//
//  Projects.m
//  iVo
//
//  Created by Nang Le on 7/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Projects.h"
#import "SmartTimeAppDelegate.h"

static sqlite3_stmt *insert_project_statement = nil;
static sqlite3_stmt *init_project_statement = nil;
static sqlite3_stmt *delete_project_statement = nil;
static sqlite3_stmt *update_project_statement = nil;

extern sqlite3 *database;
extern BOOL isLockingDB;

@implementation Projects

//EKSync
@synthesize suggestedEventMappingName;
@synthesize isInFiltering;

//@synthesize colorId;

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
    
    if (insert_project_statement == nil) {
        static char *sql = "INSERT INTO iVo_Projects (Proj_Name) VALUES('')";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_project_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
    int success = sqlite3_step(insert_project_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_project_statement);
	
//	sqlite3_finalize(insert_project_statement);	
//	insert_project_statement=nil;

    if (success != SQLITE_ERROR) {
        // SQLite provides a method which retrieves the value of the most recently auto-generated primary key sequence
        // in the database. To access this functionality, the table should have a column declared of type 
        // "INTEGER PRIMARY KEY"
		primaryKey=sqlite3_last_insert_rowid(database);
        isLockingDB=NO;
        
        return sqlite3_last_insert_rowid(database);
    }
    NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
    isLockingDB=NO;
    
    return -1;
}

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements {
    if (insert_project_statement) sqlite3_finalize(insert_project_statement);
    if (init_project_statement) sqlite3_finalize(init_project_statement);
    if (delete_project_statement) sqlite3_finalize(delete_project_statement);
    //if (hydrate_statement) sqlite3_finalize(hydrate_statement);
    if (update_project_statement) sqlite3_finalize(update_project_statement);
}

-(id)init{
	self=[super init];
	if (self) {
		self.colorId=0;
		self.groupId=0;
        self.reminderIdentifier=@"";
	}
	
	return self;
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
        if (init_project_statement == nil) {
            // Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
            // This is a great way to optimize because frequently used queries can be compiled once, then with each
            // use new variable values can be bound to placeholders.
            const char *sql = "SELECT Proj_ID,\
			Proj_Name,\
			Proj_Resvr1,\
			Proj_Resvr2,\
			Proj_Resvr3,\
			toodledoFolderKey,\
			builtIn,\
			enableTDSync,\
			enableICalSync,\
			groupId,\
			projectOrder,\
			inVisible,\
			iCalCalendarName,\
            iCalIdentifier,\
            reminderIdentifier \
            FROM iVo_Projects WHERE Proj_ID=?";
            if (sqlite3_prepare_v2(database, sql, -1, &init_project_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // For this query, we bind the primary key to the first (and only) placeholder in the statement.
        // Note that the parameters are numbered from 1, not from 0.
        sqlite3_bind_int(init_project_statement, 1, self.primaryKey);
        if (sqlite3_step(init_project_statement) == SQLITE_ROW) {
			self.projID=sqlite3_column_int(init_project_statement, 0);
			
            char *projectName=(char *)sqlite3_column_text(init_project_statement, 1);
			self.projName = (projectName)? [NSString stringWithUTF8String:projectName] : @"";
			
            char *project2GCalName=(char *)sqlite3_column_text(init_project_statement, 2);
			self.mapToGCalNameForEvent = (project2GCalName)? [NSString stringWithUTF8String:project2GCalName] : @"";

			char *project2GCalName4Task=(char *)sqlite3_column_text(init_project_statement, 3);
			self.mapToGCalNameForTask = (project2GCalName4Task)? [NSString stringWithUTF8String:project2GCalName4Task] : @"";
			
			self.colorId=sqlite3_column_int(init_project_statement, 4);
			self.toodledoFolderKey=sqlite3_column_int(init_project_statement, 5);
			self.builtIn=sqlite3_column_int(init_project_statement,6);
			self.enableTDSync=sqlite3_column_int(init_project_statement,7);
			self.enableICalSync=sqlite3_column_int(init_project_statement,8);
			self.groupId=sqlite3_column_int(init_project_statement,9);
			//projectOrder
			self.projectOrder=sqlite3_column_int(init_project_statement,10);
			self.inVisible=sqlite3_column_int(init_project_statement,11);

			char *icalcalname=(char *)sqlite3_column_text(init_project_statement, 12);
			self.iCalCalendarName = (icalcalname)? [NSString stringWithUTF8String:icalcalname] : @"";

			
            //iCalIdentifier
			char *icalcalId=(char *)sqlite3_column_text(init_project_statement, 13);
			self.iCalIdentifier = (icalcalId)? [NSString stringWithUTF8String:icalcalId] : @"";
            //reminderIdentifier
			char *rmdrID=(char *)sqlite3_column_text(init_project_statement, 14);
			self.reminderIdentifier = (rmdrID)? [NSString stringWithUTF8String:rmdrID] : @"";
            
		} else {
			self.projID=0;
            self.projName = @"";
			self.mapToGCalNameForEvent =@"";
			self.mapToGCalNameForTask =@"";
			self.colorId = 0;
        }
		
        // Reset the statement for future reuse.
        sqlite3_reset(init_project_statement);
//		sqlite3_finalize(init_project_statement);	
//		init_project_statement=nil;
       dirty = NO;
	}
    
    isLockingDB=NO;
    
    return self;
}

- (void)dealloc {
    [projName release];
	projName=nil;
	[mapToGCalNameForEvent release];
	[mapToGCalNameForTask release];
	[iCalCalendarName release];
	[iCalIdentifier release];
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
    
    if (delete_project_statement == nil) {
        const char *sql = "DELETE FROM iVo_Projects WHERE Proj_ID=?";
        if (sqlite3_prepare_v2(database, sql, -1, &delete_project_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    // Bind the primary key variable.
    sqlite3_bind_int(delete_project_statement, 1, self.primaryKey);
    // Execute the query.
    int success = sqlite3_step(delete_project_statement);
    // Reset the statement for future use.
    sqlite3_reset(delete_project_statement);
//	sqlite3_finalize(delete_project_statement);	
//	delete_project_statement=nil;

    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }
    
    isLockingDB=NO;
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
        if (update_project_statement == nil) {
            const char *sql = "UPDATE iVo_Projects SET \
			Proj_Name=?,\
			Proj_Resvr1=?,\
			Proj_Resvr2=?,\
			Proj_Resvr3=?,\
			toodledoFolderKey=?,\
			builtIn=?,\
			enableTDSync=?,\
			enableICalSync=?,\
			groupId=?,\
			projectOrder=?,\
			inVisible=?,\
			iCalCalendarName=?,\
            iCalIdentifier=?,\
            reminderIdentifier=? \
			WHERE Proj_ID=?";
            if (sqlite3_prepare_v2(database, sql, -1, &update_project_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // Bind the query variables.
        sqlite3_bind_text(update_project_statement, 1, [self.projName UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(update_project_statement, 2, [self.mapToGCalNameForEvent UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(update_project_statement, 3, [self.mapToGCalNameForTask UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(update_project_statement, 4, self.colorId);
		
		sqlite3_bind_int(update_project_statement, 5, self.toodledoFolderKey);
		sqlite3_bind_int(update_project_statement, 6, self.builtIn);
		sqlite3_bind_int(update_project_statement, 7, self.enableTDSync);
		//enableICalSync
		sqlite3_bind_int(update_project_statement, 8, self.enableICalSync);
		sqlite3_bind_int(update_project_statement, 9, self.groupId);
		//projectOrder
		sqlite3_bind_int(update_project_statement, 10, self.projectOrder);
		//inVisible
		sqlite3_bind_int(update_project_statement, 11, self.inVisible);
		//iCalCalendarName
		sqlite3_bind_text(update_project_statement, 12, [self.iCalCalendarName UTF8String], -1, SQLITE_TRANSIENT);
		//iCalIdentifier
		sqlite3_bind_text(update_project_statement, 13, [self.iCalIdentifier UTF8String], -1, SQLITE_TRANSIENT);
        //reminderIdentifier
        sqlite3_bind_text(update_project_statement, 14, [self.reminderIdentifier UTF8String], -1, SQLITE_TRANSIENT);
        
		sqlite3_bind_int(update_project_statement, 15, self.primaryKey);
		
        // Execute the query.
        int success = sqlite3_step(update_project_statement);
        // Reset the query for the next use.
        sqlite3_reset(update_project_statement);
//		sqlite3_finalize(update_project_statement);	
//		update_project_statement=nil;
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
    self.projID=num;
}

- (NSInteger)projID{
	return projID;	
}

- (void)setProjID:(NSInteger)num{
	projID=num;
}

//Alarm sound name
- (NSString *)projName {
    return projName;
}

- (void)setProjName:(NSString *)aString {
    if ((!projName && !aString) || (projName && aString && [projName isEqualToString:aString])) return;
    self.dirty = YES;
	[projName release];
    projName = [aString copy];
}

- (BOOL)dirty{
	return dirty;	
}

- (void)setDirty:(BOOL)bl{
	dirty=bl;	
}

- (NSString *)mapToGCalNameForEvent {
    return mapToGCalNameForEvent;
}

- (void)setMapToGCalNameForEvent:(NSString *)aString {
    if ((!mapToGCalNameForEvent && !aString) || (mapToGCalNameForEvent && aString && [mapToGCalNameForEvent isEqualToString:aString])) return;
    self.dirty = YES;
	[mapToGCalNameForEvent release];
    mapToGCalNameForEvent = [aString copy];
}

- (NSString *)mapToGCalNameForTask {
    return mapToGCalNameForTask;
}

- (void)setMapToGCalNameForTask:(NSString *)aString {
    if ((!mapToGCalNameForTask && !aString) || (mapToGCalNameForTask && aString && [mapToGCalNameForTask isEqualToString:aString])) return;
    self.dirty = YES;
	[mapToGCalNameForTask release];
    mapToGCalNameForTask = [aString copy];
}

- (id) copyWithZone:(NSZone*) zone{
	Projects *copy = [[Projects alloc] init];
	copy.primaryKey = primaryKey;
	copy.projID = projID;
	copy.projName = projName;
	copy.dirty = dirty;
	copy.mapToGCalNameForEvent = mapToGCalNameForEvent;
	copy.mapToGCalNameForTask = mapToGCalNameForTask;
	copy.colorId = colorId;
	copy.toodledoFolderKey=toodledoFolderKey;
	copy.builtIn=builtIn;
	copy.enableTDSync=enableTDSync;
	copy.groupId=groupId;
	copy.projectOrder=projectOrder;
	copy.iCalCalendarName=iCalCalendarName;
	
	return copy;
}

- (NSInteger)toodledoFolderKey{
	return toodledoFolderKey;	
}

- (void)setToodledoFolderKey:(NSInteger)num{
	if (toodledoFolderKey==num) {
		return;
	}
	
	dirty=YES;
	toodledoFolderKey=num;
}

- (NSInteger)builtIn{
	return builtIn;	
}

- (void)setBuiltIn:(NSInteger)num{
	if (builtIn==num) {
		return;
	}
	
	dirty=YES;
	builtIn=num;
}

- (NSInteger)enableTDSync{
	return enableTDSync;	
}

- (void)setEnableTDSync:(NSInteger)num{
	if (enableTDSync==num) {
		return;
	}
	
	dirty=YES;
	enableTDSync=num;
}

//enableICalSync
- (NSInteger)enableICalSync{
	return enableICalSync;	
}

- (void)setEnableICalSync:(NSInteger)num{
	if (enableICalSync==num) {
		return;
	}
	
	dirty=YES;
	enableICalSync=num;
}

- (NSInteger)colorId{
	return colorId;	
}

- (void)setColorId:(NSInteger)num{
	if (colorId==num) {
		return;
	}
	
	dirty=YES;
	colorId=num;
}

//groupId is the group of color id
- (NSInteger)groupId{
	return groupId;	
}

- (void)setGroupId:(NSInteger)num{
	if (groupId==num) {
		return;
	}
	
	dirty=YES;
	groupId=num;
}

//projectOrder
- (NSInteger)projectOrder{
	return projectOrder;	
}

- (void)setProjectOrder:(NSInteger)num{
	if (projectOrder==num) {
		return;
	}
	
	dirty=YES;
	projectOrder=num;
}

//inVisible
- (NSInteger)inVisible{
	return inVisible;	
}

- (void)setInVisible:(NSInteger)num{
	if (inVisible==num) {
		return;
	}
	
	dirty=YES;
	inVisible=num;
}

//iCalCalendarName
- (NSString *)iCalCalendarName {
    return iCalCalendarName;
}

- (void)setICalCalendarName:(NSString *)aString {
    if ((!iCalCalendarName && !aString) || (iCalCalendarName && aString && [iCalCalendarName isEqualToString:aString])) return;
    self.dirty = YES;
    [iCalCalendarName release];
    iCalCalendarName = [aString copy];
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
