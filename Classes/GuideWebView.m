//
//  GuideWebView.m
//  SmartTime
//
//  Created by Huy Le on 7/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GuideWebView.h"


@implementation GuideWebView

@synthesize fileName;
@synthesize fileExt;

@synthesize content;

@synthesize safariEnabled;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.delegate = self;
		
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
		
		self.fileName = nil;
		self.fileExt = nil;
		
		self.safariEnabled = NO;
		
		self.content = nil;
    }
    return self;
}

- (void)loadURL:(NSString *)url fileName:(NSString *)fileName extension:(NSString *)fileExt
{
	self.fileName = fileName;
	self.fileExt = fileExt;
	
	[self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)loadURL:(NSString *)url content:(NSString *)content
{
	self.content = content;
	
	[self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}


- (void)loadHTMLFile:(NSString *)fileName extension:(NSString *)fileExt
{
	NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExt]; 
	NSURL     *bundleUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
	
	NSString *html = [NSString stringWithContentsOfFile:filePath]; 
	
	if (html) {
		[self loadHTMLString:html baseURL:bundleUrl];
	}
}

- (void)webViewDidStartLoad:(UIWebView*)web {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	self.safariEnabled = NO;
}

- (void) webViewDidFinishLoad:(UIWebView*)web {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	self.safariEnabled = YES;
}

- (void) webView:(UIWebView*)web didFailLoadWithError:(NSError *)error {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if (self.content != nil)
	{
		[self loadHTMLString:self.content baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
	}
	else
	{
		[self loadHTMLFile:self.fileName extension:self.fileExt];
	}
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if (self.safariEnabled)
	{
		NSString *url = [[request URL] relativeString];
		
		if (![url isEqualToString:@"about:blank"])
		{
			[[UIApplication sharedApplication] openURL:[request URL]];
		}		
	}
	
	return YES;
}

- (void)dealloc {
	
	self.fileName = nil;
	self.fileExt = nil;
	
	self.content = nil;
	
    [super dealloc];
}


@end
