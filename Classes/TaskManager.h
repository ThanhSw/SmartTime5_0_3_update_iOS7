//
//  TaskManager.h
//  iVo_DatabaseAccess
//
//  Created by Nang Le on 4/30/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ivo_Utilities.h"
#import <Foundation/Foundation.h>

@class Task;
@class DateTimeSlot;
@class Setting;
@class TaskActionResult;
@class EKSync;
@class ReminderSync;

@interface TaskManager : NSObject {

	NSMutableArray	*taskList;
	NSMutableArray	*quickTaskList;
	NSMutableArray	*completedTaskList;
	NSMutableArray	*filterList;
	
	Task			*tmpNewTask;
	Task			*tmpUpdateTask;
	UIAlertView		*alertView;
	NSInteger		updatePK;
	NSInteger		delayType;
	
	NSString		*filterClause;
	NSString		*filterDoTodayClause;
	NSMutableArray	*taskListBackUp;
	BOOL			isSomeDtasksCouldNotBeRefreshed;
	Setting			*currentSetting;
	Setting			*currentSettingModifying;
	
	NSMutableArray	*fullTaskListBackUp;
	NSDate			*getREUntilDate;
	
	NSMutableArray	*dummiesList;
	NSMutableArray	*normalTaskList;
	NSMutableArray	*dTaskList;
	NSMutableArray	*eventList;
	NSMutableArray	*adeList;
	NSMutableArray	*REList;
	
	NSDate			*hasFilledDummiesToDate;
	NSMutableArray	*recentDummiesList;
	
	EKSync			*ekSync;
    ReminderSync    *reminderSync;
}
 
@property (nonatomic,retain)	NSMutableArray	*taskList;
@property (nonatomic,retain)	NSMutableArray	*quickTaskList;
@property (nonatomic,retain)	NSMutableArray	*completedTaskList;
@property (nonatomic,assign)	BOOL			isSomeDtasksCouldNotBeRefreshed;
@property (nonatomic,copy)		NSString		*filterClause;
@property (nonatomic,copy)		NSString		*filterDoTodayClause;
@property (nonatomic,retain)	NSMutableArray	*taskListBackUp;
@property (nonatomic,retain)	NSMutableArray	*filterList;
@property (nonatomic,retain)	Setting			*currentSetting;
@property (nonatomic,retain)	Setting			*currentSettingModifying;
@property (nonatomic,retain)	NSMutableArray	*fullTaskListBackUp;
@property (nonatomic,copy)		NSDate			*getREUntilDate;

@property (nonatomic,retain)	NSMutableArray	*dummiesList;
@property (nonatomic,retain)	NSMutableArray	*normalTaskList;
@property (nonatomic,retain)	NSMutableArray	*dTaskList;
@property (nonatomic,retain)	NSMutableArray	*eventList;
@property (nonatomic,retain)	NSMutableArray	*adeList;
@property (nonatomic,retain)	NSMutableArray	*REList;
@property (nonatomic,retain)	NSDate			*hasFilledDummiesToDate;
@property (nonatomic,retain)	NSMutableArray	*recentDummiesList;
@property (nonatomic,retain)	EKSync			*ekSync;
@property (nonatomic,retain)	ReminderSync    *reminderSync;

//- (void)sortAscTaskListByDate;
- (void) sortAscTaskListByDate:(NSMutableArray*)list;
- (NSInteger)getIndexOfTaskByPrimaryKey:(Task *)task inArray:(NSMutableArray *)list;
- (TaskActionResult *) updateTask:(Task *)task isAllowChangeDueWhenUpdate:(BOOL)isAllowChangeDueWhenUpdate updateREType:(NSInteger)updateREType REUntilDate:(NSDate*)REUntilDate updateTime:(NSDate*)updateTime;

- (void)markedCompletedTask:(NSInteger)taskKey doneREType:(NSInteger)doneREType;

- (TaskActionResult *) deleteTask: (double) taskKey isDeleteFromDB:(BOOL)deleteFromDB deleteREType:(NSInteger)deleteREType;
- (void)splitUnPinchedTasksFromTaskList:(NSMutableArray *)list fromIndex:(NSInteger)position toList:(NSMutableArray *)outList context:(NSInteger)context;
- (void)splitUnPinchedTasksNoPassedDeadlineFromTaskList:(NSMutableArray *)list fromIndex:(NSInteger)position toList:(NSMutableArray *)outList context:(NSInteger)context;
- (void)splitTasksFromStartTime:(NSMutableArray *)list fromStartTime:(NSDate *)startTime toList:(NSMutableArray *)outList context:(NSInteger)context;
- (void)splitTasksByDeadLineFromTaskList:(NSMutableArray *)list fromIndex:(NSInteger)position toList:(NSMutableArray *)outList context:(NSInteger)context byDeadLine:(NSInteger)byDeadLine;
- (TaskActionResult*)addNewTask:(Task *)task toArray:(NSMutableArray *)list isAllowChangeDueWhenAdd:(BOOL)isAllowChangeDueWhenAdd;
- (TaskActionResult*)delayTask:(NSInteger)taskKey delayType:(NSInteger) type isAutoChangeDue:(BOOL)changeDue;
- (TaskActionResult*)moveTask:(NSInteger)taskKey toTask:(NSInteger)toTaskKey isAutoChangeDue:(BOOL)changeDue;
- (TaskActionResult*)moveTaskInCalendar:(NSInteger)taskKey toTask:(NSInteger)toTaskKey expectedStartTime:(NSDate*)expectedStartTime isAutoChangeDue:(BOOL)isAutoChangeDue;

- (void)sortList:(NSMutableArray *)list byKey:(NSString *)byKey;
-(void)sortListWithAD:(NSMutableArray *)list byKey:(NSString *)byKey isAscending:(BOOL)isAscending;
- (void) resetFirstTaskContextInList:(NSMutableArray *)list;
- (NSDate *)getDueEndBeforeInTaskList:(NSMutableArray *)list beforeIndex:(NSInteger)beforeIndex;
- (NSDate *)getEndTimeInTaskList:(NSMutableArray *)list beforeIndex:(NSInteger)beforeIndex;
- (NSDate *)getDueEndAfterInTaskList:(NSMutableArray *)list afterIndex:(NSInteger)afterIndex;

-(DateTimeSlot *)createTimeSlotForDTask:(Task *)task inArray:(NSMutableArray *)list startFromDate:(NSDate *)currDate toDate:(NSDate*)toDate;

- (NSMutableArray*) getDisplayList:(NSDate *)fillREUntilDate;
- (void)callAlert:(NSString *)message;
-(BOOL)refreshTaskList;
-(NSInteger)getMaxTaskDurationInTaskList:(NSMutableArray*)inList;
-(TaskActionResult *)applyNewSetting4TaskList:(Setting *)currentSettingModifying;
- (NSDate *)lastTaskEndDateInList:(NSMutableArray *)list;
//-(NSDate *)smartEndOfLastTaskInList:(NSMutableArray *)list context:(NSInteger)context isUsedDeadLine:(NSInteger)isUsedDeadLine;
-(NSDate *)smartEndOfLastTaskInList:(NSMutableArray *)list forTask:(Task*)task context:(NSInteger)context isUsedDeadLine:(NSInteger)isUsedDeadLine;

//-(NSDate *)fillRepeatEventInstances:(NSMutableArray *)list toList:(NSMutableArray*)toList fromDate:(NSDate *)fromDate getInstanceUntilDate:(NSDate *)getInstanceUntilDate isShowPastInstances:(BOOL)isShowPastInstances;
//-(NSDate *)fillRepeatEventInstances:(NSMutableArray *)list toList:(NSMutableArray*)toList fromDate:(NSDate *)fromDate getInstanceUntilDate:(NSDate *)getInstanceUntilDate isShowPastInstances:(BOOL)isShowPastInstances isCleanOldDummies:(BOOL)isCleanOldDummies;
-(NSDate *)fillRepeatEventInstances:(NSMutableArray *)list 
							 toList:(NSMutableArray*)toList 
						   fromDate:(NSDate *)fromDate 
			   getInstanceUntilDate:(NSDate *)getInstanceUntilDate 
				isShowPastInstances:(BOOL)isShowPastInstances 
				  isCleanOldDummies:(BOOL)isCleanOldDummies 
			   isRememberFilledDate:(BOOL)isRememberFilledDate
		   isNeedAtLeastOneInstance:(BOOL)isNeedAtLeastOneInstance;

-(Task *)addInstanceIntoList:(Task *)task toList:(NSMutableArray *)list instanceKey:(NSInteger)instanceKeyp forDate:(NSDate *)date;
-(NSMutableArray *)createRepeatEventInstanceList:(Task *)task getInstanceUntilDate:(NSDate *)getInstanceUntilDate;
-(void)updateNewDueEndDateForUpdatedTask:(Task *)task inList:(NSMutableArray *)list;
-(NSInteger)deleteREInstances:(Task *)instance inList:(NSMutableArray *)list deleteType:(NSInteger)deleteType isDeleteFromDB:(BOOL)isDeleteFromDB;
-(void)cleanExceptionInstanceInMainSeries:(Task*)task inList:(NSMutableArray *)list;
-(NSMutableArray *)createListExceptionInstancesOfRE:(Task*)taskRE inList:(NSMutableArray *)list;
//-(NSMutableArray *)createRepeatEventsInstancesAndExceptionsList:(NSMutableArray *)RETaskList fromDate:(NSDate*)fromDate toDate:(NSDate *)getInstanceUntilDate;
-(Task *)addInstanceIntoExtraList:(Task *)task toList:(NSMutableArray *)list instanceKey:(NSInteger)instanceKeyp forDate:(NSDate *)date;
-(void)updateExceptionIntoRE:(Task *)REExpInstance inList:(NSMutableArray *)inList originalStartDate:(NSDate *)date action:(NSInteger)action;

-(Task*)getParentRE:(Task *)instance inList:(NSMutableArray *)list;
-(BOOL)isExistedExceptionOnDate:(NSDate *)date forRE:(Task *)task inList:(NSMutableArray *)list;

//for syncing
-(NSMutableArray *)createListDeletedItemFromTaskList;
-(void)removeDeleteList;

//-(NSMutableArray *)createInspectDisplaylist:(NSMutableArray *)list isIncludedADE:(BOOL)isIncludedADE;
-(NSMutableArray *)createInspectDisplaylist:(NSMutableArray *)list isSplit:(BOOL)isSplit fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
-(BOOL)isNotFitTask:(Task *)task;

- (TaskActionResult *)addNewGCalSyncTask:(NSMutableArray *)addList toArray:(NSMutableArray *)list isAllowChangeDueWhenAdd:(BOOL)isAllowChangeDueWhenAdd;
- (NSMutableArray*) getFilterListFromDate:(NSDate *)fromDate getInstanceUntilDate:(NSDate *)fillREUntilDate;
//-(NSMutableArray *)getTaskListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate splitLongTask:(BOOL) splitLongTask;
-(NSMutableArray *)getTaskListFromDate:(NSDate *)fromDate 
								toDate:(NSDate *)toDate 
						 splitLongTask:(BOOL) splitLongTask 
					  isUpdateTaskList:(BOOL)isUpdateTaskList 
							isSplitADE:(BOOL)isSplitADE; 
//trung ST3.1
- (void) fillFirstDummyREInstanceToList: (NSMutableArray *)list rootRE:(Task *)task;
-(void)initTaskList:(NSMutableArray *)list;

-(void)createDummiesForREFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
-(void)refreshTaskListFromPartList;
-(NSMutableArray *)getTaskListFromTheOrder:(NSInteger)fromTheOrder toTheOrder:(NSInteger)toTheOrder;
-(BOOL)updateDummiesKeyFromList:(NSMutableArray *)fromList toList:(NSMutableArray *)toList;
-(void)updateTaskListWithDateAndDummies:(id)sender;

-(NSMutableArray *)getSubTaskListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
-(NSMutableArray *)getREListFromTaskList:(NSMutableArray *)list;
-(NSInteger)getRepeatEveryForRE:(Task *)task;
-(void)addTaskInToList:(Task*)task toList:(NSMutableArray *)toList fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate isSplitLongTask:(BOOL)isSplitLongTask;
-(void )createInspectDisplayForTask:(Task *)task inList:(NSMutableArray *)list isSplit:(BOOL)isSplit fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
-(NSMutableArray *)copyTasksFromList:(NSMutableArray *)list;
-(BOOL)isDayInWeekend:(NSInteger)weekDay;

-(Projects *)projectWithPrimaryKey:(NSInteger)key;

- (NSDate *)updateTimeFromString:(NSString*)string forDate:(NSDate*)date;
-(NSInteger)getToodledoRepeatTypeForTask:(Task *)task;

-(BOOL)addCalendarToCalendarList:(Projects *)cal;

-(void)updateLocalNotificationForList:(NSMutableArray*)list;
-(void)checkForFullSync;
-(void)snoozeAlertForTask:(Task*)task;
-(Task*)nextDummyForRepeatingTask:(Task*)task;
-(Task *)nextInstanceOfRecuringTask:(Task *)task;
-(Task *)newInstanceForTask:(Task *)task instanceKey:(NSInteger)instanceKeyp forDate:(NSDate *)date;


@end
