//
//  Task.m
//  iVo_DatabaseAccess
//
//  Created by Nang Le on 4/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Task.h"
#import "SmartTimeAppDelegate.h"
#import "ivo_Utilities.h"
#import "Alert.h"

static sqlite3_stmt *insert_statement = nil;
static sqlite3_stmt *init_statement = nil;
static sqlite3_stmt *delete_statement = nil;
//static sqlite3_stmt *hydrate_statement = nil;
static sqlite3_stmt *update_statement = nil;

static sqlite3_stmt *insert_dummy_statement = nil;
static sqlite3_stmt *init_dummy_statement = nil;
static sqlite3_stmt *delete_dummy_statement = nil;
//static sqlite3_stmt *hydrate_statement = nil;
static sqlite3_stmt *update_dummy_statement = nil;

extern sqlite3 *database;
extern NSInteger gmtSeconds;
extern ivo_Utilities *ivoUtility;

extern NSTimeZone	*App_defaultTimeZone;
extern BOOL				isDayLigtSavingTime;
extern NSTimeInterval	dstOffset;
extern TaskManager *taskmanager;

extern NSMutableArray *alertList;

extern BOOL isLockingDB;

@implementation Task

@synthesize dirty,isDeletedFromGCal;
@synthesize taskKey;
@synthesize filledDummiesToDate;
@synthesize isNeedAdjustDST;
@synthesize isChangedAlertSetting;

@synthesize isMultiParts;
@synthesize howLongParts;
@synthesize currentHowlong;

@synthesize originalExceptionDate;

//@synthesize gcalEventId;

-(id)init{
	self=[super init];

	self.taskName=@"";
    self.taskDescription=@"";
	self.taskDueStartDate=[NSDate date];
	self.taskNotEalierThan=[NSDate date];
	self.taskPhoneToCall=@"";
	self.taskEndRepeatDate=[NSDate date];
	
	self.taskOriginalWhere=-1;
	self.primaryKey=-1;
	self.taskIsUseDeadLine=0;
	self.taskRepeatID=0;
	self.taskNumberInstances=0;
	self.parentRepeatInstance=-1;
	self.taskRepeatExceptions=@"";
	self.taskRepeatOptions=@"1//0";
	self.isAllDayEvent=0;
	self.isUsedExternalUpdateTime=NO;
	
	//*[Trung] for GCal sync
	self.taskStartTime = [NSDate date];
	self.taskREStartTime=[NSDate date];
	self.taskEndTime = [[NSDate date] dateByAddingTimeInterval:900];
	self.taskHowLong = 900;
	self.taskName = @"";
	self.taskDescription = @"";
	self.taskLocation = @"";
	self.taskDefault = 0;
	self.taskCompleted = 0;
	self.taskDeadLine = [NSDate date];
	self.taskDueEndDate = [[NSDate date] dateByAddingTimeInterval:93312000];
	self.taskDateUpdate = [NSDate date];
	self.taskContact = @"";
	self.taskEmailToSend = @"";
	self.taskAlertValues=@"";
	self.taskSynKey=0;
	//[Trung] for GCal sync *
	self.gcalEventId = nil;
	self.isDeletedFromGCal=NO;
	self.filledDummiesToDate=[NSDate date];
	self.isNeedAdjustDST=NO;
	self.isChangedAlertSetting=NO;
	self.specifiedAlertTime=[NSDate date];
	self.alertByDeadline=0;
	self.toodledoID=0;
	
	self.taskProject=taskmanager.currentSetting.projectDefID;
	self.isMultiParts=NO;
	self.howLongParts=@"";
	self.hasAlert=0;
    
    self.alertIndex=0;
    self.taskRepeatStyle=0;
    self.reminderIdentifier=@"";
    
	return self;
}

//prepare the new empty row in Catagory table for update later (when user create new category on UI)
- (NSInteger)prepareNewRecordIntoDatabase:(sqlite3 *)database {
	// This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed.
    while (isLockingDB) {
        //usleep(20);
        [NSThread sleepForTimeInterval:0.01];
    }
    isLockingDB=YES;
    
    if (insert_statement == nil) {
        static char *sql = "INSERT INTO iVo_Tasks (Task_Name) VALUES('')";
		//NSString *sql =[NSString stringWithFormat:@"INSERT INTO %@ (Task_Name) VALUES('')",tableName];
        if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
    int success = sqlite3_step(insert_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_statement);
//	sqlite3_finalize(insert_statement);	
//	insert_statement=nil;
    if (success != SQLITE_ERROR) {
        // SQLite provides a method which retrieves the value of the most recently auto-generated primary key sequence
        // in the database. To access this functionality, the table should have a column declared of type 
        // "INTEGER PRIMARY KEY"
        self.primaryKey= sqlite3_last_insert_rowid(database);
		updated=YES;
        isLockingDB=NO;
		return primaryKey;
    }
    NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
    isLockingDB=NO;
    
    return -1;
}

- (NSInteger)prepareDummyIntoDatabase:(sqlite3 *)database {
	// This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed.
    if (insert_dummy_statement == nil) {
        static char *sql = "INSERT INTO RE_Dummies (Task_Name) VALUES('')";
		//NSString *sql =[NSString stringWithFormat:@"INSERT INTO %@ (Task_Name) VALUES('')",tableName];
        if (sqlite3_prepare_v2(database, sql, -1, &insert_dummy_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
    int success = sqlite3_step(insert_dummy_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_dummy_statement);
	//	sqlite3_finalize(insert_statement);	
	//	insert_statement=nil;
    if (success != SQLITE_ERROR) {
        // SQLite provides a method which retrieves the value of the most recently auto-generated primary key sequence
        // in the database. To access this functionality, the table should have a column declared of type 
        // "INTEGER PRIMARY KEY"
        self.primaryKey= sqlite3_last_insert_rowid(database);
		updated=YES;
		return primaryKey;
    }
    NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
    return -1;
}

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements {
    
	if (insert_statement) sqlite3_finalize(insert_statement);
    if (init_statement) sqlite3_finalize(init_statement);
    if (delete_statement) sqlite3_finalize(delete_statement);
    if (update_statement) sqlite3_finalize(update_statement);
	
	if (insert_dummy_statement) sqlite3_finalize(insert_dummy_statement);
    if (init_dummy_statement) sqlite3_finalize(init_dummy_statement);
    if (delete_dummy_statement) sqlite3_finalize(delete_dummy_statement);
    if (update_dummy_statement) sqlite3_finalize(update_dummy_statement);
	
}

// Creates the task object with primary key and name, description is brought into memory.
- (id)getInfoWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db{
	if (self = [super init]) {
        
        while (isLockingDB) {
            //usleep(20);
        [NSThread sleepForTimeInterval:0.01];
        }
        isLockingDB=YES;
        
        self.primaryKey = pk;
        database = db;
        // Compile the query for retrieving book data.
        if (init_statement == nil) {
            // Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
            // This is a great way to optimize because frequently used queries can be compiled once, then with each
            // use new variable values can be bound to placeholders.
            const char *sql = "SELECT Task_Name,Task_Description,Task_Pinned,Task_Priority,Task_StartTime, Task_Status,Task_Completed,Task_TypeID,Task_What,Task_Who, \
			Task_Where,Task_When,Task_HowLong,Task_Project,Task_EndTime,Task_DueStartDate, Task_DueEndDate,Task_DateUpdate, Task_TypeUpdate, Task_Default, \
			Task_RepeatID,Task_RepeatTimes,Task_Location,Task_Contact,Task_AlertID,Task_OriginalWhere,Task_DeadLine,Task_NotEalierThan,Task_IsUseDeadLine,Set_Resvr5, \
			Set_Resvr4,Set_Resvr6,Set_Resvr3,Set_Resvr7,Set_Resvr2,Set_Resvr1,Set_Resvr8,filledDummiesToDate,taskOrder,PNSKey, \
			specifiedAlertTime,alertByDeadline,isAdjustedSpecifiedDate,toodledoID,toodledoHasStart,isHidden,iCalIdentifier,iCalCalendarName,alertIndex,alertUnit,alertBasedOn,hasAlert,taskRepeatStyle,reminderIdentifier FROM iVo_Tasks WHERE Task_ID=?";
			//NSString *sql =[NSString stringWithFormat:@"SELECT Task_Name,Task_Description,Task_Pinned,Task_Priority,Task_StartTime, Task_Status,Task_Completed,Task_TypeID,Task_What,Task_Who,Task_Where,Task_When,Task_HowLong,Task_Project,Task_EndTime,Task_DueStartDate, Task_DueEndDate,Task_DateUpdate, Task_TypeUpdate, Task_Default,Task_RepeatID,Task_RepeatTimes,Task_Location,Task_Contact,Task_AlertID,Task_OriginalWhere,Task_DeadLine,Task_NotEalierThan,Task_IsUseDeadLine,Set_Resvr5,Set_Resvr4,Set_Resvr6,Set_Resvr3,Set_Resvr7,Set_Resvr2,Set_Resvr1,Set_Resvr8 FROM %@ WHERE Task_ID=?",tableName];
            if (sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // For this query, we bind the primary key to the first (and only) placeholder in the statement.
        // Note that the parameters are numbered from 1, not from 0.
        sqlite3_bind_int(init_statement, 1, self.primaryKey);
        if (sqlite3_step(init_statement) == SQLITE_ROW) {
			//for debugging
			//printf("\n catname: %s, catDescr: %s",sqlite3_column_text(init_statement, 0),sqlite3_column_text(init_statement, 1));
            //------------

			NSDate *date=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 17)-gmtSeconds];
			NSTimeInterval adjustTimeVal=-gmtSeconds -[App_defaultTimeZone daylightSavingTimeOffsetForDate:date]+[App_defaultTimeZone daylightSavingTimeOffset];
			
			char *taskNme=(char *)sqlite3_column_text(init_statement, 0);
			char *taskDesr=(char *)sqlite3_column_text(init_statement, 1);
			self.taskName =(taskNme)? [NSString stringWithUTF8String:taskNme] : @"";
			self.taskDescription=(taskDesr)? [NSString stringWithUTF8String:taskDesr] :  @"" ;
			
			self.taskPinned=sqlite3_column_int(init_statement, 2);
			self.taskREStartTime=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 3) + adjustTimeVal]; 
			self.taskStartTime=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 4) + adjustTimeVal]; 
			
			self.taskStatus=sqlite3_column_int(init_statement, 5);
			self.taskCompleted=sqlite3_column_int(init_statement, 6);
			self.taskSynKey=sqlite3_column_double(init_statement, 7);
			self.taskWhat=sqlite3_column_int(init_statement, 8);
			self.taskWho=sqlite3_column_int(init_statement, 9);
			self.taskWhere=sqlite3_column_int(init_statement, 10);
			self.taskNumberInstances=sqlite3_column_int(init_statement, 11);
			self.taskHowLong=sqlite3_column_int(init_statement, 12);
			self.taskProject=sqlite3_column_int(init_statement, 13);
			
			self.taskEndTime=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 14) + adjustTimeVal]; 
			self.taskDueStartDate=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 15) + adjustTimeVal]; 
			
			self.taskDueEndDate=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 16) + adjustTimeVal]; 
			
			self.taskDateUpdate=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 17)]; //[[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 17)] addTimeInterval:-gmtSeconds];
			self.taskTypeUpdate=sqlite3_column_int(init_statement, 18);
			self.taskDefault=sqlite3_column_int(init_statement, 19);
			self.taskRepeatID=sqlite3_column_int(init_statement, 20);
			self.taskRepeatTimes=sqlite3_column_int(init_statement, 21);
			char *taskLoc=(char *)sqlite3_column_text(init_statement, 22);
			char *taskCon=(char *)sqlite3_column_text(init_statement, 23);
			self.taskLocation = (taskLoc)? [NSString stringWithUTF8String:taskLoc] : @"";
			self.taskContact=(taskCon)? [NSString stringWithUTF8String:taskCon] : @"" ;
			
			self.taskAlertID=sqlite3_column_int(init_statement, 24);
			self.taskOriginalWhere=sqlite3_column_int(init_statement, 25);

			self.taskDeadLine=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 26) + adjustTimeVal]; 
			
			self.taskNotEalierThan=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 27) + adjustTimeVal]; 
			
			self.taskIsUseDeadLine=sqlite3_column_int(init_statement, 28);
			
			char *email=(char *)sqlite3_column_text(init_statement, 29);
			self.gcalEventId =(email)? [NSString stringWithUTF8String:email] : @"";
			
			char *phone=(char *)sqlite3_column_text(init_statement, 30);
			self.taskPhoneToCall =(phone)? [NSString stringWithUTF8String:phone] : @"";
			
			self.taskEndRepeatDate=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 31) + adjustTimeVal]; 
			
			if( [self.taskEndRepeatDate compare:self.taskStartTime]==NSOrderedAscending)
			self.taskEndRepeatDate=self.taskStartTime;
			
			char *repeatOpt=(char *)sqlite3_column_text(init_statement, 32);
			self.taskRepeatOptions =(repeatOpt)? [NSString stringWithUTF8String:repeatOpt] : @"";
			self.parentRepeatInstance=sqlite3_column_int(init_statement, 33);
			
			char *repeatExp=(char *)sqlite3_column_text(init_statement, 34);
			self.taskRepeatExceptions =(repeatExp)? [NSString stringWithUTF8String:repeatExp] : @"";
			
			char *alertValue=(char *)sqlite3_column_text(init_statement, 35);
			self.taskAlertValues =(alertValue)? [NSString stringWithUTF8String:alertValue] : @"";

			self.isAllDayEvent=sqlite3_column_int(init_statement, 36);
			
			//filledDummiesToDate
			//self.filledDummiesToDate=[[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 37)] addTimeInterval:-gmtSeconds];
			self.taskOrder=sqlite3_column_int(init_statement, 38);
			
			char *pnsKey=(char *)sqlite3_column_text(init_statement, 39);
			self.PNSKey =(pnsKey)? [NSString stringWithUTF8String:pnsKey] : @"";
			
			self.specifiedAlertTime=[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement, 40) + adjustTimeVal]; 
			
			if([ivoUtility getYear:self.specifiedAlertTime]==1970){
				self.specifiedAlertTime=[NSDate date];
			}
			
			self.alertByDeadline=sqlite3_column_int(init_statement, 41);
			self.isAdjustedSpecifiedDate=sqlite3_column_int(init_statement, 42);
			
			self.isNeedAdjustDST=YES;
			
			self.toodledoID=sqlite3_column_int(init_statement, 43);
			self.toodledoHasStart=sqlite3_column_int(init_statement, 44);
			self.isHidden=sqlite3_column_int(init_statement, 45);
			
			char *icalid=(char *)sqlite3_column_text(init_statement, 46);
			self.iCalIdentifier =(icalid)? [NSString stringWithUTF8String:icalid] : @"";
			
			char *icalcalname=(char *)sqlite3_column_text(init_statement, 47);
			self.iCalCalendarName =(icalcalname)? [NSString stringWithUTF8String:icalcalname] : @"";
			
            self.alertIndex=sqlite3_column_int(init_statement, 48);
            //alertUnit
            self.alertUnit=sqlite3_column_int(init_statement, 49);
            //alertBasedOn
            self.alertBasedOn=sqlite3_column_int(init_statement, 50);
            //hasAlert
            self.hasAlert=sqlite3_column_int(init_statement, 51);
            self.taskRepeatStyle=sqlite3_column_int(init_statement, 52);
            
            char *rmdrID=(char *)sqlite3_column_text(init_statement, 53);
			self.reminderIdentifier =(rmdrID)? [NSString stringWithUTF8String:rmdrID] : @"";
            
		} else {
            self.taskName = @"";
			self.taskDescription= @"";
			self.taskPinned=-1;
			self.taskREStartTime=[NSDate date];
			self.taskStartTime=[NSDate date];
			self.taskEndTime=[NSDate date];
			self.taskDueStartDate=[NSDate date];
			self.taskDueEndDate=[NSDate date];
			self.taskStatus=-1;
			self.taskCompleted=-1;
			self.taskSynKey=-1;
			self.taskWhat=-1;
			self.taskWho=-1;
			self.taskWhere=-1;
			self.taskNumberInstances=-1;
			self.taskHowLong=-1;
			self.taskProject=-1;
			self.taskDateUpdate=[NSDate date];
			self.taskTypeUpdate=-1;
			self.taskDefault=-1;
			self.taskRepeatID=-1;
			self.taskRepeatTimes=-1;
			self.taskLocation=@"";
			self.taskContact=@"";
			self.taskAlertID=-1;
			self.taskOriginalWhere=-1;
			self.taskDeadLine=[NSDate date];
			self.taskNotEalierThan=[NSDate date];
			self.taskIsUseDeadLine=-1;
			self.taskEmailToSend=@"";
			self.taskPhoneToCall=@"";
			self.taskEndRepeatDate=[NSDate date];
			self.isAllDayEvent=-1;
        }
		
        // Reset the statement for future reuse.
        sqlite3_reset(init_statement);
//		sqlite3_finalize(init_statement);	
//		init_statement=nil;
        self.dirty = NO;
		//for debugging
		//printf("\n catname: %s, catDescr: %s, date: %s",[self.taskName UTF8String],[self.taskDescription UTF8String],[[self.taskStartTime description] UTF8String]);
		//------------
        
        isLockingDB=NO;
	}
    return self;
}


- (void)dealloc {
    [taskName release];
    [taskDescription release];
    [taskStartTime release];
	[taskEndTime release];
	[taskDueEndDate release];
	[taskDueStartDate release];
	[taskREStartTime release];
	[taskDateUpdate release];
	[taskLocation release];
	[taskContact release];
	[taskDeadLine release];
	[taskNotEalierThan release];
	[taskEmailToSend release];
	[taskPhoneToCall release];
	[taskEndRepeatDate release];
	[taskRepeatOptions release];
	[taskRepeatExceptions release];
	[taskAlertValues release];
	[filledDummiesToDate release];
	[specifiedAlertTime release];
	[iCalIdentifier release];
	[iCalCalendarName release];
	[reminderIdentifier release];
    
	[super dealloc];
}

- (void)deleteFromDatabase {
    // Compile the delete statement if needed.
    while (isLockingDB) {
        //usleep(20);
        [NSThread sleepForTimeInterval:0.01];
    }
    isLockingDB=YES;
    
    if (delete_statement == nil) {
        const char *sql = "DELETE FROM iVo_Tasks WHERE Task_ID=?";
		//NSString *sql =[NSString stringWithFormat:@"DELETE FROM iVo_Tasks WHERE Task_ID=?",tableName];
        if (sqlite3_prepare_v2(database, sql, -1, &delete_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
    // Bind the primary key variable.
    sqlite3_bind_int(delete_statement, 1, self.primaryKey);
    // Execute the query.
    int success = sqlite3_step(delete_statement);
    // Reset the statement for future use.
    sqlite3_reset(delete_statement);
//	sqlite3_finalize(delete_statement);	
//	delete_statement=nil;

    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }
    
    isLockingDB=NO;
}

- (void)deleteDummyFromDatabase {
    // Compile the delete statement if needed.
    if (delete_dummy_statement == nil) {
        const char *sql = "DELETE FROM RE_Dummies WHERE Task_ID=?";
		//NSString *sql =[NSString stringWithFormat:@"DELETE FROM iVo_Tasks WHERE Task_ID=?",tableName];
        if (sqlite3_prepare_v2(database, sql, -1, &delete_dummy_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
    // Bind the primary key variable.
    sqlite3_bind_int(delete_dummy_statement, 1, self.primaryKey);
    // Execute the query.
    int success = sqlite3_step(delete_dummy_statement);
    // Reset the statement for future use.
    sqlite3_reset(delete_dummy_statement);
	//	sqlite3_finalize(delete_statement);	
	//	delete_statement=nil;
	
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }
}


// Flushes all but the primary key and title out to the database.
- (void)update{
    while (isLockingDB) {
        //usleep(20);
        [NSThread sleepForTimeInterval:0.01];
    }
    isLockingDB=YES;
    
    if (self.dirty && self.primaryKey>=0) {
		
        // Write any changes to the database.
        // First, if needed, compile the update query.
        if (update_statement == nil) {
            const char *sql = "UPDATE iVo_Tasks SET Task_Name=?,\
            Task_Description=?,\
            Task_Pinned=?,\
            Task_Priority=?,\
            Task_StartTime=?,\
            Task_Status=?,\
            Task_Completed=?,\
            Task_TypeID=?,\
            Task_What=?,\
            Task_Who=?,\
            Task_Where=?,\
            Task_When=?,\
            Task_HowLong=?,\
            Task_Project=?,\
            Task_EndTime=?,\
            Task_DueStartDate=?,\
            Task_DueEndDate=?,\
            Task_DateUpdate=?,\
            Task_TypeUpdate=?,\
            Task_Default=?,\
            Task_RepeatID=?,\
            Task_RepeatTimes=?,\
            Task_Location=?,\
            Task_Contact=?,\
            Task_AlertID=?,\
            Task_OriginalWhere=?,\
            Task_DeadLine=?,\
            Task_NotEalierThan=?,\
            Task_IsUseDeadLine=?,\
            Set_Resvr5=?,\
            Set_Resvr4=?,\
            Set_Resvr6=?,\
            Set_Resvr3=?,\
            Set_Resvr7=?,\
            Set_Resvr2=?,\
            Set_Resvr1=?,\
            Set_Resvr8=?,\
            taskOrder=?,\
            PNSKey=?,\
            specifiedAlertTime=?,\
            alertByDeadline=?,\
            isAdjustedSpecifiedDate=?,\
            toodledoID=?,\
            toodledoHasStart=?,\
            isHidden=?,\
            iCalIdentifier=?,\
            iCalCalendarName=?,\
            alertIndex=?,\
            alertUnit=?,\
            alertBasedOn=?,\
            hasAlert=?,\
            taskRepeatStyle=?,\
            reminderIdentifier=? WHERE Task_ID=?";
			//NSString *sql =[NSString stringWithFormat:@"UPDATE iVo_Tasks SET Task_Name=?,Task_Description=?,Task_Pinned=?,Task_Priority=?,Task_StartTime=?,Task_Status=?,Task_Completed=?,Task_TypeID=?,Task_What=?,Task_Who=?,Task_Where=?,Task_When=?,Task_HowLong=?,Task_Project=?,Task_EndTime=?, Task_DueStartDate=?, Task_DueEndDate=?, Task_DateUpdate=?, Task_TypeUpdate=?, Task_Default=?,Task_RepeatID=?,Task_RepeatTimes=?,Task_Location=?,Task_Contact=?,Task_AlertID=?, Task_OriginalWhere=?, Task_DeadLine=?,Task_NotEalierThan=?,Task_IsUseDeadLine=?,Set_Resvr5=?,Set_Resvr4=?,Set_Resvr6=?,Set_Resvr3=?,Set_Resvr7=?,Set_Resvr2=?,Set_Resvr1=?,Set_Resvr8=? WHERE Task_ID=?";
			//const char *sql = "UPDATE iVo_Tasks SET Task_Name=?,Task_Description=? WHERE Task_ID=?";
            if (sqlite3_prepare_v2(database, sql, -1, &update_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
		
        self.taskDateUpdate=[NSDate date];
		NSDate *date=[self.taskDateUpdate retain];
		NSTimeInterval adjustTimeVal=gmtSeconds + [App_defaultTimeZone daylightSavingTimeOffsetForDate:date]-[App_defaultTimeZone daylightSavingTimeOffset];
		
        // Bind the query variables.
        sqlite3_bind_text(update_statement, 1, [self.taskName UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(update_statement, 2, [self.taskDescription UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(update_statement, 3, self.taskPinned);
		//sqlite3_bind_double(update_statement, 4, [[self.taskREStartTime addTimeInterval:gmtSeconds -([App_defaultTimeZone isDaylightSavingTimeForDate:self.taskREStartTime]?0:self.isNeedAdjustDST?dstOffset:0)] timeIntervalSince1970]);
		sqlite3_bind_double(update_statement, 4, [self.taskREStartTime timeIntervalSince1970] + adjustTimeVal);
		
		//sqlite3_bind_double(update_statement, 5, [[self.taskStartTime addTimeInterval:gmtSeconds -([App_defaultTimeZone isDaylightSavingTimeForDate:self.taskStartTime]?0:self.isNeedAdjustDST?dstOffset:0)] timeIntervalSince1970]);//[startDate timeIntervalSince1970]);
		sqlite3_bind_double(update_statement, 5, [self.taskStartTime timeIntervalSince1970] + adjustTimeVal);
		
		sqlite3_bind_int(update_statement, 6, self.taskStatus);
		sqlite3_bind_int(update_statement, 7, self.taskCompleted);
		sqlite3_bind_double(update_statement, 8, self.taskSynKey);
		sqlite3_bind_int(update_statement, 9, self.taskWhat);
		sqlite3_bind_int(update_statement, 10, self.taskWho);
		sqlite3_bind_int(update_statement, 11,self.taskWhere);
		sqlite3_bind_int(update_statement,12, self.taskNumberInstances);
		sqlite3_bind_int(update_statement, 13,self.taskHowLong);
		sqlite3_bind_int(update_statement, 14,self.taskProject);
		//sqlite3_bind_double(update_statement, 15,[[self.taskEndTime addTimeInterval:gmtSeconds -([App_defaultTimeZone isDaylightSavingTimeForDate:self.taskEndTime]?0:self.isNeedAdjustDST?dstOffset:0)] timeIntervalSince1970]);
		sqlite3_bind_double(update_statement, 15,[self.taskEndTime timeIntervalSince1970] + adjustTimeVal);
		
		//sqlite3_bind_double(update_statement, 16, [[self.taskDueStartDate addTimeInterval:gmtSeconds -([App_defaultTimeZone isDaylightSavingTimeForDate:self.taskDueStartDate]?0:self.isNeedAdjustDST?dstOffset:0)] timeIntervalSince1970]);//[startDate timeIntervalSince1970]);
		sqlite3_bind_double(update_statement, 16, [self.taskDueStartDate timeIntervalSince1970] + adjustTimeVal);//[startDate timeIntervalSince1970]);
		
		//sqlite3_bind_double(update_statement, 17, [[self.taskDueEndDate addTimeInterval:gmtSeconds-([App_defaultTimeZone isDaylightSavingTimeForDate:self.taskDueEndDate]?0:self.isNeedAdjustDST?dstOffset:0)] timeIntervalSince1970]);//[endDate timeIntervalSince1970]);
		sqlite3_bind_double(update_statement, 17, [self.taskDueEndDate timeIntervalSince1970] + adjustTimeVal);//[endDate timeIntervalSince1970]);
		
		//if(!self.isUsedExternalUpdateTime && self.taskCompleted==0){
			//Trung ST3.4
			//self.taskDateUpdate=[NSDate date];
		//	[self refreshDateUpdate];
			
		//}else {
		//	self.isUsedExternalUpdateTime=NO;
		//}
	
		sqlite3_bind_double(update_statement, 18, [self.taskDateUpdate timeIntervalSince1970]);
		sqlite3_bind_int(update_statement,19,self.taskTypeUpdate);
		sqlite3_bind_int(update_statement,20,self.taskDefault);
		sqlite3_bind_int(update_statement,21,self.taskRepeatID);
		sqlite3_bind_int(update_statement, 22,self.taskRepeatTimes);
		sqlite3_bind_text(update_statement, 23, [self.taskLocation UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(update_statement, 24, [self.taskContact UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(update_statement,25,self.taskAlertID);
		sqlite3_bind_int(update_statement,26,self.taskOriginalWhere);
		//sqlite3_bind_double(update_statement, 27,[[self.taskDeadLine addTimeInterval:gmtSeconds -([App_defaultTimeZone isDaylightSavingTimeForDate:self.taskDeadLine]?0:self.isNeedAdjustDST?dstOffset:0)] timeIntervalSince1970]);
		sqlite3_bind_double(update_statement, 27,[self.taskDeadLine timeIntervalSince1970] + adjustTimeVal);
		
		//sqlite3_bind_double(update_statement, 28,[[self.taskNotEalierThan addTimeInterval:gmtSeconds -([App_defaultTimeZone isDaylightSavingTimeForDate:self.taskNotEalierThan]?0:self.isNeedAdjustDST?dstOffset:0)] timeIntervalSince1970]);
		sqlite3_bind_double(update_statement, 28,[self.taskNotEalierThan timeIntervalSince1970] + adjustTimeVal);
		
		sqlite3_bind_int(update_statement,29,self.taskIsUseDeadLine);
		sqlite3_bind_text(update_statement, 30, [self.gcalEventId UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(update_statement, 31, [self.taskPhoneToCall UTF8String], -1, SQLITE_TRANSIENT);
		//sqlite3_bind_double(update_statement, 32, [[self.taskEndRepeatDate addTimeInterval:gmtSeconds -([App_defaultTimeZone isDaylightSavingTimeForDate:self.taskEndRepeatDate]?0:self.isNeedAdjustDST?dstOffset:0)] timeIntervalSince1970]);
		sqlite3_bind_double(update_statement, 32, [self.taskEndRepeatDate timeIntervalSince1970] + adjustTimeVal);
		
		sqlite3_bind_text(update_statement, 33, [self.taskRepeatOptions UTF8String], -1, SQLITE_TRANSIENT);
		
		sqlite3_bind_int(update_statement, 34, self.parentRepeatInstance);
		sqlite3_bind_text(update_statement, 35, [self.taskRepeatExceptions UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(update_statement, 36, [self.taskAlertValues UTF8String], -1, SQLITE_TRANSIENT);
		
		sqlite3_bind_int(update_statement,37,self.isAllDayEvent);
//		sqlite3_bind_double(update_statement, 38, [[self.filledDummiesToDate addTimeInterval:gmtSeconds] timeIntervalSince1970]);
		sqlite3_bind_int(update_statement, 38, self.taskOrder);
		
		sqlite3_bind_text(update_statement, 39, [self.PNSKey UTF8String], -1, SQLITE_TRANSIENT);
		
		//specifiedAlertTime
		sqlite3_bind_double(update_statement, 40, [self.specifiedAlertTime timeIntervalSince1970] + adjustTimeVal);
		
		//alertByDeadline
		sqlite3_bind_int(update_statement, 41, self.alertByDeadline);
		
		//isAdjustedSpecifiedDate
		sqlite3_bind_int(update_statement, 42, self.isAdjustedSpecifiedDate);
		//toodledoID
		sqlite3_bind_int(update_statement, 43, self.toodledoID);
		//toodledoHasStart
		sqlite3_bind_int(update_statement, 44, self.toodledoHasStart);
		//isHidden
		sqlite3_bind_int(update_statement, 45, self.isHidden);
		//
		sqlite3_bind_text(update_statement, 46, [self.iCalIdentifier UTF8String], -1, SQLITE_TRANSIENT);
		//iCalCalendarName
		sqlite3_bind_text(update_statement, 47, [self.iCalCalendarName UTF8String], -1, SQLITE_TRANSIENT);
		//alertIndex
        sqlite3_bind_int(update_statement, 48, self.alertIndex);
        //alertUnit
        sqlite3_bind_int(update_statement, 49, self.alertUnit);
        
        sqlite3_bind_int(update_statement, 50, self.alertBasedOn);
        //hasAlert
        sqlite3_bind_int(update_statement, 51, self.hasAlert);
        //taskRepeatStyle
        sqlite3_bind_int(update_statement, 52, self.taskRepeatStyle);
        //reminderIdentifier
        sqlite3_bind_text(update_statement, 53, [self.reminderIdentifier UTF8String], -1, SQLITE_TRANSIENT);
        
		sqlite3_bind_int(update_statement, 54, self.primaryKey);
		self.isNeedAdjustDST=NO;
		 
		[date release];

		// sqlite3_bind_int(update_statement, 3, self.primaryKey);
        // Execute the query.
        int success = sqlite3_step(update_statement);
        // Reset the query for the next use.
        sqlite3_reset(update_statement);
//		sqlite3_finalize(update_statement);	
//		update_statement=nil;
        // Handle errors.
        if (success != SQLITE_DONE) {
            NSAssert1(0, @"Error: failed to update with message '%s'.", sqlite3_errmsg(database));
        }
        // Update the object state with respect to unwritten changes.
        self.dirty = NO;

    }
	[data release];
	data = nil;
    updated = NO; 
    
    isLockingDB=NO;
}

-(void) externalUpdate
{
	isUsedExternalUpdateTime = YES;
	
	[self update];
}

-(void) enableExternalUpdate
{
	isUsedExternalUpdateTime = YES;
}

- (void) modifyUpdateTime
{
    while (isLockingDB) {
        //usleep(20);
        [NSThread sleepForTimeInterval:0.01];
    }
    isLockingDB=YES;
    
	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE iVo_Tasks SET Task_DateUpdate = ? WHERE Task_ID = ?";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	if (!isUsedExternalUpdateTime)
	{
		self.taskDateUpdate = [NSDate date];
	}
	
	isUsedExternalUpdateTime = NO;	
	
	NSTimeInterval updateTimeValue = (self.taskDateUpdate == nil? -1: [[ivoUtility dateByAddNumSecond:gmtSeconds toDate:self.taskDateUpdate] timeIntervalSince1970]);				
	
	sqlite3_bind_double(statement, 1, updateTimeValue);
	sqlite3_bind_int(statement, 2, self.primaryKey);
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
    
    isLockingDB=NO;
}

- (void) updateSyncID
{
    while (isLockingDB) {
        //usleep(20);
        [NSThread sleepForTimeInterval:0.01];
    }
    isLockingDB=YES;
    
	sqlite3_stmt *statement = nil;
	
    if (statement == nil) {
        static char *sql = "UPDATE iVo_Tasks SET Set_Resvr5 = ?, Task_DateUpdate = ? WHERE Task_ID=?";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	if (self.gcalEventId == nil)
	{
		self.gcalEventId = @"";
	}
	
	if (!isUsedExternalUpdateTime)
	{
		self.taskDateUpdate = [NSDate date];
	}
	
	isUsedExternalUpdateTime = NO;	
	
	NSTimeInterval updateTimeValue = (self.taskDateUpdate == nil? -1: [[ivoUtility dateByAddNumSecond:gmtSeconds toDate:self.taskDateUpdate] timeIntervalSince1970]);						
	
	sqlite3_bind_text(statement, 1, [self.gcalEventId UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_double(statement, 2, updateTimeValue);
	sqlite3_bind_int(statement, 3, self.primaryKey);
	
    int success = sqlite3_step(statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_finalize(statement);
    if (success != SQLITE_DONE) {
 		NSAssert1(0, @"Error: failed to update into the database with message '%s'.", sqlite3_errmsg(database));
	}
    
    isLockingDB=NO;
    
}

// Flushes all but the primary key and title out to the database.
- (void)updateDummy{
    if (self.dirty && self.primaryKey>=0) {
		
        // Write any changes to the database.
        // First, if needed, compile the update query.
        if (update_dummy_statement == nil) {
            const char *sql = "UPDATE RE_Dummies SET Task_Name=?,Task_Description=?,Task_Pinned=?,Task_Priority=?,Task_StartTime=?,Task_Status=?,Task_Completed=?,Task_TypeID=?,Task_What=?,Task_Who=?,Task_Where=?,Task_When=?,Task_HowLong=?,Task_Project=?,Task_EndTime=?, Task_DueStartDate=?, Task_DueEndDate=?, Task_DateUpdate=?, Task_TypeUpdate=?, Task_Default=?,Task_RepeatID=?,Task_RepeatTimes=?,Task_Location=?,Task_Contact=?,Task_AlertID=?, Task_OriginalWhere=?, Task_DeadLine=?,Task_NotEalierThan=?,Task_IsUseDeadLine=?,Set_Resvr5=?,Set_Resvr4=?,Set_Resvr6=?,Set_Resvr3=?,Set_Resvr7=?,Set_Resvr2=?,Set_Resvr1=?,Set_Resvr8=? WHERE Task_ID=?";
			//NSString *sql =[NSString stringWithFormat:@"UPDATE iVo_Tasks SET Task_Name=?,Task_Description=?,Task_Pinned=?,Task_Priority=?,Task_StartTime=?,Task_Status=?,Task_Completed=?,Task_TypeID=?,Task_What=?,Task_Who=?,Task_Where=?,Task_When=?,Task_HowLong=?,Task_Project=?,Task_EndTime=?, Task_DueStartDate=?, Task_DueEndDate=?, Task_DateUpdate=?, Task_TypeUpdate=?, Task_Default=?,Task_RepeatID=?,Task_RepeatTimes=?,Task_Location=?,Task_Contact=?,Task_AlertID=?, Task_OriginalWhere=?, Task_DeadLine=?,Task_NotEalierThan=?,Task_IsUseDeadLine=?,Set_Resvr5=?,Set_Resvr4=?,Set_Resvr6=?,Set_Resvr3=?,Set_Resvr7=?,Set_Resvr2=?,Set_Resvr1=?,Set_Resvr8=? WHERE Task_ID=?";
			//const char *sql = "UPDATE iVo_Tasks SET Task_Name=?,Task_Description=? WHERE Task_ID=?";
            if (sqlite3_prepare_v2(database, sql, -1, &update_dummy_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // Bind the query variables.
        self.taskDateUpdate=[NSDate date];
        
        sqlite3_bind_text(update_dummy_statement, 1, [self.taskName UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(update_dummy_statement, 2, [self.taskDescription UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(update_dummy_statement, 3, self.taskPinned);
		sqlite3_bind_double(update_dummy_statement, 4, [[self.taskREStartTime dateByAddingTimeInterval:gmtSeconds] timeIntervalSince1970]);
		sqlite3_bind_double(update_dummy_statement, 5, [[self.taskStartTime dateByAddingTimeInterval:gmtSeconds] timeIntervalSince1970]);//[startDate timeIntervalSince1970]);
		sqlite3_bind_int(update_dummy_statement, 6, self.taskStatus);
		sqlite3_bind_int(update_dummy_statement, 7, self.taskCompleted);
		sqlite3_bind_double(update_dummy_statement, 8, self.taskSynKey);
		sqlite3_bind_int(update_dummy_statement, 9, self.taskWhat);
		sqlite3_bind_int(update_dummy_statement, 10, self.taskWho);
		sqlite3_bind_int(update_dummy_statement, 11,self.taskWhere);
		sqlite3_bind_int(update_dummy_statement,12, self.taskNumberInstances);
		sqlite3_bind_int(update_dummy_statement, 13,self.taskHowLong);
		sqlite3_bind_int(update_dummy_statement, 14,self.taskProject);
		sqlite3_bind_double(update_dummy_statement, 15,[[self.taskEndTime dateByAddingTimeInterval:gmtSeconds] timeIntervalSince1970]);
		sqlite3_bind_double(update_dummy_statement, 16, [[self.taskDueStartDate dateByAddingTimeInterval:gmtSeconds] timeIntervalSince1970]);//[startDate timeIntervalSince1970]);
		sqlite3_bind_double(update_dummy_statement, 17, [[self.taskDueEndDate dateByAddingTimeInterval:gmtSeconds] timeIntervalSince1970]);//[endDate timeIntervalSince1970]);
		//if(!self.isUsedExternalUpdateTime){
		//	self.taskDateUpdate=[NSDate date];
		//}else {
		//	self.isUsedExternalUpdateTime=NO;
		//}
		
		sqlite3_bind_double(update_dummy_statement, 18, [self.taskDateUpdate timeIntervalSince1970]);
		sqlite3_bind_int(update_dummy_statement,19,self.taskTypeUpdate);
		sqlite3_bind_int(update_dummy_statement,20,self.taskDefault);
		sqlite3_bind_int(update_dummy_statement,21,self.taskRepeatID);
		sqlite3_bind_int(update_dummy_statement, 22,self.taskRepeatTimes);
		sqlite3_bind_text(update_dummy_statement, 23, [self.taskLocation UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(update_dummy_statement, 24, [self.taskContact UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(update_dummy_statement,25,self.taskAlertID);
		sqlite3_bind_int(update_dummy_statement,26,self.taskOriginalWhere);
		sqlite3_bind_double(update_dummy_statement, 27,[[self.taskDeadLine dateByAddingTimeInterval:gmtSeconds] timeIntervalSince1970]);
		sqlite3_bind_double(update_dummy_statement, 28,[[self.taskNotEalierThan dateByAddingTimeInterval:gmtSeconds] timeIntervalSince1970]);
		sqlite3_bind_int(update_dummy_statement,29,self.taskIsUseDeadLine);
		sqlite3_bind_text(update_dummy_statement, 30, [self.gcalEventId UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(update_dummy_statement, 31, [self.taskPhoneToCall UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_double(update_dummy_statement, 32, [[self.taskEndRepeatDate dateByAddingTimeInterval:gmtSeconds] timeIntervalSince1970]);
		sqlite3_bind_text(update_dummy_statement, 33, [self.taskRepeatOptions UTF8String], -1, SQLITE_TRANSIENT);
		
		sqlite3_bind_int(update_dummy_statement, 34, self.parentRepeatInstance);
		sqlite3_bind_text(update_dummy_statement, 35, [self.taskRepeatExceptions UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(update_dummy_statement, 36, [self.taskAlertValues UTF8String], -1, SQLITE_TRANSIENT);
		
		sqlite3_bind_int(update_dummy_statement,37,self.isAllDayEvent);
		sqlite3_bind_int(update_dummy_statement, 38, self.primaryKey);
		
		
		// sqlite3_bind_int(update_dummy_statement, 3, self.primaryKey);
        // Execute the query.
        int success = sqlite3_step(update_dummy_statement);
        // Reset the query for the next use.
        sqlite3_reset(update_dummy_statement);
		//		sqlite3_finalize(update_dummy_statement);	
		//		update_dummy_statement=nil;
        // Handle errors.
        if (success != SQLITE_DONE) {
            NSAssert1(0, @"Error: failed to update with message '%s'.", sqlite3_errmsg(database));
        }
        // Update the object state with respect to unwritten changes.
        self.dirty = NO;
		
    }
	[data release];
	data = nil;
    updated = NO; 
}

#pragma mark common methods
- (BOOL)isEqualToTask:(Task *)task{
	if( task.primaryKey==self.primaryKey &&
	   [task.taskName isEqualToString:self.taskName] &&
	   [task.taskDescription isEqualToString:self.taskDescription] &&
	   [task.taskStartTime isEqualToDate: self.taskStartTime] &&
	   [task.taskEndTime isEqualToDate:self.taskEndTime] &&
	   [task.taskDueStartDate isEqualToDate:self.taskDueStartDate] &&
	   [task.taskDueEndDate isEqualToDate:self.taskDueEndDate] &&
	   task.taskPinned==self.taskPinned &&
	   [task.taskREStartTime isEqualToDate: self.taskREStartTime] &&
	   task.taskStatus==self.taskStatus &&
	   task.taskCompleted==self.taskCompleted &&
	   task.taskSynKey==self.taskSynKey &&
	   task.taskWhat==self.taskWhat &&
	   task.taskWho==self.taskWho &&
	   task.taskWhere==self.taskWhere &&
	   task.taskNumberInstances==self.taskNumberInstances &&
	   task.taskHowLong==self.taskHowLong &&
	   task.taskProject==self.taskProject &&
	   task.parentRepeatInstance==self.parentRepeatInstance &&
	   task.taskTypeUpdate==self.taskTypeUpdate &&
	   [task.taskDateUpdate isEqualToDate:self.taskDateUpdate] &&
	   task.taskDefault==self.taskDefault &&
	   task.taskRepeatID==self.taskRepeatID &&
	   task.taskRepeatTimes==self.taskRepeatTimes &&
	   [task.taskLocation isEqualToString: self.taskLocation] &&
	   [task.taskContact isEqualToString: self.taskContact] &&
	   task.taskAlertID==self.taskAlertID &&
	   task.taskOriginalWhere==self.taskOriginalWhere &&
	   [task.taskDeadLine isEqualToDate:self.taskDeadLine] &&
	   [task.taskNotEalierThan isEqualToDate:self.taskNotEalierThan] &&
	   task.taskIsUseDeadLine==self.taskIsUseDeadLine &&
	   [task.taskEmailToSend isEqualToString: self.taskEmailToSend] &&
	   [task.taskPhoneToCall isEqualToString: self.taskPhoneToCall] &&
	   [task.taskEndRepeatDate isEqualToDate:self.taskEndRepeatDate] &&
	   [task.taskRepeatOptions isEqualToString: self.taskRepeatOptions] &&
	   task.isOneMoreInstance==self.isOneMoreInstance &&
	   [task.taskRepeatExceptions isEqualToString: self.taskRepeatExceptions] &&
		[task.taskAlertValues isEqualToString:self.taskAlertValues]&&
		task.isAllDayEvent==self.isAllDayEvent&&
		task.taskKey==self.taskKey&&
		task.PNSKey==self.PNSKey&&
		task.alertByDeadline==self.alertByDeadline)
        
		return YES;
	return NO;
}

- (BOOL)isEqualToDummy:(Task *)task{
	if(task.primaryKey<-1 &&
	   [task.taskStartTime isEqualToDate: self.taskStartTime] &&
	   [task.taskEndTime isEqualToDate:self.taskEndTime] &&
	   task.parentRepeatInstance==self.parentRepeatInstance)
		return YES;
	return NO;
}

-(Alert *)getAlertInfo{
    if (self.alertIndex<0 || self.alertIndex>15) {
        return nil;
    }
    
    Alert *ret=[[Alert alloc] init];
    
    ret.amount=[[alertList objectAtIndex:self.alertIndex] intValue];
    ret.timeUnit=self.alertUnit;
    
    switch (self.alertUnit) {
        case 0:
            ret.timeUnitString=NSLocalizedString(@"minutesText", @"");//@"minutes";
            break;
        case 1:
            ret.timeUnitString=NSLocalizedString(@"hoursText", @"");//@"hours";
            break;
        case 2:
            ret.timeUnitString=NSLocalizedString(@"daysText", @"");//@"days";
            break;
        case 3:
            ret.timeUnitString=NSLocalizedString(@"weeksText", @"");//@"weeks";
            break;
    } 
    
    return ret;
}

-(NSMutableArray *)creatAlertList{
	NSMutableArray *ret=[[NSMutableArray alloc] init];
	//NSArray *alertListArr=[self.taskAlertValues componentsSeparatedByString:@"/"];
	//if(self.hasAlert){
		//for (NSInteger i=1;i<alertListArr.count;i++){
		//	Alert *tmp=[ivoUtility creatAlertFromList:alertListArr atIndex:i];
		//	[ret addObject:tmp];
		//	[tmp release];
		//}
	//}
	
    if (self.hasAlert) {
        if (self.alertIndex>=0 && self.alertIndex<16) {
            [ret addObject:[self getAlertInfo]];
        }
    }
    
	return ret;
}

-(void)updateAlertList:(NSMutableArray *)list{
    /*
	if(self.taskPinned==1 && list !=nil && list.count>0){
		// For some reasons as Syncing to GCal that has no APNS alerts, we will need to keep any APNS alerts before updating
		NSString *alertStr=@"";
		if([self.taskAlertValues length]>0){
			alertStr= [ivoUtility getAPNSAlertFromTask:self];
		}
		
		for(NSInteger i=0;i<list.count;i++){
			Alert *tmp=(Alert *)[list objectAtIndex:i];
			NSString *alertStrtmp=[NSString stringWithFormat:@"%d|%d|%d",tmp.amount,tmp.alertBy,tmp.timeUnit];
			alertStr=[alertStr stringByAppendingString:[NSString stringWithFormat:@"/%@",alertStrtmp]];
		}
		
		self.taskAlertValues=alertStr;
	}
     */
    
}

-(NSDate *)getOriginalDateOfExceptionInstance{
	NSDate *ret=[NSDate dateWithTimeIntervalSince1970:[self.taskRepeatExceptions doubleValue]];
	if(ret==nil || [ivoUtility getYear:ret]==1970)
		return self.taskStartTime;
	return ret;
}

//Trung ST3.4
-(void) refreshDateUpdate
{
	NSDate *now = [NSDate date];
	
//	if ([ivoUtility compareDate:now withDate:self.taskDateUpdate] == NSOrderedAscending)
//	{
//		self.taskDateUpdate = [self.taskDateUpdate dateByAddingTimeInterval:1];
//	}
//	else
//	{
		self.taskDateUpdate = now;
//	}
	
//	printf("refresh Task (%s) with date update (%s)\n", [self.taskName UTF8String], [[self.taskDateUpdate description] UTF8String]);
}

#pragma mark Properties
// Accessors implemented below. All the "get" accessors simply return the value directly, with no additional
// logic or steps for synchronization. The "set" accessors attempt to verify that the new value is definitely
// different from the old value, to minimize the amount of work done. Any "set" which actually results in changing
// data will mark the object as "dirty" - i.e., possessing data that has not been written to the database.
// All the "set" accessors copy data, rather than retain it. This is common for value objects - strings, numbers, 
// dates, data buffers, etc. This ensures that subsequent changes to either the original or the copy don't violate 
// the encapsulation of the owning object.

//primarykey property
- (NSInteger)primaryKey {
    return primaryKey;
}

-(void)setPrimaryKey:(NSInteger)num{
	if (primaryKey==num) return;
	self.dirty=YES;
	primaryKey=num;
}

//taskID property
-(NSInteger)taskID{
	return taskID;	
}

-(void)setTaskID:(NSInteger)TID{
	if(taskID==TID) return;
	self.dirty=YES;
	taskID=TID;
}

//alertByDeadline
-(NSInteger)alertByDeadline{
	return alertByDeadline;	
}

-(void)setAlertByDeadline:(NSInteger)anum{
	if(alertByDeadline==anum) return;
	self.dirty=YES;
	alertByDeadline=anum;
}

//taskName property
- (NSString *)taskName {
    return taskName;
}

- (void)setTaskName:(NSString *)aString {
    if ((!taskName && !aString) || (taskName && aString && [taskName isEqualToString:aString])) return;
    self.dirty = YES;
    [taskName release];
    taskName = [aString copy];
}

//taskDescription property
- (NSString *)taskDescription {
    return taskDescription;
}

- (void)setTaskDescription:(NSString *)aString {
    if ((!taskDescription && !aString) || (taskDescription && aString && [taskDescription isEqualToString:aString])) return;
    self.dirty = YES;
    [taskDescription release];
    taskDescription = [aString copy];
}

//taskStartTime property
- (NSDate *)taskStartTime{
	return taskStartTime;
}

- (void)setTaskStartTime:(NSDate *)aDate{
	if ([taskStartTime isEqualToDate:aDate]) return;
	self.dirty=YES;
	
	[taskStartTime release];
	
	//taskStartTime=[aDate copy];
	NSInteger dateSecond=[ivoUtility getSecond:aDate];
	taskStartTime=[[aDate dateByAddingTimeInterval:-dateSecond] copy];	

	if(!taskREStartTime || [ivoUtility getYear:taskStartTime]==1970){
        [taskREStartTime release];
		taskREStartTime=[taskStartTime copy];
	}
}

//taskEndTime property
- (NSDate *)taskEndTime{
	//if(isDayLigtSavingTime && [App_defaultTimeZone isDaylightSavingTimeForDate:taskEndTime])
	//return [taskEndTime addTimeInterval:[App_defaultTimeZone daylightSavingTimeOffsetForDate:taskEndTime]];

	return taskEndTime;
	
}

- (void)setTaskEndTime:(NSDate *)aDate{
	if ([taskEndTime isEqualToDate:aDate]) return;
	self.dirty=YES;
	
	[taskEndTime release];
	//taskEndTime=[aDate copy];
	NSInteger dateSecond=[ivoUtility getSecond:aDate];
	taskEndTime=[[aDate dateByAddingTimeInterval:-dateSecond] copy];
}

//taskDueStartDate property
- (NSDate *)taskDueStartDate{
	return taskDueStartDate;
}

- (void)setTaskDueStartDate:(NSDate *)aDate{
	if ([taskDueStartDate isEqualToDate:aDate]) return;
	self.dirty=YES;

	[taskDueStartDate release];
	taskDueStartDate=[aDate copy];
}

//taskDueEndDate property
- (NSDate *)taskDueEndDate{
	return taskDueEndDate;
}

- (void)setTaskDueEndDate:(NSDate *)aDate{
	if ([taskDueEndDate isEqualToDate:aDate]) return;
	self.dirty=YES;

	[taskDueEndDate release];
	taskDueEndDate=[aDate copy];

 }

//taskPinned property
-(NSInteger)taskPinned{
	return taskPinned;
}

-(void)setTaskPinned: (NSInteger)pinned {
	if (taskPinned==pinned) return;
	self.dirty=YES;
	taskPinned=pinned;
	
	if(taskPinned==0)
		taskRepeatID=0;
}

//taskPriority property
-(NSDate *)taskREStartTime{
	return taskREStartTime;	
}

- (void)setTaskREStartTime:(NSDate *)aDate{
	if([taskREStartTime isEqualToDate:aDate]) return;
	self.dirty=YES;
	[taskREStartTime release];
	NSInteger dateSecond=[ivoUtility getSecond:aDate];
	taskREStartTime=[[aDate dateByAddingTimeInterval:-dateSecond] copy];
	self.filledDummiesToDate=taskREStartTime;
}

//taskStatus property
-(NSInteger)taskStatus{
	return taskStatus;	
}

- (void)setTaskStatus:(NSInteger)status{
	if (taskStatus==status) return;
	self.dirty=YES;
	taskStatus=status;
}

//taskCompeted property
- (NSInteger)taskCompleted{
	return taskCompleted;	
}

- (void)setTaskCompleted:(NSInteger)completed{
	if (taskCompleted==completed) return;
	self.dirty=YES;
	taskCompleted=completed;
}

//taskSynKey property
- (double)taskSynKey{
	return taskSynKey;	
}

- (void)setTaskSynKey:(double)typeID{
	if(taskSynKey==typeID) return;
	self.dirty=YES;
	taskSynKey=typeID;
}

//taskWhat property
- (NSInteger)taskWhat{
	return taskWhat;	
}

- (void)setTaskWhat:(NSInteger)IconID{
	if(taskWhat==IconID) return;
	self.dirty=YES;
	taskWhat=IconID;
}

//taskWho property
-(NSInteger)taskWho{
	return taskWho;	
}

-(void)setTaskWho:(NSInteger)IconID{
	if(taskWho==IconID) return;
	self.dirty=YES;
	taskWho=IconID;
}

//taskWhere property
-(NSInteger)taskWhere{
	return taskWhere;	
}

-(void)setTaskWhere:(NSInteger)IconID{
	if(taskWhere==IconID) return;
	self.dirty=YES;
	taskWhere=IconID;
}

//taskNumberInstances property
-(NSInteger)taskNumberInstances{
	return taskNumberInstances;	
}

-(void)setTaskNumberInstances:(NSInteger)IconID{
	if(taskNumberInstances==IconID) return;
	self.dirty=YES;
	taskNumberInstances=IconID;
}

//taskHowLong property
-(NSInteger)taskHowLong{
	return taskHowLong;	
}

-(void)setTaskHowLong:(NSInteger)IconID{
	NSInteger dur=IconID;
	if(dur<60) dur=60;
	if(taskHowLong==dur) return;
	self.dirty=YES;
	taskHowLong=dur;	
}

//taskProject property
-(NSInteger)taskProject{
	return taskProject;	
}

-(void)setTaskProject:(NSInteger)IconID{
	if(taskProject==IconID) return;
	self.dirty=YES;
	taskProject=IconID;
}

//parentRepeatInstance property
-(NSInteger)parentRepeatInstance{
	return parentRepeatInstance;	
}

-(void)setParentRepeatInstance:(NSInteger)IconID{
	if(parentRepeatInstance==IconID) return;
	self.dirty=YES;
	parentRepeatInstance=IconID;
}

//taskDateUpdate property
- (NSDate *)taskDateUpdate{
	return taskDateUpdate;
}

- (void)setTaskDateUpdate:(NSDate *)aDate{
	if ([taskDateUpdate isEqualToDate:aDate]) return;
	self.dirty=YES;
	
	[taskDateUpdate release];
	
//	if ([aDate compare:[NSDate date]]==NSOrderedAscending && self.taskCompleted==0){
//		taskDateUpdate = [[NSDate date] copy];
//	}else {
		taskDateUpdate=[aDate copy];
//	}
}

//taskTypeUpdate property
-(NSInteger)taskTypeUpdate{
	return taskTypeUpdate;	
}

-(void)setTaskTypeUpdate:(NSInteger)TypeID{
	if(taskTypeUpdate==TypeID) return;
	self.dirty=YES;
	taskTypeUpdate=TypeID;
}

//taskTypeUpdate property
-(NSInteger)taskDefault{
	return taskDefault;	
}

-(void)setTaskDefault:(NSInteger)dfltID{
	if(taskDefault==dfltID) return;
	self.dirty=YES;
	taskDefault=dfltID;
}

-(NSInteger)taskRepeatID{
	return taskRepeatID;	
}

-(void)setTaskRepeatID:(NSInteger)num{
	if(taskRepeatID==num) return;
	self.dirty=YES;
	taskRepeatID=num;
}

//taskRepeatTimes property
- (NSInteger)taskRepeatTimes{
	return taskRepeatTimes;
}

- (void)setTaskRepeatTimes:(NSInteger)aNum{
	if (taskRepeatTimes == aNum) return;
	self.dirty=YES;
	taskRepeatTimes=aNum;
}

//taskLocation property
- (NSString *)taskLocation {
    return taskLocation;
}

- (void)setTaskLocation:(NSString *)aString {
    if ((!taskLocation && !aString) || (taskLocation && aString && [taskLocation isEqualToString:aString])) return;
    self.dirty = YES;
    [taskLocation release];
    taskLocation = [[aString stringByReplacingOccurrencesOfString:@"\n" withString:@", "] copy];
}

//taskContact property
- (NSString *)taskContact {
    return taskContact;
}

- (void)setTaskContact:(NSString *)aString {
    if ((!taskContact && !aString) || (taskContact && aString && [taskContact isEqualToString:aString])) return;
    self.dirty = YES;
    [taskContact release];
    taskContact = [aString copy];
}

//taskEmailToSend property
- (NSString *)taskEmailToSend {
    return taskEmailToSend;
}

- (void)setTaskEmailToSend:(NSString *)aString {
    if ((!taskEmailToSend && !aString) || (taskEmailToSend && aString && [taskEmailToSend isEqualToString:aString])) return;
    self.dirty = YES;
    [taskEmailToSend release];
    taskEmailToSend = [aString copy];
}

//gcalEventId
- (NSString *)gcalEventId {
    return gcalEventId;
}

- (void)setGcalEventId:(NSString *)aString {
    if ((!gcalEventId && !aString) || (gcalEventId && aString && [gcalEventId isEqualToString:aString])) return;
    self.dirty = YES;
    [gcalEventId release];
    gcalEventId = [aString copy];
}

//taskEmailToSend property
- (NSString *)taskPhoneToCall {
    return taskPhoneToCall;
}

- (void)setTaskPhoneToCall:(NSString *)aString {
    if ((!taskPhoneToCall && !aString) || (taskPhoneToCall && aString && [taskPhoneToCall isEqualToString:aString])) return;
    self.dirty = YES;
    [taskPhoneToCall release];
    taskPhoneToCall = [aString copy];
}

//taskRepeatOptions
- (NSString *)taskRepeatOptions {
    return taskRepeatOptions;
}

- (void)setTaskRepeatOptions:(NSString *)aString {
    if ((!taskRepeatOptions && !aString) || (taskRepeatOptions && aString && [taskRepeatOptions isEqualToString:aString])) return;
    self.dirty = YES;
    [taskRepeatOptions release];
    taskRepeatOptions = [aString copy];
}

//taskRepeatExceptions
- (NSString *)taskRepeatExceptions {
    return taskRepeatExceptions;
}

- (void)setTaskRepeatExceptions:(NSString *)aString {
    if ((!taskRepeatExceptions && !aString) || (taskRepeatExceptions && aString && [taskRepeatExceptions isEqualToString:aString])) return;
    self.dirty = YES;
    [taskRepeatExceptions release];
    taskRepeatExceptions = [aString copy];
}

//taskAlertValues
- (NSString *)taskAlertValues {
    return taskAlertValues;
}

- (void)setTaskAlertValues:(NSString *)aString {
    if ((!taskAlertValues && !aString) || (taskAlertValues && aString && [taskAlertValues isEqualToString:aString])) return;
    self.dirty = YES;
    [taskAlertValues release];
    taskAlertValues = [aString copy];
}

-(NSInteger)taskAlertID{
	return taskAlertID;	
}

-(void)setTaskAlertID:(NSInteger)num{
	if(taskAlertID==num) return;
	self.dirty=YES;
	taskAlertID=num;
}

- (BOOL)dirty{
	return dirty;	
}

- (void)setDirty:(BOOL)bl{
	dirty=bl;	
}

//isOneMoreInstance
- (BOOL)isOneMoreInstance{
	return isOneMoreInstance;	
}

- (void)setIsOneMoreInstance:(BOOL)bl{
	isOneMoreInstance=bl;	
}

-(NSInteger)taskOriginalWhere{
	return taskOriginalWhere;	
}

-(void)setTaskOriginalWhere:(NSInteger)num{
	if(taskOriginalWhere==num) return;
	self.dirty=YES;
	taskOriginalWhere=num;
}

//taskDeadline property
- (NSDate *)taskDeadLine{
	return taskDeadLine;
}

- (void)setTaskDeadLine:(NSDate *)aDate{
	if ([taskDeadLine isEqualToDate:aDate]) return;
	self.dirty=YES;
	
	[taskDeadLine release];
	taskDeadLine=[aDate copy];
}

//taskNotEalierThan property
- (NSDate *)taskNotEalierThan{
	return taskNotEalierThan;
}

- (void)setTaskNotEalierThan:(NSDate *)aDate{
	if ([taskNotEalierThan isEqualToDate:aDate]) return;
	self.dirty=YES;
	
	[taskNotEalierThan release];
	NSInteger dateSecond=[ivoUtility getSecond:aDate];
	taskNotEalierThan=[[aDate dateByAddingTimeInterval:-dateSecond] copy];
}

//taskEndRepeatDate
- (NSDate *)taskEndRepeatDate{
	return taskEndRepeatDate;
}

- (void)setTaskEndRepeatDate:(NSDate *)aDate{
	if ([taskEndRepeatDate isEqualToDate:aDate]) return;
	self.dirty=YES;
	
	[taskEndRepeatDate release];
	NSInteger dateSecond=[ivoUtility getSecond:aDate];
	taskEndRepeatDate=[[aDate dateByAddingTimeInterval:-dateSecond] copy];
}

//specifiedAlertTime
- (NSDate *)specifiedAlertTime{
	return specifiedAlertTime;
}

- (void)setSpecifiedAlertTime:(NSDate *)aDate{
	if ([specifiedAlertTime isEqualToDate:aDate]) return;
	self.dirty=YES;
	
	[specifiedAlertTime release];
	NSInteger dateSecond=[ivoUtility getSecond:aDate];
	specifiedAlertTime=[[aDate dateByAddingTimeInterval:-dateSecond] copy];
}

//IsUseDedLine properties
-(NSInteger)taskIsUseDeadLine{
	return taskIsUseDeadLine;	
}

-(void)setTaskIsUseDeadLine:(NSInteger)num{
	if(taskIsUseDeadLine==num) return;
	self.dirty=YES;
	taskIsUseDeadLine=num;
}

//originalPKey
//IsUseDedLine properties
-(NSInteger)originalPKey{
	return originalPKey;	
}

-(void)setOriginalPKey:(NSInteger)num{
	if(originalPKey==num) return;
	originalPKey=num;
}

-(NSInteger)isAllDayEvent{
	return isAllDayEvent;	
}

-(void)setIsAllDayEvent:(NSInteger)num{
	if(isAllDayEvent==num) return;
	isAllDayEvent=num;

	/*
	if(num==1 && self.taskPinned==1){
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;//|NSWeekdayCalendarUnit|NSWeekdayOrdinalCalendarUnit;
		NSDateComponents *comps = [gregorian components:unitFlags fromDate:self.taskStartTime];
		
		[comps setHour:0];
		[comps setMinute:0];
		[comps setSecond:0];
		
		self.taskStartTime=[gregorian dateFromComponents:comps];
		
		if(self.taskHowLong < 86400){
			self.taskHowLong=86400;
		}
		
		self.taskEndTime=[self.taskStartTime addTimeInterval:self.taskHowLong];
		
		comps = [gregorian components:unitFlags fromDate:self.taskEndTime];
		
		if((self.taskHowLong/86400)*86400!=self.taskHowLong){
			[comps setHour:23];
			[comps setMinute:60];
			[comps setSecond:0];
		}else {
			[comps setHour:0];
			[comps setMinute:0];
			[comps setSecond:0];
		}
		
		self.taskEndTime=[gregorian dateFromComponents:comps];
		[gregorian release];
		
		self.taskHowLong=[self.taskEndTime timeIntervalSinceDate:self.taskStartTime];
	}
	 */
}

-(BOOL)isUsedExternalUpdateTime{
	return isUsedExternalUpdateTime;	
}

-(void)setIsUsedExternalUpdateTime:(BOOL)bl{
	isUsedExternalUpdateTime=bl;
}

/*
- (NSDate *)filledDummiesToDate{
	return filledDummiesToDate;
}

- (void)setFilledDummiesToDate:(NSDate *)aDate{
	if ([filledDummiesToDate isEqualToDate:aDate]) return;
	self.dirty=YES;
	
	[filledDummiesToDate release];
	filledDummiesToDate=[filledDummiesToDate copy];
	
}
*/
-(NSInteger)taskOrder{
	return taskOrder;	
}

-(void)setTaskOrder:(NSInteger)num{
	if(taskOrder==num) return;
	self.dirty=YES;
	taskOrder=num;
}

-(BOOL)isNeedAdjustDST{
	return isNeedAdjustDST;
}

-(void)setIsNeedAdjustDST:(BOOL)bl{
	isNeedAdjustDST=bl;
}

//taskAlertValues
- (NSString *)PNSKey {
    return PNSKey;
}

- (void)setPNSKey:(NSString *)aString {
    if ((!PNSKey && !aString) || (PNSKey && aString && [PNSKey isEqualToString:aString])) return;
    self.dirty = YES;
    [PNSKey release];
    PNSKey = [aString copy];
}

-(NSInteger)isAdjustedSpecifiedDate{
	return isAdjustedSpecifiedDate;
}

-(void)setIsAdjustedSpecifiedDate:(NSInteger)anum{
	if(isAdjustedSpecifiedDate==anum) return;
	self.dirty=YES;
	isAdjustedSpecifiedDate=anum;
}

//
-(NSInteger)toodledoID{
	return toodledoID;
}

-(void)setToodledoID:(NSInteger)anum{
	if(toodledoID==anum) return;
	self.dirty=YES;
	toodledoID=anum;
}

//toodledoHasStart
-(NSInteger)toodledoHasStart{
	return toodledoHasStart;
}

-(void)setToodledoHasStart:(NSInteger)anum{
	if(toodledoHasStart==anum) return;
	self.dirty=YES;
	toodledoHasStart=anum;
}

//isHidden
-(NSInteger)isHidden{
	return isHidden;
}

-(void)setIsHidden:(NSInteger)anum{
	if(isHidden==anum) return;
	self.dirty=YES;
	isHidden=anum;
}

//iCalIdentifier
- (NSString *)iCalIdentifier {
    return iCalIdentifier;
}

- (void)setICalIdentifier:(NSString *)aString {
    if ((!iCalIdentifier && !aString) || (iCalIdentifier && aString && [iCalIdentifier isEqualToString:aString])) return;
    self.dirty = YES;
    [iCalIdentifier release];
    iCalIdentifier = [aString copy];
}

- (NSString *)iCalCalendarName {
    return iCalCalendarName;
}

- (void)setICalCalendarName:(NSString *)aString {
    if ((!iCalCalendarName && !aString) || (iCalCalendarName && aString && [iCalCalendarName isEqualToString:aString])) return;
    self.dirty = YES;
    [iCalCalendarName release];
    iCalCalendarName = [aString copy];
}

//alertIndex
-(NSInteger)alertIndex{
	return alertIndex;
}

-(void)setAlertIndex:(NSInteger)anum{
	if(alertIndex==anum) return;
	self.dirty=YES;
    if (anum<0) {
        alertIndex=0;
    }else if(anum>15){
        alertIndex=15;
    }else{
        alertIndex=anum;
    }
}

//alertUnit
-(NSInteger)alertUnit{
	return alertUnit;
}

-(void)setAlertUnit:(NSInteger)anum{
	if(alertUnit==anum) return;
	self.dirty=YES;
	alertUnit=anum;
}

//alertBasedOn
-(NSInteger)alertBasedOn{
	return alertBasedOn;
}

-(void)setAlertBasedOn:(NSInteger)anum{
	if(alertBasedOn==anum) return;
	self.dirty=YES;
	alertBasedOn=anum;
}

//hasAlert
-(NSInteger)hasAlert{
	return hasAlert;
}

-(void)setHasAlert:(NSInteger)anum{
	if(hasAlert==anum) return;
	self.dirty=YES;
	hasAlert=anum;
}

//taskRepeatStyle
-(NSInteger)taskRepeatStyle{
	return taskRepeatStyle;
}

-(void)setTaskRepeatStyle:(NSInteger)anum{
	if(taskRepeatStyle==anum) return;
	self.dirty=YES;
	taskRepeatStyle=anum;
}

//reminderIdentifier
- (NSString *)reminderIdentifier {
    return reminderIdentifier;
}

- (void)setReminderIdentifier:(NSString *)aString {
    if ((!reminderIdentifier && !aString) || (reminderIdentifier && aString && [reminderIdentifier isEqualToString:aString])) return;
    self.dirty = YES;
    [reminderIdentifier release];
    reminderIdentifier = [aString copy];
}

@end
