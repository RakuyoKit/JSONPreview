module Tools
  def mise_exec_prefix
    'mise exec --'
  end

  def ci_mode?
    ENV['CI'] == 'true'
  end

  def ci_debug_mode?
    ENV['RUNNER_DEBUG'] == '1' || ENV['ACTIONS_RUNNER_DEBUG'] == 'true'
  end
end

# Reference other rake files to avoid adding the -f parameter when executing the rake command
FileList['**/*.rb'].each { |rf| require_relative rf }

namespace :swift do
  FORMAT_COMMAND = 'swift package --allow-writing-to-package-directory format'
  BUILD_COMMAND = 'xcodebuild -scheme RaLog -destination'

  desc 'Run Format'
  task :format do
    sh FORMAT_COMMAND
  end

  desc 'Run Lint'
  task :lint do
    sh FORMAT_COMMAND + ' --lint'
  end

  desc 'Build'
  task :build do
    sh BUILD_COMMAND + " 'platform=iOS Simulator,OS=17.4,name=iPhone 15 Pro'"
  end
end
