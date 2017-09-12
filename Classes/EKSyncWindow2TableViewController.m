//
//  SyncWindow2TableViewController.m
//  SmartTime
//
//  Created by Huy Le on 9/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EKSyncWindow2TableViewController.h"

#import "Setting.h"
#import "Colors.h"
#import "SmartTimeAppDelegate.h"
#import "TaskManager.h"
#import "Setting.h"

extern TaskManager *taskmanager;

@implementation EKSyncWindow2TableViewController

@synthesize setting;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)loadView 
{
	[super loadView];
	
	self.tableView.sectionFooterHeight = 20;
	CGRect frame=[[UIScreen mainScreen] bounds];
    
	syncFromTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 160, frame.size.height-62) style:UITableViewStyleGrouped];
	
	syncFromTableView.sectionHeaderHeight=5;
	syncFromTableView.sectionFooterHeight=1;
	syncFromTableView.delegate = self;
	syncFromTableView.dataSource = self;
	
	syncToTableView = [[UITableView alloc] initWithFrame:CGRectMake(160, 0, 160, frame.size.height-62) style:UITableViewStyleGrouped];
	
	syncToTableView.sectionHeaderHeight=5;
	syncToTableView.sectionFooterHeight=1;
	syncToTableView.delegate = self;
	syncToTableView.dataSource = self;
	
	syncFromIndex = self.setting.syncWindowStart;
	syncToIndex = self.setting.syncWindowEnd;
	
	self.navigationItem.title = NSLocalizedString(@"syncWindowText", @"");	
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

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	taskmanager.currentSettingModifying.syncWindowStart = syncFromIndex;
	taskmanager.currentSettingModifying.syncWindowEnd = syncToIndex;

}

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
	
	if ([tableView isEqual:self.tableView])
	{
		return 1;
	}
	
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([tableView isEqual:self.tableView])
	{
		return 418;
	}
	
	return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if ([tableView isEqual:self.tableView])
	{
		return NSLocalizedString(@"syncFromToText", @"");//@"   Sync From               Sync To";
	}
	
	return @"";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.font = [cell.font fontWithSize:16];
    
    // Set up the cell...
	
	if ([tableView isEqual:self.tableView])
	{
		[cell.contentView addSubview:syncFromTableView];
		[cell.contentView addSubview:syncToTableView];		
	}
	else if ([tableView isEqual:syncFromTableView])
	{
		switch (indexPath.row)
		{
			case 0:
			{
				cell.text = NSLocalizedString(@"syncBeginThisWeekText", @"");
			}
				break;			
			case 1:
			{
				cell.text = NSLocalizedString(@"syncLastWeekText", @"");
			}
				break;
			case 2:
			{
				cell.text = NSLocalizedString(@"syncLastMonthText", @"");
			}
				break;
			case 3:
			{
				cell.text = NSLocalizedString(@"syncLast3MonthText", @"");
			}
				break;
			case 4:
			{
				cell.text = NSLocalizedString(@"syncLastYearText", @"");
			}
				break;
			case 5:
			{
				cell.text = NSLocalizedString(@"syncAllPreviousText", @"");
			}
				break;			
		}
		
		if (indexPath.row == syncFromIndex)
		{
			[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
			cell.textColor=[Colors darkSteelBlue];
		}else {
			[cell setAccessoryType:UITableViewCellAccessoryNone];
			cell.textColor=[UIColor blackColor];
		}		
		
	}		
	else if ([tableView isEqual:syncToTableView])
	{
		switch (indexPath.row)
		{
			case 0:
			{
				cell.text = NSLocalizedString(@"syncEndThisWeekText", @"");;
			}
				break;			
			case 1:
			{
				cell.text = NSLocalizedString(@"syncNextWeekText", @"");;
			}
				break;
			case 2:
			{
				cell.text = NSLocalizedString(@"syncNextMonthText", @"");;
			}
				break;
			case 3:
			{
				cell.text = NSLocalizedString(@"syncNext3MonthText", @"");;
			}
				break;
			case 4:
			{
				cell.text = NSLocalizedString(@"syncNextYearText", @"");;
			}
				break;
			case 5:
			{
				cell.text = NSLocalizedString(@"syncAllForwardText", @"");;
			}
				break;			
		}
		
		if (indexPath.row == syncToIndex)
		{
			[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
			cell.textColor=[Colors darkSteelBlue];
		}else {
			[cell setAccessoryType:UITableViewCellAccessoryNone];
			cell.textColor=[UIColor blackColor];
		}		
		
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if ([tableView isEqual:syncFromTableView])
	{
		syncFromIndex = indexPath.row;
	}
	else if ([tableView isEqual:syncToTableView])
	{
		syncToIndex = indexPath.row;
	}
	
	[[tableView cellForRowAtIndexPath:indexPath] setTextColor:[Colors darkSteelBlue]];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	NSIndexPath *oldIndexPath = nil;
	
	if ([tableView isEqual:syncFromTableView])
	{
		oldIndexPath = [NSIndexPath indexPathForRow:syncFromIndex inSection:0];
	}
	else if ([tableView isEqual:syncToTableView])
	{
		oldIndexPath = [NSIndexPath indexPathForRow:syncToIndex inSection:0];
	}	
	
	[[tableView cellForRowAtIndexPath:oldIndexPath] setAccessoryType:UITableViewCellAccessoryNone];
	[[tableView cellForRowAtIndexPath:oldIndexPath] setTextColor:[UIColor blackColor]];
	
	[[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
	
	return indexPath;
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


- (void)dealloc {
	[syncFromTableView release];
	[syncToTableView release];
	
    [super dealloc];
}


@end

