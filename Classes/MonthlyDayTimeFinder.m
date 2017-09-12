//
//  MonthlyDayTimeFinder.m
//  SmartTime
//
//  Created by Left Coast Logic on 3/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MonthlyDayTimeFinder.h"

#import "TaskManager.h"
#import "Setting.h"
#import "IvoCommon.h" 
#import "ivo_Utilities.h"

extern TaskManager *taskmanager;
extern ivo_Utilities *ivoUtility;

extern NSMutableArray *projectList;

@implementation MonthlyDayTimeFinder


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.userInteractionEnabled = NO;
		
		self.backgroundColor = [UIColor clearColor];
		
		taskList = nil;
    }
    return self;
}

-(void)showFreeTime:(NSMutableArray *)list
{
	taskList = list;
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	// Drawing code
	
	if (taskList == nil)
	{
		return;
	}
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSDateComponents *deskTimeStartComps = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:taskmanager.currentSetting.deskTimeStart];
	NSDateComponents *deskTimeEndComps = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:taskmanager.currentSetting.deskTimeEnd];
	
	CGFloat beginHour = [deskTimeStartComps hour];
	CGFloat beginMinute = [deskTimeStartComps minute];
	CGFloat totalMinutes = ([deskTimeEndComps hour] - [deskTimeStartComps hour])*60 + [deskTimeEndComps minute] - [deskTimeStartComps minute];
	
	for (Task *task in taskList)
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


- (void)dealloc {
    [super dealloc];
}


@end
