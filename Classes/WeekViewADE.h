//
//  WeekViewADE.h
//  SmartTime
//
//  Created by Nang Le on 2/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WeekViewADE : UIView {
	NSString	*adeName;
	NSInteger	projectID;
	CGRect		viewFrame;
}

@property(nonatomic,retain) NSString	*adeName;
@property(nonatomic,assign) NSInteger	projectID;
@end
