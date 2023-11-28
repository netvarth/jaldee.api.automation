*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Waitlist Settings
Library           Collections
Library           String
Library           json
Library           DateTime
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

       
*** Variables ***
${SERVICE1} 	   stuff
${SERVICE2} 	   SerUpdSett1
${SERVICE3} 	   SerUpdSett2
${SERVICE5} 	   SerUpdSett3
${loc}             EFGH
${queue1}          MorningQueue
${queue2}          AfternoonQueue
${queue3}          EveningQueue
${self}            0


*** Test Cases ***

JD-TC-UpdateWaitlistSettings-1
    [Documentation]  Update wailist settings using calculationMode as Fixed
    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${duration}=   Random Int  min=2  max=2
    Set Suite Variable   ${duration}
    
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${duration}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  calculationMode=${calc_mode[1]}  trnArndTime=${duration}  futureDateWaitlist=${bool[1]}  showTokenId=${bool[1]}  onlineCheckIns=${bool[1]}   maxPartySize=1
    
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${duration}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}   ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  calculationMode=${calc_mode[0]}  trnArndTime=0   futureDateWaitlist=${bool[1]}  showTokenId=${bool[0]}  onlineCheckIns=${bool[1]}  maxPartySize=1
    
    
JD-TC-UpdateWaitlistSettings-8
    [Documentation]  Update wailist settings using calculationMode as ML
    ${resp}=  Encrypted Provider Login  ${PUSERNAME23}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_queue     ${PUSERNAME23}
    clear_service   ${PUSERNAME23}
    clear_location   ${PUSERNAME23}
    clear_customer   ${PUSERNAME23}

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  30   ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  calculationMode=${calc_mode[0]}  trnArndTime=0  futureDateWaitlist=${bool[1]}  showTokenId=${bool[1]}  onlineCheckIns=${bool[1]} 
    # ${cid}=  get_id  ${CUSERNAME5}
    # Set Suite Variable  ${cid}  

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${description}=     FakerLibrary.sentence
    Set Suite Variable   ${description}
    Set Suite Variable  ${email}  ${P_Email}${cid}.${test_mail}
    # ${email}=    ${P_Email}${cid}.${test_mail}
    # set Suite Variable    ${email}

    # ${SERVICE1}=   FakerLibrary.name
    # ${s_id5}=  Create Sample Service  ${SERVICE1}
    # Set Suite Variable   ${s_id5}

    # ${SERVICE1}=   FakerLibrary.name
    # ${s_id6}=  Create Sample Service  ${SERVICE2}
    # Set Suite Variable   ${s_id6}

    ${lid5}=  Create Sample Location
    Set Suite Variable   ${lid5}

    ${resp}=  Create Service  ${SERVICE1}  ${description}   ${duration}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}   45  500  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id5}  ${resp.json()} 

    ${resp}=  Create Service  ${SERVICE2}  ${description}   ${duration}  ${status[0]}  ${bType}  ${bool[1]}   ${notifytype[2]}   45  500  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${s_id6}  ${resp.json()}
    # ${resp}=  Get Locations
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${lid5}  ${resp.json()[0]['id']}
    
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    Set Suite Variable   ${sTime}
    ${eTime}=   add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime}

    ${resp}=  Create Queue  ${queue1}  ${recurringtype[0]}   ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  8  ${lid5}  ${s_id5}  ${s_id6}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid5}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    # ${desc}=   FakerLibrary.word
    # ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=  Add To Waitlist  ${cid}  ${s_id5}  ${qid5}  ${DAY1}  ${description}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${waitlist_id}  ${wid[0]}
    #  ${cid1}=  get_id  ${CUSERNAME1}
    # Set Suite Variable  ${cid1}  ${cid1}

    ${resp}=  Add To Waitlist  ${cid1}  ${s_id5}  ${qid5}  ${DAY1}  ${description}  ${bool[1]}  ${cid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${waitlist_id1}  ${wid[0]}
    #  ${cid2}=  get_id  ${CUSERNAME2}
    # Set Suite Variable  ${cid2}  ${cid2}

    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid2}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid2}  ${s_id5}  ${qid5}  ${DAY1}  ${description}  ${bool[1]}  ${cid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${waitlist_id2}  ${wid[0]}
    # ${cid3}=  get_id  ${CUSERNAME3}
    # Set Suite Variable  ${cid2}  ${cid2}

    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid3}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid3}  ${s_id5}  ${qid5}  ${DAY1}  ${description}  ${bool[1]}  ${cid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${waitlist_id3}  ${wid[0]}
    ${resp}=  Get Queue ById  ${qid5}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=2  queueWaitingTime=8
    
    ${resp}=  Waitlist Action  STARTED  ${waitlist_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  03s
    ${resp}=  Get Queue ById  ${qid5}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=2  queueWaitingTime=6

    
    ${resp}=  Waitlist Action  STARTED  ${waitlist_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  05s
    ${resp}=  Get Queue ById  ${qid5}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=5  queueWaitingTime=0
    
    
    ${resp}=  Waitlist Action  STARTED  ${waitlist_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  05s
    ${resp}=  Get Queue ById  ${qid5}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=8  queueWaitingTime=8

    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${duration}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  calculationMode=${calc_mode[1]}  trnArndTime=${duration}  futureDateWaitlist=${bool[1]}  showTokenId=${bool[1]}  onlineCheckIns=${bool[1]}  
    ${resp}=  Add To Waitlist  ${cid}  ${s_id6}  ${qid5}  ${DAY1}  ${description}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${waitlist_id4}  ${wid[0]}
    ${resp}=  Get Queue ById  ${qid5}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=30  queueWaitingTime=30    
    
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  30  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  calculationMode=${calc_mode[0]}  trnArndTime=0  futureDateWaitlist=${bool[1]}  showTokenId=${bool[1]}  onlineCheckIns=${bool[1]}  

    
    ${resp}=  Waitlist Action  STARTED  ${waitlist_id3}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  05s
    ${resp}=  Get Queue ById  ${qid5}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=8  queueWaitingTime=8

    
    ${resp}=  Waitlist Action  STARTED  ${waitlist_id4}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  05s
    ${resp}=  Get Queue ById  ${qid5}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=8  queueWaitingTime=0


 
    

