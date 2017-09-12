//
//  ScrollableTaskMainView.m
//  IVo
//
//  Created by Left Coast Logic on 6/18/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SmartTimeView.h"
#import "TaskView.h"
#import "EventView.h"

#import "DynamicLine.h"
#import "TaskManager.h"

#import "ivo_Utilities.h"

#import "SmartViewController.h"
#import "SmartTimeAppDelegate.h"

#import "TaskKey.h"
#import "DeletedTEKeys.h"

#import "TaskActionResult.h"


#define PADDING 5
#define DYNAMIC_LINE_PADDING 8
#define DYNAMIC_LINE_YOFFSET 10
#define SEPARATE_OFFSET 10

#define AUTO_SCROLL_UNIT 60

#define HIGHTLIGHT_ANIMATION_DURATION_SECONDS 0.1 

#define MAX_TASK_TO_APPLY_FAST_UPDATE 60

TaskView *hightlightedTaskView = nil;

TaskView *leftTaskView = nil;
TaskView *rightTaskView = nil;

extern TaskManager *taskmanager;
extern SmartViewController *_smartViewController;
extern SmartTimeAppDelegate *App_Delegate;
//extern Setting *currentSetting;
extern ivo_Utilities *ivoUtility;

//extern NSString *movingTaskPassItsDeadLineAlertText;
//extern NSString *movingTaskPassOthersDeadLineAlertText;
//extern NSString *movingTaskIntoThePast;
//extern NSString *movingTaskPastToPast;

@implementation SmartTimeView

@synthesize totalHeight;
@synthesize newKey;
@synthesize taskList;
@synthesize isRefreshForMoving;

- (id)initWithFrame:(CGRect)frame {
	//ILOG(@"[SmartTimeView initWithFrame\n")
	
	if (self = [super initWithFrame:frame]) {
		
		// Initialization code
		isTaskViewMoving = NO;

		self.totalHeight = 0;
		taskViews = nil;

		upScrollArea = CGRectMake(0, 0, frame.size.width, 30);
		
		downScrollArea = CGRectOffset(upScrollArea, 0, frame.size.height - upScrollArea.size.height);

		self.scrollEnabled = YES;
		self.delegate = self;
		self.scrollsToTop = NO;
		
		self.isRefreshForMoving=NO;
		
		self.showsHorizontalScrollIndicator = YES;
		self.showsVerticalScrollIndicator = YES;
		
		self.directionalLockEnabled = YES;
		
		selectedTaskView = nil;
		lastPastDueY = 0;
		lastTaskRec = CGRectZero;
		
		self.newKey = -1;
		
/*		
		//reset back color
		if(taskmanager.currentSetting.iVoStyleID==0){
			// for aesthetic reasons (the background is black), make the nav bar black for this particular page
			self.backgroundColor=[UIColor colorWithRed:1 green:1 blue:1 alpha:0.9];
		}else{
			self.backgroundColor=[UIColor blackColor];
		}
*/
		self.backgroundColor = [UIColor clearColor];
	}
	//ILOG(@"SmartTimeView initWithFrame]\n")
	
	return self;
}

- (void) initData: (NSInteger) key
{
	//ILOG(@"[SmartTimeView initData\n")
	
	//printf("initData\n");
//	[ivoUtility printTask:taskmanager.taskList];
	
	if (self.subviews.count == 0)
	{
		dynLine1 = [[DynamicLine alloc] initWithFrame:CGRectMake(0, DYNAMIC_LINE_YOFFSET, 320, 2*DYNAMIC_LINE_PADDING)];
		[dynLine1 setTodayDayLine:YES];
		
		[self addSubview:dynLine1];
		
		[dynLine1 release];
		
		dynLine2 = [[DynamicLine alloc] initWithFrame:CGRectMake(0, DYNAMIC_LINE_YOFFSET + 2*DYNAMIC_LINE_PADDING, 320, 2*DYNAMIC_LINE_PADDING)];
		
		[dynLine2 setTodayDayLine:NO];
		
		[self addSubview:dynLine2];
		
		[dynLine2 release];
				
	}else {
		//Nang3.8 ==>add
		[dynLine1 setTodayDayLine:YES];
		[dynLine2 setTodayDayLine:NO];
	}


	self.newKey = key;
	
	self.taskList = [taskmanager getTaskListFromDate:nil toDate:nil splitLongTask:NO isUpdateTaskList:YES  isSplitADE:NO];
	
    printf("\nSmartView list:%lu\n",(unsigned long)self.taskList.count);
	//[ivoUtility printTask:self.taskList];
	
	[self startFastUpdate];

    [dynLine1 layoutSubviews];
    [dynLine2 layoutSubviews];
    
	//ILOG(@"SmartTimeView initData]\n")
}

- (void) resetFastUpdate
{	
	[self stopFastUpdate];

	selectedTaskView = nil;
	
	fastUpdateIndex = 0;
	isFastUpdating = NO;
	lastView = nil;
	previousLastView = nil;
	
	dynLine1.frame = CGRectMake(0, DYNAMIC_LINE_YOFFSET, 320, 2*DYNAMIC_LINE_PADDING);
	dynLine2.frame = CGRectMake(0, DYNAMIC_LINE_YOFFSET + 2*DYNAMIC_LINE_PADDING, 320, 2*DYNAMIC_LINE_PADDING);	
		
	dynLine1.hidden = YES;
	dynLine2.hidden = YES;
}

- (void) startFastUpdate
{
	[self resetFastUpdate];
	
	for (UIView* view in self.subviews)
	{
		if (![view isKindOfClass:[DynamicLine class]])
		{
			[view removeFromSuperview];
		}
	}

	//nang 3.3.1 09101601
//	if (self.taskList.count > MAX_TASK_TO_APPLY_FAST_UPDATE) // gradually draw
    
	if(self.taskList.count > MAX_TASK_TO_APPLY_FAST_UPDATE && !self.isRefreshForMoving)
	{
		fastUpdateTimer = [[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(fastUpdate:) userInfo:nil repeats:YES] retain];
	}
	else // draw all
	{
		for (int i=0; i<self.taskList.count; i++)
		{
			[self fastUpdate:self];
		}
		
		self.taskList = nil;		
	}
}

-(void) stopFastUpdate
{
	if (fastUpdateTimer != nil)
	{
		[fastUpdateTimer invalidate];
		[fastUpdateTimer release];
		fastUpdateTimer = nil;
		
		isFastUpdating = NO;
		fastUpdateIndex = 0;
	}	
}

-(void) fastUpdate:(id)sender
{
	if (isFastUpdating)
	{
		return;
	}
	
	if (sender == nil && tmpTaskViewList == nil)
	{
		return;
	}
	
	if (!self.taskList ||  fastUpdateIndex >= self.taskList.count || fastUpdateIndex < 0)
	{
		[self stopFastUpdate];
		
		return;
	}
	
	isFastUpdating = YES;
	
	CGFloat width = self.bounds.size.width;
	
	CGRect lastFrame = (lastView == nil? CGRectZero:lastView.frame);
	
	//printf("Last Frame x=%f ,y=%f, w=%f, h=%f\n", lastFrame.origin.x, lastFrame.origin.y, lastFrame.size.width, lastFrame.size.height);
	
	Task *task = [self.taskList objectAtIndex:fastUpdateIndex];
    //fastUpdateIndex++;
	
	if (task.taskPinned && [ivoUtility compareDateNoTime:[[NSDate date] dateByAddingTimeInterval:-24*60*60] withDate:task.taskStartTime] != NSOrderedAscending)
	{
		//for better performance, skip Event in past
		isFastUpdating = NO;
		fastUpdateIndex++;
		return;
	}
	
	lastTaskKey = task.primaryKey;
	
	TaskView *taskView;
	
	if (task.taskPinned)
	{
		taskView = [[EventView alloc] initWithTask:task];
	}
	else
	{
		taskView = [[TaskView alloc] initWithTask:task];
	}
	
/*	
	if (task.taskRepeatID > 0)
	{
		taskView.type = TYPE_SMART_RE;
		
		if (task.isOneMoreInstance)
		{
			taskView.type = TYPE_SMART_RE_MORE;
		}
	}
	else if (task.parentRepeatInstance > 0)
	{
		taskView.type = TYPE_SMART_RE_EXC;
	}
*/
	
	[taskView initWithFrame:self.frame];
	
	if (!(taskView.pinched && taskView.inPast))
	{
		if (sender != nil)
		{
			[self addSubview: taskView];
		}
		else
		{
			[tmpTaskViewList addObject:taskView];
		}

		[taskView release];
		
		if (lastView != nil)
		{
			if (taskView.doTomorrow && (lastView.doToday || lastView.inPast))
			{
				lastFrame = dynLine1.frame;
				dynLine1.hidden = NO;
			}
			else if (!taskView.inPast && !taskView.doToday && !taskView.doTomorrow && (lastView.inPast || lastView.doToday || lastView.doTomorrow))
			{
				lastFrame = dynLine2.frame;
				dynLine2.hidden = NO;
				dynLine1.hidden = NO;
			}
		}
		else
		{
			if (taskView.doTomorrow)
			{
				lastFrame = dynLine1.frame;
				dynLine1.hidden = NO;
			} 
			else if (!taskView.inPast && !taskView.doToday)
			{
				lastFrame = dynLine2.frame;
				dynLine2.hidden = NO;
				dynLine1.hidden = NO;
			}
		}
		
		CGRect frm = taskView.frame;
		CGFloat dx = 0;
		
		frm.origin.y = lastFrame.origin.y + lastFrame.size.height;
		
		CGFloat previousLastY = 0;
		
		if (previousLastView != nil)
		{
			previousLastY = previousLastView.frame.origin.y + previousLastView.frame.size.height;
		}
		
		if (frm.origin.y < previousLastY) // if there is any view with badge -> update max Y
		{
			frm.origin.y = previousLastY;
		}
		else
		{
			previousLastY = frm.origin.y;
		}
		
		frm.origin.y += PADDING;
		
		if ([taskView isKindOfClass:[EventView class]])
		{
			dx = (width - frm.size.width)/2;
			frm.origin.x = dx;
		}
		else if (lastFrame.origin.x + lastFrame.size.width > 200) //break to new line
		{
			dx = (width - 2*frm.size.width)/3;
			frm.origin.x = dx;
		}
		else //no break line  
		{
			if (lastFrame.size.width == 0) //no Task before
			{
				dx = (width - 2*frm.size.width)/3;
				
				frm.origin.x = dx;
				frm.origin.y = PADDING;
			}
			else
			{
				dx = (width - frm.size.width - lastFrame.size.width)/3;
				frm.origin.x = 2*dx + lastFrame.size.width;
				frm.origin.y = lastFrame.origin.y;
			}
			
			lastFrame.origin.x = dx;
			
			lastView.frame = lastFrame;
			
			//frm.origin.x = 2*dx + lastFrame.size.width;
			//frm.origin.y = lastFrame.origin.y;
		}	
		
		frm.origin.x = ceil(frm.origin.x);
		frm.origin.y = ceil(frm.origin.y);
		frm.size.width = floor(frm.size.width);
		frm.size.height = floor(frm.size.height);
		
		//printf("%d. Task: %s, x=%f ,y=%f, w=%f, h=%f\n", fastUpdateIndex, [task.taskName UTF8String], frm.origin.x, frm.origin.y, frm.size.width, frm.size.height);
		
		taskView.frame = frm;
		
		CGRect taskPad = frm;
		
		taskPad.origin.x -= dx;
		taskPad.size.width = dx;
		
		taskPad.origin.x = ceil(taskPad.origin.x);
		taskPad.origin.y = ceil(taskPad.origin.y);
		taskPad.size.width = floor(taskPad.size.width);
		taskPad.size.height = floor(taskPad.size.height);
		
		taskView.pad = taskPad;
		
		//printf("Task Pad: %s, x=%f ,y=%f, w=%f, h=%f\n", [task.taskName UTF8String], taskPad.origin.x, taskPad.origin.y, taskPad.size.width, taskPad.size.height);	
		
		lastTaskRec = frm;
		
		if (taskView.doToday || taskView.inPast) //move Dynamic Line 1
		{
			lastFrame = frm;
			
			lastFrame.origin.x = 0;
			lastFrame.origin.y = lastFrame.origin.y + lastFrame.size.height;
			
			if (lastFrame.origin.y < previousLastY)
			{
				lastFrame.origin.y = previousLastY;
			}
			
			lastFrame.origin.y += DYNAMIC_LINE_YOFFSET;
			lastFrame.size.width = width;
			lastFrame.size.height = 2*DYNAMIC_LINE_PADDING; 
			
			dynLine1.frame = lastFrame;
			dynLine1.hidden = NO;
			
			lastFrame.origin.y += lastFrame.size.height;
			dynLine2.frame = lastFrame;
		}		
		else if (taskView.doTomorrow) //move Dynamic Line 2
		{
			lastFrame = frm;
			
			lastFrame.origin.x = 0;
			lastFrame.origin.y = lastFrame.origin.y + lastFrame.size.height;
			
			if (lastFrame.origin.y < previousLastY)
			{
				lastFrame.origin.y = previousLastY;
			}
			
			lastFrame.origin.y += DYNAMIC_LINE_YOFFSET;
			lastFrame.size.width = width;
			lastFrame.size.height = 2*DYNAMIC_LINE_PADDING; 
			
			dynLine2.frame = lastFrame;
			
			dynLine2.hidden = NO;
		}
		
		CGFloat height = frm.origin.y + frm.size.height;
		//printf("height = %f\n", height);
		
		CGFloat contentHeight = (height > self.frame.size.height?height + self.frame.size.height/2:self.frame.size.height + 40); 
		
		self.contentSize = CGSizeMake(self.frame.size.width, contentHeight);
		
		previousLastView = lastView;		
		lastView = taskView;
	}

	if (fastUpdateIndex >= self.taskList.count)
	{
		self.taskList = nil;
	}
    
	fastUpdateIndex++;
    
	isFastUpdating = NO;
	
	//nang 3.3.1 09101601
	self.isRefreshForMoving=NO;
}

- (void) moveEnd
{
	for (UIView *view in self.subviews)
	{
		if ([view isKindOfClass:[TaskView class]])
		{
			[view removeFromSuperview];
		}
	}
	
	for (UIView *view in tmpTaskViewList)
	{
		if ([view isKindOfClass:[TaskView class]])
		{
			[self addSubview:view];  //SmartTimeView keeps view, don't release it
		}
	}
	
	[tmpTaskViewList release]; //after finished animation release the temporary list
	tmpTaskViewList = nil;
}

- (void) updateView:(NSMutableArray *)tasks
{
	//printf("updateView\n");
	
	self.taskList = tasks;
	
	//nang 3.3.1 09101601
//	if (tasks.count > MAX_TASK_TO_APPLY_FAST_UPDATE)
	if(tasks.count > MAX_TASK_TO_APPLY_FAST_UPDATE && !self.isRefreshForMoving)
	{
		[self startFastUpdate];
	}
	else
	{
		tmpTaskViewList = [[NSMutableArray alloc] initWithCapacity:tasks.count];
		
		[tmpTaskViewList addObject:dynLine1];
		[tmpTaskViewList addObject:dynLine2];

		[self resetFastUpdate];
		
		for (int i=0; i<tasks.count; i++)
		{
			[self fastUpdate:nil];
		}
		
		self.taskList = nil;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDelegate: self];
		[UIView setAnimationDidStopSelector:@selector(moveEnd)];
		
		[UIView setAnimationDuration:0.5];
		
		for (UIView *view in self.subviews)
		{
			if ([view isKindOfClass:[TaskView class]])
			{
				TaskView *old_taskView = (TaskView *) view;
				TaskView *new_taskView = [self findByKey:old_taskView.key list:tmpTaskViewList];
				
				if (new_taskView != nil)
				{
					old_taskView.pad = new_taskView.pad;
					
					old_taskView.frame = new_taskView.frame;				
					
					old_taskView.doToday = new_taskView.doToday;
					old_taskView.due = new_taskView.due;
				}
				else
				{
					[old_taskView removeFromSuperview];
				}
				
			}
		}
		
		[UIView commitAnimations];
		
	}
	//ILOG(@"SmartTimeView updateView]\n")
}

- (TaskView *) findByKey:(NSInteger)key list:(NSMutableArray*)list
{
	//ILOG(@"[SmartTimeView findByKey\n")

//Trung 08101301	
//	for (int j=1; j<list.count;j++)
	for (int j=2; j<list.count;j++)
	{
		TaskView *tmp_taskView = [list objectAtIndex:j];
		if (tmp_taskView.key == key)
		{
			//ILOG(@"SmartTimeView findByKey] FOUND\n")
			return tmp_taskView;
		}
	}
	
	//ILOG(@"SmartTimeView findByKey]\n")
	return nil;
}

/*
- (NSMutableArray *) createTaskViewsByTasks:(NSMutableArray *)tasks
{
	//ILOG(@"[SmartTimeView createTaskViewsByTasks\n")
	
	NSMutableArray *views = [[NSMutableArray alloc] initWithCapacity: 5];
	
//Trung 08101301
	DynamicLine *dynLine = [[DynamicLine alloc] initWithFrame:CGRectZero];
	[dynLine setTodayDayLine:YES];

	dynLine.hidden = YES;
	[views addObject:dynLine];
	
	[dynLine release];

//  Trung 08101301
	DynamicLine *dynLine2 = [[DynamicLine alloc] initWithFrame:CGRectZero];
	//	DynamicLine *dynLine2 = [[DynamicLine alloc] init:YES];
							 
	[dynLine2 setTodayDayLine:NO];
	
	dynLine2.hidden = YES;
	[views addObject:dynLine2];
	
	[dynLine2 release];
	
	for (int i=0; i<tasks.count; i++)
	{
		Task *task = [tasks objectAtIndex:i];

		lastTaskKey = task.primaryKey;
		
		TaskView *taskView;
				
		if (task.taskPinned)
		{
			taskView = [[EventView alloc] initWithTask:task];
		}
		else
		{
			taskView = [[TaskView alloc] initWithTask:task];
		}
		
		//[Trung v2.0]
		if (task.taskRepeatID > 0)
		{
			taskView.type = TYPE_SMART_RE;
			
			if (task.isOneMoreInstance)
			{
				taskView.type = TYPE_SMART_RE_MORE;
			}
		}
		else if (task.parentRepeatInstance > 0)
		{
			taskView.type = TYPE_SMART_RE_EXC;
		}
		
		[taskView initWithFrame:self.frame];
		
		//if (!(taskView.pinched && taskView.due == OVERDUE))
		if (!(taskView.pinched && taskView.inPast))
		{
			[views addObject:taskView];
		}
		
		[taskView release];
	}
	
	[self layoutTaskViews:views];
	
	//ILOG(@"SmartTimeView createTaskViewsByTasks]\n")
	return views;
}
*/

- (TaskView *)hitTestRec: (CGRect) rec
{
	//ILOG(@"[SmartTimeView hitTestRec\n")
	
	for (UIView *view in self.subviews)
	{
		if ([view isKindOfClass:[TaskView class]])
		{
			TaskView *taskview = (TaskView *)view;
			
			CGRect testrec = taskview.frame;
			testrec.size.width = testrec.size.width/2;
			
			
			if (!taskview.hidden && !taskview.isMoving && taskview.type!=TYPE_SMART_DYNAMICLINE && CGRectIntersectsRect(testrec, rec))
			{
				//ILOG(@"SmartTimeView hitTestRec] FOUND\n")
				return taskview;
			}
			
		}
	}
	
	//ILOG(@"SmartTimeView hitTestRec]\n")
	
	return nil;
}

- (TaskView *)hitTestPadRec: (CGRect) rec
{
	//ILOG(@"[SmartTimeView hitTestPadRec\n")
	
	CGRect checkRec = CGRectZero;
	
	for (UIView *view in self.subviews)
	{
		if ([view isKindOfClass:[TaskView class]])
		{
			TaskView *taskview = (TaskView *)view;
			
			if (!taskview.hidden && !taskview.isMoving && taskview.type!=TYPE_SMART_DYNAMICLINE)
			{
				if (taskview.frame.origin.x < 50) //left side task
				{
					if (CGRectIntersectsRect(checkRec, rec))
					{
						checkRec = CGRectZero;
						//ILOG(@"SmartTimeView hitTestPadRec] FOUND 1\n")
						return taskview;
					}
					
					checkRec = taskview.pad;
					
					if (CGRectIntersectsRect(checkRec, rec))
					{
						checkRec = CGRectZero;
						//ILOG(@"SmartTimeView hitTestPadRec] FOUND 2\n")
						return taskview;
					}
				}
				else //right side task
				{
					checkRec = taskview.pad;
					
					if (CGRectIntersectsRect(checkRec, rec))
					{
						checkRec = CGRectZero;
						//ILOG(@"SmartTimeView hitTestPadRec] FOUND 3\n")
						return taskview;
					}
				}
				
				checkRec.origin.x = taskview.frame.origin.x + taskview.frame.size.width;
				checkRec.origin.y = taskview.frame.origin.y;
				checkRec.size.width = self.frame.size.width - checkRec.origin.x;
				checkRec.size.height = taskview.frame.size.height;
			}
		}
	}
	
	//ILOG(@"SmartTimeView hitTestPadRec]\n")
	
	return nil;
}

/*
- (TaskView *)hitTestPadRec: (CGRect) rec
{	
	for (UIView *view in self.subviews)
	{
		if ([view isKindOfClass:[TaskView class]])
		{
			TaskView *taskview = (TaskView *)view;
			
			CGRect testrec = taskview.frame;
			testrec.size.width = testrec.size.width/2;
			
			if (!taskview.hidden && !taskview.isMoving && taskview.type!=TYPE_SMART_DYNAMICLINE && CGRectIntersectsRect(taskview.pad, rec))
			{
				return taskview;
			}
		}
	}
	
	return nil;
}
*/

- (NSInteger) getKey2Replace
{
	//ILOG(@"[SmartTimeView getKey2Replace\n")
	
	if (hightlightedTaskView != nil) //move behind hightlight task view
	{
		if (hightlightedTaskView.key == lastTaskKey)
		{
			//ILOG(@"SmartTimeView getKey2Replace] 1 RETURN 0xFFFF\n")
			return 0xFFFF;
		}
		else
		{
			TaskView *foundTaskView = nil;
			
			for (UIView *view in self.subviews)
			{
				if ([view isKindOfClass:[TaskView class]])
				{
					TaskView *taskView = (TaskView *) view;
					if (foundTaskView != nil)
					{
						//ILOG(@"SmartTimeView getKey2Replace]\n")
						return taskView.key;
					}
					else if (taskView.key == hightlightedTaskView.key)
					{
						foundTaskView = taskView;
					}
				}
			}
		}
	}
	else if (rightTaskView != nil) //move in front right task view
	{
		return rightTaskView.key;
	}
	else if (leftTaskView != nil) //move end of list
	{
		//ILOG(@"SmartTimeView getKey2Replace] 2 RETURN 0xFFFF\n")
		return 0xFFFF;
	}
	
	//ILOG(@"SmartTimeView getKey2Replace] RETURN -1\n")
	return -1;
}

- (void)separate: (TaskView *) taskView
{
	//ILOG(@"[SmartTimeView separate\n")
	
	if (rightTaskView != taskView)
	{
		[self unseparate];
		
		rightTaskView = taskView;
		
		NSInteger leftIdx = 0;
		
		NSArray* views = self.subviews;
		
//Trung 08101301		
//		for (int i=1; i<views.count;i++)
		for (int i=2; i<views.count;i++) //skip day line 1 & 2
		{
			TaskView *view = [views objectAtIndex:i];
			if (view == taskView)
			{
				leftIdx = i-1;
				break;
			}
		}
		
		if (leftIdx > 0)
		{
			leftTaskView = [views objectAtIndex:leftIdx];
			
			if (leftTaskView.frame.origin.x > self.frame.size.width/2 || leftTaskView.frame.size.width >= BOX_FULL_WIDE) 
			{
				//if previous task view in on the right side of screen or is a FULL WIDE box, no need to move it
				leftTaskView = nil;
			}
		}
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:HIGHTLIGHT_ANIMATION_DURATION_SECONDS];
		rightTaskView.frame = CGRectOffset(rightTaskView.frame, SEPARATE_OFFSET, 0);
		if (leftTaskView != nil)
		{
			leftTaskView.frame = CGRectOffset(leftTaskView.frame, -SEPARATE_OFFSET, 0);
		}
		[UIView commitAnimations];
		
	}
	//ILOG(@"SmartTimeView separate]\n")
}

- (void) unseparate
{
	//ILOG(@"[SmartTimeView unseparate\n")
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:HIGHTLIGHT_ANIMATION_DURATION_SECONDS];

	if (rightTaskView != nil)
	{
		rightTaskView.frame = CGRectOffset(rightTaskView.frame, -SEPARATE_OFFSET, 0);
	}

	if (leftTaskView != nil)
	{
		leftTaskView.frame = CGRectOffset(leftTaskView.frame, SEPARATE_OFFSET, 0);
	}
		
	[UIView commitAnimations];
	
	rightTaskView = nil;
	leftTaskView = nil;
	
	//ILOG(@"SmartTimeView unseparate]\n")
}

- (void)hightlight: (CGRect) rec
{
	//ILOG(@"[SmartTimeView hightlight\n")
	
	BOOL ret = [self checkMoveAtEnd:rec];
	
	if(ret == YES) //move task to the end of list
	{
		NSInteger lastIndex = self.subviews.count - 2;
		
		if (lastIndex > 0)
		{
			if (hightlightedTaskView != nil) //unhightlight
			{
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:HIGHTLIGHT_ANIMATION_DURATION_SECONDS];
				hightlightedTaskView.transform = CGAffineTransformIdentity;
				[UIView commitAnimations];
				hightlightedTaskView = nil;						
			}
			
			TaskView *lastTaskView = (TaskView *) [self.subviews objectAtIndex:lastIndex];
			
			if (leftTaskView != lastTaskView)
			{
				[self unseparate];
				
				leftTaskView = lastTaskView;
			
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:HIGHTLIGHT_ANIMATION_DURATION_SECONDS];
				leftTaskView.frame = CGRectOffset(leftTaskView.frame, -SEPARATE_OFFSET, 0);
				[UIView commitAnimations];
			}
		}
	}
	else
	{
		CGRect testrec = rec;
		CGRect testrecpad = rec;
		
		testrec.size.width = testrec.size.width/3;
		testrecpad.size.width = 30;	
		
		TaskView *taskView = [self hitTestPadRec:testrecpad];
		if (taskView != nil)
		{		
			if (hightlightedTaskView != nil) //unhightlight
			{
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:HIGHTLIGHT_ANIMATION_DURATION_SECONDS];
				hightlightedTaskView.transform = CGAffineTransformIdentity;
				[UIView commitAnimations];
				hightlightedTaskView = nil;						
			}
			
			[self separate:taskView];
		}
		else 
		{
			[self unseparate];
			
			taskView = [self hitTestRec:testrec];
			
			if (hightlightedTaskView != nil && taskView != hightlightedTaskView) // unhighlight old selection
			{
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:HIGHTLIGHT_ANIMATION_DURATION_SECONDS];
				hightlightedTaskView.transform = CGAffineTransformIdentity;
				[UIView commitAnimations];
				hightlightedTaskView = nil;			
			}
			
			if (taskView != nil && taskView !=hightlightedTaskView) //hightlight new selection
			{
				hightlightedTaskView = taskView;
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:HIGHTLIGHT_ANIMATION_DURATION_SECONDS];
				hightlightedTaskView.transform = CGAffineTransformMakeScale(1.1, 1.1);
				[UIView commitAnimations];
				hightlightedTaskView = taskView;
			}
		}
	}
	
	//ILOG(@"SmartTimeView hightlight]\n")
}

- (void)unhightlight
{
	//ILOG(@"[SmartTimeView unhightlight\n")
	
	[self unseparate];
	
	if (hightlightedTaskView != nil) // unhighlight current selection
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:HIGHTLIGHT_ANIMATION_DURATION_SECONDS];
		hightlightedTaskView.transform = CGAffineTransformIdentity;
		[UIView commitAnimations];
		hightlightedTaskView = nil;			
	}
	
	//ILOG(@"SmartTimeView unhightlight]\n")
}

- (void)hightlightTaskView: (CGPoint) point
{
	//ILOG(@"[SmartTimeView hightlightTaskView\n")
	
	TaskView *taskView = (TaskView *) [self hitTest:point withEvent:nil];
	
	if (hightlightedTaskView != nil && taskView != hightlightedTaskView) // unhighlight old selection
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:HIGHTLIGHT_ANIMATION_DURATION_SECONDS];
		hightlightedTaskView.transform = CGAffineTransformIdentity;
		[UIView commitAnimations];
		hightlightedTaskView = nil;			
	}
	
	if (taskView != nil && taskView !=hightlightedTaskView) //hightlight new selection
	{
		hightlightedTaskView = taskView;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:HIGHTLIGHT_ANIMATION_DURATION_SECONDS];
		hightlightedTaskView.transform = CGAffineTransformMakeScale(1.1, 1.1);
		[UIView commitAnimations];
		hightlightedTaskView = taskView;
	}
	
	//ILOG(@"SmartTimeView hightlightTaskView]\n")
}

- (void)unhightlightTaskView
{
	//ILOG(@"[SmartTimeView unhightlightTaskView\n")
	
	if (hightlightedTaskView != nil) // unhighlight current selection
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:HIGHTLIGHT_ANIMATION_DURATION_SECONDS];
		hightlightedTaskView.transform = CGAffineTransformIdentity;
		[UIView commitAnimations];
		hightlightedTaskView = nil;			
	}
	
	//ILOG(@"SmartTimeView unhightlightTaskView]\n")
}

- (NSInteger)findViewIndex:(TaskView *)taskView
{
	//ILOG(@"[SmartTimeView findViewIndex\n")
	
	NSArray* views = self.subviews;
	for (int i=0; i<views.count;i++)
	{
		UIView *view = [views objectAtIndex:i];
		
		if ([view isKindOfClass:[TaskView class]] && (view == taskView))
		{
			//ILOG(@"SmartTimeView findViewIndex] FOUND\n")
			
			return i;
		}
	}
	
	//ILOG(@"SmartTimeView findViewIndex] NOT FOUND\n")
	return -1;
}

- (BOOL) checkMoveAtEnd:(CGRect) rec
{
	//ILOG(@"[SmartTimeView checkMoveAtEnd\n")
	
	BOOL ret = NO;
	
	if ((rec.origin.y > lastTaskRec.origin.y) && (rec.origin.y < (lastTaskRec.origin.y + lastTaskRec.size.height)))
	{
		if (rec.origin.x > lastTaskRec.origin.x)
		{
			ret = YES;
		}
	}
	else if (rec.origin.y > (lastTaskRec.origin.y + lastTaskRec.size.height))
	{
		ret = YES;
	}
	
	//ILOG(@"SmartTimeView checkMoveAtEnd]\n")
	
	return ret;
}

- (void)beginMoveTaskView:(TaskView *)taskView
{
	//ILOG(@"[SmartTimeView beginMoveTaskView\n")
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	self.isRefreshForMoving=YES;
	isTaskViewMoving = YES;
	
	self.scrollEnabled = NO;
	taskViewMovingIndex = [self findViewIndex:taskView];
	
	[self bringSubviewToFront:taskView];
	
	[self selectTaskView:taskView];
	
	//ILOG(@"SmartTimeView beginMoveTaskView]\n")
}

- (void)endMoveTaskView:(TaskView *)taskView
{
	//ILOG(@"[SmartTimeView endMoveTaskView\n")
	
//	[App_Delegate showAcitivityIndicatorThread];//nang
	
	NSInteger key = taskView.key;	
	NSInteger key2replace =  [self getKey2Replace];

	[self unhightlight];
	
	if (key2replace != -1)
	{
		CGPoint offset = self.contentOffset;
		
		if (key2replace == 0xFFFF) // move to end of list
		{
			key2replace = -1;
		}

		[self unselectTaskView];
		
		moveKey = key;
		toKey = key2replace;
		moveTaskView = taskView;
		
		BOOL restoreTask = NO;

		//taskCheckResult ret=[taskmanager moveTask:key toTask:key2replace isAutoChangeDue:NO];
		TaskActionResult *ret=[taskmanager moveTask:key toTask:key2replace isAutoChangeDue:NO];
		
		if(ret.errorNo==ERR_TASK_ITSELF_PASS_DEADLINE){
			//overdueMovingAlert = [[UIAlertView alloc] initWithTitle:@"Moving this task will bump it past its deadline. Change deadline?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
			overdueMovingAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"movingTaskPassItsDeadLineAlertText", @"")/*movingTaskPassItsDeadLineAlertText*/ message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"_cancelText", @"")/*_cancelText*/ otherButtonTitles:nil];
			[overdueMovingAlert addButtonWithTitle:NSLocalizedString(@"_autoText", @"")/*_autoText*/];
			[overdueMovingAlert addButtonWithTitle:NSLocalizedString(@"_manualText", @"")/*_manualText*/];
			[overdueMovingAlert show];
			[overdueMovingAlert release];
			
			//return;
			
		}else if(ret.errorNo==ERR_TASK_ANOTHER_PASS_DEADLINE){//moving task make some onter tasks over due
			//overdueMovingAlert = [[UIAlertView alloc] initWithTitle:@"This will cause some existing tasks to pass their deadlines. Change those deadlines automatically?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
			overdueMovingAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"movingTaskPassOthersDeadLineAlertText", @"")/*movingTaskPassOthersDeadLineAlertText*/ message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"_cancelText", @"")/*_cancelText*/ otherButtonTitles:nil];
			
			[overdueMovingAlert addButtonWithTitle:NSLocalizedString(@"_yesText", @"")/*_yesText*/];
			[overdueMovingAlert show];
			[overdueMovingAlert release];
			
			//return;
		}else if(ret.errorNo==ERR_TASK_MOVE_TO_PAST){
			//pastMovingAlert = [[UIAlertView alloc] initWithTitle:@"Sorry, you can't move a task into the past." message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			pastMovingAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"movingTaskPastToPast", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"_okText", @"")/*_okText*/ otherButtonTitles:nil];

			[pastMovingAlert show];
			[pastMovingAlert release];
			
			restoreTask = YES;
			
		}else if(ret.errorNo==ERR_TASK_MOVE_PAST_TO_PAST){
			pastMovingAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"movingTaskPastToPast", @"")/*movingTaskPastToPast*/ message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"_okText", @"")/*_okText*/ otherButtonTitles:nil];
			[pastMovingAlert show];
			[pastMovingAlert release];
			
			restoreTask = YES;
		}else if(ret.errorNo==ERR_TASK_NOT_BE_FIT_BY_RE) {
			UIAlertView	*taskNotBeFitByREAlert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"taskNotBeFitByREText", @"")/*taskNotBeFitByREText*/  message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"_okText", @"")/*_okText*/ otherButtonTitles:nil];
			
			[taskNotBeFitByREAlert show];
			[taskNotBeFitByREAlert release];
			
			restoreTask = YES;
			//return;
		}
		else
		{
			//trung ST3.1
			NSMutableArray *updateTaskList = [taskmanager getTaskListFromDate:nil toDate:nil splitLongTask:NO isUpdateTaskList:YES  isSplitADE:NO];
			[self updateView:updateTaskList];
		}
		
		[ret release];
		
		if (restoreTask)
		{
			[taskView retain];
			[taskView removeFromSuperview];
			
			[taskView restoreFrame];
			[self insertSubview:taskView atIndex:taskViewMovingIndex]; // no action on moving task view, restore it location in task main view
			[taskView release];			
		}
		
		[self setContentOffset:offset];
	}
	else
	{
		[taskView retain];
		[taskView removeFromSuperview];
		
		[taskView restoreFrame];
		[self insertSubview:taskView atIndex:taskViewMovingIndex]; // no action on moving task view, restore it location in task main view
		[taskView release];
	}

	isTaskViewMoving = NO;	
	taskViewMovingIndex = -1;
	
	self.scrollEnabled = YES;
	
	App_Delegate.me.networkActivityIndicatorVisible=NO;
	
//	[App_Delegate stopAcitivityIndicatorThread];

	//ILOG(@"SmartTimeView endMoveTaskView]\n")
}


- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex{
	//ILOG(@"[SmartTimeView alertView\n")
//	[App_Delegate showAcitivityIndicatorThread];
	
	if([alertVw isEqual:overdueMovingAlert]){
		if(buttonIndex==1){
			[taskmanager moveTask:moveKey toTask:toKey isAutoChangeDue:YES];
			
		}else if(buttonIndex==2){
			[_smartViewController editTask:moveKey];
 		}		
	}else if ([alertVw isEqual:overdueMovingAlert]) {
		if(buttonIndex==1){
			[taskmanager moveTask:moveKey toTask:toKey isAutoChangeDue:YES];
		}
	}

	NSMutableArray *updateTaskList = [taskmanager getTaskListFromDate:nil toDate:nil splitLongTask:NO isUpdateTaskList:YES  isSplitADE:NO];
	
	[self updateView:updateTaskList];
	
	[self setContentOffset:self.contentOffset];
	
//	[App_Delegate stopAcitivityIndicatorThread];

	//ILOG(@"SmartTimeView alertView]\n")
}

/*
- (void)layoutTaskViews:(NSArray *)views
{
	//ILOG(@"[SmartTimeView layoutTaskViews\n")
	
	CGRect contentRect = self.bounds;
	
	CGFloat x = contentRect.size.width; // set x to big value to trigger breaking in new line 
	
	CGFloat y = 0;
	
	CGFloat w = contentRect.size.width;
	
	self.totalHeight = 0;	
	
	CGFloat dy = 0;
	CGFloat dx = 0;
	CGRect frame;
	
	CGPoint dynamicLineStart;
	dynamicLineStart.x = 0;
	dynamicLineStart.y = 0;

//Trung 08101301
	CGPoint dynamicLine2Start;
	dynamicLine2Start.x = 0;
	dynamicLine2Start.y = 0;
	
	BOOL reachDynamicLine = NO;
//Trung 08101301
	BOOL reachDynamicLine2 = NO;	
	
	BOOL isPastDue = YES;
	
	DynamicLine *dynLine = [views objectAtIndex:0];
	dynLine.hidden = YES;

//Trung 08101301
	DynamicLine *dynLine2 = [views objectAtIndex:1];
	dynLine2.hidden = YES;

	lastPastDueY = 0;
	CGFloat newTaskY = 0;

//Trung 08101301	
//	for (int i=1; i<views.count;i++)
	for (int i=2; i<views.count;i++) //skip day line 1 & 2
	{
		CGRect taskPad = CGRectZero;
		
		TaskView *curview = [views objectAtIndex:i];
				
		frame = curview.bounds;
		
		if (!reachDynamicLine)
		{
			if (!curview.doToday && curview.type!=TYPE_SMART_GROUP)
			{
				reachDynamicLine = YES;
				
				//y += 2*DYNAMIC_LINE_PADDING;
				y += 2*DYNAMIC_LINE_PADDING + DYNAMIC_LINE_YOFFSET;
				
				dynamicLineStart.x = 0;
				dynamicLineStart.y = y + dy - DYNAMIC_LINE_PADDING;
				
				x = contentRect.size.width; // set x to big value to trigger breaking in new line					
				
				y = y - PADDING;
				
				//if (i == views.count -1 && !curview.doTomorrow) //last task's smart time is beyond tomorrow
				if (!curview.doTomorrow) //last task's smart time is beyond tomorrow
				{
					reachDynamicLine2 = YES;

					y += 2*DYNAMIC_LINE_PADDING + DYNAMIC_LINE_YOFFSET;
					
					dynamicLine2Start.x = 0;
					dynamicLine2Start.y = y + dy - DYNAMIC_LINE_PADDING;
					
					x = contentRect.size.width; // set x to big value to trigger breaking in new line					
					
					y = y - PADDING;
					
				}
			}
		}
		
//Trung 08101301		
		else if (!reachDynamicLine2)
		{
			if (!curview.doTomorrow && curview.type!=TYPE_SMART_GROUP)
			{
				reachDynamicLine2 = YES;
				
				//y += 2*DYNAMIC_LINE_PADDING;
				y += 2*DYNAMIC_LINE_PADDING + DYNAMIC_LINE_YOFFSET;
				
				dynamicLine2Start.x = 0;
				dynamicLine2Start.y = y + dy - DYNAMIC_LINE_PADDING;
				
				x = contentRect.size.width; // set x to big value to trigger breaking in new line					
				
				y = y - PADDING;
			}
		}
		
		
		if (isPastDue)
		{
			if (curview.due != OVERDUE)
			{
				isPastDue = NO;
				
				x = contentRect.size.width; // set x to big value to trigger breaking in new line					
			}
		}
		
		TaskView *nextview = nil;
		
		if (i<views.count - 1)
		{
			nextview = [views objectAtIndex:i+1];
		}
		
		CGFloat curw = frame.size.width;
		CGFloat nextw = (nextview == nil? 0: nextview.bounds.size.width);
		
		if (x > 2*w/3) // on new line -> re-calculate dx 
		{
			if (curw + nextw > w) // at least 1 full-wide box 
			{
				// for initial screen, the task "Touch and hold ..." is FULL WIDE (task id: -10003)	
				if (curview.pinched || curview.taskCompleted == -10003)
				{
					dx = (w - curw)/2;
				}
				else
				{
					dx = (w -2*curw)/3;
				}
			}
			else // 2 half-wide boxes or 1 half-wide box
			{
				if (nextw == 0) // no next task
				{
					if (curw > w/2) // full wide box
					{
						dx = (w -curw)/2;
					}
					else // half-wide box
					{
						dx =  (w - 2*curw)/3;
					}
				}
				else // 2 half-wide boxes
				{
					dx =  (w - (curw + nextw))/3;
				}
			}
			
			x = dx;
			y += dy + PADDING; 
			dy = 0;
		}
		else
		{
			x += dx;
			// for initial screen, the task "Touch and hold ..." is FULL WIDE (task id: -10003)	
			if (curview.pinched || curview.taskCompleted == -10003) // need to break on new line
			{
				dx = (w - curw)/2;
				x = dx;
				y += dy + PADDING; 
				dy = 0;
			}
		}
		
		CGPoint point;
		point.x = x;
		
		CGFloat ddy = 0;
		if (dy > frame.size.height)
		{
			ddy = (dy - frame.size.height)/2;
		}
		 
		point.y = y + ddy;
		
		frame.origin = point;
		
		frame.origin.x = ceil(frame.origin.x);
		frame.origin.y = ceil(frame.origin.y);
		frame.size.width = floor(frame.size.width);
		frame.size.height = floor(frame.size.height);
		
		curview.frame = frame;
		
		taskPad = frame;

		taskPad.origin.x -= dx;
		taskPad.size.width = dx;

		taskPad.origin.x = ceil(taskPad.origin.x);
		taskPad.origin.y = ceil(taskPad.origin.y);
		taskPad.size.width = floor(taskPad.size.width);
		taskPad.size.height = floor(taskPad.size.height);
		
		curview.pad = taskPad;
		
		x += frame.size.width;
		
		if (frame.size.height > dy)
		{
			dy = frame.size.height; 
		}
		
		if (curview.due == OVERDUE)
		{
			CGFloat maxY = curview.frame.origin.y + curview.frame.size.height;
			lastPastDueY = (maxY > lastPastDueY? maxY:lastPastDueY);
		}
		
		if (self.newKey != -1)
		{
			if (curview.key == self.newKey)
			{
				newTaskY = curview.frame.origin.y;
				self.newKey = -1;
			}
		}
		
	}
	self.totalHeight = y + dy;
	
	frame = self.frame;

//Trung 08101301
	if (reachDynamicLine)
	{
		frame.origin = dynamicLineStart;
		frame.origin.y -= DYNAMIC_LINE_PADDING;
		frame.size.height = 2*DYNAMIC_LINE_PADDING;
		
		dynLine.frame = frame;
		dynLine.hidden = NO;
		
		if (reachDynamicLine2)
		{
			frame.origin = dynamicLine2Start;
			frame.origin.y -= DYNAMIC_LINE_PADDING;
			frame.size.height = 2*DYNAMIC_LINE_PADDING;
			dynLine2.frame = frame;
			dynLine2.hidden = NO;		
		}
		else if (self.totalHeight > 0)
		{
			frame.origin = dynamicLine2Start;
			frame.origin.y = DYNAMIC_LINE_YOFFSET + self.totalHeight;
			frame.size.height = 2*DYNAMIC_LINE_PADDING;
			dynLine2.frame = frame;
			dynLine2.hidden = NO;			
		}		
		
	}
	else if (self.totalHeight > 0)
	{
		frame.origin = dynamicLineStart;
		frame.origin.y = DYNAMIC_LINE_YOFFSET + self.totalHeight;
		frame.size.height = 2*DYNAMIC_LINE_PADDING;
		dynLine.frame = frame;
		dynLine.hidden = NO;			
	}	

	CGFloat contentHeight = (self.totalHeight > self.frame.size.height?self.totalHeight + self.frame.size.height/2:self.frame.size.height + 40); 
	self.contentSize = CGSizeMake(self.frame.size.width, contentHeight);
	
	if (newTaskY > self.bounds.size.height - 40)
	{
		[self setContentOffset:CGPointMake(0, newTaskY - self.bounds.size.height + 40)];
	}
	
	//ILOG(@"SmartTimeView layoutTaskViews]\n")
}
*/

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	//ILOG(@"[SmartTimeView scrollViewDidEndScrollingAnimation\n")
	
	if (isScrolling && scrollTaskView != nil)
	{
		scrollTaskView.frame = CGRectOffset(scrollTaskView.frame, 0, -scrollUnit);
		scrollTaskView = nil;
	}
	
	isScrolling = NO;
	
	//ILOG(@"SmartTimeView scrollViewDidEndScrollingAnimation]\n")
}

- (CGFloat) check2scroll:(NSSet *)touches view:(UIView *) view
{
	//ILOG(@"[SmartTimeView check2scroll\n")
	
	if (isScrolling)
	{
		//ILOG(@"SmartTimeView check2scroll] RETURN 0\n")
		return 0;
	}
	
	scrollUnit = 0;
	
	BOOL scroll = NO;
	
	CGPoint offset = self.contentOffset;
	
	CGPoint newTouchPoint;
	CGPoint prevTouchPoint;
	
	for (UITouch* touch in touches)
	{
		newTouchPoint = [touch locationInView:self];
		prevTouchPoint = [touch previousLocationInView:self];
	}
	
	newTouchPoint.x -= offset.x;
	newTouchPoint.y -= offset.y;
	
	BOOL upScroll = CGRectContainsPoint(upScrollArea, newTouchPoint);
	BOOL downScroll = CGRectContainsPoint(downScrollArea, newTouchPoint);
	
	if (upScroll)
	{
		if (offset.y > 0)
		{
			if (offset.y > AUTO_SCROLL_UNIT)
			{
				scrollUnit = AUTO_SCROLL_UNIT;
			}
			else
			{
				scrollUnit = offset.y;
			}
			
			scroll = YES;
		}		
	}
	
	if (downScroll)
	{
		CGFloat delta = self.contentSize.height -self.frame.size.height - offset.y;
		
		if (delta > 0)
		{
			if (delta > AUTO_SCROLL_UNIT)
			{
				scrollUnit = -AUTO_SCROLL_UNIT;
			}
			else
			{
				scrollUnit = -delta;
			}
			
			scroll = YES;
		}		
	}
	
	if (scroll)
	{
		scrollTaskView = view;
		isScrolling = YES;
		offset.y -= scrollUnit;
		[self setContentOffset:offset animated:YES];
	}
	
	//ILOG(@"SmartTimeView check2scroll]\n")
	return scrollUnit;
}

//trung ST3.1
//- (void) executeCommand:(NSInteger) comm key:(NSInteger) key
- (void) executeCommand:(NSInteger) comm key:(NSInteger) key parentKey:(NSInteger) parentKey startTime:(NSDate *) startTime
{
	//ILOG(@"[SmartTimeView executeCommand\n")
	
	switch (comm) {
		case CREATE_TASK:
			break;
		case VIEW_TASK:
			//printf("selected key: %d, parent key: %d edit key: %d\n", selectedTaskView.key, selectedTaskView.parentKey, key);

//nang 3.3.1			
//			//trung ST3.1
//			[ivoUtility fillREInstanceToList:taskmanager.taskList dummykey:key parentKey:parentKey startTime:startTime];
			
			[self unselectTaskView];
			[_smartViewController editTask:key];
			break;
	}
	
	//ILOG(@"SmartTimeView executeCommand]\n")

}

- (void) selectTaskView:(TaskView *)taskView
{
	//ILOG(@"[SmartTimeView selectTaskView\n")

	if (selectedTaskView != nil)
	{
		if (selectedTaskView == taskView)
		{
			[self unselectTaskView];
			
			return;
		}
		
		selectedTaskView.selected = NO;				
	}
	
	selectedTaskView = taskView;
	selectedTaskView.selected = YES;
	
	[_smartViewController resetQuickEditMode:NO taskKey:selectedTaskView.key];
	
	//ILOG(@"SmartTimeView selectTaskView]\n")
}

- (void) unselectTaskView
{
	//ILOG(@"[SmartTimeView unselectTaskView\n")
	
	if (selectedTaskView != nil)
	{
		selectedTaskView.selected = NO;
		
		[_smartViewController resetQuickEditMode:YES taskKey:selectedTaskView.key];
		
		selectedTaskView = nil;		
	}
	
	//ILOG(@"SmartTimeView unselectTaskView]\n")
}

- (NSInteger) getSelectedKey
{
	//ILOG(@"[SmartTimeView getSelectedKey\n")
	
	if (selectedTaskView != nil)
	{
		//ILOG(@"SmartTimeView getSelectedKey]\n")
		return selectedTaskView.key;
	}
	
	//ILOG(@"SmartTimeView getSelectedKey] RETURN -1\n")
	return -1;
}

//trung ST3.1 
- (NSInteger) getSelectedTaskKey
{
	if (selectedTaskView != nil)
	{		
		NSInteger key = selectedTaskView.key;
//		NSInteger parentKey = selectedTaskView.parentKey;
//		BOOL isRootRE = selectedTaskView.isRootRE;
		//NSDate *startTime = selectedTaskView.startTime;
//		NSDate *startTime = selectedTaskView.originalStartTime;
		
/* nang 3.3.1
 if (key < -1 || isRootRE)
		{
			[ivoUtility fillREInstanceToList:taskmanager.taskList dummykey:key parentKey:parentKey startTime:startTime];
		}
		
*/		
		return key;
	}

	return -1;
}

- (void)dealloc
{
	//[overdueMovingAlert release];
	//[pastMovingAlert release];
	//[scrollTaskView release];
	
	[super dealloc];
}


@end
