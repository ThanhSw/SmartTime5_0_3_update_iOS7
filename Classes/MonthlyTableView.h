//
//  MonthlyTableView.h
//  SmartTime
//
//  Created by Left Coast Logic on 2/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MonthlyDayTimeFinder;

@interface MonthlyTableView : UIView<UITableViewDelegate,UITableViewDataSource> {
	NSMutableArray *taskList;
	
	UITableView *listView;
	//UIButton *toWeekButton;
	//UILabel *dayLabel;
	
	NSDate *calendarDate;
	
	MonthlyDayTimeFinder *tfView;
}

- (void)setCalendarDate:(NSDate *)date isFilter:(BOOL)isFilter;
- (void)setWeekTitle:(NSString *)title;
- (void)setDayTitle:(NSString *)title;

@end
