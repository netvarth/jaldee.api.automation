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

${waitlistedby}   PROVIDER
${SERVICE1}    SERVICE1
${SERVICE2}    SERVICE2

*** Test Cases ***

JD-TC-GetWaitlistHistory-1

      [Documentation]   View Waitlist by Provider login

      clear_queue      ${PUSERNAME24}
      clear_location   ${PUSERNAME24}
      clear_service    ${PUSERNAME24}
     
      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${ser_durtn}=   Random Int   min=2   max=10
      ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${ser_durtn}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      change_system_date  -3
      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
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
      Log   ${resp.json()}
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
      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist History
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable    ${cname4}    ${resp.json()[0]['consumer']['firstName']}
      Set Suite Variable    ${cname3}    ${resp.json()[1]['consumer']['firstName']}
      Set Suite Variable    ${cname2}    ${resp.json()[2]['consumer']['firstName']}
      Set Suite Variable    ${cname1}    ${resp.json()[3]['consumer']['firstName']}
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  4
      Verify Response List  ${resp}  0  token=${token_id3}  ynwUuid=h_${waitlist_id3}  date=${DAY1}  waitlistStatus=${wl_status[1]}   partySize=1  waitlistedBy=${waitlistedby} 
      Should Be Equal As Strings  ${resp.json()[0]['service']['name']}  ${SERVICE1}
      Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${s_id1}
      Verify Response List  ${resp}  1  token=${token_id2}  ynwUuid=h_${waitlist_id2}  date=${DAY1}  waitlistStatus=${wl_status[1]}   partySize=1  waitlistedBy=${waitlistedby} 
      Should Be Equal As Strings  ${resp.json()[0]['service']['name']}  ${SERVICE1}
      Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${s_id1}
      Verify Response List  ${resp}  2  token=${token_id1}  ynwUuid=h_${waitlist_id1}  date=${DAY1}  waitlistStatus=${wl_status[1]}   partySize=1  waitlistedBy=${waitlistedby} 
      Should Be Equal As Strings  ${resp.json()[0]['service']['name']}  ${SERVICE1}
      Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${s_id1}
      Verify Response List  ${resp}  3  token=${token_id}  ynwUuid=h_${waitlist_id}  date=${DAY1}  waitlistStatus=${wl_status[1]}   partySize=1  waitlistedBy=${waitlistedby} 
      Should Be Equal As Strings  ${resp.json()[0]['service']['name']}  ${SERVICE1}
      Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${s_id1}

JD-TC-GetWaitlistHistory-2

      [Documentation]   View Waitlist after cancel

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist History
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      change_system_date  -3
      ${samday}=  db.get_date_by_timezone  ${tz}
      ${resp}=  Waitlist Action Cancel  ${waitlist_id}  ${waitlist_cancl_reasn[4]}   ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200     
      ${resp}=  Get Waitlist By Id  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  waitlistStatus=${wl_status[4]}
      resetsystem_time
      ${T_DAY}=  db.get_date_by_timezone  ${tz}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist By Id  ${waitlist_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist History
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist History  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Log   ${resp.json()}
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id}
      ${resp}=  Get Waitlist History  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id3}
      Verify Response List  ${resp}  1  ynwUuid=h_${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=h_${waitlist_id1}
   
JD-TC-GetWaitlistHistory-3
      [Documentation]   Get waitlist waitlistStatus-neq=arrived from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist History  waitlistStatus-neq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id}
      
JD-TC-GetWaitlistHistory-4
      [Documentation]   Get waitlist waitlistStatus-neq=cancelled from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id3}
      Verify Response List  ${resp}  1  ynwUuid=h_${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=h_${waitlist_id1}
 
JD-TC-GetWaitlistHistory-5
      [Documentation]   Get waitlist firstName-eq=${cname1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  firstName-eq=${cname1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id}

JD-TC-GetWaitlistHistory-6
      [Documentation]   Get waitlist firstName-neq=${cname1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  firstName-neq=${cname1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id3}
      Verify Response List  ${resp}  1  ynwUuid=h_${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=h_${waitlist_id1}

JD-TC-GetWaitlistHistory-7
      [Documentation]   Get waitlist firstName-eq=${cname2}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  firstName-eq=${cname2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id1}

JD-TC-GetWaitlistHistory-8
      [Documentation]   Get waitlist firstName-neq=${cname2}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History   firstName-neq=${cname2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id3}
      Verify Response List  ${resp}  1  ynwUuid=h_${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=h_${waitlist_id}

JD-TC-GetWaitlistHistory-9
      [Documentation]   Get waitlist service-eq=${s_id1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  service-eq=${s_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  4
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id3}
      Verify Response List  ${resp}  1  ynwUuid=h_${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=h_${waitlist_id1}
      Verify Response List  ${resp}  3  ynwUuid=h_${waitlist_id}

JD-TC-GetWaitlistHistory-10

      [Documentation]   Get waitlist service-neq=${s_id1}  from=0  count=10
   
      change_system_date  -3
      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
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
      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist History  service-neq=${s_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id5}
      Verify Response List  ${resp}  1  ynwUuid=h_${waitlist_id4}

JD-TC-GetWaitlistHistory-11
      [Documentation]   Get waitlist firstName-eq=${cname1}  waitlistStatus-eq=cancelled from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Get Waitlist History  firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id}

JD-TC-GetWaitlistHistory-12
      [Documentation]   Get waitlist firstName-neq=${cname1}  waitlistStatus-neq=cancelled from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  firstName-neq=${cname1}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  4
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id5}
      Verify Response List  ${resp}  1  ynwUuid=h_${waitlist_id3}
      Verify Response List  ${resp}  2  ynwUuid=h_${waitlist_id2}
      Verify Response List  ${resp}  3  ynwUuid=h_${waitlist_id1}

JD-TC-GetWaitlistHistory-13
      [Documentation]   Get waitlist firstName-eq=${cname1}  waitlistStatus-eq=arrived from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1    
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id4}

JD-TC-GetWaitlistHistory-14
      [Documentation]   Get waitlist firstName-eq=${cname2}  waitlistStatus-eq=cancelled from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  firstName-eq=${cname2}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  0

JD-TC-GetWaitlistHistory-15
      [Documentation]   Get waitlist firstName-neq=${cname2}  waitlistStatus-neq=cancelled from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  firstName-neq=${cname2}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id4}
      Verify Response List  ${resp}  1  ynwUuid=h_${waitlist_id3}
      Verify Response List  ${resp}  2  ynwUuid=h_${waitlist_id2}

JD-TC-GetWaitlistHistory-16
      [Documentation]   Get waitlist firstName-eq=${cname2}  waitlistStatus-eq=arrived from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  firstName-eq=${cname2}  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id5}
      Verify Response List  ${resp}  1  ynwUuid=h_${waitlist_id1}
 
JD-TC-GetWaitlistHistory-17    
      [Documentation]   Get waitlist firstName-eq=${cname1}  service-eq=${s_id1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  firstName-eq=${cname1}  service-eq=${s_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id}

JD-TC-GetWaitlistHistory-18
      [Documentation]   Get waitlist firstName-neq=${cname1}  service-neq=${s_id1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  firstName-neq=${cname1}  service-neq=${s_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id5}

JD-TC-GetWaitlistHistory-19
      [Documentation]   Get waitlist firstName-eq=${cname2}  service-eq=${s_id1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  firstName-eq=${cname2}  service-eq=${s_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id1}

JD-TC-GetWaitlistHistory-20
      [Documentation]   Get waitlist firstName-neq=${cname2}  service-neq=${s_id1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  firstName-neq=${cname2}  service-neq=${s_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id4}
   
JD-TC-GetWaitlistHistory-21
      [Documentation]   Get waitlist firstName-eq=${cname1}  service-eq=${s_id2} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  firstName-eq=${cname1}  service-eq=${s_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id4}

JD-TC-GetWaitlistHistory-22
      [Documentation]   Get waitlist firstName-neq=${cname1}  service-neq=${s_id2} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  firstName-neq=${cname1}  service-neq=${s_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id3}
      Verify Response List  ${resp}  1  ynwUuid=h_${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=h_${waitlist_id1}

JD-TC-GetWaitlistHistory-23
      [Documentation]   Get waitlist firstName-eq=${cname2}  service-eq=${s_id2} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  firstName-eq=${cname2}  service-eq=${s_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id5}

JD-TC-GetWaitlistHistory-24
      [Documentation]   Get waitlist firstName-neq=${cname2}  service-neq=${s_id2} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  firstName-neq=${cname2}  service-neq=${s_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id3}
      Verify Response List  ${resp}  1  ynwUuid=h_${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=h_${waitlist_id} 

JD-TC-GetWaitlistHistory-25
      [Documentation]   Get waitlist service-eq=${s_id1}   waitlistStatus-eq=${wl_status[4]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  service-eq=${s_id1}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id}

JD-TC-GetWaitlistHistory-26
      [Documentation]   Get waitlist service-neq=${s_id1}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Get Waitlist History  service-neq=${s_id1}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id5}
      Verify Response List  ${resp}  1  ynwUuid=h_${waitlist_id4}

JD-TC-GetWaitlistHistory-27
      [Documentation]   Get waitlist service-eq=${s_id1}   waitlistStatus-eq=${wl_status[1]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  service-eq=${s_id1}  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id3}
      Verify Response List  ${resp}  1  ynwUuid=h_${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=h_${waitlist_id1}

JD-TC-GetWaitlistHistory-28
      [Documentation]   Get waitlist service-eq=${s_id2}   waitlistStatus-eq=${wl_status[1]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  service-eq=${s_id2}  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id5}
      Verify Response List  ${resp}  1  ynwUuid=h_${waitlist_id4}

JD-TC-GetWaitlistHistory-29
      [Documentation]   Get waitlist service-eq=${s_id2}   waitlistStatus-eq=${wl_status[4]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  service-eq=${s_id2}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  0

JD-TC-GetWaitlistHistory-30
      [Documentation]   Get waitlist service-neq=${s_id2}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Get Waitlist History  service-neq=${s_id2}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id3}
      Verify Response List  ${resp}  1  ynwUuid=h_${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=h_${waitlist_id1}

JD-TC-GetWaitlistHistory-31
      [Documentation]   Get waitlist token_id-eq=${token_id}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  token-eq=${token_id}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  token=${token_id}

JD-TC-GetWaitlistHistory-32
      [Documentation]   Get waitlist token_id-neq=${token_id}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  token-neq=${token_id}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  5
      Verify Response List  ${resp}  0  token=${token_id5}
      Verify Response List  ${resp}  1  token=${token_id4}
      Verify Response List  ${resp}  2  token=${token_id3}
      Verify Response List  ${resp}  3  token=${token_id2}
      Verify Response List  ${resp}  4  token=${token_id1}

JD-TC-GetWaitlistHistory-33
      [Documentation]   Get waitlist token_id-eq=${token_id}  service-eq=${s_id1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  token-eq=${token_id}  service-eq=${s_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  token=${token_id}

JD-TC-GetWaitlistHistory-34
      [Documentation]   Get waitlist token_id-neq=${token_id}  service-neq=${s_id2}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  token-neq=${token_id}  service-neq=${s_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  token=${token_id3}
      Verify Response List  ${resp}  1  token=${token_id2}
      Verify Response List  ${resp}  2  token=${token_id1}

JD-TC-GetWaitlistHistory-35
      [Documentation]   Get waitlist firstName-eq=${cname1}  date-eq=${DAY1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  firstName-eq=${cname1}  date-eq=${DAY1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  token=${token_id4}
      Verify Response List  ${resp}  1  token=${token_id}

JD-TC-GetWaitlistHistory-36
      [Documentation]   Get waitlist  date-neq=${DAY1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  date-neq=${DAY1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  0
   
JD-TC-GetWaitlistHistory-37
      [Documentation]   Get waitlist date-eq=${DAY1}  service-neq=${s_id2}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  date-eq=${DAY1}  service-neq=${s_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  4
      Verify Response List  ${resp}  0  token=${token_id3}
      Verify Response List  ${resp}  1  token=${token_id2}
      Verify Response List  ${resp}  2  token=${token_id1}
      Verify Response List  ${resp}  3  token=${token_id}

JD-TC-GetWaitlistHistory-38
      [Documentation]   Get waitlist waitlistStatus-eq=${wl_status[4]}   date-eq=${DAY1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  waitlistStatus-eq=${wl_status[4]}  date-eq=${DAY1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  token=${token_id}

JD-TC-GetWaitlistHistory-39
      [Documentation]   Get waitlist queue-eq   from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  queue-eq=${qid1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  6
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id5}
      Verify Response List  ${resp}  1  ynwUuid=h_${waitlist_id4}
      Verify Response List  ${resp}  2  ynwUuid=h_${waitlist_id3}
      Verify Response List  ${resp}  3  ynwUuid=h_${waitlist_id2}
      Verify Response List  ${resp}  4  ynwUuid=h_${waitlist_id1}
      Verify Response List  ${resp}  5  ynwUuid=h_${waitlist_id}

JD-TC-GetWaitlistHistory-40
      [Documentation]   Get waitlist queue-neq   from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  queue-neq=${qid1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  0

JD-TC-GetWaitlistHistory-41
      [Documentation]   Get waitlist queue-eq  and token-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  queue-eq=${qid1}  token-eq=${token_id}    from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  token=${token_id}

JD-TC-GetWaitlistHistory-42
      [Documentation]   Get waitlist queue-eq  and token-neq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  queue-eq=${qid1}  token-neq=${token_id}    from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  5
      Verify Response List  ${resp}  0  token=${token_id5}
      Verify Response List  ${resp}  1  token=${token_id4}
      Verify Response List  ${resp}  2  token=${token_id3}
      Verify Response List  ${resp}  3  token=${token_id2}
      Verify Response List  ${resp}  4  token=${token_id1}

JD-TC-GetWaitlistHistory-43
      [Documentation]   Get waitlist queue-eq  and firstName-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  queue-eq=${qid1}  firstName-eq=${cname2}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id5}
      Verify Response List  ${resp}  1  ynwUuid=h_${waitlist_id1}

JD-TC-GetWaitlistHistory-44
      [Documentation]   Get waitlist queue-eq  and service-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  queue-eq=${qid1}  service-eq=${s_id1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  4
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id3}
      Verify Response List  ${resp}  1  ynwUuid=h_${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=h_${waitlist_id1}
      Verify Response List  ${resp}  3  ynwUuid=h_${waitlist_id}

JD-TC-GetWaitlistHistory-45
      [Documentation]   Get waitlist queue-eq  and  waitlistStatus-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  queue-eq=${qid1}  waitlistStatus-eq=${wl_status[4]}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id}

JD-TC-GetWaitlistHistory-46
      [Documentation]   Get waitlist queue-eq  and  date-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  queue-eq=${qid1}  date-eq=${DAY1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  6
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id5}
      Verify Response List  ${resp}  1  ynwUuid=h_${waitlist_id4}
      Verify Response List  ${resp}  2  ynwUuid=h_${waitlist_id3}
      Verify Response List  ${resp}  3  ynwUuid=h_${waitlist_id2}
      Verify Response List  ${resp}  4  ynwUuid=h_${waitlist_id1}
      Verify Response List  ${resp}  5  ynwUuid=h_${waitlist_id}

JD-TC-GetWaitlistHistory-47
      [Documentation]   Get waitlist location-eq   from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  location-eq=${lid}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  6
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id5}
      Verify Response List  ${resp}  1  ynwUuid=h_${waitlist_id4}
      Verify Response List  ${resp}  2  ynwUuid=h_${waitlist_id3}
      Verify Response List  ${resp}  3  ynwUuid=h_${waitlist_id2}
      Verify Response List  ${resp}  4  ynwUuid=h_${waitlist_id1}
      Verify Response List  ${resp}  5  ynwUuid=h_${waitlist_id}

JD-TC-GetWaitlistHistory-48
      [Documentation]   Get waitlist location-neq=${lid}   from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  location-neq=${lid}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  0

JD-TC-GetWaitlistHistory-49
      [Documentation]   Get waitlist location-eq=${lid}  and token-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  location-eq=${lid}  token-eq=${token_id}    from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  token=${token_id}

JD-TC-GetWaitlistHistory-50
      [Documentation]   Get waitlist location-eq=${lid}  and token-neq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  location-eq=${lid}  token-neq=${token_id}    from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  5
      Verify Response List  ${resp}  0  token=${token_id5}
      Verify Response List  ${resp}  1  token=${token_id4}
      Verify Response List  ${resp}  2  token=${token_id3}
      Verify Response List  ${resp}  3  token=${token_id2}
      Verify Response List  ${resp}  4  token=${token_id1}

JD-TC-GetWaitlistHistory-51
      [Documentation]   Get waitlist location-eq=${lid}  and firstName-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  location-eq=${lid}  firstName-eq=${cname2}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id5}
      Verify Response List  ${resp}  1  ynwUuid=h_${waitlist_id1}

JD-TC-GetWaitlistHistory-52
      [Documentation]   Get waitlist location-eq=${lid}  and service-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  location-eq=${lid}  service-eq=${s_id1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  4
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id3}
      Verify Response List  ${resp}  1  ynwUuid=h_${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=h_${waitlist_id1}
      Verify Response List  ${resp}  3  ynwUuid=h_${waitlist_id}

JD-TC-GetWaitlistHistory-53
      [Documentation]   Get waitlist location-eq=${lid}  and  waitlistStatus-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  location-eq=${lid}  waitlistStatus-eq=${wl_status[4]}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id}

JD-TC-GetWaitlistHistory-54
      [Documentation]   Get waitlist location-eq=${lid}  and  date-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  location-eq=${lid}  date-eq=${DAY1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  6
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id5}
      Verify Response List  ${resp}  1  ynwUuid=h_${waitlist_id4}
      Verify Response List  ${resp}  2  ynwUuid=h_${waitlist_id3}
      Verify Response List  ${resp}  3  ynwUuid=h_${waitlist_id2}
      Verify Response List  ${resp}  4  ynwUuid=h_${waitlist_id1}
      Verify Response List  ${resp}  5  ynwUuid=h_${waitlist_id}

JD-TC-GetWaitlistHistory-55
      [Documentation]   Get waitlist location-eq=${lid}  and  queue-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist History  location-eq=${lid}  queue-eq=${qid1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  6
      Verify Response List  ${resp}  0  ynwUuid=h_${waitlist_id5}
      Verify Response List  ${resp}  1  ynwUuid=h_${waitlist_id4}
      Verify Response List  ${resp}  2  ynwUuid=h_${waitlist_id3}
      Verify Response List  ${resp}  3  ynwUuid=h_${waitlist_id2}
      Verify Response List  ${resp}  4  ynwUuid=h_${waitlist_id1}
      Verify Response List  ${resp}  5  ynwUuid=h_${waitlist_id}
      
JD-TC-GetWaitlistHistory-UH1
      [Documentation]   Get waitlist using consumer login

      ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Get Waitlist History  service-neq=${s_id2}  waitlistStatus-neq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings   "${resp.json()}"     "${LOGIN_NO_ACCESS_FOR_URL}"
      
JD-TC-GetWaitlistHistory-UH2
      [Documentation]   Get waitlist without login

      ${resp}=  Get Waitlist History  service-neq=${s_id2}  waitlistStatus-neq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  419
      Should Be Equal As Strings   "${resp.json()}"     "${SESSION_EXPIRED}"
