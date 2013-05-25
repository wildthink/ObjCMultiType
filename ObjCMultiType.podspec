Pod::Spec.new do |s|
  s.name     = 'ObjCMultiType'
  s.version  = '0.1'
  s.summary  = 'An  Objective-C dynamic multi-type framework.'
  s.homepage = 'https://github.com/datalore/ObjCMultiType'
  s.license  = 'MIT'
  s.author   = { 'Jason Jobe' => 'jason2010@jasonjobe.com' }
  s.source   = { :git => 'https://github.com/datalore/ObjCMultiType.git' }

  s.source_files = FileList['src/M*.{h,m}'].exclude(/multitype\.m/)
end
