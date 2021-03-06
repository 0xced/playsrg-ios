//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "MediasViewController.h"

#import <SRGDataProvider/SRGDataProvider.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShowViewController : MediasViewController <UIGestureRecognizerDelegate>

- (instancetype)initWithShow:(SRGShow *)show fromPushNotification:(BOOL)fromPushNotification NS_DESIGNATED_INITIALIZER;

@end

@interface ShowViewController (Unavailable)

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
