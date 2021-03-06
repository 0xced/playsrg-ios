//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UIColor+PlaySRG.h"

#import <SRGAppearance/SRGAppearance.h>

@implementation UIColor (PlaySRG)

+ (UIColor *)play_redColor
{
    return UIColor.srg_redColor;
}

+ (UIColor *)play_liveRedColor
{
    return [UIColor srg_colorFromHexadecimalString:@"#d50000"];
}

+ (UIColor *)play_progressRedColor
{
    return [UIColor srg_colorFromHexadecimalString:@"#d50000"];
}

+ (UIColor *)play_notificationRedColor
{
    return [UIColor srg_colorFromHexadecimalString:@"#ed3323"];
}

+ (UIColor *)play_blackColor
{
    return [UIColor srg_colorFromHexadecimalString:@"#161616"];
}

+ (UIColor *)play_lightGrayColor
{
    return UIColor.lightGrayColor;
}

+ (UIColor *)play_grayColor
{
    return [UIColor srg_colorFromHexadecimalString:@"#979797"];
}

+ (UIColor *)play_grayButtonBackgroundColor
{
    return [UIColor srg_colorFromHexadecimalString:@"#232323"];
}

+ (UIColor *)play_lightGrayButtonBackgroundColor
{
    return [UIColor srg_colorFromHexadecimalString:@"#242424"];
}

+ (UIColor *)play_grayThumbnailImageViewBackgroundColor
{
    return [UIColor srg_colorFromHexadecimalString:@"#232323"];
}

+ (UIColor *)play_blackDurationLabelBackgroundColor
{
    return [UIColor colorWithWhite:0.f alpha:0.75f];
}

@end
