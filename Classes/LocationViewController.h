//
//  LocationViewController.h
//  iVo
//
//  Created by Nang Le on 7/8/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LocationViewController : UIViewController < UITableViewDataSource, UITableViewDelegate,
														UITextViewDelegate,UITextFieldDelegate > 
{

	id					editedObject;
	UITableView			*tableView;
	UIBarButtonItem		*saveButton;
	NSIndexPath			*oldSelectedIndex;
	
	NSString			*selectedLocation;
	UIView				*contentView;
	UISegmentedControl	*sortAddress;
	//UITextField			*currentSelectLocation;
	
	NSMutableArray		*indexArrayList;
}
@property (nonatomic, retain)	id				editedObject;
@property (nonatomic, copy)		NSString		*selectedLocation;
@property (nonatomic, retain)	NSIndexPath		*oldSelectedIndex;
@property (nonatomic, retain)	NSMutableArray	*indexArrayList;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
-(void)refreshFrames;

//- (void)setUpDisplayList:(BOOL)isSortByName;


@end
