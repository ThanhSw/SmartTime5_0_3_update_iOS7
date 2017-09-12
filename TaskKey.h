//
//  TaskKey.h
//  SmartTime
//
//  Created by Huy Le on 6/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TaskKey : NSObject {

	NSInteger key;
	NSInteger parentKey;
	NSDate *startTime;
}

@property NSInteger key;
@property NSInteger parentKey;
@property (nonatomic, copy) NSDate *startTime;

@end
