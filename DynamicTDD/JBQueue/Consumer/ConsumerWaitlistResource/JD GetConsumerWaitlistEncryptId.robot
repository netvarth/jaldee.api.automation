*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Waitlist
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py   

*** Variables ***
${waitlistedby}           CONSUMER
@{service_names}
                            

*** Test Cases ***    
JD-TC-GetWaitlistByEncryptedID-1
    [Documentation]   Get Waitlist details By Encrypted ID
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${pid}=  get_acc_id  ${PUSERNAME179}
    Set Suite Variable      ${pid}
    # clear_service   ${PUSERNAME179}
    # clear_location  ${PUSERNAME179}
    # clear_queue  ${PUSERNAME179}
    clear waitlist   ${PUSERNAME179}
    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    Set Suite Variable  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id1}
    ${sTime1}=  db.subtract_timezone_time  ${tz}  1  00
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  50  
    Set Suite Variable   ${eTime1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  70      
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${CUSERNAME20}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cid}  ${resp.json()}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME20}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME20}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${firstname}=  FakerLibrary.name
    Set Suite Variable   ${firstname}
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=    Add FamilyMember For ProviderConsumer     ${firstname}  ${lastname}  ${dob}  ${gender}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${f1}   ${resp.json()}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${f1}  ${pid}  ${qid}  ${DAY1}  ${s_id1}  ${cnote}  ${bool[0]}  ${f1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid1}  ${wid[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id  ${uuid1}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1} 
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${qid}  
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}  ${lastname}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['phoneNo']}  ${CUSERNAME20}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Waitlist EncodedId    ${uuid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${W_uuid1}   ${resp.json()}
    
    Set Suite Variable  ${W_uuid1}  ${resp.json()}

    ${resp}=  Get Waitlist By Id  ${uuid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}   checkinEncId=${W_uuid1}

    ${resp}=  Get Waitlist By EncodedID    ${W_uuid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}                         ${uuid1}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Consumer Waitlist By EncodedId   ${W_uuid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}                         ${uuid1}
    
JD-TC-GetWaitlistByEncryptedID-2

    [Documentation]   Consumer without login Get Encrypted ID
 
    ${resp}=   Get Consumer Waitlist By EncodedId   ${W_uuid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}                         ${uuid1}
    
# JD-TC-GetWaitlistByEncryptedID-3
#     [Documentation]    Get Consumer Encrypted ID of another consumer

#     ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200  
    
#     ${resp}=  Get Consumer Waitlist By EncodedId     ${W_uuid1} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  partySize=1    waitlistedBy=${waitlistedby}      personsAhead=0
#     Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
#     Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
#     Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}            ${c_id}
#     Should Be Equal As Strings  ${resp.json()['ynwUuid']}                         ${uuid1}
   


JD-TC-GetWaitlistByEncryptedID-UH1
    [Documentation]     Passing Consumer Encrypted ID is Zero 
        
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200 

    ${resp}=   Get Consumer Waitlist By EncodedId    0
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"      "${INVALID_CHECKIN_ID}"

