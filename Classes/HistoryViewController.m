//
//  HistoryViewController.m
//  iVo
//
//  Created by Nang Le on 7/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HistoryViewController.h"
#import "TaskManager.h"
#import "SmartTimeAppDelegate.h"
#import "Colors.h"
#import "ivo_Utilities.h"
#import "Task.h"
#import "HistoryView.h"
#import "IvoCommon.h"

//extern Setting			*currentSetting;
extern SmartTimeAppDelegate	*App_Delegate;
extern TaskManager		*taskmanager;

@implementation HistoryViewController

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
	}
	return self;
}

- (void)loadView {
	//ILOG(@"[HistoryViewController loadView\n");
	
	self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
	
	self.navigationItem.title = NSLocalizedString(@"doneHistoryText", @"")/*doneHistoryText*/;
	
    CGRect frame=[[UIScreen mainScreen] bounds];
    
	contentView=[[HistoryView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-70)];
	contentView.backgroundColor=[UIColor groupTableViewBackgroundColor];
	
	self.view=contentView;
	//ILOG(@"HistoryViewController loadView]\n");
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


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[contentView release];
	[super dealloc];
}

#pragma mark controller delegate
// called after this controller's view will appear
- (void)viewWillAppear:(BOOL)animated
{	
	//ILOG(@"[HistoryViewController viewWillAppear\n");
	
//	[[contentView historyTableView] reloadData];
	//ILOG(@"HistoryViewController viewWillAppear]\n");
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
}

- (void)viewDidAppear:(BOOL)animated{
//	if(contentView.displayList.count>0){
//		[[contentView historyTableView] scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//	}
//
}

- (void)viewDidLoad {
}

#pragma mark action methods

#pragma mark properties

@end
