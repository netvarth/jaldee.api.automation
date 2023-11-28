*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Api Gateway
Library           Collections
Library           String
Library           json
Library           DateTime
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ApiKeywords.robot
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
@{emptylist}

*** Test Cases ***


JD-TC-GetLeadDetailsForSP-1

    [Documentation]   Get lead details for a service provider having one lead.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${prov_id1}  ${resp.json()['id']}
    Set Suite Variable  ${prov_fname1}  ${resp.json()['firstName']}

    ${p_id1}=  get_acc_id  ${PUSERNAME34}

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['isApiGateway']}==${bool[0]}   Enable Disable API gateway   ${toggle[0]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get SP Token
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apiGateway']}   ${toggle[0]}
    Set Suite Variable    ${sp_token}   ${resp.json()['spToken']} 

    ${resp}=   Create User Token   ${PUSERNAME34}  ${PASSWORD}   ${sp_token}   ${countryCodes[0]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${user_token}   ${resp.json()['userToken']} 

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
    
    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number

    ${resp}=  AddCustomer  ${CUSERNAME13}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${pcons_id13}  ${resp.json()[0]['id']}
    
    ${resp}=  Create Lead   ${title}  ${desc}  ${targetPotential}  ${locId1}  ${pcons_id13}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lead_id}        ${resp.json()['id']}
    Set Suite Variable   ${leUid}        ${resp.json()['uid']}

    ${resp}=  Get Leads Details  ${user_token}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                  ${leUid}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}            ${p_id1}
    Should Be Equal As Strings  ${resp.json()[0]['title']}                ${title}
    Should Be Equal As Strings  ${resp.json()[0]['assignee']['id']}       ${prov_id1}
    Should Be Equal As Strings  ${resp.json()[0]['assignee']['name']}     ${prov_fname1}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}       ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}       ${pcons_id13}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['phoneNo']}  ${CUSERNAME13}


JD-TC-GetLeadDetailsForSP-2

    [Documentation]   Get lead details for a service provider without having a lead.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['isApiGateway']}==${bool[0]}   Enable Disable API gateway   ${toggle[0]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get SP Token
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apiGateway']}   ${toggle[0]}
    Set Test Variable    ${sp_token}   ${resp.json()['spToken']} 

    ${resp}=   Create User Token   ${PUSERNAME11}  ${PASSWORD}   ${sp_token}   ${countryCodes[0]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${user_token}   ${resp.json()['userToken']} 

    ${resp}=  Get Leads Details  ${user_token}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   []


JD-TC-GetLeadDetailsForSP-UH1

    [Documentation]   Get lead details with invalid user token.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME23}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${invalid_usertkn}=  FakerLibrary.word
    ${resp}=  Get Leads Details  ${invalid_usertkn}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422


JD-TC-GetLeadDetailsForSP-UH5

    [Documentation]   Get lead details with sp token.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Leads Details  ${sp_token}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
















