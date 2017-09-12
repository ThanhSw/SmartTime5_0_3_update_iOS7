//
//  TableCellWhatLocation.h
//  SmartTime
//
//  Created by Nang Le on 10/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TableCellWhatLocation : UITableViewCell {
	UITextView	*cellContent;
	UIButton	*editLocationButton;	
}

@property (nonatomic,retain) UITextView *cellContent;
@property (nonatomic,retain) UIButton	*editLocationButton;
@end
