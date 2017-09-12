//
//  ProjectEditViewController.m
//  SmartTime
//
//  Created by Huy Le on 9/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ProjectEditViewController.h"
#import "Projects.h"
#import "IvoCommon.h"
#import "ivo_Utilities.h"

extern ivo_Utilities *ivoUtility;

@implementation ProjectEditViewController

@synthesize projectList;
@synthesize projectIndex;
@synthesize eventMap;

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
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 418)];
	contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];	
	
	UILabel *projectNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 30)];
	projectNameLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"projectNameText", @"")/*projectNameText*/];
	projectNameLabel.backgroundColor = [UIColor clearColor];
	
	[contentView addSubview:projectNameLabel];
	[projectNameLabel release];	
	
	projectName = [[UITextField alloc] initWithFrame:CGRectMake(10, 40, 300, 30)];
	projectName.borderStyle=UITextBorderStyleRoundedRect;
	projectName.returnKeyType = UIReturnKeyDefault;
	projectName.font=[UIFont systemFontOfSize:20];
	projectName.clearButtonMode=UITextFieldViewModeWhileEditing;
	projectName.delegate=self;
	
	UILabel *mappedGCalNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 90, 300, 30)];
	mappedGCalNameLabel.text = [NSString stringWithFormat:@"%@ [%@]:", NSLocalizedString(@"mappedGCalNameText", @"")/*mappedGCalNameText*/, self.eventMap?NSLocalizedString(@"eventText", @""):NSLocalizedString(@"taskText", @"")/*eventText:taskText*/];
	mappedGCalNameLabel.backgroundColor = [UIColor clearColor];
	
	[contentView addSubview:mappedGCalNameLabel];
	[mappedGCalNameLabel release];
	
	gcalName = [[UITextField alloc] initWithFrame:CGRectMake(10, 120, 300, 30)];
	gcalName.borderStyle=UITextBorderStyleRoundedRect;
	gcalName.returnKeyType = UIReturnKeyDefault;
	gcalName.font=[UIFont systemFontOfSize:20];	
	gcalName.textColor = [UIColor grayColor];
	gcalName.enabled = NO;
	
	UIButton *useGCalNameButton =[ivoUtility createButton:NSLocalizedString(@"useGCalNameText", @"")/*useGCalNameText*/
													 buttonType:UIButtonTypeRoundedRect 
														  frame:CGRectMake(100, 160, 140, 30) 
													 titleColor:nil 
														 target:self 
													   selector:@selector(useGCalName:) 
											   normalStateImage:nil
											 selectedStateImage:nil];
	[useGCalNameButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	
	if (self.projectList != nil && self.projectIndex < self.projectList.count)
	{
		Projects *prj = (Projects *) [self.projectList objectAtIndex:self.projectIndex];
	
		projectName.text = prj.projName;
		gcalName.text = (self.eventMap? prj.mapToGCalNameForEvent:prj.mapToGCalNameForTask);
		
		//useGCalNameButton.enabled = YES;
		
		if ([gcalName.text isEqualToString:@""])
		{
			//useGCalNameButton.enabled = NO;
			mappedGCalNameLabel.hidden = YES;
			gcalName.hidden = YES;
			useGCalNameButton.hidden = YES;
		}
			
	}
	
	[projectName becomeFirstResponder];
	
	[contentView addSubview:projectName];
	[projectName release];

	[contentView addSubview:gcalName];
	[gcalName release];

	[contentView addSubview:useGCalNameButton];
	[useGCalNameButton release];
	
	self.view = contentView;
	[contentView release];

	self.navigationItem.title = NSLocalizedString(@"projectEditText", @"")/*projectEditText*/;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[[self.projectList objectAtIndex:self.projectIndex] setProjName:projectName.text];
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

- (void) useGCalName:(id) sender
{
	projectName.text = gcalName.text;
}

#pragma mark TextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

- (void)dealloc {
	projectList = nil;
	
    [super dealloc];
}


@end
