namespace :lib do
  require 'find'
  include Tools

  desc 'Release new version'
  task :release do
    podspec_file = Find.find('.').detect { |path| path =~ /\.podspec$/ && !path.include?('.build/') }

    name = nil
    version = nil

    File.readlines(podspec_file).each do |line|
      if line =~ /s.name/
        name = line.split('=').last.strip.delete("'")
      elsif line =~ /s.version/
        version = line.split('=').last.strip.delete("'")
        break
      end
    end

    puts "Releasing version #{version} of #{name}"

    execute_pod('lib', 'lint', name)

    main_branch = 'master'
    develop_branch = 'develop'
    release_branch = "release/#{version}"

    source_branch = if has_develop_branch?
                      develop_branch
                    else
                      main_branch
                    end

    sh "git checkout -b #{release_branch} #{source_branch}"
    git_message = "release: version #{version}"
    sh "git add . && git commit -m '#{git_message}' --no-verify --allow-empty"

    git_merge(release_branch, main_branch, "Merge branch '#{release_branch}'")

    sh "git tag #{version}"
    git_push(version)

    if source_branch == develop_branch
      git_merge(version, develop_branch, "Merge tag '#{version}' into #{develop_branch}")
    end

    sh "git branch -d #{release_branch}"

    execute_pod('trunk', 'push', name)
  end

  def execute_pod(command, subcommand, name)
    sh mise_exec_prefix + " pod #{command} #{subcommand} #{name}.podspec --allow-warnings --skip-tests"
  end

  def has_develop_branch?
    system "git show-branch develop &>/dev/null"
  end

  def git_merge(from_branch, to_branch, merge_message)
    sh "git checkout #{to_branch}"
    sh "git merge --no-ff -m '#{merge_message}' #{from_branch} --no-verify"
    git_push(to_branch, "--no-verify")
  end

  def git_push(branch, options = "")
    sh "git push origin #{branch} #{options}"
  end
end
