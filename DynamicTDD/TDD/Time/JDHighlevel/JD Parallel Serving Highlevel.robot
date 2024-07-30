*** Settings ***
Suite Teardown    Run Keywords  Delete All Sessions  resetsystem_time
Test Teardown     Delete All Sessions
Force Tags        Holiday
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${SERVICE1}    Cutting11101
${SERVICE2}    Cutting11

*** Test Cases ***
JD-TC-High Level Test Case-1
    [Documentation]  Checking the appxWaitingTime when calculation mode as Fixed and Parallel serving as 4
    ${resp}=  Encrypted Provider Login  ${PUSERNAME10}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_service   ${PUSERNAME10} 
    ${description}=  FakerLibrary.sentence
    ${ser_dutratn}=   Random Int   min=8   max=8
    ${total_amount1}=  Random Int   min=100  max=500
    ${min_prepayment}=   Random Int   min=10  max=50
    ${resp}=  Create Service  ${SERVICE1}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${EMPTY}  ${total_amount1}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_1}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE2}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${EMPTY}  ${total_amount1}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_2}  ${resp.json()}
    clear_location  ${PUSERNAME10}
    # ${city}=   get_place
    # Set Suite Variable  ${city}
    # ${latti}=  get_latitude
    # Set Suite Variable  ${latti}
    # ${longi}=  get_longitude
    # Set Suite Variable  ${longi}
    # ${postcode}=  FakerLibrary.postcode
    # Set Suite Variable  ${postcode}
    # ${address}=  get_address
    # Set Suite Variable  ${address}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    Set Suite Variable  ${city}
    Set Suite Variable  ${latti}
    Set Suite Variable  ${longi}
    Set Suite Variable  ${postcode}
    Set Suite Variable  ${address}
    ${parking}    Random Element   ${parkingType}
    Set Suite Variable  ${parking}
    ${24hours}    Random Element    ${bool}
    Set Suite Variable  ${24hours}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()}
    # Sleep  2s
    # ${resp}=  Get Queues
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${qid}  ${resp.json()[0]['id']}

    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${sTime1}=  db.subtract_timezone_time  ${tz}  2  00
    ${eTime1}=  add_timezone_time  ${tz}  3  30  
    Set Test Variable  ${qTime}   ${sTime1}-${eTime1}
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${sId_1}  ${sId_2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${queue1}=  FakerLibrary.word
    ${resp}=  Update Queue  ${qid}  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  2  10  ${lid}  ${sId_1}  ${sId_2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${trnTime}=   Random Int   min=10   max=10
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${trnTime}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[0]}   ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${cid}=  get_id  ${CUSERNAME1}

    ${resp}=  AddCustomer   ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qid}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    # ${cid}=  get_id  ${CUSERNAME2}
    ${resp}=  AddCustomer   ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qid}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid4}  ${wid[0]}
   
    # ${cid}=  get_id  ${CUSERNAME3}
    ${resp}=  AddCustomer   ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid5}  ${wid[0]}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qid}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid6}  ${wid[0]}
    
    Comment  Check waiting time of every waitlist
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=10
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=10

    Comment  Start 1st waitlist
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=0

    Comment  Start 2nd waitlist
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=0

    Comment  cancel 5th waitlist
    ${word}=  FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${wid5}  ${waitlist_cancl_reasn[4]}  ${word}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  3s
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0  waitlistStatus=${wl_status[4]}
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=0 
    Comment  cancel 4st waitlist
    ${resp}=  Waitlist Action Cancel  ${wid4}  ${waitlist_cancl_reasn[4]}  ${word}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0  waitlistStatus=${wl_status[4]}
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0  waitlistStatus=${wl_status[4]}
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=0  

    Comment  canceled waitlist back to queue
    ${resp}=  Waitlist Action  ${waitlist_actions[3]}  ${wid4}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action  ${waitlist_actions[3]}  ${wid5}
    Should Be Equal As Strings  ${resp.status_code}  200   
    sleep  2s
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=10
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=10  waitlistStatus=${wl_status[0]}
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=10  waitlistStatus=${wl_status[0]}
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=10  

JD-TC-High Level Test Case-2
	[Documentation]  Checking appxWaitingTime in different situations when calculation mode as ML and Parallel serving as 4
    ${resp}=  Encrypted Provider Login  ${PUSERNAME10}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_service   ${PUSERNAME10} 
    ${description}=  FakerLibrary.sentence
    ${ser_dutratn}=   Random Int   min=8   max=8
    ${total_amount1}=  Random Int   min=100  max=500
    ${min_prepayment}=   Random Int   min=10  max=50
    ${resp}=  Create Service  ${SERVICE1}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${EMPTY}  ${total_amount1}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_1}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE2}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${EMPTY}  ${total_amount1}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_2}  ${resp.json()}
    clear_location  ${PUSERNAME10}
    # ${city}=   get_place
    # Set Suite Variable  ${city}
    # ${latti}=  get_latitude
    # Set Suite Variable  ${latti}
    # ${longi}=  get_longitude
    # Set Suite Variable  ${longi}
    # ${postcode}=  FakerLibrary.postcode
    # Set Suite Variable  ${postcode}
    # ${address}=  get_address
    # Set Suite Variable  ${address}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    Set Suite Variable  ${city}
    Set Suite Variable  ${latti}
    Set Suite Variable  ${longi}
    Set Suite Variable  ${postcode}
    Set Suite Variable  ${address}
    ${parking}    Random Element   ${parkingType}
    Set Suite Variable  ${parking}
    ${24hours}    Random Element    ${bool}
    Set Suite Variable  ${24hours}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()}
    Sleep  2s
    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()[0]['id']}
    
    ${queue1}=  FakerLibrary.word
    ${resp}=  Update Queue  ${qid}  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  4  10  ${lid}  ${sId_1}  ${sId_2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${trnTime}=   Random Int   min=10   max=10
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}   ${trnTime}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[0]}   ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME1}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    ${cid}=  get_id  ${CUSERNAME2}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid4}  ${wid[0]}
   
    ${cid}=  get_id  ${CUSERNAME3}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid5}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid6}  ${wid[0]}
    
    Comment  Check waiting time of every waitlist
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=2
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=4    

    Comment  Start 1st waitlist
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=2  

    change_system_time  0  10
    sleep  1s
    Comment  Start 2nd waitlist
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=0 

    Comment  cancel 3rd and 4th waitlist
    ${word}=  FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${wid3}  ${waitlist_cancl_reasn[4]}  ${word}
    Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Waitlist Action Cancel  ${wid4}  ${waitlist_cancl_reasn[4]}  ${word}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  3s
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0  waitlistStatus=${wl_status[4]}
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0  waitlistStatus=${wl_status[4]}
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0  
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=0  
    
    change_system_time  0  20
    Comment  Start 5th waitlist
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid5}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME4}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid7}  ${wid[0]}
    sleep  2s
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0  waitlistStatus=${wl_status[4]}
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0  waitlistStatus=${wl_status[4]}
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=0  
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=0  

    Comment  canceled waitlist back to queue
    ${resp}=  Waitlist Action  ${waitlist_actions[3]}  ${wid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  3s
    ${resp}=  Waitlist Action  ${waitlist_actions[3]}  ${wid4}
    Should Be Equal As Strings  ${resp.status_code}  200   
    sleep  3s
    
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200   

    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0  waitlistStatus=${wl_status[0]}
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0  waitlistStatus=${wl_status[0]}
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=0  
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=0  

    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid8}  ${wid[0]}

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0  waitlistStatus=${wl_status[0]}
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0  waitlistStatus=${wl_status[0]}
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=0  
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=0  
    Verify Response List  ${resp}  7  ynwUuid=${wid8}  appxWaitingTime=15  
    
    change_system_time  0  20
    Comment  Start 3rd waitlist
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${cid}=  get_id  ${CUSERNAME5}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid9}  ${wid[0]}

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0  waitlistStatus=${wl_status[0]}
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=0  
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=0  
    Verify Response List  ${resp}  7  ynwUuid=${wid8}  appxWaitingTime=0  
    Verify Response List  ${resp}  8  ynwUuid=${wid9}  appxWaitingTime=17  

    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid10}  ${wid[0]}

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0  waitlistStatus=${wl_status[0]}
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=0  
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=0  
    Verify Response List  ${resp}  7  ynwUuid=${wid8}  appxWaitingTime=0  
    Verify Response List  ${resp}  8  ynwUuid=${wid9}  appxWaitingTime=17 
    Verify Response List  ${resp}  9  ynwUuid=${wid10}  appxWaitingTime=34 

    change_system_time  0  10
    Comment  Start 4th waitlist
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid4}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=0  
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=0  
    Verify Response List  ${resp}  7  ynwUuid=${wid8}  appxWaitingTime=0  
    Verify Response List  ${resp}  8  ynwUuid=${wid9}  appxWaitingTime=0 
    Verify Response List  ${resp}  9  ynwUuid=${wid10}  appxWaitingTime=15