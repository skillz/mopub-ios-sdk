//
// Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MRVideoPlayerManagerSKZ.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MPInstanceProviderSKZ.h"
#import "UIViewController+MPAdditions.h"

@implementation MRVideoPlayerManagerSKZ

@synthesize delegate = _delegate;

- (id)initWithDelegate:(id<MRVideoPlayerManagerDelegateSKZ>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:nil];

    [super dealloc];
}

- (void)playVideo:(NSDictionary *)parameters
{
    NSString *URLString = [[parameters objectForKey:@"uri"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *URL = [NSURL URLWithString:URLString];

    if (!URL) {
        [self.delegate videoPlayerManager:self didFailToPlayVideoWithErrorMessage:@"URI was not valid."];
        return;
    }

    MPMoviePlayerViewController *controller = [[MPInstanceProviderSKZ sharedProvider] buildMPMoviePlayerViewControllerWithURL:URL];

    [self.delegate videoPlayerManagerWillPresentVideo:self];
    [[self.delegate viewControllerForPresentingVideoPlayer] mp_presentModalViewControllerSKZ:controller
                                                                                 animated:MP_ANIMATED];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerPlaybackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
}

- (void)moviePlayerPlaybackDidFinish:(NSNotification *)notification
{
    [self.delegate videoPlayerManagerDidDismissVideo:self];
}

@end
