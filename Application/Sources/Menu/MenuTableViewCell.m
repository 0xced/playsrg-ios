//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "MenuTableViewCell.h"

#import "DownloadSession.h"
#import "UIColor+PlaySRG.h"
#import "UIImageView+PlaySRG.h"

#import <SRGAppearance/SRGAppearance.h>

@interface MenuTableViewCell ()

@property (nonatomic, weak) IBOutlet UIView *verticalLineView;
@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation MenuTableViewCell

#pragma mark Getters and setters

- (void)setMenuItemInfo:(MenuItemInfo *)menuItemInfo
{
    _menuItemInfo = menuItemInfo;
    
    self.titleLabel.font = [UIFont srg_regularFontWithTextStyle:SRGAppearanceFontTextStyleHeadline];
    self.titleLabel.text = menuItemInfo.title;
    
    self.iconImageView.image = menuItemInfo.image;
    [self updateIconImageViewAnimation];
}

- (void)setCurrent:(BOOL)current
{
    _current = current;
    
    self.verticalLineView.hidden = !current;
    
    [self updateAppearanceHighlighted:current];
    [self updateIconImageViewAnimation];
}

#pragma mark Overrides

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = UIColor.blackColor;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.iconImageView play_stopAnimating];
}

- (void)willMoveToWindow:(UIWindow *)window
{
    [super willMoveToWindow:window];
    
    if (window) {
        [self updateIconImageViewAnimation];
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(downloadSessionStateDidChange:)
                                                   name:DownloadSessionStateDidChangeNotification
                                                 object:nil];
    }
    else {
        [NSNotificationCenter.defaultCenter removeObserver:self name:DownloadSessionStateDidChangeNotification object:nil];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (! self.current) {
        [self updateAppearanceHighlighted:highlighted];
        [self updateIconImageViewAnimation];
    }
}

#pragma mark User interface

- (void)updateAppearanceHighlighted:(BOOL)highlighted
{
    UIColor *color = highlighted ? UIColor.whiteColor : UIColor.play_grayColor;
    self.titleLabel.textColor = color;
    self.iconImageView.tintColor = color;
}

- (void)updateIconImageViewAnimation
{
    [self.iconImageView play_stopAnimating];
    
    if (self.menuItemInfo.menuItem == MenuItemDownloads) {
        switch (DownloadSession.sharedDownloadSession.state) {
            case DownloadSessionStateDownloading: {
                [self.iconImageView play_startAnimatingDownloading22WithTintColor:self.iconImageView.tintColor];
                break;
            }
                
            default: {
                break;
            }
        }
        self.iconImageView.image = self.menuItemInfo.image;
    }
}

#pragma mark Notifications

- (void)downloadSessionStateDidChange:(NSNotification *)notification
{
    [self updateIconImageViewAnimation];
}

@end
