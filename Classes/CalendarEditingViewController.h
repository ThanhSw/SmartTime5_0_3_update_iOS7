//
//  SyncToodledoSetupViewController.h
//  SmartOrganizer
//
//  Created by NangLe on 8/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Projects;

@interface CalendarEditingViewController : UIViewController <UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UIAlertViewDelegate> {
	UIView *contentView;
	//UIToolbar *toolbar;
	//UILabel *titleLb;
	
	id				editedObject;
	NSInteger		editedKey;
	UITextField		*projectNameTextField;
	
	//UILabel				*fontColorLabel;
	//UIButton			*fontColorBt;
	//UIPickerView		*colorDPView;
	
	Projects			*editedCalendar;
	
	//BOOL				isColorPickerShowed;
	
	UIBarButtonItem		*saveButton;
	
	UIButton *resetToodleSyncBt;
	UIButton *deleteBt;
	
	UIButton *defaultCalendarBt;
	UIButton *showHidebt;
	
	UIAlertView *resetAlertView;
	UIAlertView *deleteAlertView;
	
	//for Quick Add
	BOOL isQuickAdd;
//	UISegmentedControl *projectTypeSeg;
//	UILabel *projectTypeLb;
	
	NSMutableArray *buttonsList;
}

@property(retain,nonatomic) id	editedObject;
@property(assign,nonatomic) NSInteger	editedKey;
@property(retain,nonatomic) Projects	*editedCalendar;
@property(retain,nonatomic) UITextField	*projectNameTextField;
@property(assign,nonatomic) BOOL isQuickAdd;
@property(retain,nonatomic) NSMutableArray *buttonsList;

-(void)showPickerView:(UIPickerView *)picker;
-(void)reloadData;
-(void)loadColorPicker:(id)sender;
-(void)saveCalendar:(id)sender;
-(void)refreshFrames;

@end
