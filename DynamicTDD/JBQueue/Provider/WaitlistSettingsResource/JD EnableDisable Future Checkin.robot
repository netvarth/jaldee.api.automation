***Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Future Checkin
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Test Cases ***


JD-TC-EnableDisableFutureCheckin-1

    [Documentation]  Disable future checkin by login as a  valid provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Disable Future Checkin
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  futureDateWaitlist=False

JD-TC-EnableDisableFutureCheckin-2

    [Documentation]  Enable future checkin by login as a  valid provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Enable Future Checkin
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  futureDateWaitlist=True


JD-TC-EnableDisableFutureCheckin-UH1      

    [Documentation]  Enable future checkin by login as a consumer

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${account_id}=  get_acc_id  ${PUSERNAME1}
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

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Enable Future Checkin
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   "${resp.json()}"     "${LOGIN_NO_ACCESS_FOR_URL}"
     
JD-TC-EnableDisableFutureCheckin-UH2      
    [Documentation]  Disable future checkin by login as a consumer

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=   Disable Future Checkin
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   "${resp.json()}"     "${LOGIN_NO_ACCESS_FOR_URL}"
     
JD-TC-EnableDisableFutureCheckin-UH3
     [Documentation]  Enable future checkin without login

     ${resp}=   Enable Future Checkin
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"    "${SESSION_EXPIRED}"
     
JD-TC-EnableDisableFutureCheckin-UH4
     [Documentation]  Disable futurecheckin without login

     ${resp}=   Disable Future Checkin
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-EnableDisableFutureCheckin-UH5
    [Documentation]  Disable a already disabled future checkin

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Disable Future Checkin
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Disable Future Checkin
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${FUTURE_CHECKIN_ALREADY_OFF}"
     
JD-TC-EnableDisableFutureCheckin-UH6
    [Documentation]  Enable a already enabled future checkin

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Enable Future Checkin
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Enable Future Checkin
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${FUTURE_CHECKIN_ALREADY_ON}"





