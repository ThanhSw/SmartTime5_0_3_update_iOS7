//
//  GCal2ProjMap.m
//  SmartTime
//
//  Created by Nang Le on 1/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GCal2ProjMap.h"


@implementation GCal2ProjMap
@synthesize gCalName,projectID;//,mappingValue;

-(id)init{
	if(self=[super init]){
		
	}
	
	return self;
}

-(void)dealloc{
	[gCalName release];
	//[mappingValue release];
	[super dealloc];
}
@end
