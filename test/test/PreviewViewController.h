//
//  PreviewViewController.h
//  Salutations 365
//
//  Created on 25/11/13.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>

#import "OverlayViewController.h"

@interface PreviewViewController : UIViewController<NSURLConnectionDelegate>
{
    MPMoviePlayerViewController *movie;
//    MPMoviePlayerController *movie;
    UIProgressView *progress;
    NSMutableData *responseData;
    
    
    IBOutlet OverlayViewController *overlay;
    
    
    
    IBOutlet UIProgressView *progress1;
    IBOutlet UIButton *startStopBtn;
    IBOutlet UILabel *timeLbl1,*timeLbl2;
    NSTimer *updateTimer;
    
    
    NSOperationQueue* queue;
    
    UIBackgroundTaskIdentifier backgroundTask;
}

@property(nonatomic)BOOL isUploading;

-(void)startTimer;
-(void)stopTimer;

-(IBAction)ClickStartStop;

@end
