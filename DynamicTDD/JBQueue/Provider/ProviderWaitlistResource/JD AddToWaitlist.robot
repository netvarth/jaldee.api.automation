*** Settings ***
Suite Teardown    Delete All Sessions 
Test Teardown     Delete All Sessions
Force Tags        Waitlist
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot

*** Variables ***
${waitlistedby}           PROVIDER
${SERVICE1}               SERVICE1001
${SERVICE2}               SERVICE2002
${SERVICE3}               SERVICE3003
${SERVICE4}               SERVICE4004
${SERVICE5}               SERVICE3005
${SERVICE6}               SERVICE4006
${sample}                     4452135820
@{service_names}

*** Test Cases ***

# JD-TC-AddToWaitlist-0
#       [Documentation]   Add a consumer to the waitlist for the current day
     
#       ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}   
#       Log   ${resp.json()}
#       Should Be Equal As Strings  ${resp.status_code}   200
#       ${resp}=  Get Waitlist Settings
#       Log   ${resp.json()}
#       Should Be Equal As Strings  ${resp.status_code}   200

#       ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
#       Log    ${resp.json()}
#       Should Be Equal As Strings  ${resp.status_code}  200

#       # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
#       # Log   ${resp.json()}
#       # Should Be Equal As Strings      ${resp.status_code}  200

#       ${resp}=    Get Locations
#       Log  ${resp.content}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       IF   '${resp.content}' == '${emptylist}'
#             ${loc_id1}=  Create Sample Location
#             ${resp}=   Get Location ById  ${loc_id1}
#             Log  ${resp.content}
#             Should Be Equal As Strings  ${resp.status_code}  200
#             Set Suite Variable  ${tz}  ${resp.json()['timezone']}
#       ELSE
#             Set Suite Variable  ${loc_id1}  ${resp.json()[0]['id']}
#             Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
#       END

#       ${SERVICE1}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE1} 
#       ${SERVICE2}=    generate_unique_service_name  ${service_names}
#       ${SERVICE3}=    generate_unique_service_name  ${service_names}
#       ${SERVICE4}=    generate_unique_service_name  ${service_names}
#       ${SERVICE5}=    generate_unique_service_name  ${service_names}
#       ${SERVICE6}=    generate_unique_service_name  ${service_names}

#       ${resp}=   Create Sample Service  ${SERVICE1}   maxBookingsAllowed=10
#       Set Test Variable    ${ser_id1}    ${resp}  
#       ${resp}=   Create Sample Service  ${SERVICE2}   maxBookingsAllowed=10
#       Set Test Variable    ${ser_id2}    ${resp}  
#       ${resp}=   Create Sample Service  ${SERVICE3}   maxBookingsAllowed=10
#       Set Test Variable    ${ser_id3}    ${resp}  

#       ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
#       ${q_name}=    FakerLibrary.name
#       ${list}=  Create List   1  2  3  4  5  6  7
#       ${strt_time}=   db.subtract_timezone_time   ${tz}  5  55
#       ${end_time}=    db.add_timezone_time  ${tz}  5  00 
#       ${parallel}=   Random Int  min=1   max=1
#       ${capacity}=  Random Int   min=130   max=200

#       ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}  ${ser_id3}
#       Log   ${resp.json()}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       Set Test Variable  ${que_id1}   ${resp.json()}
    
#       ${waitlist_ids}=  Create List

#       FOR   ${a}  IN RANGE   120
            
#             ${cons_num}    Random Int  min=123456   max=999999
#             ${CUSERPH}=  Evaluate  ${CUSERNAME}+${cons_num}
#             Set Test Variable  ${CUSERPH${a}}  ${CUSERPH}
#             ${resp}=  AddCustomer  ${CUSERPH${a}}
#             Log  ${resp.json()}
#             Should Be Equal As Strings  ${resp.status_code}  200
#             Set Test Variable  ${cid${a}}  ${resp.json()}

#             ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${a}}
#             Log   ${resp.json()}
#             Should Be Equal As Strings  ${resp.status_code}  200
#             Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

#             ${desc}=   FakerLibrary.word
#             ${resp}=  Add To Waitlist  ${cid${a}}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid${a}} 
#             Log   ${resp.json()}
#             Should Be Equal As Strings  ${resp.status_code}  200
#             ${wid}=  Get Dictionary Values  ${resp.json()}
#             Set Test Variable  ${wid${a}}  ${wid[0]}

#             Append To List   ${waitlist_ids}  ${wid${a}}

#       END
      
#       Log   ${waitlist_ids}
#       Log   ${waitlist_ids[0]}
#       ${len}=  Get Length  ${waitlist_ids}

#       FOR   ${a}  IN RANGE   ${len}
     
#             ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${waitlist_ids[${a}]}
#             Log   ${resp.json()}
#             Should Be Equal As Strings  ${resp.status_code}  200

#             ${resp}=  Get Waitlist By Id  ${waitlist_ids[${a}]} 
#             Log  ${resp.json()}
#             Should Be Equal As Strings  ${resp.status_code}  200
#             Should Be Equal As Strings  ${resp.json()['waitlistStatus']}      ${wl_status[2]}

#       END

JD-TC-AddToWaitlist-1
      [Documentation]   Add a consumer to the waitlist for the current day

      # clear_service   ${HLPUSERNAME18}
     
      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}   
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}   200

      ${resp}=  Get Waitlist Settings
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      IF  ${resp.json()['enabledWaitlist']}==${bool[0]}   
            ${resp}=   Enable Waitlist
            Should Be Equal As Strings  ${resp.status_code}  200
      END

      # ${resp}=  Get  Waitlist Settings
      # Log  ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200\

      # ${resp}=   Enable Waitlist
      # Log   ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      
      ${resp}=  Get Waitlist Settings
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}   200

      ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
      Log    ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid}  ${resp.json()}

      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
      Log   ${resp.json()}
      Should Be Equal As Strings      ${resp.status_code}  200
     
      ${resp}=    Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      IF   '${resp.content}' == '${emptylist}'
            ${loc_id1}=  Create Sample Location
            ${resp}=   Get Location ById  ${loc_id1}
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Suite Variable  ${tz}  ${resp.json()['timezone']}
      ELSE
            Set Suite Variable  ${loc_id1}  ${resp.json()[0]['id']}
            Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
      END

      ${SERVICE1}=    generate_unique_service_name  ${service_names}
      Append To List  ${service_names}  ${SERVICE1} 
      Set Suite Variable    ${SERVICE1} 

      ${SERVICE2}=    generate_unique_service_name  ${service_names}
      Append To List  ${service_names}  ${SERVICE2} 
      Set Suite Variable    ${SERVICE2} 

      ${SERVICE3}=    generate_unique_service_name  ${service_names}
      Append To List  ${service_names}  ${SERVICE3} 
      Set Suite Variable    ${SERVICE3} 

      ${resp}=   Create Sample Service  ${SERVICE1}   maxBookingsAllowed=15
      Set Suite Variable    ${ser_id1}    ${resp}  
      ${resp}=   Create Sample Service  ${SERVICE2}   maxBookingsAllowed=15
      Set Suite Variable    ${ser_id2}    ${resp}  
      ${resp}=   Create Sample Service  ${SERVICE3}   maxBookingsAllowed=15
      Set Suite Variable    ${ser_id3}    ${resp}  

      ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable  ${CUR_DAY}
      ${q_name}=    FakerLibrary.name
      Set Suite Variable    ${q_name}
      ${list}=  Create List   1  2  3  4  5  6  7
      Set Suite Variable    ${list}
      ${strt_time}=   db.add_timezone_time  ${tz}  1  00
      Set Suite Variable    ${strt_time}
      ${end_time}=    db.add_timezone_time  ${tz}  3  00 
      Set Suite Variable    ${end_time}   
      ${parallel}=   Random Int  min=1   max=1
      Set Suite Variable   ${parallel}
      ${capacity}=  Random Int   min=10   max=20
      Set Suite Variable   ${capacity}
      ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}  ${ser_id3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id1}   ${resp.json()}
      ${desc}=   FakerLibrary.word
      Set Suite Variable  ${desc}
      ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby}   personsAhead=0
      Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

JD-TC-AddToWaitlist-2
      [Documentation]   Add a consumer to a different service on same Queue

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=   Get Service By Id  ${ser_id2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable   ${ser_duratn}    ${resp.json()['serviceDuration']}
      ${app_wait_time}=   Evaluate  ${ser_duratn}*1
      Set Suite Variable   ${app_wait_time}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid}  ${ser_id2}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid1}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid1} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log   ${cid}
      Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=${app_wait_time}  waitlistedBy=${waitlistedby}  personsAhead=1
      Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${SERVICE2}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           ${cid}

JD-TC-AddToWaitlist-3
      [Documentation]   Add a consumer to the waitlist for a future date for the same service of current day

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${FUT_DAY}=  db.add_timezone_date  ${tz}  2
      Set Suite Variable   ${FUT_DAY}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${FUT_DAY}  ${desc}  ${bool[1]}  ${cid} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid2}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid2} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${FUT_DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby}  personsAhead=0
      Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${SERVICE1}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           ${cid}

JD-TC-AddToWaitlist-4
      [Documentation]   Add a consumer to the waitlist for a different service in a future date 

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid}  ${ser_id2}  ${que_id1}  ${FUT_DAY}  ${desc}  ${bool[1]}  ${cid} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid3}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid3} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${FUT_DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=${app_wait_time}  waitlistedBy=${waitlistedby}  personsAhead=1
      Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${SERVICE2}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           ${cid}

JD-TC-AddToWaitlist-5
    [Documentation]   Add a consumer to a different queue 

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${SERVICE4}=    generate_unique_service_name  ${service_names}
      Append To List  ${service_names}  ${SERVICE4} 
      Set Suite Variable    ${SERVICE4} 

      ${resp}=   Create Sample Service  ${SERVICE4}
      Set Suite Variable  ${ser_id4}  ${resp} 
     
      ${q_name1}=    FakerLibrary.name
      Set Suite Variable    ${q_name1}    
      ${strt_time1}=   db.add_timezone_time  ${tz}  3  10
      Set Suite Variable    ${strt_time1}
      ${end_time1}=    db.add_timezone_time  ${tz}  5  00 
      Set Suite Variable    ${end_time1}     
      ${resp}=  Create Queue  ${q_name1}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time1}  ${end_time1}  ${parallel}  ${capacity}  ${loc_id1}  ${ser_id1}  ${ser_id4}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id2}  ${resp.json()}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid}  ${ser_id4}  ${que_id2}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid4}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid4} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby}  personsAhead=0
      Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${SERVICE4}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id4}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           ${cid}

JD-TC-AddToWaitlist-6
      [Documentation]   Add a consumer to same service on same date to a different queue

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${c_id}  ${resp.json()}

      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${c_id}  ${ser_id1}  ${que_id2}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${c_id} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid5}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid5} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=${app_wait_time}  waitlistedBy=${waitlistedby}  personsAhead=1
      Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${c_id}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${c_id}

JD-TC-AddToWaitlist-7
      [Documentation]   Add a consumer to a waitlist who is already added to another provider's waitlist for the current day

      # clear_customer   ${HLPUSERNAME17}
      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME17}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist Settings
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}   200

      ${resp}=  AddCustomer  ${CUSERNAME1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid1}  ${resp.json()}

      ${resp}=    Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      IF   '${resp.content}' == '${emptylist}'
            ${loc_id2}=  Create Sample Location
            ${resp}=   Get Location ById  ${loc_id2}
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Suite Variable  ${tz}  ${resp.json()['timezone']}
      ELSE
            Set Suite Variable  ${loc_id2}  ${resp.json()[0]['id']}
            Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
      END 

      ${SERVICE5}=    generate_unique_service_name  ${service_names}
      Append To List  ${service_names}  ${SERVICE5} 
      Set Suite Variable    ${SERVICE5} 

      ${SERVICE6}=    generate_unique_service_name  ${service_names}
      Append To List  ${service_names}  ${SERVICE6} 
      Set Suite Variable    ${SERVICE6} 

     

      ${resp}=   Create Sample Service  ${SERVICE5}
      Set Suite Variable    ${ser_id5}    ${resp}  
      ${resp}=   Create Sample Service  ${SERVICE6}
      Set Suite Variable    ${ser_id6}    ${resp}  
      ${duration}=   Random Int  min=2  max=10
      Set Suite Variable   ${duration}
      ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${duration}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${q_name2}=    FakerLibrary.name
      Set Suite Variable    ${q_name2}         
      ${resp}=  Create Queue  ${q_name2}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}  ${capacity}  ${loc_id2}  ${ser_id5}  ${ser_id6}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id3}  ${resp.json()}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid1}  ${ser_id5}  ${que_id3}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid11}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid11} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby}  personsAhead=0
      Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE5}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id5}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid1}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid1}

JD-TC-AddToWaitlist-8
    [Documentation]   Add a consumer to a waitlist, who is already added to another provider's waitlist for a future date

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME17}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid1}  ${ser_id5}  ${que_id3}  ${FUT_DAY}  ${desc}  ${bool[1]}  ${cid1} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid12}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid12} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${FUT_DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0   waitlistedBy=${waitlistedby}  personsAhead=0
      # Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${SERVICE5}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id5}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${cid1}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           ${cid1}

JD-TC-AddToWaitlist-9
      [Documentation]   Add a provider to the waitlist

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer   ${HLPUSERNAME17} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Set Suite Variable  ${pid}  ${resp.json()}

      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${pid}  ${ser_id2}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${pid} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid6}  ${wid[0]}
      ${app_wait_time1}=   Evaluate  ${ser_duratn}*2
      Set Suite Variable   ${app_wait_time1}
      ${resp}=  Get Waitlist By Id  ${wid6} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=${app_wait_time1}  waitlistedBy=${waitlistedby}  personsAhead=2
      Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${SERVICE2}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${pid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           ${pid}

JD-TC-AddToWaitlist-10
      [Documentation]   Add to waitlist after disabling online checkin

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Disable Online Checkin
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${c_id}  ${resp.json()[0]['id']}

      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${c_id}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${c_id} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid7}  ${wid[0]}
   
JD-TC-AddToWaitlist-11
      [Documentation]   Add family members to the waitlist

      ${f_name}  ${l_name}  ${PUSERNAME_R}  ${LoginId}=  Provider Signup
      Set Suite Variable  ${PUSERNAME_R}

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_R}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200 

      ${resp}=  Update Waitlist Settings  ${calc_mode[2]}   ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  50
      Should Be Equal As Strings  ${resp.status_code}  200
     
      ${resp}=  Enable Waitlist
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep   01s
      ${resp}=  Get jaldeeIntegration Settings
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]} 

      ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get jaldeeIntegration Settings
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

      ${resp}=  AddCustomer  ${CUSERNAME2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${id}  ${resp.json()}

      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
      Log   ${resp.json()}
      Should Be Equal As Strings      ${resp.status_code}  200

      ${resp}=  Get Locations
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable    ${loc_id3}   ${resp.json()[0]['id']}
      Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}

      ${SERVICE11}=    generate_unique_service_name  ${service_names}
      Append To List  ${service_names}  ${SERVICE11} 
      Set Suite Variable    ${SERVICE11} 

      ${ser_id7}=   Create Sample Service  ${SERVICE11}     maxBookingsAllowed=10
      Set Suite Variable   ${ser_id7}
      ${q_name1}=    FakerLibrary.name
      Set Suite Variable    ${q_name1}
      ${strt_time1}=   db.add_timezone_time  ${tz}  1  00
      Set Suite Variable    ${strt_time1}
      ${end_time1}=    db.add_timezone_time  ${tz}  2  20 
      Set Suite Variable    ${end_time1}  
      ${capacity}=  Random Int  min=8   max=20
      ${parallel}=  Random Int   min=50   max=52
      Set Suite Variable   ${parallel}
      Set Suite Variable   ${capacity}
      ${partysize}=  Create Dictionary  maxPartySize=${parallel}
      
      ${resp}=  Sample Queue      ${loc_id3}  ${ser_id7}   
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id4}   ${resp.json()}

      ${resp}=    Get Queue ById    ${que_id4}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${f_name}=   generate_firstname
      ${l_name}=   FakerLibrary.last_name
      ${dob}=      FakerLibrary.date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProvider  ${id}  ${f_name}  ${l_name}  ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${mem_id}  ${resp.json()}
      ${f_name}=   generate_firstname
      ${l_name}=   FakerLibrary.last_name
      ${dob}=      FakerLibrary.date
      ${resp}=  AddFamilyMemberByProvider  ${id}  ${f_name}  ${l_name}  ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${mem_id1}  ${resp.json()}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${id}  ${ser_id7}  ${que_id4}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${mem_id}  
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${wait_id1}  ${wid[0]}
      Set Suite Variable  ${wait_id2}  ${wid[1]}
      ${resp}=  Get Waitlist By Id  ${wait_id1}
      Log  ${resp.json()} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby}  personsAhead=0
      Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE11}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id7}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${id}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${mem_id}
      # ${resp}=  Get Waitlist By Id  ${wait_id2} 
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  waitlistedBy=${waitlistedby}  personsAhead=1
      # Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE11}
      # Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id7}
      # Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${id}
      # Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${mem_id1}
# *** Comments ***
JD-TC-AddToWaitlist-12
      [Documentation]   Add again to the same queue and service after cancelling the waitlist

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
     
      ${desc}=   FakerLibrary.word
      Set Suite Variable    ${desc}
      ${resp}=  Add To Waitlist  ${c_id}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${c_id} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid1}  ${wid[0]}
      ${cncl_resn}=   Random Element     ${waitlist_cancl_reasn}
      ${resp}=  Waitlist Action Cancel  ${wid1}  ${cncl_resn}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Add To Waitlist   ${c_id}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${c_id} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wait_id3}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wait_id3} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  waitlistedBy=${waitlistedby}  
      Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${SERVICE1}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${c_id}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           ${c_id}

JD-TC-AddToWaitlist-13
      [Documentation]   Add to waitlist after disabling future checkin

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Disable Future Checkin
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${FUT_DAY}=  db.add_timezone_date  ${tz}  4
      ${resp}=  Add To Waitlist  ${cid}  ${ser_id2}  ${que_id1}  ${FUT_DAY}  ${desc}  ${bool[1]}  ${cid} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wait_id}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wait_id} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${FUT_DAY}  waitlistStatus=${wl_status[0]}  partySize=1  waitlistedBy=${waitlistedby}  personsAhead=0
      Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${SERVICE2}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           ${cid}

      # Should Be Equal As Strings  ${resp.status_code}  422
      # Should Be Equal As Strings  "${resp.json()}"  "${FUTURE_CHECKIN_DISABLED}"
      ${resp}=  Enable Future Checkin
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-AddToWaitlist-UH1
      [Documentation]   Add To Waitlist by Consumer login

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
      Log   ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${account_id}=  get_acc_id  ${HLPUSERNAME18}

      ${fname}=  generate_firstname
      ${lname}=  FakerLibrary.last_name
      Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}

      ${resp}=  AddCustomer  ${CUSERNAME8}    firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  email=${pc_emailid1}
      Log   ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Send Otp For Login    ${CUSERNAME8}    ${account_id}
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${jsessionynw_value}=   Get Cookie from Header  ${resp}

      ${resp}=  Verify Otp For Login   ${CUSERNAME8}   ${OtpPurpose['Authentication']}    JSESSIONYNW=${jsessionynw_value}
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200
      Set Suite Variable  ${token}  ${resp.json()['token']}

      ${resp}=  Provider Logout
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=    ProviderConsumer Login with token   ${CUSERNAME8}    ${account_id}  ${token} 
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${resp}=  Add To Waitlist  ${cid}  ${ser_id2}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"
 
JD-TC-AddToWaitlist-UH2
      [Documentation]   Add To Waitlist without login

      ${resp}=  Add To Waitlist  ${cid}  ${ser_id2}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
      Should Be Equal As Strings  ${resp.status_code}  419
      Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-AddToWaitlist-UH3
      [Documentation]   Add To Waitlist by using another provider's service

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME17}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id3}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

JD-TC-AddToWaitlist-UH4
      [Documentation]   Add To Waitlist by passing invalid consumer

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Add To Waitlist   000  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}   ${cid} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${INVALID_CONS_ID}"
      
JD-TC-AddToWaitlist-UH5
      [Documentation]   Waitlist for a non family member

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${resp}=  AddCustomer  ${CUSERNAME4}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid7}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid7}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1}
      Should Be Equal As Strings  ${resp.status_code}  404
      Should Be Equal As Strings  "${resp.json()}"  "${NOT_A_Familiy_Member}"

JD-TC-AddToWaitlist-UH6
      [Documentation]   Add a consumer to the same queue for the same service repeatedly

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME5}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid8}  ${resp.json()}

      ${SERVICE1}=    generate_service_name
      ${s_id}=  Create Sample Service  ${SERVICE1}

      ${resp}=  Sample Queue  ${loc_id1}   ${s_id}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${q_id}  ${resp.json()}
    
      ${resp}=  Add To Waitlist  ${cid8}  ${s_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid8} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Add To Waitlist  ${cid8}  ${s_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid8} 
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"    	"${WAITLIST_CUSTOMER_ALREADY_IN}"

JD-TC-AddToWaitlist-UH7
      [Documentation]   Add to waitlist after disabling location

      ${multilocdoms}=  get_mutilocation_domains
      Log  ${multilocdoms}
      Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
      Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

      ${firstname}=  generate_firstname
      ${lastname}=  FakerLibrary.last_name
      ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+5568524
      ${highest_package}=  get_highest_license_pkg
      ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_C}    ${highest_package[0]}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    202
      ${resp}=  Account Activation  ${PUSERNAME_C}  0
      Should Be Equal As Strings    ${resp.status_code}    200

      ${jsessionynw_value}=   Get Cookie from Header  ${resp}

      ${resp}=  Account Set Credential  ${PUSERNAME_C}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_C}    JSESSIONYNW=${jsessionynw_value}
      Should Be Equal As Strings    ${resp.status_code}    200
      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_C}${\n}
      Set Suite Variable  ${PUSERNAME_C}

      ${resp}=  Enable Waitlist
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep   01s

      ${loc_id}=  Create Sample Location
      ${resp}=   Get Location ById  ${loc_id}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200


      ${loc_id4}=  Create Sample Location
      ${resp}=   Get Location ById  ${loc_id4}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['timezone']}
      ${SERVICE8}=    generate_service_name
      ${ser_id8}=  Create Sample Service  ${SERVICE8}

      ${resp}=  Sample Queue  ${loc_id4}   ${ser_id8}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${que_id5}  ${resp.json()}
      
      ${resp}=  Disable Location  ${loc_id4}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${id1}  ${resp.json()}
      
      ${resp}=  Add To Waitlist  ${id1}  ${ser_id8}  ${que_id5}  ${CUR_DAY}   ${desc}  ${bool[1]}  ${id1} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${LOCATION_DISABLED}"
      ${resp}=  Enable Location  ${loc_id4}
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-AddToWaitlist-UH8
      [Documentation]   Add to waitlist after disabling queue

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${q_name3}=    FakerLibrary.name
      Set Suite Variable    ${q_name3}     
      ${strt_time3}=   db.add_timezone_time  ${tz}  5  10
      Set Suite Variable    ${strt_time3}
      ${end_time3}=    db.add_timezone_time  ${tz}  6  00 
      Set Suite Variable    ${end_time3}   
      ${resp}=  Create Queue    ${q_name3}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time3}  ${end_time3}  ${parallel}  ${capacity}    ${loc_id1}     ${ser_id3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id5}   ${resp.json()}
      ${resp}=  Enable Disable Queue  ${que_id5}      ${toggleButton[1]}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${id2}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${id2}  ${ser_id3}  ${que_id5}  ${CUR_DAY}   ${desc}  ${bool[1]}  ${id2} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_DISABLED}"
      ${resp}=  Enable Disable Queue  ${que_id5}      ${toggleButton[0]}
      Should Be Equal As Strings  ${resp.status_code}  200
      # ${resp}=  Disable Future Checkin
      # Log   ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-AddToWaitlist-UH9
      [Documentation]   Add to waitlist after disabling service

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Disable Service  ${ser_id3}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Add To Waitlist  ${cid8}  ${ser_id3}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid8} 
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${INVALID_SERVICE}"
      ${resp}=  Enable Service  ${ser_id3}
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-AddToWaitlist-UH10
      [Documentation]   Add to waitlist after disabling waitlist for current day

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Disable Waitlist
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep  2s
      ${resp}=  Add To Waitlist  ${id2}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${id2} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_NOT_ENABLED}"
      ${resp}=  Enable Waitlist
      Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-AddToWaitlist-UH11
      [Documentation]   Add to waitlist on a holiday
      
      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${DAY2}=  db.add_timezone_date  ${tz}  3
      ${list}=  Create List   1  2  3  4  5  6  7
      # ${resp}=  Create Holiday  ${DAY2}  ${desc}  ${strt_time}  ${end_time}
      ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY2}  ${DAY2}  ${EMPTY}  ${strt_time}  ${end_time}  ${desc}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${DAY2}  ${desc}  ${bool[1]}  ${cid} 
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_NON_WORKING_DAY}"

JD-TC-AddToWaitlist-UH12
      [Documentation]   Add a consumer to a waitlist when partysize number affecting  waiting time and it becomes greater than working time

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      clear_customer   ${HLPUSERNAME18}

      ${resp}=  AddCustomer  ${CUSERNAME1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${Acid}  ${resp.json()}

      ${loc_id3}=  Create Sample Location
      Set Suite Variable    ${loc_id3} 
      ${resp}=   Get Location ById  ${loc_id3}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${SERVICE8}=    generate_unique_service_name  ${service_names}
      Append To List  ${service_names}  ${SERVICE8} 

      ${ser_id7}=  Create Sample Service  ${SERVICE8}
      Set Suite Variable    ${ser_id7} 
      ${queue1}=    FakerLibrary.name
      Set Suite Variable    ${queue1}    
      ${strt_time3}=   db.add_timezone_time  ${tz}  0  35
      Set Suite Variable    ${strt_time3}
      ${end_time3}=    db.add_timezone_time  ${tz}  0  38 
      Set Suite Variable    ${end_time3}  
      ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time3}  ${end_time3}  ${parallel}  ${capacity}  ${loc_id3}  ${ser_id7}
      Log     ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id6}   ${resp.json()}
      ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  0  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Add To Waitlist  ${Acid}  ${ser_id7}  ${que_id6}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${Acid} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+500000
      ${f_name}=   generate_firstname
      ${l_name}=   FakerLibrary.last_name
      ${dob}=      FakerLibrary.date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProvider  ${Acid}  ${f_name}  ${l_name}  ${dob}  ${gender}  
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id}  ${resp.json()}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+500001
      ${f_name}=   generate_firstname
      ${l_name}=    FakerLibrary.last_name
      ${dob}=       FakerLibrary.date
      ${resp}=  AddFamilyMemberByProvider  ${Acid}  ${f_name}  ${l_name}  ${dob}  ${gender}   
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id1}  ${resp.json()}
      ${resp}=  Add To Waitlist  ${Acid}  ${ser_id7}  ${que_id6}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${mem_id}  ${mem_id1}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${PARTY_SIZE_GREATER}"

JD-TC-AddToWaitlist-UH13
      [Documentation]   Add a consumer to a waitlist after working time

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${queue2}=    FakerLibrary.name
      Set Suite Variable    ${queue2} 
      ${stime}=   db.subtract_timezone_time   ${tz}   2   00  
      ${etime}=   db.get_time_by_timezone   ${tz}
      ${resp}=  Create Queue   ${queue2}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc_id1}  ${ser_id1}  ${ser_id2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id7}   ${resp.json()}
      ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${ser_duratn}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME0}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${coid1}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${coid1}  ${ser_id1}  ${que_id7}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${coid1} 
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_BUS_HOURS_END}"

JD-TC-AddToWaitlist-UH14
      [Documentation]   Add to waitlist on a non scheduled day

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${list}=  Create List  1  2  3  4  5  6
      ${stime}=   db.subtract_timezone_time   ${tz}   2   00  
      Set Suite Variable   ${stime}
      ${etime}=   db.add_timezone_time  ${tz}   0  15
      Set Suite Variable   ${etime}
      ${resp}=  Update Queue  ${que_id7}  ${queue2}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc_id1}  ${ser_id1}  ${ser_id2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${d}=  get_weekday
      ${d}=  Evaluate  7-${d}
      ${DAY2}=  db.add_timezone_date  ${tz}  ${d}

      ${firstname}=  generate_firstname
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer   ${PUSERNAME2}  
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Set Suite Variable  ${coid3}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME2}${\n}
      ${resp}=  Add To Waitlist  ${coid3}  ${ser_id1}  ${que_id7}  ${DAY2}  ${desc}  ${bool[1]}  ${coid3} 
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_NON_WORKING_DAY}"

JD-TC-AddToWaitlist-UH15
      [Documentation]  update maximum capacity and check

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Update Queue  ${que_id7}  ${queue2}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${stime}  ${etime}  1  2  ${loc_id1}  ${ser_id1}  ${ser_id2}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${DAY2}=  db.add_timezone_date  ${tz}  1
      ${resp}=  Add To Waitlist  ${coid3}  ${ser_id1}  ${que_id7}  ${DAY2}  ${desc}  ${bool[1]}  ${coid3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${firstname}=  generate_firstname
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer   ${PUSERNAME3} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Set Test Variable  ${cid4}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME3}${\n}
      ${resp}=  Add To Waitlist  ${cid4}  ${ser_id1}  ${que_id7}  ${DAY2}  ${desc}  ${bool[1]}  ${cid4} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${firstname}=  generate_firstname
      ${lastname}=  FakerLibrary.last_name

      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer   ${PUSERNAME4} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Set Test Variable  ${cid5}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME4}${\n}
     
      ${resp}=  Add To Waitlist  ${cid5}  ${ser_id1}  ${que_id7}  ${DAY2}  ${desc}  ${bool[1]}  ${cid5} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${WATLIST_MAX_LIMIT_REACHED}"


JD-TC-AddToWaitlist-UH16
      [Documentation]  update maximum capacity and check

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${queue4}=    FakerLibrary.name
      Set Suite Variable    ${queue4}    
      ${DAY1}=  db.add_timezone_date  ${tz}  1
      ${resp}=  Create Queue  ${queue4}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${stime}  ${etime}  1  50  ${loc_id1}  ${ser_id3}   ${ser_id4}
      Log    ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id8}  ${resp.json()}
      ${firstname}=  generate_firstname
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer   ${PUSERNAME1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid0}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME1}${\n}
      
      # ${resp}=  Add To Waitlist  ${cid0}  ${ser_id3}  ${que_id8}  ${DAY1}  ${desc}  ${bool[1]}  ${cid0} 
      # Log   ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Update Queue  ${que_id8}  ${queue4}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${stime}  ${etime}  1  4  ${loc_id1}  ${ser_id3}  ${ser_id4}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${firstname}=  generate_firstname
      ${lastname}=  FakerLibrary.last_name
      
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer   ${PUSERNAME7}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid1}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME3}${\n}
      
      ${resp}=  Add To Waitlist  ${cid0}  ${ser_id3}  ${que_id8}  ${DAY1}  ${desc}  ${bool[1]}  ${cid0}   location=${loc_id1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Add To Waitlist  ${cid1}  ${ser_id3}  ${que_id8}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}   location=${loc_id1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${firstname}=  generate_firstname
      ${lastname}=  FakerLibrary.last_name
      
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer   ${PUSERNAME6}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid2}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME6}${\n}
      
      ${resp}=  Add To Waitlist  ${cid2}  ${ser_id3}  ${que_id8}  ${DAY1}  ${desc}  ${bool[1]}  ${cid2}  location=${loc_id1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

     
      ${resp}=  Add To Waitlist  ${cid1}   ${ser_id4}   ${que_id8}   ${DAY1}   ${desc}  ${bool[1]}  ${cid1}  location=${loc_id1}
      Should Be Equal As Strings  ${resp.status_code}  200 
     
      ${resp}=  Add To Waitlist  ${cid2}  ${ser_id4}  ${que_id8}  ${DAY1}  ${desc}  ${bool[1]}  ${cid2}  location=${loc_id1}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"    "${WATLIST_MAX_LIMIT_REACHED}"


JD-TC-AddToWaitlist-14
      [Documentation]  Provider takes checkin for a consumer with a different phone number
      
      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=   Get License UsageInfo 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Business Profile
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${bsname}  ${resp.json()['businessName']}
      Set Test Variable  ${pid}  ${resp.json()['id']}
      Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

      # clear_location   ${HLPUSERNAME18}
      # clear_service    ${HLPUSERNAME18}
      clear_customer   ${HLPUSERNAME18}
      clear_consumer_msgs  ${CUSERNAME12}
      clear_provider_msgs  ${HLPUSERNAME18}

      ${resp}=   Get Service
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=    Get Locations
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
            
      ${SERVICE1}=    generate_unique_service_name  ${service_names}
      Append To List  ${service_names}  ${SERVICE1}
      ${s_id}=  Create Sample Service  ${SERVICE1}

      ${resp}=   Get Service
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

      ${lid}=  Create Sample Location  
      ${resp}=   Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['timezone']}
      # clear_queue   ${HLPUSERNAME18}

      ${resp}=  Get Queues
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME12}  
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}   ${resp.json()}

      ${DAY1}=  db.get_date_by_timezone  ${tz}
      ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
      ${DAY2}=  db.add_timezone_date  ${tz}  10      
      ${DAY3}=  db.add_timezone_date  ${tz}  4
      ${list}=  Create List  1  2  3  4  5  6  7
      ${sTime1}=  db.get_time_by_timezone  ${tz}
      ${delta}=  FakerLibrary.Random Int  min=10  max=60
      ${eTime1}=  add_two   ${sTime1}  ${delta}
      ${queue_name}=  FakerLibrary.bs
      ${parallel}=  FakerLibrary.Random Int  min=1  max=1
      ${capacity}=  FakerLibrary.Random Int  min=5  max=10
      ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${q_id}  ${resp.json()}

      ${resp}=  Get Queue ById  ${q_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

      ${now}=   db.get_time_by_timezone   ${tz}
      ${PO_Number}    Generate random string    4    ${digits} 
      ${PO_Number}    Convert To Integer  ${PO_Number}
      ${country_code}    Generate random string    2    ${digits} 
      ${country_code}    Convert To Integer  ${country_code}
      ${CUSERPH12}=  Evaluate  ${CUSERNAME12}+${PO_Number}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist with PhoneNo  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${CUSERPH12}  91  ${cid} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${wl_json}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid}  ${wl_json[0]}

      ${resp}=  Get Waitlist By Id  ${wid} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-AddToWaitlist-15
      [Documentation]  Provider takes checkin for a consumer with an international phone number

      
      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=   Get License UsageInfo 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Business Profile
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${bsname}  ${resp.json()['businessName']}
      Set Test Variable  ${pid}  ${resp.json()['id']}
      Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

      # clear_location   ${HLPUSERNAME18}
      # clear_service    ${HLPUSERNAME18}
      clear_customer   ${HLPUSERNAME18}
      clear_consumer_msgs  ${CUSERNAME12}
      clear_provider_msgs  ${HLPUSERNAME18}

      ${resp}=   Get Service
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=    Get Locations
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
            
      ${SERVICE1}=    generate_unique_service_name  ${service_names}
      Append To List  ${service_names}  ${SERVICE1}
      ${s_id}=  Create Sample Service  ${SERVICE1}

      ${resp}=   Get Service
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

      ${lid}=  Create Sample Location  
      ${resp}=   Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['timezone']}
      # clear_queue   ${HLPUSERNAME18}

      ${resp}=  Get Queues
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME12}  
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}   ${resp.json()}

      ${DAY1}=  db.get_date_by_timezone  ${tz}
      ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
      ${DAY2}=  db.add_timezone_date  ${tz}  10      
      ${DAY3}=  db.add_timezone_date  ${tz}  4
      ${list}=  Create List  1  2  3  4  5  6  7
      ${sTime1}=  db.get_time_by_timezone  ${tz}
      ${delta}=  FakerLibrary.Random Int  min=10  max=60
      ${eTime1}=  add_two   ${sTime1}  ${delta}
      ${queue_name}=  FakerLibrary.bs
      ${parallel}=  FakerLibrary.Random Int  min=1  max=1
      ${capacity}=  FakerLibrary.Random Int  min=5  max=10
      ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${q_id}  ${resp.json()}

      ${resp}=  Get Queue ById  ${q_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

      ${now}=   db.get_time_by_timezone   ${tz}
      ${PO_Number}    Generate random string    4    ${digits} 
      ${PO_Number}    Convert To Integer  ${PO_Number}
      ${country_code}    Generate random string    2    ${digits} 
      ${country_code}    Convert To Integer  ${country_code}
      ${CUSERPH12}=  Evaluate  ${CUSERNAME12}+${PO_Number}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist with PhoneNo  ${cid}  ${s_id}  ${q_id}  ${DAY1}  1746173745  880  ${cid} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${wl_json}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid}  ${wl_json[0]}

      ${resp}=  Get Waitlist By Id  ${wid} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-AddToWaitlist-UH18
      [Documentation]  Provider takes checkin for a consumer without phone number and country code
      
      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=   Get License UsageInfo 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Business Profile
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${bsname}  ${resp.json()['businessName']}
      Set Test Variable  ${pid}  ${resp.json()['id']}
      Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

      # clear_location   ${HLPUSERNAME18}
      # clear_service    ${HLPUSERNAME18}
      clear_customer   ${HLPUSERNAME18}
      clear_consumer_msgs  ${CUSERNAME12}
      clear_provider_msgs  ${HLPUSERNAME18}

      ${resp}=   Get Service
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=    Get Locations
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
            
      ${SERVICE1}=    generate_unique_service_name  ${service_names}
      Append To List  ${service_names}  ${SERVICE1} 
      ${s_id}=  Create Sample Service  ${SERVICE1}

      ${resp}=   Get Service
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

      ${lid}=  Create Sample Location  
      ${resp}=   Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['timezone']}
      # clear_queue   ${HLPUSERNAME18}

      ${resp}=  Get Queues
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME12}  
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}   ${resp.json()}

      ${DAY1}=  db.get_date_by_timezone  ${tz}
      ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
      ${DAY2}=  db.add_timezone_date  ${tz}  10      
      ${DAY3}=  db.add_timezone_date  ${tz}  4
      ${list}=  Create List  1  2  3  4  5  6  7
      ${sTime1}=  db.get_time_by_timezone  ${tz}
      ${delta}=  FakerLibrary.Random Int  min=10  max=60
      ${eTime1}=  add_two   ${sTime1}  ${delta}
      ${queue_name}=  FakerLibrary.bs
      ${parallel}=  FakerLibrary.Random Int  min=1  max=1
      ${capacity}=  FakerLibrary.Random Int  min=5  max=10
      ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${q_id}  ${resp.json()}

      ${resp}=  Get Queue ById  ${q_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

      ${now}=   db.get_time_by_timezone   ${tz}
      ${PO_Number}    Generate random string    4    ${digits} 
      ${PO_Number}    Convert To Integer  ${PO_Number}
      ${country_code}    Generate random string    2    ${digits} 
      ${country_code}    Convert To Integer  ${country_code}
      ${CUSERPH12}=  Evaluate  ${CUSERNAME12}+${PO_Number}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist with PhoneNo  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${cid} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${COUNTRY_CODEREQUIRED}"

      # Should Be Equal As Strings  ${resp.status_code}  200
      
      # ${wl_json}=  Get Dictionary Values  ${resp.json()}
      # Set Test Variable  ${wid}  ${wl_json[0]}

      # ${resp}=  Get Waitlist By Id  ${wid} 
      # Log  ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-AddToWaitlist-16
      [Documentation]  Provider takes checkin for a consumer without phone number and with country code
      
      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=   Get License UsageInfo 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Business Profile
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${bsname}  ${resp.json()['businessName']}
      Set Test Variable  ${pid}  ${resp.json()['id']}
      Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

      # clear_location   ${HLPUSERNAME18}
      # clear_service    ${HLPUSERNAME18}
      clear_customer   ${HLPUSERNAME18}
      clear_consumer_msgs  ${CUSERNAME12}
      clear_provider_msgs  ${HLPUSERNAME18}

      ${resp}=   Get Service
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=    Get Locations
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
            
      ${SERVICE1}=    generate_unique_service_name  ${service_names}
      Append To List  ${service_names}  ${SERVICE1}
      ${s_id}=  Create Sample Service  ${SERVICE1}

      ${resp}=   Get Service
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

      ${lid}=  Create Sample Location  
      ${resp}=   Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['timezone']}
      # clear_queue   ${HLPUSERNAME18}

      ${resp}=  Get Queues
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME12}  
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}   ${resp.json()}

      ${DAY1}=  db.get_date_by_timezone  ${tz}
      ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
      ${DAY2}=  db.add_timezone_date  ${tz}  10      
      ${DAY3}=  db.add_timezone_date  ${tz}  4
      ${list}=  Create List  1  2  3  4  5  6  7
      ${sTime1}=  db.get_time_by_timezone  ${tz}
      ${delta}=  FakerLibrary.Random Int  min=10  max=60
      ${eTime1}=  add_two   ${sTime1}  ${delta}
      ${queue_name}=  FakerLibrary.bs
      ${parallel}=  FakerLibrary.Random Int  min=1  max=1
      ${capacity}=  FakerLibrary.Random Int  min=5  max=10
      ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${q_id}  ${resp.json()}

      ${resp}=  Get Queue ById  ${q_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

      ${now}=   db.get_time_by_timezone   ${tz}
      ${PO_Number}    Generate random string    4    ${digits} 
      ${PO_Number}    Convert To Integer  ${PO_Number}
      ${country_code}    Generate random string    2    ${digits} 
      ${country_code}    Convert To Integer  ${country_code}
      ${CUSERPH12}=  Evaluate  ${CUSERNAME12}+${PO_Number}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist with PhoneNo  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${EMPTY}  91  ${cid} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      # Should Be Equal As Strings  "${resp.json()}"  "${COUNTRY_CODEREQUIRED}"
      
      ${wl_json}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid}  ${wl_json[0]}

      ${resp}=  Get Waitlist By Id  ${wid} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-AddToWaitlist-UH19
      [Documentation]  Provider takes checkin for a consumer with phone number but without country code
      
      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=   Get License UsageInfo 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Business Profile
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${bsname}  ${resp.json()['businessName']}
      Set Test Variable  ${pid}  ${resp.json()['id']}
      Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

      # clear_location   ${HLPUSERNAME18}
      # clear_service    ${HLPUSERNAME18}
      clear_customer   ${HLPUSERNAME18}
      clear_consumer_msgs  ${CUSERNAME12}
      clear_provider_msgs  ${HLPUSERNAME18}

      ${resp}=   Get Service
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=    Get Locations
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
            
      ${SERVICE1}=    generate_unique_service_name  ${service_names}
      Append To List  ${service_names}  ${SERVICE1}
      ${s_id}=  Create Sample Service  ${SERVICE1}

      ${resp}=   Get Service
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

      ${lid}=  Create Sample Location  
      ${resp}=   Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['timezone']}
      # clear_queue   ${HLPUSERNAME18}

      ${resp}=  Get Queues
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME12}  
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}   ${resp.json()}

      ${DAY1}=  db.get_date_by_timezone  ${tz}
      ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
      ${DAY2}=  db.add_timezone_date  ${tz}  10      
      ${DAY3}=  db.add_timezone_date  ${tz}  4
      ${list}=  Create List  1  2  3  4  5  6  7
      ${sTime1}=  db.get_time_by_timezone  ${tz}
      ${delta}=  FakerLibrary.Random Int  min=10  max=60
      ${eTime1}=  add_two   ${sTime1}  ${delta}
      ${queue_name}=  FakerLibrary.bs
      ${parallel}=  FakerLibrary.Random Int  min=1  max=1
      ${capacity}=  FakerLibrary.Random Int  min=5  max=10
      ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${q_id}  ${resp.json()}

      ${resp}=  Get Queue ById  ${q_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

      ${now}=   db.get_time_by_timezone   ${tz}
      ${PO_Number}    Generate random string    4    ${digits} 
      ${PO_Number}    Convert To Integer  ${PO_Number}
      ${country_code}    Generate random string    2    ${digits} 
      ${country_code}    Convert To Integer  ${country_code}
      ${CUSERPH12}=  Evaluate  ${CUSERNAME12}+${PO_Number}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist with PhoneNo  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${CUSERPH12}  ${EMPTY}  ${cid} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${COUNTRY_CODEREQUIRED}"

      
      # ${wl_json}=  Get Dictionary Values  ${resp.json()}
      # Set Test Variable  ${wid}  ${wl_json[0]}

      # ${resp}=  Get Waitlist By Id  ${wid} 
      # Log  ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200







