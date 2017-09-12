//
//  Setting.m
//  iVo_DatabaseAccess
//
//  Created by Nang Le on 4/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Setting.h"
#import "SmartTimeAppDelegate.h"
#import "ivo_Utilities.h"
#import "CalendarView.h"

extern ivo_Utilities *ivoUtility;
extern CalendarView *_calendarView;
extern NSInteger gmtSeconds;
extern NSTimeZone	*App_defaultTimeZone;
extern BOOL				isDayLigtSavingTime;
extern NSTimeInterval	dstOffset;

static sqlite3_stmt *insert_setting_statement = nil;
static sqlite3_stmt *init_setting_statement = nil;
static sqlite3_stmt *delete_setting_statement = nil;
//static sqlite3_stmt *hydrate_statement = nil;
static sqlite3_stmt *update_setting_statement = nil;

extern BOOL isLockingDB;

extern sqlite3 *database;
@implementation Setting
@synthesize syncType;

//@synthesize syncWindowStart;
//@synthesize syncWindowEnd;

//prepare the new empty row in Catagory table for update later (when user create new category on UI)
- (NSInteger)prepareNewRecordIntoDatabase:(sqlite3 *)database{
	// This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed.
    
    while (isLockingDB) {
        //usleep(20);
        [NSThread sleepForTimeInterval:0.01];
    }
    isLockingDB=YES;
    
    if (insert_setting_statement == nil) {
        static char *sql = "INSERT INTO iVo_Setting (Set_AlarmSoundName) VALUES('none')";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_setting_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
    int success = sqlite3_step(insert_setting_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_setting_statement);
//	sqlite3_finalize(insert_setting_statement);	
//	insert_setting_statement=nil;

    if (success != SQLITE_ERROR) {
        // SQLite provides a method which retrieves the value of the most recently auto-generated primary key sequence
        // in the database. To access this functionality, the table should have a column declared of type 
        // "INTEGER PRIMARY KEY"
        
        isLockingDB=NO;
        return sqlite3_last_insert_rowid(database);
    }
    NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));

    isLockingDB=NO;
    return -1;
}
 
// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements {
    if (insert_setting_statement) sqlite3_finalize(insert_setting_statement);
    if (init_setting_statement) sqlite3_finalize(init_setting_statement);
    if (delete_setting_statement) sqlite3_finalize(delete_setting_statement);
    //if (hydrate_statement) sqlite3_finalize(hydrate_statement);
    if (update_setting_statement) sqlite3_finalize(update_setting_statement);
}

// Creates the category object with primary key and name, description is brought into memory.
- (id)getInfoWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db {
    while (isLockingDB) {
        //usleep(20);
        [NSThread sleepForTimeInterval:0.01];
    }
    isLockingDB=YES;
    
	if (self = [super init]) {
        self.primaryKey = pk;
        database = db;
        // Compile the query for retrieving book data.
        if (init_setting_statement == nil) {
            // Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
            // This is a great way to optimize because frequently used queries can be compiled once, then with each
            // use new variable values can be bound to placeholders.
            const char *sql = "SELECT Set_ID,Set_AlarmSoundName,Set_iVoStyleID,Set_DeskTimeStart,Set_DeskTimeEnd,Set_HomeTimeNDStart,Set_HomeTimeNDEnd,Set_HomeTimeWEStart,Set_HomeTimeWEEnd,Set_HowlongDefVal,Set_ContextDefID,Set_RepeatDefID,Set_ProjectDefID,Set_EndRepeatCount,Set_EndDueCount,Set_DeskTimeWEStart,Set_DeskTimeWEEnd,Set_MovingStyle,Set_DueWhenMove,Set_PushTaskFoward,Set_CleanOldDayCount,Set_Resvr4,Set_Resvr1,Set_Resvr5,Set_Resvr2,Set_Resvr6,Set_Resvr7,isFirstInstlUpdatStart,snapImage,syncWindowStart,syncWindowEnd,findTimeSlotInNumberOfDays,numberOfRestartTimes,adjustTimeIntervalForNewDue,badgeType,weekStartDay,previousDevToken,isNeedShowPushWarning,startWorkingWDay,endWorkingWDay,snoozeDuration,snoozeUnit,toodledoToken,toodledoTokenTime,toodledoUserId,toodledoUserName,toodledoPassword,toodledoKey,toodledoSyncTime,toodledoSyncType,toodledoDeletedFolders,isFirstTimeToodledoSync,toodledoDeletedTasks,enableSyncToodledo,enableSyncICal,defaultProjectId,autoICalSync,autoTDSync,hasToodledoFirstTimeSynced,deletedICalEvents,iCalLastSyncTime,deletedICalCalendars,syncEventOnly,firstStart41,wasHardClosed,enabledReminderSync,deletedReminderLists,deletedReminders FROM iVo_Setting WHERE Set_ID=?";
            if (sqlite3_prepare_v2(database, sql, -1, &init_setting_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // For this query, we bind the primary key to the first (and only) placeholder in the statement.
        // Note that the parameters are numbered from 1, not from 0.
        sqlite3_bind_int(init_setting_statement, 1, self.primaryKey);
        if (sqlite3_step(init_setting_statement) == SQLITE_ROW) {
			self.setID=sqlite3_column_int(init_setting_statement, 0);
			char *setDefaultSound=(char *)sqlite3_column_text(init_setting_statement, 1);
			self.alarmSoundName = (setDefaultSound)? [NSString stringWithUTF8String:setDefaultSound] : @"";
			self.iVoStyleID=sqlite3_column_int(init_setting_statement, 2);

			//NSDate *date=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_setting_statement, 3)];
			self.deskTimeStart=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_setting_statement, 3)-gmtSeconds];
			
			//date=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_setting_statement, 4)];
			self.deskTimeEnd=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_setting_statement, 4)-gmtSeconds];
			
			//date=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_setting_statement, 5)];
			self.homeTimeNDStart=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_setting_statement, 5)-gmtSeconds];
			
			//date=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_setting_statement, 6)];
			self.homeTimeNDEnd=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_setting_statement, 6)-gmtSeconds];
			
			//date=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_setting_statement, 7)];
			self.homeTimeWEStart=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_setting_statement, 7)-gmtSeconds];			
			
			//date=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_setting_statement, 8)];
			self.homeTimeWEEnd=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_setting_statement, 8)-gmtSeconds];
			
			self.howlongDefVal=sqlite3_column_int(init_setting_statement, 9);
			self.contextDefID=sqlite3_column_int(init_setting_statement, 10);
			self.repeatDefID=sqlite3_column_int(init_setting_statement, 11);
			self.projectDefID=sqlite3_column_int(init_setting_statement, 12);
			self.endRepeatCount=sqlite3_column_int(init_setting_statement, 13);
			self.expiredBetaTestDate=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_setting_statement, 14)-gmtSeconds];//[[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_setting_statement, 14)] addTimeInterval:-gmtSeconds];
			//self.expiredBetaTestDate=sqlite3_column_int(init_setting_statement, 14);

			//date=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_setting_statement, 15)];
			self.deskTimeWEStart=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_setting_statement, 15)-gmtSeconds];
			
			//date=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_setting_statement, 16)];
			self.deskTimeWEEnd=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_setting_statement, 16)-gmtSeconds];
			
			self.taskMovingStyle=sqlite3_column_int(init_setting_statement, 17);
			self.dueWhenMove=sqlite3_column_int(init_setting_statement, 18);
			self.pushTaskFoward=sqlite3_column_int(init_setting_statement, 19);
			self.cleanOldDayCount=sqlite3_column_int(init_setting_statement, 20);
			self.isFirstTimeStart=sqlite3_column_int(init_setting_statement, 21);
			char *gCalAcc= (char *)sqlite3_column_text(init_setting_statement, 22);
			self.gCalAccount=(gCalAcc)? [NSString stringWithUTF8String:gCalAcc] : @"";

			//date=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_setting_statement, 23)];
			self.lastSyncedTime=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_setting_statement, 23)-gmtSeconds];

			char *delItem= (char *)sqlite3_column_text(init_setting_statement, 24);
			self.deleteItemsInTaskList=(delItem)? [NSString stringWithUTF8String:delItem] : @"";

			self.syncType=sqlite3_column_int(init_setting_statement, 25);
			self.deletingType=sqlite3_column_int(init_setting_statement, 26);
			self.isFirstInstlUpdatStart=sqlite3_column_int(init_setting_statement, 27);
						
			NSUInteger blobLength1 = sqlite3_column_bytes(init_setting_statement, 28);
			if(blobLength1>0){
				self.snapImageData=[NSData dataWithBytes:sqlite3_column_blob(init_setting_statement, 28) length:blobLength1];
			}else {
				self.snapImageData=nil;
			}
			
			self.syncWindowStart=sqlite3_column_int(init_setting_statement, 29);
			self.syncWindowEnd=sqlite3_column_int(init_setting_statement, 30);
			self.findTimeSlotInNumberOfDays=sqlite3_column_int(init_setting_statement, 31);
			if(self.findTimeSlotInNumberOfDays==0){
				self.findTimeSlotInNumberOfDays=90;//default for finding time slot for a task will be in 3 months beginning from its due start.
			}
			
			self.numberOfRestartTimes=sqlite3_column_int(init_setting_statement, 32);
			self.adjustTimeIntervalForNewDue=sqlite3_column_int(init_setting_statement, 33);
			self.badgeType=sqlite3_column_int(init_setting_statement, 34);
			self.weekStartDay=sqlite3_column_int(init_setting_statement, 35);
			
			char *dev= (char *)sqlite3_column_text(init_setting_statement, 36);
			self.previousDevToken=(dev)? [NSString stringWithUTF8String:dev] : @"";
			
			self.isNeedShowPushWarning=sqlite3_column_int(init_setting_statement, 37);
			self.startWorkingWDay=sqlite3_column_int(init_setting_statement, 38);
			self.endWorkingWDay=sqlite3_column_int(init_setting_statement, 39);
			self.snoozeDuration=sqlite3_column_int(init_setting_statement, 40);
			if(self.snoozeDuration==0)//default is 30 minutes, start from 1 minutes
				self.snoozeDuration=30;
			self.snoozeUnit=sqlite3_column_int(init_setting_statement, 41);
			
			char *token= (char *)sqlite3_column_text(init_setting_statement, 42);
			self.toodledoToken=(token)? [NSString stringWithUTF8String:token] : @"";
			
			self.toodledoTokenTime=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_setting_statement, 43)-gmtSeconds];
			
			char *userId= (char *)sqlite3_column_text(init_setting_statement, 44);
			self.toodledoUserId=(userId)? [NSString stringWithUTF8String:userId] : @"";

			char *userName= (char *)sqlite3_column_text(init_setting_statement, 45);
			self.toodledoUserName=(userName)? [NSString stringWithUTF8String:userName] : @"";

			char *pwd= (char *)sqlite3_column_text(init_setting_statement, 46);
			self.toodledoPassword=(pwd)? [NSString stringWithUTF8String:pwd] : @"";

			char *tdKey= (char *)sqlite3_column_text(init_setting_statement, 47);
			self.toodledoKey=(tdKey)? [NSString stringWithUTF8String:tdKey] : @"";

			self.toodledoSyncTime=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_setting_statement, 48)-gmtSeconds];
			self.toodledoSyncType=sqlite3_column_int(init_setting_statement, 49);
			
			char *delFolders= (char *)sqlite3_column_text(init_setting_statement, 50);
			self.toodledoDeletedFolders=(delFolders)? [NSString stringWithUTF8String:delFolders] : @"";
			
			self.isFirstTimeToodledoSync=sqlite3_column_int(init_setting_statement, 51);

			char *delTasks= (char *)sqlite3_column_text(init_setting_statement, 52);
			self.toodledoDeletedTasks=(delTasks)? [NSString stringWithUTF8String:delTasks] : @"";
			self.enableSyncToodledo=sqlite3_column_int(init_setting_statement, 53);
			self.enableSyncICal=sqlite3_column_int(init_setting_statement, 54);
			//defaultProjectId
			self.defaultProjectId=sqlite3_column_int(init_setting_statement, 55);
			
			//autoICalSync
			self.autoICalSync=sqlite3_column_int(init_setting_statement, 56);
			self.autoTDSync=sqlite3_column_int(init_setting_statement, 57);
			//hasToodledoFirstTimeSynced
			self.hasToodledoFirstTimeSynced=sqlite3_column_int(init_setting_statement, 58);
			//deletedICalEvents
			char *delicalevents= (char *)sqlite3_column_text(init_setting_statement, 59);
			self.deletedICalEvents=(delicalevents)? [NSString stringWithUTF8String:delicalevents] : @"";
			
			self.iCalLastSyncTime=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_setting_statement, 60)-gmtSeconds];
            
            //deletedICalCalendars
			char *delicalcals= (char *)sqlite3_column_text(init_setting_statement, 61);
			self.deletedICalCalendars=(delicalcals)? [NSString stringWithUTF8String:delicalcals] : @"";

            self.syncEventOnly=sqlite3_column_int(init_setting_statement, 62);
            self.firstStart41=sqlite3_column_int(init_setting_statement, 63);
            self.wasHardClosed=sqlite3_column_int(init_setting_statement, 64);
            self.enabledReminderSync=sqlite3_column_int(init_setting_statement, 65);
            
            //deletedReminderLists
			char *delRmdrList= (char *)sqlite3_column_text(init_setting_statement, 66);
			self.deletedReminderLists=(delRmdrList)? [NSString stringWithUTF8String:delRmdrList] : @"";
            
            char *delRmdrs= (char *)sqlite3_column_text(init_setting_statement, 67);
			self.deletedReminders=(delRmdrs)? [NSString stringWithUTF8String:delRmdrs] : @"";
		} else {
			
			self.setID=0;
            self.alarmSoundName = @"";
			self.iVoStyleID=0;
			self.deskTimeStart=nil;
			self.deskTimeEnd=nil;
			self.homeTimeNDStart=nil;
			self.homeTimeNDEnd=nil;
			self.homeTimeWEStart=nil;
			self.homeTimeWEEnd=nil;
			self.howlongDefVal=0;
			self.contextDefID=-1;
			self.repeatDefID=-1;
			self.projectDefID=-1;
			self.endRepeatCount=0;
			self.expiredBetaTestDate=nil;
			self.deskTimeWEStart=nil;
			self.deskTimeWEEnd=nil;
			self.taskMovingStyle=-1;
			self.dueWhenMove=-1;
			self.pushTaskFoward=-1;
			self.cleanOldDayCount=-1;
			self.isFirstTimeStart=-1;
			self.gCalAccount=@"";
			self.deletingType=-1;
			//self.calProjectMap=@"";
        }
		
        // Reset the statement for future reuse.
        sqlite3_reset(init_setting_statement);
//		sqlite3_finalize(init_setting_statement);	
//		init_setting_statement=nil;

        dirty = NO;
	}
    
    isLockingDB=NO;
    
    return self;
}

- (void)dealloc {
    [alarmSoundName release];
	alarmSoundName=nil;
	
	[deskTimeStart release];
	deskTimeStart=nil;
	
	[deskTimeEnd release];
	deskTimeEnd=nil;
	
	[deskTimeWEStart release];
	deskTimeWEStart=nil;
	
	[deskTimeWEEnd release];
	deskTimeWEEnd=nil;	
	
	[homeTimeNDStart release];
	homeTimeNDStart=nil;
	
	[homeTimeWEStart release];
	homeTimeWEStart=nil;
	
	[homeTimeNDEnd release];
	homeTimeNDEnd=nil;
	
	[homeTimeWEEnd release];
	homeTimeWEEnd=nil;
	
	[gCalAccount release];
	gCalAccount=nil;
	
	[lastSyncedTime release];
	lastSyncedTime=nil;
	
	[expiredBetaTestDate release];
	expiredBetaTestDate=nil;
	
	[deleteItemsInTaskList release];
	[snapImageData release];
	
	//[calProjectMap release];
	
	//Toodledo Sync
	[toodledoToken release];
	[toodledoTokenTime release];
	[toodledoUserId release];
	[toodledoUserName release];
	[toodledoPassword release];
	[toodledoKey release];
	[toodledoSyncTime release];
	[toodledoDeletedFolders release];
	[toodledoDeletedTasks release];
	[deletedICalEvents release];
	
	[iCalLastSyncTime release];
	[deletedICalCalendars release];
    
    [deletedReminderLists release];
    [deletedReminders release];
    
    [super dealloc];
}

- (void)deleteFromDatabase {
    // Compile the delete statement if needed.
    if (delete_setting_statement == nil) {
        const char *sql = "DELETE FROM iVo_Setting WHERE Set_ID=?";
        if (sqlite3_prepare_v2(database, sql, -1, &delete_setting_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    // Bind the primary key variable.
    sqlite3_bind_int(delete_setting_statement, 1, self.primaryKey);
    // Execute the query.
    int success = sqlite3_step(delete_setting_statement);
    // Reset the statement for future use.
    sqlite3_reset(delete_setting_statement);
//	sqlite3_finalize(delete_setting_statement);	
//	delete_setting_statement=nil;
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }
}

// Flushes all but the primary key and title out to the database.
- (void)update {
    while (isLockingDB) {
        //usleep(20);
        [NSThread sleepForTimeInterval:0.01];
    }
    isLockingDB=YES;
    
    if (self.dirty) {
        // Write any changes to the database.
        // First, if needed, compile the update query.
        if (update_setting_statement == nil) {
			//const char *sql = "UPDATE iVo_Setting SET Set_AlarmSoundName=? WHERE Set_ID=?";
            const char *sql = "UPDATE iVo_Setting SET Set_AlarmSoundName=?, Set_iVoStyleID=?, Set_DeskTimeStart=?,Set_DeskTimeEnd=?,Set_HomeTimeNDStart=?,Set_HomeTimeNDEnd=?,Set_HomeTimeWEStart=?,Set_HomeTimeWEEnd=?,Set_HowlongDefVal=?,Set_ContextDefID=?,Set_RepeatDefID=?,Set_ProjectDefID=?,Set_EndRepeatCount=?,Set_EndDueCount=?,Set_DeskTimeWEStart=?,Set_DeskTimeWEEnd=?,Set_MovingStyle=?,Set_DueWhenMove=?, Set_PushTaskFoward=?,Set_CleanOldDayCount=?,Set_Resvr4=?,Set_Resvr1=?,Set_Resvr5=?,Set_Resvr2=?,Set_Resvr6=?,Set_Resvr7=?,isFirstInstlUpdatStart=?,snapImage=?,syncWindowStart=?,syncWindowEnd=?,findTimeSlotInNumberOfDays=?,numberOfRestartTimes=?,adjustTimeIntervalForNewDue=?,badgeType=?,weekStartDay=?,previousDevToken=?,isNeedShowPushWarning=?,startWorkingWDay=?,endWorkingWDay=?,snoozeDuration=?,snoozeUnit=?,toodledoToken=?,toodledoTokenTime=?,toodledoUserId=?,toodledoUserName=?,toodledoPassword=?,toodledoKey=?,toodledoSyncTime=?,toodledoSyncType=?,toodledoDeletedFolders=?,isFirstTimeToodledoSync=?,toodledoDeletedTasks=?,enableSyncToodledo=?,enableSyncICal=?,defaultProjectId=?,hasToodledoFirstTimeSynced=?,deletedICalEvents=?,iCalLastSyncTime=?,deletedICalCalendars=?,autoICalSync=?,syncEventOnly=?,firstStart41=?,wasHardClosed=?,enabledReminderSync=?,deletedReminderLists=?,deletedReminders=? WHERE Set_ID=?";
            if (sqlite3_prepare_v2(database, sql, -1, &update_setting_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // Bind the query variables.
        sqlite3_bind_text(update_setting_statement, 1, [self.alarmSoundName UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(update_setting_statement, 2,self.iVoStyleID);
/*		
		sqlite3_bind_double(update_setting_statement, 3, [[self.deskTimeStart addTimeInterval:gmtSeconds -[App_defaultTimeZone isDaylightSavingTimeForDate:self.deskTimeStart]?0:dstOffset] timeIntervalSince1970]);
		sqlite3_bind_double(update_setting_statement, 4, [[self.deskTimeEnd addTimeInterval:gmtSeconds -[App_defaultTimeZone isDaylightSavingTimeForDate:self.deskTimeEnd]?0:dstOffset] timeIntervalSince1970]);
		sqlite3_bind_double(update_setting_statement, 5, [[self.homeTimeNDStart addTimeInterval:gmtSeconds -[App_defaultTimeZone isDaylightSavingTimeForDate:self.homeTimeNDStart]?0:dstOffset] timeIntervalSince1970]);
		sqlite3_bind_double(update_setting_statement, 6, [[self.homeTimeNDEnd addTimeInterval:gmtSeconds -[App_defaultTimeZone isDaylightSavingTimeForDate:self.homeTimeNDEnd]?0:dstOffset] timeIntervalSince1970]);
		sqlite3_bind_double(update_setting_statement, 7, [[self.homeTimeWEStart addTimeInterval:gmtSeconds -[App_defaultTimeZone isDaylightSavingTimeForDate:self.homeTimeWEStart]?0:dstOffset] timeIntervalSince1970]);
		sqlite3_bind_double(update_setting_statement, 8, [[self.homeTimeWEEnd addTimeInterval:gmtSeconds -[App_defaultTimeZone isDaylightSavingTimeForDate:self.homeTimeWEEnd]?0:dstOffset] timeIntervalSince1970] );
*/		

		sqlite3_bind_double(update_setting_statement, 3, [self.deskTimeStart timeIntervalSince1970]+gmtSeconds);
		sqlite3_bind_double(update_setting_statement, 4, [self.deskTimeEnd timeIntervalSince1970]+gmtSeconds);
		sqlite3_bind_double(update_setting_statement, 5, [self.homeTimeNDStart timeIntervalSince1970]+gmtSeconds);
		sqlite3_bind_double(update_setting_statement, 6, [self.homeTimeNDEnd timeIntervalSince1970]+gmtSeconds);
		sqlite3_bind_double(update_setting_statement, 7, [self.homeTimeWEStart timeIntervalSince1970]+gmtSeconds);
		sqlite3_bind_double(update_setting_statement, 8, [self.homeTimeWEEnd timeIntervalSince1970]+gmtSeconds);
		
		sqlite3_bind_int(update_setting_statement, 9,self.howlongDefVal);
		sqlite3_bind_int(update_setting_statement, 10,self.contextDefID);
		sqlite3_bind_int(update_setting_statement, 11,self.repeatDefID);
		sqlite3_bind_int(update_setting_statement, 12,self.projectDefID);
		sqlite3_bind_int(update_setting_statement, 13,self.endRepeatCount);
		sqlite3_bind_int(update_setting_statement, 14,[self.expiredBetaTestDate timeIntervalSince1970] +gmtSeconds);
/*		
		sqlite3_bind_double(update_setting_statement, 15, [[self.deskTimeWEStart addTimeInterval:gmtSeconds -[App_defaultTimeZone isDaylightSavingTimeForDate:self.deskTimeWEStart]?0:dstOffset] timeIntervalSince1970] );
		sqlite3_bind_double(update_setting_statement, 16, [[self.deskTimeWEEnd addTimeInterval:gmtSeconds -[App_defaultTimeZone isDaylightSavingTimeForDate:self.deskTimeWEEnd]?0:dstOffset] timeIntervalSince1970]);
*/
		sqlite3_bind_double(update_setting_statement, 15, [self.deskTimeWEStart timeIntervalSince1970] +gmtSeconds);
		sqlite3_bind_double(update_setting_statement, 16, [self.deskTimeWEEnd timeIntervalSince1970]+gmtSeconds);

		sqlite3_bind_int(update_setting_statement, 17, self.taskMovingStyle);
		sqlite3_bind_int(update_setting_statement, 18, self.dueWhenMove);
		sqlite3_bind_int(update_setting_statement, 19, self.pushTaskFoward);
		sqlite3_bind_int(update_setting_statement, 20, self.cleanOldDayCount);
		sqlite3_bind_int(update_setting_statement, 21, self.isFirstTimeStart);
		sqlite3_bind_text(update_setting_statement, 22, [self.gCalAccount UTF8String], -1, SQLITE_TRANSIENT);
		
//		sqlite3_bind_double(update_setting_statement, 23, [[self.lastSyncedTime addTimeInterval:gmtSeconds -[App_defaultTimeZone isDaylightSavingTimeForDate:self.lastSyncedTime]?0:dstOffset] timeIntervalSince1970] );
		sqlite3_bind_double(update_setting_statement, 23, [self.lastSyncedTime timeIntervalSince1970] +gmtSeconds);		
		sqlite3_bind_text(update_setting_statement, 24, [self.deleteItemsInTaskList UTF8String], -1, SQLITE_TRANSIENT);
		
		sqlite3_bind_int(update_setting_statement, 25, self.syncType);
		
		sqlite3_bind_int(update_setting_statement, 26, self.deletingType);
		
//		sqlite3_bind_text(update_setting_statement, 26, [self.calProjectMap UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(update_setting_statement,27,self.isFirstInstlUpdatStart);
		
		if(self.snapImageData != nil)
			sqlite3_bind_blob(update_setting_statement, 28, [self.snapImageData bytes], [self.snapImageData length], SQLITE_TRANSIENT);
		else
			sqlite3_bind_blob(update_setting_statement, 28, nil, -1, NULL);
		
		sqlite3_bind_int(update_setting_statement,29,self.syncWindowStart);
		sqlite3_bind_int(update_setting_statement,30,self.syncWindowEnd);
		sqlite3_bind_int(update_setting_statement,31,self.findTimeSlotInNumberOfDays);
		sqlite3_bind_int(update_setting_statement,32,self.numberOfRestartTimes);
		sqlite3_bind_int(update_setting_statement,33,self.adjustTimeIntervalForNewDue);
		sqlite3_bind_int(update_setting_statement,34,self.badgeType);
		sqlite3_bind_int(update_setting_statement,35,self.weekStartDay);
		
		sqlite3_bind_text(update_setting_statement, 36, [self.previousDevToken UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(update_setting_statement,37,self.isNeedShowPushWarning);
		sqlite3_bind_int(update_setting_statement,38,self.startWorkingWDay);
		sqlite3_bind_int(update_setting_statement,39,self.endWorkingWDay);
		
		sqlite3_bind_int(update_setting_statement,40,self.snoozeDuration);
		sqlite3_bind_int(update_setting_statement,41,self.snoozeUnit);
		
		sqlite3_bind_text(update_setting_statement, 42, [self.toodledoToken UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_double(update_setting_statement, 43, [self.toodledoTokenTime timeIntervalSince1970]+gmtSeconds);
		sqlite3_bind_text(update_setting_statement, 44, [self.toodledoUserId UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(update_setting_statement, 45, [self.toodledoUserName UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(update_setting_statement, 46, [self.toodledoPassword UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(update_setting_statement, 47, [self.toodledoKey UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_double(update_setting_statement, 48, [self.toodledoSyncTime timeIntervalSince1970]+gmtSeconds);
		
		sqlite3_bind_int(update_setting_statement,49,self.toodledoSyncType);
		sqlite3_bind_text(update_setting_statement, 50, [self.toodledoDeletedFolders UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(update_setting_statement,51,self.isFirstTimeToodledoSync);
		sqlite3_bind_text(update_setting_statement, 52, [self.toodledoDeletedTasks UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(update_setting_statement,53,self.enableSyncToodledo);
		//enableSyncICal
		sqlite3_bind_int(update_setting_statement,54,self.enableSyncICal);
		//defaultProjectId
		sqlite3_bind_int(update_setting_statement,55,self.defaultProjectId);
		//hasToodledoFirstTimeSynced
		sqlite3_bind_int(update_setting_statement,56,self.hasToodledoFirstTimeSynced);
		//deletedICalEvents
		sqlite3_bind_text(update_setting_statement, 57, [self.deletedICalEvents UTF8String], -1, SQLITE_TRANSIENT);
		
		//iCalLastSyncTime
		sqlite3_bind_double(update_setting_statement, 58, [self.iCalLastSyncTime timeIntervalSince1970]+gmtSeconds);
		
        //deletedICalCalendars
        sqlite3_bind_text(update_setting_statement, 59, [self.deletedICalCalendars UTF8String], -1, SQLITE_TRANSIENT);
        //autoICalSync
        sqlite3_bind_int(update_setting_statement,60,self.autoICalSync);
        //syncEventOnly
        sqlite3_bind_int(update_setting_statement,61,self.syncEventOnly);
        //firstStart41
        sqlite3_bind_int(update_setting_statement,62,self.firstStart41);
        
        //wasHardClosed
        sqlite3_bind_int(update_setting_statement,63,self.wasHardClosed);
        //enabledReminderSync
        sqlite3_bind_int(update_setting_statement,64,self.enabledReminderSync);
        //deletedReminderLists
        sqlite3_bind_text(update_setting_statement, 65, [self.deletedReminderLists UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(update_setting_statement, 66, [self.deletedReminders UTF8String], -1, SQLITE_TRANSIENT);
        
		sqlite3_bind_int(update_setting_statement, 67, self.primaryKey);
		
        // Execute the query.
        int success = sqlite3_step(update_setting_statement);
        // Reset the query for the next use.
        sqlite3_reset(update_setting_statement);
//		sqlite3_finalize(update_setting_statement);	
//		update_setting_statement=nil;
        // Handle errors.
        if (success != SQLITE_DONE) {
            NSAssert1(0, @"Error: failed to update with message '%s'.", sqlite3_errmsg(database));
        }
        // Update the object state with respect to unwritten changes.
        self.dirty = NO;
    }
    // Release member variables to reclaim memory. Set to nil to avoid over-releasing them 
    [data release];
    data = nil;
    // Update the object state with respect to hydration.
    updated = NO;
    
    isLockingDB=NO;
}

#pragma mark common methods


#pragma mark Properties
// Accessors implemented below. All the "get" accessors simply return the value directly, with no additional
// logic or steps for synchronization. The "set" accessors attempt to verify that the new value is definitely
// different from the old value, to minimize the amount of work done. Any "set" which actually results in changing
// data will mark the object as "dirty" - i.e., possessing data that has not been written to the database.
// All the "set" accessors copy data, rather than retain it. This is common for value objects - strings, numbers, 
// dates, data buffers, etc. This ensures that subsequent changes to either the original or the copy don't violate 
// the encapsulation of the owning object.

- (NSInteger)primaryKey {
    return primaryKey;
}

-(void)setPrimaryKey:(NSInteger)num{
	primaryKey=num;
}

- (NSInteger)setID{
	return setID;	
}

- (void)setSetID:(NSInteger)num{
	setID=num;
}

//Alarm sound name
- (NSString *)alarmSoundName {
    return alarmSoundName;
}

- (void)setAlarmSoundName:(NSString *)aString {
    if ((!alarmSoundName && !aString) || (alarmSoundName && aString && [alarmSoundName isEqualToString:aString])) return;
    self.dirty = YES;
    [alarmSoundName release];
    alarmSoundName = [aString copy];
}

//iVo Style
- (NSInteger)iVoStyleID{
	return iVoStyleID;	
}

- (void)setIVoStyleID:(NSInteger)num{
	if(iVoStyleID==num) return;	
	self.dirty=YES;
	iVoStyleID=num;
	
	if (_calendarView != nil)
	{
		[_calendarView changeBackgroundStyle];
	}
}

//Desk time start
- (NSDate *)deskTimeStart{
	return deskTimeStart;	
}
	
- (void)setDeskTimeStart:(NSDate *)aDate{
	if ([deskTimeStart isEqualToDate:aDate]) return;
	self.dirty=YES;
	
	if (deskTimeStart!=nil){
		[deskTimeStart release];
	}	
	deskTimeStart=[aDate copy];
}

//Desk time end
- (NSDate *)deskTimeEnd{
	return deskTimeEnd;	
}

- (void)setDeskTimeEnd:(NSDate *)aDate{
	if ([deskTimeEnd isEqualToDate:aDate]) return;
	self.dirty=YES;
	
	if (deskTimeEnd!=nil){
		[deskTimeEnd release];
	}	
	deskTimeEnd=[aDate copy];
}

//Desk time Weekend start
- (NSDate *)deskTimeWEStart{
	return deskTimeWEStart;	
}

- (void)setDeskTimeWEStart:(NSDate *)aDate{
	if ([deskTimeWEStart isEqualToDate:aDate]) return;
	self.dirty=YES;
	
	if (deskTimeWEStart!=nil){
		[deskTimeWEStart release];
	}	
	deskTimeWEStart=[aDate copy];
}

//Desk time weekend  end
- (NSDate *)deskTimeWEEnd{
	return deskTimeWEEnd;	
}

- (void)setDeskTimeWEEnd:(NSDate *)aDate{
	if ([deskTimeWEEnd isEqualToDate:aDate]) return;
	self.dirty=YES;
	
	if (deskTimeWEEnd!=nil){
		[deskTimeWEEnd release];
	}	
	deskTimeWEEnd=[aDate copy];
}

//Home time normal day start
- (NSDate *)homeTimeNDStart{
	return homeTimeNDStart;	
}

- (void)setHomeTimeNDStart:(NSDate *)aDate{
	if ([homeTimeNDStart isEqualToDate:aDate]) return;
	self.dirty=YES;
	
	if (homeTimeNDStart!=nil){
		[homeTimeNDStart release];
	}	
	homeTimeNDStart=[aDate copy];
}

//Home time normal day end
- (NSDate *)homeTimeNDEnd{
	return homeTimeNDEnd;	
}

- (void)setHomeTimeNDEnd:(NSDate *)aDate{
	if ([homeTimeNDEnd isEqualToDate:aDate]) return;
	self.dirty=YES;
	
	if (homeTimeNDEnd!=nil){
		[homeTimeNDEnd release];
	}	
	homeTimeNDEnd=[aDate copy];
}

//Home time weekend day start
- (NSDate *)homeTimeWEStart{
	return homeTimeWEStart;	
}

- (void)setHomeTimeWEStart:(NSDate *)aDate{
	if ([homeTimeWEStart isEqualToDate:aDate]) return;
	self.dirty=YES;
	
	if (homeTimeWEStart!=nil){
		[homeTimeWEStart release];
	}	
	homeTimeWEStart=[aDate copy];
}

//Home time normal day end
- (NSDate *)homeTimeWEEnd{
	return homeTimeWEEnd;	
}

- (void)setHomeTimeWEEnd:(NSDate *)aDate{
	if ([homeTimeWEEnd isEqualToDate:aDate]) return;
	self.dirty=YES;
	
	if (homeTimeWEEnd!=nil){
		[homeTimeWEEnd release];
	}	
	homeTimeWEEnd=[aDate copy];
}

//lastSyncedTime
- (NSDate *)lastSyncedTime{
	return lastSyncedTime;	
}

- (void)setLastSyncedTime:(NSDate *)aDate{
	if ([lastSyncedTime isEqualToDate:aDate]) return;
	self.dirty=YES;
	
	if (lastSyncedTime!=nil){
		[lastSyncedTime release];
	}	
	lastSyncedTime=[aDate copy];
}

//how long default
- (NSInteger)howlongDefVal{
	return howlongDefVal;	
}

- (void)setHowlongDefVal:(NSInteger)num{
	if(howlongDefVal==num) return;
	self.dirty=YES;
	howlongDefVal=num;
}

//context id default
- (NSInteger)contextDefID{
	return contextDefID;	
}

- (void)setContextDefID:(NSInteger)num{
	if(contextDefID==num) return;
	self.dirty=YES;
	contextDefID=num;
}

//repeat id default
- (NSInteger)repeatDefID{
	return repeatDefID;	
}

- (void)setRepeatDefID:(NSInteger)num{
	if(repeatDefID==num) return;
	self.dirty=YES;
	repeatDefID=num;
}

//project id default
- (NSInteger)projectDefID{
	return projectDefID;	
}

- (void)setProjectDefID:(NSInteger)num{
	if(projectDefID==num) return;
	self.dirty=YES;
	projectDefID=num;
}

//End repeat days count default
- (NSInteger)endRepeatCount{
	return endRepeatCount;	
}

- (void)setEndRepeatCount:(NSInteger)num{
	if(endRepeatCount==num) return;
	self.dirty=YES;
	endRepeatCount=num;
}

//expiredBetaTestDate
- (NSDate *)expiredBetaTestDate{
	return expiredBetaTestDate;	
}

- (void)setExpiredBetaTestDate:(NSDate *)aDate{
	if ([expiredBetaTestDate isEqualToDate:aDate]) return;
	self.dirty=YES;
	
	if (expiredBetaTestDate!=nil){
		[expiredBetaTestDate release];
	}	
	expiredBetaTestDate=[aDate copy];
}

//Moving Style days count default
- (NSInteger)taskMovingStyle{
	return taskMovingStyle;	
}

- (void)setTaskMovingStyle:(NSInteger)num{
	if(taskMovingStyle==num) return;
	self.dirty=YES;
	taskMovingStyle=num;
}

//Due in Moving 
- (NSInteger)dueWhenMove{
	return dueWhenMove;	
}

- (void)setDueWhenMove:(NSInteger)num{
	if(dueWhenMove==num) return;
	self.dirty=YES;
	dueWhenMove=num;
}

//pushTaskFoward
- (NSInteger)pushTaskFoward{
	return pushTaskFoward;	
}

- (void)setPushTaskFoward:(NSInteger)num{
	if(pushTaskFoward==num) return;
	self.dirty=YES;
	pushTaskFoward=num;
	
}
- (BOOL)dirty{
	return dirty;	
}

- (void)setDirty:(BOOL)bl{
	dirty=bl;	
}

-(NSInteger)cleanOldDayCount{
	return cleanOldDayCount;
}

-(void)setCleanOldDayCount:(NSInteger)aNum{
	if(cleanOldDayCount==aNum) return;
	self.dirty=YES;
	cleanOldDayCount=aNum;
}

-(NSInteger)isFirstTimeStart{
	return isFirstTimeStart;
}

-(void)setIsFirstTimeStart:(NSInteger)aNum{
	if(isFirstTimeStart==aNum) return;
	self.dirty=YES;
	isFirstTimeStart=aNum;
}
	
//Alarm sound name
- (NSString *)gCalAccount {
    return gCalAccount;
}

- (void)setGCalAccount:(NSString *)aString {
    if ((!gCalAccount && !aString) || (gCalAccount && aString && [gCalAccount isEqualToString:aString])) return;
    self.dirty = YES;
    [gCalAccount release];
    gCalAccount = [aString copy];
}

//deleteItemsInTaskList
- (NSString *)deleteItemsInTaskList {
    return deleteItemsInTaskList;
}

- (void)setDeleteItemsInTaskList:(NSString *)aString {
    if ((!deleteItemsInTaskList && !aString) || (deleteItemsInTaskList && aString && [deleteItemsInTaskList isEqualToString:aString])) return;
    self.dirty = YES;
    [deleteItemsInTaskList release];
    deleteItemsInTaskList = [aString copy];
}

/*n
- (NSInteger)syncType {
	return syncType;
}

-(void)setSyncType:(NSInteger)aNum{
	
	if(syncType==aNum) return;
	self.dirty=YES;
	syncType=aNum;
}
*/
 

-(NSInteger)deletingType{
	return deletingType;
}

-(void)setDeletingType:(NSInteger)aNum{
	if(deletingType==aNum) return;
	self.dirty=YES;
	deletingType=aNum;
}

//isFirstInstlUpdatStart
-(NSInteger)isFirstInstlUpdatStart{
	return isFirstInstlUpdatStart;
}

-(void)setIsFirstInstlUpdatStart:(NSInteger)aNum{
	if(isFirstInstlUpdatStart==aNum) return;
	self.dirty=YES;
	isFirstInstlUpdatStart=aNum;
}

-(NSData *)snapImageData{
	return snapImageData;
}

-(void)setSnapImageData:(NSData *)imgData{
	if(!imgData) return;
	dirty=YES;
	[snapImageData release];
	snapImageData=[[NSData dataWithData:imgData] retain];
}

/*
//calProjectMap
- (NSString *)calProjectMap {
    return calProjectMap;
}

- (void)setCalProjectMap:(NSString *)aString {
    if ((!calProjectMap && !aString) || (calProjectMap && aString && [calProjectMap isEqualToString:aString])) return;
    self.dirty = YES;
    [calProjectMap release];
    calProjectMap = [aString copy];
}
*/

-(NSInteger)syncWindowStart{
	return syncWindowStart;
}

-(void)setSyncWindowStart:(NSInteger)aNum{
	if(syncWindowStart==aNum) return;
	self.dirty=YES;
	syncWindowStart=aNum;
}

-(NSInteger)syncWindowEnd{
	return syncWindowEnd;
}

-(void)setSyncWindowEnd:(NSInteger)aNum{
	if(syncWindowEnd==aNum) return;
	self.dirty=YES;
	syncWindowEnd=aNum;
}

//findTimeSlotInNumberOfDays
-(NSInteger)findTimeSlotInNumberOfDays{
	return findTimeSlotInNumberOfDays;
}

-(void)setFindTimeSlotInNumberOfDays:(NSInteger)aNum{
	if(findTimeSlotInNumberOfDays==aNum) return;
	self.dirty=YES;
	findTimeSlotInNumberOfDays=aNum;
}

//numberOfRestartTimes
-(NSInteger)numberOfRestartTimes{
	return numberOfRestartTimes;
}

-(void)setNumberOfRestartTimes:(NSInteger)aNum{
	if(numberOfRestartTimes==aNum) return;
	self.dirty=YES;
	numberOfRestartTimes=aNum;
}

//adjustTimeIntervalForNewDue
-(NSInteger)adjustTimeIntervalForNewDue{
	return adjustTimeIntervalForNewDue;
}

-(void)setAdjustTimeIntervalForNewDue:(NSInteger)aNum{
	if(adjustTimeIntervalForNewDue==aNum) return;
	self.dirty=YES;
	if(aNum<86400){
		adjustTimeIntervalForNewDue=aNum;
	}else {
		adjustTimeIntervalForNewDue=1;
	}
}

//badgeType
-(NSInteger)badgeType{
	return badgeType;
}

-(void)setBadgeType:(NSInteger)aNum{
	if(badgeType==aNum) return;
	self.dirty=YES;
	badgeType=aNum;
}

//weekStartDay;
-(NSInteger)weekStartDay{
	return weekStartDay;
}

-(void)setWeekStartDay:(NSInteger)aNum{
	if(weekStartDay==aNum) return;
	self.dirty=YES;
	weekStartDay=aNum;
}

//previousDevToken
- (NSString *)previousDevToken {
    return previousDevToken;
}

- (void)setPreviousDevToken:(NSString *)aString {
    if ((!previousDevToken && !aString) || (previousDevToken && aString && [previousDevToken isEqualToString:aString])) return;
    self.dirty = YES;
    [previousDevToken release];
    previousDevToken = [aString copy];
}

//isNeedShowPushWarning
-(NSInteger)isNeedShowPushWarning{
	return isNeedShowPushWarning;
}

-(void)setIsNeedShowPushWarning:(NSInteger)aNum{
	if(isNeedShowPushWarning==aNum) return;
	self.dirty=YES;
	isNeedShowPushWarning=aNum;
}

//startWorkingWDay
-(NSInteger)startWorkingWDay{
	return startWorkingWDay;
}

-(void)setStartWorkingWDay:(NSInteger)aNum{
	if(startWorkingWDay==aNum && aNum>0) return;
	self.dirty=YES;
	if(aNum<1){
		startWorkingWDay=2;
	}else {
		startWorkingWDay=aNum;
	}
}

-(NSInteger)endWorkingWDay{
	return endWorkingWDay;
}

-(void)setEndWorkingWDay:(NSInteger)aNum{
	if(endWorkingWDay==aNum && aNum>0) return;
	self.dirty=YES;
	if(aNum<1){
		endWorkingWDay=6;
	}else {
		endWorkingWDay=aNum;
	}
}

- (NSInteger)snoozeDuration{
	return snoozeDuration;	
}

- (void)setSnoozeDuration:(NSInteger)num{
	if(snoozeDuration==num) return;
	self.dirty=YES;
	snoozeDuration=num;
}

- (NSInteger)snoozeUnit{
	return snoozeUnit;	
}

- (void)setSnoozeUnit:(NSInteger)num{
	if(snoozeUnit==num) return;
	self.dirty=YES;
	snoozeUnit=num;
}

//toodledoToken
- (NSString *)toodledoToken {
    return toodledoToken;
}

- (void)setToodledoToken:(NSString *)aString {
    if ((!toodledoToken && !aString) || (toodledoToken && aString && [toodledoToken isEqualToString:aString])) return;
    self.dirty = YES;
    [toodledoToken release];
    toodledoToken = [aString copy];
}

//toodledoTokenTime
- (NSDate *)toodledoTokenTime{
	return toodledoTokenTime;	
}

- (void)setToodledoTokenTime:(NSDate *)aDate{
	if ([toodledoTokenTime isEqualToDate:aDate]) return;
	self.dirty=YES;
	
	if (toodledoTokenTime!=nil){
		[toodledoTokenTime release];
	}	
	toodledoTokenTime=[aDate copy];
}

//toodledoUserId
- (NSString *)toodledoUserId {
    return toodledoUserId;
}

- (void)setToodledoUserId:(NSString *)aString {
    if ((!toodledoUserId && !aString) || (toodledoUserId && aString && [toodledoUserId isEqualToString:aString])) return;
    self.dirty = YES;
    [toodledoUserId release];
    toodledoUserId = [aString copy];
}

//toodledoUserName
- (NSString *)toodledoUserName {
    return toodledoUserName;
}

- (void)setToodledoUserName:(NSString *)aString {
    if ((!toodledoUserName && !aString) || (toodledoUserName && aString && [toodledoUserName isEqualToString:aString])) return;
    self.dirty = YES;
    [toodledoUserName release];
    toodledoUserName = [aString copy];
}

//toodledoPassword
- (NSString *)toodledoPassword {
    return toodledoPassword;
}

- (void)setToodledoPassword:(NSString *)aString {
    if ((!toodledoPassword && !aString) || (toodledoPassword && aString && [toodledoPassword isEqualToString:aString])) return;
    self.dirty = YES;
    [toodledoPassword release];
    toodledoPassword = [aString copy];
}

//toodledoKey
- (NSString *)toodledoKey {
    return toodledoKey;
}

- (void)setToodledoKey:(NSString *)aString {
    if ((!toodledoKey && !aString) || (toodledoKey && aString && [toodledoKey isEqualToString:aString])) return;
    self.dirty = YES;
    [toodledoKey release];
    toodledoKey = [aString copy];
}

//toodledoSyncTime
- (NSDate *)toodledoSyncTime{
	return toodledoSyncTime;	
}

- (void)setToodledoSyncTime:(NSDate *)aDate{
	if ([toodledoSyncTime isEqualToDate:aDate]) return;
	self.dirty=YES;
	
	if (toodledoSyncTime!=nil){
		[toodledoSyncTime release];
	}	
	toodledoSyncTime=[aDate copy];
}

//toodledoSyncType
- (NSInteger)toodledoSyncType{
	return toodledoSyncType;	
}

- (void)setToodledoSyncType:(NSInteger)num{
	if(toodledoSyncType==num) return;
	self.dirty=YES;
	toodledoSyncType=num;
}

//toodledoDeletedFolders
- (NSString *)toodledoDeletedFolders {
    return toodledoDeletedFolders;
}

- (void)setToodledoDeletedFolders:(NSString *)aString {
    if ((!toodledoDeletedFolders && !aString) || (toodledoDeletedFolders && aString && [toodledoDeletedFolders isEqualToString:aString])) return;
    self.dirty = YES;
    [toodledoDeletedFolders release];
    toodledoDeletedFolders = [aString copy];
}

//isFirstTimeToodledoSync
- (NSInteger)isFirstTimeToodledoSync{
	return isFirstTimeToodledoSync;	
}

- (void)setIsFirstTimeToodledoSync:(NSInteger)num{
	if(isFirstTimeToodledoSync==num) return;
	self.dirty=YES;
	isFirstTimeToodledoSync=num;
}

//toodledoDeletedTasks
- (NSString *)toodledoDeletedTasks {
    return toodledoDeletedTasks;
}

- (void)setToodledoDeletedTasks:(NSString *)aString {
    if ((!toodledoDeletedTasks && !aString) || (toodledoDeletedTasks && aString && [toodledoDeletedTasks isEqualToString:aString])) return;
    self.dirty = YES;
    [toodledoDeletedTasks release];
    toodledoDeletedTasks = [aString copy];
}

//enableSyncToodledo
- (NSInteger)enableSyncToodledo{
	return enableSyncToodledo;	
}

- (void)setEnableSyncToodledo:(NSInteger)num{
	if(enableSyncToodledo==num) return;
	self.dirty=YES;
	enableSyncToodledo=num;
}

//enableSyncICal
- (NSInteger)enableSyncICal{
	return enableSyncICal;	
}

- (void)setEnableSyncICal:(NSInteger)num{
	if(enableSyncICal==num) return;
	self.dirty=YES;
	enableSyncICal=num;
}

//defaultProjectId
- (NSInteger)defaultProjectId{
	return defaultProjectId;	
}

- (void)setDefaultProjectId:(NSInteger)num{
	if(defaultProjectId==num) return;
	self.dirty=YES;
	defaultProjectId=num;
    //self.projectDefID=num;
}

//autoICalSync
- (NSInteger)autoICalSync{
	return autoICalSync;	
}

- (void)setAutoICalSync:(NSInteger)num{
	if(autoICalSync==num) return;
	self.dirty=YES;
	autoICalSync=num;
}

- (NSInteger)autoTDSync{
	return autoTDSync;	
}

- (void)setAutoTDSync:(NSInteger)num{
	if(autoTDSync==num) return;
	self.dirty=YES;
	autoTDSync=num;
}

//hasToodledoFirstTimeSynced
- (NSInteger)hasToodledoFirstTimeSynced{
	return hasToodledoFirstTimeSynced;	
}

- (void)setHasToodledoFirstTimeSynced:(NSInteger)num{
	if(hasToodledoFirstTimeSynced==num) return;
	self.dirty=YES;
	hasToodledoFirstTimeSynced=num;
}

//deletedICalEvents
- (NSString *)deletedICalEvents {
    return deletedICalEvents;
}

- (void)setDeletedICalEvents:(NSString *)aString {
    if ((!deletedICalEvents && !aString) || (deletedICalEvents && aString && [deletedICalEvents isEqualToString:aString])) return;
    self.dirty = YES;
    [deletedICalEvents release];
    deletedICalEvents = [aString copy];
}

//iCalLastSyncTime
- (NSDate *)iCalLastSyncTime{
	return iCalLastSyncTime;	
}

- (void)setICalLastSyncTime:(NSDate *)aDate{
	if ([iCalLastSyncTime isEqualToDate:aDate]) return;
	self.dirty=YES;
	
	if (iCalLastSyncTime!=nil){
		[iCalLastSyncTime release];
	}	
	iCalLastSyncTime=[aDate copy];
}

//deletedICalCalendars
- (NSString *)deletedICalCalendars {
    return deletedICalCalendars;
}

- (void)setDeletedICalCalendars:(NSString *)aString {
    if ((!deletedICalCalendars && !aString) || (deletedICalCalendars && aString && [deletedICalCalendars isEqualToString:aString])) return;
    self.dirty = YES;
    [deletedICalCalendars release];
    deletedICalCalendars = [aString copy];
}

//syncEventOnly
- (NSInteger)syncEventOnly{
	return syncEventOnly;	
}

- (void)setSyncEventOnly:(NSInteger)num{
	if(syncEventOnly==num) return;
	self.dirty=YES;
	syncEventOnly=num;
}

//firstStart41
- (NSInteger)firstStart41{
	return firstStart41;	
}

- (void)setFirstStart41:(NSInteger)num{
	if(firstStart41==num) return;
	self.dirty=YES;
	firstStart41=num;
}

//wasHardClosed
- (NSInteger)wasHardClosed{
	return wasHardClosed;	
}

- (void)setWasHardClosed:(NSInteger)num{
	if(wasHardClosed==num) return;
	self.dirty=YES;
	wasHardClosed=num;
}

//enabledReminderSync
- (NSInteger)enabledReminderSync{
	return enabledReminderSync;
}

- (void)setEnabledReminderSync:(NSInteger)num{
	if(enabledReminderSync==num) return;
	self.dirty=YES;
	enabledReminderSync=num;
}

//deletedReminderLists
- (NSString *)deletedReminderLists {
    return deletedReminderLists;
}

- (void)setDeletedReminderLists:(NSString *)aString {
    if ((!deletedReminderLists && !aString) || (deletedReminderLists && aString && [deletedReminderLists isEqualToString:aString])) return;
    self.dirty = YES;
    [deletedReminderLists release];
    deletedReminderLists = [aString copy];
}

- (NSString *)deletedReminders {
    return deletedReminders;
}

- (void)setDeletedReminders:(NSString *)aString {
    if ((!deletedReminders && !aString) || (deletedReminders && aString && [deletedReminders isEqualToString:aString])) return;
    self.dirty = YES;
    [deletedReminders release];
    deletedReminders = [aString copy];
}

@end
