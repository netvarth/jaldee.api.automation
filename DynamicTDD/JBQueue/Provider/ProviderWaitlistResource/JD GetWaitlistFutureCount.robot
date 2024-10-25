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

*** Test Cases ***
JD-TC-GetWaitlistFutureCount-1
      [Documentation]   View waitlist count by Provider login

      clear_customer    ${HLPUSERNAME24}

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Log  ${resp.content}
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
      ${q_name}=    FakerLibrary.name
      Set Suite Variable    ${q_name}
      ${list}=  Create List   1  2  3  4  5  6  7
      Set Suite Variable    ${list}
      ${DAY1}=  db.add_timezone_date  ${tz}   2
      Set Suite Variable  ${DAY1} 
      ${DAY2}=  db.add_timezone_date  ${tz}  3
      Set Suite Variable  ${DAY2}
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

      ${cname1}=    FakerLibrary.name
      Set Suite Variable    ${cname1}
      ${lname1}=    FakerLibrary.name
      Set Suite Variable    ${lname1}

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

      ${cname2}=    FakerLibrary.name
      Set Suite Variable    ${cname2}
      ${lname2}=    FakerLibrary.name
      Set Suite Variable    ${lname2}

      ${resp}=  AddCustomer  ${CUSERNAME1}   firstName=${cname2}   lastName=${lname2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id1}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id1}  ${tid[0]}

      ${cname3}=    FakerLibrary.name
      Set Suite Variable    ${cname3}
      ${lname3}=    FakerLibrary.name
      Set Suite Variable    ${lname3}

      ${resp}=  AddCustomer  ${CUSERNAME2}   firstName=${cname3}   lastName=${lname3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${DAY2}  ${desc}  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id2}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id2}  ${tid[0]}

      ${cname4}=    FakerLibrary.name
      Set Suite Variable    ${cname4}
      ${lname4}=    FakerLibrary.name
      Set Suite Variable    ${lname4}

      ${resp}=  AddCustomer  ${CUSERNAME3}   firstName=${cname4}   lastName=${lname4} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${DAY2}  ${desc}  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id3}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id3}  ${tid[0]}
      
      ${resp}=  Get Waitlist Future   
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable    ${cname1}    ${resp.json()[0]['consumer']['firstName']}
      Set Suite Variable    ${cname2}    ${resp.json()[1]['consumer']['firstName']}
      Set Suite Variable    ${cname3}    ${resp.json()[2]['consumer']['firstName']}
      Set Suite Variable    ${cname4}    ${resp.json()[3]['consumer']['firstName']}
      
      ${resp}=  Get Waitlist Count Future
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  4
     
JD-TC-GetWaitlistFutureCount-2
      [Documentation]   View waitlist count after cancel

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action CANCEL  ${waitlist_id}  ${waitlist_cancl_reasn[4]}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist Count Future  waitlistStatus-eq=${wl_status[4]}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1
      ${resp}=  Get Waitlist Count Future  waitlistStatus-eq=${wl_status[0]}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3
     
JD-TC-GetWaitlistFutureCount-3
      [Documentation]   Get waitlist waitlistStatus-neq=${wl_status[0]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  waitlistStatus-neq=${wl_status[0]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1
         
JD-TC-GetWaitlistFutureCount-4
      [Documentation]   Get waitlist waitlistStatus-neq=${wl_status[4]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  waitlistStatus-neq=${wl_status[4]}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3
    
JD-TC-GetWaitlistFutureCount-5
      [Documentation]   Get waitlist firstName-eq=${cname1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  firstName-eq=${cname1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistFutureCount-6
      [Documentation]   Get waitlist firstName-neq=${cname1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  firstName-neq=${cname1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3

JD-TC-GetWaitlistFutureCount-7
      [Documentation]   Get waitlist firstName-eq=${cname2}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  firstName-eq=${cname2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistFutureCount-8
      [Documentation]   Get waitlist firstName-neq=${cname2}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  firstName-neq=${cname2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3

JD-TC-GetWaitlistFutureCount-9
      [Documentation]   Get waitlist service-eq=${ser_id1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  service-eq=${ser_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  4
 
JD-TC-GetWaitlistFutureCount-10
      [Documentation]   Get waitlist service-neq=${ser_id1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
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
      ${resp}=  Get Waitlist Count Future  service-neq=${ser_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2

JD-TC-GetWaitlistFutureCount-11
      [Documentation]   Get waitlist firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[4]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistFutureCount-12
      [Documentation]   Get waitlist firstName-neq=${cname1}  waitlistStatus-neq=${wl_status[4]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  firstName-neq=${cname1}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  4

JD-TC-GetWaitlistFutureCount-13
      [Documentation]   Get waitlist firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[0]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[0]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1
 
JD-TC-GetWaitlistFutureCount-14
      [Documentation]   Get waitlist firstName-eq=${cname2}  waitlistStatus-eq=${wl_status[4]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  firstName-eq=${cname2}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  0

JD-TC-GetWaitlistFutureCount-15
      [Documentation]   Get waitlist firstName-neq=${cname2}   waitlistStatus-neq=${wl_status[4]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  firstName-neq=${cname2}   waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3
 
JD-TC-GetWaitlistFutureCount-16
      [Documentation]   Get waitlist firstName-eq=${cname2}   waitlistStatus-eq=${wl_status[0]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  firstName-eq=${cname2}   waitlistStatus-eq=${wl_status[0]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2
 
JD-TC-GetWaitlistFutureCount-17    
      [Documentation]   Get waitlist firstName-eq=${cname1}  service-eq=${ser_id1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  firstName-eq=${cname1}  service-eq=${ser_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1
  
JD-TC-GetWaitlistFutureCount-18
      [Documentation]   Get waitlist firstName-neq=${cname1}  service-neq=${ser_id1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  firstName-neq=${cname1}  service-neq=${ser_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistFutureCount-19
      [Documentation]   Get waitlist firstName-eq=${cname2}  service-eq=${ser_id1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  firstName-eq=${cname2}  service-eq=${ser_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1
 
JD-TC-GetWaitlistFutureCount-20
      [Documentation]   Get waitlist firstName-neq=${cname2}  service-neq=${ser_id1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  firstName-neq=${cname2}  service-neq=${ser_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistFutureCount-21
      [Documentation]   Get waitlist firstName-eq=${cname1}  service-eq=${ser_id2} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  firstName-eq=${cname1}  service-eq=${ser_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistFutureCount-22
      [Documentation]   Get waitlist firstName-neq=${cname1}  service-neq=${ser_id2} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  firstName-neq=${cname1}  service-neq=${ser_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3
 
JD-TC-GetWaitlistFutureCount-23
      [Documentation]   Get waitlist firstName-eq=${cname2}  service-eq=${ser_id2} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  firstName-eq=${cname2}  service-eq=${ser_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistFutureCount-24
      [Documentation]   Get waitlist firstName-neq=${cname2}  service-neq=${ser_id2} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  firstName-neq=${cname2}  service-neq=${ser_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3

JD-TC-GetWaitlistFutureCount-25
      [Documentation]   Get waitlist service-eq=${ser_id1}   waitlistStatus-eq=${wl_status[4]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  service-eq=${ser_id1}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistFutureCount-26
      [Documentation]   Get waitlist service-neq=${ser_id1}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Get Waitlist Count Future  service-neq=${ser_id1}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2

JD-TC-GetWaitlistFutureCount-27
      [Documentation]   Get waitlist service-eq=${ser_id1}   waitlistStatus-eq=${wl_status[0]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  service-eq=${ser_id1}  waitlistStatus-eq=${wl_status[0]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3

JD-TC-GetWaitlistFutureCount-28
      [Documentation]   Get waitlist service-eq=${ser_id2}   waitlistStatus-eq=${wl_status[0]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  service-eq=${ser_id2}  waitlistStatus-eq=${wl_status[0]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2

JD-TC-GetWaitlistFutureCount-29
      [Documentation]   Get waitlist service-eq=${ser_id2}   waitlistStatus-eq=${wl_status[4]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  service-eq=${ser_id2}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  0

JD-TC-GetWaitlistFutureCount-30
      [Documentation]   Get waitlist service-neq=${ser_id2}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Get Waitlist Count Future  service-neq=${ser_id2}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3

JD-TC-GetWaitlistFutureCount-31
      [Documentation]   Get waitlist token_id-eq=${token_id}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  token-eq=${token_id}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2
 
JD-TC-GetWaitlistFutureCount-32
      [Documentation]   Get waitlist token_id-neq=${token_id}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  token-neq=${token_id}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  4

JD-TC-GetWaitlistFutureCount-33
      [Documentation]   Get waitlist token_id-eq=${token_id}  service-eq=${ser_id1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  token-eq=${token_id}  service-eq=${ser_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2

JD-TC-GetWaitlistFutureCount-34
      [Documentation]   Get waitlist token_id-neq=${token_id}  service-neq=${ser_id2}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  token-neq=${token_id}  service-neq=${ser_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2

JD-TC-GetWaitlistFutureCount-35
      [Documentation]   Get waitlist firstName-eq=${cname1}  date-eq=${DAY1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  firstName-eq=${cname1}  date-eq=${DAY1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2
 
JD-TC-GetWaitlistFutureCount-36
      [Documentation]   Get waitlist  date-neq=${DAY1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  date-neq=${DAY1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3

NW-TC-GetWaitlistFutureCount-37
      [Documentation]   Get waitlist date-eq=${DAY1}  service-neq=${ser_id2}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  date-eq=${DAY1}  service-neq=${ser_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2
  
JD-TC-GetWaitlistFutureCount-38
      [Documentation]   Get waitlist waitlistStatus-eq=${wl_status[4]}   date-eq=${DAY1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  waitlistStatus-eq=${wl_status[4]}  date-eq=${DAY1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistFutureCount-39
      [Documentation]   Get waitlist queue-eq   from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  queue-eq=${que_id1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  6

JD-TC-GetWaitlistFutureCount-40
      [Documentation]   Get waitlist queue-neq   from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  queue-neq=${que_id1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  0

JD-TC-GetWaitlistFutureCount-41
      [Documentation]   Get waitlist queue-eq  and token-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  queue-eq=${que_id1}  token-eq=${token_id}    from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2

JD-TC-GetWaitlistFutureCount-42
      [Documentation]   Get waitlist queue-eq  and token-neq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  queue-eq=${que_id1}  token-neq=${token_id}    from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  4

JD-TC-GetWaitlistFutureCount-43
      [Documentation]   Get waitlist queue-eq  and firstName-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  queue-eq=${que_id1}  firstName-eq=${cname2}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2

JD-TC-GetWaitlistFutureCount-44
      [Documentation]   Get waitlist queue-eq  and service-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  queue-eq=${que_id1}  service-eq=${ser_id1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  4

JD-TC-GetWaitlistFutureCount-45
      [Documentation]   Get waitlist queue-eq  and  waitlistStatus-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  queue-eq=${que_id1}  waitlistStatus-eq=${wl_status[4]}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistFutureCount-46
      [Documentation]   Get waitlist queue-eq  and  date-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  queue-eq=${que_id1}  date-eq=${DAY1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3

JD-TC-GetWaitlistFutureCount-47
      [Documentation]   Get waitlist location-eq   from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  location-eq=${loc_id1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  6

JD-TC-GetWaitlistFutureCount-48
      [Documentation]   Get waitlist location-neq=${loc_id1}   from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  location-neq=${loc_id1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  0

JD-TC-GetWaitlistFutureCount-49
      [Documentation]   Get waitlist location-eq=${loc_id1}  and token-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  location-eq=${loc_id1}  token-eq=${token_id}    from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2

JD-TC-GetWaitlistFutureCount-50
      [Documentation]   Get waitlist location-eq=${loc_id1}  and token-neq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  location-eq=${loc_id1}  token-neq=${token_id}    from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  4
 
JD-TC-GetWaitlistFutureCount-51
      [Documentation]   Get waitlist location-eq=${loc_id1}  and firstName-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  location-eq=${loc_id1}  firstName-eq=${cname2}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2

JD-TC-GetWaitlistFutureCount-52
      [Documentation]   Get waitlist location-eq=${loc_id1}  and service-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  location-eq=${loc_id1}  service-eq=${ser_id1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  4

JD-TC-GetWaitlistFutureCount-53
      [Documentation]   Get waitlist location-eq=${loc_id1}  and  waitlistStatus-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  location-eq=${loc_id1}  waitlistStatus-eq=${wl_status[4]}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistFutureCount-54
      [Documentation]   Get waitlist location-eq=${loc_id1}  and  date-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  location-eq=${loc_id1}  date-eq=${DAY1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3

JD-TC-GetWaitlistFutureCount-55
      [Documentation]   Get waitlist location-eq=${loc_id1}  and  queue-eq from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Future  location-eq=${loc_id1}  queue-eq=${que_id1}   from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  6

JD-TC-GetWaitlistFutureCount-56
      [Documentation]   Get Future Waitlist count of a family member. 
      # clear_queue      ${PUSERNAME40}
      # clear_location   ${PUSERNAME40}
      # clear_service    ${PUSERNAME40}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME40}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${ser_duratn}=  Random Int   min=2   max=4
      ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${ser_duratn}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=   Create Sample Location
      Set Suite Variable    ${loc_id11}    ${resp}  
      ${resp}=   Get Location ById  ${loc_id11}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['timezone']}
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

      ${f_name}=   generate_firstname
      Set Suite Variable  ${f_name}
      ${l_name}=   FakerLibrary.last_name
      Set Suite Variable  ${l_name}
      ${dob}=      FakerLibrary.date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProvider  ${cid}  ${f_name}  ${l_name}  ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${mem_id}  ${resp.json()}

      ${FUT_DAY}=  db.add_timezone_date  ${tz}   3
      ${resp}=  Add To Waitlist  ${cid}  ${ser_id11}  ${que_id11}  ${FUT_DAY}  ${desc}  ${bool[1]}  ${mem_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id11}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id11}  ${tid[0]}
      ${resp}=  Get provider communications
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Waitlist Count Future   
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistFutureCount-UH1
      [Documentation]   Get waitlist using consumer login

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

      ${fname}=  generate_firstname
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

      ${jsessionynw_value}=   Get Cookie from Header  ${resp}
      ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}   JSESSIONYNW=${jsessionynw_value}
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200
      Set Suite Variable  ${token}  ${resp.json()['token']}

      ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200   

      ${resp}=  Get Waitlist Count Future  service-neq=${ser_id2}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  "${resp.json()}"     "${LOGIN_NO_ACCESS_FOR_URL}"
      
JD-TC-GetWaitlistFutureCount-UH2
      [Documentation]   Get waitlist without login

      ${resp}=  Get Waitlist Count Future  service-neq=${ser_id2}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  419
      Should Be Equal As Strings  "${resp.json()}"     "${SESSION_EXPIRED}"
