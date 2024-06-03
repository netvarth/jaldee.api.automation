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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
@{emptylist}

*** Test Cases ***


JD-TC-GetCustomerCountForSP-1

    [Documentation]   Get customer count for a service provider having one lead.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${prov_id1}  ${resp.json()['id']}
    # Set Suite Variable  ${prov_fname1}  ${resp.json()['firstName']}
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${prov_id1}  ${decrypted_data['id']}
    Set Test Variable  ${prov_fname1}  ${decrypted_data['firstName']}

    ${p_id1}=  get_acc_id  ${PUSERNAME20}

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

    ${resp}=   Create User Token   ${PUSERNAME20}  ${PASSWORD}   ${sp_token}   ${countryCodes[0]}  
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

    ${resp}=  Get Customer Count  ${user_token}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}       1

JD-TC-GetCustomerCountForSP-2

    [Documentation]   Get customer count for a service provider without add customer.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
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

    ${resp}=   Create User Token   ${PUSERNAME19}  ${PASSWORD}   ${sp_token}   ${countryCodes[0]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${user_token}   ${resp.json()['userToken']} 

    ${resp}=  Get Customer Count  ${user_token}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   0


JD-TC-GetCustomerCountForSP-4

    [Documentation]   Get customer count for a service provider without create a lead.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME14}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${pcon_id}  ${resp.json()[0]['id']}
    
    ${resp}=  Get Customer Count  ${user_token}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}       1

JD-TC-GetCustomerCountForSP-5

    [Documentation]   Get customer count for a service provider having multiple customers.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME15}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${pcons_id1}  ${resp.json()[0]['id']}
    
    ${resp}=  Get Customer Count  ${user_token}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}       2

JD-TC-GetCustomerCountForSP-6

    [Documentation]   Get customer count for a service provider having customers and family members.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${pcon_id}  ${firstname}  ${lastname}  ${dob}  ${gender}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id}  ${resp.content}

    ${resp}=  Get Customer Count  ${user_token}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}       3


# JD-TC-GetCustomerCountForSP-

#     [Documentation]   Get customer details for a service provider after remove the customer.


JD-TC-GetCustomerCountForSP-UH1

    [Documentation]   Get lead count with invalid user token.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${invalid_usertkn}=  FakerLibrary.word
    ${resp}=  Get Customer Count  ${invalid_usertkn}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-GetCustomerCountForSP-UH2

    [Documentation]   Get lead count with sp token.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Customer Count  ${sp_token}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
















