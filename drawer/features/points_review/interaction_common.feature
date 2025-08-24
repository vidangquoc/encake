@javascript
Feature: Points review
  In order to memorize what I've learned
  As an english learner
  I want to review learning points
  
  Background:
    Given I am on point review page
    And I get 10 points for review
    
  Scenario: display only reminded points on next turn
    * If some points are reminded on current turn, on next turned only reminded points are displayed
    
    | TURN  | DISPLAYED POINTS                | REMINDED POINTS               |
    | 1     | 1, 2, 3 ,4, 5, 6, 7, 8, 9, 10   | 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 |
    | 2     | 1, 2, 3 ,4, 5, 6, 7, 8, 9, 10   | 1, 2, 3,    5, 6, 7,    9, 10 |
    | 3     | 1, 2, 3,    5, 6, 7,    9, 10   |    2, 3,    6, 7,          10 |
    | 4     |    2, 3,       6, 7,       10   |       3,    6,             10 |
    | 5     |       3,       6,          10   |       3,                   10 |
    | 6     | 3, 10                           |  |
    | 7     | 1, 2, 3 ,4, 5, 6, 7, 8, 9, 10   |  |
    
      
  Scenario: view previous reminded point
    Given Some points on current turn are reminded
    Then On the next turn, when I click to see previous point, only reminded points are displayed
    
  
  Scenario: try viewing pass previous turn
    Given Some points on current turn are reminded
    Then On next turn, I try to click back to current turn
    Then I can only reach to the first point of the next turn
    
  
  Scenario: finish review
    When I confirm that I have finished reviewing
    Then I see that point list is empty
    And I see that point screen is empty   