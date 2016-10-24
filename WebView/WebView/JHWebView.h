//
//  JHWebView.h
//  JHWebView
//
//  Created by LiSiYuan on 16/10/18.
//  Copyright © 2016年 re. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,JHWebViewNavigationType) {
    JHWebViewNavigationLinkClicked,
    JHWebViewNavigationFormSubmitted,
    JHWebViewNavigationBackForward,
    JHWebViewNavigationReload,
    JHWebViewNavigationResubmitted,
    JHWebViewNavigationOther = -1
};
@class JHWebView;
@protocol JHWebViewProtocol <NSObject>
@optional
@property (nonatomic, readonly, strong) UIScrollView *scrollView;
@property (nonatomic, readonly, getter=canGoBack) BOOL canGoBack;
@property (nonatomic, readonly, getter=canGoForward) BOOL canGoForward;
@property (nonatomic, readonly, getter=isLoading) BOOL loading;
// use KVO
@property (nonatomic, readonly, copy) NSString *title;
// use KVO
@property (nonatomic, readonly) double estimatedProgress;
- (void)loadRequest:(NSURLRequest *)request;
- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;
- (void)reload;
- (void)stopLoading;
- (void)goBack;
- (void)goForward;
- (void)jh_evaluateJavaScript:(NSString*)javaScriptString completionHandler:(void (^)(id, NSError*))completionHandler;

@end

@protocol JHWebViewDelegate <NSObject>
@optional
- (BOOL)jh_webView:(id<JHWebViewProtocol>)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(JHWebViewNavigationType)navigationType;
- (void)jh_webViewDidStartLoad:(id<JHWebViewProtocol>)webView;
- (void)jh_webViewDidFinishLoad:(id<JHWebViewProtocol>)webView;
- (void)jh_webView:(id<JHWebViewProtocol>)webView didFailLoadWithError:(NSError *)error;
@end

@interface JHWebViewConfiguration : NSObject
@property (nonatomic) BOOL allowsInlineMediaPlayback; // iPhone Safari defaults to NO. iPad Safari defaults to YES
@property (nonatomic) BOOL mediaPlaybackRequiresUserAction; // iPhone and iPad Safari both default to YES
@property (nonatomic) BOOL mediaPlaybackAllowsAirPlay; // iPhone and iPad Safari both default to YES
@property (nonatomic) BOOL suppressesIncrementalRendering; // iPhone and iPad Safari both default to NO
@property (nonatomic) BOOL scalesPageToFit;
@end

@interface JHWebView : UIView <JHWebViewProtocol>
+(JHWebView *)webViewWithFrame:(CGRect)frame configuration:(JHWebViewConfiguration *)configuration;
@property (nonatomic,weak) id<JHWebViewDelegate> delegate;

@end
