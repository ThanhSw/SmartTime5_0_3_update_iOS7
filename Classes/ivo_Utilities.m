//
//  ivo_Utilities.m
//  iVo_DatabaseAccess
//
//  Created by Nang Le on 5/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ivo_Utilities.h"
#import "IvoCommon.h"
#import "Setting.h"
#import "Task.h"
#import "Projects.h"
#import "SmartTimeAppDelegate.h"
#import "DateTimeSlot.h"
#import "Alert.h"
#import "TaskActionResult.h"
#import "ServerAlertInfo.h"
#import "ColorObject.h"
#import "EKSync.h"
#import "ReminderSync.h"

//#import "GCal2ProjMap.h"

//extern Setting		*currentSetting;
extern TaskManager	*taskmanager;
extern BOOL _is24HourFormat;
extern NSTimeInterval dstOffset;
extern ivo_Utilities *ivoUtility;
extern NSTimeZone *App_defaultTimeZone;
extern NSString		*dev_token;
extern BOOL	isInternetConnected;
extern float OSVersion;
extern NSString *startTimeIsLaterEndTimeText;
extern NSMutableArray *projectList;

extern BOOL    needStopSync;

/*
extern CGFloat _project0Colors[2][3];
extern CGFloat _project0Colors[2][3];
extern CGFloat _project1Colors[2][3];
extern CGFloat _project2Colors[2][3];
extern CGFloat _project3Colors[2][3];
extern CGFloat _project4Colors[2][3];
extern CGFloat _project5Colors[2][3];

extern CGFloat _project6Colors[2][3];
extern CGFloat _project7Colors[2][3];
extern CGFloat _project8Colors[2][3];
extern CGFloat _project9Colors[2][3];
extern CGFloat _project10Colors[2][3];
extern CGFloat _project11Colors[2][3];

extern CGFloat _project12Colors[2][3];
extern CGFloat _project13Colors[2][3];
extern CGFloat _project14Colors[2][3];
extern CGFloat _project15Colors[2][3];
extern CGFloat _project16Colors[2][3];
extern CGFloat _project17Colors[2][3];

extern CGFloat _project18Colors[2][3];
extern CGFloat _project19Colors[2][3];
extern CGFloat _project20Colors[2][3];
*/

extern CGFloat _otherColors[2][3];

extern NSString* _gcalProjectColors[21];

extern CGFloat _eventColors[2][3];

extern CGFloat _outlineColors[MAXDUE][3];

extern int _outlineWidths[MAXDUE];

extern CGFloat _dynamicLineColor[3];

extern CGFloat _shadowColor[3];

extern CGFloat _homeColor[3];

extern CGFloat _timeSlotColor[3];

extern int _boxHWHeights[MAXDURATION];
extern int _boxFWHeights[MAXDURATION];

#pragma mark number
extern double timeInervalForExpandingToFillRE;

BOOL _startDayAsMonday = NO;

NSString* _dayNamesMon[7] = {@"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat", @"Sun"};
NSString* _dayNamesSun[7] = {@"Sun", @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat"};
NSString* _monthNames[12] = {@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"};

@implementation ivo_Utilities

#pragma ma- (rk Common uses
-(id)init{
	self=[super init];
	return self;
}

-(void) dealloc{
	[super dealloc];
}

- (NSInteger)getIndexOfTaskByPrimaryKey:(Task *)task inArray:(NSMutableArray *)list {
	//ILOG(@"[ivo_Utilities getIndexOfTaskByPrimaryKey\n");
    NSMutableArray *arr=[NSMutableArray arrayWithArray:list];
    
	Task *taskMember;
	NSInteger i=0;
	for (taskMember in arr){
		if (taskMember.primaryKey==task.primaryKey){
			taskMember=nil;
			//ILOG(@"ivo_Utilities getIndexOfTaskByPrimaryKey]\n");
			return i;	
		}
		i++;
	}
	//ILOG(@"ivo_Utilities getIndexOfTaskByPrimaryKey]\n");
	return -1;
}

- (Task *)getTaskByPrimaryKey:(NSInteger)key inArray:(NSMutableArray *)list {
	//ILOG(@"[ivo_Utilities getTaskByPrimaryKey\n");
    NSMutableArray *arr=[NSMutableArray arrayWithArray:list];
	Task *taskMember;
	//[self printTask:list];
	for (taskMember in arr){
		if (taskMember.primaryKey==key){
			//ILOG(@"ivo_Utilities getTaskByPrimaryKey]\n");
			return taskMember;	
		}
	}
	//ILOG(@"ivo_Utilities getTaskByPrimaryKey]\n");
	return nil;
}

- (Task *)getTaskBySyncKey:(double)syncKey inArray:(NSMutableArray *)list {
	//ILOG(@"[ivo_Utilities getTaskByPrimaryKey\n");
	Task *taskMember;
	//[self printTask:list];
    NSMutableArray *arr=[NSMutableArray arrayWithArray:list];
    
	for (taskMember in arr){

		double diff = taskMember.taskSynKey - syncKey;
		
		if (diff < 0)
		{
			diff = diff *(-1);
		}
		
		if (diff < 0.001)
		{
			//ILOG(@"ivo_Utilities getTaskByPrimaryKey]\n");
			return taskMember;	
		}
	}
	//ILOG(@"ivo_Utilities getTaskByPrimaryKey]\n");
	return nil;
}

- (Task *)getTaskByEventID:(NSString *)eventId inArray:(NSMutableArray *)list {
	//ILOG(@"[ivo_Utilities getTaskByPrimaryKey\n");
	
	if (eventId == nil)
	{
		return nil;
	}
	
	Task *taskMember;
	//[self printTask:list];
    NSMutableArray *arr=[NSMutableArray arrayWithArray:list];
    
	for (taskMember in arr){
		NSRange range = [taskMember.gcalEventId rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"®"] options:NSBackwardsSearch];
		
		if (range.location != NSNotFound && [[taskMember.gcalEventId substringToIndex:range.location] isEqualToString:eventId])
		{
			
			return taskMember;	
		}
	}
	//ILOG(@"ivo_Utilities getTaskByPrimaryKey]\n");
	return nil;
}

- (NSInteger) getIndex: (NSMutableArray*) tasks: (NSInteger) taskKey{
	//ILOG(@"[ivo_Utilities getIndex\n");
    NSMutableArray *arr=[NSMutableArray arrayWithArray:tasks];
    
	NSInteger ret = -1;
	for (int i = 0; i < arr.count; i++)
	{
		if ([[arr objectAtIndex:i] primaryKey] == taskKey)
		{
			ret = i;
			//ILOG(@"ivo_Utilities getIndex]\n");
			return ret;
		}
	}
	//ILOG(@"ivo_Utilities getIndex]\n");
	return ret;
}


//From Nang's code

- (void) printTask: (NSMutableArray*) tasks{
	printf ("Print task list\n");
    
    NSMutableArray *arr=[NSMutableArray arrayWithArray:tasks];
	Task *taskTmp;
	for (taskTmp in arr){
		printf("tas key: (%d) syncKey: (%lf) name: (%s) pinch (%d) Start: (%s), Duration: (%d), completed:%d,isAllDay: %d,event link: %s, update date: %s, project:%d, parent id:%d\n", 
			   taskTmp.primaryKey, taskTmp.taskSynKey, [taskTmp.taskName UTF8String], taskTmp.taskPinned, 
			   [[taskTmp.taskStartTime description] UTF8String], taskTmp.taskHowLong,taskTmp.taskCompleted,taskTmp.isAllDayEvent,[taskTmp.gcalEventId UTF8String],[[taskTmp.taskDateUpdate description] UTF8String], taskTmp.taskProject, taskTmp.parentRepeatInstance);
	}
	
}

/*
- (NSInteger)getYear:(NSDate *)date{
	if (date==nil) return -1;
	NSString *fullDateStr = [date description];
	NSArray *fullDateComps=[NSArray arrayWithArray:[fullDateStr componentsSeparatedByString:@" "]];
	NSString *dateCompsStr=[fullDateComps objectAtIndex:0];
	NSArray *dateComps=[NSArray arrayWithArray:[dateCompsStr componentsSeparatedByString:@"-"]];
	return [[dateComps objectAtIndex:0] integerValue]; 
}

- (NSInteger)getMonth:(NSDate *)date{
	if (date==nil) return -1;
	NSString *fullDateStr = [date description];
	NSArray *fullDateComps=[NSArray arrayWithArray:[fullDateStr componentsSeparatedByString:@" "]];
	NSString *dateCompsStr=[fullDateComps objectAtIndex:0];
	NSArray *dateComps=[NSArray arrayWithArray:[dateCompsStr componentsSeparatedByString:@"-"]];
	return [[dateComps objectAtIndex:1] integerValue]; 
}

- (NSInteger)getDay:(NSDate *)date{
	if (date==nil) return -1;
	NSString *fullDateStr = [date description];
	NSArray *fullDateComps=[NSArray arrayWithArray:[fullDateStr componentsSeparatedByString:@" "]];
	NSString *dateCompsStr=[fullDateComps objectAtIndex:0];
	NSArray *dateComps=[NSArray arrayWithArray:[dateCompsStr componentsSeparatedByString:@"-"]];
	return [[dateComps objectAtIndex:2] integerValue]; 
}

- (NSString *)createWeekDayName: (NSDate *)date{
   	if (date==nil) return nil;
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterFullStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	NSString *dateStr = [dateFormatter stringFromDate:date];
	NSArray *dateComp=[NSArray arrayWithArray:[dateStr componentsSeparatedByString:@" "]];
	[dateFormatter release];
	return [[[dateComp objectAtIndex:0] substringToIndex:3] copy];  	
}
 
- (NSString *)createMonthName: (NSDate *)date{
	//ILOG(@"[ivo_Utilities createMonthName\n");
   	if (date==nil) return nil;
	NSDateFormatter *dateFormatterM = [[NSDateFormatter alloc] init];
	[dateFormatterM setDateStyle:NSDateFormatterFullStyle];
	[dateFormatterM setTimeStyle:NSDateFormatterNoStyle];
	NSString *dateStrM = [dateFormatterM stringFromDate:date];
	NSArray *dateCompM=[NSArray arrayWithArray:[dateStrM componentsSeparatedByString:@" "]];
	[dateFormatterM release];
	//ILOG(@"ivo_Utilities createMonthName]\n");
	return [[[dateCompM objectAtIndex:1] substringToIndex:3] copy];  	
}

- (NSInteger)getHour:(NSDate *)date{
	//ILOG(@"[ivo_Utilities getHour\n");
	if (date==nil) return -1;
	NSString *fullDateStr = [date description];
	NSArray *fullDateComps=[NSArray arrayWithArray:[fullDateStr componentsSeparatedByString:@" "]];
	NSString *timeCompsStr=[fullDateComps objectAtIndex:1];
	NSArray *timeComps=[NSArray arrayWithArray:[timeCompsStr componentsSeparatedByString:@":"]] ;
	//ILOG(@"ivo_Utilities getHour]\n");
	return  [[timeComps objectAtIndex:0] integerValue]; 
}
*/

/*
- (NSInteger)getHourWithAMPM:(NSDate *)date{
	//ILOG(@"[ivo_Utilities getHourWithAMPM\n");
	if (date==nil) return -1;
	NSString *fullDateStr = [date description];
	NSArray *fullDateComps=[NSArray arrayWithArray:[fullDateStr componentsSeparatedByString:@" "]];
	NSString *timeCompsStr=[fullDateComps objectAtIndex:1];
	NSArray *timeComps=[NSArray arrayWithArray:[timeCompsStr componentsSeparatedByString:@":"]] ;
	NSInteger hour=[[timeComps objectAtIndex:0] integerValue]; 
	if (hour>12){
		hour=hour-12;
	}else {
		if (hour==0){
			hour=12;
		}
	}
	//ILOG(@"ivo_Utilities getHourWithAMPM]\n");
	return hour;	
}

- (NSString *)createAMPM:(NSDate *)date{
	if([self getHour:date]>=12){
		return @"PM";
	}
	return @"AM";
}

- (NSInteger)getMinute:(NSDate *)date{
	if (date==nil) return -1;
	NSString *fullDateStr = [date description];
	NSArray *fullDateComps=[NSArray arrayWithArray:[fullDateStr componentsSeparatedByString:@" "]];
	NSString *timeCompsStr=[fullDateComps objectAtIndex:1];
	NSArray *timeComps=[NSArray arrayWithArray:[timeCompsStr componentsSeparatedByString:@":"]] ;
	return [[timeComps objectAtIndex:1] integerValue]; 
}


- (NSInteger)getSecond:(NSDate *)date{
	if (date==nil) return -1;
	NSString *fullDateStr = [date description];
	NSArray *fullDateComps=[NSArray arrayWithArray:[fullDateStr componentsSeparatedByString:@" "]];
	NSString *timeCompsStr=[fullDateComps objectAtIndex:1];
	NSArray *timeComps=[NSArray arrayWithArray:[timeCompsStr componentsSeparatedByString:@":"]] ;
	return [[timeComps objectAtIndex:2] integerValue]; 
}
*/

//
//getShortStringFromDate
//get full date string from a given date. Ex: "Jul 7"
- (NSString *)getShortStringFromDate:(NSDate *) date{
	//ILOG(@"[ivo_Utilities createStringFromDate\n");
	NSString *monthname=[self createMonthName:date];
	NSString *ret=[NSString stringWithFormat:@"%@ %02d",monthname,[self getDay:date] ];
	[monthname release];
	//ILOG(@"ivo_Utilities createStringFromDate]\n");
	return ret;	
}

-(NSString *)getLongStringFromDate:(NSDate *)date{
	NSString *shortDate=[self createStringFromShortDate:date];
	NSString *ret=[NSString stringWithFormat:@"%@ %@",shortDate,[self getTimeStringFromDate:date]];
	[shortDate release];
	return ret;
}

//get full date string from a given date. Ex: "Fri Jul 7, 2008" or "Fri Jul 7, 2008 10:00AM"
- (NSString *)createStringFromDate:(NSDate *) date isIncludedTime:(BOOL)isTime{
	//ILOG(@"[ivo_Utilities createStringFromDate\n");
	NSString *wdayname=[self createWeekDayName:date];
	NSString *monthname=[self createMonthName:date];
	NSString *ap=[self createAMPM:date];
	NSString *ret=nil;
	
	if(date !=nil){
		if(isTime){
			if(_is24HourFormat){
	/*		ret= [[[[wdayname  stringByAppendingString:@ " "] stringByAppendingString: 
				  monthname] stringByAppendingString:
				  [NSString stringWithFormat:@" %02d, %2d  %02d:%02d",
				   [self getDay:date],
				   [self getYear:date],
				   [self getHour:date],
				   [self getMinute:date]]] copy];	
	*/
				ret=[[NSString stringWithFormat:@"%@ %@ %02d, %2d  %02d:%02d",
					 wdayname,
					 monthname,
					 [self getDay:date],
					 [self getYear:date],
					 [self getHour:date],
					 [self getMinute:date]] copy];
			}else {
	/*			ret= [[[[[wdayname  stringByAppendingString:@ " "] stringByAppendingString: 
						 monthname] stringByAppendingString:
						[NSString stringWithFormat:@" %02d, %2d  %02d:%02d",
						 [self getDay:date],
						 [self getYear:date],
						 [self getHourWithAMPM:date],
						 [self getMinute:date]]] stringByAppendingString:ap] copy];	
	*/
				ret=[[NSString stringWithFormat:@"%@ %@ %02d, %2d  %02d:%02d%@",
					  wdayname,
					  monthname,
					  [self getDay:date],
					  [self getYear:date],
					   [self getHourWithAMPM:date],
					  [self getMinute:date],
					  ap] copy];
			}

		}else{
		/*	
			ret= [[[[wdayname stringByAppendingString:@ " "] stringByAppendingString: 
				  monthname] stringByAppendingString:
				  [NSString stringWithFormat:@" %02d, %02d",
				   [self getDay:date],
				   [self getYear:date]]] copy];	
		*/
			ret=[[NSString stringWithFormat:@"%@ %@ %02d, %2d",
				  wdayname,
				  monthname,
				  [self getDay:date],
				  [self getYear:date]] copy];
		}
	}
	[ap release];
	[wdayname release];
	[monthname release];
	//ILOG(@"ivo_Utilities createStringFromDate]\n");
	return ret;	
}

- (NSString *)createStringFromShortDate:(NSDate *) date {
	//ILOG(@"[ivo_Utilities createStringFromDate\n");
	NSString *ret=nil;
	if(date !=nil){
			ret= [[NSString stringWithFormat:@"%02d-%02d-%02d",
					 [self getYear:date],
					 [self  getMonth:date],
					 [self getDay:date]] copy];	
	}
	//ILOG(@"ivo_Utilities createStringFromDate]\n");
	return ret;	
}

- (NSString *)getStringFromShortDate:(NSDate *) date {
	//ILOG(@"[ivo_Utilities createStringFromDate\n");
	NSString *ret=nil;
	if(date !=nil){
		ret= [NSString stringWithFormat:@"%02d-%02d-%02d",
			   [self getYear:date],
			   [self  getMonth:date],
			   [self getDay:date]];	
	}
	//ILOG(@"ivo_Utilities createStringFromDate]\n");
	return ret;	
}

//get time string from a given date. Ex: "11:00 AM"
- (NSString *)createTimeStringFromDate:(NSDate *) date{
	//ILOG(@"[ivo_Utilities createTimeStringFromDate\n");
	NSString *ret=nil;//[[NSString alloc] initWithString:@""];
	NSString *ap=[self createAMPM:date];
	
	if(date !=nil){
		if(_is24HourFormat){
			ret= [[NSString stringWithFormat:@"%02d:%02d ",
					[self getHour:date],
					[self getMinute:date]] copy];	
		}else {
			ret= [[[NSString stringWithFormat:@"%02d:%02d ",
					[self getHourWithAMPM:date],
					[self getMinute:date]] stringByAppendingString:ap] copy];	
		}

	}
	[ap release];
	//ILOG(@"ivo_Utilities createTimeStringFromDate]\n");
	return ret;	
	
}

//get time string from a given date. Ex: "11:00 AM"
- (NSString *)getTimeStringFromDate:(NSDate *) date{
	//ILOG(@"[ivo_Utilities createTimeStringFromDate\n");
	NSString *ret=nil;//[[NSString alloc] initWithString:@""];
	NSString *ap=[self getShortAMPM:date];
	
	if(date !=nil){
		if(_is24HourFormat){
			ret= [NSString stringWithFormat:@"%02d:%02d",
				   [self getHour:date],
				   [self getMinute:date]] ;	
		}else {
			ret= [[NSString stringWithFormat:@"%02d:%02d",
					[self getHourWithAMPM:date],
					[self getMinute:date]] stringByAppendingString:ap];	
		}
		
	}
	//ILOG(@"ivo_Utilities createTimeStringFromDate]\n");
	return ret;	
	
}

//get a date string from a given date. Ex: "Fri Jul 7, 2008"
- (NSString *)createCurrentDateInfo{
	//ILOG(@"[ivo_Utilities createCurrentDateInfo\n");
	NSDate *date=[NSDate date];
	NSString * wdayname = [self createWeekDayName:date];
	NSString * monthname = [self createMonthName:date];
	
	NSString * ret = [[[[wdayname stringByAppendingString:@ " "] stringByAppendingString: 
					   monthname] stringByAppendingString:
					  [NSString stringWithFormat:@" %02d, %2d",
					   [self getDay:date],
					   [self getYear:date]]] copy];
	[wdayname release];
	[monthname release];
	//ILOG(@"ivo_Utilities createCurrentDateInfo]\n");
	return ret;
}

////////////////
- (NSInteger)getYear:(NSDate *)date{
	//ILOG(@"[ivo_Utilities getYear\n");
	if (date==nil) return -1;
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dayComponents =[gregorian components:NSYearCalendarUnit fromDate:date];
	NSInteger year = [dayComponents year];
	//printf("\n year: %d",year);
	[gregorian release];
	//ILOG(@"ivo_Utilities getYear]\n");
	return year; 
}

- (NSInteger)getMonth:(NSDate *)date{
	//ILOG(@"[ivo_Utilities getMonth\n");
	if (date==nil) return -1;
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dayComponents =[gregorian components:NSMonthCalendarUnit fromDate:date];
	NSInteger month = [dayComponents month];
	//printf("\n year: %d",month);
	[gregorian release];
	//ILOG(@"ivo_Utilities getMonth]\n");
	return month; 
}

- (NSInteger)getDay:(NSDate *)date{
	//ILOG(@"[ivo_Utilities getDay\n");
	if (date==nil) return -1;
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dayComponents =[gregorian components:NSDayCalendarUnit fromDate:date];
	NSInteger day = [dayComponents day];
	//printf("\n year: %d",day);
	[gregorian release];
	//ILOG(@"ivo_Utilities getDay]\n");
	return day; 
}

- (NSString *)createMonthName: (NSDate *)date{
	//ILOG(@"[ivo_Utilities createMonthName\n");
   	if (date==nil) return nil;
   	if (date==nil) return [[NSString alloc] initWithString: @""];
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dayComponents =[gregorian components:NSMonthCalendarUnit fromDate:date];
	NSInteger month = [dayComponents month];
	NSString *monthName; 
	switch (month) {
		case 1:
			monthName=[NSString stringWithString:NSLocalizedString(@"janText", @"")];
			break;
		case 2:
			monthName=[NSString stringWithString:NSLocalizedString(@"febText", @"")];
			break;
		case 3:
			monthName=[NSString stringWithString:NSLocalizedString(@"marText", @"")];
			break;
		case 4:
			monthName=[NSString stringWithString:NSLocalizedString(@"aprText", @"")];
			break;
		case 5:
			monthName=[NSString stringWithString:NSLocalizedString(@"mayText", @"")];
			break;
		case 6:
			monthName=[NSString stringWithString:NSLocalizedString(@"junText", @"")];
			break;
		case 7:
			monthName=[NSString stringWithString:NSLocalizedString(@"julText", @"")];
			break;
		case 8:
			monthName=[NSString stringWithString:NSLocalizedString(@"augText", @"")];
			break;
		case 9:
			monthName=[NSString stringWithString:NSLocalizedString(@"sepText", @"")];
			break;
		case 10:
			monthName=[NSString stringWithString:NSLocalizedString(@"octText", @"")];
			break;
		case 11:
			monthName=[NSString stringWithString:NSLocalizedString(@"novText", @"")];
			break;
		case 12:
			monthName=[NSString stringWithString:NSLocalizedString(@"decText", @"")];
			break;
			
	}
	[gregorian release];
	//ILOG(@"ivo_Utilities createMonthName]\n");
	return [monthName copy];  	
}

- (NSInteger)getWeekday:(NSDate *)date{
   	if (date==nil) return 0;
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dayComponents =[gregorian components:NSWeekdayCalendarUnit fromDate:date];
	NSInteger wd = [dayComponents weekday];
	[gregorian release];
	return wd;
}

- (NSInteger)getWeekdayOrdinal:(NSDate *)date{
   	if (date==nil) return 0;
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dayComponents =[gregorian components:NSWeekdayOrdinalCalendarUnit fromDate:date];
	NSInteger wdo = [dayComponents weekdayOrdinal];
	[gregorian release];
	return wdo;
}

- (NSString *)createWeekDayName: (NSDate *)date{
	//ILOG(@"[ivo_Utilities createWeekDayName\n");
   	if (date==nil) return [[NSString alloc] initWithString: @""];
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dayComponents =[gregorian components:NSWeekdayCalendarUnit fromDate:date];
	NSInteger wd = [dayComponents weekday];
	NSString *WeekDayName; 
	if(wd== 1){
		WeekDayName=[NSString stringWithString: NSLocalizedString(@"sunText", @"")/*sunText*/];
	}else if(wd==2){
		WeekDayName=[NSString stringWithString: NSLocalizedString(@"monText", @"") /*monText*/];
	}else if(wd==3){
		WeekDayName=[NSString stringWithString: NSLocalizedString(@"tueText", @"") /*tueText*/];
	}else if(wd==4){
		WeekDayName=[NSString stringWithString: NSLocalizedString(@"wedText", @"") /*wedText*/];
	}else if(wd==5){
		WeekDayName=[NSString stringWithString: NSLocalizedString(@"thuText", @"") /*thuText*/];
	}else if(wd==6){
		WeekDayName=[NSString stringWithString: NSLocalizedString(@"friText", @"") /*friText*/];
	}else if(wd==7){
		WeekDayName=[NSString stringWithString: NSLocalizedString(@"satText", @"") /*satText*/];
	}
	[gregorian release];
	
	//ILOG(@"ivo_Utilities createWeekDayName]\n");
	return [WeekDayName copy];  	
}

- (NSInteger)getHour:(NSDate *)date{
	if (date==nil) return -1;
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dayComponents =[gregorian components:NSHourCalendarUnit fromDate:date];
	NSInteger hour = [dayComponents hour];
	[gregorian release];
	//printf("\n hours: %d",hour);
	return hour; 
}

- (NSInteger)getHourWithAMPM:(NSDate *)date{
	if (date==nil) return -1;
	//ILOG(@"[ivo_Utilities getHourWithAMPM\n");
	NSInteger hour=[self getHour:date];
	if (hour>12){
		hour=hour-12;
	}else {
		if (hour==0){
			hour=12;
		}
	}
	//ILOG(@"ivo_Utilities getHourWithAMPM]\n");
	return hour;	
}

- (NSString *)createAMPM:(NSDate *)date{
	NSString *ap=nil;
	if([self getHour:date]>=12){
		ap= [NSLocalizedString(@"pmText", @"") copy];
	}else {
		ap=[NSLocalizedString(@"amText", @"") copy];
	}

	return ap;
}

- (NSString *)getShortAMPM:(NSDate *)date{
	NSString *ap=nil;
	if([self getHour:date]>=12){
		ap= @"p";//pText;
	}else {
		ap=@"a";//aText;
	}
	
	return ap;
}

- (NSInteger)getMinute:(NSDate *)date{
	//ILOG(@"[ivo_Utilities getMinute\n");
	if (date==nil) return -1;
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dayComponents =[gregorian components:NSMinuteCalendarUnit fromDate:date];
	NSInteger minute = [dayComponents minute];
	//printf("\n minute: %d",minute);
	[gregorian release];
	//ILOG(@"ivo_Utilities getMinute]\n");
	return minute; 
}

- (NSInteger)getSecond:(NSDate *)date{
	//ILOG(@"[ivo_Utilities getSecond\n");
	if (date==nil) return -1;
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dayComponents =[gregorian components:NSSecondCalendarUnit fromDate:date];
	NSInteger second = [dayComponents second];
	//printf("\n second: %d",second);
	[gregorian release];
	//ILOG(@"ivo_Utilities getSecond]\n");
	return second; 
}

- (UIButton *)createButton:(NSString *)title 
				buttonType:(UIButtonType)buttonType
					 frame:(CGRect)frame
				titleColor:(UIColor *)titleColor
					target:(id)target
				  selector:(SEL)selector
		  normalStateImage:(NSString *)normalStateImage
		selectedStateImage:(NSString*)selectedStateImage
{
	//ILOG(@"[ivo_Utilities createButton\n");
	// create a UIButton with buttonType
	UIButton *button = [[UIButton buttonWithType:buttonType] retain];
	button.frame = frame;
	[button setTitle:title forState:UIControlStateNormal];
	button.titleLabel.font=[UIFont systemFontOfSize:14];
	if(titleColor!=nil){
		[button setTitleColor:titleColor  forState:UIControlStateNormal];
	}else {
		[button setTitleColor:[UIColor brownColor]  forState:UIControlStateNormal];		
	}
	
	button.backgroundColor = [UIColor clearColor];
	if(normalStateImage !=nil && ![normalStateImage isEqual:@""]){
		//[button setBackgroundImage:[[UIImage imageNamed:normalStateImage] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[button setBackgroundImage:[UIImage imageNamed:normalStateImage] forState:UIControlStateNormal];
	}
	
	if(selectedStateImage !=nil && ![selectedStateImage isEqual:@""]){
		//[button setBackgroundImage:[[UIImage imageNamed:selectedStateImage] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
		[button setBackgroundImage:[UIImage imageNamed:selectedStateImage] forState:UIControlStateSelected];
	}
	
	[button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
	
	//ILOG(@"ivo_Utilities createButton]\n");
	return button;
}

- (NSString *)createCalculateHowLong:(NSInteger)value{
	//ILOG(@"[ivo_Utilities createCalculateHowLong\n");
	NSString *ret=nil;
	NSInteger hours=value/3600;
	NSInteger mins=(value-hours*3600)/60;
	if(value<3600){
		ret= [[NSString stringWithFormat:@"%d min",value/60] copy];
	}else {
		if(mins>0){
			if(hours>1){
				if(mins<2){
					ret= [[NSString stringWithFormat:@"%d hrs, %d min",hours,mins] copy];
				}else {
					ret= [[NSString stringWithFormat:@"%d hrs, %d mins",hours,mins] copy];
				}

			}else {
				if(mins<2){
					ret= [[NSString stringWithFormat:@"%d hr, %d min",hours,mins] copy];
				}else {
					ret= [[NSString stringWithFormat:@"%d hr, %d mins",hours,mins] copy];
				}

			}

		}else {
			if(hours>1){
				ret= [[NSString stringWithFormat:@"%d hrs",hours] copy];
			}else {
				ret= [[NSString stringWithFormat:@"%d hr",hours] copy];
			}
		}
	}

	//ILOG(@"ivo_Utilities createCalculateHowLong]\n");
	return ret;
}

- (BOOL)isTaskInOtherContextRange:(Task*)task{
	//ILOG(@"[ivo_Utilities isTaskInOtherContextRange\n");
	
	NSString *wdayname=[self createWeekDayName:task.taskStartTime];
	BOOL ret=NO;
	
	
	if(task.taskWhere==0){//home task
		if([wdayname isEqual:NSLocalizedString(@"satText", @"")] || [wdayname isEqual:NSLocalizedString(@"sunText", @"")]){//weekend
			if((([self getHour:task.taskStartTime])*60 +[self getMinute:task.taskStartTime] >=  
				([self getHour:taskmanager.currentSetting.deskTimeWEStart])*60 +[self getMinute:taskmanager.currentSetting.deskTimeWEStart]) &&
				(([self getHour:task.taskStartTime])*60 +[self getMinute:task.taskStartTime] <=  
				 ([self getHour:taskmanager.currentSetting.deskTimeWEEnd])*60 +[self getMinute:taskmanager.currentSetting.deskTimeWEEnd])){
				ret= YES;	
			}
		}else {
			if((([self getHour:task.taskStartTime])*60 +[self getMinute:task.taskStartTime] >=  
				([self getHour:taskmanager.currentSetting.deskTimeStart])*60 +[self getMinute:taskmanager.currentSetting.deskTimeStart]) &&
			   (([self getHour:task.taskStartTime])*60 +[self getMinute:task.taskStartTime] <=  
				([self getHour:taskmanager.currentSetting.deskTimeEnd])*60 +[self getMinute:taskmanager.currentSetting.deskTimeEnd])){

				ret= YES;	
			}
		}
	}else if(task.taskWhere==1){
		if([wdayname isEqual:NSLocalizedString(@"satText", @"")] || [wdayname isEqual:NSLocalizedString(@"sunText", @"")]){//weekend
			if((([self getHour:task.taskStartTime])*60 +[self getMinute:task.taskStartTime] >=  
				([self getHour:taskmanager.currentSetting.homeTimeWEStart])*60 +[self getMinute:taskmanager.currentSetting.homeTimeWEStart]) &&
			   (([self getHour:task.taskStartTime])*60 +[self getMinute:task.taskStartTime] <=  
				([self getHour:taskmanager.currentSetting.homeTimeWEEnd])*60 +[self getMinute:taskmanager.currentSetting.homeTimeWEEnd])){
				
				ret= YES;	
			}
		}else {
			if((([self getHour:task.taskStartTime])*60 +[self getMinute:task.taskStartTime] >=  
				([self getHour:taskmanager.currentSetting.homeTimeNDStart])*60 +[self getMinute:taskmanager.currentSetting.homeTimeNDStart]) &&
			   (([self getHour:task.taskStartTime])*60 +[self getMinute:task.taskStartTime] <=  
				([self getHour:taskmanager.currentSetting.homeTimeNDEnd])*60 +[self getMinute:taskmanager.currentSetting.homeTimeNDEnd])){
				
				ret= YES;	
			}
		}
	}
	
	[wdayname release];
	
	//ILOG(@"ivo_Utilities isTaskInOtherContextRange]\n");
	return ret;
}

- (NSTimeInterval)getDateTimeStampForAdjustmentNewDue{
	NSDate *date=[NSDate date];
	NSString *currentDateShortStr=[NSString stringWithFormat:@"%d%d%d",[self getYear:date],[self getMonth:date],[self getDay:date]];
	NSTimeInterval ret=(NSTimeInterval)[[currentDateShortStr substringFromIndex:2] longLongValue];
	return ret;
}

//dateStr: yyyy-mm-dd
-(NSDate *)dateFromDateString:(NSString *)dateStr{
	NSArray *dateComps=[dateStr componentsSeparatedByString:@"-"];
	if (dateComps.count<3)return nil;
	
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];	
	unsigned unitFlags = NSWeekdayCalendarUnit|NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:[NSDate date]];
	[comps setYear:[[dateComps objectAtIndex:0] intValue]];
	[comps setMonth:[[dateComps objectAtIndex:1] intValue]];
	[comps setDay:[[dateComps objectAtIndex:2] intValue]];
	[comps setHour:0];
	[comps setMinute:0];
	[comps setSecond:0];
	
	return [gregorian dateFromComponents:comps];
	
}

//get a date string from a given date. Ex: 2010-05-09
- (NSString *)getShortDateWithFullYearStringFromDate:(NSDate *) date {
	NSString *ret=@"";
	if(date !=nil){
		ret= [NSString stringWithFormat:@"%04d-%02d-%02d",
			  [self getYear:date],
			  [self  getMonth:date],
			  [self  getDay:date]];	
	}
	return ret;	
}
-(NSString *)getAMPM:(NSDate *)date{
	NSString *ap=nil;
	if([self getHour:date]>=12){
		ap= NSLocalizedString(@"pmText", @"");
	}else {
		ap=NSLocalizedString(@"amText", @"");
	}
	
	return ap;
}

- (NSString *)getTimeStringLowerAmPmFromDate:(NSDate *) date{
	NSString *ret=nil;
	NSString *ap=[[ivoUtility getAMPM:date] lowercaseString];
	
	if(date !=nil){
		if(_is24HourFormat){
			ret= [NSString stringWithFormat:@"%02d:%02d",
				  [self getHour:date],
				  [self getMinute:date]];	
		}else {
			ret= [[NSString stringWithFormat:@"%02d:%02d",
				   [self getHourWithAMPM:date],
				   [self getMinute:date]] stringByAppendingString:ap];	
		}
		
	}
	return ret;	
	
}


-(NSDate *)newDateFromDate:(NSDate*)date offset:(NSTimeInterval)offset{
    if (!date) return nil;
    
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:date];
	
	NSInteger dayOffset=(NSInteger)offset/86400;
	long long modDay=(NSInteger)offset%86400;//offset - 86400*dayOffset;
	NSInteger hourOffset=(NSInteger)modDay/3600;
	long long modHour=(NSInteger)modDay%3600;;//modDay-3600*hourOffset;
	NSInteger minOffset=modHour/60;
	NSInteger secOffset=modHour%60;;//modHour - 60*minOffset;
	
	[comps setDay:[comps day]+dayOffset];
	[comps setHour:[comps hour]+hourOffset];
	[comps setMinute:[comps minute]+minOffset];
	[comps setSecond:[comps second]+secOffset];
	
	return [gregorian dateFromComponents:comps];
}

//Reset a dates with new components
-(NSDate *)resetDate:(NSDate*)date year:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute sencond:(NSInteger)second{
    
    if (!date) return nil;
    
	NSDate *ret=nil;
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];	
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:date];
	
	[comps setYear:year];
	[comps setMonth:month];
	[comps setDay:day];
	
	[comps setHour:hour];
	[comps setMinute:minute];
	[comps setSecond:second];
	
	ret=[gregorian dateFromComponents:comps];
	
	return ret;
}

#pragma mark commons
-(Alert *)creatAlertFromList:(NSArray *)arr atIndex:(NSInteger)atIndex{
	Alert *ret=[[Alert alloc] init];
/*	if(arr.count>atIndex){
		NSArray *alertValArr=[(NSString *)[arr objectAtIndex:atIndex] componentsSeparatedByString:@"|"];
		ret.amount=[[alertValArr objectAtIndex:0] intValue];
		ret.alertBy=[[alertValArr objectAtIndex:1] intValue];
		ret.timeUnit=[[alertValArr objectAtIndex:2] intValue];
		
		switch (ret.alertBy) {
			case 0:
				ret.alertByString=NSLocalizedString(@"SMSText", @"SMS");//@"SMS";
				break;
			case 1:
				ret.alertByString=NSLocalizedString(@"popupTitleText", @"Pop Up");//@"Pop Up";
				break;
			case 2:
				ret.alertByString=NSLocalizedString(@"emailTitleText", @"Email");//@"Email";
				break;
			case 3:
				if (OSVersion<=1.0) {
					ret.alertByString=NSLocalizedString(@"APNSText", @"");//@"APNS";
				}else {
					ret.alertByString=NSLocalizedString(@"popUpText", @"Pop-up");//@"APNS";
				}

				break;
				
		}
		
		switch (ret.timeUnit) {
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
	}
 */
	return ret;
}

//get a date string from a given date. Ex: 2010-05-09 10:40:30
- (NSString *)getShortDateTimeStringFromDate:(NSDate *) date {
	NSString *ret=nil;
	if(date !=nil){
		ret= [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d",
			  [self getYear:date],
			  [self getMonth:date],
			  [self getDay:date],
			  [self getHour:date],
			  [self getMinute:date],
			  [self getSecond:date]];	
	}
	return ret;	
}

/*
//dateStr: yyyy-mm-dd
-(NSDate *)dateFromDateString:(NSString *)dateStr{
	NSArray *dateComps=[dateStr componentsSeparatedByString:@"-"];
	if (dateComps.count<3)return nil;
	
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];	
	unsigned unitFlags = NSWeekdayCalendarUnit|NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:[NSDate date]];
	[comps setYear:[[dateComps objectAtIndex:0] intValue]];
	[comps setMonth:[[dateComps objectAtIndex:1] intValue]];
	[comps setDay:[[dateComps objectAtIndex:2] intValue]];
	[comps setHour:0];
	[comps setMinute:0];
	[comps setSecond:0];
	
	return [gregorian dateFromComponents:comps];
	
}
*/
/*
-(GCal2ProjMap *)creatGCal2ProjMapFromList:(NSArray *)arr atIndex:(NSInteger)atIndex{
	GCal2ProjMap *ret=[[GCal2ProjMap alloc] init];
	if(arr.count>atIndex){
		NSArray *mapValArr=[(NSString *)[arr objectAtIndex:atIndex] componentsSeparatedByString:@"|"];
		ret.gCalName=[[mapValArr objectAtIndex:0] intValue];
		ret.projectID=[[mapValArr objectAtIndex:1] intValue];
		//ret.mappingValue=[[ret.gCalName stringByAppendingString:@" <-> "] stringByAppendingString:[[projectList objectAtIndex:ret.projectID] projectName]];
	}
	return ret;
}
*/
-(NSString *)removeNewLineCharactersFromStr:(NSString *)string{
	NSString *ret;
	ret=[string stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];//remove the newline character
	ret=[ret stringByReplacingOccurrencesOfString:@"\n" withString:@""];//remove new line character;
	ret=[ret stringByReplacingOccurrencesOfString:@"\r" withString:@""];//remove new line character;
	return ret;
}

-(NSString *)replaceNewLineCharactersFromStr:(NSString *)string byString:(NSString *)byString{
	NSString *ret;
	ret=[string stringByReplacingOccurrencesOfString:@"\r\n" withString:byString];//remove the newline character
	ret=[ret stringByReplacingOccurrencesOfString:@"\n" withString:byString];//remove new line character;
	ret=[ret stringByReplacingOccurrencesOfString:@"\r" withString:byString];//remove new line character;
	return ret;	
}

#pragma mark Settings' methods

- (void)copySetting:(Setting *)setting toSetting:(Setting *)toSetting{
	//ILOG(@"[ivo_Utilities createCopySetting\n");
	if(!setting || !toSetting) return;
	
	toSetting.primaryKey=setting.primaryKey;
	toSetting.setID=setting.setID;
	toSetting.alarmSoundName=setting.alarmSoundName;
	toSetting.iVoStyleID=setting.iVoStyleID;
	toSetting.deskTimeStart=setting.deskTimeStart;
	toSetting.deskTimeEnd=setting.deskTimeEnd;
	toSetting.homeTimeNDStart=setting.homeTimeNDStart;
	toSetting.homeTimeNDEnd=setting.homeTimeNDEnd;
	toSetting.homeTimeWEStart=setting.homeTimeWEStart;
	toSetting.homeTimeWEEnd=setting.homeTimeWEEnd;
	toSetting.howlongDefVal=setting.howlongDefVal;
	toSetting.contextDefID=setting.contextDefID;
	toSetting.repeatDefID=setting.repeatDefID;
	toSetting.projectDefID=setting.projectDefID;
	toSetting.endRepeatCount=setting.endRepeatCount;
	toSetting.expiredBetaTestDate=setting.expiredBetaTestDate;
	toSetting.deskTimeWEStart=setting.deskTimeWEStart;
	toSetting.deskTimeWEEnd=setting.deskTimeWEEnd;
	toSetting.taskMovingStyle=setting.taskMovingStyle;
	toSetting.dueWhenMove=setting.dueWhenMove;
	toSetting.pushTaskFoward=setting.pushTaskFoward;
	toSetting.cleanOldDayCount=setting.cleanOldDayCount;
	toSetting.isFirstTimeStart=setting.isFirstTimeStart;
	toSetting.gCalAccount=setting.gCalAccount;
	toSetting.lastSyncedTime=setting.lastSyncedTime;
	toSetting.syncType=setting.syncType;
	toSetting.deleteItemsInTaskList=setting.deleteItemsInTaskList;
	toSetting.deletingType=setting.deletingType;
	toSetting.isFirstInstlUpdatStart=setting.isFirstInstlUpdatStart;
	toSetting.syncWindowStart=setting.syncWindowStart;
	toSetting.syncWindowEnd=setting.syncWindowEnd;
	toSetting.numberOfRestartTimes=setting.numberOfRestartTimes;
	toSetting.adjustTimeIntervalForNewDue=setting.adjustTimeIntervalForNewDue;
	toSetting.badgeType=setting.badgeType;
	toSetting.weekStartDay=setting.weekStartDay;
	toSetting.previousDevToken=setting.previousDevToken;
	toSetting.isNeedShowPushWarning=setting.isNeedShowPushWarning;
	toSetting.startWorkingWDay=setting.startWorkingWDay;
	toSetting.endWorkingWDay=setting.endWorkingWDay;
	toSetting.snoozeDuration=setting.snoozeDuration;
	toSetting.snoozeUnit=setting.snoozeUnit;

	toSetting.toodledoToken=setting.toodledoToken;
	toSetting.toodledoTokenTime=setting.toodledoTokenTime;
	toSetting.toodledoUserId=setting.toodledoUserId;
	toSetting.toodledoUserName=setting.toodledoUserName;
	toSetting.toodledoPassword=setting.toodledoPassword;
	toSetting.toodledoKey=setting.toodledoKey;
	toSetting.toodledoSyncTime=setting.toodledoSyncTime;
	toSetting.toodledoSyncType=setting.toodledoSyncType;
	toSetting.toodledoDeletedFolders=setting.toodledoDeletedFolders;
	toSetting.isFirstTimeToodledoSync=setting.isFirstTimeToodledoSync;
	toSetting.toodledoDeletedTasks=setting.toodledoDeletedTasks;
	toSetting.enableSyncToodledo=setting.enableSyncToodledo;
	toSetting.enableSyncICal=setting.enableSyncICal;
	toSetting.defaultProjectId=setting.defaultProjectId;
	toSetting.autoICalSync=setting.autoICalSync;
	toSetting.autoTDSync=setting.autoTDSync;
	toSetting.hasToodledoFirstTimeSynced=setting.hasToodledoFirstTimeSynced;
	toSetting.deletedICalEvents=setting.deletedICalEvents;
	toSetting.iCalLastSyncTime=setting.iCalLastSyncTime;
	toSetting.syncEventOnly=setting.syncEventOnly;
    toSetting.firstStart41=setting.firstStart41;
    toSetting.enabledReminderSync=setting.enabledReminderSync;
    toSetting.deletedReminderLists=setting.deletedReminderLists;
    toSetting.deletedReminders=setting.deletedReminders;
    
	//toSetting.calProjectMap=setting.calProjectMap;
	
	//ILOG(@"ivo_Utilities createCopySetting]\n");
	}

#pragma mark Projects' methods
//copy from an exisiting Project
- (Projects *)createCopyProject:(Projects*)proj{
	//ILOG(@"[ivo_Utilities createCopyProject\n");
	Projects *toProject=[[Projects alloc] init];
	toProject.primaryKey=proj.primaryKey;
	toProject.projID=proj.projID;
	toProject.projName=proj.projName;
	toProject.mapToGCalNameForEvent=proj.mapToGCalNameForEvent;
	toProject.mapToGCalNameForTask=proj.mapToGCalNameForTask;
	
	toProject.groupId=proj.groupId;
	toProject.projectOrder=proj.projectOrder;
	toProject.iCalCalendarName=proj.iCalCalendarName;
	toProject.inVisible=proj.inVisible;
	toProject.enableICalSync=proj.enableICalSync;
	toProject.iCalIdentifier=proj.iCalIdentifier;
    toProject.isInFiltering=proj.isInFiltering;
    toProject.colorId=proj.colorId;
    toProject.builtIn=proj.builtIn;
    toProject.reminderIdentifier=proj.reminderIdentifier;
    
	toProject.dirty=NO;
	//ILOG(@"ivo_Utilities createCopyProject]\n");
	return toProject;
}

//copy a list projects from existing list
- (NSMutableArray*)	createCopyProjectList:(NSMutableArray*)projList{
	//ILOG(@"[ivo_Utilities createCopyProjectList\n");
	NSMutableArray *newList=[[NSMutableArray alloc] initWithCapacity:7];
	for(int i=0; i<projList.count;i++){
		Projects *newProj=[self createCopyProject:[projList objectAtIndex:i]];
		[newList addObject:newProj];
		[newProj release];
	}
	//ILOG(@"ivo_Utilities createCopyProjectList]\n");
	return newList;
}

#pragma mark Tasks' methods
//copy a task
- (void)copyTask:(Task *)fromTask toTask:(Task *)task isIncludedPrimaryKey:(BOOL)isCopyPK{
	//ILOG(@"[ivo_Utilities copyTask\n");
	if(isCopyPK){
		task.primaryKey=fromTask.primaryKey;
	}
	
	task.taskID=fromTask.taskID;
	task.taskName=fromTask.taskName;
	task.taskDescription=fromTask.taskDescription;
	task.taskStartTime=fromTask.taskStartTime;
	task.taskEndTime=fromTask.taskEndTime;
	task.taskDueStartDate=fromTask.taskDueStartDate;
	task.taskDueEndDate=fromTask.taskDueEndDate;
	task.taskPinned=fromTask.taskPinned;
	task.taskREStartTime=fromTask.taskREStartTime;
	task.taskStatus=fromTask.taskStatus;
	task.taskCompleted=fromTask.taskCompleted;
	task.taskSynKey=fromTask.taskSynKey;
	task.taskWhat=fromTask.taskWhat;
	task.taskWho=fromTask.taskWho;
	task.taskWhere=fromTask.taskWhere;
	task.taskNumberInstances=fromTask.taskNumberInstances;
	task.taskHowLong=fromTask.taskHowLong;
	task.taskProject=fromTask.taskProject;
	task.parentRepeatInstance=fromTask.parentRepeatInstance;
	task.taskTypeUpdate=fromTask.taskTypeUpdate;
	task.taskDateUpdate=fromTask.taskDateUpdate;
	task.taskDefault=fromTask.taskDefault;
	task.taskRepeatID=fromTask.taskRepeatID;
	task.taskRepeatTimes=fromTask.taskRepeatTimes;
	task.taskLocation=fromTask.taskLocation;
	task.taskContact=fromTask.taskContact;
	task.taskAlertID=fromTask.taskAlertID;
	task.taskOriginalWhere=fromTask.taskOriginalWhere;
	task.taskDeadLine=fromTask.taskDeadLine;
	task.taskNotEalierThan=fromTask.taskNotEalierThan;
	task.taskIsUseDeadLine=fromTask.taskIsUseDeadLine;
	task.taskEmailToSend=fromTask.taskEmailToSend;
	task.taskPhoneToCall=fromTask.taskPhoneToCall;
	task.taskEndRepeatDate=fromTask.taskEndRepeatDate;
	task.taskRepeatOptions=fromTask.taskRepeatOptions;
	task.isOneMoreInstance=fromTask.isOneMoreInstance;
	task.taskRepeatExceptions=fromTask.taskRepeatExceptions;
	task.taskAlertValues=fromTask.taskAlertValues;
	task.originalPKey=fromTask.originalPKey;
	task.isAllDayEvent=fromTask.isAllDayEvent;
	task.isUsedExternalUpdateTime=fromTask.isUsedExternalUpdateTime;
	task.gcalEventId=fromTask.gcalEventId;
	task.isDeletedFromGCal=fromTask.isDeletedFromGCal;
	task.taskKey=fromTask.taskKey;
	task.PNSKey=fromTask.PNSKey;
	task.specifiedAlertTime=fromTask.specifiedAlertTime;
	task.alertByDeadline=fromTask.alertByDeadline;
	task.isAdjustedSpecifiedDate=fromTask.isAdjustedSpecifiedDate;
	task.originalPKey=fromTask.originalPKey;
	task.toodledoID=fromTask.toodledoID;
	
	task.isMultiParts=fromTask.isMultiParts;
	task.howLongParts=fromTask.howLongParts;
	
	task.toodledoHasStart=fromTask.toodledoHasStart;
	task.isHidden=fromTask.isHidden;
	task.iCalIdentifier=fromTask.iCalIdentifier;
	task.iCalCalendarName=fromTask.iCalCalendarName;
	task.hasAlert=fromTask.hasAlert;
    task.alertIndex=fromTask.alertIndex;
    task.alertBasedOn=fromTask.alertBasedOn;
    task.alertUnit=fromTask.alertUnit;
    task.taskRepeatStyle=fromTask.taskRepeatStyle;
    task.reminderIdentifier=fromTask.reminderIdentifier;
    
	//task.dirty=NO;
	//ILOG(@"ivo_Utilities copyTask]\n");
}

#pragma mark Task Management
- (TaskActionResult *)smartCheckValidationTask:(Task *)task inTaskList:(NSMutableArray *)list {
	//ILOG(@"[ivo_Utilities smartCheckValidationTask\n");
	
    NSMutableArray *arr=[NSMutableArray arrayWithArray:list];
    
	TaskActionResult *ret=[[TaskActionResult alloc] init];
	
	NSDate *taskStartTime=task.taskStartTime;
	NSDate *taskEndTime=task.taskEndTime;
	
	//check task name
	if (task.taskName==nil || [task.taskName isEqual:@""]){
		ret.errorNo= ERR_TASK_WITHOUT_NAME;//1;// invalid task name (task without name)
		ret.errorMessage=NSLocalizedString(@"taskEvenWithoutTitleText", @"");
		return ret;
	}
	
	//check Dead Line
	if(task.taskPinned==0 && task.taskIsUseDeadLine==1 && 
	   [task.taskDeadLine compare:[NSDate date]]==NSOrderedAscending){
		
		ret.errorNo=ERR_TASK_WITH_DEAD_LINE_IN_PAST;
		ret.errorMessage=NSLocalizedString(@"newDTaskWithDeadlineInThePastText", @"");
		return ret;
	}
	
	//check duration
	if (task.taskHowLong<0){
		ret.errorNo= ERR_TASK_WITH_NEGATIVE_DURATION;//2;// task with negative duration
		return ret;
	}
	
	if (task.taskPinned==0 && task.taskHowLong>24*3600){
		ret.errorNo= ERR_TASK_DURATION_TOO_LONG;//7;//unpinched task with duration > 8hrs
		ret.errorMessage=[NSString stringWithString: NSLocalizedString(@"durationIsTooLongText", @"")];
		return ret;
	}
	
	if (task.taskPinned==1){//pinched task
		if([taskStartTime compare:taskEndTime]==NSOrderedDescending){
			ret.errorNo= ERR_START_TIME_LATER_END_TIME;//4;//pinched task with start time is later then end time
			ret.errorMessage=[NSString stringWithString:NSLocalizedString(@"startTimeIsLaterEndTimeText", @"")];
			return ret;
		}
	}
	return ret;
	
}	


- (TaskActionResult *)smartCheckOverlapTask:(Task *)task inTaskList:(NSMutableArray *)list{
	//ILOG(@"[ivo_Utilities smartCheckValidationTask\n");
	//ILOG(@"[ivo_Utilities smartCheckValidationTask\n");
	
	TaskActionResult *ret=[[TaskActionResult alloc] init];
	
	NSDate *taskStartTime=task.taskStartTime;
	NSDate *taskEndTime=task.taskEndTime;
	
	//check task name
	if (task.taskName==nil || [task.taskName isEqual:@""]){
		ret.errorNo= ERR_TASK_WITHOUT_NAME;//1;// invalid task name (task without name)
		ret.errorMessage=NSLocalizedString(@"taskEvenWithoutTitleText", @"");
		return ret;
	}

	
	//check Dead Line
	if(task.taskPinned==0 && task.taskIsUseDeadLine==1 && 
	   [task.taskDeadLine compare:[NSDate date]]==NSOrderedAscending){
		
		ret.errorNo=ERR_TASK_WITH_DEAD_LINE_IN_PAST;
		ret.errorMessage=NSLocalizedString(@"newDTaskWithDeadlineInThePastText", @"");
		return ret;
	}
	
	//check duration
	if (task.taskHowLong<0){
		ret.errorNo= ERR_TASK_WITH_NEGATIVE_DURATION;//2;// task with negative duration
		return ret;
	}

//  ST4.1: task may have long duraiton	
//	if (task.taskPinned==0 && task.taskHowLong>24*3600){
//		ret.errorNo= ERR_TASK_DURATION_TOO_LONG;//7;//unpinched task with duration > 24hrs
//		ret.errorMessage=[NSString stringWithString: durationIsTooLongText];
//		return ret;
//	}
	
	if (task.taskPinned==1){//pinched task
		if([taskStartTime compare:taskEndTime]==NSOrderedDescending){
			ret.errorNo= ERR_START_TIME_LATER_END_TIME;//4;//pinched task with start time is later then end time
			ret.errorMessage=[NSString stringWithString:NSLocalizedString(@"startTimeIsLaterEndTimeText", @"")];
			
			return ret;
		}
	}
	
	//check overlap time slot and getting the index of the task that causes error, for saving time we don't call getindex method here
	NSInteger atTaskIndex=0;
	Task *tmp;
	
    NSMutableArray *arr=[NSMutableArray arrayWithArray:list];
	for (tmp in arr){
		if(tmp.primaryKey!=task.primaryKey && !(tmp.taskPinned==1&&tmp.isAllDayEvent==1) ){
			if([tmp.taskEndTime compare:task.taskStartTime]==NSOrderedAscending) //only check task/Dtask/Event
				goto goNext;
			
			//ST4.1
			//if([tmp.taskStartTime compare:task.taskEndTime]==NSOrderedDescending)//no overlap
			if([tmp.taskStartTime compare:task.taskEndTime]!=NSOrderedAscending)//no overlap
				return ret;
			
			NSDate *tmpStartTime=tmp.taskStartTime;
			NSDate *tmpEndTime=tmp.taskEndTime;
			
			//incase Event, only check raise exception if it is overlap a task, then task will be moved down
			if(task.taskPinned==1 && tmp.taskPinned==0){
				//ST4.1
				if (([tmpStartTime isEqualToDate: taskStartTime]) || 
					([tmpStartTime compare:taskStartTime]==NSOrderedAscending && 
					 [tmpEndTime compare:taskStartTime]==NSOrderedDescending)) {
				//if ([tmpStartTime compare:taskStartTime]==NSOrderedAscending && 
				//	 [tmpEndTime compare:taskStartTime]==NSOrderedDescending) {
					if (tmp.taskPinned==1){
						ret.errorNo= ERR_EVENT_START_OVERLAPPED;//8;//start time is overlapped by another defined pinched task duration
					}else if(tmp.taskPinned==0){
						ret.errorNo= ERR_TASK_START_OVERLAPPED;//9;//start time is overlapped by another due task duration	
					}
					ret.errorAtTaskIndex=atTaskIndex;
					return ret;
						
				//ST4.1		
				//} else if(([tmpEndTime isEqualToDate:taskEndTime]) ||
				//		  ([tmpStartTime compare:taskEndTime]==NSOrderedAscending &&
				//		   [tmpEndTime compare:taskEndTime]==NSOrderedDescending)) {

				} else if([tmpStartTime compare:taskEndTime]==NSOrderedAscending &&
						[tmpEndTime compare:taskEndTime]!=NSOrderedAscending) {		
					if(tmp.taskPinned==1){
						ret.errorNo=ERR_EVENT_END_OVERLAPPED;//10;//end time is overlapped by another defined pinched task duration
					}else if(tmp.taskPinned==0) {
						ret.errorNo= ERR_TASK_END_OVERLAPPED;//11; //end time is overlapped by another due task duration
					}
					ret.errorAtTaskIndex=atTaskIndex;
					return ret;
				} else if([taskStartTime compare:tmpStartTime]==NSOrderedAscending && 
						  [taskEndTime compare:tmpEndTime]==NSOrderedDescending) {
					if(tmp.taskPinned==1){
						ret.errorNo= ERR_EVENT_OVERLAPS_OTHERS;//12;//task's body overlaps pinched tmp
					}else if(tmp.taskPinned==0) {
						ret.errorNo= ERR_TASK_OVERLAPS_OTHERS;//13;//task's body overlaps dued tmp
					}
					ret.errorAtTaskIndex=atTaskIndex;
					return ret;
				}
				//incase Task, raise all exceptions if it overlaps(or is overlapped by) a task/event, then task will be moved down
			}else if(!(task.taskPinned==1 && tmp.taskPinned==1)){
				//ST4.1
				if (([tmpStartTime isEqualToDate: taskStartTime]) || 
					([tmpStartTime compare:taskStartTime]==NSOrderedAscending && 
					 [tmpEndTime compare:taskStartTime]==NSOrderedDescending)) {
				//if ([tmpStartTime compare:taskStartTime]==NSOrderedAscending && 
				//	[tmpEndTime compare:taskStartTime]==NSOrderedDescending) {
					
					if (tmp.taskPinned==1){
						ret.errorNo= ERR_EVENT_START_OVERLAPPED;//8;//start time is overlapped by another defined pinched task duration
					}else if(tmp.taskPinned==0){
						ret.errorNo= ERR_TASK_START_OVERLAPPED;//9;//start time is overlapped by another due task duration	
					}
					
					ret.errorAtTaskIndex=atTaskIndex;
					return ret;
				//ST4.1	
				//} else if(([tmpEndTime isEqualToDate:taskEndTime]) ||
				//		  ([tmpStartTime compare:taskEndTime]==NSOrderedAscending &&
				//		   [tmpEndTime compare:taskEndTime]==NSOrderedDescending)) {
				} else if([tmpStartTime compare:taskEndTime]==NSOrderedAscending &&
						   [tmpEndTime compare:taskEndTime]!=NSOrderedAscending) {	
					if(tmp.taskPinned==1){
						ret.errorNo=ERR_EVENT_END_OVERLAPPED;//10;//end time is overlapped by another defined pinched task duration
					}else if(tmp.taskPinned==0) {
						ret.errorNo= ERR_TASK_END_OVERLAPPED;//11; //end time is overlapped by another due task duration
					}
					ret.errorAtTaskIndex=atTaskIndex;
					return ret;
				} else if([taskStartTime compare:tmpStartTime]==NSOrderedAscending && 
						  [taskEndTime compare:tmpEndTime]==NSOrderedDescending) {
					if(tmp.taskPinned==1){
						ret.errorNo= ERR_EVENT_OVERLAPS_OTHERS;//12;//task overlaps pinched tmp
					}else if(tmp.taskPinned==0) {
						ret.errorNo= ERR_TASK_OVERLAPS_OTHERS;//13;//task overlaps dued tmp
					}
					ret.errorAtTaskIndex=atTaskIndex;
					return ret;
				}
			}		
		}
		goNext:
		atTaskIndex++;
	}		
	
	//ILOG(@"ivo_Utilities smartCheckValidationTask]\n");
	return ret;
	
}


- (NSInteger)getTimeSlotIndexForTask:(Task *)task inArray:(NSMutableArray *)list{
	//ILOG(@"[ivo_Utilities getTimeSlotIndexForTask\n");
    NSMutableArray *arr=[NSMutableArray arrayWithArray:list];
	Task *tmp;
	NSInteger i=0;
	for (tmp in arr){
		if([task.taskStartTime compare:tmp.taskStartTime]==NSOrderedAscending){
			return i;
		}
		i++;
	}
	
	//ILOG(@"ivo_Utilities getTimeSlotIndexForTask]\n");
	return i;
}

-(void)inspectPinnedTaskDate:(Task *)task{
	//ILOG(@"[ivo_Utilities inspectPinnedTaskDate\n");
	NSInteger dateSecond=[self getSecond:task.taskStartTime];
	if (dateSecond>0){
		NSDate *startTime=[task.taskStartTime copy];
		task.taskStartTime=[startTime dateByAddingTimeInterval:-dateSecond];
		[startTime release];
	}
	
	dateSecond=[self getSecond:task.taskEndTime];
	if (dateSecond>0){
		NSDate *endTime=[task.taskEndTime copy];
		task.taskEndTime=[endTime dateByAddingTimeInterval:-dateSecond];	
		[endTime release];
	}
	
    if (task.taskREStartTime) {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit|NSSecondCalendarUnit;
        
        NSDateComponents *comps = [gregorian components:unitFlags fromDate:task.taskREStartTime];
        [comps setSecond:[self getSecond:task.taskStartTime]];
        [comps setMinute:[self getMinute:task.taskStartTime]];
        [comps setHour:[self getHour:task.taskStartTime]];
        
        //	dateSecond=[self getSecond:task.taskREStartTime];
        //	if (dateSecond>0){
        //		NSDate *reStartTime=[task.taskREStartTime copy];
        //		task.taskREStartTime=[reStartTime addTimeInterval:-dateSecond];
        //		[reStartTime release];
        //	}
        task.taskREStartTime=[gregorian dateFromComponents:comps];
        
        comps = [gregorian components:unitFlags fromDate:task.taskEndRepeatDate];
        [comps setSecond:[self getSecond:task.taskEndTime]];
        [comps setMinute:[self getMinute:task.taskEndTime]];
        [comps setHour:[self getHour:task.taskEndTime]];
		
        //	dateSecond=[self getSecond:task.taskEndRepeatDate];
        //	if (dateSecond>0){
        //		NSDate *reEndTime=[task.taskEndRepeatDate copy];
        //		task.taskEndRepeatDate=[reEndTime addTimeInterval:-dateSecond];
        //		[reEndTime release];
        //	}
        
        task.taskEndRepeatDate=[gregorian dateFromComponents:comps];
        [gregorian release];
        
        //ILOG(@"ivo_Utilities inspectPinnedTaskDate]\n");
        
        /*
         dateSecond=[ivo_Utilities getSecond:task.taskDueStartDate];
         if (dateSecond>0){
         NSDate *taskNotEalierThan=[task.taskDueStartDate copy];
         task.taskDueStartDate=[taskNotEalierThan addTimeInterval:-dateSecond];
         [taskNotEalierThan release];
         }
         
         dateSecond=[ivo_Utilities getSecond:task.taskDueEndDate];
         if (dateSecond>0){
         NSDate *dueEnd=[task.taskDueEndDate copy];
         task.taskDueEndDate=[dueEnd addTimeInterval:-dateSecond];	
         [dueEnd release];
         }
         */
    }
	
}

- (NSMutableArray *) alloc_filterTasksByDate:(NSMutableArray *)list date:(NSDate *) date
{
	
	//NSMutableArray *ret=[taskmanager createInspectDisplaylist:list isIncludedADE:YES];
	NSMutableArray *ret=[[NSMutableArray alloc] initWithArray:list];
	
	//ILOG(@"[ivo_Utilities alloc_filterTasksByDate\n");
	NSMutableArray *filteredTasks = [[NSMutableArray alloc] initWithCapacity:5];//nang
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];//nang
	
    if (date) {
        /**** clear hour:minute:second for date *****/
        unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
        NSDateComponents *comps = [gregorian components:unitFlags fromDate:date];
        date = [gregorian dateFromComponents:comps];
        /***********************************************/
        
		for (int i=0; i<ret.count; i++)
		{
			Task *task = [ret objectAtIndex:i];
			
			/**** clear hour:minute:second for start time *****/
			comps = [gregorian components:unitFlags fromDate:task.taskStartTime];
			NSDate *starttime = [gregorian dateFromComponents:comps];
			/***********************************************/
			
			NSComparisonResult result = [starttime compare:date];
			if (result == NSOrderedSame)
			{
				[filteredTasks addObject:task];
			}
		}
    }
		
	[gregorian release];
	//ILOG(@"ivo_Utilities alloc_filterTasksByDate]\n");
	[ret release];
	return filteredTasks;
}

//trung ST3.1
- (void) fillREInstanceToList: (NSMutableArray *)list dummykey:(NSInteger)dummyKey parentKey:(NSInteger)parentKey startTime:(NSDate *)startTime
{
    NSMutableArray *arr=[NSMutableArray arrayWithArray:list];
    
	if (dummyKey < -1 && parentKey >= 0)
	{
		
		Task *sameDummyKeyTask = nil;
		Task *parentTask = nil;
		
        
		for (Task *task in arr)
		{
			if (task.primaryKey == dummyKey)
			{
				sameDummyKeyTask = task;
			}
			else if (task.primaryKey == parentKey)
			{
				parentTask = task;
			}
		}

		if (parentTask != nil)
		{
			if (sameDummyKeyTask == nil)
			{
				sameDummyKeyTask = [[[Task alloc] init] autorelease];
				[list addObject:sameDummyKeyTask];
			}

			[self copyTask:parentTask toTask:sameDummyKeyTask isIncludedPrimaryKey:NO];
			
			sameDummyKeyTask.parentRepeatInstance = parentKey;
			sameDummyKeyTask.primaryKey = dummyKey;
			sameDummyKeyTask.taskStartTime = startTime;
			sameDummyKeyTask.taskEndTime = [startTime dateByAddingTimeInterval:sameDummyKeyTask.taskHowLong];
		}
	}
	else if (dummyKey >= 0 && parentKey == -1)
	{
		for (Task *task in arr)
		{
			if (task.primaryKey == dummyKey && task.taskRepeatID > 0 && task.taskPinned) // root RE found
			{
				[taskmanager fillFirstDummyREInstanceToList: list rootRE:task];
				
				//printf("---- Task List after fill first dummy instance ---\n");
				//[self printTask:list];
				
				break;
			}
		}		
	}
}

- (CGSize) getTimeSize: (CGFloat) size
{
	NSString *am12 = @"12:00 AM";
	UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:size];
	
	return [am12 sizeWithFont:font];
}


- (NSDate *)createDeadLine:(NSInteger)type fromDate:(NSDate *)fromDate context:(NSInteger)context{
    
    if (!fromDate) return nil;
    
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
	NSDate *deadLineDate;
	NSDate *deadLineDateTime;
	NSDateComponents *compsDln = [gregorian components:unitFlags fromDate:fromDate];
	
	switch (type) {
		case DEADLINE_TODAY:
			deadLineDate = [fromDate copy];
			break;
		case DEADLINE_TOMORROW:
			//deadLineDate = [[fromDate addTimeInterval:86400] copy];
			[compsDln setDay:[compsDln day]+1];
			deadLineDate=[[gregorian dateFromComponents:compsDln] copy];
			break;
		case DEADLINE_1_WEEK:
			//deadLineDate = [[fromDate addTimeInterval:604800] copy];
			[compsDln setDay:[compsDln day] +7];
			deadLineDate=[[gregorian dateFromComponents:compsDln] copy];
			break;
		case DEADLINE_2_WEEKS:
			//deadLineDate = [[fromDate addTimeInterval:1209600] copy];
			[compsDln setDay:[compsDln day] +14];
			deadLineDate=[[gregorian dateFromComponents:compsDln] copy];
			
			break;
		case DEADLINE_1_MONTH:
			//deadLineDate = [[fromDate addTimeInterval:2592000] copy];
			[compsDln setMonth:[compsDln month] +1];
			deadLineDate=[[gregorian dateFromComponents:compsDln] copy];
			
			break;
		default: //ST3.2.1
			deadLineDate = [fromDate copy];
	}
	
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:deadLineDate];
	[comps setSecond:0];
	
	NSString *weekDayName=[self createWeekDayName:deadLineDate];
	NSInteger weekDay=[self getWeekday:deadLineDate];
	
	NSInteger wkHourHomeEnd=[self getHour:taskmanager.currentSetting.homeTimeWEEnd];
	NSInteger ndHourHomeEnd=[self getHour:taskmanager.currentSetting.homeTimeNDEnd];
	NSInteger wkHourDeskEnd=[self getHour:taskmanager.currentSetting.deskTimeWEEnd];
	NSInteger ndHourDeskEnd=[self getHour:taskmanager.currentSetting.deskTimeEnd];
	
	NSInteger wkMinHomeEnd=[self getMinute:taskmanager.currentSetting.homeTimeWEEnd];
	NSInteger ndMinHomeEnd=[self getMinute:taskmanager.currentSetting.homeTimeNDEnd];
	NSInteger wkMinDeskEnd=[self getMinute:taskmanager.currentSetting.deskTimeWEEnd];
	NSInteger ndMinDeskEnd=[self getMinute:taskmanager.currentSetting.deskTimeEnd];
	
	if(context==0){//home
		//if([weekDayName isEqual:satText] || [weekDayName isEqual:sunText]){//weekend
		if([taskmanager isDayInWeekend:weekDay]){
			[comps setMinute:wkMinHomeEnd];
			[comps setHour:wkHourHomeEnd];	
		}else{//normal day
			[comps setMinute:ndMinHomeEnd];
			[comps setHour: ndHourHomeEnd];	
		}
	}else{//desk
		//if([weekDayName isEqual:satText] || [weekDayName isEqual:sunText]){//weekend
		if([taskmanager isDayInWeekend:weekDay]){
			[comps setMinute:wkMinDeskEnd];
			[comps setHour:wkHourDeskEnd];	
		}else{//normal day
			[comps setMinute:ndMinDeskEnd];
			[comps setHour: ndHourDeskEnd];	
		}
	}
	
	deadLineDateTime= [[[gregorian dateFromComponents:comps] dateByAddingTimeInterval:0] copy];
	[weekDayName release];
	
	[gregorian release];
	[deadLineDate release];
	return deadLineDateTime;
}

-(NSDate *)createEndRepeatDateFromCount:(NSDate *)fromDate typeRepeat:(NSInteger)typeRepeat repeatCount:(NSInteger)repeatCount repeatOptionsStr:(NSString *)repeatOptionsStr{
    
    if (!fromDate) return nil;
    
	NSDate *ret;
	
	NSDate *tmp;
	
	tmp=fromDate;
	
	//get repeat options:
	NSInteger repeatEvery;
	NSInteger repeatBy;
	NSString *repeatOn;
	
	if(repeatOptionsStr !=nil && ![repeatOptionsStr isEqualToString:@""]){
		NSArray *options=[repeatOptionsStr componentsSeparatedByString:@"/"];
		repeatEvery=[(NSString*)[options objectAtIndex:0] intValue];
		repeatOn=[(NSString*)[options objectAtIndex:1] copy];
		repeatBy=[(NSString*)[options objectAtIndex:2] intValue];
	}else {
		repeatEvery=1;
		repeatOn=@"";
		repeatBy=0;
	}
	
	
	if(repeatEvery<1){
		repeatEvery=1;
	}
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;//|NSWeekdayCalendarUnit|NSWeekdayOrdinalCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:tmp];
	
	NSInteger nextMonth=[comps month];
	NSInteger nextYear=[comps year];
	NSInteger wd=[self getWeekday:tmp];
	NSInteger wdo=[self getWeekdayOrdinal:tmp];
	
	switch (typeRepeat) {
		case REPEAT_DAILY://daily
		{
			//tmp=[tmp addTimeInterval:86400*repeatEvery*(repeatCount-1)];
			comps = [gregorian components:unitFlags fromDate:tmp];
			[comps setDay:[comps day]+repeatEvery*(repeatCount-1)];
			tmp=[gregorian dateFromComponents:comps];
		}
			break;
			
		case REPEAT_WEEKLY://weekly
			//check the options
		{
			if(repeatOn !=nil && ![repeatOn isEqualToString:@""]){
				NSArray *selectDays=[repeatOn componentsSeparatedByString:@"|"];
				NSInteger firstInstanceWeekDay=[self getWeekday:tmp];
				NSInteger peakDaysInWeek=0;
				NSInteger maxPeakDay=firstInstanceWeekDay;
				
				for (NSInteger i=0;i<selectDays.count;i++){
					peakDaysInWeek=[(NSString *)[selectDays objectAtIndex:i] intValue];
					if(peakDaysInWeek>maxPeakDay){
						maxPeakDay=peakDaysInWeek;
					}					
				}
				
				//tmp=[tmp addTimeInterval:(maxPeakDay-firstInstanceWeekDay)* 86400];
				comps = [gregorian components:unitFlags fromDate:tmp];
				[comps setDay:[comps day]+(maxPeakDay-firstInstanceWeekDay)];
				tmp=[gregorian dateFromComponents:comps];
			}
			
			//tmp=[tmp addTimeInterval:(double)604800*repeatEvery*(repeatCount-1)];
			comps = [gregorian components:unitFlags fromDate:tmp];
			[comps setDay:[comps day]+7*repeatEvery*(repeatCount-1)];
			tmp=[gregorian dateFromComponents:comps];
		}
			break;
		case REPEAT_MONTHLY://monthly
		{
			nextMonth=nextMonth + repeatEvery*(repeatCount-1);
			if(nextMonth<=12){ 
				[comps setMonth:nextMonth];
			}else {
				[comps setYear:[comps year] +(NSInteger)(nextMonth/12)];
				[comps setMonth:nextMonth - (NSInteger)(nextMonth/12) *12];
				nextMonth=1;
			}
			
			if(repeatBy==0){//weekday
				
			}else {//weekday name
				[comps setWeekday:wd];
				[comps setWeekdayOrdinal:wdo];
			}
			
			tmp= [gregorian dateFromComponents:comps];
		}
			break;
		case REPEAT_YEARLY://yearly
		{
			nextYear=nextYear +repeatEvery*(repeatCount-1);
			[comps setYear:nextYear];
			tmp= [gregorian dateFromComponents:comps];
			
		}
			break;
			
		default:
			
			break;
			
	}
	
	if(repeatOn !=nil){
		[repeatOn release];
		repeatOn=nil;
	}
	[gregorian release];
	
	ret=[tmp copy];
	
	return ret;
}

-(repeatCountTime)createRepeatCountFromEndDate:(NSDate *)fromDate typeRepeat:(NSInteger)typeRepeat toDate:(NSDate *)toDate repeatOptionsStr:(NSString *)repeatOptionsStr reStartDate:(NSDate *)reStartDate{
	repeatCountTime ret;
	ret.numberOfInstances=0;
	ret.repeatTimes=0;
	NSDate *untilDate;
	NSDate *tmp;
	
	untilDate=toDate;
	tmp=fromDate;
	
	if([tmp compare:untilDate]==NSOrderedDescending || !fromDate || !toDate){
		ret.numberOfInstances=1;
		ret.repeatTimes=1;
		return ret;
	}
	
	
	//get repeat options:
	NSInteger repeatEvery;
	NSInteger repeatBy;
	NSString *repeatOn;
	
	if(repeatOptionsStr !=nil && ![repeatOptionsStr isEqualToString:@""]){
		NSArray *options=[repeatOptionsStr componentsSeparatedByString:@"/"];
		repeatEvery=[(NSString*)[options objectAtIndex:0] intValue];
		repeatOn=[(NSString*)[options objectAtIndex:1] copy];
		repeatBy=[(NSString*)[options objectAtIndex:2] intValue];
	}else {
		repeatEvery=1;
		repeatOn=@"";
		repeatBy=0;
	}
	
	
	if(repeatEvery<1){
		repeatEvery=1;
	}
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;//|NSWeekdayCalendarUnit|NSWeekdayOrdinalCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:tmp];
	
	NSInteger nextMonth=[comps month];
	NSInteger nextYear=[comps year];
	NSInteger wd=[self getWeekday:tmp];
	NSInteger wdo=[self getWeekdayOrdinal:tmp];
	
	ret.repeatTimes=1;
	ret.numberOfInstances=1;
	
	//NSInteger loopCount=0;//used to stop the loop if unknow exception cases happened, 
	while ([tmp compare:untilDate]==NSOrderedAscending){//maximum is 2 years day
		//loopCount +=1;
		
		//if(loopCount==730){//for debugger only
		//	printf("\niVo_Utilities: Can't createRepeatCountFromEndDate from list because of looped forever\n");
		//}
		
		switch (typeRepeat) {
			case REPEAT_DAILY://daily
			{
				//tmp=[tmp addTimeInterval:86400*repeatEvery];
				comps = [gregorian components:unitFlags fromDate:tmp];
				[comps setDay:[comps day]+repeatEvery];
				tmp=[gregorian dateFromComponents:comps];
				
				/*				//nang fix DST--------------
				 NSDate *date=tmp;
				 if(![App_defaultTimeZone isDaylightSavingTimeForDate:reStartDate]){
				 tmp=[tmp addTimeInterval:-dstOffset];
				 }
				 
				 NSDate *nextDstDate=[App_defaultTimeZone nextDaylightSavingTimeTransitionAfterDate:[tmp addTimeInterval:-86400]];
				 if(![App_defaultTimeZone isDaylightSavingTimeForDate:tmp] 
				 || [[ivoUtility getLongStringFromDate:tmp] isEqualToString:[ivoUtility getLongStringFromDate:nextDstDate]]){
				 tmp=[ivo_Utilities dateWithNewOffset:tmp offsetFromDate:nextDstDate];
				 }
				 //-----------------------------
				 */				
				if([tmp compare:untilDate]==NSOrderedDescending){
					goto exitWhile;
				}
				
				//				tmp=date;
				
				ret.repeatTimes+=1;
				ret.numberOfInstances+=1;
			}
				break;
				
			case REPEAT_WEEKLY://weekly
				//check the options
			{
				if(repeatOn !=nil && ![repeatOn isEqualToString:@""]){
					NSArray *selectDays=[repeatOn componentsSeparatedByString:@"|"];
					NSInteger firstInstanceWeekDay=[self getWeekday:tmp];
					NSInteger peakDaysInWeek=0;
					
					//set to the first day of week
					//tmp=[tmp addTimeInterval:-(firstInstanceWeekDay-1)*86400];
					comps = [gregorian components:unitFlags fromDate:tmp];
					[comps setDay:[comps day]-(firstInstanceWeekDay-1)];
					tmp=[gregorian dateFromComponents:comps];
					
					NSDate *groupIntancesDate=nil;
					
					NSInteger i=0;
					for (i;i<selectDays.count;i++){
						
					beginFor:
						peakDaysInWeek=(NSInteger)[(NSString *)[selectDays objectAtIndex:i] intValue];
						
						//groupIntancesDate=[tmp addTimeInterval:(peakDaysInWeek-1)* 86400];
						comps = [gregorian components:unitFlags fromDate:tmp];
						[comps setDay:[comps day]+(peakDaysInWeek-1)];
						groupIntancesDate=[gregorian dateFromComponents:comps];
						
						if([groupIntancesDate compare:fromDate]!=NSOrderedDescending){
							
							if([groupIntancesDate compare:untilDate]!=NSOrderedAscending){
								break;
							}
							
							i+=1;
							if(i<selectDays.count){
								goto beginFor;
							}else {
								break;
							}
							
						}
						
						if([groupIntancesDate compare:untilDate]!=NSOrderedAscending){
							//break;
							goto wContinueLoop;
						}
						ret.numberOfInstances+=1;
					}
					
					if([self getWeekdayOrdinal:groupIntancesDate]==[self getWeekdayOrdinal:fromDate] &&
					   [self getMonth:groupIntancesDate]==[self getMonth:fromDate] &&
					   [self getYear:groupIntancesDate]==[self getYear:fromDate]){
						ret.repeatTimes-=1;
						//ret.numberOfInstances-=1;
					}
					
				}else {
					ret.numberOfInstances=+1;					
				}
				
				
				ret.repeatTimes+=1;
			wContinueLoop:{}
				//tmp=[tmp addTimeInterval:604800*repeatEvery];
				comps = [gregorian components:unitFlags fromDate:tmp];
				[comps setDay:[comps day]+7*repeatEvery];
				tmp=[gregorian dateFromComponents:comps];
			}
				break;
			case REPEAT_MONTHLY://monthly
			{
				nextMonth=nextMonth + repeatEvery;
				if(nextMonth<=12){ 
					[comps setMonth:nextMonth];
				}else {
					[comps setYear:[comps year] +(NSInteger)(nextMonth/12)];
					[comps setMonth:nextMonth - (NSInteger)(nextMonth/12) *12];
					nextMonth=1;
				}
				
				if(repeatBy==0){//weekday
					
				}else {//weekday name
					[comps setWeekday:wd];
					[comps setWeekdayOrdinal:wdo];
				}
				
				tmp= [gregorian dateFromComponents:comps];
				if([tmp compare:untilDate]==NSOrderedDescending){
					goto exitWhile;
				}
				
				ret.repeatTimes+=1;
				ret.numberOfInstances+=1;
			}
				break;
			case REPEAT_YEARLY://yearly
			{
				nextYear=nextYear +repeatEvery;
				[comps setYear:nextYear];
				tmp= [gregorian dateFromComponents:comps];
				
				if([tmp compare:untilDate]==NSOrderedDescending){
					goto exitWhile;
				}
				
				ret.repeatTimes+=1;	
				ret.numberOfInstances+=1;
			}
				break;
				
			default:
				goto exitWhile;
				break;
				
		}
	}
exitWhile:	
	
	if(repeatOn !=nil){
		[repeatOn release];
		repeatOn=nil;
	}
	[gregorian release];
	
	return ret;
}

//
-(NSInteger)countRepeatInstancesFromEndDate:(NSDate *)fromDate typeRepeat:(NSInteger)typeRepeat toDate:(NSDate *)toDate repeatOptionsStr:(NSString *)repeatOptionsStr{
    
    if (!fromDate || !toDate) return 0;
    
	NSInteger ret=0;
	NSDate *untilDate;
	NSDate *tmp;
	
	untilDate=toDate;
	tmp=fromDate;
	
	//get repeat options:
	NSInteger repeatEvery;
	NSInteger repeatBy;
	NSString *repeatOn;
	
	if(repeatOptionsStr !=nil && ![repeatOptionsStr isEqualToString:@""]){
		NSArray *options=[repeatOptionsStr componentsSeparatedByString:@"/"];
		repeatEvery=[(NSString*)[options objectAtIndex:0] intValue];
		repeatOn=[(NSString*)[options objectAtIndex:1] copy];
		repeatBy=[(NSString*)[options objectAtIndex:2] intValue];
	}else {
		repeatEvery=1;
		repeatOn=@"";
		repeatBy=0;
	}
	
	
	if(repeatEvery<1){
		repeatEvery=1;
	}
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;//|NSWeekdayCalendarUnit|NSWeekdayOrdinalCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:tmp];
	
	NSInteger nextMonth=[comps month];
	NSInteger nextYear=[comps year];
	NSInteger wd=[self getWeekday:tmp];
	NSInteger wdo=[self getWeekdayOrdinal:tmp];
	
	ret=1;
	
	NSInteger loopCount=0;//used to stop the loop if unknow exception cases happened, 
	
	while ([tmp compare:untilDate]==NSOrderedAscending && loopCount<730){
		loopCount +=1;
		switch (typeRepeat) {
			case REPEAT_DAILY://daily
			{
				//tmp=[tmp addTimeInterval:86400*repeatEvery];
				comps = [gregorian components:unitFlags fromDate:tmp];
				[comps setDay:[comps day]+repeatEvery];
				tmp=[gregorian dateFromComponents:comps];
				
				if([tmp compare:untilDate]==NSOrderedDescending){
					goto exitWhile;
				}
				ret+=1;
			}
				break;
				
			case REPEAT_WEEKLY://weekly
				//check the options
			{
				if(repeatOn !=nil && ![repeatOn isEqualToString:@""]){
					NSArray *selectDays=[repeatOn componentsSeparatedByString:@"|"];
					NSInteger firstInstanceWeekDay=[self getWeekday:tmp];
					NSInteger peakDaysInWeek=0;
					
					//set to the first day of week
					//tmp=[tmp addTimeInterval:-(firstInstanceWeekDay-1)*86400];
					comps = [gregorian components:unitFlags fromDate:tmp];
					[comps setDay:[comps day]-(firstInstanceWeekDay-1)];
					tmp=[gregorian dateFromComponents:comps];
					
					NSDate *groupIntancesDate=nil;
					
					NSInteger i=0;
					for (i;i<selectDays.count;i++){
						
					beginFor:
						peakDaysInWeek=(NSInteger)[(NSString *)[selectDays objectAtIndex:i] intValue];
						
						//groupIntancesDate=[tmp addTimeInterval:(peakDaysInWeek-1)* 86400];
						comps = [gregorian components:unitFlags fromDate:tmp];
						[comps setDay:[comps day]+(peakDaysInWeek-1)];
						groupIntancesDate=[gregorian dateFromComponents:comps];
						
						if([groupIntancesDate compare:fromDate]!=NSOrderedDescending){
							
							if([groupIntancesDate compare:untilDate]==NSOrderedDescending){
								break;
							}
							
							i+=1;
							
							if(i<selectDays.count){
								goto beginFor;
							}else {
								break;
							}
							
						}
						
						if([groupIntancesDate compare:untilDate]==NSOrderedDescending){
							break;
						}
						ret+=1;
					}
				}else {
					ret+=1;
				}
				
				
				//tmp=[tmp addTimeInterval:604800*repeatEvery];
				comps = [gregorian components:unitFlags fromDate:tmp];
				[comps setDay:[comps day]+7*repeatEvery];
				tmp=[gregorian dateFromComponents:comps];
				
			}
				break;
			case REPEAT_MONTHLY://monthly
			{
				nextMonth=nextMonth + repeatEvery;
				if(nextMonth<=12){ 
					[comps setMonth:nextMonth];
				}else {
					[comps setYear:[comps year] +(NSInteger)(nextMonth/12)];
					[comps setMonth:nextMonth - (NSInteger)(nextMonth/12) *12];
					nextMonth=1;
				}
				
				if(repeatBy==0){//weekday
					
				}else {//weekday name
					[comps setWeekday:wd];
					[comps setWeekdayOrdinal:wdo];
				}
				
				tmp= [gregorian dateFromComponents:comps];
				if([tmp compare:untilDate]==NSOrderedDescending){
					goto exitWhile;
				}
				
				ret+=1;
			}
				break;
			case REPEAT_YEARLY://yearly
			{
				nextYear=nextYear +repeatEvery;
				[comps setYear:nextYear];
				tmp= [gregorian dateFromComponents:comps];
				
				if([tmp compare:untilDate]==NSOrderedDescending){
					goto exitWhile;
				}
				
				ret+=1;					
			}
				break;
				
			default:
				goto exitWhile;
				break;
				
		}
	}
exitWhile:	
	
	if(repeatOn !=nil){
		[repeatOn release];
		repeatOn=nil;
	}
	[gregorian release];
	
	return ret;
}

-(NSInteger)getRepeatEvery:(NSString *)taskRepeatOptions{
	NSInteger repeatEvery=1;
	if(taskRepeatOptions !=nil && ![taskRepeatOptions isEqualToString:@""]){
		NSArray *options=[taskRepeatOptions componentsSeparatedByString:@"/"];
		repeatEvery=[(NSString*)[options objectAtIndex:0] intValue];
	}else {
		repeatEvery=1;
	}

	
	if(repeatEvery<1){
		repeatEvery=1;
	}
	return repeatEvery; 
}

//return a list of dates where exceptions are deleted
/*
- (NSMutableArray *)deletedExceptionList:(Task *)mainInstance inList:(NSMutableArray *)list{
	NSMutableArray *listDate=[[NSMutableArray alloc] initWithCapacity:1];
	
	Task *task=[taskmanager getParentRE:mainInstance inList:list];
	
	NSString *deletedExceptionStr=[task.taskRepeatExceptions copy];
	
	if(![deletedExceptionStr isEqualToString:@""]){
		for (Task *tmp in list){
			if(tmp.primaryKey !=task.primaryKey && tmp.parentRepeatInstance==task.primaryKey && tmp.primaryKey>-1){
				deletedExceptionStr=[deletedExceptionStr stringByReplacingOccurrencesOfString:[[NSString stringWithFormat:@"|"] 
																							   stringByAppendingString:tmp.taskRepeatExceptions] 
																				   withString:@""];
			}
		}
	}
	
	if(![deletedExceptionStr isEqualToString:@""]){
		NSArray *exceptionList=[deletedExceptionStr componentsSeparatedByString:@"|"];
		NSDate *tmpDate;
		
		for(NSInteger i=1; i<exceptionList.count;i++){
			tmpDate=[[NSDate dateWithTimeIntervalSince1970:[[exceptionList objectAtIndex:i] doubleValue]] copy];
			[listDate addObject:tmpDate];
			[tmpDate release];
		}
	}
	
	[deletedExceptionStr release];
	return listDate;
}
 */
- (NSMutableArray *)deletedExceptionList:(Task *)mainInstance inList:(NSMutableArray *)list{
	NSMutableArray *listDate=[[NSMutableArray alloc] initWithCapacity:1];
	
	//Task *task=[taskmanager getParentRE:mainInstance inList:list];
	
	//NSString *deletedExceptionStr=[task.taskRepeatExceptions copy];
	
    NSMutableArray *arr=[NSMutableArray arrayWithArray:list];
    
	NSString *deletedExceptionStr=[NSString stringWithString:mainInstance.taskRepeatExceptions];
	
	if(![deletedExceptionStr isEqualToString:@""]){
		for (Task *tmp in arr){
			//if(tmp.primaryKey !=task.primaryKey && tmp.parentRepeatInstance==task.primaryKey && tmp.primaryKey>-1){
			if(tmp.primaryKey !=mainInstance.primaryKey && tmp.parentRepeatInstance==mainInstance.primaryKey && tmp.primaryKey>-1){
				//deletedExceptionStr=[deletedExceptionStr stringByReplacingOccurrencesOfString:[[NSString stringWithFormat:@"|"] 
				deletedExceptionStr=[deletedExceptionStr stringByReplacingOccurrencesOfString:[[NSString stringWithString:@"|"] 
																							   stringByAppendingString:tmp.taskRepeatExceptions] 
																				   withString:@""];
			}
		}
	}
	
	if(![deletedExceptionStr isEqualToString:@""]){
		NSArray *exceptionList=[deletedExceptionStr componentsSeparatedByString:@"|"];
		//NSDate *tmpDate;
		
		for(NSInteger i=1; i<exceptionList.count;i++){
			//tmpDate=[[NSDate dateWithTimeIntervalSince1970:[[exceptionList objectAtIndex:i] doubleValue]] copy];
			NSDate *tmpDate=[NSDate dateWithTimeIntervalSince1970:[[exceptionList objectAtIndex:i] doubleValue]];
			[listDate addObject:tmpDate];
			//[tmpDate release];
		}
	}
	
	//NSMutableArray *ret=[listDate retain];
	//[listDate release];
	//return ret;
	return listDate;
}

//project index will be project id in v4.1

/*
-(UIColor *)getRGBColorForProject:(NSInteger)projectIndex isGetFirstRGB:(BOOL)isGetFirstRGB{
	CGFloat r;
	CGFloat g;
	CGFloat b;
	switch (projectIndex)
	{
		case PROJECT0:
		{
			if(isGetFirstRGB){
				r = _project0Colors[0][0]/255;
				g= _project0Colors[0][1]/255;
				b = _project0Colors[0][2]/255;
			}else {
				r = _project0Colors[1][0]/255;
				g = _project0Colors[1][1]/255;
				b = _project0Colors[1][2]/255;
			}

		}
			break;
		case PROJECT1:
		{
			if(isGetFirstRGB){
				r = _project1Colors[0][0]/255;
				g = _project1Colors[0][1]/255;
				b = _project1Colors[0][2]/255;
			}else {
				r = _project1Colors[1][0]/255;
				g = _project1Colors[1][1]/255;
				b = _project1Colors[1][2]/255;
			}

		}
			break;
		case PROJECT2:
		{
			if(isGetFirstRGB){
				r = _project2Colors[0][0]/255;
				g = _project2Colors[0][1]/255;
				b = _project2Colors[0][2]/255;
			}else {
				r = _project2Colors[1][0]/255;
				g = _project2Colors[1][1]/255;
				b = _project2Colors[1][2]/255;
			}
		}
			break;
			
		case PROJECT3:
		{
			if(isGetFirstRGB){
				r = _project3Colors[0][0]/255;
				g = _project3Colors[0][1]/255;
				b = _project3Colors[0][2]/255;
			}else {
				r = _project3Colors[1][0]/255;
				g = _project3Colors[1][1]/255;
				b = _project3Colors[1][2]/255;
			}
			
		}
			break;
		case PROJECT4:
		{
			if(isGetFirstRGB){
				r = _project4Colors[0][0]/255;
				g = _project4Colors[0][1]/255;
				b = _project4Colors[0][2]/255;
			}else {
				r = _project4Colors[1][0]/255;
				g = _project4Colors[1][1]/255;
				b = _project4Colors[1][2]/255;
			}
		}
			break;
		case PROJECT5:
		{
			if(isGetFirstRGB){
				r = _project5Colors[0][0]/255;
				g = _project5Colors[0][1]/255;
				b = _project5Colors[0][2]/255;
			}else {
				r = _project5Colors[1][0]/255;
				g = _project5Colors[1][1]/255;
				b = _project5Colors[1][2]/255;
			}
		}
			break;
		case PROJECT6:
		{
			if(isGetFirstRGB){
				r = _project6Colors[0][0]/255;
				g = _project6Colors[0][1]/255;
				b = _project6Colors[0][2]/255;
			}else {
				r = _project6Colors[1][0]/255;
				g = _project6Colors[1][1]/255;
				b = _project6Colors[1][2]/255;
			}
			
		}
			break;
		case PROJECT7:
		{
			if(isGetFirstRGB){
				r = _project7Colors[0][0]/255;
				g = _project7Colors[0][1]/255;
				b = _project7Colors[0][2]/255;
			}else {
				r = _project7Colors[1][0]/255;
				g = _project7Colors[1][1]/255;
				b = _project7Colors[1][2]/255;
			}
		}
			break;
		case PROJECT8:
		{
			if(isGetFirstRGB){
				r = _project8Colors[0][0]/255;
				g = _project8Colors[0][1]/255;
				b = _project8Colors[0][2]/255;
			}else {
				r = _project8Colors[1][0]/255;
				g = _project8Colors[1][1]/255;
				b = _project8Colors[1][2]/255;
			}
		}
			break;
		case PROJECT9:
		{
			if(isGetFirstRGB){
				r = _project9Colors[0][0]/255;
				g = _project9Colors[0][1]/255;
				b = _project9Colors[0][2]/255;
			}else {
				r = _project9Colors[1][0]/255;
				g = _project9Colors[1][1]/255;
				b = _project9Colors[1][2]/255;
			}
		}
			break;
		case PROJECT10:
		{
			if(isGetFirstRGB){
				r = _project10Colors[0][0]/255;
				g = _project10Colors[0][1]/255;
				b = _project10Colors[0][2]/255;
			}else {
				r = _project10Colors[1][0]/255;
				g = _project10Colors[1][1]/255;
				b = _project10Colors[1][2]/255;
			}
		}
			break;
		case PROJECT11:
		{
			if(isGetFirstRGB){
				r = _project11Colors[0][0]/255;
				g = _project11Colors[0][1]/255;
				b = _project11Colors[0][2]/255;
			}else {
				r = _project11Colors[1][0]/255;
				g = _project11Colors[1][1]/255;
				b = _project11Colors[1][2]/255;
			}
		}
			break;
		case PROJECT12:
		{
			if(isGetFirstRGB){
				r = _project12Colors[0][0]/255;
				g = _project12Colors[0][1]/255;
				b = _project12Colors[0][2]/255;
			}else {
				r = _project12Colors[1][0]/255;
				g = _project12Colors[1][1]/255;
				b = _project12Colors[1][2]/255;
			}
		}
			break;
		case PROJECT13:
		{
			if(isGetFirstRGB){
				r = _project13Colors[0][0]/255;
				g = _project13Colors[0][1]/255;
				b = _project13Colors[0][2]/255;
			}else {
				r = _project13Colors[1][0]/255;
				g = _project13Colors[1][1]/255;
				b = _project13Colors[1][2]/255;
			}
		}
			break;
		case PROJECT14:
		{
			if(isGetFirstRGB){
				r = _project14Colors[0][0]/255;
				g = _project14Colors[0][1]/255;
				b = _project14Colors[0][2]/255;
			}else {
				r = _project14Colors[1][0]/255;
				g = _project14Colors[1][1]/255;
				b = _project14Colors[1][2]/255;
			}
			
		}
			break;
		case PROJECT15:
		{
			if(isGetFirstRGB){
				r = _project15Colors[0][0]/255;
				g = _project15Colors[0][1]/255;
				b = _project15Colors[0][2]/255;
			}else {
				r = _project15Colors[1][0]/255;
				g = _project15Colors[1][1]/255;
				b = _project15Colors[1][2]/255;
			}
		}
			break;
		case PROJECT16:
		{
			if(isGetFirstRGB){
				r = _project16Colors[0][0]/255;
				g = _project16Colors[0][1]/255;
				b = _project16Colors[0][2]/255;
			}else {
				r = _project16Colors[1][0]/255;
				g = _project16Colors[1][1]/255;
				b = _project16Colors[1][2]/255;
			}
			
		}
			break;
		case PROJECT17:
		{
			if(isGetFirstRGB){
				r = _project17Colors[0][0]/255;
				g = _project17Colors[0][1]/255;
				b = _project17Colors[0][2]/255;
			}else {
				r = _project17Colors[1][0]/255;
				g = _project17Colors[1][1]/255;
				b = _project17Colors[1][2]/255;
			}
		}
			break;
		case PROJECT18:
		{
			if(isGetFirstRGB){
				r = _project18Colors[0][0]/255;
				g = _project18Colors[0][1]/255;
				b = _project18Colors[0][2]/255;
			}else {
				r = _project18Colors[1][0]/255;
				g = _project18Colors[1][1]/255;
				b = _project18Colors[1][2]/255;
			}
		}
			break;
		case PROJECT19:
		{
			if(isGetFirstRGB){
				r = _project19Colors[0][0]/255;
				g = _project19Colors[0][1]/255;
				b = _project19Colors[0][2]/255;
			}else {
				r = _project19Colors[1][0]/255;
				g = _project19Colors[1][1]/255;
				b = _project19Colors[1][2]/255;
			}
		}
			break;
		case PROJECT20:
		{
			if(isGetFirstRGB){
				r = _project20Colors[0][0]/255;
				g = _project20Colors[0][1]/255;
				b = _project20Colors[0][2]/255;
			}else {
				r = _project20Colors[1][0]/255;
				g = _project20Colors[1][1]/255;
				b = _project20Colors[1][2]/255;
			}
			
		}
			break;
		case OTHER:
		{
			if(isGetFirstRGB){
				r = _otherColors[0][0]/255;
				g = _otherColors[0][1]/255;
				b = _otherColors[0][2]/255;
			}else {
				r = _otherColors[1][0]/255;
				g = _otherColors[1][1]/255;
				b = _otherColors[1][2]/255;
			}

		}
			break;
	}
	
	return [UIColor colorWithRed:r green:g blue:b alpha:1];
}
*/

- (NSComparisonResult)compareDate:(NSDate*) date1 withDate:(NSDate*) date2
{
    if (!date1 && !date2) return NSOrderedSame;
    if (!date1 && date2) return NSOrderedAscending;
    if (date1 && !date2) return NSOrderedDescending;
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	unsigned flags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
	
	NSDateComponents *comps1 = [gregorian components:flags fromDate:date1];
	NSDateComponents *comps2 = [gregorian components:flags fromDate:date2];
	
	if ([comps2 year] > [comps1 year])
	{
		//nang 3.6
		[gregorian release];
		return NSOrderedAscending;
	}
	else if ([comps2 year] < [comps1 year])
	{
		//nang 3.6
		[gregorian release];
		return NSOrderedDescending;
	}
	else if ([comps2 month] > [comps1 month])
	{
		//nang 3.6
		[gregorian release];
		return NSOrderedAscending;		
	}
	else if ([comps2 month] < [comps1 month])
	{
		//nang 3.6
		[gregorian release];
		return NSOrderedDescending;		
	}
	else if ([comps2 day] > [comps1 day])
	{
		//nang 3.6
		[gregorian release];
		return NSOrderedAscending;		
	}
	else if ([comps2 day] < [comps1 day])
	{
		//nang 3.6
		[gregorian release];
		return NSOrderedDescending;
	}
	else if ([comps2 hour] > [comps1 hour])
	{
		//nang 3.6
		[gregorian release];
		return NSOrderedAscending;
	}
	else if ([comps2 hour] < [comps1 hour])
	{
		//nang 3.6
		[gregorian release];
		return NSOrderedDescending;		
	}
	else if ([comps2 minute] > [comps1 minute])
	{
		//nang 3.6
		[gregorian release];
		return NSOrderedAscending;		
	}
	else if ([comps2 minute] < [comps1 minute])
	{
		//nang 3.6
		[gregorian release];
		return NSOrderedDescending;		
	}
	else if ([comps2 second] > [comps1 second])
	{
		//nang 3.6
		[gregorian release];
		return NSOrderedAscending;		
	}
	else if ([comps2 second] < [comps1 second])
	{
		//nang 3.6
		[gregorian release];
		return NSOrderedDescending;
	}
	else 
	{
		//nang 3.6
		[gregorian release];
		return NSOrderedSame;
	}
	
	[gregorian release];
	 
	//return [date1 compare:date2];
}

- (NSComparisonResult)compareDateNoTime:(NSDate*) date1 withDate:(NSDate*) date2
{
    if (!date1 && !date2) return NSOrderedSame;
    if (!date1 && date2) return NSOrderedAscending;
    if (date1 && !date2) return NSOrderedDescending;

	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	unsigned flags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
	
	NSDateComponents *comps1 = [gregorian components:flags fromDate:date1];
	NSDateComponents *comps2 = [gregorian components:flags fromDate:date2];
	
	if ([comps2 year] > [comps1 year])
	{
		//nang 3.6
		[gregorian release];
		return NSOrderedAscending;
	}
	else if ([comps2 year] < [comps1 year])
	{
		//nang 3.6
		[gregorian release];
		return NSOrderedDescending;
	}
	else if ([comps2 month] > [comps1 month])
	{
		//nang 3.6
	 [gregorian release];
		return NSOrderedAscending;		
	}
	else if ([comps2 month] < [comps1 month])
	{
		//nang 3.6
	 [gregorian release];
		return NSOrderedDescending;		
	}
	else if ([comps2 day] > [comps1 day])
	{
		//nang 3.6
	 [gregorian release];
		return NSOrderedAscending;		
	}
	else if ([comps2 day] < [comps1 day])
	{
		//nang 3.6
	 [gregorian release];
		return NSOrderedDescending;
	}
	else 
	{
		//nang 3.6
	 [gregorian release];
		return NSOrderedSame;
	}
	
	[gregorian release];
	 
	//return [date1 compare:date2];
}

- (UIImage *) takeSnapShot:(UIView *)view size:(CGSize) size
{
	UIGraphicsBeginImageContext(size); 
	[view.layer renderInContext:UIGraphicsGetCurrentContext()]; 
	
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext(); 
	
	UIGraphicsEndImageContext(); 
	
	return img;
}

- (void) deleteSuspectedDuplication
{
	NSMutableDictionary *taskDict = [NSMutableDictionary dictionaryWithCapacity:taskmanager.taskList.count];
	
	for (Task *task in taskmanager.taskList)
	{
		if (task.primaryKey >= 0)
		{
			NSMutableArray *arr = [taskDict objectForKey:task.taskName];
			
			if (arr == nil)
			{
				arr = [NSMutableArray arrayWithCapacity:2];
				
				[taskDict setObject:arr forKey:task.taskName];
			}
			
			[arr addObject:task];			
		}
	}
	
	NSEnumerator *enumerator = [taskDict objectEnumerator];
	
	NSMutableArray *arr;
	
	NSMutableArray *delList = [NSMutableArray arrayWithCapacity:10];
	
	while (arr = [enumerator nextObject]) 
	{
		if (arr.count >= 2)
		{
			Task *task = [arr objectAtIndex:0];
			
			for (int i=1; i<arr.count; i++)
			{
				Task *tmp = [arr objectAtIndex:i];
				
				Task *taskDel = nil;
				
				if ((tmp.taskPinned==0 && task.taskPinned==0) ||( [self compareDate:task.taskStartTime withDate:tmp.taskStartTime] == NSOrderedSame &&
					 [self compareDate:task.taskEndTime withDate:tmp.taskEndTime] == NSOrderedSame && task.taskPinned == tmp.taskPinned))
				{
				/*	if (task.iCalIdentifier != nil && ![task.iCalIdentifier isEqualToString:@""] && 
						(tmp.iCalIdentifier == nil || [task.iCalIdentifier isEqualToString:@""]))
					{
						taskDel = tmp;
					}
					else if (tmp.iCalIdentifier != nil && ![tmp.iCalIdentifier isEqualToString:@""] && 
							 (task.iCalIdentifier == nil || [task.iCalIdentifier isEqualToString:@""]))
						
					{
						taskDel = task;
						task = tmp;
					}
					//else if ([self compareDate:task.taskDateUpdate withDate:tmp.taskDateUpdate] == NSOrderedAscending)
					else if (tmp.primaryKey > task.primaryKey)
					{
						taskDel = task;
						task = tmp;
					}
					else
					{
						taskDel = tmp;
					}
                 */
                    
                    taskDel=tmp;
				}
				
				if (taskDel != nil)
				{
					[delList addObject:taskDel];
				}
			}
		}
	}
	
    needStopSync=YES;

	for (Task *task in delList)
	{
		task.isDeletedFromGCal = YES;
		
		NSInteger delType = -1;
		
		if (task.parentRepeatInstance == -1 && task.taskRepeatID > 0 && task.taskPinned)
		{
			delType = 2;
		}
		else if (task.taskPinned && task.parentRepeatInstance >-1)
		{
			delType = 1;
		}
		
		[taskmanager deleteTask:task.primaryKey isDeleteFromDB:YES deleteREType:delType];	
        
        if ([task.iCalIdentifier length]>0) {
            taskmanager.currentSetting.deletedICalEvents=[taskmanager.currentSetting.deletedICalEvents stringByAppendingFormat:@"|%@",task.iCalIdentifier];
            [taskmanager.currentSetting update];
        }
        
        if ([task.reminderIdentifier length]>0) {
            taskmanager.currentSetting.deletedReminders=[taskmanager.currentSetting.deletedReminders stringByAppendingFormat:@"|%@",task.reminderIdentifier];
            [taskmanager.currentSetting update];
        }
	}
	
    needStopSync=NO;

    if (taskmanager.currentSetting.autoICalSync) {
        
        if (taskmanager.currentSetting.enableSyncICal) {
            
            [taskmanager.ekSync backgroundFullSync];
        }
        
        if (taskmanager.currentSetting.enabledReminderSync) {
            [taskmanager.reminderSync backgroundFullSync];
        }
    }
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"deleteDupTitleText", @"") 
													message:NSLocalizedString(@"finishedText", @"") 
												   delegate:self 
										  cancelButtonTitle:NSLocalizedString(@"_okText", @"") 
										  otherButtonTitles:nil];
	[alert show];
	[alert release];		
}

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert {
	NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
	unsigned hexNum;
	if (![scanner scanHexInt:&hexNum]) return nil;
	
	int r = (hexNum >> 16) & 0xFF;
	int g = (hexNum >> 8) & 0xFF;
	int b = (hexNum) & 0xFF;
	
	return [UIColor colorWithRed:r / 255.0f
						   green:g / 255.0f
							blue:b / 255.0f
						   alpha:1.0f];
}

+ (NSString *)hexStringFromColor:(UIColor *)colorVal
{
	CGFloat r,g,b,a;
	
	CGColorRef color = [colorVal CGColor];
	
	int numComponents = CGColorGetNumberOfComponents(color);
	
	if (numComponents == 4)
	{
		const CGFloat *components = CGColorGetComponents(color);
		r = components[0];
		g = components[1];
		b = components[2];
		a = components[3];
	}	
	
	r = MIN(MAX(r, 0.0f), 1.0f);
	g = MIN(MAX(g, 0.0f), 1.0f);
	b = MIN(MAX(b, 0.0f), 1.0f);
	
	unsigned hexNum = (((int)roundf(r * 255)) << 16)
	| (((int)roundf(g * 255)) << 8)
	| (((int)roundf(b * 255)));	
	
	return [NSString stringWithFormat:@"%0.6X", hexNum];
}

/*
+ (NSDate *)dateWithDSTAdjusted:(NSDate *)dateArg {
	if (!dateArg) return nil;
	NSDate *date = dateArg;
	NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	//[calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[calendar setTimeZone:[NSTimeZone defaultTimeZone]];
	NSDateComponents *components = [calendar components:(
														 NSYearCalendarUnit |
														 NSMonthCalendarUnit |
														 NSDayCalendarUnit |
														 NSHourCalendarUnit |
														 NSMinuteCalendarUnit |
														 NSSecondCalendarUnit)
											   fromDate:date];
	[calendar setTimeZone:[NSTimeZone defaultTimeZone]];
	date = [calendar dateFromComponents:components];
	return date;
}
*/

+ (NSInteger)offsetForDate:(NSDate *)date {
	NSInteger offset=0;
	NSString *str=[date description];
	if([str length]>21){
		NSString *str1=[str substringFromIndex:21];
		if([str1 length]>2){
			offset= [[str1 substringToIndex:2] intValue];
		}
	}
	
	return offset;
}


- (NSDate *)dateWithNewOffset:(NSDate *)date offsetFromDate:(NSDate *)offsetFromDate{
	if (!date) return nil;
	NSDate *retDate=date;

	if(![[self getLongStringFromDate:retDate] isEqualToString:[self getLongStringFromDate:offsetFromDate]]){	  
		retDate=[retDate dateByAddingTimeInterval:dstOffset];
		if([self offsetForDate:retDate]>[self offsetForDate:date]){
			retDate=[retDate dateByAddingTimeInterval:-dstOffset];   
		}
	}else {
		if(![App_defaultTimeZone isDaylightSavingTimeForDate:[retDate dateByAddingTimeInterval:-dstOffset]]){  
			retDate=[offsetFromDate dateByAddingTimeInterval:-dstOffset];
			if([self offsetForDate:retDate]>[self offsetForDate:date]){
				retDate=[retDate dateByAddingTimeInterval:dstOffset]; 
			}
		}else {
			retDate=[retDate dateByAddingTimeInterval:dstOffset];
			if([self offsetForDate:retDate]>[self offsetForDate:date]){
				retDate=[retDate dateByAddingTimeInterval:-dstOffset];   
			}
		}
	}
	
	return retDate;
}


- (NSDate *) dateByAddNumDay:(int)argDay toDate:(NSDate *)argDate
{
	NSDateComponents *offset = [[NSDateComponents alloc] init];
	[offset setYear:0];
	[offset setMonth:0];
	[offset setDay:argDay];
	[offset setHour:0];
	[offset setMinute:0];
	[offset setSecond:0];	
	NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:offset toDate:argDate options:0];
	[offset release];
	return newDate;
}

- (NSDate *) dateByAddNumSecond:(int)argSecond toDate:(NSDate *)argDate
{
	NSDateComponents *offset = [[NSDateComponents alloc] init];
	[offset setYear:0];
	[offset setMonth:0];
	[offset setDay:0];
	[offset setHour:0];
	[offset setMinute:0];
	[offset setSecond:argSecond];	
	NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:offset toDate:argDate options:0];
	[offset release];
	return newDate;
}

- (NSDate *)addTimeInterval:(int)argSecond :(NSDate *)argDate 
{
	if (!argDate || argDate==0) return argDate;
	return [self dateByAddNumSecond:argSecond toDate:argDate];
}

- (NSDate *)dateWithoutDST:(NSDate *)date
{
	return [date dateByAddingTimeInterval:[[NSTimeZone defaultTimeZone] daylightSavingTimeOffsetForDate:date]];
}

//EK Sync
+ (NSDate *)getEndDate:(NSDate *)date
{
    if (!date) return nil;
    
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	
	NSDateComponents *dtcomps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
	
	dtcomps.hour = 23;
	dtcomps.minute = 59;
	dtcomps.second = 60;
	
	return [gregorian dateFromComponents:dtcomps];	
}
 
-(NSString *)getAPNSAlertFromTask:(Task*)task{
	NSString *ret=@"";
	if([task.taskAlertValues length]>0){
		NSArray *alertList=[task.taskAlertValues componentsSeparatedByString:@"/"];
		if(alertList.count>0){
			for(NSInteger i=1; i<alertList.count;i++){
				NSArray *alertValArr=[(NSString *)[alertList objectAtIndex:i] componentsSeparatedByString:@"|"];
				if([[alertValArr objectAtIndex:1] intValue]==3){
					ret=[ret stringByAppendingFormat:@"/%@",[alertList objectAtIndex:i]];
				}
			}
		}
	}
	
	return ret;
}

//This will updates all data (include keys) for events that are existing on Server for each invidual event.
-(void)uploadAlertsForTasks:(Task*)task isAddNew:(BOOL)isAddNew withPNSAlert:(NSString*)withPNSAlert oldDevToken:(NSString*)oldDevToken oldTaskPNSID:(NSString*)oldTaskPNSID{

	/*
//	BOOL ret=NO;
	// Configure the new event with information from the location.
	if(!isInternetConnected){
		UIAlertView *alrt=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"noInternetConnectionText", @"")
													 message:NSLocalizedString(@"cannotUpdateAlertMsg", @"")
													delegate:nil
										   cancelButtonTitle:NSLocalizedString(@"okText", @"") 
										   otherButtonTitles:nil];
		[alrt show];
		[alrt release];
		//goto endAdd;
		return;
	}
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	ServerAlertInfo *info=[[ServerAlertInfo alloc] init];
	info.task=task;
	info.isAddNew=isAddNew;
	info.alertStrValues=withPNSAlert;
	info.oldDevToken=oldDevToken;
	info.oldPNSID=oldTaskPNSID;
	
	//[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(uploadAlerts:) userInfo:info repeats:YES];
	[NSThread detachNewThreadSelector:@selector(uploadAlerts:) toTarget:self withObject:info];
     */
}

//This will updates all data (include keys) for events that are existing on Server for each invidual event.
-(void)uploadAlerts:(id)sender{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	printf("\nStarting upload alert to Server Provider....");
	ServerAlertInfo *info=(ServerAlertInfo *)sender;
	
	/*
	 turning the image into a NSData object
	 getting the image back out of the UIImageView
	 setting the quality to 90
	 */
	// setting up the URL to post to
	
	//for local server, enable this
//	NSString *urlString = @"http://192.168.1.20:8080/UploadDataSTPNS";
	
	//for remote server, enable this
	
	NSString *urlString;
	
#ifdef ST_BASIC	
	//urlString= @"http://192.168.1.17:8080/sttaskspns/UploadData";
	urlString=@"http://www.lclbackend.com:8080/sttaskspns/UploadData";
#else
	urlString= @"http://74.208.174.50:8080/UploadDataSTPNS";
#endif
	// setting up the request object now
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"POST"];
	
	/*
	 add some header info now
	 we always need a boundary when we post a file
	 also we need to set the content type
	 
	 You might want to generate a random boundary.. this is just the same
	 as my output from wireshark on a valid html post
	 */
	NSString *boundary = [NSString stringWithString:@"-----------------iQameraUploadPhoto"];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[request setValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	/*
	 now lets create the body of the post
	 */
	NSMutableData *body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"devTokenNew\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@",dev_token] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"taskPNSIDNew\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@",info.task.PNSKey] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];

	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"devToken\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@",info.oldDevToken] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"taskPNSID\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@",info.oldPNSID] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"todo\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@",info.isAddNew?@"add":@"update"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"taskRepeatID\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%d",info.task.taskRepeatID] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"taskOptions\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@",info.task.taskRepeatOptions] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"taskRepeatExceptions\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@",info.task.taskRepeatExceptions] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	//[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"updateTime\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	//[body appendData:[[NSString stringWithFormat:@"%@",[[NSDate date] description]] dataUsingEncoding:NSUTF8StringEncoding]];
	//[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"updateTime\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%lf",[[NSDate date] timeIntervalSince1970]] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	//[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"taskStartTime\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	//[body appendData:[[NSString stringWithFormat:@"%@",[task.taskStartTime description]] dataUsingEncoding:NSUTF8StringEncoding]];
	//[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"taskStartTime\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%lf",(info.task.taskPinned==1?
														 [info.task.taskStartTime timeIntervalSince1970]
														 :[info.task.specifiedAlertTime timeIntervalSince1970])] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"alertTime\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@",[info.task.taskStartTime description]] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"alertOptions\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@",info.alertStrValues] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"messageText\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@",info.task.taskName] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	// setting the body of the post to the reqeust
	[request setHTTPBody:body];
	
	//printf("\n body: %@",body);
	// now lets make the connection to the web
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
	
	if([[returnString uppercaseString] isEqual:@"SUCCESS"]){
		[info.task update];
	}else {
		if(info.isAddNew){
			info.task.PNSKey=@"";
			[info.task update];
		}
		
		UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"updateAlertFailedText", @"")  
														  message:NSLocalizedString(@"lclSeverErrorMsg", @"")
														 delegate:nil 
												cancelButtonTitle:NSLocalizedString(@"okText", @"")
												otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		
	}
	
	[info release];
	
	printf("\n%s",[returnString UTF8String]);

	[pool release];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	printf("\nEnd upload alert to Server Provider....");
}

//This will updates all dev-tokens for all events that are existing on Server.
-(void)updateForOldDevToken:(NSString*)oldDevToken{
	/*
	// Configure the new event with information from the location.
	if(!isInternetConnected){
		UIAlertView *alrt=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"noInternetConnectionText", @"")
													 message:NSLocalizedString(@"cannotUpdateAlertMsg", @"")
													delegate:nil
										   cancelButtonTitle:NSLocalizedString(@"okText", @"") 
										   otherButtonTitles:nil];
		[alrt show];
		[alrt release];
		//goto endAdd;
		return;
	}
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	//[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(uploadAlerts:) userInfo:info repeats:YES];
	[NSThread detachNewThreadSelector:@selector(updateDevTokenForAlertEvents:) toTarget:self withObject:oldDevToken];
	*/
}

//This will updates all dev-tokens for all events that are existing on Server.
-(void)updateDevTokenForAlertEvents:(id)sender{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	printf("\nStarting upload all dev-tokens for all alert events to Server Provider....");
	NSString *oldDevToken=(NSString *)sender;
	/*
	 turning the image into a NSData object
	 getting the image back out of the UIImageView
	 setting the quality to 90
	 */
	// setting up the URL to post to
	
	//for local server, enable this
	//	NSString *urlString = @"http://192.168.1.20:8080/UploadDataSTPNS";
	
	//for remote server, enable this
	NSString *urlString;
	
#ifdef ST_BASIC	
	//urlString= @"http://192.168.1.17:8080/sttaskspns/UploadData";
	urlString=@"http://www.lclbackend.com:8080/sttaskspns/UploadData";
#else
	urlString = @"http://74.208.174.50:8080/UploadDataSTPNS";
#endif
	
	// setting up the request object now
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"POST"];
	
	/*
	 add some header info now
	 we always need a boundary when we post a file
	 also we need to set the content type
	 
	 You might want to generate a random boundary.. this is just the same
	 as my output from wireshark on a valid html post
	 */
	NSString *boundary = [NSString stringWithString:@"-----------------iQameraUploadPhoto"];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[request setValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	/*
	 now lets create the body of the post
	 */
	NSMutableData *body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"devTokenNew\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@",dev_token] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"devToken\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@",oldDevToken] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"todo\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@",@"updateDevToken"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	// setting the body of the post to the reqeust
	[request setHTTPBody:body];
	
	//printf("\n body: %@",body);
	// now lets make the connection to the web
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
	
	if([[returnString uppercaseString] isEqual:@"SUCCESS"]){
		taskmanager.currentSetting.previousDevToken=dev_token;
		[taskmanager.currentSetting update];
		
		//clean all dirty on server by this old dev-token incase they can not be update because duplicate keys
		[self deleteOldAlertsOnServerForDevToken:oldDevToken];
	}else {
		
		//UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"Update Alerts Failed!" 
		//												  message:cannotUpdateAlertMsg
		//												 delegate:nil 
		//										cancelButtonTitle:@"OK" 
		//										otherButtonTitles:nil];
		//[alertView show];
		//[alertView release];
		
	}
	
	printf("\n%s",[returnString UTF8String]);
	
	[pool release];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	printf("\nEnd upload all dev-token for all alert events to Server Provider....");
}

-(void)deleteAlertsOnServerForTasks:(Task*)task{
	// Configure the new event with information from the location.
    /*
	if(!isInternetConnected){
		UIAlertView *alrt=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"noInternetConnectionText", @"")
													 message:NSLocalizedString(@"cannotUpdateAlertMsg", @"")
													delegate:nil
										   cancelButtonTitle:@"Ok" 
										   otherButtonTitles:nil];
		[alrt show];
		[alrt release];
		return;
	}
	//[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(uploadAlerts:) userInfo:task repeats:YES];
	[NSThread detachNewThreadSelector:@selector(deleteAlertsOnServerForTasksThread:) toTarget:self withObject:task];
     */
}

-(void)deleteAlertsOnServerForTasksThread:(id)sender{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	printf("\nStarting delete alert from Server Provider....");
	Task *task=(Task*)sender;	

	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

	/*
	 turning the image into a NSData object
	 getting the image back out of the UIImageView
	 setting the quality to 90
	 */
	// setting up the URL to post to
	
	//for local server, enable this
	//		NSString *urlString = @"http://192.168.1.20:8080/UploadDataSTPNS";
	
	//for remote server, enable this
	
	NSString *urlString;
#ifdef ST_BASIC	
	//urlString= @"http://192.168.1.17:8080/sttaskspns/UploadData";
	urlString=@"http://www.lclbackend.com:8080/sttaskspns/UploadData";
#else
	urlString = @"http://74.208.174.50:8080/UploadDataSTPNS";
#endif
	
	// setting up the request object now
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"POST"];
	
	/*
	 add some header info now
	 we always need a boundary when we post a file
	 also we need to set the content type
	 
	 You might want to generate a random boundary.. this is just the same
	 as my output from wireshark on a valid html post
	 */
	NSString *boundary = [NSString stringWithString:@"-----------------iQameraUploadPhoto"];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[request setValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	/*
	 now lets create the body of the post
	 */
	NSMutableData *body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"devToken\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@",dev_token] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"taskPNSID\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@",task.PNSKey] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"todo\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@",@"delete"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	// setting the body of the post to the reqeust
	[request setHTTPBody:body];
	
	//printf("\n body: %@",body);
	// now lets make the connection to the web
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
	
	if([[returnString uppercaseString] isEqual:@"SUCCESS"]){
	}else {
		UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"deleteAlertFailedText", @"")
														  message:NSLocalizedString(@"lclSeverErrorMsg", @"")
														 delegate:nil 
												cancelButtonTitle:NSLocalizedString(@"okText", @"")
												otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		
	}
	
	//NSLog(returnString);
	printf("\n%s",[returnString UTF8String]);

	[pool release];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	printf("\nEnd delete alert from Server Provider....");
}

-(BOOL)deleteOldAlertsOnServerForDevToken:(NSString*)devToken{
	BOOL ret=NO;
	// Configure the new event with information from the location.
    /*
	if(!isInternetConnected){
		UIAlertView *alrt=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"noInternetConnectionText", @"")
													 message:NSLocalizedString(@"cannotUpdateAlertMsg", @"")
													delegate:nil
										   cancelButtonTitle:@"Ok" 
										   otherButtonTitles:nil];
		[alrt show];
		[alrt release];
		goto endAdd;
	}
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	printf("\nStarting delete old alert with old token from Server Provider....");
	// setting up the URL to post to
	
	//for local server, enable this
	//	NSString *urlString = @"http://192.168.1.20:8080/UploadDataSTPNS";
	
	//for remote server, enable this
	
	NSString *urlString;
#ifdef ST_BASIC	
	//urlString= @"http://192.168.1.17:8080/sttaskspns/UploadData";
	urlString=@"http://www.lclbackend.com:8080/sttaskspns/UploadData";
#else
	urlString = @"http://www.lclbackend.com:8080/UploadDataSTPNS";
#endif
	
	// setting up the request object now
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"POST"];
	
	NSString *boundary = [NSString stringWithString:@"-----------------iQameraUploadPhoto"];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[request setValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	NSMutableData *body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"devToken\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@",devToken] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"todo\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@",@"deleteOldData"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	// setting the body of the post to the reqeust
	[request setHTTPBody:body];
	
	//printf("\n body: %@",body);
	// now lets make the connection to the web
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
	
	if([[returnString uppercaseString] isEqual:@"SUCCESS"]){
		ret=YES;
	}else {
	//	ret=NO;
	//	UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"Delete Old Alerts with ol Failed!" 
	//													  message:cannotUpdateAlertMsg
	//													 delegate:nil 
	//											cancelButtonTitle:@"OK" 
	//											otherButtonTitles:nil];
	//	[alertView show];
	//	[alertView release];
		
	}
	
	//[location release];
	
	//NSLog(returnString);
	printf("\n%s",[returnString UTF8String]);
endAdd:{}
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	printf("\nEnd delete old alert with old token from Server Provider....");
     */
	return ret;
}

-(NSString*)statisticNumberOfTasks{
	NSInteger numberOfTasks=0;
	NSInteger numberOfDTasks=0;
	NSInteger numberOfEvents=0;
	NSInteger numberOfRE=0;
	NSInteger numberOfADE=0;
	NSInteger numberOfRADE=0;
	NSInteger numberOfDummies=0;
	
	for(Task *tsk in taskmanager.taskList){
		if(tsk.taskPinned==0){
			if(tsk.taskIsUseDeadLine==1){
				numberOfDTasks+=1;
			}else {
				numberOfTasks+=1;
			}
		}else if(tsk.taskPinned==1){
			if(tsk.isAllDayEvent==1){
				if(tsk.taskRepeatID==0){
					numberOfADE+=1;
				}else {
					numberOfRADE+=1;
				}
			}else {
				if(tsk.taskRepeatID==0){
					numberOfEvents+=1;
				}else {
					numberOfRADE+=1;
				}
			}
		}else {
			numberOfDummies+=1;
		}

	}
	
	return [NSString stringWithFormat:@"- Number of Tasks: %d\n- Number of Dtasks: %d\n- Number of Events: %d\n- Number of RE: %d\n- Number of ADE: %d\n- Number of RADE: %d\n-Number of Dummies: %d\n",numberOfTasks,numberOfDTasks,numberOfEvents,numberOfRE,numberOfADE,numberOfRADE,numberOfDummies];
}

#pragma mark RGBColor
-(ColorObject*)colorForColorNameNo:(NSInteger)colorNameNo inPalette:(NSInteger)inPalette {
	ColorObject *ret=[[[ColorObject alloc] init] autorelease];
	switch (inPalette) {
		case PRIME:
			switch (colorNameNo) {
					//{ {8.0, 126.0, 174.0}, {13.0, 151.0, 207.0}, {15.0, 161.0, 220.0} };
				case PRIME_0:
					ret.R1=8.0;
					ret.G1=126.0;
					ret.B1=174.0;
					
					ret.R2=13.0;
					ret.G2=151.0;
					ret.B2=207.0;
					
					ret.R3=15.0;
					ret.G3=161.0;
					ret.B3=220.0;
					break;
				case PRIME_1:
					//{ {190.0, 109.0, 0.0}, {239.0, 148.0, 27.0}, {255.0, 160.0, 36.0} };
					ret.R1=190.0;
					ret.G1=109.0;
					ret.B1=0.0;
					
					ret.R2=239.0;
					ret.G2=148.0;
					ret.B2=27.0;
					
					ret.R3=255.0;
					ret.G3=160.0;
					ret.B3=36.0;
					break;
				case PRIME_2:
					//prime2[3][3] = { {141.0, 111.0, 71.0}, {176.0, 147.0, 110.0}, {190.0, 162.0, 126.0} };
					ret.R1=141.0 ;
					ret.G1=111.0;
					ret.B1=71.0;
					
					ret.R2=176.0;
					ret.G2=147.0;
					ret.B2=110.0;
					
					ret.R3=190.0;
					ret.G3=162.0;
					ret.B3=126.0;
					break;
				case PRIME_3:
					//prime3[3][3] = { {97.0, 139.0, 11.0}, {144.0, 196.0, 0.0}, {174.0, 255.0, 0.0} };
					ret.R1=97.0 ;
					ret.G1=139.0;
					ret.B1=11.0;
					
					ret.R2=144.0;
					ret.G2=196.0;
					ret.B2=0.0;
					
					ret.R3=174.0;
					ret.G3=255.0;
					ret.B3=0.0;
					break;
				case PRIME_4:
					//prime4[3][3] = { {174.0, 159.0, 113.0}, {186.0, 171.0, 126.0}, {187.0, 172.0, 128.0} };
					ret.R1=174.0 ;
					ret.G1=159.0;
					ret.B1=113.0;
					
					ret.R2=186.0;
					ret.G2=171.0;
					ret.B2=126.0;
					
					ret.R3=187.0;
					ret.G3=172.0;
					ret.B3=128.0;
					break;
				case PRIME_5:
					//prime5[3][3] = { {122.0, 54.0, 122.0}, {171.0, 86.0, 171.0}, {185.0, 95.0, 185.0} };
					
					ret.R1=122.0 ;
					ret.G1=54.0;
					ret.B1=122.0;
					
					ret.R2=171.0;
					ret.G2=86.0;
					ret.B2=171.0;
					
					ret.R3=185.0;
					ret.G3=95.0;
					ret.B3=185.0;
					break;
				case PRIME_6:
					//prime6[3][3] = { {112.0, 87.0, 112.0}, {106.0, 14.0, 88.0}, {164.0, 137.0, 164.0} };
					
					ret.R1=112.0 ;
					ret.G1=87.0;
					ret.B1=112.0;
					
					ret.R2=106.0;
					ret.G2=14.0;
					ret.B2=88.0;
					
					ret.R3=164.0;
					ret.G3=137.0;
					ret.B3=164.0;
					break;
				case PRIME_7:
					//prime7[3][3] = { {134.0, 90.0, 90.0}, {167.0, 128.0, 128.0}, {182.0, 145.0, 145.0} };
					
					ret.R1=134.0 ;
					ret.G1=90.0;
					ret.B1=90.0;
					
					ret.R2=167.0;
					ret.G2=128.0;
					ret.B2=128.0;
					
					ret.R3=182.0;
					ret.G3=145.0;
					ret.B3=145.0;
					break;
			}
			break;
		case PASTEL:
			switch (colorNameNo) {
				case PASTEL_0:
					//Aqua 
					//pastel0[3][3] = { {41.0, 82.0, 163.0}, {76.0, 117.0, 198.0}, {92.0, 133.0, 214.0} };
					ret.R1=41.0;
					ret.G1=82.0;
					ret.B1=163.0;
					
					ret.R2=76.0;
					ret.G2=117.0;
					ret.B2=198.0;
					
					ret.R3=92.0;
					ret.G3=133.0;
					ret.B3=214.0;
					break;
				case PASTEL_1:
					//Violet 
					//pastel1[3][3] = { {177.0, 68.0, 14.0}, {229.0, 106.0, 46.0},  {239.0, 114.0, 52.0} };
					
					ret.R1=177.0;
					ret.G1=68.0;
					ret.B1=14.0;
					
					ret.R2=229.0;
					ret.G2=106.0;
					ret.B2=46.0;
					
					ret.R3=239.0;
					ret.G3=114.0;
					ret.B3=52.0;
					break;
				case PASTEL_2:
					//GoldenRod
					//pastel2[3][3] = { {147.0, 147.0, 37.0}, {168.0, 169.0, 41.0}, {168.0, 168.0, 107.0} };
					
					ret.R1=147.0;
					ret.G1=147.0;
					ret.B1=37.0;
					
					ret.R2=168.0;
					ret.G2=169.0;
					ret.B2=41.0;
					
					ret.R3=168.0;
					ret.G3=168.0;
					ret.B3=107.0;
					break;
					
					//
				case PASTEL_3:
					//Chartreuse
					//pastel3[3][3] = { {13.0, 120.0, 19.0}, {21.0, 189.0, 30.0},  {23.0, 211.0, 33.0} };
					ret.R1=13.0;
					ret.G1=120.0;
					ret.B1=19.0;
					
					ret.R2=21.0;
					ret.G2=189.0;
					ret.B2=30.0;
					
					ret.R3=23.0;
					ret.G3=211.0;
					ret.B3=33.0;
					break;
					
				case PASTEL_4:
					//YellowGreen
					//pastel4[3][3] = { {136.0, 136.0, 14.0}, {203.0, 203.0, 20.0}, {227.0, 227.0, 22.0} };
					
					ret.R1=136.0;
					ret.G1=136.0;
					ret.B1=14.0;
					
					ret.R2=203.0;
					ret.G2=203.0;
					ret.B2=20.0;
					
					ret.R3=227.0;
					ret.G3=227.0;
					ret.B3=22.0;
					break;
					
				case PASTEL_5:
					//Pink
					//pastel5[3][3] = { {82.0, 41.0, 163.0}, {109.0, 61.0, 206.0}, {133.0, 92.0, 214.0} };
					
					ret.R1=82.0;
					ret.G1=41.0;
					ret.B1=163.0;
					
					ret.R2=109.0;
					ret.G2=61.0;
					ret.B2=206.0;
					
					ret.R3=133.0;
					ret.G3=92.0;
					ret.B3=214.0;
					break;
				case PASTEL_6:
					//Straw
					//pastel6[3][3] = { {128.0, 101.0, 180.0}, {151.0, 126.0, 200.0}, {173.0, 150.0, 219.0} };
					
					ret.R1=128.0 ;
					ret.G1=101.0;
					ret.B1=180.0;
					
					ret.R2=151.0;
					ret.G2=126.0;
					ret.B2=200.0;
					
					ret.R3=173.0;
					ret.G3=150.0;
					ret.B3=219.0;
					break;
				case PASTEL_7:
					//Neutrality
					//pastel7[3][3] = { {106.0, 106.0, 106.0}, {136.0, 136.0, 136.0}, {162.0, 161.0, 161.0} };
					
					ret.R1=106.0 ;
					ret.G1=106.0;
					ret.B1=106.0;
					
					ret.R2=136.0;
					ret.G2=136.0;
					ret.B2=136.0;
					
					ret.R3=162.0;
					ret.G3=161.0;
					ret.B3=161.0;
					break;
			}
			break;
			
		case VINTAGE:
			switch (colorNameNo) {
				case VINTAGE_0:
					//Errands
					//vintage0[3][3] = { {6.0, 6.0, 181.0}, {24.0, 24.0, 211.0}, {52.0, 52.0, 245.0} };
					
					ret.R1=6.0 ;
					ret.G1=6.0;
					ret.B1=181.0;
					
					ret.R2=24.0;
					ret.G2=24.0;
					ret.B2=211.0;
					
					ret.R3=52.0;
					ret.G3=52.0;
					ret.B3=245.0;
					break;
				case VINTAGE_1:
					//Maroon
					//vintage1[3][3] = { {163.0, 41.0, 41.0}, {202.0, 80.0, 80.0}, {214.0, 92.0, 92.0} };
					
					ret.R1=163.0;
					ret.G1=41.0;
					ret.B1=41.0;
					
					ret.R2=202.0;
					ret.G2=80.0;
					ret.B2=80.0;
					
					ret.R3=214.0;
					ret.G3=92.0;
					ret.B3=92.0;
					break;
				case VINTAGE_2:
					//Joy
					//vintage2[3][3] = { {88.0, 65.0, 21.0}, {123.0, 91.0, 28.0},  {152.0, 112.0, 33.0} };
					
					ret.R1=88.0;
					ret.G1=65.0;
					ret.B1=21.0;
					
					ret.R2=123.0;
					ret.G2=91.0;
					ret.B2=28.0;
					
					ret.R3=152.0;
					ret.G3=112.0;
					ret.B3=33.0;
					break;
				case VINTAGE_3:
					//Recreation
					//vintage3[3][3] = { {42.0, 105.0, 73.0}, {15.0, 139.0, 109.0}, {3.0, 150.0, 124.0} };
					
					ret.R1=42.0 ;
					ret.G1=105.0;
					ret.B1=73.0;
					
					ret.R2=15.0;
					ret.G2=139.0;
					ret.B2=109.0;
					
					ret.R3=3.0;
					ret.G3=150.0;
					ret.B3=124.0;
					break;
				case VINTAGE_4:
					//Moss
					//vintage4[3][3] = { {171.0, 139.0, 0.0}, {210.0, 177.0, 101.0}, {255.0, 212.0, 20.0} };
					
					ret.R1=171.0 ;
					ret.G1=139.0;
					ret.B1=0.0;
					
					ret.R2=210.0;
					ret.G2=177.0;
					ret.B2=101.0;
					
					ret.R3=255.0;
					ret.G3=212.0;
					ret.B3=20.0;
					break;
				case VINTAGE_5:
					//Lavender
					//vintage5[3][3] = { {8.0, 126.0, 174.0}, {13.0, 151.0, 207.0}, {15.0, 161.0, 220.0} };
					
					ret.R1=8.0 ;
					ret.G1=126.0;
					ret.B1=174.0;
					
					ret.R2=13.0;
					ret.G2=151.0;
					ret.B2=207.0;
					
					ret.R3=15.0;
					ret.G3=161.0;
					ret.B3=220.0;
					break;
				case VINTAGE_6:
					//Wood
					//vintage6[3][3] = { {177.0, 54.0, 95.0}, {203.0, 100.0, 134.0}, {213.0, 118.0, 150.0} };
					
					ret.R1=177.0 ;
					ret.G1=54.0;
					ret.B1=95.0;
					
					ret.R2=203.0;
					ret.G2=100.0;
					ret.B2=134.0;
					
					ret.R3=213.0;
					ret.G3=118.0;
					ret.B3=150.0;
					break;
				case VINTAGE_7:
					//SlateGrey
					//vintage7[3][3] = { {64.0, 63.0, 63.0}, {91.0, 91.0, 91.0}, {115.0, 115.0, 115.0} };
					
					ret.R1=64.0 ;
					ret.G1=63.0;
					ret.B1=63.0;
					
					ret.R2=91.0;
					ret.G2=91.0;
					ret.B2=91.0;
					
					ret.R3=115.0;
					ret.G3=115.0;
					ret.B3=115.0;
					break;
			}
			break;
			
		case LUXE:
			switch (colorNameNo) {
				case LUXE_0:
					//Wood
					//lux0[3][3] = { {0.0, 52.0, 105.0}, {0.0, 65.0, 129.0}, {4.0, 83.0, 162.0} }; 
					
					ret.R1=0.0 ;
					ret.G1=52.0;
					ret.B1=105.0;
					
					ret.R2=0.0;
					ret.G2=65.0;
					ret.B2=129.0;
					
					ret.R3=4.0;
					ret.G3=83.0;
					ret.B3=162.0;
					break;
				case LUXE_1:
					//SlateGrey
					//lux1[3][3] = { {81.0, 28.0, 22.0}, {103.0, 41.0, 35.0}, {118.0, 51.0, 44.0} };
					
					ret.R1=81.0 ;
					ret.G1=28.0;
					ret.B1=22.0;
					
					ret.R2=103.0;
					ret.G2=41.0;
					ret.B2=35.0;
					
					ret.R3=118.0;
					ret.G3=51.0;
					ret.B3=44.0;
					break;
				case LUXE_2:
					//GoldenRod
					//lux2[3][3] = { {62.0, 39.0, 17.0}, {114.0, 80.0, 46.0}, {145.0, 104.0, 63.0} };
					
					ret.R1=62.0 ;
					ret.G1=39.0;
					ret.B1=17.0;
					
					ret.R2=114.0;
					ret.G2=80.0;
					ret.B2=46.0;
					
					ret.R3=145.0;
					ret.G3=104.0;
					ret.B3=63.0;
					break;
				case LUXE_3:
					//Saddle Brown
					//lux3[3][3] = { {32.0, 101.0, 36.0}, {47.0, 143.0, 51.0}, {56.0, 175.0, 63.0} };
					
					ret.R1=32.0 ;
					ret.G1=101.0;
					ret.B1=36.0;
					
					ret.R2=47.0;
					ret.G2=143.0;
					ret.B2=51.0;
					
					ret.R3=56.0;
					ret.G3=175.0;
					ret.B3=63.0;
					break;
				case LUXE_4:
					//Neutrality
					//lux4[3][3] = { {141.0, 120.0, 31.0}, {168.0, 144.0, 62.0}, {186.0, 161.0, 51.0} };
					
					ret.R1=141.0;
					ret.G1=120.0;
					ret.B1=31.0;
					
					ret.R2=168.0;
					ret.G2=144.0;
					ret.B2=62.0;
					
					ret.R3=186.0;
					ret.G3=161.0;
					ret.B3=51.0;
					break;
				case LUXE_5:
					//Maroon
					//lux5[3][3] = { {27.0, 136.0, 122.0}, {45.0, 196.0, 176.0}, {51.0, 215.0, 193.0} };
					
					ret.R1=27.0 ;
					ret.G1=136.0;
					ret.B1=122.0;
					
					ret.R2=45.0;
					ret.G2=196.0;
					ret.B2=176.0;
					
					ret.R3=51.0;
					ret.G3=215.0;
					ret.B3=193.0;
					break;
				case LUXE_6:
					//Black
					//lux6[3][3] = { {88.0, 57.0, 72.0}, {100.0, 69.0, 84.0}, {110.0, 79.0, 94.0} };
					
					ret.R1=88.0;
					ret.G1=57.0;
					ret.B1=72.0;
					
					ret.R2=100.0;
					ret.G2=69.0;
					ret.B2=84.0;
					
					ret.R3=110.0;
					ret.G3=79.0;
					ret.B3=94.0;
					break;
				case LUXE_7:
					//Mascara
					//lux7[3][3] = { {2.0, 2.0, 2.0}, {47.0, 47.0, 47.0},{76.0, 76.0, 76.0} };
					
					ret.R1=2.0 ;
					ret.G1=2.0;
					ret.B1=2.0;
					
					ret.R2=47.0;
					ret.G2=47.0;
					ret.B2=47.0;
					
					ret.R3=76.0;
					ret.G3=76.0;
					ret.B3=76.0;
					break;
			}
			break;
	}
	
	ret.R1=ret.R1/255;
	ret.G1=ret.G1/255;
	ret.B1=ret.B1/255;
	
	ret.R2=ret.R2/255;
	ret.G2=ret.G2/255;
	ret.B2=ret.B2/255;
	
	ret.R3=ret.R3/255;
	ret.G3=ret.G3/255;
	ret.B3=ret.B3/255;
	
	return ret;
}

-(UIColor *)getRGBColorForProject:(NSInteger)projectId isGetFirstRGB:(BOOL)isGetFirstRGB{
	Projects *proj=nil;
    NSMutableArray *projects=[NSMutableArray arrayWithArray:projectList];
	for (Projects *p in projects) {
		if (p.primaryKey==projectId) {
			proj=p;
			break;
		}
	}
	
	ColorObject *color=[self colorForColorNameNo:proj.colorId inPalette:proj.groupId];
	if (isGetFirstRGB) {
		return [UIColor colorWithRed:color.R1 green:color.G1 blue:color.B1 alpha:1];
	}
	return [UIColor colorWithRed:color.R3 green:color.G3 blue:color.B3 alpha:1];
}

@end 
