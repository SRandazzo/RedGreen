Pod::Spec.new do |s|
  s.name         = "RedGreen"
  s.version      = "1.0.3"
  s.summary      = "RedGreen is an extension library for SenTestKit/XCTest that makes the test output easier to parse by humans."
  s.homepage     = "http://github.com/neilco/RedGreen"
  s.license      = 'MIT (see LICENSE.txt)'
  s.author       = { "Neil Cowburn" => "git@neilcowburn.com" }
  s.source       = { :git => "https://github.com/neilco/RedGreen.git", :tag => "1.0.3" }
  s.ios.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "$(SDKROOT)/Developer/Library/Frameworks" "$(DEVELOPER_LIBRARY_DIR)/Frameworks"' }
  s.osx.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "$(DEVELOPER_LIBRARY_DIR)/Frameworks"' }
  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.7'
  s.requires_arc = true
  s.xcconfig = { 'OTHER_LDFLAGS' => '-lObjC' }
  s.default_subspec = 'SenTestingKit'
  
  s.subspec 'SenTestingKit' do |sentest|
       sentest.framework = 'SenTestingKit'
       sentest.source_files = 'RedGreen/SenTestLog+RedGreen.{h,m}'
   end
   
   s.subspec 'XCTest' do |xctest|
        xctest.framework = 'XCTest'
        xctest.source_files = 'RedGreen/XCTestLog+RedGreen.{h,m}'
    end
   
end
