//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSBundle+PlaySRG.h"

NSString *PlaySRGAccessibilityLocalizedString(NSString *key, __unused NSString *comment)
{
    return [NSBundle.mainBundle localizedStringForKey:key value:@"" table:@"Accessibility"];
}

NSString *PlaySRGOnboardingLocalizedString(NSString *key, __unused NSString *comment)
{
    return [NSBundle.mainBundle localizedStringForKey:key value:@"" table:@"Onboarding"];
}

NSString *PlaySRGSettingsLocalizedString(NSString *key, __unused NSString *comment)
{
    NSString *settingsBundlePath = [NSBundle.mainBundle pathForResource:@"Settings" ofType:@"bundle"];
    return [[NSBundle bundleWithPath:settingsBundlePath] localizedStringForKey:key value:@"" table:@"Settings"];
}

NSString *PlaySRGNonLocalizedString(NSString *string)
{
    return string;
}

@implementation NSBundle (PlaySRG)

- (BOOL)isTestFlightDistribution
{
#if !defined(DEBUG) && !defined(NIGHTLY) && !defined(BETA)
    return (self.appStoreReceiptURL.path && [self.appStoreReceiptURL.path rangeOfString:@"sandboxReceipt"].location != NSNotFound);
#else
    return NO;
#endif
}

@end
