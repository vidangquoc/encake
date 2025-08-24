#@happy    
#  Scenario Outline: invite friends by choosing email addresses from mail box's contact list
#    Given I have signed in
#    And My registered "<email_address>" is from a supported email service "<provider>"
#    And I have some emails in my contact list
#    When I visit invite friend page
#    Then I'm redirected to my email service provider's login page    
#    Given I fill in login form with my email and "<password>"
#    And I confirm the login
#    And I give permission to get my contacts
#    Then I'm redirected back to enetwork
#    And I see checkboxes for me to choose the email addresses    
#    Given I choose an email address
#    And I confirm the invitations
#    Then I'm redirected to home page
#    And I see a message telling me that invitations has been sent
#    And an invitation email is sent to the email address I chose
#    And the email contains link to enetwork
#    
#    Examples:
#      |email_address                     |provider    |password                 |
#      |hocthuoclongtienganh@gmail.com    |gmail       |vidaica.vidaica                |
#      #|hocthuoclongtienganh@yahoo.com    |yahoo       |noisehead                |
