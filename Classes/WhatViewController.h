//
//  WhatViewController.h
//  iVo
//
//  Created by Nang Le on 8/15/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@class ContactViewConroller;
@class LocationViewController;

@interface WhatViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,
UITextFieldDelegate,UITextViewDelegate,ABPeoplePickerNavigationControllerDelegate> {
	id						editedObject;
	UITableView				*tableView;
	NSString				*taskTitle;
	NSString				*taskContact;
	NSString				*taskLocation;
	NSString				*taskEmailToSend;
	NSString				*phoneToContact;
	
	UIButton				*gotoButton;
	UIButton				*callButton;
	UIButton				*buyButton;
	UIButton				*mailButton;
	UIButton				*meetButton;
	NSInteger				whatSelected;
	
	UITextField				*taskTitleEditField;
	
	NSString				*oldContact;

	UILabel					*instrustion;
	UIView					*whatButtonGroup;
	
	UITextView				*loctionTextView;
	UIView					*contentView;
	
	UIButton				*editLocationButton;
    
    UIView *doneBarView;
    UIButton *deleteButton;
    UIButton *doneButton;
    BOOL isEditingLocation;
    
}
@property (nonatomic, retain)	id			editedObject;
@property (nonatomic, copy)		NSString	*taskTitle;
@property (nonatomic, copy)		NSString	*taskContact;
@property (nonatomic, copy)		NSString	*taskLocation;
@property (nonatomic, assign)	NSInteger	whatSelected;
@property (nonatomic, copy)		NSString	*oldContact;
@property (nonatomic, copy)		NSString	*taskEmailToSend;
@property (nonatomic, copy)		NSString	*phoneToContact;

-(void)toggleWhatButton:(NSInteger)buttonNo;
-(void)refreshTaskTitle:(NSInteger)whatIconNo;
-(void)editContact;
-(void)editLocation:(id)sender;
-(void)done:(id)sender;
-(void)refreshFrames;

//-(void)showView:(NSInteger)type date:(NSDate *)date;

@end
