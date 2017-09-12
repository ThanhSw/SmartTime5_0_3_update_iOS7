//
//  SyncKeyObject.h
//
//  Created by NangLe on 7/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SyncKeyObject : NSObject {
	NSInteger	key;
	NSString	*urlString;
	id			editedObject;
}

@property(nonatomic,assign) NSInteger key;
@property(nonatomic,retain) NSString  *urlString;
@property(nonatomic,retain) id	editedObject;

@end
