//
//  ToodleSync.m
//
//  Created by NangLe on 7/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ToodleSync.h"
#import <CFNetwork/CFNetwork.h>
#import "Task.h"
#import "IvoCommon.h"
#import "TaskManager.h"
#import "Setting.h"
#import "ivo_Utilities.h"

#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "Projects.h"
#import "SyncKeyObject.h"
#import "RootViewController.h"
#import "Setting.h"
#import "TDDeletedTaskObject.h"

#define MAX_SYNC_TASKS 500

extern TaskManager *taskManager;
extern sqlite3 *database;
//extern NSString *okText;
extern double gmtSeconds;
extern BOOL isInternetConnected;

extern NSMutableArray *projectList;

extern BOOL	isSyncing;
extern NSString *syncingText;
extern BOOL      isSyncingTask;
extern BOOL		isReloadDataFromSync;

@implementation ToodleSync
@synthesize currentString, currentTask, parseFormatter, xmlData, rssConnection, downloadAndParsePool;
@synthesize currentParseBatch,currentCalendar;
@synthesize errorMessage;
@synthesize rootViewController;
@synthesize isFinishedGetUserId;
@synthesize accValueStr;
@synthesize toodledoTaskList;
@synthesize toodledoDeletedTaskList;
@synthesize folderList;
@synthesize t2dTaskList;
@synthesize TDLastEditFolderDateTime;
@synthesize TDLastEditTaskDateTime;
@synthesize TDLastDeleteTaskDateTime;
@synthesize TDLastEditNoteDateTime;
@synthesize TDLastDeleteNoteDateTime;
@synthesize currentDeletedTask;

-(id)initWithCheckValidity:(NSString*)username password:(NSString*)password{
    self=[super init];
	if(self){
		isFinishedGetUserId=NO;
		isCheckingValidateAccount=YES;
		isSyncing=YES;
		
		parseKey=TD_GET_USER_ID;
		NSString *key = [self md5:[NSString stringWithFormat:@"%@%@", username,@"api4ce0ace4e5406"]];
		
		NSString *urlString=[NSString stringWithFormat:@"http://api.toodledo.com/2/account/lookup.php?appid=%@;sig=%@;email=%@;pass=%@;f=xml",@"smartorganizer2",key,username,password];
		
		[self getDataWithURL:urlString];
		isSyncing=NO;
		[self.rootViewController hideStatusBar];
	}
	return self;
}

-(id)init{
    self=[super init];
	if(self){
		//self.t2dTaskList=[NSMutableArray array];
		self.toodledoTaskList=[NSMutableArray array];
		self.toodledoDeletedTaskList=[NSMutableArray array];
		self.folderList=[NSMutableArray array];
		self.t2dTaskList=[NSMutableArray array];
	}
	
	return self;
}

-(NSString *)md5:(NSString *)str {//worked
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	NSString *ret= [NSString stringWithFormat:
					@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
					result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
					result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
					];
	return ret;
}

#pragma mark UserId
-(void)getUserId:(id)sender{//worked
	NSTimer *tmr=sender;
	
	if (parseKey==TD_FREE_KEY) {
		parseKey=TD_GET_USER_ID;
		NSString *sig = [self md5:[NSString stringWithFormat:@"%@%@", taskManager.currentSetting.toodledoUserName,@"api4ce0ace4e5406"]];
		NSString *urlString=[NSString stringWithFormat:@"http://api.toodledo.com/2/account/lookup.php?appid=smartorganizer2;sig=%@;email=%@;pass=%@;f=xml",sig,taskManager.currentSetting.toodledoUserName,taskManager.currentSetting.toodledoPassword];
		[self getDataWithURL:urlString];
		
		[tmr invalidate];
		tmr=nil;
	}else if(parseKey==TD_ERROR_KEY){
		[tmr invalidate];
		tmr=nil;
	}
}

#pragma mark Token

//get refresh Token must happen after getting User Id info
-(void)refreshtoken:(id)sender{//worked
	NSTimer *tmr=sender;
	
	if (parseKey==TD_FREE_KEY && isFinishedGetUserId) {
		
		NSDate *now=[NSDate date];
		NSTimeInterval duration=[now timeIntervalSinceDate:taskManager.currentSetting.toodledoTokenTime];
		duration=duration/3600;
		
		if ([taskManager.currentSetting.toodledoKey length]==0 || !taskManager.currentSetting.toodledoToken || [taskManager.currentSetting.toodledoToken length]==0 || duration>3) {
			taskManager.currentSetting.toodledoToken=@"";
			[taskManager.currentSetting update];
			
			parseKey=TD_GET_TOKEN;
			NSString *sig = [self md5:[NSString stringWithFormat:@"%@%@", taskManager.currentSetting.toodledoUserId,@"api4ce0ace4e5406"]];
			NSString *urlStr=[NSString stringWithFormat:@"http://api.toodledo.com/2/account/token.php?userid=%@;appid=smartorganizer2;sig=%@;f=xml",taskManager.currentSetting.toodledoUserId,sig];
			[self getDataWithURL:urlStr];
		}else {
			isFinishedGetToken=YES;
			parseKey=TD_FREE_KEY;
		}
		
		
		[tmr invalidate];
		tmr=nil;
	}else if(parseKey==TD_ERROR_KEY){
		[tmr invalidate];
		tmr=nil;
	}	
}

#pragma mark AccountInfo

//get Account info must happen after getting Token and User Id info
-(void)getAccountInfo:(id)sender{//worked
	NSTimer *tmr=sender;
	
	if(parseKey==TD_FREE_KEY && isFinishedGetUserId && isFinishedGetToken){
		parseKey=TD_GET_SERVER_INFO;
		[self getDataWithURL:[NSString stringWithFormat:@"http://api.toodledo.com/2/account/get.php?key=%@;f=xml",taskManager.currentSetting.toodledoKey]];
		
		[tmr invalidate];
		tmr=nil;
	}else if(parseKey==TD_ERROR_KEY){
		[tmr invalidate];
		tmr=nil;
	}
}

#pragma mark Folders

//get All Folders must happen after getting User Account info
-(void)getAllFolders:(id)sender{//worked
	NSTimer *tmr=sender;
	if(parseKey==TD_FREE_KEY && isFinishedGetAccountInfo){
		NSString *urlString=[NSString stringWithFormat:@"http://api.toodledo.com/2/folders/get.php?key=%@;f=xml",taskManager.currentSetting.toodledoKey];
		parseKey=TD_GET_FOLDER_KEY;
		[self getDataWithURL:urlString];
		[tmr invalidate];
		tmr=nil;
	}else if(parseKey==TD_ERROR_KEY){
		[tmr invalidate];
		tmr=nil;
	}
}

-(void)addFolder:(Projects *)cal{
	parseKey=TD_ADD_FOLDER_KEY;
	NSString *urlString =[NSString stringWithFormat:@"http://api.toodledo.com/2/folders/add.php?name=%@;key=%@;f=xml",
						  [cal.projName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
						  [taskManager.currentSetting.toodledoKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init]; 
	[request setURL:[NSURL URLWithString:urlString]]; 
	[request setHTTPMethod:@"POST"]; 
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"]; 
	
	NSError *error; 
	NSURLResponse *response; 
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	NSString *data=[[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding]; 
	NSLog(@"%@",data);
	
	NSArray *arr=[data componentsSeparatedByString:@"<id>"];
	if (arr.count>1) {
		NSString *str=(NSString *)[arr objectAtIndex:1];
		NSArray *arr1=[str componentsSeparatedByString:@"<"];
		
		str=[arr1 objectAtIndex:0];
		cal.toodledoFolderKey=[str intValue];
		[cal update];
	}
	
	[data release];
	[request release];
	parseKey=TD_FREE_KEY;
}

-(void)updateFolder:(Projects*)cal{
	parseKey=TD_EDIT_FOLDER;
	NSString *urlString=[NSString stringWithFormat:@"http://api.toodledo.com/2/folders/edit.php?id=%d;name=%@;key=%@;f=xml",
						 cal.toodledoFolderKey,
						 [cal.projName        stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
						 [taskManager.currentSetting.toodledoKey        stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init]; 
	[request setURL:[NSURL URLWithString:urlString]]; 
	[request setHTTPMethod:@"POST"]; 
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"]; 
	
	NSError *error; 
	NSURLResponse *response; 
	
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	[request release];
	
	NSString *data=[[[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding] autorelease]; 
	NSLog(@"%@",data);
	
	parseKey=TD_FREE_KEY;
}

-(void)deleteFolder:(NSString*)folderId{
	
	NSString *urlString=[NSString stringWithFormat:@"http://api.toodledo.com/2/folders/delete.php?id=%@;key=%@;f=xml",
						 folderId,
						 taskManager.currentSetting.toodledoKey];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init]; 
	[request setURL:[NSURL URLWithString:urlString]]; 
	[request setHTTPMethod:@"POST"]; 
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"]; 
	
	NSError *error; 
	NSURLResponse *response; 
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	NSString *data=[[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding]; 
	NSLog(@"%@",data);
	
	NSArray *arr=[data componentsSeparatedByString:@"<deleted>"];
	if (arr.count>1) {
		taskManager.currentSetting.toodledoDeletedFolders=[taskManager.currentSetting.toodledoDeletedFolders stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"|%@",folderId]
																																	   withString:@""];
		[taskManager.currentSetting update];
	}else {
		arr=[data componentsSeparatedByString:@"<error id='"];
		if (arr.count>0) {
			NSString *str=(NSString *)[arr objectAtIndex:1];
			NSArray *arr1=[str componentsSeparatedByString:@"'>"];
			if ([[arr1 objectAtIndex:0] isEqualToString:@"4"]) {
				taskManager.currentSetting.toodledoDeletedFolders=[taskManager.currentSetting.toodledoDeletedFolders stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"|%@",folderId]
																																			   withString:@""];
				[taskManager.currentSetting update];
			}
		}
	}
	
	[data release];
	[request release];
}

#pragma mark Tasks

//This must happen after getting folders in fully sync
//In the case half sync, set isFinishedGetFolders=YES before calling this method
-(void)getAllTasks:(id)sender{
	NSTimer *tmr=sender;
	if (parseKey==TD_FREE_KEY && isFinishedSyncFolders) {
		parseKey=TD_GET_TASK_KEY;
		
		NSString *urlString;
		//Is the first time sync, get all
		NSString *optionParameters=[@"folder,location,startdate,duedate,duedatemod,starttime,duetime,repeat,repeatfrom,length,added,star,note" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		if (taskManager.currentSetting.hasToodledoFirstTimeSynced==0) {
			urlString=[NSString stringWithFormat:@"http://api.toodledo.com/2/tasks/get.php?key=%@;modafter=%lf;fields=%@;f=xml",taskManager.currentSetting.toodledoKey,0.0,optionParameters];
			[self getDataWithURL:urlString];
		}else {
			//just get the list of tasks that edited or added after last sync time
			if ([taskManager.currentSetting.toodledoSyncTime compare:self.TDLastEditTaskDateTime]==NSOrderedAscending) {
				NSTimeInterval dateTimeInterval=[taskManager.currentSetting.toodledoSyncTime timeIntervalSince1970];
				urlString=[NSString stringWithFormat:@"http://api.toodledo.com/2/tasks/get.php?key=%@;modafter=%lf;fields=%@;f=xml",taskManager.currentSetting.toodledoKey,dateTimeInterval,optionParameters];
				[self getDataWithURL:urlString];
			}else {
				isFinishedGetTasks=YES;
				parseKey=TD_FREE_KEY;
			}
		}
		
		[tmr invalidate];
		tmr=nil;
	}else if(parseKey==TD_ERROR_KEY){
		[tmr invalidate];
		tmr=nil;
	}
}

-(void)getTasksModifiedAfterTimeInterVal:(NSTimeInterval)modVal{
	parseKey=TD_GET_TASK_KEY;
	NSString *urlString=[NSString stringWithFormat:@"http://api.toodledo.com/2/tasks/get.php?key=%@;modafter=%lf;f=xml",taskManager.currentSetting.toodledoKey,modVal];
	[self getDataWithURL:urlString];
}

-(void)getModifiedTasks{
	parseKey=TD_GET_TASK_KEY;
	NSString *urlString=[NSString stringWithFormat:@"http://api.toodledo.com/2/tasks/get.php?key=%@;modafter=%lf;f=xml",
						 taskManager.currentSetting.toodledoKey,[taskManager.currentSetting.toodledoSyncTime timeIntervalSince1970]];
	[self getDataWithURL:urlString];
}

//This must happen after getting all tasks when fully syncing.
//In the case half sync, set isFinishedGetTasks=YES.
-(void)getDeletedTasks:(id)sender{
	NSTimer *tmr=sender;
	if (parseKey==TD_FREE_KEY && isFinishedGetTasks) {
		parseKey=TD_GET_DELETED_TASK_KEY;
		if ([taskManager.currentSetting.toodledoSyncTime compare:self.TDLastDeleteTaskDateTime]==NSOrderedAscending) {
			NSTimeInterval tvl=[taskManager.currentSetting.toodledoSyncTime timeIntervalSince1970];
			if (tvl<=0) {
				tvl=0;
			}
			
			NSString *urlString=[NSString stringWithFormat:@"http://api.toodledo.com/2/tasks/deleted.php?key=%@;after=%lf;f=xml",
								 taskManager.currentSetting.toodledoKey,
								 tvl];
			
			//printf("\n %s",[urlString UTF8String]);
			[self getDataWithURL:urlString];
		}else {
			isFinishedGetDeletedTasks=YES;
			parseKey=TD_FREE_KEY;
		}
		
		[tmr invalidate];
		tmr=nil;
	}else if(parseKey==TD_ERROR_KEY){
		[tmr invalidate];
		tmr=nil;
	}
}

//Notes: api just allow to add 50 tasks a time maximum
-(void)addTasksFromList:(NSMutableArray*)newTasks{
	if (newTasks.count==0) return;
	
checkAndAdd:
	{
		NSInteger i=0;
		NSMutableArray *_50Tasks=[NSMutableArray array];
		NSMutableArray *tasksArr=[NSMutableArray arrayWithArray:newTasks];
		for (Task *topTask in tasksArr) {
			[_50Tasks addObject:topTask];
			[newTasks removeObject:topTask];
			i++;
			
			if (i==50 || i==tasksArr.count) {
				i=0;
				NSString *urlBody=@"";
				for (Task *task in _50Tasks) {
					Projects *cal=[taskManager calendarWithPrimaryKey:task.taskProject];
					NSString *str=[NSString stringWithFormat:@"{\"title\":\"%@\",\"folder\":\"%d\",\"location\":\"%@\",\"duedate\":%lf,\"startdate\":%lf,\"length\":\"%d\",\"completed\":%lf,\"note\":\"%@\",\"repeat\":\"%@\",\"repeatfrom\":\"%d\",\"ref\":\"%d\"}",
								   task.taskName,cal.toodledoFolderKey,task.taskLocation,task.taskIsUseDeadLine?([[ivo_Utilities resetTime4Date:task.taskDeadLine hour:0 minute:0 second:0] timeIntervalSince1970]+gmtSeconds):0,([[ivo_Utilities resetTime4Date:task.taskNotEalierThan hour:0 minute:0 second:0] timeIntervalSince1970]+gmtSeconds),task.taskHowLong,task.taskCompleted?([task.taskDateUpdate timeIntervalSince1970]+gmtSeconds):0,task.taskDescription,[taskManager getRepeatStrForTDFromSPadTask:task],task.taskRepeatID,task.primaryKey];
					
					if (i==0) {
						urlBody=str;
					}else {
						urlBody=[urlBody stringByAppendingFormat:@",%@",str];
					}
					
					i++;
				}
				
				//printf("\n add: %s",[urlBody UTF8String]);
				[self addTasksWithURLString:urlBody tasksList:_50Tasks];
				goto checkAndAdd;
			}
		}
	}
}

-(void)addTasksWithURLString:(NSString*)urlString tasksList:(NSMutableArray*)tasksList{
	parseKey=TD_ADD_TASK_KEY;
	NSMutableArray *tasks=tasksList;
	
	if (!urlString) {
		return;
	}
	
	// setting up the request object now
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:@"http://api.toodledo.com/2/tasks/add.php"]];
	[request setHTTPMethod:@"POST"];
	
	NSString *boundary = [NSString stringWithString:@"-----------------local2TD1234567890qwertyuiopasdfghjklzxcvbnm"];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[request setValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	NSMutableData *body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"key\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@",taskManager.currentSetting.toodledoKey] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"tasks\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"[%@]",urlString] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"fields\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@",@"ref"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"f\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@",@"xml"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	// setting the body of the post to the reqeust
	[request setHTTPBody:body];
	
	NSError *error; 
	NSURLResponse *response; 
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	NSString *data=[[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding]; 
	//NSLog(@"%@",data);
	
	NSArray *arr=[data componentsSeparatedByString:@"<id>"];
	//arr[1]: 1234</id><title>My Task</title><folder>0</folder><modified>1234567890</modified><completed></completed><star>0</star><ref>1</ref></task><task>
	//arr[2]:1235</id><title>Another</title><folder>0</folder><modified>1234567890</modified><completed></completed><star>1</star><ref>2</ref></task>...
	
	if (arr.count>1) {
		for (NSInteger i=1;i<arr.count;i++) {
			NSString *headStr=(NSString *)[arr objectAtIndex:i];
			NSArray *parseArr=[headStr componentsSeparatedByString:@"</id>"];
			//parseArr[0]:1234
			//parseArr[1]:<title>My Task</title><folder>0</folder><modified>1234567890</modified><completed></completed><star>0</star><ref>1</ref></task><task>
			NSInteger taskTDId=[[parseArr objectAtIndex:0] intValue];
			NSString *tail=(NSString *)[parseArr objectAtIndex:1];
			
			parseArr=[tail componentsSeparatedByString:@"<ref>"];
			//parseArr[0]:<title>My Task</title><folder>0</folder><modified>1234567890</modified><completed></completed><star>0</star><ref>
			//parseArr[1]:1</ref></task><task>
			NSString *tailSubStr= [parseArr objectAtIndex:1];
			parseArr=[tailSubStr componentsSeparatedByString:@"</ref>"];
			
			NSInteger taskCalPadId=[[parseArr objectAtIndex:0] intValue];
			
			for (Task *task in tasks) {
				if (task.primaryKey==taskCalPadId) {
					task.toodledoID=taskTDId;
					[task update];
					break;
				}
			}
		}
	}
	
	[data release];
	[request release];
	parseKey=TD_FREE_KEY;
}

-(void)updateTasksFromList:(NSMutableArray*)tasks{
	if (tasks.count==0) return;
	
	parseKey=TD_EDIT_TASK;
checkAndUpdate:
	{
		NSInteger i=0;
		NSMutableArray *_50Tasks=[NSMutableArray array];
		NSMutableArray *tasksArr=[NSMutableArray arrayWithArray:tasks];
		for (Task *topTask in tasksArr) {
			[_50Tasks addObject:topTask];
			[tasks removeObject:topTask];
			i++;
			
			if (i==49 || i==tasksArr.count) {
				i=0;
				NSString *urlBody=@"";
				for (Task *task in _50Tasks) {
					Projects *cal=[taskManager calendarWithPrimaryKey:task.taskProject];
					NSString *str=[NSString stringWithFormat:@"{\"id\":\"%d\",\"title\":\"%@\",\"folder\":\"%d\",\"location\":\"%@\",\"duedate\":%lf,\"startdate\":%lf,\"length\":\"%d\",\"completed\":%lf,\"note\":\"%@\",\"star\":\"%d\",\"repeat\":\"%@\",\"repeatfrom\":\"%d\"}",
								   task.toodledoID,
								   task.taskName,
								   cal.toodledoFolderKey,
								   task.taskLocation,
								   task.taskIsUseDeadLine?([[ivo_Utilities resetTime4Date:task.taskDeadLine hour:0 minute:0 second:0] timeIntervalSince1970]+gmtSeconds):0,
								   task.toodledoHasStart?([[ivo_Utilities resetTime4Date:task.taskNotEalierThan hour:0 minute:0 second:0] timeIntervalSince1970]+gmtSeconds):0,
								   task.hasDuration?task.taskHowLong:0,
								   task.taskCompleted?([task.taskDateUpdate timeIntervalSince1970]+gmtSeconds):0,
								   task.taskDescription,
								   [taskManager getRepeatStrForTDFromSPadTask:task],task.taskRepeatID];
					if (i==0) {
						urlBody=str;
					}else {
						urlBody=[urlBody stringByAppendingFormat:@",%@",str];
					}
					i++;
				}
				
				//NSString *urlString=[NSString stringWithFormat:@"http://api.toodledo.com/2/tasks/edit.php?key=%@;\ntasks=[%@];\nfields=%@;f=xml",taskManager.currentSetting.toodledoKey,urlBody,[@"\"\"" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
				//printf("\n %s",[urlBody UTF8String]);
				[self updateTasksWithURLString:urlBody tasksList:_50Tasks];
				
				goto checkAndUpdate;
			}
		}
	}
	
	parseKey=TD_FREE_KEY;
	
}

-(void)updateTasksWithURLString:(NSString*)urlString tasksList:(NSMutableArray*)tasksList{
	if (!urlString) {
		return;
	}
	
	// setting up the request object now
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:@"http://api.toodledo.com/2/tasks/edit.php"]];
	[request setHTTPMethod:@"POST"];
	
	NSString *boundary = [NSString stringWithString:@"-----------------local2TD1234567890qwertyuiopasdfghjklzxcvbnm"];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[request setValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	NSMutableData *body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"key\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@",taskManager.currentSetting.toodledoKey] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"tasks\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"[%@]",urlString] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"f\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@",@"xml"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	// setting the body of the post to the reqeust
	[request setHTTPBody:body];
	
	NSError *error; 
	NSURLResponse *response; 
	[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	[request release];
}

-(void)deleteTasksOnTD{
	parseKey=TD_DELETE_TASK;
	NSMutableArray *deletedTasks=(NSMutableArray*)[taskManager.currentSetting.toodledoDeletedTasks componentsSeparatedByString:@"|"];
	if (deletedTasks.count<=1) goto finished;
	
checkAndDelete:
	{
		NSInteger i=0;
		NSMutableArray *_50TaskIds=[NSMutableArray array];
		NSMutableArray *taskIdsArr=[NSMutableArray arrayWithArray:deletedTasks];
		
		for (NSString *taskId in taskIdsArr) {
			if ([taskId intValue]>0) {
				[_50TaskIds addObject:taskId];
				i++;
			}
			
			[deletedTasks removeObject:taskId];
			
			if (i==50 || i==taskIdsArr.count-1) {
				//i=0;
				NSString *urlBody=@"";
				BOOL isFirstTaskId=YES;
				for (NSString *taskIdSub in _50TaskIds) {
					if (isFirstTaskId) {
						urlBody=[urlBody stringByAppendingFormat:@"\"%@\"",taskIdSub];
						isFirstTaskId=NO;
					}else {
						urlBody=[urlBody stringByAppendingFormat:@",\"%@\"",taskIdSub];
					}
				}
				
				//NSString *urlString=[NSString stringWithFormat:@"http://api.toodledo.com/2/tasks/delete.php?key=%@;tasks=[%@];f=xml",taskManager.currentSetting.toodledoKey,[urlBody stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
				[self deleteTasksWithURLString:urlBody taskIds:_50TaskIds];
				goto checkAndDelete;
			}
		}
	}
	
finished:	
	parseKey=TD_FREE_KEY;
}

-(void)deleteTasksWithURLString:(NSString*)urlString taskIds:(NSMutableArray*)taskIds{
	parseKey=TD_DELETE_TASK;
	NSMutableArray *deleteIDsArr=taskIds;
	
	if (!urlString) {
		return;
	}
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:@"http://api.toodledo.com/2/tasks/delete.php"]];
	[request setHTTPMethod:@"POST"];
	
	NSString *boundary = [NSString stringWithString:@"-----------------local2TD1234567890qwertyuiopasdfghjklzxcvbnm"];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[request setValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	NSMutableData *body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"key\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@",taskManager.currentSetting.toodledoKey] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"tasks\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"[%@]",urlString] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"f\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@",@"xml"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	// setting the body of the post to the reqeust
	[request setHTTPBody:body];
	
	NSError *error; 
	NSURLResponse *response; 
	//[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NSString *data=[[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
	//NSLog(@"%@",data);
	
	NSArray *arr=[data componentsSeparatedByString:@"<id>"];
	if (arr.count>1) {
		for (NSString *str in deleteIDsArr) {
			taskManager.currentSetting.toodledoDeletedTasks=[taskManager.currentSetting.toodledoDeletedTasks stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"|%@",str] withString:@""];
		}
		
		[taskManager.currentSetting update];
	}
	
	[data release];
	[request release];
	parseKey=TD_FREE_KEY;
}

#pragma mark Syncs

-(void)backgroundAddFolder:(Projects*)cal{
	if (!isInternetConnected || taskManager.currentSetting.autoTDSync==0) return;
	[self performSelectorInBackground:@selector(syncAddFolder:) withObject:cal];
}

-(void)syncAddFolder:(Projects*)cal{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	//[self.rootViewController showStatusBarWithText:syncingText];
	[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(waitToAddFolder:) userInfo:cal repeats:YES];
	[[NSRunLoop currentRunLoop] run];
	[pool release];
}

-(void)waitToAddFolder:(id)sender{
	NSTimer *timer=sender;

	if (!isSyncing) {
		
		isSyncing=YES;
        [self.rootViewController showStatusBarWithText:syncingText];

		parseKey=TD_FREE_KEY;
		isError=NO;
		isFinishedGetUserId=NO;
		isFinishedGetToken=NO;
		isFinishedGetAccountInfo=NO;
		
		Projects *cal=[timer userInfo];
		
		//1.Check if exist User Id
		if ([taskManager.currentSetting.toodledoUserId length]==0) {
			[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(getUserId:) userInfo:nil repeats:YES];
		}else {
			isFinishedGetUserId=YES;
		}
		
		//2.Refresh Token after having User Id
		[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(refreshtoken:) userInfo:nil repeats:YES];
		
		//3.Get Account Info after having User Id and Token
		[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(getAccountInfo:) userInfo:nil repeats:YES];
		
		[self addFolder:cal];
		[self.rootViewController hideStatusBar];
		isSyncing=NO;
		
		[timer invalidate];
		timer=nil;
	}
}

-(void)backgroundUpdateFolder:(Projects*)cal{
	if (!isInternetConnected || taskManager.currentSetting.autoTDSync==0) return;
	[self performSelectorInBackground:@selector(syncUpdateFolder:) withObject:cal];
	
}

-(void)syncUpdateFolder:(Projects*)cal{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	//[self.rootViewController showStatusBarWithText:syncingText];
	[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(waitToUpdateFolder:) userInfo:cal repeats:YES];
	[[NSRunLoop currentRunLoop] run];
	[pool release];	
}

-(void)waitToUpdateFolder:(id)sender{
	NSTimer *timer=sender;
	
	if (!isSyncing) {
		isSyncing=YES;
        [self.rootViewController showStatusBarWithText:syncingText];

		parseKey=TD_FREE_KEY;
		isError=NO;
		isFinishedGetUserId=NO;
		isFinishedGetToken=NO;
		isFinishedGetAccountInfo=NO;
		
		//1.Check if exist User Id
		if ([taskManager.currentSetting.toodledoUserId length]==0) {
			[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(getUserId:) userInfo:nil repeats:YES];
		}else {
			isFinishedGetUserId=YES;
		}
		
		//2.Refresh Token after having User Id
		[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(refreshtoken:) userInfo:nil repeats:YES];
		
		//3.Get Account Info after having User Id and Token
		[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(getAccountInfo:) userInfo:nil repeats:YES];
		
		Projects *folder=[timer userInfo];
		[self updateFolder:folder];
		isSyncing=NO;
		[self.rootViewController hideStatusBar];
		
		[timer invalidate];
		timer=nil;
	}
}

-(void)backgroundDeleteFolder:(Projects*)cal{
	if (!isInternetConnected || taskManager.currentSetting.autoTDSync==0) return;
	[self performSelectorInBackground:@selector(syncDeleteFolder:) withObject:cal];
}

-(void)syncDeleteFolder:(Projects*)folder{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(waitToDeleteFolder:) userInfo:folder repeats:YES];
	[[NSRunLoop currentRunLoop] run];
	[pool release];	
}

-(void)waitToDeleteFolder:(id)sender{
	NSTimer *timer=sender;
	
	if (!isSyncing) {
		parseKey=TD_FREE_KEY;
		isError=NO;
		isFinishedGetUserId=NO;
		isFinishedGetToken=NO;
		isFinishedGetAccountInfo=NO;
		isSyncing=YES;
		
		Projects *folder=[timer userInfo];
		//1.Check if exist User Id
		if ([taskManager.currentSetting.toodledoUserId length]==0) {
			[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(getUserId:) userInfo:nil repeats:YES];
		}else {
			isFinishedGetUserId=YES;
		}
		
		//2.Refresh Token after having User Id
		[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(refreshtoken:) userInfo:nil repeats:YES];
		
		//3.Get Account Info after having User Id and Token
		[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(getAccountInfo:) userInfo:nil repeats:YES];
		
		if (folder.toodledoFolderKey>0) {
			[self deleteFolder:[NSString stringWithFormat:@"%d", folder.toodledoFolderKey]];
		}
		
		[self.rootViewController hideStatusBar];
		isSyncing=NO;

		[timer invalidate];
		timer=nil;
	}
}

-(void)backgroundSyncTask:(Task*)task{
	if (!isInternetConnected || taskManager.currentSetting.autoTDSync==0) return;
	[self performSelectorInBackground:@selector(backgroundSyncAddUpdateTask:) withObject:task];
}

-(void)backgroundSyncAddUpdateTask:(Task*)task{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	//[self.rootViewController showStatusBarWithText:syncingText];
	[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(waitToAddUpdateTask:) userInfo:task repeats:YES];
	[[NSRunLoop currentRunLoop] run];
	[pool release];
}

-(void)waitToAddUpdateTask:(id)sender{
	NSTimer *timer=sender;
	
	if (!isSyncing) {
		isSyncing=YES;

        [self.rootViewController showStatusBarWithText:syncingText];

		parseKey=TD_FREE_KEY;
		isError=NO;
		isFinishedGetUserId=NO;
		isFinishedGetToken=NO;
		isFinishedGetAccountInfo=NO;
		
		Task *task=[timer userInfo];
		
		//1.Check if exist User Id
		if ([taskManager.currentSetting.toodledoUserId length]==0) {
			[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(getUserId:) userInfo:nil repeats:YES];
		}else {
			isFinishedGetUserId=YES;
		}
		
		//2.Refresh Token after having User Id
		[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(refreshtoken:) userInfo:nil repeats:YES];
		
		//3.Get Account Info after having User Id and Token
		[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(getAccountInfo:) userInfo:nil repeats:YES];
		
		NSMutableArray *arr=[NSMutableArray arrayWithObject:task];
		if (task.toodledoID>0) {
			[self updateTasksFromList:arr];
		}else {
			[self addTasksFromList:arr];
		}

		isSyncing=NO;
		[self.rootViewController hideStatusBar];

		[timer invalidate];
		timer=nil;
	}
}

-(void)backgroundDeleteTask:(Task*)task{
	if (taskManager.currentSetting.autoTDSync==0 || !isInternetConnected ||task.toodledoID==0) return;
	[self performSelectorInBackground:@selector(backgroundSyncDeleteTask:) withObject:task];
}

-(void)backgroundSyncDeleteTask:(Task*)task{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	//[self.rootViewController showStatusBarWithText:syncingText];
	[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(waitToDeleteTask:) userInfo:task repeats:YES];
	[[NSRunLoop currentRunLoop] run];	
	[pool release];
}

-(void)waitToDeleteTask:(id)sender{
	NSTimer *timer=sender;
	
	if (!isSyncing) {
		isSyncing=YES;

        [self.rootViewController showStatusBarWithText:syncingText];

		parseKey=TD_FREE_KEY;
		isError=NO;
		isFinishedGetUserId=NO;
		isFinishedGetToken=NO;
		isFinishedGetAccountInfo=NO;
		
		Task *task=[timer userInfo];
		
		//1.Check if exist User Id
		if ([taskManager.currentSetting.toodledoUserId length]==0) {
			[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(getUserId:) userInfo:nil repeats:YES];
		}else {
			isFinishedGetUserId=YES;
		}
		
		//2.Refresh Token after having User Id
		[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(refreshtoken:) userInfo:nil repeats:YES];
		
		//3.Get Account Info after having User Id and Token
		[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(getAccountInfo:) userInfo:nil repeats:YES];
		
		[self deleteTasksOnTD];
		
		if (task.toodledoID>0) {
			[self deleteTasksWithURLString:[NSString stringWithFormat:@"\"%d\"",task.toodledoID] 
								   taskIds:[NSMutableArray arrayWithObjects:@"",[NSString stringWithFormat:@"%d",task.toodledoID],nil]];
		}
		
		isSyncing=NO;
		[self.rootViewController hideStatusBar];

		[timer invalidate];
		timer=nil;
	}
}

-(void)backgroundDeleteDeletedTasks{
	if (taskManager.currentSetting.autoTDSync==0 || !isInternetConnected ||[taskManager.currentSetting.toodledoDeletedTasks length]==0) return;
	[self performSelectorInBackground:@selector(deleteTasksOnTDInBackground) withObject:nil];
}

-(void)deleteTasksOnTDInBackground{
	if (taskManager.currentSetting.autoTDSync==0 || !isInternetConnected ||[taskManager.currentSetting.toodledoDeletedTasks length]==0) return;
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	//[self.rootViewController showStatusBarWithText:syncingText];
	[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(waitToDeleteDeletedTasks:) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] run];
	
	[pool release];	
}

-(void)waitToDeleteDeletedTasks:(id)sender{
	NSTimer *timer=sender;
	
	if (!isSyncing) {
		
		isSyncing=YES;
        [self.rootViewController showStatusBarWithText:syncingText];

		parseKey=TD_FREE_KEY;
		isError=NO;
		isFinishedGetUserId=NO;
		isFinishedGetToken=NO;
		isFinishedGetAccountInfo=NO;
		
		//1.Check if exist User Id
		if ([taskManager.currentSetting.toodledoUserId length]==0) {
			[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(getUserId:) userInfo:nil repeats:YES];
		}else {
			isFinishedGetUserId=YES;
		}
		
		//2.Refresh Token after having User Id
		[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(refreshtoken:) userInfo:nil repeats:YES];
		
		//3.Get Account Info after having User Id and Token
		[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(getAccountInfo:) userInfo:nil repeats:YES];
		
		[self deleteTasksOnTD];
		isSyncing=NO;
		[self.rootViewController hideStatusBar];
		
		[timer invalidate];
		timer=nil;
	}
}

-(void)backgroundfullSync{
	if (!isInternetConnected) return;
	[self performSelectorInBackground:@selector(startFullSync) withObject:nil];
	
}

//This used to make a fully sync between local and TD
//Notes: the order of code in this method should not be changed.
//Otherwise, its functionality will be incorrect.
//-(void)startFullSync:(id)sender{
-(void)startFullSync{	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    isSyncingTask=YES;
	[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(waitToFullSync:) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] run];
	
	[pool release];
}

-(void)waitToFullSync:(id)sender{
	NSTimer *timer=sender;
	
	if (!isSyncing) {
		
		isSyncing=YES;
        [self.rootViewController showStatusBarWithText:syncingText];

		parseKey=TD_FREE_KEY;
		isError=NO;
		isFinishedGetUserId=NO;
		isFinishedGetToken=NO;
		isFinishedGetAccountInfo=NO;
		
		[self.t2dTaskList removeAllObjects];
		[self.toodledoTaskList removeAllObjects];
		[self.toodledoDeletedTaskList removeAllObjects];
		[self.folderList removeAllObjects];
		
		//1.Check if exist User Id
		if ([taskManager.currentSetting.toodledoUserId length]==0) {
			[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(getUserId:) userInfo:nil repeats:YES];
		}else {
			isFinishedGetUserId=YES;
		}
		
		//2.Refresh Token after having User Id
		[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(refreshtoken:) userInfo:nil repeats:YES];
		
		//3.Get Account Info after having User Id and Token
		[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(getAccountInfo:) userInfo:nil repeats:YES];
		
		//4.Apply fully Sync
		[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(fullSync:) userInfo:nil repeats:YES];
		
		[timer invalidate];
		timer=nil;
	}
}

//This must happen after getting User Info
-(void)fullSync:(id)sender{
	NSTimer *tmr=sender;
	
	if (parseKey==TD_FREE_KEY && isFinishedGetAccountInfo) {
		
		isFinishedGetFolders=NO;
		isFinishedSyncFolders=NO;
		isFinishedGetTasks=NO;
		isFinishedGetDeletedTasks=NO;
		totalDeletedTasks=0;
		totalTasks=0;
		//parsedCount=0;
		
		//prepare to sync folders
		//1.Get all folders from TD after having Account Info
		[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(getAllFolders:) userInfo:nil repeats:YES];
		
		//2.Apply to sync Folders between local and TD
		[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(syncFolders:) userInfo:nil repeats:YES];
		
		//3.Delete tasks which deleted on local
		[self deleteTasksOnTD];
		
		//4.Get TD tasks list to sync tasks
		//If this is the first time syncing, get all tasks.
		//Otherwise, get tasks modified after syncing time.
		[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(getAllTasks:) userInfo:nil repeats:YES];
		
		//5.Get deleted tasks from TD
		[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(getDeletedTasks:) userInfo:nil repeats:YES];
		
		//6.Prepare local tasks list to sync tasks
		[self.t2dTaskList removeAllObjects];
		//if (taskManager.currentSetting.hasToodledoFirstTimeSynced==0) {
		//[self.t2dTaskList addObjectsFromArray:[taskManager getAllTasksFromList:taskManager.allTasksEventsAdes withSearchText:@""]];
		[self.t2dTaskList addObjectsFromArray:[taskManager getTaskListFromDate:nil toDate:nil taskType:0 isAllTasks:YES withSearchText:@""]];
		
		//self.t2dTaskList=[[[taskManager getTaskListFromDate:nil toDate:nil taskType:0 isAllTasks:YES withSearchText:@""] retain] autorelease];
		
		for (Projects *cal in projectList) {
			if (cal.inVisible==1) {
				[taskManager addTasksToList:self.t2dTaskList fromCalendarId:cal.primaryKey];
			}
		}
		//}else {
		//	for (Task *task in taskManager.allTasksEventsAdes) {
		//		if ([task.taskDateUpdate compare:taskManager.currentSetting.toodledoSyncTime]==NSOrderedDescending) {
		//			[self.t2dTaskList addObject:task];
		//		}
		//	}
		//	
		//	for (Projects *cal in projectList) {
		//		if (cal.inVisible==1) {
		//			NSMutableArray *hiddenTasks=[NSMutableArray array];
		//			[taskManager addTasksToList:hiddenTasks fromCalendarId:cal.primaryKey];
		//			for (Task *task in hiddenTasks) {
		//				if ([task.taskDateUpdate compare:taskManager.currentSetting.toodledoSyncTime]==NSOrderedDescending) {
		//					[self.t2dTaskList addObject:task];
		//				}
		//			}
		//		}
		//	}
		//}
		
		//6.Sync tasks
		[NSTimer scheduledTimerWithTimeInterval:LOOP_DURATION target:self selector:@selector(fullSyncTasks:) userInfo:nil repeats:YES];		
		
		[tmr invalidate];
		tmr=nil;
		
	}else if(parseKey==TD_ERROR_KEY){
		[tmr invalidate];
		tmr=nil;
	}
	
}

//	This must happen after getting all folders from TD
//	*Require: 
// - All folders from TD must be available before calling this method
// - All smartorganizer2 calendars must be available before calling this method.
-(void)syncFolders:(id)sender{
	NSTimer *tmr=sender;
	
	if(parseKey==TD_FREE_KEY && isFinishedGetFolders){
		
		[self.rootViewController showStatusBarWithText:syncingText];
		
		NSMutableArray *foldersArr=[[NSMutableArray arrayWithArray:projectList] retain];
		
		//delete the calendars, which deleted from smartorganizer2, on TD
		NSArray *deletedList=[taskManager.currentSetting.toodledoDeletedFolders componentsSeparatedByString:@"|"];
		if(deletedList.count>1){
			for (NSInteger i=1;i<deletedList.count;i++) {
				NSMutableArray *folders= [NSMutableArray arrayWithArray:self.folderList];
				
				//delete on the toodledo server
				[self deleteFolder:[deletedList objectAtIndex:i]];
				
				//delete in the recieved list
				for (Projects *folder in folders) {
					if (folder.toodledoFolderKey==[[deletedList objectAtIndex:i] intValue]) {
						[self.folderList removeObject:folder];
						break;
					}
				}
			}
		}
		//------------------------------------------------------------
		
		//update the changes between smartorganizer2 and Toodledo
		NSMutableArray *doneList=[NSMutableArray array];
		
		for (Projects *cal in foldersArr) {
			if (cal.toodledoFolderKey>0) {
				//has synced in the past
				NSMutableArray *tdFoldersArr=[NSMutableArray arrayWithArray:self.folderList];
				
				for (Projects *folder in tdFoldersArr) {
					if (cal.toodledoFolderKey==folder.toodledoFolderKey) {
						//mapped found
						if ([self.TDLastEditFolderDateTime compare:taskManager.currentSetting.toodledoSyncTime]==NSOrderedDescending) {
							//has some changes from TD after last syncing time, update folder on smartorganizer2
							cal.projName=folder.projName;
							[cal update];
							[doneList addObject:cal];
							[self.folderList removeObject:folder];
						}else {
							//has no any change from TD after last syncing time, find and update folders on TD
							NSString *calname=[[cal.projName uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
							NSString *foldername=[[folder.projName uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
							
							if (![calname isEqualToString:foldername]){
								[self updateFolder:cal];
								[doneList addObject:cal];
								[self.folderList removeObject:folder];
							}
						}
						
						break;
					}
				}
			}
		}
		
		[foldersArr removeObjectsInArray:doneList];
		[doneList removeAllObjects];
		
		//now we have two rest lists: from smartorganizer2 and from TD, 
		//Notes: will delete links from the smartorganizer2 calendars which has mapped in the past, just keep for new comparing
		//we will not delete calendar because it may have events 
		//and we will not delete tasks because TD will not delete tasks when deleting folder
		
		//now we create new mapping if any
		for (Projects *cal in foldersArr) {
			NSString *calname=[[cal.projName uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
			
			NSMutableArray *tdFoldersArr=[NSMutableArray arrayWithArray:self.folderList];
			for (Projects *folder in tdFoldersArr) {
				NSString *foldername=[[folder.projName uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
				
				if ([calname isEqualToString:foldername]) {
					cal.toodledoFolderKey=folder.toodledoFolderKey;
					[cal update];
					[doneList addObject:cal];
					[self.folderList removeObject:folder];
				}
			}
		}
		
		[foldersArr removeObjectsInArray:doneList];
		[doneList removeAllObjects];
		
		//create new folders on TD for the rest smartorganizer2 list
		for (Projects *cal in foldersArr) {
			if (cal.toodledoFolderKey==0 && cal.inVisible==0){
				[self addFolder:cal];
			}
		}
		
		
		//create new calendar on smartorganizer2
		for (Projects *cal in self.folderList) {
			[taskManager.currentSetting update];
			
			cal.colorId=(arc4random() %8);;
			cal.groupId=(arc4random() %4);;
			cal.enableTDSync=1;
			cal.enableICalSync=0;
			//cal.enableGcalSync=0;
			cal.inVisible=0;
			cal.builtIn=TD;
			[taskManager addCalendarToCalendarList:cal];
			[cal update];
		}
		
		[foldersArr release];

		//taskManager.currentSetting.toodledoSyncTime=[NSDate date];
		//[taskManager.currentSetting update];
		
		[tmr invalidate];
		tmr=nil;
		isFinishedSyncFolders=YES;
		//[self.rootViewController hideStatusBar];
		
	}else if(parseKey==TD_ERROR_KEY){
		[tmr invalidate];
		tmr=nil;
	}
	
}

//This must happen after getting DeletedTasks in fully syncing
//This requires:
//TD task list must be available before syncing
//smartorganizer2 task list must be full list and available before syncing

-(void)fullSyncTasks:(id)sender{
	NSTimer *tmr=sender;
	
	if(parseKey==TD_FREE_KEY && isFinishedGetDeletedTasks && isFinishedGetTasks && isFinishedSyncFolders){
		[self.rootViewController showStatusBarWithText:syncingText];
		
		//1.delete the tasks, which already deleted on TD, in local
		for (TDDeletedTaskObject *deletedObj in self.toodledoDeletedTaskList) {
			NSMutableArray *localList=[NSMutableArray arrayWithArray:self.t2dTaskList];
			for (Task *task in localList) {
				if (task.toodledoID==deletedObj.taskId) {
					[task deleteFromDatabase];
					[self.t2dTaskList removeObject:task];
					[taskManager.taskList removeObject:task];
				}
			}
		}
		
		//update tasks
		NSMutableArray *localTaskList=[NSMutableArray arrayWithArray:self.t2dTaskList];
		NSMutableArray *remoteUpdateList=[NSMutableArray array];
		NSMutableArray *newLocalTaskList=[NSMutableArray array];
		
		for (Task *localTask in localTaskList) {
			if (localTask.toodledoID==0) {
				[newLocalTaskList addObject:localTask];
				[self.t2dTaskList removeObject:localTask];
				continue;
			}
			
			NSMutableArray *remoteTaskList=[NSMutableArray arrayWithArray:self.toodledoTaskList];
			for (Task *remoteTask in remoteTaskList) {
				if (localTask.toodledoID==remoteTask.toodledoID) {
					if ([remoteTask.taskDateUpdate compare:localTask.taskDateUpdate]==NSOrderedAscending) {
						[remoteUpdateList addObject:localTask];
					}else {
						if ([remoteTask.taskDateUpdate compare:localTask.taskDateUpdate]==NSOrderedDescending) {
							localTask.taskName=remoteTask.taskName;
							localTask.taskLocation=remoteTask.taskLocation;
							//localTask.isFromSyncing=YES;
							localTask.taskNotEalierThan=remoteTask.taskNotEalierThan;
							localTask.taskIsUseDeadLine=remoteTask.taskIsUseDeadLine;
							localTask.taskDeadLine=remoteTask.taskDeadLine;
							//localTask.hasDuration=remoteTask.hasDuration;
							localTask.taskHowLong=remoteTask.taskHowLong;
							localTask.taskRepeatID=remoteTask.taskRepeatID;
							localTask.taskRepeatOptions=remoteTask.taskRepeatOptions;
							localTask.taskProject=remoteTask.taskProject;
							localTask.taskCompleted=remoteTask.taskCompleted;
							localTask.taskDateUpdate=remoteTask.taskDateUpdate;
							localTask.taskDescription=remoteTask.taskDescription;
							//localTask.isPinned=remoteTask.isPinned;
							
							taskManager.modifyingTask=localTask;
							//[taskManager updateTaskWithRecuringEditType:ALL_SERIRES];
							taskManager.modifyingTask.isFromSyncing=YES;
                            [taskManager.modifyingTask update];
							taskManager.modifyingTask.isFromSyncing=NO;
						}
					}
					
					[self.t2dTaskList removeObject:localTask];
					[self.toodledoTaskList removeObject:remoteTask];
					break;
				}
			}
		}
		
		//now the rest of local list should be new tasks
		if (newLocalTaskList.count>0) {
			[self addTasksFromList:newLocalTaskList];
		}
		
		//now we have two rest list, 
		//in the rest of local list has some tasks need update to TD
		localTaskList=[NSMutableArray arrayWithArray:self.t2dTaskList];
		for (Task *localTask in localTaskList) {
			if ([localTask.taskDateUpdate compare:taskManager.currentSetting.toodledoSyncTime]==NSOrderedDescending) {
				[remoteUpdateList addObject:localTask];
			}
			[self.t2dTaskList removeObject:localTask];
		}
		
		//update the tasks to TD
		if (remoteUpdateList.count>0) {
			[self updateTasksFromList:remoteUpdateList];
		}
		
		//In the rest of remote list, are new tasks need to be added to local 
		for (Task *remoteTask in self.toodledoTaskList) {
			taskManager.modifyingTask=remoteTask;
			//[taskManager addNewTask];
			taskManager.modifyingTask.isFromSyncing=YES;
            [taskManager.modifyingTask insertIntoDatabase:database];
			[taskManager.modifyingTask update];
			taskManager.modifyingTask.isFromSyncing=NO;
            //[taskManager.allTasksEventsAdes addObject:taskManager.modifyingTask];
		}
		
		//end
		//if (taskManager.currentSetting.hasToodledoFirstTimeSynced==0) {
		//	taskManager.currentSetting.hasToodledoFirstTimeSynced=1;
		//	[taskManager.currentSetting update];
		//}
		
		//-------------------------------------------------------------------------------
		
		//[self startCheckSyncSunccess];
		
		taskManager.currentSetting.toodledoSyncTime=[NSDate date];
		taskManager.currentSetting.hasToodledoFirstTimeSynced=1;
		[taskManager.currentSetting update];
		
		for (Projects *cal in projectList) {
			if (cal.inVisible) {
				[taskManager removeAllTasksBelongCalendar:cal.primaryKey];
			}
		}
		
		isReloadDataFromSync=YES;
		[self.rootViewController reloadData];
		isReloadDataFromSync=NO;
		
		isSyncing=NO;
        
        NSMutableArray *sourceList=[NSMutableArray arrayWithArray:taskManager.taskList];
		[taskManager updateLocalNotificationForList:sourceList];
		
		printf("\n sync finished!");
		[tmr invalidate];
		tmr=nil;
		
		[self.rootViewController hideStatusBar];
		parseKey=TD_FREE_KEY;
        isSyncingTask=NO;

	}else if(parseKey==TD_ERROR_KEY){
		[tmr invalidate];
		tmr=nil;
	}
	
	
}

#pragma mark UIAlertViewDelegate
-(void) closeSuccesAlert:(id)sender{
	//[successAlert dismissWithClickedButtonIndex:0 animated:YES];
	[self.rootViewController alertView:successAlert clickedButtonAtIndex:0];
}

/*
 - (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
 if ([alertView isEqual:successAlert]) {
 if (rootViewController.dayBookView.rightPageView.pageType==SMART_LIST) {
 [rootViewController.dayBookView.rightPageView.bodyView reloadSmartListData];
 }
 
 }
 
 [rootViewController stopSyncIndicator];
 }
 */

#pragma mark start new session

#pragma mark get data from server
-(void)getDataWithURL:(NSString*)urlstr{
	self.downloadAndParsePool = [[NSAutoreleasePool alloc] init];
	NSString *feedURLString = [urlstr  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	//printf("\n %s",[feedURLString UTF8String]);
	NSURLRequest *newURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:feedURLString]];
	NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:newURLRequest delegate:self];
	//self.rssConnection = [[[NSURLConnection alloc] initWithRequest:newURLRequest delegate:self] autorelease];
	self.rssConnection=connection;
	[connection release];
	
	NSAssert(self.rssConnection != nil, @"Failure to create URL connection.");
	
	if (parseKey==TD_GET_FOLDER_KEY) {
		//self.folderList=[NSMutableArray array];
		[self.folderList removeAllObjects];
	}
	
	if (parseKey==TD_GET_TASK_KEY) {
		//self.toodledoTaskList=[NSMutableArray array];
		[self.toodledoTaskList removeAllObjects];
	}
	
	if (parseKey==TD_GET_DELETED_TASK_KEY) {
		//self.toodledoDeletedTaskList=[NSMutableArray array];
		[self.toodledoDeletedTaskList removeAllObjects];
	}
	
	NSDateFormatter *dFmter= [[NSDateFormatter alloc] init];
	self.parseFormatter=dFmter;
	[dFmter release];
	
	//[self.parseFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"US"] autorelease]];
	[self.parseFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	
	[downloadAndParsePool release];
	self.downloadAndParsePool = nil;
	//parsedCount=0;
}

/*
 -(void)startCheckSyncSunccess{
 checkSyncSuccTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkSyncSunccess:) userInfo:nil repeats:YES];
 
 }
 
 -(void)checkSyncSunccess:(id)sender{
 //NSTimer *tmr=sender;
 
 //if (totalSteps<=currentStep) {
 [checkSyncSuccTimer invalidate];
 checkSyncSuccTimer=nil;
 
 successAlert=[[UIAlertView alloc] initWithTitle:@"Successfully!" 
 message:@"Your tasks have been successfully synced with Toodledo!"
 delegate:self.rootViewController
 cancelButtonTitle:nil 
 otherButtonTitles:nil];
 successAlert.tag=TOODLEDO_SYNC_SUCCES_TAG;
 [successAlert show];
 [successAlert release];
 
 [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(closeSuccesAlert:) userInfo:nil repeats:NO];
 
 //		NSDate *syncTime=[NSDate date];
 //		taskManager.currentSetting.toodledoSyncTime=syncTime;
 //		[taskManager.currentSetting update];
 
 //reset tasklist
 //		for (Task *task in taskManager.allTasksEventsAdes) {
 //			task.isFromSyncing=NO;
 //		}
 
 [taskManager refreshLocalNotificationForList:taskManager.allTasksEventsAdes];
 
 //}
 }
 */

#pragma mark Delete

- (void)dealloc {
	[rssConnection release];
    [xmlData release];
    [currentTask release];
	[currentCalendar release];
    [currentString release];
    [currentParseBatch release];
	
	if (checkSyncSuccTimer) {
		[checkSyncSuccTimer invalidate];
		checkSyncSuccTimer=nil;
	}
	
	[toodledoTaskList release];
	[folderList release];
	[parseFormatter release];
	[t2dTaskList release];
	[toodledoDeletedTaskList release];
	[errorMessage release];
	[rootViewController release];
	[accValueStr release];
	
    [super dealloc];
}

//----for downloading from server
#pragma mark NSURLConnection delegate methods

// The following are delegate methods for NSURLConnection. Similar to callback functions, this is how the connection object,
// which is working in the background, can asynchronously communicate back to its delegate on the thread from which it was
// started - in this case, the main thread.

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.xmlData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [xmlData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	//	 done = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    if ([error code] == kCFURLErrorNotConnectedToInternet) {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"No Connection Error",                             @"Error message displayed when not connected to the Internet.") forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain code:kCFURLErrorNotConnectedToInternet userInfo:userInfo];
        [self handleError:noConnectionError];
    } else {
        // otherwise handle the error generically
        [self handleError:error];
    }
    self.rssConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.rssConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    // Spawn a thread to fetch the image data so that the UI is not blocked while the application parses the XML data.
    //
    // IMPORTANT! - Don't access UIKit objects on secondary threads.
    //
	//   [NSThread detachNewThreadSelector:@selector(parseData:) toTarget:self withObject:xmlData];
	[self parseData:xmlData];
	
    // xmlData will be retained by the thread until parseData: has finished executing, so we no longer need
    // a reference to it in the main thread.
    self.xmlData = nil;
}

- (void)parseData:(NSData *)data {
    // You must create a autorelease pool for all secondary threads.
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    self.currentParseBatch = [NSMutableArray array];
    self.currentString = [NSMutableString string];
	
	//	printf("\n%s",[self.currentString UTF8String]);
    //
    // It's also possible to have NSXMLParser download the data, by passing it a URL, but this is not desirable
    // because it gives less control over the network, particularly in responding to connection errors.
    //
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];
	
    // depending on the total number of data parsed, the last batch might not have been a "full" batch, and thus
    // not been part of the regular batch transfer. So, we check the count of the array and, if necessary, send it to the main thread.
    if (!isError && [self.currentParseBatch count]>0 && parseKey==TD_GET_TASK_KEY) {
        [self performSelectorOnMainThread:@selector(addTaskToList:) withObject:self.currentParseBatch waitUntilDone:YES];
    }else if (!isError && [self.currentParseBatch count]>0 && parseKey==TD_GET_FOLDER_KEY) {
		[self performSelectorOnMainThread:@selector(addCalendarToList:) withObject:self.currentParseBatch waitUntilDone:YES];
	}else if (!isError && [self.currentParseBatch count]>0 && parseKey==TD_GET_DELETED_TASK_KEY) {
		[self performSelectorOnMainThread:@selector(addDeletedTasksToList:) withObject:self.currentParseBatch waitUntilDone:YES];
	}
		
	if(isError){
		if (isCheckingValidateAccount) {
			isCheckingValidateAccount=NO;
			isFinishedGetUserId=YES;
			goto endParse;
		}
		
		UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"" 
														  message:@"It appears as if you have not yet set up Task sync with Toodledo (please go to Settings -> Synchronization to setup before syncing) or your account is invalidated by Toodledo (try again later!)."
														 delegate:nil 
												cancelButtonTitle:@"Ok"
												otherButtonTitles:nil];
        printf("\n %s",[self.currentString UTF8String]);
		alertView.tag=TOODLEDO_ERROR_TAG;
		[alertView show];
		[alertView release];
		
	endParse:
		parseKey=TD_ERROR_KEY;
		isSyncing=NO;
		isSyncingTask=NO;
		[self.rootViewController hideStatusBar];
	}
	
	self.currentParseBatch = nil;
    self.currentTask = nil;
	self.currentCalendar=nil;
    self.currentString = nil;
    [parser release];        
    [pool release];
}


// Handle errors in the download or the parser by showing an alert to the user. This is a very simple way of handling the error,
// partly because this application does not have any offline functionality for the user. Most real applications should
// handle the error in a less obtrusive way and provide offline functionality to the user.
- (void)handleError:(NSError *)error {
	if(!didShowedConnectError){
		NSString *errorMessages = [error localizedDescription];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error!", @"Cannot download and parse data.") 
															message:errorMessages delegate:self.rootViewController 
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		alertView.tag=TOODLEDO_ERROR_TAG;
		[alertView show];
		[alertView release];
		didShowedConnectError=YES;
		//		[rootView stopAnimatingIndicator];
		
	}
	
	[self.rootViewController hideStatusBar];
	isSyncingTask=NO;
	isSyncing=NO;
}

// The secondary (parsing) thread calls addToimageList: on the main thread with batches of parsed objects. 
// The batch size is set via the kSizeOfimageBatch constant.
- (void)addTaskToList:(NSArray *)tasks {
	[self.toodledoTaskList addObjectsFromArray:tasks];
	if (self.toodledoTaskList.count==totalTasks || self.toodledoTaskList.count==MAX_SYNC_TASKS) {
		isFinishedGetTasks=YES;
		parseKey=TD_FREE_KEY;
	}
	
}

- (void)addCalendarToList:(NSArray *)calendars {
	[self.folderList addObjectsFromArray:calendars];
	isFinishedGetFolders=YES;
	parseKey=TD_FREE_KEY;
}

- (void)addDeletedTasksToList:(NSArray *)tasks {
	[self.toodledoDeletedTaskList addObjectsFromArray:tasks];
	isFinishedGetDeletedTasks=YES;
	parseKey=TD_FREE_KEY;
}

//

#pragma mark Parser constants

// Limit the number of parsed data to 1000.
static const const NSUInteger kMaximumNumberTasksToParse = 9000;

// When an image object has been fully constructed, it must be passed to the main thread and the table view 
// in RootViewController must be reloaded to display it. It is not efficient to do this for every image object -
// the overhead in communicating between the threads and reloading the table exceed the benefit to the user. Instead,
// we pass the objects in batches, sized by the constant below. In your application, the optimal batch size will vary 
// depending on the amount of data in the object and other factors, as appropriate.
static NSUInteger const kSizeOfItemInBatch = 100;


// Constants for the XML element names that will be considered during the parse. 
// Declaring these as static constants reduces the number of objects created during the run
// and is less prone to programmer error.

#pragma mark NSXMLParser Parsing UserId
static NSString *kName_UserId_Item = @"userid";

#pragma mark getAccountInfo
static NSString *kName_Account_Item=@"account";
static NSString *kName_UserAcc_TimeZone = @"timezone";
static NSString *kName_Last_Edit_Folder=@"lastedit_folder";
static NSString *kName_Last_Edit_Task=@"lastedit_task";
static NSString *kName_Last_Delete_Task=@"lastdelete_task";
static NSString *kName_Last_Edit_Note=@"lastedit_notebook";
static NSString *kName_Last_Delete_Note=@"lastdelete_notebook";

#pragma mark NSXMLParser Parsing Token
static NSString *kName_Token_Item = @"token";

#pragma mark NSXMLParser Parsing Folders
static NSString *kName_Folders_Item = @"folders";
static NSString *kName_Folder_Item = @"folder";
static NSString *kName_Folder_Id=@"id";
static NSString *kName_Folder_Name=@"name";
static NSString *kName_Folder_Archived=@"archived";

#pragma mark NSXMLParser Parsing Tasks
static NSString *kName_Tasks_Item = @"tasks";
static NSString *kName_Tasks_Deleted = @"deleted";
static NSString *kName_Task_Item = @"task";
static NSString *kName_Task_Id = @"id";
static NSString *kName_Task_Title = @"title";
static NSString *kName_Task_Tag = @"tag";
static NSString *kName_Task_Location=@"location";

static NSString *kName_Task_Folder = @"folder";
static NSString *kName_Task_Added = @"added";
static NSString *kName_Task_Modified = @"modified";

static NSString *kName_Task_StartDate = @"startdate";
static NSString *kName_Task_StartTime=@"starttime";

static NSString *kName_Task_Duedate = @"duedate";
static NSString *kName_Task_DueTime = @"duetime";

static NSString *kName_Task_Completed = @"completed";
static NSString *kName_Task_Repeat = @"repeat";
static NSString *kName_Task_Priority = @"priority";
static NSString *kName_Task_Star = @"star";
static NSString *kName_Task_Length = @"length";
static NSString *kName_Error = @"error";
static NSString *kName_Task_Notes=@"note";
static NSString *kName_Task_Stamp=@"stamp";
static NSString *kName_Task_RepeatFrom=@"repeatfrom";

#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	
    // If the number of parsed images is greater than kMaximumNumberTasksToParse, abort the parse.
	//1.2    if (parsedCount >= kMaximumNumberTasksToParse) {
	// Use the flag didAbortParsing to distinguish between this deliberate stop and other parser errors.
	//1.2        didAbortParsing = YES;
	//1.2        [parser abortParsing];
	//1.2    }
	
	//	printf("\nstart: %s",[elementName UTF8String]);
	
	switch (parseKey) {
		case TD_GET_USER_ID:
		{
			if ([elementName isEqualToString:kName_UserId_Item]
				|| [elementName isEqualToString:kName_Error]) {
				accumulatingParsedCharacterData = YES;
				[self.currentString setString:@""];
			}
		}
			break;
		case  TD_GET_SERVER_INFO:
		{
			if ([elementName isEqualToString:kName_UserAcc_TimeZone]
				|| [elementName isEqualToString:kName_Error]
				|| [elementName isEqualToString:kName_Last_Edit_Folder]
				|| [elementName isEqualToString:kName_Last_Edit_Task]
				|| [elementName isEqualToString:kName_Last_Delete_Task]
				|| [elementName isEqualToString:kName_Last_Edit_Note]
				|| [elementName isEqualToString:kName_Last_Delete_Note]) {
				accumulatingParsedCharacterData = YES;
				[self.currentString setString:@""];
			}
			
		}
			break;
			
		case TD_GET_TOKEN:
		{
			if ([elementName isEqualToString:kName_Token_Item]
				|| [elementName isEqualToString:kName_Error]) {
				accumulatingParsedCharacterData = YES;
				[self.currentString setString:@""];
			}
		}
			break;
		case TD_GET_FOLDER_KEY:
		{
			if( [elementName isEqualToString:kName_Folder_Item]
			   || [elementName isEqualToString:kName_Error]){
				Projects *cal=[[Projects alloc] init];
				self.currentCalendar=cal;
				[cal release];
				
				//if(self.currentString){ 
				//[self.currentString release];
				//	self.currentString=nil;
				
				//}
				//self.currentString=[NSMutableString string];
				//accumulatingParsedCharacterData = YES;
				
			}else if ([elementName isEqualToString:kName_Folders_Item]
					  || [elementName isEqualToString:kName_Folder_Id]
					  || [elementName isEqualToString:kName_Folder_Name]
					  || [elementName isEqualToString:kName_Folder_Archived]
					  || [elementName isEqualToString:kName_Error]){
				
				accumulatingParsedCharacterData = YES;
				[self.currentString setString:@""];
			}
		}
			break;
		case TD_GET_TASK_KEY://task elements
		{
			if ([elementName isEqualToString:kName_Tasks_Item]){
				NSString *totalTask=[attributeDict objectForKey:@"num"];
				totalTasks=[totalTask intValue];
				if (totalTasks==0) {
					isFinishedGetTasks=YES;
					parseKey=TD_FREE_KEY;
				}
			}else if ([elementName isEqualToString:kName_Task_Item]){
				Task *task = [[Task alloc] init];
				self.currentTask = task;
				[task release];
			}else if ([elementName isEqualToString:kName_Task_Title]
					  || [elementName isEqualToString:kName_Task_Id] 
					  || [elementName isEqualToString:kName_Task_Tag] 
					  || [elementName isEqualToString:kName_Task_Location]
					  || [elementName isEqualToString:kName_Task_Folder] 
					  || [elementName isEqualToString:kName_Task_Added] 
					  || [elementName isEqualToString:kName_Task_Modified]
					  || [elementName isEqualToString:kName_Task_Duedate]
					  || [elementName isEqualToString:kName_Task_DueTime]
					  || [elementName isEqualToString:kName_Task_Completed]
					  || [elementName isEqualToString:kName_Task_Repeat]
					  || [elementName isEqualToString:kName_Task_Priority]
					  || [elementName isEqualToString:kName_Task_Length]
					  || [elementName isEqualToString:kName_Error]
					  || [elementName isEqualToString:kName_Task_StartDate]
					  || [elementName isEqualToString:kName_Task_StartTime]
					  || [elementName isEqualToString:kName_Task_Notes]
					  || [elementName isEqualToString:kName_Task_Star]
					  || [elementName isEqualToString:kName_Task_RepeatFrom]) {
				
				accumulatingParsedCharacterData = YES;
				[self.currentString setString:@""];
			}	
			
		}
			break;
		case TD_GET_DELETED_TASK_KEY:
		{
			if ([elementName isEqualToString:kName_Task_Item]) {
				TDDeletedTaskObject *obj=[[TDDeletedTaskObject alloc] init];
				self.currentDeletedTask=obj;
				[obj release];
			}else if ([elementName isEqualToString:kName_Tasks_Deleted]){
				NSString *totalTask=[attributeDict objectForKey:@"num"];
				totalDeletedTasks=[totalTask intValue];
				if (totalDeletedTasks==0) {
					isFinishedGetDeletedTasks=YES;
					parseKey=TD_FREE_KEY;
				}else {
					accumulatingParsedCharacterData = YES;
					[self.currentString setString:@""];
				}
				
			}else if ([elementName isEqualToString:kName_Task_Id]
					  ||[elementName isEqualToString:kName_Task_Stamp]){
				
				accumulatingParsedCharacterData = YES;
				[self.currentString setString:@""];
			}
		}
			break;
			
		default:
		{
			parseKey=TD_FREE_KEY;
 		}
			break;
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {     
	
	switch (parseKey) {
		case TD_GET_USER_ID:
		{
			if ([elementName isEqualToString:kName_UserId_Item]) {
				if (!isCheckingValidateAccount) {
					taskManager.currentSetting.toodledoUserId =self.currentString;
					[taskManager.currentSetting update];
				}
				self.accValueStr=self.currentString;
				isFinishedGetUserId=YES;
				isCheckingValidateAccount=NO;
				parseKey=TD_FREE_KEY;
			}else if([elementName isEqualToString:kName_Error]){
				isError=YES;
				self.errorMessage=self.currentString;
			}
		}
			break;
		case  TD_GET_SERVER_INFO:
		{
			if ([elementName isEqualToString:kName_UserAcc_TimeZone]) {
				timeZone=[self.currentString intValue];
			}else if([elementName isEqualToString:kName_Last_Edit_Folder]){
				
				self.TDLastEditFolderDateTime=[NSDate dateWithTimeIntervalSince1970:[self.currentString doubleValue]-gmtSeconds];
				
			}else if([elementName isEqualToString:kName_Last_Edit_Task]){
				
				self.TDLastEditTaskDateTime=[NSDate dateWithTimeIntervalSince1970:[self.currentString doubleValue]];
				
			}else if([elementName isEqualToString:kName_Last_Delete_Task]){
				
				self.TDLastDeleteTaskDateTime=[NSDate dateWithTimeIntervalSince1970:[self.currentString doubleValue]];
				
			}else if([elementName isEqualToString:kName_Last_Edit_Note]){
				
				self.TDLastEditNoteDateTime=[NSDate dateWithTimeIntervalSince1970:[self.currentString doubleValue]];
				
			}else if([elementName isEqualToString:kName_Last_Delete_Note]){
				
				self.TDLastDeleteNoteDateTime=[NSDate dateWithTimeIntervalSince1970:[self.currentString doubleValue]];
				
			}else if([elementName isEqualToString:kName_Account_Item]){
				isFinishedGetAccountInfo=YES;
				parseKey=TD_FREE_KEY;
			}else if([elementName isEqualToString:kName_Error]){
				isError=YES;
				self.errorMessage=self.currentString;
			}
			
			break;
		}
		case TD_GET_TOKEN:
		{
			if ([elementName isEqualToString:kName_Token_Item]) {
				taskManager.currentSetting.toodledoToken =self.currentString;//sesson token
				if([taskManager.currentSetting.toodledoToken length]>0){
					taskManager.currentSetting.toodledoTokenTime=[NSDate date];
					taskManager.currentSetting.toodledoKey=[NSString stringWithString:[self md5:[[[self md5:taskManager.currentSetting.toodledoPassword] stringByAppendingString:@"api4ce0ace4e5406"] stringByAppendingString:taskManager.currentSetting.toodledoToken]]];
					[taskManager.currentSetting update];
				}
				
				isFinishedGetToken=YES;
				
				parseKey=TD_FREE_KEY;
				
			}else if([elementName isEqualToString:kName_Error]){
				isError=YES;
				self.errorMessage=self.currentString;
			}
		}
			break;
		case TD_GET_FOLDER_KEY:
		{
			if ([elementName isEqualToString:kName_Folder_Id]){
				
				self.currentCalendar.toodledoFolderKey=[self.currentString intValue];
				
			}else if ([elementName isEqualToString:kName_Folder_Name]){
				
				self.currentCalendar.projName=self.currentString;
				
			}else if ([elementName isEqualToString:kName_Folder_Archived]){
				
				//self.currentCalendar.isArchived=[self.currentString boolValue];
				
			}else if([elementName isEqualToString:kName_Folders_Item]) {
				
				[self performSelectorOnMainThread:@selector(addCalendarToList:) withObject:self.currentParseBatch waitUntilDone:YES];
				self.currentParseBatch = [NSMutableArray array];
				
			}else if([elementName isEqualToString:kName_Folder_Item] ){
				
				[self.currentParseBatch addObject:self.currentCalendar];
				
			}else if([elementName isEqualToString:kName_Error]){
				isError=YES;
				self.errorMessage=self.currentString;
			}
		}
			break;
		case TD_GET_TASK_KEY://task elements
		{
			if([elementName isEqualToString:kName_Error]){
				isError=YES;
				self.errorMessage=self.currentString;
			}else if([elementName isEqualToString:kName_Task_Item]){
				[self.currentParseBatch addObject:self.currentTask];
			}else if([elementName isEqualToString:kName_Tasks_Item]){
				[self performSelectorOnMainThread:@selector(addTaskToList:) withObject:self.currentParseBatch waitUntilDone:YES];
				self.currentParseBatch = [NSMutableArray array];
			}else if ([elementName isEqualToString:kName_Task_Id]) {
				self.currentTask.toodledoID = [self.currentString intValue];
			}else if ([elementName isEqualToString:kName_Task_Title]) {
				self.currentTask.taskName =self.currentString;
			}else if([elementName isEqualToString:kName_Task_Location]) {
				if ([self.currentString isEqualToString:@"0"]) {
					self.currentTask.taskLocation=@"";
				}else {
					self.currentTask.taskLocation=self.currentString;
				}
			}else if ([elementName isEqualToString:kName_Task_Folder]) {
				//set default calendar is first
				self.currentTask.taskProject=taskManager.currentSetting.defaultProjectId;
				for (Projects *cal in projectList) {
					if (cal.toodledoFolderKey==[self.currentString intValue]) {
						self.currentTask.taskProject = cal.primaryKey;
						self.currentTask.isHidden=cal.inVisible;
						break;
					}
				}			
			}else if ([elementName isEqualToString:kName_Task_Added]) {
				self.currentTask.createdDate =[NSDate dateWithTimeIntervalSince1970:[self.currentString doubleValue]-gmtSeconds];
				if (!self.currentTask.toodledoHasStart) {
					self.currentTask.taskNotEalierThan=self.currentTask.createdDate;
				}
			}else if ([elementName isEqualToString:kName_Task_Modified]) {
				self.currentTask.taskDateUpdate = [NSDate dateWithTimeIntervalSince1970:[self.currentString doubleValue]-gmtSeconds];
			}else if ([elementName isEqualToString:kName_Task_Duedate]) {
				if ([self.currentString doubleValue]==0.0) {
					self.currentTask.taskIsUseDeadLine=NO;
				}else{
					self.currentTask.taskIsUseDeadLine=YES;
					self.currentTask.taskDeadLine =[NSDate dateWithTimeIntervalSince1970:[self.currentString doubleValue]-gmtSeconds]; 
				}
			}else if ([elementName isEqualToString:kName_Task_DueTime]) {
				if([self.currentString doubleValue]>0){
					NSDate *dueTime=[NSDate dateWithTimeIntervalSince1970:[self.currentString doubleValue]-gmtSeconds]; 
					if (self.currentTask.taskIsUseDeadLine) {
						self.currentTask.taskDeadLine=[ivo_Utilities resetTime4Date:self.currentTask.taskDeadLine 
																		  hour:[ivo_Utilities getHour:dueTime]
																		minute:[ivo_Utilities getMinute:dueTime] 
																		second:[ivo_Utilities getSecond:dueTime]];
					}
				}
			}else if([elementName isEqualToString:kName_Task_StartDate]) {
				if ([self.currentString doubleValue]>0) {
					self.currentTask.toodledoHasStart=YES;
					self.currentTask.taskNotEalierThan = [NSDate dateWithTimeIntervalSince1970:[self.currentString doubleValue]-gmtSeconds]; 
				}else {
					self.currentTask.toodledoHasStart=NO;
					self.currentTask.taskNotEalierThan=self.currentTask.createdDate;
				}
			}else if([elementName isEqualToString:kName_Task_StartTime]) {
				if([self.currentString doubleValue]>0){
					NSDate *startTime=[NSDate dateWithTimeIntervalSince1970:[self.currentString doubleValue]-gmtSeconds]; 
					self.currentTask.taskNotEalierThan=[taskManager updateTimeFromString:self.currentString forDate:self.currentTask.taskNotEalierThan];
					self.currentTask.taskNotEalierThan=[ivo_Utilities resetTime4Date:self.currentTask.taskNotEalierThan 
																		hour:[ivo_Utilities getHour:startTime]
																	  minute:[ivo_Utilities getMinute:startTime] 
																	  second:[ivo_Utilities getSecond:startTime]];
				}
			}else if ([elementName isEqualToString:kName_Task_Completed]) {
				if([self.currentString doubleValue]>0){
					self.currentTask.taskDateUpdate=[NSDate dateWithTimeIntervalSince1970:[self.currentString doubleValue]-gmtSeconds]; 
					self.currentTask.taskCompleted=1;
				}else {
					self.currentTask.taskCompleted=0;
				}
				
			}else if ([elementName isEqualToString:kName_Task_Notes]) {
				self.currentTask.taskDescription=self.currentString; 
			}else if ([elementName isEqualToString:kName_Task_Repeat]) {
				//NSInteger repeatType=[self.currentString intValue];
                printf("\n%s",[self.currentString UTF8String]);

				[taskManager setRepeatForTask:self.currentTask fromTDRule:self.currentString];
                
			}else if([elementName isEqualToString:kName_Task_RepeatFrom]) {
				if ([self.currentString intValue]==1) {
					self.currentTask.taskRepeatID= FROM_COMPLETION;//REPEAT_AFTER_DONE;
				}else{
                    self.currentTask.taskRepeatID= FROM_DUE;
                }
			}else if ([elementName isEqualToString:kName_Task_Length]) {
				if ([self.currentString intValue]>0) {
					self.currentTask.taskHowLong=[self.currentString intValue];
				}else {
					self.currentTask.hasDuration=0;
				}
			}else if ([elementName isEqualToString:kName_Task_Star]) {
				NSInteger star=[self.currentString intValue];
				self.currentTask.isPinned=star;
			}
		}
			break;
		case TD_GET_DELETED_TASK_KEY:
		{
			if([elementName isEqualToString:kName_Error]){
				isError=YES;
				self.errorMessage=self.currentString;
			}else if([elementName isEqualToString:kName_Task_Item]){
				[self.currentParseBatch addObject:self.currentDeletedTask];
			}else if([elementName isEqualToString:kName_Tasks_Deleted]){
				[self performSelectorOnMainThread:@selector(addDeletedTasksToList:) withObject:self.currentParseBatch waitUntilDone:YES];
				self.currentParseBatch = [NSMutableArray array];
			}else if([elementName isEqualToString:kName_Task_Id]){ 
				self.currentDeletedTask.taskId=[self.currentString intValue];
			}else if([elementName isEqualToString:kName_Task_Stamp]){ 
				self.currentDeletedTask.deletedTimeInterVal=[self.currentString doubleValue];
			}
		}
			break;
	}
	
	
    // Stop accumulating parsed character data. We won't start again until specific elements begin.
    accumulatingParsedCharacterData = NO;
} 

// This method is called by the parser when it find parsed character data ("PCDATA") in an element. The parser is not
// guaranteed to deliver all of the parsed character data for an element in a single invocation, so it is necessary to
// accumulate character data until the end of the element is reached.
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (accumulatingParsedCharacterData) {
        // If the current element is one whose content we care about, append 'string'
        // to the property that holds the content of the current element.
        [self.currentString appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    // If the number of image records received is greater than kMaximumNumberTasksToParse, we abort parsing.
    // The parser will report this as an error, but we don't want to treat it as an error. The flag didAbortParsing is
    // how we distinguish real errors encountered by the parser.
    if (didAbortParsing == NO) {
        // Pass the error to the main thread for handling.
        [self performSelectorOnMainThread:@selector(handleError:) withObject:parseError waitUntilDone:NO];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
	
}

@end
