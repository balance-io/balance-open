Feature: Add feed
  In order to filter through my transactions quickly
  As a user
  I want add a feed rule

  Scenario: Add a new feed
    Given I am an established Balance user
    When I click on the preferences cog
      And I click on "Preferences"
      And I click on the "Rules" tab
      And I ensure there are no rule templates
      And I click on "Add a rule"
      And I select "Category name"
      And I select "Food and Drink"
    Then the rule name should be "In category \"Food and Drink\""
    When I click on the main dialog's "Feed" tab
    Then I should only have one transaction
      And the header should read "TUESDAY AUG 16 2016"
      And the transaction should be "Roedbyputtgarden for $13.07 in Ultimate Rewards Credit Card"