//
//  ivo_Utilities.h
//  iVo_DatabaseAccess
//
//  Created by Nang Le on 5/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"
#import "IvoCommon.h"
#import <Foundation/Foundation.h>  
#import <SystemConfiguration/SystemConfiguration.h>  
#import <netinet/in.h>  
#import <arpa/inet.h>  
#import <netdb.h> 

@class Projects;
@class Task;
@class Setting;
@class DateTimeSlot;
@class Alert;
//@class GCal2ProjMap;
@class ColorObject;

@class TaskActionResult;

@interface ivo_Utilities : NSObject {
}

- (NSInteger) getIndex: (NSMutableArray*) tasks: (NSInteger) taskKey;
- (void) printTask: (NSMutableArray*) tasks;
//nang's code
- (NSInteger)getSecond:(NSDate *)date;
- (NSInteger)getMinute:(NSDate *)date;
- (NSInteger)getHour:(NSDate *)date;
- (NSInteger)getHourWithAMPM:(NSDate *)date;
- (NSInteger)getWeekday:(NSDate *)date;
- (NSInteger)getWeekdayOrdinal:(NSDate *)date;
- (NSString *)createWeekDayName: (NSDate *)date;
- (NSString *)createAMPM:(NSDate *)date;
- (NSString *)createMonthName: (NSDate *)date;
- (NSInteger)getDay:(NSDate *)date;
- (NSInteger)getMonth:(NSDate *)date;
- (NSInteger)getYear:(NSDate *)date;
- (void)copyTask:(Task *)fromTask toTask:(Task *)task isIncludedPrimaryKey:(BOOL)isCopyPK;
- (NSInteger)getIndexOfTaskByPrimaryKey:(Task *)task inArray:(NSMutableArray *)list;
//- (taskCheckResult)smartCheckValidationTask:(Task *)task inTaskList:(NSMutableArray *)list;
//- (taskCheckResult)smartCheckOverlapTask:(Task *)task inTaskList:(NSMutableArray *)list;
- (TaskActionResult *)smartCheckValidationTask:(Task *)task inTaskList:(NSMutableArray *)list;
- (TaskActionResult *)smartCheckOverlapTask:(Task *)task inTaskList:(NSMutableArray *)list;

- (BOOL)isTaskInOtherContextRange:(Task*)task;
- (NSInteger)getTimeSlotIndexForTask:(Task *)task inArray:(NSMutableArray *)list;
- (void)inspectPinnedTaskDate:(Task *)task;
- (NSString *)createStringFromDate:(NSDate *) date isIncludedTime:(BOOL)isTime;
- (NSString *)createStringFromShortDate:(NSDate *) date;
- (NSString *)createCurrentDateInfo;
- (NSString *)createTimeStringFromDate:(NSDate *) date;

- (void)copySetting:(Setting *)setting toSetting:(Setting *)toSetting;
- (Projects *)createCopyProject:(Projects*)proj;
- (NSMutableArray*)	createCopyProjectList:(NSMutableArray*)projList;
- (UIButton *)createButton:(NSString *)title 
				buttonType:(UIButtonType)buttonType
					 frame:(CGRect)frame
				titleColor:(UIColor *)titleColor
					target:(id)target
				  selector:(SEL)selector
		  normalStateImage:(NSString *)normalStateImage
		selectedStateImage:(NSString*)selectedStateImage;

- (NSMutableArray *) alloc_filterTasksByDate:(NSMutableArray *)list date:(NSDate *) date;
- (CGSize) getTimeSize: (CGFloat) size;
- (Task *)getTaskByPrimaryKey:(NSInteger)key inArray:(NSMutableArray *)list;

- (Task *)getTaskBySyncKey:(double)syncKey inArray:(NSMutableArray *)list;
- (Task *)getTaskByEventID:(NSString *)eventId inArray:(NSMutableArray *)list;

- (NSString *)createCalculateHowLong:(NSInteger)value;
- (NSDate *)createDeadLine:(NSInteger)type fromDate:(NSDate *)fromDate context:(NSInteger)context;
-(NSDate *)createEndRepeatDateFromCount:(NSDate *)fromDate typeRepeat:(NSInteger)typeRepeat repeatCount:(NSInteger)repeatCount repeatOptionsStr:(NSString *)repeatOptionsStr;
//-(repeatCountTime)createRepeatCountFromEndDate:(NSDate *)fromDate typeRepeat:(NSInteger)typeRepeat toDate:(NSDate *)toDate repeatOptionsStr:(NSString *)repeatOptionsStr;
-(repeatCountTime)createRepeatCountFromEndDate:(NSDate *)fromDate typeRepeat:(NSInteger)typeRepeat toDate:(NSDate *)toDate repeatOptionsStr:(NSString *)repeatOptionsStr reStartDate:(NSDate *)reStartDate;

-(Alert *)creatAlertFromList:(NSArray *)arr atIndex:(NSInteger)atIndex;
- (NSInteger)getRepeatEvery:(NSString *)taskRepeatOptions;
- (NSMutableArray *)deletedExceptionList:(Task *)mainInstance inList:(NSMutableArray *)list;
-(NSString *)removeNewLineCharactersFromStr:(NSString *)string;
-(NSString *)replaceNewLineCharactersFromStr:(NSString *)string byString:(NSString *)byString;

-(NSInteger)countRepeatInstancesFromEndDate:(NSDate *)fromDate typeRepeat:(NSInteger)typeRepeat toDate:(NSDate *)toDate repeatOptionsStr:(NSString *)repeatOptionsStr;

//-(GCal2ProjMap *)creatGCal2ProjMapFromList:(NSArray *)arr atIndex:(NSInteger)atIndex;

//-(UIColor *)getRGBColorForProject:(NSInteger)projectIndex isGetFirstRGB:(BOOL)isGetFirstRGB;

- (NSString *)getShortStringFromDate:(NSDate *) date;
- (NSString *)getTimeStringFromDate:(NSDate *) date;
- (NSString *)getShortAMPM:(NSDate *)date;
- (NSComparisonResult)compareDate:(NSDate*) date1 withDate:(NSDate*) date2;
- (NSComparisonResult)compareDateNoTime:(NSDate*) date1 withDate:(NSDate*) date2;

- (UIImage *) takeSnapShot: (UIView *)view size:(CGSize) size;
//trung ST3.1
- (void) fillREInstanceToList: (NSMutableArray *)list dummykey:(NSInteger)dummyKey parentKey:(NSInteger)parentKey startTime:(NSDate *)startTime;

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;
+ (NSString *)hexStringFromColor:(UIColor *)colorVal;

//+ (NSDate *)dateWithDSTAdjusted:(NSDate *)dateArg;
-(NSString *)getLongStringFromDate:(NSDate *)date;
- (NSString *)getStringFromShortDate:(NSDate *) date;
+ (NSInteger)offsetForDate:(NSDate *)date;
//+ (NSString *)offsetForDate:(NSDate *)date;
- (NSDate *)dateWithNewOffset:(NSDate *)date offsetFromDate:(NSDate *)offsetFromDate;
- (NSDate *)addTimeInterval:(int)argSecond :(NSDate *)argDate; 
- (NSDate *) dateByAddNumSecond:(int)argSecond toDate:(NSDate *)argDate;
- (NSDate *) dateByAddNumDay:(int)argDay toDate:(NSDate *)argDate;
//- (NSTimeInterval)getDateStamp;
-(NSString *)getAPNSAlertFromTask:(Task*)task;
//-(void)uploadAlertsForTasks:(Task*)task isAddNew:(BOOL)isAddNew withPNSAlert:(NSString*)withPNSAlert;
-(void)uploadAlertsForTasks:(Task*)task isAddNew:(BOOL)isAddNew withPNSAlert:(NSString*)withPNSAlert oldDevToken:(NSString*)oldDevToken oldTaskPNSID:(NSString*)oldTaskPNSID;

-(void)deleteAlertsOnServerForTasks:(Task*)task;
-(BOOL)deleteOldAlertsOnServerForDevToken:(NSString*)devToken;
-(void)updateDevTokenForAlertEvents:(id)sender;
-(void)updateForOldDevToken:(NSString*)oldDevToken;
-(NSString*)statisticNumberOfTasks;

-(NSDate *)resetDate:(NSDate*)date year:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute sencond:(NSInteger)second;
-(NSDate *)newDateFromDate:(NSDate*)date offset:(NSTimeInterval)offset;
- (NSString *)getShortDateWithFullYearStringFromDate:(NSDate *) date ;
- (NSString *)getTimeStringLowerAmPmFromDate:(NSDate *) date;

- (NSString *)getShortDateTimeStringFromDate:(NSDate *) date;
-(NSDate *)dateFromDateString:(NSString *)dateStr;
-(NSString *)getAMPM:(NSDate *)date;

- (void) deleteSuspectedDuplication;

-(ColorObject*)colorForColorNameNo:(NSInteger)colorNameNo inPalette:(NSInteger)inPalette;
-(UIColor *)getRGBColorForProject:(NSInteger)projectId isGetFirstRGB:(BOOL)isGetFirstRGB;

@end 
