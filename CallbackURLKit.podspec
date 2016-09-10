Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "CallbackURLKit"
  s.version      = "1.0.0"
  s.summary      = "Implemenation of x-callback-url in swift"
  s.homepage     = "https://github.com/phimage/CallbackURLKit"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license      = "MIT"

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author             = { "phimage" => "eric.marchand.n7@gmail.com" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.0'

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/phimage/CallbackURLKit.git", :tag => s.version }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.default_subspecs = 'Core'

  s.subspec "Core" do  |sp|
    sp.source_files = "Sources/*.swift"
  end

  s.subspec "GoogleChrome" do  |sp|
    sp.source_files = "Clients/GoogleChrome.swift"
    sp.dependency 'CallbackURLKit/Core'
  end

end
