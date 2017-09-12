//
//  WeekDaySettingViewController.m
//  SmartTime
//
//  Created by NangLe on 1/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WeekDaySettingViewController.h"
#import "IvoCommon.h"
#import "ivo_Utilities.h"
#import "SmartTimeAppDelegate.h"
#import "TaskManager.h"
#import "Setting.h"

extern TaskManager *taskmanager;
extern ivo_Utilities *ivoUtility;
extern NSString *WeekDay[];

@implementation WeekDaySettingViewController
@synthesize editedObject;

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		self.navigationItem.title=NSLocalizedString(@"workDaysText", @"")/*workDaysText*/;
		workDayStartOptionList=[[NSMutableArray alloc] init];
		NSInteger row=0;
		NSInteger col=0;
		for (NSInteger i=0;i<7;i++){
			
			UIButton *bt=[ivoUtility createButton:[NSString stringWithFormat:@"     %@", WeekDay[i]] buttonType:UIButtonTypeCustom 
											frame:CGRectMake(10 + col*70, 25 +row*40, 70, 40) 
									   titleColor:[UIColor blackColor] 
										   target:self 
										 selector:@selector(checkTapped:) 
								 normalStateImage:@"Check-Off.png" 
							   selectedStateImage:@"Check-On.png"];
			bt.tag=i+1;
			
			[workDayStartOptionList addObject:bt];
			[bt release];
			
			if(i/3*3==i && i>0){
				row+=1;
				col=0;
			}else {
				col++;
			}
		}
		
		workDayEndOptionList=[[NSMutableArray alloc] init];
		row=0;
		col=0;
		for (NSInteger i=0;i<7;i++){
			
			UIButton *bt=[ivoUtility createButton:[NSString stringWithFormat:@"     %@", WeekDay[i]] buttonType:UIButtonTypeCustom 
											frame:CGRectMake(10 + col*70, 25 +row*40, 70, 40) 
									   titleColor:[UIColor blackColor] 
										   target:self 
										 selector:@selector(checkTapped:) 
								 normalStateImage:@"Check-Off.png" 
							   selectedStateImage:@"Check-On.png"];
			bt.tag=i+1+7;
			
			[workDayEndOptionList addObject:bt];
			[bt release];
			
			if(i/3*3==i && i>0){
				row+=1;
				col=0;
			}else {
				col++;
			}
		}
		
		UIBarButtonItem *saveBatBt=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
																				 target:self 
																				 action:@selector(save:)];
		self.navigationItem.rightBarButtonItem=saveBatBt;
		[saveBatBt release];
		
		
    }
    return self;
}


/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
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


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }else {
		NSArray *subviews=[cell.contentView subviews];
		for (UIView *view in subviews){
			//if([view isKindOfClass:[UIButton class]]){
				[view removeFromSuperview];
			//}
		}
	}

	// Set up the cell...
    cell.selectionStyle=UITableViewCellSelectionStyleNone;

	switch (indexPath.row) {
		case 0:
		{
			cell.textLabel.text=@"";
			UILabel *title=[[UILabel alloc] initWithFrame:CGRectMake(10, 2, 150, 30)];
			title.backgroundColor=[UIColor clearColor];
			title.text=NSLocalizedString(@"workDayStartsText", @"")/*workDayStartsText*/;
			title.font=[UIFont boldSystemFontOfSize:16];
			[cell.contentView addSubview:title];
			[title release];
			
			for (UIButton *bt in workDayStartOptionList){
				if(bt.tag==[editedObject startWorkingWDay]){
					bt.selected=YES;
				}
				[cell.contentView addSubview:bt];
				
			}
		}
			break;
		case 1:
		{
			cell.textLabel.text=@"";
			UILabel *title=[[UILabel alloc] initWithFrame:CGRectMake(10, 2, 150, 30)];
			title.backgroundColor=[UIColor clearColor];
			title.text=NSLocalizedString(@"workDayEndsText", @"")/*workDayEndsText*/;
			title.font=[UIFont boldSystemFontOfSize:16];
			[cell.contentView addSubview:title];
			[title release];
			
			for (UIButton *bt in workDayEndOptionList){
				if(bt.tag-7==[editedObject endWorkingWDay]){
					bt.selected=YES;
				}
				[cell.contentView addSubview:bt];
			}
			
		}
			break;
		default:
			break;
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
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


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	return 110;
}

-(void)checkTapped:(id)sender{
	UIButton *bt=(UIButton *)sender;
	
	if(bt.tag<8){
		for(UIButton *button in workDayStartOptionList){
			button.selected=NO;
		}
	}else {
		for(UIButton *button in workDayEndOptionList){
			button.selected=NO;
		}
	}
	bt.selected=YES;	
}

-(void)save:(id)sender{
	NSInteger startDaySelected=0;
	NSInteger endDaySelected=0;
	
	for(UIButton *button in workDayStartOptionList){
		if(button.selected==YES){
			//[editedObject setStartWorkingWDay:button.tag];
			startDaySelected=button.tag;
			break;
		}
	}

	for(UIButton *button in workDayEndOptionList){
		if(button.selected==YES){
			//[editedObject setEndWorkingWDay:button.tag-7];
			endDaySelected=button.tag-7;
			break;
		}
	}
	
	NSInteger distance=endDaySelected-startDaySelected;
	if(distance<0){
		distance+=7;
	}
	
	if(distance==6){
		UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"weekendDayNeededMsg", @"") 
														  message:nil 
														 delegate:self
												cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/
												otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		return;
	}
	
	[editedObject setStartWorkingWDay:startDaySelected];
	[editedObject setEndWorkingWDay:endDaySelected];
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
	[workDayStartOptionList release];
	[workDayEndOptionList release];
    [super dealloc];
}


@end

