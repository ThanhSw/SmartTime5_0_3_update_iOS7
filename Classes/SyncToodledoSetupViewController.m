    //
//  SyncToodledoSetupViewController.m
//
//  Created by NangLe on 5/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SyncToodledoSetupViewController.h"
#import "Setting.h"
#import "TaskManager.h"
#import "SmartViewController.h"
#import "IvoCommon.h"
#import "ivo_Utilities.h"
//#import "ToodleSync.h"
#import "SmartTimeAppDelegate.h"

extern TaskManager *taskmanager;
extern SmartTimeAppDelegate *App_Delegate;
extern BOOL	isInternetConnected;

@implementation SyncToodledoSetupViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	self.navigationItem.title=NSLocalizedString(@"toodledoAccountSetupText", @"Toodledo Account setup");
	
	
	UIView *contentView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 480, 290)];
	contentView.backgroundColor=[UIColor groupTableViewBackgroundColor];

	usernameTf=[[UITextField alloc] initWithFrame:CGRectMake(20, 10, 280, 30)];
	usernameTf.delegate=self;
	usernameTf.placeholder=NSLocalizedString(@"lUserNameText", @"User Name");
	usernameTf.keyboardType=UIKeyboardTypeEmailAddress;
	usernameTf.returnKeyType=UIReturnKeyDone;
	usernameTf.autocapitalizationType= UITextAutocapitalizationTypeNone;
	usernameTf.borderStyle=UITextBorderStyleRoundedRect;
	usernameTf.clearButtonMode=UITextFieldViewModeWhileEditing;
	[contentView addSubview:usernameTf];
	//[usernameTf becomeFirstResponder];
	[usernameTf release];
	
	passwordTf=[[UITextField alloc] initWithFrame:CGRectMake(20, 50, 280, 30)];
	passwordTf.delegate=self;
	passwordTf.placeholder=NSLocalizedString(@"paswordText", @"Password");
	passwordTf.keyboardType=UIKeyboardTypeDefault;
	passwordTf.returnKeyType=UIReturnKeyDone;
	passwordTf.borderStyle=UITextBorderStyleRoundedRect;
	passwordTf.clearButtonMode=UITextFieldViewModeWhileEditing;
	passwordTf.secureTextEntry=YES;
	[contentView addSubview:passwordTf];
	[passwordTf release];
	
	UIButton *verifyBt=[UIButton buttonWithType:UIButtonTypeRoundedRect];
	verifyBt.frame=CGRectMake(100, 100, 120, 30);
	[verifyBt addTarget:self action:@selector(verify:) forControlEvents:UIControlEventTouchUpInside];
	[verifyBt setTitle:NSLocalizedString(@"checkValidityText", @"") forState:UIControlStateNormal];
	[contentView addSubview:verifyBt];
	
	self.view=contentView;
	[contentView release];
}
	 
-(void)viewWillAppear:(BOOL)animated{
	usernameTf.text=taskmanager.currentSettingModifying.toodledoUserName;
	passwordTf.text=taskmanager.currentSettingModifying.toodledoPassword;
}

-(void)viewDidAppear:(BOOL)animated{
	[usernameTf becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated{
	[usernameTf resignFirstResponder];
	[passwordTf resignFirstResponder];
	
//	if (![taskmanager.currentSetting.toodledoUserName isEqualToString:usernameTf.text]
//		|| ![taskmanager.currentSetting.toodledoPassword isEqualToString:passwordTf.text]) {
		taskmanager.currentSettingModifying.toodledoUserName=usernameTf.text;
		taskmanager.currentSettingModifying.toodledoPassword=passwordTf.text;
		taskmanager.currentSettingModifying.toodledoKey=@"";
		taskmanager.currentSettingModifying.toodledoToken=@"";
		taskmanager.currentSettingModifying.toodledoUserId=@"";
		
		[taskmanager.currentSettingModifying update];
//	}
}





// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	//return NO;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)verify:(id)sender{
	if (!isInternetConnected) {
		UIAlertView *errorAlert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"noInternetConnectionText", @"")
														   message:NSLocalizedString(@"noInternetConnectionMsg", @"") 
														  delegate:nil
												 cancelButtonTitle:NSLocalizedString(@"okText", @"")
												 otherButtonTitles:nil];
		
		[errorAlert show];
		[errorAlert release];
		
	}else {
		ToodleSync *td=[[ToodleSync alloc] initWithCheckValidity:usernameTf.text password:passwordTf.text];
		[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(validateResult:) userInfo:td repeats:YES];
		[td release];
	}
}

-(void)validateResult:(id)sender{
	NSTimer *tmr=sender;
	ToodleSync *obj=[tmr userInfo];
	if (obj.isFinishedGetUserId) {
		
		UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:([obj.accValueStr isEqualToString:@"0"] || [obj.accValueStr isEqualToString:@"1"])?NSLocalizedString(@"failedText", @""):NSLocalizedString(@"successText",@"") 
														  message:([obj.accValueStr isEqualToString:@"0"] || [obj.accValueStr isEqualToString:@"1"])?NSLocalizedString(@"accountInValidateMsg", @""):NSLocalizedString(@"accountValidateMsg",@"")
														 delegate:nil
												cancelButtonTitle:NSLocalizedString(@"okText", @"OK")
												otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		
		[tmr invalidate];
		tmr=nil;
		
		//[obj release];
	}
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	return YES;
}


#pragma mark AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

}
*/
@end
