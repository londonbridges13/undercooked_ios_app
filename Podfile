# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Undercooked' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Undercooked
	pod 'RAMPaperSwitch', '~> 2.0.0' 
	pod 'AMScrollingNavbar'
	pod 'Jelly'
	pod 'NVActivityIndicatorView'
   	pod 'Alamofire', '~> 4.0'
	pod 'RealmSwift'
 	pod 'Kingfisher', '~> 3.0'
	pod 'FaveButton' 
	pod 'PullToMakeSoup', '~> 2.0'


  target 'UndercookedTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'UndercookedUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end