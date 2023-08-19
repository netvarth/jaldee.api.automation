*** Settings ***
# Suite Teardown  Run Keywords  Delete All Sessions  resetsystem_time
Suite Teardown    Delete All Sessions
Test Teardown   Delete All Sessions
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


# *** Comment ***
*** Test Cases ***

JD-TC-Get Waiting time of queue-1
	[Documentation]  create queue with current time as start time and   end time is after one hour
    Comment  waitlist the maximum number of consumer into the queue 
    Comment  call "get waiting times of queues" url during the queue time 
    
    clear_queue    ${PUSERNAME192}
    clear_service  ${PUSERNAME192}
    clear_customer   ${PUSERNAME192}
    clear_Item   ${PUSERNAME192}
    clear_location   ${PUSERNAME192}

    ${resp}=  ProviderLogin  ${PUSERNAME192}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
*** comment ***
    ${pid}=  get_acc_id  ${PUSERNAME192}
    Set Suite Variable  ${pid} 
    ${DAY}=  db.get_date    
    Set Suite Variable  ${DAY} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}

    ${sTime}=  db.get_time
    ${eTime}=  add_time  0  30
    ${city}=   get_place
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l1}  ${resp.json()}
    # sleep  2s

    ${P1SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   5  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s1}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   5  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s2}  ${resp.json()}

    ${P1SERVICE3}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE3}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE3}  ${desc}   15  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s3}  ${resp.json()}

    ${P1SERVICE4}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE4}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE4}  ${desc}   10  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s4}  ${resp.json()}

    ${sTime1}=  add_time  1  00
    ${eTime1}=  add_time  2  00
    ${p1queue1}=    FakerLibrary.word
    Set Suite Variable   ${p1queue1}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2}  ${p1_s3}  ${p1_s4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q1}  ${resp.json()}
    # sleep  02s

    # ${cid}=  get_id  ${CUSERNAME1}
    ${resp}=  AddCustomer  ${CUSERNAME1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${resp}=    Update Waitlist Settings  ${calc_mode[0]}  10  ${bool[1]}  ${bool[0]}  ${bool[1]}   ${bool[0]}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # sleep  2s
    
    ${resp}=  View Waitlist Settings
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  calculationMode=${calc_mode[0]}  trnArndTime=0  futureDateWaitlist=${bool[1]}  maxPartySize=1

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s2}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # sleep  2s 

    ${resp}=  Get Waiting Time Of queues  ${p1_l1}   ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['queueId']}  ${p1_q1}
    Should Be Equal As Strings  ${resp.json()[1]['date']}  ${DAY}
    Should Be Equal As Strings  ${resp.json()[1]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[1]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[1]['waitingTime']}  16

    # ${cid1}=  get_id  ${CUSERNAME2}
    ${resp}=  AddCustomer  ${CUSERNAME2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${p1_s1}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${p1_s2}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${cid2}=  get_id  ${CUSERNAME3}
    ${resp}=  AddCustomer  ${CUSERNAME3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid2}  ${p1_s1}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid2}  ${p1_s2}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${cid3}=  get_id  ${CUSERNAME0}
    ${resp}=  AddCustomer  ${CUSERNAME0}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid3}   ${resp.json()}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid3}  ${p1_s1}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # sleep  2s 

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waiting Time Of queues  ${p1_l1}   ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['queueId']}  ${p1_q1}
    Should Be Equal As Strings  ${resp.json()[1]['date']}  ${DAY}
    Should Be Equal As Strings  ${resp.json()[1]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[1]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[1]['waitingTime']}  56

    ${resp}=  ConsumerLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogin  ${PUSERNAME192}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid3}  ${p1_s2}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_TIME_MORE_THAN_BUS_HOURS}"
    # sleep  2s 

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  add_date  1
    Set Suite Variable  ${DAY1}
    ${resp}=  ConsumerLogin  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waiting Time Of queues  ${p1_l1}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['queueId']}  ${p1_q1}
    Should Be Equal As Strings  ${resp.json()[1]['date']}  ${DAY}
    Should Be Equal As Strings  ${resp.json()[1]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[1]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[1]['waitingTime']}  56

JD-TC-Get Waiting time of queue-2
    [Documentation]  call "get waiting times of queues" url after the queue time 
    change_system_time  1  3
    # sleep  1s
    ${resp}=  ProviderLogin  ${PUSERNAME192}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  add_date  1
    Set Suite Variable  ${DAY1}
    ${resp}=  Get Waiting Time Of queues  ${p1_l1}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['queueId']}  ${p1_q1}
    Should Be Equal As Strings  ${resp.json()[1]['date']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[1]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[1]['waitingTime']}  0

*** Keywords ***
Add Waitlist MonToFri
    [Arguments]  ${s}  ${q}
    ${pid}=  get_acc_id  ${PUSERNAME192}
    ${cid}=  get_id  ${CUSERNAME0}
    ${d1}=  get_weekday     
    ${d}=  Evaluate  7-${d1}      
    ${Date}=  add_date  ${d}
    ${Date1}=  add_date  ${d+1}  
    ${cnote}=   FakerLibrary.word   
    ${resp}=  Add To Waitlist  ${cid}  ${s}  ${q}  ${Date}  ${cnote}  ${bool[1]}  ${cid}  
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s}  ${q}  ${Date1}  ${cnote}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 

Add Waitlist Saturday
    [Arguments]  ${s}  ${q}
    ${pid}=  get_acc_id  ${PUSERNAME192}
    ${cid}=  get_id  ${CUSERNAME0}
    ${d1}=  get_weekday     
    ${d}=  Evaluate  7-${d1}      
    ${Date}=  add_date  ${d}
    ${Date1}=  add_date  ${d+1}
    ${Date2}=  add_date  7
    ${Date3}=  add_date  8
    ${Date4}=  add_date  0
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s}  ${q}  ${Date}  ${cnote}  ${bool[1]}  ${cid}   
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cnote}=   FakerLibrary.word
    ${resp}=   Add To Waitlist  ${cid}  ${s}  ${q}  ${Date1}  ${cnote}  ${bool[1]}  ${cid}  
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cnote}=   FakerLibrary.word
    ${resp}=   Add To Waitlist  ${cid}  ${s}  ${q}  ${Date2}  ${cnote}  ${bool[1]}  ${cid}   
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cnote}=   FakerLibrary.word
    ${resp}=   Add To Waitlist  ${cid}  ${s}  ${q}  ${Date3}  ${cnote}  ${bool[1]}  ${cid} 
    Should Be Equal As Strings  ${resp.status_code}  200

Add Waitlist Sunday
    [Arguments]  ${s}  ${q} 
    ${pid}=  get_acc_id  ${PUSERNAME192}
    ${cid}=  get_id  ${CUSERNAME0}
    ${d1}=  get_weekday     
    ${d}=  Evaluate  7-${d1}      
    ${Date}=  add_date  ${d}
    ${Date1}=  add_date  ${d+1}
    ${Date4}=  db.get_date 

    ${cnote}=   FakerLibrary.word
    ${resp}=   Add To Waitlist  ${cid}  ${s}  ${q}  ${Date4}  ${cnote}  ${bool[1]}  ${cid}  
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    ${cnote}=   FakerLibrary.word
    ${resp}=   Add To Waitlist  ${cid}  ${s}  ${q}  ${Date}  ${cnote}  ${bool[1]}  ${cid}   
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cnote}=   FakerLibrary.word
    ${resp}=   Add To Waitlist  ${cid}  ${s}  ${q}  ${Date1}  ${cnote}  ${bool[1]}  ${cid} 
    Should Be Equal As Strings  ${resp.status_code}  200    
      

***Comment***
