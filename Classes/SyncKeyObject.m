//
//  SyncKeyObject.m
//
//  Created by NangLe on 7/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SyncKeyObject.h"


@implementation SyncKeyObject
@synthesize urlString,key,editedObject;

-(id)init{
	if (self=[super init]) {
		
	}
	
	return self;
}

-(void)dealloc{
	[editedObject release];
	[urlString release];
	[super dealloc];
}

-(void)setUrlString:(NSString *)str{
	[urlString release];
	urlString=[str retain];
}

-(void)setEditedObject:(id)obj{
	[editedObject release];
	editedObject=[obj retain];
}

@end
