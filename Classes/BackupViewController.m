//
//  BackupViewController.m
//  SmartTime
//
//  Created by Nang Le on 10/28/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BackupViewController.h"
#import "ivo_Utilities.h"
#import "TableCellSettingAutoBump.h"
#import "SmartViewController.h"

extern ivo_Utilities		*ivoUtility;
extern SmartViewController *_smartViewController;

@implementation BackupViewController

/*
// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
	
	self.title=NSLocalizedString(@"backupButtonText", @"")/*backupButtonText*/;
	
	//CGRect tableViewFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height-5);
	tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	tableView.delegate = self;
	tableView.dataSource = self;
	self.view =tableView;

	backupToMailButton=[ivoUtility createButton:NSLocalizedString(@"backupButtonText", @"")/*backupButtonText*/
									 buttonType:UIButtonTypeRoundedRect 
										  frame:CGRectMake(230, 10, 70, 30) 
									 titleColor:[UIColor blackColor] 
										 target:self 
									   selector:@selector(backupToMail:) 
							   normalStateImage:@"no-mash-white.png" 
							 selectedStateImage:@"no-mash-blue.png"];
	
	noteLb=[[UILabel alloc] initWithFrame:CGRectMake(20, 30, 280, 270)];
	noteLb.numberOfLines=0;
	noteLb.textColor=[UIColor darkGrayColor];
	noteLb.font=[UIFont systemFontOfSize:14];
	//noteLb.text=@"This will backup your SmartTime data into an email.  Send this to your email account.  It is a good idea to save a copy on your iPhone and another copy on your desktop computer or email server.";

#ifdef FREE_VERSION
//	noteLb.text=NSLocalizedString(@"backupNotesLiteText", @"")/*backupNotesLiteText*/;
#else	
//	noteLb.text=NSLocalizedString(@"backupNotesText", @"")/*backupNotesText*/;
#endif	
}


/*
// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

-(void)backupToMail:(id)sender{
	[_smartViewController backupDataToMail];
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
	[backupToMailButton release];
	tableView.delegate=nil;
	tableView.dataSource=nil;
	[tableView release];
	[noteLb release];

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
		return @"";
}


#pragma mark -
#pragma mark === TableView delegate methods ===
#pragma mark -
// Specify the kind of accessory view (to the far right of each row) we will use
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
		return UITableViewCellAccessoryNone;
}

// Provide cells for the table, with each showing one of the available time signatures
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:{
			TableCellSettingAutoBump *cell = (TableCellSettingAutoBump *)[tableView dequeueReusableCellWithIdentifier:@"SettingSTSwithPushValue"];
			if (cell == nil) {
				cell = [[[TableCellSettingAutoBump alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingSTSwithPushValue"] autorelease];
			}
			cell.selectionStyle=UITableViewCellSelectionStyleNone;
			
			cell.bumpName.text=NSLocalizedString(@"backupCellTileText", @"")/*backupCellTileText*/;
			if([noteLb superview])
				[noteLb removeFromSuperview];
			cell.notes=noteLb;
			
			if([backupToMailButton superview])
				[backupToMailButton removeFromSuperview];

			cell.button=backupToMailButton;
			
			return cell;
			
			break;
		}
	}
	
	return nil;
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
	return 300;
}

@end
