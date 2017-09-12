//
//  TimeSlotObject.h
//  SmartOrganizer
//
//  Created by Nang Le Van on 8/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TimeSlotObject : NSObject {
	NSInteger startTimeInMinutes;
	NSInteger endTimeInMinutes;
}

@property(nonatomic,assign) NSInteger startTimeInMinutes;
@property(nonatomic,assign) NSInteger endTimeInMinutes;

- (id)copyWithZone:(NSZone *)zone;

@end
