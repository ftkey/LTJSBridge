//
//  JSBridgeInterface.h
//  LTWebView
//
//  Created by Futao on 2018/6/8.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#ifndef JSBridgeCallBack_Type
#define JSBridgeCallBack_Type
typedef void(^JSBridgeCallBack)(__nullable id result);
#endif

NS_SWIFT_NAME(JSBridgeInterface)
@protocol JSBridgeInterface <NSObject>

@required
// JS Class Name
- (NSString*)bridgeJSInterfaceName;
// JS Methods Name
- (nullable NSDictionary<NSString*,NSString*>*)bridgeJSInterfaceMethodMaps;

@end

NS_ASSUME_NONNULL_END
