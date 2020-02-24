platform :ios, '11.0'

# Ignore all warnings from all pods
inhibit_all_warnings!

target 'RevoRobotics' do
  use_frameworks!

  # Development tools
  pod 'SwiftLint', '~> 0.31.0'

  # Dependency injection
  pod 'Swinject', '~> 2.6.0'

  # Release management
  pod 'Fabric', '~> 1.10.2'
  pod 'Crashlytics', '~> 3.14.0'

  # UI
  pod 'Kingfisher', '~> 5.3.1'
  pod 'SideMenu', :git => 'https://github.com/stelabouras/SideMenu.git', :branch => 'upgrade/xcode-10.2'
  pod 'PieCharts', '~> 0.0.7'
  pod 'ContextMenu'

  # Storage
  pod 'RealmSwift', '~> 3.18.0'
  pod 'Firebase/Core'
  pod 'Firebase/Storage'
  pod 'Firebase/Analytics'
  
  # API communication
  pod 'Alamofire', '~> 5.0'
  pod 'SwiftyJSON', '~> 5.0'
  
  # Parental gate
  pod 'PMParentalGate'

  # RevolutionRobotics
  pod 'RevolutionRoboticsBlockly', '~> 0.2.5'
  pod 'RevolutionRoboticsBluetooth', '~> 0.1.1'
#  pod 'RevolutionRoboticsBlockly', :path => '../RevolutionRoboticsBlocklyIOS'
#  pod 'RevolutionRoboticsBluetooth', :path => '../RevolutionRoboticsBluetoothIOS'
end

post_install do |installer|
    plugin 'cocoapods-acknowledgements', :settings_bundle => true
end
