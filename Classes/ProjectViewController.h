//
//  ProjectViewController.h
//  iVo_NewAddTask
//
//  Created by Nang Le on 5/6/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InfoEditViewController;
//@class GCalSync;

@interface ProjectViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate> {
	id						editedObject;
	NSInteger				keyEdit;
	UITableView				*tableView;
	UIBarButtonItem			*saveButton;
	UIBarButtonItem			*doneButton;	
	NSInteger				pathIndex;

//Trung 08101002
	
//	NSMutableArray			*projectsListBackup;
	NSMutableArray			*cellList;
	BOOL					isSaved;
	BOOL					isGoingBack;
	
	UIBarButtonItem			*addBarBt;
	UIBarButtonItem			*showAllProjectsBt;
	
	NSMutableArray			*visibleProjectList;
}

@property (nonatomic, retain) id				editedObject;
@property (nonatomic, assign) NSInteger			keyEdit;
@property (nonatomic, assign) NSInteger			pathIndex;
//@property (nonatomic, assign) NSMutableArray	*projectsListBackup;
@property (nonatomic, retain) NSMutableArray	*visibleProjectList;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
-(void)refreshTitleBarName;

@end
 