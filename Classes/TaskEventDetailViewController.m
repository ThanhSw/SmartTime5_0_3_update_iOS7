//
//  TaskEventDetailViewController.m
//  iVo
//
//  Created by Nang Le on 8/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TaskEventDetailViewController.h"
#import "SmartViewController.h"
#import "InfoEditViewController.h"
#import "IvoCommon.h"
#import "ProjectViewController.h"
#import "SmartTimeAppDelegate.h"
#import "Projects.h"
#import "ContactViewConroller.h"
#import "LocationViewController.h"
#import "GeneralListViewController.h"
//#import "AlertViewController.h"
#import "ivo_Utilities.h"
#import "TimeSettingViewController.h"
#import "Colors.h"
#import "WhatViewController.h"
#import "SmartStartView.h"
#import "CalendarView.h"
#import "TableCellTaskDetailTitle.h"
#import "TableCellTaskDetailButton.h"
#import "TableCellWithRightValue.h"
#import "TableCellTaskDetailNotes.h"
#import "DurationViewController.h"
#import "Alert.h"
#import "TableViewCellDetailWhen.h"
#import "TableCellSettingAutoBump.h"
#import "DatePickerViewController.h"
#import "TaskActionResult.h"
#import "SmartTimeAppDelegate.h"
#import "TaskManager.h"
#import "AlertValueViewController.h"

#define kTransitionDuration	0.75
#define kAnimationKey @"transitionViewAnimation"

extern TaskManager *taskmanager;
extern NSMutableArray *projectList;
extern ivo_Utilities	*ivoUtility;
extern NSTimeZone		*App_defaultTimeZone;
extern NSTimeInterval	dstOffset;
extern NSString			*dev_token;

//extern Setting						*currentSetting;
extern NSArray						*contactList;
extern NSMutableArray				*contextList;
extern NSMutableArray				*projectList;
extern NSMutableArray				*alertList;
extern NSMutableArray				*repeatList;
extern TaskManager					*taskmanager;
extern CalendarView					*_calendarView;
extern SmartTimeAppDelegate			*App_Delegate;
extern ivo_Utilities				*ivoUtility;
extern BOOL							isCancelledEditFromDetail;
extern BOOL							isInternetConnected;


//extern NSString *actionMakesItsPassDeadLineText;
//extern NSString *actionMakesOthersPassDeadlinesText;
extern NSString *onDateOfDueText;
extern NSString *onDateOfStartText;

@implementation TaskEventDetailViewController
@synthesize rootViewControler;
@synthesize isUpdatedDue;

//,firstIconPeriod,secondIconPeriod,thirdIconPeriod,whenNone,whenOneWeek,whenOneMonth,
//			contentView,tableView,segmentedTaskStyleControl,segmentedContextControl,whenInfo,taskDate,taskTime,taskDueButton,
//			smartStart,taskTitleTextField,taskLocation,taskNotesTextField,transitioning;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

- (id) init
{
	if (self = [super init])
	{
		isUpdatedDue=NO;
	}
	return self;
}

// Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
	//ILOG(@"[TaskDetailViewController loadView\n");
	
    CGRect frame=[[UIScreen mainScreen] bounds];
    
	UIBarButtonItem *cancelButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem=cancelButton;
	[cancelButton release];
	
	doneButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(done:)];
	self.navigationItem.rightBarButtonItem=doneButton;
	[doneButton release];
	
	contentView=[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	contentView.backgroundColor=[UIColor groupTableViewBackgroundColor];
	
	tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, frame.size.width, frame.size.height-65) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
	tableView.sectionHeaderHeight=10;
	tableView.sectionFooterHeight=0;
	//tableView.scrollEnabled=NO;
	[contentView addSubview:tableView];
	[tableView release];
	
	hintView = [[UIView alloc] initWithFrame:CGRectMake(0, 105, frame.size.width, 336)];
	hintView.backgroundColor = [UIColor colorWithRed:40.0/255 green:40.0/255 blue:40.0/255 alpha:0.8];
	hintView.hidden = (self.keyEdit != 0);
	
	UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 100)];
	hintLabel.textColor = [UIColor whiteColor];
	hintLabel.textAlignment = NSTextAlignmentCenter;
	hintLabel.numberOfLines = 2;
	hintLabel.text = NSLocalizedString(@"titleTipText", @"")/*titleTipText*/;
	hintLabel.backgroundColor = [UIColor clearColor];
	[hintView addSubview:hintLabel];
	
	[hintLabel release];
	
	[contentView addSubview:hintView];
	[hintView release];
	
	self.view=contentView;
	[contentView release];
	//[self setEditing:YES animated:YES];

	//-----------PREPARE FOR TABLE VIEW USE-------------------
	
	//task title
	taskTitleTextField=[[UITextField alloc] initWithFrame:CGRectMake(20, 0, 250, 50)];
	taskTitleTextField.font=[UIFont systemFontOfSize:16];
	taskTitleTextField.textColor=[Colors darkSlateGray];
	taskTitleTextField.keyboardType=UIKeyboardTypeDefault;
	taskTitleTextField.returnKeyType = UIReturnKeyDone;
	taskTitleTextField.placeholder=NSLocalizedString(@"titleGuideText", @"")/*titleGuideText*/;
	taskTitleTextField.textAlignment=NSTextAlignmentLeft;
	taskTitleTextField.backgroundColor=[UIColor clearColor];
	taskTitleTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
	taskTitleTextField.delegate=self;
	
	
	//task Location
	taskLocation=[[UITextField alloc] initWithFrame:CGRectMake(20, 30, 250, 26)];	
	taskLocation.font=[UIFont systemFontOfSize:16];
	taskLocation.textColor=[Colors brown];
	taskLocation.keyboardType=UIKeyboardTypeDefault;
	taskLocation.returnKeyType = UIReturnKeyDone;
	taskLocation.placeholder=NSLocalizedString(@"locationText", @"")/*locationText*/;//@"Location";
	taskLocation.textAlignment=NSTextAlignmentLeft;
	taskLocation.backgroundColor=[UIColor clearColor];
	taskLocation.clearButtonMode=UITextFieldViewModeWhileEditing;
	taskLocation.enabled=NO;
	taskLocation.delegate=self;

	taskNotesTextField=[[UITextField alloc] initWithFrame:CGRectMake(20, 10, 250, 26)];	
	taskNotesTextField.font=[UIFont systemFontOfSize:16];
	taskNotesTextField.textColor=[Colors darkSteelBlue];
	taskNotesTextField.placeholder=NSLocalizedString(@"notesText", @"")/*notesText*/;//@"Notes";
	taskNotesTextField.textAlignment=NSTextAlignmentLeft;
	taskNotesTextField.backgroundColor=[UIColor clearColor];
	taskNotesTextField.enabled=NO;
	taskNotesTextField.delegate=self;
	
	
	//Duration
	howLongInfo=[[UILabel alloc] initWithFrame:CGRectMake(90, 0, 175, 25)];
	howLongInfo.textAlignment=NSTextAlignmentRight;
	howLongInfo.textColor= [Colors darkSteelBlue];
	howLongInfo.backgroundColor=[UIColor clearColor];
	
	//durationButtonView=[[UIView alloc] initWithFrame:CGRectMake(10, 30, 250, 25)];
	durationButtonView=[[UIView alloc] initWithFrame:CGRectMake(10, 25, 250, 25)];
	durationButtonView.backgroundColor=[UIColor clearColor];
	
	//Howlong icons
	firstIconPeriod=[ivoUtility createButton:@"  15'"
									 buttonType:UIButtonTypeRoundedRect 
										  frame:CGRectMake(10, 0, 75, 25) 
									 titleColor:nil 
										 target:self 
										selector:@selector(firstPeriod:) 
								normalStateImage:@"1-mash-white.png"
								selectedStateImage:@"1-mash-blue.png"];
	[firstIconPeriod setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[durationButtonView addSubview:firstIconPeriod];
	[firstIconPeriod release];
	
	secondIconPeriod=[ivoUtility createButton:@"   1 hr"
										buttonType:UIButtonTypeRoundedRect 
											frame:CGRectMake(95, 0, 75, 25) 
										  titleColor:nil 
											  target:self 
											selector:@selector(secondPeriod:) 
									normalStateImage:@"2-mash-white.png" 
								  selectedStateImage:@"2-mash-blue.png"];
	[secondIconPeriod setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[durationButtonView addSubview:secondIconPeriod];
	[secondIconPeriod release];
	
	thirdIconPeriod=[ivoUtility createButton:@"   3 hrs"
									buttonType:UIButtonTypeRoundedRect 
										frame:CGRectMake(180, 0, 75, 25) 
									titleColor:nil 
										target:self 
									selector:@selector(thirdPeriod:) 
							normalStateImage:@"3-mash-white.png" 
							selectedStateImage:@"3-mash-blue.png"];
	[thirdIconPeriod setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[durationButtonView addSubview:thirdIconPeriod];
	[thirdIconPeriod release];

	//task type
	NSArray *segmentTextContent = [NSArray arrayWithObjects: NSLocalizedString(@"taskText", @"")/*taskText*/, NSLocalizedString(@"eventText", @"")/*eventText*/, nil];
	segmentedTaskStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	//segmentedTaskStyleControl.frame = CGRectMake(0, 0, 300, 35);
	segmentedTaskStyleControl.frame = CGRectMake(0, 0, 300, 30);
	[segmentedTaskStyleControl addTarget:self action:@selector(taskStyleAction:) forControlEvents:UIControlEventValueChanged];
	segmentedTaskStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;
	
	//[contentView addSubview:segmentedTaskStyleControl];
	//[segmentedTaskStyleControl release];
	
	//Context
	NSArray *segmentTextContentContext = [NSArray arrayWithObjects: NSLocalizedString(@"hometimeText", @"")/*hometimeText*/, NSLocalizedString(@"worktimeText", @"")/*worktimeText*/, nil];
	segmentedContextControl = [[UISegmentedControl alloc] initWithItems:segmentTextContentContext];
	//segmentedContextControl.frame = CGRectMake(0, 0, 300, 35);
	segmentedContextControl.frame = CGRectMake(0, 0, 300, 30);
	[segmentedContextControl addTarget:self action:@selector(contextAction:) forControlEvents:UIControlEventValueChanged];
	segmentedContextControl.segmentedControlStyle = UISegmentedControlStylePlain;
	//[contentView addSubview:segmentedContextControl];
	//[segmentedContextControl release];
	
	
	durationLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, 30)];
	durationLabel.text=NSLocalizedString(@"durationText", @"Duration")/*durationText*/;//@"Duration";
	durationLabel.backgroundColor=[UIColor clearColor];
	durationLabel.font=[UIFont systemFontOfSize:16];
	durationLabel.textColor=[UIColor darkGrayColor];
	
	editTitleButon=[ivoUtility createButton:@""
										   buttonType:UIButtonTypeDetailDisclosure 
												frame:CGRectMake(270, 0, 40, 60) 
										   titleColor:nil
											   target:self 
											 selector:@selector(editTitle:) 
									 normalStateImage:nil 
								   selectedStateImage:nil];
	
	editHLButon=[ivoUtility createButton:@""
										buttonType:UIButtonTypeDetailDisclosure 
											 frame:CGRectMake(270, 0, 40, 60) 
										titleColor:nil
											target:self 
										  selector:@selector(editDuration:) 
								  normalStateImage:nil 
								selectedStateImage:nil];
	
	allDaySwitch=[[UISwitch alloc] initWithFrame:CGRectMake(210,8, 80, 40)];
	[allDaySwitch addTarget:self action:@selector(setAllDay:) forControlEvents:UIControlEventValueChanged];
	
	dueLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, 30)];
	dueLabel.text=NSLocalizedString(@"dueText", @"Due")/*dueText*/;//@"Due";
	dueLabel.backgroundColor=[UIColor clearColor];
	dueLabel.font=[UIFont systemFontOfSize:16];
	dueLabel.textColor=[UIColor darkGrayColor];
	
	dueInfo=[[UILabel alloc] initWithFrame:CGRectMake(75, 0, 190, 30)];
	dueInfo.backgroundColor=[UIColor clearColor];
	dueInfo.font=[UIFont systemFontOfSize:16];
	dueInfo.textColor=[Colors darkSteelBlue];
	dueInfo.highlightedTextColor=[UIColor whiteColor];
	dueInfo.adjustsFontSizeToFitWidth=YES;
	dueInfo.textAlignment=NSTextAlignmentRight;
	
	
	dueButtonView=[[UIView alloc] initWithFrame:CGRectMake(10, 25, 250, 25)];
	dueButtonView.backgroundColor=[UIColor clearColor];
	
	UIButton *dueToday=[ivoUtility createButton:NSLocalizedString(@"todayText", @"")/*todayText*/
								  buttonType:UIButtonTypeRoundedRect 
									   frame:CGRectMake(10, 0, 75, 25) 
								  titleColor:nil 
									  target:self 
									selector:@selector(selectDue:) 
							normalStateImage:@"no-mash-white.png"
						  selectedStateImage:@"no-mash-blue.png"];
	[dueToday setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[dueButtonView addSubview:dueToday];
	[dueToday release];
	
	UIButton *dueTomorrow=[ivoUtility createButton:NSLocalizedString(@"tomorrowText", @"")/*tomorrowText*/
									 buttonType:UIButtonTypeRoundedRect 
										  frame:CGRectMake(95, 0, 75, 25)  
									 titleColor:nil 
										 target:self 
									   selector:@selector(selectDue:) 
								  normalStateImage:@"no-mash-white.png"
								selectedStateImage:@"no-mash-blue.png"];
	[dueTomorrow setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[dueButtonView addSubview:dueTomorrow];
	[dueTomorrow release];
	
	UIButton *dueNextWeek=[ivoUtility createButton:NSLocalizedString(@"nextweekText", @"")/*nextweekText*/
										buttonType:UIButtonTypeRoundedRect 
											 frame:CGRectMake(180, 0, 75, 25) 
										titleColor:nil 
											target:self 
										  selector:@selector(selectDue:) 
								  normalStateImage:@"no-mash-white.png"
								selectedStateImage:@"no-mash-blue.png"];
	[dueNextWeek setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[dueButtonView addSubview:dueNextWeek];
	[dueNextWeek release];	
	
	editDueButon=[ivoUtility createButton:@""
							  buttonType:UIButtonTypeDetailDisclosure 
								   frame:CGRectMake(270, 0, 40, 60) 
							  titleColor:nil
								  target:self 
								selector:@selector(editDue:) 
						normalStateImage:nil 
					  selectedStateImage:nil];

	startLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, 30)];
	startLabel.text=NSLocalizedString(@"startText", @"Start")/*startText*/;//@"Start";
	startLabel.backgroundColor=[UIColor clearColor];
	startLabel.font=[UIFont systemFontOfSize:16];
	startLabel.textColor=[UIColor darkGrayColor];
	
	startInfo=[[UILabel alloc] initWithFrame:CGRectMake(75, 0, 190, 30)];
	startInfo.backgroundColor=[UIColor clearColor];
	startInfo.font=[UIFont systemFontOfSize:16];
	startInfo.textColor=[Colors darkSteelBlue];
	startInfo.highlightedTextColor=[UIColor whiteColor];
	startInfo.adjustsFontSizeToFitWidth=YES;
	startInfo.textAlignment=NSTextAlignmentRight;
	
	startButtonView=[[UIView alloc] initWithFrame:CGRectMake(10, 25, 250, 25)];
	startButtonView.backgroundColor=[UIColor clearColor];
	
	UIButton *startToday=[ivoUtility createButton:NSLocalizedString(@"todayText", @"")/*todayText*/
									 buttonType:UIButtonTypeRoundedRect 
										  frame:CGRectMake(10, 0, 75, 25) 
									 titleColor:nil 
										 target:self 
									   selector:@selector(selectStart:) 
							   normalStateImage:@"no-mash-white.png"
							 selectedStateImage:@"no-mash-blue.png"];
	[startToday setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[startButtonView addSubview:startToday];
	[startToday release];
	
	UIButton *startTomorrow=[ivoUtility createButton:NSLocalizedString(@"tomorrowText", @"")/*tomorrowText*/
										buttonType:UIButtonTypeRoundedRect 
											 frame:CGRectMake(95, 0, 75, 25)  
										titleColor:nil 
											target:self 
										  selector:@selector(selectStart:) 
								  normalStateImage:@"no-mash-white.png"
								selectedStateImage:@"no-mash-blue.png"];
	[startTomorrow setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[startButtonView addSubview:startTomorrow];
	[startTomorrow release];
	
	UIButton *startNextWeek=[ivoUtility createButton:NSLocalizedString(@"nextweekText", @"")/*nextweekText*/
										buttonType:UIButtonTypeRoundedRect 
											 frame:CGRectMake(180, 0, 75, 25) 
										titleColor:nil 
											target:self 
										  selector:@selector(selectStart:) 
								  normalStateImage:@"no-mash-white.png"
								selectedStateImage:@"no-mash-blue.png"];
	[startNextWeek setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[startButtonView addSubview:startNextWeek];
	[startNextWeek release];	
	
	editStartButon=[ivoUtility createButton:@""
							   buttonType:UIButtonTypeDetailDisclosure 
									frame:CGRectMake(270, 0, 40, 60) 
							   titleColor:nil
								   target:self 
								 selector:@selector(editStart:) 
						 normalStateImage:nil 
					   selectedStateImage:nil];
	
	
	//ILOG(@"TaskDetailViewController loadView]\n");
	
}


/*
 If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad {
}
 */
/*
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}
*/

-(BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
	//return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self refreshFrames];
}

-(void)refreshFrames{
    CGRect frame=[[UIScreen mainScreen] bounds];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        contentView.frame=CGRectMake(0, 0, frame.size.height, frame.size.width);
        tableView.frame=CGRectMake(0, 0, frame.size.height, frame.size.width-50);
        
    }else{
        contentView.frame=CGRectMake(0, 0, frame.size.width, frame.size.height);
        tableView.frame=CGRectMake(0, 0, frame.size.width, frame.size.height);
    }
    
    [tableView reloadData];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
	
	//Trung 08101002
	/*
	//free child view for saving space
	if(whatViewController !=nil)
	{
		[whatViewController release];
		whatViewController=nil;
	}
	
	if(infoEditView !=nil){
		[infoEditView release];
		infoEditView=nil;
	}
	
	if(projectView !=nil){
		[projectView release];
		projectView=nil;
	}
	
	if(generalListView !=nil){
		[generalListView release];
		generalListView=nil;
	}
	
	if(timerView !=nil){
		[timerView release];
		timerView=nil;
	}
	*/
}


- (void)dealloc {

	[taskItem release];
	taskItem=nil;
	
	[segmentedTaskStyleControl removeFromSuperview];
	[segmentedTaskStyleControl release];
	segmentedTaskStyleControl=nil;
	
	[segmentedContextControl removeFromSuperview];
	[segmentedContextControl release];
	segmentedContextControl=nil;
	
	
	//task title
	[taskTitleTextField removeFromSuperview];
	taskTitleTextField.delegate=nil;
	[taskTitleTextField release];
	taskTitleTextField=nil;
	
	[taskLocation removeFromSuperview];
	taskLocation.delegate=nil;
	[taskLocation release];
	taskLocation=nil;
	
	[howLongInfo removeFromSuperview];
	[howLongInfo release];
	howLongInfo=nil;
	
//	[firstIconPeriod removeFromSuperview];
//	[firstIconPeriod release];
//	firstIconPeriod=nil;
	
//	[secondIconPeriod removeFromSuperview];
//	[secondIconPeriod release];
//	secondIconPeriod=nil;
	
//	[thirdIconPeriod removeFromSuperview];
//	[thirdIconPeriod release];
//	thirdIconPeriod=nil;
	
/*	[whenInfo removeFromSuperview];
	[whenInfo release];
	whenInfo=nil;
	
	[taskDate removeFromSuperview];
	[taskDate release];
	taskDate=nil;
	
	[taskDate removeFromSuperview];
	[taskTime release]; 
	taskTime=nil;
	
	[whenNone removeFromSuperview];
	[whenNone release];
	whenNone=nil;
	
	[whenOneWeek removeFromSuperview];
	[whenOneWeek release];
	whenOneWeek=nil;
	
	[whenOneMonth removeFromSuperview];
	[whenOneMonth release];
	whenOneMonth=nil;
	
	[taskDueButton removeFromSuperview];
	[taskDueButton release];
	taskDueButton=nil;
	
	[smartStart removeFromSuperview];
	[smartStart release];
	smartStart=nil;
	
	[smartStartView removeFromSuperview];
	[smartStartView release];
	smartStartView=nil;
*/	
	[oldTaskName release];
	oldTaskName=nil;
	
	[taskNotesTextField removeFromSuperview];
	taskNotesTextField.delegate=nil;
	[taskNotesTextField release];
	taskNotesTextField=nil;
	 
	[rootViewControler release];
	rootViewControler=nil;

	//[tableView removeFromSuperview];
	tableView.delegate=nil;
	tableView.dataSource=nil;
	//[tableView release];
	
	[durationLabel release];
	[durationButtonView release];
	[editTitleButon release];
	[editHLButon release];
//	[editWhenButon release];
	
//	[repeatInfo release];
	
	//[contentView release];
	//contentView=nil;
	[allDaySwitch release];
	
	[dueLabel release];
	[dueInfo release];
	[dueButtonView release];
	[editDueButon release];

	[startLabel release];
	[startInfo release];
	[startButtonView release];
	[editStartButon release];
	
	[super dealloc];
}


#pragma mark controller delegate
// called after this controller's view will appear
- (void)viewWillAppear:(BOOL)animated
{	
	//ILOG(@"[TaskDetailViewController viewWillAppear\n");
	//settting default values
    
    [self refreshFrames];
	if(self.taskItem.taskName!=nil && ![self.taskItem.taskName isEqualToString:@""]){
		doneButton.enabled=YES;
		hintView.hidden = YES;
	}else {
		doneButton.enabled=NO;
	}

	
	if(!isUpdatedDue && (self.taskItem.taskDueStartDate==nil || [ivoUtility getYear:self.taskItem.taskDueStartDate]==1970 ||keyEdit==0 /*||keyEdit==2*/)){
		self.taskItem.taskDueStartDate=[NSDate date];
		self.taskItem.taskDueEndDate=[self.taskItem.taskDueStartDate dateByAddingTimeInterval:93312000];//3 years
	}
	
	isUpdatedDue=YES;
	
	//settting default values
	if((self.taskItem.taskStartTime==nil || [ivoUtility getYear:self.taskItem.taskStartTime]==1970)&& self.keyEdit==0){
	//if(self.keyEdit==0){
		self.taskItem.taskStartTime=[[NSDate date] dateByAddingTimeInterval:(3600- [ivoUtility getMinute:[NSDate date]]*60)];
	}
	NSDate *endtime=[self.taskItem.taskStartTime dateByAddingTimeInterval:[self.taskItem taskHowLong]];
	self.taskItem.taskEndTime=endtime;
	
	//reset title bar
	[self refreshTitleBarName];
	
	[self refreshTaskTitle:self.taskItem.taskWhat];
	//[self refreshTaskWhen];
	
	segmentedTaskStyleControl.selectedSegmentIndex = self.taskItem.taskPinned;
	segmentedContextControl.selectedSegmentIndex=self.taskItem.taskWhere;
	
	allDaySwitch.on=self.taskItem.isAllDayEvent;
	
	[self performSelector:@selector(setAllDay:) withObject:nil];
	
	
	//[tableView reloadData];
	
	
	[self setEditing:YES animated:NO];
		
	//ILOG(@"TaskDetailViewController viewWillAppear]\n");
}

-(void)popupSmartStartView{
    CGRect frame=[[UIScreen mainScreen] bounds];
	if(![smartStartView superview]){
		smartStartView=[[SmartStartView alloc] initWithFrame:CGRectMake(0, frame.size.height-40-60, 320, 40) ];
		
		smartStart=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
		smartStart.textColor=[UIColor yellowColor];
		smartStart.textAlignment=NSTextAlignmentCenter;
		smartStart.font=[UIFont systemFontOfSize:14];
		smartStart.backgroundColor=[UIColor clearColor];
		NSString *smartDateStr=[ivoUtility createStringFromDate:self.taskItem.taskStartTime isIncludedTime:YES];
		
		smartStart.text=[NSLocalizedString(@"suggestedTimeText", @"")/*suggestedTimeText*/ stringByAppendingString:smartDateStr];
		[smartDateStr release];
		
		[smartStartView addSubview:smartStart];
		[smartStart release];
	}
	
	if(![smartStartView superview]){
		[contentView addSubview:smartStartView];
		[smartStartView release];
	}
	//smartStartView.hidden=NO;
	
	// Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	isPopingDownSmartStartView=NO;
	
	[animation setType:kCATransitionMoveIn];
	[animation setSubtype:kCATransitionFromTop];

	// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
	[animation setDuration:kTransitionDuration];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[smartStartView layer] addAnimation:animation forKey:kAnimationKey];	
}

-(void)popDownSmartStartView{
    CGRect frame=[[UIScreen mainScreen] bounds];
	if([smartStartView superview]){
		//[smartStartView removeFromSuperview];

//		[smartStartView removeFromSuperview];
//		smartStartView=nil;
		smartStartView.frame=CGRectMake(0, frame.size.height, 320, 40);
		isPopingDownSmartStartView=YES;
		// Set up the animation
		CATransition *animation = [CATransition animation];
		[animation setDelegate:self];
	
		[animation setType:kCATransitionReveal];
		[animation setSubtype:kCATransitionFromBottom];
	
		// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
		[animation setDuration:kTransitionDuration];
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
		[[smartStartView layer] addAnimation:animation forKey:kAnimationKey];
		//smartStartView.hidden=YES;
		
		//while (transitioning) {
		//}
		
		//[smartStart removeFromSuperview];
		//[smartStart release];
		//smartStart=nil;
	}
}

-(void)viewDidAppear:(BOOL)animated{
	//show Smart Start
	if(self.taskItem.taskPinned==0 && self.taskItem.primaryKey>0 && self.taskItem.taskStartTime !=nil){
		[self popupSmartStartView];
	}
	
	if(!self.taskItem.taskName || [self.taskItem.taskName isEqualToString:@""]){
		[taskTitleTextField becomeFirstResponder];
	}
}

-(void)viewWillDisappear:(BOOL)animated{
	[taskTitleTextField resignFirstResponder];
	[self popDownSmartStartView];
	//[smartStartView removeFromSuperview];
	//smartStartView=nil;
}

-(void)viewDidDisappear:(BOOL)animated{
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
}

#pragma mark Touch handler

 // Handles the start of a touch
 - (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
 {
	 //ILOG(@"[InfoEditViewController touchesBegan\n");
	 // Enumerate through all the touch objects.
	 NSUInteger touchCount = 0;
	 for (UITouch *touch in touches) {
		 // Send to the dispatch method, which will make sure the appropriate subview is acted upon
		[self dispatchFirstTouchAtPoint:[touch locationInView:smartStartView] forEvent:nil];
		 touchCount++;  
	 }	
	 //ILOG(@"InfoEditViewController touchesBegan]\n");
 }
 
-(void) dispatchFirstTouchAtPoint:(CGPoint)touchPoint forEvent:(UIEvent *)event
{
	if (CGRectContainsPoint([smartStart frame], touchPoint)) {
		[self popDownSmartStartView];
		
		//while (transitioning) {
		//}
	}
	
}

#pragma mark action methods

-(void)cancel:(id)sender{

	isCancelledEditFromDetail=YES;

	[taskTitleTextField resignFirstResponder];
	
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)updateAlertsToServerForTask:(id)sender{
	NSTimer *tmr=(NSTimer*)sender;
	Task *task=[tmr userInfo];
	
	if([task.PNSKey length]==0 && task.taskPinned==0) return;

	/*
	NSString *alertPNSStr=[ivoUtility getAPNSAlertFromTask:task];
	
	
	if(self.keyEdit==0||self.keyEdit==2){//new task 
		//we need to reset these pair values because it may contains some old values from duplicated
		if([task.taskAlertValues length]==0 || task.taskPinned==0){
			task.taskAlertValues=@"";
			task.PNSKey=@"";
			return;
		}else {
			//new alert values has just added
			if([alertPNSStr length]==0) return;
				
			task.PNSKey=[[NSDate date] description];
			//[ivoUtility uploadAlertsForTasks:task isAddNew:YES withPNSAlert:alertPNSStr oldDevToken:dev_token newTaskPNSID:task.PNSKey];
		}

	}else {//update
		if([task.PNSKey length]>0){//had updated to server before
			if(task.taskPinned==1){//alert for event
				//update to server here
				if([alertPNSStr length]==0){
					[ivoUtility deleteAlertsOnServerForTasks:task];
				}else {
					[ivoUtility uploadAlertsForTasks:task isAddNew:NO withPNSAlert:alertPNSStr oldDevToken:dev_token newTaskPNSID:task.PNSKey];
				}
				
			}else if(task.taskPinned==0){//changed Events that has set alert to Task, clean all in local and clean on server too
				//clean on server here first
				[ivoUtility deleteAlertsOnServerForTasks:task];
				
				//clean on local here later
				task.taskAlertValues=@"";
				task.PNSKey=@"";
				return;
			}
		}else { 
			if([self.taskItem.taskAlertValues length]>0) {
				//new alert values has just added for the updated event
				if([alertPNSStr length]==0) return;
					
				task.PNSKey=[[NSDate date] description];
				[ivoUtility uploadAlertsForTasks:self.taskItem isAddNew:YES withPNSAlert:alertPNSStr ];
			}
		}
	}
	*/
	
	[task update];
}

-(void)done:(id)sender{
	//ILOG(@"[TaskDetailViewController done\n");
	
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	[taskTitleTextField resignFirstResponder];
	
	[ivoUtility inspectPinnedTaskDate:self.taskItem];
	
	//set update type
	if(self.keyEdit==0||self.keyEdit==2){
		self.taskItem.taskTypeUpdate=0;	
	}else {
		self.taskItem.taskTypeUpdate=1;	
	}
	
	//Task *task = self.taskItem;
	
	//self.taskItem.isUsedExternalUpdateTime=NO;
	
	//check validation before save
	TaskActionResult *checkTaskResult=nil;
	
	if(self.taskItem.taskPinned==1){
		//checkTaskResult=[ivoUtility smartCheckValidationTask:self.taskItem inTaskList:taskmanager.taskList checkFromDate:self.taskItem.taskStartTime];
	}else {
		//checkTaskResult=[ivoUtility smartCheckValidationTask:self.taskItem inTaskList:taskmanager.taskList checkFromDate:self.taskItem.taskDueStartDate];
	}
	
	checkTaskResult=[ivoUtility smartCheckValidationTask:self.taskItem inTaskList:taskmanager.taskList];
	
	//show some based errors (if any) before saving
	if(checkTaskResult.errorNo !=-1 && checkTaskResult.errorNo !=ERR_TASK_START_OVERLAPPED && 
	   checkTaskResult.errorNo !=ERR_TASK_END_OVERLAPPED && 
	   checkTaskResult.errorNo !=ERR_TASK_OVERLAPS_OTHERS){
		if(self.taskItem.taskPinned==1 || (self.taskItem.taskPinned==0 && checkTaskResult.errorNo <= ERR_TASK_DURATION_TOO_LONG)){
			[self callAlert:checkTaskResult.errorMessage];
			
			[checkTaskResult release];
			goto exitDone;
		}
	}
	
	[checkTaskResult release];
	
	if (self.keyEdit==0||self.keyEdit==2){//add new or duplicate
		
		self.taskItem.isNeedAdjustDST=1;//for version 3.5 or later
		self.taskItem.taskREStartTime=self.taskItem.taskStartTime;
		
		checkTaskResult=[taskmanager addNewTask:self.taskItem toArray:taskmanager.taskList isAllowChangeDueWhenAdd:NO];
		if(checkTaskResult.errorNo==1){
			[self callAlert:checkTaskResult.errorMessage];
			
			[checkTaskResult release];
			
			goto exitDone;
		}else if(checkTaskResult.errorNo==ERR_TASK_ITSELF_PASS_DEADLINE) {//overdeadline time slot found
			//increase due of task to the next day of the date when time slot found
			[checkTaskResult release];
			
			//alertViewAddPassedDue = [[UIAlertView alloc] initWithTitle:@"Your deadline will not fit. Too busy? Change deadline?" message:nil delegate:self cancelButtonTitle:manuallyText otherButtonTitles:nil];
			alertViewAddPassedDue = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"actionMakesItsPassDeadLineText", @"")/*actionMakesItsPassDeadLineText*/ message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"manuallyText", @"")/*manuallyText*/ otherButtonTitles:nil];
			[alertViewAddPassedDue addButtonWithTitle:NSLocalizedString(@"automaticallyText", @"")/*automaticallyText*/];
			[alertViewAddPassedDue show];
			[alertViewAddPassedDue release];
			return;
		}else if(checkTaskResult.errorNo==ERR_TASK_ANOTHER_PASS_DEADLINE){
			[checkTaskResult release];
			
			//alertViewAddEventTaskPassedDue = [[UIAlertView alloc] initWithTitle:@"This will cause some existing tasks to pass their deadlines. Change those deadlines automatically?" message:nil delegate:self cancelButtonTitle:cancelText otherButtonTitles:nil];
			alertViewAddEventTaskPassedDue = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"actionMakesOthersPassDeadlinesText", @"")/*actionMakesOthersPassDeadlinesText*/ message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancelText", @"")/*cancelText*/ otherButtonTitles:nil];
			
			[alertViewAddEventTaskPassedDue addButtonWithTitle:NSLocalizedString(@"yesText", @"")/*yesText*/];
			[alertViewAddEventTaskPassedDue show];
			[alertViewAddEventTaskPassedDue release];
			goto exitDone;
		}else if(checkTaskResult.errorNo==ERR_OVER_MAX_TRIAL_TASK) {
			[checkTaskResult release];
			
			//alertViewAddEventTaskPassedDue = [[UIAlertView alloc] initWithTitle:@"This will cause some existing tasks to pass their deadlines. Change those deadlines automatically?" message:nil delegate:self cancelButtonTitle:cancelText otherButtonTitles:nil];
			UIAlertView *taskOverTrialNumberAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"overMaxTrialTaskText", @"")/*overMaxTrialTaskText*/ message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"dismissText", @"")/*dismissText*/ otherButtonTitles:nil];
			
			[taskOverTrialNumberAlert show];
			[taskOverTrialNumberAlert release];
			goto exitDone;
		}else if(checkTaskResult.errorNo==ERR_RE_MAKE_TASK_NOT_BE_FIT) {
			UIAlertView	*REMakeTaskNotFitAlert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"REMakeTaskNotFitText", @"")/*REMakeTaskNotFitText*/  message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/ otherButtonTitles:nil];
			
			[REMakeTaskNotFitAlert show];
			[REMakeTaskNotFitAlert release];
			goto exitDone;
		}else if(checkTaskResult.errorNo==ERR_TASK_NOT_BE_FIT_BY_RE) {
			UIAlertView	*taskNotBeFitByREAlert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"taskNotBeFitByREText", @"")/*taskNotBeFitByREText*/  message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/ otherButtonTitles:nil];
			
			[taskNotBeFitByREAlert show];
			[taskNotBeFitByREAlert release];
			goto exitDone;
		}

		
		
		//add success
		self.rootViewControler.newTaskPrimaryKey=checkTaskResult.taskPrimaryKey;
		self.rootViewControler.isAddNew=YES;
		
		//find the new task in the task list and update alert to the server if any
		//if(self.taskItem.isChangedAlertSetting){
//			Task *tsk=[ivoUtility getTaskByPrimaryKey:checkTaskResult.taskPrimaryKey inArray:taskmanager.taskList];
//			[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(updateAlertsToServerForTask:) userInfo:tsk repeats:NO];
		//}
		////////////////////////////////////////////
		
		[checkTaskResult release];		
	}else {//update a task
		Task *original=[ivoUtility getTaskByPrimaryKey:taskItem.primaryKey inArray:taskmanager.taskList];
		if([self.taskItem isEqualToTask:original]){
			[self.navigationController popViewControllerAnimated:YES];
			return;
		}
		if(taskItem.taskPinned==1 && (taskItem.taskRepeatID>0 || (original.taskPinned==1 && original.taskRepeatID>0))){
			
			if(//![original.taskEndRepeatDate isEqualToDate: taskItem.taskEndRepeatDate] ||
				original.taskRepeatTimes !=taskItem.taskRepeatTimes||
				original.taskNumberInstances !=taskItem.taskNumberInstances ||
			    original.taskRepeatID !=taskItem.taskRepeatID || original.taskProject!=taskItem.taskProject ||
				(original.taskRepeatID==taskItem.taskRepeatID && ![original.taskRepeatOptions isEqualToString:taskItem.taskRepeatOptions])){
				
				if(original.taskRepeatID !=taskItem.taskRepeatID || (![original.taskEndRepeatDate isEqualToDate: taskItem.taskEndRepeatDate] && taskItem.taskRepeatTimes!=0 && taskItem.taskNumberInstances!=0)){//change from another task/event to RE
					if(taskItem.primaryKey>=0){
						taskItem.taskREStartTime=taskItem.taskStartTime;
						if([taskItem.taskEndRepeatDate compare:taskItem.taskEndTime]==NSOrderedAscending){
							taskItem.taskEndRepeatDate= taskItem.taskEndTime;
						}
					}
					
					if(![original.taskEndRepeatDate isEqualToDate: taskItem.taskEndRepeatDate] && taskItem.taskRepeatTimes!=0 && taskItem.taskNumberInstances!=0){
						repeatCountTime ret=[ivoUtility createRepeatCountFromEndDate:taskItem.taskREStartTime 
																	  typeRepeat:taskItem.taskRepeatID 
																		  toDate:taskItem.taskEndRepeatDate 
																repeatOptionsStr:taskItem.taskRepeatOptions
																		 reStartDate:taskItem.taskREStartTime];
						taskItem.taskNumberInstances=ret.numberOfInstances;
						taskItem.taskRepeatTimes=ret.repeatTimes;
					}
				}
				self.typeEdit=0;
				
			}
		}else if(original.taskPinned !=taskItem.taskPinned && (original.taskRepeatID >0 || original.parentRepeatInstance >-1)){
			UIAlertView *wrongChangeAlert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"editRETitleText", @"")/*editRETitleText*/ message:NSLocalizedString(@"wrongChangeREText", @"")/*wrongChangeREText*/ delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/ otherButtonTitles:nil];
			[wrongChangeAlert show];
			[wrongChangeAlert release];
			goto exitDone;
		}
		
		if(self.typeEdit==1 && original.taskPinned==1) {
                editREInstanceAlert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"editRETitleText", @"")/*editRETitleText*/  message:NSLocalizedString(@"editREInstanceText", @"")/*editREInstanceText*/ delegate:self cancelButtonTitle:NSLocalizedString(@"cancelText", @"")/*cancelText*/ otherButtonTitles:nil];
                [editREInstanceAlert addButtonWithTitle:NSLocalizedString(@"onlyInsText", @"")/*onlyInsText*/];
                [editREInstanceAlert addButtonWithTitle:NSLocalizedString(@"allEventsText", @"")/*allEventsText*/];
                [editREInstanceAlert addButtonWithTitle:NSLocalizedString(@"allInsFollowText", @"")/*allInsFollowText*/];
                [editREInstanceAlert show];
                [editREInstanceAlert release];
                goto exitDone;
            
		}else {
			checkTaskResult=[taskmanager updateTask:self.taskItem isAllowChangeDueWhenUpdate:NO updateREType:2 REUntilDate:self.taskItem.taskEndTime updateTime:nil];
			if(checkTaskResult.errorNo==ERR_TASK_ANOTHER_PASS_DEADLINE){
				[checkTaskResult release];
				
				alertViewUpdateTasksPassedDue = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"actionMakesOthersPassDeadlinesText", @"")/*actionMakesOthersPassDeadlinesText*/ message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancelText", @"")/*cancelText*/ otherButtonTitles:nil];
				[alertViewUpdateTasksPassedDue addButtonWithTitle:NSLocalizedString(@"yesText", @"")/*yesText*/];
				[alertViewUpdateTasksPassedDue show];
				[alertViewUpdateTasksPassedDue release];
				goto exitDone;
				
			}else if(checkTaskResult.errorNo==ERR_TASK_ITSELF_PASS_DEADLINE){
				if(checkTaskResult.overdueTimeSlotFound!=nil){
					//self.taskItem.taskStartTime=checkTaskResult.overdueTimeSlotFound;
					//self.taskItem.taskEndTime=[checkTaskResult.overdueTimeSlotFound addTimeInterval:self.taskItem.taskHowLong] ;
					//self.taskItem.taskDueEndDate=self.taskItem.taskEndTime;
				}
				[checkTaskResult release];
				
				//alertViewUpdateItselfPassedDue = [[UIAlertView alloc] initWithTitle:@"Your deadline will not fit. Too busy? Change deadline?" message:nil delegate:self cancelButtonTitle:manuallyText otherButtonTitles:nil];
				alertViewUpdateItselfPassedDue = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"actionMakesItsPassDeadLineText", @"")/*actionMakesItsPassDeadLineText*/ message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"manuallyText", @"")/*manuallyText*/ otherButtonTitles:nil];
				[alertViewUpdateItselfPassedDue addButtonWithTitle:NSLocalizedString(@"automaticallyText", @"")/*automaticallyText*/];
				[alertViewUpdateItselfPassedDue show];
				[alertViewUpdateItselfPassedDue release];
				goto exitDone;
			}else if(checkTaskResult.errorNo==ERR_RE_MAKE_TASK_NOT_BE_FIT) {
				UIAlertView	*REMakeTaskNotFitAlert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"REMakeTaskNotFitText", @"")/*REMakeTaskNotFitText*/  message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/ otherButtonTitles:nil];
				
				[REMakeTaskNotFitAlert show];
				[REMakeTaskNotFitAlert release];
				goto exitDone;
			}else if(checkTaskResult.errorNo==ERR_TASK_NOT_BE_FIT_BY_RE) {
				UIAlertView	*taskNotBeFitByREAlert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"taskNotBeFitByREText", @"")/*taskNotBeFitByREText*/  message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/ otherButtonTitles:nil];
				
				[taskNotBeFitByREAlert show];
				[taskNotBeFitByREAlert release];
				goto exitDone;
			}
			
			[checkTaskResult release];
		}
		
		//if(self.taskItem.isChangedAlertSetting || (original.taskPinned != self.taskItem.taskPinned && [original.PNSKey length]>0)){
//			Task *tsk=[ivoUtility getTaskByPrimaryKey:self.taskItem.primaryKey inArray:taskmanager.taskList];
//			[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(updateAlertsToServerForTask:) userInfo:tsk repeats:NO];
		//}
		
	}
	
//	[App_Delegate stopAcitivityIndicatorThread];
	//exit when no error
	//[self updateAlertsToServerForTask:nil];		

	
	[self.navigationController popViewControllerAnimated:YES];
	
exitDone:
	App_Delegate.me.networkActivityIndicatorVisible=NO;
	
	//[ivoUtility printTask:taskmanager.taskList];
//	[App_Delegate stopAcitivityIndicatorThread];
	//ILOG(@"TaskDetailViewController done\n");
}

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex{
	//ILOG(@"[TaskDetailViewController clickedButtonAtIndex\n");
	
	TaskActionResult *checkTaskResult=nil;
	if([alertVw isEqual:alertViewAddPassedDue] && buttonIndex==1){
	//re-search timeslot here
		 checkTaskResult=[taskmanager addNewTask:self.taskItem toArray:taskmanager.taskList isAllowChangeDueWhenAdd:YES];
	}else if([alertVw isEqual:alertViewAddEventTaskPassedDue] && buttonIndex==1){
		 checkTaskResult=[taskmanager addNewTask:self.taskItem toArray:taskmanager.taskList isAllowChangeDueWhenAdd:YES];
	}else if([alertVw isEqual:alertViewUpdateTasksPassedDue] && buttonIndex==1){
		if(taskItem.taskRepeatID>0 && self.typeEdit != 0){
			checkTaskResult=[taskmanager updateTask:self.taskItem isAllowChangeDueWhenUpdate:YES updateREType:currentREEditType REUntilDate:self.taskItem.taskStartTime updateTime:nil];
		}else {
			checkTaskResult=[taskmanager updateTask:self.taskItem isAllowChangeDueWhenUpdate:YES updateREType:-1 REUntilDate:self.taskItem.taskStartTime updateTime:nil];
		}

	}else if([alertVw isEqual:alertViewUpdateItselfPassedDue] && buttonIndex==1){
		if(taskItem.taskRepeatID>0 && self.typeEdit != 0){
			checkTaskResult=[taskmanager updateTask:self.taskItem isAllowChangeDueWhenUpdate:YES updateREType:currentREEditType REUntilDate:self.taskItem.taskStartTime updateTime:nil];
		}else {
			checkTaskResult=[taskmanager updateTask:self.taskItem isAllowChangeDueWhenUpdate:YES updateREType:-1 REUntilDate:self.taskItem.taskStartTime updateTime:nil];
		}
		
	}else if([alertVw isEqual:editREInstanceAlert] && buttonIndex !=0) {
		currentREEditType=buttonIndex;
		 checkTaskResult=[taskmanager updateTask:self.taskItem isAllowChangeDueWhenUpdate:NO updateREType:buttonIndex REUntilDate:self.taskItem.taskStartTime updateTime:nil];
		if(checkTaskResult.errorNo==ERR_TASK_ANOTHER_PASS_DEADLINE){
			//[checkTaskResult release];
			
			alertViewUpdateTasksPassedDue = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"actionMakesOthersPassDeadlinesText", @"")/*actionMakesOthersPassDeadlinesText*/ message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancelText", @"")/*cancelText*/ otherButtonTitles:nil];
			[alertViewUpdateTasksPassedDue addButtonWithTitle:NSLocalizedString(@"yesText", @"")/*yesText*/];
			[alertViewUpdateTasksPassedDue show];
			[alertViewUpdateTasksPassedDue release];
			//goto exitDone;
			
		}else if(checkTaskResult.errorNo==ERR_TASK_ITSELF_PASS_DEADLINE){
			//[checkTaskResult release];
			
			//alertViewUpdateItselfPassedDue = [[UIAlertView alloc] initWithTitle:@"Your deadline will not fit. Too busy? Change deadline?" message:nil delegate:self cancelButtonTitle:manuallyText otherButtonTitles:nil];
			alertViewUpdateItselfPassedDue = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"actionMakesItsPassDeadLineText", @"")/*actionMakesItsPassDeadLineText*/ message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"manuallyText", @"")/*manuallyText*/ otherButtonTitles:nil];
			[alertViewUpdateItselfPassedDue addButtonWithTitle:NSLocalizedString(@"automaticallyText", @"")/*automaticallyText*/];
			[alertViewUpdateItselfPassedDue show];
			[alertViewUpdateItselfPassedDue release];
			//goto exitDone;
		}else if(checkTaskResult.errorNo==ERR_RE_MAKE_TASK_NOT_BE_FIT) {
			UIAlertView	*REMakeTaskNotFitAlert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"REMakeTaskNotFitText", @"")/*REMakeTaskNotFitText*/  message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/ otherButtonTitles:nil];
			
			[REMakeTaskNotFitAlert show];
			[REMakeTaskNotFitAlert release];
			//goto exitDone;
		}else if(checkTaskResult.errorNo==ERR_TASK_NOT_BE_FIT_BY_RE) {
			UIAlertView	*taskNotBeFitByREAlert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"taskNotBeFitByREText", @"")/*taskNotBeFitByREText*/  message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/ otherButtonTitles:nil];
			
			[taskNotBeFitByREAlert show];
			[taskNotBeFitByREAlert release];
			//goto exitDone;
		}
	}else {
		return;
	}


	
//	[App_Delegate stopAcitivityIndicatorThread];
	
	if(checkTaskResult.errorNo==-1){//exit when add success!
		[self.navigationController popViewControllerAnimated:YES];
	}
	
	if(checkTaskResult){
		[checkTaskResult release];
	}
	//ILOG(@"TaskDetailViewController clickedButtonAtIndex]\n");
}

-(void)refreshTitleBarName{
	//ILOG(@"[TaskDetailViewController refreshTitleBarName\n");
	
	if(self.keyEdit==0){
		if(self.taskItem.taskPinned==0){
			self.navigationItem.title =NSLocalizedString(@"addTaskText", @"")/*addTaskText*/;
		}else {
			self.navigationItem.title =NSLocalizedString(@"addEventText", @"")/*addEventText*/;
		}
	}else if(self.keyEdit==1){
		if(self.taskItem.taskPinned==0){
			self.navigationItem.title =NSLocalizedString(@"editTaskText", @"")/*editTaskText*/;
		}else {
			self.navigationItem.title =NSLocalizedString(@"editEventText", @"")/*editEventText*/;
		}
	}else if(self.keyEdit==2){
		if(self.taskItem.taskPinned==0){
			self.navigationItem.title =NSLocalizedString(@"duplicateTaskText", @"")/*duplicateTaskText*/;
		}else {
			self.navigationItem.title =NSLocalizedString(@"duplicateEventText", @"")/*duplicateEventText*/;
		}
	}
	//ILOG(@"TaskDetailViewController refreshTitleBarName]\n");
	
}

-(void)taskStyleAction:(id)sender{
	//ILOG(@"[TaskDetailViewController taskStyleAction\n");
	
	self.taskItem.taskPinned=segmentedTaskStyleControl.selectedSegmentIndex;
	if(self.taskItem.taskPinned==0){//task
		self.taskItem.isAllDayEvent=0;
		allDaySwitch.on=0;
		//tableView.scrollEnabled=YES;
	}else {
		if(self.taskItem.primaryKey==-1 && self.taskItem.taskHowLong <3600){//if new event, set default duration to 1 hour
			self.taskItem.taskHowLong=3600;
			self.taskItem.taskEndTime=[self.taskItem.taskStartTime dateByAddingTimeInterval:3600];
		}
		
		//tableView.scrollEnabled=NO;
	}

	
	//[self refreshTaskWhen];
	[tableView reloadData];
	
	[self refreshTitleBarName];
	
	TableCellTaskDetailTitle *cell = (TableCellTaskDetailTitle *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
	if(!cell.taskName.text || [cell.taskName.text length]==0){
		//[taskTitleTextField resignFirstResponder];
		[cell.taskName becomeFirstResponder];
	}
	//ILOG(@"TaskDetailViewController taskStyleAction]\n");
}

-(void)contextAction:(id)sender{
	//self.taskItem.taskWhere=segmentedContextControl.selectedSegmentIndex;
	
	//[self refreshDueWhenChangeContext:self.taskItem.taskDeadLine context:self.taskItem.taskWhere];
	//[self refreshTaskDue];
	
	if (self.taskItem.taskWhere !=segmentedContextControl.selectedSegmentIndex) {
		self.taskItem.taskWhere=segmentedContextControl.selectedSegmentIndex;
		[self refreshDueWhenChangeContext:self.taskItem.taskDeadLine context:self.taskItem.taskWhere];
		[self refreshTaskDue];
	}
}

-(void)firstPeriod:(id)sender{
	//ILOG(@"[TaskDetailViewController firstPeriod\n");
	[taskTitleTextField resignFirstResponder];
	
	self.taskItem.taskHowLong=900;
	self.taskItem.taskEndTime=[self.taskItem.taskStartTime dateByAddingTimeInterval:900];		
	[self refreshTaskHowLong];
	//ILOG(@"TaskDetailViewController firstPeriod]\n");
}

-(void)secondPeriod:(id)sender{
	//ILOG(@"[TaskDetailViewController secondPeriod\n");
	[taskTitleTextField resignFirstResponder];
	
	self.taskItem.taskHowLong=3600;
	self.taskItem.taskEndTime=[self.taskItem.taskStartTime dateByAddingTimeInterval:3600];		
	[self refreshTaskHowLong];
	//ILOG(@"TaskDetailViewController secondPeriod]\n");
}

-(void)thirdPeriod:(id)sender{
	//ILOG(@"[TaskDetailViewController thirdPeriod\n");
	[taskTitleTextField resignFirstResponder];
	
	self.taskItem.taskHowLong=10800;
	self.taskItem.taskEndTime=[self.taskItem.taskStartTime dateByAddingTimeInterval:10800];		
	[self refreshTaskHowLong];
	//ILOG(@"TaskDetailViewController thirdPeriod]\n");
}
/*
-(void)whenNone:(id)sender{
	//ILOG(@"[TaskDetailViewController whenNone\n");
	[taskTitleTextField resignFirstResponder];
	
	self.taskItem.taskIsUseDeadLine=0;
	NSDate *deadlineDate=[[NSDate date] addTimeInterval:93312000];
	self.taskItem.taskDueEndDate=deadlineDate;
	self.taskItem.taskDeadLine=deadlineDate;
	
	//[self refreshTaskDue];
	//ILOG(@"TaskDetailViewController whenNone]\n");
}

-(void)whenOneWeek:(id)sender{
	//ILOG(@"[TaskDetailViewController whenOneWeek\n");
	[taskTitleTextField resignFirstResponder];
	
	self.taskItem.taskIsUseDeadLine=1;
	NSDate *deadlineDate=[ivoUtility createDeadLine:DEADLINE_1_WEEK fromDate:[NSDate date] context:self.taskItem.taskWhere];
	self.taskItem.taskNotEalierThan=[NSDate date];
	self.taskItem.taskDueEndDate=[[NSDate date] addTimeInterval:604800];
	self.taskItem.taskDeadLine=deadlineDate;
	[deadlineDate release];
	
	//[self refreshTaskDue];
	//ILOG(@"TaskDetailViewController whenOneWeek]\n");
}

-(void)whenOneMonth:(id)sender{
	//ILOG(@"[TaskDetailViewController whenOneMonth\n");
	[taskTitleTextField resignFirstResponder];
	
	self.taskItem.taskIsUseDeadLine=1;
	NSDate *deadlineDate=[ivoUtility createDeadLine:DEADLINE_1_MONTH fromDate:[NSDate date] context:self.taskItem.taskWhere];
	self.taskItem.taskNotEalierThan=[NSDate date];
	self.taskItem.taskDueEndDate=[[NSDate date] addTimeInterval:2592000];
	self.taskItem.taskDeadLine=deadlineDate;
	[deadlineDate release];

	[self refreshTaskDue];
	//ILOG(@"TaskDetailViewController whenOneMonth]\n");
}

*/

-(void)selectDue:(id)sender
{
//	printf("button title: %s\n", [[sender titleForState:UIControlStateNormal] UTF8String]);
	NSDate *today = [NSDate date];
	NSDate *tomorrow = [today dateByAddingTimeInterval:24*60*60];
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;//|NSWeekdayCalendarUnit|NSWeekdayOrdinalCalendarUnit;
	
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:today];
	NSDateComponents *wdComps =[gregorian components:NSWeekdayCalendarUnit fromDate:today];
	NSInteger wd = [wdComps weekday];
	
	NSDate *endNextWeek = [[gregorian dateFromComponents:comps] dateByAddingTimeInterval:(2*7-wd)*24*60*60];

	[gregorian release];
	
	NSString *buttonTitle = [sender titleForState:UIControlStateNormal];
	if ([buttonTitle isEqualToString:NSLocalizedString(@"todayText", @"")/*todayText*/])
	{
		//self.taskItem.taskDeadLine = today;
		self.taskItem.taskDeadLine = [ivoUtility createDeadLine:-1 fromDate:today context:self.taskItem.taskWhere];
		self.taskItem.taskIsUseDeadLine = YES;
		
	}
	else if ([buttonTitle isEqualToString:NSLocalizedString(@"tomorrowText", @"")/*tomorrowText*/])
	{
		//self.taskItem.taskDeadLine = tomorrow;
		self.taskItem.taskDeadLine = [ivoUtility createDeadLine:-1 fromDate:tomorrow context:self.taskItem.taskWhere];
		self.taskItem.taskIsUseDeadLine = YES;		
	}
	else if ([buttonTitle isEqualToString:NSLocalizedString(@"nextweekText", @"")/*nextweekText*/])
	{
		//self.taskItem.taskDeadLine = endNextWeek;
		self.taskItem.taskDeadLine = [ivoUtility createDeadLine:-1 fromDate:endNextWeek context:self.taskItem.taskWhere];
		self.taskItem.taskIsUseDeadLine = YES;		
	}
	
	self.taskItem.taskDueEndDate=[self.taskItem.taskDeadLine dateByAddingTimeInterval:taskmanager.currentSetting.adjustTimeIntervalForNewDue];
	taskmanager.currentSetting.adjustTimeIntervalForNewDue+=1;
	[taskmanager.currentSetting update];
	
	[self refreshTaskDue];
}

-(void)selectStart:(id)sender
{
	//	printf("button title: %s\n", [[sender titleForState:UIControlStateNormal] UTF8String]);
	NSDate *today = [NSDate date];
	NSDate *tomorrow = [today dateByAddingTimeInterval:24*60*60];
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;//|NSWeekdayCalendarUnit|NSWeekdayOrdinalCalendarUnit;
	
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:today];
	NSDateComponents *wdComps =[gregorian components:NSWeekdayCalendarUnit fromDate:today];
	NSInteger wd = [wdComps weekday];
	
	if(taskmanager.currentSetting.weekStartDay==START_MONDAY){
		wd--;
	}
	
	NSDate *startNextWeek = [[gregorian dateFromComponents:comps] dateByAddingTimeInterval:(8-wd)*24*60*60];

	
	NSString *buttonTitle = [sender titleForState:UIControlStateNormal];
	
	NSDate *dt = nil;
	
	if ([buttonTitle isEqualToString:NSLocalizedString(@"todayText", @"")/*todayText*/])
	{
		self.taskItem.taskNotEalierThan = today;
	}
	else if ([buttonTitle isEqualToString:NSLocalizedString(@"tomorrowText", @"")/*tomorrowText*/])
	{
		self.taskItem.taskNotEalierThan = tomorrow;
		
		dt = tomorrow;
	}
	else if ([buttonTitle isEqualToString:NSLocalizedString(@"nextweekText", @"")/*nextweekText*/])
	{
		self.taskItem.taskNotEalierThan = startNextWeek;
		dt = startNextWeek;
	}

	if (dt != nil)
	{
		//NSString *weekDayName=[ivoUtility createWeekDayName:dt];
		NSInteger weekDay=[ivoUtility getWeekday:dt];
		NSDate *contextDT = dt;

		switch (self.taskItem.taskWhere)
		{
			case 0: //home
			{
				//if([weekDayName isEqual:satText] || [weekDayName isEqual:sunText])
				if([taskmanager isDayInWeekend:weekDay])
				{
					contextDT = taskmanager.currentSetting.homeTimeWEStart;
				}
				else
				{
					contextDT = taskmanager.currentSetting.homeTimeNDStart;
				}
			}
				break;
			case 1: //work
			{
				//if([weekDayName isEqual:satText] || [weekDayName isEqual:sunText])
				if([taskmanager isDayInWeekend:weekDay])
				{
					contextDT = taskmanager.currentSetting.deskTimeWEStart;
				}
				else
				{
					contextDT = taskmanager.currentSetting.deskTimeStart;
				}				
			}
				break;
		}
		
		NSDateComponents *comps = [gregorian components:unitFlags fromDate:contextDT];
		NSDateComponents *dtcomps = [gregorian components:unitFlags fromDate:dt];
		
		comps.second = 0;
		comps.year = dtcomps.year;
		comps.month = dtcomps.month;
		comps.day = dtcomps.day;
		
		self.taskItem.taskNotEalierThan = [gregorian dateFromComponents:comps];
	}
	
	//self.taskItem.taskDueEndDate=[self.taskItem.taskNotEalierThan addTimeInterval:[self.taskItem.taskDueEndDate timeIntervalSinceDate:self.taskItem.taskDueStartDate]];
	self.taskItem.taskDueStartDate=self.taskItem.taskNotEalierThan;
		
	[self refreshTaskStart];
	[gregorian release];	
}


-(void)editDue:(id)sender
{
	DatePickerViewController *dueView=[[DatePickerViewController alloc] init];
	
	dueView.keyEdit = TASK_EDITDUE;
	dueView.editedObject = self.taskItem;
	
	[self.navigationController pushViewController:dueView animated:YES];
	[dueView release];
}

-(void)editStart:(id)sender
{
	DatePickerViewController *startView=[[DatePickerViewController alloc] init];
	
	startView.keyEdit = TASK_EDITSTART;
	startView.editedObject = self.taskItem;
	
	[self.navigationController pushViewController:startView animated:YES];
	[startView release];
}


-(void)editTitle:(id)sender{
	//ILOG(@"[TaskDetailViewController editTitle\n");
	[taskTitleTextField resignFirstResponder];
//Trung 08101002
	/*
	if(whatViewController==nil){
		whatViewController=[[WhatViewController alloc] init];	
	}
	*/
	WhatViewController *whatViewController=[[WhatViewController alloc] init];	
	
	whatViewController.editedObject=self.taskItem;
	whatViewController.taskLocation=self.taskItem.taskLocation;
	whatViewController.taskTitle=self.taskItem.taskName;
	whatViewController.taskContact=self.taskItem.taskContact;
	whatViewController.whatSelected=self.taskItem.taskWhat;
	
	[self.navigationController pushViewController:whatViewController animated:YES];
	
	//Trung 08101002
	[whatViewController release];
	//ILOG(@"TaskDetailViewController editTitle]\n");
}

-(void)editContext:(id)sender{
	//ILOG(@"[TaskDetailViewController editContext\n");
	//Trung 08101002
	/*
	if(generalListView==nil){
		generalListView=[[GeneralListViewController alloc] init];	
	}
	*/
	GeneralListViewController *generalListView=[[GeneralListViewController alloc] init];	
	
	generalListView.keyEdit=TASK_EDITCONTEXT;
	generalListView.editedObject=self.taskItem;
	generalListView.pathIndex=self.taskItem.taskWhere;
	[generalListView setEditing:YES animated:YES];
	[self.navigationController pushViewController:generalListView animated:YES];
	
	//Trung 08101002
	[generalListView release];
	//ILOG(@"TaskDetailViewController editContext]\n");
}

-(void)editDuration:(id)sender{
	//ILOG(@"[TaskDetailViewController editDuration\n");
	[taskTitleTextField resignFirstResponder];
	

	DurationViewController *infoEditView=[[DurationViewController alloc] init];	
	
	infoEditView.keyEdit=TASK_EDITHOWLONG;
	infoEditView.editedObject=self.taskItem;
	[self.navigationController pushViewController:infoEditView animated:YES];
	
	[infoEditView release];
	//ILOG(@"TaskDetailViewController editDuration]\n");
}

-(void)editWhen:(id)sender{
	//ILOG(@"[TaskDetailViewController editWhen\n");
	[taskTitleTextField resignFirstResponder];
	
	//Trung 08101002
	/*
	if(timerView==nil){
		timerView=[[TimeSettingViewController alloc] init];	
	}
	*/
	
	TimeSettingViewController *timerView=[[TimeSettingViewController alloc] init];	
	
	if (segmentedTaskStyleControl.selectedSegmentIndex==0){//edit task
		timerView.keyEdit=TASK_EDITTIMERTASK;
		timerView.cellContent0Val=self.taskItem.taskNotEalierThan;
		timerView.cellContent1Val=self.taskItem.taskDeadLine;
		timerView.isUseDeadLine=self.taskItem.taskIsUseDeadLine;
		timerView.cellContent2Val=self.taskItem.taskDueStartDate;
		timerView.cellContent3Val=self.taskItem.taskDueEndDate;
		timerView.pathIndex=-1;
	}else {//edit event
		timerView.keyEdit=TASK_EDITTIMEREVENT;
		timerView.cellContent0Val=[self.taskItem taskStartTime];
		timerView.cellContent1Val=[self.taskItem taskEndTime];
		timerView.cellContent2IntVal=[self.taskItem taskRepeatID];
		if(timerView.cellContent2IntVal<0 || timerView.cellContent2IntVal>4)
			timerView.cellContent2IntVal=0;
		timerView.cellContent3IntVal=[self.taskItem taskRepeatTimes];
		if(timerView.cellContent3IntVal<0)
			timerView.cellContent3IntVal=0;
		
		timerView.currentDuration=[self.taskItem taskHowLong];
		if([self.taskItem taskEndRepeatDate]==nil){
			timerView.cellContent3Val=[self.taskItem taskEndTime];
		}else {
			timerView.cellContent3Val=[self.taskItem taskEndRepeatDate];
		}
		//timerView.numberOfInstances=[self.taskItem taskNumberInstances];

		timerView.repeatOptions=[self.taskItem taskRepeatOptions];
	}
	
	timerView.editedObject=self.taskItem;
	[timerView setEditing:YES animated:YES];
	[self.navigationController pushViewController:timerView animated:YES];
	
	//Trung 08101002
	[timerView release];
	
	//ILOG(@"TaskDetailViewController editWhen]\n");
}

-(void)editAlert:(id)sender{
	//ILOG(@"[TaskDetailViewController editAlert\n");
	//Trung 08101002
	/*
	if(alertView==nil){
		alertView=[[AlertViewController alloc] init];	
	}
	*/
/*	AlertViewController *alertView=[[AlertViewController alloc] init];
	
	alertView.editedObject=self.taskItem;
	alertView.pathIndex=self.taskItem.taskAlertID;
	[alertView setEditing:YES animated:YES];
	[self.navigationController pushViewController:alertView animated:YES];
	
	//Trung 08101002
	[alertView release];
*/
	//ILOG(@"TaskDetailViewController editAlert]\n");
}

-(void)editProject:(id)sender{
	//ILOG(@"[TaskDetailViewController editProject\n");

	//Trung 08101002
	/*
	if(projectView==nil){
		projectView=[[ProjectViewController alloc] init];
	}
	*/
	
	ProjectViewController *projectView=[[ProjectViewController alloc] init];
	
	projectView.keyEdit=TASK_EDITPROJECT;
	projectView.editedObject=self.taskItem;
	//projectView.pathIndex=self.taskItem.taskProject;
	[projectView setEditing:YES animated:YES];
	[self.navigationController pushViewController:projectView animated:YES];
	
	//Trung 08101002
	[projectView release];
	//ILOG(@"TaskDetailViewController editProject]\n");
}

-(void)editNotes:(id)sender{
	//ILOG(@"[TaskDetailViewController editNotes\n");
	//Trung 08101002
	/*
	if(infoEditView==nil){
		infoEditView=[[InfoEditViewController alloc] init];	
	}
	*/
	InfoEditViewController *infoEditView=[[InfoEditViewController alloc] init];	
	
	infoEditView.keyEdit=TASK_EDITNOTES;
	infoEditView.editedObject=self.taskItem;
	[self.navigationController pushViewController:infoEditView animated:YES];
	//Trung 08101002
	[infoEditView release];
	//ILOG(@"TaskDetailViewController editNotes]\n");
}

-(void)setAllDay:(id)sender{
	self.taskItem.isAllDayEvent=allDaySwitch.isOn;
	//allDaySwitch.on=self.taskItem.isAllDayEvent;
	
	if(allDaySwitch.isOn && self.taskItem.taskPinned==1){
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;//|NSWeekdayCalendarUnit|NSWeekdayOrdinalCalendarUnit;
		NSDateComponents *comps = [gregorian components:unitFlags fromDate:self.taskItem.taskStartTime];
		
		[comps setHour:0];
		[comps setMinute:0];
		[comps setSecond:0];
		
		self.taskItem.taskStartTime=[gregorian dateFromComponents:comps];

		if(self.taskItem.taskHowLong < 86400){
			self.taskItem.taskHowLong=86400;
		}
		
		self.taskItem.taskEndTime=[self.taskItem.taskStartTime dateByAddingTimeInterval:self.taskItem.taskHowLong];
		
		if(![App_defaultTimeZone isDaylightSavingTimeForDate:self.taskItem.taskStartTime] && [App_defaultTimeZone isDaylightSavingTimeForDate:self.taskItem.taskEndTime]){
			self.taskItem.taskEndTime=[self.taskItem.taskEndTime dateByAddingTimeInterval:-dstOffset];
		}
		
		comps = [gregorian components:unitFlags fromDate:self.taskItem.taskEndTime];
		
		if([ivoUtility getHour:self.taskItem.taskEndTime]!=0 || [ivoUtility getMinute:self.taskItem.taskEndTime]!=0){
			[comps setHour:24];
			[comps setMinute:0];
			[comps setSecond:0];
		}//else {
		//	[comps setHour:0];
		//	[comps setMinute:0];
		//	[comps setSecond:0];
		//}

		self.taskItem.taskEndTime=[gregorian dateFromComponents:comps];
		[gregorian release];
		
		NSInteger hl=[self.taskItem.taskEndTime timeIntervalSinceDate:self.taskItem.taskStartTime];
		
		if(hl < 86400){
			hl=86400;
		}
		
//		if(self.taskItem.taskRepeatID==0){
			self.taskItem.taskHowLong=hl-hl % 86400;
//		}else {
//			self.taskItem.taskHowLong=hl;
//		}

		[tableView reloadData];
	}

}

#pragma mark common methods

-(void)refreshTaskTitle:(NSInteger)whatIconNo{
	//ILOG(@"[TaskDetailViewController refreshTaskTitle\n");
	taskLocation.text=self.taskItem.taskLocation;
	taskTitleTextField.text=self.taskItem.taskName;
	//ILOG(@"TaskDetailViewController refreshTaskTitle]\n");
}

-(void)callAlert:(NSString *)message{
	//ILOG(@"[TaskDetailViewController callAlert\n");
	UIAlertView *alrtView = [[UIAlertView alloc] initWithTitle:message message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/ otherButtonTitles:nil];
	[alrtView show];
	[alrtView release];
	//ILOG(@"TaskDetailViewController callAlert]\n");
}

 
-(void)refreshTaskHowLong{
	//ILOG(@"[TaskDetailViewController refreshTaskHowLong\n");
    secondIconPeriod.center=CGPointMake(contentView.frame.size.width/2-25, firstIconPeriod.frame.origin.y+firstIconPeriod.frame.size.height/2);

    thirdIconPeriod.frame=CGRectMake(contentView.frame.size.width-thirdIconPeriod.frame.size.width-60, thirdIconPeriod.frame.origin.y, thirdIconPeriod.frame.size.width, thirdIconPeriod.frame.size.height);
    
	if(self.taskItem.taskHowLong==900){
		firstIconPeriod.selected=YES;
	}else {
		firstIconPeriod.selected=NO;
	}
	
	if(self.taskItem.taskHowLong==3600){
		secondIconPeriod.selected=YES;
	}else {
		secondIconPeriod.selected=NO;
	}
	
	if(self.taskItem.taskHowLong==10800){
		thirdIconPeriod.selected=YES;
	}else {
		thirdIconPeriod.selected=NO;
	}
	
	NSString *durationStr=[ivoUtility createCalculateHowLong:self.taskItem.taskHowLong] ;
	howLongInfo.text=durationStr ;
	[durationStr release];
	//ILOG(@"TaskDetailViewController refreshTaskHowLong]\n");
}

-(void)refreshTaskDue
{
	NSDate *today = [NSDate date];
	NSDate *tomorrow = [today dateByAddingTimeInterval:24*60*60];
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;//|NSWeekdayCalendarUnit|NSWeekdayOrdinalCalendarUnit;
	
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:today];
	NSDateComponents *wdComps =[gregorian components:NSWeekdayCalendarUnit fromDate:today];
	NSInteger wd = [wdComps weekday];

	NSDate *endNextWeek = [[gregorian dateFromComponents:comps] dateByAddingTimeInterval:(2*7-wd)*24*60*60];
	NSDate *startNextWeek = [endNextWeek dateByAddingTimeInterval:-7*24*60*60];
	
	UIButton *todayButton = [dueButtonView.subviews objectAtIndex:0];
	UIButton *tomorrowButton = [dueButtonView.subviews objectAtIndex:1];
	UIButton *nextWeekButton = [dueButtonView.subviews objectAtIndex:2];
    
    tomorrowButton.center=CGPointMake(contentView.frame.size.width/2-25, tomorrowButton.frame.origin.y+tomorrowButton.frame.size.height/2);
    
    nextWeekButton.frame=CGRectMake(contentView.frame.size.width-nextWeekButton.frame.size.width-60, nextWeekButton.frame.origin.y, nextWeekButton.frame.size.width, nextWeekButton.frame.size.height);

    
	todayButton.selected = NO;
	tomorrowButton.selected = NO;
	nextWeekButton.selected = NO;
	
	dueInfo.text = NSLocalizedString(@"noneText", @"")/*noneText*/;
	
	if (self.taskItem.taskIsUseDeadLine)
	{		
		if ([ivoUtility compareDateNoTime:self.taskItem.taskDeadLine withDate:today] == NSOrderedSame)
		{
			todayButton.selected = YES;
		}
		else if ([ivoUtility compareDateNoTime:self.taskItem.taskDeadLine withDate:tomorrow] == NSOrderedSame)
		{
			tomorrowButton.selected = YES;
			
		}
		else if ([ivoUtility compareDateNoTime:self.taskItem.taskDeadLine withDate:startNextWeek] != NSOrderedAscending &&
				 [ivoUtility compareDateNoTime:self.taskItem.taskDeadLine withDate:endNextWeek] != NSOrderedDescending)
		{
			nextWeekButton.selected = YES;
		}
		
		dueInfo.text = [ivoUtility createStringFromDate:self.taskItem.taskDeadLine isIncludedTime:YES];	
	}
	
	
	[gregorian release];
}

-(void)refreshTaskStart
{
	NSDate *today = [NSDate date];
	NSDate *tomorrow = [today dateByAddingTimeInterval:24*60*60];
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;//|NSWeekdayCalendarUnit|NSWeekdayOrdinalCalendarUnit;
	
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:today];
	NSDateComponents *wdComps =[gregorian components:NSWeekdayCalendarUnit fromDate:today];
	NSInteger wd = [wdComps weekday];
	
	NSDate *startNextWeek = [[gregorian dateFromComponents:comps] dateByAddingTimeInterval:(8-wd)*24*60*60];
	NSDate *endNextWeek = [[gregorian dateFromComponents:comps] dateByAddingTimeInterval:(2*7-wd)*24*60*60];
	
	UIButton *todayButton = [startButtonView.subviews objectAtIndex:0];
	UIButton *tomorrowButton = [startButtonView.subviews objectAtIndex:1];
	UIButton *nextWeekButton = [startButtonView.subviews objectAtIndex:2];
	
    tomorrowButton.center=CGPointMake(contentView.frame.size.width/2-25, tomorrowButton.frame.origin.y+tomorrowButton.frame.size.height/2);
    
    nextWeekButton.frame=CGRectMake(contentView.frame.size.width-nextWeekButton.frame.size.width-60, nextWeekButton.frame.origin.y, nextWeekButton.frame.size.width, nextWeekButton.frame.size.height);
    

	todayButton.selected = NO;
	tomorrowButton.selected = NO;
	nextWeekButton.selected = NO;
	
	//nang 3.7
	NSString *str= [ivoUtility createStringFromDate:self.taskItem.taskNotEalierThan isIncludedTime:YES];	
	//startInfo.text = [ivoUtility createStringFromDate:self.taskItem.taskNotEalierThan isIncludedTime:YES];	
	startInfo.text=str;
	[str release];
	
	if ([ivoUtility compareDateNoTime:self.taskItem.taskNotEalierThan withDate:today] == NSOrderedSame)
	{
		todayButton.selected = YES;
	}
	else if ([ivoUtility compareDateNoTime:self.taskItem.taskNotEalierThan withDate:tomorrow] == NSOrderedSame)
	{
		tomorrowButton.selected = YES;
		
	}
	else if ([ivoUtility compareDateNoTime:self.taskItem.taskNotEalierThan withDate:startNextWeek] != NSOrderedAscending &&
			 [ivoUtility compareDateNoTime:self.taskItem.taskNotEalierThan withDate:endNextWeek] != NSOrderedDescending)		
	{
		nextWeekButton.selected = YES;
	}
	
	
	[gregorian release];
}

/*
-(void)refreshTaskDue{
	//ILOG(@"[TaskDetailViewController refreshTaskDue\n");
	if(self.taskItem.taskPinned==0){
		NSString *deadLineStr;
	
		if(self.taskItem.taskIsUseDeadLine==0){
			whenNone.selected=YES;
			deadLineStr=[[NSString alloc] initWithString:noneText];
			whenOneWeek.selected=NO;
			whenOneMonth.selected=NO;
		}else {
			whenNone.selected=NO;
			NSDate *deadLineDate=[ivoUtility createDeadLine:DEADLINE_1_WEEK fromDate:[NSDate date] context:self.taskItem.taskWhere];
			if([self.taskItem.taskDeadLine compare:deadLineDate]==NSOrderedSame){
				whenOneWeek.selected=YES;
			}else {
				whenOneWeek.selected=NO;
			}
			[deadLineDate release];
			
			deadLineDate=[ivoUtility createDeadLine:DEADLINE_1_MONTH fromDate:[NSDate date] context:self.taskItem.taskWhere];
			if([self.taskItem.taskDeadLine compare:deadLineDate]==NSOrderedSame){
				whenOneMonth.selected=YES;
			}else {
				whenOneMonth.selected=NO;
			}
			[deadLineDate release];
			deadLineStr=[ivoUtility createStringFromDate:self.taskItem.taskDeadLine isIncludedTime:NO] ;
		}
		
		taskDate.text=deadLineStr;
		
		[deadLineStr release];
	}
	
	//ILOG(@"TaskDetailViewController refreshTaskDue]\n");
}
*/
 
-(void)refreshDueWhenChangeContext:(NSDate *)fromDate context:(NSInteger)context{
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	//unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit|NSSecondCalendarUnit;

	NSDateComponents *comps = [gregorian components:unitFlags fromDate:fromDate];
	[comps setSecond:0];
	NSDate *deadLineDate;
	NSString *weekDayName=[ivoUtility createWeekDayName:fromDate];
	NSInteger weekDay=[ivoUtility getWeekday:fromDate];
	NSInteger wkHourHomeEnd=[ivoUtility getHour:taskmanager.currentSetting.homeTimeWEEnd];
	NSInteger ndHourHomeEnd=[ivoUtility getHour:taskmanager.currentSetting.homeTimeNDEnd];
	NSInteger wkHourDeskEnd=[ivoUtility getHour:taskmanager.currentSetting.deskTimeWEEnd];
	NSInteger ndHourDeskEnd=[ivoUtility getHour:taskmanager.currentSetting.deskTimeEnd];
	
	NSInteger wkMinHomeEnd=[ivoUtility getMinute:taskmanager.currentSetting.homeTimeWEEnd];
	NSInteger ndMinHomeEnd=[ivoUtility getMinute:taskmanager.currentSetting.homeTimeNDEnd];
	NSInteger wkMinDeskEnd=[ivoUtility getMinute:taskmanager.currentSetting.deskTimeWEEnd];
	NSInteger ndMinDeskEnd=[ivoUtility getMinute:taskmanager.currentSetting.deskTimeEnd];
	
	if(context==0){//home
		//if([weekDayName isEqual:satText] || [weekDayName isEqual:sunText]){//weekend
		if([taskmanager isDayInWeekend:weekDay]){
			[comps setMinute:wkMinHomeEnd];
			[comps setHour:wkHourHomeEnd];	
		}else{//normal day
			[comps setMinute:ndMinHomeEnd];
			[comps setHour: ndHourHomeEnd];	
		}
	}else{//desk
		//if([weekDayName isEqual:satText] || [weekDayName isEqual:sunText]){//weekend
		if([taskmanager isDayInWeekend:weekDay]){
			[comps setMinute:wkMinDeskEnd];
			[comps setHour:wkHourDeskEnd];	
		}else{//normal day
			[comps setMinute:ndMinDeskEnd];
			[comps setHour: ndHourDeskEnd];	
		}
	}
	[weekDayName release];
	
	deadLineDate = [[[gregorian dateFromComponents:comps] dateByAddingTimeInterval:0] copy];
	self.taskItem.taskDeadLine=deadLineDate;
	[deadLineDate release];
	[gregorian release];
}

/*
-(void)refreshTaskWhen{
	//ILOG(@"[TaskDetailViewController refreshTaskWhen\n");
	if(self.taskItem.taskPinned==0){
		whenInfo.text=deadlineText;//@"Deadline";
		taskDueButton.hidden=NO;
		taskTime.hidden=YES;
		repeatInfo.hidden=YES;
	}else {
		whenInfo.text=whenText;//@"When";	
		taskDueButton.hidden=YES;
		taskTime.hidden=NO;
		repeatInfo.hidden=NO;
	}
	
	//create label for Start Date
	if(self.taskItem.taskPinned==1){
		NSString *startDateStr=[ivoUtility createStringFromDate:self.taskItem.taskStartTime isIncludedTime:YES];
		taskDate.text=startDateStr;
		[startDateStr release];
	}else {
		[self refreshTaskDue];
	}
	
	//create label for Start Time
	if(self.taskItem.taskPinned==1){
		NSString *timeStr=[ivoUtility createTimeStringFromDate:self.taskItem.taskStartTime];
		taskTime.text=[repeatList objectAtIndex:self.taskItem.taskRepeatID];//[@"Start " stringByAppendingString: timeStr];
		[timeStr release];
	}else {
		taskTime.text=@"";
	}
	
	//ILOG(@"TaskDetailViewController refreshTaskWhen]\n");
}
*/

#pragma mark -
#pragma mark <UITableViewDelegate, UITableViewDataSource> Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {	
	return 4;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
    // Only one row for each section
	switch (section) {
		case 0://task type
			return 1;
			break;
		case 1:
			if(self.taskItem.taskPinned==1)
			{
				return 3;
			}
			
			return 5;
			break;
		case 2://context
			return 1;
			break;
		case 3:
#ifndef FREE_VERSION
//un-comment below to disabale alert for Tasks
//			if(self.taskItem.taskPinned==1)
				return 3;
#endif			
			return 2;
			break;
	}
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//ILOG(@"[TaskDetailViewController cellForRowAtIndexPath\n");
	
	switch (indexPath.section) {
		case 0:
		{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"taskDetail"];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"taskDetail"] autorelease];
			}
			
			cell.accessoryType= UITableViewCellAccessoryNone;
			cell.textLabel.text=@"";
			if([segmentedTaskStyleControl superview])
				[segmentedTaskStyleControl removeFromSuperview];
			[cell.contentView addSubview:segmentedTaskStyleControl];
			segmentedTaskStyleControl.frame=CGRectMake(10, 0, contentView.frame.size.width-20, 30);
			return cell;
			
		}
			break;
		case 1:
			switch (indexPath.row){
				case 0:
				{
					TableCellTaskDetailTitle *cell = (TableCellTaskDetailTitle *)[tableView dequeueReusableCellWithIdentifier:@"taskTitle1"];
					if (cell == nil) {
						cell = [[[TableCellTaskDetailTitle alloc] initWithFrame:CGRectZero reuseIdentifier:@"taskTitle1"] autorelease];
					}
					
					cell.selectionStyle=UITableViewCellSelectionStyleNone;

                    editTitleButon.frame=CGRectMake(contentView.frame.size.width-50, editTitleButon.frame.origin.y, editTitleButon.frame.size.width, editTitleButon.frame.size.height);
                    
					cell.editButton=editTitleButon;
					
					[self refreshTaskTitle:self.taskItem.taskWhat];

					if([taskTitleTextField superview])
						[taskTitleTextField removeFromSuperview];
                    
                    taskTitleTextField.frame=CGRectMake(taskTitleTextField.frame.origin.x, taskTitleTextField.frame.origin.y, contentView.frame.size.width-taskTitleTextField.frame.origin.x-60,taskTitleTextField.frame.size.height);
					cell.taskName=taskTitleTextField;

					if([taskLocation superview])
						[taskLocation removeFromSuperview];
                    taskLocation.frame=CGRectMake(taskLocation.frame.origin.x, taskLocation.frame.origin.y, contentView.frame.size.width-taskLocation.frame.origin.x-60,taskLocation.frame.size.height);

					cell.location=taskLocation;

					return cell;
				}
					break;
					
				case 1:		
				{
					if(self.taskItem.taskPinned==1) goto timeForEvent;
						
					TableCellTaskDetailButton *cell = (TableCellTaskDetailButton *)[tableView dequeueReusableCellWithIdentifier:@"taskGroupButtons"];
					if (cell == nil) {
						cell = [[[TableCellTaskDetailButton alloc] initWithFrame:CGRectZero reuseIdentifier:@"taskGroupButtons"] autorelease];
					}
					
					if(self.taskItem.taskPinned==1){
						cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
					}else {
						cell.accessoryType= UITableViewCellAccessoryNone;
					}
					
					cell.selectionStyle=UITableViewCellSelectionStyleNone;

                    durationLabel.frame=CGRectMake(durationLabel.frame.origin.x, durationLabel.frame.origin.y, contentView.frame.size.width-durationLabel.frame.origin.x-60,durationLabel.frame.size.height);
                    
					cell.cellName=durationLabel;
					
					if([howLongInfo superview])
						[howLongInfo removeFromSuperview];
                    
                    howLongInfo.frame=CGRectMake(howLongInfo.frame.origin.x, howLongInfo.frame.origin.y, contentView.frame.size.width-howLongInfo.frame.origin.x-60,howLongInfo.frame.size.height);
                    
					cell.cellValue=howLongInfo;

					if([durationButtonView superview])
						[durationButtonView removeFromSuperview];
                    
                    durationButtonView.frame=CGRectMake(durationButtonView.frame.origin.x, durationButtonView.frame.origin.y, contentView.frame.size.width-durationButtonView.frame.origin.x-60,durationButtonView.frame.size.height);
                    

					cell.buttonView=durationButtonView;
					cell.cellValue2=nil;
					
                    editHLButon.frame=CGRectMake(contentView.frame.size.width-50, editHLButon.frame.origin.y, editHLButon.frame.size.width, editHLButon.frame.size.height);

					cell.editButton=editHLButon;
					
					[self refreshTaskHowLong];
					
					return cell;
					
				}
					break;
					
				case 2:
				{
					
					if(self.taskItem.taskPinned==1) goto allDayForEvent;
				timeForEvent:				
					{	
						if(segmentedTaskStyleControl.selectedSegmentIndex==0){//task
							TableCellTaskDetailButton *cell = (TableCellTaskDetailButton *)[tableView dequeueReusableCellWithIdentifier:@"taskStart"];
							if (cell == nil) {
								cell = [[[TableCellTaskDetailButton alloc] initWithFrame:CGRectZero reuseIdentifier:@"taskStart"] autorelease];
							}
							
							cell.accessoryType= UITableViewCellAccessoryNone;
							//if(self.taskItem.taskPinned==1){
                            //    cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
                            //}else {
                            //    cell.accessoryType= UITableViewCellAccessoryNone;
                            //}
                            
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							
                            //startLabel.frame=CGRectMake(startLabel.frame.origin.x, startLabel.frame.origin.y, contentView.frame.size.width-startLabel.frame.origin.x-60,startLabel.frame.size.height);
                            
							cell.cellName=startLabel;
							
							if([startInfo superview])
								[startInfo removeFromSuperview];
                            startInfo.frame=CGRectMake(startInfo.frame.origin.x, startInfo.frame.origin.y, contentView.frame.size.width-startInfo.frame.origin.x-60,startInfo.frame.size.height);
							cell.cellValue=startInfo;
							
							if([startButtonView superview])
								[startButtonView removeFromSuperview];
                            
                            startButtonView.frame=CGRectMake(startButtonView.frame.origin.x, startButtonView.frame.origin.y, contentView.frame.size.width-startButtonView.frame.origin.x-60,startButtonView.frame.size.height);
                            
							cell.buttonView=startButtonView;
							cell.cellValue2=nil;
							
                            editStartButon.frame=CGRectMake(contentView.frame.size.width-50, editStartButon.frame.origin.y, editStartButon.frame.size.width, editStartButon.frame.size.height);
                            

							cell.editButton=editStartButon;
							
							[self refreshTaskStart];
							
							return cell;
						}
						else
						{
							TableViewCellDetailWhen *cell = (TableViewCellDetailWhen *)[tableView dequeueReusableCellWithIdentifier:@"taskGroupButtons1"];
							if (cell == nil) {
								cell = [[[TableViewCellDetailWhen alloc] initWithFrame:CGRectZero reuseIdentifier:@"taskGroupButtons1"] autorelease];
							}
							
							//if(self.taskItem.taskPinned==1){
							//	cell.accessoryType= UITableViewCellAccessoryNone;
							//}else{
								cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
							//}
							
							cell.selectionStyle=UITableViewCellSelectionStyleBlue;
							
							/*if(segmentedTaskStyleControl.selectedSegmentIndex==0){//task
								cell.title1.text=dueStartText;
								cell.title2.text=deadlineText;
								NSString *dueStartDateStr=[ivoUtility createStringFromDate:self.taskItem.taskNotEalierThan isIncludedTime:YES];
								cell.value1.text=dueStartDateStr;
								[dueStartDateStr release];
								
								if(self.taskItem.taskIsUseDeadLine){
									NSString *deadlineDateStr=[ivoUtility createStringFromDate:self.taskItem.taskDeadLine isIncludedTime:YES];
									cell.value2.text=deadlineDateStr;
									[deadlineDateStr release];
								}else {
									cell.value2.text=noneText;
								}
								
								
							}else {//event */
								cell.title1.text=NSLocalizedString(@"whenText", @"")/*whenText*/;
								NSString *startDateStr=[ivoUtility createStringFromDate:self.taskItem.taskStartTime isIncludedTime:YES];
								cell.value1.text=startDateStr;
								[startDateStr release];
								
								cell.title2.text=NSLocalizedString(@"repeatText", @"")/*repeatText*/;
								cell.value2.text=[repeatList objectAtIndex:self.taskItem.taskRepeatID];
							//}
							
							return cell;
						}
						
						
						break;	
					}
					
				allDayForEvent:
					{
						UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"taskDetail"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"taskDetail"] autorelease];
						}
					
						cell.accessoryType= UITableViewCellAccessoryNone;
						cell.selectionStyle=UITableViewCellSelectionStyleNone;
						
						cell.textLabel.textColor=[UIColor darkGrayColor];
						cell.textLabel.font=[UIFont systemFontOfSize:16];
						cell.textLabel.text=NSLocalizedString(@"allDayText", @"")/*allDayText*/;
					
						if([allDaySwitch superview])
							[allDaySwitch removeFromSuperview];
						
                        allDaySwitch.frame=CGRectMake(contentView.frame.size.width-110, allDaySwitch.frame.origin.y, allDaySwitch.frame.size.width, allDaySwitch.frame.size.height);
                        
						allDaySwitch.on=self.taskItem.isAllDayEvent;
						[cell.contentView addSubview:allDaySwitch];
						return cell;
					}
				}
					break;
				case 3:		
				{
					TableCellTaskDetailButton *cell = (TableCellTaskDetailButton *)[tableView dequeueReusableCellWithIdentifier:@"taskDue"];
					if (cell == nil) {
						cell = [[[TableCellTaskDetailButton alloc] initWithFrame:CGRectZero reuseIdentifier:@"taskDue"] autorelease];
					}
					
					cell.accessoryType= UITableViewCellAccessoryNone;
					
					cell.selectionStyle=UITableViewCellSelectionStyleNone;
					
                    //dueLabel.frame=CGRectMake(dueLabel.frame.origin.x, dueLabel.frame.origin.y, contentView.frame.size.width-dueLabel.frame.origin.x-60,startLabel.frame.size.height);
                    
					cell.cellName=dueLabel;
					
					if([dueInfo superview])
						[dueInfo removeFromSuperview];
                    
                    dueInfo.frame=CGRectMake(dueInfo.frame.origin.x, dueInfo.frame.origin.y, contentView.frame.size.width-dueInfo.frame.origin.x-60,dueInfo.frame.size.height);
                    

					cell.cellValue=dueInfo;
					
					if([dueButtonView superview])
						[dueButtonView removeFromSuperview];
					cell.buttonView=dueButtonView;
					cell.cellValue2=nil;
					
                    editDueButon.frame=CGRectMake(contentView.frame.size.width-50, editDueButon.frame.origin.y, editDueButon.frame.size.width, editDueButon.frame.size.height);
                    
					cell.editButton=editDueButon;
					
					[self refreshTaskDue];
					
					return cell;
					
				}
					break;
                case 4:
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"taskDetail3"];
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"taskDetail3"] autorelease];
                    }
                    
                    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle=UITableViewCellSelectionStyleBlue;
                    
                    cell.textLabel.font=[UIFont systemFontOfSize:16];
                    cell.textLabel.textColor=[UIColor darkGrayColor];
                    cell.textLabel.text= NSLocalizedString(@"repeatText",@"");
                    cell.detailTextLabel.text=[repeatList objectAtIndex:self.taskItem.taskRepeatID];
                    
                    return cell;
                }
                    break;
					
			}
			break;

		case 2:
		{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"taskDetail3"];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"taskDetail3"] autorelease];
			}
			
			cell.accessoryType= UITableViewCellAccessoryNone;
			cell.textLabel.text=@"";
			if([segmentedContextControl superview])
				[segmentedContextControl removeFromSuperview];
            
            segmentedContextControl.frame=CGRectMake(10, segmentedContextControl.frame.origin.y, contentView.frame.size.width-20, segmentedContextControl.frame.size.height);

			[cell.contentView addSubview:segmentedContextControl];
			
			return cell;
			
		}
		case 3:
			switch (indexPath.row) {
					
				case 0:
				{
					TableCellWithRightValue *cell = (TableCellWithRightValue *)[tableView dequeueReusableCellWithIdentifier:@"taskProject"];
					if (cell == nil) {
						cell = [[[TableCellWithRightValue alloc] initWithFrame:CGRectZero reuseIdentifier:@"taskProject"] autorelease];
					}
					cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
					
					cell.textLabel.font=[UIFont systemFontOfSize:16];
					cell.textLabel.textColor=[UIColor darkGrayColor];
					
					cell.textLabel.text= NSLocalizedString(@"projectText", @"Project"); //projectText;//@"Project";
					CGRect frm=cell.value.frame;
					//frm.size.height=40;
					//cell.value.frame=frm;
					cell.value.frame=CGRectMake(frm.origin.x, frm.origin.y, contentView.frame.size.width-frm.origin.x-40, 40);
                    
					Projects *project=[App_Delegate calendarWithPrimaryKey:self.taskItem.taskProject];
					
					cell.value.text=project.projName;
					
					//cell.value.textColor=[ivoUtility getRGBColorForProject:self.taskItem.taskProject isGetFirstRGB:NO];
					
					//EK Sync
					//NSInteger colorId = [[projectList objectAtIndex:self.taskItem.taskProject] colorId];
					cell.value.textColor=[ivoUtility getRGBColorForProject:self.taskItem.taskProject isGetFirstRGB:NO];
					
                    
					return cell;
				}
					break;
				case 1:
				{
#ifdef FREE_VERSION
				goto forNoteRow;	
#endif	
// un-comment this line to disable Push for tasks
//					if(self.taskItem.taskPinned==0) goto forNoteRow;
					
					TableCellWithRightValue *cell = (TableCellWithRightValue *)[tableView dequeueReusableCellWithIdentifier:@"taskProject"];
					if (cell == nil) {
						cell = [[[TableCellWithRightValue alloc] initWithFrame:CGRectZero reuseIdentifier:@"taskProject"] autorelease];
					}
					
					cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
					cell.textLabel.font=[UIFont systemFontOfSize:16];
					cell.textLabel.textColor=[UIColor darkGrayColor];
					
					cell.textLabel.text=NSLocalizedString(@"alertText", @"Alert")/*alertText*/;//@"Alert";
					
					CGRect frm=cell.value.frame;
					frm.size.height=40;
					//cell.value.frame=frm;
                    
                    cell.value.frame=CGRectMake(frm.origin.x, frm.origin.y, contentView.frame.size.width-frm.origin.x-40, 40);
                    
					//if(self.taskItem.taskAlertValues ==nil || [self.taskItem.taskAlertValues isEqualToString:@""]){
                    if(self.taskItem.hasAlert==0){
						cell.value.text=NSLocalizedString(@"noneText", @"None")/*noneText*/;//@"None";
					}else {
                        
                        NSString *alertValueStr=@"";
                        
						NSMutableArray *alerList=[self.taskItem creatAlertList];
                        if (alerList.count>0) {
                            Alert *alert=[alerList objectAtIndex:0];
                            
                            if(alert.amount==0){
                                //alertValueStr=[[NSString stringWithFormat:@"%@: ",alert.alertByString] stringByAppendingString:onDateEventText];
                                if(taskItem.taskPinned==1){
                                    alertValueStr=NSLocalizedString(@"onDateEventText", @"");
                                }else {
                                    //alertValueStr=NSLocalizedString(@"specifiedTimeText", @"");
                                    if (self.taskItem.alertBasedOn==0 || self.taskItem.taskIsUseDeadLine==0) {
                                        alertValueStr=NSLocalizedString(@"onDateOfStartText",@"");
                                    }else{
                                        alertValueStr=NSLocalizedString(@"onDateOfDueText",@"");
                                    }
                                }
                                
                            }else {
                                alertValueStr=[[NSString stringWithFormat:@"%d %@ ",alert.amount,alert.timeUnitString] stringByAppendingString:NSLocalizedString(@"beforeText", @"")];
                            }

                            if(alerList.count>1){
                                alertValueStr=[alertValueStr stringByAppendingString: @",..."];
                            }
                        }

						cell.value.text=alertValueStr;
							
						[alerList release];
					}

					return cell;
				}
					break;

			 	case 2:
				{
				forNoteRow:
					{
						TableCellTaskDetailNotes *cell = (TableCellTaskDetailNotes *)[tableView dequeueReusableCellWithIdentifier:@"MyIdentifier5"];
						if (cell == nil) {
							cell = [[[TableCellTaskDetailNotes alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifier5"] autorelease];
						}
						
						cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
						cell.textLabel.font=[UIFont systemFontOfSize:16];
						cell.textLabel.textColor=[UIColor darkGrayColor];
						
						taskNotesTextField.text=self.taskItem.taskDescription;
						if([taskNotesTextField superview])
							[taskNotesTextField removeFromSuperview];
						
                        taskNotesTextField.frame=CGRectMake(taskNotesTextField.frame.origin.x, taskNotesTextField.frame.origin.y, contentView.frame.size.width-taskNotesTextField.frame.origin.x-30,taskNotesTextField.frame.size.height);
                        

						cell.cellContent=taskNotesTextField;
						return cell;
					}
				}
					break;
			}
			break;
		}	
	
	//ILOG(@"TaskDetailViewController cellForRowAtIndexPath]\n");

	return nil;
}


- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section {
    // Return the displayed title for the specified section.
	switch (section) {
		case 0:
			return @"";
			break;
		case 1:
			return @"";
			break;
		case 2:
			return @"";
			break;
	}
	return @"";
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Never allow selection.
    if (self.editing) {
		return indexPath;
	}
    return nil;
}

/*
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 1:
			switch (indexPath.row) {
				case 1:
					if(self.taskItem.taskPinned==1)
						return UITableViewCellAccessoryDisclosureIndicator;
					return UITableViewCellAccessoryNone;
					break;
				case 2:
					if(self.taskItem.taskPinned==1)
						return UITableViewCellAccessoryNone;

					return UITableViewCellAccessoryDisclosureIndicator;
					break;
			}
			break;
		case 3:
			return UITableViewCellAccessoryDisclosureIndicator;
			break;
	}
	return UITableViewCellAccessoryNone;
}
*/

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	switch (newIndexPath.section) {
		case 1:
			switch (newIndexPath.row) {
				case 1:
					if(self.taskItem.taskPinned==1)
						[self editWhen:nil];
					break;
				/*case 2:
					if(self.taskItem.taskPinned==0)
					[self editWhen:nil];
					break;*/
                case 4:
                {
                    GeneralListViewController *generalListView=[[GeneralListViewController alloc] init];
					
					generalListView.keyEdit=TASK_EDIT_REPEAT;
					//generalListView.editedObject=self.editedObject;
					generalListView.editedObject=self.taskItem;
					generalListView.pathIndex=self.taskItem.taskRepeatID;
					[generalListView setEditing:YES animated:YES];
					[self.navigationController pushViewController:generalListView animated:YES];
					[generalListView release];
                    
                }
                    break;
			}
			break;
		case 3://Project and Notes
			switch (newIndexPath.row) {
				case 0://projects
				{
					ProjectViewController *projectView=[[ProjectViewController alloc] init];
					
					projectView.keyEdit=TASK_EDITPROJECT;
					projectView.editedObject=self.taskItem;
					//projectView.pathIndex=self.taskItem.taskProject;
					[projectView setEditing:YES animated:YES];
					[self.navigationController pushViewController:projectView animated:YES];
					[projectView release];
				}
					break;
				case 1:
				{	
#ifdef FREE_VERSION
				goto forNoteRow;
#endif
					// un-comment this line to disable Push for tasks
					//if(self.taskItem.taskPinned==0) goto forNoteRow;
                    
					AlertValueViewController *alertView=[[AlertValueViewController alloc] init];
					alertView.editedObject=self.taskItem;
					//alertView.alertValues=(NSMutableArray *)[self.taskItem.taskAlertValues componentsSeparatedByString:@"/"];
					//[alertView setEditing:YES animated:YES];
					[self.navigationController pushViewController:alertView animated:YES];
					[alertView release];
                     
				}
					break;
				case 2://notes
				forNoteRow:
				{
					InfoEditViewController *infoEditView=[[InfoEditViewController alloc] init];
					
					infoEditView.keyEdit=TASK_EDITNOTES;
					infoEditView.editedObject=self.taskItem;
					[self.navigationController pushViewController:infoEditView animated:YES];
					[infoEditView release];
				}
					break;
			}
			break;
		default:
			break;
	}
    [table deselectRowAtIndexPath:newIndexPath animated:YES];
	
	App_Delegate.me.networkActivityIndicatorVisible=NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	switch (indexPath.section) {
		case 0:
			//return 35;
			return 30;
			break;
		case 1:
			/*
			if(indexPath.row==0){
				return 60;
			}else if(indexPath.row==1){
				return 60;
			}else {
				if(self.taskItem.taskPinned==1)
					return 44;
				return 60;
			}
			*/
			if((self.taskItem.taskPinned==1 && indexPath.row == 2) || indexPath.row==4)
				return 44;
            
			return 55;
			
			break;
		case 2:
			//return 35;
			return 30;
			break;
		case 3:
			return 40;		
			break;
	}
	
	return 40;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	//return 10;
	return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
	return 0;
}

#pragma mark TextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
	if([textField isEqual:taskTitleTextField]){
		[textField resignFirstResponder];
	}else if([textField isEqual:taskLocation]){
		[textField resignFirstResponder];
	}
	
	hintView.hidden = YES;
	
	return YES;	
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
	NSString *newText=[textField.text copy];
	if([textField isEqual:taskTitleTextField]){
		if(![self.oldTaskName isEqual:newText]){
			self.taskItem.taskWhat=-1;
		}
		self.taskItem.taskName=newText;	
	}else if([textField isEqual:taskLocation]){
		self.taskItem.taskLocation=newText;
	}

	[newText release];
	
	if(self.taskItem.taskName!=nil && ![self.taskItem.taskName isEqualToString:@""]){
		doneButton.enabled=YES;
	}else {
		doneButton.enabled=NO;
	}
	
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
	NSString *oldText=[textField.text copy];
	if([textField isEqual:taskTitleTextField]){
		self.oldTaskName=oldText;
	}else if([textField isEqual:taskLocation]){
		//
	}
	
	[oldText release];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
	
	if(![string isEqualToString:@""]) {
		doneButton.enabled=YES;
	}else if([textField.text length]<2) {
		doneButton.enabled=NO;			
	}
	hintView.hidden=YES;
	
	return YES;
}

#pragma mark transition view
- (void)animationDidStart:(CAAnimation *)animation {
	
	transitioning = YES;
    
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished {
	transitioning = NO;
	if([smartStartView superview]&&isPopingDownSmartStartView){
		[smartStartView removeFromSuperview];
		smartStartView=nil;	
		isPopingDownSmartStartView=NO;

	}
	
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	for (UITouch *touch in touches) {
		
	}
}

// Handles the end of a touch event.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch *touch in touches) {
		if( CGRectContainsPoint([hintView frame], [touch locationInView:self.view])){
			hintView.hidden=YES;
			[taskTitleTextField resignFirstResponder];
		}		
	}	
}

#pragma mark properties

-(NSString	*)oldTaskName{
	return oldTaskName;
}

-(void)setOldTaskName:(NSString *)aSting{
	if(oldTaskName!=nil)
	[oldTaskName release];
	oldTaskName=[aSting copy];
}

-(NSInteger)keyEdit{
	return keyEdit;	
}

-(void)setKeyEdit:(NSInteger)aNum{
	keyEdit=aNum;
}

//typeEdit
-(NSInteger)typeEdit{
	return typeEdit;	
}

-(void)setTypeEdit:(NSInteger)aNum{
	typeEdit=aNum;
}

-(Task *)taskItem{
	return taskItem;
}

-(void)setTaskItem:(Task*)tmp{
	[taskItem release];
	taskItem=[tmp retain];
}
@end
