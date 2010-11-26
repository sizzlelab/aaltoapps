Feature: User rates an application
  In order to share the opinion of the application
  As an end-user
  I want to be able to give the application a rating
  
  Scenario: Rating an application when logged in
    Given I am on "testproduct" detailed view
    And I am logged in
    When I give the rating "3"
    And I press "rate"
    Then a new "average" value of ratings will be calculated
    And I should see "Thank you for rating" within "#notifications"
    
  Scenario: Attempting to rate an application when not logged in
    Given I am on "testproduct" detailed view
    And I am not logged in
    When I should not see "rate"
    Then I should see "You need to log in first to rate"
    
  Scenario: Rating when already given a rating
    Given I am on "testproduct" detailed view
    And I am logged in
    When I Should not see "rate"
    Then I should see "Edit rating"