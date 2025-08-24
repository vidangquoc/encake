#@javascript
#Feature: review summary
#  In order to know what's going on with the review process
#  As a user
#  I want to be able see summary of the review after I confirm the finishing of review
#  
#  Background:
#    Given I am visiting reviewing page
#    
#  Scinario: see correct summary
#  
#    Given I have the following due points
#    
#      | POINT   | EFFECTIVELY REVIEWED TIMES  | DUE DATE |
#      | point 0 | 0                           | today    |
#      | point 1 | 1                           | today    |
#      | point 2 | 2                           | today    |
#      | point 3 | 3                           | today    |
#      | point 4 | 4                           | today    |      
#      
#    And I get all of them for reviewing
#    
#    And In the review process, I have the following reminding times
#    
#      | POINT   | REMINDING TIMES |
#      | point 0 | 0               |
#      | point 1 | 1               |
#      | point 2 | 2               |
#      | point 3 | 3               |
#      | point 4 | 4               |
#      
#    And I confirm that they has been reviewed
#    Then I see a summary with the following details
#    
#      | POINT   | REMINDING TIMES | DUE DATE |
#      | point 0 | 0               ||
#      | point 1 | 1               ||
#      | point 2 | 2               ||
#      | point 3 | 3               ||
#      | point 4 | 4               ||
#