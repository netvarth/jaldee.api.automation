*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        SearchData
Library           Collections
Library           String
Library           json
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
*** Test Cases ***

JD-TC-EnableDisableSearchData-1
      [Documentation]  Enable and Disable Search Data
      ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get jaldeeIntegration Settings
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Search Status
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${status}  ${resp.json()}
      Run Keyword If  '${status}' =='false'  Enable Search
      ${resp}=  Get Search Status
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${status}  ${resp.json()}
      Run Keyword If  '${status}' =='true'  Disable Search

JD-TC-EnableDisableSearchData-UH1
      [Documentation]  Enable and Disable Search Data which is already enabled and disabled
      ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get jaldeeIntegration Settings
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Run Keyword If  ${resp.json()['onlinePresence']}==${bool[0]}   Set jaldeeIntegration Settings   ${boolean[1]}  ${EMPTY}  ${EMPTY}   

      # ${resp}=  Set jaldeeIntegration Settings   ${boolean[1]}  ${EMPTY}  ${EMPTY}  
      # Log   ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Search Status
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${status}  ${resp.json()}
      Run Keyword If  '${status}' =='false'  Enable Searching
      ${resp}=  Get Search Status
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${status}  ${resp.json()}
      Run Keyword If  '${status}' =='true'  Disable Searching
      

JD-TC-EnableDisableSearchData-UH2
      [Documentation]  Enable  Provider Search without login
      ${resp}=  Enable Search Data
      Should Be Equal As Strings  ${resp.status_code}  419
      Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}
      ${resp}=  Disable Search Data
      Should Be Equal As Strings  ${resp.status_code}  419
      Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-EnableDisableSearchData-UH3
      [Documentation]  Enable Search Data  using comsumer login
      ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Enable Search Data
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}
      ${resp}=  Disable Search Data
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

*** Keywords ***
Enable Search
      ${resp}=  Enable Search Data
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Search Status
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  true

Disable Search
      ${resp}=  Disable Search Data
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Search Status
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  false

Enable Searching
      ${resp}=  Enable Search Data
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Search Status
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  true
      ${resp}=  Enable Search Data
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${SEARCH_ALREADY_ENABLED}"

Disable Searching
      ${resp}=  Disable Search Data
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Search Status
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  false
      ${resp}=  Disable Search Data
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${SEARCH_ALREADY_DISABLED}"