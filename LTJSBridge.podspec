
Pod::Spec.new do |s|
  s.name         = "LTJSBridge"
  s.version      = "1.0"
  s.summary      = 'WKWebView JSBridge Like Android addJavascriptInterface and name.'
  s.homepage     = "https://futao.me/"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Futao' => 'ftkey@qq.com' }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/ftkey/LTJSBridge.git", :tag => "#{s.version}" }
  s.frameworks = "Foundation", "UIKit", "WebKit"
  s.requires_arc = true
  s.default_subspecs = 'Core'


  s.subspec "Core" do |ss|
    ss.source_files  = "Classes", "JSBridge/Classes/Core/**/*.{h,m}"
    ss.resource  = "JSBridge/Resources/lt_jsbridge.bundle"
  end

end
