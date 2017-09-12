//
//  DatePickerViewController.h
//  SmartTime
//
//  Created by Huy Le on 8/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;

@interface DatePickerViewController : UIViewController {
	UIDatePicker		*datePicker;
	
	Task *				editedObject;
	NSInteger			keyEdit;
	
	UIButton *noneDueButton;
}

@property (nonatomic, retain)	Task *editedObject;
@property (nonatomic, assign)	NSInteger	keyEdit;

@end
