//
//  TaskActionResult.h
//  SmartTime
//
//  Created by NangLe on 8/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TaskActionResult : NSObject {
	NSInteger	errorNo;
	NSInteger	errorAtTaskIndex;
	NSString	*errorMessage;
	NSDate		*overdueTimeSlotFound;
	NSInteger	taskPrimaryKey;
}

@property(nonatomic,assign) NSInteger	errorNo;
@property(nonatomic,assign) NSInteger	errorAtTaskIndex;
@property(nonatomic,retain) NSString	*errorMessage;
@property(nonatomic,retain) NSDate		*overdueTimeSlotFound;
@property(nonatomic,assign) NSInteger	taskPrimaryKey;

@end
