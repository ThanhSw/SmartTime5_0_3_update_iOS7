//
//  SycnGuideViewController.m
//  SmartTime
//
//  Created by NangLe on 2/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SyncGuideViewController.h"
#import "IvoCommon.h"
#import "SmartTimeAppDelegate.h"

extern BOOL isInternetConnected;
@implementation SyncGuideViewController

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
	self.title=NSLocalizedString(@"syncGuideText", @"")/*syncGuideText*/;
    
    CGRect frame=[[UIScreen mainScreen] bounds];
    
	webview=[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, frame.size.height-65)];
	
	self.view=webview;
	[webview release];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	if(isInternetConnected){
		[webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.leftcoastlogic.com/blog/smartapps/smarttimepro/synchronization"]]];
	}else {
		UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"noInternetConnectionText", @"")/*noInternetConnectionText*/// @"No internet connection!" 
														  message:NSLocalizedString(@"noInternetConnectionMsg", @"")/*noInternetConnectionMsg*/
														 delegate:nil
												cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/
												otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}

    [super viewDidLoad];
}


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


- (void)dealloc {
    [super dealloc];
}


@end
