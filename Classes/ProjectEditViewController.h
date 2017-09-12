//
//  ProjectEditViewController.h
//  SmartTime
//
//  Created by Huy Le on 9/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProjectEditViewController : UIViewController<UITextFieldDelegate> {
	NSMutableArray *projectList;
	NSInteger projectIndex;
	
	UITextField *projectName;
	UITextField *gcalName;
	
	BOOL eventMap;
}

@property (nonatomic, retain) 	NSMutableArray *projectList;
@property NSInteger projectIndex; 
@property BOOL eventMap;

@end
