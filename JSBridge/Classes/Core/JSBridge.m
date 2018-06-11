//
//  WKWebViewBridge.m
//  LTWebView
//
//  Created by Futao on 2018/6/8.
//

#import "JSBridge.h"
#import "JSBridgeMessageHandler.h"


@interface JSBridge ()
@property(nonatomic,strong)NSMutableDictionary<NSString*, NSObject<JSBridgeInterface>*> *javascriptInterfaces;
@end
@implementation JSBridge
- (NSMutableDictionary<NSString*, NSObject<JSBridgeInterface>*> *)javascriptInterfaces {
    if (!_javascriptInterfaces) {
        _javascriptInterfaces = @{}.mutableCopy;
    }
    return _javascriptInterfaces;
}
+ (instancetype)bridgeByWebView:(WKWebView *)webView {
    return [[[self class] alloc] initWithWebView:webView];
    
}
- (instancetype)initWithWebView:(WKWebView *)webView {
    if (self = [super init]) {
        if (webView) {
            _webview = webView;
            NSBundle *bundle = [NSBundle bundleForClass:[self class]];
            NSString *filePath = [[bundle bundlePath] stringByAppendingPathComponent:@"lt_jsbridge.bundle/javascript_bridge.js"];
            NSString *jsContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            WKUserScript *jsContentUserScript = [[WKUserScript alloc] initWithSource:jsContent injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
            [_webview.configuration.userContentController addUserScript:jsContentUserScript];
            
            JSBridgeMessageHandler *messageHandler = [[JSBridgeMessageHandler alloc] initWithJSBridge:self];
            [_webview.configuration.userContentController addScriptMessageHandler:messageHandler name:@"JSB"];
        }
    }
    return self;
}
- (void)addJavascriptInterfaces:(NSArray<NSObject<JSBridgeInterface>*> *)interfaces {
    NSParameterAssert(interfaces);
    [interfaces enumerateObjectsUsingBlock:^(NSObject<JSBridgeInterface> * _Nonnull interface, NSUInteger idx, BOOL * _Nonnull stop) {
        NSParameterAssert(interface);
        NSParameterAssert([interface bridgeJSInterfaceName]);

        [self.javascriptInterfaces setObject:interface forKey:[interface bridgeJSInterfaceName]];
    }];
    NSString *jsString = [self injectJavascripts:interfaces];
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:jsString injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [_webview.configuration.userContentController addUserScript:userScript];
}
- (void)addJavascriptInterface:(NSObject<JSBridgeInterface>*)interface {
    NSParameterAssert(interface);
    NSParameterAssert([interface bridgeJSInterfaceName]);

    [self.javascriptInterfaces setObject:interface forKey:[interface bridgeJSInterfaceName]];
    NSString *jsString = [self injectJavascripts:@[interface]];
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:jsString injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [_webview.configuration.userContentController addUserScript:userScript];
}

- (NSString *)injectJavascripts:(NSArray<NSObject<JSBridgeInterface>*> *)javascriptInterfaces {
    
    NSMutableDictionary *injectInterfaces = @{}.mutableCopy;
    [javascriptInterfaces enumerateObjectsUsingBlock:^(NSObject<JSBridgeInterface> * _Nonnull interface, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *jsMethods = [[interface bridgeJSInterfaceMethodMaps] allKeys];
        if (jsMethods) {
            [injectInterfaces setObject:jsMethods forKey:[interface bridgeJSInterfaceName]];
        }
    }];
    NSString *jsInjectPrex = @"window.JSB.inject";
    NSString *jsInjectInterfaces = [self serializeMessage:injectInterfaces];
    return [NSString stringWithFormat:@"%@(%@);",jsInjectPrex,jsInjectInterfaces];
}

- (NSString *)serializeMessage:(NSDictionary*)message {
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message
                                                                          options:0
                                                                            error:nil]
                                 encoding:NSUTF8StringEncoding];
}


@end

