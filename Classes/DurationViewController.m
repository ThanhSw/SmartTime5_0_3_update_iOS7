//
//  DurationViewController.m
//  SmartTime
//
//  Created by Nang Le on 11/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DurationViewController.h"
#import "Task.h"
#import "TaskManager.h"
#import "Setting.h"

extern TaskManager *taskmanager;

@implementation DurationViewController
@synthesize editedObject,keyEdit;

/*
// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
	CGRect frame=[[UIScreen mainScreen] bounds];
    
	self.title=NSLocalizedString(@"durationText", "Duration");//@"Duration";
	
	UIBarButtonItem *saveButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
															  target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
	
	contentView=[[UIView alloc] initWithFrame:CGRectZero];
	//contentView.backgroundColor=[UIColor groupTableViewBackgroundColor];
	
	timerDPView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 84, frame.size.width, 250)];
	timerDPView.datePickerMode=UIDatePickerModeCountDownTimer;
	timerDPView.minuteInterval=5;
	[contentView addSubview: timerDPView];
	
	allWorkDayButton=[[UIButton buttonWithType:UIButtonTypeRoundedRect] retain]; 
	allWorkDayButton.frame=CGRectMake(10, 240+100, frame.size.width-20, 40);
	allWorkDayButton.titleLabel.font=[UIFont boldSystemFontOfSize:16];
	[allWorkDayButton setTitle:NSLocalizedString(@"allWorkDayText", @"")/*allWorkDayText*/ forState:UIControlStateNormal];
	[allWorkDayButton addTarget:self action:@selector(setAllWorkDay:) forControlEvents:UIControlEventTouchUpInside];
	[contentView addSubview: allWorkDayButton];
	[allWorkDayButton release];

	allHomeDayButton=[[UIButton buttonWithType:UIButtonTypeRoundedRect] retain]; 
	allHomeDayButton.frame=CGRectMake(10, 295+100, frame.size.width-30, 40);
	allHomeDayButton.titleLabel.font=[UIFont boldSystemFontOfSize:16];
	[allHomeDayButton setTitle:NSLocalizedString(@"allHomeDayText", @"")/*allHomeDayText*/ forState:UIControlStateNormal];
	[allHomeDayButton addTarget:self action:@selector(setAllHomeDay:) forControlEvents:UIControlEventTouchUpInside];
	[contentView addSubview: allHomeDayButton];
	[allHomeDayButton release];

	allDayButton=[[UIButton buttonWithType:UIButtonTypeRoundedRect] retain]; 
	allDayButton.frame=CGRectMake(10, 350+100, frame.size.width-20, 40);
	allDayButton.titleLabel.font=[UIFont boldSystemFontOfSize:16];
	[allDayButton setTitle:NSLocalizedString(@"allDayText", @"")/*allDayText*/ forState:UIControlStateNormal];
	[allDayButton addTarget:self action:@selector(setAllDay:) forControlEvents:UIControlEventTouchUpInside];
	
	[contentView addSubview: allDayButton];
	[allDayButton release];
	
	self.view=contentView;
}

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

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self refreshFrames];
}

-(void)refreshFrames{
    CGRect frame=[[UIScreen mainScreen] bounds];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        contentView.frame=CGRectMake(0, 0, frame.size.height, frame.size.width);
        timerDPView.frame = CGRectMake(0, 64, frame.size.height,155);
        allWorkDayButton.frame=CGRectMake(10, 167+64, frame.size.height-20, 30);
        allHomeDayButton.frame=CGRectMake(10, 202+64, frame.size.height-20, 30);
        allDayButton.frame=CGRectMake(10, 237+64, frame.size.height-20, 30);
        
    }else{
        contentView.frame=CGRectMake(0, 0, frame.size.width, frame.size.height);
        timerDPView.frame = CGRectMake(0, 64, frame.size.width,220);
        allWorkDayButton.frame=CGRectMake(10, 240+64, frame.size.width-20, 40);
        allHomeDayButton.frame=CGRectMake(10, 295+64, frame.size.width-20, 40);
        allDayButton.frame=CGRectMake(10, 350+64, frame.size.width-20, 40);
    }
    
}

/*
// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

-(void)setAllWorkDay:(id)sender{
	timerDPView.countDownDuration=[taskmanager.currentSetting.deskTimeEnd timeIntervalSinceDate:taskmanager.currentSetting.deskTimeStart];
}

-(void)setAllHomeDay:(id)sender{
	timerDPView.countDownDuration=[taskmanager.currentSetting.homeTimeNDEnd timeIntervalSinceDate:taskmanager.currentSetting.homeTimeNDStart];
	
}

-(void)setAllDay:(id)sender{
	timerDPView.countDownDuration=86399;
}

-(void)save:(id)sender{
	switch (keyEdit) {
		case TASK_EDITHOWLONG:
			[editedObject setTaskHowLong:timerDPView.countDownDuration];
			break;
		case SETTING_HOWLONG:
			[self.editedObject setHowlongDefVal:timerDPView.countDownDuration];
			break;
	}

	[self.navigationController popViewControllerAnimated:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[timerDPView release];
	[contentView release];
    [super dealloc];
}

#pragma mark controller delegate
- (void)viewWillAppear:(BOOL)animated {
	[self refreshFrames];
	switch (keyEdit) {
		case TASK_EDITHOWLONG:
			timerDPView.countDownDuration=[editedObject taskHowLong];
			break;
		case SETTING_HOWLONG:
			timerDPView.countDownDuration=[editedObject howlongDefVal];
			break;
	}
	
}
@end
