//
//  SyncWindow2TableViewController.h
//  SmartTime
//
//  Created by Huy Le on 9/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Setting;

@interface EKSyncWindow2TableViewController : UITableViewController {
	UITableView *syncFromTableView;
	UITableView *syncToTableView;
	
	NSInteger syncFromIndex;
	NSInteger syncToIndex;
	
	Setting *setting;
}

@property (nonatomic, assign) Setting *setting;

@end
