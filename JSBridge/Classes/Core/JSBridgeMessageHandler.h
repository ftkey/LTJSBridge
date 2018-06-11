//
//  JSBridgeMessageHandler.h
//  LTWebView
//
//  Created by Futao on 2018/6/8.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "JSBridge.h"

NS_ASSUME_NONNULL_BEGIN
NS_SWIFT_NAME(JSBridgeMessageHandler)
@interface JSBridgeMessageHandler : NSObject <WKScriptMessageHandler>
- (instancetype)initWithJSBridge:(JSBridge *)webViewBridge;
@end
NS_ASSUME_NONNULL_END
