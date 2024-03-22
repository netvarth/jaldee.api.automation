*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        LocationSuggestion
Library           Collections
Library           String
Library           json
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${sug}	           An

*** Test Cases ***

JD-TC-GetLocationSuggestion-1
    [Documentation]  GetLocationSuggestion by providerlogin
    ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Location Suggestion  ${sug}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Set Suite Variable  ${len}  ${len}
    ${status} =  Evaluate  ${len} > 0
    Should Be Equal As Strings  ${status}  True

JD-TC-GetLocationSuggestion-2
    [Documentation]  GetLocationSuggestion by consumerlogin
    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Location Suggestion  ${sug}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len1}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  ${len1}

JD-TC-GetLocationSuggestion-3
    [Documentation]  GetLocationSuggestion without login
    ${resp}=   Get Location Suggestion  ${sug}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len1}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  ${len1}

JD-TC-GetLocationSuggestion-4
    [Documentation]  GetLocationSuggestion for all small letter input
    ${resp}=   Get Location Suggestion  an
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len1}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  ${len1}

JD-TC-GetLocationSuggestion-5
    [Documentation]  GetLocationSuggestion for all capital letter input
    ${resp}=   Get Location Suggestion  AN
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len1}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  ${len1}

JD-TC-GetLocationSuggestion-6
    [Documentation]  GetLocationSuggestion for mixed letter input
    ${resp}=   Get Location Suggestion  aN
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len1}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  ${len1}

