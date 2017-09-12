//
//  ScrollableCalendarView.h
//  IVo
//
//  Created by Left Coast Logic on 6/18/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmartTimeView.h"

@class ScheduleView;

@interface CalendarView : SmartTimeView<UITextViewDelegate> {
	
	ScheduleView *currentSchedule;
	ScheduleView *previousSchedule;
	ScheduleView *nextSchedule;
	
	NSMutableArray *currentADEList;
	NSMutableArray *previousADEList;
	NSMutableArray *nextADEList;
	
	BOOL taskHasJustMoved;
	NSDate *scrollDate;
	
	NSMutableArray *currentPage;
	NSMutableArray *previousPage;
	NSMutableArray *nextPage;

	CGRect rightScrollArea;
	CGRect leftScrollArea;

	BOOL isDayScrolling;
	NSDate *moveTime; //nang
	//UIAlertView	*overDeadlineMovingAlert;
	
	//BOOL isAdjusted;
	
//Trung 08101301
	CGPoint lastContentOffset;
	CGFloat scrollDelta;

//Nang	
	NSDate *quickEventStartTime;
	UIImageView *quickEventBoxImg;
	UITextView *quickEventTextView;
	BOOL		isInQuickAddMode;
	UIImageView *indicatorImgView;
}

@property (nonatomic,retain) NSDate *moveTime;
@property (nonatomic,retain) NSDate *quickEventStartTime;
@property (nonatomic,assign) BOOL		isInQuickAddMode;
@property (nonatomic,retain)	NSDate *scrollDate;

- (void) loadPages:(NSDate *) date;
- (void)hightlight: (CGRect) rec;
- (void)unhightlight;
- (void)freePage:(NSMutableArray *)page;
- (NSDate *) copy_getTimeSlot;
- (void) changeBackgroundStyle;
- (void) initData: (NSDate *) date;
- (NSDate *)getScrollDate;
- (NSMutableArray *) createTaskViewsByTasks:(NSMutableArray *)tasks:(NSMutableArray *)adeList;

+ (CGSize) calculateTimePaneSize;
+ (int) getStartHour;
+ (int) getEndHour;
- (void) initDataWithInfo: (id) sender;
- (void)scrollPage;
-(void)drawIndicator;

@end
