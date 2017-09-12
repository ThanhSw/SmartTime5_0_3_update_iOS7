//
//  ProductPageViewController.h
//  SmartTime
//
//  Created by Nang Le on 6/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProductPageViewController : UIViewController {
	NSInteger	keyDisplay;
	UIImageView	*backgroundImgView;
	UILabel		*introductionLb;
}

@property(nonatomic,retain) UIImageView	*backgroundImgView;
@property(nonatomic,retain) UILabel		*introductionLb;
@property(nonatomic,assign) NSInteger	keyDisplay;
@end
