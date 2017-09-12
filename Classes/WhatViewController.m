//
//  WhatViewController.m
//  iVo
//
//  Created by Nang Le on 8/15/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "WhatViewController.h"
#import "IvoCommon.h"
#import "Task.h"
#import "ivo_Utilities.h"
#import "Colors.h"
#import "Setting.h"
#import "SmartTimeAppDelegate.h"
#import "ContactViewConroller.h"
#import "LocationViewController.h"
#import "TableCellWhatTextTap.h"
#import "TableCellWhatLocation.h"
#import "SmartStartView.h"
#import <AddressBook/AddressBook.h>

//extern Setting	*currentSetting;
extern NSArray	*contactList;
extern ivo_Utilities	*ivoUtility;
extern SmartTimeAppDelegate *App_Delegate;

@implementation WhatViewController
@synthesize editedObject;

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
        isEditingLocation=NO;
	}
	return self;
}


// Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
	//ILOG(@"[WhatViewController loadView\n");
	// Don't invoke super if you want to create a view hierarchy programmatically
	//[super loadView];
	// Add navigation item buttons.

    CGRect frame=[[UIScreen mainScreen] bounds];
    
    UIBarButtonItem *saveButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
															  target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
	
	//self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
	
	self.navigationItem.title = NSLocalizedString(@"titleLocationText", @"")/*titleLocationText*/;
	
	contentView= [[UIView alloc] initWithFrame:CGRectMake(0,0, frame.size.width, frame.size.height)];
	contentView.backgroundColor=[UIColor groupTableViewBackgroundColor];
	
	tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,69, frame.size.width, frame.size.height-70-64) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
	//tableView.scrollEnabled=NO;
	
	doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	doneButton.frame = CGRectMake(250, 165, 60, 30);
	doneButton.alpha=1;
	[doneButton setTitle:NSLocalizedString(@"doneButtonText", @"")/*doneButtonText*/ forState:UIControlStateNormal];
	doneButton.titleLabel.font=[UIFont systemFontOfSize:14];
	[doneButton setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];		
	[doneButton setBackgroundImage:[UIImage imageNamed:@"blue-small.png"] forState:UIControlStateNormal];
	
	[doneButton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];


	deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	deleteButton.frame = CGRectMake(10, 165, 60, 30);
	deleteButton.alpha=1;
	[deleteButton setTitle:NSLocalizedString(@"cleanText", @"")/*cleanText*/ forState:UIControlStateNormal];
	deleteButton.titleLabel.font=[UIFont systemFontOfSize:14];
	[deleteButton setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];		
	[deleteButton setBackgroundImage:[UIImage imageNamed:@"blue-small.png"] forState:UIControlStateNormal];
	
	[deleteButton addTarget:self action:@selector(cleanWhere:) forControlEvents:UIControlEventTouchUpInside];
	
	
	doneBarView=[[UIView alloc] initWithFrame:CGRectMake(0, 160, 320, 40)];
	doneBarView.backgroundColor=[UIColor viewFlipsideBackgroundColor];
	doneBarView.alpha=0.3;
	
	[contentView addSubview:doneBarView];
	[doneBarView release];
	
	[contentView addSubview:doneButton];
	[contentView addSubview:deleteButton];
	
	[contentView addSubview:tableView];
	[tableView release];
	
	self.view = contentView;
	[contentView release];
	
	taskTitleEditField=[[UITextField alloc] initWithFrame:CGRectMake(15, 80, frame.size.width-30, 40)];
    //taskTitleEditField.backgroundColor=[UIColor clearColor];
	taskTitleEditField.borderStyle=UITextBorderStyleRoundedRect;
	taskTitleEditField.returnKeyType=UIReturnKeyDone;
	taskTitleEditField.font=[UIFont systemFontOfSize:16];
	taskTitleEditField.delegate=self;
	taskTitleEditField.textColor=[Colors darkSlateGray];
	taskTitleEditField.clearButtonMode=UITextFieldViewModeWhileEditing;
	
	loctionTextView=[[UITextView alloc] initWithFrame:CGRectMake(20, 0, frame.size.width-70, 80)];
	loctionTextView.delegate=self;
	loctionTextView.backgroundColor=[UIColor clearColor];
	loctionTextView.keyboardType=UIKeyboardTypeDefault;
	loctionTextView.font=[UIFont systemFontOfSize:18];
	//loctionTextView.alwaysBounceVertical=YES;
	
	gotoButton=[ivoUtility createButton:@"" 
							 buttonType:UIButtonTypeCustom 
								  frame:CGRectMake(10, 0, 40, 40) 
							 titleColor:nil 
								 target:self 
							   selector:@selector(gotoButtonAction:) 
					   normalStateImage:@"Go.png"
					 selectedStateImage:@"blueGo.png"];
	
	
	callButton=[ivoUtility createButton:@"" 
							 buttonType:UIButtonTypeCustom 
								  frame:CGRectMake(70, 0, 40, 40) 
							 titleColor:nil 
								 target:self 
							   selector:@selector(callButtonAction:) 
					   normalStateImage:@"Call.png"
					 selectedStateImage:@"blueCall.png"];

	buyButton=[ivoUtility createButton:@"" 
							buttonType:UIButtonTypeCustom 
								 frame:CGRectMake(130, 0, 40, 40) 
							titleColor:nil 
								target:self 
							  selector:@selector(buyButtonAction:) 
					  normalStateImage:@"Buy.png"
					selectedStateImage:@"blueBuy.png" ];
	
	mailButton=[ivoUtility createButton:@"" 
							 buttonType:UIButtonTypeCustom 
								  frame:CGRectMake(190, 0, 40, 40) 
							 titleColor:nil 
								 target:self 
							   selector:@selector(mailButtonAction:) 
					   normalStateImage:@"Mail.png"
					 selectedStateImage:@"blueMail.png"];
	
	meetButton=[ivoUtility createButton:@"" 
							 buttonType:UIButtonTypeCustom 
								  frame:CGRectMake(250, 0, 40, 40) 
							 titleColor:nil 
								 target:self 
							   selector:@selector(meetButtonAction:) 
					   normalStateImage:@"Meet.png"
					 selectedStateImage:@"blueMeet.png"];
	
	whatButtonGroup=[[UIView alloc] initWithFrame:CGRectMake(10, 30, 290, 40)];
	[whatButtonGroup addSubview:gotoButton];
	[gotoButton release];
	[whatButtonGroup addSubview:callButton];
	[callButton release];
	[whatButtonGroup addSubview:buyButton];
	[buyButton release];
	[whatButtonGroup addSubview:mailButton];
	[mailButton release];
	[whatButtonGroup addSubview:meetButton];
	[meetButton release];
	
	instrustion=[[UILabel alloc] initWithFrame:CGRectMake(20, 2, 280, 25)];	
	instrustion.text=NSLocalizedString(@"titleGuideWWWText", @"")/*titleGuideWWWText*/;
	instrustion.textColor=[UIColor grayColor];
	
	editLocationButton=[ivoUtility createButton:@""
								 buttonType:UIButtonTypeDetailDisclosure 
									  frame:CGRectMake(270, 0, 40, 80) 
								 titleColor:nil
									 target:self 
								   selector:@selector(editLocation:) 
						   normalStateImage:nil 
						 selectedStateImage:nil];
	
	[self setEditing:YES animated:YES];
	//ILOG(@"WhatViewController loadView]\n");
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

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    [self refreshFrames];
    
}

-(void)refreshFrames{
    CGRect frame=[[UIScreen mainScreen] bounds];
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        contentView.frame=CGRectMake(0,0, frame.size.height, frame.size.width);
        if ([loctionTextView isFirstResponder] || isEditingLocation) {
            tableView.frame = CGRectMake(0,64, frame.size.height, 65);
        }else{
            tableView.frame = CGRectMake(0,64, frame.size.height, frame.size.width-64);
        }
        taskTitleEditField.frame=CGRectMake(15, 80, frame.size.height-30, 40);
        loctionTextView.frame=CGRectMake(20, 0, frame.size.height-70, 80);
        deleteButton.frame = CGRectMake(10, 70, 60, 30);
        doneButton.frame = CGRectMake(frame.size.height-70, 70, 60, 30);
        doneBarView.frame=CGRectMake(0, 65, frame.size.height, 40);
        editLocationButton.frame=CGRectMake(frame.size.height-50, 0+64, 40, 80);
        instrustion.frame=CGRectMake(20, 2, frame.size.height-40, 25);
    }else{
        contentView.frame=CGRectMake(0,0, frame.size.width, frame.size.height);
        if ([loctionTextView isFirstResponder] || isEditingLocation) {
            tableView.frame = CGRectMake(0,0+64, frame.size.width, 155);
        }else{
            tableView.frame = CGRectMake(0,0+64, frame.size.width, frame.size.height-64);
        }
        taskTitleEditField.frame=CGRectMake(15, 80, frame.size.width-30, 40);
        loctionTextView.frame=CGRectMake(20, 0, frame.size.width-70, 80);
        deleteButton.frame = CGRectMake(10, 165, 60, 30);
        doneButton.frame = CGRectMake(frame.size.width-70, 165, 60, 30);
        doneBarView.frame=CGRectMake(0, 160, frame.size.width, 40);
        editLocationButton.frame=CGRectMake(frame.size.width-50, 0, 40, 80);
        instrustion.frame=CGRectMake(20, 2, frame.size.width-40, 25);
    }
    
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 28;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
	return 2;
}

- (void)dealloc {
	
	[gotoButton removeFromSuperview];
	//[gotoButton release];
	
	[callButton removeFromSuperview];
	//[callButton release];
	
	[buyButton removeFromSuperview];
	//[buyButton release];

	[mailButton removeFromSuperview];
	//[mailButton release];
	
	[meetButton removeFromSuperview];
	//[meetButton release];
	
	[taskTitleEditField removeFromSuperview];
	taskTitleEditField.delegate=nil;
	[taskTitleEditField release];
	
	[taskContact release];
	
	[taskTitle release];
	
	[taskLocation release];
	
	[taskEmailToSend release];
	[phoneToContact release];
	
	[oldContact release];

	//[tableView removeFromSuperview];
	tableView.delegate=nil;
	tableView.dataSource=nil;
	//[tableView release];
	
	[editedObject release];
	editedObject=nil;
	[whatButtonGroup release];
	[instrustion release];
	
	loctionTextView.delegate=nil;
	[loctionTextView release];
	
	[editLocationButton release];
	//[contentView release];
	[super dealloc];
}

#pragma mark controller delegate
// called after this controller's view will appear
- (void)viewWillAppear:(BOOL)animated
{	
	//ILOG(@"[HistoryViewController viewWillAppear\n");
    
	[self refreshFrames];
	[self refreshTaskTitle:self.whatSelected];
	[tableView reloadData];
	
	//ILOG(@"HistoryViewController viewWillAppear]\n");
}

-(void)viewDidAppear:(BOOL)animated{
}

-(void)viewWillDisappear:(BOOL)animated{
	[self done:nil];	
}

#pragma mark -
#pragma mark <UITableViewDelegate, UITableViewDataSource> Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return NSLocalizedString(@"whatText", @"")/*whatText*/;//@"What";
			//return whatText;//@"What";
			break;
		case 1:
			return NSLocalizedString(@"whoText", @"")/*whoText*/;//@"Who";
			//return whoText;//@"Who";
			break;
		case 2:
			return NSLocalizedString(@"whereText", @"")/*whereText*/;//@"Where";
			//return whereText;//@"Where";
			break;
	}
	return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//ILOG(@"[SmartViewController cellForRowAtIndexPath\n");

	
	switch (indexPath.section) {
		case 0:
		{
			TableCellWhatTextTap *cell = (TableCellWhatTextTap *)[tableView dequeueReusableCellWithIdentifier:@"WWW1"];
			if (cell == nil) {
				cell = [[[TableCellWhatTextTap alloc] initWithFrame:CGRectZero reuseIdentifier:@"WWW1"] autorelease];
			}
			
			cell.selectionStyle=UITableViewCellSelectionStyleNone;

			if([instrustion superview])
				[instrustion removeFromSuperview];
			
			cell.instruction=instrustion;
			if([whatButtonGroup superview])
				[whatButtonGroup removeFromSuperview];
			
			cell.buttonView=whatButtonGroup;
			
			[self toggleWhatButton:self.whatSelected];
			
			taskTitleEditField.text=self.taskTitle;
			cell.editText=taskTitleEditField;
			
			return cell;
		}
			break;

		case 1:	
		{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WWW"];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"WWW"] autorelease];
			}
			
			cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
			
			cell.textLabel.text=self.taskContact;
			return cell;
		}
			break;
		case 2:
		{
			TableCellWhatLocation *cell = (TableCellWhatLocation *)[tableView dequeueReusableCellWithIdentifier:@"WWW2"];
			if (cell == nil) {
				cell = [[[TableCellWhatLocation alloc] initWithFrame:CGRectZero reuseIdentifier:@"WWW2"] autorelease];
			}
			
			if([loctionTextView superview]){
				[loctionTextView removeFromSuperview];
			}

			loctionTextView.text=self.taskLocation;

			cell.cellContent=loctionTextView;
			
			if([editLocationButton superview])
				[editLocationButton removeFromSuperview];
			
			cell.editLocationButton=editLocationButton;
			return cell;
		}
			break;

		default:
			
			break;
	}
	
	//ILOG(@"SmartViewController cellForRowAtIndexPath]\n");

	return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Never allow selection.
    if (self.editing) {
		return indexPath;
	}
    return nil;
}

/*
- (UITableViewCellAccessoryType)tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
		case 1:
			return UITableViewCellAccessoryDisclosureIndicator;
			break;
		default:
			return UITableViewCellAccessoryNone;
			break;	
	}
}
*/

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	//ILOG(@"[SmartViewController didSelectRowAtIndexPath\n");

	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	switch (newIndexPath.section) {
		case 1:
			[self editContact];
			break;
		case 2:
			//[self editLocation];
			break;
		default:
			break;
	}

	[table deselectRowAtIndexPath:newIndexPath animated:YES];
	App_Delegate.me.networkActivityIndicatorVisible=NO;
	
	//ILOG(@"SmartViewController didSelectRowAtIndexPath]\n");
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if(indexPath.section==0){
		return 130;
	}
	
	return 80;	
}


#pragma mark action methods

-(void)cleanWhere:(id)sender{
	loctionTextView.text=@"";
}

-(void)gotoButtonAction:(id)sender{
	//ILOG(@"[TaskDetailViewController gotoButtonAction\n");
	self.whatSelected=1;//Go
	[self refreshTaskTitle:self.whatSelected];
	[self toggleWhatButton:self.whatSelected];
	//ILOG(@"TaskDetailViewController gotoButtonAction]\n");
	
}

-(void)callButtonAction:(id)sender{
	//ILOG(@"[TaskDetailViewController callButtonAction\n");
	
	self.whatSelected=2;//Contact
	[self refreshTaskTitle:self.whatSelected];
	[self toggleWhatButton:self.whatSelected];
	//ILOG(@"TaskDetailViewController callButtonAction]\n");
}

-(void)buyButtonAction:(id)sender{
	//ILOG(@"[TaskDetailViewController buyButtonAction\n");
	self.whatSelected=3;//Get
	[self refreshTaskTitle:self.whatSelected];
	[self toggleWhatButton:self.whatSelected];
	//ILOG(@"TaskDetailViewController buyButtonAction]\n");
}

-(void)mailButtonAction:(id)sender{
	
	self.whatSelected=4;//Write mail
	[self refreshTaskTitle:self.whatSelected];
	[self toggleWhatButton:self.whatSelected];
}

-(void)meetButtonAction:(id)sender{
	//ILOG(@"[TaskDetailViewController meetButtonAction\n");
	self.whatSelected=5;//Meet
	[self refreshTaskTitle:self.whatSelected];
	[self toggleWhatButton:self.whatSelected];
	//ILOG(@"TaskDetailViewController meetButtonAction]\n");
}

-(void)editContact{
	
	//ILOG(@"[TaskDetailViewController editWho\n");
	//if(contactList.count>0){
		//Trung 08101002
		/*
		if(contactView==nil){
			contactView=[[ContactViewConroller alloc] init];	
		}
		 */
		App_Delegate.me.networkActivityIndicatorVisible=YES;
/*		ContactViewConroller *contactView=[[ContactViewConroller alloc] init];	
		contactView.editedObject=self;
		contactView.selectedContact=self.taskContact;
		contactView.oldSelectedIndex=nil;
		[contactView setEditing:YES animated:YES];
		[self.navigationController pushViewController:contactView animated:YES];
		//Trung 08101002
		[contactView release];
*/
	ABPeoplePickerNavigationController *contactList=[[ABPeoplePickerNavigationController alloc] init];
	contactList.peoplePickerDelegate = self;
	[self presentModalViewController:contactList animated:YES];
	[contactList release];
	
	App_Delegate.me.networkActivityIndicatorVisible=NO;
	
	//}else {
		//show alert message here
	//}	
	//ILOG(@"TaskDetailViewController editWho]\n");
}

-(void)editLocation:(id)sender {
	//ILOG(@"[InfoEditViewController editLocation\n");
		App_Delegate.me.networkActivityIndicatorVisible=YES;
	
		LocationViewController *locationViewController=[[LocationViewController alloc] init];	
	
		locationViewController.oldSelectedIndex=nil;
		locationViewController.editedObject=self;
		[locationViewController setEditing:YES animated:YES];
		[self.navigationController pushViewController:locationViewController animated:YES];
		
		//Trung 08101002
		[locationViewController release];
		App_Delegate.me.networkActivityIndicatorVisible=NO;
	//ILOG(@"InfoEditViewController editLocation]\n");
}

-(void)save:(id)sender{
	//if([taskTitleEditField isFirstResponder])
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	[taskTitleEditField resignFirstResponder];
	[self.editedObject setTaskName:self.taskTitle];
	[self.editedObject setTaskContact:self.taskContact];
	//[self.editedObject setTaskLocation:self.taskLocation];
	[self.editedObject setTaskLocation:loctionTextView.text];
	[self.editedObject setTaskWhat:self.whatSelected];
	[self.editedObject setTaskEmailToSend:self.taskEmailToSend];
	[self.editedObject setTaskPhoneToCall:self.phoneToContact];
	
	[self.navigationController popViewControllerAnimated:YES];
	App_Delegate.me.networkActivityIndicatorVisible=NO;
}

-(void)done:(id)sender{
    //CGRect frame=[[UIScreen mainScreen] bounds];
    isEditingLocation=NO;
	[loctionTextView resignFirstResponder];
	//tableView.scrollEnabled=YES;
	//tableView.frame=CGRectMake(0,5, 320, frame.size.height-70);
	//[tableView reloadData];
    //[self refreshFrames];
}

#pragma mark common methods
-(void)toggleWhatButton:(NSInteger)buttonNo {
	//ILOG(@"[TaskDetailViewController toggleWhatButton\n");
	if(buttonNo==1){
		gotoButton.selected=YES;	
	}else {
		gotoButton.selected=NO;
	}
	
	if(buttonNo==2){
		callButton.selected=YES;	
	}else {
		callButton.selected=NO;	
	}
	
	if(buttonNo==3){
		buyButton.selected=YES;
	}else {
		buyButton.selected=NO;	
	}
	
	if(buttonNo==4){
		mailButton.selected=YES;	
	}else {
		mailButton.selected=NO;	
	}
	
	if(buttonNo==5){
		meetButton.selected=YES;	
	}else {
		meetButton.selected=NO;	
	}
	//ILOG(@"TaskDetailViewController toggleWhatButton]\n");
}

-(void)refreshTaskTitle:(NSInteger)whatIconNo{
	//ILOG(@"[TaskDetailViewController refreshTaskTitle\n");
	switch (whatIconNo) {
		case 1:
			
			if(self.taskContact != nil && ![self.taskContact isEqual:@""]){
				self.taskTitle=[NSLocalizedString(@"gotoText", @"")/*gotoText*/ stringByAppendingString:self.taskContact];
			}else {
				self.taskTitle= NSLocalizedString(@"gotoText", @"")/*gotoText*/;
			}
			
			break;
		case 2:
			if(self.taskContact != nil && ![self.taskContact isEqual:@""]){
				self.taskTitle=[NSLocalizedString(@"contactText", @"")/*contactText*/ stringByAppendingString:self.taskContact];
			}else {
				self.taskTitle=NSLocalizedString(@"contactText", @"")/*contactText*/;
			}
			
			break;
		case 3:
			if(self.taskContact != nil && ![self.taskContact isEqual:@""]){
				self.taskTitle=[NSLocalizedString(@"getText", @"")/*getText*/ stringByAppendingString:self.taskContact];
			}else {
				self.taskTitle=NSLocalizedString(@"getText", @"")/*getText*/;
			}
			
			break;
		case 4:
			if(self.taskContact != nil && ![self.taskContact isEqual:@""]){
				self.taskTitle=[NSLocalizedString(@"writeToText", @"")/*writeToText*/ stringByAppendingString:self.taskContact];
			}else {
				self.taskTitle=NSLocalizedString(@"writeToText", @"")/*writeToText*/;
			}
			
			break;
		case 5:
			if(self.taskContact != nil && ![self.taskContact isEqual:@""]){
				self.taskTitle=[NSLocalizedString(@"meetText", @"")/*meetText*/ stringByAppendingString:self.taskContact];
			}else {
				self.taskTitle=NSLocalizedString(@"meetText", @"")/*meetText*/;
			}
			
			break;
			
		default:
			
			break;
	}	
	taskTitleEditField.text=self.taskTitle;
	//ILOG(@"TaskDetailViewController refreshTaskTitle]\n");
}

#pragma mark TextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
	[taskTitleEditField resignFirstResponder];
    [self refreshFrames];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
	[self refreshFrames];
	if(self.oldContact !=nil){
		NSRange searchContactInTitle;
		searchContactInTitle=[textField.text rangeOfString:self.oldContact];
		if(searchContactInTitle.location==NSNotFound){
			self.taskContact=@"";
			self.whatSelected=-1;
			[self toggleWhatButton:-1];
			[[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]].textLabel setText:@""];
		}
	}
	self.taskTitle=textField.text;	
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
	self.oldContact=textField.text;
    [self refreshFrames];

	return YES;
}

#pragma mark textView delegate 
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    //[textView becomeFirstResponder];
    isEditingLocation=YES;
	//CGRect frm=CGRectMake(0, 5, 320, 155);
	//tableView.frame=frm;
	//[tableView scrollRectToVisible:CGRectMake(240, 415, 60, 30) animated:YES];
    [self refreshFrames];
    //CGRect rect=[tableView rectForSection:2];
	[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    //[tableView scrollRectToVisible:rect animated:YES];
    //[textView becomeFirstResponder];
	return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
	self.taskLocation=textView.text;
    isEditingLocation=NO;
    [self refreshFrames];
    
}

#pragma mark ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker 
{
	[peoplePicker dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker 
      shouldContinueAfterSelectingPerson:(ABRecordRef)person 
{
	CFStringRef firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
	CFStringRef lastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
	CFStringRef company = ABRecordCopyValue(person, kABPersonOrganizationProperty);
	
	if (firstName==nil && lastName==nil && company==nil){
		firstName=(CFStringRef)NSLocalizedString(@"nonameText", @"")/*nonameText*/;
		lastName=(CFStringRef)@" ";
		company=(CFStringRef)@" ";
	}else{
		if(firstName==nil) {
			firstName=(CFStringRef) @" ";
		}
		if(lastName==nil){
			lastName=(CFStringRef)@" ";
		}
		if(company==nil){
			company=(CFStringRef)@" ";
		}
		
	}
	
	NSString *contactName=[NSString stringWithFormat:@"%@ %@",firstName, lastName];
	contactName=[contactName stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];//remove new line character;
	contactName=[contactName stringByReplacingOccurrencesOfString:@"\n" withString:@" "];//remove new line character;
	contactName=[contactName stringByReplacingOccurrencesOfString:@"\r" withString:@" "];//remove new line character;
	
	NSString *contactComName=[NSString stringWithFormat:@"%@",company];
	contactComName=[contactComName stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];//remove new line character;
	contactComName=[contactComName stringByReplacingOccurrencesOfString:@"\n" withString:@" "];//remove new line character;
	contactComName=[contactComName stringByReplacingOccurrencesOfString:@"\r" withString:@" "];//remove new line character;
		
	if ([[contactName stringByReplacingOccurrencesOfString:@" " withString:@""] length]==0) {
		contactName=contactComName;
	}
	
	self.taskContact=contactName;
	
	//get PHONE NUMBER from contact
	NSString *phoneNumber=@"";
	ABMutableMultiValueRef phoneEmailValue = ABRecordCopyValue(person, kABPersonPhoneProperty);
	if(ABMultiValueGetCount(phoneEmailValue)>0){
		phoneNumber=@"";
		
		for(NSInteger i=0;i<ABMultiValueGetCount(phoneEmailValue);i++){
			CFStringRef phoneNo = ABMultiValueCopyValueAtIndex(phoneEmailValue, i);
			CFStringRef label=ABMultiValueCopyLabelAtIndex(phoneEmailValue, i);
			
			if(label==nil){
				label=(CFStringRef)@" ";	
			}
			
			if(phoneNo==nil){
				phoneNo=(CFStringRef)@" ";	
			}
			phoneNumber=[phoneNumber stringByAppendingFormat:@"/%@|%@",label,phoneNo];
		}
		
	}
	CFRelease(phoneEmailValue);
	self.phoneToContact=phoneNumber;
	
	NSString *contactAddress=nil;
	//get first address for this contact
	ABMutableMultiValueRef multiValue = ABRecordCopyValue(person, kABPersonAddressProperty);
	
	if(ABMultiValueGetCount(multiValue)>0){
		
		//get all address from the contact
		CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(multiValue, 0);
		CFStringRef street = CFDictionaryGetValue(dict, kABPersonAddressStreetKey);
		CFStringRef city = CFDictionaryGetValue(dict, kABPersonAddressCityKey);
		CFStringRef country = CFDictionaryGetValue(dict, kABPersonAddressCountryKey);		
		CFStringRef state = CFDictionaryGetValue(dict,kABPersonAddressStateKey);
		CFStringRef zip = CFDictionaryGetValue(dict,kABPersonAddressZIPKey);
		
		CFRelease(dict);
		
		if(street!=nil){
			contactAddress=[NSString stringWithFormat:@"%@",street];
		}else {
			contactAddress=[NSString stringWithString: @""];
		}
		
		if(city!=nil){
			if(street!=nil){
				NSString *cityNameAppend=[NSString stringWithFormat:@", %@",city];
				contactAddress=[contactAddress stringByAppendingString:cityNameAppend];
			}else{
				NSString *cityNameAsLoc=[NSString stringWithFormat:@"%@",city];
				contactAddress=[contactAddress stringByAppendingString:cityNameAsLoc];
			}
		}
		
		if(country!=nil){
			if(![contactAddress isEqualToString:@""]){
				NSString *countryNameAppend=[NSString stringWithFormat:@", %@",country];
				contactAddress=[contactAddress stringByAppendingString:countryNameAppend];
			}else{
				NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",country];
				contactAddress=[contactAddress stringByAppendingString:countryNameAsLoc];
			}
		}
		
		if(state !=nil){
			if(![contactAddress isEqualToString:@""]){
				NSString *countryNameAppend=[NSString stringWithFormat:@", %@",state];
				contactAddress=[contactAddress stringByAppendingString:countryNameAppend];
			}else{
				NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",state];
				contactAddress=[contactAddress stringByAppendingString:countryNameAsLoc];
			}
		}
		
		if(zip !=nil){
			if(![contactAddress isEqualToString:@""]){
				NSString *countryNameAppend=[NSString stringWithFormat:@", %@",zip];
				contactAddress=[contactAddress stringByAppendingString:countryNameAppend];
			}else{
				NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",zip];
				contactAddress=[contactAddress stringByAppendingString:countryNameAsLoc];
			}
		}
		
	}else {
		contactAddress=@"";
	}
	
	contactAddress=[contactAddress stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];//remove the newline character
	contactAddress=[contactAddress stringByReplacingOccurrencesOfString:@"\n" withString:@" "];//remove new line character;
	contactAddress=[contactAddress stringByReplacingOccurrencesOfString:@"\r" withString:@" "];//remove new line character;
	
	CFRelease(multiValue);
	
	self.taskLocation=contactAddress;
	
	//get email address from contact
	NSString *emailAddress=@"";
	ABMutableMultiValueRef multiEmailValue = ABRecordCopyValue(person, kABPersonEmailProperty);
	if(ABMultiValueGetCount(multiEmailValue)>0){
		CFStringRef emailAddr = ABMultiValueCopyValueAtIndex(multiEmailValue, 0);
		
		if(emailAddr==nil){
			emailAddr=(CFStringRef)@" ";	
		}
		emailAddress=[NSString stringWithFormat:@"%@",emailAddr];
	}
	CFRelease(multiEmailValue);
	self.taskEmailToSend=emailAddress;
	
	// remove the controller
	[self dismissModalViewControllerAnimated:YES];

    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker 
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property 
							  identifier:(ABMultiValueIdentifier)identifier{
	return NO;
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person
{
    CFStringRef firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    CFStringRef lastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
    CFStringRef company = ABRecordCopyValue(person, kABPersonOrganizationProperty);
    
    if (firstName==nil && lastName==nil && company==nil){
        firstName=(CFStringRef)NSLocalizedString(@"nonameText", @"")/*nonameText*/;
        lastName=(CFStringRef)@" ";
        company=(CFStringRef)@" ";
    }else{
        if(firstName==nil) {
            firstName=(CFStringRef) @" ";
        }
        if(lastName==nil){
            lastName=(CFStringRef)@" ";
        }
        if(company==nil){
            company=(CFStringRef)@" ";
        }
        
    }
    
    NSString *contactName=[NSString stringWithFormat:@"%@ %@",firstName, lastName];
    contactName=[contactName stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];//remove new line character;
    contactName=[contactName stringByReplacingOccurrencesOfString:@"\n" withString:@" "];//remove new line character;
    contactName=[contactName stringByReplacingOccurrencesOfString:@"\r" withString:@" "];//remove new line character;
    
    NSString *contactComName=[NSString stringWithFormat:@"%@",company];
    contactComName=[contactComName stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];//remove new line character;
    contactComName=[contactComName stringByReplacingOccurrencesOfString:@"\n" withString:@" "];//remove new line character;
    contactComName=[contactComName stringByReplacingOccurrencesOfString:@"\r" withString:@" "];//remove new line character;
    
    if ([[contactName stringByReplacingOccurrencesOfString:@" " withString:@""] length]==0) {
        contactName=contactComName;
    }
    
    self.taskContact=contactName;
    
    //get PHONE NUMBER from contact
    NSString *phoneNumber=@"";
    ABMutableMultiValueRef phoneEmailValue = ABRecordCopyValue(person, kABPersonPhoneProperty);
    if(ABMultiValueGetCount(phoneEmailValue)>0){
        phoneNumber=@"";
        
        for(NSInteger i=0;i<ABMultiValueGetCount(phoneEmailValue);i++){
            CFStringRef phoneNo = ABMultiValueCopyValueAtIndex(phoneEmailValue, i);
            CFStringRef label=ABMultiValueCopyLabelAtIndex(phoneEmailValue, i);
            
            if(label==nil){
                label=(CFStringRef)@" ";
            }
            
            if(phoneNo==nil){
                phoneNo=(CFStringRef)@" ";
            }
            phoneNumber=[phoneNumber stringByAppendingFormat:@"/%@|%@",label,phoneNo];
        }
        
    }
    CFRelease(phoneEmailValue);
    self.phoneToContact=phoneNumber;
    
    NSString *contactAddress=nil;
    //get first address for this contact
    ABMutableMultiValueRef multiValue = ABRecordCopyValue(person, kABPersonAddressProperty);
    
    if(ABMultiValueGetCount(multiValue)>0){
        
        //get all address from the contact
        CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(multiValue, 0);
        CFStringRef street = CFDictionaryGetValue(dict, kABPersonAddressStreetKey);
        CFStringRef city = CFDictionaryGetValue(dict, kABPersonAddressCityKey);
        CFStringRef country = CFDictionaryGetValue(dict, kABPersonAddressCountryKey);
        CFStringRef state = CFDictionaryGetValue(dict,kABPersonAddressStateKey);
        CFStringRef zip = CFDictionaryGetValue(dict,kABPersonAddressZIPKey);
        
        CFRelease(dict);
        
        if(street!=nil){
            contactAddress=[NSString stringWithFormat:@"%@",street];
        }else {
            contactAddress=[NSString stringWithString: @""];
        }
        
        if(city!=nil){
            if(street!=nil){
                NSString *cityNameAppend=[NSString stringWithFormat:@", %@",city];
                contactAddress=[contactAddress stringByAppendingString:cityNameAppend];
            }else{
                NSString *cityNameAsLoc=[NSString stringWithFormat:@"%@",city];
                contactAddress=[contactAddress stringByAppendingString:cityNameAsLoc];
            }
        }
        
        if(country!=nil){
            if(![contactAddress isEqualToString:@""]){
                NSString *countryNameAppend=[NSString stringWithFormat:@", %@",country];
                contactAddress=[contactAddress stringByAppendingString:countryNameAppend];
            }else{
                NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",country];
                contactAddress=[contactAddress stringByAppendingString:countryNameAsLoc];
            }
        }
        
        if(state !=nil){
            if(![contactAddress isEqualToString:@""]){
                NSString *countryNameAppend=[NSString stringWithFormat:@", %@",state];
                contactAddress=[contactAddress stringByAppendingString:countryNameAppend];
            }else{
                NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",state];
                contactAddress=[contactAddress stringByAppendingString:countryNameAsLoc];
            }
        }
        
        if(zip !=nil){
            if(![contactAddress isEqualToString:@""]){
                NSString *countryNameAppend=[NSString stringWithFormat:@", %@",zip];
                contactAddress=[contactAddress stringByAppendingString:countryNameAppend];
            }else{
                NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",zip];
                contactAddress=[contactAddress stringByAppendingString:countryNameAsLoc];
            }
        }
        
    }else {
        contactAddress=@"";
    }
    
    contactAddress=[contactAddress stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];//remove the newline character
    contactAddress=[contactAddress stringByReplacingOccurrencesOfString:@"\n" withString:@" "];//remove new line character;
    contactAddress=[contactAddress stringByReplacingOccurrencesOfString:@"\r" withString:@" "];//remove new line character;
    
    CFRelease(multiValue);
    
    self.taskLocation=contactAddress;
    
    //get email address from contact
    NSString *emailAddress=@"";
    ABMutableMultiValueRef multiEmailValue = ABRecordCopyValue(person, kABPersonEmailProperty);
    if(ABMultiValueGetCount(multiEmailValue)>0){
        CFStringRef emailAddr = ABMultiValueCopyValueAtIndex(multiEmailValue, 0);
        
        if(emailAddr==nil){
            emailAddr=(CFStringRef)@" ";
        }
        emailAddress=[NSString stringWithFormat:@"%@",emailAddr];
    }
    CFRelease(multiEmailValue);
    self.taskEmailToSend=emailAddress;
    
    // remove the controller
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark properties
-(NSString *)taskContact{
	return taskContact;
}

-(void)setTaskContact:(NSString *)aString{
	[taskContact release];
	taskContact=[aString copy];
}

-(NSString *)taskTitle{
	return taskTitle;
}

-(void)setTaskTitle:(NSString *)aString{
	[taskTitle release];
	taskTitle=[aString copy];
}

-(NSString *)taskLocation{
	return taskLocation;
}

-(void)setTaskLocation:(NSString *)aString{
	[taskLocation release];
	taskLocation=[aString copy];
}

-(NSString *)oldContact{
	return oldContact;
}

-(void)setOldContact:(NSString *)aString{
	[oldContact release];
	oldContact=[aString copy];
}

-(NSString *)taskEmailToSend{
	return taskEmailToSend;
}

-(void)setTaskEmailToSend:(NSString *)aString{
	[taskEmailToSend release];
	taskEmailToSend=[aString copy];
}




-(NSString *)phoneToContact{
	return phoneToContact;
}

-(void)setPhoneToContact:(NSString *)aString{
	[phoneToContact release];
	phoneToContact=[aString copy];
}

-(NSInteger)whatSelected{
	return whatSelected;
}

-(void)setWhatSelected:(NSInteger)anum{
	whatSelected=anum;	
}
@end
