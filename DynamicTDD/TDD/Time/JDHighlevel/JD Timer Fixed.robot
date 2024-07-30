*** Settings ***
Suite Teardown    Run Keywords  Delete All Sessions  resetsystem_time
Test Teardown     Delete All Sessions
Force Tags        Fixed   WaitingTime      
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${SERVICE1}     DelayHLev
${SERVICE2}     DelayHLev2

*** Test Cases ***
JD-TC-High Level Test Case-1
	[Documentation]  Checking the appxWaitingTime when timer is working
    ${resp}=  Encrypted Provider Login  ${PUSERNAME40}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_service   ${PUSERNAME40} 
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
    clear_location  ${PUSERNAME40}
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
    ${eTime}=  add_timezone_time  ${tz}   0  100
    Set Suite Variable   ${eTime}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  2s
    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()[0]['id']}
    ${trnTime}=   Random Int   min=10   max=10
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${trnTime}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[0]}   ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY}=  db.get_date_by_timezone  ${tz}

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
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=10
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=10
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=10
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=10
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=10

    change_system_time  0  5
    Comment  Check waiting time of every waitlist
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=5
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=5
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=5
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=5
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=5

    change_system_time  0  2
    Comment  Check waiting time of every waitlist
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=3
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=3
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=3
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=3
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=3

    change_system_time  0  3
    Comment  Check waiting time of every waitlist
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=0
    

JD-TC-High Level Test Case-2
	[Documentation]  Checking the appxWaitingTime when timer is working
    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_service   ${PUSERNAME42} 
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
    clear_location  ${PUSERNAME42}
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
    ${eTime}=  add_timezone_time  ${tz}   0  100
    Set Suite Variable   ${eTime}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  2s
    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()[0]['id']}
    ${trnTime}=   Random Int   min=10   max=10
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${trnTime}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[0]}   ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY}=  db.get_date_by_timezone  ${tz}

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
    sleep  03s
    
    Comment  Check waiting time of every waitlist
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=10
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=10
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=10

    change_system_time  0  2
    Comment  Check waiting time of every waitlist
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=8
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=8
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=8
    
    ${cid2}=  get_id  ${CUSERNAME5}
    ${resp}=  Add To Waitlist  ${cid2}  ${sId_1}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid5}  ${wid[0]}

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=8
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=8
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=8
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=10

    change_system_time  0  5
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=3
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=3
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=3
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=5

    ${resp}=  Add To Waitlist  ${cid2}  ${sId_2}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid6}  ${wid[0]}

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=3
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=3
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=3
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=5
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=10

    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  03s

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=3
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=3
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=5
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=10

	Comment  Checking the appxWaitingTime when timer is working and delay is applied
    Set Test Variable  ${delay}  30
    ${resp}=  Add Delay  ${qid}  ${delay}  ${None}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Delay  ${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  delayDuration=${delay}
    sleep  02s

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=33
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=33
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=35
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=40

    change_system_time  0  3
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=30
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=30
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=32
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=37

    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  03s

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=30
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=32
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=37
    

    ${cid3}=  get_id  ${CUSERNAME6}
    ${resp}=  Add To Waitlist  ${cid3}  ${sId_2}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid7}  ${wid[0]}

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=30
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=32
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=37
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=37
    
    Set Test Variable  ${delay}  0
    ${resp}=  Add Delay  ${qid}  ${delay}  ${None}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Delay  ${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  delayDuration=${delay}
    sleep  02s

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=2
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=7
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=10

    change_system_time  0  3
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=4
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=7

    ${resp}=  Add To Waitlist  ${cid3}  ${sId_1}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid8}  ${wid[0]}

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=4
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=7
    Verify Response List  ${resp}  7  ynwUuid=${wid8}  appxWaitingTime=10

JD-TC-High Level Test Case-3
	[Documentation]  Checking the appxWaitingTime when timer is working and cancel a waitlist
    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_service   ${PUSERNAME42} 
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
    clear_location  ${PUSERNAME42}
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
    ${eTime}=  add_timezone_time  ${tz}   0  100
    Set Suite Variable   ${eTime}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  2s
    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()[0]['id']}
    ${trnTime}=   Random Int   min=10   max=10
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${trnTime}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[0]}   ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY}=  db.get_date_by_timezone  ${tz}

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
    sleep  03s
    
    Comment  Check waiting time of every waitlist
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=10
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=10
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=10

    change_system_time  0  2
    Comment  Check waiting time of every waitlist
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=8
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=8
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=8

    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  03s

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=8
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=8
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=8

    change_system_time  0  5
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=3
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=3
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=3

    Set Test Variable  ${delay}  30
    ${resp}=  Add Delay  ${qid}  ${delay}  ${None}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Delay  ${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  delayDuration=${delay}
    sleep  02s

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=33
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=33
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=33

    change_system_time  0  3
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=30
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=30
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=30

    ${cid3}=  get_id  ${CUSERNAME3}
    ${resp}=  Add To Waitlist  ${cid3}  ${sId_2}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid5}  ${wid[0]}

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=30
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=30
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=30
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=37

    Set Test Variable  ${delay}  0
    ${resp}=  Add Delay  ${qid}  ${delay}  ${None}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Delay  ${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  delayDuration=${delay}
    sleep  02s

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=7

    change_system_time  0  3
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${wid12}
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=7

    ${resp}=  Add To Waitlist  ${cid3}  ${sId_1}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid6}  ${wid[0]}

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=7
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=10
    ${word}=  FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${wid5}  ${waitlist_cancl_reasn[5]}  ${word}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=  Get Waitlist By Id  ${wid5}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[4]}


    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=10
    
    change_system_time  0  3
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=7
    
    ${resp}=  Waitlist Action  ${waitlist_actions[3]}  ${wid5}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  04s
    ${resp}=  Get Waitlist By Id  ${wid15}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=4
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=7
    change_system_time  0  2

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=2
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=5

    ${cid3}=  get_id  ${CUSERNAME7}
    ${resp}=  Add To Waitlist  ${cid3}  ${sId_1}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid7}  ${wid[0]}
    sleep  02s

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=2
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=5
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=10
    

JD-TC-High Level Test Case-4
    [Documentation]  Checking the appxWaitingTime when timer is working and cancel a waitlist and add a delay after cancel a waitlist
    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_service   ${PUSERNAME42} 
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
    clear_location  ${PUSERNAME42}
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
    ${eTime}=  add_timezone_time  ${tz}   0  100
    Set Suite Variable   ${eTime}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  2s
    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()[0]['id']}
    ${trnTime}=   Random Int   min=10   max=10
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${trnTime}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[0]}   ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY}=  db.get_date_by_timezone  ${tz}

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
    sleep  03s
    
    Comment  Check waiting time of every waitlist
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=10
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=10
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=10

    change_system_time  0  2
    Comment  Check waiting time of every waitlist
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=8
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=8
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=8

    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  03s

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=8
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=8
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=8

    change_system_time  0  5
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=3
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=3
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=3

    ${cid3}=  get_id  ${CUSERNAME3}
    ${resp}=  Add To Waitlist  ${cid3}  ${sId_1}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid5}  ${wid[0]}

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=3
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=3
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=3
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=10
    ${word}=  FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${wid4}  ${waitlist_cancl_reasn[5]}  ${word}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=  Get Waitlist By Id  ${wid4}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[4]}


    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=3
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=3
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=10

    change_system_time  0  2
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=1
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=1
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=8
    Set Test Variable  ${delay}  30
    ${resp}=  Add Delay  ${qid}  ${delay}  ${None}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Delay  ${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  delayDuration=${delay}
    sleep  02s

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=31
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=31
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=38

    change_system_time  0  5
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=26
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=26
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=33

    ${resp}=  Waitlist Action  ${waitlist_actions[3]}  ${wid4}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  04s
    ${resp}=  Get Waitlist By Id  ${wid4}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=26
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=26
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=26
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=33
    
    ${resp}=  Add To Waitlist  ${cid3}  ${sId_2}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid6}  ${wid[0]}

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=26
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=26
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=26
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=33
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=35
    Set Test Variable  ${delay}  0
    ${resp}=  Add Delay  ${qid}  ${delay}  ${None}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Delay  ${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  delayDuration=${delay}
    sleep  02s

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=3
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=10
    
    change_system_time  0  3
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=7

    ${cid3}=  get_id  ${CUSERNAME4}
    ${resp}=  Add To Waitlist  ${cid3}  ${sId_1}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid7}  ${wid[0]}
    sleep  02s

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=7
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=10