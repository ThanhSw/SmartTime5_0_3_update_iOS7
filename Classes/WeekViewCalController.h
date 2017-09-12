//
//  WeekViewCalController.h
//  SmartTime
//
//  Created by Nang Le on 2/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Task;
@class SmartViewController;
@class WeeklyViewSkin;
@class WeekViewTimeFinder;

@interface WeekViewCalController : UIViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIScrollViewDelegate> {
	UIToolbar *topToolbar;
	UILabel	*sunLabel;
	UILabel	*monLabel;
	UILabel	*tueLabel;
	UIButton *monthNameButton;
	UILabel	*thuLabel;
	UILabel	*friLabel;
	UILabel	*satLabel;
	
	UIView	*contentView;
	UITableView	*sunTableView;
	UITableView	*monTableView;
	UITableView	*tueTableView;
	UITableView	*wedTableView;
	UITableView	*thuTableView;
	UITableView	*friTableView;
	UITableView	*satTableView;
	//UITableView *headerView;
	UIScrollView  *headerView;	
	
	WeeklyViewSkin *skinView;
	WeekViewTimeFinder *timeFinderView;	
	UIView *pageView;
	
	NSMutableArray *sunList;
	NSMutableArray *monList;
	NSMutableArray *tueList;
	NSMutableArray *wedList;
	NSMutableArray *thuList;
	NSMutableArray *friList;
	NSMutableArray *satList;
	
	NSMutableArray *adeList;
	
	UIView	*containerView;
	UILabel	*toolbarTitle;
	NSDate	*currentDisplayDate;
	NSDate	*firstDateInWeek;
	NSDate	*lastDateInWeek;
	
	//UIView	*adeView;
	
	NSInteger sunMonthDay;
	NSInteger monMonthDay;
	NSInteger tueMonthDay;
	NSInteger wedMonthDay;
	NSInteger thuMonthDay;
	NSInteger friMonthDay;
	NSInteger satMonthDay;
	NSString	*monthName;
	
	UIDatePicker	*jumpToDateDP;
	UIView			*optionView;
	BOOL			isPoppedUp;
	BOOL			isTransition;
	
	UIButton	*prevButton;
	UIButton	*nextButton;
	UIButton	*addNewButton;
	UIButton	*leftButton;
	UIButton	*rightButton;
	UIButton	*doneButton;
	
	NSDate *monday;
	NSDate *tueday;
	NSDate *wednesday;
	NSDate *thusday;
	NSDate *friday;
	
	//UIView	*groupDayView;
	
	NSInteger selectedWD;
	NSInteger previousSelectedWD;
	
	UISegmentedControl *segBar;
	
	//for add new tasks/events
	//UIView *optSubView;
	UITextField *taskNameTF;
	UIButton	*taskStartBT;
	UILabel *toggleLB;
	//UISegmentedControl *contextSeg;
	UIButton	*homeButton;
	UIButton	*workButton;
	UILabel *typeDurLB;
	
	//duration buttons
	UIButton				*firstIconPeriod;
	UIButton				*secondIconPeriod;
	UIButton				*thirdIconPeriod;
	UIButton				*fourthIconPeriod;
	
	//project buttons
	UIButton		*urgentButton;
	UIButton		*privateButton;
	UIButton		*noneButton;
	UIButton		*projectAButton;
	UIButton		*projectBButton;
	UIButton		*projectCButton;
	
	UIButton		*project7Button;
	UIButton		*project8Button;
	UIButton		*project9Button;
	UIButton		*project10Button;
	UIButton		*project11Button;
	UIButton		*project12Button;
	
	//for filtering
	//UISegmentedControl	*taskTypeSeg;
	UIButton *taskButton;
	UIButton *eventButton;
	
	Task *newTask;
//	NSMutableArray *displayList;
	BOOL			isFilter;
	
	UIImageView    *filterModeView;
	SmartViewController	*SmartViewController;
	
	UIView *titleView;
	
	//
	UIImageView *sunClockDur;
	UIImageView *monClockDur;
	UIImageView *tueClockDur;
	UIImageView *wedClockDur;
	UIImageView *thuClockDur;
	UIImageView *friClockDur;
	UIImageView *satClockDur;
	
	BOOL		isBackFromMonthView;
	
	UIView *optSubView;
    
    NSInteger cellWidth;
}

@property(nonatomic,retain) Task *newTask;

@property(nonatomic,retain) UIView *optSubView;

@property(nonatomic, assign) BOOL		isBackFromMonthView;
@property(nonatomic,retain) NSMutableArray *sunList;
@property(nonatomic,retain) NSMutableArray *monList;
@property(nonatomic,retain) NSMutableArray *tueList;
@property(nonatomic,retain) NSMutableArray *wedList;
@property(nonatomic,retain) NSMutableArray *thuList;
@property(nonatomic,retain) NSMutableArray *friList;
@property(nonatomic,retain) NSMutableArray *satList;
@property(nonatomic,retain) NSMutableArray *adeList;

@property (nonatomic,retain) UIView	*containerView;

@property (nonatomic,retain) UIToolbar *topToolbar;
@property (nonatomic,retain) UILabel	*toolbarTitle;

@property (nonatomic,retain) NSDate	*currentDisplayDate;
@property (nonatomic,retain) NSDate	*firstDateInWeek;
@property (nonatomic,retain) NSDate	*lastDateInWeek;

@property (nonatomic,assign) NSInteger sunMonthDay;
@property (nonatomic,assign) NSInteger monMonthDay;
@property (nonatomic,assign) NSInteger tueMonthDay;
@property (nonatomic,assign) NSInteger wedMonthDay;
@property (nonatomic,assign) NSInteger thuMonthDay;
@property (nonatomic,assign) NSInteger friMonthDay;
@property (nonatomic,assign) NSInteger satMonthDay;

@property (nonatomic,retain) NSString	*monthName;

@property(nonatomic,retain) NSDate *monday;
@property(nonatomic,retain) NSDate *tueday;
@property(nonatomic,retain) NSDate *wednesday;
@property(nonatomic,retain) NSDate *thusday;
@property(nonatomic,retain) NSDate *friday;
//@property(nonatomic,retain) NSMutableArray *displayList;

@property(nonatomic,retain) SmartViewController	*SmartViewController;

-(void)refreshTableViews;
-(void)setupDisplayList:(NSDate *)forDate;
-(void)refreshADEView;
-(void)refreshTableViewsSize:(UITableView *)tableView;

-(void)popUpOptionView;
-(void)popDownOptionView;
-(void)popUpDatePicker;
-(void)popDownDatePicker;
- (UIButton *)getButton:(NSString *)title 
			 buttonType:(UIButtonType)buttonType
				  frame:(CGRect)frame
				 target:(id)target
			   selector:(SEL)selector
   normalStateTextColor:(UIColor *)normalStateTextColor
 selectedStateTextColor:(UIColor *)selectedStateTextColor;
-(void)addNew:(id)sender;
-(void)projSelected:(id)sender;
-(void)periodChanged:(id)sender;
-(void)setupOptionSubView;
-(void)contextChanged:(id)sender;
-(double)usedDurationInDay:(NSMutableArray *)list;
-(void)refreshClockDuration;
-(UIImageView *)setImageForClockDuration:(double)duration;

-(void)showView:(NSInteger)type date:(NSDate *)date;
-(void)getStateForExisting;

@end
