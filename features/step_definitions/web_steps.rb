Given /^I am on "([^"]*)" detailed view$/ do |arg1|
  visit product_path(Product.find(:first))
end

When /^I give the rating "([^"]*)"$/ do |arg1|
  select arg1, :from => 'rating'
end

When /^I press "([^"]*)"$/ do |arg1|
  click_button arg1
end

When /^I should not see "([^"]*)"$/ do |arg1|
  pending #express the regexp above with the code you wish you had
end

Then /^a new "([^"]*)" value of ratings will be calculated$/ do |arg1|
  pending #express the regexp above with the code you wish you had
end

Then /^I should see "([^"]*)" within "([^"]*)"$/ do |arg1, arg2|
  pending #express the regexp above with the code you wish you had
end

Then /^I should not see "([^"]*)"$/ do |arg1|
  pending #express the regexp above with the code you wish you had
end

