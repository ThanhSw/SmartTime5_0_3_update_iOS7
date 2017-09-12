//
//  AboutLCLViewController.m
//  SmartTime
//
//  Created by Nang Le on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AboutLCLViewController.h"

@implementation AboutLCLViewController

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    CGRect frame=[[UIScreen mainScreen] bounds];
    
    viewOptionSeg=[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"SmartTime",@"SmartApps" ,nil]];
    viewOptionSeg.frame=CGRectMake(0, 0, 160, 30);
    viewOptionSeg.segmentedControlStyle=UISegmentedControlStyleBar;
    [viewOptionSeg addTarget:self action:@selector(viewChange:) forControlEvents:UIControlEventValueChanged];
    viewOptionSeg.selectedSegmentIndex=0;
    self.navigationItem.titleView=viewOptionSeg;
    [viewOptionSeg release];
    
    webcontent=[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, frame.size.height-44)];
    webcontent.backgroundColor=[UIColor clearColor];
    webcontent.delegate=self;
    self.view=webcontent;
    [webcontent release];
}

-(void)refreshViews{
    
}

-(void)viewDidAppear:(BOOL)animated{
	//viewOptionSeg.selectedSegmentIndex=0;
    [self performSelector:@selector(viewChange:) withObject:viewOptionSeg];
}


-(void)viewChange:(id)sender{
    UISegmentedControl *seg=sender;
    
    switch (seg.selectedSegmentIndex) {
        case 0:
        {
            NSString *htmlFile;// = [[NSBundle mainBundle] pathForResource:@"ST_aboutUS_320" ofType:@"html"];
            CGRect frame=[[UIScreen mainScreen] bounds];
            
            if (frame.size.height>480) {
                htmlFile = [[NSBundle mainBundle] pathForResource:@"ST_aboutUS_320_ip5" ofType:@"html"];
            }else{
                htmlFile = [[NSBundle mainBundle] pathForResource:@"ST_aboutUS_320" ofType:@"html"];
            }
            
            NSData *htmlData = [NSData dataWithContentsOfFile:htmlFile];
            NSString *imagePath = [[NSBundle mainBundle] resourcePath];
            imagePath = [imagePath stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
            imagePath = [imagePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            if (htmlData) {
                [webcontent loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"file:/%@//",imagePath]]];
            }
            
        }
            break;
        case 1:
        {
            NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"LCL_Products_Page_320" ofType:@"html"];
            NSData *htmlData = [NSData dataWithContentsOfFile:htmlFile];
            NSString *imagePath = [[NSBundle mainBundle] resourcePath];
            imagePath = [imagePath stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
            imagePath = [imagePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            if (htmlData) {
                [webcontent loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"file:/%@//",imagePath]]];
            }				
        }
            break;
    }
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    CGRect frame=[[UIScreen mainScreen] bounds];
    if (toInterfaceOrientation==UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation==UIInterfaceOrientationLandscapeRight) {
        webcontent.frame=CGRectMake(0, 0, frame.size.height, frame.size.width-44);
        
    }else{
        webcontent.frame=CGRectMake(0, 0, 320, frame.size.height-44);
        
    }
    [self performSelector:@selector(viewChange:) withObject:viewOptionSeg];
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	//printf("\n %d",[[request URL] isFileURL]);
	//if (![[request URL] isFileURL] && aboutUsSeg.selectedSegmentIndex==2) {
	//	[[UIApplication sharedApplication] openURL:[request URL]];
		
	//}
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
	
}

-(void)dealloc{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [super dealloc];
}

@end
