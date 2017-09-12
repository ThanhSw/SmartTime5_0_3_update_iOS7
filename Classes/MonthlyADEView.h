//
//  MonthlyADEView.h
//  SmartTime
//
//  Created by Left Coast Logic on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MonthlyADEView : UIView {
	NSDate *startDate;
	NSDate *endDate;
}

@property (nonatomic, copy) NSDate *startDate;
@property (nonatomic, copy) NSDate *endDate;

-(void) setStartDate:(NSDate *)startDateVal endDate:(NSDate *)endDateVal;

@end
