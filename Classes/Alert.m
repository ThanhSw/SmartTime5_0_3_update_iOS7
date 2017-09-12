//
//  Alert.m
//  SmartTime
//
//  Created by Nang Le on 11/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Alert.h"

@implementation Alert


-(id)init{
	self=[super init];
	return self;
}

-(void)dealloc{
	[timeUnitString release];
	[alertByString release];
	[super dealloc];
}

#pragma mark properties
//timeUnitString
-(NSString *)timeUnitString{
	return timeUnitString;
}

-(void)setTimeUnitString:(NSString *)aStr{
	[timeUnitString release];
	timeUnitString=[aStr copy];
}

//alertByString
-(NSString *)alertByString{
	return alertByString;
}

-(void)setAlertByString:(NSString *)aStr{
	[alertByString release];
	alertByString=[aStr copy];
}

-(NSInteger)amount{
	return amount;
}
  
-(void)setAmount:(NSInteger)aNum{
	amount=aNum;
}

-(NSInteger)alertBy{
	return alertBy;
}

-(void)setAlertBy:(NSInteger)aNum{
	alertBy=aNum;
}

-(NSInteger)timeUnit{
	return timeUnit;
}

-(void)setTimeUnit:(NSInteger)aNum{
	timeUnit=aNum;
}

@end
