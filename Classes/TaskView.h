//
//  TaskView.h
//  IVo
//
//  Created by Left Coast Logic on 4/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IvoCommon.h"
#import "Task.h"
#import "MoveArea.h"
//#import "BadgeView.h"

@interface TaskView : UIView {
	NSInteger key;
// trung ST3.1
	NSInteger parentKey;
	
	NSDate *startTime;
	NSDate *endTime;
	TaskCategory category;
	TaskTypeEnum type;
	TaskDue due;
	NSString *name;
	TaskDuration duration;
	NSString *location;
	NSInteger defaultValue;
	
	CGFloat progress;
	int subTaskNo;
	BOOL pinched;
	BOOL doToday;
	
//Trung 08101301
	BOOL doTomorrow;

	MoveArea *moveArea;
	
	BOOL isMoving;
	BOOL inMoveMode;
	
	BOOL jiggleRight;
	
	NSInteger taskCompleted;
	
	CGRect pad;
	
	CGRect originFrame;
	CGRect originPad;
	
	BOOL selected;
	
	TaskContext context;

	UIImageView *contextView;
    UIImageView *repeatTaskView;
    
	NSDate *deadline;
	NSInteger dueLeft;
	BOOL inPast;
	
	NSDate *lastTouchTime;
	BOOL checkTouchAndHold;
	CGFloat alphaStore; //1.0.1 [NTT Oct1]
	
	BOOL hasAlert;
	UIImageView *alertView;
	
	BOOL isADE;
	//trung ST3.1
	BOOL isRootRE;
	NSDate *originalStartTime;
    
    BOOL    isRepeatTask;
}

@property NSInteger key;
//trung ST3.1
@property NSInteger parentKey;
@property BOOL isRootRE;

@property TaskCategory category;
@property TaskTypeEnum type;
@property TaskDue due;
@property TaskDuration duration;
@property TaskContext context;
@property NSInteger defaultValue;

@property CGFloat progress;
@property int subTaskNo;
@property BOOL pinched;
@property BOOL doToday;
//Trung 08101301
@property BOOL doTomorrow;

@property CGRect pad;
@property BOOL selected;

@property NSInteger taskCompleted;
@property BOOL jiggleRight;

@property BOOL isMoving;

@property BOOL inPast;
@property BOOL    isRepeatTask;

//@property (nonatomic, copy) NSString *location;
@property (nonatomic, retain) NSString *location;

//@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) NSString *name;

//@property (nonatomic, copy) NSDate *startTime;
@property (nonatomic, retain) NSDate *startTime;

//@property (nonatomic, copy) NSDate *endTime;
@property (nonatomic, retain) NSDate *endTime;

//@property (nonatomic, copy) NSDate *deadline;
@property (nonatomic, retain) NSDate *deadline;

//nang 3.7 
//@property (nonatomic, copy) NSDate *originalStartTime;
@property (nonatomic, retain) NSDate *originalStartTime;

//Trung 08101701
//@property (nonatomic, retain) MoveArea* moveArea;

@property CGRect originFrame;
@property CGRect originPad;

@property BOOL isADE;

- (CGSize) calculateSize;
- (id)initWithTask:(Task *)task;
- (void)beginMoveTaskView;
- (void)endMoveTaskView;
- (void) restoreFrame;
- (BOOL) checkTime2Move:(NSDate *)time;
- (TaskTypeEnum) getTaskType;
- (BOOL) checkDue;
- (BOOL) checkContext;
- (void) drawText:(CGContextRef) ctx;
- (void) drawShape:(CGContextRef) ctx;
- (void) drawOverlay:(CGContextRef) ctx;

@end
