Feature: User edits his rating
  In order to change my mind
  As an end-user
  I want to edit my rating
  
  Scenario: Editing rating when logged in and already rated
  Given I am on "testproduct" detailed view
  And I am logged in
  And I have already "rated"
  When I press "edit rating"
  And I set a new rating "2"
  And I press "update"
  Then a new "average" should be calculated
  And I should see "Rating edited"