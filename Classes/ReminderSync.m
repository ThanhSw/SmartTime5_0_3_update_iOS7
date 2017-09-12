//
//  ReminderSync.m
//  SmartTime
//
//  Created by NangLe_MPro on 1/16/13.
//
//

#import "ReminderSync.h"
#import "IvoCommon.h"
#import "ivo_Utilities.h"
#import "TaskManager.h"
#import "Task.h"
#import "Setting.h"
#import "Projects.h"
#import "EKSync.h"
#import "SmartViewController.h"
#import "SmartTimeAppDelegate.h"

////
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
////


@implementation ReminderSync
@synthesize fromDate;
@synthesize toDate;
@synthesize errorTitle;
@synthesize rootViewController;

-(id)init{
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"6.0"]==NSOrderedAscending) return nil;
    
	if (self=[super init]) {
        
        
        [self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted,NSError *error){
            
            if (error) {
                printf("\n error:%s",[[error description] UTF8String]);
            }
        }];
        
	}
	
	return self;
}

-(EKEventStore*)eventStore{
    
    static EKEventStore *rmdrStore=nil;
    if (!rmdrStore) {
        rmdrStore=[[EKEventStore alloc] init];
    }
    
    return rmdrStore;
}

-(void)handleError:(NSError*)error errorMessage:(NSString*)errorMessage{
    if (!isError) {
        totalSync--;

        isError=YES;
        NSString *msg=errorMessage?errorMessage:[error localizedDescription];
        
        [self performSelectorOnMainThread:@selector(showErrorMessage:) withObject:msg waitUntilDone:YES];
    }
}

-(void)showErrorMessage:(id)sender{
    NSString *errorMessage=(NSString*)sender;
    
    UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@""
                                                      message:(errorMessage?errorMessage:@"")
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"okText", @"")
                                            otherButtonTitles:nil];
    [alertView show];
}

-(NSMutableArray *)getICalRemindersFromCalendars:(NSArray *)calendars{
	// Create the predicate.
    
	NSPredicate *predicate = [self.eventStore predicateForRemindersInCalendars:calendars];
	
    NSMutableArray *reminders=[[NSMutableArray alloc] init];
	// Fetch all events that match the predicate.
    [self.eventStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray *array){
        [reminders addObjectsFromArray:array];
    }];
    
    [[NSRunLoop currentRunLoop] run];
    
	return reminders;
}

#pragma mark update Event infor

-(void)updateLocalReminderInfo:(Task*)localRemdr fromRemoteReminder:(EKReminder*)remoteRemdr{
    
	localRemdr.taskName=remoteRemdr.title;
	localRemdr.taskLocation=(remoteRemdr.location?remoteRemdr.location:@"");
    localRemdr.taskDescription=(remoteRemdr.hasNotes?remoteRemdr.notes:@"");
    
    if (remoteRemdr.completed) {
        localRemdr.taskCompleted=1;
        localRemdr.taskDateUpdate=remoteRemdr.completionDate;
    }
    
    NSDateComponents *comp=remoteRemdr.startDateComponents;
    
    localRemdr.taskStartTime=[ivoUtility resetDate:[NSDate date]
                     year:[comp year]
                    month:[comp month]
                      day:[comp day]
                     hour:[comp hour]
                   minute:[comp minute]
                  sencond:0];
    
    comp=remoteRemdr.dueDateComponents;
    
    if (comp) {
        localRemdr.taskIsUseDeadLine=1;
        localRemdr.taskDeadLine=[ivoUtility resetDate:[NSDate date]
                                                 year:[comp year]
                                                month:[comp month]
                                                  day:[comp day]
                                                 hour:[comp hour]
                                               minute:[comp minute]
                                              sencond:0];
        
    }else{
        localRemdr.taskIsUseDeadLine=0;
    }
    
    
    localRemdr.reminderIdentifier=remoteRemdr.calendarItemIdentifier;
    
	localRemdr.taskPinned=0;
    
    
	NSMutableArray *sourceList=[NSMutableArray arrayWithArray:projectList];
    NSString *calId=remoteRemdr.calendar.calendarIdentifier;
    for (Projects *cal in sourceList) {
        if ([cal.reminderIdentifier isEqualToString:calId]) {
            localRemdr.taskProject=cal.primaryKey;
            localRemdr.isHidden=cal.inVisible;
            break;
        }
    }
}

-(void)updateRemotReminderInfo:(EKReminder *)remoteRemdr fromLocalEvent:(Task *)localRemdr{
	remoteRemdr.title = localRemdr.taskName;
	remoteRemdr.location = localRemdr.taskLocation;
	remoteRemdr.notes = localRemdr.taskDescription;
    
    remoteRemdr.completed=localRemdr.taskCompleted;
    if (localRemdr.taskCompleted==1) {
        remoteRemdr.completionDate=localRemdr.taskDateUpdate;
    }else{
        remoteRemdr.completionDate=nil;
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *dayComponents =[gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:localRemdr.taskStartTime];
    remoteRemdr.startDateComponents=dayComponents;
    
    if (localRemdr.taskIsUseDeadLine) {
        NSDateComponents *dayComponents =[gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:localRemdr.taskDeadLine];
        remoteRemdr.dueDateComponents=dayComponents;
    }else{
        remoteRemdr.dueDateComponents=nil;
    }
    
	Projects *calendar=[taskmanager projectWithPrimaryKey:localRemdr.taskProject];
    remoteRemdr.calendar=[self.eventStore calendarWithIdentifier:calendar.reminderIdentifier];
        
}

#pragma mark Add/Update remote events

-(BOOL)addNewReminderToICal:(Task*)reminder{
	
    NSError *err=nil;
	BOOL ret=NO;
    
    EKReminder *remoteReminder=[EKReminder reminderWithEventStore:self.eventStore];
    
    [self updateRemotReminderInfo:remoteReminder fromLocalEvent:reminder];
    
    ret=[self.eventStore saveReminder:remoteReminder commit:YES error:&err];
    
    if (ret) {//update the reminderIdentifier for the new event
        reminder.reminderIdentifier=remoteReminder.calendarItemIdentifier;
        [reminder update];
    }
    
	return ret;
}

-(BOOL)updateRemoteReminder:(EKReminder*)remoteReminder fromLocalEvent:(Task*)localReminder{
    
    EKReminder *rmtReminder=nil;
    
    BOOL ret=NO;
    
    rmtReminder=(EKReminder*)[self.eventStore calendarItemWithIdentifier:remoteReminder.calendarItemIdentifier];
    
    if (rmtReminder) {
        ret=YES;
    }
    
    if (ret) {
        NSError *err=nil;
        
        [self updateRemotReminderInfo:rmtReminder fromLocalEvent:localReminder];
        
        [self.eventStore saveReminder:rmtReminder commit:YES error:&err];
        
        if (ret) {
            localReminder.reminderIdentifier=rmtReminder.calendarItemIdentifier;
            [localReminder update];
        }
        
    }
    
    return ret;
}

#pragma mark Full Sync

-(void)backgroundFullSync{
    
	if ([[[UIDevice currentDevice] systemVersion] compare:@"6.0"]==NSOrderedAscending) return;
    
	if(taskmanager.currentSetting.enabledReminderSync==0 ) return;
    
	[self performSelectorInBackground:@selector(syncCalendarsAndTasks) withObject:nil];
    
}

-(void)syncCalendarsAndTasks{

    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        isError=NO;
    isSyncing=YES;
    totalSync++;

        [self syncCalendars];
        [self fullSyncTasks];
    
    isSyncing=NO;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    [pool release];
}

-(void)syncCalendars{
    
    //[self.eventStore reset];
    
    NSMutableArray *localList;
    NSMutableArray *remoteList;
    
    NSArray *delCalArr=[taskmanager.currentSetting.deletedReminderLists componentsSeparatedByString:@"|"];
    remoteList=[NSMutableArray arrayWithArray:[self.eventStore calendarsForEntityType:EKEntityTypeReminder]];
    
    for (NSString *calid in delCalArr) {
        if ([calid length]>0) {
            for(EKCalendar *ical in remoteList){
                if ([ical.calendarIdentifier isEqualToString:calid]) {
                    EKCalendar *rmtCal=ical;
                    NSString *rmtCalID=[ical.calendarIdentifier copy];
                    
                    if (![rmtCal refresh]) {
                        rmtCal=[self.eventStore calendarWithIdentifier:rmtCalID];
                    }
                    
                    if(rmtCal){
                        if([self.eventStore removeCalendar:rmtCal commit:YES error:nil]){
                            taskmanager.currentSetting.deletedReminderLists=[taskmanager.currentSetting.deletedReminderLists stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"|%@",calid] withString:@""];
                        }
                    }
                    
                    goto nextCheck;
                }
            }
            
            taskmanager.currentSetting.deletedReminderLists=[taskmanager.currentSetting.deletedReminderLists stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"|%@",calid] withString:@""                        ];
        nextCheck:{}
        }
        
    }
    
    NSMutableArray *localCalList=[NSMutableArray arrayWithArray:projectList];
    NSMutableArray *iCalCalList=[NSMutableArray arrayWithArray:[self.eventStore calendarsForEntityType:EKEntityTypeReminder]];
    
    //For the calendar, which is synced between local and iOS calendar, will change title to be the same to CalPad's
    NSMutableArray *localCalendars=[NSMutableArray arrayWithArray:localCalList];
    for (Projects *localCal in localCalendars) {
        if ([localCal.reminderIdentifier length]>0) {
            remoteList=[NSMutableArray arrayWithArray:iCalCalList];
            
            for (EKCalendar *remoteCal in remoteList) {
                if ([remoteCal.calendarIdentifier isEqualToString:localCal.reminderIdentifier]) {
                    /*
                    EKCalendar *rmtCal=remoteCal;
                    NSString *rmtCalID=[remoteCal.calendarIdentifier copy];
                    
                    if (![rmtCal refresh]) {
                        rmtCal=[self.eventStore calendarWithIdentifier:rmtCalID];
                    }
                    
                    if(rmtCal){
                        rmtCal.title=localCal.projName;
                        [self.eventStore saveCalendar:rmtCal commit:YES error:nil];
                        [localCal update];
                    }
                    */
                    localCal.projName=remoteCal.title;
                    [localCal update];
                    
                    [iCalCalList removeObject:remoteCal];
                    [localCalList removeObject:localCal];
                    
                    break;
                }
            }
        }
    }
    
    //auto map
    localList=[NSMutableArray arrayWithArray:localCalList];
    remoteList=[NSMutableArray arrayWithArray:iCalCalList];
    
    //link the calendars which have the same name on iPhone Calendar and SO
    for (EKCalendar *iCalCal in remoteList) {
        NSString *iCalName=[[iCalCal.title uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (!iCalName || [iCalName length]==0) {
            [iCalCalList removeObject:iCalCal];
            continue;
        }
        
        localList=[NSMutableArray arrayWithArray:localCalList];
        for (Projects *cal in localList) {
            NSString *calName=[[cal.projName uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
            if ([iCalName isEqualToString:calName]) {
                //New, link it
                cal.reminderIdentifier=iCalCal.calendarIdentifier;
                [cal update];
                [iCalCalList removeObject:iCalCal];
                [localCalList removeObject:cal];
                break;
            }
        }
    }

    //now we have two rest list
    
    //Create the new calendars come from remote calendar, which is not existed on local
    remoteList=[NSMutableArray arrayWithArray:iCalCalList];
    
    for (EKCalendar *remoteCal in remoteList) {
        
        EKCalendar *rmtCal=remoteCal;
        NSString *rmtCalID=[remoteCal.calendarIdentifier copy];
        
        if (![rmtCal refresh]) {
            rmtCal=[self.eventStore calendarWithIdentifier:rmtCalID];
        }
        
        if(rmtCal){
            Projects *cal=[[Projects alloc] init];
            cal.projName=rmtCal.title;
            cal.reminderIdentifier=rmtCal.calendarIdentifier;
            cal.colorId=(arc4random() %8);
			cal.groupId=(arc4random() %4);;
			cal.enableICalSync=1;
			cal.enableTDSync=0;
			[taskmanager addCalendarToCalendarList:cal];
        }
    }
    
    
    localList=[NSMutableArray arrayWithArray:localCalList];
    for (Projects *localCal in localList) {
        
        if ([localCal.reminderIdentifier length]>0) {
            
            EKReminder *remoteReminder=(EKReminder*)[self.eventStore calendarItemWithIdentifier:localCal.reminderIdentifier];
            
            if (!remoteReminder) {
                 
                NSMutableArray *arr=[NSMutableArray arrayWithArray:taskmanager.taskList];
                for (Task *task in arr) {
                    if (task.taskProject==localCal.primaryKey) {
                        [task deleteFromDatabase];
                        
                        if (task.toodledoID>0) {
                            taskmanager.currentSetting.toodledoDeletedTasks=[taskmanager.currentSetting.toodledoDeletedTasks stringByAppendingFormat:@"|%ld",(long)task.toodledoID];
                        }
                        
                        [taskmanager.taskList removeObject:task];
                        
                    }
                }
                
                if (localCal.toodledoFolderKey>0) {
                    taskmanager.currentSetting.toodledoDeletedFolders=[taskmanager.currentSetting.toodledoDeletedFolders stringByAppendingFormat:@"|%d",localCal.toodledoFolderKey];
                }
                
                [localCal deleteFromDatabase];
                
                [projectList removeObject:localCal];
            }
            
        }else{// this is new calendar created on local, add to iOS Cal
            EKCalendar *remoteCal=[EKCalendar calendarForEntityType:EKEntityTypeReminder eventStore:self.eventStore];
            BOOL hasLocalSource=NO;
            NSArray *sources=[NSArray arrayWithArray:self.eventStore.sources];
            
            for(EKSource *source in sources){
                if ((source.sourceType==EKSourceTypeCalDAV &&
                     ![[source.title uppercaseString] isEqualToString:@"GMAIL"])){
                    remoteCal.source=source;
                    hasLocalSource=YES;
                    
                    remoteCal.title=localCal.projName;
                    NSError *error=nil;
                    BOOL ret=[self.eventStore saveCalendar:remoteCal commit:YES error:&error];
                    if(ret){
                        localCal.reminderIdentifier=remoteCal.calendarIdentifier;
                        [localCal update];
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
                        
                        remoteCal.title=localCal.projName;
                        NSError *error=nil;
                        BOOL ret=[self.eventStore saveCalendar:remoteCal commit:YES error:&error];
                        if(ret){
                            localCal.reminderIdentifier=remoteCal.calendarIdentifier;
                            [localCal update];
                        }else {
                            hasLocalSource=NO;
                        }
                        
                        break;
                    }
                }
                
            }
            
            if (!hasLocalSource) {
                EKCalendar *defaultRemoteCal=[self.eventStore defaultCalendarForNewEvents];
                if (defaultRemoteCal) {
                    remoteCal.source=defaultRemoteCal.source;
                    
                    remoteCal.title=localCal.projName;
                    NSError *error=nil;
                    BOOL ret=[self.eventStore saveCalendar:remoteCal commit:YES error:&error];
                    if(ret){
                        localCal.reminderIdentifier=remoteCal.calendarIdentifier;
                        [localCal update];
                    }else {
                        
                    }
                }
            }
        }
    }
    
    //[dataManager.currentSetting dehydrate];
}

-(void)fullSyncTasks{
    if (isError){
        return;
    }
    
    //[App_Delegate getTaskList];
    NSMutableArray *dataList=[NSMutableArray arrayWithArray:taskmanager.taskList];
    
    [App_Delegate addHiddenTasksEventsToList:dataList];
    
    NSMutableArray *completedArr=[App_Delegate createFullDoneTaskList];
    
    [dataList addObjectsFromArray:completedArr];
    
    
    NSMutableArray *localTasksList=[NSMutableArray arrayWithArray:[App_Delegate getAllTasksFromList:dataList]];
	
    //[self.eventStore reset];
    
    NSPredicate *predicate = [self.eventStore predicateForRemindersInCalendars:[self.eventStore calendarsForEntityType:EKEntityTypeReminder]];
    
    // Fetch all events that match the predicate.
    [self.eventStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray *array){
        NSMutableArray *remoteTasksList=[[NSMutableArray alloc] init];
        [remoteTasksList addObjectsFromArray:array];
        
        NSMutableArray *remoteList;
        
        //delete the synced events on iOS Cal, which had been deleted on local
        NSMutableArray *deletedTasks=[NSMutableArray arrayWithArray:[taskmanager.currentSetting.deletedReminders componentsSeparatedByString:@"|"]];
        for (NSString *delID in deletedTasks) {
            if ([delID length]>0) {
                
                remoteList=[NSMutableArray arrayWithArray:remoteTasksList];
                
                for (EKReminder *remoteReminder in remoteList) {
                    if ([remoteReminder.calendarItemIdentifier isEqualToString:delID]) {
                        if([self.eventStore removeReminder:remoteReminder commit:YES error:nil]){
                            taskmanager.currentSetting.deletedReminders=[taskmanager.currentSetting.deletedReminders stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"|%@",delID] withString:@""];
                        }
                        
                        [remoteTasksList removeObject:remoteReminder];
                        goto nextCheck;
                    }
                }
                
                taskmanager.currentSetting.deletedReminders=[taskmanager.currentSetting.deletedReminders stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"|%@",delID] withString:@""];
                
            nextCheck:{}
                
            }
        }
        
        //////////////////////////////////////////////
        // perform update the current synced events //
        //////////////////////////////////////////////
        
        NSMutableArray *localList=[NSMutableArray arrayWithArray:localTasksList];
        
        localList=[NSMutableArray arrayWithArray:localTasksList];
        
        for (Task *localReminder in localList) {
            if ([localReminder.reminderIdentifier length]>0 || (localReminder.parentRepeatInstance<1)){
                NSMutableArray *remoteList=[NSMutableArray arrayWithArray:remoteTasksList];
                for (EKReminder *remoteReminder in remoteList) {
                    if (([localReminder.reminderIdentifier length]>0 && [localReminder.reminderIdentifier isEqualToString:remoteReminder.calendarItemIdentifier])) {
                        
                        if ([localReminder.taskDateUpdate compare:remoteReminder.lastModifiedDate]==NSOrderedDescending) {
                            [self updateRemoteReminder:remoteReminder fromLocalEvent:localReminder];
                        }else{
                            [self updateLocalReminderInfo:localReminder fromRemoteReminder:remoteReminder];
                            [localReminder update];
                        }
                        
                        [localTasksList removeObject:localReminder];
                        [remoteTasksList removeObject:remoteReminder];
                        break;
                    }
                }
            }
        }
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        //now we have two rest lists                                                                      //
        //Remove events on local for the events that synced with iOS Cal and were deleted on iOS Cal,   //
        //or resync exceptions to iOS Cal if they are validated on iOS Cal because of update from local //
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        
        for (Task *localReminder in localTasksList) {
            if ([localReminder.reminderIdentifier length]>0) {
                //EKReminder *remoteReminder=(EKReminder*)[self.eventStore calendarItemWithIdentifier:localReminder.reminderIdentifier];
                
                //if (!remoteReminder) {
                    
                    if (localReminder.toodledoID>0) {
                        taskmanager.currentSetting.toodledoDeletedTasks=[taskmanager.currentSetting.toodledoDeletedTasks stringByAppendingFormat:@"|%ld",(long)localReminder.toodledoID];
                    }
                    
                    if ([localReminder.iCalIdentifier length]>0) {
                        taskmanager.currentSetting.deletedICalEvents=[taskmanager.currentSetting.deletedICalEvents stringByAppendingFormat:@"|%@",localReminder.iCalIdentifier];
                    }
                    
                    [localReminder deleteFromDatabase];
                    [taskmanager.taskList removeObject:localReminder];
                    
                //}else{
                    /*
                    if ([localReminder.taskDateUpdate compare:remoteReminder.lastModifiedDate]==NSOrderedDescending) {
                        [self updateRemoteReminder:remoteReminder fromLocalEvent:localReminder];
                    }else{
                        [self updateLocalReminderInfo:localReminder fromRemoteReminder:remoteReminder];
                        [localReminder update];
                    }
                     */
                //}
            }else {
                //new event
                [self addNewReminderToICal:localReminder];
            }
        }
        
        
        ///////////////////////////////////////////////////////////////
        // add new events from the rest iOS data list to local //
        ///////////////////////////////////////////////////////////////
        
        remoteList=[NSMutableArray arrayWithArray:remoteTasksList];
        
        for (EKReminder *remoteReminder in remoteList) {
			Task *localTask=[[Task alloc] init];
			localTask.taskPinned=0;
			[self updateLocalReminderInfo:localTask fromRemoteReminder:remoteReminder];
            
            [localTask prepareNewRecordIntoDatabase:database];
            [localTask update];
            
            if (!localTask.isHidden) {
                [taskmanager.taskList addObject:localTask];
            }
        }
        
        NSMutableArray *sourceList=[NSMutableArray arrayWithArray:taskmanager.taskList];
		[taskmanager updateLocalNotificationForList:sourceList];
		
        totalSync--;
		//[self.rootViewController startRefreshTasks];
        if (totalSync<=0) {
            //[self.rootViewController startRefreshTasks];
            [self.rootViewController performSelectorOnMainThread:@selector(startRefreshTasks) withObject:nil waitUntilDone:NO];
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
    [[NSRunLoop currentRunLoop] run];
}

#pragma mark 1-Way add events
-(void)oneWayAddReminderToICal:(Task*)localReminder{
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"6.0"]==NSOrderedAscending) return;
    
    Projects *cal=[taskmanager projectWithPrimaryKey:localReminder.taskProject];
    
    if ([cal.reminderIdentifier length]==0 ) return;
    
    [self performSelectorInBackground:@selector(performAddReminderToICal:) withObject:localReminder];
}

-(void)performAddReminderToICal:(id)sender{
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        //[self.eventStore reset];
        
        Task *localReminder=(Task*)sender;
        
        [self addNewReminderToICal:localReminder];
        
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [pool release];
}

#pragma mark 1-Way update event
-(void)oneWayUpdateReminder:(Task*)localReminder{
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"6.0"]==NSOrderedAscending) return;
    
    Projects *cal=[taskmanager projectWithPrimaryKey:localReminder.taskProject];
    
	if ([cal.reminderIdentifier length]==0) return;
    
	[self performSelectorInBackground:@selector(performOneWayUpdate:) withObject:localReminder];
}

-(void)performOneWayUpdate:(Task*)object{
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
        
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
        //[self.eventStore reset];
        
        Task *localReminder=object;
        
        if ([localReminder.reminderIdentifier length]>0) {
            
            EKReminder *remoteReminder=(EKReminder*)[self.eventStore calendarItemWithIdentifier:localReminder.reminderIdentifier];
            if (remoteReminder) {
                [self updateRemoteReminder:remoteReminder fromLocalEvent:localReminder];
            }
            
        }
        
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    
    [pool release];
    
}

#pragma mark 1-Way delete event
-(void)oneWayDeleteReminders{
	
    if ([[[UIDevice currentDevice] systemVersion] compare:@"6.0"]==NSOrderedAscending) return;
    
	[self performSelectorInBackground:@selector(performOneWaySyncDeleteReminders) withObject:nil];
	
}

-(void)performOneWaySyncDeleteReminders{
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
        //[self.eventStore reset];
        
        NSMutableArray *deletedReminders=[NSMutableArray arrayWithArray:[taskmanager.currentSetting.deletedReminders componentsSeparatedByString:@"|"]];
        
        for (NSString *delID in deletedReminders) {
            if ([delID length]>0) {
                
                EKReminder *remoteReminder=(EKReminder*)[self.eventStore calendarItemWithIdentifier:delID];
                
                if (remoteReminder) {
                    if([self.eventStore removeReminder:remoteReminder commit:YES error:nil]){
                        taskmanager.currentSetting.deletedReminders=[taskmanager.currentSetting.deletedReminders stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"|%@",delID] withString:@""];
                    }
                }else{
                    taskmanager.currentSetting.deletedReminders=[taskmanager.currentSetting.deletedReminders stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"|%@",delID] withString:@""];
                }
            }
        }
        
        [taskmanager.currentSetting update];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [pool release];
}

#pragma mark one way delete calendar
-(void)oneWayDeleteCalendars{
    if ([[[UIDevice currentDevice] systemVersion] compare:@"6.0"]==NSOrderedAscending) return;
    
	[self performSelectorInBackground:@selector(performOneWayDeleteCalendars:) withObject:nil];
}

-(void)performOneWayDeleteCalendars:(id)sender{
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        //[self.eventStore reset];
        
        NSMutableArray *remoteList;
        NSArray *delCalArr=[taskmanager.currentSetting.deletedReminderLists componentsSeparatedByString:@"|"];
        for (NSString *calid in delCalArr) {
            if ([calid length]>0) {
                remoteList=[NSMutableArray arrayWithArray:[self.eventStore calendarsForEntityType:EKEntityTypeReminder]];
                for(EKCalendar *ical in remoteList){
                    if ([ical.calendarIdentifier isEqualToString:calid]) {
                        EKCalendar *rmtCal=ical;
                        NSString *rmtCalID=[ical.calendarIdentifier copy];
                        
                        if (![rmtCal refresh]) {
                            rmtCal=[self.eventStore calendarWithIdentifier:rmtCalID];
                        }
                        
                        if(rmtCal){
                            if([self.eventStore removeCalendar:rmtCal commit:YES error:nil]){
                                taskmanager.currentSetting.deletedReminderLists=[taskmanager.currentSetting.deletedReminderLists stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"|%@",calid] withString:@""];
                            }
                        }
                        
                        
                        goto nextCheck;
                    }
                }
                
                taskmanager.currentSetting.deletedReminderLists=[taskmanager.currentSetting.deletedReminderLists stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"|%@",calid] withString:@""                        ];
            nextCheck:{}
            }
        }
        
        [taskmanager.currentSetting update];
        
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [pool release];
}

-(void)oneWayAddCalendar:(Projects*)cal{
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"6.0"]==NSOrderedAscending) return;
    
	[self performSelectorInBackground:@selector(performOneWayAddCalendars:) withObject:cal];
}

-(void)performOneWayAddCalendars:(id)sender{
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        Projects *cal=(Projects*)sender;
        
        //[self.eventStore reset];
        
        EKCalendar *iCal=[EKCalendar calendarForEntityType:EKEntityTypeReminder eventStore:self.eventStore];
        
        NSArray *sources=[NSArray arrayWithArray:self.eventStore.sources];
        for(EKSource *source in sources){
            if (source.sourceType==EKSourceTypeLocal){
                iCal.source=source;
                break;
            }
        }
        
        iCal.title=cal.projName;
        
        NSError *error=nil;
        BOOL ret=[self.eventStore saveCalendar:iCal commit:YES error:nil];
        if(ret){
            cal.reminderIdentifier=iCal.calendarIdentifier;
            [cal update];
        }else {
            [self handleError:error errorMessage:nil];
        }
        
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [pool release];
    
}

///
-(void)oneWayUpdateCalendar:(Projects*)cal{
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"6.0"]==NSOrderedAscending) return;
    
    if ([cal.reminderIdentifier length]==0) return;
    
	[self performSelectorInBackground:@selector(performOneWayUpdateCalendar:) withObject:cal];
}

-(void)performOneWayUpdateCalendar:(id)sender{
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        Projects *cal=(Projects*)sender;
        
        //[self.eventStore reset];
        
        EKCalendar *remoteCal=[self.eventStore calendarWithIdentifier:cal.reminderIdentifier];
        if (remoteCal) {
            if (![remoteCal.title isEqualToString:cal.projName]) {
                remoteCal.title=cal.projName;
                [self.eventStore saveCalendar:remoteCal commit:YES error:nil];
            }
        }
        
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [pool release];
}

@end
