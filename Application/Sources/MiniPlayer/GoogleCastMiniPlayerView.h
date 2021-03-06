//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <GoogleCast/GoogleCast.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GoogleCastMiniPlayerView : UIView <GCKUIMediaControllerDelegate>

@property (class, nonatomic, readonly) GoogleCastMiniPlayerView *view;

@end

NS_ASSUME_NONNULL_END
