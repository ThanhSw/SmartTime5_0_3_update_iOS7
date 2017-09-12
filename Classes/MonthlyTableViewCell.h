//
//  MonthlyTableViewCell.h
//  SmartTime
//
//  Created by Left Coast Logic on 2/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MonthlyTableViewCell : UITableViewCell {
	UILabel *taskName;
	UIImageView *projectIcon;
}

-(void) setType:(NSInteger)type :(NSInteger)project;
-(void) setName:(NSString *)name;

- (void) resetIvoStyle;

@end
