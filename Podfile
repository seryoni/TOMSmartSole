# Uncomment this line to define a global platform for your project
platform :ios, '9.0'

install! 'cocoapods'  # , :integrate_targets => false


def testsPods
    #pod 'OHHTTPStubs', '~> 5.0'
    pod 'Quick', '~> 0.9'
    pod 'Nimble', '~> 4.0'
end

target 'Hero' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Hero
	pod 'Observable-Swift'
    pod 'CocoaLumberjack/Swift'
	pod 'Fabric'
    pod 'Crashlytics'
	#pod 'Charts', :git => 'https://github.com/danielgindi/Charts.git' #, :commit => '2e117e3'	
	pod 'RZBluetooth'
	pod 'TSMessages'
	pod 'GradientView'
    
  target 'HeroTests' do
    inherit! :search_paths
    # Pods for testing
    testsPods
  end

end
