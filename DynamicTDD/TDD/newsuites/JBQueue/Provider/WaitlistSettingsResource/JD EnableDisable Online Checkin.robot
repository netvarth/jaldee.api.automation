***Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        POC
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Suite Setup     Run Keywords  clear_queue  ${PUSERNAME2}  AND  clear_location  ${PUSERNAME2}

*** Test Cases ***


JD-TC-EnableDisableOnlineCheckin-1
    [Documentation]  Enable online checkin by login as a  valid provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_location  ${PUSERNAME3}
    ${account_id}=  get_acc_id  ${PUSERNAME3}
    Set Suite Variable  ${account_id}

    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${companySuffix}=  FakerLibrary.companySuffix
    Set Suite Variable   ${companySuffix}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    Set Suite Variable  ${city}
    Set Suite Variable  ${latti}
    Set Suite Variable  ${longi}
    Set Suite Variable  ${postcode}
    Set Suite Variable  ${address}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  9   0
    Set Suite Variable   ${sTime}   
    ${eTime}=  add_timezone_time  ${tz}  10  0
    Set Suite Variable   ${eTime}
    ${city}=   get_place
    Set Suite Variable   ${city}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${companySuffix}.com  ${postcode}  ${address}  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2 sec
    Set Suite Variable  ${lid}  ${resp.json()}

    ${list}=  UpdateBaseLocation  ${lid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Online Checkin
    Log  ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Search Data
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Online Checkin
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  onlineCheckIns=True

JD-TC-EnableDisableOnlineCheckin-2
    [Documentation]  Disable online checkin by login as a  valid provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Disable Online Checkin
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  onlineCheckIns=False

JD-TC-EnableDisableOnlineCheckin-UH1      

    [Documentation]  Enable online checkin by login as a consumer

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  FakerLibrary.first_name
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
    Set Test Variable  ${token}  ${resp.json()['token']}
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Enable Online Checkin
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   "${resp.json()}"     "${LOGIN_NO_ACCESS_FOR_URL}"
     
JD-TC-EnableDisableOnlineCheckin-UH2      

    [Documentation]  Disable online checkin by login as a consumer

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  FakerLibrary.first_name
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
    Set Test Variable  ${token}  ${resp.json()['token']}
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Disable Online Checkin
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"
     
JD-TC-EnableDisableOnlineCheckin-UH3
     [Documentation]  Enable online checkin without login
     ${resp}=   Enable Online Checkin
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
     
JD-TC-EnableDisableOnlineCheckin-UH4
     [Documentation]  Disable onlinecheckin without login
     ${resp}=   Disable Online Checkin
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   ${resp.json()}  ${SESSION_EXPIRED}

JD-TC-EnableDisableOnlineCheckin-UH5

    [Documentation]  Enable a already enabled online checkin

    ${resp}=  Encrypted Provider Login  ${PUSERNAME114}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Search Data
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Search Data
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=   Enable Online Checkin
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${ONLINE_CHECKIN_ALREADY_ON}"

JD-TC-EnableDisableOnlineCheckin-UH6

    [Documentation]  Disable a already disabled online checkin

    ${resp}=  Encrypted Provider Login  ${PUSERNAME124}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Disable Online Checkin
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Disable Online Checkin
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${ONLINE_CHECKIN_ALREADY_OFF}"

JD-TC-EnableDisableOnlineCheckin-3

    [Documentation]  Disable search data and try to enable online chek in

    ${resp}=  Encrypted Provider Login  ${PUSERNAME124}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Enable Search Data
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Search Data
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     

    ${resp}=   Enable Online Checkin
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    #Should Be Equal As Strings  "${resp.json()}"  "${PLS_ENABLE_PUBLIC_SEARCH}"    
     
JD-TC-EnableDisableOnlineCheckin-4

    [Documentation]  Disable search data and and check waitlist settings

    ${resp}=  Encrypted Provider Login  ${PUSERNAME124}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     

    ${resp}=  Get Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  onlineCheckIns=True  futureDateWaitlist=True
