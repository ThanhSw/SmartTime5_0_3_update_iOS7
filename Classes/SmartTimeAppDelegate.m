//
//  SmartTimeAppDelegate.m
//  SmartTime
//
//  Created by Nang Le on 10/2/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "SmartTimeAppDelegate.h"
#import "SmartViewController.h"
#import "Setting.h"
#import "Task.h"
#import "TaskManager.h"
#import "ivo_Utilities.h"
#import "Projects.h"
#import "Contacts.h"
#import <AddressBook/AddressBook.h>
#import "NSDataBase64.h"
#import "Reachability.h"

#import "WeekViewCalController.h"
//#import "GCalSync.h"
#import "ProductListViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MiniProductPageViewController.h"
#import "EKSync.h"
#import "GTMBase64.h"
#import "MyViewController.h"
#import "ReminderSync.h"

//extern GCalSync *_gcalSyncSingleton;
extern SmartTimeView *_smartTimeView;
extern SmartTimeView	*smartView;

extern NSMutableArray	*originalGCalList;
extern NSMutableArray	*originalGCalColorList;
extern NSMutableArray	*originalGCalColorDict;
//extern NSString *importTaskSuccessText;
extern NSString *ST41FirstPopUpMsg;

extern NSString *beginAutoSyncNowText;
extern NSString *STAutoSyncMsg;

//extern NSString *WeekDay[];

//extern NSTimeInterval	dstOffset;

NSInteger			loadingView;
//NSTimeInterval		adjustForNewDue;
NSTimeZone			*App_defaultTimeZone;
BOOL				isDayLigtSavingTime=NO;
NSInteger			gmtSeconds; 
NSString			*STVersion;
NSInteger			instanceKey;//for taskmager uses
NSInteger			dummyKey;
NSTimeInterval		dstOffset;
NSString			*deviceType;
NSDate				*today;

BOOL                isLockingDB;

float		OSVersion;

Reachability* hostReach;
BOOL isInternetConnected=NO;
BOOL stopPushWarning=NO;

BOOL    needStopSync=NO;
BOOL	isSyncing;

BOOL    isStartFromBackground=NO;

SmartViewController *_smartViewController;
SmartTimeAppDelegate		*App_Delegate;
ivo_Utilities		*ivoUtility;

NSString	*dev_token;

TaskManager *taskmanager;

sqlite3 *database;

extern CalendarView *_calendarView;
extern sqlite3_stmt *insert_statement;
extern sqlite3_stmt *init_statement ;
extern sqlite3_stmt *delete_statement;
//static sqlite3_stmt *hydrate_statement = nil;
extern sqlite3_stmt *update_statement;
//extern BOOL _startDayAsMonday;

// integrated code 
@interface SmartTimeAppDelegate (Private)
- (void)createEditableCopyOfDatabaseIfNeeded;
- (void)createInitialIvoDatabaseIfNeeded;
- (void)initializeDatabase;
- (void)getSetting;
//for getting Task list
//- (void) getTaskList;
- (NSUInteger) getTaskCount;

- (void)getContextList;
- (void)getIVoStyleList;
- (void)getRepeatList;
- (void)getContactList;
- (void)getAlertList;
- (void)getWhatList;
//- (void)getTaskMovingStypeList;
- (void)getDeadlineExpandList;
- (void)cleanOldData:(NSInteger)olderDays;
- (void)updateDefaultTasks;
-(void )getSyncTypeList;
-(void)changeDBSettingTable;
//-(void)getDummiesList;
-(void)cleanOldDataFromDB;

@end

static Boolean initializeDatabaseSucess=FALSE;
//for tasks
NSMutableArray	*tasks;
NSMutableArray	*quickTasks;
NSMutableArray	*completedTasksToday;
//for Setting
//Setting			*currentSetting;
//Setting			*currentSettingModifying;

NSMutableArray	*projectList;
NSMutableArray	*contextList;
NSMutableArray	*iVoStyleList;
NSMutableArray	*repeatList;
NSArray			*contactList;
NSMutableArray	*locationList;
NSMutableArray	*alertList;
NSMutableArray  *whatList;
//NSMutableArray	*taskMovingStypeList;
NSMutableArray	*deadlineExpandList;

NSArray			*contactDisplayList;
NSArray			*locationDisplayListByName;
NSArray			*locationDisplayListByContact;

NSMutableArray	*syncTypeList;

//Trung 08102101
BOOL _is24HourFormat = NO;
BOOL _didStartup = NO;
BOOL _inExternalLaunch = NO;
BOOL isCancelledEditFromDetail=NO;


//---for seaching time slots
NSInteger homeSettingHourWEStart;
NSInteger homeSettingHourWEEnd;

NSInteger homeSettingHourNDStart;
NSInteger homeSettingHourNDEnd;

NSInteger homeSettingMinWEStart;
NSInteger homeSettingMinWEEnd;

NSInteger homeSettingMinNDStart;
NSInteger homeSettingMinNDEnd;

NSInteger deskSettingHourWEStart;
NSInteger deskSettingHourWEEnd;

NSInteger deskSettingHourNDStart;
NSInteger deskSettingHourNDEnd;

NSInteger deskSettingMinWEStart;
NSInteger deskSettingMinWEEnd;

NSInteger deskSettingMinNDStart;
NSInteger deskSettingMinNDEnd;

// add 900 senconds just try to know if the time range on week end is enough for task with duration 15 minutes or not.
NSInteger  homeSettingWEStartInSec;
NSInteger  homeSettingWEEndInSec; 

NSInteger  deskSettingWEStartInSec; 
NSInteger  deskSettingWEEndInSec;

NSInteger  numberOfWeekendDays;
NSInteger  startWeekendDay;
NSInteger endWeekendDay;

//-------

extern BOOL _startDayAsMonday;

@implementation SmartTimeAppDelegate
@synthesize window;
@synthesize viewController;
@synthesize navigationController;
@synthesize progressInd;
@synthesize indexContactLetters;
@synthesize indexLocationByNameLetters;
@synthesize indexLocationByContactLetters;
@synthesize urlTask;
@synthesize isLoadingContact;
@synthesize isLoadingLocation;
@synthesize me;
@synthesize hintSettingDict;
@synthesize pushMessage;
@synthesize bgTask;
@synthesize currentURL;

///New for OS4 -------------
//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
//	return YES;
//}

-(NSDate *)getToday{
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit|NSSecondCalendarUnit;
	
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:[NSDate date]];	
	[comps setSecond:0];
	[comps setMinute:0];
	[comps setHour:0];
	
	return [gregorian dateFromComponents:comps];	
	
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    //printf("\n Actived!...");
    
}

- (void)applicationWillResignActive:(UIApplication *)application{
	switch (loadingView) {
		case SMART_VIEW:
		{
		}
			break;
		case CALENDAR_VIEW:
		{
		}
			break;
		case SETTING_VIEW:
			
			break;
		case FOCUS_VIEW:
			
			break;
		case HISTORY_VIEW:
			
			break;
		case WEEK_VIEW:
			
			break;
		case MONTH_VIEW:
			
			break;
		case CONTACT_VIEW:
			
			break;
		default:
			break;
	}
	
	[self resetBadges:application];

}

//- (void)applicationDidEnterBackground:(UIApplication *)application{
	
//}

- (void)applicationDidEnterBackground:(UIApplication *)application {
/*	NSLog(@"Application entered background state.");
	// UIBackgroundTaskIdentifier bgTask is instance variable
//	NSAssert(self->bgTask == UIInvalidBackgroundTask, nil);
	
	bgTask = [application beginBackgroundTaskWithExpirationHandler: ^{
		dispatch_async(dispatch_get_main_queue(), ^{
			[application endBackgroundTask:self->bgTask];
			self->bgTask = UIBackgroundTaskInvalid;
		});
	}];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		while ([application backgroundTimeRemaining] > 1.0) {
			NSString *friend = [self checkForIncomingChat];
			if (friend) {
				UILocalNotification *localNotif = [[UILocalNotification alloc] init];
				if (localNotif) {
					localNotif.alertBody = [NSString stringWithFormat:
											NSLocalizedString(@"%@ has a message for you.", nil), friend];
					localNotif.alertAction = NSLocalizedString(@"Read Msg", nil);
					localNotif.soundName = @"alarmsound.caf";
					localNotif.applicationIconBadgeNumber = 1;
					NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Your Background Task works",ToDoItemKey, @"Message from javacom", MessageTitleKey, nil];
					localNotif.userInfo = infoDict;
					[application presentLocalNotificationNow:localNotif];
					[localNotif release];
					friend = nil;
					break;
				}
			}
		}
		[application endBackgroundTask:self->bgTask];
		self->bgTask = UIInvalidBackgroundTask;
	});
 */
    
    [taskmanager.taskList makeObjectsPerformSelector:@selector(update)];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    CFPreferencesAppSynchronize( kCFPreferencesCurrentApplication );
    
	[_smartViewController startRefreshTasks];

	switch (loadingView) {
		case SMART_VIEW:
			//[_smartTimeView initData:-1];
//			[_smartViewController startRefreshTasks];
			
			break;
		case CALENDAR_VIEW:
//			[_calendarView initData:[NSDate date]];
			break;
		case SETTING_VIEW:
			
			break;
		case FOCUS_VIEW:
			
			break;
		case HISTORY_VIEW:
			
			break;
		case WEEK_VIEW:
			
			break;
		case MONTH_VIEW:
			
			break;
		case CONTACT_VIEW:
			
			break;
			
		default:
			break;
	}
	
#ifdef FREE_VERSION
	taskmanager.currentSetting.numberOfRestartTimes+=1;
	[taskmanager.currentSetting update];
	if((taskmanager.currentSetting.numberOfRestartTimes/4)*4==taskmanager.currentSetting.numberOfRestartTimes || taskmanager.currentSetting.numberOfRestartTimes==1){
		
		MiniProductPageViewController *vwController=[[MiniProductPageViewController alloc] init];
		//vwController.loadingMode=0;
		[self.navigationController pushViewController:vwController animated:NO];
		[vwController release];
	}
#endif
	
	taskmanager.ekSync.rootViewController=self.viewController;
	[taskmanager checkForFullSync];
    
    isStartFromBackground=YES;	
}

//--------------------------

- (void)applicationDidFinishLaunching:(UIApplication *)application {
//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.me=application;
	dummyKey=-2;
	deviceType = [[UIDevice currentDevice].model retain];
	
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appExit:)
    //                                             name:UIApplicationWillTerminateNotification object:nil];
    
	[self loadHintSettingDict];
	
	[self loadMainViewController];
	OSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
	
	if(OSVersion <= 3.0){
		//for checking internet connection
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
		
		//Change the host name here to change the server your monitoring
		hostReach = [[Reachability reachabilityWithHostName: @"www.google.com"] retain];
		[hostReach startNotifer];
		[self updateInternetConnectionStatus: hostReach];
		
		if(!isInternetConnected){
			internetReach = [[Reachability reachabilityForInternetConnection] retain];
			[internetReach startNotifer];
			[self updateInternetConnectionStatus: internetReach];
		}
		
		if(!isInternetConnected){
			wifiReach = [[Reachability reachabilityForLocalWiFi] retain];
			[wifiReach startNotifer];
			[self updateInternetConnectionStatus: wifiReach];
		}
	}else {
		isInternetConnected=YES;
	}

	today=[[NSDate date] retain];
	
#ifdef FREE_VERSION
#else
    /*
	if (OSVersion <= 3.0) {
		if(!isInternetConnected){
			UIAlertView *alrt=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"noInternetConnectionText", @"")
														 message:NSLocalizedString(@"noInternetForPushMsg", @"")
														delegate:nil
											   cancelButtonTitle:NSLocalizedString(@"okText", @"")
											   otherButtonTitles:nil];
			[alrt show];
			[alrt release];
		}
		
		//[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];
		[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
	}else {
		
	}
     */
#endif
	//return YES;
    
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	
	NSLog(@"deviceToken: %@", deviceToken);
	
	dev_token=[[self hexadecimalDescription:deviceToken] retain];
//	dev_token=[[[tmp substringFromIndex:1] substringToIndex:[tmp length]-2] retain];
	printf("\n%s\n",[dev_token UTF8String]);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	NSLog(@"Error in registration. Error: %@", error);
//	printf("\nError in registration. Error: %s", [error UTF8String]);
} 

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
	NSLog(@"user info %@", userInfo);

	//self.pushMessage = nil;
	id alertInfo = [userInfo objectForKey:@"aps"];
	id alert = [alertInfo objectForKey:@"alert"];
	
	//id alert = userInfo;
	if ([alert isKindOfClass:[NSString class]]) {
		self.pushMessage = alert;
	} else if ([alert isKindOfClass:[NSDictionary class]]) {
		self.pushMessage = [alert objectForKey:@"body"];
	}
	if (alert) {
		NSString *appID;//=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"kCFBundleNameKey"];
#ifdef FREE_VERSION

#else
#ifdef ST_BASIC
		appID=@"ST Tasks";
#else
		appID=@"ST Pro";
#endif
#endif		
/*		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSArray *array = [fileManager contentsOfDirectoryAtPath:@"/System/Library/Audio/UISounds/" error:nil];
		for (NSString *soundName in array){
			printf("\n%s",[soundName UTF8String]);
		}
*/		
		NSURL *aFileURL = [NSURL fileURLWithPath:@"/System/Library/Audio/UISounds/alarm.caf" isDirectory:NO];
        
		// If the file exists, calls Core Audio to create a system sound ID.
        if (aFileURL != nil)  {
            SystemSoundID aSoundID;
            OSStatus error = AudioServicesCreateSystemSoundID((CFURLRef)aFileURL, &aSoundID);
            
            if (error == kAudioServicesNoError) { // success
				AudioServicesPlaySystemSound (aSoundID);

            } else {
                NSLog(@"Error loading sound at path!");
            }
        } else {
            NSLog(@"NSURL is nil for path");
        }

		AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);

		
		pushAlertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",appID]//@"ST Pro"
															message:[NSString stringWithFormat:@"%@",self.pushMessage]  delegate:self
												  cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/
												  otherButtonTitles:NSLocalizedString(@"snoozeText", @"")/*snoozeText*/, nil];
		[pushAlertView show];
		[pushAlertView release];
	}
}	

-(void)updateOldDevTokenOnServer:(id)sender
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSString *oldDevToken=(NSString *)sender;
	[ivoUtility updateForOldDevToken:oldDevToken];
	//if(ret){
	//	taskmanager.currentSetting.previousDevToken=dev_token;
	//	[taskmanager.currentSetting update];
	//}
	[pool release];
}

-(void)cleanOldDevTokenOnServer:(id)sender
{
	 NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSString *oldDevToken=(NSString *)sender;
	BOOL ret=[ivoUtility deleteOldAlertsOnServerForDevToken:oldDevToken];
	if(ret){
		taskmanager.currentSetting.previousDevToken=dev_token;
		[taskmanager.currentSetting update];
	}
	[pool release];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notif {
	//NSLog(@"application: didReceiveLocalNotification:");
	//NSString *itemName = [notif.userInfo objectForKey:ToDoItemKey];
	//NSString *messageTitle = [notif.userInfo objectForKey:MessageTitleKey];
	NSString *appID;
#ifdef FREE_VERSION
	
#else
#ifdef ST_BASIC
	appID=@"SmartTime Tasks";
#else
	appID=@"Smart Time";
#endif
#endif	
	
	NSURL *aFileURL = [NSURL fileURLWithPath:@"/System/Library/Audio/UISounds/alarm.caf" isDirectory:NO];
	// If the file exists, calls Core Audio to create a system sound ID.
	/*if (aFileURL != nil)  {
		SystemSoundID aSoundID;
		OSStatus error = AudioServicesCreateSystemSoundID((CFURLRef)aFileURL, &aSoundID);
		
		if (error == kAudioServicesNoError) { // success
			AudioServicesPlaySystemSound (aSoundID);
			
		} else {
			NSLog(@"Error loading sound at path!");
		}
	} else {
		NSLog(@"NSURL is nil for path");
	}
	
	AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
	
	pushAlertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",appID]//@"ST Pro"
											   message:[NSString stringWithFormat:@"%@",notif.alertBody] 
											  delegate:self
									 cancelButtonTitle:NSLocalizedString(@"okText", @"")
									 otherButtonTitles:nil];
	[pushAlertView show];
	[pushAlertView release];
	
	//NSLog(@"Receive Local Notification while the app is still running...");
	//NSLog(@"current notification is %@",notif);
	//application.applicationIconBadgeNumber = notif.applicationIconBadgeNumber-1;
	*/
    
	if (aFileURL != nil)  {
		SystemSoundID aSoundID;
		OSStatus error = AudioServicesCreateSystemSoundID((CFURLRef)aFileURL, &aSoundID);
		
		if (error == kAudioServicesNoError) { // success
			AudioServicesPlaySystemSound (aSoundID);
			
		} else {
			NSLog(@"Error loading sound at path!");
		}
	} else {
		NSLog(@"NSURL is nil for path");
	}
	
	AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
	
	NSDictionary *dict=[notif userInfo];
	alertTaskId=[[dict objectForKey:@"taskId"] intValue];
    
	//Task *task=[ivoUtility getTaskByPrimaryKey:alertTaskId inArray:taskmanager.taskList];
	
	UIAlertView *localAlertView = [[UIAlertView alloc] initWithTitle:appID
                                                             message:[NSString stringWithFormat:@"%@",notif.alertBody] 
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"okText", @"")
                                                   otherButtonTitles:NSLocalizedString(@"snoozeText", @""), nil];
	localAlertView.tag=3;
	[localAlertView show];
	[localAlertView release];
    
}

- (void)loadMainViewController{
	self.viewController=[[SmartViewController alloc] init];
	
	_smartViewController = [self.viewController retain];
	
	self.navigationController = [[MyViewController alloc] initWithRootViewController:self.viewController];
	
	[[self.navigationController view] addSubview:progressInd];
	// Override point for customization after app launch	
	[self.window setFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController=self.navigationController;
    
	//[self.window addSubview:[self.navigationController view]];
	
	[self.window makeKeyAndVisible];
	
	App_Delegate = self;
}

- (NSString *)hexadecimalDescription:(NSData *)data 
{
    NSMutableString *string = [NSMutableString stringWithCapacity:[data length] * 2];
    const uint8_t *bytes = [data bytes];
	
    for (int i = 0; i < [data length]; i++)
        [string appendFormat:@"%02x", (uint32_t)bytes[i]];
	
    return [[string copy] autorelease];
}

- (NSString *)dataFilePath: (NSString *) path
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [paths objectAtIndex:0];
    return [docDirectory stringByAppendingPathComponent:path];
}

- (void) loadHintSettingDict
{
	self.hintSettingDict = [NSMutableDictionary dictionaryWithContentsOfFile:[self dataFilePath:@"HintSettings.dat"]];
	
	if (self.hintSettingDict == nil)
	{
		self.hintSettingDict = [NSMutableDictionary dictionaryWithCapacity:2];
	}
}

- (void) saveHintSettingDict
{
	[self.hintSettingDict writeToFile:[self dataFilePath:@"HintSettings.dat"] atomically:YES];
}


- (void) startup
{

	if (_didStartup)
	{
		return;
	}
	
	// NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	me.networkActivityIndicatorVisible=YES;
	
	_is24HourFormat = [self check24HourFormat];
	
	isOpeningContactDB=NO;
	isLoadingContact=NO;
	isLoadingLocation=NO;
	isPreparingShowingActivityClock=NO;
	isLoadingST=NO;
	instanceKey=-2;
	
    
	[self create_UIActivityIndView:UIActivityIndicatorViewStyleWhiteLarge];
	
	//get STmartTime Version
	STVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	if (STVersion == nil || [STVersion isEqualToString:@""])
	{
		STVersion = @"unknown";
	}
		
	App_defaultTimeZone = [[NSTimeZone defaultTimeZone] retain];
	gmtSeconds=App_defaultTimeZone.secondsFromGMT;
	isDayLigtSavingTime=[App_defaultTimeZone isDaylightSavingTime];
	//gmtSeconds=[App_defaultTimeZone daylightSavingTimeOffset];
	NSDate *date=[App_defaultTimeZone nextDaylightSavingTimeTransition];
	NSDate *date1;
	
	dstOffset=[App_defaultTimeZone daylightSavingTimeOffsetForDate:[date dateByAddingTimeInterval:86400]];
	if(dstOffset==0){
		date1=[App_defaultTimeZone nextDaylightSavingTimeTransitionAfterDate:date];
		dstOffset=[App_defaultTimeZone daylightSavingTimeOffsetForDate:[date1 dateByAddingTimeInterval:-86400]];
	}
	
	ivoUtility=[[ivo_Utilities alloc] init];
	taskmanager = [[TaskManager alloc] init];
	
	//if(!initializeDatabaseSucess){
		[self createEditableCopyOfDatabaseIfNeeded];
		[self initializeDatabase];
	//}
	
#ifdef FREE_VERSION
	//if(taskmanager.currentSetting.isShowedPopup !=1){
	if(taskmanager.currentSetting.isFirstInstlUpdatStart==0){
		taskmanager.currentSetting.isFirstInstlUpdatStart=1;
		//load introduction alert
		UIAlertView *introductionView = [[UIAlertView alloc] initWithTitle:@"Welcome to ST Free!" message:NSLocalizedString(@"introductionLiteText", @"")/*introductionLiteText*/ delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"")/*@"OK"*/ otherButtonTitles:nil];
		
		[introductionView show];
		[introductionView release];
		
		taskmanager.currentSetting.isFirstInstlUpdatStart =1;
		[taskmanager.currentSetting update];
	}
	
#else
#ifdef ST_BASIC
	if(taskmanager.currentSetting.isFirstInstlUpdatStart==0){
		taskmanager.currentSetting.isFirstInstlUpdatStart=1;
		//load introduction alert
		introductionBSView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"STTasksWelcomMsg", @"")/*STTasksWelcomMsg*/ message:NSLocalizedString(@"introductionBasicText", @"")/*introductionBasicText*/ delegate:self cancelButtonTitle:NSLocalizedString(@"laterText", @"")/*laterText*/ otherButtonTitles:nil];
		
		[introductionBSView addButtonWithTitle:NSLocalizedString(@"visitText", @"")/*visitText*/];
		[introductionBSView show];
		[introductionBSView release];
		
		taskmanager.currentSetting.isFirstInstlUpdatStart =1;
		[taskmanager.currentSetting update];
	}
	
#else
	if(taskmanager.currentSetting.isFirstInstlUpdatStart==0){
		taskmanager.currentSetting.isFirstInstlUpdatStart=1;
		[taskmanager.currentSetting update];

		/*
		newSyncGuideAlert=[[UIAlertView alloc] initWithTitle:forGcalSyncText message:syncGuideMessages delegate:self cancelButtonTitle:okText otherButtonTitles:nil];
		[newSyncGuideAlert addButtonWithTitle:syncGuideText];
		[newSyncGuideAlert show];
		[newSyncGuideAlert release];
		 */
	}
#endif	
#endif
	//3.6 for PNS
	if ([dev_token length]>0 && [taskmanager.currentSetting.previousDevToken length]>0 && ![dev_token isEqualToString:taskmanager.currentSetting.previousDevToken]){
		//remove the old data with the unused token on server
		NSString *oldDevToken=[NSString stringWithString:taskmanager.currentSetting.previousDevToken];
		//[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(cleanOldDevTokenOnServer:) userInfo:oldDevToken repeats:YES];
		[NSThread detachNewThreadSelector:@selector(updateOldDevTokenOnServer:) toTarget:self withObject:oldDevToken];
	}else if([taskmanager.currentSetting.previousDevToken length]==0){
		taskmanager.currentSetting.previousDevToken=dev_token;
		[taskmanager.currentSetting update];
	}
	
	_startDayAsMonday = (taskmanager.currentSetting.weekStartDay==START_MONDAY?YES:NO);

	App_Delegate = self;
	[NSThread detachNewThreadSelector:@selector(getRemainList) toTarget:self withObject:nil];

	isLoadingST=NO;
	[progressInd stopAnimating];
	
	_didStartup = YES;
	
	taskmanager.ekSync.rootViewController=self.viewController;
    taskmanager.reminderSync.rootViewController=self.viewController;
    
    if (taskmanager.currentSetting.enableSyncICal==1 && taskmanager.currentSetting.autoICalSync==1) {
        taskmanager.currentSetting.autoICalSync=0;
        [taskmanager.currentSetting update];
        
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"beginAutoSyncNowText",@"")
                                                          message:NSLocalizedString(@"STAutoSyncMsg",@"")
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"noText",@"")
                                                otherButtonTitles:NSLocalizedString(@"yesText",@""), nil];
        alertView.tag=9;
        [alertView show];
        [alertView release];

    }

	//[taskmanager checkForFullSync];

    if (taskmanager.currentSetting.firstStart41==0) {
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@""
                                                          message:NSLocalizedString(@"ST41FirstPopUpMsg",@"")
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"okText", @"")
                                                otherButtonTitles:NSLocalizedString(@"syncGuideText", @""), nil];
        alertView.tag=200;
        [alertView show];
        [alertView release];
        
        taskmanager.currentSetting.firstStart41=1;
        [taskmanager.currentSetting update];
    }
    
	//[pool release];
}

-(void)getRemainList{
	 NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[self getSyncTypeList];
	[self getContextList];
	[self getIVoStyleList];
	[self getRepeatList];
	[self getAlertList];
	[self getWhatList];
	[self getDeadlineExpandList];	
	[pool release];
}

-(void)changeDBSettingTable{
	if(initializeDatabaseSucess){
		//sqlite3_exec(database, "CREATE TABLE RE_Dummies (task_ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,Task_Name TEXT,Task_Description TEXT,Task_Pinned NUMERIC,Task_Priority NUMERIC,Task_StartTime NUMERIC, Task_Status NUMERIC,Task_Completed NUMERIC,Task_TypeID NUMERIC,Task_What NUMERIC,Task_Who NUMERIC,Task_Where NUMERIC,Task_When NUMERIC,Task_HowLong NUMERIC,Task_Project NUMERIC,Task_EndTime NUMERIC,Task_DueStartDate NUMERIC, Task_DueEndDate NUMERIC,Task_DateUpdate NUMERIC, Task_TypeUpdate NUMERIC, Task_Default NUMERIC,Task_RepeatID NUMERIC,Task_RepeatTimes NUMERIC,Task_Location TEXT,Task_Contact TEXT,Task_AlertID NUMERIC,Task_OriginalWhere NUMERIC,Task_DeadLine NUMERIC,Task_NotEalierThan NUMERIC,Task_IsUseDeadLine NUMERIC,Set_Resvr5 TEXT,Set_Resvr4 TEXT,Set_Resvr6 NUMERIC,Set_Resvr3 TEXT,Set_Resvr7 NUMERIC,Set_Resvr2 TEXT,Set_Resvr1 TEXT,Set_Resvr8 NUMERIC,filledDummiesToDate NUMERIC)", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN isFirstInstlUpdatStart NUMERIC;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN snapImage BLOB;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN syncWindowStart NUMERIC DEFAULT 1;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN syncWindowEnd NUMERIC DEFAULT 2;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN findTimeSlotInNumberOfDays NUMERIC;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN numberOfRestartTimes NUMERIC;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN adjustTimeIntervalForNewDue NUMERIC;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN badgeType NUMERIC;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN weekStartDay NUMERIC;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN startWorkingWDay NUMERIC;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN endWorkingWDay NUMERIC;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN previousDevToken TEXT;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN isNeedShowPushWarning TEXT;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN snoozeDuration NUMERIC;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN snoozeUnit NUMERIC;", nil, nil, nil);
		
		//TD Sync
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN toodledoToken TEXT;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN toodledoTokenTime NUMERIC;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN toodledoUserId TEXT;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN toodledoUserName TEXT;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN toodledoPassword TEXT;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN toodledoKey TEXT;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN toodledoSyncTime NUMERIC;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN toodledoSyncType NUMERIC;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN toodledoDeletedFolders TEXT;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN isFirstTimeToodledoSync NUMERIC;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN toodledoDeletedTasks TEXT;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN enableSyncToodledo NUMERIC;", nil, nil, nil);
		//enableSyncICal
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN enableSyncICal NUMERIC;", nil, nil, nil);
		//autoICalSync
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN autoICalSync NUMERIC;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN autoTDSync NUMERIC;", nil, nil, nil);
		//hasToodledoFirstTimeSynced
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN hasToodledoFirstTimeSynced NUMERIC;", nil, nil, nil);
		//deletedICalEvents
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN deletedICalEvents TEXT;", nil, nil, nil);
		//iCalLastSyncTime
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN iCalLastSyncTime NUMERIC;", nil, nil, nil);
		//defaultProjectId
		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN defaultProjectId NUMERIC;", nil, nil, nil);
        //deletedICalCalendars
        sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN deletedICalCalendars TEXT;", nil, nil, nil);
        //syncEventOnly
        sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN syncEventOnly NUMERIC DEFAULT 1;", nil, nil, nil);
        //firstStart41
        sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN firstStart41 NUMERIC;", nil, nil, nil);
        //wasHardClosed
        sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN wasHardClosed NUMERIC;", nil, nil, nil);
        //enabledReminderSync
        sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN enabledReminderSync NUMERIC;", nil, nil, nil);
        //deletedReminderLists
        sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN deletedReminderLists TEXT;", nil, nil, nil);
        sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN deletedReminders TEXT;", nil, nil, nil);
        
//		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN startWorkingWDay NUMERIC;", nil, nil, nil);
//		sqlite3_exec(database, "ALTER TABLE iVo_Setting ADD COLUMN endWorkingWDay NUMERIC;", nil, nil, nil);
		
		sqlite3_exec(database, "ALTER TABLE iVo_Tasks ADD COLUMN filledDummiesToDate NUMERIC;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Tasks ADD COLUMN taskOrder NUMERIC;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Tasks ADD COLUMN specifiedAlertTime NUMERIC;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Tasks ADD COLUMN alertByDeadline NUMERIC;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Tasks ADD COLUMN PNSKey TEXT;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Tasks ADD COLUMN isAdjustedSpecifiedDate NUMERIC;", nil, nil, nil);
		
		//toodledoID
		sqlite3_exec(database, "ALTER TABLE iVo_Tasks ADD COLUMN toodledoID NUMERIC;", nil, nil, nil);
		//toodledoHasStart
		sqlite3_exec(database, "ALTER TABLE iVo_Tasks ADD COLUMN toodledoHasStart NUMERIC;", nil, nil, nil);
		//isHidden
		sqlite3_exec(database, "ALTER TABLE iVo_Tasks ADD COLUMN isHidden NUMERIC;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Tasks ADD COLUMN iCalCalendarName TEXT;", nil, nil, nil);
		
		sqlite3_exec(database, "ALTER TABLE iVo_Tasks ADD COLUMN iCalIdentifier TEXT;", nil, nil, nil);
		//iCalCalendarName
        //alertIndex
        sqlite3_exec(database, "ALTER TABLE iVo_Tasks ADD COLUMN alertIndex NUMERIC;", nil, nil, nil);
        //alertUnit
        sqlite3_exec(database, "ALTER TABLE iVo_Tasks ADD COLUMN alertUnit NUMERIC;", nil, nil, nil);
        //alertBasedOn
        sqlite3_exec(database, "ALTER TABLE iVo_Tasks ADD COLUMN alertBasedOn NUMERIC;", nil, nil, nil);
        //hasAlert
        sqlite3_exec(database, "ALTER TABLE iVo_Tasks ADD COLUMN hasAlert NUMERIC;", nil, nil, nil);
        //taskRepeatStyle
        sqlite3_exec(database, "ALTER TABLE iVo_Tasks ADD COLUMN taskRepeatStyle NUMERIC;", nil, nil, nil);
        //reminderIdentifier
        sqlite3_exec(database, "ALTER TABLE iVo_Tasks ADD COLUMN reminderIdentifier TEXT;", nil, nil, nil);
        
		sqlite3_exec(database, "ALTER TABLE iVo_Projects ADD COLUMN iCalCalendarName TEXT;", nil, nil, nil);
		
		sqlite3_exec(database, "ALTER TABLE iVo_Projects ADD COLUMN toodledoFolderKey NUMERIC;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Projects ADD COLUMN builtIn NUMERIC;", nil, nil, nil);
		sqlite3_exec(database, "ALTER TABLE iVo_Projects ADD COLUMN enableTDSync NUMERIC;", nil, nil, nil);
		//enableICalSync
		sqlite3_exec(database, "ALTER TABLE iVo_Projects ADD COLUMN enableICalSync NUMERIC;", nil, nil, nil);
		//groupId
		sqlite3_exec(database, "ALTER TABLE iVo_Projects ADD COLUMN groupId NUMERIC;", nil, nil, nil);
		//projectOrder
		sqlite3_exec(database, "ALTER TABLE iVo_Projects ADD COLUMN projectOrder NUMERIC;", nil, nil, nil);
		//inVisible
		sqlite3_exec(database, "ALTER TABLE iVo_Projects ADD COLUMN inVisible NUMERIC;", nil, nil, nil);
		//iCalIdentifier
		sqlite3_exec(database, "ALTER TABLE iVo_Projects ADD COLUMN iCalIdentifier TEXT;", nil, nil, nil);
        //reminderIdentifier
        sqlite3_exec(database, "ALTER TABLE iVo_Projects ADD COLUMN reminderIdentifier TEXT;", nil, nil, nil);
        
//		sqlite3_exec(database, "ALTER TABLE iVo_Tasks ADD COLUMN isNeedAdjustDST NUMERIC;", nil, nil, nil);
	}
}

-(void)startInitialValuesForSeachingTimeSlot:(Setting *)setting{
	homeSettingHourWEStart=[ivoUtility getHour:setting.homeTimeWEStart];
	homeSettingHourWEEnd=[ivoUtility getHour:setting.homeTimeWEEnd];
	
	homeSettingHourNDStart=[ivoUtility getHour:setting.homeTimeNDStart];
	homeSettingHourNDEnd=[ivoUtility getHour:setting.homeTimeNDEnd];
	
	homeSettingMinWEStart=[ivoUtility getMinute:setting.homeTimeWEStart];
	homeSettingMinWEEnd=[ivoUtility getMinute:setting.homeTimeWEEnd];
	
	homeSettingMinNDStart=[ivoUtility getMinute:setting.homeTimeNDStart];
	homeSettingMinNDEnd=[ivoUtility getMinute:setting.homeTimeNDEnd];
	
	deskSettingHourWEStart=[ivoUtility getHour:setting.deskTimeWEStart];
	deskSettingHourWEEnd=[ivoUtility getHour:setting.deskTimeWEEnd];
	
	deskSettingHourNDStart=[ivoUtility getHour:setting.deskTimeStart];
	deskSettingHourNDEnd=[ivoUtility getHour:setting.deskTimeEnd];
	
	deskSettingMinWEStart=[ivoUtility getMinute:setting.deskTimeWEStart];
	deskSettingMinWEEnd=[ivoUtility getMinute:setting.deskTimeWEEnd];
	
	deskSettingMinNDStart=[ivoUtility getMinute:setting.deskTimeStart];
	deskSettingMinNDEnd=[ivoUtility getMinute:setting.deskTimeEnd];
	
	// add 900 senconds just try to know if the time range on week end is enough for task with duration 15 minutes or not.
	homeSettingWEStartInSec= homeSettingHourWEStart*3600 +homeSettingMinWEStart*60 + 900;
	homeSettingWEEndInSec= homeSettingHourWEEnd*3600 + homeSettingMinWEEnd*60; 
	
	deskSettingWEStartInSec=deskSettingHourWEStart*3600 + deskSettingMinWEStart*60 + 900; 
	deskSettingWEEndInSec=deskSettingHourWEEnd*3600 + deskSettingMinWEEnd*60 ;
	
	startWeekendDay=setting.endWorkingWDay+1;
	if(startWeekendDay>7)
		startWeekendDay=0;
	
	endWeekendDay=setting.startWorkingWDay-1;
	if(endWeekendDay<1)
		endWeekendDay=7;
	
	numberOfWeekendDays=setting.endWorkingWDay+1-setting.startWorkingWDay;
	if(numberOfWeekendDays>0){
		numberOfWeekendDays=7-numberOfWeekendDays;
	}else {
		numberOfWeekendDays=abs(numberOfWeekendDays);
	}
}

#pragma mark AlertView delegate
- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex{
	//ILOG(@"[SmartTimeView alertView\n")
	if(alertVw.tag==9) {
        if (buttonIndex==1) {
            taskmanager.currentSetting.autoICalSync=1;
            [taskmanager checkForFullSync];
        }else{
            taskmanager.currentSetting.autoICalSync=0;
        }
        [taskmanager.currentSetting update];
    }else if(alertVw.tag==3) {
		if (buttonIndex==1) {
			Task *task=[ivoUtility getTaskByPrimaryKey:alertTaskId inArray:taskmanager.taskList];
			if (task) {
				[taskmanager snoozeAlertForTask:task];
			}
		}	
	}else if(alertVw.tag==200){
        if (buttonIndex==1) {
            NSURL *url = [[NSURL alloc] initWithString:@"http:/leftcoastlogic.com/smarttime/sync"];
            [[UIApplication sharedApplication] openURL:url];
            [url release];
        }
    }else if([alertVw isEqual:importAlert] && buttonIndex==1){
		isAgreedToImport=YES;
		[self application:(UIApplication *)App_Delegate handleOpenURL:self.currentURL];
		
	}else if([alertVw isEqual:finishedAlert] && buttonIndex==0) {
		exit(0);
	}else if([alertVw isEqual:newSyncGuideAlert]){
		switch (buttonIndex) {
			case 0:
				
				break;
			case 1:
			{
				NSURL *url = [[NSURL alloc] initWithString:@"http://leftcoastlogic.com/sync"];
				[[UIApplication sharedApplication] openURL:url];
				[url release];
			}
				break;
		}
		
	}else if([alertVw isEqual:introductionBSView] && buttonIndex==1) {//
		
		NSString *bodyStr = [NSString stringWithFormat:@"http://leftcoastlogic.com/sttm"];
		NSString *encoded = [bodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSURL *url = [[NSURL alloc] initWithString:encoded];
		
		[[UIApplication sharedApplication] openURL:url];
		
		[url release];
		
		/*switch (buttonIndex) {
			case 0:
			{
				NSURL *url = [[NSURL alloc] initWithString:@"http://www.leftcoastlogic.com/STInfo/"];
				[[UIApplication sharedApplication] openURL:url];
				[url release];
				
			}
				break;
			case 1:
			{
				NSString *bodyStr = [NSString stringWithFormat:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=295845767&mt=8"];
				NSString *encoded = [bodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				NSURL *url = [[NSURL alloc] initWithString:encoded];
				
				[[UIApplication sharedApplication] openURL:url];
				
				[url release];
			}
				break;
		}
		 */
	}else if([alertVw isEqual:pushAlertView] && buttonIndex==1) {
		//snooze for this alert
        NSMutableArray *sourceList=[NSMutableArray arrayWithArray:taskmanager.taskList];
		for (Task *task in sourceList){
			if([task.taskName isEqualToString:self.pushMessage] && [task.PNSKey length]>0){
				
				Task *tmp=[[[Task alloc] init] autorelease];
				[ivoUtility copyTask:task toTask:tmp isIncludedPrimaryKey:YES];
				
				NSString *alertPNSStr=[ivoUtility getAPNSAlertFromTask:tmp];
				
				NSInteger unit=taskmanager.currentSetting.snoozeUnit;
				
				NSTimeInterval snoozeDuration=taskmanager.currentSetting.snoozeDuration*(unit==0?60:unit==1?3600:unit==2?86400:7*86400);
				
				if(tmp.taskPinned==1){//event, update start time
					tmp.taskStartTime=[tmp.taskStartTime dateByAddingTimeInterval:snoozeDuration];
				}else {//task, update specified date
					tmp.specifiedAlertTime=[tmp.specifiedAlertTime dateByAddingTimeInterval:snoozeDuration];
				}

				[ivoUtility uploadAlertsForTasks:tmp isAddNew:NO withPNSAlert:alertPNSStr oldDevToken:dev_token oldTaskPNSID:tmp.PNSKey];
				
				//[tmp release];
			}
		}
	}

}

-(void)startProgress{
	 NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[progressAlert show];
	isLoadingST=YES;
	[pool release];
}

-(void) initSystem{

}
- (void)dealloc {
	self.hintSettingDict = nil;
	
    [viewController release];
	[navigationController release];
	[window release];
	[tasks release];
	[taskmanager release];
	[projectList release];
	[contextList release];
	[iVoStyleList release];
	[repeatList release];
	[contactList release];
	[locationList release];
	[alertList release];
	[whatList release];
	[progressInd release];
	[ivoUtility release];
	[urlTask release];
	[progressBar release];
	[progressAlert release];
	[activityView release];
	[syncTypeList release];
	
	//if (_gcalSyncSingleton != nil)
	//{
	//	[_gcalSyncSingleton release];
	//}
	
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
	
	[super dealloc];
}

// Creates a writable copy of the bundled default database in the application Documents directory.
- (void)createEditableCopyOfDatabaseIfNeeded {
	BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"IvoDatabase.sql"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
    // The writable database does not exist, so copy the default to the appropriate location.
  	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"IvoDatabase.sql"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }	
	
}

// Creates a writable copy of the bundled default database in the application Documents directory.
- (void)createInitialIvoDatabaseIfNeeded {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"/../../IvoDatabase.sql"];
	
	//char buf[256];
	//[writableDBPath getCString:buf];
	//printf("writableDBPath = %s\n", buf);
	
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"IvoDatabase_initial.sql"];
	//[defaultDBPath getCString:buf];
	//printf("defaultDBPath = %s\n", buf);
	
	
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

// Open the database connection and retrieve minimal information for all objects.
- (void)initializeDatabase {
	projectList=[[NSMutableArray alloc] init];
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"IvoDatabase.sql"];
	
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
//        printf("\nOpen database success!");
        
        //sqlite3_busy_timeout(database,5000);
		initializeDatabaseSucess=true;
		
		[self changeDBSettingTable];
        
		//get setting first
		[self getSetting];
        [self getProjectList];

		//new in 3.7
		[self startInitialValuesForSeachingTimeSlot:taskmanager.currentSetting];
		
		//show default tasks for the first time use
		if(taskmanager.currentSetting.isFirstTimeStart==1){
			[self updateDefaultTasks];
			taskmanager.currentSetting.isFirstTimeStart=0;
			[taskmanager.currentSetting update];
		}
		
		//clean old data based on setting
		//if(taskmanager.currentSetting.cleanOldDayCount>0){
			//if user enable clean data function, we will get tasklist while cleaning
		//	[self cleanOldData:taskmanager.currentSetting.cleanOldDayCount];
		//}else {
			//get task list
			[self getTaskList];
		//}
        /*
        for (Task *task in taskmanager.taskList) {
            if (task.primaryKey>0) {
                if (task.alertIndex<0) {
                    task.alertIndex=0;
                    [task update];
                }else if(task.alertIndex>15){
                    task.alertIndex=15;
                    [task update];
                }
            }
        }
         */
        BOOL needUpdateDefaultProject=YES;
        
        NSMutableArray *projects=[NSMutableArray arrayWithArray:projectList];
        for(Projects *proj in projects){
            if (proj.primaryKey==taskmanager.currentSetting.projectDefID) {
                needUpdateDefaultProject=NO;
                break;
            }
        }
        
        if (needUpdateDefaultProject) {
            taskmanager.currentSetting.projectDefID=[[projects objectAtIndex:0] primaryKey];
            [taskmanager.currentSetting update];
        }
        
        [self mirgateData];

		//[self getDummiesList];
	} else {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
		initializeDatabaseSucess=false;
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
        // Additional error handling, as appropriate...
    }
}

-(void)mirgateData{
    
    NSMutableArray *projects=[NSMutableArray arrayWithArray:projectList];
    
    if (taskmanager.currentSetting.firstStart41<2 && projects.count==12) {
        //update projects ids for tasks.
        NSMutableArray *sourceList=[NSMutableArray arrayWithArray:taskmanager.taskList];
        NSMutableArray *sourceListTmp;//=[NSMutableArray arrayWithArray:sourceList];
        for (NSInteger i=0;i<12;i++) {
            sourceListTmp=[NSMutableArray arrayWithArray:sourceList];
            Projects *project = [projects objectAtIndex:i];
            switch (i) {
                case 0://Smarttime
                    project.colorId=0;
                    project.groupId=1;

                    break;
                case 1://Urgent
                    project.colorId=1;
                    project.groupId=2;
                    
                    break;
                case 2://Family
                    project.colorId=1;
                    project.groupId=0;
                    
                    break;
                case 3://Recreation
                    project.colorId=3;
                    project.groupId=3;
                    
                    break;
                case 4://Errands
                    project.colorId=4;
                    project.groupId=2;
                    
                    break;
                case 5://Lavender
                    project.colorId=5;
                    project.groupId=1;
                    
                    break;
                case 6://Industrial
                    project.colorId=0;
                    project.groupId=0;
                    
                    break;
                case 7://Violet
                    project.colorId=6;
                    project.groupId=2;
                    
                    break;
                case 8://Mustard
                    project.colorId=4;
                    project.groupId=2;
                    
                    break;
                case 9://Emerald
                    project.colorId=3;
                    project.groupId=1;
                    
                    break;
                case 10://Grey Flannel
                    project.colorId=5;
                    project.groupId=3;
                    
                    break;
                case 11://PurpleHaze
                    project.colorId=5;
                    project.groupId=0;
                    
                    break;
                default:
                    break;
            }
            
            for (Task *task in sourceListTmp) {
                if (task.taskProject==i) {
                    task.taskProject=project.primaryKey;
                    [task update];
                    [sourceList removeObject:task];
                }
            }

            [project update];
        }
        
        taskmanager.currentSetting.firstStart41=2;
        [taskmanager.currentSetting update];
        
    }
    
}

// get Setting list
- (void)getSetting{
	if(initializeDatabaseSucess){
		// Get the primary key for all setings.
		const char *sql = "SELECT Set_ID FROM iVo_Setting Where Set_ID=1";
		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				int primaryKey = sqlite3_column_int(statement, 0);
				// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
				// autorelease is slightly more expensive than release. This design choice has nothing to do with
				// actual memory management - at the end of this block of code, all the settings objects allocated
				// here will be in memory regardless of whether we use autorelease or release, because they are
				// retained by the settings array.
				Setting *currentSettingLoad= [[Setting alloc] getInfoWithPrimaryKey:primaryKey database:database];

/*
#ifdef FREE_VERSION
				currentSettingLoad.numberOfRestartTimes+=1;
				[currentSettingLoad update];
				if((currentSettingLoad.numberOfRestartTimes/4)*4==currentSettingLoad.numberOfRestartTimes || currentSettingLoad.numberOfRestartTimes==1){
					
					MiniProductPageViewController *vwController=[[MiniProductPageViewController alloc] init];
					vwController.loadingMode=0;
					[self.navigationController pushViewController:vwController animated:NO];
					[vwController release];
				}
#endif
*/								
				taskmanager.currentSetting=currentSettingLoad;
				[currentSettingLoad release];
			}
		}
		
		sqlite3_finalize(statement);		
	}else
		printf("Database is not opened!");	
}

// get project list
- (void)getProjectList{
	if(initializeDatabaseSucess){
		[projectList removeAllObjects];
		
		// Get the primary key for all setings.
		//const char *sql = "SELECT Proj_ID FROM iVo_Projects";
		//EKSync
		const char *sql = "SELECT Proj_ID FROM iVo_Projects ORDER BY projectOrder ASC";
		
		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				int primaryKey = sqlite3_column_int(statement, 0);
				// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
				// autorelease is slightly more expensive than release. This design choice has nothing to do with
				// actual memory management - at the end of this block of code, all the settings objects allocated
				// here will be in memory regardless of whether we use autorelease or release, because they are
				// retained by the settings array.
				Projects *project= [[Projects alloc] getInfoWithPrimaryKey:primaryKey database:database];
				[projectList addObject:project];
				[project release];
			}
		}
		
		/*4.1
		if(projectList.count==6){
			Projects *project= [[Projects alloc] init];
			project.projName=[NSString stringWithFormat:@"Industrial"];
			
			project.primaryKey=[project prepareNewRecordIntoDatabase:database];
			[project update];
			[projectList addObject:project];
			[project release];
			
			project= [[Projects alloc] init];
			project.projName=[NSString stringWithFormat:@"Violet"];
			
			project.primaryKey=[project prepareNewRecordIntoDatabase:database];
			[project update];
			[projectList addObject:project];
			[project release];

			project= [[Projects alloc] init];
			project.projName=[NSString stringWithFormat:@"Mustard"];
			
			project.primaryKey=[project prepareNewRecordIntoDatabase:database];
			[project update];
			[projectList addObject:project];
			[project release];

			project= [[Projects alloc] init];
			project.projName=[NSString stringWithFormat:@"Emeralds"];
			
			project.primaryKey=[project prepareNewRecordIntoDatabase:database];
			[project update];
			[projectList addObject:project];
			[project release];

			project= [[Projects alloc] init];
			project.projName=[NSString stringWithFormat:@"Grey Flannel"];
			
			project.primaryKey=[project prepareNewRecordIntoDatabase:database];
			[project update];
			[projectList addObject:project];
			[project release];

			project= [[Projects alloc] init];
			project.projName=[NSString stringWithFormat:@"Purple Haze"];
			
			project.primaryKey=[project prepareNewRecordIntoDatabase:database];
			[project update];
			[projectList addObject:project];
			[project release];
			
		}
		
		
		//EK Sync - upgrade Project table to v4.1 (update project color to field Set_Rerv3)
		BOOL needUpgrade = YES;
		
		for (Projects *project in projectList)
		{
			if (project.colorId != 0)
			{
				needUpgrade = NO;
			}
		}
		
		if (projectList.count > 0 && needUpgrade)
		{
			for (int i=0; i<projectList.count; i++)
			{
				Projects *project = [projectList objectAtIndex:i];
				[project setColorId:i];

				[project setDirty:YES];
				
				[project update];
			}
		}
		*/
		
		sqlite3_finalize(statement);		
	}else
		printf("Database is not opened!");
}

- (NSMutableArray*)getProjectListFromDB{
    
    NSMutableArray *ret=[NSMutableArray array];
	if(initializeDatabaseSucess){
		
		// Get the primary key for all setings.
		//const char *sql = "SELECT Proj_ID FROM iVo_Projects";
		//EKSync
		const char *sql = "SELECT Proj_ID FROM iVo_Projects ORDER BY projectOrder ASC";
		
		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				int primaryKey = sqlite3_column_int(statement, 0);
				// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
				// autorelease is slightly more expensive than release. This design choice has nothing to do with
				// actual memory management - at the end of this block of code, all the settings objects allocated
				// here will be in memory regardless of whether we use autorelease or release, because they are
				// retained by the settings array.
				Projects *project= [[Projects alloc] getInfoWithPrimaryKey:primaryKey database:database];
				[ret addObject:project];
				[project release];
			}
		}
		
		
		sqlite3_finalize(statement);		
	}else
		printf("Database is not opened!");
    
    return ret;
}

// get Task list
- (void)getTaskList{
	NSMutableArray *taskList=[[NSMutableArray alloc] init];
	
	if(initializeDatabaseSucess){
		
		NSString *sql=[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks WHERE Task_Completed=0 AND (isHidden=0 OR isHidden ISNULL OR length(isHidden)=0)"];
		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			//sqlite3_bind_int(statement,1, completed);
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				int primaryKey = sqlite3_column_int(statement, 0);
				// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
				// autorelease is slightly more expensive than release. This design choice has nothing to do with
				// actual memory management - at the end of this block of code, all the tasks objects allocated
				// here will be in memory regardless of whether we use autorelease or release, because they are
				// retained by the tasks array.
				Task *task = [[Task alloc] getInfoWithPrimaryKey:primaryKey database:database];
				task.taskKey=task.primaryKey;
				[taskList addObject:task];
				[task release];
			}
		}
		
		sqlite3_finalize(statement);		
	}else
		printf("Database can not open!");
		
	taskmanager.taskList=taskList;
	[taskList release];
	
//	[self getPartTaskList];	
//	[taskmanager refreshTaskListFromPartList];
//	printf("\nend get task list: %s",[[[NSDate date] description] UTF8String]);
	//[ivoUtility printTask:taskmanager.taskList];
}

- (void)getPartTaskList{
	
	NSMutableArray *normalTasks=[self createNormalTaskListFromDate:nil toDate:nil context:-1];
	taskmanager.normalTaskList=normalTasks;
	[normalTasks release];
	
	NSMutableArray *dTasks=[self createDTaskListFromDate:nil toDate:nil context:-1];
	taskmanager.dTaskList=dTasks;
	[dTasks release];
	
	NSMutableArray *events=[self createEventListFromDate:nil toDate:nil];
	taskmanager.eventList=events;
	[events release];
	
	NSMutableArray *res=[self createREListFromDate:nil toDate:nil];
	taskmanager.REList=res;
	[res release];
	
	NSMutableArray *ades=[self createADEListFromDate:nil toDate:nil];
	taskmanager.adeList=ades;
	[ades release];
	
	//[ivoUtility printTask:taskmanager.taskList];
}

- (NSMutableArray *)createTaskListFromTheOrder:(NSInteger)fromTheOrder toTheOrder:(NSInteger)toTheOrder{
	NSMutableArray *taskList=[[NSMutableArray alloc] init];
	
	if(initializeDatabaseSucess){
		
		NSString *sql;
		if(fromTheOrder <0 && toTheOrder<0){
			sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks WHERE Task_Completed=0"];
		}else {
            sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where taskOrder BETWEEN %ld AND %d",(long)fromTheOrder,toTheOrder];
		}
		
		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			//sqlite3_bind_int(statement,1, completed);
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				int primaryKey = sqlite3_column_int(statement, 0);
				// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
				// autorelease is slightly more expensive than release. This design choice has nothing to do with
				// actual memory management - at the end of this block of code, all the tasks objects allocated
				// here will be in memory regardless of whether we use autorelease or release, because they are
				// retained by the tasks array.
				Task *task = [[Task alloc] getInfoWithPrimaryKey:primaryKey database:database];
				task.taskKey=task.primaryKey;
				[taskList addObject:task];
				[task release];
			}
		}
		
		sqlite3_finalize(statement);		
	}else
		printf("Database can not open!");
	
	return taskList;	
}

- (NSInteger)getMaxOrder{
	NSInteger maxOrder=0;
	if(initializeDatabaseSucess){
		
		NSString *sql;
			sql =[NSString stringWithFormat:@"SELECT MAX(taskOrder) FROM iVo_Tasks WHERE Task_Completed=0"];
		
		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			//sqlite3_bind_int(statement,1, completed);
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				maxOrder = sqlite3_column_int(statement, 0);
				// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
				// autorelease is slightly more expensive than release. This design choice has nothing to do with
				// actual memory management - at the end of this block of code, all the tasks objects allocated
				// here will be in memory regardless of whether we use autorelease or release, because they are
				// retained by the tasks array.
			}
		}
		
		sqlite3_finalize(statement);		
	}else
		printf("Database can not open!");
	
	return maxOrder;	
}

- (NSInteger)getMaxProjectOrder{
	NSInteger maxOrder=0;
	if(initializeDatabaseSucess){
		
		NSString *sql;
		sql =[NSString stringWithFormat:@"SELECT MAX(projectOrder) FROM iVo_Projects"];
		
		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			//sqlite3_bind_int(statement,1, completed);
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				maxOrder = sqlite3_column_int(statement, 0);
				// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
				// autorelease is slightly more expensive than release. This design choice has nothing to do with
				// actual memory management - at the end of this block of code, all the tasks objects allocated
				// here will be in memory regardless of whether we use autorelease or release, because they are
				// retained by the tasks array.
			}
		}
		
		sqlite3_finalize(statement);		
	}else
		printf("Database can not open!");
	
	return maxOrder;	
}

//rule: either fromDate and toDate are nil or both have values
- (NSMutableArray *)createEventListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate{
	NSMutableArray *events=[[NSMutableArray alloc] init];
	
	if(initializeDatabaseSucess){
		NSDate *fromDt=fromDate;
		NSDate *toDt=toDate;
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit|NSSecondCalendarUnit;
		
		NSDateComponents *comps;
		if(fromDate){
			comps = [gregorian components:unitFlags fromDate:fromDate];	
			[comps setSecond:0];
			[comps setMinute:0];
			[comps setHour:0];
			fromDt=[gregorian dateFromComponents:comps];
		}
		double fromDateTimeInterval=[fromDt timeIntervalSince1970] + gmtSeconds;

		if(toDate){
			comps = [gregorian components:unitFlags fromDate:toDate];	
			[comps setSecond:60];
			[comps setMinute:59];
			[comps setHour:23];
			toDt=[gregorian dateFromComponents:comps];
		}
		double toDateTimeInterval=[toDt timeIntervalSince1970] +gmtSeconds;
		[gregorian release];	

		NSString *sql;
		if(fromDate && toDate){
			sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=1 AND Task_RepeatID=0 AND Set_Resvr8=0 AND Task_Completed=0 AND ((Task_StartTime BETWEEN %lf AND %lf) OR (Task_EndTime BETWEEN %lf AND %lf) OR (Task_StartTime > %lf AND Task_EndTime < %lf)  OR (Task_StartTime < %lf AND Task_EndTime > %lf)) ",fromDateTimeInterval,toDateTimeInterval,fromDateTimeInterval,toDateTimeInterval,fromDateTimeInterval,toDateTimeInterval,fromDateTimeInterval,toDateTimeInterval];
		}else if(fromDate) {
			sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=1 AND Task_RepeatID=0 AND Set_Resvr8=0 AND Task_Completed=0 AND (Task_StartTime >= %lf OR Task_EndTime >%lf)",fromDateTimeInterval,fromDateTimeInterval];
		}else if(toDate) {
			sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=1 AND Task_RepeatID=0 AND Set_Resvr8=0 AND Task_Completed=0 AND (Task_StartTime <= %lf OR Task_EndTime<%lf)",toDateTimeInterval,toDateTimeInterval];
		}else {
			sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=1 AND Set_Resvr8=0 AND Task_RepeatID=0 AND Task_Completed=0"];
		}

		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			//sqlite3_bind_int(statement,1, completed);
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				int primaryKey = sqlite3_column_int(statement, 0);
				// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
				// autorelease is slightly more expensive than release. This design choice has nothing to do with
				// actual memory management - at the end of this block of code, all the tasks objects allocated
				// here will be in memory regardless of whether we use autorelease or release, because they are
				// retained by the tasks array.
				Task *task = [[Task alloc] getInfoWithPrimaryKey:primaryKey database:database];
				task.taskKey=task.primaryKey;
				[events addObject:task];
				[task release];
			}
		}
		
		sqlite3_finalize(statement);		
	}else
		printf("Database can not open!");
	
	return events;
}

- (NSMutableArray *)createREListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate{
	NSMutableArray *res=[[NSMutableArray alloc] init];
	
	if(initializeDatabaseSucess){
		NSDate *fromDt=fromDate;
		NSDate *toDt=toDate;
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit|NSSecondCalendarUnit;
		
		NSDateComponents *comps;
		if(fromDate){
			comps = [gregorian components:unitFlags fromDate:fromDate];	
			[comps setSecond:0];
			[comps setMinute:0];
			[comps setHour:0];
			fromDt=[gregorian dateFromComponents:comps];
		}
		double fromDateTimeInterval=[fromDt timeIntervalSince1970] + gmtSeconds;
		
		if(toDate){
			comps = [gregorian components:unitFlags fromDate:toDate];	
			[comps setSecond:60];
			[comps setMinute:59];
			[comps setHour:23];
			toDt=[gregorian dateFromComponents:comps];
		}
		double toDateTimeInterval=[toDt timeIntervalSince1970] +gmtSeconds;
		[gregorian release];	
		
//		double fromDateTimeInterval=[fromDate timeIntervalSince1970] + gmtSeconds;
//		double toDateTimeInterval=[toDate timeIntervalSince1970] +gmtSeconds;
		
		NSString *sql;
		if(fromDate && toDate){
			sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=1 AND Task_RepeatID > 0 AND Set_Resvr8=0 AND Task_Completed=0 AND ((Task_StartTime BETWEEN %lf AND %lf) OR (Task_EndTime BETWEEN %lf AND %lf) OR (Task_StartTime > %lf AND Task_EndTime < %lf) OR (Task_StartTime < %lf AND Task_EndTime > %lf))",fromDateTimeInterval,toDateTimeInterval,fromDateTimeInterval,toDateTimeInterval,fromDateTimeInterval,toDateTimeInterval,fromDateTimeInterval,toDateTimeInterval];
		}else if(fromDate) {
			sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=1 AND Task_RepeatID > 0 AND Set_Resvr8=0 AND Task_Completed=0 AND (Task_StartTime >= %lf OR Task_EndTime>%lf)",fromDateTimeInterval,fromDateTimeInterval];
		}else if(toDate) {
			sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=1 AND Task_RepeatID > 0 AND Set_Resvr8=0 AND Task_Completed=0 AND (Task_StartTime <= %lf OR Task_EndTime < %lf)",toDateTimeInterval,toDateTimeInterval];
		}else {
			sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=1 AND Task_RepeatID>0 AND Set_Resvr8=0 AND Task_Completed=0"];
		}
		
		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			//sqlite3_bind_int(statement,1, completed);
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				int primaryKey = sqlite3_column_int(statement, 0);
				// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
				// autorelease is slightly more expensive than release. This design choice has nothing to do with
				// actual memory management - at the end of this block of code, all the tasks objects allocated
				// here will be in memory regardless of whether we use autorelease or release, because they are
				// retained by the tasks array.
				Task *task = [[Task alloc] getInfoWithPrimaryKey:primaryKey database:database];
				task.taskKey=task.primaryKey;
				[res addObject:task];
				[task release];
			}
		}
		
		sqlite3_finalize(statement);		
	}else
		printf("Database can not open!");
	
	return res;
}

- (NSMutableArray *)createADEListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate{
	NSMutableArray *ades=[[NSMutableArray alloc] init];
	
	if(initializeDatabaseSucess){
		NSDate *fromDt=fromDate;
		NSDate *toDt=toDate;
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit|NSSecondCalendarUnit;
		
		NSDateComponents *comps;
		if(fromDate){
			comps = [gregorian components:unitFlags fromDate:fromDate];	
			[comps setSecond:0];
			[comps setMinute:0];
			[comps setHour:0];
			fromDt=[gregorian dateFromComponents:comps];
		}
		double fromDateTimeInterval=[fromDt timeIntervalSince1970] + gmtSeconds;
		
		if(toDate){
			comps = [gregorian components:unitFlags fromDate:toDate];	
			[comps setSecond:60];
			[comps setMinute:59];
			[comps setHour:23];
			toDt=[gregorian dateFromComponents:comps];
		}
		double toDateTimeInterval=[toDt timeIntervalSince1970] +gmtSeconds;
		[gregorian release];	
		
		//double fromDateTimeInterval=[fromDate timeIntervalSince1970] + gmtSeconds;
		//double toDateTimeInterval=[toDate timeIntervalSince1970] +gmtSeconds;
		
		NSString *sql;
		if(fromDate && toDate){
			sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=1 AND Set_Resvr8=1 AND Task_Completed=0 AND ((Task_StartTime BETWEEN %lf AND %lf) OR (Task_EndTime > %lf AND Task_EndTime <=%lf) OR (Task_StartTime > %lf AND Task_EndTime < %lf) OR (Task_StartTime < %lf AND Task_EndTime > %lf))",fromDateTimeInterval,toDateTimeInterval,fromDateTimeInterval,toDateTimeInterval,fromDateTimeInterval,toDateTimeInterval,fromDateTimeInterval,toDateTimeInterval];
		}else if(fromDate) {
			sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=1 AND Set_Resvr8=1 AND Task_Completed=0 AND (Task_StartTime >= %lf OR Task_EndTime > %lf)",fromDateTimeInterval,fromDateTimeInterval];
		}else if(toDate) {
			sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=1 AND Set_Resvr8=1 AND Task_Completed=0 AND (Task_StartTime <= %lf OR Task_StartTime < %lf)",toDateTimeInterval,toDateTimeInterval];
		}else {
			sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=1 AND Set_Resvr8=1 AND Task_Completed=0"];
		}
		
//		printf("\n spl: %s",[sql UTF8String]);
		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			//sqlite3_bind_int(statement,1, completed);
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				int primaryKey = sqlite3_column_int(statement, 0);
				// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
				// autorelease is slightly more expensive than release. This design choice has nothing to do with
				// actual memory management - at the end of this block of code, all the tasks objects allocated
				// here will be in memory regardless of whether we use autorelease or release, because they are
				// retained by the tasks array.
				Task *task = [[Task alloc] getInfoWithPrimaryKey:primaryKey database:database];
				task.taskKey=task.primaryKey;
				[ades addObject:task];
				[task release];
			}
		}
		
		sqlite3_finalize(statement);		
	}else
		printf("Database can not open!");
	
	return ades;
}

- (NSMutableArray *)createNormalTaskListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate context:(NSInteger)context{
	
	NSMutableArray *normalTasks=[[NSMutableArray alloc] init];
	if(initializeDatabaseSucess){
		NSDate *fromDt=fromDate;
		NSDate *toDt=toDate;
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit|NSSecondCalendarUnit;
		
		NSDateComponents *comps;
		if(fromDate){
			comps = [gregorian components:unitFlags fromDate:fromDate];	
			[comps setSecond:0];
			[comps setMinute:0];
			[comps setHour:0];
			fromDt=[gregorian dateFromComponents:comps];
		}
		double fromDateTimeInterval=[fromDt timeIntervalSince1970] + gmtSeconds;
		
		if(toDate){
			comps = [gregorian components:unitFlags fromDate:toDate];	
			[comps setSecond:60];
			[comps setMinute:59];
			[comps setHour:23];
			toDt=[gregorian dateFromComponents:comps];
		}
		double toDateTimeInterval=[toDt timeIntervalSince1970] +gmtSeconds;
		[gregorian release];	
		
		//double fromDateTimeInterval=[fromDate timeIntervalSince1970] + gmtSeconds;
		//double toDateTimeInterval=[toDate timeIntervalSince1970] +gmtSeconds;
		
		NSString *sql;
		if(fromDate && toDate){
            sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=0 AND Task_IsUseDeadLine=0 AND Task_Where LIKE '%@' AND Task_Completed=0 AND Task_StartTime BETWEEN %lf AND %lf",context==-1?@"%":[NSString stringWithFormat:@"%ld",(long)context],fromDateTimeInterval,toDateTimeInterval];
		}else if(fromDate) {
            sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=0 AND Task_IsUseDeadLine=0 AND Task_Where LIKE '%@' AND Task_Completed=0 AND Task_StartTime >= %lf",context==-1?@"%":[NSString stringWithFormat:@"%ld",(long)context],fromDateTimeInterval];
		}else if(toDate) {
            sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=0 AND Task_IsUseDeadLine=0 AND Task_Where LIKE '%@' AND Task_Completed=0 AND Task_StartTime <= %lf",context==-1?@"%":[NSString stringWithFormat:@"%ld",(long)context],toDateTimeInterval];
		}else {
            sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=0 AND Task_IsUseDeadLine=0 AND Task_Where LIKE '%@' AND Task_Completed=0",context==-1?@"%":[NSString stringWithFormat:@"%ld",(long)context]];
		}
		
		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			//sqlite3_bind_int(statement,1, completed);
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				int primaryKey = sqlite3_column_int(statement, 0);
				// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
				// autorelease is slightly more expensive than release. This design choice has nothing to do with
				// actual memory management - at the end of this block of code, all the tasks objects allocated
				// here will be in memory regardless of whether we use autorelease or release, because they are
				// retained by the tasks array.
				Task *task = [[Task alloc] getInfoWithPrimaryKey:primaryKey database:database];
				task.taskKey=task.primaryKey;
				[normalTasks addObject:task];
				[task release];
			}
		}
		
		sqlite3_finalize(statement);		
	}else
		printf("Database can not open!");
	
	return normalTasks;	
}

- (NSMutableArray *)createDTaskListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate context:(NSInteger)context{
	NSMutableArray *dTasks=[[NSMutableArray alloc] init];
	
	if(initializeDatabaseSucess){
		NSDate *fromDt=fromDate;
		NSDate *toDt=toDate;
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit|NSSecondCalendarUnit;
		
		NSDateComponents *comps;
		if(fromDate){
			comps = [gregorian components:unitFlags fromDate:fromDate];	
			[comps setSecond:0];
			[comps setMinute:0];
			[comps setHour:0];
			fromDt=[gregorian dateFromComponents:comps];
		}
		double fromDateTimeInterval=[fromDt timeIntervalSince1970] + gmtSeconds;
		
		if(toDate){
			comps = [gregorian components:unitFlags fromDate:toDate];	
			[comps setSecond:60];
			[comps setMinute:59];
			[comps setHour:23];
			toDt=[gregorian dateFromComponents:comps];
		}
		double toDateTimeInterval=[toDt timeIntervalSince1970] +gmtSeconds;
		[gregorian release];	
		
		
		//double fromDateTimeInterval=[fromDate timeIntervalSince1970] + gmtSeconds;
		//double toDateTimeInterval=[toDate timeIntervalSince1970] +gmtSeconds;
		
		NSString *sql;
		if(fromDate && toDate){
            sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=0 AND Task_IsUseDeadLine=1 AND Task_Where LIKE '%@' AND Task_Completed=0 AND Task_StartTime BETWEEN %lf AND %lf",context==-1?@"%":[NSString stringWithFormat:@"%ld",(long)context],fromDateTimeInterval,toDateTimeInterval];
		}else if(fromDate) {
            sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=0 AND Task_IsUseDeadLine=1 AND Task_Where LIKE '%@' AND Task_Completed=0 AND Task_StartTime >= %lf",context==-1?@"%":[NSString stringWithFormat:@"%ld",(long)context],fromDateTimeInterval];
		}else if(toDate) {
            sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=0 AND Task_IsUseDeadLine=1 AND Task_Where LIKE '%@' AND Task_Completed=0 AND Task_StartTime <= %lf",context==-1?@"%":[NSString stringWithFormat:@"%ld",(long)context],toDateTimeInterval];
		}else {
            sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=0 AND Task_IsUseDeadLine=1 AND Task_Where LIKE '%@' AND Task_Completed=0",context==-1?@"%":[NSString stringWithFormat:@"%ld",(long)context]];
		}
		
		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			//sqlite3_bind_int(statement,1, completed);
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				int primaryKey = sqlite3_column_int(statement, 0);
				// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
				// autorelease is slightly more expensive than release. This design choice has nothing to do with
				// actual memory management - at the end of this block of code, all the tasks objects allocated
				// here will be in memory regardless of whether we use autorelease or release, because they are
				// retained by the tasks array.
				Task *task = [[Task alloc] getInfoWithPrimaryKey:primaryKey database:database];
				task.taskKey=task.primaryKey;
				[dTasks addObject:task];
				[task release];
			}
		}
		
		sqlite3_finalize(statement);		
	}else
		printf("Database can not open!");
	
	return dTasks;		
}

// get Task list
/*
- (void)getDummiesList{
	NSMutableArray *dummies=[[NSMutableArray alloc] init];
	
	if(initializeDatabaseSucess){
		// Get the primary key for all tasks.
		const char *sql = "SELECT Task_ID FROM RE_Dummies";
		
		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
			//sqlite3_bind_int(statement,1, completed);
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				int primaryKey = sqlite3_column_int(statement, 0);
				// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
				// autorelease is slightly more expensive than release. This design choice has nothing to do with
				// actual memory management - at the end of this block of code, all the tasks objects allocated
				// here will be in memory regardless of whether we use autorelease or release, because they are
				// retained by the tasks array.
				Task *task = [[Task alloc] getDummyInfoWithPrimaryKey:primaryKey database:database];
				task.taskKey=task.primaryKey;
				task.primaryKey=dummyKey;
				dummyKey-=1;
				[dummies addObject:task];
				[task release];
			}
		}
		
		sqlite3_finalize(statement);		
	}else
		printf("Database can not open!");
	
	taskmanager.dummiesList=dummies;
	[dummies release];
	
	//[ivoUtility printTask:taskmanager.taskList];
}


- (NSMutableArray *)createDummiesListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate{
	NSMutableArray *dummies=[[NSMutableArray alloc] init];
	
	if(initializeDatabaseSucess){
		// Get the primary key for all tasks.
		
		NSDate *fromDt=fromDate;
		NSDate *toDt=toDate;
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit|NSSecondCalendarUnit;
		
		NSDateComponents *comps;
		if(fromDate){
			comps = [gregorian components:unitFlags fromDate:fromDate];	
			[comps setSecond:0];
			[comps setMinute:0];
			[comps setHour:0];
			fromDt=[gregorian dateFromComponents:comps];
		}
		double fromDateTimeInterval=[fromDt timeIntervalSince1970] + gmtSeconds;
		
		if(toDate){
			comps = [gregorian components:unitFlags fromDate:toDate];	
			[comps setSecond:60];
			[comps setMinute:59];
			[comps setHour:23];
			toDt=[gregorian dateFromComponents:comps];
		}
		double toDateTimeInterval=[toDt timeIntervalSince1970] +gmtSeconds;
		[gregorian release];	
		
		//double fromDateTimeInterval=[fromDate timeIntervalSince1970] + gmtSeconds;
		//double toDateTimeInterval=[toDate timeIntervalSince1970] +gmtSeconds;
		
		NSString *sql =[NSString stringWithFormat: @"SELECT Task_ID FROM RE_Dummies WHERE task_StartTime BETWEEN %lf AND %lf",fromDateTimeInterval,toDateTimeInterval];
		
		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			//sqlite3_bind_int(statement,1, completed);
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				int primaryKey = sqlite3_column_int(statement, 0);
				// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
				// autorelease is slightly more expensive than release. This design choice has nothing to do with
				// actual memory management - at the end of this block of code, all the tasks objects allocated
				// here will be in memory regardless of whether we use autorelease or release, because they are
				// retained by the tasks array.
				Task *task = [[Task alloc] getDummyInfoWithPrimaryKey:primaryKey database:database];
				task.taskKey=task.primaryKey;
				task.primaryKey=dummyKey;
				dummyKey-=1;
				[dummies addObject:task];
				[task release];
			}
		}
		
		sqlite3_finalize(statement);		
	}else
		printf("Database can not open!");
	
	return dummies;
	
	//[ivoUtility printTask:taskmanager.taskList];
}
*/

//get tasks in DB from a date to a date, if  isAllTasks==NO, just get all tasks not completed, YES get all tasks include completed tasks. 
-(NSMutableArray *)getTaskListFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate taskType:(NSInteger)Task_Pinned isAllTasks:(BOOL)isAllTasks withSearchText:(NSString *)searchText{
	NSMutableArray *taskListTmp=[NSMutableArray array];
	
	if(initializeDatabaseSucess){
		NSDate *fromDt=fromDate;
		NSDate *toDt=toDate;
		NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
		unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit|NSSecondCalendarUnit;
		
		double todayTimeInterVal=[[self getToday] timeIntervalSince1970];
		NSDateComponents *comps;
		if(fromDate){
			comps = [gregorian components:unitFlags fromDate:fromDate];	
			[comps setSecond:0];
			[comps setMinute:0];
			[comps setHour:0];
			fromDt=[gregorian dateFromComponents:comps];
		}
		double fromDateTimeInterval=[fromDt timeIntervalSince1970] + gmtSeconds;
		
		if(toDate){
			comps = [gregorian components:unitFlags fromDate:toDate];	
			[comps setSecond:59];
			[comps setMinute:59];
			[comps setHour:23];
			toDt=[gregorian dateFromComponents:comps];
		}
		double toDateTimeInterval=[toDt timeIntervalSince1970] +gmtSeconds;
		//[gregorian release];	
		
		NSString *sql;
		
		if(fromDate && toDate){
			if(isAllTasks){
				if(fromDateTimeInterval==todayTimeInterVal){
                    sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=%ld AND Task_Name LIKE '%%%@%%' AND (Task_IsUseDeadLine=0 OR (Task_IsUseDeadLine=1 AND Task_DeadLine BETWEEN %lf AND %lf));",(long)Task_Pinned,searchText,fromDateTimeInterval,toDateTimeInterval];
				}else {
                    sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=%ld AND Task_Name LIKE '%%%@%%' AND (Task_IsUseDeadLine=1 AND Task_DeadLine BETWEEN %lf AND %lf);",(long)Task_Pinned,searchText,fromDateTimeInterval,toDateTimeInterval];
				}
				
			}else {
				if(fromDateTimeInterval==todayTimeInterVal){
					sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=%d AND status<1 AND Task_Name LIKE '%%%@%%' AND (Task_IsUseDeadLine=0 OR (Task_IsUseDeadLine=1 AND Task_DeadLine BETWEEN %lf AND %lf));",Task_Pinned,searchText,fromDateTimeInterval,toDateTimeInterval];
				}else {
					sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=%d AND status<1 AND Task_Name LIKE '%%%@%%' AND (Task_IsUseDeadLine=1 AND Task_DeadLine BETWEEN %lf AND %lf);",Task_Pinned,searchText,fromDateTimeInterval,toDateTimeInterval];
				}
				
			}
		}else if(fromDate) {
			if(isAllTasks){
				if(fromDateTimeInterval==todayTimeInterVal){
					sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=%d AND Task_Name LIKE '%%%@%%' AND (Task_IsUseDeadLine=0 OR (Task_IsUseDeadLine=1 AND Task_DeadLine >= %lf));",Task_Pinned,searchText,fromDateTimeInterval];
				}else {
					sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=%d AND Task_Name LIKE '%%%@%%' AND Task_IsUseDeadLine=1 AND Task_DeadLine >= %lf;",Task_Pinned,searchText,fromDateTimeInterval];
				}
				
			}else {
				if(fromDateTimeInterval==todayTimeInterVal){
					sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=%d AND status<1 AND Task_Name LIKE '%%%@%%' AND (Task_IsUseDeadLine=0 OR (Task_IsUseDeadLine=1 AND Task_DeadLine >= %lf));",Task_Pinned,searchText,fromDateTimeInterval];
				}else {
					sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=%d AND status<1 AND Task_Name LIKE '%%%@%%' AND Task_IsUseDeadLine=1 AND Task_DeadLine >= %lf;",Task_Pinned,searchText,fromDateTimeInterval];
				}
			}
		}else if(toDate) {
			if(isAllTasks){
				if(toDateTimeInterval==todayTimeInterVal){
					sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=%d AND Task_Name LIKE '%%%@%%' AND (Task_IsUseDeadLine=0 OR (Task_IsUseDeadLine=1 AND Task_DeadLine <= %lf));",Task_Pinned,searchText,toDateTimeInterval];
				}else {
					sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=%d AND Task_Name LIKE '%%%@%%' AND Task_IsUseDeadLine=1 AND Task_DeadLine <= %lf;",Task_Pinned,searchText,toDateTimeInterval];
				}
				
			}else {
				if(toDateTimeInterval==todayTimeInterVal){
					sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=%d AND status<1 AND Task_Name LIKE '%%%@%%' AND (Task_IsUseDeadLine=0 OR (Task_IsUseDeadLine=1 AND Task_DeadLine <= %lf));",Task_Pinned,searchText,toDateTimeInterval];
				}else {
					sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=%d AND status<1 AND Task_Name LIKE '%%%@%%' AND Task_IsUseDeadLine=1 AND Task_DeadLine <= %lf;",Task_Pinned,searchText,toDateTimeInterval];
				}
				
			}
		}else {
			if(isAllTasks){
				sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=%d AND Task_Name LIKE '%%%@%%'",Task_Pinned,searchText];
			}else {
				sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=%d AND Task_Name LIKE '%%%@%%' AND Task_Completed=0",Task_Pinned,searchText];
			}
		}
		
		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			//sqlite3_bind_int(statement,1, completed);
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				int primaryKey = sqlite3_column_int(statement, 0);
				// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
				// autorelease is slightly more expensive than release. This design choice has nothing to do with
				// actual memory management - at the end of this block of code, all the tasks objects allocated
				// here will be in memory regardless of whether we use autorelease or release, because they are
				// retained by the tasks array.
				Task *task = [[Task alloc] getInfoWithPrimaryKey:primaryKey database:database];
				[taskListTmp addObject:task];
				//printf("\n updated date: %s",[[ivo_Utilities getShortDateStringFromDate:task.taskDateUpdate] UTF8String]);
				[task release];
			}
		}
		
		sqlite3_finalize(statement);		
	}else
		printf("Database can not open!");
	return taskListTmp;		
}

//get tasks in DB from a dateUpdate to a dateUpdate, if  isAllTasks==NO, just get all tasks not completed, YES get all tasks include completed tasks. 
-(NSMutableArray *)getTaskListFromUpdateDate:(NSDate *)fromDate toUpdateDate:(NSDate *)toDate isAllTasks:(BOOL)isAllTasks{
	NSMutableArray *taskList=[NSMutableArray array];
	
	if(initializeDatabaseSucess){
		NSDate *fromDt=fromDate;
		NSDate *toDt=toDate;
		NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
		unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit|NSSecondCalendarUnit;
		
		double todayTimeInterVal=[[self getToday] timeIntervalSince1970];
		NSDateComponents *comps;
		if(fromDate){
			comps = [gregorian components:unitFlags fromDate:fromDate];	
			[comps setSecond:0];
			[comps setMinute:0];
			[comps setHour:0];
			fromDt=[gregorian dateFromComponents:comps];
		}
		double fromDateTimeInterval=[fromDt timeIntervalSince1970] + gmtSeconds;
		
		if(toDate){
			comps = [gregorian components:unitFlags fromDate:toDate];	
			[comps setSecond:59];
			[comps setMinute:59];
			[comps setHour:23];
			toDt=[gregorian dateFromComponents:comps];
		}
		double toDateTimeInterval=[toDt timeIntervalSince1970] +gmtSeconds;
		//[gregorian release];	
		
		NSString *sql;
		if(fromDate && toDate){
			if(isAllTasks){
				if(fromDateTimeInterval==todayTimeInterVal){
					sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=0 AND dateUpdate BETWEEN %lf AND %lf;",fromDateTimeInterval,toDateTimeInterval];
				}else {
					sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=0 AND dateUpdate BETWEEN %lf AND %lf;",fromDateTimeInterval,toDateTimeInterval];
				}
				
			}else {
				if(fromDateTimeInterval==todayTimeInterVal){
					sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=0 AND Task_Completed<1 AND dateUpdate BETWEEN %lf AND %lf;",fromDateTimeInterval,toDateTimeInterval];
				}else {
					sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=0 AND Task_Completed<1 AND dateUpdate BETWEEN %lf AND %lf;",fromDateTimeInterval,toDateTimeInterval];
				}
				
			}
		}else if(fromDate) {
			if(isAllTasks){
				if(fromDateTimeInterval==todayTimeInterVal){
					sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=0 AND dateUpdate >= %lf;",fromDateTimeInterval];
				}else {
					sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=0 AND dateUpdate >= %lf;",fromDateTimeInterval];
				}
				
			}else {
				if(fromDateTimeInterval==todayTimeInterVal){
					sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=0 AND Task_Completed<1 AND dateUpdate >= %lf;",fromDateTimeInterval];
				}else {
					sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=0 AND Task_Completed<1 AND dateUpdate >= %lf;",fromDateTimeInterval];
				}
			}
		}else if(toDate) {
			if(isAllTasks){
				if(toDateTimeInterval==todayTimeInterVal){
					sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=0 AND dateUpdate <= %lf;",toDateTimeInterval];
				}else {
					sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=0 AND dateUpdate <= %lf;",toDateTimeInterval];
				}
				
			}else {
				if(toDateTimeInterval==todayTimeInterVal){
					sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=0 AND Task_Completed<1 AND dateUpdate <= %lf;",toDateTimeInterval];
				}else {
					sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where Task_Pinned=0 AND Task_Completed<1 AND dateUpdate <= %lf;",toDateTimeInterval];
				}
				
			}
		}else {
			if(isAllTasks){
				sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks WHERE Task_Pinned=0 "];
			}else {
				sql =[NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks where  Task_Pinned=0 AND Task_Completed=0"];
			}
		}
		
		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			//sqlite3_bind_int(statement,1, completed);
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				int primaryKey = sqlite3_column_int(statement, 0);
				// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
				// autorelease is slightly more expensive than release. This design choice has nothing to do with
				// actual memory management - at the end of this block of code, all the tasks objects allocated
				// here will be in memory regardless of whether we use autorelease or release, because they are
				// retained by the tasks array.
				Task *task = [[Task alloc] getInfoWithPrimaryKey:primaryKey database:database];
				[taskList addObject:task];
				//printf("\n updated date: %s",[[ivo_Utilities getShortDateStringFromDate:task.taskDateUpdate] UTF8String]);
				[task release];
			}
		}
		
		sqlite3_finalize(statement);		
	}else
		printf("Database can not open!");
	return taskList;		
}

//get QuickTaskList
- (void)getQuickTaskList:(NSString *)filterClause{
	quickTasks=[[NSMutableArray alloc] init];
	if(initializeDatabaseSucess){
		NSString *currentDate=[ivoUtility createStringFromShortDate:[NSDate date]];

		if(filterClause==nil || [filterClause isEqual:@""]){
			[quickTasks addObjectsFromArray:[taskmanager getTaskListFromDate:[NSDate date] toDate:[NSDate date] splitLongTask:YES isUpdateTaskList:YES isSplitADE:YES]];
		}else {
			NSArray *filterCritera=[filterClause componentsSeparatedByString:@"|"];
            
            NSMutableArray *arr=[NSMutableArray arrayWithArray:projectList];
            
            BOOL needToCheckProject=NO;
            
            for (Projects *p in arr) {
                if (p.isInFiltering==1) {
                    needToCheckProject=YES;
                    break;
                }
            }

             NSMutableArray *sourceList=[NSMutableArray arrayWithArray:taskmanager.taskList];
            
			for(Task *tmp in sourceList){
				NSRange strInStr=[tmp.taskName rangeOfString:(NSString *)[filterCritera objectAtIndex:0] options:NSCaseInsensitiveSearch];
				if(strInStr.location!=NSNotFound || tmp.taskPinned==[[filterCritera objectAtIndex:1] intValue] || tmp.taskPinned== [[filterCritera objectAtIndex:2] intValue]
				   || tmp.taskWhere==[[filterCritera objectAtIndex:3] intValue] || tmp.taskWhere== [[filterCritera objectAtIndex:4] intValue]){
                    
                    if (needToCheckProject) {
                        Projects *project=[App_Delegate calendarWithPrimaryKey:tmp.taskProject];  
                        
                        if (project.isInFiltering) {
                            //[filteredTasks addObject:tmp];
                            
                            NSString *taskStartDate=[ivoUtility createStringFromShortDate:tmp.taskStartTime];
                            if([taskStartDate isEqual:currentDate]){
                                [quickTasks addObject:tmp];
                            }
                            [taskStartDate release];
                            
                        }
                    }else{
                        NSString *taskStartDate=[ivoUtility createStringFromShortDate:tmp.taskStartTime];
                        if([taskStartDate isEqual:currentDate]){
                            [quickTasks addObject:tmp];
                        }
                        [taskStartDate release];
                    }
				}
			}
			
		}
		
		[currentDate release];
	}else
		printf("Database can not open!");
	
	[taskmanager setQuickTaskList: quickTasks];
	
	if(quickTasks!=nil){
		[quickTasks release];
		quickTasks=nil;
	}	
}

//get completed Tasks today
- (void)getCompletedTasksToday{
	completedTasksToday=[[NSMutableArray alloc] init];
	if(initializeDatabaseSucess){
		// Get the primary key for all tasks.
		//const char *sql = "SELECT Task_ID FROM iVo_Tasks where date(Task_DateUpdate,'unixepoch') =date('now') and Task_Completed=1";
		const char *sql = "SELECT Task_ID FROM iVo_Tasks where Task_Completed=1";
		
		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
			NSString *currentDate=[ivoUtility createStringFromShortDate:[NSDate date]];
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				int primaryKey = sqlite3_column_int(statement, 0);
				Task *task = [[Task alloc] getInfoWithPrimaryKey:primaryKey database:database];
				NSString *taskDateUpdateStr=[ivoUtility createStringFromShortDate:task.taskDateUpdate];
				if([taskDateUpdateStr isEqualToString:currentDate]){
					[completedTasksToday addObject:task];
				}
				[taskDateUpdateStr release];
				[task release];
			}
			[currentDate release];
		}
		
		sqlite3_finalize(statement);		
	}else
		printf("Database can not open!");
	
	[taskmanager setCompletedTaskList: completedTasksToday];
	//taskmanager.completedTaskList=completedTasksToday;
	if(completedTasksToday!=nil){
		[completedTasksToday release];
		completedTasksToday=nil;
	}	
	
}


//get full completed Tasks list
- (NSMutableArray *)createFullDoneTaskList{
	NSMutableArray *fullDoneTaskList=[[NSMutableArray alloc] init];
	if(initializeDatabaseSucess){
		// Get the primary key for all tasks.
		const char *sql = "SELECT Task_ID FROM iVo_Tasks where Task_Completed=1";
		
		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				int primaryKey = sqlite3_column_int(statement, 0);
				Task *task = [[Task alloc] getInfoWithPrimaryKey:primaryKey database:database];
				[fullDoneTaskList addObject:task];
				[task release];
			}
			
		}
		
		sqlite3_finalize(statement);		
	}else
		printf("Database can not open!");
	
	return fullDoneTaskList;
}

- (void)getFilterTaskList:(NSString *)queryClause fromList:(NSMutableArray *)fromList{
	NSMutableArray *filteredTasks=[[NSMutableArray alloc] init];
	BOOL isTitleEmpty=NO;
	NSArray *filterCritera=[queryClause componentsSeparatedByString:@"|"];

	NSString	*title=(NSString *)[filterCritera objectAtIndex:0];
	
	if([title isEqualToString:@""]) {
		isTitleEmpty=YES;
	}
	NSInteger	taskT=[[filterCritera objectAtIndex:1] intValue];
	NSInteger	taskE=[[filterCritera objectAtIndex:2] intValue];

	if(taskT==-1 && taskE==-1){
		taskT=0;
		taskE=1;
	}
	
	NSInteger	taskHome=[[filterCritera objectAtIndex:4] intValue];
	NSInteger	taskWork=[[filterCritera objectAtIndex:3] intValue];
	
	if(taskHome==-1 && taskWork==-1){
		taskHome=0;
		taskWork=1;
	}
/*	
	NSInteger	project1=[[filterCritera objectAtIndex:5] intValue];
	NSInteger	project2=[[filterCritera objectAtIndex:6] intValue];
	NSInteger	project3=[[filterCritera objectAtIndex:7] intValue];
	NSInteger	project4=[[filterCritera objectAtIndex:8] intValue];
	NSInteger	project5=[[filterCritera objectAtIndex:9] intValue];
	NSInteger	project6=[[filterCritera objectAtIndex:10] intValue];
	//
	NSInteger	project7=[[filterCritera objectAtIndex:11] intValue];
	NSInteger	project8=[[filterCritera objectAtIndex:12] intValue];
	NSInteger	project9=[[filterCritera objectAtIndex:13] intValue];
	NSInteger	project10=[[filterCritera objectAtIndex:14] intValue];
	NSInteger	project11=[[filterCritera objectAtIndex:15] intValue];
	NSInteger	project12=[[filterCritera objectAtIndex:16] intValue];
	
	if(project1 == -1 && project2==-1 && project3==-1 && project4 ==-1 && project5 ==-1 &&project6==-1
		&&project7 == -1 && project8==-1 && project9==-1 && project10 ==-1 && project11 ==-1 &&project12==-1){
		project1=0;
		project2=1;
		project3=2;
		project4=3;
		project5=4;
		project6=5;

		project7=6;
		project8=7;
		project9=8;
		project10=9;
		project11=10;
		project12=11;
		
	}
*/
	//ST3.3	
	//for(Task *tmp in taskmanager.taskList){
    
    NSMutableArray *arr=[NSMutableArray arrayWithArray:projectList];
    
    BOOL needToCheckProject=NO;
    
    for (Projects *p in arr) {
        if (p.isInFiltering==1) {
            needToCheckProject=YES;
            break;
        }
    }
    
	for(Task *tmp in fromList){
		if(isTitleEmpty) {
			title=tmp.taskName;
		}
		NSRange strInStr=[tmp.taskName rangeOfString:title options:NSCaseInsensitiveSearch];
		
		if(strInStr.location!=NSNotFound && (tmp.taskPinned==taskT || tmp.taskPinned== taskE)
		   && (tmp.taskWhere==taskHome || tmp.taskWhere== taskWork)){/*
			&& (tmp.taskProject == project1 || tmp.taskProject == project2  
			|| tmp.taskProject == project3 || tmp.taskProject == project4 
		   || tmp.taskProject == project5 || tmp.taskProject == project6||
				tmp.taskProject == project7 || tmp.taskProject == project8  
				|| tmp.taskProject == project9 || tmp.taskProject == project10 
				|| tmp.taskProject == project11 || tmp.taskProject == project12)){*/
			   
            if (needToCheckProject) {
                Projects *project=[App_Delegate calendarWithPrimaryKey:tmp.taskProject];  
                
                if (project.isInFiltering) {
                    [filteredTasks addObject:tmp];
                }
            }else{
                [filteredTasks addObject:tmp];
            }
		}
	}

	[taskmanager setFilterList:filteredTasks];
	
	if(filteredTasks !=nil){
		[filteredTasks release];
		filteredTasks=nil;
	}
}

// get Task list
- (NSUInteger)getTaskCount{
	if(initializeDatabaseSucess){
		// Get the primary key for all tasks.
		const char *sql = "SELECT count(Task_ID) FROM iVo_Tasks";
		
		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
			//printf("\ntaskCount: %d",sqlite3_column_int(statement, 0));
			return sqlite3_column_int(statement, 0);
		}
		
		sqlite3_finalize(statement);		
	}else
		printf("Database can not open!");
	
	return 0;
}

-(Projects *)calendarWithPrimaryKey:(NSInteger)key{
	Projects *ret=nil;
	while (projectList.count==0) {
		//usleep(20);
        [NSThread sleepForTimeInterval:0.01];
	}
	
	NSMutableArray *sourceList=[NSMutableArray arrayWithArray:projectList];
	for (Projects *cal in sourceList){
		if(cal.primaryKey==key){
			return cal;
			break;
		}
	}
	
	if (sourceList.count>0) {
		ret=[sourceList objectAtIndex:0];
	}
	
	return ret;
}

-(Projects *)calendarWithICalId:(NSString *)key{
	Projects *ret=nil;
	while (projectList.count==0) {
		//usleep(20);
        [NSThread sleepForTimeInterval:0.01];
	}
	
	//NSString *str=[[key stringByReplacingOccurrencesOfString:@" " withString:@""] uppercaseString];
	NSMutableArray *sourceList=[NSMutableArray arrayWithArray:projectList];
	for (Projects *cal in sourceList){
		if([cal.iCalIdentifier isEqualToString:key]){
			return cal;
			break;
		}
	}
	
	if (sourceList.count>0) {
		ret=[sourceList objectAtIndex:0];
	}
	
	return ret;
}

- (void)deleteAllTasksBelongCalendar:(NSInteger)calendarId{
	if(initializeDatabaseSucess){
		// Get the primary key for all tasks.
		
        NSString *sql =[NSString stringWithFormat:@"DELETE FROM iVo_Tasks WHERE Task_Project=%ld",(long)calendarId];
		
		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
		sqlite3_step(statement);
		sqlite3_finalize(statement);	
		
	}else
		printf("Database can not open!");
}

-(NSMutableArray *)getADEsListOnlyFromTaskList:(NSMutableArray*)list fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate withSearchText:(NSString *)searchText needSort:(BOOL)needSort{
	NSMutableArray *taskListTmp=[NSMutableArray array];
	NSString *searchValue=[searchText length]==0?nil:searchText;
	
	NSDate *fromDt=fromDate;
	NSDate *toDt=toDate;
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit|NSSecondCalendarUnit;
	
	NSDateComponents *comps;
	if(fromDate){
		comps = [gregorian components:unitFlags fromDate:fromDate];	
		[comps setSecond:0];
		[comps setMinute:0];
		[comps setHour:1];
		fromDt=[gregorian dateFromComponents:comps];
	}
	
	if(toDate){
		comps = [gregorian components:unitFlags fromDate:toDate];	
		[comps setSecond:59];
		[comps setMinute:59];
		[comps setHour:23];
		toDt=[gregorian dateFromComponents:comps];
	}
	
	NSMutableArray *sourceList=[NSMutableArray arrayWithArray:list];
	if (needSort)
		[taskmanager sortListWithAD:sourceList byKey:@"isAllDayEvent" isAscending:NO];
	
	if(fromDate && toDate){
		if (searchValue) {
			for (Task *task in sourceList) {
				if (task.taskPinned==0) {
					continue;
				}
				
				if (task.isAllDayEvent==0) {
					continue;
				}
				
				if (task.taskRepeatID!=0) {
					continue;
				}
				
				if ([task.taskName rangeOfString:searchValue].location== NSNotFound){
					continue;
				}
				
				if ([task.taskEndTime compare:fromDt]==NSOrderedAscending) {
					continue;
				}
				
				if ([task.taskStartTime compare:toDt]==NSOrderedDescending) {
					continue;
				}
				
				
				//Task *tmp=[task copy];
				[taskListTmp addObject:task];
				//[tmp release];
			}		
		}else {
			for (Task *task in sourceList) {
				
				if (task.taskPinned==0) {
					continue;
				}
				
				if (task.isAllDayEvent==0) {
					continue;
				}
				
				if (task.taskRepeatID!=0) {
					continue;
				}
				
				
				if ([task.taskEndTime compare:fromDt]==NSOrderedAscending) {
					continue;
				}
				
				if ([task.taskStartTime compare:toDt]==NSOrderedDescending) {
					continue;
				}
				
				//Task *tmp=[task copy];
				[taskListTmp addObject:task];
				//[tmp release];
			}
		}
		
	}else if(fromDate) {
		if (searchValue) {
			for (Task *task in sourceList) {
				if (task.taskPinned==0) {
					continue;
				}
				
				if (task.isAllDayEvent==0) {
					continue;
				}
				
				if (task.taskRepeatID!=0) {
					continue;
				}
				
				
				if ([task.taskEndTime compare:fromDt]==NSOrderedAscending) {
					continue;
				}
				
				if ([task.taskName rangeOfString:searchValue].location!= NSNotFound) {
					
					//Task *tmp=[task copy];
					[taskListTmp addObject:task];
					//[tmp release];
				}
			}
		}else {
			for (Task *task in sourceList) {
				if (task.taskPinned==0) {
					continue;
				}
				
				if (task.isAllDayEvent==0) {
					continue;
				}
				
				if (task.taskRepeatID!=0) {
					continue;
				}
				
				
				if ([task.taskEndTime compare:fromDt]==NSOrderedAscending) {
					continue;
				}
				
				//Task *tmp=[task copy];
				[taskListTmp addObject:task];
				//[tmp release];
			}
		}
		
	}else if(toDate) {
		if (searchValue) {
			for (Task *task in sourceList) {
				if (task.taskPinned==0) {
					continue;
				}
				
				if (task.isAllDayEvent==0) {
					continue;
				}
				
				if (task.taskRepeatID!=0) {
					continue;
				}
				
				
				if ([task.taskStartTime compare:toDt]==NSOrderedDescending) {
					continue;
				}
				
				if ([task.taskName rangeOfString:searchValue].location!= NSNotFound) {
					
					//Task *tmp=[task copy];
					[taskListTmp addObject:task];
					//[tmp release];
				}
			}
		}else {
			for (Task *task in sourceList) {
				if (task.taskPinned==0) {
					continue;
				}
				
				if (task.isAllDayEvent==0) {
					continue;
				}
				
				if (task.taskRepeatID!=0) {
					continue;
				}
				
				
				if ([task.taskStartTime compare:toDt]==NSOrderedDescending) {
					continue;
				}
				
				//Task *tmp=[task copy];
				[taskListTmp addObject:task];
				//[tmp release];
			}
		}
	}else {
		if (searchValue) {
			for (Task *task in sourceList) {
				if (task.taskPinned==0) {
					continue;
				}
				
				if (task.isAllDayEvent==0) {
					continue;
				}
				
				if (task.taskRepeatID!=0) {
					continue;
				}
				
				
				
				if ([task.taskName rangeOfString:searchValue].location!= NSNotFound) {
					//Task *tmp=[task copy];
					[taskListTmp addObject:task];
					//[tmp release];
				}
			}
			
		}else {
			for (Task *task in sourceList) {
				if (task.taskPinned==1 && task.isAllDayEvent==1 && task.taskRepeatID==0 ) {
					//Task *tmp=[task copy];
					[taskListTmp addObject:task];
					//[tmp release];
				}
			}
		}
	}
	
	
	return taskListTmp;
	
	
	//	return [self getADEsListFromDate:fromDate toDate:toDate withSearchText:searchText];
}

-(NSMutableArray *)getAllEventsFromList:(NSMutableArray*)list{
    NSMutableArray *ret=[NSMutableArray array];
    
    NSMutableArray *sourceList=[NSMutableArray arrayWithArray:list];
    for (Task *task in sourceList) {
        if (task.taskPinned==1) {
            [ret addObject:task];
        }
    }
    
    return ret;    
}

-(NSMutableArray *)getAllTasksFromList:(NSMutableArray*)list{
    NSMutableArray *ret=[NSMutableArray array];
    
    NSMutableArray *sourceList=[NSMutableArray arrayWithArray:list];
    for (Task *task in sourceList) {
        if (task.taskPinned==0) {
            [ret addObject:task];
        }
    }
    
    return ret;
}


-(NSMutableArray *)getEventOnlyListFromTaskList:(NSMutableArray*)list fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate withSearchText:(NSString *)searchText needSort:(BOOL)needSort{
	NSMutableArray *taskListTmp=[NSMutableArray array];
	NSString *searchValue=[searchText length]==0?nil:searchText;
	
	NSDate *fromDt=fromDate;
	NSDate *toDt=toDate;
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit|NSSecondCalendarUnit;
	
	NSDateComponents *comps;
	if(fromDate){
		comps = [gregorian components:unitFlags fromDate:fromDate];	
		[comps setSecond:0];
		[comps setMinute:1];
		[comps setHour:1];
		fromDt=[gregorian dateFromComponents:comps];
	}
	
	if(toDate){
		comps = [gregorian components:unitFlags fromDate:toDate];	
		[comps setSecond:59];
		[comps setMinute:59];
		[comps setHour:23];
		toDt=[gregorian dateFromComponents:comps];
	}
	
    NSMutableArray *sourceList=[NSMutableArray arrayWithArray:list];
	if (needSort)
		[taskmanager sortListWithAD:sourceList byKey:@"taskPinned" isAscending:NO];
	
	if(fromDate && toDate){
		if (searchValue) {
			for (Task *task in sourceList) {
				if (task.taskPinned==0) {
					goto finish;
				}
				
				if (task.taskRepeatID>0) {
					continue;
				}
				
				if (task.isAllDayEvent==1) {
					continue;
				}
				
				if ([task.taskEndTime compare:fromDt]==NSOrderedAscending) {
					continue;
				}
				
				if([task.taskStartTime compare:toDt]==NSOrderedDescending){
					continue;
				}
				
				if ([task.taskName rangeOfString:searchValue].location!= NSNotFound) {
					
					//Task *tmp=[task copy];
					[taskListTmp addObject:task];
					//[tmp release];
				}
			}		
		}else {
			for (Task *task in sourceList) {
				if (task.taskPinned==0) {
					goto finish;
				}
				
				if (task.taskRepeatID>0) {
					continue;
				}
				
				if (task.isAllDayEvent==1) {
					continue;
				}
				
				if ([task.taskEndTime compare:fromDt]==NSOrderedAscending) {
					continue;
				}
				
				if([task.taskStartTime compare:toDt]==NSOrderedDescending){
					continue;
				}
				
				
				//Task *tmp=[task copy];
				[taskListTmp addObject:task];
				//[tmp release];
			}
		}
		
	}else if(fromDate) {
		if (searchValue) {
			for (Task *task in sourceList) {
				if (task.taskPinned==0) {
					goto finish;
				}
				
				if (task.taskRepeatID>0) {
					continue;
				}
				
				if (task.isAllDayEvent==1) {
					continue;
				}
				
				if ([task.taskEndTime compare:fromDt]==NSOrderedAscending) {
					continue;
				}
				
				if ([task.taskName rangeOfString:searchValue].location!= NSNotFound) {
					
					//Task *tmp=[task copy];
					[taskListTmp addObject:task];
					//[tmp release];
				}
			}
		}else {
			for (Task *task in sourceList) {
				if (task.taskPinned==0) {
					goto finish;
				}
				
				if (task.taskRepeatID>0) {
					continue;
				}
				
				if (task.isAllDayEvent==1) {
					continue;
				}
				
				if ([task.taskStartTime compare:fromDt]==NSOrderedAscending) {
					continue;
				}
				
				
				//Task *tmp=[task copy];
				[taskListTmp addObject:task];
				//[tmp release];
			}
		}
		
	}else if(toDate) {
		if (searchValue) {
			for (Task *task in sourceList) {
				if (task.taskPinned==0) {
					goto finish;
				}
				
				if (task.taskRepeatID>0) {
					continue;
				}
				
				if (task.isAllDayEvent==1) {
					continue;
				}
				
				if([task.taskStartTime compare:toDt]==NSOrderedDescending){
					continue;
				}
				
				if ([task.taskName rangeOfString:searchValue].location!= NSNotFound) {
					
					//Task *tmp=[task copy];
					[taskListTmp addObject:task];
					//[tmp release];
				}
			}
		}else {
			for (Task *task in sourceList) {
				if (task.taskPinned==0) {
					goto finish;
				}
				
				if (task.taskRepeatID>0) {
					continue;
				}
				
				if (task.isAllDayEvent==1) {
					continue;
				}
				
				if([task.taskStartTime compare:toDt]==NSOrderedDescending){
					continue;
				}
				
				//Task *tmp=[task copy];
				[taskListTmp addObject:task];
				//[tmp release];
			}
		}
	}else {
		if (searchValue) {
			for (Task *task in sourceList) {
				if (task.taskPinned==0) {
					goto finish;
				}
				
				if (task.taskRepeatID>0) {
					continue;
				}
				
				if (task.isAllDayEvent==1) {
					continue;
				}
				
				if ([task.taskName rangeOfString:searchValue].location!= NSNotFound) {
					//Task *tmp=[task copy];
					[taskListTmp addObject:task];
					//[tmp release];
				}
			}
			
		}else {
			for (Task *task in sourceList) {
				if (task.taskPinned==0) {
					goto finish;
				}
				
				if (task.taskRepeatID>0) {
					continue;
				}
				
				if (task.isAllDayEvent==1) {
					continue;
				}
				
				//Task *tmp=[task copy];
				[taskListTmp addObject:task];
				//[tmp release];
			}
		}
	}
	
finish:
	return taskListTmp;
	
	//return [self getEventListFromDate:fromDate toDate:toDate withSearchText:searchText];
}

-(NSMutableArray *)getAllRecurringADEsFromTaskList:(NSMutableArray*)list withSearchText:(NSString *)searchText{
	NSMutableArray *taskListTmp=[NSMutableArray array];
	NSString *searchValue=[searchText length]==0?nil:searchText;
	
    NSMutableArray *sourceList=[NSMutableArray arrayWithArray:list];
	[taskmanager sortListWithAD:sourceList byKey:@"taskRepeatID" isAscending:NO];
	
	if (searchValue) {
		for (Task *task in sourceList) {
			if (task.taskRepeatID==0) {
				goto finish;
			}
            
			if (task.taskPinned==0) {
				continue;
			}
			
			if (task.isAllDayEvent==0) {
				continue;
			}
			
			
			if ([task.taskName rangeOfString:searchValue].location!= NSNotFound) {
				//Task *tmp=[task copy];
				[taskListTmp addObject:task];
				//[tmp release];
			}
		}
		
	}else {
		for (Task *task in sourceList) {
			if (task.taskPinned==0) {
				goto finish;
			}
			
			if (task.isAllDayEvent==0) {
				continue;
			}
			
			if (task.taskRepeatID==0) {
				continue;
			}
			
			//Task *tmp=[task copy];
			[taskListTmp addObject:task];
			//[tmp release];
		}
	}
	
finish:	
	return taskListTmp;
	
	
	//return [self getAllRecurringADEsWithSearchText:searchText];
}

-(NSMutableArray *)getAllRecurringEventsFromTaskList:(NSMutableArray*)list withSearchText:(NSString *)searchText{
	NSMutableArray *taskListTmp=[NSMutableArray array];
	NSString *searchValue=[searchText length]==0?nil:searchText;
	
    NSMutableArray *sourceList=[NSMutableArray arrayWithArray:list];
	[taskmanager sortListWithAD:sourceList byKey:@"taskRepeatID" isAscending:NO];
	
	if (searchValue) {
		for (Task *task in sourceList) {
			if (task.taskRepeatID==0) {
				goto finish;
			}
			
			if (task.isAllDayEvent==1) {
				continue;
			}
			
			if (task.taskPinned==0) {
				continue;
			}
			
			if ([task.taskName rangeOfString:searchValue].location!= NSNotFound) {
				//Task *tmp=[task copy];
				[taskListTmp addObject:task];
				//[tmp release];
			}
		}
		
	}else {
		for (Task *task in sourceList) {
			if (task.taskRepeatID==0) {
				goto finish;
			}
			
			if (task.isAllDayEvent==1) {
				continue;
			}
			
			if (task.taskPinned==0) {
				continue;
			}
			
			[taskListTmp addObject:task];
		}
	}
	
finish:	
	return taskListTmp;
    
	//return [self getAllRecurringEventsWithSearchText:searchText];
}

-(void)updateHiddenStatusForTaskBelongCalendarId:(NSInteger)calendarId hidden:(NSInteger)hidden{
	if(initializeDatabaseSucess){
		// Get the primary key for all tasks.
		
        NSString *sql =[NSString stringWithFormat:@"UPDATE iVo_Tasks SET isHidden=%ld WHERE Task_Project=%ld",(long)hidden,(long)calendarId];
		
		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
		sqlite3_step(statement);
		sqlite3_finalize(statement);	
		
		
	}else
		printf("Database can not open!");
}

- (void)removeAllTasksBelongCalendar:(NSInteger)calendarId{
	
	NSMutableArray *tasks=[NSMutableArray arrayWithArray:taskmanager.taskList];
	for (Task *task in tasks) {
		if (task.taskProject==calendarId) {
			[taskmanager.taskList removeObject:task];
		}
	}
}

-(void)addTasksToListFromCalendarId:(NSInteger)calendarId{
	if(initializeDatabaseSucess){
		
        NSString *sql = [NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks WHERE Task_Project=%ld",(long)calendarId];
		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				int primaryKey = sqlite3_column_int(statement, 0);
				// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
				// autorelease is slightly more expensive than release. This design choice has nothing to do with
				// actual memory management - at the end of this block of code, all the book objects allocated
				// here will be in memory regardless of whether we use autorelease or release, because they are
				// retained by the books array.
				Task *task = [[Task alloc] getInfoWithPrimaryKey:primaryKey database:database];
				[taskmanager.taskList addObject:task];
				[task release];
			}
		}
		
		// "Finalize" the statement - releases the resources associated with the statement.
		sqlite3_finalize(statement);
	}
}

-(void)addHiddenTasksEventsToList:(NSMutableArray*)list{
    if(initializeDatabaseSucess){
		
		NSString *sql = [NSString stringWithFormat:@"SELECT Task_ID FROM iVo_Tasks WHERE isHidden=1"];
		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				int primaryKey = sqlite3_column_int(statement, 0);
				// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
				// autorelease is slightly more expensive than release. This design choice has nothing to do with
				// actual memory management - at the end of this block of code, all the book objects allocated
				// here will be in memory regardless of whether we use autorelease or release, because they are
				// retained by the books array.
				Task *task = [[Task alloc] getInfoWithPrimaryKey:primaryKey database:database];
				[list addObject:task];
				[task release];
			}
		}
		
		// "Finalize" the statement - releases the resources associated with the statement.
		sqlite3_finalize(statement);
	}
}

#pragma mark end of DB interaction

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	printf("\nMemory warning!");
//	[taskmanager.taskList makeObjectsPerformSelector:@selector(update)];
//	[projectList  makeObjectsPerformSelector:@selector(update)];
}

//- (void)applicationDidBecomeActive:(UIApplication *)application{
	//application.applicationIconBadgeNumber+=1;
//}

-(void)appExit:(id)sender{
    if (taskmanager.currentSetting.enableSyncICal==1 && taskmanager.currentSetting.autoICalSync==1) {
        taskmanager.currentSetting.autoICalSync=0;
        taskmanager.currentSetting.wasHardClosed=1;
        taskmanager.currentSettingModifying.wasHardClosed=1;
        [taskmanager.currentSettingModifying update];
        [taskmanager.currentSetting update];
    }
}

// Save all changes to the database, then close it.
- (void)applicationWillTerminate:(UIApplication *)application {
	//[NSThread detachNewThreadSelector:@selector(createAlarm) toTarget:self withObject:me];
    
    if (taskmanager.currentSetting.enableSyncICal==1 && taskmanager.currentSetting.autoICalSync==1) {
        taskmanager.currentSetting.autoICalSync=0;
        taskmanager.currentSetting.wasHardClosed=1;
        taskmanager.currentSettingModifying.wasHardClosed=1;
        [taskmanager.currentSettingModifying update];
        [taskmanager.currentSetting update];
    }
    
	[self resetBadges:application];
	
	if([smartView superview] && (_smartViewController.interfaceOrientation==UIInterfaceOrientationPortrait || 
								 _smartViewController.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)){
		[_smartViewController cacheImage];
	}
	
	if(taskmanager.currentSetting.cleanOldDayCount>0){
		//if user enable clean data function, we will get tasklist while cleaning
		[self cleanOldDataFromDB];
	}
	// Save changes in Setting.
	//[currentSetting makeObjectsPerformSelector:@selector(update)];
	
	[taskmanager.taskList makeObjectsPerformSelector:@selector(update)];
	[Task finalizeStatements];
	
	NSMutableArray *settingList=[[NSMutableArray alloc] initWithCapacity:1];
	[settingList addObject:taskmanager.currentSetting];
	[settingList makeObjectsPerformSelector:@selector(update)];
	[Setting finalizeStatements];
	[settingList release];
	
	[projectList  makeObjectsPerformSelector:@selector(update)];
	[Projects finalizeStatements];
	
	// Close the database.
    if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(database));
    }
	
	initializeDatabaseSucess=false;	
}

-(void)resetBadges:(UIApplication *)application{
	NSInteger badge=0;
	NSDate *curDate=[NSDate date];
    NSMutableArray *sourceList=[NSMutableArray arrayWithArray:taskmanager.taskList];
    
	switch (taskmanager.currentSetting.badgeType) {
		case TASKS_ALL:
			for(Task *task in sourceList){
				if(task.taskPinned==0 && task.primaryKey>0)
				{
					badge+=1;
				}
			}
			break;
		case TASKS_WITH_DUE_ALL:
			for(Task *task in sourceList){
				if(task.taskPinned==0 && task.primaryKey>0 && task.taskIsUseDeadLine==1)
				{
					badge+=1;
				}
			}
			break;
		case TASKS_WITH_DUE_2_DAYS:
			for(Task *task in sourceList){
				if(task.taskPinned==0 && task.primaryKey>0 && task.taskIsUseDeadLine==1 && 
				   //[[ivoUtility getStringFromShortDate:task.taskDeadLine] compare:[ivoUtility getStringFromShortDate:curDate]]!=NSOrderedAscending &&
				   [[ivoUtility getStringFromShortDate:task.taskDeadLine] compare:[ivoUtility getStringFromShortDate:[curDate dateByAddingTimeInterval:86400]]]!=NSOrderedDescending)
				{
					badge+=1;
				}
			}
			break;
		default:
			break;
	}
	
	application.applicationIconBadgeNumber=badge;
	
}

//----------define for tasks
// Remove a specific task from the array of tasks and also from the database.
// Granular (specific to only the index of the affected setting) Key-Value-Observing notifications will be posted.
/*- (void)removeTaskFromArray:(Task *)task {
 NSUInteger index = [tasks indexOfObject:task];
 // In this application, it's unlikely that this would occur - but it's better to check for such errors.
 if (index == NSNotFound) return;
 // Delete from the database first.
 [task deleteFromDatabase];
 // Create an index set so that we can post a fine-grained notification of the change that occurs.
 // A coarse grained notification would simply indicate that the entire array changed, this indicates the row
 // and type of change.
 NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:index];
 [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexSet forKey:@"Tasks"];
 [tasks removeObject:task];
 [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexSet forKey:@"Tasks"];
 }
 */

// Create a new Task in the database and add it to the array of tasks.
// Granular (specific to only the index of the affected task) Key-Value-Observing notifications will be posted.
- (NSInteger)addTask: (Task *)task {
    // Create a new record in the database and get its automatically generated primary key.
    NSInteger primaryKey = [task prepareNewRecordIntoDatabase:database];
	[task update];
	return primaryKey;
}

//EK Sync
- (NSInteger)addProject: (Projects *)project {
    // Create a new record in the database and get its automatically generated primary key.
    NSInteger primaryKey = [project prepareNewRecordIntoDatabase:database];
	[project update];
	return primaryKey;
}

+ (CGSize) getTimeSize: (CGFloat) size
{
	NSString *am12 = @"12:00 AM";
	UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:size];
	
	return [am12 sizeWithFont:font];
}

-(void)getContextList{
	//context List
	contextList=[[NSMutableArray alloc] initWithCapacity:2];
	[contextList addObject:NSLocalizedString(@"homeText", @"")/*homeText*/];//@"Home"];
	[contextList addObject:NSLocalizedString(@"workText", @"")/*workText*/];//@"Work"];
}

-(void)getIVoStyleList{
	//iVoStyle List
	iVoStyleList=[[NSMutableArray alloc]initWithCapacity:2];
	[iVoStyleList addObject:NSLocalizedString(@"appleBlueText", @"")/*appleBlueText*/];
	[iVoStyleList addObject:NSLocalizedString(@"blackOpaqueText", @"")/*blackOpaqueText*/];
}

-(void)getRepeatList{
	//Repeat Style List
	repeatList=[[NSMutableArray alloc]initWithCapacity:6];
/*	[repeatList addObject:@"None"];
	[repeatList addObject:@"Every Day"];
	[repeatList addObject:@"Every Week"];
	[repeatList addObject:@"Every 2 Weeks"];
	[repeatList addObject:@"Every Month"];
	[repeatList addObject:@"Every Year"];
 */
	[repeatList addObject:NSLocalizedString(@"noneText", @"None")/*noneText*/];//@"None"];
	[repeatList addObject:NSLocalizedString(@"dailyText", @"Daily")/*dailyText*/];//@"Daily"];
	[repeatList addObject:NSLocalizedString(@"weeklyText", @"Weekly")/*weeklyText*/];//@"Weekly"];
	[repeatList addObject:NSLocalizedString(@"monthlyText", @"Monthly")/*monthlyText*/];//@"Monthly"];
	[repeatList addObject:NSLocalizedString(@"yearlyText", @"Yearly")/*yearlyText*/];//@"Yearly"];
}

- (void)getContactList{
	ABAddressBookRef addressBook = ABAddressBookCreate();
	contactList = (NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
	isOpeningContactDB=YES;
}

-(void)getAlertList{
	//Repeat Style List
	alertList=[[NSMutableArray alloc] initWithCapacity:5];
	[alertList insertObject:NSLocalizedString(@"onDateText", @"At time")/*@"At time"*/ atIndex:0];
	[alertList insertObject:@"1" atIndex:1];
	[alertList insertObject:@"2" atIndex:2];
	[alertList insertObject:@"3" atIndex:3];
	[alertList insertObject:@"4" atIndex:4];
	[alertList insertObject:@"5" atIndex:5];
	[alertList insertObject:@"6" atIndex:6];
	[alertList insertObject:@"7" atIndex:7];
	[alertList insertObject:@"8" atIndex:8];
	
	[alertList insertObject:@"9" atIndex:9];
	[alertList insertObject:@"10" atIndex:10];
	[alertList insertObject:@"15" atIndex:11];
	[alertList insertObject:@"20" atIndex:12];
	[alertList insertObject:@"30" atIndex:13];
	[alertList insertObject:@"45" atIndex:14];
	[alertList insertObject:@"90" atIndex:15];
}

- (void)getWhatList{
	whatList=[[NSMutableArray alloc]initWithCapacity:5];
	[whatList addObject:@"Go "];
	[whatList addObject:@"Contact "];
	[whatList addObject:@"Get "];
	[whatList addObject:@"Write mail "];
	[whatList addObject:@"Meet "];
}

/*
 - (void)getTaskMovingStypeList{
 taskMovingStypeList=[[NSMutableArray alloc]initWithCapacity:2];
 [taskMovingStypeList addObject:@"Changeable"];
 [taskMovingStypeList addObject:@"Keep Separate"];
 }
 */
- (void)getDeadlineExpandList{
	deadlineExpandList=[[NSMutableArray alloc]initWithCapacity:2];
	[deadlineExpandList addObject:NSLocalizedString(@"automaticallyText", @"")/*automaticallyText*/];
	[deadlineExpandList addObject:NSLocalizedString(@"promptMeText", @"")/*promptMeText*/];
}

-(void)getSyncTypeList{
/*	syncTypeList=[[NSMutableArray alloc] init];
	[syncTypeList addObject:NSLocalizedString(@"smartSyncGCalText", @"")];
	[syncTypeList addObject:NSLocalizedString(@"smartToGCalText", @"")];
	[syncTypeList addObject:NSLocalizedString(@"gCalToSmartText", @"")];
 */
}

-(void)cleanOldDataFromDB{
	if(initializeDatabaseSucess){
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
		NSDateComponents *comps = [gregorian components:unitFlags fromDate:[NSDate date]];	
		[comps setSecond:0];
		[comps setMinute:0];
		[comps setHour:0];
		
		NSDate *beforeDate=[[[gregorian dateFromComponents:comps] dateByAddingTimeInterval:-taskmanager.currentSetting.cleanOldDayCount*86400] copy];
		double timeIntervalSinceBeforeDate=[beforeDate timeIntervalSince1970]+gmtSeconds;
		
		NSString *sql =[NSString stringWithFormat:@"DELETE FROM iVo_Tasks WHERE task_EndTime<=%lf and Task_Pinned=1 and (Task_RepeatID=0 or (task_RepeatID>0 and Task_RepeatTimes>0 and Set_Resvr6<=%lf))",timeIntervalSinceBeforeDate,timeIntervalSinceBeforeDate];
		
		sqlite3_stmt *statement=nil;
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
		sqlite3_step(statement);
		sqlite3_finalize(statement);	
		
	}else
		printf("Database can not open!");
}

- (void)cleanOldData:(NSInteger)olderDays{
	if(initializeDatabaseSucess){
		tasks=[[NSMutableArray alloc] init];
		// Get the primary key for all tasks.
		//const char *sql = "SELECT Task_ID FROM iVo_Tasks where date(Task_DateUpdate,'unixepoch') =date('now') and Task_Completed=1";
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
		NSDateComponents *comps = [gregorian components:unitFlags fromDate:[NSDate date]];	
		[comps setSecond:0];
		[comps setMinute:0];
		[comps setHour:0];
		
		NSDate *beforeDate=[[[gregorian dateFromComponents:comps] dateByAddingTimeInterval:-taskmanager.currentSetting.cleanOldDayCount*86400] copy];
		
		const char *sql = "SELECT Task_ID FROM iVo_Tasks";
		
		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
			NSString *currentDate=[ivoUtility createStringFromShortDate:[NSDate date]];
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				int primaryKey = sqlite3_column_int(statement, 0);
				Task *task = [[Task alloc] getInfoWithPrimaryKey:primaryKey database:database];
				if([task.taskEndTime compare:beforeDate]==NSOrderedAscending &&
				   !(task.taskPinned==1&&task.taskRepeatID>0 && (task.taskRepeatTimes==0 
					|| task.taskRepeatTimes>0) && [task.taskEndRepeatDate compare:[NSDate date]]==NSOrderedDescending) ){
					[task deleteFromDatabase];
                    
                    if ([task.iCalIdentifier length]>0) {
                        taskmanager.currentSetting.deletedICalEvents=[taskmanager.currentSetting.deletedICalEvents stringByAppendingFormat:@"|%@",task.iCalIdentifier];
                    }
                    if (task.toodledoID>0) {
                        taskmanager.currentSetting.toodledoDeletedTasks=[taskmanager.currentSetting.toodledoDeletedTasks stringByAppendingFormat:@"|%ld",(long)task.toodledoID];
                    }                    
                    
                    [taskmanager.currentSetting update];
                    
				}else if(task.taskCompleted==0){
					[tasks addObject:task];
				}
				[task release];
			}
			[currentDate release];
		}
		
		[gregorian release];
		[beforeDate release];
		sqlite3_finalize(statement);
		
		NSSortDescriptor *date_descriptor = [[NSSortDescriptor alloc] initWithKey:@"taskStartTime"  ascending: YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObject:date_descriptor];
		
		[tasks sortUsingDescriptors:sortDescriptors];	
		
		[taskmanager initTaskList: tasks];
		
	}else
		printf("Database can not open!");
	
}

//
- (void)cleanAllTask{
	if(initializeDatabaseSucess){
		// Get the primary key for all tasks.
		
		const char *sql = "DELETE FROM iVo_Tasks";
		
		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
		sqlite3_step(statement);
		sqlite3_finalize(statement);	
		
		[taskmanager.taskList removeAllObjects];
		
	}else
		printf("Database can not open!");
}

- (void)cleanAllEvents{
	if(initializeDatabaseSucess){
		// Get the primary key for all tasks.
		
		const char *sql = "DELETE FROM iVo_Tasks WHERE Task_Pinned=1";
		
		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
		sqlite3_step(statement);
		sqlite3_finalize(statement);	
		
		NSMutableArray *tmpList=[[NSMutableArray alloc] initWithArray: taskmanager.taskList];
		for (Task *tmp in tmpList){
			if(tmp.taskPinned==1){
				[taskmanager.taskList removeObject:tmp];
			}
		}
		[tmpList release];
	}else
		printf("Database can not open!");
}

- (void)updateDefaultTasks{
	if(initializeDatabaseSucess){
		// Get the primary key for all tasks.
		
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		//unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
		unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit;

		NSDateComponents *comps = [gregorian components:unitFlags fromDate:[NSDate date]];
		[comps setHour:8];
		[comps setSecond:0];
		[comps setMinute:0];
		
		const char *sql = "SELECT Task_ID FROM iVo_Tasks where Task_Default=1";
		
		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
			//sqlite3_bind_int(statement,1, completed);
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				int primaryKey = sqlite3_column_int(statement, 0);
				// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
				// autorelease is slightly more expensive than release. This design choice has nothing to do with
				// actual memory management - at the end of this block of code, all the tasks objects allocated
				// here will be in memory regardless of whether we use autorelease or release, because they are
				// retained by the tasks array.
				Task *task = [[Task alloc] getInfoWithPrimaryKey:primaryKey database:database];
				switch (task.primaryKey) {
					case 1://overdue default Dtask
						//[comps setHour:18];
						task.taskDeadLine=[[gregorian dateFromComponents:comps] dateByAddingTimeInterval:86400];
						task.taskStartTime=[[gregorian dateFromComponents:comps] dateByAddingTimeInterval:86400];
						task.taskEndTime=[task.taskStartTime dateByAddingTimeInterval:task.taskHowLong];
						task.taskDueStartDate=task.taskStartTime;
						task.taskREStartTime=task.taskStartTime;
						task.taskDueEndDate=[task.taskEndTime  dateByAddingTimeInterval:3*5184000];
						task.parentRepeatInstance=-1;
						task.taskRepeatTimes=0;
						task.taskNumberInstances=0;
						break;	
					case 2://indue Dtask
						//[comps setHour:8];
						task.taskDeadLine=[[gregorian dateFromComponents:comps] dateByAddingTimeInterval:2592000];
						task.taskStartTime=[[gregorian dateFromComponents:comps] dateByAddingTimeInterval:90000];;//[gregorian dateFromComponents:comps];
						task.taskEndTime=[task.taskStartTime dateByAddingTimeInterval:task.taskHowLong];
						task.taskREStartTime=task.taskStartTime;
						task.taskDueEndDate=[task.taskEndTime  dateByAddingTimeInterval:3*5184000];
						task.taskDueStartDate=[NSDate date];
						task.parentRepeatInstance=-1;
						task.taskRepeatTimes=0;
						task.taskNumberInstances=0;
						break;
					case 3://today task
						//[comps setHour:9];
						task.taskDeadLine=[[gregorian dateFromComponents:comps] dateByAddingTimeInterval:2592000];
						task.taskStartTime=[[gregorian dateFromComponents:comps] dateByAddingTimeInterval:93600];
						task.taskEndTime=[task.taskStartTime dateByAddingTimeInterval:task.taskHowLong];
						task.taskREStartTime=task.taskStartTime;
						task.taskDueStartDate=[NSDate date];
						task.taskDueEndDate=[task.taskEndTime  dateByAddingTimeInterval:3*5184000];
						task.parentRepeatInstance=-1;
						task.taskRepeatTimes=0;
						task.taskNumberInstances=0;
						break;
					case 4://tomorrow event 1
						//[comps setHour:9];
						task.taskStartTime=[[gregorian dateFromComponents:comps] dateByAddingTimeInterval:86400*2];
						task.taskEndTime=[task.taskStartTime dateByAddingTimeInterval:task.taskHowLong];
						task.taskDeadLine=[[NSDate date] dateByAddingTimeInterval:2592000];
						task.taskREStartTime=task.taskStartTime;
						task.taskDueStartDate=[NSDate date];
						task.taskDueEndDate=[task.taskEndTime  dateByAddingTimeInterval:3*5184000];
						task.parentRepeatInstance=-1;
						task.taskRepeatTimes=0;
						task.taskNumberInstances=0;
						break;
					case 5://tomorrow event 2
						//[comps setHour:11];
						task.taskStartTime=[[gregorian dateFromComponents:comps] dateByAddingTimeInterval:86400*2+3600];
						task.taskEndTime=[task.taskStartTime dateByAddingTimeInterval:task.taskHowLong];
						task.taskREStartTime=task.taskStartTime;
						task.taskDeadLine=[[NSDate date] dateByAddingTimeInterval:2592000];
						task.taskDueStartDate=[NSDate date];
						task.taskDueEndDate=[task.taskEndTime  dateByAddingTimeInterval:3*5184000];
						task.parentRepeatInstance=-1;
						task.taskRepeatTimes=0;
						task.taskNumberInstances=0;
						break;
					case 6://tomorrow event 3
						//[comps setHour:16];
						task.taskStartTime=[[gregorian dateFromComponents:comps] dateByAddingTimeInterval:345600];
						task.taskEndTime=[task.taskStartTime dateByAddingTimeInterval:task.taskHowLong];
						task.taskREStartTime=task.taskStartTime;
						task.taskDeadLine=[[NSDate date] dateByAddingTimeInterval:2592000];
						task.taskDueStartDate=[NSDate date];
						task.taskDueEndDate=[task.taskEndTime  dateByAddingTimeInterval:3*5184000];
						task.parentRepeatInstance=-1;
						task.taskRepeatTimes=0;
						task.taskNumberInstances=0;
						break;
					case 7://tomorrow event 4
						//[comps setHour:8];
						task.taskStartTime=[gregorian dateFromComponents:comps];
						task.taskEndTime=[task.taskStartTime dateByAddingTimeInterval:task.taskHowLong];
						task.taskREStartTime=task.taskStartTime;
						task.taskDeadLine=[[NSDate date] dateByAddingTimeInterval:2*86400];
						task.taskDueStartDate=[[NSDate date] dateByAddingTimeInterval:86400];
						task.taskDueEndDate=[task.taskEndTime  dateByAddingTimeInterval:86400+task.taskHowLong];
						task.taskNotEalierThan=[[NSDate date] dateByAddingTimeInterval:86400];
						task.parentRepeatInstance=-1;
						task.taskRepeatTimes=0;
						task.taskNumberInstances=0;
						break;
						
				}
				task.taskDefault=0;
				[task update];
				[task release];
			}
			
		}
		[gregorian release];
		
		sqlite3_finalize(statement);		
	}else
		printf("Database can not open!");
	
}

-(void)getFullTaskListForBackup{
	tasks=[[NSMutableArray alloc] init];
	
	if(initializeDatabaseSucess){
		// Get the primary key for all tasks.
		const char *sql = "SELECT Task_ID FROM iVo_Tasks";
		
		sqlite3_stmt *statement=nil;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
			//sqlite3_bind_int(statement,1, completed);
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				int primaryKey = sqlite3_column_int(statement, 0);
				// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
				// autorelease is slightly more expensive than release. This design choice has nothing to do with
				// actual memory management - at the end of this block of code, all the tasks objects allocated
				// here will be in memory regardless of whether we use autorelease or release, because they are
				// retained by the tasks array.
				Task *task = [[Task alloc] getInfoWithPrimaryKey:primaryKey database:database];
				[tasks addObject:task];
				[task release];
			}
			
		}
		
		sqlite3_finalize(statement);		
	}else
		printf("Database can not open!");
	
	taskmanager.fullTaskListBackUp=[tasks retain];
	if(tasks!=nil){
		[tasks release];
		tasks=nil;
	}	
}

#pragma mark threads
- (void)create_UIActivityIndView:(UIActivityIndicatorViewStyle)style
{
	CGRect frame = CGRectMake(140, 80, 40, 40);
	progressInd = [[UIActivityIndicatorView alloc] initWithFrame:frame];
	progressInd.activityIndicatorViewStyle = style;
	progressInd.hidesWhenStopped=YES;
	[progressInd sizeToFit];
	progressInd.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
										 UIViewAutoresizingFlexibleRightMargin |
										 UIViewAutoresizingFlexibleTopMargin |
										 UIViewAutoresizingFlexibleBottomMargin);
}

- (void)showAcitivityIndicatorThread{	
	[NSThread detachNewThreadSelector:@selector(showAcitivityIndicator) toTarget:self withObject:nil];		
}

- (void)showAcitivityIndicator{
	 NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	isPreparingShowingActivityClock=YES;
	if(![progressInd isAnimating]){
		[self.window bringSubviewToFront:progressInd];
		[progressInd startAnimating];
	}
	isPreparingShowingActivityClock=NO;
	[pool release];
}

- (void)stopAcitivityIndicatorThread{	
	
	[NSThread detachNewThreadSelector:@selector(stopAcitivityIndicator) toTarget:self withObject:nil];
}

- (void)stopAcitivityIndicator{
	 NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	//while ([progressInd isAnimating])
	//while (isPreparingShowingActivityClock) {
	//}
	
	[progressInd stopAnimating];
	
	[pool release];
}


- (void)createUpContactDisplayList {
	//ILOG(@"[ContactViewConroller setUpDisplayList\n");
	/*
	 Create an array (contacts) of dictionaries
	 Each dictionary groups together the time zones with locale names beginning with a particular letter:
	 key = "letter" value = e.g. "A"
	 key = "contacts" value = [array of dictionaries]
	 
	 Each dictionary in "contacts" contains keys "timeZone" and "timeZoneLocaleName"
	 */
//	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
//	[self showAcitivityIndicatorThread];
	
	if(!isOpeningContactDB){
		[self getContactList];
	}
	
	NSMutableDictionary *indexedContacts = [[NSMutableDictionary alloc] init];
	
	for (int i=0; i< contactList.count; i++){
		
		ABRecordRef ref = CFArrayGetValueAtIndex((CFArrayRef)contactList,(CFIndex)i);
		
		CFStringRef firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
		CFStringRef lastName = ABRecordCopyValue(ref, kABPersonLastNameProperty);
		CFStringRef company = ABRecordCopyValue(ref, kABPersonOrganizationProperty);
		
		//CFStringRef mobile=ABRecordCopyValue(ref,kABPersonPhoneMobileLabel);
		//CFStringRef mphone=ABRecordCopyValue(ref,kABPersonPhoneMainLabel);
		
		if (firstName==nil && lastName==nil && company==nil){
			firstName=(CFStringRef)NSLocalizedString(@"nonameText", @"")/*nonameText*/;
			lastName=(CFStringRef)@" ";
			company=(CFStringRef)@" ";
		}else{
			if(firstName==nil) {
				firstName=(CFStringRef) @" ";
			}
			if(lastName==nil){
				lastName=(CFStringRef)@" ";
			}
			if(company==nil){
				company=(CFStringRef)@" ";
			}
			
		}

		
		NSString *contactName=[NSString stringWithFormat:@"%@ %@",firstName, lastName];
		
		NSString *cName=[contactName copy];
		contactName=[cName stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];//remove new line character;
		contactName=[contactName stringByReplacingOccurrencesOfString:@"\n" withString:@" "];//remove new line character;
		contactName=[contactName stringByReplacingOccurrencesOfString:@"\r" withString:@" "];//remove new line character;
		[cName release];
		
		NSString *contactComName=[NSString stringWithFormat:@"%@",company];
		cName=[contactComName copy];
		contactComName=[cName stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];//remove new line character;
		contactComName=[contactComName stringByReplacingOccurrencesOfString:@"\n" withString:@" "];//remove new line character;
		contactComName=[contactComName stringByReplacingOccurrencesOfString:@"\r" withString:@" "];//remove new line character;
		[cName release];
		
		//printf("\n%s",[contactComName UTF8String]);
		NSString *firstLetter; 
		if([[contactName stringByReplacingOccurrencesOfString:@" " withString:@""] length]>0){
			if([[(NSString *)lastName stringByReplacingOccurrencesOfString:@" " withString:@""] length]>0){
				firstLetter= [[(NSString *)lastName substringToIndex:1] uppercaseString];
			}else if([[(NSString *)firstName stringByReplacingOccurrencesOfString:@" " withString:@""] length]>0){
				firstLetter= [[(NSString *)firstName substringToIndex:1] uppercaseString];			
			}else {
				firstLetter=@"Z#";
			}

		}else if([contactComName length]>0) {
			contactName=contactComName;
			firstLetter= [[contactComName substringToIndex:1] uppercaseString];
		}else {
			contactName=NSLocalizedString(@"nonameText", @"")/*nonameText*/;//@"No Name";
			firstLetter=@"Z#";
		}

		
		if([firstLetter compare:@"A"]==NSOrderedAscending  || [firstLetter compare:@"z"]==NSOrderedDescending)
			firstLetter=@"Z#";
		
		NSMutableArray *indexArray = [indexedContacts objectForKey:firstLetter];
		if (indexArray == nil) {
			indexArray = [[NSMutableArray alloc] init];
			[indexedContacts setObject:indexArray forKey:firstLetter];
			//[indexArray release];
		}
		
		Contacts *contact=[[Contacts alloc] init];
		contact.contactName=contactName;
		
		NSString *contactLastName=[NSString stringWithFormat:@"%@ %@", lastName,firstName];
		contact.contactLastName=contactLastName;
		contact.companyName=contactComName;
		
		//get email address from contact
		ABMutableMultiValueRef multiEmailValue = ABRecordCopyValue(ref, kABPersonEmailProperty);
		if(ABMultiValueGetCount(multiEmailValue)>0){
			CFStringRef emailAddr = ABMultiValueCopyValueAtIndex(multiEmailValue, 0);
			
			if(emailAddr==nil){
				emailAddr=(CFStringRef)@" ";	
			}
			contact.emailAddress=[NSString stringWithFormat:@"%@",emailAddr];
		}
		//[multiEmailValue release];
		CFRelease(multiEmailValue);
		
		
		//get PHONE NUMBER from contact
		ABMutableMultiValueRef phoneEmailValue = ABRecordCopyValue(ref, kABPersonPhoneProperty);
		if(ABMultiValueGetCount(phoneEmailValue)>0){
			contact.phoneNumber=@"";
			
			for(NSInteger i=0;i<ABMultiValueGetCount(phoneEmailValue);i++){
				CFStringRef phoneNo = ABMultiValueCopyValueAtIndex(phoneEmailValue, i);
				CFStringRef label=ABMultiValueCopyLabelAtIndex(phoneEmailValue, i);
				
				if(label==nil){
					label=(CFStringRef)@" ";	
				}
				
				if(phoneNo==nil){
					phoneNo=(CFStringRef)@" ";	
				}
				contact.phoneNumber=[contact.phoneNumber stringByAppendingFormat:@"/%@|%@",label,phoneNo];
			}
		
		}
		CFRelease(phoneEmailValue);
		
		NSString *contactAddress=nil;
		//get first address for this contact
		ABMutableMultiValueRef multiValue = ABRecordCopyValue(ref, kABPersonAddressProperty);
		
		if(ABMultiValueGetCount(multiValue)>0){
			
			//get all address from the contact
			CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(multiValue, 0);
			CFStringRef street = CFDictionaryGetValue(dict, kABPersonAddressStreetKey);
			CFStringRef city = CFDictionaryGetValue(dict, kABPersonAddressCityKey);
			CFStringRef country = CFDictionaryGetValue(dict, kABPersonAddressCountryKey);		
			CFStringRef state = CFDictionaryGetValue(dict,kABPersonAddressStateKey);
			CFStringRef zip = CFDictionaryGetValue(dict,kABPersonAddressZIPKey);
			
			CFRelease(dict);
			
			if(street!=nil){
				contactAddress=[NSString stringWithFormat:@"%@",street];
			}else {
				contactAddress=[NSString stringWithString: @""];
			}
			
			if(city!=nil){
				if(street!=nil){
					NSString *cityNameAppend=[NSString stringWithFormat:@", %@",city];
					contactAddress=[contactAddress stringByAppendingString:cityNameAppend];
				}else{
					NSString *cityNameAsLoc=[NSString stringWithFormat:@"%@",city];
					contactAddress=[contactAddress stringByAppendingString:cityNameAsLoc];
				}
			}
			
			if(country!=nil){
				if(![contactAddress isEqualToString:@""]){
					NSString *countryNameAppend=[NSString stringWithFormat:@", %@",country];
					contactAddress=[contactAddress stringByAppendingString:countryNameAppend];
				}else{
					NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",country];
					contactAddress=[contactAddress stringByAppendingString:countryNameAsLoc];
				}
			}
			
			if(state !=nil){
				if(![contactAddress isEqualToString:@""]){
					NSString *countryNameAppend=[NSString stringWithFormat:@", %@",state];
					contactAddress=[contactAddress stringByAppendingString:countryNameAppend];
				}else{
					NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",state];
					contactAddress=[contactAddress stringByAppendingString:countryNameAsLoc];
				}
			}
			
			if(zip !=nil){
				if(![contactAddress isEqualToString:@""]){
					NSString *countryNameAppend=[NSString stringWithFormat:@", %@",zip];
					contactAddress=[contactAddress stringByAppendingString:countryNameAppend];
				}else{
					NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",zip];
					contactAddress=[contactAddress stringByAppendingString:countryNameAsLoc];
				}
			}
			
		}else {
			contactAddress=[NSString stringWithString: @""];
		}
		
			
/*			
			///
			CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(multiValue, 0);
			CFStringRef street = CFDictionaryGetValue(dict, kABPersonAddressStreetKey);
			CFStringRef city = CFDictionaryGetValue(dict, kABPersonAddressCityKey);
			CFStringRef country = CFDictionaryGetValue(dict, kABPersonAddressCountryKey);		

			CFRelease(dict);
			
			if(street!=nil){
				contactAddress=[NSString stringWithFormat:@"%@",street];
			}else {
				contactAddress=@"";
			}
			
			if(city!=nil){
				if(street!=nil){
					contactAddress=[contactAddress stringByAppendingString:[NSString stringWithFormat:@", %@",city]];
				}else {
					contactAddress=[contactAddress stringByAppendingString:[NSString stringWithFormat:@"%@",city]] ;
				}
			}
			
			if(country !=nil){
				if(![contactAddress isEqualToString:@""]){
					contactAddress=[contactAddress stringByAppendingString:[NSString stringWithFormat:@", %@",country]];
				}else {
					contactAddress=[contactAddress stringByAppendingString:[NSString stringWithFormat:@"%@",country]] ;
				}
				
			}
			
			
		}else {
			contactAddress=[NSString stringWithString: @""];
		}
		
*/		
		contact.contactAddress=[contactAddress stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];//remove the newline character
		contact.contactAddress=[contact.contactAddress stringByReplacingOccurrencesOfString:@"\n" withString:@" "];//remove new line character;
		contact.contactAddress=[contact.contactAddress stringByReplacingOccurrencesOfString:@"\r" withString:@" "];//remove new line character;
		
		NSDictionary *contactDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:contact, @"contacts", [[contact contactLastName] capitalizedString], @"contactName", nil];
		[indexArray addObject:contactDictionary];
		
		[contact release];
	
		CFRelease(multiValue);
		
	}
	
	/*
	 Finish setting up the data structure:
	 Create the contacts array;
	 Sort the used index letters and keep as an instance variable;
	 Sort the contents of the contacts arrays;
	 */
	NSMutableArray *contacts = [[NSMutableArray alloc] init];
	
	// Normally we'd use a localized comparison to present information to the user, but here we know the data only contains unaccented uppercase letters
	self.indexContactLetters = [[indexedContacts allKeys] sortedArrayUsingSelector:@selector(compare:)];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"contactName" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	
	for (NSString *indexLetter in self.indexContactLetters) {
		
		NSMutableArray *contactDictionaries = [indexedContacts objectForKey:indexLetter];
		[contactDictionaries sortUsingDescriptors:sortDescriptors];
		
		NSDictionary *letterDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:indexLetter, @"letter", contactDictionaries, @"contacts", nil];
		[contacts addObject:letterDictionary];
		[letterDictionary release];
	}
	[sortDescriptor release];
	
	if(contactDisplayList !=nil)
		[contactDisplayList release];
		
	contactDisplayList =[[NSArray alloc] initWithArray: contacts];
	[contacts release];
	[indexedContacts release];
	
	isLoadingContact=YES;
	//[pool release];
	
//	[self stopAcitivityIndicatorThread];
	//ILOG(@"ContactViewConroller setUpDisplayList]\n");
}

- (void)createUpLocationDisplayList:(BOOL)isSortByName {
	//ILOG(@"[SmartViewController setUpDisplayList\n");
	/*
	 Create an array (contacts) of dictionaries
	 Each dictionary groups together the time zones with locale names beginning with a particular letter:
	 key = "letter" value = e.g. "A"
	 key = "contacts" value = [array of dictionaries]
	 
	 Each dictionary in "contacts" contains keys "timeZone" and "timeZoneLocaleName"
	 */
//	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSMutableDictionary *indexedContacts = [[NSMutableDictionary alloc] init];
	
	for (int i=0; i< contactList.count; i++){
		
		ABRecordRef record = [contactList objectAtIndex:i];
		
		ABMutableMultiValueRef multiValue = ABRecordCopyValue(record, kABPersonAddressProperty);
		
		if(ABMultiValueGetCount(multiValue)>0){
			
			for(int j=0; j<ABMultiValueGetCount(multiValue);j++){//get all address from a contact
				CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(multiValue, j);
				CFStringRef street = CFDictionaryGetValue(dict, kABPersonAddressStreetKey);
				CFStringRef city = CFDictionaryGetValue(dict, kABPersonAddressCityKey);
				CFStringRef country = CFDictionaryGetValue(dict, kABPersonAddressCountryKey);		
				CFStringRef state = CFDictionaryGetValue(dict,kABPersonAddressStateKey);
				CFStringRef zip = CFDictionaryGetValue(dict,kABPersonAddressZIPKey);
				
				
				CFRelease(dict);
				
				NSString *locationName;
				if(street!=nil){
					locationName=[NSString stringWithFormat:@"%@",street];
				}else {
					locationName=[NSString stringWithString: @""];
				}
				
				if(city!=nil){
					if(street!=nil){
						NSString *cityNameAppend=[NSString stringWithFormat:@", %@",city];
						locationName=[locationName stringByAppendingString:cityNameAppend];
					}else{
						NSString *cityNameAsLoc=[NSString stringWithFormat:@"%@",city];
						locationName=[locationName stringByAppendingString:cityNameAsLoc];
					}
				}
				
				if(country!=nil){
					if(![locationName isEqualToString:@""]){
						NSString *countryNameAppend=[NSString stringWithFormat:@", %@",country];
						locationName=[locationName stringByAppendingString:countryNameAppend];
					}else{
						NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",country];
						locationName=[locationName stringByAppendingString:countryNameAsLoc];
					}
				}
				
				if(state !=nil){
					if(![locationName isEqualToString:@""]){
						NSString *countryNameAppend=[NSString stringWithFormat:@", %@",state];
						locationName=[locationName stringByAppendingString:countryNameAppend];
					}else{
						NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",state];
						locationName=[locationName stringByAppendingString:countryNameAsLoc];
					}
				}
				
				if(zip !=nil){
					if(![locationName isEqualToString:@""]){
						NSString *countryNameAppend=[NSString stringWithFormat:@", %@",zip];
						locationName=[locationName stringByAppendingString:countryNameAppend];
					}else{
						NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",zip];
						locationName=[locationName stringByAppendingString:countryNameAsLoc];
					}
				}
				
				NSString *locFull=[locationName copy];
				locationName=[locFull stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];//remove new line character;
				locationName=[locationName stringByReplacingOccurrencesOfString:@"\n" withString:@" "];//remove new line character;
				locationName=[locationName stringByReplacingOccurrencesOfString:@"\r" withString:@" "];//remove ; character;

				[locFull release];
				
				if( !isSortByName){
					
					NSString *firstLetter;
					if([[locationName stringByReplacingOccurrencesOfString:@" " withString:@""] length]<1){
						firstLetter=@"Z#";
					}else {
						firstLetter = [[locationName substringToIndex:1] uppercaseString];
					}
					
					if([firstLetter compare:@"A"]==NSOrderedAscending  || [firstLetter compare:@"z"]==NSOrderedDescending)
						firstLetter=@"Z#";
					
					NSMutableArray *indexArray = [indexedContacts objectForKey:firstLetter];
					if (indexArray == nil) {
						indexArray = [[NSMutableArray alloc] init];
						[indexedContacts setObject:indexArray forKey:firstLetter];
						//[indexArray release];
					}
					NSDictionary *contactDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:locationName, @"locations", locationName, @"locationLocaleName", nil];
					[indexArray addObject:contactDictionary];
					[contactDictionary release];

				}else {
					//ABRecordRef ref = CFArrayGetValueAtIndex((CFArrayRef)contactList,(CFIndex)i);
					
					CFStringRef firstName = ABRecordCopyValue(record, kABPersonFirstNameProperty);
					CFStringRef lastName = ABRecordCopyValue(record, kABPersonLastNameProperty);
					
					if (firstName==nil && lastName==nil){
						firstName=(CFStringRef)@"No name";
						lastName=(CFStringRef)@" ";
					}else if(firstName==nil) {
						firstName=(CFStringRef) @" ";
					}else if(lastName==nil){
						lastName=(CFStringRef)@" ";
					}
					
					NSString *contactName=[[NSString  alloc] initWithFormat:@"%@ %@",firstName, lastName];
					
					NSString *firstLetter = contactName;
					NSMutableArray *indexArray = [indexedContacts objectForKey:firstLetter];
					if (indexArray == nil) {
						indexArray = [[NSMutableArray alloc] init];
						[indexedContacts setObject:indexArray forKey:firstLetter];
						//						[indexArray release];
					}
					NSDictionary *contactDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:locationName, @"locations", locationName, @"locationLocaleName", nil];
					[indexArray addObject:contactDictionary];
					[contactDictionary release];
					[contactName release];
				}
			}
		}
		CFRelease(multiValue);
	}
	
	/*
	 Finish setting up the data structure:
	 Create the contacts array;
	 Sort the used index letters and keep as an instance variable;
	 Sort the contents of the contacts arrays;
	 */
	NSMutableArray *locations = [[NSMutableArray alloc] init];
	
	// Normally we'd use a localized comparison to present information to the user, but here we know the data only contains unaccented uppercase letters
	if(isSortByName){
		self.indexLocationByNameLetters = [[indexedContacts allKeys] sortedArrayUsingSelector:@selector(compare:)];
	}else {
		self.indexLocationByContactLetters= [[indexedContacts allKeys] sortedArrayUsingSelector:@selector(compare:)];
	}

	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"locationLocaleName" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	
	NSString *indexLetterTmp;
	NSArray *indexLetters=isSortByName? self.indexLocationByNameLetters: self.indexLocationByContactLetters;
	for (indexLetterTmp in indexLetters) {		
		NSMutableArray *locaionDictionaries = [indexedContacts objectForKey:indexLetterTmp];
		[locaionDictionaries sortUsingDescriptors:sortDescriptors];
		
		NSString *indexLetter= [indexLetterTmp copy];
		NSDictionary *letterDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:indexLetter, @"letter", locaionDictionaries, @"locations", nil];
		[locations addObject:letterDictionary];
		[indexLetter release];
		[letterDictionary release];
	}
	[sortDescriptor release];
	
	if(isSortByName){
		if(locationDisplayListByName!=nil)
			[locationDisplayListByName release];
		
		locationDisplayListByName =[[NSArray alloc] initWithArray: locations];
		
	}else {
		if(locationDisplayListByContact!=nil)
			[locationDisplayListByContact release];
		
		locationDisplayListByContact =[[NSArray alloc] initWithArray: locations];
	}

	[locations release];
	[indexedContacts release];
	
//	[pool release];
	//ILOG(@"SmartViewController setUpDisplayList]\n");
}

-(void)createTwoLocationDisplayList{
	
//	[self showAcitivityIndicatorThread];
	if(!isOpeningContactDB){
		[self getContactList];
	}	
	[self createUpLocationDisplayList:YES];
	[self createUpLocationDisplayList:NO];
	
	isLoadingLocation=YES;
//	[self stopAcitivityIndicatorThread];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{   
	//parameter format: _!$!_taskName_!$!_taskLocation_!$!_taskDescription_!$!_taskPinned_!$!_taskHowLong_!$!_taskWhere_!$!_taskProject
	//"_!$!_" used to separate parameters
	//"_!$$!_" replace for "#"
	//"_!$$_" replace for "&"
	//"_$$!_" replace for "?"
	//"_$$$_" replace for " "
	//"_!!$_" separate tasks
	//"_$!$_" replace for new line character
	//"_!!$$_" replace for "/" character
	//"_!!!_" replcase for "%" character
	//"_!!!$_" replace for "%40" character when decoding
	
	
//	if(!initializeDatabaseSucess){
//		[self createEditableCopyOfDatabaseIfNeeded];
//		[self initializeDatabase];
//	}
	
	_inExternalLaunch = YES;
	
	//[self startup];
	
	//_didStartup=NO;
	
//	UIAlertView *openURLAlerttmp = [[UIAlertView alloc] initWithTitle:@"opening ST" message:nil delegate:nil cancelButtonTitle:okText otherButtonTitles:nil];
//	[openURLAlerttmp show];
//	[openURLAlerttmp release];
	
//	while (!_didStartup) {
//		[NSThread sleepForTimeInterval:0.01];
//	}
	
    if (!url) {
        // The URL is nil. There's nothing more to do.
        return NO;
    }
    
    self.currentURL=url;
	if([@"/importDatabase" isEqual:[url path]]) {
		if(!isAgreedToImport){
			importAlert=[[UIAlertView alloc] initWithTitle:@"Restore Smart Time database" 
												   message:@"Restoring database from the backed up will overwrite your current database and you will need to restart the app after finished. Are you sure?" 
												  delegate:self
										 cancelButtonTitle:@"Cancel"
										 otherButtonTitles:nil];
			
			[importAlert addButtonWithTitle:@"Ok"];
			[importAlert show];
			[importAlert release];
			return YES;
		}
		
        NSString *query = [url query];
        NSString *importUrlData = (NSString *)[GTMBase64 webSafeDecodeString:query];
		
        // NOTE: In practice you will want to prompt the user to confirm before you overwrite their files!
		NSString *filename = @"IvoDatabase.sql";
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *uniquePath = [documentsDirectory stringByAppendingPathComponent: filename];
		
        [importUrlData writeToFile:uniquePath atomically:YES];
		
		finishedAlert=[[UIAlertView alloc] initWithTitle:@"Restore backed up database successfully!" 
												 message:@"Your backed up database has been restored successfully! Please restart your app. Thanks." 
												delegate:self
									   cancelButtonTitle:@"OK"
									   otherButtonTitles:nil];
		[finishedAlert show];
		[finishedAlert release];
		isAgreedToImport=NO;
        return YES;
    }else {
	/*	UIAlertView *errorAlert=[[UIAlertView alloc] initWithTitle:@"Restore backed up database failed!" 
														   message:@"Could not restore database from the backed up." 
														  delegate:self
												 cancelButtonTitle:@"OK"
												 otherButtonTitles:nil];
		[errorAlert show];
		[errorAlert release];
	}
	*/
        NSString *taskParameters = [[url parameterString] copy];
        
        if (!taskParameters) {
            // The URL's absoluteString is nil. There's nothing more to do.
            [taskParameters release];
            return NO;
        }
        //for old version
        NSString *decodedStr=[taskParameters stringByReplacingOccurrencesOfString:@"%40" withString:@"_!!!$_"];
        
        decodedStr= [decodedStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        decodedStr=[decodedStr stringByReplacingOccurrencesOfString:@"_!!!$_" withString:@"%40"];
        
        decodedStr=[decodedStr stringByReplacingOccurrencesOfString:@"_!!!_" withString:@"%"];
        
        //NSData *dest = [NSDataBase64 dataWithBase64EncodedString:decodedStr];
        //decodedStr=[[NSString alloc] initWithData:dest encoding:NSUnicodeStringEncoding];
        if([decodedStr length]<1){
            [taskParameters release];
            return NO;
        }
        
        //[NSTimer scheduledTimerWithTimeInterval:0 target:self selecttor:@selector(updateData:) userInfo:decodedStr repeats:NO];
        [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(updateData:) userInfo:decodedStr repeats:NO];	
        [taskParameters release];
    }
    return YES;
}

-(void)updateData:(id)sender{
	
	me.networkActivityIndicatorVisible=YES;
	NSTimer *timer=sender;
	
	NSString *decodedStr=[timer userInfo];
	
	if([[decodedStr substringToIndex:5] isEqualToString:@"_$!!_"]){//restore
		NSArray *parseURLParameters=[NSArray arrayWithArray:[decodedStr componentsSeparatedByString:@"_$!!_"]];
		
		if(parseURLParameters.count<4){
			//[taskParameters release];
			//NSString *lastDecodeStr=[decodedStr substringFromIndex:[decodedStr length] -200];
			UIAlertView *openURLAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"restoreBrokenLinkErrorMessageText", @"")/*restoreBrokenLinkErrorMessageText*/ message:@"" delegate:nil cancelButtonTitle:NSLocalizedString(@"yesText", @"")/*yesText*/ otherButtonTitles:nil];
			//UIAlertView *openURLAlert = [[UIAlertView alloc] initWithTitle:lastDecodeStr message:@"" delegate:nil cancelButtonTitle:okText otherButtonTitles:nil];
			[openURLAlert show];
			[openURLAlert release];
			me.networkActivityIndicatorVisible=NO;
			return;
		}
		/////////////////////////////////////////////////////////////////////////////
		//restore settings
		//////////////////////////////////////////////////////////////////////////////
		
		NSString *backupSettingStr=[(NSString *)[parseURLParameters objectAtIndex:2] copy];
		if(![backupSettingStr isEqualToString:@""]){
			NSString *decodeTaskParameterStr=[backupSettingStr stringByReplacingOccurrencesOfString:@"_!$!_" withString:@" "];//decode "_!$!_" character
			NSString *decodeTaskSpecialChar1=[decodeTaskParameterStr stringByReplacingOccurrencesOfString:@"_!$$!_" withString:@"#"];//decode "#" character
			NSString *decodeTaskSpecialChar2=[decodeTaskSpecialChar1 stringByReplacingOccurrencesOfString:@"_$$!_" withString:@"?"];//decode "?" character
			NSString *decodeTaskSpecialChar3=[decodeTaskSpecialChar2 stringByReplacingOccurrencesOfString:@"_!$$_" withString:@"&"];//decode "&" character
			decodeTaskSpecialChar3=[decodeTaskSpecialChar3 stringByReplacingOccurrencesOfString:@"_$!$_" withString:@"\n"];//decode "\n" character
			decodeTaskSpecialChar3=[decodeTaskSpecialChar3 stringByReplacingOccurrencesOfString:@"_!!$$_" withString:@"/"];
			decodeTaskSpecialChar3=[decodeTaskSpecialChar3 stringByReplacingOccurrencesOfString:@"_$!!$_" withString:@"|"];
			
			
			NSArray *fullTaskParameters=[NSArray arrayWithArray:[decodeTaskSpecialChar3 componentsSeparatedByString:@" "]];
			
			NSInteger parameterCount=fullTaskParameters.count;
			
			//UIAlertView *taskPropertiesCountView=[[UIAlertView alloc] initWithTitle:@"Task properties count:" message:[NSString stringWithFormat:@"%d",parameterCount] delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:nil];
			//[taskPropertiesCountView show];
			//[taskPropertiesCountView release];
			
			if(parameterCount>0)
				taskmanager.currentSetting.alarmSoundName=[[(NSString *)[fullTaskParameters objectAtIndex:0] stringByReplacingOccurrencesOfString:@"_$$$_" withString:@" "] retain];
			if([taskmanager.currentSetting.alarmSoundName isEqualToString:@"NoSound"])
				taskmanager.currentSetting.alarmSoundName=nil;
			if(parameterCount>1)
				taskmanager.currentSetting.deskTimeStart=[NSDate dateWithTimeIntervalSince1970: [[fullTaskParameters objectAtIndex:1] doubleValue]];
			
			if(parameterCount>2)
				taskmanager.currentSetting.deskTimeEnd=[NSDate dateWithTimeIntervalSince1970: [[fullTaskParameters objectAtIndex:2] doubleValue]];
			
			if(parameterCount>3)
				taskmanager.currentSetting.deskTimeWEStart=[NSDate dateWithTimeIntervalSince1970: [[fullTaskParameters objectAtIndex:3] doubleValue]];
			
			if(parameterCount>4)
				taskmanager.currentSetting.deskTimeWEEnd=[NSDate dateWithTimeIntervalSince1970: [[fullTaskParameters objectAtIndex:4] doubleValue]];
			
			if(parameterCount>5)
				taskmanager.currentSetting.homeTimeNDStart=[NSDate dateWithTimeIntervalSince1970: [[fullTaskParameters objectAtIndex:5] doubleValue]];
			
			if(parameterCount>6)
				taskmanager.currentSetting.homeTimeNDEnd=[NSDate dateWithTimeIntervalSince1970: [[fullTaskParameters objectAtIndex:6] doubleValue]];
			
			if(parameterCount>7)
				taskmanager.currentSetting.homeTimeWEStart=[NSDate dateWithTimeIntervalSince1970: [[fullTaskParameters objectAtIndex:7] doubleValue]];
			
			if(parameterCount>8)
				taskmanager.currentSetting.homeTimeWEEnd=[NSDate dateWithTimeIntervalSince1970: [[fullTaskParameters objectAtIndex:8] doubleValue]];
			
			if(parameterCount>9)
				taskmanager.currentSetting.iVoStyleID=[[fullTaskParameters objectAtIndex:9] intValue];
			
			if(parameterCount>10)
				taskmanager.currentSetting.howlongDefVal=[[fullTaskParameters objectAtIndex:10] intValue];
			
			if(parameterCount>11)
				taskmanager.currentSetting.contextDefID=[[fullTaskParameters objectAtIndex:11] intValue];
			
			if(parameterCount>12)
				taskmanager.currentSetting.projectDefID=[[fullTaskParameters objectAtIndex:12] intValue];
			
			if(parameterCount>13)
				taskmanager.currentSetting.primaryKey=[[fullTaskParameters objectAtIndex:13] intValue];
			
			if(parameterCount>14)
				taskmanager.currentSetting.taskMovingStyle=[[fullTaskParameters objectAtIndex:14] intValue];
			
			if(parameterCount>15)
				taskmanager.currentSetting.dueWhenMove=[[fullTaskParameters objectAtIndex:15] intValue];
			
			if(parameterCount>16)
				taskmanager.currentSetting.pushTaskFoward=[[fullTaskParameters objectAtIndex:16] intValue];
			
			if(parameterCount>17)
				taskmanager.currentSetting.cleanOldDayCount=[[fullTaskParameters objectAtIndex:17] intValue];
			
			if(parameterCount>18)
				taskmanager.currentSetting.isFirstTimeStart=[[fullTaskParameters objectAtIndex:18] intValue];
			
			if(parameterCount>19)
				taskmanager.currentSetting.gCalAccount=[[(NSString *)[fullTaskParameters objectAtIndex:19] stringByReplacingOccurrencesOfString:@"_$$$_" withString:@" "] retain];
			if([taskmanager.currentSetting.gCalAccount isEqualToString:@"NoGCalACCount"])
				taskmanager.currentSetting.gCalAccount=nil;
			
			if(parameterCount>20)
				taskmanager.currentSetting.lastSyncedTime=[NSDate dateWithTimeIntervalSince1970: [[fullTaskParameters objectAtIndex:20] doubleValue]];
			
			[taskmanager.currentSetting update];
			
		}
		
		//printf("\n number of setting properties:%d",parameterCount);
		[backupSettingStr release];
		
		/////////////////////////////////////////////////////////////////////////////
		//restore Projects
		//////////////////////////////////////////////////////////////////////////////
		NSString *projListStr=[(NSString *)[parseURLParameters objectAtIndex:3] copy];
		if(![projListStr isEqualToString:@""]){
			NSArray *projList=[NSArray arrayWithArray:[projListStr componentsSeparatedByString:@"_!!$_"]];
			
            if(projList>0){
                NSMutableArray *arr=[NSMutableArray arrayWithArray:projectList];
                for (Projects *prj in arr) {
                    [prj deleteFromDatabase];
                }
            }
            
            [projectList removeAllObjects];

			for (NSInteger i=1;i<projList.count;i++){
				NSString *projStr=[(NSString *)[projList objectAtIndex:i] copy];	
				NSString *decodeTaskParameterStr=[projStr stringByReplacingOccurrencesOfString:@"_!$!_" withString:@" "];//decode "_!$!_" character
				NSString *decodeTaskSpecialChar1=[decodeTaskParameterStr stringByReplacingOccurrencesOfString:@"_!$$!_" withString:@"#"];//decode "#" character
				NSString *decodeTaskSpecialChar2=[decodeTaskSpecialChar1 stringByReplacingOccurrencesOfString:@"_$$!_" withString:@"?"];//decode "?" character
				NSString *decodeTaskSpecialChar3=[decodeTaskSpecialChar2 stringByReplacingOccurrencesOfString:@"_!$$_" withString:@"&"];//decode "&" character
				decodeTaskSpecialChar3=[decodeTaskSpecialChar3 stringByReplacingOccurrencesOfString:@"_$!$_" withString:@"\n"];
				decodeTaskSpecialChar3=[decodeTaskSpecialChar3 stringByReplacingOccurrencesOfString:@"_!!$$_" withString:@"/"];
				decodeTaskSpecialChar3=[decodeTaskSpecialChar3 stringByReplacingOccurrencesOfString:@"_$!!$_" withString:@"|"];
				
				NSArray *fullTaskParameters=[NSArray arrayWithArray:[decodeTaskSpecialChar3 componentsSeparatedByString:@" "]];
				
				NSInteger projPropCount=fullTaskParameters.count;
                
                    
                Projects *tmpProj=[[Projects alloc] init];
                
                if(projPropCount>0)
                    tmpProj.primaryKey=[[fullTaskParameters objectAtIndex:0] intValue];
                
                if(projPropCount>1)
                    tmpProj.projName=[[(NSString *)[fullTaskParameters objectAtIndex:1] stringByReplacingOccurrencesOfString:@"_$$$_" withString:@" "] retain];
                
                if([tmpProj.projName isEqualToString:@"NoProName"])
                    tmpProj.projName=@"";
                
                tmpProj.projectOrder=i;
				tmpProj.colorId=(arc4random() %8);
				tmpProj.groupId=(arc4random() %4);
				
                //printf("\n number of project properties:%d",projPropCount);
                
                [tmpProj prepareNewRecordIntoDatabase:database];
                [tmpProj update];
                [tmpProj release];                
			}
		}
		
		[projListStr release];
		[self getProjectList];
		
		
		/////////////////////////////////////////////////////////////////////////////
		//restore task list
		//////////////////////////////////////////////////////////////////////////////
		
		//clean existing tasks for restoring
		[self cleanAllTask];
		
		//get task list
		NSString *taskStr=(NSString *)[parseURLParameters objectAtIndex:1];
		
		if(![taskStr isEqualToString:@""]){
			NSArray *taskList=[NSArray arrayWithArray:[taskStr componentsSeparatedByString:@"_!!$_"]];
			
			for (NSInteger i=1;i<taskList.count;i++){
				
				NSString *taskStr=[(NSString *)[taskList objectAtIndex:i] copy];	
				NSString *decodeTaskParameterStr=[taskStr stringByReplacingOccurrencesOfString:@"_!$!_" withString:@" "];//decode "_!$!_" character
				NSString *decodeTaskSpecialChar1=[decodeTaskParameterStr stringByReplacingOccurrencesOfString:@"_!$$!_" withString:@"#"];//decode "#" character
				NSString *decodeTaskSpecialChar2=[decodeTaskSpecialChar1 stringByReplacingOccurrencesOfString:@"_$$!_" withString:@"?"];//decode "?" character
				NSString *decodeTaskSpecialChar3=[decodeTaskSpecialChar2 stringByReplacingOccurrencesOfString:@"_!$$_" withString:@"&"];//decode "&" character
				decodeTaskSpecialChar3=[decodeTaskSpecialChar3 stringByReplacingOccurrencesOfString:@"_$!$_" withString:@"\n"];
				decodeTaskSpecialChar3=[decodeTaskSpecialChar3 stringByReplacingOccurrencesOfString:@"_!!$$_" withString:@"/"];
				decodeTaskSpecialChar3=[decodeTaskSpecialChar3 stringByReplacingOccurrencesOfString:@"_$!!$_" withString:@"|"];
				
				NSArray *fullTaskParameters=[NSArray arrayWithArray:[decodeTaskSpecialChar3 componentsSeparatedByString:@" "]];
				
				NSInteger taskPropertiesCount=fullTaskParameters.count;
				
				//printf("\n number of Task properties:%d",taskPropertiesCount);
				
				//UIAlertView *taskPropertiesCountView=[[UIAlertView alloc] initWithTitle:@"Task properties count:" message:[NSString stringWithFormat:@"%d",taskPropertiesCount] delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:nil];
				//[taskPropertiesCountView show];
				//[taskPropertiesCountView release];
				
				if(self.urlTask !=nil){
					[self.urlTask release];	
				}
				self.urlTask=[[Task alloc] init];
				if(taskPropertiesCount>0)
					self.urlTask.taskName=[[(NSString *)[fullTaskParameters objectAtIndex:0] stringByReplacingOccurrencesOfString:@"_$$$_" withString:@" "] retain];//"%C2%A7"
				
				if(taskPropertiesCount>1)
					self.urlTask.taskLocation=[[(NSString *)[fullTaskParameters objectAtIndex:1] stringByReplacingOccurrencesOfString:@"_$$$_" withString:@" "] retain];
				if([self.urlTask.taskLocation isEqualToString:@"NoLocation"])
					self.urlTask.taskLocation=@"";
				
				if(taskPropertiesCount>2)
					self.urlTask.taskDescription=[[(NSString *)[fullTaskParameters objectAtIndex:2] stringByReplacingOccurrencesOfString:@"_$$$_" withString:@" "] retain];
				if([self.urlTask.taskDescription isEqualToString:@"NoNotes"])
					self.urlTask.taskDescription=@"";
				
				if(taskPropertiesCount>3)
					self.urlTask.taskPinned=[[fullTaskParameters objectAtIndex:3] intValue];
				
				if(taskPropertiesCount>4)
					self.urlTask.taskHowLong=[[fullTaskParameters objectAtIndex:4] intValue];
				
				if(taskPropertiesCount>5)
					self.urlTask.taskWhere=[[fullTaskParameters objectAtIndex:5] intValue];
				
				if(taskPropertiesCount>6)
					self.urlTask.taskProject=[[fullTaskParameters objectAtIndex:6] intValue];
				
				if(taskPropertiesCount>7)
					self.urlTask.taskStartTime=[NSDate dateWithTimeIntervalSince1970: [[fullTaskParameters objectAtIndex:7] doubleValue]];
				
				if(taskPropertiesCount>8)
					self.urlTask.taskDeadLine=[NSDate dateWithTimeIntervalSince1970: [[fullTaskParameters objectAtIndex:8] doubleValue]];
				
				if(taskPropertiesCount>9)
					self.urlTask.taskIsUseDeadLine=[[fullTaskParameters objectAtIndex:9] intValue];
				
				if(taskPropertiesCount>10)
					self.urlTask.taskEndTime=[NSDate dateWithTimeIntervalSince1970: [[fullTaskParameters objectAtIndex:10] doubleValue]];
				
				if(taskPropertiesCount>11)
					self.urlTask.taskDueStartDate=[NSDate dateWithTimeIntervalSince1970: [[fullTaskParameters objectAtIndex:11] doubleValue]];
				
				if(taskPropertiesCount>12)
					self.urlTask.taskDueEndDate=[NSDate dateWithTimeIntervalSince1970: [[fullTaskParameters objectAtIndex:12] doubleValue]];
				
				//if(taskPropertiesCount>13)
				//	self.urlTask.taskDateUpdate=[NSDate dateWithTimeIntervalSince1970: [[fullTaskParameters objectAtIndex:13] doubleValue]];
				
				if(taskPropertiesCount>14)
					self.urlTask.taskREStartTime=[NSDate dateWithTimeIntervalSince1970: [[fullTaskParameters objectAtIndex:14] doubleValue]];				
				if(taskPropertiesCount>15)
					self.urlTask.taskStatus=[[fullTaskParameters objectAtIndex:15] intValue];
				
				if(taskPropertiesCount>16)
					self.urlTask.taskCompleted=[[fullTaskParameters objectAtIndex:16] intValue];
				
				self.urlTask.isUsedExternalUpdateTime=YES;
				if(taskPropertiesCount>13)
					self.urlTask.taskDateUpdate=[NSDate dateWithTimeIntervalSince1970: [[fullTaskParameters objectAtIndex:13] doubleValue]];

				
				if(taskPropertiesCount>17)
					self.urlTask.taskOriginalWhere=[[fullTaskParameters objectAtIndex:17] intValue];
				
				if(taskPropertiesCount>18)
					self.urlTask.taskTypeUpdate=[[fullTaskParameters objectAtIndex:18] intValue];
				
				if(taskPropertiesCount>19)
					self.urlTask.taskDefault=[[fullTaskParameters objectAtIndex:19] intValue];
				
				if(taskPropertiesCount>20)
					self.urlTask.taskRepeatID=[[fullTaskParameters objectAtIndex:20] intValue];
				
				if(taskPropertiesCount>21)
					self.urlTask.taskRepeatTimes=[[fullTaskParameters objectAtIndex:21] intValue];
				
				if(taskPropertiesCount>22)
					self.urlTask.taskContact=[[(NSString *)[fullTaskParameters objectAtIndex:22] stringByReplacingOccurrencesOfString:@"_$$$_" withString:@" "] retain];
				if([self.urlTask.taskContact isEqualToString:@"NoContact"])
					self.urlTask.taskContact=@"";
				
				if(taskPropertiesCount>23)
					self.urlTask.taskAlertID=[[fullTaskParameters objectAtIndex:23] intValue];
				
				if(taskPropertiesCount>24)
					self.urlTask.taskNotEalierThan=[NSDate dateWithTimeIntervalSince1970: [[fullTaskParameters objectAtIndex:24] doubleValue]];
				
				if(taskPropertiesCount>25)
					self.urlTask.gcalEventId=[[(NSString *)[fullTaskParameters objectAtIndex:25] stringByReplacingOccurrencesOfString:@"_$$$_" withString:@" "] retain];
				if([self.urlTask.gcalEventId isEqualToString:@"NoMail"])
					self.urlTask.gcalEventId=@"";
				
				self.urlTask.taskWhat=-1;			//what ID for What Actions
				self.urlTask.taskWho=-1;			//who ID for Contact
				
				//Begin for 2.0 or later---------------------------------------------------------------
				if(taskPropertiesCount<27){//update for old versions that may makes conflict in this version 
					self.urlTask.parentRepeatInstance=-1;
					self.urlTask.taskRepeatOptions=@"1//0";
				}else {
					if(taskPropertiesCount>26)
						self.urlTask.parentRepeatInstance=[[fullTaskParameters objectAtIndex:26] intValue];
					
					if(taskPropertiesCount>27)
						self.urlTask.taskPhoneToCall=[[(NSString *)[fullTaskParameters objectAtIndex:27] stringByReplacingOccurrencesOfString:@"_$$$_" withString:@" "] retain];
					if([self.urlTask.taskPhoneToCall isEqualToString:@"NoPhones"])
						self.urlTask.taskPhoneToCall=@"";
					
					if(taskPropertiesCount>28)
						self.urlTask.taskEndRepeatDate=[NSDate dateWithTimeIntervalSince1970: [[fullTaskParameters objectAtIndex:28] doubleValue]];
					
					if(taskPropertiesCount>29)
						self.urlTask.taskRepeatOptions=[[(NSString *)[fullTaskParameters objectAtIndex:29] stringByReplacingOccurrencesOfString:@"_$$$_" withString:@" "] retain];
					if([self.urlTask.taskRepeatOptions isEqualToString:@"NoOptions"])
						self.urlTask.taskRepeatOptions=@"";
					
					if(taskPropertiesCount>30)
						self.urlTask.taskRepeatExceptions=[[(NSString *)[fullTaskParameters objectAtIndex:30] stringByReplacingOccurrencesOfString:@"_$$$_" withString:@" "] retain];
					if([self.urlTask.taskRepeatExceptions isEqualToString:@"NoExceptions"])
						self.urlTask.taskRepeatExceptions=@"";
					
					//31 is verison number
					if(taskPropertiesCount>32)
						self.urlTask.taskNumberInstances=[[fullTaskParameters objectAtIndex:32] intValue];	
					
					if(taskPropertiesCount>33){
						//self.urlTask.taskAlertValues=[[(NSString *)[fullTaskParameters objectAtIndex:33] stringByReplacingOccurrencesOfString:@"_$$$_" withString:@" "] retain];
						//if([self.urlTask.taskAlertValues isEqualToString:@"NoAlert"])
							self.urlTask.taskAlertValues=@"";
					}
					if(taskPropertiesCount>34)
						self.urlTask.isAllDayEvent =[[fullTaskParameters objectAtIndex:34] intValue];
					
					if(taskPropertiesCount>35)
						self.urlTask.taskSynKey =[[fullTaskParameters objectAtIndex:35] doubleValue];
					
				}
				//End for 2.0 or later---------------------------------------------------------------
				
				[self.urlTask prepareNewRecordIntoDatabase:database];
				[self.urlTask update];
				
				//			UIAlertView *openURLAlert = [[UIAlertView alloc] initWithTitle:@"new task:" message:[NSString stringWithFormat:@"\n tasklist:%d, new task name:%@,taskLoc:%@,tasknote: %@,taskpinned: %d, taskDur: %d, TaskWhere:%d",taskmanager.taskList.count, self.urlTask.taskName,self.urlTask.taskLocation,self.urlTask.taskDescription,self.urlTask.taskPinned,self.urlTask.taskHowLong,self.urlTask.taskWhere] delegate:nil cancelButtonTitle:okText otherButtonTitles:nil];
				//			[openURLAlert show];
				//			[openURLAlert release];
				
				
				[self.urlTask release];	
				self.urlTask=nil;
				[taskStr release];
			}
		}
		
		[self getTaskList];
		
		UIAlertView *openURLAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"restoringSuccessText", @"")/*restoringSuccessText*/ message:@"" delegate:nil cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/ otherButtonTitles:nil];
		[openURLAlert show];
		[openURLAlert release];
		
	}else {//add sharing task
		NSString *decodeTaskParameterStr=[decodedStr stringByReplacingOccurrencesOfString:@"_!$!_" withString:@" "];//decode "_!$!_" character
		NSString *decodeTaskSpecialChar1=[decodeTaskParameterStr stringByReplacingOccurrencesOfString:@"_!$$!_" withString:@"#"];//decode "#" character
		NSString *decodeTaskSpecialChar2=[decodeTaskSpecialChar1 stringByReplacingOccurrencesOfString:@"_$$!_" withString:@"?"];//decode "?" character
		NSString *decodeTaskSpecialChar3=[decodeTaskSpecialChar2 stringByReplacingOccurrencesOfString:@"_!$$_" withString:@"&"];//decode "&" character
		decodeTaskSpecialChar3=[decodeTaskSpecialChar3 stringByReplacingOccurrencesOfString:@"_$!$_" withString:@"\n"];
		decodeTaskSpecialChar3=[decodeTaskSpecialChar3 stringByReplacingOccurrencesOfString:@"_!!$$_" withString:@"/"];
		decodeTaskSpecialChar3=[decodeTaskSpecialChar3 stringByReplacingOccurrencesOfString:@"_$!!$_" withString:@"|"];
		
		NSArray *fullTaskParameters=[NSArray arrayWithArray:[decodeTaskSpecialChar3 componentsSeparatedByString:@" "]];
		
		if(self.urlTask !=nil){
			[self.urlTask release];	
		}
		self.urlTask=[[Task alloc] init];
		
		if(fullTaskParameters.count>0)
			self.urlTask.taskName=[[(NSString *)[fullTaskParameters objectAtIndex:0] stringByReplacingOccurrencesOfString:@"_$$$_" withString:@" "] retain];//"%C2%A7"
		
		if(fullTaskParameters.count>1)
			self.urlTask.taskLocation=[[(NSString *)[fullTaskParameters objectAtIndex:1] stringByReplacingOccurrencesOfString:@"_$$$_" withString:@" "] retain];
		if([self.urlTask.taskLocation isEqualToString:@"NoLocation"])
			self.urlTask.taskLocation=nil;
		
		if(fullTaskParameters.count>2)
			self.urlTask.taskDescription=[[(NSString *)[fullTaskParameters objectAtIndex:2] stringByReplacingOccurrencesOfString:@"_$$$_" withString:@" "] retain];
		if([self.urlTask.taskDescription isEqualToString:@"NoNotes"])
			self.urlTask.taskDescription=nil;
		
		if(fullTaskParameters.count>3)
			self.urlTask.taskPinned=[[fullTaskParameters objectAtIndex:3] intValue];
		
		if(fullTaskParameters.count>4)
			self.urlTask.taskHowLong=[[fullTaskParameters objectAtIndex:4] intValue];
		
		if(fullTaskParameters.count>5)
			self.urlTask.taskWhere=[[fullTaskParameters objectAtIndex:5] intValue];
		
		if(fullTaskParameters.count>6)
			self.urlTask.taskProject=[[fullTaskParameters objectAtIndex:6] intValue];
		
		if(fullTaskParameters.count>7)
			self.urlTask.taskStartTime=[NSDate dateWithTimeIntervalSince1970: [[fullTaskParameters objectAtIndex:7] doubleValue]];
		self.urlTask.taskEndTime=[self.urlTask.taskStartTime dateByAddingTimeInterval:self.urlTask.taskHowLong];
		self.urlTask.taskDueStartDate=[NSDate date];
		
		if(fullTaskParameters.count>8)
			self.urlTask.taskDueEndDate=[NSDate dateWithTimeIntervalSince1970: [[fullTaskParameters objectAtIndex:8] doubleValue]];
		self.urlTask.taskWhat=-1;			//what ID for What Actions
		self.urlTask.taskWho=-1;			//who ID for Contact
		self.urlTask.taskOriginalWhere=self.urlTask.taskWhere;	//keep track for where
		self.urlTask.taskDateUpdate=[NSDate date];	//the date when task is updated
		self.urlTask.taskTypeUpdate=0;		//0: update; 1: done
		self.urlTask.taskDefault=0;		//1: task is default
		
		if(fullTaskParameters.count>8)
			self.urlTask.taskDeadLine=[NSDate dateWithTimeIntervalSince1970: [[fullTaskParameters objectAtIndex:8] doubleValue]];		
		self.urlTask.taskNotEalierThan=[NSDate date];
		
		if(fullTaskParameters.count>9)
			self.urlTask.taskIsUseDeadLine=[[fullTaskParameters objectAtIndex:9] intValue];
		
		if(fullTaskParameters.count<11){//restore from old verson 1.3 or older
			self.urlTask.parentRepeatInstance=-1;
			self.urlTask.taskRepeatOptions=@"1//0";
		}else {
			if(fullTaskParameters.count>10)
				self.urlTask.parentRepeatInstance=[[fullTaskParameters objectAtIndex:10] intValue];
			
			if(fullTaskParameters.count>11)
				self.urlTask.taskPhoneToCall=[[(NSString *)[fullTaskParameters objectAtIndex:11] stringByReplacingOccurrencesOfString:@"_$$$_" withString:@" "] retain];
			if([self.urlTask.taskPhoneToCall isEqualToString:@"NoPhones"])
				self.urlTask.taskPhoneToCall=@"";
			
			if(fullTaskParameters.count>12)
				self.urlTask.taskEndRepeatDate=[NSDate dateWithTimeIntervalSince1970: [[fullTaskParameters objectAtIndex:12] doubleValue]];
			
			if(fullTaskParameters.count>13)
				self.urlTask.taskRepeatOptions=[[(NSString *)[fullTaskParameters objectAtIndex:13] stringByReplacingOccurrencesOfString:@"_$$$_" withString:@" "] retain];
			if([self.urlTask.taskRepeatOptions isEqualToString:@"NoOptions"])
				self.urlTask.taskRepeatOptions=@"1//0";
			
			if(fullTaskParameters.count>14)
				self.urlTask.taskRepeatExceptions=[[(NSString *)[fullTaskParameters objectAtIndex:14] stringByReplacingOccurrencesOfString:@"_$$$_" withString:@" "] retain];
			if([self.urlTask.taskRepeatExceptions isEqualToString:@"NoExceptions"])
				self.urlTask.taskRepeatExceptions=@"";
			
			if(fullTaskParameters.count>15)
				self.urlTask.taskRepeatID=[[fullTaskParameters objectAtIndex:15] intValue];
			
			//16 is version
			
			if(fullTaskParameters.count>17)
				self.urlTask.taskNumberInstances=[[fullTaskParameters objectAtIndex:17] intValue];
			
			if(fullTaskParameters.count>18){
				//self.urlTask.taskAlertValues=[[(NSString *)[fullTaskParameters objectAtIndex:18] stringByReplacingOccurrencesOfString:@"_$$$_" withString:@" "] retain];
				//if([self.urlTask.taskAlertValues isEqualToString:@"NoAlert"])
					self.urlTask.taskAlertValues=@"";
			}
			
			if(fullTaskParameters.count>19)
				self.urlTask.taskREStartTime=[NSDate dateWithTimeIntervalSince1970: [[fullTaskParameters objectAtIndex:19] doubleValue]];
			
			
			if(fullTaskParameters.count>20)
				self.urlTask.isAllDayEvent=[[fullTaskParameters objectAtIndex:20] intValue];
			
			[taskmanager addNewTask:self.urlTask toArray:taskmanager.taskList isAllowChangeDueWhenAdd:YES];
			
		}		
		UIAlertView *openURLAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"importTaskSuccessText", @"")/*importTaskSuccessText*/ message:@"" delegate:nil cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/ otherButtonTitles:nil];
		[openURLAlert show];
		[openURLAlert release];
	}
	
	
//	[taskParameters release];
	
	_inExternalLaunch = NO;	
	
	[_smartViewController refreshViews];	
	me.networkActivityIndicatorVisible=NO;
}

- (BOOL)check24HourFormat
{
	//*Trung 08102101
	[NSDateFormatter setDefaultFormatterBehavior:NSNumberFormatterBehavior10_4];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	//[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	//NSDate *date = [[NSDate alloc] initWithString:@"2001-03-24 13:45:32 +0600"];
	NSDate *date = [NSDate date];
	
	NSString *formattedDateString = [dateFormatter stringFromDate:date];
	//NSLog(@"formattedDateString for locale %@: %@",
	//	  [[dateFormatter locale] localeIdentifier], formattedDateString);	
	
	[dateFormatter release];
	
	NSRange range;
	
	range.location = formattedDateString.length - 2;
	
	range.length = 2;
	
	NSString *tail = [formattedDateString substringWithRange:range];
	
	if ([tail isEqualToString:@"AM"] || [tail isEqualToString:@"PM"] || [tail isEqualToString:@"am"] || [tail isEqualToString:@"pm"])
	{
		return NO;
	}
	
	return YES;
	//Trung 08102101*
}

-(void)updateInternetConnectionStatus:(Reachability *)curReach{
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    //BOOL connectionRequired= [curReach connectionRequired];
    switch (netStatus)
    {
        case NotReachable:
        {
			isInternetConnected=NO;
            break;
        }
            
        case ReachableViaWWAN:
        {
			isInternetConnected=YES;
            break;
        }
        case ReachableViaWiFi:
        {
			isInternetConnected=YES;
            break;
		}
    }
}
//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateInternetConnectionStatus: curReach];
}

@end
