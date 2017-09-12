//
//  DateAndList.h
//  SmartTime
//
//  Created by NangLe on 9/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DateAndList : NSObject {
	NSDate *date;
	NSMutableArray *array;
	BOOL	isKeepRecentList;
}
@property(nonatomic,retain) NSDate *date;
@property(nonatomic,retain) NSMutableArray *array;
@property(nonatomic,assign) BOOL	isKeepRecentList;

@end
