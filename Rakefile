# frozen_string_literal: true

FLUTTER = 'fvm flutter'
DART = 'fvm dart'

desc 'Run the app'
task :run do
  sh "#{FLUTTER} run"
end

desc 'Run the app on iOS simulator'
task :run_ios do
  sh "#{FLUTTER} run -d ios"
end

desc 'Run the app on Android emulator'
task :run_android do
  sh "#{FLUTTER} run -d android"
end

desc 'Format code'
task :format do
  sh "#{DART} format lib/"
end

desc 'Check format without modifying files'
task :format_check do
  sh "#{DART} format --set-exit-if-changed lib/"
end

desc 'Run linter (analyze)'
task :lint do
  sh "#{FLUTTER} analyze"
end

desc 'Run tests'
task :test do
  sh "#{FLUTTER} test"
end

desc 'Clean build artifacts'
task :clean do
  sh "#{FLUTTER} clean"
end

desc 'Get dependencies'
task :deps do
  sh "#{FLUTTER} pub get"
end

desc 'Build iOS'
task :build_ios do
  sh "#{FLUTTER} build ios"
end

desc 'Build Android APK'
task :build_apk do
  sh "#{FLUTTER} build apk"
end

desc 'Build Android App Bundle'
task :build_aab do
  sh "#{FLUTTER} build appbundle"
end

desc 'Format, lint, and test'
task check: %i[format_check lint test]

task default: :run
