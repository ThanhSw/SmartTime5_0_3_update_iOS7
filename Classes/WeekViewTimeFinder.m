//
//  WeekViewTimeFinder.m
//  SmartTime
//
//  Created by Left Coast Logic on 3/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WeekViewTimeFinder.h"
#import "TaskManager.h"
#import "Setting.h"
#import "WeekViewCalController.h"
#import "IvoCommon.h"
#import "ivo_Utilities.h"

extern TaskManager *taskmanager;
extern ivo_Utilities *ivoUtility;

//EK Sync
extern NSMutableArray *projectList;

@implementation WeekViewTimeFinder

@synthesize today;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		//self.userInteractionEnabled = NO;
        cellWidth=frame.size.width/7;
		self.backgroundColor = [UIColor clearColor];
		
		weekViewCtrler = nil;
		today = -1;
    }
    return self;
}

- (void)setToday:(NSInteger)todayVal
{
	today = todayVal;
	
	[self setNeedsDisplay]; 
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	UIColor *darkColor = [UIColor darkGrayColor];
	UIColor *lightColor = [UIColor whiteColor];
	UIColor *alternativeColor = [UIColor grayColor];	
	UIColor *todayColor = [UIColor grayColor];
	
	if(taskmanager.currentSetting.iVoStyleID==0)
	{
		lightColor = [UIColor colorWithRed:(CGFloat)196/255 green:(CGFloat)191/255 blue:(CGFloat)204/255 alpha:1];
		darkColor = [UIColor colorWithRed:(CGFloat)156/255 green:(CGFloat)151/255 blue:(CGFloat)164/255 alpha:1];
		alternativeColor = [UIColor colorWithRed:(CGFloat)176/255 green:(CGFloat)171/255 blue:(CGFloat)184/255 alpha:1];
		
		todayColor = [UIColor colorWithRed:(CGFloat)90/255 green:(CGFloat)111/255 blue:(CGFloat)140/255 alpha:1];
	}
	else
	{
		darkColor = [UIColor colorWithRed:(CGFloat)30/255 green:(CGFloat)30/255 blue:(CGFloat)30/255 alpha:1];
		lightColor = [UIColor colorWithRed:(CGFloat)70/255 green:(CGFloat)70/255 blue:(CGFloat)70/255 alpha:1];
		alternativeColor = [UIColor colorWithRed:(CGFloat)50/255 green:(CGFloat)50/255 blue:(CGFloat)50/255 alpha:1];

		todayColor = [UIColor colorWithRed:(CGFloat)90/255 green:(CGFloat)111/255 blue:(CGFloat)140/255 alpha:1];
	}

	[darkColor setFill];
	CGContextFillRect(ctx, CGRectMake(0, 0, cellWidth + 2, rect.size.height));
	CGContextFillRect(ctx, CGRectMake(6*cellWidth + 2, 0, cellWidth + 2, rect.size.height));

	[lightColor setFill];
	CGContextFillRect(ctx, CGRectMake(cellWidth + 2, 0, 5*cellWidth, rect.size.height));
	

	[alternativeColor setFill];
	CGContextFillRect(ctx, CGRectMake(2*cellWidth + 2, 0, cellWidth, rect.size.height));
	CGContextFillRect(ctx, CGRectMake(4*cellWidth + 2, 0, cellWidth, rect.size.height));	

	if (self.today != -1)
	{
		[todayColor setFill];
		CGContextFillRect(ctx, CGRectMake((self.today - 1)*cellWidth + 2, 0, cellWidth, rect.size.height));
	}
	
	[self drawFreeTime: ctx];

}

- (void)drawList:(NSMutableArray *)list inRect:(CGRect) rect context:(CGContextRef) ctx
{
	if (list == nil)
	{
		return;
	}
	
	//CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSDateComponents *deskTimeStartComps = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:taskmanager.currentSetting.deskTimeStart];
	NSDateComponents *deskTimeEndComps = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:taskmanager.currentSetting.deskTimeEnd];
	
	//CGFloat beginHour = 8;
	CGFloat beginHour = [deskTimeStartComps hour];
	CGFloat beginMinute = [deskTimeStartComps minute];
	//CGFloat totalMinutes = 12*60;
	CGFloat totalMinutes = ([deskTimeEndComps hour] - [deskTimeStartComps hour])*60 + [deskTimeEndComps minute] - [deskTimeStartComps minute];

	for (Task *task in list)
	{
		if (!task.isAllDayEvent && task.taskPinned)
		{
			NSDateComponents *startComps = [gregorian components:0xFF fromDate:task.taskStartTime];
			NSDateComponents *endComps = [gregorian components:0xFF fromDate:task.taskEndTime];

			NSInteger startHour = [startComps hour]; 
			NSInteger endHour = [endComps hour]; 

			NSInteger startMinute = [startComps minute];
			NSInteger minutes = task.taskHowLong/60;
			
			NSInteger minOffset = (startHour - beginHour)*60 + (startMinute - beginMinute);
			
			if (minOffset < 0) //out of left
			{
				minutes += minOffset;
				minOffset = 0;
			}
			
			if (minutes > 0 && minOffset < totalMinutes)
			{
				NSInteger minDuration = minutes;
				
				if (minutes > totalMinutes - minOffset) //> out of right 
				{
					minDuration = totalMinutes - minOffset;
				}
				
				CGFloat y = rect.size.height*minOffset/totalMinutes;
				CGFloat h = rect.size.height*minDuration/totalMinutes;
				
				//UIColor *color = [[ivoUtility getRGBColorForProject:task.taskProject isGetFirstRGB:NO] colorWithAlphaComponent:0.5];
				//EK Sync
				//NSInteger colorId = [(Projects*)[projectList objectAtIndex:task.taskProject] colorId];
				UIColor *color = [[ivoUtility getRGBColorForProject:task.taskProject isGetFirstRGB:NO] colorWithAlphaComponent:0.5];
				
				[color setFill];
				
				CGContextFillRect(ctx, CGRectMake(rect.origin.x, rect.origin.y + y, rect.size.width, h));				

			}				
			
		}
	}
	
	[gregorian release];
}

- (void)drawFreeTime:(CGContextRef) ctx
{
	if (weekViewCtrler == nil)
	{
		return;
	}
	
	NSMutableArray *list = weekViewCtrler.sunList;
	[self drawList:list inRect:CGRectMake(cellWidth + 2 - WEEKVIEW_FREETIME_WIDTH, 0, WEEKVIEW_FREETIME_WIDTH, self.bounds.size.height) context:ctx];
	 
	list = weekViewCtrler.monList;	
	[self drawList:list inRect:CGRectMake(2*cellWidth + 2 - WEEKVIEW_FREETIME_WIDTH, 0, WEEKVIEW_FREETIME_WIDTH, self.bounds.size.height) context:ctx];
	  
	list = weekViewCtrler.tueList;	
	[self drawList:list inRect:CGRectMake(3*cellWidth + 2 - WEEKVIEW_FREETIME_WIDTH, 0, WEEKVIEW_FREETIME_WIDTH, self.bounds.size.height) context:ctx];
	   
	list = weekViewCtrler.wedList;	
	[self drawList:list inRect:CGRectMake(4*cellWidth + 2 - WEEKVIEW_FREETIME_WIDTH, 0, WEEKVIEW_FREETIME_WIDTH, self.bounds.size.height) context:ctx];

	list = weekViewCtrler.thuList;	
	[self drawList:list inRect:CGRectMake(5*cellWidth + 2 - WEEKVIEW_FREETIME_WIDTH, 0, WEEKVIEW_FREETIME_WIDTH, self.bounds.size.height) context:ctx];

	list = weekViewCtrler.friList;	
	[self drawList:list inRect:CGRectMake(6*cellWidth + 2 - WEEKVIEW_FREETIME_WIDTH, 0, WEEKVIEW_FREETIME_WIDTH, self.bounds.size.height) context:ctx];

	list = weekViewCtrler.satList;	
	[self drawList:list inRect:CGRectMake(self.bounds.size.width - WEEKVIEW_FREETIME_WIDTH, 0, WEEKVIEW_FREETIME_WIDTH, self.bounds.size.height) context:ctx];
	//[self drawList:list inRect:CGRectMake(7*cellWidth + 2 - WEEKVIEW_FREETIME_WIDTH, 0, WEEKVIEW_FREETIME_WIDTH, self.bounds.size.height) context:ctx];
	 
}

- (void)setWeekViewController: (WeekViewCalController *)ctrler
{
	weekViewCtrler = ctrler;
}

- (void)dealloc {
    [super dealloc];
}


@end
