*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Waitlist
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
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
JD-TC-Get Waitlist Today-1
	[Documentation]  Add To Waitlist By Consumer valid  provider

    clear_service   ${PUSERNAME28}
    clear_location   ${PUSERNAME28}
    clear_queue     ${PUSERNAME28}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${lic_id}   ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
    Set Suite Variable  ${lic_name}   ${decrypted_data['accountLicenseDetails']['accountLicense']['name']}
    # Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
    # Set Test Variable   ${lic_name}   ${resp.json()['accountLicenseDetails']['accountLicense']['name']}


    
    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    # ${resp}=   Run Keyword If  '${lic_id}' != '${lic2}'  Change License Package  ${highest_package[0]}
    # Run Keyword If   '${resp}' != '${None}'  Log  ${resp.json()}
    # Run Keyword If   '${resp}' != '${None}'  Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${lic_id}' != '${lic2}'
        ${resp1}=   Change License Package  ${highest_package[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${pkg_id}=   get_highest_license_pkg
    # ${resp}=  Change License Package  ${pkgid[0]}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${pid}=  get_acc_id  ${PUSERNAME28}
    Set Suite Variable  ${pid} 
    ${loc_id1}=   Create Sample Location

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${s_id1}=   Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id1}
    ${s_id2}=   Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id2}
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
    ${resp}=  Create Queue    ${q_name1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id1}  ${s_id1}   ${s_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id1}   ${resp.json()}
    ${q_name2}=    FakerLibrary.name
    Set Suite Variable    ${q_name2}
    ${strt_time1}=   add_timezone_time  ${tz}  0  10  
    Set Suite Variable    ${strt_time1}
    ${end_time1}=    add_timezone_time  ${tz}  0  29   
    Set Suite Variable    ${end_time1}
    ${resp}=  Create Queue    ${q_name2}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${strt_time1}  ${end_time1}   ${parallel}   ${capacity}    ${loc_id1}  ${s_id1}   ${s_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id2}   ${resp.json()}

    ${duration}=   Random Int  min=2  max=10
    Set Suite Variable   ${duration}  
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${duration}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  calculationMode=${calc_mode[1]}  trnArndTime=${duration}  futureDateWaitlist=${bool[1]}  showTokenId=${bool[1]}  onlineCheckIns=${bool[1]}   maxPartySize=1
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME15}   
    Set Suite Variable   ${cid}  
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${q_id1}  ${DAY}  ${s_id1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid1}  ${wid[0]}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${q_id1}  ${DAY}  ${s_id2}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid2}  ${wid[0]}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${q_id2}  ${DAY}  ${s_id1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
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
    Set Suite Variable  ${membr1}   ${resp.json()}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${q_id1}  ${DAY}  ${s_id2}  ${cnote}  ${bool[0]}  ${membr1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${w1}  ${wid[0]}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${uuid1}
    Should Be Equal As Strings  ${resp.status_code}  200       
        
JD-TC-Get Waitlist Today-2
	[Documentation]  Filter waitlist by service id

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist  service-eq=${s_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  2
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${s_id2}
    Should Be Equal As Strings  ${resp.json()[1]['service']['id']}  ${s_id2}
    ${resp}=  Get consumer Waitlist   queue-eq=${q_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
       
JD-TC-Get Waitlist Today-3
	[Documentation]  Filter waitlist by queue id

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist  queue-eq=${q_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['queue']['id']}  ${q_id2}  

JD-TC-Get Waitlist Today-4
	[Documentation]  Filter waitlist by first name of family member

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist  waitlistingFor-eq=firstName::${firstName}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Log  ${count}
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['waitlistingFor'][0]['firstName']}  ${firstname}     

JD-TC-Get Waitlist Today-5
	[Documentation]  Filter waitlist by last name of family member

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist  waitlistingFor-eq=lastName::${lastName}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Log  ${count}
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['waitlistingFor'][0]['lastName']}  ${lastName}     

# JD-TC-Get Waitlist Today-6
# 	[Documentation]  Filter waitlist by jaldeeid of family member

#     ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get consumer Waitlist  waitlistingFor-eq=jaldeeId::${membr1}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${count}=  Get Length  ${resp.json()} 
#     Log  ${count}
#     Should Be Equal As Integers  ${count}  1
#     Should Be Equal As Strings  ${resp.json()[0]['waitlistingFor'][0]['jaldeeId']}  ${membr1}     

JD-TC-Get Waitlist Today-7
	[Documentation]  Filter waitlist by waitlist status

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist  waitlistStatus-eq=${wl_status[2]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY} 
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}  ${wl_status[2]}
    
JD-TC-Get Waitlist Today-8
	[Documentation]  Filter waitlist by queue id and service id

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist  service-eq=${s_id1}  queue-eq=${q_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${s_id1}
    Should Be Equal As Strings  ${resp.json()[0]['queue']['id']}  ${q_id1}       
    
JD-TC-Get Waitlist Today-9
	[Documentation]  Filter waitlist by queue id and status

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist   queue-eq=${q_id1}  waitlistStatus-eq=${wl_status[2]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY} 
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}  ${wl_status[2]}
    Should Be Equal As Strings  ${resp.json()[0]['queue']['id']}  ${q_id1} 

JD-TC-Get Waitlist Today-10
	[Documentation]  Filter waitlist by service-eq=${s_id1}  waitlistStatus-eq=started

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist   service-eq=${s_id1}  waitlistStatus-eq=${wl_status[2]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}  ${wl_status[2]}
    Should Be Equal As Strings  ${resp.json()[0]['queue']['id']}  ${q_id1}     
    
JD-TC-Get Waitlist Today-11
	[Documentation]  Filter waitlist by token

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist By Id  ${uuid2}  ${pid}
    Set Test Variable  ${token}  ${resp.json()['token']}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist   token-eq=${token}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['token']}  ${token} 

JD-TC-Get Waitlist Today-12
	[Documentation]  Filter waitlist by service-eq=${s_id1}  waitlistStatus-eq=checkedIn

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist   service-eq=${s_id1}  waitlistStatus-eq=${wl_status[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}  ${wl_status[0]}
     Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${s_id1}   

JD-TC-Get Waitlist Today-13
	[Documentation]  Filter waitlist by  queue-eq=${q_id1}  waitlistStatus-eq=checkedIn
    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist   queue-eq=${q_id1}  waitlistStatus-eq=${wl_status[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  2
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}  ${wl_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['queue']['id']}  ${q_id1} 
    Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}  ${wl_status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['queue']['id']}  ${q_id1}    

JD-TC-Get Waitlist Today-14
	[Documentation]  Filter waitlist by queue-eq=${q_id1}  waitlistStatus-eq=DONE

    ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action   ${waitlist_actions[4]}   ${uuid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist   queue-eq=${q_id1}  waitlistStatus-eq=${wl_status[5]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}  ${wl_status[5]}
    Should Be Equal As Strings  ${resp.json()[0]['queue']['id']}  ${q_id1} 

JD-TC-Get Waitlist Today-15
    [Documentation]  Filter waitlist by service-eq=${s_id1}  waitlistStatus-eq=DONE

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist   service-eq=${s_id1}  waitlistStatus-eq=${wl_status[5]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}  ${wl_status[5]}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${s_id1} 
     
JD-TC-Get Waitlist Today-16
    [Documentation]  Filter waitlist by service-eq=${s_id2}  waitlistStatus-eq=cancelled   

    ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${desc}=  FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${uuid2}  ${waitlist_cancl_reasn[4]}  ${desc}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Get Waitlist By Id  ${uuid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[4]}
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist   queue-eq=${q_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist   service-eq=${s_id2}  waitlistStatus-eq=${wl_status[4]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}  ${wl_status[4]}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${s_id2} 

JD-TC-Get Waitlist Today-17
	[Documentation]  Filter waitlist by queue-eq=${q_id1}  waitlistStatus-eq=cancelled

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist   queue-eq=${q_id1}  waitlistStatus-eq=${wl_status[4]}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}  ${wl_status[4]}
    Should Be Equal As Strings  ${resp.json()[0]['queue']['id']}  ${q_id1}   

JD-TC-Get Waitlist Today-18
	[Documentation]  Filter waitlist by token and queue id

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist By Id  ${uuid2}  ${pid}
    Set Test Variable  ${token}  ${resp.json()['token']}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist   queue-eq=${q_id1}  token-eq=${token}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['token']}  ${token} 

JD-TC-Get Waitlist Today-19
	[Documentation]  Filter waitlist by token and queue id

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist By Id  ${uuid2}  ${pid}
    Set Test Variable  ${token}  ${resp.json()['token']}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist   queue-eq=${q_id1}  token-eq=${token}  service-eq=${s_id2}  waitlistStatus-eq=${wl_status[4]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['token']}  ${token}  

JD-TC-Get Waitlist Today-20
	[Documentation]  Add To Waitlist By Consumer valid  provider

    clear_service   ${PUSERNAME22}
    clear_location   ${PUSERNAME22}
    clear_queue     ${PUSERNAME22}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME22}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid}=  get_acc_id  ${PUSERNAME22}
    Set Suite Variable  ${pid} 
    ${loc_id2}=   Create Sample Location
    Set Suite Variable   ${loc_id2}
    ${s1_id1}=   Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s1_id1}
    ${s1_id2}=   Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s1_id2}
    ${resp}=  Create Queue    ${q_name1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id2}  ${s1_id1}   ${s1_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q1_id1}   ${resp.json()}
    ${resp}=  Create Queue    ${q_name2}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${strt_time1}  ${end_time1}   ${parallel}   ${capacity}    ${loc_id2}  ${s1_id1}   ${s1_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q1_id2}   ${resp.json()}
    ${duration}=   Random Int  min=2  max=10
    Set Suite Variable   ${duration}  
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${duration}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  calculationMode=${calc_mode[1]}  trnArndTime=${duration}  futureDateWaitlist=${bool[1]}  showTokenId=${bool[1]}  onlineCheckIns=${bool[1]}   maxPartySize=1
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  db.add_timezone_date  ${tz}  1  

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME18}   
    Set Suite Variable   ${cid} 
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${q1_id1}  ${DAY1}  ${s1_id1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid1}  ${wid[0]}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${q1_id1}  ${DAY1}  ${s1_id2}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid2}  ${wid[0]}
    ${tid}=  Get Dictionary Keys  ${resp.json()}
    Set Suite Variable  ${token_id}  ${tid[0]}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${q1_id2}  ${DAY1}  ${s1_id1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid3}  ${wid[0]}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${q1_id2}  ${DAY1}  ${s1_id2}  ${cnote}  ${bool[0]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid4}  ${wid[0]}
    
JD-TC-Get Waitlist Today-21
	[Documentation]  Filter waitlist by service id

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist  service-eq=${s1_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  2   
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${s1_id2}
    Should Be Equal As Strings  ${resp.json()[1]['service']['id']}  ${s1_id2} 
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${uuid2}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${uuid4}
       
JD-TC-Get Waitlist Today-22
	[Documentation]  Filter waitlist by queue id

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist  queue-eq=${q1_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  2
    Should Be Equal As Strings  ${resp.json()[0]['queue']['id']}  ${q1_id2}  
    Should Be Equal As Strings  ${resp.json()[1]['queue']['id']}  ${q1_id2}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${uuid3}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${uuid4}
   
JD-TC-Get Waitlist Today-23
	[Documentation]  Filter waitlist by Location id

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist  location-eq=${loc_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
     ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  4    
    Should Be Equal As Strings  ${resp.json()[0]['queue']['location']['id']}  ${loc_id2}
    Should Be Equal As Strings  ${resp.json()[1]['queue']['location']['id']}  ${loc_id2}
    Should Be Equal As Strings  ${resp.json()[2]['queue']['location']['id']}  ${loc_id2}
    Should Be Equal As Strings  ${resp.json()[3]['queue']['location']['id']}  ${loc_id2}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${uuid1}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${uuid2}
    Should Be Equal As Strings  ${resp.json()[2]['ynwUuid']}  ${uuid3}    
    Should Be Equal As Strings  ${resp.json()[3]['ynwUuid']}  ${uuid4}

JD-TC-Get Waitlist Today-24
	[Documentation]  Filter waitlist by Status

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist  waitlistStatus-eq=${wl_status[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  4    
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${uuid1}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${uuid2}
    Should Be Equal As Strings  ${resp.json()[2]['ynwUuid']}  ${uuid3}    
    Should Be Equal As Strings  ${resp.json()[3]['ynwUuid']}  ${uuid4}

JD-TC-Get Waitlist Today-25
	[Documentation]  Filter waitlist queue-eq=${q1_id2}  location-eq=${loc_id2}

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist  queue-eq=${q1_id2}  location-eq=${loc_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  2
    Should Be Equal As Strings  ${resp.json()[0]['queue']['id']}  ${q1_id2}
    Should Be Equal As Strings  ${resp.json()[1]['queue']['id']}  ${q1_id2}
    Should Be Equal As Strings  ${resp.json()[0]['queue']['location']['id']}  ${loc_id2}
    Should Be Equal As Strings  ${resp.json()[0]['queue']['location']['id']}  ${loc_id2}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${uuid3}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${uuid4}
    
JD-TC-Get Waitlist Today-26
	[Documentation]  Filter waitlist by queue-eq=${q1_id2}  service-eq=${s1_id1}

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist  queue-eq=${q1_id2}  service-eq=${s1_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1   
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${s1_id1} 
    Should Be Equal As Strings  ${resp.json()[0]['queue']['id']}  ${q1_id2}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${uuid3}
    
JD-TC-Get Waitlist Today-27
	[Documentation]  Filter waitlist by waitlistStatus-eq=${${wl_status[0]}}  queue-eq=${q1_id2}

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist  waitlistStatus-eq=${wl_status[0]}  queue-eq=${q1_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  2    
    Should Be Equal As Strings  ${resp.json()[0]['queue']['id']}  ${q1_id2}
    Should Be Equal As Strings  ${resp.json()[1]['queue']['id']}  ${q1_id2}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${uuid3}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${uuid4}

JD-TC-Get Waitlist Today-28
	[Documentation]  Filter waitlist by service-eq=${s1_id2}  location-eq=${loc_id2}

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist  service-eq=${s1_id2}  location-eq=${loc_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  2
    Should Be Equal As Strings  ${resp.json()[0]['queue']['location']['id']}  ${loc_id2}
    Should Be Equal As Strings  ${resp.json()[1]['queue']['location']['id']}  ${loc_id2}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${uuid2}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${uuid4}
    
JD-TC-Get Waitlist Today-29
	[Documentation]  Filter waitlist by  waitlistStatus-eq=${${wl_status[0]}}  service-eq=${s1_id2}

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist  waitlistStatus-eq=${wl_status[0]}  service-eq=${s1_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  2 
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${s1_id2}
    Should Be Equal As Strings  ${resp.json()[1]['service']['id']}  ${s1_id2} 
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${uuid2}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${uuid4}  

JD-TC-Get Waitlist Today-30
	[Documentation]  Filter waitlist by waitlistStatus-eq=${${wl_status[0]}}  location-eq=${loc_id2}

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist  waitlistStatus-eq=${wl_status[0]}  location-eq=${loc_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  4 
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${uuid1}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${uuid2}
    Should Be Equal As Strings  ${resp.json()[2]['ynwUuid']}  ${uuid3}    
    Should Be Equal As Strings  ${resp.json()[3]['ynwUuid']}  ${uuid4}
    Should Be Equal As Strings  ${resp.json()[0]['queue']['location']['id']}  ${loc_id2}
    Should Be Equal As Strings  ${resp.json()[1]['queue']['location']['id']}  ${loc_id2}
    Should Be Equal As Strings  ${resp.json()[2]['queue']['location']['id']}  ${loc_id2}
    Should Be Equal As Strings  ${resp.json()[3]['queue']['location']['id']}  ${loc_id2}

JD-TC-Get Waitlist Today-31
	[Documentation]  Filter waitlist by waitlistStatus-eq=${${wl_status[0]}}  service-eq=${s1_id1}

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist  waitlistStatus-eq=${wl_status[0]}  service-eq=${s1_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  2       
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${s1_id1}
    Should Be Equal As Strings  ${resp.json()[1]['service']['id']}  ${s1_id1} 
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${uuid1}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${uuid3}  

JD-TC-Get Waitlist Today-32
	[Documentation]  Filter waitlist by  tokon id
    
    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist  token-eq=${token_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1      
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${uuid2}  
    # Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${uuid4} 
    Should Be Equal As Strings  ${resp.json()[0]['token']}  ${token_id} 
    # Should Be Equal As Strings  ${resp.json()[1]['token']}  ${token_id}

JD-TC-Get Waitlist Today-33
	[Documentation]  Filter waitlist by  first name
    
    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cname1}=  Set Variable   ${resp.json()['firstName']}
    ${resp}=  Get consumer Waitlist  firstName-eq=${cname1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  4  
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${uuid1}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${uuid2}
    Should Be Equal As Strings  ${resp.json()[2]['ynwUuid']}  ${uuid3}
    Should Be Equal As Strings  ${resp.json()[3]['ynwUuid']}  ${uuid4}  

JD-TC-Get Waitlist Today-34
	[Documentation]  Filter waitlist by date
    
    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  db.add_timezone_date  ${tz}  1  
    ${resp}=  Get consumer Waitlist  date-eq=${DAY1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  4  
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${uuid1}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${uuid2}
    Should Be Equal As Strings  ${resp.json()[2]['ynwUuid']}  ${uuid3}
    Should Be Equal As Strings  ${resp.json()[3]['ynwUuid']}  ${uuid4}

    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['date']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[2]['date']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[3]['date']}  ${DAY1}  

JD-TC-Get Waitlist Today-35
	[Documentation]  Filter waitlist by service id
    
    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  db.add_timezone_date  ${tz}  1  
    ${resp}=  Get consumer Waitlist  service-eq=${s1_id2}  date-eq=${DAY1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  2   
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${s1_id2}
    Should Be Equal As Strings  ${resp.json()[1]['service']['id']}  ${s1_id2} 
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${uuid2}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${uuid4}
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['date']}  ${DAY1}
       
JD-TC-Get Waitlist Today-36
	[Documentation]  Filter waitlist by queue id
    
    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  db.add_timezone_date  ${tz}  1  
    ${resp}=  Get consumer Waitlist  queue-eq=${q1_id2}  date-eq=${DAY1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  2
    Should Be Equal As Strings  ${resp.json()[0]['queue']['id']}  ${q1_id2}  
    Should Be Equal As Strings  ${resp.json()[1]['queue']['id']}  ${q1_id2}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${uuid3}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${uuid4}   
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['date']}  ${DAY1}  

JD-TC-Get Waitlist Today-37
	[Documentation]  Filter waitlist by queue-eq=${q1_id2}  date-eq=${DAY1}  location-eq=${loc_id2}  service-eq=${s1_id2}
    
    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  db.add_timezone_date  ${tz}  1  
    ${resp}=  Get consumer Waitlist  queue-eq=${q1_id2}  date-eq=${DAY1}  location-eq=${loc_id2}  service-eq=${s1_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1      
    Should Be Equal As Strings  ${resp.json()[0]['queue']['location']['id']}  ${loc_id2} 
    Should Be Equal As Strings  ${resp.json()[0]['queue']['id']}  ${q1_id2}  
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${s1_id2}  
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY1}   
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${uuid4}        
 
JD-TC-Get Waitlist Today-UH1
	[Documentation]  with out login 
    
    ${resp}=  Get consumer Waitlist   waitlistStatus-eq=${wl_status[2]}
    Should Be Equal As Strings  ${resp.status_code}  419  
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"   


JD-TC-FamilyMember-CLEAR
    clear_Family  ${membr1}
   