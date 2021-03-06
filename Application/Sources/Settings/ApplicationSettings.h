//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "MenuItemInfo.h"

#import <SRGLetterbox/SRGLetterbox.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  User location options.
 */
typedef NS_ENUM(NSInteger, SettingUserLocation) {
    /**
     *  Default IP-based location.
     */
    SettingUserLocationDefault,
    /**
     *  Outside CH.
     */
    SettingUserLocationOutsideCH,
    /**
     *  Ignore location.
     */
    SettingUserLocationIgnored
};

OBJC_EXPORT NSString * const PlaySRGSettingAlternateRadioHomepageDesignEnabled;
OBJC_EXPORT NSString * const PlaySRGSettingHDOverCellularEnabled;
OBJC_EXPORT NSString * const PlaySRGSettingOriginalImagesOnlyEnabled;
OBJC_EXPORT NSString * const PlaySRGSettingPresenterModeEnabled;
OBJC_EXPORT NSString * const PlaySRGSettingStandaloneEnabled;
OBJC_EXPORT NSString * const PlaySRGSettingAutoplayEnabled;

OBJC_EXPORT NSString * const PlaySRGSettingLastLoggedInEmailAddress;
OBJC_EXPORT NSString * const PlaySRGSettingLastOpenHomepageUid;
OBJC_EXPORT NSString * const PlaySRGSettingLastPlayedRadioLiveURN;
OBJC_EXPORT NSString * const PlaySRGSettingServiceURL;
OBJC_EXPORT NSString * const PlaySRGSettingUserLocation;

OBJC_EXPORT BOOL ApplicationSettingAlternateRadioHomepageDesignEnabled(void);
OBJC_EXPORT BOOL ApplicationSettingOriginalImagesOnlyEnabled(void);
OBJC_EXPORT BOOL ApplicationSettingPresenterModeEnabled(void);

OBJC_EXPORT BOOL ApplicationSettingStandaloneEnabled(void);
OBJC_EXPORT SRGQuality ApplicationSettingPreferredQuality(void);
OBJC_EXPORT SRGLetterboxPlaybackSettings *ApplicationSettingPlaybackSettings(void);

OBJC_EXPORT NSURL *ApplicationSettingServiceURL(void);
OBJC_EXPORT NSDictionary<NSString *, NSString *> *ApplicationSettingGlobalParameters(void);
OBJC_EXPORT NSTimeInterval ApplicationSettingContinuousPlaybackTransitionDuration(void);

OBJC_EXPORT NSString * _Nullable ApplicationSettingSelectedLiveStreamURNForChannelUid(NSString * _Nullable channelUid);
OBJC_EXPORT void ApplicationSettingSetSelectedLiveStreamURNForChannelUid(NSString * channelUid, NSString * _Nullable mediaURN);

OBJC_EXPORT SRGMedia * _Nullable ApplicationSettingSelectedLivestreamMediaForChannelUid(NSString * _Nullable channelUid, NSArray<SRGMedia *> * _Nullable medias);

OBJC_EXPORT MenuItemInfo * ApplicationSettingLastOpenHomepageMenuItemInfo(void);
OBJC_EXPORT void ApplicationSettingSetLastOpenHomepageMenuItemInfo(MenuItemInfo * _Nullable menuItem);

NS_ASSUME_NONNULL_END
