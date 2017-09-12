//
//  SettingView.h
//  iVoProtoTypes
//
//  Created by Nang Le on 6/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"

@class SmartViewController;
@class Setting;
//@class GCalSync;

@interface SettingView : UIView <UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate> {

	UITableView *tableView;
	NSInteger	pathIndex;
	SmartViewController *rootViewController;
	UISwitch	*pushForward;
	UISwitch	*changeDeadline;
	UILabel		*bumpTaskDescr;
	UILabel		*bumpDeadlineDescr;
	
	UISwitch	*deleteWarning;
	UIAlertView *deleteDupAlert;
	UIButton *deleteDupButon;
	
	SKProduct *proUpgradeProduct;
    SKProductsRequest *productsRequest;
}
//@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) SmartViewController *rootViewController;
@property (nonatomic, assign) NSInteger pathIndex;
@property (nonatomic, retain) UISwitch	*pushForward;
@property (nonatomic, retain) UISwitch	*changeDeadline;
@property (nonatomic, retain) UILabel	*bumpTaskDescr;
@property (nonatomic, retain) UILabel	*bumpDeadlineDescr;
@property (nonatomic, retain) UIButton  *deleteDupButon;

-(void)resetData;
//- (void) requestProductData;
//- (void)loadStore;
//- (BOOL)canMakePurchases;
//- (void)purchaseProUpgrade;

-(void) editSyncWindow;
//-(void) editSyncMapping;
//-(void) editSyncDirection;
//-(void) editSyncDirection;
- (void) createSyncWindowCell:(UITableViewCell *)cell;
@end
