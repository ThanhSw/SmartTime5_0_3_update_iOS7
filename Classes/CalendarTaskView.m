//
//  CalendarTaskView.m
//  IVo
//
//  Created by Left Coast Logic on 6/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import "IvoCommon.h"
#import "CalendarTaskView.h"
#import "CalendarView.h"
#import "ivo_Utilities.h"

#define TIME_SLOT_HEIGHT 25
#define CALENDAR_VIEW_ALIGNMENT 20
#define CALENDAR_VIEW_PAD 10
#define SUBTASKNO_SIZE 20

#define TIME_LINE_PAD 5
#define LEFT_MARGIN 3

#define MOVE_ANIMATION_DURATION_SECONDS 0.1

extern CalendarView *_calendarView;

@implementation CalendarTaskView


- (id)initWithFrame:(CGRect)frame {
	//ILOG(@"[CalendarTaskView initWithFrame\n")
	
	if (self = [super initWithFrame:frame]) {
		// Initialization code

	}
	//ILOG(@"CalendarTaskView initWithFrame]\n")
	return self;
}

- (TaskTypeEnum) getTaskType
{
	return TYPE_CALENDAR_TASK;
}

- (CGSize) calculateSize
{
	//ILOG(@"[CalendarTaskView calculateSize\n")
	
	CGSize size;
	
	size.width = 0;
	size.height = 0;
	
	CGSize timePaneSize = [CalendarView calculateTimePaneSize];
	
	CGRect mainfrm = [[UIScreen mainScreen] bounds];
	
	NSTimeInterval howLong = [self.endTime timeIntervalSinceDate:self.startTime];
	
	size.width = mainfrm.size.width - LEFT_MARGIN - timePaneSize.width - TIME_LINE_PAD - CALENDAR_VIEW_ALIGNMENT - 3;
	
	CGFloat hours = howLong/3600;
	
	if (hours < 0.5)
	{
		size.height = TIME_SLOT_HEIGHT;
	}
	else
	{
		size.height = 2*TIME_SLOT_HEIGHT*hours;
	}
	
	//ILOG(@"CalendarTaskView calculateSize]\n")
	return size;
}

//[Trung v2.0] 
- (SmartTimeView *)parentView
{
	return _calendarView;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code here.
	[super drawRect:rect];
}

- (void)dealloc {
	//ILOG(@"[CalendarTaskView dealloc\n")
	
	[super dealloc];
	
	//ILOG(@"CalendarTaskView dealloc]\n")
}


@end
