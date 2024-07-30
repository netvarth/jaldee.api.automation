*** Settings ***
Suite Teardown    Delete All Sessions 
Test Teardown     Run Keywords  Delete All Sessions  resetsystem_time
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

*** Variables ***

${waitlistedby}           PROVIDER
${SERVICE1}    SERVICE1
${SERVICE2}    SERVICE2

*** Test Cases ***

JD-TC-GetWaitlistHistoryCount-1 

      [Documentation]   View Waitlist by Provider login

      clear_queue      ${PUSERNAME26}
      clear_location   ${PUSERNAME26}
      clear_service    ${PUSERNAME26}
     
      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${ser_durtn}=   Random Int   min=2   max=10
      ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${ser_durtn}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      change_system_date  -3
      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${DAY1}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable  ${DAY1} 
      ${lid}=   Create Sample Location
      Set Suite Variable    ${lid} 
      ${s_id1}=   Create Sample Service  ${SERVICE1}
      Set Suite Variable    ${s_id1}   
      ${s_id2}=   Create Sample Service  ${SERVICE2}
      Set Suite Variable    ${s_id2} 
      ${q_name}=    FakerLibrary.name
      Set Suite Variable    ${q_name}
      ${list}=  Create List   1  2  3  4  5  6  7
      Set Suite Variable    ${list}
      ${strt_time}=   db.subtract_timezone_time  ${tz}  2  00
      Set Suite Variable    ${strt_time}
      ${end_time}=    add_timezone_time  ${tz}       0  20 
      Set Suite Variable    ${end_time} 
      ${capacity}=  Random Int  min=8   max=20
      ${parallel}=  Random Int   min=1   max=2
      Set Suite Variable   ${parallel}
      Set Suite Variable   ${capacity}  
      ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${lid}  ${s_id1}  ${s_id2}  
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${qid1}   ${resp.json()} 
      ${desc}=   FakerLibrary.word
      Set Suite Variable   ${desc}
      # ${id}=  get_id  ${CUSERNAME0}
      ${resp}=  Get Consumer By Id  ${CUSERNAME0}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cname0}   ${resp.json()['userProfile']['firstName']}
      Set Test Variable  ${lname0}   ${resp.json()['userProfile']['lastName']}

      ${resp}=  AddCustomer  ${CUSERNAME0}  firstName=${cname0}   lastName=${lname0}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${id0}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${id0}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${id0}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id}  ${tid[0]}
      ${resp}=  Get provider communications
      Should Be Equal As Strings  ${resp.status_code}  200
      # ${id}=  get_id  ${CUSERNAME1}
      ${resp}=  Get Consumer By Id  ${CUSERNAME1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cname1}   ${resp.json()['userProfile']['firstName']}
      Set Test Variable  ${lname1}   ${resp.json()['userProfile']['lastName']}

      ${resp}=  AddCustomer  ${CUSERNAME1}  firstName=${cname1}   lastName=${lname1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${id1}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${id1}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${id1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id1}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id1}  ${tid[0]}
      # ${id}=  get_id  ${CUSERNAME2}
      ${resp}=  Get Consumer By Id  ${CUSERNAME2}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cname2}   ${resp.json()['userProfile']['firstName']}
      Set Test Variable  ${lname2}   ${resp.json()['userProfile']['lastName']}

      ${resp}=  AddCustomer  ${CUSERNAME2}  firstName=${cname2}   lastName=${lname2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${id}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${id}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${id}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id2}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id2}  ${tid[0]}
      # ${id}=  get_id  ${CUSERNAME3}
      ${resp}=  Get Consumer By Id  ${CUSERNAME3}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cname3}   ${resp.json()['userProfile']['firstName']}
      Set Test Variable  ${lname3}   ${resp.json()['userProfile']['lastName']}

      ${resp}=  AddCustomer  ${CUSERNAME3}  firstName=${cname3}   lastName=${lname3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${id}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${id}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${id}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id3}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id3}  ${tid[0]}
      resetsystem_time
      ${T_DAY}=  db.get_date_by_timezone  ${tz}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Provider Waitlist History
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable    ${cname1}    ${resp.json()[0]['consumer']['firstName']}
      Set Suite Variable    ${cname2}    ${resp.json()[1]['consumer']['firstName']}
      Set Suite Variable    ${cname3}    ${resp.json()[2]['consumer']['firstName']}
      Set Suite Variable    ${cname4}    ${resp.json()[3]['consumer']['firstName']}
      ${resp}=  Get Waitlist Count History
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  4
      
JD-TC-GetWaitlistHistoryCount-2
      [Documentation]   View Waitlist after cancel

      change_system_date  -3
      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action Cancel   ${waitlist_id}  ${waitlist_cancl_reasn[4]}   ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist By Id  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  waitlistStatus=${wl_status[4]}
      resetsystem_time
      ${T_DAY}=  db.get_date_by_timezone  ${tz}
      Log  ${T_DAY}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200    
      ${resp}=  Get Waitlist Count History  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1
      ${resp}=  Get Waitlist Count History  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3
         
JD-TC-GetWaitlistHistoryCount-3
      [Documentation]   Get waitlist waitlistStatus-neq=arrived from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  waitlistStatus-neq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1
         
JD-TC-GetWaitlistHistoryCount-4
      [Documentation]   Get waitlist waitlistStatus-neq=cancelled from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3

JD-TC-GetWaitlistHistoryCount-5
      [Documentation]   Get waitlist firstName-eq=${cname1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  firstName-eq=${cname1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1
 
JD-TC-GetWaitlistHistoryCount-6
      [Documentation]   Get waitlist firstName-neq=${cname1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  firstName-neq=${cname1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3
     
JD-TC-GetWaitlistHistoryCount-7
      [Documentation]   Get waitlist firstName-eq=${cname2}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  firstName-eq=${cname2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistHistoryCount-8
      [Documentation]   Get waitlist firstName-neq=${cname2}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  firstName-neq=${cname2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3
     
JD-TC-GetWaitlistHistoryCount-9
      [Documentation]   Get waitlist service-eq=${s_id1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  service-eq=${s_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  4
    
JD-TC-GetWaitlistHistoryCount-10
      [Documentation]   Get waitlist service-neq=${s_id1}  from=0  count=10

      change_system_date  -3
      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200    
      ${DAY1}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable  ${DAY1}  
      # ${id}=  get_id  ${CUSERNAME0}
      ${resp}=  Add To Waitlist  ${id0}  ${s_id2}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${id0}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id4}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id4}  ${tid[0]}
      # ${id}=  get_id  ${CUSERNAME1}
      ${resp}=  Add To Waitlist  ${id1}  ${s_id2}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${id1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id5}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id5}  ${tid[0]}
      resetsystem_time
      ${T_DAY}=  db.get_date_by_timezone  ${tz}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist Count History  service-neq=${s_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2

JD-TC-GetWaitlistHistoryCount-11
      [Documentation]   Get waitlist firstName-eq=${cname1}  waitlistStatus-eq=cancelled from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  0
  
JD-TC-GetWaitlistHistoryCount-12
      [Documentation]   Get waitlist firstName-neq=${cname1}  waitlistStatus-neq=cancelled from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  firstName-neq=${cname1}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  4
 
JD-TC-GetWaitlistHistoryCount-13
      [Documentation]   Get waitlist firstName-eq=${cname1}  waitlistStatus-eq=arrived from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1
 
JD-TC-GetWaitlistHistoryCount-14
      [Documentation]   Get waitlist firstName-eq=${cname2}  waitlistStatus-eq=cancelled from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  firstName-eq=${cname2}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  0

JD-TC-GetWaitlistHistoryCount-15
      [Documentation]   Get waitlist firstName-neq=${cname2}  waitlistStatus-neq=cancelled from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  firstName-neq=${cname2}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  4
    
JD-TC-GetWaitlistHistoryCount-16
      [Documentation]   Get waitlist firstName-eq=${cname2}  waitlistStatus-eq=arrived from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  firstName-eq=${cname2}  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1
   
JD-TC-GetWaitlistHistoryCount-17    
      [Documentation]   Get waitlist firstName-eq=${cname1}  service-eq=${s_id1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  firstName-eq=${cname1}  service-eq=${s_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1
   
JD-TC-GetWaitlistHistoryCount-18
      [Documentation]   Get waitlist firstName-neq=${cname1}  service-neq=${s_id1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  firstName-neq=${cname1}  service-neq=${s_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2

JD-TC-GetWaitlistHistoryCount-19
      [Documentation]   Get waitlist firstName-eq=${cname2}  service-eq=${s_id1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  firstName-eq=${cname2}  service-eq=${s_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1
   
JD-TC-GetWaitlistHistoryCount-20
      [Documentation]   Get waitlist firstName-neq=${cname2}  service-neq=${s_id1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  firstName-neq=${cname2}  service-neq=${s_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2

JD-TC-GetWaitlistHistoryCount-21
      [Documentation]   Get waitlist firstName-eq=${cname1}  service-eq=${s_id2} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  firstName-eq=${cname1}  service-eq=${s_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  0

JD-TC-GetWaitlistHistoryCount-22
      [Documentation]   Get waitlist firstName-neq=${cname1}  service-neq=${s_id2} from=0  count=10
      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  firstName-neq=${cname1}  service-neq=${s_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3

JD-TC-GetWaitlistHistoryCount-23
      [Documentation]   Get waitlist firstName-eq=${cname2}  service-eq=${s_id2} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  firstName-eq=${cname2}  service-eq=${s_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  0

JD-TC-GetWaitlistHistoryCount-24
      [Documentation]   Get waitlist firstName-neq=${cname2}  service-neq=${s_id2} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  firstName-neq=${cname2}  service-neq=${s_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3

JD-TC-GetWaitlistHistoryCount-25
      [Documentation]   Get waitlist service-eq=${s_id1}   waitlistStatus-eq=cancelled  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  service-eq=${s_id1}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1
 
JD-TC-GetWaitlistHistoryCount-26
      [Documentation]   Get waitlist service-neq=${s_id1}  waitlistStatus-neq=cancelled  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Get Waitlist Count History  service-neq=${s_id1}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2
 
JD-TC-GetWaitlistHistoryCount-27
      [Documentation]   Get waitlist service-eq=${s_id1}   waitlistStatus-eq=arrived  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  service-eq=${s_id1}  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3
 
JD-TC-GetWaitlistHistoryCount-28
      [Documentation]   Get waitlist service-eq=${s_id2}   waitlistStatus-eq=arrived  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  service-eq=${s_id2}  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2

JD-TC-GetWaitlistHistoryCount-29
      [Documentation]   Get waitlist service-eq=${s_id2}   waitlistStatus-eq=cancelled  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  service-eq=${s_id2}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  0

JD-TC-GetWaitlistHistoryCount-30
      [Documentation]   Get waitlist service-neq=${s_id2}  waitlistStatus-neq=cancelled  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Get Waitlist Count History  service-neq=${s_id2}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3

JD-TC-GetWaitlistHistoryCount-31
      [Documentation]   Get waitlist token_id-eq=${token_id}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  token-eq=${token_id}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1
 
JD-TC-GetWaitlistHistoryCount-32
      [Documentation]   Get waitlist token_id-neq=${token_id}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  token-neq=${token_id}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  5

JD-TC-GetWaitlistHistoryCount-33
      [Documentation]   Get waitlist token_id-eq=${token_id}  service-eq=${s_id1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  token-eq=${token_id}  service-eq=${s_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistHistoryCount-34
      [Documentation]   Get waitlist token_id-neq=${token_id}  service-neq=${s_id2}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  token-neq=${token_id}  service-neq=${s_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3

JD-TC-GetWaitlistHistoryCount-35
      [Documentation]   Get waitlist firstName-eq=${cname1}  date-eq=${DAY1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  firstName-eq=${cname1}  date-eq=${DAY1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1
 
JD-TC-GetWaitlistHistoryCount-36
      [Documentation]   Get waitlist  date-neq=${DAY1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  date-neq=${DAY1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  0
   
JD-TC-GetWaitlistHistoryCount-37
      [Documentation]   Get waitlist date-eq=${DAY1}  service-neq=${s_id2}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  date-eq=${DAY1}  service-neq=${s_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  4

JD-TC-GetWaitlistHistoryCount-38
      [Documentation]   Get waitlist waitlistStatus-eq=cancelled   date-eq=${DAY1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  waitlistStatus-eq=${wl_status[4]}  date-eq=${DAY1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistHistoryCount-39
      [Documentation]   Get waitlist queue-eq   from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  queue-eq=${qid1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  6

JD-TC-GetWaitlistHistoryCount-40
      [Documentation]   Get waitlist queue-neq   from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  queue-neq=${qid1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  0

JD-TC-GetWaitlistHistoryCount-41
      [Documentation]   Get waitlist queue-eq  and token-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  queue-eq=${qid1}  token-eq=${token_id}    from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistHistoryCount-42
      [Documentation]   Get waitlist queue-eq  and token-neq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  queue-eq=${qid1}  token-neq=${token_id}    from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  5
      
JD-TC-GetWaitlistHistoryCount-43
      [Documentation]   Get waitlist queue-eq  and firstName-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  queue-eq=${qid1}  firstName-eq=${cname2}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1
      
JD-TC-GetWaitlistHistoryCount-44
      [Documentation]   Get waitlist queue-eq  and service-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  queue-eq=${qid1}  service-eq=${s_id1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  4

JD-TC-GetWaitlistHistoryCount-45
      [Documentation]   Get waitlist queue-eq  and  waitlistStatus-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  queue-eq=${qid1}  waitlistStatus-eq=${wl_status[4]}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1
    
JD-TC-GetWaitlistHistoryCount-46
      [Documentation]   Get waitlist queue-eq  and  date-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  queue-eq=${qid1}  date-eq=${DAY1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  6

JD-TC-GetWaitlistHistoryCount-47
      [Documentation]   Get waitlist location-eq   from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  location-eq=${lid}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  6

JD-TC-GetWaitlistHistoryCount-48
      [Documentation]   Get waitlist location-neq=${lid}   from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  location-neq=${lid}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  0

JD-TC-GetWaitlistHistoryCount-49
      [Documentation]   Get waitlist location-eq=${lid}  and token-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  location-eq=${lid}  token-eq=${token_id}    from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistHistoryCount-50
      [Documentation]   Get waitlist location-eq=${lid}  and token-neq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  location-eq=${lid}  token-neq=${token_id}    from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  5

JD-TC-GetWaitlistHistoryCount-51
      [Documentation]   Get waitlist location-eq=${lid}  and firstName-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  location-eq=${lid}  firstName-eq=${cname2}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistHistoryCount-52
      [Documentation]   Get waitlist location-eq=${lid}  and service-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  location-eq=${lid}  service-eq=${s_id1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  4

JD-TC-GetWaitlistHistoryCount-53
      [Documentation]   Get waitlist location-eq=${lid}  and  waitlistStatus-eq= cancelled from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  location-eq=${lid}  waitlistStatus-eq=${wl_status[4]}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistHistoryCount-54
      [Documentation]   Get waitlist location-eq=${lid}  and  date-eq=${DAY1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  location-eq=${lid}  date-eq=${DAY1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  6

JD-TC-GetWaitlistHistoryCount-55
      [Documentation]   Get waitlist location-eq=${lid}  and  queue-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count History  location-eq=${lid}  queue-eq=${qid1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  6
  
JD-TC-GetWaitlistHistoryCount-UH1
      [Documentation]   Get waitlist using consumer login

      ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Get Waitlist Count History  service-neq=${s_id2}  waitlistStatus-neq=${wl_status[1]}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings   "${resp.json()}"     "${LOGIN_NO_ACCESS_FOR_URL}"
      
JD-TC-GetWaitlistHistoryCount-UH2
      [Documentation]   Get waitlist without login

      ${resp}=  Get Waitlist Count History  service-neq=${s_id2}  waitlistStatus-neq=${wl_status[1]}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  419
      Should Be Equal As Strings   "${resp.json()}"     "${SESSION_EXPIRED}"
