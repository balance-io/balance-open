Feature: Add account
  In order to see my transactions and account data
  As a user 
  I want add accounts

  Scenario: Add account through welcome screen (button)
    Given I am a new Balance user
    When I click on "PayPal"
      And I enter my PayPal email address
      And I enter my PayPal password
      And I click "Connect"
    Then my account should be added

  Scenario: Add account through welcome screen (search)
    Given I am a new Balance user
    When I click on the search institutions field
      And I type "paypal"
      And I click on "PayPal"
      And I enter my PayPal email address
      And I enter my PayPal password
      And I click "Connect"
    Then my account should be added

  Scenario: Add account validation error
    Given I am an established Balance user
      And I am on the add account screen
    When I click on "PayPal"
      And I enter a random email address
      And I enter a random password
      And I click "Connect"
    Then my account should not be added
      And I should see an error message

  Scenario: Add account through preferences cog
    Given I am an established Balance user
    When I click on the preferences cog
      And I click on "Add an account"
    Then I should be on the add account screen

  Scenario: Add account through preferences modal
    Given I am an established Balance user
    When I click on the preferences cog
      And I click on "Preferences"
      And I click on the "Accounts" tab
      And I click on "Add a new login"
    Then I should be on the add account screen