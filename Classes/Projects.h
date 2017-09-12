//
//  Projects.h
//  iVo
//
//  Created by Nang Le on 7/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
//#import "/usr/include/sqlite3.h"
#import <sqlite3.h>
@interface Projects : NSObject {
   // Primary key in the database.
    NSInteger	primaryKey;
    // Attributes.
	NSInteger	projID;
	NSString	*projName;
	
	NSString	*mapToGCalNameForEvent;//map to Proj_Resvr1 in dB
	NSString	*mapToGCalNameForTask;//map to Proj_Resvr2 in dB
	
	//EKSync
	NSInteger	colorId;//map to Proj_Resvr3 in dB
	NSInteger	groupId;//the group of color id
	NSInteger	projectOrder;
	
	NSString	*suggestedEventMappingName;
	NSString	*iCalCalendarName;
	NSString    *iCalIdentifier;
    
	NSInteger		toodledoFolderKey;
	NSInteger		builtIn;//0:SO; 1:GCal; 2TD;
	NSInteger		enableTDSync;
	NSInteger		enableICalSync;
	
	NSInteger	inVisible;
	
	//local uses
	BOOL		isInFiltering;
	
	// Internal state variables. Hydrated tracks whether attribute data is in the object or the database.
    BOOL		updated;
    // Dirty tracks whether there are in-memory changes to data which have no been written to the database.
    BOOL		dirty;
    NSData		*data;
    
    NSString *reminderIdentifier;
}

@property (assign, nonatomic)	NSInteger	primaryKey;
@property (assign, nonatomic)	NSInteger	projID;
@property (copy, nonatomic)		NSString	*projName;
@property (assign, nonatomic)	 BOOL		dirty;
@property (copy, nonatomic)		NSString	*mapToGCalNameForEvent;//map to Proj_Resvr1 in dB
@property (copy, nonatomic)		NSString	*mapToGCalNameForTask;//map to Proj_Resvr2 in dB

@property (assign, nonatomic)	NSInteger	colorId;
@property (copy, nonatomic)		NSString	*suggestedEventMappingName;

@property (assign, nonatomic)	NSInteger		toodledoFolderKey;
@property (assign, nonatomic)	NSInteger		builtIn;//0:SO; 1:GCal; 2TD;
@property (assign, nonatomic)	NSInteger		enableTDSync;
@property (assign, nonatomic)	NSInteger		enableICalSync;
@property (assign, nonatomic)	NSInteger		groupId;
@property (assign, nonatomic)	NSInteger	projectOrder;
@property (assign, nonatomic)	NSInteger	inVisible;
@property (copy, nonatomic)		NSString	*iCalCalendarName;
@property (assign, nonatomic)	BOOL		isInFiltering;
@property (copy, nonatomic)		NSString    *iCalIdentifier;
@property (copy, nonatomic)		NSString *reminderIdentifier;


- (NSInteger)prepareNewRecordIntoDatabase:(sqlite3 *)database;
// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements;

// Creates the object with primary key and title is brought into memory.
- (id)getInfoWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;
// Flushes all but the primary key and title out to the database.
- (void)update;
// Remove the book complete from the database. In memory deletion to follow...
- (void)deleteFromDatabase;

@end
