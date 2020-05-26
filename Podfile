# Uncomment the next line to define a global platform for your project
platform :ios, 12.0

target 'aquaios' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for aquaios
  pod 'PromiseKit', '6.10.0'
  pod 'SwiftLint', '0.35.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
    end
  end
end

