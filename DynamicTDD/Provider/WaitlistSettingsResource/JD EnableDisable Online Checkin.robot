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
Suite Setup     Run Keywords  clear_queue  ${PUSERNAME2}  AND  clear_location  ${PUSERNAME2}

*** Test Cases ***


JD-TC-EnableDisableOnlineCheckin-1
    [Documentation]  Enable online checkin by login as a  valid provider
    ${resp}=  ProviderLogin  ${PUSERNAME215}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_location  ${PUSERNAME215}
    ${DAY1}=  get_date
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${longi}=   get_longitude
    Set Suite Variable  ${longi}
    ${latti}=   get_latitude
    Set Suite Variable  ${latti}
    ${companySuffix}=  FakerLibrary.companySuffix
    Set Suite Variable   ${companySuffix}
    ${postcode}=  FakerLibrary.postcode
    Set Suite Variable   ${postcode}
    ${address}=  get_address
    Set Suite Variable   ${address}
    ${sTime}=  add_time  9   0
    Set Suite Variable   ${sTime}   
    ${eTime}=  add_time  10  0
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
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}   
    ${resp}=  Enable Search Data
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Enable Online Checkin
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  View Waitlist Settings
    Verify Response  ${resp}  onlineCheckIns=True

JD-TC-EnableDisableOnlineCheckin-2
    [Documentation]  Disable online checkin by login as a  valid provider
    ${resp}=  ProviderLogin  ${PUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Disable Online Checkin
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  View Waitlist Settings
    Verify Response  ${resp}  onlineCheckIns=False

JD-TC-EnableDisableOnlineCheckin-UH1      
     [Documentation]  Enable online checkin by login as a consumer
     ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=   Enable Online Checkin
     Should Be Equal As Strings  ${resp.status_code}  401
     Should Be Equal As Strings   "${resp.json()}"     "${LOGIN_NO_ACCESS_FOR_URL}"
     
JD-TC-EnableDisableOnlineCheckin-UH2      
     [Documentation]  Disable online checkin by login as a consumer
     ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
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
    ${resp}=  ProviderLogin  ${PUSERNAME114}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   View Waitlist Settings
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
    ${resp}=  ProviderLogin  ${PUSERNAME124}  ${PASSWORD}
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
    ${resp}=  ProviderLogin  ${PUSERNAME124}  ${PASSWORD}
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
    ${resp}=  ProviderLogin  ${PUSERNAME124}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}    
    Verify Response  ${resp}  onlineCheckIns=True  futureDateWaitlist=True
