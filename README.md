## WebView
统一了UIWebView与WKWebView的部分API</br>
系统小于`iOS8`时切换到`UIWebView`。否则使用`WKWebView`

---

统一了部分方法，所有可使用的方法与代理回调参考`JHWebViewProtocol`协议</br>
`JHWebViewProtocol`协议里没有声明的方法暂时不能使用使用

目前支持的方法

``` objc
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
```
