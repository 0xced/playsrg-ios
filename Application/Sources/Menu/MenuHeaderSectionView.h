//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <UIKit/UIKit.h>

#import "MenuSectionInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface MenuHeaderSectionView : UITableViewHeaderFooterView

+ (CGFloat)heightForMenuSectionInfo:(MenuSectionInfo *)menuSectionInfo;

@property (nonatomic) MenuSectionInfo *menuSectionInfo;

@end

NS_ASSUME_NONNULL_END
