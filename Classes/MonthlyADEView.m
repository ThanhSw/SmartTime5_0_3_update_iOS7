//
//  MonthlyADEView.m
//  SmartTime
//
//  Created by Left Coast Logic on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MonthlyADEView.h"
#import "TaskManager.h"
#import "Task.h"
#import "ivo_Utilities.h"
#import "Setting.h"
#import "MonthlyCalendarView.h" 
#import "SmartTimeAppDelegate.h"

extern SmartTimeAppDelegate *App_Delegate;

extern TaskManager *taskmanager;
extern ivo_Utilities *ivoUtility;

extern NSMutableArray *projectList;

#define ADE_LINE_WIDTH 7
#define ADE_LINE_SPACE (ADE_LINE_WIDTH + 2)
#define ADE_LINE_MARGIN 20
#define TIME_LINE_WIDTH 7

@implementation MonthlyADEView

@synthesize startDate;
@synthesize endDate;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		
		self.backgroundColor = [UIColor clearColor];
		
		self.userInteractionEnabled = NO;
		
		startDate = nil;
		endDate = nil;
    }
	
    return self;
}

-(void) setStartDate:(NSDate *)startDateVal endDate:(NSDate *)endDateVal
{
	//self.startDate = startDateVal;
	//self.endDate = endDateVal;
	
    
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
    if (startDateVal){
        NSDateComponents *startComps = [gregorian components:0xFF fromDate:startDateVal];
        
        [startComps setHour:0];
        [startComps setMinute:0];
        [startComps setSecond:0];
        
        self.startDate = [gregorian dateFromComponents:startComps];
    }
    
    if (endDateVal) {
        NSDateComponents *endComps = [gregorian components:0xFF fromDate:endDateVal];
        
        [endComps setHour:23];
        [endComps setMinute:59];
        [endComps setSecond:60];
        
        self.endDate = [gregorian dateFromComponents:endComps];
    }

	[gregorian release];
	
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
	
	if (startDate == nil || endDate == nil)
	{
		return;
	}
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(ctx, ADE_LINE_WIDTH);
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

	NSDateComponents *startComps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:startDate];
	NSDate *startdt = [gregorian dateFromComponents:startComps];

	NSDateComponents *endComps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:endDate];
	NSDate *enddt = [gregorian dateFromComponents:endComps];
	
	NSDateComponents *deskTimeStartComps = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:taskmanager.currentSetting.deskTimeStart];
	NSDateComponents *deskTimeEndComps = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:taskmanager.currentSetting.deskTimeEnd];
	
	CGFloat beginHour = [deskTimeStartComps hour];
	CGFloat beginMinute = [deskTimeStartComps minute];
	CGFloat totalMinutes = ([deskTimeEndComps hour] - [deskTimeStartComps hour])*60 + [deskTimeEndComps minute] - [deskTimeStartComps minute];
	
	NSInteger duration[42][3];
	NSInteger project[42][3];
	NSInteger adeNum[42][2];
	NSInteger allocTime[42];
	BOOL dot[42];
	
	for (int i=0; i<42; i++)
	{
		dot[i] = NO;
		allocTime[i] = 0;
		
		for (int j=0; j<3; j++)
		{
			duration[i][j] = -1;
			project[i][j] = -1;
			
			if (j<2)
			{
				adeNum[i][j] = 0;
			}
		}
	}

	//NSMutableArray *list = [taskmanager getTaskListFromDate:[ivoUtility dateByAddNumDay:-1 toDate:startdt] toDate:[ivoUtility dateByAddNumDay:1 toDate:enddt] splitLongTask:YES];
	//NSMutableArray *list = [taskmanager getTaskListFromDate:[ivoUtility dateByAddNumDay:-1 toDate:startdt] toDate:[ivoUtility dateByAddNumDay:1 toDate:enddt] splitLongTask:YES];
	NSMutableArray *list = [taskmanager getTaskListFromDate:[ivoUtility dateByAddNumDay:-1 toDate:startdt] toDate:[ivoUtility dateByAddNumDay:1 toDate:enddt] splitLongTask:YES isUpdateTaskList:NO isSplitADE:NO];
 
	
//	printf("--- Month List ---\n");
//	[ivoUtility printTask:list];
//	printf("------------------\n");
	
	
	for (Task *task in list)
	{
		NSDateComponents *taskStartComps = [gregorian components:0xFF fromDate:task.taskStartTime];
		NSDateComponents *taskEndComps = [gregorian components:0xFF fromDate:task.taskEndTime];
		
		NSDate *dtStart = [gregorian dateFromComponents:taskStartComps];
		NSDate *dtEnd = [gregorian dateFromComponents:taskEndComps];
		
		if (([startDate compare:dtStart] != NSOrderedDescending && [endDate compare:dtStart] == NSOrderedDescending) ||
			([startDate compare:dtEnd] == NSOrderedAscending && [endDate compare:dtEnd] != NSOrderedAscending))		
		{
			//NSTimeInterval diff = [dtStart timeIntervalSinceDate:startdt];
			NSTimeInterval diff = [[ivoUtility dateWithoutDST:dtStart] timeIntervalSinceDate:[ivoUtility dateWithoutDST:startdt]];
			
			NSInteger index = diff/(24*60*60) ;
			
			//printf("%d. start (%s) - end (%s) - diff(%f)\n", index, [[startdt description] UTF8String], [[dtStart description] UTF8String], diff);
			
			NSInteger days = task.taskHowLong/(24*60*60);
			NSInteger minutes = task.taskHowLong/60;
			NSInteger startHour = [taskStartComps hour];
			NSInteger startMinute = [taskStartComps minute];
			
			if ([startDate compare:dtStart] == NSOrderedDescending) //start date is in previous month
			{
				index = 0;
				NSInteger secs = [startdt timeIntervalSinceDate:dtStart]; 
				days -= round(secs/(24*60*60));
				minutes -= secs/60 + startHour*60 + startMinute;
			}
			
			if ([startDate compare:dtStart] != NSOrderedDescending && [endDate compare:dtStart] != NSOrderedAscending && !task.isAllDayEvent)
			{
				dot[index] = YES;
			}			
			
			if (!task.isAllDayEvent && task.taskPinned) //draw time line
			{
				NSInteger minOffset = (startHour - beginHour)*60 + (startMinute - beginMinute);
				
				if (minOffset < 0) //out of left
				{
					minutes += minOffset;
					minOffset = 0;
				}
				
				NSInteger cellIndex = index;
				
				while (minutes > 0 && minOffset < totalMinutes)
				{
					NSInteger minDuration = minutes;
					
					if (minutes > totalMinutes - minOffset) //> out of right 
					{
						minDuration = totalMinutes - minOffset;
					}
					
					allocTime[cellIndex] = allocTime[cellIndex] + minDuration;
					
					dot[cellIndex] = YES;
					
					//calculate for next day
					minOffset = 0;
					minutes -= minDuration + (24*60 - totalMinutes);
					cellIndex ++;
					
				}				
			}				
			
			if (task.isAllDayEvent && task.taskPinned)
			{				
				BOOL found = NO;
				
				for (int j=0; j<3; j++)
				{
					if (duration[index][j] == -1)
					{
						duration[index][j] = days;
						project[index][j] = task.taskProject;
						
						adeNum[index][0] += 1;
						
						for (int k=1;k<days;k++)
						{
							if (index + k < 42)
							{
								adeNum[index+k][1] += 1;
							}
						}
						
						found = YES;
						break;
					}
				}
				
				if (!found)
				{
					NSInteger minIndex = -1;
					
					for (int j=0; j<3; j++)
					{
						if (duration[index][j] < days)
						{
							minIndex = j;
							break;
						}
					}
					
					if (minIndex != -1)
					{
						duration[index][minIndex] = days;
						project[index][minIndex] = task.taskProject;
						
						adeNum[index][0] += 1;
						
						for (int k=1;k<days;k++)
						{
							if (index + k < 42)
							{
								adeNum[index+k][1] += 1;
							}
						}
						
					}					
				}
				
			}
		}
		
	}

	CGFloat dayWidth = self.frame.size.width/7; 
	CGFloat dayHeight = self.frame.size.height/6;
	
	UIColor *dotColor = [UIColor whiteColor];
	
	if(taskmanager.currentSetting.iVoStyleID==0)
	{
		dotColor = [UIColor blackColor];
	}
	
	for (int i=0; i<42; i++)
	{
		int div = i/7;
		int mod = i%7;
		
		if (dot[i])
		{
			[dotColor setFill];
			
			CGContextFillEllipseInRect(ctx, CGRectMake(mod*dayWidth + dayWidth/2 - 2, div*dayHeight + 2 + 5, 5, 5));
		}
		
		NSInteger num1 = (adeNum[i][1] > 3? 3:adeNum[i][1]);
		NSInteger num0 = (adeNum[i][0] > 3? 3:adeNum[i][0]);		
		
		CGFloat yoffset = ADE_LINE_MARGIN + ((num1 < 3 - num0)?num1:(3 - num0))*ADE_LINE_SPACE; 
		
		for (int j=0; j<3; j++)
		{
			if (duration[i][j] != -1)
			{
				//UIColor *color = [ivoUtility getRGBColorForProject:project[i][j] isGetFirstRGB:NO];
				//EK Sync
				//NSInteger colorId = [[projectList objectAtIndex:project[i][j]] colorId];
                
                //Projects *prj=[App_Delegate calendarWithPrimaryKey:<#(NSInteger)#>];
               
                //V4.1
				//UIColor *color = [ivoUtility getRGBColorForProject:[[projectList objectAtIndex:project[i][j]] primaryKey] isGetFirstRGB:NO];
				
                UIColor *color = [ivoUtility getRGBColorForProject:project[i][j] isGetFirstRGB:NO];
                
				[color set];
				
				BOOL toBreak = (mod + duration[i][j] > 7); 
				
				NSInteger segment = (toBreak?7-mod:duration[i][j]);
				
				CGContextMoveToPoint(ctx, mod*dayWidth , div*dayHeight + yoffset + j*ADE_LINE_SPACE);
				CGContextAddLineToPoint(ctx, (mod + segment)*dayWidth, div*dayHeight + yoffset + j*ADE_LINE_SPACE);
				CGContextStrokePath(ctx);
				
				if (toBreak)
				{
					segment = duration[i][j] - segment;
					NSInteger segmentDiv = div + 1;
					
					while (segment > 7)
					{
						CGContextMoveToPoint(ctx, 0 , segmentDiv*dayHeight + yoffset + j*ADE_LINE_SPACE);
						CGContextAddLineToPoint(ctx, self.frame.size.width, segmentDiv*dayHeight + yoffset + j*ADE_LINE_SPACE);
						CGContextStrokePath(ctx);
						
						segment -= 7;
						segmentDiv += 1;
						
						if (segmentDiv == 5)
						{
							break;
						}
					}
					
					if (segment > 0 && segmentDiv <= 5)
					{
						CGContextMoveToPoint(ctx, 0 , segmentDiv*dayHeight + yoffset + j*ADE_LINE_SPACE);
						CGContextAddLineToPoint(ctx, segment*dayWidth, segmentDiv*dayHeight + yoffset + j*ADE_LINE_SPACE);
						CGContextStrokePath(ctx);
					}
				}
			}
		}
	}
	
	MonthlyCalendarView *calView = (MonthlyCalendarView *) self.superview;
	
	[calView setAllocTime:allocTime duration:totalMinutes];
	
	
	[gregorian release];	
}

- (void)dealloc {
    [super dealloc];
}


@end
