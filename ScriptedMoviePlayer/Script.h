//
//  ScriptProcessor.h
//  ScriptedMoviePlayer
//
//  Created by Greg Maletic on 9/1/15.
//  Copyright (c) 2015 C3Images. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define DEFAULT_SCRIPT_FILENAME @"script"

#define TAG_CYCLE @"secondsToCycle"
#define TAG_FOUNDATION_IMAGE @"foundationImage"
#define TAG_SCRIPT @"script"
#define TAG_OFFSET @"secondsOffset"
#define TAG_MOVIE @"movie"

#define NOTIFICATION_NEW_PLAYER @"newPlayer"
#define USERINFO_KEY_PLAYER @"player"

@interface Script : NSObject

@property UIImage* foundationImage;
@property (readonly) AVPlayer* avPlayer;

- (void)process;
- (void)processScriptFile:(NSString*)scriptFileName;

@end
