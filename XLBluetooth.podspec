Pod::Spec.new do |s|
s.name         = "XLBluetooth"
s.version      = "1.0.1"
s.summary      = "连接蓝牙读写数据"
s.license      = "MIT"
s.homepage     = "https://github.com/githubLXD333/XLBluetooth"
s.author             = { "lxd" => "75509218@qq.com" }
s.platform     = :ios, "11.0"
s.source       = { :git => "https://github.com/githubLXD333/XLBluetooth.git", :tag => "#{s.version}" }
s.source_files  = "XLBluetooth/*"
end
