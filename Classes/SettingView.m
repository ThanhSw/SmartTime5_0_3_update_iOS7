//
//  SettingView.m
//  iVoProtoTypes
//
//  Created by Nang Le on 6/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SettingView.h"
#import "SmartTimeAppDelegate.h"
#import "Projects.h"
#import "Setting.h"
#import "ivo_Utilities.h"
#import "InfoEditViewController.h"
#import "IvoCommon.h"
#import "SmartViewController.h"
#import "Colors.h"
#import "TableCellWithRightValue.h"
#import "TableCellSettingContext.h"
#import "TableCellSettingAutoBump.h"
#import "SetUpMailAccountViewController.h"
#import "GCalSyncGuideViewController.h"
#import "EKSyncWindow2TableViewController.h"
#import "EKSync.h"
#import "ReminderSync.h"

extern NSMutableArray	*projectList;
extern NSMutableArray	*contextList;
extern NSMutableArray	*iVoStyleList;
extern NSMutableArray	*repeatList;
extern NSMutableArray	*taskMovingStypeList;
extern NSMutableArray	*deadlineExpandList;
extern ivo_Utilities	*ivoUtility;
extern TaskManager		*taskmanager;
extern NSMutableArray	*syncTypeList;
extern	SmartTimeAppDelegate	*App_Delegate;
extern SmartViewController *_smartViewController;

extern NSMutableArray			*originalGCalList;
extern NSMutableArray			*originalGCalColorList;

extern NSString *synchronizationText;
extern NSString *iPadCalendarSyncText;
extern NSString  *syncNowText;
extern NSString *autoSyncText;

//extern Setting			*currentSettingModifying;
extern BOOL _is24HourFormat;

extern NSString *WeekDay[];
extern NSString *alertUnitList[];

extern NSString *syncEventOnlyText;
extern NSString *iPhoneReminderText;
extern NSString *tasksAndEventsText;
extern NSString *eventsOnlyText;

#define kInAppPurchaseProUpgradeProductId @"com.runmonster.runmonsterfree.upgradetopro"

@implementation SettingView
@synthesize pathIndex,rootViewController,pushForward,changeDeadline,bumpTaskDescr,bumpDeadlineDescr,deleteDupButon;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		
		CGRect tableViewFrame = CGRectMake(0, 0, frame.size.width, frame.size.height-5);
		tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStyleGrouped];
		//tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
		tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		tableView.sectionHeaderHeight=40;
		tableView.sectionFooterHeight=1;
		tableView.delegate = self;
		tableView.dataSource = self;
		[self addSubview:tableView];
		[tableView release];
		
		pushForward=[[UISwitch alloc] initWithFrame:CGRectMake(220,8, 80, 40)];
		[pushForward addTarget:self action:@selector(pushTask:) forControlEvents:UIControlEventValueChanged];
		
		deleteWarning=[[UISwitch alloc] initWithFrame:CGRectMake(220,8, 80, 40)];
		[deleteWarning addTarget:self action:@selector(deleteWarning:) forControlEvents:UIControlEventValueChanged];
		
		
		bumpTaskDescr=[[UILabel alloc] initWithFrame:CGRectMake(20, 30, 280, 70)];
		bumpTaskDescr.textColor=[UIColor darkGrayColor];
		bumpTaskDescr.font=[UIFont systemFontOfSize:14];
		bumpTaskDescr.numberOfLines=0;
		bumpTaskDescr.backgroundColor=[UIColor clearColor];
		
		changeDeadline=[[UISwitch alloc] initWithFrame:CGRectMake(210,8, 80, 40)];
		[changeDeadline addTarget:self action:@selector(changeDeadline:) forControlEvents:UIControlEventValueChanged];
		
		bumpDeadlineDescr=[[UILabel alloc] initWithFrame:CGRectMake(20, 30, 280, 50)];
		bumpDeadlineDescr.textColor=[UIColor darkGrayColor];
		bumpDeadlineDescr.font=[UIFont systemFontOfSize:14];
		bumpDeadlineDescr.numberOfLines=0;
		bumpDeadlineDescr.backgroundColor=[UIColor clearColor];
		
#ifdef ST_BASIC
		[self requestProductData];
#endif
		
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	// Drawing code
}

-(void)resetData{
	[tableView reloadData];
}

- (void)dealloc {
	[rootViewController release];
	rootViewController=nil;

	[pushForward removeFromSuperview];
	[pushForward release];
	pushForward=nil;
	
	[bumpTaskDescr removeFromSuperview];
	[bumpTaskDescr release];
	bumpTaskDescr=nil;
	
	[changeDeadline removeFromSuperview];
	[changeDeadline release];
	changeDeadline=nil;
	
	[bumpDeadlineDescr removeFromSuperview];
	[bumpDeadlineDescr release];
	bumpDeadlineDescr=nil;
	
	
	//[tableView removeFromSuperview];
	tableView.delegate=nil;
	tableView.dataSource=nil;
	//[tableView release];
	//tableView=nil;
	
	[deleteWarning release];
	[super dealloc];
}

#pragma mark -
#pragma mark === TableView datasource methods ===
#pragma mark -

// As the delegate and data source for the table, the PreferencesView must respond to certain methods the table view
// will call to get the number of sections, the number of rows, and the cell for a row.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {

	if(section==0){
		return 6;
	}else if(section==1){
		if (taskmanager.currentSettingModifying.enableSyncICal==1 || taskmanager.currentSettingModifying.enabledReminderSync==1) {

            return 4;
		}
		return 2;
		
	}else if(section==2){
		return 8;	
	}else if(section==3){
		return 3;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if(section==0){
		return NSLocalizedString(@"generalSettingSectionText", @"")/*generalSettingSectionText*/;
	}else if(section==1){
		//return NSLocalizedString(@"_eventSyncText", @"");
		return NSLocalizedString(@"synchronizationText",@"");
	}else if(section==2){
		return NSLocalizedString(@"smarttimeSettingSectionText", @"")/*smarttimeSettingSectionText*/;
	}else{
		return NSLocalizedString(@"defaultValuesSettingSectionText", @"")/*defaultValuesSettingSectionText*/;
	}
	return nil;
}

#pragma mark -
#pragma mark === TableView delegate methods ===
#pragma mark -
// Specify the kind of accessory view (to the far right of each row) we will use
/*
 - (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
#ifdef FREE_VERSION
	if((indexPath.section==1 && (indexPath.row==2||indexPath.row==3)) ||
	   indexPath.section==0&&indexPath.row==2){
		return UITableViewCellAccessoryNone;
	}
#else
	if((indexPath.section==2 && (indexPath.row==2||indexPath.row==3)) ||
		indexPath.section==0&&indexPath.row==3){
		return UITableViewCellAccessoryNone;
	}
#endif
	
	return UITableViewCellAccessoryDisclosureIndicator;
}
*/


// Provide cells for the table, with each showing one of the available time signatures
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:{
			switch (indexPath.row) {
				case 0:
				{
					TableCellWithRightValue *cell = (TableCellWithRightValue *)[tableView dequeueReusableCellWithIdentifier:@"SettingSTValue"];
					if (cell == nil) {
						cell = [[[TableCellWithRightValue alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingSTValue"] autorelease];
					}

					cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
					cell.textLabel.text=NSLocalizedString(@"settingBackgroundStyleText", @"")/*settingBackgroundStyleText*/;
					cell.value.text=[iVoStyleList objectAtIndex:taskmanager.currentSettingModifying.iVoStyleID];

					return cell;
				}
					break;
					
				case 1:
				{
					TableCellWithRightValue *cell = (TableCellWithRightValue *)[tableView dequeueReusableCellWithIdentifier:@"SettingSTEdit"];
					if (cell == nil) {
						cell = [[[TableCellWithRightValue alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingSTEdit"] autorelease];
					}else{
                        for (id view in [cell.contentView subviews]) {
                            if ([view isKindOfClass:[UIButton class
                                                     ]] ||
                                [view isKindOfClass:[UISwitch class]] ||
                                [view isKindOfClass:[UISegmentedControl class]]) {
                                [view removeFromSuperview];
                            }
                        }
                    }
			
					cell.accessoryType= UITableViewCellAccessoryNone;
					cell.textLabel.text=NSLocalizedString(@"backupButtonText", @"")/*backupButtonText*/;
					cell.value.text=@"";
					
                    UIButton *backupBt=[UIButton buttonWithType:UIButtonTypeRoundedRect];
                    backupBt.frame=CGRectMake(210, 5, 80, 30);
                    [backupBt setTitle:NSLocalizedString(@"backupButtonText", @"") forState:UIControlStateNormal];
                    [backupBt addTarget:self action:@selector(backup:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.contentView addSubview:backupBt];
                    
					return cell;
				}
					break;
				case 2:
				{
					TableCellWithRightValue *cell = (TableCellWithRightValue *)[tableView dequeueReusableCellWithIdentifier:@"SettingSTEdit"];
					if (cell == nil) {
						cell = [[[TableCellWithRightValue alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingSTEdit"] autorelease];
					}
					
					cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
					cell.textLabel.text=NSLocalizedString(@"settingProjectNameText", @"")/*settingProjectNameText*/;
					cell.value.text=@"";
					
					return cell;
				}
					break;

				case 3:
				{
					TableCellSettingAutoBump *cell = (TableCellSettingAutoBump *)[tableView dequeueReusableCellWithIdentifier:@"SettingSTSwithPushValue"];
					if (cell == nil) {
						cell = [[[TableCellSettingAutoBump alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingSTSwithPushValue"] autorelease];
					}else{
                        for (id view in [cell.contentView subviews]) {
                            if ([view isKindOfClass:[UIButton class
                                                     ]] ||
                                [view isKindOfClass:[UISwitch class]] ||
                                [view isKindOfClass:[UISegmentedControl class]]) {
                                [view removeFromSuperview];
                            }
                        }
                    }
					
					cell.accessoryType= UITableViewCellAccessoryNone;
					cell.selectionStyle=UITableViewCellSelectionStyleNone;
					cell.bumpName.text=NSLocalizedString(@"deletingWarningText", @"")/*deletingWarningText*/;
					//cell.value.text=@"";
					
					if([deleteWarning superview])
						[deleteWarning removeFromSuperview];
					
					cell.switchControl=deleteWarning;
					deleteWarning.on=taskmanager.currentSettingModifying.deletingType;
					
					cell.notes.text=@"";
					cell.button=nil;
					
					return cell;
				}
					break;
				case 4:
				{
					UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingSTEditText"];
					if (cell == nil) {
						cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingSTEditText"] autorelease];
					}
					
					cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
					cell.textLabel.text=NSLocalizedString(@"applicationBadgeText", @"")/*applicationBadgeText*/;
					
					return cell;
				}
					break;	
				case 5:
				{
					UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingSTEditText"];
					if (cell == nil) {
						cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingSTEditText"] autorelease];
					}
					
					cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
					cell.textLabel.text=NSLocalizedString(@"weekStartDayText", @"")/*weekStartDayText*/;
					
					return cell;
				}
					break;	
				case 6:
				{
					UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingSTEditText"];
					if (cell == nil) {
						cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingSTEditText"] autorelease];
					}
					
					cell.accessoryType= UITableViewCellAccessoryNone;
					cell.textLabel.text=NSLocalizedString(@"upgradeToSTProText", @"")/*upgradeToSTProText*/;
					
					return cell;
				}
					break;	
					
			}
			break;
		}
		case 1: //EK sync
		{
			switch (indexPath.row)
			{
                case 0:
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingEventSyncWindow"];
					if (cell == nil) {
						cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingEventSyncWindow"] autorelease];
					}
					else
					{
						for(UIView *view in cell.subviews)
						{
							if(view.tag >= 10000 ||
                               [view isKindOfClass:[UIButton class]] ||
                               [view isKindOfClass:[UISwitch class]] ||
                               [view isKindOfClass:[UISegmentedControl class]])
							{
								[view removeFromSuperview];
							}
						}
					}
                    
					
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.accessoryType = UITableViewCellAccessoryNone;
					//cell.textLabel.text = NSLocalizedString(@"_eventSyncText", @"");
					cell.textLabel.text=iPhoneReminderText;
					
					UISwitch *sw=[[UISwitch alloc] initWithFrame:CGRectMake(220, 10, 90, 30)];
					sw.tag=10008;
					[sw addTarget:self action:@selector(syncTask:) forControlEvents:UIControlEventValueChanged];
					[cell.contentView addSubview:sw];
					sw.on=taskmanager.currentSettingModifying.enabledReminderSync;
					[sw release];
					
					//[self createSyncWindowCell:cell];
					
					return cell;
                }
                    break;
				case 1:
				{
					UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingEventSyncWindow"];
					if (cell == nil) {
						cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingEventSyncWindow"] autorelease];
					}
					else 
					{
						for(UIView *view in cell.subviews)
						{
							if(view.tag >= 10000||
                               [view isKindOfClass:[UIButton class]] ||
                               [view isKindOfClass:[UISwitch class]] ||
                               [view isKindOfClass:[UISegmentedControl class]])
							{
								[view removeFromSuperview];
							}
						}
					}

					
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.accessoryType = UITableViewCellAccessoryNone;
					//cell.textLabel.text = NSLocalizedString(@"_eventSyncText", @"");
					//cell.textLabel.text=NSLocalizedString(@"iPadCalendarSyncText",@"");
					
                    UILabel *lb=[[UILabel alloc] initWithFrame:CGRectMake(20, 10, 200, 20)];
                    lb.tag=10008;

                    lb.backgroundColor=[UIColor clearColor];
                    lb.font=[UIFont boldSystemFontOfSize:17];
                    lb.text=NSLocalizedString(@"iPadCalendarSyncText",@"");
                    [cell.contentView addSubview:lb];
                    [lb release];
                    
					UISwitch *sw=[[UISwitch alloc] initWithFrame:CGRectMake(220, 10, 90, 30)];
					sw.tag=10008;
					[sw addTarget:self action:@selector(syncEvent:) forControlEvents:UIControlEventValueChanged];
					[cell.contentView addSubview:sw];
					sw.on=taskmanager.currentSettingModifying.enableSyncICal;
					[sw release];
					
					//[self createSyncWindowCell:cell];
					
                    if (sw.isOn) {
                        UIButton *bt1=[UIButton buttonWithType:UIButtonTypeCustom];
                        bt1.frame=CGRectMake(20,30,320,30);
                        [bt1 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                        bt1.titleLabel.font=[UIFont systemFontOfSize:15];
                        bt1.tag=10008;
                        [bt1 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
                        [bt1 setTitle:[NSString stringWithFormat:@"          %@",tasksAndEventsText] forState:UIControlStateNormal];
                        [bt1 setBackgroundImage:[UIImage imageNamed:@"Pin-Off.png"] forState:UIControlStateNormal];
                        [bt1 setBackgroundImage:[UIImage imageNamed:@"Pin-On.png"] forState:UIControlStateSelected];
                        [bt1 addTarget:self action:@selector(taskAndEvents2iCal:) forControlEvents:UIControlEventTouchUpInside];
                        bt1.selected=!taskmanager.currentSettingModifying.syncEventOnly;
                        [cell.contentView addSubview:bt1];
                        
                        bt1=[UIButton buttonWithType:UIButtonTypeCustom];
                        bt1.frame=CGRectMake(20,60,320,30);
                        bt1.tag=10008;
                        bt1.titleLabel.font=[UIFont systemFontOfSize:15];
                        [bt1 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
                        [bt1 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                        [bt1 setTitle:[NSString stringWithFormat:@"          %@",eventsOnlyText] forState:UIControlStateNormal];
                        [bt1 setBackgroundImage:[UIImage imageNamed:@"Pin-Off.png"] forState:UIControlStateNormal];
                        [bt1 setBackgroundImage:[UIImage imageNamed:@"Pin-On.png"] forState:UIControlStateSelected];
                        [bt1 addTarget:self action:@selector(onlyEvents2iCal:) forControlEvents:UIControlEventTouchUpInside];
                        bt1.selected=taskmanager.currentSettingModifying.syncEventOnly;
                        [cell.contentView addSubview:bt1];
                        
                        ///
                        
                        lb=[[UILabel alloc] initWithFrame:CGRectMake(20, 95, 120, 20)];
                        lb.tag=10008;
                        lb.backgroundColor=[UIColor clearColor];
                        lb.font=[UIFont boldSystemFontOfSize:14];
                        lb.text=NSLocalizedString(@"syncWindowText", @"");
                        [cell.contentView addSubview:lb];
                        [lb release];
                        
                        UIButton *syncWindowOption1Button = [ivoUtility createButton:NSLocalizedString(@"syncWindowOption1Text", @"")
                                                                          buttonType:UIButtonTypeCustom
                                                                               frame:CGRectMake(120, 90, 40, 30)
                                                                          titleColor:[UIColor blackColor]
                                                                              target:self
                                                                            selector:@selector(changeSyncWindow:)
                                                                    normalStateImage:@"no-mash-white.png"
                                                                  selectedStateImage:@"no-mash-blue.png"];
                        syncWindowOption1Button.tag = 12000;
                        [syncWindowOption1Button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
                        
                        [cell.contentView addSubview:syncWindowOption1Button];
                        [syncWindowOption1Button release];
                        
                        UIButton *syncWindowOption2Button = [ivoUtility createButton:NSLocalizedString(@"syncWindowOption2Text", @"")
                                                                          buttonType:UIButtonTypeCustom
                                                                               frame:CGRectMake(170, 90, 40, 30)
                                                                          titleColor:[UIColor blackColor]
                                                                              target:self
                                                                            selector:@selector(changeSyncWindow:)
                                                                    normalStateImage:@"no-mash-white.png"
                                                                  selectedStateImage:@"no-mash-blue.png"];
                        syncWindowOption2Button.tag = 12001;
                        [syncWindowOption2Button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
                        
                        [cell.contentView addSubview:syncWindowOption2Button];
                        [syncWindowOption2Button release];
                        
                        UIButton *syncWindowOption3Button = [ivoUtility createButton:NSLocalizedString(@"syncWindowOption3Text", @"") 
                                                                          buttonType:UIButtonTypeCustom
                                                                               frame:CGRectMake(220, 90, 40, 30)
                                                                          titleColor:[UIColor blackColor] 
                                                                              target:self 
                                                                            selector:@selector(changeSyncWindow:) 
                                                                    normalStateImage:@"no-mash-white.png"
                                                                  selectedStateImage:@"no-mash-blue.png"];	
                        syncWindowOption3Button.tag = 12002;
                        [syncWindowOption3Button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
                        
                        [cell.contentView addSubview:syncWindowOption3Button];
                        [syncWindowOption3Button release];
                        
                        NSInteger syncWindowStart = taskmanager.currentSettingModifying.syncWindowStart;
                        NSInteger syncWindowEnd = taskmanager.currentSettingModifying.syncWindowEnd;
                        
                        if (syncWindowStart == 1 && syncWindowEnd == 1)
                        {
                            syncWindowOption1Button.selected = YES;
                        }
                        else if (syncWindowStart == 2 && syncWindowEnd == 2)
                        {
                            syncWindowOption2Button.selected = YES;
                        }
                        else if (syncWindowStart == 3 && syncWindowEnd == 3)
                        {
                            syncWindowOption3Button.selected = YES;
                        }
                        /////
                     
                        UIButton *detailBt=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                        detailBt.frame=CGRectMake(270,85,40,40);
                        detailBt.tag=10008;
                        [detailBt addTarget:self action:@selector(syncWindow:) forControlEvents:UIControlEventTouchUpInside];
                        [cell.contentView addSubview:detailBt];
                    }
					return cell;
				}
					break;
                    /*
				case 2:
				{
					UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingEventSyncMapping"];
					if (cell == nil) {
						cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingEventSyncMapping"] autorelease];
					}
					else 
					{
						for(UIView *view in cell.contentView.subviews)
						{
							if(view.tag >= 10000)
							{
								[view removeFromSuperview];
							}
						}
					}
					
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					cell.textLabel.text = @"";
					
					[self createSyncWindowCell:cell];
					
					//[self createSyncMappingCell:cell];
					
					return cell;
				}
					break;
                     */
				case 2:
				{
					//autoSyncText
					UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingEventSyncWindow"];
					if (cell == nil) {
						cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingEventSyncWindow"] autorelease];
					}
					else 
					{
						for(UIView *view in cell.subviews)
						{
							if(view.tag >= 10000||
                               [view isKindOfClass:[UIButton class]] ||
                               [view isKindOfClass:[UISwitch class]] ||
                               [view isKindOfClass:[UISegmentedControl class]])
							{
								[view removeFromSuperview];
							}
						}
					}
					
					
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.accessoryType = UITableViewCellAccessoryNone;
					//cell.textLabel.text = NSLocalizedString(@"_eventSyncText", @"");
					cell.textLabel.text=NSLocalizedString(@"autoSyncText",@"");
					
					UISwitch *sw=[[UISwitch alloc] initWithFrame:CGRectMake(220, 10, 90, 30)];
					sw.tag=10008;
					[sw addTarget:self action:@selector(autoSync:) forControlEvents:UIControlEventValueChanged];
					[cell.contentView addSubview:sw];
					sw.on=taskmanager.currentSettingModifying.autoICalSync;
					[sw release];
					
					//[self createSyncWindowCell:cell];
					
					return cell;
				}
					break;
	
                    /*
                case 4:
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingEventSyncWindow"];
					if (cell == nil) {
						cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingEventSyncWindow"] autorelease];
					}
					else 
					{
						for(UIView *view in cell.contentView.subviews)
						{
							if(view.tag >= 10000)
							{
								[view removeFromSuperview];
							}
						}
					}
                    
					
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.accessoryType = UITableViewCellAccessoryNone;
					//cell.textLabel.text = NSLocalizedString(@"_eventSyncText", @"");
					cell.textLabel.text=NSLocalizedString(@"syncEventOnlyText",@"");
					
					UISwitch *sw=[[UISwitch alloc] initWithFrame:CGRectMake(220, 10, 90, 30)];
					sw.tag=10008;
					[sw addTarget:self action:@selector(syncEventOnly:) forControlEvents:UIControlEventValueChanged];
					[cell.contentView addSubview:sw];
					sw.on=taskmanager.currentSettingModifying.syncEventOnly;
					[sw release];
					
					//[self createSyncWindowCell:cell];
					
					return cell;
                    
                }
                    break;
                     */
				case 3:
				{
					UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingEventSyncDirection"];
					if (cell == nil) {
						cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingEventSyncDirection"] autorelease];
					}
					else 
					{
						for(UIView *view in cell.subviews)
						{
							if(view.tag >= 10000||
                               [view isKindOfClass:[UIButton class]] ||
                               [view isKindOfClass:[UISwitch class]] ||
                               [view isKindOfClass:[UISegmentedControl class]])
							{
								[view removeFromSuperview];
							}
						}
					}
					
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.accessoryType = UITableViewCellAccessoryNone;
					cell.textLabel.text = @"";
					
					UIButton *bt=[UIButton buttonWithType:UIButtonTypeRoundedRect];
					bt.tag=10008;
					bt.frame=CGRectMake(20, 7, 280, 30);
					[bt setTitle:NSLocalizedString(@"syncNowText",@"") forState:UIControlStateNormal];
					[bt addTarget:self action:@selector(syncEventNow:) forControlEvents:UIControlEventTouchUpInside];
					[cell.contentView addSubview:bt];
					
					return cell;
				}
					break;
			}
			
			break;
		}
			
		case 2:{
			switch (indexPath.row){
				case 0://WorkDays In Week	
				{
					TableCellSettingContext *cell = (TableCellSettingContext *)[tableView dequeueReusableCellWithIdentifier:@"SettingSTTimeEdit"];
					if (cell == nil) {
						cell = [[[TableCellSettingContext alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingSTTimeEdit"] autorelease];
					}
					
					
					cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
					cell.contextName.text=NSLocalizedString(@"workDaysText", @"")/*workDaysText*/;
					cell.imageView.image=nil;//[UIImage imageNamed:@"Work-gray.png"];
					
					NSInteger wdStart=taskmanager.currentSettingModifying.startWorkingWDay-1;//1:sun - 7:sat
					NSInteger wdEnd=taskmanager.currentSettingModifying.endWorkingWDay-1;

					NSString *wdMidStr=@"";
					if(wdStart>wdEnd){
						wdMidStr=NSLocalizedString(@"nextText", @"")/*nextText*/;
					}
					
					NSInteger weStart=wdEnd+1;
					
					if(weStart>6){
						weStart-=7;
					}
					
					NSInteger weEnd=wdStart-1;
					if(weEnd<0){
						weEnd+=7;
					}

					NSString *weMidStr=@"";
					if(weStart>weEnd){
						weMidStr=NSLocalizedString(@"nextText", @"")/*nextText*/;
					}
					
					cell.weekDayValue.text=[NSString stringWithFormat:@"%@ ~ %@%@",
											WeekDay[wdStart],
											wdMidStr,
											WeekDay[wdEnd]];
					
					cell.weekEndValue.text=[NSString stringWithFormat:@"%@ ~ %@%@",
											WeekDay[weStart],
											weMidStr,
											WeekDay[weEnd]];
					
					return cell;
				}
					break;
				case 1:
				{
					TableCellSettingContext *cell = (TableCellSettingContext *)[tableView dequeueReusableCellWithIdentifier:@"SettingSTTimeEdit"];
					if (cell == nil) {
						cell = [[[TableCellSettingContext alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingSTTimeEdit"] autorelease];
					}
					
					cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
					cell.contextName.text=NSLocalizedString(@"settingWorkTimeText", @"")/*settingWorkTimeText*/;
					cell.imageView.image=[UIImage imageNamed:@"Work-gray.png"];
					
					NSString *apDeskStart=[ivoUtility createAMPM:taskmanager.currentSettingModifying.deskTimeStart];
					NSString *apDeskEnd=[ivoUtility createAMPM:taskmanager.currentSettingModifying.deskTimeEnd];
					
					if(_is24HourFormat){
						cell.weekDayValue.text=[NSString stringWithFormat:@"%02d:%02d ~ %02d:%02d",
												[ivoUtility getHour:taskmanager.currentSettingModifying.deskTimeStart],
												[ivoUtility getMinute:taskmanager.currentSettingModifying.deskTimeStart],
												[ivoUtility getHour:taskmanager.currentSettingModifying.deskTimeEnd],
												[ivoUtility getMinute:taskmanager.currentSettingModifying.deskTimeEnd]];
						
					}else {
						
						cell.weekDayValue.text=[NSString stringWithFormat:@"%02d:%02d%@ ~ %02d:%02d%@",
												[ivoUtility getHourWithAMPM:taskmanager.currentSettingModifying.deskTimeStart],
												[ivoUtility getMinute:taskmanager.currentSettingModifying.deskTimeStart],
												apDeskStart,
												[ivoUtility getHourWithAMPM:taskmanager.currentSettingModifying.deskTimeEnd],
												[ivoUtility getMinute:taskmanager.currentSettingModifying.deskTimeEnd],
												apDeskEnd];
					}

					
					[apDeskStart release];
					[apDeskEnd release];
					
					NSString *apDeskWEStart=[ivoUtility createAMPM:taskmanager.currentSettingModifying.deskTimeWEStart];
					NSString *apDeskWEEnd=[ivoUtility createAMPM:taskmanager.currentSettingModifying.deskTimeWEEnd];
					
					if(_is24HourFormat){
					cell.weekEndValue.text=[NSString stringWithFormat:@"%02d:%02d ~ %02d:%02d",
									 [ivoUtility getHour:taskmanager.currentSettingModifying.deskTimeWEStart],
									 [ivoUtility getMinute:taskmanager.currentSettingModifying.deskTimeWEStart],
									 [ivoUtility getHour:taskmanager.currentSettingModifying.deskTimeWEEnd],
									 [ivoUtility getMinute:taskmanager.currentSettingModifying.deskTimeWEEnd]];
					}else {
						cell.weekEndValue.text=[NSString stringWithFormat:@"%02d:%02d%@ ~ %02d:%02d%@",
												[ivoUtility getHourWithAMPM:taskmanager.currentSettingModifying.deskTimeWEStart],
												[ivoUtility getMinute:taskmanager.currentSettingModifying.deskTimeWEStart],
												apDeskWEStart,
												[ivoUtility getHourWithAMPM:taskmanager.currentSettingModifying.deskTimeWEEnd],
												[ivoUtility getMinute:taskmanager.currentSettingModifying.deskTimeWEEnd],
												apDeskWEEnd];
						
					}

					
					[apDeskWEStart release];
					[apDeskWEEnd release];
					
					return cell;
				}	
					break;
				case 2:
				{
					TableCellSettingContext *cell = (TableCellSettingContext *)[tableView dequeueReusableCellWithIdentifier:@"SettingSTTimeEdit"];
					if (cell == nil) {
						cell = [[[TableCellSettingContext alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingSTTimeEdit"] autorelease];
					}

					cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
					cell.contextName.text=NSLocalizedString(@"settingHomeTimeText", @"")/*settingHomeTimeText*/;
					cell.imageView.image=[UIImage imageNamed:@"Home-gray.png"];
					
					NSString *apHomeStart=[ivoUtility createAMPM:taskmanager.currentSettingModifying.homeTimeNDStart];
					NSString *apHomeEnd=[ivoUtility createAMPM:taskmanager.currentSettingModifying.homeTimeNDEnd];
					
					if(_is24HourFormat){
					cell.weekDayValue.text=[NSString stringWithFormat:@"%02d:%02d ~ %02d:%02d",
								   [ivoUtility getHour:taskmanager.currentSettingModifying.homeTimeNDStart],
								   [ivoUtility getMinute:taskmanager.currentSettingModifying.homeTimeNDStart],
								   [ivoUtility getHour:taskmanager.currentSettingModifying.homeTimeNDEnd],
								   [ivoUtility getMinute:taskmanager.currentSettingModifying.homeTimeNDEnd]];
					}else {
						cell.weekDayValue.text=[NSString stringWithFormat:@"%02d:%02d%@ ~ %02d:%02d%@",
												[ivoUtility getHourWithAMPM:taskmanager.currentSettingModifying.homeTimeNDStart],
												[ivoUtility getMinute:taskmanager.currentSettingModifying.homeTimeNDStart],
												apHomeStart,
												[ivoUtility getHourWithAMPM:taskmanager.currentSettingModifying.homeTimeNDEnd],
												[ivoUtility getMinute:taskmanager.currentSettingModifying.homeTimeNDEnd],
												apHomeEnd];
						
					}

						
					[apHomeStart release];
					[apHomeEnd release];
					
					NSString *apHomeWEStart=[ivoUtility createAMPM:taskmanager.currentSettingModifying.homeTimeWEStart];
					NSString *apHomeWEEnd=[ivoUtility createAMPM:taskmanager.currentSettingModifying.homeTimeWEEnd];
					
					if(_is24HourFormat){
					cell.weekEndValue.text=[NSString stringWithFormat:@"%02d:%02d ~ %02d:%02d",
									 [ivoUtility getHour:taskmanager.currentSettingModifying.homeTimeWEStart],
									 [ivoUtility getMinute:taskmanager.currentSettingModifying.homeTimeWEStart],
									 [ivoUtility getHour:taskmanager.currentSettingModifying.homeTimeWEEnd],
									 [ivoUtility getMinute:taskmanager.currentSettingModifying.homeTimeWEEnd]];
					}else {
						cell.weekEndValue.text=[NSString stringWithFormat:@"%02d:%02d%@ ~ %02d:%02d%@",
												[ivoUtility getHourWithAMPM:taskmanager.currentSettingModifying.homeTimeWEStart],
												[ivoUtility getMinute:taskmanager.currentSettingModifying.homeTimeWEStart],
												apHomeWEStart,
												[ivoUtility getHourWithAMPM:taskmanager.currentSettingModifying.homeTimeWEEnd],
												[ivoUtility getMinute:taskmanager.currentSettingModifying.homeTimeWEEnd],
												apHomeWEEnd];
						
					}

					
					[apHomeWEStart release];
					[apHomeWEEnd release];
					
					return cell;
					
					break;
				}
				case 3:
				{
					TableCellSettingAutoBump *cell = (TableCellSettingAutoBump *)[tableView dequeueReusableCellWithIdentifier:@"SettingSTSwithPushValue"];
					if (cell == nil) {
						cell = [[[TableCellSettingAutoBump alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingSTSwithPushValue"] autorelease];
					}
					cell.notes.text=@"";
					cell.bumpName.text=@"";
					
					cell.accessoryType= UITableViewCellAccessoryNone;
					cell.selectionStyle=UITableViewCellSelectionStyleNone;
					
					cell.bumpName.text=NSLocalizedString(@"settingAutoBumpTaskText", @"")/*settingAutoBumpTaskText*/;

					if([bumpTaskDescr superview])
						[bumpTaskDescr removeFromSuperview];

					//cell.notes=NSLocalizedString(@"bumpTaskDescr", @"")/*bumpTaskDescr*/;
					cell.notes=bumpTaskDescr;

					if([pushForward superview]){
						[pushForward removeFromSuperview];
					}
					//cell.switchControl=NSLocalizedString(@"pushForward", @"")/*pushForward*/;
					cell.switchControl=pushForward;
					
					pushForward.on=taskmanager.currentSettingModifying.pushTaskFoward;
					
					if(pushForward.isOn){
						bumpTaskDescr.text=NSLocalizedString(@"settingAutoBumpTaskONText", @"")/*settingAutoBumpTaskONText*/;
					}else {
						bumpTaskDescr.text=NSLocalizedString(@"settingAutoBumpTaskOFFText", @"")/*settingAutoBumpTaskOFFText*/;
					}
					
					//if([bumpTaskDescr superview])
					//	[bumpTaskDescr removeFromSuperview];
					cell.button=nil;
					return cell;
				}	
					break;
				case 4:
				{
					TableCellSettingAutoBump *cell = (TableCellSettingAutoBump *)[tableView dequeueReusableCellWithIdentifier:@"SettingSTSwithDeadlineValue"];
					if (cell == nil) {
						cell = [[[TableCellSettingAutoBump alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingSTSwithDeadlineValue"] autorelease];
					}
					
					cell.notes.text=@"";
					cell.bumpName.text=@"";
					
					cell.accessoryType= UITableViewCellAccessoryNone;
					cell.selectionStyle=UITableViewCellSelectionStyleNone;
					
					cell.bumpName.text=NSLocalizedString(@"settingAutoBumpDeadlineText", @"")/*settingAutoBumpDeadlineText*/;
					
					if([bumpDeadlineDescr superview])
						[bumpDeadlineDescr removeFromSuperview];
					//cell.notes=NSLocalizedString(@"bumpDeadlineDescr", @"")/*bumpDeadlineDescr*/;
					cell.notes=bumpDeadlineDescr;

					cell.switchControl=changeDeadline;
					
					if([changeDeadline superview])
						[changeDeadline removeFromSuperview];
					changeDeadline.on=1-taskmanager.currentSettingModifying.dueWhenMove;
					[cell.contentView addSubview:changeDeadline];
					cell.button=nil;
					
					if (taskmanager.currentSettingModifying.dueWhenMove==0){
						bumpDeadlineDescr.text=NSLocalizedString(@"settingAutoBumpDeadlineONText", @"")/*settingAutoBumpDeadlineONText*/;
					}else {
						bumpDeadlineDescr.text=NSLocalizedString(@"settingAutoBumpDeadlineOFFText", @"")/*settingAutoBumpDeadlineOFFText*/;
					}
					
					return cell;
				}	
					break;
				case 5:
				{
					TableCellWithRightValue *cell = (TableCellWithRightValue *)[tableView dequeueReusableCellWithIdentifier:@"SettingSTValue"];
					if (cell == nil) {
						cell = [[[TableCellWithRightValue alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingSTValue"] autorelease];
					}
					
					cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
					cell.textLabel.text=NSLocalizedString(@"cleanOldDateTitleText", @"")/*cleanOldDateTitleText*/;
					
					if(taskmanager.currentSettingModifying.cleanOldDayCount>0){
						if(taskmanager.currentSettingModifying.cleanOldDayCount>1){
							cell.value.text=[NSString stringWithFormat:@"%d days", taskmanager.currentSettingModifying.cleanOldDayCount];
						}else {
							cell.value.text=[NSString stringWithFormat:@"%d day", taskmanager.currentSettingModifying.cleanOldDayCount];
						}

					}else {
						cell.value.text=NSLocalizedString(@"neverText", @"")/*neverText*/;
					}
					
					return cell;
				}
					break;
				case 6:
				{
					UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deleteDup"];
					if (cell == nil) {
						cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"deleteDup"] autorelease];
					}
					else
					{
						for(UIView *view in cell.contentView.subviews)
						{
							if([view isKindOfClass:[UIButton class]]||
                               [view isKindOfClass:[UISwitch class]] ||
                               [view isKindOfClass:[UISegmentedControl class]])
							{
								[view removeFromSuperview];
							}
						}
					}
					
					cell.textLabel.text = NSLocalizedString(@"deleteDupTitleText", @"")/*deleteDupTitleText*/;
					
					deleteDupButon=[ivoUtility createButton:NSLocalizedString(@"goText", @"")/*goText*///@"Go"
														   buttonType:UIButtonTypeRoundedRect
																frame:CGRectMake(260, 6, 30, 30) 
														   titleColor:nil
															   target:self 
															 selector:@selector(deleteDup:) 
													 normalStateImage:nil 
												   selectedStateImage:nil];
					[cell.contentView addSubview:deleteDupButon];		
					[deleteDupButon release];
					
					return cell;					
				}
					break;
				case 7:
				{
					TableCellWithRightValue *cell = (TableCellWithRightValue *)[tableView dequeueReusableCellWithIdentifier:@"SettingSTValue"];
					if (cell == nil) {
						cell = [[[TableCellWithRightValue alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingSTValue"] autorelease];
					}
					
					cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
					cell.textLabel.text=NSLocalizedString(@"snoozeDurationText", @"")/*snoozeDurationText*/;
					
					cell.value.text=[NSString stringWithFormat:@"%d %@",taskmanager.currentSettingModifying.snoozeDuration,alertUnitList[taskmanager.currentSettingModifying.snoozeUnit]];
					return cell;
				}
					break;	
			}
			break;
		}
		case 3:{
			switch (indexPath.row) {
				case 0:
				{
					TableCellWithRightValue *cell = (TableCellWithRightValue *)[tableView dequeueReusableCellWithIdentifier:@"SettingSTValue"];
					if (cell == nil) {
						cell = [[[TableCellWithRightValue alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingSTValue"] autorelease];
					}

					cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
					NSString *hlStr=[ivoUtility createCalculateHowLong:taskmanager.currentSettingModifying.howlongDefVal];
					cell.value.text= hlStr;
					[hlStr release];
					cell.textLabel.text=NSLocalizedString(@"durationText", @"")/*durationText*/;
					
					return cell;
				}
					break;
				case 1:
				{
					TableCellWithRightValue *cell =(TableCellWithRightValue *) [tableView dequeueReusableCellWithIdentifier:@"SettingSTValue"];
					if (cell == nil) {
						cell = [[[TableCellWithRightValue alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingSTValue"] autorelease];
					}
					
					cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
					cell.value.text=[contextList objectAtIndex:taskmanager.currentSettingModifying.contextDefID];
					cell.textLabel.text=NSLocalizedString(@"contextText", @"")/*contextText*/;
					
					return cell;
				}

					break;
				case 2: 
				{
					TableCellWithRightValue *cell =(TableCellWithRightValue *) [tableView dequeueReusableCellWithIdentifier:@"SettingSTValue"];
					if (cell == nil) {
						cell = [[[TableCellWithRightValue alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingSTValue"] autorelease];
					}else{
						
					}

					cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
					cell.textLabel.text=NSLocalizedString(@"projectText", @"")/*projectText*/;
					Projects *project=[App_Delegate calendarWithPrimaryKey:taskmanager.currentSettingModifying.projectDefID];
                    taskmanager.currentSettingModifying.projectDefID=project.primaryKey;
                    
					cell.value.text=project.projName;
					cell.textLabel.text=NSLocalizedString(@"projectText", @"")/*projectText*/;
					
					return cell;
					break;
				}
					
				case 3: 
				{
					UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"TestTingMode"];
					if (cell == nil) {
						cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"TestTingMode"] autorelease];
					}else
						
					cell.accessoryType= UITableViewCellAccessoryNone;
					cell.textLabel.text=@"Statistic Tasks";
					return cell;
					break;
				}	
			}
			break;
		}
	}
	
	return nil;
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	switch (newIndexPath.section) {
		case 0:
			switch (newIndexPath.row) {
				//case 0:
				//	break;
				case 0:
					[self.rootViewController pushSettingsRelativeView:SETTING_IVOSTYLEDEFID editObject:taskmanager.currentSettingModifying];
					break;
				case 2:
#ifndef FREE_VERSION	
					[self.rootViewController pushSettingsRelativeView:SETTING_PROJECTEDIT editObject:projectList];
#endif
					break;
				case 1:
					[self.rootViewController pushSettingsRelativeView:SETTING_BACKUP editObject:taskmanager.currentSettingModifying];
					break;
				case 3:
					//deleting warning
					break;
				case 4:
					[self.rootViewController pushSettingsRelativeView:SETTING_BADGE editObject:taskmanager.currentSettingModifying];
					break;
				case 5:
					[self.rootViewController pushSettingsRelativeView:SETTING_WEEK_START_DAY editObject:taskmanager.currentSettingModifying];
					break;
					
			}
			break;
		case 1: //EK Sync
		{
            /*
			switch (newIndexPath.row) 
			{
				case 2:
				{
					[self editSyncWindow];
				}
					break;
								
			}
			*/
			break;
		}			
		case 2:
			switch (newIndexPath.row) {
				case 0:
					[self.rootViewController pushSettingsRelativeView:SETTING_WORKDAYS editObject:taskmanager.currentSettingModifying];
					break;
					
				case 1:
					[self.rootViewController pushSettingsRelativeView:SETTING_DESKTIME editObject:taskmanager.currentSettingModifying];
					break;
				case 2:
					[self.rootViewController pushSettingsRelativeView:SETTING_HOMETIME editObject:taskmanager.currentSettingModifying];
					break;
				case 4:
					//[self.rootViewController pushSettingsRelativeView:SETTING_PASSDUEMOVE editObject:taskmanager.currentSettingModifying];
					break;					
				case 5:	
					[self.rootViewController pushSettingsRelativeView:SETTING_CLEANOLDDATA editObject:taskmanager.currentSettingModifying];
					break;
				case 7:	
					[self.rootViewController pushSettingsRelativeView:SETTING_SNOOZE_DURATION editObject:taskmanager.currentSettingModifying];
					break;
					
			}
			break;
		case 3:
			switch (newIndexPath.row) {
				case 0:
					[self.rootViewController pushSettingsRelativeView:SETTING_HOWLONG editObject:taskmanager.currentSettingModifying];
					break;
				case 1:
					[self.rootViewController pushSettingsRelativeView:SETTING_CONTEXTDEFID editObject:taskmanager.currentSettingModifying];
					break;
				case 2:
					[self.rootViewController pushSettingsRelativeView:SETTING_PROJECTDEFAULT editObject:taskmanager.currentSettingModifying];
					break;
				case 3://this row for testing so should move it up if any new row inserted
				{
					UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"Tasks" 
																	  message:[ivoUtility statisticNumberOfTasks] 
																	 delegate:nil 
															cancelButtonTitle:NSLocalizedString(@"okText", @"")/*okText*/ 
															otherButtonTitles:nil];
					[alertView show];
					[alertView release];
				}
					break;
			}
			break;
	}
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
	if (indexPath.section==1) {
        if (indexPath.row==1) {
            if (taskmanager.currentSettingModifying.enableSyncICal) {
                return 130;
            }else{
                return 45;
            }
        }
    }else if(indexPath.section==2){
		if(indexPath.row <5){
			if(indexPath.row==3)
				return 100;
			return 80;
		}
	}
	
	return 45;
}

#pragma mark Cell Creation
- (void) createSyncWindowCell:(UITableViewCell *)cell
{
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.textLabel.text = NSLocalizedString(@"syncWindowText", @"");
	
	UIButton *syncWindowOption1Button = [ivoUtility createButton:NSLocalizedString(@"syncWindowOption1Text", @"") 
												  buttonType:UIButtonTypeCustom
													   frame:CGRectMake(130, 5, 40, 30) 
												  titleColor:[UIColor blackColor] 
													  target:self 
													selector:@selector(changeSyncWindow:) 
											normalStateImage:@"no-mash-white.png"
										  selectedStateImage:@"no-mash-blue.png"];	
	syncWindowOption1Button.tag = 12000;
	[syncWindowOption1Button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	
	[cell.contentView addSubview:syncWindowOption1Button];	
	[syncWindowOption1Button release];
	
	UIButton *syncWindowOption2Button = [ivoUtility createButton:NSLocalizedString(@"syncWindowOption2Text", @"") 
												  buttonType:UIButtonTypeCustom
													   frame:CGRectMake(180, 5, 40, 30) 
												  titleColor:[UIColor blackColor] 
													  target:self 
													selector:@selector(changeSyncWindow:) 
											normalStateImage:@"no-mash-white.png"
										  selectedStateImage:@"no-mash-blue.png"];	
	syncWindowOption2Button.tag = 12001;
	[syncWindowOption2Button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	
	[cell.contentView addSubview:syncWindowOption2Button];
	[syncWindowOption2Button release];	
	
	UIButton *syncWindowOption3Button = [ivoUtility createButton:NSLocalizedString(@"syncWindowOption3Text", @"") 
												  buttonType:UIButtonTypeCustom
													   frame:CGRectMake(230, 5, 40, 30) 
												  titleColor:[UIColor blackColor] 
													  target:self 
													selector:@selector(changeSyncWindow:) 
											normalStateImage:@"no-mash-white.png"
										  selectedStateImage:@"no-mash-blue.png"];	
	syncWindowOption3Button.tag = 12002;
	[syncWindowOption3Button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	
	[cell.contentView addSubview:syncWindowOption3Button];
	[syncWindowOption3Button release];
	
	NSInteger syncWindowStart = taskmanager.currentSettingModifying.syncWindowStart;
	NSInteger syncWindowEnd = taskmanager.currentSettingModifying.syncWindowEnd;
	
	if (syncWindowStart == 1 && syncWindowEnd == 1)
	{
		syncWindowOption1Button.selected = YES;
	}
	else if (syncWindowStart == 2 && syncWindowEnd == 2)
	{
		syncWindowOption2Button.selected = YES;
	}
	else if (syncWindowStart == 3 && syncWindowEnd == 3)
	{
		syncWindowOption3Button.selected = YES;
	}
}

- (void) createSyncMappingCell:(UITableViewCell *)cell
{
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.textLabel.text = NSLocalizedString(@"_calendarMappingText", @"");
}

- (void) createSyncDirectionCell:(UITableViewCell *)cell
{
/*	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.textLabel.text = NSLocalizedString(@"settingSyncTypeText", @"");
	
	UILabel *directionLabel=[[UILabel alloc] initWithFrame:CGRectMake(60, 10, 205, 20)];
	directionLabel.tag = 11010;
	directionLabel.textAlignment=NSTextAlignmentRight;
	directionLabel.backgroundColor=[UIColor clearColor];
	directionLabel.font=[UIFont systemFontOfSize:15];
	
	NSString *directions[3] = { NSLocalizedString(@"_2wayText", @""),  NSLocalizedString(@"_importText", @""),  NSLocalizedString(@"_exportText", @"")};
	directionLabel.text = directions[taskmanager.currentSettingModifying.syncType];
	directionLabel.textColor = [Colors steelBlue];
	
	[cell.contentView addSubview:directionLabel];
	[directionLabel release];
 */
}

#pragma mark EK Sync Support
- (void) refreshSyncWindowButtons
{
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
	
	UIButton *syncWindowOption1Button = (UIButton *) [cell viewWithTag:12000];
	syncWindowOption1Button.selected = NO;
	
	UIButton *syncWindowOption2Button =  (UIButton *) [cell viewWithTag:12001];
	syncWindowOption2Button.selected = NO;
	
	UIButton *syncWindowOption3Button =  (UIButton *) [cell viewWithTag:12002];
	syncWindowOption3Button.selected = NO;
	
	NSInteger syncWindowStart = taskmanager.currentSettingModifying.syncWindowStart;
	NSInteger syncWindowEnd = taskmanager.currentSettingModifying.syncWindowEnd;
	
	if (syncWindowStart == 1 && syncWindowEnd == 1)
	{
		syncWindowOption1Button.selected = YES;
	}
	else if (syncWindowStart == 2 && syncWindowEnd == 2)
	{
		syncWindowOption2Button.selected = YES;
	}
	else if (syncWindowStart == 3 && syncWindowEnd == 3)
	{
		syncWindowOption3Button.selected = YES;
	}
	
}

- (void) changeSyncWindow: (id) sender
{
	switch ([sender tag])
	{
		case 12000:
		{
			taskmanager.currentSettingModifying.syncWindowStart = 1;
			taskmanager.currentSettingModifying.syncWindowEnd = 1;
			
			[self refreshSyncWindowButtons];
		}
			break;
		case 12001:
		{
			taskmanager.currentSettingModifying.syncWindowStart = 2;
			taskmanager.currentSettingModifying.syncWindowEnd = 2;
			
			[self refreshSyncWindowButtons];			
		}
			break;
		case 12002:
		{
			taskmanager.currentSettingModifying.syncWindowStart = 3;
			taskmanager.currentSettingModifying.syncWindowEnd = 3;
			
			[self refreshSyncWindowButtons];			
		}
			break;
	}
	
}

#pragma mark action methods

-(void)syncWindow:(id)sender{
    [self editSyncWindow];
}

-(void)taskAndEvents2iCal:(id)sender{
    taskmanager.currentSettingModifying.syncEventOnly=0;
    [tableView reloadData];
}

-(void)onlyEvents2iCal:(id)sender{
    taskmanager.currentSettingModifying.syncEventOnly=1;
    [tableView reloadData];
}

-(void)syncEventOnly:(id)sender{
    UISwitch *sw=sender;
    taskmanager.currentSettingModifying.syncEventOnly=sw.isOn;
}

-(void)backup:(id)sender{
    [_smartViewController backupDataToMail];
}

-(void)autoSync:(id)sender{
	UISwitch *sw=sender;
	taskmanager.currentSettingModifying.autoICalSync=sw.isOn;
    if (taskmanager.currentSettingModifying.autoICalSync==1 && taskmanager.currentSetting.autoICalSync==0) {
        _smartViewController.needCheckAutoSync=YES;
    }
}

-(void)editSyncWindow{
	EKSyncWindow2TableViewController *ctrler = [[EKSyncWindow2TableViewController alloc] init];
	ctrler.setting = taskmanager.currentSettingModifying;
	
	[self.rootViewController.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
	
}

-(void)syncTaskNow:(id)sender{
	[taskmanager.ekSync backgroundFullSync];
}

-(void)syncEventNow:(id)sender{
	taskmanager.ekSync.rootViewController=App_Delegate.viewController;
    _smartViewController.needCheckAutoSync=YES;
    [_smartViewController performSelector:@selector(flipAction:) withObject:_smartViewController.doneButton];
    
    //in the case not auto-sync specified, taskmanager will not sync, have to do it here
    if (taskmanager.currentSetting.autoICalSync==0) {
        
        if ( taskmanager.currentSettingModifying.enableSyncICal==1) {
            [taskmanager.ekSync backgroundFullSync];
        }

        if (taskmanager.currentSettingModifying.enabledReminderSync) {
            [taskmanager.reminderSync backgroundFullSync];
        }
    
    }
}

-(void)syncTask:(id)sender{
	UISwitch *sw=sender;
	taskmanager.currentSettingModifying.enabledReminderSync=sw.isOn;
	[tableView reloadData];
}


//syncEvent
-(void)syncEvent:(id)sender{
	UISwitch *sw=sender;
	taskmanager.currentSettingModifying.enableSyncICal=sw.isOn;
	[tableView reloadData];
}


-(void)TDSyncEnabled:(id)sender{
	UISwitch *sw=sender;
	taskmanager.currentSettingModifying.enableSyncToodledo=sw.isOn;
	[tableView reloadData];
}

-(void)pushTask:(id) sender{
	taskmanager.currentSettingModifying.pushTaskFoward=pushForward.isOn;
	if(pushForward.isOn){
		bumpTaskDescr.text=NSLocalizedString(@"settingAutoBumpTaskONText", @"")/*settingAutoBumpTaskONText*/;//@"ON: during app startup, tasks that are not completed will be automatically rescheduled. ";
	}else {
		bumpTaskDescr.text=NSLocalizedString(@"settingAutoBumpTaskOFFText", @"")/*settingAutoBumpTaskOFFText*/;//@"OFF: during app startup, tasks that are not completed will not be automatically rescheduled.";
	}
}

-(void)changeDeadline:(id)sender{
	taskmanager.currentSettingModifying.dueWhenMove=1-changeDeadline.isOn;
	if (taskmanager.currentSettingModifying.dueWhenMove==0){
		bumpDeadlineDescr.text=NSLocalizedString(@"settingAutoBumpDeadlineONText", @"")/*settingAutoBumpDeadlineONText*/;//@"ON: deadlines of tasks may be automatically expanded when creating or modifying tasks.";
	}else {
		bumpDeadlineDescr.text=NSLocalizedString(@"settingAutoBumpDeadlineOFFText", @"")/*settingAutoBumpDeadlineOFFText*/ ;//@"OFF: warn user for any passing deadline when creating or modyfing tasks.";
	}
	
}

-(void)deleteWarning:(id)sender{
	taskmanager.currentSettingModifying.deletingType=deleteWarning.isOn;
}

-(void)deleteDup:(id) sender
{
	deleteDupAlert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"warningText", @"")/*warningText*/
											  message:NSLocalizedString(@"deleteDupMsg", @"")/*deleteDupMsg*/
											 delegate:self
									cancelButtonTitle:NSLocalizedString(@"noText", @"")/*noText*/
									otherButtonTitles:nil];

	[deleteDupAlert addButtonWithTitle:NSLocalizedString(@"yesText", @"")/*yesText*/];
	[deleteDupAlert show];
	[deleteDupAlert release];	
}

#pragma mark properties
-(NSInteger)pathIndex{
	return pathIndex;	
}

-(void)setPathIndex:(NSInteger)pathIdx{
	pathIndex=pathIdx;	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if([alertView isEqual:deleteDupAlert] && buttonIndex==1){
		deleteDupButon.enabled = NO;
		
		[ivoUtility deleteSuspectedDuplication];
		
		[self.rootViewController refreshAfterDupDeletion];
		
		deleteDupButon.enabled = YES;
	}
}

/*
#pragma mark in-app purchase for Tasks
- (void) requestProductData
{
	//SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: [NSSet setWithObject: @"com.leftcoastlogic.smarttimeplus"]];
	productsRequest= [[SKProductsRequest alloc] initWithProductIdentifiers: [NSSet setWithObject: @"smarttimeplus"]];
	productsRequest.delegate = self;
	[productsRequest start];
}

//***************************************
// PRAGMA_MARK: Delegate Methods
//***************************************
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	NSArray *products = response.products;
    proUpgradeProduct = [products count] == 1 ? [[products firstObject] retain] : nil;
    if (proUpgradeProduct)
    {
        NSLog(@"Product title: %@" , proUpgradeProduct.localizedTitle);
        NSLog(@"Product description: %@" , proUpgradeProduct.localizedDescription);
        NSLog(@"Product price: %@" , proUpgradeProduct.price);
        NSLog(@"Product id: %@" , proUpgradeProduct.productIdentifier);
    }
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
    
    // finally release the reqest we alloc/init’ed in requestProUpgradeProductData
    [productsRequest release];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:self userInfo:nil];
}
*/
/*
-(void) subscribe:(id) sender{
	SKPayment *payment = [SKPayment paymentWithProductIdentifier:@"smarttimeplus"];
	[[SKPaymentQueue defaultQueue] addPayment:payment];
}
*/

/*
///////
//
// call this method once on startup
//
- (void)loadStore
{
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // get the product description (defined in early sections)
    [self requestProUpgradeProductData];
}

//
// call this before making a purchase
//
- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

//
// kick off the upgrade transaction
//
- (void)purchaseProUpgrade:(id)sender
{
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:kInAppPurchaseProUpgradeProductId];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma -
#pragma Purchase helpers

//
// saves a record of the transaction by storing the receipt to disk
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProUpgradeProductId])
    {
        // save the transaction receipt to disk
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"proUpgradeTransactionReceipt" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//
// enable pro features
//
- (void)provideContent:(NSString *)productId
{
    if ([productId isEqualToString:kInAppPurchaseProUpgradeProductId])
    {
        // enable the pro features
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isProUpgradePurchased" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful)
    {
        // send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
    }
    else
    {
        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
    }
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
} 
*/

@end
