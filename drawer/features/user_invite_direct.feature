@javascript
Feature: invite friends
  In order to communicate with more people on enetwork
  As a user
  I want to invite my friends
  
  Background:
    Given I have signed in
    And I visit direct inviting page
    
  Scenario: valid email addresses
    Given I enter several email addresses
    And I click the button to invite friends
    Then I'm redirected to home page
    And I see a message telling me that invitations has been sent
    And invitation emails is sent to the email addresses I entered
    And the emails contain link to enetwork
  
  
  Scenario: empty email field
    Given I let the textbox for entering email addresses empty
    And I click the button to invite friends
    Then I should see a messaging telling me that I should enter email addresses
  
    
  Scenario: invalid email addresses
    Given I enter some valid email addresses and some invalid email addresses    
    And I click the button to invite friends
    Then only valid email addresses receive invitation emails
    And I see a message telling me that some email addresses are invalid
    And invalid email addresses are presented in the textbox