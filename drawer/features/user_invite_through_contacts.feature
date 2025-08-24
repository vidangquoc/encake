Feature: invite friends
  In order to communicate with more people on enetwork
  As a user
  I want to invite my friends   
    
  @happy
  Scenario: invite friends by choosing email addresses from mail box's contact list
    Given I have signed in
    And My email is from a supported email service provider
    And I have some emails in my contact list
    When I visit invite friend page
    Then I see checkboxes for me to choose the email addresses    
    Given I choose an email address
    And I confirm the invitations
    Then I'm redirected to home page
    And I see a message telling me that invitations has been sent
    And an invitation email is sent to the email address I chose
    And the email contains link to enetwork
    
  
  Scenario: when an invited friend signs up he is added as my friend on enetwork
    Given I invited a friend through and invitation email    
    And My friend opens the email and clicks the link to enetwork    
    Then He is lead to enetwork home page
    Given He visit the registration page
    And He registers with all valid information
    Then His account is created  
    Given He opens his confirmation email and clicks on confirmation link
    Then His account is activated
    And We become friends on enetwork 
    
    
  Scenario: invite people that have been registered
    Given I have signed in
    And My email is from a supported email service provider
    And I have some emails in my contact list
    And I visit invite friend page
    And I choose some emails to invite
    But Some of the emails have already registered
    When I confirm the invitations
    Then Those people who have the registered emails become my friends
    And Invitation emails are only sent to unregisted emails
  
   
  Scenario: emails of friends are not shown on available email list
    Given I have signed in
    And My email is from a supported email service provider
    And I have some emails in my contact list    
    But Some of the emails belong to my friends
    When I visit invite friend page    
    Then I don't see emails of my friends on available email list
  
   
  Scenario: empty contact list
    Given I have signed in
    And My email is from a supported email service provider
    But I have no emails in my contact list
    When I visit invite friend page    
    Then I'm redirected back to direct inviting page
    
      
  Scenario: My email is not from a supported email service provider  
    Given I have signed in   
    And My email is not from a supported email service provider 
    When I visit invite friend page    
    Then I'm redirected back to direct inviting page
  
  
  Scenario: exclude invalid emails from available email list
    Given I have signed in
    And My email is from a supported email service provider
    But My contact list contains some invalid emails    
    When I visit invite friend page    
    Then I don't see invalid emails on available email list
  
    