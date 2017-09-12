//
//  DateTimeSlot.h
//  iVo
//
//  Created by Nang Le on 7/31/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface DateTimeSlot : NSObject {
	NSDate		*timeSlotDate;
	NSInteger	indexAt;
	BOOL		isOverDue;
	BOOL		isPassedDeadLine;
	BOOL		isNotFit;
}

@property(nonatomic,retain)NSDate		*timeSlotDate;
@property(nonatomic,assign)NSInteger	indexAt;
@property(nonatomic,assign)BOOL			isOverDue;
@property(nonatomic,assign)BOOL			isPassedDeadLine;
@property(nonatomic,assign)BOOL			isNotFit;
@end
