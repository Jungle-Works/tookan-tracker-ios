Pod::Spec.new do |s|
s.name = 'TookanTracker'
s.version = '0.0.9'
s.summary = 'Now add Tookan Tracker in app for quick tracking.'
s.homepage = 'https://github.com/Jungle-Works/tookan-tracker-ios.git'
s.documentation_url = 'https://docs.jungleworks.com/tookan/sdk/ios'

s.license = { :type => 'MIT', :file => 'FILE_LICENSE' }

s.author = { 'Mukul Kansal' => 'mukul.kansal@jungleworks.com' }

s.source = { :git => 'https://github.com/Jungle-Works/tookan-tracker-ios.git', :tag => s.version }
s.ios.deployment_target = '9.0'

#s.exclude_files = 'TookanTracker/TookanTracker/DemoApp'
s.static_framework = true

s.source_files = 'TookanTracker/**/*.{h,m,swift,c}'
s.resources = 'TookanTracker/**/*.{png,jpeg,jpg,storyboard,xib}'
s.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

s.dependency 'GoogleMaps'
s.dependency 'GooglePlaces'
s.dependency 'CocoaAsyncSocket'
s.dependency 'Flightmap-SDK-iOS'
#s.static_framework = true


s.swift_version = '5.0'

end
