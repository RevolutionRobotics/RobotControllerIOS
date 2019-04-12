# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'RevolutionRobotics' do
  use_frameworks!

  # Development tools
  pod 'SwiftLint', '~> 0.31.0'

  # Release management
  pod 'Fabric', '~> 1.9.0'
  pod 'Crashlytics', '~> 3.12.0'

  # UI
  pod 'Kingfisher', '~> 5.3.1'

  # Stprage
  pod 'RealmSwift', '~> 3.14.1'

  # RevolutionRobotics
  pod 'RevolutionRoboticsBlockly', git: 'git@gitlab.supercharge.io:revolutionrobotics/blockly-ios.git', branch: 'development', :submodules => true
  pod 'RevolutionRoboticsBluetooth', git: 'git@gitlab.supercharge.io:revolutionrobotics/bluetooth-ios.git', branch: 'development'
end
