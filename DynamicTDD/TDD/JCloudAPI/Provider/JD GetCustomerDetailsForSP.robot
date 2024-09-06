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


JD-TC-GetCustomerDetailsForSP-1

    [Documentation]   Get customer details for a service provider having one lead.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${prov_id1}  ${resp.json()['id']}
    # Set Suite Variable  ${prov_fname1}  ${resp.json()['firstName']}
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${prov_id1}  ${decrypted_data['id']}
    Set Test Variable  ${prov_fname1}  ${decrypted_data['firstName']}

    ${p_id1}=  get_acc_id  ${PUSERNAME8}

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   ${resp.json()['isApiGateway']}==${bool[0]}
        ${resp}=   Enable Disable API gateway   ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['isApiGateway']}  ${bool[1]}

    ${resp}=  Get SP Token
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apiGateway']}   ${toggle[0]}
    Set Suite Variable    ${sp_token}   ${resp.json()['spToken']} 

    ${resp}=   Create User Token   ${PUSERNAME8}  ${PASSWORD}   ${sp_token}   ${countryCodes[0]}  
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
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END
    
    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number

    # ${resp}=  AddCustomer  ${CUSERNAME13}    
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}
    # Log   ${resp.json()}
    # Should Be Equal As Strings      ${resp.status_code}  200
    # Set Test Variable  ${pcons_id13}  ${resp.json()[0]['id']}
    ${emptylist}=  Create List
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcons_id13}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcons_id13}  ${resp.json()[0]['id']}
    END
    
    ${resp}=  Create Lead   ${title}  ${desc}  ${targetPotential}  ${locId1}  ${pcons_id13}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lead_id}        ${resp.json()['id']}
    Set Suite Variable   ${leUid}        ${resp.json()['uid']}

    ${resp}=  Get Customer Details  ${user_token}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}           ${pcons_id13}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNo']}      ${CUSERNAME13}

JD-TC-GetCustomerDetailsForSP-2

    [Documentation]   Get customer details for a service without add customer.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   ${resp.json()['isApiGateway']}==${bool[0]}
        ${resp}=   Enable Disable API gateway   ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['isApiGateway']}  ${bool[1]}

    ${resp}=  Get SP Token
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apiGateway']}   ${toggle[0]}
    Set Test Variable    ${sp_token}   ${resp.json()['spToken']} 

    ${resp}=   Create User Token   ${PUSERNAME17}  ${PASSWORD}   ${sp_token}   ${countryCodes[0]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${user_token}   ${resp.json()['userToken']} 

    ${resp}=  Get Customer Details  ${user_token}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   []


JD-TC-GetCustomerDetailsForSP-3

    [Documentation]   Get customer details for a service provider without create a lead.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  AddCustomer  ${CUSERNAME14}    
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}
    # Log   ${resp.json()}
    # Should Be Equal As Strings      ${resp.status_code}  200
    # Set Suite Variable  ${pcon_id}  ${resp.json()[0]['id']}

    ${emptylist}=  Create List
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME14} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcon_id}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcon_id}  ${resp.json()[0]['id']}
    END
    
    ${resp}=  Get Customer Details  ${user_token}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}           ${pcon_id}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNo']}      ${CUSERNAME14}


JD-TC-GetCustomerDetailsForSP-4

    [Documentation]   Get customer details for a service provider having multiple customers.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME15}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${pcons_id1}  ${resp.json()[0]['id']}
    
    ${resp}=  Get Customer Details  ${user_token}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['id']}           ${pcon_id}
    Should Be Equal As Strings  ${resp.json()[1]['phoneNo']}      ${CUSERNAME14}

    Should Be Equal As Strings  ${resp.json()[0]['id']}           ${pcons_id1}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNo']}      ${CUSERNAME15}


JD-TC-GetCustomerDetailsForSP-5

    [Documentation]   Get customer details for a service provider having customers and family members.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${pcon_id}  ${firstname}  ${lastname}  ${dob}  ${gender}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id}  ${resp.content}

    ${resp}=  Get Customer Details  ${user_token}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[2]['id']}           ${pcon_id}
    Should Be Equal As Strings  ${resp.json()[2]['phoneNo']}      ${CUSERNAME14}

    Should Be Equal As Strings  ${resp.json()[1]['id']}           ${pcons_id1}
    Should Be Equal As Strings  ${resp.json()[1]['phoneNo']}      ${CUSERNAME15}

    Should Be Equal As Strings  ${resp.json()[0]['id']}           ${mem_id}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNo']}      ${CUSERNAME14}

# JD-TC-GetCustomerDetailsForSP-

#     [Documentation]   Get customer details for a service provider after remove the customer.


JD-TC-GetCustomerDetailsForSP-UH1

    [Documentation]   Get lead details with invalid user token.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${invalid_usertkn}=  FakerLibrary.word
    ${resp}=  Get Customer Details  ${invalid_usertkn}
    Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Empty  ${resp.content}

JD-TC-GetCustomerDetailsForSP-UH2

    [Documentation]   Get lead details with sp token.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Customer Details  ${sp_token}
    Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Empty  ${resp.content}
















