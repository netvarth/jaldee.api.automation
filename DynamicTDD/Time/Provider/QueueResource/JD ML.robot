*** Settings ***
Suite Teardown    Run Keywords  Delete All Sessions  resetsystem_time
Test Teardown     Delete All Sessions
Force Tags        ML
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
${SERVICE1}	   Qwait3
${SERVICE2}	   Qwait4
${SERVICE3}	   Qwait5
${SERVICE4}	   Qwait6
${SERVICE5}	   Qwait7
${SERVICE6}	   Qwait8

*** Test Cases ***

JD-TC-ML Test Case-1
    
    [Documentation]  Verification of Get Approximate Waiting Time When calculation mode as ML ,add 8  waitlist and  Start one by one 
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME135}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
*** comment ***   
    clear_service   ${PUSERNAME135}
    clear_location  ${PUSERNAME135}
    clear_queue  ${PUSERNAME135}
    clear_customer  ${PUSERNAME135}
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  0  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  
    ${sTime1}=  subtract_timezone_time  ${tz}  1  00
    Set Suite Variable   ${sTime1}
    # ${eTime1}=  add_timezone_time  ${tz}   5  30
    ${eTime1}=  add_timezone_time  ${tz}  5  30  
    Set Suite Variable   ${eTime1}
    # ${city}=   get_place
    # Set Suite Variable  ${city}
    # ${latti}=  get_latitude
    # Set Suite Variable  ${latti}
    # ${longi}=  get_longitude
    # Set Suite Variable  ${longi}
    # ${postcode}=  FakerLibrary.postcode
    # Set Suite Variable  ${postcode}
    # ${address}=  get_address
    # Set Suite Variable  ${address}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    Set Suite Variable  ${city}
    Set Suite Variable  ${latti}
    Set Suite Variable  ${longi}
    Set Suite Variable  ${postcode}
    Set Suite Variable  ${address}
    ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
    Set Suite Variable  ${parking_type}
    ${24hours}    Random Element    ['True','False']
    Set Suite Variable  ${24hours}
    ${sTime}=  add_timezone_time  ${tz}  6  15
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}   7  30
    Set Suite Variable   ${eTime}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()}
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${sId_1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${sId_1}
    ${sId_2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${sId_2}
    ${sId_3}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable  ${sId_3}
    ${sId_4}=  Create Sample Service  ${SERVICE4}
    Set Suite Variable  ${sId_4}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  25  ${lid}  ${sId_1}  ${sId_2}  ${sId_3}  ${sId_4}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q1_l1}  ${resp.json()}
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    # ${cid}=  get_id  ${CUSERNAME7}

    ${resp}=  AddCustomer  ${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${q1_l1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${q1_l1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid2}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_3}  ${q1_l1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid3}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_4}  ${q1_l1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid4}  ${wid[0]}    
    # ${cid}=  get_id  ${CUSERNAME1}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${q1_l1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid5}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${q1_l1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid6}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_3}  ${q1_l1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid7}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_4}  ${q1_l1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid8}  ${wid[0]}
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid1}       
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  02s
    ${resp}=  Get Waitlist Today   queue-eq=${q1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   2
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   4  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   6
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   8
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   10
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}   12      
    ${resp}=  Get Queue ById  ${q1_l1}
    Verify Response  ${resp}  turnAroundTime=2  queueWaitingTime=14
    ${resp}=  Waitlist Action   ${waitlist_actions[4]}  ${wid1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    change_system_time  0  5        
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s 
    ${resp}=  Get Waitlist Today   queue-eq=${q1_l1}
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}  0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}  0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}  0
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}  5 
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}  10 
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}  15  
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}  20 
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}  25     
    ${resp}=  Get Queue ById  ${q1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200       
    Verify Response  ${resp}  turnAroundTime=5  queueWaitingTime=30  

    change_system_time  0  10
    ${resp}=  Waitlist Action   ${waitlist_actions[4]}  ${wid2}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid3}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  02s
    ${resp}=  Get Waitlist Today   queue-eq=${q1_l1}
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   8
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   16
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   24
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}   32
    ${resp}=  Get Queue ById  ${q1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=8  queueWaitingTime=40	

    change_system_time  0  15
    ${resp}=  Waitlist Action   ${waitlist_actions[4]}  ${wid3}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid4}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  02s
    ${resp}=  Get Waitlist Today   queue-eq=${q1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   10
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   20
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}   30 
    ${resp}=  Get Queue ById  ${q1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Verify Response  ${resp}  turnAroundTime=10  queueWaitingTime=40

    change_system_time  0  10
    ${resp}=  Waitlist Action   ${waitlist_actions[4]}  ${wid4}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid5}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  02s
    ${resp}=  Get Waitlist Today   queue-eq=${q1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   10
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}   20
    ${resp}=  Get Queue ById  ${q1_l1}  
    Should Be Equal As Strings  ${resp.status_code}  200  
    Verify Response  ${resp}  turnAroundTime=10  queueWaitingTime=30

    change_system_time  0  5
    ${resp}=  Waitlist Action   ${waitlist_actions[4]}  ${wid5}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid6}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  02s
    ${resp}=  Get Waitlist Today   queue-eq=${q1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}   9 
    ${resp}=  Get Queue ById  ${q1_l1}  
    Should Be Equal As Strings  ${resp.status_code}  200  
    Verify Response  ${resp}  turnAroundTime=9  queueWaitingTime=18

    change_system_time  0  10
    ${resp}=  Waitlist Action   ${waitlist_actions[4]}  ${wid6}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid7}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  02s
    ${resp}=  Get Waitlist Today   queue-eq=${q1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}   0
    ${resp}=  Get Queue ById  ${q1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Verify Response  ${resp}  turnAroundTime=9  queueWaitingTime=9

    change_system_time  0  5
    ${resp}=  Waitlist Action   ${waitlist_actions[4]}  ${wid7}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid8}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  02s
    ${resp}=  Get Queue ById  ${q1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Verify Response  ${resp}  turnAroundTime=9  queueWaitingTime=0
    ${resp}=  Waitlist Action   ${waitlist_actions[4]}  ${wid8}  
    Should Be Equal As Strings  ${resp.status_code}  200
    resetsystem_time

JD-TC-ML Test Case-2
    [Documentation]  check ideal time is taken for ML calculation when queue is empty   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME135}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    # ${cid}=  get_id  ${CUSERNAME6}

    ${resp}=  AddCustomer  ${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${q1_l1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${q1_l1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid2}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_3}  ${q1_l1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid3}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_4}  ${q1_l1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}    
    Set Suite Variable  ${wid4}  ${wid[0]}     
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid1}       
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s 
    ${resp}=  Get Queue ById  ${q1_l1}
    Verify Response  ${resp}  turnAroundTime=9  queueWaitingTime=27
    change_system_time  0  20  
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  02s
    ${resp}=  Get Queue ById  ${q1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=10  queueWaitingTime=20   
    change_system_time  0  10
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid3}   
    Should Be Equal As Strings  ${resp.status_code}  200  
    sleep  02s  
    ${resp}=  Get Queue ById  ${q1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=10  queueWaitingTime=10 
    change_system_time  0  15
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid4}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  02s
    ${resp}=  Get Queue ById  ${q1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Verify Response  ${resp}  turnAroundTime=11  queueWaitingTime=0  
    ${resp}=  Waitlist Action   ${waitlist_actions[4]}  ${wid1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action   ${waitlist_actions[4]}  ${wid2}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action   ${waitlist_actions[4]}  ${wid3}  
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Waitlist Action   ${waitlist_actions[4]}  ${wid4}  
    Should Be Equal As Strings  ${resp.status_code}  200
    resetsystem_time

JD-TC-ML Test Case-3
    [Documentation]  check ideal time is taken for ML calculation when queue is not empty   
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME135}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    # ${cid}=  get_id  ${CUSERNAME7}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${q1_l1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${q1_l1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid2}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_3}  ${q1_l1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid3}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_4}  ${q1_l1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}    
    Set Suite Variable  ${wid4}  ${wid[0]}     
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid1}       
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s 
    ${resp}=  Get Queue ById  ${q1_l1}
    Verify Response  ${resp}  turnAroundTime=11  queueWaitingTime=33
    change_system_time  2  0 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME135}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    # ${cid}=  get_id  ${CUSERNAME5} 

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  02s
    ${resp}=  Get Queue ById  ${q1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Verify Response  ${resp}  turnAroundTime=20  queueWaitingTime=42  
    change_system_time  0  10
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid3}   
    Should Be Equal As Strings  ${resp.status_code}  200  
    sleep  02s  
    ${resp}=  Get Queue ById  ${q1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Verify Response  ${resp}  turnAroundTime=20  queueWaitingTime=20
    change_system_time  0  15
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid4}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  02s
    ${resp}=  Get Queue ById  ${q1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200       
    Verify Response  ${resp}  turnAroundTime=19  queueWaitingTime=0  
    ${resp}=  Waitlist Action   ${waitlist_actions[4]}  ${wid1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action   ${waitlist_actions[4]}  ${wid2}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action   ${waitlist_actions[4]}  ${wid3}  
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Waitlist Action   ${waitlist_actions[4]}  ${wid4}  
    Should Be Equal As Strings  ${resp.status_code}  200  

    resetsystem_time  
JD-TC-ML Test Case-4
    [Documentation]  delay add to the ML waiting time calculation   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME12}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_service   ${PUSERNAME12}
    clear_location  ${PUSERNAME12}
    clear_queue  ${PUSERNAME12}
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  0  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}  ${DAY}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${sTime1}=  subtract_timezone_time  ${tz}  1  00
    Set Suite Variable   ${sTime1}
    # ${eTime1}=  add_timezone_time  ${tz}   5  30
    ${eTime1}=  add_timezone_time  ${tz}  5  30  
    Set Suite Variable   ${eTime1}
    # ${city}=   get_place
    # Set Suite Variable  ${city}
    # ${latti}=  get_latitude
    # Set Suite Variable  ${latti}
    # ${longi}=  get_longitude
    # Set Suite Variable  ${longi}
    # ${postcode}=  FakerLibrary.postcode
    # Set Suite Variable  ${postcode}
    # ${address}=  get_address
    # Set Suite Variable  ${address}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    Set Suite Variable  ${city}
    Set Suite Variable  ${latti}
    Set Suite Variable  ${longi}
    Set Suite Variable  ${postcode}
    Set Suite Variable  ${address}
    ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
    Set Suite Variable  ${parking_type}
    ${24hours}    Random Element    ['True','False']
    Set Suite Variable  ${24hours}
    ${sTime}=  add_timezone_time  ${tz}  6  15
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}   7  30
    Set Suite Variable   ${eTime}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()}
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${sId_1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${sId_1}
    ${sId_2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${sId_2}
    ${sId_3}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable  ${sId_3}
    ${sId_4}=  Create Sample Service  ${SERVICE4}
    Set Suite Variable  ${sId_4}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  15  ${lid}  ${sId_1}  ${sId_2}  ${sId_3}  ${sId_4}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q1_l1}  ${resp.json()}
    # ${cid}=  get_id  ${CUSERNAME4}

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${q1_l1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${q1_l1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid2}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_3}  ${q1_l1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid3}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_4}  ${q1_l1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}    
    Set Suite Variable  ${wid4}  ${wid[0]}     
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid1}       
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s 
    ${resp}=  Get Queue ById  ${q1_l1}
    Verify Response  ${resp}  turnAroundTime=2  queueWaitingTime=6
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0 
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   2
    ${resp}=  Get Waitlist By Id  ${wid4} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   4

    ${delay_time}=   Random Int  min=10   max=40
    ${resp}=  Add Delay  ${q1_l1}  ${delay_time}  ${None}  true
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Delay  ${q1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  delayDuration=${delay_time}
    sleep  02s
    ${wait_time}=  Evaluate  ${delay_time}*2
    ${wait_time1}=  Evaluate  ${delay_time}*4
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${delay_time} 
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${wait_time}
    ${resp}=  Get Waitlist By Id  ${wid4} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   ${wait_time1}
    change_system_time  0  ${delay_time} 
    sleep  02s 
    ${resp}=  Get Delay  ${q1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  delayDuration=0
    ${resp}=  Get Waitlist By Id  ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   0 
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   2
    ${resp}=  Get Waitlist By Id  ${wid4} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appxWaitingTime']}   4
    ${resp}=  Get Queue ById  ${q1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=2  queueWaitingTime=6
    change_system_time  0  10
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  02s
    ${turn_around_time}=  Evaluate  ${delay_time}+10
    ${queue_wait_time}=  Evaluate  ${turn_around_time}*2
    ${resp}=  Get Queue ById  ${q1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=${turn_around_time}  queueWaitingTime=${queue_wait_time}
    change_system_time  0  10
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid3}   
    Should Be Equal As Strings  ${resp.status_code}  200  
    sleep  02s  
    ${turn_around_time}=  Evaluate  ${turn_around_time}+10  
    ${turn_around_time}=  Evaluate  ${turn_around_time}/2     
    ${resp}=  Get Queue ById  ${q1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=${turn_around_time}  queueWaitingTime=${turn_around_time}
    change_system_time  0  15
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid4}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  02s
    ${turn_around_time}=  Evaluate  ${turn_around_time}+15
    ${turn_around_time}=  Evaluate  ${turn_around_time}/3  
    ${resp}=  Get Queue ById  ${q1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Verify Response  ${resp}  turnAroundTime=${turn_around_time}  queueWaitingTime=0  
    ${resp}=  Waitlist Action   ${waitlist_actions[4]}  ${wid1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action   ${waitlist_actions[4]}  ${wid2}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action   ${waitlist_actions[4]}  ${wid3}  
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Waitlist Action   ${waitlist_actions[4]}  ${wid4}  
    Should Be Equal As Strings  ${resp.status_code}  200        
    resetsystem_time

JD-TC-ML Test Case-5
    [Documentation]   Check queue waiting time when queue has no persons in waitlist status arrived
    ${resp}=  Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_service   ${PUSERNAME13}
    clear_location  ${PUSERNAME13}
    clear_queue  ${PUSERNAME13}
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  0  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}  ${DAY}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${sTime1}=  subtract_timezone_time  ${tz}  1  00
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${sId_1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${sId_1}
    ${sId_2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${sId_2}
    ${sId_3}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable  ${sId_3}
    ${sId_4}=  Create Sample Service  ${SERVICE4}
    Set Suite Variable  ${sId_4}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  15  ${lid}  ${sId_1}  ${sId_2}  ${sId_3}  ${sId_4}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    Log  ${qid1}
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    # ${cid}=  get_id  ${CUSERNAME5} 

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
   
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid1}  ${DAY}  ${sId_1}  ${desc}  ${bool[0]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid1}  ${DAY}  ${sId_2}  ${desc}  ${bool[0]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid2}  ${wid[0]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200  
    # ${cid}=  get_id  ${CUSERNAME1} 

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
   
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid1}  ${DAY}  ${sId_1}  ${desc}  ${bool[0]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid3}  ${wid[0]}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid1}  ${DAY}  ${sId_2}  ${desc}  ${bool[0]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid4}  ${wid[0]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200  
    # ${cid}=  get_id  ${CUSERNAME2}   

    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
 
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid1}  ${DAY}  ${sId_1}  ${desc}  ${bool[0]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid5}  ${wid[0]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action  ${waitlist_actions[0]}  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[1]}
    ${resp}=  Waitlist Action  ${waitlist_actions[0]}  ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[1]}
    ${resp}=  Waitlist Action  ${waitlist_actions[0]}  ${wid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${wid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[1]}

    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=  Get Queue ById  ${qid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=2  queueWaitingTime=8

    change_system_time  0  5
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=  Get Queue ById  ${qid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=5  queueWaitingTime=15

    change_system_time  0  10
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=  Get Queue ById  ${qid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=8  queueWaitingTime=16

    Comment   Check queue waiting time when queue has no persons in waitlist status arrived,So turnAroundTime is 8

    change_system_time  0  10
    ${resp}=  Get Waitlist By Id  ${wid4}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid4}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=  Get Queue ById  ${qid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=8  queueWaitingTime=8

    change_system_time  0  10
    ${resp}=  Get Waitlist By Id  ${wid5}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid5}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=  Get Queue ById  ${qid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=8  queueWaitingTime=0
    resetsystem_time

JD-TC-ML Test Case-6
    [Documentation]   Check queue waiting time when token1 is arrived after token3
    ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_service   ${PUSERNAME14}
    clear_location  ${PUSERNAME14}
    clear_queue  ${PUSERNAME14}
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  0  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}  ${DAY}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${sTime1}=  subtract_timezone_time  ${tz}  1  00
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${sId_1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${sId_1}
    ${sId_2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${sId_2}
    ${sId_3}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable  ${sId_3}
    ${sId_4}=  Create Sample Service  ${SERVICE4}
    Set Suite Variable  ${sId_4}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  15  ${lid}  ${sId_1}  ${sId_2}  ${sId_3}  ${sId_4}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid2}  ${resp.json()}
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    # ${cid}=  get_id  ${CUSERNAME5}   

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
 
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid2}  ${DAY}  ${sId_1}  ${desc}  ${bool[0]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid2}  ${DAY}  ${sId_2}  ${desc}  ${bool[0]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid2}  ${wid[0]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200  
    # ${cid}=  get_id  ${CUSERNAME1}   

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
 
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid2}  ${DAY}  ${sId_1}  ${desc}  ${bool[0]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid3}  ${wid[0]}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid2}  ${DAY}  ${sId_2}  ${desc}  ${bool[0]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid4}  ${wid[0]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200  
    # ${cid}=  get_id  ${CUSERNAME2}

    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid2}  ${DAY}  ${sId_1}  ${desc}  ${bool[0]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid5}  ${wid[0]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action  ${waitlist_actions[0]}  ${wid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${wid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[1]}
    ${resp}=  Waitlist Action  ${waitlist_actions[0]}  ${wid4}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${wid4}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[1]}
    ${resp}=  Waitlist Action  ${waitlist_actions[0]}  ${wid5}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${wid5}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[1]}

    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=  Get Queue ById  ${qid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=2  queueWaitingTime=8
    ${resp}=  Get Waitlist Today   queue-eq=${qid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   2
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   4  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   6
    
    
    change_system_time  0  10
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=  Get Queue ById  ${qid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=10  queueWaitingTime=30
    ${resp}=  Get Waitlist Today   queue-eq=${qid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   10 
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   20
    
    change_system_time  0  5
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=  Get Queue ById  ${qid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=8  queueWaitingTime=16
    ${resp}=  Get Waitlist Today   queue-eq=${qid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   8

    change_system_time  0  5
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid4}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=  Get Queue ById  ${qid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=7  queueWaitingTime=7
    ${resp}=  Get Waitlist Today   queue-eq=${qid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   0

    change_system_time  0  10
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid5}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=  Get Queue ById  ${qid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=8  queueWaitingTime=0