Feature: User sign in
  In order to encourage users to learn harder
  As the product owner
  I want users to see motivational information when they sign in
  
  Background:    
    Given I have signed in
    
  Scenario: see current level
    When I visit home page
    Then I see my current level  
  
  Scenario: see current lesson
    When I visit home page
    Then I see a link to view my current lesson
    And I see a link to take current lesson test
    
  Scenario: see link to review page if user has due points
    Given I have some due points
    When I visit home page
    Then I see a link to point review page
    
  Scenario: don't see link to review page if user has no due points
    Given I have no due points
    When I visit home page
    Then I do not see any link to point review page
       
  Scenario: user and friends are sorted according to highest level, then highest current lesson, then soonest date on which previous lesson test is passed
  
    Given The following users exist
    
      | FIRST NAME              | ROLE    | LEVEL | CURRENT LESSON POSITION | PASSED LESSON TEST ON |
      | me                      | myself  | 1     | 1                       | none                  |
      | Level_2_lesson_1        | friend  | 2     | 1                       | today                 |
      | Level_2_lesson_2        | friend  | 2     | 2                       | today                 |
      | Level_2_lesson_2_Sooner | friend  | 2     | 2                       | yesterday             |
      | Level_3_lesson_1        | friend  | 3     | 1                       | today                 |
      | Level_3_lesson_2        | friend  | 3     | 2                       | today                 |
      | Level_3_lesson_2_Sooner | friend  | 3     | 2                       | yesterday             |
      | Unknown                 | none    | 4     | 1                       | today                 |
      | Unknown2                | none    | 4     | 1                       | today                 |
                  
    When I visit home page
    Then I see best studying people sorted as following
    
      |FIRST NAME              |
      |Level_3_lesson_2_Sooner |
      |Level_3_lesson_2        |
      |Level_3_lesson_1        |
      |Level_2_lesson_2_Sooner |
      |Level_2_lesson_2        |
      |Level_2_lesson_1        |
      |me                      |
    
  Scenario: maximum of 10 best studying people are listed
    Given I have 20 friends
    When I visit home page
    Then I see 10 best studying people  
    
  
  Scenario: show link for inviting friends
    When I visit home page
    Then I see link for me to invite friends
    
      