//
//  AlertValueViewController.h
//  SmartTime
//
//  Created by Nang Le on 11/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AlertValueViewController : UIViewController <UIPickerViewDelegate,UIAlertViewDelegate> {
	id					editedObject; 
	UIPickerView		*timerDPView;
	NSInteger			keyEdit;
	UIView				*contentView;
	BOOL				isOnDateSelected;
	
    /*
	UIButton			*smsOptionButton;
	UIButton			*popupOptionButton;
	UIButton			*mailOptionButton;
	UIButton			*APNSOptionButton;
	
	NSString			*alertValuesStr;
	NSInteger			alertByVal;
	UIAlertView			*pushAlertView;
     */
	NSInteger			taskPinned;
    BOOL                noAlertSeleced;
}

@property (nonatomic, retain)	id			editedObject;
@property (nonatomic, assign) NSInteger		keyEdit;
//@property (nonatomic, copy) NSString		*alertValuesStr;
@property (nonatomic, assign) NSInteger			taskPinned;

-(void)resetAlertBy:(NSInteger)option;

@end
