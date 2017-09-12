//
//  ProductListViewController.m
//  MugShotz
//
//  Created by Nang Le on 5/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ProductListViewController.h"
#import "ProductTableViewCell.h"
#import "TaskManager.h"
#import "Setting.h"
#import "IvoCommon.h"

extern TaskManager *taskmanager;
@implementation ProductListViewController
@synthesize loadingMode;

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
/*	
#ifdef FREE_VERSION
	if(taskmanager.currentSetting.numberOfRestartTimes<5){
		if(self.loadingMode==0){
			UIBarButtonItem *nilBarBt=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace 
																					target:self 
																					action:@selector(goToMainView:)];
			self.navigationItem.leftBarButtonItem=nilBarBt;
			[nilBarBt release];
			
			UIBarButtonItem *goBarBt=[[UIBarButtonItem alloc] initWithTitle:@"Go >>" 
																	  style:UIBarButtonItemStyleDone 
																	 target:self
																	 action:@selector(goToMainView:)];
			self.navigationItem.rightBarButtonItem=goBarBt;
			[goBarBt release];
		}else {
			self.navigationItem.leftBarButtonItem=nil;
			self.navigationItem.rightBarButtonItem=nil;
		}
	}
#endif
*/
    
    CGRect frame=[[UIScreen mainScreen] bounds];
	self.navigationItem.title=@"By Left Coast Logic";
	productTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, frame.size.height-65) style:UITableViewStylePlain];
	productTableView.delegate=self;
	productTableView.dataSource=self;
	productTableView.backgroundColor=[UIColor colorWithRed:160.0/255 green:160.0/255 blue:163.0/255 alpha:1];
	productTableView.separatorColor=[UIColor grayColor];
	
	self.view=productTableView;
	[productTableView release];
}

-(void)viewWillAppear:(id)sender{
	self.navigationController.navigationBarHidden=NO;
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

-(void)viewWillDisappear:(BOOL)animated{
	self.navigationItem.leftBarButtonItem=nil;
	self.navigationItem.rightBarButtonItem=nil;
}

-(void)goToMainView:(id)sender{
	[self.navigationController popViewControllerAnimated:NO];
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
	return 7;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// this table has only one section
	return @"";
}

#pragma mark -
#pragma mark === TableView delegate methods ===
#pragma mark -
// Specify the kind of accessory view (to the far right of each row) we will use
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	//return UITableViewCellAccessoryNone;
	return UITableViewCellAccessoryDisclosureIndicator;
}

// Provide cells for the table, with each showing one of the available time signatures
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//ILOG(@"[ListTaskView cellForRowAtIndexPath\n");
	
	ProductTableViewCell *cell = (ProductTableViewCell *)[productTableView dequeueReusableCellWithIdentifier:@"myIdentify"];
	if (cell == nil) {
		cell = [[[ProductTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"myIdentify"] autorelease];
	}
	else {
/*		cell.iconImageView.image=nil;
		cell.header.text=@"";
		cell.body.text=@"";
		cell.footer.text=@"";
*/
		[cell setHeaderText:@""];
		[cell setBodyText:@""];
		[cell setFooterText:@""];
		[cell setDetailDescriptionText:@"" withHeight:77];
		[cell setPriceText:@""];
		[cell setImage:nil];
		
	}


	switch (indexPath.row) {
		case 0://ST
			[cell setHeaderText:@"Productivity, Business, Education"];
			[cell setBodyText:@"SmartTime Pro"];
			[cell setFooterText:@"\"Finally, an organizer with a brain\""];
			//[cell setDetailDescriptionText:@"All the features of SmartTime Plus:\n• Week View\n• Month View\n• Sync all of your Tasks and Events to Google Calendar\n• Specify sync windows\n• Sync with shared calendars and public calendars\n• Integration with iPhone:  Direct dialing, Google Maps, share tasks via email\n• Create and manage alerts for your Events (via GCal)\n• New features being developed" withHeight:320];
			[cell setDetailDescriptionText:@"All the features of SmartTime Tasks, plus\n• Calendar View with one-tap Event creation\n• Focus View\n• History View\n• Landscape Week View with Day details\n• Free time-at-a-glance in Week View\n• Landscape Month View with Day details\n• Life Balance shading in Month View" withHeight:250];
			//[cell setPriceText:@"$9.99"];
			[cell setImage:[UIImage imageNamed:@"STIcon.png"]];
			break;
		case 1://ST_BASIC
			[cell setHeaderText:@"Business, Productivity"];
			[cell setBodyText:@"SmartTime Tasks"];
			[cell setFooterText:@"\"Looks at your Appointments, finds time for your tasks\""];
			[cell setDetailDescriptionText:@"All the features of SmartTime Free, plus\n• Google Sync (Events and Tasks!)\n• SMS alerts via Google Calendar\n• Pop-up alerts via GCal to iPhone Calendar\n• Google Maps integration\n• Direct dial contacts from your schedule\n• Direct SMS contacts from your schedule\n• Share Smart items with other SmartTime users\n• 12 different task & event categories and colors\n• Backup via email" withHeight:320];
			//[cell setPriceText:@"$9.99"];
			[cell setImage:[UIImage imageNamed:@"STTM.png"]];
			
			break;
		case 2://ST_FREE
			[cell setHeaderText:@"Productivity, Business, Education"];
			[cell setBodyText:@"SmartTime Free"];
			[cell setFooterText:@"\"Rated 9 stars by AppCraver\""];
			[cell setDetailDescriptionText:@"• Unique Smart View integrates Tasks and Events\n• Looks for your Events, then finds time for your Tasks\n• Dynamic Day Line shows what you can accomplish today\n• Flexible Filters (GTD and Franklin Covey -friendly)\n• Work and Home contexts\n• Contacts list integration\n• Quick Add for Tasks and Events\n• Use Action Icons, no need for keyboard" withHeight:300];
			//[cell setPriceText:@"$9.99"];
			[cell setImage:[UIImage imageNamed:@"STFree.png"]];
			break;
		case 3://CR
			[cell setHeaderText:@"Productivity, Entertainment, Audio"];
			[cell setBodyText:@"SmartTunes"];
			[cell setFooterText:@"\"Over 100 stations to wake up or sleep to...\""];
			[cell setDetailDescriptionText:@"All the features of SmartTunes:\n• Eye pleasing design\n• 300 radio stations\n• Wake up to music\n• Radio fade out at night before you sleep\n• Timer function to stop radio\n• Many skins to choose from!\n• Signal indicator for radio reception\n• On/Off light indicator\n• Display any picture from your photo album for wake up or sleep profiles\n• Create many \"wake\" or \"sleep\" profiles to wake you or soothe you to sleep" withHeight:320];
			//[cell setPriceText:@"$1.99"];			
			[cell setImage:[UIImage imageNamed:@"WT_icon.png"]];
			break;
		case 4://SQ
			[cell setHeaderText:@"Productivity, Entertainment"];
			[cell setBodyText:@"Shoot2Quill"];
			[cell setFooterText:@"\"Improve your texting, save the World\""];
			[cell setDetailDescriptionText:@"All the features of Shoot2Quill:\n• Use the keyboard to shoot \"letter bombs\" and space ships out of the sky\n• Multiple levels of increasing difficulty with original stereo soundtracks\n• Plug in your earphones and blast (type) away!\n• Compare your high scores with others\n• If you get to Level 5 and still think you\'re hot stuff, shift into overdrive by switching to \"Top Gun\" mode" withHeight:260];
			//[cell setPriceText:@"$2.99"];			
			[cell setImage:[UIImage imageNamed:@"S2Qicon.png"]];
			break;
		case 5://FF
			[cell setHeaderText:@"Entertainment, Photography"]; 
			[cell setBodyText:@"FotoFlair"];
			[cell setFooterText:@"\"Fotographic Fun\""];
			[cell setDetailDescriptionText:@"All the features of Foto Flair:\n• Take a photo with the iPhone camera, or import from your Photo Album\n• Drag flair with your finger from the drawer directly onto a photo\n• Resize flair with a pinch of your fingers, change the angle too!\n• Drag and drop into the trash can to delete\n• Save to the film roll, or email directly using Gmail" withHeight:260];
			//[cell setPriceText:@"$1.99"];
			[cell setImage:[UIImage imageNamed:@"FFicon.png"]];
			break;
		case 6://iQ
			[cell setHeaderText:@"Photography, Social Networking"];
			[cell setBodyText:@"Qamera"];
			[cell setFooterText:@"\"See the world\""];
			[cell setImage:[UIImage imageNamed:@"Qicon.png"]];
			break;
			
	}
		
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	if((indexPath.row/2)*2==indexPath.row){
		cell.backgroundColor=[UIColor colorWithRed:172.0/255 green:172.0/255 blue:176.0/255 alpha:1];
		
	}else{
		cell.backgroundColor=[UIColor colorWithRed:152.0/255 green:152.0/255 blue:156.0/255 alpha:1];
	}
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	switch (newIndexPath.row) {
		case 0://ST
		{
			NSString *bodyStr = [NSString stringWithFormat:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=295845767&mt=8"];
			NSString *encoded = [bodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSURL *url = [[NSURL alloc] initWithString:encoded];
			
			[[UIApplication sharedApplication] openURL:url];
			
			[url release];
		}
			break;
		case 1://STTM
		{
			NSString *bodyStr = [NSString stringWithFormat:@"http://leftcoastlogic.com/sttm"];
			NSString *encoded = [bodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSURL *url = [[NSURL alloc] initWithString:encoded];
			
			[[UIApplication sharedApplication] openURL:url];
			
			[url release];
		}
			break;
		case 2://ST Free
		
			break;
		case 3://CR
		{
			NSString *bodyStr = [NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=318891941&mt=8"];
			NSString *encoded = [bodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSURL *url = [[NSURL alloc] initWithString:encoded];
			
			[[UIApplication sharedApplication] openURL:url];
			
			[url release];
		}
			break;
		case 4://S2Q
		{
			NSString *bodyStr = [NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=317937073&mt=8"];
			NSString *encoded = [bodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSURL *url = [[NSURL alloc] initWithString:encoded];
			
			[[UIApplication sharedApplication] openURL:url];
			
			[url release];
			
		}
			break;
		case 5://FF
		{
			NSString *bodyStr = [NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=318063904&mt=8"];
			NSString *encoded = [bodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSURL *url = [[NSURL alloc] initWithString:encoded];
			
			[[UIApplication sharedApplication] openURL:url];
			
			[url release];
		}
			break;
		case 6://iQ
		{
			NSString *bodyStr = [NSString stringWithFormat:@"http://www.leftcoastlogic.com/products/"];
			NSString *encoded = [bodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSURL *url = [[NSURL alloc] initWithString:encoded];
			
			[[UIApplication sharedApplication] openURL:url];
			
			[url release];
		}
			break;
	}
		[table deselectRowAtIndexPath:newIndexPath animated:YES];	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	switch (indexPath.row) {
		case 0:
			return 250;
			break;
		case 1:
			return 310;
			break;
		case 2:
			return 300;
			break;
		case 3:
			return 320;
			break;
		case 4:
			return 260;
			break;
		case 5:
			return 260;
			break;
		case 6:
			return 77;
			break;
		default:
			return 77;
			break;
	}
	return 77;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)table editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	return UITableViewCellEditingStyleNone;	
}

@end
