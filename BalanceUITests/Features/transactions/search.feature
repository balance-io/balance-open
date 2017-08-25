Feature: Search Transactions
  In order to find the transactions I'm looking for
  As a user
  I want be able to search through my transactions list

  Before:
    Given I am an established user
      And I am on the transactions tab

  Scenario: Basic text search
    When I type '7' into the search box
    Then there should be 137 transactions listed
      And the transaction total should be $14,424.93
      And there should be a pending transaction for $23.67 at a 7-Eleven
      And there should be two transactions under "SATURDAY AUG 20"

  Scenario: In account
    When I type 'in:(American Express)' into the search box
    Then there should be 223 transactions listed
      And the transaction total should be $57.39
      And the first transaction should be on Sunday Aug 14th, an "Online Payment Thank You" for $63.95