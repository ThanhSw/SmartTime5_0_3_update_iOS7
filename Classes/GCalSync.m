//
//  GCalPush.m
//  iVo
//
//  Created by Left Coast Logic on 10/24/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GCalSync.h"
#import "TaskManager.h"
//#import "GData.h"
#import "SmartTimeAppDelegate.h"
#import "SmartViewController.h"
//#import "GCalParser.h"
#import "Alert.h"
#import "DeletedTEKeys.h"

#import "Projects.h"
//#import "GData.h"

#import "TaskActionResult.h"

//#import "SyncMappingTableViewController.h"

extern TaskManager *taskmanager;
extern SmartTimeAppDelegate *App_Delegate;
extern SmartViewController *_smartViewController;
extern ivo_Utilities	*ivoUtility;
extern NSMutableArray	*projectList;

NSMutableArray	*originalGCalList = nil;
NSMutableArray	*originalGCalColorList = nil;
NSDictionary *originalGCalColorDict = nil;

static int staticID = 0;
static int _staticTaskKey = -5000;

NSString *_gcalName4Events[PROJECT_NUM];
NSString *_gcalName4Tasks[PROJECT_NUM];

GCalSync *_gcalSyncSingleton = nil;

//ST3.1 Admod
#ifdef FREE_VERSION
static bool _liteSyncEnable = YES;
#else
static bool _liteSyncEnable = NO;
#endif

/*
NSString *_startMin = @"2009-07-14T00:00:00+07:00";
NSString *_startMax = @"2009-07-27T00:00:00+07:00";

NSString *_updateMin = @"2009-03-20T00:00:00+07:00";
*/

@implementation GCalSync

@synthesize mUserName;
@synthesize mPassword;

@synthesize STEventCalendar;
@synthesize STTaskCalendar;

@synthesize syncTime;
@synthesize lastSyncTime;
@synthesize lastDeleteTime;

@synthesize syncErrorMsg;
@synthesize mapReady;
/*
-(id) init: (NSString *)userName : (NSString *)password: (NSDate *)initSyncTime
{
	if (self = [super init])
	{
		self.mUserName = userName;
		self.mPassword = password;
		
		nSync = 0;
		nErr = 0;
		
		staticID = 0;
		
		_staticTaskKey = -5000;		
		
		for (int i=0; i<PROJECT_NUM; i++)
		{
			STEventCalendars[i] = nil;
			STTaskCalendars[i] = nil;
			
			gCalEvents[i] = nil;
			gCalTasks[i] = nil;
			gCalTasksDone[i] = nil;
			
			gCalInvalidEvents[i] = nil;
			
			pushEvents[i] = nil;
			pushTasks[i] = nil;
			
			syncEventFlags[i] = NO;
			syncREFlags[i] = NO;
			syncTaskFlags[i] = NO;
			
			loadEventFlags[i] = NO;
			loadTaskFlags[i] = NO;
		}
		
		pushTaskReady = NO;
		pushEventReady = NO;

		syncTaskReady = NO;
		syncEventReady = NO;
		
		reconcileDone = NO;	
		
		mapReady = NO;
		
		self.syncTime = initSyncTime;
		self.lastSyncTime = initSyncTime;
		
		noProjectMapping = YES;
		[self resetProjectMapping];
		
		noEvent2Sync = YES;
		
		gcalCalendars = nil;
	}
	
	return self;
}

-(GDataServiceGoogleCalendar *) calendarService {
	
	static GDataServiceGoogleCalendar* service = nil;
	
	if (!service) {
		service = [[GDataServiceGoogleCalendar alloc] init];
	}
	
	//nang 3.6
	//[service setServiceShouldFollowNextLinks:YES];
	//[service setShouldCacheDatedData:YES];
	//[service setShouldServiceFeedsIgnoreUnknowns:YES];
	//-------
	[service setUserCredentialsWithUsername:self.mUserName password:self.mPassword];
	
	return service;
}

-(void)changeTask:(Task *)task withDate:(NSDate *)date eTag:(NSString *)eTag
{
	if (eTag == nil)
	{
		eTag = @"";
	}
	
	task.isUsedExternalUpdateTime = YES;
	task.taskDateUpdate = date;
	
	NSRange range = [task.gcalEventId rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"®"] options:NSBackwardsSearch];
	
	if (range.location != NSNotFound)
	{
		range.location += 1;
		range.length = task.gcalEventId.length - range.location;
		
		task.gcalEventId = [task.gcalEventId stringByReplacingCharactersInRange:range withString:eTag];
	}
	
	[task update];
	
	//printf("changeTask %s - id:%s, with gcal date update: %s\n", [task.taskName UTF8String], [task.gcalEventId UTF8String], [[date description] UTF8String]);
}

-(void)linkTask: (Task *)task withEvent:(GDataEntryCalendarEvent *)event
{
//	if (task.gcalEventId == nil || [task.gcalEventId isEqualToString:@""])
//	{
		NSString *eventId = [NSString stringWithFormat:@"%@®%@", [event identifier], [event ETag]];
		
		task.isUsedExternalUpdateTime = YES;
		task.taskDateUpdate = [[event updatedDate] date];

		task.gcalEventId = eventId;
	
	//printf("Link task(%s) - gcal id (%s) - date update (%s)\n", [task.taskName UTF8String], [task.gcalEventId UTF8String], [[task.taskDateUpdate description] UTF8String]);
		
		[task update];
//	}
}

-(void) updateSyncTime: (NSDate *)gcalDateUpdate
{
	NSInteger syncType = [taskmanager.currentSetting syncType];

	if (syncType != 0) //only update sync time for 2-way sync
	{
		return;
	}
	
	if (self.syncTime == nil)
	{
		self.syncTime = gcalDateUpdate;
	}
	else
	{
		NSComparisonResult res = [ivoUtility compareDate:self.syncTime withDate:gcalDateUpdate];
		
		if (res == NSOrderedAscending)
		{
			self.syncTime = gcalDateUpdate;
		}
	}
}

-(void) rewindSyncTime: (NSDate *)dateUpdate
{
	NSInteger syncType = [taskmanager.currentSetting syncType];

	if (syncType == 0) //2-way sync -> don't rewind
	{
		return;
	}
	
	if (self.syncTime == nil)
	{
		self.syncTime = dateUpdate;
	}
	else
	{
		//fix DST
		//NSDate *dt = [dateUpdate addTimeInterval:-60];
		NSDate *dt = [ivoUtility dateByAddNumSecond:-60 toDate:dateUpdate];
		
		NSComparisonResult res = [ivoUtility compareDate:self.syncTime withDate:dt];
		
		if (res == NSOrderedDescending)
		{
			self.syncTime = dt;
		}
	}	
}

-(void)saveLastSyncTime
{
	if ([self.syncTime compare:self.lastDeleteTime] == NSOrderedAscending)
	{
		self.syncTime = self.lastDeleteTime;
	}
	
	taskmanager.currentSetting.lastSyncedTime = self.syncTime;
	self.lastSyncTime = self.syncTime;
	
	[taskmanager.currentSetting update];
}

-(void)reportError:(NSInteger) errCode:(NSString *)taskName
{
	NSString *msg = nil;
	
	switch (errCode)
	{
		case ERR_TASK_NOT_BE_FIT_BY_RE:
			msg = [NSString stringWithFormat:@"\'[%@]\' %@", taskName, NSLocalizedString(@"_notFitText", @"");
			break;
		case ERR_RE_MAKE_TASK_NOT_BE_FIT:
			msg = [NSString stringWithFormat:@"\'[%@]\' %@", taskName, NSLocalizedString(@"_makeNotFitText", @"")];
			break;
	}
	
	if (msg != nil)
	{
		if (self.syncErrorMsg == nil)
		{
			self.syncErrorMsg = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"_syncErrText", @""), msg];
		}
		else
		{
			self.syncErrorMsg = [self.syncErrorMsg stringByAppendingFormat:@", %@", msg];
		}
	}
}

-(BOOL)checkSyncKey:(double) key1: (double) key2
{
	double diff = key1 - key2;
	
	if (diff < 0)
	{
		diff = diff *(-1);
	}
	
	if (diff < 0.001)
	{
		return YES;
	}
	
	return NO;
}

-(BOOL)checkKey:(SyncKeyPair) keypair
{
	for (Task *task in taskmanager.taskList)
	{
		
		double diff =  task.taskSynKey - keypair.syncKey;
		
		if (diff < 0)
		{
			diff = diff*(-1);
		}
		
		if (diff < 0.001)
		{
			return YES;
		}
	}
	
	//printf("checkKey: NOT FOUND, key:%d, syncKey:%lf\n", keypair.key, keypair.syncKey);
	
	return NO;
}

-(BOOL)checkLongEvent:(GDataEntryCalendarEvent *)event
{
	GDataDateTime *startTime = nil;
	GDataDateTime *endTime = nil;
	
	NSArray *times = [event times];
	GDataWhen *when = nil;
	if ([times count] > 0) {
		when = [times objectAtIndex:0];
		startTime = [when startTime];
		endTime = [when endTime];
	}
	
	if (startTime != nil && endTime != nil)
	{
		NSTimeInterval duration = [[endTime date] timeIntervalSinceDate:[startTime date]];
		
		if (duration >= 24*60*60)
		{
			//printf("Long duration: start (%s) end (%s)\n", [[[startTime date] description] UTF8String], [[[endTime date] description] UTF8String]);
			return YES;
		}
	}
	
	return NO;
}

-(BOOL)checkDeleteId:(NSString *)eventId: (NSArray *)delList
{
	for (DeletedTEKeys *delKey in delList)
	{
		if (delKey.gcalEventId != nil && ![delKey.gcalEventId isEqualToString:@""] && delKey.primaryKey >= 0)
		{
			NSRange range = [delKey.gcalEventId rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"®"] options:NSBackwardsSearch];
			
			if (range.location != NSNotFound && [eventId isEqualToString:[delKey.gcalEventId substringToIndex:range.location]])
			{
				return YES;
			}
		}
	}
	
	return NO;
}

-(BOOL)checkDelete:(SyncKeyPair)keypair: (NSArray *)delList
{
	for (DeletedTEKeys *delKey in delList)
	{
		double diff = keypair.syncKey - delKey.syncKey;
			
		if (diff < 0)
		{
			diff = diff*(-1);
		}
			
		if (diff < 0.001)
		{
			//printf("check DELETE: YES for ST key:%d, syncKey: %lf\n", delKey.primaryKey, delKey.syncKey); 
				
			return YES;
		}
	}
	
	//printf("check DELETE - sync key %lf NOT FOUND in ST DELETE LIST\n", keypair.syncKey);
	
	return NO;
}

- (NSDate *) getDateUpdate: (GDataEntryCalendarEvent *)entry
{
	NSDate *dt = [[entry updatedDate] date];
	
	for (GDataExtendedProperty *extProperty in [entry extendedProperties])
	{
		if ([extProperty.name isEqualToString:@"ST_DateUpdate"])
		{
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
			
			NSDate *stdt = [formatter dateFromString:extProperty.value];
			[formatter release];
			
			NSTimeInterval diff = [dt timeIntervalSinceDate:stdt];
			
			NSDate *tmp = dt;
			
			if (diff < 120)
			{
				dt = stdt;
			}
			
			//printf("getDateUpdate returns (%s) for event (%s) - gcal date (%s) , st date (%s)\n", [[dt description] UTF8String], [[[entry title] stringValue] UTF8String], [[tmp description] UTF8String], [[stdt description] UTF8String]); 
			
			break;
		}
	}
		
	return [[dt retain] autorelease];
}

- (NSString *) getDummyRE: (GDataEntryCalendarEvent *)entry
{
	for (GDataExtendedProperty *extProperty in [entry extendedProperties])
	{
		if ([extProperty.name isEqualToString:@"ST_DummyRE"])
		{
			return extProperty.value;
		}
	}
	
	return nil;
}

- (NSString *) getSyncKeyOfEventEntry: (GDataEntryCalendarEvent *)entry
{
	for (GDataExtendedProperty *extProperty in [entry extendedProperties])
	{
		if ([extProperty.name isEqualToString:@"ST_SyncKey"])
		{
			return [[extProperty.value copy] autorelease];
		}			
	}
	
	return nil;
}

- (SyncKeyPair) getKeyOfEventEntry: (GDataEntryCalendarEvent *)entry
{
	SyncKeyPair ret;
	
	ret.key = -123456;
	ret.syncKey = 0;
	
	NSArray * extProperties = [entry extendedProperties];
	
	if ([extProperties count] == 0)
	{
		return ret;
	}
	else
	{
		for (GDataExtendedProperty *extProperty in extProperties)
		{
			if ([extProperty.name isEqualToString:@"ST_STID"])
			{
				ret.key = [extProperty.value integerValue];
			}
			if ([extProperty.name isEqualToString:@"ST_SyncKey"])
			{
				ret.syncKey = [extProperty.value doubleValue];
			}			
		}
	}
	
	return ret;
}

- (BOOL) checkDoneTask: (GDataEntryCalendarEvent *)entry
{
	NSArray * extProperties = [entry extendedProperties];

	if ([extProperties count] == 0)
	{
		return NO;
	}
	else
	{
		for (GDataExtendedProperty *extProperty in extProperties)
		{
			if ([extProperty.name isEqualToString:@"ST_Completed"])
			{
				NSInteger completed = [extProperty.value integerValue];
				
				if (completed == 1)
				{
					return YES;
				}
			}
		}
	}
	
	return NO;
}

-(void)printDictionary:(NSDictionary *) dict
{
	//printf("_________ GCal RE series __________\n");
	
	NSEnumerator *enumerator = [dict keyEnumerator];
	
	NSString *key;
	
	while (key = [enumerator nextObject]) 
	{
		NSMutableArray *value;
		
		value = [dict objectForKey:key];
			int c = 0;
			//printf("-> RE series with id: %s\n", [key UTF8String]);
			for (GDataEntryCalendarEvent *event in value)
			{
				GDataEventStatus *status = [event eventStatus];
				
				NSString *statusString = [status stringValue];
				
				NSString *type = nil;
				
				if ([statusString isEqualToString:@"http://schemas.google.com/g/2005#event.canceled"])
				{
					type = @"Deleted";
				}
				else
				{
					type = @"Not Deleted"; 
				}
				
				SyncKeyPair keypair = [self getKeyOfEventEntry:event];
				
				NSString *orgStart = nil;
				
				GDataOriginalEvent *orgEvent = [event originalEvent]; 
				
				if (orgEvent != nil)
				{
					GDataWhen *when= [orgEvent originalStartTime];
				
					GDataDateTime *startTime = [when startTime];
					
					orgStart = [startTime RFC3339String];
				}
				
				//printf("#%d. %s [key = %d, type = %s, original start = %s, synKey = %lf]\n", c++, [[[event title] stringValue] UTF8String], keypair.key, [type UTF8String], [orgStart UTF8String], keypair.syncKey);
			}
			//printf("<- RE series\n");	
	}
	
	//printf("_________ GCal RE series __________\n");
}

-(void)printTaskDictionary:(NSDictionary *) dict
{
	//printf("_________ Task Dictionary __________\n");
	
	NSEnumerator *enumerator = [dict keyEnumerator];
	
	NSString *key;
	
	int count = 1;
	
	while (key = [enumerator nextObject]) 
	{
		Task *task = [dict objectForKey:key];
		//printf("#%d. Task (%s) - id (%s) - start: (%s)\n", count++, [task.taskName UTF8String], [key UTF8String], [[task.taskStartTime description] UTF8String]);	
	}
	
	//printf("_________ Task Dictionary __________\n");
}

-(void)printGEvent:(GDataEntryCalendarEvent *)event
{
	//printf("***** GCal Event Info\n");
	
	NSString *title = [[event title] stringValue];
	
	//printf("title = %s\n", [title UTF8String]);
	
	GDataDateTime *startTime = nil;
	GDataDateTime *endTime = nil;
	
	NSArray *times = [event times];
	GDataWhen *when = nil;
	if ([times count] > 0) {
		when = [times objectAtIndex:0];
		startTime = [when startTime];
		endTime = [when endTime];
	}

	//printf("start time = %s\n", [[[startTime date] description] UTF8String]);
	//printf("end time = %s\n", [[[endTime date] description] UTF8String]);

	GDataRecurrence *recur = [event recurrence];
	
	if (recur != nil)
	{
		//printf("recur = %s\n", [[recur stringValue] UTF8String]);
	}
	
	for (GDataExtendedProperty *prop in [event extendedProperties])
	{
		//printf("%s = %s\n", [[prop name] UTF8String], [[prop value] UTF8String]);
	}
	//printf("GCal Event Info ******\n");	
}

-(void)updateTask:(Task *) task withGCalEvent:(GDataEntryCalendarEvent *)event
{
	GDataDateTime *startTime = nil;
	GDataDateTime *endTime = nil;
	
	NSString *title = [[event title] stringValue];
	
	NSString *note = [[event content] stringValue];
	

	GDataWhen *when = [[event times] objectAtIndex:0];
	
	if (when!=nil && ![[when startTime] hasTime] && ![[when endTime] hasTime])
	{
		task.isAllDayEvent = YES;
		
	}
	else
	{
		task.isAllDayEvent = NO;
	}
	
	GDataRecurrence *recur = [event recurrence];
	
	if (recur != nil)
	{
		GCalParser *parser = [[GCalParser alloc] init];
	
		[parser parse:[recur stringValue]];
		
		[parser updateRE:task];
		
		startTime = [GDataDateTime dateTimeWithDate:task.taskStartTime timeZone:[NSTimeZone systemTimeZone]];
		endTime = [GDataDateTime dateTimeWithDate:task.taskEndTime timeZone:[NSTimeZone systemTimeZone]];
		
		[parser release];
	}
	else
	{
		startTime = [when startTime];
				
		endTime = [when endTime];
		
		task.taskRepeatID = 0;
	}
		
	NSArray *reminders = [when reminders];
	
	if (reminders == nil || [reminders count] == 0)
	{
		//printf("task: %s has NO REMINDER\n", [title UTF8String]);
	}

	
	NSMutableArray *alerts = [NSMutableArray arrayWithCapacity:[reminders count]];
	
	for (GDataReminder *reminder in reminders)
	{
		Alert *alert = [[Alert alloc] init]; 
		
		NSString *method = [reminder method];
		
		if ([method isEqualToString:@"alert"])
		{
			//printf("set ALERT BY: 1\n");
			[alert setAlertBy:1];
		}
		else if ([method isEqualToString:@"sms"])
		{
			//printf("set ALERT BY: 0\n");
			[alert setAlertBy:0];
		}
		else if ([method isEqualToString:@"email"])
		{
			//printf("set ALERT BY: 2\n");			
			[alert setAlertBy:2];
		}
		
		NSString *period = [reminder hours];
		
		if (period != nil)
		{
			//printf("set TIME UNIT: 1, AMOUNT: %d\n", [period integerValue]);			
			[alert setTimeUnit:1];
			[alert setAmount:[period integerValue]];
		}
		else
		{
			period = [reminder minutes];
			
			if (period != nil)
			{
				NSInteger amount = [period integerValue];
				
				if (amount >= 7*24*60)
				{
					[alert setTimeUnit:3];
					amount = amount/(7*24*60);
					
					//printf("set TIME UNIT: 3, AMOUNT: %d\n", amount);
				}
				else if (amount >= 24*60 && amount < 7*24*60)
				{
					[alert setTimeUnit:2];
					
					amount = amount/(24*60);
					
					//printf("set TIME UNIT: 2, AMOUNT: %d\n", amount);
				}
				else if (amount >= 60 && amount < 24*60)
				{
					[alert setTimeUnit:1];
					
					amount = amount/60;
					
					//printf("set TIME UNIT: 1, AMOUNT: %d\n", amount);
				}
				else
				{
					[alert setTimeUnit:0];
					//printf("set TIME UNIT: 0, AMOUNT: %d\n", amount);
				}
				
				[alert setAmount:amount];
			}
			else
			{
				period = [reminder days];
				
				if (period != nil)
				{
					[alert setTimeUnit:2];
					
					[alert setAmount:[period integerValue]];
				}
			}
		}
					
		[alerts addObject:alert];
		
		[alert release];
	}
					
	[task updateAlertList:alerts];
		
	NSArray *locations = [event locations];
	
	NSString *location = @"";
	
	for (GDataWhere *where in locations)
	{
		NSString *loc = [where stringValue];
		
		if (loc != nil && ![loc isEqualToString:@""])
		{
			location = loc;
			
			break;
		}
	}		
	
	task.taskName = title;
	task.taskDescription = note;
	task.taskLocation = location;
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

	if (startTime != nil)
	{
		//printf("Event (%s) - Start Time (%s) - Universal?(%s)\n", [title UTF8String], [[startTime RFC3339String] UTF8String], [startTime isUniversalTime]?"YES":"NO");
		if (task.isAllDayEvent)
		{			
			NSDateComponents *stcomps = [startTime dateComponents];
			//printf("start components year (%d) - month (%d) - day (%d) - hour (%d) - minute (%d) - second (%d)\n", [stcomps year], [stcomps month], [stcomps day], [stcomps hour], [stcomps minute], [stcomps second]);

			[stcomps setHour:0];
			[stcomps setMinute:0];
			[stcomps setSecond:0];
			
			task.taskStartTime = [gregorian dateFromComponents:stcomps];
			
			//printf("ADE (%s), start time (%s) - date before: (%s), start time after: (%s)\n", [task.taskName UTF8String], [[startTime RFC3339String] UTF8String], [[[startTime date] description] UTF8String], [[task.taskStartTime description] UTF8String]);
		}
		else
		{
			task.taskStartTime = [startTime date];
			//printf("Normal Event (%s), start time before: (%s), start time after: (%s)\n", [task.taskName UTF8String], [[startTime description] UTF8String], [[task.taskStartTime description] UTF8String]);
		}
	}
	else
	{
		task.taskStartTime = [NSDate date];
	}
	
	if (endTime != nil)
	{
		if (task.isAllDayEvent)
		{
			NSDateComponents *stcomps = [startTime dateComponents];
			
			NSDateComponents *etcomps = [endTime dateComponents];
			
			//printf("end components year (%d) - month (%d) - day (%d) - hour (%d) - minute (%d) - second (%d)\n", [etcomps year], [etcomps month], [etcomps day], [etcomps hour], [etcomps minute], [etcomps second]);
			
			[etcomps setHour:0];
			[etcomps setMinute:0];
			[etcomps setSecond:0];
			
			task.taskEndTime = [gregorian dateFromComponents:etcomps];
			
			if ([etcomps year] == [stcomps year] && [etcomps month] == [stcomps month] && [etcomps day] == [stcomps day])
			{
				//fix DST
				//task.taskEndTime = [task.taskEndTime addTimeInterval:24*60*60];
				task.taskEndTime = [ivo_Utilities dateByAddNumDay:1 toDate:task.taskEndTime];
			}
		}
		else
		{			
			task.taskEndTime = [endTime date];
		}
		

		task.taskHowLong = [task.taskEndTime timeIntervalSinceDate:task.taskStartTime];
	}
	else
	{
		task.taskHowLong = 15*60;
	}

	[gregorian release];
	
	
	task.taskWhere = [taskmanager.currentSetting contextDefID];
	
	for (GDataExtendedProperty *prop in [event extendedProperties])
	{
		if ([prop.name isEqualToString:@"ST_Context"])
		{
			NSInteger context = [prop.value integerValue];
			
			task.taskWhere = context;
		}
		else if ([prop.name isEqualToString:@"ST_Deadline"])
		{
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
			
			NSDate *deadline = [formatter dateFromString:prop.value];
			
			//printf("Task deadline: len (%d) before (%s) - after (%s)\n", [prop.value length], [prop.value UTF8String], [[deadline description] UTF8String]);
			
			task.taskDeadLine = deadline;
			
			[formatter release];
		}
		else if ([prop.name isEqualToString:@"ST_IsUseDeadline"])
		{
			task.taskIsUseDeadLine = [prop.value integerValue];
		}
		else if ([prop.name isEqualToString:@"ST_Contact"])
		{
			task.taskContact = prop.value;
			
			//printf("Contact: %d\n", task.taskContact);
		}
		else if ([prop.name isEqualToString:@"ST_DueEnd"])
		{
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
			
			NSDate *dueEnd = [formatter dateFromString:prop.value];
			
			task.taskDueEndDate = dueEnd;
			
			[formatter release];
		}
		
	}	
	
	task.gcalEventId = [NSString stringWithFormat:@"%@®%@", [event identifier], [event ETag]];
	
	task.isUsedExternalUpdateTime = YES;
	task.taskDateUpdate = [[event updatedDate] date];
	
	[self updateSyncTime:[[event updatedDate] date]];	
}

-(NSString *)buildRecurrence:(Task *) task
{
	if (task.taskRepeatID == 0)
	{
		return nil;
	}
	
	NSString *daily_never = @"DTSTART;TZID=tzid_value:dt_startValue\r\nDTEND;TZID=tzid_value:dt_endValue\r\nRRULE:FREQ=DAILY;INTERVAL=interval_value";
	NSString *daily_until = @"DTSTART;TZID=tzid_value:dt_startValue\r\nDTEND;TZID=tzid_value:dt_endValue\r\nRRULE:FREQ=DAILY;INTERVAL=interval_value;UNTIL=until_value";

	NSString *weekly_never = @"DTSTART;TZID=tzid_value:dt_startValue\r\nDTEND;TZID=tzid_value:dt_endValue\r\nRRULE:FREQ=WEEKLY;INTERVAL=interval_value;BYDAY=byDay_value";
	NSString *weekly_until = @"DTSTART;TZID=tzid_value:dt_startValue\r\nDTEND;TZID=tzid_value:dt_endValue\r\nRRULE:FREQ=WEEKLY;INTERVAL=interval_value;BYDAY=byDay_value;UNTIL=until_value";

	NSString *monthly_byDay_never = @"DTSTART;TZID=tzid_value:dt_startValue\r\nDTEND;TZID=tzid_value:dt_endValue\r\nRRULE:FREQ=MONTHLY;INTERVAL=interval_value;BYDAY=byDay_value";
	NSString *monthly_byDay_until = @"DTSTART;TZID=tzid_value:dt_startValue\r\nDTEND;TZID=tzid_value:dt_endValue\r\nRRULE:FREQ=MONTHLY;INTERVAL=interval_value;BYDAY=byDay_value;UNTIL=until_value";

	NSString *monthly_byMonth_never = @"DTSTART;TZID=tzid_value:dt_startValue\r\nDTEND;TZID=tzid_value:dt_endValue\r\nRRULE:FREQ=MONTHLY;INTERVAL=interval_value;BYMONTH=byMonth_value";
	NSString *monthly_byMonth_until = @"DTSTART;TZID=tzid_value:dt_startValue\r\nDTEND;TZID=tzid_value:dt_endValue\r\nRRULE:FREQ=MONTHLY;INTERVAL=interval_value;BYMONTH=byMonth_value;UNTIL=until_value";

	NSString *yearly_never = @"DTSTART;TZID=tzid_value:dt_startValue\r\nDTEND;TZID=tzid_value:dt_endValue\r\nRRULE:FREQ=YEARLY;INTERVAL=interval_value";
	NSString *yearly_until = @"DTSTART;TZID=tzid_value:dt_startValue\r\nDTEND;TZID=tzid_value:dt_endValue\r\nRRULE:FREQ=YEARLY;INTERVAL=interval_value;UNTIL=until_value";
	
	
	NSString *tzid_value = [[NSTimeZone systemTimeZone] name];
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[gregorian setTimeZone:[NSTimeZone systemTimeZone]];
	
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	
//	//printf("*build recurrence - task RE start time: %s\n", [[task.taskREStartTime description] UTF8String]);
	
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:task.taskREStartTime];
	
	NSString *dt_startValue = [NSString stringWithFormat:@"%04d%02d%02dT%02d%02d%02d", [comps year], [comps month], [comps day], [comps hour], [comps minute], [comps second]];	
	
	if (task.isAllDayEvent)
	{
		dt_startValue = [NSString stringWithFormat:@"%04d%02d%02d", [comps year], [comps month], [comps day]];
	}

	//fix DST
	//comps = [gregorian components:unitFlags fromDate:[task.taskREStartTime addTimeInterval:task.taskHowLong]];
	comps = [gregorian components:unitFlags fromDate:[ivoUtility dateByAddNumSecond:task.taskHowLong toDate:task.taskREStartTime]];

	NSString *dt_endValue = [NSString stringWithFormat:@"%04d%02d%02dT%02d%02d%02d", [comps year], [comps month], [comps day], [comps hour], [comps minute], [comps second]];	

	if (task.isAllDayEvent)
	{
		dt_endValue = [NSString stringWithFormat:@"%04d%02d%02d", [comps year], [comps month], [comps day]];
	}
	
	
	NSArray *options = [task.taskRepeatOptions componentsSeparatedByString:@"/"];
	
	NSString *interval_value = [options objectAtIndex:0];
							 
	NSArray *days = [[options objectAtIndex:1] componentsSeparatedByString:@"|"];
							   
	NSString *byDay_value = @"";
							   
	for (int i=0; i<[days count]; i++)
	{
		NSInteger dayOfWeek = [[days objectAtIndex:i] integerValue];
		
		NSString *dayStr = @"";
		
		switch (dayOfWeek)
		{
			case 1:
				//dayStr = @"Su";
				dayStr = @"SU";
				break;
			case 2:
				//dayStr = @"Mo";
				dayStr = @"MO";
				break;
			case 3:
				//dayStr = @"Tu";
				dayStr = @"TU";
				break;
			case 4:
				//dayStr = @"We";
				dayStr = @"WE";
				break;
			case 5:
				//dayStr = @"Th";
				dayStr = @"TH";
				break;
			case 6:
				//dayStr = @"Fr";
				dayStr = @"FR";
				break;
			case 7:
				//dayStr = @"Sa";
				dayStr = @"SA";
		}				
		
		if (i == [days count] -1)
		{
			byDay_value = [byDay_value stringByAppendingString:dayStr];
		}
		else
		{
			byDay_value = [byDay_value stringByAppendingFormat:@"%@,",dayStr];
		}
	}							   
							   
	comps = [gregorian components:unitFlags fromDate:task.taskEndRepeatDate];

	NSString *until_value = [NSString stringWithFormat:@"%04d%02d%02dT%02d%02d%02dZ", [comps year], [comps month], [comps day], [comps hour], [comps minute], [comps second]];	
							   
	NSString *recurStr = nil;
							   
	switch (task.taskRepeatID)
	{
		case REPEAT_DAILY:
			if (task.taskRepeatTimes == 0) //never
			{
				recurStr = daily_never;
			}
			else
			{
				recurStr = [daily_until stringByReplacingOccurrencesOfString:@"until_value" withString:until_value];
			}
			
			break;
		case REPEAT_WEEKLY:
		{
			if (task.taskRepeatTimes == 0) //never
			{
				recurStr = weekly_never;
			}
			else
			{
				recurStr = [weekly_until stringByReplacingOccurrencesOfString:@"until_value" withString:until_value];
			}
			
			recurStr = [recurStr stringByReplacingOccurrencesOfString:@"byDay_value" withString:byDay_value];
		}	
		break;
		case REPEAT_MONTHLY:
		{
			NSString *repeatBy = [options objectAtIndex:2];
			
			if (task.taskRepeatTimes == 0) //never
			{
				if ([repeatBy isEqualToString:@"0"])
				{
					recurStr = monthly_byMonth_never;
				}
				else if ([repeatBy isEqualToString:@"1"])
				{
					recurStr = monthly_byDay_never;
				}
			}
			else
			{
				if ([repeatBy isEqualToString:@"0"])
				{
					recurStr = monthly_byMonth_until;
				}
				else if ([repeatBy isEqualToString:@"1"])
				{
					recurStr = monthly_byDay_until;
				}
				
				recurStr = [recurStr stringByReplacingOccurrencesOfString:@"until_value" withString:until_value];
			}
			
			if ([repeatBy isEqualToString:@"0"])
			{
				//printf("Task Start Time :%s\n", [[task.taskStartTime description] UTF8String]);
				NSInteger dayOfMonth = [ivoUtility getDay:task.taskStartTime];
				
				NSString *byMonth_value = [NSString stringWithFormat:@"%d", dayOfMonth];
				
				recurStr = [recurStr stringByReplacingOccurrencesOfString:@"byMonth_value" withString:byMonth_value];
				
			}
			else if ([repeatBy isEqualToString:@"1"])
			{
				NSInteger weekOfMonth = [ivoUtility getWeekdayOrdinal:task.taskStartTime];
				
				NSInteger dayOfWeek = [ivoUtility getWeekday:task.taskStartTime];
				
				NSString *dayStr = @"";
				
				switch (dayOfWeek)
				{
					case 1:
						dayStr = @"SU";
						break;
					case 2:
						dayStr = @"MO";
						break;
					case 3:
						dayStr = @"TU";
						break;
					case 4:
						dayStr = @"WE";
						break;
					case 5:
						dayStr = @"TH";
						break;
					case 6:
						dayStr = @"FR";
						break;
					case 7:
						dayStr = @"SA";
				}
				
				NSString *byMonth_value = [NSString stringWithFormat:@"%d%@", weekOfMonth, dayStr];
				
				recurStr = [recurStr stringByReplacingOccurrencesOfString:@"byDay_value" withString:byMonth_value];
			}			
		}
		break;
		case REPEAT_YEARLY:
			if (task.taskRepeatTimes == 0) //never
			{
				recurStr = yearly_never;
			}
			else
			{
				recurStr = [yearly_until stringByReplacingOccurrencesOfString:@"until_value" withString:until_value];
			}
			
			break;			
	}
	 
	recurStr = [recurStr stringByReplacingOccurrencesOfString:@"tzid_value" withString:tzid_value];

	recurStr = [recurStr stringByReplacingOccurrencesOfString:@"dt_startValue" withString:dt_startValue];

	recurStr = [recurStr stringByReplacingOccurrencesOfString:@"dt_endValue" withString:dt_endValue];

	recurStr = [recurStr stringByReplacingOccurrencesOfString:@"interval_value" withString:interval_value];
	
	[gregorian release];
	
	//printf("recurrence string: %s\n", [recurStr UTF8String]);
	 
	 return [recurStr copy];
}

-(void)updatePK4GCalEvent:(GDataEntryCalendarEvent *)event:(NSInteger)key:(double)syncKey
{
	GDataExtendedProperty *idProperty = [GDataExtendedProperty propertyWithName:@"ST_STID" value:[NSString stringWithFormat:@"%d", key]];
	GDataExtendedProperty *syncKeyProperty = [GDataExtendedProperty propertyWithName:@"ST_SyncKey" value:[NSString stringWithFormat:@"%lf",syncKey]];
	
	for (GDataExtendedProperty *prop in [event extendedProperties])
	{
		if ([prop.name isEqualToString:@"ST_STID"])
		{
			prop.value = idProperty.value;
			
			idProperty = nil;
		}
		else if ([prop.name isEqualToString:@"ST_SyncKey"])
		{
			prop.value = syncKeyProperty.value;
			
			syncKeyProperty = nil;
		}		
	}
	
	if (idProperty != nil)
	{
		[event addExtendedProperty:idProperty];	
	}	
	if (syncKeyProperty != nil)
	{
		[event addExtendedProperty:syncKeyProperty];	
	}	
	
}

-(void)updateDummyREHRef:(GDataEntryCalendarEvent *)event:(NSString *)href
{
	GDataExtendedProperty *dummyREProperty = [GDataExtendedProperty propertyWithName:@"ST_DummyRE" value:href];
	
	for (GDataExtendedProperty *prop in [event extendedProperties])
	{
		if ([prop.name isEqualToString:@"ST_DummyRE"])
		{
			prop.value = dummyREProperty.value;
			
			dummyREProperty = nil;
		}
	}
	
	if (dummyREProperty != nil)
	{
		[event addExtendedProperty:dummyREProperty];	
	}	
	
}

-(void)updateGCalEvent:(GDataEntryCalendarEvent *)event withTask:(Task *) task
{
	NSString *title = (task.taskCompleted==1?[NSString stringWithFormat:@"(x) %@", task.taskName]:task.taskName);
	
	[event setTitleWithString:title];			
	[event setContentWithString:task.taskDescription];
	
	GDataDateTime *startDateTime = [GDataDateTime dateTimeWithDate:task.taskStartTime timeZone:[NSTimeZone systemTimeZone]];
	GDataDateTime *endDateTime = [GDataDateTime dateTimeWithDate:task.taskEndTime timeZone:[NSTimeZone systemTimeZone]];
	
	if (task.isAllDayEvent == 1)
	{
		[startDateTime setHasTime:NO];
		[endDateTime setHasTime:NO];
	}
	
	if (task.taskRepeatID > 0 && task.parentRepeatInstance == -1)
	{
		GDataRecurrence *recur = [event recurrence];
		
		NSString *recurStr = [self buildRecurrence:task];
		
		if (recur != nil)
		{
			//printf("*** update original RE (%s) with recurrence string: %s\n", [task.taskName UTF8String], [recurStr UTF8String]);
			
			[recur setStringValue:recurStr];
		}
		else if (recurStr != nil)
		{
			//printf("*** set original RE (%s) with recurrence string: %s\n", [task.taskName UTF8String], [recurStr UTF8String]);	
			[event setRecurrence:[GDataRecurrence recurrenceWithString:recurStr]];
			
			//ST3.2: GCal does not allow both gd:when and gd:recurrence
		}
		
		if (recurStr != nil)
		{
			[recurStr release];
		}
		
	}
	else
	{
		GDataOriginalEvent *originalRE = [event originalEvent];
		
		if (task.parentRepeatInstance >= 0 && originalRE == nil) //exception
		{
			Task *originalTask = [taskmanager getParentRE:task inList:taskmanager.taskList];
			
			if (originalTask != nil && originalTask.gcalEventId != nil && ![originalTask.gcalEventId isEqualToString:@""])
			{
				NSRange range = [originalTask.gcalEventId rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"®"] options:NSBackwardsSearch];
				
				if (range.location != NSNotFound)
				{					
					NSString *eventId = [originalTask.gcalEventId substringToIndex:range.location];
					
					NSString *originID = [eventId lastPathComponent];
					NSString *originHRef = [eventId stringByReplacingOccurrencesOfString:@"events" withString:@"private/full"];
					
					NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
					
					NSDateComponents *orgComps = [gregorian components:0xFF fromDate:originalTask.taskREStartTime];
					
					//NSDateComponents *excComps = [gregorian components:0xFF fromDate:task.taskStartTime];
					NSDateComponents *excComps = [gregorian components:0xFF fromDate:[task getOriginalDateOfExceptionInstance]];
					
					[orgComps setYear:[excComps year]];
					[orgComps setMonth:[excComps month]];
					[orgComps setDay:[excComps day]];
					
					GDataDateTime *orgStartTime = [GDataDateTime dateTimeWithDate:[gregorian dateFromComponents:orgComps] timeZone:[NSTimeZone systemTimeZone]];
					
					//fix DST
					//GDataDateTime *orgEndTime = [GDataDateTime dateTimeWithDate:[[gregorian dateFromComponents:orgComps] addTimeInterval:originalTask.taskHowLong] timeZone:[NSTimeZone systemTimeZone]];
					GDataDateTime *orgEndTime = [GDataDateTime dateTimeWithDate:[ivoUtility dateByAddNumSecond:originalTask.taskHowLong toDate:[gregorian dateFromComponents:orgComps]] timeZone:[NSTimeZone systemTimeZone]];
					
					//printf("Update GCal for exception: %s - with original start: %s, original end: %s\n", [task.taskName UTF8String], [[orgStartTime RFC3339String] UTF8String], [[orgEndTime RFC3339String] UTF8String]);
					
					[gregorian release];

					originalRE = [GDataOriginalEvent originalEventWithID:originID href:originHRef originalStartTime:[GDataWhen whenWithStartTime:orgStartTime endTime:orgEndTime]];
					
					[event setOriginalEvent:originalRE];
				}
			}
		}
			
		GDataWhen *when = nil;

		if ([event times] == nil || [[event times] count] == 0)
		{
			when = [GDataWhen whenWithStartTime:startDateTime endTime:endDateTime];
			[event addTime:when];
		}
		else
		{
			when = [[event times] objectAtIndex:0];	
			
			[when setStartTime:startDateTime];
			[when setEndTime:endDateTime];
		}		
	}
	
	NSArray *alerts = [task creatAlertList];
	
	NSMutableArray *reminders = [NSMutableArray arrayWithCapacity:[alerts count]];
	
	for (Alert *alert in alerts)
	{
		GDataReminder *reminder = [GDataReminder reminder];
		
		switch ([alert alertBy])
		{
			case 0:
			{
				//printf("set REMINDER: 'sms'\n");
				[reminder setMethod:@"sms"];
			}	
				break;
			case 1:
			{
				//printf("set REMINDER: 'alert'\n"); 
				[reminder setMethod:@"alert"];
				break;
			}
			case 2:
			{
				//printf("set REMINDER: 'email'\n");
				[reminder setMethod:@"email"];
			}
				break;
		}
		
		NSInteger amount = [alert amount];
		
		switch ([alert timeUnit])
		{
			case 0:
			{
				//printf("set REMINDER: '%d minutes'\n", amount);
				[reminder setMinutes:[NSString stringWithFormat:@"%d", amount]];
			}	
				break;
			case 1:
			{
				//printf("set REMINDER: '%d hours'\n", amount);
				[reminder setHours:[NSString stringWithFormat:@"%d", amount]];
				break;
			}
			case 2:
			{
				//printf("set REMINDER: '%d days'\n", amount);
				[reminder setDays:[NSString stringWithFormat:@"%d", amount]];
			}
				break;
			case 3:
			{
				//printf("set REMINDER: '%d weeks'\n", amount);
				[reminder setMinutes:[NSString stringWithFormat:@"%d", amount*7*24*60]];			
			}
				break;
		}
		
		
		[reminders addObject:reminder];
	}
	
	for (GDataWhen *when in [event times])
	{
		[when setReminders:reminders];
		
		if (task.isAllDayEvent == 1)
		{
			[[when startTime] setHasTime:NO];
			[[when endTime] setHasTime:NO];
		}

	}
	
	[alerts release];
	
	NSArray *wheres = [event locations];
	
	GDataWhere *where;
	
	if ([wheres count] == 0)
	{
		where = [GDataWhere whereWithString:task.taskLocation];
		[event addLocation:where];
	}
	else
	{
		where = [wheres objectAtIndex:0];
		[where setStringValue:task.taskLocation];
	}
	
	GDataDateTime *dateUpdate = [GDataDateTime dateTimeWithDate:task.taskDateUpdate timeZone:[NSTimeZone systemTimeZone]];
	
	[event setUpdatedDate:dateUpdate];
	
	//printf("updateGCalEvent (%s) - st dateUpdate (%s), gcal dateUpdate (%s)\n", [title UTF8String], [[task.taskDateUpdate description] UTF8String], [[[event updatedDate] RFC3339String] UTF8String]);
	
	if (task.taskContact == nil)
	{
		task.taskContact = @"";
	}
	
	if (task.taskEmailToSend == nil)
	{
		task.taskEmailToSend = @"";
	}
	
	if (task.taskDueEndDate == nil)
	{
		task.taskDueEndDate = [NSDate date];
	}

	if (task.taskDateUpdate == nil)
	{
		task.taskDateUpdate = [NSDate date];
	}
	
	if (task.taskDeadLine == nil)
	{
		task.taskDeadLine = [NSDate date];
	}	
		
	GDataExtendedProperty *dtUpdateProperty = [GDataExtendedProperty propertyWithName:@"ST_DateUpdate" value:[task.taskDateUpdate description]];		
	GDataExtendedProperty *adeProperty = [GDataExtendedProperty propertyWithName:@"ST_ADE" value:[NSString stringWithFormat:@"%d", task.isAllDayEvent]];	
	GDataExtendedProperty *deadlineProperty = [GDataExtendedProperty propertyWithName:@"ST_Deadline" value:[task.taskDeadLine description]];
	GDataExtendedProperty *isUseDeadlineProperty = [GDataExtendedProperty propertyWithName:@"ST_IsUseDeadline" value:[NSString stringWithFormat:@"%d", task.taskIsUseDeadLine]];
	GDataExtendedProperty *contextProperty = [GDataExtendedProperty propertyWithName:@"ST_Context" value:[NSString stringWithFormat:@"%d", task.taskWhere]];
	GDataExtendedProperty *dueEndProperty = [GDataExtendedProperty propertyWithName:@"ST_DueEnd" value:[task.taskDueEndDate description]];
	GDataExtendedProperty *completedProperty = [GDataExtendedProperty propertyWithName:@"ST_Completed" value:[NSString stringWithFormat:@"%d", task.taskCompleted]];
	GDataExtendedProperty *defaultProperty = [GDataExtendedProperty propertyWithName:@"ST_Default" value:[NSString stringWithFormat:@"%d", task.taskDefault]];
	//GDataExtendedProperty *projectProperty = [GDataExtendedProperty propertyWithName:@"ST_Project" value:[NSString stringWithFormat:@"%d", task.taskProject]];
	GDataExtendedProperty *contactProperty = [GDataExtendedProperty propertyWithName:@"ST_Contact" value:task.taskContact];
	//GDataExtendedProperty *emailProperty = [GDataExtendedProperty propertyWithName:@"ST_Email" value:task.taskEmailToSend];
	GDataExtendedProperty *idProperty = [GDataExtendedProperty propertyWithName:@"ST_STID" value:[NSString stringWithFormat:@"%d", task.primaryKey]];

	GDataExtendedProperty *syncKeyProperty = nil;

	if (task.taskSynKey > 0)
	{
		syncKeyProperty = [GDataExtendedProperty propertyWithName:@"ST_SyncKey" value:[NSString stringWithFormat:@"%lf", task.taskSynKey]];			
	}
	
	for (GDataExtendedProperty *prop in [event extendedProperties])
	{
		if ([prop.name isEqualToString:@"ST_STID"])
		{
			prop.value = idProperty.value;
				
			idProperty = nil;
		}
		if ([prop.name isEqualToString:@"ST_DateUpdate"])
		{
			prop.value = dtUpdateProperty.value;
			
			dtUpdateProperty = nil;
		}				
		if ([prop.name isEqualToString:@"ST_ADE"])
		{
			prop.value = adeProperty.value;
			
			adeProperty = nil;
		}		
		if ([prop.name isEqualToString:@"ST_Deadline"])
		{
			prop.value = deadlineProperty.value;
			//printf("Update GCal event deadline (%s) for task (%s)\n", [prop.value UTF8String], [task.taskName UTF8String]);
				
			deadlineProperty = nil;
		}
		if ([prop.name isEqualToString:@"ST_IsUseDeadline"])
		{
			prop.value = isUseDeadlineProperty.value;
				
			isUseDeadlineProperty = nil;
		}
		if ([prop.name isEqualToString:@"ST_Context"])
		{
			prop.value = contextProperty.value;
				
			contextProperty = nil;
		}
		if ([prop.name isEqualToString:@"ST_DueEnd"])
		{
			prop.value = dueEndProperty.value;
				
			dueEndProperty = nil;
		}
		if ([prop.name isEqualToString:@"ST_Completed"])
		{
			prop.value = completedProperty.value;
				
			completedProperty = nil;
		}
		if ([prop.name isEqualToString:@"ST_Default"])
		{
			prop.value = defaultProperty.value;
			
			defaultProperty = nil;
		}
		if ([prop.name isEqualToString:@"ST_Contact"])
		{
			prop.value = contactProperty.value;
				
			contactProperty = nil;
		}
		if ([prop.name isEqualToString:@"ST_SyncKey"])
		{
			syncKeyProperty = nil;//don't update sync key if existing
		}
	}

	if (dtUpdateProperty != nil)
	{
		[event addExtendedProperty:dtUpdateProperty];
	}
	
	if (adeProperty != nil)
	{
		[event addExtendedProperty:adeProperty];
	}
	
	if (deadlineProperty != nil)
	{
		//printf("Add GCal event deadline (%s) for task (%s)\n", [deadlineProperty.value UTF8String], [task.taskName UTF8String]);
		[event addExtendedProperty:deadlineProperty];
	}
	
	if (isUseDeadlineProperty != nil)
	{
		[event addExtendedProperty:isUseDeadlineProperty];
	}
	
	if (contextProperty != nil)
	{
		[event addExtendedProperty:contextProperty];
	}
	
	if (dueEndProperty != nil)
	{
		[event addExtendedProperty:dueEndProperty];
	}
	
	if (completedProperty != nil)
	{
		[event addExtendedProperty:completedProperty];
	}
	
	if (defaultProperty != nil)
	{
		[event addExtendedProperty:defaultProperty];
	}
	if (contactProperty != nil)
	{
		[event addExtendedProperty:contactProperty];
	}
	if (idProperty != nil)
	{
		[event addExtendedProperty:idProperty];		
	}

	if (syncKeyProperty != nil)
	{
		[event addExtendedProperty:syncKeyProperty];	
	}
}

- (void)checkError:(NSError *)error
{
	//printf("error code:%d\n", [error code]);
	
	if (nErr == 0)
	{
		NSString *errMsg = _syncFailureText;
		
		switch ([error code])
		{
			case 403:
				errMsg = NSLocalizedString(@"_error403Text", @"");
				break;
			case -1009:
				errMsg = NSLocalizedString(@"_error_1009Text", @"");
				break;
		}
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_syncErrTitleText", @"") message:errMsg delegate:self cancelButtonTitle:NSLocalizedString(@"_okText", @"") otherButtonTitles:nil];
		[alert show];
		[alert release];	
	}
	
	if (activityView != nil && activityView.superview)
	{
		[activityView stopAnimating];
		[activityView removeFromSuperview];
		activityView = nil;
		_smartViewController.syncBt.hidden=NO;
	}
	
	_smartViewController.navigationController.navigationBar.userInteractionEnabled = YES;
	_smartViewController.view.userInteractionEnabled = YES;	
	
	nErr++;
	nSync--;
	
	if (nSync == 0)
	{
		[self freeObjects];
		
		[taskmanager removeDeleteList];
		[_smartViewController refreshViews];		
	}
}

- (void)errorTicket:(GDataServiceTicket *)ticket failedWithError:(NSError *)error 
{
	//printf("error code:%d\n", [error code]);
	
	if (nErr == 0)
	{
		NSString *errMsg = NSLocalizedString(@"_syncFailureText", @"");
		
		switch ([error code])
		{
			case 403:
				errMsg = NSLocalizedString(@"_error403Text", @"");
				break;
			case -1009:
				errMsg = NSLocalizedString(@"_error_1009Text", @"");
				break;
		}
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_syncErrTitleText", @"") message:errMsg delegate:self cancelButtonTitle:NSLocalizedString(@"_okText", @"") otherButtonTitles:nil];
		[alert show];
		[alert release];	
	}
	
	if (activityView != nil && activityView.superview)
	{
		[activityView stopAnimating];
		[activityView removeFromSuperview];
		activityView = nil;
		_smartViewController.syncBt.hidden=NO;
	}
	
	_smartViewController.navigationController.navigationBar.userInteractionEnabled = YES;
	_smartViewController.view.userInteractionEnabled = YES;	
	
	nErr++;
	nSync--;
	
	if (nSync == 0)
	{
		[self freeObjects];
		
		[taskmanager removeDeleteList];
		[_smartViewController refreshViews];		
	}
}


- (void)errorTicket_old:(GDataServiceTicket *)ticket failedWithError:(NSError *)error 
{
	//printf("error code:%d\n", [error code]);
	
	if (nErr == 0)
	{
		NSString *errMsg = [error localizedDescription];
		switch ([error code])
		{
			case 304:
				errMsg = NSLocalizedString(@"_error304Text", @"");
				break;
			case 400:
				errMsg = NSLocalizedString(@"_error400Text", @"");
				break;
			case 401:
				errMsg = NSLocalizedString(@"_error401Text", @"");
				break;
			case 403:
				errMsg = NSLocalizedString(@"_error403Text", @"");
				break;
			case 404:
				errMsg = NSLocalizedString(@"_error404Text", @"");
				break;
			case 409:
				errMsg = NSLocalizedString(@"_error409Text", @"");
				break;
			case 500:
				errMsg = NSLocalizedString(@"_error500Text", @"");
				break;			
		}
		
		NSString *msg = [NSString stringWithFormat:@"%@: \"%@\". %@.", NSLocalizedString(@"_syncFailureText", @""), errMsg, NSLocalizedString(@"_syncTryLaterText", @"")];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_syncErrTitleText", @"")message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"_okText", @"") otherButtonTitles:nil];
		[alert show];
		[alert release];	
	}
	
	//trung ST3.1
	
	if (activityView != nil && activityView.superview)
	{
		[activityView stopAnimating];
		[activityView removeFromSuperview];
		activityView = nil;
		_smartViewController.syncBt.hidden=NO;
	}
	
	_smartViewController.navigationController.navigationBar.userInteractionEnabled = YES;
	_smartViewController.view.userInteractionEnabled = YES;	

	nErr++;
	nSync--;
	
	if (nSync == 0)
	{
		[self freeObjects];
		
		[taskmanager removeDeleteList];
		[_smartViewController refreshViews];		
	}
}

-(void)resetProjectMapping
{
	//ST3.1 Admod
	if (_liteSyncEnable)
	{
		for (int i=0; i<PROJECT_NUM; i++)
		{
			_gcalName4Events[i] = nil;
			_gcalName4Tasks[i] = nil;
		}
		
		_gcalName4Events[0] = @"Default Events";
		
		noProjectMapping = NO;
		
		return;
	}
	
	int count = [projectList count];
	
	for (int i=0; i<count;i++)
	{
		Projects *project = [projectList objectAtIndex:i];
		
		if ([project.mapToGCalNameForEvent isEqualToString:@""])
		{
			_gcalName4Events[i] = nil;
		}
		else
		{
			_gcalName4Events[i] = project.mapToGCalNameForEvent;
			
			noProjectMapping = NO;
		}
		
		if ([project.mapToGCalNameForTask isEqualToString:@""])
		{
			_gcalName4Tasks[i] = nil;
		}
		else
		{
			_gcalName4Tasks[i] = project.mapToGCalNameForTask;
			
			noProjectMapping = NO;
		}
	}
	
	if (count < PROJECT_NUM)
	{
		for (int i=count; i<PROJECT_NUM; i++)
		{
			_gcalName4Events[i] = nil;
			_gcalName4Tasks[i] = nil;
		}
	}
	
}

- (void) freeObjects
{
	for (int i=0; i<PROJECT_NUM; i++)
	{
		
		if (gCalEvents[i] != nil)
		{
			[gCalEvents[i] release];
			
			gCalEvents[i] = nil;
		}
		
		if (gCalTasks[i] != nil)
		{
			[gCalTasks[i] release];
			
			gCalTasks[i] = nil;
		}
		
		if (gCalTasksDone[i] != nil)
		{
			[gCalTasksDone[i] release];
			
			gCalTasksDone[i] = nil;
		}
		
		if (gCalInvalidEvents[i] != nil)
		{
			[gCalInvalidEvents[i] release];
			
			gCalInvalidEvents[i] = nil;
		}
		
		if (pushEvents[i] != nil)
		{
			[pushEvents[i] release];
			
			pushEvents[i] = nil;
		}
		
		if (pushTasks[i] != nil)
		{
			[pushTasks[i] release];
			
			pushTasks[i] = nil;
		}
	}
	
	if (lastDeleteTime != nil)
	{
		[lastDeleteTime release];
		
		lastDeleteTime = nil;
	}
	
	if (syncErrorMsg != nil)
	{
		[syncErrorMsg release];
		
		syncErrorMsg = nil;
	}
	
	if (gcalCalendars != nil)
	{
		[gcalCalendars release];
		gcalCalendars = nil;
	}
	
	if (stDict != nil)
	{
		[stDict release];
		
		stDict = nil;
	}	
}

- (void)reset
{
	//printf("sync time: %s, last sync time: %s\n", [[self.syncTime description] UTF8String], [[self.lastSyncTime description] UTF8String]);

	nSync = 0;
	nErr = 0;
	
	staticID = 0;
	
	_staticTaskKey = -5000;
	
	for (int i=0; i<PROJECT_NUM; i++)
	{		
		syncEventFlags[i] = NO;
		syncREFlags[i] = NO;
		syncTaskFlags[i] = NO;
		
		loadEventFlags[i] = NO;
		loadTaskFlags[i] = NO;	
		
		STEventCalendars[i] = nil;
		STTaskCalendars[i] = nil;
	}

	pushTaskReady = NO;
	pushEventReady = NO;
	
	syncTaskReady = NO;
	syncEventReady = NO;
	
	reconcileDone = NO;
	
	noProjectMapping = YES;
	
	[self resetProjectMapping];
	
	noEvent2Sync = YES;	
	
	hasSharedCalendar = NO;
}

- (void)addStep
{
	nSync++;
}

- (BOOL) checkTaskOutSyncWindow:(Task *)task syncStartDate:(NSDate *)syncStartDate syncEndDate:(NSDate *)syncEndDate
{
	BOOL ret = NO;
	
	if (task.parentRepeatInstance == -1 && task.taskPinned && task.taskRepeatID == 0 &&
		((syncStartDate != nil && [ivoUtility compareDate:task.taskEndTime withDate:syncStartDate] == NSOrderedAscending) ||
		 (syncEndDate != nil && [ivoUtility compareDate:syncEndDate withDate:task.taskStartTime] == NSOrderedAscending))) //check if Event (not RE) is out of sync window 
	{
		//printf("Event (%s) out of sync window - start time: %s, end time: %s\n", [task.taskName UTF8String], [[task.taskStartTime description] UTF8String], [[task.taskEndTime description] UTF8String]);
		
		ret = YES;
	}
	else if (task.parentRepeatInstance == -1 && task.taskPinned && task.taskRepeatID > 0 &&
		((task.taskNumberInstances > 0 && syncStartDate != nil && [ivoUtility compareDate:task.taskEndRepeatDate withDate:syncStartDate] == NSOrderedAscending) ||
		 (syncEndDate != nil && [ivoUtility compareDate:syncEndDate withDate:task.taskStartTime] == NSOrderedAscending))) //check if RE start is out of sync window 
	{
		//printf("RE (%s) out of sync window - start time: %s, end time: %s\n", [task.taskName UTF8String], [[task.taskStartTime description] UTF8String], [[task.taskEndTime description] UTF8String]);

		ret = YES;
	}
	
	return ret;
}

- (void) removeTaskOutSyncWindow
{
	NSMutableDictionary *projectDict = [NSMutableDictionary dictionaryWithCapacity:5];
	
	for (int i=0; i<PROJECT_NUM; i++)
	{
		if (STEventCalendars[i] != nil)
		{
			[projectDict setObject:@"y" forKey:[NSNumber numberWithInt:i]];
		}
	}
	
	//NSDate *startMin = [[GDataDateTime dateTimeWithRFC3339String:_startMin] date];
	NSDate *startMin = [self getSyncWindowDate:YES];
	//NSDate *startMax = [[GDataDateTime dateTimeWithRFC3339String:_startMax] date];
	NSDate *startMax = [self getSyncWindowDate:NO];
	
	//printf("startMin: %s\n", [[startMin description] UTF8String]);
	//printf("startMax: %s\n", [[startMax description] UTF8String]);
	
	NSMutableArray *stOutOfWindowList = [NSMutableArray arrayWithCapacity:10];
	
	for (Task *task in taskmanager.taskList)
	{
		if ([projectDict objectForKey:[NSNumber numberWithInt:task.taskProject]] != nil &&
			[self checkTaskOutSyncWindow:task syncStartDate:startMin syncEndDate:startMax])
		{
			[stOutOfWindowList addObject:task];
		}
	}
	
	for (Task *task in stOutOfWindowList)
	{
		task.isDeletedFromGCal = YES;
		
		NSInteger delType = -1;
		
		if (task.parentRepeatInstance == -1 && task.taskRepeatID > 0 && task.taskPinned)
		{
			delType = 2;
		}
		else if (task.taskPinned && task.parentRepeatInstance >-1)
		{
			delType = 1;
		}
		
		[taskmanager deleteTask:task.primaryKey isDeleteFromDB:YES deleteREType:delType];

	}
	
}

- (void)checkSuccess
{
	nSync--;
	
	if (nSync == 0 && nErr == 0)
	{
		NSString *msg = NSLocalizedString(@"_unreconcilableErrText", @"");
		
		for (int i=0; i<PROJECT_NUM; i++)
		{
			if (gCalInvalidEvents[i] != nil)
			{
				for (GDataEntryCalendarEvent *event in gCalInvalidEvents[i])
				{
					NSString *name = [[event title] stringValue];
					
					msg = [NSString stringWithFormat:@"%@ '%@',", msg, name]; 
				}
			}
		}
		
		if (!reconcileDone && ![msg isEqualToString:NSLocalizedString(@"_unreconcilableErrText", @"")])
		{			
			syncReconcile= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_syncSuccessTitleText", @"")  message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"_cancelSyncText", @"") otherButtonTitles:nil];
			[syncReconcile addButtonWithTitle:NSLocalizedString(@"_insertToSTText", @"")];
			[syncReconcile addButtonWithTitle:NSLocalizedString(@"_deleteFromGCalText", @"")];
			[syncReconcile show];
			[syncReconcile release];
		}
		else
		{
			NSString *msg = NSLocalizedString(@"_syncSuccessText", @"");
			NSString *title = NSLocalizedString(@"_syncSuccessTitleText", @"");
			
			if (hasSharedCalendar)
			{
				msg = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"_syncSuccessText", @""), NSLocalizedString(@"_note4ReadOnlyGCalText", @"")]; 
			}
			
			if (self.syncErrorMsg != nil)
			{
				msg = self.syncErrorMsg;
				title = NSLocalizedString(@"_syncWarningTitleText", @"");
			}
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"_okText", @"") otherButtonTitles:nil];
			[alert show];
			[alert release];
			
			//[_smartViewController refreshViews];
			
			[self saveLastSyncTime];
			
			//trung ST3.1
			
			if (activityView != nil && activityView.superview)
			{
				[activityView stopAnimating];
				[activityView removeFromSuperview];
				activityView = nil;
				_smartViewController.syncBt.hidden=NO;
			}
			
			_smartViewController.navigationController.navigationBar.userInteractionEnabled = YES;
			_smartViewController.view.userInteractionEnabled = YES;
		}
		
	}
	
	if (nSync == 0)
	{		
		[taskmanager removeDeleteList];	
		
		NSInteger syncType = [taskmanager.currentSetting syncType];

		if (syncType == 0) //2-way sync
		{
			[self removeTaskOutSyncWindow];
		}
		
		[self freeObjects];
		
		[_smartViewController refreshViews];
	}
}

- (void)deleteEventTicket:(GDataServiceTicket *)ticket deletedEntry:(GDataEntryCalendarEvent *)entry error:(NSError *)error
{
	if (error != nil)
	{
		[self checkError:error];
		
		return;
	}
	
	NSMutableString *reportStr = [NSMutableString stringWithFormat:@"http status:%d - DELETED id:%@\n\n", 
								  [ticket statusCode], [entry identifier]];

	//printf("Delete event report: %s\n", [reportStr UTF8String]);	
	
	[self checkSuccess];
}

- (void)batchInsertTicket:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedCalendarEvent *)feed error:(NSError *)error
{
	if (error != nil)
	{
		[self checkError:error];
		
		return;
	}
	//printf("Batch Insert\n");
	
	//NSDate *startMin = [[GDataDateTime dateTimeWithRFC3339String:_startMin] date];
	//NSDate *startMix = [self getSyncWindowDate:YES];
	
	//NSDate *startMax = [[GDataDateTime dateTimeWithRFC3339String:_startMax] date];
	//NSDate *startMax = [self getSyncWindowDate:NO];
	
	NSMutableString *reportStr = [NSMutableString stringWithFormat:@"http status:%d\n\n", 
								  [ticket statusCode]];
	
	NSArray *responseEntries = [feed entries];
	
	NSMutableArray *reExcInsertList = [NSMutableArray arrayWithCapacity:5];	
	
	for (int idx = 0; idx < [responseEntries count]; idx++) 
	{
		
		GDataEntryCalendarEvent *entry = [responseEntries objectAtIndex:idx];
		GDataBatchID *batchID = [entry batchID];
		
		[self updateSyncTime:[[entry updatedDate] date]];
		
		NSString *href = [self getDummyRE:entry];
		
		if (href != nil)
		{
			//printf("dummy event link: %s\n", [href UTF8String]);
			
			[self addStep];
			NSURL *editLink = [NSURL URLWithString:href];
			
			GDataServiceGoogleCalendar *service = [self calendarService];
			
			[service deleteResourceURL: editLink
										  ETag:nil
									  delegate:self
					 didFinishSelector:@selector(deleteEventTicket:deletedEntry:error:)];		
			
		}
		
		// report the batch ID, entry title, and status for each item
		NSString *title= [[entry title] stringValue];
		
		SyncKeyPair keypair = [self getKeyOfEventEntry:entry];
		
		//printf("+++ GCal was inserted for event: %s, in batch: %s, with key: %d, and syncKey: %lf\n", [title UTF8String], [[batchID stringValue] UTF8String], keypair.key, keypair.syncKey);
		
		Task *task = [ivoUtility getTaskBySyncKey:keypair.syncKey inArray:taskmanager.taskList];
		
		if (task != nil)
		{
			//NSString *eventId = [NSString stringWithFormat:@"%@®%@", [entry identifier], [entry ETag]];
			
			//task.gcalEventId = eventId;
			
			//[self changeTask:task withDate:[[entry updatedDate] date] eTag:[entry ETag]];
			
			[self linkTask:task withEvent:entry];
			
			NSInteger year = [ivoUtility getYear:task.taskREStartTime];
			
			if (task.taskRepeatID > 0 && task.parentRepeatInstance == -1 && year != 1970) //Recurring Event -> sync exceptions
			{
				NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
				unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
				
				NSDateComponents *reStartTimeComps = [gregorian components:unitFlags fromDate:task.taskREStartTime];
								
				NSArray *excList = [taskmanager createListExceptionInstancesOfRE:task inList:taskmanager.taskList];		
				
				for (Task *exc in excList)
				{
					NSDate *dt = [exc getOriginalDateOfExceptionInstance];
					
					NSDateComponents *orgTimeComps = [gregorian components:unitFlags fromDate:dt];
					
					[orgTimeComps setHour:[reStartTimeComps hour]];
					[orgTimeComps setMinute:[reStartTimeComps minute]];
					[orgTimeComps setSecond:[reStartTimeComps second]];
					
					dt = [gregorian dateFromComponents:orgTimeComps];
					
					//printf("batchInsertTicket - ST RE (%s) exception original date: (%s), date: (%s)\n", [task.taskName UTF8String], [[dt description] UTF8String], [[exc.taskStartTime description] UTF8String]);					
					
					GDataEntryCalendarEvent *newEvent = [GDataEntryCalendarEvent calendarEvent];
					
					NSString *batchID = [NSString stringWithFormat:@"batchID_%u", ++staticID];
					[newEvent setBatchIDWithString:batchID];
					
					Task *tmp = [ivoUtility getTaskByPrimaryKey:exc.primaryKey inArray:taskmanager.taskList];
					
					if (tmp.taskSynKey == 0)
					{
						tmp.taskSynKey = [[NSDate date] timeIntervalSince1970];
						
						[tmp update];
					}
					
					[self updateGCalEvent:newEvent withTask:tmp];
					
					SyncKeyPair keypair = [self getKeyOfEventEntry:newEvent];
					
					//printf("--- RE EXCEPTION INSERT with batch ID: %s, for event: %s, original date: %s, key: %d, syncKey: %lf\n", [[[newEvent batchID] stringValue] UTF8String], [[[newEvent title] stringValue] UTF8String], [[dt description] UTF8String], keypair.key, keypair.syncKey);
					
					GDataDateTime *startdt = [GDataDateTime dateTimeWithDate:dt timeZone:[NSTimeZone systemTimeZone]];
					
					//fix DST
					//GDataDateTime *enddt = [GDataDateTime dateTimeWithDate:[dt addTimeInterval:exc.taskHowLong] timeZone:[NSTimeZone systemTimeZone]];
					GDataDateTime *enddt = [GDataDateTime dateTimeWithDate:[ivoUtility dateByAddNumSecond:exc.taskHowLong toDate:dt] timeZone:[NSTimeZone systemTimeZone]];
					
					GDataWhen *start = [GDataWhen whenWithStartTime:startdt endTime:enddt];
					
					NSString *originID = [[entry identifier] lastPathComponent];
					NSString *originHRef = [[[entry editLink] URL] absoluteString];
					
					GDataOriginalEvent *originEvent = [GDataOriginalEvent originalEventWithID:originID href:originHRef originalStartTime:start];
					[newEvent setOriginalEvent:originEvent];
					
					[reExcInsertList addObject:newEvent];
				}
				
				[excList release];
				
				NSArray *delList = [ivoUtility deletedExceptionList:task inList:taskmanager.taskList];
				
				for (NSDate *dt in delList)
				{
					GDataEntryCalendarEvent *newEvent = [GDataEntryCalendarEvent calendarEvent];
					
					NSString *batchID = [NSString stringWithFormat:@"batchID_%u", ++staticID];
					[newEvent setBatchIDWithString:batchID];
					
					//printf("--- RE DEL EXCEPTION INSERT ST->GCal with batch ID: %s, for event: %s, on date: %s\n", [[[newEvent batchID] stringValue] UTF8String], [[[newEvent title] stringValue] UTF8String], [[dt description] UTF8String]);
					
					GDataDateTime *startdt = [GDataDateTime dateTimeWithDate:dt timeZone:[NSTimeZone systemTimeZone]];
					
					//fix DST
					//GDataDateTime *enddt = [GDataDateTime dateTimeWithDate:[dt addTimeInterval:task.taskHowLong] timeZone:[NSTimeZone systemTimeZone]];
					GDataDateTime *enddt = [GDataDateTime dateTimeWithDate:[ivoUtility dateByAddNumSecond:task.taskHowLong toDate:dt] timeZone:[NSTimeZone systemTimeZone]];
					
					GDataWhen *start = [GDataWhen whenWithStartTime:startdt endTime:enddt];
					
					NSString *originID = [[entry identifier] lastPathComponent];
					NSString *originHRef = [[[entry editLink] URL] absoluteString];
					
					GDataOriginalEvent *originEvent = [GDataOriginalEvent originalEventWithID:originID href:originHRef originalStartTime:start];
					[newEvent setOriginalEvent:originEvent];
					
					[newEvent setEventStatus:[GDataEventStatus valueWithString:@"http://schemas.google.com/g/2005#event.canceled"]];
					
					[reExcInsertList addObject:newEvent];
					
				}
				
				[delList release];	
				
				[gregorian release];
			}			
		}
		
		[reportStr appendFormat:@"%@: %@\n", [batchID stringValue], title];
		
		GDataBatchInterrupted *interrupted = [entry batchInterrupted];
		if (interrupted) {
			[reportStr appendFormat:@"%@\n", [interrupted description]];
		}
		
		GDataBatchStatus *status = [entry batchStatus];
		if (status) {
			[reportStr appendFormat:@"%d %@\n", [[status code] intValue], [status reason]];
		}
		[reportStr appendString:@"\n"];
		
	}
	
	//printf("Batch insert report: %s\n", [reportStr UTF8String]);
	
	NSString *urlStr = [feed identifier];
	
	urlStr = [urlStr stringByAppendingString:@"/batch"];
	
	NSURL *batchURL = [NSURL URLWithString:urlStr];
	
	if (batchURL != nil && reExcInsertList.count > 0) 
	{
		[self addStep];
		
		GDataFeedCalendarEvent *batchFeed = [GDataFeedCalendarEvent calendarEventFeed];
		
		[batchFeed setEntriesWithEntries:reExcInsertList];
		
		GDataBatchOperation *op = [GDataBatchOperation batchOperationWithType:kGDataBatchOperationInsert];
		[batchFeed setBatchOperation:op];    
		
		GDataServiceGoogleCalendar *service = [self calendarService];
		
		//GData 1.9.1
		[service fetchFeedWithBatchFeed:batchFeed
						forBatchFeedURL:batchURL
							   delegate:self
					  didFinishSelector:@selector(batchInsertTicket:finishedWithFeed:error:)];		
		
	}

	
	[self checkSuccess];
}

-(void)batchPush:(BOOL) is4Tasks: (NSInteger) project: (NSArray *) taskList
{
	GDataEntryCalendar *calendar = (is4Tasks?STTaskCalendars[project]:STEventCalendars[project]);
	
	if (calendar == nil)
	{
		return;
	}
	
	NSURL *postURL = [[calendar alternateLink] URL];
	NSURL *batchURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/batch", [postURL absoluteString]]];
	
	NSMutableArray *insertList = [NSMutableArray arrayWithCapacity:[taskList count]];
	
	NSInteger syncType = [taskmanager.currentSetting syncType];	
	
	//NSDate *startMin = [[GDataDateTime dateTimeWithRFC3339String:_startMin] date];
	NSDate *startMin = [self getSyncWindowDate:YES];
	
	//NSDate *startMax = [[GDataDateTime dateTimeWithRFC3339String:_startMax] date];
	NSDate *startMax = [self getSyncWindowDate:NO];
	
	for (Task* task in taskList)
	{
		if (syncType == 1 && [self checkTaskOutSyncWindow:task syncStartDate:startMin syncEndDate:startMax])
		{
			continue;
		}
		// make a new event
		GDataEntryCalendarEvent *newEvent = [GDataEntryCalendarEvent calendarEvent];
		
		//printf("new Event id: %s\n", [[newEvent identifier] UTF8String]);
		
		NSString *batchID = [NSString stringWithFormat:@"batchID_%u", ++staticID];
		[newEvent setBatchIDWithString:batchID];
		
		if (task.taskSynKey == 0)
		{
			task.taskSynKey = [[NSDate date] timeIntervalSince1970];
			[task update];
		}
		
		[self updateGCalEvent:newEvent withTask:task];
		
		//printf("--- PUSH ST->GCal with batch ID: %s, for event: %s, with key: %d, syncKey: %lf\n", [[[newEvent batchID] stringValue] UTF8String], [[[newEvent title] stringValue] UTF8String], task.primaryKey, task.taskSynKey);
		
		[insertList addObject:newEvent];			
		
	}
	
	if (batchURL != nil && [insertList count] > 0) 
	{
		[self addStep];
		
		GDataFeedCalendarEvent *batchFeed = [GDataFeedCalendarEvent calendarEventFeed];
		
		[batchFeed setEntriesWithEntries:insertList];
		
		GDataBatchOperation *op = [GDataBatchOperation batchOperationWithType:kGDataBatchOperationInsert];
		[batchFeed setBatchOperation:op];    
		
		GDataServiceGoogleCalendar *service = [self calendarService];
		
		//GData 1.9.1
		[service fetchFeedWithBatchFeed:batchFeed
						forBatchFeedURL:batchURL
							   delegate:self
					  didFinishSelector:@selector(batchInsertTicket:finishedWithFeed:error:)];
		
	}
}

- (void)createCalendarTicketAndPush:(GDataServiceTicket *)ticket addedEntry:(GDataEntryCalendar *)object error:(NSError *)error
{
	if (error != nil)
	{
		[self checkError:error];
		
		return;
	}
	
	NSString *calTitle = [[object title] stringValue];
	
	//printf("Calendar (%s) was created\n", [calTitle UTF8String]);
	
	BOOL sync4Tasks = NO;
	
	NSInteger project = -1;
	
	for (int i=0; i<PROJECT_NUM; i++)
	{
		if ([calTitle isEqualToString:_gcalName4Events[i]])
		{
			GDataEntryCalendar *calendar = [[object copy] autorelease];
			
			[gcalCalendars addObject:calendar];
			STTaskCalendars[i] = calendar;			
			
			project = i;
			
			break;
		}
		else if ([calTitle isEqualToString:_gcalName4Tasks[i]])
		{
			
			GDataEntryCalendar *calendar = [[object copy] autorelease];
				
			[gcalCalendars addObject:calendar];
			STTaskCalendars[i] = calendar;
			
			sync4Tasks = YES;
			
			project = i;
			
			break;
		}
	}
	
	if (project != -1)
	{
		//printf("createCalendarTicketAndPush for project: %d\n", project);

		[self push:sync4Tasks :project];
	}
	
	[self checkSuccess];	
}

- (void) createEventCalendarAndPush:(NSInteger) project
{
	//printf("createEventCalendarAndPush for project %d...\n", project);
	
	if (_gcalName4Events[project] != nil)
	{
		NSString *title = _gcalName4Events[project];
		
		NSURL *postURL = [NSURL URLWithString:kGDataGoogleCalendarDefaultOwnCalendarsFeed];
		
		if (postURL != nil) 
		{
			[self addStep];
			
			GDataServiceGoogleCalendar *service = [self calendarService];
			
			GDataEntryCalendar *newEntry = [GDataEntryCalendar calendarEntry];
			
			[newEntry setTitleWithString:title];
			
			[newEntry setIsSelected:YES]; // check the calendar in the web display
			
			[newEntry setColor:[GDataColorProperty valueWithString:_gcalProjectColors[project]]];
			
			[newEntry setTimeZoneName:[GDataTimeZoneProperty valueWithString:[[NSTimeZone systemTimeZone] name]]];
			
			//GData 1.9.1
			[service fetchEntryByInsertingEntry:newEntry
											 forFeedURL:postURL 
											   delegate:self
							  didFinishSelector:@selector(createCalendarTicketAndPush:addedEntry:error:)];
			
		}		
	}	
	
}

- (void) createTaskCalendarAndPush:(NSInteger) project
{
	//printf("createTaskCalendarAndPush for project: %d\n", project);
	
	if (_gcalName4Tasks[project] != nil)
	{
		NSString *title = _gcalName4Tasks[project];
		
		NSURL *postURL = [NSURL URLWithString:kGDataGoogleCalendarDefaultOwnCalendarsFeed];
		
		if (postURL != nil) 
		{
			[self addStep];
			
			GDataServiceGoogleCalendar *service = [self calendarService];
			
			GDataEntryCalendar *newEntry = [GDataEntryCalendar calendarEntry];
			
			[newEntry setTitleWithString:title];
			
			[newEntry setIsSelected:YES]; // check the calendar in the web display
			
			[newEntry setColor:[GDataColorProperty valueWithString:_gcalProjectColors[project]]];
			
			[newEntry setTimeZoneName:[GDataTimeZoneProperty valueWithString:[[NSTimeZone systemTimeZone] name]]];
			
			//GData 1.9.1
			[service fetchEntryByInsertingEntry:newEntry
											 forFeedURL:postURL 
											   delegate:self
							  didFinishSelector:@selector(createCalendarTicketAndPush:addedEntry:error:)];			
			
		}		
	}
}

- (void)batchDeleteTicket:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedCalendarEvent *)feed error:(NSError *)error
{
	if (error != nil)
	{
		[self checkError:error];
		
		return;
	}
	//printf("Delete events\n");
	
	NSMutableString *reportStr = [NSMutableString stringWithFormat:@"http status:%d\n\n", 
								  [ticket statusCode]];
	
	NSArray *responseEntries = [feed entries];
	for (int idx = 0; idx < [responseEntries count]; idx++) {
		
		GDataEntryCalendarEvent *entry = [responseEntries objectAtIndex:idx];
		GDataBatchID *batchID = [entry batchID];
		
		[self updateSyncTime:[[entry updatedDate] date]];
		
		SyncKeyPair keypair = [self getKeyOfEventEntry:entry];
		
		// report the batch ID, entry title, and status for each item
		NSString *title= [[entry title] stringValue];
		[reportStr appendFormat:@"%@: %@\n", [batchID stringValue], title];
		
		GDataBatchInterrupted *interrupted = [entry batchInterrupted];
		if (interrupted) {
			[reportStr appendFormat:@"%@\n", [interrupted description]];
		}
		
		GDataBatchStatus *status = [entry batchStatus];
		if (status) {
			[reportStr appendFormat:@"%d %@\n", [[status code] intValue], [status reason]];
		}
		[reportStr appendString:@"\n"];
		
	}
	
	//printf("Batch delete report: %s\n", [reportStr UTF8String]); 
	
	[self checkSuccess];
}

- (void)batchUpdateTicket:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedCalendarEvent *)feed error:(NSError *)error 
{
	if (error != nil)
	{
		[self checkError:error];
		
		return;
	}
	//printf("Update events\n");

	NSMutableString *reportStr = [NSMutableString stringWithFormat:@"http status:%d\n\n", 
								  [ticket statusCode]];
	
	NSArray *responseEntries = [feed entries];
	for (int idx = 0; idx < [responseEntries count]; idx++) {
		
		GDataEntryCalendarEvent *entry = [responseEntries objectAtIndex:idx];
		GDataDateTime *updateDate = [entry updatedDate];
		
		[self updateSyncTime:[updateDate date]];
		
		GDataBatchID *batchID = [entry batchID];
		
		// report the batch ID, entry title, and status for each item
		NSString *title= [[entry title] stringValue];
		
		SyncKeyPair keypair = [self getKeyOfEventEntry:entry];
		
		//printf("+++ GCal was updated for event: %s, in batch: %s, with key: %d, and syncKey: %lf\n", [title UTF8String], [[batchID stringValue] UTF8String], keypair.key, keypair.syncKey);		
		
		Task *task = [ivoUtility getTaskByEventID:[entry identifier] inArray:taskmanager.taskList];
		
		if (task != nil)
		{
			[self changeTask:task withDate:[updateDate date] eTag:[entry ETag]];		
		}
		
		[reportStr appendFormat:@"%@: %@\n", [batchID stringValue], title];
		
		GDataBatchInterrupted *interrupted = [entry batchInterrupted];
		if (interrupted) {
			[reportStr appendFormat:@"%@\n", [interrupted description]];
		}
		
		GDataBatchStatus *status = [entry batchStatus];
		if (status) {
			[reportStr appendFormat:@"%d %@\n", [[status code] intValue], [status reason]];
		}
		[reportStr appendFormat:@"update date: %@\n", [[updateDate date] description]]; 
		
		[reportStr appendString:@"\n"];

	}
	
	//printf("Batch update report: %s\n", [reportStr UTF8String]); 
	
	[self checkSuccess];
}

-(void) getNewTasks
{
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:10];
	NSMutableArray *keys = [NSMutableArray arrayWithCapacity:10];
	
	for (Task *task in taskmanager.taskList)
	{
		if (!task.taskPinned && task.primaryKey >= 0)
		{
			[taskList addObject:task];
			
			if (task.gcalEventId != nil) // exclude events whose project has been changed in GCal
			{
				NSRange range = [task.gcalEventId rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"®"] options:NSBackwardsSearch];
				
				if (range.location != NSNotFound)
				{
					[keys addObject:[task.gcalEventId substringToIndex:range.location]];
				}
				else
				{
					[keys addObject:[NSString stringWithFormat:@"%d", task.primaryKey]];	
				}
			}
			else
			{
				[keys addObject:[NSString stringWithFormat:@"%d", task.primaryKey]];
			}
		}
	}
	
	NSDictionary *taskDict = [NSDictionary dictionaryWithObjects:taskList forKeys:keys];
	
	[self printTaskDictionary:taskDict];
	
	NSMutableArray *delList = [taskmanager createListDeletedItemFromTaskList];	
	
	NSMutableArray *stInsertList = [NSMutableArray arrayWithCapacity:10];
	
	//download new Tasks
	for (int i=0; i<PROJECT_NUM; i++)
	{
		if (gCalTasks[i] != nil && gCalTasks[i].count > 0)
		{
			for (GDataEntryCalendarEvent *event in gCalTasks[i])
			{
				if (![self checkDoneTask:event])
				{
					Task *stTask = [taskDict objectForKey:[event identifier]];
					
					if (stTask != nil) //found in ST -> update if necessary
					{
						if ([ivoUtility compareDate:stTask.taskDateUpdate withDate:[[event updatedDate] date]] == NSOrderedAscending)
						{
							//printf("UPDATE TASK GCAL->ST for Task (%s) - st updated date: (%s) - gcal updated date: (%s)\n", [stTask.taskName UTF8String], [[stTask.taskDateUpdate description] UTF8String], [[[[event updatedDate] date] description] UTF8String]);
							[self updateTask:stTask withGCalEvent:event];
						}
					}
					else if (![self checkDeleteId:[event identifier] :delList]) //not found in ST
					{
						//printf("Not found in Task List for Event Id: %s\n", [[event identifier] UTF8String]);
						
						Task *task = [[Task alloc] init];
						
						task.taskPinned = NO;
						
						[self updateTask:task withGCalEvent:event];
						
						[self setDummyKey:task :event];
						
						task.taskProject = i;
						
						//printf("--- TO CREATE GCal->ST for task: %s, dummy key: %d\n", [[[event title] stringValue] UTF8String], task.primaryKey);
						
						[stInsertList addObject:task];
						
						[task release];		
					}
					
				}
			}
		}
	}
	
	if ([stInsertList count] > 0)
	{
		[taskmanager addNewGCalSyncTask:stInsertList toArray:taskmanager.taskList isAllowChangeDueWhenAdd:YES]; //batch create in ST
		
		for (Task *task in stInsertList)
		{
			NSInteger primKey = task.primaryKey;
			NSInteger dummyKey = task.originalPKey;
			
			if (primKey == dummyKey) //insert Error
			{
				NSInteger errCode = ERR_TASK_NOT_BE_FIT_BY_RE;
				
				[self reportError:errCode:task.taskName];
			}
		}
	}	
}

-(void) checkToStartSyncTask
{
	BOOL taskSyncReady = YES;
	
	for (int i=0; i<PROJECT_NUM; i++)
	{
		taskSyncReady = taskSyncReady & syncEventFlags[i] & syncREFlags[i] && loadTaskFlags[i];
	}
	
	if (taskSyncReady)
	{
		//printf("start sync task ...\n");
			
		NSInteger syncType = [taskmanager.currentSetting syncType];
		
		if (syncType == 0) //2-way sync
		{
			//sync delete list
			NSMutableArray *delList = [taskmanager createListDeletedItemFromTaskList];
			
			for (DeletedTEKeys *delKey in delList)
			{
				if (delKey.gcalEventId != nil && ![delKey.gcalEventId isEqualToString:@""])
				{			
					NSRange range = [delKey.gcalEventId rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"®"] options:NSBackwardsSearch];
					
					if (range.location != NSNotFound)
					{				
						NSString *eventId = [delKey.gcalEventId substringToIndex:range.location];
						
						NSString *etag = [delKey.gcalEventId substringFromIndex:range.location+1];
						
						//printf("--- DELETE ST->GCal for event id: %s\n", [delKey.gcalEventId UTF8String]);
						
						[self addStep];
						
						NSURL *editLink = [NSURL URLWithString:[eventId stringByReplacingOccurrencesOfString:@"events" withString:@"private/full"]];
						
						GDataServiceGoogleCalendar *service = [self calendarService];
						
						//GData 1.9.1
						[service deleteResourceURL:editLink 
													  ETag:etag
												  delegate:self
								 didFinishSelector:@selector(deleteEventTicket:deletedEntry:error:)];
						
						
					}	
				}
			}
			
			//get new Tasks for 2-way sync
			[self getNewTasks];
		}
			
		for (int i=0; i<PROJECT_NUM; i++)
		{
			[self syncTaskCalendar:i];
		}
	}
}

-(void) checkToStartSyncEvent
{
	BOOL syncReady = YES;
	
	for (int i=0; i<PROJECT_NUM; i++)
	{
		syncReady = syncReady & loadEventFlags[i];
	}
	
	if (syncReady)
	{
		if (stDict != nil)
		{
			[stDict release];
			
			stDict = nil;
		}
		
		for (int i=0; i<PROJECT_NUM; i++)
		{
			[self syncEventCalendar:i];
		}
	}
}

-(void) checkToFinishGetTask
{
	BOOL taskGetCompleted = YES;
	
	for (int i=0; i<PROJECT_NUM; i++)
	{
		taskGetCompleted = taskGetCompleted & syncTaskFlags[i];
	}
	
	if (taskGetCompleted)
	{
		for (int i=0; i<PROJECT_NUM; i++)
		{
			NSMutableArray *events = gCalTasks[i];
			
			if (events == nil || STTaskCalendars[i] == nil)
			{
				continue;
			}
			
			NSString *urlStr = [[STTaskCalendars[i] alternateLink] href];
			
			urlStr = [urlStr stringByAppendingString:@"/batch"];
			
			NSURL *batchURL = [NSURL URLWithString:urlStr];
			
			NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:10];
			
			for (Task *task in taskmanager.taskList)
			{
				if (!task.taskPinned && task.taskProject == i)
				{
					[taskList addObject:task];
				}
			}
			
			NSMutableArray *keys = [NSMutableArray arrayWithCapacity:[taskList count]];
			
			for (Task* task in taskList)
			{
				if (task.gcalEventId != nil) // exclude events whose project has been changed in GCal
				{
					NSRange range = [task.gcalEventId rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"®"] options:NSBackwardsSearch];
					
					if (range.location != NSNotFound)
					{
						[keys addObject:[task.gcalEventId substringToIndex:range.location]];
					}
					else
					{
						[keys addObject:[NSString stringWithFormat:@"%d", task.primaryKey]];	
					}
				}
				else
				{
					[keys addObject:[NSString stringWithFormat:@"%d", task.primaryKey]];
				}
				
			}
			
			NSDictionary *taskDict = [NSDictionary dictionaryWithObjects:taskList forKeys:keys];
			
			for (GDataEntryCalendarEvent *event in events)
			{
				Task *task = [taskDict objectForKey:[event identifier]];
				
				if (task != nil) //update
				{
					NSString *batchID = [NSString stringWithFormat:@"batchID_%u", ++staticID];
					[event setBatchIDWithString:batchID];
					
					//printf("checkToFinishGetTask - update batch ID: %s, for event: %s, id: %s\n", [[[event batchID] stringValue] UTF8String], [[[event title] stringValue] UTF8String], [[event identifier] UTF8String]);			
					
					[self updateGCalEvent:event withTask:task];
				}				
			}
			
			[self addStep];
			
			GDataFeedCalendarEvent *batchFeed = [GDataFeedCalendarEvent calendarEventFeed];
			
			[batchFeed setEntriesWithEntries:events];
			
			GDataBatchOperation *op = [GDataBatchOperation batchOperationWithType:kGDataBatchOperationUpdate];
			[batchFeed setBatchOperation:op];    
			GDataServiceGoogleCalendar *service = [self calendarService];
			
			//GData 1.9.1
			[service fetchFeedWithBatchFeed:batchFeed
							forBatchFeedURL:batchURL
								   delegate:self
						  didFinishSelector:@selector(batchUpdateTicket:finishedWithFeed:error:)];			
			
		}
	}
}

- (void) setDummyKey:(Task *)task:(GDataEntryCalendarEvent *)event
{
	task.primaryKey = _staticTaskKey--;
	
	[self updatePK4GCalEvent:event :task.primaryKey: 0];
}

-(void)batchCreateST:(BOOL)sync4Tasks:(NSMutableArray *)stInsertList:(NSDictionary *)gcalInsertDict:(NSMutableArray *)gcalList
{
	NSDate *timeRec = [NSDate date];
	
	//printf("start batch ST create ...\n");
	
	[taskmanager addNewGCalSyncTask:stInsertList toArray:taskmanager.taskList isAllowChangeDueWhenAdd:YES];
	
	NSTimeInterval diff = [timeRec timeIntervalSinceNow] * (-1);
	
	//printf("end batch ST create, sync time: %lf seconds\n", diff);
	
	for (Task *task in stInsertList)
	{
		NSInteger primKey = task.primaryKey;
		NSInteger dummyKey = task.originalPKey;
		
		//printf("process task (%s), dummy key (%d)\n", [task.taskName UTF8String], dummyKey);
		
		GDataEntryCalendarEvent *event = [gcalInsertDict objectForKey:[NSString stringWithFormat:@"%d", dummyKey]];
		
		if (event != nil)
		{
			if (primKey == dummyKey) //insert Error
			{
				[gcalList removeObject:event];
				
				NSInteger errCode = (sync4Tasks? ERR_TASK_NOT_BE_FIT_BY_RE: ERR_RE_MAKE_TASK_NOT_BE_FIT);
				
				[self reportError:errCode:task.taskName];
				
				//printf("--- FAILED TO INSERT GCal->ST for event: %s, with key: %d\n", [[[event title] stringValue] UTF8String], primKey);
			}
			else
			{
				[self updatePK4GCalEvent:event :primKey: task.taskSynKey];
				
				//printf("--- INSERT GCal->ST for event: %s, with key: %d, and syncKey:%lf\n", [[[event title] stringValue] UTF8String], primKey, task.taskSynKey);
				
				SyncKeyPair keypair = [self getKeyOfEventEntry: event];
				
				//printf("Get Key for event:(%s) - key (%d) - syncKey (%lf)\n",  [[[event title] stringValue] UTF8String], keypair.key, keypair.syncKey);
			}
		}
		else
		{
			//printf("Not found event for dummy key: %d\n", dummyKey);
		}
	}	
}

- (void) get: (BOOL)sync4Tasks: (NSInteger) project
{
	//printf("Get %s for project: %d\n", (sync4Tasks?"Tasks":"Events") ,project);
	
	NSMutableDictionary *reExcDict = [NSMutableDictionary dictionaryWithCapacity:10];
	
	NSMutableArray *stInsertList = [NSMutableArray arrayWithCapacity:10];
	
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:10];
	NSMutableArray *keys = [NSMutableArray arrayWithCapacity:10];
	
	//NSDate *startMin = [[GDataDateTime dateTimeWithRFC3339String:_startMin] date];
	//NSDate *startMax = [[GDataDateTime dateTimeWithRFC3339String:_startMax] date];	
	
	for (Task *task in taskmanager.taskList)
	{
		if (((sync4Tasks && !task.taskPinned) || (!sync4Tasks && task.taskPinned)) && task.taskProject == project && task.primaryKey >= 0)
		{
			[taskList addObject:task];
			
			if (task.gcalEventId != nil) // exclude events whose project has been changed in GCal
			{
				NSRange range = [task.gcalEventId rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"®"] options:NSBackwardsSearch];
				
				if (range.location != NSNotFound)
				{
					[keys addObject:[task.gcalEventId substringToIndex:range.location]];
				}
				else if (task.taskSynKey > 0.0) //v2.3 reconcile
				{
					[keys addObject:[NSString stringWithFormat:@"%lf", task.taskSynKey]];
				}
				else
				{
					[keys addObject:[NSString stringWithFormat:@"%d", task.primaryKey]];	
				}
			}
			else if (task.taskSynKey > 0.0) //v2.3 reconcile
			{
				[keys addObject:[NSString stringWithFormat:@"%lf", task.taskSynKey]];
			}			
			else
			{
				[keys addObject:[NSString stringWithFormat:@"%d", task.primaryKey]];
			}
				
			[self rewindSyncTime:task.taskDateUpdate];
		}
	}

	NSDictionary *taskDict = [NSDictionary dictionaryWithObjects:taskList forKeys:keys];	
	
	int count = 1;
	
	NSMutableArray *events = (sync4Tasks?gCalTasks[project]:gCalEvents[project]);	
	
	for (GDataEntryCalendarEvent *event in events) 
	{
		if (sync4Tasks && [self checkLongEvent:event])
		{
			//printf("LONG TASK\n");
			continue;
		}
		
		if (sync4Tasks && [self checkDoneTask:event])
		{
			//printf("DONE TASK\n");
			continue;
		}
		
		GDataEventStatus *status = [event eventStatus];
		
		NSString *statusString = [status stringValue];
		NSString *title = [[event title] stringValue];		
		
		GDataOriginalEvent *origin = [event originalEvent];		
		
		NSString *eventId = [NSString stringWithFormat:@"%@®%@", [event identifier], [event ETag]];
		
		NSDate *gcalDateUpdate = [[event updatedDate] date];
		
		//printf("#%d. Event (%s) - id (%s) - date updated: (%s)\n", count++, [title UTF8String], [eventId UTF8String], [[gcalDateUpdate description] UTF8String]);
		
		if (![statusString isEqualToString:@"http://schemas.google.com/g/2005#event.canceled"])
		{
			Task *task = [taskDict objectForKey:[event identifier]];
			
			if (task != nil) //existing in SmartTime -> update
			{
				Task *tmp = [[Task alloc] init];
				
				[ivoUtility copyTask:task toTask:tmp isIncludedPrimaryKey:YES];
				
				[self updateTask:tmp withGCalEvent:event];
				
				if (task.taskProject != project) //project has been changed in GCal
				{
					tmp.taskProject = project;
					//printf("--- GET: CHANGE project GCal->ST for event: %s\n", [tmp.taskName UTF8String]);
				}							
				
				//taskCheckResult result = [taskmanager updateTask:tmp isAllowChangeDueWhenUpdate:YES updateREType:2 REUntilDate:tmp.taskStartTime updateTime:gcalDateUpdate];
				TaskActionResult *result = [taskmanager updateTask:tmp isAllowChangeDueWhenUpdate:YES updateREType:2 REUntilDate:tmp.taskStartTime updateTime:gcalDateUpdate];
				
				[self reportError:result.errorNo :tmp.taskName];
				//printf("--- GET: UPDATE GCal->ST for event: %s, ST update date: %s, GCal update date: %s\n", [tmp.taskName UTF8String], [[tmp.taskDateUpdate description] UTF8String], [[gcalDateUpdate description] UTF8String]);
				
				[tmp release];
				
				[taskList removeObject:task];
				[result release];
			}
			else
			{
				NSString *syncKey = [self getSyncKeyOfEventEntry:event];
				
				BOOL v23Found = NO;
				
				if (syncKey != nil) //check v2.3
				{
					Task *task = [taskDict objectForKey:syncKey];

					if (task != nil) //existing in SmartTime (v2.3) -> update
					{
						Task *tmp = [[Task alloc] init];
						
						[ivoUtility copyTask:task toTask:tmp isIncludedPrimaryKey:YES];
						
						[self updateTask:tmp withGCalEvent:event];
						
						if (task.taskProject != project) //project has been changed in GCal
						{
							tmp.taskProject = project;
							//printf("--- GET: CHANGE (v2.3) project GCal->ST for event: %s, syncKey: %s\n", [tmp.taskName UTF8String], [syncKey UTF8String]);
						}							
						
						//taskCheckResult result = [taskmanager updateTask:tmp isAllowChangeDueWhenUpdate:YES updateREType:2 REUntilDate:tmp.taskStartTime updateTime:gcalDateUpdate];
						TaskActionResult *result = [taskmanager updateTask:tmp isAllowChangeDueWhenUpdate:YES updateREType:2 REUntilDate:tmp.taskStartTime updateTime:gcalDateUpdate];
						
						[self reportError:result.errorNo :tmp.taskName];
						//printf("--- GET: UPDATE (v2.3) GCal->ST for event: %s, ST update date: %s, GCal update date: %s, syncKey: %s\n", [tmp.taskName UTF8String], [[tmp.taskDateUpdate description] UTF8String], [[gcalDateUpdate description] UTF8String], [syncKey UTF8String]);
						
						[tmp release];
						
						[taskList removeObject:task];
						[result release];
						
						v23Found = YES;
					}
					
				}
				
				if (!v23Found)
				{
					if (origin != nil) // recurring event exception
					{
						NSMutableArray *arr = [reExcDict objectForKey:[origin originalID]];
						
						if (arr != nil)
						{				
							[arr addObject:event];
						}
						else
						{
							NSMutableArray *series = [NSMutableArray arrayWithCapacity:5];
							[series addObject:event];
							
							[reExcDict setObject:series forKey:[origin originalID]];
						}
						
						continue;
					}
					else
					{
						Task *task = [[Task alloc] init];
						
						task.taskPinned = !sync4Tasks;
						
						[self updateTask:task withGCalEvent:event];
						
						[self setDummyKey:task :event];
						
						task.taskProject = project;
						
						//printf("--- TO CREATE GCal->ST for event: %s, dummy key: %d, in batch ID: %s\n", [[[event title] stringValue] UTF8String], task.primaryKey, [[[event batchID] stringValue] UTF8String]);
						
						[stInsertList addObject:task];
						
						[task release];
					}				
				}				
			}
			
			[self rewindSyncTime:[[event updatedDate] date]];
		}
		
	}
	
	if ([stInsertList count] > 0)
	{
		[taskmanager addNewGCalSyncTask:stInsertList toArray:taskmanager.taskList isAllowChangeDueWhenAdd:YES]; //batch create in ST
		
		for (Task *task in stInsertList)
		{
			NSInteger primKey = task.primaryKey;
			NSInteger dummyKey = task.originalPKey;
			
			if (primKey == dummyKey) //insert Error
			{
				NSInteger errCode = (sync4Tasks? ERR_TASK_NOT_BE_FIT_BY_RE: ERR_RE_MAKE_TASK_NOT_BE_FIT);
				
				[self reportError:errCode:task.taskName];
			}
		}
	}
	
	for (NSArray *reExceptions in [reExcDict objectEnumerator])
	{
		for (GDataEntryCalendarEvent *event in reExceptions) 
		{
			NSString *originalID = [[event originalEvent] originalID];
			NSString *eventId = [event identifier];
			
			NSRange range = [eventId rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/"] options:NSBackwardsSearch];
			
			range.location += 1;
			range.length = eventId.length - range.location;
			
			eventId = [eventId stringByReplacingCharactersInRange:range withString:originalID];
			
			//printf("Original Event Id: %s\n", [eventId UTF8String]);
			
			Task* stOriginalRE = [ivoUtility getTaskByEventID:eventId inArray:taskmanager.taskList];
			
			Task *task = [[Task alloc] init];
			
			if (stOriginalRE != nil)
			{
				task.parentRepeatInstance = stOriginalRE.primaryKey;
			}
			else //orphan new exeception from GCal  
			{
				task.parentRepeatInstance = 999999;
			}
			
			task.taskPinned = !sync4Tasks;
			task.taskProject = project;
			
			[self updateTask:task withGCalEvent:event];
			
			task.parentRepeatInstance = stOriginalRE.primaryKey;
			task.taskRepeatID = 0;
			

			
			NSString *statusString = [ [event eventStatus] stringValue];
			
			NSInteger action = 0;//insert
			
			if ([statusString isEqualToString:@"http://schemas.google.com/g/2005#event.canceled"]) //deleted in GCal
			{
				action = 1; //delete
			}
			
			GDataDateTime *orgStart = [[[event originalEvent] originalStartTime] startTime];
			
			[taskmanager updateExceptionIntoRE:task inList:taskmanager.taskList originalStartDate:[orgStart date] action:action];				
			
			//Task *tmp = [ivoUtility getTaskByPrimaryKey:task.primaryKey inArray:taskmanager.taskList];
			
			//tmp.gcalEventId = [NSString stringWithFormat:@"%@®%@", [event identifier], [event ETag]];
			
			NSString *actionStr = (action == 0?@"CREATE":@"DELETE");
			
			//printf("--- RE EXCEPTION %s GCal->ST for event (%s), on date (%s), with key (%d)\n", [actionStr UTF8String], [[[event title] stringValue] UTF8String], [[task.taskStartTime description] UTF8String], task.primaryKey);
			
			[task release];	
			
			[self rewindSyncTime:[[event updatedDate] date]];
		}
	}
	
	for (Task *task in taskList)
	{
		if (task.gcalEventId != nil && ![task.gcalEventId isEqualToString:@""])
		{
			task.gcalEventId = @""; //reset to insert to GCal for next 2-way sync
			
			[task update];
		}
	}
	
	if (sync4Tasks)
	{
		syncTaskFlags[project] = YES;
		
		[self checkToFinishGetTask];
	}
	else
	{
		if (gCalEvents[project] != nil)
		{
			[gCalEvents[project] release];
			
			gCalEvents[project] = nil;
		}
		
		syncEventFlags[project] = YES;
		syncREFlags[project] = YES;
		
		[self checkToStartSyncTask];
	}
}

-(void) syncDoneTask:(NSInteger) project
{
	if (STTaskCalendars[project] == nil)
	{
		return;
	}
	
	NSMutableArray *doneList = [App_Delegate createFullDoneTaskList];
	
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:5];
	
	for (Task *task in doneList)
	{
		if (task.taskProject == project)
		{
			[taskList addObject:task];
		}
	}
	
	[doneList release];
		
	NSArray *events = gCalTasksDone[project];
	
	NSMutableArray *keys = [NSMutableArray arrayWithCapacity:[events count]];
	NSMutableArray *values = [NSMutableArray arrayWithCapacity:[events count]];

	for (GDataEntryCalendarEvent *event in events)
	{
		SyncKeyPair keypair = [self getKeyOfEventEntry:event];
		
		if (keypair.syncKey != 0)
		{
			[keys addObject:[NSString stringWithFormat:@"%lf", keypair.syncKey]];
			
			[values addObject:@"yes"];
		}
	}
	
	NSDictionary *dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
	
	NSMutableArray *insertList = [NSMutableArray arrayWithCapacity:5];
	
	for (Task *task in taskList)
	{
		NSString *found = [dict objectForKey:[NSString stringWithFormat:@"%lf", task.taskSynKey]];
		
		if (found == nil)
		{
			// make a new event
			GDataEntryCalendarEvent *newEvent = [GDataEntryCalendarEvent calendarEvent];
			
			NSString *batchID = [NSString stringWithFormat:@"batchID_%u", ++staticID];
			[newEvent setBatchIDWithString:batchID];
			
			task.taskSynKey = [[NSDate date] timeIntervalSince1970];
			
			[task update];
			
			[self updateGCalEvent:newEvent withTask:task];
			
			//printf("--- PUSH ST->GCal with batch ID: %s, for event: %s, with key: %d, syncKey: %lf\n", [[[newEvent batchID] stringValue] UTF8String], [[[newEvent title] stringValue] UTF8String], task.primaryKey, task.taskSynKey);
			
			[insertList addObject:newEvent];
			
		}
	}

	NSString *urlStr = [[STTaskCalendars[project] alternateLink] href];
	
	urlStr = [urlStr stringByAppendingString:@"/batch"];
	
	NSURL *batchURL = [NSURL URLWithString:urlStr];	
	
	if (batchURL != nil && [insertList count] > 0) 
	{
		[self addStep];
		
		GDataFeedCalendarEvent *batchFeed = [GDataFeedCalendarEvent calendarEventFeed];
		
		[batchFeed setEntriesWithEntries:insertList];
		
		GDataBatchOperation *op = [GDataBatchOperation batchOperationWithType:kGDataBatchOperationInsert];
		[batchFeed setBatchOperation:op];    
		
		GDataServiceGoogleCalendar *service = [self calendarService];
		
		//GData 1.9.1
		[service fetchFeedWithBatchFeed:batchFeed
						forBatchFeedURL:batchURL
							   delegate:self
					  didFinishSelector:@selector(batchInsertTicket:finishedWithFeed:error:)];
		
	}
}

- (void) push: (BOOL)sync4Tasks :(NSInteger) project
{
	//printf("Push %s for project: %d\n", (sync4Tasks?"Tasks":"Events") ,project);
	
	NSMutableArray *events = (sync4Tasks?gCalTasks[project]: gCalEvents[project]);
	
	GDataEntryCalendar *calendar = (sync4Tasks?STTaskCalendars[project]: STEventCalendars[project]); 
	
	if (calendar == nil)
	{
		return;
	}
	
	NSMutableArray * taskList = [NSMutableArray arrayWithCapacity:10];
	NSMutableArray * keys = [NSMutableArray arrayWithCapacity:10];
	
	//NSDate *startMin = [[GDataDateTime dateTimeWithRFC3339String:_startMin] date];
	//NSDate *startMax = [[GDataDateTime dateTimeWithRFC3339String:_startMax] date];	
	
	for (Task *task in taskmanager.taskList)
	{
		if (((sync4Tasks && !task.taskPinned) || (!sync4Tasks && task.taskPinned)) &&  task.taskProject == project && task.primaryKey >=0)
		{
			[taskList addObject:task];
			
			if (task.gcalEventId != nil) // exclude events whose project has been changed in GCal
			{
				NSRange range = [task.gcalEventId rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"®"] options:NSBackwardsSearch];
				
				if (range.location != NSNotFound)
				{
					[keys addObject:[task.gcalEventId substringToIndex:range.location]];
				}
				else if (task.taskSynKey > 0.0) //v2.3 reconcile
				{
					[keys addObject:[NSString stringWithFormat:@"%lf", task.taskSynKey]];
				}
				else
				{
					[keys addObject:[NSString stringWithFormat:@"%d", task.primaryKey]];	
				}
			}
			else if (task.taskSynKey > 0.0) //v2.3 reconcile
			{
				[keys addObject:[NSString stringWithFormat:@"%lf", task.taskSynKey]];
			}			
			else
			{
				[keys addObject:[NSString stringWithFormat:@"%d", task.primaryKey]];
			}			
			
			[self rewindSyncTime:task.taskDateUpdate];
		}
	}
	
	if (events == nil || [events count] == 0) // no existing events
	{
		if ([taskList count] > 0)
		{
			[self batchPush:sync4Tasks :project: taskList];
		}
	}
	else
	{
		NSString *urlStr = [[calendar alternateLink] href];
		
		urlStr = [urlStr stringByAppendingString:@"/batch"];
		
		NSURL *batchURL = [NSURL URLWithString:urlStr];
		
		NSDictionary *taskDict = [NSDictionary dictionaryWithObjects:taskList forKeys:keys];
		
		//printf("--- PUSH - TASK DICTIONARY: ---\n");
		[self printTaskDictionary:taskDict];
		//printf("-------------------------------\n");
		
		NSMutableArray * gcalUpdateList = [NSMutableArray arrayWithCapacity:10];	
		
		int count = 1;
		
		for (GDataEntryCalendarEvent *event in events) 
		{
			NSString *batchID = [NSString stringWithFormat:@"batchID_%u", ++staticID];
			[event setBatchIDWithString:batchID];
			
			NSString *eventId = [NSString stringWithFormat:@"%@®%@", [event identifier], [event ETag]];
			
			//printf("#%d. Event (%s) - id (%s) - date updated: (%s)\n", count++, [[[event title] stringValue] UTF8String], [eventId UTF8String], [[[[event updatedDate] date] description] UTF8String]);
						
			Task *task = [taskDict objectForKey:[event identifier]];
			
			if (task != nil)
			{
				[gcalUpdateList addObject:event];
				
				[self updateGCalEvent:event withTask:task];
				
				//printf("--- PUSH: UPDATE ST->GCal for event (%s) - batchId (%s)\n", [[[event title] stringValue] UTF8String], [batchID UTF8String]);
				
				[taskList removeObject:task];
			}
			else
			{
				NSString *syncKey = [self getSyncKeyOfEventEntry:event];
				
				if (syncKey != nil) //check v2.3
				{
					Task *task = [taskDict objectForKey:syncKey];
					
					if (task != nil) //existing in SmartTime (v2.3) -> update
					{
						[self linkTask:task withEvent:event];
						
						[gcalUpdateList addObject:event];
						
						[self updateGCalEvent:event withTask:task];
						
						//printf("--- PUSH: UPDATE (v2.3) ST->GCal for event (%s) - batchId (%s), syncKey (%s)\n", [[[event title] stringValue] UTF8String], [batchID UTF8String], [syncKey UTF8String]);
						
						[taskList removeObject:task];						
					}
					else
					{
						//printf("--- PUSH: (v2.3) CANNOT FIND event (%s), syncKey (%s)\n", [[[event title] stringValue] UTF8String], [syncKey UTF8String]);
					}
				}
			}
			
			[self rewindSyncTime:[[event updatedDate] date]];	
		}

		if (batchURL != nil && [gcalUpdateList count] > 0)
		{
			[self addStep];
			
			GDataFeedCalendarEvent *batchFeed = [GDataFeedCalendarEvent calendarEventFeed];
			
			[batchFeed setEntriesWithEntries:gcalUpdateList];
			
			GDataBatchOperation *op = [GDataBatchOperation batchOperationWithType:kGDataBatchOperationUpdate];
			[batchFeed setBatchOperation:op];    
			GDataServiceGoogleCalendar *service = [self calendarService];
			
				//GData 1.9.1
			[service fetchFeedWithBatchFeed:batchFeed
							forBatchFeedURL:batchURL
								   delegate:self
						  didFinishSelector:@selector(batchUpdateTicket:finishedWithFeed:error:)];
			
		}		
		
		if ([taskList count] > 0)
		{
			[self batchPush:sync4Tasks :project: taskList];
		}		
		
	}
	
	if (!sync4Tasks)
	{
		if (gCalEvents[project] != nil)
		{
			[gCalEvents[project] release];
			
			gCalEvents[project] = nil;
		}
		
		syncEventFlags[project] = YES;
		syncREFlags[project] = YES;
		
		[self checkToStartSyncTask];			
	}	
	else
	{
		[self syncDoneTask:project];
	}
	
}

- (void) printRepeatExceptions
{
	for (Task *task in taskmanager.taskList)
	{
		//for debug only
		if (task.parentRepeatInstance == -1 && task.taskPinned && task.taskRepeatID > 0)
		{
			//printf("task %s, repeatExceptions string = %s \n", [task.taskName UTF8String], [task.taskRepeatExceptions UTF8String]); 
		}		
	}
}

- (void) sync: (BOOL)sync4Tasks: (NSInteger) project
{
	NSString *syncType = (sync4Tasks?@"Sync for Task...":@"Sync for Event...");
	
	//printf("%s, project: %d\n", [syncType UTF8String], project);
	
	if (sync4Tasks)
	{
		return;//Task is push-only
	}
	
	NSArray *events = gCalEvents[project];

	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:10];
	NSMutableArray *keys = [NSMutableArray arrayWithCapacity:10];
		
	for (Task *task in taskmanager.taskList)
	{
		if (((sync4Tasks && !task.taskPinned) || (!sync4Tasks && task.taskPinned)) && task.taskProject == project && task.primaryKey >= 0)
		{
			[taskList addObject:task];
			
			if (task.gcalEventId != nil) // exclude events whose project has been changed in GCal
			{
				NSRange range = [task.gcalEventId rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"®"] options:NSBackwardsSearch];
				
				if (range.location != NSNotFound)
				{
					[keys addObject:[task.gcalEventId substringToIndex:range.location]];
				}
				else
				{
					[keys addObject:[NSString stringWithFormat:@"%d", task.primaryKey]];	
				}
			}
			else
			{
				[keys addObject:[NSString stringWithFormat:@"%d", task.primaryKey]];
			}			
		}
						
	}
	
	
	NSDictionary *taskDict = [NSDictionary dictionaryWithObjects:taskList forKeys:keys];
	//[self printTaskDictionary:taskDict];
	
	NSMutableArray *delList = [taskmanager createListDeletedItemFromTaskList];
	NSString *urlStr = [[STEventCalendars[project] alternateLink] href];
	
	urlStr = [urlStr stringByAppendingString:@"/batch"];
	
	NSURL *batchURL = [NSURL URLWithString:urlStr];
	
	NSMutableArray *gcalUpdateList = [NSMutableArray arrayWithCapacity:10];
	
	NSMutableArray *gcalInsertList = [NSMutableArray arrayWithCapacity:10];
	
	NSMutableArray *stInsertList = [NSMutableArray arrayWithCapacity:10];
	
	NSMutableArray *stOutOfWindowList = [NSMutableArray arrayWithCapacity:10];
		
	NSMutableDictionary *reExcDict = [NSMutableDictionary dictionaryWithCapacity:10];
	
	int count = 1;
	
	for (GDataEntryCalendarEvent *event in events) 
	{		
		NSString *statusString = [[event eventStatus] stringValue];
		
		NSString *title = [[event title] stringValue];
		
		if ([statusString isEqualToString:@"http://schemas.google.com/g/2005#event.canceled"] && [title isEqualToString:@"CANCELLED"])
		{
			continue;
		}
				
		if (sync4Tasks && [self checkLongEvent:event])
		{
			//printf("LONG EVENT\n");
			continue;
		}
		
		NSString *batchID = [NSString stringWithFormat:@"batchID_%u", ++staticID];
		[event setBatchIDWithString:batchID];

		GDataOriginalEvent *origin = [event originalEvent];	
		GDataRecurrence *recur = [event recurrence];	
		
		NSString *eventId = [NSString stringWithFormat:@"%@®%@", [event identifier], [event ETag]];
		
		NSDate *gcalDateUpdate = [[event updatedDate] date];
		
		NSString *statusStr = [statusString isEqualToString:@"http://schemas.google.com/g/2005#event.canceled"]?@"CANCELED":@"NOT CANCELLED";

		//printf("#%d. Event (%s) - id (%s) - date updated: (%s) - batchId (%s) - statuc (%s)\n", count++, [title UTF8String], [eventId UTF8String], [[gcalDateUpdate description] UTF8String], [batchID UTF8String], [statusStr UTF8String]);
		
		Task *task = [taskDict objectForKey:[event identifier]];
		
		if (task == nil) //new from Google Calendar
		{
			//if (![statusString isEqualToString:@"http://schemas.google.com/g/2005#event.canceled"])
			//{
				if (origin != nil) // recurring event exception
				{
					NSMutableArray *arr = [reExcDict objectForKey:[origin originalID]];
					
					if (arr != nil)
					{				
						[arr addObject:event];
					}
					else
					{
						NSMutableArray *series = [NSMutableArray arrayWithCapacity:5];
						[series addObject:event];
						
						[reExcDict setObject:series forKey:[origin originalID]];
					}
					
					continue;
				}
				//else if (![self checkDeleteId:[event identifier] :delList])
				else if (![self checkDeleteId:[event identifier] :delList] && ![statusString isEqualToString:@"http://schemas.google.com/g/2005#event.canceled"])
				{
					Task *task = [[Task alloc] init];
					
					task.taskPinned = !sync4Tasks;
					
					[self updateTask:task withGCalEvent:event];
					
					[self setDummyKey:task :event];
					
					task.taskProject = project;
					
					//printf("--- TO CREATE GCal->ST for event: %s, dummy key: %d, in batch ID: %s\n", [[[event title] stringValue] UTF8String], task.primaryKey, [[[event batchID] stringValue] UTF8String]);
					
					[stInsertList addObject:task];
					
					[task release];					
				}
			//}
			//else
			//{
			//	//printf("** CANCELED event not found: %s, id: %s\n", [title UTF8String], [eventId UTF8String]);
			//}
	
		}
		else //old from SmartTime
		{	
			if ([ivoUtility compareDate:task.taskDateUpdate withDate:gcalDateUpdate] == NSOrderedAscending) //GCal change is effective 	
			{				
				if ([statusString isEqualToString:@"http://schemas.google.com/g/2005#event.canceled"]) //delete from GCal
				{
					NSInteger delType = -1;
					
					if (recur != nil) //RE parent
					{
						delType = 2;
					}
					else if (origin != nil)
					{
						delType = 1;
					}

					//printf("--- DELETE GCal->ST for event: %s, primary key: %d, del type: %d\n", [task.taskName UTF8String], task.primaryKey, delType);
					
					task.isDeletedFromGCal = YES;
					
					[taskmanager deleteTask:task.primaryKey isDeleteFromDB:YES deleteREType:delType];
					
					//task.isDeletedFromGCal = NO;					
					
					[self updateSyncTime:gcalDateUpdate];
				}
				else //update from GCal
				{
					Task *tmp = [[Task alloc] init];
					
					[ivoUtility copyTask:task toTask:tmp isIncludedPrimaryKey:YES];
					
					//printf("--- UPDATE GCal->ST for event: %s, ST update date: %s, GCal update date: %s\n", [tmp.taskName UTF8String], [[tmp.taskDateUpdate description] UTF8String], [[gcalDateUpdate description] UTF8String]);

					[self updateTask:tmp withGCalEvent:event];
					
					if (task.taskProject != project) //project has been changed in GCal
					{
						tmp.taskProject = project;
						//printf("--- CHANGE project GCal->ST for event: %s\n", [tmp.taskName UTF8String]);
					}
					
					//taskCheckResult result = [taskmanager updateTask:tmp isAllowChangeDueWhenUpdate:YES updateREType:2 REUntilDate:tmp.taskStartTime updateTime:gcalDateUpdate];
					TaskActionResult *result = [taskmanager updateTask:tmp isAllowChangeDueWhenUpdate:YES updateREType:2 REUntilDate:tmp.taskStartTime updateTime:gcalDateUpdate];

					[self reportError:result.errorNo :tmp.taskName];
					
					[tmp release];
					[result release];
				}
			} 
			else if ([ivoUtility compareDate:gcalDateUpdate withDate:task.taskDateUpdate] == NSOrderedAscending) //ST change is effective
			{
				//printf("--- UPDATE ST->GCal for  FOUND event: %s, ST update date: %s, GCal update date: %s\n", [task.taskName UTF8String], [[task.taskDateUpdate description] UTF8String], [[gcalDateUpdate description] UTF8String]);
				[self updateGCalEvent:event withTask:task];
				
				[gcalUpdateList addObject:event];
			}
			else
			{
				//printf("--- NO CHANGE of event: %s, ST update date: %s, GCal update date: %s\n", [task.taskName UTF8String], [[task.taskDateUpdate description] UTF8String], [[gcalDateUpdate description] UTF8String]);
			}
			
			//sync RE DELETED exception before removing from task list 
			if (task.parentRepeatInstance == -1 && task.taskPinned && task.taskRepeatID > 0)
			{
				NSRange range = [task.gcalEventId rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"®"] options:NSBackwardsSearch];
				
				if (range.location != NSNotFound)
				{
					NSString *eventId = [task.gcalEventId substringToIndex:range.location];
					
					NSArray *delList = [ivoUtility deletedExceptionList:task inList:taskmanager.taskList];
					
					for (NSDate *dt in delList)
					{
						GDataEntryCalendarEvent *newEvent = [GDataEntryCalendarEvent calendarEvent];
						
						NSString *batchID = [NSString stringWithFormat:@"batchID_%u", ++staticID];
						[newEvent setBatchIDWithString:batchID];
						
						//printf("--- INSERT DELETED RE EXCEPTION ST->GCal for FOUND event: %s, on date: %s, with batch ID: %s\n",[task.taskName UTF8String], [[dt description] UTF8String], [[[newEvent batchID] stringValue] UTF8String]);
						
						GDataDateTime *startdt = [GDataDateTime dateTimeWithDate:dt timeZone:[NSTimeZone systemTimeZone]];
						
						//fix DST
						//GDataDateTime *enddt = [GDataDateTime dateTimeWithDate:[dt addTimeInterval:task.taskHowLong] timeZone:[NSTimeZone systemTimeZone]];
						GDataDateTime *enddt = [GDataDateTime dateTimeWithDate:[ivoUtility dateByAddNumSecond:task.taskHowLong toDate:dt] timeZone:[NSTimeZone systemTimeZone]];
						
						GDataWhen *start = [GDataWhen whenWithStartTime:startdt endTime:enddt];
						
						NSString *originID = [eventId lastPathComponent];
						NSString *originHRef = [eventId stringByReplacingOccurrencesOfString:@"events" withString:@"private/full"];
						
						GDataOriginalEvent *originEvent = [GDataOriginalEvent originalEventWithID:originID href:originHRef originalStartTime:start];
						[newEvent setOriginalEvent:originEvent];
						
						[newEvent setEventStatus:[GDataEventStatus valueWithString:@"http://schemas.google.com/g/2005#event.canceled"]];
						
						[gcalInsertList addObject:newEvent];
					}
					
					[delList release];
					
				}				
			}			
			
			[task retain];
			[taskList removeObject:task];
			[task release];			
		}
	}
	
	if ([stInsertList count] > 0)
	{
		[taskmanager addNewGCalSyncTask:stInsertList toArray:taskmanager.taskList isAllowChangeDueWhenAdd:YES]; //batch create in ST
		
		for (Task *task in stInsertList)
		{
			NSInteger primKey = task.primaryKey;
			NSInteger dummyKey = task.originalPKey;
			
			if (primKey == dummyKey) //insert Error
			{
				NSInteger errCode = (sync4Tasks? ERR_TASK_NOT_BE_FIT_BY_RE: ERR_RE_MAKE_TASK_NOT_BE_FIT);
				
				[self reportError:errCode:task.taskName];
			}
		}
	}
	
	for (NSArray *reExceptions in [reExcDict objectEnumerator])
	{
		for (GDataEntryCalendarEvent *event in reExceptions) 
		{
			NSString *originalID = [[event originalEvent] originalID];
			NSString *eventId = [event identifier];
			
			NSRange range = [eventId rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/"] options:NSBackwardsSearch];
			
			range.location += 1;
			range.length = eventId.length - range.location;
			
			eventId = [eventId stringByReplacingCharactersInRange:range withString:originalID];
			
			//printf("Original Event Id: %s\n", [eventId UTF8String]);
			
			Task* stOriginalRE = [ivoUtility getTaskByEventID:eventId inArray:taskmanager.taskList];

			Task *task = [[Task alloc] init];

			if (stOriginalRE != nil)
			{
				task.parentRepeatInstance = stOriginalRE.primaryKey;
			}
			else //orphan new exeception from GCal  
			{
				task.parentRepeatInstance = 999999;
			}
			
			task.taskPinned = !sync4Tasks;
			task.taskProject = project;

			[self updateTask:task withGCalEvent:event];
			
			task.parentRepeatInstance = stOriginalRE.primaryKey;
			task.taskRepeatID = 0;
			
			NSString *statusString = [ [event eventStatus] stringValue];
			
			NSInteger action = 0;//insert
			
			if ([statusString isEqualToString:@"http://schemas.google.com/g/2005#event.canceled"]) //deleted in GCal
			{
				action = 1; //delete
			}
			
			GDataDateTime *orgStart = [[[event originalEvent] originalStartTime] startTime];
			
			[taskmanager updateExceptionIntoRE:task inList:taskmanager.taskList originalStartDate:[orgStart date] action:action];				
			
			//Task *tmp = [ivoUtility getTaskByPrimaryKey:task.primaryKey inArray:taskmanager.taskList];
			
			//tmp.gcalEventId = [event identifier];
			
			NSString *actionStr = (action == 0?@"CREATE":@"DELETE");
			
			//printf("--- RE EXCEPTION %s GCal->ST for event (%s), on date (%s), with key (%d)\n", [actionStr UTF8String], [[[event title] stringValue] UTF8String], [[task.taskStartTime description] UTF8String], task.primaryKey);
			
			[task release];
		}
	}
	
	//filter for newly updated tasks only to update GCal
	for (Task *task in taskList)
	{		
		if (task.gcalEventId == nil || [task.gcalEventId isEqualToString:@""])
		{
			BOOL isNewREExc = NO;
			
			if(task.parentRepeatInstance >= 0)
			{
				Task *originalRE = [taskmanager getParentRE:task inList:taskmanager.taskList];
				
				if (originalRE != nil && originalRE.gcalEventId != nil && ![originalRE.gcalEventId isEqualToString:@""])
				{
					isNewREExc = YES;
				}
			}
			
			if (task.parentRepeatInstance == -1 || isNewREExc)
			{
				GDataEntryCalendarEvent *newEvent = [GDataEntryCalendarEvent calendarEvent];
				
				NSString *batchID = [NSString stringWithFormat:@"batchID_%u", ++staticID];
				[newEvent setBatchIDWithString:batchID];
				
				if (task.taskSynKey == 0)
				{
					task.taskSynKey = [[NSDate date] timeIntervalSince1970];
					
					[task update];
				}			
				
				[self updateGCalEvent:newEvent withTask:task];
				
				[gcalInsertList addObject:newEvent];
				
				if (isNewREExc)
				{
					//printf("--- INSERT RE Exception ST->GCal for event: %s - batchId (%s)\n", [task.taskName UTF8String], [batchID UTF8String]);
				}
				else
				{
					//printf("--- INSERT NEW E/RE ST->GCal for event: %s - batchId (%s)\n", [task.taskName UTF8String], [batchID UTF8String]);					
				}
			}
		}	
		else if ([task.gcalEventId isEqualToString:@"NoMail"]) //when restoring from v.2.2 DB, it contains "NoMail" as content -> insert to GCal
		{
			GDataEntryCalendarEvent *newEvent = [GDataEntryCalendarEvent calendarEvent];
			
			NSString *batchID = [NSString stringWithFormat:@"batchID_%u", ++staticID];
			[newEvent setBatchIDWithString:batchID];
			
			if (task.taskSynKey == 0)
			{
				task.taskSynKey = [[NSDate date] timeIntervalSince1970];
				
				[task update];
			}
			
			[self updateGCalEvent:newEvent withTask:task];
			
			[gcalInsertList addObject:newEvent];
			
			//printf("--- INSERT ST->GCal for event: %s - batchId (%s)\n", [task.taskName UTF8String], [batchID UTF8String]);			
		}
		else if ([ivoUtility compareDate:self.lastSyncTime withDate:task.taskDateUpdate] == NSOrderedAscending)
		{
			NSRange range = [task.gcalEventId rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"®"] options:NSBackwardsSearch];
			
			if (range.location != NSNotFound)
			{
				NSString *eventId = [task.gcalEventId substringToIndex:range.location];
				
				NSString *etag = [task.gcalEventId substringFromIndex:range.location+1];
				
				GDataEntryCalendarEvent *newEvent = [GDataEntryCalendarEvent calendarEvent];
				
				NSString *batchID = [NSString stringWithFormat:@"batchID_%u", ++staticID];
				[newEvent setBatchIDWithString:batchID];
				
				[newEvent setIdentifier:[eventId stringByReplacingOccurrencesOfString:@"events" withString:@"private/full"]];
				
				[newEvent setETag:etag];
				
				[self updateGCalEvent:newEvent withTask:task];
				
				[gcalUpdateList addObject:newEvent];
				
				//printf("--- UPDATE ST->GCal for event: %s - batch Id (%s)\n", [task.taskName UTF8String], [batchID UTF8String]);
				
			}
			else
			{
				//printf("--- NOT UPDATE ST->GCal for event: %s\n", [task.taskName UTF8String]);			
			}
			
		}
		else
		{
			//printf("--- NO ACTION for event: %s, ST update date: %s, last sync time: %s\n", [task.taskName UTF8String], [[task.taskDateUpdate description] UTF8String], [[self.lastSyncTime description] UTF8String]);
		}

		//sync RE DELETED exception
		if (task.parentRepeatInstance == -1 && task.taskPinned && task.taskRepeatID > 0)
		{
			NSRange range = [task.gcalEventId rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"®"] options:NSBackwardsSearch];
			
			if (range.location != NSNotFound)
			{
				NSString *eventId = [task.gcalEventId substringToIndex:range.location];
				
				NSArray *delList = [ivoUtility deletedExceptionList:task inList:taskmanager.taskList];
				
				for (NSDate *dt in delList)
				{
					GDataEntryCalendarEvent *newEvent = [GDataEntryCalendarEvent calendarEvent];
					
					NSString *batchID = [NSString stringWithFormat:@"batchID_%u", ++staticID];
					[newEvent setBatchIDWithString:batchID];
					
					//printf("--- INSERT DELETED RE EXCEPTION ST->GCal for event: %s, on date: %s, with batch ID: %s\n", [[[newEvent title] stringValue] UTF8String], [[dt description] UTF8String], [[[newEvent batchID] stringValue] UTF8String]);
					
					GDataDateTime *startdt = [GDataDateTime dateTimeWithDate:dt timeZone:[NSTimeZone systemTimeZone]];
					
					//fix DST
					//GDataDateTime *enddt = [GDataDateTime dateTimeWithDate:[dt addTimeInterval:task.taskHowLong] timeZone:[NSTimeZone systemTimeZone]];
					GDataDateTime *enddt = [GDataDateTime dateTimeWithDate:[ivoUtility dateByAddNumSecond:task.taskHowLong toDate:dt] timeZone:[NSTimeZone systemTimeZone]];
					
					GDataWhen *start = [GDataWhen whenWithStartTime:startdt endTime:enddt];
					
					NSString *originID = [eventId lastPathComponent];
					NSString *originHRef = [eventId stringByReplacingOccurrencesOfString:@"events" withString:@"private/full"];
					
					GDataOriginalEvent *originEvent = [GDataOriginalEvent originalEventWithID:originID href:originHRef originalStartTime:start];
					[newEvent setOriginalEvent:originEvent];
					
					[newEvent setEventStatus:[GDataEventStatus valueWithString:@"http://schemas.google.com/g/2005#event.canceled"]];
					
					[gcalInsertList addObject:newEvent];
				}
				
				[delList release];
				
			}				
		}
				
	}
	
	if (gcalUpdateList.count > 0)
	{
		[self addStep];
		
		GDataFeedCalendarEvent *batchFeed = [GDataFeedCalendarEvent calendarEventFeed];
		
		[batchFeed setEntriesWithEntries:gcalUpdateList];
		
		GDataBatchOperation *op = [GDataBatchOperation batchOperationWithType:kGDataBatchOperationUpdate];
		[batchFeed setBatchOperation:op];    
		GDataServiceGoogleCalendar *service = [self calendarService];
		
		//GData 1.9.1
		[service fetchFeedWithBatchFeed:batchFeed
										  forBatchFeedURL:batchURL
												 delegate:self
					  didFinishSelector:@selector(batchUpdateTicket:finishedWithFeed:error:)];
		
	}
	
	if (gcalInsertList.count > 0)
	{
		[self addStep];
		
		GDataFeedCalendarEvent *batchFeed = [GDataFeedCalendarEvent calendarEventFeed];
		
		[batchFeed setEntriesWithEntries:gcalInsertList];
		
		GDataBatchOperation *op = [GDataBatchOperation batchOperationWithType:kGDataBatchOperationInsert];
		[batchFeed setBatchOperation:op];    
		
		GDataServiceGoogleCalendar *service = [self calendarService];
		
		//GData 1.9.1
		[service fetchFeedWithBatchFeed:batchFeed
						forBatchFeedURL:batchURL
							   delegate:self
					  didFinishSelector:@selector(batchInsertTicket:finishedWithFeed:error:)];
		
		
	}

	//[gregorian release];
	
	if (!sync4Tasks)
	{
		if (gCalEvents[project] != nil)
		{
			[gCalEvents[project] release];
			
			gCalEvents[project] = nil;
		}
		
		syncEventFlags[project] = YES;	
		syncREFlags[project] = YES;	
		
		[self checkToStartSyncTask];
	}	
}

- (GDataEntryCalendarEvent *)copyGDataEvent:(GDataEntryCalendarEvent *) event
{
	GDataEntryCalendarEvent *entry = [GDataEntryCalendarEvent calendarEvent];
	[entry setLinks:[event links]];
	[entry setIdentifier:[event identifier]];
	[entry setEventStatus:[event eventStatus]];
	[entry setETag:[event ETag]];
	[entry setTitle: [event title]];
	[entry setContent:[event content]];
	[entry setRecurrence:[event recurrence]];
	[entry setOriginalEvent:[event originalEvent]];
	[entry setTimes:[event times]];
	[entry setReminders:[event reminders]];
	[entry setLocations:[event locations]];
	[entry setUpdatedDate:[event updatedDate]];
	[entry setExtendedProperties:[event extendedProperties]];
	
	return entry;
}

- (void)fetchCalendarEventsTicketAndSync:(GDataServiceTicket *)ticket finishedWithEntries:(GDataFeedCalendarEvent *)object error:(NSError *)error
{
	if (error != nil)
	{
		//printf("fetchCalendarEventsTicketAndSync ERROR\n");
		
		[self checkError:error];
		
		return;
	}
	
	//printf("fetchCalendarEventsTicketAndSync NO Error\n");
	
	NSInteger project = -1;
	
	BOOL sync4Tasks = NO;
	
	for (int i=0; i<PROJECT_NUM; i++)
	{
		if (STEventCalendars[i] != nil)
		{
			NSString *calendarHRef = [[STEventCalendars[i] alternateLink] href];
			
			if ([calendarHRef isEqualToString:[object identifier]])
			{
				if (gCalEvents[i] == nil)
				{
					gCalEvents[i] = [[NSMutableArray alloc] initWithCapacity:[[object entries] count]];
				}
				
				for (GDataEntryCalendarEvent *event in [object entries])
				{
					NSString *statusString = [ [event eventStatus] stringValue];
					
					NSString *title = [[event title] stringValue];
					
					if ([statusString isEqualToString:@"http://schemas.google.com/g/2005#event.canceled"] && [title isEqualToString:@"CANCELLED"])
					{
						continue;
					}
					
					[gCalEvents[i] addObject:[self copyGDataEvent:event]];
					//[gCalEvents[i] addObject:[[event copy] autorelease]]; 
					//[gCalEvents[i] addObject:event]; 
					
					Task *task = [stDict objectForKey:[event identifier]];
					
					if (task != nil)
					{
						BOOL needUpdateTask = NO;
						
						if ([ivoUtility compareDate:task.taskDateUpdate withDate:[[event updatedDate] date]] != NSOrderedDescending)
						{
							//Convert Task into Event
							if (task.taskPinned == 0)
							{
								task.taskPinned = 1;
								needUpdateTask = YES;
							}
							
							//Change Project
							if (task.taskProject != i)
							{
								task.taskProject = i;
								needUpdateTask = YES;
							}							
						}
						
						if (needUpdateTask)
						{
							Task *tmp = [[Task alloc] init];
							
							[ivoUtility copyTask:task toTask:tmp isIncludedPrimaryKey:YES];
							
							[self updateTask:tmp withGCalEvent:event];

							NSDate *gcalUpdateDate = [ivoUtility dateByAddNumSecond:1 toDate:[[event updatedDate] date]];
							
							//fix DST
							//taskCheckResult result = [taskmanager updateTask:tmp isAllowChangeDueWhenUpdate:YES updateREType:2 REUntilDate:tmp.taskStartTime updateTime:[gcalUpdateDate addTimeInterval:1]];
							//taskCheckResult result = [taskmanager updateTask:tmp isAllowChangeDueWhenUpdate:YES updateREType:2 REUntilDate:tmp.taskStartTime updateTime:gcalUpdateDate];
							
							TaskActionResult *result = [taskmanager updateTask:tmp isAllowChangeDueWhenUpdate:YES updateREType:2 REUntilDate:tmp.taskStartTime updateTime:gcalUpdateDate];
							
							[self reportError:result.errorNo :tmp.taskName];
							//printf("--- CONVERT/CHANGE PROJECT GCal->ST for event: %s, ST update date: %s, GCal update date: %s\n", [tmp.taskName UTF8String], [[tmp.taskDateUpdate description] UTF8String], [[gcalUpdateDate description] UTF8String]);
							
							Task *t = [ivoUtility getTaskByEventID:[event identifier] inArray:taskmanager.taskList];
							//printf("--- CONVERT/CHANGE PROJECT GCal->ST for event: %s, start time before: %s, start time after: %s\n", [t.taskName UTF8String], [[tmp.taskStartTime description] UTF8String], [[t.taskStartTime description] UTF8String]);  
							
							[tmp release];
							[result release];
						}
						
					}
					else
					{
						NSString *syncKey = [self getSyncKeyOfEventEntry:event];
						
						if (syncKey != nil)
						{
							Task *task = [stDict objectForKey:syncKey];
							
							if (task != nil)
							{
								[self linkTask:task withEvent:event]; //link to GCal again if last sync failed
								
								BOOL needUpdateTask = NO;
								
								//Convert Task into Event
								if (task.taskPinned == 0)
								{
									task.taskPinned = 1;
									needUpdateTask = YES;
								}
								
								//Change Project
								if (task.taskProject != i)
								{
									task.taskProject = i;
									needUpdateTask = YES;
								}
								
								if (needUpdateTask)
								{
									Task *tmp = [[Task alloc] init];
									
									[ivoUtility copyTask:task toTask:tmp isIncludedPrimaryKey:YES];
									
									[self updateTask:tmp withGCalEvent:event];
									
									//NSDate *gcalUpdateDate = [[event updatedDate] date];
									NSDate *gcalUpdateDate = [ivoUtility dateByAddNumSecond:1 toDate:[[event updatedDate] date]];
									
									//fix DST
									//taskCheckResult result = [taskmanager updateTask:tmp isAllowChangeDueWhenUpdate:YES updateREType:2 REUntilDate:tmp.taskStartTime updateTime:[gcalUpdateDate addTimeInterval:1]];
									//taskCheckResult result = [taskmanager updateTask:tmp isAllowChangeDueWhenUpdate:YES updateREType:2 REUntilDate:tmp.taskStartTime updateTime:gcalUpdateDate];
									
									TaskActionResult *result = [taskmanager updateTask:tmp isAllowChangeDueWhenUpdate:YES updateREType:2 REUntilDate:tmp.taskStartTime updateTime:gcalUpdateDate];
									
									[self reportError:result.errorNo :tmp.taskName];
									//printf("--- CONVERT/CHANGE PROJECT GCal->ST for event: %s, ST update date: %s, GCal update date: %s\n", [tmp.taskName UTF8String], [[tmp.taskDateUpdate description] UTF8String], [[gcalUpdateDate description] UTF8String]);
									
									Task *t = [ivoUtility getTaskByEventID:[event identifier] inArray:taskmanager.taskList];
									//printf("--- CONVERT/CHANGE PROJECT GCal->ST for event: %s, start time before: %s, start time after: %s\n", [t.taskName UTF8String], [[tmp.taskStartTime description] UTF8String], [[t.taskStartTime description] UTF8String]);  
									
									[tmp release];
									//[result release];
								}
							}
							
							
						}
					}
				}
				project = i;
				
				//printf("fetchCalendarEventsTicketAndSync - Event project %d\n", project);			
				
				break;		
			}			
		}
		
		if (STTaskCalendars[i] != nil)
		{
			NSString *calendarHRef = [[STTaskCalendars[i] alternateLink] href];
			
			if ([calendarHRef isEqualToString:[object identifier]])
			{
				if (gCalTasks[i] == nil)
				{
					gCalTasks[i] = [[NSMutableArray alloc] initWithCapacity:[[object entries] count]];
				}
				
				if (gCalTasksDone[i] == nil)
				{
					gCalTasksDone[i] = [[NSMutableArray alloc] initWithCapacity:[[object entries] count]];
				}
				
				for (GDataEntryCalendarEvent *event in [object entries])
				{
					if ([event originalEvent] != nil || [event recurrence] != nil) //skip RE
					{
						continue;
					}
					
					NSString *statusString = [ [event eventStatus] stringValue];
					
					NSString *title = [[event title] stringValue];
					
					if ([statusString isEqualToString:@"http://schemas.google.com/g/2005#event.canceled"] && [title isEqualToString:@"CANCELLED"])
					{
						continue;
					}		
					
					if ([self checkDoneTask:event])
					{
						//[gCalTasksDone[i] addObject:[[event copy] autorelease]];
						[gCalTasksDone[i] addObject:[self copyGDataEvent:event]];
					}
					else
					{
						//[gCalTasks[i] addObject:[[event copy] autorelease]];
						[gCalTasks[i] addObject:[self copyGDataEvent:event]];
					}
					
					Task *task = [stDict objectForKey:[event identifier]];
					
					if (task != nil)
					{
						BOOL needUpdateTask = NO;
						
						//Convert Event into Task
						if (task.taskPinned == 1)
						{
							task.taskPinned = 0;
							needUpdateTask = YES;
						}
						
						//Change Project
						if (task.taskProject != i)
						{
							task.taskProject = i;
							needUpdateTask = YES;
						}
						
						if (needUpdateTask)
						{
							Task *tmp = [[Task alloc] init];
							
							[ivoUtility copyTask:task toTask:tmp isIncludedPrimaryKey:YES];
							
							[self updateTask:tmp withGCalEvent:event];
							
							tmp.taskDateUpdate = [NSDate date];							
					
							NSDate *gcalUpdateDate = [[event updatedDate] date];
							
							//taskCheckResult result = [taskmanager updateTask:tmp isAllowChangeDueWhenUpdate:YES updateREType:2 REUntilDate:tmp.taskStartTime updateTime:nil];
							TaskActionResult *result = [taskmanager updateTask:tmp isAllowChangeDueWhenUpdate:YES updateREType:2 REUntilDate:tmp.taskStartTime updateTime:nil];
							
							[self reportError:result.errorNo :tmp.taskName];
							//printf("--- CONVERT/CHANGE PROJECT GCal->ST for event: %s, ST update date: %s, GCal update date: %s\n", [tmp.taskName UTF8String], [[tmp.taskDateUpdate description] UTF8String], [[gcalUpdateDate description] UTF8String]);
							
							Task *t = [ivoUtility getTaskByEventID:[event identifier] inArray:taskmanager.taskList];
							//printf("--- CONVERT/CHANGE PROJECT GCal->ST for event: %s, start time before: %s, start time after: %s\n", [t.taskName UTF8String], [[tmp.taskStartTime description] UTF8String], [[t.taskStartTime description] UTF8String]);  
							
							[tmp release];
							[result release];
						}
						
					}
					
				}
				
				project = i;
				
				//printf("fetchCalendarEventsTicketAndSync - Task project %d\n", project);				
				
				sync4Tasks = YES;
				
				break;				
			}			
		}
		
	}
	
	GDataLink *nextLink = [object nextLink];
	
	if (nextLink != nil)
	{
		NSString *str = [nextLink href];
		
		//str = [str stringByReplacingOccurrencesOfString:@"%3A" withString:@":"];	
		
		//printf("fetchCalendarEventsTicketAndSync URL = %s \n", [str UTF8String]);
		
		NSURL *feedURL = [NSURL URLWithString:str]; 
		
		[self addStep];
		
		GDataServiceGoogleCalendar *service = [self calendarService];
		GDataServiceTicket *ticket;
		
		//GData 1.9.1
		GDataQueryCalendar *query = [GDataQueryCalendar calendarQueryWithFeedURL:feedURL];
		//[query setMaxResults:50];
		
		ticket = [service fetchFeedWithQuery:query
									delegate:self
						   didFinishSelector:@selector(fetchCalendarEventsTicketAndSync:finishedWithEntries:error:)];
		
	}
	else
	{
		if (project != -1)
		{
			if (sync4Tasks)
			{
				loadTaskFlags[project] = YES;
				
				[self checkToStartSyncTask];
			}
			else
			{
				loadEventFlags[project] = YES;
				
				[self checkToStartSyncEvent];
			}
		}
	}	
	
	[self checkSuccess];
}

- (NSDate *) getSyncWindowDate:(BOOL) isPast
{
	NSInteger syncWindowStart = taskmanager.currentSetting.syncWindowStart;
	NSInteger syncWindowEnd = taskmanager.currentSetting.syncWindowEnd;
	
	NSDate *today = [NSDate date];

	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;//|NSWeekdayCalendarUnit|NSWeekdayOrdinalCalendarUnit;

	NSDateComponents *comps = [gregorian components:unitFlags fromDate:today];
	
	if (isPast)
	{
		comps.hour = 0;
		comps.minute = 0;
		comps.second = 0;
	}
	else
	{
		comps.hour = 23;
		comps.minute = 59;
		comps.second = 59;		
	}
	
	NSDateComponents *wdComps =[gregorian components:NSWeekdayCalendarUnit fromDate:today];
	NSInteger wd = [wdComps weekday];
	
	if (isPast)
	{		
		switch (syncWindowStart)
		{
			case 0: //this week
			{
				//fix DST
				//today=[[gregorian dateFromComponents:comps] addTimeInterval:-(wd-1)*24*60*60];
				today=[ivo_Utilities dateByAddNumDay:-(wd-1) toDate:[gregorian dateFromComponents:comps]];
			}
				break;
			case 1: //last week
			{
				//fix DST
				//today=[[gregorian dateFromComponents:comps] addTimeInterval:-(wd-1+7)*24*60*60];
				today=[ivo_Utilities dateByAddNumDay:-(wd-1+7) toDate:[gregorian dateFromComponents:comps]];
			}
				break;
			case 2: //last month
			{
				if (comps.month == 1)
				{
					comps.month = 12;
					comps.year -= 1;
				}
				else
				{
					comps.month -= 1;
				}
				
				comps.day = 1;
				
				today=[gregorian dateFromComponents:comps];
			}
				break;
			case 3: //last 3 months
			{
				if (comps.month <= 3)
				{
					comps.month = (9 + comps.month);
					comps.year -= 1;
				}
				else
				{
					comps.month -= 3;
				}
				
				comps.day = 1;
				
				today=[gregorian dateFromComponents:comps];
			}
				break;
 
			case 4: //last year
			{
				comps.year -= 1;
				comps.month = 1;
				comps.day = 1;
				
				today=[gregorian dateFromComponents:comps];
			}
				break;
			case 5: //all previous
			{
				today=nil;
			}
				break;
				
		}
		
	}
	else
	{
		switch (syncWindowEnd)
		{
			case 0: //this week
			{
				//fix DST
				//today=[[gregorian dateFromComponents:comps] addTimeInterval:(7-wd)*24*60*60];
				today=[ivo_Utilities dateByAddNumDay:(7-wd) toDate:[gregorian dateFromComponents:comps]];
			}
				break;
			case 1: //next week
			{
				//fix DST
				//today=[[gregorian dateFromComponents:comps] addTimeInterval:(2*7-wd)*24*60*60];
				today=[ivo_Utilities dateByAddNumDay:(2*7-wd) toDate:[gregorian dateFromComponents:comps]];
			}
				break;
			case 2: //next month
			{
				if (comps.month >= 11)
				{
					comps.month = (comps.month + 2 - 12);
					comps.year += 1;
				}
				else
				{
					comps.month += 2;
				}
				
				comps.day = 1;
				
				//fix DST
				//today=[[gregorian dateFromComponents:comps] addTimeInterval:-24*60*60];
				today=[ivo_Utilities dateByAddNumDay:-1 toDate:[gregorian dateFromComponents:comps]];
			}
				break;
			case 3: //next 3 months
			{
				if (comps.month >= 10)
				{
					comps.month = (comps.month + 4 - 12);
					comps.year += 1;
				}
				else
				{
					comps.month += 4;
				}
				
				comps.day = 1;
				
				//fix DST
				//today=[[gregorian dateFromComponents:comps] addTimeInterval:-24*60*60];
				today=[ivo_Utilities dateByAddNumDay:-1 toDate:[gregorian dateFromComponents:comps]];
			}
				break;
			case 4: //next year
			{
				comps.year += 2;
				comps.month = 1;
				comps.day = 1;
				
				//fix DST
				//today=[[gregorian dateFromComponents:comps] addTimeInterval:-24*60*60];
				today=[ivo_Utilities dateByAddNumDay:-1 toDate:[gregorian dateFromComponents:comps]];
			}
				break;
			case 5: //all previous
			{
				today=nil;
			}
				break;
				
		}
		
	}
	
	[gregorian release];
	
	return today;
}

-(void) fetchAllEventsAndSync:(GDataEntryCalendar *)calendar
{
	if (calendar != nil) 
	{
		NSDate *syncWindowStart = [self getSyncWindowDate:YES];
		NSDate *syncWindowEnd = [self getSyncWindowDate:NO];
		
		NSString *startMin = @"";
		
		if (syncWindowStart > 0)
		{
			GDataDateTime *gdt = [GDataDateTime dateTimeWithDate:syncWindowStart timeZone:[NSTimeZone systemTimeZone]];
			
			startMin = [NSString stringWithFormat:@"&start-min=%@", [[gdt RFC3339String] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"]];	
		}
		
		NSString *startMax = @"";
		
		if (syncWindowEnd > 0)
		{
			GDataDateTime *gdt = [GDataDateTime dateTimeWithDate:syncWindowEnd timeZone:[NSTimeZone systemTimeZone]];
			
			startMax = [NSString stringWithFormat:@"&start-max=%@", [[gdt RFC3339String] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"]];	
		}
		
		//printf("** Sync Window - start (%s) - end (%s)\n", [startMin UTF8String], [startMax UTF8String]);
		
		NSString *str = [[calendar alternateLink] href];

		NSURL *feedURL = [NSURL URLWithString:str];
			
		feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?showdeleted=true%@%@", str,startMin,startMax]];
		
		//printf("fetch all events URL: \n   %s\n", [[feedURL absoluteString] UTF8String]);
		
		[self addStep];
		
		GDataServiceGoogleCalendar *service = [self calendarService];
		GDataServiceTicket *ticket;
				
		GDataQueryCalendar *query = [GDataQueryCalendar calendarQueryWithFeedURL:feedURL];
		[query setMaxResults:25];
		
		ticket = [service fetchFeedWithQuery:query
											   delegate:self
									  didFinishSelector:@selector(fetchCalendarEventsTicketAndSync:finishedWithEntries:error:)];
		
	}
	
}

-(void) fetchAllTasksAndSync:(GDataEntryCalendar *)calendar
{
	if (calendar != nil) 
	{
		NSString *str = [[calendar alternateLink] href];
		
		NSURL *feedURL = [NSURL URLWithString:str];
		
		[self addStep];
		
		GDataServiceGoogleCalendar *service = [self calendarService];
		GDataServiceTicket *ticket;
		
		//GData 1.9.1
		GDataQueryCalendar *query = [GDataQueryCalendar calendarQueryWithFeedURL:feedURL];
		[query setMaxResults:25];
		
		ticket = [service fetchFeedWithQuery:query
									delegate:self
						   didFinishSelector:@selector(fetchCalendarEventsTicketAndSync:finishedWithEntries:error:)];
	}
	
}

-(void)syncTaskCalendar:(NSInteger)project
{
	GDataEntryCalendar *calendar = STTaskCalendars[project];
	
	if (calendar != nil)
	{
		NSString *accessLevelStr = [[calendar accessLevel] stringValue];
		
		if ([accessLevelStr isEqualToString:@"none"] || [accessLevelStr isEqualToString:@"read"] || [accessLevelStr isEqualToString:@"freebusy"])
		{
			hasSharedCalendar = YES;
		}
		
		NSString *calendarColor = [[calendar color] stringValue];
		
		if (![calendarColor isEqualToString:_gcalProjectColors[project]]) //change GCal color
		{
			
			NSURL *editURL = [[calendar editLink] URL];
			
			GDataServiceGoogleCalendar *service = [self calendarService];
			
			[calendar setColor:[GDataColorProperty valueWithString:_gcalProjectColors[project]]];
			
			//GData 1.9.1
			[service fetchEntryByUpdatingEntry:calendar
									  delegate:self
							 didFinishSelector:@selector(changeColorCalendarTicket:changedEntry:error:)];		
			
		}		
	}	
	
	NSInteger syncType = [taskmanager.currentSetting syncType];
	
	switch (syncType)
	{
		case 1://1-way ST->GCal
			if (calendar != nil)
			{
				[self push:YES :project];				
			}
			else if (_gcalName4Tasks[project] != nil)
			{
				//printf("syncTaskCalendar - calendar for project %d NOT exists\n", project);
				
				[self createTaskCalendarAndPush:project];
			}
			
			break;
		case 0: //2-way sync
		{
			if (calendar != nil)
			{
				[self push:YES :project];
			}
			else if (_gcalName4Tasks[project] != nil)
			{
				//printf("syncTaskCalendar - calendar for project %d NOT exists\n", project);
				
				//[self createTaskCalendarAndPush:project];
				
				NSString *msg = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"_noTaskCalendar2SyncText", @""), _gcalName4Tasks[project]];
				
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_syncSuccessTitleText", @"") message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"_okText", @"") otherButtonTitles:nil];
				[alert show];
				[alert release];
				
				syncTaskFlags[project] = YES;			
			}
			
		}
			break;
		case 2: //1-way GCal->ST
		{
			if (calendar != nil)
			{
				[self get:YES:project];
			}
			else if (_gcalName4Tasks[project] != nil)
			{
				NSString *msg = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"_noTaskCalendar2SyncText", @""), _gcalName4Tasks[project]];
				
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_syncSuccessTitleText", @"") message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"_okText", @"") otherButtonTitles:nil];
				[alert show];
				[alert release];
				
				syncTaskFlags[project] = YES;				
			}
			
		}
			break;
	
	}
}

- (void)changeColorCalendarTicket:(GDataServiceTicket *)ticket changedEntry:(GDataEntryCalendar *)object error:(NSError *)error 
{	
}

- (void)changeColorErrorTicket:(GDataServiceTicket *)ticket failedWithError:(NSError *)error 
{
}

-(void)syncEventCalendar:(NSInteger)project
{
	GDataEntryCalendar *calendar = STEventCalendars[project];
	
	if (calendar != nil)
	{
		//printf("sync Event for project: %d\n", project);
		NSString *accessLevelStr = [[calendar accessLevel] stringValue];

		if ([accessLevelStr isEqualToString:@"none"] || [accessLevelStr isEqualToString:@"read"] || [accessLevelStr isEqualToString:@"freebusy"])
		{
			
			hasSharedCalendar = YES;
		}
		
		NSString *calendarColor = [[calendar color] stringValue];
		
		if (![calendarColor isEqualToString:_gcalProjectColors[project]]) //change GCal color
		{
			
			NSURL *editURL = [[calendar editLink] URL];
			
			GDataServiceGoogleCalendar *service = [self calendarService];
			
			[calendar setColor:[GDataColorProperty valueWithString:_gcalProjectColors[project]]];
			
				//GData 1.9.1
			
			[service fetchEntryByUpdatingEntry:calendar
											  delegate:self
							 didFinishSelector:@selector(changeColorCalendarTicket:changedEntry:error:)];
		}		
	}
	
	NSInteger syncType = [taskmanager.currentSetting syncType];
		
	switch (syncType)
	{
		case 0://2-way
		{
			if (calendar != nil)
			{
				[self sync:NO:project];
			}
			else if (_gcalName4Events[project] != nil)
			{
				//ST3.1 Admod
				//NSString *msg = [NSString stringWithFormat:@"%@: %@", _noEventCalendar2SyncText, _gcalName4Events[project]];
				NSString *msg = _liteSyncEnable?NSLocalizedString(@"_noDefaultCalendar2SyncText", @""):[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"_noEventCalendar2SyncText", @""), _gcalName4Events[project]];
				
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_syncSuccessTitleText", @"") message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"_okText", @"") otherButtonTitles:nil];
				[alert show];
				[alert release];
				
				syncEventFlags[project] = YES;
				syncREFlags[project] = YES;				
			}			
		}
			break;
		case 1://1-way ST->GCal			
		{
			if (calendar != nil)
			{
				[self push:NO :project];
			}
			else if (_gcalName4Events[project] != nil)
			{
				[self createEventCalendarAndPush:project];
			}
			
		}
			break;
		case 2: //1-way GCal->ST
		{
			if (calendar != nil)
			{
				[self get:NO:project];
			}
			else if (_gcalName4Events[project] != nil)
			{
				//ST3.1 Admod
				//NSString *msg = [NSString stringWithFormat:@"%@: %@", _noEventCalendar2SyncText, _gcalName4Events[project]];
				NSString *msg = _liteSyncEnable?NSLocalizedString(@"_noDefaultCalendar2SyncText", @""):[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"_noEventCalendar2SyncText", @""), _gcalName4Events[project]];
				
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_syncSuccessTitleText", @"") message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"_okText", @"") otherButtonTitles:nil];
				[alert show];
				[alert release];

				syncEventFlags[project] = YES;
				syncREFlags[project] = YES;				
			}
			
		}
			break;

	}	
	
}

-(NSDictionary *)prepareSTDictionary
{
	//[ivoUtility printTask:taskmanager.taskList];
	
	NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:10];
	NSMutableArray *keys = [NSMutableArray arrayWithCapacity:10];
	
	for (Task *task in taskmanager.taskList)
	{
		if (task.primaryKey >= 0)
		{
			if (task.gcalEventId != nil && ![task.gcalEventId isEqualToString:@""]) // exclude events whose project has been changed in GCal
			{
				[taskList addObject:task];
				
				NSRange range = [task.gcalEventId rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"®"] options:NSBackwardsSearch];
				
				if (range.location != NSNotFound)
				{
					[keys addObject:[task.gcalEventId substringToIndex:range.location]];
				}
				else if (task.taskSynKey > 0)
				{
					//[keys addObject:[NSString stringWithFormat:@"%d", task.primaryKey]];	
					[keys addObject:[NSString stringWithFormat:@"%lf", task.taskSynKey]];
				}
			}
		}
		
	}

	//stDict = [[NSDictionary dictionaryWithObjects:taskList forKeys:keys] retain];	
	return [[NSDictionary dictionaryWithObjects:taskList forKeys:keys] retain];
}


//-(void)calendarListFetchTicketAndStartSync:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedCalendar *)object
//GData 1.9.1
-(void)calendarListFetchTicketAndStartSync:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedCalendar *)object error:(NSError *)error
{
	if (error != nil)
	{
		[self checkError:error];
		
		return;
	}
	
	if (gcalCalendars == nil)
	{
		gcalCalendars = [[NSMutableArray alloc] initWithCapacity:[[object entries] count]];
	}

	for (GDataEntryCalendar *calendar in [object entries])
	{
		GDataEntryCalendar *entry = [GDataEntryCalendar calendarEntry];
		[entry setTitle:[calendar title]];
		[entry setLinks:[calendar links]];
		[entry setColor:[calendar color]];
		
		[gcalCalendars addObject:entry];
		//[gcalCalendars addObject:[[calendar copy] autorelease]]; 
		//[gcalCalendars addObject:calendar]; 
	}
	
	GDataLink *nextLink = [object nextLink];
	
	if (nextLink != nil)
	{
		NSString *str = [nextLink href];
		
		NSURL *feedURL = [NSURL URLWithString:str]; 
		
		[self addStep];
		
		GDataServiceGoogleCalendar *service = [self calendarService];
		
		GDataServiceTicket *ticket;
		
		//GData 1.9.1
		 ticket = [service fetchFeedWithURL:feedURL
										   delegate:self
								  didFinishSelector:@selector(calendarListFetchTicketAndStartSync:finishedWithFeed:error:)];
		 
	}
	else
	{
		BOOL noEventToLoad = YES;
		
		stDict = [self prepareSTDictionary];
		
		//ST3.1 Admob
		if (_liteSyncEnable)
		{
			if (gcalCalendars.count > 0)
			{
				//STEventCalendars[0] = [[gcalCalendars objectAtIndex:0] retain];
				STEventCalendars[0] = [gcalCalendars objectAtIndex:0];
				
				[self fetchAllEventsAndSync:STEventCalendars[0]];
				
				noEventToLoad = NO;
			}
		}
		else
		{
			for (GDataEntryCalendar *calendar in gcalCalendars)
			{
				NSString *calTitle = [[[calendar title] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; 
				
				if ([calTitle isEqualToString:@""])
				{
					continue;
				}
				
				for (int i=0; i<PROJECT_NUM; i++)
				{
					if ([calTitle isEqualToString:_gcalName4Events[i]])
					{
						STEventCalendars[i] = calendar;
						
						[self fetchAllEventsAndSync:STEventCalendars[i]];
						
						noEventToLoad = NO;
					}
					else if ([calTitle isEqualToString:_gcalName4Tasks[i]])
					{
						
						STTaskCalendars[i] = calendar;
						
						[self fetchAllTasksAndSync:STTaskCalendars[i]];
					}
				}
			}
			
			for (int i=0; i<PROJECT_NUM; i++)
			{
				if (STEventCalendars[i] == nil)
				{
					loadEventFlags[i] = YES; // nothing to load -> ready to sync
				}
				
				if (STTaskCalendars[i] == nil)
				{
					loadTaskFlags[i] = YES; // nothing to load -> ready to sync
				}
			}	
		}
		

		if (noEventToLoad)
		{
			[self checkToStartSyncEvent]; //trigger sync if nothing to load
			
			[self checkToStartSyncTask]; //trigger sync if no event to load
		}
		
		
		[self checkSuccess];
	}		
	
}

-(void) reconcileDelete
{
	
	for (int i=0; i<PROJECT_NUM; i++)
	{
		if (gCalInvalidEvents[i] != nil && STEventCalendars[i] != nil)
		{
			NSString *urlStr = [[STEventCalendars[i] alternateLink] href];
			
			urlStr = [urlStr stringByAppendingString:@"/batch"];
			
			NSURL *batchURL = [NSURL URLWithString:urlStr];
			
			[self addStep];
			
			GDataFeedCalendarEvent *batchFeed = [GDataFeedCalendarEvent calendarEventFeed];
			
			[batchFeed setEntriesWithEntries:gCalInvalidEvents[i]];
			
			GDataBatchOperation *op = [GDataBatchOperation batchOperationWithType:kGDataBatchOperationDelete];
			[batchFeed setBatchOperation:op];    
			
			GDataServiceGoogleCalendar *service = [self calendarService];
			
			//GData 1.9.1
			[service fetchFeedWithBatchFeed:batchFeed
							forBatchFeedURL:batchURL
								   delegate:self
						  didFinishSelector:@selector(batchDeleteTicket:finishedWithFeed:error:)];			
		}
	}	
	
	reconcileDone = YES;
	
}

-(void) reconcileInsert
{
	for (int i=0; i<PROJECT_NUM; i++)
	{
		if (gCalInvalidEvents[i] != nil && STEventCalendars[i] != nil)
		{
			NSMutableArray *stInsertList = [NSMutableArray arrayWithCapacity:gCalInvalidEvents[i].count];
			NSMutableArray *stInsertKeys = [NSMutableArray arrayWithCapacity:gCalInvalidEvents[i].count];
			
			for (GDataEntryCalendarEvent *event in gCalInvalidEvents[i])
			{
				Task *task = [[Task alloc] init];
				
				[self updateTask:task withGCalEvent:event];
				task.taskPinned = YES;
				
				[self setDummyKey:task :event];
				
				//printf("--- TO RECONCILE EVENT INSERT GCal->ST for event: %s, dummy key: %d, in batch ID: %s\n", [[[event title] stringValue] UTF8String], task.primaryKey, [[[event batchID] stringValue] UTF8String]);
				
				[stInsertList addObject:task];
				[stInsertKeys addObject:[NSString stringWithFormat:@"%d", task.primaryKey]];
				
				[task release];
			}
			
			NSDictionary *gcalInsertDict = [NSDictionary dictionaryWithObjects:gCalInvalidEvents[i] forKeys:stInsertKeys];
			
			[self batchCreateST:NO:stInsertList:gcalInsertDict:gCalInvalidEvents[i]];
			
			NSString *urlStr = [[[STEventCalendars[i] alternateLink] URL] absoluteString];
			
			urlStr = [urlStr stringByAppendingString:@"/batch"];
			
			NSURL *batchURL = [NSURL URLWithString:urlStr];
			
			[self addStep];
			
			GDataFeedCalendarEvent *batchFeed = [GDataFeedCalendarEvent calendarEventFeed];
			
			[batchFeed setEntriesWithEntries:gCalInvalidEvents[i]];
			
			GDataBatchOperation *op = [GDataBatchOperation batchOperationWithType:kGDataBatchOperationUpdate];
			[batchFeed setBatchOperation:op];    
			GDataServiceGoogleCalendar *service = [self calendarService];
			
			//GData 1.9.1
			[service fetchFeedWithBatchFeed:batchFeed
							forBatchFeedURL:batchURL
								   delegate:self
						  didFinishSelector:@selector(batchUpdateTicket:finishedWithFeed:error:)];
			
			
		}
	}
		
	reconcileDone = YES;	
}

-(void)startProgress{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	//[self createProgressionAlertWithMessage:@"Loading..." withActivity:YES];
	while (progressAlert== nil) {
		[NSThread sleepForTimeInterval:0.1];
	}
	
	while (activityView==nil) {
		[NSThread sleepForTimeInterval:0.1];
	}
	
	while (![activityView superview]) {
		[NSThread sleepForTimeInterval:0.1];
	}
	[progressAlert show];
	[pool release];
}

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex{
	//ILOG(@"[SmartTimeView alertView\n")
	
	if([alertVw isEqual:syncAlert])
	{
		if(buttonIndex==1)
		{
			[self fetchAllCalendarsAndStartSync];
		}
	}
	else if ([alertVw isEqual:syncReconcile])
	{
		if(buttonIndex==1)
		{
			[self reconcileInsert];
		}
		else if(buttonIndex==2)
		{
			[self reconcileDelete];
		}		
	}
		
}

-(void)checkSync
{
	//printf("last sync time: %s\n", [[self.lastSyncTime description] UTF8String]);

	NSInteger syncType = [taskmanager.currentSetting syncType];
	
	NSString *msg = nil;
	
	switch(syncType)
	{
		case 1: //1-way ST->GCal
		case 2: //1-way GCal->ST
		{
			NSString *msg = (syncType == 1?NSLocalizedString(@"_onewayST_GCalText", @""):NSLocalizedString(@"_onewayGCal_STText", @""));
			syncAlert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_syncSuccessTitleText", @"") message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"_cancelSyncText", @"") otherButtonTitles:nil];
			[syncAlert addButtonWithTitle:NSLocalizedString(@"_okText", @"")];
			[syncAlert show];
			[syncAlert release];
		}
			break;
		case 0: //2-way ST<->GCal
		{
			[self fetchAllCalendarsAndStartSync];
		}
	}
}

- (void)fetchAllCalendarsAndStartSync 
{
	if ((self.mUserName == nil && self.mPassword == nil) || [[self.mUserName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] || [[self.mPassword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""])
	{
		NSString *msg = NSLocalizedString(@"_invalidUserNameNPasswordText", @"");
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_gcalAccountErrTitleText", @"") message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"_okText", @"") otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		return;
	}
	
	//printf("Task List when syncing...\n");
	//[ivoUtility printTask:taskmanager.taskList];

	[self reset];
	
	if (noProjectMapping)
	{
		NSString *msg = NSLocalizedString(@"_noCalendar2SyncText", @"");
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_syncErrTitleText", @"") message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"_okText", @"") otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		return;		
	}
	
	for (int i=0; i<PROJECT_NUM; i++)
	{
		if (_gcalName4Events[i] == nil)
		{
			syncEventFlags[i] = YES;
			syncREFlags[i] = YES;
			loadEventFlags[i] = YES;
		}

		
		if (_gcalName4Tasks[i] == nil)
		{
			syncTaskFlags[i] = YES;
			loadTaskFlags[i] = YES;			
		}
	}
	
	activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	//nang 3.7
	//activityView.frame = CGRectMake(250, 10, 20, 20);
	activityView.frame = CGRectMake(10, 7, 30, 30);
	[activityView startAnimating];
	
	//[_smartViewController.navigationController.navigationBar addSubview:activityView];
	_smartViewController.syncBt.hidden=YES;
	[_smartViewController.toolbar addSubview:activityView];
	[activityView release];
	
	_smartViewController.navigationController.navigationBar.userInteractionEnabled = NO;
	_smartViewController.view.userInteractionEnabled = NO;	
	
	[self addStep];
	
	GDataServiceGoogleCalendar *service = [self calendarService];
	
	NSString *feedURLString = kGDataGoogleCalendarDefaultAllCalendarsFeed;
	
	GDataServiceTicket *ticket;
	
	
	//GData 1.9.1
	ticket = [service fetchFeedWithURL:[NSURL URLWithString:feedURLString]
									  delegate:self
							 didFinishSelector:@selector(calendarListFetchTicketAndStartSync:finishedWithFeed:error:)];
	
}

-(void)calendarListFetchTicketToMap:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedCalendar *)object error:(NSError *)error
{	
	if (error != nil)
	{
		[self checkError:error];
		
		return;
	}
	
	if (gcalCalendars == nil)
	{
		gcalCalendars = [[NSMutableArray alloc] initWithCapacity:[[object entries] count]];
	}
	
	for (GDataEntryCalendar *calendar in [object entries])
	{
		[gcalCalendars addObject:[[calendar copy] autorelease]]; 
	}
	
	GDataLink *nextLink = [object nextLink];
	
	if (nextLink != nil)
	{
		NSString *str = [nextLink href];
		
		NSURL *feedURL = [NSURL URLWithString:str]; 
		
		[self addStep];
		
		GDataServiceGoogleCalendar *service = [self calendarService];
		
		GDataServiceTicket *ticket;
		
		//GData 1.9.1
		ticket = [service fetchFeedWithURL:feedURL
								  delegate:self
						 didFinishSelector:@selector(calendarListFetchTicketToMap:finishedWithFeed:error:)];		
	}
	else
	{		
		if (originalGCalList != nil)
		{
			[originalGCalList release];		
		}
		
		if (originalGCalColorList != nil)
		{
			[originalGCalColorList release];		
		}
		
		if (originalGCalColorDict != nil)
		{
			[originalGCalColorDict release];		
		}
		
		originalGCalList = [[NSMutableArray alloc] initWithCapacity:[gcalCalendars count]];
		
		originalGCalColorList = [[NSMutableArray alloc] initWithCapacity:[gcalCalendars count]];
		
		for (GDataEntryCalendar *calendar in gcalCalendars)
		{
			NSString *calTitle = [[[calendar title] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; 
			
			if (![calTitle isEqualToString:@""])
			{
				[originalGCalList addObject:[[calTitle copy] autorelease]];
			}
			
			NSString *calColor = [[[calendar color] stringValue] stringByReplacingOccurrencesOfString:@"#" withString:@""];
			
			[originalGCalColorList addObject:[ivo_Utilities colorWithHexString:calColor]];
		}
		
		originalGCalColorDict = [[NSDictionary alloc] initWithObjects:originalGCalColorList forKeys:originalGCalList];
		
		mapReady = YES;	
		
		App_Delegate.me.networkActivityIndicatorVisible=NO;

		id ctrler = _smartViewController.navigationController.topViewController;
		
		if (ctrler != nil && [ctrler isKindOfClass:[SyncMappingTableViewController class]])
		{
			[ctrler mapFinished];
		}

	}		
	
}

- (void)fetchErrorTicket:(GDataServiceTicket *)ticket failedWithError:(NSError *)error 
{
	if (originalGCalList != nil)
	{
		[originalGCalList release];
	}
	
	if (originalGCalColorList != nil)
	{
		[originalGCalColorList release];		
	}
	
	if (originalGCalColorDict != nil)
	{
		[originalGCalColorDict release];		
	}	
	
	originalGCalList = [[NSMutableArray alloc] initWithCapacity:1];
	
	[originalGCalList addObject:@""];

	originalGCalColorList = [[NSMutableArray alloc] initWithCapacity:1];
	
	[originalGCalColorList addObject:[UIColor blackColor]];
	
	originalGCalColorDict = [[NSDictionary alloc] initWithObjects:originalGCalColorList forKeys:originalGCalList];	
	
	mapReady = YES;
	
	App_Delegate.me.networkActivityIndicatorVisible=NO;
	
	id ctrler = _smartViewController.navigationController.topViewController;
	
	if (ctrler != nil && [ctrler isKindOfClass:[SyncMappingTableViewController class]])
	{
		[ctrler mapFinished];
	}
}

- (void)fetchAllCalendarsToMap {
	
	if ((self.mUserName == nil && self.mPassword == nil) || [[self.mUserName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] || [[self.mPassword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""])
	{
		if (originalGCalList != nil)
		{
			[originalGCalList release];
		}
		
		if (originalGCalColorList != nil)
		{
			[originalGCalColorList release];		
		}
		
		if (originalGCalColorDict != nil)
		{
			[originalGCalColorDict release];		
		}	
		
		originalGCalList = [[NSMutableArray alloc] initWithCapacity:1];
		
		[originalGCalList addObject:@""];
		
		originalGCalColorList = [[NSMutableArray alloc] initWithCapacity:1];
		
		[originalGCalColorList addObject:[UIColor blackColor]];
		
		originalGCalColorDict = [[NSDictionary alloc] initWithObjects:originalGCalColorList forKeys:originalGCalList];	
		
		mapReady = YES;
		
		id ctrler = _smartViewController.navigationController.topViewController;
		
		if (ctrler != nil && [ctrler isKindOfClass:[SyncMappingTableViewController class]])
		{
			[ctrler mapFinished];
		}
		
	}
	else
	{
		App_Delegate.me.networkActivityIndicatorVisible=YES;
		
		if (gcalCalendars != nil)
		{
			[gcalCalendars release];
			gcalCalendars = nil;
		}
		
		mapReady = NO;
		
		GDataServiceGoogleCalendar *service = [self calendarService];
		
		NSString *feedURLString = kGDataGoogleCalendarDefaultAllCalendarsFeed;
		
		GDataServiceTicket *ticket;
		
		//GData 1.9.1
		ticket = [service fetchFeedWithURL:[NSURL URLWithString:feedURLString]
								  delegate:self
						 didFinishSelector:@selector(calendarListFetchTicketToMap:finishedWithFeed:error:)];
		
	}
}

- (void)authFetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data {	
	App_Delegate.me.networkActivityIndicatorVisible=NO;
	// authentication fetch completed
	NSString* responseString = [[[NSString alloc] initWithData:data
													  encoding:NSUTF8StringEncoding] autorelease];
	//NSDictionary *responseDict = [GDataServiceGoogle dictionaryWithResponseString:responseString];
	//GData1.9.1
	NSDictionary *responseDict = [GDataUtilities dictionaryWithResponseString:responseString];	
	
	NSString *authToken = [responseDict objectForKey:@"Auth"];
	
	if ([authToken length] > 0) 
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_syncSuccessTitleText", @"") message:NSLocalizedString(@"_okAuthText", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"_okText", @"") otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		[self fetchAllCalendarsToMap];
	} 
	else 
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_syncSuccessTitleText", @"") message:NSLocalizedString(@"_koAuthText", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"_okText", @"") otherButtonTitles:nil];
		[alert show];
		[alert release];		
	}	
}

- (void)authFetcher:(GDataHTTPFetcher *)fetcher failedWithStatus:(int)status data:(NSData *)data {
	App_Delegate.me.networkActivityIndicatorVisible=NO;
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_syncSuccessTitleText", @"") message:NSLocalizedString(@"_koAuthText", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"_okText", @"") otherButtonTitles:nil];
	[alert show];
	[alert release];	
}

- (void)authFetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error {
	App_Delegate.me.networkActivityIndicatorVisible=NO;
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_syncSuccessTitleText", @"") message:NSLocalizedString(@"_koAuthText", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"_okText", @"") otherButtonTitles:nil];
	[alert show];
	[alert release];	
}

- (NSString *)stringByURLEncoding:(NSString *)param {
	
	NSString *resultStr = param;
	
	CFStringRef originalString = (CFStringRef) param;
	CFStringRef leaveUnescaped = NULL;
	CFStringRef forceEscaped = CFSTR("!*'();:@&=+$,/?%#[]");
	
	CFStringRef escapedStr;
	escapedStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
														 originalString,
														 leaveUnescaped, 
														 forceEscaped,
														 kCFStringEncodingUTF8);
	
	if (escapedStr) {
		resultStr = [NSString stringWithString:(NSString *)escapedStr];
		CFRelease(escapedStr);
	}
	return resultStr;
}

- (void)authenticate 
{
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	if ([self.mUserName length] > 0 && [self.mPassword length] > 0) {
		
		// do we care about http: protocol logins?
		NSString *domain = @"www.google.com";
		// unit tests will authenticate to a server running locally; 
		// see GDataServiceTest.m
		NSString *scheme = [domain hasPrefix:@"localhost:"] ? @"http" : @"https";
		
		NSString *urlTemplate = @"%@://%@/accounts/ClientLogin";
		NSString *authURLString = [NSString stringWithFormat:urlTemplate, 
								   scheme, domain];
		
		NSURL *authURL = [NSURL URLWithString:authURLString];
		//NSMutableURLRequest *request = [self authenticationRequestForURL:authURL];
		NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:authURL
												cachePolicy:NSURLRequestReloadIgnoringCacheData 
											timeoutInterval:60] autorelease];
		
		
		NSString *password = self.mPassword;
		
		NSString *userAgent = @"LCL-ST-3.0";
		
		NSString *postTemplate = @"Email=%@&Passwd=%@&source=%@&service=%@&accountType=%@";
		NSString *postString = [NSString stringWithFormat:postTemplate, 
								[self stringByURLEncoding:self.mUserName],
								[self stringByURLEncoding:password],
								[self stringByURLEncoding:userAgent],
								@"cl",
								@"HOSTED_OR_GOOGLE"];
	
		GDataHTTPFetcher* fetcher = [GDataHTTPFetcher httpFetcherWithRequest:request];
		
		[fetcher setPostData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
		
		[fetcher beginFetchWithDelegate:self
					  didFinishSelector:@selector(authFetcher:finishedWithData:)
			  didFailWithStatusSelector:@selector(authFetcher:failedWithStatus:data:)
			   didFailWithErrorSelector:@selector(authFetcher:failedWithError:)];
	}
}

+(id)getInstance:(NSString *)userName :(NSString *)password: (NSDate *)lastSyncTime
{
	if (_gcalSyncSingleton == nil)
	{
		_gcalSyncSingleton = [[GCalSync alloc] init:userName :password :lastSyncTime];
	}
	else
	{
		[_gcalSyncSingleton reset];
		[_gcalSyncSingleton init:userName :password :lastSyncTime];
	}
	
	return _gcalSyncSingleton;
}

-(void) dealloc
{
	if (mUserName != nil)
	{
		[mUserName release];
	}
	
	if (mPassword != nil)
	{
		[mPassword release];
	}

	for (int i=0; i<PROJECT_NUM; i++)
	{
		
		if (gCalEvents[i] != nil)
		{
			[gCalEvents[i] release];
			
			gCalEvents[i] = nil;
		}
		
		if (gCalTasks[i] != nil)
		{
			[gCalTasks[i] release];
			
			gCalTasks[i] = nil;
		}
		
		if (gCalTasksDone[i] != nil)
		{
			[gCalTasksDone[i] release];
			
			gCalTasksDone[i] = nil;
		}		

		if (gCalInvalidEvents[i] != nil)
		{
			[gCalInvalidEvents[i] release];
			
			gCalInvalidEvents[i] = nil;
		}
		
	}
	
	if (syncTime != nil)
	{
		[syncTime release];
	}

	if (lastSyncTime != nil)
	{
		[lastSyncTime release];
	}
	
	if (lastDeleteTime != nil)
	{
		[lastDeleteTime release];
	}
	
	if (syncErrorMsg != nil)
	{
		[syncErrorMsg release];
	}
	
	if (gcalCalendars != nil)
	{
		[gcalCalendars release];
		gcalCalendars = nil;
	}
	
	if (stDict != nil)
	{
		[stDict release];
		stDict = nil;
	}
	
	[super dealloc];
}
*/

@end
