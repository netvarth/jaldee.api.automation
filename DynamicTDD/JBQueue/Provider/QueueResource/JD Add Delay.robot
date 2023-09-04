*** Settings ***
Suite Teardown    Delete All Sessions
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
${self}         0
${start}    150

*** Test Cases ***

JD-TC-AddDelay-1
      [Documentation]   Add delay by enabling sendMessage and verifying notification sent to consumer
      ${resp}=  Encrypted Provider Login  ${PUSERNAME136}  ${PASSWORD}
      # Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${decrypted_data}=  db.decrypt_data  ${resp.content}
      Log  ${decrypted_data}
      Set Suite Variable  ${pid}  ${decrypted_data['id']}
      Set Suite Variable  ${bname}  ${decrypted_data['userName']}
      # Set Test Variable  ${pid}  ${resp.json()['id']}
      # Set Test Variable  ${bname}  ${resp.json()['userName']}
    
      ${resp}=   Get Business Profile
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${buss_name}  ${resp.json()['businessName']}
      Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

      ${resp}=   Get jaldeeIntegration Settings
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
      Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
      Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

      ${resp}=   Get jaldeeIntegration Settings
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

      ${pid1}=  get_acc_id  ${PUSERNAME136}
      clear_service   ${PUSERNAME136}
      clear_location  ${PUSERNAME136}
      clear_queue  ${PUSERNAME136}
      clear_customer   ${PUSERNAME136}
      ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  0  true  true  true  true  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${list}=  Create List  1  2  3  4  5  6  7
      Set Suite Variable  ${list}  ${list}
      # ${city}=   FakerLibrary.state
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
      ${parking}    Random Element     ${parkingType}
      Set Suite Variable  ${parking}
      ${24hours}    Random Element    ${bool}
      Set Suite Variable  ${24hours}
      ${DAY1}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable  ${DAY1} 
      ${DAY2}=  db.add_timezone_date  ${tz}  70      
      Set Suite Variable  ${DAY2}
      ${sTime}=  add_timezone_time  ${tz}  5  15  
      Set Suite Variable   ${sTime}
      ${eTime}=  add_timezone_time  ${tz}  6  30  
      Set Suite Variable   ${eTime}
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking}  ${24hours}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid}  ${resp.json()}
      ${sTime1}=  subtract_timezone_time  ${tz}  2  00
      Set Suite Variable   ${sTime1}
      ${eTime1}=  add_timezone_time  ${tz}  3  30  
      Set Suite Variable   ${eTime1}
      Set Test Variable  ${qTime}   ${sTime1}-${eTime1}
      ${SERVICE1}=  FakerLibrary.name
      Set Suite Variable   ${SERVICE1} 
      ${s_id1}=  Create Sample Service  ${SERVICE1}
      Set Suite Variable  ${s_id1}
      ${queue_name}=  FakerLibrary.bs
      ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${qid}  ${resp.json()}

      clear_Consumermsg  ${CUSERNAME31}
      clear_Consumermsg  ${CUSERNAME3}

      ${resp}=  Get Consumer By Id  ${CUSERNAME31}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${uname_c20}   ${resp.json()['userProfile']['firstName']} ${resp.json()['userProfile']['lastName']}
      Set Suite Variable  ${cname1}   ${resp.json()['userProfile']['firstName']}
      Set Suite Variable  ${lname1}   ${resp.json()['userProfile']['lastName']}

      ${resp}=  AddCustomer  ${CUSERNAME31}  firstName=${cname1}   lastName=${lname1}   
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid}  ${resp.json()}

      ${desc}=   FakerLibrary.word
      Set Suite Variable  ${desc}
      ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id}  ${wid[0]}

      ${resp}=   Get Waitlist EncodedId    ${waitlist_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      Set Suite Variable  ${W_encId1}  ${resp.json()}
     
      ${resp}=  Get Consumer By Id  ${CUSERNAME3}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${uname_c21}   ${resp.json()['userProfile']['firstName']} ${resp.json()['userProfile']['lastName']}
      Set Suite Variable  ${cname2}   ${resp.json()['userProfile']['firstName']}
      Set Suite Variable  ${lname2}   ${resp.json()['userProfile']['lastName']}

      ${resp}=  AddCustomer  ${CUSERNAME3}  firstName=${cname2}   lastName=${lname2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid2}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid2}  ${s_id1}  ${qid}  ${DAY1}  ${desc}  ${bool[1]}  ${cid2}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id2}  ${wid[0]}

      ${resp}=   Get Waitlist EncodedId    ${waitlist_id2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      Set Suite Variable  ${W_encId2}  ${resp.json()}
      # sleep  02s
      ${resp}=  Get Waitlist Today  queue-eq=${qid}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200 
      Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${waitlist_id}
      Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}  0
      Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${waitlist_id2}
      Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}  2
      
      ${resp}=  Waitlist Action  STARTED  ${waitlist_id}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep  02s
      ${resp}=  Get Waitlist By Id  ${waitlist_id}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  waitlistStatus=started

      ${resp}=  Get Consumer By Id  ${CUSERNAME4}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${uname_c22}   ${resp.json()['userProfile']['firstName']} ${resp.json()['userProfile']['lastName']}
      Set Suite Variable  ${cname3}   ${resp.json()['userProfile']['firstName']}
      Set Suite Variable  ${lname3}   ${resp.json()['userProfile']['lastName']}

      ${resp}=  AddCustomer  ${CUSERNAME4}   firstName=${cname3}   lastName=${lname3} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid3}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid3}  ${s_id1}  ${qid}  ${DAY1}  ${desc}  ${bool[1]}  ${cid3}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id3}  ${wid[0]}

      ${resp}=   Get Waitlist EncodedId    ${waitlist_id3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      Set Suite Variable  ${W_encId3}  ${resp.json()}

      clear_Consumermsg  ${CUSERNAME4}
      ${delay_time}=   Random Int  min=5   max=40
      ${prov_msg}=   FakerLibrary.word
      ${resp}=  Add Delay  ${qid}  ${delay_time}  ${prov_msg}  ${bool[1]}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Delay  ${qid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  delayDuration=${delay_time}
      
      # ${resp}=  Get Business Profile
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Set Suite Variable  ${bname1}  ${resp.json()['businessName']}

      ${resp}=  Get Appointment Messages
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}   200
      ${confirmwl_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 
      ${defDelayAdd_msg}=  Set Variable   ${resp.json()['delayMessages']['Consumer_APP']}

      ${resp}=   ProviderLogout
      Should Be Equal As Strings    ${resp.status_code}    200
      
      sleep  02s
      ${resp}=  ConsumerLogin  ${CUSERNAME3}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${rcid2}  ${resp.json()['id']}         
      Set Suite Variable  ${consumername}  ${resp.json()['userName']}
      
      ${provider_msg}=   Set Variable  Message from [providerName] : [message] 
      ${provider_msg}=   Replace String  ${provider_msg}  [providerName]   ${buss_name}
      ${provider_msg}=   Replace String  ${provider_msg}  [message]        ${prov_msg}

      ${date}=  Convert Date  ${DAY1}  result_format=%a, %d %b %Y
      ${hrs}  ${mins}=   Convert_hour_mins   ${delay_time}

      ${bookingid}=  Format String  ${bookinglink}  ${W_encId2}  ${W_encId2}
      ${defconfirm_msg}=  Replace String  ${confirmwl_push}  [consumer]   ${consumername}
      ${defcosnfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${W_encId2}
      
      ${msg}=  Replace String  ${defDelayAdd_msg}  [consumer]   ${consumername}
      ${msg}=  Replace String  ${msg}  [providerMessage]   ${provider_msg}
      ${msg}=  Replace String  ${msg}  [bookingId]   ${W_encId2}
      ${msg}=  Replace String  ${msg}  [delayType]   ${delayType[0]}
      ${msg}=  Replace String  ${msg}  [delaytime]   ${mins}${SPACE}mins

      ${resp}=  Get Consumer Communications
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      # ${date}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
      # ${delay_time}=   Convert To String  ${delay_time}
      # ${msg}=  Replace String    ${delay}  [username]  ${consumername}
      # ${msg}=  Replace String  ${msg}  [provider name]  ${bname1}
      # ${msg}=  Replace String  ${msg}  [service]  ${SERVICE1}
      # ${msg}=  Replace String  ${msg}  [minutes]  ${delay_time}
      # ${msg}=  Replace String  ${msg}  [time]  0 hrs ${delay_time}
      Log  ${msg}
      Verify Response List  ${resp}  1  waitlistId=${waitlist_id2}  service=${SERVICE1} on ${date}  accountId=${pid1}  msg=${msg} 
      Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  0
      # Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}  ${bname} 
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${rcid2}
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['name']}  ${consumername}

      # ${WaitlistNotify_msg1}=  Replace String  ${checkInML_push}  [username]   ${consumername} 
      # ${WaitlistNotify_msg1}=  Replace String  ${WaitlistNotify_msg1}  [date]   ${date}
      # ${WaitlistNotify_msg1}=  Replace String  ${WaitlistNotify_msg1}  [service]   ${SERVICE1}
      # ${WaitlistNotify_msg1}=  Replace String  ${WaitlistNotify_msg1}  [qTime]   ${qTime}
      # ${WaitlistNotify_msg1}=  Replace String  ${WaitlistNotify_msg1}  [wait/service]   service
      # ${WaitlistNotify_msg1}=  Replace String  ${WaitlistNotify_msg1}  [estTime]   ${eTime1}
      # ${WaitlistNotify_msg1}=  Replace String  ${WaitlistNotify_msg1}  [provider name]   ${bname1}


      ${resp}=  Consumer Logout
      Should Be Equal As Strings    ${resp.status_code}    200
     
      ${resp}=  ConsumerLogin  ${CUSERNAME4}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${rcid3}  ${resp.json()['id']}
      Set Suite Variable  ${consumername}  ${resp.json()['userName']}

      ${time}=  Evaluate  ${delay_time}+2
      ${time}=   Convert To String  ${time}
      ${hrs}  ${mins}=   Convert_hour_mins   ${delay_time}

      ${bookingid}=  Format String  ${bookinglink}  ${W_encId3}  ${W_encId3}
      ${defconfirm_msg}=  Replace String  ${confirmwl_push}  [consumer]   ${consumername}
      ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${W_encId3}
      
      ${msg}=  Replace String  ${defDelayAdd_msg}  [consumer]   ${consumername}
      ${msg}=  Replace String  ${msg}  [providerMessage]   ${provider_msg}
      ${msg}=  Replace String  ${msg}  [bookingId]   ${W_encId3}
      ${msg}=  Replace String  ${msg}  [delayType]   ${delayType[0]}
      ${msg}=  Replace String  ${msg}  [delaytime]   ${mins}${SPACE}mins
      
      sleep  3s
      ${resp}=  Get Consumer Communications
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      # ${time}=  Evaluate  ${delay_time}+2
      # ${time}=   Convert To String  ${time}
      # ${msg}=  Replace String    ${delay}  [username]  ${consumername}
      # ${msg}=  Replace String  ${msg}  [provider name]  ${bname1}
      # ${msg}=  Replace String  ${msg}  [service]  ${SERVICE1}
      # ${msg}=  Replace String  ${msg}  [minutes]  ${delay_time}
      # ${msg}=  Replace String  ${msg}  [time]  0 hrs ${time}
      Verify Response List  ${resp}  0  waitlistId=${waitlist_id3}  service=${SERVICE1} on ${date}  accountId=${pid1}  msg=${msg} 
      Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  0
      # Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}  ${bname} 
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${rcid3}
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['name']}  ${consumername}

      ${resp}=  Consumer Logout
      Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-AddDelay-2
      [Documentation]   Add delay by disabling sendMessage and verify no notification sent to consumer

      
      ${resp}=  ConsumerLogin  ${CUSERNAME31}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Consumer Communications
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      clear_Consumermsg  ${CUSERNAME31}
      ${resp}=  Get Consumer Communications
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  []
      ${resp}=  Consumer Logout
      Should Be Equal As Strings    ${resp.status_code}    200 
      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME136}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id2}  ${wid[0]}

      ${resp}=  Get Waitlist By Id  ${waitlist_id2}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep  02s
      
      ${resp}=  ConsumerLogin  ${CUSERNAME31}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Consumer Communications
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      clear_Consumermsg  ${CUSERNAME31}
      ${resp}=  Get Consumer Communications
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  []
      ${resp}=  Consumer Logout
      Should Be Equal As Strings    ${resp.status_code}    200 

      ${resp}=  Encrypted Provider Login  ${PUSERNAME136}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${delay_time}=   Random Int  min=5   max=15
      Set Suite Variable  ${delay_time2}  ${delay_time}
      ${resp}=  Add Delay  ${qid}  ${delay_time}  ${desc}  ${bool[0]} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Delay  ${qid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  delayDuration=${delay_time}
      ${resp}=   ProviderLogout
      Should Be Equal As Strings    ${resp.status_code}    200
      sleep  03s
      ${resp}=  ConsumerLogin  ${CUSERNAME31}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Consumer Communications
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  []
      ${resp}=  Consumer Logout
      Should Be Equal As Strings    ${resp.status_code}    200     

      ${resp}=  Encrypted Provider Login  ${PUSERNAME136}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200    
      ${resp}=  Waitlist Action Cancel  ${waitlist_id2}  ${waitlist_cancl_reasn[3]}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-AddDelay-3
      [Documentation]   Add delay with provider delay message and enabling send notification true
      ${resp}=  ConsumerLogin  ${CUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${C24_fname}  ${resp.json()['firstName']}
      Set Suite Variable  ${C24_lname}  ${resp.json()['lastName']}
      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME136}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${decrypted_data}=  db.decrypt_data  ${resp.content}
      Log  ${decrypted_data}
      Set Suite Variable  ${pid}  ${decrypted_data['id']}
      Set Suite Variable  ${bname}  ${decrypted_data['userName']}
      # Set Test Variable  ${pid}  ${resp.json()['id']}
      # Set Test Variable  ${bname}  ${resp.json()['userName']}
      ${pid1}=  get_acc_id  ${PUSERNAME136}

      ${resp}=  AddCustomer  ${CUSERNAME24}  firstName=${C24_fname}   lastName=${C24_lname}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid4}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid4}  ${s_id1}  ${qid}  ${DAY1}  ${desc}  ${bool[1]}  ${cid4}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid}  ${wid[0]}

      ${resp}=   Get Waitlist EncodedId    ${wid}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      Set Suite Variable  ${W_encId4}  ${resp.json()}

      clear_Consumermsg  ${CUSERNAME24}
      ${delay_time}=   Random Int  min=15   max=40
      Set Suite Variable  ${delay_time}
      ${resp}=  Add Delay  ${qid}  ${delay_time}  ${desc}  ${bool[1]} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Delay  ${qid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  delayDuration=${delay_time}

      ${resp}=  Get Appointment Messages
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}   200
      ${confirmwl_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 
      ${defDelayAdd_msg}=  Set Variable   ${resp.json()['delayMessages']['Consumer_APP']}

      ${resp}=   ProviderLogout
      Should Be Equal As Strings    ${resp.status_code}    200
      # sleep  03s
      ${resp}=  ConsumerLogin  ${CUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${consumername}  ${resp.json()['userName']}
      Set Suite Variable  ${rcid4}  ${resp.json()['id']}
    
      ${provider_msg}=   Set Variable  Message from [providerName] : [message] 
      ${provider_msg}=   Replace String  ${provider_msg}  [providerName]   ${buss_name}
      ${provider_msg}=   Replace String  ${provider_msg}  [message]        ${desc}

      # ${time_delay}=  Evaluate  ${delay_time}-${delay_time2}
      ${hrs}  ${mins}=   Convert_hour_mins   ${delay_time}

      ${bookingid}=  Format String  ${bookinglink}  ${W_encId4}  ${W_encId4}
      ${defconfirm_msg}=  Replace String  ${confirmwl_push}  [consumer]   ${consumername}
      ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${W_encId4}
      
      ${msg}=  Replace String  ${defDelayAdd_msg}  [consumer]   ${consumername}
      ${msg}=  Replace String  ${msg}  [providerMessage]   ${provider_msg}
      ${msg}=  Replace String  ${msg}  [bookingId]   ${W_encId4}
      ${msg}=  Replace String  ${msg}  [delayType]   ${delayType[0]}
      ${msg}=  Replace String  ${msg}  [delaytime]   ${mins}${SPACE}mins
      
      sleep   3s
      ${resp}=  Get Consumer Communications
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${date}=  Convert Date  ${DAY1}  result_format=%a, %d %b %Y
      # ${date}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
      Verify Response List  ${resp}  0  waitlistId=${wid}  service=${SERVICE1} on ${date}  accountId=${pid1}  msg=${msg}
      Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  0
      # Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}  ${bname} 
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${rcid4}
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['name']}  ${consumername}

JD-TC-AddDelay-4
      [Documentation]   Set delay to 0
      ${resp}=  Encrypted Provider Login  ${PUSERNAME136}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Add Delay  ${qid}  0  ${desc}  ${bool[1]} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Delay  ${qid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  delayDuration=0

JD-TC-AddDelay-UH1
      [Documentation]   Add delay using consumer login
      ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Add Delay  ${qid}  ${delay_time}  ${desc}  ${bool[1]}
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  "${resp.json()}"     "${LOGIN_NO_ACCESS_FOR_URL}"
      
JD-TC-AddDelay-UH2
      [Documentation]    Add delay using delay time greater than business time(assume business time is 8hrs)
      ${resp}=  Encrypted Provider Login  ${PUSERNAME136}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${delay_time}=   Random Int  min=400   max=500
      ${resp}=  Add Delay  ${qid}  ${delay_time}  ${desc}  ${bool[1]}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_DELAY_GREATER}"
      
JD-TC-AddDelay-UH3
      [Documentation]    Add delay after disabling Queue
      ${resp}=  Encrypted Provider Login  ${PUSERNAME136}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${list}=  Create List   1  2  3  4  5  6  7
      ${sTime2}=  subtract_timezone_time  ${tz}  5  00
      Set Suite Variable   ${sTime2}
      ${eTime2}=  subtract_timezone_time  ${tz}   4  30
      Set Suite Variable   ${eTime2}
      ${queue2}=  FakerLibrary.bs
      ${resp}=  Create Queue  ${queue2}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  1  15  ${lid}  ${s_id1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${qid2}  ${resp.json()}
      ${resp}=  Disable Queue  ${qid2}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Add Delay  ${qid2}  ${delay_time}  ${desc}  ${bool[1]}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_DISABLED}"

JD-TC-AddDelay-UH4
      [Documentation]    Add delay after disabling waitlist
      ${domresp}=  Get BusinessDomainsConf
      Should Be Equal As Strings  ${domresp.status_code}  200
      ${len}=  Get Length  ${domresp.json()}
      ${len}=  Evaluate  ${len}-1
      ${PUSERNAME}=  Evaluate  ${PUSERNAME}+401873
      Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
      Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${highest_package}=  get_highest_license_pkg
      ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME}   ${highest_package[0]}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Activation  ${PUSERNAME}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Set Credential  ${PUSERNAME}  ${PASSWORD}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      Set Suite Variable  ${PUSERNAME}
      Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME}${\n}  
      # ${resp}=  Disable Waitlist
      # Log  ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Create Sample Queue
      Set Suite Variable  ${qid5}   ${resp['queue_id']}
      ${resp}=  Add Delay  ${qid5}  ${delay_time}  ${desc}  ${bool[1]}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_NOT_ENABLED}"
      ${resp}=  Enable Waitlist
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-AddDelay-UH5
      [Documentation]    Add delay after disabling location
      
      ${domresp}=  Get BusinessDomainsConf
      Should Be Equal As Strings  ${domresp.status_code}  200
      ${len}=  Get Length  ${domresp.json()}
      ${len}=  Evaluate  ${len}-1
      ${PUSERNAME0}=  Evaluate  ${PUSERNAME}+50451222
      Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
      Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${highest_package}=  get_highest_license_pkg
      ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME0}   ${highest_package[0]}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Activation  ${PUSERNAME0}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Set Credential  ${PUSERNAME0}  ${PASSWORD}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      Set Suite Variable  ${PUSERNAME0}
      Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME0}${\n}  

      ${resp}=  Enable Waitlist
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep   01s

      ${pid0}=  get_acc_id  ${PUSERNAME0}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${lid22}=  Create Sample Location

      ${city}=   db.get_place
      ${latti}=  get_latitude
      ${longi}=  get_longitude
      ${postcode}=  FakerLibrary.postcode
      ${address}=  get_address
      ${parking}    Random Element     ${parkingType} 
      ${24hours}    Random Element    ['True','False']
      ${DAY}=  db.get_date_by_timezone  ${tz}
      ${list}=  Create List  1  2  3  4  5  6  7
      # ${sTime}=  db.get_time_by_timezone   ${tz}
      ${sTime}=  db.get_time_by_timezone  ${tz}
      ${eTime}=  add_timezone_time  ${tz}  0  15  
      ${url}=   FakerLibrary.url
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid3}  ${resp.json()}

      ${s_id5}=  Create Sample Service  ${SERVICE1}
      Set Suite Variable  ${s_id5}
      ${queue2}=  FakerLibrary.bs
      ${sTime2}=  add_timezone_time  ${tz}  7  00
      Set Suite Variable   ${sTime2}
      ${eTime2}=  add_timezone_time  ${tz}   7  05
      Set Suite Variable   ${eTime2}
      ${resp}=  Create Queue  ${queue2}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  1  15  ${lid3}  ${s_id5}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${qid3}  ${resp.json()}
      ${resp}=  Disable Location  ${lid3}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep  2s
      ${resp}=  Add Delay  ${qid3}  ${delay_time}  ${desc}  ${bool[1]}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${LOCATION_DISABLED}" 
      ${resp}=  Enable Location  ${lid3}
      Should Be Equal As Strings  ${resp.status_code}  200 
      sleep  2s 
      ${resp}=  Get Queue Location  ${lid3}
      Should Be Equal As Strings  ${resp.status_code}  200 
      Verify Response List  ${resp}  0  queueState=${Qstate[1]}
      
JD-TC-AddDelay-UH6
      [Documentation]    Add delay without login
      ${resp}=  Add Delay  ${qid}  ${delay_time}  ${desc}  ${bool[1]}
      Should Be Equal As Strings  ${resp.status_code}  419
      Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-AddDelay-UH7
      [Documentation]   Add delay to another provider's queue
      ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Add Delay  ${qid}  ${delay_time}  tech problem  false 
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

JD-TC-AddDelay-UH8
      [Documentation]    Add Delay performing after business hours
      ${resp}=  Encrypted Provider Login  ${PUSERNAME136}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${list}=  Create List  1  2  3  4  5  6  7
      # ${date}=  db.get_date_by_timezone  ${tz}
      ${queue2}=  FakerLibrary.bs
      ${sTime2}=  subtract_timezone_time  ${tz}  4   00
      Set Suite Variable   ${sTime2}
      ${eTime2}=  subtract_timezone_time  ${tz}   3  05
      Set Suite Variable   ${eTime2}
      ${resp}=  Create Queue  ${queue2}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  1  15  ${lid}  ${s_id1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${q_id}  ${resp.json()}
      ${resp}=  Add Delay  ${q_id}  ${delay_time}  ${desc}  ${bool[1]}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_DELAY_CANT_APPLY}"

JD-TC-AddDelay-5
      [Documentation]   Add delay by enabling sendMessage and verifying notification sent to consumer
      ${resp}=  ConsumerLogin  ${CUSERNAME16}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${C16_fname}  ${resp.json()['firstName']}
      Set Suite Variable  ${C16_lname}  ${resp.json()['lastName']}

      ${resp}=  ConsumerLogin  ${CUSERNAME3}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${C3_fname}  ${resp.json()['firstName']}
      Set Suite Variable  ${C3_lname}  ${resp.json()['lastName']}

      ${resp}=  ConsumerLogin  ${CUSERNAME4}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${C4_fname}  ${resp.json()['firstName']}
      Set Suite Variable  ${C4_lname}  ${resp.json()['lastName']}

      ${resp}=  ConsumerLogin  ${CUSERNAME14}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${C14_fname}  ${resp.json()['firstName']}
      Set Suite Variable  ${C14_lname}  ${resp.json()['lastName']}
      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${decrypted_data}=  db.decrypt_data  ${resp.content}
      Log  ${decrypted_data}
      Set Suite Variable  ${pid}  ${decrypted_data['id']}
      Set Suite Variable  ${bname}  ${decrypted_data['userName']}
      # Set Test Variable  ${pid}  ${resp.json()['id']}
      # Set Test Variable  ${bname}  ${resp.json()['userName']}
    
      ${resp}=   Get Business Profile
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${buss_name}  ${resp.json()['businessName']}

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

      clear_service   ${PUSERNAME2}
      clear_location  ${PUSERNAME2}
      clear_queue  ${PUSERNAME2}
      clear_customer   ${PUSERNAME2}
      clear_Consumermsg  ${CUSERNAME16}
      clear_Consumermsg  ${CUSERNAME3}
      clear_Consumermsg  ${CUSERNAME4}
      clear_Consumermsg  ${CUSERNAME14}
      ${pid1}=  get_acc_id  ${PUSERNAME2}
      ${duration}=   Random Int  min=2  max=10
      Set Suite Variable   ${duration}
      ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${duration}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}   ${Empty}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${DAY1}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable  ${DAY1}  ${DAY1}
      ${resp}=  Create Sample Queue
      Set Suite Variable  ${qid}   ${resp['queue_id']}
      Set Suite Variable  ${s_id1}   ${resp['service_id']}
      Set Suite Variable  ${Service_name}   ${resp['service_name']}
      ${resp}=  Get Queue ById  ${qid}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${sTime}  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}
      Set Test Variable  ${eTime}  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}
      clear_Providermsg  ${PUSERNAME2}
      

      ${resp}=  AddCustomer  ${CUSERNAME16}  firstName=${C16_fname}   lastName=${C16_lname}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid}  ${resp.json()}
  
      ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id}  ${wid[0]}

      ${resp}=   Get Waitlist EncodedId    ${waitlist_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      Set Suite Variable  ${Wl_encId1}  ${resp.json()}

      ${resp}=  AddCustomer  ${CUSERNAME3}  firstName=${C3_fname}   lastName=${C3_lname}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid2}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid2}  ${s_id1}  ${qid}  ${DAY1}  ${desc}  ${bool[1]}  ${cid2}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id2}  ${wid[0]}

      ${resp}=   Get Waitlist EncodedId    ${waitlist_id2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      Set Suite Variable  ${Wl_encId2}  ${resp.json()}

      ${resp}=  AddCustomer  ${CUSERNAME4}  firstName=${C4_fname}   lastName=${C4_lname}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid3}  ${resp.json()}

      sleep  02s
      ${resp}=  Add To Waitlist  ${cid3}  ${s_id1}  ${qid}  ${DAY1}  ${desc}  ${bool[1]}  ${cid3}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id3}  ${wid[0]}

      ${resp}=   Get Waitlist EncodedId    ${waitlist_id3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      Set Suite Variable  ${Wl_encId3}  ${resp.json()}

      ${resp}=  AddCustomer  ${CUSERNAME14}  firstName=${C14_fname}   lastName=${C14_lname}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid4}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid4}  ${s_id1}  ${qid}  ${DAY1}  ${desc}  ${bool[1]}  ${cid4}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id4}  ${wid[0]}
      sleep  02s

      ${resp}=   Get Waitlist EncodedId    ${waitlist_id4}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      Set Suite Variable  ${Wl_encId4}  ${resp.json()}

      ${resp}=  Get Waitlist Today  queue-eq=${qid}
      Should Be Equal As Strings  ${resp.status_code}  200 
      Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${waitlist_id}
      Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}  0
      Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${waitlist_id2}
      Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}  2
      Should Be Equal As Strings  ${resp.json()[2]['ynwUuid']}  ${waitlist_id3}
      Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}  4
      Should Be Equal As Strings  ${resp.json()[3]['ynwUuid']}  ${waitlist_id4}
      Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}  6
      
      # ${resp}=  Get Business Profile
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Set Test Variable  ${bname2}  ${resp.json()['businessName']}

      ${delay_time}=   Random Int  min=1   max=5
      ${prov_msg}=   FakerLibrary.word
      ${resp}=  Add Delay  ${qid}  ${delay_time}  ${prov_msg}  ${bool[1]}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Delay  ${qid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  delayDuration=${delay_time}

      ${resp}=  Get Appointment Messages
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}   200
      ${confirmwl_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 
      ${defDelayAdd_msg}=  Set Variable   ${resp.json()['delayMessages']['Consumer_APP']}

      ${resp}=   ProviderLogout
      Should Be Equal As Strings    ${resp.status_code}    200

      ${provider_msg}=   Set Variable  Message from [providerName] : [message] 
      ${provider_msg}=   Replace String  ${provider_msg}  [providerName]   ${buss_name}
      ${provider_msg}=   Replace String  ${provider_msg}  [message]        ${prov_msg}

      sleep  03s
      # ${date}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
      ${date}=  Convert Date  ${DAY1}  result_format=%a, %d %b %Y

      ${resp}=  ConsumerLogin  ${CUSERNAME16}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${rcid}  ${resp.json()['id']}  
      Set Suite Variable  ${consumername}  ${resp.json()['userName']}

      ${delay_time}=   Convert To String  ${delay_time}
      ${delay_time_first}=  add_two  ${sTime}  ${delay_time}
      # ${msg}=  Replace String    ${Add_delay}  [username]  ${consumername}
      # ${msg}=  Replace String  ${msg}  [provider name]  ${bname2}
      # ${msg}=  Replace String  ${msg}  [service]  ${Service_name}
      # ${msg}=  Replace String  ${msg}  [minutes]  ${delay_time}
      # ${msg}=  Replace String  ${msg}  [time]  ${delay_time_first}

      ${hrs}  ${mins}=   Convert_hour_mins   ${delay_time}

      ${bookingid}=  Format String  ${bookinglink}  ${Wl_encId1}  ${Wl_encId1}
      ${defconfirm_msg}=  Replace String  ${confirmwl_push}  [consumer]   ${consumername}
      ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${Wl_encId1}
      
      ${msg}=  Replace String  ${defDelayAdd_msg}  [consumer]   ${consumername}
      ${msg}=  Replace String  ${msg}  [providerMessage]   ${provider_msg}
      ${msg}=  Replace String  ${msg}  [bookingId]   ${Wl_encId1}
      ${msg}=  Replace String  ${msg}  [delayType]   ${delayType[0]}
      ${msg}=  Replace String  ${msg}  [delaytime]   ${mins}${SPACE}mins

      ${resp}=  Get Consumer Communications
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      Verify Response List  ${resp}  1  waitlistId=${waitlist_id}  service=${Service_name} on ${date}  accountId=${pid1}  msg=${msg}  
      Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  0
      # Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}  ${bname} 
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${rcid}
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['name']}  ${consumername}
      
      ${resp}=  ConsumerLogin  ${CUSERNAME3}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${consumername}  ${resp.json()['userName']}
      Set Suite Variable  ${rcid2}  ${resp.json()['id']}  

      ${delay_time1}=  Evaluate  ${delay_time}+2
      ${delay_time_first}=  add_two  ${sTime}  ${delay_time1}
      # ${msg}=  Replace String    ${Add_delay}  [username]  ${consumername}
      # ${msg}=  Replace String  ${msg}  [provider name]  ${bname2}
      # ${msg}=  Replace String  ${msg}  [service]  ${Service_name}
      # ${msg}=  Replace String  ${msg}  [minutes]  ${delay_time}
      # ${msg}=  Replace String  ${msg}  [time]  ${delay_time_first}

      ${hrs}  ${mins}=   Convert_hour_mins   ${delay_time}

      ${bookingid}=  Format String  ${bookinglink}  ${Wl_encId2}  ${Wl_encId2}
      ${defconfirm_msg}=  Replace String  ${confirmwl_push}  [consumer]   ${consumername}
      ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${Wl_encId2}
      
      ${msg}=  Replace String  ${defDelayAdd_msg}  [consumer]   ${consumername}
      ${msg}=  Replace String  ${msg}  [providerMessage]   ${provider_msg}
      ${msg}=  Replace String  ${msg}  [bookingId]   ${Wl_encId2}
      ${msg}=  Replace String  ${msg}  [delayType]   ${delayType[0]}
      ${msg}=  Replace String  ${msg}  [delaytime]   ${mins}${SPACE}mins

      ${resp}=  Get Consumer Communications
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      Verify Response List  ${resp}  1  waitlistId=${waitlist_id2}  service=${Service_name} on ${date}  accountId=${pid1}  msg=${msg}  
      Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  0
      # Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}  ${bname} 
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${rcid2}
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['name']}  ${consumername}

      ${resp}=  Consumer Logout
      Should Be Equal As Strings    ${resp.status_code}    200
     
      ${resp}=  ConsumerLogin  ${CUSERNAME4}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${consumername}  ${resp.json()['userName']}
      Set Suite Variable  ${rcid3}  ${resp.json()['id']}  

      ${delay_time1}=  Evaluate  ${delay_time}+4
      ${delay_time_first}=  add_two  ${sTime}  ${delay_time1}
      # ${msg}=  Replace String    ${Add_delay}  [username]  ${consumername}
      # ${msg}=  Replace String  ${msg}  [provider name]  ${bname2}
      # ${msg}=  Replace String  ${msg}  [service]  ${Service_name}
      # ${msg}=  Replace String  ${msg}  [minutes]  ${delay_time}
      # ${msg}=  Replace String  ${msg}  [time]  ${delay_time_first}

      ${hrs}  ${mins}=   Convert_hour_mins   ${delay_time}

      ${bookingid}=  Format String  ${bookinglink}  ${Wl_encId3}  ${Wl_encId3}
      ${defconfirm_msg}=  Replace String  ${confirmwl_push}  [consumer]   ${consumername}
      ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${Wl_encId3}
      
      ${msg}=  Replace String  ${defDelayAdd_msg}  [consumer]   ${consumername}
      ${msg}=  Replace String  ${msg}  [providerMessage]   ${provider_msg}
      ${msg}=  Replace String  ${msg}  [bookingId]   ${Wl_encId3}
      ${msg}=  Replace String  ${msg}  [delayType]   ${delayType[0]}
      ${msg}=  Replace String  ${msg}  [delaytime]   ${mins}${SPACE}mins

      ${resp}=  Get Consumer Communications
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      Verify Response List  ${resp}  1  waitlistId=${waitlist_id3}  service=${Service_name} on ${date}  accountId=${pid1}  msg=${msg}  
      Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  0
      # Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}  ${bname} 
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${rcid3}
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['name']}  ${consumername}

      ${resp}=  Consumer Logout
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=  ConsumerLogin  ${CUSERNAME14}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${consumername}  ${resp.json()['userName']}
      Set Suite Variable  ${rcid4}  ${resp.json()['id']} 

      ${delay_time1}=  Evaluate  ${delay_time}+6
      ${delay_time_first}=  add_two  ${sTime}  ${delay_time1}
      # ${msg}=  Replace String    ${Add_delay}  [username]  ${consumername}
      # ${msg}=  Replace String  ${msg}  [provider name]  ${bname2}
      # ${msg}=  Replace String  ${msg}  [service]  ${Service_name}
      # ${msg}=  Replace String  ${msg}  [minutes]  ${delay_time}
      # ${msg}=  Replace String  ${msg}  [time]  ${delay_time_first}

      ${hrs}  ${mins}=   Convert_hour_mins   ${delay_time}

      ${bookingid}=  Format String  ${bookinglink}  ${Wl_encId4}  ${Wl_encId4}
      ${defconfirm_msg}=  Replace String  ${confirmwl_push}  [consumer]   ${consumername}
      ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${Wl_encId4}
      
      ${msg}=  Replace String  ${defDelayAdd_msg}  [consumer]   ${consumername}
      ${msg}=  Replace String  ${msg}  [providerMessage]   ${provider_msg}
      ${msg}=  Replace String  ${msg}  [bookingId]   ${Wl_encId4}
      ${msg}=  Replace String  ${msg}  [delayType]   ${delayType[0]}
      ${msg}=  Replace String  ${msg}  [delaytime]   ${mins}${SPACE}mins

      ${resp}=  Get Consumer Communications
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      Verify Response List  ${resp}  1  waitlistId=${waitlist_id4}  service=${Service_name} on ${date}  accountId=${pid1}  msg=${msg}  
      Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  0
      # Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}  ${bname} 
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${rcid4}
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['name']}  ${consumername}

      ${resp}=  Consumer Logout
      Should Be Equal As Strings    ${resp.status_code}    200
      clear_Consumermsg  ${CUSERNAME16}
      clear_Consumermsg  ${CUSERNAME3}
      clear_Consumermsg  ${CUSERNAME4}
      clear_Consumermsg  ${CUSERNAME14}

      ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
    
      ${prov_msg}=   FakerLibrary.word
      ${resp}=  Add Delay  ${qid}  0  ${prov_msg}  true
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep  02s
      ${resp}=  Get Delay  ${qid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  delayDuration=0

      ${resp}=   ProviderLogout
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=  ConsumerLogin  ${CUSERNAME16}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${consumername}  ${resp.json()['userName']}
      Set Suite Variable  ${rcid}  ${resp.json()['id']}  

      # ${msg}=  Replace String    ${delay_reduce}  [username]  ${consumername}
      # ${msg}=  Replace String  ${msg}  [provider name]  ${bname2}
      # ${msg}=  Replace String  ${msg}  [service]  ${Service_name}
      # ${msg}=  Replace String  ${msg}  [minutes]  ${delay_time}
      # ${msg}=  Replace String  ${msg}  [wait/service]  service
      # ${msg}=  Replace String  ${msg}  [time]  ${sTime}
    
      ${provider_msg}=   Set Variable  Message from [providerName] : [message] 
      ${provider_msg}=   Replace String  ${provider_msg}  [providerName]   ${buss_name}
      ${provider_msg}=   Replace String  ${provider_msg}  [message]        ${prov_msg}
   
      ${hrs}  ${mins}=   Convert_hour_mins   0

      ${bookingid}=  Format String  ${bookinglink}  ${Wl_encId1}  ${Wl_encId1}
      ${defconfirm_msg}=  Replace String  ${confirmwl_push}  [consumer]   ${consumername}
      ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${Wl_encId1}
      
      ${msg}=  Replace String  ${defDelayAdd_msg}  [consumer]   ${consumername}
      ${msg}=  Replace String  ${msg}  [providerMessage]   ${provider_msg}
      ${msg}=  Replace String  ${msg}  [bookingId]   ${Wl_encId1}
      ${msg}=  Replace String  ${msg}  [delayType]   ${delayType[0]}
      ${msg}=  Replace String  ${msg}  [delaytime]   ${mins}

      ${resp}=  Get Consumer Communications
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      Verify Response List  ${resp}  0  waitlistId=${waitlist_id}  service=${Service_name} on ${date}  accountId=${pid1}  msg=${msg}
      Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  0
      # Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}  ${bname} 
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${rcid}
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['name']}  ${consumername}
      
      ${resp}=  Consumer Logout
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=  ConsumerLogin  ${CUSERNAME3}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${consumername}  ${resp.json()['userName']}
      Set Suite Variable  ${rcid2}  ${resp.json()['id']} 

      ${time_after_cancel}=  add_two  ${sTime}  2
      # ${msg}=  Replace String    ${delay_reduce}  [username]  ${consumername}
      # ${msg}=  Replace String  ${msg}  [provider name]  ${bname2}
      # ${msg}=  Replace String  ${msg}  [service]  ${Service_name}
      # ${msg}=  Replace String  ${msg}  [minutes]  ${delay_time}
      # ${msg}=  Replace String  ${msg}  [wait/service]  service
      # ${msg}=  Replace String  ${msg}  [time]  ${time_after_cancel}

      ${hrs}  ${mins}=   Convert_hour_mins   0

      ${bookingid}=  Format String  ${bookinglink}  ${Wl_encId2}  ${Wl_encId2}
      ${defconfirm_msg}=  Replace String  ${confirmwl_push}  [consumer]   ${consumername}
      ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${Wl_encId2}
      
      ${msg}=  Replace String  ${defDelayAdd_msg}  [consumer]   ${consumername}
      ${msg}=  Replace String  ${msg}  [providerMessage]   ${provider_msg}
      ${msg}=  Replace String  ${msg}  [bookingId]   ${Wl_encId2}
      ${msg}=  Replace String  ${msg}  [delayType]   ${delayType[1]}
      ${msg}=  Replace String  ${msg}  [delaytime]   ${mins}${SPACE}mins

      ${resp}=  Get Consumer Communications
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      Verify Response List  ${resp}  0  waitlistId=${waitlist_id2}  service=${Service_name} on ${date}  accountId=${pid1}  msg=${msg}   
      Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  0
      # Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}  ${bname} 
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${rcid2}
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['name']}  ${consumername}

      ${resp}=  Consumer Logout
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=  ConsumerLogin  ${CUSERNAME4}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${consumername}  ${resp.json()['userName']}
      Set Suite Variable  ${rcid3}  ${resp.json()['id']}  

      ${time_after_cancel}=  add_two  ${sTime}  4
      # ${msg}=  Replace String    ${delay_reduce}  [username]  ${consumername}
      # ${msg}=  Replace String  ${msg}  [provider name]  ${bname2}
      # ${msg}=  Replace String  ${msg}  [service]  ${Service_name}
      # ${msg}=  Replace String  ${msg}  [minutes]  ${delay_time}
      # ${msg}=  Replace String  ${msg}  [wait/service]  service
      # ${msg}=  Replace String  ${msg}  [time]  ${time_after_cancel}

      ${hrs}  ${mins}=   Convert_hour_mins   0

      ${bookingid}=  Format String  ${bookinglink}  ${Wl_encId3}  ${Wl_encId3}
      ${defconfirm_msg}=  Replace String  ${confirmwl_push}  [consumer]   ${consumername}
      ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${Wl_encId3}
      
      ${msg}=  Replace String  ${defDelayAdd_msg}  [consumer]   ${consumername}
      ${msg}=  Replace String  ${msg}  [providerMessage]   ${provider_msg}
      ${msg}=  Replace String  ${msg}  [bookingId]   ${Wl_encId3}
      ${msg}=  Replace String  ${msg}  [delayType]   ${delayType[1]}
      ${msg}=  Replace String  ${msg}  [delaytime]   ${mins}${SPACE}mins

      ${resp}=  Get Consumer Communications
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      Verify Response List  ${resp}  0  waitlistId=${waitlist_id3}  service=${Service_name} on ${date}  accountId=${pid1}  msg=${msg}
      Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  0
      # Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}  ${bname} 
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${rcid3}
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['name']}  ${consumername}

      ${resp}=  Consumer Logout
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=  ConsumerLogin  ${CUSERNAME14}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${consumername}  ${resp.json()['userName']}
      Set Suite Variable  ${rcid4}  ${resp.json()['id']}  

      # ${time_after_cancel}=  add_two  ${sTime}  6
      # ${msg}=  Replace String    ${delay_reduce}  [username]  ${consumername}
      # ${msg}=  Replace String  ${msg}  [provider name]  ${bname2}
      # ${msg}=  Replace String  ${msg}  [service]  ${Service_name}
      # ${msg}=  Replace String  ${msg}  [minutes]  ${delay_time}
      # ${msg}=  Replace String  ${msg}  [wait/service]  service
      # ${msg}=  Replace String  ${msg}  [time]  ${time_after_cancel}

      ${hrs}  ${mins}=   Convert_hour_mins   0

      ${bookingid}=  Format String  ${bookinglink}  ${Wl_encId4}  ${Wl_encId4}
      ${defconfirm_msg}=  Replace String  ${confirmwl_push}  [consumer]   ${consumername}
      ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${Wl_encId4}
      
      ${msg}=  Replace String  ${defDelayAdd_msg}  [consumer]   ${consumername}
      ${msg}=  Replace String  ${msg}  [providerMessage]   ${provider_msg}
      ${msg}=  Replace String  ${msg}  [bookingId]   ${Wl_encId4}
      ${msg}=  Replace String  ${msg}  [delayType]   ${delayType[1]}
      ${msg}=  Replace String  ${msg}  [delaytime]   ${mins}${SPACE}mins    

      ${resp}=  Get Consumer Communications
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      Verify Response List  ${resp}  0  waitlistId=${waitlist_id4}  service=${Service_name} on ${date}  accountId=${pid1}  msg=${msg} 
      Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  0
      # Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}  ${bname} 
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${rcid4}
      Should Be Equal As Strings  ${resp.json()[0]['receiver']['name']}  ${consumername}

JD-TC-AddDelay-6
      [Documentation]   Add delay by provider ,take a waitlist for future. Then check future waitlist does not get delay value
      ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${pid}=  get_acc_id  ${PUSERNAME1} 
      clear_service   ${PUSERNAME1}
      clear_location  ${PUSERNAME1}
      clear_queue  ${PUSERNAME1}
      clear_customer   ${PUSERNAME1}
      ${pid}=  get_acc_id  ${PUSERNAME1}
      ${duration}=   Random Int  min=2  max=10
      Set Suite Variable   ${duration}
      ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${duration}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}   ${Empty}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${resp}=  Create Sample Queue
      Set Suite Variable  ${qid}   ${resp['queue_id']}
      Set Suite Variable  ${s_id1}   ${resp['service_id']}
      Set Suite Variable  ${Service_name}   ${resp['service_name']}
      Set Suite Variable   ${lid}   ${resp['location_id']}

      ${resp}=   Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

      ${resp}=  Get Queue ById  ${qid}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${sTime}  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}
      Set Test Variable  ${eTime}  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}

      clear_Providermsg  ${PUSERNAME1}
      clear_Consumermsg  ${CUSERNAME1}
      ${delay_time}=   Random Int  min=1   max=5
      ${resp}=  Add Delay  ${qid}  ${delay_time}  ${None}  ${bool[1]}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Delay  ${qid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  delayDuration=${delay_time}
      ${DAY1}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable  ${DAY1}  ${DAY1}
      ${DAY2}=  db.add_timezone_date  ${tz}  2  
      
      ${resp}=  AddCustomer  ${CUSERNAME1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid}  ${DAY2}  ${desc}  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id}  ${wid[0]}
      
      ${resp}=  Get Waitlist By Id  ${waitlist_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY2}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=PROVIDER  personsAhead=0
      Should Be Equal As Strings  ${resp.json()['service']['name']}  ${Service_name}
      Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}  ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid}


