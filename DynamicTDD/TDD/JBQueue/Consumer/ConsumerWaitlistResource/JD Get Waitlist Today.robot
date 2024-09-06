*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Waitlist
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           random
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot

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
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

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



# ............timezone cases........


JD-TC-Get Waitlist Today-38

	[Documentation]  taking a waitlist for a provider who has a branch in us. base location is ist.(online checkin from India),
    ...   then verify get waitlist today details. 

    clear_service   ${PUSERNAME228}
    clear_location   ${PUSERNAME228}
    clear_queue     ${PUSERNAME228}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME228}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${lic_id}   ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
    Set Test Variable  ${lic_name}   ${decrypted_data['accountLicenseDetails']['accountLicense']['name']}
   
    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Test variable  ${lic2}  ${highest_package[0]}

    IF  '${lic_id}' != '${lic2}'
        ${resp1}=   Change License Package  ${highest_package[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME228}
    
    ${latti}  ${longi}  ${city}  ${country_abbr}  ${US_tz}=  FakerLibrary.Local Latlng  country_code=US  coords_only=False
    ${list}=  Create List  1  2  3  4  5  6  7

    ${sTime}=  add_timezone_time  ${US_tz}  0  30  
    ${eTime}=  add_timezone_time  ${US_tz}  1  00  

    ${sTime1}  ${eTime1}=  db.endtime_conversion  ${sTime}  ${eTime}

    ${DAY}=  db.get_date_by_timezone  ${US_tz}
    ${address} =  FakerLibrary.address
    ${postcode}=  FakerLibrary.postcode
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${loc_id1}  ${resp.json()}

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${s_id1}=   Create Sample Service  ${SERVICE1}
    ${s_id2}=   Create Sample Service  ${SERVICE2}
    ${q_name1}=    FakerLibrary.name
    ${strt_time}=   db.subtract_timezone_time  ${US_tz}  3  00
    ${end_time}=    add_timezone_time  ${US_tz}  0  10   
    ${capacity}=  Random Int  min=8   max=20
    ${parallel}=  Random Int   min=1   max=2
    ${resp}=  Create Queue    ${q_name1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id1}  ${s_id1}   ${s_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id1}   ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${cid}=  get_id  ${CUSERNAME18}   

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${q_id1}  ${DAY}  ${s_id1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid1}  ${wid[0]}

    ${resp}=  Get consumer Waitlist  location-eq=${loc_id1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1


JD-TC-Get Waitlist Today-39

	[Documentation]  taking a waitlist for a provider who has a branch in us. base location is ist.(online checkin from India),
    ...   then verify get waitlist today details. 


    Comment  Provider in US
    ${PO_Number}=  FakerLibrary.Numerify  %#####
    ${USProvider}=  Evaluate  ${PUSERNAME}+${PO_Number}

    ${licpkgid}  ${licpkgname}=  get_highest_license_pkg

    ${resp}=  Get BusinessDomainsConf
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dom_len}=  Get Length  ${resp.json()}
    ${dom}=  random.randint  ${0}  ${dom_len-1}
    ${sdom_len}=  Get Length  ${resp.json()[${dom}]['subDomains']}
    Set Test Variable  ${domain}  ${resp.json()[${dom}]['domain']}
    Log   ${domain}
    
    FOR  ${subindex}  IN RANGE  ${sdom_len}
        ${sdom}=  random.randint  ${0}  ${sdom_len-1}
        Set Test Variable  ${subdomain}  ${resp.json()[${dom}]['subDomains'][${subindex}]['subDomain']}
        ${is_corp}=  check_is_corp  ${subdomain}
        Exit For Loop If  '${is_corp}' == 'False'
    END
    Log   ${subdomain}

    ${fname}=  FakerLibrary.name
    ${lname}=  FakerLibrary.lastname
    ${US_P_Email}  Set Variable  ${P_Email}${USProvider}.${test_mail}
    ${resp}=  Account SignUp  ${fname}  ${lname}  ${US_P_Email}  ${domain}  ${subdomain}  ${USProvider}  ${licpkgid}  countryCode=+64
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${US_P_Email}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${US_P_Email}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${US_P_Email}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Encrypted Provider Login  ${USProvider}  ${PASSWORD}  countryCode=+64
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${USProvider}+15566122
    ${ph2}=  Evaluate  ${USProvider}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${US_P_Email}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    ${address} =  FakerLibrary.address
    ${postcode}=  FakerLibrary.postcode
    ${latti}  ${longi}  ${city}  ${country_abbr}  ${US_tz_orig}=  FakerLibrary.Local Latlng  country_code=NZ  coords_only=False
    ${US_tz}=  create_tz  ${US_tz_orig}
    ${DAY}=  db.get_date_by_timezone  ${US_tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  db.get_time_by_timezone  ${US_tz}  
    ${eTime}=  db.add_timezone_time  ${US_tz}  0  30  
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
    Log  ${fields.content}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # Set Test Variable  ${email_id}  ${P_Email}${USProvider}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${fname}  ${lname}   ${US_P_Email}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${pid}=  get_acc_id  ${PUSERNAME217}
    
    # ${latti}  ${longi}  ${city}  ${country_abbr}  ${US_tz}=  FakerLibrary.Local Latlng  country_code=New Zealand  coords_only=False
    # ${list}=  Create List  1  2  3  4  5  6  7

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${loc_id1}   ${resp.json()[0]['id']}

    # ${sTime}=  add_timezone_time  ${US_tz}  0  30  
    # ${eTime}=  add_timezone_time  ${US_tz}  1  00  

    # ${sTime1}  ${eTime1}=  db.endtime_conversion  ${sTime}  ${eTime}

    # ${DAY}=  db.get_date_by_timezone  ${US_tz}
    # ${address} =  FakerLibrary.address
    # ${postcode}=  FakerLibrary.postcode
    # ${parking}    Random Element     ${parkingType} 
    # ${24hours}    Random Element    ['True','False']
    # ${url}=   FakerLibrary.url
    # ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${loc_id1}  ${resp.json()}

    # ${resp}=   Get Location ById  ${loc_id1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
   
    ${s_id1}=   Create Sample Service  ${SERVICE1}
    ${s_id2}=   Create Sample Service  ${SERVICE2}
    ${q_name1}=    FakerLibrary.name
    ${strt_time}=   db.subtract_timezone_time  ${US_tz}  3  00
    ${end_time}=    add_timezone_time  ${US_tz}  0  10   
    ${capacity}=  Random Int  min=8   max=20
    ${parallel}=  Random Int   min=1   max=2
    ${resp}=  Create Queue    ${q_name1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id1}  ${s_id1}   ${s_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id1}   ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${cid}=  get_id  ${CUSERNAME18}   

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${q_id1}  ${DAY}  ${s_id1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid1}  ${wid[0]}

    ${resp}=  Get consumer Waitlist  location-eq=${loc_id1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1


JD-TC-Get Waitlist Today-40

	[Documentation]  taking a waitlist for a provider in us( base location is US).(online checkin from India),
    ...   then verify get waitlist today details. 

    clear_service   ${PUSERNAME228}
    clear_location   ${PUSERNAME228}
    clear_queue     ${PUSERNAME228}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME228}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Get Waitlist Today-41

	[Documentation]  taking a waitlist for a provider who has base location is new zealand.(online checkin from India),
    ...   then verify get waitlist today details. 


    Comment  Provider in US
    ${PO_Number}=  FakerLibrary.Numerify  %#####
    ${USProvider}=  Evaluate  ${PUSERNAME}+${PO_Number}

    ${licpkgid}  ${licpkgname}=  get_highest_license_pkg

    ${resp}=  Get BusinessDomainsConf
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dom_len}=  Get Length  ${resp.json()}
    ${dom}=  random.randint  ${0}  ${dom_len-1}
    ${sdom_len}=  Get Length  ${resp.json()[${dom}]['subDomains']}
    Set Test Variable  ${domain}  ${resp.json()[${dom}]['domain']}
    Log   ${domain}
    
    FOR  ${subindex}  IN RANGE  ${sdom_len}
        ${sdom}=  random.randint  ${0}  ${sdom_len-1}
        Set Test Variable  ${subdomain}  ${resp.json()[${dom}]['subDomains'][${subindex}]['subDomain']}
        ${is_corp}=  check_is_corp  ${subdomain}
        Exit For Loop If  '${is_corp}' == 'False'
    END
    Log   ${subdomain}

    ${fname}=  FakerLibrary.name
    ${lname}=  FakerLibrary.lastname
    ${US_P_Email}  Set Variable  ${P_Email}${USProvider}.${test_mail}
    ${resp}=  Account SignUp  ${fname}  ${lname}  ${US_P_Email}  ${domain}  ${subdomain}  ${USProvider}  ${licpkgid}  countryCode=+64
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${US_P_Email}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${US_P_Email}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${US_P_Email}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Encrypted Provider Login  ${USProvider}  ${PASSWORD}  countryCode=+64
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}

    clear_service   ${USProvider}  
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${USProvider}+15566122
    ${ph2}=  Evaluate  ${USProvider}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${US_P_Email}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    ${address} =  FakerLibrary.address
    ${postcode}=  FakerLibrary.postcode
    ${latti}  ${longi}  ${city}  ${country_abbr}  ${US_tz_orig}=  FakerLibrary.Local Latlng  country_code=NZ  coords_only=False
    ${US_tz}=  create_tz  ${US_tz_orig}
    ${DAY}=  db.get_date_by_timezone  ${US_tz}
    ${DAY1}=  db.add_timezone_date  ${US_tz}  10 
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  db.get_time_by_timezone  ${US_tz}  
    ${eTime}=  db.add_timezone_time  ${US_tz}  1  30  
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
    Log  ${fields.content}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # Set Test Variable  ${email_id}  ${P_Email}${USProvider}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${fname}  ${lname}   ${US_P_Email}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${pid}=  get_acc_id  ${USProvider}
    
    # ${latti}  ${longi}  ${city}  ${country_abbr}  ${US_tz}=  FakerLibrary.Local Latlng  country_code=New Zealand  coords_only=False
    # ${list}=  Create List  1  2  3  4  5  6  7

    ${resp}=  Enable Appointment
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Waitlist
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${loc_id1}   ${resp.json()[0]['id']}

    ${sTime}=  add_timezone_time  ${US_tz}  0  30  
    ${eTime}=  add_timezone_time  ${US_tz}  1  00  

    ${sTime1}  ${eTime1}=  db.endtime_conversion  ${sTime}  ${eTime}

    # ${DAY}=  db.get_date_by_timezone  ${US_tz}
    # ${address} =  FakerLibrary.address
    # ${postcode}=  FakerLibrary.postcode
    # ${parking}    Random Element     ${parkingType} 
    # ${24hours}    Random Element    ['True','False']
    # ${url}=   FakerLibrary.url
    # ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${loc_id1}  ${resp.json()}

    # ${resp}=   Get Location ById  ${loc_id1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${s_id1}=   Create Sample Service  ${SERVICE1}
    ${s_id2}=   Create Sample Service  ${SERVICE2}
    ${q_name1}=    FakerLibrary.name
    ${strt_time}=   db.subtract_timezone_time  ${US_tz}  3  00
    ${end_time}=    add_timezone_time  ${US_tz}  0  10   
    ${capacity}=  Random Int  min=8   max=20
    ${parallel}=  Random Int   min=1   max=2
    ${resp}=  Create Queue    ${q_name1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}   ${parallel}   ${capacity}    ${loc_id1}  ${s_id1}   ${s_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id1}   ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200


    ${firstName}=  FakerLibrary.name
    ${lastName}=  FakerLibrary.last_name
    # ${primaryMobileNo}    FakerLibrary.Numerify   text=%#########
    # ${CountryCode}  FakerLibrary.Country Code
    # ${Number}=  random_phone_num_generator
    # Log  ${Number}
    # ${CountryCode}=  Set Variable  ${Number.country_code}
    # ${primaryMobileNo}=  Set Variable  ${Number.national_number}
    ${Number}=  FakerLibrary.Numerify  %#####
    ${primaryMobileNo}=  Evaluate  ${CUSERNAME}+${Number}
    Set Test Variable  ${email}  ${C_Email}${primaryMobileNo}.${test_mail}
    
    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${pid}   countryCode=${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${primaryMobileNo}  ${pid}  countryCode=${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200    

    ${resp}=  Customer Logout   
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}  ${pid}  ${token}  countryCode=${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}

    # ${resp}=  Consumer Login    ${CUSERNAME9}  ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200 

    # Set Test Variable  ${f_Name}  ${resp.json()['firstName']}
    # Set Test Variable  ${l_Name}  ${resp.json()['lastName']}
    # Set Test Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']} 

    # ${cid}=  get_id  ${CUSERNAME9}   

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${q_id1}  ${DAY}  ${s_id1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid1}  ${wid[0]}

    ${resp}=  Get consumer Waitlist  location-eq=${loc_id1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1


JD-TC-Get Waitlist Today-42

	[Documentation]  taking an appt for a provider who has base location is new zealand.(online checkin from India),
    ...   then verify get waitlist today details. 




    Comment  Provider in US
    ${PO_Number}=  FakerLibrary.Numerify  %#####
    ${USProvider}=  Evaluate  ${PUSERNAME}+${PO_Number}

    ${licpkgid}  ${licpkgname}=  get_highest_license_pkg

    ${resp}=  Get BusinessDomainsConf
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dom_len}=  Get Length  ${resp.json()}
    ${dom}=  random.randint  ${0}  ${dom_len-1}
    ${sdom_len}=  Get Length  ${resp.json()[${dom}]['subDomains']}
    Set Test Variable  ${domain}  ${resp.json()[${dom}]['domain']}
    Log   ${domain}
    
    FOR  ${subindex}  IN RANGE  ${sdom_len}
        ${sdom}=  random.randint  ${0}  ${sdom_len-1}
        Set Test Variable  ${subdomain}  ${resp.json()[${dom}]['subDomains'][${subindex}]['subDomain']}
        ${is_corp}=  check_is_corp  ${subdomain}
        Exit For Loop If  '${is_corp}' == 'False'
    END
    Log   ${subdomain}

    ${fname}=  FakerLibrary.name
    ${lname}=  FakerLibrary.lastname
    ${US_P_Email}  Set Variable  ${P_Email}${USProvider}.${test_mail}
    ${resp}=  Account SignUp  ${fname}  ${lname}  ${US_P_Email}  ${domain}  ${subdomain}  ${USProvider}  ${licpkgid}  countryCode=+64
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${US_P_Email}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${US_P_Email}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${US_P_Email}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Encrypted Provider Login  ${USProvider}  ${PASSWORD}  countryCode=+64
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}

    clear_service   ${USProvider}  
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${USProvider}+15566122
    ${ph2}=  Evaluate  ${USProvider}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${US_P_Email}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    ${address} =  FakerLibrary.address
    ${postcode}=  FakerLibrary.postcode
    ${latti}  ${longi}  ${city}  ${country_abbr}  ${US_tz_orig}=  FakerLibrary.Local Latlng  country_code=NZ  coords_only=False
    ${US_tz}=  create_tz  ${US_tz_orig}
    ${DAY}=  db.get_date_by_timezone  ${US_tz}
    ${DAY1}=  db.add_timezone_date  ${US_tz}  10 
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  db.get_time_by_timezone  ${US_tz}  
    ${eTime}=  db.add_timezone_time  ${US_tz}  1  30  
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
    Log  ${fields.content}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # Set Test Variable  ${email_id}  ${P_Email}${USProvider}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${fname}  ${lname}   ${US_P_Email}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${pid}=  get_acc_id  ${USProvider}
    
    # ${latti}  ${longi}  ${city}  ${country_abbr}  ${US_tz}=  FakerLibrary.Local Latlng  country_code=New Zealand  coords_only=False
    # ${list}=  Create List  1  2  3  4  5  6  7

    ${resp}=  Enable Appointment
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${loc_id1}   ${resp.json()[0]['id']}

    ${sTime}=  add_timezone_time  ${US_tz}  0  30  
    ${eTime}=  add_timezone_time  ${US_tz}  1  00  

    ${sTime1}  ${eTime1}=  db.endtime_conversion  ${sTime}  ${eTime}

    # ${DAY}=  db.get_date_by_timezone  ${US_tz}
    # ${address} =  FakerLibrary.address
    # ${postcode}=  FakerLibrary.postcode
    # ${parking}    Random Element     ${parkingType} 
    # ${24hours}    Random Element    ['True','False']
    # ${url}=   FakerLibrary.url
    # ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${loc_id1}  ${resp.json()}

    # ${resp}=   Get Location ById  ${loc_id1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${s_id1}=   Create Sample Service  ${SERVICE1}
    ${s_id2}=   Create Sample Service  ${SERVICE2}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=5
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY}  ${DAY1}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${loc_id1}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Monthly Schedule Availability by Location and Service  ${loc_id1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['scheduleName']}   ${schedule_name}
    Should Be Equal As Strings  ${resp.json()[0]['scheduleId']}     ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[0]['date']}           ${DAY}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstName}=  FakerLibrary.name
    ${lastName}=  FakerLibrary.last_name
    # ${primaryMobileNo}    FakerLibrary.Numerify   text=%#########
    # ${CountryCode}  FakerLibrary.Country Code
    ${Number}=  random_phone_num_generator
    Log  ${Number}
    ${CountryCode}=  Set Variable  ${Number[0]}
    ${primaryMobileNo}=  Set Variable  ${Number[1]}
    Set Test Variable  ${email}  ${C_Email}${primaryMobileNo}.${test_mail}
    
    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${pid}   countryCode=${CountryCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${primaryMobileNo}  ${pid}  countryCode=${CountryCode}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200    

    ${resp}=  Customer Logout   
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}  ${pid}  ${token}  countryCode=${CountryCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}

    # ${resp}=  Consumer Login    ${CUSERNAME9}  ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200 

    # Set Test Variable  ${f_Name}  ${resp.json()['firstName']}
    # Set Test Variable  ${l_Name}  ${resp.json()['lastName']}
    # Set Test Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']} 

    # ${cid}=  get_id  ${CUSERNAME9}   

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id1}   ${pid}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id1}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.word
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id1}  ${sch_id1}  ${DAY}  ${cnote}   ${apptfor}   location=${{str('${loc_id1}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=    Get Consumer Appointments Today  location-eq=${loc_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    ${resp}=    Get Consumer Appointments Today 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1


JD-TC-FamilyMember-CLEAR
    clear_Family  ${membr1}
   