//
//  LTViewController.m
//  LTJSBridge
//
//  Created by Futao on 06/11/2018.
//  Copyright (c) 2018 Futao. All rights reserved.
//

#import "LTViewController.h"
#import <LTJSBridge/JSBridge.h>
#import <WebKit/WebKit.h>

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

@interface LTViewController ()
@property(nonatomic, strong) JSBridge *bridge;
@property(nonatomic, strong) WKWebView *webView;
@end

@implementation LTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.webView];
    self.bridge =  [JSBridge bridgeByWebView:self.webView];
    [self.bridge addJavascriptInterface:[JSInterface new]];
    [self loadExamplePage];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadExamplePage{
    NSString *htmlPath =
    [[NSBundle mainBundle] pathForResource:@"Test" ofType:@"html"];
    NSString *appHtml = [NSString stringWithContentsOfFile:htmlPath
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [self.webView loadHTMLString:appHtml baseURL:baseURL];
}
@end
