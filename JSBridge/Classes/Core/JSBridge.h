//
//  WKWebViewBridge.h
//  LTWebView
//
//  Created by Futao on 2018/6/8.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "JSBridgeInterface.h"


NS_ASSUME_NONNULL_BEGIN
NS_SWIFT_NAME(JSBridge)
@interface JSBridge : NSObject
@property(nonatomic,weak,readonly) WKWebView *webview;
@end

@interface JSBridge (Bridge)
+ (instancetype)bridgeByWebView:(WKWebView *)webView;
@end

@interface JSBridge (Interface)
@property(nonatomic, readonly, copy) NSDictionary<NSString*, NSObject<JSBridgeInterface>*> *javascriptInterfaces;
- (void)addJavascriptInterface:(NSObject<JSBridgeInterface>*)interface;
- (void)addJavascriptInterfaces:(NSArray<NSObject<JSBridgeInterface>*> *)interfaces;
@end
NS_ASSUME_NONNULL_END




