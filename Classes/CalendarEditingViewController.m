//
//  SyncToodledoSetupViewController.h
//  SmartOrganizer
//
//  Created by NangLe on 8/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CalendarEditingViewController.h"
#import "IvoCommon.h"
#import "Projects.h"
#import "ivo_Utilities.h"
#import "RGBColor.h"
#import "TaskManager.h"
#import "ColorObject.h"
#import "Setting.h"
#import "Task.h"
//#import "ToodleSync.h"
#import "EKSync.h"
#import "TaskManager.h"
#import "SmartTimeAppDelegate.h"
#import "ReminderSync.h"

extern SmartTimeAppDelegate *App_Delegate;
extern ivo_Utilities *ivoUtility;
extern BOOL			isSyncing;

extern TaskManager *taskmanager;
extern sqlite3 *database;
extern NSMutableArray *projectList;

extern NSString *enterCalendarNameHereText;
extern NSString *selectColorText;
extern NSString *calendarDetailText;
//extern NSString *backText;
extern NSString *ColorGroupNames[];
//extern NSString *cancelText;
//extern NSString *deleteText;
//extern NSString *resetForToddledoSyncText;
//extern NSString *resetCalendarForToodleSyncMsg;
//extern NSString *yesText;
//extern NSString *noText;
extern NSString *deleteCalendarErrorMsg;
extern NSString *deleteCalendarMsg;
//extern NSString *okText;
extern NSString *setAsDefaultCaledarText;
extern NSString *syncWithGoogleText;
extern NSString *syncWithToodledoText;
extern NSString *syncWithICalText;
//extern NSString *normalText;
//extern NSString *listText;
//extern NSString *projectTypeText;
//extern NSString *projectTypeNotes;
extern NSString *newProjectText;
extern NSString *editProjectText;
extern NSString *unHideThisCalendarText;
//extern NSString *newCategoryText;

#pragma mark new

extern NSString *calendarDetailText;
extern NSString *newCategoryText;

@implementation CalendarEditingViewController
@synthesize editedObject,editedKey,editedCalendar;
@synthesize projectNameTextField;
@synthesize isQuickAdd;
@synthesize buttonsList;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement loadView to create a view hierarchy programmatically, without using a nib.
//- (void)loadView {
-(id)init{
    self=[super init];
	if (self) {
		
		self.navigationItem.title=NSLocalizedString(@"newProjectText",@"");
		self.buttonsList=[NSMutableArray array];
		
		//UIBarButtonItem *cancelBt=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
		//																		target:self 
		//																		action:@selector(cancelQuickAdd:)];
		//self.navigationItem.leftBarButtonItem=cancelBt;
		//[cancelBt release];

		//UIBarButtonItem *donelBt=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
		//																		target:self 
		//																		action:@selector(doneQuickAdd:)];
		//self.navigationItem.rightBarButtonItem=donelBt;
		//[donelBt release];
		
        CGRect frame=[[UIScreen mainScreen] bounds];
        
		contentView=[[UIView alloc] initWithFrame:frame];
		contentView.backgroundColor=[UIColor colorWithRed:(CGFloat)211/255 green:(CGFloat)214/255 blue:(CGFloat)219/255 alpha:1];
		
		CGRect textFieldFrame = CGRectMake(10, 50+64, 460, 30);
		projectNameTextField=[[UITextField alloc] initWithFrame:textFieldFrame];
		projectNameTextField.borderStyle=UITextBorderStyleRoundedRect;
		projectNameTextField.returnKeyType = UIReturnKeyDefault;
		projectNameTextField.font=[UIFont systemFontOfSize:18];
		projectNameTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
		projectNameTextField.placeholder=NSLocalizedString(@"enterCalendarNameHereText",@"");
		projectNameTextField.delegate=self;
		projectNameTextField.returnKeyType=UIReturnKeyDone;
		[contentView addSubview:projectNameTextField];
		[projectNameTextField release];
		
/*		fontColorLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 35)];
		fontColorLabel.backgroundColor=[UIColor blackColor];
		fontColorLabel.textColor=[UIColor whiteColor];
		fontColorLabel.textAlignment=NSTextAlignmentCenter;
		fontColorLabel.text=selectColorText;
		
		fontColorBt=[UIButton buttonWithType:UIButtonTypeCustom];
		fontColorBt.frame=CGRectMake(0, 0, 250, 35);
		[fontColorBt addTarget:self action:@selector(loadColorPicker:) forControlEvents:UIControlEventTouchUpInside];
		[fontColorBt addSubview:fontColorLabel];
		[fontColorLabel release];

		[contentView addSubview:fontColorBt];
*/
		
		defaultCalendarBt=[UIButton buttonWithType:UIButtonTypeCustom];
		defaultCalendarBt.frame=CGRectMake(0, 64, 250, 35);
		[defaultCalendarBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[defaultCalendarBt setBackgroundImage:[UIImage imageNamed:@"settings_check.png"] forState:UIControlStateSelected];
		[defaultCalendarBt setBackgroundImage:[UIImage imageNamed:@"settings_uncheck.png"] forState:UIControlStateNormal];
		[defaultCalendarBt addTarget:self action:@selector(setDefault:) forControlEvents:UIControlEventTouchUpInside];
		[defaultCalendarBt setTitle:[NSString stringWithFormat:@"        %@",NSLocalizedString(@"setAsDefaultCaledarText",@"")] forState:UIControlStateNormal];
		[contentView addSubview:defaultCalendarBt];
		
		showHidebt=[UIButton buttonWithType:UIButtonTypeRoundedRect];
		showHidebt.frame=CGRectMake(0, 64, 250, 35);
		[showHidebt setTitle:NSLocalizedString(@"unHideThisCalendarText",@"") forState:UIControlStateNormal];
		[showHidebt addTarget:self action:@selector(unhideCalendar:) forControlEvents:UIControlEventTouchUpInside];
		[contentView addSubview:showHidebt];
		
		deleteBt=[UIButton buttonWithType:UIButtonTypeRoundedRect];
		deleteBt.frame=CGRectMake(0, 64, 250, 35);
		deleteBt.titleLabel.font=[UIFont systemFontOfSize:16];
		[deleteBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[deleteBt addTarget:self action:@selector(deleteCalendar:) forControlEvents:UIControlEventTouchUpInside];
		[deleteBt setTitle:NSLocalizedString(@"deleteText", @"") forState:UIControlStateNormal];
		[deleteBt setBackgroundImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
		
		[contentView addSubview:deleteBt];
		
		
		for (NSInteger i=0;i<4;i++) {
			for (NSInteger j=0; j<8; j++) {
				UIView *colorView=[[UIView alloc] initWithFrame:CGRectMake(0, 64, 25, 25)];
				colorView.userInteractionEnabled=NO;
				ColorObject *color=[ivoUtility colorForColorNameNo:j inPalette:i];
				colorView.backgroundColor=[UIColor colorWithRed:color.R1 green:color.G1 blue:color.B1 alpha:1];
				colorView.center=CGPointMake(j*40+20, 200+i*40+20+84);
				[contentView addSubview:colorView];
				[colorView release];

				UIButton *bt=[UIButton buttonWithType:UIButtonTypeCustom];
				bt.tag=i*10+j;
				bt.frame=CGRectMake(j*40, 200+i*40+84, 40, 40);
				[bt setImage:[UIImage imageNamed:@"colors_highlight.png"] forState:UIControlStateSelected];
				[bt setImage:[UIImage imageNamed:@"colors_empty.png"] forState:UIControlStateNormal];
				[bt addTarget:self action:@selector(colorSeleted:) forControlEvents:UIControlEventTouchUpInside];
				[contentView addSubview:bt];
				
				[self.buttonsList addObject:bt];
			}
		}
		
		self.view=contentView;
		[contentView release];
		
		//[self loadColorPicker:nil];
        
        
	}
	return self;
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
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

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations

    [self refreshFrames];
		
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    [self refreshFrames];
}

-(void)refreshFrames{
    CGRect frame=[[UIScreen mainScreen] bounds];
    
    if (!self.isQuickAdd) {
		projectNameTextField.frame=CGRectMake(40, 20+64, frame.size.width-80, 30);
		defaultCalendarBt.center=CGPointMake(frame.size.width/2, 85+64);
		showHidebt.center=CGPointMake(frame.size.width/2, 85+64+40);
		deleteBt.center=CGPointMake(frame.size.width/2, 133+64+40);
	}else {
		defaultCalendarBt.hidden=YES;
		deleteBt.hidden=YES;
		projectNameTextField.frame=CGRectMake(40, 20+64, frame.size.width-80, 30);
	}
	
	if (taskmanager.currentSettingModifying.projectDefID==self.editedCalendar.primaryKey) {
		deleteBt.hidden=YES;
	}

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[editedObject release];
    [super dealloc];
}


#pragma mark action methods

-(void)colorSeleted:(id)sender{
	for (UIButton *btn in self.buttonsList) {
		btn.selected=NO;
	}
	
	UIButton *bt=sender;
	NSInteger colorNo=bt.tag;
	bt.selected=!bt.selected;
	self.editedCalendar.groupId=colorNo/10;
	self.editedCalendar.colorId=colorNo%10;
	[self.editedCalendar update];
	
	ColorObject *color=[ivoUtility colorForColorNameNo:self.editedCalendar.colorId
											 inPalette:self.editedCalendar.groupId];
	projectNameTextField.textColor=[UIColor colorWithRed:color.R1 green:color.G1 blue:color.B1 alpha:1];

}

-(void)unhideCalendar:(id)sender{
	self.editedCalendar.inVisible=0;
	[self.editedCalendar update];
	[App_Delegate updateHiddenStatusForTaskBelongCalendarId:self.editedCalendar.primaryKey hidden:self.editedCalendar.inVisible];
	[App_Delegate addTasksToListFromCalendarId:self.editedCalendar.primaryKey];
	[self reloadData];
}

-(void)cancelQuickAdd:(id)sender{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)doneQuickAdd:(id)sender{
    self.editedCalendar.projName=projectNameTextField.text;
	[self saveCalendar:nil];
}

-(void)setDefault:(id)sender{
	if ([self.editedObject primaryKey]>0) {
		taskmanager.currentSettingModifying.projectDefID=self.editedCalendar.primaryKey;
		[taskmanager.currentSettingModifying update];
	}
	
	defaultCalendarBt.selected=YES;
	[(Projects*)self.editedCalendar update];
    
    //[self reloadData];
}

-(void)deleteCalendar:(id)sender{
	if (projectList.count>1) {
		deleteAlertView=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"deleteCalendarMsg",@"")
												   message:@"" 
												  delegate:self
										 cancelButtonTitle:NSLocalizedString(@"noText", @"")
										 otherButtonTitles:NSLocalizedString(@"yesText", @""),nil];
		[deleteAlertView show];
		[deleteAlertView release];
		
	}else {
		deleteAlertView=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"deleteCalendarErrorMsg",@"") 
												   message:@"" 
												  delegate:self
										 cancelButtonTitle:NSLocalizedString(@"okText", @"")
										 otherButtonTitles:nil];
		[deleteAlertView show];
		[deleteAlertView release];
		
	}
}

-(void)cancel:(id)sender{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)saveCalendar:(id)sender{
	[projectNameTextField resignFirstResponder];
    self.editedCalendar.projName=projectNameTextField.text;

	if(!projectNameTextField.text || [[projectNameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]){
		//if (self.isQuickAdd) {
			self.editedCalendar.projName=NSLocalizedString(@"newProjectText",@"");;
		//}else {
		//	self.editedCalendar.projName=@"New Project";
		//}
	}
	
	switch (editedKey) {
		case ADD_NEW:
		{
			[taskmanager addCalendarToCalendarList:self.editedCalendar];
			if (defaultCalendarBt.selected) {
				taskmanager.currentSettingModifying.projectDefID=self.editedCalendar.primaryKey;
				[taskmanager.currentSettingModifying update];
				defaultCalendarBt.selected=YES;
			}
		}
			break;
		case EDIT:
		{
			
			[(Projects*)self.editedCalendar update];
			
		}
			break;
	}
    
    if (taskmanager.currentSettingModifying.autoICalSync==1){
        
        if(taskmanager.currentSettingModifying.enableSyncICal==1) {
            [taskmanager.ekSync oneWayUpdateiCal:self.editedObject];
        }

        if (taskmanager.currentSettingModifying.enabledReminderSync==1) {
            [taskmanager.reminderSync oneWayUpdateCalendar:self.editedCalendar];
        }
    }
}

-(void)showPickerView:(UIPickerView *)picker{
	// Position the date picker below the bottom of the screen.
	picker.hidden=NO;
	picker.frame = CGRectMake(0, 1024, self.view.frame.size.width, 180);
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	picker.frame=CGRectMake(0, self.view.frame.size.height-180+40, self.view.frame.size.width, 180);
	[UIView commitAnimations];	
//	isColorPickerShowed=YES;
	
}

#pragma mark AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if ([alertView isEqual:resetAlertView] && buttonIndex==1) {
		self.editedCalendar.toodledoFolderKey=0;
		resetAlertView.hidden=YES;
		[self.editedCalendar update];
		//[self.rootController removeDetailCalendarView:nil];
	}else if ([alertView isEqual:deleteAlertView] && buttonIndex==1) {
		//delete tasks/events from this calendar first
		//[taskmanager deleteAllTasksBelongCalendar:self.editedCalendar.primaryKey];
		
		NSMutableArray *taskArr=[NSMutableArray arrayWithArray:taskmanager.taskList];
		for (Task *task in taskArr) {
			if (task.taskProject==self.editedCalendar.primaryKey) {
				//[taskmanager deleteTask:task.primaryKey
				//		 isDeleteFromDB:YES
				//		   deleteREType:ALL_SERIRES];
                
                if (task.taskPinned==1 && [task.iCalIdentifier length]>0) {
                    taskmanager.currentSettingModifying.deletedICalEvents=[taskmanager.currentSettingModifying.deletedICalEvents stringByAppendingFormat:@"|%@",task.iCalIdentifier];
                    taskmanager.currentSetting.deletedICalEvents=[taskmanager.currentSetting.deletedICalEvents stringByAppendingFormat:@"|%@",task.iCalIdentifier];
                }else if (task.taskPinned==0 && [task.reminderIdentifier length]>0){
                    taskmanager.currentSettingModifying.deletedReminders=[taskmanager.currentSettingModifying.deletedReminders stringByAppendingFormat:@"|%@",task.reminderIdentifier];
                    taskmanager.currentSetting.deletedReminders=[taskmanager.currentSetting.deletedReminders stringByAppendingFormat:@"|%@",task.reminderIdentifier];
                }
                    
				[task deleteFromDatabase];
			}
		} 
		
			
		[taskmanager.currentSettingModifying update];
		
		
		NSMutableArray *arr=[NSMutableArray arrayWithArray:taskmanager.taskList];
		for (Task *task in arr) {
			if (task.taskProject==self.editedCalendar.primaryKey) {
				[taskmanager.taskList removeObject:task];
			}
		}
		
		[App_Delegate deleteAllTasksBelongCalendar:self.editedCalendar.primaryKey];
		
		//delete this calendar
		//[self.editedCalendar deleteFromDatabase];
		BOOL isDefaultCal=NO;
		if (self.editedCalendar.primaryKey==taskmanager.currentSettingModifying.projectDefID) {
			isDefaultCal=YES;
		}
		
		if (isDefaultCal) {
			taskmanager.currentSettingModifying.projectDefID=[[projectList objectAtIndex:0] primaryKey];
		}
		
		//[self.rootViewController removeDetailCalendarView:nil];
		
        if ([self.editedCalendar.iCalIdentifier length]>0) {
            taskmanager.currentSettingModifying.deletedICalCalendars=[taskmanager.currentSettingModifying.deletedICalCalendars stringByAppendingFormat:@"|%@",self.editedCalendar.iCalIdentifier];
            
            //for syncing
            taskmanager.currentSetting.deletedICalCalendars=[taskmanager.currentSetting.deletedICalCalendars stringByAppendingFormat:@"|%@",self.editedCalendar.iCalIdentifier];
        }
        
        if ([self.editedCalendar.reminderIdentifier length]>0) {
            taskmanager.currentSettingModifying.deletedReminderLists=[taskmanager.currentSettingModifying.deletedReminderLists stringByAppendingFormat:@"|%@",self.editedCalendar.reminderIdentifier];
            taskmanager.currentSetting.deletedReminderLists=[taskmanager.currentSetting.deletedReminderLists stringByAppendingFormat:@"|%@",self.editedCalendar.reminderIdentifier];
        }
        
        [taskmanager.currentSettingModifying update];
        [taskmanager.currentSetting update];
        
		if (taskmanager.currentSettingModifying.autoICalSync) {
            
			if (taskmanager.currentSettingModifying.enableSyncICal==1) {

                //[self.editedCalendar deleteFromDatabase];
                //[projectList removeObject:self.editedCalendar];

				if ([taskmanager.currentSettingModifying.deletedICalEvents length]>0) {
					[taskmanager.ekSync backgroundFullSync];
				}else{
                    [taskmanager.ekSync oneWayDeleteICals];
                }
                
			}
            
            if (taskmanager.currentSettingModifying.enabledReminderSync) {
                [taskmanager.reminderSync oneWayDeleteCalendars];
            }
		}

        [self.editedCalendar deleteFromDatabase];
        [projectList removeObject:self.editedCalendar];

		[self.navigationController popViewControllerAnimated:YES];
        //[projectList removeObject:self.editedCalendar];
	}
}

#pragma mark ControllerDelegate
-(void)viewWillAppear:(BOOL)animated{
	
	switch (editedKey) {
		case ADD_NEW:
			self.navigationItem.title=NSLocalizedString(@"newCategoryText",@"");
			deleteBt.hidden=YES;
			break;
		case EDIT:
		{	
			self.navigationItem.title=NSLocalizedString(@"calendarDetailText", @"") ;
			if (!self.isQuickAdd) {
				self.navigationItem.rightBarButtonItem=nil;
				self.navigationItem.leftBarButtonItem=nil;
                deleteBt.hidden=NO;
			}
		}
			break;
	}

	self.editedCalendar=editedObject;

	ColorObject *color=[ivoUtility colorForColorNameNo:self.editedCalendar.colorId inPalette:self.editedCalendar.groupId];
	
	projectNameTextField.text=self.editedCalendar.projName;
	projectNameTextField.textColor=[UIColor colorWithRed:color.R1 green:color.G1 blue:color.B1 alpha:1];
	
	for (UIButton *bt in self.buttonsList) {
		if (bt.tag==self.editedCalendar.groupId*10+self.editedCalendar.colorId) {
			bt.selected=YES;
		}else {
			bt.selected=NO;
		}
		
	}
	
	if (self.isQuickAdd) {
		if (editedKey==ADD_NEW) {
			self.navigationItem.title=NSLocalizedString(@"newProjectText", @"");;
		}else {
			self.navigationItem.title=NSLocalizedString(@"editProjectText", @"");
		}
	}
    
    [self refreshFrames];
}

-(void)reloadData{
	
	self.editedCalendar=editedObject;
	
	switch (editedKey) {
		case ADD_NEW:
			self.navigationItem.title=NSLocalizedString(@"newCategoryText",@"");
			deleteBt.hidden=YES;
            defaultCalendarBt.hidden=YES;
			break;
		case EDIT:
		{			
			self.navigationItem.title=NSLocalizedString(@"calendarDetailText", @"");
			if (!self.isQuickAdd) {
				if (taskmanager.currentSettingModifying.projectDefID==self.editedCalendar.primaryKey) {
					defaultCalendarBt.selected=YES;
				}else {
					defaultCalendarBt.selected=NO;
				}
				
				self.navigationItem.rightBarButtonItem=nil;
				self.navigationItem.leftBarButtonItem=nil;
			}
			
            deleteBt.hidden=NO;
            defaultCalendarBt.hidden=NO;
		}
			break;
	}

	ColorObject *color=[ivoUtility colorForColorNameNo:self.editedCalendar.colorId inPalette:self.editedCalendar.groupId];
	
	projectNameTextField.text=self.editedCalendar.projName;
	projectNameTextField.textColor=[UIColor colorWithRed:color.R1 green:color.G1 blue:color.B1 alpha:1];
	
	for (UIButton *bt in self.buttonsList) {
		if (bt.tag==self.editedCalendar.groupId*10+self.editedCalendar.colorId) {
			bt.selected=YES;
		}else {
			bt.selected=NO;
		}

	}
	
	if (self.editedCalendar.inVisible && editedKey!=ADD_NEW) {
		showHidebt.hidden=NO;
	}else {
		showHidebt.hidden=YES;
	}
}

- (void)viewWillDisappear:(BOOL)animated{
	[self performSelector:@selector(saveCalendar:) withObject:nil];
}

-(void)loadColorPicker:(id)sender{

}

#pragma mark UIPickerView Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	switch (component) {
		case 0:
			return 4;//number of palettes
			break;
		case 1://number of RGBColor in each palettes
		{
			//switch (self.editedCalendar.groupId){
			//	case PRIME:
					return 8;
			//		break;
			//	case PASTEL:
			//		return 8;
			//		break;
			//}
		}
			break;
	}
	return 0;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
	switch (component) {
		case 0:
			//[pickerView reloadComponent:1];
			[pickerView reloadAllComponents];
			
			self.editedCalendar.groupId=row;
			//set default select
			[pickerView selectRow:0/*(editedKey==ADD_NEW?0:(self.editedCalendar.colorId<7?self.editedCalendar.colorId:0))*/ inComponent:1 animated:YES];
			//self.editedCalendar.colorId=(editedKey==ADD_NEW?0:(self.editedCalendar.colorId<7?self.editedCalendar.colorId:0));
			self.editedCalendar.colorId=0;
			
			ColorObject *color=[ivoUtility colorForColorNameNo:self.editedCalendar.colorId inPalette:row];
//			fontColorLabel.backgroundColor=[UIColor colorWithRed:color.R1 green:color.G1 blue:color.B1 alpha:1];
			projectNameTextField.textColor=[UIColor colorWithRed:color.R1 green:color.G1 blue:color.B1 alpha:1];
			break;
		case 1:
		{
			ColorObject *color=[ivoUtility colorForColorNameNo:row inPalette:self.editedCalendar.groupId];
//			fontColorLabel.backgroundColor=[UIColor colorWithRed:color.R1 green:color.G1 blue:color.B1 alpha:1];
			projectNameTextField.textColor=[UIColor colorWithRed:color.R1 green:color.G1 blue:color.B1 alpha:1];
			self.editedCalendar.colorId=row;
		}
			break;
	}
	
	switch (editedKey) {
		case EDIT:
		{
			
			[(Projects*)self.editedCalendar update];
			
		}
			break;
	}
	
	//self.editedCalendar.groupId=[pickerView selectedRowInComponent:0];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
	return 40;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
	switch (component) {
		case 0:
			return 120;
			break;
		case 1:
			return 220;
			break;
	}
	return 0;
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
	
	UILabel	*rowView=(UILabel*)view;
	if(!rowView){
		rowView = [[[UILabel alloc] 
					initWithFrame:CGRectMake(0, 0,
											 [self pickerView:pickerView widthForComponent:component]-6,
											 [self pickerView:pickerView rowHeightForComponent:component])] autorelease];
	}
	
	rowView.textAlignment=NSTextAlignmentCenter;
	rowView.backgroundColor=[UIColor clearColor];
	
	switch (component) {
		case 0:
			rowView.backgroundColor=[UIColor clearColor];
			rowView.textColor=[UIColor blackColor];
			rowView.shadowColor=[UIColor lightGrayColor];
			rowView.text=ColorGroupNames[row];
			break;
		case 1:
		{
			
			ColorObject *color=[ivoUtility colorForColorNameNo:row inPalette:self.editedCalendar.groupId];
			rowView.backgroundColor=[UIColor colorWithRed:color.R1 green:color.G1 blue:color.B1 alpha:1];	
		}
			break;
	}
	
	return rowView;
	
}

#pragma mark textField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
//	isColorPickerShowed=NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
//	self.editedCalendar.projName=textField.text;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
	switch (editedKey) {
		case ADD_NEW:
			//saveButton.enabled=NO;
			break;
	}

	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
	
	switch (editedKey) {
		case ADD_NEW:
			if(![string isEqualToString:@""]){
				//saveButton.enabled=YES;
			}else if([textField.text length]<2){
				//saveButton.enabled=NO;
			}
			
			break;
	}
	
	return YES;
}
	

@end
