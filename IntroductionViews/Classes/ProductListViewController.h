//
//  ProductListViewController.h
//  MugShotz
//
//  Created by Nang Le on 5/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProductListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
	UITableView	*productTableView;
	NSInteger loadingMode;
}
@property(assign,nonatomic) NSInteger loadingMode;
@end
