//
//  WyswigEdit.m
//  iVo_NewAddTask
//
//  Created by Nang Le on 5/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "InfoEditViewController.h"
#import "ivo_Utilities.h"
#import "IvoCommon.h"
#import "Setting.h"
#import "Projects.h"
#import "Task.h"
#import "SmartTimeAppDelegate.h"
#import "LocationViewController.h"
#import "TimeSettingViewController.h"
#import "TaskManager.h"
#import "Colors.h"

//extern Setting			*currentSetting;
extern NSMutableArray	*locationList;
extern NSArray			*contactList;
extern ivo_Utilities	*ivoUtility;
extern TaskManager		*taskmanager;
extern NSMutableArray	*originalGCalList;
extern NSMutableArray	*projectList;

#define GROW_ANIMATION_DURATION_SECONDS 0.15 
#define SHRINK_ANIMATION_DURATION_SECONDS 0.15 

@implementation InfoEditViewController
@synthesize editedObject;
@synthesize keyEdit,pathIndex,gCalList,usedGcalsList,secondKeyEdit;

/*
 This method is not invoked if the controller is restored from a nib file.
 All relevant configuration should have been performed in Interface Builder.
 If you need to do additional setup after loading from a nib, override -loadView.
*/
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
		self.title = NSLocalizedString(@"WyswigEdit", @"WyswigEdit title");
	}
	return self;
}
*/

- (id)init {
	
	// Set self's frame to encompass the image
	if (self = [super init]) {
		//self.title =@"Task Editing";
	}
	return self;
}

- (void)setNavTitle:(NSString *)aString{
	self.title=aString;
}

- (void)loadView {
	//ILOG(@"[InfoEditViewController loadView\n");
	// Add navigation item buttons.
    
    CGRect frame=[[UIScreen mainScreen] bounds];
    
	saveButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
															  target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = saveButton;
	self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;

	contentView=[[UIView alloc] initWithFrame:CGRectZero];
	contentView.backgroundColor=[UIColor groupTableViewBackgroundColor];
	
	CGRect textFieldFrame = CGRectMake(10, 20+64, 300, 35);
	textField=[[UITextField alloc] initWithFrame:textFieldFrame];
	textField.borderStyle=UITextBorderStyleRoundedRect;
	textField.returnKeyType = UIReturnKeyDefault;
	textField.font=[UIFont systemFontOfSize:20];
	textField.clearButtonMode=UITextFieldViewModeWhileEditing;
	textField.delegate=self;
	[contentView addSubview:textField];
	
	editTextView=[[UITextView alloc] initWithFrame:CGRectMake(10, 20+64, 300, 160)];
	editTextView.delegate=self;
	editTextView.backgroundColor=[UIColor clearColor];
	editTextView.keyboardType=UIKeyboardTypeDefault;
	editTextView.font=[UIFont systemFontOfSize:18];
	//editTextView.hidden=YES;
	//[contentView addSubview:editTextView];
	
	REInstruction=[[UILabel alloc] initWithFrame:CGRectMake(10, 55+64, 300, 70)];
	REInstruction.text=NSLocalizedString(@"RETimesEditText", @"")/*RETimesEditText*/;
	REInstruction.backgroundColor=[UIColor clearColor];
	REInstruction.textColor=[UIColor darkGrayColor];
	//REInstruction.textAlignment=NSTextAlignmentCenter;
	REInstruction.numberOfLines=0;
	REInstruction.hidden=YES;
	[contentView addSubview:REInstruction];
	
	
	dayUnit=[[UILabel alloc] initWithFrame:CGRectMake(10, 60+64, 300, 30)];
	dayUnit.text=NSLocalizedString(@"dayUnitText", @"")/*dayUnitText*/;
	dayUnit.backgroundColor=[UIColor clearColor];
	dayUnit.textAlignment=NSTextAlignmentCenter;
	dayUnit.hidden=YES;
	[contentView addSubview:dayUnit];
	
	tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 65+64, 320,frame.size.height-135) style:UITableViewStyleGrouped];
	tableView.sectionHeaderHeight=20;
	tableView.sectionFooterHeight=0;
    tableView.delegate = self;
    tableView.dataSource = self;
	tableView.hidden=YES;	
	
	[contentView addSubview:tableView];
	//[tableView release];
	
	doneButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	doneButton.frame = CGRectMake(250, 165+64, 60, 30);
	doneButton.alpha=1;
	[doneButton setTitle:NSLocalizedString(@"doneButtonText", @"")/*doneButtonText*/ forState:UIControlStateNormal];
	doneButton.titleLabel.font=[UIFont systemFontOfSize:14];
	[doneButton setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];		
	[doneButton setBackgroundImage:[UIImage imageNamed:@"blue-small.png"] forState:UIControlStateNormal];
	
	[doneButton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
	
	doneBarView=[[UIView alloc] initWithFrame:CGRectMake(0, 160+64, 320, 40)];
	doneBarView.backgroundColor=[UIColor viewFlipsideBackgroundColor];
	doneBarView.alpha=0.3;
	[contentView addSubview:doneBarView];
	[contentView addSubview:doneButton];
	[doneBarView release];

	doneBarView.hidden=YES;
	doneButton.hidden=YES;
	self.view=contentView;	
	[self setEditing:YES animated:NO];
	
	//ILOG(@"InfoEditViewController loadView]\n");
	
}

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
	
}


- (void)dealloc {	
	[textField removeFromSuperview];
	textField.delegate=nil;
	[textField release];
	
	[tableView removeFromSuperview];
	tableView.delegate=nil;
	tableView.dataSource=nil;
	[tableView release];
	
	[textValue release];
	[saveButton release];
	[contentView release];
	[REInstruction release];
	[dayUnit release];
	
	[locationInfo removeFromSuperview];
	[locationInfo release];
	
	[selectedLocation release];

//Trung 08101002
	[editedObject release];
	editedObject=nil;
	
	editTextView.delegate=nil;
	[editTextView release];
	[super dealloc];
	
}

#pragma mark controller delegate
- (void)viewWillAppear:(BOOL)animated {
	//ILOG(@"[InfoEditViewController viewWillAppear\n");
	
	//NSMutableArray *tmp=[[NSMutableArray alloc] init];
	//[tmp addObject:@"ST Event1"];
	//[tmp addObject:@"ST Event2"];
	//[tmp addObject:@"ST Task1"];
	//[tmp addObject:@"ST Task2"];			
	//originalGCalList=tmp;
	
	[self refreshTitleBarName];
	
	//howLongIconView.hidden=YES;
	REInstruction.hidden=YES;
	dayUnit.hidden=YES;
	textField.placeholder=@"";
	self.pathIndex=-1;
	
	tableView.hidden=YES;
	if([editTextView subviews]){
		[editTextView removeFromSuperview];
	}
	
	CGRect tFFrm= CGRectMake(10, 20+64, 300, 35);
	textField.frame=tFFrm;
	
	switch (self.keyEdit) {
		case SETTING_HOWLONG:{
			textField.keyboardType=UIKeyboardTypeNumberPad;
			textField.text =[NSString stringWithFormat:@"%d", [self.editedObject howlongDefVal]/60];
			//howLongIconView.hidden=NO;
			REInstruction.hidden=NO;
		}
			break;
		case SETTING_TIMESREPEAT:{
			textField.keyboardType=UIKeyboardTypeNumberPad;
            textField.text =[NSString stringWithFormat:@"%ld", (long)[self.editedObject endRepeatCount]];
		}
			break;
		case SETTING_ENDDUEDAYS:{
		//	textField.keyboardType=UIKeyboardTypeNumberPad;
		//	textField.text =[NSString stringWithFormat:@"%d", [self.editedObject expiredBetaTestDate]];
		}
			break;
		case SETTING_CLEANOLDDATA:{
			dayUnit.hidden=NO;
			textField.keyboardType=UIKeyboardTypeNumberPad;
			textField.text =[NSString stringWithFormat:@"%d", [self.editedObject cleanOldDayCount]];
		}
			break;
		case SETTING_PROJECTEDIT:{
			textField.keyboardType=UIKeyboardTypeDefault;
			textField.text=[self.editedObject projName];
		}
			break;
		case SETTING_GCALPROJMAP:{
			/*v5			
			tableView.hidden=NO;
			[tableView reloadData];
			textField.keyboardType=UIKeyboardTypeDefault;
			textField.placeholder=(taskmanager.currentSettingModifying.syncType == 1?NSLocalizedString(@"tapToEnterCalNameText", @""):NSLocalizedString(@"unMapGCalText", @""));
			switch (self.secondKeyEdit) {
				case SETTING_PROGCALEVENTMAP:
					textField.text=[self.editedObject mapToGCalNameForEvent];
					break;
				case SETTING_PROGCALTASKMAP:
					textField.text=[self.editedObject mapToGCalNameForTask];
					break;
			}
			
			[textField resignFirstResponder];
             */
		}
			break;
		case TASK_EDITTITLE:{
			textField.keyboardType=UIKeyboardTypeDefault;
			self.textValue=[self.editedObject taskName];
			textField.text=[self.editedObject taskName];
		}
			break;
		case TASK_EDITNOTES:{
			//textField.keyboardType=UIKeyboardTypeDefault;
			//textField.text=[self.editedObject taskDescription];
			textField.frame=editTextView.frame;
			editTextView.text=[self.editedObject taskDescription];
			[contentView addSubview:editTextView];
		}
			break;
		case TASK_EDITHOWLONG:{
			textField.keyboardType=UIKeyboardTypeNumberPad;
			textField.text =[NSString stringWithFormat:@"%d", [self.editedObject taskHowLong]/60];
		}
			break;
		case TIMER_EDITREPEATTIMES:{
			REInstruction.hidden=NO;
			
			textField.keyboardType=UIKeyboardTypeNumberPad;
			textField.text =[NSString stringWithFormat:@"%d", [self.editedObject cellContent3IntVal]];
			
			UIButton *nerverEndButton= [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain]; 
			nerverEndButton.frame=CGRectMake(10, 140+64, 300, 40);
			nerverEndButton.titleLabel.font=[UIFont boldSystemFontOfSize:20];
			[nerverEndButton setTitle:NSLocalizedString(@"repeatForeverText", @"")/*repeatForeverText*/ forState:UIControlStateNormal];
			[nerverEndButton addTarget:self action:@selector(setRepeatForever:) forControlEvents:UIControlEventTouchUpInside];
			[self.view addSubview:nerverEndButton];
			[nerverEndButton release];
		}
			break;
	}
	//ILOG(@"InfoEditViewController viewWillAppear]\n");
}

- (void)viewDidAppear:(BOOL)animated {	
	//[textField becomeFirstResponder];
	switch (self.keyEdit) {
		case TASK_EDITNOTES:
			[editTextView becomeFirstResponder];
			break;
		default:
			break;
	}
	
}

- (void)viewDidLoad{
	[super viewDidLoad];
	switch (self.keyEdit) {
		case TASK_EDITNOTES:
			break;
		case SETTING_GCALPROJMAP:
			break;
	
		default:
			[textField becomeFirstResponder];
			break;
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	//ILOG(@"[InfoEditViewController viewWillDisappear\n");
	// Configure the animation.
	
	self.textValue=textField.text;

	[textField resignFirstResponder];
	[editTextView resignFirstResponder];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	[UIView commitAnimations];
	//ILOG(@"InfoEditViewController viewWillDisappear]\n");
}

#pragma mark action methods
-(void)setRepeatForever:(id)sender{
	textField.text=@"0";
	[self save:nil];
}

-(void)done:(id)sender{
	[textField resignFirstResponder];
	[tableView reloadData];
}

- (void)save:(id)sender {
	//ILOG(@"[InfoEditViewController save\n");
	NSString *textFieldValue=[textField.text copy];
	
	switch (self.keyEdit) {
		case SETTING_HOWLONG:	
			//if([textField.text intValue]*60 > 86400){
			//	[self.editedObject setHowlongDefVal:86400];
			//}else if([textField.text intValue]*60<=0){
				//if user set an overload integer number or negative number, get default as 1'
			//	[self.editedObject setHowlongDefVal:60];
			//}else {
			//	[self.editedObject setHowlongDefVal:[textFieldValue intValue]*60];
			//}
			break;
		case SETTING_TIMESREPEAT:		
			if([textField.text intValue]<1){
				//if user set an overload integer number or negative number, get default as 0 times
				[self.editedObject setEndRepeatCount:1];
			}else {
				[self.editedObject setEndRepeatCount:[textFieldValue intValue]];
			}
			break;
		case SETTING_ENDDUEDAYS:
/*			if([textField.text intValue]<1){
				//if user set an overload integer number or negative number, get default as 1 day
				[self.editedObject setEndDueCount:1];
			}else {
				[self.editedObject setEndDueCount:[textFieldValue intValue]];
			}
*/			
			break;
		case SETTING_PROJECTEDIT:
			[self.editedObject setProjName:textFieldValue];
			break;
			
		case SETTING_GCALPROJMAP:
		{
			//check if duplicate
/*v5			for (NSInteger i=0;i<self.usedGcalsList.count;i++){
				if(![textField.text isEqualToString:@""] && [textField.text isEqualToString:[self.usedGcalsList objectAtIndex:i]]){
					UIAlertView *alertError=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mapGCalToProjectErrorTitleText", @"")
																	   message:NSLocalizedString(@"mapGCalToProjectErrorMEssageText", @"")
																	  delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"")
															 otherButtonTitles:nil];
					[alertError show];
					[alertError release];
					return;
				}
			}
*/ 
			switch (self.secondKeyEdit) {
				case SETTING_PROGCALEVENTMAP:
					[self.editedObject setMapToGCalNameForEvent:textFieldValue];	
					break;
				case SETTING_PROGCALTASKMAP:
					[self.editedObject setMapToGCalNameForTask:textFieldValue];	
					break;
			}
		}
			break;

		case TASK_EDITTITLE:
			if(![textField.text isEqual:textFieldValue]){
				[self.editedObject setTaskName:textFieldValue];
				[self.editedObject setTaskWhat:-1];
				[self.editedObject setTaskContact:@""];
			}
			break;
		case TASK_EDITNOTES:
			[self.editedObject setTaskDescription:editTextView.text];
			break;
		case TASK_EDITHOWLONG:
			//if([textField.text intValue]*60 > 86400){
			//	[self.editedObject setTaskHowLong:86400];
			//}else if([textField.text intValue]*60<1){
			//	//if user set an overload integer number or negative number, get default as 1'
			//	[self.editedObject setTaskHowLong:60];
			//}else {
			//	[self.editedObject setTaskHowLong:[textFieldValue intValue]*60];
			//}
			break;
		case TIMER_EDITREPEATTIMES:		
		{
			double repeatTimes=	[textField.text doubleValue];
			if(repeatTimes>999) repeatTimes=999;
			
			Task *tmp=[taskmanager getParentRE:[editedObject editedObject] inList:taskmanager.taskList];
			if(tmp && tmp.primaryKey==[[editedObject editedObject] primaryKey]){
				tmp=nil;	
			}
			
			if(repeatTimes<0){
				//if user set an overload integer number or negative number, get default as 0 times
				[self.editedObject setCellContent3IntVal:0];
			}else {
				[self.editedObject setCellContent3IntVal:repeatTimes];
				NSDate *newEndRepeaDate=[ivoUtility createEndRepeatDateFromCount:(tmp)? tmp.taskEndTime:[editedObject cellContent1Val]
																	  typeRepeat:[self.editedObject cellContent2IntVal] 
																	 repeatCount:repeatTimes 
																	 repeatOptionsStr:[editedObject repeatOptions]];
				[self.editedObject setCellContent3Val:newEndRepeaDate];
				[newEndRepeaDate release];
			}
		}
			break;
		case SETTING_CLEANOLDDATA:
			if([textField.text intValue]>99999){
				[self.editedObject setCleanOldDayCount:99999];
			}else if([textField.text intValue]<0){
				//if user set an overload integer number or negative number, get default as 0 times
				[self.editedObject setCleanOldDayCount:0];
			}else {
				[self.editedObject setCleanOldDayCount:[textFieldValue intValue]];
			}
			break;
		
			
	}

	[textFieldValue release];
	
    [self.navigationController popViewControllerAnimated:YES];
	//ILOG(@"InfoEditViewController save]\n");
 }

#pragma mark common uses

-(void)setupGCalList{
	NSMutableArray *ret;//=[[NSMutableArray alloc] init];
	NSMutableArray *orgList=[[NSMutableArray alloc] initWithArray:originalGCalList copyItems:YES];
	
//	for (NSInteger i=0;i<projectList.count;i++){
	 
		//get task and event project name for comparing
		//NSString *taskNameCal=[[[projectList objectAtIndex:i] projName] stringByAppendingString:@" Tasks"];
		//NSString *eventNameCal=[[[projectList objectAtIndex:i] projName] stringByAppendingString:@" Events"];
	 
		/*
		printf("*** GCal List [InfoEditViewController - setupGCalList]\n");
		for (NSString *s in orgList)
		{
			printf("gcal calendar name: %s\n", [s UTF8String]);
		}
		printf("GCal List\n ***");
		*/
/*
		NSMutableArray *tmpOrg=[[NSMutableArray alloc] initWithArray:orgList];
		
		for(NSString *tmp in tmpOrg){
			if([tmp isEqualToString:taskNameCal]){
				[orgList removeObject:tmp];
			}
			else if([tmp isEqualToString:eventNameCal]){ 
				[orgList removeObject:tmp];
			}
		}
		
		[tmpOrg release];
*/
//	}

	NSString *taskName=[[editedObject projName] stringByAppendingString:@" Tasks"];
	NSString *eventName=[[editedObject projName] stringByAppendingString:@" Events"];

	//ST3.1 - only add default mapping names for 1-way sync ST->GCal
	if (taskmanager.currentSettingModifying.syncType == 1)
	{
		NSString *foundTaskName = nil;
		NSString *foundEventName = nil;
		
		for(NSString *tmp in orgList){
			if([tmp isEqualToString:taskName]){
				foundTaskName = tmp;
			}
			else if([tmp isEqualToString:eventName]){ 
				foundEventName = tmp;
			}
		}
		
		if (foundTaskName != nil)
		{
			[orgList removeObject:foundTaskName];
		}
		
		if (foundEventName != nil)
		{
			[orgList removeObject:foundEventName];
		}
		
		if(orgList.count>0){
			[orgList insertObject:taskName atIndex:0];
		}else {
			[orgList addObject:taskName];
		}
		
		[orgList insertObject:eventName atIndex:0];	
		
		textField.enabled = YES;
	}
	else
	{
		textField.enabled = NO;
	}
	
	ret=[[NSMutableArray alloc] initWithArray:orgList];
	
	NSMutableArray *tmpArr=[[NSMutableArray alloc] initWithArray:ret];
	for(NSString *orgTmp in tmpArr){
		for(NSString *usedTmp in self.usedGcalsList){
			if([orgTmp isEqualToString:usedTmp]){
				[ret removeObject:orgTmp];
				break;
			}
		}
	}
	[tmpArr release];
	
exitFor:
	self.gCalList=ret;
	[orgList release];
	[ret release];
}

// Allocates and initializes a piece view object. Sets characteristics to default values.
-(UIImageView *)newIconViewWithImageNamed:(NSString *)imageName atPostion:(CGPoint)centerPoint
{
	//ILOG(@"[InfoEditViewController newIconViewWithImageNamed\n");
	UIImage *image = [UIImage imageNamed:imageName];
	UIImageView *theView = [[UIImageView alloc] initWithImage:image];
	// Set the center of the view.
	theView.center = centerPoint;
	// Set alpha so it is slightly transparent to allow seeing pieces move over each other.
	theView.alpha = 0.9;
	// Disable user interaction for this view. You must do this if you want to handle touches for more than one object at at time.
	// You'll get events for the superview, and then dispatch them to the appropriate subview in the touch handling methods.
	// theView.userInteractionEnabled = NO;
	[image release];
	
	//ILOG(@"InfoEditViewController newIconViewWithImageNamed]\n");
	return theView;
}

-(void)refreshTitleBarName{
	//ILOG(@"[InfoEditViewController refreshTitleBarName\n");
	switch (self.keyEdit) {
		case SETTING_HOWLONG:
			self.navigationItem.title =NSLocalizedString(@"durationText", @"")/*durationText*/;//@"Duration";
			break;
		case SETTING_TIMESREPEAT:
			self.navigationItem.title =NSLocalizedString(@"repeatTimesText", @"")/*repeatTimesText*/;
			break;
		case SETTING_ENDDUEDAYS:
			self.navigationItem.title =NSLocalizedString(@"untilDueText", @"")/*untilDueText*/;
			break;
		case SETTING_PROJECTEDIT:
			self.navigationItem.title =NSLocalizedString(@"editProjectText", @"")/*editProjectText*/;//@"Edit Project";
			break;
		case SETTING_GCALPROJMAP:
			self.navigationItem.title=NSLocalizedString(@"gcalNameText", @"")/*gcalNameText*/;
			break;
		case TASK_EDITTITLE:
			self.navigationItem.title =NSLocalizedString(@"titleText", @"")/*titleText*/;//@"Title";
			break;
		case TASK_EDITNOTES:
			self.navigationItem.title =NSLocalizedString(@"notesText", @"")/*notesText*/;//@"Notes";
			break;
		case TASK_EDITHOWLONG:
			self.navigationItem.title =NSLocalizedString(@"durationText", @"")/*durationText*/;//@"Duration";
			break;
		case TIMER_EDITREPEATTIMES:
			self.navigationItem.title =NSLocalizedString(@"repeatTimesText", @"")/*repeatTimesText*/;
			break;
			
	}
	//ILOG(@"InfoEditViewController refreshTitleBarName]\n");
}

#pragma mark TextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
	if(self.keyEdit==SETTING_GCALPROJMAP){
		tableView.hidden=YES;
		doneBarView.hidden=NO;
		doneButton.hidden=NO;
	}else {
		doneBarView.hidden=YES;
		doneButton.hidden=YES;
	}

}

- (void)textFieldDidEndEditing:(UITextField *)textField{
	if(self.keyEdit==SETTING_GCALPROJMAP){
		tableView.hidden=NO;
	}
	doneBarView.hidden=YES;
	doneButton.hidden=YES;
}

#pragma mark textView delegate

- (void)textViewDidEndEditing:(UITextView *)textView{
}

#pragma mark property

-(NSString *)textValue{
	return textValue;	
}
-(void)setTextValue:(NSString *)aString{
	if ((!textValue && !aString) || (textValue && aString && [textValue isEqualToString:aString])) return;
	[textValue release];
	textValue = [aString copy];
}

- (NSString	*)selectedLocation{
	return selectedLocation;	
}

- (void)setSelectedLocation:(NSString *)aString{
	[selectedLocation release];
	selectedLocation=[aString copy];	
}

#pragma mark -
#pragma mark <UITableViewDelegate, UITableViewDataSource> Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
	if(keyEdit==SETTING_GCALPROJMAP){
		[self setupGCalList];
	}
	self.pathIndex=-1;
    // 1 sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
	//trung ST3.2
    //return self.gCalList.count;
	if (taskmanager.currentSettingModifying.syncType == 1)
	{
		return self.gCalList.count;
	}
	else
	{
		return self.gCalList.count + 1;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//ILOG(@"[ProjectViewController cellForRowAtIndexPath\n");
	//if(self.gCalList.count>0){
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifier"] autorelease];
		}

/*	v5
	
	if (indexPath.row < self.gCalList.count)
	{
		cell.textLabel.text = [self.gCalList objectAtIndex:indexPath.row];
	}
	else
	{
		cell.textLabel.text = NSLocalizedString(@"clearGCalMappingText", @"");
	}

		if([cell.textLabel.text isEqualToString:textField.text]){
			//[[tv cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
			//[cell setAccessoryType:UITableViewCellAccessoryCheckmark];	
			self.pathIndex=indexPath.row;
			[cell.textLabel setTextColor:[Colors darkSteelBlue]];
		}
		else if ([cell.textLabel.text isEqualToString:NSLocalizedString(@"clearGCalMappingText", @"")])
		{
			[[cell textLabel] setTextColor:[UIColor grayColor]];
		}
		else {
			[cell.textLabel setTextColor:[UIColor blackColor]];
		}
	//trung ST3.2
	//if(self.gCalList.count>0 && indexPath.row==self.pathIndex &&
	if(indexPath.row==self.pathIndex &&
	   ![cell.textLabel.text isEqualToString:@""] ){
		cell.accessoryType= UITableViewCellAccessoryCheckmark;	
	}else {
		cell.accessoryType=  UITableViewCellAccessoryNone;
	}
	*/
		//ILOG(@"ProjectViewController cellForRowAtIndexPath]\n");
		return cell;
	//}
	//return nil;
}


- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section {
    // Return the displayed title for the specified section.
	if(self.gCalList.count>0)
	return NSLocalizedString(@"selectGCalNameInListText", @"")/*selectGCalNameInListText*/;
	
	return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Never allow selection.
    if (self.editing) {
		saveButton.enabled=YES;
		return indexPath;
	}
    return nil;
}

/*- (UITableViewCellAccessoryType)tableView:(UITableView *)table accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	
	if(self.gCalList.count>0 && indexPath.row==self.pathIndex && 
	   ![[[table cellForRowAtIndexPath:indexPath] text] isEqualToString:@""] ){
		return UITableViewCellAccessoryCheckmark;	
	}
	return UITableViewCellAccessoryNone;
}
*/

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	//ILOG(@"[ProjectViewController didSelectRowAtIndexPath\n");
	/*
    printf("\n %s", [[[table cellForRowAtIndexPath:newIndexPath].textLabel text] UTF8String]);
	if(keyEdit==SETTING_GCALPROJMAP && [[table cellForRowAtIndexPath:newIndexPath].textLabel text] &&
	   ![[[table cellForRowAtIndexPath:newIndexPath].textLabel text] isEqualToString:@""] ){
        
		NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:self.pathIndex inSection:0];	
		[[table cellForRowAtIndexPath:oldIndexPath] setAccessoryType:UITableViewCellAccessoryNone];
		[[table cellForRowAtIndexPath:newIndexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
		
		//trung ST3.2
		//textField.text=[[table cellForRowAtIndexPath:newIndexPath] text];
		if ([[table cellForRowAtIndexPath:newIndexPath].textLabel.text isEqualToString:NSLocalizedString(@"clearGCalMappingText", @"")])
		{
			textField.text = @"";
		}
		else
		{
			textField.text=[[table cellForRowAtIndexPath:newIndexPath].textLabel text];			
		}
		
		if ([[table cellForRowAtIndexPath:oldIndexPath].textLabel.text isEqualToString:NSLocalizedString(@"clearGCalMappingText", @"")])
		{
			[[table cellForRowAtIndexPath:oldIndexPath].textLabel setTextColor:[UIColor grayColor]];
		}
		else
		{
			[[table cellForRowAtIndexPath:oldIndexPath].textLabel setTextColor:[UIColor blackColor]];
		}
		
		[[table cellForRowAtIndexPath:newIndexPath].textLabel setTextColor:[Colors darkSteelBlue]];
		self.pathIndex=newIndexPath.row;
    }	
     */
    [table deselectRowAtIndexPath:newIndexPath animated:YES];
	//ILOG(@"ProjectViewController didSelectRowAtIndexPath]\n");
}

@end
