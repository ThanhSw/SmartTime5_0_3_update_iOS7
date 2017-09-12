//
//  WeekViewTimeFinder.h
//  SmartTime
//
//  Created by Left Coast Logic on 3/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WeekViewCalController;

@interface WeekViewTimeFinder : UIView {
	WeekViewCalController *weekViewCtrler;
	
	NSInteger today;
    NSInteger cellWidth;
}

@property NSInteger today; 

- (void)drawFreeTime;
- (void)setWeekViewController: (WeekViewCalController *)weekViewCtrler;

@end
