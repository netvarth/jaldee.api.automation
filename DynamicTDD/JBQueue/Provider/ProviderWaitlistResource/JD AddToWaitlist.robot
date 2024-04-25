*** Settings ***
Suite Teardown    Delete All Sessions 
Test Teardown     Delete All Sessions
Force Tags        Waitlist
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${waitlistedby}           PROVIDER
${SERVICE1}               SERVICE1001
${SERVICE2}               SERVICE2002
${SERVICE3}               SERVICE3003
${SERVICE4}               SERVICE4004
${SERVICE5}               SERVICE3005
${SERVICE6}               SERVICE4006
${sample}                     4452135820

*** Test Cases ***

JD-TC-AddToWaitlist-0
      [Documentation]   Add a consumer to the waitlist for the current day

      clear_queue      ${PUSERNAME101}
      clear_location   ${PUSERNAME101}
      clear_service    ${PUSERNAME101}
      clear_customer   ${PUSERNAME101}
     
      ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}   
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}   200
      ${resp}=  View Waitlist Settings
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}   200

      ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
      Log    ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
      Log   ${resp.json()}
      Should Be Equal As Strings      ${resp.status_code}  200
     
      
      ${resp}=   Create Sample Location
      Set Test Variable    ${loc_id1}    ${resp} 
      ${resp}=   Get Location ById  ${loc_id1}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 
      ${resp}=   Create Sample Service  ${SERVICE1}
      Set Test Variable    ${ser_id1}    ${resp}  
      ${resp}=   Create Sample Service  ${SERVICE2}
      Set Test Variable    ${ser_id2}    ${resp}  
      ${resp}=   Create Sample Service  ${SERVICE3}
      Set Test Variable    ${ser_id3}    ${resp}  

      ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
      ${q_name}=    FakerLibrary.name
      ${list}=  Create List   1  2  3  4  5  6  7
      ${strt_time}=   db.subtract_timezone_time   ${tz}  5  55
      ${end_time}=    db.add_timezone_time  ${tz}  5  00 
      ${parallel}=   Random Int  min=1   max=1
      ${capacity}=  Random Int   min=130   max=200

      ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}  ${ser_id3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${que_id1}   ${resp.json()}
    
      ${waitlist_ids}=  Create List

      FOR   ${a}  IN RANGE   120
            
            ${cons_num}    Random Int  min=123456   max=999999
            ${CUSERPH}=  Evaluate  ${CUSERNAME}+${cons_num}
            Set Test Variable  ${CUSERPH${a}}  ${CUSERPH}
            ${resp}=  AddCustomer  ${CUSERPH${a}}
            Log  ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Test Variable  ${cid${a}}  ${resp.json()}

            ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${a}}
            Log   ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200
            Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

            ${desc}=   FakerLibrary.word
            ${resp}=  Add To Waitlist  ${cid${a}}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid${a}} 
            Log   ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200
            ${wid}=  Get Dictionary Values  ${resp.json()}
            Set Test Variable  ${wid${a}}  ${wid[0]}

            Append To List   ${waitlist_ids}  ${wid${a}}

      END
      
      Log   ${waitlist_ids}
      Log   ${waitlist_ids[0]}
      ${len}=  Get Length  ${waitlist_ids}

      FOR   ${a}  IN RANGE   ${len}
     
            ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${waitlist_ids[${a}]}
            Log   ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200

            ${resp}=  Get Waitlist By Id  ${waitlist_ids[${a}]} 
            Log  ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200
            Should Be Equal As Strings  ${resp.json()['waitlistStatus']}      ${wl_status[2]}

      END

JD-TC-AddToWaitlist-1
      [Documentation]   Add a consumer to the waitlist for the current day

      clear_queue      ${PUSERNAME161}
      clear_location   ${PUSERNAME161}
      clear_service    ${PUSERNAME161}
      clear_customer   ${PUSERNAME161}
     
      ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}   
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}   200
      
      ${resp}=  View Waitlist Settings
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
     
      
      ${resp}=   Create Sample Location
      Set Suite Variable    ${loc_id1}    ${resp}  
      ${resp}=   Get Location ById  ${loc_id1}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 
      ${resp}=   Create Sample Service  ${SERVICE1}
      Set Suite Variable    ${ser_id1}    ${resp}  
      ${resp}=   Create Sample Service  ${SERVICE2}
      Set Suite Variable    ${ser_id2}    ${resp}  
      ${resp}=   Create Sample Service  ${SERVICE3}
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

      ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
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

      ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
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

      ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
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

      ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
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

      ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
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

      clear_queue      ${PUSERNAME151}
      clear_location   ${PUSERNAME151}
      clear_service    ${PUSERNAME151}
      clear_customer   ${PUSERNAME151}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  View Waitlist Settings
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}   200

      ${resp}=  AddCustomer  ${CUSERNAME1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid1}  ${resp.json()}

      ${resp}=   Create Sample Location
      Set Suite Variable    ${loc_id2}    ${resp} 
      ${resp}=   Get Location ById  ${loc_id2}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 
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

      ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
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
      Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${SERVICE5}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id5}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${cid1}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           ${cid1}

JD-TC-AddToWaitlist-9
    [Documentation]   Add a provider to the waitlist

      ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
     
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}  ${gender}  ${dob}   ${PUSERNAME151}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Set Suite Variable  ${pid}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt   ${PUSERNAME151}${\n}

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

      ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Disable Online Checkin
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${id}  ${resp.json()[0]['id']}

      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${id}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${id} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid7}  ${wid[0]}
   
JD-TC-AddToWaitlist-11
      [Documentation]   Add family members to the waitlist

      ${f_name}=  FakerLibrary.first_name
      ${l_name}=  FakerLibrary.last_name
      ${resp}=    get_maxpartysize_subdomain
      Set Test Variable   ${sector}        ${resp['domain']}
      Set Test Variable   ${sub_sector}    ${resp['subdomain']}
      ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+8706
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_A}${\n}   
      ${pkg_id}=   get_highest_license_pkg
      ${resp}=   Account SignUp  ${f_name}  ${l_name}  ${None}   ${sector}   ${sub_sector}  ${PUSERNAME_A}  ${pkg_id[0]}
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Activation  ${PUSERNAME_A}  0
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200  
      Set Suite Variable   ${PUSERNAME_A}

      ${PUSERPH1}=  Evaluate  ${PUSERNAME}+342
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH1}${\n}

      ${PUSERPH2}=  Evaluate  ${PUSERNAME}+343
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH2}${\n}

      ${PUSERMAIL0}=   Set Variable  ${P_Email}${PUSERNAME_A}.${test_mail}
      ${views}=  Evaluate  random.choice($Views)  random
      Log   ${views}
      ${name1}=  FakerLibrary.name
      ${name2}=  FakerLibrary.name
      ${name3}=  FakerLibrary.name
      ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH1}  ${views}
      ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH2}  ${views}
      ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL0}  ${views}
      ${bs}=  FakerLibrary.bs
      ${companySuffix}=  FakerLibrary.companySuffix
      # ${city}=   get_place
      # ${latti}=  get_latitude
      # ${longi}=  get_longitude
      # ${postcode}=  FakerLibrary.postcode
      # ${address}=  get_address
      ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
      ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
      Set Suite Variable  ${tz}
      ${sTime}=  db.subtract_timezone_time   ${tz}  3  25
      ${eTime}=  db.add_timezone_time  ${tz}   0  30 
      ${desc}=   FakerLibrary.sentence
      ${url}=   FakerLibrary.url
      ${parking}   Random Element   ${parkingType}
      ${24hours}    Random Element    ['True','False']
      ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      sleep   1s
    
      ${fields}=   Get subDomain level Fields  ${sector}  ${sub_sector}
      Log  ${fields.json()}
      Should Be Equal As Strings    ${fields.status_code}   200

      ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

      ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_sector}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get specializations Sub Domain  ${sector}  ${sub_sector}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${spec}=  get_Specializations  ${resp.json()}
      ${resp}=  Update Specialization  ${spec}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}   200


      ${resp}=  Update Waitlist Settings  ${calc_mode[2]}   ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
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
      Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
      ${ser_id7}=   Create Sample Service  ${SERVICE1}
      Set Suite Variable   ${ser_id7}
      ${q_name1}=    FakerLibrary.name
      Set Suite Variable    ${q_name1}
      ${strt_time1}=   db.add_timezone_time  ${tz}  1  00
      Set Suite Variable    ${strt_time1}
      ${end_time1}=    db.add_timezone_time  ${tz}  2  20 
      Set Suite Variable    ${end_time1}  
      ${capacity}=  Random Int  min=8   max=20
      ${parallel}=  Random Int   min=1   max=1
      Set Suite Variable   ${parallel}
      Set Suite Variable   ${capacity}
      ${resp}=  Create Queue    ${q_name1}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time1}  ${end_time1}   ${parallel}   ${capacity}    ${loc_id3}  ${ser_id7}  
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id4}   ${resp.json()}
      ${f_name}=   FakerLibrary.first_name
      ${l_name}=   FakerLibrary.last_name
      ${dob}=      FakerLibrary.date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProvider  ${id}  ${f_name}  ${l_name}  ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${mem_id}  ${resp.json()}
      ${f_name}=   FakerLibrary.first_name
      ${l_name}=   FakerLibrary.last_name
      ${dob}=      FakerLibrary.date
      ${resp}=  AddFamilyMemberByProvider  ${id}  ${f_name}  ${l_name}  ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${mem_id1}  ${resp.json()}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${id}  ${ser_id7}  ${que_id4}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${mem_id}  ${mem_id1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${wait_id1}  ${wid[0]}
      Set Suite Variable  ${wait_id2}  ${wid[1]}
      ${resp}=  Get Waitlist By Id  ${wait_id1}
      Log  ${resp.json()} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby}  personsAhead=0
      Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id7}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${id}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${mem_id}
      ${resp}=  Get Waitlist By Id  ${wait_id2} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  waitlistedBy=${waitlistedby}  personsAhead=1
      Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id7}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${id}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${mem_id1}

JD-TC-AddToWaitlist-12
      [Documentation]   Add again to the same queue and service after cancelling the waitlist

      ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
     
      ${desc}=   FakerLibrary.word
      Set Suite Variable    ${desc}
      ${resp}=  Add To Waitlist  ${pid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${pid} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid1}  ${wid[0]}
      ${cncl_resn}=   Random Element     ${waitlist_cancl_reasn}
      ${resp}=  Waitlist Action Cancel  ${wid1}  ${cncl_resn}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Add To Waitlist   ${pid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${pid} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wait_id3}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wait_id3} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  waitlistedBy=${waitlistedby}  personsAhead=4
      Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${SERVICE1}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${pid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           ${pid}

JD-TC-AddToWaitlist-13
      [Documentation]   Add to waitlist after disabling future checkin

      ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
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

      ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
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

      ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id3}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  404
      Should Be Equal As Strings  "${resp.json()}"  "${NOT_A_Familiy_Member}"

JD-TC-AddToWaitlist-UH4
      [Documentation]   Add To Waitlist by passing invalid consumer

      ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Add To Waitlist   000  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}   ${cid} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${INVALID_CONS_ID}"
      
JD-TC-AddToWaitlist-UH5
      [Documentation]   Waitlist for a non family member

      ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
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

      ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME5}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid8}  ${resp.json()}
    
      ${resp}=  Add To Waitlist  ${cid8}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid8} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Add To Waitlist  ${cid8}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid8} 
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"    	"${WAITLIST_CUSTOMER_ALREADY_IN}"

JD-TC-AddToWaitlist-UH7
      [Documentation]   Add to waitlist after disabling location

      ${multilocdoms}=  get_mutilocation_domains
      Log  ${multilocdoms}
      Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
      Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+5568524
      ${highest_package}=  get_highest_license_pkg
      ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_C}    ${highest_package[0]}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Activation  ${PUSERNAME_C}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Set Credential  ${PUSERNAME_C}  ${PASSWORD}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_C}${\n}
      Set Suite Variable  ${PUSERNAME_C}

      # ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
      # Log   ${resp.json()}
      # Should Be Equal As Strings    ${resp.status_code}    200

      
      ${list}=  Create List  1  2  3  4  5  6  7
      ${ph1}=  Evaluate  ${PUSERNAME_C}+15566122
      ${ph2}=  Evaluate  ${PUSERNAME_C}+25566122
      ${views}=  Random Element    ${Views}
      ${name1}=  FakerLibrary.name
      ${name2}=  FakerLibrary.name
      ${name3}=  FakerLibrary.name
      ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
      ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
      ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
      ${bs}=  FakerLibrary.bs
      ${companySuffix}=  FakerLibrary.companySuffix
      # ${city}=   get_place
      # ${latti}=  get_latitude
      # ${longi}=  get_longitude
      # ${postcode}=  FakerLibrary.postcode
      # ${address}=  get_address
      ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
      ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
      Set Suite Variable  ${tz}
      ${parking}   Random Element   ${parkingType}
      ${24hours}    Random Element    ${bool}
      ${desc}=   FakerLibrary.sentence
      ${url}=   FakerLibrary.url
      ${DAY1}=  db.get_date_by_timezone  ${tz}
      ${sTime}=  db.add_timezone_time  ${tz}  0  15
      ${eTime}=  db.add_timezone_time  ${tz}   0  45
      ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=  Get Business Profile
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
      Log  ${fields.json()}
      Should Be Equal As Strings    ${fields.status_code}   200

      ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

      ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${spec}=  get_Specializations  ${resp.json()}
      ${resp}=  Update Specialization  ${spec}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${resp}=  Enable Waitlist
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep   01s
    
      # ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # ${resp}=  Create Sample Queue
      # Set Suite Variable   ${loc_id4}   ${resp['location_id']}
      # Set Suite Variable   ${ser_id8}   ${resp['service_id']}
      # Set Suite Variable   ${que_id5}   ${resp['queue_id']}
      ${loc_id4}=  Create Sample Location
      ${resp}=   Get Location ById  ${loc_id4}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
      ${SERVICE8}=    FakerLibrary.Word
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

      ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
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
      ${resp}=  Disable Queue  ${que_id5}
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
      ${resp}=  Enable Queue  ${que_id5}
      Should Be Equal As Strings  ${resp.status_code}  200
      # ${resp}=  Disable Future Checkin
      # Log   ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-AddToWaitlist-UH9
      [Documentation]   Add to waitlist after disabling service

      ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
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

      ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
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
      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
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

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${Acid}  ${resp.json()}
     
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
      ${f_name}=   FakerLibrary.first_name
      ${l_name}=   FakerLibrary.last_name
      ${dob}=      FakerLibrary.date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${Acid}  ${f_name}  ${l_name}  ${dob}  ${gender}  ${Familymember_ph}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id}  ${resp.json()}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+500001
      ${f_name}=   FakerLibrary.first_name
      ${l_name}=    FakerLibrary.last_name
      ${dob}=       FakerLibrary.date
      ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${Acid}  ${f_name}  ${l_name}  ${dob}  ${gender}   ${Familymember_ph}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id1}  ${resp.json()}
      ${resp}=  Add To Waitlist  ${Acid}  ${ser_id7}  ${que_id6}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${mem_id}  ${mem_id1}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_TIME_MORE_THAN_BUS_HOURS}"

JD-TC-AddToWaitlist-UH13
      [Documentation]   Add a consumer to a waitlist when partysize number affecting  waiting time and it becomes greater than working time

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  0  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME6}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${coid}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${coid}  ${ser_id7}  ${que_id6}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${coid} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Add To Waitlist  ${coid}  ${ser_id7}  ${que_id6}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${coid} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_TIME_MORE_THAN_BUS_HOURS}"

JD-TC-AddToWaitlist-UH14
      [Documentation]   Add a consumer to a waitlist after working time

      ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
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

JD-TC-AddToWaitlist-UH15
      [Documentation]   Add to waitlist on a non scheduled day

      ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
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

      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}  ${gender}  ${dob}  ${PUSERNAME2}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Set Suite Variable  ${coid3}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME2}${\n}
      ${resp}=  Add To Waitlist  ${coid3}  ${ser_id1}  ${que_id7}  ${DAY2}  ${desc}  ${bool[1]}  ${coid3} 
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_NON_WORKING_DAY}"

JD-TC-AddToWaitlist-UH16
      [Documentation]  update maximum capacity and check

      ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Update Queue  ${que_id7}  ${queue2}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${stime}  ${etime}  1  2  ${loc_id1}  ${ser_id1}  ${ser_id2}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${DAY2}=  db.add_timezone_date  ${tz}  1
      ${resp}=  Add To Waitlist  ${coid3}  ${ser_id1}  ${que_id7}  ${DAY2}  ${desc}  ${bool[1]}  ${coid3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}  ${gender}  ${dob}  ${PUSERNAME3}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Set Test Variable  ${cid4}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME3}${\n}
      ${resp}=  Add To Waitlist  ${cid4}  ${ser_id1}  ${que_id7}  ${DAY2}  ${desc}  ${bool[1]}  ${cid4} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name

      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}  ${gender}  ${dob}  ${PUSERNAME4}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Set Test Variable  ${cid5}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME4}${\n}
     
      ${resp}=  Add To Waitlist  ${cid5}  ${ser_id1}  ${que_id7}  ${DAY2}  ${desc}  ${bool[1]}  ${cid5} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${WATLIST_MAX_LIMIT_REACHED}"


JD-TC-AddToWaitlist-UH17
      [Documentation]  update maximum capacity and check

      ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${queue4}=    FakerLibrary.name
      Set Suite Variable    ${queue4}    
      ${DAY1}=  db.add_timezone_date  ${tz}  1
      ${resp}=  Create Queue  ${queue4}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${stime}  ${etime}  1  50  ${loc_id1}  ${ser_id3}   ${ser_id4}
      Log    ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id8}  ${resp.json()}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}  ${gender}  ${dob}  ${PUSERNAME1}  ${EMPTY}
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
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}  ${gender}  ${dob}  ${PUSERNAME7}  ${EMPTY}
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
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}  ${gender}  ${dob}  ${PUSERNAME6}  ${EMPTY}
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
      
      ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      Set Test Variable  ${jdconID}   ${resp.json()['id']}
      Set Test Variable  ${fname}   ${resp.json()['firstName']}
      Set Test Variable  ${lname}   ${resp.json()['lastName']}
      Set Test Variable  ${uname}   ${resp.json()['userName']}

      ${resp}=  Consumer Logout
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
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

      clear_location   ${PUSERNAME161}
      clear_service    ${PUSERNAME161}
      clear_customer   ${PUSERNAME161}
      clear_consumer_msgs  ${CUSERNAME12}
      clear_provider_msgs  ${PUSERNAME161}

      ${resp}=   Get Service
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=    Get Locations
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
            
      ${SERVICE1}=    FakerLibrary.Word
      ${s_id}=  Create Sample Service  ${SERVICE1}

      ${resp}=   Get Service
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

      ${lid}=  Create Sample Location  
      ${resp}=   Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
      clear_queue   ${PUSERNAME161}

      ${resp}=  Get Queues
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME12}  firstName=${fname}   lastName=${lname}
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
      ${PO_Number}    Generate random string    4    0123456789
      ${PO_Number}    Convert To Integer  ${PO_Number}
      ${country_code}    Generate random string    2    0123456789
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
      
      ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      Set Test Variable  ${jdconID}   ${resp.json()['id']}
      Set Test Variable  ${fname}   ${resp.json()['firstName']}
      Set Test Variable  ${lname}   ${resp.json()['lastName']}
      Set Test Variable  ${uname}   ${resp.json()['userName']}

      ${resp}=  Consumer Logout
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
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

      clear_location   ${PUSERNAME161}
      clear_service    ${PUSERNAME161}
      clear_customer   ${PUSERNAME161}
      clear_consumer_msgs  ${CUSERNAME12}
      clear_provider_msgs  ${PUSERNAME161}

      ${resp}=   Get Service
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=    Get Locations
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
            
      ${SERVICE1}=    FakerLibrary.Word
      ${s_id}=  Create Sample Service  ${SERVICE1}

      ${resp}=   Get Service
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

      ${lid}=  Create Sample Location  
      ${resp}=   Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
      clear_queue   ${PUSERNAME161}

      ${resp}=  Get Queues
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME12}  firstName=${fname}   lastName=${lname}
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
      ${PO_Number}    Generate random string    4    0123456789
      ${PO_Number}    Convert To Integer  ${PO_Number}
      ${country_code}    Generate random string    2    0123456789
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
      
      ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      Set Test Variable  ${jdconID}   ${resp.json()['id']}
      Set Test Variable  ${fname}   ${resp.json()['firstName']}
      Set Test Variable  ${lname}   ${resp.json()['lastName']}
      Set Test Variable  ${uname}   ${resp.json()['userName']}

      ${resp}=  Consumer Logout
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
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

      clear_location   ${PUSERNAME161}
      clear_service    ${PUSERNAME161}
      clear_customer   ${PUSERNAME161}
      clear_consumer_msgs  ${CUSERNAME12}
      clear_provider_msgs  ${PUSERNAME161}

      ${resp}=   Get Service
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=    Get Locations
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
            
      ${SERVICE1}=    FakerLibrary.Word
      ${s_id}=  Create Sample Service  ${SERVICE1}

      ${resp}=   Get Service
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

      ${lid}=  Create Sample Location  
      ${resp}=   Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
      clear_queue   ${PUSERNAME161}

      ${resp}=  Get Queues
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME12}  firstName=${fname}   lastName=${lname}
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
      ${PO_Number}    Generate random string    4    0123456789
      ${PO_Number}    Convert To Integer  ${PO_Number}
      ${country_code}    Generate random string    2    0123456789
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
      
      ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      Set Test Variable  ${jdconID}   ${resp.json()['id']}
      Set Test Variable  ${fname}   ${resp.json()['firstName']}
      Set Test Variable  ${lname}   ${resp.json()['lastName']}
      Set Test Variable  ${uname}   ${resp.json()['userName']}

      ${resp}=  Consumer Logout
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
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

      clear_location   ${PUSERNAME161}
      clear_service    ${PUSERNAME161}
      clear_customer   ${PUSERNAME161}
      clear_consumer_msgs  ${CUSERNAME12}
      clear_provider_msgs  ${PUSERNAME161}

      ${resp}=   Get Service
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=    Get Locations
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
            
      ${SERVICE1}=    FakerLibrary.Word
      ${s_id}=  Create Sample Service  ${SERVICE1}

      ${resp}=   Get Service
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

      ${lid}=  Create Sample Location  
      ${resp}=   Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
      clear_queue   ${PUSERNAME161}

      ${resp}=  Get Queues
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME12}  firstName=${fname}   lastName=${lname}
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
      ${PO_Number}    Generate random string    4    0123456789
      ${PO_Number}    Convert To Integer  ${PO_Number}
      ${country_code}    Generate random string    2    0123456789
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
      
      ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      Set Test Variable  ${jdconID}   ${resp.json()['id']}
      Set Test Variable  ${fname}   ${resp.json()['firstName']}
      Set Test Variable  ${lname}   ${resp.json()['lastName']}
      Set Test Variable  ${uname}   ${resp.json()['userName']}

      ${resp}=  Consumer Logout
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
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

      clear_location   ${PUSERNAME161}
      clear_service    ${PUSERNAME161}
      clear_customer   ${PUSERNAME161}
      clear_consumer_msgs  ${CUSERNAME12}
      clear_provider_msgs  ${PUSERNAME161}

      ${resp}=   Get Service
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=    Get Locations
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
            
      ${SERVICE1}=    FakerLibrary.Word
      ${s_id}=  Create Sample Service  ${SERVICE1}

      ${resp}=   Get Service
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

      ${lid}=  Create Sample Location  
      ${resp}=   Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
      clear_queue   ${PUSERNAME161}

      ${resp}=  Get Queues
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME12}  firstName=${fname}   lastName=${lname}
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
      ${PO_Number}    Generate random string    4    0123456789
      ${PO_Number}    Convert To Integer  ${PO_Number}
      ${country_code}    Generate random string    2    0123456789
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







