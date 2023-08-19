*** Settings ***
Suite Teardown    Run Keywords  Delete All Sessions  resetsystem_time
Test Teardown     Delete All Sessions
Force Tags        ML   WaitingTime   
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
    ${resp}=  ProviderLogin  ${PUSERNAME50}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_service   ${PUSERNAME50} 
    ${description}=  FakerLibrary.sentence
    ${ser_dutratn1}=   Random Int   min=20   max=20
    ${ser_dutratn}=   Random Int   min=10   max=10
    ${total_amount1}=  Random Int   min=100  max=500
    ${min_prepayment}=   Random Int   min=10  max=50
    ${resp}=  Create Service  ${SERVICE1}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${EMPTY}  ${total_amount1}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_1}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE2}  ${description}   ${ser_dutratn1}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${EMPTY}  ${total_amount1}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_2}  ${resp.json()}
    clear_location  ${PUSERNAME50}
    ${city}=   get_place
    Set Suite Variable  ${city}
    ${latti}=  get_latitude
    Set Suite Variable  ${latti}
    ${longi}=  get_longitude
    Set Suite Variable  ${longi}
    ${postcode}=  FakerLibrary.postcode
    Set Suite Variable  ${postcode}
    ${address}=  get_address
    Set Suite Variable  ${address}
    ${parking}    Random Element   ${parkingType}
    Set Suite Variable  ${parking}
    ${24hours}    Random Element    ${bool}
    Set Suite Variable  ${24hours}
    ${DAY}=  get_date
    Set Suite Variable  ${DAY}
	${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime}=  db.get_time
    Set Suite Variable   ${sTime}
    ${eTime}=  add_time   0  100
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
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}   ${trnTime}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[0]}   ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY}=  get_date

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
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=15
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=30
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=45
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=60
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=75

    change_system_time  0  5
    Comment  Check waiting time of every waitlist
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=10
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=25
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=40
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=55
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=70

    change_system_time  0  2
    Comment  Check waiting time of every waitlist
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=8
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=23
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=38
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=53
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=68

    change_system_time  0  3
    Comment  Check waiting time of every waitlist
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=5
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=20
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=35
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=50
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=65
    

JD-TC-High Level Test Case-2
	[Documentation]  Checking the appxWaitingTime when timer is working
    ${resp}=  ProviderLogin  ${PUSERNAME52}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_service   ${PUSERNAME52} 
    ${description}=  FakerLibrary.sentence
    ${ser_dutratn1}=   Random Int   min=20   max=20
    ${ser_dutratn}=   Random Int   min=10   max=10
    ${total_amount1}=  Random Int   min=100  max=500
    ${min_prepayment}=   Random Int   min=10  max=50
    ${resp}=  Create Service  ${SERVICE1}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${EMPTY}  ${total_amount1}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_1}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE2}  ${description}   ${ser_dutratn1}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${EMPTY}  ${total_amount1}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_2}  ${resp.json()}
    clear_location  ${PUSERNAME52}
    ${city}=   get_place
    Set Suite Variable  ${city}
    ${latti}=  get_latitude
    Set Suite Variable  ${latti}
    ${longi}=  get_longitude
    Set Suite Variable  ${longi}
    ${postcode}=  FakerLibrary.postcode
    Set Suite Variable  ${postcode}
    ${address}=  get_address
    Set Suite Variable  ${address}
    ${parking}    Random Element   ${parkingType}
    Set Suite Variable  ${parking}
    ${24hours}    Random Element    ${bool}
    Set Suite Variable  ${24hours}
    ${DAY}=  get_date
    Set Suite Variable  ${DAY}
	${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime}=  db.get_time
    Set Suite Variable   ${sTime}
    ${eTime}=  add_time   0  100
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
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}   ${trnTime}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[0]}   ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY}=  get_date

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
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=15
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=30
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=45

    change_system_time  0  2
    Comment  Check waiting time of every waitlist
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=13
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=28
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=43
    
    ${cid2}=  get_id  ${CUSERNAME5}
    ${resp}=  Add To Waitlist  ${cid2}  ${sId_1}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid5}  ${wid[0]}

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=13
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=28
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=43
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=60

    change_system_time  0  5
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=8
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=23
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=38
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=55

    ${resp}=  Add To Waitlist  ${cid2}  ${sId_2}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid6}  ${wid[0]}

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=8
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=23
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=38
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=55
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=75

    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    change_system_time  0  5
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  03s

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=5
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=10
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=15


    change_system_time  0  3
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=2
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=7
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=12
   
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  03s
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=4
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=8

    change_system_time  0  3
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=1
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=5

    ${cid3}=  get_id  ${CUSERNAME3}
    ${resp}=  Add To Waitlist  ${cid3}  ${sId_2}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid7}  ${wid[0]}

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=1
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=5
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=12


    change_system_time  0  3
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=2
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=9
    
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid4}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  02s

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=5
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=10
 
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
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=30
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=35
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=40

    change_system_time  0  5
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=25
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=30
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=35

    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid5}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=25
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=30
    
    ${resp}=  Add To Waitlist  ${cid3}  ${sId_1}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid8}  ${wid[0]}
    sleep  02s

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=25
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=30
    Verify Response List  ${resp}  7  ynwUuid=${wid8}  appxWaitingTime=35

    change_system_time  0  5
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=20
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=25
    Verify Response List  ${resp}  7  ynwUuid=${wid8}  appxWaitingTime=30
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
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=0
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=0
    Verify Response List  ${resp}  7  ynwUuid=${wid8}  appxWaitingTime=5

    change_system_time  0  5
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=0
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=0
    Verify Response List  ${resp}  7  ynwUuid=${wid8}  appxWaitingTime=0

    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid6}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=0
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=0
    Verify Response List  ${resp}  7  ynwUuid=${wid8}  appxWaitingTime=6

    ${cid3}=  get_id  ${CUSERNAME4}
    ${resp}=  Add To Waitlist  ${cid3}  ${sId_1}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid9}  ${wid[0]}

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=0
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=0
    Verify Response List  ${resp}  7  ynwUuid=${wid8}  appxWaitingTime=6
    Verify Response List  ${resp}  8  ynwUuid=${wid9}  appxWaitingTime=12

	Comment  Checking the appxWaitingTime when timer is working and cancel a waitlist
    ${word}=  FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${wid8}  ${waitlist_cancl_reasn[5]}  ${word}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=  Get Waitlist By Id  ${wid8}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[4]}

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=0
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=0
    Verify Response List  ${resp}  7  ynwUuid=${wid8}  appxWaitingTime=0
    Verify Response List  ${resp}  8  ynwUuid=${wid9}  appxWaitingTime=6

    change_system_time  0  5
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=0
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=0
    Verify Response List  ${resp}  7  ynwUuid=${wid8}  appxWaitingTime=0
    Verify Response List  ${resp}  8  ynwUuid=${wid9}  appxWaitingTime=1

    ${resp}=  Waitlist Action  ${waitlist_actions[3]}  ${wid8}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=  Get Waitlist By Id  ${wid8}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=0
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=0
    Verify Response List  ${resp}  7  ynwUuid=${wid8}  appxWaitingTime=1
    Verify Response List  ${resp}  8  ynwUuid=${wid9}  appxWaitingTime=7


    ${resp}=  Add To Waitlist  ${cid3}  ${sId_2}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid10}  ${wid[0]}
    sleep  02s

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=0
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=0
    Verify Response List  ${resp}  7  ynwUuid=${wid8}  appxWaitingTime=1
    Verify Response List  ${resp}  8  ynwUuid=${wid9}  appxWaitingTime=7
    Verify Response List  ${resp}  9  ynwUuid=${wid10}  appxWaitingTime=18