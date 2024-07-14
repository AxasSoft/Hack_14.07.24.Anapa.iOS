# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Anapa' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Anapa
  pod "PromiseKit", "~> 8"
  pod "JMMaskTextField"
  pod 'Toast-Swift', '~> 5.0.1'
  pod 'SDWebImage', '~> 5.0'
  pod 'IQKeyboardManagerSwift'
  pod 'KeychainAccess'
  pod 'Wormholy', :configurations => ['Debug']
  pod 'ZLPhotoBrowser'
  pod 'SnapKit', '~> 5.6.0'
  pod 'Kingfisher', '~> 7.6.1'
  pod "CenteredCollectionView"
  pod 'YPImagePicker'
  pod 'SwiftVideoBackground'
  pod 'Firebase/Messaging'
  pod 'Firebase/Core'
  pod 'NotificationView'
  pod 'MessageKit'
  pod 'Cosmos', '~> 23.0'
  pod 'LoadingShimmer'
  pod 'PanModal'
  pod 'SwiftyMarkdown'
  pod 'UIActiveableLabel'
  pod 'Shuffle-iOS'
  
  target 'AnapaTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'AnapaUITests' do
    # Pods for testing
  end

  post_install do |installer|
    installer.generated_projects.each do |project|
      project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
              xcconfig_path = config.base_configuration_reference.real_path
              xcconfig = File.read(xcconfig_path)
              xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
              File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
           end
      end
    end
  end
end
