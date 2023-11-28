*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        WaitingTime
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Suite Setup     Run Keywords  clear_queue  ${PUSERNAME171}  AND  clear_queue  ${PUSERNAME172}   AND  clear_location  ${PUSERNAME172}  AND  clear_location  ${PUSERNAME171}  AND  clear_service  ${PUSERNAME171}  AND  clear_service  ${PUSERNAME172}  AND  clear_service  ${PUSERNAME173}  AND  clear_location  ${PUSERNAME173}  AND  clear_queue  ${PUSERNAME173}

*** Variables ***
${SERVICE1}  Makeup  
${SERVICE2}  Hair makeup
${self}      0

*** Test Cases ***

JD-TC-GetQueueWaitingTime-1
      [Documentation]   Get queue waiting time when calculation mode as Fixed
      ${resp}=  Encrypted Provider Login  ${PUSERNAME171}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      clear_service   ${PUSERNAME171}
      clear_location  ${PUSERNAME171}
      clear_queue  ${PUSERNAME171}
      clear_customer   ${PUSERNAME171}
      ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  10  true  true  true  true  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${lid}=  Create Sample Location
      Set Suite Variable  ${lid}
      ${resp}=   Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
      ${s_id}=  Create Sample Service  ${SERVICE1}
      Set Suite Variable  ${s_id}
      ${s_id1}=  Create Sample Service  ${SERVICE2}
      Set Suite Variable  ${s_id1}
      ${DAY1}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable  ${DAY1}  ${DAY1}
      ${DAY2}=  db.add_timezone_date  ${tz}  10        
      Set Suite Variable  ${DAY2}  ${DAY2}
      ${list}=  Create List  1  2  3  4  5  6  7
      Set Suite Variable  ${list}  ${list}
      ${sTime1}=  db.subtract_timezone_time  ${tz}  1  00
      Set Suite Variable   ${sTime1}
      ${eTime1}=  add_timezone_time  ${tz}  0  30  
      Set Suite Variable   ${eTime1}
      ${queue_name}=  FakerLibrary.bs
      ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id}  ${s_id1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${qid1}  ${resp.json()}
      ${resp}=  AddCustomer  ${CUSERNAME1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid}  ${resp.json()}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id}  ${wid[0]}
      ${resp}=  AddCustomer  ${CUSERNAME2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid1}  ${resp.json()}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid1}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id1}  ${wid[0]}

      ${resp}=  Get Queue Waiting Time  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.json()}  10
      ${resp}=  Waitlist Action Cancel  ${waitlist_id1}  noshowup  hi
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action Cancel  ${waitlist_id}  noshowup  hi
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetQueueWaitingTime-2
      [Documentation]   Get queue waiting time after STARTED
      ${resp}=  Encrypted Provider Login  ${PUSERNAME171}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id}  ${wid[0]}
      ${resp}=  Get Queue Waiting Time  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  10
      ${resp}=  Waitlist Action  STARTED  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Waiting Time  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  0

JD-TC-GetQueueWaitingTime-3
      [Documentation]   Get Queue waiting time after CANCEL
      ${resp}=  Encrypted Provider Login  ${PUSERNAME171}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id}  ${wid[0]}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid1}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id1}  ${wid[0]}

      ${resp}=  Get Queue Waiting Time  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  10
      ${desc}=   FakerLibrary.word
      ${resp}=  Waitlist Action Cancel  ${waitlist_id1}  ${waitlist_cancl_reasn[2]}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Waiting Time  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  10
      ${resp}=  Waitlist Action Cancel  ${waitlist_id}  ${waitlist_cancl_reasn[2]}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Waiting Time  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  0
      
JD-TC-GetQueueWaitingTime-4
      [Documentation]   Get Queue waiting time after CHECK_IN
      ${resp}=  Encrypted Provider Login  ${PUSERNAME171}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id}  ${wid[0]}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid1}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id1}  ${wid[0]}
      
      ${resp}=  Get Queue Waiting Time  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  10
      ${desc}=   FakerLibrary.word
      ${resp}=  Waitlist Action Cancel  ${waitlist_id1}  ${waitlist_cancl_reasn[2]}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Waiting Time  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  10
      ${resp}=  Waitlist Action Cancel  ${waitlist_id}  ${waitlist_cancl_reasn[2]}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Waiting Time  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}   0
      ${resp}=  Waitlist Action  CHECK_IN  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Waiting Time  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  10
      ${resp}=  Waitlist Action  CHECK_IN  ${waitlist_id1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Waiting Time  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  10

JD-TC-GetQueueWaitingTime-5
      [Documentation]   Get future queue waiting time 
      ${resp}=  Encrypted Provider Login  ${PUSERNAME171}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${DAY2}=  db.add_timezone_date  ${tz}  1  
      Set Suite Variable  ${DAY2}  ${DAY2}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY2}  ${desc}  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id}  ${wid[0]}
      ${resp}=  Get Queue Waiting Time  ${qid1}  ${DAY2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  10
      ${resp}=  Waitlist Action Cancel  ${waitlist_id}  ${waitlist_cancl_reasn[2]}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Waiting Time  ${qid1}  ${DAY2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  0


JD-TC-GetQueueWaitingTime-6
      [Documentation]   Get future queue waiting time after CANCEL
      ${resp}=  Encrypted Provider Login  ${PUSERNAME171}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY2}  ${desc}  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id}  ${wid[0]}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid1}  ${s_id1}  ${qid1}  ${DAY2}  ${desc}  ${bool[1]}  ${cid1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id1}  ${wid[0]}
      ${resp}=  Get Queue Waiting Time  ${qid1}  ${DAY2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  10
      ${resp}=  Waitlist Action Cancel  ${waitlist_id1}  ${waitlist_cancl_reasn[2]}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Waiting Time  ${qid1}  ${DAY2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  10
      ${resp}=  Waitlist Action Cancel  ${waitlist_id}  ${waitlist_cancl_reasn[2]}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Waiting Time  ${qid1}  ${DAY2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  0
      
JD-TC-GetQueueWaitingTime-7
      [Documentation]   Get future queue waiting time after CHECK_IN
      ${resp}=  Encrypted Provider Login  ${PUSERNAME171}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY2}  ${desc}  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id}  ${wid[0]}

      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid1}  ${s_id1}  ${qid1}  ${DAY2}  ${desc}  ${bool[1]}  ${cid1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id1}  ${wid[0]}
      ${resp}=  Get Queue Waiting Time  ${qid1}  ${DAY2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  10
      ${resp}=  Waitlist Action Cancel  ${waitlist_id1}  ${waitlist_cancl_reasn[2]}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Waiting Time  ${qid1}  ${DAY2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  10
      ${resp}=  Waitlist Action Cancel  ${waitlist_id}  ${waitlist_cancl_reasn[2]}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Waiting Time  ${qid1}  ${DAY2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  0
      ${resp}=  Waitlist Action  CHECK_IN  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Waiting Time  ${qid1}  ${DAY2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  10
      ${resp}=  Waitlist Action  CHECK_IN  ${waitlist_id1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Waiting Time  ${qid1}  ${DAY2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  10

JD-TC-GetQueueWaitingTime-8
      [Documentation]   Get queue waiting time when calulation mode as ML
      ${resp}=  Encrypted Provider Login  ${PUSERNAME172}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      clear_service   ${PUSERNAME172}
      clear_location  ${PUSERNAME172}
      clear_queue  ${PUSERNAME172}
      clear_customer   ${PUSERNAME172}
     
      ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  10  true  true  true  true  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${lid}=  Create Sample Location
      Set Suite Variable  ${lid}

      ${resp}=   Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

      ${desc}=   FakerLibrary.word
      ${total_amount}=  Random Int  min=100  max=500
      ${min_prepayment}=  Random Int   min=1   max=50
      ${service_durtn}=  Random Int   min=5   max=10
      Set Suite Variable  ${service_durtn}
      ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${service_durtn}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${s_id}  ${resp.json()} 
      ${queue_name}=  FakerLibrary.bs
      ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${qid1}  ${resp.json()}
     
      ${resp}=  AddCustomer  ${CUSERNAME1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid2}  ${resp.json()}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid2}  ${s_id}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid2}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id}  ${wid[0]}
      
      ${resp}=  AddCustomer  ${CUSERNAME2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid3}  ${resp.json()}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid3}  ${s_id}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid3}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id1}  ${wid[0]}
      ${WaitingTime}=  Evaluate  ${service_durtn}*2
      ${resp}=  Get Queue Waiting Time  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.json()}  ${WaitingTime}
      ${resp}=  Waitlist Action Cancel  ${waitlist_id1}  ${waitlist_cancl_reasn[2]}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action Cancel  ${waitlist_id}  ${waitlist_cancl_reasn[2]}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetQueueWaitingTime-9
      [Documentation]  Get queue waiting time when calulation mode as NoCalc
      ${resp}=  Encrypted Provider Login  ${PUSERNAME173}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      clear_service   ${PUSERNAME173}
      clear_location  ${PUSERNAME173}
      clear_queue  ${PUSERNAME173}
      clear_customer   ${PUSERNAME173}
      ${resp}=  Update Waitlist Settings  ${calc_mode[2]}  10  true  true  true  true  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${lid}=  Create Sample Location
      Set Suite Variable  ${lid}
      ${resp}=   Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

      ${desc}=   FakerLibrary.word
      ${total_amount}=  Random Int  min=100  max=500
      ${min_prepayment}=  Random Int   min=1   max=50
      ${service_durtn}=  Random Int   min=5   max=10
      Set Suite Variable  ${service_durtn}
      ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${service_durtn}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${s_id}  ${resp.json()} 
      ${queue_name}=  FakerLibrary.bs
      ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${qid1}  ${resp.json()}
     
      ${resp}=  AddCustomer  ${CUSERNAME1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid4}  ${resp.json()}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid4}  ${s_id}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid4}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id}  ${wid[0]}

      ${resp}=  Get Queue Waiting Time  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.json()}  0
     
      ${resp}=  AddCustomer  ${CUSERNAME3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid5}  ${resp.json()}
      ${resp}=  Add To Waitlist  ${cid5}  ${s_id}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid5}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id}  ${wid[0]}
      ${resp}=  Get Queue Waiting Time  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.json()}  0

JD-TC-GetQueueWaitingTime-UH1
      [Documentation]   Get Queue waiting time by Consumer login
      ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Waiting Time  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"
      
JD-TC-GetQueueWaitingTime-UH2
      [Documentation]   Get Queue waiting time without login
      ${resp}=  Get Queue Waiting Time  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.status_code}  419
      Should Be Equal As Strings  "${resp.json()}"     "${SESSION_EXPIRED}"
