# LTJSBridge

[![CI Status](https://img.shields.io/travis/Futao/LTJSBridge.svg?style=flat)](https://travis-ci.org/Futao/LTJSBridge)
[![Version](https://img.shields.io/cocoapods/v/LTJSBridge.svg?style=flat)](https://cocoapods.org/pods/LTJSBridge)
[![License](https://img.shields.io/cocoapods/l/LTJSBridge.svg?style=flat)](https://cocoapods.org/pods/LTJSBridge)
[![Platform](https://img.shields.io/cocoapods/p/LTJSBridge.svg?style=flat)](https://cocoapods.org/pods/LTJSBridge)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```
JS Code:
JSInterface.test(function(result) { clientinfo.innerHTML = "result: " +result; })
JSInterface.test1("str1","str2",function(result) { clientinfo.innerHTML = "result: " ;})
JSInterface.test2("str1","str2","str3","str4");

```

```
OC Code:

@interface JSInterface:NSObject <JSBridgeInterface>
@end
@implementation JSInterface

- (nullable NSDictionary<NSString*,NSString*>*)bridgeJSInterfaceMethodMaps {
    return @{
             @"test":NSStringFromSelector(@selector(test:)),
             @"test1":NSStringFromSelector(@selector(test1:::)),
             @"test2":NSStringFromSelector(@selector(test2:string2:string3:string4:))
             };
}
- (nonnull NSString *)bridgeJSInterfaceName {
   return @"JSInterface";
}
- (void)test:(JSBridgeCallBack)callback {
    callback(@"OC Callback [test]");
}
- (void)test1:(NSString*)string1 :(NSString*)string2 :(JSBridgeCallBack)callback {
    NSLog(@"%@,%@",string1,string2);
    callback(@"OC Callback  [test1]");
}
- (void)test2:(NSString*)string1 string2:(NSString*)string2 string3:(NSString*)string3 string4:(NSString*)string4{
    NSLog(@"%@,%@,%@,%@",string1,string2,string3,string4);
    
}
@end
```

## Requirements

## Installation

LTJSBridge is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LTJSBridge'
```

```
#import <LTJSBridge/JSBridge.h>

@property(nonatomic, strong) WKWebView *webView;
@property(nonatomic, strong) JSBridge *bridge;

self.bridge =  [JSBridge bridgeByWebView:self.webView];
[self.bridge addJavascriptInterface:[JSInterface new]];

```

## Author

Futao, ftkey@qq.com

## License

LTJSBridge is available under the MIT license. See the LICENSE file for more info.


##Thx
FMWebViewJavascriptBridge
