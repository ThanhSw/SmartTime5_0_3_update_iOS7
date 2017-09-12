//
//  GCal2ProjMap.h
//  SmartTime
//
//  Created by Nang Le on 1/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GCal2ProjMap : NSObject {
	NSString	*gCalName;
	NSInteger	projectID;
	
	//NSString	*mappingValue;
}

@property(retain,nonatomic) NSString	*gCalName;
@property(assign,nonatomic) NSInteger	projectID;
//@property(retain,nonatomic) NSString	*mappingValue;
@end
