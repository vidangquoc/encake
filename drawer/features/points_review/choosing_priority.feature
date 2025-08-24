@javascript
Feature: Points Choosing
  In order to increase effectiveness of review
  As a product owner
  I want points to be chosen in priorities according to their statuses
    
  Background:
    Given My account exists
  
    
  Scenario: showing the right number of points
    Given I have 20 points in my learning bag
    And I visit review page
    When I get 10 points for reviewing
    Then I see a list of 10 points
    
  
  Scenario: due points have higher priorities than new points
    Given I have following points in my learning bag        
    
      | POINT             | LAST REVIEWED DATE | NEXT REVIEWED DATE | 
      | new               | none               | none               |
      | new 2             | none               | none               |
      | review due        | 4 days ago         | yesterday          |
      | review due 2      | yesterday          | today              |
    
    And I visit review page
    When I get 2 points for reviewing
    Then I see the following points
      
      | review due    |
      | review due 2  |
      
  
  Scenario: new points have higher priorities than not-due points
    Given I have following points in my learning bag
    
      | POINT             | LAST REVIEWED DATE | NEXT REVIEWED DATE |
      | not due           | yesterday          | tomorrow           |
      | not due 2         | yesterday          | 2 days from now    |
      | new               | none               | none               |
      | new 2             | none               | none               |
      
    And I visit review page
    When I get 2 points for reviewing
    Then I see the following points
      
      | new              |
      | new 2            |
      
       
  Scenario: not-due points have higher priorities than reviewed-today points
    Given I have following points in my learning bag
    
      | POINT             | LAST REVIEWED DATE | NEXT REVIEWED DATE | 
      | none due          | yesterday          | tomorrow           |
      | none due 2        | 2 days ago         | tomorrow           |
      | reviewed today    | today              | 2 days from today  |
      | reviewed today 2  | today              | 3 days from today  |
      
    And I visit review page
    When I get 2 points for reviewing
    Then I see the following points    
      
      | none due              |
      | none due 2            |    
      
  
  Scenario: For due points, points having less effectively reviewed times have higher priorities
    Given I have following points in my learning bag
      
      | POINT  | LAST REVIEWED DATE | NEXT REVIEWED DATE | EFFECTIVELY REVIEWED TIMES |
      | due 3  | yesterday          | today              | 3                          |
      | due 4  | yesterday          | today              | 4                          |
      | due 1  | yesterday          | today              | 1                          |
      | due 2  | yesterday          | today              | 2                          |
    
    And I visit review page  
    When I get 2 points for reviewing
    Then I see the following points    
      
      | due 1            |
      | due 2            |    
  
  
  Scenario: For due points with the same effectively reviewed time, points having less reviewed times have higher priorities
    Given I have following points in my learning bag
      
      | POINT  | LAST REVIEWED DATE | NEXT REVIEWED DATE | EFFECTIVELY REVIEWED TIMES | REVIEWED TIMES |
      | due 3  | yesterday          | today              | 1                          | 3              |
      | due 4  | yesterday          | today              | 1                          | 4              |
      | due 1  | yesterday          | today              | 1                          | 1              |
      | due 2  | yesterday          | today              | 1                          | 2              |
    
    And I visit review page  
    When I get 2 points for reviewing
    Then I see the following points    
      
      | due 1            |
      | due 2            |
  
      
  Scenario: For not-due points, points having less effectively reviewed times have higher priorities
    Given I have following points in my learning bag
      
      | POINT      | LAST REVIEWED DATE    | NEXT REVIEWED DATE    | EFFECTIVELY REVIEWED TIMES |
      | not due 3  | yesterday             | tomorrow              | 3                          |
      | not due 4  | yesterday             | tomorrow              | 4                          |
      | not due 1  | yesterday             | tomorrow              | 1                          |
      | not due 2  | yesterday             | tomorrow              | 2                          |
    
    And I visit review page  
    When I get 2 points for reviewing
    Then I see the following points    
      
      | not due 1            |
      | not due 2            |    
  
   
  Scenario: For not-due points with the same effectively reviewed time, points having less reviewed times have higher priorities
    Given I have following points in my learning bag
      
      | POINT      | LAST REVIEWED DATE    | NEXT REVIEWED DATE    | EFFECTIVELY REVIEWED TIMES | REVIEWED TIMES |
      | not due 3  | yesterday             | tomorrow              | 1                          | 3              |
      | not due 4  | yesterday             | tomorrow              | 1                          | 4              |
      | not due 1  | yesterday             | tomorrow              | 1                          | 1              |
      | not due 2  | yesterday             | tomorrow              | 1                          | 2              |
    
    And I visit review page  
    When I get 2 points for reviewing
    Then I see the following points    
      
      | not due 1            |
      | not due 2            |
         
      
  Scenario: For reviewed-today points, points having less reviewed times have higher priorities
    Given I have following points in my learning bag
      
      | POINT             | LAST REVIEWED DATE | NEXT REVIEWED DATE | EFFECTIVELY REVIEWED TIMES | REVIEWED TIMES |
      | reviewed-today 3  | today              | tomorrow           | 1                          | 3              |
      | reviewed-today 4  | today              | tomorrow           | 1                          | 4              |
      | reviewed-today 1  | today              | tomorrow           | 2                          | 1              |
      | reviewed-today 2  | today              | tomorrow           | 2                          | 2              |
    
    And I visit review page  
    When I get 2 points for reviewing
    Then I see the following points    
      
      | reviewed-today 1    |
      | reviewed-today 2    |        