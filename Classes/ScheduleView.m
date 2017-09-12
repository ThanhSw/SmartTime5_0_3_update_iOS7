//
//  ScheduleView.m
//  iVo
//
//  Created by Left Coast Logic on 7/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import "IvoCommon.h"
#import "ScheduleView.h"
#import "TimeSlotView.h"
#import "CalendarView.h"

#define TIME_SLOT_HEIGHT 25


@implementation ScheduleView


- (id)initWithFrame:(CGRect)frame {
	//ILOG(@"[ScheduleView initWithFrame\n")
	
	if (self = [super initWithFrame:frame]) {
		
		// Initialization code
		self.backgroundColor = [UIColor clearColor];
		
		activeSlot = nil;
		
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];//nang
		
		unsigned unitFlags = 0xFFFF;
		NSDateComponents *comps = [gregorian components:unitFlags fromDate:[NSDate date]];
		
		int startHour = [CalendarView getStartHour];
		int endHour = [CalendarView getEndHour];
		
		for (int i=startHour; i<=endHour; i++)
		{
			int numSlots = (i==endHour? 1:2);
			
			for (int j=0; j<numSlots;j++)
			{
				[comps setHour:i];
				[comps setMinute:j*30];
				[comps setSecond:0];
			
				TimeSlotView *tsView = [[TimeSlotView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, TIME_SLOT_HEIGHT)];
				tsView.time = [gregorian dateFromComponents:comps];
			
				[self addSubview:tsView];
				[tsView release];
			}
		}
		
		CGFloat totalHeight = (endHour-startHour)*2*TIME_SLOT_HEIGHT;
		
		frame.size.height = totalHeight;
		
		self.frame = frame;
		[gregorian release];//nang

	}
	//ILOG(@"ScheduleView initWithFrame]\n")
	return self;
}

- (void) layoutSubviews
{
	//ILOG(@"[ScheduleView layoutSubviews\n")
	
	NSArray *views = self.subviews;
	
	CGFloat dy = 0;
	
	for (int i=0; i<views.count; i++)
	{
		UIView *view = [views objectAtIndex:i];
		CGRect frm = view.frame;
		
		frm.origin.y = dy;
		
		view.frame = frm;
		
		dy += frm.size.height;
	
        [view setNeedsDisplay];
	}
	
	//ILOG(@"ScheduleView layoutSubviews]\n")
}

- (NSDate *)getTimeSlot
{
	//ILOG(@"[ScheduleView getTimeSlot\n")
	
	if (activeSlot != nil)
	{
		//ILOG(@"ScheduleView getTimeSlot] NOT NIL\n")
		return activeSlot.time;
	}
	
	//ILOG(@"ScheduleView getTimeSlot]\n")
	return nil;
}

- (TimeSlotView *) hitTestRec: (CGRect) rec
{
	//ILOG(@"[ScheduleView hitTestRec\n")
	
	for (TimeSlotView *view in self.subviews)
	{
		if ([view hitTestRec:rec] != nil)
		{
			//ILOG(@"ScheduleView hitTestRec] NOT NIL\n")
			return view;
		}
	}
	
	//ILOG(@"ScheduleView hitTestRec]\n")
	return nil;
}

- (void) hightlight:(CGRect) rec
{
	//ILOG(@"[ScheduleView hightlight\n")
	
	rec.origin.x -= self.frame.origin.x;
	rec.origin.y -= self.frame.origin.y;
	
	TimeSlotView *slot = [self hitTestRec:rec];
	
	if (activeSlot == slot)
	{
		return;
	}
	
	[activeSlot unhightlight];
	
	activeSlot = slot;
	
	if (activeSlot != nil)
	{
		[activeSlot hightlight];
	}
	
	//ILOG(@"ScheduleView hightlight]\n")
}

- (void) unhightlight
{
	//ILOG(@"[ScheduleView unhightlight\n")
	
	if (activeSlot != nil)
	{
		[activeSlot unhightlight];
		activeSlot = nil;
	}
	//ILOG(@"ScheduleView unhightlight]\n")
}

- (void)drawRect:(CGRect)rect {
	// Drawing code
}


- (void)dealloc {
	[super dealloc];
}


@end
