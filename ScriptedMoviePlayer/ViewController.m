//
//  ViewController.m
//  ScriptedMoviePlayer
//
//  Created by Greg Maletic on 9/1/15.
//  Copyright (c) 2015 C3Images. All rights reserved.
//

#import "ViewController.h"
#import "Script.h"

@interface ViewController ()
@property AVPlayerViewController* avpvc;
@property Script* currentScript;
@property UIColor* desiredOverlayColor;
@property UIImageView* overlayImageView;
//@property UILabel* timeLabel;
@end

@implementation ViewController

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Black background.
	[self.view setBackgroundColor:[UIColor blackColor]];
	
	// Create the movie player view controller and add it to the screen.
	self.avpvc = [[AVPlayerViewController alloc] init];
	self.avpvc.showsPlaybackControls = NO;
	
	self.avpvc.view.frame = self.view.bounds;
	[self.view addSubview:self.avpvc.view];

	// Find out when there is a new player that has content to display.
	[[NSNotificationCenter defaultCenter] addObserverForName:NOTIFICATION_NEW_PLAYER object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification)
	{
		AVPlayer* player = notification.userInfo[USERINFO_KEY_PLAYER];
		NSAssert(player, @"No player");
		self.avpvc.player = player;
		[self.avpvc.player play];
//		self.timeLabel.text = [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]];
		NSLog(@"PLAY");
	}];
	
	// Allow user to restart the script if things seem out of sync.
	UILongPressGestureRecognizer* resyncScriptGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(recognizeRestartGesture:)];
	resyncScriptGestureRecognizer.numberOfTouchesRequired = 1;
	resyncScriptGestureRecognizer.minimumPressDuration = 3;
	[self.avpvc.view addGestureRecognizer:resyncScriptGestureRecognizer];
	
	// Get notified in case the brightness changes, so we can change it ourselves.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(affectScreenBrightness) name:UIScreenBrightnessDidChangeNotification object:nil];

//	// Add a time label to the screen.
//	self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 15)];
//	self.timeLabel.textColor = [UIColor whiteColor];
//	self.timeLabel.text = @"Time";
//	[self.view addSubview:self.timeLabel];

	// Kick everyting off.
	[self startScriptWithSynctime:[NSDate timeIntervalSinceReferenceDate]];
}

//- (void)recordTimeGestureRecognized:(UIGestureRecognizer*)gr
//{
//	if (gr.state == UIGestureRecognizerStateBegan)
//	{
//		self.syncTime = [NSDate date];
//	}
//}

- (void)recognizeRestartGesture:(UIGestureRecognizer*)gr
{
	if (gr.state == UIGestureRecognizerStateBegan)
	{
		// Flash to tell user that their gesture has been recognized.
		[self flashScreen];
	}
	else if (gr.state == UIGestureRecognizerStateEnded)
	{
		// Do the sync.
		[self startScriptWithSynctime:[NSDate timeIntervalSinceReferenceDate]];
	}
}

- (void)startScriptWithSynctime:(NSTimeInterval)synctime
{
	NSLog(@"RESYNCING…");
	
	[self.avpvc.player pause];
	self.avpvc.player = nil;
	
	[self.currentScript stopTimers];
	self.currentScript = nil;
	Script* script = [[Script alloc] initWithScriptFile:@"script" withSyncTime:synctime];
	[script process];
	
	// Take some actions based on the script.
	// Load brightness.
	[self affectScreenBrightnessUsingScript:script];

	// Do we need to enable the overlay?
	[self enableOverlayUsingScript:script];
	
	[self enableOffsetUsingScript:script];
	
	// Hold on to this.
	self.currentScript = script;
}

- (void)affectScreenBrightness
{
	[self affectScreenBrightnessUsingScript:self.currentScript];
}

- (void)affectScreenBrightnessUsingScript:(Script*)script
{
	NSNumber* brightnessNumber = script.deviceJson[TAG_BRIGHTNESS];
	if (brightnessNumber)
	{
		CGFloat brightness = [brightnessNumber floatValue];
		[[UIScreen mainScreen] setWantsSoftwareDimming:YES];
		[[UIScreen mainScreen] setBrightness:brightness];
	}
	else
	{
		[[UIScreen mainScreen] setWantsSoftwareDimming:NO];
	}
}

- (void)enableOverlayUsingScript:(Script*)script
{
	NSString* overlayImageName = script.deviceJson[TAG_OVERLAY_IMAGE];
	if (overlayImageName)
	{
		UIImage* overlayImage = [UIImage imageNamed:overlayImageName];
		[self.overlayImageView removeFromSuperview];
		self.overlayImageView = [[UIImageView alloc] initWithImage:overlayImage];
		[self.avpvc.contentOverlayView addSubview:self.overlayImageView];
	}
}

- (void)enableOffsetUsingScript:(Script*)script
{
	CGFloat offsetX = 0;
	NSNumber* offsetXNumber = script.deviceJson[TAG_OFFSET_X];
	if (offsetXNumber)
	{
		offsetX = [offsetXNumber floatValue];
	}
	
	CGFloat offsetY = 0;
	NSNumber* offsetYNumber = script.deviceJson[TAG_OFFSET_Y];
	if (offsetYNumber)
	{
		offsetY = [offsetYNumber floatValue];
	}
	
	CGAffineTransform translate = CGAffineTransformMakeTranslation(offsetX, offsetY);
	self.avpvc.view.transform = translate;
}

- (void)flashScreen
{
	self.avpvc.contentOverlayView.backgroundColor = [UIColor greenColor];
	[UIView animateWithDuration:1 animations:^
	 {
		 self.avpvc.contentOverlayView.backgroundColor = self.desiredOverlayColor;
	 }];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
