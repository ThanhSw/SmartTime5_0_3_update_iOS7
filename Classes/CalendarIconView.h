//
//  CalendarIconView.h
//  SmartOrganizer
//
//  Created by Nang Le Van on 8/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CalendarIconView : UIView {
	NSInteger calendarId;
	BOOL      isSquareBox;
	BOOL	  isIndicator;	
    BOOL      isCircle;  
}

@property(nonatomic,assign) NSInteger calendarId;
@property(nonatomic,assign) BOOL      isSquareBox;
@property(nonatomic,assign) BOOL	  isIndicator;
@property(nonatomic,assign) BOOL      isCircle; 

-(void)drawInContext:(CGContextRef)context;

@end
