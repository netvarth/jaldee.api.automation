*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Order
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


*** Test Cases ***


JD-TC-GetOrderSetings-1
    [Documentation]    Get order settings of provider.

    clear_queue    ${PUSERNAME140}
    clear_service  ${PUSERNAME140}
    clear_customer   ${PUSERNAME140}
    clear_Item   ${PUSERNAME140}
    ${resp}=  ProviderLogin  ${PUSERNAME140}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Suite Variable  ${fname}  ${resp.json()['firstName']}
    Set Suite Variable  ${lname}  ${resp.json()['lastName']}
    
    ${accId}=  get_acc_id  ${PUSERNAME140}
    Set Suite Variable  ${accId}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${email_id}  ${firstname}${PUSERNAME140}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order Settings of Provider    ${accId}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    Should Be Equal As Strings  ${resp.json()['enableOrder']}                    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}      ${PUSERNAME140}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['email']}      ${email_id}
   
JD-TC-GetOrderSetings-2
    [Documentation]    Get order settings of provider WITHOUT ENABLE ORDER.

    clear_queue    ${PUSERNAME141}
    clear_service  ${PUSERNAME141}
    clear_customer   ${PUSERNAME141}
    clear_Item   ${PUSERNAME141}
    ${resp}=  ProviderLogin  ${PUSERNAME141}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${fname}  ${resp.json()['firstName']}
    Set Test Variable  ${lname}  ${resp.json()['lastName']}
    
    ${accId1}=  get_acc_id  ${PUSERNAME141}

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order Settings of Provider    ${accId1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    Should Be Equal As Strings  ${resp.json()['enableOrder']}                    ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}      ${PUSERNAME141}
    
JD-TC-GetOrderSetings-3
    [Documentation]    Get order settings of provider By provider login.

    clear_queue    ${PUSERNAME143}
    clear_service  ${PUSERNAME143}
    clear_customer   ${PUSERNAME143}
    clear_Item   ${PUSERNAME143}
    ${resp}=  ProviderLogin  ${PUSERNAME143}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${fname}  ${resp.json()['firstName']}
    Set Test Variable  ${lname}  ${resp.json()['lastName']}
    
    ${accId2}=  get_acc_id  ${PUSERNAME143}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME143}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${resp}=   Get Order Settings of Provider    ${accId2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    Should Be Equal As Strings  ${resp.json()['enableOrder']}                    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}      ${PUSERNAME143}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['email']}      ${email_id}

JD-TC-GetOrderSetings-4
    [Documentation]    Get Order without login.

    ${resp}=   Get Order Settings of Provider    ${accId}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings  ${resp.json()['enableOrder']}                    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}      ${PUSERNAME140}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['email']}      ${email_id}
   