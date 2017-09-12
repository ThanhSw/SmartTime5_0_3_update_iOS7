//
//  AlertOptionForTaskViewController.m
//  SmartTime
//
//  Created by NangLe on 2/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlertOptionForTaskViewController.h"
#import "Task.h"
#import "IvoCommon.h"

@implementation AlertOptionForTaskViewController
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
    CGRect frame=[[UIScreen mainScreen] bounds];
    
	contentView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width,frame.size.height)];
	contentView.backgroundColor=[UIColor groupTableViewBackgroundColor];
	
	UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
	if([editedObject alertByDeadline]==1){
		if([editedObject taskIsUseDeadLine]==1){
			datePicker.date=[editedObject taskDeadLine];
		}else {
			datePicker.date=[editedObject taskEndTime];
		}
	}else {
		datePicker.date=[editedObject specifiedAlertTime];

	}

	[datePicker addTarget:self action:@selector(timeChanged:) forControlEvents:UIControlEventValueChanged];
//	datePicker.minuteInterval=5;
//	datePicker.minimumDate=[NSDate date];
	[contentView addSubview: datePicker];
	[datePicker release];
	
/*	if([editedObject taskIsUseDeadLine]==1){
		UIButton *dueBt=[UIButton buttonWithType:UIButtonTypeRoundedRect];
		dueBt.frame=CGRectMake(20, 300, 280, 40);
		[dueBt setTitle:alertByDueDateText forState:UIControlStateNormal];
		[dueBt addTarget:self action:@selector(dueSlected:) forControlEvents:UIControlEventTouchUpInside];
		[contentView addSubview:dueBt];
		
	}
*/
	
	self.view=contentView;
	[contentView release];
}

-(void)timeChanged:(id)sender{
	UIDatePicker *datePicker=sender;
	[editedObject setAlertByDeadline:0];
	[editedObject setSpecifiedAlertTime:datePicker.date];
	[editedObject setIsAdjustedSpecifiedDate:1];
}

-(void)dueSlected:(id)sender{
	[editedObject setAlertByDeadline:1];
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)specifiedSlected:(id)sender{
	UIButton *bt=sender;
	
	if(bt.selected){
		bt.selected=NO;
	}else {
		bt.selected=YES;
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

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
