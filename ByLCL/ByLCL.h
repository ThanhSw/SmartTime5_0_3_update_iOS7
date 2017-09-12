
#import <UIKit/UIKit.h>

#define CreateByLCL() [[[ByLCL alloc] initialize] autorelease]

@interface ByLCL : UIViewController
<UIWebViewDelegate> {
  IBOutlet UIWebView          *webView;
  IBOutlet UINavigationItem *navItem;
}

- (ByLCL*) initialize;


@end
