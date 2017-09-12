//
//  GuideWebView.h
//  SmartTime
//
//  Created by Huy Le on 7/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GuideWebView : UIWebView<UIWebViewDelegate> {
	NSString *fileName;
	NSString *fileExt;
	
	NSString *content;
	
	BOOL safariEnabled;
}

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *fileExt;

@property (nonatomic, copy) NSString *content;

@property BOOL safariEnabled;

- (void)loadURL:(NSString *)url fileName:(NSString *)fileName extension:(NSString *)fileExt;
- (void)loadURL:(NSString *)url content:(NSString *)content;
- (void)loadHTMLFile:(NSString *)fileName extension:(NSString *)fileExt;

@end
