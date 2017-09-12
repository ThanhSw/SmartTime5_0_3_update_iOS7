//
//  TimeSettingViewController.h
//  iVo
//
//  Created by Nang Le on 7/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InfoEditViewController;
@class GeneralListViewController;

@interface TimeSettingViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate> {
	id					editedObject;
	NSInteger			keyEdit;
    UIDatePicker		*datePicker;
	UIBarButtonItem		*saveButton;
	UITableView			*tableView;
	UIView				*mainView;
	BOOL				isOrderDateError;
	
	UILabel				*cellContent0;
	UILabel				*cellContent1;
	UILabel				*cellContent2;
	UILabel				*cellContent3;
	
	NSDate				*cellContent0Val;
	NSDate				*cellContent1Val;
	NSDate				*cellContent2Val;
	NSDate				*cellContent3Val;
	
	NSInteger			cellContent2IntVal;
	NSInteger			cellContent3IntVal;
	NSInteger			allDayEvent;
	
	NSInteger			currentDuration;
	BOOL				isUseDeadLine;
	
	UIAlertView			*alertView;
	NSInteger			pathIndex;
	UIButton			*editRepeatCountButton;
	NSString			*repeatOptions;
	
	//BOOL				isConfigDeadline;
	
	UIButton			*noneButton;
	UIButton			*tomorrowButton;
	UIButton			*todayButton;
	UIButton			*oneWeekButton;
	UIButton			*twoWeeksButton;
	UIButton			*oneMonthButton;
	UIView				*groupButton;
	
//Trung 08101002
/*
	InfoEditViewController		*infoEditView;
	GeneralListViewController	*generalListView;
*/
}

@property (nonatomic, retain)	id			editedObject;
//@property (nonatomic, retain)	UITableView *tableView;
@property (nonatomic, assign)	NSInteger	keyEdit;;
@property (nonatomic, copy)		NSDate		*cellContent0Val;
@property (nonatomic, copy)		NSDate		*cellContent1Val;
@property (nonatomic, copy)		NSDate		*cellContent2Val;
@property (nonatomic, copy)		NSDate		*cellContent3Val;
@property (nonatomic, assign)	NSInteger	cellContent2IntVal;
@property (nonatomic, assign)	NSInteger	cellContent3IntVal;

@property (nonatomic, retain)	UILabel		*cellContent0;
@property (nonatomic, retain)	UILabel		*cellContent1;
@property (nonatomic, retain)	UILabel		*cellContent2;
@property (nonatomic, retain)	UILabel		*cellContent3;

@property (nonatomic, assign)	BOOL		isOrderDateError;
@property (nonatomic, assign)	NSInteger	currentDuration;
@property (nonatomic, assign)	BOOL		isUseDeadLine;
@property (nonatomic, assign)	NSInteger	pathIndex;
@property (nonatomic, copy)		NSString	*repeatOptions;

@property (nonatomic, assign)	NSInteger	allDayEvent;

-(BOOL)checkOrderDateError:(NSInteger)row;
-(void)refreshTitleBarName;
-(void)showDatePicker;
-(void)setAllDay:(id)sender;
-(void)refreshFrames;

@end
