Feature: Rearrange accounts
  In order to organise my account balances by personal priority
  As a user
  I want arrange and order my accounts and institutions

  Scenario: Rearrange institutions through accounts tab
    Given I am an established Balance user
      And I have more than one account from more than one institution
    When I click and hold my mouse on the coloured instituion name bar
      And I drag the first account down to below the second institution
      And I release my mouse click
    Then my institutions should be in the expected order

  Scenario: Rearrange accounts through accounts tab
    Given I am an established Balance user
      And I have more than one account from the same institution
    When I click and hold my mouse on the account name
      And I drag the first account down to below the second account
      And I release my mouse click
    Then my accounts should be in the expected order