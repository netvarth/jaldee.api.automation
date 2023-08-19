*** Settings ***
Test Teardown     Delete All Sessions   
# Suite Teardown    Run Keywords  Delete All Sessions  resetsystem_time
Suite Teardown    Delete All Sessions
Force Tags        Rating
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
  



*** Test Cases ***

JD-TC-Get Waitist Rating-1
 
    [Documentation]   get history waitlist rating of a provider.(online checkin) with filter- account
    
    ${resp}=  Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    clear_queue    ${PUSERNAME206}
    clear_service  ${PUSERNAME206}
    clear_customer   ${PUSERNAME206}
    clear_Item   ${PUSERNAME206}

    change_system_date  -5

    ${resp}=  Encrypted Provider Login  ${PUSERNAME206}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${cid}=  get_id  ${CUSERNAME0}
    # Set Suite Variable  ${cid}
    ${pid}=  get_acc_id  ${PUSERNAME206}
    Set suite variable  ${pid} 
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${list}=  Create List   1  2  3  4  5  6  7

    ${P1SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   5  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s1}  ${resp.json()} 

    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   5  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200    
    Set Suite Variable  ${p1_s2}  ${resp.json()}

    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l1}  ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    
    ${sTime1}=  add_timezone_time  ${tz}  1  00  
    ${eTime1}=  add_timezone_time  ${tz}  1  30  
    ${p1queue1}=    FakerLibrary.word
    Set Suite Variable   ${p1queue1}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q1}  ${resp.json()}    

    ${sTime2}=  add_timezone_time  ${tz}  1  30  
    ${eTime2}=  add_timezone_time  ${tz}  2  00  
    ${p1queue2}=    FakerLibrary.word
    Set Suite Variable   ${p1queue2}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue2}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q2}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME0}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid1}  ${wid[0]}

    ${comment}=   FakerLibrary.word
    ${resp}=   Waitlist Rating  ${uuid1}   3  ${comment}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Waitlist By Id  ${uuid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}  3
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}   ${comment}

    ${resp}=  Add To Waitlist  ${cid}  ${p1_s2}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid2}  ${wid[0]}

    ${comment}=   FakerLibrary.word
    ${resp}=   Waitlist Rating  ${uuid2}   4  ${comment}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${uuid2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}  4
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}   ${comment}

    # ${cid1}=  get_id  ${CUSERNAME1}
    ${resp}=  AddCustomer  ${CUSERNAME1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid1}  ${p1_s1}  ${p1_q2}  ${DAY}  ${cnote}  ${bool[1]}  ${cid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid3}  ${wid[0]}

    ${comment}=   FakerLibrary.word
    ${resp}=   Waitlist Rating  ${uuid3}   2  ${comment}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${uuid3} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}  2
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}   ${comment}

    ${resp}=  Add To Waitlist  ${cid1}  ${p1_s2}  ${p1_q2}  ${DAY}  ${cnote}  ${bool[1]}  ${cid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid4}  ${wid[0]}

    ${comment}=   FakerLibrary.word
    ${resp}=   Waitlist Rating  ${uuid4}   5  ${comment}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${uuid4} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}  5
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}   ${comment}

    # ${cid2}=  get_id  ${CUSERNAME2}
    ${resp}=  AddCustomer  ${CUSERNAME2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid2}  ${p1_s1}  ${p1_q2}  ${DAY}  ${cnote}  ${bool[1]}  ${cid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid5}  ${wid[0]}

    ${comment}=   FakerLibrary.word
    ${resp}=   Waitlist Rating  ${uuid5}   2  ${comment}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${uuid5} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}  2
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}   ${comment}

    ${resp}=  Add To Waitlist  ${cid2}  ${p1_s2}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid6}  ${wid[0]}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Rating  account=${pid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}   5

    resetsystem_time

    ${resp}=   Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Rating  account=${pid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  5 

JD-TC-Get Waitist Rating-2
 
    [Documentation]   add rating to a waitlist in the history.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME206}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${comment}=   FakerLibrary.word
    ${resp}=   Waitlist Rating  ${uuid6}   5  ${comment}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${uuid6} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}  5
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}   ${comment}


JD-TC-Get Waitist Rating-3
 
    [Documentation]   get history waitlist rating of a provider.(online checkin) with filter- date

    ${resp}=   Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${date}=  db.subtract_timezone_date  ${tz}    5

    ${resp}=  Get Rating  createdDate-eq=${date}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  5 

    ${date1}=  db.get_date_by_timezone  ${tz}  

    ${resp}=  Get Rating  createdDate-eq=${date1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}   1


JD-TC-Get Waitist Rating-4

    [Documentation]  get history waitlist rating of a provider.(online checkin) with filter- date and account  
    

    ${resp}=  Encrypted Provider Login  ${PUSERNAME206}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l1}  ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Test Variable   ${p1_s2}   ${resp.json()[1]['id']}

    ${resp}=   Get Queues
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_q1}   ${resp.json()[0]['id']}  
    Set Test Variable   ${p1_q2}   ${resp.json()[1]['id']}  

    change_system_date  -1

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set suite variable  ${DAY1}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME206}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME4}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid3}   ${resp.json()}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid3}  ${p1_s1}  ${p1_q2}  ${DAY1}  ${cnote}  ${bool[1]}  ${cid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid7}  ${wid[0]}

    ${comment}=   FakerLibrary.word
    ${resp}=   Waitlist Rating  ${uuid7}   3  ${comment}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${uuid7} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}  3
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}   ${comment}
    
    ${resp}=  Add To Waitlist  ${cid3}  ${p1_s2}  ${p1_q1}  ${DAY1}  ${cnote}  ${bool[1]}  ${cid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid8}  ${wid[0]}

    ${comment}=   FakerLibrary.word
    ${resp}=   Waitlist Rating  ${uuid8}   4  ${comment}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${uuid8} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}  4
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}   ${comment}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    resetsystem_time

    ${resp}=   Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Rating  account=${pid}  createdDate-eq=${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2  
    Should Be Equal As Strings  ${resp.json()[1]['uuid']}  ${uuid7} 
    Should Be Equal As Strings  ${resp.json()[0]['uuid']}  ${uuid8} 


*** Comment ***


JD-TC-Get Waitist Rating-
 
    [Documentation]   update waitist rating for a history  online checkin.

JD-TC-Get Waitist Rating-
 
    [Documentation]   update waitist rating for a history  walkin checkin.


JD-TC-Get Waitist Rating-
 
    [Documentation]   get history waitlist rating of a provider.(walkin checkin) with filter- account

JD-TC-Get Waitist Rating-
 
    [Documentation]   get history waitlist rating of a provider.(walkin checkin) with filter- account and date