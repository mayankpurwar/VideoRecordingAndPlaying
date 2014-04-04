//
//  RecordViewController.m
//  Salutations 365
//
//  Created on 24/11/13.
//

#import "RecordViewController.h"

#include <sys/types.h>
#include <sys/sysctl.h>

@interface RecordViewController ()

@end

@implementation RecordViewController

@synthesize captureSession, stillImageOutput, previewLayer;
@synthesize bCaptureDevice;//,fCaptureDevice;
@synthesize bInput,fInput;
@synthesize movieFileOutput;
@synthesize Device;

@synthesize name;

@synthesize isRecording;
@synthesize iscountDown;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Record";
    
    countdown.hidden = YES;
    countdown.center = self.previewImage.center;
    
    NSLog(@"%@  %@",[[UIDevice currentDevice] systemVersion],[[UIDevice currentDevice] systemName]);

    if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7.0)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        DocDirectory = [[NSString alloc] initWithString:[paths objectAtIndex:0]];
        isTorchON = NO;
        devicePos = 0;
    
    
        isBackCamera = NO;
        isFrontCamera = NO;
    
    
    
    lbl1.hidden = YES;
    lbl2.hidden = YES;
    lbl3.hidden = YES;
    lbl4.hidden = YES;
    
    img1.hidden = YES;
    img2.hidden = YES;
    
    
    
    
    
    

    
    if( [UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceRear] == NO)
    {
        isBackCamera = NO;
        
        if( [UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront]  == NO)
        {
            isFrontCamera = NO;
        }
        else
        {
            isFrontCamera = YES;
        }
        
    }
    else
    {
        isBackCamera = YES;
    }
    
    
    
    
    BtncamFlip.hidden = YES;
    
    if([UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceRear] == YES)
    {
        if([UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront] == YES)
            BtncamFlip.hidden = NO;
    }
    
    
    //
    //
//     [self setupSession];
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    captureSession = [[AVCaptureSession alloc] init];
    bCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (bCaptureDevice){
        NSError *error;
        bInput = [AVCaptureDeviceInput deviceInputWithDevice:bCaptureDevice error:&error];
        if (!error)
        {
            if ([captureSession canAddInput:bInput])
                [captureSession addInput:bInput];
            else
                NSLog(@"Couldn't add video input");
        }
        else
        {
            NSLog(@"Couldn't create video input");
        }
    }
    else
    {
        NSLog(@"Couldn't create video capture device");
    }
    
    //ADD AUDIO INPUT
    NSLog(@"Adding audio input");
    AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    NSError *error = nil;
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
    if (audioInput)
    {
        [captureSession addInput:audioInput];
    }
    
    //----- ADD OUTPUTS -----
    
    //ADD VIDEO PREVIEW LAYER
    NSLog(@"Adding video preview layer");
    [self setPreviewLayer:[[[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession] autorelease]];
    
    previewLayer.orientation = AVCaptureVideoOrientationPortrait;		//<<SET ORIENTATION.  You can deliberatly set this wrong to flip the image and may actually need to set it wrong to get the right image
    
    [[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //ADD MOVIE FILE OUTPUT
    NSLog(@"Adding movie file output");
    movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    

    
    if ([captureSession canAddOutput:movieFileOutput])
        [captureSession addOutput:movieFileOutput];
    
    //SET THE CONNECTION PROPERTIES (output properties)
    [self CameraSetOutputProperties];			//(We call a method as it also has to be done after changing camera)
    
    
    //----- SET THE IMAGE QUALITY / RESOLUTION -----
    //Options:
    //	AVCaptureSessionPresetHigh - Highest recording quality (varies per device)
    //	AVCaptureSessionPresetMedium - Suitable for WiFi sharing (actual values may change)
    //	AVCaptureSessionPresetLow - Suitable for 3G sharing (actual values may change)
    //	togg - 640x480 VGA (check its supported before setting it)
    //	AVCaptureSessionPreset1280x720 - 1280x720 720p HD (check its supported before setting it)
    //	AVCaptureSessionPresetPhoto - Full photo resolution (not supported for video output)
    NSLog(@"Setting image quality");
    /*[CaptureSession setSessionPreset:AVCaptureSessionPresetMedium];
     if ([CaptureSession canSetSessionPreset:AVCaptureSessionPreset640x480])		//Check size based configs are supported before setting them
     [CaptureSession setSessionPreset:AVCaptureSessionPreset640x480];*/
    [self setPreviewSessionPreset:AVCaptureSessionPreset640x480];
    
    //----- DISPLAY THE PREVIEW LAYER -----
    //Display it full screen under out view controller existing controls
    NSLog(@"Display the preview layer");
    CGRect layerRect = [[[self view] layer] bounds];
    [previewLayer setBounds:layerRect];
    [previewLayer setPosition:CGPointMake(CGRectGetMidX(layerRect),
                                          CGRectGetMidY(layerRect))];
    //[[[self view] layer] addSublayer:[[self CaptureManager] previewLayer]];
    //We use this instead so it goes on a layer behind our UI controls (avoids us having to manually bring each control to the front):
    
    UIView *CameraView = [[[UIView alloc] init] autorelease];
    [[self previewImage] addSubview:CameraView];
    [self.view sendSubviewToBack:CameraView];
    
    [[CameraView layer] addSublayer:previewLayer];
    
    /*UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
     doubleTapGesture.numberOfTapsRequired = 2;
     [self.view addGestureRecognizer:doubleTapGesture];
     doubleTapGesture.enabled = true;
     doubleTapGesture.delegate = self;
     [doubleTapGesture release];*/
    
    //----- START THE CAPTURE SESSION RUNNING -----
    [captureSession startRunning];
    
    
    
    
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    recordingTime.hidden = YES;
    [captureSession startRunning];
    [BtncamFlip setEnabled:YES];
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if(UIInterfaceOrientationPortrait == toInterfaceOrientation)
        return YES;
    
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




-(void) addNotifObservers
{
    //Adding AVCaptureSession Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationForSessionStart:) name:AVCaptureSessionDidStartRunningNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationForSessionError:) name:AVCaptureSessionRuntimeErrorNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationForSessionStop:) name:AVCaptureSessionDidStopRunningNotification object:nil];
    //NSLog(@"Adding Notification Observers");
}

-(void) notificationForSessionStart:(NSNotification*)notif
{
    sessionStartNotificationReceived = YES;
    //NSLog(@"notificationForSessionStart");
}



-(void) setupSession
{
    AVCaptureSession *_captureSession = [[AVCaptureSession alloc] init];
    self.captureSession = _captureSession;
    [_captureSession release];
    
    if(captureError == NO)
    {
        NSThread *thread = [[[NSThread alloc] initWithTarget:self selector:@selector(addNotifObservers) object:nil] autorelease];
        [thread start];
        while ([thread isExecuting]) {
            sleep(0.1);
        }
    }
    
    [self setSessionPreset];
    [self setupPreviewLayer];
    [self setupOutputs];
    [self toggleSession:YES];
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [self setupAutoFocus];
    //    });
    
    AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[self.stillImageOutput connections]];
    
    //    AVCaptureDevice *cDev = isBackCamera ? [self bCaptureDevice] : [self fCaptureDevice];
    AVCaptureDevice *cDev = [self Device];
    isTorchAvailable = [cDev hasFlash];
    NSLog(@"torch %d",isTorchAvailable);
    if ([videoConnection isVideoOrientationSupported])
        [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    captureError = NO;
    
    
    
    
    
}



-(void) setSessionPreset {
//    NSString *device = [self platform];
    if(IS_IPHONE_5)
        [self.captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    else
        [self.captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    
//    [self.captureSession setSessionPreset:AVCaptureSessionPresetMedium];
//    [self.captureSession setSessionPreset:AVCaptureSessionPresetHigh];
}


-(void) setupPreviewLayer
{
    //    if(self.captureSession)
    {
        // Setup Preview Layer
        AVCaptureVideoPreviewLayer *cvpl = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
        //UIView *aView = previewImage;
        
        cvpl.videoGravity = AVLayerVideoGravityResizeAspectFill;
        cvpl.frame = self.previewImage.bounds; // Assume you want the preview layer to fill the view.
        //NSLog(@"its frame: %@",NSStringFromCGRect(self.previewImage.frame));
        self.previewLayer = cvpl;
        [self.previewImage.layer addSublayer:self.previewLayer];
//        previewLayer.orientation = AVCaptureVideoOrientationPortrait;
        
        AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationPortrait;
        [previewLayer setOrientation:orientation];
    
    
        [captureSession startRunning];
    }
}


-(void) setupOutputs
{
    
    
    //    self.movieFileOutput = [[[AVCaptureMovieFileOutput alloc] init] autorelease];
    //    self.movieFileOutput.movieFragmentInterval = CMTimeMakeWithSeconds(1.0, 600.);
    //
    //    AVCaptureStillImageOutput *SIO = [[AVCaptureStillImageOutput alloc] init];
    //	NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
    //                                    AVVideoCodecJPEG, AVVideoCodecKey,
    //                                    nil];
    //    [SIO setOutputSettings:outputSettings];
    //    [outputSettings release];
    //
    //    self.stillImageOutput = SIO;
    //    [SIO release];
    
    
    
    
    
    
    self.movieFileOutput = [[[AVCaptureMovieFileOutput alloc] init] autorelease];
    self.movieFileOutput.movieFragmentInterval = CMTimeMakeWithSeconds(1.0, 600.);
    
    
    
    
    Float64 TotalSeconds = 25;
    int32_t preferredTimeScale = 30;
    CMTime maxDuration = CMTimeMakeWithSeconds(TotalSeconds, preferredTimeScale);
    self.movieFileOutput.maxRecordedDuration = maxDuration;
    
    
    
    // Setup STILL
    AVCaptureStillImageOutput *sOutput = [[[AVCaptureStillImageOutput alloc] init] autorelease] ;
    self.stillImageOutput = sOutput;
    NSMutableDictionary *outputSettings = [NSMutableDictionary dictionaryWithObjectsAndKeys:                                 AVVideoCodecJPEG, AVVideoCodecKey, nil];
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) outputSettings[AVVideoQualityKey] = @0.2;
    
    [sOutput setOutputSettings:outputSettings];
    

    
    
    
    
}


-(void) toggleSession:(BOOL)flag
{
    if (flag)
    {
        [self.captureSession beginConfiguration];
        if (isBackCamera)
        {
            [self setupBackCam];
            if ([self.captureSession canAddInput:self.bInput])
            {
                [self.captureSession addInput:self.bInput];
            }
        }
        else
        {
            [self setupFrontCam];
            if ([self.captureSession canAddInput:self.fInput])
            {
                [self.captureSession addInput:self.fInput];
            }
        }
        
        if ([self.captureSession canAddOutput:self.stillImageOutput]) {
            [self.captureSession addOutput:self.stillImageOutput];
        }
        
        if ([self.captureSession canAddOutput:self.movieFileOutput]) {
            [self.captureSession addOutput:self.movieFileOutput];
        }
        
        
        AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        AVCaptureDeviceInput * audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
        [self.captureSession addInput:audioInput];
        
        [self.captureSession commitConfiguration];
        //        [self synchronizeSessionStart];
    }
    else {
        [self.captureSession beginConfiguration];
        NSArray *inputs = [self.captureSession inputs];
        [inputs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self.captureSession removeInput:(AVCaptureInput*)obj];
        }];
        NSArray *outputs = [self.captureSession outputs];
        [outputs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self.captureSession removeOutput:(AVCaptureOutput*)obj];
        }];
        [self.captureSession commitConfiguration];
        [self.captureSession stopRunning];
    }
    
    

    
    
    if (!isTorchAvailable){
        [BtnFlash setEnabled:NO];
        [BtnFlash setHidden:YES];
    }
    
    
}

//
//-(void)setupAutoFocus
//{
//    AVCaptureDevice* pDev = (isBackCamera ? [self bCaptureDevice] : [self fCaptureDevice]);
//    if ([pDev isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
//        NSLog(@"AutoFocus is supported");
//        [pDev lockForConfiguration:nil];
//        [pDev setFocusMode:AVCaptureFocusModeAutoFocus];
//        [pDev unlockForConfiguration];
//    }
//    else
//    {
//        NSLog(@"AutoFocus is not supported");
//    }
//}

-(AVCaptureConnection *) connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections{
    for ( AVCaptureConnection *connection in connections ) {
        for ( AVCaptureInputPort *port in [connection inputPorts] ) {
            if ( [[port mediaType] isEqual:mediaType] ) {
                if([[[UIDevice currentDevice] systemVersion] integerValue] >= 5)
                {
                    if(connection.isVideoMinFrameDurationSupported)
                        connection.videoMinFrameDuration = CMTimeMake(1, 30);
                    if(connection.isVideoMaxFrameDurationSupported)
                        connection.videoMaxFrameDuration = CMTimeMake(1, 30);
                }
                return [connection retain] ;
            }
        }
    }
    return nil;
}

- (NSString *) platform
{
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
	free(machine);
	return platform;
}

- (AVCaptureDevice*) getCameraWithPosition:(AVCaptureDevicePosition)pos
{
    // get all video devices available
    NSArray *pDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for(AVCaptureDevice *pDev in pDevices)
    {
        // return front facing device
        if(pDev.position == pos)
            return pDev;
    }
    return nil;
}

-(void) setupFrontCam
{
    NSError *error;
    self.Device = [self getCameraWithPosition:AVCaptureDevicePositionFront];
    
    self.fInput = [AVCaptureDeviceInput deviceInputWithDevice:[self Device] error:&error];
    
    isTorchAvailable = [self.Device hasTorch];
    isBackworking = NO;
}
-(void) setupBackCam {
    self.Device = [self getCameraWithPosition:AVCaptureDevicePositionBack];
    
    NSError *error;
    self.bInput = [AVCaptureDeviceInput deviceInputWithDevice:[self Device] error:&error];
    
    isTorchAvailable = [self.Device hasTorch];
    isBackworking = YES;
}


-(IBAction)captureStillImage
{
    AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[self.stillImageOutput connections]];
    
    NSLog(@"%@",videoConnection);
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
     {
         if(imageDataSampleBuffer != NULL)
         {
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
             
             UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:imageData], nil, nil, nil);
             
         }
         else
         {
             [self handleCaptureError:error];
         }
     }];
    
}



-(void) handleCaptureError:(NSError*)_error
{
    //    //NSLog(@"Trying to handle error");
    captureError = YES;
    //not closing the already open folder because this Session is stopped because of capture error
    //    [self Stop:nil];
    //    [self setupSession];
    //    [self startCapturingPhotos];
}


-(NSURL *) tempFileURL {
    
    NSString *outputPath = [DocDirectory stringByAppendingPathComponent:@"1.mp4"];
    
    NSLog(@"%@ ",outputPath);
    if([[NSFileManager defaultManager] fileExistsAtPath:outputPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil];
    }
    
    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
    
    return [outputURL autorelease];
}

-(void)setHappyScroll
{
    img1.hidden = NO;
    img2.hidden = NO;
    lbl1.hidden = NO;
    lbl2.hidden = NO;
    lbl3.hidden = NO;
    lbl4.hidden = NO;
    
    int space = 50;
    int margin = 0;
    if(IOS7)
    {
        margin = 10;
    }
    
    NSString *text1 = @"Happy     Birthday     To     You,";
    NSString *text2 = @"Happy     Birthday     To     You,";
    NSString *text3 = [NSString stringWithFormat:@"Happy     Birthday     Dear     %@,",self.name];
    NSString *text4 = @"Happy     Birthday     To     You";
    
    CGSize constrainedSize = CGSizeMake(400, 9999);
    CGSize textSize1 = [text1 sizeWithFont:[UIFont systemFontOfSize:17.0] constrainedToSize:constrainedSize lineBreakMode:NSLineBreakByWordWrapping];
    CGSize textSize2 = [text2 sizeWithFont:[UIFont systemFontOfSize:17.0] constrainedToSize:constrainedSize lineBreakMode:NSLineBreakByWordWrapping];
    CGSize textSize3 = [text3 sizeWithFont:[UIFont systemFontOfSize:17.0] constrainedToSize:constrainedSize lineBreakMode:NSLineBreakByWordWrapping];
    CGSize textSize4 = [text4 sizeWithFont:[UIFont systemFontOfSize:17.0] constrainedToSize:constrainedSize lineBreakMode:NSLineBreakByWordWrapping];
    NSLog(@"%f",textSize3.width);
    
    [lbl1 setText:text1];
    [lbl2 setText:text2];
    [lbl3 setText:text3];
    [lbl4 setText:text4];
    
    CGRect lblframe = CGRectMake(50, lbl1.frame.origin.y, textSize1.width+margin, 21);
    lbl1.frame = lblframe;
    
    lblframe = CGRectMake(lblframe.origin.x+lblframe.size.width+space, lblframe.origin.y, textSize2.width+margin, 21);
    lbl2.frame = lblframe;
    NSLog(@"%f",lbl3.frame.size.width);
    lblframe = CGRectMake(lblframe.origin.x+lblframe.size.width+space, lblframe.origin.y, textSize3.width+margin, 21);
    lbl3.frame = lblframe;
        NSLog(@"%f",lbl3.frame.size.width);
    lblframe = CGRectMake(lblframe.origin.x+lblframe.size.width+space, lblframe.origin.y, textSize4.width+margin, 21);
    lbl4.frame = lblframe;
    
    NSLog(@"%f,%f,%@ %@",lbl1.frame.size.width,lbl3.frame.size.width,lbl3.text,text2);
    
    
    
    
    if(IOS7)
    {
        CGRect frame = lbl1.frame;
        float y = frame.origin.y;
        frame.origin.y = y+20;
        lbl1.frame = frame;
        
        frame = lbl2.frame;
        y = frame.origin.y;
        frame.origin.y = y+20;
        lbl2.frame = frame;
        
        frame = lbl3.frame;
        y = frame.origin.y;
        frame.origin.y = y+20.0;
        lbl3.frame = frame;
        
        frame = lbl4.frame;
        y = frame.origin.y;
        frame.origin.y = y+20.0;
        lbl4.frame = frame;
        
        frame = img1.frame;
        y = frame.origin.y;
        frame.origin.y = y+20;
        img1.frame = frame;
        
        frame = img2.frame;
        y = frame.origin.y;
        frame.origin.y = y+20;
        img2.frame = frame;
    }
    comingLbl = 1;
    
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.navigationController.navigationBarHidden = YES;
    
    
    int changewith = 44;
    if (IOS7)
    {
        changewith = 64;
    }
    else
    {
        changewith = 44;
    }
    
    
    CGRect frame = self.previewImage.frame;
    frame.origin.y = frame.origin.y+changewith;
    self.previewImage.frame = frame;
    
    frame = BtnRecordorStop.frame;
    frame.origin.y = frame.origin.y+changewith;
    BtnRecordorStop.frame = frame;
    
    frame = BtncamFlip.frame;
    frame.origin.y = frame.origin.y+changewith;
    BtncamFlip.frame = frame;
    
    frame = BtnFlash.frame;
    frame.origin.y = frame.origin.y+changewith;
    BtnFlash.frame = frame;
    
    frame = recordingTime.frame;
    frame.origin.y = frame.origin.y+changewith;
    recordingTime.frame = frame;
    
    
    scrollTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(scheduleScroll) userInfo:Nil repeats:NO];
    
    

}

-(void)scheduleScroll
{
//    scrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.013 target:self selector:@selector(scrollLabels) userInfo:Nil repeats:YES];
    scrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.016 target:self selector:@selector(scrollLabels) userInfo:Nil repeats:YES];
}

-(void)scrollLabels
{
    CGRect frame = lbl1.frame;
    float x = frame.origin.x;
    frame.origin.x = x-1.0;
    lbl1.frame = frame;
    
    frame = lbl2.frame;
    x = frame.origin.x;
    frame.origin.x = x-1.0;
    lbl2.frame = frame;
    
    frame = lbl3.frame;
    x = frame.origin.x;
    frame.origin.x = x-1.0;
    lbl3.frame = frame;
    
    frame = lbl4.frame;
    x = frame.origin.x;
    frame.origin.x = x-1.0;
    lbl4.frame = frame;
    
//    if(lbl1.frame.origin.x<-22)
//        [lbl1 setTextColor:[UIColor redColor]];
//    
//    if(lbl2.frame.origin.x<-22)
//        [lbl2 setTextColor:[UIColor redColor]];
//    
//    if(lbl3.frame.origin.x<-22)
//        [lbl3 setTextColor:[UIColor redColor]];
//    
//    if(lbl4.frame.origin.x<-22)
//        [lbl4 setTextColor:[UIColor redColor]];
    
    
    
    
    
    
    
    
    if(lbl1.frame.origin.x+lbl1.frame.size.width<160)
        [lbl1 setTextColor:[UIColor redColor]];
    
    if(lbl2.frame.origin.x+lbl2.frame.size.width<160)
        [lbl2 setTextColor:[UIColor redColor]];
    
    if(lbl3.frame.origin.x+lbl3.frame.size.width<160)
        [lbl3 setTextColor:[UIColor redColor]];
    
    if(lbl4.frame.origin.x+lbl4.frame.size.width<160)
        [lbl4 setTextColor:[UIColor redColor]];
    
    
    
    
//    if(lbl1.frame.origin.x<-182)
//    {
//        frame = lbl3.frame;
//        float x = frame.origin.x;
//        frame.origin.x = x+frame.size.width;
//        lbl1.frame = frame;
//        [lbl1 setTextColor:[UIColor whiteColor]];
//        
//        NSString *str = @"Happy     Birthday     To     You,";
//        if(check)
//        {
//            [lbl3 setText:str];
//        }
//        
//    }
//    
//    if(lbl2.frame.origin.x<-182)
//    {
//        frame = lbl1.frame;
//        float x = frame.origin.x;
//        frame.origin.x = x+frame.size.width;
//        lbl2.frame = frame;
//        [lbl2 setTextColor:[UIColor whiteColor]];
//    }
//    
//    if(lbl3.frame.origin.x<-182)
//    {
//        frame = lbl2.frame;
//        float x = frame.origin.x;
//        frame.origin.x = x+frame.size.width;
//        lbl3.frame = frame;
//        [lbl3 setTextColor:[UIColor whiteColor]];
//        check = TRUE;
//    }
}

-(void)resetHappyScroll
{
    
    [lbl1 setText:@"Happy     Birthday     To     You,"];
    [lbl2 setText:@"Happy     Birthday     To     You,"];
    [lbl3 setText:@"Happy     Birthday     To     You,"];
    
    if(scrollTimer)
    {
        [scrollTimer invalidate];
        scrollTimer = Nil;
    }
    
    if(IOS7)
    {
        CGRect frame = lbl1.frame;
        float y = frame.origin.y;
        frame.origin.y = y-20;
        lbl1.frame = frame;
        
        frame = lbl2.frame;
        y = frame.origin.y;
        frame.origin.y = y-20;
        lbl2.frame = frame;
        
        frame = lbl3.frame;
        y = frame.origin.y;
        frame.origin.y = y-20.0;
        lbl3.frame = frame;
        
        frame = lbl4.frame;
        y = frame.origin.y;
        frame.origin.y = y-20.0;
        lbl4.frame = frame;
        
        frame = img1.frame;
        y = frame.origin.y;
        frame.origin.y = y-20;
        img1.frame = frame;
        
        frame = img2.frame;
        y = frame.origin.y;
        frame.origin.y = y-20;
        img2.frame = frame;
    }
    
    img1.hidden = YES;
    img2.hidden = YES;
    
    lbl1.hidden = YES;
    lbl2.hidden = YES;
    lbl3.hidden = YES;
    lbl4.hidden = YES;
    
    
    CGRect frame = lbl1.frame;
    frame.origin.x = 320.0;;
    lbl1.frame = frame;
    
    frame = lbl2.frame;
    frame.origin.x = 640.0;;
    lbl2.frame = frame;
    
    frame = lbl3.frame;
    frame.origin.x = 960.0;;
    lbl3.frame = frame;
    
    [lbl1 setTextColor:[UIColor whiteColor]];
    [lbl2 setTextColor:[UIColor whiteColor]];
    [lbl3 setTextColor:[UIColor whiteColor]];
    [lbl4 setTextColor:[UIColor whiteColor]];
    
}

-(void)timerended
{
    countDown--;
    
    if(countDown==0)
    {
        iscountDown = FALSE;
        isRecording = TRUE;
        countdown.hidden = YES;
        
        [self startRecording];
    }
    else
    {
        [countdown setImage:[UIImage imageNamed:[NSString stringWithFormat:@"counter%d.png",countDown]]];
        countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerended) userInfo:Nil repeats:NO];
    }
}


-(void)startRecording
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.5 * 1000000000ull);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       check = FALSE;
                       
                       [BtnRecordorStop setImage:[UIImage imageNamed:@"Stop.png"] forState:UIControlStateNormal];
                       
                       int time = 26;
//                       if([[USER_DEFAULTS valueForKey:@"SalType"] isEqualToString:@"Birthday"])
                       {
                           time = 26;
                           
                           [self setHappyScroll];
                       }
//                       else
//                       {
//                           time = 61;
//                           recordingtimeCounter = 0;
//                           recordingTime.hidden = NO;
//                           recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(UpdateLabel) userInfo:Nil repeats:YES];
//                           
////                           [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(UpdateLabel) userInfo:nil repeats:NO];
//                       }
                       
                       //                           int time = [[USER_DEFAULTS valueForKey:@"RecordingTime"] intValue]+1;
                       [BtnRecordorStop setEnabled:YES];
                       NSLog(@"%d",time);
                       timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(TimerEnded) userInfo:Nil repeats:NO];
                       
                       [self performSelectorOnMainThread:@selector(setupWriter:) withObject:[self tempFileURL] waitUntilDone:NO];
                   });
}

-(void)UpdateLabel
{
    recordingtimeCounter=recordingtimeCounter+1;
    NSLog(@"%d",recordingtimeCounter);
    recordingTime.text=[NSString stringWithFormat:@"%02d:%02d",recordingtimeCounter/60,recordingtimeCounter%60];
//    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(UpdateLabel) userInfo:nil repeats:NO];
}


-(IBAction)ClickedRecordorStop
{
    
    if (![movieFileOutput isRecording])
    {
        [BtnRecordorStop setEnabled:NO];
        [BtncamFlip setEnabled:NO];

        
//        if([[USER_DEFAULTS valueForKey:@"SalType"] isEqualToString:@"Birthday"])
        {
            iscountDown = TRUE;
            countdown.hidden = NO;
            countDown = 3;
            [countdown setImage:[UIImage imageNamed:@"counter3.png"]];
            [self CameraSetOutputProperties];
            countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerended) userInfo:Nil repeats:NO];
        }
//        else
//        {
//            [self CameraSetOutputProperties];
//            [self startRecording];
//        }
        
        
        
//        self.navigationController.navigationBarHidden = YES;
//        isRecording = TRUE;
//        
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.5 * 1000000000ull);
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
//                       {
//                           [self setHappyScroll];
//                           [BtnRecordorStop setImage:[UIImage imageNamed:@"Stop.png"] forState:UIControlStateNormal];
//                           
//                           int time = [[USER_DEFAULTS valueForKey:@"RecordingTime"] intValue]+1;
//                           NSLog(@"%d",time);
//                        timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(TimerEnded) userInfo:Nil repeats:NO];
//                           
//                           [self performSelectorOnMainThread:@selector(setupWriter:) withObject:[self tempFileURL] waitUntilDone:NO];
//                           
//                           
//                           
//                       });
    }
    else
    {
        
        [BtnRecordorStop setEnabled:NO];
        [self ResetView];
        [self ShowPreviewview];
        [BtnRecordorStop setEnabled:YES];
    }
}


-(void)ResetView
{
    [BtncamFlip setEnabled:YES];
    isRecording = FALSE;
    recordingTime.hidden = YES;
    [recordingTime setText:@"00:00"];
//    if([[USER_DEFAULTS valueForKey:@"SalType"] isEqualToString:@"Birthday"])
    {
        [self resetHappyScroll];
        
        int changewith = 44;
        if (IOS7)
        {
            changewith = 64;
        }
        else
        {
            changewith = 44;
        }
        self.navigationController.navigationBarHidden = NO;
        
        CGRect frame = self.previewImage.frame;
        frame.origin.y = frame.origin.y-changewith;
        self.previewImage.frame = frame;
        
        frame = BtnRecordorStop.frame;
        frame.origin.y = frame.origin.y-changewith;
        BtnRecordorStop.frame = frame;
        
        frame = BtncamFlip.frame;
        frame.origin.y = frame.origin.y-changewith;
        BtncamFlip.frame = frame;
        
        frame = BtnFlash.frame;
        frame.origin.y = frame.origin.y-changewith;
        BtnFlash.frame = frame;
        
        frame = recordingTime.frame;
        frame.origin.y = frame.origin.y-changewith;
        recordingTime.frame = frame;
    }
    
    if(timer)
    {
        [timer invalidate];
        timer = Nil;
    }
    if(recordingTimer)
    {
        [recordingTimer invalidate];
        recordingTimer = Nil;
    }
    if(isTorchON)
        [self ClickedFlash];
    [movieFileOutput stopRecording];
    [BtnRecordorStop setImage:[UIImage imageNamed:@"Start.png"] forState:UIControlStateNormal];
}

-(void)ShowPreviewview
{
//    [captureSession stopRunning];
    PreviewViewController *myView;
    if(IS_IPHONE_5){
        myView=[[PreviewViewController alloc]initWithNibName:@"PreviewViewController" bundle:nil];
    }
    else{
        myView=[[PreviewViewController alloc]initWithNibName:@"PreviewViewController_iPhone4" bundle:nil];
    }
    APP_DELEGATE.preview = myView;
    APP_DELEGATE.preview.title = @"Preview";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Retake"
                                                                   style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    [backButton release];
    
    [myView release];
    [self.navigationController pushViewController:APP_DELEGATE.preview animated:YES];
}

-(void)TimerEnded
{
    [self ClickedRecordorStop];
}

- (void) setupWriter:(NSURL*) path {
    
//    AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self movieFileOutput] connections]];
//    
//    if ([videoConnection isVideoOrientationSupported])
//    {
//        NSLog(@"Setting portrait right video orientation");
//        [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
//        if(isFrontCamera)
//        if ([videoConnection isVideoMirroringSupported])
//            [videoConnection setVideoMirrored:TRUE];
//    }
//    else
//    {
//        NSLog(@"Cannot set video orientation");
//    }
    [[self movieFileOutput] startRecordingToOutputFileURL:path recordingDelegate:self];
    
}


- (BOOL)shouldAutorotate
{
    return YES;
}


#pragma mark -
#pragma mark Capture Output
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    
    
}
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    
    if (error != nil && error.code != AVErrorSessionWasInterrupted) {
        NSLog(@"Error recording to output file: %@", [error description]);
    }
    else
    {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                       {
                           ALAssetsLibrary *library = [[[ALAssetsLibrary alloc] init] autorelease];
                           if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputFileURL])
                           {
                               [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL
                                                           completionBlock:^(NSURL *assetURL, NSError *err)
                                {
                                    if (err)
                                    {
                                        NSLog(@"Video save error: %@", err);
                                    }
                                    else
                                    {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            
                                        });
                                    }
                                }];
                           }
                           
                       });
    }
    
    
}



+ (void) removeAllInputsAndOutputs: (AVCaptureSession*) session
{
	[session beginConfiguration];
	
	for (AVCaptureInput* input in session.inputs) {
		[session removeInput:input];
	}
	
	for (AVCaptureOutput* output in session.outputs) {
		[session removeOutput:output];
	}
	
	[session commitConfiguration];
}




-(IBAction)ClickedCamFlip
{
    dispatch_async(dispatch_get_main_queue(), ^{
    BtnRecordorStop.enabled = NO;
    [captureSession stopRunning];
    BtncamFlip.hidden=YES;
    });
    if(Device.position == AVCaptureDevicePositionBack)
    {
        [captureSession beginConfiguration];
        [captureSession removeInput:bInput];
        [self setupFrontCam];
        if ([captureSession canAddInput:fInput]) {
            [captureSession addInput:fInput];
        }
        [captureSession commitConfiguration];
        devicePos = 1;
    }
    else
    {
        [captureSession beginConfiguration];
        [captureSession removeInput:fInput];
        [self setupBackCam];
        if ([captureSession canAddInput:bInput]) {
            [captureSession addInput:bInput];
        }
        [captureSession commitConfiguration];
        devicePos = 0;
    }
    if([Device hasTorch] && [Device isTorchModeSupported:AVCaptureTorchModeOn])
        BtnFlash.hidden = false;
    else BtnFlash.hidden = true;
    dispatch_async(dispatch_get_main_queue(), ^{
    BtncamFlip.hidden= NO;
    BtnRecordorStop.userInteractionEnabled = YES;
    [captureSession startRunning];
    });
    
}


-(IBAction)ClickedFlash
{
    if (isTorchON) {
        [Device lockForConfiguration:nil];
        [Device setTorchMode:AVCaptureTorchModeOff];
        [BtnFlash setImage:[UIImage imageNamed:@"Flash-off.png"] forState:UIControlStateNormal];
        [Device unlockForConfiguration];
        isTorchON = NO;
    }
    else {
        [Device lockForConfiguration:nil];
        [Device setTorchMode:AVCaptureTorchModeOn];
        [BtnFlash setImage:[UIImage imageNamed:@"Flash-on.png"] forState:UIControlStateNormal];
        [Device unlockForConfiguration];
        isTorchON = YES;
    }
}

-(void)StopCountDown
{
    [BtncamFlip setEnabled:YES];
    [BtnRecordorStop setEnabled:YES];
    [countDownTimer invalidate];
    countDownTimer = Nil;
    countdown.hidden = YES;
}










- (void) CameraSetOutputProperties{
    
    //SET THE CONNECTION PROPERTIES (output properties)
    AVCaptureConnection *CaptureConnection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    
    //Set landscape (if required)
    if ([CaptureConnection isVideoOrientationSupported])
    {
        //AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationLandscapeRight;		//<<<<<SET VIDEO ORIENTATION IF LANDSCAPE
        [CaptureConnection setVideoOrientation:[self getVideoOrientation]];
    }
    
    //Set frame rate (if requried)
    CMTimeShow(CaptureConnection.videoMinFrameDuration);
    CMTimeShow(CaptureConnection.videoMaxFrameDuration);
    
    if (CaptureConnection.supportsVideoMinFrameDuration)
        CaptureConnection.videoMinFrameDuration = CMTimeMake(1, 30);
    if (CaptureConnection.supportsVideoMaxFrameDuration)
        CaptureConnection.videoMaxFrameDuration = CMTimeMake(1, 30);
    
    CMTimeShow(CaptureConnection.videoMinFrameDuration);
    CMTimeShow(CaptureConnection.videoMaxFrameDuration);
}

-(AVCaptureVideoOrientation)getVideoOrientation{
    // set the videoOrientation based on the device orientation to
    // ensure the pic is right side up for all orientations
    AVCaptureVideoOrientation videoOrientation;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationLandscapeLeft:
            // Not clear why but the landscape orientations are reversed
            // if I use AVCaptureVideoOrientationLandscapeLeft here the pic ends up upside down
            videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            // Not clear why but the landscape orientations are reversed
            // if I use AVCaptureVideoOrientationLandscapeRight here the pic ends up upside down
            videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            videoOrientation = AVCaptureVideoOrientationPortrait;
            break;
    }
    
    return videoOrientation;
}

-(void)setPreviewSessionPreset:(NSString*)AVCaptureSessionPresetType{
    //isSettingsVisible=NO;
    NSLog(@"AVCaptureSessionPresetType:%@",AVCaptureSessionPresetType);
    //[CaptureSession setSessionPreset:AVCaptureSessionPresetMedium];
    if ([captureSession canSetSessionPreset:AVCaptureSessionPresetType])		//Check size based configs are supported before setting them
    {
        NSLog(@"Setting AVCaptureSessionPresetType");
        [captureSession stopRunning];
        [captureSession setSessionPreset:AVCaptureSessionPresetType];
        [captureSession startRunning];
    }
}


- (IBAction)CameraToggleButtonPressed
{
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1)		//Only do if device has multiple cameras
    {
        NSLog(@"Toggle camera");
        [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(toggleCameraSwitch) userInfo:nil repeats:NO];
    }
}

-(void)toggleCameraSwitch{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        BtnRecordorStop.enabled = NO;
        BtncamFlip.hidden=YES;
    });
    
    
    NSError *error;
    //AVCaptureDeviceInput *videoInput = [self videoInput];
    AVCaptureDeviceInput *NewVideoInput;
    AVCaptureDevicePosition position = [[bInput device] position];
    if (position == AVCaptureDevicePositionBack)
    {
        [self setPreviewSessionPreset:AVCaptureSessionPreset640x480];
        NewVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self CameraWithPosition:AVCaptureDevicePositionFront] error:&error];
    }
    else if (position == AVCaptureDevicePositionFront)
    {
        if([bCaptureDevice isTorchAvailable]){
            BtnFlash.enabled=YES;
        }else{
            BtnFlash.enabled=NO;
        }
        NewVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self CameraWithPosition:AVCaptureDevicePositionBack] error:&error];
    }else{
        if([bCaptureDevice isTorchAvailable]){
            BtnFlash.enabled=YES;
        }else{
            BtnFlash.enabled=NO;
        }
        NewVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self CameraWithPosition:AVCaptureDevicePositionBack] error:&error];
    }
    
    if (NewVideoInput != nil)
    {
        [captureSession beginConfiguration];		//We can now change the inputs and output configuration.  Use commitConfiguration to end
        [captureSession removeInput:bInput];
        if ([captureSession canAddInput:NewVideoInput])
        {
            [captureSession addInput:NewVideoInput];
            bInput = NewVideoInput;
        }
        else
        {
            [self.captureSession addInput:self.bInput];
        }
        
        //Set the connection properties again
        [self CameraSetOutputProperties];
        
        [captureSession commitConfiguration];
        [NewVideoInput release];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        BtnRecordorStop.enabled = YES;
        BtncamFlip.hidden=NO;
    });
}

- (AVCaptureDevice *) CameraWithPosition:(AVCaptureDevicePosition) Position
{
    NSArray *Devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *Device1 in Devices)
    {
        if ([Device1 position] == Position)
        {
            return Device1;
        }
    }
    return nil;
}
@end
