//
//  ScrollableTaskMainView.h
//  IVo
//
//  Created by Left Coast Logic on 6/18/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TaskView;
@class DynamicLine;
@class TaskKey;

@interface SmartTimeView : UIScrollView<UIScrollViewDelegate> {
	BOOL isTaskViewMoving;
	
	NSInteger taskViewMovingIndex;
	
	NSMutableArray *taskViews;
	
	CGFloat totalHeight;
	
	CGRect upScrollArea;
	CGRect downScrollArea;
	
	UIView *scrollTaskView;
	CGFloat scrollUnit;
	
	BOOL isScrolling;
	
	TaskView *selectedTaskView;
	//BOOL isMoved;
	
	NSInteger lastTaskKey;
	CGRect lastTaskRec;
	CGFloat lastPastDueY;
	
	//Nang
	UIAlertView	*overdueMovingAlert;
	UIAlertView	*pastMovingAlert;
	
	NSInteger moveKey;
	NSInteger toKey;
	TaskView *moveTaskView;
	
	NSInteger newKey;
	
	NSMutableArray *taskList;
	NSInteger fastUpdateIndex;
	BOOL isFastUpdating;
	NSTimer *fastUpdateTimer;
	NSMutableArray *tmpTaskViewList;
	TaskView *lastView;
	TaskView *previousLastView;
	
	DynamicLine *dynLine1;
	DynamicLine *dynLine2;
	
	BOOL		isRefreshForMoving;
}

@property CGFloat totalHeight;
@property NSInteger newKey;
@property (nonatomic, retain) NSMutableArray *taskList; 
@property (nonatomic, assign) BOOL		isRefreshForMoving;

- (void)beginMoveTaskView:(TaskView *)taskView;
- (void)endMoveTaskView:(TaskView *)taskView;
- (void)hightlightTaskView: (CGPoint) point;
- (void)unhightlightTaskView;

- (void) updateView:(NSMutableArray *)tasks;
//- (NSMutableArray *) createTaskViewsByTasks:(NSMutableArray *)tasks;
- (TaskView *) findByKey:(NSInteger)key list:(NSMutableArray*)list;
//- (void)layoutTaskViews:(NSArray *)taskViews;
- (void)separate: (TaskView *) taskView;
- (void) unseparate;
- (CGFloat) check2scroll:(NSSet *)touches view:(UIView *) view;
- (void) initData:(NSInteger) key;
- (void)hightlight: (CGRect) rec;
- (void)unhightlight;

//trung ST3.1
//- (void) executeCommand:(NSInteger) comm key:(NSInteger) key;
- (void) executeCommand:(NSInteger) comm key:(NSInteger) key parentKey:(NSInteger) parentKey startTime:(NSDate *) startTime;

- (void) selectTaskView:(TaskView *)taskView;
- (void) unselectTaskView;
- (NSInteger) getSelectedKey;
- (BOOL) checkMoveAtEnd:(CGRect) rec;

//trung ST3.1 
- (NSInteger) getSelectedTaskKey;

- (void) startFastUpdate;
-(void) stopFastUpdate;
-(void) fastUpdate:(id)sender;

- (void) initData: (NSInteger) key;

@end
