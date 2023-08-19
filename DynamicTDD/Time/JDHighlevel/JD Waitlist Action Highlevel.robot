*** Settings ***
Suite Teardown    Run Keywords  Delete All Sessions  resetsystem_time
Test Teardown     Delete All Sessions
Force Tags        WailistAction   WaitingTime     
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
*** Test Cases ***

JD-TC-WaitlistactionHighlevel-1
      [Documentation]  Waitlist actions performing after add a delay
      ${resp}=  ProviderLogin  ${PUSERNAME55}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      clear_service   ${PUSERNAME55} 
      ${description}=  FakerLibrary.sentence
      ${ser_dutratn}=   Random Int   min=8   max=8
      ${total_amount1}=  Random Int   min=100  max=500
      ${min_prepayment}=   Random Int   min=10  max=50
      ${resp}=  Create Service  ${SERVICE1}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${EMPTY}  ${total_amount1}  ${bool[0]}  ${bool[0]}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${sId_1}  ${resp.json()}
      clear_location  ${PUSERNAME55}
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
       Set Test Variable  ${lid}  ${resp.json()}
      # Sleep  2s
      # ${resp}=  Get Queues
      # Log  ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Set Suite Variable  ${qid}  ${resp.json()[0]['id']}
      ${DAY2}=  add_date  10
      ${queue_name}=  FakerLibrary.bs
      ${parallel}=   Random Int  min=1   max=1
      ${capacity}=  Random Int   min=10   max=20
      ${sTime1}=  subtract_time  2  00
      ${eTime1}=  add_time   3  30
      Set Test Variable  ${qTime}   ${sTime1}-${eTime1}
      ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${sId_1}  
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${qid}  ${resp.json()}

      ${trnTime}=   Random Int   min=10   max=10
      ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${trnTime}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[0]}   ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${DAY}=  get_date

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

      # ${cid}=  get_id  ${CUSERNAME2}
      ${resp}=  AddCustomer   ${CUSERNAME2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid2}  ${wid[0]}
      
      # ${cid}=  get_id  ${CUSERNAME3}
      ${resp}=  AddCustomer   ${CUSERNAME3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid3}  ${wid[0]}

      # ${cid}=  get_id  ${CUSERNAME4}
      ${resp}=  AddCustomer   ${CUSERNAME4}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${wid4}  ${wid[0]}
      Sleep  3s
      ${resp}=  Get Waitlist Today  queue-eq=${qid}
      Should Be Equal As Strings  ${resp.status_code}  200 
      Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
      Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=10
      Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=10
      Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=10

      ${word}=  FakerLibrary.word
      ${resp}=  Waitlist Action Cancel  ${wid2}  ${waitlist_cancl_reasn[5]}  ${word}      
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist By Id  ${wid2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  waitlistStatus=${wl_status[4]}

      ${resp}=  Get Waitlist Today  queue-eq=${qid}
      Should Be Equal As Strings  ${resp.status_code}  200 
      Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
      Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
      Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=10
      Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=10

      Set Test Variable  ${delay}  30
      ${resp}=  Add Delay  ${qid}  ${delay}  ${None}  ${bool[1]}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Delay  ${qid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  delayDuration=${delay}
      sleep  02s

      ${resp}=  Get Waitlist Today  queue-eq=${qid}
      Should Be Equal As Strings  ${resp.status_code}  200 
      Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=30
      Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
      Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=40
      Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=40
      

      ${resp}=  Waitlist Action  ${waitlist_actions[3]}  ${wid2}
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep  03s
      ${resp}=  Get Waitlist By Id  ${wid2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  waitlistStatus=${wl_status[0]}

      ${resp}=  Get Waitlist Today  queue-eq=${qid}
      Should Be Equal As Strings  ${resp.status_code}  200 
      Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
      Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
      Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
      Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0
      
      ${word}=  FakerLibrary.word
      ${resp}=  Waitlist Action Cancel  ${wid3}  ${waitlist_cancl_reasn[5]}  ${word}      
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist By Id  ${wid3}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  waitlistStatus=${wl_status[4]}


      ${resp}=  Get Waitlist Today  queue-eq=${qid}
      Should Be Equal As Strings  ${resp.status_code}  200 
      Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=40
      Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=40
      Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
      Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=40

      Set Test Variable  ${delay}  0
      ${resp}=  Add Delay  ${qid}  ${delay}  ${None}  ${bool[1]}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Delay  ${qid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  delayDuration=${delay}
      sleep  02s

      ${resp}=  Get Waitlist Today  queue-eq=${qid}
      Should Be Equal As Strings  ${resp.status_code}  200 
      Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=10
      Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=10
      Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
      Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=10

      ${resp}=  Waitlist Action  ${waitlist_actions[3]}  ${wid3}
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep  02s
      ${resp}=  Get Waitlist By Id  ${wid2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  waitlistStatus=${wl_status[0]}

      ${resp}=  Get Waitlist Today  queue-eq=${qid}
      Should Be Equal As Strings  ${resp.status_code}  200 
      Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=10
      Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=10
      Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=10
      Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=10
      

JD-TC-WaitlistactionHighlevel-UH1
      [Documentation]  Waitlist actions performing before business hour(Action Started)
      ${resp}=  ProviderLogin  ${PUSERNAME55}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      change_system_time  0  -120

      ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid4}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_FUTURE_CANNOT_BE_STARTED}"
