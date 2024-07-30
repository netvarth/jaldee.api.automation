
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
Suite Setup       Run Keywords  clear_queue  ${PUSERNAME34}  AND  clear_location  ${PUSERNAME34}


*** Test Cases ***

JD-TC-EnableDisableOnlineCheckin-1
    [Documentation]  Enable online checkin by login as a  valid provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${companySuffix}=  FakerLibrary.companySuffix
    Set Suite Variable   ${companySuffix} 
    # ${city}=  get_place  
    # Set Suite Variable   ${city}
    # ${longi}=  get_longitude  
    # Set Suite Variable   ${longi}
    # ${latti}=  get_latitude  
    # Set Suite Variable   ${latti}  
    # ${postcode}=  FakerLibrary.postcode
    # Set Suite Variable   ${postcode}
    # ${address}=  get_address
    # Set Suite Variable   ${address}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    Set Suite Variable  ${city}
    Set Suite Variable  ${latti}
    Set Suite Variable  ${longi}
    Set Suite Variable  ${postcode}
    Set Suite Variable  ${address}
    ${DAY}=  db.add_timezone_date  ${tz}  2  
    Set Suite Variable  ${DAY}
    ${sTime}=  add_timezone_time  ${tz}  9   0
    Set Suite Variable   ${sTime}   
    ${eTime}=  add_timezone_time  ${tz}  11  0
    Set Suite Variable   ${eTime}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${companySuffix}.com  ${postcode}  ${address}  free  True  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid1}  ${resp.json()}
    sleep  02s
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    Verify Response  ${resp}  onlineCheckIns=True


JD-TC-EnableDisableOnlineCheckin-2
    [Documentation]  Disable online checkin by login as a  valid provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Disable Online Checkin
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  View Waitlist Settings
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  onlineCheckIns=False
    

JD-TC-EnableDisableOnlineCheckin-UH1      
     [Documentation]  Enable online checkin by login as a consumer
     ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=   Enable Online Checkin
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  401
     Should Be Equal As Strings   "${resp.json()}"     "${LOGIN_NO_ACCESS_FOR_URL}"


JD-TC-EnableDisableOnlineCheckin-UH2      
     [Documentation]  Disable online checkin by login as a consumer
     ${resp}=  ConsumerLogin  ${CUSERNAME2}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=   Disable Online Checkin
     Log  ${resp.json()}
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
    [Documentation]  Enable a already enabled future checkin
    ${resp}=  Encrypted Provider Login  ${PUSERNAME36}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Enable Online Checkin
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${ONLINE_CHECKIN_ALREADY_ON}"


JD-TC-EnableDisableOnlineCheckin-UH6
    [Documentation]  Disable a already disabled future checkin
    ${resp}=  Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Disable Online Checkin
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Disable Online Checkin
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${ONLINE_CHECKIN_ALREADY_OFF}"


JD-TC-EnableDisableOnlineCheckin-3
    [Documentation]  Disable search data when no base location
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}  
    ${resp}=  Enable Search Data
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=  Disable Search Data
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-EnableDisableOnlineCheckin-CLEAR
    [Documentation]  Enable search data when no base location
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}    
    ${resp}=  UpdateBaseLocation  ${lid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['baseLocation']['id']}  ${lid1}
    ${resp}=  Get Location ById  ${lid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  baseLocation=True
    ${resp}=  Enable Search Data
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

