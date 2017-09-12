//
//  ContactView.h
//  iVo_NewAddTask
//
//  Created by Nang Le on 5/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

@interface ContactViewConroller : UIViewController <UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate> {
	id					editedObject;
	UITableView			*tableView;
	UIBarButtonItem		*saveButton;
	NSIndexPath			*oldSelectedIndex;
	NSString			*selectedContact;
	UIView				*contentView;
	NSMutableArray		*indexArrayList;
	
	UISearchBar			*contactSearchBar;
	NSMutableArray		*filterContactList;
	
	BOOL				isSearching;
	BOOL				isEditing;
	BOOL				isFullList;
}
@property (nonatomic, retain)	id				editedObject;
@property (nonatomic, copy)		NSString		*selectedContact;
@property (nonatomic, retain)	NSIndexPath		*oldSelectedIndex;
@property (nonatomic, retain)	NSMutableArray	*indexArrayList;
@property (nonatomic, retain)	NSMutableArray	*filterContactList;
@property (nonatomic, retain)	UISearchBar		*contactSearchBar;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (void)getFilterList:(NSString *)containText; 
@end
