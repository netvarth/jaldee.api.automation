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
${self}         0
${service_duration}   5   


*** Test Cases ***
JD-TC- Cancel Waitlist-1  

	[Documentation]  Delete Waitlist By Consumer
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME103}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id     ${PUSERNAME103}
    Set Suite Variable      ${pid}

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]} 

    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Change License Package  ${pkgid[0]}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_l1}  ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${DAY}=  db.get_date_by_timezone  ${tz} 
    Set Suite Variable  ${DAY}  
    ${TOMORROW}=  db.add_timezone_date  ${tz}  1  
    Set Suite Variable  ${TOMORROW}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500

    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s1}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500

    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s2}  ${resp.json()}

    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  1  30  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %

    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_q1}  ${resp.json()}

    ${fname}=  FakerLibrary.first_name
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

    ${resp}=    Verify Otp For Login   ${CUSERNAME20}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${cons_id}  ${resp.json()['id']}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid1}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id  ${uuid1}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${TOMORROW}  ${p1_s2}  ${cnote}  ${bool[0]}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid2}  ${wid[0]}
    
    ${resp}=  Get consumer Waitlist By Id  ${uuid1}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id  ${uuid2}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Cancel Waitlist  ${uuid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Cancel Waitlist  ${uuid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get consumer Waitlist By Id  ${uuid1}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}  ${wl_status[4]}

    ${resp}=  Get consumer Waitlist By Id  ${uuid2}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}  ${wl_status[4]} 

JD-TC- Cancel Waitlist-UH1  

	[Documentation]  try to delete  already deleted  waitlist

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}   ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Cancel Waitlist  ${uuid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_CANCEL_STATUS}"

    ${resp}=  Cancel Waitlist  ${uuid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_CANCEL_STATUS}"


JD-TC- Cancel Waitlist-UH2

	[Documentation]  try to delete waitlist  without login 
    
    ${resp}=  Cancel Waitlist  ${uuid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC- Cancel Waitlist-UH3

	[Documentation]  try to delete  Started  waitlist
        
    ${resp}=  Encrypted Provider Login  ${PUSERNAME103}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action  CHECK_IN  ${uuid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${uuid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}   ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Cancel Waitlist  ${uuid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_CANCEL_STATUS}"    

JD-TC- Cancel Waitlist-UH4
	
    [Documentation]  try to delete  Done  waitlist
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME103}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action  ${waitlist_actions[4]}  ${uuid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}   ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Cancel Waitlist  ${uuid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_CANCEL_STATUS}"    
            
        
    