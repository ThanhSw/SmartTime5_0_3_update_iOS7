//
//  CalendarPageView.h
//  SmartTime
//
//  Created by Left Coast Logic on 2/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CalendarADEView;
@class CalendarView;

@interface CalendarPageView : UIView {
	CalendarADEView *adeView;
	CalendarView *calendarView;
}

- (NSInteger) getSelectedKey;
- (void) unselectADE;

//trung ST3.1
- (NSInteger) getSelectedTaskKey;
- (NSDate *) getDisplayDate;
- (void) setADEList: (NSMutableArray *)list;
@end
