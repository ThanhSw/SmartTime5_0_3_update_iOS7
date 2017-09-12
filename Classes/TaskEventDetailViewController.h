//
//  TaskEventDetailViewController.h
//  iVo
//
//  Created by Nang Le on 8/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;
//@class AlertViewController;
@class WhatViewController;
@class SmartStartView;
@class SmartViewController;
@class InfoEditViewController;
@class ProjectViewController;
@class GeneralListViewController;
@class TimeSettingViewController;


@interface TaskEventDetailViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
	NSInteger				keyEdit;
	NSInteger				typeEdit;//0: add/edit task/normal event; 1:edit RE
	UIView					*contentView;
	UITableView				*tableView;
	
	Task					*taskItem;
//	AlertViewController		*alertView;
	UIAlertView				*alertViewAddPassedDue;
	UIAlertView				*alertViewAddEventTaskPassedDue;
	UIAlertView				*alertViewUpdateItselfPassedDue;//itself passed due
	UIAlertView				*alertViewUpdateTasksPassedDue;//makes some tasks passed due
	
	UISegmentedControl		*segmentedTaskStyleControl;
	UISegmentedControl		*segmentedContextControl;
	
	//task title
	UITextField				*taskTitleTextField;
	UITextField				*taskLocation;
	UITextField				*taskNotesTextField;
	
	UILabel					*howLongInfo;
	UIButton				*firstIconPeriod;
	UIButton				*secondIconPeriod;
	UIButton				*thirdIconPeriod;
	
//	UIButton				*whenNone;
//	UIButton				*whenOneWeek;
//	UIButton				*whenOneMonth;
	
/*	UILabel					*whenInfo;
	UILabel					*taskDate;
	UILabel					*taskTime;
	UIView					*taskDueButton;
*/	
    SmartStartView			*smartStartView;												
	NSString				*oldTaskName;
	UILabel					*smartStart;
	
	SmartViewController		*rootViewControler;	
	UIBarButtonItem			*doneButton;
	
	UIView					*durationButtonView;
	UILabel					*durationLabel;
	UIButton				*editTitleButon;
	UIButton				*editHLButon;
//	UIButton				*editWhenButon;
	BOOL					transitioning;
	UILabel					*repeatInfo;
	
	UIAlertView				*editREInstanceAlert;
	NSInteger				currentREEditType;
	BOOL					isPopingDownSmartStartView;
	
	UISwitch			*allDaySwitch;
	
	UILabel					*dueLabel;
	UILabel					*dueInfo;	
	UIView					*dueButtonView;
	UIButton				*editDueButon;

	UILabel					*startLabel;
	UILabel					*startInfo;	
	UIView					*startButtonView;
	UIButton				*editStartButon;	
	
	BOOL					isUpdatedDue;
	UIView *hintView;
}

@property (nonatomic, assign)	NSInteger				keyEdit;
@property (nonatomic, assign)	NSInteger				typeEdit;
@property (nonatomic,retain)	Task					*taskItem;
@property (nonatomic,copy)		NSString				*oldTaskName;
@property (nonatomic,retain)	SmartViewController		*rootViewControler;
@property (nonatomic, assign)	BOOL					isUpdatedDue;


-(void)refreshTaskTitle:(NSInteger)whatIconNo;
-(void)callAlert:(NSString *)message;
-(void)refreshTaskHowLong;
//-(void)refreshTaskWhen;
-(void)refreshTitleBarName;
-(void)refreshTaskDue;
-(void)refreshDueWhenChangeContext:(NSDate *)fromDate context:(NSInteger)context;
-(void)popupSmartStartView;
-(void)popDownSmartStartView;
-(void)dispatchFirstTouchAtPoint:(CGPoint)touchPoint forEvent:(UIEvent *)event;
-(void)refreshTaskStart;
-(void)refreshFrames;

@end
