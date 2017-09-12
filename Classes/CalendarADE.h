//
//  CalendarADE.h
//  SmartTime
//
//  Created by Left Coast Logic on 1/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CalendarADE : NSObject {
	NSInteger key;

	//trung ST3.1
	NSInteger parentKey;
	NSDate *startTime;
	
	NSInteger project;
	NSString *name;
}

@property NSInteger key;

//trung ST3.1 
@property NSInteger parentKey;
@property (nonatomic, copy) NSDate *startTime;

@property NSInteger project;
@property (nonatomic, copy) NSString *name;


@end
