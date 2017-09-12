//
//  AboutUsWebView.m
//  SmartTime
//
//  Created by Left Coast Logic on 10/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AboutUsWebView.h"


@implementation AboutUsWebView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) { 
        // Initialization code
		
		NSString *filePath;// = [[NSBundle mainBundle] pathForResource:@"ST_aboutUS_320" ofType:@"html"];
        
        CGRect frame=[[UIScreen mainScreen] bounds];
        
        if (frame.size.height>480) {
            filePath = [[NSBundle mainBundle] pathForResource:@"ST_aboutUS_320_ip5" ofType:@"html"];
        }else{
            filePath = [[NSBundle mainBundle] pathForResource:@"ST_aboutUS_320" ofType:@"html"];
        }

        
		//NSData *htmlData = [NSData dataWithContentsOfFile:filePath];
		NSString *html = [NSString stringWithContentsOfFile:filePath]; 
		//if (htmlData) {  
		if (html) {
			NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
			if (version == nil || [version isEqualToString:@""])
			{
				version = @"unknown";
			}
			
			NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
			if (build == nil || [build isEqualToString:@""])
			{
				build = @"unknown";
			}
			
			NSString *info = [NSString stringWithFormat:@"Version %@ build %@", version, build];
			
			html = [html stringByReplacingOccurrencesOfString:@"STVersion" withString:info];

			//[self loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:nil];
			[self loadHTMLString:html baseURL:nil];
		}
		
		self.delegate = self;
    }
    return self;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	//NSString *url = [[request URL] absoluteString];
	NSString *url = [[request URL] relativeString];
	
	if (![url isEqualToString:@"about:blank"])
	{
		url = [NSString stringWithFormat:@"http:/%@", [[request URL] relativePath]];
		
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	}
	return YES;
}

- (void)dealloc {
    [super dealloc];
}


@end
