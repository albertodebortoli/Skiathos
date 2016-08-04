Pod::Spec.new do |s|
	s.name = 'Skiathos'
	s.version = '1.0.0'
	s.license = { :type => 'MIT', :file => 'LICENSE' }
	s.summary = 'Simply all you need for doing Core Data. Objective-C flavour.'
	s.description = 'A minimalistic, thread safe, non-boilerplate and super easy to use version of Active Record on Core Data. Simply all you need for doing Core Data. Objective-C flavour.'
	s.homepage = 'https://github.com/albertodebortoli/Skiathos'
	s.author = { 'Alberto De Bortoli' => 'albertodebortoli.website@gmail.com' }
	s.source = { :git => 'https://github.com/albertodebortoli/Skiathos.git', :tag => "#{s.version}" }
	s.source_files = 'Skiathos/src/**/*.{h,m}'
	s.module_name = 'Skiathos'
	s.ios.deployment_target = '8.0'
	s.requires_arc = true
	s.frameworks = ["Foundation", "UIKit", "CoreData"]
end

