*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags      Waitlist
Library         Collections
Library         String
Library         json
Library           FakerLibrary
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
# Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${service_duration}   20   
${self}         0
${parallel}     1
${capacity}     5

*** Test Cases ***

JD-TC-Get Waitlist By Id Consumer-1  
	[Documentation]  Add To Waitlist By Consumer valid  provider
    
    [Setup]  Run Keywords  clear_queue  ${PUSERNAME193}  AND  clear_location  ${PUSERNAME193}  AND  clear_service  ${PUSERNAME192}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME193}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME193}
    Set Suite Variable  ${pid}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${duration}=   Random Int  min=2  max=10
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}   ${duration}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    
   
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${DAY}=  db.get_date_by_timezone  ${tz}  
    Set Suite Variable  ${DAY} 
    # ${sTime}=  db.get_time_by_timezone   ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  2  00  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_l1}  ${resp.json()}

    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l1}  ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${P1SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}  ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s1}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s2}  ${resp.json()}

    ${sTime1}=  add_timezone_time  ${tz}  2  00  
    ${eTime1}=  add_timezone_time  ${tz}  2  30  
    ${p1queue1}=    FakerLibrary.word
    Set Suite Variable   ${p1queue1}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q1}  ${resp.json()}

    comment   ${resp}=  Enable Online Checkin
    comment  Should Be Equal As Strings  ${resp.status_code}  200

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${CUSERNAME20}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME20}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${CUSERNAME20}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${fname}   ${resp.json()['firstName']}
    Set Test Variable   ${cid}   ${resp.json()['id']}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid1}  ${wid[0]}
    # sleep  04s   

    ${resp}=  Get consumer Waitlist By Id  ${uuid1}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1} 
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}  
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}  ${lname}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['phoneNo']}  ${CUSERNAME20}
    

JD-TC-Get Waitlist By Id Consumer-UH2
	[Documentation]  get waitlist by id consumer side without login  

    ${pid}=  get_acc_id  ${PUSERNAME}
    ${resp}=  Get consumer Waitlist By Id  ${uuid1}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419 
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


JD-TC-Get Waitlist By Id Consumer-UH3
	[Documentation]  get waitlist By id  using provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME193}
    ${resp}=  Get consumer Waitlist By Id  ${uuid1}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}" 
        
