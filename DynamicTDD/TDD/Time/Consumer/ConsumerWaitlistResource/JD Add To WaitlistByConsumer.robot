*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions  resetsystem_time
Force Tags        Waitlist
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

${digits}       0123456789
${self}         0


*** Test Cases ***

JD-TC-Add To WaitlistByConsumer-1

	[Documentation]  check the waitlist history by consumer for an online checkin.

    change_system_date  -3

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${pid0}=  get_acc_id  ${PUSERNAME1}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  0  15  
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_l1}  ${resp.json()}
    
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   5  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_s1}  ${resp.json()}
    
    ${P2SERVICE2}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P2SERVICE2}  ${desc}   5  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_s2}  ${resp.json()}

    ${sTime1}=  add_timezone_time  ${tz}  4  15  
    ${eTime1}=  add_timezone_time  ${tz}  6  30  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_q1}  ${resp.json()}
    
    ${sTime2}=  add_timezone_time  ${tz}  2  30  
    ${eTime2}=  add_timezone_time  ${tz}  3  45  
    ${p1queue2}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${resp}=  Create Queue  ${p1queue2}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  1  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_q2}  ${resp.json()}
   
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200    
    
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    
    ${cid}=  get_id  ${CUSERNAME5}    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcons_id1}  ${resp.json()[0]['id']}

    resetsystem_time

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}            ${wl_status[0]}
    Should Be Equal As Strings  ${resp.json()['date']}                      ${DAY}
    Should Be Equal As Strings  ${resp.json()['service']['name']}           ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}             ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}   ${pcons_id1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}               ${p1_q1}


JD-TC-Add To WaitlistByConsumer-2

	[Documentation]  checking the waitlistStatus of a consumer prepaymentPending to cancelled then again adding a consumer to waitlist and checking personsAhead   

    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${pid1}=  get_acc_id  ${PUSERNAME2}
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}    Random Element     ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  30  
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[4]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p2_l1}  ${resp.json()}

    ${P2SERVICE1}=    FakerLibrary.word
    Set Test Variable  ${P2SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P2SERVICE1}  ${desc}   20  ${status[0]}    ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p2_s1}  ${resp.json()}

    ${P2SERVICE2}=    FakerLibrary.word
    Set Test Variable  ${P2SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P2SERVICE2}  ${desc}   20  ${status[0]}    ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p2_s2}  ${resp.json()}

    ${resp}=    Update Waitlist Settings  ${calc_mode[0]}  20  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[0]}   ${EMPTY}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${sTime1}=  add_timezone_time  ${tz}  0  30  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${p2queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${resp}=  Create Queue  ${p2queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p2_l1}  ${p2_s1}  ${p2_s2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p2_q1}  ${resp.json()}

    ${resp}=   Get Account Settings 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     

    ${cid}=  get_id  ${CUSERNAME1}   
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid1}  ${p2_q1}  ${DAY}  ${p2_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcons_id2}  ${resp.json()[0]['id']}

    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}            ${wl_status[3]}
    Should Be Equal As Strings  ${resp.json()['date']}                      ${DAY}
    Should Be Equal As Strings  ${resp.json()['service']['name']}           ${P2SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}             ${p2_s1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}   ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}               ${p2_q1}
   
    ${resp}=  Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    change_system_time   0  20
    # ${sT}=  db.get_time_by_timezone  ${tz}
    ${sT}=  db.get_time_by_timezone  ${tz}
    ${DAY2}=  db.get_date_by_timezone  ${tz}
    # sleep  15m
    
    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    # ${pid1}=  get_acc_id  ${PUSERNAME2}   
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   waitlistStatus=${wl_status[3]}
    
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    ${cid}=  get_id  ${CUSERNAME2}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid1}  ${p2_q1}  ${DAY}  ${p2_s2}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    # sleep  02s

    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${pid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  personsAhead=0

JD-TC-Add To WaitlistByConsumer-3

    [Documentation]  checkedIn a future waitlist and change day and check waitlist actions

    clear_queue    ${PUSERNAME1}
    clear_service  ${PUSERNAME1}
    clear_customer   ${PUSERNAME1}
    clear_Item   ${PUSERNAME1}

    ${pid0}=  get_acc_id  ${PUSERNAME1}
    ${cid}=  get_id  ${CUSERNAME4}
    ${DAY}=  db.get_date_by_timezone  ${tz}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${P1SERVICE1}=    FakerLibrary.word
    ${servicecharge}=   Random Int  min=100  max=500
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   5  ${status[0]}    ${btype}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_s1}  ${resp.json()}
    
    ${TOMORROW}=  db.add_timezone_date  ${tz}  2  
    ${city}=   get_place
    ${latti1}=  get_latitude
    ${longi1}=  get_longitude
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sLTime}=  db.get_time_by_timezone  ${tz}
    ${sLTime}=  db.get_time_by_timezone  ${tz}
    ${eLTime}=  add_timezone_time  ${tz}  0  30  
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi1}  ${latti1}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[4]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sLTime}  ${eLTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_l3}  ${resp.json()}

    # ${sTime3}=  db.get_time_by_timezone  ${tz}
    ${sTime3}=  db.get_time_by_timezone  ${tz}
    ${eTime3}=  add_timezone_time  ${tz}  0  30  
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${resp}=  Create Queue  ${queue1}   ${recurringtype[1]}  ${list}  ${TOMORROW}  ${EMPTY}  ${EMPTY}  ${sTime3}  ${eTime3}  1  ${capacity}  ${p1_l3}  ${p1_s1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_q2}  ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q2}  ${TOMORROW}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${TOMORROW}  waitlistStatus=${wl_status[0]} 
    
    ${resp}=  Consumer Logout       
    Should Be Equal As Strings  ${resp.status_code}  200  

    change_system_date  2
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    
    ${resp}=  Waitlist Action  REPORT  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Waitlist By Id  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[1]}
    
    ${resp}=  Waitlist Action  STARTED  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Waitlist By Id  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[2]}
    
    ${resp}=  Waitlist Action  DONE  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Add To WaitlistByConsumer-UH1

	[Documentation]  the consumer add to waitlist for a service with prepayment and waitlist get cancelled  ,because  prepayment was not done 
    
    clear_queue    ${PUSERNAME2}
    clear_service  ${PUSERNAME2}
    clear_customer   ${PUSERNAME2}
    clear_Item   ${PUSERNAME2}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid1}=  get_acc_id  ${PUSERNAME2}
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}    Random Element     ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  30  
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[4]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p2_l1}  ${resp.json()}

    ${P1SERVICE1}=    FakerLibrary.word
    Set Test Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   5  ${status[0]}    ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_s1}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    Set Test Variable  ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   5  ${status[0]}    ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_s2}  ${resp.json()}

    ${resp}=    Update Waitlist Settings  ${calc_mode[0]}  20  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p2_l1}  ${p1_s1}  ${p1_s2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    
    ${cid}=  get_id  ${CUSERNAME5}    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid1}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pcons_id2}  ${resp.json()[0]['id']}

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}            ${wl_status[3]}
    Should Be Equal As Strings  ${resp.json()['date']}                      ${DAY}
    Should Be Equal As Strings  ${resp.json()['service']['name']}           ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}             ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}   ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}               ${p1_q1}
    
    change_system_time  0  20
    # sleep  5s
    
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}            ${wl_status[3]}
    Should Be Equal As Strings  ${resp.json()['date']}                      ${DAY}
    Should Be Equal As Strings  ${resp.json()['service']['name']}           ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}             ${p1_s1}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Waitlist Action  CHECK_IN  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    # ${WAITLIST_STATUS_NOT_CHANGEABLE_AS_PREPAY_PENDING}=  Format String   ${WAITLIST_STATUS_NOT_CHANGEABLE_AS_PREPAY_PENDING}   ${wl_status[3]}   ${wl_status[0]} 
    Should Be Equal As Strings  ${resp.json()}    ${PAYMENT_NOT_DONE}


JD-TC-Add To WaitlistByConsumer-UH2

	[Documentation]  the consumer add to waitlist for a service with prepayment  
    ${DAY}=  db.get_date_by_timezone  ${tz}  
    
    ${resp}=   Run Keywords   clear_queue  ${PUSERNAME1}  AND  clear waitlist   ${PUSERNAME1}
    ${cid}=  get_id  ${CUSERNAME1} 
    ${pid0}=  get_acc_id  ${PUSERNAME1}
    ${DAY}=  db.get_date_by_timezone  ${tz}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}
    # Set Test Variable   ${p1_s2}   ${resp.json()[1]['id']}
    # Set Test Variable   ${P1SERVICE2}   ${resp.json()[1]['name']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}
    Set Test Variable   ${p1_l2}   ${resp.json()[1]['id']}

    ${p1queue1}=    FakerLibrary.word
    ${sTime1}=  add_timezone_time  ${tz}  4  15  
    ${eTime1}=  add_timezone_time  ${tz}  6  30  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l1}  ${p1_s1}  
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_q1}  ${resp.json()}

    ${p1queue2}=    FakerLibrary.word
    ${sTime2}=  add_timezone_time  ${tz}  2  30  
    ${eTime2}=  add_timezone_time  ${tz}  3  45  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${resp}=  Create Queue  ${p1queue2}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  1  ${capacity}  ${p1_l1}  ${p1_s1} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_q2}  ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
       
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pcons_id2}  ${resp.json()[0]['id']}

    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get consumer Waitlist By Id   ${wid}  ${pid0}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}            ${wl_status[0]}
    Should Be Equal As Strings  ${resp.json()['date']}                      ${DAY}
    Should Be Equal As Strings  ${resp.json()['service']['name']}           ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}             ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}   ${pcons_id2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}               ${p1_q1}

    ${resp}=  Consumer Logout       
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Accept Payment  ${wid}  cash  100  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Payment By UUId  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    change_system_time  0  5
    # sleep  5s

    ${resp}=  Get Payment By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
