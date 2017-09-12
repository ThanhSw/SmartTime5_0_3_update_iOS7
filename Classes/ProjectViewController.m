//
//  ProjectViewController.m
//  iVo_NewAddTask
//
//  Created by Nang Le on 5/6/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ProjectViewController.h"
#import "IvoCommon.h"
#import "ivo_Utilities.h"
#import "Setting.h"
#import "Projects.h"
#import "InfoEditViewController.h"
#import "SmartTimeAppDelegate.h"
#import "TableCellWithRightValue.h"
//#import "GCalSync.h"
#import "CalendarEditingViewController.h"
#import "TaskManager.h"

#import "SmartViewController.h"

//extern Setting *currentSetting;
extern NSMutableArray *projectList;
extern ivo_Utilities	*ivoUtility;
extern TaskManager		*taskmanager;
extern SmartTimeAppDelegate *App_Delegate;
extern SmartViewController *_smartViewController;

extern NSString *projectsText;
extern NSString *showAllText;

@implementation ProjectViewController

@synthesize editedObject;
@synthesize pathIndex;
@synthesize keyEdit;
@synthesize visibleProjectList;

//@synthesize projectsListBackup;
/*
 This method is not invoked if the controller is restored from a nib file.
 All relevant configuration should have been performed in Interface Builder.
 If you need to do additional setup after loading from a nib, override -loadView.
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
		//self.title = NSLocalizedString(@"Projects", @"Projects");
	}
	return self;
}

-(id) init{
	if(self = [super init])
	{
		//EK Sync
		//projectsListBackup = [[NSMutableArray alloc] initWithArray:projectList copyItems:YES];
		self.navigationItem.title=NSLocalizedString(@"projectsText",@"");
		
		//ILOG(@"[ProjectViewController loadView\n");
		//for selection projects uses
		cellList=[[NSMutableArray alloc] init];
		self.visibleProjectList=[NSMutableArray array];
		
		//saveButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
		//														  target:self action:@selector(save:)];
		addBarBt=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
															   target:self
															   action:@selector(addProject:)];
		showAllProjectsBt=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"showAllText",@"")
														   style:UIBarButtonItemStyleBordered
														  target:self
														  action:@selector(showAllProjects:)];
		
		self.navigationItem.rightBarButtonItem = addBarBt;
		//self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
		
		//for change Projects setting uses
		//doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
		//														  target:self action:@selector(done:)];
        
        CGRect frame=[[UIScreen mainScreen] bounds];
		tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64,frame.size.width , frame.size.height-64) style:UITableViewStylePlain];
		tableView.sectionHeaderHeight=40;
		tableView.sectionFooterHeight=1;
		tableView.delegate = self;
		tableView.dataSource = self;
		
		self.view = tableView;
	}
  return self;	
}

- (void)loadView {


	//ILOG(@"ProjectViewController loadView]\n");
}

- (void)dealloc {
	
	[addBarBt release];
	//[doneButton release];

	//[projectsListBackup release];

	
	[tableView removeFromSuperview];
	tableView.delegate=nil;
	tableView.dataSource=nil;
	[tableView release];
	
	//Trung 08101002
	[editedObject release];
	
	[showAllProjectsBt release];
	
	[super dealloc];	
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
	//return YES;
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

-(void)fetchCalendars
{
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

//	GCalSync *gcalsync = [GCalSync getInstance:userName :passWord :nil];

//	[gcalsync fetchAllCalendarsToMap];

}

-(void)viewDidLoad{
}

#pragma mark controller delegate
- (void)viewWillAppear:(BOOL)animated {
	//ILOG(@"[ProjectViewController viewWillAppear\n");
	isSaved=NO;
	isGoingBack=YES;
	
	[self.visibleProjectList removeAllObjects];
    
    NSMutableArray *projects=[NSMutableArray arrayWithArray:projectList];
	for (Projects *project in projects) {
		if (!project.inVisible) {
			[self.visibleProjectList addObject:project];
		}
	}
	
	if(self.keyEdit==SETTING_PROJECTDEFAULT||self.keyEdit==TASK_EDITPROJECT ){
		//saveButton.enabled=NO;
		self.navigationItem.rightBarButtonItem = nil;
		
	}else if(self.keyEdit==SETTING_PROJECTEDIT|| self.keyEdit==PROJECT_SHOW_HIDE){
		[tableView reloadData];
		
		if (self.keyEdit==PROJECT_SHOW_HIDE) {
			self.navigationItem.rightBarButtonItem = showAllProjectsBt;
		}else {
			self.navigationItem.rightBarButtonItem = addBarBt;
		}
	}
	self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
	
	//refresh title bar name
	[self refreshTitleBarName];

    //[tableView reloadData];
	//ILOG(@"ProjectViewController viewWillAppear]\n");
}

-(void)viewDidAppear:(BOOL)animated{

}
- (void)viewWillDisappear:(BOOL)animated{
	//if(self.keyEdit==SETTING_PROJECTEDIT && !isSaved && isGoingBack){
		//roll back changes
		
	//	[projectList release];
	//	projectList=[[NSMutableArray alloc] initWithArray:self.projectsListBackup];
		
	//}
	
	if(self.keyEdit==SETTING_PROJECTDEFAULT || self.keyEdit==TASK_EDITPROJECT){
		Projects *proj=[self.visibleProjectList objectAtIndex:self.pathIndex];
		if(self.keyEdit==SETTING_PROJECTDEFAULT){
			taskmanager.currentSettingModifying.projectDefID=proj.primaryKey;
		}else {
			[editedObject setTaskProject:proj.primaryKey];
		}
	}
    
    if (self.keyEdit==PROJECT_SHOW_HIDE) {
        [_smartViewController startRefreshTasks];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
}
 
#pragma mark action methods

-(void)showAllProjects:(id)sender{
    
    NSMutableArray *projects=[NSMutableArray arrayWithArray:projectList];
	for (Projects *project in projects) {
		if (project.inVisible) {
			project.inVisible=0;
			[App_Delegate updateHiddenStatusForTaskBelongCalendarId:project.primaryKey hidden:project.inVisible];
			[App_Delegate addTasksToListFromCalendarId:project.primaryKey];
            
            [project update];
		}
	}
	
	[tableView reloadData];
}

-(void)addProject:(id)sender{
	CalendarEditingViewController *ctrler = [[CalendarEditingViewController alloc] init];
	ctrler.editedKey=ADD_NEW;
	Projects *prj = [[Projects alloc] init];
	ctrler.editedCalendar=prj;
	ctrler.editedObject = prj;
	[ctrler reloadData];
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

- (IBAction)cancel:(id)sender {
	//ILOG(@"[ProjectViewController cancel\n");
    // cancel edits
	if(self.keyEdit==SETTING_PROJECTEDIT){
		//roll back changes
		
		//[projectList release];
		//projectList=[[NSMutableArray alloc] initWithArray:projectsListBackup];
		
	}
    [self.navigationController popViewControllerAnimated:YES];
	//ILOG(@"ProjectViewController cancel]\n");
}

/*
- (IBAction)save:(id)sender {
	//ILOG(@"[ProjectViewController save\n");
	switch (self.keyEdit) {
		case SETTING_PROJECTDEFAULT:
			[self.editedObject setProjectDefID:self.pathIndex];
			break;
		case TASK_EDITPROJECT:
			[self.editedObject setTaskProject:self.pathIndex];
			break;
	}
	isSaved=YES;
	[self.navigationController popViewControllerAnimated:YES];
	//ILOG(@"ProjectViewController save]\n");
}
*/

- (void)done:(id)sender{
	Projects *proj;
    NSMutableArray *projects=[NSMutableArray arrayWithArray:projectList];
	for(proj in projects){
		//EK Sync
		[proj setDirty:YES];
		[proj update];
	}
	isSaved=YES;
		
	[self.navigationController popViewControllerAnimated:YES];
	
	
}

-(void)calendarSelected:(id)sender{
	UIButton *bt=sender;
	bt.selected=!bt.selected;
	
	Projects *project=[taskmanager projectWithPrimaryKey:bt.tag];
	project.enableICalSync=bt.selected;
	[project update];
}

-(void)projectSelected:(id)sender{
	UIButton *bt=sender;
	bt.selected=!bt.selected;

	Projects *project=[taskmanager projectWithPrimaryKey:bt.tag];
	project.enableTDSync=bt.selected;
	[project update];
}

#pragma mark common methods
-(void)refreshTitleBarName{
	//ILOG(@"[ProjectViewController refreshTitleBarName\n");
	//if(self.keyEdit==SETTING_PROJECTDEFAULT||self.keyEdit==TASK_EDITPROJECT){
	//	self.navigationItem.title =NSLocalizedString(@"projectText", @"")/*projectText*/;//@"Projects";
	//}else if(self.keyEdit==SETTING_PROJECTEDIT){
	//	self.navigationItem.title =NSLocalizedString(@"editProjectText", @"")/*editProjectText*/;
	//}
	
	//ILOG(@"ProjectViewController refreshTitleBarName]\n");
	self.navigationItem.title=NSLocalizedString(@"projectsText",@"");;
}

#pragma mark -
#pragma mark <UITableViewDelegate, UITableViewDataSource> Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
    // 1 sections
//	if(self.keyEdit==SETTING_GCALPROJMAP)
		//return 2;
//		return projectList.count ;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
    // Only one row for each section
//	if(self.keyEdit==SETTING_GCALPROJMAP)
//		return 2;
	if (keyEdit==SETTING_PROJECTEDIT||keyEdit==PROJECT_SHOW_HIDE) {
		return projectList.count;
	}
	
	[self.visibleProjectList removeAllObjects];
    
    NSMutableArray *projects=[NSMutableArray arrayWithArray:projectList];
	for (Projects *project in projects) {
		if (!project.inVisible) {
			[self.visibleProjectList addObject:project];
		}
	}
	
	return self.visibleProjectList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//ILOG(@"[ProjectViewController cellForRowAtIndexPath\n");
	
 	//TableCellWithRightValue *cell =[(TableCellWithRightValue *)tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
	
	UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:@"MyIdentifier"] autorelease];
	}else {
		NSArray *arr=[cell subviews];
		for (id view in arr) {
			if ([arr isKindOfClass:[UIButton class]]) {
				[view removeFromSuperview];
			}
		}
	}

    NSMutableArray *projects=[NSMutableArray arrayWithArray:projectList];
	Projects *project=[projects objectAtIndex:indexPath.row];;

	if(self.keyEdit==SETTING_PROJECTDEFAULT || self.keyEdit==TASK_EDITPROJECT){
		project=[self.visibleProjectList objectAtIndex:indexPath.row];

		if(self.keyEdit==SETTING_PROJECTDEFAULT){
			if (project.primaryKey==taskmanager.currentSettingModifying.projectDefID) {
				cell.accessoryType= UITableViewCellAccessoryCheckmark;
				self.pathIndex=indexPath.row;
			}else {
				cell.accessoryType= UITableViewCellAccessoryNone;				
			}
		}else {
			if (project.primaryKey==[editedObject taskProject]) {
				cell.accessoryType= UITableViewCellAccessoryCheckmark;
				self.pathIndex=indexPath.row;
			}else {
				cell.accessoryType= UITableViewCellAccessoryNone;				
			}
		}

	}else if(self.keyEdit==SETTING_PROJECTEDIT){
		project=[projects objectAtIndex:indexPath.row];

		cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
	}else if (self.keyEdit==PROJECT_FILTER) {
		project=[self.visibleProjectList objectAtIndex:indexPath.row];

		if (project.isInFiltering) {
			cell.accessoryType= UITableViewCellAccessoryCheckmark;
		}else {
			cell.accessoryType= UITableViewCellAccessoryNone;
		}
		
	}else {
		cell.accessoryType= UITableViewCellAccessoryNone;
	}
		
	cell.textLabel.text =project.projName ;
	[cell.textLabel setTextColor:[ivoUtility getRGBColorForProject:project.primaryKey isGetFirstRGB:NO]];

	return cell;
}


- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section {
    // Return the displayed title for the specified section.	

	//if(self.keyEdit==SETTING_PROJECTEDIT){
	//	return @"                      Calendars     Projects";
	//}
	
	return @"";
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Never allow selection.
    if (self.editing) {
		saveButton.enabled=YES;
		return indexPath;
	}
    return nil;
}

/*- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	
	if(self.keyEdit==SETTING_PROJECTDEFAULT || self.keyEdit==TASK_EDITPROJECT){
		if(self.pathIndex>=0){
			NSIndexPath *selectedPath = [NSIndexPath indexPathForRow:self.pathIndex inSection:0];	
			if ([selectedPath compare:indexPath] == NSOrderedSame ) {
				return UITableViewCellAccessoryCheckmark;
			}
		}
		return UITableViewCellAccessoryNone;
	}else if(self.keyEdit==SETTING_PROJECTEDIT||keyEdit==SETTING_GCALPROJMAP){
		return UITableViewCellAccessoryDisclosureIndicator;
	}
	
	return UITableViewCellAccessoryNone;
}
*/

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	//ILOG(@"[ProjectViewController didSelectRowAtIndexPath\n");
	isGoingBack=NO;
	if(self.keyEdit==SETTING_PROJECTDEFAULT || self.keyEdit==TASK_EDITPROJECT){
		NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:self.pathIndex inSection:0];	
		[[table cellForRowAtIndexPath:oldIndexPath] setAccessoryType:UITableViewCellAccessoryNone];
		[[table cellForRowAtIndexPath:newIndexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
		self.pathIndex=newIndexPath.row;
		
		if ([self.editedObject isKindOfClass:[Task class]]) {
			Projects *project=[self.visibleProjectList objectAtIndex:self.pathIndex];
			[self.editedObject setTaskProject:project.primaryKey];
		}
		
    }else if(self.keyEdit==SETTING_PROJECTEDIT){
		if(newIndexPath.row>=0) {
			//EK Sync
			CalendarEditingViewController *ctrler = [[CalendarEditingViewController alloc] init];
			ctrler.editedKey=EDIT;
            NSMutableArray *projects=[NSMutableArray arrayWithArray:projectList];
			Projects *prj = [projects objectAtIndex:newIndexPath.row];
			ctrler.editedCalendar=prj;
			ctrler.editedObject = prj;
			[ctrler reloadData];
			[self.navigationController pushViewController:ctrler animated:YES];
			[ctrler release];	
			
		}
	}else if (self.keyEdit==PROJECT_FILTER) {
		Projects *project=[self.visibleProjectList objectAtIndex:newIndexPath.row];
		project.isInFiltering=!project.isInFiltering;
		
		if (project.isInFiltering) {
			[[table cellForRowAtIndexPath:newIndexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
		}else {
			[[table cellForRowAtIndexPath:newIndexPath] setAccessoryType:UITableViewCellAccessoryNone];
		}

		[project update];
	}else if (self.keyEdit==PROJECT_SHOW_HIDE) {
        
        NSMutableArray *projects=[NSMutableArray arrayWithArray:projectList];
		Projects *project=[projects objectAtIndex:newIndexPath.row];
        
        if (project.primaryKey!=taskmanager.currentSetting.projectDefID) {
            project.inVisible=!project.inVisible;
            
            [project update];
            [table deselectRowAtIndexPath:newIndexPath animated:YES];
            [table reloadData];		
            
            if (project.primaryKey==taskmanager.currentSetting.projectDefID) {
                
            }else {
                [App_Delegate updateHiddenStatusForTaskBelongCalendarId:project.primaryKey hidden:project.inVisible];
                
                if (project.inVisible) { 
                    [App_Delegate removeAllTasksBelongCalendar:project.primaryKey];
                }else {
                    [App_Delegate addTasksToListFromCalendarId:project.primaryKey];
                }
            } 
        }
	}
	
    [table deselectRowAtIndexPath:newIndexPath animated:YES];
	//ILOG(@"ProjectViewController didSelectRowAtIndexPath]\n");
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	if (self.keyEdit==PROJECT_SHOW_HIDE) {
        
        NSMutableArray *projects=[NSMutableArray arrayWithArray:projectList];
		Projects *project=[projects objectAtIndex:indexPath.row];
		if (project.inVisible) {
			//cell.backgroundView.backgroundColor=[UIColor lightGrayColor];
			//cell.contentView.backgroundColor=[UIColor lightGrayColor];
			//cell.textLabel.backgroundColor=[UIColor lightGrayColor];
			//cell.backgroundColor=[UIColor lightGrayColor];
            cell.accessoryType=UITableViewCellAccessoryNone;
		}else {
			//cell.backgroundView.backgroundColor=[UIColor whiteColor];
			//cell.contentView.backgroundColor=[UIColor whiteColor];
			//cell.textLabel.backgroundColor=[UIColor whiteColor];
			//cell.backgroundColor=[UIColor whiteColor];
            cell.accessoryType=UITableViewCellAccessoryCheckmark;
		}
	}
}


#pragma mark properties
-(NSInteger)pathIndex{
	return pathIndex;	
}

-(void)setPathIndex:(NSInteger)pathIdx{
	pathIndex=pathIdx;	
}


@end
