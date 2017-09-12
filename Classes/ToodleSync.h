//
//  ToodleSync.h
//
//  Created by NangLe on 7/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class Task;
@class Projects;
@class RootViewController;
@class TDDeletedTaskObject;

@interface ToodleSync : NSObject <UIAlertViewDelegate,NSXMLParserDelegate> {
  // for downloading the xml data
/*	NSMutableArray *toodledoTaskList;
	NSMutableArray *toodledoDeletedTaskList;
	NSMutableArray  *folderList;
	NSMutableArray  *t2dTaskList;
	
	NSDateFormatter *parseFormatter;
    NSURLConnection *rssConnection;
    NSMutableData *xmlData;
	
    // these variables are used during parsing
    Task *currentTask;
	Projects *currentCalendar;
	
    NSMutableArray *currentParseBatch;
    NSUInteger parsedCount;
    NSMutableString *currentString;
    BOOL accumulatingParsedCharacterData;
    BOOL didAbortParsing;
	
	NSAutoreleasePool *downloadAndParsePool;
	
	BOOL	didShowedConnectError;
	BOOL	isDownloading;
	BOOL		isError;
	
	NSInteger	getDataKey;
	NSInteger	parseKey;
	NSInteger	newToodleIdAdded;
	
	BOOL		isFinishedGetFolders;
	BOOL		isFinishedSyncFolders;
	BOOL		isFinishedGetTasks;
	BOOL		isFinishedGetDeletedTasks;
	BOOL		isFinishedGetUserId;
	BOOL		isFinishedGetToken;
	BOOL		isFinishedGetAccountInfo;
	
	NSInteger	totalTasks;
	NSInteger	totalDeletedTasks;
	NSInteger	totalFolders;
	
	NSInteger	timeZone;
	
	NSInteger errorTimes;
	NSString	*errorMessage;
	
	RootViewController *rootViewController;
	
	UIAlertView *successAlert;
	
	BOOL  isCheckingValidateAccount;
	NSString *accValueStr;
	
	NSInteger totalSteps;
	NSInteger currentStep;
	
	NSTimer *checkSyncSuccTimer;
 */
	NSMutableArray		*toodledoTaskList;
	NSMutableArray		*toodledoDeletedTaskList;
	NSMutableArray		*folderList;
	NSMutableArray		*t2dTaskList;
	
	NSDateFormatter		*parseFormatter;
    NSURLConnection		*rssConnection;
    NSMutableData		*xmlData;
	
    // these variables will be used during parsing
    Task				*currentTask;
	Projects			*currentCalendar;
	TDDeletedTaskObject *currentDeletedTask;
	
    NSMutableArray		*currentParseBatch;
    //NSUInteger			parsedCount;
    NSMutableString		*currentString;
    BOOL				accumulatingParsedCharacterData;
    BOOL				didAbortParsing;
	
	NSAutoreleasePool	*downloadAndParsePool;
	
	BOOL				didShowedConnectError;
	BOOL				isError;
	NSInteger			parseKey;
	
	BOOL				isFinishedGetFolders;
	BOOL				isFinishedSyncFolders;
	BOOL				isFinishedGetTasks;
	BOOL				isFinishedGetDeletedTasks;
	BOOL				isFinishedGetUserId;
	BOOL				isFinishedGetToken;
	BOOL				isFinishedGetAccountInfo;
	
	NSInteger			totalTasks;
	NSInteger			totalDeletedTasks;
	
	NSInteger			timeZone;
	NSString			*errorMessage;
	
	RootViewController	*rootViewController;
	
	UIAlertView			*successAlert;
	BOOL				isCheckingValidateAccount;
	NSString			*accValueStr;
	
	NSTimer				*checkSyncSuccTimer;
	
	NSDate				*TDLastEditFolderDateTime;
	NSDate				*TDLastEditTaskDateTime;
	NSDate				*TDLastDeleteTaskDateTime;
	NSDate				*TDLastEditNoteDateTime;
	NSDate				*TDLastDeleteNoteDateTime;
	
	//BOOL				isSyncing;
}
/*
@property (nonatomic, retain)	NSMutableArray *toodledoTaskList;
@property (nonatomic, retain)	NSMutableArray  *folderList;

@property (nonatomic, retain)	NSURLConnection *rssConnection;
@property (nonatomic, retain)	NSMutableData *xmlData;
@property (nonatomic, retain)	NSDateFormatter *parseFormatter;
@property (nonatomic, retain)	Task *currentTask;
@property (nonatomic, retain)	Projects *currentCalendar;
@property (nonatomic, retain)	NSMutableString *currentString;
@property (nonatomic, retain)	NSMutableArray *currentParseBatch;
@property (nonatomic,assign)	NSInteger	getDataKey;
@property (nonatomic, assign)	NSAutoreleasePool *downloadAndParsePool;
@property (nonatomic, retain)	NSMutableArray  *t2dTaskList;
@property (nonatomic, retain)	NSMutableArray *toodledoDeletedTaskList;
@property (nonatomic, retain)	NSString	*errorMessage;
@property (nonatomic, retain)	RootViewController *rootViewController;
@property (nonatomic,assign)	BOOL  isFinishedGetUserId;
@property (nonatomic, retain)	NSString *accValueStr;

- (void)addTaskToList:(NSArray *)images;
- (void)handleError:(NSError *)error;
-(NSString *) md5: ( NSString *) str;
- (void)parseData:(NSData *)data;

-(void)refreshtoken;
-(void)getDataWithURL:(NSString*)urlstr;
-(void)getAllFolders;
-(void)getAllTasks;
-(void)getModifiedTasks;
-(void)getDeletedTasks;
-(void)addFolder:(Projects *)cal;
-(void)addTask:(Task *)task;
-(void)sync:(id)sender;
-(void)getUserId;
-(void)start;
-(void)getAccountInfo;
-(id)initWithCheckValidity:(NSString*)username password:(NSString*)password;
*/

@property (nonatomic, retain)	NSMutableArray *toodledoTaskList;
@property (nonatomic, retain)	NSMutableArray  *folderList;

@property (nonatomic, retain)	NSURLConnection *rssConnection;
@property (nonatomic, retain)	NSMutableData *xmlData;
@property (nonatomic, retain)	NSDateFormatter *parseFormatter;
@property (nonatomic, retain)	Task *currentTask;
@property (nonatomic, retain)	Projects *currentCalendar;
@property (nonatomic, retain)	TDDeletedTaskObject *currentDeletedTask;

@property (nonatomic, retain)	NSMutableString *currentString;
@property (nonatomic, retain)	NSMutableArray *currentParseBatch;
@property (nonatomic, assign)	NSAutoreleasePool *downloadAndParsePool;
@property (nonatomic, retain)	NSMutableArray  *t2dTaskList;
@property (nonatomic, retain)	NSMutableArray *toodledoDeletedTaskList;
@property (nonatomic, retain)	NSString	*errorMessage;
@property (nonatomic, retain)	RootViewController *rootViewController;
@property (nonatomic,assign)	BOOL  isFinishedGetUserId;
@property (nonatomic, retain)	NSString *accValueStr;

@property (nonatomic, retain)	NSDate	*TDLastEditFolderDateTime;
@property (nonatomic, retain)	NSDate	*TDLastEditTaskDateTime;
@property (nonatomic, retain)	NSDate	*TDLastDeleteTaskDateTime;
@property (nonatomic, retain)	NSDate	*TDLastEditNoteDateTime;
@property (nonatomic, retain)	NSDate	*TDLastDeleteNoteDateTime;
//@property (nonatomic,assign)	BOOL	isSyncing;

- (void)addTaskToList:(NSArray *)images;
- (void)handleError:(NSError *)error;
-(NSString *) md5: ( NSString *) str;
- (void)parseData:(NSData *)data;

-(void)getDataWithURL:(NSString*)urlstr;
-(void)getTasksModifiedAfterTimeInterVal:(NSTimeInterval)modVal;
-(void)getModifiedTasks;
-(void)addFolder:(Projects *)cal;
-(id)initWithCheckValidity:(NSString*)username password:(NSString*)password;
//-(void)startCheckSyncSunccess;

-(void)addTasksFromList:(NSMutableArray*)newTasks;
-(void)addTasksWithURLString:(NSString*)urlString tasksList:(NSMutableArray*)tasksList;
-(void)updateTasksFromList:(NSMutableArray*)tasks;
-(void)updateTasksWithURLString:(NSString*)urlString tasksList:(NSMutableArray*)tasksList;
-(void)deleteTasksOnTD;
-(void)deleteTasksWithURLString:(NSString*)urlString taskIds:(NSMutableArray*)taskIds;

-(void)updateFolder:(Projects*)cal;
-(void)deleteFolder:(NSString*)folderId;
-(void)backgroundfullSync;
-(void)backgroundSyncTask:(Task*)task;
-(void)backgroundDeleteTask:(Task*)task;
-(void)backgroundSyncAddUpdateTask:(Task*)task;
-(void)backgroundSyncDeleteTask:(Task*)task;
-(void)backgroundDeleteFolder:(Projects*)cal;
-(void)syncDeleteFolder:(Projects*)folder;
-(void)backgroundDeleteDeletedTasks;
-(void)deleteTasksOnTDInBackground;
-(void)syncAddFolder:(Projects*)cal;
-(void)backgroundAddFolder:(Projects*)cal;

-(void)backgroundUpdateFolder:(Projects*)cal;

@end
