*** Settings ***
Suite Teardown    resetsystem_time
Test Teardown     Delete All Sessions
Force Tags        Delay
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

JD-TC-AddDelay-1
      [Documentation]   Continuesly adding delay on a account
      # ${resp}=  ProviderLogin  ${PUSERNAME10}  ${PASSWORD}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # clear_service   ${PUSERNAME10} 
      # ${description}=  FakerLibrary.sentence
      # ${ser_dutratn}=   Random Int   min=10   max=10
      # ${total_amount1}=  Random Int   min=100  max=500
      # ${min_prepayment}=   Random Int   min=10  max=50
      # ${resp}=  Create Service  ${SERVICE1}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${EMPTY}  ${total_amount1}  ${bool[0]}  ${bool[0]}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Set Test Variable  ${s_id}  ${resp.json()}
      # clear_location  ${PUSERNAME10}
      # Create Sample Location
      # Sleep  2s
      # ${resp}=  Get Queues
      # Log  ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Set Suite Variable  ${qid}  ${resp.json()[0]['id']}

      ${resp}=  ProviderLogin  ${PUSERNAME136}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${pid}  ${resp.json()['id']}
      Set Test Variable  ${bname}  ${resp.json()['userName']}

      ${resp}=   Get jaldeeIntegration Settings
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
      ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
      Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
      Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

      ${resp}=   Get jaldeeIntegration Settings
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  
      Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

      ${pid1}=  get_acc_id  ${PUSERNAME136}
      clear_service   ${PUSERNAME136}
      clear_location  ${PUSERNAME136}
      clear_queue  ${PUSERNAME136}
      clear_customer   ${PUSERNAME136}
      ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  0  true  true  true  true  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${DAY1}=  get_date
      ${DAY2}=  add_date  70      
      ${list}=  Create List  1  2  3  4  5  6  7
      ${city}=   FakerLibrary.state
      ${latti}=  get_latitude
      ${longi}=  get_longitude
      ${postcode}=  FakerLibrary.postcode
      ${address}=  get_address
      ${parking}    Random Element     ${parkingType}
      ${24hours}    Random Element    ${bool}
      ${sTime}=  add_time  1  15
      ${eTime}=  add_time   3  30
      
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${lid}  ${resp.json()}

      ${sTime1}=  subtract_time  2  00
      ${eTime1}=  add_time   3  30
      Set Test Variable  ${qTime}   ${sTime1}-${eTime1}

      # ${SERVICE1}=  FakerLibrary.name
      # ${s_id}=  Create Sample Service  ${SERVICE1}
      # Set Test Variable  ${s_id}

      ${description}=  FakerLibrary.sentence
      ${ser_dutratn}=   Random Int   min=10   max=10
      ${total_amount1}=  Random Int   min=100  max=500
      ${min_prepayment}=   Random Int   min=10  max=50
      ${resp}=  Create Service  ${SERVICE1}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${EMPTY}  ${total_amount1}  ${bool[0]}  ${bool[0]}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${s_id}  ${resp.json()}

      ${queue_name}=  FakerLibrary.bs
      ${parallel}=   Random Int  min=1   max=1
      ${capacity}=  Random Int   min=10   max=20
      ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${qid}  ${resp.json()}

      # ${trnTime}=   Random Int   min=10   max=20
      # ${resp}=  Update Waitlist Settings  ${calc_mode[0]}   ${trnTime}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[0]}   ${EMPTY}
      # Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME1}  
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cId}  ${resp.json()}

      # ${cId}=  get_id  ${CUSERNAME1}
      ${DAY}=  get_date
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cId}  ${s_id}  ${qid}  ${DAY}  ${desc}  ${bool[1]}  ${cId}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id}  ${wid[0]}

      ${resp}=  AddCustomer  ${CUSERNAME2}  
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid2}  ${resp.json()}

      # ${cid2}=  get_id  ${CUSERNAME2}
      ${resp}=  Add To Waitlist  ${cid2}  ${s_id}  ${qid}  ${DAY}  ${desc}  ${bool[1]}  ${cid2}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id1}  ${wid[0]}

      ${resp}=  AddCustomer  ${CUSERNAME4}  
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid4}  ${resp.json()}

      # ${cid}=  get_id  ${CUSERNAME4}
      ${resp}=  Add To Waitlist  ${cid4}  ${s_id}  ${qid}  ${DAY}  ${desc}  ${bool[1]}  ${cid4}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id2}  ${wid[0]}

      ${resp}=  AddCustomer  ${CUSERNAME3}  
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid3}  ${resp.json()}

      # ${cid2}=  get_id  ${CUSERNAME3}
      ${resp}=  Add To Waitlist  ${cid3}  ${s_id}  ${qid}  ${DAY}  ${desc}  ${bool[1]}  ${cid3}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id3}  ${wid[0]}

      sleep  02s
      ${resp}=  Get Waitlist Today  queue-eq=${qid}
      Should Be Equal As Strings  ${resp.status_code}  200 
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}  appxWaitingTime=0
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id1}  appxWaitingTime=10
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id2}  appxWaitingTime=20
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id3}  appxWaitingTime=30
      Set Test Variable  ${dtime}  15
      ${resp}=  Add Delay  ${qid}  ${dtime}  ${None}  ${bool[1]}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Delay  ${qid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  delayDuration=${dtime}
      sleep  02s

      ${resp}=  Get Waitlist Today  queue-eq=${qid}
      Should Be Equal As Strings  ${resp.status_code}  200 
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}  appxWaitingTime=15
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id1}  appxWaitingTime=25
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id2}  appxWaitingTime=35
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id3}  appxWaitingTime=45

      change_system_time  0  3

      ${resp}=  Add Delay  ${qid}  10  ${None}  ${bool[1]}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Delay  ${qid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  delayDuration=10
      sleep  02s

      ${resp}=  Get Waitlist Today  queue-eq=${qid}
      Should Be Equal As Strings  ${resp.status_code}  200 
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}  appxWaitingTime=7
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id1}  appxWaitingTime=17
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id2}  appxWaitingTime=27
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id3}  appxWaitingTime=37

      change_system_time  0  3

      ${resp}=  Add Delay  ${qid}  5  ${None}  ${bool[1]}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Delay  ${qid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  delayDuration=5
      sleep  02s

      ${resp}=  Get Waitlist Today  queue-eq=${qid}
      Should Be Equal As Strings  ${resp.status_code}  200 
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}  appxWaitingTime=0
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id1}  appxWaitingTime=9
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id2}  appxWaitingTime=19
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id3}  appxWaitingTime=29

      change_system_time  0  3

      ${resp}=  Add Delay  ${qid}  0  ${None}  ${bool[1]}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Delay  ${qid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  delayDuration=0
      sleep  02s

      ${resp}=  Get Waitlist Today  queue-eq=${qid}
      Should Be Equal As Strings  ${resp.status_code}  200 
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}  appxWaitingTime=0
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id1}  appxWaitingTime=1
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id2}  appxWaitingTime=11
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id3}  appxWaitingTime=21
     change_system_time  0  3

      ${resp}=  Add Delay  ${qid}  20  ${None}  ${bool[1]}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Delay  ${qid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  delayDuration=20
      sleep  02s

      ${resp}=  Get Waitlist Today  queue-eq=${qid}
      Should Be Equal As Strings  ${resp.status_code}  200 
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}  appxWaitingTime=20
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id1}  appxWaitingTime=20
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id2}  appxWaitingTime=28
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id3}  appxWaitingTime=38


      change_system_time  0  3

      ${resp}=  Add Delay  ${qid}  0  ${None}  ${bool[1]}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Delay  ${qid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  delayDuration=0
      sleep  02s

      ${resp}=  Get Waitlist Today  queue-eq=${qid}
      Should Be Equal As Strings  ${resp.status_code}  200 
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}  appxWaitingTime=0
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id1}  appxWaitingTime=0
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id2}  appxWaitingTime=5
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id3}  appxWaitingTime=15

      change_system_time  0  3
      
      ${resp}=  AddCustomer  ${CUSERNAME5}  
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid5}  ${resp.json()}

      # ${cid2}=  get_id  ${CUSERNAME5}
      ${resp}=  Add To Waitlist  ${cid5}  ${s_id}  ${qid}  ${DAY}  ${desc}  ${bool[1]}  ${cid5}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id4}  ${wid[0]}

      ${resp}=  Get Waitlist Today  queue-eq=${qid}
      Should Be Equal As Strings  ${resp.status_code}  200 
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}  appxWaitingTime=0
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id1}  appxWaitingTime=0
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id2}  appxWaitingTime=2
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id3}  appxWaitingTime=12
      Verify Response List  ${resp}  4  ynwUuid=${waitlist_id4}  appxWaitingTime=40
      change_system_time  0  2

      ${resp}=  Waitlist Action  STARTED  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep  03s
      ${resp}=  Get Waitlist Today  queue-eq=${qid}
      Should Be Equal As Strings  ${resp.status_code}  200 
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id1}  appxWaitingTime=0
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id2}  appxWaitingTime=10
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id3}  appxWaitingTime=20
      Verify Response List  ${resp}  4  ynwUuid=${waitlist_id4}  appxWaitingTime=30

      change_system_time  0  5

      ${resp}=  Waitlist Action  STARTED  ${waitlist_id1}
      Should Be Equal As Strings  ${resp.status_code}  200

      sleep  03s
      
      ${resp}=  Get Waitlist Today  queue-eq=${qid}
      Should Be Equal As Strings  ${resp.status_code}  200 
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id2}  appxWaitingTime=0
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id3}  appxWaitingTime=5
      Verify Response List  ${resp}  4  ynwUuid=${waitlist_id4}  appxWaitingTime=10

      resetsystem_time