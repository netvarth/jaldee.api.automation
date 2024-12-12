*** Settings ***
Test Teardown     Delete All Sessions
# Suite Teardown    Run Keywords  Delete All Sessions  resetsystem_time
Suite Teardown    Delete All Sessions
Force Tags        Rating
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
# Variables         /ebs/TDD/varfiles/consumermail.py
  
*** Variables ***
${service_duration}   5   
${self}     0
@{service_names}
@{stars}        1  2  3  4  5

*** Test Cases ***
JD-TC-Get Waitist Rating-1

    [Documentation]  Get waitlist Rating Filter Using Input  
    Comment   a provider Waitlisted consumer gives Rating 
    # [setup]  Run Keywords  clear_queue  ${PUSERNAME106}  AND   # clear_service   ${PUSERNAME106}  AND  clear waitlist   ${PUSERNAME106}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME106}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_customer   ${PUSERNAME106}

    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l1}  ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name

    ${resp}=  AddCustomer  ${CUSERNAME2}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
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

    ${P1SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${P1SERVICE1}
    Set Suite Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}  ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s1}  ${resp.json()} 

    ${P1SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${P1SERVICE2}
    Set Suite Variable  ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}
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

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME2}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME2}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME2}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${cons_id}  ${resp.json()['id']}

    ${resp}=  Get Rating  account=${pid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

JD-TC-Get Waitist Rating-2
    [Documentation]  Get waitlist Rating Filter Using Input account=${pid} service-eq=${p1_s2} 

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME2}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Rating  account=${pid}  service-eq=${p1_s2}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1
    Should Be Equal As Strings  ${resp.json()[0]['uuid']}   ${uuid2}

JD-TC-Get Waitist Rating-3
    [Documentation]  Get waitlist Rating Filter Using Input account=${pid} rating-eq=1

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME2}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Rating  account=${pid}  rating-eq=2
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  0 


JD-TC-Get Waitist Rating-5
    [Documentation]  Get waitlist Rating Filter Using Input account=${pid} service-eq=${p1_s2} rating-eq=4 

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME2}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Rating  account=${pid}  service-eq=${p1_s2}   rating-eq=4
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1
    # Should Be Equal As Strings  ${resp.json()[0]['uuid']}  ${uuid8}
    Should Be Equal As Strings  ${resp.json()[0]['uuid']}  ${uuid2}
