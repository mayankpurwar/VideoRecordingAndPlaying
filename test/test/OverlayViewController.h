//
//  OverlayViewController.h
//  Internet Sensation
//
//

#import <UIKit/UIKit.h>

@interface OverlayViewController : UIViewController
{
    IBOutlet UINavigationBar *navBar;
    IBOutlet UIToolbar *toolbar,*toolbar1;
}

@property(nonatomic,retain) IBOutlet UIToolbar *toolbar,*toolbar1;

@end
