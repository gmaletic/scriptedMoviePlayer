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
@end

@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	self.avpvc = [[AVPlayerViewController alloc] init];
	self.avpvc.showsPlaybackControls = NO;
	
	self.avpvc.view.frame = self.view.bounds;
	[self.view addSubview:self.avpvc.view];
	
	Script* script = [[Script alloc] init];
	[script process];

	[[NSNotificationCenter defaultCenter] addObserverForName:NOTIFICATION_NEW_PLAYER object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification)
	{
		AVPlayer* player = notification.userInfo[USERINFO_KEY_PLAYER];
		NSAssert(player, @"No player");
		self.avpvc.player = player;
		[self.avpvc.player play];
	}];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
