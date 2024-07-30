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

JD-TC-GetSearchStatus -1
    [Documentation]  Get Search Data
    ${resp}=  Encrypted Provider Login  ${PUSERNAME22}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Search Status
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${status}  ${resp.json()}
    Run Keyword If  '${status}' =='false'  Enable Search
    ${resp}=  Get Search Status
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${status}  ${resp.json()}
    Run Keyword If  '${status}' =='true'  Disable Search

JD-TC-GetSearchStatus-UH1
    [Documentation]  Get Search Data which is already enabled and disabled
    ${resp}=  Encrypted Provider Login  ${PUSERNAME23}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Search Status
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${status}  ${resp.json()}
    Run Keyword If  '${status}' =='false'  Enable Searching
    ${resp}=  Get Search Status
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${status}  ${resp.json()}
    Run Keyword If  '${status}' =='true'  Disable Searching

        
JD-TC-GetSearchStatus -UH2
    Comment    Get search status of an account without login
    ${resp}=  Get Search Status
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-GetSearchStatus -UH3
    Comment    Get search status of an account using consumer login
    ${resp}=   Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Search Status
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

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