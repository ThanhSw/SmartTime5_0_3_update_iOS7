//
//  GeneralListViewController.m
//  iVo
//
//  Created by Nang Le on 7/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GeneralListViewController.h"
#import "SmartTimeAppDelegate.h"
#import "Setting.h"
#import "IvoCommon.h"
#import "TimeSettingViewController.h"
#import "Colors.h"
#import "TaskManager.h"

//extern Setting			*currentSetting;
extern NSMutableArray	*repeatList;
extern NSMutableArray	*contextList;
extern NSMutableArray	*iVoStyleList;
extern NSMutableArray	*deadlineExpandList;
extern ivo_Utilities	*ivoUtility;
extern TaskManager		*taskmanager;
extern NSMutableArray	*syncTypeList;
extern SmartTimeAppDelegate *App_Delegate;
extern NSString *repeatFromDueDateText;
extern NSString *repeatFromCompletionDateText;

@implementation GeneralListViewController
@synthesize editedObject;
@synthesize pathIndex;
@synthesize keyEdit;

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

	//ILOG(@"[GeneralListViewController loadView\n");
	
    CGRect frame=[[UIScreen mainScreen] bounds];
    
	saveButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
															  target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = saveButton;
	self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
			
	contentView= [[UIView alloc] initWithFrame:CGRectZero];
	contentView.backgroundColor=[UIColor groupTableViewBackgroundColor];
	
	tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 65, 320, frame.size.height-65) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
	
	UIButton *doneButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	doneButton.frame = CGRectMake(250, 165, 60, 30);
	doneButton.alpha=1;
	[doneButton setTitle:NSLocalizedString(@"doneButtonText", @"")/*doneButtonText*/ forState:UIControlStateNormal];
	doneButton.titleLabel.font=[UIFont systemFontOfSize:14];
	[doneButton setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];		
	[doneButton setBackgroundImage:[UIImage imageNamed:@"blue-small.png"] forState:UIControlStateNormal];

	[doneButton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
	
	UIView *doneBarView=[[UIView alloc] initWithFrame:CGRectMake(0, 160, 320, 40)];
	doneBarView.backgroundColor=[UIColor viewFlipsideBackgroundColor];
	doneBarView.alpha=0.3;
	
	//[doneBarView addSubview:doneButton];
	//[doneButton release];
	
	[contentView addSubview:doneBarView];
	[doneBarView release];
	
	[contentView addSubview:doneButton];
	[doneButton release];
	
	[contentView addSubview:tableView];
    self.view = contentView;
	
	//for weekly options
	repeatOptionWeeklyView=[[UIView alloc] initWithFrame:CGRectMake(0, 35, 300, 100)];
	
	UILabel	*repeatOnLB=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 20)];
	repeatOnLB.text=NSLocalizedString(@"repeatOnText", @"")/*repeatOnText*/;
	repeatOnLB.font=[UIFont boldSystemFontOfSize:16];
 	[repeatOptionWeeklyView addSubview: repeatOnLB];
	[repeatOnLB release];
	
	sunButton=[ivoUtility createButton:NSLocalizedString(@"sunOptText", @"")/*sunOptText*/ buttonType:UIButtonTypeCustom 
										   frame:CGRectMake(10, 25, 70, 40) 
									  titleColor:[UIColor blackColor] 
										  target:self 
										selector:@selector(checkTapped:) 
								normalStateImage:@"Check-Off.png" 
							  selectedStateImage:@"Check-On.png"];
	sunButton.titleLabel.font=[UIFont boldSystemFontOfSize:16];
	[repeatOptionWeeklyView addSubview:sunButton];
	[sunButton release];

	monButton=[ivoUtility createButton:NSLocalizedString(@"monOptText", @"")/*monOptText*/ buttonType:UIButtonTypeCustom 
										   frame:CGRectMake(80, 25, 70, 40) 
									  titleColor:[UIColor blackColor] 
										  target:self 
										selector:@selector(checkTapped:) 
								normalStateImage:@"Check-Off.png" 
							  selectedStateImage:@"Check-On.png"];
	monButton.titleLabel.font=[UIFont boldSystemFontOfSize:16];
	[repeatOptionWeeklyView addSubview:monButton];
	[monButton release];
	
	tueButton=[ivoUtility createButton:NSLocalizedString(@"tueOptText", @"")/*tueOptText*/ buttonType:UIButtonTypeCustom 
										   frame:CGRectMake(150, 25, 70, 40) 
									  titleColor:[UIColor blackColor] 
										  target:self 
										selector:@selector(checkTapped:) 
								normalStateImage:@"Check-Off.png" 
							  selectedStateImage:@"Check-On.png"];
	tueButton.titleLabel.font=[UIFont boldSystemFontOfSize:16];
	[repeatOptionWeeklyView addSubview:tueButton];
	[tueButton release];
	
	wedButton=[ivoUtility createButton:NSLocalizedString(@"wedOptText", @"")/*wedOptText*/ buttonType:UIButtonTypeCustom 
										   frame:CGRectMake(220, 25, 70, 40) 
									  titleColor:[UIColor blackColor] 
										  target:self 
										selector:@selector(checkTapped:) 
								normalStateImage:@"Check-Off.png" 
							  selectedStateImage:@"Check-On.png"];
	wedButton.titleLabel.font=[UIFont boldSystemFontOfSize:16];
	[repeatOptionWeeklyView addSubview:wedButton];
	[wedButton release];
	
	thuButton=[ivoUtility createButton:NSLocalizedString(@"thuOptText", @"")/*thuOptText*/ buttonType:UIButtonTypeCustom 
										   frame:CGRectMake(10, 65, 70, 40) 
									  titleColor:[UIColor blackColor] 
										  target:self 
										selector:@selector(checkTapped:) 
								normalStateImage:@"Check-Off.png" 
							  selectedStateImage:@"Check-On.png"];
	thuButton.titleLabel.font=[UIFont boldSystemFontOfSize:16];
	
	[repeatOptionWeeklyView addSubview:thuButton];
	[thuButton release];
	
	friButton=[ivoUtility createButton:NSLocalizedString(@"friOptText", @"")/*friOptText*/ buttonType:UIButtonTypeCustom 
										   frame:CGRectMake(80, 65, 70, 40) 
									  titleColor:[UIColor blackColor] 
										  target:self 
										selector:@selector(checkTapped:) 
								normalStateImage:@"Check-Off.png" 
							  selectedStateImage:@"Check-On.png"];
	friButton.titleLabel.font=[UIFont boldSystemFontOfSize:16];
	[repeatOptionWeeklyView addSubview:friButton];
	[friButton release];
	
	satButton=[ivoUtility createButton:NSLocalizedString(@"satOptText", @"")/*satOptText*/ buttonType:UIButtonTypeCustom 
										   frame:CGRectMake(150, 65, 70, 40) 
									  titleColor:[UIColor blackColor] 
										  target:self 
										selector:@selector(checkTapped:) 
								normalStateImage:@"Check-Off.png" 
							  selectedStateImage:@"Check-On.png"];
	satButton.titleLabel.font=[UIFont boldSystemFontOfSize:16];
	[repeatOptionWeeklyView addSubview:satButton];
	[satButton release];
	
	
	//for Monthly options
	repeatOptionMonthlyView=[[UIView alloc] initWithFrame:CGRectMake(0, 35, 300, 100)];
	UILabel	*repeatByLB=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 20)];
	repeatByLB.text=NSLocalizedString(@"repeatByText", @"");
	repeatByLB.font=[UIFont boldSystemFontOfSize:16];
	[repeatOptionMonthlyView addSubview:repeatByLB];
	[repeatByLB release];
	
	dayNumberButton=[ivoUtility createButton:NSLocalizedString(@"dayOfMonthText", @"")/*dayOfMonthText*/ buttonType:UIButtonTypeCustom 
										   frame:CGRectMake(0, 30, 300, 30) 
									  titleColor:[UIColor blackColor] 
										  target:self 
										selector:@selector(toggleMonthPin:) 
								normalStateImage:@"Pin-Off.png" 
							  selectedStateImage:@"Pin-On.png"];
	dayNumberButton.titleLabel.font=[UIFont systemFontOfSize:16];
	[dayNumberButton setTitleColor:[Colors darkSteelBlue] forState :UIControlStateSelected];
	[repeatOptionMonthlyView addSubview:dayNumberButton];
	[dayNumberButton release];
	
	dayWeekButton=[ivoUtility createButton:NSLocalizedString(@"dayOfWeekText", @"")/*dayOfWeekText*/ buttonType:UIButtonTypeCustom 
												 frame:CGRectMake(0, 70, 300, 30) 
											titleColor:[UIColor blackColor] 
												target:self 
											  selector:@selector(toggleMonthPin:) 
									  normalStateImage:@"Pin-Off.png" 
									selectedStateImage:@"Pin-On.png"];
	dayWeekButton.titleLabel.font=[UIFont systemFontOfSize:16];
	[dayWeekButton setTitleColor:[Colors darkSteelBlue] forState :UIControlStateSelected];
	[repeatOptionMonthlyView addSubview:dayWeekButton];
	[dayWeekButton release];
	
	//for default options
	repeatEveryLB=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 110, 20)];
	repeatEveryLB.text=NSLocalizedString(@"repeatEveryText", @"")/*repeatEveryText*/;
	repeatEveryLB.font=[UIFont boldSystemFontOfSize:16];
	
	CGRect textFieldFrame = CGRectMake(130,7.5 ,80, 30);
	textField=[[UITextField alloc] initWithFrame:textFieldFrame];
	textField.borderStyle=UITextBorderStyleRoundedRect;
	textField.returnKeyType = UIReturnKeyDone;
	textField.keyboardType=UIKeyboardTypeNumberPad;
	textField.textAlignment=NSTextAlignmentCenter;
	textField.font=[UIFont systemFontOfSize:16];
	textField.clearButtonMode=UITextFieldViewModeWhileEditing;
	textField.delegate=self;
	
	
	repeatEveryUnitLB=[[UILabel alloc] initWithFrame:CGRectMake(220, 10, 70, 20)];
	repeatEveryUnitLB.text=@"";
	repeatEveryUnitLB.textAlignment=NSTextAlignmentCenter;
	
	syncTypeNotes=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 280, 150)];
	syncTypeNotes.numberOfLines=0;
	syncTypeNotes.backgroundColor=[UIColor clearColor];
	syncTypeNotes.textColor=[UIColor darkGrayColor];
	//syncTypeNotes
	
	//ILOG(@"GeneralListViewController loadView]\n");
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
	tableView.delegate=nil;
	tableView.dataSource=nil;
	[tableView release];

	[saveButton release];
	[repeatOptionWeeklyView release];
	[repeatOptionMonthlyView release];
	[editedObject release];
	
	[repeatEveryLB release];
	[textField release];
	[repeatEveryUnitLB release];
	[contentView release];
	[repeatOn release];
	[repeatOptions release];
	
	[syncTypeNotes release];
	
	/*
	[sunButton release];
	[monButton release];
	[tueButton release];
	[wedButton release];
	[thuButton release];
	[friButton release];
	[satButton release];
	
	[dayNumberButton release];
	[dayWeekButton release];
	 */
	
	[super dealloc];
}

#pragma mark controller delegate
- (void)viewWillAppear:(BOOL)animated {

	//ILOG(@"[GeneralListViewController viewWillAppear\n");
	
	//refresh title bar name
	[self refreshTitleBarName];
	currentIndex=self.pathIndex;

	switch (keyEdit) {
		case TIMER_EDITREPEATID:
			//repeatBy=0;
			self.repeatOptions= [editedObject repeatOptions];
			if(self.repeatOptions !=nil && ![self.repeatOptions isEqualToString:@""]){
				NSArray *options=[self.repeatOptions componentsSeparatedByString:@"/"];
				repeatEvery=[(NSString*)[options objectAtIndex:0] intValue];
				self.repeatOn=(NSString*)[options objectAtIndex:1];
				repeatBy=[(NSString*)[options objectAtIndex:2] intValue];
			}else {
				repeatEvery=1;
				repeatOn=@"";
				repeatBy=0;
			}
				
			if(repeatEvery<1){
				repeatEvery=1;
			}
			
			[self resetCheckboxes:self.repeatOn];
			
			if(repeatBy==0){
				dayNumberButton.selected=YES;
				dayWeekButton.selected=NO;
			}else {
				dayNumberButton.selected=NO;
				dayWeekButton.selected=YES;
			}
			
			textField.text=[NSString stringWithFormat:@"%d", repeatEvery];
			
			//set default for check list
			if(self.repeatOn ==nil || [self.repeatOn isEqualToString:@""]){
				NSInteger wd=[ivoUtility getWeekday:[editedObject cellContent0Val]];
				switch (wd) {
					case 1:
						sunButton.selected=YES;
						break;
					case 2:
						monButton.selected=YES;
						break;
					case 3:
						tueButton.selected=YES;
						break;
					case 4:
						wedButton.selected=YES;
						break;
					case 5:
						thuButton.selected=YES;
						break;
					case 6:
						friButton.selected=YES;
						break;
					case 7:
						satButton.selected=YES;
						break;
				}
			}
			break;
        case TASK_EDIT_REPEAT:
        {
            self.repeatOptions= [editedObject taskRepeatOptions];
			if(self.repeatOptions !=nil && ![self.repeatOptions isEqualToString:@""]){
				NSArray *options=[self.repeatOptions componentsSeparatedByString:@"/"];
				repeatEvery=[(NSString*)[options objectAtIndex:0] intValue];
				self.repeatOn=(NSString*)[options objectAtIndex:1];
				repeatBy=[(NSString*)[options objectAtIndex:2] intValue];
			}else {
				repeatEvery=1;
				repeatOn=@"";
				repeatBy=0;
			}
            
			if(repeatEvery<1){
				repeatEvery=1;
			}
			
			[self resetCheckboxes:self.repeatOn];
			
			if(repeatBy==0){
				dayNumberButton.selected=YES;
				dayWeekButton.selected=NO;
			}else {
				dayNumberButton.selected=NO;
				dayWeekButton.selected=YES;
			}
			
			textField.text=[NSString stringWithFormat:@"%d", repeatEvery];
			
			//set default for check list
			if(self.repeatOn ==nil || [self.repeatOn isEqualToString:@""]){
				NSInteger wd=[ivoUtility getWeekday:[editedObject taskStartTime]];
				switch (wd) {
					case 1:
						sunButton.selected=YES;
						break;
					case 2:
						monButton.selected=YES;
						break;
					case 3:
						tueButton.selected=YES;
						break;
					case 4:
						wedButton.selected=YES;
						break;
					case 5:
						thuButton.selected=YES;
						break;
					case 6:
						friButton.selected=YES;
						break;
					case 7:
						satButton.selected=YES;
						break;
				}
            }
        }
		default:
			break;
	}
	//ILOG(@"GeneralListViewController viewWillAppear]\n");
}

-(void)viewDidAppear:(BOOL)animated{

}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    //[tableView reloadData];
}

#pragma mark action methods

-(void)toggleMonthPin:(id)sender{
	if([sender isEqual:dayNumberButton]){
		if(!dayNumberButton.selected){
			repeatBy=0;
			dayNumberButton.selected=YES;
			dayNumberButton.highlighted=YES;
			dayWeekButton.selected=NO;
			dayWeekButton.highlighted=NO;
		}
	}
	
	if([sender isEqual:dayWeekButton]){
		if(!dayWeekButton.selected){
			repeatBy=1;
			dayWeekButton.selected=YES;
			dayWeekButton.highlighted=YES;
			dayNumberButton.selected=NO;
			dayNumberButton.highlighted=NO;
		}
	}
	
}

-(void)cancel:(id)sender{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)done:(id)sender{
	[self popDownKeyboard];
}

-(void)checkTapped:(id)sender{
	[self toggleButtonState:sender normalStateTitleColor:[UIColor blackColor] selectStateTitleColor:[Colors darkSteelBlue]];
	[self getCheckedList];
}


-(void)save:(id)sender{
	//ILOG(@"[GeneralListViewController save\n");
	switch (self.keyEdit) {
		case SETTING_REPEATDEFID:
			[self.editedObject setRepeatDefID:self.pathIndex];
			break;
		case SETTING_CONTEXTDEFID:
			[self.editedObject setContextDefID:self.pathIndex];
			break;
		case SETTING_IVOSTYLEDEFID:
			[self.editedObject setIVoStyleID:self.pathIndex];
			break;
		case TASK_EDITCONTEXT:
			[self.editedObject setTaskWhere:self.pathIndex];
			break;
		case TIMER_EDITREPEATID:
		{
			[self.editedObject setCellContent2IntVal:self.pathIndex];
			[self getCheckedList];
			
			Task *tmp=[taskmanager getParentRE:[editedObject editedObject] inList:taskmanager.taskList];
			if(tmp && tmp.primaryKey==[[editedObject editedObject] primaryKey]){
				tmp=nil;	
			}
			
			if(self.pathIndex !=0){
				[self.editedObject setRepeatOptions:[NSString stringWithFormat:@"%d/%@/%d",[textField.text intValue],self.repeatOn?self.repeatOn:@"",repeatBy]];
			}else {
				[self.editedObject setRepeatOptions:@""];
			}
			
			//printf("\n%s",[[ivoUtility getStringFromShortDate:[self.editedObject cellContent3Val]] UTF8String]);
			if([self.editedObject cellContent3IntVal] !=0){
				repeatCountTime ret=[ivoUtility createRepeatCountFromEndDate:tmp.taskREStartTime ? tmp.taskREStartTime : [editedObject cellContent0Val] 
																  typeRepeat:self.pathIndex 
																	  toDate:[self.editedObject cellContent3Val]
															repeatOptionsStr:[self.editedObject repeatOptions]
																 reStartDate:tmp.taskREStartTime ? tmp.taskREStartTime : [editedObject cellContent0Val]];
				[self.editedObject setCellContent3IntVal:ret.repeatTimes];
			}else {//set default value for endRepeatDate
				NSDate *endRepeatDate=[ivoUtility createEndRepeatDateFromCount:tmp.taskEndTime ?  tmp.taskEndTime:[NSDate date]
																	typeRepeat:self.pathIndex 
																   repeatCount:1
																   repeatOptionsStr:[self.editedObject repeatOptions]];
				[self.editedObject setCellContent3Val:endRepeatDate];
				[endRepeatDate release];
			}
		}
			break;
        case TASK_EDIT_REPEAT:
        {
            [self.editedObject setTaskRepeatID:self.pathIndex];
			[self getCheckedList];
			
			//Task *tmp=[taskmanager getParentRE:[editedObject editedObject] inList:taskmanager.taskList];
			//if(tmp && tmp.primaryKey==[editedObject primaryKey]){
			//	tmp=nil;	
			//}
			
			if(self.pathIndex !=0){
				[self.editedObject setTaskRepeatOptions:[NSString stringWithFormat:@"%d/%@/%d",[textField.text intValue],self.repeatOn?self.repeatOn:@"",repeatBy]];
			}else {
				[self.editedObject setTaskRepeatOptions:@""];
			}
            
            break;
        }
		case SETTING_TASKMOVE:
			[self.editedObject setTaskMovingStyle:self.pathIndex];
			break;
		case SETTING_PASSDUEMOVE:
			[self.editedObject setDueWhenMove:self.pathIndex];
			break;
		case SETTING_SYNCTYPE:
			[self.editedObject setSyncType:self.pathIndex];
			//[settingView resetData];
			break;
		case SETTING_BADGE:
			[self.editedObject setBadgeType:self.pathIndex];
			break;
		case SETTING_WEEK_START_DAY:
			[self.editedObject setWeekStartDay:self.pathIndex];
			break;
			
	}
	
	[self.navigationController popViewControllerAnimated:YES];
	//ILOG(@"GeneralListViewController save]\n");
}

#pragma mark common Methods
-(void)toggleButtonState:(UIButton *)button 
   normalStateTitleColor:(UIColor *)normalStateTitleColor 
   selectStateTitleColor:(UIColor *)selectStateTitleColor{
	if(button.selected){
//		NSInteger wd=[ivoUtility getWeekday:[editedObject cellContent0Val]];
//		if((wd==1 && [button isEqual:sunButton])||(wd==2 && [button isEqual:monButton])
//			||(wd==3 && [button isEqual:tueButton]) ||(wd==4 && [button isEqual:wedButton])
//			||(wd==5 && [button isEqual:thuButton]) ||(wd==6 && [button isEqual:friButton])
//			||(wd==7 && [button isEqual:sunButton])) return;
		button.highlighted=NO;
		button.selected=NO;
		[button setTitleColor:normalStateTitleColor forState:UIControlStateNormal];
	}else {
		button.highlighted=YES;
		button.selected=YES;
		[button setTitleColor:selectStateTitleColor forState:UIControlStateNormal];
	}	
}

-(void)popDownKeyboard{
    CGRect frame=[[UIScreen mainScreen] bounds];
	tableView.frame=CGRectMake(0, 0, 320, frame.size.height-20);;
	tableView.scrollEnabled=YES;
	tableView.scrollsToTop=YES;
	[textField resignFirstResponder];
}

-(void)getCheckedList{

	NSString *tmp=[[NSString alloc] initWithString:@""];
	
	if(sunButton.selected){
		tmp=[tmp stringByAppendingFormat: @"|1"];
	}

	if(monButton.selected){
		tmp=[tmp stringByAppendingFormat: @"|2"];
	}
	
	if(tueButton.selected){
		tmp=[tmp stringByAppendingFormat: @"|3"];
	}

	if(wedButton.selected){
		tmp=[tmp stringByAppendingFormat: @"|4"];
	}

	if(thuButton.selected){
		tmp=[tmp stringByAppendingFormat: @"|5"];
	}

	if(friButton.selected){
		tmp=[tmp stringByAppendingFormat: @"|6"];
	}

	if(satButton.selected){
		tmp=[tmp stringByAppendingFormat: @"|7"];
	}
	
	
	if([tmp length]>1){
		NSString *tmp1=[tmp retain];
		self.repeatOn=[tmp1 substringFromIndex:1];
	}
	[tmp release];
}

-(void)resetCheckboxes:(NSString *)valueList{
	if(valueList !=nil && ![valueList isEqualToString:@""]){
		NSArray *selectDays=[valueList componentsSeparatedByString:@"|"];
		//clean first
		[self setAllCheckBoxesOff];
		
		//reset state
		for (NSInteger i=0; i<selectDays.count;i++){
			[self setCheckBoxOn:[(NSString *)[selectDays objectAtIndex:i] intValue]];
		}
	}else {
		[self setAllCheckBoxesOff];
	}
}

-(void)setAllCheckBoxesOff{
	sunButton.selected=NO;
	monButton.selected=NO;
	tueButton.selected=NO;
	wedButton.selected=NO;
	thuButton.selected=NO;
	friButton.selected=NO;
	satButton.selected=NO;
}

-(void)setCheckBoxOn:(NSInteger)value{
	switch (value) {
		case 1:
			sunButton.selected=YES;
			break;
		case 2:
			monButton.selected=YES;
			break;
		case 3:
			tueButton.selected=YES;
			break;
		case 4:
			wedButton.selected=YES;
			break;
		case 5:
			thuButton.selected=YES;
			break;
		case 6:
			friButton.selected=YES;
			break;
		case 7:
			satButton.selected=YES;
			break;
	}
	
}


-(void)refreshTitleBarName{
	//ILOG(@"[GeneralListViewController refreshTitleBarName\n");
	switch (self.keyEdit) {
		case SETTING_REPEATDEFID:
			self.navigationItem.title =NSLocalizedString(@"repeatTypeText", @"Repeat Types")/*repeatTypeText*/;//@"Repeat Types";
			break;
		case SETTING_CONTEXTDEFID:
			self.navigationItem.title =NSLocalizedString(@"contextsText", @"")/*contextsText*/;
			break;
		case SETTING_IVOSTYLEDEFID:
			self.navigationItem.title =NSLocalizedString(@"stylesText", @"")/*stylesText*/;
			break;
		case TASK_EDITCONTEXT:
			self.navigationItem.title =NSLocalizedString(@"contextsText", @"Contexts")/*contextsText*/;//@"Contexts";
			break;
		case TIMER_EDITREPEATID:
			self.navigationItem.title =NSLocalizedString(@"repeatTypeText", @"Repeat Types")/*repeatTypeText*/;//@"Repeat Types";
			break;
         case TASK_EDIT_REPEAT:
        {
            self.navigationItem.title =NSLocalizedString(@"repeatTypeText", @"Repeat Types");
        }
            break;
		case SETTING_TASKMOVE:
			self.navigationItem.title =@"Moving Style";//no use
			break;
		case SETTING_PASSDUEMOVE:
			self.navigationItem.title =@"Moving Style";//no use
			break;
		case SETTING_BADGE:
			self.navigationItem.title =NSLocalizedString(@"applicationBadgeText", @"")/*applicationBadgeText*/;
			break;
		case SETTING_WEEK_START_DAY:
			self.navigationItem.title =NSLocalizedString(@"weekStartDayText", @"")/*weekStartDayText*/;
			break;
	
			
	}
	//ILOG(@"GeneralListViewController refreshTitleBarName]\n");
}

#pragma mark -
#pragma mark <UITableViewDelegate, UITableViewDataSource> Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
    // 1 sections
	switch (self.keyEdit) {
		case TIMER_EDITREPEATID:
			if(currentIndex==REPEAT_DAILY || currentIndex==REPEAT_WEEKLY || currentIndex==REPEAT_MONTHLY||currentIndex==REPEAT_YEARLY)
			return 2;
			break;	
        case TASK_EDIT_REPEAT:
        {
			if(currentIndex==REPEAT_DAILY || currentIndex==REPEAT_WEEKLY || currentIndex==REPEAT_MONTHLY||currentIndex==REPEAT_YEARLY)
                //return 2;
                if([self.editedObject taskPinned]==1){
                    return 2;
                }else{
                    return 3;
                }
        }
            break;
		case SETTING_SYNCTYPE:
			return 2;
			break;
		case SETTING_WEEK_START_DAY:
			return 1;
			break;
			
	}
    return 1;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
    // Only one row for each section
	switch (self.keyEdit) {
		case SETTING_REPEATDEFID:
			return repeatList.count;
			break;
		case SETTING_CONTEXTDEFID:
			return contextList.count;
			break;
		case SETTING_IVOSTYLEDEFID:
			return iVoStyleList.count;
			break;
		case TASK_EDITCONTEXT:
			return contextList.count;
			break;
		case TIMER_EDITREPEATID:
			switch (section) {
				case 0:
					return repeatList.count;
					break;
				case 1:
					return 1;
					break;
                case 2:
                    if ([self.editedObject taskIsUseDeadLine]) {
                        return 2;
                    }
                    
                    return 1;
                    break;    
			}
			break;
        case TASK_EDIT_REPEAT:
        {
            switch (section) {
				case 0:
					return repeatList.count;
					break;
				case 1:
					return 1;
					break;
                case 2:
                    if ([self.editedObject taskIsUseDeadLine]) {
                        return 2;
                    }
                    
                    return 1;
                    break;    
			}
        }
            break;
		case SETTING_TASKMOVE:
			//return taskMovingStypeList.count;
			break;
		case SETTING_PASSDUEMOVE:
			return deadlineExpandList.count;
			break;
		case SETTING_SYNCTYPE:
			if(section==0){
				return syncTypeList.count;
			}else {
				return 1;
			}

			break;
		case SETTING_BADGE:
			return 3;
			break;
		case SETTING_WEEK_START_DAY:
			switch (section) {
				case 0:
					return 2;
					break;
				case 1:
					return 1;
					break;
			}
			break;
			
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//ILOG(@"[GeneralListViewController cellForRowAtIndexPath\n");
	
	NSIndexPath *selectedPath = [NSIndexPath indexPathForRow:self.pathIndex inSection:0];	
	
	switch (self.keyEdit) {
		case SETTING_REPEATDEFID:
		{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifierGL"];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifierGL"] autorelease];
			}
			
			if(self.pathIndex>=0 &&[selectedPath compare:indexPath] == NSOrderedSame ){
					cell.accessoryType= UITableViewCellAccessoryCheckmark;
			}else {
				cell.accessoryType= UITableViewCellAccessoryNone;
			}
			
			if(currentIndex==indexPath.row){
				cell.textLabel.textColor=[Colors darkSteelBlue];
			}else {
				cell.textLabel.textColor=[UIColor blackColor];
			}
			
			cell.textLabel.text = [repeatList objectAtIndex:indexPath.row];
			return cell;
		}
			break;
		case SETTING_CONTEXTDEFID:
		{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifierGL"];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifierGL"] autorelease];
			}
			
			if(self.pathIndex>=0 &&[selectedPath compare:indexPath] == NSOrderedSame ){
				cell.accessoryType= UITableViewCellAccessoryCheckmark;
			}else {
				cell.accessoryType= UITableViewCellAccessoryNone;
			}
			
			if(currentIndex==indexPath.row){
				cell.textLabel.textColor=[Colors darkSteelBlue];
			}else {
				cell.textLabel.textColor=[UIColor blackColor];
			}
			
			cell.textLabel.text = [contextList objectAtIndex:indexPath.row];
			return cell;
		}
			break;
		case SETTING_IVOSTYLEDEFID:
		{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifierGL"];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifierGL"] autorelease];
			}
			
			if(self.pathIndex>=0 &&[selectedPath compare:indexPath] == NSOrderedSame ){
				cell.accessoryType= UITableViewCellAccessoryCheckmark;
			}else {
				cell.accessoryType= UITableViewCellAccessoryNone;
			}
			
			if(currentIndex==indexPath.row){
				cell.textLabel.textColor=[Colors darkSteelBlue];
			}else {
				cell.textLabel.textColor=[UIColor blackColor];
			}

			cell.textLabel.text = [iVoStyleList objectAtIndex:indexPath.row];
			return cell;
		}
			break;
		case TASK_EDITCONTEXT:
		{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifierGL"];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifierGL"] autorelease];
			}
			
			if(self.pathIndex>=0 &&[selectedPath compare:indexPath] == NSOrderedSame ){
				cell.accessoryType= UITableViewCellAccessoryCheckmark;
			}else {
				cell.accessoryType= UITableViewCellAccessoryNone;
			}			
			
			if(currentIndex==indexPath.row){
				cell.textLabel.textColor=[Colors darkSteelBlue];
			}else {
				cell.textLabel.textColor=[UIColor blackColor];
			}

			cell.textLabel.text = [contextList objectAtIndex:indexPath.row];
			return cell;
		}
			break;
		case TIMER_EDITREPEATID:
			switch (indexPath.section) {
				case 0:
				{
					UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifierGL"];
					if (cell == nil) {
						cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifierGL"] autorelease];
					}
					
					if(self.pathIndex>=0 &&[selectedPath compare:indexPath] == NSOrderedSame ){
						cell.accessoryType= UITableViewCellAccessoryCheckmark;
					}else {
						cell.accessoryType= UITableViewCellAccessoryNone;
					}
					
					if(currentIndex==indexPath.row){
						cell.textLabel.textColor=[Colors darkSteelBlue];
					}else {
						cell.textLabel.textColor=[UIColor blackColor];
					}

					cell.textLabel.text = [repeatList objectAtIndex:indexPath.row];
					return cell;
				}
					break;
				case 1:
					switch (indexPath.row) {
						case 0:
						{
							UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifierGLOpt"];
							if (cell == nil) {
								cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifierGLOpt"] autorelease];
							}
							
							if(self.pathIndex>=0 &&[selectedPath compare:indexPath] == NSOrderedSame ){
								cell.accessoryType= UITableViewCellAccessoryCheckmark;
							}else {
								cell.accessoryType= UITableViewCellAccessoryNone;
							}
							
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							
							if(currentIndex==indexPath.row){
								cell.textLabel.textColor=[Colors darkSteelBlue];
							}else {
								cell.textLabel.textColor=[UIColor blackColor];
							}

							cell.textLabel.text=@"";
							if([repeatEveryLB superview])
								[repeatEveryLB removeFromSuperview];
							[cell.contentView addSubview:repeatEveryLB];
							
							switch (currentIndex) {
								case REPEAT_DAILY:
									repeatEveryUnitLB.text= NSLocalizedString(@"dayUnitText", @"");//@"day(s)";
									break;
								case REPEAT_WEEKLY:
									repeatEveryUnitLB.text=NSLocalizedString(@"weekUnitText", @"")/*weekUnitText*/;
									break;
								case REPEAT_MONTHLY:
									repeatEveryUnitLB.text=NSLocalizedString(@"monthUnitText", @"")/*monthUnitText*/;
									break;
								case REPEAT_YEARLY:
									repeatEveryUnitLB.text=NSLocalizedString(@"yearUnitText", @"")/*yearUnitText*/;
									break;
								default:
									repeatEveryUnitLB.text=@"";
									break;
							}
							
							if([textField superview])
								[textField removeFromSuperview];
							[cell.contentView addSubview:textField];
							
							if([repeatEveryUnitLB superview])
								[repeatEveryUnitLB removeFromSuperview];
							[cell.contentView addSubview:repeatEveryUnitLB];
							
							if([repeatOptionWeeklyView superview])
								[repeatOptionWeeklyView removeFromSuperview];
							
							if([repeatOptionMonthlyView superview])
								[repeatOptionMonthlyView removeFromSuperview];
							
							if(currentIndex==REPEAT_WEEKLY){
								[cell.contentView addSubview:repeatOptionWeeklyView];
							}else if(currentIndex==REPEAT_MONTHLY){
								[cell.contentView addSubview:repeatOptionMonthlyView];
							}
							return cell;

						}
							break;
					}
					break;
				case 2:
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"repeatStyle"];
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"repeatStyle"] autorelease];
                    }else{
                        
                    }
                    
                    cell.textLabel.text=@"";
                    
                    if ([self.editedObject taskRepeatID]==indexPath.row) {
                        cell.accessoryType=UITableViewCellAccessoryCheckmark;
                    }else{
                        cell.accessoryType=UITableViewCellAccessoryNone;
                    }
                    
                    switch (indexPath.row) {
                        case 0:
                            cell.textLabel.text=NSLocalizedString(@"repeatFromCompletionDateText",@"");
                            break;
                            
                        default:
                            cell.textLabel.text= NSLocalizedString(@"repeatFromDueDateText",@"");
                            break;
                    }
                    
                    return cell;
                }
                    break;	
			}
			break;
        case TASK_EDIT_REPEAT:
            switch (indexPath.section) {
				case 0:
				{
					UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifierGL"];
					if (cell == nil) {
						cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifierGL"] autorelease];
					}
					
					if(self.pathIndex>=0 &&[selectedPath compare:indexPath] == NSOrderedSame ){
						cell.accessoryType= UITableViewCellAccessoryCheckmark;
					}else {
						cell.accessoryType= UITableViewCellAccessoryNone;
					}
					
					if(currentIndex==indexPath.row){
						cell.textLabel.textColor=[Colors darkSteelBlue];
					}else {
						cell.textLabel.textColor=[UIColor blackColor];
					}
                    
					cell.textLabel.text = [repeatList objectAtIndex:indexPath.row];
					return cell;
				}
					break;
				case 1:
					switch (indexPath.row) {
						case 0:
						{
							UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifierGLOpt"];
							if (cell == nil) {
								cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifierGLOpt"] autorelease];
							}
							
							if(self.pathIndex>=0 &&[selectedPath compare:indexPath] == NSOrderedSame ){
								cell.accessoryType= UITableViewCellAccessoryCheckmark;
							}else {
								cell.accessoryType= UITableViewCellAccessoryNone;
							}
							
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							
							if(currentIndex==indexPath.row){
								cell.textLabel.textColor=[Colors darkSteelBlue];
							}else {
								cell.textLabel.textColor=[UIColor blackColor];
							}
                            
							cell.textLabel.text=@"";
							if([repeatEveryLB superview])
								[repeatEveryLB removeFromSuperview];
							[cell.contentView addSubview:repeatEveryLB];
							
							switch (currentIndex) {
								case REPEAT_DAILY:
									repeatEveryUnitLB.text= NSLocalizedString(@"dayUnitText", @"");//@"day(s)";
									break;
								case REPEAT_WEEKLY:
									repeatEveryUnitLB.text=NSLocalizedString(@"weekUnitText", @"")/*weekUnitText*/;
									break;
								case REPEAT_MONTHLY:
									repeatEveryUnitLB.text=NSLocalizedString(@"monthUnitText", @"")/*monthUnitText*/;
									break;
								case REPEAT_YEARLY:
									repeatEveryUnitLB.text=NSLocalizedString(@"yearUnitText", @"")/*yearUnitText*/;
									break;
								default:
									repeatEveryUnitLB.text=@"";
									break;
							}
							
							if([textField superview])
								[textField removeFromSuperview];
							[cell.contentView addSubview:textField];
							
							if([repeatEveryUnitLB superview])
								[repeatEveryUnitLB removeFromSuperview];
							[cell.contentView addSubview:repeatEveryUnitLB];
							
							if([repeatOptionWeeklyView superview])
								[repeatOptionWeeklyView removeFromSuperview];
							
							if([repeatOptionMonthlyView superview])
								[repeatOptionMonthlyView removeFromSuperview];
							
							if(currentIndex==REPEAT_WEEKLY){
								[cell.contentView addSubview:repeatOptionWeeklyView];
							}else if(currentIndex==REPEAT_MONTHLY){
								[cell.contentView addSubview:repeatOptionMonthlyView];
							}
							return cell;
                            
						}
							break;
					}
					break;
				case 2:
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"repeatStyle"];
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"repeatStyle"] autorelease];
                    }else{
                        
                    }
                    
                    cell.textLabel.text=@"";
                    
                    if ([self.editedObject taskRepeatStyle]==indexPath.row) {
                        cell.accessoryType=UITableViewCellAccessoryCheckmark;
                    }else{
                        cell.accessoryType=UITableViewCellAccessoryNone;
                    }
                    
                    switch (indexPath.row) {
                        case 0:
                            cell.textLabel.text=NSLocalizedString(@"repeatFromCompletionDateText",@"");
                            break;
                            
                        default:
                            cell.textLabel.text=NSLocalizedString(@"repeatFromDueDateText",@"");;
                            break;
                    }
                    
                    return cell;
                }
                    break;	
			}
			break;
		case SETTING_TASKMOVE:
			//cell.text =[taskMovingStypeList objectAtIndex:indexPath.row];
			break;
		case SETTING_PASSDUEMOVE:
			
			//cell.text =[deadlineExpandList objectAtIndex:indexPath.row];
			
			break;
		case SETTING_SYNCTYPE:
		{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifierGL"];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifierGL"] autorelease];
			}
			
			if(self.pathIndex>=0 &&[selectedPath compare:indexPath] == NSOrderedSame ){
				cell.accessoryType= UITableViewCellAccessoryCheckmark;
			}else {
				cell.accessoryType= UITableViewCellAccessoryNone;
			}			

			if(indexPath.section==0){
				cell.selectionStyle=UITableViewCellSelectionStyleBlue;
				if(currentIndex==indexPath.row){
					cell.textLabel.textColor=[Colors darkSteelBlue];
				}else {
					cell.textLabel.textColor=[UIColor blackColor];
				}
				
				cell.textLabel.text=[syncTypeList objectAtIndex:indexPath.row];
			}else {
				cell.selectionStyle=UITableViewCellSelectionStyleNone;
				if([syncTypeNotes superview])
					[syncTypeNotes removeFromSuperview];
				
				[cell.contentView addSubview:syncTypeNotes];
	
/*v5                
#ifdef FREE_VERSION
				
				if(self.pathIndex==0){//st<->gcal
					syncTypeNotes.text=NSLocalizedString(@"twoWaySTAndGCalMsg4LiteText", @"")
				}else if(self.pathIndex==1){//st->gcal
					syncTypeNotes.text=NSLocalizedString(@"oneWaySTToGCalMsg4LiteText", @"")
				}else {
					syncTypeNotes.text=NSLocalizedString(@"oneWayGCalToSTMsg4LiteText", @"")
				}
#else
				if(self.pathIndex==0){//st<->gcal
					syncTypeNotes.text=NSLocalizedString(@"twoWaySTAndGCalMsgText", @"")
				}else if(self.pathIndex==1){//st->gcal
					syncTypeNotes.text=NSLocalizedString(@"oneWaySTToGCalMsgText", @"")
				}else {
					syncTypeNotes.text=NSLocalizedString(@"oneWayGCalToSTMsgText", @"")
				}
 
#endif				
*/
            cell.textLabel.text=@"";
			}
			
			return cell;
		}
			break;
			
		case SETTING_BADGE:
		{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifierGL"];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifierGL"] autorelease];
			}
			
			if(self.pathIndex>=0 &&[selectedPath compare:indexPath] == NSOrderedSame ){
				cell.accessoryType= UITableViewCellAccessoryCheckmark;
			}else {
				cell.accessoryType= UITableViewCellAccessoryNone;
			}
			
			if(currentIndex==indexPath.row){
				cell.textLabel.textColor=[Colors darkSteelBlue];
			}else {
				cell.textLabel.textColor=[UIColor blackColor];
			}
			
			switch (indexPath.row) {
				case TASKS_ALL:
					cell.textLabel.text = NSLocalizedString(@"allTasksText", @"")/*allTasksText*/;
					break;
				case TASKS_WITH_DUE_ALL:
					cell.textLabel.text = NSLocalizedString(@"tasksWithDueText", @"")/*tasksWithDueText*/;
					break;
				case TASKS_WITH_DUE_2_DAYS:
					cell.textLabel.text = NSLocalizedString(@"tasksWithNoDueText", @"")/*tasksWithNoDueText*/;
					break;
				default:
					break;
			}
			return cell;
		}
			break;
		
		case SETTING_WEEK_START_DAY:
		{
			switch (indexPath.section) {
				case 0:
				{
					UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifierGL"];
					if (cell == nil) {
						cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifierGL"] autorelease];
					}
					
					if(self.pathIndex>=0 &&[selectedPath compare:indexPath] == NSOrderedSame ){
						cell.accessoryType= UITableViewCellAccessoryCheckmark;
					}else {
						cell.accessoryType= UITableViewCellAccessoryNone;
					}
					
					if(currentIndex==indexPath.row){
						cell.textLabel.textColor=[Colors darkSteelBlue];
					}else {
						cell.textLabel.textColor=[UIColor blackColor];
					}
					
					switch (indexPath.row) {
						case START_SUNDAY:
							cell.textLabel.text = NSLocalizedString(@"sundayText", @"")/*sundayText*/;
							break;
						case START_MONDAY:
							cell.textLabel.text = NSLocalizedString(@"mondayText", @"")/*mondayText*/;
							break;
						default:
							break;
					}
					return cell;
				}	
					break;
				case 1:
				{
				/*	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifierGL"];
					if (cell == nil) {
						cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifierGL"] autorelease];
					}
					
					cell.accessoryType= UITableViewCellAccessoryNone;
					cell.selectionStyle=UITableViewCellSelectionStyleNone;
					
					cell.textLabel.font =[UIFont italicSystemFontOfSize:14];
					cell.textLabel.numberOfLines=0;
					cell.textLabel.text=NSLocalizedString(@"weedStartDayNotesMsg", @"")
					return cell;
                 */
				}
					break;
			}
		}
			break;
			
			
	}
	
	//ILOG(@"GeneralListViewController cellForRowAtIndexPath]\n");
	return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	switch (self.keyEdit) {
		case (TIMER_EDITREPEATID):
			if (indexPath.section==1&&indexPath.row==0)
				if(currentIndex==REPEAT_DAILY || currentIndex==REPEAT_YEARLY){
					return 45;
				}else if(currentIndex==REPEAT_WEEKLY || currentIndex==REPEAT_MONTHLY){
					return 150;
				}
			break;
        case TASK_EDIT_REPEAT:
			if (indexPath.section==1&&indexPath.row==0)
				if(currentIndex==REPEAT_DAILY || currentIndex==REPEAT_YEARLY){
					return 45;
				}else if(currentIndex==REPEAT_WEEKLY || currentIndex==REPEAT_MONTHLY){
					return 150;
				}
			break;
		case SETTING_SYNCTYPE:
			if (indexPath.section==1&&indexPath.row==0)
				return 150;
			break;
		case SETTING_WEEK_START_DAY:
			if (indexPath.section==1&&indexPath.row==0)
				return 60;
			break;
	}
	return 45;
}

- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section {
    // Return the displayed title for the specified section.	
	return @"";
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			currentIndex=indexPath.row;
			[tv reloadData];
			break;
		case 1:
			break;
	}
    
	// Never allow selection.
    if (self.editing) {
		saveButton.enabled=YES;
		return indexPath;
	}
    return nil;
}

/*- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	if(self.pathIndex>=0){
		NSIndexPath *selectedPath = [NSIndexPath indexPathForRow:self.pathIndex inSection:0];	
		if ([selectedPath compare:indexPath] == NSOrderedSame ) {
			return UITableViewCellAccessoryCheckmark;
		}
	}
	return UITableViewCellAccessoryNone;
	
}
*/
- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	//ILOG(@"[GeneralListViewController didSelectRowAtIndexPath\n");
	switch (newIndexPath.section) {
		case 0:
		{
			NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:self.pathIndex inSection:0];	
			[[table cellForRowAtIndexPath:oldIndexPath] setAccessoryType:UITableViewCellAccessoryNone];
			[[table cellForRowAtIndexPath:newIndexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
			self.pathIndex=newIndexPath.row;
			[table deselectRowAtIndexPath:newIndexPath animated:YES];
			
			if(keyEdit==SETTING_SYNCTYPE)
			{

/*v5                
#ifdef FREE_VERSION
				if(self.pathIndex==0){//st<->gcal
					syncTypeNotes.text=NSLocalizedString(@"twoWaySTAndGCalMsg4LiteText", @"")
				}else if(self.pathIndex==1){//st->gcal
					syncTypeNotes.text=NSLocalizedString(@"oneWaySTToGCalMsg4LiteText", @"")
				}else {
					syncTypeNotes.text=NSLocalizedString(@"oneWayGCalToSTMsg4LiteText", @"")
				}
#else
				if(self.pathIndex==0){//st<->gcal
					syncTypeNotes.text=NSLocalizedString(@"twoWaySTAndGCalMsgText", @"")
				}else if(self.pathIndex==1){//st->gcal
					syncTypeNotes.text=NSLocalizedString(@"oneWaySTToGCalMsgText", @"")
				}else {
					syncTypeNotes.text=NSLocalizedString(@"oneWayGCalToSTMsgText", @"")
				}
 
#endif	
 */
			}
		}
			break;
		case 1:
			break;
            
        case 2:
        {
            [self.editedObject setTaskRepeatStyle:newIndexPath.row];
            UITableViewCell *cell=cell=[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
            cell.accessoryType=UITableViewCellAccessoryNone;
            cell=cell=[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]];
            cell.accessoryType=UITableViewCellAccessoryNone;
            
            cell=[table cellForRowAtIndexPath:newIndexPath];
            cell.accessoryType=UITableViewCellAccessoryCheckmark;
            [table deselectRowAtIndexPath:newIndexPath animated:YES];
        }   
            break;    
	}
	//[table reloadData];
	
	//ILOG(@"GeneralListViewController didSelectRowAtIndexPath]\n");
}

#pragma mark TextField Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)tF{
	CGRect frm=CGRectMake(0, 0, 320, 160);
	tableView.frame=frm;
	tableView.scrollEnabled=NO;
	///[tableView scrollRectToVisible:CGRectMake(240, 415, 60, 30)/*[tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]*/ animated:YES];
	[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:NO];
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)tF{
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)tF{
	if([tF.text intValue]<1)
		tF.text=[NSString stringWithFormat:@"%d",1];
}

#pragma mark properties
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
	if(repeatOptions !=nil)
	[repeatOptions release];
	repeatOptions=[str copy];
}


-(NSString *)repeatOn{
	return repeatOn;
}

-(void)setRepeatOn:(NSString *)str{
	if(repeatOn !=nil)
	[repeatOn release];
	repeatOn=[str copy];
}

@end
