//
//  AlertEditController.m
//  iVo_NewAddTask
//
//  Created by Nang Le on 5/8/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AlertViewController.h"
#import "SmartTimeAppDelegate.h"
#import "Task.h"
#import "IvoCommon.h"
#import "TableCellWithRightValue.h"
#import "AlertValueViewController.h"
#import "Alert.h"
#import "ivo_Utilities.h"
#import "GuideWebView.h"
#import "AlertOptionForTaskViewController.h"

//extern NSMutableArray	*alertList;

extern ivo_Utilities *ivoUtility;
extern float OSVersion;

@implementation AlertViewController

@synthesize editedObject;;


/*
 This method is not invoked if the controller is restored from a nib file.
 All relevant configuration should have been performed in Interface Builder.
 If you need to do additional setup after loading from a nib, override -loadView.
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
		self.title = NSLocalizedString(@"alertText", "");
	}
	return self;
}


-(id) init{
	if(self = [super init]){
		self.title=NSLocalizedString(@"alertText", @"")/*alertText*/;
	}
	return self;	
}

- (void)loadView {
	//ILOG(@"[AlertViewController loadView\n");

	// Don't invoke super if you want to create a view hierarchy programmatically
	//[super loadView];
	UIBarButtonItem *saveButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
															  target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
	
	UIBarButtonItem *cancelButton= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
	tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.view = tableView;
	
	//alertValues=[[editedObject taskAlertValues] componentsSeparatedByString:@"/"];

	//ILOG(@"AlertViewController loadView]\n");
	
	}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

#pragma mark controller delegate
- (void)viewWillAppear:(BOOL)animated {
	[tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated{

}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    //[tableView reloadData];
}

#pragma mark action methods

- (IBAction)cancel:(id)sender {
    // cancel edits
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
	//[editedObject setTaskAlertID:self.pathIndex];
	NSString *alertStr=[NSString stringWithFormat:@""];
	for(NSInteger i=1;i<alertValues.count;i++){
		
		alertStr=[alertStr stringByAppendingString:[NSString stringWithFormat:@"/%@",(NSString *)[alertValues objectAtIndex:i]]];
	}
	[editedObject setTaskAlertValues:alertStr];
	[editedObject setIsChangedAlertSetting:YES];
	
	[self.navigationController popViewControllerAnimated:YES];
	
}

- (void)dealloc {
	tableView.dataSource=nil;
	tableView.delegate=nil;
	[tableView release];
	[editedObject release];
	[alertValues release];
	
	[super dealloc];
}
 
#pragma mark -
#pragma mark <UITableViewDelegate, UITableViewDataSource> Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
	if([editedObject taskPinned]==1)
		return 2;
    return 3;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
    // Only one row for each section
    //return alertList.count;
	if(section==0){
		return alertValues.count>5?5:alertValues.count;
	}else if(section==1){
		if([editedObject taskPinned]==1) goto notes;
		return 1;
	}else {
	notes:
		return 1;
	}


	return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if(indexPath.section==0){
		return 44;
	}else if(indexPath.section==1){
		if([editedObject taskPinned]==1) goto notes;
		return 44;
	}else{
	notes:
		//return 110;
		if([editedObject taskPinned]==1){
			return 280;
		}else {
			return 200;
		}

	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	switch (indexPath.section) {
		case 0:
		{
			TableCellWithRightValue *cell = (TableCellWithRightValue *)[tableView dequeueReusableCellWithIdentifier:@"AlertCell"];
			if (cell == nil) {
				// Create a new cell. CGRectZero allows the cell to determine the appropriate size.
				cell = [[[TableCellWithRightValue alloc] initWithFrame:CGRectZero reuseIdentifier:@"AlertCell"] autorelease];
			}

			
			if(indexPath.section==0){
				cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
			}else {
				cell.accessoryType=  UITableViewCellAccessoryNone;
			}
			
			cell.selectionStyle=UITableViewCellSelectionStyleBlue;
            
/*v5            
			switch (alertValues.count) {
				case 1:
					cell.textLabel.text=NSLocalizedString(@"addText", @"");
					cell.value.text=@"";
					return cell;
					break;
				case 2:
					if(indexPath.row==1){
						cell.textLabel.text=NSLocalizedString(@"addText", @"");
						cell.value.text=@"";
						return cell;
					}
					break;
				case 3:
					if(indexPath.row==2){
						cell.textLabel.text=NSLocalizedString(@"addText", @"");
						cell.value.text=@"";
						return cell;
					}
					break;
				case 4:
					if(indexPath.row==3){
						cell.textLabel.text=NSLocalizedString(@"addText", @"");
						cell.value.text=@"";
						return cell;
					}
					break;
				case 5:
					if(indexPath.row==4){
						cell.textLabel.text=NSLocalizedString(@"addText", @"");
						cell.value.text=@"";
						return cell;
					}
					break;
			}
			
			Alert *alert=[ivoUtility creatAlertFromList:alertValues atIndex:indexPath.row+1];
			cell.textLabel.text=[NSString stringWithFormat:@"%@",alert.alertByString];
			NSString *alertValueStr;
			if(alert.amount==0){
				if([editedObject taskPinned]==1){
					alertValueStr=NSLocalizedString(@"onDateEventText", @"");
				}else {
					alertValueStr=NSLocalizedString(@"specifiedTimeText", @"");
				}

			}else {
				alertValueStr=[[NSString stringWithFormat:@" %d %@ ",alert.amount,alert.timeUnitString] stringByAppendingString:NSLocalizedString(@"beforeText", @"")];
			}
			
			cell.value.text=alertValueStr;
			[alert release];
*/			
			
			return cell;
	
		}
			break;
			
		case 1:
			
		{
			if([editedObject taskPinned]==1) goto notes;
			
			TableCellWithRightValue *cell = (TableCellWithRightValue *)[tableView dequeueReusableCellWithIdentifier:@"AlertCell"];
			if (cell == nil) {
				// Create a new cell. CGRectZero allows the cell to determine the appropriate size.
				cell = [[[TableCellWithRightValue alloc] initWithFrame:CGRectZero reuseIdentifier:@"AlertCell"] autorelease];
			}
			
			switch (indexPath.row) {
				case 0:
				{				
					cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
					cell.selectionStyle=UITableViewCellSelectionStyleBlue;
					cell.textLabel.text=NSLocalizedString(@"timeText", @"")/*timeText*/;
					NSDate *taskTime;
					if ([editedObject isAdjustedSpecifiedDate]) {
						taskTime=[editedObject specifiedAlertTime];
					}else {
						if ([editedObject taskIsUseDeadLine]) {
							taskTime=[editedObject taskDeadLine];
						}else {
							taskTime = [[ivoUtility createDeadLine:-1 fromDate:[[NSDate date] dateByAddingTimeInterval:7*86400] context:[editedObject taskWhere]] autorelease];
							[editedObject setIsAdjustedSpecifiedDate:1];
						}
						[editedObject setSpecifiedAlertTime:taskTime];
					}

					NSString *alertDateStr=[ivoUtility createStringFromDate:taskTime isIncludedTime:YES];
					if([editedObject taskIsUseDeadLine]==1){
						cell.value.text=([editedObject alertByDeadline]==1?NSLocalizedString(@"dueDateText", @"")/*dueDateText*/:alertDateStr);
					}else {
						cell.value.text=alertDateStr;
					}

					[alertDateStr release];
				}
					break;
			}
			
			return cell;
		}		
			
		case 2:
		notes:
		{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlertCellNote"];
			if (cell == nil) {
				// Create a new cell. CGRectZero allows the cell to determine the appropriate size.
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"AlertCellNote"] autorelease];
			}else {
				NSArray *subviews=[cell.contentView subviews];
				
				for(UIView *view in subviews){
					if([view isKindOfClass:[GuideWebView class]]){
						[view removeFromSuperview];
					}
				}
			}

			
			if(indexPath.section==0){
				cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
			}else {
				cell.accessoryType=  UITableViewCellAccessoryNone;
			}
			
			cell.selectionStyle=UITableViewCellSelectionStyleNone;
			
			if([editedObject taskPinned]==1){
				GuideWebView *alertHint = [[GuideWebView alloc] initWithFrame:CGRectMake(10, 10, 290, 280)];
			
				if (OSVersion<=3.0) {
					[alertHint loadHTMLFile:@"EventAlertHint" extension:@"txt"];
				}else {
					[alertHint loadHTMLFile:@"EventAlertOS4Hint" extension:@"txt"];
				}

				
				
				[cell.contentView addSubview:alertHint];
			
				[alertHint release];			
			}else {
				cell.textLabel.numberOfLines=0;
				//cell.textLabel.textColor=[UIColor darkGrayColor];
				if (OSVersion<=3.0) {
					cell.textLabel.text=NSLocalizedString(@"taskPushHintMsg", @"")/*taskPushHintMsg*/;
				}else {
					cell.textLabel.text=NSLocalizedString(@"taskPushHintOS4Msg", @"")/*taskPushHintOS4Msg*/;
				}

				
			}

			return cell;
		}
			break;
	}
	
	
	return nil;
}

- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section {
    // Return the displayed title for the specified section.
	if(section==2) return NSLocalizedString(@"notesText", @"")/*notesText*/;
	
	return @"";
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Never allow selection.
//	if(indexPath.section==0)
	return indexPath;
	
//	return nil;
}

//- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
//	if(indexPath.section==0)
//		return UITableViewCellAccessoryDisclosureIndicator;
//
//	return UITableViewCellAccessoryNone;
//}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[table deselectRowAtIndexPath:indexPath animated:YES];
/*	if(indexPath.section==0){
		AlertValueViewController *alerValueView=[[AlertValueViewController alloc] init];
		switch (indexPath.row) {
			case 0:
				if(alertValues.count > 1){
					alerValueView.keyEdit=1;
					alerValueView.alertValuesStr=(NSString *)[alertValues objectAtIndex:1];
				}else {
					alerValueView.keyEdit=-1;
					alerValueView.alertValuesStr=@"";
				}
				break;
			case 1:
				if(alertValues.count > 2){
					alerValueView.keyEdit=2;
					alerValueView.alertValuesStr=(NSString *)[alertValues objectAtIndex:2];
				}else {
					alerValueView.keyEdit=-1;
					alerValueView.alertValuesStr=@"";
				}
				
				break;
			case 2:
				if(alertValues.count > 3){
					alerValueView.keyEdit=3;
					alerValueView.alertValuesStr=(NSString *)[alertValues objectAtIndex:3];
				}else {
					alerValueView.keyEdit=-1;
					alerValueView.alertValuesStr=@"";
				}
				
				break;
			case 3:
				if(alertValues.count > 4){
					alerValueView.keyEdit=4;
					alerValueView.alertValuesStr=(NSString *)[alertValues objectAtIndex:4];
				}else {
					alerValueView.keyEdit=-1;
					alerValueView.alertValuesStr=@"";
				}
				
				break;
			case 4:
				if(alertValues.count > 5){
					alerValueView.keyEdit=5;
					alerValueView.alertValuesStr=(NSString *)[alertValues objectAtIndex:5];
				}else {
					alerValueView.keyEdit=-1;
					alerValueView.alertValuesStr=@"";
				}
				
				break;
		}
		alerValueView.editedObject=self;
		alerValueView.taskPinned=[editedObject taskPinned];
		[alerValueView setEditing:YES animated:YES];
		[self.navigationController pushViewController:alerValueView animated:YES];
		[alerValueView release];
	}else if(indexPath.section==1){
		if([editedObject taskPinned]==1) return;
		
		AlertOptionForTaskViewController *viewController=[[AlertOptionForTaskViewController alloc] init];
		viewController.editedObject=self.editedObject;
		viewController.title=NSLocalizedString(@"alertTimeText", @"")
		[self.navigationController pushViewController:viewController animated:YES];
		[viewController release];
	}	
 */
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	if(indexPath.section==0){
		switch (alertValues.count) {
			case 1:
				return UITableViewCellEditingStyleNone;
				break;
			case 2:
				if(indexPath.row==1)
					return UITableViewCellEditingStyleNone;
				break;
			case 3:
				if(indexPath.row==2)
					return UITableViewCellEditingStyleNone;
				break;
			case 4:
				if(indexPath.row==3)
					return UITableViewCellEditingStyleNone;
				break;
			case 5:
				if(indexPath.row==4)
					return UITableViewCellEditingStyleNone;
				break;
		}
		
		return UITableViewCellEditingStyleDelete;	
	}
	
	return UITableViewCellEditingStyleNone;
}


- (void)tableView:(UITableView *)tV commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	[alertValues removeObject:[alertValues objectAtIndex:indexPath.row+1]];
	[tableView reloadData];
}

#pragma mark properties

-(NSMutableArray *)alertValues{
	return alertValues;
}

-(void)setAlertValues:(NSMutableArray *)arr{
	[alertValues release];
	
	alertValues=[[NSMutableArray alloc] initWithArray:arr];
}
@end
