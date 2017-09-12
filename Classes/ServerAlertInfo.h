//
//  ServerAlertInfo.h
//  SmartTime
//
//  Created by NangLe on 12/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Task;
@interface ServerAlertInfo : NSObject {
	Task *task;
	NSString *alertStrValues;
	BOOL isAddNew;
	NSString *oldDevToken;
	NSString *oldPNSID;
	NSString *newDevToken;
	NSString *newPNSID;
}

@property(retain,nonatomic) Task *task;
@property(retain,nonatomic) NSString *alertStrValues;
@property(assign,nonatomic) BOOL isAddNew;
@property(retain,nonatomic) NSString *oldDevToken;
@property(retain,nonatomic) NSString *oldPNSID;
@property(retain,nonatomic) NSString *newDevToken;
@property(retain,nonatomic) NSString *newPNSID;

@end
