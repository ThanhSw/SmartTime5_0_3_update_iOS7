//
//  SmartTimeAppDelegate.h
//  SmartTime
//
//  Created by Nang Le on 10/2/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Setting.h"
#import "Task.h"
#import "TaskManager.h"
#import "ivo_Utilities.h"

@class SmartViewController;
@class Reachability;
@class MyViewController;

@interface SmartTimeAppDelegate : NSObject <UIApplicationDelegate,UIAlertViewDelegate> {
	//IBOutlet UIWindow *window;
	IBOutlet SmartViewController *viewController;
	IBOutlet MyViewController	*navigationController;
	IBOutlet UIActivityIndicatorView		*progressInd;
	IBOutlet UIProgressView					*progressBar;
	
	UIAlertView *progressAlert;
	UIActivityIndicatorView *activityView;
	
	UIView		*startView;
	Task		*urlTask;

	NSArray				*indexContactLetters;
	NSArray				*indexLocationByNameLetters;
	NSArray				*indexLocationByContactLetters;
	BOOL		isLoadingContact;
	BOOL		isLoadingLocation;
	BOOL		isOpeningContactDB;
	BOOL		isPreparingShowingActivityClock;
	BOOL		isLoadingST;
	
	UIApplication	*me;
	UIAlertView		*newSyncGuideAlert;
	NSMutableArray	*tmpTaskList;
	
	NSMutableDictionary *hintSettingDict;
	UIAlertView *introductionBSView;
	
	Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;
	
	UIAlertView *pushAlertView; 
	NSString *pushMessage; 
	
	UIBackgroundTaskIdentifier bgTask;
    
    UIAlertView *finishedAlert;
    UIAlertView *importAlert;
    NSURL *currentURL;
    BOOL  isAgreedToImport;  
    
    NSInteger alertTaskId;
}


@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain)   SmartViewController		*viewController;
@property (nonatomic, retain)	UINavigationController	*navigationController;
@property (nonatomic,retain)	UIActivityIndicatorView	*progressInd;
@property (nonatomic, retain)	NSArray			*indexContactLetters;
@property (nonatomic, retain)	NSArray			*indexLocationByNameLetters;
@property (nonatomic, retain)	NSArray			*indexLocationByContactLetters;
@property (nonatomic,retain)	Task			*urlTask;
@property (nonatomic,assign)	BOOL			isLoadingContact;
@property (nonatomic,assign)	BOOL			isLoadingLocation;
@property (nonatomic, retain)	UIApplication	*me;
@property (nonatomic, retain) NSMutableDictionary *hintSettingDict;
@property (nonatomic, retain) NSString			*pushMessage;
@property (nonatomic, retain) NSURL *currentURL;

@property (nonatomic,assign)	UIBackgroundTaskIdentifier bgTask;

// Removes a Task from the Task of tasks, and also deletes it from the database. There is no undo.
//- (void)removeTaskFromArray:(Task *)task;
// Creates a new TaskType object with default data. 
- (NSInteger)addTask: (Task *)newTask;
//- (NSMutableArray *)getFilterTaskList:(NSString *)queryClause;
//- (void)getFilterTaskList:(NSString *)queryClause;
- (void)getFilterTaskList:(NSString *)queryClause fromList:(NSMutableArray *)fromList;
//- (void) getQuickTaskList;
- (void)getQuickTaskList:(NSString *)filterClause;
- (NSMutableArray *) createFullDoneTaskList;
- (void) getCompletedTasksToday;
- (void)getTaskList;
- (void)getPartTaskList;
+ (CGSize) getTimeSize: (CGFloat) size;

- (void)create_UIActivityIndView:(UIActivityIndicatorViewStyle)style;
- (void)showAcitivityIndicatorThread;
- (void)showAcitivityIndicator;
- (void)stopAcitivityIndicatorThread;
- (void)stopAcitivityIndicator;
- (void)createUpContactDisplayList;
- (void)createUpLocationDisplayList:(BOOL)isSortByName ;
//- (void) createProgressionAlertWithMessage:(NSString *)message withActivity:(BOOL)activity;
-(void)startProgress;
-(void)createTwoLocationDisplayList;
-(void)getFullTaskListForBackup;
- (void)cleanAllTask;
- (BOOL)check24HourFormat;
- (void)cleanAllEvents;
//- (NSMutableArray *)createDummiesListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (NSMutableArray *)createEventListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (NSMutableArray *)createREListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (NSMutableArray *)createADEListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
//- (NSMutableArray *)createNormalTaskListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (NSMutableArray *)createNormalTaskListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate context:(NSInteger)context;
//- (NSMutableArray *)createDTaskListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (NSMutableArray *)createDTaskListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate context:(NSInteger)context;
- (NSMutableArray *)createTaskListFromTheOrder:(NSInteger)fromTheOrder toTheOrder:(NSInteger)toTheOrder;
- (NSInteger)getMaxOrder;

-(void)updateInternetConnectionStatus:(Reachability *)curReach;
-(void)startInitialValuesForSeachingTimeSlot:(Setting *)setting;
-(void)resetBadges:(UIApplication *)application;

-(NSMutableArray *)getTaskListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate taskType:(NSInteger)Task_Pinned isAllTasks:(BOOL)isAllTasks withSearchText:(NSString *)searchText;
-(NSMutableArray *)getTaskListFromUpdateDate:(NSDate *)fromDate toUpdateDate:(NSDate *)toDate isAllTasks:(BOOL)isAllTasks;

-(NSDate *)getToday;
- (void) loadHintSettingDict;
- (void)loadMainViewController;
- (NSString *)hexadecimalDescription:(NSData *)data ;

- (void) startup;

- (NSInteger)getMaxProjectOrder;
- (void)getProjectList;

-(Projects *)calendarWithPrimaryKey:(NSInteger)key;
-(Projects *)calendarWithICalId:(NSString *)key;
- (void)deleteAllTasksBelongCalendar:(NSInteger)calendarId;
-(NSMutableArray *)getADEsListOnlyFromTaskList:(NSMutableArray*)list fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate withSearchText:(NSString *)searchText needSort:(BOOL)needSort;
-(NSMutableArray *)getEventOnlyListFromTaskList:(NSMutableArray*)list fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate withSearchText:(NSString *)searchText needSort:(BOOL)needSort;
-(NSMutableArray *)getAllRecurringADEsFromTaskList:(NSMutableArray*)list withSearchText:(NSString *)searchText;
-(NSMutableArray *)getAllRecurringEventsFromTaskList:(NSMutableArray*)list withSearchText:(NSString *)searchText;

- (void) saveHintSettingDict;

-(void)updateHiddenStatusForTaskBelongCalendarId:(NSInteger)calendarId hidden:(NSInteger)hidden;
- (void)removeAllTasksBelongCalendar:(NSInteger)calendarId;
-(void)addTasksToListFromCalendarId:(NSInteger)calendarId;
-(void)mirgateData;

-(NSMutableArray *)getAllEventsFromList:(NSMutableArray*)list;
-(void)addHiddenTasksEventsToList:(NSMutableArray*)list;
- (NSMutableArray*)getProjectListFromDB;
-(NSMutableArray *)getAllTasksFromList:(NSMutableArray*)list;

@end

