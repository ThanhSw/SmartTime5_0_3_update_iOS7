//
//  ScheduleView.h
//  iVo
//
//  Created by Left Coast Logic on 7/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeSlotView.h"


@interface ScheduleView : UIView {
	TimeSlotView *activeSlot;
}

- (void)hightlight: (CGRect) rec;
- (void)unhightlight;
- (NSDate *)getTimeSlot;

@end
