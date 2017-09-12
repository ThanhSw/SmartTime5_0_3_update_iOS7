//
//  HistoryView.m
//  iVo
//
//  Created by Nang Le on 7/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HistoryView.h"
#import "TaskManager.h"
#import "SmartTimeAppDelegate.h"
#import "Colors.h"
#import "ivo_Utilities.h"
#import "Task.h"
#import "IvoCommon.h"
#import "EKSync.h"
#import "ReminderSync.h"

//extern Setting			*currentSetting;
extern SmartTimeAppDelegate	*App_Delegate;
extern TaskManager		*taskmanager;
extern ivo_Utilities	*ivoUtility;

@implementation HistoryView
//@synthesize historyTableView;
@synthesize isSwipe;


- (id)initWithFrame:(CGRect)frame {
	//ILOG(@"[HistoryView initWithFrame\n");
	if (self = [super initWithFrame:frame]) {
        CGRect mainframe=[[UIScreen mainScreen] bounds];
        
		historyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, mainframe.size.width,mainframe.size.height-70) style:UITableViewStylePlain];
		historyTableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
		historyTableView.allowsSelectionDuringEditing=YES;
		historyTableView.delegate = self;
		historyTableView.dataSource = self;

		[self addSubview:historyTableView];
		
	}
	//ILOG(@"HistoryView initWithFrame]\n");
	return self;
}


- (void)drawRect:(CGRect)rect {
	// Drawing code
}


- (void)dealloc {
	//ILOG(@"[HistoryView dealloc\n");
	
	[historyTableView removeFromSuperview];
	historyTableView.delegate=nil;
	historyTableView.dataSource=nil;
	[historyTableView release];
	
	[fullCompletedTasksList release];
	
	[displayList release];
	
	[indexLetters release];
	
	[super dealloc];
	//ILOG(@"HistoryView dealloc]\n");
}

#pragma mark -
#pragma mark <UITableViewDelegate, UITableViewDataSource> Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
	//ILOG(@"[HistoryView numberOfSectionsInTableView\n");
	[self setUpDisplayList];
	if([self.displayList count]>0){
		//ILOG(@"HistoryView numberOfSectionsInTableView]\n");
		return [self.displayList count]; 
	}
	//ILOG(@"HistoryView numberOfSectionsInTableView]\n");
	return 1;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
	//ILOG(@"[HistoryView numberOfRowsInSection\n");
    // Only one row for each section
	if([self.displayList count]>0){
		NSDictionary *letterDictionary = [self.displayList objectAtIndex:section];
		NSArray *doneTasksForLetter = [letterDictionary objectForKey:@"doneTasks"];
		//ILOG(@"HistoryView numberOfRowsInSection]\n");
		return [doneTasksForLetter count];
	}
	
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// The header for the section is the region name -- get this from the dictionary at the section index
	//ILOG(@"[HistoryView tableView\n");
	if([self.displayList count]>0){
		//NSDictionary *sectionDictionary = [self.displayList objectAtIndex:self.displayList.count - section -1];
		NSDictionary *sectionDictionary = [self.displayList objectAtIndex:section];
		//ILOG(@"HistoryView tableView]\n");
		return [sectionDictionary valueForKey:@"letter"];
	}
	//ILOG(@"HistoryView tableView]\n");
	return nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	/*
	 Return the index titles for each of the sections (e.g. "A", "B", "C"...).
	 Use key-value coding to get the value for the key @"letter" in each of the dictionaries in list.
	 */
	//return [self.displayList valueForKey:@"letter"];
	//ILOG(@"[HistoryView sectionIndexTitlesForTableView]\n");
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	// Return the index for the given section title
	//ILOG(@"[HistoryView tableView\n");
	if([self.displayList count]>0){
		//ILOG(@"HistoryView tableView]\n");
		return [self.indexLetters indexOfObject:title];
	}
	//ILOG(@"HistoryView tableView]\n");
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//ILOG(@"[HistoryView cellForRowAtIndexPath\n");
	
	// Try to retrieve from the table view a now-unused cell with the given identifier
 	UITableViewCell *cell = [historyTableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifier"] autorelease];
	}else {
		NSArray *subViewList=[cell.contentView subviews];
		
		for (UIView *tmp in subViewList){
			if([tmp isKindOfClass:[UIImageView class]])
			[tmp removeFromSuperview];
		}
	}
	
	cell.textLabel.font=[UIFont systemFontOfSize:14];
	
	//NSDictionary *letterDictionary = [self.displayList objectAtIndex:self.displayList.count-indexPath.section-1];
	NSDictionary *letterDictionary = [self.displayList objectAtIndex: indexPath.section];
	NSArray *doneTasksForLetter = [letterDictionary objectForKey:@"doneTasks"];
	NSDictionary *contactDictionary = [doneTasksForLetter objectAtIndex:indexPath.row];
	
	// Set the cell's text to the name of the contact name at the row
	cell.textLabel.text =[NSString stringWithFormat:@"     %@", [[contactDictionary objectForKey:@"doneTasks"] taskName]];
	
	if([[contactDictionary objectForKey:@"doneTasks"] taskPinned]==1){
		cell.textLabel.textColor=[Colors sienna];	
	}else {
		cell.textLabel.textColor=[UIColor darkGrayColor];
	}
	
	UIImageView *projType;
	Task *tmpTask=[contactDictionary objectForKey:@"doneTasks"];
	
	if(tmpTask.taskPinned==1){
		if(tmpTask.isAllDayEvent==0){
			projType=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"circle%d.png",[[contactDictionary objectForKey:@"doneTasks"] taskProject]+1]]];
		}else {
			projType=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"rec%d.png",[[contactDictionary objectForKey:@"doneTasks"] taskProject]+1]]];
		}
		
	}else {
		projType=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"poly%d.png",[[contactDictionary objectForKey:@"doneTasks"] taskProject]+1]]];
	}
	
	projType.frame=CGRectMake(10, 10, 10, 10);
	[cell.contentView addSubview:projType];
	[projType release];
	
	//ILOG(@"HistoryView cellForRowAtIndexPath]\n");
	return cell;
}

//- (UITableViewCellAccessoryType)tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	
 //   return UITableViewCellAccessoryNone;
//}


- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	//ILOG(@"[HistoryView didSelectRowAtIndexPath\n");
	//deselect to hide the highlight of selected cell
    [table deselectRowAtIndexPath:newIndexPath animated:YES];
	//ILOG(@"HistoryView didSelectRowAtIndexPath]\n");
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
	//return;
}
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
	//NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:self.pathIndex inSection:0];	
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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	
   // if (self.isSwipe){
		return UITableViewCellEditingStyleDelete;	
	//}
	//return UITableViewCellEditingStyleNone;	
}


- (void)tableView:(UITableView *)tV commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	//ILOG(@"[HistoryView commitEditingStyle\n");

	NSDictionary *letterDictionary = [self.displayList objectAtIndex:indexPath.section];
	NSArray *contactsForLetter = [letterDictionary objectForKey:@"doneTasks"];
	NSDictionary *contactDictionary = [contactsForLetter objectAtIndex:indexPath.row];
	//printf("\ntask name %s",[[[contactDictionary objectForKey:@"doneTasks"] taskName] UTF8String]);
    Task *task=[contactDictionary objectForKey:@"doneTasks"];
        
	[task deleteFromDatabase]; 
	
    if ([task.iCalIdentifier length]>0) {
        taskmanager.currentSetting.deletedICalEvents=[taskmanager.currentSetting.deletedICalEvents stringByAppendingFormat:@"|%@",task.iCalIdentifier];
        
        [taskmanager.currentSetting update];
        
        if (taskmanager.currentSettingModifying.autoICalSync && taskmanager.currentSettingModifying.enableSyncICal) {
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

	[historyTableView reloadData];
	//ILOG(@"HistoryView commitEditingStyle]\n");
}

#pragma mark common uses

- (void)setUpDisplayList {
	/*
	 Create an array (doneTasks) of dictionaries
	 Each dictionary groups together the time zones with locale names beginning with a particular letter:
	 key = "letter" value = e.g. "A"
	 key = "doneTasks" value = [array of dictionaries]
	 
	 Each dictionary in "doneTasks" contains keys "timeZone" and "timeZoneLocaleName"
	 */
	//ILOG(@"[HistoryView setUpDisplayList\n");
	
	NSMutableDictionary *indexedContacts = [[NSMutableDictionary alloc] init];
		
	NSMutableArray *fullDoneList=[App_Delegate createFullDoneTaskList];
	self.fullCompletedTasksList=fullDoneList;
	[fullDoneList release];
	
	for (int i=0; i< self.fullCompletedTasksList.count; i++){
		
		Task *tmp=[self.fullCompletedTasksList objectAtIndex:i] ;		
		
		//NSString *dateComplete=[ivoUtility createStringFromDate:[tmp taskDateUpdate] isIncludedTime:NO];
		NSDate *updateDate=[[tmp taskDateUpdate] copy];
		NSString *dateComplete=[ivoUtility createStringFromShortDate:updateDate];
		
		NSMutableArray *indexArray = [indexedContacts objectForKey:dateComplete];
		if (indexArray == nil) {
			indexArray = [[NSMutableArray alloc] init];
			[indexedContacts setObject:indexArray forKey:dateComplete];
			[indexArray release];
		}
		
		NSDictionary *contactDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:tmp, @"doneTasks", updateDate, @"taskName", nil];
		[indexArray addObject:contactDictionary];
		[contactDictionary release];
		[updateDate release];
		[dateComplete release];
	}
	
	/*
	 Finish setting up the data structure:
	 Create the doneTasks array;
	 Sort the used index letters and keep as an instance variable;
	 Sort the contents of the doneTasks arrays;
	 */
	
	
	NSMutableArray *doneTasks = [[NSMutableArray alloc] init];
	
	// Normally we'd use a localized comparison to present information to the user, but here we know the data only contains unaccented uppercase letters
	self.indexLetters = [[indexedContacts allKeys] sortedArrayUsingSelector:@selector(compare:)];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"taskName" ascending:NO];//lasted done task is top most of section
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	
	for (NSString *indexLetter in self.indexLetters) {
		
		NSMutableArray *contactDictionaries = [indexedContacts objectForKey:indexLetter];
		[contactDictionaries sortUsingDescriptors:sortDescriptors];
		
		NSDictionary *letterDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:indexLetter, @"letter", contactDictionaries, @"doneTasks", nil];
		[doneTasks addObject:letterDictionary];
		[letterDictionary release];
	}
	[sortDescriptor release];
	
	
	NSMutableArray* indexListInDescendingOrder=[[NSMutableArray alloc] initWithArray:doneTasks]; 
	NSSortDescriptor *sortIndexListDescriptor = [[NSSortDescriptor alloc] initWithKey:@"letter"  ascending: NO];
	NSArray *sortIndexListDescriptors = [NSArray arrayWithObject:sortIndexListDescriptor];
	self.displayList=[indexListInDescendingOrder sortedArrayUsingDescriptors:sortIndexListDescriptors];
	[indexListInDescendingOrder release];
	[sortIndexListDescriptor release];
	
	
	//self.displayList = doneTasks;
	[doneTasks release];
	[indexedContacts release];

	//ILOG(@"HistoryView setUpDisplayList]\n");
}

#pragma mark properties
-(NSArray*)displayList{
	return displayList;
}

-(void)setDisplayList:(NSArray *)arr{
	[displayList release];
	//displayList=[arr copy];
	displayList=[[NSArray alloc] initWithArray:arr];
}

-(NSMutableArray*)fullCompletedTasksList{
	return fullCompletedTasksList;
}

-(void)setFullCompletedTasksList:(NSMutableArray *)arr{
	[fullCompletedTasksList release];
	//fullCompletedTasksList=[arr copy];
	fullCompletedTasksList=[[NSMutableArray alloc] initWithArray:arr];
}

-(NSArray*)indexLetters{
	return indexLetters;
}

-(void)setIndexLetters:(NSArray *)arr{
	[indexLetters release];
	//indexLetters=[arr copy];
	indexLetters=[[NSArray alloc] initWithArray:arr];
}

@end
