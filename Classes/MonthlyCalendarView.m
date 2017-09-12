//
//  MonthlyCalendarView.m
//  SmartTime
//
//  Created by Left Coast Logic on 12/31/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MonthlyCalendarView.h"
#import "MonthlyCellView.h"

#import "MonthlyView.h"
#import "ivo_Utilities.h"
#import "SmartTimeAppDelegate.h"

#import "MonthlyADEView.h"
#import "TaskManager.h"

extern ivo_Utilities *ivoUtility;
extern SmartTimeAppDelegate *App_Delegate;
extern TaskManager *taskmanager;

extern BOOL _startDayAsMonday;
extern NSString* _monthNames[12];

@implementation MonthlyCalendarView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		//_startDayAsMonday = (taskmanager.currentSetting.weekStartDay==START_MONDAY?YES:NO);
		
		selectedCellIndex = -1;
		todayCellIndex = -1;
		
		CGFloat width = frame.size.width;
		CGFloat dayWidth = floor(width/7);
		
		UIColor *bgColor = [UIColor lightGrayColor];
		//UIColor *txtColor = [UIColor whiteColor];
	
		if(taskmanager.currentSetting.iVoStyleID==0){
			// for aesthetic reasons (the background is black), make the nav bar black for this particular page
			bgColor=[UIColor colorWithRed:0.64 green:0.7 blue:0.77 alpha:1];
		}else{
			// for aesthetic reasons (the background is black), make the nav bar black for this particular page
			bgColor=[UIColor colorWithRed:0.33 green:0.33 blue:0.33 alpha:1];
		}
		
		CGFloat cellHeight = floor(frame.size.height/6);
		
		CGFloat ymargin = 0;
		CGFloat yoffset = 0;
		
		for (int i=0; i<42; i++)
		{
			int mod = i%7;
			
			CGFloat height = cellHeight;
			
			BOOL isWeekend = (taskmanager.currentSetting.weekStartDay==START_MONDAY?(mod == 5 || mod == 6):(mod == 0 || mod == 6));
			
			CGRect frm = CGRectMake(mod*dayWidth, ymargin+ yoffset, dayWidth, height);
			
			MonthlyCellView *cell = [[MonthlyCellView alloc] initWithFrame:frm];
			cell.day = -1;
			cell.index = i;
			
			if (isWeekend)
			{
				cell.isWeekend = YES;
			}
			
			
			cell.selected = NO;
			
			if (mod == 6)
			{
				yoffset += height;
			}
			
			[self addSubview:cell];
			
			[cell release];
		}
		
		adeView = [[MonthlyADEView alloc] initWithFrame: CGRectMake(0, ymargin, frame.size.width, frame.size.height - ymargin)];
		
		[self addSubview:adeView];
		
    }
    return self;
}

-(void)selectCell:(NSInteger)cellIndex
{
	NSInteger firstCellIndex = 0; 
	
	MonthlyCellView *cell = nil;
	
	if (selectedCellIndex >=0)
	{
		cell = [[self subviews] objectAtIndex:firstCellIndex + selectedCellIndex];
	
		cell.selected = NO;
	}
	
	selectedCellIndex = cellIndex;
	
	cell = [[self subviews] objectAtIndex:firstCellIndex + selectedCellIndex];

	cell.selected = YES;
		
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSDateComponents *comps = [gregorian components:0xFF fromDate:[NSDate date]];
	
	[comps setYear:cell.year];
	[comps setMonth:cell.month];
	[comps setDay:cell.day];
	
	NSDate *date = [gregorian dateFromComponents:comps];

	MonthlyView *parent = (MonthlyView *)[[self superview] superview];
	
	[parent setCalendarDate:date];
	
	[gregorian release];
}

- (void)selectDate:(NSDate *)date
{
    if (!date) return;
    
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	
	//NSDateComponents *currentComps = [gregorian components:unitFlags fromDate:self.date];
	NSDateComponents *dtComps = [gregorian components:unitFlags fromDate:date];
	
	NSInteger dtMonth = [dtComps month];
	NSInteger dtYear = [dtComps year];
	NSInteger dtDay = [dtComps day];
	
	if (dtMonth == currentMonth && dtYear == currentYear)
	{
		//NSInteger firstCellIndex = 10;
		NSInteger firstCellIndex = 0; 
		
		for (int i=0; i<42; i++)
		{
			MonthlyCellView *cell = [[self subviews] objectAtIndex:firstCellIndex + i];
			
			if (cell.month == dtMonth && cell.year == dtYear && cell.day == dtDay)
			{
				[self selectCell:cell.index];
				break;
			}
		}			
	}
	else
	{
		[self showMonth:dtMonth withYear:dtYear withDay:dtDay];
	}
	
	[gregorian release];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}

-(void)showFocus: (NSString *)focus 
{
	MonthlyView *parent = (MonthlyView *)[[self superview] superview];
	
	[parent showFocus:focus];
}

- (void) showNextMonth
{
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	if (currentMonth == 12)
	{
		currentMonth = 1;
		currentYear += 1;
	}	
	else
	{
		currentMonth += 1;
	}
	
	[self showMonth:currentMonth withYear:currentYear withDay:-1];
	
	App_Delegate.me.networkActivityIndicatorVisible=NO;
}

- (void) showPreviousMonth
{
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	if (currentMonth == 1)
	{
		currentMonth = 12;
		currentYear -= 1;
	}
	else
	{
		currentMonth -= 1;
	}
	
	[self showMonth:currentMonth withYear:currentYear withDay:-1];	
	
	App_Delegate.me.networkActivityIndicatorVisible=NO;
}

-(NSString *) getMonthTitle
{
	return [NSString stringWithFormat:@"%@ %4d", _monthNames[currentMonth-1], currentYear];
}

//daylight saving fix
-(void)showMonth:(NSInteger)month withYear:(NSInteger)year withDay:(NSInteger)day
{
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	if (month > 12 || month < 1)
	{
		return;
	}
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSDate *today = [NSDate date];
	
	NSDateComponents *firstDateComps = [gregorian components:0xFF fromDate:today]; //today
	
	NSInteger todayYear = [firstDateComps year];
	NSInteger todayMonth = [firstDateComps month];
	NSInteger todayDay = [firstDateComps day];
	
	NSInteger dayYear = (day == -1?[firstDateComps year]:year);	
	NSInteger dayMonth = (day == -1?[firstDateComps month]:month);
	NSInteger dayDay = (day == -1?[firstDateComps day]:day);
	
	[firstDateComps setYear:year];
	[firstDateComps setMonth:month];
	[firstDateComps setDay:1];
	
	NSInteger firstCellIndex = 0;
	
	if (todayCellIndex != -1) //clear today border
	{
		MonthlyCellView *cell = [[self subviews] objectAtIndex:firstCellIndex + todayCellIndex];
		
		cell.isToday = NO;
		todayCellIndex = -1;
	}
	
	NSInteger wkday = [[gregorian components:NSWeekdayCalendarUnit fromDate:[gregorian dateFromComponents:firstDateComps]] weekday];
	
	NSInteger firstDayIndex = wkday - 1; //start day is Sunday
	
	if (taskmanager.currentSetting.weekStartDay==START_MONDAY)
	{
		if (wkday == 1)
		{
			firstDayIndex = 6;
		}
		else
		{
			firstDayIndex = wkday - 2;
		}
	}
	
	NSInteger startIndex = firstCellIndex + firstDayIndex; 
	
	NSDateComponents *nextFirstDateComps = [gregorian components:0xFF fromDate:today];
	
	if (month == 12)
	{
		[nextFirstDateComps setYear:year + 1];
		[nextFirstDateComps setMonth:1];
		[nextFirstDateComps setDay:1];
	}
	else
	{
		[nextFirstDateComps setYear:year];
		[nextFirstDateComps setMonth:month+1];
		[nextFirstDateComps setDay:1];		
	}
	
	//printf("next First Date = %s\n", [[[gregorian dateFromComponents:nextFirstDateComps] description] UTF8String]);

	//fix DST
	//NSDate *lastDate = [[gregorian dateFromComponents:nextFirstDateComps] addTimeInterval:-24*60*60];
	NSDate *lastDate = [ivoUtility dateByAddNumDay:-1 toDate:[gregorian dateFromComponents:nextFirstDateComps]];
	
	//printf("last Date = %s\n", [[lastDate description] UTF8String]);
	
	NSDateComponents *lastDateComps = [gregorian components:0xFF fromDate:lastDate];
	
	NSInteger nDays = [lastDateComps day];
	
	//printf("days: %d\n", nDays);
	
	BOOL sameMonthYear = (dayMonth == month && dayYear == year);
	
	for (int i=0; i<nDays; i++)
	{
		MonthlyCellView *cell = [[self subviews] objectAtIndex:startIndex + i];
		cell.day = i+1;
		cell.month = month;
		cell.year = year;
		cell.gray = NO;
		
		//printf("%d - %4d/%2d/%2d\n", startIndex + i, cell.year, cell.month, cell.day);
		
		if (cell.day == todayDay && cell.month == todayMonth && cell.year == todayYear)
		{
			cell.isToday = YES;
			todayCellIndex = startIndex + i;
		}
		
		if (sameMonthYear && cell.day == dayDay)
		{
			[self selectCell:cell.index]; //select day
		}
		else
		{
			cell.selected = NO;
		}
		
	}
	
	if (!sameMonthYear)
	{
		MonthlyCellView *cell = [[self subviews] objectAtIndex:startIndex];
		[self selectCell:cell.index]; //select the first day
	}
	
	if (startIndex > firstCellIndex)
	{
		//fix DST
		//NSDate *lastDatePrevMonth = [[gregorian dateFromComponents:firstDateComps] addTimeInterval:-24*60*60];
		NSDate *lastDatePrevMonth = [ivoUtility dateByAddNumDay:-1 toDate:[gregorian dateFromComponents:firstDateComps]];
		
		NSDateComponents *lastDatePrevMonthComps = [gregorian components:0xFF fromDate:lastDatePrevMonth];
		
		NSInteger lastDayPrevMonth = [lastDatePrevMonthComps day];
		
		for (int i=startIndex-1; i>=firstCellIndex; i--)
		{
			MonthlyCellView *cell = [[self subviews] objectAtIndex:i];
			cell.day = lastDayPrevMonth--;
			
			cell.month = (month == 1?12:month-1);
			cell.year = (month == 1?year-1:year);
			cell.gray = YES;
			
			if (cell.day == todayDay && cell.month == todayMonth && cell.year == todayYear)
			{
				cell.isToday = YES;
				todayCellIndex = i;
			}			
			
			cell.selected = NO;
		}
		
	}
	
	if (startIndex + nDays <  firstCellIndex + 42)
	{
		NSInteger day = 1;
		
		for (int i=startIndex+nDays; i<firstCellIndex+42; i++)
		{
			MonthlyCellView *cell = [[self subviews] objectAtIndex:i];
			cell.day = day++;
			
			cell.month = (month == 12?1:month+1);
			cell.year = (month == 12?year+1:year);
			cell.gray = YES;
			
			if (cell.day == todayDay && cell.month == todayMonth && cell.year == todayYear)
			{
				cell.isToday = YES;
				todayCellIndex = i;
			}
			
			cell.selected = NO;
		}
		
	}
	
	MonthlyCellView *cell = [[self subviews] objectAtIndex:firstCellIndex];	
	
	[firstDateComps setYear:cell.year];
	[firstDateComps setMonth:cell.month];
	[firstDateComps setDay:cell.day];
	
	cell = [[self subviews] objectAtIndex:firstCellIndex + 41];	
	
	[lastDateComps setYear:cell.year];
	[lastDateComps setMonth:cell.month];
	[lastDateComps setDay:cell.day];
	
	[adeView setStartDate:[gregorian dateFromComponents:firstDateComps] endDate:[gregorian dateFromComponents:lastDateComps]];
	
	currentMonth = month;
	currentYear = year;
	
	MonthlyView *parent = (MonthlyView *)[[self superview] superview];
	[parent showMonthTitle:[self getMonthTitle]];
	
	[gregorian release];	
	
	App_Delegate.me.networkActivityIndicatorVisible=NO;	
}

-(void)showMonth_old:(NSInteger)month withYear:(NSInteger)year withDay:(NSInteger)day
{
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	if (month > 12 || month < 1)
	{
		return;
	}

	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSDateComponents *firstDateComps = [gregorian components:0xFF fromDate:[NSDate date]]; //today

	NSInteger todayYear = [firstDateComps year];	
	NSInteger todayMonth = [firstDateComps month];
	NSInteger todayDay = [firstDateComps day];

	NSInteger dayYear = (day == -1?[firstDateComps year]:year);	
	NSInteger dayMonth = (day == -1?[firstDateComps month]:month);
	NSInteger dayDay = (day == -1?[firstDateComps day]:day);
	
	[firstDateComps setYear:year];
	[firstDateComps setMonth:month];
	[firstDateComps setDay:1];
	
	NSInteger firstCellIndex = 0;
	
	if (todayCellIndex != -1) //clear today border
	{
		MonthlyCellView *cell = [[self subviews] objectAtIndex:firstCellIndex + todayCellIndex];
		
		cell.isToday = NO;
		todayCellIndex = -1;
	}
	
	NSInteger wkday = [[gregorian components:NSWeekdayCalendarUnit fromDate:[gregorian dateFromComponents:firstDateComps]] weekday];
	
	NSInteger firstDayIndex = wkday - 1; //start day is Sunday
	
	if (taskmanager.currentSetting.weekStartDay==START_MONDAY)
	{
		if (wkday == 1)
		{
			firstDayIndex = 6;
		}
		else
		{
			firstDayIndex = wkday - 2;
		}
	}
	
	NSInteger startIndex = firstCellIndex + firstDayIndex; 
	
	NSDateComponents *nextFirstDateComps = [gregorian components:0xFF fromDate:[NSDate date]];

	if (month == 12)
	{
		[nextFirstDateComps setYear:year + 1];
		[nextFirstDateComps setMonth:1];
		[nextFirstDateComps setDay:1];
	}
	else
	{
		[nextFirstDateComps setYear:year];
		[nextFirstDateComps setMonth:month+1];
		[nextFirstDateComps setDay:1];		
	}
	
	printf("next First Date = %s\n", [[[gregorian dateFromComponents:nextFirstDateComps] description] UTF8String]);
	
	NSDate *lastDate = [ivoUtility dateByAddNumSecond:-24*60*60 toDate:[gregorian dateFromComponents:nextFirstDateComps]];
	
	printf("last Date = %s\n", [[lastDate description] UTF8String]);
	
	NSDateComponents *lastDateComps = [gregorian components:0xFF fromDate:lastDate];
	
	NSInteger nDays = [lastDateComps day];
	
	printf("days: %d\n", nDays);
	
	BOOL sameMonthYear = (dayMonth == month && dayYear == year);
	
	for (int i=0; i<nDays; i++)
	{
		MonthlyCellView *cell = [[self subviews] objectAtIndex:startIndex + i];
		cell.day = i+1;
		cell.month = month;
		cell.year = year;
		cell.gray = NO;
		
		printf("%d - %4d/%2d/%2d\n", startIndex + i, cell.year, cell.month, cell.day);

		if (cell.day == todayDay && cell.month == todayMonth && cell.year == todayYear)
		{
			cell.isToday = YES;
			todayCellIndex = startIndex + i;
		}
		
		if (sameMonthYear && cell.day == dayDay)
		{
			[self selectCell:cell.index]; //select day
		}
		else
		{
			cell.selected = NO;
		}
		
	}
	
	if (!sameMonthYear)
	{
		MonthlyCellView *cell = [[self subviews] objectAtIndex:startIndex];
		[self selectCell:cell.index]; //select the first day
	}
	
	if (startIndex > firstCellIndex)
	{
		NSDate *lastDatePrevMonth = [ivoUtility dateByAddNumSecond:-24*60*60 toDate:[gregorian dateFromComponents:firstDateComps]];
		
		NSDateComponents *lastDatePrevMonthComps = [gregorian components:0xFF fromDate:lastDatePrevMonth];
		
		NSInteger lastDayPrevMonth = [lastDatePrevMonthComps day];

		for (int i=startIndex-1; i>=firstCellIndex; i--)
		{
			MonthlyCellView *cell = [[self subviews] objectAtIndex:i];
			cell.day = lastDayPrevMonth--;
			
			cell.month = (month == 1?12:month-1);
			cell.year = (month == 1?year-1:year);
			cell.gray = YES;
			
			if (cell.day == todayDay && cell.month == todayMonth && cell.year == todayYear)
			{
				cell.isToday = YES;
				todayCellIndex = i;
			}			
			
			cell.selected = NO;
		}
		
	}
	
	if (startIndex + nDays <  firstCellIndex + 42)
	{
		NSInteger day = 1;
		
		for (int i=startIndex+nDays; i<firstCellIndex+42; i++)
		{
			MonthlyCellView *cell = [[self subviews] objectAtIndex:i];
			cell.day = day++;
			
			cell.month = (month == 12?1:month+1);
			cell.year = (month == 12?year+1:year);
			cell.gray = YES;
			
			if (cell.day == todayDay && cell.month == todayMonth && cell.year == todayYear)
			{
				cell.isToday = YES;
				todayCellIndex = i;
			}
			
			cell.selected = NO;
		}
		
	}
	
	MonthlyCellView *cell = [[self subviews] objectAtIndex:firstCellIndex];	

	[firstDateComps setYear:cell.year];
	[firstDateComps setMonth:cell.month];
	[firstDateComps setDay:cell.day];
	
	cell = [[self subviews] objectAtIndex:firstCellIndex + 41];	
	
	[lastDateComps setYear:cell.year];
	[lastDateComps setMonth:cell.month];
	[lastDateComps setDay:cell.day];
	
	[adeView setStartDate:[gregorian dateFromComponents:firstDateComps] endDate:[gregorian dateFromComponents:lastDateComps]];
		
	currentMonth = month;
	currentYear = year;
	
	MonthlyView *parent = (MonthlyView *)[[self superview] superview];
	[parent showMonthTitle:[self getMonthTitle]];
	
	[gregorian release];	
	
	App_Delegate.me.networkActivityIndicatorVisible=NO;	
}
/*
#pragma mark action methods
-(void)goPrev:(id)sender{
	//App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	//printf("go previous month\n");
	if (currentMonth == 1)
	{
		currentMonth = 12;
		currentYear -= 1;
	}
	else
	{
		currentMonth -= 1;
	}
	
	[self showMonth:currentMonth withYear:currentYear withDay:-1];
	
	//App_Delegate.me.networkActivityIndicatorVisible=NO;
}

-(void)goNext:(id)sender{
	//App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	//printf("go next month\n");
	if (currentMonth == 12)
	{
		currentMonth = 1;
		currentYear += 1;
	}	
	else
	{
		currentMonth += 1;
	}
	
	[self showMonth:currentMonth withYear:currentYear withDay:-1];
	
	//App_Delegate.me.networkActivityIndicatorVisible=NO;
}
*/

-(void)setAllocTime:(NSInteger [42]) allocTime  duration:(NSInteger) totalMinutes
{
	//NSInteger firstCellIndex = 10;
	NSInteger firstCellIndex = 0;
	
	UIColor *color = [UIColor blackColor];
	
	for (int i=0; i<42; i++)
	{
		CGFloat ratio = (CGFloat) allocTime[i]/totalMinutes;
		
		if (allocTime[i] == 0)
		{
			ratio = 0;
		}
		
		MonthlyCellView *cell = [[self subviews] objectAtIndex:firstCellIndex+i];
		cell.freeRatio = ratio;
	}
}

- (void)dealloc {
	
	[adeView release];
	
    [super dealloc];
}


@end
