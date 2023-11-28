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

*** Variables ***
${waitlistedby}           PROVIDER

*** Test Cases ***

JD-TC-GetWaitlistToday-1
      [Documentation]   View Waitlist by Provider login

      clear_queue      ${PUSERNAME28}
      clear_location   ${PUSERNAME28}
      clear_service    ${PUSERNAME28}
      clear_customer    ${PUSERNAME28}

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${ser_duratn}=  Random Int   min=2   max=4
      ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${ser_duratn}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${resp}=   Create Sample Location
      Set Suite Variable    ${loc_id1}    ${resp}  
      ${resp}=   Get Location ById  ${loc_id1}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
      ${ser_name1}=   FakerLibrary.word
      Set Suite Variable    ${ser_name1} 
      ${resp}=   Create Sample Service  ${ser_name1}
      Set Suite Variable    ${ser_id1}    ${resp}  
      ${ser_name2}=   FakerLibrary.word
      Set Suite Variable    ${ser_name2} 
      ${resp}=   Create Sample Service  ${ser_name2}
      Set Suite Variable    ${ser_id2}    ${resp}  
      ${ser_name3}=   FakerLibrary.word
      Set Suite Variable    ${ser_name3} 
      ${resp}=   Create Sample Service  ${ser_name3}
      Set Suite Variable    ${ser_id3}    ${resp}  
      ${ser_name4}=   FakerLibrary.word
      Set Suite Variable    ${ser_name4} 
      ${resp}=   Create Sample Service  ${ser_name4}
      Set Suite Variable    ${ser_id4}    ${resp}  
      ${q_name}=    FakerLibrary.name
      Set Suite Variable    ${q_name}
      ${list}=  Create List   1  2  3  4  5  6  7
      Set Suite Variable    ${list}
      
      ${DAY1}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable  ${DAY1} 
      ${strt_time}=   db.subtract_timezone_time   ${tz}  2  00
      Set Suite Variable    ${strt_time}
      ${end_time}=    db.add_timezone_time  ${tz}       0  20 
      Set Suite Variable    ${end_time}  
      ${parallel}=   Random Int  min=1   max=2
      Set Suite Variable   ${parallel}
      ${capacity}=  Random Int   min=10   max=20
      Set Suite Variable   ${capacity} 
      ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}  ${ser_id3}
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

      ${resp}=  AddCustomer  ${CUSERNAME0}  firstName=${cname1}   lastName=${lname1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
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

      ${resp}=  AddCustomer  ${CUSERNAME1}   firstName=${cname2}   lastName=${lname2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid1}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
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

      ${resp}=  AddCustomer  ${CUSERNAME2}   firstName=${cname3}   lastName=${lname3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid2}  ${resp.json()}
      
      ${resp}=  Add To Waitlist  ${cid2}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid2}
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
      Set Test Variable  ${cid3}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid3}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid3}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id3}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id3}  ${tid[0]}
      ${resp}=  Get Waitlist Today  
      Log   ${resp.json()}
      Set Suite Variable    ${cname1}    ${resp.json()[0]['consumer']['firstName']}
      Set Suite Variable    ${cname2}    ${resp.json()[1]['consumer']['firstName']}
      Set Suite Variable    ${cname3}    ${resp.json()[2]['consumer']['firstName']}
      Set Suite Variable    ${cname4}    ${resp.json()[3]['consumer']['firstName']}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  4
      Verify Response List  ${resp}  0  token=${token_id}  ynwUuid=${waitlist_id}    date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1  waitlistedBy=${waitlistedby}  personsAhead=0
      Should Be Equal As Strings  ${resp.json()[0]['service']['name']}        ${ser_name1}
      Should Be Equal As Strings  ${resp.json()[0]['service']['id']}          ${ser_id1}
      Verify Response List  ${resp}  1  token=${token_id1}  ynwUuid=${waitlist_id1}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1  waitlistedBy=${waitlistedby}  personsAhead=1 
      Should Be Equal As Strings  ${resp.json()[0]['service']['name']}        ${ser_name1}
      Should Be Equal As Strings  ${resp.json()[0]['service']['id']}          ${ser_id1}
      Verify Response List  ${resp}  2  token=${token_id2}  ynwUuid=${waitlist_id2}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1  waitlistedBy=${waitlistedby}  personsAhead=2
      Should Be Equal As Strings  ${resp.json()[0]['service']['name']}        ${ser_name1}
      Should Be Equal As Strings  ${resp.json()[0]['service']['id']}          ${ser_id1}
      Verify Response List  ${resp}  3  token=${token_id3}  ynwUuid=${waitlist_id3}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1  waitlistedBy=${waitlistedby}  personsAhead=3
      Should Be Equal As Strings  ${resp.json()[0]['service']['name']}        ${ser_name1}
      Should Be Equal As Strings  ${resp.json()[0]['service']['id']}          ${ser_id1}
      
JD-TC-GetWaitlistToday-2
      [Documentation]   View Waitlist after cancel

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action CANCEL  ${waitlist_id}  ${waitlist_cancl_reasn[3]}   ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${waitlist_id1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist Today  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}
      ${resp}=  Get Waitlist Today  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id3}
      
JD-TC-GetWaitlistToday-3
      [Documentation]   Get waitlist waitlistStatus-eq=started from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  waitlistStatus-eq=${wl_status[2]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id1}

JD-TC-GetWaitlistToday-4
      [Documentation]   Get waitlist waitlistStatus-eq=Arrived from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id3}

JD-TC-GetWaitlistToday-5
      [Documentation]   Get waitlist waitlistStatus-neq=Arrived from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  waitlistStatus-neq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id1}

JD-TC-GetWaitlistToday-6
      [Documentation]   Get waitlist waitlistStatus-neq=checkedIn from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  waitlistStatus-neq=${wl_status[0]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  4
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id1}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id3}

JD-TC-GetWaitlistToday-7
      [Documentation]   Get waitlist waitlistStatus-neq=started from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  waitlistStatus-neq=${wl_status[2]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id3}

JD-TC-GetWaitlistToday-8
      [Documentation]   Get waitlist waitlistStatus-neq=cancelled from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id1}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id3}

JD-TC-GetWaitlistToday-9
      [Documentation]   Get waitlist firstName-eq=${cname1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-eq=${cname1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}
      
JD-TC-GetWaitlistToday-10
      [Documentation]   Get waitlist firstName-neq=${cname1} from=0  count=10
 
      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-neq=${cname1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Log   ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id1}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id3}

JD-TC-GetWaitlistToday-11
      [Documentation]   Get waitlist firstName-eq=${cname2}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-eq=${cname2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id1}
      
JD-TC-GetWaitlistToday-12
      [Documentation]   Get waitlist firstName-neq=${cname2}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-neq=${cname2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id3}


JD-TC-GetWaitlistToday-13
      [Documentation]   Get waitlist service-eq=${ser_id1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  service-eq=${ser_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  4
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id1}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id3}

JD-TC-GetWaitlistToday-14
      [Documentation]   Get waitlist waitlistStatus-eq=done  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action  ${waitlist_actions[4]}  ${waitlist_id1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist Today  waitlistStatus-eq=${wl_status[5]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id1}

JD-TC-GetWaitlistToday-15
      [Documentation]   Get waitlist waitlistStatus-neq=done  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist Today  waitlistStatus-neq=${wl_status[5]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id3}

JD-TC-GetWaitlistToday-16
      [Documentation]   Get waitlist service-neq=${ser_id1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 

      ${resp}=  Get Consumer By Id  ${CUSERNAME4}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cname5}   ${resp.json()['userProfile']['firstName']}
      Set Suite Variable  ${lname5}   ${resp.json()['userProfile']['lastName']}

      ${resp}=  AddCustomer  ${CUSERNAME4}   firstName=${cname5}   lastName=${lname5} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid4}  ${resp.json()}

      # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
      # Log   ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Set Suite Variable  ${cid4}  ${resp.json()[0]['id']}

      ${resp}=  Add To Waitlist  ${cid4}  ${ser_id2}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid4}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id4}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id4}  ${tid[0]}

      ${resp}=  Get Consumer By Id  ${CUSERNAME5}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cname6}   ${resp.json()['userProfile']['firstName']}
      Set Suite Variable  ${lname6}   ${resp.json()['userProfile']['lastName']}

      ${resp}=  AddCustomer  ${CUSERNAME5}   firstName=${cname6}   lastName=${lname6}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid5}  ${resp.json()}

      # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
      # Log   ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Set Suite Variable  ${cid5}  ${resp.json()[0]['id']}

      ${resp}=  Add To Waitlist  ${cid5}  ${ser_id2}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid5}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id5}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id5}  ${tid[0]}
      ${resp}=  Get Waitlist Today  service-neq=${ser_id1}  from=0  count=10
      Log   ${resp.json()}
      Set Suite Variable    ${cname4}    ${resp.json()[0]['consumer']['firstName']}
      Set Suite Variable    ${cname5}    ${resp.json()[1]['consumer']['firstName']}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id4}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id5}

JD-TC-GetWaitlistToday-17
      [Documentation]   Get waitlist firstName-eq=${cname2}  waitlistStatus-eq=${wl_status[5]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-eq=${cname2}  waitlistStatus-eq=${wl_status[5]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id1}

JD-TC-GetWaitlistToday-18
      [Documentation]   Get waitlist firstName-neq=${cname2}  waitlistStatus-neq=${wl_status[5]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-neq=${cname2}  waitlistStatus-neq=${wl_status[5]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  5
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id3}
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id4}
      Verify Response List  ${resp}  4  ynwUuid=${waitlist_id5}

JD-TC-GetWaitlistToday-19
      [Documentation]   Get waitlist firstName-eq=${cname2}  waitlistStatus-eq=cancelled from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-eq=${cname2}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  0
      
JD-TC-GetWaitlistToday-20
      [Documentation]   Get waitlist firstName-neq=${cname2}  waitlistStatus-neq=${wl_status[4]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-neq=${cname2}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  4
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id3}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id4}
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id5}

JD-TC-GetWaitlistToday-21
      [Documentation]   Get waitlist firstName-eq=${cname2}  waitlistStatus-eq=${wl_status[1]} from=0  count=10
      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-eq=${cname2}  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  0

JD-TC-GetWaitlistToday-22
      [Documentation]   Get waitlist firstName-neq=${cname2}  waitlistStatus-neq=${wl_status[1]} from=0  count=10
      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-neq=${cname2}  waitlistStatus-neq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
       Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}

JD-TC-GetWaitlistToday-23
      [Documentation]   Get waitlist firstName-eq=${cname2}  waitlistStatus-eq=${wl_status[0]} from=0  count=10
      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-eq=${cname2}  waitlistStatus-eq=${wl_status[0]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  0

JD-TC-GetWaitlistToday-24
      [Documentation]   Get waitlist firstName-neq=${cname2}  waitlistStatus-neq=${wl_status[2]} from=0  count=10
      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-neq=${cname2}  waitlistStatus-neq=${wl_status[2]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  5
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id3}
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id4}
      Verify Response List  ${resp}  4  ynwUuid=${waitlist_id5}

JD-TC-GetWaitlistToday-25
      [Documentation]   Get waitlist firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[5]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[5]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  0

JD-TC-GetWaitlistToday-26
      [Documentation]   Get waitlist firstName-neq=${cname1}  waitlistStatus-neq=${wl_status[5]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-neq=${cname1}  waitlistStatus-neq=${wl_status[5]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  4
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id3}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id4}
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id5}

JD-TC-GetWaitlistToday-27
      [Documentation]   Get waitlist firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[4]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}

JD-TC-GetWaitlistToday-28
      [Documentation]   Get waitlist firstName-neq=${cname1}  waitlistStatus-neq=${wl_status[4]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-neq=${cname1}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  5
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id1}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id3}
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id4}
      Verify Response List  ${resp}  4  ynwUuid=${waitlist_id5}

JD-TC-GetWaitlistToday-29
      [Documentation]   Get waitlist firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[1]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  0
      
JD-TC-GetWaitlistToday-30
      [Documentation]   Get waitlist firstName-neq=${cname1}  waitlistStatus-neq=${wl_status[1]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-neq=${cname1}  waitlistStatus-neq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id1}
     
JD-TC-GetWaitlistToday-31
      [Documentation]   Get waitlist firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[0]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[0]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  0

JD-TC-GetWaitlistToday-32
      [Documentation]   Get waitlist firstName-neq=${cname1}  waitlistStatus-neq=${wl_status[2]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-neq=${cname1}  waitlistStatus-neq=${wl_status[2]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  5
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id1}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id3}
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id4}
      Verify Response List  ${resp}  4  ynwUuid=${waitlist_id5}

JD-TC-GetWaitlistToday-33
      [Documentation]   Get waitlist firstName-eq=${cname2}  service-eq=${ser_id1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-eq=${cname2}  service-eq=${ser_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id1}
     

JD-TC-GetWaitlistToday-34
      [Documentation]   Get waitlist firstName-neq=${cname2}  service-neq=${ser_id1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-neq=${cname2}  service-neq=${ser_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id4}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id5}
     
JD-TC-GetWaitlistToday-35
      [Documentation]   Get waitlist firstName-eq=${cname1}  service-eq=${ser_id1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-eq=${cname1}  service-eq=${ser_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}

JD-TC-GetWaitlistToday-36
      [Documentation]   Get waitlist firstName-neq=${cname1}  service-neq=${ser_id1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-neq=${cname1}  service-neq=${ser_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id4}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id5}
   
JD-TC-GetWaitlistToday-37
      [Documentation]   Get waitlist firstName-eq=${cname4}  service-eq=${ser_id2} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-eq=${cname4}  service-eq=${ser_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id4}
     
JD-TC-GetWaitlistToday-38
      [Documentation]   Get waitlist firstName-neq=${cname4}  service-neq=${ser_id2} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-neq=${cname4}  service-neq=${ser_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  4
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id1}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  3  ynwUuid=${waitlist_id3}

JD-TC-GetWaitlistToday-39
      [Documentation]   Get waitlist firstName-eq=${cname2}  service-eq=${ser_id2} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-eq=${cname2}  service-eq=${ser_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  0

JD-TC-GetWaitlistToday-40
      [Documentation]   Get waitlist firstName-neq=${cname1}  service-neq=${ser_id2} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  firstName-neq=${cname1}  service-neq=${ser_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id1}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id3}   

JD-TC-GetWaitlistToday-41
      [Documentation]   Get waitlist service-eq=${ser_id1}   waitlistStatus=${wl_status[4]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  service-eq=${ser_id1}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}

JD-TC-GetWaitlistToday-42
      [Documentation]   Get waitlist service-neq=${ser_id1}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Get Waitlist Today  service-neq=${ser_id1}  waitlistStatus-neq=${wl_status[4]}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id4}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id5}

JD-TC-GetWaitlistToday-43
      [Documentation]   Get waitlist service-eq=${ser_id1}   waitlistStatus-eq=${wl_status[5]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  service-eq=${ser_id1}  waitlistStatus-eq=${wl_status[5]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id1}

JD-TC-GetWaitlistToday-44
      [Documentation]   Get waitlist service-neq=${ser_id1}  waitlistStatus-neq=${wl_status[5]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Get Waitlist Today  service-neq=${ser_id1}  waitlistStatus-neq=${wl_status[5]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id4}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id5}

JD-TC-GetWaitlistToday-45
      [Documentation]   Get waitlist service-eq=${ser_id1}   waitlistStatus-eq=${wl_status[1]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  service-eq=${ser_id1}  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id3}

JD-TC-GetWaitlistToday-46
      [Documentation]   Get waitlist service-neq=${ser_id1}  waitlistStatus-neq=${wl_status[1]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Get Waitlist Today  service-neq=${ser_id1}  waitlistStatus-neq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  0

JD-TC-GetWaitlistToday-47
      [Documentation]   Get waitlist service-eq=${ser_id1}   waitlistStatus-eq=${wl_status[0]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  service-eq=${ser_id1}  waitlistStatus-eq=${wl_status[0]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  0

JD-TC-GetWaitlistToday-48
      [Documentation]   Get waitlist service-neq=${ser_id1}  waitlistStatus-neq=${wl_status[2]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Get Waitlist Today  service-neq=${ser_id1}  waitlistStatus-neq=${wl_status[2]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id4}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id5}

JD-TC-GetWaitlistToday-49
      [Documentation]   Get waitlist service-eq=${ser_id2}   waitlistStatus-eq=${wl_status[0]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  service-eq=${ser_id2}  waitlistStatus-eq=${wl_status[0]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  0

JD-TC-GetWaitlistToday-50
      [Documentation]   Get waitlist service-neq=${ser_id2}  waitlistStatus-neq=${wl_status[1]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Get Waitlist Today  service-neq=${ser_id2}  waitlistStatus-neq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id1}

JD-TC-GetWaitlistToday-51
      [Documentation]   Get waitlist service-eq=${ser_id2}   waitlistStatus-eq=${wl_status[4]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  service-eq=${ser_id2}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  0

JD-TC-GetWaitlistToday-52
      [Documentation]   Get waitlist service-neq=${ser_id2}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Get Waitlist Today  service-neq=${ser_id2}  waitlistStatus-neq=${wl_status[4]}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id1}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id3}

JD-TC-GetWaitlistToday-53
      [Documentation]   Get waitlist service-eq=${ser_id2}   waitlistStatus-eq=${wl_status[5]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  service-eq=${ser_id2}  waitlistStatus-eq=${wl_status[5]}    from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  0

JD-TC-GetWaitlistToday-54
      [Documentation]   Get waitlist service-neq=${ser_id2}  waitlistStatus-neq=${wl_status[5]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Get Waitlist Today  service-neq=${ser_id2}  waitlistStatus-neq=${wl_status[5]}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id2}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id3}

JD-TC-GetWaitlistToday-55
      [Documentation]   Get waitlist service-eq=${ser_id2}   waitlistStatus-eq=${wl_status[1]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  service-eq=${ser_id2}  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id4}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id5}

JD-TC-GetWaitlistToday-56
      [Documentation]   Get waitlist service-neq=${ser_id2}  waitlistStatus-neq=${wl_status[1]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Get Waitlist Today  service-neq=${ser_id2}  waitlistStatus-neq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id1}

JD-TC-GetWaitlistToday-57
      [Documentation]   Get waitlist token_id-eq=${token_id}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  token-eq=${token_id}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  token=${token_id}

JD-TC-GetWaitlistToday-58
      [Documentation]   Get waitlist token_id-neq=${token_id}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  token-neq=${token_id}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  5
      Verify Response List  ${resp}  0  token=${token_id1}
      Verify Response List  ${resp}  1  token=${token_id2}
      Verify Response List  ${resp}  2  token=${token_id3}
      Verify Response List  ${resp}  3  token=${token_id4}
      Verify Response List  ${resp}  4  token=${token_id5}


JD-TC-GetWaitlistToday-59
      [Documentation]   Get waitlist token_id-eq=${token_id}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  token-eq=${token_id}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  token=${token_id}

JD-TC-GetWaitlistToday-60
      [Documentation]   Get waitlist token_id-eq=${token_id}  service-eq=${ser_id1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  token-eq=${token_id}  service-eq=${ser_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  token=${token_id}

JD-TC-GetWaitlistToday-61
      [Documentation]   Get waitlist token_id-neq=${token_id}  service-neq=${ser_id2}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Today  token-neq=${token_id}  service-neq=${ser_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  token=${token_id1}
      Verify Response List  ${resp}  1  token=${token_id2}
      Verify Response List  ${resp}  2  token=${token_id3}

JD-TC-GetWaitlistToday-62
      [Documentation]   Get waitlist location-eq=${lid1} from=0  count=10

      clear_queue      ${PUSERNAME19}
      clear_location   ${PUSERNAME19}
      clear_service    ${PUSERNAME19}
      clear_customer    ${PUSERNAME19}

      ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 

      ${resp}=  AddCustomer  ${CUSERNAME3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}  ${resp.json()}

      ${resp}=   Create Sample Location
      Set Suite Variable    ${lid1}    ${resp}  
      ${ser_name4}=   FakerLibrary.word
      Set Suite Variable    ${ser_name4} 
      ${resp}=   Create Sample Service  ${ser_name4}
      Set Suite Variable    ${ser_id4}    ${resp}  
      ${ser_name5}=   FakerLibrary.word
      Set Suite Variable    ${ser_name5} 
      ${resp}=   Create Sample Service  ${ser_name5}
      Set Suite Variable    ${ser_id5}    ${resp}  
      ${q_name1}=    FakerLibrary.name
      Set Suite Variable    ${q_name1}  
      ${resp}=  Create Queue    ${q_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  1   15    ${lid1}  ${ser_id4}  ${ser_id5} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${qid2}   ${resp.json()} 
      ${resp}=  Add To Waitlist  ${cid}  ${ser_id4}  ${qid2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id5}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id5}  ${tid[0]}

      ${resp}=  AddCustomer  ${CUSERNAME2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid1}  ${resp.json()}
      
      ${resp}=  Add To Waitlist  ${cid1}  ${ser_id5}  ${qid2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id6}  ${wid[0]}

      ${resp}=  AddCustomer  ${CUSERNAME4}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid2}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid2}  ${ser_id5}  ${qid2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log   ${resp.json()}
      
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id7}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id7}  ${tid[0]}
      ${resp}=  Get Waitlist Today  location-eq=${lid1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id5}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id6}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id7}  

JD-TC-GetWaitlistToday-63
      [Documentation]   Get waitlistlocation-eq=${lid1} service-eq=${ser_id5} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200   
      ${resp}=  Get Waitlist Today  location-eq=${lid1}   service-eq=${ser_id5}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2     
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id6}   
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id7}        

JD-TC-GetWaitlistToday-64
      [Documentation]   Get waitlist location-eq=${lid1}  queue-eq=${qid2} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Get Waitlist Today  location-eq=${lid1}  queue-eq=${qid2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id5}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id6}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id7}  

JD-TC-GetWaitlistToday-65
      [Documentation]   Get waitlist location-eq=${lid1}  waitlistStatus-eq=${wl_status[1]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Waitlist Action  ${waitlist_actions[1]}   ${waitlist_id6}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist Today  location-eq=${lid1}  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id5}  
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id7}    

JD-TC-GetWaitlistToday-66
      [Documentation]   Get waitlist location-eq=${lid1}  waitlistStatus-eq=${wl_status[2]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Get Waitlist Today  location-eq=${lid1}  waitlistStatus-eq=${wl_status[2]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id6}  

JD-TC-GetWaitlistToday-67
      [Documentation]   Get waitlist location-eq=${lid1}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Waitlist Action Cancel   ${waitlist_id5}  ${waitlist_cancl_reasn[4]}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist Today  location-eq=${lid1}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id5}  

JD-TC-GetWaitlistToday-68
      [Documentation]   Get waitlist location-eq=${lid1}  token-eq=${token_id5}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Get Waitlist Today  location-eq=${lid1}  token-eq=${token_id5}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id5}  

JD-TC-GetWaitlistToday-69
      [Documentation]   Get waitlist location-eq=${lid1}  queue-eq=${qid2} service-eq=${ser_id4} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Get Waitlist Today  location-eq=${lid1}  queue-eq=${qid2}  service-eq=${ser_id4}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1     
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id5}      

JD-TC-GetWaitlistToday-70
      [Documentation]   Get waitlist location-eq=${lid1}  queue-eq=${qid2}  waitlistStatus-eq=${wl_status[4]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Get Waitlist Today  location-eq=${lid1}  queue-eq=${qid2}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1     
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id5}

JD-TC-GetWaitlistToday-71
      [Documentation]   Get waitlist location-eq=${lid1}  queue-eq=${qid2}  token-eq=${token_id5} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Get Waitlist Today  location-eq=${lid1}  queue-eq=${qid2}  token-eq=${token_id5}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1     
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id5}   

JD-TC-GetWaitlistToday-72
      [Documentation]   Get waitlist location-eq=${lid1}  queue-eq=${qid2}  token-eq=${token_id7}  waitlistStatus-eq=${wl_status[1]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Get Waitlist Today  location-eq=${lid1}  queue-eq=${qid2}  token-eq=${token_id7}  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1     
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id7}    

JD-TC-GetWaitlistToday-73
      [Documentation]   Get waitlist location-eq=${lid1}  queue-eq=${qid2}  token-eq=${token_id5}  waitlistStatus-eq=${wl_status[1]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Get Waitlist Today  location-eq=${lid1}  queue-eq=${qid2}  token-eq=${token_id5}  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  0   

JD-TC-GetWaitlistToday-74
      [Documentation]   Get waitlist queue-eq=${qid2} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200       
      ${resp}=  Get Waitlist Today    queue-eq=${qid2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  3     
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id5}
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id6}
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id7}

JD-TC-GetWaitlistToday-75
      [Documentation]   Get queue-eq=${qid2} service-eq=${ser_id5} from=0  count=10
      ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200   
      ${resp}=  Get Waitlist Today  queue-eq=${qid2}   service-eq=${ser_id5}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  2     
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id6}   
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id7}    

JD-TC-GetWaitlistToday-76
      [Documentation]   Get waitlist queue-eq=${qid2}  waitlistStatus-eq=${wl_status[2]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Get Waitlist Today  queue-eq=${qid2}  waitlistStatus-eq=${wl_status[2]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id6}  

JD-TC-GetWaitlistToday-77
      [Documentation]   Get waitlist queue-eq=${qid2}  waitlistStatus-eq=${wl_status[4]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Get Waitlist Today  queue-eq=${qid2}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id5}  

JD-TC-GetWaitlistToday-78
      [Documentation]   Get waitlist queue-eq=${qid2}  location-eq=${lid1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Get Waitlist Today  queue-eq=${qid2}  location-eq=${lid1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  3
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id5}  
      Verify Response List  ${resp}  1  ynwUuid=${waitlist_id6} 
      Verify Response List  ${resp}  2  ynwUuid=${waitlist_id7} 

JD-TC-GetWaitlistToday-79
      [Documentation]   Get waitlist  waitlistStatus-eq=${wl_status[1]}  queue-eq=${qid2} service-eq=${ser_id5} from=0  count=10
      ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Get Waitlist Today  waitlistStatus-eq=${wl_status[1]}  queue-eq=${qid2}  service-eq=${ser_id5}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1    
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id7}   

JD-TC-GetWaitlistToday-80
      [Documentation]   Get Future Waitlist of a family member. 
      clear_queue      ${PUSERNAME19}
      clear_location   ${PUSERNAME19}
      clear_service    ${PUSERNAME19}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${ser_duratn}=  Random Int   min=2   max=4
      ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${ser_duratn}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=   Create Sample Location
      Set Suite Variable    ${loc_id11}    ${resp}  
      ${resp}=   Get Location ById  ${loc_id11}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
      ${ser_name11}=   FakerLibrary.word
      Set Suite Variable    ${ser_name11} 
      ${resp}=   Create Sample Service  ${ser_name11}
      Set Suite Variable    ${ser_id11}    ${resp}   
      
      ${q_name1}=    FakerLibrary.name
      ${strt_time}=   db.subtract_timezone_time   ${tz}  2  00
      ${end_time}=    db.add_timezone_time  ${tz}       0  20 
      ${parallel}=   Random Int  min=1   max=2
      ${capacity}=  Random Int   min=10   max=20
      ${resp}=  Create Queue    ${q_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id11}  ${ser_id11}  
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id11}   ${resp.json()} 

      ${resp}=  AddCustomer  ${CUSERNAME30}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}  ${resp.json()}

      ${f_name}=   FakerLibrary.first_name
      Set Suite Variable  ${f_name}
      ${l_name}=   FakerLibrary.last_name
      Set Suite Variable  ${l_name}
      ${dob}=      FakerLibrary.date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProvider  ${cid}  ${f_name}  ${l_name}  ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${mem_id}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid}  ${ser_id11}  ${que_id11}  ${DAY1}  ${desc}  ${bool[1]}  ${mem_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id11}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id11}  ${tid[0]}
      ${resp}=  Get provider communications
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetWaitlistToday-81
      [Documentation]  Get Future Waitlist By first name of family member

      ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Waitlist Today  waitlistingFor-eq=firstName::${f_name}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id11}

JD-TC-GetWaitlistToday-82
      [Documentation]  Get Future Waitlist By last name of family member

      ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist Today  waitlistingFor-eq=lastName::${l_name}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id11}

JD-TC-GetWaitlistToday-UH1
      [Documentation]   Get waitlist using consumer login

      ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Get Waitlist Today  service-neq=${ser_id2}  waitlistStatus-neq=${wl_status[0]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  "${resp.json()}"     "${LOGIN_NO_ACCESS_FOR_URL}"
      
JD-TC-GetWaitlistToday-UH2
      [Documentation]   Get waitlist without login

      ${resp}=  Get Waitlist Today  service-neq=${ser_id2}  waitlistStatus-neq=${wl_status[0]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  419
      Should Be Equal As Strings  "${resp.json()}"     "${SESSION_EXPIRED}"

