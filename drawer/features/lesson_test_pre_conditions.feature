@javascript
Feature: test pre-condition
  In order to encorage learners to study more careffuly before taking tests
  As the product ower
  I want learners to meet pre-conditions before taking a test
  
  Background:
    Given I have decided to take lesson test
  
  Scenario: user have not taken the test
    Given I have not taken the lesson test before
    When I access the lesson test page
    Then I see a message telling me that if I fail the lesson test I will not be able to re-take it til tomorrow
    And I have chance to proceed to the lesson test
    And I also have chance cancel the lesson test process
    
          
  Scenario: user failed the test more than 1 day
    Given I failed the test yesterday or sooner
    When I access the lesson test page
    Then I see a message telling me that if I fail the lesson test I will not be able to re-take it til tomorrow
    And I have chance to proceed to the lesson test
    And I also have chance cancel the lesson test process
    

  Scenario: user have failed the test today
    Given I have failed the test at some time today
    When I access the lesson test page
    Then I see a message telling me that I would not be able to re-take it til tomorrow    
    And I also have chance cancel the lesson test process

    
  Scenario: user has points needed to be reviewed
    Given I has some points needed to be reviewed
    When I access the lesson test page
    Then I see a message telling me that I cannot take the test because I has points needed to be reviewed
    And I have change to get to the point review page
    And I also have chance cancel the lesson test process