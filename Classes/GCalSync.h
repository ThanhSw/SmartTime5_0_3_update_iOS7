//
//  GCalPush.h
//  iVo
//
//  Created by Left Coast Logic on 10/24/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

//#define PROJECT_NUM 21
#import "IvoCommon.h"
#import <UIKit/UIKit.h>

@class GDataEntryCalendar;

@interface GCalSync : NSObject {
	NSString *mUserName;
	NSString *mPassword;
	
	GDataEntryCalendar *STEventCalendar;
	GDataEntryCalendar *STTaskCalendar;
	
	NSInteger nSync;
	NSInteger nErr;	
	NSDate *syncTime;
	
	NSDate *lastSyncTime;
	NSDate *lastDeleteTime;

	UIAlertView *progressAlert;
	UIActivityIndicatorView *activityView;	
	
	UIAlertView *syncAlert;
	UIAlertView *syncReconcile;
	
	NSString *syncErrorMsg;
	
	BOOL pushTaskReady;
	BOOL pushEventReady;
	
	BOOL syncTaskReady;
	BOOL syncEventReady;
	
	BOOL reconcileDone;
	
	NSMutableArray *pushEvents[PROJECT_NUM];
	NSMutableArray *pushTasks[PROJECT_NUM];
	
	GDataEntryCalendar *STEventCalendars[PROJECT_NUM]; 
	GDataEntryCalendar *STTaskCalendars[PROJECT_NUM]; 
	
	NSMutableArray *gCalEvents[PROJECT_NUM];
	NSMutableArray *gCalTasks[PROJECT_NUM];
	NSMutableArray *gCalTasksDone[PROJECT_NUM];
	
	NSMutableArray *gCalInvalidEvents[PROJECT_NUM];
	
	BOOL syncEventFlags[PROJECT_NUM];
	BOOL syncREFlags[PROJECT_NUM];
	BOOL syncTaskFlags[PROJECT_NUM];

	BOOL loadEventFlags[PROJECT_NUM];
	BOOL loadTaskFlags[PROJECT_NUM];	
		
	BOOL mapReady;
	BOOL noProjectMapping;
	BOOL noEvent2Sync;	
	
	NSMutableArray *gcalCalendars;
	BOOL hasSharedCalendar;
	
	NSDictionary *stDict;
}

@property (nonatomic, retain) NSString *mUserName;
@property (nonatomic, retain) NSString *mPassword;

@property (nonatomic, retain) GDataEntryCalendar *STEventCalendar;
@property (nonatomic, retain) GDataEntryCalendar *STTaskCalendar;

@property (nonatomic, copy) NSDate *syncTime;
@property (nonatomic, copy) NSDate *lastSyncTime;
@property (nonatomic, copy) NSDate *lastDeleteTime;

@property (nonatomic, copy)	NSString *syncErrorMsg;

@property BOOL mapReady;

-(id) init: (NSString *)userName : (NSString *)password: (NSDate *)initSyncTime;
- (void)fetchAllCalendarsToMap;
- (void)authenticate;
+(id) getInstance:(NSString *)userName :(NSString *)password: (NSDate *)lastSyncTime;

@end
