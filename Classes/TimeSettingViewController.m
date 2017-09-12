//
//  TimeSettingViewController.m
//  iVo
//
//  Created by Nang Le on 7/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TimeSettingViewController.h"
#import "IvoCommon.h"
#import "Setting.h"
#import "ivo_Utilities.h"
#import "SmartTimeAppDelegate.h"
#import "SmartViewController.h"
#import "InfoEditViewController.h"
#import "GeneralListViewController.h"
#import "Colors.h"
#import "TableCellTimer.h"
#import "TaskManager.h"
#import "SmartTimeAppDelegate.h"

extern NSTimeZone *App_defaultTimeZone;
extern NSTimeInterval dstOffset;

//extern Setting						*currentSetting;
extern SmartTimeAppDelegate			*App_Delegate;
extern NSMutableArray				*repeatList;
extern ivo_Utilities				*ivoUtility;
extern TaskManager					*taskmanager;

//extern NSString *startTimeIsLaterEndTimeText;


@implementation TimeSettingViewController
@synthesize editedObject,keyEdit,cellContent2IntVal,cellContent3IntVal,isOrderDateError,currentDuration,isUseDeadLine,
			cellContent0,cellContent1,cellContent2,cellContent3,allDayEvent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

- (id) init
{
	if (self = [super init])
	{
	}
	return self;
}

- (void)loadView {
	//ILOG(@"[TimeSettingViewController loadView\n");
    CGRect frame=[[UIScreen mainScreen] bounds];
    
	saveButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
															  target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = saveButton;
	self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;

	mainView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
	mainView.backgroundColor=[UIColor groupTableViewBackgroundColor];
	self.view=mainView;

	datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
	//datePicker.hidden=YES;
	
	
	[datePicker addTarget:self action:@selector(timeChanged:) forControlEvents:UIControlEventValueChanged];
	datePicker.minuteInterval=5;
	[mainView addSubview: datePicker];

	tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, 210) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
	tableView.scrollEnabled=NO;
	tableView.sectionHeaderHeight=1;
	tableView.sectionFooterHeight=1;
	
    [mainView addSubview:tableView];
	[self showDatePicker];

	editRepeatCountButton=[ivoUtility createButton:@""
							  buttonType:UIButtonTypeDetailDisclosure 
								   frame:CGRectMake(270, 64, 40, 45)
							  titleColor:nil
								  target:self 
								selector:@selector(editRepeatCount:) 
						normalStateImage:nil 
					  selectedStateImage:nil];
	
	
	groupButton=[[UIView alloc] initWithFrame:CGRectMake(15, 10+64, 300, 80)];
	groupButton.backgroundColor=[UIColor clearColor];

	//deadlines buttons
	noneButton=[ivoUtility createButton:NSLocalizedString(@"noneText", @"")/*noneText*/
						   buttonType:UIButtonTypeRoundedRect 
								frame:CGRectMake(0, 64, 75, 25)
						   titleColor:nil 
							   target:self 
							 selector:@selector(deadlineChanged:) 
					 normalStateImage:@"no-mash-white.png"
				   selectedStateImage:@"no-mash-blue.png"];
	[noneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[groupButton addSubview:noneButton];
	//[noneButton release];
	
	oneWeekButton=[ivoUtility createButton:NSLocalizedString(@"oneWeekText", @"")/*oneWeekText*/
							  buttonType:UIButtonTypeRoundedRect 
								   frame:CGRectMake(95, 64, 75, 25)
							  titleColor:nil 
								  target:self 
								selector:@selector(deadlineChanged:) 
						normalStateImage:@"no-mash-white.png" 
					  selectedStateImage:@"no-mash-blue.png"];
	[oneWeekButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[groupButton addSubview:oneWeekButton];
	//[oneWeekButton release];

	oneMonthButton=[ivoUtility createButton:NSLocalizedString(@"oneMonthText", @"")/*oneMonthText*/
							   buttonType:UIButtonTypeRoundedRect 
									frame:CGRectMake(190, 64, 75, 25)
							   titleColor:nil 
								   target:self 
								 selector:@selector(deadlineChanged:) 
						 normalStateImage:@"no-mash-white.png" 
					   selectedStateImage:@"no-mash-blue.png"];
	
	[oneMonthButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[groupButton addSubview:oneMonthButton];
	//[oneMonthButton release];

	//deadlines buttons
	todayButton=[ivoUtility createButton:NSLocalizedString(@"todayText", @"")/*todayText*/
							 buttonType:UIButtonTypeRoundedRect 
								  frame:CGRectMake(0, 40+64, 75, 25)
							 titleColor:nil 
								 target:self 
							   selector:@selector(deadlineChanged:) 
					   normalStateImage:@"no-mash-white.png"
					 selectedStateImage:@"no-mash-blue.png"];
	[todayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[groupButton addSubview:todayButton];
	//[todayButton release];
	
	tomorrowButton=[ivoUtility createButton:NSLocalizedString(@"tomorrowText", @"")/*tomorrowText*/
								buttonType:UIButtonTypeRoundedRect 
									 frame:CGRectMake(95, 40+64, 75, 25)
								titleColor:nil 
									target:self 
								  selector:@selector(deadlineChanged:) 
						  normalStateImage:@"no-mash-white.png" 
						selectedStateImage:@"no-mash-blue.png"];
	[tomorrowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[groupButton addSubview:tomorrowButton];
	//[oneWeekButton release];
	
	twoWeeksButton=[ivoUtility createButton:NSLocalizedString(@"twoWeeksText", @"")/*twoWeeksText*/
								 buttonType:UIButtonTypeRoundedRect 
									  frame:CGRectMake(190, 40+64, 75, 25)
								 titleColor:nil 
									 target:self 
								   selector:@selector(deadlineChanged:) 
						   normalStateImage:@"no-mash-white.png" 
						 selectedStateImage:@"no-mash-blue.png"];
	
	[twoWeeksButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[groupButton addSubview:twoWeeksButton];
	
	
	//[twoWeeksButton release];
	
	
	//[tableView release];
	//ILOG(@"TimeSettingViewController loadView]\n");
}


-(void)refreshFrames{
    CGRect frame=[[UIScreen mainScreen] bounds];
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
        mainView.frame=CGRectMake(0, 0, frame.size.height, frame.size.width);
        
    }else{
        mainView.frame=CGRectMake(0, 0, frame.size.width, frame.size.height);
        
    }
}

/*
 If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad {
}
 */

-(BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
	//[pool release];
}


- (void)dealloc {
	
	[datePicker removeFromSuperview];
    [datePicker release];
	
	[saveButton release];
	
	[mainView release];
	
	[cellContent0 removeFromSuperview];
	[cellContent0 release];
	
	[cellContent1 removeFromSuperview];
	[cellContent1 release];

	[cellContent3 removeFromSuperview];
	[cellContent2 release];

	[cellContent3 removeFromSuperview];
	[cellContent3 release];
	
	[cellContent0Val release];
	[cellContent1Val release];
	[cellContent2Val release];
	[cellContent3Val release];
	
	//[alertView release];
	
	[editRepeatCountButton release];
	
	[tableView removeFromSuperview];
	tableView.delegate=nil;
	tableView.dataSource=nil;
	[tableView release];
	
	[groupButton release];
	[repeatOptions release];
	
//Trung 08101002
/*
	[infoEditView release];
	[generalListView release];
*/	
	[editedObject release];
	
	[super dealloc];
}

#pragma mark controller delegate
- (void)viewWillAppear:(BOOL)animated {
	//ILOG(@"[TimeSettingViewController viewWillAppear\n");
	
	CGRect frame;
	switch (self.keyEdit) {
		case SETTING_DESKTIME:
			self.cellContent0Val=[self.editedObject deskTimeStart];
			self.cellContent1Val=[self.editedObject deskTimeEnd];
			self.cellContent2Val=[self.editedObject deskTimeWEStart];
			self.cellContent3Val=[self.editedObject deskTimeWEEnd];
			
			datePicker.datePickerMode=UIDatePickerModeTime;
			frame=tableView.frame; 
			frame.origin.y=64;
			frame.size.height=200;
			tableView.frame=frame;
			break;
		case SETTING_HOMETIME:
			self.cellContent0Val=[self.editedObject homeTimeNDStart];
			self.cellContent1Val=[self.editedObject homeTimeNDEnd];
			self.cellContent2Val=[self.editedObject homeTimeWEStart];
			self.cellContent3Val=[self.editedObject homeTimeWEEnd];
			
			datePicker.datePickerMode=UIDatePickerModeTime;
			frame=tableView.frame; 
			frame.origin.y=64;
			frame.size.height=200;
			tableView.frame=frame;			
			break;
			
			///
		case TASK_EDITTIMERTASK:
			//self.isUseDeadLine=[self.editedObject taskIsUseDeadLine];
			//self.cellContent3Val=[self.editedObject taskDeadLine];
						
			datePicker.datePickerMode=UIDatePickerModeDateAndTime;
			datePicker.date=self.cellContent0Val;
			
			frame=tableView.frame; 
			frame.origin.y=64;
			frame.size.height=100;

			tableView.frame=frame;
			break;
			
		case TASK_EDITTIMEREVENT:
			
			//settting default values			
//			self.cellContent0Val=[self.editedObject taskStartTime];
//			self.cellContent1Val=[self.editedObject taskEndTime];
//			self.cellContent2IntVal=[self.editedObject taskRepeatID];
//			self.cellContent3IntVal=[self.editedObject taskRepeatTimes];
//			self.currentDuration=[self.editedObject taskHowLong];
			datePicker.date=self.cellContent0Val;
			
			if([editedObject isAllDayEvent]){
				datePicker.datePickerMode=UIDatePickerModeDate;
			}else {
				datePicker.datePickerMode=UIDatePickerModeDateAndTime;
			}

			
			frame=tableView.frame; 
			if(self.cellContent2IntVal !=0){
				frame.origin.y=64;
				frame.size.height=200;
			}else {
				frame.origin.y=30+64;
				frame.size.height=150;
			}

			tableView.frame=frame;			
			break;
			
	}

//	[self showDatePicker];
	
	[self refreshTitleBarName];
	
	[tableView reloadData];
	[self setEditing:YES animated:YES];
	//ILOG(@"TimeSettingViewController viewWillAppear]\n");
}

- (void)viewWillDisappear:(BOOL)animated {
	if (self.pathIndex>=0){
		[tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:self.pathIndex inSection:0] animated:NO];
	}
	
	self.pathIndex=-1;	
}
-(void)showDatePicker{
	// Position the date picker below the bottom of the screen.
	datePicker.hidden=NO;
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	CGSize pickerSize = [datePicker sizeThatFits:CGSizeZero];
	CGFloat screenBottom =  screenRect.size.height - screenRect.origin.y-20;
	CGRect startRect = CGRectMake(0, screenBottom, pickerSize.width, pickerSize.height);
	datePicker.frame = startRect;
	// Calculate the position to which the picker will be animated.
	CGRect pickerRect = CGRectMake(0, screenBottom - pickerSize.height, pickerSize.width, pickerSize.height);
	// Configure the animation.
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	datePicker.frame = pickerRect;
	[UIView commitAnimations];	
}

- (void)viewDidAppear:(BOOL)animated {
	//ILOG(@"[TimeSettingViewController viewDidAppear\n");
	//select the first cell when loaded as default
	if(self.keyEdit == TASK_EDITTIMERTASK){
		//[tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:NO scrollPosition:UITableViewScrollPositionNone];
		//[self tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
		self.pathIndex=-1;
		return;
	}else{
		datePicker.date=self.cellContent0Val;
		[tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
		[self tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	}

	self.pathIndex=0;
	//ILOG(@"TimeSettingViewController viewDidAppear]\n");
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    //[tableView reloadData];
}

#pragma mark action methods

- (IBAction)save:(id)sender{
	//ILOG(@"[TimeSettingViewController save\n");
	if(self.isOrderDateError){
		//alertView = [[UIAlertView alloc] initWithTitle:@"Please choose an End-date that occurs after the Start-date" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"startTimeIsLaterEndTimeText", @"")/*startTimeIsLaterEndTimeText*/ message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/ otherButtonTitles:nil];
		
		[alertView show];
		[alertView release];
		return;
	}
	
	switch (self.keyEdit) {
		case SETTING_DESKTIME:
			[self.editedObject setDeskTimeStart:self.cellContent0Val];
			[self.editedObject setDeskTimeEnd:self.cellContent1Val];
			[self.editedObject setDeskTimeWEStart:self.cellContent2Val];
			[self.editedObject setDeskTimeWEEnd:self.cellContent3Val];
			break;
		case SETTING_HOMETIME:
			[self.editedObject setHomeTimeNDStart:self.cellContent0Val];
			[self.editedObject setHomeTimeNDEnd:self.cellContent1Val];
			[self.editedObject setHomeTimeWEStart:self.cellContent2Val];
			[self.editedObject setHomeTimeWEEnd:self.cellContent3Val];
			break;
		case TASK_EDITTIMERTASK:
			[self.editedObject setTaskNotEalierThan:self.cellContent0Val];
			[self.editedObject setTaskDeadLine:self.cellContent1Val];
			[self.editedObject setTaskDueStartDate:self.cellContent2Val];
			//[self.editedObject setTaskDueEndDate:self.cellContent3Val];
			[self.editedObject setTaskIsUseDeadLine:self.isUseDeadLine];
			if(self.isUseDeadLine==1){
				[self.editedObject setTaskDueEndDate:self.cellContent1Val];	
			}
			break;
		case TASK_EDITTIMEREVENT:
		{
			Task *tmp=[taskmanager getParentRE:editedObject inList:taskmanager.taskList];
			if(tmp && tmp.primaryKey==[editedObject primaryKey]){
				tmp=nil;	
			}
			
			[self.editedObject setTaskStartTime:self.cellContent0Val];
			[self.editedObject setTaskEndTime:self.cellContent1Val];
			[self.editedObject setTaskHowLong:(NSInteger)[[self.editedObject taskEndTime] timeIntervalSinceDate:[self.editedObject taskStartTime]]+1];
			[self.editedObject setTaskRepeatID:self.cellContent2IntVal];

			if(self.cellContent3IntVal !=0){
				//repeatCountTime ret=[ivoUtility createRepeatCountFromEndDate:tmp.taskEndTime?tmp.taskEndTime:[NSDate date] 
				//												  typeRepeat:self.cellContent2IntVal 
				//													  toDate:self.cellContent3Val 
				//											repeatOptionsStr:repeatOptions];
				
				repeatCountTime ret=[ivoUtility createRepeatCountFromEndDate:tmp.taskREStartTime ? tmp.taskREStartTime : self.cellContent0Val
																  typeRepeat:self.cellContent2IntVal 
																	  toDate:self.cellContent3Val 
															repeatOptionsStr:repeatOptions
																 reStartDate:tmp.taskREStartTime ? tmp.taskREStartTime : self.cellContent0Val];
				
				[self.editedObject setTaskNumberInstances:ret.numberOfInstances];
			}else {
				[self.editedObject setTaskNumberInstances:0];
			}
			
			[self.editedObject setTaskRepeatTimes:self.cellContent3IntVal];
			
//			[self.editedObject setTaskRepeatTimes:self.cellContent3IntVal];
//			[self.editedObject setTaskNumberInstances:ret.numberOfInstances];

			[self.editedObject setTaskEndRepeatDate:self.cellContent3Val];
			[self.editedObject setTaskRepeatOptions:self.repeatOptions];
		}
			break;			
	}
	
	[self.navigationController popViewControllerAnimated:YES];
	//ILOG(@"TimeSettingViewController save]\n");
}

- (void)timeChanged:(id)sender{
	//ILOG(@"[TimeSettingViewController timeChanged\n");
	switch (self.keyEdit) {
		case SETTING_DESKTIME:
			switch ([[tableView indexPathForSelectedRow] row]) {
				case 0:
					self.cellContent0Val=datePicker.date;
					NSString *timeStr=[ivoUtility createTimeStringFromDate:self.cellContent0Val];
					self.cellContent0.text=timeStr;
					[timeStr release];
					break;
				case 1:
					self.cellContent1Val=datePicker.date;
					NSString *timeStr1=[ivoUtility createTimeStringFromDate:self.cellContent1Val];
					self.cellContent1.text=timeStr1;
					[timeStr1 release];
					break;
				case 2:
					self.cellContent2Val=datePicker.date;
					NSString *timeStr2=[ivoUtility createTimeStringFromDate:self.cellContent2Val];
					self.cellContent2.text=timeStr2;
					[timeStr2 release];
					break;
				case 3:
					self.cellContent3Val=datePicker.date;
					NSString *timeStr3=[ivoUtility createTimeStringFromDate:self.cellContent3Val];
					self.cellContent3.text=timeStr3;
					[timeStr3 release];
					break;					
			}
			
			break;
		case SETTING_HOMETIME:
			switch ([[tableView indexPathForSelectedRow] row]) {
				case 0:
					self.cellContent0Val=datePicker.date;
					NSString *timeStr=[ivoUtility createTimeStringFromDate:self.cellContent0Val];
					self.cellContent0.text=timeStr;
					[timeStr release];
					break;
				case 1:
					self.cellContent1Val=datePicker.date;
					NSString *timeStr1=[ivoUtility createTimeStringFromDate:self.cellContent1Val];
					self.cellContent1.text=timeStr1;
					[timeStr1 release];
					break;
				case 2:
					self.cellContent2Val=datePicker.date;
					NSString *timeStr2=[ivoUtility createTimeStringFromDate:self.cellContent2Val];
					self.cellContent2.text=timeStr2;
					[timeStr2 release];
					break;
				case 3:
					self.cellContent3Val=datePicker.date;
					NSString *timeStr3=[ivoUtility createTimeStringFromDate:self.cellContent3Val];
					self.cellContent3.text=timeStr3;
					[timeStr3 release];
					break;
			}
			break;
			
		case TASK_EDITTIMERTASK:
			/*
			switch ([[tableView indexPathForSelectedRow] row]) {
				
				case 0:
					self.cellContent0Val=datePicker.date;
					NSString *dateStr=[ivoUtility createStringFromDate:self.cellContent0Val isIncludedTime:YES];
					self.cellContent0.text=dateStr;
					[dateStr release];
					break;
				case 1:
					self.cellContent1Val=datePicker.date;
					NSString *dateStr1=[ivoUtility createStringFromDate:self.cellContent1Val isIncludedTime:YES];
					self.cellContent1.text=dateStr1;
					[dateStr1 release];
					break;
			}
			 */
		{
			switch ([[tableView indexPathForSelectedRow] row]) {
				case 0:
				{
					self.cellContent0Val=datePicker.date;
					//self.cellContent2Val=datePicker.date;
					NSString *dateStr=[ivoUtility createStringFromDate:self.cellContent0Val isIncludedTime:YES];
					self.cellContent0.text=dateStr;
					[dateStr release];
				}
					break;
				case 1:
				{
					[self performSelector:@selector(deadlineChanged:) withObject:nil];
					self.isUseDeadLine=1;
					self.cellContent1Val=datePicker.date;
					NSString *dateStr=[ivoUtility createStringFromDate:self.cellContent1Val isIncludedTime:YES];
					self.cellContent1.text=dateStr;
					[dateStr release];
				}
					break;
			}
		}	
			break;
		case TASK_EDITTIMEREVENT:
		{
			Task *tmp=[taskmanager getParentRE:editedObject inList:taskmanager.taskList];
			if(tmp && tmp.primaryKey==[editedObject primaryKey]){
				tmp=nil;	
			}
			
			switch ([[tableView indexPathForSelectedRow] row]) {
				case 0:
				{
					self.cellContent0Val=datePicker.date;
					NSString *dateStr=[ivoUtility createStringFromDate:self.cellContent0Val isIncludedTime:YES];
					self.cellContent0.text=dateStr;
					[dateStr release];
					self.cellContent1Val=[self.cellContent0Val dateByAddingTimeInterval:self.currentDuration];
					dateStr=[ivoUtility createStringFromDate:self.cellContent1Val isIncludedTime:YES];
					self.cellContent1.text=dateStr;
					[dateStr release];
					
					if([editedObject primaryKey]>=-1 && [editedObject taskRepeatID]>0){ 
						NSDate *newEndRepeatDate=[ivoUtility createEndRepeatDateFromCount:tmp.taskEndTime?tmp.taskEndTime:self.cellContent1Val typeRepeat:self.cellContent2IntVal 
																		  repeatCount:self.cellContent3IntVal==0?1:self.cellContent3IntVal 
																		  repeatOptionsStr:repeatOptions];
						self.cellContent3Val=newEndRepeatDate;
						[newEndRepeatDate release];
					}
					
					if(self.cellContent3IntVal !=0){
						NSString *endRepeatDate=[ivoUtility createStringFromDate:self.cellContent3Val isIncludedTime:NO ];
						self.cellContent3.text=endRepeatDate;//[NSString stringWithFormat:@"%d",self.cellContent3IntVal];
						[endRepeatDate release];
					}
				}	
					break;
				case 1:
				{
					self.cellContent1Val=datePicker.date;
					self.currentDuration=[self.cellContent1Val timeIntervalSinceDate:self.cellContent0Val];
					NSString *dateStr1=[ivoUtility createStringFromDate:self.cellContent1Val isIncludedTime:YES];
					self.cellContent1.text=dateStr1;
					[dateStr1 release];
					
					if([editedObject primaryKey]>=-1 && [editedObject taskRepeatID]>0){ 
						NSDate *newEndRepeatDate=[ivoUtility createEndRepeatDateFromCount:tmp.taskEndTime?tmp.taskEndTime:self.cellContent1Val typeRepeat:self.cellContent2IntVal 
																			  repeatCount:self.cellContent3IntVal==0?1:self.cellContent3IntVal 
																		 repeatOptionsStr:repeatOptions];
						self.cellContent3Val=newEndRepeatDate;
						[newEndRepeatDate release];
					}
					
					if(self.cellContent3IntVal !=0){
						NSString *endRepeatDate=[ivoUtility createStringFromDate:self.cellContent3Val isIncludedTime:NO ];
						self.cellContent3.text=endRepeatDate;//[NSString stringWithFormat:@"%d",self.cellContent3IntVal];
						[endRepeatDate release];
					}
				}
					break; 
				case 3:
				{
					self.cellContent3Val=datePicker.date;

					NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
					unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
					NSDateComponents *comps = [gregorian components:unitFlags fromDate:self.cellContent3Val];
					
					[comps setHour:[ivoUtility getHour:self.cellContent1Val]];
					[comps setMinute:[ivoUtility getMinute:self.cellContent1Val]];
					[comps setSecond:[ivoUtility getSecond:self.cellContent1Val]];
					
					self.cellContent3Val=[gregorian dateFromComponents:comps];
					
					NSString *endRepeatDate=[ivoUtility createStringFromDate:self.cellContent3Val isIncludedTime:NO ];
					self.cellContent3.text=endRepeatDate;//[NSString stringWithFormat:@"%d",self.cellContent3IntVal];
					[endRepeatDate release];
					
					repeatCountTime ret=[ivoUtility createRepeatCountFromEndDate:tmp.taskEndTime?tmp.taskEndTime:[NSDate date] 
																	  typeRepeat:self.cellContent2IntVal 
																		  toDate:self.cellContent3Val 
																repeatOptionsStr:repeatOptions
																	 reStartDate:tmp.taskEndTime?tmp.taskEndTime:[NSDate date]];
					self.cellContent3IntVal=ret.repeatTimes;
					//self.numberOfInstances=ret.numberOfInstances;
					
					[gregorian release];
				}
			}
			
			break;
		}
			
			break;
	}
	
	if(self.keyEdit !=TASK_EDITTIMERTASK || (self.keyEdit ==TASK_EDITTIMERTASK && self.isUseDeadLine==1)){
		self.isOrderDateError=[self checkOrderDateError:[[tableView indexPathForSelectedRow] row]];
	}
	//ILOG(@"TimeSettingViewController timeChanged]\n");
}


-(void)editRepeatCount:(id)sender{
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	InfoEditViewController *infoEditView=[[InfoEditViewController alloc] init];
	
	infoEditView.keyEdit=TIMER_EDITREPEATTIMES;
	infoEditView.editedObject=self;
	[infoEditView setEditing:YES animated:YES];

	App_Delegate.me.networkActivityIndicatorVisible=NO;
	[self.navigationController pushViewController:infoEditView animated:YES];
	
	[infoEditView release];
}

-(void)deadlineChanged:(id)sender{
	if([sender isEqual:noneButton]){
		self.isUseDeadLine=0;
		NSDate *deadlineDate=[[NSDate date] dateByAddingTimeInterval:93312000];
		self.cellContent1Val=deadlineDate;
		self.cellContent3Val=deadlineDate;
		self.cellContent1.text=NSLocalizedString(@"noneText", @"")/*noneText*/;
		noneButton.selected=YES;
	}else {
		noneButton.selected=NO;
	}

	
	if([sender isEqual:oneWeekButton]){
		self.isUseDeadLine=1;
		NSDate *deadlineDate=[ivoUtility createDeadLine:DEADLINE_1_WEEK fromDate:[NSDate date] context:[self.editedObject taskWhere]];
		self.cellContent1Val=deadlineDate;
		self.cellContent3Val=deadlineDate;
		NSString *deadLineDateStr=[ivoUtility createStringFromDate:deadlineDate isIncludedTime:YES];
		self.cellContent1.text=deadLineDateStr;
		[deadLineDateStr release];
		[deadlineDate release];
		datePicker.date=self.cellContent1Val;
		oneWeekButton.selected=YES;
	}else {
		oneWeekButton.selected=NO;
	}

	
	if([sender isEqual:oneMonthButton]){
		self.isUseDeadLine=1;
		NSDate *deadlineDate=[ivoUtility createDeadLine:DEADLINE_1_MONTH fromDate:[NSDate date] context:[self.editedObject taskWhere]];
		self.cellContent1Val=deadlineDate;
		self.cellContent3Val=deadlineDate;
		NSString *deadLineDateStr=[ivoUtility createStringFromDate:deadlineDate isIncludedTime:YES];
		self.cellContent1.text=deadLineDateStr;
		[deadLineDateStr release];
		[deadlineDate release];
		datePicker.date=self.cellContent1Val;
		oneMonthButton.selected=YES;
	}else {
		oneMonthButton.selected=NO;
	}

	
	if([sender isEqual:todayButton]){
		self.isUseDeadLine=1;
		NSDate *deadLineDate=[ivoUtility createDeadLine:DEADLINE_TODAY fromDate:[NSDate date] context:[self.editedObject taskWhere]];
		NSString *deadLineDateStr=[ivoUtility createStringFromDate:deadLineDate isIncludedTime:YES];
		self.cellContent1Val=deadLineDate;
		self.cellContent3Val=deadLineDate;
		self.cellContent1.text=deadLineDateStr;
		[deadLineDateStr release];
		[deadLineDate release];
		datePicker.date=self.cellContent1Val;
		todayButton.selected=YES;
	}else {
		todayButton.selected=NO;
	}

	
	if([sender isEqual:tomorrowButton]){
		self.isUseDeadLine=1;
		NSDate *deadLineDate=[ivoUtility createDeadLine:DEADLINE_TOMORROW fromDate:[NSDate date] context:[self.editedObject taskWhere]];
		NSString *deadLineDateStr=[ivoUtility createStringFromDate:deadLineDate isIncludedTime:YES];
		self.cellContent1Val=deadLineDate;
		self.cellContent3Val=deadLineDate;
		self.cellContent1.text=deadLineDateStr;
		[deadLineDateStr release];
		[deadLineDate release];
		datePicker.date=self.cellContent1Val;
		tomorrowButton.selected=YES;
	}else {
		tomorrowButton.selected=NO;
	}

	
	if([sender isEqual:twoWeeksButton]){
		self.isUseDeadLine=1;
		NSDate *deadLineDate=[ivoUtility createDeadLine:DEADLINE_2_WEEKS fromDate:[NSDate date] context:[self.editedObject taskWhere]];
		NSString *deadLineDateStr=[ivoUtility createStringFromDate:deadLineDate isIncludedTime:YES];
		self.cellContent1Val=deadLineDate;
		self.cellContent3Val=deadLineDate;
		self.cellContent1.text=deadLineDateStr;
		[deadLineDateStr release];
		[deadLineDate release];
		datePicker.date=self.cellContent1Val;
		twoWeeksButton.selected=YES;
	}else {
		twoWeeksButton.selected=NO;
	}
	
	self.isOrderDateError=[self checkOrderDateError:[[tableView indexPathForSelectedRow] row]];
}


#pragma mark common Methods
-(BOOL)checkOrderDateError:(NSInteger)row{
	//ILOG(@"[TimeSettingViewController checkOrderDateError\n");

	BOOL ret=NO;

	//general error checking
		if([self.cellContent0Val compare:self.cellContent1Val]!=NSOrderedAscending){
			if(row==0){
				self.cellContent1.textColor=[UIColor redColor];
			}else if(row==1){
				self.cellContent0.textColor=[UIColor redColor];
			}
			ret= YES;
		}else {
			self.cellContent1.textColor=[Colors darkSteelBlue];
			self.cellContent0.textColor=[Colors darkSteelBlue];
		}
		
	if([tableView numberOfRowsInSection:0]>2){
		if(self.cellContent2Val && self.cellContent3Val && [self.cellContent2Val compare:self.cellContent3Val]==NSOrderedDescending){
			if(row==2){
				self.cellContent3.textColor=[UIColor redColor];
			}else if(row==3){
				self.cellContent2.textColor=[UIColor redColor];
			}

			ret= YES;
		}else {
			self.cellContent3.textColor=[Colors darkSteelBlue];
			self.cellContent2.textColor=[Colors darkSteelBlue];
		}
	}

	//ILOG(@"TimeSettingViewController checkOrderDateError]\n");
	return ret;
}

-(void)refreshTitleBarName{
	//ILOG(@"[TimeSettingViewController refreshTitleBarName\n");
	switch (self.keyEdit) {
		case SETTING_DESKTIME:
			self.navigationItem.title =NSLocalizedString(@"worktimeViewTitleText", @"")/*worktimeViewTitleText*/;
			break;
		case SETTING_HOMETIME:
			self.navigationItem.title =NSLocalizedString(@"hometimeViewTitleText", @"")/*hometimeViewTitleText*/;
			break;
		case TASK_EDITTIMERTASK:
			self.navigationItem.title =NSLocalizedString(@"horizonsText", @"")/*horizonsText*/;
			break;
			
		case TASK_EDITTIMEREVENT:
			self.navigationItem.title =NSLocalizedString(@"eventtimeViewTitleText", @"")/*eventtimeViewTitleText*/;
			break;
	}
	//ILOG(@"TimeSettingViewController refreshTitleBarName]\n");
}


#pragma mark -
#pragma mark <UITableViewDelegate, UITableViewDataSource> Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
    switch (self.keyEdit) {
		case TASK_EDITTIMERTASK:
			return 2;
			break;
	}
    return 1;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
	
    // Only one row for each section
	switch (self.keyEdit) {
		case SETTING_DESKTIME:
			return 4;
			break;
		case SETTING_HOMETIME:
			return 4;
			break;
		case TASK_EDITTIMERTASK:
			switch (section) {
				case 0:
					return 2;
					break;
				case 1:
					return 1;
					break;
			}
			break;
		case TASK_EDITTIMEREVENT:
			if([editedObject primaryKey]>0 && [editedObject parentRepeatInstance]>-1){
				return 2;
			}else if(self.cellContent2IntVal != 0){
				return 4;
			}else {
				return 3;
			}


			break;			
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//ILOG(@"[TimeSettingViewController cellForRowAtIndexPath\n");

	TableCellTimer *cell = (TableCellTimer *)[tableView dequeueReusableCellWithIdentifier:@"MyIdentifiertm"];
	if (cell == nil) {
		cell = [[[TableCellTimer alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifiertm"] autorelease];
	}
	
	if(self.keyEdit==TASK_EDITTIMEREVENT){
		if(indexPath.row==2){
			cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
		}else {
			cell.accessoryType= UITableViewCellAccessoryNone;
		}
	}else {
		cell.accessoryType= UITableViewCellAccessoryNone;
	}
	
	switch (self.keyEdit) {
		case SETTING_DESKTIME:
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = NSLocalizedString(@"weekdayStartCellText", @"")/*weekdayStartCellText*/;
					if (self.cellContent0 ==nil)
					{
						self.cellContent0=[[UILabel alloc] initWithFrame:CGRectMake(120, 0, 170, 43)];
					}else {
						CGRect frame=CGRectMake(120, 0, 170, 43);
						self.cellContent0.frame=frame;
					}
					self.cellContent0.highlightedTextColor=[UIColor whiteColor];
					
					NSString *timeStr=[ivoUtility createTimeStringFromDate:[self.editedObject deskTimeStart]];
					self.cellContent0.text=timeStr;
					[timeStr release];
					self.cellContent0.textAlignment=NSTextAlignmentRight;
					self.cellContent0.textColor=[Colors darkSteelBlue];
					//[cell.contentView addSubview:self.cellContent0];
					//cell.accessoryView=self.cellContent0;
					if([self.cellContent0 superview]){
						[self.cellContent0 removeFromSuperview];
					}
					cell.cellValue=self.cellContent0;
					cell.button=nil;
					break;
				case 1:
					cell.textLabel.text = NSLocalizedString(@"weekdayEndCellText", @"")/*weekdayEndCellText*/;
					if (self.cellContent1 ==nil)
					{
						self.cellContent1=[[UILabel alloc] initWithFrame:CGRectMake(120, 0, 170, 43)];
					}else {
						CGRect frame=CGRectMake(120, 0, 170, 43);
						self.cellContent1.frame=frame;
					}
					self.cellContent1.highlightedTextColor=[UIColor whiteColor];
					
					NSString *timeStr1=[ivoUtility createTimeStringFromDate:[self.editedObject deskTimeEnd]];
					self.cellContent1.text=timeStr1;
					[timeStr1 release];
					self.cellContent1.textAlignment=NSTextAlignmentRight;
					self.cellContent1.textColor=[Colors darkSteelBlue];
					self.cellContent1.backgroundColor=[UIColor clearColor];
					//[cell.contentView addSubview:self.cellContent1];
					//cell.accessoryView=self.cellContent1;
					
					if([self.cellContent1 superview]){
						[self.cellContent1 removeFromSuperview];
					}
					cell.cellValue=self.cellContent1;
					cell.button=nil;
					break;
				case 2:
					cell.textLabel.text = NSLocalizedString(@"weekendStartCellText", @"")/*weekendStartCellText*/;
					cell.textLabel.textColor=[Colors brown];
					if (self.cellContent2 ==nil)
					{
						self.cellContent2=[[UILabel alloc] initWithFrame:CGRectMake(120, 0,170, 43)];
					}else {
						CGRect frame=CGRectMake(120, 0, 170, 43);
						self.cellContent2.frame=frame;					
					}
					self.cellContent2.highlightedTextColor=[UIColor whiteColor];

					NSString *timeStr2=[ivoUtility createTimeStringFromDate:[self.editedObject deskTimeWEStart]];
					self.cellContent2.text=timeStr2;
					[timeStr2 release];
					self.cellContent2.textAlignment=NSTextAlignmentRight;
					self.cellContent2.textColor=[Colors darkSteelBlue];
					//[cell.contentView addSubview:self.cellContent2];
					if([self.cellContent2 superview]){
						[self.cellContent2 removeFromSuperview];
					}
					cell.cellValue=self.cellContent2;
					cell.button=nil;
					break;
				case 3:
					cell.textLabel.text = NSLocalizedString(@"weekendEndCellText", @"")/*weekendEndCellText*/;
					cell.textLabel.textColor=[Colors brown];
					if (self.cellContent3 ==nil)
					{
						self.cellContent3=[[UILabel alloc] initWithFrame:CGRectMake(120, 0, 170, 43)];
					}else {
						CGRect frame=CGRectMake(120, 0, 170, 43);
						self.cellContent3.frame=frame;
					}
					self.cellContent3.highlightedTextColor=[UIColor whiteColor];

					NSString *timeStr3=[ivoUtility createTimeStringFromDate:[self.editedObject deskTimeWEEnd]];
					self.cellContent3.text=timeStr3;
					[timeStr3 release];
					self.cellContent3.textAlignment=NSTextAlignmentRight;
					self.cellContent3.textColor=[Colors darkSteelBlue];
					
					if([self.cellContent3 superview]){
						[self.cellContent3 removeFromSuperview];
					}
					cell.cellValue=self.cellContent3;
					cell.button=nil;
					
					break;
			}			
			break;
		case SETTING_HOMETIME:
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = NSLocalizedString(@"weekdayStartCellText", @"")/*weekdayStartCellText*/;
					if (self.cellContent0 ==nil)
					{
						self.cellContent0=[[UILabel alloc] initWithFrame:CGRectMake(120, 0, 170, 43)];
					}else {
						CGRect frame=CGRectMake(120, 0, 170, 43);
						self.cellContent0.frame=frame;
					}
					self.cellContent0.highlightedTextColor=[UIColor whiteColor];

					NSString *timeStr=[ivoUtility createTimeStringFromDate:[self.editedObject homeTimeNDStart]];
					self.cellContent0.text=timeStr;
					[timeStr release];
					self.cellContent0.textAlignment=NSTextAlignmentRight;
					self.cellContent0.textColor=[Colors darkSteelBlue];
					//[cell.contentView addSubview:self.cellContent0];
					if([self.cellContent0 superview]){
						[self.cellContent0 removeFromSuperview];
					}
					cell.cellValue=self.cellContent0;
					cell.button=nil;
					break;
				case 1:
					cell.textLabel.text = NSLocalizedString(@"weekdayEndCellText", @"")/*weekdayEndCellText*/;
					if (self.cellContent1 ==nil)
					{
						self.cellContent1=[[UILabel alloc] initWithFrame:CGRectMake(120, 0, 170, 43)];
					}else {
						CGRect frame=CGRectMake(120, 0, 170, 43);
						self.cellContent1.frame=frame;
					}
					self.cellContent1.highlightedTextColor=[UIColor whiteColor];

					NSString *timeStr1=[ivoUtility createTimeStringFromDate:[self.editedObject homeTimeNDEnd]];
					self.cellContent1.text=timeStr1;
					[timeStr1 release];
					self.cellContent1.textAlignment=NSTextAlignmentRight;
					self.cellContent1.textColor=[Colors darkSteelBlue];
					//[cell.contentView addSubview:self.cellContent1];
					if([self.cellContent1 superview]){
						[self.cellContent1 removeFromSuperview];
					}
					cell.cellValue=self.cellContent1;
					cell.button=nil;
					
					break;
				case 2:
					cell.textLabel.text = NSLocalizedString(@"weekendStartCellText", @"")/*weekendStartCellText*/;
					cell.textLabel.textColor=[Colors brown];
					if (self.cellContent2 ==nil)
					{
						self.cellContent2=[[UILabel alloc] initWithFrame:CGRectMake(120, 0, 170, 43)];
					}else {
						CGRect frame=CGRectMake(120, 0, 170, 43);
						self.cellContent2.frame=frame;					
					}
					self.cellContent2.highlightedTextColor=[UIColor whiteColor];

					NSString *timeStr2=[ivoUtility createTimeStringFromDate:[self.editedObject homeTimeWEStart]];
					self.cellContent2.text=timeStr2;
					[timeStr2 release];
					self.cellContent2.textAlignment=NSTextAlignmentRight;
					self.cellContent2.textColor=[Colors darkSteelBlue];
					//[cell.contentView addSubview:self.cellContent2];
					if([self.cellContent2 superview]){
						[self.cellContent2 removeFromSuperview];
					}
					cell.cellValue=self.cellContent2;
					cell.button=nil;
					break;
				case 3:
					cell.textLabel.text = NSLocalizedString(@"weekendEndCellText", @"")/*weekendEndCellText*/;
					cell.textLabel.textColor=[Colors brown];
					if (self.cellContent3 ==nil)
					{
						self.cellContent3=[[UILabel alloc] initWithFrame:CGRectMake(120, 0, 170, 43)];
					}else {
						CGRect frame=CGRectMake(120, 0, 170, 43);
						self.cellContent3.frame=frame;
					}
					self.cellContent3.highlightedTextColor=[UIColor whiteColor];

					NSString *dateStr=[ivoUtility createTimeStringFromDate:[self.editedObject homeTimeWEEnd]];
					self.cellContent3.text=dateStr;
					[dateStr release];
					self.cellContent3.textAlignment=NSTextAlignmentRight;
					self.cellContent3.textColor=[Colors darkSteelBlue];
					//[cell.contentView addSubview:self.cellContent3];
					
					if([self.cellContent3 superview]){
						[self.cellContent3 removeFromSuperview];
					}
					cell.cellValue=self.cellContent3;
					cell.button=nil;
					break;
			}			
			break;
		case TASK_EDITTIMERTASK:
			switch (indexPath.section) {
				case 0:
					//cell.selectionStyle=UITableViewCellSelectionStyleNone;
					switch (indexPath.row) {
						case 0:
							/*
							cell.text = todayText;
							cell.font=[UIFont systemFontOfSize:16];
							*/
						{
							cell.textLabel.text=NSLocalizedString(@"dueStartText", @"")/*dueStartText*/;
							cell.textLabel.font=[UIFont systemFontOfSize:16];
							if (self.cellContent0 ==nil)
							{
								self.cellContent0=[[UILabel alloc] initWithFrame:CGRectMake(90, 0, 209, 42)];
							}else {
								CGRect frame=CGRectMake(90, 0, 209, 42);
								self.cellContent0.frame=frame;
							}
							self.cellContent0.highlightedTextColor=[UIColor whiteColor];
							
							self.cellContent0.font=[UIFont systemFontOfSize:16];
							self.cellContent0.textColor=[Colors darkSteelBlue];
							self.cellContent0.textAlignment=NSTextAlignmentRight;
							
							NSString *deadLineDateStr=[ivoUtility createStringFromDate:self.cellContent0Val isIncludedTime:YES];
							self.cellContent0.text=deadLineDateStr;
							[deadLineDateStr release];
							
							//[cell.contentView addSubview:self.cellContent3];
							if([self.cellContent0 superview]){
								[self.cellContent0 removeFromSuperview];
							}
							cell.cellValue=self.cellContent0;
							cell.button=nil;
						}
							break;
						case 1:
							/*
							cell.text =tomorrowText;
							cell.font=[UIFont systemFontOfSize:16];
							 */
						{
							cell.textLabel.text=NSLocalizedString(@"deadlineText", @"")/*deadlineText*/;
							if (self.cellContent1 ==nil)
							{
								self.cellContent1=[[UILabel alloc] initWithFrame:CGRectMake(90, 0, 209, 42)];
							}else {
								CGRect frame=CGRectMake(90, 0, 209, 42);
								self.cellContent1.frame=frame;
							}
							self.cellContent1.highlightedTextColor=[UIColor whiteColor];
							
							self.cellContent1.font=[UIFont systemFontOfSize:16];
							self.cellContent1.textColor=[Colors darkSteelBlue];
							self.cellContent1.textAlignment=NSTextAlignmentRight;
							
							if(self.isUseDeadLine){
								NSString *deadLineDateStr=[ivoUtility createStringFromDate:self.cellContent1Val isIncludedTime:YES];
								self.cellContent1.text=deadLineDateStr;
								[deadLineDateStr release];
							}else {
								self.cellContent1.text=NSLocalizedString(@"noneText", @"")/*noneText*/;
							}

							//[cell.contentView addSubview:self.cellContent3];
							if([self.cellContent1 superview]){
								[self.cellContent1 removeFromSuperview];
							}
							cell.cellValue=self.cellContent1;
							cell.button=nil;
							cell.textLabel.font=[UIFont systemFontOfSize:16];
						}	
							break;
							
						//case 2:
						//	cell.text=twoWeeksText;
						//	cell.font=[UIFont systemFontOfSize:16];
						//	break;
						//	 
					}			
					break;
				case 1:
					cell.selectionStyle=UITableViewCellSelectionStyleNone;
					
					if([groupButton superview])
						[groupButton removeFromSuperview];
					[cell.contentView addSubview:groupButton];
					/*	
					cell.text=specifiedText;
					if (self.cellContent3 ==nil)
					{
						self.cellContent3=[[UILabel alloc] initWithFrame:CGRectMake(90, 0, 209, 42)];
					}else {
						CGRect frame=CGRectMake(90, 0, 209, 42);
						self.cellContent3.frame=frame;
					}
					self.cellContent3.highlightedTextColor=[UIColor whiteColor];
					
					self.cellContent3.font=[UIFont systemFontOfSize:16];
					self.cellContent3.textColor=[Colors darkSteelBlue];
					self.cellContent3.textAlignment=NSTextAlignmentRight;
					
					NSString *deadLineDateStr=[ivoUtility createStringFromDate:self.cellContent3Val isIncludedTime:YES];
					self.cellContent3.text=deadLineDateStr;
					[deadLineDateStr release];
					
					//[cell.contentView addSubview:self.cellContent3];
					if([self.cellContent3 superview]){
						[self.cellContent3 removeFromSuperview];
					}
					cell.cellValue=self.cellContent3;
					cell.button=nil;
					cell.font=[UIFont systemFontOfSize:16];
					 */
					break;
			}

			break;
		case TASK_EDITTIMEREVENT:
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = NSLocalizedString(@"startsText", @"")/*startsText*/;
					if (self.cellContent0 ==nil)
					{
						self.cellContent0=[[UILabel alloc] initWithFrame:CGRectMake(70, 0, 230, 43)];
					}else {
						CGRect frame=CGRectMake(70, 0, 230, 43);
						self.cellContent0.frame=frame;
					}
					self.cellContent0.highlightedTextColor=[UIColor whiteColor];

					NSString *dateStr=[ivoUtility createStringFromDate:self.cellContent0Val isIncludedTime:YES];
					self.cellContent0.text=dateStr;
					[dateStr release];
					self.cellContent0.textAlignment=NSTextAlignmentRight;
					self.cellContent0.textColor=[Colors darkSteelBlue];
					//[cell.contentView addSubview:self.cellContent0];
					
					if([self.cellContent0 superview]){
						[self.cellContent0 removeFromSuperview];
					}
					cell.cellValue=self.cellContent0;
					cell.button=nil;
					break;
				case 1:
					cell.textLabel.text = NSLocalizedString(@"endsText", @"")/*endsText*/;
					if (self.cellContent1 ==nil)
					{
						self.cellContent1=[[UILabel alloc] initWithFrame:CGRectMake(70, 0, 230, 43)];
					}else {
						CGRect frame=CGRectMake(70, 0, 230, 43);
						self.cellContent1.frame=frame;
					}
					self.cellContent1.highlightedTextColor=[UIColor whiteColor];

					NSString *dateStr1=[ivoUtility createStringFromDate:self.cellContent1Val isIncludedTime:YES];
					self.cellContent1.text=dateStr1;
					[dateStr1 release];
					
					self.cellContent1.textAlignment=NSTextAlignmentRight;
					self.cellContent1.textColor=[Colors darkSteelBlue];
					//[cell.contentView addSubview:self.cellContent1];
					
					if([self.cellContent1 superview]){
						[self.cellContent1 removeFromSuperview];
					}
					cell.cellValue=self.cellContent1;
					cell.button=nil;
					
					break;
				case 2:
					cell.textLabel.text = NSLocalizedString(@"repeatText", @"")/*repeatText*/;
					cell.textLabel.textColor=[Colors brown];
					if (self.cellContent2 ==nil)
					{
						self.cellContent2=[[UILabel alloc] initWithFrame:CGRectMake(130, 0, 155, 43)];
					}else {
						CGRect frame=CGRectMake(130, 0, 155, 43);
						self.cellContent2.frame=frame;
					}
					self.cellContent2.highlightedTextColor=[UIColor whiteColor];
					self.cellContent2.text=[repeatList objectAtIndex:self.cellContent2IntVal];
					self.cellContent2.textAlignment=NSTextAlignmentRight;
					self.cellContent2.textColor=[Colors darkSteelBlue];
					
					if([self.cellContent2 superview]){
						[self.cellContent2 removeFromSuperview];
					}
					cell.cellValue=self.cellContent2;
					cell.button=nil;
					
					if([tableView numberOfRowsInSection:0]==3){
						if([self.cellContent3 superview]){
							[self.cellContent3 removeFromSuperview];
						}
					}
					break;
				case 3:
					//if(self.cellContent2IntVal != 0){
						cell.textLabel.text = NSLocalizedString(@"untilText", @"")/*untilText*/;
						cell.textLabel.textColor=[Colors brown];
						if (self.cellContent3 ==nil)
						{
							self.cellContent3=[[UILabel alloc] initWithFrame:CGRectMake(120, 0, 175, 43)];
						}else {
							CGRect frame=CGRectMake(120, 0, 175, 43);
							self.cellContent3.frame=frame;
						}
						self.cellContent3.highlightedTextColor=[UIColor whiteColor];
						
						if([ivoUtility getYear:self.cellContent3Val]==1970 || self.cellContent3IntVal==0){
							self.cellContent3.text=NSLocalizedString(@"foreverText", @"")/*foreverText*/;	
						}else {
							NSString *endRepeatDate=[ivoUtility createStringFromDate:self.cellContent3Val isIncludedTime:NO ];
							self.cellContent3.text=endRepeatDate;//[NSString stringWithFormat:@"%d",self.cellContent3IntVal];
							[endRepeatDate release];
						}
						
						self.cellContent3.textAlignment=NSTextAlignmentRight;
						self.cellContent3.textColor=[Colors darkSteelBlue];
						
						if([self.cellContent3 superview]){
							[self.cellContent3 removeFromSuperview];
						}
						cell.cellValue=self.cellContent3;
						
						//if([editRepeatCountButton superview]){
						//	[editRepeatCountButton removeFromSuperview];
						//}
						
						cell.button=editRepeatCountButton;
					//}else {
					//	cell.text = allDayText;

					//}

					break;

			}			
			break;
			
	}
	
	//ILOG(@"TimeSettingViewController cellForRowAtIndexPath]\n");

	return cell;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
	
}

- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section {
    // Return the displayed title for the specified section.	
	return @"";
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Never allow selection.
    if (self.editing) {
		saveButton.enabled=YES;
		return indexPath;
	}
   return indexPath;
}

/*- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	if(self.keyEdit==TASK_EDITTIMEREVENT){
		if(indexPath.row==2){
			return 	UITableViewCellAccessoryDisclosureIndicator;
		}
	}else if(self.keyEdit==TASK_EDITTIMERTASK) {
		if(self.pathIndex>=0){
			NSIndexPath *selectedPath = [NSIndexPath indexPathForRow:self.pathIndex inSection:0];	
			if ([selectedPath compare:indexPath] == NSOrderedSame ) {
				//return UITableViewCellAccessoryCheckmark;
			}
		}
	}

	return UITableViewCellAccessoryNone;
}
*/
- (CGFloat)tableView:(UITableView *)table heightForRowAtIndexPath:(NSIndexPath *)indexPath{
		if(self.keyEdit==TASK_EDITTIMERTASK && indexPath.section==1 ){
			return 85;
		}
	
	return 43;
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	//ILOG(@"[TimeSettingViewController didSelectRowAtIndexPath\n");
	//App_Delegate.me.networkActivityIndicatorVisible=YES;
	datePicker.minimumDate=nil;
	switch (self.keyEdit) {
		case SETTING_DESKTIME:
//			self.pathIndex=newIndexPath.row;
			switch (newIndexPath.row) {
				case 0:
					datePicker.date=self.cellContent0Val;//[self.editedObject deskTimeStart];
					break;
				case 1:
					datePicker.date=self.cellContent1Val;
					break;
				case 2:
					datePicker.date=self.cellContent2Val;
					break;
				case 3:
					datePicker.date=self.cellContent3Val;
					break;					
			}
			break;
		case SETTING_HOMETIME:
//			self.pathIndex=newIndexPath.row;
			switch (newIndexPath.row) {
				case 0:
					datePicker.date=self.cellContent0Val;
					break;
				case 1:
					datePicker.date=self.cellContent1Val;
					break;
				case 2:
					datePicker.date=self.cellContent2Val;
					break;
				case 3:
					datePicker.date=self.cellContent3Val;
					break;
			}
			break;
		case TASK_EDITTIMERTASK:
		{
			switch (newIndexPath.section) {
				case 1:
				{
					NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:self.pathIndex inSection:0];
					if(![oldIndexPath isEqual:newIndexPath]||self.pathIndex==-1){
						//[[table cellForRowAtIndexPath:oldIndexPath] setAccessoryType:UITableViewCellAccessoryNone];
						//[[table cellForRowAtIndexPath:newIndexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
						self.pathIndex=newIndexPath.row;
						/*	
						switch (newIndexPath.row) {
							case 0:
							{
								//datePicker.hidden=YES;
								NSDate *deadLineDate=[ivoUtility createDeadLine:DEADLINE_TODAY fromDate:[NSDate date] context:[self.editedObject taskWhere]];
								NSString *deadLineDateStr=[ivoUtility createStringFromDate:deadLineDate isIncludedTime:YES];
								self.cellContent3Val=deadLineDate;
								self.cellContent3.text=deadLineDateStr;
								[deadLineDateStr release];
								[deadLineDate release];
							}
								break;
							case 1:
							{
								//datePicker.hidden=YES;
								NSDate *deadLineDate=[ivoUtility createDeadLine:DEADLINE_TOMORROW fromDate:[NSDate date] context:[self.editedObject taskWhere]];
								NSString *deadLineDateStr=[ivoUtility createStringFromDate:deadLineDate isIncludedTime:YES];
								self.cellContent3Val=deadLineDate;
								self.cellContent3.text=deadLineDateStr;
								[deadLineDateStr release];
								[deadLineDate release];
							}
								break;				
							case 2:
							{
								//datePicker.hidden=YES;
								NSDate *deadLineDate=[ivoUtility createDeadLine:DEADLINE_2_WEEKS fromDate:[NSDate date] context:[self.editedObject taskWhere]];
								NSString *deadLineDateStr=[ivoUtility createStringFromDate:deadLineDate isIncludedTime:YES];
								self.cellContent3Val=deadLineDate;
								self.cellContent3.text=deadLineDateStr;
								[deadLineDateStr release];
								[deadLineDate release];
							}
								break;
						}
						 */
					}
					//[table deselectRowAtIndexPath:newIndexPath animated:YES];
				}
					break;
				case 0:
				{
					switch (newIndexPath.row) {
						case 0:
						{
							NSString *dateStr=[ivoUtility createStringFromDate:self.cellContent0Val isIncludedTime:YES];
							self.cellContent0.text=dateStr;
							[dateStr release];
							datePicker.date=self.cellContent0Val;
							//isConfigDeadline=NO;
							//[tableView reloadData];
							CGRect frame=tableView.frame; 
							frame.origin.y=10;
							frame.size.height=100;
							
							tableView.frame=frame;
							
						}
							break;
						case 1:
						{
							
							if(self.isUseDeadLine){
								NSString *dateStr=[ivoUtility createStringFromDate:self.cellContent1Val isIncludedTime:YES];
								self.cellContent1.text=dateStr;
								[dateStr release];
								
								datePicker.date=self.cellContent1Val;
							}else {
								noneButton.selected=YES;
							}

							
							//isConfigDeadline=YES;
							//[tableView reloadData];
							CGRect frame=tableView.frame; 
							frame.origin.y=10;
							frame.size.height=200;
							
							tableView.frame=frame;
							
						}
							
							break;
					}
				}
					break;
			}
			//datePicker.date=self.cellContent3Val;
		}
			break;
		case TASK_EDITTIMEREVENT:
			datePicker.datePickerMode=UIDatePickerModeDateAndTime;
		{	
			Task *tmp=[taskmanager getParentRE:editedObject inList:taskmanager.taskList];
			
			self.pathIndex=newIndexPath.row;
			switch (newIndexPath.row) {
				case 0:
					datePicker.date=self.cellContent0Val;//[self.editedObject deskTimeStart];
					break;
				case 1:
					datePicker.date=self.cellContent1Val;
					break;					
				case 2:
				{
					GeneralListViewController *generalListView=[[GeneralListViewController alloc] init];
					
					generalListView.keyEdit=TIMER_EDITREPEATID;
					//generalListView.editedObject=self.editedObject;
					generalListView.editedObject=self;
					generalListView.pathIndex=self.cellContent2IntVal;
					[generalListView setEditing:YES animated:YES];
					[self.navigationController pushViewController:generalListView animated:YES];
					[generalListView release];
					
				}
					break;
				case 3:
				{
					datePicker.datePickerMode=UIDatePickerModeDate;
					datePicker.minimumDate=(tmp!=nil)?[tmp.taskREStartTime dateByAddingTimeInterval:tmp.taskHowLong]:[NSDate date];
					
					if(self.cellContent3Val==nil){
						datePicker.date=(tmp!=nil)?[tmp.taskREStartTime dateByAddingTimeInterval:tmp.taskHowLong]:[NSDate date];
						self.cellContent3Val=datePicker.date;
					}else {
						datePicker.date=self.cellContent3Val;
					}

					
					if(self.cellContent3IntVal==0)
						self.cellContent3IntVal=1;
					NSString *endRepeatDate=[ivoUtility createStringFromDate:self.cellContent3Val isIncludedTime:NO ];
					self.cellContent3.text=endRepeatDate;//[NSString stringWithFormat:@"%d",self.cellContent3IntVal];
					[endRepeatDate release];
					
					
				}
					break;
			}
		}
			break;
	}

	if(self.keyEdit !=TASK_EDITTIMERTASK || ( self.keyEdit ==TASK_EDITTIMERTASK && self.isUseDeadLine==1)){
		//reset color if error order date
		if(self.isOrderDateError=[self checkOrderDateError:newIndexPath.row]) return;
	}
	
	//App_Delegate.me.networkActivityIndicatorVisible=NO;
	
	//ILOG(@"TimeSettingViewController didSelectRowAtIndexPath]\n");

}

#pragma mark properties

- (NSDate*)cellContent0Val{
	return cellContent0Val;	
}

- (void)setCellContent0Val:(NSDate*)aDate{
	[cellContent0Val release];
	cellContent0Val=[aDate copy];
}

- (NSDate*)cellContent1Val{
	return cellContent1Val;	
}

- (void)setCellContent1Val:(NSDate*)aDate{
	[cellContent1Val release];
	cellContent1Val=[aDate copy];
}

- (NSDate*)cellContent2Val{
	return cellContent2Val;	
}

- (void)setCellContent2Val:(NSDate*)aDate{
	[cellContent2Val release];
	cellContent2Val=[aDate copy];
}

- (NSDate*)cellContent3Val{
	return cellContent3Val;	
}

- (void)setCellContent3Val:(NSDate*)aDate{
	[cellContent3Val release];
	cellContent3Val=[aDate copy];
}

-(NSInteger)pathIndex{
	return pathIndex;	
}

-(void)setPathIndex:(NSInteger)pathIdx{
	pathIndex=pathIdx;	
}

-(NSString *)repeatOptions{
	return repeatOptions;
}

-(void)setRepeatOptions:(NSString *)str{
	[repeatOptions release];
	repeatOptions=[str copy];
}

/*
//numberOfInstances
-(NSInteger)numberOfInstances{
	return numberOfInstances;	
}

-(void)setNumberOfInstances:(NSInteger)aNum{
	numberOfInstances=aNum;	
}
*/

@end
