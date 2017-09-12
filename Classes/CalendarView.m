//
//  ScrollableCalendarView.m
//  IVo
//
//  Created by Left Coast Logic on 6/18/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import "IvoCommon.h"
#import "CalendarView.h"
#import "ScheduleView.h"

#import "CalendarTaskView.h"
#import "CalendarEventView.h"
#import "ivo_Utilities.h"
#import "TaskManager.h"
#import "SmartViewController.h"
#import "SmartTimeAppDelegate.h"

#import "CalendarPageView.h"
#import "CalendarADE.h"
#import "TaskActionResult.h"
#import "DateAndList.h"

#define TIME_SLOT_HEIGHT 25
#define CALENDAR_VIEW_ALIGNMENT 20
#define CALENDAR_VIEW_PAD 10
#define SUBTASKNO_SIZE 20

#define TIME_LINE_PAD 5

#define LEFT_MARGIN 3

#define DAY_SCROLL_UNIT 60

extern TaskManager *taskmanager;
extern SmartViewController *_smartViewController;
extern SmartTimeAppDelegate *App_Delegate;//nang
extern ivo_Utilities	*ivoUtility;
//extern Setting	*currentSetting;
extern NSTimeZone *App_defaultTimeZone;
extern NSTimeInterval dstOffset;
//extern NSString *movingTaskPassOthersDeadLineAlertText;

@implementation CalendarView
@synthesize moveTime;
@synthesize quickEventStartTime;
@synthesize isInQuickAddMode;
@synthesize scrollDate;

- (id)initWithFrame:(CGRect)frame {
	//ILOG(@"[CalendarView initWithFrame\n")
	if (self = [super initWithFrame:frame]) {
		// Initialization code
		CGRect rec = self.bounds; //ST3.0
		
		previousSchedule = [[ScheduleView alloc] initWithFrame:rec]; //ST3.0
		[self addSubview:previousSchedule];	

		currentSchedule = [[ScheduleView alloc] initWithFrame:CGRectOffset(rec, rec.size.width, 0)]; //ST3.0
		
		[self addSubview:currentSchedule];
				
		nextSchedule = [[ScheduleView alloc] initWithFrame:CGRectOffset(rec, 2*rec.size.width, 0)]; //ST3.0
		[self addSubview:nextSchedule];
		
		currentADEList = [[NSMutableArray alloc] initWithCapacity:3];
		previousADEList = [[NSMutableArray alloc] initWithCapacity:3];
		nextADEList = [[NSMutableArray alloc] initWithCapacity:3];


		taskHasJustMoved = NO;
		
		self.directionalLockEnabled = YES;
		
		currentPage = nil;
		previousPage = nil;
		nextPage = nil;
		self.scrollDate=[NSDate date];
		
		rightScrollArea = CGRectMake(frame.size.width - 30, 0, 30, frame.size.height);
		leftScrollArea = CGRectMake(0, 0, 30, frame.size.height);
		isDayScrolling = NO;
		self.backgroundColor = [UIColor clearColor];
	}
	//ILOG(@"CalendarView initWithFrame]\n")
	return self;
}


- (void) initData: (NSDate *) date
{
	//ILOG(@"[CalendarView initData\n")
	selectedTaskView = nil;

	if (date != nil)
	{
		self.scrollDate=date;
	}else {
		self.scrollDate=[NSDate date];
	}

	[self loadPages:self.scrollDate];
	
	isInQuickAddMode=NO;
	
	//ILOG(@"CalendarView initData]\n")
}

//Nang 3.1.1
- (void) initDataWithInfo: (id) sender
{
	NSTimer *timer=sender;
	
	NSDate *date=[timer userInfo];
	[self initData:date];
}

- (void)layoutTaskViews:(NSArray *)views
{
	//ILOG(@"[CalendarView layoutTaskViews\n")
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];//nang
	unsigned unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit |  NSSecondCalendarUnit;
	
	CGSize timePaneSize = [CalendarView calculateTimePaneSize];
	CGFloat ymargin = TIME_SLOT_HEIGHT/2;

	int startHour = [CalendarView getStartHour];
	int startOffset = (startHour > 0 ? startHour*2*TIME_SLOT_HEIGHT:0);
	
	TaskView *prevView = nil;// bug fix #277 for 1.0.1
	
	//Trung 08101202
	//fix for proper display of stack of 5 min tasks
	NSInteger currentSlotIdx = -1;
	NSInteger stackCount = 0;
	
	for (int i=0; i<views.count;i++)
	{
		CalendarTaskView *curview = [views objectAtIndex:i];
		NSDate *date = curview.startTime;
		NSDateComponents *taskcomps = [gregorian components:unitFlags fromDate:date];
		NSInteger hour = [taskcomps hour];
		NSInteger minute = [taskcomps minute];
		
		NSInteger slotIdx = 2*hour + minute/30;
		
		//Trung 08101202
		//fix for proper display of stack of 5 min tasks		
		if (slotIdx != currentSlotIdx && stackCount >= 2) //there are more than 3 tasks at the previous slot
		{
			CGFloat delta = [MoveArea getHashmarkVisibleWidth];
			
			int count = stackCount - 2;
			
			for (int k=i-3;count-- > 0;k--)
			{
				UIView *behindView = [views objectAtIndex:k];
				
				behindView.frame = CGRectOffset(behindView.frame, -delta*(stackCount-2-count), 0); 
				
				UIView *frontView = [views objectAtIndex:k+1];
				frontView.alpha = 0.8;
			}
		}
		
		CGFloat x = LEFT_MARGIN + timePaneSize.width + TIME_LINE_PAD;
		
		if (!curview.pinched)
		{
			x +=  CALENDAR_VIEW_ALIGNMENT;
		}		
		
		CGFloat y = ymargin + slotIdx * TIME_SLOT_HEIGHT - startOffset + 1;
		
		if (curview.pinched) // bug fix #277 for 1.0.1
		{
			if (minute >= 30)
			{
				minute -= 30;
			}
			
			y += minute*TIME_SLOT_HEIGHT/30;
		}
		
		CGRect frm = curview.frame;
		
		frm.origin.x = x;
		frm.origin.y = y;
		
		frm.origin.x = ceil(frm.origin.x);
		frm.origin.y = ceil(frm.origin.y);
		frm.size.width = floor(frm.size.width);
		frm.size.height = floor(frm.size.height);
		
		curview.frame = frm;
		
		//1.0.1 [NTT Oct1]
		if (prevView != nil && CGRectIntersectsRect(prevView.frame, curview.frame))
		{
			curview.alpha = 0.8;
			
			if (curview.pinched && prevView.pinched)
			{
				curview.frame = CGRectOffset(curview.frame, [MoveArea getHashmarkVisibleWidth], 0);
			}
			else if (!curview.pinched && !prevView.pinched)
			{
				frm = prevView.frame;
				
				if (frm.size.width > 150)
				{
					frm.size.width = floor((frm.size.width - CALENDAR_VIEW_PAD)/2);
				}
				
				prevView.frame = CGRectOffset(frm, frm.size.width + CALENDAR_VIEW_PAD, 0);
				
				frm = curview.frame;
				
				if (frm.size.width > 150)
				{
					frm.size.width = floor((frm.size.width - CALENDAR_VIEW_PAD)/2);
				}
				
				curview.frame = frm;
			}
		}
		
		prevView = curview;		
		
		//Trung 08101202
		//fix for proper display of stack of 5 min tasks
		if (slotIdx != currentSlotIdx)
		{
			currentSlotIdx = slotIdx;
			stackCount = 1;
		}
		else
		{
			stackCount ++;
		}
	} // end for
	
	//Trung 08101202
	//fix for proper display of stack of 5 min tasks		
	if (stackCount >= 2) //there are more than 3 tasks at the same slot at the end of the list
	{
		CGFloat delta = [MoveArea getHashmarkVisibleWidth];
		
		int count = stackCount - 2;
		
		for (int k=views.count-3;count-- > 0;k--)
		{
			UIView *behindView = [views objectAtIndex:k];
			
			behindView.frame = CGRectOffset(behindView.frame, -delta*(stackCount-2-count), 0); 
			
			UIView *frontView = [views objectAtIndex:k+1];
			frontView.alpha = 0.8;
		}
	}
	
	
	[gregorian release];//nang
	
	//ILOG(@"CalendarView layoutTaskViews]\n")
}

- (NSMutableArray *) createTaskViewsByTasks:(NSMutableArray *)tasks:(NSMutableArray *)adeList
{
	//ILOG(@"[CalendarView createTaskViewsByTasks\n")
	NSMutableArray *views = [[NSMutableArray alloc] initWithCapacity: 5];//nang

	for (int i=0; i<tasks.count; i++)
	{
		Task *task = [tasks objectAtIndex:i];
		
		CalendarTaskView *taskView;
		
		if (task.taskPinned)
		{
			if (task.isAllDayEvent)
			{
				CalendarADE *ade = [[CalendarADE alloc] init];
				
				ade.key = task.primaryKey;
				ade.project = task.taskProject;
				ade.name = task.taskName;
				
				//trung ST3.1
				ade.parentKey = task.parentRepeatInstance;
				
				if (task.taskRepeatID > 0)
				{
					ade.startTime = task.taskREStartTime;
				}
				else
				{
					ade.startTime = task.taskStartTime;
				}
				
				[adeList addObject:ade];
				
				[ade release];
				
				continue;
			}
			
			taskView = [[CalendarEventView alloc] initWithTask:task];//nang
		}
		else
		{
			taskView = [[CalendarTaskView alloc] initWithTask:task];//nang
		}

		[taskView initWithFrame:self.frame];
		[views addObject:taskView];
		
		[taskView release];//nang
	}
	
	[self layoutTaskViews:views];
	
	//ILOG(@"CalendarView createTaskViewsByTasks]\n")
	
	return views;
}

- (void) selectTaskView:(TaskView *)taskView
{
	//nang add quicken add feature
	if(isInQuickAddMode) return;
	
	CalendarPageView *parent = (CalendarPageView *)self.superview;
	
	[parent unselectADE];
	
	[super selectTaskView:taskView];
}

- (void)beginMoveTaskView:(TaskView *)taskView
{
	//nang add quicken add feature
	if(isInQuickAddMode) return;
	
	//ILOG(@"[CalendarView beginMoveTaskView\n")
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	[super beginMoveTaskView:taskView];
	
	//ILOG(@"CalendarView beginMoveTaskView]\n")
}

- (void)endMoveTaskView:(TaskView *)taskView
{
	//ILOG(@"[CalendarView endMoveTaskView\n")

	//nang add quicken add feature
	if(isInQuickAddMode) return;
	
	NSDate *time = [self copy_getTimeSlot];
	if(self.moveTime !=nil){
		[self.moveTime release];
	}
	self.moveTime=[time retain];
	
	[self unhightlight];
	
	if (time != nil && [taskView checkTime2Move:time])
	{
		CGPoint offset = self.contentOffset;
		[self unselectTaskView];

		NSInteger key = taskView.key;
		moveKey= taskView.key;
		
		[taskView removeFromSuperview];
		
		TaskActionResult *ret=nil;//=[[TaskActionResult alloc] init];
		ret=[taskmanager moveTaskInCalendar :key toTask:0 expectedStartTime:time isAutoChangeDue:NO];		
		if(ret.errorNo==ERR_TASK_ANOTHER_PASS_DEADLINE){
			overdueMovingAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"movingTaskPassOthersDeadLineAlertText", @"")/*movingTaskPassOthersDeadLineAlertText*/ message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"_cancelText", @"")/*_cancelText*/ otherButtonTitles:nil];
			
			[overdueMovingAlert addButtonWithTitle:NSLocalizedString(@"_yesText", @"")/*_yesText*/];
			[overdueMovingAlert show];
			[overdueMovingAlert release];
			
			[ret release];

			return;
		}else if(ret.errorNo==ERR_TASK_NOT_BE_FIT_BY_RE||ret.errorNo==ERR_RE_MAKE_TASK_NOT_BE_FIT) {
			UIAlertView	*taskNotBeFitByREAlert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"REMakeTaskNotFitText", @"")/*REMakeTaskNotFitText*/  message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"_okText", @"")/*_okText*/ otherButtonTitles:nil];
			
			[taskNotBeFitByREAlert show];
			[taskNotBeFitByREAlert release];
			[ret release];
			return;
		}
		
        if (ret) {
            [ret release];
        }
		
		NSDate *currentDatePage=[self.scrollDate copy];
		[self initData:currentDatePage];
		[currentDatePage release];
		
		[self setContentOffset:CGPointMake(self.frame.size.width, offset.y) animated:NO]; //snap to page 1
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
	
	taskHasJustMoved = YES;
	
	[time release];
	
	scrollTaskView = nil;
	isDayScrolling = NO;
	isScrolling = NO;
	
	App_Delegate.me.networkActivityIndicatorVisible=NO;
	
	//ILOG(@"CalendarView endMoveTaskView]\n")
}

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex{
	//ILOG(@"[CalendarView alertView\n")
	if([alertVw isEqual:overdueMovingAlert] && (buttonIndex==1)){
		[taskmanager moveTaskInCalendar :moveKey toTask:0 expectedStartTime:self.moveTime isAutoChangeDue:YES];
	}
	NSDate *currentDatePage=[self.scrollDate copy];
	[self initData:currentDatePage];
	[currentDatePage release];
	
	isTaskViewMoving = NO;
	taskViewMovingIndex = -1;
	self.scrollEnabled = YES;
	
	taskHasJustMoved = YES;
	
	
	scrollTaskView = nil;
	isDayScrolling = NO;
	isScrolling = NO;
	
	[self setContentOffset:self.contentOffset animated:NO];
}
- (void)hightlight: (CGRect) rec
{
	//ILOG(@"[CalendarView hightlight\n")
	[currentSchedule hightlight:rec];
	//ILOG(@"CalendarView hightlight]\n")	
}

- (void)unhightlight
{
	//ILOG(@"[CalendarView unhightlight\n")
	[currentSchedule unhightlight];
	//ILOG(@"CalendarView unhightlight]\n")	
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	printf("scrollViewDidEndScrollingAnimation\n");
	
	//ILOG(@"[CalendarView scrollViewDidEndScrollingAnimation\n")
	if (isScrolling == YES)
	{
		//ILOG(@"calling super scrollViewDidEndScrollingAnimation ...\n")
		[super scrollViewDidEndScrollingAnimation:scrollView];
		//ILOG(@"calling super scrollViewDidEndScrollingAnimation FINISHED\n")
	}
	else if (isDayScrolling && scrollTaskView != nil)
	{
		//ILOG(@"scrollViewDidEndScrollingAnimation [1]\n")
		scrollTaskView.frame = CGRectOffset(scrollTaskView.frame, scrollUnit, 0);
		//ILOG(@"scrollViewDidEndScrollingAnimation [2]\n")
		
		[self scrollPage];
		
		scrollTaskView = nil;
		isDayScrolling = NO;
		//ILOG(@"scrollViewDidEndScrollingAnimation [3]\n")
	}
	//ILOG(@"CalendarView scrollViewDidEndScrollingAnimation]\n")
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	lastContentOffset = self.contentOffset;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (isDayScrolling)
	{
		return;
	}
	
	CGFloat deltaX = (self.contentOffset.x - lastContentOffset.x)/320;
	CGFloat deltaY = (self.contentOffset.y - lastContentOffset.y)/480;
	
	if (deltaX < 0)
	{
		deltaX *= (-1);
	}

	if (deltaY < 0)
	{
		deltaY *= (-1);
	}
	
	//printf("deltaX = %f, deltaY = %f\n");
	
	if (deltaX > deltaY)
	{
		self.contentOffset = CGPointMake(self.contentOffset.x, lastContentOffset.y);
	}
	else
	{
		self.contentOffset = CGPointMake(lastContentOffset.x, self.contentOffset.y);
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView 
{
	[self scrollPage];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if (!decelerate)
	{
		[self scrollPage];
	}
}

- (void)scrollPage
{	
	//printf("--------------\n");
	//ILOG(@"[CalendarView scrollViewDidEndDecelerating\n")
	
	//nang add quicken add feature
	if(isInQuickAddMode) return;
	
	[self unselectTaskView];
	
	CGFloat pageWidth = self.frame.size.width;
	
    int page = floor((self.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
	//printf("page = %d\n", page);
	//printf("offset = %f\n", self.contentOffset.x);
	
	NSDate *newDate = nil;
	NSMutableArray *list = nil;
	
	CalendarPageView *parent = (CalendarPageView *)[self superview];

	if (page == 0) //scroll left
	{
		[self freePage: nextPage];
		[nextADEList release];
		
		for(TaskView *view in currentPage)
		{
			if (view != scrollTaskView)
			{
				view.frame = CGRectOffset(view.frame, self.frame.size.width, 0);
			}
		}
		
		nextPage = currentPage;
		nextADEList = currentADEList;

		for(TaskView *view in previousPage)
		{
			if (view != scrollTaskView)
			{
				view.frame = CGRectOffset(view.frame, self.frame.size.width, 0);
			}
		}
		
		if (scrollTaskView != nil)
		{
			scrollTaskView.frame = CGRectOffset(scrollTaskView.frame, self.frame.size.width, 0);
		}		
		
		currentPage = previousPage;
		currentADEList = previousADEList;
		
		newDate = [self.scrollDate dateByAddingTimeInterval:-2*24*60*60];
		if([App_defaultTimeZone isDaylightSavingTimeForDate:newDate] && ![App_defaultTimeZone isDaylightSavingTimeForDate:self.scrollDate]){
			newDate=[newDate dateByAddingTimeInterval:-dstOffset];
		}else if(![App_defaultTimeZone isDaylightSavingTimeForDate:newDate] && [App_defaultTimeZone isDaylightSavingTimeForDate:self.scrollDate]){
			newDate=[newDate dateByAddingTimeInterval:dstOffset];
		}
		
		list = [taskmanager getTaskListFromDate:newDate toDate:newDate splitLongTask:YES isUpdateTaskList:YES isSplitADE:YES];	
		
		previousADEList = [[NSMutableArray alloc] initWithCapacity:3];
		
		previousPage = [self createTaskViewsByTasks :list :previousADEList];

		NSDate *dt = [newDate dateByAddingTimeInterval:24*60*60];
		if([App_defaultTimeZone isDaylightSavingTimeForDate:newDate] && ![App_defaultTimeZone isDaylightSavingTimeForDate:dt]){
			dt=[dt dateByAddingTimeInterval:dstOffset];
		}else if(![App_defaultTimeZone isDaylightSavingTimeForDate:newDate] && [App_defaultTimeZone isDaylightSavingTimeForDate:dt]){
			dt=[dt dateByAddingTimeInterval:-dstOffset];
		}

		self.scrollDate=dt;
		
		[self drawIndicator];
		
		
		for(TaskView *view in previousPage)
		{
			[self addSubview:view];
		}
				
		if (isDayScrolling)
		{
			self.contentOffset = CGPointMake(self.contentOffset.x + self.frame.size.width, self.contentOffset.y);
		}

		[parent setADEList:currentADEList];	

	}
	
	if (page == 2) //scroll right
	{
		[self freePage: previousPage];
		[previousADEList release];
		
		for(TaskView *view in currentPage)
		{
			if (view != scrollTaskView)
			{
				view.frame = CGRectOffset(view.frame, -self.frame.size.width, 0);
			}
		}
		
		previousPage = currentPage;
		previousADEList = currentADEList;
		
		for(TaskView *view in nextPage)
		{
			if (view != scrollTaskView)
			{
				view.frame = CGRectOffset(view.frame, -self.frame.size.width, 0);
			}
		}
		
		if (scrollTaskView != nil)
		{
			scrollTaskView.frame = CGRectOffset(scrollTaskView.frame, -self.frame.size.width, 0);
		}
		
		currentPage = nextPage;
		currentADEList = nextADEList;
		
		//dst fix
		newDate = [self.scrollDate dateByAddingTimeInterval:2*24*60*60];
		if([App_defaultTimeZone isDaylightSavingTimeForDate:newDate] && ![App_defaultTimeZone isDaylightSavingTimeForDate:self.scrollDate]){
			newDate=[newDate dateByAddingTimeInterval:-dstOffset];
		}else if(![App_defaultTimeZone isDaylightSavingTimeForDate:newDate] && [App_defaultTimeZone isDaylightSavingTimeForDate:self.scrollDate]){
			newDate=[newDate dateByAddingTimeInterval:dstOffset];
		}
		
		list = [taskmanager getTaskListFromDate:newDate toDate:newDate splitLongTask:YES isUpdateTaskList:YES isSplitADE:YES];
		
		nextADEList = [[NSMutableArray alloc] initWithCapacity:3];
		nextPage = [self createTaskViewsByTasks :list :nextADEList];
		
		NSDate *dt = [newDate dateByAddingTimeInterval:-24*60*60];
		if([App_defaultTimeZone isDaylightSavingTimeForDate:newDate] && ![App_defaultTimeZone isDaylightSavingTimeForDate:dt]){
			dt=[dt dateByAddingTimeInterval:dstOffset];
		}else if(![App_defaultTimeZone isDaylightSavingTimeForDate:newDate] && [App_defaultTimeZone isDaylightSavingTimeForDate:dt]){
			dt=[dt dateByAddingTimeInterval:-dstOffset];
		}

		self.scrollDate=dt;
		
		[self drawIndicator];
		
		for(TaskView *view in nextPage)
		{
			view.frame = CGRectOffset(view.frame, 2*self.frame.size.width, 0);

			[self addSubview:view];
		}
		
		if (isDayScrolling)
		{			
			self.contentOffset = CGPointMake(self.contentOffset.x - self.frame.size.width, self.contentOffset.y);
		}

		[parent setADEList:currentADEList];

	}
		
	if (!isDayScrolling)
	{
		self.contentOffset = CGPointMake(self.frame.size.width, self.contentOffset.y);
	}

	NSString *formattedDateString = [ivoUtility createStringFromDate:self.scrollDate isIncludedTime:NO];

	[_smartViewController.titleView setTitle:formattedDateString forState:UIControlStateNormal]; 
	
	[formattedDateString release];//nang
	//ILOG(@"CalendarView scrollViewDidEndDecelerating]\n")

}

-(void)drawIndicator{
    CGRect frame=[[UIScreen mainScreen] bounds];
    
	//nang 3.3.1 add the indicator for the current time
	if(indicatorImgView && [indicatorImgView superview]){
		[indicatorImgView removeFromSuperview];
		[indicatorImgView release];
		indicatorImgView=nil;
	}
	
	if([[ivoUtility getStringFromShortDate:self.scrollDate] isEqualToString:[ivoUtility getStringFromShortDate:[NSDate date]]]){
		NSDate *crntDate=[NSDate date];
		CGFloat y=(CGFloat)([ivoUtility getHour:crntDate]+(CGFloat)[ivoUtility getMinute:crntDate]/60 )*(CGFloat)currentSchedule.frame.size.height/24;
		indicatorImgView=[[UIImageView alloc] initWithFrame:CGRectMake(35+frame.size.width,y+8,frame.size.width-35, 10)];
		indicatorImgView.image=[UIImage imageNamed:@"indicator.png"];	
		[self addSubview: indicatorImgView];
	}
}

- (NSDate *) copy_getTimeSlot
{
	//ILOG(@"[CalendarView copy_getTimeSlot\n")
	NSDate *timeslot = [currentSchedule getTimeSlot];
	
	if (timeslot == nil)
	{
		//ILOG(@"CalendarView copy_getTimeSlot] return nil\n")
		return nil;
	}
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = 0xFFFF;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:timeslot];
	
	NSDateComponents *scrollDateComps = [gregorian components:unitFlags fromDate:self.scrollDate];
	
	[scrollDateComps setHour:comps.hour];
	[scrollDateComps setMinute:comps.minute];
	[scrollDateComps setSecond:comps.second];

	NSDate *date = [gregorian dateFromComponents:scrollDateComps]; 
	[gregorian release];
	
	//ILOG(@"CalendarView copy_getTimeSlot]\n")
	return [date copy]; 
}

- (void) loadPages:(NSDate *) date
{
	printf("loadPages\n");
	
	//ILOG(@"[CalendarView loadPages\n")
	[self freePage:nil];
	
	NSMutableArray *tmpList = [taskmanager getTaskListFromDate:[self.scrollDate dateByAddingTimeInterval:-24*60*60] toDate:[self.scrollDate dateByAddingTimeInterval:24*60*60] splitLongTask:YES isUpdateTaskList:YES isSplitADE:YES];
	
	NSMutableArray *list = [ivoUtility alloc_filterTasksByDate:tmpList date:self.scrollDate];
	
	if (currentADEList != nil)
	{
		[currentADEList release];
	}
	
	currentADEList = [[NSMutableArray alloc] initWithCapacity:3];
	
	currentPage = [self createTaskViewsByTasks :list :currentADEList];
	
	[list release];
	
	NSDate *yesterday = [self.scrollDate dateByAddingTimeInterval: -24*60*60];
	
	list = [ivoUtility alloc_filterTasksByDate:tmpList date:yesterday];
	
	if (previousADEList != nil)
	{
		[previousADEList release];
	}
	
	previousADEList = [[NSMutableArray alloc] initWithCapacity:3];
	
	previousPage = [self createTaskViewsByTasks :list :previousADEList];
	
	[list release];
	
	NSDate *tomorrow = [self.scrollDate dateByAddingTimeInterval: 24*60*60];
	list = [ivoUtility alloc_filterTasksByDate:tmpList date:tomorrow];
	
	if (nextADEList != nil)
	{
		[nextADEList release];
	}
	
	nextADEList = [[NSMutableArray alloc] initWithCapacity:3];
	
	nextPage = [self createTaskViewsByTasks :list :nextADEList];
	
	[list release];
	
	for(TaskView *view in previousPage)
	{
		[self addSubview:view];
	}
	
	for(TaskView *view in currentPage)
	{
		view.frame = CGRectOffset(view.frame, self.frame.size.width, 0);
		[self addSubview:view];
	}
	
	//nang 3.3.1 add the indicator for the current time
	[self drawIndicator];
	
	for(TaskView *view in nextPage)
	{
		view.frame = CGRectOffset(view.frame, 2*self.frame.size.width, 0);
		[self addSubview:view];
	}
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];//nang
	unsigned unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit |  NSSecondCalendarUnit;	
	
	int startHour = [CalendarView getStartHour];
	CGFloat hours = [[gregorian components:unitFlags fromDate:self.scrollDate] hour] - startHour;

	totalHeight = currentSchedule.frame.size.height;
	
	self.contentSize = CGSizeMake(self.frame.size.width*3, totalHeight + self.frame.size.height/2);
	
	if([[ivoUtility getStringFromShortDate:self.scrollDate] isEqualToString:[ivoUtility getStringFromShortDate:[NSDate date]]] && !self.isInQuickAddMode){
		lastContentOffset = CGPointMake(self.frame.size.width, hours*2*TIME_SLOT_HEIGHT);
	
	}else {
		lastContentOffset = CGPointMake(self.frame.size.width,self.contentOffset.y);
	}

	
	[self setContentOffset:lastContentOffset];	

	NSString *formattedDateString = [ivoUtility createStringFromDate:self.scrollDate isIncludedTime:NO];
	
	[_smartViewController.titleView setTitle:formattedDateString forState:UIControlStateNormal];
	
	[formattedDateString release];//nang
	
	[gregorian release];//nang
	
	CalendarPageView *parent = (CalendarPageView *)[self superview];
	[parent setADEList:currentADEList];
	
	//ILOG(@"CalendarView loadPages]\n")
    
    [previousSchedule layoutSubviews];
    [currentSchedule layoutSubviews];
    [nextSchedule layoutSubviews];
}

- (void)freePage:(NSMutableArray *)page 
{
	//ILOG(@"[CalendarView freePage\n")
	if ((previousPage != nil) && (previousPage == page || page == nil))
	{
		for(UIView *view in previousPage)
		{
			if (view != scrollTaskView)
			{
				[view removeFromSuperview];
			}
		}
		
		[previousPage release];
		previousPage = nil;
	}
	if ((currentPage != nil) && (currentPage == page || page == nil))
	{
		for(UIView *view in currentPage)
		{
			if (view != scrollTaskView)
			{
				[view removeFromSuperview];
			}			
		}
		
		[currentPage release];
		currentPage = nil;
	}
	if ((nextPage != nil) && (nextPage == page || page == nil))
	{
		for(UIView *view in nextPage)
		{
			if (view != scrollTaskView)
			{
				[view removeFromSuperview];
			}			
		}
		
		[nextPage release];
		nextPage = nil;
	}
	//ILOG(@"CalendarView freePage]\n")
}

- (void) changeBackgroundStyle
{
}

- (CGFloat) check2scroll:(NSSet *)touches view:(UIView *) view
{
	//ILOG(@"[CalendarView check2scroll\n")
	if (isDayScrolling)
	{
		//ILOG(@"CalendarView check2scroll] RETURN 0\n")
		return 0;
	}
	
	if ([super check2scroll:touches view:view] == 0 && !isScrolling)
	{
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
		
		BOOL rightScroll = CGRectContainsPoint(rightScrollArea, newTouchPoint);
		BOOL leftScroll = CGRectContainsPoint(leftScrollArea, newTouchPoint);
		
		scrollUnit = 0;
				
		if (rightScroll)
		{			
			scrollUnit = DAY_SCROLL_UNIT;
		}
		
		if (leftScroll)
		{
			NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
			NSDateComponents *todayComps = [gregorian components:unitFlags fromDate:[NSDate date]];
			
			NSDate *today = [gregorian dateFromComponents:todayComps];
			
			NSDateComponents *scrollComps = [gregorian components:unitFlags fromDate:self.scrollDate];
			
			NSDate *scrollDay = [gregorian dateFromComponents:scrollComps];
			
			[gregorian release];
			
			NSComparisonResult result = [scrollDay compare:today];
			if (result == NSOrderedSame)
			{
				CGFloat delta = offset.x - self.frame.size.width;
				
				if (delta >= DAY_SCROLL_UNIT)
				{
					scrollUnit = -DAY_SCROLL_UNIT;
				}
				else if (delta > 0)
				{
					scrollUnit = -delta;
				}
			}
			else if (result == NSOrderedDescending)
			{
				scrollUnit = -DAY_SCROLL_UNIT;
			}
		}

		if (scrollUnit != 0)
		{
			scrollTaskView = view;
			isDayScrolling = YES;
			offset.x += scrollUnit;
			[self setContentOffset:offset animated:YES];
		}		
	}
	//ILOG(@"CalendarView check2scroll]\n")
	return scrollUnit;
}

- (NSInteger) getSelectedKey
{
	CalendarPageView *parent = (CalendarPageView *)[self superview];
	
	NSInteger key = [parent getSelectedKey];
	
	if (key == -1)
	{
		key = [super getSelectedKey];
	}
	
	return key;
}

//trung ST3.1
- (NSInteger) getSelectedTaskKey
{
	CalendarPageView *parent = (CalendarPageView *)[self superview];
	
	NSInteger key = [parent getSelectedTaskKey];
	
	if (key == -1)
	{
		key = [super getSelectedTaskKey];
	}
	
	return key;
}

+ (CGSize) calculateTimePaneSize
{
	//ILOG(@"[CalendarView calculateTimePaneSize\n")
	
	CGFloat fontSize = 12;
	
	UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:fontSize];
	CGSize hourSize = [@"12 " sizeWithFont:font];
	
	font = [UIFont fontWithName:@"Helvetica" size:fontSize-2];
	CGSize amSize = [@"AM" sizeWithFont:font];

	//ILOG(@"CalendarView calculateTimePaneSize]\n")

	return CGSizeMake(hourSize.width + amSize.width, hourSize.height);

}

- (NSDate *)getScrollDate
{
	return scrollDate;
}

+ (int) getStartHour
{
	return 0;
}

+ (int) getEndHour
{
	return 24;
}

- (void)dealloc {
	//ILOG(@"[CalendarView dealloc\n")
	[self freePage:nil];
	
	[previousSchedule release];
	[currentSchedule release];
	[nextSchedule release];
	
	[currentADEList release];
	[previousADEList release];
	[nextADEList release];
	
	[scrollDate release];
	
	[currentPage release];
	[previousPage release];
	[nextPage release];
	
	[moveTime release]; //nang
	
	[super dealloc];
	//ILOG(@"CalendarView dealloc]\n")
}

//Nang: quicken add event
#pragma mark touch handler

// Handles the start of a touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch *touch in touches) {
		
//		if( CGRectContainsPoint([howLong frame], [touch locationInView:howLong])){
//		}		
	}	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	for (UITouch *touch in touches) {
	
	}
}

// Handles the end of a touch event.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(isInQuickAddMode) return;
	
	isInQuickAddMode=YES;
    CGRect frame=[[UIScreen mainScreen] bounds];
    
	//calaculate the specified time
	NSDate *date = self.scrollDate;

	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;//|NSWeekdayCalendarUnit|NSWeekdayOrdinalCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:date];
	
	NSInteger time;
	
    // Enumerates through all touch object
    for (UITouch *touch in touches){
		CGPoint touchPoint=[touch locationInView:currentSchedule];
		time=touchPoint.y*24/currentSchedule.frame.size.height;
		[comps setHour:time];
		[comps setMinute:0];
		[comps setSecond:0];
		
		self.quickEventStartTime=[gregorian dateFromComponents:comps];
		//[gregorian release];
		
		if(time<24){
			
			[self unselectTaskView];
			
			//draw box and load keyboard
			CGFloat y=(CGFloat)time*currentSchedule.frame.size.height/24;
			
			quickEventBoxImg=[[UIImageView alloc] initWithFrame:CGRectMake(40+frame.size.width,y+12, frame.size.width-60, 52)];
			quickEventBoxImg.image=[UIImage imageNamed:@"quickEventBox.png"];
			quickEventBoxImg.alpha=0.5;
			
			[self addSubview:quickEventBoxImg];
			[quickEventBoxImg release];
			
			quickEventTextView=[[UITextView alloc] initWithFrame:CGRectMake(40+frame.size.width,y+15, frame.size.width-70, 50)];
			quickEventTextView.backgroundColor=[UIColor clearColor];
			quickEventTextView.font=[UIFont systemFontOfSize:18];
			quickEventTextView.returnKeyType=UIReturnKeyDone;
			quickEventTextView.delegate=self;
			
			[self addSubview:quickEventTextView];
			
			[quickEventTextView becomeFirstResponder];
			[quickEventTextView release];
			
			CGRect frame=self.frame;
			frame.size.height-=175;
			self.frame=frame;
			
			[self scrollRectToVisible:CGRectMake(40+frame.size.width, y+15, frame.size.width-70, 55) animated:YES];
			self.scrollEnabled=NO;
		}else {
			isInQuickAddMode=NO;
		}

	}
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
	if([text isEqualToString:@"\n"]){
		[quickEventTextView resignFirstResponder];
	}	
	return YES;	
}

- (void)textViewDidEndEditing:(UITextView *)textView{
	if([quickEventTextView.text length]>0){
		TaskActionResult *ret;
		
		Task *newTask=[[Task alloc] init];
		newTask.isNeedAdjustDST=1;
		newTask.taskPinned=1;
		newTask.taskName=textView.text;
		newTask.taskStartTime=self.quickEventStartTime;
		newTask.taskHowLong=3600;
		newTask.taskEndTime=[self.quickEventStartTime dateByAddingTimeInterval:3600];
		
		if(taskmanager.currentSetting.dueWhenMove==0){
			ret=[taskmanager addNewTask:newTask toArray:taskmanager.taskList isAllowChangeDueWhenAdd:YES];
		}else {
			ret=[taskmanager addNewTask:newTask toArray:taskmanager.taskList isAllowChangeDueWhenAdd:NO];
			if(ret.errorNo==ERR_TASK_ANOTHER_PASS_DEADLINE){
				UIAlertView *alertViewAddEventTaskPassedDue = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"quickAddPassDeadlineErrorMgs", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"_okText", @"")/*okText*/ otherButtonTitles:nil];
				[alertViewAddEventTaskPassedDue show];
				[alertViewAddEventTaskPassedDue release];
			}
		}
		
		[newTask release];
		[self initData:self.scrollDate];
	}
	[quickEventTextView removeFromSuperview];
	[quickEventBoxImg removeFromSuperview];
	
	CGRect frame=self.frame;
	frame.size.height+=175;
	self.frame=frame;
	
	isInQuickAddMode=NO;
	self.scrollEnabled=YES;
}

@end
