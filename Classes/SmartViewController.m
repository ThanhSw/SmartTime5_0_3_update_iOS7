//
//  iVoProtoTypesAppDelegate.m
//  iVoProtoTypes
//
//  Created by Nang Le on 6/19/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "SmartViewController.h"
#import "CalendarView.h"
#import "TaskEventDetailViewController.h"
#import "SettingView.h"
#import "FilterView.h"
#import "QuartzCore/QuartzCore.h"
#import "SmartTimeView.h"
#import "ivo_Utilities.h"
#import "IvoCommon.h"
#import "InfoEditViewController.h"
#import "SmartTimeAppDelegate.h"
#import "ProjectViewController.h"
#import "Setting.h"
#import "GeneralListViewController.h"
#import "TimeSettingViewController.h"
#import "TaskManager.h"
#import "ListTaskView.h"
#import "HistoryViewController.h"
#import "AboutUsView.h"
//#import "AboutUsWebView.h"
//#import "SetUpMailAccountViewController.h"
#import "Projects.h"
#import "BackupViewController.h"
#import "DurationViewController.h"
//#import "GCalSync.h"
#import "GCalSyncGuideViewController.h"
#import "WeekViewCalController.h"
#import "CalendarPageView.h"
#import "AdMobView.h"
#import "Colors.h"
#import "ProductListViewController.h"
//#import "LCLAdsView.h"
#import "WeekView.h"
#import "DeletedTEKeys.h"
#import "NSDataBase64.h"
//#import "SyncWindowTableViewController.h"
#import "TaskActionResult.h"
//#import "ProductPageViewController.h"

//#import "SyncMappingTableViewController.h"
#import "RoundedRectView.h"
//#import "SyncMappingViewController.h"

#import "WeekDaySettingViewController.h"
#import "SnoozeDurationViewController.h"
#import "ByLCL.h"
//#import "ByLCLViewController.h"
#import "SyncGuideViewController.h"

#import "EKSync.h"
#import "WBProgressHUD.h"
//#import "ToodleSync.h"
#import "GTMBase64.h"
#import "AboutLCLViewController.h"
#import "ReminderSync.h"

#define kTransitionDuration	0.25
#define kStdButtonWidth			106.0
#define kStdButtonHeight		40.0
#define kAnimationKey @"transitionViewAnimation"

extern sqlite3 *database;
extern SmartTimeAppDelegate *App_Delegate;
extern NSMutableArray *projectList;
//extern Setting *currentSetting;
extern TaskManager *taskmanager;
extern ivo_Utilities	*ivoUtility;
//extern Setting			*currentSettingModifying;
extern BOOL isCancelledEditFromDetail;
extern BOOL isInternetConnected;
extern NSString			*deviceType;

extern NSInteger			loadingView;
extern NSString *movingTaskPassOthersDeadLineAlertText;

SmartTimeView *_activeView;

SmartTimeView *_smartTimeView = nil;

SmartTimeView				*smartView;

CGRect						smartViewFrame;
CGRect						smartViewFrameAd;

//CalendarView *_calendarView = nil;
extern CalendarView *_calendarView;

extern BOOL _didStartup;
extern BOOL _inExternalLaunch;

@implementation SmartViewController
@synthesize newTaskPrimaryKey,isAddNew,transitioning,previousCallerView,phoneList,selectedWeekDate,titleView;
@synthesize keywords;
@synthesize searchingKeyWords;
@synthesize lclPageBarBt;
@synthesize containerView;
@synthesize currentSelectedKey;
@synthesize toolbar;
@synthesize syncBt;
//@synthesize toodledoSync;
@synthesize segmentedControlEdit;
@synthesize buttonBarSegmentedControl;
@synthesize needCheckAutoSync;
@synthesize doneButton;
@synthesize isFilter;

//@synthesize listTaskView;

//- (void)awakeFromNib
//{
	// make the title of this page the same as the title of this app
	//self.title = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"MyName"];
//}

/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
	}
	return self;
}
*/

- (id) init
{
	if (self = [super init])
	{
		//gcalsync = nil;
		self.keywords=nil;
		self.searchingKeyWords=nil;
		isAnotherViewLoaded=NO;
		
		[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(startup) userInfo:nil repeats:NO];
	}
	return self;
}

- (void) initView
{
	self.title = NSLocalizedString(@"backText", @"")/*backText*/;
	CGRect frame=[[UIScreen mainScreen] bounds];
    
    
	//UIButton *settingBt=[self buttonWithTitle:@""
	//								   target:self
	//								 selector:@selector(flipAction:)
	//									frame:CGRectMake(20, 0, 25, 25)
	//									image:@"STSetting.png"
	//							 imagePressed:nil
	//							darkTextColor:NO];
	 
    UIButton *settingBt=[UIButton buttonWithType:UIButtonTypeCustom];
    settingBt.frame=CGRectMake(0, 0, 40, 40);
    [settingBt setImage:[UIImage imageNamed:@"STSetting.png"] forState:UIControlStateNormal];
    [settingBt addTarget:self action:@selector(flipAction:) forControlEvents:UIControlEventTouchUpInside];
    
	infoSettingButton=[[UIBarButtonItem alloc] initWithCustomView:settingBt];
	//[settingBt release];
	
	UIButton *displayBt=[UIButton buttonWithType:UIButtonTypeCustom];
	displayBt.frame=CGRectMake(0, 0, 40, 40);
	[displayBt setImage:[UIImage imageNamed:@"show_hide.png"] forState:UIControlStateNormal];
	[displayBt addTarget:self action:@selector(showHideProjects:) forControlEvents:UIControlEventTouchUpInside];
	
	projectDisplayBt=[[UIBarButtonItem alloc] initWithCustomView:displayBt];
	
	
	self.navigationItem.leftBarButtonItem = infoSettingButton;// projectDisplayBt;
	
	addButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd  target:self action:@selector(addNew:)];
	self.navigationItem.rightBarButtonItem=addButton;
	
	titleView=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
	titleView.frame=CGRectMake(45, 0, 250, 44);
	titleView.titleLabel.font=[UIFont boldSystemFontOfSize:17];
	[titleView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[titleView setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
	titleView.backgroundColor=[UIColor clearColor];
	[titleView addTarget:self action:@selector(invokeJumpToDate:) forControlEvents:UIControlEventTouchUpInside];
    [titleView setTitle:NSLocalizedString(@"smartViewText",@"") forState:UIControlStateNormal];
	self.navigationItem.titleView=titleView;
	
	//EK Sync
	syncProgressView = [[WBProgressHUD alloc] initWithFrame:CGRectMake(40, 140, 240, 120)];
	[syncProgressView setText:@"Synchronizing ..."];	
	
	smartViewFrameAd =CGRectMake(0, 0, frame.size.width, frame.size.height-65-40);
	smartViewFrame = CGRectMake(0, 0, frame.size.width, frame.size.height-44);
	
	//configue for tool bar-----------------------------------------------------
	toolbar = [UIToolbar new];
	toolbar.barStyle = UIBarStyleBlackOpaque;
	
	flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
															 target:nil
															 action:nil];
	
#ifdef FREE_VERSION
	
#else

#endif
	
	UIButton *filterBt=[self buttonWithTitle:@""
									  target:self
									selector:@selector(filterTask:)
									   frame:CGRectMake(0, 0, 26, 26)
									   image:@"filter.png"
								imagePressed:nil
							   darkTextColor:NO];
	
	filterButton=[[UIBarButtonItem alloc] initWithCustomView:filterBt];
	[filterBt release];
	
	NSArray *items = [NSArray arrayWithObjects: 
					  projectDisplayBt,flexItem,nil];
	NSArray *tailItems=[NSArray arrayWithObjects:
						flexItem,
						filterButton,
						nil];
	buttonBarSegmentedControl = [[UISegmentedControl alloc] initWithItems:
								 [NSArray arrayWithObjects:NSLocalizedString(@"smartText", @"")/*smartText*/, NSLocalizedString(@"calendarText", @"")/*calendarText*/, NSLocalizedString(@"focusText", @"")/*focusText*/,nil]];
	
	[buttonBarSegmentedControl addTarget:self action:@selector(viewSelected:) forControlEvents:UIControlEventValueChanged];
	//buttonBarSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	buttonBarSegmentedControl.selectedSegmentIndex=0;
	self.previousCallerView=buttonBarSegmentedControl.selectedSegmentIndex;
	buttonBarSegmentedControl.backgroundColor = [UIColor clearColor];
	
	buttonBarSegmentedControl.tintColor = [UIColor darkGrayColor];
	buttonBarSegmentedControl.frame = CGRectMake(0, 0, 210, 30);
	
	segItem = [[UIBarButtonItem alloc] initWithCustomView:buttonBarSegmentedControl];
	
#ifdef FREE_VERSION
	toolbarNormalModeItems=[[items arrayByAddingObjectsFromArray:tailItems] retain];
#else 
#ifdef ST_BASIC
	toolbarNormalModeItems=[[items arrayByAddingObjectsFromArray:tailItems] retain];
#else
	toolbarNormalModeItems=[[[items arrayByAddingObjectsFromArray:[NSArray arrayWithObject:segItem]] 
							 arrayByAddingObjectsFromArray:tailItems] retain];

#endif
#endif
	
	
	toolbar.items = toolbarNormalModeItems;
	
	// size up the toolbar and set its frame
	[toolbar sizeToFit];
	
	//for layer transition between Smart view and Calendar view
	contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
	contentView.backgroundColor = [UIColor clearColor];
	
	//contentMainView=[[UIView alloc] initWithFrame:smartViewFrame];
    contentMainView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
	contentMainView.backgroundColor = [UIColor clearColor];
	
	[contentView addSubview:contentMainView];
	
    [toolbar setFrame:CGRectMake(0,frame.size.height-44,frame.size.width,44)];
    
	smartView = [[SmartTimeView alloc] initWithFrame:smartViewFrame];
	
	_smartTimeView = smartView;

	[contentMainView addSubview:smartView];
	[contentView addSubview:toolbar];
	
	[self.containerView addSubview: contentView];
	/*
	guideView = [[RoundedRectView alloc] initWithFrame:CGRectMake(20, 200, 280, 240)];
	[guideView setActionsWithTarget:self actionOK:@selector(hintOK:) actionNotShow:@selector(dontShowHint:)];
	
	[guideView loadHTMLFile:@"Welcome" extension:@"txt"];
	*/
	
#ifdef FREE_VERSION
	//AdMob
//	adMobAd = [AdMobView requestAdWithDelegate:self]; // start a new ad request
//	[adMobAd retain]; // this will be released when it loads (or fails to load)
//	[contentView bringSubviewToFront:adMobAd];
#else
	UIBarButtonItem *lclBarBt=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"alsoByLCLBriefText", @"")/*alsoByLCLBriefText*/
															   style:UIBarButtonSystemItemEdit 
															  target:self 
															  action:@selector(byLCL:)];
	self.lclPageBarBt=lclBarBt;
	[lclBarBt release];
#endif
    
	[self prepareForAnotherViews];
    
    
}

-(void)prepareForAnotherViews{
	//prepare for edit and filter---------------------------------------------------------
	if(isAnotherViewLoaded) return;
	
    CGRect frame=[[UIScreen mainScreen] bounds];
    
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	segmentedControlEdit = [[UISegmentedControl alloc] initWithItems:
							[NSArray arrayWithObjects:NSLocalizedString(@"markDoneText", @"")/*markDoneText*/, NSLocalizedString(@"deferText", @"")/*deferText*/,NSLocalizedString(@"duplicateText", @"")/*duplicateText*/, nil]];
	[segmentedControlEdit addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventValueChanged];
	//segmentedControlEdit.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControlEdit.backgroundColor = [UIColor clearColor];
	if(taskmanager.currentSetting.iVoStyleID==0){
		segmentedControlEdit.tintColor = nil;
	}else {
		segmentedControlEdit.tintColor = [UIColor darkGrayColor];
	}
	
	segmentedControlEdit.frame = CGRectMake(0, 0, 210, 30);
	
	UIBarButtonItem *flexEditItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																				  target:nil
																				  action:nil];
	
	UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash 
																			target:self action:@selector(deletedTask:)];
	
	UIBarButtonItem *outActionButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(outActions:)];
	outActionButton.style=UIBarButtonItemStylePlain;
	
	NSArray *editItems = [NSArray arrayWithObjects: 
						  delete,flexEditItem,nil];
#ifdef FREE_VERSION	
	NSArray *tailEditItems=[NSArray arrayWithObjects:
							flexEditItem,
							nil];
#else
	NSArray *tailEditItems=[NSArray arrayWithObjects:
							flexEditItem,
							outActionButton,
							nil];
#endif
	
	UIBarButtonItem *segItemEdit = [[UIBarButtonItem alloc] initWithCustomView:segmentedControlEdit];
	toolbarEditModeItems=[[[editItems arrayByAddingObjectsFromArray:[NSArray arrayWithObject:segItemEdit]] arrayByAddingObjectsFromArray:tailEditItems] retain];
	
	[flexEditItem release];
	[outActionButton release];
	[segItemEdit release];
	[flexItem release];
	[delete release];
	[segItem release];
	[syncButton release];
	
	//prepare for setting view navigation bar---------------------------------------------
	//view for setting view
	backSideContentView=[[UIView alloc] initWithFrame:CGRectMake(0, 64, frame.size.width,frame.size.height-65)];
	
	UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[infoButton addTarget:self action:@selector(showAboutUs:) forControlEvents:UIControlEventTouchUpInside];
	infoButton.frame=CGRectMake(0, 0, 40, 40);
	aboutUs=[[UIBarButtonItem alloc] initWithCustomView:infoButton];
	doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
															   target:self action:@selector(flipAction:)];
	//-------------------------------------------------------------------------------------
	
	//prepare for change to Calendar view--------------------------------------------------
	
	todayButton=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"todayText", @"Today")/*todayText*/ /*@"Today"*/ style:UIBarButtonItemStyleBordered target:self action:@selector(goBackToday:)];
	
	//prepare for Filter view
	noneFilterButton=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"exitFilterText", @"")/*exitFilterText*/ style:UIBarButtonItemStyleBordered target:self action:@selector(exitFilter:)];
	
	fullDoneButton=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"historyText", @"")/*historyText*/ style:UIBarButtonItemStyleBordered target:self action:@selector(fullDoneHistory:)];
	
	quickEditActionSheet =[[UIActionSheet alloc] initWithTitle:@""
													  delegate:self cancelButtonTitle:NSLocalizedString(@"cancelText", @"")/*cancelText*/ destructiveButtonTitle:nil
											 otherButtonTitles:NSLocalizedString(@"nextdayText", @"")/*nextdayText*/, NSLocalizedString(@"nextweekText", @"")/*nextweekText*/,nil, nil];
	outActionSheet =[[UIActionSheet alloc] initWithTitle:@""
												delegate:self cancelButtonTitle:NSLocalizedString(@"cancelText", @"")/*cancelText*/ destructiveButtonTitle:nil
									   otherButtonTitles:NSLocalizedString(@"launchMapText", @"")/*launchMapText*/, NSLocalizedString(@"sharingTaskText", @"")/*sharingTaskText*/,NSLocalizedString(@"phoneContactText", @"")/*phoneContactText*/,NSLocalizedString(@"sendSmsText", @"")/*sendSmsText*/,nil, nil];
	
	//ILOG(@"SmartViewController loadView]\n");
	
	self.selectedWeekDate=nil;
	isJump2DatePKPopUp=NO;
	
	isAnotherViewLoaded=YES;
	[pool release];
}

// Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
    taskmanager.reminderSync.rootViewController=self;
    
    CGRect frame=[[UIScreen mainScreen] bounds];
    
	self.navigationController.navigationBarHidden=YES;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	// match the status bar with the nav bar
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
	//self.navigationItem.title=NSLocalizedString(@"smartViewText", @"")/*smartViewText*/;
    
    [titleView setTitle:NSLocalizedString(@"smartViewText",@"") forState:UIControlStateNormal];
	self.navigationItem.titleView=titleView;
	//ILOG(@"[SmartViewController loadView\n");
	//configure naviagetion bar------------------------------------------------
	appFirstStart=YES;
	//[self setEditing:YES animated:NO];

	// add the top-most parent view------------------------------------------------------
	UIView *containerViewTmp= [[UIView alloc] initWithFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
    
	self.containerView=containerViewTmp;
	[containerViewTmp release];

	//self.view = self.containerView;
	
	
	if (!_didStartup)
	{
		//[self.navigationController setNavigationBarHidden:YES animated:NO];
		
		if(!startupView){
			startupView = [[UIImageView alloc] init];//WithFrame:CGRectMake(0, 44, 320, 480)];
			UIImage *image=[self getCachedImage]; 
			if(image){
				startupView.image =image;
			}else {
				startupView.image=[UIImage imageNamed:@"snapBody.png"];
			}

			//[self.containerView addSubview:startupView];
			self.view=startupView;
			//[startupView release];
		}		
	}
	else
	{
		[self initView];
		
		//trung ST3.1
		//[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(initView) userInfo:nil repeats:NO];	
	}
	
	
}

- (void) showModal:(UIView*) modalView
{
	UIWindow* mainWindow = (((SmartTimeAppDelegate*) [UIApplication sharedApplication].delegate).window);
	
	CGPoint middleCenter = modalView.center;
	CGSize offSize = [UIScreen mainScreen].bounds.size;
	CGPoint offScreenCenter = CGPointMake(offSize.width / 2.0, offSize.height * 1.5);
	modalView.center = offScreenCenter; // we start off-screen
	[mainWindow addSubview:modalView];
	
	// Show it with a transition effect
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.7]; // animation duration in seconds
	modalView.center = middleCenter;
	[UIView commitAnimations];
}

- (void) hideModal:(UIView*) modalView
{
	CGSize offSize = [UIScreen mainScreen].bounds.size;
	CGPoint offScreenCenter = CGPointMake(offSize.width / 2.0, offSize.height * 1.5);
	[UIView beginAnimations:nil context:modalView];
	[UIView setAnimationDuration:0.7];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(hideModalEnded:finished:context:)];
	modalView.center = offScreenCenter;
	[UIView commitAnimations];
}

- (void) hideModalEnded:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	/*
	 UIView* modalView = (UIView *)context;
	 [modalView removeFromSuperview];
	 [modalView release];
	 */ 
	[guideView removeFromSuperview];
	[guideView release];
	guideView = nil;
}
 
#pragma mark action methods

-(void)showHideProjects:(id)sender{
	ProjectViewController *viewController=[[ProjectViewController alloc] init];
	viewController.keyEdit=PROJECT_SHOW_HIDE;
	viewController.editing=YES;
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];
}

-(void)upgradeST:(id)sender{
/*	NSString *bodyStr = [NSString stringWithFormat:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=295845767&mt=8"];
	NSString *encoded = [bodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [[NSURL alloc] initWithString:encoded];
	
	[[UIApplication sharedApplication] openURL:url];
	
	[url release];
*/
	[upgradeAS showInView:contentView];
}

-(void)addNew:(id)sender{
	//ILOG(@"[SmartViewController addNew\n");
	
	//Trung 08101002
	/*
	if(taskDetail==nil){
		taskDetail=[[TaskEventDetailViewController alloc] init];	
	}
	*/
	if(_calendarView && _calendarView.isInQuickAddMode) return;
	
	App_Delegate.me.networkActivityIndicatorVisible=YES;
		
	TaskEventDetailViewController *taskDetail=[[TaskEventDetailViewController alloc] init];	
	
	if(taskDetail.taskItem !=nil){
		[taskDetail.taskItem release];
	}
	
	Task *tmp=[[Task alloc] init];
	
	//set default values for new task
	[tmp setTaskWhere:taskmanager.currentSetting.contextDefID];
	[tmp setTaskHowLong:taskmanager.currentSetting.howlongDefVal];
	[tmp setTaskProject:taskmanager.currentSetting.projectDefID];
	[tmp setTaskDueStartDate:[NSDate date]];
	[tmp setTaskNotEalierThan:[NSDate date]];
	[tmp setTaskStartTime:nil];
	
	[tmp setTaskDueEndDate:[[NSDate date] dateByAddingTimeInterval:2592000]];
	[tmp setTaskDeadLine:[[NSDate date] dateByAddingTimeInterval:2592000]];
	[tmp setTaskIsUseDeadLine:NO];

	if ([calendarView superview])
	{
		[tmp setTaskPinned:YES];
		[tmp setTaskStartTime:[calendarView getDisplayDate]];
	}	
	
	taskDetail.taskItem=tmp;//[tmp retain];
	[tmp release];
	
	taskDetail.keyEdit=0;
	taskDetail.typeEdit=0;
	[taskDetail setEditing:NO animated:NO];
	
	taskDetail.rootViewControler=self;
	
	//trung ST3.1
	//[self resetQuickEditMode:YES taskKey:[self selectedKey]];
	[self resetQuickEditMode:YES taskKey:[self getSelectedTaskKey]];
	
	[self.navigationController pushViewController:taskDetail animated:YES];
	
	//Trung 08101002
	[taskDetail release];
	
	App_Delegate.me.networkActivityIndicatorVisible=NO;
	//ILOG(@"SmartViewController addNew]\n");
}

-(void)viewSelected:(id)sender{
	//ILOG(@"[SmartViewController viewSelected\n");
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	[self transitionView];
	self.previousCallerView=buttonBarSegmentedControl.selectedSegmentIndex;

	App_Delegate.me.networkActivityIndicatorVisible=NO;

	//ILOG(@"SmartViewController viewSelected]\n");
}

-(void)deletedTask:(id)sender{
	//ILOG(@"[SmartViewController deletedTask\n");
	
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	//trung ST3.1
	//Task *deleteTask=[ivoUtility getTaskByPrimaryKey:[self selectedKey] inArray:taskmanager.taskList];
	//currentSelectedKey=[self selectedKey];
	currentSelectedKey=[self getSelectedTaskKey];
	
	Task *deleteTask=[ivoUtility getTaskByPrimaryKey:currentSelectedKey inArray:taskmanager.taskList];	
	
	if(deleteTask.taskPinned==1 && deleteTask.taskRepeatID>0 && deleteTask.taskNumberInstances !=1){
		//trung ST3.1
		//if([[ivoUtility getTaskByPrimaryKey:[self selectedKey] inArray:taskmanager.taskList] isOneMoreInstance]!=1){
		if([[ivoUtility getTaskByPrimaryKey:currentSelectedKey inArray:taskmanager.taskList] isOneMoreInstance]!=1){
			deleteREAlertView= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"deleteREtitleText", @"")/*deleteREtitleText*/  message:NSLocalizedString(@"deleteREText", @"")/*deleteREText*/ delegate:self cancelButtonTitle:NSLocalizedString(@"cancelText", @"")/*cancelText*/ otherButtonTitles:nil];
			[deleteREAlertView addButtonWithTitle:NSLocalizedString(@"onlyInsText", @"")/*onlyInsText*/];
			[deleteREAlertView addButtonWithTitle:NSLocalizedString(@"allEventsText", @"")/*allEventsText*/];
			[deleteREAlertView addButtonWithTitle:NSLocalizedString(@"allInsFollowText", @"")/*allInsFollowText*/];
		}else {
			deleteREAlertView= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"deleteREtitleText", @"")/*deleteREtitleText*/  message:NSLocalizedString(@"deleteREAllAndFollowText", @"")/*deleteREAllAndFollowText*/ delegate:self cancelButtonTitle:NSLocalizedString(@"cancelText", @"")/*cancelText*/ otherButtonTitles:nil];
			[deleteREAlertView addButtonWithTitle:NSLocalizedString(@"allEventsText", @"")/*allEventsText*/];
			[deleteREAlertView addButtonWithTitle:NSLocalizedString(@"allInsFollowText", @"")/*allInsFollowText*/];
		}
		
		[deleteREAlertView show];
		[deleteREAlertView release];
		return;
	
	}else {
		
		if(taskmanager.currentSetting.deletingType==1){
			deleteConfirmAlertView= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"deleteConfirmTitleText", @"")/*deleteConfirmTitleText*/  message:NSLocalizedString(@"deleteConfirmText", @"")/*deleteConfirmText*/ delegate:self cancelButtonTitle:NSLocalizedString(@"cancelText", @"")/*cancelText*/ otherButtonTitles:nil];
			[deleteConfirmAlertView addButtonWithTitle:NSLocalizedString(@"okText", @"")/*okText*/];
			[deleteConfirmAlertView show];
			[deleteConfirmAlertView release];
			return;
		}
		
		if([smartView superview]||[calendarView superview]){
			//trung ST3.1
			//[taskmanager deleteTask:[self selectedKey] isDeleteFromDB:YES deleteREType:-1];
			[taskmanager deleteTask:currentSelectedKey isDeleteFromDB:YES deleteREType:-1];
		}else if([listTaskView superview]){
			//[[listTaskView tableViewDo] deselectRowAtIndexPath:[NSIndexPath indexPathForRow:listTaskView.pathIndex inSection:0]  animated:YES];
			[listTaskView deselectedCell];
			
			//[taskmanager deleteTask:[[taskmanager.quickTaskList objectAtIndex:listTaskView.pathIndex] primaryKey] isDeleteFromDB:YES deleteREType:-1];
			[taskmanager deleteTask:currentSelectedKey isDeleteFromDB:YES deleteREType:-1];
			listTaskView.isDoViewSelected=NO;
			listTaskView.pathIndex=-1;
		}
	}


	//trung ST3.1
	//[self resetQuickEditMode:YES taskKey:[self selectedKey]];
	[self resetQuickEditMode:YES taskKey:currentSelectedKey];
	
	[self refreshViews];
	
	App_Delegate.me.networkActivityIndicatorVisible=NO;
	
	//[App_Delegate stopAcitivityIndicatorThread];
	
	//ILOG(@"SmartViewController deletedTask]\n");
}

-(void)syncTasks:(id)sender{
	
	//tasks sync
/*	if (taskmanager.currentSetting.enableSyncToodledo==1) {
		ToodleSync *toodledoSyncTmp=[[ToodleSync alloc] init];
		
		self.toodledoSync=toodledoSyncTmp;
		self.toodledoSync.rootViewController=self;
		[self.toodledoSync start];
		[toodledoSyncTmp release];
	}else {
		[self performSelector:@selector(:synchronize:) withObject:nil];
	}
*/
	
}

/*
-(void)synchronize:(id)sender{
	

	BOOL noMapping = YES;
	
	for (Projects *prj in projectList)
	{
		if (![prj.mapToGCalNameForEvent isEqualToString:@""])
		{
			noMapping = NO;
			break;
		}
	}
	
	if (noMapping)
	{
		CalendarSelectionTableViewController *ctrler = [[CalendarSelectionTableViewController alloc] init];
		[self.navigationController pushViewController:ctrler animated:YES];
		[ctrler release];		
	}
	else 
	{
		[syncProgressView showInView:contentMainView];
		
		[NSTimer scheduledTimerWithTimeInterval:0 target:[EKSync getInstance] selector:@selector(sync) userInfo:nil repeats:NO];
	}
		
	//[self startSyncIndicator];
}
*/

-(void)startSyncIndicator{
	if (!syncAlertView) {
		syncAlertView=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"toodledoSyncingText", @"")
												 message:nil
												delegate:nil 
									   cancelButtonTitle:nil 
									   otherButtonTitles:nil];
		UIActivityIndicatorView *indicatorView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		indicatorView.frame=CGRectMake(130, 50, 30, 30);
		[indicatorView startAnimating];
		[syncAlertView addSubview:indicatorView];
		
		[syncAlertView show];
		[syncAlertView release];
	}
}

-(void)stopSyncIndicator{
	[syncAlertView dismissWithClickedButtonIndex:0 animated:YES];
	syncAlertView=nil;
}

-(void)outActions:(id)sender{
	// use the same style as the nav bar
	outActionSheet.actionSheetStyle = self.navigationController.navigationBar.barStyle;
	
	[outActionSheet showInView:self.view];
}


-(void)filterTask:(id)sender{
	//ILOG(@"[SmartViewController filterTask\n");
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	if(![filterView superview]){
		filterView=[[FilterView alloc] initWithFrame:smartViewFrame];
		filterView.rootView=self;
	}
	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:animationIDfinished:finished:context:)];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1.5];//kTransitionDuration];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	
	
	[UIView setAnimationTransition:([filterView superview] ?
									UIViewAnimationTransitionCurlDown : UIViewAnimationTransitionCurlUp)
						   forView:contentMainView cache:YES];
	if ([filterView superview])
	{
		[filterView removeFromSuperview];
		//[filterView release];
		filterView=nil;
		
		if(self.previousCallerView==0){
			[contentMainView addSubview:smartView];
		}else if(self.previousCallerView==1){
			[contentMainView addSubview:calendarView];
		}else if(self.previousCallerView==2){
			[contentMainView addSubview:listTaskView];
		}

	}
	else
	{
		if(self.previousCallerView==0){
			[smartView removeFromSuperview];
		}else if(self.previousCallerView==1){
			[calendarView removeFromSuperview];
		}else if(self.previousCallerView==2){
			[listTaskView removeFromSuperview];
		}
		
		[contentMainView addSubview:filterView];
		[filterView release];
		//filterView=nil;
	}

	//commit animation
	[UIView commitAnimations];
	
	App_Delegate.me.networkActivityIndicatorVisible=NO;
	//ILOG(@"SmartViewController filterTask]\n");
}

-(void)applyFilter:(NSString *)queryClause doTodayClause:(NSString *)queryDoTodayClause{
	//ILOG(@"[SmartViewController applyFilter\n");
	
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	taskmanager.filterClause=queryClause;
	taskmanager.filterDoTodayClause=queryDoTodayClause;
	
	//change to filter mode
	isFilter=YES;
	self.navigationItem.leftBarButtonItem=noneFilterButton;
	[self filterTask:nil];
	
	if([smartView superview]){
		[_smartTimeView initData:-1];
		//self.navigationItem.title = smartViewText;//@"Smart View";
		[titleView setTitle:NSLocalizedString(@"smartViewText", @"")/*smartViewText*/ forState:UIControlStateNormal];
	}else {
		//NSDate *currentDatePage=[[calendarView getScrollDate] copy];
		NSDate *currentDatePage=[[_calendarView getScrollDate] copy];
		[_calendarView initData:currentDatePage];
		[currentDatePage release];			
	}

	listTaskView.filterCaluse=queryClause;
	listTaskView.pathIndex=-1;
	[listTaskView refreshData];
	
	App_Delegate.me.networkActivityIndicatorVisible=NO;
	
	//ILOG(@"SmartViewController applyFilter]\n");
	
}

-(void)exitFilter:(id)sender{
	//ILOG(@"[SmartViewController exitFilter\n");
	if(_calendarView && _calendarView.isInQuickAddMode) return;
	
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	if([filterView superview]){
		[self filterTask:nil];
	}

	//trung ST3.1
	//[self resetQuickEditMode:YES taskKey:[self selectedKey]];
	[self resetQuickEditMode:YES taskKey:[self getSelectedTaskKey]];
	
	taskmanager.filterClause=nil;
	taskmanager.filterDoTodayClause=nil;
	listTaskView.filterCaluse=nil;
	
	if([smartView superview]){
		[_smartTimeView initData:-1];
		//self.navigationItem.title = smartViewText;//@"Smart View";
		[titleView setTitle:NSLocalizedString(@"smartViewText", @"")/*smartViewText*/ forState:UIControlStateNormal];
	}else {
		//NSDate *currentDatePage=[[calendarView getScrollDate] copy];
		NSDate *currentDatePage=[[_calendarView getScrollDate] copy];
		[_calendarView initData:currentDatePage];
		[currentDatePage release];	
	}

	[listTaskView refreshData];
	//[[listTaskView tableViewDo] reloadData];
	listTaskView.pathIndex=-1;
	
	isFilter=NO;

	if(self.previousCallerView==0){
		self.navigationItem.leftBarButtonItem=infoSettingButton;//projectDisplayBt;
	}else if(self.previousCallerView==1){
		self.navigationItem.leftBarButtonItem=todayButton;
	}else if(self.previousCallerView==2){
		self.navigationItem.leftBarButtonItem=fullDoneButton;
	}

	taskmanager.filterList =nil;
	App_Delegate.me.networkActivityIndicatorVisible=NO;
	
	//ILOG(@"SmartViewController exitFilter]\n");

}

-(void)goBackToday:(id)sender{
	if(_calendarView && _calendarView.isInQuickAddMode) return;
	
	if(isEdit){
		[self resetQuickEditMode:isEdit taskKey:-1];
	}
	
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	//[calendarView initData:[NSDate date]];
	[_calendarView initData:[NSDate date]];
	
	//NSString *formattedDateString = [ivoUtility createStringFromDate:[calendarView getScrollDate] isIncludedTime:NO];
	NSString *formattedDateString = [ivoUtility createStringFromDate:[_calendarView getScrollDate] isIncludedTime:NO];
	
	//self.navigationItem.title = formattedDateString;
	[titleView setTitle:formattedDateString forState:UIControlStateNormal];
	
	[formattedDateString release];	
	
	if(jumpToDateView && isJump2DatePKPopUp){
		[self popDownJumpDate];
	}
	App_Delegate.me.networkActivityIndicatorVisible=NO;
}

/*
-(void)editAction:(id)sender{
	//ILOG(@"[SmartViewController editAction\n");

	App_Delegate.me.networkActivityIndicatorVisible=YES;
	currentSelectedKey=[self selectedKey];
	
	if (segmentedControlEdit.selectedSegmentIndex==1){//defer
		quickEditActionSheet.actionSheetStyle = self.navigationController.navigationBar.barStyle;
		
		[quickEditActionSheet showInView:self.view];
		
		segmentedControlEdit.selectedSegmentIndex=-1;
	}else if(segmentedControlEdit.selectedSegmentIndex==2){//duplicate
		
		TaskEventDetailViewController *taskDetail=[[TaskEventDetailViewController alloc] init];	
		
		taskDetail.keyEdit=2;
		taskDetail.typeEdit=0;//
		
		if(taskDetail.taskItem !=nil){
			[taskDetail.taskItem release];
		}
		
		Task *tmp=[[Task alloc] init];
		
		if([smartView superview]||[calendarView superview]){
			[ivoUtility copyTask:[ivoUtility getTaskByPrimaryKey:[self selectedKey] inArray:taskmanager.taskList] 
							 toTask:tmp isIncludedPrimaryKey:NO];
		}else if([listTaskView superview]) {
			[listTaskView deselectedCell];
			[ivoUtility copyTask:[taskmanager.quickTaskList objectAtIndex:listTaskView.pathIndex]
							 toTask:tmp isIncludedPrimaryKey:NO];
			listTaskView.isDoViewSelected=NO;
			listTaskView.pathIndex=-1;
		}

		tmp.taskDeadLine=tmp.taskDeadLine;
		tmp.taskDueEndDate=[tmp.taskDueEndDate addTimeInterval:86400];
		tmp.taskSynKey=0;
		tmp.gcalEventId=@"";
		tmp.parentRepeatInstance=-1;
		
		taskDetail.taskItem=tmp;//[tmp retain];
		[tmp release];
		
		//exit quick edit mode
		[self resetQuickEditMode:YES taskKey:[self selectedKey]];

		[self.navigationController pushViewController:taskDetail animated:YES];
		//Trung 08101002
		[taskDetail release];
		
	}else if(segmentedControlEdit.selectedSegmentIndex==0){//mark done
		Task *selectedTask=[ivoUtility getTaskByPrimaryKey:[self selectedKey] inArray:taskmanager.taskList];
		if([listTaskView superview]){
			selectedTask=[taskmanager.quickTaskList objectAtIndex:listTaskView.pathIndex]; 
		}
		currentSelectedKey=selectedTask.primaryKey;

		if(selectedTask.taskPinned==0){
			if([smartView superview]||[calendarView superview]){
				[taskmanager markedCompletedTask:[self selectedKey] doneREType:1];
			}else if([listTaskView superview]){
				[listTaskView deselectedCell];
				[taskmanager markedCompletedTask:[[taskmanager.quickTaskList objectAtIndex:listTaskView.pathIndex] primaryKey] doneREType:1];
				listTaskView.isDoViewSelected=NO;
				listTaskView.pathIndex=-1;
			}
			
			[listTaskView refreshData];
			[self refreshViews];
			//exit quick edit mode
			[self resetQuickEditMode:YES taskKey:[self selectedKey]];
		}else {
			markDoneEventAlert=[[UIAlertView alloc] initWithTitle:doneEventConfirmationText 
														  message:doneEventWarningMessage 
														 delegate:self 
												cancelButtonTitle:cancelText
												otherButtonTitles:nil];
			[markDoneEventAlert addButtonWithTitle:okText];
			[markDoneEventAlert show];
			[markDoneEventAlert release];
		}

	}
	
	segmentedControlEdit.selectedSegmentIndex=-1;
	
	App_Delegate.me.networkActivityIndicatorVisible=NO;
	//ILOG(@"SmartViewController editAction]\n");
}
*/

-(void)editAction:(id)sender{
	//ILOG(@"[SmartViewController editAction\n");
	
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	//trung ST3.1
	//currentSelectedKey=[self selectedKey];
	currentSelectedKey=[self getSelectedTaskKey];
	
	if (segmentedControlEdit.selectedSegmentIndex==1){//defer
		quickEditActionSheet.actionSheetStyle = self.navigationController.navigationBar.barStyle;
		
		[quickEditActionSheet showInView:self.view];
		
		segmentedControlEdit.selectedSegmentIndex=-1;
	}else if(segmentedControlEdit.selectedSegmentIndex==2){//duplicate
		
		TaskEventDetailViewController *taskDetail=[[TaskEventDetailViewController alloc] init];	
		
		taskDetail.keyEdit=2;
		taskDetail.typeEdit=0;//
		
		if(taskDetail.taskItem !=nil){
			[taskDetail.taskItem release];
		}
		
		Task *tmp=[[Task alloc] init];
		
		if([smartView superview]||[calendarView superview]){
			//trung ST3.1
			//[ivoUtility copyTask:[ivoUtility getTaskByPrimaryKey:[self selectedKey] inArray:taskmanager.taskList] toTask:tmp isIncludedPrimaryKey:NO];
			[ivoUtility copyTask:[ivoUtility getTaskByPrimaryKey:currentSelectedKey inArray:taskmanager.taskList] toTask:tmp isIncludedPrimaryKey:NO];
		}else if([listTaskView superview]) {
			[listTaskView deselectedCell];
			[ivoUtility copyTask:[taskmanager.quickTaskList objectAtIndex:listTaskView.pathIndex]
						  toTask:tmp isIncludedPrimaryKey:NO];
			listTaskView.isDoViewSelected=NO;
			listTaskView.pathIndex=-1;
		}
		
		tmp.taskDeadLine=tmp.taskDeadLine;
		tmp.taskDueEndDate=[tmp.taskDueEndDate dateByAddingTimeInterval:1];
		//tmp.taskDueStartDate=[tmp.taskDueStartDate addTimeInterval:1];
		tmp.taskSynKey=0;
		tmp.gcalEventId=@"";
        tmp.iCalIdentifier=@"";
        tmp.reminderIdentifier=@"";
        tmp.toodledoID=0;
		tmp.parentRepeatInstance=-1;
		
		taskDetail.taskItem=tmp;//[tmp retain];
		[tmp release];
		
		//exit quick edit mode
		
		//trung ST3.1
		//[self resetQuickEditMode:YES taskKey:[self selectedKey]];
		[self resetQuickEditMode:YES taskKey:currentSelectedKey];
		
		[self.navigationController pushViewController:taskDetail animated:YES];
		//Trung 08101002
		[taskDetail release];
		
	}else if(segmentedControlEdit.selectedSegmentIndex==0){//mark done
		//trung ST3.1
		//Task *selectedTask=[ivoUtility getTaskByPrimaryKey:[self selectedKey] inArray:taskmanager.taskList];
		Task *selectedTask=[ivoUtility getTaskByPrimaryKey:currentSelectedKey inArray:taskmanager.taskList];
		
		if([listTaskView superview]){
			selectedTask=[taskmanager.quickTaskList objectAtIndex:listTaskView.pathIndex]; 
		}
		currentSelectedKey=selectedTask.primaryKey;
		
		if(selectedTask.taskPinned==0){
			if([smartView superview]||[calendarView superview]){
				//trung ST3.1
				//[taskmanager markedCompletedTask:[self selectedKey] doneREType:1];
				[taskmanager markedCompletedTask:currentSelectedKey doneREType:1];
			}else if([listTaskView superview]){
				[listTaskView deselectedCell];
				[taskmanager markedCompletedTask:[[taskmanager.quickTaskList objectAtIndex:listTaskView.pathIndex] primaryKey] doneREType:1];
				listTaskView.isDoViewSelected=NO;
				listTaskView.pathIndex=-1;
			}
			
			//nang 3.1.1
			//[listTaskView refreshData];
			[self refreshViews];

			//exit quick edit mode
			//trung ST3.1
			//[self resetQuickEditMode:YES taskKey:[self selectedKey]];
			[self resetQuickEditMode:YES taskKey:currentSelectedKey];
			
		}else {
			markDoneEventAlert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"doneEventConfirmationText", @"")/*doneEventConfirmationText*/ 
														  message:NSLocalizedString(@"doneEventWarningMessage", @"")/*doneEventWarningMessage*/ 
														 delegate:self 
												cancelButtonTitle:NSLocalizedString(@"cancelText", @"")/*cancelText*/
												otherButtonTitles:nil];
			[markDoneEventAlert addButtonWithTitle:NSLocalizedString(@"okText", @"")/*okText*/];
			[markDoneEventAlert show];
			[markDoneEventAlert release];
		}
		
	}
	
	segmentedControlEdit.selectedSegmentIndex=-1;
	
	App_Delegate.me.networkActivityIndicatorVisible=NO;
	//ILOG(@"SmartViewController editAction]\n");
}

- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex{
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	//ILOG(@"[SmartViewController actionSheet\n");
	if([modalView isEqual:quickEditActionSheet]){
		if (buttonIndex==2){//cancel
			segmentedControlEdit.selectedSegmentIndex=-1;
		}else {
			
			isDeferingTask=YES;
			
			//trung ST3.1
			//self.newTaskPrimaryKey=[self selectedKey];
			self.newTaskPrimaryKey=[self getSelectedTaskKey];
			
			TaskActionResult *ret=nil;
			if(buttonIndex==0){//next day
				delayType=1;
				if([smartView superview]||[calendarView superview]){
					
					//printf("---- Task List before deferring ----\n");
					//[ivoUtility printTask:taskmanager.taskList];
					
					//defer in Smart View
					//trung ST3.1
					//ret=[taskmanager delayTask:[self selectedKey] delayType:1 isAutoChangeDue:NO];
					ret=[taskmanager delayTask:self.newTaskPrimaryKey delayType:1 isAutoChangeDue:NO];
				}else if([listTaskView superview]){
					//defer in List View
					//[[listTaskView tableViewDo] deselectRowAtIndexPath:[NSIndexPath indexPathForRow:listTaskView.pathIndex inSection:0]  animated:YES];
					[listTaskView deselectedCell];
					ret=[taskmanager delayTask:[[taskmanager.quickTaskList objectAtIndex:listTaskView.pathIndex] primaryKey] delayType:1 isAutoChangeDue:NO];
					listTaskView.isDoViewSelected=NO;
					listTaskView.pathIndex=-1;
				}
				
			}else if(buttonIndex==1) {//next week
				delayType=3;
				if([smartView superview]||[calendarView superview]){
					//defer in Smart View
					//trung ST3.1
					//ret=[taskmanager delayTask:[self selectedKey] delayType:3 isAutoChangeDue:NO];
					ret=[taskmanager delayTask:self.newTaskPrimaryKey delayType:3 isAutoChangeDue:NO];
				}else if([listTaskView superview]){
					//defer in List View
					//[[listTaskView tableViewDo] deselectRowAtIndexPath:[NSIndexPath indexPathForRow:listTaskView.pathIndex inSection:0]  animated:YES];
					[listTaskView deselectedCell];
					ret=[taskmanager delayTask:[[taskmanager.quickTaskList objectAtIndex:listTaskView.pathIndex] primaryKey] delayType:3 isAutoChangeDue:NO];
					listTaskView.isDoViewSelected=NO;
					listTaskView.pathIndex=-1;
				}
			}
			
			if(ret.errorNo==ERR_TASK_ITSELF_PASS_DEADLINE){
				//delayAlert = [[UIAlertView alloc] initWithTitle:@"Defering this task will bump it past its deadline. Change deadline?" message:nil delegate:self cancelButtonTitle:cancelText otherButtonTitles:nil];
				delayAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"deferTaskPassItsDeadlineText", @"")/*deferTaskPassItsDeadlineText*/ message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancelText", @"")/*cancelText*/ otherButtonTitles:nil];

				[delayAlert addButtonWithTitle:NSLocalizedString(@"autoText", @"")/*autoText*/];
				[delayAlert addButtonWithTitle:NSLocalizedString(@"manualText", @"")/*manualText*/];
				[delayAlert show];
				[delayAlert release];
				
				//trung ST3.1
				//[self resetQuickEditMode:YES taskKey:[self selectedKey]];
				[self resetQuickEditMode:YES taskKey:self.newTaskPrimaryKey];
				[ret release];
				return;
			}else if(ret.errorNo==ERR_TASK_ANOTHER_PASS_DEADLINE){
				//delayAlert = [[UIAlertView alloc] initWithTitle:@"This will cause some existing tasks to pass their deadlines. Change those deadlines automatically?" message:nil delegate:self cancelButtonTitle:cancelText otherButtonTitles:nil];
				delayAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"movingTaskPassOthersDeadLineAlertText", @"")/*movingTaskPassOthersDeadLineAlertText*/ message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancelText", @"")/*cancelText*/ otherButtonTitles:nil];

				[delayAlert addButtonWithTitle:NSLocalizedString(@"yesText", @"")/*yesText*/];
				[delayAlert show];
				[delayAlert release];
				
				//trung ST3.1
				//[self resetQuickEditMode:YES taskKey:[self selectedKey]];
				[self resetQuickEditMode:YES taskKey:self.newTaskPrimaryKey];
				[ret release];
				return;
			}else if(ret.errorNo==ERR_TASK_NOT_BE_FIT_BY_RE) {
				UIAlertView	*taskNotBeFitByREAlert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"taskNotBeFitByREText", @"")/*taskNotBeFitByREText*/  message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/ otherButtonTitles:nil];
				
				[taskNotBeFitByREAlert show];
				[taskNotBeFitByREAlert release];
				
				//trung ST3.1
				//[self resetQuickEditMode:YES taskKey:[self selectedKey]];
				[self resetQuickEditMode:YES taskKey:self.newTaskPrimaryKey];
				
				[ret release];
				return;
			}

			[ret release];
			
			//			[self refreshViews];
			//			[self resetQuickEditMode:YES];
			//exit quick edit mode
		}
	}else if([modalView isEqual:outActionSheet]) {
		switch (buttonIndex) {
			case 0://
			{
				//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"maps:daddr=San+Francisco,+CA&saddr=Current+Location"]];
				
				//trung ST3.1
				NSInteger primKey = [self getSelectedTaskKey];
				//NSString *taskLocationStr=[[[ivoUtility getTaskByPrimaryKey:[self selectedKey] inArray:taskmanager.taskList] taskLocation] copy];
				NSString *taskLocationStr=[[[ivoUtility getTaskByPrimaryKey:primKey inArray:taskmanager.taskList] taskLocation] copy];
				//taskLocationStr=[taskLocationStr stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
				
				if(!taskLocationStr || [taskLocationStr isEqualToString:@""]){
					UIAlertView *locationAlert;
					//trung ST3.1
					//if([[ivoUtility getTaskByPrimaryKey:[self selectedKey] inArray:taskmanager.taskList] taskPinned]==0){
					if([[ivoUtility getTaskByPrimaryKey:primKey inArray:taskmanager.taskList] taskPinned]==0){	
						//locationAlert= [[UIAlertView alloc] initWithTitle:@"Sorry! This task has no location to launch the Maps" message:nil delegate:self cancelButtonTitle:dismissText otherButtonTitles:nil];
						locationAlert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"noTaskLocationForLaunchMapText", @"")/*noTaskLocationForLaunchMapText*/ message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"dismissText", @"")/*dismissText*/ otherButtonTitles:nil];
					}else {
						//locationAlert= [[UIAlertView alloc] initWithTitle:@"Sorry! This event has no location to launch the Maps" message:nil delegate:self cancelButtonTitle:dismissText otherButtonTitles:nil];
						locationAlert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"noEventLocationForLaunchMapText", @"")/*noEventLocationForLaunchMapText*/ message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"dismissText", @"")/*dismissText*/ otherButtonTitles:nil];
					}
					
					[locationAlert show];
					[locationAlert release];
					return;
				}
				
				NSString *addressStr= [taskLocationStr stringByReplacingOccurrencesOfString:@" " withString:@"+"];
				NSString *urlStr=[[NSString stringWithFormat: @"http://maps.google.com/maps?q="] 
								  stringByAppendingString:addressStr];
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]]; 
				//stringByAppendingString: @"&saddr=Current+Location"]]];
				[taskLocationStr release];
			}
				
				break;
			case 1://send mail
			{
				//"_!$!_" used to separate parameters
				//"_!$$!_" replace for "#"
				//"_!$$_" replace for "&"
				//"_$$!_" replace for "?"
				//"_$$$_" replace for " "
				//"_$!$_" replace for new line character
				// "_!!$$_" replace for "/" character
				//"_$!!$_" replace for "|" character
				
				//trung ST3.1
				//Task *tmpTask=[ivoUtility getTaskByPrimaryKey:[self selectedKey] inArray:taskmanager.taskList];
				Task *tmpTask=[ivoUtility getTaskByPrimaryKey:[self getSelectedTaskKey] inArray:taskmanager.taskList];
				
				if(tmpTask.primaryKey <-1 && tmpTask.parentRepeatInstance>-1){
                    NSMutableArray *arr=[NSMutableArray arrayWithArray:taskmanager.taskList];
					for(Task *tmp in arr){
						if(tmp.primaryKey==tmpTask.parentRepeatInstance){
							tmpTask=tmp;
							break;
						}
					}
				}
				//parameter format: _!$!_taskName_!$!_taskLocation_!$!_taskDescription_!$!_taskPinned_!$!_taskHowLong_!$!_taskWhere_!$!_taskProject_!$!_taskStartTime
				//					_!$!_taskDeadLine_!$!_taskIsUseDeadLine_!$!_parentRepeatInstance_!$!_taskPhoneToCall _!$!_taskEndRepeatDate _!$!_taskRepeatOptions
				//					_!$!_taskRepeatExceptions_!$!_taskRepeatID_!$!_versionNumber||_!$!_taskNumberInstances_!$!_taskAlertValues_!$!_taskREStartTime_!$!_isAllDayEvent
				NSString *linkParameters=[[NSString alloc] initWithFormat:@"%@_!$!_%@_!$!_%@_!$!_%d_!$!_%d_!$!_%d_!$!_%d_!$!_%f_!$!_%f_!$!_%d_!$!_%d_!$!_%@_!$!_%f_!$!_%@_!$!_%@_!$!_%d_!$!_%@_!$!_%d_!$!_%@_!$!_%f_!$!_%d",
										  tmpTask.taskName,
										  [tmpTask.taskLocation length]==0?@"NoLocation":tmpTask.taskLocation, 
										  [tmpTask.taskDescription length]==0? @"NoNotes":tmpTask.taskDescription,	
										  tmpTask.taskPinned,
										  tmpTask.taskHowLong,
										  tmpTask.taskWhere,
										  tmpTask.taskProject,
										  [tmpTask.taskStartTime timeIntervalSince1970],
										  [tmpTask.taskDeadLine timeIntervalSince1970],
										  tmpTask.taskIsUseDeadLine,
										  //new for 2.0 or later
										  tmpTask.parentRepeatInstance,
										  //[tmpTask.taskPhoneToCall length]==0? @"NoPhones":tmpTask.taskPhoneToCall,
										  @"NoPhones",
										  [tmpTask.taskEndRepeatDate timeIntervalSince1970],
										  [tmpTask.taskRepeatOptions length]==0? @"NoOptions":tmpTask.taskRepeatOptions,
										  [tmpTask.taskRepeatExceptions length]==0? @"NoExceptions":tmpTask.taskRepeatExceptions,
										  tmpTask.taskRepeatID,
										  @"2.0",
										  tmpTask.taskNumberInstances,
										  [tmpTask.taskAlertValues length]==0? @"NoAlert":tmpTask.taskAlertValues,
										  [tmpTask.taskREStartTime timeIntervalSince1970],
										  tmpTask.isAllDayEvent];
				
				printf("\n%s",[linkParameters UTF8String]);
				NSString *inspect1LinkParameters=[linkParameters stringByReplacingOccurrencesOfString:@"#" withString:@"_!$$!_"];
				NSString *inspect2LinkParameters=[inspect1LinkParameters stringByReplacingOccurrencesOfString:@"&" withString:@"_!$$_"];
				NSString *inspect3LinkParameters=[inspect2LinkParameters stringByReplacingOccurrencesOfString:@"?" withString:@"_$$!_"];
				NSString *inspect4LinkParameters=[inspect3LinkParameters stringByReplacingOccurrencesOfString:@" " withString:@"_$$$_"];
				
				//remove new line character from the link
				inspect4LinkParameters=[ivoUtility replaceNewLineCharactersFromStr:inspect4LinkParameters byString:@"_$!$_"];
				inspect4LinkParameters=[inspect4LinkParameters stringByReplacingOccurrencesOfString:@"/" withString:@"_!!$$_"];
				inspect4LinkParameters=[inspect4LinkParameters stringByReplacingOccurrencesOfString:@"|" withString:@"_$!!$_"];
				
				NSString *appLinkStr; 
				if(tmpTask.taskPinned==1){//event
					NSString *eventStartTimeStr=[ivoUtility createStringFromDate:tmpTask.taskStartTime isIncludedTime:YES];
					NSString *howlongStr=[ivoUtility createCalculateHowLong:tmpTask.taskHowLong];
#ifdef ST_BASIC
					appLinkStr= [[[NSString stringWithFormat: @"Hi, you have received a sharing Event:<br/>-Topic: '%@' <br/>-Location: %@ <br/>-Start Time: %@ <br/>-Duration: %@.<br/> <a href=""smarttimetasks://smarttimetasks/;",[tmpTask.taskName stringByReplacingOccurrencesOfString:@"&" withString:@" and "],[tmpTask.taskLocation stringByReplacingOccurrencesOfString:@"&" withString:@" and "],eventStartTimeStr,howlongStr] 
								  stringByAppendingString:	inspect4LinkParameters] 
								 stringByAppendingString:[[NSString stringWithFormat: @""">\nTap here to add this to SmartTime"]
														  stringByAppendingString:@"</a>"]];
					
#else					
					appLinkStr= [[[NSString stringWithFormat: @"Hi, you have received a sharing Event:<br/>-Topic: '%@' <br/>-Location: %@ <br/>-Start Time: %@ <br/>-Duration: %@.<br/> <a href=""smarttimeplus://smarttimeplus/;",[tmpTask.taskName stringByReplacingOccurrencesOfString:@"&" withString:@" and "],[tmpTask.taskLocation stringByReplacingOccurrencesOfString:@"&" withString:@" and "],eventStartTimeStr,howlongStr] 
								  stringByAppendingString:	inspect4LinkParameters] 
								 stringByAppendingString:[[NSString stringWithFormat: @""">\nTap here to add this to SmartTime"]
														  stringByAppendingString:@"</a>"]];
#endif					
					[howlongStr release];
					[eventStartTimeStr release];
				}else {
					NSString *howlongStr=[ivoUtility createCalculateHowLong:tmpTask.taskHowLong];
#ifdef ST_BASIC
					appLinkStr= [[[NSString stringWithFormat: @"Hi, you have received a sharing Task:<br/>-Topic: '%@' <br/>-Location: %@ <br/>-Duration: %@.<br/> <a href=""smarttimetasks://smarttimetasks/;",[tmpTask.taskName stringByReplacingOccurrencesOfString:@"&" withString:@" and "],[tmpTask.taskLocation stringByReplacingOccurrencesOfString:@"&" withString:@" and "],howlongStr] 
								  stringByAppendingString:	inspect4LinkParameters] 
								 stringByAppendingString:[[NSString stringWithFormat: @"""><br/>Tap here to add this to SmartTime"]
														  stringByAppendingString:@"</a>"]];
					
#else
					appLinkStr= [[[NSString stringWithFormat: @"Hi, you have received a sharing Task:<br/>-Topic: '%@' <br/>-Location: %@ <br/>-Duration: %@.<br/> <a href=""smarttimeplus://smarttimeplus/;",[tmpTask.taskName stringByReplacingOccurrencesOfString:@"&" withString:@" and "],[tmpTask.taskLocation stringByReplacingOccurrencesOfString:@"&" withString:@" and "],howlongStr] 
								  stringByAppendingString:	inspect4LinkParameters] 
								 stringByAppendingString:[[NSString stringWithFormat: @"""><br/>Tap here to add this to SmartTime"]
														  stringByAppendingString:@"</a>"]];
#endif					
					[howlongStr release];
				}
				
				
				NSString *bodyStr = [NSString stringWithFormat:@"mailto:%@?subject=Sharing %@ from SmartTime&body=%@",tmpTask.taskEmailToSend ? tmpTask.taskEmailToSend: @" ",tmpTask.taskPinned==0?@"Task":@"Event" ,appLinkStr];
				NSString *encoded = [bodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				encoded=[encoded stringByReplacingOccurrencesOfString:@" " withString:@""];
				NSURL *url = [[NSURL alloc] initWithString:encoded];
				
				//				[[UIApplication sharedApplication] openURL:url];
				
				BOOL success=NO;
				
				success=[[UIApplication sharedApplication] openURL:url];
				
				if(!success){
					UIAlertView *errorOpen=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"errorSharingCanNotLaunchMailAppText", @"")/*errorSharingCanNotLaunchMailAppText*/ message:nil 
																	 delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/ otherButtonTitles:nil];
					[errorOpen show];
					[errorOpen release];
				}
				
				[url release];
			
				[linkParameters release];
			
			}
				break;
				
			case 2://Phone Contact
			{
				if(![deviceType isEqualToString:@"iPhone"]){
					UIAlertView *noSupportAlert;
					noSupportAlert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"noSupportPlatformMsg", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/ otherButtonTitles:nil];
					[noSupportAlert show];
					[noSupportAlert release];
					return;
				}
				
				//trung ST3.1
				//NSString *taskPhoneStr=[[[ivoUtility getTaskByPrimaryKey:[self selectedKey] inArray:taskmanager.taskList] taskPhoneToCall] copy];
				NSString *taskPhoneStr=[[[ivoUtility getTaskByPrimaryKey:[self getSelectedTaskKey] inArray:taskmanager.taskList] taskPhoneToCall] copy];
				
				if(!taskPhoneStr || [taskPhoneStr isEqualToString:@""]){
					UIAlertView *phoneAlert;
					phoneAlert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"phoneErrText", @"")/*phoneErrText*/ message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/ otherButtonTitles:nil];
					[phoneAlert show];
					[phoneAlert release];
					[taskPhoneStr release];
					return;
				}

				BOOL success=NO;

				NSArray *phoneNumberList=[taskPhoneStr componentsSeparatedByString:@"/"];
				if(phoneNumberList.count<=1){
					goto launchNotSuccess;
				}else {
					if(phoneNumberList.count==2){//if existed only on phone number
						NSArray *phoneNumberStr=[[phoneNumberList objectAtIndex:1] componentsSeparatedByString:@"|"];	
						//NSString *phoneStr= [NSString stringWithFormat:@"tel:%@",[[[[phoneNumberStr objectAtIndex:1] stringByReplacingOccurrencesOfString:@"(" withString:@"-"] stringByReplacingOccurrencesOfString:@"+" withString:@"00"] stringByReplacingOccurrencesOfString:@" " withString:@""]];
						NSString *phoneStr= [NSString stringWithFormat:@"tel:%@",[[[phoneNumberStr objectAtIndex:1] stringByReplacingOccurrencesOfString:@"(" withString:@"-"] stringByReplacingOccurrencesOfString:@" " withString:@""]];
						success=[[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneStr]]; 
					}else {
						self.phoneList=phoneNumberList;
						
						callConfirm=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"phoneNumberText", @"")/*phoneNumberText*/ 
																			message:nil 
																		   delegate:self 
																  cancelButtonTitle:NSLocalizedString(@"cancelText", @"")/*cancelText*/ 
																  otherButtonTitles:nil];
						
						for(NSInteger i=1;i<phoneNumberList.count;i++){
							NSArray *phoneNumberStr=[[phoneNumberList objectAtIndex:i] componentsSeparatedByString:@"|"];	
							NSString *labelStr=[phoneNumberStr objectAtIndex:0];
							if([labelStr length]>8){
								labelStr=[[labelStr substringFromIndex:4] substringToIndex:[labelStr length]-8];
							}
							[callConfirm addButtonWithTitle:[NSString stringWithFormat:@"%@  %@",labelStr,[phoneNumberStr objectAtIndex:1]]];
						}
						
						[callConfirm show];
						[callConfirm release];
						return;
					}

				}

				
			launchNotSuccess:
				if(!success){
					UIAlertView *errorOpen=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"phoneErrText", @"")/*phoneErrText*/ message:nil 
																	 delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/ otherButtonTitles:nil];
					[errorOpen show];
					[errorOpen release];
				}
				[taskPhoneStr release];
				
			}
				break;
			case 3://send SMS
			{
				if(![deviceType isEqualToString:@"iPhone"]){
					UIAlertView *noSupportAlert;
					noSupportAlert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"noSupportPlatformMsg", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/ otherButtonTitles:nil];
					[noSupportAlert show];
					[noSupportAlert release];
					return;
				}
				
				NSString *taskPhoneStr=[[[ivoUtility getTaskByPrimaryKey:[self getSelectedTaskKey] inArray:taskmanager.taskList] taskPhoneToCall] copy];
				
				if(!taskPhoneStr || [taskPhoneStr isEqualToString:@""]){
					UIAlertView *phoneAlert;
					phoneAlert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"smsErrText", @"")/*smsErrText*/ message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/ otherButtonTitles:nil];
					[phoneAlert show];
					[phoneAlert release];
					[taskPhoneStr release];
					return;
				}
				
				BOOL success=NO;
				
				NSArray *phoneNumberList=[taskPhoneStr componentsSeparatedByString:@"/"];
				if(phoneNumberList.count<=1){
					goto launchSMSNotSuccess;
				}else {
					if(phoneNumberList.count==2){//if existed only one phone number
						NSArray *phoneNumberStr=[[phoneNumberList objectAtIndex:1] componentsSeparatedByString:@"|"];	
						NSString *phoneStr= [NSString stringWithFormat:@"sms:%@",[[[phoneNumberStr objectAtIndex:1] stringByReplacingOccurrencesOfString:@"(" withString:@"-"] stringByReplacingOccurrencesOfString:@" " withString:@""]];
						success=[[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneStr]]; 
					}else {
						self.phoneList=phoneNumberList;
						
						smsConfirm=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"selecAtPhoneNumberText", @"")/*selecAtPhoneNumberText*/ 
															   message:nil 
															  delegate:self 
													 cancelButtonTitle:NSLocalizedString(@"cancelText", @"")/*cancelText*/ 
													 otherButtonTitles:nil];
						
						for(NSInteger i=1;i<phoneNumberList.count;i++){
							NSArray *phoneNumberStr=[[phoneNumberList objectAtIndex:i] componentsSeparatedByString:@"|"];	
							NSString *labelStr=[phoneNumberStr objectAtIndex:0];
							if([labelStr length]>8){
								labelStr=[[labelStr substringFromIndex:4] substringToIndex:[labelStr length]-8];
							}
							[smsConfirm addButtonWithTitle:[NSString stringWithFormat:@"%@  %@",labelStr,[phoneNumberStr objectAtIndex:1]]];
						}
						
						[smsConfirm show];
						[smsConfirm release];
						return;
					}
					
				}
				
				
			launchSMSNotSuccess:
				if(!success){
					UIAlertView *errorOpen=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"smsErrText", @"")/*smsErrText*/ message:nil 
																	 delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/ otherButtonTitles:nil];
					[errorOpen show];
					[errorOpen release];
				}
				[taskPhoneStr release];
			}
				break;
		}
	}else if([modalView isEqual:upgradeAS]){
		switch (buttonIndex) {
			case 0://
			{
				NSString *bodyStr = [NSString stringWithFormat:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=295845767&mt=8"];
				NSString *encoded = [bodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				NSURL *url = [[NSURL alloc] initWithString:encoded];
				
				[[UIApplication sharedApplication] openURL:url];
				
				[url release];
				goto exit;
			}
				break;
			case 1://
			{
				NSString *bodyStr = [NSString stringWithFormat:@"http://leftcoastlogic.com/sttm"];
				NSString *encoded = [bodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				NSURL *url = [[NSURL alloc] initWithString:encoded];
				
				[[UIApplication sharedApplication] openURL:url];
				
				[url release];
				goto exit;
			}
				break;
			case 2://ST3.1 Admob
			{
				ProductListViewController *viewController=[[ProductListViewController alloc] init];
				[self.navigationController pushViewController:viewController animated:YES];
				[viewController release];
				goto exit;
				
//				[self synchronize:nil];
			}
				break;				
		}
	}
	
	[self refreshViews];

exit:	
	//trung ST3.1
	//[self resetQuickEditMode:YES taskKey:[self selectedKey]];
	[self resetQuickEditMode:YES taskKey:[self getSelectedTaskKey]];
	
	App_Delegate.me.networkActivityIndicatorVisible=NO;
	
	//ILOG(@"SmartViewController actionSheet]\n");
	
	//[self resetQuickEditMode:YES];
}

-(void)backupDataToMail{
    NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *dBPath = [documentsDirectory stringByAppendingPathComponent:@"IvoDatabase.sql"];
    if([fileManager fileExistsAtPath:dBPath]){
		NSData *fileData = [NSData dataWithContentsOfFile:dBPath];
		NSString *encodedString = [GTMBase64 stringByWebSafeEncodingData:fileData padded:YES];
		//NSString *fullLinkParameters = [NSString stringWithFormat:@"smartmoney://localhost/importDatabase?%@", encodedString];
		NSString *appLinkStr= [[NSString stringWithFormat: @"Hi,\n Your Smart Time database has been backed up into this mail successfully!<br/><br/> <a href=""smarttimeplus://localhost/importDatabase?%@",encodedString] 
							   stringByAppendingString:[[NSString stringWithFormat: @""">Tap here to restore the backed up database."]
                                                        stringByAppendingString:@"</a><br/><br/>Thanks for using Smart Time!"]];
		NSString *bodyStr = [[NSString stringWithFormat:@"mailto:?subject=Smart Time- Data backup: "] stringByAppendingString:[NSString stringWithFormat:@"%@&body=%@",[[ivoUtility createStringFromDate:[NSDate date] isIncludedTime:YES] autorelease],appLinkStr]];
		
		NSString *encoded =[bodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		//		printf("\n\n\n after endcoding: %s",[encoded UTF8String]);
		NSURL *url = [[NSURL alloc] initWithString:encoded];
		
		BOOL success=NO;
		
		success=[[UIApplication sharedApplication] openURL:url];
		
		if(!success){
			UIAlertView *errorOpen=[[UIAlertView alloc] initWithTitle:@"Could not launch Mail app!" message:@"Either your device does not support Mail app or your database has problem inside." 
															 delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[errorOpen show];
			[errorOpen release];
		}
		
		[url release];
	}
    
    /*
	//get full list of task from database;
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	if(taskmanager.fullTaskListBackUp !=nil){
		[taskmanager.fullTaskListBackUp release];
	}
	[App_Delegate getFullTaskListForBackup];
	/////////////////////////////////////////////
	
	//"_!$!_" used to separate parameters
	//"_!$$!_" replace for "#"
	//"_!$$_" replace for "&"
	//"_$$!_" replace for "?"
	//"_$$$_" replace for " "
	//"_!!$_" to seperate tasks
	//"_$!!_" to separate Tasks/Setting/Projects
	//"_!!$_" to seperate projects too
	//"_$!$_" replace for new line character
	// "_!!$$_" replace for "/" character
	//"_!!!_" replcase for "%"
	
	//"_$!!$_" replace for "|" character
	
	
	NSString *appLinkStr; 
	NSString *fullLinkParameters;
	NSString *linkParameters;
	NSString *inspect1LinkParameters;
	NSString *inspect2LinkParameters;
	NSString *inspect3LinkParameters;
	NSString *inspect4LinkParameters;
	
	fullLinkParameters=@"_$!!_";
	
	
	//backup task list
	for (NSInteger i=0;i<taskmanager.fullTaskListBackUp.count;i++){
		Task *tmpTask=[taskmanager.fullTaskListBackUp objectAtIndex:i];
		
		//parameter format: taskName_!$!_taskLocation_!$!_taskDescription_!$!_taskPinned_!$!_taskHowLong_!$!_taskWhere_!$!_taskProject_!$!_taskStartTime_!$!_taskDeadLine_!$!_taskIsUseDeadLine
		//					_!$!_taskEndTime_!$!_taskDueStartDate _!$!_taskDueEndDate _!$!_taskDateUpdate _!$!_taskPriority_!$!_taskStatus _!$!_taskCompleted
		//					_!$!_taskOriginalWhere_!$!_taskTypeUpdate_!$!_taskDefault _!$!_taskRepeatID _!$!_taskRepeatTimes _!$!_taskContact _!$!_taskAlertID 
		//					_!$!_taskNotEalierThan _!$!_gcalEventId _!$!_parentRepeatInstance_!$!_taskPhoneToCall _!$!_taskEndRepeatDate _!$!_taskRepeatOptions
		//					_!$!_taskRepeatExceptions_!$!_versionNumber_!$!_taskNumberInstances_!$!_taskAlertValues_!$!_isAllDayEvent_!$!_taskSynKey
		
		linkParameters=[[NSString alloc] initWithFormat:@"%@_!$!_%@_!$!_%@_!$!_%d_!$!_%d_!$!_%d_!$!_%d_!$!_%f_!$!_%f_!$!_%d_!$!_%f_!$!_%f_!$!_%f_!$!_%f_!$!_%f_!$!_%d_!$!_%d_!$!_%d_!$!_%d_!$!_%d_!$!_%d_!$!_%d_!$!_%@_!$!_%d_!$!_%f_!$!_%@_!$!_%d_!$!_%@_!$!_%f_!$!_%@_!$!_%@_!$!_%@_!$!_%d_!$!_%@_!$!_%d_!$!_%lf",
						tmpTask.taskName,																//0		//
						[tmpTask.taskLocation length]==0?@"NoLocation":tmpTask.taskLocation,			//1		//
						[tmpTask.taskDescription length]==0? @"NoNotes":tmpTask.taskDescription,		//2		//
						tmpTask.taskPinned,															//3			//
						tmpTask.taskHowLong,															//4		//
						tmpTask.taskWhere,															//5			//	
						tmpTask.taskProject,															//6		//
						[tmpTask.taskStartTime timeIntervalSince1970],								//7			//
						[tmpTask.taskDeadLine timeIntervalSince1970],									//8		//
						tmpTask.taskIsUseDeadLine,													//9			//
						[tmpTask.taskEndTime timeIntervalSince1970],								//10
						[tmpTask.taskDueStartDate timeIntervalSince1970],							//11
						[tmpTask.taskDueEndDate timeIntervalSince1970],								//12
						[tmpTask.taskDateUpdate timeIntervalSince1970],								//13
						[tmpTask.taskREStartTime timeIntervalSince1970],							//14
						tmpTask.taskStatus,															//15
						tmpTask.taskCompleted,														//16
						tmpTask.taskOriginalWhere,													//17	
						tmpTask.taskTypeUpdate,														//18
						tmpTask.taskDefault,														//19
						tmpTask.taskRepeatID,														//20		//
						tmpTask.taskRepeatTimes,													//21
						[tmpTask.taskContact length]==0?@"NoContact":tmpTask.taskContact,			//22
						tmpTask.taskAlertID,														//23
						[tmpTask.taskNotEalierThan timeIntervalSince1970],							//24
						tmpTask.gcalEventId,														//25
						
						//begin for 2.0 or later-----------------------------------------------
						tmpTask.parentRepeatInstance,												//26
						//[tmpTask.taskPhoneToCall length]==0? @"NoPhones":tmpTask.taskPhoneToCall,	//27			//
						@"NoPhones",	//27			//
						[tmpTask.taskEndRepeatDate timeIntervalSince1970],							//28			//
						[tmpTask.taskRepeatOptions length]==0? @"NoOptions":tmpTask.taskRepeatOptions,//29			//
						[tmpTask.taskRepeatExceptions length]==0? @"NoExceptions":tmpTask.taskRepeatExceptions,//30	//
						@"2.0",																			//31		//
						tmpTask.taskNumberInstances,													//32		//
						[tmpTask.taskAlertValues length]==0? @"NoAlert":tmpTask.taskAlertValues,				//33		//
						tmpTask.isAllDayEvent,															//34
						tmpTask.taskSynKey];															//35
		//end for 2.0 or later-----------------------------------------------
		
		inspect1LinkParameters=[linkParameters stringByReplacingOccurrencesOfString:@"#" withString:@"_!$$!_"];
		inspect2LinkParameters=[inspect1LinkParameters stringByReplacingOccurrencesOfString:@"&" withString:@"_!$$_"];
		inspect3LinkParameters=[inspect2LinkParameters stringByReplacingOccurrencesOfString:@"?" withString:@"_$$!_"];
		inspect4LinkParameters=[inspect3LinkParameters stringByReplacingOccurrencesOfString:@" " withString:@"_$$$_"];
		
		fullLinkParameters=[[fullLinkParameters stringByAppendingString:@"_!!$_"] stringByAppendingString:inspect4LinkParameters];
		
		[linkParameters release];
	}
	
	//printf("\n%s",[fullLinkParameters UTF8String]);
	//backup Setting
	fullLinkParameters=[fullLinkParameters stringByAppendingString:@"_$!!_"];
	//parameter format: alarmSoundName_!$!_deskTimeStart _!$!_deskTimeEnd _!$!_deskTimeWEStart _!$!_deskTimeWEEnd _!$!_homeTimeNDStart
	//					_!$!_homeTimeNDEnd _!$!_homeTimeWEStart _!$!_homeTimeWEEnd _!$!_iVoStyleID _!$!_howlongDefVal _!$!_contextDefID
	//					_!$!_projectDefID_!$!_primaryKey _!$!_taskMovingStyle _!$!_dueWhenMove _!$!_pushTaskFoward _!$!_cleanOldDayCount 
	//					_!$!_isFirstTimeStart _!$!_gCalAccount _!$!_lastSyncedTime_!$!_versionNumber
	linkParameters=[[NSString alloc] initWithFormat:@"%@_!$!_%f_!$!_%f_!$!_%f_!$!_%f_!$!_%f_!$!_%f_!$!_%f_!$!_%f_!$!_%d_!$!_%d_!$!_%d_!$!_%d_!$!_%d_!$!_%d_!$!_%d_!$!_%d_!$!_%d_!$!_%d_!$!_%@_!$!_%f_!$!_%@",
					[taskmanager.currentSetting.alarmSoundName length]==0?@"NoSound":taskmanager.currentSetting.alarmSoundName,//0
					[taskmanager.currentSetting.deskTimeStart timeIntervalSince1970],	//1
					[taskmanager.currentSetting.deskTimeEnd timeIntervalSince1970],		//2
					[taskmanager.currentSetting.deskTimeWEStart timeIntervalSince1970],	//3
					[taskmanager.currentSetting.deskTimeWEEnd timeIntervalSince1970],	//4
					[taskmanager.currentSetting.homeTimeNDStart timeIntervalSince1970],	//5
					[taskmanager.currentSetting.homeTimeNDEnd timeIntervalSince1970],	//6
					[taskmanager.currentSetting.homeTimeWEStart timeIntervalSince1970],	//7
					[taskmanager.currentSetting.homeTimeWEEnd timeIntervalSince1970],	//8
					taskmanager.currentSetting.iVoStyleID,								//9
					taskmanager.currentSetting.howlongDefVal,							//10
					taskmanager.currentSetting.contextDefID,							//11
					taskmanager.currentSetting.projectDefID,							//12
					taskmanager.currentSetting.primaryKey,								//13
					taskmanager.currentSetting.taskMovingStyle,							//14
					taskmanager.currentSetting.dueWhenMove,								//15
					taskmanager.currentSetting.pushTaskFoward,							//16
					taskmanager.currentSetting.cleanOldDayCount,						//17
					taskmanager.currentSetting.isFirstTimeStart,						//18
					@"NoGCalACCount",													//19
					
					//begin for ST 2.0
					[taskmanager.currentSetting.lastSyncedTime timeIntervalSince1970],	//20
					@"2.0"];															//21
	
	inspect1LinkParameters=[linkParameters stringByReplacingOccurrencesOfString:@"#" withString:@"_!$$!_"];
	inspect2LinkParameters=[inspect1LinkParameters stringByReplacingOccurrencesOfString:@"&" withString:@"_!$$_"];
	inspect3LinkParameters=[inspect2LinkParameters stringByReplacingOccurrencesOfString:@"?" withString:@"_$$!_"];
	inspect4LinkParameters=[inspect3LinkParameters stringByReplacingOccurrencesOfString:@" " withString:@"_$$$_"];
	
	fullLinkParameters=[fullLinkParameters stringByAppendingString:linkParameters];
	[linkParameters release];
	
	//printf("\n\n\n after adding Setting: %s",[fullLinkParameters UTF8String]);
	
	//backup Project List----------------------------------------------
	fullLinkParameters=[fullLinkParameters stringByAppendingString:@"_$!!_"];
	
	for(NSInteger i=0;i<projectList.count;i++){
		Projects *tmp=(Projects *)[projectList objectAtIndex:i];
		
		//parameter format: primaryKey_!$!_projName
		linkParameters=[[NSString alloc] initWithFormat:@"%d_!$!_%@",
						tmp.primaryKey,
						[tmp.projName length]==0?@"NoProName":tmp.projName];
		
		inspect1LinkParameters=[linkParameters stringByReplacingOccurrencesOfString:@"#" withString:@"_!$$!_"];
		inspect2LinkParameters=[inspect1LinkParameters stringByReplacingOccurrencesOfString:@"&" withString:@"_!$$_"];
		inspect3LinkParameters=[inspect2LinkParameters stringByReplacingOccurrencesOfString:@"?" withString:@"_$$!_"];
		inspect4LinkParameters=[inspect3LinkParameters stringByReplacingOccurrencesOfString:@" " withString:@"_$$$_"];
		
		fullLinkParameters=[[fullLinkParameters stringByAppendingString:@"_!!$_"] stringByAppendingString:inspect4LinkParameters];	
		
		//remove new line characters from the link
		//fullLinkParameters=[ivoUtility removeNewLineCharactersFromStr:fullLinkParameters];
		
		[linkParameters release];
	}
	
	//printf("\n\n\n after adding Project %s",[fullLinkParameters UTF8String]);
	
	fullLinkParameters=[ivoUtility replaceNewLineCharactersFromStr:fullLinkParameters byString:@"_$!$_"];
	fullLinkParameters=[fullLinkParameters stringByReplacingOccurrencesOfString:@"/" withString:@"_!!$$_"];
	fullLinkParameters=[fullLinkParameters stringByReplacingOccurrencesOfString:@"|" withString:@"_$!!$_"];
	fullLinkParameters=[fullLinkParameters stringByReplacingOccurrencesOfString:@"|" withString:@"_$!!$_"];
	fullLinkParameters=[fullLinkParameters stringByReplacingOccurrencesOfString:@"%" withString:@"_!!!_"];
	
	//NSData *source=[fullLinkParameters dataUsingEncoding:NSUnicodeStringEncoding];
	//fullLinkParameters=[NSDataBase64 base64Encoding:source];
	
	//printf("\napp par: %s",[fullLinkParameters UTF8String]);
#ifdef	ST_BASIC
	appLinkStr= [[[NSString stringWithFormat: @"Hi, your data has been backed up successfully into this email.  Please save this email in a safe place.  It is a good idea to save a copy on your iPhone and another copy on your desktop computer or on your email server.<br/><br/> <a href=""smarttimetasks://smarttimetasks/;"] 
				  stringByAppendingString:	fullLinkParameters] 
				 stringByAppendingString:[[[NSString stringWithFormat: @""">Please tap here to restore this backup to SmartTime Plus."]
										   stringByAppendingString:@"</a><br/><br/>Warning:  During the restore process, all existing data will be overwritten!"] 
										  stringByAppendingString: @"<br/><br/>For further instructions or questions, please <a href=""http://leftcoastlogic.com/wp/?p=42"">tap here."]];
#else
	appLinkStr= [[[NSString stringWithFormat: @"Hi, your data has been backed up successfully into this email.  Please save this email in a safe place.  It is a good idea to save a copy on your iPhone and another copy on your desktop computer or on your email server.<br/><br/> <a href=""smarttimeplus://smarttimeplus/;"] 
				  stringByAppendingString:	fullLinkParameters] 
				 stringByAppendingString:[[[NSString stringWithFormat: @""">Please tap here to restore this backup to SmartTime Plus."]
										   stringByAppendingString:@"</a><br/><br/>Warning:  During the restore process, all existing data will be overwritten!"] 
										  stringByAppendingString: @"<br/><br/>For further instructions or questions, please <a href=""http://leftcoastlogic.com/wp/?p=42"">tap here."]];
	
#endif	
	
	NSString *currentTime=[ivoUtility createStringFromDate:[NSDate date] isIncludedTime:YES];
	NSString *bodyStr = [[NSString stringWithFormat:@"mailto:?subject=SmartTime Backup - "] stringByAppendingString:[NSString stringWithFormat:@"%@&body=%@",currentTime,appLinkStr]];
	[currentTime release];
	
//	NSData *source=[bodyStr dataUsingEncoding:NSUnicodeStringEncoding];
	//bodyStr=[source dataUsingEncoding:NSUnicodeStringEncoding];
//	bodyStr=[NSDataBase64 base64Encoding:source];
	
	NSString *encoded =[bodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
//	printf("\n\n\n after endcode %s",[encoded UTF8String]);
	
	encoded=[encoded stringByReplacingOccurrencesOfString:@" " withString:@""];
	encoded=[encoded stringByReplacingOccurrencesOfString:@"\"" withString:@""];
	encoded=[encoded stringByReplacingOccurrencesOfString:@"\'" withString:@""];
	//encoded=[encoded stringByReplacingOccurrencesOfString:@"\'" withString:@""];
	
	encoded=[ivoUtility replaceNewLineCharactersFromStr:encoded byString:@""];
	NSURL *url = [[NSURL alloc] initWithString:encoded];
	
	//[[UIApplication sharedApplication] openURL:url];
	
	BOOL success=NO;
	
	success=[[UIApplication sharedApplication] openURL:url];
	
	if(!success){
		UIAlertView *errorOpen=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"errorBackupCanNotLaunchMailAppText", @"")] message:nil 
														 delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"") otherButtonTitles:nil];
		[errorOpen show];
		[errorOpen release];
	}
	
	[url release];
	
	/////////////////////////////////////////////
	if(taskmanager.fullTaskListBackUp !=nil){
		[taskmanager.fullTaskListBackUp release];
		taskmanager.fullTaskListBackUp=nil;
	}
	App_Delegate.me.networkActivityIndicatorVisible=NO;
	*/
    
}

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex{
	//ILOG(@"[SmartTimeView alertView\n")
	
	if (alertVw.tag== TOODLEDO_SYNC_SUCCES_TAG) {
		[alertVw dismissWithClickedButtonIndex:0 animated:YES];
		[self startRefreshTasks];
		[self performSelector:@selector(synchronize:)];
		[self stopSyncIndicator];
		
		
	}else  if (alertVw.tag== TOODLEDO_ERROR_TAG) {
		[self stopSyncIndicator];
		[self performSelector:@selector(synchronize:)];
		
	}else if([alertVw isEqual:delayAlert]){
		if(buttonIndex==1){
			//trung ST3.1
			//[taskmanager delayTask:[self selectedKey] delayType:delayType isAutoChangeDue:YES];
			[taskmanager delayTask:[self getSelectedTaskKey] delayType:delayType isAutoChangeDue:YES];
		}else if(buttonIndex==2){
			//trung ST3.1
			//[self editTask:[self selectedKey]];
			[self editTask:[self getSelectedTaskKey]];
		}
	}else if([alertVw isEqual:deleteREAlertView]) {
		//printf("\n%d",[self selectedKey] );
		if(buttonIndex !=0){
			if([[ivoUtility getTaskByPrimaryKey:currentSelectedKey inArray:taskmanager.taskList] isOneMoreInstance]!=1){
				[taskmanager deleteTask:currentSelectedKey isDeleteFromDB:YES deleteREType:buttonIndex];
			}else {
				[taskmanager deleteTask:currentSelectedKey isDeleteFromDB:YES deleteREType:buttonIndex+1];
			}

		}
	}else if([alertVw isEqual:deleteConfirmAlertView]) {
		if(buttonIndex==1){
			if([smartView superview]||[calendarView superview]){
				[taskmanager deleteTask:currentSelectedKey isDeleteFromDB:YES deleteREType:-1];
			}else if([listTaskView superview]){
				//[[listTaskView tableViewDo] deselectRowAtIndexPath:[NSIndexPath indexPathForRow:listTaskView.pathIndex inSection:0]  animated:YES];
				[listTaskView deselectedCell];
				
				//[taskmanager deleteTask:[[taskmanager.quickTaskList objectAtIndex:listTaskView.pathIndex] primaryKey] isDeleteFromDB:YES deleteREType:-1];
				[taskmanager deleteTask:currentSelectedKey isDeleteFromDB:YES deleteREType:-1];
				listTaskView.isDoViewSelected=NO;
				listTaskView.pathIndex=-1;
			}
			
		}
		
	}else if([alertVw isEqual:callConfirm]) {
		if(buttonIndex>0){
			NSArray *phoneNumberStr=[[self.phoneList objectAtIndex:buttonIndex] componentsSeparatedByString:@"|"];	
			//NSString *phoneStr= [NSString stringWithFormat:@"tel:%@",[[[[phoneNumberStr objectAtIndex:1] stringByReplacingOccurrencesOfString:@"(" withString:@"-"] stringByReplacingOccurrencesOfString:@"+" withString:@"00"] stringByReplacingOccurrencesOfString:@" " withString:@""]];
			NSString *phoneStr= [NSString stringWithFormat:@"tel:%@",[[[phoneNumberStr objectAtIndex:1] stringByReplacingOccurrencesOfString:@"(" withString:@"-"] stringByReplacingOccurrencesOfString:@" " withString:@""]];
			BOOL success=[[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneStr]]; 
			
			if(!success){
				UIAlertView *errorOpen=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"phoneErrText", @"")/*phoneErrText*/ message:nil 
																 delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/ otherButtonTitles:nil];
				[errorOpen show];
				[errorOpen release];
			}			
		}
	}else if([alertVw isEqual:smsConfirm]) {
		if(buttonIndex>0){
			NSArray *phoneNumberStr=[[self.phoneList objectAtIndex:buttonIndex] componentsSeparatedByString:@"|"];	
			//NSString *phoneStr= [NSString stringWithFormat:@"tel:%@",[[[[phoneNumberStr objectAtIndex:1] stringByReplacingOccurrencesOfString:@"(" withString:@"-"] stringByReplacingOccurrencesOfString:@"+" withString:@"00"] stringByReplacingOccurrencesOfString:@" " withString:@""]];
			NSString *phoneStr= [NSString stringWithFormat:@"sms:%@",[[[phoneNumberStr objectAtIndex:1] stringByReplacingOccurrencesOfString:@"(" withString:@"-"] stringByReplacingOccurrencesOfString:@" " withString:@""]];
			BOOL success=[[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneStr]]; 
			
			if(!success){
				UIAlertView *errorOpen=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"smsErrText", @"")/*smsErrText*/ message:nil 
																 delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/ otherButtonTitles:nil];
				[errorOpen show];
				[errorOpen release];
			}
		}
	}else if([alertVw isEqual:markDoneEventAlert] && buttonIndex==1) {
		if([smartView superview]||[calendarView superview]){
			[taskmanager markedCompletedTask:currentSelectedKey doneREType:1];
		}else if([listTaskView superview]){
			[listTaskView deselectedCell];
			[taskmanager markedCompletedTask:[[taskmanager.quickTaskList objectAtIndex:listTaskView.pathIndex] primaryKey] doneREType:1];
			listTaskView.isDoViewSelected=NO;
			listTaskView.pathIndex=-1;
			[listTaskView refreshData];
		}
		
		//[listTaskView refreshData];
		
	}

	[self refreshViews];
	
	//exit quick edit mode
	//trung ST3.1
	//[self resetQuickEditMode:YES taskKey:[self selectedKey]] ; 
	[self resetQuickEditMode:YES taskKey:[self getSelectedTaskKey]]; 
}

- (void)flipAction:(id)sender
{
	//ILOG(@"[SmartViewController flipAction\n");
	
	//ILOG(@"[SmartViewController flipAction\n");
	
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	BOOL isFlipping=NO;
	BOOL isNeedRefreshView=NO;
	
	if([filterView superview]){
		[self filterTask:nil];
	}
	
	if(isEdit){
		[self resetQuickEditMode:isEdit taskKey:-1];
	}
	
	if(smartView ==nil){
		smartView = [[SmartTimeView alloc] initWithFrame:smartViewFrame];
		_smartTimeView = smartView;
		[smartView initData:-1];
	}			

	//trung ST3.1
	//if([smartView superview]){
	if([contentView superview] && [smartView superview]){
		[self cacheImage];
	}
	
    CGRect frame=[[UIScreen mainScreen] bounds];
    
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:animationIDfinished:finished:context:)];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.75];
	
	[UIView setAnimationTransition:([contentView superview] ?
									UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
						   forView:self.containerView cache:YES];
	if ([backSideContentView superview])
	{
		isFlipping=YES;
		//BOOL needCheckAutoSync=NO;
		//if (taskmanager.currentSettingModifying.autoICalSync==1 && taskmanager.currentSetting.autoTDSync==0) {
		//	needCheckAutoSync=YES;
		//}
		
		//if (![smartView superview]) {
		//	[contentMainView addSubview:smartView];
		//}
		
		if(sender==doneButton){
			//backup current setting
			Setting *currentSettingBackup=[[Setting alloc] init];
			//currentSettingBackup=[ivoUtility createCopySetting:currentSetting];
			[ivoUtility copySetting:taskmanager.currentSetting toSetting:currentSettingBackup];
			
			//currentSetting=[ivoUtility createCopySetting:currentSettingModifying];
			taskmanager.currentSetting=taskmanager.currentSettingModifying;
			//check error
			if(![currentSettingBackup.deskTimeStart isEqualToDate:taskmanager.currentSetting.deskTimeStart] ||
			   ![currentSettingBackup.deskTimeEnd isEqualToDate:taskmanager.currentSetting.deskTimeEnd] ||
			   ![currentSettingBackup.deskTimeWEStart isEqualToDate:taskmanager.currentSetting.deskTimeWEStart] ||
			   ![currentSettingBackup.deskTimeWEEnd isEqualToDate:taskmanager.currentSetting.deskTimeWEEnd] ||
			   ![currentSettingBackup.homeTimeNDStart isEqualToDate:taskmanager.currentSetting.homeTimeNDStart] ||
			   ![currentSettingBackup.homeTimeNDEnd isEqualToDate:taskmanager.currentSetting.homeTimeNDEnd] ||
			   ![currentSettingBackup.homeTimeWEStart isEqualToDate:taskmanager.currentSetting.homeTimeWEStart] ||
			   ![currentSettingBackup.homeTimeWEEnd isEqualToDate:taskmanager.currentSetting.homeTimeWEEnd]||
				currentSettingBackup.startWorkingWDay !=taskmanager.currentSetting.startWorkingWDay ||
				currentSettingBackup.endWorkingWDay !=taskmanager.currentSetting.endWorkingWDay){
				
				[App_Delegate startInitialValuesForSeachingTimeSlot:taskmanager.currentSetting];
				TaskActionResult *ret=[taskmanager applyNewSetting4TaskList:taskmanager.currentSettingModifying];
				if(ret.errorNo==ERR_TASK_NOT_BE_FIT_BY_RE||ret.errorNo==ERR_RE_MAKE_TASK_NOT_BE_FIT) {
					UIAlertView	*taskNotBeFitByREAlert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"REMakeTaskNotFitText", @"")/*REMakeTaskNotFitText*/  message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/ otherButtonTitles:nil];
					
					[taskNotBeFitByREAlert show];
					[taskNotBeFitByREAlert release];
					//trung ST3.1
					//[self resetQuickEditMode:YES taskKey:[self selectedKey]];
					[self resetQuickEditMode:YES taskKey:[self getSelectedTaskKey]];
					[ret release];
					taskmanager.currentSetting=currentSettingBackup;
					
					[currentSettingBackup release];
					
					[App_Delegate startInitialValuesForSeachingTimeSlot:taskmanager.currentSetting];
					return;
				}else if(ret.errorNo==ERR_TASK_ANOTHER_PASS_DEADLINE){
					//roll back change
					
					//currentSetting=[ivoUtility createCopySetting:currentSettingBackup];
					taskmanager.currentSetting=currentSettingBackup;
					
					[currentSettingBackup release];
					
					//UIAlertView *applyNewSetting4TaskListAlert=[[UIAlertView alloc] initWithTitle:@"Apply this will cause some existing tasks to pass their deadlines. Change Auto Bump Deadline to Automatically if you still want to apply!" message:nil delegate:self cancelButtonTitle:okText otherButtonTitles:nil];
					UIAlertView *applyNewSetting4TaskListAlert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"applyNewSettingMakesDtasksPassDeadlineText", @"")/*applyNewSettingMakesDtasksPassDeadlineText*/ message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/ otherButtonTitles:nil];
					[applyNewSetting4TaskListAlert show];
					[applyNewSetting4TaskListAlert release];
					[ret release];
					[App_Delegate startInitialValuesForSeachingTimeSlot:taskmanager.currentSetting];
					return;
				} 
				
				[ret release];
			}	

			[currentSettingBackup release];
			
			//save changing in setting view			
			[taskmanager.currentSetting update];
			if (self.needCheckAutoSync) {
				[taskmanager checkForFullSync];
			}
			
			//update iVo style
			[self resetIVoStyle];
			isNeedRefreshView=YES;
			
		}		
				
		//flip back Smart View
		[settingView  removeFromSuperview];
		[settingView release];
		settingView=nil;
		
		[backSideContentView removeFromSuperview];
		[self.containerView addSubview:contentView];
		
		//self.navigationItem.title =@"Smart View";
		[titleView setTitle:NSLocalizedString(@"smartViewText", @"")/*smartViewText*/ forState:UIControlStateNormal];
		//		[self freeChildControllerToSaveSapce];
		
		//[self freeOffScreenViews];
		if(isNeedRefreshView){
			[NSTimer scheduledTimerWithTimeInterval:0.75 
											 target:self 
										   selector:@selector(refreshViews) 
										   userInfo:nil 
											repeats:NO];
		}
		
		loadingView=SMART_VIEW;
	}
	else
	{
		loadingView=SETTING_VIEW;
		isFlipping=YES;
		if(settingView==nil){
			settingView=[[SettingView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-64)];//[[UIScreen mainScreen] bounds]];
			settingView.backgroundColor=[UIColor whiteColor];
			settingView.rootViewController=self;
		}
		if([settingView superview]){
			[settingView removeFromSuperview];
		}
		
		[backSideContentView addSubview:settingView];
		taskmanager.currentSettingModifying=taskmanager.currentSetting;
		[settingView resetData];

		[contentView removeFromSuperview];
		[self.containerView addSubview:backSideContentView];
		
		[titleView setTitle:NSLocalizedString(@"settingsText", @"")/*settingsText*/ forState:UIControlStateNormal];
		
		[backSideContentView bringSubviewToFront:settingToolbar];
	}
	
	[UIView commitAnimations];
	isFlipping=NO;
	if(isFlipping) return;
	
	if ([backSideContentView superview]){
		self.navigationItem.rightBarButtonItem=doneButton;
		//self.navigationItem.leftBarButtonItem=cancelButton;
		self.navigationItem.leftBarButtonItem=aboutUs;
	}else {
		self.navigationItem.rightBarButtonItem= addButton;
		self.navigationItem.leftBarButtonItem=infoSettingButton;//projectDisplayBt;
	}
	
	App_Delegate.me.networkActivityIndicatorVisible=NO;
	
	//[self freeOffScreenViews];
	//ILOG(@"SmartViewController flipAction]\n");
}

-(void)fullDoneHistory:(id)sender{
	
	//ILOG(@"[SmartViewController fullDoneHistory\n");
	
	//Trung 08101002
	/*
	if(historyView==nil){
		historyView=[[HistoryViewController alloc] init];
	}
	*/
	loadingView=HISTORY_VIEW;
	
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	historyView=[[HistoryViewController alloc] init];
	
	[historyView setEditing:YES animated:YES];
	
//	if(listTaskView.isDoViewSelected){
//		[listTaskView tableView:[listTaskView tableViewDo] didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:listTaskView.pathIndex inSection:0]];
//		listTaskView.pathIndex=-1;
//	}
	[listTaskView deselectedCell];
	listTaskView.pathIndex=-1;

	[self.navigationController pushViewController:historyView animated:YES];
	
	//Trung 08101002
	[historyView release];
	App_Delegate.me.networkActivityIndicatorVisible=NO;
	
	//ILOG(@"SmartViewController fullDoneHistory]\n");
}

-(void)showAboutUs:(id)sender{
	//App_Delegate.me.networkActivityIndicatorVisible=YES;
	if(self.transitioning) {
		return;
	}
	
    /*
	if([settingView superview]){
		if(aboutUsView ==nil){
			aboutUsView=[[AboutUsView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];	
			//aboutUsView=[[AboutUsWebView alloc] initWithFrame:smartViewFrame];	
		}
		
		[self replaceSubview:settingView withSubview:aboutUsView transition:kCATransitionMoveIn direction:kCATransitionFromTop duration:0.75 controlView:backSideContentView];		
		//self.navigationItem.leftBarButtonItem=nil;
		self.navigationController.navigationBar.tintColor=[UIColor blackColor];
		self.navigationItem.rightBarButtonItem=self.lclPageBarBt;
		//self.navigationItem.title=aboutUsText;
		[titleView setTitle:NSLocalizedString(@"aboutUsText", @"") forState:UIControlStateNormal];
		
		
	}else if([aboutUsView superview]){
		// Set up the animation
		
		self.navigationController.navigationBar.tintColor=nil;
		[self replaceSubview:aboutUsView withSubview:settingView transition:kCATransitionMoveIn direction:kCATransitionFromBottom duration:0.75 controlView:backSideContentView];		

		self.navigationItem.leftBarButtonItem=aboutUs;
		self.navigationItem.rightBarButtonItem=doneButton;
		//self.navigationItem.title=settingsText;
		[titleView setTitle:NSLocalizedString(@"settingsText", @"") forState:UIControlStateNormal];
		
		[aboutUsView release];
		aboutUsView=nil;
	}

		
     App_Delegate.me.networkActivityIndicatorVisible=NO;
     */
    
    AboutLCLViewController *viewController=[[AboutLCLViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

//-(void)backupData:(id)sender{
//	backupActionSheet.actionSheetStyle = self.navigationController.navigationBar.barStyle;
//	[backupActionSheet showInView:self.view];	
//}

-(void)jump2DateChanged:(id)sender{
	self.selectedWeekDate=jumpToDateDP.date;
}

-(void)goAction:(id)sender{
	if(isEdit){
		[self resetQuickEditMode:isEdit taskKey:-1];
	}
	
	[self refreshViews];
	[self popDownJumpDate];
}

-(void)invokeJumpToDate:(id)sender{

#ifdef FREE_VERSION	
	
#else
	if([calendarView superview]){
		if(_calendarView.isInQuickAddMode) return;
		
		self.selectedWeekDate=[NSDate date];
		if(isJump2DatePKPopUp){
			[self popDownJumpDate];
		}else {
			[self popUpJumpDate];
		}
	}
#endif	
}

-(void)byLCL:(id)sender{
	/*
	ProductListViewController *viewController=[[ProductListViewController alloc] init];
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];
	 */
	ByLCL *viewController=[[ByLCL alloc] initialize];
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];
}

- (void)hintOK: (id) sender
{
	[self hideModal:guideView];
}

- (void)dontShowHint: (id) sender
{
	[self hideModal:guideView];
	
	NSNumber *welcomeEnabled = [NSNumber numberWithInt:0];
	
	[App_Delegate.hintSettingDict setValue:welcomeEnabled forKey:@"welcomeEnabled"];
	
	[App_Delegate saveHintSettingDict];		
}

#pragma mark Transition methods

-(void)transitionView{
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	//ILOG(@"[SmartViewController transitionView\n");

	if(self.transitioning) {
		return;
	}
		
	NSInteger selectedIndex=buttonBarSegmentedControl.selectedSegmentIndex;
	switch (selectedIndex) {
		case 0:
		{
			loadingView=SMART_VIEW;
			if([listTaskView superview]) {
				//reset task list
				if(!isFilter){
					self.navigationItem.leftBarButtonItem=infoSettingButton;//projectDisplayBt;;
				}else {
					self.navigationItem.leftBarButtonItem=noneFilterButton;
				}
				
				self.navigationItem.rightBarButtonItem=addButton;

				if(smartView ==nil){
					smartView = [[SmartTimeView alloc] initWithFrame:smartViewFrame];
					_smartTimeView = smartView;
				
					[smartView initData:-1];
					
				}
				else
				{
					[smartView initData:-1];
				}
				
				[self replaceSubview:listTaskView withSubview:smartView transition:kCATransitionMoveIn direction:kCATransitionFromTop duration:kTransitionDuration controlView:contentMainView];
				//[smartView initData:-1];
								
			} else if([calendarView superview]){
				
				if(!isFilter){
					self.navigationItem.leftBarButtonItem=infoSettingButton;//projectDisplayBt;;
					//return full tasks list here
					
				}else{
					//get filter result list here
					//ST3.2.1 - show exit Filter button
					self.navigationItem.leftBarButtonItem=noneFilterButton;
				}
				
				if(smartView ==nil){
					smartView = [[SmartTimeView alloc] initWithFrame:smartViewFrame];
					_smartTimeView = smartView;
					
					[smartView initData:-1];
					
				}
				else
				{
					[smartView initData:-1];
				}

				[self replaceSubview:calendarView withSubview:smartView transition:kCATransitionMoveIn direction:kCATransitionFromTop duration:kTransitionDuration controlView:contentMainView];
			}else if([filterView superview]) {
				[self filterTask:nil];//re animate filter view
				[self viewSelected:nil];//call back segment change.	
			}
			
			[titleView setTitle:NSLocalizedString(@"smartViewText", @"")/*smartViewText*/ forState:UIControlStateNormal];
		}
			break;
		case 1:
			loadingView=CALENDAR_VIEW;
			if([listTaskView superview]) {
				if(!isFilter){
					self.navigationItem.leftBarButtonItem=todayButton;
				}else {
					self.navigationItem.leftBarButtonItem=noneFilterButton;
				}

				self.navigationItem.rightBarButtonItem=addButton;
				
				if(calendarView ==nil)
				{
					calendarView = [[CalendarPageView alloc] initWithFrame:smartViewFrame];	
				}
				
				[titleView setTitle:NSLocalizedString(@"calendarViewText", @"")/*calendarViewText*/ forState:UIControlStateNormal];

				NSDate *currentDatePage=(self.selectedWeekDate != nil?[self.selectedWeekDate copy]:[[_calendarView getScrollDate] copy]);
				
				if(self.selectedWeekDate)
				{
					self.selectedWeekDate=nil;
				}					
				
				//nang 3.1.1
				//[_calendarView initData:currentDatePage];
				[NSTimer scheduledTimerWithTimeInterval:0 target:_calendarView selector:@selector(initDataWithInfo:) userInfo:currentDatePage repeats:NO];
				
				[currentDatePage release];
				
				[self replaceSubview:listTaskView withSubview:calendarView transition:kCATransitionMoveIn direction:kCATransitionFromBottom duration:kTransitionDuration controlView:contentMainView];

			} else if([smartView superview]){
				if(!isFilter){
					self.navigationItem.leftBarButtonItem=todayButton;
					self.navigationItem.rightBarButtonItem=addButton;
					//return full tasks list here
					
				}else{
					//get filter result list here
					//ST3.2.1 - show exit Filter button
					self.navigationItem.leftBarButtonItem=noneFilterButton;
				}
			
				//trung ST3.1
				//[self cacheImage];
				if([contentView superview])
				{
					[self cacheImage];
				}
				
				if(calendarView ==nil)
				{
					calendarView = [[CalendarPageView alloc] initWithFrame:smartViewFrame];	
				}
					
				[titleView setTitle:NSLocalizedString(@"calendarViewText", @"")/*calendarViewText*/ forState:UIControlStateNormal];
				
				NSDate *currentDatePage=(self.selectedWeekDate != nil?[self.selectedWeekDate copy]:[[_calendarView getScrollDate] copy]);
				
				if(self.selectedWeekDate)
				{
					self.selectedWeekDate=nil;
				}					

				//nang 3.1.1
				//[_calendarView initData:currentDatePage];
				[NSTimer scheduledTimerWithTimeInterval:0 target:_calendarView selector:@selector(initDataWithInfo:) userInfo:currentDatePage repeats:NO];

				[currentDatePage release];
				
				[self replaceSubview:smartView withSubview:calendarView transition:kCATransitionMoveIn direction:kCATransitionFromBottom duration:kTransitionDuration controlView:contentMainView];

			}else if([filterView superview]) {
				
				if(calendarView ==nil)
				{
					calendarView = [[CalendarPageView alloc] initWithFrame:smartViewFrame];	
				}
				
				[titleView setTitle:NSLocalizedString(@"calendarViewText", @"")/*calendarViewText*/ forState:UIControlStateNormal];
				
				NSDate *currentDatePage=(self.selectedWeekDate != nil?[self.selectedWeekDate copy]:[[_calendarView getScrollDate] copy]);
				
				if(self.selectedWeekDate)
				{
					self.selectedWeekDate=nil;
				}					
				
				//nang 3.1.1
				//[_calendarView initData:currentDatePage];
				[NSTimer scheduledTimerWithTimeInterval:0 target:_calendarView selector:@selector(initDataWithInfo:) userInfo:currentDatePage repeats:NO];
				
				[currentDatePage release];
				
				[self filterTask:nil];//re animate filter view
				[self viewSelected:nil];//call back segment change.	
			}

			break;
		case 2:
			loadingView=FOCUS_VIEW;
			if(listTaskView ==nil){
				listTaskView=[[ListTaskView alloc] initWithFrame:smartViewFrame];
                listTaskView.backgroundColor=[UIColor lightGrayColor];
				listTaskView.rootViewController=self;
			}

			listTaskView.pathIndex=-1;
			listTaskView.restoreIndex=-1;
			
			if([smartView superview]) {
				//trung ST3.1
				//[self cacheImage];
				if ([contentView superview])
				{
					[self cacheImage];
				}
				[self replaceSubview:smartView withSubview:listTaskView transition:kCATransitionMoveIn direction:kCATransitionFromRight duration:kTransitionDuration controlView:contentMainView];
			} else if([calendarView superview]){
				[self replaceSubview:calendarView withSubview:listTaskView transition:kCATransitionMoveIn direction:kCATransitionFromRight duration:kTransitionDuration controlView:contentMainView];
			}else if([filterView superview]) {
				[self filterTask:nil];//re animate filter view
				[self viewSelected:nil];//call back segment change.	
			}
			
			if(!isFilter){
				self.navigationItem.leftBarButtonItem=fullDoneButton;
			}else {
				listTaskView.filterCaluse=taskmanager.filterClause;
				self.navigationItem.leftBarButtonItem=noneFilterButton;
			}
			
			[NSTimer scheduledTimerWithTimeInterval:0 target:listTaskView selector:@selector(refreshData) userInfo:nil repeats:NO];
			
			self.navigationItem.rightBarButtonItem=addButton;
			
			[titleView setTitle:NSLocalizedString(@"focusText", @"")/*focusText*/ forState:UIControlStateNormal];
			break;
			
		case 3:
		{
			/*
			WeekViewCalController *viewController=[[WeekViewCalController alloc] init];
			viewController.SmartViewController = self;
			
			[viewController shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
			[self.navigationController presentModalViewController:viewController animated:YES];
			//[self.navigationController pushViewController:viewController animated:YES];
			[viewController release];
			*/
		}
			break;
	}
			
	[self freeOffScreenViews];
	
	App_Delegate.me.networkActivityIndicatorVisible=NO;
	//ILOG(@"SmartViewController transitionView]\n");
}

- (void)replaceSubview:(UIView *)oldView withSubview:(UIView *)newView transition:(NSString *)transition 
			 direction:(NSString *)direction duration:(NSTimeInterval)duration controlView:(UIView *)controlView{ 
	//ILOG(@"[SmartViewController replaceSubview\n");
	
	NSArray *subViews = [controlView subviews];
	NSUInteger index;
	
	if ([oldView superview] == controlView) {
		// Find the index of oldView so that we can insert newView at the same place
		for(index = 0; [subViews objectAtIndex:index] != oldView; ++index) {}
		[oldView removeFromSuperview];
	}
	
	// If there's a new view and it doesn't already have a superview, insert it where the old view was
	if (newView && ([newView superview] == nil))
		[controlView insertSubview:newView atIndex:index];
	
	
	// Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setDelegate:controlView];
	
	// Set the type and if appropriate direction of the transition, 
	if (transition == kCATransitionFade) {
		[animation setType:kCATransitionFade];
	} else {
		[animation setType:transition];
		[animation setSubtype:direction];
	}
	
	// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
	[animation setDuration:duration];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[controlView layer] addAnimation:animation forKey:kAnimationKey];
	
	//ILOG(@"SmartViewController replaceSubview]\n");
}

#pragma mark pushViewControllers
-(void)pushSettingsRelativeView:(infoEditKey)keyEdit editObject:(id)editObject{
	
	//ILOG(@"[SmartViewController pushSettingsRelativeView\n");
		if (keyEdit==SETTING_TIMESREPEAT || keyEdit==SETTING_ENDDUEDAYS
			 || keyEdit==SETTING_CLEANOLDDATA){
			InfoEditViewController *infoEditView=[[InfoEditViewController alloc] init];	
			
			infoEditView.keyEdit=keyEdit;
			infoEditView.editedObject=editObject;
			[self.navigationController pushViewController:infoEditView animated:YES];
			
			[infoEditView release];
			
		//}else if(keyEdit==SETTING_PROJECTDEFAULT || keyEdit==SETTING_PROJECTEDIT||keyEdit==SETTING_GCALPROJMAP){
		}else if(keyEdit==SETTING_PROJECTDEFAULT || keyEdit==SETTING_PROJECTEDIT){
			ProjectViewController *projectView=[[ProjectViewController alloc] init];
			
			if(keyEdit==SETTING_PROJECTDEFAULT){
				projectView.pathIndex=[editObject projectDefID];
			}
			//EK Sync
			/*else {
				if(projectView.projectsListBackup!=nil){
					[projectView.projectsListBackup release];
				}
				projectView.projectsListBackup =[ivoUtility createCopyProjectList:projectList];
			}*/
			
			projectView.keyEdit=keyEdit;
			projectView.editedObject=editObject;
			[projectView setEditing:YES animated:YES];
			[self.navigationController pushViewController:projectView animated:YES];
			
			[projectView release];
			
		}else if (keyEdit==SETTING_GCALPROJMAP)
		{
			/*
			SyncMappingTableViewController *mappingCtrler = [[SyncMappingTableViewController alloc] init];
			//SyncMappingViewController *mappingCtrler = [[SyncMappingViewController alloc] init];
			
			[self.navigationController pushViewController:mappingCtrler animated:YES];
			
			[mappingCtrler release];
			 */
		}else if (keyEdit==SETTING_REPEATDEFID || keyEdit==SETTING_CONTEXTDEFID ||
				  keyEdit==SETTING_IVOSTYLEDEFID||keyEdit==SETTING_TASKMOVE ||
				  keyEdit==SETTING_PASSDUEMOVE||keyEdit==SETTING_SYNCTYPE||
				  keyEdit==SETTING_BADGE||keyEdit==SETTING_WEEK_START_DAY){
			GeneralListViewController *generalListView=[[GeneralListViewController alloc] init];
			
			generalListView.editedObject=editObject; 
			generalListView.keyEdit=keyEdit;
			if(keyEdit==SETTING_REPEATDEFID) {
				generalListView.pathIndex=[editObject repeatDefID];//currentSetting.repeatDefID;
			}else if(keyEdit==SETTING_CONTEXTDEFID){
				generalListView.pathIndex=[editObject contextDefID];//currentSetting.contextDefID;
			}else if(keyEdit==SETTING_IVOSTYLEDEFID){
				generalListView.pathIndex=[editObject iVoStyleID];//currentSetting.iVoStyleID;
			}else if(keyEdit==SETTING_TASKMOVE){
				generalListView.pathIndex=[editObject taskMovingStyle];//currentSetting.taskMovingStyle;
			}else if(keyEdit==SETTING_PASSDUEMOVE){
				generalListView.pathIndex=[editObject dueWhenMove];
			}else if(keyEdit==SETTING_SYNCTYPE){
				generalListView.pathIndex=[editObject syncType];
			}else if(keyEdit==SETTING_BADGE){
				generalListView.pathIndex=[editObject badgeType];
			}else if(keyEdit==SETTING_WEEK_START_DAY) {
				generalListView.pathIndex=[editObject weekStartDay];
			}

			
			[generalListView setEditing:YES animated:YES];
			[self.navigationController pushViewController:generalListView animated:YES];
			
			[generalListView release];
			
		}if (keyEdit==SETTING_DESKTIME||keyEdit==SETTING_HOMETIME){
			TimeSettingViewController *timerView=[[TimeSettingViewController alloc] init];
			
			timerView.editedObject=editObject;
			timerView.keyEdit=keyEdit;
			[timerView setEditing:YES animated:YES];
			[self.navigationController pushViewController:timerView animated:YES];
			
			[timerView release];
		}else if(keyEdit==SETTING_SETUPGCALACC) {
			/*SetUpMailAccountViewController *gCalAccController=[[SetUpMailAccountViewController alloc] init];
			gCalAccController.editedObject=editObject;
			[gCalAccController setEditing:YES animated:YES];
			[self.navigationController pushViewController:gCalAccController animated:YES];
			[gCalAccController release];
             */
		}else if(keyEdit==SETTING_BACKUP) {
			BackupViewController *backupController=[[BackupViewController alloc] init];
			[backupController setEditing:YES animated:YES];
			[self.navigationController pushViewController:backupController animated:YES];
			[backupController release];
		}else if(keyEdit==SETTING_HOWLONG){
			
			DurationViewController *infoEditView=[[DurationViewController alloc] init];	
			
			infoEditView.keyEdit=keyEdit;
			infoEditView.editedObject=editObject;
			[self.navigationController pushViewController:infoEditView animated:YES];
			
			[infoEditView release];
			
		}else if(keyEdit==SETTING_GCALSYNCGUIDE) {
			GCalSyncGuideViewController *viewController=[[GCalSyncGuideViewController alloc] init];
			[self.navigationController pushViewController:viewController animated:YES];
			[viewController release];
		}else if(keyEdit==SETTING_WORKDAYS) {
			WeekDaySettingViewController *viewController=[[WeekDaySettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
			viewController.editedObject=editObject;
			[self.navigationController pushViewController:viewController animated:YES];
			[viewController release];
		}else if(keyEdit==SETTING_SNOOZE_DURATION) {
			SnoozeDurationViewController *viewController=[[SnoozeDurationViewController alloc] init];
			viewController.editedObject=editObject;
			[self.navigationController pushViewController:viewController animated:YES];
			[viewController release];
		}else if(keyEdit==SETTING_SYNCGUIDE) {
			SyncGuideViewController *viewController=[[SyncGuideViewController alloc] init];
			[self.navigationController pushViewController:viewController animated:YES];
			[viewController release];
		}



	//ILOG(@"SmartViewController pushSettingsRelativeView]\n");
}

#pragma mark ViewControllerDelegate

/*
// Implement viewDidLoad if you need to do additional setup after loading the view.
- (void)viewDidLoad {
	[super viewDidLoad];
}
 */

// called after this controller's view will appear
- (void)viewWillAppear:(BOOL)animated
{
	self.navigationController.navigationBarHidden=NO;

	if (_didStartup)
	{
		//ILOG(@"[SmartViewController viewWillAppear\n");
		[self resetIVoStyle];	
		//reload data on setting view if it is existing
		if([backSideContentView superview]){
			//[settingView.tableView reloadData];
			[settingView resetData];
		}else if([listTaskView superview]) {
			//[listTaskView.tableViewDo reloadData];
			[NSTimer scheduledTimerWithTimeInterval:0 target:listTaskView selector:@selector(refreshData) userInfo:nil repeats:NO];
			//[listTaskView refreshData];
		}
		
		isDeferingTask=NO;
		
		//[self refreshViews];	
		if(!appFirstStart && ![backSideContentView superview])
			[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(refreshViews) userInfo:nil repeats:NO];
	}

	
	//ILOG(@"SmartViewController viewWillAppear]\n");
}

- (void)viewWillDisappear:(BOOL)animated{
	[listTaskView deselectedCell];
	listTaskView.pathIndex=-1;
	
	if([filterView superview]){
		[self filterTask:nil];
	}
	
	//trung ST3.1
	//if([smartView superview]){	
	if([contentView superview] && [smartView superview]){
		[self cacheImage];
	}
	
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	//App_Delegate.me.networkActivityIndicatorVisible=YES;	
#ifdef FREE_VERSION
	return (interfaceOrientation==UIInterfaceOrientationPortrait || interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown);
#else
#ifdef ST_BASIC
	return (interfaceOrientation==UIInterfaceOrientationPortrait || interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown);
#else	
    /*
	// groundColor=[UIColor blackColor];
	if(interfaceOrientation==UIInterfaceOrientationPortrait || interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown){
		self.navigationController.navigationBarHidden=NO;
		self.view.frame=CGRectMake(0, 0, 320, 480);
		
	}else {
		//trung ST3.1
		if ([backSideContentView superview])
		{
			return NO;
		}
		self.navigationController.navigationBarHidden=YES;
		self.view.frame=CGRectMake(0, 0, 480, 320);
	}
	*/
    
	//App_Delegate.me.networkActivityIndicatorVisible=NO;
	return YES;
#endif	
    
#endif
 
	return YES;
}

//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    // groundColor=[UIColor blackColor];
    
    if (isJump2DatePKPopUp) {
        [self popDownJumpDate];
    }
    
    CGRect frame=[[UIScreen mainScreen] bounds];
    
	if(toInterfaceOrientation==UIInterfaceOrientationPortrait || toInterfaceOrientation==UIInterfaceOrientationPortraitUpsideDown){
		self.navigationController.navigationBarHidden=NO;
		self.view.frame=CGRectMake(0, 0, frame.size.width, frame.size.height);
		
	}else {
		//trung ST3.1
		if ([backSideContentView superview])
		{
		//	return;
		}
		self.navigationController.navigationBarHidden=YES;
		self.view.frame=CGRectMake(0, 0, frame.size.height, frame.size.width);
	}

#ifndef FREE_VERSION
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	if(toInterfaceOrientation==UIInterfaceOrientationPortrait || toInterfaceOrientation==UIInterfaceOrientationPortraitUpsideDown){
		//trung ST3.1
		if (weekView != nil && [weekView superview])
		{
			[weekView removeFromSuperview];
            [weekView release];
			weekView=nil;
			//[containerView addSubview:contentView];
			
		}
        
        contentView.hidden=NO;
	}else {		
		//trung ST 3.1
		//if([smartView superview]){
		if([contentView superview] && [smartView superview]){
			[self cacheImage];
		}
		
		
		if (weekView) {
            if ([weekView superview])
            {
                [weekView removeFromSuperview];
            }
            
			[weekView release];
			weekView=nil;
		}
		
		weekView = [[WeekView alloc] initWithFrame:CGRectMake(0, 0, frame.size.height, frame.size.width)];
		
        [containerView addSubview:weekView];
        
        contentView.hidden=YES;
		
	}
    
    
    
	App_Delegate.me.networkActivityIndicatorVisible=NO;
	
#endif

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	
	//trung ST3.1
	if(fromInterfaceOrientation==UIInterfaceOrientationPortraitUpsideDown || fromInterfaceOrientation==UIInterfaceOrientationPortrait)
	{
		if (weekView != nil)
		{
			weekView.isFilter = isFilter;
		}
	}
	else
	{
		if (weekView != nil)
		{
			isFilter = weekView.isFilter;
			self.selectedWeekDate = weekView.currentDisplayDate;
		}
		
	}
	
	[self refreshViews];
}

-(void)viewDidAppear:(BOOL)animated{
	//[NSThread detachNewThreadSelector:@selector(prepareForAnotherViews) toTarget:self withObject:nil];
	appFirstStart=NO;
	
	/*
	NSNumber *welcomeEnabled = [App_Delegate.hintSettingDict objectForKey:@"welcomeEnabled"];
	
	if (!(welcomeEnabled != nil && [welcomeEnabled intValue] == 0) && guideView != nil)
	{
		[self showModal:guideView];	
	}
	*/
    
    [contentView bringSubviewToFront:contentMainView];
    [contentView bringSubviewToFront:toolbar];
    
}

-(void)startup
{
	
		[App_Delegate startup];
		
		[self.navigationController setNavigationBarHidden:NO animated:NO];	

		//trung ST 3.1
		[self initView];
		
		//trung ST3.1
		[self resetIVoStyle];
				
		///////////////////
		if(appFirstStart && taskmanager.currentSetting.pushTaskFoward==1) {
			[self startRefreshTasks];
		}
		else
		{
			[self refreshViews];
		}
}

-(void)startRefreshTasks{
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	BOOL ret=[taskmanager refreshTaskList];

    printf("\n %d",ret);
    
	//trung ST3.1 - refresh screen
	[self refreshViews];
	
	App_Delegate.me.networkActivityIndicatorVisible=NO;
}

/*
- (void)didReceiveMemoryWarning {
	printf("\nMemory warning...");
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
	//free child view to save space
//	[self freeChildControllerToSaveSapce];

}
*/

- (void)dealloc {
	//[gcalsync release];
	[queryToDoTodayClause release];
	[containerView release];
	[smartView release];
	[titleView release];
    
	[calendarView release];
	[listTaskView release];
	[historyView release];
	
	[filterView release];
	
	[settingView release];
	[contentView release];
	[contentMainView release];
	[buttonBarSegmentedControl release];
	
	[infoSettingButton release];
	[addButton release];
	[aboutUs release];
	[deleteButton release];
	[doneButton release];
	[todayButton release];
	[filterButton release];
	[noneFilterButton release];
	[fullDoneButton release];
	
	[quickEditActionSheet release];
	[outActionSheet release];

	[segmentedControlEdit release];
	[toolbarNormalModeItems release];
	[toolbarEditModeItems release];
	[toolbar release];
	[settingToolbar release];
	[aboutUsView release];
	[backSideContentView release];
	[aboutUsView release];
//	[backupActionSheet release];
	
//	[smartImageView release];
//	[calendarImageView release];
	
	[adMobAd release];
	[autoslider invalidate];
	
	[upgradeAS release];
	
	//EK Sync 
	[syncProgressView release];	
	
	[projectDisplayBt release];
	[weekView release];
    
	[super dealloc];
}

#pragma mark TouchController
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	
	for (UITouch *touch in touches) {

	}
}


#pragma mark Common methods

-(NSInteger)selectedKey{
	//ILOG(@"[SmartViewController selectedKey\n");
	if([smartView superview]){
		//ILOG(@"SmartViewController selectedKey]\n");
		return [_smartTimeView getSelectedKey];
	}else if([calendarView superview]) {
		//ILOG(@"SmartViewController selectedKey]\n");
		return [_calendarView getSelectedKey];
	}
	//ILOG(@"SmartViewController selectedKey]\n");
	return -1;
}

//trung ST3.1
-(NSInteger)getSelectedTaskKey{
	//purpose: to populate dummy RE instance if any to taskmanager.tasklist before returning the key
	if([smartView superview]){
		return [_smartTimeView getSelectedTaskKey];
	}else if([calendarView superview]) {
		return [_calendarView getSelectedTaskKey];
	}
	return currentSelectedKey;
}


/*
-(void) goBackView
{
	if ([smartImageView superview])
	{
		[smartImageView removeFromSuperview];
		[smartView initData:-1];
		
		[contentMainView addSubview:smartView];		
	}
	else if ([calendarImageView superview])
	{
		[calendarImageView removeFromSuperview];

		if(self.selectedWeekDate){
			//[calendarView initData:self.selectedWeekDate];
			[_calendarView initData:self.selectedWeekDate];
			NSString *formattedDateString = [ivoUtility createStringFromDate:self.selectedWeekDate isIncludedTime:NO];
			
			//self.navigationItem.title = formattedDateString;
			[titleView setTitle:formattedDateString forState:UIControlStateNormal];
			[formattedDateString release];
			self.selectedWeekDate=nil;
			
		}else {
			
			NSDate *currentDatePage=[[_calendarView getScrollDate] copy];
			[_calendarView initData:currentDatePage];
			[currentDatePage release];
		}
		
		[contentMainView addSubview:calendarView];	
	}
	else if ([focusImageView superview])
	{
		[focusImageView removeFromSuperview];
		
		[listTaskView refreshData];
		
		[contentMainView addSubview:listTaskView];
		
	}
	
}
*/

-(void)refreshAfterDupDeletion
{
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	if([smartView superview])
	{
		[smartView performSelector:@selector(initData:)];
	}
	else if([calendarView superview]) 
	{
		NSDate *currentDatePage=(self.selectedWeekDate != nil?[self.selectedWeekDate copy]:[[_calendarView getScrollDate] copy]);
		
		if(self.selectedWeekDate)
		{
			self.selectedWeekDate=nil;
		}	
		
		[_calendarView initData:currentDatePage];
		
		[currentDatePage release];		
	}
	else if([listTaskView superview])
	{
		[listTaskView refreshData];
	}
	
	App_Delegate.me.networkActivityIndicatorVisible=NO;	
}

-(void)refreshViews{
	//ILOG(@"[SmartViewController refreshViews\n");
	//printf("refresh view\n");
	App_Delegate.me.networkActivityIndicatorVisible=YES;

	if(isEdit){
		[self resetQuickEditMode:isEdit taskKey:-1];
	}
	
	//trung ST3.1 - when exit filter from Week/Month View -> update the left navigate
	if (isFilter)
	{
		self.navigationItem.leftBarButtonItem=noneFilterButton;
	}	
	
	//trung ST3.1
	if (!contentView.hidden)
	{
		if([smartView superview]){
			if(self.isAddNew){
				[smartView initData:self.newTaskPrimaryKey];
			}else {
				if(isDeferingTask){
					[smartView initData:self.newTaskPrimaryKey];
				}else {
					[smartView initData:-1];
				}
			}
			
			if (!isFilter) //trung ST3.1 - when exit filter from Week/Month View -> update the left navigation button
			{
				self.navigationItem.leftBarButtonItem = infoSettingButton;//projectDisplayBt;;
			}			
			
		}else if([calendarView superview]) {
			if(self.isAddNew){
				[_calendarView initData:[[ivoUtility getTaskByPrimaryKey:self.newTaskPrimaryKey inArray:taskmanager.taskList] taskStartTime]];

			}else {
				if(isDeferingTask){
					[_calendarView initData:[[ivoUtility getTaskByPrimaryKey:self.newTaskPrimaryKey inArray:taskmanager.taskList] taskStartTime]];
				}else {
					
					NSDate *currentDatePage=(self.selectedWeekDate != nil?[self.selectedWeekDate copy]:[[_calendarView getScrollDate] copy]);
					
					if(self.selectedWeekDate)
					{
						self.selectedWeekDate=nil;
					}	
					
					[_calendarView initData:currentDatePage];
					
					[currentDatePage release];
				}
			}
			
			if (!isFilter) //trung ST3.1 - when exit filter from Week/Month View -> update the left navigation button
			{
				self.navigationItem.leftBarButtonItem = todayButton;
			}
			
		}else if([listTaskView superview]){
			[NSTimer scheduledTimerWithTimeInterval:0 target:listTaskView selector:@selector(refreshData) userInfo:nil repeats:NO];
			//[listTaskView refreshData];
			
			if (!isFilter) //trung ST3.1 - when exit filter from Week/Month View -> update the left navigation button
			{
				self.navigationItem.leftBarButtonItem = fullDoneButton;
			}			
		}
		
	}
	else
	{
		[weekView startWeekView];
	}	

endRefreshView:
	
	isCancelledEditFromDetail=NO;
	
	isDeferingTask=NO;
	self.isAddNew=NO;
	//ILOG(@"SmartViewController refreshViews]\n");

	if ([self.view isEqual:startupView])
	{	
		self.view=self.containerView;
		//[startupView removeFromSuperview];
		[startupView release];
		startupView=nil;
	}
	
    [contentView bringSubviewToFront:contentMainView];
    [contentView bringSubviewToFront:toolbar];

	App_Delegate.me.networkActivityIndicatorVisible=NO;

}

-(void)editTask:(NSInteger)taskKey {
	//ILOG(@"[SmartViewController editTask\n");

	//Trung 08101002
	/*
    if(taskDetail==nil){
		taskDetail=[[TaskEventDetailViewController alloc] init];
	}
	*/
	
	if(_calendarView && _calendarView.isInQuickAddMode) return;
	
	TaskEventDetailViewController *taskDetail=[[TaskEventDetailViewController alloc] init];
	
	taskDetail.keyEdit=1;
	
	taskDetail.typeEdit=0;
	if(taskDetail.taskItem !=nil){
		[taskDetail.taskItem release];
	}
	
	Task *tmp=[[Task alloc] init];
	[ivoUtility copyTask:[ivoUtility getTaskByPrimaryKey:taskKey inArray:taskmanager.taskList] 
					 toTask:tmp isIncludedPrimaryKey:YES];
	
	//[ivoUtility printTask:taskmanager.taskList];
	
	if(tmp.primaryKey < -1 || (tmp.taskRepeatID>0 && tmp.taskRepeatTimes != 1)){
		taskDetail.typeEdit=1;
	}
		
	taskDetail.taskItem=tmp;//[tmp retain];
	[tmp release];
	
	[self.navigationController pushViewController:taskDetail animated:YES];
	
	//Trung 08101002
	[taskDetail release];
	
	//ILOG(@"SmartViewController editTask]\n");
}

-(void)editTaskFromListView:(Task*)task{
	//ILOG(@"[SmartViewController editTaskFromListView\n");
	TaskEventDetailViewController *taskDetail=[[TaskEventDetailViewController alloc] init];	
	
	Task *tmp=[[Task alloc] init];
	
	[ivoUtility copyTask:task toTask:tmp isIncludedPrimaryKey:YES];
	taskDetail.taskItem=tmp;
	[tmp release];
	
	taskDetail.keyEdit=1;
	[taskDetail setEditing:NO animated:NO];
	[self.navigationController pushViewController:taskDetail animated:YES];
	
	//Trung 08101002
	[taskDetail release];
	
	//ILOG(@"SmartViewController editTaskFromListView]\n");
}

-(void)resetIVoStyle{
	 
	//ILOG(@"[SmartViewController resetIVoStyle\n");
	if(taskmanager.currentSetting.iVoStyleID==0){
		// for aesthetic reasons (the background is black), make the nav bar black for this particular page
		self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
		// match the status bar with the nav bar
		[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
		
		self.containerView.backgroundColor=[UIColor colorWithRed:1 green:1 blue:1 alpha:0.9];
		 
		toolbar.barStyle=UIBarStyleDefault;
		segmentedControlEdit.tintColor = nil;
		buttonBarSegmentedControl.tintColor = nil;
	}else{
		// for aesthetic reasons (the background is black), make the nav bar black for this particular page
		self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
		// match the status bar with the nav bar
		[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
		
		self.containerView.backgroundColor=[UIColor blackColor];
		toolbar.barStyle=UIBarStyleBlackOpaque;
		segmentedControlEdit.tintColor = [UIColor darkGrayColor];
		buttonBarSegmentedControl.tintColor = [UIColor darkGrayColor];
		
	}
	
	//Nang3.8
	if (weekView != nil && [weekView superview])
	{
		[weekView resetIvoStyle];
	}

	//ILOG(@"SmartViewController resetIVoStyle]\n");
}

-(void) resetQuickEditMode:(BOOL)isInEdit taskKey:(NSInteger)taskKey{
	//ILOG(@"[SmartViewController resetQuickEditMode\n");
	if(isInEdit){
		toolbar.items= toolbarNormalModeItems;
		isEdit=NO;
		self.keywords=nil;
		self.searchingKeyWords=nil;
	}else {
		toolbar.items=toolbarEditModeItems;
		self.keywords=[[ivoUtility getTaskByPrimaryKey:currentSelectedKey inArray:taskmanager.taskList] taskName];
		self.searchingKeyWords=[[ivoUtility getTaskByPrimaryKey:currentSelectedKey inArray:taskmanager.taskList] taskLocation];

		isEdit=YES;
	}

	//ILOG(@"SmartViewController resetQuickEditMode]\n");
}

- (UIButton *)buttonWithTitle:	(NSString *)title
					   target:(id)target
					 selector:(SEL)selector
						frame:(CGRect)frame
						image:(NSString *)image
				 imagePressed:(NSString *)imagePressed
				darkTextColor:(BOOL)darkTextColor
{	
	//ILOG(@"[SmartViewController buttonWithTitle\n");
	UIButton *button = [[UIButton alloc] initWithFrame:frame];
	// or you can do this:
	//		UIButton *button = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	//		button.frame = frame;
	button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	[button setTitle:title forState:UIControlStateNormal];	
		
	if (darkTextColor)
	{
		[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	}
	else
	{
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	}
	
	if(image !=nil){
		UIImage *newImage = [[UIImage imageNamed:image] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		[button setBackgroundImage:newImage forState:UIControlStateNormal];
	}
	
	if(imagePressed !=nil){
    	UIImage *newPressedImage = [[UIImage imageNamed:imagePressed] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		[button setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
	}
			
	[button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
	
    // in case the parent view draws with a custom color or gradient, use a transparent color
	button.backgroundColor = [UIColor clearColor];
	//ILOG(@"SmartViewController buttonWithTitle]\n");
	return button;
}

-(void)freeChildControllerToSaveSapce
{
	[self freeOffScreenViews];
}

-(void)freeOffScreenViews{
/*	 if([calendarView superview]) {				
		if (smartView!=nil)
			[smartView release];
		smartView=nil;
		
		if(listTaskView !=nil)
			[listTaskView release];
		listTaskView=nil;
	}else if([listTaskView superview]) {
		if(calendarView !=nil)
			[calendarView release];
		calendarView=nil;
		_calendarView=nil;
		
		if (smartView!=nil)
			[smartView release];
		smartView=nil;
	}else if([smartView superview]) {
		if(calendarView !=nil)
			[calendarView release];
		calendarView=nil;
		_calendarView=nil;
		
		if(listTaskView !=nil)
			[listTaskView release];
		listTaskView=nil;
		
	}
 */
}

- (void) cacheImage
{
    CGRect frame=[[UIScreen mainScreen] bounds];
    
	UIGraphicsBeginImageContext(CGSizeMake(frame.size.width, frame.size.height-62));
	[containerView.layer renderInContext:UIGraphicsGetCurrentContext()]; 
	
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext(); 
	
	UIGraphicsEndImageContext(); 
	
    NSString *filename = @"startup.png";
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *uniquePath = [documentsDirectory stringByAppendingPathComponent: filename];
	
	[UIImagePNGRepresentation(img) writeToFile: uniquePath atomically: NO];
	
	//printf("\n write result: %d",ret);
}	

- (UIImage *) getCachedImage
{
    NSString *filename = @"startup.png";
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *uniquePath = [documentsDirectory stringByAppendingPathComponent: filename];
    
    UIImage *image=nil;
    
    // Check for a cached version
    if([[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
    {
        image = [UIImage imageWithContentsOfFile: uniquePath]; // this is the cached image
    }
	
    return image;
}

//EK Sync
- (void) syncEventComplete
{
	[syncProgressView hide];
	[syncProgressView removeFromSuperview];
	
	[self refreshViews];
}

#pragma mark transition view
- (void)animationDidStart:(CAAnimation *)animation {
	
	self.transitioning = YES;
    
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished {
	
	self.transitioning = NO;
}


-(void)popUpJumpDate{
    CGRect frame=[[UIScreen mainScreen] bounds];
    
	if(jumpToDateView==nil){
		jumpToDateView=[[UIView alloc] initWithFrame:CGRectMake(0, 64, frame.size.width,frame.size.height-55-64)];
		jumpToDateView.backgroundColor=[UIColor whiteColor];
		jumpToDateView.alpha=0.85;
		
		jumpToDateDP=[[UIDatePicker alloc] initWithFrame:CGRectMake(0,frame.size.height-280-64,frame.size.width, 280)];
		[jumpToDateDP addTarget:self action:@selector(jump2DateChanged:) forControlEvents:UIControlEventValueChanged];
		jumpToDateDP.datePickerMode=UIDatePickerModeDate;
		jumpToDateDP.minuteInterval=5;
		[jumpToDateView addSubview:jumpToDateDP];
		[jumpToDateDP release];
		
		UIButton *goButton=[ivoUtility createButton:NSLocalizedString(@"goText", @"")/*goText*/ 
								 buttonType:UIButtonTypeCustom
									  frame:CGRectMake(240, 80, 60, 30)
								 titleColor:[UIColor whiteColor] 
									 target:self 
								   selector:@selector(goAction:) 
						   normalStateImage:@"blue-small.png" 
						 selectedStateImage:nil];
		[jumpToDateView addSubview:goButton];
		[goButton release];
		
		[contentView addSubview:jumpToDateView];
		[jumpToDateView release];
	}
	
	jumpToDateDP.date=self.selectedWeekDate;
	
	[contentView bringSubviewToFront:jumpToDateView];
	jumpToDateView.frame=CGRectMake(0, 64, frame.size.width,frame.size.height-65-64);
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	
	[animation setType:kCATransitionMoveIn];
	[animation setSubtype:kCATransitionFromTop];
	
	// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
	[animation setDuration:0.3];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[jumpToDateView layer] addAnimation:animation forKey:kAnimationKey];	
	isJump2DatePKPopUp=YES;
}

-(void)popDownJumpDate{
    CGRect frame=[[UIScreen mainScreen] bounds];
    
	jumpToDateView.frame=CGRectMake(0,frame.size.height+10, frame.size.width, 350);
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	
	[animation setType:kCATransitionReveal];
	[animation setSubtype:kCATransitionFromBottom];
	
	// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
	[animation setDuration:0.3];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[jumpToDateView layer] addAnimation:animation forKey:kAnimationKey];	
	isJump2DatePKPopUp=NO;
}

@end

