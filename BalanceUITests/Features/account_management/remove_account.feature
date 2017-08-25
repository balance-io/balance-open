Feature: Remove account
  In order to organise and clean up my transactions
  As a user
  I want remove accounts

  Scenario: Remove account through preferences modal (> 1 account)
    Given I am an established Balance user
      And I have more than one account
    When I click on the preferences cog
      And I click on "Preferences"
      And I click on the "Accounts" tab
      And I click on one of my accounts
      And I click on "Remove account"
    Then my account should be deleted

  Scenario: Remove account through preferences modal (only 1 account)
    Given I am an established Balance user
      And I have one account
    When I click on the preferences cog
      And I click on "Preferences"
      And I click on the "Accounts" tab
      And I click on one of my accounts
      And I click on "Remove account"
    Then my account should be deleted
      And I should be on the add account screen