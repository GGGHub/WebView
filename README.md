## WebView
- 统一了UIWebView与WKWebView部分通用的API</br>
- 系统小于`iOS8`时切换到`UIWebView`。否则使用`WKWebView`</br>
- 支持自动提取`WebView`中的图片并通过相关的属性或代理方法获取</br>
- 支持通过`KVO`获取`WebView`高度，加载进度，网页标题等</br>

---
### WebView代理方法

统一了`UIWebView`与`WKWebView`的代理方法。所有的代理方法都以`jh`开头

``` objc
@protocol JHWebViewDelegate <NSObject>
@optional
- (BOOL)jh_webView:(id<JHWebViewProtocol>)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(JHWebViewNavigationType)navigationType;
- (void)jh_webViewDidStartLoad:(id<JHWebViewProtocol>)webView;
- (void)jh_webViewDidFinishLoad:(id<JHWebViewProtocol>)webView;
- (void)jh_webView:(id<JHWebViewProtocol>)webView didFailLoadWithError:(NSError *)error;
@end
```


---

## 使用

封装的方法参考了WKWebView的API，首先创建一个配置类设置`WebView`相关属性然后初始化`WebView`。

``` objc
    JHWebViewConfiguration *configuration = [[JHWebViewConfiguration alloc] init];
    configuration.scalesPageToFit = NO;
    configuration.loadingHUD = YES;     //是否显示加载遮罩
    configuration.captureImage = YES;   //是否捕获图片
    JHWebView *webView = [JHWebView webViewWithFrame:CGRectMake(0, 0, self.view.width, 400) configuration:configuration];   //
    webView.delegate = self;
    [_webView addObserver:self forKeyPath:@"pageHeight" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL]; //通过KVO监听页面高度

```

如果想要捕获图片并且在点击图片时获取相应<img>标签的`src`属性时

``` objc

-(BOOL)jh_webView:(id<JHWebViewProtocol>)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(JHWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString hasPrefix:@"img"]) {
        NSString *imageStr = [request.URL.absoluteString substringFromIndex:3];
        NSUInteger idx = [webView.images indexOfObject:imageStr];
        if (idx != NSNotFound) {
            //webView.images属性为网页中所有图片的数组，imageStr为图片的地址
        }
    }
    return NO;
}
```

