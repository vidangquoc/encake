Feature: invite friends
  In order to be shown more clearly on enetwork
  As a user
  I want to update my basic information
  
  Background:
    Given I want to update my basic information
      
  Scenario: all information valid
    When I update my basic information with all valid details   
    Then I should see a message telling me that information has been updated    
     
  Scenario: password is too short
    When I update basic information with a password having less than 5 characters
    Then A message show me that password is too short
   
  Scenario: password is too long
    When I update basic information with a password having more than 100 characters    
    Then A message show me that password is too long
     
  Scenario: password contains non-ascii characters
    #note: valid password can contain only ascii characters
    When I update basic information with a password containing non-ascii characters    
    Then A message show me that password is invalid
   
  Scenario: password confirmation does not match
    When I update basic information with a password confirmation not matching password    
    Then A message show me that password confirmation does not match
      
  Scenario: email is unchangeable
    Given I update basic information with a new email
    Then My email still keeps unchanged
    
  Scenario: keep password unchanged if password is absent
    Given I update basic information with a blank password
    Then My password is unchanged 
   
  Scenario: first name is absent
    When I update basic information without first name
    Then A message show me that first name is required   
    
  Scenario: last name is absent
    When I update basic information without last name
    Then A message show me that last name is required    
    
  Scenario: upload prohibited files
    When I update my avatar with a file, extension of which is not allowed
    Then A message show me that I am not allowed to upload file with that extension
  
  
#  Scenario: invalid birthday
#    Given I provide the private information update form with all valid information
#    And I provide Birthday with an invalid day
#    Then I should see a message telling me that Birthday is invalid


  #Scenario: gender is absent
  #  Given I update basic information without choosing a gender
  #  Then A message show me that gender is required  
    
    
    