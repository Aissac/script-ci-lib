# Put your step definitions here
Given /^the directory "([^"]*)" does not exist$/ do |dir|
  FileUtils.rm_rf dir
end
