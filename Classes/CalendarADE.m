//
//  CalendarADE.m
//  SmartTime
//
//  Created by Left Coast Logic on 1/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CalendarADE.h"


@implementation CalendarADE

@synthesize key;

//trung ST3.1
@synthesize parentKey;
@synthesize startTime;

@synthesize project;
@synthesize name;

- (void)dealloc {
	if (name != nil)
	{
		[name release];
	}
	if (startTime != nil)
	{
		[startTime release];
	}
    [super dealloc];
}

@end
