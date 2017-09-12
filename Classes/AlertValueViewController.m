//
//  AlertValueViewController.m
//  SmartTime
//
//  Created by Nang Le on 11/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AlertValueViewController.h"
#import "ivo_Utilities.h"
#import "Colors.h"
#import "AlertViewController.h"
#import "SmartTimeAppDelegate.h"
#import "TaskManager.h"
#import "Task.h"

extern float OSVersion;
extern ivo_Utilities *ivoUtility;
extern NSMutableArray *alertList;
extern BOOL stopPushWarning;
extern TaskManager *taskmanager;
extern NSString *dev_token;
extern NSString *alertFromText;

extern NSString *onDateText;
extern NSString *ofDueText;
extern NSString *ofStartText;
extern NSString *ofEventText;

@implementation AlertValueViewController
@synthesize editedObject,keyEdit,taskPinned;

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
    
    noAlertSeleced=NO;
	self.title=NSLocalizedString(@"alertBeforeText", @"")/*alertBeforeText*/;
	
	//UIBarButtonItem *saveButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
	//																		   target:self action:@selector(save:)];
    //self.navigationItem.rightBarButtonItem = saveButton;
	//[saveButton release];
	
    CGRect frame=[[UIScreen mainScreen] bounds];
    
	contentView=[[UIView alloc] initWithFrame:CGRectZero];
	contentView.backgroundColor=[UIColor groupTableViewBackgroundColor];
	
	timerDPView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 84, 320, 280)];
	timerDPView.delegate=self;
	timerDPView.showsSelectionIndicator=YES;
	[contentView addSubview: timerDPView];
	[timerDPView release];
	
	if([self.editedObject taskPinned]==1){	
/*		UIView *optionView=[[UIView alloc] initWithFrame:CGRectMake(10, 220, 300, 185)];
		
		optionView.backgroundColor=[UIColor clearColor];
		
			UIImageView *section1ImgeView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];//160
			section1ImgeView.image=[UIImage imageNamed:@"AlertSection1.png"];
#ifdef FREE_VERSION	
#else
			//#ifdef ST_BASIC
			//#else
			// 09122901 un comment this for Push
			[optionView addSubview:section1ImgeView];
			//#endif		
#endif	
			[section1ImgeView release];
		APNSOptionButton=[ivoUtility createButton:(OSVersion<=3.0? NSLocalizedString(@"pushRequireMsg", @""):NSLocalizedString(@"localNotificationMsg", @""))
									   buttonType:UIButtonTypeCustom 
												frame:CGRectMake(0, 0, 320, 30) //160
										   titleColor:[UIColor blackColor] 
											   target:self 
											 selector:@selector(togglePin:) 
									 normalStateImage:@"Pin-Off.png" 
								   selectedStateImage:@"Pin-On.png"];
			APNSOptionButton.titleLabel.font=[UIFont systemFontOfSize:15];
			[APNSOptionButton setTitleColor:[Colors darkSteelBlue] forState :UIControlStateSelected];

        
#ifdef FREE_VERSION	
#else
//			[optionView addSubview:APNSOptionButton];
#endif
			[APNSOptionButton release];
		
		//Via Google... (requires  Google account
		UILabel *alertBy1=[[UILabel alloc] initWithFrame:CGRectMake(10, 45, 300, 20)];//0
		alertBy1.backgroundColor=[UIColor clearColor];
		alertBy1.text=NSLocalizedString(@"alertRequireMsg", @"")
		alertBy1.font=[UIFont italicSystemFontOfSize:14];
		alertBy1.textColor=[UIColor darkGrayColor];
		alertBy1.shadowColor=[UIColor lightGrayColor];
		
		
		UIImageView *section2ImgeView=[[UIImageView alloc] initWithFrame:CGRectMake(0,40, 300, 150)];//25
		section2ImgeView.image=[UIImage imageNamed:@"AlertSection2.png"];
		[optionView addSubview:section2ImgeView];
		[section2ImgeView release];
		
		[optionView addSubview:alertBy1];
		[alertBy1 release];

		smsOptionButton=[ivoUtility createButton:NSLocalizedString(@"smsButtonText", @"")
                                    buttonType:UIButtonTypeCustom 
										   frame:CGRectMake(0, 75, 320, 30) //35
									  titleColor:[UIColor blackColor] 
										  target:self 
										selector:@selector(togglePin:) 
								normalStateImage:@"Pin-Off.png" 
							  selectedStateImage:@"Pin-On.png"];
		smsOptionButton.titleLabel.font=[UIFont systemFontOfSize:15];
		[smsOptionButton setTitleColor:[Colors darkSteelBlue] forState :UIControlStateSelected];
		[optionView addSubview:smsOptionButton];
		[smsOptionButton release];
		
		popupOptionButton=[ivoUtility createButton:NSLocalizedString(@"popUpText",@"Pop-up                                                   ") buttonType:UIButtonTypeCustom 
						   //frame:CGRectMake(0, 50, 300, 30) 
											 frame:CGRectMake(0, 115, 320, 30) //75
										titleColor:[UIColor blackColor] 
											target:self 
										  selector:@selector(togglePin:) 
								  normalStateImage:@"Pin-Off.png" 
								selectedStateImage:@"Pin-On.png"];
		popupOptionButton.titleLabel.font=[UIFont systemFontOfSize:15];
		[popupOptionButton setTitleColor:[Colors darkSteelBlue] forState :UIControlStateSelected];
		[optionView addSubview:popupOptionButton];
		[popupOptionButton release];
		
		mailOptionButton=[ivoUtility createButton:NSLocalizedString(@"emailText", @"") buttonType:UIButtonTypeCustom 
						  //frame:CGRectMake(0, 90, 300, 30) 
											frame:CGRectMake(0, 155, 320, 30) //115
									   titleColor:[UIColor blackColor] 
										   target:self 
										 selector:@selector(togglePin:) 
								 normalStateImage:@"Pin-Off.png" 
							   selectedStateImage:@"Pin-On.png"];
		mailOptionButton.titleLabel.font=[UIFont systemFontOfSize:15];
		[mailOptionButton setTitleColor:[Colors darkSteelBlue] forState :UIControlStateSelected];
		[optionView addSubview:mailOptionButton];
		[mailOptionButton release];
		
		[contentView addSubview:optionView];
		[optionView release];
 */
	}else{
        
        if ([self.editedObject taskIsUseDeadLine]==1) {
            UILabel *alertBasedOnLb=[[UILabel alloc] initWithFrame:CGRectMake(20, 240+64, 200, 30)];
            alertBasedOnLb.backgroundColor=[UIColor clearColor];
            alertBasedOnLb.shadowColor=[UIColor lightGrayColor];
            alertBasedOnLb.textColor=[UIColor darkGrayColor];
            alertBasedOnLb.text=NSLocalizedString(@"alertFromText",@"");
            [contentView addSubview:alertBasedOnLb];
            [alertBasedOnLb release];
            
            UISegmentedControl *seg=[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects: NSLocalizedString(@"startText",@""),NSLocalizedString(@"dueText",@""),nil]];
            seg.frame=CGRectMake(160, 240+64, 140, 30);
            [seg addTarget:self action:@selector(alertBase:) forControlEvents:UIControlEventValueChanged];
            seg.selectedSegmentIndex=[self.editedObject alertBasedOn];
            [contentView addSubview:seg];
            [seg release];
        }
    }
	
    UIButton *noneBt=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    noneBt.frame=CGRectMake(20, 310+64, 280, 30);
    [noneBt setTitle:NSLocalizedString(@"noneText",@"") forState:UIControlStateNormal];
    [noneBt addTarget:self action:@selector(noneAlert:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:noneBt];
    
	self.view=contentView;
}


-(void)noneAlert:(id)sender{
    noAlertSeleced=YES;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)alertBase:(id)sender{
    UISegmentedControl *seg=sender;
    [self.editedObject setAlertBasedOn:seg.selectedSegmentIndex];
    
    [timerDPView reloadAllComponents];
}

/*
 
// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

-(void)save:(id)sender{
	/*
	NSString *alertStr=[NSString stringWithFormat:@"%d|%d|%d",[timerDPView selectedRowInComponent:0]==0? 0: 
						[[alertList objectAtIndex: [timerDPView selectedRowInComponent:0]] intValue],alertByVal,
						[timerDPView selectedRowInComponent:1]];
	//NSString *tmp; 
	switch (keyEdit) {
		 case 1://1 alert
			[[editedObject alertValues] removeObjectAtIndex:1];
			[[editedObject alertValues] insertObject:alertStr atIndex:1];
			 break;
		 case 2://2 alert
			[[editedObject alertValues] removeObjectAtIndex:2];
			[[editedObject alertValues] insertObject:alertStr atIndex:2];
			 break;
		 case 3://3 alert
			[[editedObject alertValues] removeObjectAtIndex:3];
			[[editedObject alertValues] insertObject:alertStr atIndex:3];
			 break;
		 case 4://4 alert
			[[editedObject alertValues] removeObjectAtIndex:4];
			[[editedObject alertValues] insertObject:alertStr atIndex:4];
			 break;
		 case 5://5 alert
			[[editedObject alertValues] removeObjectAtIndex:5];
			[[editedObject alertValues] insertObject:alertStr atIndex:5];
			 break;
		 case -1://new alert
			[[editedObject alertValues] addObject:alertStr]; 
			 break;
	 }
     */
    
	[self.navigationController popViewControllerAnimated:YES];	
}

- (void)viewWillAppear:(BOOL)animated {
    if ([self.editedObject alertIndex]==0) {
        isOnDateSelected=YES;
    }else{
        isOnDateSelected=NO;
    }
    
    [timerDPView reloadAllComponents];
    [timerDPView selectRow:[self.editedObject alertIndex] inComponent:0 animated:NO];
	[timerDPView reloadComponent:1];

    [timerDPView selectRow:[self.editedObject alertUnit] inComponent:1 animated:NO];

    /*
	if(alertValuesStr !=nil && ![alertValuesStr isEqualToString:@""]){
		NSArray *alertVals=[alertValuesStr componentsSeparatedByString:@"|"];
		//get index of value
		NSInteger i=0;
		for (NSString *str in alertList){
			if([str isEqualToString:[alertVals objectAtIndex:0]]){
				break;
			}
			i++;
		}
		
		[timerDPView selectRow:i inComponent:0 animated:YES];
		if([(NSString*)[alertVals objectAtIndex:0] intValue]!=0){
			isOnDateSelected=NO;
			[timerDPView reloadComponent:1];
		}
		[timerDPView selectRow:[(NSString*)[alertVals objectAtIndex:2] intValue] inComponent:1 animated:YES];
		alertByVal=[(NSString*)[alertVals objectAtIndex:1] intValue];
	}else {//add new, set default value
		[timerDPView selectRow:0 inComponent:0 animated:YES];
#ifdef FREE_VERSION
 		alertByVal=0;
#else
//#ifdef ST_BASIC
//		alertByVal=0;
//#else
		if(self.taskPinned==0){	
			alertByVal=3;
		}else{
			alertByVal=3;
		}
//#endif		
#endif		
	}

	[self resetAlertBy:alertByVal];
	*/
}

-(void)viewDidAppear:(BOOL)animated{
    //[timerDPView reloadAllComponents];
    
   // printf("\n: %d",[self.editedObject alertUnit]);
    //[self pickerView:timerDPView didSelectRow:[self.editedObject alertIndex] inComponent:0];
    //[self pickerView:timerDPView didSelectRow:[self.editedObject alertUnit] inComponent:1];
}

-(void)viewWillDisappear:(BOOL)animated{    
    if (noAlertSeleced) {
        [self.editedObject setHasAlert:0];
    }else{
        [self.editedObject setAlertIndex:[timerDPView selectedRowInComponent:0]];
        [self.editedObject setAlertUnit:[timerDPView selectedRowInComponent:1]];
        [self.editedObject setHasAlert:1];
    }
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
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[editedObject release];
	[contentView release];
    [super dealloc];
}

#pragma mark UIPickerView Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	switch (component) {
		case 0:
			return alertList.count;
			break;
		case 1:
			if(isOnDateSelected){
                return 1;
            }
			return 4;
			break;
	}
	return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
	switch (component) {
		case 0:
            if (row==0) {
                if ([self.editedObject taskPinned]==1) {
                    return [alertList objectAtIndex:row];
                }else{
                    return NSLocalizedString(@"onDateText",@"");
                }
            }
            
            return [alertList objectAtIndex:row];
            
			break;
		case 1:
			if(isOnDateSelected){
				switch (row) {
					case 0:
						if([self.editedObject taskPinned]==1){
							return NSLocalizedString(@"ofEventText",@"");
						}else {
							//return NSLocalizedString(@"specifiedText", @"specified");//@"specified";
                            if ([self.editedObject alertBasedOn]==0) {
                                return NSLocalizedString(@"ofStartText",@"");
                            }else{
                                return NSLocalizedString(@"ofDueText",@"");
                            }
						}

						break;
				}
			}else {
				switch (row) {
					case 0:
						return NSLocalizedString(@"minutesText", @"minutes");//@"minutes";
						break;
					case 1:
						return NSLocalizedString(@"hoursText", @"hours");//@"hours";
						break;
					case 2:
						return NSLocalizedString(@"daysText", @"days");//@"days";
						break;
					case 3:
						return NSLocalizedString(@"weeksText", @"weeks");//@"weeks";
						break;
				}
			}

			break;
	}
	
	return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
	switch (component) {
		case 0:
			if(row==0){
				isOnDateSelected=YES;
			}else {
				isOnDateSelected=NO;
			}

			[timerDPView reloadComponent:1];
			break;
		default:
			break;
	}
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
	return 40;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
	switch (component) {
		case 0:
			return 140;
			break;
		case 1:
			return 140;
			break;
	}
	return 0;
}

@end
