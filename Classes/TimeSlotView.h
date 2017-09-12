//
//  TimeSlotView.h
//  iVo
//
//  Created by Left Coast Logic on 7/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TimeSlotView : UIView {
	NSDate *time;
	
	BOOL isHightLighted;
}

- (TimeSlotView *) hitTestRec: (CGRect) rec;
- (void) hightlight;
- (void) unhightlight;

@property (nonatomic, retain) 	NSDate *time;

@end
