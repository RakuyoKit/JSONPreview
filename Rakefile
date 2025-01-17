# Please do not modify the contents of this file.
# If you need to add a new rake method, please create a separate ruby ​​file in the `script` folder.

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

# The folders under this array are mutually exclusive, only the first folder that exists is loaded
mutual_exclusion_rakes_dirs = ['./script']

# Check and load the first existing directory
mutual_exclusion_rakes_dirs.each do |dir|
  if Dir.exist?(dir)
    Dir.glob("#{dir}/*.rb").each { |rf| require_relative rf if File.file?(rf) }
    break  # Because of mutual exclusion, stop after finding the first valid directory
  end
end
