//
//  SetUpMailAccountViewController.m
//  SmartTime
//
//  Created by Nang Le on 10/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SetUpMailAccountViewController.h"
#import "Setting.h"
#import "IvoCommon.h"
#import "ivo_Utilities.h"
//#import "GCalSync.h"
#import "SmartTimeAppDelegate.h"

extern ivo_Utilities *ivoUtility;
extern BOOL isInternetConnected;

@implementation SetUpMailAccountViewController
@synthesize editedObject;//,userName,passWord;
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
	
	saveButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave  target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem=saveButton;
	//[saveBt release];
	
	contentView=[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	contentView.backgroundColor=[UIColor groupTableViewBackgroundColor];
	
	UILabel *userTitle=[[UILabel alloc] initWithFrame:CGRectMake(10, 10,300 , 20)];
	userTitle.text=NSLocalizedString(@"userNameText", @"")/*userNameText*/;
	userTitle.shadowColor=[UIColor lightGrayColor];
	userTitle.backgroundColor=[UIColor groupTableViewBackgroundColor];
	[contentView addSubview:userTitle];
	[userTitle release];
	
	userNameTextFiedl=[[UITextField alloc] initWithFrame:CGRectMake(10, 40,300 , 40)];
	userNameTextFiedl.borderStyle = UITextBorderStyleRoundedRect;
	//userNameTextFiedl.returnKeyType = UIReturnKeyDone;
	userNameTextFiedl.keyboardType = UIKeyboardTypeEmailAddress;
	userNameTextFiedl.autocapitalizationType=UITextAutocapitalizationTypeNone;
	userNameTextFiedl.font=[UIFont systemFontOfSize:18];
	userNameTextFiedl.clearButtonMode=UITextFieldViewModeWhileEditing;
	userNameTextFiedl.delegate = self;
	[contentView addSubview:userNameTextFiedl];

	UILabel *passwTitle=[[UILabel alloc] initWithFrame:CGRectMake(10, 90,300 , 20)];
	passwTitle.text=NSLocalizedString(@"passwordText", @"")/*passwordText*/;
	passwTitle.shadowColor=[UIColor lightGrayColor];
	passwTitle.backgroundColor=[UIColor groupTableViewBackgroundColor];
	[contentView addSubview:passwTitle];
	[passwTitle release];
	
	passWordTextFiedl=[[UITextField alloc] initWithFrame:CGRectMake(10, 120,300 , 40)];
	passWordTextFiedl.borderStyle = UITextBorderStyleRoundedRect;
	passWordTextFiedl.secureTextEntry = YES;
	passWordTextFiedl.font=[UIFont systemFontOfSize:18];
	passWordTextFiedl.clearButtonMode=UITextFieldViewModeWhileEditing;
	//passWordTextFiedl.returnKeyType = UIReturnKeyDone;
	passWordTextFiedl.delegate = self;
	[contentView addSubview:passWordTextFiedl];
	
	UIButton *checkButton=[ivoUtility createButton:NSLocalizedString(@"_checkAccountValidity", @"")
							  buttonType:UIButtonTypeRoundedRect 
								   frame:CGRectMake(80, 170, 160, 25) 
							  titleColor:nil 
								  target:self 
								selector:@selector(checkValidity:) 
								  normalStateImage:nil
								selectedStateImage:nil];						   
						//normalStateImage:@"no-mash-white.png"
					  //selectedStateImage:@"no-mash-blue.png"];
	[checkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	
	[contentView addSubview:checkButton];
	[checkButton release];
	
	self.view=contentView;
}

- (void)viewWillAppear:(BOOL)animated{
	[self deParseAccount:[editedObject gCalAccount]];
	userNameTextFiedl.text=self.userName;
	passWordTextFiedl.text=self.passWord;
	
	if(self.userName!=nil){
		saveButton.enabled=YES;
	}else {
		saveButton.enabled=NO;
	}

}

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
	[userNameTextFiedl becomeFirstResponder];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

-(void)checkValidity:(id)sender
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
	
	GCalSync *gcalSync = [GCalSync getInstance:userNameTextFiedl.text :passWordTextFiedl.text :nil];
	[gcalSync authenticate];
*/
}

- (void)dealloc {
	[userName release];
	[passWord release];
	userNameTextFiedl.delegate=nil;
	[userNameTextFiedl release];
	passWordTextFiedl.delegate=nil;
	[passWordTextFiedl release];
	[contentView release];
	[saveButton release];
	[editedObject release];
    [super dealloc];
}

#pragma mark action methods
-(void)save:(id)sender{
	[passWordTextFiedl resignFirstResponder];
	[userNameTextFiedl resignFirstResponder];

	NSString *account=[self createAccount:self.userName password:self.passWord];
	[editedObject setGCalAccount:account];
	[account release];
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark TextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
	if([textField isEqual:userNameTextFiedl]){
		[userNameTextFiedl resignFirstResponder];
		[passWordTextFiedl becomeFirstResponder];
	}else if([textField isEqual:passWordTextFiedl]){
		[passWordTextFiedl resignFirstResponder];
		[userNameTextFiedl becomeFirstResponder];
	}
	return YES;	
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
	//NSString *newText=[textField.text copy];
	if([textField isEqual:userNameTextFiedl]){
		self.userName=userNameTextFiedl.text;
	}else if([textField isEqual:passWordTextFiedl]){
		self.passWord=passWordTextFiedl.text;
	}
	
	//[newText release];
	
if(self.userName!=nil && ![[self.userName stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]){
		saveButton.enabled=YES;
	}else {
		saveButton.enabled=NO;
	}
	
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
//	NSString *oldText=[textField.text copy];
//	if([textField isEqual:taskTitleTextField]){
//		self.oldTaskName=oldText;
//	}else if([textField isEqual:taskLocation]){
		//
//	}
	
//	[oldText release];
}

#pragma mark common methods
-(void)deParseAccount:(NSString *)mixedAccount{
	if(mixedAccount !=nil){
		NSArray *account=[NSArray arrayWithArray:[mixedAccount componentsSeparatedByString:@"®"]];
		if(account.count==1){
			self.userName=[account objectAtIndex:0];
			self.passWord=@"";
		}else if(account.count==2){
			self.userName=[account objectAtIndex:0];
			self.passWord=[account objectAtIndex:1];
		}else {
			self.userName=@"";
			self.passWord=@"";
		}
	}else {
		self.userName=@"";
		self.passWord=@"";
	}
}

-(NSString *)createAccount:(NSString *)username password:(NSString *)password{
	return [[[username stringByAppendingString:@"®"] stringByAppendingString:password?password:@""] retain];
}

#pragma mark properties
-(NSString *)userName{
	return userName;
}

-(void)setUserName:(NSString *)str{
	[userName release];
	userName=[str copy];
}

-(NSString *)passWord{
	return passWord;
}

-(void)setPassWord:(NSString *)str{
	[passWord release];
	passWord=[str copy];
}

@end
