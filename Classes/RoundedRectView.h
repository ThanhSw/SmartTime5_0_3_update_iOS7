//
//  RoundedRectView.h
//  SmartTime
//
//  Created by Huy Le on 10/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GuideWebView;

@interface RoundedRectView : UIView {
    UIColor     *strokeColor;
    UIColor     *rectColor;
    CGFloat     strokeWidth;
    CGFloat     cornerRadius;
	
	GuideWebView *webView;
	
	UIButton *okButton;
	UIButton *dontShowButton;
}

@property (nonatomic, retain) UIColor *strokeColor;
@property (nonatomic, retain) UIColor *rectColor;
@property CGFloat strokeWidth;
@property CGFloat cornerRadius;

@end
