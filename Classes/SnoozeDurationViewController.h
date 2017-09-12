//
//  SnoozeDurationViewController.h
//  SmartTime
//
//  Created by NangLe on 2/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SnoozeDurationViewController : UIViewController<UIPickerViewDelegate> {
	id					editedObject; 
	UIPickerView		*timerDPView;
	UIView				*contentView;
}
@property (nonatomic, retain)	id			editedObject;

@end
