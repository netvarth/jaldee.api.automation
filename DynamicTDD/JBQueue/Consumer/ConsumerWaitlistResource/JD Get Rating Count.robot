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
  
*** Variables ***
${service_duration}   5   
${self}         0
@{stars}        1  2  3  4  5

*** Test Cases ***
JD-TC-Get Waitist Rating-1

    [Documentation]  Get waitlist Rating Filter Using Input  
    Comment   a provider Waitlisted consumer gives Rating 
    [setup]  Run Keywords  clear_queue  ${PUSERNAME106}  AND   clear_service   ${PUSERNAME106}  AND  clear waitlist   ${PUSERNAME106}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME106}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_customer   ${PUSERNAME106}

    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l1}  ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  AddCustomer  ${CUSERNAME0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Change License Package  ${pkgid[0]}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${pid}=  get_acc_id  ${PUSERNAME106}
    Set suite variable  ${pid} 
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${list}=  Create List   1  2  3  4  5  6  7

    ${P1SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s1}  ${resp.json()} 

    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200    
    Set Suite Variable  ${p1_s2}  ${resp.json()}
    
    
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

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid1}  ${wid[0]}

    ${comment}=   FakerLibrary.word
    ${resp}=   Waitlist Rating  ${uuid1}   ${stars[2]}  ${comment}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Waitlist By Id  ${uuid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}  ${stars[2]}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}   ${comment}

    ${resp}=  Add To Waitlist  ${cid}  ${p1_s2}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid2}  ${wid[0]}

    ${comment}=   FakerLibrary.word
    ${resp}=   Waitlist Rating  ${uuid2}   ${stars[3]}  ${comment}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${uuid2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}  ${stars[3]}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}   ${comment}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid1}  ${p1_s1}  ${p1_q2}  ${DAY}  ${cnote}  ${bool[1]}  ${cid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid3}  ${wid[0]}

    ${comment}=   FakerLibrary.word
    ${resp}=   Waitlist Rating  ${uuid3}   ${stars[1]}  ${comment}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${uuid3} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}  ${stars[1]}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}   ${comment}

    ${resp}=  Add To Waitlist  ${cid1}  ${p1_s2}  ${p1_q2}  ${DAY}  ${cnote}  ${bool[1]}  ${cid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid4}  ${wid[0]}

    ${comment}=   FakerLibrary.word
    ${resp}=   Waitlist Rating  ${uuid4}   ${stars[4]}  ${comment}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${uuid4} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}  ${stars[4]}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}   ${comment}

    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid2}  ${p1_s1}  ${p1_q2}  ${DAY}  ${cnote}  ${bool[1]}  ${cid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid5}  ${wid[0]}

    ${comment}=   FakerLibrary.word
    ${resp}=   Waitlist Rating  ${uuid5}   ${stars[1]}  ${comment}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${uuid5} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}  ${stars[1]}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}   ${comment}

    ${resp}=  Add To Waitlist  ${cid2}  ${p1_s2}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${cid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid6}  ${wid[0]}

    ${comment}=   FakerLibrary.word
    ${resp}=   Waitlist Rating  ${uuid6}   ${stars[4]}  ${comment}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${uuid6} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}  ${stars[4]}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}   ${comment}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Rating  account=${pid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  6  

JD-TC-Get Waitist Rating-2
    [Documentation]  Get waitlist Rating Filter Using Input account=${pid} service-eq=${p1_s2} 

    ${resp}=  Get Rating  account=${pid}  service-eq=${p1_s2}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  3
    # Should Be Equal As Strings  ${resp.json()[0]['uuid']}   ${uuid8} 
    Should Be Equal As Strings  ${resp.json()[0]['uuid']}   ${uuid6}  
    Should Be Equal As Strings  ${resp.json()[1]['uuid']}   ${uuid4} 
    Should Be Equal As Strings  ${resp.json()[2]['uuid']}   ${uuid2}

JD-TC-Get Waitist Rating-3
    [Documentation]  Get waitlist Rating Filter Using Input account=${pid} rating-eq=2  

    ${resp}=  Get Rating  account=${pid}  rating-eq=2
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2    
    Should Be Equal As Strings  ${resp.json()[1]['uuid']}  ${uuid3}
    Should Be Equal As Strings  ${resp.json()[0]['uuid']}  ${uuid5}
    


JD-TC-Get Waitist Rating-5
    [Documentation]  Get waitlist Rating Filter Using Input account=${pid} service-eq=${p1_s2} rating-eq=4 

    ${resp}=  Get Rating  account=${pid}  service-eq=${p1_s2}   rating-eq=4
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1
    # Should Be Equal As Strings  ${resp.json()[0]['uuid']}  ${uuid8}
    Should Be Equal As Strings  ${resp.json()[0]['uuid']}  ${uuid2}

JD-TC-Get Waitist Rating-6
    [Documentation]  Get waitlist Rating Filter Using Input account=${pid} rating-eq=2 createdDate-eq=${DAY}

    ${resp}=  Get Rating  account=${pid}  rating-eq=2  createdDate-eq=${DAY}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2   
    Should Be Equal As Strings  ${resp.json()[1]['uuid']}  ${uuid3} 
    Should Be Equal As Strings  ${resp.json()[0]['uuid']}  ${uuid5} 


*** Comments ***

JD-TC-Get Waitist Rating-4
    [Documentation]  Get waitlist Rating Filter Using Input account=${pid} createdDate-eq=${DAY1}

    ${resp}=  Get Rating  account=${pid}  createdDate-eq=${DAY1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2  
    Should Be Equal As Strings  ${resp.json()[1]['uuid']}  ${uuid7} 
    Should Be Equal As Strings  ${resp.json()[0]['uuid']}  ${uuid8} 