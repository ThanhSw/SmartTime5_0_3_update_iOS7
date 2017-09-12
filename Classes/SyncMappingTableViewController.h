//
//  SyncMappingTableViewController.h
//  SmartTime
//
//  Created by Huy Le on 9/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GuideWebView;

@interface SyncMappingTableViewController : UITableViewController {
	UITableView *projectTableView;
	UITableView *gcalTableView;
	
	UIView *syncWindowCellView;
	
	UIToolbar *bottomToolbar;	
	
	NSArray *copyProjectList;
	
	NSMutableArray *gcalList;
	
	BOOL eventMap;
	
	//UILabel *hintLabel;
	GuideWebView *hintLabel;
	UIButton *hintOKButton;
	UIButton *hintDontShowButton;	
	UIView *hintView;
	
	UIButton *autoMapButton;
	UIButton *connectButton;
	
	BOOL firstTimeLoad;
	BOOL isConnecting;
	
	BOOL isExistedMappings;	
	BOOL isFirstTimeLoadView;
	
	UIButton *stepHintButtonView;
	NSInteger moveToIndex;
	NSInteger moveTimes;
}

@end
