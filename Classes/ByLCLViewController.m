//
//  ByLCLViewController.m
//  SmartTime
//
//  Created by NangLe on 2/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ByLCLViewController.h"


@implementation ByLCLViewController

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
	self.title=@"By LCL";
    
    CGRect frame=[[UIScreen mainScreen] bounds];
    
	webview=[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, frame.size.height-65)];
	
	self.view=webview;
	[webview release];
}

-(void)viewWillAppear:(BOOL)animated{
	 [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.leftcoastlogic.com/sn/alsobyLCL"]]];
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

/*============================================================================
 UIWebViewDelegate
 ============================================================================*/
/*----------------------------------------------------------------------------
 Methods:     webView:shouldStartLoadWithRequest:navigationType
 ----------------------------------------------------------------------------*/
- (BOOL)              webView:(UIWebView*)web
   shouldStartLoadWithRequest:(NSURLRequest*)request
               navigationType:(UIWebViewNavigationType)navigationType{
	BOOL ret = YES;
	NSRange rg =[[request.URL absoluteString] rangeOfString:@"http://phobos.apple.com/WebObjects/MZStore.woa"];
	if (0 == rg.location){
		NSString *test = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://google.com"]];
		if (nil == test){
			//[Warning warningFor:Warning_ErrNetwork withTaget:nil];
		} else {
			[[UIApplication sharedApplication] openURL:request.URL];
		}
		ret = NO;
	}
	return ret;
} 
/*----------------------------------------------------------------------------
 Methods:     webView:didFailLoadWithError
 ----------------------------------------------------------------------------*/
- (void) webView:(UIWebView*)web didFailLoadWithError:(NSError *)error {
	// funcstart();
	
	/* load local web page */
	NSString  *htmlPath = [[NSBundle mainBundle] pathForResource:@"LCL_Products_Page" ofType:@"html"];
	NSURL     *bundleUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
	NSString  *html = [[NSString alloc] initWithContentsOfFile:htmlPath];
	[webview loadHTMLString:html baseURL:bundleUrl];
	
	//funcstop();
	return;
} /* webView:didFailLoadWithError */


@end
