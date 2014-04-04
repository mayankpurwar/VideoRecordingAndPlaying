//
//  RecordViewController.h
//  Salutations 365
//
//  Created on 24/11/13.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AppDelegate.h"


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface RecordViewController : UIViewController<AVCaptureFileOutputRecordingDelegate>
{
    AVCaptureSession *captureSession;
    //    AVCaptureDevice *bCaptureDevice,*fCaptureDevice;
    AVCaptureDevice *Device;
	AVCaptureStillImageOutput *stillImageOutput;
	AVCaptureVideoPreviewLayer *previewLayer;
    

    
    BOOL captureError;
    BOOL isBackCamera;
    BOOL isFrontCamera;
    BOOL isBackworking;
    
    int devicePos;
    BOOL isTorchAvailable;
    
    
    
    
    BOOL sessionStartNotificationReceived;
    NSInteger flashState;
    
    AVCaptureMovieFileOutput    *movieFileOutput;
    
    IBOutlet UIButton *BtnRecordorStop;
    IBOutlet UIButton *BtncamFlip;
    IBOutlet UIButton *BtnFlash;
    
    IBOutlet UIButton *BtnDone,*BtnBack;
    
    
    BOOL isTorchON;
    
    NSString *DocDirectory;
    NSTimer *timer;
    NSTimer *scrollTimer;
    
    
    
    IBOutlet UILabel *lbl1,*lbl2,*lbl3,*lbl4;
    IBOutlet UIImageView *img1,*img2;
    int comingLbl;
    
    IBOutlet UIImageView *countdown;
    
    int countDown;
    BOOL iscountDown;
    NSTimer *countDownTimer;

    BOOL check;
    
    IBOutlet UILabel *recordingTime;
    
    NSTimer *recordingTimer;
    int recordingtimeCounter;
    
    
}

@property (nonatomic)    BOOL isRecording,iscountDown;
@property(nonatomic,retain)NSString *name;


-(IBAction)ClickedCamFlip;
-(IBAction)ClickedFlash;
-(IBAction)ClickedRecordorStop;


-(void)ResetView;


//-(IBAction)ClickedStop;
//-(IBAction)ClickedBack;
//-(IBAction)ClickedDone;
-(IBAction)captureStillImage;

@property (nonatomic, retain) AVCaptureSession *captureSession;
@property (nonatomic, retain) AVCaptureDevice *bCaptureDevice;
//@property (nonatomic, retain) AVCaptureDevice *fCaptureDevice;
@property (nonatomic, retain) AVCaptureDevice *Device;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, retain) AVCaptureDeviceInput *bInput,*fInput;
@property (nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, retain) IBOutlet UIImageView *previewImage;
@property (nonatomic, retain) AVCaptureMovieFileOutput *movieFileOutput;



-(void)StopCountDown;
- (IBAction)CameraToggleButtonPressed;


@end
