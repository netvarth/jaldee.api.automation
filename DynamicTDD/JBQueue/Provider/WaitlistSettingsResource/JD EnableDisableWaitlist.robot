*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Provider Waitlist 
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot

*** Test Cases ***

JD-TC-EnableDisableWaitlist-1
    [Documentation]  Disable  waitlist by login as a  valid provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  enabledWaitlist=${bool[1]}

    ${resp}=   Disable Waitlist
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  enabledWaitlist=${bool[0]}

JD-TC-EnableDisableWaitlist-2
    [Documentation]  Enable waitlist by login as a  valid provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  enabledWaitlist=${bool[0]}

    ${resp}=   Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s

    ${resp}=  Get Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  enabledWaitlist=${bool[1]}

JD-TC-EnableDisableWaitlist-UH1
    [Documentation]  Enable a waitlist when already enabled waitlist

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Enable Waitlist
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_SETTINGS_ALREADY_ON}"

JD-TC-EnableDisableWaitlist-UH2
    [Documentation]  Disable a waitlist when already disabled waitlist

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Disable Waitlist
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Disable Waitlist
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_SETTINGS_ALREADY_OFF}"

JD-TC-EnableDisableWaitlist-UH3
    [Documentation]  Enable waitlist by login as a consumer

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${account_id}=  get_acc_id  ${PUSERNAME3}
    Set Suite Variable  ${account_id}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
    Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}

    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=   Enable Waitlist
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   "${resp.json()}"     "${LOGIN_NO_ACCESS_FOR_URL}"
     
JD-TC-EnableDisableWaitlist-UH4      
    [Documentation]  Disable waitlist by login as a consumer

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Disable Waitlist
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-EnableDisableWaitlist-UH5
    [Documentation]  Enable waitlist without login

    ${resp}=   Enable Waitlist
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
     
JD-TC-EnableDisableWaitlist-UH6
    [Documentation]  Disable waitlist without login

    ${resp}=   Disable Waitlist
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}" 
     

