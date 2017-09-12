//
//  BackupViewController.h
//  SmartTime
//
//  Created by Nang Le on 10/28/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//@class SmartViewController;

@interface BackupViewController : UIViewController <UITableViewDelegate,UITableViewDataSource > {
	UIButton	*backupToMailButton;
	UITableView *tableView;
	UILabel		*noteLb;
	
	//SmartViewController *SmartViewController;
}

@end
