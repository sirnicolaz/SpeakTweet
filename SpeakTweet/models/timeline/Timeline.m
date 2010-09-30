#import "Timeline.h"
#import "Cache.h"
#import "Account.h"
#import "Configuration.h"

static int compareStatus(Status *a, Status *b, void *ptr);

@interface Timeline(Private)

- (void)loadArchive;
- (void)saveArchive;

- (int)insertStatusToSortedTimeline:(Status*)status;
- (NSString*)latestStatusId;

- (void)restartTimer;
- (void)stopTimer;
- (void)timerExpired;

- (void)clientBeginDelegate:(TwitterClient*)sender;
- (void)clientEndDelegate:(TwitterClient*)sender;
- (void)clientSucceededDelegate:(NSArray*)insertedStatuses;
- (void)clientFailedDelegate:(TwitterClient*)sender;

@end


@implementation Timeline

@synthesize readTracker;
@synthesize autoRefresh;
@synthesize getLatest20TweetOnHumanOperation;

#pragma mark Public

- (id)initWithDelegate:(NSObject<TimelineDelegate>*)theDelegate
   withArchiveFilename:(NSString*)filename {
	if (self = [super init]) {
		delegate = [theDelegate retain];
		timeline = [[NSMutableArray alloc] init];
		if (filename) {
			archiverCachePath = [[[Cache createArchiverCacheDirectory] 
												stringByAppendingString:filename] retain];
			loadArchive = YES;
			[self loadArchive];
		}
	}
	return self;
}

- (id)initWithDelegate:(NSObject<TimelineDelegate>*)theDelegate
   withArchiveFilename:(NSString*)filename withLoadArchive:(BOOL)load {

	if (self = [super init]) {
		delegate = [theDelegate retain];
		timeline = [[NSMutableArray alloc] init];
		if (filename) {
			archiverCachePath = [[[Cache createArchiverCacheDirectory] 
								  stringByAppendingString:filename] retain];
			loadArchive = load;
			[self loadArchive];
		}
	}
	return self;
}

- (void)dealloc {
	LOG(@"Timeline#dealloc");
	[delegate release];
	[timeline release];
	[archiverCachePath release];
	[activeTwitterClient release];
	[lastReloadTime release];
	[self stopTimer];
	[super dealloc];
}

- (void)prefetch {
	LOG(@"Timeline#prefetch");
	if (timeline.count == 0) {
		[self loadArchive];
	}
	[self getTimelineWithPage:0 autoload:YES];
}

- (void)activate {
	LOG(@"Timeline#activate");
	@synchronized (self) {
		if (timeline.count == 0) {
			[self loadArchive];
		}
		[self restartTimer];
	}	
}

- (void)suspend {
	LOG(@"Timeline#suspend");
	@synchronized (self) {
		[self stopTimer];
		[self saveArchive];
	}
}

- (void)disactivate {
	LOG(@"Timeline#disactivate");
	[self suspend];
	[self clear];
}

- (void)clear {
	LOG(@"Timeline#clear");
	@synchronized (self) {
		[timeline removeAllObjects];
	}
}

- (void)clearAndRemoveCache {
	[self clear];
	if (archiverCachePath) {
		NSMutableArray *statuses = [NSMutableArray array];
		[NSKeyedArchiver archiveRootObject:statuses toFile:archiverCachePath];
	}
}

#pragma mark Archive(Private)

- (void)loadArchive {
	if (archiverCachePath && loadArchive) {
		NSMutableArray *statuses = [NSKeyedUnarchiver unarchiveObjectWithFile:archiverCachePath];
		if (statuses.count > 0) {
			BOOL rt = readTracker;
			readTracker = YES;
			[self appendStatuses:statuses];
			[delegate timeline:self clientSucceeded:nil insertedStatuses:statuses];
			readTracker = rt;
		}
	}
}

- (void)saveArchive {
	if (archiverCachePath && updated) {
		NSMutableArray *statuses = [NSMutableArray array];
		int cnt = 0;
		for (Status *s in timeline) {
			if (cnt > 100) break;
			[statuses addObject:s];
			cnt++;
		}
		[NSKeyedArchiver archiveRootObject:statuses toFile:archiverCachePath];
		updated = NO;
	}
}

#pragma mark Timeline(Private)

static int compareStatus(Status *a, Status *b, void *ptr)
{
	Message *msg_a = a.message;
	Message *msg_b = b.message;
	enum ReplyType ra = msg_a.replyType;
	enum ReplyType rb = msg_b.replyType;
	
	int c = [msg_a.statusId compare:msg_b.statusId options:NSNumericSearch];
	if (c == 0) return 0;
	
	if ((ra == _MESSAGE_REPLY_TYPE_DIRECT && rb != _MESSAGE_REPLY_TYPE_DIRECT) ||
		(ra != _MESSAGE_REPLY_TYPE_DIRECT && rb == _MESSAGE_REPLY_TYPE_DIRECT)) {
		
		int c_ = [msg_a.timestamp compare:msg_b.timestamp];
		if (c_ != 0) {
			c = c_;
		}
	}
	return (-1) * c;	
}

- (int)insertStatusToSortedTimeline:(Status*)status {
	int i = 0;
	for (Status *s in timeline) {
		int n = compareStatus(s, status, nil);
		if (n == 0) return 0;
		if (n > 0) {
			[timeline insertObject:status atIndex:i];
			return -1;
		}
		i++;
	}
	
	[timeline addObject:status];
	return 1;
}

- (NSString*)latestStatusId {
	NSString *statusId = nil;
	@synchronized(self) {
		if (timeline.count > 0) {
			Status *s = [timeline objectAtIndex:0];
			statusId = [s.message.statusId copy];
		}
	}
	return statusId;
}

#pragma mark TwitterClientDelegate(Private)

- (void)twitterClientSucceeded:(TwitterClient*)sender messages:(NSArray*)statuses {
	LOG(@"Timeline#twitterClientSucceeded");
	@synchronized(self) {
		NSMutableArray *insertedStatuses = [[[NSMutableArray alloc] init] autorelease];
		int head_cnt = 0;
		for (Message *msg in statuses) {
			Status *status = [[Status alloc] initWithMessage:msg];
			int inserted = [self insertStatusToSortedTimeline:status];
			if (inserted != 0) {
				if (! readTracker) {
					status.message.status = _MESSAGE_STATUS_READ;
				}
				[insertedStatuses addObject:status];
			}
			if (inserted == -1) {
				head_cnt++;
			}
			[status release];
		}
		
		if (statuses.count > 0) {
			updated = YES;
		}
		
		if (head_cnt % 2 == 1) {
			evenInv = ! evenInv;
		}
		
		[self performSelectorOnMainThread:@selector(clientSucceededDelegate:) 
							   withObject:insertedStatuses 
							waitUntilDone:NO];
	}
}

- (void)twitterClientFailed:(TwitterClient*)sender {
	LOG(@"Timeline#twitterClientFailed");
	[delegate timeline:self clientFailed:sender];
/*	[self performSelectorOnMainThread:@selector(clientFailedDelegate:) 
						   withObject:sender 
						waitUntilDone:NO];
*/}

- (void)twitterClientBegin:(TwitterClient*)sender {
	LOG(@"Timeline#twitterClientBegin");
	[delegate timeline:self clientBegin:sender];

/*	[self performSelectorOnMainThread:@selector(clientBeginDelegate:) 
						   withObject:sender 
						waitUntilDone:NO];
*/	
	[activeTwitterClient release];
	activeTwitterClient = [sender retain];
}

- (void)twitterClientEnd:(TwitterClient*)sender {
	LOG(@"Timeline#twitterClientEnd");
//	[delegate timeline:self clientEnd:sender];

	[activeTwitterClient release];
	activeTwitterClient = nil;

	[self performSelectorOnMainThread:@selector(clientEndDelegate:) 
						   withObject:sender 
						waitUntilDone:YES];

}


- (void)clientBeginDelegate:(TwitterClient*)sender {
	[delegate timeline:self clientBegin:sender];
}

- (void)clientEndDelegate:(TwitterClient*)sender {
	[delegate timeline:self clientEnd:sender];
}

- (void)clientSucceededDelegate:(NSArray*)insertedStatuses {
	[delegate timeline:self clientSucceeded:activeTwitterClient insertedStatuses:insertedStatuses];
}

- (void)clientFailedDelegate:(TwitterClient*)sender {
	[delegate timeline:self clientFailed:sender];
}


#pragma mark Private

- (void)getTimelineWithPage:(int)page autoload:(BOOL)autoload {
	if (activeTwitterClient == nil && [[Account sharedInstance] valid]) {
		[self stopTimer];
		NSDate *now = [NSDate date];
		BOOL got = NO;
		NSString *since_id = [self latestStatusId];
		
		if ([self count] < 20) {
			since_id = nil;
		}
		
		if (autoload) { 
			if (lastReloadTime == nil || [now timeIntervalSinceDate:lastReloadTime] > 60) {
				[delegate timeline:self requestForPage:page since_id:since_id];
				got = YES;
			}
		} else {
			if (getLatest20TweetOnHumanOperation && page < 2) {
				since_id = nil;
			}
			[delegate timeline:self requestForPage:page since_id:since_id];
			got = YES;
		}
		
		if (got) {
			[lastReloadTime release];
			lastReloadTime = [now retain];
		}

		[self restartTimer];
	}	
}

#pragma mark Public

- (void)appendStatuses:(NSArray*)statuses {

	int head_cnt = 0;
	for (Status *status in statuses) {
		int inserted = [self insertStatusToSortedTimeline:status];
		if (inserted != 0) {
			if (! readTracker) {
				status.message.status = _MESSAGE_STATUS_READ;
			}
		}
		if (inserted == -1) {
			head_cnt++;
		}
	}
	if (head_cnt % 2 == 1) {
		evenInv = ! evenInv;
	}
	
	updated = YES;
}

- (void)removeLastReloadTime {
	[lastReloadTime release];
	lastReloadTime = nil;
}

- (int)count {
	int ret = 0;
	@synchronized (self) {
		ret = timeline.count;
	}
	return ret;
}

- (Status*)statusAtIndex:(int)index {
	Status* ret = nil;
	@synchronized (self) {
		int cnt = [timeline count];
		if (index >= 0 && cnt > index) {
			ret = [timeline objectAtIndex:index];
		}
	}
	return ret;
}

- (BOOL)isEven:(int)index {
	BOOL isEven = (index % 2 == 0);
	if (evenInv) isEven = !isEven;
	return isEven;
}

- (BOOL)isClientActive {
	return activeTwitterClient != nil;
}

- (void)clientCancel {
	[activeTwitterClient cancel];
}

- (int)indexFromStatusId:(NSString*)statusId {
	int ret = NSNotFound;
	@synchronized (self) {
		int index = 0;
		for (Status *s in timeline) {
			if ([s.message.statusId isEqualToString:statusId]) {
				ret = index;
				break;
			}
			index++;
		}
	}
	return ret;
}

- (void)hilightByScreenName:(NSString*)screenName {
	@synchronized (self) {
		for (Status *s in timeline) {
			[s.message hilightUserReplyWithScreenName:screenName];
		}
	}			
}

#pragma mark ReadMark

- (NSMutableArray*)unreadStatuses {
	NSMutableArray *ret = [NSMutableArray array];
	@synchronized (self) {
		for (Status *s in timeline) {
			if (s.message.status == _MESSAGE_STATUS_NORMAL) {
				[ret addObject:[s retain]];
			}
		}
	}
	return ret;
}

- (void)markAllAsRead {
	@synchronized (self) {
		for (Status *s in timeline) {
			s.message.status = _MESSAGE_STATUS_READ;
		}
	}
}

static BOOL is_badge_unread_message(Message *message) {
	return message.replyType == _MESSAGE_REPLY_TYPE_REPLY ||
	message.replyType == _MESSAGE_REPLY_TYPE_REPLY_PROBABLE ||
	message.replyType == _MESSAGE_REPLY_TYPE_DIRECT;
}

- (int)badgeCount {
	int count = 0;
	@synchronized (self) {
		for (Status *s in timeline) {
			if (s.message.status == _MESSAGE_STATUS_NORMAL) {
				if (is_badge_unread_message(s.message)) {
					count++;
				}
			}
		}
	}	
	return count;
}

#pragma mark Timer

- (void)restartTimer {
	[self stopTimer];

	if (autoRefresh) {
		int refreshInterval = [[Configuration instance] refreshIntervalSeconds];

		if (refreshInterval < 30) {
			return;
		}

		refreshTimer = [[NSTimer scheduledTimerWithTimeInterval:refreshInterval
														  target:self
														selector:@selector(timerExpired)
														userInfo:nil
														 repeats:YES] retain];
	}
}

- (void)stopTimer {
    if (refreshTimer) {
        [refreshTimer invalidate];
        [refreshTimer release];
		refreshTimer = nil;
    }
}

- (void)timerExpired {
	[self getTimelineWithPage:0 autoload:YES];
}

@end
