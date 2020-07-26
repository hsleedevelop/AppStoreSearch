install! 'cocoapods', :deterministic_uuids => false
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '13.0'

# ignore all warnings from all pods
inhibit_all_warnings!

# 모든 target 에서 사용할 공용 pods
def shared_pods
  # RX
  pod 'RxSwift', '~> 5.1.1'
  pod 'RxCocoa', '~> 5.1.1'
  pod 'RxSwiftExt', '~> 5.1.1'
  pod 'RxGesture', '~> 3.0.2'
  pod 'RxDataSources', '~> 4.0.1'
  pod 'Cosmos', '~> 22.1.0'
end

# 디버그용 pods
def debug_pods
    pod 'FLEX',   :configurations => ['Debug']
end

# 각 target 별 pods 선언
target 'AppStoreSearch' do
    use_frameworks!
    shared_pods
    debug_pods
    target 'AppStoreSearchTests' do
      inherit! :search_paths
    end
    target 'AppStoreSearchUITests' do
      inherit! :search_paths
    end
end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        swift_version = '5.2'
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = swift_version
        end
    end
end
