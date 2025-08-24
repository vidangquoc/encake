Feature: User sign in
  In order to use enetwork
  As a registered user
  I want to sign in
  
  Background:    
    Given I have an account
   
  Scenario: account has not been activated
    Given My account has not been activated
    When I sign in
    Then I'm told that my account has not been activated
      
  Scenario: correct email and password
    When I sign in with correct email and password 
    Then I get signed in
      
  Scenario: incorrect email
    When I sign in with incorrect email    
    Then I'm told that the login is invalid
        
  Scenario: incorrect password
    When I sign in with incorrect password 
    Then I'm told that the login is invalid 
  