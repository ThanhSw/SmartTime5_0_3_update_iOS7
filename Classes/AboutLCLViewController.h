//
//  AboutLCLViewController.h
//  SmartTime
//
//  Created by Nang Le on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutLCLViewController : UIViewController<UIWebViewDelegate>{
    UIWebView *webcontent;
    UISegmentedControl *viewOptionSeg;
}

@end
