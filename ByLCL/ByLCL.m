//
//  SettingCtrl.m
//  SmartNotes
//
//  Created by LCL2 on 11/13/09.
//  Copyright 2009 Left Coat Logic LLC. All rights reserved.
//

#import "ByLCL.h"
#import "IvoCommon.h"

@implementation ByLCL

/*----------------------------------------------------------------------------
 Method:      initialize
 -----------------------------------------------------------------------------*/
- (ByLCL*) initialize {
  //funcstart();
  
  if (nil != (self = [super initWithNibName:@"ByLCL" bundle:nil])){
    self.hidesBottomBarWhenPushed           = YES;
  }
  
  
 // funcstop();
  return self;
} /* initWithNote */

/*----------------------------------------------------------------------------
 Method:      viewDidLoad
 Description: Called after the controller’s view is loaded into memory.
 -----------------------------------------------------------------------------*/
- (void) viewDidLoad {
  //funcstart();
  [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.leftcoastlogic.com/sn/alsobyLCL"]]];
  //funcstop();
  return;
} /* viewDidLoad */

/*----------------------------------------------------------------------------
 Method:      viewDidUnload
 Description: Called when the controller’s view is released from memory.
 -----------------------------------------------------------------------------*/
- (void) viewDidUnload {
//  funcstart();
 // funcstop();
  return;
} /* viewDidUnload */

/*----------------------------------------------------------------------------
 Method:      viewWillAppear
 Description: Sent to the controller before the view appears on screen.
 -----------------------------------------------------------------------------*/
- (void) viewWillAppear:(BOOL)animated {
 // funcstart();
  /* set nav-ctrl button */
  self.title                              = navItem.title;
  self.navigationItem.rightBarButtonItem  = navItem.rightBarButtonItem;
  self.navigationItem.backBarButtonItem   = navItem.backBarButtonItem;
  //funcstop();
} /* viewWillAppear */

/*----------------------------------------------------------------------------
 Method:      viewDidAppear
 Description: Sent to the controller after the view fully appears on screen.
 -----------------------------------------------------------------------------*/
- (void) viewDidAppear:(BOOL)animated {
 // funcstart();
//  funcstop();
} /* viewDidAppear */

/*----------------------------------------------------------------------------
 Method:      viewWillDisappear
 Description: Sent to the controller before the view is dismissed, covered,
 or otherwise hidden from view.
 -----------------------------------------------------------------------------*/
- (void) viewWillDisappear:(BOOL)animated {
 // funcstart();
 // funcstop();
} /* viewWillDisappear */

/*----------------------------------------------------------------------------
 Method:      viewWillDisappear
 Description: Sent to the controller after the view is dismissed, covered,
 or otherwise hidden from view.
 -----------------------------------------------------------------------------*/
- (void) viewDidDisappear:(BOOL)animated {
  //funcstart();
  //funcstop();
  return;
} /* viewDidDisappear */

/*----------------------------------------------------------------------------
 Method:      viewWillDisappear
 Description: Sent to the view controller when
 the application receives a memory warning.
 -----------------------------------------------------------------------------*/
- (void) didReceiveMemoryWarning {
  //funcstart();
  //ClearCache(); /* clear cache */
 // funcstop();
  return;
} /* didReceiveMemoryWarning */

/*----------------------------------------------------------------------------
 Method:      dealloc
 Description: Deallocates the memory occupied by the receiver.
 -----------------------------------------------------------------------------*/
- (void) dealloc {
  //funcstart();
  /* stop webView */
  if ([webView isLoading]){
    [webView stopLoading];
    //SystemFree();
  }
  /* release IBOutlet */
  [webView    release];
  [navItem    release];
  /* call supper  */
  [super dealloc];
 // funcstop();
  return;
} /* dealloc */

/*============================================================================
 UIWebViewDelegate
 ============================================================================*/
/*----------------------------------------------------------------------------
 Methods:     webView:shouldStartLoadWithRequest:navigationType
 ----------------------------------------------------------------------------*/
- (BOOL)              webView:(UIWebView*)web
   shouldStartLoadWithRequest:(NSURLRequest*)request
               navigationType:(UIWebViewNavigationType)navigationType{
  //funcstart();
  BOOL ret = YES;
  NSRange rg =[[request.URL absoluteString] rangeOfString:@"http://phobos.apple.com/WebObjects/MZStore.woa"];
  //mtrace("url[%s]",[[request.URL absoluteString] UTF8String]);
  //mtrace("rg.location[%d]",rg.location);
  if (0 == rg.location){
    NSString *test = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://google.com"]];
    if (nil == test){
      //[Warning warningFor:Warning_ErrNetwork withTaget:nil];
		UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"noInternetConnectionText", @"")// @"No internet connection!" 
														  message:NSLocalizedString(@"noInternetConnectionMsg", @"")
														 delegate:nil
												cancelButtonTitle:NSLocalizedString(@"okText", @"")
												otherButtonTitles:nil];
		[alertView show];
		[alertView release];
    } else {
      [[UIApplication sharedApplication] openURL:request.URL];
    }
    ret = NO;
  }
  //funcstop();
  return ret;
} /* webView:shouldStartLoadWithRequest:navigationType */

/*----------------------------------------------------------------------------
 Methods:     webViewDidStartLoad
 ----------------------------------------------------------------------------*/
- (void)webViewDidStartLoad:(UIWebView*)web {
 // funcstart();
  //SystemBusy();
 // funcstop();
  return;
} /* webViewDidStartLoad */

/*----------------------------------------------------------------------------
 Methods:     webViewDidFinishLoad
 ----------------------------------------------------------------------------*/
- (void) webViewDidFinishLoad:(UIWebView*)web {
 // funcstart();
 // SystemFree();
  //funcstop();
  return;
} /* webViewDidFinishLoad */

/*----------------------------------------------------------------------------
 Methods:     webView:didFailLoadWithError
 ----------------------------------------------------------------------------*/
- (void) webView:(UIWebView*)web didFailLoadWithError:(NSError *)error {
 // funcstart();
  
  /* load local web page */
  NSString  *htmlPath = [[NSBundle mainBundle] pathForResource:@"LCL_Products_Page" ofType:@"html"];
  NSURL     *bundleUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
  NSString  *html = [[NSString alloc] initWithContentsOfFile:htmlPath];
  [webView loadHTMLString:html baseURL:bundleUrl];
  
  //funcstop();
  return;
} /* webView:didFailLoadWithError */


@end /* HelpCtrl */
