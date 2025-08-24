@javascript
Feature: Points review
  In order to memorize what I've learned
  As an english learner
  I want to review learning points
  
  
  Background:
    Given I am on point review page    
    And I choose Vietnamease to English as review mode
    And I get 5 points for review
  
  
  Scenario: meaning of the main example of the first point is shown on display screen
    Then Meaning of the main example of the first point is shown on display screen
    But I don't hear any sound of the first point
  
 
  Scenario: view next point
    When I move to the next point
    Then Meaning of the main example of the next point is shown on display screen
    But I don't hear any sound of the next point
        
    
  Scenario: view previous point
    Given I am in the midle of the point list
    When I move back to the previous point
    Then Meaning of the main example of the previous point is shown on display screen
    But I don't hear any sound of the previous point
  
 
  Scenario: get reminding for current point
    When I get reminding for the current point
    Then Content of the current point is shown as title of reminding box
    And Meaning of the current point is shown as content of reminding box  
  
  
  Scenario: show example when getting reminding
    When I get reminding for the current point    
    Then Content of the main example of the point is shown on display screen
    And Meaning of the main example of the point is also shown on display screen
    
  
  Scenario: hearing sound
    When I click to hear sound of current point
    Then I hear sound of the main example of the current point
    When I confirm that I have finished reviewing
    Then I am considered to get reminding on the current point
  
  
  Scenario: switch review mode
    When I switch review mode to "English to Vietnamease"    
    Then Content of the main example of the curren point is shown on display screen
    