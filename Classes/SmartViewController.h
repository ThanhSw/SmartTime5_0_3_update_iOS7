//
//  iVoProtoTypesViewController.h
//  iVoProtoTypes
//
//  Created by Nang Le on 6/19/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuartzCore/QuartzCore.h"
#import "SmartTimeView.h"
#import "IvoCommon.h"
#import "Task.h"
#import "AdMobDelegateProtocol.h";

//@protocol TransitionViewDelegate <NSObject>
//@optional
//- (void)transitionViewDidStart:(UIView *)view;
//- (void)transitionViewDidFinish:(UIView *)view;
//- (void)transitionViewDidCancel:(UIView *)view;
//@end

//#define AD_REFRESH_PERIOD 10.0 // display fresh ads once per minute

@class CalendarPageView;
@class SmartTimeView;
@class CalendarView;
@class TaskEventDetailViewController;
@class SettingView;
@class FilterView;
@class InfoEditViewController;
@class ProjectViewController;
@class GeneralListViewController;
@class TimeSettingViewController;
@class ListTaskView;
@class HistoryViewController;
@class AboutUsView;
//@class AboutUsWebView;

@class AdMobView;
//@class LCLAdsView;
@class WeekViewCalController;
@class WeekView;
@class RoundedRectView;
//@class GCalSync;
@class WBProgressHUD;
//@class ToodleSync;

@interface SmartViewController : UIViewController  <UINavigationBarDelegate,
													UIActionSheetDelegate,AdMobDelegate>
{
	UIView						*containerView;
	CalendarPageView			*calendarView;
	ListTaskView				*listTaskView;
	HistoryViewController		*historyView;
	FilterView					*filterView;
	SettingView					*settingView;
	UIView						*contentView;
	UIView						*contentMainView;
	UISegmentedControl			*buttonBarSegmentedControl;
	UIToolbar					*settingToolbar;
	
	NSInteger					previousCallerView;
	BOOL						isListviewCalled;
	BOOL						isAddNew;
	NSInteger					newTaskPrimaryKey;
	
	UIBarButtonItem				*infoSettingButton;
	UIBarButtonItem				*addButton;
	UIBarButtonItem				*cancelButton;
	UIBarButtonItem				*deleteButton;
	UIBarButtonItem				*doneButton;
	UIBarButtonItem				*todayButton;
	UIBarButtonItem				*filterButton;
	UIBarButtonItem				*noneFilterButton;
	UIBarButtonItem				*fullDoneButton;
	UIBarButtonItem				*aboutUs;
	UIBarButtonItem				*flexItem;
	UIBarButtonItem				*syncButton;
	UIBarButtonItem				*segItem;
	
	UIToolbar					*toolbar;
	BOOL						isFilter;
	BOOL						isEdit;
	UISegmentedControl			*segmentedControlEdit;
	NSArray						*toolbarNormalModeItems;
	NSArray						*toolbarEditModeItems;
	UIAlertView					*delayAlert;
	UIAlertView					*deleteREAlertView;
	
	AboutUsView					*aboutUsView;
	BOOL						transitioning;
	UIView						*backSideContentView;
	NSInteger					delayType;
	BOOL						isDeferingTask;
	BOOL						appFirstStart;
	
	UIActionSheet				*quickEditActionSheet;
	UIActionSheet				*outActionSheet;
	
	NSString					*queryToDoTodayClause;
	NSInteger					currentSelectedKey;
	
	UIAlertView					*deleteConfirmAlertView;
	
	NSArray						*phoneList;
	UIAlertView					*callConfirm;
	UIAlertView					*smsConfirm;
	NSDate						*selectedWeekDate;
	
	UIView						*jumpToDateView;
	UIDatePicker				*jumpToDateDP;
	UIButton					*titleView;
	BOOL						isJump2DatePKPopUp;
	BOOL						isAnotherViewLoaded;
	
	UIAlertView					*markDoneEventAlert;
	
	NSTimer						*refreshTimer;
	
	UIImageView *startupView;
	
	
	//AdMob
	AdMobView *adMobAd;   // the actual ad; self.view is the location where the ad will be placed
	NSTimer *autoslider; // timer to slide in fresh ads
	NSString *keywords;
	NSString *searchingKeyWords;
	
	UIActionSheet	*upgradeAS;
//	LCLAdsView *LCLAd;
	
	UIBarButtonItem *lclPageBarBt;
	WeekViewCalController *weekViewController;
	
	WeekView *weekView;
	RoundedRectView *guideView;
	
	UIButton *syncBt;
	
	//EK Sync
	WBProgressHUD *syncProgressView;

	UIAlertView *syncAlertView;
	
	UIBarButtonItem *projectDisplayBt;
	//ToodleSync *toodledoSync;
    
    BOOL needCheckAutoSync;
}

@property (nonatomic, retain)	UIBarButtonItem			*lclPageBarBt;
@property (nonatomic, retain)	UIView					*containerView;
@property (nonatomic, assign)	BOOL					isAddNew;
@property (nonatomic, assign)	NSInteger				newTaskPrimaryKey;
@property (nonatomic, assign)	BOOL					transitioning;
@property (nonatomic, assign)	NSInteger				previousCallerView;

@property (retain,nonatomic)	UIToolbar				*toolbar;
@property (retain,nonatomic)	UIButton				*syncBt;

@property (retain,nonatomic)	NSArray					*phoneList;
@property (nonatomic, retain)	NSDate					*selectedWeekDate;
@property (nonatomic, retain)	UIButton				*titleView;
@property (nonatomic, retain)	NSString				*keywords;
@property (nonatomic, retain)	NSString				*searchingKeyWords;
@property (nonatomic, assign)	NSInteger				currentSelectedKey;
@property (nonatomic, retain)	UISegmentedControl		*buttonBarSegmentedControl;
@property (nonatomic, retain)	UISegmentedControl		*segmentedControlEdit;
@property (nonatomic, retain)	UIBarButtonItem			*doneButton;

@property (nonatomic,assign) BOOL                       needCheckAutoSync;
@property (nonatomic,assign) BOOL						isFilter;

//@property (nonatomic, retain)	ToodleSync				*toodledoSync;

-(void)resetIVoStyle;
-(void) resetQuickEditMode:(BOOL)isInEdit taskKey:(NSInteger)taskKey;
-(void)transitionView;
-(void)pushSettingsRelativeView:(infoEditKey)keyEdit editObject:(id)editObject;
- (void)replaceSubview:(UIView *)oldView withSubview:(UIView *)newView transition:(NSString *)transition 
			 direction:(NSString *)direction duration:(NSTimeInterval)duration controlView:(UIView *)controlView;

- (UIButton *)buttonWithTitle:(NSString *)title
					   target:(id)target
					 selector:(SEL)selector
						frame:(CGRect)frame
						image:(NSString *)image
				 imagePressed:(NSString *)imagePressed
				darkTextColor:(BOOL)darkTextColor;

-(void)filterTask:(id)sender;
-(void)applyFilter:(NSString *)queryClause doTodayClause:(NSString *)queryDoTodayClause;
-(void)addNew:(id)sender;
-(void)editTask:(NSInteger)keyEdit;
-(void)editTaskFromListView:(Task*)task;
-(void)refreshViews;
-(NSInteger)selectedKey;

//trung ST3.1
-(NSInteger)getSelectedTaskKey;

-(void)freeChildControllerToSaveSapce;
-(void)freeOffScreenViews;
-(void)backupDataToMail;

-(void)popUpJumpDate;

-(void)popDownJumpDate;


- (void) cacheImage;
- (UIImage *) getCachedImage;

////

-(void)startSyncIndicator;
-(void)stopSyncIndicator;
-(void)prepareForAnotherViews;
-(void)startRefreshTasks;
-(void)refreshAfterDupDeletion;

@end

