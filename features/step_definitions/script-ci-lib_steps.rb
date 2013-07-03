# Put your step definitions here
Given /^the directory "([^"]*)" is empty$/ do |dir|
  dir = File.join(current_dir, dir)
  FileUtils.rm_rf(dir, :secure => true)
  FileUtils.mkdir_p(dir)
end
