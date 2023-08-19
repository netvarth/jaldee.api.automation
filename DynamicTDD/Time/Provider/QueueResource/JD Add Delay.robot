*** Settings ***
Suite Teardown    Run Keywords  Delete All Sessions  resetsystem_time
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
${SERVICE1}     Radio Repdca111

*** Test Cases ***

JD-TC-AddDelay-1
      [Documentation]   Add delay by enabling sendMessage and verifying notification sent to consumer
      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME160}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${pid}=  get_acc_id  ${PUSERNAME160}
      clear_service   ${PUSERNAME160}
      clear_location  ${PUSERNAME160}
      clear_queue  ${PUSERNAME160}
      ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  0  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${DAY1}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable  ${DAY1}  ${DAY1}
      ${DAY2}=  db.add_timezone_date  ${tz}  70      
      Set Suite Variable  ${DAY2}  ${DAY2}
      ${list}=  Create List  1  2  3  4  5  6  7
      Set Suite Variable  ${list}  ${list}
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
      ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
      Set Suite Variable  ${parking_type}
      ${24hours}    Random Element    ['True','False']
      Set Suite Variable  ${24hours}
      ${sTime}=  add_timezone_time  ${tz}  5  15  
      Set Suite Variable   ${sTime}
      ${eTime}=  add_timezone_time  ${tz}  6  30  
      Set Suite Variable   ${eTime}
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid}  ${resp.json()}
      ${sTime1}=  subtract_timezone_time  ${tz}  2  00
      Set Suite Variable   ${sTime1}
      ${eTime1}=  add_timezone_time  ${tz}  3  30  
      Set Suite Variable   ${eTime1}
      ${s_id1}=  Create Sample Service  ${SERVICE1}
      Set Suite Variable  ${s_id1}
      ${queue_name}=  FakerLibrary.bs
      ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${qid}  ${resp.json()}
      ${desc}=   FakerLibrary.word
      Set Suite Variable  ${desc}
      ${resp}=  Get Delay  ${qid}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid}  ${resp.json()}

      # ${cid}=  get_id  ${CUSERNAME1}
      ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id}  ${wid[0]}

      ${resp}=  AddCustomer  ${CUSERNAME2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid2}  ${resp.json()}

      # ${cid2}=  get_id  ${CUSERNAME2}
      ${resp}=  Add To Waitlist  ${cid2}  ${s_id1}  ${qid}  ${DAY1}  ${desc}  ${bool[1]}  ${cid2}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id2}  ${wid[0]}
      ${resp}=  Get Waitlist Today  queue-eq=${qid}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200 
      Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${waitlist_id}
      Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}  0
      Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${waitlist_id2}
      Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}  2

      clear_Consumermsg  ${CUSERNAME1}
      clear_Consumermsg  ${CUSERNAME2}
      ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${waitlist_id}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      # ${cid3}=  get_id  ${CUSERNAME3}
      ${resp}=  AddCustomer  ${CUSERNAME3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid3}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid3}  ${s_id1}  ${qid}  ${DAY1}  ${desc}  ${bool[1]}  ${cid3}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id3}  ${wid[0]}

      clear_Consumermsg  ${CUSERNAME3}
      ${delay_time}=   Random Int  min=10   max=40
      ${resp}=  Add Delay  ${qid}  ${delay_time}  ${None}  true
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Delay  ${qid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  delayDuration=${delay_time}
      ${resp}=  Get Business Profile
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${bname}  ${resp.json()['businessName']}
      ${resp}=   ProviderLogout
      Should Be Equal As Strings    ${resp.status_code}    200
      
      # sleep  05s
      ${resp}=  ConsumerLogin  ${CUSERNAME2}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${consumername}  ${resp.json()['userName']}
      ${resp}=  Get Consumer Communications
      Should Be Equal As Strings  ${resp.status_code}  200
      ${date}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
      ${delay_time}=   Convert To String  ${delay_time}
      ${msg}=  Replace String    ${delay_time}  [username]  ${consumername}
      ${msg}=  Replace String  ${msg}  [provider name]  ${bname}
      ${msg}=  Replace String  ${msg}  [service]  ${SERVICE1}
      ${msg}=  Replace String  ${msg}  [minutes]  ${delay_time}
      ${msg}=  Replace String  ${msg}  [time]  ${delay_time}
      Log  ${msg}
      Verify Response List  ${resp}  0  waitlistId=${waitlist_id2}  service=${SERVICE1} on ${date}  accountId=${pid}  msg=${msg} 
      Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  ${pid}
      Should Be Equal As Strings  ${resp.json()[0]['owner']['userName']}  ${bname} 
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${cid2}
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['userName']}  ${consumername}

      ${resp}=  Consumer Logout
      Should Be Equal As Strings    ${resp.status_code}    200
     
      ${resp}=  ConsumerLogin  ${CUSERNAME3}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${consumername}  ${resp.json()['userName']}
      ${resp}=  Get Consumer Communications
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${time}=  Evaluate  ${delay_time}+2
      ${time}=   Convert To String  ${time}
      ${msg}=  Replace String    ${delay}  [username]  ${consumername}
      ${msg}=  Replace String  ${msg}  [provider name]  ${bname}
      ${msg}=  Replace String  ${msg}  [service]  ${SERVICE1}
      ${msg}=  Replace String  ${msg}  [minutes]  ${delay_time}
      ${msg}=  Replace String  ${msg}  [time]  ${time}
      Verify Response List  ${resp}  0  waitlistId=${waitlist_id3}  service=${SERVICE1} on ${date}  accountId=${pid}  msg=${msg} 
      Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  ${pid}
      Should Be Equal As Strings  ${resp.json()[0]['owner']['userName']}  ${bname} 
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${cid3}
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['userName']}  ${consumername}
      ${resp}=  Consumer Logout
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=  Encrypted Provider Login  ${PUSERNAME160}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      change_system_time  0  5
      ${new_delay_time}=  Evaluate  ${delay_time}-5
      ${new_delay_time1}=  Evaluate  ${time}-5
      ${resp}=  Get Delay  ${qid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  delayDuration=${new_delay_time}

      ${resp}=  Get Waitlist By Id  ${waitlist_id2} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  appxWaitingTime=${new_delay_time}
      Verify Response  ${resp}  waitlistStatus=arrived
      ${resp}=  Get Waitlist By Id  ${waitlist_id3} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  appxWaitingTime=${new_delay_time1}
      Verify Response  ${resp}  waitlistStatus=arrived

      ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${waitlist_id2}
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep  02s
      ${resp}=  Get Waitlist By Id  ${waitlist_id3} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  appxWaitingTime=${new_delay_time}

      ${new_delay_time1}=  Evaluate  ${new_delay_time}+5
      ${cid4}=  get_id  ${CUSERNAME4}

      ${resp}=  AddCustomer  ${CUSERNAME4}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid4}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid4}  ${s_id1}  ${qid}  ${DAY1}  ${desc}  ${bool[1]}  ${cid4}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id4}  ${wid[0]}

      ${resp}=  Get Waitlist By Id  ${waitlist_id4} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  appxWaitingTime=${new_delay_time1}


      clear_Consumermsg  ${CUSERNAME3}
      clear_Consumermsg  ${CUSERNAME4}
      ${resp}=  Add Delay  ${qid}  0  ${None}  true
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Delay  ${qid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  delayDuration=0
      sleep  05s
      ${resp}=  Get Waitlist By Id  ${waitlist_id3} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  appxWaitingTime=0
      ${resp}=  Get Waitlist By Id  ${waitlist_id4} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  appxWaitingTime=5
      ${resp}=   ProviderLogout
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=  ConsumerLogin  ${CUSERNAME3}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${consumername}  ${resp.json()['userName']}
      ${new_delay_time}=   Convert To String  ${new_delay_time}
      ${msg}=  Replace String    ${delay_reduce}  [username]  ${consumername}
      ${msg}=  Replace String  ${msg}  [provider name]  ${bname}
      ${msg}=  Replace String  ${msg}  [service]  ${SERVICE1}
      ${msg}=  Replace String  ${msg}  [minutes]  ${new_delay_time}
      ${msg}=  Replace String  ${msg}  [wait/service]  wait
      ${msg}=  Replace String  ${msg}  [time]  0 mins
      ${resp}=  Get Consumer Communications
      Should Be Equal As Strings  ${resp.status_code}  200

      Verify Response List  ${resp}  0  waitlistId=${waitlist_id3}  service=${SERVICE1} on ${date}  accountId=${pid}  msg=${msg}  
      Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  ${pid}
      Should Be Equal As Strings  ${resp.json()[0]['owner']['userName']}  ${bname} 
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${cid3}
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['userName']}  ${consumername}
      ${resp}=  Consumer Logout
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=  ConsumerLogin  ${CUSERNAME4}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${consumername}  ${resp.json()['userName']}
      ${new_delay_time1}=   Convert To String  ${new_delay_time1}
      ${msg}=  Replace String    ${delay_reduce}  [username]  ${consumername}
      ${msg}=  Replace String  ${msg}  [provider name]  ${bname}
      ${msg}=  Replace String  ${msg}  [service]  ${SERVICE1}
      ${msg}=  Replace String  ${msg}  [minutes]  ${new_delay_time}
      ${msg}=  Replace String  ${msg}  [wait/service]  wait
      ${msg}=  Replace String  ${msg}  [time]  5 mins
      ${resp}=  Get Consumer Communications
      Should Be Equal As Strings  ${resp.status_code}  200

      Verify Response List  ${resp}  0  waitlistId=${waitlist_id4}  service=${SERVICE1} on ${date}  accountId=${pid}  msg=${msg}  
      Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  ${pid}
      Should Be Equal As Strings  ${resp.json()[0]['owner']['userName']}  ${bname} 
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${cid4}
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['userName']}  ${consumername}