//
//  WyswigEdit.h
//  iVo_NewAddTask
//
//  Created by Nang Le on 5/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LocationViewController;

@interface InfoEditViewController : UIViewController <UITextFieldDelegate,UITextViewDelegate,UITableViewDelegate,UITableViewDataSource> {
	UIView				*contentView;
	id					editedObject;
	UITextField			*textField;
	NSString			*textValue;
	UITableView			*tableView;
	UIBarButtonItem		*saveButton;
	NSInteger			keyEdit;
	NSInteger			secondKeyEdit;
	
	UILabel				*locationInfo;
	NSString			*selectedLocation;
	
	UILabel				*REInstruction;
	UILabel				*dayUnit;
	
	UITextView			*editTextView;
	NSMutableArray		*gCalList;
	
	NSInteger			pathIndex;
	UIView				*doneBarView;
	UIButton			*doneButton;
	NSMutableArray		*usedGcalsList;
}
@property (nonatomic, retain) id			editedObject;
@property (nonatomic, retain) NSString		*textValue;
@property (nonatomic, assign) NSInteger		keyEdit;
@property (nonatomic, assign) NSInteger		secondKeyEdit;
@property (nonatomic, assign) NSInteger		pathIndex;
@property (nonatomic, retain) NSMutableArray	*gCalList;
@property (nonatomic, retain) NSMutableArray	*usedGcalsList;


- (void)setNavTitle:(NSString *)aString;
//- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
-(void)refreshTitleBarName;

@end
 