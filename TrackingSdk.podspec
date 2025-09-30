Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '12.0'
s.name = "TrackingSdk"
s.summary = "TrackingSdk lets a user select an ice cream flavor."
s.requires_arc = true

# 2
s.version = "0.1.0"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 4 - Replace with your name and e-mail address
s.author = { "Mukul Kansal" => "mukul.kansal@jungleworks.com" }

# 5 - Replace this URL with your own GitHub page's URL (from the address bar)
s.homepage = "https://github.com/tookanapp/tookan-tracker-ios"

# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://github.com/tookanapp/tookan-tracker-ios.git",
             :tag => "#{s.version}" }

# 7
s.framework = "UIKit"


# 8
s.source_files = "TookanTracker/**/*.{swift}"
s.exclude_files = "TookanTracker/DemoApp"
# 9
s.resources = "TookanTracker/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"

# 10
s.swift_version = "5.0"

end
