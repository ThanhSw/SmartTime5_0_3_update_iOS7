//
//  GCalSyncGuideViewController.m
//  SmartTime
//
//  Created by Nang Le on 1/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GCalSyncGuideViewController.h"
#import "IvoCommon.h"

#import "GuideWebView.h"

@implementation GCalSyncGuideViewController

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
- (void)loadView {
	tableView=[[UITableView alloc] initWithFrame:CGRectZero];
	tableView.delegate=self;
	tableView.dataSource=self;
	tableView.backgroundColor=[UIColor groupTableViewBackgroundColor];
	self.view=tableView;
	[tableView release];
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark === TableView datasource methods ===
#pragma mark -

// As the delegate and data source for the table, the PreferencesView must respond to certain methods the table view
// will call to get the number of sections, the number of rows, and the cell for a row.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return nil;
}


#pragma mark -
#pragma mark === TableView delegate methods ===
#pragma mark -
// Specify the kind of accessory view (to the far right of each row) we will use
//- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
//		return UITableViewCellAccessoryNone;
//}

// Provide cells for the table, with each showing one of the available time signatures
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"SettingSTValue"];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingSTValue"] autorelease];
	}
	cell.selectionStyle=UITableViewCellSelectionStyleNone;
	
/*	
	UILabel *guideTextLb=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 280, 1180)];
	guideTextLb.backgroundColor=[UIColor clearColor];
	guideTextLb.numberOfLines=0;
#ifdef FREE_VERSION
	guideTextLb.text=guideContent4LiteText;
#else
	guideTextLb.text=guideContentText;
#endif
	[cell.contentView addSubview:guideTextLb];
	[guideTextLb release];
*/
	GuideWebView *guide = [[GuideWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 800)];
	
#ifdef FREE_VERSION
	[guide loadHTMLFile:@"SyncLiteGuide" extension:@"txt"];
#else
	[guide loadHTMLFile:@"SyncGuide" extension:@"txt"];	
#endif
	
	[cell.contentView addSubview:guide];
	[guide release];
	
	return cell;
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	[table deselectRowAtIndexPath:newIndexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
	return;
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
	
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	return UITableViewCellEditingStyleNone;	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 800;
}


@end
