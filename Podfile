platform :ios, '11.0'

# Ignore all warnings from all pods
inhibit_all_warnings!

target 'RevoRobotics' do
  use_frameworks!

  # Development tools
  pod 'SwiftLint', '~> 0.31.0'

  # Dependency injection
  pod 'Swinject', '~> 2.6.0'

  # UI
  pod 'Kingfisher', '~> 5.3.1'
  pod 'SideMenu', :git => 'https://github.com/stelabouras/SideMenu.git', :branch => 'upgrade/xcode-10.2'
  pod 'PieCharts', '~> 0.0.7'
  pod 'ContextMenu'

  # Storage
  pod 'ZIPFoundation', '~> 0.9'
  pod 'RealmSwift', '~> 3.18.0'
  
  # Firebase
  pod 'Firebase/CoreOnly'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  
  # API communication
  pod 'Alamofire', '~> 5.0'
  pod 'SwiftyJSON', '~> 5.0'
  pod 'PromiseKit', '~> 6.8'
  
  # Parental gate
  pod 'PMParentalGate'

  # RevolutionRobotics
  pod 'RevolutionRoboticsBlockly', '~> 0.3.2'
  pod 'RevolutionRoboticsBluetooth', '~> 0.1.4'
#  pod 'RevolutionRoboticsBlockly', :path => '../RevolutionRoboticsBlocklyIOS'
#  pod 'RevolutionRoboticsBluetooth', :path => '../RevolutionRoboticsBluetoothIOS'
end

post_install do |installer|
    plugin 'cocoapods-acknowledgements', :settings_bundle => true
end
