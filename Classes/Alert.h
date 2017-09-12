//
//  Alert.h
//  SmartTime
//
//  Created by Nang Le on 11/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Alert : NSObject {
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
