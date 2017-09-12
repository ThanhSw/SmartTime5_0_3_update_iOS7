//
//  CalendarPageView.m
//  SmartTime
//
//  Created by Left Coast Logic on 2/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CalendarPageView.h"
#import "CalendarADEView.h"
#import "CalendarView.h"
#import "IvoCommon.h"
#import "TaskManager.h"
#import "Setting.h"

CalendarView *_calendarView = nil;
extern TaskManager *taskmanager;

@implementation CalendarPageView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
/*		
		//reset back color
		if(taskmanager.currentSetting.iVoStyleID==0){
			// for aesthetic reasons (the background is black), make the nav bar black for this particular page
			self.backgroundColor=[UIColor colorWithRed:1 green:1 blue:1 alpha:0.9];
		}else{
			// for aesthetic reasons (the background is black), make the nav bar black for this particular page
			self.backgroundColor=[UIColor blackColor];
		}
*/
		self.backgroundColor = [UIColor clearColor];
		
		CGRect rec = self.bounds;
		rec.size.height = ADE_VIEW_HEIGHT;
		
		adeView = [[CalendarADEView alloc] initWithFrame:rec];
		//adeView.hidden = YES;
		
		[self addSubview:adeView];
		[adeView release];
		
		rec.origin.y += ADE_VIEW_HEIGHT;
		rec.size.height = self.bounds.size.height - ADE_VIEW_HEIGHT;
		
		calendarView = [[CalendarView alloc] initWithFrame:rec];
		[self addSubview:calendarView];
		[calendarView release];
		
		_calendarView = calendarView;
    }
    return self;
}

- (void) setADEList: (NSMutableArray *)list
{
	if (list == nil || list.count == 0)
	{
		if (!adeView.hidden)
		{
			CGRect frm = calendarView.frame;
		
			frm.origin.y -= ADE_VIEW_HEIGHT;
			
			frm.size.height += ADE_VIEW_HEIGHT;
			
			calendarView.frame = frm;
		
			adeView.hidden = YES;
			
			adeView.adeList = list;
			
			[adeView resetIndex];
			[adeView setNeedsDisplay];
		}
	}
	else
	{
		if (adeView.hidden)
		{
			CGRect frm = calendarView.frame;
			
			frm.origin.y += ADE_VIEW_HEIGHT;
			
			frm.size.height -= ADE_VIEW_HEIGHT;
		
			calendarView.frame = frm;
			
			adeView.hidden = NO;
		}
		
		adeView.adeList = list;
		
		[adeView resetIndex];
		[adeView setNeedsDisplay];
	}
}

- (NSInteger) getSelectedKey
{
	return [adeView getSelectedKey];
}

//trung ST3.1
- (NSInteger) getSelectedTaskKey
{
	return [adeView getSelectedTaskKey]; 
}

- (NSDate *) getDisplayDate
{
	return [calendarView getScrollDate]; 
}

- (void) unselectADE
{
	adeView.selected = NO;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
    [super dealloc];
}


@end
