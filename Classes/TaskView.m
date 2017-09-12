//
//  TaskView.m
//  IVo
//
//  Created by Left Coast Logic on 4/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "TaskView.h"
#import "IvoCommon.h"
#import "ivo_Utilities.h"
#import "SmartTimeView.h"
#import "TaskManager.h"
#import "Projects.h"
#import "ColorObject.h"
#import "SmartTimeAppDelegate.h"
#import "TaskManager.h"


extern SmartTimeAppDelegate *App_Delegate;

extern void addRoundedRectToPath(CGContextRef context, CGRect rect,float ovalWidth,float ovalHeight);
extern void fillRoundedRect (CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight);
extern void strokeRoundedRect(CGContextRef context, CGRect rect, float ovalWidth,float ovalHeight);
extern void gradientRoundedRect(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight, CGFloat components[], CGFloat locations[], size_t num_locations);

#define SIZE 100
#define FONT_PADDING 5
#define TASK_HEIGHT 40
#define DUEVIEW_HALF_SIZE 13
#define TASK_FONT_SIZE 12

#define TIME_FONT_SIZE 8

#define MOVE_ANIMATION_DURATION_SECONDS 0.1

extern SmartTimeView* _smartTimeView;

extern NSString *_sun_image;

extern NSString *_moon_image;

extern NSString *_re_image;

//extern NSString *_sun_image ;

extern NSString *_re_plus_image;

extern NSString *_re_exc_image;

extern NSString *_ade_image;

extern NSString *_alert_image;


extern ivo_Utilities	*ivoUtility;

extern NSMutableArray *projectList;
extern MoveAreaMarginStyle _app_movearea_margin_style;
BOOL _greenBadgeTurnOff;

///
extern TaskManager	*taskmanager;
extern BOOL _is24HourFormat;
extern NSTimeInterval dstOffset;
extern ivo_Utilities *ivoUtility;
extern NSTimeZone *App_defaultTimeZone;
extern NSString		*dev_token;
extern BOOL	isInternetConnected;
extern float OSVersion;
//extern NSString *startTimeIsLaterEndTimeText;

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

////
@implementation TaskView

@synthesize key;

//trung ST3.1
@synthesize parentKey;

@synthesize startTime;
@synthesize endTime;
@synthesize deadline;
@synthesize category;
@synthesize type;
@synthesize due;
@synthesize name;
@synthesize duration;
@synthesize location;
@synthesize defaultValue;

@synthesize progress;
@synthesize subTaskNo;
@synthesize pinched;

//Trung 08101701
//@synthesize moveArea;

@synthesize doToday;

//Trung 08101301
@synthesize doTomorrow;

@synthesize pad;
@synthesize taskCompleted;
@synthesize jiggleRight;
@synthesize isMoving;

@synthesize originFrame;
@synthesize originPad;

@synthesize selected;
@synthesize context;

@synthesize inPast;

@synthesize isADE;
//trung ST3.1
@synthesize isRootRE;

@synthesize isRepeatTask;

@synthesize originalStartTime;

- (id)initWithTask:(Task *)task
{
	//ILOG(@"[TaskView initWithTask\n")

	//self.type = TYPE_SMART_TASK;
	self.type = [self getTaskType];
	
	if (task.isAllDayEvent == 1)
	{
		//self.type = TYPE_ADE;
		self.isADE = YES;
	}
	
	self.doToday = YES;
	self.doTomorrow = NO;
	self.subTaskNo = 0;
	self.context = task.taskWhere;
	self.defaultValue = task.taskDefault;
	//self.defaultValue = 1;
	
	self.inPast = NO;
	
	self.key = task.primaryKey;

	//printf("Task View %s - key: %d\n", [task.taskName UTF8String], self.key);
	
	//trung ST3.1
	self.parentKey = task.parentRepeatInstance;
	if (self.key >=0 && self.parentKey == -1 && task.taskRepeatID > 0)
	{
		self.isRootRE = YES;
	}
	else
	{
		self.isRootRE = NO;
	}
	
	if (self.isRootRE || self.key < -1)
	{
		self.originalStartTime = task.taskREStartTime;
	}
	else
	{
		self.originalStartTime = task.taskStartTime;
	}
	
	self.taskCompleted = task.taskCompleted;
	
	NSDate *today = [NSDate date];

	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:today];
	
	// for first startup screen, reset task's date to today
	if (task.taskCompleted <= -10000)
	{		
		unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit |  NSSecondCalendarUnit;		
		NSDateComponents *taskcomps = [gregorian components:unitFlags fromDate:task.taskStartTime];
		
		[comps setHour:[taskcomps hour]];
		[comps setMinute:[taskcomps minute]];
		[comps setSecond:[taskcomps second]];
		
		//nang 3.7
		//self.startTime = [[gregorian dateFromComponents:comps] copy];
		self.startTime = [gregorian dateFromComponents:comps];
		
		self.key = task.taskCompleted;
		
	}
	else
	{
		//self.startTime = [task.taskStartTime copy];
		self.startTime = task.taskStartTime;
	}
	
	NSDate *endtime = [self.startTime dateByAddingTimeInterval:task.taskHowLong];
	self.endTime = endtime;
	
	self.deadline = nil;
	
	if (task.taskIsUseDeadLine == 1)
	{
		self.deadline = task.taskDeadLine;
	}	

	//self.category = task.taskProject;
	//EK Sync
	//self.category = (TaskCategory) (task.taskProject < 0 || task.taskProject > projectList.count?0: [[projectList objectAtIndex:task.taskProject] colorId]);
	
	self.category=task.taskProject;
	
	self.name = task.taskName;
	
	//printf("task: %s -  color: %d - updated time: %s\n", [self.name UTF8String], self.category, [[task.taskDateUpdate description] UTF8String]);
	
	//self.location = [task.taskLocation copy];
	self.location = task.taskLocation;
	
	CGFloat f = task.taskHowLong/60;

	if (f < 60)
	{
		self.duration = SMALL;
	}
	else if (f < 180)
	{
		self.duration = MEDIUM;
	}
	else
	{
		self.duration = LARGE;
	}

	self.pinched = task.taskPinned;
	
	self.due = NODUE;
	dueLeft = 0;
	
	// for initial screen, set DUE to draw thin red border for "My Daily Achievement" (task id: -10001)	
	if (self.taskCompleted == -10001)
	{
		self.due = DUE;
	}
	else
	{		
		
		if (self.deadline != nil)
		{
            /**** clear hour:minute:second for endtime *****/
            unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
            //comps = [gregorian components:unitFlags fromDate:endtime];
            
            comps = [gregorian components:unitFlags fromDate:self.deadline];
            endtime = [gregorian dateFromComponents:comps];
            /***********************************************/
            
            /**** clear hour:minute:second for today *****/
            comps = [gregorian components:unitFlags fromDate:today];
            today = [gregorian dateFromComponents:comps];
            /***********************************************/

			NSTimeInterval diff = [endtime timeIntervalSinceDate:today];
		
			dueLeft = floor(diff/24/3600);
			
			self.due = BEDUE;
		
			if (dueLeft == 0)
			{
				self.due = DUE;
			} else if (dueLeft < 0)
			{
				self.due = OVERDUE;
			} else if (dueLeft > 99)
			{
				self.due = NODUE;
			}
		}
		
		/**** clear hour:minute:second for today *****/
		comps = [gregorian components:unitFlags fromDate:self.startTime];
		NSDate *starttime = [gregorian dateFromComponents:comps];
		/***********************************************/		
		
		NSComparisonResult result = [starttime compare:today];
		
//Trung 08101301
		NSDate *tomorrow = [today dateByAddingTimeInterval:24*60*60];

//		NSComparisonResult result = [self.startTime compare:[NSDate date]];

		if (result == NSOrderedDescending)
		{
			self.doToday = NO;
			
//Trung 08101301

			NSComparisonResult result = [starttime compare:tomorrow];
			
			if (result == NSOrderedDescending)
			{
				self.doTomorrow = NO;
			}
			else if (result == NSOrderedAscending || result == NSOrderedSame)
			{
				self.doTomorrow = YES;
			}			
		}
		else if (result == NSOrderedAscending || result == NSOrderedSame)
		{
			self.doToday = YES;
		}

		NSDate *yesterday = [today dateByAddingTimeInterval:-24*60*60];
		
		result = [starttime compare:yesterday];
		
		if (result == NSOrderedAscending || result == NSOrderedSame)
		{
			self.inPast = YES;
		}
		else
		{
			self.inPast = NO;
		}
	}
	
	NSArray *alerts = [task creatAlertList];
	
	//nang 3.7	
	//if (alerts.count > 0 && task.taskPinned) //only Event has alert
	if (alerts.count > 0)
	{
		hasAlert = TRUE;
	}
	
	[alerts release]; 

	[gregorian release];

    if (task.taskPinned==0 && task.taskRepeatID>0) {
        self.isRepeatTask=YES;
        
    }else{
        self.isRepeatTask=NO;
    }
	//ILOG(@"TaskView initWithTask]\n")
	
	return self;	
}

- (id)initWithFrame:(CGRect)frame {
	//ILOG(@"[TaskView initWithFrame\n")
    if (self = [super initWithFrame:frame]) {
		
        // Initialization code here.
		inMoveMode = NO;
		checkTouchAndHold = NO;
		self.jiggleRight = NO;
		self.isMoving = NO;
		//lastTouchTime = nil;
		lastTouchTime = [[NSDate date] copy];

		CGSize size = [self calculateSize];

		CGRect frm = CGRectZero;
		frm.size = size;
		self.frame = frm;
		
		self.backgroundColor = [UIColor clearColor];
		
		self.originFrame = frm;

		if (self.type != TYPE_SMART_DYNAMICLINE && !self.isADE)
		{
			//Trung 08101701
			/*
			self.moveArea = [[MoveArea alloc] initWithFrame:CGRectZero];
			self.moveArea.howLong = self.duration;
			self.moveArea.taskType = self.type;
		
			[self addSubview:self.moveArea];
			 */

			moveArea = [[MoveArea alloc] initWithFrame:CGRectZero];
			moveArea.howLong = self.duration;
			moveArea.taskType = self.type;
			
			[self addSubview:moveArea];
			
			//Trung 08101701
			[moveArea release];

		}
		
		alertView = nil;
		
		if (hasAlert)
		{
			UIImage *image = [UIImage imageNamed:_alert_image];
			alertView = [[UIImageView alloc] initWithImage:image];
			[self addSubview:alertView];
		}
		
		contextView = nil;
		
		if (self.type == TYPE_SMART_RE || self.type == TYPE_CALENDAR_RE && self.duration >= MEDIUM)
		{
			UIImage *image = [UIImage imageNamed:_re_image];
			contextView = [[UIImageView alloc] initWithImage:image];
			[self addSubview:contextView];
			
			[contextView release];			
		}
		else if (self.type == TYPE_SMART_RE_MORE)
		{
			UIImage *image = [UIImage imageNamed:_re_plus_image];
			contextView = [[UIImageView alloc] initWithImage:image];
			[self addSubview:contextView];
			
			[contextView release];			
		}
		else if (self.type == TYPE_SMART_RE_EXC || self.type == TYPE_CALENDAR_RE_EXC && self.duration >= MEDIUM)
		{
			UIImage *image = [UIImage imageNamed:_re_exc_image];
			contextView = [[UIImageView alloc] initWithImage:image];
			[self addSubview:contextView];
			
			[contextView release];						
		}
		else if (self.isADE)
		{
			UIImage *image = [UIImage imageNamed:_ade_image];
			contextView = [[UIImageView alloc] initWithImage:image];
			[self addSubview:contextView];
			
			[contextView release];			
		}
		else if ([self checkContext])
		{			
			NSString *contextImageName = _sun_image;
		
			if (self.context == CONTEXT_HOME)
			{
				contextImageName = _moon_image;
			}

			UIImage *image = [UIImage imageNamed:contextImageName];
			contextView = [[UIImageView alloc] initWithImage:image];
			[self addSubview:contextView];
			
			//Trung 08101701
			[contextView release];
		}
		
        repeatTaskView=[[UIImageView alloc] initWithFrame:CGRectMake(15, 1, 8, 8)];
        [self addSubview:repeatTaskView];
        [repeatTaskView release];

    }
    
	//ILOG(@"TaskView initWithFrame]\n")	
    return self;
}

- (TaskTypeEnum) getTaskType
{
	return TYPE_SMART_TASK;
}

- (BOOL) checkDue
{
	BOOL ret = NO;
	if (self.due < NODUE)
	{
		if (self.type == TYPE_SMART_TASK)
		{
			ret = YES;
		} 
		else if (self.type == TYPE_CALENDAR_TASK && self.duration >= MEDIUM)
		{
			ret = YES;
		}
	}
	
	if (_greenBadgeTurnOff && self.due == BEDUE)
	{
		ret = NO;
	}
	
	return ret;
}

- (BOOL) checkContext
{
	BOOL ret = NO;
	
	if (self.type == TYPE_SMART_TASK)
	{
		ret = YES;
	}
	else if (self.type == TYPE_CALENDAR_TASK && self.duration >= MEDIUM)
	{
		ret = YES;
	}
	
	return ret;
}	

- (void)layoutSubviews {
	//ILOG(@"[TaskView layoutSubviews\n")
		
	CGFloat top_margin = 0;
	
	if ([self checkDue])
	{
		top_margin += DUEVIEW_HALF_SIZE;
	}

	CGRect contextViewRect = CGRectZero;
	
	CGFloat hashmarkWidth = [MoveArea getHashmarkVisibleWidth];

	CGFloat left_margin = (hashmarkWidth - CONTEXT_SIZE)/2;
	
    repeatTaskView.frame=CGRectMake(15, top_margin+1, 8, 8);

	if (alertView != nil)
	{
		left_margin = 2;
		
		alertView.frame = CGRectMake(left_margin, top_margin, ALERT_SIZE, ALERT_SIZE);
		
		left_margin += ALERT_SIZE - 2;
		//left_margin += ALERT_SIZE;
		
		//top_margin += 2;
	}
	
	switch (_app_movearea_margin_style)
	{
		case LEFT_MARGIN:
		{
			//contextViewRect = CGRectMake((hashmarkWidth - CONTEXT_SIZE)/2, top_margin + 4, CONTEXT_SIZE, CONTEXT_SIZE);			
			contextViewRect = CGRectMake((self.isRepeatTask?(left_margin-2):left_margin), top_margin + (self.isRepeatTask?7:4), CONTEXT_SIZE, CONTEXT_SIZE);
			top_margin += 2;

		}	
			break;
		case RIGHT_MARGIN:
			//contextViewRect = CGRectMake(2, top_margin + 4, CONTEXT_SIZE, CONTEXT_SIZE);
			contextViewRect = CGRectMake(2, top_margin + 4, CONTEXT_SIZE, CONTEXT_SIZE);
			
			break;
	}
		
	if (contextView != nil)
	{
		contextView.frame = contextViewRect;
		
		top_margin += CONTEXT_SIZE;
	}
	else if (alertView != nil)
	{
		//top_margin += ALERT_SIZE - 4;
		top_margin += ALERT_SIZE - 4;
	}

	CGRect moveAreaRect = CGRectZero;
	CGFloat height = MOVE_AREA_HEIGHT;
	if (self.frame.size.height < height)
	{
		height = self.frame.size.height;
	}

	switch (_app_movearea_margin_style)
	{
		case LEFT_MARGIN:
			
			moveAreaRect = CGRectMake(0, top_margin, MOVE_AREA_WIDTH, height);			
			break;
		case RIGHT_MARGIN:
		{
			moveAreaRect = CGRectMake(self.bounds.size.width - MOVE_AREA_WIDTH, 2*top_margin, MOVE_AREA_WIDTH, height);
			
			if ([self checkDue])
			{
				moveAreaRect.origin.x -= DUEVIEW_HALF_SIZE;
			}
		}	
			break;
	}

//Trung 08101701
/*
	if (self.moveArea != nil)
	{
		self.moveArea.frame = moveAreaRect;
	}
*/
	if (moveArea != nil)
	{
		moveArea.frame = moveAreaRect;
	}
	
	//ILOG(@"TaskView layoutSubviews]\n")
}

- (CGSize) calculateSize
{
	//ILOG(@"[TaskView calculateSize\n")
	
	CGSize size;
	
	// for initial screen, set task "Touch and hold ..." to FULL WIDE (task id: -10003)	
	if (self.pinched || self.taskCompleted == -10003) // Full Wide Task
	{
		size.width = BOX_FULL_WIDE;
	}
	else
	{
		size.width = BOX_HALF_WIDE;
	}
	
	size.height = TASK_HEIGHT;
	
	if ([self checkDue])
	{
		size.width += DUEVIEW_HALF_SIZE;
		size.height += DUEVIEW_HALF_SIZE;
	}
	
	//ILOG(@"[TaskView calculateSize\n")
	return size;
}

- (void) setSelected:(BOOL) selectedVal
{
	//ILOG(@"[TaskView setSelected\n")

	BOOL needsDisplay = (selected != selectedVal);
	
	selected = selectedVal;

	//Trung 08101701
	//self.moveArea.selected = selectedVal;
	moveArea.selected = selectedVal;

	
	if (needsDisplay)
	{
		[self setNeedsDisplay];
	}
	
	//ILOG(@"TaskView setSelected]\n")
}

- (void) restoreFrame
{
	//ILOG(@"[TaskView restoreFrame\n")
	
	self.pad = self.originPad;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	self.frame = self.originFrame;
	[UIView commitAnimations];
	
	//ILOG(@"TaskView restoreFrame]\n")
}

- (void) drawBadge:(CGContextRef) ctx
{
	CGRect dueRec = CGRectMake(self.bounds.size.width - 2*DUEVIEW_HALF_SIZE -3, 2, 2*DUEVIEW_HALF_SIZE, 2*DUEVIEW_HALF_SIZE);

	//CGFloat dueViewWidthAdj = (dueLeft > 9? 8 : 0);	
	//dueRec.origin.x -= dueViewWidthAdj;
	//dueRec.size.width += dueViewWidthAdj;
	
	CGRect shadowDueRec = CGRectOffset(dueRec, 1, 3);
	
	[[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.6] setFill];
	CGContextFillEllipseInRect(ctx, shadowDueRec);
	//fillRoundedRect(ctx, shadowDueRec, 8, 8);
	
	[[UIColor colorWithRed:0 green:0.5 blue:0 alpha:1] setFill]; //dark green
	
	if (self.due == OVERDUE)
	{
		[[UIColor redColor] setFill];
	} 
	else if (self.due == DUE)
	{
		[[UIColor orangeColor] setFill];
	}

	dueRec.origin.x += 3;
	dueRec.origin.y += 3;
	dueRec.size.width -= 6;
	dueRec.size.height -= 6;
	
	CGContextFillEllipseInRect(ctx, dueRec);
	//fillRoundedRect(ctx, dueRec, 8, 8);
	
	dueRec.origin.x -= 1;
	dueRec.origin.y -= 1;
	dueRec.size.width += 2;
	dueRec.size.height += 2;
	
	[[UIColor whiteColor] set];
	CGContextSetLineWidth(ctx, 2);
	CGContextStrokeEllipseInRect(ctx, dueRec);
	//strokeRoundedRect(ctx, dueRec, 8, 8);
	
	dueRec.origin.x -= 1;
	dueRec.origin.y -= 1;
	dueRec.size.width += 2;
	dueRec.size.height += 2;	

	[[UIColor grayColor] set];
	
	CGContextSetLineWidth(ctx, 1);
	CGContextStrokeEllipseInRect(ctx, dueRec);
	//strokeRoundedRect(ctx, dueRec, 8, 8);
	
	[[UIColor whiteColor] set];
	
	if (self.selected)
	{
		[[UIColor yellowColor] set];
	}
	
	dueRec = CGRectMake(self.frame.size.width - 2*DUEVIEW_HALF_SIZE - 3, 6, 2*DUEVIEW_HALF_SIZE, 2*DUEVIEW_HALF_SIZE);
	//dueRec.origin.x -= dueViewWidthAdj;
	//dueRec.size.width += dueViewWidthAdj;	
	
	NSString *s = [NSString stringWithFormat:@"%d",dueLeft];
	//UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:10];
	UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
	
	if (self.due == OVERDUE)
	{
		s = @"!";
	} 
	
	[s drawInRect:dueRec withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:NSTextAlignmentCenter];
	
/*	
	CGContextAddEllipseInRect(ctx, dueRec);
	CGContextClip(ctx);
	
	dueRec = CGRectOffset(dueRec, 0, -16);
	[[UIColor colorWithRed:1 green:1 blue:1 alpha:0.7] setFill];
	
	CGContextFillEllipseInRect(ctx, dueRec);
*/	
}

- (void) drawShape:(CGContextRef) ctx
{
	//ILOG(@"[TaskView drawShape\n")
	
	CGRect bounds = self.bounds;
	
	if ([self checkDue])
	{
		bounds.size.width -= DUEVIEW_HALF_SIZE;
		bounds.size.height -= DUEVIEW_HALF_SIZE;
		bounds.origin.y += DUEVIEW_HALF_SIZE;
	}
	
	CGRect shadowRect = bounds;
	shadowRect.origin.x += 2;
	shadowRect.origin.y += 2;
	shadowRect.size.width -= BOX_RIGHT_SHADING;
	shadowRect.size.height -= 2;
	
	CGFloat *rgb;
	CGFloat r1,g1,b1,r2,g2,b2;
	
	r1 = _shadowColor[0]/255;
	g1 = _shadowColor[1]/255;
	b1 = _shadowColor[2]/255;
	[[UIColor colorWithRed:r1 green:g1 blue:b1 alpha:0.6] setFill];
	
	fillRoundedRect(ctx, shadowRect, 4, 5);
	
	bounds.size.width -= 2;
	bounds.size.height -= 2;
	
	CGFloat lineW = 1;
	
	if (self.due != MAXDUE)
	{
		lineW = _outlineWidths[self.due];
	}

	bounds.origin.x += lineW/2;
	bounds.origin.y += lineW/2;
	bounds.size.width -= lineW;
	bounds.size.height -= lineW;
		
	Projects *proj=[App_Delegate calendarWithPrimaryKey:self.category];
	ColorObject *color=[ivoUtility colorForColorNameNo:proj.colorId inPalette:proj.groupId];

	r1=color.R3;
	g1=color.G3;
	b1=color.B3;
	
	r2=color.R1;
	g2=color.G1;
	b2=color.B1;

	size_t num_locations = 3;
	CGFloat locations[3] = { 0.0, 0.4, 1.0 };
	
	CGFloat components[12] = { r1, g1, b1, 1.0,  // Start color
	r2, g2, b2, 1.0, r2, g2, b2, 1.0 };
	
	
	gradientRoundedRect(ctx, bounds, 4, 5, components, locations, num_locations);
	
	if (self.selected)
	{
		lineW = 2;
		[[UIColor yellowColor] set];
	}
	else
	{
		rgb = _outlineColors[self.due];
			
		r1 = rgb[0]/255;
		g1 = rgb[1]/255;
		b1 = rgb[2]/255;
			
		CGContextSetRGBStrokeColor(ctx, r1, g1, b1, 1);
	}
	
	CGContextSetLineWidth(ctx, lineW);

	strokeRoundedRect(ctx, bounds, 4, 5);
	
	//ILOG(@"TaskView drawShape]\n")
}

- (void) drawText:(CGContextRef) ctx
{
	//ILOG(@"[TaskView drawText\n")
	
	CGRect bounds = self.bounds;
	
	CGFloat top_margin = 0;
	
	if (self.type == TYPE_CALENDAR_TASK && self.duration < LARGE)
	{
		top_margin = 0;
	}
	
	if ([self checkDue])
	{
		bounds.size.width -= 2*DUEVIEW_HALF_SIZE - HASHMARK_SPACING;
		bounds.size.height -= DUEVIEW_HALF_SIZE;
		bounds.origin.y += DUEVIEW_HALF_SIZE;
	}	
	
	bounds.origin.y += BOX_TEXT_PADDING + top_margin;
	bounds.size.height -= 2*BOX_TEXT_PADDING;

	CGFloat fontSize = TASK_FONT_SIZE;

	UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:fontSize];
	
	CGFloat r = _shadowColor[0]/255;
	CGFloat g = _shadowColor[1]/255;
	CGFloat b = _shadowColor[2]/255;
	
	UIColor *embossedColor = [UIColor colorWithRed:r green:g blue:b alpha:1];
	
	UIColor *textColor = [UIColor whiteColor];
	
	if (self.selected)
	{
		textColor = [UIColor yellowColor];
	}

	UITextAlignment alignment = NSTextAlignmentCenter;
	
	NSString *boxText = self.name; 
	
	CGFloat hashmarkWidth = [MoveArea getHashmarkVisibleWidth];
	
	switch (_app_movearea_margin_style)
	{
		case LEFT_MARGIN:
			bounds.origin.x = hashmarkWidth;
			bounds.size.width -= hashmarkWidth + HASHMARK_SPACING + BOX_RIGHT_SHADING;
			break;
		case RIGHT_MARGIN:
			bounds.origin.x = HASHMARK_SPACING;
			bounds.size.width -= hashmarkWidth + HASHMARK_SPACING + BOX_RIGHT_SHADING;
			if ([self checkContext])
			{
				boxText = [@"    " stringByAppendingString:boxText];
			}
			break;
	}
	
	//[[UIColor cyanColor] set];
	//CGContextStrokeRect(ctx, bounds);
	
	CGRect embossedRec = CGRectOffset(bounds, 0, -1);
	
	[embossedColor set];
	[boxText drawInRect:embossedRec withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:alignment];
	
	[textColor set];
	
	[boxText drawInRect:bounds withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:alignment];
	
	//ILOG(@"TaskView drawText]\n")
}

- (void) drawOverlay:(CGContextRef) ctx
{
	CGRect bounds = self.bounds;
	
	//if (self.due < NODUE && self.type == TYPE_SMART_TASK)
	if ([self checkDue])
	{
		bounds.size.width -= DUEVIEW_HALF_SIZE;
		bounds.size.height -= DUEVIEW_HALF_SIZE;
		bounds.origin.y += DUEVIEW_HALF_SIZE;
	}
	
	bounds.size.width -= 2;
	bounds.size.height -= 2;
	
	CGFloat lineW = 1;
	
	if (self.due != MAXDUE)
	{
		lineW = _outlineWidths[self.due];
	}
	
	bounds.origin.x += lineW/2;
	bounds.origin.y += lineW/2;
	bounds.size.width -= lineW;
	bounds.size.height -= lineW;

	[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4] setFill];
	
	fillRoundedRect(ctx, bounds, 4, 5);
}

- (void) drawBadgeOverlay:(CGContextRef) ctx
{
	CGRect dueRec = CGRectMake(self.bounds.size.width - 2*DUEVIEW_HALF_SIZE -3, 2, 2*DUEVIEW_HALF_SIZE, 2*DUEVIEW_HALF_SIZE);

	//CGFloat dueViewWidthAdj = (dueLeft > 9? 8 : 0);
	//dueRec.origin.x -= dueViewWidthAdj;
	//dueRec.size.width += dueViewWidthAdj;
	
	[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4] setFill];

	CGContextFillEllipseInRect(ctx, dueRec);
	//fillRoundedRect(ctx, dueRec, 8, 8);
}

- (void)drawRect:(CGRect)rect {
	//ILOG(@"[TaskView drawRect\n")
	
    // Drawing code here.
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextClearRect(ctx, rect);
	
	[self drawShape:ctx];
	
	[self drawText:ctx];
	
	//if (inPast)
	//{
	//	[self drawOverlay:ctx];
	//}
	
	if ([self checkDue])
	{
		[self drawBadge:ctx];
		
		//if (inPast)
		//{
		//	[self drawBadgeOverlay:ctx];
		//}
	}
	
	//ILOG(@"TaskView drawRect]\n")
    
    if (self.isRepeatTask) {
        repeatTaskView.image=[UIImage imageNamed:@"repeatTask.png"];
    }else{
        repeatTaskView.image=nil;
    }
        
}

//[Trung v2.0] 
- (SmartTimeView *)parentView
{
	return _smartTimeView;
}

- (void)beginMoveTaskView
{
	//ILOG(@"[TaskView beginMoveTaskView\n")
	
	self.isMoving = YES;
	
	self.originFrame = self.frame;
	self.originPad = self.pad;
	
	alphaStore = self.alpha; //1.0.1 [NTT Oct1]

	self.alpha = 0.7;
	
	self.exclusiveTouch = YES;
	
	//[_smartTimeView beginMoveTaskView:self];
	[[self parentView] beginMoveTaskView:self];
	
	checkTouchAndHold = YES;
	
	//ILOG(@"TaskView beginMoveTaskView]\n")
}

- (void)endMoveTaskView
{
	//ILOG(@"[TaskView endMoveTaskView\n")
	
	if (self.isMoving)
	{		
		self.alpha = alphaStore; //1.0.1 [NTT Oct1]

		self.isMoving = NO;
		
		//[_smartTimeView endMoveTaskView:self];
		[[self parentView] endMoveTaskView:self];
		
	}
	
	//self.exclusiveTouch = NO;
	
	//ILOG(@"TaskView endMoveTaskView]\n")
}

- (void)moveEnd
{
	//ILOG(@"[TaskView moveEnd\n")
	
	//[_smartTimeView hightlight:self.frame];
	[[self parentView] hightlight:self.frame];
	
	//ILOG(@"TaskView moveEnd]\n")

} 

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	//ILOG(@"[TaskView touchesBegan\n")
	if (self.type != TYPE_SMART_DYNAMICLINE)
	{
			[self beginMoveTaskView];

			NSTimeInterval diff = [lastTouchTime timeIntervalSinceNow]*(-1);
			//printf("diff = %f\n", diff);
			if (diff <= 0.5) //double touch
			{
				//trung ST3.1
				
				//[[self parentView] executeCommand:VIEW_TASK key:self.key];	
				[[self parentView] executeCommand:VIEW_TASK key:self.key parentKey:self.parentKey startTime:self.originalStartTime];
			}
		
			if (lastTouchTime != nil)
			{
				[lastTouchTime release];
			}
			lastTouchTime = [[NSDate date] copy];
	}
		
	//ILOG(@"TaskView touchesBegan]\n")
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	//ILOG(@"[TaskView touchesMoved\n")
	
	//if (self.type == TYPE_SMART_EVENT || self.type == TYPE_SMART_RE || self.type == TYPE_SMART_RE_MORE || self.type == TYPE_SMART_RE_EXC || self.type == TYPE_ADE)
	if (self.type == TYPE_SMART_EVENT || self.type == TYPE_SMART_RE || self.type == TYPE_SMART_RE_MORE || self.type == TYPE_SMART_RE_EXC || self.isADE)
	{
		return;
	}
	
	BOOL moveEnable = NO;
	
	if (!checkTouchAndHold)
	{
		moveEnable = YES;
	}
	else
	{
		NSTimeInterval diff = [lastTouchTime timeIntervalSinceNow]*(-1);
	
		//printf("move diff = %f\n", diff);
		
		if (diff >= 0.4)
		{
			moveEnable = YES;
			
			checkTouchAndHold = NO;
		}
	}
		
	if (self.isMoving && moveEnable)
	{
		CGPoint newTouchPoint;
		CGPoint prevTouchPoint;
	
		for (UITouch* touch in touches)
		{
			newTouchPoint = [touch locationInView:self];
			prevTouchPoint = [touch previousLocationInView:self];
		}

		self.frame = CGRectOffset(self.frame, newTouchPoint.x - prevTouchPoint.x, newTouchPoint.y - prevTouchPoint.y);
		
		self.pad = CGRectOffset(self.pad, newTouchPoint.x - prevTouchPoint.x, newTouchPoint.y - prevTouchPoint.y);
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDelegate: self];
		[UIView setAnimationDidStopSelector:@selector(moveEnd)];

		[UIView setAnimationDuration:MOVE_ANIMATION_DURATION_SECONDS];
		self.transform = CGAffineTransformIdentity;
		[UIView commitAnimations];
		
		//[_smartTimeView check2scroll:touches view:self];
		[[self parentView] check2scroll:touches view:self];
	}
	
	//ILOG(@"TaskView touchesMoved]\n")
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//ILOG(@"[TaskView touchesEnded\n")
	[self endMoveTaskView];
	//ILOG(@"TaskView touchesEnded]\n")
}

- (BOOL)checkTime2Move:(NSDate *)time
{
	//ILOG(@"[TaskView checkTime2Move\n")
	
	NSDate *tmp = self.startTime;
	NSInteger minute=[ivoUtility getMinute:tmp];
	NSInteger second=[ivoUtility getSecond:tmp];
	if(minute<30){
		tmp=[tmp dateByAddingTimeInterval:-minute*60 -second];
	}else if(minute>30) {
		tmp=[tmp dateByAddingTimeInterval:(30-minute)*60 -second];
	}
	
	NSTimeInterval interval = [tmp timeIntervalSinceDate:time];
	
	if (interval < 0)
	{
		interval = interval*(-1) ;
	}
	
	if (interval < 30*60)
	{
		//ILOG(@"TaskView checkTime2Move] return NO\n")
		return NO;
	}
	
	//ILOG(@"TaskView checkTime2Move]\n")
	return YES;
}

- (void)dealloc
{
	//ILOG(@"[TaskView dealloc\n")
	if (self.name != nil)
	{
		[self.name release];
	}

	if (self.location != nil)
	{
		[self.location release];
	}	
	
	if (self.startTime != nil)
	{
		[self.startTime release];
	}

	if (self.endTime != nil)
	{
		[self.endTime release];
	}

	if (self.deadline != nil)
	{
		[self.deadline release];
	}
	
//Trung 08101701
/*
	if (self.moveArea != nil)
	{
		[self.moveArea release];
	}
 
	if (contextView != nil)
	{
		[contextView release];
	}
*/
	
	if (lastTouchTime != nil)
	{
		[lastTouchTime release];
	}
	
	[super dealloc];
	
	//ILOG(@"TaskView dealloc]\n")
}

@end
