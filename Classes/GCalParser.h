//
//  ICalParser.h
//  SmartTime
//
//  Created by Left Coast Logic on 11/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Task;

@interface GCalParser : NSObject {
	NSDate *startDate;
	NSDate *endDate;
	NSDictionary *rruleDict;
	NSMutableArray *components;
	BOOL isADE;
	BOOL adeCheck;
}

@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;
@property (nonatomic, retain) NSDictionary *rruleDict;
@property (nonatomic, retain) NSMutableArray *components;
@property BOOL isADE;

-(void) updateRE:(Task *)re;
-(void) parse:(NSString *)data;

@end
