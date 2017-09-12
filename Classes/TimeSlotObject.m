//
//  TimeSlotObject.m
//  SmartOrganizer
//
//  Created by Nang Le Van on 8/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TimeSlotObject.h"


@implementation TimeSlotObject
@synthesize startTimeInMinutes;
@synthesize endTimeInMinutes;

-(id)init{
	return [super init];
}

-(void)dealloc{	
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone{
	TimeSlotObject *ret=[[TimeSlotObject alloc] init];
	ret.startTimeInMinutes=self.startTimeInMinutes;
	ret.endTimeInMinutes=self.endTimeInMinutes;
	return ret;
}

@end
