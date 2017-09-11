Feature: Account cell
  In order to interact with my saved accounts quickly and easily
  As a user
  I want be able to expand the account cell and use its functionality

  Scenario: Expand account cell
    Given I am an established Balance user
      And I have more than one account
    When I click on one of my account cells
    Then it should be expanded

  Scenario: Go to transactions
    Given I am an established Balance user
      And I have more than one account
    When I click on one of my account cells
      And I click on "Search transactions"
    Then I should be on the transactions list
      And the transactions search should be scoped to that account

  Scenario: Exclude from balance
    Given I am an established Balance user
      And I have more than one account
    When I click on one of my account cells
      And I click on "Exclude balance"
    Then I should see the excluded icon
      And I should see an "Include balance button"
      And my total balance should be reduced by the amount in that account