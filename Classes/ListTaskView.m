//
//  QuickTaskView.m
//  IVo
//
//  Created by Nang Le on 6/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ListTaskView.h"
#import "TaskManager.h"
#import "SmartTimeAppDelegate.h"
#import "Colors.h"
#import "ivo_Utilities.h"
#import "SmartViewController.h"
#import "TableCellFocus.h"
#import "TableCellWithRightValue.h"
#import "CalendarIconView.h"
#import "EKSync.h"
#import "ReminderSync.h"

extern TaskManager *taskmanager;
extern SmartTimeAppDelegate *App_Delegate;
extern ivo_Utilities	*ivoUtility;

@implementation ListTaskView
@synthesize rootViewController,cellTextVal;

- (id)initWithFrame:(CGRect)frame {
	//ILOG(@"[ListTaskView initWithFrame\n");
	if (self = [super initWithFrame:frame]) {
		// Initialization code
	
		//pool = [[NSAutoreleasePool alloc] init];
		doView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, (frame.size.height)/2)];
		doView.backgroundColor=[UIColor groupTableViewBackgroundColor];
		
		doToday=[[UILabel alloc] initWithFrame:CGRectMake(15, 5, 100, 25)];
		doToday.text=NSLocalizedString(@"doTodayText", @"")/*doTodayText*/;//@"Do Today";
		doToday.backgroundColor=[UIColor clearColor];
		doToday.textColor=[Colors darkSteelBlue];
		[doView addSubview:doToday];
		
		CGRect tableViewDoFrame = CGRectMake(0.0, 34, 320, doView.frame.size.height-34);
		tableViewDo = [[UITableView alloc] initWithFrame:tableViewDoFrame style:UITableViewStyleGrouped];
		tableViewDo.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
		tableViewDo.sectionHeaderHeight=0;
		tableViewDo.sectionFooterHeight=0;
		tableViewDo.allowsSelectionDuringEditing=YES;
		tableViewDo.delegate = self;
		tableViewDo.dataSource = self;
		[doView addSubview:tableViewDo];
		
		//[tableViewDo release];
		
		[self addSubview:doView];
		/*29-7*/
		//[doView release];
		
		doneView=[[UIView alloc] initWithFrame:CGRectMake(0, doView.frame.size.height, 320, (frame.size.height)/2)];
		doneView.backgroundColor=[UIColor groupTableViewBackgroundColor];
		
		doneToday=[[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 25)];
		doneToday.text=NSLocalizedString(@"doneTodayButtonText", @"")/*doneTodayButtonText*/;
		doneToday.backgroundColor=[UIColor clearColor];
		doneToday.textColor=[Colors darkSteelBlue];
		[doneView addSubview:doneToday];
		
		showHideDoneTodayButton=[ivoUtility createButton:NSLocalizedString(@"hideDoneTodayButonText", @"")/*hideDoneTodayButonText*/
												 buttonType:UIButtonTypeRoundedRect 
													  frame:CGRectMake(180, 4, 130, 25) 
												 titleColor:[UIColor whiteColor] 
													 target:self 
												   selector:@selector(switchShowHideDone:) 
										   normalStateImage:@"no-mash-blue.png"
										 selectedStateImage:nil];
		[doView addSubview:showHideDoneTodayButton];
		
		CGRect tableViewDoneFrame;
#ifdef FREE_VERSION
		tableViewDoneFrame= CGRectMake(0.0,25, 320, 151-44);
#else
		tableViewDoneFrame= CGRectMake(0.0,34, 320, doneView.frame.size.height-34);
#endif
		tableViewDone = [[UITableView alloc] initWithFrame:tableViewDoneFrame style:UITableViewStyleGrouped];
		tableViewDone.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
		tableViewDone.sectionHeaderHeight=0;
		tableViewDone.sectionFooterHeight=0;
		tableViewDone.allowsSelectionDuringEditing=YES;
		tableViewDone.delegate = self;
		tableViewDone.dataSource = self;
		[doneView addSubview:tableViewDone];
		//doneView.hidden=YES;
		[self addSubview:doneView];
		//[doneView release];
		
		doneButton=[ivoUtility createButton:NSLocalizedString(@"doneButtonText", @"")/*doneButtonText*/ 
									buttonType:UIButtonTypeRoundedRect 
										 frame:CGRectMake(5, 2, 50, 25) 
									titleColor:[UIColor brownColor]//[Colors steelBlue] 
										target:self 
									  selector:@selector(doneTask:) 
							  normalStateImage:@""//@"50_25_blue.png"
							selectedStateImage:nil];
		
		editButon=[ivoUtility createButton:@""
								   buttonType:UIButtonTypeDetailDisclosure 
										frame:CGRectMake(265, 0, 40, 30) 
								   titleColor:nil
									   target:self 
									 selector:@selector(editTaskEvent:) 
							 normalStateImage:nil 
						   selectedStateImage:nil];
		
		self.cellTextVal=[[UILabel alloc] initWithFrame:CGRectMake(60, 0, 200, 27)];
		self.cellTextVal.font=[UIFont systemFontOfSize:14];
		//self.cellTextVal.textColor=[UIColor whiteColor];
		self.cellTextVal.backgroundColor=[UIColor clearColor];
		//self.cellTextVal.textAlignment=NSTextAlignmentCenter;
		self.cellTextVal.highlightedTextColor=[UIColor whiteColor];
		self.isSwipe=YES;
		
	}
	//ILOG(@"ListTaskView initWithFrame]\n");
	return self;
}

- (void)drawRect:(CGRect)rect {
	// Drawing code
}


- (void)dealloc {
	[tableViewDo removeFromSuperview];
	tableViewDo.delegate=nil;
	tableViewDo.dataSource=nil;
	[tableViewDo release];
	
	[tableViewDone removeFromSuperview];
	tableViewDone.delegate=nil;
	tableViewDone.dataSource=nil;
	[tableViewDone release];
	
	[doToday removeFromSuperview];
	[doToday release];
	
	[doneToday removeFromSuperview];
	[doneToday release];
	
	[doneView removeFromSuperview];
	[doneView release];
	
	[doView release];

	[doneButton release];
	
	[rootViewController release];
	rootViewController=nil;
	
	[cellTextVal removeFromSuperview];
	[cellTextVal release];
	
	[editButon removeFromSuperview];
	[editButon release];
	
	[showHideDoneTodayButton removeFromSuperview];
	[showHideDoneTodayButton release];
	
	[filterCaluse release];
	
	[super dealloc];
}

#pragma mark actions methods

-(void)switchShowHideDone:(id)sender{
	//[self.navigationController popViewControllerAnimated:YES];
	//ILOG(@"[SmartViewController switchShowHideDone\n");
	if([[showHideDoneTodayButton currentTitle] isEqualToString:NSLocalizedString(@"showDoneTodayButonText", @"")/*showDoneTodayButonText*/]){
		[showHideDoneTodayButton setTitle:NSLocalizedString(@"hideDoneTodayButonText", @"")/*hideDoneTodayButonText*/ forState:UIControlStateNormal];
		[self showHideDoneTodayAct:NO];
	}else {
		[self showHideDoneTodayAct:YES];
		[showHideDoneTodayButton setTitle:NSLocalizedString(@"showDoneTodayButonText", @"")/*showDoneTodayButonText*/ forState:UIControlStateNormal];
	}
	//ILOG(@"SmartViewController switchShowHideDone]\n");
}

-(void)showHideDoneTodayAct:(BOOL)isShowDone{
    //CGRect mainFrame=[[UIScreen mainScreen] bounds];
    
	if(isShowDone){
		CGRect frame=CGRectMake(0, 0, 320,self.frame.size.height);
		doView.frame=frame;
        tableViewDo.frame=CGRectMake(0, 34, 320,frame.size.height-34);
        
		doneView.hidden=YES;
	}else {
		CGRect frame= CGRectMake(0, 0, 320, self.frame.size.height/2);
		doView.frame=frame;
        tableViewDo.frame=CGRectMake(0, 34, 320,frame.size.height-34);
        
		
		doneView.hidden=NO;
	}

}

-(void)doneTask:(id)sender{
	
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	//ILOG(@"[ListTaskView doneTask\n");
	self.isSwipe=YES;
	
	[tableViewDo setEditing:NO animated:YES];
	[tableViewDo deselectRowAtIndexPath:[NSIndexPath indexPathForRow:self.pathIndex inSection:0]  animated:YES];
	[[tableViewDo cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.pathIndex inSection:0]] setEditing:NO animated:NO];
	[doneButton removeFromSuperview];
	
	NSInteger taskKey=[[taskmanager.quickTaskList objectAtIndex:self.pathIndex] primaryKey];
	[taskmanager markedCompletedTask:taskKey doneREType:1];	
	[tableViewDo reloadData];
	[tableViewDone reloadData];
	
	//scroll to deleted item
	NSInteger gotoIndex=[ivoUtility getIndex:taskmanager.completedTaskList :taskKey];
	[tableViewDone scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:gotoIndex inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	self.isDoViewSelected=NO;
	[self.rootViewController resetQuickEditMode:YES taskKey:taskKey];
	
	App_Delegate.me.networkActivityIndicatorVisible=NO;
	//ILOG(@"ListTaskView doneTask]\n");
}

-(void)editTaskEvent:(id)sender{
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	[tableViewDo setEditing:NO animated:YES];
	[tableViewDo deselectRowAtIndexPath:[NSIndexPath indexPathForRow:self.pathIndex inSection:0]  animated:NO];
	[[tableViewDo cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.pathIndex inSection:0]] setEditing:NO animated:NO];

	[[tableViewDo cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.pathIndex inSection:0]].textLabel setText:self.cellTextVal.text];
	
    if (self.pathIndex < 0)
        return;
    
	if([[taskmanager.quickTaskList objectAtIndex:self.pathIndex] taskIsUseDeadLine] && 
	   [[[taskmanager.quickTaskList objectAtIndex:self.pathIndex] taskEndTime] compare:[NSDate date]]==NSOrderedAscending){
		[[tableViewDo cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.pathIndex inSection:0]].textLabel setTextColor:[UIColor redColor]];
	}else if([[[taskmanager.quickTaskList objectAtIndex:self.pathIndex] taskEndTime] compare:[NSDate date]]==NSOrderedAscending){
		[[tableViewDo cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.pathIndex inSection:0]].textLabel setTextColor:[UIColor brownColor]];
	}else {
		[[tableViewDo cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.pathIndex inSection:0]].textLabel setTextColor:[Colors darkSteelBlue]];
	}
	
	[[tableViewDo cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.pathIndex inSection:0]].textLabel setFont:[UIFont systemFontOfSize:14]];
	
	[self.cellTextVal removeFromSuperview];
	[doneButton removeFromSuperview];
	[editButon removeFromSuperview];
    
	
	[self tableView:tableViewDo didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:self.pathIndex inSection:0]];
	NSInteger taskKey=[[taskmanager.quickTaskList objectAtIndex:self.pathIndex] primaryKey];
	[self.rootViewController resetQuickEditMode:YES taskKey:taskKey];
	[self.rootViewController editTaskFromListView:[taskmanager.quickTaskList objectAtIndex:self.pathIndex]];
	self.isDoViewSelected=NO;
    [editButon removeFromSuperview];
	App_Delegate.me.networkActivityIndicatorVisible=NO;
}

#pragma mark common methods
-(void) refreshData{
	[App_Delegate getQuickTaskList:self.filterCaluse];
	[App_Delegate getCompletedTasksToday];
	[tableViewDo reloadData];
	[tableViewDone reloadData];
}

-(void)deselectedCell{
	if(self.isDoViewSelected){
		[self tableView: tableViewDo didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:self.pathIndex inSection:0]];
		//self.pathIndex=-1;
		//self.isDoViewSelected=NO;
		[tableViewDo setEditing:NO animated:NO];
	}
		
}

#pragma mark -
#pragma mark === TableView datasource methods ===
#pragma mark -

// As the delegate and data source for the table, the PreferencesView must respond to certain methods the table view
// will call to get the number of sections, the number of rows, and the cell for a row.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;//one section for each table
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	//ILOG(@"[ListTaskView numberOfRowsInSection\n");
	if([table isEqual:tableViewDo] && section==0){
		//[App_Delegate getQuickTaskList:self.filterCaluse];
		return taskmanager.quickTaskList.count;
	}else if([table isEqual: tableViewDone] && section==0){
		//[App_Delegate getCompletedTasksToday];
		return taskmanager.completedTaskList.count;
	}
	
	self.isDoViewSelected=NO;
	
	//ILOG(@"ListTaskView numberOfRowsInSection]\n");
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// this table has only one section
	return @"";
}


#pragma mark -
#pragma mark === TableView delegate methods ===
#pragma mark -
// Specify the kind of accessory view (to the far right of each row) we will use
//- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
//	return UITableViewCellAccessoryNone;
//}

// Provide cells for the table, with each showing one of the available time signatures
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//ILOG(@"[ListTaskView cellForRowAtIndexPath\n");

	if([table isEqual: tableViewDo] && indexPath.section==0){
		TableCellFocus *cell = (TableCellFocus *)[table dequeueReusableCellWithIdentifier:@"DoCell"];
		if (cell == nil) {
			cell = [[[TableCellFocus alloc] initWithFrame:CGRectZero reuseIdentifier:@"DoCell"] autorelease];
		}else {
			NSArray *subViewList=[cell.contentView subviews];
			
			for (id tmp in subViewList){
				if ([tmp isKindOfClass:[CalendarIconView class]]) {
					[tmp removeFromSuperview];
				}
			}
		}

		
		if(taskmanager.quickTaskList.count>0){
			if (indexPath.row<=taskmanager.quickTaskList.count){ 
				Task *tmpTask=[taskmanager.quickTaskList objectAtIndex:indexPath.row];
				
				cell.taskName.text=tmpTask.taskName;
				
				//UIImageView *projType;
				
				CalendarIconView *icon=[[CalendarIconView alloc] initWithFrame:CGRectMake(10, 8, 10, 10)];
				icon.backgroundColor=[UIColor clearColor];
				
				if(tmpTask.taskPinned==1){
					/*
					if([[taskmanager.quickTaskList objectAtIndex:indexPath.row] isAllDayEvent]==0){
						projType=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"circle%d.png",[[taskmanager.quickTaskList objectAtIndex:indexPath.row] taskProject]+1]]];
					}else {
						projType=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"rec%d.png",[[taskmanager.quickTaskList objectAtIndex:indexPath.row] taskProject]+1]]];
					}
					 */
					icon.isSquareBox=YES;
				}else {
					//projType=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"poly%d.png",[[taskmanager.quickTaskList objectAtIndex:indexPath.row] taskProject]+1]]];
					icon.isSquareBox=NO;
				}

				icon.calendarId=tmpTask.taskProject;
				[icon setNeedsDisplay];
				[cell.contentView addSubview:icon];
				[icon release];
				/*
				projType.frame=CGRectMake(10, 8, 10, 10);
				[cell.contentView addSubview:projType];
				[projType release];
				 */

				//cell.leftButton=nil;
				cell.rightButton=editButon;
				
				if([tmpTask taskIsUseDeadLine] &&([[tmpTask taskDeadLine] compare:[NSDate date]]==NSOrderedAscending)){
					cell.textLabel.textColor=[UIColor redColor];	
				}else if([[tmpTask taskEndTime] compare:[NSDate date]]==NSOrderedAscending){
					cell.taskName.textColor=[UIColor brownColor];	
				}else {
					cell.taskName.textColor=[Colors darkSteelBlue];	
				}
		
				if([tmpTask taskPinned]==1){
					NSString *timeStr=[ivoUtility createTimeStringFromDate:[tmpTask taskStartTime]];
					cell.startTime.text=timeStr;
					[timeStr release];
				}else {
					if([tmpTask taskIsUseDeadLine]==1){
						NSString *timeStr=[ivoUtility createStringFromDate:[tmpTask taskDeadLine] isIncludedTime:NO];
						cell.startTime.text=timeStr;
						[timeStr release];
					}else {
						cell.startTime.text=@"";
					}
				}
			}	
		}else {
			cell.taskName.text=NSLocalizedString(@"nothingToDoText", @"")/*nothingToDoText*/;
			cell.taskName.textColor=[UIColor brownColor];
		}
		return cell;
		
	}else if([table isEqual: tableViewDone] &&  indexPath.section==0) {
		TableCellFocus *cell = (TableCellFocus *)[table dequeueReusableCellWithIdentifier:@"DoCell"];
		if (cell == nil) {
				cell = [[[TableCellFocus alloc] initWithFrame:CGRectZero reuseIdentifier:@"DoCell"] autorelease];
			
		}else {
			NSArray *subViewList=[cell.contentView subviews];
			
			for (id tmp in subViewList){
				if ([tmp isKindOfClass:[CalendarIconView class]]) {
					[tmp removeFromSuperview];
				}
			}
		}
		
			cell.textLabel.font=[UIFont systemFontOfSize:14];
		//cell.textLabel.leftButton=nil;
		cell.rightButton=nil;
		
		//UIImageView *projType;
		Task *tmpTask=[taskmanager.completedTaskList objectAtIndex:indexPath.row];
		
		/*
		if(tmpTask.taskPinned==1){
			if(tmpTask.isAllDayEvent==0){
				projType=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"circle%d.png",[[taskmanager.completedTaskList objectAtIndex:indexPath.row] taskProject]+1]]];
			}else {
				projType=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"rec%d.png",[[taskmanager.completedTaskList objectAtIndex:indexPath.row] taskProject]+1]]];
			}
			
		}else {
			projType=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"poly%d.png",[[taskmanager.completedTaskList objectAtIndex:indexPath.row] taskProject]+1]]];
		}
		
		projType.frame=CGRectMake(10, 8, 10, 10);
		[cell.contentView addSubview:projType];
		[projType release];
		 */
		 
		CalendarIconView *icon=[[CalendarIconView alloc] initWithFrame:CGRectMake(10, 8, 10, 10)];
		icon.backgroundColor=[UIColor clearColor];
		
		if([tmpTask taskPinned]==1){
			/*
			 if([[taskmanager.quickTaskList objectAtIndex:indexPath.row] isAllDayEvent]==0){
			 projType=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"circle%d.png",[[taskmanager.quickTaskList objectAtIndex:indexPath.row] taskProject]+1]]];
			 }else {
			 projType=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"rec%d.png",[[taskmanager.quickTaskList objectAtIndex:indexPath.row] taskProject]+1]]];
			 }
			 */
			icon.isSquareBox=YES;
		}else {
			//projType=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"poly%d.png",[[taskmanager.quickTaskList objectAtIndex:indexPath.row] taskProject]+1]]];
			icon.isSquareBox=NO;
		}
		
		icon.calendarId=tmpTask.taskProject;
		[icon setNeedsDisplay];
		[cell.contentView addSubview:icon];
		[icon release];
		
		//cell.leftButton=nil;
		cell.rightButton=editButon;
		
		if(taskmanager.completedTaskList.count>0){
			if (indexPath.row<=taskmanager.completedTaskList.count){ 
				cell.taskName.text = [tmpTask taskName];
				
				if( [tmpTask taskPinned]==1){
					cell.taskName.textColor=[Colors sienna];	
				}else {
					cell.taskName.textColor=[UIColor darkGrayColor];
				}
			}	
		}else {
			cell.taskName.text=NSLocalizedString(@"nothingDoneText", @"")/*nothingDoneText*/;
			cell.taskName.textColor=[UIColor brownColor];
		}
		
		return cell;
	}

	//ILOG(@"ListTaskView cellForRowAtIndexPath]\n");
	return nil;
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {

	//ILOG(@"[ListTaskView didSelectRowAtIndexPath\n");
	self.isSwipe=NO;	
	if([table isEqual:tableViewDo] && taskmanager.quickTaskList.count>0){
	//if(taskmanager.quickTaskList.count>0){
		//NSString *cellText=[[table cellForRowAtIndexPath:newIndexPath] text];
		rootViewController.currentSelectedKey=[[taskmanager.quickTaskList objectAtIndex:newIndexPath.row] primaryKey];
		
		NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:self.pathIndex inSection:0];	

		[[table cellForRowAtIndexPath:oldIndexPath] setEditing:NO animated:NO];
		if(![oldIndexPath isEqual:newIndexPath]) {
			self.pathIndex=newIndexPath.row ;//[[table indexPathForSelectedRow] section];

			[[table cellForRowAtIndexPath:newIndexPath] setEditing:YES animated:YES];
			

			if(!table.isEditing){
				[table setEditing:YES animated:YES];
			}else {
			//[tableView reloadData];
				[table setEditing:NO animated:NO];
				[table setEditing:YES animated:YES];
			}

			self.isDoViewSelected=YES;

			if([table isEqual:tableViewDo]){
				//if([doneButton superview])
				//	[doneButton removeFromSuperview];
				//[[[table cellForRowAtIndexPath:newIndexPath] contentView] addSubview:doneButton];
				
				if([editButon superview])
					[editButon removeFromSuperview];
				[[[table cellForRowAtIndexPath:newIndexPath] contentView] addSubview:editButon];
				
				
				if([self.cellTextVal superview])
					[self.cellTextVal removeFromSuperview];
				[[[table cellForRowAtIndexPath:newIndexPath] contentView] addSubview:self.cellTextVal];
				
				self.cellTextVal.highlighted=YES;
				
				NSInteger taskKey=[[taskmanager.quickTaskList objectAtIndex:self.pathIndex] primaryKey];
				[self.rootViewController resetQuickEditMode:NO taskKey:taskKey];
				
				//update old selected row
				if(oldIndexPath.row<taskmanager.quickTaskList.count){
					[[table cellForRowAtIndexPath:oldIndexPath].textLabel setText:self.cellTextVal.text];
					if([[taskmanager.quickTaskList objectAtIndex:oldIndexPath.row] taskIsUseDeadLine] && 
					   [[[taskmanager.quickTaskList objectAtIndex:oldIndexPath.row] taskDeadLine] compare:[NSDate date]]==NSOrderedAscending){
						//passed deadline
						[[table cellForRowAtIndexPath:oldIndexPath].textLabel setTextColor:[UIColor redColor]];
					}else if([[[taskmanager.quickTaskList objectAtIndex:oldIndexPath.row] taskEndTime] compare:[NSDate date]]==NSOrderedAscending){
						//passed Smart End
						[[table cellForRowAtIndexPath:oldIndexPath].textLabel setTextColor:[UIColor brownColor]];
					}else {
						//in due
						[[table cellForRowAtIndexPath:oldIndexPath].textLabel setTextColor:[Colors darkSteelBlue]];
					}
					[[table cellForRowAtIndexPath:oldIndexPath].textLabel setFont:[UIFont systemFontOfSize:14]];
				}
				
				//backup new selected row value
				self.cellTextVal.text=[[table cellForRowAtIndexPath:newIndexPath].textLabel text];
				[[table cellForRowAtIndexPath:newIndexPath].textLabel setText:@""];
				if([[taskmanager.quickTaskList objectAtIndex:newIndexPath.row] taskIsUseDeadLine] && 
				   [[[taskmanager.quickTaskList objectAtIndex:newIndexPath.row] taskDeadLine] compare:[NSDate date]]==NSOrderedAscending){
					//passed deadline
					self.cellTextVal.textColor=[UIColor redColor];
				}else if([[[taskmanager.quickTaskList objectAtIndex:newIndexPath.row] taskEndTime] compare:[NSDate date]]==NSOrderedAscending){
					//passed Smart End
					self.cellTextVal.textColor=[UIColor brownColor];
				}else {
					//in due
					self.cellTextVal.textColor=[Colors darkSteelBlue];
				}
				
			}
			
		}else {
			if(table.isEditing){
				self.isSwipe=YES;
				self.isDoViewSelected=NO;
				
				[table setEditing:NO animated:YES];
				[table deselectRowAtIndexPath:newIndexPath animated:YES];
				[[table cellForRowAtIndexPath:newIndexPath] setEditing:NO animated:NO];
			
				if([table isEqual:tableViewDo]){
					//return to the original state before selected.
					[[table cellForRowAtIndexPath:newIndexPath].textLabel setText:self.cellTextVal.text];
					self.cellTextVal.highlighted=NO;
					[[table cellForRowAtIndexPath:newIndexPath].textLabel setFont:[UIFont systemFontOfSize:14]];
					
					//if([[[taskmanager.quickTaskList objectAtIndex:oldIndexPath.row] taskEndTime] compare:[NSDate date]]==NSOrderedAscending){
					//	[[table cellForRowAtIndexPath:oldIndexPath] setTextColor:[UIColor redColor]];
					//}else {
					//	[[table cellForRowAtIndexPath:oldIndexPath] setTextColor:[Colors darkSteelBlue]];
					//}
					
					if(oldIndexPath.row<taskmanager.quickTaskList.count){
						[[table cellForRowAtIndexPath:oldIndexPath].textLabel setText:self.cellTextVal.text];
						self.cellTextVal.highlighted=NO;
						if([[taskmanager.quickTaskList objectAtIndex:oldIndexPath.row] taskIsUseDeadLine] && 
						   [[[taskmanager.quickTaskList objectAtIndex:oldIndexPath.row] taskDeadLine] compare:[NSDate date]]==NSOrderedAscending){
							//passed deadline
							[[table cellForRowAtIndexPath:oldIndexPath].textLabel setTextColor:[UIColor redColor]];
						}else if([[[taskmanager.quickTaskList objectAtIndex:oldIndexPath.row] taskEndTime] compare:[NSDate date]]==NSOrderedAscending){
							//passed Smart End
							[[table cellForRowAtIndexPath:oldIndexPath].textLabel setTextColor:[UIColor brownColor]];
						}else {
							//in due
							[[table cellForRowAtIndexPath:oldIndexPath].textLabel setTextColor:[Colors darkSteelBlue]];
						}
						[[table cellForRowAtIndexPath:oldIndexPath].textLabel setFont:[UIFont systemFontOfSize:14]];
					}
					
					[self.cellTextVal removeFromSuperview];
					//[doneButton removeFromSuperview];
					[editButon removeFromSuperview];
					NSInteger taskKey=[[taskmanager.quickTaskList objectAtIndex:self.pathIndex] primaryKey];
					[self.rootViewController resetQuickEditMode:YES taskKey:taskKey];
				}
			}else {
				[[table cellForRowAtIndexPath:newIndexPath] setEditing:YES animated:YES];
				[table setEditing:YES animated:YES];
				self.isDoViewSelected=YES;
				
				if([table isEqual:tableViewDo]){
					//if([doneButton superview])
					//	[doneButton removeFromSuperview];
					//[[[table cellForRowAtIndexPath:newIndexPath] contentView] addSubview:doneButton];
					
					if([editButon superview])
						[editButon removeFromSuperview];
					[[[table cellForRowAtIndexPath:newIndexPath] contentView] addSubview:editButon];
					
					
					if([self.cellTextVal superview])
						[self.cellTextVal removeFromSuperview];
					[[[table cellForRowAtIndexPath:newIndexPath] contentView] addSubview:self.cellTextVal];
					
					//[[[table cellForRowAtIndexPath:newIndexPath] contentView] addSubview:doneButton];
					//[[[table cellForRowAtIndexPath:newIndexPath] contentView] addSubview:editButon];
					//[[[table cellForRowAtIndexPath:newIndexPath] contentView] addSubview:self.cellTextVal];
					
					self.cellTextVal.highlighted=YES;
					
					NSInteger taskKey=[[taskmanager.quickTaskList objectAtIndex:self.pathIndex] primaryKey];
					[self.rootViewController resetQuickEditMode:NO taskKey:taskKey];
					
					//backup new selected row value
					self.cellTextVal.text=[[table cellForRowAtIndexPath:newIndexPath].textLabel text];
					[[table cellForRowAtIndexPath:newIndexPath].textLabel setText:@""];
					if([[taskmanager.quickTaskList objectAtIndex:oldIndexPath.row] taskIsUseDeadLine] && 
					   [[[taskmanager.quickTaskList objectAtIndex:oldIndexPath.row] taskDeadLine] compare:[NSDate date]]==NSOrderedAscending){
						//passed deadline
						self.cellTextVal.textColor=[UIColor redColor];
					}else if([[[taskmanager.quickTaskList objectAtIndex:oldIndexPath.row] taskEndTime] compare:[NSDate date]]==NSOrderedAscending){
						//passed Smart End
						self.cellTextVal.textColor=[UIColor brownColor];
					}else {
						//in due
						self.cellTextVal.textColor=[Colors darkSteelBlue];
					}
				}
			}
		}
	}else {
		//self.pathIndex=-1;
		self.isSwipe=YES;
		[table setEditing:NO animated:YES];		
		[[table cellForRowAtIndexPath:newIndexPath] setEditing:NO animated:NO];
		
		if([table isEqual:tableViewDo] && taskmanager.quickTaskList.count==0){
			[table deselectRowAtIndexPath:newIndexPath animated:YES];	
		}
		
	}

	
	if([table isEqual:tableViewDone]){
		self.isSwipe=YES;
		[table deselectRowAtIndexPath:newIndexPath animated:YES];
		if(self.isDoViewSelected){
			[self tableView:tableViewDo didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:self.pathIndex inSection:0]];
		}
		
	}
	
	//[table deselectRowAtIndexPath:newIndexPath animated:YES];

	//ILOG(@"ListTaskView didSelectRowAtIndexPath]\n");
}

- (void)tableView:(UITableView *)tV commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	//NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:self.pathIndex inSection:0];
	//ILOG(@"[ListTaskView commitEditingStyle\n");
	if(editingStyle==UITableViewCellEditingStyleDelete){
		if([tV isEqual:tableViewDo]){
             Task *task=[taskmanager.quickTaskList objectAtIndex:indexPath.row];
			if([[taskmanager.quickTaskList objectAtIndex:indexPath.row] taskCompleted]==1){
				[[taskmanager.quickTaskList objectAtIndex:indexPath.row] deleteFromDatabase]; 
                
                if ([task.iCalIdentifier length]>0) {
                    taskmanager.currentSetting.deletedICalEvents=[taskmanager.currentSetting.deletedICalEvents stringByAppendingFormat:@"|%@",task.iCalIdentifier];
                    
                    [taskmanager.currentSetting update];
                    
                    if (taskmanager.currentSetting.autoICalSync && taskmanager.currentSetting.enableSyncICal) {
                        [taskmanager.ekSync backgroundFullSync];
                    }
                }

                if ([task.reminderIdentifier length]>0) {
                    taskmanager.currentSetting.deletedReminders=[taskmanager.currentSetting.deletedReminders stringByAppendingFormat:@"|%@",task.reminderIdentifier];
                    [taskmanager.currentSetting update];
                    if (taskmanager.currentSetting.autoICalSync && taskmanager.currentSetting.enabledReminderSync) {
                        [taskmanager.reminderSync backgroundFullSync];
                    }
                }

			}else {
				rootViewController.currentSelectedKey=[[taskmanager.quickTaskList objectAtIndex:indexPath.row] primaryKey];
				[rootViewController performSelector:@selector(deletedTask:) withObject:nil];
				//[taskmanager deleteTask:[[taskmanager.quickTaskList objectAtIndex:indexPath.row] primaryKey] isDeleteFromDB:YES deleteREType:-1];
			}
			return;
		}else {
            Task *task=[taskmanager.completedTaskList objectAtIndex:indexPath.row];
			if(task.taskCompleted==1){
				[[taskmanager.completedTaskList objectAtIndex:indexPath.row] deleteFromDatabase]; 
                
                if ([task.iCalIdentifier length]>0) {
                    taskmanager.currentSetting.deletedICalEvents=[taskmanager.currentSetting.deletedICalEvents stringByAppendingFormat:@"|%@",task.iCalIdentifier];
                    
                    [taskmanager.currentSetting update];
                    
                    [taskmanager.ekSync backgroundFullSync];
                }

                if ([task.reminderIdentifier length]>0) {
                    taskmanager.currentSetting.deletedReminders=[taskmanager.currentSetting.deletedReminders stringByAppendingFormat:@"|%@",task.reminderIdentifier];
                    [taskmanager.currentSetting update];
                    if (taskmanager.currentSetting.autoICalSync && taskmanager.currentSetting.enabledReminderSync) {
                        [taskmanager.reminderSync backgroundFullSync];
                    }
                }

			}else {
				[taskmanager deleteTask:[[taskmanager.completedTaskList objectAtIndex:indexPath.row] primaryKey] isDeleteFromDB:YES deleteREType:-1];
			}
		}
	}else if(editingStyle==UITableViewCellEditingStyleInsert){
		[tableViewDo setEditing:NO animated:YES];
		[tableViewDo deselectRowAtIndexPath:indexPath animated:YES];
		[[tableViewDo cellForRowAtIndexPath:indexPath] setEditing:NO animated:NO];
		[doneButton removeFromSuperview];
		
		[self.rootViewController editTaskFromListView:[taskmanager.quickTaskList objectAtIndex:indexPath.row]];
	}

	[self refreshData];
	[tV reloadData];
	//ILOG(@"ListTaskView commitEditingStyle]\n");
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
	return;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{

}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
	
	return NO;	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 30;
}

//swipe to delete
- (void)tableView:(UITableView *)table didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
	self.isSwipe=YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)table editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	
    if (!self.isSwipe){
		if([table isEqual:tableViewDo] && self.pathIndex==indexPath.row){
			//return UITableViewCellEditingStyleInsert;
			return UITableViewCellEditingStyleNone;
		}
	}else {
		if(([table isEqual:tableViewDo] && (taskmanager.quickTaskList.count>0)) || 
		   ([table isEqual:tableViewDone] && (taskmanager.completedTaskList.count>0))){
			return UITableViewCellEditingStyleDelete;	
		}
	}
	return UITableViewCellEditingStyleNone;	
}

#pragma mark properties
-(NSInteger)pathIndex{
	return pathIndex;	
}

-(void)setPathIndex:(NSInteger)pathIdx{
	pathIndex=pathIdx;	
}

-(NSInteger)restoreIndex{
	return restoreIndex;	
}

-(void)setRestoreIndex:(NSInteger)pathIdx{
	restoreIndex=pathIdx;	
}

-(BOOL)isSwipe{
	return isSwipe;	
}

-(void)setIsSwipe:(BOOL)swipe{
	isSwipe=swipe;	
}

-(BOOL)isDoViewSelected{
	return isDoViewSelected;	
}

-(void)setIsDoViewSelected:(BOOL)selected{
	isDoViewSelected=selected;	
}

-(NSString *)filterCaluse{
	return filterCaluse;
}

-(void)setFilterCaluse:(NSString *)aString{
	[filterCaluse release];
	filterCaluse=[aString copy];
}

@end
