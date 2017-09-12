//
//  CalendarADEView.h
//  SmartTime
//
//  Created by Left Coast Logic on 1/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CalendarADEView : UIView {
	
	NSMutableArray *adeList;
	NSInteger currentIndex;
	NSInteger startIndex;
	
	NSDate *lastTouchTime;
	BOOL scrollToRight;
	
	BOOL selected;	
}

@property (nonatomic, retain) NSMutableArray *adeList; 
@property BOOL selected;

-(void)resetIndex;
- (void) changeBackgroundStyle;
- (NSInteger) getSelectedKey;

//trung ST3.1
- (NSInteger) getSelectedTaskKey;

@end
