//
//  AlertEditController.h
//  iVo_NewAddTask
//
//  Created by Nang Le on 5/8/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AlertViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,UIWebViewDelegate> {
	id editedObject;
	UITableView *tableView;
	NSMutableArray *alertValues;
}
@property (nonatomic, retain)	id editedObject;
@property (nonatomic, retain)	NSMutableArray *alertValues;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
@end
 