//
//  PreviewViewController.m
//  Salutations 365
//
//  Created on 25/11/13.
//

#import "PreviewViewController.h"

@interface PreviewViewController ()

@end

@implementation PreviewViewController

@synthesize isUploading;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(0, 0, 30, 24)];
        [btn setImage:[UIImage imageNamed:@"Upload.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(ClickedUpload) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
        self.navigationItem.rightBarButtonItem = rightBtn;
        [rightBtn release];
        
        
//        btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [btn setFrame:CGRectMake(0, 0, 18, 24)];
//        [btn setImage:[UIImage imageNamed:@"Upload.png"] forState:UIControlStateNormal];
//        [btn addTarget:self action:@selector(ClickedUpload) forControlEvents:UIControlEventTouchUpInside];
//        UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
//        self.navigationItem.rightBarButtonItem = rightBtn;
//        [rightBtn release];
        
    }
    return self;
}

- (void)viewDidLoad
{
    
//    if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7.0)
//    {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//    }
    
    
    [super viewDidLoad];
    
    isUploading = FALSE;
    movie = [[MPMoviePlayerViewController alloc] init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *DocDirectory = [paths objectAtIndex:0];
    
    NSString *outputPath = [DocDirectory stringByAppendingPathComponent:@"1.mp4"];
    movie.moviePlayer.contentURL = [NSURL fileURLWithPath:outputPath];
    movie.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    
//    movie.moviePlayer.shouldAutoplay = NO;
    
    movie.moviePlayer.controlStyle = MPMovieControlStyleNone;
    movie.moviePlayer.fullscreen = YES;
//    [movie.moviePlayer setScalingMode:MPMovieScalingModeFill];
    [self installMovieNotificationObservers];
    movie.view.frame = self.view.frame;
    NSLog(@"%@\n%@",[NSValue valueWithCGRect:movie.view.frame],[NSValue valueWithCGRect:self.view.frame]);
    [self.view addSubview:movie.view];
    NSLog(@"file time %f",movie.moviePlayer.playableDuration);
    [self.view addSubview:overlay.view];
    [self startTimer];
    
    
    
    
    NSURL *url = [NSURL fileURLWithPath:outputPath];
    AVAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    NSLog(@"file time %f",CMTimeGetSeconds(asset.duration));
    
    
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self stopTimer];
    [super viewDidDisappear:animated];
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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    movie = [[MPMoviePlayerViewController alloc] init];
//    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *DocDirectory = [paths objectAtIndex:0];
//    
//    NSString *outputPath = [DocDirectory stringByAppendingPathComponent:@"1.mp4"];
//    movie.moviePlayer.contentURL = [NSURL fileURLWithPath:outputPath];
//    
//    movie.moviePlayer.controlStyle = MPMovieControlStyleNone;
//    [self installMovieNotificationObservers];
//    movie.view.frame = self.view.frame;
//    [self.view addSubview:movie.view];
//    
//    [self.view addSubview:overlay.view];
//    [self startTimer];
}















-(void)installMovieNotificationObservers
{
//    MPMoviePlayerController *player = [self moviePlayerController];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:movie.moviePlayer];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:movie.moviePlayer];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:movie.moviePlayer];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:movie.moviePlayer];
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationHandlers
{
//    MPMoviePlayerController *player = [self moviePlayerController];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:movie.moviePlayer];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:movie.moviePlayer];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:movie.moviePlayer];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:movie.moviePlayer];
}

/* Delete the movie player object, and remove the movie notification observers. */
-(void)deletePlayerAndNotificationObservers
{
    [self removeMovieNotificationHandlers];
//    [self setMoviePlayerController:nil];
}



#pragma mark Movie Notification Handlers

/*  Notification called when the movie finished playing. */
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    
    [self stopTimer];
    
    NSNumber *reason = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
	switch ([reason integerValue])
	{
            /* The end of the movie was reached. */
		case MPMovieFinishReasonPlaybackEnded:
            /*
             Add your code here to handle MPMovieFinishReasonPlaybackEnded.
             */
            progress1.progress = 1.0;
            timeLbl1.text = [NSString stringWithFormat:@"%@", [self ChangetimeIntervaltoString: movie.moviePlayer.playableDuration]];
			break;
            
            /* An error was encountered during playback. */
		case MPMovieFinishReasonPlaybackError:
            NSLog(@"An error was encountered during playback");
//            [self performSelectorOnMainThread:@selector(displayError:) withObject:[[notification userInfo] objectForKey:@"error"]
//                                waitUntilDone:NO];
//            [self removeMovieViewFromViewHierarchy];
//            [self removeOverlayView];
//            [self.backgroundView removeFromSuperview];
			break;
            
            /* The user stopped playback. */
		case MPMovieFinishReasonUserExited:
//            [self removeMovieViewFromViewHierarchy];
//            [self removeOverlayView];
//            [self.backgroundView removeFromSuperview];
			break;
            
		default:
			break;
	}
}

/* Handle movie load state changes. */
- (void)loadStateDidChange:(NSNotification *)notification
{
	MPMoviePlayerController *player = notification.object;
	MPMovieLoadState loadState = player.loadState;
    
	/* The load state is not known at this time. */
	if (loadState & MPMovieLoadStateUnknown)
	{
//        [self.overlayController setLoadStateDisplayString:@"n/a"];
        
//        [overlayController setLoadStateDisplayString:@"unknown"];
	}
	
	/* The buffer has enough data that playback can begin, but it
	 may run out of data before playback finishes. */
	if (loadState & MPMovieLoadStatePlayable)
	{
//        [overlayController setLoadStateDisplayString:@"playable"];
	}
	
	/* Enough data has been buffered for playback to continue uninterrupted. */
	if (loadState & MPMovieLoadStatePlaythroughOK)
	{
        // Add an overlay view on top of the movie view
//        [self addOverlayView];
        NSLog(@"content play length is %g   %g seconds", player.duration,player.playableDuration);
//        [overlayController setLoadStateDisplayString:@"playthrough ok"];
	}
	
	/* The buffering of data has stalled. */
	if (loadState & MPMovieLoadStateStalled)
	{
//        [overlayController setLoadStateDisplayString:@"stalled"];
	}
}

/* Called when the movie playback state has changed. */
- (void) moviePlayBackStateDidChange:(NSNotification*)notification
{
	MPMoviePlayerController *player = notification.object;
    
	/* Playback is currently stopped. */
	if (player.playbackState == MPMoviePlaybackStateStopped)
	{
        [startStopBtn setImage:[UIImage imageNamed:@"preview-play.png"] forState:UIControlStateNormal];
        [self stopTimer];
//        [overlayController setPlaybackStateDisplayString:@"stopped"];
	}
	/*  Playback is currently under way. */
	else if (player.playbackState == MPMoviePlaybackStatePlaying)
	{
        [startStopBtn setImage:[UIImage imageNamed:@"preview-pause.png"] forState:UIControlStateNormal];
//        [overlayController setPlaybackStateDisplayString:@"playing"];
	}
	/* Playback is currently paused. */
	else if (player.playbackState == MPMoviePlaybackStatePaused)
	{
        [startStopBtn setImage:[UIImage imageNamed:@"preview-play.png"] forState:UIControlStateNormal];
//        [overlayController setPlaybackStateDisplayString:@"paused"];
        [self stopTimer];
	}
	/* Playback is temporarily interrupted, perhaps because the buffer
	 ran out of content. */
	else if (player.playbackState == MPMoviePlaybackStateInterrupted)
	{
        [startStopBtn setImage:[UIImage imageNamed:@"preview-play.png"] forState:UIControlStateNormal];
//        [overlayController setPlaybackStateDisplayString:@"interrupted"];
        [self stopTimer];
	}
}

/* Notifies observers of a change in the prepared-to-play state of an object
 conforming to the MPMediaPlayback protocol. */
- (void) mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
	// Add an overlay view on top of the movie view
//    [self addOverlayView];
}



-(void)startTimer
{
    if(![updateTimer isValid])
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updatePlay) userInfo:nil repeats:YES];
}

-(void)stopTimer
{
    [updateTimer invalidate];
    updateTimer = nil;
}



-(void)updatePlay
{
    
    NSLog(@"in UpdatePlay,%d",(int)movie.moviePlayer.currentPlaybackTime);
    
    if((int)movie.moviePlayer.currentPlaybackTime>=0)
    {
        if(movie.moviePlayer.currentPlaybackTime == movie.moviePlayer.duration)
        {
            [startStopBtn setImage:[UIImage imageNamed:@"preview-play.png"] forState:UIControlStateNormal];
        }
        else
        {
            progress1.progress = movie.moviePlayer.currentPlaybackTime/movie.moviePlayer.duration;
            timeLbl1.text = [NSString stringWithFormat:@"%@", [self ChangetimeIntervaltoString: movie.moviePlayer.currentPlaybackTime]];
            timeLbl2.text = [NSString stringWithFormat:@"%@", [self ChangetimeIntervaltoString: movie.moviePlayer.playableDuration]];
            NSLog(@"%f",movie.moviePlayer.playableDuration);
        }
    }
    
}

-(NSString *)ChangetimeIntervaltoString:(NSTimeInterval)time
{
    int mnts=0,hour=0;
    int timeinerval = (int)time;
    int sec = timeinerval%60;
    timeinerval = timeinerval/60;
    if(timeinerval>0)
    {
        mnts = timeinerval%60;
    }
    timeinerval = timeinerval/60;
    if(timeinerval>0)
    {
        hour = timeinerval%60;
    }
    NSString *time3 = @"";
    if(hour>0)
        time3  = [time3 stringByAppendingFormat:@"%d:%02d:%02d",hour,mnts,sec];
    
    else {
        
        time3  = [time3 stringByAppendingFormat:@"%02d:%02d",mnts,sec];
        
    }
    return time3;
}

-(IBAction)ClickStartStop
{
    //    UIButton *btn = (UIButton *)sender;
    
    
//    if(MPMoviePlaybackStateStopped!=movie.moviePlayer.playbackState)
    {
        if(movie.moviePlayer.playbackState==MPMoviePlaybackStatePlaying)
        {
            //            [playBtn setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
            
            [self stopTimer];
            [movie.moviePlayer pause];
        }
        
        else
        {
            [self startTimer];
            if([timeLbl1.text isEqualToString:timeLbl2.text])
                [timeLbl1 setText:@"00:00"];
            [movie.moviePlayer play];
            //            [playBtn setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        }
    }
    
}



@end
