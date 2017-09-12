//
//  MonthlyViewController.m
//  SmartTime
//
//  Created by Left Coast Logic on 2/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MonthlyViewController.h"
#import "MonthlyView.h"

@implementation MonthlyViewController

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
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
    
	MonthlyView *contentView=[[MonthlyView alloc] initWithFrame:CGRectMake(0, 0, frame.size.height, frame.size.width-18)];
	//contentView.controller = self;
	self.view = contentView;
	[contentView release];	
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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
    if(interfaceOrientation == UIInterfaceOrientationPortrait||interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
	{		
		[self.navigationController dismissModalViewControllerAnimated:YES];
		
	}

	return YES;
	
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	if(fromInterfaceOrientation==UIInterfaceOrientationPortrait||fromInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        CGRect frame=[[UIScreen mainScreen] bounds];
		self.view.frame=CGRectMake(0, 0,frame.size.height , frame.size.width);
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
