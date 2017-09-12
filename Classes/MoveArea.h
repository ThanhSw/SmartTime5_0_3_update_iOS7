//
//  MoveArea.h
//  IVo
//
//  Created by Left Coast Logic on 6/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IvoCommon.h" 

@interface MoveArea : UIView {
	TaskDuration howLong;
	BOOL enable;
	BOOL visible;
	TaskTypeEnum taskType;
	BOOL selected;
	
	CGFloat hashMarkYMargin;
}

@property TaskDuration howLong;
@property BOOL enable;
@property BOOL visible;
@property TaskTypeEnum taskType;
@property BOOL selected;

- (void) setHashmarkYMargin:(CGFloat) margin;

+ (CGFloat) getHashmarkXMargin;
+ (CGFloat) getHashmarkVisibleWidth;

@end
