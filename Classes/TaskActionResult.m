//
//  TaskActionResult.m
//  SmartTime
//
//  Created by NangLe on 8/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TaskActionResult.h"


@implementation TaskActionResult
@synthesize	errorNo;
@synthesize	errorAtTaskIndex;
@synthesize	errorMessage;
@synthesize	overdueTimeSlotFound;
@synthesize	taskPrimaryKey;

-(id)init{
	if(self=[super init]){
		errorNo=-1;
		taskPrimaryKey=-1;
		errorAtTaskIndex=-1;
	}
	return self;
}

-(void)dealloc{
	[errorMessage release];
	[overdueTimeSlotFound release];
	[super dealloc];
}
@end
