//
//  OverlayViewController.m
//  Internet Sensation
//
//

#import "OverlayViewController.h"

@interface OverlayViewController ()

@end

@implementation OverlayViewController

@synthesize toolbar,toolbar1;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7.0)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    navBar.hidden = !navBar.hidden;
    toolbar.hidden = !toolbar.hidden;
    toolbar1.hidden = !toolbar1.hidden;
}

@end
