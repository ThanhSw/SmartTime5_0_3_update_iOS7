//
//  TaskKey.m
//  SmartTime
//
//  Created by Huy Le on 6/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TaskKey.h"


@implementation TaskKey

@synthesize key;
@synthesize parentKey;
@synthesize startTime;

- (void) dealloc
{
	startTime = nil;
	[super dealloc];
}

@end
