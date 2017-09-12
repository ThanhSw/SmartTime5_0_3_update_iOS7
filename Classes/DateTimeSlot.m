//
//  DateTimeSlot.m
//  iVo
//
//  Created by Nang Le on 7/31/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DateTimeSlot.h"


@implementation DateTimeSlot
@synthesize indexAt;
@synthesize timeSlotDate;
@synthesize isOverDue,isPassedDeadLine;
@synthesize isNotFit;

 -(id)init{
	 if(self=[super init]){
		 isNotFit=NO; 
	 }
	 
 return self;
 }

-(void)dealloc{
	[timeSlotDate release];
	[super dealloc];
}

@end
