//
//  Syncself.tableViewController.m
//  SmartTime
//
//  Created by Huy Le on 9/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SyncMappingTableViewController.h"
#import "ivo_Utilities.h"
#import "Projects.h"
#import "GCalSync.h"
#import "IvoCommon.h"
#import "SyncWindow2TableViewController.h"
#import "ProjectEditViewController.h"

#import "SmartTimeAppDelegate.h"
#import "TaskManager.h"
#import "Setting.h"

#import "Colors.h"
#import "QuartzCore/QuartzCore.h"

extern BOOL isInternetConnected;

extern TaskManager *taskmanager;
extern SmartTimeAppDelegate *App_Delegate;

extern ivo_Utilities *ivoUtility;
extern NSMutableArray *projectList;
extern NSMutableArray	*originalGCalList;
extern NSMutableArray	*originalGCalColorList;
extern NSMutableArray	*originalGCalColorDict;
extern TaskManager *taskmanager;

@implementation SyncMappingTableViewController

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

-(id) init
{
	if(self = [super init])
	{
		copyProjectList=[[NSArray alloc] initWithArray:projectList copyItems:YES];
		
		eventMap = YES;
		
		gcalList = nil;
		
		[self fetchCalendars:nil];
		
		firstTimeLoad = YES;
		isConnecting = NO;
	}
	return self;	
}

-(void) setupGCalList
{
	if (gcalList != nil)
	{
		[gcalList release];
	}
	
	gcalList = [[NSMutableArray alloc] initWithCapacity:PROJECT_NUM];
	
	for (int i=0; i<PROJECT_NUM; i++)
	{
		[gcalList addObject:(eventMap?[[copyProjectList objectAtIndex:i] mapToGCalNameForEvent]:[[copyProjectList objectAtIndex:i] mapToGCalNameForTask])];
	}
	
	[self resizeViews];

}

-(void)fetchCalendars:(id) sender
{
	//Nang3.8==>remove
	//nang - checking internet connecttion status
/*	if(!isInternetConnected){
		UIAlertView *alrt=[[UIAlertView alloc] initWithTitle:noInternetConnectionText
													 message:noInternetConnectionMsg
													delegate:self
										   cancelButtonTitle:okText 
										   otherButtonTitles:nil];
		[alrt show];
		[alrt release];
		return;
	}
*/	
	connectButton.enabled = NO;
	autoMapButton.enabled = NO;
/*	
	NSNumber *action = [sender userInfo];	
	if (action == nil)
	{
		connectButton.selected = YES;
		autoMapButton.selected = YES;
		
		connectButton.enabled = NO;
		autoMapButton.enabled = NO;
	}
	else
	{
		if ([action intValue] == 0)
		{
			autoMapButton.selected = YES;
			autoMapButton.enabled = NO;
		}
		else
		{
			connectButton.selected = YES;
			connectButton.enabled = NO;
		}
	}
*/
	
	NSString *userName = nil;
	NSString *passWord = nil;
	
	NSString *mixedAccount = [taskmanager.currentSettingModifying gCalAccount];
	if(mixedAccount !=nil){
		NSArray *account=[NSArray arrayWithArray:[mixedAccount componentsSeparatedByString:@"®"]];
		if(account.count==1){
			userName=[account objectAtIndex:0];
			passWord=@"";
		}else if(account.count==2){
			userName=[account objectAtIndex:0];
			passWord=[account objectAtIndex:1];
		}else {
			userName=@"";
			passWord=@"";
		}
	}else {
		userName=@"";
		passWord=@"";
	}
	
	GCalSync *gcalsync = [GCalSync getInstance:userName :passWord :nil];
	
	[gcalsync fetchAllCalendarsToMap];
}

- (void)loadView 
{
	[super loadView];
	moveTimes=1;
	
	projectTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 160, 0) style:UITableViewStyleGrouped];
	projectTableView.sectionHeaderHeight=5;
	projectTableView.sectionFooterHeight=1;
	projectTableView.delegate = self;
	projectTableView.dataSource = self;
	
	gcalTableView = [[UITableView alloc] initWithFrame:CGRectMake(120, 0, 200, 0) style:UITableViewStyleGrouped];
	gcalTableView.sectionHeaderHeight=5;
	gcalTableView.sectionFooterHeight=1;
	gcalTableView.delegate = self;
	gcalTableView.dataSource = self;
	gcalTableView.editing = YES;
	
	syncWindowCellView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	
	UILabel *syncWindowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 140, 30)];
	syncWindowLabel.backgroundColor = [UIColor clearColor];
	syncWindowLabel.text = NSLocalizedString(@"syncWindowText", @"")/*syncWindowText*/;
	
	[syncWindowCellView addSubview:syncWindowLabel];
	[syncWindowLabel release];
	
	UIButton *syncWindowOption1Button =[ivoUtility createButton:NSLocalizedString(@"syncWindowOption1Text", @"")/*syncWindowOption1Text*/
							 buttonType:UIButtonTypeRoundedRect 
								  frame:CGRectMake(120, 5, 50, 30) 
							 titleColor:nil 
								 target:self 
							   selector:@selector(syncWindowSetting:) 
									 normalStateImage:@"no-mash-white.png"
								   selectedStateImage:@"no-mash-blue.png"];
	[syncWindowOption1Button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	syncWindowOption1Button.tag = 100;
	
	[syncWindowCellView addSubview:syncWindowOption1Button];
	[syncWindowOption1Button release];

	UIButton *syncWindowOption2Button =[ivoUtility createButton:NSLocalizedString(@"syncWindowOption2Text", @"")/*syncWindowOption2Text*/
										   buttonType:UIButtonTypeRoundedRect 
												frame:CGRectMake(175, 5, 50, 30) 
										   titleColor:nil 
											   target:self 
											 selector:@selector(syncWindowSetting:) 
									  normalStateImage:@"no-mash-white.png"
									selectedStateImage:@"no-mash-blue.png"];
	[syncWindowOption2Button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	syncWindowOption2Button.tag = 200;
	
	[syncWindowCellView addSubview:syncWindowOption2Button];
	[syncWindowOption2Button release];	

	UIButton *syncWindowOption3Button =[ivoUtility createButton:NSLocalizedString(@"syncWindowOption3Text", @"")/*syncWindowOption3Text*/
											buttonType:UIButtonTypeRoundedRect 
												 frame:CGRectMake(230, 5, 50, 30) 
											titleColor:nil 
												target:self 
											  selector:@selector(syncWindowSetting:) 
										normalStateImage:@"no-mash-white.png"
									  selectedStateImage:@"no-mash-blue.png"];
	[syncWindowOption3Button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	syncWindowOption3Button.tag = 300;
	
	[syncWindowCellView addSubview:syncWindowOption3Button];
	[syncWindowOption3Button release];	
	
	UIButton *selectSyncWindowButon=[ivoUtility createButton:@""
											 buttonType:UIButtonTypeDetailDisclosure 
												  frame:CGRectMake(280, 0, 44, 44) 
											 titleColor:nil
												 target:self 
											   selector:@selector(syncWindowSetting:) 
									   normalStateImage:nil 
									 selectedStateImage:nil];
	selectSyncWindowButon.tag = 400;
	
	[syncWindowCellView addSubview:selectSyncWindowButon];
	
	[selectSyncWindowButon release];
	

	bottomToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,418-44,320,44)];
	bottomToolbar.barStyle = UIBarStyleBlackOpaque;
	
	bottomToolbar.tag = 1000;
	
	[self.view addSubview:bottomToolbar];
	[bottomToolbar release];
	
	UISegmentedControl *buttonBarSegmentedControl = [[UISegmentedControl alloc] initWithItems:
								 [NSArray arrayWithObjects:NSLocalizedString(@"eventText", @"")/*eventText*/, NSLocalizedString(@"taskText", @"")/*taskText*/,nil]];
	
	[buttonBarSegmentedControl addTarget:self action:@selector(changeType:) forControlEvents:UIControlEventValueChanged];
	buttonBarSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBordered;
	buttonBarSegmentedControl.selectedSegmentIndex=0;
	buttonBarSegmentedControl.tintColor = [UIColor blueColor];
	//buttonBarSegmentedControl.frame = CGRectMake(0, 0, 140, 30);
	buttonBarSegmentedControl.frame = CGRectMake(0, 0, 180, 30);
	
	UIBarButtonItem *segItem = [[UIBarButtonItem alloc] initWithCustomView:buttonBarSegmentedControl];
	[buttonBarSegmentedControl release];

/*	
	autoMapButton =[ivoUtility createButton:autoMapText
											  buttonType:UIButtonTypeRoundedRect 
												   frame:CGRectMake(0, 5, 70, 30) 
											  titleColor:nil 
												  target:self 
												selector:@selector(autoMap:) 
										normalStateImage:nil
									  selectedStateImage:@"grayButton.png"];
	[autoMapButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	
	UIBarButtonItem *autoMapButtonItem = [[UIBarButtonItem alloc] initWithCustomView:autoMapButton];
	[autoMapButton release];
*/ 
	
	connectButton =[ivoUtility createButton:NSLocalizedString(@"connectText", @"")/*connectText*/
										 buttonType:UIButtonTypeRoundedRect 
											  //frame:CGRectMake(0, 5, 70, 30) 
					frame:CGRectMake(0, 5, 100, 30) 
										 titleColor:nil 
											 target:self 
										   selector:@selector(connect:) 
								   normalStateImage:nil
								 selectedStateImage:@"grayButton.png"];
	[connectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	
	UIBarButtonItem *connectButtonItem = [[UIBarButtonItem alloc] initWithCustomView:connectButton];
	[connectButton release];
	
	UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
															 target:nil
															 action:nil];
	
	
	//bottomToolbar.items =  [NSArray arrayWithObjects:autoMapButtonItem, flexItem, segItem, flexItem, connectButtonItem, nil];
	bottomToolbar.items =  [NSArray arrayWithObjects:segItem, flexItem, connectButtonItem, nil];
	
	//[autoMapButtonItem release];
	[connectButtonItem release];
	[flexItem release];
	
	hintView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 418)];
	hintView.backgroundColor = [UIColor colorWithRed:40.0/255 green:40.0/255 blue:40.0/255 alpha:0.9];
	hintView.hidden = YES;
	
	hintLabel = [[GuideWebView alloc] initWithFrame:CGRectMake(10, 0, 300, 400)];
	[hintLabel loadHTMLFile:@"EventSyncHint" extension:@"htm"];
	
	[hintView addSubview:hintLabel];
	
	[hintLabel release];

	hintOKButton =[ivoUtility createButton:NSLocalizedString(@"okText", @"")/*okText*/
								buttonType:UIButtonTypeRoundedRect 
									 //frame:CGRectMake(50, 14*44-60, 80, 25) 
				   frame:CGRectMake(210, 380, 100, 30) 
								titleColor:nil 
									target:self 
								  selector:@selector(hint:) 
						  normalStateImage:nil
						selectedStateImage:nil];
	[hintOKButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];	
	
	hintDontShowButton =[ivoUtility createButton:NSLocalizedString(@"dontShowText", @"")/*dontShowText*/
									  buttonType:UIButtonTypeRoundedRect 
										   frame:CGRectMake(10, 380, 100, 30) 
									  titleColor:nil 
										  target:self 
										selector:@selector(hint:) 
								normalStateImage:nil
							  selectedStateImage:nil];
	[hintDontShowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	
	[hintView addSubview:hintOKButton];
	[hintOKButton release];
	
	[hintView addSubview:hintDontShowButton];
	[hintDontShowButton release];
	
	[self.view addSubview:hintView];
	[hintView release];
	
	UIBarButtonItem *saveButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
															  target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = saveButton;
	self.navigationItem.title = NSLocalizedString(@"gcalEventMappingText", @"")/*gcalEventMappingText*/;
	
	[saveButton release];
	
	//nang 3.6
	isExistedMappings=NO;
	isFirstTimeLoadView=NO;
	for(Projects *proj in projectList){
		if([proj.mapToGCalNameForTask length]>0 || [proj.mapToGCalNameForEvent length]>0){
			isExistedMappings=YES;
		}
	}

	if(!isExistedMappings){
		//stepHintImageView=[[UIImageView alloc] initWithFrame:CGRectMake(210, 295, 103, 83)];
		//stepHintImageView.image=[UIImage imageNamed:@"tap.png"];
		//[self.view addSubview: stepHintImageView];
		//[stepHintImageView release];
		stepHintButtonView=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
		stepHintButtonView.frame= CGRectMake(210, 295, 103, 83);
		[stepHintButtonView setImage:[UIImage imageNamed:@"tap.png"] forState:UIControlStateNormal];
		[stepHintButtonView addTarget:self action:@selector(hideButtonHint:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:stepHintButtonView];
		[stepHintButtonView release];
	}
}

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/
-(void)hideButtonHint:(id)sender{
	UIButton *bt=(UIButton *)sender;
	if(stepHintButtonView && [stepHintButtonView superview]){
		[stepHintButtonView removeFromSuperview];
		stepHintButtonView=nil;
	}
	
	if(bt.tag==2){
		isExistedMappings=YES;
		isFirstTimeLoadView=YES;
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[self refreshSyncWindowButtons];
	[self setupGCalList];

	[self reloadData:nil];
}

- (void) popupHint
{
	BOOL showHint = NO;
	
	if (eventMap)
	{
		NSNumber *eventMapHintEnabled = [App_Delegate.hintSettingDict objectForKey:@"eventMapHintEnabled"];
		//NSNumber *eventMapHintEnabled =nil;
		
		if (eventMapHintEnabled != nil && [eventMapHintEnabled intValue] == 0)
		{
			hintView.hidden = YES;
		}
		else
		{
			//nang 3.6
			//self.tableView.scrollEnabled = NO;
			//self.tableView.sectionHeaderHeight = 0;
			//[self.tableView reloadData];//dont show header
			
			//showHint = YES;
			showHint=NO;
		}			
	}
	else
	{
		NSNumber *taskMapHintEnabled = [App_Delegate.hintSettingDict objectForKey:@"taskMapHintEnabled"];
		
		if (taskMapHintEnabled != nil && [taskMapHintEnabled intValue] == 0)
		{
			hintView.hidden = YES;
		}
		else
		{
			self.tableView.scrollEnabled = NO;
			self.tableView.sectionHeaderHeight = 0;
			[self.tableView reloadData];//dont show header
			
			showHint = YES;
		}			
	}
	
	if (showHint)
	{
		hintView.hidden = NO;
		
		//hintLabel.text = (eventMap?eventMapHintText:taskMapHintText);
		[hintLabel loadHTMLFile:(eventMap?@"EventSyncHint":@"TaskSyncHint") extension:@"htm"];
		
		CATransition *animation = [CATransition animation];
		[animation setDelegate:self];
		
		[animation setType:kCATransitionMoveIn];
		[animation setSubtype:kCATransitionFromTop];
		
		// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
		[animation setDuration:0.25];
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
		
		[[self.view layer] addAnimation:animation forKey:@"popUpHint"];			
		
	}
	else
	{
		[self reloadData:nil];
		bottomToolbar.frame = CGRectMake(0, 418-44, 320, 44);
		bottomToolbar.hidden = NO;
	}
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	if (firstTimeLoad)
	{
		[self popupHint];
		
		firstTimeLoad = NO;
	}
}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)viewDidLoad {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
}

- (void) mapFinished
{
	printf("map finished\n");
	
	autoMapButton.enabled = YES;
	autoMapButton.selected = NO;
	
	connectButton.enabled = YES;
	connectButton.selected = NO;
}

- (void) hint: (id) sender
{	
	if ([sender isEqual:hintDontShowButton])
	{
		if (eventMap)
		{
			NSNumber *eventMapHintEnabled = [NSNumber numberWithInt:0];
			
			[App_Delegate.hintSettingDict setValue:eventMapHintEnabled forKey:@"eventMapHintEnabled"];
			
			[App_Delegate saveHintSettingDict];	
		}
		else
		{
			NSNumber *taskMapHintEnabled = [NSNumber numberWithInt:0];
			
			[App_Delegate.hintSettingDict setValue:taskMapHintEnabled forKey:@"taskMapHintEnabled"];
			
			[App_Delegate saveHintSettingDict];			
		}
	}

	hintView.hidden = YES;
	
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	
	[animation setType:kCATransitionMoveIn];
	[animation setSubtype:kCATransitionFromBottom];
	
	// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
	[animation setDuration:0.25];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[self.view layer] addAnimation:animation forKey:@"popDownHint"];			
	
	self.tableView.scrollEnabled = YES;
	self.tableView.sectionHeaderHeight = 20;
		
	[self reloadData:nil];
	bottomToolbar.frame = CGRectMake(0, 418-44, 320, 44);
	bottomToolbar.hidden = NO;	
}

- (void) refreshSyncWindowButtons
{
	UIButton *syncWindowOption1Button = (UIButton *) [syncWindowCellView viewWithTag:100];
	syncWindowOption1Button.selected = NO;

	UIButton *syncWindowOption2Button =  (UIButton *) [syncWindowCellView viewWithTag:200];
	syncWindowOption2Button.selected = NO;
		
	UIButton *syncWindowOption3Button =  (UIButton *) [syncWindowCellView viewWithTag:300];
	syncWindowOption3Button.selected = NO;
	
	NSInteger syncWindowStart = taskmanager.currentSettingModifying.syncWindowStart;
	NSInteger syncWindowEnd = taskmanager.currentSettingModifying.syncWindowEnd;
	
	if (syncWindowStart == 0 && syncWindowEnd == 0)
	{
		syncWindowOption1Button.selected = YES;
	}
	else if (syncWindowStart == 1 && syncWindowEnd == 1)
	{
		syncWindowOption2Button.selected = YES;
	}
	else if (syncWindowStart == 2 && syncWindowEnd == 2)
	{
		syncWindowOption3Button.selected = YES;
	}
	
}

- (void) syncWindowSetting: (id) sender
{
	switch ([sender tag])
	{
		case 100:
		{
			taskmanager.currentSettingModifying.syncWindowStart = 0;
			taskmanager.currentSettingModifying.syncWindowEnd = 0;
			
			[self refreshSyncWindowButtons];
		}
			break;
		case 200:
		{
			taskmanager.currentSettingModifying.syncWindowStart = 1;
			taskmanager.currentSettingModifying.syncWindowEnd = 1;
			
			[self refreshSyncWindowButtons];			
		}
			break;
		case 300:
		{
			taskmanager.currentSettingModifying.syncWindowStart = 2;
			taskmanager.currentSettingModifying.syncWindowEnd = 2;
			
			[self refreshSyncWindowButtons];			
		}
			break;
		case 400:
		{
			SyncWindow2TableViewController *syncWindowController = [[SyncWindow2TableViewController alloc] init];
			[self.navigationController pushViewController:syncWindowController animated:YES];
			[syncWindowController release];
		}
			break;
	}
	
}

- (void) changeType: (id) sender
{
	//nang 3.6
	if([sender selectedSegmentIndex]==1){
		if(stepHintButtonView && [stepHintButtonView superview]){
			[stepHintButtonView removeFromSuperview];
			stepHintButtonView=nil;
		}	
	}
	
	self.tableView.contentOffset = CGPointMake(0, 0);
	
	eventMap = ([sender selectedSegmentIndex] == 0);
	
	[self setupGCalList];
	
	self.navigationItem.title = (eventMap? NSLocalizedString(@"gcalEventMappingText", @""):NSLocalizedString(@"gcalTaskMappingText", @"")/*gcalEventMappingText: gcalTaskMappingText*/);
		
	[self popupHint];
}

- (void) autoMap: (id) sender
{
	if (originalGCalList != nil)
	{
		if (originalGCalList.count == 0 || (originalGCalList.count == 1 && [[originalGCalList objectAtIndex:0] isEqualToString:@""]))
		{
			UIAlertView *noMapAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"smartSyncText", @"")/*smartSyncText*/ message:NSLocalizedString(@"nothingToAutoMapText", @"")/*nothingToAutoMapText*/ delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/ otherButtonTitles:nil];
			
			[noMapAlert show];
			[noMapAlert release];		
		}
		else
		{
			[gcalList release];
			
			gcalList = [[NSMutableArray alloc] initWithArray:originalGCalList copyItems:YES];
						
			NSDictionary *gcalDict = [NSDictionary dictionaryWithObjects:gcalList forKeys:gcalList];
			
			for (int i=0; i<PROJECT_NUM; i++)
			{
				(eventMap?[[copyProjectList objectAtIndex:i] setMapToGCalNameForEvent:@""]:[[copyProjectList objectAtIndex:i] setMapToGCalNameForTask:@""]);
				
				NSString *excludedGCal = (eventMap?[[copyProjectList objectAtIndex:i] mapToGCalNameForTask]:[[copyProjectList objectAtIndex:i] mapToGCalNameForEvent]);
				
				if (excludedGCal != nil && ![excludedGCal isEqualToString:@""])
				{
					NSString *s = [gcalDict objectForKey:excludedGCal];
					
					if (s != nil)
					{
						[gcalList removeObject:s];
					}
				}					
			}
			
			if (gcalList.count < PROJECT_NUM)
			{
				for (int i=gcalList.count; i<PROJECT_NUM; i++)
				{
					[gcalList addObject:@""];
				}
			}
			
			NSMutableArray *gcalColorList = [NSMutableArray arrayWithCapacity:gcalList.count];
			
			for (NSString *s in gcalList)
			{
				NSString *colorStr = [ivo_Utilities hexStringFromColor:[originalGCalColorDict objectForKey:s]];
									  
				//printf("found color: %s, for name: %s\n", [colorStr UTF8String], [s UTF8String]);
				[gcalColorList addObject:colorStr];
			}
			
			gcalDict = [NSDictionary dictionaryWithObjects:gcalList forKeys:gcalColorList];
			
			for (int i=0; i<PROJECT_NUM; i++)
			{
				UIColor *prjColor = [ivoUtility getRGBColorForProject:i isGetFirstRGB:NO];
				
				NSString *mappedGCal = [gcalDict objectForKey:[ivo_Utilities hexStringFromColor:prjColor]];
				
				if (mappedGCal != nil) //found
				{
					(eventMap?[[copyProjectList objectAtIndex:i] setMapToGCalNameForEvent:mappedGCal]:[[copyProjectList objectAtIndex:i] setMapToGCalNameForTask:mappedGCal]);
					
					[gcalList removeObject:mappedGCal];
				}
			}
			
			for (int i=0; i<PROJECT_NUM; i++)
			{
				NSString *mappedGCal = (eventMap?[[copyProjectList objectAtIndex:i] mapToGCalNameForEvent]:[[copyProjectList objectAtIndex:i] mapToGCalNameForTask]);
				
				if (mappedGCal != nil && ![mappedGCal isEqualToString:@""])
				{
					[gcalList insertObject:mappedGCal atIndex:i]; //keep the old mapped index
				}
			}	
			
			if (gcalList.count < PROJECT_NUM)
			{
				for (int i=gcalList.count; i<PROJECT_NUM; i++)
				{
					[gcalList addObject:@""];
				}
			}			

			[self reloadData:nil];
			
		}
	}
	
	[self resizeViews];

	//[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(fetchCalendars:) userInfo:[NSNumber numberWithInt:0] repeats:NO];	
}

- (void) connect: (id) sender
{
	if(stepHintButtonView && [stepHintButtonView superview]){
		[stepHintButtonView removeFromSuperview];
		stepHintButtonView=nil;
	}
	
	//Nang3.8==>remove
/*	if(!isInternetConnected){
		UIAlertView *alrt=[[UIAlertView alloc] initWithTitle:noInternetConnectionText
													 message:noInternetConnectionMsg
													delegate:self
										   cancelButtonTitle:okText 
										   otherButtonTitles:nil];
		[alrt show];
		[alrt release];
		return;
	}
*/
	
	if (isConnecting)
	{
		return;
	}
	
	isConnecting = YES;
	
	if (originalGCalList != nil)
	{
		if (originalGCalList.count == 0 || (originalGCalList.count == 1 && [[originalGCalList objectAtIndex:0] isEqualToString:@""]))
		{
			UIAlertView *noMapAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"smartSyncText", @"")/*smartSyncText*/ message:NSLocalizedString(@"nothingToRefreshText", @"")/*nothingToRefreshText*/ delegate:self cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/ otherButtonTitles:nil];
			
			[noMapAlert show];
			[noMapAlert release];		
		}
		else
		{
			
			[gcalList release];
			
			gcalList = [[NSMutableArray alloc] initWithArray:originalGCalList copyItems:YES];

			NSDictionary *gcalDict = [NSDictionary dictionaryWithObjects:gcalList forKeys:gcalList];
			
			for (int i=0; i<PROJECT_NUM; i++)
			{
				NSString *excludedGCal = (eventMap?[[copyProjectList objectAtIndex:i] mapToGCalNameForTask]:[[copyProjectList objectAtIndex:i] mapToGCalNameForEvent]);
				
				if (excludedGCal != nil && ![excludedGCal isEqualToString:@""])
				{
					NSString *s = [gcalDict objectForKey:excludedGCal];
					
					if (s != nil)
					{
						[gcalList removeObject:s];
					}
				}				
			}
			
			if (gcalList.count < PROJECT_NUM) //fill empty rows
			{
				for (int i=gcalList.count; i<PROJECT_NUM; i++)
				{
					[gcalList addObject:@""];
				}
			}			
			
			for (int i=0; i<PROJECT_NUM; i++)
			{
				NSString *mappedGCal = (eventMap?[[copyProjectList objectAtIndex:i] mapToGCalNameForEvent]:[[copyProjectList objectAtIndex:i] mapToGCalNameForTask]);
				
				if (mappedGCal != nil && ![mappedGCal isEqualToString:@""])
				{
					NSString *s = [gcalDict objectForKey:mappedGCal];
					
					if (s != nil) //found old mapped name
					{
						[gcalList removeObject:s];
					}
					else //not found -> not map anymore
					{
						(eventMap?[[copyProjectList objectAtIndex:i] setMapToGCalNameForEvent:@""]:[[copyProjectList objectAtIndex:i] setMapToGCalNameForTask:@""]);
					}
				}
			}
						
			for (int i=0; i<PROJECT_NUM; i++)
			{
				NSString *mappedGCal = (eventMap?[[copyProjectList objectAtIndex:i] mapToGCalNameForEvent]:[[copyProjectList objectAtIndex:i] mapToGCalNameForTask]);
				
				if (mappedGCal != nil && ![mappedGCal isEqualToString:@""])
				{
					[gcalList insertObject:mappedGCal atIndex:i]; //keep the old mapped index
				}
			}

			[self reloadData:nil];
			
			//nang 3.6
			if(!isFirstTimeLoadView){
				if(stepHintButtonView && [stepHintButtonView superview]){
					[stepHintButtonView removeFromSuperview];
					stepHintButtonView=nil;
				}
				
				stepHintButtonView=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
				stepHintButtonView.frame= CGRectMake(10, 255, 139, 115);
				[stepHintButtonView setImage:[UIImage imageNamed:@"drag.png"] forState:UIControlStateNormal];
				[stepHintButtonView addTarget:self action:@selector(hideButtonHint:) forControlEvents:UIControlEventTouchUpInside];
				[self.view addSubview:stepHintButtonView];
				[stepHintButtonView release];
			}
		}
	}
	
	[self resizeViews];
	
	isConnecting = NO;

	[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(fetchCalendars:) userInfo:[NSNumber numberWithInt:1] repeats:NO];	
}

- (void) editProject: (id) sender
{
	ProjectEditViewController *prjEditController = [[ProjectEditViewController alloc] init];
	
	prjEditController.projectList = copyProjectList;
	
	prjEditController.projectIndex = [sender tag];
	prjEditController.eventMap = eventMap;
	
	[self.navigationController pushViewController:prjEditController animated:YES];
	[prjEditController release];	
}

- (void)save:(id)sender
{
	for (int i=0; i<projectList.count; i++)
	{
		Projects *proj = [projectList objectAtIndex:i];
		
		[proj setMapToGCalNameForEvent:[[copyProjectList objectAtIndex:i] mapToGCalNameForEvent]];
		[proj setMapToGCalNameForTask:[[copyProjectList objectAtIndex:i] mapToGCalNameForTask]];
		[proj setProjName:[[copyProjectList objectAtIndex:i] projName]];
		
		[proj update];
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}

-(void) resizeViews
{
	CGFloat height = ((gcalList.count > PROJECT_NUM?gcalList.count: PROJECT_NUM) + 1)*44;

	CGRect frm = gcalTableView.frame;
	frm.size.height = height;
	gcalTableView.frame = frm;
	
	frm = projectTableView.frame;
	frm.size.height = height;
	projectTableView.frame = frm;	
}

/*
-(void)linkToWeb:(id)sender{
	NSString *bodyStr = [NSString stringWithFormat:@"http://leftcoastlogic.com/sync"];
	NSString *encoded = [bodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [[NSURL alloc] initWithString:encoded];
	
	[[UIApplication sharedApplication] openURL:url];
	
	[url release];
	
}
*/

-(void)reloadData:(id)sender
{
	[gcalTableView reloadData];
	[projectTableView reloadData];	
	[self.tableView reloadData];	
}

-(void) reloadGCalTableView:(id)sender
{
	[gcalTableView reloadData];
}

- (void) updateMap
{
	for (int i=0; i<PROJECT_NUM; i++)
	{
		NSString *s = eventMap?[[copyProjectList objectAtIndex:i] mapToGCalNameForEvent]:[[copyProjectList objectAtIndex:i] mapToGCalNameForTask];
		
		if (s != nil && ![s isEqualToString:@""] && ![[gcalList objectAtIndex:i] isEqualToString:@""])
		{
			eventMap?[[copyProjectList objectAtIndex:i] setMapToGCalNameForEvent:[gcalList objectAtIndex:i]]:
			[[copyProjectList objectAtIndex:i] setMapToGCalNameForTask:[gcalList objectAtIndex:i]];
		}
		else
		{
			eventMap?[[copyProjectList objectAtIndex:i] setMapToGCalNameForEvent:@""]:
			[[copyProjectList objectAtIndex:i] setMapToGCalNameForTask:@""];
		}
		
		//printf("updateMap at %d: %s\n", i, [eventMap?[[copyProjectList objectAtIndex:i] mapToGCalNameForEvent]:[[copyProjectList objectAtIndex:i] mapToGCalNameForTask] UTF8String]);
	}
	
	[projectTableView reloadData];
	[gcalTableView reloadData];
	
	//[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(reloadGCalTableView:) userInfo:nil repeats:NO]; //to avoid loop-forever in moveRowAtIndexPath	
	
	//nang 3.6
	if(!isFirstTimeLoadView && moveToIndex<projectList.count && (moveTimes/2)*2==moveTimes){
		if(stepHintButtonView && [stepHintButtonView superview]){
			[stepHintButtonView removeFromSuperview];
			stepHintButtonView=nil;
		}
		
		stepHintButtonView=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
		stepHintButtonView.tag=2;
		stepHintButtonView.frame= CGRectMake(155, moveToIndex*44+44, 122, 96);
		[stepHintButtonView setImage:[UIImage imageNamed:@"lock.png"] forState:UIControlStateNormal];
		[stepHintButtonView addTarget:self action:@selector(hideButtonHint:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:stepHintButtonView];
		[stepHintButtonView release];
	}
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if ([tableView isEqual:self.tableView])
	{
		return 2;
	}
		
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([tableView isEqual:self.tableView])
	{
		return 1;
	}
	else if ([tableView isEqual:gcalTableView])
	{
		return gcalList.count;
	}

    return 12;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if ([tableView isEqual:self.tableView] && section == 1)
	{
		return NSLocalizedString(@"mappingHeaderText", @"")/*mappingHeaderText*/;
	}
	
	return @"";
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([tableView isEqual:self.tableView] && indexPath.section == 1)
	{
		return ((gcalList.count > PROJECT_NUM?gcalList.count: PROJECT_NUM) + 2)*44;
	}
	
	return 44;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MappingCell";
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //if (cell == nil) {
      UITableViewCell * cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    //}
	//else
	//{
	//	for(UIView *view in cell.contentView.subviews)
	//	{
	//		if(([view isKindOfClass:[UILabel class]] && view.tag >= 10000) || [view isKindOfClass:[UIButton class]])
	//		{
	//			[view removeFromSuperview];
	//		}
	//	}
	//}
    
    // Set up the cell...
	if ([tableView isEqual:self.tableView])
	{
		if (indexPath.section == 0)
		{
			[cell.contentView addSubview:syncWindowCellView];
			cell.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
		}
		else
		{
			[cell.contentView addSubview:gcalTableView];
			[cell.contentView addSubview:projectTableView];
		}
	}
	else if ([tableView isEqual:projectTableView])
	{
		UILabel *prjName = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 110, 44)];
		prjName.tag = 20000;
		prjName.backgroundColor = [UIColor clearColor];
		prjName.numberOfLines = 2;
		prjName.font = [cell.textLabel.font fontWithSize:14];
		[cell.contentView addSubview:prjName];
		cell.backgroundColor = [UIColor whiteColor];
		
		Projects *prj = [copyProjectList objectAtIndex:indexPath.row];
		
		//cell.font = [cell.font fontWithSize:14];
		//cell.text = prj.projName;		
		//cell.textColor = [ivoUtility getRGBColorForProject:indexPath.row isGetFirstRGB:NO];
		
		prjName.text = prj.projName;
		prjName.textColor = [ivoUtility getRGBColorForProject:indexPath.row isGetFirstRGB:NO];

		NSString *mappedGCal = (eventMap?[prj mapToGCalNameForEvent]:[prj mapToGCalNameForTask]);
		
		if (mappedGCal != nil && ![mappedGCal isEqualToString:@""])
		{
			//cell.backgroundColor = [Colors lightCyan];
			//nang 3.6
			cell.backgroundColor=[ivoUtility getRGBColorForProject:indexPath.row isGetFirstRGB:NO];
			prjName.textColor=[UIColor whiteColor];
		}
		else
		{
			cell.backgroundColor = [UIColor whiteColor];
		}
		
		UIButton *editProjectButon=[ivoUtility createButton:@""
									 buttonType:UIButtonTypeDetailDisclosure 
									frame:CGRectMake(110, 6, 30, 30) 
									 titleColor:nil
										 target:self 
									   selector:@selector(editProject:) 
							   normalStateImage:nil 
							 selectedStateImage:nil];
		[cell.contentView addSubview:editProjectButon];
		editProjectButon.tag = indexPath.row;
		
		[editProjectButon release];
		
	}
	else if ([tableView isEqual:gcalTableView])
	{
		UILabel *calName = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 110, 44)];
		calName.tag = 10000;
		calName.backgroundColor = [UIColor clearColor];
		calName.numberOfLines = 2;
		calName.font = [cell.textLabel.font fontWithSize:14];
		[cell.contentView addSubview:calName];
		cell.backgroundColor = [UIColor whiteColor];
		
		if (indexPath.row < gcalList.count)
		{
			calName.text = [gcalList objectAtIndex:indexPath.row];
			
			UIColor *color = [originalGCalColorDict objectForKey:calName.text];
			
			if (color != nil)
			{
				calName.textColor = color;
			}				
			
			if (indexPath.row < PROJECT_NUM)
			{
				Projects *prj = [copyProjectList objectAtIndex:indexPath.row];
				
				NSString *mappedGCal = (eventMap?[prj mapToGCalNameForEvent]:[prj mapToGCalNameForTask]);
				
				if (mappedGCal != nil && ![mappedGCal isEqualToString:@""])
				{
					//calName.textColor = [ivoUtility getRGBColorForProject:indexPath.row isGetFirstRGB:NO];
					//cell.backgroundColor = [Colors lightCyan];
					//nang 3.6
					cell.backgroundColor=[ivoUtility getRGBColorForProject:indexPath.row isGetFirstRGB:NO];
					calName.textColor=[UIColor whiteColor];
				}				
			}
				
		}
		
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		cell.showsReorderControl = YES;
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if ([tableView isEqual:projectTableView])
	{
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		
		Projects *prj = [copyProjectList objectAtIndex:indexPath.row];
		NSString *mappedGCal = (eventMap?[prj mapToGCalNameForEvent]:[prj mapToGCalNameForTask]);
		
		if (mappedGCal != nil && ![mappedGCal isEqualToString:@""])
		{			
			(eventMap? [[copyProjectList objectAtIndex:indexPath.row] setMapToGCalNameForEvent:@""]:
			 [[copyProjectList objectAtIndex:indexPath.row] setMapToGCalNameForTask:@""]);			
		}
		else if (![[gcalList objectAtIndex:indexPath.row] isEqualToString:@""]) 
		{
			(eventMap? [[copyProjectList objectAtIndex:indexPath.row] setMapToGCalNameForEvent:[gcalList objectAtIndex:indexPath.row]]:
			 [[copyProjectList objectAtIndex:indexPath.row] setMapToGCalNameForTask:[gcalList objectAtIndex:indexPath.row]]);
		}
		
		[projectTableView reloadData];
		[gcalTableView reloadData];
		
		//nang 3.6
		if(stepHintButtonView && [stepHintButtonView superview]){
			[stepHintButtonView removeFromSuperview];
			stepHintButtonView=nil;
		}	
	}
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	[gcalList exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
	moveToIndex=toIndexPath.row;
	moveTimes+=1;
	[self updateMap];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
	if ([tableView isEqual:gcalTableView])
	{
		return YES;
	}
	
	return NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	bottomToolbar.hidden = YES;
	
	if(stepHintButtonView && stepHintButtonView.tag!=2 && [stepHintButtonView superview]){
		[stepHintButtonView removeFromSuperview];
		stepHintButtonView=nil;
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if (!decelerate)
	{
		CGRect frm = bottomToolbar.frame;
		frm.origin.y = scrollView.contentOffset.y + 418 - frm.size.height;
		bottomToolbar.frame = frm;
		bottomToolbar.hidden = NO;		
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	CGRect frm = bottomToolbar.frame;
	frm.origin.y = scrollView.contentOffset.y + 418 - frm.size.height;
	bottomToolbar.frame = frm;
	bottomToolbar.hidden = NO;	

}

- (void)dealloc {
	
	[gcalList release];
	
	[copyProjectList release];
	
	[syncWindowCellView release];
	
    [super dealloc];
}


@end

