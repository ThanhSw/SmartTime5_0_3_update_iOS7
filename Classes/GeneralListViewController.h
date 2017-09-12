//
//  GeneralListViewController.h
//  iVo
//
//  Created by Nang Le on 7/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GeneralListViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate> {
	id					editedObject;
	NSInteger			keyEdit;
	UITableView			*tableView;
	UIBarButtonItem		*saveButton;
	NSInteger			pathIndex;
	NSInteger			currentIndex;
	
	UIView				*repeatOptionWeeklyView;
	UIView				*repeatOptionMonthlyView;
	
	UILabel				*repeatEveryLB;
	UITextField			*textField;
	UILabel				*repeatEveryUnitLB;
	UIView				*contentView;
	
	UIButton			*sunButton;
	UIButton			*monButton;
	UIButton			*tueButton;
	UIButton			*wedButton;
	UIButton			*thuButton;
	UIButton			*friButton;
	UIButton			*satButton;
	
	UIButton			*dayNumberButton;
	UIButton			*dayWeekButton;
	
	NSInteger			repeatEvery;
	NSString			*repeatOn;
	NSInteger			repeatBy;
	NSString			*repeatOptions;
	
	UILabel				*syncTypeNotes;
}

@property (nonatomic, retain) id editedObject;
@property (nonatomic, assign) NSInteger keyEdit;
@property (nonatomic, assign) NSInteger pathIndex;
@property (nonatomic, copy) NSString	*repeatOptions;
@property (nonatomic, copy) NSString	*repeatOn;

-(void)refreshTitleBarName;
-(void)popDownKeyboard;
-(void)toggleButtonState:(UIButton *)button 
   normalStateTitleColor:(UIColor *)normalStateTitleColor 
   selectStateTitleColor:(UIColor *)selectStateTitleColor;
-(void)setAllCheckBoxesOff;
-(void)setCheckBoxOn:(NSInteger)value;
-(void)resetCheckboxes:(NSString *)valueList;
-(void)getCheckedList;
-(void)toggleMonthPin:(id)sender;

@end
