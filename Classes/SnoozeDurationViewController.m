//
//  SnoozeDurationViewController.m
//  SmartTime
//
//  Created by NangLe on 2/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SnoozeDurationViewController.h"
#import "SmartTimeAppDelegate.h"

extern NSMutableArray *alertList;

@implementation SnoozeDurationViewController
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
	self.title=NSLocalizedString(@"snoozeDurationText", @"")/*snoozeDurationText*/;
    CGRect frame=[[UIScreen mainScreen] bounds];
    
	contentView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
	contentView.backgroundColor=[UIColor groupTableViewBackgroundColor];
	
	timerDPView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 84, frame.size.width, 250)];
	timerDPView.delegate=self;
	timerDPView.showsSelectionIndicator=YES;
	[contentView addSubview: timerDPView];
	[timerDPView release];
	
	self.view=contentView;
	[contentView release];
}

- (void)viewWillAppear:(BOOL)animated {
	NSInteger i=1;
	for (i;i<alertList.count;i++){
		NSString *str=[alertList objectAtIndex:i];
		if([str isEqualToString:[NSString stringWithFormat:@"%d",[editedObject snoozeDuration]]]){
			break;
		}
	}
	[timerDPView selectRow:i-1 inComponent:0 animated:YES];
	[timerDPView selectRow:[editedObject snoozeUnit] inComponent:1 animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
	[editedObject setSnoozeDuration:[[alertList objectAtIndex:[timerDPView selectedRowInComponent:0]+1] intValue]];
	[editedObject setSnoozeUnit:[timerDPView selectedRowInComponent:1]];
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


- (void)dealloc {
    [super dealloc];
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

#pragma mark UIPickerView Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	switch (component) {
		case 0:
			return alertList.count-1;
			break;
		case 1:
			return 4;
			break;
	}
	return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
	switch (component) {
		case 0:
			return [alertList objectAtIndex:row+1];
			break;
		case 1:
			switch (row) {
				case 0:
					return NSLocalizedString(@"minutesText", @"minutes");//@"minutes";
					break;
				case 1:
					return NSLocalizedString(@"hoursText", @"hours");//@"hours";
					break;
				case 2:
					return NSLocalizedString(@"daysText", @"days");//@"days";
					break;
				case 3:
					return NSLocalizedString(@"weeksText", @"weeks");//@"weeks";
					break;
			}
			
			break;
	}
	
	return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
	switch (component) {
		case 0:
			[timerDPView reloadComponent:1];
			break;
		default:
			break;
	}
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
	return 40;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
	switch (component) {
		case 0:
			return 100;
			break;
		case 1:
			return 100;
			break;
	}
	return 0;
}

#pragma mark properties
@end
