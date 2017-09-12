//
//  EKOneWaySyncObject.h
//  SmartOrganizer
//
//  Created by Nang Le Van on 4/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Task;
@class Projects;

@interface EKOneWaySyncObject : NSObject {
    Projects *project;
	Task *event;
	NSInteger originalCalendarId;
	NSInteger updateType;
}

@property(nonatomic,retain) Projects *project;
@property(nonatomic,retain) Task *event;
@property(nonatomic,assign) NSInteger originalCalendarId;
@property(nonatomic,assign) NSInteger updateType;

@end
