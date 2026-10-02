platform :ios, '16.0'

target 'Tower_iOS' do
  use_frameworks!

  # Pods for Tower_iOS
  pod 'AzureCommunicationCalling', :podspec =>
    'https://raw.githubusercontent.com/Azure/azure-sdk-for-ios/AzureCommunicationCalling_2.18.4/sdk/communication/' \
    'AzureCommunicationCalling/AzureCommunicationCalling.podspec.json'
  pod 'SwiftGen', '~> 6.0', :configurations => []
  pod 'SwiftLint', '~> 0.65', :configurations => []

  target 'Tower_iOSTests' do
    inherit! :search_paths

    # Pods for testing

  end

  target 'Tower_iOSUITests' do

    # Pods for testing

  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if Gem::Version.new(config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']) < Gem::Version.new('16.0')
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
      end
    end
  end

  # AzureCommunicationCalling ships a prebuilt .swiftinterface pinned to iOS 12.0 that
  # current Xcode must rebuild, which fails because AzureCommunicationCommon is built for
  # 16.0. Raise the interface's target to match.
  Dir.glob(installer.sandbox.root.join('AzureCommunicationCalling/**/*.swiftinterface')).each do |path|
    text = File.read(path)
    patched = text.gsub(/(-target \S+?-apple-ios)[\d.]+/) { "#{$1}16.0" }
    File.write(path, patched) unless patched == text
  end
end
