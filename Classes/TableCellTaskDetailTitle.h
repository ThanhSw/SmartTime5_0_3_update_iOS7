//
//  TableCellTaskDetailTitle.h
//  SmartTime
//
//  Created by Nang Le on 10/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TableCellTaskDetailTitle : UITableViewCell {
	UITextField		*taskName;
	UITextField		*location;
	UIButton		*editButton;
}

@property (nonatomic,retain) UITextField	*taskName;
@property (nonatomic,retain) UITextField	*location;
@property (nonatomic,retain) UIButton		*editButton;

@end
