//
//  DeleteTEKeys.h
//  SmartTime
//
//  Created by Nang Le on 12/8/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DeletedTEKeys : NSObject {
	NSInteger	primaryKey;
	double		syncKey;
	NSString	*gcalEventId;
}
@property(nonatomic, assign) NSInteger	primaryKey;
@property(nonatomic, assign) double		syncKey;
@property(nonatomic, retain) NSString	*gcalEventId;
@end
