Pod::Spec.new do |s|
  s.name     = 'ObjCMultiType'
  s.version  = '0.1'
  s.summary  = 'An  Objective-C dynamic multi-type framework.'
  s.homepage = 'https://github.com/datalore/ObjCMultiType'
  s.license  = 'MIT'
  s.author   = { 'Jason Jobe' => 'jason2010@jasonjobe.com' }
  s.source   = { :git => 'https://github.com/datalore/ObjCMultiType.git', :tag => '0.1' }
  s.requires_arc = true
  s.ios.source_files = 'src/*.[hm]'
  s.osx.source_files = 'src/*.[hm]'
end
