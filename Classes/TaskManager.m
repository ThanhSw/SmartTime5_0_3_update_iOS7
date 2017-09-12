//
//  TaskManager.m
//  iVo_DatabaseAccess
//
//  Created by Nang Le on 4/30/08.
//  Contents replaced by Nang Le
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TaskManager.h"
#import "SmartTimeAppDelegate.h"
#import "IvoCommon.h"
#import "Setting.h"
#import "SmartViewController.h"
#import "CalendarView.h"
#import "DateTimeSlot.h"
#import <Foundation/Foundation.h>
#import "DeletedTEKeys.h"
#import "TaskActionResult.h"
#import "DateAndList.h"
#import "Projects.h"
#import "TimeSlotObject.h"
#import "EKSync.h"
#import "ReminderSync.h"

//extern NSInteger instanceKey;

extern NSMutableArray *projectList;

extern	CalendarView	*_calendarView;
extern	sqlite3			*database;
extern	SmartTimeAppDelegate	*App_Delegate;
//extern	Setting			*currentSetting;
extern  SmartTimeAppDelegate	*App_Delegate;
extern ivo_Utilities	*ivoUtility;
extern NSInteger			dummyKey;
extern NSTimeZone		*App_defaultTimeZone;
extern NSTimeInterval	dstOffset;
extern NSString *dev_token;
extern float OSVersion;
extern NSMutableArray *alertList;

extern BOOL needStopSync;

//---for searching time slots
extern NSInteger homeSettingHourWEStart;
extern NSInteger homeSettingHourWEEnd;

extern NSInteger homeSettingHourNDStart;
extern NSInteger homeSettingHourNDEnd;

extern NSInteger homeSettingMinWEStart;
extern NSInteger homeSettingMinWEEnd;

extern NSInteger homeSettingMinNDStart;
extern NSInteger homeSettingMinNDEnd;

extern NSInteger deskSettingHourWEStart;
extern NSInteger deskSettingHourWEEnd;

extern NSInteger deskSettingHourNDStart;
extern NSInteger deskSettingHourNDEnd;

extern NSInteger deskSettingMinWEStart;
extern NSInteger deskSettingMinWEEnd;

extern NSInteger deskSettingMinNDStart;
extern NSInteger deskSettingMinNDEnd;

// add 900 senconds just try to know if the time range on week end is enough for task with duration 15 minutes or not.
extern NSInteger  homeSettingWEStartInSec;
extern NSInteger  homeSettingWEEndInSec; 

extern NSInteger  deskSettingWEStartInSec; 
extern NSInteger  deskSettingWEEndInSec;

extern NSInteger  numberOfWeekendDays;
extern NSInteger  startWeekendDay;
extern NSInteger endWeekendDay;
//--------

extern double timeInervalForExpandingToFillRE;
NSInteger totalSync=0;

@implementation TaskManager

@synthesize taskList;
//@synthesize quickTaskList;
//@synthesize filterList;
//@synthesize completedTaskList;
//@synthesize taskListBackUp;
@synthesize fullTaskListBackUp;
@synthesize dummiesList;
@synthesize normalTaskList;
@synthesize dTaskList;
@synthesize eventList;
@synthesize adeList;
@synthesize REList;
@synthesize hasFilledDummiesToDate;
@synthesize recentDummiesList;
@synthesize ekSync;
@synthesize reminderSync;

-(id)init{
	if(self=[super init]){
		recentDummiesList=[[NSMutableArray alloc] init];
		
		EKSync *ek=[[EKSync alloc] init];
		self.ekSync=ek;
		[ek release];
        
        ReminderSync *rmdSync=[[ReminderSync alloc] init];
        self.reminderSync=rmdSync;
        [rmdSync release];
	}
	
	return self;
}

-(void)dealloc{
	[taskList release];
	[quickTaskList release];
	[completedTaskList release];
	[filterList release];
	[tmpNewTask release];
	[tmpUpdateTask release];
	[alertView release];
	[filterClause release];
	[filterDoTodayClause release];
	[taskListBackUp release];
	[currentSetting release];
	[currentSettingModifying release];
	[fullTaskListBackUp release];
	[getREUntilDate release];
	[dummiesList release];
	[hasFilledDummiesToDate release];
	[recentDummiesList release];
	
	[super dealloc];
}

-(Projects *)projectWithPrimaryKey:(NSInteger)key{
	Projects *ret;
    
    NSMutableArray *projects=[NSMutableArray arrayWithArray:projectList];
	for (Projects *cal in projects){
		if(cal.primaryKey==key){
			return cal;
			break;
		}
	}
	
	ret=[projects objectAtIndex:0];
	
	return ret;
}

-(NSInteger)getToodledoRepeatTypeForTask:(Task *)task{
	switch (task.taskRepeatID) {
		case 0:
			return 0;
			break;
		case 1:			
			return 4;
			break;
		case 2:
			if ([[task.taskRepeatOptions substringToIndex:1] isEqualToString:@"1"]) {
				return 1;
			}else if ([[task.taskRepeatOptions substringToIndex:1] isEqualToString:@"2"]) {
				return 5;
			}
			return 1;
			break;
		case 3:
			
			if ([[task.taskRepeatOptions substringToIndex:1] isEqualToString:@"2"]) {
				return 6;
			}else if ([[task.taskRepeatOptions substringToIndex:1] isEqualToString:@"6"]) {
				return 7;
			}else if ([[task.taskRepeatOptions substringToIndex:1] isEqualToString:@"3"]) {
				return 8;
			}			
			return 2;
			break;
		case 4:
			return 3;
			break;
	}
	return 0;
}

//update time which is from string format 12:00am, 4:00pm for an existing date
- (NSDate *)updateTimeFromString:(NSString*)string forDate:(NSDate*)date{
	NSDate *ret=[NSDate date];
	NSArray *arr=[string componentsSeparatedByString:@":"];
	if (arr.count>1) {
		NSInteger hour=[[arr objectAtIndex:0] intValue];
		NSInteger min=[[[arr objectAtIndex:1] substringToIndex:[[arr objectAtIndex:1] length]-2] intValue];
		
		NSString *subStr=[string substringFromIndex:[string length]-2];
		if ([[subStr uppercaseString] isEqualToString:@"PM"]) {
			hour+=12;
		}
		
		ret=[ivoUtility resetDate:date 
							year:[ivoUtility getYear:date]
						   month:[ivoUtility getMonth:date]
							 day:[ivoUtility getDay:date]
							hour:hour 
						  minute:min 
						 sencond:0];
	}
	
	return ret;
}

- (void) sortAscTaskListByDate:(NSMutableArray*)list {
	//ILOG(@"[TaskManager sortAscTaskListByDate\n");
	//keep the original task list in another array
	//NSMutableArray* originalTasks=[[NSMutableArray alloc] initWithArray:list]; 
	
	NSSortDescriptor *date_descriptor = [[NSSortDescriptor alloc] initWithKey:@"taskStartTime"  ascending: YES];
	
	NSArray *sortDescriptors = [NSArray arrayWithObject:date_descriptor];
	
	//get the sorted task list based on the original task list 	
	//[list release];
	list= (NSMutableArray *)[list sortedArrayUsingDescriptors:sortDescriptors];
	//[originalTasks release];
	[date_descriptor release];
	
	//ILOG(@"TaskManager sortAscTaskListByDate]\n");
}

- (NSInteger)getIndexOfTaskByPrimaryKey:(Task *)task inArray:(NSMutableArray *)list {
	//ILOG(@"[TaskManager getIndexOfTaskByPrimaryKey\n");
	NSInteger ret=-1;
	
    NSMutableArray *arr=[NSMutableArray arrayWithArray:list];
	Task *taskMember;
	NSInteger i=0;
	for (taskMember in arr){
		if (taskMember.primaryKey==task.primaryKey){
			taskMember=nil;
			//ILOG(@"TaskManager getIndexOfTaskByPrimaryKey]\n");
			ret= i;	
			goto exitFound;
		}
		i++;
	}
	//ILOG(@"TaskManager getIndexOfTaskByPrimaryKey]\n");
exitFound:
	return ret;
}

- (void)markedCompletedTask:(NSInteger)taskKey doneREType:(NSInteger)doneREType{
	//ILOG(@"[TaskManager markedCompletedTask\n");
	
	//NSMutableArray *newList=self.taskList;
	Task *mainInstance=nil;
	BOOL isMainInstance=NO;
	
	Task *tsk=[ivoUtility getTaskByPrimaryKey:taskKey inArray:self.taskList];
	
	if(tsk.primaryKey<-1){ 
		mainInstance=[ivoUtility getTaskByPrimaryKey:tsk.parentRepeatInstance inArray:self.taskList];
	}else {
		mainInstance=tsk;
		isMainInstance=YES;
	}

	if(tsk.taskRepeatID>0 && (tsk.isOneMoreInstance==YES || tsk.primaryKey>-1)){

		NSInteger repeatEvery=[self getRepeatEveryForRE:tsk];
		NSMutableArray *nextDummies=[NSMutableArray array];
		[self fillRepeatEventInstances:[NSArray arrayWithObject:mainInstance] 
								toList:nextDummies
							  fromDate:tsk.taskEndTime
				  getInstanceUntilDate:[tsk.taskEndTime dateByAddingTimeInterval:tsk.taskRepeatID==1?2*86400*repeatEvery:tsk.taskRepeatID==2?(604800+86400)*repeatEvery:tsk.taskRepeatID==3?(2678400+86400)*repeatEvery:(31536000+86400)*repeatEvery] 
				   isShowPastInstances:YES 
					 isCleanOldDummies:NO 
				  isRememberFilledDate:NO
			  isNeedAtLeastOneInstance:YES];

//		if(nextDummies.count==0){
//			[self fillFirstDummyREInstanceToList:self.taskList rootRE:mainInstance];
//		}else {
			[self.taskList addObjectsFromArray:nextDummies];
//		}
		
		[self sortList:self.taskList byKey:@"taskStartTime"];
		
		//[self updateDummiesKeyFromList:[NSMutableArray arrayWithObject:tsk] toList:self.taskList];
		
	}

	NSMutableArray *newList= [[NSMutableArray alloc] initWithArray: self.taskList];

	Task *tmp;
 	for (tmp in newList) {
		if(tmp.primaryKey==taskKey){
			
			//update deleted Item to setting for Syncing
			if(tmp.primaryKey>-1 && tmp.taskRepeatID==0){
				self.currentSetting.deleteItemsInTaskList=[self.currentSetting.deleteItemsInTaskList 
													   stringByAppendingString:[NSString stringWithFormat:@"$!$%d|%f|%@",taskKey,tmp.taskSynKey,tmp.gcalEventId]];
				[self.currentSetting update];
			}
			
			tmp.taskCompleted=1;
			tmp.taskTypeUpdate=1;
			
            if(tmp.taskPinned==1 && tmp.taskRepeatID>0 && tmp.taskNumberInstances!=1){
                switch (doneREType) {
					case 1://done this instance only
						if(isMainInstance){//done main instance
							//NSInteger key=mainInstance.primaryKey;
							//mainInstance.taskRepeatID=0;
							BOOL haveNewMainInstance=NO;
							for (Task *instanceRE in newList){//find the first next instance
								
								if (instanceRE.primaryKey <-1 && instanceRE.parentRepeatInstance==mainInstance.primaryKey){
									
									[recentDummiesList removeObject:instanceRE];
									
									instanceRE.parentRepeatInstance=-1;

									///////
									if(mainInstance.taskRepeatTimes>0){
									repeatCountTime ret=[ivoUtility createRepeatCountFromEndDate:mainInstance.taskREStartTime?mainInstance.taskEndTime:[NSDate date] 
																					  typeRepeat:mainInstance.taskRepeatID 
																						  toDate:mainInstance.taskEndRepeatDate 
																				repeatOptionsStr:mainInstance.taskRepeatOptions
																					 reStartDate:mainInstance.taskREStartTime?mainInstance.taskEndTime:[NSDate date]];
									instanceRE.taskNumberInstances=ret.numberOfInstances;
									instanceRE.taskRepeatTimes=ret.repeatTimes;
									}
									//////
									
									instanceRE.taskRepeatExceptions=[mainInstance.taskRepeatExceptions stringByAppendingFormat:@"|%f",[mainInstance.taskStartTime timeIntervalSince1970]];
									instanceRE.primaryKey=mainInstance.primaryKey;
									[instanceRE update];

									haveNewMainInstance=YES;
									break;
								}
							}
							
							mainInstance.taskRepeatID=0;
							mainInstance.taskSynKey=0;
							mainInstance.gcalEventId=@"";
							mainInstance.taskCompleted=1;
		
							if(haveNewMainInstance)
								mainInstance.primaryKey= [App_Delegate addTask:mainInstance];
							
							self.currentSetting.deleteItemsInTaskList=[self.currentSetting.deleteItemsInTaskList 
                                                                       stringByAppendingString:[NSString stringWithFormat:@"$!$%ld|%f|%@",(long)taskKey,mainInstance.taskSynKey,mainInstance.gcalEventId]];
							[self.currentSetting update];
							
							[mainInstance update];
							
							[self.taskList removeObject:mainInstance];
							
						}else {
							
							
							mainInstance.taskRepeatExceptions=[mainInstance.taskRepeatExceptions stringByAppendingFormat:@"|%f",[tmp.taskStartTime timeIntervalSince1970]];
							[mainInstance update];
							
							tmp.taskSynKey=0;
							tmp.gcalEventId=@"";
							
							[recentDummiesList removeObject:tmp];

							tmp.taskCompleted=1;
							tmp.primaryKey= [App_Delegate addTask:tmp];
							self.currentSetting.deleteItemsInTaskList=[self.currentSetting.deleteItemsInTaskList 
																	   stringByAppendingString:[NSString stringWithFormat:@"$!$%d|%f|%@",taskKey,tmp.taskSynKey,tmp.gcalEventId]];
							[self.currentSetting update];
							
							[self.taskList removeObject:tmp];
						}
						
						break;
					case 2://done all series
						//not implemented now
						break;
					case 3://done following
						//not implemented now
						break;
				}
			}else {
				[tmp update];
				[self.taskList removeObject:tmp];
				
                if (tmp.taskPinned==0 && tmp.taskRepeatID>0) {
                    Task *nextInstance=[self nextDummyForRepeatingTask:tmp];
                    if (nextInstance) {
                        nextInstance.primaryKey=-1;
                        [self addNewTask:nextInstance
                                 toArray:self.taskList
                 isAllowChangeDueWhenAdd:YES];
                     
                    //[self.taskList addObject:nextInstance];
                    }
                }
			}

			NSDate *endDate=[[tmp taskEndTime] copy];
			[self.taskList removeObject:tmp];
			//tmp=nil;
			
//			[App_Delegate getPartTaskList];
			
			if([endDate compare:[NSDate date]]==NSOrderedDescending){
				[self refreshTaskList];
			}
			[endDate release];
			
			//return;
			goto exitMark;
		}
	}

//	//update the order for tasks
//	NSInteger i=1;
//	for (Task *task in self.taskList){
//		if(task.primaryKey>=0){
//			task.taskOrder=i;
//			[task update];
//			i+=1;
//		}
//	}
	
//	[App_Delegate getPartTaskList];
	
exitMark:
	{
		
	}
	[newList release];
	
    if (!needStopSync &&  self.currentSetting.autoICalSync) {
        
        if (self.currentSetting.enableSyncICal ) {
            [self.ekSync backgroundFullSync];
        }

        if (self.currentSetting.enabledReminderSync) {
            [self.reminderSync backgroundFullSync];
        }
        
        
    }
    
//	[App_Delegate stopAcitivityIndicatorThread];
	//ILOG(@"TaskManager markedCompletedTask]\n");
}

-(Task*)nextDummyForRepeatingTask:(Task*)task{
    Task *ret=nil;
    
    if (task.taskPinned==1 || task.taskRepeatID==0) {
        return ret;
    }
	
    if (task.taskRepeatStyle==1) {
        ret=[self nextInstanceOfRecuringTask:task];
        ret.taskCompleted=0;
    }else{
        if (!task.taskIsUseDeadLine) {
            ret=[[[Task alloc] init] autorelease];
            [ivoUtility copyTask:task toTask:ret isIncludedPrimaryKey:YES];
            ret.taskIsUseDeadLine=1;
            ret.taskNotEalierThan=[NSDate date];
            ret.taskCompleted=0;
            
            switch (task.taskRepeatID) {
                case REPEAT_DAILY:
                    ret.taskDeadLine=[ivoUtility newDateFromDate:[NSDate date] offset:86400];   
                    break;
                case REPEAT_WEEKLY:
                    ret.taskDeadLine=[ivoUtility newDateFromDate:[NSDate date] offset:7*86400];   
                    break;
                case REPEAT_MONTHLY:
                    ret.taskDeadLine=[ivoUtility newDateFromDate:[NSDate date] offset:30*86400];   
                    break;
                case REPEAT_YEARLY:
                    ret.taskDeadLine=[ivoUtility newDateFromDate:[NSDate date] offset:365*86400];   
                    break;
            }
        }else{
            //get first instance from current time
            Task *taskTmp=[[[Task alloc] init] autorelease];
            [ivoUtility copyTask:task toTask:taskTmp isIncludedPrimaryKey:YES];
            //[task copy];
            
            while (YES) {
                ret=[self nextInstanceOfRecuringTask:taskTmp];
                if (!ret) {
                    return ret;
                }
                
                if ([ivoUtility compareDateNoTime:ret.taskDeadLine withDate:[NSDate date]]==NSOrderedDescending) {
                    ret.taskCompleted=0;
                    return ret;
                }else{
                    taskTmp.taskDeadLine=ret.taskDeadLine;
                }
            }
        }
    }
    
    return ret;
}

-(Task *)nextInstanceOfRecuringTask:(Task *)task{
	Task *ret=nil;
	
	if(task.taskRepeatID==0) return ret;
	
	//if(task.taskPinned==1 && task.taskRepeatTimes!=0 && [task.taskEndTime compare:task.repeatEndDate]==NSOrderedSame) return ret;
	
	//get repeat options, we need to know the repeat options to get exactly its dummies.
	NSInteger repeatEvery;
	NSInteger repeatBy;
	NSString *repeatOn;
	
	if(task.taskRepeatOptions !=nil && ![task.taskRepeatOptions isEqualToString:@""]){
		NSArray *options=[task.taskRepeatOptions componentsSeparatedByString:@"/"];
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
	
	NSDate *tmp=task.taskDeadLine;
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |NSWeekdayCalendarUnit|NSWeekdayOrdinalCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:tmp];
	NSInteger wd=[ivoUtility getWeekday:tmp];
	NSInteger wdo=[ivoUtility getWeekdayOrdinal:tmp];
	
	while (YES){
		
		switch (task.taskRepeatID) {
			case REPEAT_DAILY://daily
			{
				comps = [gregorian components:unitFlags fromDate:tmp];
				[comps setDay:[comps day]+repeatEvery];
				tmp=[gregorian dateFromComponents:comps];
				
//				if(task.isRepeatForever==0 && [tmp compare:task.repeatEndDate]==NSOrderedDescending) return ret;
				
//				if([self hasExceptionAtDate:tmp forTask:task]) continue;
				
				ret=[self newInstanceForTask:task instanceKey:dummyKey forDate:tmp];
				dummyKey=dummyKey-1;
				
				goto exitWhile;
			}
				break;
				
			case REPEAT_WEEKLY://weekly
			{
				
				//check the options
				if(repeatOn !=nil && ![repeatOn isEqualToString:@""]){
					NSArray *selectDays=[repeatOn componentsSeparatedByString:@"|"];
					NSInteger firstInstanceWeekDay=[ivoUtility getWeekday:tmp];
					NSInteger peakDaysInWeek=0;
					
					comps = [gregorian components:unitFlags fromDate:tmp];
					[comps setDay:[comps day]-(firstInstanceWeekDay-1)];
					tmp=[gregorian dateFromComponents:comps];
					
					NSDate *groupIntancesDate=nil;
					
					NSInteger i=0;
					for (i=0;i<selectDays.count;i++){
						
					beginFor:
						peakDaysInWeek=(NSInteger)[(NSString *)[selectDays objectAtIndex:i] intValue];
						
						comps = [gregorian components:unitFlags fromDate:tmp];
						[comps setDay:[comps day]+(peakDaysInWeek-1)];
						groupIntancesDate=[gregorian dateFromComponents:comps];
						
//						if(task.isRepeatForever==0 && [groupIntancesDate compare:task.repeatEndDate]==NSOrderedDescending) return ret;
						
						if([groupIntancesDate compare:task.taskDeadLine]!=NSOrderedDescending){
							
							//if([groupIntancesDate compare:untilDate]!=NSOrderedAscending){
							//	goto exitWhile;
							//}
							
							i+=1;
							if(i<selectDays.count){
								goto beginFor;
							}else {
								break;
							}
						}
						
//						if([self hasExceptionAtDate:groupIntancesDate forTask:task]) continue;
						
						ret=[self newInstanceForTask:task instanceKey:dummyKey forDate:groupIntancesDate];
						dummyKey=dummyKey-1;
						goto exitWhile;
						
					wContinueLoop:{}
					}
					
					comps = [gregorian components:unitFlags fromDate:tmp];
					[comps setDay:[comps day] + 7*repeatEvery];
					tmp=[gregorian dateFromComponents:comps];
				}else {
					
					[comps setDay:[comps day] + 7*repeatEvery];
					tmp=[gregorian dateFromComponents:comps];
					
//					if(task.isRepeatForever==0 && [tmp compare:task.repeatEndDate]==NSOrderedDescending) return ret;
					
//					if([self hasExceptionAtDate:tmp forTask:task]) continue;
					
					ret=[self newInstanceForTask:task instanceKey:dummyKey forDate:tmp];
					dummyKey=dummyKey-1;
					
					goto exitWhile;
				}
			}
				break;
			case REPEAT_MONTHLY://monthly
			{
				
				[comps setMonth:[comps month]+repeatEvery];
				
				if(repeatBy==0){//weekday
					
				}else {//weekday name
					[comps setWeekday:wd];
					[comps setWeekdayOrdinal:wdo];
				}
				
				tmp= [gregorian dateFromComponents:comps];
				
//				if(task.isRepeatForever==0 && [tmp compare:task.repeatEndDate]==NSOrderedDescending) return ret;
				
//				if([self hasExceptionAtDate:tmp forTask:task]) continue;
				
				ret=[self newInstanceForTask:task instanceKey:dummyKey forDate:tmp];
				dummyKey=dummyKey-1;
				
				goto exitWhile;
			}
				break;
				
			case REPEAT_YEARLY://yearly
			{
				[comps setYear: [comps year]+repeatEvery];
				
				tmp= [gregorian dateFromComponents:comps];
				
//				if(task.isRepeatForever==0 && [tmp compare:task.repeatEndDate]==NSOrderedDescending) return ret;
				
//				if([self hasExceptionAtDate:tmp forTask:task]) continue;
				
				ret=[self newInstanceForTask:task instanceKey:dummyKey forDate:tmp];
				dummyKey=dummyKey-1;
				
				goto exitWhile;
			}
				break;
				
			default:
				goto exitWhile;
				break;
				
		}
	}
	
exitWhile:
	return ret;
}

-(Task *)newInstanceForTask:(Task *)task instanceKey:(NSInteger)instanceKeyp forDate:(NSDate *)date{
	Task *ret=[[[Task alloc] init] autorelease];
	[ivoUtility copyTask:task toTask:ret isIncludedPrimaryKey:YES];
	ret.primaryKey=instanceKeyp;
    ret.taskDeadLine=date;
	
	ret.originalExceptionDate=date;
	//ret.parentRepeatInstance=task.primaryKey;
	return ret;
}

//- (taskCheckResult) updateTask:(Task *)task isAllowChangeDueWhenUpdate:(BOOL)isAllowChangeDueWhenUpdate updateREType:(NSInteger)updateREType REUntilDate:(NSDate*)REUntilDate updateTime:(NSDate*)updateTime{
- (TaskActionResult *) updateTask:(Task *)task isAllowChangeDueWhenUpdate:(BOOL)isAllowChangeDueWhenUpdate updateREType:(NSInteger)updateREType REUntilDate:(NSDate*)REUntilDate updateTime:(NSDate*)updateTime{
	//ILOG(@"[TaskManager updateTask\n");
	//printf("\n\nstart update");
	TaskActionResult *ret=[[TaskActionResult alloc] init];
	DateTimeSlot *getTimeSlotResult=nil;
	TaskActionResult *overlapCheck=nil;
	
	Task *originalTask=[[Task alloc] init];
	Task *updatedTask=[[Task alloc] init];
	
	//[self refreshTaskListFromPartList];
	NSMutableArray *updatedTasks=[[NSMutableArray alloc] initWithArray:self.taskList];
	
//	NSMutableArray *updatedTasks=[self copyTasksFromList:self.taskList];
	
	[ivoUtility copyTask:task toTask:updatedTask isIncludedPrimaryKey:YES];
	
	//if(updateTime!=nil){
	//	updatedTask.isUsedExternalUpdateTime=YES;
	//	updatedTask.taskDateUpdate=updateTime;
	//}
	//else
	//{
	//	[updatedTask refreshDateUpdate];
	//}
	
	NSDate *searchTimeSlotFromDate;
	//get the main instance
	Task *mainInstance=nil;//[[Task alloc] init];
	BOOL isMainInstance=NO;
	BOOL isNeedToCheck=YES;
	NSMutableArray *tmpREList=[[NSMutableArray alloc] init];
	
	NSInteger i=0;
	NSInteger j=0;
	
	for (Task *taskMember in updatedTasks){
		//find the task need to be updated in the list
		if (taskMember.primaryKey==task.primaryKey){
			
			//keep the original task for comparing later
			[ivoUtility copyTask:taskMember toTask:originalTask isIncludedPrimaryKey:YES];

			//remove it out of list
			[updatedTasks removeObject:taskMember];
			
			//remove from recentDummiesList first
			//[recentDummiesList removeObject:taskMember];
			
			NSDate *getRepeatInstancesUntil=[self lastTaskEndDateInList:updatedTasks];
			
			if(updatedTask.taskPinned==1){
				
				if((updatedTask.taskRepeatID==0 && [updatedTask.taskEndTime compare:[NSDate date]]==NSOrderedAscending) || (updatedTask.taskRepeatID>0 && updatedTask.taskRepeatTimes>0 && [updatedTask.taskEndRepeatDate compare:[NSDate date]]==NSOrderedAscending)){
					//in the past, no need to check
					isNeedToCheck=NO;
					goto smartCheck;
				}
				
				if (updatedTask.taskRepeatID>0 ||
					(originalTask.taskHowLong != updatedTask.taskHowLong) || 
					(![originalTask.taskStartTime isEqualToDate: updatedTask.taskStartTime])||
					(![originalTask.taskEndTime isEqualToDate: updatedTask.taskEndTime])||
					originalTask.taskRepeatID !=updatedTask.taskRepeatID ||
					originalTask.taskRepeatTimes != updatedTask.taskRepeatTimes||
					originalTask.taskNumberInstances != updatedTask.taskNumberInstances ||
					originalTask.isAllDayEvent!=updatedTask.isAllDayEvent){
		
					if(REUntilDate!=nil && [REUntilDate compare:getRepeatInstancesUntil]==NSOrderedDescending){
						getRepeatInstancesUntil=REUntilDate;
					}
					
					if(task.taskRepeatID>0 || originalTask.taskRepeatID>0){
						
						//get the main instance:
						if(updatedTask.primaryKey<-1){
							//for(Task *tmp in self.taskList){
							for(Task *tmp in updatedTasks){
								if(tmp.primaryKey==updatedTask.parentRepeatInstance){
									//mainInstance=tmp;
									Task *main=[[Task alloc] init];
									[ivoUtility copyTask:tmp toTask:main isIncludedPrimaryKey:YES];
									//remove the root instance out of list
									mainInstance=main;
									[updatedTasks removeObject:tmp];
									[updatedTasks addObject:main];
									[self sortList:updatedTasks byKey:@"taskStartTime"];
									[main release];
									break;
								}
								j++;//mainInstance position
							}
						}else {
							//Task *tmp=[ivoUtility getTaskByPrimaryKey:updatedTask.primaryKey inArray:updatedTasks];
							//[ivoUtility copyTask:tmp toTask:mainInstance isIncludedPrimaryKey:YES];
							//[updatedTasks removeObject:tmp];
							//[updatedTasks addObject:mainInstance];
							//[self sortList:updatedTasks byKey:@"taskStartTime"];
							mainInstance=updatedTask;
							isMainInstance=YES;
						}
						
						//updatedTask.taskSynKey=mainInstance.taskSynKey;
						
						switch (updateREType) {
							case 1://update this instance only
								if(originalTask.taskRepeatID>0 && (originalTask.isOneMoreInstance==YES || originalTask.isAllDayEvent==1 || [originalTask.taskEndTime compare:getRepeatInstancesUntil]==NSOrderedAscending)){
									NSInteger repeatEvery=[self getRepeatEveryForRE:originalTask];
									[self fillRepeatEventInstances:[NSArray arrayWithObject:isMainInstance?originalTask:mainInstance] 
															toList:updatedTasks
														  fromDate:originalTask.taskEndTime
											  getInstanceUntilDate:[originalTask.taskEndTime dateByAddingTimeInterval:originalTask.taskRepeatID==1?2*86400*repeatEvery:originalTask.taskRepeatID==2?(604800+86400)*repeatEvery:originalTask.taskRepeatID==3?(2678400+86400)*repeatEvery:(31536000+86400)*repeatEvery] 
											   isShowPastInstances:YES 
												 isCleanOldDummies:NO 
											  isRememberFilledDate:NO
										  isNeedAtLeastOneInstance:YES];
								}
								
								if(!isMainInstance){
									//remove from recentDummiesList first
									//[recentDummiesList removeObject:taskMember];
									
									if(updatedTask.taskNumberInstances != 1){
										updatedTask.primaryKey=-1;
										updatedTask.taskRepeatID=0;
										updatedTask.taskRepeatTimes=0;
										updatedTask.taskNumberInstances=0;
										updatedTask.gcalEventId=@"";
                                        updatedTask.iCalIdentifier=@"";
										updatedTask.taskSynKey=0;
										updatedTask.parentRepeatInstance=mainInstance.primaryKey;
										mainInstance.taskRepeatExceptions=[mainInstance.taskRepeatExceptions stringByAppendingFormat:@"|%f",[originalTask.taskStartTime timeIntervalSince1970]];
									}else {
										goto updateAllSeries;
									}
								}
								
								if(overlapCheck) [overlapCheck release];
								overlapCheck=[ivoUtility smartCheckOverlapTask:updatedTask inTaskList:updatedTasks];
									
								break;
							case 2://update all in series
							{
							updateAllSeries:
								
								updatedTask.taskREStartTime=updatedTask.taskStartTime;
								NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
								unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
								
								//for the Start Time of the maininstance in the Series of ST
								NSDateComponents *comps = [gregorian components:unitFlags fromDate:updatedTask.taskStartTime];
								
								//for the RE Start Date Time of the mainInstance in the main series of ST 
								NSDateComponents *compsMain=[gregorian components:unitFlags fromDate:updatedTask.taskREStartTime];
								[compsMain setYear:[ivoUtility getYear:mainInstance.taskREStartTime]];
								[compsMain setMonth:[ivoUtility getMonth:mainInstance.taskREStartTime]];
								[compsMain setDay:[ivoUtility getDay:mainInstance.taskREStartTime]];
								
								//new***, keep original date, only change time for RE Start Time
								updatedTask.taskREStartTime=[gregorian dateFromComponents:compsMain];

								if(!isMainInstance){
									i=j;//reset position update to mainInstance
									
									//if change time or both date and time, keep date on mainInstance and shift time up/down
									if ([ivoUtility getHour:originalTask.taskStartTime] != [ivoUtility getHour:updatedTask.taskStartTime]||
										[ivoUtility getMinute:originalTask.taskStartTime] != [ivoUtility getMinute:updatedTask.taskStartTime]){

										[comps setYear:[ivoUtility getYear:mainInstance.taskStartTime]];
										[comps setMonth:[ivoUtility getMonth:mainInstance.taskStartTime]];
										[comps setDay:[ivoUtility getDay:mainInstance.taskStartTime]];
										
										
										//keep original date, only change time for mainIntances showing on ST
										updatedTask.taskStartTime=[gregorian dateFromComponents:comps];
										updatedTask.taskEndTime=[updatedTask.taskStartTime dateByAddingTimeInterval:updatedTask.taskHowLong];
										
									}else {
										if ([ivoUtility getDay:originalTask.taskStartTime] != [ivoUtility getDay:updatedTask.taskStartTime]||
											  [ivoUtility getMonth:originalTask.taskStartTime] != [ivoUtility getMonth:updatedTask.taskStartTime] ||
											  [ivoUtility getYear:originalTask.taskStartTime] != [ivoUtility getYear:updatedTask.taskStartTime]){
											
											//new***, if change date (or both date and time), change RE Start Time followed
											updatedTask.taskREStartTime=updatedTask.taskStartTime;
											//updatedTask.taskStartTime=updatedTask.taskStartTime;
											
											if(![updatedTask.taskStartTime isEqualToDate:mainInstance.taskStartTime]){
												NSDate *newStartTime4MainInstance=updatedTask.taskStartTime;
												//check if first instance where new mainInstance moved to if any existing exception
												
												if([self isExistedExceptionOnDate:newStartTime4MainInstance forRE:mainInstance inList:updatedTasks]){
													//for (Task *tmp in self.taskList){
													for (Task *tmp in updatedTasks){
														if(tmp.parentRepeatInstance ==mainInstance.primaryKey && tmp.primaryKey <-1 &&
														   [tmp.taskStartTime compare:updatedTask.taskStartTime]!=NSOrderedAscending){
															newStartTime4MainInstance=tmp.taskStartTime;
															break;
														}
													}
												}
												
												updatedTask.taskStartTime=newStartTime4MainInstance;
											}
											
										}else {
											//if not change date only, keep original start date and time
											updatedTask.taskStartTime=mainInstance.taskStartTime;
											updatedTask.taskEndTime=[updatedTask.taskStartTime dateByAddingTimeInterval:updatedTask.taskHowLong];
											updatedTask.taskREStartTime=mainInstance.taskREStartTime;
										}
									}

									
									updatedTask.primaryKey=mainInstance.primaryKey;
									updatedTask.parentRepeatInstance=-1;
									updatedTask.isOneMoreInstance=NO;
									
									//reset original task
									[ivoUtility copyTask:mainInstance toTask:originalTask isIncludedPrimaryKey:YES];
									
									[updatedTasks removeObject:mainInstance];
									mainInstance=updatedTask;
									
								}								
								[gregorian release];
								
								//check exceptions
								if ([ivoUtility getHour:originalTask.taskStartTime] != [ivoUtility getHour:updatedTask.taskStartTime]||
									[ivoUtility getMinute:originalTask.taskStartTime] != [ivoUtility getMinute:updatedTask.taskStartTime] ||
									originalTask.taskRepeatID != updatedTask.taskRepeatID){//make RE as new and clean all exception instances if any
									
									//clean all instances and exception instances on list first
									NSMutableArray *tmpNewList=[updatedTasks copy];
									for (Task *instance in tmpNewList){
										if(instance.taskPinned==1 && instance.parentRepeatInstance==mainInstance.primaryKey){
											//remove from recentDummiesList first
											//[recentDummiesList removeObject:instance];
											
											[updatedTasks removeObject:instance];
										}
									}
									
									[tmpNewList release];
									
									//reset exception values on list for main instance
									mainInstance.taskRepeatExceptions=@"";
									
								}else if(originalTask.taskNumberInstances > updatedTask.taskNumberInstances 
										 || ![originalTask.taskEndRepeatDate isEqualToDate:updatedTask.taskEndRepeatDate]
										 || ![originalTask.taskREStartTime isEqualToDate:updatedTask.taskREStartTime]) {
										//change end repeat to be shorter
									
									//clean all instances and exception instances below the end of the main series on list
									NSMutableArray *tmpNewList=[updatedTasks copy];
									for (Task *instance in tmpNewList){
										if(instance.parentRepeatInstance==mainInstance.primaryKey
											&& ((updatedTask.taskNumberInstances >0 && [[instance getOriginalDateOfExceptionInstance] compare:updatedTask.taskEndRepeatDate]==NSOrderedDescending)
												||[[instance getOriginalDateOfExceptionInstance] compare:updatedTask.taskREStartTime]==NSOrderedAscending
												|| (updatedTask.taskNumberInstances >0 && [instance.taskStartTime compare:updatedTask.taskEndRepeatDate]==NSOrderedDescending)
												|| [instance.taskStartTime compare:updatedTask.taskREStartTime]==NSOrderedAscending)){

											//remove from recentDummiesList first
											//[recentDummiesList removeObject:instance];
											[updatedTasks removeObject:instance];
										}
									}
									
									[tmpNewList release];
									
								}else {//clean instance in series and keep exception inatances if any
									NSMutableArray *tmpNewList=[updatedTasks copy];
									for (Task *instance in tmpNewList){
										if(instance.primaryKey< -1 && instance.parentRepeatInstance==mainInstance.primaryKey){
											//remove from recentDummiesList first
											//[recentDummiesList removeObject:instance];
											
											[updatedTasks removeObject:instance];
										}
									}
									[tmpNewList release];
								}	

								//get new list instances again
								//NSMutableArray *tmpREList1=[self createRepeatEventInstanceList:updatedTask getInstanceUntilDate:[getRepeatInstancesUntil dateByAddingTimeInterval:timeInervalForExpandingToFillRE]];
								NSMutableArray *tmpREList1=[[NSMutableArray alloc] init];
								[self fillRepeatEventInstances:[NSMutableArray arrayWithObject:updatedTask] 
														toList:tmpREList1 
													  fromDate:[NSDate date] 
										  getInstanceUntilDate:[getRepeatInstancesUntil dateByAddingTimeInterval:timeInervalForExpandingToFillRE]
										   isShowPastInstances:NO 
											 isCleanOldDummies:NO 
										  isRememberFilledDate:NO 
									  isNeedAtLeastOneInstance:NO];
								//check if any overlap
								for (Task *tmpInstance in  tmpREList1){
									if(overlapCheck) [overlapCheck release];
									overlapCheck=[ivoUtility smartCheckOverlapTask:tmpInstance inTaskList:updatedTasks];
									if (overlapCheck.errorNo==ERR_TASK_START_OVERLAPPED||overlapCheck.errorNo==ERR_TASK_END_OVERLAPPED||overlapCheck.errorNo==ERR_TASK_OVERLAPS_OTHERS){
										break;
									}
								}
								
								[tmpREList1 release];
								
							}
								break;
							case 3://update following
							{
								//make end repeat for existing series
								if(!isMainInstance){
									mainInstance.taskEndRepeatDate=[originalTask.taskEndTime dateByAddingTimeInterval:-86400];
									repeatCountTime ret=[ivoUtility createRepeatCountFromEndDate:mainInstance.taskREStartTime //replace endtime to be taskStartTime
																					  typeRepeat:mainInstance.taskRepeatID 
																						  toDate:mainInstance.taskEndRepeatDate
																				repeatOptionsStr:mainInstance.taskRepeatOptions
																					 reStartDate:mainInstance.taskREStartTime];
									mainInstance.taskRepeatTimes=ret.repeatTimes;
									mainInstance.taskNumberInstances=ret.numberOfInstances;
								
									if(updatedTask.taskNumberInstances>0){
										ret=[ivoUtility createRepeatCountFromEndDate:updatedTask.taskREStartTime //replace endtime to be taskStartTime
																		  typeRepeat:updatedTask.taskRepeatID 
																			  toDate:updatedTask.taskEndRepeatDate
																	repeatOptionsStr:updatedTask.taskRepeatOptions
																		 reStartDate:updatedTask.taskREStartTime];
										updatedTask.taskRepeatTimes=ret.repeatTimes;
										updatedTask.taskNumberInstances=ret.numberOfInstances;
									}
									
									updatedTask.primaryKey=-1;
									updatedTask.parentRepeatInstance=-1;
									updatedTask.taskRepeatOptions=mainInstance.taskRepeatOptions;
									updatedTask.taskRepeatExceptions=@"";
									
									//new***
									updatedTask.taskREStartTime=updatedTask.taskStartTime;
									
									//clean the instances and exception instances in the rest.
									NSMutableArray *tmpNewList=[updatedTasks copy];
									for(Task *restInstance in tmpNewList){
										if(restInstance.primaryKey !=-1 && restInstance.parentRepeatInstance==mainInstance.primaryKey && 
										   ([[restInstance getOriginalDateOfExceptionInstance] compare:originalTask.taskStartTime]==NSOrderedDescending
											||[restInstance.taskStartTime compare:originalTask.taskStartTime]==NSOrderedDescending)){
											
											//remove from recentDummiesList first
											//[recentDummiesList removeObject:restInstance];
											
											[updatedTasks removeObject:restInstance];
										}
									}
									
									[tmpNewList release];
								}else {
									goto updateAllSeries;
									//[updatedTasks removeObject:mainInstance];
								}

								
								//create instances from the updated instances and check all new instances (treat update instance as a new RE)
								//NSMutableArray *tmpREList=[self createRepeatEventInstanceList:updatedTask getInstanceUntilDate:[getRepeatInstancesUntil dateByAddingTimeInterval:timeInervalForExpandingToFillRE]];
								NSMutableArray *tmpREList=[[NSMutableArray alloc] init];
								[self fillRepeatEventInstances:[NSMutableArray arrayWithObject:updatedTask] 
														toList:tmpREList 
													  fromDate:[NSDate date] 
										  getInstanceUntilDate:[getRepeatInstancesUntil dateByAddingTimeInterval:timeInervalForExpandingToFillRE]
										   isShowPastInstances:NO 
											 isCleanOldDummies:NO 
										  isRememberFilledDate:NO 
									  isNeedAtLeastOneInstance:NO];
								
								for (Task *tmpInstance in  tmpREList){
									if(overlapCheck) [overlapCheck release];
									overlapCheck=[ivoUtility smartCheckOverlapTask:tmpInstance inTaskList:updatedTasks];
									if (overlapCheck.errorNo==ERR_TASK_START_OVERLAPPED||overlapCheck.errorNo==ERR_TASK_END_OVERLAPPED||overlapCheck.errorNo==ERR_TASK_OVERLAPS_OTHERS){
										break;
									}
								}
							}
								break;

							default://change from task/event to RE
								//get new list instances again
							{
								//NSMutableArray *tmpREList=[self createRepeatEventInstanceList:updatedTask getInstanceUntilDate:getRepeatInstancesUntil];
								[self fillRepeatEventInstances:[NSMutableArray arrayWithObject:updatedTask] 
														toList:tmpREList
													  fromDate:updatedTask.taskREStartTime 
										  getInstanceUntilDate:getRepeatInstancesUntil 
										   isShowPastInstances:NO 
											 isCleanOldDummies:YES 
										  isRememberFilledDate:NO
									  isNeedAtLeastOneInstance:NO];
								//check if any overlap
								for (Task *tmpInstance in  tmpREList){
									if(overlapCheck) [overlapCheck release];
									overlapCheck=[ivoUtility smartCheckOverlapTask:tmpInstance inTaskList:updatedTasks];
									if (overlapCheck.errorNo==ERR_TASK_START_OVERLAPPED||overlapCheck.errorNo==ERR_TASK_END_OVERLAPPED||overlapCheck.errorNo==ERR_TASK_OVERLAPS_OTHERS){
										break;
									}
								}
								//[tmpREList release];
							}
								break;
						}

					}else {
						if(overlapCheck) [overlapCheck release];
						overlapCheck=[ivoUtility smartCheckOverlapTask:updatedTask inTaskList:updatedTasks];
					}
					
					//checking if this change make overlap any tasks
				
				smartCheck:
					if (isNeedToCheck && ((updatedTask.isAllDayEvent!=originalTask.isAllDayEvent)||(updatedTask.taskHowLong!=originalTask.taskHowLong) || 
										  (overlapCheck.errorNo==ERR_TASK_START_OVERLAPPED||overlapCheck.errorNo==ERR_TASK_END_OVERLAPPED||overlapCheck.errorNo==ERR_TASK_OVERLAPS_OTHERS)) //||(originalTask.taskHowLong != updatedTask.taskHowLong)
						){//overlap an another task
						
						//[updatedTasks addObjectsFromArray:tmpREList];
						NSMutableArray *splitedTasksFromOverlapped=[[NSMutableArray alloc] initWithCapacity:2];
						if(updatedTask.isAllDayEvent==1){
							[self splitUnPinchedTasksFromTaskList:updatedTasks fromIndex:[ivoUtility getIndex:updatedTasks :updatedTask.primaryKey] toList:splitedTasksFromOverlapped context:-1];
						}else {
							[self splitUnPinchedTasksFromTaskList:updatedTasks fromIndex:overlapCheck.errorAtTaskIndex>0?overlapCheck.errorAtTaskIndex:0 toList:splitedTasksFromOverlapped context:-1];
						}

						
						//insert new event to list
						NSInteger i=[ivoUtility getTimeSlotIndexForTask:updatedTask inArray:updatedTasks];
						//if(i>=0 && i<updatedTasks.count){
							[updatedTasks insertObject:updatedTask atIndex:i];
						//}else {
						//	[updatedTasks addObject:updatedTasks];
						//}

						
						//fill RE's instances before re-adding tasks/Dtasks into list
						self.REList= [self getREListFromTaskList:updatedTasks];
						
						[self fillRepeatEventInstances:self.REList
												toList:updatedTasks 
											  fromDate:nil 
								  getInstanceUntilDate:[getRepeatInstancesUntil dateByAddingTimeInterval:timeInervalForExpandingToFillRE]
								   isShowPastInstances:NO
									 isCleanOldDummies:YES 
								  isRememberFilledDate:NO
							  isNeedAtLeastOneInstance:YES];	
						
						[self sortList:updatedTasks byKey:@"taskStartTime"];
						
						//re sort splited tasks
						[self sortList:splitedTasksFromOverlapped byKey:@"taskDueEndDate"];
						
						
						NSMutableArray *splitedTasksNoDeaLineFromOverlapped=[[NSMutableArray alloc] initWithCapacity:2];
						[self splitTasksByDeadLineFromTaskList:splitedTasksFromOverlapped fromIndex:0 toList:splitedTasksNoDeaLineFromOverlapped context:-1 byDeadLine:0];

//						if(splitedTasksFromOverlapped.count>0){
//							Task *tmp=[splitedTasksFromOverlapped objectAtIndex:0];
//							searchTimeSlotFromDate=[self smartEndOfLastTaskInList:updatedTasks forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
//						}
						
						//add task with deadline first
						for (Task *tmp in splitedTasksFromOverlapped){
							//find new time slot for each splitted task
							
							searchTimeSlotFromDate=[self smartEndOfLastTaskInList:updatedTasks forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
							//find new time slot for each splitted task
							if(task.taskRepeatID>0){
								getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:updatedTasks startFromDate:searchTimeSlotFromDate toDate:[searchTimeSlotFromDate dateByAddingTimeInterval:THREE_MONTH_INTERVAL]];
							}else {
								if(([searchTimeSlotFromDate compare:tmp.taskStartTime] !=NSOrderedSame) || 
								   [tmp isEqual:[splitedTasksFromOverlapped objectAtIndex:0]] || [searchTimeSlotFromDate compare:tmp.taskNotEalierThan]==NSOrderedAscending){
									getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:updatedTasks startFromDate:searchTimeSlotFromDate toDate:[searchTimeSlotFromDate dateByAddingTimeInterval:THREE_MONTH_INTERVAL]];
								}else {
									getTimeSlotResult=[[DateTimeSlot alloc] init];
									getTimeSlotResult.timeSlotDate=tmp.taskStartTime;
									getTimeSlotResult.indexAt=[ivoUtility getTimeSlotIndexForTask:tmp inArray:updatedTasks];
									getTimeSlotResult.isOverDue=NO;
									getTimeSlotResult.isPassedDeadLine=NO;
								}
							}

							//if([self isNotFitTask:getTimeSlotResult.timeSlotDate lastREInstanceDate:endInstanceDate inList:updatedTasks toDate:[searchTimeSlotFromDate dateByAddingTimeInterval:endInstanceDate]]){	
							if(getTimeSlotResult.isNotFit){
								ret.errorNo=ERR_RE_MAKE_TASK_NOT_BE_FIT;
								if(getTimeSlotResult!=nil){
									[getTimeSlotResult release];
									getTimeSlotResult=nil;
								}
								
								if(splitedTasksFromOverlapped !=nil){
									[splitedTasksFromOverlapped release];
									splitedTasksFromOverlapped=nil;
								}
								
								
								if(splitedTasksNoDeaLineFromOverlapped !=nil){
									[splitedTasksNoDeaLineFromOverlapped release];
									splitedTasksNoDeaLineFromOverlapped=nil;
								}
								
								//[updatedTasks release];
								
								
								//return ret;
								goto exitUpdate;
								
							}else if(getTimeSlotResult.indexAt > -1){
								if(getTimeSlotResult.isPassedDeadLine && tmp.taskIsUseDeadLine){
									if(currentSetting.dueWhenMove==0 || isAllowChangeDueWhenUpdate){
										//expand deadline to the date when new time slot found
										NSDate *newDeadLine=[ivoUtility createDeadLine:DEADLINE_TODAY fromDate:getTimeSlotResult.timeSlotDate context:tmp.taskWhere];
										tmp.taskDeadLine=newDeadLine;
										
										if(newDeadLine!=nil){
											[newDeadLine release];
											newDeadLine=nil;
										}
									}else {
										
										ret.errorNo=ERR_TASK_ANOTHER_PASS_DEADLINE;
										
										if(getTimeSlotResult!=nil){
											[getTimeSlotResult release];
											getTimeSlotResult=nil;
										}
										
										if(splitedTasksFromOverlapped !=nil){
											[splitedTasksFromOverlapped release];
											splitedTasksFromOverlapped=nil;
										}
										
										
										if(splitedTasksNoDeaLineFromOverlapped !=nil){
											[splitedTasksNoDeaLineFromOverlapped release];
											splitedTasksNoDeaLineFromOverlapped=nil;
										}
										
										//[updatedTasks release];
										
										
										//return ret;
										goto exitUpdate;
									}
								}
								
								if(getTimeSlotResult.isOverDue){
									tmp.taskDueEndDate=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
								}
								
								tmp.taskStartTime=getTimeSlotResult.timeSlotDate;
								tmp.taskEndTime=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
								[updatedTasks insertObject:tmp atIndex:getTimeSlotResult.indexAt];
	//							searchTimeSlotFromDate=tmp.taskEndTime;
							}
							if(getTimeSlotResult!=nil){
								[getTimeSlotResult release];
								getTimeSlotResult=nil;
							}
							
						}
						
//						if(splitedTasksNoDeaLineFromOverlapped.count>0){
//							Task *tmp=[splitedTasksNoDeaLineFromOverlapped objectAtIndex:0];
//							searchTimeSlotFromDate=[self smartEndOfLastTaskInList:updatedTasks forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
//						}
						
						//add task without deadline last
						for (Task *tmp in splitedTasksNoDeaLineFromOverlapped){
							
							//find new time slot for each splitted task
							
							searchTimeSlotFromDate=[self smartEndOfLastTaskInList:updatedTasks forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
							//find new time slot for each splitted task
							
							if(task.taskRepeatID>0){
								getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:updatedTasks startFromDate:searchTimeSlotFromDate toDate:[searchTimeSlotFromDate dateByAddingTimeInterval:THREE_MONTH_INTERVAL]];
							}else {
								if(([searchTimeSlotFromDate compare:tmp.taskStartTime] !=NSOrderedSame) || 
								   [tmp isEqual:[splitedTasksNoDeaLineFromOverlapped objectAtIndex:0]] || [searchTimeSlotFromDate compare:tmp.taskNotEalierThan]==NSOrderedAscending){
									getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:updatedTasks startFromDate:searchTimeSlotFromDate toDate:[searchTimeSlotFromDate dateByAddingTimeInterval:THREE_MONTH_INTERVAL]];
								}else {
									getTimeSlotResult=[[DateTimeSlot alloc] init];
									getTimeSlotResult.timeSlotDate=tmp.taskStartTime;
									getTimeSlotResult.indexAt=[ivoUtility getTimeSlotIndexForTask:tmp inArray:updatedTasks];
									getTimeSlotResult.isOverDue=NO;
									getTimeSlotResult.isPassedDeadLine=NO;
								}
							}

							
							//if([self isNotFitTask:getTimeSlotResult.timeSlotDate lastREInstanceDate:endInstanceDate inList:updatedTasks]){	
							if(getTimeSlotResult.isNotFit){
								ret.errorNo=ERR_RE_MAKE_TASK_NOT_BE_FIT;
								if(getTimeSlotResult!=nil){
									[getTimeSlotResult release];
									getTimeSlotResult=nil;
								}
								
								if(splitedTasksFromOverlapped !=nil){
									[splitedTasksFromOverlapped release];
									splitedTasksFromOverlapped=nil;
								}
								
								
								if(splitedTasksNoDeaLineFromOverlapped !=nil){
									[splitedTasksNoDeaLineFromOverlapped release];
									splitedTasksNoDeaLineFromOverlapped=nil;
								}
								
								//[updatedTasks release];
								
								
								//return ret;
								goto exitUpdate;
								
							}else if(getTimeSlotResult.indexAt > -1){
								if(getTimeSlotResult.isOverDue){
									tmp.taskDueEndDate=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
									tmp.taskDeadLine=tmp.taskDueEndDate;
								}
								
								tmp.taskStartTime=getTimeSlotResult.timeSlotDate;
								tmp.taskEndTime=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
//								tmp.taskDueEndDate=tmp.taskEndTime;
								[updatedTasks insertObject:tmp atIndex:getTimeSlotResult.indexAt];
//								searchTimeSlotFromDate=tmp.taskEndTime;
							}
							if(getTimeSlotResult!=nil){
								[getTimeSlotResult release];
								getTimeSlotResult=nil;
							}
						}
						
						//update databse
						for (Task *tmp in splitedTasksFromOverlapped){
							[tmp update];
						}
						
						for (Task *tmp in splitedTasksNoDeaLineFromOverlapped){
							[tmp update];
						}
						
						if(splitedTasksFromOverlapped !=nil){
							[splitedTasksFromOverlapped release];
							splitedTasksFromOverlapped=nil;
						}
						
						if(splitedTasksNoDeaLineFromOverlapped !=nil){
							[splitedTasksNoDeaLineFromOverlapped release];
							splitedTasksNoDeaLineFromOverlapped=nil;
						}
						
						if(getTimeSlotResult!=nil){
							[getTimeSlotResult release];
							getTimeSlotResult=nil;
						}
						//update the UpdatedTask at the last of function
					}else {
						NSInteger i=[ivoUtility getTimeSlotIndexForTask:updatedTask inArray:updatedTasks];
						[updatedTasks insertObject:updatedTask atIndex:i];
					}
					
				}else {
					NSInteger i=[ivoUtility getTimeSlotIndexForTask:updatedTask inArray:updatedTasks];
					[updatedTasks insertObject:updatedTask atIndex:i];
					//if(originalTask.taskRepeatID>0) goto saveUpdate;
				}
				
			}
			//	break;
			//case 0://change Tasks
			else{
				if ((originalTask.taskHowLong != updatedTask.taskHowLong) || 
					(![originalTask.taskStartTime isEqualToDate: updatedTask.taskStartTime])||
					(![originalTask.taskEndTime isEqualToDate: updatedTask.taskEndTime])||
					(![originalTask.taskNotEalierThan isEqualToDate: updatedTask.taskNotEalierThan])||
					(![originalTask.taskDeadLine isEqualToDate: updatedTask.taskDeadLine])||
					(originalTask.taskWhere != updatedTask.taskWhere)||
					(originalTask.taskPinned !=updatedTask.taskPinned)){
					
					self.REList=[self getREListFromTaskList:updatedTasks];
					[self fillRepeatEventInstances:self.REList
											toList:updatedTasks 
										  fromDate:nil
							  getInstanceUntilDate:[getRepeatInstancesUntil dateByAddingTimeInterval:timeInervalForExpandingToFillRE] 
							   isShowPastInstances:NO 
								 isCleanOldDummies:YES 
							  isRememberFilledDate:NO
						  isNeedAtLeastOneInstance:NO];
					[self sortList:updatedTasks byKey:@"taskStartTime"];
					
					if(overlapCheck) [overlapCheck release];
					overlapCheck=[ivoUtility smartCheckOverlapTask:updatedTask inTaskList:updatedTasks];

					if (overlapCheck.errorNo==ERR_TASK_START_OVERLAPPED||overlapCheck.errorNo==ERR_TASK_END_OVERLAPPED||overlapCheck.errorNo==ERR_TASK_OVERLAPS_OTHERS ||
						overlapCheck.errorNo==ERR_EVENT_START_OVERLAPPED||overlapCheck.errorNo==ERR_EVENT_END_OVERLAPPED||overlapCheck.errorNo==ERR_EVENT_OVERLAPS_OTHERS ||
						(originalTask.taskHowLong != updatedTask.taskHowLong||
						 (![originalTask.taskNotEalierThan isEqualToDate: updatedTask.taskNotEalierThan])||
						 (![originalTask.taskDeadLine isEqualToDate: updatedTask.taskDeadLine])||
						 (originalTask.taskWhere != updatedTask.taskWhere))||
						(originalTask.taskPinned !=updatedTask.taskPinned)){//overlap an another task
						
						NSMutableArray *splitedTasksFromDueEnd=[[NSMutableArray alloc] initWithCapacity:2];
						//[self splitTasksFromStartTime:updatedTasks fromStartTime:today toList:splitedTasksFromDueEnd context:-1];
						[self splitTasksFromStartTime:updatedTasks fromStartTime:[NSDate date] toList:splitedTasksFromDueEnd context:-1];
						//[splitedTasksFromDueEnd insertObject:updatedTask atIndex:0];
						[splitedTasksFromDueEnd addObject:updatedTask];
						
						[self sortList:splitedTasksFromDueEnd byKey:@"taskDueEndDate"];
						
						NSMutableArray *splitedTasksNoDeaLineFromDueEndList=[[NSMutableArray alloc] initWithCapacity:2];
						[self splitTasksByDeadLineFromTaskList:splitedTasksFromDueEnd fromIndex:0 toList:splitedTasksNoDeaLineFromDueEndList context:updatedTask.taskWhere byDeadLine:0];
						//[self sortList:splitedTasksNoDeaLineFromDueEndList byKey:@"taskDueEndDate"];
						
//						if(splitedTasksFromDueEnd.count>0){
//							Task *tmp=[splitedTasksFromDueEnd objectAtIndex:0];
//							searchTimeSlotFromDate=[self smartEndOfLastTaskInList:updatedTasks forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
//						}
						//try to add first for testing.
						//add task with deadline first
						for (Task *tmp in splitedTasksFromDueEnd){
							
							//find new time slot for each splitted task
							//getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:updatedTasks startFromDate:searchTimeSlotFromDate];

							searchTimeSlotFromDate=[self smartEndOfLastTaskInList:updatedTasks forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
							//find new time slot for each splitted task
							if(tmp.primaryKey==task.primaryKey || ([searchTimeSlotFromDate compare:tmp.taskStartTime] !=NSOrderedSame) || 
							   [tmp isEqual:[splitedTasksFromDueEnd objectAtIndex:0]] || 
							   (tmp.primaryKey== updatedTask.primaryKey && originalTask.taskHowLong != updatedTask.taskHowLong)){
								getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:updatedTasks startFromDate:searchTimeSlotFromDate toDate:[searchTimeSlotFromDate dateByAddingTimeInterval:THREE_MONTH_INTERVAL]];
							}else {
								getTimeSlotResult=[[DateTimeSlot alloc] init];
								getTimeSlotResult.timeSlotDate=tmp.taskStartTime;
								getTimeSlotResult.indexAt=[ivoUtility getTimeSlotIndexForTask:tmp inArray:updatedTasks];
								getTimeSlotResult.isOverDue=NO;
								getTimeSlotResult.isPassedDeadLine=NO;
							}
							
							//if([self isNotFitTask:getTimeSlotResult.timeSlotDate lastREInstanceDate:endInstanceDate inList:updatedTasks]){	
							if(getTimeSlotResult.isNotFit){
								ret.errorNo=ERR_TASK_NOT_BE_FIT_BY_RE;
								if(getTimeSlotResult!=nil){
									[getTimeSlotResult release];
									getTimeSlotResult=nil;
								}
								if(splitedTasksFromDueEnd !=nil){
									[splitedTasksFromDueEnd release];
									splitedTasksFromDueEnd=nil;
								}
								
								if (splitedTasksNoDeaLineFromDueEndList !=nil){
									[splitedTasksNoDeaLineFromDueEndList release];
									splitedTasksNoDeaLineFromDueEndList=nil;
								}
								//[updatedTasks release];
								
								//return ret;
								goto exitUpdate;
								
							}else if(getTimeSlotResult.indexAt > -1){
								if(getTimeSlotResult.isPassedDeadLine && tmp.taskIsUseDeadLine){
									if(currentSetting.dueWhenMove==0 || isAllowChangeDueWhenUpdate){
										//expand deadline to the date when new time slot found
										NSDate *newDeadLine=[ivoUtility createDeadLine:DEADLINE_TODAY fromDate:getTimeSlotResult.timeSlotDate context:tmp.taskWhere];
										tmp.taskDeadLine=newDeadLine;
										if(newDeadLine!=nil){
											[newDeadLine release];
											newDeadLine=nil;
										}
										
									}else {
										
										if(tmp.primaryKey==task.primaryKey){
											ret.errorNo=ERR_TASK_ITSELF_PASS_DEADLINE;
										}else {
											ret.errorNo=ERR_TASK_ANOTHER_PASS_DEADLINE;
										}
										
										if(getTimeSlotResult!=nil){
											[getTimeSlotResult release];
											getTimeSlotResult=nil;
										}
										if(splitedTasksFromDueEnd !=nil){
											[splitedTasksFromDueEnd release];
											splitedTasksFromDueEnd=nil;
										}
										
										if (splitedTasksNoDeaLineFromDueEndList !=nil){
											[splitedTasksNoDeaLineFromDueEndList release];
											splitedTasksNoDeaLineFromDueEndList=nil;
										}
										//[updatedTasks release];
										
										//return ret;
										goto exitUpdate;
									}
								}
								
								if(getTimeSlotResult.isOverDue){
									tmp.taskDueEndDate=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
								}
								
								tmp.taskStartTime=getTimeSlotResult.timeSlotDate;
								tmp.taskEndTime=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
								[updatedTasks insertObject:tmp atIndex:getTimeSlotResult.indexAt];
//								searchTimeSlotFromDate=tmp.taskEndTime;
							}
							if(getTimeSlotResult!=nil){
								[getTimeSlotResult release];
								getTimeSlotResult=nil;
							}
							
						}
						
//						if(splitedTasksNoDeaLineFromDueEndList.count>0){
//							Task *tmp=[splitedTasksNoDeaLineFromDueEndList objectAtIndex:0];
//							searchTimeSlotFromDate=[self smartEndOfLastTaskInList:updatedTasks forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
//						}
						
						//add task without deadline last
						for (Task *tmp in splitedTasksNoDeaLineFromDueEndList){
							
							//find new time slot for each splitted task
							
							searchTimeSlotFromDate=[self smartEndOfLastTaskInList:updatedTasks forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
							
							//find new time slot for each splitted task
							if(tmp.primaryKey==task.primaryKey ||([searchTimeSlotFromDate compare:tmp.taskStartTime] !=NSOrderedSame) || 
							   [tmp isEqual:[splitedTasksNoDeaLineFromDueEndList objectAtIndex:0]] || 
							   (tmp.primaryKey==updatedTask.primaryKey && originalTask.taskHowLong != updatedTask.taskHowLong)){
								getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:updatedTasks startFromDate:searchTimeSlotFromDate toDate:[searchTimeSlotFromDate dateByAddingTimeInterval:THREE_MONTH_INTERVAL]];
							}else {
								getTimeSlotResult=[[DateTimeSlot alloc] init];
								getTimeSlotResult.timeSlotDate=tmp.taskStartTime;
								getTimeSlotResult.indexAt=[ivoUtility getTimeSlotIndexForTask:tmp inArray:updatedTasks];
								getTimeSlotResult.isOverDue=NO;
								getTimeSlotResult.isPassedDeadLine=NO;
							}
							
							//if([self isNotFitTask:getTimeSlotResult.timeSlotDate lastREInstanceDate:endInstanceDate inList:updatedTasks]){	
							if(getTimeSlotResult.isNotFit){
								ret.errorNo=ERR_TASK_NOT_BE_FIT_BY_RE;
								if(getTimeSlotResult!=nil){
									[getTimeSlotResult release];
									getTimeSlotResult=nil;
								}
								if(splitedTasksFromDueEnd !=nil){
									[splitedTasksFromDueEnd release];
									splitedTasksFromDueEnd=nil;
								}
								
								if (splitedTasksNoDeaLineFromDueEndList !=nil){
									[splitedTasksNoDeaLineFromDueEndList release];
									splitedTasksNoDeaLineFromDueEndList=nil;
								}
								//[updatedTasks release];
								
								//return ret;
								goto exitUpdate;
								
							}else if(getTimeSlotResult.indexAt > -1){
								if(getTimeSlotResult.isOverDue){
									tmp.taskDueEndDate=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
									tmp.taskDeadLine=tmp.taskDueEndDate;
								}
								
								tmp.taskStartTime=getTimeSlotResult.timeSlotDate;
								tmp.taskEndTime=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
//								if(tmp.primaryKey==task.primaryKey)
//								tmp.taskDueEndDate=tmp.taskEndTime;
								[updatedTasks insertObject:tmp atIndex:getTimeSlotResult.indexAt];
//								searchTimeSlotFromDate=tmp.taskEndTime;
							}
							if(getTimeSlotResult!=nil){
								[getTimeSlotResult release];
								getTimeSlotResult=nil;
							}
						}
						
						
						//update databse
						for (Task *tmp in splitedTasksFromDueEnd){
							if(tmp.primaryKey==updatedTask.primaryKey){
								[updatedTask release];
								updatedTask=[tmp retain];
							}
							
							[tmp update];
						}
						
						for (Task *tmp in splitedTasksNoDeaLineFromDueEndList){
							[tmp update];
							if(tmp.primaryKey==updatedTask.primaryKey){
								[updatedTask release];
								updatedTask=[tmp retain];
							}
						}
						
						if(splitedTasksFromDueEnd !=nil){
							[splitedTasksFromDueEnd release];
							splitedTasksFromDueEnd=nil;
						}
						
						if (splitedTasksNoDeaLineFromDueEndList !=nil){
							[splitedTasksNoDeaLineFromDueEndList release];
							splitedTasksNoDeaLineFromDueEndList=nil;
						}
						
						
						if(getTimeSlotResult!=nil){
							[getTimeSlotResult release];
							getTimeSlotResult=nil;
						}
						
						//goto exitFor;
					}else {
						[updatedTasks insertObject:updatedTask atIndex:i];
						[updatedTask update];
					}
					
				}else {
					[updatedTasks insertObject:updatedTask atIndex:i];
					[updatedTask update];
				}
				
			}
			
			//for syncing
			if(originalTask.taskProject!=updatedTask.taskProject || originalTask.taskPinned !=updatedTask.taskPinned){
				//update deleted Item to setting for Syncing
				self.currentSetting.deleteItemsInTaskList=[self.currentSetting.deleteItemsInTaskList 
														   stringByAppendingString:[NSString stringWithFormat:@"$!$%d|%f|%@",originalTask.primaryKey,originalTask.taskSynKey,originalTask.gcalEventId]];
				updatedTask.gcalEventId=@"";
                
                if ([updatedTask.iCalIdentifier length]>0) {
                    self.currentSetting.deletedICalEvents=[self.currentSetting.deletedICalEvents stringByAppendingFormat:@"|%@",updatedTask.iCalIdentifier];
                }

                updatedTask.iCalIdentifier=@"";
                
                if ([updatedTask.reminderIdentifier length]>0) {
                    self.currentSetting.deletedReminders=[self.currentSetting.deletedReminders stringByAppendingFormat:@"|%@",updatedTask.reminderIdentifier];
                }
                
                updatedTask.reminderIdentifier=@"";
                
                [self.currentSetting update];
                
				[updatedTask update];
                
			}
			
			///////////////////save update for RE
		saveUpdate:
			if(updatedTask.taskPinned==1 && originalTask.taskRepeatID>0){
				switch (updateREType) {
					case 1://update this instance only
						if(isMainInstance){
							if(updatedTask.taskNumberInstances != 1){
								for(Task *tmpNewMainInstance in updatedTasks){
									if(tmpNewMainInstance.primaryKey<-1 && tmpNewMainInstance.parentRepeatInstance==updatedTask.primaryKey){
										//remove from recentDummiesList at the position where will be new main instance
										[recentDummiesList removeObject:tmpNewMainInstance];
										
										//exchange key
										tmpNewMainInstance.primaryKey=updatedTask.primaryKey;
									 	updatedTask.parentRepeatInstance=tmpNewMainInstance.primaryKey;

										//record original date for the exception
										tmpNewMainInstance.taskRepeatExceptions=[mainInstance.taskRepeatExceptions stringByAppendingFormat:@"|%f",[originalTask.taskStartTime timeIntervalSince1970]];
										updatedTask.taskRepeatID=0;
										updatedTask.taskSynKey=0;
										updatedTask.gcalEventId=@"";
                                        updatedTask.iCalIdentifier=@"";

										tmpNewMainInstance.parentRepeatInstance=-1;
										
										//if(tmpNewMainInstance.taskNumberInstances>1){
											//tmpNewMainInstance.taskRepeatTimes=tmpNewMainInstance.taskRepeatTimes -1;
											//tmpNewMainInstance.taskNumberInstances-=1;
											//tmpNewMainInstance.taskEndRepeatDate=[tmpNewMainInstance.taskEndRepeatDate dateByAddingTimeInterval:-86400];
										//}
										
										[tmpNewMainInstance update];
										break;
									}
								}
								
								updatedTask.taskRepeatID=0;
								//use taskRepeatExceptions to update original date for the instance
								updatedTask.taskRepeatExceptions=[NSString stringWithFormat:@"%f",[originalTask.taskStartTime timeIntervalSince1970]];
								updatedTask.primaryKey=[App_Delegate addTask:updatedTask];
								//mainInstance.parentRepeatInstance=updatedTask.primaryKey;
							}else {
								goto saveUpdateAllSeries;
							}

						}else {
							mainInstance.taskRepeatExceptions=[mainInstance.taskRepeatExceptions stringByAppendingFormat:@"|%f",[originalTask.taskStartTime timeIntervalSince1970]];
							//use taskRepeatExceptions to update original date for the instance
							updatedTask.taskRepeatExceptions=[NSString stringWithFormat:@"%f",[originalTask.taskStartTime timeIntervalSince1970]];
							updatedTask.gcalEventId=@"";
							updatedTask.taskSynKey=0;
                            updatedTask.iCalIdentifier=@"";
							updatedTask.primaryKey=[App_Delegate addTask:updatedTask];
						}

						ret.taskPrimaryKey=updatedTask.primaryKey;
						[mainInstance update];
						[updatedTask update];
						
						////printf("\nparent of new exception: %d",[self getParentRE:updatedTask inList:taskList]);
						break;
					case 2://update all in series
					saveUpdateAllSeries:
                    {
						//remove from recentDummiesList first
                        NSMutableArray *dummiesSourceList=[NSMutableArray arrayWithArray:self.recentDummiesList];
						for(Task *dummy in dummiesSourceList){
							if(dummy.parentRepeatInstance==mainInstance.primaryKey){
								[recentDummiesList removeObject:dummy];
								break;
							}
						}
						
						if ([ivoUtility getHour:originalTask.taskStartTime] != [ivoUtility getHour:updatedTask.taskStartTime]||
							[ivoUtility getMinute:originalTask.taskStartTime] != [ivoUtility getMinute:updatedTask.taskStartTime] ||
							originalTask.taskRepeatID != updatedTask.taskRepeatID){
							//for (Task *instance in self.taskList){//remove exceptions in database
							for (Task *instance in updatedTasks){//remove exceptions in database
								if(instance.primaryKey>-2 && instance.parentRepeatInstance==mainInstance.primaryKey){
									if(![instance.gcalEventId isEqualToString:@""]){
										self.currentSetting.deleteItemsInTaskList=[self.currentSetting.deleteItemsInTaskList 
                                                                                   stringByAppendingString:[NSString stringWithFormat:@"$!$%ld|%f|%@",(long)instance.primaryKey,instance.taskSynKey,instance.gcalEventId]];
										[self.currentSetting update];	
									}
									
									if (instance.toodledoID>0) {
                                        self.currentSetting.toodledoDeletedTasks=[self.currentSetting.toodledoDeletedTasks stringByAppendingFormat:@"|%ld",(long)instance.toodledoID];
										[self.currentSetting update];
									}
									
                                    if ([instance.iCalIdentifier length]>0) {
                                        self.currentSetting.deletedICalEvents=[self.currentSetting.deletedICalEvents stringByAppendingFormat:@"|%@",instance.iCalIdentifier];
                                        [self.currentSetting update];
                                    }

                                    if ([instance.reminderIdentifier length]>0) {
                                        self.currentSetting.deletedReminders=[self.currentSetting.deletedReminders stringByAppendingFormat:@"|%@",instance.reminderIdentifier];
                                    }
                                    
									[instance deleteFromDatabase];
								}
							}
						}else if(originalTask.taskNumberInstances > updatedTask.taskNumberInstances 
								 || ![originalTask.taskEndRepeatDate isEqualToDate:updatedTask.taskEndRepeatDate]
								 || ![originalTask.taskREStartTime isEqualToDate:updatedTask.taskREStartTime]) {
							//changed end repeat to be shorter
							
							//for (Task *instance in self.taskList){//remove exceptions in database
							for (Task *instance in updatedTasks){//remove exceptions in database
								if(instance.primaryKey>-2 && instance.parentRepeatInstance==updatedTask.primaryKey
								   && ((updatedTask.taskNumberInstances >0 && [[instance getOriginalDateOfExceptionInstance] compare:updatedTask.taskEndRepeatDate]==NSOrderedDescending)
									   ||[[instance getOriginalDateOfExceptionInstance] compare:updatedTask.taskREStartTime]==NSOrderedAscending
									   || (updatedTask.taskNumberInstances >0 && [instance.taskStartTime compare:updatedTask.taskEndRepeatDate]==NSOrderedDescending)
									   || [instance.taskStartTime compare:updatedTask.taskREStartTime]==NSOrderedAscending)){
									
									if(![instance.gcalEventId isEqualToString:@""]){
										self.currentSetting.deleteItemsInTaskList=[self.currentSetting.deleteItemsInTaskList 
                                                                                   stringByAppendingString:[NSString stringWithFormat:@"$!$%ld|%f|%@",(long)instance.primaryKey,instance.taskSynKey,instance.gcalEventId]];
										[self.currentSetting update];	
									}
									
									   if (instance.toodledoID>0) {
                                           self.currentSetting.toodledoDeletedTasks=[self.currentSetting.toodledoDeletedTasks stringByAppendingFormat:@"|%ld",(long)instance.toodledoID];
										   [self.currentSetting update];
									   }
                                       
                                       if ([instance.iCalIdentifier length]>0) {
                                           self.currentSetting.deletedICalEvents=[self.currentSetting.deletedICalEvents stringByAppendingFormat:@"|%@",instance.iCalIdentifier];
                                           [self.currentSetting update];
                                       }

									   if ([instance.reminderIdentifier length]>0) {
                                           self.currentSetting.deletedReminders=[self.currentSetting.deletedReminders stringByAppendingFormat:@"|%@",instance.reminderIdentifier];
                                       }
                                       
									[instance deleteFromDatabase];
								}
							}
							
							/*
							if(originalTask.taskNumberInstances > updatedTask.taskNumberInstances 
							   || ![originalTask.taskEndRepeatDate isEqualToDate:updatedTask.taskEndRepeatDate]){
								repeatCountTime ret=[ivoUtility createRepeatCountFromEndDate:[updatedTask.taskREStartTime dateByAddingTimeInterval:updatedTask.taskHowLong]
																				  typeRepeat:updatedTask.taskRepeatID 
																					  toDate:updatedTask.taskEndRepeatDate
																			repeatOptionsStr:[updatedTask taskRepeatOptions]];
								
								updatedTask.taskRepeatTimes=ret.repeatTimes;
								updatedTask.taskNumberInstances=ret.numberOfInstances;
							}
							 */
						}
						
						//[mainInstance update];
						
						[updatedTask update];
						////printf("--%s",[updatedTask.taskRepeatExceptions UTF8String]);
                    }
						break;
					case 3://update following
						if(!isMainInstance){
							updatedTask.taskSynKey=0;
							updatedTask.gcalEventId=@"";
							updatedTask.iCalIdentifier=@"";
                            
							updatedTask.parentRepeatInstance=-1;
							if(updatedTask.taskNumberInstances>0){
								repeatCountTime ret=[ivoUtility createRepeatCountFromEndDate:updatedTask.taskREStartTime //replace endtime to be taskStartTime
																				  typeRepeat:updatedTask.taskRepeatID 
																					  toDate:updatedTask.taskEndRepeatDate
																			repeatOptionsStr:[updatedTask taskRepeatOptions]
																				 reStartDate:updatedTask.taskREStartTime];
								
								updatedTask.taskRepeatTimes=ret.repeatTimes;
								updatedTask.taskNumberInstances=ret.numberOfInstances;
								
							}
							updatedTask.primaryKey=[App_Delegate addTask:updatedTask];

							//remove from recentDummiesList first
							//for(Task *dummy in recentDummiesList){
                            NSMutableArray *dummiesSourceList=[NSMutableArray arrayWithArray:self.recentDummiesList];
                            for(Task *dummy in dummiesSourceList){
								if(dummy.parentRepeatInstance==mainInstance.primaryKey && dummy.parentRepeatInstance==mainInstance.primaryKey
								   && ([[dummy getOriginalDateOfExceptionInstance] compare:originalTask.taskStartTime]==NSOrderedDescending 
									   || [dummy.taskStartTime compare:originalTask.taskStartTime]==NSOrderedDescending)){
									[recentDummiesList removeObject:dummy];
								}
							}
							
							//for (Task *instance in self.taskList){//remove below exceptions in database
							for (Task *instance in updatedTasks){//remove below exceptions in database
								if(instance.primaryKey>-2&& instance.parentRepeatInstance==mainInstance.primaryKey
								   && ([[instance getOriginalDateOfExceptionInstance] compare:originalTask.taskStartTime]==NSOrderedDescending 
									   || [instance.taskStartTime compare:originalTask.taskStartTime]==NSOrderedDescending)){
									
									
                                       if(![instance.gcalEventId isEqualToString:@""]){
                                           self.currentSetting.deleteItemsInTaskList=[self.currentSetting.deleteItemsInTaskList 
                                                                                      stringByAppendingString:[NSString stringWithFormat:@"$!$%ld|%f|%@",(long)instance.primaryKey,instance.taskSynKey,instance.gcalEventId]];
                                           [self.currentSetting update];	
                                       }
									
									   if (instance.toodledoID>0) {
                                           self.currentSetting.toodledoDeletedTasks=[self.currentSetting.toodledoDeletedTasks stringByAppendingFormat:@"|%ld",(long)instance.toodledoID];
										   [self.currentSetting update];
									   }
									   
                                       if ([instance.iCalIdentifier length]>0) {
                                           self.currentSetting.deletedICalEvents=[self.currentSetting.deletedICalEvents stringByAppendingFormat:@"|%@",instance.iCalIdentifier];
                                           [self.currentSetting update];
                                       }
                                       
                                       if ([instance.reminderIdentifier length]>0) {
                                           self.currentSetting.deletedReminders=[self.currentSetting.deletedReminders stringByAppendingFormat:@"|%@",instance.reminderIdentifier];
                                       }
									[instance deleteFromDatabase];
								}
							}
							
							[mainInstance update];
						}else {
							goto saveUpdateAllSeries;
						}

						ret.taskPrimaryKey=updatedTask.primaryKey;
						[updatedTask update];
						break;
					default:
						[updatedTask update];
						break;
				}
				
			}else if(updatedTask.taskPinned==1){
				[updatedTask update];
			}

            /*
			//update alerts to server if any
			if(OSVersion<=3.0){ 
				if ([dev_token length]>0){
					NSString *alertPNSStr=[ivoUtility getAPNSAlertFromTask:updatedTask];
					if([updatedTask.PNSKey length]>0){
						// un-comment this line to disable Push for Task
						if([alertPNSStr length]==0){
							[ivoUtility deleteAlertsOnServerForTasks:updatedTask];
						}else {
							[ivoUtility uploadAlertsForTasks:updatedTask isAddNew:NO withPNSAlert:alertPNSStr oldDevToken:dev_token oldTaskPNSID:updatedTask.PNSKey];
						}
						
					}else { 
						if([updatedTask.taskAlertValues length]>0) {
							//new alert values has just added for the updated event
							if([alertPNSStr length]>0) {
								
								updatedTask.PNSKey=[[NSDate date] description];
								[ivoUtility uploadAlertsForTasks:updatedTask isAddNew:YES withPNSAlert:alertPNSStr oldDevToken:dev_token oldTaskPNSID:updatedTask.PNSKey];
							}
						}
					}
				}
			}else {
				[self updateLocalNotificationForList:updatedTasks];
			}
			*/
			
			[updatedTask update];
			///////////////////////////////
					   
			if(overlapCheck!=nil){
				[overlapCheck release];
				overlapCheck=nil;
			}
			
			goto exitFor;

		}
		i++;
	}
	
exitFor:	
	self.taskList=updatedTasks;
	
    [self updateLocalNotificationForList:self.taskList];

	//update the order for tasks
//	i=1;
//	for (Task *task in self.taskList){
//		if(task.primaryKey>=0){
//			task.taskOrder=i;
//			[task update];
//			i+=1;
//		}
//	}
	
exitUpdate:	
	//[App_Delegate getPartTaskList];
	
	[tmpREList release];
//	[mainInstance release];

	if(getTimeSlotResult!=nil){
		[getTimeSlotResult release];
		getTimeSlotResult=nil;
	}
	
	if(updatedTasks!=nil){
		[updatedTasks release];
		updatedTasks=nil;
	}

	if(updatedTask!=nil){
		[updatedTask release];
		updatedTask=nil;
	}
	
	
//	//printf("---%s",[self.currentSetting.deleteItemsInTaskList UTF8String]);
//	[App_Delegate stopAcitivityIndicatorThread];
	//ILOG(@"TaskManager updateTask]\n");
    
    //[self.ekSync backgroundFullSync];
    
    if (!needStopSync && self.currentSetting.autoICalSync) {
        if ((self.currentSetting.syncEventOnly==1 && (task.taskPinned==1 || originalTask.taskPinned==1)) || self.currentSetting.syncEventOnly==0) {
            if (self.currentSetting.enableSyncICal) {
                [self.ekSync backgroundFullSync];
            }
        }
        
        if (self.currentSetting.enabledReminderSync) {
            [self.reminderSync backgroundFullSync];
        }
    }
    
    if(originalTask !=nil){
        [originalTask release];
        originalTask=nil;
    }

    //printf("\n end update");
    
	return ret;
}

//-(void)updateAlertsSettingToServerProvider:(id)sender{
	//NSTimer *timer=(NSTimer *)sender;
	//Task* tmp=[timer userInfo];
	//[ivoUtility uploadAlertsForTasks:tmp isAddNew:<#(BOOL)isAddNew#> withPNSAlert:<#(NSString *)withPNSAlert#>];
//}

-(BOOL)isExistedExceptionOnDate:(NSDate *)date forRE:(Task *)task inList:(NSMutableArray *)list{
	BOOL ret=NO;
	/*
	for(Task *tmp in list){
		if(tmp.taskPinned==1 && tmp.primaryKey > -1 && tmp.parentRepeatInstance==task.primaryKey && 
			[ivoUtility getDay:tmp.taskStartTime]==[ivoUtility getDay:date] &&
			[ivoUtility getMonth:tmp.taskStartTime]==[ivoUtility getMonth:date] &&
		   [ivoUtility getYear:tmp.taskStartTime]==[ivoUtility getYear:date]){

			ret=YES;
			break;
		}
	}
	 */
	
	NSArray *exceptionDateList=[task.taskRepeatExceptions componentsSeparatedByString:@"|"];
	for (NSInteger i=1;i<exceptionDateList.count;i++){
		NSDate *tmp=[NSDate dateWithTimeIntervalSince1970:[[exceptionDateList objectAtIndex:i] doubleValue]];
		if([[ivoUtility getStringFromShortDate:tmp] isEqualToString:[ivoUtility getStringFromShortDate:date]]){
			ret=YES;
			break;
		}
	}
	return ret;
}

//deleteType: 0-delete this instance only; 1-delete all in series; 2-delete following; 
-(NSInteger)deleteREInstances:(Task *)instance inList:(NSMutableArray *)list deleteType:(NSInteger)deleteType isDeleteFromDB:(BOOL)isDeleteFromDB{
	NSMutableArray *newList= [NSMutableArray arrayWithArray:list];
	Task *mainInstance=nil;
	BOOL isMainInstance=NO;
	NSInteger indx=0;
	
	//get the main instance:
	if(instance.primaryKey<-1){
		for(Task *tmp in list){
			if(tmp.primaryKey==instance.parentRepeatInstance){
				mainInstance=tmp;
				break;
			}
		}
	}else {
		mainInstance=instance;
		isMainInstance=YES;
	}

	switch (deleteType) {
		case 1://delete this instance only
			indx=[self getIndexOfTaskByPrimaryKey:instance inArray:self.taskList];
			
			if(instance.taskRepeatID>0 && instance.isOneMoreInstance==YES){
				NSMutableArray *nextDummies=[NSMutableArray array];
				NSInteger repeatEvery=[self getRepeatEveryForRE:instance];
				[self fillRepeatEventInstances:[NSArray arrayWithObject:mainInstance] 
										toList:nextDummies
									  fromDate:instance.taskEndTime
						  getInstanceUntilDate:[instance.taskEndTime dateByAddingTimeInterval:instance.taskRepeatID==1?2*86400*repeatEvery:instance.taskRepeatID==2?(604800+86400)*repeatEvery:instance.taskRepeatID==3?(2678400+86400)*repeatEvery:(31536000+86400)*repeatEvery] 
						   isShowPastInstances:YES 
							 isCleanOldDummies:NO 
						  isRememberFilledDate:NO
					  isNeedAtLeastOneInstance:NO];
				
				if(nextDummies.count==0){
					[self fillFirstDummyREInstanceToList:self.taskList rootRE:mainInstance];
				}else {
					[self.taskList addObjectsFromArray:nextDummies];
				}
				[self sortList:self.taskList byKey:@"taskStartTime"];
			}
			
			if(isMainInstance){//delete main instance
				NSInteger key=mainInstance.primaryKey;
				[list removeObject:mainInstance];
				
				for (Task *instanceRE in list){//find the first next instance
					if (instanceRE.primaryKey <-1 && instanceRE.parentRepeatInstance==mainInstance.primaryKey){
						if(isDeleteFromDB){
							//remove from recentDummiesList first
							[recentDummiesList removeObject:instanceRE];
						}
						
						instanceRE.primaryKey=key;
						instanceRE.parentRepeatInstance=-1;
						instanceRE.taskREStartTime=instanceRE.taskStartTime;
						
						if(instanceRE.taskNumberInstances>1)
							instanceRE.taskNumberInstances=instanceRE.taskNumberInstances-1;
						[instanceRE update];
						break;
					}
				}
			}else {
				mainInstance.taskRepeatExceptions=[mainInstance.taskRepeatExceptions stringByAppendingFormat:@"|%f",[instance.taskStartTime timeIntervalSince1970]];
				
				[mainInstance update];
				[list removeObject:instance];
			}

			
			break;
		case 2://delete all in series
			indx=[self getIndexOfTaskByPrimaryKey:mainInstance inArray:list];
			
			for (Task *instanceRE in newList){
				if (instanceRE.primaryKey <-1 && instanceRE.parentRepeatInstance==mainInstance.primaryKey){
					if(isDeleteFromDB){
						//remove from recentDummiesList first
						[recentDummiesList removeObject:instanceRE];
					}
					[list removeObject:instanceRE];
				}
			}
			
			if(isDeleteFromDB){
				[mainInstance deleteFromDatabase];
			}	

			//update deleted Item to setting for Syncing
			if(!instance.isDeletedFromGCal){
				self.currentSetting.deleteItemsInTaskList=[self.currentSetting.deleteItemsInTaskList 
                                                           stringByAppendingString:[NSString stringWithFormat:@"$!$%ld|%f|%@",(long)mainInstance.primaryKey,mainInstance.taskSynKey,mainInstance.gcalEventId]];
				[self.currentSetting update];
			}
			
			if (instance.toodledoID>0) {
                self.currentSetting.toodledoDeletedTasks=[self.currentSetting.toodledoDeletedTasks stringByAppendingFormat:@"|%ld",(long)instance.toodledoID];
				[self.currentSetting update];
			}
			
            if ([instance.iCalIdentifier length]>0) {
                 self.currentSetting.deletedICalEvents=[self.currentSetting.deletedICalEvents stringByAppendingFormat:@"|%@",instance.iCalIdentifier];
                [self.currentSetting update];
            }
            
            if ([instance.reminderIdentifier length]>0) {
                self.currentSetting.deletedReminders=[self.currentSetting.deletedReminders stringByAppendingFormat:@"|%@",instance.reminderIdentifier];
            }
            
			/*//remove alerts from server if any///////////////
			if([dev_token length]>0){
				if([mainInstance.PNSKey length]>0){
					[ivoUtility deleteAlertsOnServerForTasks:mainInstance];
				}
			}
			 */			
			/////////////////////////////////////////////////
			
            /*
			if (OSVersion<=3.0) {
				//remove alerts from server if any///////////////
				if([dev_token length]>0){
					if([mainInstance.PNSKey length]>0){
						[ivoUtility deleteAlertsOnServerForTasks:mainInstance];
					}
				}
				/////////////////////////////////////////////////
				
				[list removeObject:mainInstance];
			}else {
				if ([mainInstance.taskAlertValues length]>0) {
					[list removeObject:mainInstance];
					[self updateLocalNotificationForList:list];
				}else {
					[list removeObject:mainInstance];
				}
			}
			*/
            
            //[self updateLocalNotificationForList:self.taskList];
            
			[list removeObject:mainInstance];
			
			break;
		case 3://delete following
			indx=[self getIndexOfTaskByPrimaryKey:instance inArray:list];
			
			if(!isMainInstance){//incase delete instances is not the main instance 
				mainInstance.taskEndRepeatDate=[instance.taskEndTime dateByAddingTimeInterval:-86400]; 
				repeatCountTime ret=[ivoUtility createRepeatCountFromEndDate:mainInstance.taskREStartTime//replace endtime to be taskStartTime 
																  typeRepeat:mainInstance.taskRepeatID 
																	  toDate:mainInstance.taskEndRepeatDate
															repeatOptionsStr:[mainInstance taskRepeatOptions]
																 reStartDate:mainInstance.taskREStartTime];
				mainInstance.taskRepeatTimes=ret.repeatTimes;
				mainInstance.taskNumberInstances=ret.numberOfInstances;
				[mainInstance update];
				//update the instances in the series
				
			}

			for (Task *instanceRE in newList){
				if (instanceRE.primaryKey <=instance.primaryKey && instanceRE.parentRepeatInstance==mainInstance.primaryKey){
					if(isDeleteFromDB){
						//remove from recentDummiesList first
						[recentDummiesList removeObject:instanceRE];
					}
					[list removeObject:instanceRE];
				}
			}
			
			if(isMainInstance){//incase delete instances is also the main instance 
				
				if(isDeleteFromDB){
					[mainInstance deleteFromDatabase];
				}	
				[list removeObject:mainInstance];

			}else {//update remain instances in the series
				for (Task *instanceRE in list){
					if (instanceRE.primaryKey <-1 && instanceRE.parentRepeatInstance==mainInstance.primaryKey){
						instanceRE.taskEndRepeatDate=[instance.taskEndTime dateByAddingTimeInterval:-86400]; 
						repeatCountTime ret=[ivoUtility createRepeatCountFromEndDate:mainInstance.taskREStartTime //replace endtime to be taskStartTime 
																		  typeRepeat:mainInstance.taskRepeatID 
																			  toDate:mainInstance.taskEndRepeatDate
																	repeatOptionsStr:[instanceRE taskRepeatOptions]
																		 reStartDate:mainInstance.taskREStartTime];
						instanceRE.taskRepeatTimes=ret.repeatTimes;
						instanceRE.taskNumberInstances=ret.numberOfInstances;
					}
				}
			}

			break;
			
		default:
			break;
	}
	
	//[newList release];
	
    [self updateLocalNotificationForList:self.taskList];

	return indx;
}

- (TaskActionResult *) deleteTask: (double) taskKey isDeleteFromDB:(BOOL)deleteFromDB deleteREType:(NSInteger)deleteREType{
	//ILOG(@"[TaskManager deleteTask\n");
	
	//	[App_Delegate showAcitivityIndicatorThread];
	
    //printf("\n start delete");
    
	TaskActionResult *ret=[[TaskActionResult alloc] init];;
	
	DateTimeSlot *getTimeSlotResult=nil;
	
	//NSMutableArray* retArray = [[NSMutableArray alloc] initWithArray:self.taskList];
	NSInteger indx=0;
	Task* taskTmp;
	Task* deleteTask=[[Task alloc] init];
	
	NSDate *searchTimeSlotFromDate;

	Task *delTask=nil;
	if(taskKey<-1){
		delTask=[ivoUtility getTaskByPrimaryKey:taskKey inArray:self.taskList];
	}

	
	self.REList=[self getREListFromTaskList:self.taskList];
	
	[self fillRepeatEventInstances:self.REList 
							toList:self.taskList
						  fromDate:[NSDate date] 
			  getInstanceUntilDate:delTask?[delTask.taskEndTime dateByAddingTimeInterval:timeInervalForExpandingToFillRE]:[[self lastTaskEndDateInList:self.taskList] dateByAddingTimeInterval:timeInervalForExpandingToFillRE]
			   isShowPastInstances:YES 
				 isCleanOldDummies:YES 
			  isRememberFilledDate:NO
		  isNeedAtLeastOneInstance:NO];
	[self sortList:self.taskList byKey:@"taskStartTime"];
	
	NSMutableArray *arr=[[NSMutableArray alloc] initWithArray:self.recentDummiesList];
	
	[self updateDummiesKeyFromList:arr toList:self.taskList];
	[arr release];
    
	if(delTask)
		[self updateDummiesKeyFromList:[NSMutableArray arrayWithObject:delTask] toList:self.taskList];
		//[arr addObject:delTask];

	[self sortList:self.taskList byKey:@"taskStartTime"];

    NSMutableArray *sourceList=[NSMutableArray arrayWithArray:self.taskList];
	for (taskTmp in sourceList){
		if (taskTmp.primaryKey ==(NSInteger) taskKey || (taskTmp.taskSynKey==taskKey && taskTmp.taskSynKey !=0)){
			[ivoUtility copyTask:taskTmp toTask:deleteTask isIncludedPrimaryKey:YES];
			
			
			indx=[self getIndexOfTaskByPrimaryKey:taskTmp inArray:self.taskList];
			
			
			//delete all instances if this is a RE
			if(taskTmp.taskPinned==1 && taskTmp.taskRepeatID>0 && taskTmp.taskNumberInstances !=1){
				indx=[self deleteREInstances:taskTmp inList:self.taskList deleteType:deleteREType isDeleteFromDB:deleteFromDB];
				
			}else{
				if(!taskTmp.isDeletedFromGCal && deleteFromDB){
					//update deleted Item to setting for Syncing
					self.currentSetting.deleteItemsInTaskList=[self.currentSetting.deleteItemsInTaskList 
                                                               stringByAppendingString:[NSString stringWithFormat:@"$!$%ld|%f|%@",(long)taskTmp.primaryKey,taskTmp.taskSynKey,taskTmp.gcalEventId]];
					
					if (taskTmp.toodledoID>0) {
                        self.currentSetting.toodledoDeletedTasks=[self.currentSetting.toodledoDeletedTasks stringByAppendingFormat:@"|%ld",(long)taskTmp.toodledoID];
					}
                    
                    if ([taskTmp.iCalIdentifier length]>0) {
                        self.currentSetting.deletedICalEvents=[self.currentSetting.deletedICalEvents stringByAppendingFormat:@"|%@",taskTmp.iCalIdentifier];
                    }
                    
                    if ([taskTmp.reminderIdentifier length]>0) {
                        self.currentSetting.deletedReminders=[self.currentSetting.deletedReminders stringByAppendingFormat:@"|%@",taskTmp.reminderIdentifier];
                        //[self.currentSetting update];
                        //if (self.currentSetting.autoICalSync && self.currentSetting.enabledReminderSync) {
                        //    [self.reminderSync oneWayDeleteReminders];
                        //}
                    }

                    //if ([taskTmp.reminderIdentifier length]>0) {
                    //    self.currentSetting.deletedReminders=[self.currentSetting.deletedReminders stringByAppendingFormat:@"|%@",taskTmp.reminderIdentifier];
                    //}
                    
					[self.currentSetting update];
				}
				
				//remove alerts from server if any///////////////
				/*if([dev_token length]>0){
					if(taskTmp.taskPinned==1 && [taskTmp.PNSKey length]>0){
						[ivoUtility deleteAlertsOnServerForTasks:taskTmp];
					}
				}
				 */
				/////////////////////////////////////////////////
                /*
				if (OSVersion<=3.0) {
					//remove alerts from server if any///////////////
					if([dev_token length]>0){
						//if(taskTmp.taskPinned==1 && [taskTmp.PNSKey length]>0){
						if([taskTmp.PNSKey length]>0){
							[ivoUtility deleteAlertsOnServerForTasks:taskTmp];
						}
					}
					[self.taskList removeObject:taskTmp];
					/////////////////////////////////////////////////
				}else {
					if ([taskTmp.taskAlertValues length]>0) {
						[self.taskList removeObject:taskTmp];
						[self updateLocalNotificationForList:self.taskList];						
					}else {
						[self.taskList removeObject:taskTmp];
					}
				}
				*/
                
                //[self updateLocalNotificationForList:self.taskList];
				[self.taskList removeObject:taskTmp];
				
			}
			
			//delete all exception instances if any for syncing
			NSMutableArray *tmpDelList=[self.taskList copy];
			if(deleteTask.taskPinned==1 && deleteTask.taskRepeatID>0){
				for(Task *expInstance in tmpDelList){
					if (expInstance.parentRepeatInstance==deleteTask.primaryKey){
						
						if(deleteFromDB){
							[expInstance deleteFromDatabase];	
						}
						
						[self.taskList removeObject:expInstance];
						
					}
				}
				
			}
			
			[tmpDelList release];
			
			
			if([deleteTask.taskEndTime compare:[NSDate date]]==NSOrderedAscending && 
			   !(deleteTask.taskPinned==1 && deleteTask.taskRepeatID>0 && deleteTask.taskNumberInstances !=1)){
				if (deleteFromDB){
					[deleteTask deleteFromDatabase];
				}
				goto exitFor;
			}else {//refresh the list
				
				NSMutableArray *splitedTasksFromOverlap=[[NSMutableArray alloc] initWithCapacity:5];
				[self splitUnPinchedTasksFromTaskList:self.taskList fromIndex:indx toList:splitedTasksFromOverlap context:-1];

				//move unpinned task at bottom up
				Task *tmp;
				if (splitedTasksFromOverlap.count>0){
//					tmp=[splitedTasksFromOverlap objectAtIndex:0];
//					searchTimeSlotFromDate=[self smartEndOfLastTaskInList:self.taskList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];

					for (tmp in splitedTasksFromOverlap){
						
						Task *updateSplitTask=[[Task alloc] init];
						[ivoUtility copyTask:tmp toTask:updateSplitTask isIncludedPrimaryKey:YES];
						
						//find new time slot for each splitted task
						if(getTimeSlotResult!=nil){
							[getTimeSlotResult release];
							getTimeSlotResult=nil;
						}
						
						searchTimeSlotFromDate=[self smartEndOfLastTaskInList:self.taskList forTask:tmp context:updateSplitTask.taskWhere isUsedDeadLine:updateSplitTask.taskIsUseDeadLine];
						//find new time slot for each splitted task
						if(([searchTimeSlotFromDate compare:updateSplitTask.taskStartTime] !=NSOrderedSame) || 
						   [updateSplitTask isEqual:[splitedTasksFromOverlap objectAtIndex:0]]){
							
							getTimeSlotResult=[self createTimeSlotForDTask:updateSplitTask inArray:self.taskList startFromDate:searchTimeSlotFromDate toDate:[searchTimeSlotFromDate dateByAddingTimeInterval:THREE_MONTH_INTERVAL]];
						}else {
							getTimeSlotResult=[[DateTimeSlot alloc] init];
							getTimeSlotResult.timeSlotDate=updateSplitTask.taskStartTime;
							getTimeSlotResult.indexAt=[ivoUtility getTimeSlotIndexForTask:tmp inArray:self.taskList];
							getTimeSlotResult.isOverDue=NO;
							getTimeSlotResult.isPassedDeadLine=NO;
						}
						
						if(getTimeSlotResult.indexAt!=-1){
							updateSplitTask.taskStartTime=getTimeSlotResult.timeSlotDate;
							updateSplitTask.taskEndTime=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:updateSplitTask.taskHowLong];
							//update database for this task
							//[updateSplitTask update];
							//update list
							[self.taskList insertObject:updateSplitTask atIndex:getTimeSlotResult.indexAt];
							
//							searchTimeSlotFromDate=updateSplitTask.taskEndTime;
							
						}else {//nerver makes out of range due for others when delete a task
							/*
							 ret.errorNo= 1;//update task make due task out of range of due dates
							 ret.errorMessage=[[NSString alloc] initWithFormat:@"Invalid: delete task makes unpinned task's due dates '%s' out of range!",[tmp.taskName UTF8String]];
							 goto exitDelete;
							 */
						}
						
						if(updateSplitTask !=nil){
							[updateSplitTask release];
							updateSplitTask=nil;
						}
						
						if(getTimeSlotResult!=nil){
							[getTimeSlotResult release];
							getTimeSlotResult=nil;
						}
					}
				}
				
				if (deleteFromDB && !(deleteTask.taskPinned==1 && deleteTask.taskRepeatID>0 && deleteTask.taskNumberInstances !=1)){//update database
					[deleteTask deleteFromDatabase];
//					if (splitedTasksFromOverlap.count>0){
//						//for (Task *tmp in self.taskList){
//						for (Task *tmp in self.taskList){
//							if(tmp.primaryKey>0 && tmp.taskPinned==0){
//								[tmp update];
//							}
//						}
//						
//					}
				}
				
				if (splitedTasksFromOverlap.count>0){
                    NSMutableArray *sourceList=[NSMutableArray arrayWithArray:self.taskList];
					for (Task *tmp in sourceList){
					//for (Task *tmp in deleteList){
						if(tmp.primaryKey>0){
							[tmp update];
						}
					}
				}			

			//	self.taskList=deleteList;
				
			//	[deleteList release];
				
				if(splitedTasksFromOverlap !=nil){
					[splitedTasksFromOverlap release];
					splitedTasksFromOverlap=nil;
				}
				
				goto exitFor;
			}
		}		
		indx++;
	}
	
exitFor:
	//self.taskList;
	//[retArray release];
	//retArray=nil;
	
	//if(deleteFromDB){
	//	[App_Delegate getPartTaskList];
	//}
	
exitDelete:
	
    [self updateLocalNotificationForList:self.taskList];

	if(getTimeSlotResult!=nil){
		[getTimeSlotResult release];
		getTimeSlotResult=nil;
	}
	
	if(deleteTask !=nil){
		[deleteTask release];
		deleteTask=nil;
	}
    
    if (deleteFromDB && !needStopSync) {
        //[self.ekSync oneWayDeleteEvent:delTask withType:deleteREType];
        if (self.currentSetting.enableSyncICal && self.currentSetting.autoICalSync) {
            [self.ekSync backgroundFullSync];
        }
        
        if (self.currentSetting.enabledReminderSync && self.currentSetting.autoICalSync) {
            [self.reminderSync backgroundFullSync];
        }
    }
	
    //printf("\n end delete");
    
	//	[App_Delegate stopAcitivityIndicatorThread];
	//ILOG(@"TaskManager deleteTask]\n");
	return ret;
}

/*
- (taskCheckResult) deleteTask: (double) taskKey isDeleteFromDB:(BOOL)deleteFromDB deleteREType:(NSInteger)deleteREType{
	//ILOG(@"[TaskManager deleteTask\n");
	
//	[App_Delegate showAcitivityIndicatorThread];
	
	taskCheckResult ret;
	ret.errorNo=-1;
	ret.errorMessage=nil;
	ret.overdueTimeSlotFound=nil;
	
	DateTimeSlot *getTimeSlotResult=nil;
	
	//NSMutableArray* retArray = [[NSMutableArray alloc] initWithArray:self.taskList];
	NSInteger indx=0;
	Task* taskTmp;
	Task* deleteTask=[[Task alloc] init];
	
	NSDate *searchTimeSlotFromDate;
	
	for (taskTmp in self.taskList){
		if (taskTmp.primaryKey ==(NSInteger) taskKey || (taskTmp.taskSynKey==taskKey && taskTmp.taskSynKey !=0)){
			[ivoUtility copyTask:taskTmp toTask:deleteTask isIncludedPrimaryKey:YES];

			
			indx=[self getIndexOfTaskByPrimaryKey:taskTmp inArray:self.taskList];

			
			//delete all instances if this is a RE
			if(taskTmp.taskPinned==1 && taskTmp.taskRepeatID>0 && taskTmp.taskNumberInstances !=1){
				[self deleteREInstances:taskTmp inList:self.taskList deleteType:deleteREType isDeleteFromDB:deleteFromDB];
			
			}else{
				if(!taskTmp.isDeletedFromGCal){
					//update deleted Item to setting for Syncing
					self.currentSetting.deleteItemsInTaskList=[self.currentSetting.deleteItemsInTaskList 
														   stringByAppendingString:[NSString stringWithFormat:@"$!$%d|%f|%@",taskTmp.primaryKey,taskTmp.taskSynKey,taskTmp.gcalEventId]];
					[self.currentSetting update];
				}
				
				[self.taskList removeObject:taskTmp];
				
			}

			
			//delete all exception instances if any for syncing
			NSMutableArray *tmpDelList=[self.taskList copy];
			if(deleteTask.taskPinned==1 && deleteTask.taskRepeatID>0){
				for(Task *expInstance in tmpDelList){
					if (expInstance.parentRepeatInstance==deleteTask.primaryKey){
						
						if(deleteFromDB){
							[expInstance deleteFromDatabase];	
						}
						
						//update deleted Item to setting for Syncing
						//self.currentSetting.deleteItemsInTaskList=[self.currentSetting.deleteItemsInTaskList 
						//										   stringByAppendingString:[NSString stringWithFormat:@"/%d|%f",expInstance.primaryKey,expInstance.taskSynKey]];
						//[self.currentSetting update];
						
						[self.taskList removeObject:expInstance];
						
						//expInstance.parentRepeatInstance=888888;
						//[expInstance update];
					}
				}
			}
			
			[tmpDelList release];
			
			
			if([deleteTask.taskEndTime compare:[NSDate date]]==NSOrderedAscending && 
			   !(deleteTask.taskPinned==1 && deleteTask.taskRepeatID>0 && deleteTask.taskNumberInstances !=1)){
				if (deleteFromDB){
					[deleteTask deleteFromDatabase];
				}
				goto exitFor;
			}else {//refresh the list
				
				NSMutableArray *splitedTasksFromOverlap=[[NSMutableArray alloc] initWithCapacity:5];
				[self splitUnPinchedTasksFromTaskList:self.taskList fromIndex:indx toList:splitedTasksFromOverlap context:deleteTask.taskWhere];

				//move unpinned task at bottom up
				Task *tmp;
				if (splitedTasksFromOverlap.count>0){
					for (tmp in splitedTasksFromOverlap){
					
						Task *updateSplitTask=[[Task alloc] init];
						[ivoUtility copyTask:tmp toTask:updateSplitTask isIncludedPrimaryKey:YES];
					
						//find new time slot for each splitted task
						if(getTimeSlotResult!=nil){
							[getTimeSlotResult release];
							getTimeSlotResult=nil;
						}
					
						searchTimeSlotFromDate=[self smartEndOfLastTaskInList:self.taskList context:updateSplitTask.taskWhere isUsedDeadLine:updateSplitTask.taskIsUseDeadLine];
						//find new time slot for each splitted task
						if(([searchTimeSlotFromDate compare:updateSplitTask.taskStartTime] !=NSOrderedSame) || 
						   [updateSplitTask isEqual:[splitedTasksFromOverlap objectAtIndex:0]]){
								
							getTimeSlotResult=[self createTimeSlotForDTask:updateSplitTask inArray:self.taskList startFromDate:searchTimeSlotFromDate];
						}else {
							getTimeSlotResult=[[DateTimeSlot alloc] init];
							getTimeSlotResult.timeSlotDate=updateSplitTask.taskStartTime;
							getTimeSlotResult.indexAt=[ivoUtility getTimeSlotIndexForTask:tmp inArray:self.taskList];
							getTimeSlotResult.isOverDue=NO;
							getTimeSlotResult.isPassedDeadLine=NO;
						}
						
						if(getTimeSlotResult.indexAt!=-1){
							updateSplitTask.taskStartTime=getTimeSlotResult.timeSlotDate;
							updateSplitTask.taskEndTime=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:updateSplitTask.taskHowLong];
							//update database for this task
							//[updateSplitTask update];
							//update list
							[self.taskList insertObject:updateSplitTask atIndex:getTimeSlotResult.indexAt];
							
							//searchTimeSlotFromDate=updateSplitTask.taskEndTime;
						
						}
 
						if(updateSplitTask !=nil){
							[updateSplitTask release];
							updateSplitTask=nil;
						}
					
						if(getTimeSlotResult!=nil){
							[getTimeSlotResult release];
							getTimeSlotResult=nil;
						}
					}
				}
			
				if (deleteFromDB && !(deleteTask.taskPinned==1 && deleteTask.taskRepeatID>0 && deleteTask.taskNumberInstances !=1)){//update database
					[deleteTask deleteFromDatabase];
					if (splitedTasksFromOverlap.count>0){
						for (Task *tmp in splitedTasksFromOverlap){
							[tmp update];
						}
					}
				}
			
				if(splitedTasksFromOverlap !=nil){
					[splitedTasksFromOverlap release];
					splitedTasksFromOverlap=nil;
				}
				
				goto exitFor;
			}
		}		
		indx++;
	}
	
exitFor:
exitDelete:
	
	if(getTimeSlotResult!=nil){
		[getTimeSlotResult release];
		getTimeSlotResult=nil;
	}
	
	if(deleteTask !=nil){
		[deleteTask release];
		deleteTask=nil;
	}
	return ret;
}
*/
- (TaskActionResult *) delayTask:(NSInteger)taskKey delayType:(NSInteger) type isAutoChangeDue:(BOOL)changeDue{
	//ILOG(@"[TaskManager delayTask\n");
//	[App_Delegate showAcitivityIndicatorThread];
	
    //printf("\n start delay");
    
	TaskActionResult *ret=[[TaskActionResult alloc] init];;
	ret.errorNo=-1;
	ret.errorMessage=nil;
	ret.overdueTimeSlotFound=nil;
	
	BOOL isPinnedTask=NO;
	Task *taskTmp;
	Task *deferTask=[[Task alloc] init];
	NSInteger indx;
	//NSMutableArray *delayList=[[NSMutableArray alloc] initWithArray:self.taskList];//backup
	NSMutableArray *listBackup=[[NSMutableArray alloc] initWithArray:self.taskList];//backup task list
	
	//[ivoUtility printTask:listBackup];
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	
	updatePK=taskKey;
	delayType=type;
	
	NSDate	*searchTimeSlotFromDate;
	NSDate *getRepeatInstancesUntil=[self lastTaskEndDateInList:self.taskList];
	
    NSMutableArray *sourceList=[NSMutableArray arrayWithArray:self.taskList];
    
	for (indx=0;indx<sourceList.count;indx++){
		taskTmp=[sourceList objectAtIndex:indx];
		
		if(taskTmp.primaryKey==taskKey){
			
			[ivoUtility copyTask:taskTmp toTask:deferTask isIncludedPrimaryKey:YES];
			
//			unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
			NSDateComponents *comps = [gregorian components:unitFlags fromDate:deferTask.taskStartTime];
			comps.hour=0;
			comps.minute=0;
			comps.second=0;
			
			if(deferTask.taskPinned==0){//defer task
				NSDate *originalDate=[deferTask.taskDueStartDate retain];
				//change Its Start Due
				if (type==1){
					[comps setDay:[comps day]+1];
					//deferTask.taskDueStartDate=[[gregorian dateFromComponents:comps] dateByAddingTimeInterval:86400];
				}else if(type==2){
					[comps setDay:[comps day]+2];
					//deferTask.taskDueStartDate=[[gregorian dateFromComponents:comps] dateByAddingTimeInterval:172800];
				}else if(type==3){
					[comps setDay:[comps day]+7];
					//deferTask.taskDueStartDate=[[gregorian dateFromComponents:comps] dateByAddingTimeInterval:604800];
				}
				
				deferTask.taskDueStartDate=[gregorian dateFromComponents:comps];
				
//nang 3.6: 091224
/*				if([App_defaultTimeZone isDaylightSavingTimeForDate:originalDate] && ![App_defaultTimeZone isDaylightSavingTimeForDate:deferTask.taskDueStartDate]){
					deferTask.taskDueStartDate=[deferTask.taskDueStartDate dateByAddingTimeInterval:dstOffset];
				}else if(![App_defaultTimeZone isDaylightSavingTimeForDate:originalDate] && [App_defaultTimeZone isDaylightSavingTimeForDate:deferTask.taskDueStartDate]){
					deferTask.taskDueStartDate=[deferTask.taskDueStartDate dateByAddingTimeInterval:-dstOffset];
				}
*/				
				[originalDate release];
				
				deferTask.taskNotEalierThan=deferTask.taskDueStartDate;
				
				
				//get Task out from list
				if(ret) [ret release];
				ret=[self deleteTask:deferTask.primaryKey isDeleteFromDB:NO deleteREType:-1];
				
				DateTimeSlot *getTimeSlotResult;
				
				deferTask.taskStartTime=deferTask.taskDueStartDate;
				deferTask.taskDueEndDate=[deferTask.taskStartTime dateByAddingTimeInterval:deferTask.taskHowLong];
				
				NSInteger index=[ivoUtility getTimeSlotIndexForTask:deferTask inArray:self.taskList];
				
				NSMutableArray *splitedTasksFromDueEnd=[[NSMutableArray alloc] initWithCapacity:2];
				//[self splitTasksFromStartTime:self.taskList fromStartTime:[NSDate date] toList:splitedTasksFromDueEnd context:deferTask.taskWhere];
				
				[self splitUnPinchedTasksFromTaskList:self.taskList fromIndex:index toList:splitedTasksFromDueEnd context:tmpNewTask.taskWhere];
				[splitedTasksFromDueEnd insertObject:deferTask atIndex:0];
				
				[self sortList:splitedTasksFromDueEnd byKey:@"taskDueEndDate"];
				
				NSMutableArray *splitedTasksNoDeaLineFromDueEndList=[[NSMutableArray alloc] initWithCapacity:2];
				[self splitTasksByDeadLineFromTaskList:splitedTasksFromDueEnd fromIndex:0 toList:splitedTasksNoDeaLineFromDueEndList context:deferTask.taskWhere byDeadLine:0];
				
				self.REList=[self getREListFromTaskList:self.taskList];
				[self fillRepeatEventInstances:self.REList 
										toList:self.taskList 
									  fromDate:nil getInstanceUntilDate:[getRepeatInstancesUntil dateByAddingTimeInterval:timeInervalForExpandingToFillRE] 
						   isShowPastInstances:NO 
							 isCleanOldDummies:YES 
						  isRememberFilledDate:NO
					  isNeedAtLeastOneInstance:NO];
				
				[self sortList:self.taskList byKey:@"taskStartTime"];
				
//				if (splitedTasksFromDueEnd.count>0){
//					Task *tmp=[splitedTasksFromDueEnd objectAtIndex:0];
//					searchTimeSlotFromDate=[self smartEndOfLastTaskInList:self.taskList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
//				}
				
				//try to add first for testing.
				//add task with deadline first
				for (Task *tmp in splitedTasksFromDueEnd){
					
					//find new time slot for each splitted task
					//getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:self.taskList startFromDate:searchTimeSlotFromDate];
					
					searchTimeSlotFromDate=[self smartEndOfLastTaskInList:self.taskList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
					//find new time slot for each splitted task
					if(([searchTimeSlotFromDate compare:tmp.taskStartTime] !=NSOrderedSame ) || 
					   [tmp isEqual:[splitedTasksFromDueEnd objectAtIndex:0]]){
						
						getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:self.taskList startFromDate:searchTimeSlotFromDate toDate:[searchTimeSlotFromDate dateByAddingTimeInterval:THREE_MONTH_INTERVAL]];
					}else {
						getTimeSlotResult=[[DateTimeSlot alloc] init];
						getTimeSlotResult.timeSlotDate=tmp.taskStartTime;
						getTimeSlotResult.indexAt=[ivoUtility getTimeSlotIndexForTask:tmp inArray:self.taskList];
						getTimeSlotResult.isOverDue=NO;
						getTimeSlotResult.isPassedDeadLine=NO;
					}
					
					//if([self isNotFitTask:getTimeSlotResult.timeSlotDate lastREInstanceDate:endInstanceDate inList:self.taskList]){	
					if(getTimeSlotResult.isNotFit){
						ret.errorNo=ERR_TASK_NOT_BE_FIT_BY_RE;
						
						if(getTimeSlotResult!=nil){
							[getTimeSlotResult release];
							getTimeSlotResult=nil;
						}
						self.taskList=listBackup;
						if(splitedTasksFromDueEnd !=nil){
							[splitedTasksFromDueEnd release];
							splitedTasksFromDueEnd=nil;
						}
						
						if (splitedTasksNoDeaLineFromDueEndList !=nil){
							[splitedTasksNoDeaLineFromDueEndList release];
							splitedTasksNoDeaLineFromDueEndList=nil;
						}
						
						//[delayList release];
						//return ret;
						goto exitFor;
						
					}else if(getTimeSlotResult.indexAt > -1){
						if(getTimeSlotResult.isPassedDeadLine && tmp.taskIsUseDeadLine){
							if(currentSetting.dueWhenMove==0 || changeDue){
								//expand deadline to the date when new time slot found
								NSDate *newDeadLine=[ivoUtility createDeadLine:DEADLINE_TODAY fromDate:getTimeSlotResult.timeSlotDate context:tmp.taskWhere];
								tmp.taskDeadLine=newDeadLine;
								if(newDeadLine!=nil){
									[newDeadLine release];
									newDeadLine=nil;
								}
								
							}else {
								
								if(tmp.primaryKey==taskKey){
									ret.errorNo=ERR_TASK_ITSELF_PASS_DEADLINE;
								}else {
									ret.errorNo=ERR_TASK_ANOTHER_PASS_DEADLINE;
								}
								
								if(getTimeSlotResult!=nil){
									[getTimeSlotResult release];
									getTimeSlotResult=nil;
								}
								self.taskList=listBackup;
								if(splitedTasksFromDueEnd !=nil){
									[splitedTasksFromDueEnd release];
									splitedTasksFromDueEnd=nil;
								}
								
								if (splitedTasksNoDeaLineFromDueEndList !=nil){
									[splitedTasksNoDeaLineFromDueEndList release];
									splitedTasksNoDeaLineFromDueEndList=nil;
								}
								 
								//[delayList release];
								//return ret;
								goto exitFor;
							}
						}
						
						if(getTimeSlotResult.isOverDue){
							tmp.taskDueEndDate=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
						}
						
						tmp.taskStartTime=getTimeSlotResult.timeSlotDate;
						tmp.taskEndTime=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
						//					if(tmp.primaryKey==deferTask.primaryKey)
						//					tmp.taskDueEndDate=tmp.taskEndTime;
						[self.taskList insertObject:tmp atIndex:getTimeSlotResult.indexAt];
//						searchTimeSlotFromDate=tmp.taskEndTime;
					}
					if(getTimeSlotResult!=nil){
						[getTimeSlotResult release];
						getTimeSlotResult=nil;
					}
					
				}
				
//				if (splitedTasksNoDeaLineFromDueEndList.count>0){
//					Task *tmp=[splitedTasksNoDeaLineFromDueEndList objectAtIndex:0];
//					searchTimeSlotFromDate=[self smartEndOfLastTaskInList:self.taskList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
//				}
				
				//add task without deadline last
				for (Task *tmp in splitedTasksNoDeaLineFromDueEndList){
					
					//find new time slot for each splitted task
					//getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:self.taskList startFromDate:searchTimeSlotFromDate];
					
					searchTimeSlotFromDate=[self smartEndOfLastTaskInList:self.taskList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
					//find new time slot for each splitted task
					if(([searchTimeSlotFromDate compare:tmp.taskStartTime] !=NSOrderedSame) || 
					   [tmp isEqual:[splitedTasksNoDeaLineFromDueEndList objectAtIndex:0]]){
						
						getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:self.taskList startFromDate:searchTimeSlotFromDate toDate:[searchTimeSlotFromDate dateByAddingTimeInterval:THREE_MONTH_INTERVAL]];
					}else {
						getTimeSlotResult=[[DateTimeSlot alloc] init];
						getTimeSlotResult.timeSlotDate=tmp.taskStartTime;
						getTimeSlotResult.indexAt=[ivoUtility getTimeSlotIndexForTask:tmp inArray:self.taskList];
						getTimeSlotResult.isOverDue=NO;
						getTimeSlotResult.isPassedDeadLine=NO;
					}
					
					//if([self isNotFitTask:getTimeSlotResult.timeSlotDate lastREInstanceDate:endInstanceDate inList:self.taskList]){	
					if(getTimeSlotResult.isNotFit){
						ret.errorNo=ERR_TASK_NOT_BE_FIT_BY_RE;
						
						if(getTimeSlotResult!=nil){
							[getTimeSlotResult release];
							getTimeSlotResult=nil;
						}
						
						//[ivoUtility printTask:listBackup];
						self.taskList=listBackup;
						//[ivoUtility printTask:listBackup];
						if(splitedTasksFromDueEnd !=nil){
							[splitedTasksFromDueEnd release];
							splitedTasksFromDueEnd=nil;
						}
						
						if (splitedTasksNoDeaLineFromDueEndList !=nil){
							[splitedTasksNoDeaLineFromDueEndList release];
							splitedTasksNoDeaLineFromDueEndList=nil;
						}
						
						//[delayList release];
						//return ret;
						goto exitFor;
						
					}else if(getTimeSlotResult.indexAt > -1){
						if(getTimeSlotResult.isOverDue){
							tmp.taskDueEndDate=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
							tmp.taskDeadLine=tmp.taskDueEndDate;
						}
						
						tmp.taskStartTime=getTimeSlotResult.timeSlotDate;
						tmp.taskEndTime=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
						//					if(tmp.primaryKey==deferTask.primaryKey)
						//					tmp.taskDueEndDate=tmp.taskEndTime;
						[self.taskList insertObject:tmp atIndex:getTimeSlotResult.indexAt];
//						searchTimeSlotFromDate=tmp.taskEndTime;
					}
					if(getTimeSlotResult!=nil){
						[getTimeSlotResult release];
						getTimeSlotResult=nil;
					}
				}
				
				//update due end date for the delaying task---------------------------
				[self updateNewDueEndDateForUpdatedTask:deferTask inList:self.taskList];
				
				
				//update databse
				for (Task *tmp in splitedTasksFromDueEnd){
					if(tmp.primaryKey==taskKey && isPinnedTask)
						tmp.taskPinned=1;
//					[tmp update];
				}
				
				for (Task *tmp in splitedTasksNoDeaLineFromDueEndList){
					if(tmp.primaryKey==taskKey && isPinnedTask)
						tmp.taskPinned=1;
//					[tmp update];
				}
				
				//ST 3.3.1 update the rest tasks on task List
                
                NSMutableArray *sourceList=[NSMutableArray arrayWithArray:self.taskList];
				for(Task *task in sourceList){
					if(task.taskPinned==0){
						[task update];
					}
				}
				
				if(splitedTasksFromDueEnd !=nil){
					[splitedTasksFromDueEnd release];
					splitedTasksFromDueEnd=nil;
				}
				
				if (splitedTasksNoDeaLineFromDueEndList !=nil){
					[splitedTasksNoDeaLineFromDueEndList release];
					splitedTasksNoDeaLineFromDueEndList=nil;
				}
				
				
				if(getTimeSlotResult!=nil){
					[getTimeSlotResult release];
					getTimeSlotResult=nil;
				}
				
				//update the order for tasks
//				NSInteger i=1;
//				for (Task *task in self.taskList){
//					if(task.primaryKey>=0){
//						task.taskOrder=i;
//						[task update];
//						i+=1;
//					}
//				}
				
                if (!needStopSync && self.currentSetting.autoICalSync) {
                    if (self.currentSetting.enableSyncICal) {
                        [self.ekSync backgroundFullSync];
                    }
                    
                    if (self.currentSetting.enabledReminderSync) {
                        [self.reminderSync backgroundFullSync];
                    }
                }

			}else {//defer event
				Task *deferingTask=[[Task alloc] init];
				//Task *mainInstance=nil;
				//BOOL isMainInstance=NO;
				
				[ivoUtility copyTask:taskTmp toTask:deferingTask isIncludedPrimaryKey:YES];
				
				//NSDate *originalDate=[deferingTask.taskStartTime retain];
				
				//unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
				//comps = [gregorian components:unitFlags fromDate:taskTmp.taskStartTime];
				
				if (type==1){
					//[comps setDay:[comps day]+1];
                    deferingTask.taskStartTime=[ivoUtility newDateFromDate:deferingTask.taskStartTime offset:86400];
				}else if(type==2){
					//[comps setDay:[comps day]+2];
                    deferingTask.taskStartTime=[ivoUtility newDateFromDate:deferingTask.taskStartTime offset:2*86400];
				}else if(type==3){
					//[comps setDay:[comps day]+7];
                    deferingTask.taskStartTime=[ivoUtility newDateFromDate:deferingTask.taskStartTime offset:7*86400];
				}
				//deferingTask.taskStartTime=[gregorian dateFromComponents:comps];
				
				//[originalDate release];
				
				//[comps setSecond:[comps second]+taskTmp.taskHowLong];
				//deferingTask.taskEndTime=[gregorian dateFromComponents:comps];
                deferingTask.taskEndTime=[ivoUtility newDateFromDate:deferingTask.taskStartTime offset:taskTmp.taskHowLong];
                
				//[deferingTask.taskStartTime dateByAddingTimeInterval:taskTmp.taskHowLong];
				
				ret=[self updateTask:deferingTask 
		  isAllowChangeDueWhenUpdate:changeDue 
						updateREType:1 
						 REUntilDate:[deferingTask.taskEndTime dateByAddingTimeInterval:timeInervalForExpandingToFillRE] 
						  updateTime:nil];
				
				if(ret.errorNo !=-1)
					self.taskList=listBackup;
                
                [deferingTask release];
				
			}
						
			goto exitFor;
		}
		
	}
	
exitFor:	
	//[App_Delegate getPartTaskList];

	[listBackup release];
	//[delayList release];
	[gregorian release];
	[deferTask release];
//	[App_Delegate stopAcitivityIndicatorThread];
	
    //printf("\n end delay");
    
	//ILOG(@"TaskManager delayTask]\n");
	return ret;
}

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex{
	//ILOG(@"[TaskManager alertView\n");
	if([alertVw isEqual:alertView]){
		if (buttonIndex==1){
			[self delayTask:updatePK delayType:delayType isAutoChangeDue:YES];
		}
	}
	//ILOG(@"TaskManager alertView]\n");
}

- (TaskActionResult *)moveTask:(NSInteger)taskKey toTask:(NSInteger)toTaskKey isAutoChangeDue:(BOOL)isAutoChangeDue{
	//ILOG(@"[TaskManager moveTask\n");
		
    //printf("\n start move");
    
	TaskActionResult *ret=[[TaskActionResult alloc] init];
	ret.errorNo=-1;
	ret.errorMessage=nil;
	ret.overdueTimeSlotFound=nil;
	
	NSInteger fromIndex;
	NSInteger toIndex;
	BOOL isPinnedTask=NO;
	NSDate *currentDate=[NSDate date];
	
	if (self.taskList.count<2){
		//return ret;	
		goto exitMove;
	}
	
	if([ivoUtility getIndex:self.taskList :taskKey]== ([ivoUtility getIndex:self.taskList :toTaskKey]-1)){
		//ILOG(@"TaskManager moveTask]\n");
		//return ret;	
		goto exitMove;
	}
	
	NSMutableArray *list=[[NSMutableArray alloc] initWithArray:self.taskList];//backup
	Task *tmpTask=[[Task alloc] init];
	NSDate *startFromDate=nil;
	
	NSDate *searchTimeSlotFromDate;
	NSDate *getRepeatInstancesUntil=[self lastTaskEndDateInList:self.taskList];
	
	fromIndex=[ivoUtility getIndex:self.taskList :taskKey];
	[ivoUtility copyTask:[self.taskList objectAtIndex:fromIndex] toTask:tmpTask isIncludedPrimaryKey:YES];
	if (tmpTask.taskPinned==1){
		tmpTask.taskPinned=0;
		isPinnedTask=YES;
	}
	
	if(toTaskKey==-1){//move out of the end of list
		toIndex=self.taskList.count-1;
	}else {
		toIndex=[ivoUtility getIndex:self.taskList :toTaskKey];
	}

	if(fromIndex==toIndex){
		if(tmpTask !=nil){
			[tmpTask release];
			tmpTask=nil;
		}		
		
		if(list !=nil){
			[list release];
			list=nil;
		}
		
		//return ret;
		goto exitMove;
	}

//	[App_Delegate showAcitivityIndicatorThread];

	NSMutableArray *splitedTasksFromOverlap=[[NSMutableArray alloc] initWithCapacity:5];
	if(toTaskKey!=-1){
		if (fromIndex<toIndex){//move down
			//[self splitUnPinchedTasksFromTaskList:self.taskList fromIndex:toIndex toList:splitedTasksFromOverlap context:-1];
			[self.taskList removeObjectAtIndex:fromIndex];
			[self.taskList insertObject:tmpTask atIndex:toIndex];
			[self splitUnPinchedTasksFromTaskList:self.taskList fromIndex:fromIndex toList:splitedTasksFromOverlap context:-1];
			//[splitedTasksFromOverlap insertObject:tmpTask atIndex:0];
			
			if(ret) [ret release];
			ret=[self deleteTask:tmpTask.primaryKey isDeleteFromDB:NO deleteREType:-1];//delete from list and reset the start time for the unpinned task from the original position moved task to the new position moved task.
			if (ret.errorNo !=-1){
				//delete error -> rollback
				self.taskList=list;
				if(tmpTask !=nil){
					[tmpTask release];
					tmpTask=nil;
				}				
				
				if(list !=nil){
					[list release];
					list=nil;
				}
				
				//[dueBeforeTaskMoveTo release];
				if(splitedTasksFromOverlap !=nil){
					[splitedTasksFromOverlap release];
					splitedTasksFromOverlap=nil;
				}
				
				//ILOG(@"TaskManager moveTask]\n");
				//return ret;
				goto exitMove;
			}
			//toIndex=toIndex-2;
			toIndex=toIndex-1;
		}else if(fromIndex>toIndex){//move up
			[self.taskList removeObjectAtIndex:fromIndex];
			[self splitUnPinchedTasksFromTaskList:self.taskList fromIndex:toIndex toList:splitedTasksFromOverlap context:-1];
			[splitedTasksFromOverlap insertObject:tmpTask atIndex:0];
			//toIndex=toIndex-1;
		}
	}else {//move to over the end of list
		[splitedTasksFromOverlap insertObject:tmpTask atIndex:0];
		
		if(ret) [ret release];
		ret=[self deleteTask:tmpTask.primaryKey isDeleteFromDB:NO deleteREType:-1];//delete afrom list and reset the start time for the unpinned task from the original position moved task to the new position moved task.
		if (ret.errorNo !=-1){
			//delete error -> rollback
			self.taskList=list;
			
			if(tmpTask !=nil){
				[tmpTask release];
				tmpTask=nil;
			}			
			
			if(list !=nil){
				[list release];
				list=nil;
			}
			
			if(splitedTasksFromOverlap !=nil){
				[splitedTasksFromOverlap release];
				splitedTasksFromOverlap=nil;
			}
			
			//ILOG(@"TaskManager moveTask]\n");
			//return ret;
			goto exitMove;
		}		
	}

	//check if the task moving to the past
	if(toTaskKey!=-1 && splitedTasksFromOverlap.count>1){
		if([[[splitedTasksFromOverlap objectAtIndex:1] taskEndTime] compare:currentDate]==NSOrderedAscending){
			if([[[splitedTasksFromOverlap objectAtIndex:0] taskEndTime] compare:currentDate]==NSOrderedAscending){
				ret.errorNo=ERR_TASK_MOVE_PAST_TO_PAST;
			}else {
				ret.errorNo=ERR_TASK_MOVE_TO_PAST;//19;
			}
				
			self.taskList=list;
			
			if(tmpTask !=nil){
				[tmpTask release];
				tmpTask=nil;
			}
			
			if(splitedTasksFromOverlap !=nil){
				[splitedTasksFromOverlap release];
				splitedTasksFromOverlap=nil;
			}			
			
			if(list !=nil){
				[list release];
				list=nil;
			}
			
			if(startFromDate!=nil){
				[startFromDate release];
				startFromDate=nil;
			}
			//ILOG(@"TaskManager moveTask]\n");
			//return ret;		
			goto exitMove;
		}
	}
	
	//create new taskNotEalierThan

	if(startFromDate!=nil){
		[startFromDate release];
		startFromDate=nil;
	}
	
	startFromDate=[[self getEndTimeInTaskList:self.taskList beforeIndex:toIndex<self.taskList.count?toIndex:self.taskList.count-1] copy];
	if(startFromDate==nil || [startFromDate compare:currentDate]==NSOrderedAscending ){
		startFromDate=[currentDate copy];
	}
	
	[[splitedTasksFromOverlap objectAtIndex:0] setTaskDueStartDate:startFromDate];
	[[splitedTasksFromOverlap objectAtIndex:0] setTaskDueEndDate:[startFromDate dateByAddingTimeInterval:[[splitedTasksFromOverlap objectAtIndex:0] taskHowLong]]];
	
	[self resetFirstTaskContextInList:splitedTasksFromOverlap];
	
	//[self sortList:splitedTasksFromOverlap byKey:@"taskDueEndDate"];
	
	NSMutableArray *splitedTasksNoDeaLineFromDueEndList=[[NSMutableArray alloc] initWithCapacity:2];
	[self splitTasksByDeadLineFromTaskList:splitedTasksFromOverlap fromIndex:0 toList:splitedTasksNoDeaLineFromDueEndList context:-1 byDeadLine:0];
	
	self.REList=[self getREListFromTaskList:self.taskList];
	[self fillRepeatEventInstances:self.REList 
							toList:self.taskList 
						  fromDate:[NSDate date] 
			  getInstanceUntilDate:[getRepeatInstancesUntil dateByAddingTimeInterval:timeInervalForExpandingToFillRE] 
			   isShowPastInstances:NO 
				 isCleanOldDummies:YES 
			  isRememberFilledDate:NO
		  isNeedAtLeastOneInstance:NO];
	[self sortList:self.taskList byKey:@"taskStartTime"];
	
	DateTimeSlot *getTimeSlotResult=nil;
	
//	if (splitedTasksFromOverlap.count>0){
//		Task *tmp=[splitedTasksFromOverlap objectAtIndex:0];
//		searchTimeSlotFromDate=[self smartEndOfLastTaskInList:self.taskList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
//	}
	//try to add first for testing.
	//add task with deadline first
	for (Task *tmp in splitedTasksFromOverlap){
		
		//find new time slot for each splitted task
		
		searchTimeSlotFromDate=[self smartEndOfLastTaskInList:self.taskList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
		//find new time slot for each splitted task
		if(([searchTimeSlotFromDate compare:tmp.taskStartTime] !=NSOrderedSame) || 
		   [tmp isEqual:[splitedTasksFromOverlap objectAtIndex:0]]){
			getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:self.taskList startFromDate:searchTimeSlotFromDate toDate:[searchTimeSlotFromDate dateByAddingTimeInterval:THREE_MONTH_INTERVAL]];
		}else {
			getTimeSlotResult=[[DateTimeSlot alloc] init];
			getTimeSlotResult.timeSlotDate=tmp.taskStartTime;
			getTimeSlotResult.indexAt=[ivoUtility getTimeSlotIndexForTask:tmp inArray:self.taskList];
			getTimeSlotResult.isOverDue=NO;
			getTimeSlotResult.isPassedDeadLine=NO;
		}
		
		//if([self isNotFitTask:getTimeSlotResult.timeSlotDate lastREInstanceDate:endInstanceDate inList:self.taskList]){	
		if(getTimeSlotResult.isNotFit){
			ret.errorNo=ERR_TASK_NOT_BE_FIT_BY_RE;
			if(tmpTask !=nil){
				[tmpTask release];
				tmpTask=nil;
			}
			
			if(startFromDate!=nil){
				[startFromDate release];
				startFromDate=nil;
			}
			if(getTimeSlotResult!=nil){
				[getTimeSlotResult release];
				getTimeSlotResult=nil;
			}
			
			if(splitedTasksFromOverlap !=nil){
				[splitedTasksFromOverlap release];
				splitedTasksFromOverlap=nil;
			}
			
			if (splitedTasksNoDeaLineFromDueEndList !=nil){
				[splitedTasksNoDeaLineFromDueEndList release];
				splitedTasksNoDeaLineFromDueEndList=nil;
			}
			
			self.taskList=list;
			
			if(list !=nil){
				[list release];
				list=nil;
			}
			
			//return ret;
			goto exitMove;
			
		}else if(getTimeSlotResult.indexAt > -1){
			if(getTimeSlotResult.isPassedDeadLine && tmp.taskIsUseDeadLine){
				if(currentSetting.dueWhenMove==0 || isAutoChangeDue){
					//expand deadline to the date when new time slot found
					NSDate *newDeadLine=[ivoUtility createDeadLine:DEADLINE_TODAY fromDate:getTimeSlotResult.timeSlotDate context:tmp.taskWhere];
					tmp.taskDeadLine=newDeadLine;
					tmp.taskDueEndDate=newDeadLine;
					
					if(newDeadLine!=nil){
						[newDeadLine release];
						newDeadLine=nil;
					}
					
				}else {
					
					if(tmp.primaryKey==taskKey){
						ret.errorNo=ERR_TASK_ITSELF_PASS_DEADLINE;
					}else {
						ret.errorNo=ERR_TASK_ANOTHER_PASS_DEADLINE;
					}
				
					if(tmpTask !=nil){
						[tmpTask release];
						tmpTask=nil;
					}
					
					if(startFromDate!=nil){
						[startFromDate release];
						startFromDate=nil;
					}
					if(getTimeSlotResult!=nil){
						[getTimeSlotResult release];
						getTimeSlotResult=nil;
					}
					
					if(splitedTasksFromOverlap !=nil){
						[splitedTasksFromOverlap release];
						splitedTasksFromOverlap=nil;
					}
					
					if (splitedTasksNoDeaLineFromDueEndList !=nil){
						[splitedTasksNoDeaLineFromDueEndList release];
						splitedTasksNoDeaLineFromDueEndList=nil;
					}
					
					self.taskList=list;
					
					if(list !=nil){
						[list release];
						list=nil;
					}
					
					//return ret;
					goto exitMove;
				}
			}
			
			if(getTimeSlotResult.isOverDue){
				tmp.taskDueStartDate=getTimeSlotResult.timeSlotDate;
				tmp.taskDueEndDate=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
			}
			
			tmp.taskStartTime=getTimeSlotResult.timeSlotDate;
			tmp.taskEndTime=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
//			if(tmp.primaryKey==tmpTask.primaryKey)
//			tmp.taskDueEndDate=tmp.taskEndTime;
			[self.taskList insertObject:tmp atIndex:getTimeSlotResult.indexAt];
//			searchTimeSlotFromDate=tmp.taskEndTime;
		}
		if(getTimeSlotResult!=nil){
			[getTimeSlotResult release];
			getTimeSlotResult=nil;
		}
		
	}
	
//	if (splitedTasksNoDeaLineFromDueEndList.count>0){
//		Task *tmp=[splitedTasksNoDeaLineFromDueEndList objectAtIndex:0];
//		searchTimeSlotFromDate=[self smartEndOfLastTaskInList:self.taskList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
//	}
	
	//add task without deadline last
	for (Task *tmp in splitedTasksNoDeaLineFromDueEndList){
		
		//find new time slot for each splitted task
		//getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:self.taskList startFromDate:searchTimeSlotFromDate];
		
		searchTimeSlotFromDate=[self smartEndOfLastTaskInList:self.taskList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
		//find new time slot for each splitted task
		if(([searchTimeSlotFromDate compare:tmp.taskStartTime] !=NSOrderedSame ) || 
		   [tmp isEqual:[splitedTasksNoDeaLineFromDueEndList objectAtIndex:0]]){
			getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:self.taskList startFromDate:searchTimeSlotFromDate toDate:[searchTimeSlotFromDate dateByAddingTimeInterval:THREE_MONTH_INTERVAL]];
		}else {
			getTimeSlotResult=[[DateTimeSlot alloc] init];
			getTimeSlotResult.timeSlotDate=tmp.taskStartTime;
			getTimeSlotResult.indexAt=[ivoUtility getTimeSlotIndexForTask:tmp inArray:self.taskList];
			getTimeSlotResult.isOverDue=NO;
			getTimeSlotResult.isPassedDeadLine=NO;
		}
		
		//if([self isNotFitTask:getTimeSlotResult.timeSlotDate lastREInstanceDate:endInstanceDate inList:self.taskList]){	
		if(getTimeSlotResult.isNotFit){
			ret.errorNo=ERR_TASK_NOT_BE_FIT_BY_RE;
			if(tmpTask !=nil){
				[tmpTask release];
				tmpTask=nil;
			}
			
			if(startFromDate!=nil){
				[startFromDate release];
				startFromDate=nil;
			}
			if(getTimeSlotResult!=nil){
				[getTimeSlotResult release];
				getTimeSlotResult=nil;
			}
			
			if(splitedTasksFromOverlap !=nil){
				[splitedTasksFromOverlap release];
				splitedTasksFromOverlap=nil;
			}
			
			if (splitedTasksNoDeaLineFromDueEndList !=nil){
				[splitedTasksNoDeaLineFromDueEndList release];
				splitedTasksNoDeaLineFromDueEndList=nil;
			}
			
			self.taskList=list;
			
			if(list !=nil){
				[list release];
				list=nil;
			}
			
			//return ret;
			goto exitMove;
			
		}else if(getTimeSlotResult.indexAt > -1){
			if(getTimeSlotResult.isOverDue){
				tmp.taskDueEndDate=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
				tmp.taskDeadLine=tmp.taskDueEndDate;
			}
			
			tmp.taskStartTime=getTimeSlotResult.timeSlotDate;
			tmp.taskEndTime=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
//			if(tmp.primaryKey==tmpTask.primaryKey)
//			tmp.taskDueEndDate=tmp.taskEndTime;
			[self.taskList insertObject:tmp atIndex:getTimeSlotResult.indexAt];
//			searchTimeSlotFromDate=tmp.taskEndTime;
		}
		if(getTimeSlotResult!=nil){
			[getTimeSlotResult release];
			getTimeSlotResult=nil;
		}
	}
	
	//update due end date for the delaying task---------------------------
	[self updateNewDueEndDateForUpdatedTask:tmpTask inList:self.taskList];

	//update databse
//	for (Task *tmp in splitedTasksFromOverlap){
//		[tmp update];
//	}
	
//	for (Task *tmp in splitedTasksNoDeaLineFromDueEndList){
//		[tmp update];
//	}
	
	//ST 3.3.1 update the rest tasks on task List
    NSMutableArray *sourceList=[NSMutableArray arrayWithArray:self.taskList];
	for(Task *task in sourceList){
		if(task.taskPinned==0){
			[task update];
		}
	}
	
	if(splitedTasksFromOverlap !=nil){
		[splitedTasksFromOverlap release];
		splitedTasksFromOverlap=nil;
	}	
	
	if (splitedTasksNoDeaLineFromDueEndList !=nil){
		[splitedTasksNoDeaLineFromDueEndList release];
		splitedTasksNoDeaLineFromDueEndList=nil;
	}
		
	if(getTimeSlotResult!=nil){
		[getTimeSlotResult release];
		getTimeSlotResult=nil;
	}
	
	//re-update DueEnd
//**
//	fromIndex=[ivoUtility getIndex:self.taskList :taskKey];
//	if(fromIndex <self.taskList.count-1){
//		Task *movedTask=[self.taskList objectAtIndex:fromIndex];
//		NSDate *tmpDate=[self getDueEndAfterInTaskList:self.taskList afterIndex:fromIndex];
//		if([movedTask.taskDueEndDate compare:tmpDate]==NSOrderedAscending){
//			movedTask.taskDueEndDate=[tmpDate dateByAddingTimeInterval:-1];
//		}
//	}
	
	
finalMove:	
	if (isPinnedTask){
		Task *movedTasks;	
		movedTasks=[sourceList objectAtIndex:[ivoUtility getIndex:sourceList :taskKey]];

		movedTasks.taskPinned=1;
		[movedTasks update];
	}
	
	//[App_Delegate getPartTaskList];
	
	if(startFromDate!=nil){
		[startFromDate release];
		startFromDate=nil;
	}
	
	if(list !=nil){
		[list release];
		list=nil;
	}
	if(tmpTask !=nil){
		[tmpTask release];
		tmpTask=nil;
	}
	
	
exitMove:	
//	[App_Delegate stopAcitivityIndicatorThread];
	
    if (!needStopSync && self.currentSetting.autoICalSync) {
        
        if (self.currentSetting.enableSyncICal) {
            [self.ekSync backgroundFullSync];
        }
        
        if (self.currentSetting.enabledReminderSync) {
            [self.reminderSync backgroundFullSync];
        }
    }

    //printf("\n\n end move");
    
	//ILOG(@"TaskManager moveTask]\n");
	return ret;	
}

-(void)updateNewDueEndDateForUpdatedTask:(Task *)task inList:(NSMutableArray *)list{
	NSDate *newDueEndDate=nil;
	if([task.taskEndTime compare:task.taskDueEndDate]==NSOrderedAscending){
		newDueEndDate=task.taskDueEndDate;
	}else{
		newDueEndDate=task.taskEndTime;
	}
	
	NSMutableArray *arr=[NSMutableArray arrayWithArray:list];
	NSInteger fromIndex=[self getIndexOfTaskByPrimaryKey:task inArray:arr];
	
	Task *updatedTask=(Task *)[arr objectAtIndex:fromIndex];
	NSDate *endDueAfter=[self getDueEndAfterInTaskList:arr afterIndex:fromIndex];
	NSDate *endDueBefore=[self getDueEndBeforeInTaskList:arr beforeIndex:fromIndex];
	
	if(endDueAfter !=nil && endDueBefore !=nil){
		if([endDueBefore compare:endDueAfter]==NSOrderedAscending){
			updatedTask.taskDueEndDate=[endDueBefore dateByAddingTimeInterval:(double)[endDueAfter timeIntervalSinceDate:endDueBefore]/2];
		}else {
			if(updatedTask.taskIsUseDeadLine){
				updatedTask.taskDueEndDate=[endDueBefore dateByAddingTimeInterval:1];//before moved Dtask is a task
			}else {
				updatedTask.taskDueEndDate=[endDueAfter dateByAddingTimeInterval:-1];//after moved task is a Dtask
			}

		}

	}else if(endDueBefore !=nil) {
		updatedTask.taskDueEndDate=[endDueBefore dateByAddingTimeInterval: 1];
	}else if(endDueAfter !=nil){
		updatedTask.taskDueEndDate=[endDueBefore dateByAddingTimeInterval: -1];
	}else {
		updatedTask.taskDueEndDate=newDueEndDate;
	}

}


- (NSDate *)getDueEndBeforeInTaskList:(NSMutableArray *)list beforeIndex:(NSInteger)beforeIndex{
	//ILOG(@"[TaskManager getDueEndInTaskList\n");
	NSDate *ret=nil;
	
	if(list.count==0) goto exitGet;//return nil;
	
	//Task *task=(Task *)[list objectAtIndex:beforeIndex];
	NSMutableArray *arr=[NSMutableArray arrayWithArray:list];
    
	for (NSInteger i=beforeIndex-1;i>=0;i--){
		Task *tmp=(Task *)[arr objectAtIndex:i];
		if([tmp taskPinned]==0){
			////printf("\n%s",[tmp.taskName UTF8String]);
			ret=[tmp taskDueEndDate];
			break;
		}
	}
	
exitGet:
	//ILOG(@"TaskManager getDueEndInTaskList]\n");
	return ret;
}
	
- (NSDate *)getDueEndAfterInTaskList:(NSMutableArray *)list afterIndex:(NSInteger)afterIndex{
	//ILOG(@"[TaskManager getDueEndInTaskList\n");
	NSDate *ret=nil;
	if(list.count==0) goto exitGet;//return nil;
	
	//Task *task=(Task *)[list objectAtIndex:afterIndex];
	NSMutableArray *arr=[NSMutableArray arrayWithArray:list];
    
	for (NSInteger i=afterIndex +1;i<list.count;i++){
		Task *tmp=(Task *)[arr objectAtIndex:i];
		if([tmp taskPinned]==0){
			////printf("\n%s",[tmp.taskName UTF8String]);
			ret=[tmp taskDueEndDate];
			break;
		}
	}
	//ILOG(@"TaskManager getDueEndInTaskList]\n");
exitGet:
	return ret;
}

- (NSDate *)getEndTimeInTaskList:(NSMutableArray *)list beforeIndex:(NSInteger)beforeIndex{
	//ILOG(@"[TaskManager getEndTimeInTaskList\n");
	NSDate *ret=nil;
	NSInteger i=-1;
	if(list.count==0) goto exitGet;//return nil;
	
    NSMutableArray *arr=[NSMutableArray arrayWithArray:list];
	for (int j=0;j<beforeIndex;j++){
		if([(Task*)[arr objectAtIndex:j] taskPinned]==0){
			i=j;
		}
	}
	
	if(i>=0){
		//ILOG(@"TaskManager getEndTimeInTaskList]\n");
		ret= (NSDate *)[(Task*)[arr objectAtIndex:i] taskEndTime];
	}
	//ILOG(@"TaskManager getDueEndInTaskList]\n");
exitGet:
	
	return ret;
}

-(void)resetFirstTaskContextInList:(NSMutableArray *)list{
	//ILOG(@"[TaskManager resetFirstTaskContextInList\n");
    NSMutableArray *arr=[NSMutableArray arrayWithArray:list];
    
	if(arr.count>=2){
		Task *firstTask=[arr objectAtIndex:0];
		Task *secondTask=[arr objectAtIndex:1];
		
		//DateTimeSlot *getTimeSlotResult=[ivoUtility createTimeSlotForDTask:tmpNewTask inArray:self.taskList startFromDate:[firstTask taskDueStartDate]];
		DateTimeSlot *getTimeSlotResult=[self createTimeSlotForDTask:tmpNewTask inArray:self.taskList startFromDate:[firstTask taskDueStartDate] toDate:[[firstTask taskDueStartDate] dateByAddingTimeInterval:THREE_MONTH_INTERVAL]];
		
		 
		if([(NSDate *)[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:firstTask.taskHowLong] compare:secondTask.taskStartTime]==NSOrderedDescending &&
			![ivoUtility isTaskInOtherContextRange:firstTask]){
		
			if(secondTask.taskWhere !=firstTask.taskWhere){
				if(firstTask.taskOriginalWhere!=-1){//backup original context
					firstTask.taskOriginalWhere=firstTask.taskWhere;
				}
				firstTask.taskWhere=secondTask.taskWhere;
			}
		}
		
		if(getTimeSlotResult !=nil){
			[getTimeSlotResult release];
			getTimeSlotResult=nil;
		}
	}
	//ILOG(@"TaskManager resetFirstTaskContextInList]\n");
}

- (TaskActionResult *)moveTaskInCalendar:(NSInteger)taskKey toTask:(NSInteger)toTaskKey expectedStartTime:(NSDate*)expectedStartTime isAutoChangeDue:(BOOL)isAutoChangeDue{
	//ILOG(@"[TaskManager moveTaskInCalendar\n");
//	[App_Delegate showAcitivityIndicatorThread];
	
    //printf("\n\n start move in calendar");
    
	TaskActionResult *ret=nil;[[TaskActionResult alloc] init];
	ret.errorNo=-1;
	ret.errorMessage=nil;
	ret.overdueTimeSlotFound=nil;
	
	//NSMutableArray *taskListBk=[self.taskList copy];//[[NSMutableArray alloc] initWithArray:(NSArray*)self.taskList];//backup task List
	
	 //self.taskListBackUp=self.taskList;
	NSMutableArray *listBackup=[[NSMutableArray alloc] initWithArray: self.taskList];
	if(expectedStartTime !=nil){//execute command only ecpectedStartTime is not nil

		Task *tmpTask=[[Task alloc] init];
		Task *tmp;//keep original moving task
		
		//keep task's position that will be moved
		tmp=[ivoUtility getTaskByPrimaryKey:taskKey inArray:self.taskList];
	
		//Copy this task as a new pinned task
		[ivoUtility copyTask:tmp toTask:tmpTask isIncludedPrimaryKey:YES];
		
		if (tmpTask.taskPinned==0){//change unpinned task to pinned task (if any)
			tmpTask.taskPinned=1;
		}
		tmpTask.taskStartTime=expectedStartTime;
		tmpTask.taskEndTime=[expectedStartTime dateByAddingTimeInterval:tmpTask.taskHowLong];
		tmpTask.taskIsUseDeadLine=0;
		tmpTask.taskTypeUpdate=1;
		
		//ret =[ivoUtility smartCheckValidationTask:tmpTask inTaskList:taskList checkFromDate:expectedStartTime];
		ret =[ivoUtility smartCheckOverlapTask:tmpTask inTaskList:self.taskList];
		
		if(ret.errorNo !=-1 && ret.errorNo !=ERR_TASK_START_OVERLAPPED && ret.errorNo !=ERR_TASK_END_OVERLAPPED && ret.errorNo !=ERR_TASK_OVERLAPS_OTHERS){
		//if(ret.errorNo !=-1 && ret.errorNo !=9 && ret.errorNo !=11 && ret.errorNo !=13){
			[self callAlert:ret.errorMessage];
			//[ret.errorMessage release];
			if(tmpTask!=nil){
				[tmpTask release];
				tmpTask=nil;
			}
			//ILOG(@"TaskManager moveTaskInCalendar]\n");
			goto exitMove;
		}
		
		
		if(ret) [ret release];
		ret=[self updateTask:tmpTask isAllowChangeDueWhenUpdate:isAutoChangeDue updateREType:1 REUntilDate:tmpTask.taskEndTime updateTime:nil];

//		if(ret.errorNo==ERR_TASK_ANOTHER_PASS_DEADLINE
//		   ||ret.errorNo==ERR_TASK_NOT_BE_FIT_BY_RE||
//		   ret.errorNo==ERR_RE_MAKE_TASK_NOT_BE_FIT){
//			//rollback change
//			self.taskList=listBackup;
//		}	
		
		if(tmpTask!=nil){
			[tmpTask release];
			tmpTask=nil;
		}
	}
exitMove:
	[listBackup release];
//	[App_Delegate stopAcitivityIndicatorThread];
	
	//ILOG(@"TaskManager moveTaskInCalendar]\n");
    
    //if (!needStopSync && self.currentSetting.enableSyncICal && self.currentSetting.autoICalSync) {
    //    [self.ekSync backgroundFullSync];
    //}
    
    //printf("\n\n end move in calendar");
	return ret;		
}

- (NSMutableArray*) getFilterListFromDate:(NSDate *)fromDate getInstanceUntilDate:(NSDate *)fillREUntilDate
{	
	//ILOG(@"[TaskManager getDisplayList\n");
	if (self.filterClause == nil || [self.filterClause isEqual:@""])
	{
		//ILOG(@"TaskManager getDisplayList]\n");
		self.filterList=nil;
		if(fillREUntilDate!=nil){
			[self fillRepeatEventInstances:self.REList
									toList:self.taskList
								  fromDate:fromDate
					  getInstanceUntilDate:fillREUntilDate
					   isShowPastInstances:YES
						 isCleanOldDummies:YES
					  isRememberFilledDate:NO
				  isNeedAtLeastOneInstance:NO];
		}else {
			NSMutableArray *tmpList=[[NSMutableArray alloc] initWithArray:self.taskList];
			self.taskList=tmpList;
			[tmpList release];
		}
		
		//self.filterList=[self createInspectDisplaylist:self.taskList];
		return self.taskList;
	}
	
	[App_Delegate getFilterTaskList:self.filterClause fromList:self.taskList];
	//self.filterList=[self createInspectDisplaylist:self.filterList];
	
	//ILOG(@"TaskManager getDisplayList]\n");
	return self.filterList;	
}

- (NSMutableArray*) getDisplayList:(NSDate *)fillREUntilDate
{	
	//ILOG(@"[TaskManager getDisplayList\n");
	if (self.filterClause == nil || [self.filterClause isEqual:@""])
	{
		//ILOG(@"TaskManager getDisplayList]\n");
		self.filterList=nil;
		if(fillREUntilDate!=nil){
			[self fillRepeatEventInstances:self.REList toList:self.taskList fromDate:nil getInstanceUntilDate:fillREUntilDate isShowPastInstances:YES isCleanOldDummies:YES isRememberFilledDate:NO  isNeedAtLeastOneInstance:NO];
		}else {
			NSMutableArray *tmpList=[[NSMutableArray alloc] initWithArray:self.taskList];
			self.taskList=tmpList;
			[tmpList release];
		}

		//self.filterList=[self createInspectDisplaylist:self.taskList];
		return self.taskList;
	}

	[App_Delegate getFilterTaskList:self.filterClause fromList:self.taskList];
	//self.filterList=[self createInspectDisplaylist:self.filterList];

	//ILOG(@"TaskManager getDisplayList]\n");
	return self.filterList;	
}
/*
-(NSMutableArray *)createInspectDisplaylist:(NSMutableArray *)list isIncludedADE:(BOOL)isIncludedADE{
	NSMutableArray *ret=[[NSMutableArray alloc] init];
	for (Task *task in list){
		NSString *taskStartStr=[ivoUtility createStringFromShortDate:task.taskStartTime];
		NSString *taskEndStr=[ivoUtility createStringFromShortDate:task.taskEndTime];
		
		//if((task.taskPinned==1 && task.isAllDayEvent==1)|| ([ivoUtility getYear:task.taskStartTime]==[ivoUtility getYear:task.taskEndTime] &&
		//   [ivoUtility getMonth:task.taskStartTime]==[ivoUtility getMonth:task.taskEndTime] &&
		//   [ivoUtility getDay:task.taskStartTime]==[ivoUtility getDay:task.taskEndTime])){
		if(!isIncludedADE && task.taskPinned==1 && task.isAllDayEvent==1 || [taskStartStr isEqualToString:taskEndStr]){
			[ret addObject:task];	
		}else {
			NSDate *tmpStartDate=task.taskStartTime;
			NSDate *tmpEndDate=nil;
			NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
			NSDateComponents *comps = [gregorian components:unitFlags fromDate:tmpStartDate];
			
			[comps setHour:24];
			[comps setMinute:0];
			tmpEndDate=[gregorian dateFromComponents:comps];
			
			if([tmpEndDate compare:task.taskEndTime]==NSOrderedDescending){
				tmpEndDate=task.taskEndTime;
			}
			
			//NSInteger loopCount=0;//used to stop the loop if unknow exception cases happened
			while ([tmpEndDate compare:task.taskEndTime]!=NSOrderedDescending){
				//loopCount+=1;
				
				//if(loopCount==730){//for debugger only
				//	//printf("\nTask Manager: Can't createInspectDisplaylist from list because of looped forever\n");
				//}
				
				Task *tmp=[[Task alloc]init];
				[ivoUtility copyTask:task toTask:tmp isIncludedPrimaryKey:YES];
				tmp.taskStartTime=tmpStartDate;
				tmp.taskEndTime=tmpEndDate;
				tmp.taskHowLong=[tmpEndDate timeIntervalSinceDate:tmpStartDate];
				[ret addObject:tmp];
				[tmp release];
				
				if([tmpEndDate compare:task.taskEndTime]==NSOrderedSame){
					break;
				}
				comps = [gregorian components:unitFlags fromDate:[tmpStartDate dateByAddingTimeInterval:86400]];
				[comps setHour:0];
				[comps setMinute:0];
				tmpStartDate=[gregorian dateFromComponents:comps];
				
				[comps setHour:24];
				[comps setMinute:0];
				tmpEndDate=[gregorian dateFromComponents:comps];
				
				if([tmpEndDate compare:task.taskEndTime]==NSOrderedDescending){
					tmpEndDate=task.taskEndTime;
				}
				
			}
			[gregorian release];
		}
	}
	
	return ret;	
}
*/
-(NSMutableArray *)createInspectDisplaylist:(NSMutableArray *)list isSplit:(BOOL)isSplit fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate{
	NSMutableArray *ret=[[NSMutableArray alloc] init];
    
    if (!toDate || !fromDate) return ret;
    
	for (Task *task in list){
		if(!isSplit && task.taskPinned==1 && task.isAllDayEvent==1){
			[ret addObject:task];	
		}else {
			if([[ivoUtility getStringFromShortDate:task.taskStartTime] isEqualToString:[ivoUtility getStringFromShortDate:task.taskEndTime]]) {
				//[ret addObject:task];
				continue;
			}
			
			NSDate *tmpStartDate=task.taskStartTime;
			//if([tmpStartDate compare:toDate] !=NSOrderedAscending ) goto exit; 
			
			NSDate *tmpEndDate=nil;
			NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
			NSDateComponents *comps = [gregorian components:unitFlags fromDate:tmpStartDate];
			
			[comps setHour:24];
			[comps setMinute:0];
			[comps setSecond:0];
			tmpEndDate=[gregorian dateFromComponents:comps];
			
			if([tmpEndDate compare:task.taskEndTime]==NSOrderedDescending){
				tmpEndDate=task.taskEndTime;
			}
			
			//while ([tmpEndDate compare:task.taskEndTime]!=NSOrderedDescending && loopCount<730){
			while ([tmpEndDate compare:task.taskEndTime]!=NSOrderedDescending){
				if([tmpStartDate compare:fromDate]!=NSOrderedAscending && [tmpEndDate compare:toDate]!=NSOrderedDescending){
					Task *tmp=[[Task alloc] init];
					[ivoUtility copyTask:task toTask:tmp isIncludedPrimaryKey:YES];
					tmp.taskStartTime=tmpStartDate;
					tmp.taskEndTime=tmpEndDate;
					tmp.taskHowLong=[tmpEndDate timeIntervalSinceDate:tmpStartDate];
					[ret addObject:tmp];
					[tmp release];
				}

				if([tmpEndDate compare:task.taskEndTime]==NSOrderedSame){
					break;
				}

				
//nang 3.6-091224
/*				
				NSDate *dt=[tmpStartDate dateByAddingTimeInterval:86400];
				if([ivo_Utilities offsetForDate:tmpStartDate] !=[ivo_Utilities offsetForDate:dt]){
					if([App_defaultTimeZone isDaylightSavingTimeForDate:tmpStartDate] && ![App_defaultTimeZone isDaylightSavingTimeForDate:dt]){
						dt=[dt dateByAddingTimeInterval:dstOffset];
					}else if(![App_defaultTimeZone isDaylightSavingTimeForDate:tmpStartDate] && [App_defaultTimeZone isDaylightSavingTimeForDate:dt]){
						dt=[dt dateByAddingTimeInterval:-dstOffset];
					}
				}
				
*/
				comps = [gregorian components:unitFlags fromDate:tmpStartDate];
				[comps setDay:[comps day] + 1];
				tmpStartDate=[gregorian dateFromComponents:comps];
				
				comps = [gregorian components:unitFlags fromDate:tmpStartDate];
				[comps setHour:0];
				[comps setMinute:0];
				[comps setSecond:0];
				tmpStartDate=[gregorian dateFromComponents:comps];
				
				[comps setHour:24];
				[comps setMinute:0];
				[comps setSecond:0];
				tmpEndDate=[gregorian dateFromComponents:comps];

				if([tmpEndDate compare:task.taskEndTime]==NSOrderedDescending){
					tmpEndDate=task.taskEndTime;
				}
				
				//if([tmpEndDate compare:toDate] !=NSOrderedAscending) goto exit;
			}
			[gregorian release];
		}
	}
exit:
	return ret;	
}

-(void )createInspectDisplayForTask:(Task *)task inList:(NSMutableArray*)list isSplit:(BOOL)isSplit fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate{
	//NSMutableArray *ret=[[NSMutableArray alloc] init];
    
    NSMutableArray *sourceList=[NSMutableArray arrayWithArray:list];
    
    if (!toDate || !fromDate) return;
    
		if(!isSplit && task.taskPinned==1 && task.isAllDayEvent==1){
			[list addObject:task];	
		}else {
			if([[ivoUtility getStringFromShortDate:task.taskStartTime] isEqualToString:[ivoUtility getStringFromShortDate:task.taskEndTime]]) {
				[list addObject:task];	
				return;
			}
			
			NSDate *tmpStartDate=task.taskStartTime;
			
			NSDate *tmpEndDate=nil;
			NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
			NSDateComponents *comps = [gregorian components:unitFlags fromDate:tmpStartDate];
			
			[comps setHour:24];
			[comps setMinute:0];
			[comps setSecond:0];
			tmpEndDate=[gregorian dateFromComponents:comps];
			
			if([tmpEndDate compare:task.taskEndTime]==NSOrderedDescending){
				tmpEndDate=task.taskEndTime;
			}
			
			//while ([tmpEndDate compare:task.taskEndTime]!=NSOrderedDescending && loopCount<730){
			while ([tmpEndDate compare:task.taskEndTime]!=NSOrderedDescending){
				if([tmpStartDate compare:fromDate]!=NSOrderedAscending && [tmpEndDate compare:toDate]!=NSOrderedDescending){
					Task *tmp=[[Task alloc] init];
					[ivoUtility copyTask:task toTask:tmp isIncludedPrimaryKey:YES];
					tmp.taskStartTime=tmpStartDate;
					tmp.taskEndTime=tmpEndDate;
					tmp.taskHowLong=[tmpEndDate timeIntervalSinceDate:tmpStartDate];
					[list addObject:tmp];
					[tmp release];
				}
				
				if([tmpEndDate compare:task.taskEndTime]==NSOrderedSame){
					break;
				}
								
//nang 3.6 - 091224
/*				
				NSDate *dt=[tmpStartDate dateByAddingTimeInterval:86400];
				if([ivo_Utilities offsetForDate:tmpStartDate] !=[ivo_Utilities offsetForDate:dt]){
					if([App_defaultTimeZone isDaylightSavingTimeForDate:tmpStartDate] && ![App_defaultTimeZone isDaylightSavingTimeForDate:dt]){
						dt=[dt dateByAddingTimeInterval:dstOffset];
					}else if(![App_defaultTimeZone isDaylightSavingTimeForDate:tmpStartDate] && [App_defaultTimeZone isDaylightSavingTimeForDate:dt]){
						dt=[dt dateByAddingTimeInterval:-dstOffset];
					}
				}
*/				
//				comps = [gregorian components:unitFlags fromDate:tmpStartDate];
//				[comps setHour:0];
//				[comps setMinute:0];
//				[comps setSecond:[comps second] + 86400];
//				tmpStartDate=[gregorian dateFromComponents:comps];
				
				comps = [gregorian components:unitFlags fromDate:tmpStartDate];
				[comps setDay:[comps day] + 1];
				tmpStartDate=[gregorian dateFromComponents:comps];
				
				comps = [gregorian components:unitFlags fromDate:tmpStartDate];
				[comps setHour:0];
				[comps setMinute:0];
				[comps setSecond:0];
				tmpStartDate=[gregorian dateFromComponents:comps];
				
				[comps setHour:24];
				[comps setMinute:0];
				[comps setSecond:0];
				tmpEndDate=[gregorian dateFromComponents:comps];
				
				if([tmpEndDate compare:task.taskEndTime]==NSOrderedDescending){
					tmpEndDate=task.taskEndTime;
				}
				
//				if(task.taskRepeatID>0 && task.taskNumberInstances>0 && [tmpEndDate compare:task.taskEndRepeatDate]!=NSOrderedAscending){
//					break;
//				}
				//if([tmpEndDate compare:toDate] !=NSOrderedAscending) goto exit;
			}
			[gregorian release];
		}
}

//Split all tasks and Dtasks from original list
- (void)splitUnPinchedTasksFromTaskList:(NSMutableArray *)list fromIndex:(NSInteger)position toList:(NSMutableArray *)outList context:(NSInteger)context {
	//ILOG(@"[TaskManager splitUnPinchedTasksFromTaskList\n");
    //printf("\n\n start split unpinched Task");
	if(outList==nil){
		outList=[[NSMutableArray alloc] init];	
	}
	
	//remove splitted task from original array
	int i=position;
	NSInteger taskContext=context;
	BOOL isInOtherRange;
	
//	NSInteger loopCount=0;//used to exit loop if unknow exception case happened
//	NSInteger totalTasks=list.count>730?list.count:730;
//	while (i<list.count && loopCount<totalTasks){
//		loopCount+=1;
//		if(loopCount==totalTasks){//for debugger only
//			//printf("\nTask Manager: Can't split unpinched task from list because of looped forever\n");
//		}
    
    NSMutableArray *sourceList=[NSMutableArray arrayWithArray:list];
    
	while (YES){
        if (i>=sourceList.count) {
            break;
        }
        
		if(taskContext!=-1){
			isInOtherRange=[ivoUtility isTaskInOtherContextRange:[sourceList objectAtIndex:i]];
		}
		
		if ([[sourceList objectAtIndex:i] taskPinned]==0 && (taskContext==-1 ? YES: ([[sourceList objectAtIndex:i] taskWhere]==context || isInOtherRange))){
			
			Task *taskTmp=[[Task alloc] init];
			[ivoUtility copyTask:[sourceList objectAtIndex:i] toTask:taskTmp isIncludedPrimaryKey:YES];
			[outList addObject:taskTmp];
			[list removeObject:[sourceList objectAtIndex:i]];
			//[sourceList removeObjectAtIndex:i];
            
			if(taskTmp !=nil){
				[taskTmp release];
				taskTmp=nil;
			}
			
			
			if( isInOtherRange){
				taskContext=-1;	
			}
		}//else {
			i++;
		//}
	}
    
    //printf("\n\n end split unpinched task");
	//ILOG(@"TaskManager splitUnPinchedTasksFromTaskList]\n");
}

//Split all tasks and Dtasks(that no passed its deadline) from original list
- (void)splitUnPinchedTasksNoPassedDeadlineFromTaskList:(NSMutableArray *)list fromIndex:(NSInteger)position toList:(NSMutableArray *)outList context:(NSInteger)context {
	//ILOG(@"[TaskManager splitUnPinchedTasksFromTaskList\n");
    
    //printf("\n start split DTask");
	if(outList==nil){
		outList=[[NSMutableArray alloc] init];	
	}
	
	//remove splitted task from original array
	int i=position;
	NSInteger taskContext=context;
	BOOL isInOtherRange;
	
//	NSInteger loopCount=0;//used to exit loop if unknow exception case happened
//	NSInteger totalTasks=list.count>730?list.count:730;
//	while (i<list.count && loopCount<totalTasks){
//		loopCount+=1;
//		if(loopCount==totalTasks){//for debugger only
//			//printf("\nTask Manager: Can't splitUnPinchedTasksNoPassedDeadlineFromTaskList from list because of looped forever\n");
//		}
    
    NSMutableArray *sourceList=[NSMutableArray arrayWithArray:list];
    
	while (i<sourceList.count){		
		if(taskContext!=-1){
			isInOtherRange=[ivoUtility isTaskInOtherContextRange:[sourceList objectAtIndex:i]];
		}
		
		if ([[sourceList objectAtIndex:i] taskPinned]==0 && (taskContext==-1 ? YES: ([[sourceList objectAtIndex:i] taskWhere]==context || isInOtherRange))){
			if(!([[sourceList objectAtIndex:i] taskIsUseDeadLine] && [[[sourceList objectAtIndex:i] taskDeadLine] compare:[NSDate date]]==NSOrderedAscending)){
				Task *taskTmp=[[Task alloc] init];
				[ivoUtility copyTask:[sourceList objectAtIndex:i] toTask:taskTmp isIncludedPrimaryKey:YES];
				[outList addObject:taskTmp];
				[list removeObject:[sourceList objectAtIndex:i]];
				//[sourceList removeObjectAtIndex:i];
                
				if(taskTmp !=nil){
					[taskTmp release];
					taskTmp=nil;
				}
			
				if( isInOtherRange){
					taskContext=-1;	
			
				}
			}//else {
			//	i++;
			//}

		}//else {
			i++;
		//}
	}
    
    //printf("\n\n end split DTask");
	//ILOG(@"TaskManager splitUnPinchedTasksFromTaskList]\n");
}

//split all tasks/Dtasks from original list start from a date.
- (void)splitTasksFromStartTime:(NSMutableArray *)list fromStartTime:(NSDate *)startTime toList:(NSMutableArray *)outList context:(NSInteger)context {
	//ILOG(@"[TaskManager splitTasksFromStartTime\n");
    
    //printf("\n\n start split Task");
    
	if(outList==nil){
		outList=[[NSMutableArray alloc] init];	
	}
	
	//remove splitted task from original array
	int i=0;
	NSInteger taskContext=context;
	BOOL isInOtherRange;
	
//	NSInteger loopCount=0;//used to exit loop if unknow exception case happened
//	NSInteger totalTasks=list.count>730?list.count:730;
//	while (i<list.count && loopCount<totalTasks){
//		loopCount+=1;
//		if(loopCount==totalTasks){//for debugger only
//			//printf("\nTask Manager: Can't splitTasksFromStartTime from list because of looped forever\n");
//		}
    
    NSMutableArray *sourceList=[NSMutableArray arrayWithArray:list];
	while (i<sourceList.count){	
		if([[sourceList objectAtIndex:i] taskPinned]==0 && [[[sourceList objectAtIndex:i] taskStartTime] compare:startTime]==NSOrderedDescending){
			if(taskContext!=-1){
				isInOtherRange=[ivoUtility isTaskInOtherContextRange:[sourceList objectAtIndex:i]];
			}
			//taskContext=-1: mean all context?
			if (taskContext==-1 ? YES: ([[sourceList objectAtIndex:i] taskWhere]==context || isInOtherRange)){
			//if ([[list objectAtIndex:i] taskPinned]==0 && (taskContext==-1 ? YES: ([[list objectAtIndex:i] taskWhere]==context || isInOtherRange))){
			
				Task *taskTmp=[[Task alloc] init];
				[ivoUtility copyTask:[sourceList objectAtIndex:i] toTask:taskTmp isIncludedPrimaryKey:YES];
				[outList addObject:taskTmp];
				[list removeObject:[sourceList objectAtIndex:i]];
				//[sourceList removeObjectAtIndex:i];
                
				if(taskTmp !=nil){
					[taskTmp release];
					taskTmp=nil;
				}				
			
				if( isInOtherRange){
					taskContext=-1;	
				}
			}//else {
			//	i++;
			//}
		}//else {
			i++;
		//}

	}
    
    //printf("\n\n end split Task");
	//ILOG(@"TaskManager splitTasksFromStartTime]\n");
}

//split only Dtasks from a tasks/Dtasks list
- (void)splitTasksByDeadLineFromTaskList:(NSMutableArray *)list fromIndex:(NSInteger)position toList:(NSMutableArray *)outList context:(NSInteger)context byDeadLine:(NSInteger)byDeadLine{
	//ILOG(@"[TaskManager splitUnPinchedTasksFromTaskList\n");
    
    //printf("\n\n start split Task by Deadline");
    
	if(outList==nil){
		outList=[[NSMutableArray alloc] init];	
	}
	
	//remove splitted task from original array
	int i=position;
	NSInteger taskContext=context;
	BOOL isInOtherRange;
	
//	NSInteger loopCount=0;//used to exit loop if unknow exception case happened
//	NSInteger totalTasks=list.count>730?list.count:730;
//	while (i<list.count && loopCount<totalTasks){
//		loopCount+=1;
//		if(loopCount==totalTasks){//for debugger only
//			//printf("\nTask Manager: Can't splitTasksByDeadLineFromTaskList from list because of looped forever\n");
//		}
    
    NSMutableArray *sourceList=[NSMutableArray arrayWithArray:list];
    
	while (i<sourceList.count){		
		if(taskContext!=-1){
			isInOtherRange=[ivoUtility isTaskInOtherContextRange:[sourceList objectAtIndex:i]];
		}
		
		if ([[sourceList objectAtIndex:i] taskPinned]==0 && [[sourceList objectAtIndex:i] taskIsUseDeadLine]==byDeadLine  
			&& (taskContext==-1 ? YES: ([[sourceList objectAtIndex:i] taskWhere]==context || isInOtherRange))){
			
			Task *taskTmp=[[Task alloc] init];
			[ivoUtility copyTask:[sourceList objectAtIndex:i] toTask:taskTmp isIncludedPrimaryKey:YES];
			[outList addObject:taskTmp];
			[list removeObject:[sourceList objectAtIndex:i]];
			//[sourceList removeObjectAtIndex:i];
            
			if(taskTmp !=nil){
				[taskTmp release];
				taskTmp=nil;
			}
			
			
			if( isInOtherRange){
				taskContext=-1;	
			}
		}//else {
			i++;
		//}
	}
	//ILOG(@"TaskManager splitUnPinchedTasksFromTaskList]\n");
    
    //printf("\n\n end split Task by deadline");
}


-(void)refreshREList{
	NSMutableArray *ret=[App_Delegate createREListFromDate:nil toDate:nil];
	self.REList=ret;
	[ret release];
}

- (TaskActionResult *)addNewTask:(Task *)task toArray:(NSMutableArray *)list isAllowChangeDueWhenAdd:(BOOL)isAllowChangeDueWhenAdd {
	
    //NSMutableArray *sourceList=[NSMutableArray arrayWithArray:list];
    
	//ILOG(@"[TaskManager addNewTask\n");
	//	[App_Delegate showAcitivityIndicatorThread];
	
	TaskActionResult *ret=nil;//[[TaskActionResult alloc] init];
	
	TaskActionResult *overlapCheck=nil;
	
	//	NSMutableArray *newList=[[NSMutableArray alloc] initWithArray:self.eventList];
	//	[newList addObjectsFromArray:self.REList];
	//	[newList addObjectsFromArray:self.dummiesList];
	
	//backup present new task
	if(tmpNewTask!=nil){
		[tmpNewTask	release];
		tmpNewTask=nil;
	}
	
	tmpNewTask=[[Task alloc] init];
	
	[ivoUtility copyTask:task toTask:tmpNewTask isIncludedPrimaryKey:YES];
	
	NSDate *searchTimeSlotFromDate;
	NSDate *getRepeatInstancesUntil=[self lastTaskEndDateInList:self.taskList];
	BOOL isNeedToCheck=YES;
	NSMutableArray *tmpREList=[[NSMutableArray alloc] init];
	//NSDate *endInstanceDate;
	
	//we will start to get the task list from begin of today, the task is in the past from 
	//yesterday must be Dtasks which are over their deadlines
	NSDate *today=[NSDate date];
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit|NSSecondCalendarUnit;
	
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:today];	
	[comps setSecond:0];
	[comps setMinute:0];
	[comps setHour:0];
	
	today=[gregorian dateFromComponents:comps];
	[gregorian release];
	
	//repeare a unique list for re-organization the list with new one
	NSMutableArray *newList=[[NSMutableArray alloc] initWithArray:self.taskList];
	
	self.REList=[self getREListFromTaskList:newList];
	
	switch (task.taskPinned) {
		case 1://new Event
		{
			//NSMutableArray *dtasks=[App_Delegate createDTaskListFromDate:nil toDate:nil context:-1];
			//NSMutableArray *ntasks=[App_Delegate createNormalTaskListFromDate:nil toDate:nil context:-1];
			//[newList addObjectsFromArray:dtasks];
			//[newList addObjectsFromArray:ntasks];
			//[dtasks release];
			//[ntasks release];
			
			//[self sortList:newList byKey:@"taskStartTime"];
			
			if(self.REList.count>0){
				[self fillRepeatEventInstances:self.REList 
										toList:newList 
									  fromDate:today 
						  getInstanceUntilDate:[getRepeatInstancesUntil dateByAddingTimeInterval:timeInervalForExpandingToFillRE] 
						   isShowPastInstances:NO 
							 isCleanOldDummies:YES 
						  isRememberFilledDate:NO
					  isNeedAtLeastOneInstance:NO];
			}
			
			[self sortList:newList byKey:@"taskStartTime"];
			
			if((task.isAllDayEvent==1) || (task.taskRepeatID==0 && [task.taskEndTime compare:[NSDate date]]==NSOrderedAscending) || (task.taskRepeatID>0 && task.taskRepeatTimes>0 &&[task.taskEndRepeatDate compare:[NSDate date]]==NSOrderedAscending)){
				if(task.isAllDayEvent==1){
					if(task.taskRepeatTimes>0 && task.taskNumberInstances<=0){
						repeatCountTime ret=[ivoUtility createRepeatCountFromEndDate:task.taskREStartTime //replace endtime to be startTime 
																		  typeRepeat:task.taskRepeatID 
																			  toDate:task.taskEndRepeatDate 
																	repeatOptionsStr:task.taskRepeatOptions
																		 reStartDate:task.taskREStartTime];
						
						[tmpNewTask setTaskNumberInstances:ret.numberOfInstances];
					}
				}
				
				//in the past, no need to check
				isNeedToCheck=NO;
				goto smartCheck;
			}
			
			if(task.taskRepeatID>0){
				task.taskREStartTime=task.taskStartTime;
				tmpNewTask.taskREStartTime=tmpNewTask.taskStartTime;
				
				if(task.taskRepeatTimes>0 && task.taskNumberInstances<=0){
					repeatCountTime ret=[ivoUtility createRepeatCountFromEndDate:task.taskREStartTime //replace endtime to be startTime 
																	  typeRepeat:task.taskRepeatID 
																		  toDate:task.taskEndRepeatDate 
																repeatOptionsStr:task.taskRepeatOptions
																	 reStartDate:task.taskREStartTime];
					
					[tmpNewTask setTaskNumberInstances:ret.numberOfInstances];
				}
				
				
				[tmpREList addObject:task];
				
				//just get the number of dummies enough for calculating time slot for tasks
				//and quick check for the new RE series 
				[self fillRepeatEventInstances:[NSArray arrayWithObject:task] 
										toList:tmpREList 
									  fromDate:task.taskREStartTime 
						  getInstanceUntilDate:[[NSDate date] dateByAddingTimeInterval:timeInervalForExpandingToFillRE] 
						   isShowPastInstances:NO 
							 isCleanOldDummies:YES 
						  isRememberFilledDate:NO
					  isNeedAtLeastOneInstance:NO];
				
				for (Task *tmpInstance in  tmpREList){
					if(overlapCheck) [overlapCheck release];
					overlapCheck=[ivoUtility smartCheckOverlapTask:tmpInstance inTaskList:newList];
					if (overlapCheck.errorNo==ERR_TASK_START_OVERLAPPED||overlapCheck.errorNo==ERR_TASK_END_OVERLAPPED||overlapCheck.errorNo==ERR_TASK_OVERLAPS_OTHERS){
						break;
					}
//					[overlapCheck release];
//					overlapCheck=nil;
				}
			}else {
				if(overlapCheck) [overlapCheck release];
				overlapCheck=[ivoUtility smartCheckOverlapTask:tmpNewTask inTaskList:newList];
			}
			
		smartCheck:			
			if (isNeedToCheck && overlapCheck && (overlapCheck.errorNo==ERR_TASK_START_OVERLAPPED||overlapCheck.errorNo==ERR_TASK_END_OVERLAPPED||overlapCheck.errorNo==ERR_TASK_OVERLAPS_OTHERS)){
				
				//get the sublist from the overlap task to re-arrange
				NSMutableArray *splitedTasksFromOverlapped=[[NSMutableArray alloc] init];
				[self splitUnPinchedTasksFromTaskList:newList fromIndex:overlapCheck.errorAtTaskIndex toList:splitedTasksFromOverlapped context:-1];
				[self sortList:splitedTasksFromOverlapped byKey:@"taskDueEndDate"];
				
				NSMutableArray *splitedTasksNoDeaLineFromOverlapped=[[NSMutableArray alloc] init];
				[self splitTasksByDeadLineFromTaskList:splitedTasksFromOverlapped fromIndex:0 toList:splitedTasksNoDeaLineFromOverlapped context:-1 byDeadLine:0];
				[self sortList:splitedTasksNoDeaLineFromOverlapped byKey:@"taskDueEndDate"];
				
				if(tmpNewTask.taskRepeatID==0){
					[newList addObject:task];
				}
				
				//[self fillRepeatEventInstances:[NSArray arrayWithObject:task] toList:tmpREList fromDate:[NSDate date] getInstanceUntilDate:getRepeatInstancesUntil isShowPastInstances:NO];
				[newList addObjectsFromArray:tmpREList];
				[self sortList:newList byKey:@"taskStartTime"];
				
//				if (splitedTasksFromOverlapped.count>0){
//					Task *tmp=[splitedTasksFromOverlapped objectAtIndex:0];
//					searchTimeSlotFromDate=[self smartEndOfLastTaskInList:newList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
//				}

				//add task with deadline first
				for (Task *tmp in splitedTasksFromOverlapped){
					
					searchTimeSlotFromDate=[self smartEndOfLastTaskInList:newList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
					//find new time slot for each splitted task
					DateTimeSlot *getTimeSlotResult=nil;
					if(task.taskRepeatID>0){
						getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:newList startFromDate:searchTimeSlotFromDate toDate:[searchTimeSlotFromDate dateByAddingTimeInterval:THREE_MONTH_INTERVAL]];
					}else {
						if(([searchTimeSlotFromDate compare:tmp.taskStartTime] !=NSOrderedSame) || 
						   [tmp isEqual:[splitedTasksFromOverlapped objectAtIndex:0]] || [searchTimeSlotFromDate compare:tmp.taskNotEalierThan]==NSOrderedAscending){
							getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:newList startFromDate:searchTimeSlotFromDate toDate:[searchTimeSlotFromDate dateByAddingTimeInterval:THREE_MONTH_INTERVAL]];
						}else {
							getTimeSlotResult=[[DateTimeSlot alloc] init];
							getTimeSlotResult.timeSlotDate=tmp.taskStartTime;
							getTimeSlotResult.indexAt=[ivoUtility getTimeSlotIndexForTask:tmp inArray:newList];
							getTimeSlotResult.isOverDue=NO;
							getTimeSlotResult.isPassedDeadLine=NO;
						}
					}
					
					if(getTimeSlotResult.isNotFit){
						ret.errorNo=ERR_RE_MAKE_TASK_NOT_BE_FIT;
						ret.errorAtTaskIndex=9999;
						
						[getTimeSlotResult release];
						[splitedTasksFromOverlapped release];
						[splitedTasksNoDeaLineFromOverlapped release];
						[newList release];
						//return ret;
						goto endAdd;
						
					}else if(getTimeSlotResult.indexAt > -1){
						if(getTimeSlotResult.isPassedDeadLine && tmp.taskIsUseDeadLine){
							if(currentSetting.dueWhenMove==0 || isAllowChangeDueWhenAdd){
								//expand deadline to the date when new time slot found
								NSDate *newDeadLine=[ivoUtility createDeadLine:DEADLINE_TODAY fromDate:getTimeSlotResult.timeSlotDate context:tmp.taskWhere];
								tmp.taskDeadLine=newDeadLine;
								if(newDeadLine!=nil){
									[newDeadLine release];
									newDeadLine=nil;
								}
								
							}else {
								ret.errorNo=ERR_TASK_ANOTHER_PASS_DEADLINE;
								
								[getTimeSlotResult release];
								[splitedTasksFromOverlapped release];
								[splitedTasksNoDeaLineFromOverlapped release];
								[newList release];
								//return ret;
								goto endAdd;
							}
						}
						
						if(getTimeSlotResult.isOverDue){
							tmp.taskDueEndDate=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
						}
						
						tmp.taskStartTime=getTimeSlotResult.timeSlotDate;
						tmp.taskEndTime=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
						//						tmp.taskDueEndDate=tmp.taskEndTime;
						[newList insertObject:tmp atIndex:getTimeSlotResult.indexAt];
//						searchTimeSlotFromDate=tmp.taskEndTime;
						//searchTimeSlotFromDate=tmp.taskEndTime;
					}
					
					[getTimeSlotResult release];
				}
				
//				if (splitedTasksNoDeaLineFromOverlapped.count>0){
//					Task *tmp=[splitedTasksNoDeaLineFromOverlapped objectAtIndex:0];
//					searchTimeSlotFromDate=[self smartEndOfLastTaskInList:newList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
//				}
				
				//add tasks without deadline last
				for (Task *tmp in splitedTasksNoDeaLineFromOverlapped){
					
					//find new time slot for each splitted task
					DateTimeSlot *getTimeSlotResult=nil;
					searchTimeSlotFromDate=[self smartEndOfLastTaskInList:newList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
					
					if(task.taskRepeatID>0){
						getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:newList startFromDate:searchTimeSlotFromDate toDate:[searchTimeSlotFromDate dateByAddingTimeInterval:THREE_MONTH_INTERVAL]];
					}else {
						if(([searchTimeSlotFromDate compare:tmp.taskStartTime] !=NSOrderedSame) || 
						   [tmp isEqual:[splitedTasksNoDeaLineFromOverlapped objectAtIndex:0]] || [searchTimeSlotFromDate compare:tmp.taskNotEalierThan]==NSOrderedAscending){
							getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:newList startFromDate:searchTimeSlotFromDate toDate:[searchTimeSlotFromDate dateByAddingTimeInterval:THREE_MONTH_INTERVAL]];
						}else {
							getTimeSlotResult=[[DateTimeSlot alloc] init];
							getTimeSlotResult.timeSlotDate=tmp.taskStartTime;
							getTimeSlotResult.indexAt=[ivoUtility getTimeSlotIndexForTask:tmp inArray:newList];
							getTimeSlotResult.isOverDue=NO;
							getTimeSlotResult.isPassedDeadLine=NO;
						}
					}
					
					if(getTimeSlotResult.isNotFit){
						ret.errorNo=ERR_RE_MAKE_TASK_NOT_BE_FIT;
						ret.errorAtTaskIndex=9999;
						
						[getTimeSlotResult release];
						[splitedTasksFromOverlapped release];
						[splitedTasksNoDeaLineFromOverlapped release];
						[newList release];
						//return ret;
						goto endAdd;
					}else if(getTimeSlotResult.indexAt > -1){
						if(getTimeSlotResult.isOverDue){
							tmp.taskDueEndDate=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
							tmp.taskDeadLine=tmp.taskDueEndDate;
						}
						
						tmp.taskStartTime=getTimeSlotResult.timeSlotDate;
						tmp.taskEndTime=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
						//						tmp.taskDueEndDate=tmp.taskEndTime;
						[newList insertObject:tmp atIndex:getTimeSlotResult.indexAt];
						
//						searchTimeSlotFromDate=tmp.taskEndTime;
						//searchTimeSlotFromDate=tmp.taskEndTime;
						
					}
					
					[getTimeSlotResult release];
				}
				
				//update databse
				for (Task *tmp in newList){
					if(tmp.primaryKey > -1)
						[tmp update];
				}
				
				/*
				for (Task *tmp in splitedTasksNoDeaLineFromOverlapped){
					[tmp update];
				}
				*/
				
				//add new event to databse 
				Task *newEvent=[ivoUtility getTaskByPrimaryKey:-1 inArray:newList];
				NSInteger newPk=[App_Delegate addTask:newEvent];
				newEvent.primaryKey=newPk;
				ret.taskPrimaryKey=newPk;
				/*			
				 //save dummies if new task is an RE 
				 if(newEvent.taskRepeatID>0){
				 for (Task *tmp in tmpREList){
				 if(tmp.primaryKey<=-2){
				 tmp.taskKey=tmp.primaryKey;
				 [tmp prepareDummyIntoDatabase:database];
				 [tmp updateDummy];
				 NSInteger i=tmp.primaryKey;
				 tmp.primaryKey=tmp.taskKey;
				 tmp.taskKey=i;
				 }else {
				 tmp.filledDummiesToDate=[[NSDate date] dateByAddingTimeInterval:THREE_MONTH_INTERVAL];
				 [tmp update];
				 }
				 }
				 
				 [self.dummiesList addObjectsFromArray:tmpREList];
				 }
				 */		
				//add to member lists
				/*				if(newEvent.isAllDayEvent){
				 [self.adeList addObject:newEvent];
				 }else if(tmpNewTask.taskRepeatID==0){
				 [self.eventList addObject:newEvent];
				 }else {
				 [self.REList addObject:newEvent];
				 }
				 */
				[splitedTasksFromOverlapped release];
				[splitedTasksNoDeaLineFromOverlapped release];
				
			}else{
				//NSInteger i=[ivoUtility getTimeSlotIndexForTask:tmpNewTask inArray:newList];
				NSInteger newPk=[App_Delegate addTask:tmpNewTask];
				tmpNewTask.primaryKey=newPk;
				ret.taskPrimaryKey=newPk;
				
				//[newList insertObject:tmpNewTask atIndex:i];
				[newList addObject:tmpNewTask];
				
				/*				//add to member lists
				 if(tmpNewTask.isAllDayEvent){
				 [self.adeList addObject:tmpNewTask];
				 }else if(tmpNewTask.taskRepeatID==0){
				 [self.eventList addObject:tmpNewTask];
				 }else {
				 [self.REList addObject:tmpNewTask];
				 }
				 */				
				/*				
				 //save dummies if new task is an RE 
				 if(tmpNewTask.taskRepeatID>0){
				 for (Task *tmp in tmpREList){
				 if(tmp.primaryKey<=-2){
				 tmp.taskKey=tmp.primaryKey;
				 [tmp prepareDummyIntoDatabase:database];
				 [tmp updateDummy];
				 NSInteger i=tmp.primaryKey;
				 tmp.primaryKey=tmp.taskKey;
				 tmp.taskKey=i;
				 }else {
				 tmp.filledDummiesToDate=[[NSDate date] dateByAddingTimeInterval:THREE_MONTH_INTERVAL];
				 [tmp update];
				 }
				 }
				 
				 [self.dummiesList addObjectsFromArray:tmpREList];
				 }
				 */			}
			
			//[overlapCheck release];
		}
			break;
			
		case 0://new Task
		{
			NSMutableArray *splitedTasksFromDueEnd=[[NSMutableArray alloc] initWithCapacity:2];
			[self splitTasksFromStartTime:newList fromStartTime:[NSDate date] toList:splitedTasksFromDueEnd context:tmpNewTask.taskWhere];
			[splitedTasksFromDueEnd insertObject:tmpNewTask atIndex:0];
			
			[self sortList:splitedTasksFromDueEnd byKey:@"taskDueEndDate"];
			
			NSMutableArray *splitedTasksNoDeaLineFromDueEndList=[[NSMutableArray alloc] initWithCapacity:2];
			[self splitTasksByDeadLineFromTaskList:splitedTasksFromDueEnd fromIndex:0 toList:splitedTasksNoDeaLineFromDueEndList context:tmpNewTask.taskWhere byDeadLine:0];
			
			[self fillRepeatEventInstances:self.REList toList:newList 
								  fromDate:tmpNewTask.taskDueStartDate
					  getInstanceUntilDate:[tmpNewTask.taskDueStartDate dateByAddingTimeInterval:timeInervalForExpandingToFillRE] 
					   isShowPastInstances:NO 
						 isCleanOldDummies:YES 
					  isRememberFilledDate:NO
				  isNeedAtLeastOneInstance:NO];

			[self sortList:newList byKey:@"taskStartTime"];
			
//			if (splitedTasksFromDueEnd.count>0){
//				Task *tmp=[splitedTasksFromDueEnd objectAtIndex:0];
//				searchTimeSlotFromDate=[self smartEndOfLastTaskInList:newList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
//			}
			//try to add first for testing.
			//add task with deadline first
			for (Task *tmp in splitedTasksFromDueEnd){
				
				searchTimeSlotFromDate=[self smartEndOfLastTaskInList:newList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
				//find new time slot for each splitted task
				DateTimeSlot *getTimeSlotResult=nil;
				if(tmp.primaryKey ==-1){//new
					getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:newList startFromDate:tmp.taskDueStartDate toDate:[tmp.taskDueStartDate dateByAddingTimeInterval:THREE_MONTH_INTERVAL]];
				}else if(([searchTimeSlotFromDate compare:tmp.taskStartTime] !=NSOrderedSame) || 
						 [tmp isEqual:[splitedTasksFromDueEnd objectAtIndex:0]] || [searchTimeSlotFromDate compare:tmp.taskNotEalierThan]==NSOrderedAscending){
					getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:newList startFromDate:searchTimeSlotFromDate toDate:[searchTimeSlotFromDate dateByAddingTimeInterval:THREE_MONTH_INTERVAL]];
				}else {
					getTimeSlotResult=[[DateTimeSlot alloc] init];
					getTimeSlotResult.timeSlotDate=tmp.taskStartTime;
					getTimeSlotResult.indexAt=[ivoUtility getTimeSlotIndexForTask:tmp inArray:newList];
					getTimeSlotResult.isOverDue=NO;
					getTimeSlotResult.isPassedDeadLine=NO;
				}
				
				
				if(getTimeSlotResult.isNotFit){
					ret.errorNo=ERR_TASK_NOT_BE_FIT_BY_RE;
					
					//release clalculating lists
					[getTimeSlotResult release];
					[splitedTasksFromDueEnd release];
					[splitedTasksNoDeaLineFromDueEndList release];
					[newList release];
					
					//return ret;
					goto endAdd;
					
				}else if(getTimeSlotResult.indexAt > -1){
					if(getTimeSlotResult.isPassedDeadLine && tmp.taskIsUseDeadLine){
						if(currentSetting.dueWhenMove==0 || isAllowChangeDueWhenAdd){
							//expand deadline to the date when new time slot found
							NSDate *newDeadLine=[ivoUtility createDeadLine:DEADLINE_TODAY fromDate:getTimeSlotResult.timeSlotDate context:tmp.taskWhere];
							tmp.taskDeadLine=newDeadLine;
							
							if(newDeadLine!=nil){
								[newDeadLine release];
								newDeadLine=nil;
							}
						}else {
							if(tmp.primaryKey==-1){
								ret.errorNo=ERR_TASK_ITSELF_PASS_DEADLINE;
							}else {
								ret.errorNo=ERR_TASK_ANOTHER_PASS_DEADLINE;
							}
							
							[getTimeSlotResult release];
							[splitedTasksFromDueEnd release];
							[splitedTasksNoDeaLineFromDueEndList release];
							[newList release];
							//return ret;
							goto endAdd;
						}
					}
					
					if(getTimeSlotResult.isOverDue){
						tmp.taskDueEndDate=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
					}
					
					tmp.taskStartTime=getTimeSlotResult.timeSlotDate;
					tmp.taskEndTime=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
					//							tmp.taskDueEndDate=tmp.taskEndTime;
					[newList insertObject:tmp atIndex:getTimeSlotResult.indexAt];
//					searchTimeSlotFromDate=tmp.taskEndTime;
				}
				
				
				[getTimeSlotResult release];
				
			}
			
//			if (splitedTasksNoDeaLineFromDueEndList.count>0){
//				Task *tmp=[splitedTasksNoDeaLineFromDueEndList objectAtIndex:0];
//				searchTimeSlotFromDate=[self smartEndOfLastTaskInList:newList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
//			}
			
			//add task without deadline last
			for (Task *tmp in splitedTasksNoDeaLineFromDueEndList){
				
				//find new time slot for each splitted task
				searchTimeSlotFromDate=[self smartEndOfLastTaskInList:newList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
				DateTimeSlot *getTimeSlotResult=nil;
				if(tmp.primaryKey ==-1){//new
					getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:newList startFromDate:tmp.taskDueStartDate toDate:[tmp.taskDueStartDate dateByAddingTimeInterval:THREE_MONTH_INTERVAL]];
				}else if(([searchTimeSlotFromDate compare:tmp.taskStartTime] !=NSOrderedSame) || 
						 [tmp isEqual:[splitedTasksNoDeaLineFromDueEndList objectAtIndex:0]] || [searchTimeSlotFromDate compare:tmp.taskNotEalierThan]==NSOrderedAscending){
					getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:newList startFromDate:searchTimeSlotFromDate toDate:[searchTimeSlotFromDate dateByAddingTimeInterval:THREE_MONTH_INTERVAL]];
				}else {
					getTimeSlotResult=[[DateTimeSlot alloc] init];
					getTimeSlotResult.timeSlotDate=tmp.taskStartTime;
					getTimeSlotResult.indexAt=[ivoUtility getTimeSlotIndexForTask:tmp inArray:newList];
					getTimeSlotResult.isOverDue=NO;
					getTimeSlotResult.isPassedDeadLine=NO;
				}
				
				//if([self isNotFitTask:getTimeSlotResult.timeSlotDate lastREInstanceDate:endInstanceDate inList:newList]){	
				if(getTimeSlotResult.isNotFit){
					ret.errorNo=ERR_TASK_NOT_BE_FIT_BY_RE;
					
					//release clalculating lists
					[getTimeSlotResult release];
					[splitedTasksFromDueEnd release];
					[splitedTasksNoDeaLineFromDueEndList release];
					[newList release];
					//return ret;
					goto endAdd;
					
				}else if(getTimeSlotResult.indexAt > -1){
					if(getTimeSlotResult.isOverDue){
						tmp.taskDueEndDate=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
						tmp.taskDeadLine=tmp.taskDueEndDate;
					}
					
					tmp.taskStartTime=getTimeSlotResult.timeSlotDate;
					tmp.taskEndTime=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
					//							tmp.taskDueEndDate=tmp.taskEndTime;
					[newList insertObject:tmp atIndex:getTimeSlotResult.indexAt];
//					searchTimeSlotFromDate=tmp.taskEndTime;
				}
				
				//release clalculating lists
				[getTimeSlotResult release];
			}
			
			//update database
			Task *newTaskTmp;
			for (Task *tmp in newList){
				if(tmp.primaryKey <=-2) continue;
				
				if(tmp.primaryKey==-1){//new task
					NSInteger newPk=[App_Delegate addTask:tmp];
					//Task *newTask=[ivoUtility getTaskByPrimaryKey:-1 inArray:newList];
					//newTask.primaryKey=newPk;
					tmp.primaryKey=newPk;
					ret.taskPrimaryKey=newPk;
					newTaskTmp=tmp;
				}
				
                [tmp update];
				
			}
			
			[splitedTasksFromDueEnd release];
			[splitedTasksNoDeaLineFromDueEndList release];
			
		}	
			break;
	}
	
	//ST 3.6 upload alert to server
	//we need to reset these pair values because it may contains some old values from duplicated
	Task *tsk=[ivoUtility getTaskByPrimaryKey:ret.taskPrimaryKey inArray:newList];
    /*
	if(OSVersion<=3.0){
		if([dev_token length]>0){
			NSString *alertPNSStr=[ivoUtility getAPNSAlertFromTask:tsk];
			
			//un comments (replace) this line to disable Push for Tasks
			//if([tsk.taskAlertValues length]==0 || tsk.taskPinned==0){
			if([tsk.taskAlertValues length]==0){
				tsk.taskAlertValues=@"";
				tsk.PNSKey=@"";
			}else {
				//new alert values has just added
				if([alertPNSStr length]>0) {
					tsk.PNSKey=[[NSDate date] description];
					[ivoUtility uploadAlertsForTasks:tsk isAddNew:YES withPNSAlert:alertPNSStr oldDevToken:dev_token oldTaskPNSID:tsk.PNSKey];
					//if(!ret){
					//	tsk.PNSKey=@"";
					//}
				}
			}
			[tsk update];
		}
	}else {
		if ([tsk.taskAlertValues length]>0) {
			[self updateLocalNotificationForList:newList];
		};
	}
     */
	
exitAdd:	
	//	[App_Delegate getPartTaskList];
	self.taskList=newList;
    [self updateLocalNotificationForList:self.taskList];

	[newList release];
	
	//	//update the order for tasks
	//	NSInteger i=1;
	//	for (Task *task in self.taskList){
	//		if(task.primaryKey>=0){
	//			task.taskOrder=i;
	//			[task update];
	//			i+=1;
	//		}
	//	}	
	if(overlapCheck!=nil){
		[overlapCheck release];
		overlapCheck=nil;
	}
	
	[tmpREList release];
	
endAdd:
	//	[App_Delegate stopAcitivityIndicatorThread];
	//ILOG(@"TaskManager addNewTask]\n");
    
    if (!needStopSync) {
        if (self.currentSetting.autoICalSync) {
            
            if (self.currentSetting.enableSyncICal) {
                [self.ekSync backgroundFullSync];
            }
            
            if (self.currentSetting.enabledReminderSync) {
                [self.reminderSync backgroundFullSync];
            }
        }
    }

	return ret;
}


- (TaskActionResult *)addNewGCalSyncTask:(NSMutableArray *)addList toArray:(NSMutableArray *)list isAllowChangeDueWhenAdd:(BOOL)isAllowChangeDueWhenAdd {
	
	//ILOG(@"[TaskManager addNewTask\n");
	
	//	[App_Delegate showAcitivityIndicatorThread];
//	//printf("\nAdd from ST for syncing--begin");
	TaskActionResult *ret=[[TaskActionResult alloc] init];
	NSMutableArray *sourceList=[NSMutableArray arrayWithArray:list];
    
	DateTimeSlot *getTimeSlotResult=nil;
	
	NSMutableArray *newTaskInAddList=[[NSMutableArray alloc] init];

	//update original Pkey and syncKey for addList
	for(Task *task in addList){
		task.originalPKey=task.primaryKey;
		if(task.taskPinned==1)
		task.primaryKey=-1;
		//task.taskSynKey = [[NSDate date] timeIntervalSince1970];
	}
	
	NSMutableArray *tmpAddList=[[NSMutableArray alloc] initWithArray:addList];
	//split tasks and keep original key for addList
	for (Task *task in tmpAddList){
		if(task.taskPinned==0){
			[newTaskInAddList addObject:task];
			[addList removeObject:task];//remove this object first, will add ti addList again after adding to tasklist.
		}
	}
	
	[tmpAddList release];
	
	NSDate *searchTimeSlotFromDate;
	NSDate *getRepeatInstancesUntil;//=[self lastTaskEndDateInList:list];
	
	//taskCheckResult addRet;
	tmpAddList=[[NSMutableArray alloc] initWithArray:addList];
	for (Task *task in tmpAddList){//add new event first
		if (task.taskSynKey == 0)
		{
			task.taskSynKey = [[NSDate date] timeIntervalSince1970];
		}
		
		ret=[self addNewTask:task toArray:self.taskList isAllowChangeDueWhenAdd:YES];
		
		if(ret.errorNo==-1){
			
			task.primaryKey=ret.taskPrimaryKey;
		}else {
			task.primaryKey=task.originalPKey;
		}
	}
	[tmpAddList release];
	
	NSMutableArray *newList=[[NSMutableArray alloc] initWithArray:self.taskList];//get existing list
	
	//add new tasks later
	
	NSMutableArray *splitedTasksFromDueEnd=[[NSMutableArray alloc] initWithCapacity:2];
	[self splitTasksFromStartTime:newList fromStartTime:[NSDate date] toList:splitedTasksFromDueEnd context:-1];
	[splitedTasksFromDueEnd addObjectsFromArray:newTaskInAddList];
	
	//[splitedTasksFromDueEnd insertObject:tmpNewTask atIndex:0];
	
	[self sortList:splitedTasksFromDueEnd byKey:@"taskDueEndDate"];
	getRepeatInstancesUntil=[[self lastTaskEndDateInList:splitedTasksFromDueEnd] dateByAddingTimeInterval:5184000];//add 2 months
	//getRepeatInstancesUntil=[self lastTaskEndDateInList:splitedTasksFromDueEnd];//add 2 months
	
	NSMutableArray *splitedTasksNoDeaLineFromDueEndList=[[NSMutableArray alloc] initWithCapacity:2];
	[self splitTasksByDeadLineFromTaskList:splitedTasksFromDueEnd fromIndex:0 toList:splitedTasksNoDeaLineFromDueEndList context:-1 byDeadLine:0];
	
	self.REList=[self getREListFromTaskList:newList];
	[self fillRepeatEventInstances:self.REList 
							toList:newList 
						  fromDate:[NSDate date]
			  getInstanceUntilDate:[getRepeatInstancesUntil dateByAddingTimeInterval:timeInervalForExpandingToFillRE] 
			   isShowPastInstances:NO 
				 isCleanOldDummies:YES 
			  isRememberFilledDate:NO
		  isNeedAtLeastOneInstance:NO];
	
	[self sortList:newList byKey:@"taskStartTime"];	
	
//	if (splitedTasksFromDueEnd.count>0){
//		Task *tmp=[splitedTasksFromDueEnd objectAtIndex:0];
//		searchTimeSlotFromDate=[self smartEndOfLastTaskInList:newList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
//	}
	
	//try to add first for testing.
	//add task with deadline first
	for (Task *tmp in splitedTasksFromDueEnd){
		searchTimeSlotFromDate=[self smartEndOfLastTaskInList:newList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
		//find new time slot for each splitted task
		getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:newList startFromDate:searchTimeSlotFromDate toDate:[searchTimeSlotFromDate dateByAddingTimeInterval:THREE_MONTH_INTERVAL]];
		
		//if([self isNotFitTask:getTimeSlotResult.timeSlotDate lastREInstanceDate:endInstanceDate inList:newList]){	
		if(getTimeSlotResult.isNotFit){
			ret.errorNo=ERR_TASK_NOT_BE_FIT_BY_RE;
			
			//re-add the task to the addList;
			tmp.primaryKey=tmp.originalPKey;
			
			if (tmp.taskSynKey == 0)
			{
				tmp.taskSynKey = [[NSDate date] timeIntervalSince1970];
			}
			
			[addList addObject:tmp];
			[newList removeObject:tmp];
			
			if(getTimeSlotResult!=nil){
				[getTimeSlotResult release];
				getTimeSlotResult=nil;
			}
			if(splitedTasksFromDueEnd !=nil){
				[splitedTasksFromDueEnd release];
				splitedTasksFromDueEnd=nil;
			}
			
			if (splitedTasksNoDeaLineFromDueEndList !=nil){
				[splitedTasksNoDeaLineFromDueEndList release];
				splitedTasksNoDeaLineFromDueEndList=nil;
			}
			
			
			if(newList !=nil){
				[newList release];
				newList=nil;
			}
			
			//return ret;
			goto endAdd;
			
		}else if(getTimeSlotResult.indexAt > -1){
			if(getTimeSlotResult.isPassedDeadLine && tmp.taskIsUseDeadLine){
				if(currentSetting.dueWhenMove==0 || isAllowChangeDueWhenAdd){
					//expand deadline to the date when new time slot found
					NSDate *newDeadLine=[ivoUtility createDeadLine:DEADLINE_TODAY fromDate:getTimeSlotResult.timeSlotDate context:tmp.taskWhere];
					tmp.taskDeadLine=newDeadLine;
					if(newDeadLine!=nil){
						[newDeadLine release];
						newDeadLine=nil;
					}
					
				}else {
					
					if(tmp.primaryKey==-1){
						ret.errorNo=ERR_TASK_ITSELF_PASS_DEADLINE;
					}else {
						ret.errorNo=ERR_TASK_ANOTHER_PASS_DEADLINE;
					}
					
					if(getTimeSlotResult!=nil){
						[getTimeSlotResult release];
						getTimeSlotResult=nil;
					}
					if(splitedTasksFromDueEnd !=nil){
						[splitedTasksFromDueEnd release];
						splitedTasksFromDueEnd=nil;
					}
					
					if (splitedTasksNoDeaLineFromDueEndList !=nil){
						[splitedTasksNoDeaLineFromDueEndList release];
						splitedTasksNoDeaLineFromDueEndList=nil;
					}
					
					
					if(newList !=nil){
						[newList release];
						newList=nil;
					}
					
					//return ret;
					goto endAdd;
				}
			}
			
			if(getTimeSlotResult.isOverDue){
				tmp.taskDueEndDate=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
			}
			
			tmp.taskStartTime=getTimeSlotResult.timeSlotDate;
			tmp.taskEndTime=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
			//							tmp.taskDueEndDate=tmp.taskEndTime;
			[newList insertObject:tmp atIndex:getTimeSlotResult.indexAt];
//			searchTimeSlotFromDate=tmp.taskEndTime;
		}
		if(getTimeSlotResult!=nil){
			[getTimeSlotResult release];
			getTimeSlotResult=nil;
		}
		
	}
	
//	if (splitedTasksNoDeaLineFromDueEndList.count>0){
//		Task *tmp=[splitedTasksNoDeaLineFromDueEndList objectAtIndex:0];
//		searchTimeSlotFromDate=[self smartEndOfLastTaskInList:newList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
//	}
	
	//add task without deadline last
	for (Task *tmp in splitedTasksNoDeaLineFromDueEndList){
		
		//find new time slot for each splitted task
		searchTimeSlotFromDate=[self smartEndOfLastTaskInList:newList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
		getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:newList startFromDate:searchTimeSlotFromDate toDate:[searchTimeSlotFromDate dateByAddingTimeInterval:THREE_MONTH_INTERVAL]];
		
		//if([self isNotFitTask:getTimeSlotResult.timeSlotDate lastREInstanceDate:endInstanceDate inList:newList]){	
		if(getTimeSlotResult.isNotFit){
			ret.errorNo=ERR_TASK_NOT_BE_FIT_BY_RE;
			
			//re-add the task to the addList;
			tmp.primaryKey=tmp.originalPKey;
			if (tmp.taskSynKey == 0)
			{
				tmp.taskSynKey = [[NSDate date] timeIntervalSince1970];
			}
			
			[addList addObject:tmp];
			[newList removeObject:tmp];
			
			if(getTimeSlotResult!=nil){
				[getTimeSlotResult release];
				getTimeSlotResult=nil;
			}
			if(splitedTasksFromDueEnd !=nil){
				[splitedTasksFromDueEnd release];
				splitedTasksFromDueEnd=nil;
			}
			
			if (splitedTasksNoDeaLineFromDueEndList !=nil){
				[splitedTasksNoDeaLineFromDueEndList release];
				splitedTasksNoDeaLineFromDueEndList=nil;
			}
			
			
			if(newList !=nil){
				[newList release];
				newList=nil;
			}
			
			//return ret;
			goto endAdd;
			
		}else if(getTimeSlotResult.indexAt > -1){
			if(getTimeSlotResult.isOverDue){
				tmp.taskDueEndDate=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
				tmp.taskDeadLine=tmp.taskDueEndDate;
			}
			
			tmp.taskStartTime=getTimeSlotResult.timeSlotDate;
			tmp.taskEndTime=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
			//							tmp.taskDueEndDate=tmp.taskEndTime;
			[newList insertObject:tmp atIndex:getTimeSlotResult.indexAt];
//			searchTimeSlotFromDate=tmp.taskEndTime;
		}
		if(getTimeSlotResult!=nil){
			[getTimeSlotResult release];
			getTimeSlotResult=nil;
		}
	}
	
	//update database
	for (Task *tmp in splitedTasksFromDueEnd){

		if(tmp.primaryKey<=-1){//new task
			NSInteger newPk=[App_Delegate addTask:tmp];
			
			for(Task *task in newList){
				if(task.originalPKey==tmp.originalPKey){
					task.primaryKey=newPk;
					if (task.taskSynKey == 0)
					{
						task.taskSynKey = [[NSDate date] timeIntervalSince1970];
					}
					ret.taskPrimaryKey=newPk;
					break;
				}
			}
			
			//re-add the task to the addList;
			Task *newTask=[[Task alloc] init];
			Task *tmp1=[ivoUtility getTaskByPrimaryKey:newPk inArray:newList];
			[ivoUtility copyTask:tmp1 toTask:newTask isIncludedPrimaryKey:YES];
			[addList addObject:newTask];
			[newTask release];
		}else {
			[tmp update];
		}
		
	}
	
	for (Task *tmp in splitedTasksNoDeaLineFromDueEndList){
		
		if(tmp.primaryKey<=-1){//new task
			NSInteger newPk=[App_Delegate addTask:tmp];
			for(Task *task in newList){
				if(task.originalPKey==tmp.originalPKey){
					task.primaryKey=newPk;
					if (task.taskSynKey == 0)
					{
						task.taskSynKey = [[NSDate date] timeIntervalSince1970];
					}
					ret.taskPrimaryKey=newPk;
					break;
				}
			}
			
			
			Task *newTask=[[Task alloc] init];
			Task *tmp1=[ivoUtility getTaskByPrimaryKey:newPk inArray:newList];
			[ivoUtility copyTask:tmp1 toTask:newTask isIncludedPrimaryKey:YES];
			[addList addObject:newTask];
			[newTask release];

		}else {
			[tmp update];
		}
	}
	
	//clean original PKey
	for(Task *task in newList){
		task.originalPKey=-1;
	}
	
	
	if(splitedTasksFromDueEnd !=nil){
		[splitedTasksFromDueEnd release];
		splitedTasksFromDueEnd=nil;
	}
	
	if (splitedTasksNoDeaLineFromDueEndList !=nil){
		[splitedTasksNoDeaLineFromDueEndList release];
		splitedTasksNoDeaLineFromDueEndList=nil;
	}
	
	
	if(getTimeSlotResult!=nil){
		[getTimeSlotResult release];
		getTimeSlotResult=nil;
	}	

exitAdd:	
	self.taskList=newList;
	
//	//update the order for tasks
//	NSInteger i=1;
//	for (Task *task in self.taskList){
//		if(task.primaryKey>=0){
//			task.taskOrder=i;
//			[task update];
//			i+=1;
//		}
//	}	
	
	if(getTimeSlotResult!=nil){
		[getTimeSlotResult release];
		getTimeSlotResult=nil;
	}
	
	if(newList !=nil){
		[newList release];
		newList=nil;
	}
	
	[newTaskInAddList release];
	
endAdd:
//	[App_Delegate getPartTaskList];
//	[self refreshTaskListFromPartList];
	
	//	[App_Delegate stopAcitivityIndicatorThread];
	//ILOG(@"TaskManager addNewTask]\n");
	//printf("\nAdd from ST for syncing--end");
	return ret;
}

/*
- (void)dealloc{
	[tmpNewTask release];
	[tmpUpdateTask release];
	[alertView release];
	[taskList release];
	taskList=nil;
	[quickTaskList release];
	quickTaskList=nil;
	[completedTaskList release];
	completedTaskList=nil;
	[super dealloc];
}
*/
-(void)callAlert:(NSString *)message{
	UIAlertView *alrtView = [[UIAlertView alloc] initWithTitle:message message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"") otherButtonTitles:nil];
	[alrtView show];
	[alrtView release];
}

-(void)sortList:(NSMutableArray *)list byKey:(NSString *)byKey{

	/*
	//sort the list before assigning it
	NSMutableArray *originalQTasks=[[NSMutableArray alloc] initWithArray:list]; 
	
	NSSortDescriptor *date_descriptorQ = [[NSSortDescriptor alloc] initWithKey:byKey ascending: YES];
	
	NSArray *sortDescriptors = [NSArray arrayWithObject:date_descriptorQ];
	
	//get the sorted task list based on the original task list
 	[list removeAllObjects];
	[list addObjectsFromArray:[originalQTasks sortedArrayUsingDescriptors:sortDescriptors]];
	[date_descriptorQ release];
	[originalQTasks release];
	*/
    
    NSMutableArray* originalQTasks=[NSMutableArray arrayWithArray:list];	
	NSSortDescriptor *date_descriptorQ = [[NSSortDescriptor alloc] initWithKey:byKey ascending: YES];
	
	NSArray *sortDescriptors = [NSArray arrayWithObject:date_descriptorQ];
	
	//get the sorted task list based on the original task list 	
    [list setArray:[originalQTasks sortedArrayUsingDescriptors:sortDescriptors]];
	[date_descriptorQ release];
}

-(void)sortListWithAD:(NSMutableArray *)list byKey:(NSString *)byKey isAscending:(BOOL)isAscending{

	/*
	//sort the list before assigning it
	NSMutableArray *originalQTasks=[[NSMutableArray alloc] initWithArray:list]; 
	
	NSSortDescriptor *date_descriptorQ = [[NSSortDescriptor alloc] initWithKey:byKey ascending: isAscending];
	
	NSArray *sortDescriptors = [NSArray arrayWithObject:date_descriptorQ];
	
	//get the sorted task list based on the original task list
 	[list removeAllObjects];
	[list addObjectsFromArray:[originalQTasks sortedArrayUsingDescriptors:sortDescriptors]];
	[date_descriptorQ release];
	[originalQTasks release];
	*/
    
    NSMutableArray* originalQTasks=[NSMutableArray arrayWithArray:list];
	
	NSSortDescriptor *date_descriptorQ = [[NSSortDescriptor alloc] initWithKey:byKey ascending: isAscending];
	
	NSArray *sortDescriptors = [NSArray arrayWithObject:date_descriptorQ];
	
	//get the sorted task list based on the original task list 	
    [list setArray:[originalQTasks sortedArrayUsingDescriptors:sortDescriptors]];
	[date_descriptorQ release];
}

-(BOOL)refreshTaskList{
    //while (totalSync>0) {
    //    [NSThread sleepForTimeInterval:0.01];
    //}
    
    //printf("\n start refresh");
	////printf("\nstart refresh task list: %s",[[[NSDate date] description] UTF8String]);
	NSMutableArray *nTasks=[NSMutableArray array];
	NSMutableArray *dTasks=[NSMutableArray array];
	NSMutableArray *events=[NSMutableArray array];
    
    NSMutableArray *sourceList=[NSMutableArray arrayWithArray:self.taskList];

	for(Task *task in sourceList){
		if(task.taskPinned==0){
			if(task.taskIsUseDeadLine==0){
				[nTasks addObject:task];
			}else {
				[dTasks addObject:task];
			}
		}else {
			[events addObject:task];
		}
	}
	
	self.normalTaskList=nTasks;
	self.dTaskList=dTasks;
	self.REList=[self getREListFromTaskList:events];
	
	if(self.normalTaskList.count==0 && self.dTaskList.count==0){
		////printf("\nend refresh task list: %s",[[[NSDate date] description] UTF8String]);
        
        //printf("\n end refresh");
		return YES;
	}
	
	NSDate *searchTimeSlotFromDate;
	
	self.isSomeDtasksCouldNotBeRefreshed=NO;
	
//	DateTimeSlot *getTimeSlotResult=nil;
	
	NSMutableArray *splitedTasksNoDeaLineFromDueEndListOrginal=[[NSMutableArray alloc] initWithArray:self.normalTaskList];
	NSMutableArray *splitedTasksNoDeaLineFromDueEndList=[[NSMutableArray alloc] initWithCapacity:2];
	[self splitTasksByDeadLineFromTaskList:splitedTasksNoDeaLineFromDueEndListOrginal fromIndex:0 toList:splitedTasksNoDeaLineFromDueEndList context:-1 byDeadLine:0];
	[self sortList:splitedTasksNoDeaLineFromDueEndList byKey:@"taskDueEndDate"];
	[splitedTasksNoDeaLineFromDueEndListOrginal release];
	
	NSMutableArray *splitedTasksFromDueEndOriginal=[[NSMutableArray alloc] initWithArray:self.dTaskList];
	NSMutableArray *splitedTasksFromDueEnd=[[NSMutableArray alloc] initWithCapacity:2];
	[self splitUnPinchedTasksNoPassedDeadlineFromTaskList:splitedTasksFromDueEndOriginal fromIndex:0 toList:splitedTasksFromDueEnd context:-1];
	[self sortList:splitedTasksFromDueEnd byKey:@"taskDueEndDate"];

	//Sub backup for task list incase it has any passed deadline task
	NSMutableArray *listWithDeadlineTasks=[[NSMutableArray alloc] initWithArray:events];
	NSDate *lastTaskEndDateInDtaskList=[self lastTaskEndDateInList:self.dTaskList];
	NSDate *lastTaskEndDateInTaskList=[self lastTaskEndDateInList:self.normalTaskList];
	
	[self fillRepeatEventInstances:self.REList 
							toList:listWithDeadlineTasks
						  fromDate:[NSDate date]
			  getInstanceUntilDate:[lastTaskEndDateInDtaskList compare:lastTaskEndDateInTaskList]==NSOrderedAscending?[lastTaskEndDateInTaskList dateByAddingTimeInterval:timeInervalForExpandingToFillRE]:[lastTaskEndDateInDtaskList dateByAddingTimeInterval:timeInervalForExpandingToFillRE]
			   isShowPastInstances:NO 
				 isCleanOldDummies:YES
			  isRememberFilledDate:NO
		  isNeedAtLeastOneInstance:NO];
	
	self.taskList=listWithDeadlineTasks;
	
	[listWithDeadlineTasks addObjectsFromArray:self.dTaskList];
	[self sortList:listWithDeadlineTasks byKey:@"taskStartTime"];
	
//	NSMutableArray *listBackup=[[NSMutableArray alloc] initWithArray: self.taskList];

	[self.taskList addObjectsFromArray:splitedTasksFromDueEndOriginal];
	[self sortList:self.taskList byKey:@"taskStartTime"];
	[splitedTasksFromDueEndOriginal release];
	
//	if(splitedTasksFromDueEnd.count>0){
//		Task *tmp=[splitedTasksFromDueEnd objectAtIndex:0];
//		searchTimeSlotFromDate=[self smartEndOfLastTaskInList:self.taskList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
//	}
	//try to add first for testing.
	//add task with deadline first
	for (Task *tmp in splitedTasksFromDueEnd){
		
		searchTimeSlotFromDate=[self smartEndOfLastTaskInList:self.taskList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
		////printf("\n%s", [[ivoUtility createStringFromDate:searchTimeSlotFromDate  isIncludedTime:YES] UTF8String]);
		//find new time slot for each splitted task
		DateTimeSlot *getTimeSlotResult=nil;
//		if([searchTimeSlotFromDate compare:tmp.taskStartTime] !=NSOrderedSame || [searchTimeSlotFromDate compare:tmp.taskNotEalierThan]==NSOrderedAscending){
			getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:self.taskList startFromDate:searchTimeSlotFromDate toDate:[searchTimeSlotFromDate dateByAddingTimeInterval:THREE_MONTH_INTERVAL]];
/*		}else {
			getTimeSlotResult=[[DateTimeSlot alloc] init];
			getTimeSlotResult.timeSlotDate=tmp.taskStartTime;
			getTimeSlotResult.indexAt=[ivoUtility getTimeSlotIndexForTask:tmp inArray:self.taskList];
			getTimeSlotResult.isOverDue=NO;
			getTimeSlotResult.isPassedDeadLine=NO;
		}
*/		
		//if([self isNotFitTask:getTimeSlotResult.timeSlotDate lastREInstanceDate:endInstanceDate inList:self.taskList]){	
		if(getTimeSlotResult.isNotFit){
			//roll back change
			//self.taskList=listBackup;
			
			[getTimeSlotResult release];
			[splitedTasksFromDueEnd release];
			[splitedTasksNoDeaLineFromDueEndList release];
			[listWithDeadlineTasks release];
			
			////printf("\nend refresh task list: %s",[[[NSDate date] description] UTF8String]);
			//[App_Delegate getPartTaskList];
            
            //printf("\n end refresh");
			return NO;
		}else if(getTimeSlotResult.indexAt > -1){
			if(getTimeSlotResult.isPassedDeadLine && tmp.taskIsUseDeadLine){// && currentSetting.dueWhenMove==0){
				
			refreshForTasksOnly:				
				//roll back change
				self.taskList=listWithDeadlineTasks;
				
				//[getTimeSlotResult release];
				[splitedTasksFromDueEnd release];
				
				self.isSomeDtasksCouldNotBeRefreshed=YES;
				
				//refresh tasks only--------------------------------------------------

				NSDate *searchTSFromDate;
				
//				if(splitedTasksNoDeaLineFromDueEndList.count>0){
//					Task *tmp=[splitedTasksNoDeaLineFromDueEndList objectAtIndex:0];
//					searchTSFromDate=[self smartEndOfLastTaskInList:self.taskList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
//				}
				
				for (Task *tmp in splitedTasksNoDeaLineFromDueEndList){
					//find new time slot for each splitted task
					//find new time slot for each splitted task
					DateTimeSlot *getTimeSlotResult1=nil;
					searchTSFromDate=[self smartEndOfLastTaskInList:self.taskList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
					if([searchTimeSlotFromDate compare:tmp.taskStartTime] !=NSOrderedSame || [searchTimeSlotFromDate compare:tmp.taskNotEalierThan]==NSOrderedAscending){
						getTimeSlotResult1=[self createTimeSlotForDTask:tmp inArray:self.taskList startFromDate:searchTSFromDate toDate:[searchTSFromDate dateByAddingTimeInterval:THREE_MONTH_INTERVAL]];
					}else {
						getTimeSlotResult1=[[DateTimeSlot alloc] init];
						getTimeSlotResult1.timeSlotDate=tmp.taskStartTime;
						getTimeSlotResult1.indexAt=[ivoUtility getTimeSlotIndexForTask:tmp inArray:self.taskList];
						getTimeSlotResult1.isOverDue=NO;
						getTimeSlotResult1.isPassedDeadLine=NO;
					}
					
					if(getTimeSlotResult1.indexAt > -1){
						if(getTimeSlotResult1.isOverDue){
							tmp.taskDueEndDate=[getTimeSlotResult1.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
							tmp.taskDeadLine=tmp.taskDueEndDate;
						}
						
						tmp.taskStartTime=getTimeSlotResult1.timeSlotDate;
						tmp.taskEndTime=[getTimeSlotResult1.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
//						tmp.taskDueEndDate=tmp.taskEndTime;
                        if (self.taskList.count>getTimeSlotResult1.indexAt) {
                            [self.taskList insertObject:tmp atIndex:getTimeSlotResult1.indexAt];
                        }else{
                            [self.taskList addObject:tmp];
                        }
//						searchTSFromDate=tmp.taskEndTime;
					}
					
					[getTimeSlotResult1 release];
				}

				for (Task *tmp in splitedTasksNoDeaLineFromDueEndList){
					[tmp update];
				}
				
				[splitedTasksNoDeaLineFromDueEndList release];
				[getTimeSlotResult release];
				[listWithDeadlineTasks release];
				
				//update the order for tasks
//				NSInteger i=1;
//				for (Task *task in self.taskList){
//					if(task.primaryKey>=0){
//						task.taskOrder=i;
//						[task update];
//						i+=1;
//					}
//				}
				
                //printf("\n end refresh");
				//[App_Delegate getPartTaskList];
				return YES;
			}
			
			if(getTimeSlotResult.isOverDue){
				tmp.taskDueEndDate=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
			}
			
			tmp.taskStartTime=getTimeSlotResult.timeSlotDate;
			tmp.taskEndTime=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
//			tmp.taskDueEndDate=tmp.taskEndTime;
			//[self.taskList insertObject:tmp atIndex:getTimeSlotResult.indexAt];
			
            if (self.taskList.count>getTimeSlotResult.indexAt) {
                [self.taskList insertObject:tmp atIndex:getTimeSlotResult.indexAt];
            }else{
                [self.taskList addObject:tmp];
            }

			//nang 3.6
//			searchTimeSlotFromDate=tmp.taskEndTime;
		}
	
		[getTimeSlotResult release];
	}
	
//	if(splitedTasksNoDeaLineFromDueEndList.count>0){
//		Task *tmp=[splitedTasksNoDeaLineFromDueEndList objectAtIndex:0];
//		searchTimeSlotFromDate=[self smartEndOfLastTaskInList:self.taskList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
//	}
	
	//add task without deadline last
	for (Task *tmp in splitedTasksNoDeaLineFromDueEndList){
		searchTimeSlotFromDate=[self smartEndOfLastTaskInList:self.taskList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
		//find new time slot for each splitted task
		DateTimeSlot *getTimeSlotResult=nil;
		//v5 if([searchTimeSlotFromDate compare:tmp.taskStartTime] !=NSOrderedSame || [searchTimeSlotFromDate compare:tmp.taskNotEalierThan]==NSOrderedAscending){
			getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:self.taskList startFromDate:searchTimeSlotFromDate toDate:[searchTimeSlotFromDate dateByAddingTimeInterval:THREE_MONTH_INTERVAL]];
		//v5}else {
		//	getTimeSlotResult=[[DateTimeSlot alloc] init];
		//	getTimeSlotResult.timeSlotDate=tmp.taskStartTime;
		//	getTimeSlotResult.indexAt=[ivoUtility getTimeSlotIndexForTask:tmp inArray:self.taskList];
		//	getTimeSlotResult.isOverDue=NO;
		//	getTimeSlotResult.isPassedDeadLine=NO;
		//}		
		
		if(getTimeSlotResult.indexAt > -1){
			if(getTimeSlotResult.isOverDue){
				tmp.taskDueEndDate=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
				tmp.taskDeadLine=tmp.taskDueEndDate;
			}
			
			tmp.taskStartTime=getTimeSlotResult.timeSlotDate;
			tmp.taskEndTime=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
//			tmp.taskDueEndDate=tmp.taskEndTime;
			//[self.taskList insertObject:tmp atIndex:getTimeSlotResult.indexAt];
            
            if (self.taskList.count>getTimeSlotResult.indexAt) {
                [self.taskList insertObject:tmp atIndex:getTimeSlotResult.indexAt];
            }else{
                [self.taskList addObject:tmp];
            }

		}
		
//		searchTimeSlotFromDate=tmp.taskEndTime;
		[getTimeSlotResult release];
	}
	
	//update database
	for (Task *tmp in splitedTasksFromDueEnd){
			[tmp update];
	}
	
	for (Task *tmp in splitedTasksNoDeaLineFromDueEndList){
		[tmp update];
	}
	
//	//update the order for tasks
//	NSInteger i=1;
//	for (Task *task in self.taskList){
//		if(task.primaryKey>=0){
//			task.taskOrder=i;
//			[task update];
//			i+=1;
//		}
//	}	
	[splitedTasksFromDueEnd release];
	[splitedTasksNoDeaLineFromDueEndList release];
	[listWithDeadlineTasks release];
	
    //[self checkForFullSync];
    
	//[App_Delegate getPartTaskList];
	//printf("\n end refresh");
    
	////printf("\nend refresh task list: %s",[[[NSDate date] description] UTF8String]);
	return YES;
}


-(TaskActionResult *)applyNewSetting4TaskList:(Setting *)currentSettingModify{
	
//	[App_Delegate showAcitivityIndicatorThread];
	
	NSDate *searchTimeSlotFromDate;
	
	TaskActionResult *ret=[[TaskActionResult alloc] init];
	DateTimeSlot *getTimeSlotResult=nil;
	
	NSMutableArray *listBackup;
	listBackup=[[NSMutableArray alloc] initWithArray:self.taskList];//backup task list
	
	NSMutableArray *splitedTasksFromDueEnd=[[NSMutableArray alloc] initWithCapacity:2];
	//[self splitTasksFromStartTime:newList fromStartTime:[NSDate date] toList:splitedTasksFromDueEnd context:tmpNewTask.taskWhere];
	[self splitUnPinchedTasksNoPassedDeadlineFromTaskList:self.taskList fromIndex:0 toList:splitedTasksFromDueEnd context:-1];
	
	[self sortList:splitedTasksFromDueEnd byKey:@"taskDueEndDate"];
	
	NSMutableArray *splitedTasksNoDeaLineFromDueEndList=[[NSMutableArray alloc] initWithCapacity:2];
	[self splitTasksByDeadLineFromTaskList:splitedTasksFromDueEnd fromIndex:0 toList:splitedTasksNoDeaLineFromDueEndList context:-1 byDeadLine:0];
	
	NSDate *getRepeatInstancesUntil=[self lastTaskEndDateInList:self.taskList];
	
	[self fillRepeatEventInstances:[self getREListFromTaskList:self.taskList]
							toList:self.taskList 
						  fromDate:[NSDate date] 
			  getInstanceUntilDate:[getRepeatInstancesUntil dateByAddingTimeInterval: timeInervalForExpandingToFillRE] 
			   isShowPastInstances:NO 
				 isCleanOldDummies:YES 
			  isRememberFilledDate:NO
		  isNeedAtLeastOneInstance:NO];

	//try to add first for testing.
	//add task with deadline first
	for (Task *tmp in splitedTasksFromDueEnd){
		
		searchTimeSlotFromDate=[self smartEndOfLastTaskInList:self.taskList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];
		////printf("\n%s", [[ivoUtility createStringFromDate:searchTimeSlotFromDate  isIncludedTime:YES] UTF8String]);
		//find new time slot for each splitted task
		
		getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:self.taskList startFromDate:searchTimeSlotFromDate toDate:[searchTimeSlotFromDate dateByAddingTimeInterval:THREE_MONTH_INTERVAL]];
		
		//if([self isNotFitTask:getTimeSlotResult.timeSlotDate lastREInstanceDate:endInstanceDate inList:self.taskList]){	
		if(getTimeSlotResult.isNotFit){
			//roll back change
			self.taskList=listBackup;
			
			if(getTimeSlotResult!=nil){
				[getTimeSlotResult release];
				getTimeSlotResult=nil;
			}
			
			if(splitedTasksFromDueEnd !=nil){
				[splitedTasksFromDueEnd release];
				splitedTasksFromDueEnd=nil;
			}
			
			if (splitedTasksNoDeaLineFromDueEndList !=nil){
				[splitedTasksNoDeaLineFromDueEndList release];
				splitedTasksNoDeaLineFromDueEndList=nil;
			}
			
			
			//return ret;
			goto exitRefresh;
		}else if(getTimeSlotResult.indexAt > -1){
			if(getTimeSlotResult.isPassedDeadLine && tmp.taskIsUseDeadLine){
				
				if(currentSettingModify.dueWhenMove==0){
					//expand deadline to the date when new time slot found
					NSDate *newDeadLine=[ivoUtility createDeadLine:DEADLINE_TODAY fromDate:getTimeSlotResult.timeSlotDate context:tmp.taskWhere];
					tmp.taskDeadLine=newDeadLine;
					if(newDeadLine!=nil){
						[newDeadLine release];
						newDeadLine=nil;
					}
					
				}else {
					ret.errorNo=ERR_TASK_ANOTHER_PASS_DEADLINE;
					//roll back change
					self.taskList=listBackup;
				
					if(getTimeSlotResult!=nil){
						[getTimeSlotResult release];
						getTimeSlotResult=nil;
					}
					
					if(splitedTasksFromDueEnd !=nil){
						[splitedTasksFromDueEnd release];
						splitedTasksFromDueEnd=nil;
					}
					
					if (splitedTasksNoDeaLineFromDueEndList !=nil){
						[splitedTasksNoDeaLineFromDueEndList release];
						splitedTasksNoDeaLineFromDueEndList=nil;
					}
					
				
					//return ret;
					goto exitRefresh;
				}
			}
			
			if(getTimeSlotResult.isOverDue){
				tmp.taskDueEndDate=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
			}
			
			tmp.taskStartTime=getTimeSlotResult.timeSlotDate;
			tmp.taskEndTime=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
//			tmp.taskDueEndDate=tmp.taskEndTime;
			[self.taskList insertObject:tmp atIndex:getTimeSlotResult.indexAt];
		}
		if(getTimeSlotResult!=nil){
			[getTimeSlotResult release];
			getTimeSlotResult=nil;
		}
		
	}
	
	//add task without deadline last
	for (Task *tmp in splitedTasksNoDeaLineFromDueEndList){
		searchTimeSlotFromDate=[self smartEndOfLastTaskInList:self.taskList forTask:tmp context:tmp.taskWhere isUsedDeadLine:tmp.taskIsUseDeadLine];

		//find new time slot for each splitted task
		getTimeSlotResult=[self createTimeSlotForDTask:tmp inArray:self.taskList startFromDate:searchTimeSlotFromDate toDate:[tmp.taskDueStartDate dateByAddingTimeInterval:THREE_MONTH_INTERVAL]];
		
		//if([self isNotFitTask:getTimeSlotResult.timeSlotDate lastREInstanceDate:endInstanceDate inList:self.taskList]){	
		if(getTimeSlotResult.isNotFit){
			//roll back change
			self.taskList=listBackup;
			
			if(getTimeSlotResult!=nil){
				[getTimeSlotResult release];
				getTimeSlotResult=nil;
			}
			
			if(splitedTasksFromDueEnd !=nil){
				[splitedTasksFromDueEnd release];
				splitedTasksFromDueEnd=nil;
			}
			
			if (splitedTasksNoDeaLineFromDueEndList !=nil){
				[splitedTasksNoDeaLineFromDueEndList release];
				splitedTasksNoDeaLineFromDueEndList=nil;
			}
			
			
			//return ret;
			goto exitRefresh;
		}else if(getTimeSlotResult.indexAt > -1){
			if(getTimeSlotResult.isOverDue){
				tmp.taskDueEndDate=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
				tmp.taskDeadLine=tmp.taskDueEndDate;
			}
			
			tmp.taskStartTime=getTimeSlotResult.timeSlotDate;
			tmp.taskEndTime=[getTimeSlotResult.timeSlotDate dateByAddingTimeInterval:tmp.taskHowLong];
//			tmp.taskDueEndDate=tmp.taskEndTime;
			[self.taskList insertObject:tmp atIndex:getTimeSlotResult.indexAt];
		}
		if(getTimeSlotResult!=nil){
			[getTimeSlotResult release];
			getTimeSlotResult=nil;
		}
	}
	
	//update database
	for (Task *tmp in splitedTasksFromDueEnd){
		[tmp update];
	}
	
	for (Task *tmp in splitedTasksNoDeaLineFromDueEndList){
		[tmp update];
	}
	
	if(splitedTasksFromDueEnd !=nil){
		[splitedTasksFromDueEnd release];
		splitedTasksFromDueEnd=nil;
	}
	
	if (splitedTasksNoDeaLineFromDueEndList !=nil){
		[splitedTasksNoDeaLineFromDueEndList release];
		splitedTasksNoDeaLineFromDueEndList=nil;
	}
	
	if(getTimeSlotResult!=nil){
		[getTimeSlotResult release];
		getTimeSlotResult=nil;
	}	

exitRefresh:
	[listBackup release];
//	[App_Delegate stopAcitivityIndicatorThread];
	return ret;
}

-(NSInteger)getRepeatEveryForRE:(Task *)task{
	NSInteger repeatEvery;
	if(task.taskRepeatOptions !=nil && ![task.taskRepeatOptions isEqualToString:@""]){
		NSArray *options=[task.taskRepeatOptions componentsSeparatedByString:@"/"];
		repeatEvery=[(NSString*)[options objectAtIndex:0] intValue];
	}else {
		repeatEvery=1;
	}
	
	if(repeatEvery<1){
		repeatEvery=1;
	}
	
	return repeatEvery;
}

-(NSMutableArray *)createRepeatEventInstanceList:(Task *)task getInstanceUntilDate:(NSDate *)getInstanceUntilDate{
	NSMutableArray *list=[[NSMutableArray alloc] init];
	NSDate *untilDate;
	NSDate *tmp;
	NSDate *tmpEndate;
	//NSInteger instanceKey=-2;
	
	if((task.taskPinned==1) && (task.taskRepeatID > 0)){
		
		//get temporary end repeat date when RE will be displayed until.
		untilDate=getInstanceUntilDate;
		
		//start display from the first instance
		tmp=task.taskStartTime;
		tmpEndate=[tmp dateByAddingTimeInterval:task.taskHowLong];
	
		//get repeat options:
		NSInteger repeatEvery;
		NSInteger repeatBy;
		NSString *repeatOn;
		
		if(task.taskRepeatOptions !=nil && ![task.taskRepeatOptions isEqualToString:@""]){
			NSArray *options=[task.taskRepeatOptions componentsSeparatedByString:@"/"];
			repeatEvery=[(NSString*)[options objectAtIndex:0] intValue];
			repeatOn=[(NSString*)[options objectAtIndex:1] copy];
			repeatBy=[(NSString*)[options objectAtIndex:2] intValue];
		}else {
			repeatEvery=1;
			repeatOn=@"";
			repeatBy=0;
		}
		
		if(repeatEvery<1){
			repeatEvery=1;
		}
		
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;//|NSWeekdayCalendarUnit|NSWeekdayOrdinalCalendarUnit;
		NSDateComponents *comps = [gregorian components:unitFlags fromDate:tmp];
		
		NSInteger nextMonth=[comps month];
		NSInteger nextYear=[comps year];
		NSInteger wd=[ivoUtility getWeekday:tmp];
		NSInteger wdo=[ivoUtility getWeekdayOrdinal:tmp];
		
		[self addInstanceIntoList:task toList:list instanceKey:dummyKey forDate:tmp];
		dummyKey=dummyKey-1;
		
		//NSInteger loopCount=0;//used to exit loop if any unknow exception cases happened
		while ([tmp compare:untilDate]==NSOrderedAscending){//maximum display is 2 years
			
			//if(loopCount==730){//for debugger only
			///	//printf("\nTask Manager: Can't createRepeatEventInstanceList from list because of looped forever\n");
			//}
			
			switch (task.taskRepeatID) {
				case REPEAT_DAILY://daily
				{
					tmp=[tmp dateByAddingTimeInterval:86400*repeatEvery];
					
					if(task.taskNumberInstances>0 && [tmp compare:task.taskEndRepeatDate]==NSOrderedDescending){
						goto exitWhile;
					}
					[self addInstanceIntoList:task toList:list instanceKey:dummyKey forDate:tmp];
					dummyKey=dummyKey-1;
				}
					break;
					
				case REPEAT_WEEKLY://weekly
					//check the options
				{
					if(repeatOn !=nil && ![repeatOn isEqualToString:@""]){
						NSArray *selectDays=[repeatOn componentsSeparatedByString:@"|"];
						NSInteger firstInstanceWeekDay=[ivoUtility getWeekday:tmp];
						NSInteger peakDaysInWeek=0;
						//set to the first day of week
						tmp=[tmp dateByAddingTimeInterval:-(firstInstanceWeekDay-1)*86400];
						
						NSDate *groupIntancesDate=nil;
						for (NSInteger i=0;i<selectDays.count;i++){
							
						beginFor:
							peakDaysInWeek=(NSInteger)[(NSString *)[selectDays objectAtIndex:i] intValue];
							
							groupIntancesDate=[tmp dateByAddingTimeInterval:(peakDaysInWeek-1)* 86400];
							tmpEndate=[groupIntancesDate dateByAddingTimeInterval:task.taskHowLong];

							if([groupIntancesDate compare:task.taskStartTime]!=NSOrderedDescending){
								//tmpEndate=[groupIntancesDate dateByAddingTimeInterval:task.taskHowLong];
								
								if((task.taskNumberInstances>0 && [tmpEndate compare:task.taskEndRepeatDate]==NSOrderedDescending)
								   || [tmpEndate compare:untilDate]==NSOrderedDescending){
									goto exitWhile;
								}
								
								i++;
								if(i<selectDays.count){
									goto beginFor;
								}else {
									break;
								}
								
							}
							
							if((task.taskNumberInstances>0 && [tmpEndate compare:task.taskEndRepeatDate]==NSOrderedDescending)
							   || [tmpEndate compare:untilDate]==NSOrderedDescending){
								goto exitWhile;
							}
							
							[self addInstanceIntoList:task toList:list instanceKey:dummyKey forDate:groupIntancesDate];
							dummyKey=dummyKey-1;
						}
					}
					
					tmp=[tmp dateByAddingTimeInterval:604800*repeatEvery];
				}
					break;
				case REPEAT_MONTHLY://monthly
				{
					nextMonth=nextMonth + repeatEvery;
					if(nextMonth<=12){ 
						[comps setMonth:nextMonth];
					}else {
						[comps setYear:[comps year] +(NSInteger)(nextMonth/12)];
						[comps setMonth:nextMonth - (NSInteger)(nextMonth/12) *12];
					}
					
					if(repeatBy==0){//weekday
						
					}else {//weekday name
						[comps setWeekday:wd];
						[comps setWeekdayOrdinal:wdo];
					}
					
					tmp= [gregorian dateFromComponents:comps];
					if(task.taskNumberInstances>0 && [tmp compare:task.taskEndRepeatDate]==NSOrderedDescending){
						goto exitWhile;
					}
					[self addInstanceIntoList:task toList:list instanceKey:dummyKey forDate:tmp];
					dummyKey=dummyKey-1;
				}
					break;
				case REPEAT_YEARLY://yearly
				{
					nextYear=nextYear +repeatEvery;
					[comps setYear:nextYear];
					tmp= [gregorian dateFromComponents:comps];
					
					if(task.taskNumberInstances>0 && [tmp compare:task.taskEndRepeatDate]==NSOrderedDescending){
						goto exitWhile;
					}
					[self addInstanceIntoList:task toList:list instanceKey:dummyKey forDate:tmp];
					dummyKey=dummyKey-1;
					
				}
					break;
					
				default:
					goto exitWhile;
					break;
					
			}
		}
	exitWhile:	

		if(repeatOn !=nil){
			[repeatOn release];
			repeatOn=nil;
		}
		[gregorian release];
	}

	
	return list;
}

//this will fill dummies from list into toList, the list must be a REList
//if fromDate is nil:
//	- it will start generate dummies from REStartTime if isCleanOldDummies is YES.
//  - start generate dummies from filledDummiesToDate if isRememberFilledDate is YES

-(NSDate *)fillRepeatEventInstances:(NSMutableArray *)list 
							 toList:(NSMutableArray*)toList 
						   fromDate:(NSDate *)fromDate 
			   getInstanceUntilDate:(NSDate *)getInstanceUntilDate 
				isShowPastInstances:(BOOL)isShowPastInstances 
				  isCleanOldDummies:(BOOL)isCleanOldDummies 
			   isRememberFilledDate:(BOOL)isRememberFilledDate
		   isNeedAtLeastOneInstance:(BOOL)isNeedAtLeastOneInstance
{
	
	NSDate *ret=getInstanceUntilDate;
	NSDate *untilDate;
	NSDate *tmp;
	NSMutableArray *tmpList=[NSMutableArray arrayWithArray:list];
	NSDate *previousDate=nil;
	
	//Clean all old dummies from toList and reset the remember filled date if any
	if(isCleanOldDummies){
		NSMutableArray *array=[NSMutableArray arrayWithArray:toList];
		for(Task *task in tmpList){
			for(Task *dummy in array){
				if(dummy.primaryKey<-1 && dummy.parentRepeatInstance==task.primaryKey){
					[toList removeObject:dummy];
					if(isRememberFilledDate)//reset filledDate
						task.filledDummiesToDate=task.taskREStartTime;
				}
			}
		}
	}
	
	for(Task *task in tmpList){
		if((task.taskPinned==1) && (task.taskRepeatID > 0)){
			////printf("\n fill dummies for RE: %s, start from date: %s -to Date: %s",[task.taskName UTF8String],[[fromDate description] UTF8String],[[getInstanceUntilDate description] UTF8String]);
			if(getInstanceUntilDate && [getInstanceUntilDate compare:task.taskREStartTime]==NSOrderedAscending){
				continue;
			}
			
			//get repeat options, we need to know the repeat options to get exactly its dummies.
			NSInteger repeatEvery;
			NSInteger repeatBy;
			NSString *repeatOn;
			
			if(task.taskRepeatOptions !=nil && ![task.taskRepeatOptions isEqualToString:@""]){
				NSArray *options=[task.taskRepeatOptions componentsSeparatedByString:@"/"];
				repeatEvery=[(NSString*)[options objectAtIndex:0] intValue];
				repeatOn=[(NSString*)[options objectAtIndex:1] copy];
				repeatBy=[(NSString*)[options objectAtIndex:2] intValue];
			}else {
				repeatEvery=1;
				repeatOn=@"";
				repeatBy=0;
			}
			
			if(repeatEvery<1){
				repeatEvery=1;
			}
			
			//get temporary end repeat date when RE will be displayed until.
			untilDate=getInstanceUntilDate;
			
			//we need to adjust the until time to the RE End time
			NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;//|NSWeekdayCalendarUnit|NSWeekdayOrdinalCalendarUnit;
			NSDateComponents *compsCurDate = [gregorian components:unitFlags fromDate:[NSDate date]];
		
			if([fromDate compare:getInstanceUntilDate]!=NSOrderedSame){
				NSDate *nextTwoDays;//
				switch (task.taskRepeatID) {
					case REPEAT_DAILY:
						//nextTwoDays=[[NSDate date] dateByAddingTimeInterval:172800*repeatEvery];
						[compsCurDate setDay:[compsCurDate day]+2*repeatEvery];
						break;
					case REPEAT_WEEKLY:
						//nextTwoDays=[[NSDate date] dateByAddingTimeInterval:604800*repeatEvery];
						[compsCurDate setDay:[compsCurDate day]+14*repeatEvery];
						break;
					case REPEAT_MONTHLY:
						//nextTwoDays=[[NSDate date] dateByAddingTimeInterval:2678400*repeatEvery];
						[compsCurDate setMonth:[compsCurDate month]+2*repeatEvery];
						break;
					case REPEAT_YEARLY:
						//nextTwoDays=[[NSDate date] dateByAddingTimeInterval:31536000*repeatEvery];
						[compsCurDate setYear:[compsCurDate year]+2*repeatEvery];
						break;
				}
				nextTwoDays=[gregorian dateFromComponents:compsCurDate];
				
				if([untilDate compare:nextTwoDays]==NSOrderedAscending)
					untilDate=nextTwoDays;
			}
			
			//start display from the RE Start time
			tmp=task.taskStartTime;
			
			NSDateComponents *comps = [gregorian components:unitFlags fromDate:tmp];
			NSDateComponents *compsTodate = [gregorian components:unitFlags fromDate:untilDate];
			
			//NSInteger nextMonth=[comps month];
			//NSInteger nextYear=[comps year];
			NSInteger wd=[ivoUtility getWeekday:tmp];
			NSInteger wdo=[ivoUtility getWeekdayOrdinal:tmp];
			
			[compsTodate setHour:24];
			[compsTodate setMinute:0];
			[compsTodate setSecond:0];
			
			//reset Until Date time to the end of RE time (RE End time)
			untilDate=[gregorian dateFromComponents:compsTodate];
			
			if([untilDate compare:task.taskEndRepeatDate]!=NSOrderedAscending && task.taskNumberInstances > 0){
				//untilDate=task.isAllDayEvent?[task.taskEndRepeatDate dateByAddingTimeInterval:86400-1]:task.taskEndRepeatDate;
				untilDate=task.taskEndRepeatDate;
			}
			
			NSDate *startFromDate=tmp;
			
			if(!isRememberFilledDate){
				if(fromDate){
					startFromDate=fromDate;
				}
			}else {
				startFromDate=task.filledDummiesToDate;
			}
			
			BOOL isLastInstanceInSeries=NO;
			
			NSMutableArray *dummies=[NSMutableArray array];
			Task *previousInstance = task;
			task.isOneMoreInstance=NO;
			
			previousDate=nil;
			
			if([startFromDate compare:untilDate]==NSOrderedDescending) 
				continue;
			
			//NSInteger loopCount=[untilDate timeIntervalSinceDate:startFromDate]/(86400) +7;
			
			NSInteger loopCount=5000;
			BOOL	isShifted=NO;
			
			while (loopCount>=0 &&[tmp compare:untilDate]==NSOrderedAscending){
				if(loopCount==0){
					//printf("\n Exist Fill RE list unexpected!");
				}
				switch (task.taskRepeatID) {
					case REPEAT_DAILY://daily
					{
						
						//tmp=[tmp dateByAddingTimeInterval:86400*repeatEvery];
						comps = [gregorian components:unitFlags fromDate:tmp];
						[comps setDay:[comps day]+repeatEvery];
						tmp=[gregorian dateFromComponents:comps];
						
						if (!isShifted && !([tmp compare:startFromDate]!=NSOrderedAscending || [(NSDate*)[tmp dateByAddingTimeInterval:task.taskHowLong] compare:startFromDate]!=NSOrderedAscending)){
							[comps setDay:[comps day]+(((NSInteger)([startFromDate timeIntervalSinceDate:tmp]/86400)/repeatEvery)*repeatEvery)];
							tmp=[gregorian dateFromComponents:comps];
							isShifted=YES;
							//goto dContinueLoop;
						}
						
						if(task.taskNumberInstances>0 && [tmp compare:task.taskEndRepeatDate]!=NSOrderedAscending){
							isLastInstanceInSeries=YES;
							goto exitWhile;
						}
						
						if ([tmp compare:untilDate]==NSOrderedDescending){
							goto exitWhile;
						}
						
						previousInstance=[self addInstanceIntoList:task toList:dummies instanceKey:dummyKey forDate:tmp];
						dummyKey=dummyKey-1;
						if(isRememberFilledDate)
							task.filledDummiesToDate=tmp;
						
						//						tmp=date;
						loopCount-=1;
						
					dContinueLoop:{}
						
					}
						break;
						
					case REPEAT_WEEKLY://weekly
					{
						if (!isShifted && !([tmp compare:startFromDate]!=NSOrderedAscending || [(NSDate*)[tmp dateByAddingTimeInterval:task.taskHowLong] compare:startFromDate]!=NSOrderedAscending)){
							[comps setDay:[comps day]+(NSInteger)(((NSInteger)([startFromDate timeIntervalSinceDate:tmp]/86400)/(7*repeatEvery))*(7*repeatEvery))];
							tmp=[gregorian dateFromComponents:comps];
							isShifted=YES;
							//goto dContinueLoop;
						}
						
						//check the options
						if(repeatOn !=nil && ![repeatOn isEqualToString:@""]){
							NSArray *selectDays=[repeatOn componentsSeparatedByString:@"|"];
							NSInteger firstInstanceWeekDay=[ivoUtility getWeekday:tmp];
							NSInteger peakDaysInWeek=0;
							
							//set to the first day of week
							if(selectDays.count>4){
								ret=tmp;
							}
							
							//tmp=[tmp dateByAddingTimeInterval:-(firstInstanceWeekDay-1)*86400];
							comps = [gregorian components:unitFlags fromDate:tmp];
							[comps setDay:[comps day]-(firstInstanceWeekDay-1)];
							tmp=[gregorian dateFromComponents:comps];
							
							NSDate *groupIntancesDate=nil;
							
							NSInteger i=0;
							for (i;i<selectDays.count;i++){
								
							beginFor:
								peakDaysInWeek=(NSInteger)[(NSString *)[selectDays objectAtIndex:i] intValue];
								
								if(selectDays.count>4 && (task.taskNumberInstances==0)){
									ret=groupIntancesDate?groupIntancesDate:tmp;
								}
								
								//groupIntancesDate=[tmp dateByAddingTimeInterval:(peakDaysInWeek-1)* 86400];
								comps = [gregorian components:unitFlags fromDate:tmp];
								[comps setDay:[comps day]+(peakDaysInWeek-1)];
								groupIntancesDate=[gregorian dateFromComponents:comps];
								
								if (!([groupIntancesDate compare:startFromDate]!=NSOrderedAscending || [(NSDate*)[groupIntancesDate dateByAddingTimeInterval:task.taskHowLong] compare:startFromDate]!=NSOrderedAscending)) {
									goto wContinueLoop;
								}
								
								if([groupIntancesDate compare:task.taskStartTime]!=NSOrderedDescending){
									
									if(task.taskNumberInstances>0 && [tmp compare:task.isAllDayEvent?[task.taskEndRepeatDate dateByAddingTimeInterval:86400]:task.taskEndRepeatDate]==NSOrderedDescending){
										isLastInstanceInSeries=YES;
										goto exitWhile;
									}else if([groupIntancesDate compare:untilDate]!=NSOrderedAscending){
										goto exitWhile;
									}
									
									i+=1;
									if(i<selectDays.count){
										goto beginFor;
									}else {
										break;
									}
								}
								
								if(task.taskNumberInstances>0 && [tmp compare:task.isAllDayEvent?[task.taskEndRepeatDate dateByAddingTimeInterval:86400]:task.taskEndRepeatDate]==NSOrderedDescending){
									isLastInstanceInSeries=YES;
									goto exitWhile;
								}else if([groupIntancesDate compare:untilDate]!=NSOrderedAscending){
									goto exitWhile;
								}
								
								previousInstance=[self addInstanceIntoList:task toList:dummies instanceKey:dummyKey forDate:groupIntancesDate];
								dummyKey=dummyKey-1;
								if(isRememberFilledDate)
									task.filledDummiesToDate=groupIntancesDate;
								
							wContinueLoop:{}
								
							}
							
							comps = [gregorian components:unitFlags fromDate:tmp];
							[comps setDay:[comps day] + 7*repeatEvery];
							tmp=[gregorian dateFromComponents:comps];

							//tmp=[tmp dateByAddingTimeInterval:604800*repeatEvery];
							
							loopCount-=1;
						}else {
							
							//tmp=[tmp dateByAddingTimeInterval:604800*repeatEvery];
							if (!isShifted && !([tmp compare:startFromDate]!=NSOrderedAscending || [(NSDate*)[tmp dateByAddingTimeInterval:task.taskHowLong] compare:startFromDate]!=NSOrderedAscending)){ 
								[comps setDay:[comps day]+(NSInteger)(((NSInteger)([startFromDate timeIntervalSinceDate:tmp]/86400)/(7*repeatEvery))*(7*repeatEvery))];
								tmp=[gregorian dateFromComponents:comps];
								isShifted=YES;
								//goto wContinueLoop1;
							}else {
								[comps setDay:[comps day] + 7*repeatEvery];
								tmp=[gregorian dateFromComponents:comps];
							}

						
							if(task.taskNumberInstances>0 && [tmp compare:task.isAllDayEvent?[task.taskEndRepeatDate dateByAddingTimeInterval:86400]:task.taskEndRepeatDate]==NSOrderedDescending){
								isLastInstanceInSeries=YES;
								goto exitWhile;
							}
							
							if ([tmp compare:untilDate]!=NSOrderedAscending){
								goto exitWhile;
							}
							
							//if ([tmp compare:startFromDate]!=NSOrderedAscending || [(NSDate*)[tmp dateByAddingTimeInterval:task.taskHowLong] compare:startFromDate]!=NSOrderedAscending) {
							previousInstance=[self addInstanceIntoList:task toList:dummies instanceKey:dummyKey forDate:tmp];
							dummyKey=dummyKey-1;
							if(isRememberFilledDate)
								task.filledDummiesToDate=tmp;
							
							loopCount-=1;
							
							//							tmp=date;
						wContinueLoop1:
							{}
						}
					}
						break;
					case REPEAT_MONTHLY://monthly
					{
						/*
						 nextMonth=nextMonth + repeatEvery;
						if(nextMonth<=12){ 
							[comps setMonth:nextMonth];
						}else {
							[comps setYear:[comps year] +(NSInteger)(nextMonth/12)];
							[comps setMonth:nextMonth - (NSInteger)(nextMonth/12) *12];
							nextMonth=1;
						}
						*/
						
						[comps setMonth:[comps month]+repeatEvery];
						
						if(repeatBy==0){//weekday
							
						}else {//weekday name
							[comps setWeekday:wd];
							[comps setWeekdayOrdinal:wdo];
						}
						
						tmp= [gregorian dateFromComponents:comps];
						
						if (!isShifted &&!([tmp compare:startFromDate]!=NSOrderedAscending || [(NSDate*)[tmp dateByAddingTimeInterval:task.taskHowLong] compare:startFromDate]!=NSOrderedAscending)){
							[comps setYear:[ivoUtility getYear:startFromDate]];
							[comps setMonth:[ivoUtility getMonth:startFromDate]];
							tmp= [gregorian dateFromComponents:comps];
							isShifted=YES;
							//goto mContinueLoop;
						}
						
						if(task.taskNumberInstances>0 && [tmp compare:task.isAllDayEvent?[task.taskEndRepeatDate dateByAddingTimeInterval:86400]:task.taskEndRepeatDate]==NSOrderedDescending){
							isLastInstanceInSeries=YES;
							goto exitWhile;
						}
						
						if ([tmp compare:untilDate]!=NSOrderedAscending){
							goto exitWhile;
						}
						
						//if ([tmp compare:startFromDate]!=NSOrderedAscending || [(NSDate*)[tmp dateByAddingTimeInterval:task.taskHowLong] compare:startFromDate]!=NSOrderedAscending) {	
						previousInstance=[self addInstanceIntoList:task toList:dummies instanceKey:dummyKey forDate:tmp];
						dummyKey=dummyKey-1;
						if(isRememberFilledDate)
							task.filledDummiesToDate=tmp;
						
						loopCount-=1;
						
					mContinueLoop:{}
						
					}
						break;
					case REPEAT_YEARLY://yearly
					{
						//nextYear=nextYear +repeatEvery;
						[comps setYear: [comps year]+repeatEvery];
						
						tmp= [gregorian dateFromComponents:comps];
						
						if (!isShifted && !([tmp compare:startFromDate]!=NSOrderedAscending || [(NSDate*)[tmp dateByAddingTimeInterval:task.taskHowLong] compare:startFromDate]!=NSOrderedAscending)){
							[comps setYear:[ivoUtility getYear:startFromDate]];
							tmp= [gregorian dateFromComponents:comps];
							isShifted=YES;
							//goto yContinueLoop;
						}
						
						if(task.taskNumberInstances>0 && [tmp compare:task.isAllDayEvent?[task.taskEndRepeatDate dateByAddingTimeInterval:86400]:task.taskEndRepeatDate]!=NSOrderedAscending){
							isLastInstanceInSeries=YES;
							goto exitWhile;
						}
						
						if ([tmp compare:untilDate]!=NSOrderedAscending){
							goto exitWhile;
						}
						
						previousInstance=[self addInstanceIntoList:task toList:dummies instanceKey:dummyKey forDate:tmp];
						dummyKey=dummyKey-1;
						if(isRememberFilledDate)
							task.filledDummiesToDate=tmp;
						
						loopCount-=1;
						
					yContinueLoop:{}
						
					}
						break;
						
					default:
						goto exitWhile;
						break;
						
				}
			}
		exitWhile:	
			
			if(task.taskNumberInstances>0 && [previousInstance.taskEndTime isEqualToDate: task.isAllDayEvent?[task.taskEndRepeatDate dateByAddingTimeInterval:86400]:task.taskEndRepeatDate]){
				isLastInstanceInSeries=YES;
			} 
			
			if(previousInstance !=nil && ((!isLastInstanceInSeries && previousInstance.primaryKey < -1) 
										  || (previousInstance.primaryKey>-1 && previousInstance.taskNumberInstances !=1))){
				previousInstance.isOneMoreInstance=YES;
			}else {
				previousInstance.isOneMoreInstance=NO;
			}
			
			
			isLastInstanceInSeries=NO;
			
			if(repeatOn !=nil){
				[repeatOn release];
				repeatOn=nil;
			}
			
			[gregorian release];
			
			//clean RE exception instances
			[self cleanExceptionInstanceInMainSeries:task inList:dummies];
			
			if(isNeedAtLeastOneInstance && dummies.count==0){
				[self fillFirstDummyREInstanceToList:dummies rootRE:task];
			}
			
			[toList addObjectsFromArray:dummies];
			
		}
		
	}
	
endFill:	
	
	return ret;
}

//trung ST3.1
-(Task *)fillREInstanceIntoList:(Task *)task toList:(NSMutableArray *)list instanceKey:(NSInteger)instanceKeyp forDate:(NSDate *)date
{
	Task *tmpTask = nil;
    
	NSMutableArray *sourceList=[NSMutableArray arrayWithArray:list];
	for (Task *task in sourceList)
	{
		if (task.primaryKey == instanceKeyp)
		{
			tmpTask = task;
			
			break;
		}
	}
	
	if (tmpTask == nil)
	{
		tmpTask=[[Task alloc] init];
		
		NSInteger index4Instance=[ivoUtility getTimeSlotIndexForTask:tmpTask inArray:sourceList];
		
		[list insertObject:tmpTask atIndex:index4Instance];
		[tmpTask release];		
	}
	
	[ivoUtility copyTask:task toTask:tmpTask isIncludedPrimaryKey:NO];
	tmpTask.primaryKey=instanceKeyp;
	//instanceKey=instanceKey-1;
	tmpTask.taskStartTime=date;
	//tmpTask.taskSynKey=0;
	tmpTask.isOneMoreInstance=NO;
	tmpTask.parentRepeatInstance=task.primaryKey;
	tmpTask.taskEndTime=[tmpTask.taskStartTime dateByAddingTimeInterval:tmpTask.taskHowLong];
	
	return tmpTask;
}

//trung ST3.1
- (void) fillFirstDummyREInstanceToList: (NSMutableArray *)list rootRE:(Task *)task
{
	NSDate *tmp=task.taskStartTime;
	//NSDate *tmpEndate=[tmp dateByAddingTimeInterval:task.taskHowLong];
	
	//NSInteger instanceKey=-2;	
	
	//get repeat options:
	NSInteger repeatEvery;
	NSInteger repeatBy;
	NSString *repeatOn;
	
	if(task.taskRepeatOptions !=nil && ![task.taskRepeatOptions isEqualToString:@""]){
		NSArray *options=[task.taskRepeatOptions componentsSeparatedByString:@"/"];
		repeatEvery=[(NSString*)[options objectAtIndex:0] intValue];
		repeatOn=[(NSString*)[options objectAtIndex:1] copy];
		repeatBy=[(NSString*)[options objectAtIndex:2] intValue];
	}else {
		repeatEvery=1;
		repeatOn=@"";
		repeatBy=0;
	}
	
	if(repeatEvery<1){
		repeatEvery=1;
	}
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;//|NSWeekdayCalendarUnit|NSWeekdayOrdinalCalendarUnit;	
	
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:tmp];
	
	NSInteger nextMonth=[comps month];
	NSInteger nextYear=[comps year];
	NSInteger wd=[ivoUtility getWeekday:tmp];
	NSInteger wdo=[ivoUtility getWeekdayOrdinal:tmp];
	
	NSDate *untilDate = nil;
	
	if(task.taskNumberInstances > 0 && task.taskEndRepeatDate != nil){
		//untilDate=task.isAllDayEvent?[task.taskEndRepeatDate dateByAddingTimeInterval:86400-1]:task.taskEndRepeatDate;
		untilDate=task.taskEndRepeatDate;
	}
	
	BOOL isLastInstanceInSeries=NO;
	//BOOL isAddedDSTOffset=NO;
	
	Task *previousInstance = task;
	task.isOneMoreInstance=NO;	
	
	while (YES)
	{
		switch (task.taskRepeatID) 
		{
			case REPEAT_DAILY://daily
			{
				
				//tmp=[tmp dateByAddingTimeInterval:86400*repeatEvery];
				
				comps = [gregorian components:unitFlags fromDate:tmp];
				[comps setDay:[comps day]+repeatEvery];
				tmp=[gregorian dateFromComponents:comps];
				
				if ([self isExistedExceptionOnDate:tmp forRE:task inList:list])
				{
					continue;
				}
				
				if([tmp compare:[NSDate date]]==NSOrderedAscending){
					continue;
				}
				
				if(untilDate != nil && [tmp compare:untilDate]==NSOrderedDescending){
					isLastInstanceInSeries=YES;
					goto exitWhile;
				}				
				
				//previousInstance=[self fillREInstanceIntoList:task toList:list instanceKey:dummyKey forDate:tmp];
				previousInstance=[self addInstanceIntoList:task toList:list instanceKey:dummyKey forDate:tmp];
				
				dummyKey=dummyKey-1;
				
				goto exitWhile;
			}
				break;
				
			case REPEAT_WEEKLY://weekly
				//check the options
			{
				NSDate *groupIntancesDate=nil;				
				
				if(repeatOn !=nil && ![repeatOn isEqualToString:@""])
				{
					NSArray *selectDays=[repeatOn componentsSeparatedByString:@"|"];
					NSInteger firstInstanceWeekDay=[ivoUtility getWeekday:tmp];
					NSInteger peakDaysInWeek=0;
					
					//tmp=[tmp dateByAddingTimeInterval:-(firstInstanceWeekDay-1)*86400];
					comps = [gregorian components:unitFlags fromDate:tmp];
					[comps setDay:[comps day]-(firstInstanceWeekDay-1)];
					tmp=[gregorian dateFromComponents:comps];
					
					NSInteger i=0;
					for (i;i<selectDays.count;i++)
					{
						peakDaysInWeek=(NSInteger)[(NSString *)[selectDays objectAtIndex:i] intValue];
						
						//groupIntancesDate=[tmp dateByAddingTimeInterval:(peakDaysInWeek-1)* 86400];
						comps = [gregorian components:unitFlags fromDate:tmp];
						[comps setDay:[comps day]+(peakDaysInWeek-1)];
						groupIntancesDate=[gregorian dateFromComponents:comps];
						
						//if(untilDate != nil && [tmpEndate compare:untilDate]==NSOrderedDescending){
						if(untilDate != nil && [groupIntancesDate compare:untilDate]!=NSOrderedAscending){
							isLastInstanceInSeries=YES;
							goto exitWhile;
						}
						
						if ([groupIntancesDate compare:task.taskStartTime] != NSOrderedDescending || [groupIntancesDate compare:[NSDate date]]==NSOrderedAscending) //before or same as root re date -> discard
						{
							groupIntancesDate = nil;
							
							continue;
						}
						
						if ([self isExistedExceptionOnDate:groupIntancesDate forRE:task inList:list])
						{
							groupIntancesDate = nil;
							
							continue;
						}
						else
						{
							break;
						}						
					}
					
					if (groupIntancesDate != nil)
					{
						previousInstance=[self addInstanceIntoList:task toList:list instanceKey:dummyKey forDate:groupIntancesDate];
						dummyKey-=1;
						goto exitWhile;							
					}
					
					comps = [gregorian components:unitFlags fromDate:tmp];
					[comps setDay:[comps day]+7*repeatEvery];
					tmp=[gregorian dateFromComponents:comps];
				}
				else 
				{
					//tmp=[tmp dateByAddingTimeInterval:604800*repeatEvery];
					comps = [gregorian components:unitFlags fromDate:tmp];
					[comps setDay:[comps day]+7*repeatEvery];
					tmp=[gregorian dateFromComponents:comps];
					
					if(untilDate != nil && [tmp compare:untilDate]!=NSOrderedAscending){
						isLastInstanceInSeries=YES;
						goto exitWhile;
					}
					
					if ([self isExistedExceptionOnDate:tmp forRE:task inList:list])
					{
						continue;
					}
					
					previousInstance=[self addInstanceIntoList:task toList:list instanceKey:dummyKey forDate:tmp];
					dummyKey-=1;
					
					goto exitWhile;					
				}
			}
				break;
			case REPEAT_MONTHLY://monthly
			{
				nextMonth=nextMonth + repeatEvery;
				if(nextMonth<=12){ 
					[comps setMonth:nextMonth];
				}else {
					[comps setYear:[comps year] +(NSInteger)(nextMonth/12)];
					[comps setMonth:nextMonth - (NSInteger)(nextMonth/12) *12];
					nextMonth=1;
				}
				
				if(repeatBy==0){//weekday
					
				}else {//weekday name
					[comps setWeekday:wd];
					[comps setWeekdayOrdinal:wdo];
				}
				
				tmp= [gregorian dateFromComponents:comps];
				
				if([tmp compare:[NSDate date]]==NSOrderedAscending){
					continue;
				}
				
				if(untilDate != nil && [tmp compare:untilDate]!=NSOrderedAscending){
					isLastInstanceInSeries=YES;
					goto exitWhile;
				}
				
				if ([self isExistedExceptionOnDate:tmp forRE:task inList:list])
				{
					continue;
				}
				
				//previousInstance=[self fillREInstanceIntoList:task toList:list instanceKey:dummyKey forDate:tmp];
				previousInstance=[self addInstanceIntoList:task toList:list instanceKey:dummyKey forDate:tmp];
				dummyKey-=1;
				
				goto exitWhile;					
				
			}
				break;
			case REPEAT_YEARLY://yearly
			{
				nextYear=nextYear +repeatEvery;
				[comps setYear:nextYear];
				
				tmp= [gregorian dateFromComponents:comps];
				
				if([tmp compare:[NSDate date]]==NSOrderedAscending){
					continue;
				}
				
				if(untilDate != nil && [tmp compare:untilDate]!=NSOrderedAscending){
					isLastInstanceInSeries=YES;
					goto exitWhile;
				}
				
				if ([self isExistedExceptionOnDate:tmp forRE:task inList:list])
				{
					continue;
				}
				
				//previousInstance=[self fillREInstanceIntoList:task toList:list instanceKey:dummyKey forDate:tmp];
				previousInstance=[self addInstanceIntoList:task toList:list instanceKey:dummyKey forDate:tmp];
				dummyKey-=1;
				
				goto exitWhile;					
				
			}
				break;
				
			default:
				goto exitWhile;
				break;
				
		}
		
		if (untilDate != nil && [tmp compare:untilDate] != NSOrderedAscending)
		{
			break;
		}
	}
	
exitWhile:	
	if(task.taskNumberInstances>0 && [previousInstance.taskEndTime isEqualToDate: task.isAllDayEvent?[task.taskEndRepeatDate dateByAddingTimeInterval:86400]:task.taskEndRepeatDate]){
		isLastInstanceInSeries=YES;
	} 
	
	if(previousInstance !=nil && ((!isLastInstanceInSeries && previousInstance.primaryKey < -1) 
								  || ([previousInstance isEqual:task] && task.taskNumberInstances !=1))){
		previousInstance.isOneMoreInstance=YES;
	}else {
		previousInstance.isOneMoreInstance=NO;
	}
	
	
	isLastInstanceInSeries=NO;
	if(repeatOn !=nil){
		[repeatOn release];
		repeatOn=nil;
	}
	
	[gregorian release];
}

-(void)addTaskToList:(Task *)task toList:(NSMutableArray *)list fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate split:(BOOL)split
{
    
	if ((fromDate == nil && toDate == nil && task.taskPinned == 1 && [ivoUtility compareDateNoTime:task.taskStartTime withDate:[NSDate date]] != NSOrderedAscending) || //for SmartView, exclude past event 
		(fromDate == nil && [toDate compare:task.taskEndTime] != NSOrderedAscending) ||
		(toDate == nil && [task.taskStartTime compare:fromDate] != NSOrderedAscending) ||
		(fromDate != nil && toDate != nil && [task.taskStartTime compare:fromDate] != NSOrderedAscending && [task.taskStartTime compare:toDate] == NSOrderedAscending) ||
		(fromDate != nil && toDate != nil && [fromDate compare:task.taskEndTime] == NSOrderedAscending && [toDate compare:task.taskEndTime] != NSOrderedAscending) ||
		(fromDate != nil && toDate != nil && [task.taskStartTime compare:fromDate] == NSOrderedAscending && [toDate compare:task.taskEndTime] == NSOrderedAscending))
	{
		if (split && !task.isAllDayEvent)
		{
			if (fromDate == nil)
			{
				fromDate = task.taskStartTime;
			}
			if (toDate == nil)
			{
				toDate = task.taskEndTime;
			}
			
			NSDate *beginDate = ([task.taskStartTime compare:fromDate] == NSOrderedDescending? task.taskStartTime : fromDate);
			NSDate *endDate = ([task.taskEndTime compare:toDate] == NSOrderedAscending? task.taskEndTime : toDate);
			
			NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;			
			
			NSDate *tmpStartDate = beginDate; 
			
			while ([tmpStartDate compare:endDate] == NSOrderedAscending)
			{
				NSDateComponents *comps = [gregorian components:unitFlags fromDate:tmpStartDate];
				[comps setHour:24];
				[comps setMinute:0];
				[comps setSecond:0];
				NSDate *tmpEndDate=[gregorian dateFromComponents:comps];
				
				if([tmpEndDate compare:endDate]==NSOrderedDescending){
					tmpEndDate=endDate;
				}				
				
				if (([tmpStartDate compare:fromDate] != NSOrderedAscending && [tmpStartDate compare:toDate] == NSOrderedAscending) ||
					([fromDate compare:tmpEndDate] == NSOrderedAscending && [toDate compare:tmpEndDate] != NSOrderedAscending))
				{
					Task *tmp=[[Task alloc]init];
					[ivoUtility copyTask:task toTask:tmp isIncludedPrimaryKey:YES];
					tmp.taskStartTime=tmpStartDate;
					tmp.taskEndTime=tmpEndDate;
					tmp.taskHowLong=[tmpEndDate timeIntervalSinceDate:tmpStartDate];
					tmp.taskREStartTime = task.taskStartTime;
					
					[list addObject:tmp];
					
					[tmp release];					
				}
				
				comps = [gregorian components:unitFlags fromDate:[tmpStartDate dateByAddingTimeInterval:24*60*60]];
				[comps setHour:0];
				[comps setMinute:0];
				[comps setSecond:0];
				tmpStartDate=[gregorian dateFromComponents:comps];				
			}
			
			[gregorian release];
		}
		else
		{
			[list addObject:task];			
		}
	}
}

/*
-(void)addTaskToList:(Task *)task toList:(NSMutableArray *)list fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate split:(BOOL)split
{
	if ((fromDate == nil && toDate == nil && task.taskPinned == 1 && [ivoUtility compareDateNoTime:task.taskStartTime withDate:[NSDate date]] != NSOrderedAscending) || //for SmartView, exclude past event 
		(fromDate == nil && [toDate compare:task.taskEndTime] != NSOrderedAscending) ||
		 (toDate == nil && [task.taskStartTime compare:fromDate] != NSOrderedAscending) ||
		 (fromDate != nil && toDate != nil && [task.taskStartTime compare:fromDate] != NSOrderedAscending && [task.taskStartTime compare:toDate] == NSOrderedAscending) ||
		 (fromDate != nil && toDate != nil && [fromDate compare:task.taskEndTime] == NSOrderedAscending && [toDate compare:task.taskEndTime] != NSOrderedAscending) ||
		(fromDate != nil && toDate != nil && [task.taskStartTime compare:fromDate] == NSOrderedAscending && [toDate compare:task.taskEndTime] == NSOrderedAscending))
	{
		if (split && !task.isAllDayEvent)
		//if (split)
		{
			if (fromDate == nil)
			{
				fromDate = task.taskStartTime;
			}
			if (toDate == nil)
			{
				toDate = task.taskEndTime;
			}
			
			NSDate *beginDate = ([task.taskStartTime compare:fromDate] == NSOrderedDescending? task.taskStartTime : fromDate);
			NSDate *endDate = ([task.taskEndTime compare:toDate] == NSOrderedAscending? task.taskEndTime : toDate);

			NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;			
			
			NSDate *tmpStartDate = beginDate; 
			
			while ([tmpStartDate compare:endDate] == NSOrderedAscending)
			{
				NSDateComponents *comps = [gregorian components:unitFlags fromDate:tmpStartDate];
				[comps setHour:24];
				[comps setMinute:0];
				NSDate *tmpEndDate=[gregorian dateFromComponents:comps];
				
				if([tmpEndDate compare:endDate]==NSOrderedDescending){
					tmpEndDate=endDate;
				}				
				
				if (([tmpStartDate compare:fromDate] != NSOrderedAscending && [tmpStartDate compare:toDate] == NSOrderedAscending) ||
					([fromDate compare:tmpEndDate] == NSOrderedAscending && [toDate compare:tmpEndDate] != NSOrderedAscending))
				{
					Task *tmp=[[Task alloc]init];
					[ivoUtility copyTask:task toTask:tmp isIncludedPrimaryKey:YES];
					tmp.taskStartTime=tmpStartDate;
					tmp.taskEndTime=tmpEndDate;
					tmp.taskHowLong=[tmpEndDate timeIntervalSinceDate:tmpStartDate];
					tmp.taskREStartTime = task.taskStartTime;
					
					[list addObject:tmp];
					
					[tmp release];					
				}

				comps = [gregorian components:unitFlags fromDate:[tmpStartDate dateByAddingTimeInterval:24*60*60]];
				[comps setHour:0];
				[comps setMinute:0];
				tmpStartDate=[gregorian dateFromComponents:comps];				
			}
			
			[gregorian release];
		}
		else
		{
			[list addObject:task];			
		}
	}else {
		[list addObject:task];			
	}

}
*/
-(Task *)addREInstanceToList:(Task *)task toList:(NSMutableArray *)list fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate instanceKey:(int *)instanceKey forDate:(NSDate *)forDate split:(BOOL)split
{
	NSDate *endForDate = [forDate dateByAddingTimeInterval:task.taskHowLong];
	
	if ((fromDate == nil && toDate == nil && task.taskPinned == 1 && [ivoUtility compareDateNoTime:forDate withDate:[NSDate date]] != NSOrderedAscending) || //for SmartView, exclude past event 
		(fromDate == nil && [toDate compare:endForDate] != NSOrderedAscending) ||
		(toDate == nil && [forDate compare:fromDate] != NSOrderedAscending) ||
		(fromDate != nil && toDate != nil && [forDate compare:fromDate] != NSOrderedAscending && [forDate compare:toDate] == NSOrderedAscending) ||
		(fromDate != nil && toDate != nil && [fromDate compare:endForDate] == NSOrderedAscending && [toDate compare:endForDate] != NSOrderedAscending) ||
		(fromDate != nil && toDate != nil && [forDate compare:fromDate] == NSOrderedAscending && [toDate compare:endForDate] == NSOrderedAscending))
	{
		/*		
		 Task *dummyRE = [self addInstanceIntoList:task toList:list instanceKey:(*instanceKey) forDate:forDate];
		 */
		Task *tmpTask = nil;
		
		if (split && !task.isAllDayEvent)
		{
			if (fromDate == nil)
			{
				fromDate = forDate;
			}
			
			if (toDate == nil)
			{
				toDate = endForDate;
			}
			
			NSDate *beginDate = ([forDate compare:fromDate] == NSOrderedDescending? forDate : fromDate);
			NSDate *endDate = ([endForDate compare:toDate] == NSOrderedAscending? endForDate : toDate);
			
			NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;			
			
			NSDate *tmpStartDate = beginDate;
			Task *lastTask = nil;
			
			while ([tmpStartDate compare:endDate] == NSOrderedAscending)
			{
				NSDateComponents *comps = [gregorian components:unitFlags fromDate:tmpStartDate];
				[comps setHour:24];
				[comps setMinute:0];
				NSDate *tmpEndDate=[gregorian dateFromComponents:comps];
				
				if([tmpEndDate compare:endDate]==NSOrderedDescending){
					tmpEndDate=endDate;
				}
				
				if (([tmpStartDate compare:fromDate] != NSOrderedAscending && [tmpStartDate compare:toDate] == NSOrderedAscending) ||
					([fromDate compare:tmpEndDate] == NSOrderedAscending && [toDate compare:tmpEndDate] != NSOrderedAscending))
				{
					tmpTask=[[Task alloc] init];
					[ivoUtility copyTask:task toTask:tmpTask isIncludedPrimaryKey:NO];
					tmpTask.primaryKey=(*instanceKey);
					tmpTask.isOneMoreInstance=NO;
					tmpTask.parentRepeatInstance=task.primaryKey;
					
					tmpTask.taskStartTime=tmpStartDate;
					tmpTask.taskEndTime=tmpEndDate;
					tmpTask.taskHowLong=[tmpEndDate timeIntervalSinceDate:tmpStartDate];
					tmpTask.taskREStartTime=forDate; 
					
					[list addObject:tmpTask];
					
					lastTask = tmpTask;
					
					[tmpTask release];					
				}					
				
				comps = [gregorian components:unitFlags fromDate:[tmpStartDate dateByAddingTimeInterval:24*60*60]];
				[comps setHour:0];
				[comps setMinute:0];
				tmpStartDate=[gregorian dateFromComponents:comps];				
			}
			
			[gregorian release];
			
			if (lastTask != nil)
			{
				tmpTask = [lastTask retain];
			}
		}
		else
		{
			tmpTask=[[Task alloc] init];
			[ivoUtility copyTask:task toTask:tmpTask isIncludedPrimaryKey:NO];
			tmpTask.primaryKey=(*instanceKey);
			tmpTask.taskStartTime=forDate;
			tmpTask.taskREStartTime=forDate;
			tmpTask.isOneMoreInstance=NO;
			tmpTask.parentRepeatInstance=task.primaryKey;
			tmpTask.taskEndTime=[tmpTask.taskStartTime dateByAddingTimeInterval:tmpTask.taskHowLong];
			
			[list addObject:tmpTask];
		}
		
		(*instanceKey) = (*instanceKey)-1;
		
		if (tmpTask != nil)
		{
			return [tmpTask autorelease];
		}
	}
	
	return nil;
}

/*
-(Task *)addREInstanceToList:(Task *)task toList:(NSMutableArray *)list fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate instanceKey:(int *)instanceKey forDate:(NSDate *)forDate split:(BOOL)split
{
	NSDate *endForDate = [forDate dateByAddingTimeInterval:task.taskHowLong];
	
	if ((fromDate == nil && toDate == nil && task.taskPinned == 1 && [ivoUtility compareDateNoTime:forDate withDate:[NSDate date]] != NSOrderedAscending) || //for SmartView, exclude past event 
		(fromDate == nil && [toDate compare:endForDate] != NSOrderedAscending) ||
		(toDate == nil && [forDate compare:fromDate] != NSOrderedAscending) ||
		(fromDate != nil && toDate != nil && [forDate compare:fromDate] != NSOrderedAscending && [forDate compare:toDate] == NSOrderedAscending) ||
		(fromDate != nil && toDate != nil && [fromDate compare:endForDate] == NSOrderedAscending && [toDate compare:endForDate] != NSOrderedAscending) ||
		(fromDate != nil && toDate != nil && [forDate compare:fromDate] == NSOrderedAscending && [toDate compare:endForDate] == NSOrderedAscending))
	{
		Task *tmpTask = nil;
		
		if (split && !task.isAllDayEvent)
		{
			if (fromDate == nil)
			{
				fromDate = forDate;
			}
			
			if (toDate == nil)
			{
				toDate = endForDate;
			}
			
			NSDate *beginDate = ([forDate compare:fromDate] == NSOrderedDescending? forDate : fromDate);
			NSDate *endDate = ([endForDate compare:toDate] == NSOrderedAscending? endForDate : toDate);
			
			NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;			
			
			NSDate *tmpStartDate = beginDate;
			Task *lastTask = nil;
			
			while ([tmpStartDate compare:endDate] == NSOrderedAscending)
			{
				NSDateComponents *comps = [gregorian components:unitFlags fromDate:tmpStartDate];
				[comps setHour:24];
				[comps setMinute:0];
				NSDate *tmpEndDate=[gregorian dateFromComponents:comps];
				
				if([tmpEndDate compare:endDate]==NSOrderedDescending){
					tmpEndDate=endDate;
				}
				
				if (([tmpStartDate compare:fromDate] != NSOrderedAscending && [tmpStartDate compare:toDate] == NSOrderedAscending) ||
					([fromDate compare:tmpEndDate] == NSOrderedAscending && [toDate compare:tmpEndDate] != NSOrderedAscending))
				{
					tmpTask=[[Task alloc] init];
					[ivoUtility copyTask:task toTask:tmpTask isIncludedPrimaryKey:NO];
					tmpTask.primaryKey=(*instanceKey);
					tmpTask.isOneMoreInstance=NO;
					tmpTask.parentRepeatInstance=task.primaryKey;
					
					tmpTask.taskStartTime=tmpStartDate;
					tmpTask.taskEndTime=tmpEndDate;
					tmpTask.taskHowLong=[tmpEndDate timeIntervalSinceDate:tmpStartDate];
					tmpTask.taskREStartTime=forDate; 
					
					[list addObject:tmpTask];
					
					lastTask = tmpTask;
					
					[tmpTask release];					
				}					
								
				comps = [gregorian components:unitFlags fromDate:[tmpStartDate dateByAddingTimeInterval:24*60*60]];
				[comps setHour:0];
				[comps setMinute:0];
				tmpStartDate=[gregorian dateFromComponents:comps];				
			}
			
			[gregorian release];
			
			if (lastTask != nil)
			{
				tmpTask = [lastTask retain];
			}
		}
		else
		{
			tmpTask=[[Task alloc] init];
			[ivoUtility copyTask:task toTask:tmpTask isIncludedPrimaryKey:NO];
			tmpTask.primaryKey=(*instanceKey);
			tmpTask.taskStartTime=forDate;
			tmpTask.taskREStartTime=forDate;
			tmpTask.isOneMoreInstance=NO;
			tmpTask.parentRepeatInstance=task.primaryKey;
			tmpTask.taskEndTime=[tmpTask.taskStartTime dateByAddingTimeInterval:tmpTask.taskHowLong];
			
			[list addObject:tmpTask];
		}
		
		(*instanceKey) = (*instanceKey)-1;
		
		if (tmpTask != nil)
		{
			return [tmpTask autorelease];
		}
	}
	
	return nil;
}
*/
/*
-(NSMutableArray *)getTaskListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate splitLongTask:(BOOL) splitLongTask
{
//	NSDate *untilDate = nil;
	Task *task;
	NSDate *tmp;
	NSDate *tmpEndate;
	Task *previousInstance=nil;
	//BOOL isShowPastInstances = YES;
	
	NSMutableArray *dummyREList = [NSMutableArray arrayWithCapacity:self.taskList.count]; 
	
	NSMutableArray *list;
	if (self.filterClause == nil || [self.filterClause isEqual:@""])
	{
		list = self.taskList;
	}
	else
	{
		[App_Delegate getFilterTaskList:self.filterClause];
		list = self.filterList;
	}

	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;//|NSWeekdayCalendarUnit|NSWeekdayOrdinalCalendarUnit;
	
	NSDateComponents *comps;
	
	if (fromDate != nil)
	{
		comps = [gregorian components:unitFlags fromDate:fromDate];
		
		[comps setHour:0];
		[comps setMinute:0];
		[comps setSecond:0];
		
		fromDate=[gregorian dateFromComponents:comps];		
	}
	
	if (toDate != nil)
	{
		comps = [gregorian components:unitFlags fromDate:toDate];
		
		[comps setHour:24];
		[comps setMinute:0];
		[comps setSecond:0];
		
		toDate=[gregorian dateFromComponents:comps];		
	}
	
	NSMutableArray *reList = [NSMutableArray arrayWithCapacity:5];
	
	NSMutableArray *retList = (fromDate == nil && toDate == nil && (self.filterClause == nil || [self.filterClause isEqual:@""]))? self.taskList:[NSMutableArray arrayWithCapacity:50];
	
	for(task in list) 
	{
		////printf("Task %s - start: %s - end: %s\n", [task.taskName UTF8String], [[task.taskStartTime description] UTF8String], [[task.taskStartTime description] UTF8String]);
		
		if((task.taskPinned==1) && (task.taskRepeatID > 0) && task.primaryKey > -2)
		{
			[reList addObject:task];
		}
		else if (task.primaryKey >= -1)
		{
			if (retList != self.taskList)
			{
				[self addTaskToList:task toList:retList fromDate:fromDate toDate:toDate split:splitLongTask];
			}
		}
		else if (task.primaryKey < -1)
		{
			if (retList == self.taskList)
			{
				[dummyREList addObject:task];
			}
		}
	}
	
	for (Task *task in dummyREList)
	{
		[retList removeObject:task]; //remove all dummy instances
	}
	
	//Rules for RE's instances: each instance has a negative primarykey, 
	//this is used to identify that instance in application layer. 
	NSInteger instanceKey=-2;
	
	//for(task in tmpList){
	for(task in reList){
		if((task.taskPinned==1) && (task.taskRepeatID > 0) && task.primaryKey > -2){
			
			NSDate *untilDate = nil;
			
			if(task.taskNumberInstances > 0 && task.taskEndRepeatDate != nil){
				untilDate=task.isAllDayEvent?[task.taskEndRepeatDate dateByAddingTimeInterval:86400-1]:task.taskEndRepeatDate;
			}			
			
			NSDate *whileDate = toDate;
			
			//get temporary end repeat date when RE will be displayed until.
			if (whileDate == nil) //for smartView
			{
				 switch (task.taskRepeatID) {
				 case REPEAT_DAILY:
						 whileDate=[[NSDate date] dateByAddingTimeInterval:259200];
						 break;
				 case REPEAT_WEEKLY:
						 whileDate=[[NSDate date] dateByAddingTimeInterval:691200];
						 break;
				 case REPEAT_MONTHLY:
						 whileDate=[[NSDate date] dateByAddingTimeInterval:2764800];
						 break;
				 case REPEAT_YEARLY:
						 whileDate=[[NSDate date] dateByAddingTimeInterval:31622400];
						 break;
				 }
				
				NSDateComponents *compsTodate = [gregorian components:unitFlags fromDate:whileDate];
				[compsTodate setHour:23];
				[compsTodate setMinute:59];
				[compsTodate setSecond:59];
				
				whileDate=[gregorian dateFromComponents:compsTodate];
			}
			
			
			if ([whileDate compare:untilDate] == NSOrderedDescending)
			{
				whileDate = untilDate;
			}			
			
			//start display from the first instance
			tmp=task.taskStartTime;
			tmpEndate=[tmp dateByAddingTimeInterval:task.taskHowLong];
			
			//get repeat options:
			NSInteger repeatEvery;
			NSInteger repeatBy;
			NSString *repeatOn;
			
			if(task.taskRepeatOptions !=nil && ![task.taskRepeatOptions isEqualToString:@""]){
				NSArray *options=[task.taskRepeatOptions componentsSeparatedByString:@"/"];
				repeatEvery=[(NSString*)[options objectAtIndex:0] intValue];
				repeatOn=[(NSString*)[options objectAtIndex:1] copy];
				repeatBy=[(NSString*)[options objectAtIndex:2] intValue];
			}else {
				repeatEvery=1;
				repeatOn=@"";
				repeatBy=0;
			}
			
			if(repeatEvery<1){
				repeatEvery=1;
			}
			
			NSDateComponents *comps = [gregorian components:unitFlags fromDate:tmp];
			
			NSInteger nextMonth=[comps month];
			NSInteger nextYear=[comps year];
			NSInteger wd=[ivoUtility getWeekday:tmp];
			NSInteger wdo=[ivoUtility getWeekdayOrdinal:tmp];
						
			////printf("\n%s",[[ivoUtility createStringFromDate:untilDate isIncludedTime:YES] UTF8String]);
			BOOL isLastInstanceInSeries=NO;
			
			previousInstance=task;
			task.isOneMoreInstance=NO;
			
			if (retList != self.taskList)
			{
				[self addTaskToList:task toList:retList fromDate:fromDate toDate:toDate split:splitLongTask];
			}
			
			NSInteger loopCount=0;//used to stop the loop if unknow exception cases happened, 
			while (loopCount<730)
			{
				loopCount +=1;
				
				if(loopCount==730){//for debugger only
					//printf("\nTask Manager: Can't fillRepeatEventInstances from list because of looped forever\n");
				}
				
				switch (task.taskRepeatID) 
				{
					case REPEAT_DAILY://daily
					{
						tmp=[tmp dateByAddingTimeInterval:86400*repeatEvery];
						tmpEndate=[tmp dateByAddingTimeInterval:task.taskHowLong];

						//if(untilDate != nil && [tmpEndate compare:untilDate]==NSOrderedDescending){
						if(untilDate != nil && [tmp compare:untilDate]==NSOrderedDescending){
							isLastInstanceInSeries=YES;
							goto exitWhile;
						}
						
						previousInstance = [self addREInstanceToList:task toList:retList fromDate:fromDate toDate:toDate instanceKey:&instanceKey forDate:tmp split:splitLongTask];
					}
						break;
						
					case REPEAT_WEEKLY://weekly
						//check the options
					{
						if(repeatOn !=nil && ![repeatOn isEqualToString:@""])
						{
							NSArray *selectDays=[repeatOn componentsSeparatedByString:@"|"];
							NSInteger firstInstanceWeekDay=[ivoUtility getWeekday:tmp];
							NSInteger peakDaysInWeek=0;
							
							NSDate *firstDateOfWeek=[tmp dateByAddingTimeInterval:-(firstInstanceWeekDay-1)*86400];
							
							NSDate *groupIntancesDate=nil;
							
							for (int i=0;i<selectDays.count;i++)
							{
								peakDaysInWeek=(NSInteger)[(NSString *)[selectDays objectAtIndex:i] intValue];
								
								groupIntancesDate=[firstDateOfWeek dateByAddingTimeInterval:(peakDaysInWeek-1)* 86400];
								tmpEndate=[groupIntancesDate dateByAddingTimeInterval:task.taskHowLong];
								
								//if(untilDate != nil && [tmpEndate compare:untilDate]==NSOrderedDescending){
								if(untilDate != nil && [groupIntancesDate compare:untilDate]==NSOrderedDescending){
									isLastInstanceInSeries=YES;
									goto exitWhile;
								}
								
								if ([groupIntancesDate compare:task.taskStartTime] != NSOrderedDescending) //before or same as root re date
								{
									continue;
								}
								
								previousInstance = [self addREInstanceToList:task toList:retList fromDate:fromDate toDate:toDate instanceKey:&instanceKey forDate:groupIntancesDate split:splitLongTask];
								instanceKey=instanceKey-1;
							}
							
							tmp=[firstDateOfWeek dateByAddingTimeInterval:604800*repeatEvery];
							tmpEndate=[tmp dateByAddingTimeInterval:task.taskHowLong];							
							
						
						}else {
							tmp=[tmp dateByAddingTimeInterval:604800*repeatEvery];
							
							tmpEndate=[tmp dateByAddingTimeInterval:task.taskHowLong];
							
							//if(untilDate != nil && [tmpEndate compare:untilDate]==NSOrderedDescending){
							if(untilDate != nil && [tmp compare:untilDate]==NSOrderedDescending){
								isLastInstanceInSeries=YES;
								goto exitWhile;
							}

							previousInstance = [self addREInstanceToList:task toList:retList fromDate:fromDate toDate:toDate instanceKey:&instanceKey forDate:tmp split:splitLongTask];
						}
						
					}
						break;
					case REPEAT_MONTHLY://monthly
					{
						nextMonth=nextMonth + repeatEvery;
						if(nextMonth<=12){ 
							[comps setMonth:nextMonth];
						}else {
							[comps setYear:(nextYear + nextMonth/12)];
							[comps setMonth:nextMonth%12];
						}
						
						if(repeatBy==0){//weekday
							
						}else {//weekday name
							[comps setWeekday:wd];
							[comps setWeekdayOrdinal:wdo];
						}

						tmp= [gregorian dateFromComponents:comps];
						tmpEndate=[tmp dateByAddingTimeInterval:task.taskHowLong];
						
						//if(untilDate != nil && [tmpEndate compare:untilDate]==NSOrderedDescending){
						if(untilDate != nil && [tmp compare:untilDate]==NSOrderedDescending){
							isLastInstanceInSeries=YES;
							goto exitWhile;
						}

						previousInstance = [self addREInstanceToList:task toList:retList fromDate:fromDate toDate:toDate instanceKey:&instanceKey forDate:tmp split:splitLongTask];
						
					}
						break;
					case REPEAT_YEARLY://yearly
					{
						nextYear=nextYear +repeatEvery;
						[comps setYear:nextYear];
						
						tmp= [gregorian dateFromComponents:comps];
						
						tmpEndate=[tmp dateByAddingTimeInterval:task.taskHowLong];
						//if(untilDate != nil && [tmpEndate compare:untilDate]==NSOrderedDescending){
						if(untilDate != nil && [tmp compare:untilDate]==NSOrderedDescending){
							isLastInstanceInSeries=YES;
							goto exitWhile;
						}
						
						previousInstance = [self addREInstanceToList:task toList:retList fromDate:fromDate toDate:toDate instanceKey:&instanceKey forDate:tmp split:splitLongTask];
						
					}
						break;
						
					default:
						goto exitWhile;
						break;
						
				}
				
				if ([tmp compare:whileDate]==NSOrderedDescending)
				{
					break;
				}
			}
		exitWhile:	
			if(task.taskNumberInstances>0 && [previousInstance.taskEndTime isEqualToDate: task.isAllDayEvent?[task.taskEndRepeatDate dateByAddingTimeInterval:86400]:task.taskEndRepeatDate]){
				isLastInstanceInSeries=YES;
			} 
			
			if(previousInstance !=nil && ((!isLastInstanceInSeries && previousInstance.primaryKey < -1) 
										  || ([previousInstance isEqual:task] && task.taskNumberInstances !=1))){
				previousInstance.isOneMoreInstance=YES;
			}else {
				previousInstance.isOneMoreInstance=NO;
			}
			
			
			isLastInstanceInSeries=NO;
			if(repeatOn !=nil){
				[repeatOn release];
				repeatOn=nil;
			}
			
			//clean RE exception instances
			[self cleanExceptionInstanceInMainSeries:task inList:retList];
		}
	}
	
	[gregorian release];
	
	//[ivoUtility printTask:retList];
	NSSortDescriptor *date_descriptor = [[NSSortDescriptor alloc] initWithKey:@"taskStartTime"  ascending: YES];
	
	NSArray *sortDescriptors = [NSArray arrayWithObject:date_descriptor];
	
	[retList sortUsingDescriptors:sortDescriptors];	
	
	return retList;
}
*/

/*not used in this release*/
-(NSMutableArray *)getTaskListFromTheOrder:(NSInteger)fromTheOrder toTheOrder:(NSInteger)toTheOrder{
	NSMutableArray *list;
	if (self.filterClause == nil || [self.filterClause isEqual:@""])
	{
		NSMutableArray *partList=[App_Delegate createTaskListFromTheOrder:fromTheOrder toTheOrder:toTheOrder];
		NSDate *getRepeatInstancesUntil=[self lastTaskEndDateInList:list];
		[self fillRepeatEventInstances:partList toList:list fromDate:[NSDate date] getInstanceUntilDate:[getRepeatInstancesUntil dateByAddingTimeInterval:2*86400] isShowPastInstances:NO isCleanOldDummies:YES isRememberFilledDate:NO  isNeedAtLeastOneInstance:NO];
	}else {
		[App_Delegate getFilterTaskList:self.filterClause fromList:self.taskList];
		list = self.filterList;
	}
	[self sortList:list byKey:@"taskStartTime"];

	return list;
}

-(NSMutableArray *)getTaskListFromDate:(NSDate *)fromDate 
								toDate:(NSDate *)toDate 
						 splitLongTask:(BOOL) splitLongTask 
					  isUpdateTaskList:(BOOL)isUpdateTaskList 
							isSplitADE:(BOOL)isSplitADE
{
	
	NSDate *today=[NSDate date];
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit|NSSecondCalendarUnit;
	
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:today];	
	[comps setSecond:0];
	[comps setMinute:0];
	[comps setHour:0];
	
	today=[gregorian dateFromComponents:comps];
	NSDate *fromDt=fromDate;
	NSDate *toDt=toDate;
	if(fromDate && toDate){
		comps = [gregorian components:unitFlags fromDate:fromDate];	
		[comps setSecond:0];
		[comps setMinute:0];
		[comps setHour:0];
		fromDt=[gregorian dateFromComponents:comps];
		
		comps = [gregorian components:unitFlags fromDate:toDate];	
		[comps setSecond:0];
		[comps setMinute:0];
		[comps setHour:24];
		toDt=[gregorian dateFromComponents:comps];
	}

	NSDate *startDate=fromDt;
	if(!startDate)
		startDate=today;
	
	NSMutableArray *list;
	NSMutableArray *reArr=[NSMutableArray array];
	NSMutableArray *listTmp=[NSMutableArray array];
	
	NSMutableArray *arrTask=[NSMutableArray arrayWithArray:self.taskList];
	for(Task *task in arrTask){
		if(task.primaryKey<-1){
			[self.taskList removeObject:task];
		}else {
			if(task.taskPinned==1 && task.taskRepeatID>0){
				[reArr addObject:task];
				if(splitLongTask){
					[self addTaskInToList:task toList:listTmp fromDate:fromDt toDate:toDt isSplitLongTask:isSplitADE];
				}else {
					[listTmp addObject:task];
				}

			}else {
				if(splitLongTask){
					[self addTaskInToList:task toList:listTmp fromDate:fromDt toDate:toDt isSplitLongTask:isSplitADE];
				}else {
					if((task.taskPinned==1 && [task.taskEndTime compare:startDate]!=NSOrderedAscending) || task.taskPinned==0)
						[listTmp addObject:task];
				}

			}
		}
	}
	
	if(!splitLongTask){
	}else {
		//listTmp=[self createInspectDisplaylist:listTmp isSplit:isSplitADE fromDate:fromDt toDate:toDt];
	}
	
	list=listTmp;
	
	NSMutableArray *dummies=[[NSMutableArray alloc] init];

	if(fromDate && toDate){
		if(!splitLongTask){
			[self fillRepeatEventInstances:reArr 
									toList:dummies 
								  fromDate:fromDt 
					  getInstanceUntilDate:toDt 
					   isShowPastInstances:YES 
						 isCleanOldDummies:YES 
					  isRememberFilledDate:NO
				  isNeedAtLeastOneInstance:NO];
			
			//[list addObjectsFromArray:dummies];
			for (Task *task in dummies){
				[self addTaskInToList:task toList:list fromDate:fromDt toDate:toDt isSplitLongTask:isSplitADE];
			}
			
			if(isUpdateTaskList){
				DateAndList *dl=[[DateAndList alloc] init];
				dl.array=dummies;
				dl.date=fromDt;
				dl.isKeepRecentList=YES;
				[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(updateTaskListWithDateAndDummies:) userInfo:dl repeats:NO];
			}
		}else {
			
			[self fillRepeatEventInstances:reArr 
									toList:dummies 
								  fromDate:fromDt 
					  getInstanceUntilDate:toDt 
					   isShowPastInstances:YES 
						 isCleanOldDummies:NO 
					  isRememberFilledDate:NO
				  isNeedAtLeastOneInstance:NO];

//			NSMutableArray *inspectedList;
//			inspectedList=[self createInspectDisplaylist:dummies isSplit:isSplitADE fromDate:fromDt toDate:toDt];
//			[list addObjectsFromArray:inspectedList];

			for (Task *task in dummies){
				[self addTaskInToList:task toList:list fromDate:fromDt toDate:toDt isSplitLongTask:isSplitADE];
			}
			
			if(isUpdateTaskList){
				DateAndList *dl=[[DateAndList alloc] init];
				dl.date=fromDt;
				//dl.array=inspectedList;
				dl.array=dummies;
				dl.isKeepRecentList=YES;
				[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(updateTaskListWithDateAndDummies:) userInfo:dl repeats:NO];
			}	
			
//			[inspectedList release];
		}
		
	}else {
		
		[recentDummiesList removeAllObjects];
		
		//NSDate *getRepeatInstancesUntil=[self lastTaskEndDateInList:list];
		[self fillRepeatEventInstances:reArr 
								toList:dummies 
							  fromDate:today 
				  //getInstanceUntilDate:[getRepeatInstancesUntil dateByAddingTimeInterval:2*86400] 
				  getInstanceUntilDate:[today dateByAddingTimeInterval:3*86400] 
				   isShowPastInstances:NO 
					 isCleanOldDummies:YES 
				  isRememberFilledDate:NO
			  isNeedAtLeastOneInstance:YES];
		
		[list addObjectsFromArray:dummies];
		
		if(isUpdateTaskList){
			DateAndList *dl=[[DateAndList alloc] init];
			dl.array=dummies;
			dl.date=nil;
			dl.isKeepRecentList=NO;
			[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(updateTaskListWithDateAndDummies:) userInfo:dl repeats:NO];
		}
	}
	 
	[dummies release];
	
	//[self sortList:self.taskList byKey:@"taskStartTime"];
	[self sortList:list byKey:@"taskStartTime"];

	if (self.filterClause == nil || [self.filterClause isEqual:@""])
	{

	}
	else
	{
		[App_Delegate getFilterTaskList:self.filterClause fromList:list];
		list = self.filterList;
	}

	[gregorian release];
	//[ivoUtility printTask:list];
	
	return list;
}

-(void)updateTaskListWithDateAndDummies:(id)sender{
	
	NSTimer *timer=sender;
	DateAndList *dl=[timer userInfo];
	
//	NSMutableArray *array=[NSMutableArray arrayWithArray:self.taskList];
//	for(Task *task in array){
//		if(task.primaryKey<-1)
//			[self.taskList removeObject:task];
//	}
//	[self refreshTaskListFromPartList];
	
	NSMutableArray *newDummies=[NSMutableArray arrayWithArray:dl.array];
	
	for(Task *newDummy in newDummies){
		//for (Task *oldDummy in recentDummiesList){
        NSMutableArray *dummiesSourceList=[NSMutableArray arrayWithArray:self.recentDummiesList];
        for(Task *oldDummy in dummiesSourceList){
			if([newDummy.taskStartTime compare:oldDummy.taskStartTime]==NSOrderedSame && newDummy.parentRepeatInstance==oldDummy.parentRepeatInstance && 
				([oldDummy.taskStartTime compare:[dl.date dateByAddingTimeInterval:-3*86400]]==NSOrderedAscending || [oldDummy.taskStartTime compare:[dl.date dateByAddingTimeInterval:3*86400]]==NSOrderedDescending)){				
				//[newDummies removeObject:oldDummy];
				oldDummy.primaryKey=newDummy.primaryKey;
				[dl.array removeObject:newDummy];
			}
		}
	}
	
	[self.taskList addObjectsFromArray:recentDummiesList];
	[self.taskList addObjectsFromArray:dl.array];
	
	if(dl.date){
		NSMutableArray *arrTmp=[NSMutableArray arrayWithArray:recentDummiesList];
		for (Task *task in arrTmp) {
			if([task.taskStartTime compare:[dl.date dateByAddingTimeInterval:-3*86400]]==NSOrderedAscending || [task.taskStartTime compare:[dl.date dateByAddingTimeInterval:3*86400]]==NSOrderedDescending){
				[recentDummiesList removeObject:task];
			}
		}
	}else {
		[recentDummiesList removeAllObjects];
	}

	if(dl.isKeepRecentList){
		[recentDummiesList addObjectsFromArray:dl.array];
	}
	
	//[self sortList:self.taskList byKey:@"taskStartTime"];
	
	[dl release];
	
	//[ivoUtility printTask:self.taskList];
 
}

-(void)addTaskInToList:(Task*)task toList:(NSMutableArray *)toList fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate isSplitLongTask:(BOOL)isSplitLongTask{
	Task *tmp=nil;
	
	if(fromDate && toDate){
//			if([task.taskEndTime compare:fromDate]==NSOrderedAscending) return;
			
			if(([task.taskStartTime compare:fromDate] !=NSOrderedAscending && [task.taskStartTime compare:toDate]!=NSOrderedDescending) 
			   
			   || ([task.taskEndTime compare:fromDate]!=NSOrderedAscending && [task.taskEndTime compare:toDate]!=NSOrderedDescending)
			   
			   || ([task.taskStartTime compare:fromDate] != NSOrderedDescending &&[task.taskEndTime compare:toDate]!=NSOrderedAscending)){
				
				//[toList addObject:task];
				tmp=task;
			}
			
//			if([task.taskStartTime compare:toDate]==NSOrderedDescending) return;
	}else{
		//[toList addObject:task];		
		tmp=task;
	}
	
	if(!tmp) return;

	[self createInspectDisplayForTask:tmp inList:toList isSplit:isSplitLongTask fromDate:fromDate toDate:toDate];

}


-(NSMutableArray *)getSubTaskListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate {
	NSMutableArray *ret=[NSMutableArray array];
    NSMutableArray *sourceList=[NSMutableArray arrayWithArray:self.taskList];

	if(fromDate && toDate){
		for(Task *task in sourceList){
			if([task.taskEndTime compare:fromDate]==NSOrderedAscending) continue;

				if(([task.taskStartTime compare:fromDate] !=NSOrderedAscending && [task.taskStartTime compare:toDate]!=NSOrderedDescending) 
		  
									   || ([task.taskEndTime compare:fromDate]!=NSOrderedAscending && [task.taskEndTime compare:toDate]!=NSOrderedDescending)
			   
									   || ([task.taskStartTime compare:fromDate] != NSOrderedDescending &&[task.taskEndTime compare:toDate]!=NSOrderedAscending)){
				
					[ret addObject:task];
				}
			
			if([task.taskStartTime compare:toDate]==NSOrderedDescending) break;
		}
	}else{
		[ret addObjectsFromArray: sourceList];		
	}
	return ret;
}

-(NSMutableArray *)getREListFromTaskList:(NSMutableArray *)list{
	NSMutableArray *ret=[NSMutableArray array];
	NSMutableArray *sourceList=[NSMutableArray arrayWithArray:list];
    
	for(Task *task in sourceList){
		if(task.primaryKey>0 && task.taskPinned==1 && task.taskRepeatID>0){
			[ret addObject:task];
		}
	}
	
	return ret;
}

-(NSMutableArray *)createListExceptionInstancesOfRE:(Task*)taskRE inList:(NSMutableArray *)list{
	NSMutableArray *exceptionInstanceList=[[NSMutableArray alloc] init];
    
    NSMutableArray *sourceList=[NSMutableArray arrayWithArray:list];

	for(Task *tmp in sourceList){
		if(tmp.taskPinned==1 && tmp.parentRepeatInstance==taskRE.primaryKey && tmp.primaryKey > -2){
			Task *task=[[Task alloc] init];
			[ivoUtility copyTask:tmp toTask:task isIncludedPrimaryKey:YES];
			[exceptionInstanceList addObject:task];
			[task release];
		}
	}
	return exceptionInstanceList;
}

-(void)cleanExceptionInstanceInMainSeries:(Task*)task inList:(NSMutableArray *)list{
	if(task.taskRepeatExceptions !=nil && ![task.taskRepeatExceptions isEqualToString:@""]){
		NSArray *exceptionValues=[task.taskRepeatExceptions componentsSeparatedByString:@"|"];
		for(NSInteger i=1;i<exceptionValues.count;i++){
			NSDate *tmpExpDate=[NSDate dateWithTimeIntervalSince1970: [(NSString *)[exceptionValues objectAtIndex:i] doubleValue]];
			NSMutableArray *tmpNewList=[NSMutableArray arrayWithArray:list];

			Task *previousInstance=task;
			for (Task *instanceRE in tmpNewList){
				if(instanceRE.primaryKey<-1 && instanceRE.parentRepeatInstance==task.primaryKey){   
//				   if( [ivoUtility getYear:instanceRE.taskStartTime]==[ivoUtility getYear:tmpExpDate]
//				   && [ivoUtility getMonth:instanceRE.taskStartTime]==[ivoUtility getMonth:tmpExpDate]
//				   && [ivoUtility getDay:instanceRE.taskStartTime]==[ivoUtility getDay:tmpExpDate]){
					if( [[ivoUtility getStringFromShortDate:instanceRE.taskStartTime] isEqualToString: [ivoUtility getStringFromShortDate:tmpExpDate]]){
						
					   //if the instance have the sign "+", re-assign it to the previous instances
					   if(instanceRE.isOneMoreInstance && previousInstance !=nil){
						   previousInstance.isOneMoreInstance=YES;
					   }
					   [list removeObject:instanceRE];
				   }else {
					   previousInstance=instanceRE;
				   }

				}
			}
			//[tmpNewList release];
		}
	}
}

-(Task *)addInstanceIntoList:(Task *)task toList:(NSMutableArray *)list instanceKey:(NSInteger)instanceKeyp forDate:(NSDate *)date{
	Task *tmpTask=[[Task alloc] init];
	[ivoUtility copyTask:task toTask:tmpTask isIncludedPrimaryKey:NO];
	tmpTask.primaryKey=instanceKeyp;
	//instanceKey=instanceKey-1;
	tmpTask.taskStartTime=date;
	//tmpTask.taskSynKey=0;
	tmpTask.isOneMoreInstance=NO;
	tmpTask.parentRepeatInstance=task.primaryKey;
	tmpTask.taskEndTime=[tmpTask.taskStartTime dateByAddingTimeInterval:tmpTask.taskHowLong];
	
    NSMutableArray *sourceList=[NSMutableArray arrayWithArray:list];

	if([ivo_Utilities offsetForDate:tmpTask.taskStartTime] !=[ivo_Utilities offsetForDate:tmpTask.taskEndTime]){
		if([App_defaultTimeZone isDaylightSavingTimeForDate:tmpTask.taskStartTime] && ![App_defaultTimeZone isDaylightSavingTimeForDate:tmpTask.taskEndTime]){
			tmpTask.taskEndTime= [tmpTask.taskEndTime dateByAddingTimeInterval:dstOffset];
		}else if(![App_defaultTimeZone isDaylightSavingTimeForDate:tmpTask.taskStartTime] && [App_defaultTimeZone isDaylightSavingTimeForDate:tmpTask.taskEndTime]){
			tmpTask.taskEndTime= [tmpTask.taskEndTime dateByAddingTimeInterval:-dstOffset];
		}
	}
	
//	NSInteger index4Instance=[ivoUtility getTimeSlotIndexForTask:tmpTask inArray:list];
//	[list insertObject:tmpTask atIndex:index4Instance];
	[list addObject:tmpTask];
	[tmpTask release];
	
//	return [list objectAtIndex:index4Instance];
    if (list.count>0) {
	return [list objectAtIndex:list.count-1];
    }
    
    return nil;
}

-(Task *)addInstanceIntoExtraList:(Task *)task toList:(NSMutableArray *)list instanceKey:(NSInteger)instanceKeyp forDate:(NSDate *)date{
	Task *tmpTask=[[Task alloc] init];
	[ivoUtility copyTask:task toTask:tmpTask isIncludedPrimaryKey:NO];
	tmpTask.primaryKey=instanceKeyp;
	//instanceKey=instanceKey-1;
	tmpTask.taskStartTime=date;
	tmpTask.isOneMoreInstance=NO;
	tmpTask.parentRepeatInstance=task.primaryKey;
	tmpTask.taskEndTime=[tmpTask.taskStartTime dateByAddingTimeInterval:tmpTask.taskHowLong];
	//NSInteger index4Instance=[ivoUtility getTimeSlotIndexForTask:tmpTask inArray:list];
	//[list insertObject:tmpTask atIndex:index4Instance];
	[list addObject:tmpTask];
	[tmpTask release];
	
	if (list.count>0) {
        return [list objectAtIndex:list.count-1];
    }
    
    return nil;
}

/*
-(void)updateExceptionIntoRE:(Task *)REExpInstance inList:(NSMutableArray *)list originalStartDate:(NSDate *)date action:(NSInteger)action{
	
	//if task.parentRepeaInstance > 0, action=0(insert) -> create the exception, update task info including task.primaryKey
	//if task.parentRepeatInstance > 0, action=1(delete) -> delete the exception
	switch (action) {
		case 0://insert
			
			//find the instance in the main series to make the change
			for(Task *tmp in list){
				if([tmp.taskStartTime isEqualToDate:date] && ((tmp.primaryKey<-1 && tmp.parentRepeatInstance==REExpInstance.parentRepeatInstance) ||
															  tmp.primaryKey==REExpInstance.parentRepeatInstance)){
					REExpInstance.primaryKey=tmp.primaryKey;
					REExpInstance.taskRepeatID=tmp.taskRepeatID;
					REExpInstance.taskRepeatOptions=tmp.taskRepeatOptions;
		
					taskCheckResult result=[self updateTask:REExpInstance isAllowChangeDueWhenUpdate:YES updateREType:1 REUntilDate:REExpInstance.taskEndTime];
					
					if (result.errorNo == -1)
					{
						REExpInstance.primaryKey = result.taskPrimaryKey;
					}
					break;
				}
			}
			
			break;
		case 1://delete
			//search mainInstance to update exception
			for(Task *task in list){
				if(task.primaryKey==REExpInstance.parentRepeatInstance){
					task.taskRepeatExceptions=[task.taskRepeatExceptions stringByAppendingFormat:@"|%f",[date timeIntervalSince1970]];
					break;
				}
			}
			break;
	}
}
*/

-(void)updateExceptionIntoRE:(Task *)REExpInstance inList:(NSMutableArray *)inList originalStartDate:(NSDate *)date action:(NSInteger)action{
	//printf("\nupdateExceptionToRE From GCal--begin");
	//if task.parentRepeaInstance > 0, action=0(insert) -> create the exception, update task info including task.primaryKey
	//if task.parentRepeatInstance > 0, action=1(delete) -> delete the exception
	NSMutableArray *list=[NSMutableArray arrayWithArray:inList];
	switch (action) {
		case 0://insert
		{

			if(REExpInstance.parentRepeatInstance==999999){
		insertException:
				{
					TaskActionResult *result=[self addNewTask:REExpInstance toArray:self.taskList isAllowChangeDueWhenAdd:YES];
				
					if (result.errorNo == -1)
					{
						//update new gCalEventID for new exception instance
						Task *newException=[ivoUtility getTaskByPrimaryKey:result.taskPrimaryKey inArray:taskList];
						newException.gcalEventId=REExpInstance.gcalEventId;
						[newException update];
						
						REExpInstance.primaryKey = result.taskPrimaryKey;
					}
					
					[result release];
				}
			}else {
				//find the instance in the main series to make the change
				NSString *originalDateStr=[ivoUtility createStringFromDate:date isIncludedTime:YES];
				BOOL isDummyFound=NO;
				BOOL isExceptionFound=NO;
				
				self.REList=[self getREListFromTaskList:list];
				[self fillRepeatEventInstances:self.REList toList:list fromDate:[NSDate date]
						  getInstanceUntilDate:[date dateByAddingTimeInterval:86400] isShowPastInstances:YES isCleanOldDummies:YES isRememberFilledDate:NO isNeedAtLeastOneInstance:NO];
				[self sortList:list byKey:@"taskStartTime"];
				
			//searchDummyForUodate:
				for(Task *tmp in list){
					NSString *eventStartTimeStr=[ivoUtility createStringFromDate:tmp.taskStartTime isIncludedTime:YES];
					if([eventStartTimeStr isEqualToString:originalDateStr] && ((tmp.primaryKey<-1 && tmp.parentRepeatInstance==REExpInstance.parentRepeatInstance)||
																			   tmp.primaryKey==REExpInstance.parentRepeatInstance)){
						
						isDummyFound=YES;
						isExceptionFound=YES;
						
						REExpInstance.primaryKey=tmp.primaryKey;
						REExpInstance.taskRepeatID=tmp.taskRepeatID;
						REExpInstance.taskRepeatOptions=tmp.taskRepeatOptions;
						
						TaskActionResult *result=[self updateTask:REExpInstance isAllowChangeDueWhenUpdate:YES updateREType:1 REUntilDate:REExpInstance.taskEndTime updateTime:nil];
						
						if (result.errorNo == -1)
						{
							//update new gCalEventID for new exception instance
							Task *newException=[ivoUtility getTaskByPrimaryKey:result.taskPrimaryKey inArray:taskList];
							newException.gcalEventId=REExpInstance.gcalEventId;
							[newException update];
							
							REExpInstance.primaryKey = result.taskPrimaryKey;
						}
						
						[result release];
						break;
					}
					[eventStartTimeStr release];
				}
				
				if(!isDummyFound){
					//[self fillRepeatEventInstances:list 
					//		  getInstanceUntilDate:date isShowPastInstances:NO];
					
					//goto searchDummyForUodate;
					
					//search for any exception on that day
					for(Task *tmp in list){
						NSString *eventStartTimeStr=[ivoUtility createStringFromDate:tmp.taskStartTime isIncludedTime:YES];
						if(tmp.primaryKey>-1 && tmp.parentRepeatInstance==REExpInstance.parentRepeatInstance && [eventStartTimeStr isEqualToString:originalDateStr]){
							isExceptionFound=YES;
							REExpInstance.primaryKey=tmp.primaryKey;
							[self updateTask:REExpInstance isAllowChangeDueWhenUpdate:YES updateREType:1  REUntilDate:REExpInstance.taskEndTime updateTime:nil];
						}
						[eventStartTimeStr release];
					}
				}
				
				if(!isExceptionFound){
					[originalDateStr release];
					goto insertException;
				}
				
				[originalDateStr release];
			}
			
		}
			break;
		case 1://delete
			//search mainInstance to update exception
			for(Task *task in list){
				if(task.primaryKey==REExpInstance.parentRepeatInstance){
					//trung ST3.2
					//task.taskRepeatExceptions=[task.taskRepeatExceptions stringByAppendingFormat:@"|%f",[date timeIntervalSince1970]];
					NSString *dt = [NSString stringWithFormat:@"|%f",[date timeIntervalSince1970]];
					
					NSRange range = [task.taskRepeatExceptions rangeOfString:dt];
					
					if (range.location == NSNotFound)
					{
						task.taskRepeatExceptions=[task.taskRepeatExceptions stringByAppendingString:dt];
					}
					
					break;
				}
			}
			break;
	}
	//printf("\nupdateExceptionToRE From GCal--end");
	//[App_Delegate getPartTaskList];
}

#pragma mark Local Notification

-(void)snoozeAlertForTask:(Task*)task{
	UIApplication* app = [UIApplication sharedApplication];
	NSMutableArray	*oldNotifications = (NSMutableArray	*)[app scheduledLocalNotifications];
	
	NSMutableArray *locNotif=[NSMutableArray arrayWithArray:oldNotifications];
	for (UILocalNotification *notif in locNotif) {
		NSDictionary *dict=[notif userInfo];
		
        if ([[dict objectForKey:@"taskId"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)task.primaryKey]]) {
			[app cancelLocalNotification:notif];
			[oldNotifications removeObject:notif];
			break;
		}
	}
    
	if (task.taskCompleted==1) return;
	
	UILocalNotification* alarm = [[UILocalNotification alloc] init];
	if (alarm) {
        NSInteger unit=self.currentSetting.snoozeUnit;
        NSTimeInterval snoozeDuration=self.currentSetting.snoozeDuration*(unit==0?60:unit==1?3600:unit==2?86400:7*86400);
        
		alarm.fireDate = [ivoUtility newDateFromDate:[NSDate date] offset:snoozeDuration]; 
		alarm.timeZone = [NSTimeZone defaultTimeZone]; 
		alarm.repeatInterval = 0; 
		alarm.soundName = @"alarmsound.caf"; 
		alarm.alertBody = task.taskName;
		
        NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)task.primaryKey],@"taskId",nil];
		alarm.userInfo = infoDict;
		[app scheduleLocalNotification:alarm];
	}
    
	[alarm release];
}


//-(void)refreshLocalNotificationForList:(NSMutableArray*)list{	
//}

-(void)updateLocalNotificationForList:(NSMutableArray*)list{
    UIApplication* app = [UIApplication sharedApplication];
	NSMutableArray	*oldNotifications = (NSMutableArray	*)[app scheduledLocalNotifications];
	NSMutableArray *sourceList=[NSMutableArray arrayWithArray:list];
    
	for (Task *task in sourceList) {
		
		NSMutableArray *locNotif=[NSMutableArray arrayWithArray:oldNotifications];
		BOOL mayBeSnooze=NO;
		UILocalNotification *mayBeSnoozeNotif;
		
		for (UILocalNotification *notif in locNotif) {
			NSDictionary *dict=[notif userInfo];
			
            if ([[dict objectForKey:@"taskId"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)task.primaryKey]]) {
				if ([notif.fireDate compare:[NSDate date]]==NSOrderedDescending) {
					//no need to update an active notification
					mayBeSnooze=YES;
					mayBeSnoozeNotif=notif;
					break;
				}else {
					//will check to re-active notification if any, but first cancel it
					[app cancelLocalNotification:notif];
					[oldNotifications removeObject:notif];
					break;
				}
			}
		}
		
		if (task.taskCompleted==1) continue;
		
		NSDate *eventTime=nil;
		NSDate *alertTime=nil;
		if(task.primaryKey>0 && task.hasAlert){
			if (task.taskPinned==1) {
				if ([task.taskStartTime compare:[NSDate date]]==NSOrderedAscending) {
					continue;
				}else {
					eventTime=task.taskStartTime;
				}
				
			}else {
				//task
					if (task.taskIsUseDeadLine==1 && task.alertBasedOn==1) {//based on due
						if ([task.taskDeadLine compare:[NSDate date]]==NSOrderedAscending) {
							continue;
						}else {
							eventTime=task.taskDeadLine;
						}
					}else {
						if ([task.taskNotEalierThan compare:[NSDate date]]==NSOrderedAscending) {
							continue;
						}else {
							eventTime=task.taskNotEalierThan;
						}
					}
			}
			
			if (mayBeSnooze) {
				[app cancelLocalNotification:mayBeSnoozeNotif];
				[oldNotifications removeObject:mayBeSnoozeNotif];
			}
            
            /*
			if (task.popUpAlertIndex==1) {
				alertTime=eventTime;
			}else if (task.popUpAlertIndex==2) {
				alertTime=[Utilities newDateFromDate:eventTime offset:-5*60];
			}else if (task.popUpAlertIndex==3) {
				alertTime=[Utilities newDateFromDate:eventTime offset:-10*60];
			}else if (task.popUpAlertIndex==4) {
				alertTime=[Utilities newDateFromDate:eventTime offset:-15*60];
			}else if (task.popUpAlertIndex==5) {
				alertTime=[Utilities newDateFromDate:eventTime offset:-30*60];
			}else if (task.popUpAlertIndex==6) {
				alertTime=[Utilities newDateFromDate:eventTime offset:-45*60];
			}else if (task.popUpAlertIndex==7) {
				alertTime=[Utilities newDateFromDate:eventTime offset:-60*60];
			}else if (task.popUpAlertIndex==8) {
				alertTime=[Utilities newDateFromDate:eventTime offset:-120*60];
			}else if (task.popUpAlertIndex==9) {
				alertTime=[Utilities newDateFromDate:eventTime offset:-86400];
			}else if (task.popUpAlertIndex==10) {
				alertTime=[Utilities newDateFromDate:eventTime offset:-2*86400];
			}else if (task.popUpAlertIndex==11) {
				alertTime=[Utilities newDateFromDate:eventTime offset:-7*86400];
			}else if (task.popUpAlertIndex==12) {
				alertTime=[Utilities newDateFromDate:eventTime offset:-14*86400];
			}else{
				alertTime=nil;
			}
			*/
            
           // Alert *alert=[task getAlertInfo];
            
            alertTime=[ivoUtility newDateFromDate:eventTime offset:-([[alertList objectAtIndex:task.alertIndex] intValue] * (task.alertUnit==0?60:task.alertUnit==1?3600:task.alertUnit==2?86400:7*86400))];
			//add alarm to system
            
			if ([alertTime compare:[NSDate date]]==NSOrderedDescending) {
				UILocalNotification* alarm = [[UILocalNotification alloc] init];
				if (alarm) {
					alarm.fireDate = alertTime; 
					alarm.timeZone = [NSTimeZone defaultTimeZone]; 
					alarm.repeatInterval = 0; 
					alarm.soundName = @"alarmsound.caf"; 
					alarm.alertBody = task.taskName;
					
                    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)task.primaryKey],@"taskId",nil];
					alarm.userInfo = infoDict;
					[app scheduleLocalNotification:alarm];
				}
				[alarm release];
			}
            
		}
		
	next:{}
		
	}
	
	//cancel all remaining
	for (UILocalNotification *notf in oldNotifications) {
		[app cancelLocalNotification:notf];
	}
    
    /*
	UIApplication* app = [UIApplication sharedApplication];
	NSArray	*oldNotifications = [app scheduledLocalNotifications];
	
	// Clear out the old notification before scheduling a new one. 
	if ([oldNotifications count] > 0)
		[app cancelAllLocalNotifications];
	
	for (Task *task in list) {
		// Create a new notification 
		
		NSDate *eventTime;
		NSDate *alertTime;
		if([task.taskAlertValues length]>0 && task.primaryKey>0){
			if (task.taskPinned==1) {
				//event
				if ([task.taskStartTime compare:[NSDate date]]==NSOrderedAscending) {
					continue;
				}else {
					eventTime=task.taskStartTime;
				}
				
			}else {
				//task
				if (task.isAdjustedSpecifiedDate==1) {
					if ([task.specifiedAlertTime compare:[NSDate date]]==NSOrderedAscending) {
						continue;
					}else {
						eventTime=task.specifiedAlertTime;
					}
				}else {
					if (task.taskIsUseDeadLine==1) {
						if ([task.taskDeadLine compare:[NSDate date]]==NSOrderedAscending) {
							continue;
						}else {
							eventTime=task.taskDeadLine;
						}
					}else {
						//no reason to fail to this case!
						eventTime=task.specifiedAlertTime;
					}
				}
			}
			
			NSArray *alertList=[task.taskAlertValues componentsSeparatedByString:@"/"];
			if(alertList.count>0){
				for(NSInteger i=1; i<alertList.count;i++){
					NSArray *alertValArr=[(NSString *)[alertList objectAtIndex:i] componentsSeparatedByString:@"|"];
					if([[alertValArr objectAtIndex:1] intValue]==3){
						NSInteger duration=[[alertValArr objectAtIndex:0] intValue];
						//printf("\n %d",[[alertValArr objectAtIndex:2] intValue]);
						switch ([[alertValArr objectAtIndex:2] intValue]) {
							case 0://minute
								alertTime=[ivoUtility addTimeInterval:-duration*60 :eventTime];
								break;
							case 1://hour
								alertTime=[ivoUtility addTimeInterval:-duration*3600 :eventTime];
								break;
							case 2://day
								alertTime=[ivoUtility addTimeInterval:-duration*86400 :eventTime];
								break;
							case 3://week
								break;
								alertTime=[ivoUtility addTimeInterval:-7*duration*86400 :eventTime];
						}
						
						//get snooze duration here
						
						//add alarm to system
						if ([alertTime compare:[NSDate date]]==NSOrderedDescending) {
							UILocalNotification* alarm = [[[UILocalNotification alloc] init] autorelease];
							if (alarm) {
								alarm.fireDate = alertTime; 
								alarm.timeZone = [NSTimeZone defaultTimeZone]; 
								alarm.repeatInterval = 0; 
								alarm.soundName = @"alarmsound.caf"; 
								alarm.alertBody = task.taskName;
								
								//NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",task.primaryKey],@"primaryKey",
								//						  [NSString stringWithFormat:@"/@",[alertList objectAtIndex:i]],@"SnoozeTime",nil];
								//alarm.userInfo = infoDict;
								
								[app scheduleLocalNotification:alarm];
							}
						}
					}
				}
			}
		}
	}
     */
    
}

#pragma mark common methods
/*
-(BOOL)isNotFitTask:(NSDate*)taskStartTime lastREInstanceDate:(NSDate*)date inList:(NSMutableArray *)list{
	BOOL ret=NO;
	if([taskStartTime compare:date]!=NSOrderedAscending){
		for (Task *tmp in list){
			if(tmp.taskPinned==1 && tmp.taskRepeatID>0 && tmp.taskRepeatTimes==0 
			   && ([ivoUtility getHour:tmp.taskStartTime]*60+[ivoUtility getMinute:tmp.taskStartTime])>= 
			   ([ivoUtility getHour:taskStartTime]*60+[ivoUtility getMinute:taskStartTime])){
				ret=YES;
				break;
			}
		}
	}
	
	return ret;
}
*/

-(BOOL)addCalendarToCalendarList:(Projects *)cal{
    NSMutableArray *projects=[NSMutableArray arrayWithArray:projectList];
	for(Projects *calendar in projects){
		if([[[calendar.projName stringByReplacingOccurrencesOfString:@" " withString:@""] uppercaseString] isEqualToString:[[cal.projName stringByReplacingOccurrencesOfString:@" " withString:@""] uppercaseString]]){
			return NO;
		}
	}
	
	[cal prepareNewRecordIntoDatabase:database];
	[cal update];
	[projectList addObject:cal];
	
	return YES;
}


//this function used for dummy list want to update it keys to another list,
//both two list must have the order before use this function and the another list
//must contains the dummy list
-(BOOL)updateDummiesKeyFromList:(NSMutableArray *)fromList toList:(NSMutableArray *)toList{
	NSInteger i=0;
	NSInteger j=0;
	BOOL ret=NO;
	if(fromList.count==0 || toList.count==0) return ret;
	
    NSMutableArray *sourceListFrom=[NSMutableArray arrayWithArray:fromList];
    NSMutableArray *sourceListTo=[NSMutableArray arrayWithArray:toList];
    
	for(i;i<sourceListFrom.count;i++){
		Task *dummy=[sourceListFrom objectAtIndex:i];

		for(j;j<sourceListTo.count;j++){
			Task *task=[sourceListFrom objectAtIndex:j];
			if(task.primaryKey<0 && task.parentRepeatInstance==dummy.parentRepeatInstance && [task.taskStartTime compare:dummy.taskStartTime]==NSOrderedSame){
				//task.primaryKey=dummy.primaryKey;
                [toList removeObject:task];
                [toList addObject:dummy];
				ret=YES;
				j++;
				break;
			}
		}
	}
	
	return ret;
}

-(void)refreshTaskListFromPartList{
	NSMutableArray *array=[NSMutableArray arrayWithArray:self.normalTaskList];
	[array addObjectsFromArray:self.dTaskList];
	[array addObjectsFromArray:self.eventList];
	[array addObjectsFromArray:self.REList];
	[array addObjectsFromArray:self.adeList];
	self.taskList=array;
}

//-(BOOL)isNotFitTask:(NSDate*)taskStartTime lastREInstanceDate:(NSDate*)date inList:(NSMutableArray *)list{


//We just check if the task can not be fit into schedule because its duration length is over 
//its context time range and this should be called before finding time slot for the task
-(BOOL)isNotFitTask:(Task *)task{
	double contextNDRangeDuration=0;
	double contextWKRangeDuration=0;
		
	if(task.taskWhere==0){//home
		contextNDRangeDuration=[self.currentSetting.homeTimeNDEnd timeIntervalSinceDate:self.currentSetting.homeTimeNDStart];
		contextWKRangeDuration=[self.currentSetting.homeTimeWEEnd timeIntervalSinceDate:self.currentSetting.homeTimeWEStart];
	}else {//work
		contextNDRangeDuration=[self.currentSetting.homeTimeNDEnd timeIntervalSinceDate:self.currentSetting.homeTimeNDStart];
		contextWKRangeDuration=[self.currentSetting.homeTimeWEEnd timeIntervalSinceDate:self.currentSetting.homeTimeWEStart];
	}

	if(task.taskHowLong>contextNDRangeDuration && task.taskHowLong>contextWKRangeDuration) {
		return YES;
	}
	
	return NO;
}

-(void)createDummiesForREFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate{
	
}

-(Task*)getParentRE:(Task *)instance inList:(NSMutableArray *)list{
    NSMutableArray *sourceList=[NSMutableArray arrayWithArray:list];
    
	for(Task *tmp in sourceList){
		if (tmp.primaryKey==instance.parentRepeatInstance || 
			(![tmp isEqual:instance] && tmp.primaryKey==instance.primaryKey && tmp.primaryKey > -2) || 
			instance.primaryKey==-1 || 
			tmp.primaryKey==-1 ){
			
			if(instance.primaryKey==-1){//return itself
				 //[ivoUtility inspectPinnedTaskDate: instance];
				return instance;
			}
			return tmp;
			break;
		}
	}
	return nil;
}

- (NSDate *)lastTaskEndDateInList:(NSMutableArray *)list{
		
    NSMutableArray *sourceList=[NSMutableArray arrayWithArray:list];
    
	NSInteger i=sourceList.count-1;
	NSDate *lastDate=[NSDate date];
/*	
	for (Task *tmp in list ) {
		if ([tmp taskPinned]==0 && [lastDate compare:tmp.taskEndTime]==NSOrderedAscending){
			lastDate=tmp.taskEndTime;
		}
	}
*/

	for(i;i>=0;i--){
		Task *tmp=[sourceList objectAtIndex:i];
		if ([tmp taskPinned]==0 && [lastDate compare:tmp.taskEndTime]==NSOrderedAscending){
			lastDate=tmp.taskEndTime;
			break;
		}
	}
	
	return lastDate;
}

-(NSDate *)smartEndOfLastTaskInList:(NSMutableArray *)list forTask:(Task*)task context:(NSInteger)context isUsedDeadLine:(NSInteger)isUsedDeadLine{
	
     NSMutableArray *sourceList=[NSMutableArray arrayWithArray:list];
    
	Task *taskMember;
	NSInteger i=sourceList.count-1;
	NSDate *ret=[NSDate date];
	
	for(i;i>=0;i--){
		
		taskMember=[sourceList objectAtIndex:i];
		if (taskMember.taskPinned==0 && taskMember.taskWhere==context && taskMember.taskIsUseDeadLine==isUsedDeadLine){
			if([taskMember.taskEndTime compare:[NSDate date]]!=NSOrderedAscending){
				ret= taskMember.taskEndTime;
			}

			goto exitWhile;
		}
		//i-=1;
	}
	
exitWhile:	
	//if([ret compare:task.taskDueStartDate]==NSOrderedDescending)
	//	ret=task.taskDueStartDate;
	
	return ret;
	
}

/* Just apply this for nwe logic of split tasks
-(DateTimeSlot *)createTimeSlotForDTask:(Task *)task inArray:(NSMutableArray *)list startFromDate:(NSDate *)currDate toDate:(NSDate*)toDate{//currDate normally is DueStartDate
	//ILOG(@"[TaskManager createTimeSlotForDTask\n");
	
	//task.isMultiParts=NO;
	//task.howLongParts=@"";
	
	BOOL timeSlotFound=NO;
	BOOL isOVerDue=NO;
	BOOL isPassedDeadLine=NO;
	NSDate *timeSlotFoundSuggested=nil;
	NSInteger indexFound=-1;
	
	DateTimeSlot *retTimeSlotFound=[[DateTimeSlot alloc] init];
	Task *taskTmp=[[Task alloc] init];
	[ivoUtility copyTask:task toTask:taskTmp isIncludedPrimaryKey:YES];
	
	NSDate *timeSlotDate=[[NSDate date] copy];	
	//NSDate *untilDate=toDate;
	
	//get the datetime to start for searching
	if ([timeSlotDate compare:currDate]==NSOrderedAscending){
		[timeSlotDate release];
		timeSlotDate=[currDate copy];		
	}
	
	//if nevermind taskNotEalierThan, make comment on this code 
	if([timeSlotDate compare:task.taskNotEalierThan]==NSOrderedAscending){
		[timeSlotDate release];
		timeSlotDate=[task.taskNotEalierThan copy];
	}

	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = NSWeekdayCalendarUnit| NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit|NSSecondCalendarUnit;
	
	NSDateComponents *comps;
	NSDateComponents *compsTask;
	
	task.currentHowlong=task.taskHowLong;
	
	while (!timeSlotFound && task.currentHowlong>0) {
		
		NSDate *tmpTimeSlot=[timeSlotDate copy];
		comps = [gregorian components:unitFlags fromDate:tmpTimeSlot];	
		[comps setSecond:0];
		
		if(timeSlotDate!=nil){
			[timeSlotDate release];
			timeSlotDate=nil;
		}
		
		NSInteger weekDay=[comps weekday];
		
		NSInteger slotHour=[comps hour];
		NSInteger slotDay=[comps day];
		NSInteger slotMonth=[comps month];
		NSInteger slotYear=[comps year];
		NSInteger slotMinute=[comps minute];
		
		compsTask = [gregorian components:unitFlags fromDate:[tmpTimeSlot dateByAddingTimeInterval:taskTmp.currentHowlong]];
		NSInteger taskHour=[compsTask hour];
		NSInteger taskDay=[compsTask day];
		NSInteger taskMonth=[compsTask month];
		NSInteger taskYear=[compsTask year];
		NSInteger taskMinute=[compsTask minute];
		
		//NSInteger  taskEndInMin=taskHour*60+taskMinute;
		NSInteger  taskStartInMin=taskHour*60;
		NSInteger  slotStartInMin=slotHour*60 +slotMinute;
		
		if (task.taskWhere==0){//home task
			if([self isDayInWeekend:weekDay]){ //search in weekend days
				//if current DateTimeSlot hour is earlier than home weekend time start,start finding DateTimeSlot from home weekend start
				if(slotStartInMin<(homeSettingHourWEStart*60+homeSettingMinWEStart)){
					//if current DateTimeSlot hour is earlier than home weekend time start 
					
					if(homeSettingWEStartInSec>= homeSettingWEEndInSec){
						//if have no room defined for Weekend days, jump to Home on Working days for seaching, start at Home start
						[comps setHour:homeSettingHourNDStart];
						[comps setMinute:homeSettingMinNDStart];
						
						NSInteger restWEDays=endWeekendDay-weekDay +1;
						if(restWEDays<0){
							restWEDays+=7;
						}
						
						[comps setSecond:[comps second] + restWEDays*86400];
						
						timeSlotDate = [[gregorian dateFromComponents:comps] copy];
						
					}else {
						//if have room defined for Weekend days, jump to start at Weekend Home start
						[comps setHour:homeSettingHourWEStart];
						[comps setMinute:homeSettingMinWEStart];
						timeSlotDate = [[gregorian dateFromComponents:comps] copy];
					}					
				//ST4.1
				//}else if(taskEndInMin>(homeSettingHourWEEnd*60+homeSettingMinWEEnd) ||
				//		 (slotDay != taskDay) ||
				//		 (slotMonth != taskMonth) ||
				//		 (slotYear != taskYear)){ 
				}else if(taskStartInMin+5>(homeSettingHourWEEnd*60+homeSettingMinWEEnd) ||
						 (slotDay != taskDay) ||
						 (slotMonth != taskMonth) ||
						 (slotYear != taskYear)){ 
					
					//if current DateTimeSlot hour is in home weekend time, but has no time available room on that day 
					//increase current date to search in next day
					if(weekDay!=endWeekendDay){	
						//if sat, start find on next day(sun) at home weekend time start
						if(homeSettingWEStartInSec>= homeSettingWEEndInSec){
							[comps setHour:homeSettingHourNDStart];
							[comps setMinute:homeSettingMinNDStart];
							NSInteger restWEDays=endWeekendDay-weekDay +1;
							if(restWEDays<0){
								restWEDays+=7;
							}
							
							[comps setSecond:[comps second] + restWEDays*86400];
							
						}else {
							[comps setHour:homeSettingHourWEStart];
							[comps setMinute:homeSettingMinWEStart];
							[comps setSecond:[comps second] + 86400];
						}
						
					}else {
						//if sun, start find on next day (Mon) at home normal day start
						[comps setHour:homeSettingHourNDStart];
						[comps setMinute:homeSettingMinNDStart];
						[comps setSecond:[comps second] + 86400];
					}
					
					timeSlotDate = [[gregorian dateFromComponents:comps] copy];
				}
			}else {//home normal days
				//if DateTimeSlot is ealier than Home Normal Start, start finding at Home Normal Start 
				if(slotStartInMin <(homeSettingHourNDStart*60+homeSettingMinNDStart)){
					[comps setHour:homeSettingHourNDStart];
					[comps setMinute:homeSettingMinNDStart];
					timeSlotDate = [[gregorian dateFromComponents:comps] copy];
					
				}else if(taskStartInMin>(homeSettingHourNDEnd*60 + homeSettingMinNDEnd) ||
						 (slotDay != taskDay) ||
						 (slotMonth != taskMonth) ||
						 (slotYear != taskYear)){
					//increase current date
					if(weekDay==self.currentSetting.endWorkingWDay){
						//if Fri, start find on next day (Sat) at Home Weekend Start
						if(homeSettingWEStartInSec>= homeSettingWEEndInSec){
							[comps setHour:homeSettingHourNDStart];
							[comps setMinute:homeSettingMinNDStart];
							[comps setSecond:[comps second] + (numberOfWeekendDays+1)*86400];//259200
						}else {
							[comps setHour:homeSettingHourWEStart];
							[comps setMinute:homeSettingMinWEStart];
							[comps setSecond:[comps second] + 86400];
						}
					}else {
						//normal day, start find on next day at Home Normal Start
						[comps setHour:homeSettingHourNDStart];
						[comps setMinute:homeSettingMinNDStart];
						[comps setSecond:[comps second] + 86400];
					}
					timeSlotDate = [[gregorian dateFromComponents:comps] copy];
				}
			}
			
		}else if(task.taskWhere==1||task.taskWhere==2){//work & school task
			
			if([self isDayInWeekend:weekDay]){
				if(slotStartInMin < (deskSettingHourWEStart*60 +deskSettingMinWEStart)){
					//weekend days, start find from Desk Weekend Start
					
					if(deskSettingWEStartInSec>= deskSettingWEEndInSec){
						[comps setHour:deskSettingHourNDStart];
						[comps setMinute:deskSettingMinNDStart];
						
						NSInteger restWEDays=endWeekendDay-weekDay +1;
						if(restWEDays<0){
							restWEDays+=7;
						}
						
						[comps setSecond:[comps second] + restWEDays*86400];
					}else {
						[comps setHour:deskSettingHourWEStart];
						[comps setMinute:deskSettingMinWEStart];
					}
					
					timeSlotDate = [[gregorian dateFromComponents:comps] copy];
					
				}else if(taskStartInMin > (deskSettingHourWEEnd*60 + deskSettingMinWEEnd) ||
						 (slotDay != taskDay) ||
						 (slotMonth != taskMonth) ||
						 (slotYear != taskYear)){// ||(taskHour==deskSettingHourWEEnd && (taskMinute > 0 ||taskSecond > 0))) 
					//increase current date to search in next day
					if(weekDay!=endWeekendDay){
						//if sat, start find on next day(sun) at Desk Weekend Time Start
						
						if(deskSettingWEStartInSec>= deskSettingWEEndInSec){
							[comps setHour:deskSettingHourNDStart];
							[comps setMinute:deskSettingMinNDStart];
							NSInteger restWEDays=endWeekendDay-weekDay +1;
							if(restWEDays<0){
								restWEDays+=7;
							}
							
							[comps setSecond:[comps second] + restWEDays*86400];
						}else {
							[comps setHour:deskSettingHourWEStart];
							[comps setMinute:deskSettingMinWEStart];
							[comps setSecond:[comps second] + 86400];
						}
						
					}else {
						//if sun, start find on next day (Mon) at Desk Normal Day Start
							[comps setHour:deskSettingHourNDStart];
							[comps setMinute:deskSettingMinNDStart];
							[comps setSecond:[comps second] + 86400];
					}
					
					timeSlotDate = [[gregorian dateFromComponents:comps] copy];
				}
			}else {//normal days
				//if DateTimeSlot is earlier than Desk Normal Day Start, start find from Desk Normal Day Start
				if(slotStartInMin < (deskSettingHourNDStart*60 + deskSettingMinNDStart)){
					[comps setHour:deskSettingHourNDStart];
					[comps setMinute:deskSettingMinNDStart];
					timeSlotDate = [[gregorian dateFromComponents:comps] copy];
					
				}else if(taskStartInMin > (deskSettingHourNDEnd*60 +deskSettingMinNDEnd) ||
						 (slotDay != taskDay) ||
						 (slotMonth != taskMonth) ||
						 (slotYear != taskYear)){
					//increase current date
					if(weekDay==self.currentSetting.endWorkingWDay){
						//if Fri, start find on next day (Sat) at Desk Weekend Start
						if(deskSettingWEStartInSec>= deskSettingWEEndInSec){
							[comps setHour:deskSettingHourNDStart];
							[comps setMinute:deskSettingMinNDStart];
							[comps setSecond:[comps second] + (numberOfWeekendDays +1 )*86400];// 259200
						}else {
							[comps setHour:deskSettingHourWEStart];
							[comps setMinute:deskSettingMinWEStart];
							[comps setSecond:[comps second] + 86400];
						}
						
					}else {
						//normal day, start find on next day at Desk Normal Day Start
						[comps setHour:deskSettingHourNDStart];
						[comps setMinute:deskSettingMinNDStart];
						[comps setSecond:[comps second] + 86400];

					}
					
					timeSlotDate = [[gregorian dateFromComponents:comps] copy];
				}
			}
		}
		
		if (timeSlotDate !=nil){
			NSDate *resultDate=timeSlotDate;
			if(tmpTimeSlot !=nil){
				[tmpTimeSlot release];
				tmpTimeSlot=nil;
			}
			
			tmpTimeSlot=[resultDate copy];
			
			[timeSlotDate release];
			timeSlotDate=nil;
		}
		
//		if ([(NSDate *)[tmpTimeSlot addTimeInterval:(NSTimeInterval)taskTmp.taskHowLong] compare:taskTmp.taskDueEndDate]==NSOrderedDescending){
//			if(timeSlotFoundSuggested!=nil){
//				[timeSlotFoundSuggested release];
//				timeSlotFoundSuggested=nil;
//			}
//			
//			timeSlotFoundSuggested=[tmpTimeSlot copy];
//			isOVerDue=YES;
//		}
		
//		if ([(NSDate *)[tmpTimeSlot addTimeInterval:(NSTimeInterval)taskTmp.taskHowLong] compare:taskTmp.taskDeadLine]==NSOrderedDescending){
//			isPassedDeadLine=YES;
//		}
		
		taskTmp.taskStartTime=tmpTimeSlot;
		taskTmp.taskEndTime=[tmpTimeSlot dateByAddingTimeInterval:taskTmp.taskHowLong];
		
		TaskActionResult *checkResult=[ivoUtility smartCheckOverlapTask:taskTmp inTaskList:list];
		if(checkResult.errorAtTaskIndex>-1){ 
		  if (checkResult.errorNo==ERR_EVENT_END_OVERLAPPED ||
			checkResult.errorNo==ERR_TASK_END_OVERLAPPED ||
			checkResult.errorNo==ERR_EVENT_OVERLAPS_OTHERS ||
			checkResult.errorNo==ERR_TASK_OVERLAPS_OTHERS){
			  
			  
		  }else {
			  if (timeSlotDate!=nil){
				  [timeSlotDate release];
				  timeSlotDate=nil;
			  }
			  
			  timeSlotDate=[[[list objectAtIndex:checkResult.errorAtTaskIndex] taskEndTime] copy];
		  }

			
//			isOVerDue=NO;
//			isPassedDeadLine=NO;
		}else {
			if(timeSlotFoundSuggested!=nil){
				[timeSlotFoundSuggested release];
				timeSlotFoundSuggested=nil;
			}
			
			timeSlotFoundSuggested=[taskTmp.taskStartTime copy];
			
			indexFound=[ivoUtility getTimeSlotIndexForTask:taskTmp inArray:list];
			timeSlotFound=YES;
		}
		
		[checkResult release];
		
		if(tmpTimeSlot !=nil){
			[tmpTimeSlot release];
			tmpTimeSlot=nil;
		}
	}
	
	[gregorian release];
	
	retTimeSlotFound.indexAt=indexFound;
	retTimeSlotFound.timeSlotDate=timeSlotFoundSuggested;
	retTimeSlotFound.isOverDue=isOVerDue;
	retTimeSlotFound.isPassedDeadLine=isPassedDeadLine;
	
	//if([timeSlotFoundSuggested compare:untilDate]==NSOrderedDescending){
	//	retTimeSlotFound.isNotFit=YES;
	//}
	
	if(timeSlotFoundSuggested !=nil){
		[timeSlotFoundSuggested release];
		timeSlotFoundSuggested=nil;
	}
	
	if(taskTmp !=nil){
		[taskTmp release];
		taskTmp=nil;
	}
	
	if(timeSlotDate!=nil){
		[timeSlotDate release];
		timeSlotDate=nil;
	}
	
	//ILOG(@"TaskManager createTimeSlotForDTask]\n");
	return retTimeSlotFound;
}
*/

-(DateTimeSlot *)createTimeSlotForDTask:(Task *)task inArray:(NSMutableArray *)list startFromDate:(NSDate *)currDate toDate:(NSDate*)toDate{//currDate normally is DueStartDate
	//ILOG(@"[TaskManager createTimeSlotForDTask\n");
	
	BOOL timeSlotFound=NO;
	BOOL isOVerDue=NO;
	BOOL isPassedDeadLine=NO;
	NSDate *timeSlotFoundSuggested=nil;
	NSInteger indexFound=-1;
	
	DateTimeSlot *retTimeSlotFound=[[DateTimeSlot alloc] init];
	Task *taskTmp=[[Task alloc] init];
	[ivoUtility copyTask:task toTask:taskTmp isIncludedPrimaryKey:YES];
	
	NSDate *timeSlotDate=[[NSDate date] copy];	
	NSDate *untilDate=toDate;
	
	//if current date is in the past, shift it to the current
	if([currDate compare:timeSlotDate]==NSOrderedAscending){
		untilDate=[timeSlotDate dateByAddingTimeInterval:[toDate timeIntervalSinceDate:currDate]];
	}
	
	//get the datetime to start for searching
	if ([timeSlotDate compare:currDate]==NSOrderedAscending){
		[timeSlotDate release];
		timeSlotDate=[currDate copy];		
	}
	
	//if nevermind taskNotEalierThan, make comment on this code 
	if([timeSlotDate compare:task.taskNotEalierThan]==NSOrderedAscending){
		[timeSlotDate release];
		timeSlotDate=[task.taskNotEalierThan copy];
		
		untilDate=[task.taskNotEalierThan dateByAddingTimeInterval:[toDate timeIntervalSinceDate:currDate]];
	}
	
	if([timeSlotDate compare:task.taskDueStartDate]==NSOrderedAscending){
		untilDate=[task.taskDueStartDate dateByAddingTimeInterval:[toDate timeIntervalSinceDate:currDate]];
	}
	
	while (!timeSlotFound && [timeSlotDate compare:untilDate]!=NSOrderedDescending) {
		
		NSDate *tmpTimeSlot=[timeSlotDate copy];
		
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		unsigned unitFlags = NSWeekdayCalendarUnit| NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit|NSSecondCalendarUnit;
		
		NSDateComponents *comps = [gregorian components:unitFlags fromDate:tmpTimeSlot];	
		[comps setSecond:0];
		
		if(timeSlotDate!=nil){
			[timeSlotDate release];
			timeSlotDate=nil;
		}
		
		//NSString *dayName=[ivoUtility createWeekDayName:tmpTimeSlot];
		NSInteger weekDay=[comps weekday];//[ivoUtility getWeekday:tmpTimeSlot];
		
		NSInteger slotHour=[comps hour];
		NSInteger slotDay=[comps day];
		NSInteger slotMonth=[comps month];
		NSInteger slotYear=[comps year];
		NSInteger slotMinute=[comps minute];
		
		NSDateComponents *compsTask = [gregorian components:unitFlags fromDate:[tmpTimeSlot dateByAddingTimeInterval:taskTmp.taskHowLong]];
		NSInteger taskHour=[compsTask hour];
		NSInteger taskDay=[compsTask day];
		NSInteger taskMonth=[compsTask month];
		NSInteger taskYear=[compsTask year];
		NSInteger taskMinute=[compsTask minute];
		
		NSInteger  taskEndInMin=taskHour*60+taskMinute; 
		NSInteger  slotStartInMin=slotHour*60 +slotMinute;
		
		if (task.taskWhere==0){//home task
			if([self isDayInWeekend:weekDay]){ //search in weekend days
				//if current DateTimeSlot hour is earlier than home weekend time start,
				//then start finding DateTimeSlot from home weekend start
				if(slotStartInMin<(homeSettingHourWEStart*60+homeSettingMinWEStart)){
					//if current DateTimeSlot hour is earlier than home weekend time start 
					
					if(homeSettingWEStartInSec>= homeSettingWEEndInSec){
						//if have no room defined for Weekend days, jump to Home on Working days for seaching, start at Home start
						[comps setHour:homeSettingHourNDStart];
						[comps setMinute:homeSettingMinNDStart];
						
						NSInteger restWEDays=endWeekendDay-weekDay +1;
						if(restWEDays<0){
							restWEDays+=7;
						}
						
						[comps setSecond:[comps second] + restWEDays*86400];
						
						timeSlotDate = [[gregorian dateFromComponents:comps] copy];
						
					}else {
						//if have room defined for Weekend days, jump to start at Weekend Home start
						[comps setHour:homeSettingHourWEStart];
						[comps setMinute:homeSettingMinWEStart];
						timeSlotDate = [[gregorian dateFromComponents:comps] copy];
					}					
				}else if(taskEndInMin>(homeSettingHourWEEnd*60+homeSettingMinWEEnd) ||
						 (slotDay != taskDay) ||
						 (slotMonth != taskMonth) ||
						 (slotYear != taskYear)){ 
					//if current DateTimeSlot hour is in home weekend time, but has no time available room on that day 
					//increase current date to search in next day
					if(weekDay!=endWeekendDay){	
						//if sat, start find on next day(sun) at home weekend time start
						if(homeSettingWEStartInSec>= homeSettingWEEndInSec){
							[comps setHour:homeSettingHourNDStart];
							[comps setMinute:homeSettingMinNDStart];
							//	[comps setSecond:[comps second] + numberOfWeekendDays*86400];//172800
							NSInteger restWEDays=endWeekendDay-weekDay +1;
							if(restWEDays<0){
								restWEDays+=7;
							}
							
							[comps setSecond:[comps second] + restWEDays*86400];
							
							//							[comps setSecond:[comps second] + abs((7-weekDay+self.currentSetting.startWorkingWDay))*86400];
							
							//timeSlotDate = [[[gregorian dateFromComponents:comps] addTimeInterval:172800] copy];
						}else {
							[comps setHour:homeSettingHourWEStart];
							[comps setMinute:homeSettingMinWEStart];
							[comps setSecond:[comps second] + 86400];
							//timeSlotDate = [[[gregorian dateFromComponents:comps] addTimeInterval:86400] copy];
						}
						
					}else {
						//if sun, start find on next day (Mon) at home normal day start
						[comps setHour:homeSettingHourNDStart];
						[comps setMinute:homeSettingMinNDStart];
						[comps setSecond:[comps second] + 86400];
						//timeSlotDate = [[[gregorian dateFromComponents:comps] addTimeInterval:86400] copy];
					}
					
					
					//[comps setSecond:[comps second] + abs((6-weekDay+taskmanager.currentSetting.startWorkingWDay))*86400];
					timeSlotDate = [[gregorian dateFromComponents:comps] copy];
				}
			}else {//home normal days
				//if DateTimeSlot is ealier than Home Normal Start, start finding at Home Normal Start 
				if(slotStartInMin <(homeSettingHourNDStart*60+homeSettingMinNDStart)){
					[comps setHour:homeSettingHourNDStart];
					[comps setMinute:homeSettingMinNDStart];
					timeSlotDate = [[gregorian dateFromComponents:comps] copy];
					
				}else if(taskEndInMin>(homeSettingHourNDEnd*60 + homeSettingMinNDEnd) ||
						 (slotDay != taskDay) ||
						 (slotMonth != taskMonth) ||
						 (slotYear != taskYear)){
					//increase current date
					//if ([dayName isEqual: friText]){
					if(weekDay==self.currentSetting.endWorkingWDay){
						//if Fri, start find on next day (Sat) at Home Weekend Start
						if(homeSettingWEStartInSec>= homeSettingWEEndInSec){
							[comps setHour:homeSettingHourNDStart];
							[comps setMinute:homeSettingMinNDStart];
							[comps setSecond:[comps second] + (numberOfWeekendDays+1)*86400];//259200
							//timeSlotDate = [[[gregorian dateFromComponents:comps] addTimeInterval:259200] copy];
						}else {
							[comps setHour:homeSettingHourWEStart];
							[comps setMinute:homeSettingMinWEStart];
							[comps setSecond:[comps second] + 86400];
							//timeSlotDate = [[[gregorian dateFromComponents:comps] addTimeInterval:86400] copy];
						}
					}else {
						//normal day, start find on next day at Home Normal Start
						[comps setHour:homeSettingHourNDStart];
						[comps setMinute:homeSettingMinNDStart];
						[comps setSecond:[comps second] + 86400];
						//timeSlotDate = [[[gregorian dateFromComponents:comps] addTimeInterval:86400] copy];
					}
					timeSlotDate = [[gregorian dateFromComponents:comps] copy];
				}
			}
			
		}else if(task.taskWhere==1||task.taskWhere==2){//work & school task
			
			//if(([dayName isEqual: satText]) || ([dayName isEqual: sunText])){ //weekend days
			if([self isDayInWeekend:weekDay]){
				if(slotStartInMin < (deskSettingHourWEStart*60 +deskSettingMinWEStart)){
					//weekend days, start find from Desk Weekend Start
					
					if(deskSettingWEStartInSec>= deskSettingWEEndInSec){
						[comps setHour:deskSettingHourNDStart];
						[comps setMinute:deskSettingMinNDStart];
						
						NSInteger restWEDays=endWeekendDay-weekDay +1;
						if(restWEDays<0){
							restWEDays+=7;
						}
						
						[comps setSecond:[comps second] + restWEDays*86400];
					}else {
						[comps setHour:deskSettingHourWEStart];
						[comps setMinute:deskSettingMinWEStart];
					}
					
					//[comps setSecond:[comps second] + abs((6-weekDay+taskmanager.currentSetting.startWorkingWDay))*86400];
					timeSlotDate = [[gregorian dateFromComponents:comps] copy];
					
				}else if(taskEndInMin > (deskSettingHourWEEnd*60 + deskSettingMinWEEnd) ||
						 (slotDay != taskDay) ||
						 (slotMonth != taskMonth) ||
						 (slotYear != taskYear)){// ||(taskHour==deskSettingHourWEEnd && (taskMinute > 0 ||taskSecond > 0))) 
					//increase current date to search in next day
					if(weekDay!=endWeekendDay){
						//if sat, start find on next day(sun) at Desk Weekend Time Start
						
						if(deskSettingWEStartInSec>= deskSettingWEEndInSec){
							[comps setHour:deskSettingHourNDStart];
							[comps setMinute:deskSettingMinNDStart];
							NSInteger restWEDays=endWeekendDay-weekDay +1;
							if(restWEDays<0){
								restWEDays+=7;
							}
							
							[comps setSecond:[comps second] + restWEDays*86400];
						}else {
							[comps setHour:deskSettingHourWEStart];
							[comps setMinute:deskSettingMinWEStart];
							[comps setSecond:[comps second] + 86400];
						}
						
					}else {
						//if sun, start find on next day (Mon) at Desk Normal Day Start
						[comps setHour:deskSettingHourNDStart];
						[comps setMinute:deskSettingMinNDStart];
						[comps setSecond:[comps second] + 86400];
					}
					
					timeSlotDate = [[gregorian dateFromComponents:comps] copy];
				}
			}else {//normal days
				//if DateTimeSlot is earlier than Desk Normal Day Start, start find from Desk Normal Day Start
				if(slotStartInMin < (deskSettingHourNDStart*60 + deskSettingMinNDStart)){
					[comps setHour:deskSettingHourNDStart];
					[comps setMinute:deskSettingMinNDStart];
					timeSlotDate = [[gregorian dateFromComponents:comps] copy];
					
				}else if(taskEndInMin > (deskSettingHourNDEnd*60 +deskSettingMinNDEnd) ||
						 (slotDay != taskDay) ||
						 (slotMonth != taskMonth) ||
						 (slotYear != taskYear)){// ||(taskHour==deskSettingHourNDEnd && (taskMinute > 0 ||taskSecond > 0))) 
					//increase current date
					if(weekDay==self.currentSetting.endWorkingWDay){
						//if Fri, start find on next day (Sat) at Desk Weekend Start
						if(deskSettingWEStartInSec>= deskSettingWEEndInSec){
							[comps setHour:deskSettingHourNDStart];
							[comps setMinute:deskSettingMinNDStart];
							[comps setSecond:[comps second] + (numberOfWeekendDays +1 )*86400];// 259200
							//timeSlotDate = [[[gregorian dateFromComponents:comps] addTimeInterval:259200] copy];
						}else {
							[comps setHour:deskSettingHourWEStart];
							[comps setMinute:deskSettingMinWEStart];
							[comps setSecond:[comps second] + 86400];
							//timeSlotDate = [[[gregorian dateFromComponents:comps] addTimeInterval:86400] copy];
						}
						
					}else {
						//normal day, start find on next day at Desk Normal Day Start
						[comps setHour:deskSettingHourNDStart];
						[comps setMinute:deskSettingMinNDStart];
						[comps setSecond:[comps second] + 86400];
						
						//timeSlotDate = [[[gregorian dateFromComponents:comps] addTimeInterval:86400] copy];
					}
					
					timeSlotDate = [[gregorian dateFromComponents:comps] copy];
				}
			}
		}
		
		//[dayName release];
		[gregorian release];
		
		if (timeSlotDate !=nil){
			NSDate *resultDate=timeSlotDate;
			if(tmpTimeSlot !=nil){
				[tmpTimeSlot release];
				tmpTimeSlot=nil;
			}
			
			tmpTimeSlot=[resultDate copy];
			
			[timeSlotDate release];
			timeSlotDate=nil;
		}
		
		if ([(NSDate *)[tmpTimeSlot dateByAddingTimeInterval:(NSTimeInterval)taskTmp.taskHowLong] compare:taskTmp.taskDueEndDate]==NSOrderedDescending){
			if(timeSlotFoundSuggested!=nil){
				[timeSlotFoundSuggested release];
				timeSlotFoundSuggested=nil;
			}
			
			timeSlotFoundSuggested=[tmpTimeSlot copy];
			isOVerDue=YES;
		}
		
		if (taskTmp.taskDeadLine && [(NSDate *)[tmpTimeSlot dateByAddingTimeInterval:(NSTimeInterval)taskTmp.taskHowLong] compare:taskTmp.taskDeadLine]==NSOrderedDescending){
			isPassedDeadLine=YES;
		}
		
		taskTmp.taskStartTime=tmpTimeSlot;
		taskTmp.taskEndTime=[tmpTimeSlot dateByAddingTimeInterval:taskTmp.taskHowLong];
		
        NSMutableArray *sourceList=[NSMutableArray arrayWithArray:list];
        
		TaskActionResult *checkResult=[ivoUtility smartCheckOverlapTask:taskTmp inTaskList:sourceList];
		if(checkResult.errorAtTaskIndex>-1){
			if (timeSlotDate!=nil){
				[timeSlotDate release];
				timeSlotDate=nil;
			}
			
			timeSlotDate=[[[sourceList objectAtIndex:checkResult.errorAtTaskIndex] taskEndTime] copy];
			
			isOVerDue=NO;
			isPassedDeadLine=NO;
		}else {
			if(timeSlotFoundSuggested!=nil){
				[timeSlotFoundSuggested release];
				timeSlotFoundSuggested=nil;
			}
			
			timeSlotFoundSuggested=[taskTmp.taskStartTime copy];
			
			indexFound=[ivoUtility getTimeSlotIndexForTask:taskTmp inArray:sourceList];
			timeSlotFound=YES;
		}
		
		[checkResult release];
		
		if(tmpTimeSlot !=nil){
			[tmpTimeSlot release];
			tmpTimeSlot=nil;
		}
	}
	
	//	DateTimeSlot *retTimeSlotFound=[[DateTimeSlot alloc] init];
	
	retTimeSlotFound.indexAt=indexFound;
	retTimeSlotFound.timeSlotDate=timeSlotFoundSuggested;
	retTimeSlotFound.isOverDue=isOVerDue;
	retTimeSlotFound.isPassedDeadLine=isPassedDeadLine;
	
	if([timeSlotFoundSuggested compare:untilDate]==NSOrderedDescending){
		retTimeSlotFound.isNotFit=YES;
	}
	
	if(timeSlotFoundSuggested !=nil){
		[timeSlotFoundSuggested release];
		timeSlotFoundSuggested=nil;
	}
	
	if(taskTmp !=nil){
		[taskTmp release];
		taskTmp=nil;
	}
	
	if(timeSlotDate!=nil){
		[timeSlotDate release];
		timeSlotDate=nil;
	}
	
	//[gregorian release];
	//ILOG(@"TaskManager createTimeSlotForDTask]\n");
	return retTimeSlotFound;
}

-(BOOL)isDayInWeekend:(NSInteger)weekDay{
	if(startWeekendDay<=weekDay && weekDay<=endWeekendDay) 
		return YES;
	
	if(weekDay<=startWeekendDay && weekDay<=endWeekendDay && startWeekendDay>=endWeekendDay)
		return YES;

	if(startWeekendDay<=weekDay && weekDay>=endWeekendDay && startWeekendDay>=endWeekendDay)
		return YES;
	
	return NO;
}

-(NSInteger)getMaxTaskDurationInTaskList:(NSMutableArray*)inList{
    
     NSMutableArray *sourceList=[NSMutableArray arrayWithArray:inList];
	NSInteger currentMaxDuration=1;
	for(Task *tmp in sourceList){
		if(tmp.taskPinned==0 && tmp.taskHowLong>currentMaxDuration){
			currentMaxDuration=tmp.taskHowLong;
		}
	}
	
	return currentMaxDuration;
}

-(NSMutableArray *)createListDeletedItemFromTaskList{
	NSMutableArray *ret=[[NSMutableArray alloc] init];
	NSArray *delTaskList=[self.currentSetting.deleteItemsInTaskList componentsSeparatedByString:@"$!$"];
	
	if(delTaskList.count>0){
		for(NSInteger i=1;i<delTaskList.count;i++){
			NSArray *keys=[(NSString*)[delTaskList objectAtIndex:i] componentsSeparatedByString:@"|"];
			if(keys.count==3){
				DeletedTEKeys *delTasks=[[DeletedTEKeys alloc] init];

				delTasks.primaryKey=[[keys objectAtIndex:0] intValue];
				delTasks.syncKey=[[keys objectAtIndex:1] doubleValue];
				delTasks.gcalEventId=[keys objectAtIndex:2];
				
				[ret addObject:delTasks];
				[delTasks release];
			}
		}
	}
	return ret;
}

//-(void)removeDeleteInfoForKey:(NSInteger)taskKey syncKey:(double)syncKey gcalEventId:(NSString *)gcalEventId{
//	self.currentSetting.deleteItemsInTaskList=[self.currentSetting.deleteItemsInTaskList 
//											   stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\%d|%f|%@",taskKey,syncKey,gcalEventId]
//											   withString:@""];
//	[self.currentSetting update];
//}

-(void)removeDeleteList{
	self.currentSetting.deleteItemsInTaskList=@"";
	[self.currentSetting update];
}

-(NSMutableArray *)copyTasksFromList:(NSMutableArray *)list{
    NSMutableArray *sourceList=[NSMutableArray arrayWithArray:list];
	NSMutableArray *ret=[[NSMutableArray alloc] initWithCapacity:list.count];
	for (Task *task in sourceList){
		Task *t=[[Task alloc] init];
		[ivoUtility copyTask:task toTask:t isIncludedPrimaryKey:YES];
		[ret addObject:t];
		[t release];
	}
	return ret;
}

#pragma mark Sync
-(void)checkForFullSync{
    totalSync=0;
	if (!needStopSync && self.currentSetting.autoICalSync) {
        
        if (self.currentSetting.enableSyncICal) {
            [self.ekSync backgroundFullSync];
        }
        
        if (self.currentSetting.enabledReminderSync) {
            [self.reminderSync backgroundFullSync];
        }
	}
}

#pragma mark properties

-(NSMutableArray *)taskList{

	return taskList;	
}

-(void)initTaskList:(NSMutableArray *)list
{
	taskList = list;
}

-(void)setTaskList:(NSMutableArray *)list{
	//ILOG(@"[TaskManager setTaskList\n");
	//if(taskList !=nil){
	//	[taskList release];
	//}
    
    if (!taskList) {
        taskList=[[NSMutableArray alloc] init];
    }
    
    [taskList removeAllObjects];
    
	NSSortDescriptor *date_descriptor = [[NSSortDescriptor alloc] initWithKey:@"taskStartTime"  ascending: YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject:date_descriptor];
	[taskList addObjectsFromArray:[list sortedArrayUsingDescriptors:sortDescriptors]];
	[date_descriptor release];
	
}

-(NSMutableArray *)quickTaskList{
	return quickTaskList;	
}

-(void)setQuickTaskList:(NSMutableArray *)list{
	//ILOG(@"[TaskManager setQuickTaskList\n");
	
	if(!quickTaskList){
		quickTaskList=[[NSMutableArray alloc] init];
	}	
	
    [quickTaskList removeAllObjects];
    
	//sort the list before assigning it
	NSMutableArray* originalQTasks=[[NSMutableArray alloc] initWithArray:list]; 
	
	NSSortDescriptor *date_descriptorQ = [[NSSortDescriptor alloc] initWithKey:@"taskStartTime"  ascending: YES];
	
	NSArray *sortDescriptors = [NSArray arrayWithObject:date_descriptorQ];
	
	//get the sorted task list based on the original task list 	
	[quickTaskList addObjectsFromArray:[originalQTasks sortedArrayUsingDescriptors:sortDescriptors]];
    
	[date_descriptorQ release];
	[originalQTasks release];
	
	//ILOG(@"TaskManager setQuickTaskList]\n");
}

-(NSMutableArray *)completedTaskList{
	return completedTaskList;	
}

-(void)setCompletedTaskList:(NSMutableArray *)list{
	//ILOG(@"[TaskManager setCompletedTaskList\n");
	
	if(!completedTaskList){
		completedTaskList=[[NSMutableArray alloc] init];
	}	
	
    [completedTaskList removeAllObjects];
    
	//sort the list before assigning it
	NSMutableArray* originalQTasks=[[NSMutableArray alloc] initWithArray:list]; 
	
	//lasted done task is top most of section
	NSSortDescriptor *date_descriptorQ = [[NSSortDescriptor alloc] initWithKey:@"taskDateUpdate"  ascending: NO];
	
	NSArray *sortDescriptors = [NSArray arrayWithObject:date_descriptorQ];
	
	//get the sorted task list based on the original task list 	
	[completedTaskList addObjectsFromArray:[originalQTasks sortedArrayUsingDescriptors:sortDescriptors]];
	[date_descriptorQ release];
	[originalQTasks release];
	//ILOG(@"TaskManager setCompletedTaskList]\n");
}

-(NSMutableArray *)filterList{
	return filterList;
}

-(void)setFilterList:(NSMutableArray *)list{
	[filterList release];
	filterList=nil;
	
	if(list==nil) return;
	
	//sort the list before assigning it
	NSMutableArray* originalTasks=[[NSMutableArray alloc] initWithArray:list]; 
	
	NSSortDescriptor *date_descriptor = [[NSSortDescriptor alloc] initWithKey:@"taskStartTime"  ascending: YES];
	
	NSArray *sortDescriptors = [NSArray arrayWithObject:date_descriptor];
	
	//get the sorted task list based on the original task list 	
	filterList=[[NSMutableArray alloc] initWithArray:[originalTasks sortedArrayUsingDescriptors:sortDescriptors]];
	[date_descriptor release];
	[originalTasks release];
	
}


#pragma mark New logic for ST4.1

-(TimeSlotObject *)findTimeSlotForTasks:(NSMutableArray*)list{
	TimeSlotObject *ret;
/*	[self sortList:list byKey:@"taskNotEalierThan"];
	
	NSDate *loopDate;
	if (list.count>0) {
		loopDate=[[list objectAtIndex:0] taskNotEalierThan];
	}
	
	NSMutableArray *eventList=[self get];
	NSMutableArray *openTimeslots=[self openTimeSlotsFromTime:
													   toTime:
												 inEventsList:];
	
	for (Task *task in list) {
		task.isMultiParts=NO;
		task.howLongPart=task.taskHowLong;
		
		t=task.taskNotEalierThan;
		
	}
*/	
	return ret;
}

//This will calculate open time slots for a day with a day events list.
-(NSMutableArray *)openTimeSlotsFromTime:(NSDate*)startTime toTime:(NSDate*)toTime inEventsList:(NSMutableArray*)eventslist{
	
    NSMutableArray *sourceList=[NSMutableArray arrayWithArray:eventList];
    
	NSMutableArray *ret=[NSMutableArray array];
	NSDate *loopDate=startTime;
	NSDate *endTime;
	
	if ([loopDate compare:toTime]!=NSOrderedAscending) {
		goto exitFor;
	}
	
	if (sourceList.count>0) {
		//BOOL foundStart=NO;
		BOOL existedNextEvent=NO;
		NSInteger i=0;
		
		for (Task *event in sourceList) {
			i++;
			
		foundTimeSlot:			
			
			//find start for new open time slot
			if ([event.taskEndTime compare:loopDate]==NSOrderedAscending) {
				if (i==sourceList.count) {
					existedNextEvent=NO;
				}
				continue;
			}
			
			if ([event.taskStartTime compare:loopDate]!=NSOrderedDescending && 
				[event.taskEndTime compare:loopDate]!=NSOrderedAscending) {
				
				loopDate=event.taskEndTime;
				
				if (i>=sourceList.count) {
					existedNextEvent=NO;
				}
			}else if ([event.taskStartTime compare:loopDate]==NSOrderedDescending) {
				BOOL done=NO;
				existedNextEvent=YES;
				
				if (i>=sourceList.count) {
					existedNextEvent=NO;
				}
				
				//if start is found, the end will be either the start of the next event in list 
				//or the toTime if it reach the last item in list
				endTime=event.taskStartTime;
				if ([endTime compare:toTime]==NSOrderedDescending) {
					endTime=toTime;
					done=YES;
				}
				
				TimeSlotObject *openTimeSlot=[[TimeSlotObject alloc] init];
				openTimeSlot.startTimeInMinutes=[ivoUtility getHour:loopDate]*60 +[ivoUtility getMinute:loopDate];
				openTimeSlot.endTimeInMinutes=[ivoUtility getHour:endTime]*60 +[ivoUtility getMinute:endTime];
				[ret addObject:openTimeSlot];
				[openTimeSlot release];
				
				loopDate=event.taskEndTime;
				
				if (done) {
					goto exitFor;
				}
			}
			
			if ([loopDate compare:toTime]==NSOrderedDescending) {
				goto exitFor;
			}
			
		}
		
		if (!existedNextEvent) {
			TimeSlotObject *openTimeSlot=[[TimeSlotObject alloc] init];
			openTimeSlot.startTimeInMinutes=[ivoUtility getHour:loopDate]*60 +[ivoUtility getMinute:loopDate];
			openTimeSlot.endTimeInMinutes=[ivoUtility getHour:toTime]*60 +[ivoUtility getMinute:toTime];
			[ret addObject:openTimeSlot];
			[openTimeSlot release];
		}
	}else {
		TimeSlotObject *openTimeSlot=[[TimeSlotObject alloc] init];
		openTimeSlot.startTimeInMinutes=[ivoUtility getHour:loopDate]*60 +[ivoUtility getMinute:loopDate];
		openTimeSlot.endTimeInMinutes=[ivoUtility getHour:toTime]*60 +[ivoUtility getMinute:toTime];
		[ret addObject:openTimeSlot];
		[openTimeSlot release];
	}
	
	
exitFor:
	return ret;
}

#pragma mark End New logic for ST4.1

-(NSString *)filterClause{
	return filterClause;
}

-(void)setFilterClause:(NSString *)aString{
	[filterClause release];
	filterClause=[aString copy];
}

-(NSString *)filterDoTodayClause{
	return filterDoTodayClause;
}

-(void)setFilterDoTodayClause:(NSString *)aString{
	[filterDoTodayClause release];
	filterDoTodayClause=[aString copy];
}

-(NSMutableArray *) taskListBackUp{
	return taskListBackUp;
}

-(void)setTaskListBackUp:(NSMutableArray *)list{
	[taskListBackUp release];
	taskListBackUp=[[NSMutableArray alloc] initWithArray:list];
}

-(BOOL)isSomeDtasksCouldNotBeRefreshed{
	return isSomeDtasksCouldNotBeRefreshed;
}

-(void)setIsSomeDtasksCouldNotBeRefreshed:(BOOL)aBool{
	isSomeDtasksCouldNotBeRefreshed=aBool;
}

-(Setting *)currentSetting{
	return currentSetting;
}

-(void)setCurrentSetting:(Setting *)fromSetting{
	[currentSetting release];
	currentSetting=[[Setting alloc] init];
	[ivoUtility copySetting:fromSetting toSetting:currentSetting];
}

-(Setting *)currentSettingModifying{
	return currentSettingModifying;
}

-(void)setCurrentSettingModifying:(Setting *)fromSetting{
	[currentSettingModifying release];
	currentSettingModifying=[[Setting alloc] init];
	[ivoUtility copySetting:fromSetting toSetting:currentSettingModifying];
}

-(NSDate *)getREUntilDate{
	return getREUntilDate;
}

-(void)setGetREUntilDate:(NSDate *)aDate{
	[getREUntilDate release];
	getREUntilDate=[aDate copy];
}
/*
-(NSInteger)maxDuration{
	return maxDuration;
}

-(void)setMaxDuration:(NSInteger)aNum{
	maxDuration=aNum;
}
 */
@end
