*** Settings ***
Suite Teardown    Run Keywords  Delete All Sessions  resetsystem_time
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
Variables         /ebs/TDD/varfiles/hl_musers.py

*** Variables ***
${SERVICE1}  Makeup  
${SERVICE2}  Hair makeup
${SERVICE3}  Makeup2 
${SERVICE4}  Hair makeup2


*** Test Cases ***

JD-TC-Approximate Waiting Time-1

    [Documentation]   Add a consumer to the waitlist for the current day when calculation mode as ML Then Verify all consumers approximate waiting time
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME129}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_service   ${PUSERNAME129}
    clear_location  ${PUSERNAME129}
    clear_queue  ${PUSERNAME129}
    clear_customer  ${PUSERNAME129}
    
    ${fixed_time}=   Random Int  min=1   max=10
    Set Suite Variable  ${fixed_time}
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${fixed_time}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}  ${DAY}
    ${DAY2}=  db.add_timezone_date  ${tz}  70      
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${sTime1}=  subtract_timezone_time  ${tz}  2  00
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  3  30  
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
    ${sTime}=  add_timezone_time  ${tz}  5  15  
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  6  30  
    Set Suite Variable   ${eTime}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid1}  ${resp.json()}
    ${sId_1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${sId_1}
    ${sId_2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${sId_2}
    ${sId_3}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable  ${sId_3}
    ${sId_4}=  Create Sample Service  ${SERVICE4}
    Set Suite Variable  ${sId_4}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  15  ${lid1}  ${sId_1}  ${sId_2}  ${sId_3}  ${sId_4}
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
    ${resp}=  Add To Waitlist  ${cid}  ${sId_3}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid7}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_4}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid8}  ${wid[0]}
    
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid1}       
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  03s

  
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   2
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   4  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   6 
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   8  
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   10 
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}   12      
    change_system_time  0  5         
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  03s 
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}  0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}  0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}  0
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}  5 
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}  10 
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}  15  
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}  20 
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}  25     
    change_system_time  0  10
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid3}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  03s
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   8
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   16
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   24
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}   32     
    change_system_time  0  15
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid4}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  03s
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   10
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   20
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}   30 
    change_system_time  0  10
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid5}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  03s
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   10
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}   20
    change_system_time  0  5
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid6}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  03s
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[7]['appxWaitingTime']}   9   
    change_system_time  0  10
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid7}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  03s
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
    Verify Response  ${resp}  turnAroundTime=9  queueWaitingTime=9

    change_system_time  0  5
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid8}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  03s
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
    Verify Response  ${resp}  turnAroundTime=9  queueWaitingTime=0

    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid9}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid9} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  appxWaitingTime=0

    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qi_d1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid10}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid10} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  appxWaitingTime=9

JD-TC-Approximate Waiting Time-2
	[Documentation]  Add a consumer to the waitlist for the future when calculation mode as ML and verify all consumers approximate waiting time
    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid}=  get_acc_id  ${PUSERNAME6}
    clear_service   ${PUSERNAME6}
    clear_location  ${PUSERNAME6}
    clear_queue  ${PUSERNAME6}
    ${fixed_time}=   Random Int  min=1   max=10
    Set Suite Variable  ${fixed_time}
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${fixed_time}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}  ${DAY}
    ${DAY2}=  db.add_timezone_date  ${tz}  70      
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${sTime1}=  subtract_timezone_time  ${tz}  2  00
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  3  30  
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
    ${sTime}=  add_timezone_time  ${tz}  5  15  
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  6  30  
    Set Suite Variable   ${eTime}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid1}  ${resp.json()}
    ${sId_1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${sId_1}
    ${sId_2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${sId_2}
    ${sId_3}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable  ${sId_3}
    ${sId_4}=  Create Sample Service  ${SERVICE4}
    Set Suite Variable  ${sId_4}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  15  ${lid1}  ${sId_1}  ${sId_2}  ${sId_3}  ${sId_4}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qi_d1}  ${resp.json()}
    
    ${resp}=  AddCustomer  ${CUSERNAME2}
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

    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid1}       
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  03s
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   2
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   4  
      
    change_system_time  0  5         
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  03s 
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}  0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}  0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}  0
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}  5 
    ${resp}=  Get Queue ById  ${qi_d1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=5  queueWaitingTime=10

    ${FDAY}=  db.add_timezone_date  ${tz}  35

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qi_d1}  ${FDAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${fwid1}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qi_d1}  ${FDAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${fwid2}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_3}  ${qi_d1}  ${FDAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${fwid3}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_4}  ${qi_d1}  ${FDAY}}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${fwid4}  ${wid[0]}    
     
    sleep  03s
    ${resp}=  Get Waitlist Future  date-eq=${FDAY}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   5
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   10 
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   15          
    ${resp}=  Get Queue Waiting Time  ${qi_d1}  ${FDAY}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  20


    change_system_time  0  10         
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  03s 
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}  0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}  0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}  0
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}  0
    ${resp}=  Get Queue ById  ${qi_d1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=8  queueWaitingTime=8

    sleep  03s
   
    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qi_d1}  ${FDAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${fwid5}  ${wid[0]}

    ${resp}=  Get Waitlist Future  date-eq=${FDAY}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   5
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   10 
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   15  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   32
        
    ${resp}=  Get Queue Waiting Time  ${qi_d1}  ${FDAY}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  40

    change_system_time  0  15         
    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid4}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  03s 
    ${resp}=  Get Waitlist Today   queue-eq=${qi_d1}
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}  0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}  0  
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}  0
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}  0
    ${resp}=  Get Queue ById  ${qi_d1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=10  queueWaitingTime=0

    sleep  03s
    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qi_d1}  ${FDAY}  ${desc}  ${bool[1]}  ${cid}

    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${fwid6}  ${wid[0]}
    ${resp}=  Get Waitlist Future  date-eq=${FDAY}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   5
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   10 
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   15  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   32
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   50
    ${resp}=  Get Queue Waiting Time  ${qi_d1}  ${FDAY}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  60

    ${resp}=  Add To Waitlist  ${cid}  ${sId_3}  ${qi_d1}  ${FDAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${fwid7}  ${wid[0]}
    ${resp}=  Get Waitlist Future  date-eq=${FDAY}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   5
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   10 
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   15  
    Should Be Equal As Strings  ${resp.json()[4]['appxWaitingTime']}   32
    Should Be Equal As Strings  ${resp.json()[5]['appxWaitingTime']}   50
    Should Be Equal As Strings  ${resp.json()[6]['appxWaitingTime']}   60
    ${resp}=  Get Queue Waiting Time  ${qi_d1}  ${FDAY}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  70