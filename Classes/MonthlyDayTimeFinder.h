//
//  MonthlyDayTimeFinder.h
//  SmartTime
//
//  Created by Left Coast Logic on 3/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MonthlyDayTimeFinder : UIView {
	
	NSMutableArray *taskList;

}

-(void)showFreeTime:(NSMutableArray *)list;

@end
