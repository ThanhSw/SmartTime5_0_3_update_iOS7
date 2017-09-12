//
//  DurationViewController.h
//  SmartTime
//
//  Created by Nang Le on 11/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DurationViewController : UIViewController {
	id					editedObject; 
	UIDatePicker		*timerDPView;
	NSInteger			keyEdit;
	UIView				*contentView;
    UIButton *allWorkDayButton;
    UIButton *allHomeDayButton;
    UIButton *allDayButton;
}
@property (nonatomic, retain)	id			editedObject;
@property (nonatomic, assign) NSInteger		keyEdit;

-(void)refreshFrames;

@end
