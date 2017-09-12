//
//  Task.h
//  iVo_DatabaseAccess
//
//  Created by Nang Le on 4/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <sqlite3.h>
//#import <sqlite3.h>

@class Alert;

@interface Task : NSObject {
    // Primary key in the database.
    NSInteger	primaryKey;			//map to task ID from database.
    // Attributes.
	NSInteger	taskID;				//not use
    NSString	*taskName;			//Task Title
    NSString	*taskDescription;	//Task Notes
	NSDate		*taskStartTime;		//Start Time	
	NSDate		*taskEndTime;		//End Time
	NSDate		*taskDueStartDate;	//task start window
	NSDate		*taskDueEndDate;	//task end window
	NSInteger	taskPinned;			//0:task;1:event
	//NSInteger	taskPriority;		//not used
	NSDate		*taskREStartTime;		//taskPriority
	NSInteger	taskStatus;			//not used
	NSInteger	taskCompleted;		//1:done
	double		taskSynKey;			//replace for TaskTypeID
	NSInteger	taskWhat;			//what ID for What Actions
	NSInteger	taskWho;			//who ID for Contact
	NSInteger	taskWhere;			//0:home; 1: work (context)
	NSInteger	taskOriginalWhere;	//keep track for where
	NSInteger	taskNumberInstances;			//
	NSInteger	taskHowLong;		//durations
	NSInteger	taskProject;		//Project ID from Project list
	NSInteger	parentRepeatInstance;		// map to Set_Resvr7 in database
	NSDate		*taskDateUpdate;	//the date when task is updated
	NSInteger	taskTypeUpdate;		//0: update; 1: done
	NSInteger	taskDefault;		//1: task is default
	NSInteger	taskRepeatID;		//future use
	NSInteger	taskRepeatTimes;	//future use
	NSString	*taskLocation;		//Task Location
	NSString	*taskContact;		//Task Who
	NSInteger	taskAlertID;		//future use
	NSDate		*taskDeadLine;		//bottom Dead line
	NSDate		*taskNotEalierThan;	//top deadline
	NSInteger	taskIsUseDeadLine;	//0: task without deadlin; 1: task with deadline.
	NSString	*taskEmailToSend;	//no map now, contains email address of contact for sending task via mail.
	NSString	*taskPhoneToCall;	//map to Set_Resvr4 indatabase, contains phone number to call the contact.
	NSDate		*taskEndRepeatDate;	//map to Set_Resvr6 in database.
	NSString	*taskRepeatOptions; //map to Set_Resvr3 in database. Format: "RepeatEvery|RepeatOn|RepeatBy"
	NSString	*taskRepeatExceptions; //map to Set_Resvr2 in database.
	NSString	*taskAlertValues;		//map to Set_Resver1 in database
	NSInteger	isAllDayEvent;		//map to Set_Resver8 in database
	NSInteger	taskKey;
	NSString	*PNSKey;
	
	NSDate		*filledDummiesToDate;
	NSInteger	taskOrder;
	NSDate		*specifiedAlertTime;
	NSInteger   alertByDeadline;
	
	NSInteger	isAdjustedSpecifiedDate;
	
	BOOL		isOneMoreInstance;	
	BOOL		isUsedExternalUpdateTime;//
	BOOL		isDeletedFromGCal;
	BOOL		isNeedAdjustDST;
	BOOL		isChangedAlertSetting;
	
	NSInteger	originalPKey;		//used for app layer only, for add a group of tasks/Events when syncing to ST;
	
	NSInteger	toodledoID;
	
	BOOL		isMultiParts;
	NSString	*howLongParts;//format: /startTime1|endTime1|duration1/startTime2|endTime2|duration2/...
	NSInteger	currentHowlong;//used to calculate howlong parts
	
	NSInteger	toodledoHasStart;
	NSInteger	isHidden;
	
	NSString	*iCalIdentifier;
	NSString	*iCalCalendarName;
	
	NSDate		*originalExceptionDate;

    NSInteger   alertIndex;// none, 5, 10,...
    NSInteger   alertUnit;//mins or days or weeeks....
    NSInteger   alertBasedOn;//Start or Due
    NSInteger   hasAlert;
    
    NSInteger   taskRepeatStyle;//repeat after completion of by due
    
    // Internal state variables. Hydrated tracks whether attribute data is in the object or the database.
    BOOL updated;
    // Dirty tracks whether there are in-memory changes to data which have no been written to the database.
    BOOL dirty;
    NSData *data;
	
	NSString *gcalEventId;//map to Set_Resvr5 in dabatabse
    NSString *reminderIdentifier;
}

//@property (assign, nonatomic, readonly) NSInteger primaryKey;
@property (assign, nonatomic)	NSInteger	primaryKey;
@property (assign, nonatomic)	NSInteger	taskID;
@property (copy, nonatomic)		NSString	*taskName;			//backupable
@property (copy, nonatomic)		NSString	*taskDescription;	//backupable
@property (copy, nonatomic)		NSDate		*taskStartTime;		//backupable
@property (copy, nonatomic)		NSDate		*taskEndTime;		//backupable
@property (copy, nonatomic)		NSDate		*taskDueStartDate;	//backupable
@property (copy, nonatomic)		NSDate		*taskDueEndDate;	//backupable
@property (copy, nonatomic)		NSDate		*taskDateUpdate;	//backupable
@property (assign, nonatomic)	NSInteger	taskPinned;			//backupable
@property (copy, nonatomic)		NSDate		*taskREStartTime;	//backupable, check again for new data type
@property (assign, nonatomic)	NSInteger	taskStatus;			//backupable
@property (assign, nonatomic)	NSInteger	taskCompleted;		//backupable
@property (assign, nonatomic)	double		taskSynKey;	/*old is TaskTypeID*/
@property (assign, nonatomic)	NSInteger	taskWhat;			
@property (assign, nonatomic)	NSInteger	taskWho;
@property (assign, nonatomic)	NSInteger	taskWhere;			//backupable
@property (assign, nonatomic)	NSInteger	taskOriginalWhere;	//backupable
@property (assign, nonatomic)	NSInteger	taskNumberInstances;//backupable
@property (assign, nonatomic)	NSInteger	taskHowLong;		//backupable
@property (assign, nonatomic)	NSInteger	taskProject;		//backupable
@property (assign, nonatomic)	NSInteger	parentRepeatInstance;//backupable//					//map to Set_Resvr7 field in DB
@property (assign, nonatomic)	NSInteger	taskTypeUpdate;		//backupable
@property (assign, nonatomic)	NSInteger	taskDefault;		//backupable
@property (assign, nonatomic)	NSInteger	taskRepeatID;		//backupable
@property (assign, nonatomic)	NSInteger	taskRepeatTimes;	//backupable
@property (copy, nonatomic)		NSString	*taskLocation;		//backupable
@property (copy, nonatomic)		NSString	*taskContact;		//backupable
@property (assign, nonatomic)	NSInteger	taskAlertID;		//backupable
@property (assign, nonatomic)	BOOL		dirty;
@property (assign, nonatomic)	BOOL		isOneMoreInstance;
@property (copy, nonatomic)		NSDate		*taskDeadLine;		//backupable
@property (copy, nonatomic)		NSDate		*taskNotEalierThan; //backupable
@property (assign, nonatomic)	NSInteger	taskIsUseDeadLine;	//backupable
@property (copy, nonatomic)		NSString	*taskEmailToSend;	//backupable	
@property (copy, nonatomic)		NSString	*taskPhoneToCall;	//backupable//	//map to Set_Resvr4 indatabase, contains phone number to call the contact.
@property (copy, nonatomic)		NSDate		*taskEndRepeatDate;	//backupable//	//map to Set_Resvr6 in database.
@property (copy, nonatomic)		NSString	*taskRepeatOptions;	//backupable//	//map to Set_Resvr3 in database.
@property (copy, nonatomic)		NSString	*taskRepeatExceptions;	//backupable//		//map to Set_Resvr2 in database.
@property (copy, nonatomic)		NSString	*taskAlertValues;		//map to Set_Resver1 in database
@property (assign, nonatomic)	NSInteger	taskKey;

@property (assign, nonatomic)	NSInteger	originalPKey;		//used for app layer only, for add a group of tasks/Events when syncing to ST;
@property (assign, nonatomic)	NSInteger	isAllDayEvent;		//map to Set_Resver8 in database
@property (assign, nonatomic)	BOOL		isUsedExternalUpdateTime;

//@property (assign, nonatomic) NSString* taskLocation;
@property (nonatomic, copy)		NSString	*gcalEventId; //map to Set_Resvr5 in dabatabse
@property (assign, nonatomic)	BOOL		isDeletedFromGCal;
@property (nonatomic, copy)		NSDate		*filledDummiesToDate;
@property (assign, nonatomic)	NSInteger	taskOrder;
@property (assign, nonatomic)	BOOL		isNeedAdjustDST;
@property (copy, nonatomic)		NSString	*PNSKey;
@property (assign, nonatomic)	BOOL		isChangedAlertSetting;
@property (copy, nonatomic)		NSDate		*specifiedAlertTime;
@property (assign, nonatomic)	NSInteger   alertByDeadline;
@property (assign, nonatomic)	NSInteger	isAdjustedSpecifiedDate;

@property (assign, nonatomic)	NSInteger	toodledoID;

@property (assign, nonatomic)	BOOL		isMultiParts;
@property (retain, nonatomic)	NSString	*howLongParts;//format: /startTime1|endTime1|duration1/startTime2|endTime2|duration2/...
@property (assign, nonatomic)	NSInteger	currentHowlong;//used to calculate howlong parts
@property (assign, nonatomic)	NSInteger	toodledoHasStart;
@property (assign, nonatomic)	NSInteger	isHidden;

@property (copy, nonatomic)		NSString	*iCalIdentifier;
@property (copy, nonatomic)		NSString	*iCalCalendarName;

@property (copy, nonatomic)		NSDate		*originalExceptionDate;

@property (assign, nonatomic)	NSInteger   hasAlert;
@property (assign, nonatomic)	NSInteger   alertIndex;// 5, 10,...
@property (assign, nonatomic)	NSInteger   alertUnit;//mins or days or weeeks....
@property (assign, nonatomic)	NSInteger   alertBasedOn;//Start or Due
@property (assign, nonatomic)	NSInteger   taskRepeatStyle;
@property (copy, nonatomic)		NSString *reminderIdentifier;

//- (NSInteger)prepareNewRecordIntoDatabase:(sqlite3 *)database;
- (NSInteger)prepareNewRecordIntoDatabase:(sqlite3 *)database;
- (NSInteger)prepareDummyIntoDatabase:(sqlite3 *)database;

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements;

// Creates the object with primary key and title is brought into memory.
//- (id)getInfoWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;
- (id)getInfoWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;
//- (id)getDummyInfoWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;

// Flushes all but the primary key and title out to the database.
- (void)update;
- (void)updateDummy;

// Remove the book complete from the database. In memory deletion to follow...
- (void)deleteFromDatabase;
- (void)deleteDummyFromDatabase;

- (BOOL)isEqualToTask:(Task *)task;
-(NSMutableArray *)creatAlertList;
-(void)updateAlertList:(NSMutableArray *)list;
-(NSDate *)getOriginalDateOfExceptionInstance;//this is only used for Exception
- (BOOL)isEqualToDummy:(Task *)task;

-(void) refreshDateUpdate;

-(void) externalUpdate;
-(void) enableExternalUpdate;
- (void) modifyUpdateTime;
- (void) updateSyncID;
-(Alert *)getAlertInfo;

@end
