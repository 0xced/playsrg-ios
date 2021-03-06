//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "GoogleCastMiniPlayerView.h"

#import "NSBundle+PlaySRG.h"

#import <SRGAppearance/SRGAppearance.h>

static void commonInit(GoogleCastMiniPlayerView *self);

@interface GoogleCastMiniPlayerView ()

@property (nonatomic) GCKUIMediaController *controller;

@property (nonatomic, weak) IBOutlet UIImageView *arrowImageView;
@property (nonatomic, weak) IBOutlet UIImageView *googleCastImageView;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@property (nonatomic, weak) IBOutlet GCKUIMultistateButton *playbackButton;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation GoogleCastMiniPlayerView

#pragma mark Class methods

+ (GoogleCastMiniPlayerView *)view
{
    return [NSBundle.mainBundle loadNibNamed:NSStringFromClass(self) owner:nil options:nil].firstObject;
}

#pragma mark Object lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        commonInit(self);
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        commonInit(self);
    }
    return self;
}

#pragma mark Overrides

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self updateFonts];
    
    self.progressView.progress = 0.f;
    self.progressView.progressTintColor = UIColor.redColor;
    
    self.backgroundColor = UIColor.clearColor;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openFullScreenPlayer:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    [self.playbackButton setImage:[UIImage imageNamed:@"pause-50"] forButtonState:GCKUIButtonStatePlay];
    [self.playbackButton setImage:[UIImage imageNamed:@"pause-50"] forButtonState:GCKUIButtonStatePlayLive];
    [self.playbackButton setImage:[UIImage imageNamed:@"play-50"] forButtonState:GCKUIButtonStatePause];
    
    self.controller.playPauseToggleButton = self.playbackButton;
    self.controller.streamProgressView = self.progressView;
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(contentSizeCategoryDidChange:)
                                               name:UIContentSizeCategoryDidChangeNotification
                                             object:nil];
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    
    if (newWindow) {
        [self reloadData];
    }
}

#pragma mark Data

- (void)reloadData
{
    // We don't bind properties to the controller (which would have been easier) since we want to display custom information
    // when those are empty.
    GCKSession *session = self.controller.session;
    GCKMediaMetadata *metadata = session.remoteMediaClient.mediaStatus.mediaInformation.metadata;
    if (metadata) {
        self.titleLabel.text = [metadata stringForKey:kGCKMetadataKeyTitle];
        self.playbackButton.hidden = NO;
    }
    else {
        NSString *deviceName = session.device.friendlyName;
        if (deviceName) {
            self.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ is idle.", @"Title displayed when no media is being played on the connected Google Cast receiver (placeholder is the device name)"), deviceName];
        }
        else {
            self.titleLabel.text = NSLocalizedString(@"Receiver is idle.", @"Title displayed when no media is being played on the connected Google Cast receiver (name unknown)");
        }
        self.playbackButton.hidden = YES;
    }
}

#pragma mark Fonts

- (void)updateFonts
{
    self.titleLabel.font = [UIFont srg_mediumFontWithTextStyle:SRGAppearanceFontTextStyleBody];
}

#pragma mark Accessibility

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (UIAccessibilityTraits)accessibilityTraits
{
    // Treat as header for quick navigation to the mini player
    return UIAccessibilityTraitHeader;
}

- (NSString *)accessibilityLabel
{
    return self.titleLabel.text;
}

- (NSString *)accessibilityHint
{
    return PlaySRGAccessibilityLocalizedString(@"Plays the content.", @"Mini player action hint");
}

#pragma mark GCKUIMediaControllerDelegate protocol

- (void)mediaController:(GCKUIMediaController *)mediaController didUpdatePlayerState:(GCKMediaPlayerState)playerState lastStreamPosition:(NSTimeInterval)streamPosition
{
    [self reloadData];
}

#pragma mark Gestures

- (void)openFullScreenPlayer:(UIGestureRecognizer *)gestureRecognizer
{
    [[GCKCastContext sharedInstance] presentDefaultExpandedMediaControls];
}

#pragma mark Notifications

- (void)contentSizeCategoryDidChange:(NSNotification *)notification
{
    [self updateFonts];
}

@end

static void commonInit(GoogleCastMiniPlayerView *self)
{
    self.controller = [[GCKUIMediaController alloc] init];
    self.controller.delegate = self;
}
