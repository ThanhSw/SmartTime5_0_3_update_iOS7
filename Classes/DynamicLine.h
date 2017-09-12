//
//  DynamicLine.h
//  IVo
//
//  Created by Left Coast Logic on 5/7/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskView.h"

@class DayLineTextView;

@interface DynamicLine : TaskView {
	UIImageView *dayLineView;
	
//Trung 08101301
	DayLineTextView *textView;
	BOOL todayDayLine;
}

//Trung 08101301
- (void) setTodayDayLine:(BOOL)isTodayDayLine;

@end
 