Feature: My bootstrapped app kinda works
  In order to get going on coding my awesome app
  I want to have aruba and cucumber setup
  So I don't have to do it myself

  Scenario: App just runs
    When I get help for "script-ci-lib"
    Then the exit status should be 0
    And the banner should be present
    And the banner should document that this app takes options
    And the following options should be documented:
      |--version|

  Scenario: App creates the desired files
    Given the directory "ci/lib" does not exist
    When I run `script-ci-lib .`
    Then the following files should exist:
      |ci/lib/functions                 |
      |ci/lib/helpers.rb                |
