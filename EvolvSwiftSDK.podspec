Pod::Spec.new do |spec|

  spec.name         = "EvolvSwiftSDK"
  spec.version      = "1.0.0"
  spec.summary      = "Swift SDK for integration of Evolv Optimization"
  spec.description  = <<-DESC
'This SDK is designed to be integrated into projects to allow for optimizing with Evolv'
                   DESC
  spec.homepage     = "https://github.com/evolv-ai/ios-sdk"
  spec.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  spec.author             = { "Evolv Technology Solutions" => "support@evolv.ai" }
  spec.source       = { :git => "https://github.com/evolv-ai/ios-sdk.git", :tag => "#{spec.version}" }
  spec.source_files  = "EvolvSwiftSDK/**/*.{h,m,swift}"
  spec.exclude_files = "EvolvSwiftSDK/EvolvSwiftSDKTests/**/*"
  spec.swift_version = '5.0'
  spec.ios.deployment_target = '13.0'

end
