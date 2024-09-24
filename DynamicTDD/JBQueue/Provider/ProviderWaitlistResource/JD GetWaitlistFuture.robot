*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        waitlist
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot

*** Variables ***
${waitlistedby}           PROVIDER

*** Test Cases ***
JD-TC-GetWaitlistFuture-1
      [Documentation]   View Waitlist by Provider login

      clear_queue      ${HLPUSERNAME22}
      clear_location   ${HLPUSERNAME22}
      clear_service    ${HLPUSERNAME22}
      clear_customer    ${HLPUSERNAME22}
      clear_waitlist   ${HLPUSERNAME22} 

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
          
      ${ser_duratn}=  Random Int   min=2   max=4
      ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${ser_duratn}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${resp}=   Create Sample Location
      Set Suite Variable    ${loc_id1}    ${resp}  
      ${resp}=   Get Location ById  ${loc_id1}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['timezone']}
      ${ser_name1}=   FakerLibrary.word
      Set Suite Variable    ${ser_name1} 
      ${resp}=   Create Sample Service  ${ser_name1}
      Set Suite Variable    ${ser_id1}    ${resp}  
      ${ser_name2}=   FakerLibrary.word
      Set Suite Variable    ${ser_name2} 
      ${resp}=   Create Sample Service  ${ser_name2}
      Set Suite Variable    ${ser_id2}    ${resp}  

      ${DAY1}=  db.add_timezone_date  ${tz}   2
      Set Suite Variable  ${DAY1} 
      ${DAY2}=  db.add_timezone_date  ${tz}  3
      Set Suite Variable  ${DAY2} 
      ${q_name}=    FakerLibrary.name
      Set Suite Variable    ${q_name}
      ${list}=  Create List   1  2  3  4  5  6  7
      Set Suite Variable    ${list}
      ${strt_time}=   db.subtract_timezone_time   ${tz}  2  00
      Set Suite Variable    ${strt_time}
      ${end_time}=    db.add_timezone_time  ${tz}       0  20 
      Set Suite Variable    ${end_time}  
      ${parallel}=   Random Int  min=1   max=2
      Set Suite Variable   ${parallel}
      ${capacity}=  Random Int   min=10   max=20
      Set Suite Variable   ${capacity} 
      ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}  
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id1}   ${resp.json()} 
      ${desc}=   FakerLibrary.word
      Set Suite Variable   ${desc}

      ${resp}=  Get Consumer By Id  ${CUSERNAME0}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cname1}   ${resp.json()['userProfile']['firstName']}
      Set Suite Variable  ${lname1}   ${resp.json()['userProfile']['lastName']}

      ${resp}=  AddCustomer  ${CUSERNAME0}   firstName=${cname1}   lastName=${lname1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid1}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id}  ${tid[0]}
      
      ${resp}=  Get provider communications
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Consumer By Id  ${CUSERNAME1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cname2}   ${resp.json()['userProfile']['firstName']}
      Set Suite Variable  ${lname2}   ${resp.json()['userProfile']['lastName']}

      ${resp}=  AddCustomer  ${CUSERNAME1}  firstName=${cname2}   lastName=${lname2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid2}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid2}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid2}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id1}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id1}  ${tid[0]}

      ${resp}=  Get Consumer By Id  ${CUSERNAME2}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cname3}   ${resp.json()['userProfile']['firstName']}
      Set Suite Variable  ${lname3}   ${resp.json()['userProfile']['lastName']}

      ${resp}=  AddCustomer  ${CUSERNAME2}  firstName=${cname3}   lastName=${lname3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid3}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid3}  ${ser_id1}  ${que_id1}  ${DAY2}  ${desc}  ${bool[1]}  ${cid3}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id2}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id2}  ${tid[0]}

      ${resp}=  Get Consumer By Id  ${CUSERNAME3}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cname4}   ${resp.json()['userProfile']['firstName']}
      Set Suite Variable  ${lname4}   ${resp.json()['userProfile']['lastName']}

      ${resp}=  AddCustomer  ${CUSERNAME3}   firstName=${cname4}   lastName=${lname4}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid4}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid4}  ${ser_id1}  ${que_id1}  ${DAY2}  ${desc}  ${bool[1]}  ${cid4}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id3}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id3}  ${tid[0]}

      ${resp}=  Get Consumer By Id  ${CUSERNAME31}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cname5}   ${resp.json()['userProfile']['firstName']}
      Set Suite Variable  ${lname5}   ${resp.json()['userProfile']['lastName']}

      ${resp}=  AddCustomer  ${CUSERNAME31}   firstName=${cname5}   lastName=${lname5}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${consid}  ${resp.json()}

      ${f_name}=   FakerLibrary.first_name
      Set Suite Variable  ${f_name}
      ${l_name}=   FakerLibrary.last_name
      Set Suite Variable  ${l_name}
      ${dob}=      FakerLibrary.date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProvider  ${consid}  ${f_name}  ${l_name}  ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${mem_id}  ${resp.json()}

      ${FUT_DAY}=  db.add_timezone_date  ${tz}   6
      ${resp}=  Add To Waitlist  ${consid}  ${ser_id1}  ${que_id1}  ${FUT_DAY}  ${desc}  ${bool[1]}  ${mem_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id41}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id41}  ${tid[0]}

      ${resp}=  Get Waitlist Future   
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable    ${cname1}    ${resp.json()[0]['consumer']['firstName']}
      Set Suite Variable    ${cname2}    ${resp.json()[1]['consumer']['firstName']}
      Set Suite Variable    ${cname3}    ${resp.json()[2]['consumer']['firstName']}
      Set Suite Variable    ${cname4}    ${resp.json()[3]['consumer']['firstName']}
      Set Suite Variable    ${cname5}    ${resp.json()[4]['consumer']['firstName']}
      
      
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  5
      Verify Response List  ${resp}  0  token=${token_id}  ynwUuid=${waitlist_id}    date=${DAY1}  waitlistStatus=${wl_status[0]}  partySize=1  waitlistedBy=${waitlistedby}  personsAhead=0
      Should Be Equal As Strings  ${resp.json()[0]['service']['name']}        ${ser_name1}
      Should Be Equal As Strings  ${resp.json()[0]['service']['id']}          ${ser_id1}
      Verify Response List  ${resp}  1  token=${token_id1}  ynwUuid=${waitlist_id1}  date=${DAY1}  waitlistStatus=${wl_status[0]}  partySize=1  waitlistedBy=${waitlistedby}  personsAhead=1 
      Should Be Equal As Strings  ${resp.json()[0]['service']['name']}        ${ser_name1}
      Should Be Equal As Strings  ${resp.json()[0]['service']['id']}          ${ser_id1}
      Verify Response List  ${resp}  2  token=${token_id2}  ynwUuid=${waitlist_id2}  date=${DAY2}  waitlistStatus=${wl_status[0]}  partySize=1  waitlistedBy=${waitlistedby}  personsAhead=0
      Should Be Equal As Strings  ${resp.json()[0]['service']['name']}        ${ser_name1}
      Should Be Equal As Strings  ${resp.json()[0]['service']['id']}          ${ser_id1}
      Verify Response List  ${resp}  3  token=${token_id3}  ynwUuid=${waitlist_id3}  date=${DAY2}  waitlistStatus=${wl_status[0]}  partySize=1  waitlistedBy=${waitlistedby}  personsAhead=1
      Should Be Equal As Strings  ${resp.json()[0]['service']['name']}        ${ser_name1}
      Should Be Equal As Strings  ${resp.json()[0]['service']['id']}          ${ser_id1}
      Verify Response List  ${resp}  4  token=${token_id41}  ynwUuid=${waitlist_id41}  date=${FUT_DAY}  waitlistStatus=${wl_status[0]}  partySize=1  waitlistedBy=${waitlistedby}  personsAhead=0
      Should Be Equal As Strings  ${resp.json()[0]['service']['name']}        ${ser_name1}
      Should Be Equal As Strings  ${resp.json()[0]['service']['id']}          ${ser_id1}

JD-TC-GetWaitlistFuture-2
      [Documentation]   View Waitlist after cancel

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action Cancel  ${waitlist_id}  ${waitlist_cancl_reasn[4]}   ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist Future  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}
      ${resp}=  Get Waitlist Future  waitlistStatus-eq=${wl_status[0]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  4
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id1}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id3}
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id41}
      
JD-TC-GetWaitlistFuture-3
      [Documentation]   Get waitlist waitlistStatus-neq=${wl_status[0]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  waitlistStatus-neq=${wl_status[0]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}
      
JD-TC-GetWaitlistFuture-4
      [Documentation]   Get waitlist waitlistStatus-neq=${wl_status[4]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  4
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id1}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id3}
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id41}

JD-TC-GetWaitlistFuture-5
      [Documentation]   Get waitlist firstName-eq=${cname1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  firstName-eq=${cname1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}

JD-TC-GetWaitlistFuture-6
      [Documentation]   Get waitlist firstName-neq=${cname1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  firstName-neq=${cname1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  4
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id1}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id3}
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id41}

JD-TC-GetWaitlistFuture-7
      [Documentation]   Get waitlist firstName-eq=${cname2}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  firstName-eq=${cname2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id1}

JD-TC-GetWaitlistFuture-8
      [Documentation]   Get waitlist firstName-neq=${cname2}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  firstName-neq=${cname2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  4
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id3}
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id41}

JD-TC-GetWaitlistFuture-9
      [Documentation]   Get waitlist service-eq=${ser_id1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  service-eq=${ser_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  5
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id1}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id3}
      Verify Response List  ${resp}  4  ynwUuid=${waitlist_id41}

JD-TC-GetWaitlistFuture-10
      [Documentation]   Get waitlist service-neq=${ser_id1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME0}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}  ${resp.json()[0]['id']}

      ${resp}=  Add To Waitlist  ${cid}  ${ser_id2}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id4}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id4}  ${tid[0]}

      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}  ${resp.json()[0]['id']}

      ${resp}=  Add To Waitlist  ${cid}  ${ser_id2}  ${que_id1}  ${DAY2}  ${desc}  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id5}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id5}  ${tid[0]}
      ${resp}=  Get Waitlist Future  service-neq=${ser_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id4}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id5}

JD-TC-GetWaitlistFuture-11
      [Documentation]   Get waitlist firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[4]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}

JD-TC-GetWaitlistFuture-12
      [Documentation]   Get waitlist firstName-neq=${cname1}  waitlistStatus-neq=${wl_status[4]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  firstName-neq=${cname1}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  5
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id1}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id3}
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id5}
      Verify Response List  ${resp}  4  ynwUuid=${waitlist_id41}

JD-TC-GetWaitlistFuture-13
      [Documentation]   Get waitlist firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[0]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[0]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id4}
     
JD-TC-GetWaitlistFuture-14
      [Documentation]   Get waitlist firstName-eq=${cname2}   waitlistStatus-eq=${wl_status[4]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  firstName-eq=${cname2}   waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  0

JD-TC-GetWaitlistFuture-15
      [Documentation]   Get waitlist firstName-neq=${cname2}  waitlistStatus-neq=${wl_status[4]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  firstName-neq=${cname2}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  4
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id4}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id3}
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id41}

JD-TC-GetWaitlistFuture-16
      [Documentation]   Get waitlist firstName-eq=${cname2}  waitlistStatus-eq=${wl_status[0]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  firstName-eq=${cname2}  waitlistStatus-eq=${wl_status[0]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id1}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id5}
 
JD-TC-GetWaitlistFuture-17    
      [Documentation]   Get waitlist firstName-eq=${cname1}  service-eq=${ser_id1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  firstName-eq=${cname1}  service-eq=${ser_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}
     
JD-TC-GetWaitlistFuture-18
      [Documentation]   Get waitlist firstName-neq=${cname1}  service-neq=${ser_id1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  firstName-neq=${cname1}  service-neq=${ser_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id5}

JD-TC-GetWaitlistFuture-19
      [Documentation]   Get waitlist firstName-eq=${cname2}  service-eq=${ser_id1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  firstName-eq=${cname2}  service-eq=${ser_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id1}
      
JD-TC-GetWaitlistFuture-20
      [Documentation]   Get waitlist firstName-neq=${cname2}  service-neq=${ser_id1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  firstName-neq=${cname2}  service-neq=${ser_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id4}
         
JD-TC-GetWaitlistFuture-21
      [Documentation]   Get waitlist firstName-eq=${cname1}  service-eq=${ser_id2} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  firstName-eq=${cname1}  service-eq=${ser_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id4}

JD-TC-GetWaitlistFuture-22
      [Documentation]   Get waitlist firstName-neq=${cname1}  service-neq=${ser_id2} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  firstName-neq=${cname1}  service-neq=${ser_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  4
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id1}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id3}
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id41}

JD-TC-GetWaitlistFuture-23
      [Documentation]   Get waitlist firstName-eq=${cname3}  service-eq=${ser_id2} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  firstName-eq=${cname3}  service-eq=${ser_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  0

JD-TC-GetWaitlistFuture-24
      [Documentation]   Get waitlist firstName-neq=${cname2}  service-neq=${ser_id2} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  firstName-neq=${cname2}  service-neq=${ser_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  4
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id3}
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id41}

JD-TC-GetWaitlistFuture-25
      [Documentation]   Get waitlist service-eq=${ser_id1}   waitlistStatus-eq=${wl_status[4]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  service-eq=${ser_id1}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}

JD-TC-GetWaitlistFuture-26
      [Documentation]   Get waitlist service-neq=${ser_id1}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Get Waitlist Future  service-neq=${ser_id1}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id4}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id5}

JD-TC-GetWaitlistFuture-27
      [Documentation]   Get waitlist service-eq=${ser_id1}   waitlistStatus-eq=${wl_status[0]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  service-eq=${ser_id1}   waitlistStatus-eq=${wl_status[0]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  4
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id1}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id3}
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id41}

JD-TC-GetWaitlistFuture-28
      [Documentation]   Get waitlist service-eq=${ser_id2}   waitlistStatus-eq=${wl_status[0]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  service-eq=${ser_id2}   waitlistStatus-eq=${wl_status[0]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id4}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id5}

JD-TC-GetWaitlistFuture-29
      [Documentation]   Get waitlist service-eq=${ser_id2}   waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      
      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  service-eq=${ser_id2}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  0

JD-TC-GetWaitlistFuture-30
      [Documentation]   Get waitlist service-neq=${ser_id2}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Get Waitlist Future  service-neq=${ser_id2}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  4
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id1}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id3}
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id41}

JD-TC-GetWaitlistFuture-31
      [Documentation]   Get waitlist token_id-eq=${token_id}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  token-eq=${token_id}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Log   ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  token=${token_id}
      Verify Response List  ${resp}  1  token=${token_id2}
      Verify Response List  ${resp}  2  token=${token_id41}

JD-TC-GetWaitlistFuture-32
      [Documentation]   Get waitlist token_id-neq=${token_id}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  token-neq=${token_id}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  4
      Verify Response List  ${resp}  0  token=${token_id1}
      Verify Response List  ${resp}  1  token=${token_id4}
      Verify Response List  ${resp}  2  token=${token_id3}
      Verify Response List  ${resp}  3  token=${token_id5}

JD-TC-GetWaitlistFuture-33
      [Documentation]   Get waitlist token_id-eq=${token_id}  service-eq=${ser_id1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  token-eq=${token_id}  service-eq=${ser_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  token=${token_id}
      Verify Response List  ${resp}  1  token=${token_id2}
      Verify Response List  ${resp}  2  token=${token_id41}

JD-TC-GetWaitlistFuture-34
      [Documentation]   Get waitlist token_id-neq=${token_id}  service-neq=${ser_id2}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  token-neq=${token_id}  service-neq=${ser_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  token=${token_id1}
      Verify Response List  ${resp}  1  token=${token_id3}

JD-TC-GetWaitlistFuture-35
      [Documentation]   Get waitlist firstName-eq=${cname1}  date-eq=${DAY1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  firstName-eq=${cname1}  date-eq=${DAY1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  token=${token_id}
      Verify Response List  ${resp}  1  token=${token_id4}

JD-TC-GetWaitlistFuture-36
      [Documentation]   Get waitlist  date-neq=${DAY1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  date-neq=${DAY1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  4
      Verify Response List  ${resp}  0  token=${token_id2}
      Verify Response List  ${resp}  1  token=${token_id3}
      Verify Response List  ${resp}  2  token=${token_id5}
      Verify Response List  ${resp}  3  token=${token_id41}

JD-TC-GetWaitlistFuture-37
      [Documentation]   Get waitlist date-eq=${DAY1}  service-neq=${ser_id2}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  date-eq=${DAY1}  service-neq=${ser_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  token=${token_id}
      Verify Response List  ${resp}  1  token=${token_id1}

JD-TC-GetWaitlistFuture-38
      [Documentation]   Get waitlist waitlistStatus-eq=${wl_status[4]}   date-eq=${DAY1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  waitlistStatus-eq=${wl_status[4]}  date-eq=${DAY1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  token=${token_id}

JD-TC-GetWaitlistFuture-39
      [Documentation]   Get waitlist queue-eq   from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  queue-eq=${que_id1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  7
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id1}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id4}
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  4  ynwUuid=${waitlist_id3}
      Verify Response List  ${resp}  5  ynwUuid=${waitlist_id5}
      Verify Response List  ${resp}  6  ynwUuid=${waitlist_id41}

JD-TC-GetWaitlistFuture-40
      [Documentation]   Get waitlist queue-neq   from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  queue-neq=${que_id1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  0

JD-TC-GetWaitlistFuture-41
      [Documentation]   Get waitlist queue-eq  and token-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  queue-eq=${que_id1}  token-eq=${token_id}    from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  token=${token_id}
      Verify Response List  ${resp}  1  token=${token_id2}
      Verify Response List  ${resp}  2  token=${token_id41}

JD-TC-GetWaitlistFuture-42
      [Documentation]   Get waitlist queue-eq  and token-neq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  queue-eq=${que_id1}  token-neq=${token_id}    from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  4
      Verify Response List  ${resp}  0  token=${token_id1}
      Verify Response List  ${resp}  1  token=${token_id4}
      Verify Response List  ${resp}  2  token=${token_id3}
      Verify Response List  ${resp}  3  token=${token_id5}

JD-TC-GetWaitlistFuture-43
      [Documentation]   Get waitlist queue-eq  and firstName-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  queue-eq=${que_id1}  firstName-eq=${cname2}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id1}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id5}

JD-TC-GetWaitlistFuture-44
      [Documentation]   Get waitlist queue-eq  and service-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  queue-eq=${que_id1}  service-eq=${ser_id1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  5
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id1}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id3}
      Verify Response List  ${resp}  4  ynwUuid=${waitlist_id41}

JD-TC-GetWaitlistFuture-45
      [Documentation]   Get waitlist queue-eq  and  waitlistStatus-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  queue-eq=${que_id1}  waitlistStatus-eq=${wl_status[4]}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}

JD-TC-GetWaitlistFuture-46
      [Documentation]   Get waitlist queue-eq  and  date-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  queue-eq=${que_id1}  date-eq=${DAY1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id1}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id4}

JD-TC-GetWaitlistFuture-47
      [Documentation]   Get waitlist location-eq   from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  location-eq=${loc_id1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  7
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id1}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id4}
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  4  ynwUuid=${waitlist_id3}
      Verify Response List  ${resp}  5  ynwUuid=${waitlist_id5}
      Verify Response List  ${resp}  6  ynwUuid=${waitlist_id41}

JD-TC-GetWaitlistFuture-48
      [Documentation]   Get waitlist location-neq=${loc_id1}   from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  location-neq=${loc_id1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  0

JD-TC-GetWaitlistFuture-49
      [Documentation]   Get waitlist location-eq=${loc_id1}  and token-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  location-eq=${loc_id1}  token-eq=${token_id}    from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  token=${token_id}
      Verify Response List  ${resp}  1  token=${token_id2}
      Verify Response List  ${resp}  2  token=${token_id41}

JD-TC-GetWaitlistFuture-50
      [Documentation]   Get waitlist location-eq=${loc_id1}  and token-neq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  location-eq=${loc_id1}  token-neq=${token_id}    from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  4
      Verify Response List  ${resp}  0  token=${token_id1}
      Verify Response List  ${resp}  1  token=${token_id4}
      Verify Response List  ${resp}  2  token=${token_id3}
      Verify Response List  ${resp}  3  token=${token_id5}

JD-TC-GetWaitlistFuture-51
      [Documentation]   Get waitlist location-eq=${loc_id1}  and firstName-eq from=0  count=10
      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  location-eq=${loc_id1}  firstName-eq=${cname2}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id1}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id5}

JD-TC-GetWaitlistFuture-52
      [Documentation]   Get waitlist location-eq=${loc_id1}  and service-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  location-eq=${loc_id1}  service-eq=${ser_id1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  5
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id1}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id3}
      Verify Response List  ${resp}  4  ynwUuid=${waitlist_id41}

JD-TC-GetWaitlistFuture-53
      [Documentation]   Get waitlist location-eq=${loc_id1}  and  waitlistStatus-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  location-eq=${loc_id1}  waitlistStatus-eq=${wl_status[4]}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}

JD-TC-GetWaitlistFuture-54
      [Documentation]   Get waitlist location-eq=${loc_id1}  and  date-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  location-eq=${loc_id1}  date-eq=${DAY1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id1}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id4}

JD-TC-GetWaitlistFuture-55
      [Documentation]   Get waitlist location-eq=${loc_id1}  and  queue-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Future  location-eq=${loc_id1}  queue-eq=${que_id1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  7
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id1}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id4}
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  4  ynwUuid=${waitlist_id3}
      Verify Response List  ${resp}  5  ynwUuid=${waitlist_id5}
      Verify Response List  ${resp}  6  ynwUuid=${waitlist_id41}

JD-TC-GetWaitlistFuture-56
      [Documentation]  Get Future Waitlist By first name of family member

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Waitlist Future  waitlistingFor-eq=firstName::${f_name}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id41}

JD-TC-GetWaitlistFuture-57
      [Documentation]  Get Future Waitlist By last name of family member

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist Future  waitlistingFor-eq=lastName::${l_name}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id41}


      
JD-TC-GetWaitlistFuture-UH1
      [Documentation]   Get waitlist using provider consumer login

      ${resp}=  Encrypted Provider Login  ${PUSERNAME145}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=  Get Business Profile
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${account_id}  ${resp.json()['id']} 

      #............provider consumer creation..........

      ${PH_Number}=  FakerLibrary.Numerify  %#####
      ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
      Log  ${PH_Number}
      Set Suite Variable  ${PCPHONENO}  555${PH_Number}

      ${fname}=  FakerLibrary.first_name
      Set Suite Variable  ${fname}
      ${lastname}=  FakerLibrary.last_name

      ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lastname}  countryCode=${countryCodes[1]} 
      Log   ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Provider Logout
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=    Send Otp For Login    ${PCPHONENO}    ${account_id}
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200
      Set Suite Variable  ${token}  ${resp.json()['token']}

      ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200   
            
      ${resp}=  Get Waitlist Future  service-neq=${ser_id2}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  "${resp.json()}"     "${LOGIN_NO_ACCESS_FOR_URL}"
      
JD-TC-GetWaitlistFuture-UH2
      [Documentation]   Get waitlist without login

      ${resp}=  Get Waitlist Future  service-neq=${ser_id2}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  419
      Should Be Equal As Strings  "${resp.json()}"     "${SESSION_EXPIRED}"
