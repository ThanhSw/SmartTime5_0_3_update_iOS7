//
//  DatePickerViewController.m
//  SmartTime
//
//  Created by Huy Le on 8/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DatePickerViewController.h"
#import "IvoCommon.h"
#import "Task.h"
#import "ivo_Utilities.h"
#import "SmartTimeAppDelegate.h"
#import "TaskManager.h"

extern ivo_Utilities *ivoUtility;
extern NSTimeInterval	adjustForNewDue;
extern TaskManager *taskmanager;

@implementation DatePickerViewController

@synthesize keyEdit;
@synthesize editedObject;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
//	UIBarButtonItem *saveButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
//																			   target:self action:@selector(save:)];
//    self.navigationItem.rightBarButtonItem = saveButton;
//	[saveButton release];
	CGRect frame=[[UIScreen mainScreen] bounds];
    
	UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width,frame.size.height)];
	
	//mainView.backgroundColor = [UIColor colorWithRed:40.0/255 green:42.0/255 blue:57.0/255 alpha:1];
	mainView.backgroundColor = [UIColor colorWithRed:161.0/255 green:162.0/255 blue:169.0/255 alpha:1];
	
	noneDueButton =[ivoUtility createButton:NSLocalizedString(@"noneText", @"")/*noneText*/
									 buttonType:UIButtonTypeRoundedRect 
										  frame:CGRectMake(120, 20, 80, 30) 
									 titleColor:nil 
										 target:self 
									   selector:@selector(noneDue:) 
							   normalStateImage:@"no-mash-white.png"
							 selectedStateImage:@"no-mash-blue.png"];
	[noneDueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[mainView addSubview:noneDueButton];
	[noneDueButton release];
	
	
	datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 100, frame.size.width, frame.size.height)];
	[datePicker addTarget:self action:@selector(timeChanged:) forControlEvents:UIControlEventValueChanged];
	datePicker.minuteInterval=5;
	[mainView addSubview: datePicker];
	[datePicker release];
	
	self.view = mainView;
	[mainView release];
	
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

- (void)timeChanged:(id)sender
{
	switch (self.keyEdit) 
	{
		case TASK_EDITDUE:
		{
			noneDueButton.selected = NO;
			self.editedObject.taskIsUseDeadLine = YES;
			
			self.editedObject.taskDeadLine = datePicker.date;
			self.editedObject.taskDueEndDate=[datePicker.date dateByAddingTimeInterval:taskmanager.currentSetting.adjustTimeIntervalForNewDue];
			taskmanager.currentSetting.adjustTimeIntervalForNewDue+=1;
			[taskmanager.currentSetting update];
			
//			self.editedObject.taskDueEndDate=[self.editedObject.taskDueEndDate dateByAddingTimeInterval: [self.editedObject.taskDeadLine timeIntervalSinceDate:self.editedObject.taskDueStartDate]];
		}
			break;
		case TASK_EDITSTART:
		{
			self.editedObject.taskNotEalierThan = datePicker.date;
//			self.editedObject.taskDueEndDate=[self.editedObject.taskNotEalierThan dateByAddingTimeInterval:[self.editedObject.taskDueEndDate timeIntervalSinceDate:self.editedObject.taskDueStartDate]];
			self.editedObject.taskDueStartDate=datePicker.date;
		}
			break;			
	}
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	
	switch (self.keyEdit) {
		case TASK_EDITDUE:
		{
			noneDueButton.selected = !editedObject.taskIsUseDeadLine;
			
			if (editedObject.taskIsUseDeadLine)
			{
				datePicker.date = editedObject.taskDeadLine;
			}
			else
			{
				datePicker.date = [NSDate date];
			}
			
			self.title=NSLocalizedString(@"dueText", @"")/*dueText*/;
			
		}
			break;
		case TASK_EDITSTART:
		{
			datePicker.date = editedObject.taskNotEalierThan;
			noneDueButton.hidden = YES;
			self.title=NSLocalizedString(@"startText", @"")/*startText*/;
		}
			break;
	}
	
}

-(void)noneDue:(id)sender
{
	editedObject.taskIsUseDeadLine = NO;
	noneDueButton.selected = YES;
}

- (void)dealloc {
	self.editedObject = nil;
	
    [super dealloc];
}


@end
