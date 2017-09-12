//
//  DateAndList.m
//  SmartTime
//
//  Created by NangLe on 9/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DateAndList.h"


@implementation DateAndList
@synthesize date;
@synthesize array;
@synthesize isKeepRecentList;

-(void)dealloc{
	[date release];
	[array release];
	[super dealloc];
}

@end
