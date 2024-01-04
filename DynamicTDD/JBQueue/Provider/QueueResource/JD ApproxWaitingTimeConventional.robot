*** Settings ***
Test Teardown     Delete All Sessions
Force Tags        WaitingTime
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
${SERVICE1}    MakeupS  
${SERVICE2}    Hair makeupS
${SERVICE3}    Makeup2S 
${SERVICE4}   Hair makeup2S
${SERVICE5}    Hair makeup3SS
${self}        0
${capacity}    15
@{parallel}    1   2   3
@{new}        20.75   20.65   20.50


*** Test Cases ***

JD-TC-Approximate Waiting Time Conventional-1
    [Documentation]   Add a consumer to the waitlist for the current day when calculation mode as Conventional and parallel serving is 1 , Then Verify all consumers approximate waiting time
    
    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_Z}=  Evaluate  ${PUSERNAME}+553212
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_Z}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_Z}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_Z}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME_Z}${\n}
    Set Suite Variable  ${PUSERNAME_Z}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_Z}+15566124
    ${ph2}=  Evaluate  ${PUSERNAME_Z}+25566128
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${PUSERNAME_Z}.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
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
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
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
    
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    clear_service   ${PUSERNAME_Z}
    clear_location  ${PUSERNAME_Z}
    clear_queue  ${PUSERNAME_Z}
    clear_customer  ${PUSERNAME_Z}

    ${resp}=  Update Waitlist Settings  ${calc_mode[3]}  0  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${sTime1}=  db.subtract_timezone_time  ${tz}   1  30
    ${eTime1}=  add_timezone_time  ${tz}   3   30
    ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
    ${24hours}    Random Element    ['True','False']
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid1}  ${resp.json()}

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur1}=  Random Int  min=2  max=10
    ${SERVICE1}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${s_dur1}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_1}  ${resp.json()} 

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur2}=  Random Int  min=11  max=20
    ${SERVICE2}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${s_dur2}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_2}  ${resp.json()} 

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur3}=  Random Int  min=21  max=30
    ${SERVICE3}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE3}  ${desc}   ${s_dur3}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_3}  ${resp.json()} 

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur4}=  Random Int  min=31  max=34
    ${SERVICE4}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE4}  ${desc}   ${s_dur4}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_4}  ${resp.json()} 

    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel[0]}  ${capacity}  ${lid1}  ${sId_1}  ${sId_2}  ${sId_3}  ${sId_4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qi_d1}  ${resp.json()}
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}


    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_3}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_4}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid4}  ${wid[0]}    
    
    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}


    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid5}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid6}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_3}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid7}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_4}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid8}  ${wid[0]}

    ${waiting_time}=  Evaluate  ((${s_dur1}+${s_dur2}+${s_dur3}+${s_dur4})/4)/1
    ${wait_time}=  Convert To Integer  ${waiting_time}
    ${waiting_time1}=  Evaluate  ${wait_time}+${waiting_time}
    ${wait_time1}=  Convert To Integer  ${waiting_time1}
    ${waiting_time2}=  Evaluate  ${wait_time1}+${waiting_time}
    ${wait_time2}=  Convert To Integer  ${waiting_time2}
    ${waiting_time3}=  Evaluate  ${wait_time2}+${waiting_time}
    ${wait_time3}=  Convert To Integer  ${waiting_time3}
    ${waiting_time4}=  Evaluate  ${wait_time3}+${waiting_time}
    ${wait_time4}=  Convert To Integer  ${waiting_time4}
    ${waiting_time5}=  Evaluate  ${wait_time4}+${waiting_time}
    ${wait_time5}=  Convert To Integer  ${waiting_time5}
    ${waiting_time6}=  Evaluate  ${wait_time5}+${waiting_time}
    ${wait_time6}=  Convert To Integer  ${waiting_time6}

    
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time}  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time1}
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   ${wait_time2} 
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   ${wait_time3}
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   ${wait_time4}
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   ${wait_time5}
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}   ${wait_time6}

    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid1}       
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  01s
  
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time}
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   ${wait_time1}  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   ${wait_time2} 
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   ${wait_time3}  
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   ${wait_time4} 
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}   ${wait_time5} 
          
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  01s

    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}  0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}  0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}  0
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}  ${wait_time} 
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}  ${wait_time1} 
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}  ${wait_time2}  
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}  ${wait_time3} 
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}  ${wait_time4} 
    
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid3}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  01s
    
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   ${wait_time}
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   ${wait_time1}
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   ${wait_time2}
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}   ${wait_time3}
    
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid4}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  01s
    
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   ${wait_time}
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   ${wait_time1}
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}   ${wait_time2}
   
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid5}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  01s
    
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   ${wait_time}
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}   ${wait_time1}
   
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid6}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  01s 
    
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}   ${wait_time}
    
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid7}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  03s
    
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}   0

    ${resp}=  Get Queue ById  ${qi_d1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=${wait_time}  queueWaitingTime=${wait_time}

   
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid8}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  01s
    
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}   0

    ${resp}=  Get Queue ById  ${qi_d1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=${wait_time}  queueWaitingTime=0


JD-TC-Approximate Waiting Time Conventional-2
    [Documentation]   Add a consumer to the waitlist for the current day when calculation mode as Conventional and parallel serving is 2 , Then Verify all consumers approximate waiting time
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${PUSERNAME_Z}
    clear_location  ${PUSERNAME_Z}
    clear_queue  ${PUSERNAME_Z}
    clear_customer   ${PUSERNAME_Z}
    ${resp}=  Update Waitlist Settings  ${calc_mode[3]}  0  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    
    
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
    ${24hours}    Random Element    ['True','False']
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${sTime1}=  db.subtract_timezone_time  ${tz}  2  00
    ${eTime1}=  add_timezone_time  ${tz}  3  30  
    ${sTime}=  add_timezone_time  ${tz}  5  15  
    ${eTime}=  add_timezone_time  ${tz}  6  30  
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid1}  ${resp.json()}

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur1}=  Random Int  min=2  max=10
    ${SERVICE1}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${s_dur1}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_1}  ${resp.json()} 

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur2}=  Random Int  min=11  max=20
    ${SERVICE2}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${s_dur2}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_2}  ${resp.json()} 

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur3}=  Random Int  min=21  max=30
    ${SERVICE3}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE3}  ${desc}   ${s_dur3}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_3}  ${resp.json()} 

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur4}=  Random Int  min=31  max=34
    ${SERVICE4}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE4}  ${desc}   ${s_dur4}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_4}  ${resp.json()} 

    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel[1]}  ${capacity}  ${lid1}  ${sId_1}  ${sId_2}  ${sId_3}  ${sId_4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qi_d1}  ${resp.json()}
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}

    ${resp}=  AddCustomer  ${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}


    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_3}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_4}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid4}  ${wid[0]}    

    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}


    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid5}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid6}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_3}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid7}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_4}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid8}  ${wid[0]}

    ${waiting_time}=  Evaluate  ((${s_dur1}+${s_dur2}+${s_dur3}+${s_dur4})/4)/2
    ${wait_time}=  Convert To Integer  ${waiting_time}
    ${waiting_time1}=  Evaluate  ${wait_time}+${waiting_time}
    ${wait_time1}=  Convert To Integer  ${waiting_time1}
    ${waiting_time2}=  Evaluate  ${wait_time1}+${waiting_time}
    ${wait_time2}=  Convert To Integer  ${waiting_time2}
    ${waiting_time3}=  Evaluate  ${wait_time2}+${waiting_time}
    ${wait_time3}=  Convert To Integer  ${waiting_time3}
    ${waiting_time4}=  Evaluate  ${wait_time3}+${waiting_time}
    ${wait_time4}=  Convert To Integer  ${waiting_time4}
    ${waiting_time5}=  Evaluate  ${wait_time4}+${waiting_time}
    ${wait_time5}=  Convert To Integer  ${waiting_time5}
    
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time}
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   ${wait_time1}  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   ${wait_time2} 
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   ${wait_time3}
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   ${wait_time4}
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}   ${wait_time5}

    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid1}       
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  01s
    
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   ${wait_time} 
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   ${wait_time1} 
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   ${wait_time2}  
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   ${wait_time3} 
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}   ${wait_time4}      
           
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  01s

    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}  0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}  0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}  0
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}  0 
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}  ${wait_time}
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}  ${wait_time1}  
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}  ${wait_time2} 
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}  ${wait_time3}    
   
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid3}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  01s
    
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   ${wait_time}
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   ${wait_time1}
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}   ${wait_time2}    
    
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid4}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  01s
    
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   ${wait_time}
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}   ${wait_time1} 
    
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid5}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  01s

    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}   ${wait_time}
   
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid6}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  01s
    
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}   0   
   
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid7}   
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  01s 
    
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}   0

    ${resp}=  Get Queue ById  ${qi_d1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=${wait_time}  queueWaitingTime=0

    
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid8}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  01s
    
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}   0

    ${resp}=  Get Queue ById  ${qi_d1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=${wait_time}  queueWaitingTime=0

JD-TC-Approximate Waiting Time Conventional-3
    [Documentation]  delay add to the conventional waiting time calculation   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_service   ${PUSERNAME_Z}
    clear_location  ${PUSERNAME_Z}
    clear_queue  ${PUSERNAME_Z}
    clear_customer   ${PUSERNAME_Z}
    ${resp}=  Update Waitlist Settings  ${calc_mode[3]}  0  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    
     
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
    ${24hours}    Random Element    ['True','False']
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${sTime1}=  db.subtract_timezone_time  ${tz}  2  00
    ${eTime1}=  add_timezone_time  ${tz}  3  30 
    ${sTime}=  add_timezone_time  ${tz}  5  15  
    ${eTime}=  add_timezone_time  ${tz}  6  30  
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid1}  ${resp.json()}

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur1}=  Random Int  min=2  max=10
    ${SERVICE1}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${s_dur1}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_1}  ${resp.json()} 

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur2}=  Random Int  min=11  max=20
    ${SERVICE2}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${s_dur2}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_2}  ${resp.json()} 

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur3}=  Random Int  min=21  max=30
    ${SERVICE3}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE3}  ${desc}   ${s_dur3}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_3}  ${resp.json()} 

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur4}=  Random Int  min=31  max=34
    ${SERVICE4}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE4}  ${desc}   ${s_dur4}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_4}  ${resp.json()} 

    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel[1]}  ${capacity}  ${lid1}  ${sId_1}  ${sId_2}  ${sId_3}  ${sId_4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qi_d1}  ${resp.json()}
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}

    ${waiting_time}=  Evaluate  ((${s_dur1}+${s_dur2}+${s_dur3}+${s_dur4})/4)/2
    ${wait_time}=  Convert To Integer  ${waiting_time}
    ${waiting_time1}=  Evaluate  ${wait_time}+${waiting_time}
    ${wait_time1}=  Convert To Integer  ${waiting_time1}
    ${waiting_time2}=  Evaluate  ${wait_time1}+${waiting_time}
    ${wait_time2}=  Convert To Integer  ${waiting_time2}
   
    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_3}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_4}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}    
    Set Test Variable  ${wid4}  ${wid[0]}     
   
    ${resp}=  Get Queue ById  ${qi_d1}
    Verify Response  ${resp}  turnAroundTime=${wait_time}  queueWaitingTime=${wait_time2}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0 
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0 
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${wait_time}
    ${resp}=  Get Waitlist By Id  ${wid4} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${wait_time1}

    ${delay_time}=   Random Int  min=10   max=40
    ${resp}=  Add Delay  ${qi_d1}  ${delay_time}  ${None}  true
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Delay  ${qi_d1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  delayDuration=${delay_time}
    sleep  02s
    
    ${delay_wait_time}=  Evaluate  ${delay_time}+${wait_time}
    ${delay_wait_time1}=  Evaluate  ${delay_time}+${wait_time1}
    ${delay_wait_time2}=  Evaluate  ${delay_time}+${wait_time2}

    ${resp}=  Get Queue ById  ${qi_d1}
    Log  ${resp.json()}
    Verify Response  ${resp}  turnAroundTime=${wait_time}  queueWaitingTime=${delay_wait_time2}  delay=${delay_time}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${delay_time}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${delay_time} 
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${delay_wait_time}
    ${resp}=  Get Waitlist By Id  ${wid4} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${delay_wait_time1}

    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  01s

    ${resp}=  Get Queue ById  ${qi_d1}
    Verify Response  ${resp}  turnAroundTime=${wait_time}  queueWaitingTime=${delay_wait_time1}  delay=${delay_time}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${delay_time} 
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${delay_time}
    ${resp}=  Get Waitlist By Id  ${wid4} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${delay_wait_time}
   
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  01s

    ${resp}=  Get Queue ById  ${qi_d1}
    Verify Response  ${resp}  turnAroundTime=${wait_time}  queueWaitingTime=${delay_wait_time}  delay=${delay_time}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${delay_time}
    ${resp}=  Get Waitlist By Id  ${wid4} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${delay_time}

    ${resp}=  Add Delay  ${qi_d1}  0  ${None}  true
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Delay  ${qi_d1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  delayDuration=0
    sleep  01s

    ${resp}=  Get Queue ById  ${qi_d1}
    Verify Response  ${resp}  turnAroundTime=${wait_time}  queueWaitingTime=${wait_time}  delay=0
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${delay_time}
    ${resp}=  Get Waitlist By Id  ${wid4} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${delay_time}
    
JD-TC-Approximate Waiting Time Conventional-4
    [Documentation]   Check queue waiting time when token1 is started after token3
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_service   ${PUSERNAME_Z}
    clear_location  ${PUSERNAME_Z}
    clear_queue  ${PUSERNAME_Z}
    # clear_customer   ${PUSERNAME_Z}

    ${resp}=  Update Waitlist Settings  ${calc_mode[3]}  0  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${sTime1}=  db.subtract_timezone_time  ${tz}  2  00
    ${eTime1}=  add_timezone_time  ${tz}  3  30  
    ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
    ${24hours}    Random Element    ['True','False']
    ${sTime}=  add_timezone_time  ${tz}  5  15  
    ${eTime}=  add_timezone_time  ${tz}  6  30  
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid1}  ${resp.json()}

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur1}=  Random Int  min=2  max=10
    ${SERVICE1}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${s_dur1}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_1}  ${resp.json()} 

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur2}=  Random Int  min=11  max=20
    ${SERVICE2}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${s_dur2}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_2}  ${resp.json()} 

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur3}=  Random Int  min=21  max=30
    ${SERVICE3}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE3}  ${desc}   ${s_dur3}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_3}  ${resp.json()} 

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur4}=  Random Int  min=31  max=34
    ${SERVICE4}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE4}  ${desc}   ${s_dur4}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_4}  ${resp.json()} 

    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel[1]}  ${capacity}  ${lid1}  ${sId_1}  ${sId_2}  ${sId_3}  ${sId_4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qi_d1}  ${resp.json()}
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid}=  get_acc_id  ${PUSERNAME_Z}

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME5}    
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qi_d1}  ${DAY}  ${sId_1}  ${desc}  ${bool[0]}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qi_d1}  ${DAY}  ${sId_2}  ${desc}  ${bool[0]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid2}  ${wid[0]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${cid}=  get_id  ${CUSERNAME1}    
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qi_d1}  ${DAY}  ${sId_1}  ${desc}  ${bool[0]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid3}  ${wid[0]}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qi_d1}  ${DAY}  ${sId_2}  ${desc}  ${bool[0]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid4}  ${wid[0]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${cid}=  get_id  ${CUSERNAME2}    
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qi_d1}  ${DAY}  ${sId_1}  ${desc}  ${bool[0]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid5}  ${wid[0]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}  200

    # ${wait_time}=  Evaluate  ((${s_dur1}+${s_dur2}+${s_dur3}+${s_dur4})/4)/2
    # ${wait_time1}=  Evaluate  ${wait_time}+${wait_time}
    # ${wait_time2}=  Evaluate  ${wait_time1}+${wait_time}
    # ${wait_time3}=  Evaluate  ${wait_time2}+${wait_time}
    ${waiting_time}=  Evaluate  ((${s_dur1}+${s_dur2}+${s_dur3}+${s_dur4})/4)/2
    ${wait_time}=  Convert To Integer  ${waiting_time}
    ${waiting_time1}=  Evaluate  ${wait_time}+${waiting_time}
    ${wait_time1}=  Convert To Integer  ${waiting_time1}
    ${waiting_time2}=  Evaluate  ${wait_time1}+${waiting_time}
    ${wait_time2}=  Convert To Integer  ${waiting_time2}
    ${waiting_time3}=  Evaluate  ${wait_time2}+${waiting_time}
    ${wait_time3}=  Convert To Integer  ${waiting_time3}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Queue ById  ${qi_d1}
    Verify Response  ${resp}  turnAroundTime=${wait_time}  queueWaitingTime=${wait_time3}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0 
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0 
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${wait_time}
    ${resp}=  Get Waitlist By Id  ${wid4} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${wait_time1}
    ${resp}=  Get Waitlist By Id  ${wid5} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${wait_time2}


    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  01s
    ${resp}=  Get Queue ById  ${qi_d1}
    Verify Response  ${resp}  turnAroundTime=${wait_time}  queueWaitingTime=${wait_time2}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0 
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0 
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[2]}
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0
    ${resp}=  Get Waitlist By Id  ${wid4} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${wait_time}
    ${resp}=  Get Waitlist By Id  ${wid5} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${wait_time1}    
    
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  01s
    ${resp}=  Get Queue ById  ${qi_d1}
    Verify Response  ${resp}  turnAroundTime=${wait_time}  queueWaitingTime=${wait_time1}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0 
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0 
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[2]}
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0
    ${resp}=  Get Waitlist By Id  ${wid4} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0
    ${resp}=  Get Waitlist By Id  ${wid5} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${wait_time}    
    
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  01s
    ${resp}=  Get Queue ById  ${qi_d1}
    Verify Response  ${resp}  turnAroundTime=${wait_time}  queueWaitingTime=${wait_time}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0 
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0 
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[2]}
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0
    ${resp}=  Get Waitlist By Id  ${wid4} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0
    ${resp}=  Get Waitlist By Id  ${wid5} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0

    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid4}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  01s
    ${resp}=  Get Queue ById  ${qi_d1}
    Verify Response  ${resp}  turnAroundTime=${wait_time}  queueWaitingTime=0
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0 
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0 
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[2]}
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0
    ${resp}=  Get Waitlist By Id  ${wid4} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0
    ${resp}=  Get Waitlist By Id  ${wid5} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0


    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid5}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  01s

    ${resp}=  Get Queue ById  ${qi_d1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=${wait_time}  queueWaitingTime=0  

JD-TC-Approximate Waiting Time Conventional-5
    [Documentation]   Check queue waiting time after disable service
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_service   ${PUSERNAME_Z}
    clear_location  ${PUSERNAME_Z}
    clear_queue  ${PUSERNAME_Z}
    clear_customer   ${PUSERNAME_Z}
    ${resp}=  Update Waitlist Settings  ${calc_mode[3]}  0  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    
     
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${sTime1}=  db.subtract_timezone_time  ${tz}  2  00
    ${eTime1}=  add_timezone_time  ${tz}  3  30 
    ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
    ${24hours}    Random Element    ['True','False']
    ${sTime}=  add_timezone_time  ${tz}  5  15  
    ${eTime}=  add_timezone_time  ${tz}  6  30  
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid1}  ${resp.json()}

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur1}=  Random Int  min=2  max=10
    ${SERVICE1}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${s_dur1}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_1}  ${resp.json()} 

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur2}=  Random Int  min=11  max=20
    ${SERVICE2}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${s_dur2}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_2}  ${resp.json()} 

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur3}=  Random Int  min=21  max=30
    ${SERVICE3}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE3}  ${desc}   ${s_dur3}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_3}  ${resp.json()} 

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur4}=  Random Int  min=31  max=34
    ${SERVICE4}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE4}  ${desc}   ${s_dur4}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_4}  ${resp.json()} 

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur5}=  Random Int  min=31  max=34
    ${SERVICE5}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE5}  ${desc}   ${s_dur5}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_5}  ${resp.json()} 

    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel[0]}  ${capacity}  ${lid1}  ${sId_1}  ${sId_2}  ${sId_3}  ${sId_4}  ${sId_5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qi_d1}  ${resp.json()}
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_3}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_4}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid4}  ${wid[0]}    

    # ${wait_time}=  Evaluate  ((${s_dur1}+${s_dur2}+${s_dur3}+${s_dur4}+${s_dur5})/5)/1
    # ${wait_time1}=  Evaluate  ${wait_time}+${wait_time}
    # ${wait_time2}=  Evaluate  ${wait_time1}+${wait_time}
    # ${wait_time3}=  Evaluate  ${wait_time2}+${wait_time}
    ${waiting_time}=  Evaluate  ((${s_dur1}+${s_dur2}+${s_dur3}+${s_dur4}+${s_dur5})/5)/1
    ${wait_time}=  Convert To Integer  ${waiting_time}
    ${waiting_time1}=  Evaluate  ${wait_time}+${waiting_time}
    ${wait_time1}=  Convert To Integer  ${waiting_time1}
    ${waiting_time2}=  Evaluate  ${wait_time1}+${waiting_time}
    ${wait_time2}=  Convert To Integer  ${waiting_time2}
    ${waiting_time3}=  Evaluate  ${wait_time2}+${waiting_time}
    ${wait_time3}=  Convert To Integer  ${waiting_time3}


    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time}  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time1}
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   ${wait_time2} 
    ${resp}=  Get Queue ById  ${qi_d1}
    Log  ${resp.json()}
    Verify Response  ${resp}  turnAroundTime=${wait_time}  queueWaitingTime=${wait_time3}

    ${resp}=  Disable service  ${sId_5} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Service By Id  ${sId_5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   status=${status[1]}
    sleep  03s

    ${waiting_time_new}=  Evaluate  ((${s_dur1}+${s_dur2}+${s_dur3}+${s_dur4})/4)/1
    ${wait_time_new}=  Convert To Integer  ${waiting_time_new}
    ${waiting_time1_new}=  Evaluate  ${wait_time_new}+${wait_time_new}
    ${wait_time1_new}=  Convert To Integer  ${waiting_time1_new}
    ${waiting_time2_new}=  Evaluate  ${wait_time1_new}+${wait_time_new}
    ${wait_time2_new}=  Convert To Integer  ${waiting_time2_new}
    ${waiting_time3_new}=  Evaluate  ${wait_time2_new}+${wait_time_new}
    ${wait_time3_new}=  Convert To Integer  ${waiting_time3_new}
   
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time_new}  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time1_new}
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   ${wait_time2_new} 
    ${resp}=  Get Queue ById  ${qi_d1}
    Log  ${resp.json()}
    Verify Response  ${resp}  turnAroundTime=${wait_time_new}  queueWaitingTime=${wait_time3_new}

JD-TC-Approximate Waiting Time Conventional-6
	[Documentation]  Checking appxWaitingTime in different situations when calculation mode as Conventional
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${PUSERNAME_Z}
    clear_location  ${PUSERNAME_Z}
    clear_queue  ${PUSERNAME_Z}
    clear_customer   ${PUSERNAME_Z}
    ${resp}=  Update Waitlist Settings  ${calc_mode[3]}  0  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    
    
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${sTime1}=  db.subtract_timezone_time  ${tz}  2  00
    ${eTime1}=  add_timezone_time  ${tz}  3  30  
    ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
    ${24hours}    Random Element    ['True','False']
    ${sTime}=  add_timezone_time  ${tz}  5  15  
    ${eTime}=  add_timezone_time  ${tz}  6  30  
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid1}  ${resp.json()}

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur1}=  Random Int  min=2  max=10
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${s_dur1}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_1}  ${resp.json()} 

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur2}=  Random Int  min=11  max=20
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${s_dur2}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_2}  ${resp.json()} 

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur3}=  Random Int  min=21  max=30
    ${resp}=  Create Service  ${SERVICE3}  ${desc}   ${s_dur3}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_3}  ${resp.json()} 

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur4}=  Random Int  min=31  max=34
    ${resp}=  Create Service  ${SERVICE4}  ${desc}   ${s_dur4}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_4}  ${resp.json()} 

    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel[0]}  ${capacity}  ${lid1}  ${sId_1}  ${sId_2}  ${sId_3}  ${sId_4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qi_d1}  ${resp.json()}
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_3}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_4}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid4}  ${wid[0]}    
    
    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid5}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid6}  ${wid[0]}

    # ${wait_time}=  Evaluate  ((${s_dur1}+${s_dur2}+${s_dur3}+${s_dur4})/4)/1
    # ${wait_time1}=  Evaluate  ${wait_time}+${wait_time}
    # ${wait_time2}=  Evaluate  ${wait_time1}+${wait_time}
    # ${wait_time3}=  Evaluate  ${wait_time2}+${wait_time}
    # ${wait_time4}=  Evaluate  ${wait_time3}+${wait_time}
    # ${wait_time5}=  Evaluate  ${wait_time4}+${wait_time}
    # ${wait_time6}=  Evaluate  ${wait_time5}+${wait_time}
    ${waiting_time}=  Evaluate  ((${s_dur1}+${s_dur2}+${s_dur3}+${s_dur4})/4)/1
    ${wait_time}=  Convert To Integer  ${waiting_time}
    ${waiting_time1}=  Evaluate  ${wait_time}+${waiting_time}
    ${wait_time1}=  Convert To Integer  ${waiting_time1}
    ${waiting_time2}=  Evaluate  ${wait_time1}+${waiting_time}
    ${wait_time2}=  Convert To Integer  ${waiting_time2}
    ${waiting_time3}=  Evaluate  ${wait_time2}+${waiting_time}
    ${wait_time3}=  Convert To Integer  ${waiting_time3}
    ${waiting_time4}=  Evaluate  ${wait_time3}+${waiting_time}
    ${wait_time4}=  Convert To Integer  ${waiting_time4}
    ${waiting_time5}=  Evaluate  ${wait_time4}+${waiting_time}
    ${wait_time5}=  Convert To Integer  ${waiting_time5}
    ${waiting_time6}=  Evaluate  ${wait_time5}+${waiting_time}
    ${wait_time6}=  Convert To Integer  ${waiting_time6}

    
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time}  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time1}
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   ${wait_time2} 
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   ${wait_time3}
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   ${wait_time4}

    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid1}       
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  01s
  
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time}
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   ${wait_time1}  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   ${wait_time2} 
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   ${wait_time3}  
          
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  01s

    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}  0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}  0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}  0
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}  ${wait_time} 
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}  ${wait_time1} 
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}  ${wait_time2}  
    
    Comment  cancel 3rd and 4th waitlist
    ${desc}=    FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${wid3}  ${waitlist_cancl_reasn[0]}  ${desc}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Waitlist Action Cancel  ${wid4}  ${waitlist_cancl_reasn[0]}  ${desc}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  01s
    
    ${resp}=  Get Waitlist Today  queue-eq=${qi_d1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0  waitlistStatus=${wl_status[4]}
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0  waitlistStatus=${wl_status[4]}
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=${wait_time}
       
    Comment  Start 5th waitlist
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid5}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  01s
        
    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qi_d1}  ${DAY}  hi  ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid7}  ${wid[0]}
   
    ${resp}=  Get Waitlist Today  queue-eq=${qi_d1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  waitlistStatus=${wl_status[4]}
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  waitlistStatus=${wl_status[4]}
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=0
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=${wait_time}

    Comment  cancelled waitlist back to queue
    ${resp}=  Waitlist Action  ${waitlist_actions[3]}  ${wid3}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${resp}=  Waitlist Action  ${waitlist_actions[3]}  ${wid4}
    Should Be Equal As Strings  ${resp.status_code}  200   
    
    ${resp}=  Get Waitlist Today  queue-eq=${qi_d1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0  waitlistStatus=${wl_status[0]}
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=${wait_time}  waitlistStatus=${wl_status[0]}
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=${wait_time1}
    Verify Response List  ${resp}  6  ynwUuid=${wid7}  appxWaitingTime=${wait_time2}
      

*** comment ***

JD-TC-Approximate Waiting Time Conventional-5
    [Documentation]   Check queue waiting time when batch mode enabled
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_service   ${PUSERNAME_Z}
    clear_location  ${PUSERNAME_Z}
    clear_queue  ${PUSERNAME_Z}
    ${resp}=  Update Waitlist Settings  ${calc_mode[3]}  0  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    
      
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${sTime1}=  db.subtract_timezone_time  ${tz}  2  00
    ${eTime1}=  add_timezone_time  ${tz}  3  30
    ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
    ${24hours}    Random Element    ['True','False']
    ${sTime}=  add_timezone_time  ${tz}  5  15  
    ${eTime}=  add_timezone_time  ${tz}  6  30  
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid1}  ${resp.json()}

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur1}=  Random Int  min=2  max=10
    ${SERVICE1}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${s_dur1}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_1}  ${resp.json()} 

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur2}=  Random Int  min=11  max=20
    ${SERVICE2}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${s_dur2}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_2}  ${resp.json()} 

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur3}=  Random Int  min=21  max=30
    ${SERVICE3}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE3}  ${desc}   ${s_dur3}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_3}  ${resp.json()} 

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur4}=  Random Int  min=31  max=34
    ${SERVICE4}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE4}  ${desc}   ${s_dur4}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${sId_4}  ${resp.json()} 

    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel[2]}  ${capacity}  ${lid1}  ${sId_1}  ${sId_2}  ${sId_3}  ${sId_4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qi_d1}  ${resp.json()}
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}

    ${resp}=  Enable Waitlist Batch   ${qi_d1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Queue ById  ${qi_d1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel[2]}
    Should Be Equal As Strings  ${resp.json()['batch']}    ${bool[1]}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_3}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_4}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid4}  ${wid[0]}    
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid5}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid6}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_3}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid7}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_4}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid8}  ${wid[0]}

    ${wait_time}=  Evaluate  (${s_dur1}+${s_dur2}+${s_dur3}+${s_dur4})/4
    ${wait_time1}=  Evaluate  ${wait_time}+${wait_time} 
    ${wait_time2}=  Evaluate  ${wait_time}+${wait_time}+${wait_time}+${wait_time}+${wait_time1}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0 
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0 
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0
    ${resp}=  Get Waitlist By Id  ${wid4} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${wait_time}
    ${resp}=  Get Waitlist By Id  ${wid5} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${wait_time}
    ${resp}=  Get Waitlist By Id  ${wid6} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${wait_time}
    ${resp}=  Get Waitlist By Id  ${wid7} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${wait_time1}
    ${resp}=  Get Waitlist By Id  ${wid8} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${wait_time1}

    ${resp}=  Get Queue ById  ${qi_d1}
    Log  ${resp.json()}
    Verify Response  ${resp}  turnAroundTime=${wait_time}  queueWaitingTime=${wait_time2}

    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  03s
    ${wait_time2}=  Evaluate  ${wait_time2}/2 
    ${resp}=  Get Queue ById  ${qi_d1}
    Log  ${resp.json()}
    Verify Response  ${resp}  turnAroundTime=${wait_time}  queueWaitingTime=${wait_time2}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0 
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0 
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0
    ${resp}=  Get Waitlist By Id  ${wid4} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0
    ${resp}=  Get Waitlist By Id  ${wid5} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0
    ${resp}=  Get Waitlist By Id  ${wid6} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0
    ${resp}=  Get Waitlist By Id  ${wid7} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${wait_time}
    ${resp}=  Get Waitlist By Id  ${wid8} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${wait_time}

    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid4}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid5}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid6}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  03s

    ${resp}=  Get Queue ById  ${qi_d1}
    Log  ${resp.json()}
    Verify Response  ${resp}  turnAroundTime=${wait_time}  queueWaitingTime=0
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0 
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0 
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0
    ${resp}=  Get Waitlist By Id  ${wid4} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0
    ${resp}=  Get Waitlist By Id  ${wid5} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0
    ${resp}=  Get Waitlist By Id  ${wid6} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0
    ${resp}=  Get Waitlist By Id  ${wid7} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0
    ${resp}=  Get Waitlist By Id  ${wid8} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid9}  ${wid[0]}

    ${resp}=  Get Queue ById  ${qi_d1}
    Log  ${resp.json()}
    Verify Response  ${resp}  turnAroundTime=${wait_time}  queueWaitingTime=${wait_time}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid10}  ${wid[0]}
    ${resp}=  Get Queue ById  ${qi_d1}
    Log  ${resp.json()}
    Verify Response  ${resp}  turnAroundTime=${wait_time}  queueWaitingTime=${wait_time}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_3}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid11}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_4}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid12}  ${wid[0]}

    ${resp}=  Get Queue ById  ${qi_d1}
    Log  ${resp.json()}
    Verify Response  ${resp}  turnAroundTime=${wait_time}  queueWaitingTime=${wait_time}
    ${resp}=  Get Waitlist By Id  ${wid10} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0 
    ${resp}=  Get Waitlist By Id  ${wid11} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${wait_time}
    ${resp}=  Get Waitlist By Id  ${wid12} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${wait_time}
