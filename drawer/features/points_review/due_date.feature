@javascript
Feature: updating due dates of points
  In order to increase effectiveness of review
  As a product owner
  I want points to be reviewed on due dates after reviewing
  
  #Background:
  #  Given I am visiting reviewing page
    
  
  Scenario: normal case
    Given I have the following points
    
      | POINT   | EFFECTIVELY REVIEWED TIMES  | DUE DATE |
      | point 0 | 0                           | today    |
      | point 1 | 1                           | today    |
      | point 2 | 2                           | today    |
      | point 3 | 3                           | today    |
      | point 4 | 4                           | today    |
      | point 5 | 5                           | today    |
      | point 6 | 6                           | today    |
      | point 7 | 7                           | today    |
      | point 8 | 8                           | today    |
      | point 9 | 9                           | today    |
      | point 10| 10                          | today    |
    
    And I go to reviewing page
    And I get all of them for reviewing
    When I confirm that they has been reviewed
    Then They will be updated as the following
    
      | POINT   | EFFECTIVELY REVIEWED TIMES  | DUE DATE            |
      | point 0 | 1                           | 4    days from now  |
      | point 1 | 2                           | 8    days from now  |
      | point 2 | 3                           | 16   days from now  |
      | point 3 | 4                           | 32   days from now  |
      | point 4 | 5                           | 64   days from now  |
      | point 5 | 6                           | 128  days from now  |
      | point 6 | 7                           | 256  days from now  |
      | point 7 | 8                           | 512  days from now  |
      | point 8 | 9                           | 1024 days from now  |
      | point 9 | 10                          | 2048 days from now  |
      | point 10| 11                          | 4096 days from now  |
      