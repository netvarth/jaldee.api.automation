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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${self}         0
${service_duration}   5   


*** Test Cases ***
JD-TC- Cancel Waitlist-1  
	[Documentation]  Delete Waitlist By Consumer
    [Setup]  Run Keywords  clear_queue  ${PUSERNAME103}  AND  clear_service  ${PUSERNAME103}
    ${cid}=  get_id  ${CUSERNAME3} 
    ${pid}=  get_acc_id  ${PUSERNAME103}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME103}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

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
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s2}  ${resp.json()}

    # ${sTime}=  db.get_time_by_timezone   ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  1  30  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_q1}  ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${cons_id}  ${resp.json()['id']}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid1}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id  ${uuid1}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${TOMORROW}  ${p1_s2}  ${cnote}  ${bool[0]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid2}  ${wid[0]}
    
    ${resp}=  Get consumer Waitlist By Id  ${uuid1}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}  ${wl_status[0]}

    ${resp}=  Get consumer Waitlist By Id  ${uuid2}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}  ${wl_status[0]}

    ${resp}=  Cancel Waitlist  ${uuid1}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Cancel Waitlist  ${uuid2}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get consumer Waitlist By Id  ${uuid1}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}  ${wl_status[4]}

    ${resp}=  Get consumer Waitlist By Id  ${uuid2}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}  ${wl_status[4]} 

JD-TC- Cancel Waitlist-UH1  
	[Documentation]  try to delete  already deleted  waitlist
    ${pid}=  get_acc_id  ${PUSERNAME103}
    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Cancel Waitlist  ${uuid1}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_CANCEL_STATUS}"

    ${resp}=  Cancel Waitlist  ${uuid2}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_CANCEL_STATUS}"

JD-TC- Cancel Waitlist-2  
	[Documentation]  consumer delete provider added Waitlist 
    ${pid}=  get_acc_id  ${PUSERNAME103}
    # ${cid}=  get_id  ${CUSERNAME2}
    clear_customer   ${PUSERNAME103}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME103}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Cancel Waitlist  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}  ${wl_status[4]}

JD-TC- Cancel Waitlist-UH2
	[Documentation]  try to delete waitlist but uuid and provider id is different
    ${pid}=  get_acc_id  ${PUSERNAME103}
    ${cid}=  get_id  ${CUSERNAME3}
    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_q1}  ${DAY}  ${p1_s2}  ${cnote}  ${bool[0]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid3}  ${wid[0]}

    ${pid1}=  get_acc_id  ${PUSERNAME1}
    ${resp}=  Cancel Waitlist  ${uuid3}  ${pid1}
    Should Be Equal As Strings  ${resp.status_code}  401 
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}" 


JD-TC- Cancel Waitlist-UH3
	[Documentation]  try to delete waitlist  without login 
    ${pid}=  get_acc_id  ${PUSERNAME103}
    ${resp}=  Cancel Waitlist  ${uuid3}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC- Cancel Waitlist-UH4  
	[Documentation]  try to delete  Started  waitlist
    ${pid}=  get_acc_id  ${PUSERNAME103}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME103}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action  STARTED  ${uuid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Cancel Waitlist  ${uuid3}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_CANCEL_STATUS}"    

JD-TC- Cancel Waitlist-UH5  
	[Documentation]  try to delete  Done  waitlist
    ${pid}=  get_acc_id  ${PUSERNAME103}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME103}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action  DONE  ${uuid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Cancel Waitlist  ${uuid3}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_CANCEL_STATUS}"    
            
        
    