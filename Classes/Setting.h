//
//  Setting.h
//  iVo_DatabaseAccess
//
//  Created by Nang Le on 4/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
//#import "/usr/include/sqlite3.h"
 #import <sqlite3.h>

@interface Setting : NSObject {
    // Primary key in the database.
    NSInteger	primaryKey;
    // Attributes.
	NSInteger	setID;
    NSString	*alarmSoundName;
	NSInteger	iVoStyleID;
	NSDate		*deskTimeStart;
	NSDate		*deskTimeEnd;
	NSDate		*deskTimeWEStart;
	NSDate		*deskTimeWEEnd;
	NSDate		*homeTimeNDStart;
	NSDate		*homeTimeNDEnd;
	NSDate		*homeTimeWEStart;
	NSDate		*homeTimeWEEnd;
	NSInteger	howlongDefVal;
	NSInteger	contextDefID;
	NSInteger	repeatDefID;
    NSInteger	projectDefID;
	NSInteger	endRepeatCount;
	NSDate		*expiredBetaTestDate;
	NSInteger	taskMovingStyle;
	NSInteger	dueWhenMove;// 0:Automatically; 1:Prompt Me
	NSInteger	pushTaskFoward;// 0: No push foward; 1: push automatically
	NSInteger	cleanOldDayCount; //0: never clean; >0: clean after a number days
	NSInteger	isFirstTimeStart;//0: NO; 1:YES. Mapping to Set_Resvr4 in database
	NSString	*gCalAccount;//map to Set_Resvr1 in database.
	NSDate		*lastSyncedTime; //map to Set_Resvr5 in database.
	NSString	*deleteItemsInTaskList; //map to Set_Resvr2 in database.
	NSInteger	syncType;//map to Set_Resvr6 in database
	NSInteger	deletingType;//map to Set_Resvr7 in database
	NSInteger	isFirstInstlUpdatStart;
	NSInteger	findTimeSlotInNumberOfDays;
	NSInteger	numberOfRestartTimes;
	NSInteger	adjustTimeIntervalForNewDue;
	NSInteger	badgeType;
	NSInteger	weekStartDay;
	NSString	*previousDevToken;
	NSInteger	isNeedShowPushWarning;
	
	NSData		*snapImageData;
	
	NSInteger syncWindowStart;
	NSInteger syncWindowEnd;
	NSInteger startWorkingWDay;
	NSInteger endWorkingWDay;
	
	NSInteger snoozeDuration;
	NSInteger snoozeUnit;
	
	//Toodledo Sync
	NSString	*toodledoToken;
	NSDate		*toodledoTokenTime;
	NSString	*toodledoUserId;
	NSString	*toodledoUserName;
	NSString	*toodledoPassword;
	NSString	*toodledoKey;
	NSDate		*toodledoSyncTime;
	NSInteger	toodledoSyncType;
	NSString	*toodledoDeletedFolders;
	NSInteger	isFirstTimeToodledoSync;
	NSString	*toodledoDeletedTasks;
	NSInteger	enableSyncToodledo;
	NSInteger	enableSyncICal;
	NSInteger   enabledReminderSync;
    
	NSInteger	defaultProjectId;
	NSInteger	autoICalSync;
	NSInteger	autoTDSync;
	NSInteger	hasToodledoFirstTimeSynced;
	
	NSString	*deletedICalEvents;
    NSString	*deletedICalCalendars;
    
	NSDate		*iCalLastSyncTime;
	
    NSInteger   syncEventOnly;
    NSInteger   firstStart41;
    
    NSInteger   wasHardClosed;
    
    NSString *deletedReminderLists;
    NSString *deletedReminders;

//	NSString	*calProjectMap;//map to Set_Resvr3 in database
//	NSInteger	deleteType;
	
	// Internal state variables. Hydrated tracks whether attribute data is in the object or the database.
    BOOL		updated;
    // Dirty tracks whether there are in-memory changes to data which have no been written to the database.
    BOOL		dirty;
    NSData		*data;
	
}
@property (assign, nonatomic)	NSInteger	primaryKey;			//
@property (assign, nonatomic)	NSInteger	setID;
@property (copy, nonatomic)		NSString	*alarmSoundName;	//
@property (copy, nonatomic)		NSDate		*deskTimeStart;		//
@property (copy, nonatomic)		NSDate		*deskTimeEnd;		//
@property (copy, nonatomic)		NSDate		*deskTimeWEStart;	//
@property (copy, nonatomic)		NSDate		*deskTimeWEEnd;		//
@property (copy, nonatomic)		NSDate		*homeTimeNDStart;	//
@property (copy, nonatomic)		NSDate		*homeTimeNDEnd;		//
@property (copy, nonatomic)		NSDate		*homeTimeWEStart;	//
@property (copy, nonatomic)		NSDate		*homeTimeWEEnd;		//
@property (assign, nonatomic)	NSInteger	iVoStyleID;			//
@property (assign, nonatomic)	NSInteger	howlongDefVal;		//
@property (assign, nonatomic)	NSInteger	contextDefID;		//
@property (assign, nonatomic)	NSInteger	repeatDefID;		
@property (assign, nonatomic)	NSInteger	projectDefID;		//
@property (assign, nonatomic)	NSInteger	endRepeatCount;
@property (copy, nonatomic)		NSDate		*expiredBetaTestDate;
@property (assign, nonatomic)	BOOL		dirty;
@property (assign, nonatomic)	NSInteger	taskMovingStyle;	//
@property (assign, nonatomic)	NSInteger	dueWhenMove;		//		//deadline 0:Automatically; 1:Prompt Me
@property (assign, nonatomic)	NSInteger	pushTaskFoward;		//		//0: No push foward; 1: push automatically
@property (assign, nonatomic)	NSInteger	cleanOldDayCount;	//		//0: never clean; >0: clean after a number days
@property (assign, nonatomic)	NSInteger	isFirstTimeStart;	//		//0: NO; 1:YES. Mapping to Set_Resvr4 in database
@property (copy, nonatomic)		NSString	*gCalAccount;		//		//map to Set_Resvr1 in database.
@property (copy, nonatomic)		NSDate		*lastSyncedTime;	//		//map to Set_Resvr5 in database.
@property (copy, nonatomic)		NSString	*deleteItemsInTaskList;		//map to Set_Resvr2 in database.

@property (assign, nonatomic)	NSInteger	syncType;					//map to Set_Resvr6 in database
@property (assign, nonatomic)	NSInteger	deletingType;//map to Set_Resvr7 in database
@property (assign, nonatomic)	NSInteger	isFirstInstlUpdatStart;
@property (assign, nonatomic)	NSInteger	findTimeSlotInNumberOfDays;

@property (retain, nonatomic)	NSData		*snapImageData;

@property (assign, nonatomic) NSInteger syncWindowStart;
@property (assign, nonatomic) NSInteger syncWindowEnd;
@property (assign, nonatomic) NSInteger	numberOfRestartTimes;
@property (assign, nonatomic) NSInteger adjustTimeIntervalForNewDue;
@property (assign, nonatomic) NSInteger	badgeType;
@property (assign, nonatomic) NSInteger	weekStartDay;
@property (copy, nonatomic)	  NSString	*previousDevToken;
@property (assign, nonatomic) NSInteger isNeedShowPushWarning;
@property (assign, nonatomic) NSInteger startWorkingWDay;
@property (assign, nonatomic) NSInteger endWorkingWDay;
@property (assign, nonatomic) NSInteger snoozeDuration;
@property (assign, nonatomic) NSInteger snoozeUnit;

//Toodledo Sync
@property (copy, nonatomic)	  NSString	*toodledoToken;
@property (copy, nonatomic)	  NSDate	*toodledoTokenTime;
@property (copy, nonatomic)	  NSString	*toodledoUserId;
@property (copy, nonatomic)	  NSString	*toodledoUserName;
@property (copy, nonatomic)	  NSString	*toodledoPassword;
@property (copy, nonatomic)	  NSString	*toodledoKey;
@property (copy, nonatomic)	  NSDate	*toodledoSyncTime;
@property (assign, nonatomic) NSInteger	toodledoSyncType;
@property (copy, nonatomic)	  NSString	*toodledoDeletedFolders;
@property (assign, nonatomic) NSInteger	isFirstTimeToodledoSync;
@property (copy, nonatomic)	  NSString	*toodledoDeletedTasks;
@property (assign, nonatomic) NSInteger	enableSyncToodledo;

@property (assign, nonatomic) NSInteger	enableSyncICal; 
@property (assign, nonatomic) NSInteger	defaultProjectId;

@property (assign, nonatomic) NSInteger	autoICalSync;
@property (assign, nonatomic) NSInteger	autoTDSync;
@property (assign, nonatomic) NSInteger	hasToodledoFirstTimeSynced;
@property (copy, nonatomic)	  NSString	*deletedICalEvents;
@property (copy, nonatomic)	  NSDate	*iCalLastSyncTime;
@property (copy, nonatomic)	  NSString	*deletedICalCalendars;
@property (assign, nonatomic) NSInteger   syncEventOnly;
@property (assign, nonatomic) NSInteger   firstStart41;
@property (assign, nonatomic) NSInteger   wasHardClosed;
@property (assign, nonatomic) NSInteger   enabledReminderSync;

@property (copy, nonatomic)	  NSString *deletedReminderLists;
@property (copy, nonatomic)	  NSString *deletedReminders;


//@property (copy, nonatomic)		NSString	*calProjectMap;//map to Set_Resvr3 in database, format CalName1|ProjectID1/CalName2|ProjectID2...

- (NSInteger)	prepareNewRecordIntoDatabase:(sqlite3 *)database;
// Finalize (delete) all of the SQLite compiled queries.
+ (void)		finalizeStatements;

// Creates the object with primary key and title is brought into memory.
- (id)			getInfoWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;
// Flushes all but the primary key and title out to the database.
- (void)		update;
// Remove the book complete from the database. In memory deletion to follow...
- (void)		deleteFromDatabase;

@end
