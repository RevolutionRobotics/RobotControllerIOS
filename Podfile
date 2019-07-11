platform :ios, '11.0'

# Ignore all warnings from all pods
inhibit_all_warnings!

target 'RevolutionRobotics' do
  use_frameworks!

  # Development tools
  pod 'SwiftLint', '~> 0.31.0'

  # Dependency injection
  pod 'Swinject', '~> 2.6.0'

  # Release management
  pod 'Fabric', '~> 1.9.0'
  pod 'Crashlytics', '~> 3.12.0'

  # UI
  pod 'Kingfisher', '~> 5.3.1'
  pod 'SideMenu', :git => 'https://github.com/stelabouras/SideMenu.git', :branch => 'upgrade/xcode-10.2'
  pod 'PieCharts', '~> 0.0.7'

  # Storage
  pod 'RealmSwift', '~> 3.14.1'
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'

  repoUrl = 'git@github.com:RevolutionRobotics/'
  activeBranch = 'development'

  # RevolutionRobotics
  pod 'RevolutionRoboticsBlockly', git: "#{repoUrl}RevolutionRoboticsBlocklyIOS", branch: activeBranch, :submodules => true
  pod 'RevolutionRoboticsBluetooth', git: "#{repoUrl}RevolutionRoboticsBluetoothIOS.git", branch: activeBranch
end

post_install do |installer|
    plugin 'cocoapods-acknowledgements', :settings_bundle => true
end
