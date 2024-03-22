*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
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
${SERVICE1}    SERVICE1
${SERVICE2}    SERVICE2
${self}        0

*** Test Cases ***
JD-TC-Get waitlist Today count-1
	[Documentation]  Add To Waitlist By Consumer valid  provider
    
    clear_service   ${PUSERNAME134}
    clear_location   ${PUSERNAME134}
    clear_queue     ${PUSERNAME134}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid}=  get_acc_id  ${PUSERNAME134}
    Set Suite Variable  ${pid} 
    ${lid1}=   Create Sample Location
    ${sId_1}=   Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${sId_1}
    ${sId_2}=   Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${sId_2}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY}
    ${q_name1}=    FakerLibrary.name
    Set Suite Variable    ${q_name1}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${strt_time}=   db.subtract_timezone_time  ${tz}  3  00
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}  0  10   
    Set Suite Variable    ${end_time}  
    ${capacity}=  Random Int  min=8   max=20
    ${parallel}=  Random Int   min=1   max=2
    Set Suite Variable   ${parallel}
    Set Suite Variable   ${capacity}
    ${resp}=  Create Queue    ${q_name1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid1}  ${sId_1}  ${sId_2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q1_l1}   ${resp.json()}
    ${q_name2}=    FakerLibrary.name
    Set Suite Variable    ${q_name2}
    ${strt_time1}=   add_timezone_time  ${tz}  0  10  
    Set Suite Variable    ${strt_time1}
    ${end_time1}=    add_timezone_time  ${tz}  0  29   
    Set Suite Variable    ${end_time1}
    ${resp}=  Create Queue    ${q_name2}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${strt_time1}  ${end_time1}   ${parallel}   ${capacity}    ${lid1}  ${sId_1}  ${sId_2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q2_l1}   ${resp.json()}
    ${list}=  UpdateBaseLocation  ${lid1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  onlineCheckIns=${bool[1]}
    ${duration}=   Random Int  min=2  max=10
    Set Suite Variable   ${duration}  
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${duration}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${Empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  calculationMode=${calc_mode[1]}  trnArndTime=${duration}  futureDateWaitlist=${bool[1]}  showTokenId=${bool[1]}  onlineCheckIns=${bool[1]}   maxPartySize=1
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME16}   
    Set Suite Variable   ${cid}  
    ${cnote}=   FakerLibrary.word
    Set Suite Variable   ${cnote}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${q1_l1}  ${DAY}  ${sId_1}  ${cnote}  ${bool[0]}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid1}  ${wid[0]}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${q1_l1}  ${DAY}  ${sId_2}  ${cnote}  ${bool[0]}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid2}  ${wid[0]}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${q2_l1}  ${DAY}  ${sId_1}  ${cnote}  ${bool[0]}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid3}  ${wid[0]}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable   ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname}
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${f1}   ${resp.json()}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${q1_l1}  ${DAY}  ${sId_2}  ${cnote}  ${bool[0]}  ${f1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${uuid1}
    Should Be Equal As Strings  ${resp.status_code}  200       

JD-TC-Get waitlist Today count-2
	[Documentation]  Filter waitlist by service id
    
    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count  service-eq=${sId_2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2    
      
JD-TC-Get waitlist Today count-3
	[Documentation]  Filter waitlist by queue id
    
    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count  queue-eq=${q2_l1}
    Should Be Equal As Strings  ${resp.status_code}  200    
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get waitlist Today count-4
	[Documentation]  Filter waitlist by first name of family member
    
    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count  waitlistingFor-eq=firstName::${firstName}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get waitlist Today count-5
	[Documentation]  Filter waitlist by last name of family member
    
    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count  waitlistingFor-eq=lastName::${lastName}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

# JD-TC-Get waitlist Today count-6
# 	[Documentation]  Filter waitlist by jaldeeid of family member
    
#     ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Waitlist Consumer Count  waitlistingFor-eq=jaldeeId::${f1}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get waitlist Today count-7
	[Documentation]  Filter waitlist by waitlist status
    
    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count  waitlistStatus-eq=${wl_status[2]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1
    
JD-TC-Get waitlist Today count-8
	[Documentation]  Filter waitlist by queue id and service id
    
    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count  service-eq=${sId_1}  queue-eq=${q1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1        
    
JD-TC-Get waitlist Today count-9
	[Documentation]  Filter waitlist by queue id and status
    
    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count   queue-eq=${q1_l1}  waitlistStatus-eq=${wl_status[2]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1
    
JD-TC-Get waitlist Today count-10
	[Documentation]  Filter waitlist by service-eq=${sId_1}  waitlistStatus-eq=started
    
    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count   service-eq=${sId_1}  waitlistStatus-eq=${wl_status[2]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1
        
JD-TC-Get waitlist Today count-11
	[Documentation]  Filter waitlist by token
    
    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist By Id  ${uuid2}  ${pid}
    Set Test Variable  ${token}  ${resp.json()['token']}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count   token-eq=${token}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get waitlist Today count-12
	[Documentation]  Filter waitlist by service-eq=${sId_1}  waitlistStatus-eq=checkedIn
    
    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count   service-eq=${sId_1}  waitlistStatus-eq=${wl_status[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1  

JD-TC-Get waitlist Today count-13
	[Documentation]  Filter waitlist by  queue-eq=${q1_l1}  waitlistStatus-eq=checkedIn
    
    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count   queue-eq=${q1_l1}  waitlistStatus-eq=${wl_status[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2
    
JD-TC-Get waitlist Today count-14
	[Documentation]  Filter waitlist by queue-eq=${q1_l1}  waitlistStatus-eq=Done
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action  ${waitlist_actions[4]}   ${uuid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count   queue-eq=${q1_l1}  waitlistStatus-eq=${wl_status[5]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1
    
JD-TC-Get waitlist Today count-15
    [Documentation]  Filter waitlist by service-eq=${sId_1}  waitlistStatus-eq=Done
    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count   service-eq=${sId_1}  waitlistStatus-eq=${wl_status[5]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1
       
JD-TC-Get waitlist Today count-16
    [Documentation]  Filter waitlist by service-eq=${sId_2}  waitlistStatus-eq=cancelled   
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${desc}=  FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${uuid2}  ${waitlist_cancl_reasn[4]}  ${desc}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Get Waitlist By Id  ${uuid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[4]}
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count   queue-eq=${q1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count   service-eq=${sId_2}  waitlistStatus-eq=${wl_status[4]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1
    
JD-TC-Get waitlist Today count-17
	[Documentation]  Filter waitlist by queue-eq=${q1_l1}  waitlistStatus-eq=cancelled
    
    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count   queue-eq=${q1_l1}  waitlistStatus-eq=${wl_status[4]}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1
      
JD-TC-Get waitlist Today count-18
	[Documentation]  Filter waitlist by token and queue id
    
    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist By Id  ${uuid2}  ${pid}
    Set Test Variable  ${token}  ${resp.json()['token']}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count   queue-eq=${q1_l1}  token-eq=${token}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1 

JD-TC-Get waitlist Today count-19
	[Documentation]  Filter waitlist by token and queue id
    
    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist By Id  ${uuid2}  ${pid}
    Set Test Variable  ${token}  ${resp.json()['token']}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count   queue-eq=${q1_l1}  token-eq=${token}  service-eq=${sId_2}  waitlistStatus-eq=${wl_status[4]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get Waitlist Today count-20
	[Documentation]  Add To Waitlist By Consumer valid  provider

    clear_service   ${PUSERNAME55}
    clear_location   ${PUSERNAME55}
    clear_queue     ${PUSERNAME55}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME55}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Change License Package  ${pkgid[0]}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${pid}=  get_acc_id  ${PUSERNAME55}
    Set Suite Variable  ${pid}  
    Should Be Equal As Strings    ${resp.status_code}   200
    ${lid2}=   Create Sample Location
    Set Suite Variable   ${lid2}
    ${sId_1}=   Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${sId_1}
    ${sId_2}=   Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${sId_2}
    ${resp}=  Create Queue    ${q_name1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid2}  ${sId_1}  ${sId_2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q1_l2}   ${resp.json()}
    ${resp}=  Create Queue    ${q_name2}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${strt_time1}  ${end_time1}   ${parallel}   ${capacity}    ${lid2}  ${sId_1}  ${sId_2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q2_l2}   ${resp.json()}
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  db.add_timezone_date  ${tz}  1  

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME17}   
    Set Suite Variable   ${cid}  
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${q1_l2}  ${DAY1}  ${sId_1}  ${cnote}  ${bool[0]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid1}  ${wid[0]}    
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${q1_l2}  ${DAY1}  ${sId_2}  ${cnote}  ${bool[0]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid2}  ${wid[0]} 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${waitlist_id}  ${wid[0]}
    ${tid}=  Get Dictionary Keys  ${resp.json()}
    Set Suite Variable  ${token_id}  ${tid[0]}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${q2_l2}  ${DAY1}  ${sId_1}  ${cnote}  ${bool[0]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid3}  ${wid[0]}  
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${q2_l2}  ${DAY1}  ${sId_2}  ${cnote}  ${bool[0]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid4}  ${wid[0]}
    
JD-TC-Get Waitlist Today count-21
	[Documentation]  Filter waitlist by service id
    
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count  service-eq=${sId_2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}    2   
    
JD-TC-Get Waitlist Today count-22
	[Documentation]  Filter waitlist by queue id
    
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count  queue-eq=${q2_l2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}    2
    
JD-TC-Get Waitlist Today count-23
	[Documentation]  Filter waitlist by Location id
    
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count  location-eq=${lid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}    4    
    
JD-TC-Get Waitlist Today count-24
	[Documentation]  Filter waitlist by Status
    
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count  waitlistStatus-eq=${wl_status[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  4    
    
JD-TC-Get Waitlist Today count-25
	[Documentation]  Filter waitlist queue-eq=${q2_l2}  location-eq=${lid2}
    
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count  queue-eq=${q2_l2}  location-eq=${lid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2
    
JD-TC-Get Waitlist Today count-26
	[Documentation]  Filter waitlist by queue-eq=${q2_l2}  service-eq=${sId_1}
    
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count  queue-eq=${q2_l2}  service-eq=${sId_1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1   
    
JD-TC-Get Waitlist Today count-27
	[Documentation]  Filter waitlist by waitlistStatus-eq=${wl_status[0]}  queue-eq=${q2_l2}
    
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count  waitlistStatus-eq=${wl_status[0]}  queue-eq=${q2_l2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2    
    
JD-TC-Get Waitlist Today count-28
	[Documentation]  Filter waitlist by service-eq=${sId_2}  location-eq=${lid2}
    
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count  service-eq=${sId_2}  location-eq=${lid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2
    
JD-TC-Get Waitlist Today count-29
	[Documentation]  Filter waitlist by  waitlistStatus-eq=${wl_status[0]}  service-eq=${sId_2}
    
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count  waitlistStatus-eq=${wl_status[0]}  service-eq=${sId_2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2 
    
JD-TC-Get Waitlist Today count-30
	[Documentation]  Filter waitlist by waitlistStatus-eq=${wl_status[0]}  location-eq=${lid2}
    
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count  waitlistStatus-eq=${wl_status[0]}  location-eq=${lid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  4 
    
JD-TC-Get Waitlist Today count-31
	[Documentation]  Filter waitlist by waitlistStatus-eq=${wl_status[0]}  service-eq=${sId_1}
    
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count  waitlistStatus-eq=${wl_status[0]}  service-eq=${sId_1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2       
    
JD-TC-Get Waitlist Today count-32
	[Documentation]  Filter waitlist by  tokon id
    
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist Consumer Count  token-eq=${token_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1       
    
JD-TC-Get Waitlist Today count-33
	[Documentation]  Filter waitlist by  first name
    
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cname1}=  Set Variable   ${resp.json()['firstName']}
    ${resp}=  Get Waitlist Consumer Count  firstName-eq=${cname1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  4  
    
JD-TC-Get Waitlist Today count-34
	[Documentation]  Filter waitlist by date
    
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  db.add_timezone_date  ${tz}  1  
    ${resp}=  Get Waitlist Consumer Count  date-eq=${DAY1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  4  
    
JD-TC-Get Waitlist Today count-35
	[Documentation]  Filter waitlist by service id
    
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  db.add_timezone_date  ${tz}  1  
    ${resp}=  Get Waitlist Consumer Count  service-eq=${sId_2}  date-eq=${DAY1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2   
    
JD-TC-Get Waitlist Today count-36
	[Documentation]  Filter waitlist by queue id
    
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  db.add_timezone_date  ${tz}  1  
    ${resp}=  Get Waitlist Consumer Count  queue-eq=${q2_l2}  date-eq=${DAY1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2
    
JD-TC-Get Waitlist Today count-37
	[Documentation]  Filter waitlist by queue-eq=${q2_l2}  date-eq=${DAY1}  location-eq=${lid2}  service-eq=${sId_2}
    
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  db.add_timezone_date  ${tz}  1  
    ${resp}=  Get Waitlist Consumer Count  queue-eq=${q2_l2}  date-eq=${DAY1}  location-eq=${lid2}  service-eq=${sId_2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1         
 
JD-TC-Get waitlist Today count-UH1
	[Documentation]  with out login 
    
    ${resp}=  Get Waitlist Consumer Count   waitlistStatus-eq=${wl_status[2]}
    Should Be Equal As Strings  ${resp.status_code}  419  
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"   

JD-TC-FamilyMember-CLEAR
    clear_Family  ${f1}