Feature: lessons listing
  In order to have an overview of my current studying material
  As an english learner
  I want to view lessons according to my current level
  
  Scenario: all active lessions that have position less than that of current lesson are listed.    
    When I visit lesson listing page
    Then I see a list of all active lessions that less than my current lesson
    
  Scenario: lessons are grouped into their levels    
    When I visit lesson listing page    
    Then I see lessons are grouped into their corresponding levels
    And The lessons are sorted ascendingly according to their positions
    And The levels are also sorted ascendingly according to their positions    