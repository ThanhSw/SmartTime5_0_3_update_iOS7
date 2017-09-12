//
//  LCLAdsView.h
//  SmartTime
//
//  Created by Nang Le on 6/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SmartViewController;

@interface LCLAdsView : UIView {
	UILabel *introLb;
	UILabel	*descriptLb;
	UIImageView	*icon;
	
	NSTimer *changeAdvertTmr;
	
	NSInteger	keyDisplay;
	UIButton	*backgroundImg;
	
	SmartViewController *rootViewController;
}
@property(nonatomic,retain) SmartViewController *rootViewController;
@property(nonatomic,retain) UILabel *introLb;
@property(nonatomic,retain) UILabel	*descriptLb;
@property(nonatomic,retain) UIImageView	*icon;
@property(nonatomic,retain) UIButton	*backgroundImg;
@property(nonatomic,assign) NSInteger	keyDisplay;
@end
