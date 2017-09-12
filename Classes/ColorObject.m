//
//  ColorObject.m
//  SmartOrganizer
//
//  Created by Nang Le Van on 8/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ColorObject.h"


@implementation ColorObject
@synthesize R1,G1,B1,R2,G2,B2,R3,G3,B3;

-(id)init{
	if (self=[super init]) {
		
	}
	
	return self;
}

-(void)dealloc{
	[super dealloc];
}

@end
