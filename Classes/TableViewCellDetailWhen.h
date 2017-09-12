//
//  TableViewCellDetailWhen.h
//  SmartTime
//
//  Created by Nang Le on 1/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TableViewCellDetailWhen : UITableViewCell {
	UILabel	*title1;
	UILabel	*title2;
	UILabel	*value1;
	UILabel	*value2;
}
@property(nonatomic,retain) UILabel	*title1;
@property(nonatomic,retain) UILabel	*title2;
@property(nonatomic,retain) UILabel	*value1;
@property(nonatomic,retain) UILabel	*value2;

@end
