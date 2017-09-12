//
//  AlertObject.h
//  SmartOrganizer
//
//  Created by Nang Le Van on 9/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AlertObject : NSObject {

	NSInteger amount;
	NSInteger alertBy;
	NSInteger timeUnit;
	
	NSString *alertByString;
	NSString *timeUnitString;
}
@property(nonatomic,assign) NSInteger amount;
@property(nonatomic,assign) NSInteger alertBy;
@property(nonatomic,assign) NSInteger timeUnit;

@property(nonatomic, copy) NSString *alertByString;
@property(nonatomic, copy) NSString *timeUnitString;

@end
