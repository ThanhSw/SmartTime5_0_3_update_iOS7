//
//  ContactView.m
//  iVo_NewAddTask
//
//  Created by Nang Le on 5/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ContactViewConroller.h"
#import <AddressBook/AddressBook.h>
#import "SmartTimeAppDelegate.h"
#import "Task.h"
#import "Contacts.h"
#import "IvoCommon.h"
#import "WhatViewController.h"
#import "Colors.h"

extern NSArray	*contactList;
//extern Setting	*currentSetting;
extern NSArray	*contactDisplayList;
extern SmartTimeAppDelegate		*App_Delegate;
extern NSInteger			loadingView;

@implementation ContactViewConroller
@synthesize editedObject;
@synthesize oldSelectedIndex;
@synthesize indexArrayList;
@synthesize filterContactList;
@synthesize contactSearchBar;

/*
 This method is not invoked if the controller is restored from a nib file.
 All relevant configuration should have been performed in Interface Builder.
 If you need to do additional setup after loading from a nib, override -loadView.
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
		self.title = NSLocalizedString(@"ContactView", @"ContactView title");
	}
	return self;
}

-(id) init{
	self = [super init];

	return self;	
}



- (void)loadView {
	//ILOG(@"[ContactViewConroller loadView\n");
	// Don't invoke super if you want to create a view hierarchy programmatically
	//[super loadView];
	// Add navigation item buttons.
	
	if(!App_Delegate.isLoadingContact){
		[App_Delegate createUpContactDisplayList];
	}
	
    CGRect frame=[[UIScreen mainScreen] bounds];
    
    saveButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
															  target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = saveButton;
	self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
	
	self.navigationItem.title =NSLocalizedString(@"contactsText", @"")/*contactsText*/;//@"Contacts";
	
	contentView=[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	contentView.backgroundColor=[UIColor darkGrayColor];
	
    self.view = contentView;
	
	tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-65) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;

	[contentView addSubview:tableView];
	[tableView release];
	
	indexArrayList=[[NSMutableArray alloc] initWithCapacity:1];
	//[indexArrayList addObject:@"8"];
	[indexArrayList addObject:NSLocalizedString(@"aText", @"")/*aText*/];
	[indexArrayList addObject:NSLocalizedString(@"bText", @"")/*bText*/];
	[indexArrayList addObject:NSLocalizedString(@"ccText", @"")/*ccText*/];
	[indexArrayList addObject:NSLocalizedString(@"dText", @"")/*dText*/];
	[indexArrayList addObject:NSLocalizedString(@"eText", @"")/*eText*/];
	[indexArrayList addObject:NSLocalizedString(@"fText", @"")/*fText*/];
	[indexArrayList addObject:NSLocalizedString(@"gText", @"")/*gText*/];
	[indexArrayList addObject:NSLocalizedString(@"hText", @"")/*hText*/];
	[indexArrayList addObject:NSLocalizedString(@"iText", @"")/*iText*/];
	[indexArrayList addObject:NSLocalizedString(@"jText", @"")/*jText*/];
	[indexArrayList addObject:NSLocalizedString(@"kText", @"")/*kText*/];
	[indexArrayList addObject:NSLocalizedString(@"lText", @"")/*lText*/];
	[indexArrayList addObject:NSLocalizedString(@"mText", @"")/*mText*/];
	[indexArrayList addObject:NSLocalizedString(@"nText", @"")/*nText*/];
	[indexArrayList addObject:NSLocalizedString(@"oText", @"")/*oText*/];
	[indexArrayList addObject:NSLocalizedString(@"pText", @"")/*pText*/];
	[indexArrayList addObject:NSLocalizedString(@"qText", @"")/*qText*/];
	[indexArrayList addObject:NSLocalizedString(@"rText", @"")/*rText*/];
	[indexArrayList addObject:NSLocalizedString(@"sText", @"")/*sText*/];
	[indexArrayList addObject:NSLocalizedString(@"tText", @"")/*tText*/];
	[indexArrayList addObject:NSLocalizedString(@"uText", @"")/*uText*/];
	[indexArrayList addObject:NSLocalizedString(@"vText", @"")/*vText*/];
	[indexArrayList addObject:NSLocalizedString(@"wText", @"")/*wText*/];
	[indexArrayList addObject:NSLocalizedString(@"xText", @"")/*xText*/];
	[indexArrayList addObject:NSLocalizedString(@"yText", @"")/*yText*/];
	[indexArrayList addObject:NSLocalizedString(@"zText", @"")/*zText*/];
	[indexArrayList addObject:@"#"];
	
	contactSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, 44)];
	contactSearchBar.delegate = self;
	//contactSearchBar.showsCancelButton = YES;
	//ILOG(@"ContactViewConroller loadView]\n");
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
	//[pool release];
}


- (void)dealloc {

	//[tableView release];
	tableView.delegate=nil;
	tableView.dataSource=nil;
	[saveButton release];
	[oldSelectedIndex release];
	
	[selectedContact release];
	[contentView release];
	[indexArrayList release];
	
	//Trung 08101002
	[editedObject release];

	[filterContactList release];
	[contactSearchBar release];
	
	[super dealloc];
}

#pragma mark controller delegate

- (void)viewWillAppear:(BOOL)animated {
	//ILOG(@"[ContactViewConroller viewWillAppear\n");
	
//	currentSelectContact.text=[self.editedObject taskContact];
	loadingView=CONTACT_VIEW;
	
	self.oldSelectedIndex=nil;
	[self getFilterList:nil];
    [tableView reloadData];
	isSearching=NO;
	isEditing=NO;
	isFullList=YES;
	
	if( filterContactList.count<=0){
		saveButton.enabled=NO;
	}
	//ILOG(@"ContactViewConroller viewWillAppear]\n");
}

-(void)viewDidAppear:(BOOL)animated{

}

- (void)viewWillDisappear:(BOOL)animated {
	//ILOG(@"[ContactViewConroller viewWillDisappear\n");
//	[currentSelectContact resignFirstResponder];
	//ILOG(@"ContactViewConroller viewWillDisappear]\n");
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	//ILOG(@"[ContactViewConroller setEditing\n");
    [super setEditing:editing animated:animated];
    //[tableView reloadData];
	//ILOG(@"ContactViewConroller setEditing]\n");
}

- (void)viewDidLoad {
	//[self setUpDisplayList];
}

#pragma mark action Methods

- (IBAction)cancel:(id)sender {
    // cancel edits
//	[currentSelectContact resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
	//ILOG(@"[ContactViewConroller save\n");
	if(self.oldSelectedIndex!=nil){
		[self.editedObject setTaskContact:self.selectedContact];
		NSDictionary *contactDictionary;
		
		if(!isFullList){
			contactDictionary = [filterContactList objectAtIndex:self.oldSelectedIndex.row];
		}else {
			NSDictionary *letterDictionary = [filterContactList objectAtIndex:self.oldSelectedIndex.section-1];
			NSArray *contactsForLetter = [letterDictionary objectForKey:@"contacts"];
			contactDictionary = [contactsForLetter objectAtIndex:self.oldSelectedIndex.row];
		}
		
		[self.editedObject setTaskLocation:[(Contacts *)[contactDictionary objectForKey:@"contacts"] contactAddress]];
		[self.editedObject setTaskEmailToSend:[(Contacts *)[contactDictionary objectForKey:@"contacts"] emailAddress]];
		[self.editedObject setPhoneToContact:[(Contacts *)[contactDictionary objectForKey:@"contacts"] phoneNumber]];
	}
	[self.navigationController popViewControllerAnimated:YES];
	
	//ILOG(@"ContactViewConroller save]\n");
}

- (void)doneEdit:(id)sender{
	//ILOG(@"[ContactViewConroller doneEdit\n");
//	[currentSelectContact resignFirstResponder];
	self.navigationItem.rightBarButtonItem=saveButton;
	//ILOG(@"ContactViewConroller doneEdit]\n");
}


#pragma mark -
#pragma mark <UITableViewDelegate, UITableViewDataSource> Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
	if(isSearching && isEditing){
		return 1;
	}else {
		if( filterContactList.count>0){
			return filterContactList.count+1; 
		}
	}
	return 1;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
    // Only one row for each section
	//ILOG(@"[ContactViewConroller numberOfRowsInSection\n");
	if(isSearching && isEditing){
		return filterContactList.count;
	}else {
		
		if(section==0) return 1;//search bar
		
		if( filterContactList.count>0){
			NSDictionary *letterDictionary = [filterContactList objectAtIndex:section-1];
			NSArray *contactsForLetter = [letterDictionary objectForKey:@"contacts"];
			//ILOG(@"ContactViewConroller numberOfRowsInSection]\n");
			return contactsForLetter.count;
		}
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// The header for the section is the region name -- get this from the dictionary at the section index
	//if(section==0) return nil;
	if(isSearching){
		return nil; 
	}else {
		if(section==0) return nil;
		
		if( filterContactList.count>0){
			NSDictionary *sectionDictionary = [filterContactList objectAtIndex:section-1];
			NSString *titleLeter= [sectionDictionary valueForKey:@"letter"];
			if([titleLeter isEqualToString:@"Z#"])
				return @"#";
			return titleLeter;
		}		
	}

	return nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	/*
	 Return the index titles for each of the sections (e.g. "A", "B", "C"...).
	 Use key-value coding to get the value for the key @"letter" in each of the dictionaries in list.
	 */
	//return [filterContactList valueForKey:@"letter"];
	//	NSArray *indexArray=[NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
	if(!isSearching && filterContactList.count>0){
		return indexArrayList;
	}
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	// Return the index for the given section title

	if( filterContactList.count>0){
		if([title isEqualToString:@"#"]){
			return App_Delegate.indexContactLetters.count;
		}
	
		return [App_Delegate.indexContactLetters indexOfObject:title] +1;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//ILOG(@"[ContactViewConroller cellForRowAtIndexPath\n");
	//printf("\nsection: %d",indexPath.section);
	if(isSearching && isEditing){
		// Try to retrieve from the table view a now-unused cell with the given identifier
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactIdentifier"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"ContactIdentifier"] autorelease];
		}
		
		[[cell textLabel] setTextColor:[UIColor blackColor]];
		
		NSDictionary *contactDictionary = [filterContactList objectAtIndex:indexPath.row];
		// Set the cell's text to the name of the contact name at the row
		cell.textLabel.text = [[contactDictionary objectForKey:@"contacts"] contactName];;
		
		if(self.selectedContact !=nil){
			if ([self.selectedContact isEqual:cell.textLabel.text] ) {
				self.oldSelectedIndex=indexPath;
				[[cell textLabel]  setTextColor:[Colors darkSteelBlue]];
			}
		}
		
		if( filterContactList.count>0 && self.oldSelectedIndex !=nil && [self.oldSelectedIndex compare:indexPath]==NSOrderedSame){
			cell.accessoryType= UITableViewCellAccessoryCheckmark;
		}else{
			cell.accessoryType= UITableViewCellAccessoryNone;
		}
		
		//ILOG(@"ContactViewConroller cellForRowAtIndexPath]\n");
		return cell;
		
	}else {
		switch (indexPath.section) {
			case 0:
			{
				// Try to retrieve from the table view a now-unused cell with the given identifier
				UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactIdentifier0"];
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"ContactIdentifier0"] autorelease];
				}
				
				if( filterContactList.count>0 && self.oldSelectedIndex !=nil && [self.oldSelectedIndex compare:indexPath]==NSOrderedSame){
					cell.accessoryType= UITableViewCellAccessoryCheckmark;
				}else{
					cell.accessoryType= UITableViewCellAccessoryNone;
				}
				
				if(indexPath.section==0){
					cell.textLabel.text=@"";
					if([contactSearchBar superview])
						[contactSearchBar removeFromSuperview];
					
					[cell.contentView addSubview:contactSearchBar];
					return cell;
				}	
			}
				break;
			default:
			{
				// Try to retrieve from the table view a now-unused cell with the given identifier
				UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactIdentifier"];
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"ContactIdentifier"] autorelease];
				}
				
				[[cell textLabel]  setTextColor:[UIColor blackColor]];
				
				NSDictionary *letterDictionary = [filterContactList objectAtIndex:indexPath.section-1];
				NSArray *contactsForLetter = [letterDictionary objectForKey:@"contacts"];
				NSDictionary *contactDictionary = [contactsForLetter objectAtIndex:indexPath.row];
				
				// Set the cell's text to the name of the contact name at the row
				cell.textLabel.text = [[contactDictionary objectForKey:@"contacts"] contactName];
				
				if(self.selectedContact !=nil){
					if ([self.selectedContact isEqual:cell.textLabel.text] ) {
						self.oldSelectedIndex=indexPath;
						[[cell textLabel] setTextColor:[Colors darkSteelBlue]];
					}
				}
				
				if( filterContactList.count>0 && self.oldSelectedIndex !=nil && [self.oldSelectedIndex compare:indexPath]==NSOrderedSame){
					cell.accessoryType= UITableViewCellAccessoryCheckmark;
				}else{
					cell.accessoryType= UITableViewCellAccessoryNone;
				}
				
				//ILOG(@"ContactViewConroller cellForRowAtIndexPath]\n");
				return cell;
			}
				break;
		}
	}

	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 44;
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Never allow selection.
	if(self.oldSelectedIndex !=nil){
		[[[tv cellForRowAtIndexPath:self.oldSelectedIndex] textLabel] setTextColor:[UIColor blackColor]];
	}
	[[[tv cellForRowAtIndexPath:indexPath] textLabel] setTextColor:[Colors darkSteelBlue]];
    if (self.editing) {
		saveButton.enabled=TRUE;
		return indexPath;
	}
    return nil;
}


/*- (UITableViewCellAccessoryType)tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	if( filterContactList.count>0){
		if(self.oldSelectedIndex !=nil && [self.oldSelectedIndex compare:indexPath]==NSOrderedSame){
			//[[tv cellForRowAtIndexPath:self.oldSelectedIndex] setTextColor:[Colors darkSteelBlue]];
			return UITableViewCellAccessoryCheckmark;
		}
	}
    return UITableViewCellAccessoryNone;
}
*/

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	//ILOG(@"[ContactViewConroller didSelectRowAtIndexPath\n");
	
	//mark the selected cell as checked
	if(newIndexPath.section!=0 || isEditing){ 
		[[table cellForRowAtIndexPath:self.oldSelectedIndex] setAccessoryType:UITableViewCellAccessoryNone];
		[[table cellForRowAtIndexPath:newIndexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
		//keep current index path
		self.oldSelectedIndex=newIndexPath;//[NSIndexPath indexPathForRow:newIndexPath.row inSection:newIndexPath.section];
	
		//keep selected contact
		self.selectedContact=[[[table cellForRowAtIndexPath:newIndexPath] textLabel] text];
		//	currentSelectContact.text=[[table cellForRowAtIndexPath:newIndexPath] text];
	
		//deselect to hide the highlight of selected cell
	}
    [table deselectRowAtIndexPath:newIndexPath animated:YES];
	//ILOG(@"ContactViewConroller didSelectRowAtIndexPath]\n");
  }

#pragma mark common uses
- (void)getFilterList:(NSString *)containText{
	//if(filterContactList!=nil)
	//	[filterContactList release];
	
	if((!containText || [containText isEqual:@""]) && !isEditing) {
		filterContactList=[(NSMutableArray *)contactDisplayList retain];
		isFullList=YES;
		return;
	}
	
	isFullList=NO;
	NSMutableArray *tmpList=[[NSMutableArray alloc] init];
	for(NSInteger i=0; i<contactDisplayList.count;i++){
		NSDictionary *letterDictionary = [contactDisplayList objectAtIndex:i];
		NSArray *contactsForLetter = [letterDictionary objectForKey:@"contacts"];
		for (NSInteger j=0;j<contactsForLetter.count;j++){
			NSDictionary *contactDictionary = [contactsForLetter objectAtIndex:j];

			if([containText isEqual:@""]){
				[tmpList addObject:contactDictionary];
			}else {
				//printf("\n name: %s",[[[contactDictionary objectForKey:@"contacts"] contactName] UTF8String]);
				NSRange strInStr=[[[[contactDictionary objectForKey:@"contacts"] contactName] uppercaseString] rangeOfString:[containText uppercaseString] options:NSCaseInsensitiveSearch];
				NSRange strInStr1=[[[[contactDictionary objectForKey:@"contacts"] companyName] uppercaseString] rangeOfString:[containText uppercaseString] options:NSCaseInsensitiveSearch];
				
				if(strInStr.location!=NSNotFound || strInStr1.location!=NSNotFound){
					
					[tmpList addObject:contactDictionary];
				}
			}
		}
	}
	filterContactList=[tmpList retain];
	[tmpList release];
}

#pragma mark UISearchBarDelegate
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
	isSearching=NO;
	isEditing=NO;
	searchBar.text=@"";

    CGRect frame=[[UIScreen mainScreen] bounds];
    
	[self getFilterList:nil];
	searchBar.showsCancelButton = NO;
	[searchBar resignFirstResponder];	
	[searchBar removeFromSuperview];

	//[[tableView cellForRowAtIndexPath:self.oldSelectedIndex] setTextColor:[UIColor blackColor]];
	//[[tableView cellForRowAtIndexPath:self.oldSelectedIndex] setAccessoryType:UITableViewCellAccessoryNone];
	self.oldSelectedIndex=nil;
	self.selectedContact=@"";
	
	[tableView removeFromSuperview];
	
	tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-65) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;

	[contentView addSubview:tableView];
	[tableView release];
	
	//[tableView reloadData];
	
	[tableView scrollToRowAtIndexPath:self.oldSelectedIndex atScrollPosition:UITableViewScrollPositionTop animated:YES];

}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
	return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
	isSearching=YES;
	[self getFilterList:nil];
	
	contactSearchBar.showsCancelButton = YES;
	[contactSearchBar removeFromSuperview];
	[contentView addSubview:contactSearchBar];
	//[contactSearchBar becomeFirstResponder];
	
	CGRect frm=tableView.frame;
	
	frm.size.height=200;
	tableView.frame=frm;
//	[tableView reloadData];
	isEditing=NO;

}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
	CGRect frame=[[UIScreen mainScreen] bounds];
    
	if(isSearching){
		self.oldSelectedIndex=nil;
		self.selectedContact=@"";

		isEditing=YES;
		[self getFilterList:searchText];
		
		[tableView removeFromSuperview];
		
		tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 43, frame.size.width, 157) style:UITableViewStylePlain];
		tableView.delegate = self;
		tableView.dataSource = self;
		[contentView addSubview:tableView];
		[tableView release];
		
		//[tableView reloadData];
		
	}//else {
	//	isEditing=NO;
	//	[self getFilterList:nil];
	//}
}

#pragma mark properties

- (NSString	*)selectedContact{
	return selectedContact;	
}

- (void)setSelectedContact:(NSString *)aString{
	if(selectedContact !=nil)
	[selectedContact release];
	selectedContact=[aString copy];	
}

/*
-(NSArray*)displayList{
	return displayList;
}

-(void)setDisplayList:(NSArray *)arr{
	if(displayList !=nil)
	[displayList release];
	displayList=[[NSArray alloc] initWithArray:arr];
}

-(NSArray*)indexLetters{
	return indexLetters;
}

-(void)setIndexLetters:(NSArray *)arr{
	if(indexLetters !=nil)
	[indexLetters release];
	indexLetters=[[NSArray alloc] initWithArray:arr];
}
*/

@end
