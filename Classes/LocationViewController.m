//
//  LocationViewController.m
//  iVo
//
//  Created by Nang Le on 7/8/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "LocationViewController.h"
#import "SmartTimeAppDelegate.h"
#import <CoreFoundation/CoreFoundation.h>
#import "Task.h"
#import <AddressBook/AddressBook.h>
#import "InfoEditViewController.h"
#import "SmartTimeAppDelegate.h"
#import "Colors.h"

//extern Setting			*currentSetting;
extern NSMutableArray	*locationList;
extern NSArray			*contactList;
extern NSArray			*locationDisplayListByName;
extern NSArray			*locationDisplayListByContact;
extern SmartTimeAppDelegate	*App_Delegate;

NSString *localeNameForTimeZoneNameComponents(NSArray *nameComponents);

@implementation LocationViewController
@synthesize editedObject;
@synthesize oldSelectedIndex;
@synthesize indexArrayList;

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
	//ILOG(@"[SmartViewController loadView\n");
	// Don't invoke super if you want to create a view hierarchy programmatically
	//[super loadView];
	// Add navigation item buttons.
	
    CGRect frame=[[UIScreen mainScreen] bounds];
    
	if(!App_Delegate.isLoadingLocation){
		[App_Delegate createTwoLocationDisplayList];
	}
	
    saveButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
															  target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = saveButton;
	self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
		
	self.navigationItem.title =NSLocalizedString(@"locationText", @"Locations")/*locationText*/;//@"Locations";
	
	contentView=[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	contentView.backgroundColor=[UIColor darkGrayColor];
	
	/*
	currentSelectLocation=[[UITextField alloc] initWithFrame:CGRectMake(10, 5, 300, 35)];
	currentSelectLocation.delegate=self;
	currentSelectLocation.borderStyle=UITextBorderStyleRoundedRect;
	currentSelectLocation.keyboardType=UIKeyboardTypeDefault;
	currentSelectLocation.returnKeyType=UIReturnKeyDone;
	currentSelectLocation.font=[UIFont systemFontOfSize:18];
	currentSelectLocation.clearButtonMode=UITextFieldViewModeWhileEditing;	
	currentSelectLocation.placeholder=@"Tap here for new location";
	[contentView addSubview:currentSelectLocation];
	*/

	sortAddress=[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects: NSLocalizedString(@"sortedByaddressText", @"")/*sortedByaddressText*/, NSLocalizedString(@"sortedByContactText", @"")/*sortedByContactText*/, nil]];
	sortAddress.frame=CGRectMake(10, frame.size.height-44, 300, 36);
	//sortAddress.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	//sortAddress.segmentedControlStyle = UISegmentedControlStylePlain;
    sortAddress.tintColor=[UIColor whiteColor];
	[sortAddress addTarget:self action:@selector(sortAction:) forControlEvents:UIControlEventValueChanged];
	sortAddress.selectedSegmentIndex=0;
	[contentView addSubview:sortAddress];
	
	tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 320,frame.size.height-64-44) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
	
	[contentView addSubview:tableView];
    self.view = contentView;

	indexArrayList=[[NSMutableArray alloc] initWithCapacity:1];
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
	
	//ILOG(@"SmartViewController loadView]\n");
}


/*
 If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad {
}
 */

-(void)refreshFrames{
    CGRect frame=[[UIScreen mainScreen] bounds];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        contentView.frame=CGRectMake(0, 0, frame.size.height, frame.size.width);
        sortAddress.frame=CGRectMake(10, frame.size.width-40, frame.size.height-20, 36);
        tableView.frame = CGRectMake(0, 64, frame.size.height,frame.size.width-44-64);
        
    }else{
        contentView.frame=CGRectMake(0, 0, frame.size.width, frame.size.height);
        sortAddress.frame=CGRectMake(10, frame.size.height-40, frame.size.width-20, 36);
        tableView.frame = CGRectMake(0, 64, frame.size.width,frame.size.height-64-44);
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

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self refreshFrames];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
	//[pool release];
}


- (void)dealloc {

	tableView.delegate = nil;
    tableView.dataSource = nil;
	[tableView release];
    [saveButton release];
	[selectedLocation release];
	selectedLocation=nil;
	[oldSelectedIndex release];
	oldSelectedIndex=nil;
	[contentView release];
	[indexArrayList release];
//	currentSelectLocation.delegate=nil;
//	[currentSelectLocation release];
	[sortAddress release];
	
	//Trung 08101002
	[editedObject release];
	
	[super dealloc];
}

#pragma mark controller delegate

- (void)viewWillAppear:(BOOL)animated {
	//ILOG(@"[SmartViewController viewWillAppear\n");
	
    [self refreshFrames];
	self.selectedLocation=[self.editedObject taskLocation];
	
    //[tableView reloadData];
	//ILOG(@"SmartViewController viewWillAppear]\n");
}

- (void)viewDidAppear:(BOOL)animated {
	[tableView scrollToRowAtIndexPath:self.oldSelectedIndex atScrollPosition:UITableViewScrollPositionNone animated:YES];
//	currentSelectLocation.text=self.selectedLocation;

}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	//ILOG(@"[SmartViewController setEditing\n");
    [super setEditing:editing animated:animated];
    //[tableView reloadData];
	//ILOG(@"SmartViewController setEditing]\n");
}

- (void)viewDidLoad {
	//[self setUpDisplayList:NO];
}

#pragma mark action Methods

- (IBAction)cancel:(id)sender {
    // cancel edits
//	[currentSelectLocation resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
	//ILOG(@"[SmartViewController save\n");
//	[currentSelectLocation resignFirstResponder];
	[self.editedObject setTaskLocation:self.selectedLocation];
	[self.navigationController popViewControllerAnimated:YES];
	//ILOG(@"SmartViewController save]\n");
}

- (IBAction)sortAction:(id)sender {
	//ILOG(@"[SmartViewController sortAction\n");
	//if(self.displayList !=nil){
	//	[self.displayList release];
	//}
	
	if(sortAddress.selectedSegmentIndex==1){
		//[self setUpDisplayList:YES];
	}else {
		//[self setUpDisplayList:NO];
	}

	[tableView reloadData];
	//ILOG(@"SmartViewController sortAction]\n");
}

-(void)cleanContactText:(id)sender{
//	currentSelectLocation.text=@"";
}


#pragma mark -
#pragma mark <UITableViewDelegate, UITableViewDataSource> Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
	//if(self.displayList.count>0){
	//	return [self.displayList count];
	//}
	if(sortAddress.selectedSegmentIndex==1){
		if(locationDisplayListByName.count>0)
			return locationDisplayListByName.count;
	}else {
		if(locationDisplayListByContact.count>0)
			return locationDisplayListByContact.count;
	}

	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//ILOG(@"[SmartViewController numberOfRowsInSection\n");
	// Number of rows is the number of names in the region dictionary for the specified section
		if(sortAddress.selectedSegmentIndex==1){
			if(locationDisplayListByName.count>0){
				NSDictionary *letterDictionary = [locationDisplayListByName objectAtIndex:section];
				NSArray *locationsForLetter = [letterDictionary objectForKey:@"locations"];
				//ILOG(@"SmartViewController numberOfRowsInSection]\n");
				return [locationsForLetter count];
			}
		}else {
			if(locationDisplayListByContact.count>0){
				NSDictionary *letterDictionary = [locationDisplayListByContact objectAtIndex:section];
				NSArray *locationsForLetter = [letterDictionary objectForKey:@"locations"];
				//ILOG(@"SmartViewController numberOfRowsInSection]\n");
				return [locationsForLetter count];
			}
		}
		
	//ILOG(@"SmartViewController numberOfRowsInSection]\n");	
	return 0;

}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// The header for the section is the region name -- get this from the dictionary at the section index
	
	if(sortAddress.selectedSegmentIndex==1){
		if(locationDisplayListByName.count>0){
			NSDictionary *sectionDictionary = [locationDisplayListByName objectAtIndex:section];
			NSString *titleLeter= [sectionDictionary valueForKey:@"letter"];
			if([titleLeter isEqualToString:@"Z#"])
				return @"#";
			return titleLeter;		
		}
	}else {
		if(locationDisplayListByContact.count>0){
			NSDictionary *sectionDictionary = [locationDisplayListByContact objectAtIndex:section];
			NSString *titleLeter= [sectionDictionary valueForKey:@"letter"];
			if([titleLeter isEqualToString:@"Z#"])
				return @"#";
			return titleLeter;		
		}
	}
	
	return @"";
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	/*
	 Return the index titles for each of the sections (e.g. "A", "B", "C"...).
	 Use key-value coding to get the value for the key @"letter" in each of the dictionaries in list.
	 */
	if(locationDisplayListByContact.count > 0 && sortAddress.selectedSegmentIndex==0){
		return indexArrayList;		
	}
	return nil;
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	// Return the index for the given section title
	if(sortAddress.selectedSegmentIndex==1){
		if(locationDisplayListByName.count>0){
			if([title isEqualToString:@"#"]){
				return locationDisplayListByName.count -1;
			}
			
		return [locationDisplayListByName indexOfObject:title];		
		}
	}else {
		if(locationDisplayListByContact.count>0){
			if([title isEqualToString:@"#"]){
				return locationDisplayListByContact.count -1;
			}
			
			return [locationDisplayListByContact indexOfObject:title];		
		}
	}
	
		
	return 0;
}



- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//ILOG(@"[SmartViewController cellForRowAtIndexPath\n");
 	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifier"] autorelease];
	}
	
	[cell.textLabel setTextColor:[UIColor blackColor]];
	
	if(sortAddress.selectedSegmentIndex==1){
		if(locationDisplayListByName.count>0){
			NSDictionary *letterDictionary = [locationDisplayListByName objectAtIndex:indexPath.section];
			NSArray *locationsForLetter = [letterDictionary objectForKey:@"locations"];
			NSDictionary *locationDictionary = [locationsForLetter objectAtIndex:indexPath.row];
			
			// Set the cell's text to the name of the time zone at the row
			cell.textLabel.text = [locationDictionary objectForKey:@"locationLocaleName"];
			
			if(self.selectedLocation !=nil){
				if ([self.selectedLocation isEqual:cell.textLabel.text] ) {
					self.oldSelectedIndex=indexPath;//[NSIndexPath indexPathForRow:indexPath.row inSection :indexPath.section];
					[cell.textLabel setTextColor:[Colors darkSteelBlue]];
				}	
			}
			
		}else {
			cell.textLabel.text=@"";
		}
	}else {
		if(locationDisplayListByContact.count>0){
			NSDictionary *letterDictionary = [locationDisplayListByContact objectAtIndex:indexPath.section];
			NSArray *locationsForLetter = [letterDictionary objectForKey:@"locations"];
			NSDictionary *locationDictionary = [locationsForLetter objectAtIndex:indexPath.row];
			
			// Set the cell's text to the name of the time zone at the row
			cell.textLabel.text = [locationDictionary objectForKey:@"locationLocaleName"];
			
			if(self.selectedLocation !=nil){
				if ([self.selectedLocation isEqual:cell.textLabel.text] ) {
					self.oldSelectedIndex=indexPath;//[NSIndexPath indexPathForRow:indexPath.row inSection :indexPath.section];
					[cell.textLabel setTextColor:[Colors darkSteelBlue]];
				}	
			}
			
		}else {
			cell.textLabel.text=@"";
		}
	}
	
	if(self.oldSelectedIndex !=nil && [self.oldSelectedIndex compare:indexPath]==NSOrderedSame){
		cell.accessoryType= UITableViewCellAccessoryCheckmark;
    }else {
		cell.accessoryType= UITableViewCellAccessoryNone;
	}
	
	//ILOG(@"SmartViewController cellForRowAtIndexPath]\n");
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(self.oldSelectedIndex !=nil){
		[[tv cellForRowAtIndexPath:self.oldSelectedIndex].textLabel setTextColor:[UIColor blackColor]];
	}
	[[tv cellForRowAtIndexPath:indexPath].textLabel setTextColor:[Colors darkSteelBlue]];
    // Never allow selection.
    if (self.editing) {
		//saveButton.enabled=TRUE;
		return indexPath;
	}
    return nil;
}


/*- (UITableViewCellAccessoryType)tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	
    if(self.oldSelectedIndex !=nil && [self.oldSelectedIndex compare:indexPath]==NSOrderedSame){
		return UITableViewCellAccessoryCheckmark;
    }
    return UITableViewCellAccessoryNone;
}
*/

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	//ILOG(@"[SmartViewController didSelectRowAtIndexPath\n");
	//mark the selected cell as checked
	[[table cellForRowAtIndexPath:self.oldSelectedIndex] setAccessoryType:UITableViewCellAccessoryNone];
    [[table cellForRowAtIndexPath:newIndexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
	
	//keep current index path
    self.oldSelectedIndex=newIndexPath;//[NSIndexPath indexPathForRow:newIndexPath.row inSection:newIndexPath.section];
	
	//keep selected contact
	self.selectedLocation=[[table cellForRowAtIndexPath:newIndexPath].textLabel text];
	//currentSelectLocation.text= [[table cellForRowAtIndexPath:newIndexPath] text];
//	currentSelectLocation.text=self.selectedLocation;
	
	//deselect to hide the highlight of selected cell
    [table deselectRowAtIndexPath:newIndexPath animated:YES];
	//ILOG(@"SmartViewController didSelectRowAtIndexPath]\n");
}

#pragma mark common uses
/*
- (void)setUpDisplayList:(BOOL)isSortByName {
	//ILOG(@"[SmartViewController setUpDisplayList\n");
	
	// Create an array (contacts) of dictionaries
	// Each dictionary groups together the time zones with locale names beginning with a particular letter:
	// key = "letter" value = e.g. "A"
	// key = "contacts" value = [array of dictionaries]
	 
	// Each dictionary in "contacts" contains keys "timeZone" and "timeZoneLocaleName"
	 
	
	NSMutableDictionary *indexedContacts = [[NSMutableDictionary alloc] init];
	
	for (int i=0; i< contactList.count; i++){
		
		ABRecordRef record = [contactList objectAtIndex:i];
		
		ABMutableMultiValueRef multiValue = ABRecordCopyValue(record, kABPersonAddressProperty);

		if(ABMultiValueGetCount(multiValue)>0){
	
			for(int j=0; j<ABMultiValueGetCount(multiValue);j++){//get all address from a contact
				CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(multiValue, j);
				CFStringRef street = CFDictionaryGetValue(dict, kABPersonAddressStreetKey);
				CFStringRef city = CFDictionaryGetValue(dict, kABPersonAddressCityKey);
				CFStringRef country = CFDictionaryGetValue(dict, kABPersonAddressCountryKey);		
				CFRelease(dict);
		
				NSString *locationName;
				if(street!=nil){
					locationName=[NSString stringWithFormat:@"%@",street];
				}else {
					locationName=[NSString stringWithString: @""];
				}
				
				if(city!=nil){
					if(street!=nil){
						NSString *cityNameAppend=[NSString stringWithFormat:@", %@",city];
						locationName=[locationName stringByAppendingFormat:cityNameAppend];
					}else{
						NSString *cityNameAsLoc=[NSString stringWithFormat:@"%@",city];
						locationName=[locationName stringByAppendingFormat:cityNameAsLoc];
					}
				}
				
				if(country!=nil){
					if(![locationName isEqualToString:@""]){
						NSString *countryNameAppend=[NSString stringWithFormat:@", %@",country];
						locationName=[locationName stringByAppendingFormat:countryNameAppend];
					}else{
						NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",country];
						locationName=[locationName stringByAppendingFormat:countryNameAsLoc];
					}
				}
				
				NSString *locFull=[locationName copy];
				locationName=[locFull stringByReplacingOccurrencesOfString:@"\n" withString:@" "];//remove new line character;
				[locFull release];
				
				if( !isSortByName){
					NSString *firstLetter = [[locationName substringToIndex:1] uppercaseString];
					
					if([firstLetter compare:@"A"]==NSOrderedAscending  || [firstLetter compare:@"z"]==NSOrderedDescending)
						firstLetter=@"Z#";
					
					NSMutableArray *indexArray = [indexedContacts objectForKey:firstLetter];
					if (indexArray == nil) {
						indexArray = [[NSMutableArray alloc] init];
						[indexedContacts setObject:indexArray forKey:firstLetter];
						//[indexArray release];
					}
					NSDictionary *contactDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:locationName, @"locations", locationName, @"locationLocaleName", nil];
					[indexArray addObject:contactDictionary];
					[contactDictionary release];
				}else {
					//ABRecordRef ref = CFArrayGetValueAtIndex((CFArrayRef)contactList,(CFIndex)i);
					
					CFStringRef firstName = ABRecordCopyValue(record, kABPersonFirstNameProperty);
					CFStringRef lastName = ABRecordCopyValue(record, kABPersonLastNameProperty);
					
					if (firstName==nil && lastName==nil){
						firstName=(CFStringRef)@"No name";
						lastName=(CFStringRef)@" ";
					}else if(firstName==nil) {
						firstName=(CFStringRef) @" ";
					}else if(lastName==nil){
						lastName=(CFStringRef)@" ";
					}
					
					NSString *contactName=[NSString stringWithFormat:@"%@ %@",firstName, lastName];
					
					NSString *firstLetter = [contactName copy];
					NSMutableArray *indexArray = [indexedContacts objectForKey:firstLetter];
					if (indexArray == nil) {
						indexArray = [[NSMutableArray alloc] init];
						[indexedContacts setObject:indexArray forKey:firstLetter];
//						[indexArray release];
					}
					NSDictionary *contactDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:locationName, @"locations", locationName, @"locationLocaleName", nil];
					[indexArray addObject:contactDictionary];
					[contactDictionary release];
				}
			}
		}
		CFRelease(multiValue);
	}
	
		
		// Finish setting up the data structure:
		// Create the contacts array;
		// Sort the used index letters and keep as an instance variable;
		// Sort the contents of the contacts arrays;
		 
	NSMutableArray *locations = [[NSMutableArray alloc] init];
	
	// Normally we'd use a localized comparison to present information to the user, but here we know the data only contains unaccented uppercase letters
	self.indexLetters = [[indexedContacts allKeys] sortedArrayUsingSelector:@selector(compare:)];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"locationLocaleName" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];

	NSString *indexLetterTmp;
	for (indexLetterTmp in self.indexLetters) {		
		NSMutableArray *locaionDictionaries = [indexedContacts objectForKey:indexLetterTmp];
		[locaionDictionaries sortUsingDescriptors:sortDescriptors];
		
		NSString *indexLetter= [indexLetterTmp copy];
		NSDictionary *letterDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:indexLetter, @"letter", locaionDictionaries, @"locations", nil];
		[locations addObject:letterDictionary];
		[indexLetter release];
		[letterDictionary release];
	}
	[sortDescriptor release];
	
	self.displayList = locations;
	[locations release];
	[indexedContacts release];
	
	//ILOG(@"SmartViewController setUpDisplayList]\n");
}
*/
#pragma mark TextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	return YES;	
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
	NSString *loc=[textField.text copy];
	self.selectedLocation=loc;	
	[loc release];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
}

#pragma mark properties

- (NSString	*)selectedLocation{
	return selectedLocation;	
}

- (void)setSelectedLocation:(NSString *)aString{
	[selectedLocation release];
	selectedLocation=[aString copy];	
}

/*
-(NSArray*)displayList{
	return displayList;
}


-(void)setDisplayList:(NSArray *)arr{
	[displayList release];
	//displayList=[arr copy];
	displayList=[[NSArray alloc] initWithArray:arr];
}

-(NSArray*)indexLetters{
	return indexLetters;
}

-(void)setIndexLetters:(NSArray *)arr{
	[indexLetters release];
	//indexLetters=[arr copy];
	indexLetters=[[NSArray alloc] initWithArray:arr];
}

*/
@end
