//
//  SyncService.h
//  ScriptedMoviePlayer
//
//  Created by Greg Maletic on 9/9/15.
//  Copyright © 2015 C3Images. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SyncService : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate>

+ (instancetype)sharedService;
- (void)start;

@end
