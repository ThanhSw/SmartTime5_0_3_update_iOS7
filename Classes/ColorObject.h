//
//  ColorObject.h
//  SmartOrganizer
//
//  Created by Nang Le Van on 8/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ColorObject : NSObject {
	CGFloat R1;
	CGFloat G1;
	CGFloat B1;
	
	CGFloat R2;
	CGFloat G2;
	CGFloat B2;
	
	CGFloat R3;
	CGFloat G3;
	CGFloat B3;
}

@property(nonatomic,assign) CGFloat R1;
@property(nonatomic,assign)  CGFloat G1;
@property(nonatomic,assign)  CGFloat B1;

@property(nonatomic,assign)  CGFloat R2;
@property(nonatomic,assign)  CGFloat G2;
@property(nonatomic,assign)  CGFloat B2;

@property(nonatomic,assign)  CGFloat R3;
@property(nonatomic,assign)  CGFloat G3;
@property(nonatomic,assign)  CGFloat B3;


@end
