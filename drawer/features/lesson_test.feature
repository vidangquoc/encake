@javascript
Feature: user takes test
  In order to confirm that I have master the lesson
  As an english learner
  I want to take lesson test
  
  Background:
    Given I am ready to take lesson test
  
    
  Scenario Outline: the number of questions is presented correctly
    Given My current lesson has "<number of points>" points
    When I access the lesson test screen
    Then I see "<number of questions>" questions presented
    And All questions are chosen randomly from my current lesson
    
    Examples:
    
      |number of points | number of questions |
      |10               | 10                  |
      |50               | 50                  |
      |60               | 50                  |
    
  
  Scenario Outline: test passes
    When I access the lesson test screen
    And I answer "<80% or more>" of the questions in the lesson test corectly
    And I submit the lesson test
    Then My current lesson is updated to the next active lesson
    
    Examples:
      |80% or more|
      |80         |
      |96         |
      |100        |
      
  
  Scenario Outline: test fails
    When I access the lesson test screen
    And I answer "<less than 80%>" of the questions in the lesson test corectly
    And I submit the lesson test
    Then I fail the lesson test
    
    Examples:
      |less than 80%|
      |79           |
      |40           |
      |0            |
      
  
  Scenario: update user's level
    Given My curren lesson is the last lesson of my current level
    When I pass my current lesson test
    Then My level is updated to the next level
  
  
  Scenario: show compliment from beloved when user finished the test.
    Given I have just finised a test
    Then I see a compliment from my beloved
    
   
  Scenario: don't update user's curren lesson if user's current lesson is the last lesson of the last level
    Given My curren lesson is the last lesson of the last level
    When I pass my current lesson test
    Then My current lesson remains intact
    
  
  Scenario: add all points of user's current lesson to user's point bag when user passes lesson test
    Given I pass my current lesson test
    Then All points of the lesson are added to my point bags for reviewing later
    And All added points are considered to be learnt
  
  
  Scenario: invalid points are not added to user's point bag
    Given My current lesson has some invalid points
    When I pass my current lesson test
    Then Invalid points are not added to my point bag
  
  
  Scenario: un-answered questions are considered to be false
    When I access the lesson test screen
    And I answer 79 percent of the questions in the lesson test corectly
    And I submit the lesson test
    Then I fail the lesson test
  
  
  #Scenario: notify user if there is no questions available
  #  Given No questions are available for the lesson
  #  When I access the lesson test screen
  #  Then I see a message notifying me that no test are availabe for the lesson
    
    
    
  