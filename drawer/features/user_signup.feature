Feature: User signup
  In order to use enetwork to improve my english
  As an english learner
  I want to sign up
    
  Background:
    Given I am ready with all valid details for signup
  
  @happy
  Scenario: sign up successfully
    When I signup with all valid details
    Then My account is created
    And My level is the first level
    And My lesson is the first lesson of the first level
    But My account is not activated
    And I'm reminded to open my email to confirm my account
    And I receives a confirmation email
    And The email contains confirmation link
    Given I follow confirmation link
    Then My account is activated
    And I'm signed in      
    
	Scenario: first name is absent
		When I sign up without first name
		Then I'm told that first name is required   
  
  Scenario: last name is absent
    When I sign up without last name
    Then I'm told that last name is required
	    
  Scenario: email is absent
    When I sign up without an email
    Then I'm told that email is required
     
  Scenario: invalid email
    When I sign up with an invalid email
    Then I'm told that email is invalid
      
  Scenario: email existed
    When I sign up with an email that has been registered
    Then I'm told that the email has been used   				  
     
  Scenario: password is absent
    When I sign up without password
    Then I'm told that password is required
   
  Scenario: password is too short
    When I sign up with a password having less than 5 characters    
    Then I'm told that password is too short
   
  Scenario: password is too long
    When I sign up with a password having more than 100 characters    
    Then I'm told that password is too long
     
  Scenario: password contains non-ascii characters
    #note: valid password can contain only ascii characters
    When I sign up with a password containing non-ascii characters    
    Then I'm told that password is invalid     
    
  Scenario: gender is absent
    Given I sign up without choosing a gender
    Then I'm told that gender is required
      
  Scenario: upload prohibited files
    When I sign up with an avatar image file, extension of which is not allowed
    Then I'm told that I am not allowed to upload file with that extension
          
    
    