*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        ProviderDetails
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
*** Test Cases ***

JD-TC-Get provider Details-1
    [Documentation]   Service Provider of a valid provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id}  ${resp.json()['id']}
    Set Suite Variable  ${f_name}  ${resp.json()['firstName']}
    Set Suite Variable  ${l_name}  ${resp.json()['lastName']}
    Set Suite Variable  ${no}  ${resp.json()['primaryPhoneNumber']}
    ${resp}=  Get Provider Details  ${id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}  ${id}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}  ${f_name}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}  ${l_name}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}  ${no}

JD-TC-Get provider Detail-UH1
    [Documentation]   Get provider Detail usin another provider id
    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Details  ${id}  
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

JD-TC-Get provider Detail-UH2
    ${resp}=   ConsumerLogin  ${CUSERNAME2}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    [Documentation]   update business profile of a valid provider
    ${resp}=  Get Provider Details  ${id} 
    Should Be Equal As Strings  ${resp.status_code}  401  
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"
    
NW-TC-Get provider Detail-UH3
    [Documentation]   Get provider Detail with invalid id
    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Details  0
    Should Be Equal As Strings  ${resp.status_code}  422 
    Should Be Equal As Strings  "${resp.json()}"  "${PROVIDER_NOT_EXIST}"
    
JD-TC-Get provider Detail-UH4
    [Documentation]   Get provider Detail without login
    ${resp}=  Get Provider Details  ${id}  
    Should Be Equal As Strings  ${resp.status_code}  419          
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"    
    
    
    
    
    
