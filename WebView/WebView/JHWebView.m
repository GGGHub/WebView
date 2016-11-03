//
//  JHWebView.m
//  JHWebView
//
//  Created by LiSiYuan on 16/10/18.
//  Copyright © 2016年 re. All rights reserved.
//

#import "JHWebView.h"
#import <WebKit/WebKit.h>
#import "NJKWebViewProgress.h"
#define isCanWebKit NSClassFromString(@"WKWebView")

#pragma mark - JHWKWebView
@interface JHWKWebView : WKWebView<JHWebViewProtocol>

@end
#pragma mark - JHUIWebView

@interface JHUIWebView : UIWebView<JHWebViewProtocol>

@end

@interface JHWebViewJS : NSObject
+(NSString *)scalesPageToFitJS;
+(NSString *)imgsElement;
@end
@interface JHWebView () <WKNavigationDelegate,UIWebViewDelegate,NJKWebViewProgressDelegate>
@property (nonatomic,strong) id<JHWebViewProtocol>webView;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,assign) double estimatedProgress;
@property (nonatomic,assign) float pageHeight;
@property (nonatomic,copy) NJKWebViewProgress *webViewProgress;
@property (nonatomic,strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic,strong) JHWebViewConfiguration *configuration;
@property (nonatomic,copy) NSArray *images;

@end
@implementation JHWebView
+(JHWebView *)webViewWithFrame:(CGRect)frame configuration:(JHWebViewConfiguration *)configuration
{
    return [[self alloc] initWithFrame:frame configuration:configuration];
}
-(instancetype)initWithFrame:(CGRect)frame configuration:(JHWebViewConfiguration *)configuration;
{
    self = [super initWithFrame:frame];
    if (self) {
        _configuration = configuration;
        if (isCanWebKit) {
            if (configuration) {
                WKWebViewConfiguration *webViewconfiguration = [[WKWebViewConfiguration alloc] init];
                webViewconfiguration.allowsInlineMediaPlayback = configuration.allowsInlineMediaPlayback;
                webViewconfiguration.mediaPlaybackRequiresUserAction = configuration.mediaPlaybackRequiresUserAction;
                webViewconfiguration.mediaPlaybackAllowsAirPlay = configuration.mediaPlaybackAllowsAirPlay;
                webViewconfiguration.suppressesIncrementalRendering = configuration.suppressesIncrementalRendering;
                WKUserContentController *wkUController = [[WKUserContentController alloc] init];
                if (!configuration.scalesPageToFit) {
                    NSString *jScript = [JHWebViewJS scalesPageToFitJS];
                    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
                    [wkUController addUserScript:wkUScript];
                    WKUserScript *wkScript1 = [[WKUserScript alloc] initWithSource:[JHWebViewJS imgsElement] injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
                    [wkUController addUserScript:wkScript1];
                }
                if (configuration.captureImage) {
                    NSString *jScript = [JHWebViewJS imgsElement];
                    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
                    [wkUController addUserScript:wkUScript];
                    
                }
                webViewconfiguration.userContentController = wkUController;
                _webView = (id)[[JHWKWebView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) configuration:webViewconfiguration];
                
            }
            else{
                _webView = (id)[[JHWKWebView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
            }
            [(JHWKWebView *)_webView setNavigationDelegate:self];
            [(JHWKWebView *)_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
            [(JHWKWebView *)_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
            
        }
        else{
            _webView = (id)[[JHUIWebView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
            if (configuration) {
                [(JHUIWebView *)_webView setAllowsInlineMediaPlayback:configuration.allowsInlineMediaPlayback];
                [(JHUIWebView *)_webView setMediaPlaybackRequiresUserAction:configuration.mediaPlaybackRequiresUserAction];
                [(JHUIWebView *)_webView setMediaPlaybackAllowsAirPlay:configuration.mediaPlaybackAllowsAirPlay];
                [(JHUIWebView *)_webView setSuppressesIncrementalRendering:configuration.suppressesIncrementalRendering];
                [(JHUIWebView *)_webView setScalesPageToFit:configuration.scalesPageToFit];
            }
            _webViewProgress = [[NJKWebViewProgress alloc] init];
            [(JHUIWebView *)_webView setDelegate:_webViewProgress];
            _webViewProgress.webViewProxyDelegate = self;
            _webViewProgress.progressDelegate = self;
            
        }
        if (configuration.loadingHUD) {
            [(UIView *)_webView addSubview:self.indicatorView];
        }
        [(UIView *)_webView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:(UIView *)_webView];
    }
    return self;
}
-(UIScrollView *)scrollView
{
    return _webView.scrollView;
}
- (void)loadRequest:(NSURLRequest *)request
{
    [_webView loadRequest:request];
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    [_webView loadHTMLString:string baseURL:baseURL];
}
- (void)reload
{
    [_webView reload];
}
- (void)stopLoading
{
    [_webView stopLoading];
}
- (void)goBack
{
    [_webView goBack];
}
- (void)goForward
{
    [_webView goForward];
}
-(BOOL)canGoBack
{
    return _webView.canGoBack;
}
-(BOOL)canGoForward
{
    return _webView.canGoForward;
}
-(BOOL)isLoading
{
    return _webView.isLoading;
}
- (void)jh_evaluateJavaScript:(NSString*)javaScriptString completionHandler:(void (^)(id, NSError*))completionHandler
{
    [_webView jh_evaluateJavaScript:javaScriptString completionHandler:completionHandler];
}
#pragma mark - NJKWebViewProgressDelegate
- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    self.estimatedProgress = progress;
}
#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"title"]) {
        self.title = change[NSKeyValueChangeNewKey];
    }
    else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.estimatedProgress = [change[NSKeyValueChangeNewKey] doubleValue];
    }
}
#pragma mark - WKWebViewNavigation Delegate
- (void)webView:(WKWebView*)webView decidePolicyForNavigationAction:(WKNavigationAction*)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    BOOL load = YES;
    if ([self.delegate respondsToSelector:@selector(jh_webView:shouldStartLoadWithRequest:navigationType:)]) {
        load = [self.delegate jh_webView:(JHWebView<JHWebViewProtocol>*)self shouldStartLoadWithRequest:navigationAction.request navigationType:[self navigationTypeConvert:navigationAction.navigationType]];
    }
    if (load) {
        decisionHandler(WKNavigationActionPolicyAllow);
    }else{
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    [_indicatorView startAnimating];
    if ([self.delegate respondsToSelector:@selector(jh_webViewDidStartLoad:)]) {
        [self.delegate jh_webViewDidStartLoad:(JHWebView<JHWebViewProtocol>*)self];
    }
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    [_indicatorView stopAnimating];
    if ([self.delegate respondsToSelector:@selector(jh_webViewDidFinishLoad:)]) {
        [self.delegate jh_webViewDidFinishLoad:(JHWebView<JHWebViewProtocol>*)self];
    }
    [self jh_evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id heitht, NSError *error) {
        if (!error) {
            self.pageHeight = [heitht floatValue];
        }
    }];
    if (_configuration.captureImage) {
        [self jh_evaluateJavaScript:@"imgsElement()" completionHandler:^(NSString * imgs, NSError *error) {
            if (!error && imgs.length) {
                _images = [imgs componentsSeparatedByString:@","];
            }
        }];
    }
    
}
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    [_indicatorView stopAnimating];
    if ([self.delegate respondsToSelector:@selector(jh_webViewDidFinishLoad:)]) {
        [self.delegate jh_webView:(JHWebView<JHWebViewProtocol>*)self didFailLoadWithError:error];
    }
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    [_indicatorView stopAnimating];
    if ([self.delegate respondsToSelector:@selector(jh_webView:didFailLoadWithError:)]) {
        [self.delegate jh_webView:(JHWebView<JHWebViewProtocol>*)self didFailLoadWithError:error];
    }
}
#pragma mark - UIWebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    BOOL isLoad = YES;
    if ([self.delegate respondsToSelector:@selector(jh_webView:shouldStartLoadWithRequest:navigationType:)]) {
        isLoad = [self.delegate jh_webView:(JHWebView<JHWebViewProtocol>*)self shouldStartLoadWithRequest:request navigationType:[self navigationTypeConvert:navigationType]];
    }
    return isLoad;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_indicatorView startAnimating];
    if ([self.delegate respondsToSelector:@selector(jh_webViewDidStartLoad:)]) {
        [self.delegate jh_webViewDidStartLoad:(JHWebView<JHWebViewProtocol>*)self];
    }
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_indicatorView stopAnimating];
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if ([self.delegate respondsToSelector:@selector(jh_webViewDidFinishLoad:)]) {
        [self.delegate jh_webViewDidFinishLoad:(JHWebView<JHWebViewProtocol> *)self];
    }
    [self jh_evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id heitht, NSError *error) {
        if (!error) {
            self.pageHeight = [heitht floatValue];
        }
    }];
    if (_configuration.captureImage) {
        [self jh_evaluateJavaScript:[JHWebViewJS imgsElement] completionHandler:nil];
        [self jh_evaluateJavaScript:@"imgsElement()" completionHandler:^(NSString * imgs, NSError *error) {
            if (!error && imgs.length) {
                _images = [imgs componentsSeparatedByString:@","];
            }
        }];
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_indicatorView stopAnimating];
    if ([self.delegate respondsToSelector:@selector(jh_webView:didFailLoadWithError:)]) {
        [self.delegate jh_webView:(JHWebView<JHWebViewProtocol>*)self didFailLoadWithError:error];
    }
}
#pragma mark - Init
-(UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.hidesWhenStopped = YES;
    }
    return _indicatorView;
}

#pragma mark -Privity
-(NSInteger)navigationTypeConvert:(NSInteger)type;
{
    NSInteger navigationType;
    if (isCanWebKit) {
        switch (type) {
            case WKNavigationTypeLinkActivated:
                navigationType = JHWebViewNavigationLinkClicked;
                break;
            case WKNavigationTypeFormSubmitted:
                navigationType = JHWebViewNavigationFormSubmitted;
                break;
            case WKNavigationTypeBackForward:
                navigationType = JHWebViewNavigationBackForward;
                break;
            case WKNavigationTypeReload:
                navigationType = JHWebViewNavigationReload;
                break;
            case WKNavigationTypeFormResubmitted:
                navigationType = JHWebViewNavigationResubmitted;
                break;
            case WKNavigationTypeOther:
                navigationType = JHWebViewNavigationOther;
                break;
            default:
                navigationType = JHWebViewNavigationOther;
                break;
        }
    }
    else{
        switch (type) {
            case UIWebViewNavigationTypeLinkClicked:
                navigationType = JHWebViewNavigationLinkClicked;
                break;
            case UIWebViewNavigationTypeFormSubmitted:
                navigationType = JHWebViewNavigationFormSubmitted;
                break;
            case UIWebViewNavigationTypeBackForward:
                navigationType = JHWebViewNavigationBackForward;
                break;
            case UIWebViewNavigationTypeReload:
                navigationType = JHWebViewNavigationReload;
                break;
            case UIWebViewNavigationTypeFormResubmitted:
                navigationType = JHWebViewNavigationResubmitted;
                break;
            case UIWebViewNavigationTypeOther:
                navigationType = JHWebViewNavigationOther;
                break;
                
            default:
                navigationType = JHWebViewNavigationOther;
                break;
        }
    }
    return navigationType;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    [(UIView *)_webView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _indicatorView.frame = CGRectMake(0, 0, 20, 20);
    _indicatorView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}
-(void)setNeedsLayout
{
    [super setNeedsLayout];
    [(UIView *)_webView setNeedsLayout];
}
-(void)dealloc
{
    if (isCanWebKit) {
        [(JHWebView *)_webView removeObserver:self forKeyPath:@"title"];
        [(JHWebView *)_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    }
}
@end


@implementation JHWKWebView

-(void)jh_evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler
{
    [self evaluateJavaScript:javaScriptString completionHandler:completionHandler];
}
@end

@implementation JHUIWebView
-(void)jh_evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler
{
    NSString* result = [self stringByEvaluatingJavaScriptFromString:javaScriptString];
    if (completionHandler) {
        completionHandler(result,nil);
    }
}
@end

@implementation JHWebViewConfiguration
- (instancetype)init
{
    self = [super init];
    if (self) {
        _allowsInlineMediaPlayback = NO;
        _mediaPlaybackRequiresUserAction = YES;
        _suppressesIncrementalRendering = NO;
    }
    return self;
}
@end

@implementation JHWebViewJS
+(NSString *)scalesPageToFitJS
{
    return @"var meta = document.createElement('meta'); \
    meta.name = 'viewport'; \
    meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'; \
    var head = document.getElementsByTagName('head')[0];\
    head.appendChild(meta);";
}
+(NSString *)imgsElement
{
    return @"function imgsElement(){\
    var imgs = document.getElementsByTagName(\"img\");\
    var imgScr = '';\
    for(var i=0;i<imgs.length;i++){\
    imgs[i].onclick=function(){\
    document.location='img'+this.src;\
    };\
    if(i == imgs.length-1){\
    imgScr = imgScr + imgs[i].src;\
    break;\
    }\
    imgScr = imgScr + imgs[i].src + ',';\
    };\
    return imgScr;\
    };";
}

@end



