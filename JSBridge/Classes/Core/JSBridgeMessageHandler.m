//
//  JSBridgeMessageHandler.m
//  LTWebView
//
//  Created by Futao on 2018/6/8.
//

#import "JSBridgeMessageHandler.h"
@interface JSBridgeMessageHandler ()
@property (nonatomic,weak)JSBridge *jsBridge;
@end
@implementation JSBridgeMessageHandler
- (instancetype)initWithJSBridge:(JSBridge *)jsBridge {
    if (self = [super init]) {
        _jsBridge = jsBridge;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if (![message.body isKindOfClass:[NSDictionary class]]) {
        
#if DEBUG
        NSLog(@"JS WARNING: Invalid message.body ,is not a dictionary,received: %@", [message.body class]);
#endif
        return;
    }
    NSDictionary *body = message.body;
    NSString *object = body[@"module"];
    NSString *method = body[@"method"];
    NSParameterAssert(object);
    NSParameterAssert(method);
    
    [self callNative:object method:method arguments:body[@"args"]];
}

- (void)callNative:(NSString *)module
            method:(NSString *)method
         arguments:(NSArray *)arguments {
    
    NSObject<JSBridgeInterface> *interface = _jsBridge.javascriptInterfaces[module];
    NSString *methodName = [interface bridgeJSInterfaceMethodMaps][method];
    
    NSParameterAssert(interface);
    NSParameterAssert(methodName);
    
    SEL selector = NSSelectorFromString(methodName);
    
    NSMethodSignature *sig = [interface methodSignatureForSelector:selector];
    
    NSParameterAssert(sig);
    if (!sig) {
        [self raiseException:@"method not fount" message:[NSString stringWithFormat:@"module %@ selectot %@ not found ",module,methodName]];
        return;
    }
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    invocation.selector = selector;
    invocation.target = interface;
    
    if (sig.numberOfArguments-2 != arguments.count ) {
        [self raiseException:@"arguments error" message:[NSString stringWithFormat:@"module %@ selectot %@ arguments error,expect %@ but get %@",module,methodName,@(sig.numberOfArguments-2),@(arguments.count)]];
        return;
    }
    
    NSMutableArray<dispatch_block_t> *argumentBlocks = [[NSMutableArray alloc] initWithCapacity:sig.numberOfArguments - 2];
    
#ifndef JSBRIDGE_CASE
#define JSBRIDGE_CASE(_typeChar, _type, _typeSelector, i)                  \
case _typeChar: {                                                           \
if (argument && ![argument isKindOfClass:[NSNumber class]]) {                \
[self raiseException:@"args type" message:@"args type  error"];               \
return;                                                                        \
}                                                                               \
_type argumentValue = [(NSNumber *)argument _typeSelector];                      \
[argumentBlocks addObject:^() {                                                   \
[invocation setArgument:&argumentValue atIndex:i];                                 \
}];                                                                                 \
break;                                                                               \
}
#endif
    
    for (int i=2; i<sig.numberOfArguments; i++) {
        
        const char *argumentType = [sig getArgumentTypeAtIndex:i];
        static const char *blockType = @encode(typeof(^{}));
        id argument = arguments[i-2];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types-discards-qualifiers"
        if (!strcmp(argumentType, blockType)) {
            JSBridgeCallBack responseCallback = [^(id result) {
                if (result == nil) {
                    result = [NSNull null];
                }
                NSDictionary *msg = @{@"callbackId":argument, @"jsFunctionArgsData":result};
                [self queueMessage:msg];
            } copy];
            [argumentBlocks addObject:^ {
                [invocation setArgument:&responseCallback atIndex:i];
            }];
        } else {
            switch (argumentType[0]) {
                    JSBRIDGE_CASE('c', char, charValue, i)
                    JSBRIDGE_CASE('C', unsigned char, unsignedCharValue, i)
                    JSBRIDGE_CASE('s', short, shortValue, i)
                    JSBRIDGE_CASE('S', unsigned short, unsignedShortValue, i)
                    JSBRIDGE_CASE('i', int, intValue, i)
                    JSBRIDGE_CASE('I', unsigned int, unsignedIntValue, i)
                    JSBRIDGE_CASE('l', long, longValue, i)
                    JSBRIDGE_CASE('L', unsigned long, unsignedLongValue, i)
                    JSBRIDGE_CASE('q', long long, longLongValue, i)
                    JSBRIDGE_CASE('Q', unsigned long long, unsignedLongLongValue, i)
                    JSBRIDGE_CASE('f', float, floatValue, i)
                    JSBRIDGE_CASE('d', double, doubleValue, i)
                    JSBRIDGE_CASE('B', BOOL, boolValue, i)
#pragma clang diagnostic pop
                default:
                    [invocation setArgument:&argument atIndex:i];
                    break;
            }
            
        }
    }
    
    for (dispatch_block_t argumentBlock in argumentBlocks) {
        argumentBlock();
    }
    [invocation invoke];
}

- (void)queueMessage:(NSDictionary *)message {
    
    NSString *messageJSON = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message
                                                                                           options:0
                                                                                             error:nil]
                                                  encoding:NSUTF8StringEncoding];;
    messageJSON = [self filterJsonString:messageJSON];
    
    NSString *javascriptCommand = [NSString
                                   stringWithFormat:@"JSB.handleMessageFromNative('%@');",
                                   messageJSON];
    __weak typeof(self) weakSelf = self;
    if ([[NSThread currentThread] isMainThread]) {
        [weakSelf.jsBridge.webview evaluateJavaScript:javascriptCommand completionHandler:nil];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf.jsBridge.webview evaluateJavaScript:javascriptCommand completionHandler:nil];
        });
    }
}

- (NSString *)filterJsonString:(NSString *)messageJSON {
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\\"
                                                         withString:@"\\\\"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\""
                                                         withString:@"\\\""];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\'"
                                                         withString:@"\\\'"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\n"
                                                         withString:@"\\n"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\r"
                                                         withString:@"\\r"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\f"
                                                         withString:@"\\f"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2028"
                                                         withString:@"\\u2028"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2029"
                                                         withString:@"\\u2029"];
    return messageJSON;
}


- (void)raiseException:(NSString *)name message:(NSString *)reason {
#if DEBUG
    NSException *exception =
    [[NSException alloc] initWithName:name reason:reason userInfo:nil];
    [exception raise];
#endif
}


@end
