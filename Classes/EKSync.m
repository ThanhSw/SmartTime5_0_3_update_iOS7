//
//  EKSync.m
//  SmartOrganizer
//
//  Created by Nang Le Van on 10/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EKSync.h"
#import "IvoCommon.h"
#import "ivo_Utilities.h"
#import "TaskManager.h"
#import "Task.h"
#import "AlertObject.h"
#import "Setting.h"
#import "Projects.h"
#import "SmartViewController.h"
#import "EKOneWaySyncObject.h"
#import "SmartTimeAppDelegate.h"

extern SmartTimeAppDelegate *App_Delegate;
extern NSMutableArray *projectList;
extern NSInteger totalSync;

extern TaskManager *taskmanager;
extern sqlite3	*database;
extern NSString *iCalSyncText;	
//extern NSString *okText;
extern NSString *newEventText;
extern ivo_Utilities *ivoUtility;
extern NSTimeInterval	dstOffset;;
extern BOOL			isSyncing;

extern NSString *syncingText;

@implementation EKSync
@synthesize iCalCalendarsList;
@synthesize rootViewController;

-(id)init{
    self=[super init];
	if (self) {
        
        [self.eventsStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted,NSError *error){
            
        }];
        
		
		iCalCalendarsList=[[NSMutableArray alloc] init];
	}
	
	return self;
}

-(EKEventStore*)eventsStore{
    static EKEventStore *store=nil;
    if (!store) {
        store=[[EKEventStore alloc] init];
    }
    
    return store;
}

-(void)storeChanged:(id)sender{
	
}

-(void)dealloc{
	[iCalCalendarsList release];
	[super dealloc];
}


#pragma mark Get Information from iCal

-(NSMutableArray *)getICalCalendars{
	return [NSMutableArray arrayWithArray:[self.eventsStore calendarsForEntityType:EKEntityTypeEvent]];
}

//return a list of Projects's names from iPad Projects 
-(NSMutableArray *)getICalCalendarsName{
	NSMutableArray *ret=[NSMutableArray array];
	
	
	
	return ret;
}

//This will get a all events which are matched the window
-(NSArray *)getICalEventsWithCalendars:(NSArray *)calendars{
	// Create the predicate's start and end dates.
	
	CFGregorianDate gregorianStartDate, gregorianEndDate;
	NSInteger startUnit=[self getSyncWindowUnit:YES];
	NSInteger endUnit=[self getSyncWindowUnit:NO];
	NSDate* startDate;
	NSDate* endDate;
	
	if (startUnit>0 && endUnit>0) {
		CFGregorianUnits startUnits = {0, 0, -startUnit+1, 0, 0, 0};
		
		CFGregorianUnits endUnits = {0, 0, endUnit, 0, 0, 0};
		CFTimeZoneRef timeZone = CFTimeZoneCopySystem();
		
		gregorianStartDate = CFAbsoluteTimeGetGregorianDate(
															
															CFAbsoluteTimeAddGregorianUnits(CFAbsoluteTimeGetCurrent(), timeZone, startUnits),
															
															timeZone);
		
		gregorianStartDate.hour = 0;
		
		gregorianStartDate.minute = 0;
		
		gregorianStartDate.second = 0;
		
		
		gregorianEndDate = CFAbsoluteTimeGetGregorianDate(
														  
														  CFAbsoluteTimeAddGregorianUnits(CFAbsoluteTimeGetCurrent(), timeZone, endUnits),
														  
														  timeZone);
		
		gregorianEndDate.hour = 0;
		
		gregorianEndDate.minute = 0;
		
		gregorianEndDate.second = 0;
		
		startDate =[NSDate dateWithTimeIntervalSinceReferenceDate:CFGregorianDateGetAbsoluteTime(gregorianStartDate, timeZone)];
		endDate =[NSDate dateWithTimeIntervalSinceReferenceDate:CFGregorianDateGetAbsoluteTime(gregorianEndDate, timeZone)];
		CFRelease(timeZone);
		
	}else {
		startDate=nil;
		endDate=nil;
	}
	
	// Create the predicate.
	NSPredicate *predicate = [self.eventsStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:calendars]; // eventStore is an instance variable.
	
	// Fetch all events that match the predicate.
	NSArray *events = [self.eventsStore eventsMatchingPredicate:predicate];
	//[eventStore release];
	
	return events;
}

#pragma mark Create

-(BOOL)createNewEventToICal:(Task*)event updateREType:(NSInteger)updateREType eventStore:(EKEventStore*)eventStore{
    
    [event retain];
    EKEvent *newEvent  = [EKEvent eventWithEventStore:self.eventsStore];
    if (event.taskPinned==0) {
        if (event.taskCompleted==1) {
            newEvent.title     = [NSString stringWithFormat:@"✔ %@", event.taskName];
        }else{
            newEvent.title     = [NSString stringWithFormat:@"☐ %@", event.taskName];
        }
    }else{
        newEvent.title     = event.taskName;
    } 
    
	newEvent.notes	=event.taskDescription;
	newEvent.allDay=event.isAllDayEvent;
	
	Projects *calendar=[App_Delegate calendarWithPrimaryKey:event.taskProject];
	
    NSMutableArray *icalCals=[NSMutableArray arrayWithArray:[self getICalCalendars]];
    
	for (EKCalendar *cal in icalCals) {
		if ([cal.calendarIdentifier isEqualToString:calendar.iCalIdentifier]) {
			newEvent.calendar=cal;
			goto next;
		}
	}

	//add to default calendar if has no any calendar matched;
	[newEvent setCalendar:[self.eventsStore defaultCalendarForNewEvents]];

next:
	
	newEvent.location=event.taskLocation;
	
    newEvent.startDate = event.taskStartTime;
    newEvent.endDate   = event.taskEndTime;
	
	if (event.isAllDayEvent) {
		newEvent.endDate=[ivoUtility newDateFromDate:event.taskEndTime offset:-1];
	}
	
	if (event.taskPinned==1 && event.taskRepeatID>0) {
		//newEvent.recurrenceRule= [self getICalRERuleFromLocalEvent:event];
        newEvent.recurrenceRules=nil;
		[newEvent addRecurrenceRule:[self getICalRERuleFromLocalEvent:event]];
	}else {
		newEvent.recurrenceRules= nil;
	}

	
	//update alerts
	NSMutableArray *alertsList = [NSMutableArray array];
	
	NSArray *alerts = [[event creatAlertList] autorelease];
	
	for (AlertObject *alert in alerts)
	{
		NSInteger amount = [alert amount];
		
		switch ([alert timeUnit])
		{
			case 1: //hours
			{
				amount *= 60;
				break;
			}
			case 2: //days
			{
				amount *= 24*60;
			}
				break;
			case 3: //weeks
			{
				amount *= 7*24*60;
			}
				break;
		}
		
		EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:-amount*60];
		[alertsList addObject:alarm];		
	}
	
	if (alertsList.count == 0)
	{
		newEvent.alarms = nil;
	}
	else 
	{
		newEvent.alarms = alertsList;
	}
	
	//save the changes
    NSError *err;
	BOOL ret=NO;
	
	switch (updateREType) {
		case THIS_ONLY:
			ret=[self.eventsStore saveEvent:newEvent span:EKSpanThisEvent commit:YES error:&err];
			break;
		case ALL_SERIRES:
			ret=[self.eventsStore saveEvent:newEvent span:EKSpanFutureEvents commit:YES error:&err];
			break;
		case ALL_FOLLOWING:
			ret=[self.eventsStore saveEvent:newEvent span:EKSpanFutureEvents commit:YES error:&err];
			break;
		default:
			ret=[self.eventsStore saveEvent:newEvent span:EKSpanThisEvent commit:YES error:&err];
			break;
	}

	if (ret) {//update the iCalIdentifier for the new event
		event.iCalIdentifier=newEvent.eventIdentifier;
        [event update];
        
        if (event.taskPinned==1 && event.taskRepeatID>0) {
            NSMutableArray *dummmiesSource=[NSMutableArray arrayWithArray:taskmanager.dummiesList];
            for (Task *task in dummmiesSource) {
                if (task.parentRepeatInstance==event.primaryKey) {
                    task.iCalIdentifier=newEvent.eventIdentifier;
                }
            }
        }
	}
	
    [event release];
    
	//[newEvent refresh];
    
	//[newEvent release];
	
	//[eventStore release];
	return ret; 
}

-(void)updateInfoFromICalEvent:(EKEvent*)icalEvent toLocalEvent:(Task*)event{
	
	event.taskName=[[icalEvent.title stringByReplacingOccurrencesOfString:@" " withString:@""] length]==0? NSLocalizedString(@"newEventText", @""):icalEvent.title;
    
    if ([icalEvent.title length]>2) {
        if ([[icalEvent.title substringToIndex:2] isEqualToString:@"☐ "]){
            event.taskPinned=0;
            event.taskName=[event.taskName stringByReplacingOccurrencesOfString:@"☐ " withString:@""];
        }else if([[icalEvent.title substringToIndex:2] isEqualToString:@"✔ "]) {
            event.taskPinned=0;
            event.taskName=[event.taskName stringByReplacingOccurrencesOfString:@"✔ " withString:@""];
            event.taskCompleted=1;
        }else{
            event.taskPinned=1;
        }
    }

    event.taskStartTime=icalEvent.startDate;
    event.taskEndTime=icalEvent.endDate;

	//if ([event.taskName isEqualToString:@"Ernst och Erna"]) {
	//	printf("\n catched!");
	//}
	event.taskLocation=icalEvent.location;
	event.taskDescription=icalEvent.notes;
	event.isAllDayEvent=icalEvent.isAllDay;
	event.iCalCalendarName=[[icalEvent.calendar.title uppercaseString] stringByReplacingOccurrencesOfString:@" " 
																								 withString:@""];
	//event.taskProject=[[taskmanager calendarWithICalId:icalEvent.calendar.title] primaryKey];
//	event.taskDateUpdate=icalEvent.lastModifiedDate;
//	event.taskStartTime=icalEvent.startDate;
//	event.taskEndTime=icalEvent.endDate;
	event.iCalIdentifier=icalEvent.eventIdentifier;
//	event.taskPinned=1;
    
    EKCalendar *iCal=icalEvent.calendar;
    Projects *cal=[App_Delegate calendarWithICalId:iCal.calendarIdentifier];
	event.taskProject=cal.primaryKey;
	event.isHidden=cal.inVisible;
    
	if (icalEvent.isAllDay) 
	{
		event.taskStartTime=[ivoUtility resetDate:event.taskStartTime 
										year:[ivoUtility getYear:event.taskStartTime]
									   month:[ivoUtility getMonth:event.taskStartTime]
										 day:[ivoUtility getDay:event.taskStartTime]
										hour:0 
									  minute:0 
									 sencond:0];
		event.taskEndTime=[ivoUtility resetDate:event.taskEndTime 
									  year:[ivoUtility getYear:event.taskEndTime]
									 month:[ivoUtility getMonth:event.taskEndTime]
									   day:[ivoUtility getDay:event.taskEndTime]
									  hour:0 
									minute:0 
								   sencond:0];
        
        event.taskEndTime=[ivoUtility newDateFromDate:event.taskEndTime offset:86400];
	}
	
	event.taskHowLong = [event.taskEndTime timeIntervalSinceDate:event.taskStartTime];	
	
    //printf("\n start:%s, end: %s, %d", [[[ivoUtility createStringFromDate:event.taskStartTime isIncludedTime:YES]  autorelease] UTF8String],[[[ivoUtility createStringFromDate:event.taskEndTime isIncludedTime:YES] autorelease] UTF8String],event.taskHowLong );
    
	if (icalEvent.recurrenceRules != nil)
	{
		[self updateRETypeForEvent:event fromICalRERule:icalEvent];
	}
	
	NSMutableArray *alerts = [NSMutableArray arrayWithCapacity:3];
	
	for (EKAlarm *alarm in icalEvent.alarms)
	{
    //EKAlarm *alarm=[icalEvent.alarms objectAtIndex:0];
		
        if (alarm.absoluteDate == nil)
        {
            AlertObject *alert = [[AlertObject alloc] init]; 
            [alert setAlertBy:1];
            
            NSInteger amount = -alarm.relativeOffset/60;
            
            if (amount >= 7*24*60)
            {
                [alert setTimeUnit:3];
                amount = amount/(7*24*60);
            }
            else if (amount >= 24*60 && amount < 7*24*60)
            {
                [alert setTimeUnit:2];
                
                amount = amount/(24*60);
            }
            else if (amount >= 60 && amount < 24*60)
            {
                [alert setTimeUnit:1];
                
                amount = amount/60;
            }
            else
            {
                [alert setTimeUnit:0];
            }
            
            [alert setAmount:amount];
            
            [alerts addObject:alert];
            
            event.hasAlert=YES;
            event.alertUnit=alert.timeUnit;
            
            if (amount<=10) {
                event.alertIndex=amount;
            }else{
                if (amount<20) {
                    event.alertIndex=11;
                }else if(amount<30){
                    event.alertIndex=12;
                }else if(amount<30){
                    event.alertIndex=13;
                }else if(amount<90){
                    event.alertIndex=14;
                }else{
                    event.alertIndex=15;
                }
            }
            
            [alert release];			
            
        }
        break;
	}
	
	
	//[event updateAlertList:alerts];
   // event.alertUnit=
}

-(void) updateICaEvent:(EKEvent *)iE fromLocalEvent:(Task *)event updateType:(NSInteger)updateType eventStore:(EKEventStore*)eventStore
{
    [iE retain];
    [event retain];
    
    EKEvent *iEvent=iE;
    BOOL ret=[iEvent refresh];
    if (!ret) {
        iEvent=[self.eventsStore eventWithIdentifier:event.iCalIdentifier];
        if (iEvent) {
            ret=YES;
        }
    }
    
    if (!ret) goto finished;
    
    if (event.taskPinned==0) {
        if (event.taskCompleted==1) {
            iEvent.title =[NSString stringWithFormat:@"✔ %@", event.taskName];
        }else{
            iEvent.title =[NSString stringWithFormat:@"☐ %@", event.taskName];
        }
    }else{
        iEvent.title = event.taskName;
    }
    
	iEvent.location = event.taskLocation;
	iEvent.notes = event.taskDescription;
    
	iEvent.startDate = event.taskStartTime;
    
    if (event.isAllDayEvent) {
        NSDate *endDate=[ivoUtility newDateFromDate:event.taskEndTime offset:-86400];
        endDate=[ivoUtility resetDate:endDate
                                 year:[ivoUtility getYear:endDate]
                                month:[ivoUtility getMonth:endDate]
                                  day:[ivoUtility getDay:endDate]
                                 hour:23 
                               minute:59 
                              sencond:0];
        
        iEvent.endDate = endDate;
    }else{
        iEvent.endDate = event.taskEndTime;
    }
    
	iEvent.recurrenceRules = nil;
	
	Projects *calendar=[App_Delegate calendarWithPrimaryKey:event.taskProject];
	
	NSMutableArray *icalCals=[NSMutableArray arrayWithArray:[self getICalCalendars]];
	for (EKCalendar *cal in icalCals) {
		if ([cal.calendarIdentifier isEqualToString:calendar.iCalIdentifier]) {
			iEvent.calendar=cal;
			break;
		}
	}
	
	if (event.taskPinned==1 && event.isAllDayEvent)
	{
        [iEvent setAllDay:YES];
	}
	
	if (event.taskPinned==1 && event.taskRepeatID > 0)
	{
		//iEvent.recurrenceRule = [self getICalRERuleFromLocalEvent:event];
        [iEvent addRecurrenceRule:[self getICalRERuleFromLocalEvent:event]];
	}
	
    
	NSMutableArray *alarmList = [NSMutableArray arrayWithCapacity:5];
	
	NSMutableArray *alerts = [[event creatAlertList] autorelease];
	
	for (AlertObject *alert in alerts)
	{
		NSInteger amount = [alert amount];
		
		switch ([alert timeUnit])
		{
			case 1: //hours
			{
				amount *= 60;
				break;
			}
			case 2: //days
			{
				amount *= 24*60;
			}
				break;
			case 3: //weeks
			{
				amount *= 7*24*60;
			}
				break;
		}
		
		EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:-amount*60];
		[alarmList addObject:alarm];		
	}
	
	if (alarmList.count == 0)
	{
		iEvent.alarms = nil;
	}
	else 
	{
		iEvent.alarms = alarmList;
	}
	
    
	//save the changes
    NSError *err;
	switch (updateType) {
		case THIS_ONLY:
			ret=[self.eventsStore saveEvent:iEvent span:EKSpanThisEvent commit:YES error:&err];
			break;
		default:
			ret=[self.eventsStore saveEvent:iEvent span:EKSpanFutureEvents commit:YES error:&err];
			break;
	}
    
finished:{}
    [iEvent autorelease];
    [event autorelease];
}

#pragma mark Deletete

-(BOOL)deleteEventOnICal:(NSString*)eventIdentifier deleteREType:(NSInteger)deleteREType eventStore:(EKEventStore*)eventStore{
	BOOL ret=NO;
	if (needSkipDelete) return ret;
	EKEvent *deleteEvent  = [self.eventsStore eventWithIdentifier:eventIdentifier];
	
	if (!deleteEvent) {
		return ret;
	}
	
	NSDate *startDeleteTime=[NSDate date];
	
	NSError *err;
	switch (deleteREType) {
		case THIS_ONLY:
			ret=[self.eventsStore removeEvent:deleteEvent span:EKSpanThisEvent commit:YES error:&err];
			break;
		case ALL_SERIRES:
			ret=[self.eventsStore removeEvent:deleteEvent span:EKSpanFutureEvents commit:YES error:&err];
			break;
		case ALL_FOLLOWING:
			ret=[self.eventsStore removeEvent:deleteEvent span:EKSpanFutureEvents commit:YES error:&err];
			break;
		default:
			ret=[self.eventsStore removeEvent:deleteEvent span:EKSpanThisEvent commit:YES error:&err];
			break;
	}
	NSDate *endDeleteTime=[NSDate date];
	NSTimeInterval dur=[endDeleteTime timeIntervalSinceDate:startDeleteTime];
	//printf("\n IN delete method duration: %f",dur);
	
	if (dur>2) {
		needSkipDelete=YES;
	}
	return ret;
}


-(BOOL)deleteIEventOnICal:(EKEvent*)iEvent deleteREType:(NSInteger)deleteREType eventStore:(EKEventStore*)eventStore{
	BOOL ret=NO;
	if (needSkipDelete) return ret;
	//EKEvent *deleteEvent  = [self.eventsStore eventWithIdentifier:eventIdentifier];
	
	//if (!deleteEvent) {
//		return ret;
//	}
	
	NSDate *startDeleteTime=[NSDate date];
	
	NSError *err;
	switch (deleteREType) {
		case THIS_ONLY:
			ret=[self.eventsStore removeEvent:iEvent span:EKSpanThisEvent commit:YES error:&err];
			break;
		case ALL_SERIRES:
			ret=[self.eventsStore removeEvent:iEvent span:EKSpanFutureEvents commit:YES error:&err];
			break;
		case ALL_FOLLOWING:
			ret=[self.eventsStore removeEvent:iEvent span:EKSpanFutureEvents commit:YES error:&err];
			break;
		default:
			ret=[self.eventsStore removeEvent:iEvent span:EKSpanThisEvent commit:YES error:&err];
			break;
	}
	NSDate *endDeleteTime=[NSDate date];
	NSTimeInterval dur=[endDeleteTime timeIntervalSinceDate:startDeleteTime];
	//printf("\n IN delete method duration: %f",dur);
	
	if (dur>2) {
		needSkipDelete=YES;
	}
	return ret;
}

#pragma mark create Recuring ical event rules;

-(EKRecurrenceRule *)getICalRERuleFromLocalEvent:(Task*)event{

	if (event.taskRepeatID==0 || event.taskPinned==0) {
		return nil;
	}
	
	NSInteger repeatEvery;
	NSInteger repeatBy;
	NSString *repeatOn;
	
	if(event.taskRepeatOptions !=nil && ![event.taskRepeatOptions isEqualToString:@""]){
		NSArray *options=[event.taskRepeatOptions componentsSeparatedByString:@"/"];
		repeatEvery=[(NSString*)[options objectAtIndex:0] intValue];
		repeatOn=(NSString*)[options objectAtIndex:1];
		repeatBy=[(NSString*)[options objectAtIndex:2] intValue];
	}else {
		repeatEvery=1;
		repeatOn=@"";
		repeatBy=0;
	}
	
	if(repeatEvery<1){
		repeatEvery=1;
	}
	
	NSArray *days=[repeatOn componentsSeparatedByString:@"|"];

	NSMutableArray *daysOfWeek=[NSMutableArray array];	
	if (event.taskRepeatID==REPEAT_WEEKLY) {
		for (NSString *str in days) {
			if ([str intValue]>0) {
				EKRecurrenceDayOfWeek *dayOfWeek=[EKRecurrenceDayOfWeek dayOfWeek:[str intValue]];
				[daysOfWeek addObject:dayOfWeek];		
			}
		}
	}
	
	NSMutableArray *daysOfMonth=[NSMutableArray array];
	
	if (event.taskRepeatID==REPEAT_MONTHLY) {
		if (repeatBy == 1){
			EKRecurrenceDayOfWeek *dayOfWeek = [EKRecurrenceDayOfWeek dayOfWeek:[ivoUtility getWeekday:event.taskStartTime] weekNumber:[ivoUtility getWeekdayOrdinal:event.taskStartTime]];
			[daysOfWeek addObject:dayOfWeek];
		}else{ //by day of the month
			
			NSNumber *dayOfMonth = [NSNumber numberWithInt:[ivoUtility getDay:event.taskStartTime]];
			
			[daysOfMonth addObject:dayOfMonth];
			
			daysOfWeek=nil;
		}
	}
	
	NSNumber *monthOfYear= [NSNumber numberWithInt:[ivoUtility getMonth:event.taskStartTime]];
	
	EKRecurrenceEnd *until = nil;
	
	if (event.taskRepeatTimes!=0)
	{
		until = [EKRecurrenceEnd recurrenceEndWithEndDate:event.taskEndRepeatDate];
	}
	
	EKRecurrenceRule *ret=[[[EKRecurrenceRule alloc] initRecurrenceWithFrequency:event.taskRepeatID==REPEAT_DAILY?EKRecurrenceFrequencyDaily:(event.taskRepeatID==REPEAT_WEEKLY? EKRecurrenceFrequencyWeekly:(event.taskRepeatID==REPEAT_MONTHLY?EKRecurrenceFrequencyMonthly:EKRecurrenceFrequencyYearly))
																	   interval:repeatEvery
																  daysOfTheWeek:(NSArray*)daysOfWeek
																 daysOfTheMonth:(NSArray*)daysOfMonth
																monthsOfTheYear:[NSArray arrayWithObject:monthOfYear]
																 weeksOfTheYear:nil
																  daysOfTheYear:nil
																   setPositions:nil
																			end:until] autorelease];
	return ret;
}

-(void)updateRETypeForEvent:(Task*)event fromICalRERule:(EKEvent*)icalEvent{//(EKRecurrenceRule*)iCalReRule{
    if (icalEvent.recurrenceRules.count<=0) return;
    
	EKRecurrenceRule *iCalReRule=[icalEvent.recurrenceRules objectAtIndex:0];
	NSInteger times=0;
	switch (iCalReRule.frequency) {
		case EKRecurrenceFrequencyDaily:
			event.taskRepeatID=REPEAT_DAILY;
			times=1;
			break;
		case EKRecurrenceFrequencyWeekly:
			event.taskRepeatID=REPEAT_WEEKLY;
			times=7;
			break;
		case EKRecurrenceFrequencyMonthly:
			event.taskRepeatID=REPEAT_MONTHLY;
			times=31;
			break;
		case EKRecurrenceFrequencyYearly:
			event.taskRepeatID=REPEAT_YEARLY;
			times=365;
			break;
		default:
			event.taskRepeatID=REPEAT_NONE;
			times=0;
			break;
	}
	
	NSInteger repeatEvery = iCalReRule.interval;
	NSString *repeatOn = nil;
	
	for (int i=0; i<iCalReRule.daysOfTheWeek.count; i++)
	{
		EKRecurrenceDayOfWeek *dayOfWeek = [iCalReRule.daysOfTheWeek objectAtIndex:i];
		
		if (!repeatOn) {
            repeatOn=[NSString stringWithFormat:@"%ld",(long)dayOfWeek.dayOfTheWeek];
		}else {
            repeatOn=[repeatOn stringByAppendingFormat:@"|%ld",(long)dayOfWeek.dayOfTheWeek];
		}
	}
	
	if (iCalReRule.daysOfTheWeek.count==0) {
        repeatOn=[NSString stringWithFormat:@"%ld",(long)[ivoUtility getWeekday:icalEvent.startDate]];
	}
	
	NSInteger repeatBy=0;
	if (iCalReRule.frequency==EKRecurrenceFrequencyMonthly) {
		repeatBy=(iCalReRule.daysOfTheWeek != nil && iCalReRule.daysOfTheWeek.count > 0)? 1:0;
	}
	
    event.taskRepeatOptions = [NSString stringWithFormat:@"%ld/%@/%ld", (long)repeatEvery, repeatOn, (long)repeatBy];

	if (iCalReRule.recurrenceEnd.endDate || iCalReRule.recurrenceEnd.occurrenceCount>0) {
		
		if (iCalReRule.recurrenceEnd.endDate) {
			event.taskEndRepeatDate=iCalReRule.recurrenceEnd.endDate;
		}else {
			event.taskEndRepeatDate=[ivoUtility newDateFromDate:icalEvent.startDate offset:iCalReRule.recurrenceEnd.occurrenceCount*repeatEvery*times*86400];
		}

        repeatCountTime rpCount=[ivoUtility createRepeatCountFromEndDate:event.taskStartTime
                                                              typeRepeat:event.taskRepeatID
                                                                  toDate:event.taskEndRepeatDate
                                                        repeatOptionsStr:event.taskRepeatOptions 
                                                             reStartDate:event.taskStartTime];
		
		event.taskRepeatTimes=rpCount.repeatTimes;
        event.taskNumberInstances=rpCount.numberOfInstances;
	}else {
		event.taskRepeatTimes=0;
        event.taskNumberInstances=0;
	}
}

//this will return the number of days for syncing window unit
- (NSInteger) getSyncWindowUnit:(BOOL) isForStart
{
	NSInteger ret=0;
	NSDate *today = [NSDate date];
	
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
	
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:today];
		
	NSDateComponents *wdComps =[gregorian components:NSWeekdayCalendarUnit fromDate:today];
	NSInteger wd = [wdComps weekday];
	
	if (isForStart)
	{		
		switch (taskmanager.currentSetting.syncWindowStart)
		{
			case 0: //this week
			{
				ret=wd;
			}
				break;
			case 1: //last week
			{
				ret=wd+7;
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
				
				ret=(NSInteger)[[NSDate date] timeIntervalSinceDate:[gregorian dateFromComponents:comps]]/86400+1;
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
				
				ret=(NSInteger)[[NSDate date] timeIntervalSinceDate:[gregorian dateFromComponents:comps]]/86400+1;
			}
				break;
			case 4: //last year
			{
				comps.year -= 1;
				comps.month = 1;
				comps.day = 1;
				
				ret=(NSInteger)[[NSDate date] timeIntervalSinceDate:[gregorian dateFromComponents:comps]]/86400+1;
			}
				break;				
		}
		
	}
	else
	{
		switch (taskmanager.currentSetting.syncWindowEnd)
		{
			case 0: //this week
			{
				ret=7-wd;
			}
				break;
			case 1: //next week
			{
				ret=2*7-wd;
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
				
				ret=(NSInteger)[[gregorian dateFromComponents:comps] timeIntervalSinceDate:[NSDate date]]/86400 +1;
				
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
				
				ret=(NSInteger)[[gregorian dateFromComponents:comps] timeIntervalSinceDate:[NSDate date]]/86400+1;
			}
				break;
			case 4: //next year
			{
				comps.year += 2;
				comps.month = 1;
				comps.day = 1;
				
				ret=(NSInteger)[[gregorian dateFromComponents:comps] timeIntervalSinceDate:[NSDate date]]/86400+1;
			}
				break;				
		}
		
	}
	
	return ret;
}

- (NSDate *) getSyncWindowDate:(BOOL) isStart
{
	NSDate *today = [NSDate date];
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
	
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:today];
	
	if (isStart)
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
	
	if (isStart)
	{		
		switch (taskmanager.currentSetting.syncWindowStart)
		{
			case 0: //this week
			{
				today=[ivoUtility newDateFromDate:[gregorian dateFromComponents:comps] 
										  offset:-(wd-1)*86400];
			}
				break;
			case 1: //last week
			{
				today=[ivoUtility newDateFromDate:[gregorian dateFromComponents:comps] 
										  offset:-(wd-1+7)*86400];

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
		switch (taskmanager.currentSetting.syncWindowEnd)
		{
			case 0: //this week
			{
				today=[ivoUtility newDateFromDate:[gregorian dateFromComponents:comps] 
										  offset:(7-wd)*86400];

			}
				break;
			case 1: //next week
			{
				today=[ivoUtility newDateFromDate:[gregorian dateFromComponents:comps] 
										  offset:(2*7-wd)*86400];
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
				
				today=[ivoUtility newDateFromDate:[gregorian dateFromComponents:comps] 
										  offset:-86400];
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
				
				today=[ivoUtility newDateFromDate:[gregorian dateFromComponents:comps] 
										  offset:-86400];
			}
				break;
			case 4: //next year
			{
				comps.year += 2;
				comps.month = 1;
				comps.day = 1;
				
				today=[ivoUtility newDateFromDate:[gregorian dateFromComponents:comps] 
										  offset:-86400];
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


-(void)backgroundFullSync{
	[self performSelectorInBackground:@selector(syncCalendarAndEvents) withObject:nil];
}

-(void)syncCalendarAndEvents{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(waitToFullSync:) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] run];
	[pool release];
}

-(void)waitToFullSync:(id)sender{
	NSTimer *timer=sender;
	
	if (!isSyncing) {
        totalSync++;

        //[self.eventsStore commit:nil];
        //[self.eventsStore reset];
        
        //self.eventsStore=[[[EKEventStore alloc] init] autorelease];
        
        //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        App_Delegate.me.networkActivityIndicatorVisible=YES;
        
        //[self.eventsStore refreshSourcesIfNecessary];
        
		needSkipDelete=NO;
		isSyncing=YES;

		[self.iCalCalendarsList removeAllObjects];
		[self.iCalCalendarsList addObjectsFromArray:[self.eventsStore calendarsForEntityType:EKEntityTypeEvent]];
		
		NSMutableArray *iCalCalList=self.iCalCalendarsList;
        //[App_Delegate getProjectList];
        
		NSMutableArray *calList=[NSMutableArray arrayWithArray:projectList];
		
		NSMutableArray *iCalCalListTmp=[NSMutableArray arrayWithArray:iCalCalList];
		NSMutableArray *calListTmp=[NSMutableArray arrayWithArray:calList];
		
        //delete calendars which deleted on local
        NSArray *delCalArr=[taskmanager.currentSetting.deletedICalCalendars componentsSeparatedByString:@"|"];
        for (NSString *calid in delCalArr) {
            for(EKCalendar *ical in iCalCalListTmp){
                if ([ical.calendarIdentifier isEqualToString:calid]) {
                    [self.eventsStore removeCalendar:ical commit:YES error:nil];
                    [iCalCalList removeObject:ical];
                    break;
                }
            }
        }

        taskmanager.currentSetting.deletedICalCalendars=@"";
        
		//refresh the old linked
		for (EKCalendar *iCalCal in iCalCalListTmp) {
			for (Projects *cal in calListTmp) {
				//check if this is linked
				if ([iCalCal.calendarIdentifier isEqualToString:cal.iCalIdentifier]) {
					//Yes, this is the old linked, continue
					iCalCal.title=cal.projName;
					[self.eventsStore saveCalendar:iCalCal commit:YES error:nil];
					[iCalCalList removeObject:iCalCal];
					[calList removeObject:cal];
					break;
				}
			}
		}
        
		iCalCalListTmp=[NSMutableArray arrayWithArray:iCalCalList];
		calListTmp=[NSMutableArray arrayWithArray:calList];
		
		//link the calendars which have the same name on iPhone Calendar and SO 
		for (EKCalendar *iCalCal in iCalCalListTmp) {
			NSString *iCalName=[[iCalCal.title uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
            if (!iCalName || [iCalName length]==0) {
                [iCalCalList removeObject:iCalCal];
                continue;
            }
            
			for (Projects *cal in calListTmp) {
				NSString *calName=[[cal.projName uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
				if ([iCalName isEqualToString:calName]) {
                    //New, link it
                    cal.iCalIdentifier=iCalCal.calendarIdentifier;
                    [cal update];
					[iCalCalList removeObject:iCalCal];
					[calList removeObject:cal];
					break;
				}
			}
		}
		
/*		//Create the new calendar from iPhone calendars, which is not existed on SO
		for (EKCalendar *iCal in iCalCalList) {
			Projects *cal=[[[Projects alloc] init] autorelease];
			cal.projName=iCal.title;
			cal.builtIn=ICAL;
			cal.iCalCalendarName=[[iCal.title uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
            cal.iCalIdentifier=iCal.calendarIdentifier;
			cal.colorId=(arc4random() %8);
			cal.groupId=(arc4random() %4);;
			cal.enableICalSync=1;
			cal.enableTDSync=0;
			[taskmanager addCalendarToCalendarList:cal];
			//printf("\niCalId: %d",[iCal.taskProject intValue]);
		}
*/		
        //create events from ST to iPhone Cal
        calListTmp=[NSMutableArray arrayWithArray:calList];
        
        for (Projects *project in calListTmp){
            if ([project.iCalIdentifier length]==0){
                EKCalendar *remoteCal=[EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:self.eventsStore];
                BOOL hasLocalSource=NO;
                NSArray *sources=[NSArray arrayWithArray:self.eventsStore.sources];
                
                for(EKSource *source in sources){
                    if ((source.sourceType==EKSourceTypeCalDAV &&
                         ![[source.title uppercaseString] isEqualToString:@"GMAIL"])){
                        remoteCal.source=source;
                        hasLocalSource=YES;
                        
                        remoteCal.title=project.projName;
                        NSError *error=nil;
                        BOOL ret=[self.eventsStore saveCalendar:remoteCal commit:YES error:&error];
                        if(ret){
                            project.iCalIdentifier=remoteCal.calendarIdentifier;
                            [project update];
                        }else {
                            hasLocalSource=NO;
                        }
                        
                        break;
                    }
                }
                
                if (!hasLocalSource) {
                    for(EKSource *source in sources){
                        if (source.sourceType==EKSourceTypeLocal){
                            remoteCal.source=source;
                            hasLocalSource=YES;
                            
                            remoteCal.title=project.projName;
                            NSError *error=nil;
                            BOOL ret=[self.eventsStore saveCalendar:remoteCal commit:YES error:&error];
                            if(ret){
                                project.iCalIdentifier=remoteCal.calendarIdentifier;
                                [project update];
                            }else {
                                hasLocalSource=NO;
                            }
                            
                            break;
                        }
                    }
                    
                }
                
                if (!hasLocalSource) {
                    EKCalendar *defaultRemoteCal=[self.eventsStore defaultCalendarForNewEvents];
                    if (defaultRemoteCal) {
                        remoteCal.source=defaultRemoteCal.source;
                        
                        remoteCal.title=project.projName;
                        NSError *error=nil;
                        BOOL ret=[self.eventsStore saveCalendar:remoteCal commit:YES error:&error];
                        if(ret){
                            project.iCalIdentifier=remoteCal.calendarIdentifier;
                            [project update];
                        }else {
                            
                        }
                    }
                }
            
            }else{
                [projectList removeObject:project];
                [calList removeObject:project];
                [project deleteFromDatabase];
                
            }
        }
        
        //Create the new calendar from iPhone calendars, which is not existed on SO
		for (EKCalendar *iCal in iCalCalList) {
			Projects *cal=[[[Projects alloc] init] autorelease];
			cal.projName=iCal.title;
            //printf("\nnew cal from iPhone Cal: %s",[cal.projName UTF8String]);
			cal.builtIn=ICAL;
			cal.iCalCalendarName=[[iCal.title uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
            cal.iCalIdentifier=iCal.calendarIdentifier;
			cal.colorId=(arc4random() %8);
			cal.groupId=(arc4random() %4);;
			cal.enableICalSync=1;
			cal.enableTDSync=0;
			[taskmanager addCalendarToCalendarList:cal];
			//printf("\niCalId: %d",[iCal.taskProject intValue]);
		}

		//SPad 2.1, clean events belongs to calendars which was deleted or changed on iPad Calendar
        /*
		NSMutableArray *arr=[NSMutableArray arrayWithArray:calList];
		for (Projects *cal in arr) {
			if ([cal.iCalCalendarName length]>0) {
				//this will delete all events from the mapped calendar on SPad, not separate delete events from two sources
				[App_Delegate deleteAllTasksBelongCalendar:cal.primaryKey];
			}
		}
		*/
        
		//update calendar List
		//[projectList removeAllObjects];
        //[projectList addObjectsFromArray:[App_Delegate getProjectListFromDB]];
        
		//[App_Delegate getProjectList];
		
		//sync Events-------------------------------------------------------
		
        
        //[self.eventsStore commit:nil];
        //[self.eventsStore reset];
        
		//just keep the syncing calendars
		[self.iCalCalendarsList removeAllObjects];
		[self.iCalCalendarsList addObjectsFromArray:[self.eventsStore calendarsForEntityType:EKEntityTypeEvent]];
		
		iCalCalList=[NSMutableArray arrayWithArray: self.iCalCalendarsList];
		iCalCalListTmp=[NSMutableArray arrayWithArray:iCalCalList];
		
		//get iCal events
		NSMutableArray *iCalEvList=[NSMutableArray array];
        [iCalEvList addObjectsFromArray:[self getICalEventsWithCalendars:iCalCalList]];
		
		NSMutableArray *iCalEvents=[NSMutableArray array];
		
		for (EKEvent *iEvent1 in iCalEvList) {
			NSMutableArray *arr=[NSMutableArray arrayWithArray:iCalEvents];
			if (arr.count==0) {
				[iCalEvents addObject:iEvent1];
			}else {
				for (EKEvent *iEvent2 in arr) {
					if ([iEvent1.eventIdentifier isEqualToString:iEvent2.eventIdentifier]) {
						goto next;
					}
				}
				
				[iCalEvents addObject:iEvent1];
			}
			
		next:
			{}
		}
		
		//get root for each iCal RE
		NSMutableArray *arrTmp=[NSMutableArray arrayWithArray:iCalEvents];
		for (EKEvent *iEvent in arrTmp) {
			if (!iEvent.isDetached && iEvent.recurrenceRules != nil)
			{
				EKEvent *rootRE=[self.eventsStore eventWithIdentifier:iEvent.eventIdentifier];
				if (rootRE) {
					[rootRE retain];
					[iCalEvents removeObject:iEvent];
					[iCalEvents addObject:rootRE];
					[rootRE release];
				}
			}
		}
		
		NSArray *deletedList=[taskmanager.currentSetting.deletedICalEvents componentsSeparatedByString:@"|"];
		//printf("\n delete str: %s",[taskmanager.currentSetting.deletedICalEvents UTF8String]);
		
		NSMutableArray *iCalEArr=[NSMutableArray arrayWithArray:iCalEvents];
		
		BOOL needUpdate=NO;
        NSError *err=nil;
		for (NSString *str in deletedList) {
			if ([str length]==0) {
				continue;
			}
			
			BOOL needDelete=NO;
            BOOL found=NO;
            BOOL ret;
			for (EKEvent *iEvent in iCalEArr) {
				if ([str length]>0 && [iEvent.eventIdentifier isEqualToString:str]) {
                    //[self deleteEventOnICal:iEvent.eventIdentifier deleteREType:ALL_SERIRES eventStore:self.eventsStore];
                    //[self deleteIEventOnICal:iEvent deleteREType:ALL_SERIRES eventStore:self.eventsStore];
                    ret=[self.eventsStore removeEvent:iEvent span:ALL_SERIRES commit:YES error:&err];
                    needUpdate=YES;
                    needDelete=YES;
                    found=YES;
					[iCalEvents removeObject:iEvent];
                    break;
				}
			}
            
            if (!found && [str length]>0) {
                EKEvent *iEvent1=[self.eventsStore eventWithIdentifier:str];
                [self.eventsStore removeEvent:iEvent1 span:EKSpanFutureEvents commit:YES error:nil];
            }
			
            taskmanager.currentSetting.deletedICalEvents=[taskmanager.currentSetting.deletedICalEvents stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"|%@",str] withString:@""];
		}
		
        if (taskmanager.currentSetting.syncEventOnly==1) {
            iCalEArr=[NSMutableArray arrayWithArray:iCalEvents];
            for (EKEvent *iEvent in iCalEArr) {
                if ([iEvent.title length]>2) {
                    if ([[iEvent.title substringToIndex:2] isEqualToString:@"☐ "] || 
                        [[iEvent.title substringToIndex:2] isEqualToString:@"✔ "] ) {
                        [iCalEvents removeObject:iEvent];
                    }
                }
            }
        }
        
        //[self.eventsStore commit:nil];
        
//		NSDate *syncStart=[self getSyncWindowDate:YES] ;
//		NSDate *syncEnd=[self getSyncWindowDate:NO];

        NSMutableArray *eventList=[NSMutableArray array];

        //add hidden events/tasks into sync data
        [App_Delegate addHiddenTasksEventsToList:eventList];

        if (taskmanager.currentSetting.syncEventOnly==0) {
            [eventList addObjectsFromArray:taskmanager.taskList];
            NSMutableArray *completedArr=[App_Delegate createFullDoneTaskList];
            
            [eventList addObjectsFromArray:completedArr];
            [completedArr release];
        }else{
            [eventList addObjectsFromArray:[App_Delegate getAllEventsFromList:taskmanager.taskList]];
        }
        
        
        NSMutableArray *localArr=[NSMutableArray arrayWithArray:eventList];
        for (Task *task in localArr) {
            if (task.primaryKey<0) {
                [eventList removeObject:task];
            }
        }
        
        
        
		/*
		NSMutableArray *allTaskEventArr=[NSMutableArray arrayWithArray:taskmanager.taskList];
		
        
		NSMutableArray *ades=[App_Delegate getADEsListOnlyFromTaskList:allTaskEventArr 
														  fromDate:syncStart  
															toDate:syncEnd  
													withSearchText:@"" 
														  needSort:YES];
		
		[eventList addObjectsFromArray:ades];
		
		//get SO events
		
		NSMutableArray *soEvents=[App_Delegate getEventOnlyListFromTaskList:allTaskEventArr 
															   fromDate:syncStart
																 toDate:syncEnd
														 withSearchText:@"" 
															   needSort:YES];
		[eventList addObjectsFromArray:soEvents];
		
		NSMutableArray *SORades=[App_Delegate getAllRecurringADEsFromTaskList:allTaskEventArr
														   withSearchText:@""];
		
		for (Task *task in SORades) {
			if ([task.taskStartTime compare:syncEnd]==NSOrderedDescending || 
				([task.taskEndTime compare:syncStart]==NSOrderedAscending && task.taskRepeatTimes!=0 && [task.taskEndRepeatDate compare:syncStart]==NSOrderedAscending)) {
				continue;
			}
			
			[eventList addObject:task];
		}
		
		NSMutableArray *soREs=[App_Delegate getAllRecurringEventsFromTaskList:allTaskEventArr
														   withSearchText:@""];
		
		for (Task *task in soREs) {
			if ([task.taskStartTime compare:syncEnd]==NSOrderedDescending || 
				([task.taskEndTime compare:syncStart]==NSOrderedAscending && task.taskRepeatTimes!=0 && [task.taskEndRepeatDate compare:syncStart]==NSOrderedAscending)) {
				continue;
			}
			
			[eventList addObject:task];
		}
		*/
        
		//remove events which is not belonging to enable sync calendars
		NSMutableArray *eventArr=[NSMutableArray arrayWithArray:eventList];

		//update synced events first
		NSMutableArray *iCalEventArr=[NSMutableArray arrayWithArray:iCalEvents];
		
		for (Task *event in eventArr) {
			
			if ([event.iCalIdentifier length]>0) {
				for (EKEvent *iEvent in iCalEventArr) {
					if ([iEvent.eventIdentifier isEqualToString:event.iCalIdentifier]) {
						
						if ([iEvent.lastModifiedDate compare:event.taskDateUpdate]!=NSOrderedDescending) {
                            if (event.parentRepeatInstance>0) {
                                [self updateICaEvent:iEvent fromLocalEvent:event updateType:THIS_ONLY eventStore:self.eventsStore];
                            }else{
                                [self updateICaEvent:iEvent fromLocalEvent:event updateType:ALL_SERIRES eventStore:self.eventsStore];
                            }
                        }else {
                            [self updateInfoFromICalEvent:iEvent toLocalEvent:event];
                            [event update];
                        }
						
						[eventList removeObject:event];
						[(NSMutableArray*)iCalEvents removeObject:iEvent];
						break;
					}
				}
			}
		}
		
		//check if the synced events were changed/deleted on iCal
		eventArr=[NSMutableArray arrayWithArray:eventList];
		for (Task *event in eventArr) {
			if ([event.iCalIdentifier length]>0) {
				if (event.parentRepeatInstance<1) {
                    EKEvent *iEvent=[self.eventsStore eventWithIdentifier:event.iCalIdentifier];
                    if (!iEvent) {
                        event.iCalIdentifier=@"";
                        
                        if ([event.reminderIdentifier length]>0) {
                            taskmanager.currentSetting.deletedReminders=[taskmanager.currentSetting.deletedReminders stringByAppendingFormat:@"|%@",event.reminderIdentifier];
                            [taskmanager.currentSetting update];
                        }
                        
                        [event deleteFromDatabase];
                        [taskmanager.taskList removeObject:event];
                    }else{
                        //if ([event.taskDateUpdate compare:taskmanager.currentSetting.iCalLastSyncTime]==NSOrderedDescending ||
						//	[iEvent.lastModifiedDate compare:taskmanager.currentSetting.iCalLastSyncTime]==NSOrderedDescending) {
							if ([iEvent.lastModifiedDate compare:event.taskDateUpdate]!=NSOrderedDescending) {
                                if (event.parentRepeatInstance>0) {
                                    [self updateICaEvent:iEvent fromLocalEvent:event updateType:THIS_ONLY eventStore:self.eventsStore];
                                }else{
                                    [self updateICaEvent:iEvent fromLocalEvent:event updateType:ALL_SERIRES eventStore:self.eventsStore];
                                }
							}else {
								[self updateInfoFromICalEvent:iEvent toLocalEvent:event];
								[event update];
							}
						//}
                    }
				}else {
					[self createNewEventToICal:event 
								  updateREType:THIS_ONLY 
									eventStore:self.eventsStore];
				}

				
				[eventList removeObject:event];

			}
		}
		
		
		//add new events from iCal to SO
		NSMutableArray *exceptionIcalEvents=[NSMutableArray array];
		iCalEventArr=[NSMutableArray arrayWithArray:iCalEvents];
		for (EKEvent *iEvent in iCalEventArr) {
			if (iEvent.isDetached) {
				[exceptionIcalEvents addObject:iEvent];
			}else {
				Task *event=[[Task alloc] init];
				event.taskPinned=1;
				//event.builtIn=ICAL;
				[self updateInfoFromICalEvent:iEvent toLocalEvent:event];
                if (event.taskPinned==0) {
                    event.taskWhere=0;
                    if ([ivoUtility isTaskInOtherContextRange:event]) {
                        event.taskWhere=1;
                    }
                }
                
				[event prepareNewRecordIntoDatabase:database];
				[event update];
				
				//need add to tasklist here???
				if (!event.isHidden) {
					[taskmanager.taskList addObject:event];
				}
				
				[event release];
			}
		} 
		
		//add exceptions RE to SO
		for (EKEvent *iEvent in exceptionIcalEvents) {
			//printf("\n exp: %s",[iEvent.eventIdentifier UTF8String]);
			NSString *expIdStr=[[iEvent.eventIdentifier copy] autorelease];
			NSArray *parts = [expIdStr componentsSeparatedByString:@"/"];
            
            if (parts.count>0) {
                NSString *rootId = [parts objectAtIndex:0];
                
                Task *rootRE =nil;
                NSMutableArray *eventMatchedList=[NSMutableArray arrayWithArray:taskmanager.taskList];
                for (Task *event in eventMatchedList) {
                    if ([event.iCalIdentifier isEqualToString:rootId]) {
                        rootRE=event;
                        break;
                    }
                }
                
                if (rootRE != nil)
                {
                    Task *event = [[Task alloc] init];
                    
                    [self updateInfoFromICalEvent:iEvent toLocalEvent:event];
                    
                    event.parentRepeatInstance = rootRE.primaryKey;
                    //				event.isFromSyncing=YES;
                    event.taskRepeatID = 0;
                    event.taskPinned = 1;
                    event.originalExceptionDate=[ivoUtility resetDate:iEvent.startDate year:[ivoUtility getYear:iEvent.startDate] month:[ivoUtility getMonth:iEvent.startDate] day:[ivoUtility getDay:iEvent.startDate]  hour:[ivoUtility getHour:rootRE.taskStartTime]  minute:[ivoUtility getMinute:rootRE.taskStartTime] sencond:[ivoUtility getSecond:rootRE.taskStartTime]];
                    event.taskProject = rootRE.taskProject;
                    event.iCalIdentifier=expIdStr;
                    
                    //rootRE.repeatExceptions=[rootRE.repeatExceptions stringByAppendingFormat:@"|%lf",[event.originalExceptionDate timeIntervalSince1970]];
                    //[rootRE update];
                    
                    [taskmanager updateExceptionIntoRE:event
                                                inList:eventMatchedList
                                     originalStartDate:event.originalExceptionDate
                                                action:0];
                    
                    //				event.originalExceptionDate=[ivoUtility resetTime4Date:iEvent.startDate
                    //																 hour:[ivoUtility getHour:rootRE.taskStartTime]
                    //															   minute:[ivoUtility getMinute:rootRE.taskStartTime]
                    //															   second:[ivoUtility getSecond:rootRE.taskStartTime]];
                    //[event insertIntoDatabase:database];
                    //[event update];
                    //				[App_Delegate removeDummiesListWithParentId:event.parentRepeatInstance];
                    //event.isFromSyncing=NO;
                    [event release];
                    
                }
            }
 		}
		
		//add new event from SO to iCal
		eventArr=[NSMutableArray arrayWithArray:eventList];
		for (Task *event in eventArr) {
			if (event.parentRepeatInstance==-1) {
				[self createNewEventToICal:event updateREType:ALL_SERIRES eventStore:self.eventsStore];
			}else {
				//exception of RE
				Task *rootRE=nil;
				NSMutableArray *localSource=[NSMutableArray arrayWithArray:taskmanager.taskList];
				for (Task *task in localSource) {
					if (task.primaryKey==event.parentRepeatInstance) {
						rootRE=task;
						break;
					}
				}
				
				if (rootRE) {
					EKEvent *rootICalRE=[self.eventsStore eventWithIdentifier:rootRE.iCalIdentifier];
					if (rootICalRE) {
						BOOL hasDummy=NO;
						for (EKEvent *iE in iCalEvList) {
							if ([iE.eventIdentifier isEqualToString:rootICalRE.eventIdentifier] &&
								[ivoUtility compareDateNoTime:iE.startDate withDate:event.originalExceptionDate]==NSOrderedSame) {
								[self updateICaEvent:iE fromLocalEvent:event updateType:THIS_ONLY eventStore:self.eventsStore];
								NSString *exid=[[iE.eventIdentifier copy] autorelease];
								event.iCalIdentifier=exid;
								[event update];
								hasDummy=YES;
								break;
							}
						}
						
						//reconcile auto-disappear exception on iCal after synced
						if(!hasDummy){
							[self createNewEventToICal:event updateREType:ALL_SERIRES eventStore:self.eventsStore];
						}
					}
				}
			}
			
		}
		
        //[self.eventsStore commit:nil];

		taskmanager.currentSetting.iCalLastSyncTime=[NSDate date];
		[taskmanager.currentSetting update];
		
		//reset tasklist
		//for (Task *task in allTaskEventArr) {
		//	task.isFromSyncing=NO;
		//}
		
        NSMutableArray *sourceList=[NSMutableArray arrayWithArray:taskmanager.taskList];
        for (Task *task in sourceList) {
            if (task.isHidden) {
                [taskmanager.taskList removeObject:task];
            }
        }
        
        sourceList=[NSMutableArray arrayWithArray:taskmanager.taskList];
		[taskmanager updateLocalNotificationForList:sourceList];
		
		//isReloadDataFromSync=YES;
        taskmanager.filterClause=nil;
        self.rootViewController.isFilter=NO;

        totalSync--;
        if (totalSync<=0) {
            [self.rootViewController performSelectorOnMainThread:@selector(startRefreshTasks) withObject:nil waitUntilDone:NO];
        }
		//isReloadDataFromSync=NO;
		
		isSyncing=NO;
		
		//[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		App_Delegate.me.networkActivityIndicatorVisible=NO;
		[timer invalidate];
		timer=nil;
        
        
		//[eventStore release];
        //isSyncingEvent=NO;
	}
}

////

-(void)oneWayUpdateiCal:(Projects*)calendar{
	
	if (taskmanager.currentSetting.autoICalSync==0) return;
    //[self.eventsStore refreshSourcesIfNecessary];
	EKOneWaySyncObject *obj=[[EKOneWaySyncObject alloc] init];
	obj.project=calendar;
	[self performSelectorInBackground:@selector(oneWaySyncUpdateICal:) withObject:obj];
	[obj release];
}

-(void)oneWaySyncUpdateICal:(EKOneWaySyncObject*)obj{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	//[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	App_Delegate.me.networkActivityIndicatorVisible=YES;
    
	[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(waitToOneWayUpdateICal:) userInfo:obj repeats:YES];
	[[NSRunLoop currentRunLoop] run];
	[pool release];	
}

-(void)waitToOneWayUpdateICal:(id)sender{
	NSTimer *timer=sender;
	
	if (!isSyncing) {
        //[self.eventsStore reset];
        
		isSyncing=YES;
        App_Delegate.me.networkActivityIndicatorVisible=YES;
        
		EKOneWaySyncObject *obj=[timer userInfo];
		NSMutableArray *deletedCals=(NSMutableArray*)[taskmanager.currentSetting.deletedICalCalendars componentsSeparatedByString:@"|"];
        
        [self.iCalCalendarsList removeAllObjects];
		[self.iCalCalendarsList addObjectsFromArray:[self.eventsStore calendarsForEntityType:EKEntityTypeEvent]];
        NSMutableArray *sourceList=[NSMutableArray arrayWithArray:taskmanager.taskList];
        
		for (NSString *iCalId in deletedCals) {
            Projects *project=[App_Delegate calendarWithICalId:iCalId];
            //NSMutableArray *icalCals=[NSMutableArray arrayWithArray:[self getICalCalendars]];
			for (EKCalendar *iCal in self.iCalCalendarsList) {
                if ([iCal.calendarIdentifier isEqualToString:iCalId]) {
                    [self.eventsStore removeCalendar:iCal commit:YES error:nil];
                    for (Task *task in sourceList) {
                        if (task.taskProject==project.primaryKey) {
                            //[self.eventsStore removeEvent: span:<#(EKSpan)#> commit:<#(BOOL)#> error:<#(NSError **)#> ];
                            [task deleteFromDatabase];
                            [taskmanager.taskList removeObject:task];
                            break;
                        }
                    }
                    break;
                }
            }
		}
		
        if ([obj.project.iCalIdentifier length]>0) {
            for (EKCalendar *iCal in [self.eventsStore calendarsForEntityType:EKEntityTypeEvent]) {
                if ([iCal.calendarIdentifier isEqualToString:obj.project.iCalIdentifier]) {
                    iCal.title=obj.project.projName;
                    [self.eventsStore saveCalendar:iCal commit:YES error:nil];
                }
            }
        }else{
            EKCalendar *iCal=[EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:self.eventsStore];
            //iCal.source=[self.eventsStore.sources objectAtIndex:0];
            for(EKSource *source in self.eventsStore.sources){
                if (source.sourceType==EKSourceTypeLocal){
                    iCal.source=source;
                    break;
                }
            }
            
            iCal.title=obj.project.projName;
            NSError *err=nil;
            BOOL ret=[self.eventsStore saveCalendar:iCal commit:YES error:&err];
            if(ret){
                obj.project.iCalIdentifier=iCal.calendarIdentifier;
                [obj.project update];
            }else{
                printf("\n Error: %s",[[err debugDescription] UTF8String]);
            }
        }
        
        //[self.eventsStore commit:nil];
        
		taskmanager.currentSetting.deletedICalCalendars=@"";
		[taskmanager.currentSetting update];
		
        
		//[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        App_Delegate.me.networkActivityIndicatorVisible=NO;
        
		//[eventStore release];
		isSyncing=NO;
		[timer invalidate];
		timer=nil;
	}
}

////

-(void)oneWayUpdateEvent:(Task*)event originalCalendarId:(NSInteger)originalCalendarId updateType:(NSInteger)updateType{
	
	if (taskmanager.currentSetting.autoICalSync==0) return;
	//[self.SmartViewController showStatusBarWithText:syncingText];
    
    //[self.eventsStore refreshSourcesIfNecessary];
    
	EKOneWaySyncObject *obj=[[EKOneWaySyncObject alloc] init];
	obj.event=event;
	obj.originalCalendarId=originalCalendarId;
	obj.updateType=updateType;
	[self performSelectorInBackground:@selector(oneWaySyncUpdateEvent:) withObject:obj];
	[obj release];
}

-(void)oneWaySyncUpdateEvent:(EKOneWaySyncObject*)obj{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	//[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(waitToOneWayUpdateEvent:) userInfo:obj repeats:YES];
	[[NSRunLoop currentRunLoop] run];
	[pool release];	
}

-(void)waitToOneWayUpdateEvent:(id)sender{
	NSTimer *timer=sender;
	
	if (!isSyncing) {
        //[self.eventsStore commit:nil];
        //[self.eventsStore reset];
        
		isSyncing=YES;
		needSkipDelete=NO;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

		//[self.SmartViewController showStatusBarWithText:syncingText];
		//EKEventStore *eventStore=[[EKEventStore alloc] init];

		EKOneWaySyncObject *obj=[[[timer userInfo] retain] autorelease];
		NSMutableArray *deletedEvents=(NSMutableArray*)[taskmanager.currentSetting.deletedICalEvents componentsSeparatedByString:@"|"];
        if (deletedEvents.count>1) {
            for (NSInteger i=1;i<deletedEvents.count;i++) {
                [self deleteEventOnICal:[deletedEvents objectAtIndex:i] deleteREType:ALL_SERIRES eventStore:self.eventsStore];
            }
        }
		
		taskmanager.currentSetting.deletedICalEvents=@"";
		[taskmanager.currentSetting update];
		
		//self.iCalCalendarsList=self.eventsStore.calendars;
		[self.iCalCalendarsList removeAllObjects];
		[self.iCalCalendarsList addObjectsFromArray:[self.eventsStore calendarsForEntityType:EKEntityTypeEvent]];
		
		Projects *originalCalendar=[App_Delegate calendarWithPrimaryKey:obj.originalCalendarId];
		
		Projects *newCal=[App_Delegate calendarWithPrimaryKey:obj.event.taskProject];
		
		if (originalCalendar.primaryKey==newCal.primaryKey || !originalCalendar) {
			//calendar was not changed
			if ([obj.event.iCalIdentifier length]>0) {
				
				//has synced before
				EKEvent *icalEvent=[self.eventsStore eventWithIdentifier:obj.event.iCalIdentifier];
				if (icalEvent) {
					
					//found, update it
					[self updateICaEvent:icalEvent fromLocalEvent:obj.event updateType:ALL_SERIRES eventStore:self.eventsStore];
					
				}else {
					//was deleted on iPad Cal, re-create it
					[self createNewEventToICal:obj.event updateREType:obj.updateType eventStore:self.eventsStore];
				}
			}else {
				//new event, add to iPad Cal if mapped
				if (obj.event.parentRepeatInstance>0) {
					//exception of RE
					Task *rootRE=nil;
					NSMutableArray *localSource=[NSMutableArray arrayWithArray:taskmanager.taskList];
					for (Task *task in localSource) {
						if (task.primaryKey==obj.event.parentRepeatInstance) {
							rootRE=task;
							break;
						}
					}
					
					if (rootRE) {
						EKEvent *rootICalRE=[self.eventsStore eventWithIdentifier:rootRE.iCalIdentifier];
						if (rootICalRE) {
							//[self updateICaEvent:rootICalRE fromLocalEvent:obj.event updateType:THIS_ONLY];
							//obj.event.iCalIdentifier=rootRE.iCalIdentifier;
							//[obj.event update];
							
							//NSMutableArray *iCalEvents=(NSMutableArray*)[self getICalEventsWithCalendars:self.iCalCalendarsList];
							NSMutableArray *iCalCals=[NSMutableArray arrayWithArray:[self.eventsStore calendarsForEntityType:EKEntityTypeEvent]];
							Projects *localCal=[App_Delegate calendarWithPrimaryKey:obj.event.taskProject];
							EKCalendar *remoteCal=nil;
							for (EKCalendar *ical in iCalCals) {
								if ([ical.title isEqualToString:localCal.projName]) {
									remoteCal=ical;
									break;
								}
							}
							
							//NSMutableArray *iCalEvents=(NSMutableArray*)[self getICalEventsWithCalendars:[NSArray arrayWithObject:remoteCal]];
							NSMutableArray *iCalEvents=(NSMutableArray*)[self getICalEventsWithCalendars:[NSArray arrayWithObject:remoteCal]];
							for (EKEvent *iE in iCalEvents) {
								if ([iE.eventIdentifier isEqualToString:rootICalRE.eventIdentifier] &&
									[ivoUtility compareDateNoTime:iE.startDate withDate:obj.event.originalExceptionDate]==NSOrderedSame) {
									//printf("\n before: %s",[iE.eventIdentifier UTF8String]);
									[self updateICaEvent:iE fromLocalEvent:obj.event updateType:THIS_ONLY eventStore:self.eventsStore];
									//printf("\n after: %s",[iE.eventIdentifier UTF8String]);
									NSString *exid=[[iE.eventIdentifier copy] autorelease];
									obj.event.iCalIdentifier=exid;
									[obj.event update];
									break;
								}
							}
						}
					}
				}else {
					if ([newCal.iCalIdentifier length]>0) {
						[self createNewEventToICal:obj.event updateREType:obj.updateType eventStore:self.eventsStore];
					}
				}
			}
		}else {
			//calendar changed
			
			
			if ([originalCalendar.iCalIdentifier length]>0) {
				//remove this event out of current calendar on iPad
				if ([obj.event.iCalIdentifier length]>0) {
					[self deleteEventOnICal:obj.event.iCalIdentifier deleteREType:obj.updateType eventStore:self.eventsStore];
				}
			}
			
			if ([newCal.iCalIdentifier length]>0) {
				//new event, add to iPad Cal
				[self createNewEventToICal:obj.event updateREType:obj.updateType eventStore:self.eventsStore];
			}
		}
		
		//[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        App_Delegate.me.networkActivityIndicatorVisible=NO;
        
		//[eventStore release];
		isSyncing=NO;
		[timer invalidate];
		timer=nil;
	}
}

-(void)oneWayDeleteEvent:(Task *)event withType:(NSInteger)deleteType{
	if (taskmanager.currentSetting.autoICalSync==0) return;
	if ([event.iCalIdentifier length]==0 && [taskmanager.currentSetting.deletedICalEvents length]==0) return;
    
    //[self.eventsStore refreshSourcesIfNecessary];
	EKOneWaySyncObject *obj=[[EKOneWaySyncObject alloc] init];
	obj.event=event;
	obj.updateType=deleteType;
	[self performSelectorInBackground:@selector(oneWaySyncDelete:) withObject:obj];
	[obj release];
}

-(void)oneWaySyncDelete:(EKOneWaySyncObject*)obj{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	//[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(waitToOneWayDelete:) userInfo:obj repeats:YES];
	[[NSRunLoop currentRunLoop] run];
	[pool release];		
}

-(void)waitToOneWayDelete:(id)sender{
	NSTimer *timer=sender;
	
	if (!isSyncing) {
        //[self.eventsStore commit:nil];
        //[self.eventsStore reset];
        
		isSyncing=YES;
		needSkipDelete=YES;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

		EKOneWaySyncObject *obj=[timer userInfo];
		//EKEventStore *eventStore=[[EKEventStore alloc] init];
		Projects *cal=[App_Delegate calendarWithPrimaryKey:obj.event.taskProject];

		NSMutableArray *deletedEvents=(NSMutableArray*)[taskmanager.currentSetting.deletedICalEvents componentsSeparatedByString:@"|"];
        if (deletedEvents.count>1) {
		for (NSInteger i=1;i<deletedEvents.count;i++) {
			[self deleteEventOnICal:[deletedEvents objectAtIndex:i] deleteREType:ALL_SERIRES eventStore:self.eventsStore];
		}
		}
        
		taskmanager.currentSetting.deletedICalEvents=@"";
		[taskmanager.currentSetting update];
		
		[self.iCalCalendarsList removeAllObjects];
		[self.iCalCalendarsList addObjectsFromArray:[self.eventsStore calendarsForEntityType:EKEntityTypeEvent]];
		
		//don't sync if the calendar is not mapped
		if ([cal.iCalIdentifier length]==0){
			goto endSync;
		}
		
		
		[self deleteEventOnICal:obj.event.iCalIdentifier deleteREType:obj.updateType eventStore:self.eventsStore];
		
	endSync:
		//[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        App_Delegate.me.networkActivityIndicatorVisible=NO;
        
		isSyncing=NO;
		[timer invalidate];
		timer=nil;
	}
}

-(void)closeSuccesAlert:(id)sender{
	[alertview dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	
}
 
///
-(void)oneWayDeleteICals{
	if (taskmanager.currentSetting.autoICalSync==0) return;
	[self performSelectorInBackground:@selector(oneWaySyncDeleteICal:) withObject:nil];
}

-(void)oneWaySyncDeleteICal:(id)sender{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	//[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
    //[self.eventsStore refreshSourcesIfNecessary];
    
	[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(waitToOneWayDeleteICal:) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] run];
	[pool release];		
}

-(void)waitToOneWayDeleteICal:(id)sender{
	NSTimer *timer=sender;
	
	if (!isSyncing) {
        
        //[self.eventsStore commit:nil];
        //[self.eventsStore reset];
        
		isSyncing=YES;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

		NSMutableArray *deletedCals=[NSMutableArray arrayWithArray:[taskmanager.currentSetting.deletedICalCalendars componentsSeparatedByString:@"|"]];
        
        [self.iCalCalendarsList removeAllObjects];
		[self.iCalCalendarsList addObjectsFromArray:[self.eventsStore calendarsForEntityType:EKEntityTypeEvent]];
        
		for (NSString *iCalId in deletedCals) {
            //printf("\n- %s",[iCalId UTF8String]);
			for (EKCalendar *iCal in self.iCalCalendarsList) {
                //printf("\n-- %s",[iCal.calendarIdentifier UTF8String]);
                if ([iCal.calendarIdentifier isEqualToString:iCalId]) {
                    NSError *error=nil;
                    [self.eventsStore removeCalendar:iCal commit:YES error:&error];
                    if (error) {
                        printf("\n remove error: %s",[error.description UTF8String]);
                    }
                    break;
                }
            }
		}
        
        App_Delegate.me.networkActivityIndicatorVisible=NO;
        
		isSyncing=NO;
		[timer invalidate];
		timer=nil;
	}
}

@end
