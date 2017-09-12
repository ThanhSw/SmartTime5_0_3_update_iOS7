//
//  MonthlyCalendarView.h
//  SmartTime
//
//  Created by Left Coast Logic on 12/31/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MonthlyADEView;

@interface MonthlyCalendarView : UIView {
	
	NSInteger selectedCellIndex;
	NSInteger todayCellIndex;
	
	NSInteger currentMonth;
	NSInteger currentYear;
	
	MonthlyADEView *adeView;
}

-(void)showMonth:(NSInteger)month withYear:(NSInteger)year withDay:(NSInteger)day;
-(void)selectCell:(NSInteger)cellIndex;
-(void)selectDate:(NSDate *)date;
-(void)setAllocTime:(NSInteger [42]) allocTime  duration:(NSInteger) totalMinutes;

- (void) showPreviousMonth;

@end
