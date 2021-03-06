//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "WebViewController.h"

#import "UIColor+PlaySRG.h"
#import "UIImageView+PlaySRG.h"
#import "UIViewController+PlaySRG.h"

#import <FXReachability/FXReachability.h>
#import <libextobjc/libextobjc.h>
#import <Masonry/Masonry.h>

static void *s_kvoContext = &s_kvoContext;

@interface WebViewController ()

@property (nonatomic) NSURLRequest *request;

@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, weak) UIImageView *loadingImageView;
@property (nonatomic, weak) IBOutlet UILabel *errorLabel;

@property (nonatomic, copy) WebViewControllerCustomizationBlock customizationBlock;
@property (nonatomic, copy) WKNavigationActionPolicy (^decisionHandler)(NSURL *URL);
@property (nonatomic) AnalyticsPageType analyticsPageType;

@end

@implementation WebViewController

#pragma mark Object lifecycle

- (instancetype)initWithRequest:(NSURLRequest *)request customizationBlock:(WebViewControllerCustomizationBlock)customizationBlock decisionHandler:(WKNavigationActionPolicy (^)(NSURL *))decisionHandler analyticsPageType:(AnalyticsPageType)analyticsPageType
{
    if (self = [super init]) {
        self.request = request;
        self.customizationBlock = customizationBlock;
        self.decisionHandler = decisionHandler;
        self.tracked = YES;
        self.analyticsPageType = analyticsPageType;
    }
    return self;
}

- (void)dealloc
{
    // Avoid iOS 9 crash: https://stackoverflow.com/questions/35529080/wkwebview-crashes-on-deinit
    self.webView.scrollView.delegate = nil;
    
    self.webView = nil;             // Unregister KVO
}

#pragma mark Getters and setters

- (void)setWebView:(WKWebView *)webView
{
    [_webView removeObserver:self forKeyPath:@keypath(WKWebView.new, estimatedProgress) context:s_kvoContext];
    _webView = webView;
    [_webView addObserver:self forKeyPath:@keypath(WKWebView.new, estimatedProgress) options:NSKeyValueObservingOptionNew context:s_kvoContext];
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.play_blackColor;
    
    // WKWebView cannot be instantiated in storyboards, do it programmatically
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    webView.opaque = NO;
    webView.backgroundColor = UIColor.clearColor;
    webView.alpha = 0.0f;
    webView.navigationDelegate = self;
    webView.scrollView.delegate = self;
    [self.view insertSubview:webView atIndex:0];
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11, *)) {
            make.top.equalTo(self.view);
            make.bottom.equalTo(self.view);
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
        }
        else {
            make.edges.equalTo(self.view);
        }
    }];
    self.webView = webView;
    
    UIImageView *loadingImageView = [UIImageView play_loadingImageView90WithTintColor:UIColor.play_lightGrayColor];
    loadingImageView.hidden = YES;
    [self.view insertSubview:loadingImageView atIndex:0];
    [loadingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.errorLabel);
    }];
    self.loadingImageView = loadingImageView;
    
    if (self.customizationBlock) {
        self.customizationBlock(webView);
    }
    
    self.errorLabel.text = nil;
    
    self.progressView.progressTintColor = UIColor.play_redColor;
    
    [self.webView loadRequest:self.request];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(webViewController_reachabilityDidChange:)
                                               name:FXReachabilityStatusDidChangeNotification
                                             object:nil];
}

#pragma mark Rotation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [super supportedInterfaceOrientations] & UIViewController.play_supportedInterfaceOrientations;
}

#pragma mark Status bar

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark Overrides

- (AnalyticsPageType)pageType
{
    return self.analyticsPageType;
}

- (BOOL)srg_isTrackedAutomatically
{
    return self.tracked;
}

#pragma mark ContentInsets protocol

- (NSArray<UIScrollView *> *)play_contentScrollViews
{
    UIScrollView *scrollView = self.webView.scrollView;
    return scrollView ? @[scrollView] : nil;
}

- (UIEdgeInsets)play_paddingContentInsets
{
    // Must adjust depending on the web page viewport-fit setting, see https://modelessdesign.com/backdrop/283
    if (@available(iOS 11, *)) {
        UIScrollView *scrollView = self.webView.scrollView;
        if (scrollView.contentInsetAdjustmentBehavior == UIScrollViewContentInsetAdjustmentNever) {
            return UIEdgeInsetsMake(self.topLayoutGuide.length, 0.f, self.bottomLayoutGuide.length, 0.f);
        }
    }
    return UIEdgeInsetsZero;
}

#pragma mark UIScrollViewDelegate protocol

- (void)scrollViewDidChangeAdjustedContentInset:(UIScrollView *)scrollView
{
    [self play_setNeedsContentInsetsUpdate];
}

#pragma mark WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    self.loadingImageView.hidden = NO;
    self.errorLabel.text = nil;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.progressView.alpha = 1.f;
    }];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    self.loadingImageView.hidden = YES;
    self.errorLabel.text = nil;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.webView.alpha = 1.f;
        self.progressView.alpha = 0.f;
    }];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    self.loadingImageView.hidden = YES;
    NSError *updatedError = error;
    
    NSURL *failingURL = ([error.domain isEqualToString:NSURLErrorDomain]) ? error.userInfo[NSURLErrorFailingURLErrorKey] : nil;
    if (failingURL && ! [failingURL.scheme isEqualToString:@"http"] && ! [failingURL.scheme isEqualToString:@"https"] && ! [failingURL.scheme isEqualToString:@"file"]) {
        updatedError = nil;
    }

    if ([updatedError.domain isEqualToString:NSURLErrorDomain]) {
        self.errorLabel.text = HLSLocalizedDescriptionForCFNetworkError(updatedError.code);
        
        [UIView animateWithDuration:0.3 animations:^{
            self.progressView.alpha = 0.f;
            self.webView.alpha = 0.f;
        }];
    }
    else {
        self.errorLabel.text = nil;
        
        [webView goBack];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.progressView.alpha = 0.f;
        }];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if (self.decisionHandler) {
        decisionHandler(self.decisionHandler(navigationAction.request.URL));
    }
    else {
        NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:navigationAction.request.URL resolvingAgainstBaseURL:NO];
        if (! [URLComponents.scheme isEqualToString:@"http"] && ! [URLComponents.scheme isEqualToString:@"https"] && ! [URLComponents.scheme isEqualToString:@"file"]) {
            [UIApplication.sharedApplication openURL:URLComponents.URL];
            decisionHandler(WKNavigationActionPolicyCancel);
        }
        else {
            decisionHandler(WKNavigationActionPolicyAllow);
        }
    }
}

#pragma mark Notifications

- (void)webViewController_reachabilityDidChange:(NSNotification *)notification
{
    if ([FXReachability sharedInstance].reachable) {
        if (self.viewVisible) {
            [self.webView loadRequest:self.request];
        }
    }
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (context == s_kvoContext) {
        if ([keyPath isEqualToString:@keypath(WKWebView.new, estimatedProgress)]) {
            self.progressView.progress = self.webView.estimatedProgress;
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
