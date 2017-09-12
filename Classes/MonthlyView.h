//
//  MonthlyView.h
//  SmartTime
//
//  Created by Left Coast Logic on 12/29/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MonthlyTableView;
@class MonthlyCalendarView;
@class MonthlyTitleBackgroundView;

@class WeekViewCalController;

@interface MonthlyView : UIView {
	MonthlyCalendarView *monthView;
	MonthlyTableView *listView;
	MonthlyTitleBackgroundView *bgView;
	
	NSDate *date;
	BOOL isFilter;
	
	//WeekViewCalController *controller;

	UILabel *month;
	UIButton *toWeekButton;
	UILabel *dayLabel;
	UIView *pageView;
	UIImageView *filterModeView;
}

//@property (nonatomic, retain)	WeekViewCalController *controller;
@property (nonatomic, copy) 	NSDate *date; 
@property BOOL isFilter;

//- (void)initCalendarDate:(NSDate *)date;
- (void)setCalendarDate:(NSDate *)date;
- (void)goToDate:(NSDate *)date;
-(void)toWeek;

- (void) resetIvoStyle;

- (void) showMonthTitle: (NSString *) title;
- (void)showWeekTitle:(NSString *)title;
- (void)showDayTitle:(NSString *)title;

- (void)initCalendarDate:(NSDate *)dte;
- (void)setCalendarDate:(NSDate *)dte;
- (void)goToDate:(NSDate *)dte;

@end
