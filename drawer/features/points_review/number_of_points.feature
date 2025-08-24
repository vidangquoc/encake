Feature: Initialize review
  In order to help a user have better experience with reviewing
  As an product owner
  I want to provide appropriate information when intializing review
  
  Background: have an account
    Given I have an account
    
  Scenario: user has no points in his point bag
    Given I have no points in my point bag
    When I visit point review page
    Then I am notified that I should take a test first to have points in my point bag
    And I see a link to the page for taking test
      
  Scenario Outline: show total points
    Given I have "<a number of points>" in my point bag
    When I visit point review page
    Then "<The number of points>" is shown to me
    
    Examples:
    
      | a number of points | The number of points |
      | 10                 | 10                     |
      | 15                 | 15                     |
      | 30                 | 30                     |
      
  
  Scenario Outline: show the number of due points
    Given I have "<a number of due points>" in my bag of points
    When I visit point review page
    Then I see "<The number of due points>" shown to me
    
    Examples:
    
      | a number of due points | The number of due points |
      | 10                     | 10                     |
      | 15                     | 15                     |
      | 30                     | 30                     |
  
  @javascript   
  Scenario Outline: update the number of due points
    Given I have "<a number of due points>" in my bag of points
    And I visit point review page
    When I get "<a number of points for review>" for review
    And I confirm that I have finished reviewing those points
    Then I see "<the right number of due point left>" shown
    
  Examples:
    |a number of due points|a number of points for review|the right number of due point left|
    |30                    |10                           |20                                |
    |20                    |5                            |15                                |
    |5                     |10                           |0                                |
    
    