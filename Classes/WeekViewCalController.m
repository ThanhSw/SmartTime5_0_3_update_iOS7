//
//  WeekViewCalController.m
//  SmartTime
//
//  Created by Nang Le on 2/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WeekViewCalController.h"
#import "TableCellFocus.h"
#import "Task.h"
#import "WeekViewTableCell.h"
#import "SmartStartView.h"
#import "ivo_Utilities.h"
#import "SmartTimeAppDelegate.h"
#import "TaskManager.h"
#import "Colors.h"
#import "CGRectObj.h"
#import "QuartzCore/QuartzCore.h"
#import "Projects.h"
#import "SmartViewController.h"
#import "WeekViewADE.h"
#import "MonthlyView.h"
#import "WeeklyViewSkin.h"
#import "WeekViewTimeFinder.h"
#import "TaskActionResult.h"

#define kTransitionDuration	0.35
#define kAnimationKey @"transitionViewAnimation"

extern NSMutableArray	*projectList;
extern ivo_Utilities	*ivoUtility;
extern TaskManager		*taskmanager;
extern SmartTimeAppDelegate	*App_Delegate;

extern BOOL _startDayAsMonday;
extern NSString* _dayNamesMon[7];
extern NSString* _dayNamesSun[7];
extern NSString* _monthNames[12];
//extern NSString *actionMakesItsPassDeadLineText;
extern NSString *actionMakesOthersPassDeadlinesText;

@implementation WeekViewCalController
@synthesize containerView,topToolbar,toolbarTitle,sunList,monList,tueList,wedList,thuList,friList,satList,
			currentDisplayDate,firstDateInWeek,lastDateInWeek,adeList,
			sunMonthDay,monMonthDay,tueMonthDay,wedMonthDay,thuMonthDay,friMonthDay,satMonthDay,monthName,
			monday,tueday,wednesday,thusday,friday,newTask,SmartViewController,isBackFromMonthView;
@synthesize optSubView;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (id) init
{
	if (self = [super init])
	{
        CGRect frame=[[UIScreen mainScreen] bounds];
        cellWidth=frame.size.height/7;
        
		contentView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.height, frame.size.height)];
		contentView.backgroundColor=[UIColor blackColor];
		
		if(taskmanager.currentSetting.iVoStyleID==0){
			contentView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
		}else {
			contentView.backgroundColor = [UIColor blackColor]; 
		}
		
		self.sunMonthDay = 1;
		self.monMonthDay = 2;
		self.tueMonthDay = 3;
		self.wedMonthDay = 4;
		self.thuMonthDay = 5;
		self.friMonthDay = 6;
		self.satMonthDay = 7;
		
		self.monthName=[ivoUtility createMonthName:[NSDate date]];
		
		NSTimer *initWeekViewTimer=[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(initWeekView) userInfo:nil repeats:NO];
		
		//[self initWeekView];
		
		self.containerView=contentView;
		self.view=self.containerView;	
	}
	return self;
}

- (void)loadView {
	
/*	UILabel *contentInfo=[[UILabel alloc] initWithFrame:CGRectMake(10, 120, 460, 30)];
	contentInfo.backgroundColor=[UIColor clearColor];
	contentInfo.textAlignment=NSTextAlignmentCenter;
	contentInfo.text=loadingText;
	
	[contentView addSubview:contentInfo];
	[contentInfo release];
*/		
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
//- (void)viewDidLoad {
//    [super viewDidLoad];
	
//}

#pragma mark ViewControllerDelegate
-(void)viewWillAppear:(BOOL)animated{
	isFilter=NO;
	isBackFromMonthView=NO;
}

-(void)viewWillDisappear:(BOOL)animated{
	//self.navigationController.navigationBarHidden=NO;
//	taskmanager.filterClause=nil;
//	[taskmanager getDisplayList:nil];
}

- (void) startWeekView
{
	self.currentDisplayDate=[NSDate date];
	[self refreshTableViews];
}

- (void) initWeekView
{
    CGRect frame=[[UIScreen mainScreen] bounds];
    
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	selectedWD=-1;
	
	//self.currentDisplayDate=[NSDate date];
	//[self setupDisplayList:self.currentDisplayDate];

	topToolbar = [UIToolbar new];
	topToolbar.barStyle = UIBarStyleDefault;
	[topToolbar sizeToFit];
	[topToolbar setFrame:CGRectMake(0,0,frame.size.height,WEEKVIEW_TITLE_HEIGHT)];

	titleView=[[UIView alloc] initWithFrame:CGRectMake(0,0,frame.size.height, WEEKVIEW_TITLE_HEIGHT)];
	titleView.backgroundColor=[UIColor clearColor];
	
	CGFloat offsetX = -10;
	
	for (int i=0; i<7; i++)
	{
		UILabel *day = [[UILabel alloc] initWithFrame:CGRectMake(i*cellWidth + 2 + offsetX, MONTH_TITLE_HEIGHT - 2, cellWidth, DAY_TITLE_HEIGHT)];

		day.backgroundColor = [UIColor clearColor];
		day.textColor = [UIColor whiteColor];
		day.font = [UIFont systemFontOfSize:13];
		day.textAlignment = NSTextAlignmentCenter;
		day.text = taskmanager.currentSetting.weekStartDay==START_MONDAY?_dayNamesMon[i]:_dayNamesSun[i];
		
		[titleView addSubview:day];
		
		[day release];			
	}

	sunLabel=[[UILabel alloc] initWithFrame:CGRectMake(offsetX + 2, 2, cellWidth, MONTH_TITLE_HEIGHT)];
	sunLabel.backgroundColor=[UIColor clearColor];
	sunLabel.text=[NSString stringWithFormat:@"%d", self.sunMonthDay];
	sunLabel.font=[UIFont boldSystemFontOfSize:14];
	sunLabel.textColor=[UIColor whiteColor];
	sunLabel.textAlignment=NSTextAlignmentCenter;
	
	[titleView addSubview:sunLabel];
	[sunLabel release];
	
	monLabel=[[UILabel alloc] initWithFrame:CGRectMake(cellWidth + 2 + offsetX, 2, cellWidth, MONTH_TITLE_HEIGHT)];
	monLabel.backgroundColor=[UIColor clearColor];
	monLabel.text=[NSString stringWithFormat:@"%d", self.monMonthDay];
	monLabel.font=[UIFont boldSystemFontOfSize:14];
	monLabel.textColor=[UIColor whiteColor];
	monLabel.textAlignment=NSTextAlignmentCenter;
	
	[titleView addSubview:monLabel];
	[monLabel release];
	
	tueLabel=[[UILabel alloc] initWithFrame:CGRectMake(2*cellWidth + 2 + offsetX, 2, cellWidth, MONTH_TITLE_HEIGHT)];
	
	tueLabel.backgroundColor=[UIColor clearColor];
	tueLabel.text=[NSString stringWithFormat:@"%d", self.tueMonthDay];
	tueLabel.font=[UIFont boldSystemFontOfSize:14];
	tueLabel.textColor=[UIColor whiteColor];
	tueLabel.textAlignment=NSTextAlignmentCenter;
	
	[titleView addSubview:tueLabel];
	[tueLabel release];
	
	monthNameButton=[ivoUtility createButton:self.monthName 
							   buttonType:UIButtonTypeRoundedRect//UIButtonTypeCustom 
									//frame:CGRectMake(189, 5, 56, 24) 
									   frame:CGRectMake(3*cellWidth + 2 + offsetX, 2, cellWidth, MONTH_TITLE_HEIGHT -2) 
							   titleColor:[UIColor whiteColor]
								   target:self
								 selector:@selector(monthView:) 
						 normalStateImage:@"no-mash-blue.png" 
					   selectedStateImage:nil];
	[titleView addSubview:monthNameButton];
	
	[monthNameButton release];
	
	thuLabel=[[UILabel alloc] initWithFrame:CGRectMake(4*cellWidth + 2 + offsetX, 2, cellWidth, MONTH_TITLE_HEIGHT)];
	
	thuLabel.backgroundColor=[UIColor clearColor];
	thuLabel.text=[NSString stringWithFormat:@"%d", self.thuMonthDay];
	thuLabel.font=[UIFont boldSystemFontOfSize:14];
	thuLabel.textColor=[UIColor whiteColor];
	thuLabel.textAlignment=NSTextAlignmentCenter;
	
	[titleView addSubview:thuLabel];
	[thuLabel release];
	
	friLabel=[[UILabel alloc] initWithFrame:CGRectMake(5*cellWidth + 2 + offsetX, 2, cellWidth, MONTH_TITLE_HEIGHT)];
	
	friLabel.backgroundColor=[UIColor clearColor];
	friLabel.text=[NSString stringWithFormat:@"%d", self.friMonthDay];
	friLabel.font=[UIFont boldSystemFontOfSize:14];
	friLabel.textColor=[UIColor whiteColor];
	friLabel.textAlignment=NSTextAlignmentCenter;
	
	[titleView addSubview:friLabel];
	[friLabel release];
	
	satLabel=[[UILabel alloc] initWithFrame:CGRectMake(6*cellWidth + 2 + offsetX, 2, cellWidth, MONTH_TITLE_HEIGHT)];
	
	satLabel.backgroundColor=[UIColor clearColor];
	satLabel.text=[NSString stringWithFormat:@"%d", self.satMonthDay];
	satLabel.font=[UIFont boldSystemFontOfSize:14];
	satLabel.textColor=[UIColor whiteColor];
	satLabel.textAlignment=NSTextAlignmentCenter;

	[titleView addSubview:satLabel];
	[satLabel release];
	
	filterModeView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"filterWKV.png"]];
	filterModeView.frame=CGRectMake(frame.size.height-95, 10,15, 15);
	filterModeView.hidden=YES;
	[titleView addSubview:filterModeView];
	[filterModeView release];
	
	prevButton=[ivoUtility createButton:@"" 
									   buttonType:UIButtonTypeCustom 
											//frame:CGRectMake(0, 3, 50, 30) 
									frame:CGRectMake(offsetX + 5, 0, 48, MONTH_TITLE_HEIGHT)
									   titleColor:[UIColor whiteColor]
										   target:self 
										 selector:@selector(goPrev:) 
								 normalStateImage:@"left_arrow.png" 
							   selectedStateImage:nil];
	prevButton.titleLabel.font=[UIFont systemFontOfSize:22];
	prevButton.backgroundColor=[UIColor clearColor];
	
	[titleView addSubview:prevButton];
	[prevButton release];
	
	nextButton=[ivoUtility createButton:@"" 
									   buttonType:UIButtonTypeCustom 
											//frame:CGRectMake(405, 3, 50, 30) 
								  frame:CGRectMake(offsetX + frame.size.height - 48 - 5, 0, 48, MONTH_TITLE_HEIGHT)
									   titleColor:[UIColor whiteColor]
										   target:self 
										 selector:@selector(goNext:) 
								 normalStateImage:@"right_arrow.png" 
							   selectedStateImage:nil];
	nextButton.titleLabel.font=[UIFont systemFontOfSize:22];
 	nextButton.backgroundColor= [UIColor clearColor];
	
	[titleView addSubview:nextButton];
	[nextButton release];
	
	addNewButton=[ivoUtility createButton:@"" 
							   buttonType:UIButtonTypeCustom 
									frame:CGRectMake(frame.size.height-75, 3, 50, 30)
							   titleColor:[UIColor whiteColor]
								   target:self 
								 selector:@selector(addNew:) 
						 normalStateImage:@"plus.png" 
					   selectedStateImage:nil];
	addNewButton.titleLabel.font=[UIFont systemFontOfSize:22];
 	addNewButton.backgroundColor= [UIColor clearColor];
	addNewButton.hidden=YES;
	
	[titleView addSubview:addNewButton];
	[addNewButton release];
	
	UIBarButtonItem *titleButton=[[UIBarButtonItem alloc] initWithCustomView:titleView];	
	[titleView release];
	
	NSArray *items = [NSArray arrayWithObjects: titleButton,nil];
	topToolbar.items=items;
	[titleButton release];
	
	[contentView addSubview:topToolbar];
	[topToolbar release];
	
	NSInteger todayWD=[ivoUtility getWeekday:[NSDate date]];
	
	pageView=[[UIView alloc] initWithFrame:CGRectMake(0,WEEKVIEW_TITLE_HEIGHT,frame.size.height, 320-WEEKVIEW_TITLE_HEIGHT)];
	pageView.backgroundColor=[UIColor clearColor];
	[contentView addSubview:pageView];
	[pageView release];
	
	headerView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.height, WEEKVIEW_ADE_HEIGHT)];
	headerView.contentMode = UIViewContentModeScaleAspectFit;
	headerView.maximumZoomScale = 1;
	headerView.minimumZoomScale = 1;
	headerView.clipsToBounds = YES;
	headerView.delegate = self;
	headerView.directionalLockEnabled=YES;
	headerView.backgroundColor = [UIColor whiteColor];
	
	[pageView addSubview:headerView];
	[headerView release];
	
	//[self refreshADEView];
	
	//CGFloat dayY = WEEKVIEW_ADE_HEIGHT + 2;
	CGFloat dayY = WEEKVIEW_ADE_HEIGHT;
	
	timeFinderView = [[WeekViewTimeFinder alloc] initWithFrame:CGRectMake(0, dayY, frame.size.height, 320 - 18 - dayY - WEEKVIEW_TITLE_HEIGHT)];
	[pageView addSubview:timeFinderView];
	[timeFinderView setWeekViewController:self];
	[timeFinderView release];

	sunTableView= [[UITableView alloc] initWithFrame:CGRectMake(0, dayY, cellWidth + 2, 220) style:UITableViewStylePlain];
	
	sunTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	sunTableView.backgroundColor=[UIColor clearColor];
	sunTableView.indicatorStyle=UIScrollViewIndicatorStyleWhite;
	sunTableView.delegate = self;
	sunTableView.dataSource = self;
	[pageView addSubview:sunTableView];
	[sunTableView release];
	
	monTableView= [[UITableView alloc] initWithFrame:CGRectMake(cellWidth + 2, dayY, cellWidth, 220) style:UITableViewStylePlain];
	monTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	monTableView.indicatorStyle=UIScrollViewIndicatorStyleWhite;
	monTableView.backgroundColor=[UIColor clearColor];
	monTableView.delegate = self;
	monTableView.dataSource = self;
	[pageView addSubview:monTableView];
	[monTableView release];
	
	tueTableView= [[UITableView alloc] initWithFrame:CGRectMake(2*cellWidth + 2, dayY, cellWidth, 220) style:UITableViewStylePlain];
	tueTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	tueTableView.indicatorStyle=UIScrollViewIndicatorStyleWhite;
	tueTableView.delegate = self;
	tueTableView.dataSource = self;
	tueTableView.backgroundColor=[UIColor clearColor];
	[pageView addSubview:tueTableView];
	[tueTableView release];
	
	wedTableView= [[UITableView alloc] initWithFrame:CGRectMake(3*cellWidth + 2, dayY, cellWidth, 220) style:UITableViewStylePlain];
	wedTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	wedTableView.indicatorStyle=UIScrollViewIndicatorStyleWhite;
	wedTableView.backgroundColor=[UIColor clearColor];
	wedTableView.delegate = self;
	wedTableView.dataSource = self;
	[pageView addSubview:wedTableView];
	[wedTableView release];
	
	thuTableView= [[UITableView alloc] initWithFrame:CGRectMake(4*cellWidth + 2, dayY, cellWidth, 220) style:UITableViewStylePlain];
	thuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	thuTableView.indicatorStyle=UIScrollViewIndicatorStyleWhite;
	thuTableView.backgroundColor=[UIColor clearColor];
	thuTableView.delegate = self;
	thuTableView.dataSource = self;
	[pageView addSubview:thuTableView];
	[thuTableView release];
	
	friTableView= [[UITableView alloc] initWithFrame:CGRectMake(5*cellWidth + 2, dayY, cellWidth, 220) style:UITableViewStylePlain];
	friTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	friTableView.indicatorStyle=UIScrollViewIndicatorStyleWhite;
	friTableView.backgroundColor=[UIColor clearColor];
	friTableView.delegate = self;
	friTableView.dataSource = self;
	[pageView addSubview:friTableView];
	[friTableView release];
	
	satTableView= [[UITableView alloc] initWithFrame:CGRectMake(6*cellWidth + 2, dayY, cellWidth + 2, 220) style:UITableViewStylePlain];
	satTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	satTableView.indicatorStyle=UIScrollViewIndicatorStyleWhite;
	satTableView.backgroundColor = [UIColor clearColor];
	satTableView.delegate = self;
	satTableView.dataSource = self;
	[pageView addSubview:satTableView];	
	[satTableView release];
	
	skinView=[[WeeklyViewSkin alloc] initWithFrame:CGRectMake(0, 0, frame.size.height, 320-WEEKVIEW_TITLE_HEIGHT)];
	[pageView addSubview:skinView];
	[skinView release];
	
	timeFinderView.today = todayWD;

	if(taskmanager.currentSetting.iVoStyleID==0){
		[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
		self.topToolbar.barStyle=UIBarStyleDefault;
		headerView.backgroundColor = [UIColor darkGrayColor];
	}else {
		[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
		self.topToolbar.barStyle=UIBarStyleBlackOpaque;

		headerView.backgroundColor = [UIColor blackColor];
	}
	
	/*
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	
	[animation setType:kCATransitionMoveIn];
	[animation setSubtype:kCATransitionFromTop];
	
	// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
	[animation setDuration:0.4];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[contentView layer] addAnimation:animation forKey:kAnimationKey];	
	*/
	
	App_Delegate.me.networkActivityIndicatorVisible=NO;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
  
   if(interfaceOrientation == UIInterfaceOrientationPortrait||interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){

   }else {
		//if(fromInterfaceOrientation==UIInterfaceOrientationPortrait||fromInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
//		self.containerView.frame=CGRectMake(0, 0, 480, 320);
			
//		NSTimer *startWeekViewTimer=[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(startWeekView) userInfo:nil repeats:NO];
		
	}

	//return (interfaceOrientation==UIInterfaceOrientationLandscapeLeft||interfaceOrientation==UIInterfaceOrientationLandscapeRight);
	return YES;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	//duration=0.5;
	//printf("\nbegin rotate duration: %d",duration);
	CGRect frame=[[UIScreen mainScreen] bounds];
    
	if(toInterfaceOrientation == UIInterfaceOrientationPortrait||toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
		
		 //self.navigationController.navigationBarHidden=NO;
		
		if(!isBackFromMonthView){
			switch (selectedWD) {
				case -1:
					self.SmartViewController.selectedWeekDate=nil;
					break;
				case 1:
					self.SmartViewController.selectedWeekDate=self.firstDateInWeek;
					break;
				case 2:
					self.SmartViewController.selectedWeekDate=self.monday;
					break;
				case 3:
					self.SmartViewController.selectedWeekDate=self.tueday;
					break;
				case 4:
					self.SmartViewController.selectedWeekDate=self.wednesday;
					break;
				case 5:
					self.SmartViewController.selectedWeekDate=self.thusday;
					break;
				case 6:
					self.SmartViewController.selectedWeekDate=self.friday;
					break;
				case 7:
					self.SmartViewController.selectedWeekDate=self.lastDateInWeek;
					break;
				default:
					self.SmartViewController.selectedWeekDate=nil;
					break;
			}
		}
		
		//[self.navigationController popViewControllerAnimated:NO];
		
	}else {
		//self.containerView.frame=CGRectMake(0, 0, 480, 320);
		//if(fromInterfaceOrientation==UIInterfaceOrientationPortrait||fromInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
		self.containerView.frame=CGRectMake(0, 0, frame.size.height, 320);
		
		[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(startWeekView) userInfo:nil repeats:NO];				
	}
	 
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	

}

-(void)getStateForExisting{
	if(!isBackFromMonthView){
		switch (selectedWD) {
			case -1:
				self.SmartViewController.selectedWeekDate=nil;
				break;
			case 1:
				self.SmartViewController.selectedWeekDate=self.firstDateInWeek;
				break;
			case 2:
				self.SmartViewController.selectedWeekDate=self.monday;
				break;
			case 3:
				self.SmartViewController.selectedWeekDate=self.tueday;
				break;
			case 4:
				self.SmartViewController.selectedWeekDate=self.wednesday;
				break;
			case 5:
				self.SmartViewController.selectedWeekDate=self.thusday;
				break;
			case 6:
				self.SmartViewController.selectedWeekDate=self.friday;
				break;
			case 7:
				self.SmartViewController.selectedWeekDate=self.lastDateInWeek;
				break;
			default:
				self.SmartViewController.selectedWeekDate=nil;
				break;
		}
	}
	
	taskmanager.filterClause=nil;
	[taskmanager getDisplayList:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	//[adeView release];
    [super dealloc];
}

#pragma mark action methods
-(void)goPrev:(id)sender{
	//App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	self.currentDisplayDate=[self.currentDisplayDate dateByAddingTimeInterval:-7*86400];
	[self refreshTableViews];
/*	
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	
	//[animation setType:kCATransitionMoveIn];
	[animation setType:kCATransitionPush];
	//[animation setSubtype:kCATransitionFromLeft];
	[animation setSubtype:kCATransitionFromLeft];
	
	// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
	[animation setDuration:kTransitionDuration];
	//[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
	
	[[pageView layer] addAnimation:animation forKey:kAnimationKey];	
*/	
	//App_Delegate.me.networkActivityIndicatorVisible=NO;
}

-(void)goNext:(id)sender{
	//App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	self.currentDisplayDate=[self.currentDisplayDate dateByAddingTimeInterval:7*86400];
	[self refreshTableViews];
/*
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	
	//[animation setType:kCATransitionMoveIn];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromRight];
	
	// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
	[animation setDuration:kTransitionDuration];
	//[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
	
	//[[contentView layer] addAnimation:animation forKey:kAnimationKey];	
	[[pageView layer] addAnimation:animation forKey:kAnimationKey];
*/	
	//App_Delegate.me.networkActivityIndicatorVisible=NO;
}

-(void)rightAction:(id)sender{
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	switch (segBar.selectedSegmentIndex) {
		case 0://goto a specified date
		{
			//[self popDownOptionView];
			self.currentDisplayDate=jumpToDateDP.date;
			
			if ([self.view isKindOfClass:[MonthlyView class]])
			{
				MonthlyView *view = (MonthlyView *) self.view;
				//[view initCalendarDate:jumpToDateDP.date];
				[view goToDate:jumpToDateDP.date];
			}
			else
			{
				[self refreshTableViews];
			}
			[self popDownOptionView];
		}
			break;
		case 1://filter
		{
			NSString *title=taskNameTF.text;
			//format: taskTitle|Task|Event|Work|Home|ProJ0|ProJ2|ProJ2|ProJ3|ProJ4|ProJ5
			NSString *queryClauseWithFormat=[NSString stringWithFormat:@"%@|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d",title?title:@"",taskButton.selected?0:-1,eventButton.selected?1:-1,
								   workButton.selected?1:-1,homeButton.selected?0:-1,noneButton.selected?0:-1,urgentButton.selected?1:-1,
								   privateButton.selected?2:-1,projectAButton.selected?3:-1,projectBButton.selected?4:-1,projectCButton.selected?5:-1,
								   project7Button.selected?6:-1,project8Button.selected?7:-1,project9Button.selected?8:-1,project10Button.selected?9:-1,
								   project11Button.selected?10:-1,project12Button.selected?11:-1];
			
			taskmanager.filterClause=queryClauseWithFormat;
			
			isFilter=YES;
			filterModeView.hidden=NO;
			
			if ([self.view isKindOfClass:[MonthlyView class]])
			{
				MonthlyView *view = (MonthlyView *) self.view;
				view.isFilter = YES;
			}
			else
			{
				[self refreshTableViews];
			}
			[self popDownOptionView];
			//isFilter=YES;
		}
			break;
			
		case 2://quick add event
			[self addNew:sender];
			break;
	}
	App_Delegate.me.networkActivityIndicatorVisible=NO;

}

-(void)leftAction:(id)sender{
	App_Delegate.me.networkActivityIndicatorVisible=YES;

	switch (segBar.selectedSegmentIndex) {
		case 0://goto a specified date
		{
			NSString *curentDateStr=[ivoUtility createStringFromShortDate:[NSDate date]];
			
			NSDate *tmp = self.currentDisplayDate;
			
			if ([self.view isKindOfClass:[MonthlyView class]])
			{
				MonthlyView *view = (MonthlyView *) self.view;
				tmp = view.date;
			}
						
			NSString *displayingDate=[ivoUtility createStringFromShortDate:tmp];
			if(![curentDateStr isEqualToString:displayingDate]){
				
				if ([self.view isKindOfClass:[MonthlyView class]])
				{
					MonthlyView *view = (MonthlyView *) self.view;
					//[view initCalendarDate:[NSDate date]];
					[view goToDate:[NSDate date]];
				}
				
				self.currentDisplayDate=[NSDate date];
				[self refreshTableViews];
			}
			[curentDateStr release];
			[displayingDate release];
			
			[self popDownOptionView];
		}
			break;
		case 1://filter: exit filter
			taskmanager.filterClause=nil;
			
			if ([self.view isKindOfClass:[MonthlyView class]])
			{
				MonthlyView *view = (MonthlyView *) self.view;
				view.isFilter = NO;
			}
			else
			{
				[self refreshTableViews];
			}
			[self popDownOptionView];
			isFilter=NO;
			filterModeView.hidden=YES;
			break;
			
		case 2://quick add event
		{
			if([[leftButton titleForState:UIControlStateNormal] isEqualToString:NSLocalizedString(@"taskText", @"")/*taskText*/]){
				[leftButton setTitle:NSLocalizedString(@"eventText", @"")/*eventText*/ forState:UIControlStateNormal];
				//contextSeg.hidden=YES;
				homeButton.hidden=YES;
				workButton.hidden=YES;
				taskStartBT.hidden=NO;
				toggleLB.text=NSLocalizedString(@"startText", @"")/*startText*/;
			}else if([[leftButton titleForState:UIControlStateNormal] isEqualToString:NSLocalizedString(@"eventText", @"")/*eventText*/]){
				[leftButton setTitle:NSLocalizedString(@"taskText", @"")/*taskText*/ forState:UIControlStateNormal];
				homeButton.hidden=NO;
				workButton.hidden=NO;
				[self contextChanged:workButton];
				taskStartBT.hidden=YES;
				toggleLB.text=NSLocalizedString(@"contextText", @"")/*contextText*/;
				[self popDownDatePicker];
			}

		}
			break;
	}
	
	App_Delegate.me.networkActivityIndicatorVisible=NO;
}

-(void)monthView:(id)sender{
	[self showView:1 date:self.currentDisplayDate];	
}

-(void)dateChanged:(id)sender{
	NSString *startStr=[ivoUtility createStringFromDate:jumpToDateDP.date isIncludedTime:YES];
	[taskStartBT setTitle:startStr forState:UIControlStateNormal];
	[startStr release];
}

-(void)addNew:(id)sender{
	NSInteger duration=0;
	if(firstIconPeriod.selected){
		duration=1800;	
	}else if(secondIconPeriod.selected) {
		duration=3600;
	}else if(thirdIconPeriod.selected) {
		duration=7200;
	}else if(fourthIconPeriod.selected) {
		duration=10800;
	}

	NSInteger projectID=0;

	if(noneButton.selected){
		projectID=0;	
	}else if(urgentButton.selected) {
		projectID=1;
	}else if(privateButton.selected) {
		projectID=2;
	}else if(projectAButton.selected) {
		projectID=3;
	}else if(projectBButton.selected) {
		projectID=4;
	}else if(projectCButton.selected) {
		projectID=5;
	}else if(project7Button.selected) {
		projectID=6;
	}else if(project8Button.selected) {
		projectID=7;
	}else if(project9Button.selected) {
		projectID=8;
	}else if(project10Button.selected) {
		projectID=9;
	}else if(project11Button.selected) {
		projectID=10;
	}else if(project12Button.selected) {
		projectID=11;
	}
	
	Task *task=[[Task alloc] init];
	NSInteger taskPin=[[leftButton titleForState:UIControlStateNormal] isEqualToString:NSLocalizedString(@"eventText", @"")/*eventText*/];
	task.taskName=(taskNameTF.text==nil || [taskNameTF.text isEqualToString:@""])? (taskPin? NSLocalizedString(@"newEventText", @""):NSLocalizedString(@"newTaskText", @"")/*newEventText:newTaskText*/):taskNameTF.text;
	task.taskPinned=taskPin;
	task.taskHowLong=duration;
	task.taskProject=projectID;
	if(taskPin==1){
		task.taskStartTime=jumpToDateDP.date;
		task.taskEndTime=[task.taskStartTime dateByAddingTimeInterval:duration];
	}else {
		task.taskNotEalierThan=jumpToDateDP.date;
		task.taskWhere=homeButton.selected? 0:1;
	}
	self.newTask=task;
	[task release];
	
	
	[ivoUtility inspectPinnedTaskDate:self.newTask];
	
	self.newTask.taskTypeUpdate=0;	
	
	TaskActionResult *checkTaskResult=[taskmanager addNewTask:self.newTask toArray:taskmanager.taskList isAllowChangeDueWhenAdd:NO];
	if(checkTaskResult.errorNo==1){
		UIAlertView *alrtView = [[UIAlertView alloc] initWithTitle:checkTaskResult.errorMessage message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/ otherButtonTitles:nil];
		[alrtView show];
		[alrtView release];
		goto exitSave;
		
	}else if(checkTaskResult.errorNo==ERR_TASK_ITSELF_PASS_DEADLINE) {//overdeadline time slot found
//		alertViewAddPassedDue = [[UIAlertView alloc] initWithTitle:actionMakesItsPassDeadLineText message:nil delegate:self cancelButtonTitle:manuallyText otherButtonTitles:nil];
//		[alertViewAddPassedDue addButtonWithTitle:automaticallyText];
//		[alertViewAddPassedDue show];
//		[alertViewAddPassedDue release];
		goto exitSave;
	}else if(checkTaskResult.errorNo==ERR_TASK_ANOTHER_PASS_DEADLINE){

		UIAlertView *alertViewAddEventTaskPassedDue = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"actionMakesOthersPassDeadlinesText", @"")/*actionMakesOthersPassDeadlinesText*/ message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancelText", @"")/*cancelText*/ otherButtonTitles:nil];
		
		[alertViewAddEventTaskPassedDue addButtonWithTitle:NSLocalizedString(@"yesText", @"")/*yesText*/];
		[alertViewAddEventTaskPassedDue show];
		[alertViewAddEventTaskPassedDue release];
		goto exitSave;
	}

	if ([self.view isKindOfClass:[MonthlyView class]])
	{
		MonthlyView *view = (MonthlyView *) self.view;
		
		//[view goToDate:task.taskStartTime];
		[view initCalendarDate:task.taskStartTime];
	}
	else
	{
		[self refreshTableViews];
	}
	
	[self popDownOptionView];
	
exitSave:
	[checkTaskResult release];	
}

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex{
	//ILOG(@"[TaskDetailViewController clickedButtonAtIndex\n");
	
	TaskActionResult *checkTaskResult=nil;
	if(buttonIndex==1){
		checkTaskResult=[taskmanager addNewTask:self.newTask toArray:taskmanager.taskList isAllowChangeDueWhenAdd:YES];
		[self refreshTableViews];
		[self popDownOptionView];
	}	
	
	[checkTaskResult release];
	//ILOG(@"TaskDetailViewController clickedButtonAtIndex]\n");
}


-(void)optStyleChange:(id)sender{
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	switch (segBar.selectedSegmentIndex) {
		case 0://goto a specified date
		{
			if([self.optSubView superview]){
				[self.optSubView removeFromSuperview];
			}
			
			doneButton.hidden=YES;
			[leftButton setTitle:NSLocalizedString(@"todayText", @"")/*todayText*/ forState:UIControlStateNormal];
			[rightButton setTitle:NSLocalizedString(@"goText", @"")/*goText*/ forState:UIControlStateNormal];
			jumpToDateDP.datePickerMode=UIDatePickerModeDate;
			[self popUpDatePicker];
		}
			break;
		case 1://filter
		{
			if(!self.optSubView){
				[self setupOptionSubView];
			}
			
			if(![self.optSubView superview]){
				[optionView addSubview:self.optSubView];
			}
			
			doneButton.hidden=YES;
			toggleLB.text=NSLocalizedString(@"contextText", @"")/*contextText*/;
			//contextSeg.hidden=NO;
			homeButton.hidden=NO;
			workButton.hidden=NO;
			taskStartBT.hidden=YES;

			typeDurLB.text=NSLocalizedString(@"typeStrText", @"")/*typeStrText*/;
			firstIconPeriod.hidden=YES;
			secondIconPeriod.hidden=YES;
			thirdIconPeriod.hidden=YES;
			fourthIconPeriod.hidden=YES;
			
			taskButton.hidden=NO;
			eventButton.hidden=NO;
			
			[leftButton setTitle:NSLocalizedString(@"exitText", @"")/*exitText*/ forState:UIControlStateNormal];
			[rightButton setTitle:NSLocalizedString(@"applyText", @"")/*applyText*/ forState:UIControlStateNormal];
			jumpToDateDP.datePickerMode=UIDatePickerModeDateAndTime;

			[optionView bringSubviewToFront:jumpToDateDP];
			[self popDownDatePicker];
		}
			break;
		case 2://quick add event
		{
			if(!self.optSubView){
				[self setupOptionSubView];
				[optionView addSubview:self.optSubView];
			}
			
			if(![self.optSubView superview]){
				[optionView addSubview:self.optSubView];
			}
			
			doneButton.hidden=NO;
			
			//set default Values
			NSString *dateStr=[ivoUtility createStringFromDate:jumpToDateDP.date isIncludedTime:YES];
			[taskStartBT setTitle:dateStr forState:UIControlStateNormal];
			[dateStr release];
			
			toggleLB.text=NSLocalizedString(@"startText", @"")/*startText*/;
			homeButton.hidden=YES;
			workButton.hidden=YES;
			taskStartBT.hidden=NO;
			
			typeDurLB.text=NSLocalizedString(@"durationText", @"")/*durationText*/;
			firstIconPeriod.hidden=NO;
			secondIconPeriod.hidden=NO;
			thirdIconPeriod.hidden=NO;
			fourthIconPeriod.hidden=NO;
			//taskTypeSeg.hidden=YES;
			
			taskButton.hidden=YES;
			eventButton.hidden=YES;

			
			[self periodChanged:secondIconPeriod];
			[self projSelected:noneButton];
			
			[leftButton setTitle:NSLocalizedString(@"eventText", @"")/*eventText*/ forState:UIControlStateNormal];
			[rightButton setTitle:NSLocalizedString(@"saveText", @"")/*saveText*/ forState:UIControlStateNormal];
			jumpToDateDP.datePickerMode=UIDatePickerModeDateAndTime;
			[optionView bringSubviewToFront:jumpToDateDP];
			[self popDownDatePicker];
		}
			break;
	}
	
	App_Delegate.me.networkActivityIndicatorVisible=NO;
}

-(void)doneAction:(id)sender{
	[self popDownDatePicker];
}

-(void)startDateSelected:(id)sender{
	[taskNameTF resignFirstResponder];
	CGRect frm=jumpToDateDP.frame;
	if (frm.origin.y > 100){
		[self popUpDatePicker];
	}
}

-(void)periodChanged:(id)sender{
	
	switch (segBar.selectedSegmentIndex) {
		case 0:
			
			break;
		case 1:
			
			break;
		case 2:
		{
			firstIconPeriod.selected=NO;
			secondIconPeriod.selected=NO;
			thirdIconPeriod.selected=NO;
			fourthIconPeriod.selected=NO;
			[(UIButton *)sender setSelected:YES];
		}
			break;
	}
	
}

-(void)projSelected:(id)sender{
	switch (segBar.selectedSegmentIndex) {
		case 0:
			
			break;
		case 1:
		{
			UIButton *tmp=sender;
			if(tmp.selected){
				[sender setSelected:NO];
			}else {
				[sender setSelected:YES];
			}
		}
			break;
		case 2:
		{
			noneButton.selected=NO;
			urgentButton.selected=NO;
			privateButton.selected=NO;
			projectAButton.selected=NO;
			projectBButton.selected=NO;
			projectCButton.selected=NO;
			
			project7Button.selected=NO;
			project8Button.selected=NO;
			project9Button.selected=NO;
			project10Button.selected=NO;
			project11Button.selected=NO;
			project12Button.selected=NO;
			
			[(UIButton *)sender setSelected:YES];
		}
			break;
	}
	
}

-(void)contextChanged:(id)sender{
	switch (segBar.selectedSegmentIndex) {
		case 0:
			break;
		case 1:
		{
			UIButton *tmp=sender;
			if(tmp.selected){
				[sender setSelected:NO];
			}else {
				[sender setSelected:YES];
			}
		}
			break;
		case 2:
			homeButton.selected=NO;
			workButton.selected=NO;
			[sender setSelected:YES];
			break;
	}
}

-(void)taskTypeChanged:(id)sender{
	UIButton *tmp=sender;
	if(tmp.selected){
		[sender setSelected:NO];
	}else {
		[sender setSelected:YES];
	}

}

#pragma mark -
#pragma mark === TableView datasource methods ===
#pragma mark -

// As the delegate and data source for the table, the PreferencesView must respond to certain methods the table view
// will call to get the number of sections, the number of rows, and the cell for a row.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;//one section for each table
	
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	//ILOG(@"[ListTaskView numberOfRowsInSection\n");
	
	if([table isEqual:sunTableView]){
		return sunList.count>7?sunList.count:7;
		//return 10;
	}else if([table isEqual: monTableView]){
		return monList.count>7?monList.count:7;
		//return 10;
	}else if([table isEqual: tueTableView]){
		return tueList.count>7?tueList.count:7;
		//return 10;
	}else if([table isEqual: wedTableView]){
		return wedList.count>7?wedList.count:7;
		//return 10;
	}else if([table isEqual: thuTableView]){
		return thuList.count>7?thuList.count:7;
		//return 10;
	}else if([table isEqual: friTableView]){
		return friList.count>7?friList.count:7;
		//return 10;
	}else if([table isEqual: satTableView]){
		return satList.count>7?satList.count:7;
		//return 10;
	}//else if([table isEqual:headerView]) {
		//return adeList.count;
	//	return 1;
	//}

	
	//ILOG(@"ListTaskView numberOfRowsInSection]\n");
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// this table has only one section
	return @"";
}


#pragma mark -
#pragma mark === TableView delegate methods ===
#pragma mark -
// Specify the kind of accessory view (to the far right of each row) we will use
//- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
//	return UITableViewCellAccessoryNone;
//}

// Provide cells for the table, with each showing one of the available time signatures
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//ILOG(@"[ListTaskView cellForRowAtIndexPath\n");
	
	WeekViewTableCell *cell = (WeekViewTableCell *)[table dequeueReusableCellWithIdentifier:@"DoCell"];
	if (cell == nil) {
		cell = [[[WeekViewTableCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DoCell"] autorelease];
	}else {
		NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
		for (UIView *subview in subviews) {
			[subview removeFromSuperview];
		}
		[subviews release];
	}
	
	if(taskmanager.currentSetting.iVoStyleID==0)
	{
		cell.taskName.textColor=[UIColor blackColor];
	}
	else 
	{
		cell.taskName.textColor=[UIColor whiteColor];		
	}		
	
	cell.selectionStyle=UITableViewCellSelectionStyleNone;
	
	cell.textLabel.font=[UIFont systemFontOfSize:14];
	
	NSInteger taskPin=0;
	UIImageView *projType=nil;

	CGRect frm=cell.taskName.frame;
	frm.size.width=table.frame.size.width-13;
	cell.taskName.frame=frm;
	cell.taskName.numberOfLines=2;
	
	if([table isEqual:sunTableView]){
		if(indexPath.row<sunList.count){
			taskPin=[[sunList objectAtIndex:indexPath.row] taskPinned];
			Task *tmp=[sunList objectAtIndex:indexPath.row];
			if(selectedWD==1){
				cell.taskName.font=[UIFont systemFontOfSize:14];
				if(taskPin==1){
					cell.taskName.text=[NSString stringWithFormat:@"[%@-%@] %@",[ivoUtility getTimeStringFromDate:tmp.taskStartTime],[ivoUtility getTimeStringFromDate:tmp.taskEndTime],tmp.taskName];
				}else if(tmp.taskIsUseDeadLine==1){
					cell.taskName.text=[NSString stringWithFormat:@"[%@] %@",[ivoUtility getShortStringFromDate:tmp.taskDeadLine],tmp.taskName];
				}else {
					cell.taskName.text =tmp.taskName;
				}
			}else {
				cell.taskName.font=[UIFont systemFontOfSize:12];
				cell.taskName.text =tmp.taskName;
			}
			
			if(taskPin==1){
					projType=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"circle%d.png",[[sunList objectAtIndex:indexPath.row] taskProject]+1]]];
			}else {
				projType=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"poly%d.png",[[sunList objectAtIndex:indexPath.row] taskProject]+1]]];
			}
		}else {
			cell.taskName.text=@"";
			projType=nil;
		}
		
	}else if([table isEqual: monTableView]){
		if(indexPath.row<monList.count){
			taskPin=[[monList objectAtIndex:indexPath.row] taskPinned];
			Task *tmp=[monList objectAtIndex:indexPath.row];
			if(selectedWD==2){
				cell.taskName.font=[UIFont systemFontOfSize:14];
				if(taskPin==1){
					cell.taskName.text=[NSString stringWithFormat:@"[%@-%@] %@",[ivoUtility getTimeStringFromDate:tmp.taskStartTime],[ivoUtility getTimeStringFromDate:tmp.taskEndTime],tmp.taskName];
				}else if(tmp.taskIsUseDeadLine==1){
					cell.taskName.text=[NSString stringWithFormat:@"[%@] %@",[ivoUtility getShortStringFromDate:tmp.taskDeadLine],tmp.taskName];
				}else {
					cell.taskName.text =tmp.taskName;
				}
			}else {
				cell.taskName.font=[UIFont systemFontOfSize:12];
				cell.taskName.text =tmp.taskName;
			}
			
			
			if(taskPin==1){
				projType=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"circle%d.png",[[monList objectAtIndex:indexPath.row] taskProject]+1]]];
			}else {
				projType=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"poly%d.png",[[monList objectAtIndex:indexPath.row] taskProject]+1]]];
			}
		}else {
			cell.taskName.text=@"";
			projType=nil;
		}

	}else if([table isEqual: tueTableView]){
		if(indexPath.row<tueList.count){
			taskPin=[[tueList objectAtIndex:indexPath.row] taskPinned];
			Task *tmp=[tueList objectAtIndex:indexPath.row];
			if(selectedWD==3){
				cell.taskName.font=[UIFont systemFontOfSize:14];
				if(taskPin==1){
					cell.taskName.text=[NSString stringWithFormat:@"[%@-%@] %@",[ivoUtility getTimeStringFromDate:tmp.taskStartTime],[ivoUtility getTimeStringFromDate:tmp.taskEndTime],tmp.taskName];
				}else if(tmp.taskIsUseDeadLine==1){
					cell.taskName.text=[NSString stringWithFormat:@"[%@] %@",[ivoUtility getShortStringFromDate:tmp.taskDeadLine],tmp.taskName];
				}else {
					cell.taskName.text =tmp.taskName;
				}
			}else {
				cell.taskName.font=[UIFont systemFontOfSize:12];
				cell.taskName.text =tmp.taskName;
			}
			
			
			if(taskPin==1){
				projType=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"circle%d.png",[[tueList objectAtIndex:indexPath.row] taskProject]+1]]];
			}else {
				projType=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"poly%d.png",[[tueList objectAtIndex:indexPath.row] taskProject]+1]]];
			}
		}else {
			cell.taskName.text =@"";
			projType=nil;
		}

	}else if([table isEqual: wedTableView]){
		if(indexPath.row<wedList.count){
			taskPin=[[wedList objectAtIndex:indexPath.row] taskPinned];
			Task *tmp=[wedList objectAtIndex:indexPath.row];
			if(selectedWD==4){
				cell.taskName.font=[UIFont systemFontOfSize:14];
				if(taskPin==1){
					cell.taskName.text=[NSString stringWithFormat:@"[%@-%@] %@",[ivoUtility getTimeStringFromDate:tmp.taskStartTime],[ivoUtility getTimeStringFromDate:tmp.taskEndTime],tmp.taskName];
				}else if(tmp.taskIsUseDeadLine==1){
					cell.taskName.text=[NSString stringWithFormat:@"[%@] %@",[ivoUtility getShortStringFromDate:tmp.taskDeadLine],tmp.taskName];
				}else {
					cell.taskName.text =tmp.taskName;
				}
			}else {
				cell.taskName.font=[UIFont systemFontOfSize:12];
				cell.taskName.text =tmp.taskName;
			}			
			
			if(taskPin==1){
				projType=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"circle%d.png",[[wedList objectAtIndex:indexPath.row] taskProject]+1]]];
			}else {
				projType=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"poly%d.png",[[wedList objectAtIndex:indexPath.row] taskProject]+1]]];
			}
		}else {
			cell.taskName.text=@"";
			projType=nil;
		}

	}else if([table isEqual: thuTableView]){
		if(indexPath.row<thuList.count){
			taskPin=[[thuList objectAtIndex:indexPath.row] taskPinned];
			Task *tmp=[thuList objectAtIndex:indexPath.row];
			if(selectedWD==5){
				cell.taskName.font=[UIFont systemFontOfSize:14];
				if(taskPin==1){
					cell.taskName.text=[NSString stringWithFormat:@"[%@-%@] %@",[ivoUtility getTimeStringFromDate:tmp.taskStartTime],[ivoUtility getTimeStringFromDate:tmp.taskEndTime],tmp.taskName];
				}else if(tmp.taskIsUseDeadLine==1){
					cell.taskName.text=[NSString stringWithFormat:@"[%@] %@",[ivoUtility getShortStringFromDate:tmp.taskDeadLine],tmp.taskName];
				}else {
					cell.taskName.text =tmp.taskName;
				}
			}else {
				cell.taskName.font=[UIFont systemFontOfSize:12];
				cell.taskName.text =tmp.taskName;
			}
			
			if(taskPin==1){
					projType=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"circle%d.png",[[thuList objectAtIndex:indexPath.row] taskProject]+1]]];
			}else {
				projType=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"poly%d.png",[[thuList objectAtIndex:indexPath.row] taskProject]+1]]];
			}
		}else {
			cell.taskName.text=@"";
			projType=nil;
		}

	}else if([table isEqual: friTableView]){
		if(indexPath.row<friList.count){
			taskPin=[[friList objectAtIndex:indexPath.row] taskPinned];
			Task *tmp=[friList objectAtIndex:indexPath.row];
			if(selectedWD==6){
				cell.taskName.font=[UIFont systemFontOfSize:14];
				if(taskPin==1){
					cell.taskName.text=[NSString stringWithFormat:@"[%@-%@] %@",[ivoUtility getTimeStringFromDate:tmp.taskStartTime],[ivoUtility getTimeStringFromDate:tmp.taskEndTime],tmp.taskName];
				}else if(tmp.taskIsUseDeadLine==1){
					cell.taskName.text=[NSString stringWithFormat:@"[%@] %@",[ivoUtility getShortStringFromDate:tmp.taskDeadLine],tmp.taskName];
				}else {
					cell.taskName.text =tmp.taskName;
				}
			}else {
				cell.taskName.font=[UIFont systemFontOfSize:12];
				cell.taskName.text =tmp.taskName;
			}
			
			if(taskPin==1){
				projType=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"circle%d.png",[[friList objectAtIndex:indexPath.row] taskProject]+1]]];
			}else {
				projType=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"poly%d.png",[[friList objectAtIndex:indexPath.row] taskProject]+1]]];
			}
		}else {
			cell.taskName.text=@"";
			projType=nil;
		}

	}else if([table isEqual: satTableView]){
		if(indexPath.row<satList.count){
			taskPin=[[satList objectAtIndex:indexPath.row] taskPinned];
			Task *tmp=[satList objectAtIndex:indexPath.row];
			if(selectedWD==7){
				cell.taskName.font=[UIFont systemFontOfSize:14];
				if(taskPin==1){
					cell.taskName.text=[NSString stringWithFormat:@"[%@-%@] %@",[ivoUtility getTimeStringFromDate:tmp.taskStartTime],[ivoUtility getTimeStringFromDate:tmp.taskEndTime],tmp.taskName];
				}else if(tmp.taskIsUseDeadLine==1){
					cell.taskName.text=[NSString stringWithFormat:@"[%@] %@",[ivoUtility getShortStringFromDate:tmp.taskDeadLine],tmp.taskName];
				}else {
					cell.taskName.text =tmp.taskName;
				}
			}else {
				cell.taskName.font=[UIFont systemFontOfSize:12];
				cell.taskName.text =tmp.taskName;
			}
			
			if(taskPin==1){
				projType=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"circle%d.png",[[satList objectAtIndex:indexPath.row] taskProject]+1]]];
			}else {
				projType=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"poly%d.png",[[satList objectAtIndex:indexPath.row] taskProject]+1]]];
			}
		}else {
			cell.taskName.text=@"";
			projType=nil;
		}

	}//else if([table isEqual:headerView]) {
		//if([adeView superview]){
		//	[adeView removeFromSuperview];
		//}
		
		//[self refreshADEView];
		//[adeView sizeToFit];
		//[cell.contentView addSubview:adeView];
		//[cell.contentView sizeToFit];
		//[cell sizeToFit];
		//return cell;
	//}

	if(projType){	
		projType.frame=CGRectMake(2, 10, 8, 8);
		[cell.contentView addSubview:projType];
		[projType release];
	}
	
	return cell;
	//ILOG(@"ListTaskView cellForRowAtIndexPath]\n");
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	
	[self refreshTableViewsSize:table];
	
	[table deselectRowAtIndexPath:newIndexPath animated:YES];
	
	//ILOG(@"ListTaskView didSelectRowAtIndexPath]\n");
}

- (void)tableView:(UITableView *)tV commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	//NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:self.pathIndex inSection:0];
	//ILOG(@"ListTaskView commitEditingStyle]\n");
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
	return;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
	
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
	
	return NO;	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	//if([tableView isEqual:headerView]){
	//	return 200;
	//}
	
	if([tableView isEqual:sunTableView]){
		if (selectedWD==1){
			return 38;
		}
	}else if([tableView isEqual:monTableView]){
		if (selectedWD==2){
			return 38;
		}
		
	}else if([tableView isEqual:tueTableView]){
		if (selectedWD==3){
			return 38;
		}
		
	}else if([tableView isEqual:wedTableView]){
		if (selectedWD==4){
			return 38;
		}
		
	}else if([tableView isEqual:thuTableView]){
		if (selectedWD==5){
			return 38;
		}
		
	}else if([tableView isEqual:friTableView]){
		if (selectedWD==6){
			return 38;
		}
		
	}else if([tableView isEqual:satTableView]){
		if (selectedWD==7){
			return 38;
		}
	}

	return 32;
}

//swipe to delete
- (void)tableView:(UITableView *)table didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{

}

- (UITableViewCellEditingStyle)tableView:(UITableView *)table editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	return UITableViewCellEditingStyleNone;	
}

#pragma mark common methods
-(void)showView:(NSInteger)type date:(NSDate *)date
{
    CGRect frame=[[UIScreen mainScreen] bounds];
    
	if(isPoppedUp)
	{
		[self popDownOptionView];
	}
	
	switch (type)
	{
		case 0: //week view
		{
			self.currentDisplayDate = date;
			
			self.view = self.containerView;
			
			[self refreshTableViews];
		}	
			break;
		case 1: //month view
		{
			MonthlyView *monthView=[[MonthlyView alloc] initWithFrame:CGRectMake(0, 0, frame.size.height, 320-18)];
			
			[monthView initCalendarDate:date];
			
			self.view = monthView;
			
			//monthView.controller = self;
			
			[monthView release];
			/*
			CATransition *animation = [CATransition animation];
			[animation setDelegate:self];
			
			[animation setType:kCATransitionReveal];
			//[animation setType:kCATransitionPush];
			//[animation setSubtype:kCATransitionFromLeft];
			[animation setSubtype:kCATransitionFromTop];
			
			// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
			[animation setDuration:kTransitionDuration];
			//[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
			[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
			
			[[self.view layer] addAnimation:animation forKey:kAnimationKey];	
			
			*/
		}
			break;
	}
	
}

-(void)setupDisplayList:(NSDate *)forDate{
	
	App_Delegate.me.networkActivityIndicatorVisible=YES;

	NSMutableArray *list;
	if(!isFilter){
		list=taskmanager.taskList;
	}else {
		list=[taskmanager getDisplayList:self.lastDateInWeek];
	}
	
	NSInteger weekday=[ivoUtility getWeekday:forDate];
	
	//get sun date
	NSDate *date=[forDate dateByAddingTimeInterval:-(weekday -1)*86400];
	self.firstDateInWeek=date;
	
	self.sunMonthDay=[ivoUtility getDay:date];
	NSString *sundayStr=[ivoUtility createStringFromShortDate:date];
	
	self.monday=[date dateByAddingTimeInterval:86400];
	self.monMonthDay=[ivoUtility getDay:self.monday];
	NSString *mondayStr=[ivoUtility createStringFromShortDate:self.monday];
	
	self.tueday=[self.monday dateByAddingTimeInterval:86400];
	self.tueMonthDay=[ivoUtility getDay:self.tueday];
	NSString *tuedayStr=[ivoUtility createStringFromShortDate:self.tueday];
	
	self.wednesday=[self.tueday dateByAddingTimeInterval:86400];
	self.wedMonthDay=[ivoUtility getDay:self.wednesday];
	NSString *month=[ivoUtility createMonthName:self.wednesday];
	self.monthName=month;
	[month release];
	NSString *wednesdayStr=[ivoUtility createStringFromShortDate:self.wednesday];
	
	self.thusday=[self.wednesday dateByAddingTimeInterval:86400];
	self.thuMonthDay=[ivoUtility getDay:self.thusday];
	NSString *thusdayStr=[ivoUtility createStringFromShortDate:self.thusday];
	
	self.friday=[self.thusday dateByAddingTimeInterval:86400];
	self.friMonthDay=[ivoUtility getDay:self.friday];
	NSString *fridayStr=[ivoUtility createStringFromShortDate:self.friday];
	
	self.lastDateInWeek=[self.friday dateByAddingTimeInterval:86400];
	self.satMonthDay=[ivoUtility getDay:self.lastDateInWeek];
	NSString *saturdayStr=[ivoUtility createStringFromShortDate:self.lastDateInWeek];
	
	NSString *firstDateStr=[ivoUtility createStringFromShortDate:self.firstDateInWeek];
	NSString *lastDateStr=[ivoUtility createStringFromShortDate:self.lastDateInWeek];

//	[taskmanager fillRepeatEventInstances:taskmanager.taskList fromDate:[date dateByAddingTimeInterval:-86400] getInstanceUntilDate:[date dateByAddingTimeInterval:7*86400] isShowPastInstances:NO];

	//get adelist
	NSMutableArray *adelist=[[NSMutableArray alloc] init];
	
	for(Task *tmp in list){
		if(tmp.taskPinned==1 && tmp.isAllDayEvent==1){ 
			NSString *taskDateStr=[ivoUtility createStringFromShortDate:tmp.taskStartTime];
			NSString *taskEndStr=[ivoUtility createStringFromShortDate:tmp.taskEndTime];
			if((([firstDateStr compare:taskDateStr]!=NSOrderedDescending && [taskDateStr compare:lastDateStr] !=NSOrderedDescending) ||
				([firstDateStr compare:taskEndStr]==NSOrderedAscending && [taskEndStr compare:lastDateStr] !=NSOrderedDescending) || 
				([firstDateStr compare:taskDateStr]==NSOrderedDescending && [taskEndStr compare:lastDateStr] ==NSOrderedDescending))){
				[adelist addObject:tmp];
			}
			[taskDateStr release];
			[taskEndStr	release];
		}
	}
	[firstDateStr release];
	[lastDateStr release];
	
//	[taskmanager fillRepeatEventInstances:taskmanager.taskList fromDate:[date dateByAddingTimeInterval:-86400] getInstanceUntilDate:[date dateByAddingTimeInterval:7*86400] isShowPastInstances:NO];
	
	NSMutableArray *taskListInWeek=[taskmanager createInspectDisplaylist:list isIncludedADE:NO];

	//NSMutableArray *taskListInWeek=[[NSMutableArray alloc] initWithArray :taskmanager.taskList];
	
	for(Task *tmp in list){
		NSString *taskDateStr=[ivoUtility createStringFromShortDate:tmp.taskStartTime];
		if((tmp.taskPinned==1 && tmp.isAllDayEvent==1)|| [firstDateStr compare:taskDateStr]==NSOrderedDescending || [taskDateStr compare:lastDateStr]==NSOrderedDescending){
			[taskListInWeek removeObject:tmp];	
		}
		[taskDateStr release];
	}
	
	NSMutableArray *sunlist=[[NSMutableArray alloc] init];
	NSMutableArray *monlist=[[NSMutableArray alloc] init];
	NSMutableArray *tuelist=[[NSMutableArray alloc] init];
	NSMutableArray *wedlist=[[NSMutableArray alloc] init];
	NSMutableArray *thulist=[[NSMutableArray alloc] init];
	NSMutableArray *frilist=[[NSMutableArray alloc] init];
	NSMutableArray *satlist=[[NSMutableArray alloc] init];

	for(Task *tmp in taskListInWeek){
		NSString *taskDateStr=[ivoUtility createStringFromShortDate:tmp.taskStartTime];
		if( [taskDateStr isEqualToString:sundayStr]){
			[sunlist addObject:tmp];
		}else if( [taskDateStr isEqualToString:mondayStr]){
			[monlist addObject:tmp];
		}else if( [taskDateStr isEqualToString:tuedayStr]){
			[tuelist addObject:tmp];
		}else if( [taskDateStr isEqualToString:wednesdayStr]){
			[wedlist addObject:tmp];
		}else if( [taskDateStr isEqualToString:thusdayStr]){
			[thulist addObject:tmp];
		}else if( [taskDateStr isEqualToString:fridayStr]){
			[frilist addObject:tmp];
		}else if( [taskDateStr isEqualToString:saturdayStr]){
			[satlist addObject:tmp];
		}

		[taskDateStr release];
	}

	[sundayStr release];
	[mondayStr release];
	[tuedayStr release];
	[wednesdayStr release];
	[thusdayStr release];
	[fridayStr release];
	[saturdayStr release];
		
//	toolbarTitle.text=[NSString stringWithFormat:@"%@ - %@",[ivoUtility getShortStringFromDate:self.firstDateInWeek],[ivoUtility getShortStringFromDate:self.lastDateInWeek]];
	
	self.sunList=sunlist;
	[sunlist release];
	self.monList=monlist;
	[monlist release];
	self.tueList=tuelist;
	[tuelist release];
	self.wedList=wedlist;
	[wedlist release];
	self.thuList=thulist;
	[thulist release];
	self.friList=frilist;
	[frilist release];
	self.satList=satlist;
	[satlist release];
	self.adeList=adelist;
	[adelist release];
	 
	NSTimer *refreshADETimer=[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(refreshADEView) userInfo:nil repeats:NO];
	//[self refreshADEView];
	
	App_Delegate.me.networkActivityIndicatorVisible=NO;
}

-(void)refreshClockDuration{
	double sunDuration=[self usedDurationInDay:self.sunList];
	double monDuration=[self usedDurationInDay:self.monList];
	double tueDuration=[self usedDurationInDay:self.tueList];
	double wedDuration=[self usedDurationInDay:self.wedList];
	double thuDuration=[self usedDurationInDay:self.thuList];
	double friDuration=[self usedDurationInDay:self.friList];
	double satDuration=[self usedDurationInDay:self.satList];
	
	if([sunClockDur superview])
	[sunClockDur removeFromSuperview];
	sunClockDur=[self setImageForClockDuration:sunDuration];
	sunClockDur.frame=CGRectMake(30, 6, 18, 18);
	[sunLabel addSubview:sunClockDur];
	[sunClockDur release];
	
	if([monClockDur superview])
	[monClockDur removeFromSuperview];
	monClockDur=[self setImageForClockDuration:monDuration];
	monClockDur.frame=CGRectMake(44, 6, 18, 18);
	[monLabel addSubview:monClockDur];
	[monClockDur release];
	
	if([tueClockDur superview])
	[tueClockDur removeFromSuperview];
	tueClockDur=[self setImageForClockDuration:tueDuration];
	tueClockDur.frame=CGRectMake(44, 6, 18, 18);
	[tueLabel addSubview:tueClockDur];
	[tueClockDur release];
	
	if([wedClockDur superview])
	[wedClockDur removeFromSuperview];
	wedClockDur=[self setImageForClockDuration:wedDuration];
	wedClockDur.frame=CGRectMake(250, 8, 18, 18);
	[titleView addSubview:wedClockDur];
	[wedClockDur release];
	
	if([thuClockDur superview])
	[thuClockDur removeFromSuperview];
	thuClockDur=[self setImageForClockDuration:thuDuration];
	thuClockDur.frame=CGRectMake(44, 6, 18, 18);
	[thuLabel addSubview:thuClockDur];
	[thuClockDur release];
	
	if([friClockDur superview])
	[friClockDur removeFromSuperview];
	friClockDur=[self setImageForClockDuration:friDuration];
	friClockDur.frame=CGRectMake(38, 6, 18, 18);
	[friLabel addSubview:friClockDur];
	[friClockDur release];
	
	if([satClockDur superview])
	[satClockDur removeFromSuperview];
	satClockDur=[self setImageForClockDuration:satDuration];
	satClockDur.frame=CGRectMake(30, 6, 18, 18);
	[satLabel addSubview:satClockDur];
	[satClockDur release];
	
}

-(UIImageView *)setImageForClockDuration:(double)duration{
	UIImageView *imgView;
	double clockDur=duration/2;
	if(clockDur ==0){
		imgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"00.png"]];
	}else if(clockDur <=1){
		imgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"30.png"]];
	}else if(clockDur <=2){
		imgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"60.png"]];
	}else if(clockDur <=3){
		imgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"90.png"]];
	}else if(clockDur <=4){
		imgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"120.png"]];
	}else if(clockDur <=5){
		imgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"150.png"]];
	}else if(clockDur <=6){
		imgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"180.png"]];
	}else if(clockDur <=7){
		imgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"210.png"]];
	}else if(clockDur <=8){
		imgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"240.png"]];
	}else if(clockDur <=9){
		imgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"270.png"]];
	}else if(clockDur <=10){
		imgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"300.png"]];
	}else if(clockDur <=11){
		imgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"330.png"]];
	}else{
		imgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"360.png"]];
	}
	return imgView;
}

-(void)refreshTableViews{
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	[self setupDisplayList:self.currentDisplayDate];
/*
	sunLabel.text=[NSString stringWithFormat:@"%@    \n  %d      ", sunText,self.sunMonthDay];
	monLabel.text=[NSString stringWithFormat:@"%@  \n %d   ", monText,self.monMonthDay];
	tueLabel.text=[NSString stringWithFormat:@"%@  \n %d   ", tueText,self.tueMonthDay];
*/
	sunLabel.text=[NSString stringWithFormat:@"%d", self.sunMonthDay];
	monLabel.text=[NSString stringWithFormat:@"%d", self.monMonthDay];
	tueLabel.text=[NSString stringWithFormat:@"%d", self.tueMonthDay];
	
	//[monthNameButton setTitle:[self.monthName uppercaseString] forState:UIControlStateNormal];
	[monthNameButton setTitle:self.monthName forState:UIControlStateNormal];
/*	
	thuLabel.text=[NSString stringWithFormat:@"%@  \n %d   ", thuText,self.thuMonthDay];
	friLabel.text=[NSString stringWithFormat:@"%@   \n  %d     ", friText,self.friMonthDay];
	satLabel.text=[NSString stringWithFormat:@"%@        \n  %d          ", satText,self.satMonthDay];
*/
	thuLabel.text=[NSString stringWithFormat:@"%d", self.thuMonthDay];
	friLabel.text=[NSString stringWithFormat:@"%d", self.friMonthDay];
	satLabel.text=[NSString stringWithFormat:@"%d", self.satMonthDay];
		
	/******[self refreshClockDuration];*/

	//NSInteger todayMonthDay=[ivoUtility getDay:[NSDate date]];

	timeFinderView.today = -1; 
/*	
	if( self.sunMonthDay==todayMonthDay){
		sunTableView.backgroundColor=[Colors lightBlue];
	}else {
		sunTableView.backgroundColor=[Colors lavender];
	}
*/
	//if( self.sunMonthDay==todayMonthDay)
	if([ivoUtility compareDateNoTime:self.firstDateInWeek withDate:[NSDate date]] == NSOrderedSame)
	{
		timeFinderView.today = 1;
	}
	
	[sunTableView reloadData];
/*	
	if(self.monMonthDay==todayMonthDay){
		monTableView.backgroundColor=[Colors lightBlue];
	}else {
		monTableView.backgroundColor=[Colors white];
	}
*/
	//if(self.monMonthDay==todayMonthDay)
	if([ivoUtility compareDateNoTime:self.monday withDate:[NSDate date]] == NSOrderedSame)
	{
		timeFinderView.today = 2;
	}
	
	[monTableView reloadData];
/*	
	if(self.tueMonthDay==todayMonthDay){
		tueTableView.backgroundColor=[Colors lightBlue];
	}else {
		tueTableView.backgroundColor=[Colors lavender];
	}
*/
	//if(self.tueMonthDay==todayMonthDay)
	if([ivoUtility compareDateNoTime:self.tueday withDate:[NSDate date]] == NSOrderedSame)
	{
		timeFinderView.today = 3;
	}
	
	[tueTableView reloadData];
/*	
	if( self.wedMonthDay==todayMonthDay){
		wedTableView.backgroundColor=[Colors lightBlue];
	}else {
		wedTableView.backgroundColor=[Colors white];
	}
*/
	//if( self.wedMonthDay==todayMonthDay)
	if([ivoUtility compareDateNoTime:self.wednesday withDate:[NSDate date]] == NSOrderedSame)
	{
		timeFinderView.today = 4;
	}
	
	[wedTableView reloadData];
/*	
	if(self.thuMonthDay==todayMonthDay){
		thuTableView.backgroundColor=[Colors lightBlue];
	}else {
		thuTableView.backgroundColor=[Colors lavender];
	}
*/
	//if(self.thuMonthDay==todayMonthDay)
	if([ivoUtility compareDateNoTime:self.thusday withDate:[NSDate date]] == NSOrderedSame)
	{
		timeFinderView.today = 5;
	}
	
	[thuTableView reloadData];
/*	
	if( self.friMonthDay==todayMonthDay){
		friTableView.backgroundColor=[Colors lightBlue];
	}else {
		friTableView.backgroundColor=[Colors white];
	}
*/
	//if( self.friMonthDay==todayMonthDay)
	if([ivoUtility compareDateNoTime:self.friday withDate:[NSDate date]] == NSOrderedSame)
	{
		timeFinderView.today = 6;
	}
	
	[friTableView reloadData];
/*	
	if( self.satMonthDay==todayMonthDay){
		satTableView.backgroundColor=[Colors lightBlue];
	}else {
		satTableView.backgroundColor=[Colors lavender];
	}
*/
	//if( self.satMonthDay==todayMonthDay)
	if([ivoUtility compareDateNoTime:self.lastDateInWeek withDate:[NSDate date]] == NSOrderedSame)
	{
		timeFinderView.today = 7;
	}
	
	[satTableView reloadData];
	
	App_Delegate.me.networkActivityIndicatorVisible=NO;
}

-(void)refreshADEView{
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	//clean subviews
	NSArray *subs=[headerView subviews];
	
	for(UIView *view in subs){
		[view removeFromSuperview];	
	}
	
	CGFloat maxHeight=0;

	if(adeList.count>0){
		NSDate *startFromDate;
		NSDate *endAtDate;
		
		NSString *firstDateInWeekStr=[ivoUtility createStringFromShortDate:self.firstDateInWeek];
		NSString *lastDateInWeekStr=[ivoUtility createStringFromShortDate:self.lastDateInWeek];
		
		NSMutableArray *recList=[[NSMutableArray alloc] init];
		
		for (NSInteger i=0; i<adeList.count;i++){
			Task *tmp=[adeList objectAtIndex:i];
			
			BOOL isShiftedStartWeek=NO;
			BOOL isShiftedEndWeek=NO;
			
			//get start position for ADE
			NSString *taskStartDateStr=[ivoUtility createStringFromShortDate:tmp.taskStartTime];
			if([taskStartDateStr compare:firstDateInWeekStr]==NSOrderedAscending){
				startFromDate=self.firstDateInWeek;
				isShiftedStartWeek=YES;
			}else {
				startFromDate=tmp.taskStartTime;
			}
			[taskStartDateStr release];
			
			NSInteger positionFromDate=[ivoUtility getWeekday:startFromDate];
			
			//get end position for ADE
			NSString *taskEndDateStr=[ivoUtility createStringFromShortDate:tmp.taskEndTime];
			if([taskEndDateStr compare:lastDateInWeekStr]==NSOrderedDescending){
				endAtDate=self.lastDateInWeek;
				isShiftedEndWeek=YES;
			}else {
				endAtDate=tmp.taskEndTime;
			}
			[taskEndDateStr release];
			
			NSInteger positionToDate=[ivoUtility getWeekday:endAtDate];
			
			//draw ADE into view
			CGRect adeFrame=CGRectMake(2, 2, (positionToDate ==1 && isShiftedStartWeek)? 64:((((positionToDate==7&&isShiftedEndWeek)?8:positionToDate) -positionFromDate)*68 -4), 14);
			
			switch (positionFromDate) {
				case 1://sun
					adeFrame.origin.x=0;
					break;
				case 2://mon
					adeFrame.origin.x=68;
					break;
				case 3://tue
					adeFrame.origin.x=2*68;
					break;
				case 4://wed
					adeFrame.origin.x=3*68;
					break;
				case 5://thu
					adeFrame.origin.x=4*68;
					break;
				case 6://fri
					adeFrame.origin.x=5*68;
					break;
				case 7://sat
					adeFrame.origin.x=6*68;
					break;
			}
			
			
			 CGRect sampleFrame= adeFrame;
			 sampleFrame.size.width=64;

		startSearching:
			 for(CGRectObj *tmp in recList){
				 if(CGRectContainsRect(tmp.rect,sampleFrame)){
					 sampleFrame.origin.y+=sampleFrame.size.height+4;
					 goto startSearching;//researching a gain.
				 }
			 }
			 
			adeFrame.origin.y=sampleFrame.origin.y;

			CGRectObj *rectFrm=[[CGRectObj alloc] init];
			rectFrm.rect=adeFrame;
			
			[recList addObject:rectFrm];
			[rectFrm release];
			
			WeekViewADE *ade=[[WeekViewADE alloc] initWithFrame:adeFrame];
			ade.backgroundColor=[UIColor clearColor];
			ade.adeName=tmp.taskName;
			ade.projectID=tmp.taskProject;
			[ade drawRect:adeFrame];
			[headerView addSubview:ade];
			[ade release];

			maxHeight=(maxHeight<sampleFrame.origin.y+sampleFrame.size.height+4)?sampleFrame.origin.y+sampleFrame.size.height+4:maxHeight;

		}
		
		[recList release];
		
		[headerView setContentSize:CGSizeMake(480, maxHeight)];
	}
	App_Delegate.me.networkActivityIndicatorVisible=NO;
}
-(void)refreshTableViewsSize:(UITableView *)tableView{
	CGRect frm=tableView.frame;
	//[self.view bringSubviewToFront:tableView];
	[pageView bringSubviewToFront:tableView];
	
	previousSelectedWD=selectedWD;
	selectedWD=-1;
	
	//CGFloat offsetY = WEEKVIEW_ADE_HEIGHT + 2;
	CGFloat offsetY = WEEKVIEW_ADE_HEIGHT;
	
	BOOL redrawSkin = NO;
		
	if([tableView isEqual:sunTableView]){
		if(frm.size.width<cellWidth+5){
			//frm.size.width=180;
			frm.size.width = 3*cellWidth + 1;
			selectedWD=1;
		}else {
			//frm.size.width=68;
			frm.size.width=cellWidth + 2;
			
			redrawSkin = YES;
		} 
		tableView.frame=frm;
/*		
		monTableView.frame=CGRectMake(68, 80, 68, 220);
		tueTableView.frame=CGRectMake(136, 80, 68, 220);
		wedTableView.frame=CGRectMake(204, 80, 68, 220);
		thuTableView.frame=CGRectMake(272, 80, 68, 220);
		friTableView.frame=CGRectMake(340, 80, 68, 220);
		satTableView.frame=CGRectMake(408, 80, 72, 220);
*/		
		monTableView.frame=CGRectMake(cellWidth + 2, offsetY, cellWidth, 220);
		tueTableView.frame=CGRectMake(2*cellWidth + 2, offsetY, cellWidth, 220);
		wedTableView.frame=CGRectMake(3*cellWidth + 2, offsetY, cellWidth, 220);
		thuTableView.frame=CGRectMake(4*cellWidth + 2, offsetY, cellWidth, 220);
		friTableView.frame=CGRectMake(5*cellWidth + 2, offsetY, cellWidth, 220);
		satTableView.frame=CGRectMake(6*cellWidth + 2, offsetY, cellWidth + 2, 220);
		
	}else if([tableView isEqual:monTableView]){
		if(frm.size.width<cellWidth+5){
			selectedWD=2;
			//frm.origin.x-=57;
			frm.origin.x-=cellWidth + 2;
			//frm.size.width=180;
			frm.size.width=3*cellWidth + 1;
		}else {
			//frm.origin.x+=57;
			frm.origin.x+=cellWidth + 2;
			//frm.size.width=68;
			frm.size.width=cellWidth;
			redrawSkin = YES;			
		}
		tableView.frame=frm;
/*		
		sunTableView.frame=CGRectMake(0, 80, 68, 220);
		tueTableView.frame=CGRectMake(136, 80, 68, 220);
		wedTableView.frame=CGRectMake(204, 80, 68, 220);
		thuTableView.frame=CGRectMake(272, 80, 68, 220);
		friTableView.frame=CGRectMake(340, 80, 68, 220);
		satTableView.frame=CGRectMake(408, 80, 72, 220);
*/
		sunTableView.frame=CGRectMake(0, offsetY, cellWidth + 2, 220);
		tueTableView.frame=CGRectMake(2*cellWidth + 2, offsetY, cellWidth, 220);
		wedTableView.frame=CGRectMake(3*cellWidth + 2, offsetY, cellWidth, 220);
		thuTableView.frame=CGRectMake(4*cellWidth + 2, offsetY, cellWidth, 220);
		friTableView.frame=CGRectMake(5*cellWidth + 2, offsetY, cellWidth, 220);
		satTableView.frame=CGRectMake(6*cellWidth + 2, offsetY, cellWidth + 2, 220);
		
	}else if([tableView isEqual:tueTableView]){
		if(frm.size.width<cellWidth+5){
			selectedWD=3;
			//frm.origin.x-=57;
			frm.origin.x-=cellWidth-1;
			//frm.size.width=180;
			frm.size.width=3*cellWidth - 2;
		}else {
			//frm.origin.x+=57;
			frm.origin.x+=cellWidth-1;
			//frm.size.width=68;
			frm.size.width=cellWidth;
			redrawSkin = YES;
		}
		tableView.frame=frm;
/*		
		sunTableView.frame=CGRectMake(0, 80, 68, 220);
		monTableView.frame=CGRectMake(68, 80, 68, 220);
		wedTableView.frame=CGRectMake(204, 80, 68, 220);
		thuTableView.frame=CGRectMake(272, 80, 68, 220);
		friTableView.frame=CGRectMake(340, 80, 68, 220);
		satTableView.frame=CGRectMake(408, 80, 72, 220);
*/		
		sunTableView.frame=CGRectMake(0, offsetY, cellWidth + 2, 220);
		monTableView.frame=CGRectMake(cellWidth + 2, offsetY, cellWidth, 220);
		wedTableView.frame=CGRectMake(3*cellWidth + 2, offsetY, cellWidth, 220);
		thuTableView.frame=CGRectMake(4*cellWidth + 2, offsetY, cellWidth, 220);
		friTableView.frame=CGRectMake(5*cellWidth + 2, offsetY, cellWidth, 220);
		satTableView.frame=CGRectMake(6*cellWidth + 2, offsetY, cellWidth + 2, 220);

	}else if([tableView isEqual:wedTableView]){
		if(frm.size.width<cellWidth+5){
			selectedWD=4;
			//frm.origin.x-=57;
			frm.origin.x-=cellWidth-1;
			//frm.size.width=180;
			frm.size.width=3*cellWidth - 2;
		}else {
			//frm.origin.x+=57;
			frm.origin.x+=cellWidth-1;
			//frm.size.width=68;
			frm.size.width=cellWidth;
			redrawSkin = YES;
		}
		tableView.frame=frm;
/*		
		sunTableView.frame=CGRectMake(0, 80, 68, 220);
		monTableView.frame=CGRectMake(68, 80, 68, 220);
		tueTableView.frame=CGRectMake(136, 80, 68, 220);
		thuTableView.frame=CGRectMake(272, 80, 68, 220);
		friTableView.frame=CGRectMake(340, 80, 68, 220);
		satTableView.frame=CGRectMake(408, 80, 72, 220);
*/
		sunTableView.frame=CGRectMake(0, offsetY, cellWidth + 2, 220);
		monTableView.frame=CGRectMake(cellWidth + 2, offsetY, cellWidth, 220);
		tueTableView.frame=CGRectMake(2*cellWidth + 2, offsetY, cellWidth, 220);
		thuTableView.frame=CGRectMake(4*cellWidth + 2, offsetY, cellWidth, 220);
		friTableView.frame=CGRectMake(5*cellWidth + 2, offsetY, cellWidth, 220);
		satTableView.frame=CGRectMake(6*cellWidth + 2, offsetY, cellWidth + 2, 220);
		
	}else if([tableView isEqual:thuTableView]){
		if(frm.size.width<cellWidth+5){
			selectedWD=5;
			//frm.origin.x-=57;
			frm.origin.x-=cellWidth-1;
			//frm.size.width=180;
			frm.size.width=3*cellWidth - 2;
		}else {
			//frm.origin.x+=57;
			frm.origin.x+=cellWidth-1;
			//frm.size.width=68;
			frm.size.width=cellWidth;
			redrawSkin = YES;			
		}
		tableView.frame=frm;
/*		
		sunTableView.frame=CGRectMake(0, 80, 68, 220);
		monTableView.frame=CGRectMake(68, 80, 68, 220);
		tueTableView.frame=CGRectMake(136, 80, 68, 220);
		wedTableView.frame=CGRectMake(204, 80, 68, 220);
		friTableView.frame=CGRectMake(340, 80, 68, 220);
		satTableView.frame=CGRectMake(408, 80, 72, 220);
*/
		sunTableView.frame=CGRectMake(0, offsetY, cellWidth + 2, 220);		
		monTableView.frame=CGRectMake(cellWidth + 2, offsetY, cellWidth, 220);
		tueTableView.frame=CGRectMake(2*cellWidth + 2, offsetY, cellWidth, 220);
		wedTableView.frame=CGRectMake(3*cellWidth + 2, offsetY, cellWidth, 220);
		friTableView.frame=CGRectMake(5*cellWidth + 2, offsetY, cellWidth, 220);
		satTableView.frame=CGRectMake(6*cellWidth + 2, offsetY, cellWidth + 2, 220);
		
	}else if([tableView isEqual:friTableView]){
		if(frm.size.width<cellWidth+5){
			selectedWD=6;
			//frm.origin.x-=57;
			frm.origin.x-=cellWidth-1;
			//frm.size.width=180;
			frm.size.width=3*cellWidth + 1;
		}else {
			//frm.origin.x+=57;
			frm.origin.x+=cellWidth-1;
			//frm.size.width=68;
			frm.size.width=cellWidth;
			redrawSkin = YES;			
		}
		tableView.frame=frm;
/*		
		sunTableView.frame=CGRectMake(0, 80, 68, 220);
		monTableView.frame=CGRectMake(68, 80, 68, 220);
		tueTableView.frame=CGRectMake(136, 80, 68, 220);
		wedTableView.frame=CGRectMake(204, 80, 68, 220);
		thuTableView.frame=CGRectMake(272, 80, 68, 220);
		satTableView.frame=CGRectMake(408, 80, 72, 220);
*/
		sunTableView.frame=CGRectMake(0, offsetY, cellWidth + 2, 220);		
		monTableView.frame=CGRectMake(cellWidth + 2, offsetY, cellWidth, 220);
		tueTableView.frame=CGRectMake(2*cellWidth + 2, offsetY, cellWidth, 220);
		wedTableView.frame=CGRectMake(3*cellWidth + 2, offsetY, cellWidth, 220);
		thuTableView.frame=CGRectMake(4*cellWidth + 2, offsetY, cellWidth, 220);
		satTableView.frame=CGRectMake(6*cellWidth + 2, offsetY, cellWidth + 2, 220);
		
	}else if([tableView isEqual:satTableView]){
		if(frm.size.width<cellWidth+5){
			selectedWD=7;
			//frm.origin.x-=112;
			frm.origin.x-=2*cellWidth-1;
			//frm.size.width=182;
			frm.size.width=3*cellWidth + 1;
		}else {
			//frm.origin.x+=112;
			frm.origin.x+=2*cellWidth-1;
			//frm.size.width=72;
			frm.size.width=cellWidth + 2;
			redrawSkin = YES;			
		}
		tableView.frame=frm;
/*		
		sunTableView.frame=CGRectMake(0, 80, 68, 220);
		monTableView.frame=CGRectMake(68, 80, 68, 220);
		tueTableView.frame=CGRectMake(136, 80, 68, 220);
		wedTableView.frame=CGRectMake(204, 80, 68, 220);
		thuTableView.frame=CGRectMake(272, 80, 68, 220);
		friTableView.frame=CGRectMake(340, 80, 68, 220);
*/
		sunTableView.frame=CGRectMake(0, offsetY, cellWidth + 2, 220);
		monTableView.frame=CGRectMake(cellWidth + 2, offsetY, cellWidth, 220);
		tueTableView.frame=CGRectMake(2*cellWidth + 2, offsetY, cellWidth, 220);
		wedTableView.frame=CGRectMake(3*cellWidth + 2, offsetY, cellWidth, 220);
		thuTableView.frame=CGRectMake(4*cellWidth + 2, offsetY, cellWidth, 220);
		friTableView.frame=CGRectMake(5*cellWidth + 2, offsetY, cellWidth, 220);
	}
	
	//animation
	
	[tableView reloadData];
	
	if(previousSelectedWD>0 && previousSelectedWD != selectedWD){
		switch (previousSelectedWD) {
			case 1:
				[sunTableView reloadData];
				break;
			case 2:
				[monTableView reloadData];
				break;
			case 3:
				[tueTableView reloadData];
				break;
			case 4:
				[wedTableView reloadData];
				break;
			case 5:
				[thuTableView reloadData];
				break;
			case 6:
				[friTableView reloadData];
				break;
			case 7:
				[satTableView reloadData];
				break;
		}
	}
	
	UIColor *darkColor = [UIColor grayColor];
	UIColor *lightColor = [UIColor whiteColor];
	
	if(taskmanager.currentSetting.iVoStyleID==0)
	{
		darkColor = [UIColor grayColor];
		lightColor = [UIColor whiteColor];
	}
	else
	{
		darkColor = [UIColor colorWithRed:(CGFloat)40/255 green:(CGFloat)40/255 blue:(CGFloat)40/255 alpha:1];
		lightColor = [UIColor colorWithRed:(CGFloat)60/255 green:(CGFloat)60/255 blue:(CGFloat)60/255 alpha:1];
	}	
	
	if (redrawSkin)
	{
		tableView.backgroundColor = [UIColor clearColor];
		[self.view bringSubviewToFront:skinView];
	}
	else
	{
		/*if([tableView isEqual:sunTableView] || [tableView isEqual:satTableView])
		{
			tableView.backgroundColor = lightColor;
		}
		else
		{
			tableView.backgroundColor = darkColor;
		}*/
		
		sunTableView.backgroundColor = [UIColor clearColor];
		monTableView.backgroundColor = [UIColor clearColor];
		tueTableView.backgroundColor = [UIColor clearColor];
		wedTableView.backgroundColor = [UIColor clearColor];
		thuTableView.backgroundColor = [UIColor clearColor];
		friTableView.backgroundColor = [UIColor clearColor];
		satTableView.backgroundColor = [UIColor clearColor];
		
		tableView.backgroundColor = [UIColor colorWithRed:0.37 green:0.57 blue:0.9 alpha:1];		
	}
}

-(double)usedDurationInDay:(NSMutableArray *)list{
	NSMutableArray *tmpList=[[NSMutableArray alloc] initWithArray:list];
	for(Task *tmp in list){//clean tasks, keep events only
		if(tmp.taskPinned==0){
			[tmpList removeObject:tmp];	
		}
	}
	
	//clean events that is overlaped by another
	
startInspect:
	if(tmpList.count>1){
		for (NSInteger i=1; i<tmpList.count;i++){
			Task *tmp=[tmpList objectAtIndex:i-1];
			Task *task=[tmpList objectAtIndex:i];
			//
			if([task.taskStartTime compare:tmp.taskStartTime]!=NSOrderedAscending &&[task.taskEndTime compare:tmp.taskEndTime]!=NSOrderedDescending){
				[tmpList removeObject:task];
				goto startInspect;
			}else if([task.taskStartTime compare:tmp.taskStartTime]!=NSOrderedAscending &&[tmp.taskEndTime compare:task.taskStartTime]==NSOrderedDescending){
				tmp.taskEndTime=task.taskEndTime;
				[tmpList removeObject:task];
				goto startInspect;
			}
		}
	}
	
	double duration=0;
	for (Task *tmp in tmpList){
		duration+=[tmp.taskEndTime timeIntervalSinceDate:tmp.taskStartTime];
	}
	
	return duration=duration/3600;
	
}

#pragma mark TouchController
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	
	for (UITouch *touch in touches) {
		CGRect frm=topToolbar.frame;
		frm.origin.x=50;
		frm.size.width-=130;
		if (CGRectContainsPoint(frm, [touch locationInView:self.view])) {
			if(!isPoppedUp){
				[self popUpOptionView];
			}else {
				[self popDownOptionView];
			}
		}	
	}
}

-(void)setupOptionSubView{
	if(self.optSubView==nil){
		UIView *optSubViewTmp=[[UIView alloc] initWithFrame:CGRectMake(0, 40, 480,240)];
		optSubViewTmp.backgroundColor=[UIColor clearColor];
		self.optSubView=optSubViewTmp;
		[optSubViewTmp release];
		
		UILabel *lb=[[UILabel alloc] initWithFrame:CGRectMake(10, 15, 50, 30)];
		lb.text=NSLocalizedString(@"nameText", @"")/*nameText*/;
		lb.backgroundColor=[UIColor clearColor];
		lb.textColor=[UIColor whiteColor];
		[self.optSubView addSubview:lb];
		[lb release];
		
		taskNameTF=[[UITextField alloc] initWithFrame:CGRectMake(60, 15, 150, 30)];
		taskNameTF.placeholder=@"";
		taskNameTF.returnKeyType= UIReturnKeyDone;
		taskNameTF.font=[UIFont systemFontOfSize:16];
		taskNameTF.borderStyle=UITextBorderStyleRoundedRect;
		taskNameTF.delegate=self;
		taskNameTF.clearButtonMode= UITextFieldViewModeWhileEditing;
		taskNameTF.backgroundColor=[UIColor clearColor];
		[self.optSubView addSubview:taskNameTF];
		[taskNameTF release];
		
		toggleLB=[[UILabel alloc] initWithFrame:CGRectMake(220, 15, 80, 30)];
		toggleLB.text=NSLocalizedString(@"startText", @"")/*startText*/;
		toggleLB.backgroundColor=[UIColor clearColor];
		toggleLB.textColor=[UIColor whiteColor];
		[self.optSubView addSubview:toggleLB];
		[toggleLB release];
		
		taskStartBT=[UIButton buttonWithType:UIButtonTypeRoundedRect];
		taskStartBT.frame=CGRectMake(260, 15, 210, 30);
		[taskStartBT addTarget:self action:@selector(startDateSelected:) forControlEvents:UIControlEventTouchUpInside];
		[self.optSubView addSubview:taskStartBT];
		
		homeButton =[self getButton:NSLocalizedString(@"homeText", @"")/*homeText*/
							buttonType:UIButtonTypeCustom
								 frame:CGRectMake(290, 15, 85, 30) 
								target:self 
							  selector:@selector(contextChanged:)
				  normalStateTextColor:[Colors darkSteelBlue]
				selectedStateTextColor:[UIColor whiteColor]];
		[self.optSubView addSubview:homeButton];

		workButton =[self getButton:NSLocalizedString(@"workText", @"")/*workText*/
						 buttonType:UIButtonTypeCustom
							  frame:CGRectMake(385, 15, 85, 30) 
							 target:self 
						   selector:@selector(contextChanged:)
			   normalStateTextColor:[Colors darkSteelBlue]
			 selectedStateTextColor:[UIColor whiteColor]];
		[self.optSubView addSubview:workButton];
		
		
		typeDurLB=[[UILabel alloc] initWithFrame:CGRectMake(10,60, 80, 20)];
		typeDurLB.text=NSLocalizedString(@"durationText", @"")/*durationText*/;
		typeDurLB.backgroundColor=[UIColor clearColor];
		typeDurLB.textColor=[UIColor whiteColor];
		[self.optSubView addSubview:typeDurLB];
		[typeDurLB release];
		
		
		taskButton =[self getButton:NSLocalizedString(@"taskText", @"")/*taskText*/
						 buttonType:UIButtonTypeCustom
							  frame:CGRectMake(100, 60, 85, 30) 
							 target:self 
						   selector:@selector(taskTypeChanged:)
			   normalStateTextColor:[Colors darkSteelBlue]
			 selectedStateTextColor:[UIColor whiteColor]];
		[self.optSubView addSubview:taskButton];
		[taskButton release];
		
		eventButton =[self getButton:NSLocalizedString(@"eventText", @"")/*eventText*/
						 buttonType:UIButtonTypeCustom
							  frame:CGRectMake(195, 60, 85, 30) 
							 target:self 
						   selector:@selector(taskTypeChanged:)
			   normalStateTextColor:[Colors darkSteelBlue]
			 selectedStateTextColor:[UIColor whiteColor]];
		[self.optSubView addSubview:eventButton];
		[eventButton release];
		
		firstIconPeriod=[ivoUtility createButton:@"    30'"
									  buttonType:UIButtonTypeRoundedRect 
										   frame:CGRectMake(100, 60, 85, 30) 
									  titleColor:[Colors darkSteelBlue] 
										  target:self 
										selector:@selector(periodChanged:) 
								normalStateImage:@"1-mash-white.png"
							  selectedStateImage:@"1-mash-blue.png"];
		[firstIconPeriod setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
		//firstIconPeriod.font=[UIFont systemFontOfSize:16];
		[self.optSubView addSubview:firstIconPeriod];
		
		secondIconPeriod=[ivoUtility createButton:@"     1 hr"
									   buttonType:UIButtonTypeRoundedRect 
											frame:CGRectMake(195, 60, 85, 30) 
									   titleColor:[Colors darkSteelBlue]  
										   target:self 
										 selector:@selector(periodChanged:) 
								 normalStateImage:@"2-mash-white.png" 
							   selectedStateImage:@"2-mash-blue.png"];
		[secondIconPeriod setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
		//secondIconPeriod.font=[UIFont systemFontOfSize:16];
		[self.optSubView addSubview:secondIconPeriod];
		
		thirdIconPeriod=[ivoUtility createButton:@"     2 hrs"
									  buttonType:UIButtonTypeRoundedRect 
										   frame:CGRectMake(290, 60, 85, 30) 
									  titleColor:[Colors darkSteelBlue]  
										  target:self 
										selector:@selector(periodChanged:) 
								normalStateImage:@"3-mash-white.png" 
							  selectedStateImage:@"3-mash-blue.png"];
		[thirdIconPeriod setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
		//thirdIconPeriod.font=[UIFont systemFontOfSize:16];
		[self.optSubView addSubview:thirdIconPeriod];
		
		fourthIconPeriod=[ivoUtility createButton:@"     3 hrs"
									   buttonType:UIButtonTypeRoundedRect 
											frame:CGRectMake(385, 60, 85, 30) 
									   titleColor:[Colors darkSteelBlue]  
										   target:self 
										 selector:@selector(periodChanged:) 
								 normalStateImage:@"3-mash-white.png" 
							   selectedStateImage:@"3-mash-blue.png"];
		[fourthIconPeriod setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
		//fourthIconPeriod.font=[UIFont systemFontOfSize:16];
		[self.optSubView addSubview:fourthIconPeriod];
		
		UILabel *lbPr=[[UILabel alloc] initWithFrame:CGRectMake(10,105, 80, 20)];
		lbPr.text=NSLocalizedString(@"projectText", @"")/*projectText*/;
		lbPr.backgroundColor=[UIColor clearColor];
		lbPr.textColor=[UIColor whiteColor];
		[self.optSubView addSubview:lbPr];
		[lbPr release];
		
		noneButton=[self getButton:[[projectList objectAtIndex:0] projName]
						buttonType:UIButtonTypeCustom
							 frame:CGRectMake(100, 105, 85, 30)
							target:self 
						  selector:@selector(projSelected:)
			  normalStateTextColor:[ivoUtility getRGBColorForProject:[[projectList objectAtIndex:0] primaryKey] isGetFirstRGB:NO]
			selectedStateTextColor:[UIColor whiteColor]];
		[self.optSubView addSubview:noneButton];
		[noneButton release];
		
		urgentButton=[self getButton:[[projectList objectAtIndex:1] projName]
						  buttonType:UIButtonTypeCustom
							   frame:CGRectMake(195, 105, 85, 30) 
							  target:self 
							selector:@selector(projSelected:)
				normalStateTextColor:[ivoUtility getRGBColorForProject:[[projectList objectAtIndex:1] primaryKey] isGetFirstRGB:NO]
			  selectedStateTextColor:[UIColor whiteColor]];
		[self.optSubView addSubview:urgentButton];
		[urgentButton release];
		
		privateButton =[self getButton:[[projectList objectAtIndex:2] projName]
							buttonType:UIButtonTypeCustom
								 frame:CGRectMake(290, 105, 85, 30) 
								target:self 
							  selector:@selector(projSelected:)
				  normalStateTextColor:[ivoUtility getRGBColorForProject:[[projectList objectAtIndex:2] primaryKey] isGetFirstRGB:NO]
				selectedStateTextColor:[UIColor whiteColor]];
		[self.optSubView addSubview:privateButton];
		[privateButton release];
		
		projectAButton=[self getButton:[[projectList objectAtIndex:3] projName]	 
							buttonType:UIButtonTypeCustom
								 frame:CGRectMake(385, 105, 85, 30)
								target:self 
							  selector:@selector(projSelected:)
				  normalStateTextColor:[ivoUtility getRGBColorForProject:[[projectList objectAtIndex:3] primaryKey] isGetFirstRGB:NO]
				selectedStateTextColor:[UIColor whiteColor]];
		[self.optSubView addSubview:projectAButton];
		[projectAButton release];
		
		projectBButton=[self getButton:[[projectList objectAtIndex:4] projName]
							buttonType:UIButtonTypeCustom
								 frame:CGRectMake(100, 145, 85, 30) 
								target:self 
							  selector:@selector(projSelected:)
				  normalStateTextColor:[ivoUtility getRGBColorForProject:[[projectList objectAtIndex:4] primaryKey] isGetFirstRGB:NO]
				selectedStateTextColor:[UIColor whiteColor]];
		[self.optSubView addSubview:projectBButton];
		[projectBButton release];
		
		projectCButton=[self getButton:[[projectList objectAtIndex:5] projName]	 
							buttonType:UIButtonTypeCustom
								 frame:CGRectMake(195, 145, 85, 30) 
								target:self 
							  selector:@selector(projSelected:)
				  normalStateTextColor:[ivoUtility getRGBColorForProject:[[projectList objectAtIndex:5] primaryKey] isGetFirstRGB:NO]
				selectedStateTextColor:[UIColor whiteColor]];
		[self.optSubView addSubview:projectCButton];
		[projectCButton release];
		
		////
		project7Button=[self getButton:[[projectList objectAtIndex:6] projName]	 
							buttonType:UIButtonTypeCustom
								 frame:CGRectMake(290, 145, 85, 30)
								target:self 
							  selector:@selector(projSelected:)
				  normalStateTextColor:[ivoUtility getRGBColorForProject:[[projectList objectAtIndex:6] primaryKey] isGetFirstRGB:NO]
				selectedStateTextColor:[UIColor whiteColor]];
		[self.optSubView addSubview:project7Button];
		[project7Button release];
		
		project8Button=[self getButton:[[projectList objectAtIndex:7] projName]
							buttonType:UIButtonTypeCustom
								 frame:CGRectMake(385, 145, 85, 30) 
								target:self 
							  selector:@selector(projSelected:)
				  normalStateTextColor:[ivoUtility getRGBColorForProject:[[projectList objectAtIndex:7] primaryKey] isGetFirstRGB:NO]
				selectedStateTextColor:[UIColor whiteColor]];
		[self.optSubView addSubview:project8Button];
		[project8Button release];
		
		project9Button=[self getButton:[[projectList objectAtIndex:8] projName]	 
							buttonType:UIButtonTypeCustom
								 frame:CGRectMake(100, 185, 85, 30) 
								target:self 
							  selector:@selector(projSelected:)
				  normalStateTextColor:[ivoUtility getRGBColorForProject:[[projectList objectAtIndex:8] primaryKey] isGetFirstRGB:NO]
				selectedStateTextColor:[UIColor whiteColor]];
		[self.optSubView addSubview:project9Button];
		[project9Button release];
		
		project10Button=[self getButton:[[projectList objectAtIndex:9] projName]	 
							 buttonType:UIButtonTypeCustom
								  frame:CGRectMake(195, 185, 85, 30)
								 target:self 
							   selector:@selector(projSelected:)
				   normalStateTextColor:[ivoUtility getRGBColorForProject:[[projectList objectAtIndex:9] primaryKey] isGetFirstRGB:NO]
				 selectedStateTextColor:[UIColor whiteColor]];
		[self.optSubView addSubview:project10Button];
		[project10Button release];
		
		project11Button=[self getButton:[[projectList objectAtIndex:10] projName]
							 buttonType:UIButtonTypeCustom
								  frame:CGRectMake(290, 185, 85, 30) 
								 target:self 
							   selector:@selector(projSelected:)
				   normalStateTextColor:[ivoUtility getRGBColorForProject:[[projectList objectAtIndex:10] primaryKey] isGetFirstRGB:NO]
				 selectedStateTextColor:[UIColor whiteColor]];
		[self.optSubView addSubview:project11Button];
		[project12Button release];
		
		project12Button=[self getButton:[[projectList objectAtIndex:11] projName]	 
							 buttonType:UIButtonTypeCustom
								  frame:CGRectMake(385, 185, 85, 30) 
								 target:self 
							   selector:@selector(projSelected:)
				   normalStateTextColor:[ivoUtility getRGBColorForProject:[[projectList objectAtIndex:11] primaryKey] isGetFirstRGB:NO]
				 selectedStateTextColor:[UIColor whiteColor]];
		[self.optSubView addSubview:project12Button];
		
		[project12Button release];
	}
}

#pragma mark Common methods
-(void)popUpOptionView{
	if(isTransition) return;
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	//if([optionView superview]){
		//[optionView removeFromSuperview];
	//	goto animateView;
	//	return;
	//}
	
	optionView=[[UIView alloc] initWithFrame:CGRectMake(0, WEEKVIEW_TITLE_HEIGHT, 480, 262)];
	optionView.backgroundColor=[UIColor blackColor];
	optionView.alpha=0.8;
	
	
	jumpToDateDP=[[UIDatePicker alloc] initWithFrame:CGRectMake(0, 100, 480,182)];
	[jumpToDateDP addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
	jumpToDateDP.datePickerMode=UIDatePickerModeDate;
	jumpToDateDP.minuteInterval=5;
	
	if ([self.view isKindOfClass:[MonthlyView class]])
	{
		MonthlyView *view = (MonthlyView *) self.view;
		jumpToDateDP.date = view.date;
	} else switch (selectedWD) {
		case -1:
			jumpToDateDP.date=[NSDate date];
			break;
		case 1:
			jumpToDateDP.date=self.firstDateInWeek;
			break;
		case 2:
			jumpToDateDP.date=self.monday;
			break;
		case 3:
			jumpToDateDP.date=self.tueday;
			break;
		case 4:
			jumpToDateDP.date=self.wednesday;
			break;
		case 5:
			jumpToDateDP.date=self.thusday;
			break;
		case 6:
			jumpToDateDP.date=self.friday;
			break;
		case 7:
			jumpToDateDP.date=self.lastDateInWeek;
			break;
	} 
	
	doneButton=[ivoUtility createButton:NSLocalizedString(@"doneButtonText", @"")/*doneButtonText*/ 
							 buttonType:UIButtonTypeCustom
								  frame:CGRectMake(400, 130, 60, 30) 
							 titleColor:[UIColor whiteColor] 
								 target:self 
							   selector:@selector(doneAction:) 
					   normalStateImage:@"blue-small.png" 
					 selectedStateImage:nil];
	[jumpToDateDP addSubview:doneButton];
	[doneButton release];
	
	
	[optionView addSubview: jumpToDateDP];
	[jumpToDateDP release];
	
	leftButton=[ivoUtility createButton:NSLocalizedString(@"todayText", @"")/*todayText*/ 
							 buttonType:UIButtonTypeCustom
								  frame:CGRectMake(20, 10, 60, 30) 
							 titleColor:[UIColor whiteColor] 
								 target:self 
							   selector:@selector(leftAction:) 
					   normalStateImage:@"blue-small.png" 
					 selectedStateImage:nil];
	[optionView addSubview:leftButton];
	[leftButton release];
	
	rightButton=[ivoUtility createButton:NSLocalizedString(@"goText", @"")/*goText*/ 
							  buttonType:UIButtonTypeCustom
								   frame:CGRectMake(400, 10, 60, 30) 
							  titleColor:[UIColor whiteColor] 
								  target:self 
								selector:@selector(rightAction:) 
						normalStateImage:@"blue-small.png" 
					  selectedStateImage:nil];
	[optionView addSubview:rightButton];
	[rightButton release];
	
	NSArray *segBarText = [NSArray arrayWithObjects: NSLocalizedString(@"gotoDateText", @"")/*gotoDateText*/, NSLocalizedString(@"filterText", @"")/*filterText*/,NSLocalizedString(@"quickAddText", @"")/*quickAddText*/, nil];
	segBar = [[UISegmentedControl alloc] initWithItems:segBarText];
	segBar.frame = CGRectMake(100, 10, 280, 30);
	[segBar addTarget:self action:@selector(optStyleChange:) forControlEvents:UIControlEventValueChanged];
	segBar.segmentedControlStyle = UISegmentedControlStyleBar;
	segBar.backgroundColor=[UIColor clearColor];
	if(isFilter){
		segBar.selectedSegmentIndex=1;
	}else {
		segBar.selectedSegmentIndex=0;
	}

	[optionView addSubview:segBar];
	[segBar release];
	
	//[self.containerView addSubview:optionView];
	[self.view addSubview:optionView];
	[optionView release];

animateView:
	{
		//optionView.frame=CGRectMake(0, WEEKVIEW_TITLE_HEIGHT, 480, 262);
		//jumpToDateDP.frame=CGRectMake(0, 100, 480,182);
	
		CATransition *animation = [CATransition animation];
		[animation setDelegate:self];
		
		[animation setType:kCATransitionMoveIn];
		[animation setSubtype:kCATransitionFromTop];
		
		// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
		[animation setDuration:0.3];
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
		
		[[optionView layer] addAnimation:animation forKey:kAnimationKey];	
		
		prevButton.hidden=YES;
		//addNewButton.hidden=NO;
		nextButton.hidden=YES;
		isPoppedUp=YES;
	}
	App_Delegate.me.networkActivityIndicatorVisible=NO;
	
}

-(void)popDownOptionView{
	if(isTransition) return;
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	optionView.frame=CGRectMake(0, 334, 480, 262);

	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	
	[animation setType:kCATransitionReveal];
	[animation setSubtype:kCATransitionFromBottom];
	
	// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
	[animation setDuration:0.3];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[optionView layer] addAnimation:animation forKey:kAnimationKey];	
	
	[optionView removeFromSuperview];
	//addNewButton.hidden=YES;
	prevButton.hidden=NO;
	nextButton.hidden=NO;
	[taskNameTF resignFirstResponder];
	
	isPoppedUp=NO;
	
	//[self popUpDatePicker];
	
	//[optionView removeFromSuperview];
	App_Delegate.me.networkActivityIndicatorVisible=NO;
}

-(void)popUpDatePicker{
	//[optionView ];
	[optionView bringSubviewToFront:jumpToDateDP];
	jumpToDateDP.frame=CGRectMake(0, 100, 480,180);
	
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	
	[animation setType:kCATransitionMoveIn];
	[animation setSubtype:kCATransitionFromTop];
	
	// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
	[animation setDuration:0.3];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[jumpToDateDP layer] addAnimation:animation forKey:kAnimationKey];	

}

-(void)popDownDatePicker{
	jumpToDateDP.frame=CGRectMake(0, 334, 480, 180);

	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	
	[animation setType:kCATransitionReveal];
	[animation setSubtype:kCATransitionFromBottom];
	
	// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
	[animation setDuration:0.3];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[jumpToDateDP layer] addAnimation:animation forKey:kAnimationKey];	

}

- (UIButton *)getButton:(NSString *)title 
			 buttonType:(UIButtonType)buttonType
				  frame:(CGRect)frame
				 target:(id)target
			   selector:(SEL)selector
   normalStateTextColor:(UIColor *)normalStateTextColor
 selectedStateTextColor:(UIColor *)selectedStateTextColor

{
	// create a UIButton with buttonType
	UIButton *button = [[UIButton buttonWithType:buttonType] retain];
	button.frame = frame;
	[button setTitle:title forState:UIControlStateNormal];
	button.font=[UIFont systemFontOfSize:14];
	
	[button setTitleColor:normalStateTextColor forState:UIControlStateNormal];
	[button setTitleColor:selectedStateTextColor forState:UIControlStateSelected];
	
	//button.backgroundColor = [UIColor clearColor];
	[button setBackgroundImage:[[UIImage imageNamed:@"no-mash-white.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[button setBackgroundImage:[[UIImage imageNamed:@"no-mash-blue.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateSelected];
	[button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
	
	return button;
}

#pragma mark transition view
- (void)animationDidStart:(CAAnimation *)animation {
	
	isTransition = YES;
    
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished {
	
	isTransition= NO;
}

#pragma mark TextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
	[self popDownDatePicker];
}

#pragma mark properties

-(NSMutableArray *)sunList{
	return sunList;
}

-(void)setSunList:(NSMutableArray *)arr{
	[sunList release];
	sunList=[[NSMutableArray alloc] initWithArray:arr];
	
}

-(NSMutableArray *)monList{
	return monList;
}

-(void)setMonList:(NSMutableArray *)arr{
	[monList release];
	monList=[[NSMutableArray alloc] initWithArray:arr];
	
}

-(NSMutableArray *)tueList{
	return tueList;
}

-(void)setTueList:(NSMutableArray *)arr{
	[tueList release];
	tueList=[[NSMutableArray alloc] initWithArray:arr];
}

-(NSMutableArray *)wedList{
	return wedList;
}

-(void)setWedList:(NSMutableArray *)arr{
	[wedList release];
	wedList=[[NSMutableArray alloc] initWithArray:arr];
}

-(NSMutableArray *)thuList{
	return thuList;
}

-(void)setThuList:(NSMutableArray *)arr{
	[thuList release];
	thuList=[[NSMutableArray alloc] initWithArray:arr];
}

-(NSMutableArray *)friList{
	return friList;
}

-(void)setFriList:(NSMutableArray *)arr{
	[friList release];
	friList=[[NSMutableArray alloc] initWithArray:arr];
}

-(NSMutableArray *)satList{
	return satList;
}

-(void)setSatList:(NSMutableArray *)arr{
	[satList release];
	satList=[[NSMutableArray alloc] initWithArray:arr];
}

@end
