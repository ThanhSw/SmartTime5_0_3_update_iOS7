//
//  ServerAlertInfo.m
//  SmartTime
//
//  Created by NangLe on 12/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ServerAlertInfo.h"
#import "Task.h"

@implementation ServerAlertInfo
@synthesize task;
@synthesize alertStrValues;
@synthesize isAddNew;
@synthesize oldDevToken;
@synthesize oldPNSID;
@synthesize newPNSID;
@synthesize newDevToken;

-(void)dealloc{
	[alertStrValues release];
	[task release];
	[oldDevToken release];
	[oldPNSID release];
	[newPNSID release];
	[newDevToken release];
	
	[super dealloc];
}

@end
