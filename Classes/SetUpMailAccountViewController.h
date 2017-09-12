//
//  SetUpMailAccountViewController.h
//  SmartTime
//
//  Created by Nang Le on 10/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SetUpMailAccountViewController : UIViewController <UITextFieldDelegate> {
	id			editedObject;
	NSString	*userName;
	NSString	*passWord;
	UITextField	*userNameTextFiedl;
	UITextField	*passWordTextFiedl;
	UIView		*contentView;
	UIBarButtonItem *saveButton;
}
@property (nonatomic, retain)	id		editedObject;
@property (nonatomic, copy)	NSString	*userName;
@property (nonatomic, copy)	NSString	*passWord;

-(void)deParseAccount:(NSString *)mixedAccount;
-(NSString *)createAccount:(NSString *)username password:(NSString *)password;

@end
