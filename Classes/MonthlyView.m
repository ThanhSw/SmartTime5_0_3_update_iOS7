//
//  MonthlyView.m
//  SmartTime
//
//  Created by Left Coast Logic on 12/29/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MonthlyView.h"
#import "MonthlyCalendarView.h"
#import "MonthlyTableView.h"
#import "IvoCommon.h"
#import "MonthlyTitleBackgroundView.h"
#import "TaskManager.h"
#import "Setting.h"
#import "MonthlyViewController.h"
#import "TaskManager.h"
#import "SmartTimeAppDelegate.h"


//#import "WeekViewCalController.h"
#import "SmartViewController.h"
#import "WeekView.h"

#define kTransitionDuration	0.2
#define kAnimationKey @"monthViewAnimation"

extern TaskManager *taskmanager;
extern ivo_Utilities *ivoUtility;

extern BOOL _startDayAsMonday;
extern NSString* _dayNamesMon[7];
extern NSString* _dayNamesSun[7];
extern NSString* _monthNames[12];


@implementation MonthlyView

//@synthesize controller;
@synthesize date;
@synthesize isFilter;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		//_startDayAsMonday = (taskmanager.currentSetting.weekStartDay==START_MONDAY?YES:NO);
		
		bgView = [[MonthlyTitleBackgroundView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, MONTH_TITLE_HEIGHT + DAY_TITLE_HEIGHT)];
		[self addSubview:bgView];
		[bgView release];
		
		month = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MONTHVIEW_WIDTH, MONTH_TITLE_HEIGHT)];
		
		//month.backgroundColor=bgColor;
		month.backgroundColor = [UIColor clearColor];
		month.textColor = [UIColor whiteColor];
		month.font = [UIFont boldSystemFontOfSize:18];
		month.textAlignment = NSTextAlignmentCenter;
		month.text = NSLocalizedString(@"febText", @"") /*@"February 2009"*/;
		
		[self addSubview:month];
		[month release];
		
		CGFloat dayWidth = floor(MONTHVIEW_WIDTH/7);		
		
		for (int i=0; i<7; i++)
		{
			UILabel *day = [[UILabel alloc] initWithFrame:CGRectMake(i*dayWidth, MONTH_TITLE_HEIGHT, dayWidth, DAY_TITLE_HEIGHT)];
			
			//day.backgroundColor = bgColor;
			day.backgroundColor = [UIColor clearColor];
			day.textColor = [UIColor whiteColor];
			day.font = [UIFont systemFontOfSize:12];
			day.textAlignment = NSTextAlignmentCenter;
			day.text = taskmanager.currentSetting.weekStartDay==START_MONDAY?_dayNamesMon[i]:_dayNamesSun[i];
			
			[self addSubview:day];
			
			[day release];			
		}
		
		UIButton *prevButton=[ivoUtility createButton:@"" 
										   buttonType:UIButtonTypeCustom 
												frame:CGRectMake(5, 0, /*1.5*dayWidth*/60, MONTH_TITLE_HEIGHT) 
										   titleColor:[UIColor whiteColor]
											   target:self 
											 selector:@selector(goPrev:) 
									 normalStateImage:@"" 
								   selectedStateImage:nil];
		prevButton.titleLabel.font=[UIFont systemFontOfSize:22];
		prevButton.backgroundColor=[UIColor clearColor];
		[prevButton setImage:[UIImage imageNamed:@"left_arrow.png"] forState:UIControlStateNormal];
		
		[self addSubview:prevButton];
		
		[prevButton release];
		
		UIButton *nextButton=[ivoUtility createButton:@"" 
										   buttonType:UIButtonTypeCustom 
												frame:CGRectMake(MONTHVIEW_WIDTH - 1.5*dayWidth - 5, 0, /*1.5*dayWidth*/60, MONTH_TITLE_HEIGHT) 
										   titleColor:[UIColor whiteColor]
											   target:self 
											 selector:@selector(goNext:) 
									 normalStateImage:@"" 
								   selectedStateImage:nil];
		[nextButton setImage:[UIImage imageNamed:@"right_arrow.png"] forState:UIControlStateNormal];
		nextButton.titleLabel.font=[UIFont systemFontOfSize:22];
		nextButton.backgroundColor= [UIColor clearColor];
		
		[self addSubview:nextButton];
		[nextButton release];
		
		filterModeView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"filterWKV.png"]];
		filterModeView.frame=CGRectMake(dayWidth, 8, 15, 15);
		filterModeView.hidden=YES;
		[self addSubview:filterModeView];
		[filterModeView release];

		UIColor *txtColor = [UIColor whiteColor];
		
		CGFloat listViewWidth = frame.size.width - MONTHVIEW_WIDTH;
		
		CGFloat toWeekButtonWidth = 2*(listViewWidth)/3;
		
		NSString *weekTitle = NSLocalizedString(@"weekText", @"Week")/*weekText*/;//@"Week";
		
		toWeekButton=[ivoUtility createButton:weekTitle 
								   buttonType:UIButtonTypeCustom 
										//frame:CGRectMake((frame.size.width - toWeekButtonWidth)/2, 2, toWeekButtonWidth, MONTH_TITLE_HEIGHT - 2) 
					  frame:CGRectMake(MONTHVIEW_WIDTH + (listViewWidth - toWeekButtonWidth)/2, 2, toWeekButtonWidth, MONTH_TITLE_HEIGHT - 2) 
								   titleColor:[UIColor whiteColor]
									   target:self 
									 selector:@selector(toWeek:) 
							 normalStateImage:@"no-mash-blue.png" 
						   selectedStateImage:nil];
		
		[self addSubview:toWeekButton];
		
		//dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, MONTH_TITLE_HEIGHT - 3, frame.size.width, DAY_TITLE_HEIGHT + 2)];
		dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(MONTHVIEW_WIDTH, MONTH_TITLE_HEIGHT - 3, listViewWidth, DAY_TITLE_HEIGHT + 2)];
		dayLabel.text = NSLocalizedString(@"todayText", @"Today")/*todayText*/;//@"Today";
		dayLabel.font = [UIFont italicSystemFontOfSize:12];
		dayLabel.backgroundColor = [UIColor clearColor];
		dayLabel.textAlignment = NSTextAlignmentCenter;
		dayLabel.textColor = txtColor;
		
		[self addSubview:dayLabel];		
		[dayLabel release];
		
		//monthView = [[MonthlyCalendarView alloc] initWithFrame:CGRectMake(0, 0, MONTHVIEW_WIDTH, frame.size.height)];
		//monthView = [[MonthlyCalendarView alloc] initWithFrame:CGRectMake(0, MONTH_TITLE_HEIGHT + DAY_TITLE_HEIGHT, MONTHVIEW_WIDTH, frame.size.height)];
		monthView = [[MonthlyCalendarView alloc] initWithFrame:CGRectMake(0, 0, MONTHVIEW_WIDTH, frame.size.height - MONTH_TITLE_HEIGHT - DAY_TITLE_HEIGHT)];
		
		//listView = [[MonthlyTableView alloc] initWithFrame:CGRectMake(MONTHVIEW_WIDTH, 0, frame.size.width - MONTHVIEW_WIDTH, frame.size.height)];
		//listView = [[MonthlyTableView alloc] initWithFrame:CGRectMake(MONTHVIEW_WIDTH, MONTH_TITLE_HEIGHT + DAY_TITLE_HEIGHT, listViewWidth, frame.size.height)];
		listView = [[MonthlyTableView alloc] initWithFrame:CGRectMake(MONTHVIEW_WIDTH, 0, listViewWidth, frame.size.height - MONTH_TITLE_HEIGHT - DAY_TITLE_HEIGHT)];
		
		//[self addSubview:monthView];
		//[self addSubview:listView];
		
		pageView = [[UIView alloc] initWithFrame:CGRectMake(0, MONTH_TITLE_HEIGHT + DAY_TITLE_HEIGHT, frame.size.width, frame.size.height - MONTH_TITLE_HEIGHT - DAY_TITLE_HEIGHT)];
		pageView.backgroundColor = [UIColor clearColor];
		
		[pageView addSubview:monthView];
		[pageView addSubview:listView];
		
		[self addSubview:pageView];
		[pageView release];
		
		isFilter = NO;
    }
    return self;
}

- (void) showMonthTitle: (NSString *) title
{
	month.text = title;
}

- (void)showWeekTitle:(NSString *)title
{
	[toWeekButton setTitle:title forState:UIControlStateNormal];
}

- (void)showDayTitle:(NSString *)title
{
	dayLabel.text = title; 
}

- (void) resetIvoStyle
{
	[bgView setNeedsDisplay];
	
	if (self.date != nil)
	{
		[self initCalendarDate:self.date];
	}
	else
	{
		[self initCalendarDate:[NSDate date]];
	}
}

#pragma mark action methods
-(void)goPrev:(id)sender{
	[monthView showPreviousMonth];
/*	
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromLeft];
	
	[animation setDuration:kTransitionDuration];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
	
	[[pageView layer] addAnimation:animation forKey:kAnimationKey];	
*/	
}

-(void)goNext:(id)sender{
	[monthView showNextMonth];
/*	
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromRight];
	
	[animation setDuration:kTransitionDuration];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
	
	[[pageView layer] addAnimation:animation forKey:kAnimationKey];	
*/
}

-(void)toWeek:(id)sender
{
	//[self.controller showView:0 date:self.date];
	
	WeekView *weekView = (WeekView *)[self superview];
	
	if (weekView != nil)
	{
		[weekView showView:0 date:self.date];
	}
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}

- (void)initCalendarDate:(NSDate *)dte
{
    if (!dte) return;
    
	self.date = dte;
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	
	NSDateComponents *todayComps = [gregorian components:unitFlags fromDate:dte];
	
	NSInteger currentMonth = [todayComps month];
	NSInteger currentYear = [todayComps year];
	NSInteger currentDay = [todayComps day];
	
	[monthView showMonth:currentMonth withYear:currentYear withDay:currentDay];
	
	[gregorian release];
	
	filterModeView.hidden = !isFilter;
}

- (void)setCalendarDate:(NSDate *)dte
{
	self.date = dte;

	[listView setCalendarDate:dte isFilter:self.isFilter];
	
	WeekView *parent = (WeekView *)self.superview;
	parent.currentDisplayDate = dte;
/*	
	if (self.controller != nil)
	{
		self.controller.isBackFromMonthView = YES;
		
		self.controller.SmartViewController.selectedWeekDate = date;
		
	}
*/
}

- (void)goToDate:(NSDate *)dte
{
	self.date = dte;
	
	[monthView selectDate:dte];
}

-(void)doFilter:(BOOL)isFilterVal
{
	//trung ST3.1
	isFilter = isFilterVal;
	if (self.date != nil)
	{
		[self initCalendarDate:self.date];
	}
	else
	{
		[self initCalendarDate:[NSDate date]];
	}		
}

-(void)showFocus: (NSString *)focus 
{
	UITextView *focusView = [self.subviews objectAtIndex:2];
	
	focusView.text = focus;
}


- (void)dealloc {
	[toWeekButton release];
	
	[monthView release];
	[listView release];

	[date release];
	
    [super dealloc];
}


@end
