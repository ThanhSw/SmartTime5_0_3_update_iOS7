//
//  CustomStoreObserver.m
//  SmartTime
//
//  Created by NangLe on 1/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CustomStoreObserver.h"


@implementation CustomStoreObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	for (SKPaymentTransaction *transaction in transactions)
	{
		switch (transaction.transactionState)
		{
			case SKPaymentTransactionStatePurchased:
				[self completeTransaction:transaction];
				break;
			case SKPaymentTransactionStateFailed:
				[self failedTransaction:transaction];
				break;
			case SKPaymentTransactionStateRestored:
				[self restoreTransaction:transaction];
			default:
				break;
		}
	}
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
	if (transaction.error.code != SKErrorPaymentCancelled)
	{
		// Optionally, display an error here.
	}
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
	//If you want to save the transaction
	// [self recordTransaction: transaction];
	
	//Provide the new content
	// [self provideContent: transaction.originalTransaction.payment.productIdentifier];
	
	//Finish the transaction
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
	
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
	//If you want to save the transaction
	// [self recordTransaction: transaction];
	
	//Provide the new content
	//[self provideContent: transaction.payment.productIdentifier];
	
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
	
}

@end
