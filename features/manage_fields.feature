Feature: check all manage fields
  As an administrator
  I want to check and uncheck all person, enterprise and community's fields

  Background:
    Given the following users
      | login      | name        |
      | mariasilva | Maria Silva |
    And the following enterprises
      | identifier   | owner      | name         | contact_email               | contact_phone  | enabled |
      | paper-street | mariasilva | Paper Street | marial.silva@workerbees.org | (288) 555-0153 | true    |
    And the following community
      | identifier  | name         |
      | mycommunity | My Community |
    And "Maria Silva" is admin of "My Community"
    And I am logged in as admin
    And I go to /admin/features/manage_fields

  @selenium
  Scenario: check all active person fields
    Given I check "person_active"
    And I press "save_person_fields"
    And I follow "Control panel"
    When I follow "Edit Profile"
    Then I should see "Custom area of study"

  @selenium
  Scenario: check all active enterprise fields
    Given I check "enterprise_active"
    And I press "save_enterprise_fields"
    When I go to /myprofile/paper-street/profile_editor/edit
    Then I should see "Historic and current context"

  @selenium
  Scenario: check all active community fields
    Given I check "community_active"
    And I press "save_community_fields"
    When I go to /myprofile/mycommunity/profile_editor/edit
    Then I should see "Economic activity"

  @selenium
  Scenario: uncheck Check/Uncheck All active person field
    Given I check "person_active"
    And I press "save_person_fields"
    And I uncheck "person_active"
    And I press "save_person_fields"
    And I follow "Control panel"
    When I follow "Edit Profile"
    Then I should not see "Custom area of study"

  @selenium
  Scenario: uncheck Check/Uncheck All active community field
    Given I check "community_active"
    And I press "save_community_fields"
    And I uncheck "community_active"
    And I press "save_community_fields"
    When I go to /myprofile/mycommunity/profile_editor/edit
    Then I should not see "Economic activity"

  @selenium
  Scenario: uncheck Check/Uncheck All active enterprise field
    Given I check "enterprise_active"
    And I press "save_enterprise_fields"
    And I uncheck "enterprise_active"
    And I press "save_enterprise_fields"
    When I go to /myprofile/paper-street/profile_editor/edit
    Then I should not see "Historic and current context"