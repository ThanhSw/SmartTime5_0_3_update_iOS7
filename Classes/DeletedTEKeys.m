//
//  DeleteTEKeys.m
//  SmartTime
//
//  Created by Nang Le on 12/8/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DeletedTEKeys.h"


@implementation DeletedTEKeys
@synthesize primaryKey,syncKey,gcalEventId;

-(id)init{
	self=[super init];
	return self;
}

-(void)dealloc{
	[super dealloc];
}
@end
