//
//  Contacts.m
//  iVo
//
//  Created by Nang Le on 7/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Contacts.h"


@implementation Contacts
@synthesize contactName;
@synthesize contactAddress;
@synthesize contactLastName;
@synthesize emailAddress;
@synthesize phoneNumber;
@synthesize companyName;

-(void)dealloc{
	[contactName release];
	[contactAddress release];
	[contactLastName release];
	[emailAddress release];
	[phoneNumber release];
	[companyName release];
	[super dealloc];	
}

#pragma mark properties
/*
-(NSString *)contactName{
	return contactName;
}

-(void)setContactName:(NSString *)aName{
	[contactName release];
	contactName=[aName copy];
}

-(NSString *)contactAddress{
	return contactAddress;
}

-(void)setContactAddress:(NSString *)aAddr{
	[contactAddress release];
	contactAddress=[aAddr copy];
}

-(NSString *)emailAddress{
	return emailAddress;
}

-(void)setEmailAddress:(NSString *)aAddr{
	[emailAddress release];
	emailAddress=[aAddr copy];
}

-(NSString *)contactLastName{
	return contactLastName;
}

-(void)setContactLastName:(NSString *)ln{
	[contactLastName release];
	contactLastName=[ln copy];
}


-(NSString *)phoneNumber{
	return phoneNumber;
}

-(void)setPhoneNumber:(NSString *)pn{
	[phoneNumber release];
	phoneNumber=[pn copy];
}
*/
@end
