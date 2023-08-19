*** Settings ***

Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      Coupon
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/acc_ver.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Variables ***


${loc}  Location1
${loc1}  Location112
${loc2}  Location23
${SERVICE1}   service11
${SERVICE2}   service12
${queue1}   Queue11

*** Test Cases ***

JD-TC-High Level Test Case-1
	[Documentation]  Checking the appxWaitingTime when calculation mode as NoCalc in today 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid}=  get_acc_id  ${PUSERNAME134}
    Set Suite Variable  ${pid}  ${pid}

    clear_location    ${PUSERNAME134}
    clear_service       ${PUSERNAME134}
    clear_queue      ${PUSERNAME134}
    clear_customer   ${PUSERNAME134}

    ${resp}=   Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY}=  db.get_date_by_timezone  ${tz}   
    Set Suite Variable  ${DAY}

    ${companySuffix}=  FakerLibrary.companySuffix
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${description}=  FakerLibrary.sentence
    ${snote}=  FakerLibrary.Word
    ${dis}=  FakerLibrary.Word
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime}=  add_timezone_time  ${tz}  0  30  
    ${eTime}=  add_timezone_time  ${tz}  3  00  

    ${resp}=  Create Location  ${loc}  ${longi}  ${latti}  www.${companySuffix}.com  ${postcode}   ${address}  free  True  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid1}  ${resp.json()} 

    
    ${desc}=  FakerLibrary.sentence
    set Suite Variable   ${desc}
    ${ser_durtn}=   Random Int   min=2   max=10
    ${ser_amount}=   Random Int   min=100   max=1000
    ${ser_amount1}=   Convert To Number   ${ser_amount}
    Set Suite Variable   ${ser_amount1}
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount1}  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_1}  ${resp.json()}

    ${desc}=  FakerLibrary.sentence
    set Suite Variable   ${desc}
    ${ser_durtn}=   Random Int   min=2   max=10
    ${ser_amount}=   Random Int   min=100   max=1000
    ${ser_amount2}=   Convert To Number   ${ser_amount}
    Set Suite Variable   ${ser_amount1}
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount2}  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_2}  ${resp.json()}

    
    # sleep  2s


    ${capacity}=   Random Int   min=20   max=100
    ${parallel}=   Random Int   min=1   max=2
    ${sTime}=  add_timezone_time  ${tz}  1  00  
    ${eTime}=  add_timezone_time  ${tz}  1  30  

    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid1}  ${sId_1}  ${sId_2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q1_l1}   ${resp.json()}

   
    # sleep  4s

    ${resp}=  Update Waitlist Settings  ${calc_mode[2]}  0  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200   
    sleep  4s
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  calculationMode=${calc_mode[2]}  trnArndTime=0

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}


    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${q1_l1}  ${DAY}  hi  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}


    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${q1_l1}  ${DAY}  hi  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid2}  ${wid[0]}

    ${resp}=  AddCustomer  ${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid1}  ${resp.json()[0]['id']}
    
    ${resp}=  Add To Waitlist  ${cid1}  ${sId_1}  ${q1_l1}  ${DAY}  hi  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid3}  ${wid[0]}

    ${resp}=  Get Waitlist Today  queue-eq=${q1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid1}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${wid2}
    Should Be Equal As Strings  ${resp.json()[2]['ynwUuid']}  ${wid3}

    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid3}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid3}  ${resp.json()[0]['id']}
    
    ${resp}=  Add To Waitlist  ${cid3}  ${sId_2}  ${q1_l1}  ${DAY}  hi  ${bool[1]}  ${cid3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid4}  ${wid[0]}
    
    ${resp}=  Get Waitlist Today  queue-eq=${q1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid1}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${wid2}
    Should Be Equal As Strings  ${resp.json()[2]['ynwUuid']}  ${wid3}
    Should Be Equal As Strings  ${resp.json()[3]['ynwUuid']}  ${wid4}
    Should Be Equal As Strings  ${resp.json()[0]['token']}  1
    Should Be Equal As Strings  ${resp.json()[1]['token']}  2
    Should Be Equal As Strings  ${resp.json()[2]['token']}  3
    Should Be Equal As Strings  ${resp.json()[3]['token']}  4
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY}

JD-TC-High Level Test Case-2

    [Documentation]  Checking the appxWaitingTime when calculation mode as NoCalc in future

    clear_queue      ${PUSERNAME22}
    clear_location   ${PUSERNAME22}
    clear_service    ${PUSERNAME22}
    clear_customer   ${PUSERNAME22}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME22}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ser_duratn}=  Random Int   min=2   max=4
    ${resp}=  Update Waitlist Settings  ${calc_mode[2]}  ${ser_duratn}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  db.add_timezone_date  ${tz}   2
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  3  
    Set Suite Variable  ${DAY2} 
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
    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${strt_time}=   subtract_timezone_time  ${tz}  2  00
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}       0  20 
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

    ${resp}=  AddCustomer  ${CUSERNAME0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME0}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
   
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id1}  ${DAY1}  hi  ${bool[1]}  ${cid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${waitlist_id}  ${wid[0]}


    ${resp}=   Get Waitlist Future
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${waitlist_id}
    Should Be Equal As Strings  ${resp.json()[0]['token']}  1
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY1}