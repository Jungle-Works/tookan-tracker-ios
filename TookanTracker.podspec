Pod::Spec.new do |s|
  s.name             = 'TookanTracker'
  s.version          = '0.0.9'
  s.summary          = 'Now add Tookan Tracker in app for quick tracking.'
  s.description      = 'TookanTracker SDK allows you to integrate Tookan tracking functionality into your iOS application for real-time tracking capabilities.'
  s.homepage         = 'https://github.com/Jungle-Works/tookan-tracker-ios'
  s.documentation_url = 'https://docs.jungleworks.com/tookan/sdk/ios'
  s.license          = { :type => 'MIT', :file => 'FILE_LICENSE' }
  s.author           = { 'Mukul Kansal' => 'mukul.kansal@jungleworks.com' }
  s.source           = { :git => 'https://github.com/Jungle-Works/tookan-tracker-ios.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '12.0'  # Updated from 9.0
  s.swift_version = '5.0'
  s.static_framework = true
  
  # More specific source files path
  s.source_files = 'TookanTracker/TookanTracker/**/*.{h,m,swift,c}'
  
  # Exclude DemoApp
  s.exclude_files = 'TookanTracker/TookanTracker/DemoApp/**/*'
  
  # Use resource_bundles instead of resources
  s.resource_bundles = {
    'TookanTracker' => ['TookanTracker/TookanTracker/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}']
  }
  
  # Exclude storyboards that cause issues
  s.exclude_files = [
    'TookanTracker/TookanTracker/DemoApp/**/*',
    'TookanTracker/TookanTracker/**/LaunchScreen.storyboard'
  ]
  
  s.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'DEFINES_MODULE' => 'YES'
  }
  
  s.user_target_xcconfig = { 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' 
  }
  
  # Dependencies
  s.dependency 'GoogleMaps'
  s.dependency 'GooglePlaces'
  s.dependency 'CocoaAsyncSocket'
  s.dependency 'Flightmap-SDK-iOS'
end
