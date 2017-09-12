//
//  TDDeletedTaskObject.h
//
//  Created by Nang Le Van on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TDDeletedTaskObject : NSObject {
	NSInteger taskId;
	NSTimeInterval deletedTimeInterVal;
}

@property(nonatomic,assign) NSInteger taskId;
@property(nonatomic,assign) NSTimeInterval deletedTimeInterVal;

@end
