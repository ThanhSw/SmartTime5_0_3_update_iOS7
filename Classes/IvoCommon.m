//
//  IvoCommon.m
//  IVo
//
//  Created by Left Coast Logic on 5/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

static void addRoundedRectToPath(CGContextRef context, CGRect rect,
								 float ovalWidth,float ovalHeight)

{
    float fw, fh;
	
    if (ovalWidth == 0 || ovalHeight == 0) {// 1
        CGContextAddRect(context, rect);
        return;
    }
	
    CGContextSaveGState(context);// 2
    CGContextBeginPath(context);
	
    CGContextTranslateCTM (context, CGRectGetMinX(rect),// 3
						   CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);// 4
    fw = CGRectGetWidth (rect) / ovalWidth;// 5
    fh = CGRectGetHeight (rect) / ovalHeight;// 6
	
    CGContextMoveToPoint(context, fw, fh/2); // 7
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1.2);// 8
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1.2);// 9
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1.2);// 10
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1.2); // 11
    CGContextClosePath(context);// 12
	
    CGContextRestoreGState(context);// 13
}

void strokeRoundedRect(CGContextRef context, CGRect rect, float ovalWidth,
                       float ovalHeight)
{
	//    CGContextBeginPath(context);
    addRoundedRectToPath(context, rect, ovalWidth, ovalHeight);
    CGContextStrokePath(context);
}
 
void gradientRoundedRect(CGContextRef context, CGRect rect, float ovalWidth,
						 float ovalHeight, CGFloat components[], CGFloat locations[], size_t num_locations)
{
    CGContextSaveGState(context);// 2
    addRoundedRectToPath(context, rect, ovalWidth, ovalHeight);
	
	CGContextClip(context);
	
	CGGradientRef myGradient;
	CGColorSpaceRef myColorspace;
	
	//myColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	myColorspace = CGColorSpaceCreateWithName(CFSTR("kCGColorSpaceGenericRGB"));
	myGradient = CGGradientCreateWithColorComponents (myColorspace, components,locations, num_locations);
	
	CGPoint myStartPoint, myEndPoint;
	myStartPoint.x = rect.origin.x;
	myStartPoint.y = rect.origin.y;
	myEndPoint.x = rect.origin.x;
	myEndPoint.y = rect.origin.y + rect.size.height;
	
	CGContextDrawLinearGradient(context, myGradient, myStartPoint, myEndPoint, 0);	
	
    CGContextRestoreGState(context);// 13
	CGGradientRelease(myGradient);
}

void fillRoundedRect (CGContextRef context, CGRect rect,
					  float ovalWidth, float ovalHeight)

{
	//    CGContextBeginPath(context);
    addRoundedRectToPath(context, rect, ovalWidth, ovalHeight);
    CGContextFillPath(context);
}

#import <QuartzCore/QuartzCore.h>
#import "IvoCommon.h"


double timeInervalForExpandingToFillRE=2592000;

NSString *_sun_image = @"Work.png";

NSString *_moon_image = @"Home.png";

NSString *_re_image = @"repeat.png";

NSString *_re_plus_image = @"repeatPlus.png";

NSString *_re_exc_image = @"exception.png";

NSString *_ade_image = @"ADE.png";

NSString *_alert_image = @"bell.png";

BOOL _greenBadgeTurnOff = NO;

NSString *WeekDay[]= {
	@"Sun",
	@"Mon",
	@"Tue",
	@"Wed",
	@"Thu",
	@"Fri",
	@"Sat"
};

NSString *alertUnitList[]={
	@"minutes",
	@"hours",
	@"days",
	@"weeks"
};

NSString* _gcalProjectColors[21] = {
	@"#2952A3", @"#A32929", @"#BE6D00", @"#28754E", @"#4A716C", @"#5229A3", 
	@"#29527A", @"#B1365F", @"#AB8B00", @"#0D7813", @"#5A6986", @"#7A367A", 
	@"#1B887A", @"#B1440E", @"#88880E", @"#528800", @"#4E5D6C", @"#705770", 
	@"#6E6E41", @"#865A5A", @"#8D6F47"
};

MoveAreaStyle _app_movearea_style = IVO_STYLE;
MoveAreaMarginStyle _app_movearea_margin_style = LEFT_MARGIN;

CGFloat _otherColors[2][3] = { {189,189,189}, {112,112,112} };
CGFloat _eventColors[2][3] = { {0,179,89}, {0,102,51} };

CGFloat _outlineColors[MAXDUE][3] = {{94,120,112},{94,120,112},{94,120,112},{94,120,112}};

int _outlineWidths[MAXDUE] = {1,1,1,1};

CGFloat _dynamicLineColor[3] = {176, 176, 99};

CGFloat _shadowColor[3] = {94, 120, 112};

CGFloat _homeColor[3] = {41, 255, 112};

CGFloat _timeSlotColor[3] = {0, 255, 255};

int _boxHWHeights[MAXDURATION] = {20, 40, 80};
int _boxFWHeights[MAXDURATION] = {20, 30, 40};

NSString *ColorGroupNames[]= {
	@"PRIME",
	@"PASTEL",
	@"VINTAGE",
	@"LUXE"
};

NSString *calendarDetailText=@"Calendar detail";
NSString *newCategoryText=@"New Calendar";
NSString *projectsText=@"Calendars";
NSString *synchronizationText=@"Synchronization";
NSString *iPadCalendarSyncText=@"iPhone Calendar"; 
NSString *syncNowText=@"Sync Now";

NSString *deleteCalendarMsg=@"This will delete the Calendar and all of the tasks and events that belong to it.  It will also delete the corresponding Calendar and all of its data, from your iPhone calendar. Proceed?";
NSString *newProjectText=@"New Calendar";
NSString *editProjectText=@"Edit Calendar";
NSString *setAsDefaultCaledarText=@"Set as default Calendar";
NSString *enterCalendarNameHereText=@"Enter a new calendar name here!";
NSString *unHideThisCalendarText=@"Unhide this calendar";
NSString *selectColorText=@"Select color";
NSString *deleteCalendarErrorMsg=@"Sorry! You can not delete the default calendar!";
NSString *showAllText=@"Show all";
NSString *autoSyncText=@"Auto sync";

NSString *alertFromText=@"Alert before from";
NSString *onDateOfDueText=@"On date of Due";
NSString *onDateOfStartText=@"On date of Start";
NSString *onDateText=@"On date";
NSString *ofDueText=@"Of Due";
NSString *ofStartText=@"Of Start";
NSString *ofEventText=@"Of event";
NSString *repeatFromDueDateText=@"Repeat from Due date";
NSString *repeatFromCompletionDateText=@"Repeat from completion Date";
NSString *syncEventOnlyText=@"Only Events to iPhone Cal.";

NSString *ST41FirstPopUpMsg=@"Welcome to SmartTime!\
- SmartTime synchronizes Events with your iPhone calendar, and can either integrate Tasks into your iPhone calendar, or sync them with the Reminders app.\
- Before you sync for the first time, be sure to select the sync source of your iPhone calendar.\
- For more info, please read our Sync Guide\
- Protect your data by frequently backing up SmartTime!";

NSString *byLCLText=@"By LCL";

NSString *beginAutoSyncNowText=@"Begin auto sync now?";
NSString *STAutoSyncMsg=@"SmartTime will sync automatically as you make changes while the app is running.";

NSString *tasksAndEventsText=@"Tasks and Events";
NSString *eventsOnlyText=@"Events only";


CGFloat _bgStartColors[MAXCATEGORY][3] = {
	{0,89,179},
	{184,46,46},
	{179,89,0},
	{103,136,68},
	{112,112,112},
	{133,71,194}
};

NSString *iPhoneReminderText=@"iPhone Reminder";

@implementation IvoCommon

@end



