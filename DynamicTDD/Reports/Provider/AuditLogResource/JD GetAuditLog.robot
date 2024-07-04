***Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        AuditLog
Library           Collections
Library           String
Library           json
Library           random
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${DisplayName1}   item1_DisplayName
${SERVICE1}	    Bridal Makeupsss
${NPASS}        Netvarth1     
${digits}       0987654321
${disc_type}    Predefine
${SERVICE12}  sampleservice11 
${SERVICE2}  sampleservice22
${self}     0
#${digits}       0123456789
@{provider_list}
@{dom_list}
@{multiloc_providers}


*** Test Cases ***

JD-TC-GetAuditLog -1
    [Documentation]   Provider get Audit log after provider login

    clear_Auditlog  ${PUSERNAME160}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME160}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200 
    # ${aid}=  get_acc_id  ${PUSERNAME160}
    ${lid}=  Create Sample Location
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${aid}  ${resp.json()['id']}

    ${resp}=  Create Sample Location  
    Set Suite Variable    ${lid}    ${resp}  

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${time}=   db.get_time_by_timezone  ${tz}
    ${converted_time1}=  db.timeto24hr   ${time}
    
    ${resp}=   Get Audit Logs
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['date']}       ${DAY1}
    Variable Should exist       ${resp.json()[0]['time']}       ${converted_time1}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Logged in
    Should Be Equal As Strings  ${resp.json()[0]['text']}       Login
    Should Be Equal As Strings  ${resp.json()[0]['Action']}     ADD
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   PROVIDER

JD-TC-GetAuditLog -2  
    [Documentation]   Provider get Audit log after new service creation

    clear_service   ${PUSERNAME160}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME160}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${ser_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable    ${ser_id1}
    ${time}=   db.get_time_by_timezone  ${tz}
    ${converted_time1}=  db.timeto24hr   ${time}

    ${resp}=   Get Audit Logs
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}           200
    Should Be Equal As Strings  ${resp.json()[0]['date']}       ${DAY1}
    Variable Should exist       ${resp.json()[0]['time']}       ${converted_time1}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Service Creation
    Should Be Equal As Strings  ${resp.json()[0]['text']}       Created service Bridal Makeupsss
    Should Be Equal As Strings  ${resp.json()[0]['Action']}     ADD
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   PROVIDER

JD-TC-GetAuditLog -3
    [Documentation]   Provider get Audit log after disable a service and enable a service

    ${resp}=   Encrypted Provider Login  ${PUSERNAME160}    ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Disable service  ${ser_id1}  
    Should Be Equal As Strings  ${resp.status_code}     200
    ${time}=   db.get_time_by_timezone  ${tz}
    ${converted_time1}=  db.timeto24hr   ${time}

    ${resp}=   Get Audit Logs
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['date']}       ${DAY1}
    Variable Should exist       ${resp.json()[0]['time']}       ${converted_time1}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Service Disabled
    Should Be Equal As Strings  ${resp.json()[0]['text']}       Disabled service Bridal Makeupsss
    Should Be Equal As Strings  ${resp.json()[0]['Action']}     DELETE
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   PROVIDER  

    ${resp}=  Enable service  ${ser_id1}  
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${time}=   db.get_time_by_timezone  ${tz}
    ${converted_time1}=  db.timeto24hr   ${time}

    ${resp}=   Get Audit Logs
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['date']}       ${DAY1}
    Variable Should exist       ${resp.json()[0]['time']}       ${converted_time1}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Service Enabled
    Should Be Equal As Strings  ${resp.json()[0]['text']}       Enabled service Bridal Makeupsss
    Should Be Equal As Strings  ${resp.json()[0]['Action']}     EDIT
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   PROVIDER 

JD-TC-GetAuditLog -4
    [Documentation]   Provider get Audit log after new location creation

    clear_location    ${PUSERNAME160}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME160}    ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${loc_id}=  Create Sample Location
    Set Suite Variable  ${loc_id}
    ${time}=   db.get_time_by_timezone  ${tz}
    ${converted_time1}=  db.timeto24hr   ${time}

    ${resp}=   Get Audit Logs
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['date']}       ${DAY1}
    Variable Should exist       ${resp.json()[0]['time']}       ${converted_time1}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Created a location
    Should Be Equal As Strings  ${resp.json()[0]['text']}       Created a location
    Should Be Equal As Strings  ${resp.json()[0]['Action']}     ADD
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   PROVIDER 

JD-TC-GetAuditLog -5
    [Documentation]   Provider get Audit log after disable a location

    ${f_name}=  FakerLibrary.first_name
    ${l_name}=  FakerLibrary.last_name
    ${resp}=    get_mutilocation_domains
    Log   ${resp}
    Set Test Variable   ${sector}        ${resp[0]['domain']}
    Set Test Variable   ${sub_sector}    ${resp[0]['subdomains'][0]}
    ${PUSERNAME_P}=  Evaluate  ${PUSERNAME}+99643
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_P}${\n}   
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=   Account SignUp  ${f_name}  ${l_name}  ${None}   ${sector}   ${sub_sector}  ${PUSERNAME_P}  ${pkg_id[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_P}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_P}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_P}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${PUSERNAME_P}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200  
    # ${lid1}=     Create Sample Location
    # Set Suite Variable  ${lid1}
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address

    ${p1_l1}=  Create Sample Location

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${s_Time}=  db.get_time_by_timezone  ${tz}
    ${s_Time}=  db.get_time_by_timezone  ${tz}
    Set Suite Variable    ${s_Time}
    ${converted_time}=  db.timeto24hr   ${s_Time}
    Set Suite Variable    ${converted_time}

    ${e_Time}=  add_timezone_time  ${tz}  0  15  
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${s_Time}  ${e_Time}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${loc_id1}  ${resp.json()}

    ${resp}=  Disable Location  ${loc_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${time}=   db.get_time_by_timezone  ${tz}
    ${converted_time1}=  db.timeto24hr   ${time}

    ${resp}=   Get Audit Logs
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['date']}       ${DAY}
    Variable Should exist       ${resp.json()[0]['time']}       ${converted_time1}

JD-TC-GetAuditLog -6
    [Documentation]   Provider get Audit log after location enabled

    ${f_name}=  FakerLibrary.first_name
    ${l_name}=  FakerLibrary.last_name
    ${resp}=    get_mutilocation_domains
    Log   ${resp}
    Set Test Variable   ${sector}        ${resp[2]['domain']}
    Set Test Variable   ${sub_sector}    ${resp[2]['subdomains'][0]}
    ${PUSERNAME_K}=  Evaluate  ${PUSERNAME}+99644
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_K}${\n}   
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=   Account SignUp  ${f_name}  ${l_name}  ${None}   ${sector}   ${sub_sector}  ${PUSERNAME_K}  ${pkg_id[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_K}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_K}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_K}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${PUSERNAME_NEW}   ${PUSERNAME_K}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_NEW}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200  
    # ${locatnid1}=     Create Sample Location
    # Set Suite Variable  ${locatnid1}
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address

    ${p1_l1}=  Create Sample Location

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    Set Suite Variable    ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  0  15  
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${locatnid2}   ${resp.json()}

    ${resp}=  Disable Location  ${locatnid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Enable Location  ${locatnid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${time}=   db.get_time_by_timezone  ${tz}
    ${converted_time1}=  db.timeto24hr   ${time}

    ${resp}=   Get Audit Logs
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['date']}       ${DAY}
    Variable Should exist       ${resp.json()[0]['time']}       ${converted_time1}

    ${resp}=  Disable Location  ${locatnid2}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetAuditLog -7
    [Documentation]   Provider get Audit log after new queue creation

    clear_Auditlog  ${PUSERNAME163}
    clear_location  ${PUSERNAME163}
    clear_service   ${PUSERNAME163}
    ${resp}=   Encrypted Provider Login      ${PUSERNAME163}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Create Sample Queue
    Set Suite Variable   ${loc_id2}   ${resp['location_id']}
    Set Suite Variable   ${ser_id2}   ${resp['service_id']}
    Set Suite Variable   ${que_id2}   ${resp['queue_id']}
    ${resp}=   Get Location ById  ${loc_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${time}=   db.get_time_by_timezone  ${tz}
    ${converted_time1}=  db.timeto24hr   ${time}

    ${resp}=   Get Audit Logs
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['date']}       ${DAY1}
    Variable Should exist       ${resp.json()[0]['time']}       ${converted_time1}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}   	Service time window created
    Should Be Equal As Strings  ${resp.json()[0]['text']}       Created a service time window
    Should Be Equal As Strings  ${resp.json()[0]['Action']}     ADD
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   PROVIDER

JD-TC-GetAuditLog -8
    [Documentation]   Provider get Audit log after update queue

    clear_Auditlog  ${PUSERNAME164}
    clear_location  ${PUSERNAME164}
    clear_service   ${PUSERNAME164}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME164}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${resp}=  Create Sample Queue
    Set Suite Variable   ${loc_id3}   ${resp['location_id']}
    Set Suite Variable   ${ser_id3}   ${resp['service_id']}
    Set Suite Variable   ${que_id3}   ${resp['queue_id']} 
    ${resp}=   Get Location ById  ${loc_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${q_name2}=    FakerLibrary.name
    Set Suite Variable      ${q_name2}
    ${start_time2}=   add_timezone_time  ${tz}  0  45  
    Set Suite Variable   ${start_time2}
    ${end_time2}=     add_timezone_time  ${tz}  5  00  
    Set Suite Variable   ${end_time2}
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    Set Suite Variable   ${parallel}
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    Set Suite Variable   ${capacity}
    ${resp}=  Update Queue  ${que_id3}  ${q_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${start_time2}  ${end_time2}   ${parallel}   ${capacity}    ${loc_id3}  ${ser_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${time}=   db.get_time_by_timezone  ${tz}
    ${converted_time1}=  db.timeto24hr   ${time}

    ${resp}=   Get Audit Logs
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['date']}       ${DAY1}
    Variable Should exist       ${resp.json()[0]['time']}       ${converted_time1}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Service time window updated
    Should Be Equal As Strings  ${resp.json()[0]['text']}       Updated a service time window
    Should Be Equal As Strings  ${resp.json()[0]['Action']}     EDIT
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   PROVIDER    

JD-TC-GetAuditLog -9
    [Documentation]   Provider get Audit log after disable a queue

    ${resp}=   Encrypted Provider Login  ${PUSERNAME163}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200   
    ${resp}=  Disable Queue  ${que_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${time}=   db.get_time_by_timezone  ${tz}
    ${converted_time1}=  db.timeto24hr   ${time}

    ${resp}=   Get Audit Logs
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['date']}       ${DAY1}
    Variable Should exist       ${resp.json()[0]['time']}       ${converted_time1}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Service time window disabled
    Should Be Equal As Strings  ${resp.json()[0]['text']}       Disabled a service time window
    Should Be Equal As Strings  ${resp.json()[0]['Action']}     DELETE
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   PROVIDER
    
JD-TC-GetAuditLog -10
    [Documentation]   Provider get Audit log after enable a queue

    ${resp}=   Encrypted Provider Login  ${PUSERNAME163}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200   
    ${resp}=  Enable Queue  ${que_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${time}=   db.get_time_by_timezone  ${tz}
    ${converted_time1}=  db.timeto24hr   ${time}

    ${resp}=   Get Audit Logs
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['date']}       ${DAY1}
    Variable Should exist       ${resp.json()[0]['time']}       ${converted_time1}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Service time window enabled
    Should Be Equal As Strings  ${resp.json()[0]['text']}       Enabled a service time window
    Should Be Equal As Strings  ${resp.json()[0]['Action']}     EDIT
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   PROVIDER

JD-TC-GetAuditLog -11
    [Documentation]   Provider get Audit log after cancel a waitlist

    clear_Auditlog     ${PUSERNAME165}
    clear_location     ${PUSERNAME165}
    clear_service      ${PUSERNAME165}
    clear_customer     ${PUSERNAME165}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME165}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer By Id  ${CUSERNAME5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${fname}    ${resp.json()['userProfile']['firstName']} 
    Set Test Variable   ${lname}    ${resp.json()['userProfile']['lastName']} 
    Set Suite Variable   ${cons_name5}    ${resp.json()['createdBy']['userName']} 

    ${aid}=  get_acc_id   ${PUSERNAME165}    
    ${resp}=   Create Sample Queue
    Set Suite Variable   ${loc_id4}   ${resp['location_id']}
    Set Suite Variable   ${ser_id4}   ${resp['service_id']}
    Set Suite Variable   ${que_id4}   ${resp['queue_id']}
    ${resp}=   Get Location ById  ${loc_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${q_name1}=    FakerLibrary.name
    Set Suite Variable      ${q_name1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${start_time1}=   add_timezone_time  ${tz}  2  00  
    Set Suite Variable   ${start_time1}
    ${end_time1}=     add_timezone_time  ${tz}  5  00  
    Set Suite Variable   ${end_time1}
    ${resp}=  Update Queue  ${que_id4}  ${q_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${start_time1}  ${end_time1}   ${parallel}   ${capacity}    ${loc_id4}  ${ser_id4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=   Get Queue ById   ${que_id4}
    Log    ${resp.json()}
    Set Suite Variable   ${que_name}    ${resp.json()['name']}
    Set Suite Variable   ${ser_name}    ${resp.json()['services'][0]['name']}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME5}   firstName=${fname}   lastName=${lname} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${desc}=    FakerLibrary.word
    Set Suite Variable      ${desc}
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id4}  ${que_id4}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Log   ${wid}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    ${resp}=  Waitlist Action Cancel  ${wid}  ${waitlist_cancl_reasn[3]}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${time}=   db.get_time_by_timezone  ${tz}
    ${converted_time1}=  db.timeto24hr   ${time}

    ${resp}=   Get Audit Logs
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['date']}       ${DAY1}
    Variable Should exist       ${resp.json()[0]['time']}       ${converted_time1}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}   	Check-in cancellation 
    Should Be Equal As Strings  ${resp.json()[0]['text']}       Cancelled Check-in of ${cons_name5} for ${ser_name} in ${que_name} 
    Should Be Equal As Strings  ${resp.json()[0]['Action']}     DELETE
    
JD-TC-GetAuditLog -12
    [Documentation]   Provider get Audit log after add a delay

    ${resp}=   Encrypted Provider Login  ${PUSERNAME163}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    ${desc1}=    FakerLibrary.word
    Set Test Variable      ${desc1}  
    ${turn_arund_time}=   Random Int   min=1   max=14
    Set Suite Variable   ${turn_arund_time}
    ${resp}=  Add Delay  ${que_id2}  ${turn_arund_time}   ${desc1}  ${bool[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${time}=   db.get_time_by_timezone  ${tz}
    ${converted_time1}=  db.timeto24hr   ${time}

    ${resp}=   Get Audit Logs
    Should Be Equal As Strings  ${resp.status_code}                 200
    Should Be Equal As Strings  ${resp.json()[0]['date']}           ${DAY1}
    Variable Should exist       ${resp.json()[0]['time']}           ${converted_time1}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}        Booking Delay
    Should Be Equal As Strings  ${resp.json()[0]['text']}           Added delay of ${turn_arund_time} mins
    Should Be Equal As Strings  ${resp.json()[0]['Action']}         ADD

JD-TC-GetAuditLog -13
    [Documentation]   Provider get Audit log after update waitlist settings

    ${resp}=   Encrypted Provider Login  ${PUSERNAME165}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200  
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    ${turn_arund_time}=   Random Int   min=1   max=30 
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${turn_arund_time}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${time}=   db.get_time_by_timezone  ${tz}
    ${converted_time1}=  db.timeto24hr   ${time}

    ${resp}=   Get Audit Logs
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                 200
    Should Be Equal As Strings  ${resp.json()[0]['date']}           ${DAY1}
    Variable Should exist       ${resp.json()[0]['time']}           ${converted_time1}
    #Should Be Equal As Strings  ${resp.json()[0]['subject']}   	    Enabled accept future check-In
    Should Be Equal As Strings  ${resp.json()[0]['text']}           Updated Q manager Settings     
    Should Be Equal As Strings  ${resp.json()[0]['Action']}         EDIT


	

JD-TC-GetAuditLog -14
    [Documentation]   Provider get Audit log after holiday creation

    clear_Auditlog     ${PUSERNAME166}
    clear_location     ${PUSERNAME166}
    clear_service      ${PUSERNAME166}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME166}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Sample Queue
    Set Suite Variable   ${lid}   ${resp['location_id']}

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ctime}=  add_timezone_time  ${tz}  0  50
    ${etime}=  add_timezone_time  ${tz}  0  55  
    ${desc1}=    FakerLibrary.name
    Set Test Variable      ${desc1}
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${resp}=  Create Holiday  ${DAY1}  ${desc1}  ${ctime}  ${etime}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY1}  ${EMPTY}  ${ctime}  ${etime}  ${desc1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${holidayId}    ${resp.json()['holidayId']}

    # ${resp}=   Activate Holiday  ${holidayId}
    # Log   ${resp.json()}
    # Should Be Equal As Strings   ${resp.status_code}  200 
    # sleep   03s

    ${time1}=  db.get_time_by_timezone  ${tz}
    Set Suite Variable   ${time1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${convert_time}=  db.timeto24hr   ${time1}
    Set Suite Variable   ${convert_time}

    ${resp}=   Get Audit Logs
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                 200
    Should Be Equal As Strings  ${resp.json()[0]['date']}           ${DAY1}
    Variable Should exist       ${resp.json()[0]['time']}           ${convert_time}
   
JD-TC-GetAuditLog -15
    [Documentation]   Provider get Audit log when date=date and action=EDIT

    ${resp}=   Encrypted Provider Login  ${PUSERNAME160}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200    
    ${resp}=   Get Audit Logs  date-eq=${DAY1}  action-eq=EDIT
    Should Be Equal As Strings    ${resp.status_code}   200  
    Should Contain   "${resp.json()}"   text  :  Enabled service Bridal Makeupsss
    Should Contain   "${resp.json()}"   Action  :  EDIT

JD-TC-GetAuditLog -16
    [Documentation]   Provider get Audit log when date=date and action=DELETE

    ${resp}=   Encrypted Provider Login  ${PUSERNAME160}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200    
    ${resp}=   Get Audit Logs  date-eq=${DAY1}  action-eq=DELETE
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Contain   "${resp.json()}"  text  :  Disabled service Bridal Makeupsss"
    Should Contain   "${resp.json()}"  Action  :  DELETE"

JD-TC-GetAuditLog -17
    [Documentation]   Provider get Audit log when date=date and category-eq=WAITLIST  and subCategory-eq=DELAY

    ${resp}=   Encrypted Provider Login    ${PUSERNAME163}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200    
    ${resp}=   Get Audit Logs  date-eq=${DAY1}  category-eq=WAITLIST  subCategory-eq=DELAY
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['Category']}       WAITLIST
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}    DELAY
    Should Be Equal As Strings  ${resp.json()[0]['text']}           Added delay of ${turn_arund_time} mins

JD-TC-GetAuditLog -18
    [Documentation]   Provider get Audit log when date=date and category-eq=WAITLIST  and subCategory-eq=CANCEL

    ${resp}=   Encrypted Provider Login  ${PUSERNAME165}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200    
    ${resp}=   Get Audit Logs  date-eq=${DAY1}  category-eq=WAITLIST  subCategory-eq=CANCEL
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['Category']}     WAITLIST
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}  CANCEL
    Should Be Equal As Strings  ${resp.json()[0]['text']}   	  Cancelled Check-in of ${cons_name5} for ${ser_name} in ${que_name}
 
JD-TC-GetAuditLog -19
    [Documentation]   Provider get Audit log when date=date and category-eq=WAITLIST  and subCategory-eq=BILL

    ${resp}=   Encrypted Provider Login  ${PUSERNAME165}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200 

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=  Get Consumer By Id  ${CUSERNAME1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cons_name1}    ${resp.json()['userProfile']['firstName']} 
    Set Test Variable   ${lname}     ${resp.json()['userProfile']['lastName']} 
    
    ${acc_id}=   get_acc_id    ${PUSERNAME165}    
    ${gstper}=  Random Element  ${gstpercentage}
    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstper}  ${GST_num} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  AddCustomer  ${CUSERNAME1}    firstName=${cons_name1}   lastName=${lname} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
     

    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id4}  ${que_id4}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid1}=  Get Dictionary Values  ${resp.json()}
    Log   ${wid1}
    Set Test Variable  ${wid1}  ${wid1[0]}

    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid1}
    ${resp}=   Get Audit Logs  date-eq=${DAY1}  category-eq=WAITLIST  subCategory-eq=BILL
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['Category']}           WAITLIST
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}        BILL
    Should Be Equal As Strings  ${resp.json()[0]['text']}               Created bill for ${cons_name1} ${lname} 

JD-TC-VerifyAuditLog-6
	[Documentation]  Verification of AuditLog of ${PUSERNAME_NEW}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_NEW}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Enable Location     ${locatnid2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}     200
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${time}=   db.get_time_by_timezone  ${tz}
    ${converted_time1}=  db.timeto24hr   ${time}

    ${resp}=   Get Audit Logs
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['date']}       ${DAY1}
    Variable Should exist       ${resp.json()[0]['time']}       ${converted_time1}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Location enabled
    Should Be Equal As Strings  ${resp.json()[0]['text']}       Enabled a location
    Should Be Equal As Strings  ${resp.json()[0]['Action']}     EDIT
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   PROVIDER   

JD-TC-GetAuditLog -20
    [Documentation]   Provider get Audit log when date=date and category-eq=SETTINGS  and subCategory-eq=LOCATION

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_NEW}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${resp}=   Get Audit Logs  date-eq=${DAY1}  category-eq=SETTINGS  subCategory-eq=LOCATION
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['Category']}           SETTINGS
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}        LOCATION
    Should Be Equal As Strings  ${resp.json()[0]['text']}               Enabled a location
    Should Be Equal As Strings  ${resp.json()[1]['Category']}           SETTINGS
    Should Be Equal As Strings  ${resp.json()[1]['subCategory']}        LOCATION
    Should Be Equal As Strings  ${resp.json()[1]['text']}               Disabled a location
    Should Be Equal As Strings  ${resp.json()[2]['Category']}           SETTINGS
    Should Be Equal As Strings  ${resp.json()[2]['subCategory']}        LOCATION
    Should Be Equal As Strings  ${resp.json()[2]['text']}               Enabled a location

JD-TC-GetAuditLog -21
    [Documentation]   Provider get Audit log when date=date and category-eq=SETTINGS  and subCategory-eq=QUEUE

    ${resp}=   Encrypted Provider Login  ${PUSERNAME164}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${resp}=  Disable Queue  ${que_id3}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Enable Queue  ${que_id3}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogout
    
JD-TC-GetAuditLog -22
    [Documentation]   Provider get Audit log when date=date and category-eq=SETTINGS  and subCategory-eq=SERVICE

    ${resp}=   Encrypted Provider Login  ${PUSERNAME160}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200 

    ${resp}=   Get Audit Logs  date-eq=${DAY1}  category-eq=SETTINGS  subCategory-eq=SERVICE
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['Category']}           SETTINGS
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}        SERVICE
    Should Be Equal As Strings  ${resp.json()[0]['text']}               Enabled service Bridal Makeupsss
    Should Be Equal As Strings  ${resp.json()[1]['Category']}           SETTINGS
    Should Be Equal As Strings  ${resp.json()[1]['subCategory']}        SERVICE
    Should Be Equal As Strings  ${resp.json()[1]['text']}               Disabled service Bridal Makeupsss
    Should Be Equal As Strings  ${resp.json()[2]['Category']}           SETTINGS
    Should Be Equal As Strings  ${resp.json()[2]['subCategory']}        SERVICE
    Should Be Equal As Strings  ${resp.json()[2]['text']}               Created service Bridal Makeupsss

JD-TC-GetAuditLog -23
    [Documentation]   Provider get Audit log when date=date and category-eq=SETTINGS  and subCategory-eq=HOLIDAY

    ${resp}=   Encrypted Provider Login  ${PUSERNAME166}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${resp}=   Get Audit Logs  date-eq=${DAY1}  category-eq=SETTINGS  subCategory-eq=HOLIDAY
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['Category']}           SETTINGS
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}        HOLIDAY
    Should Be Equal As Strings  ${resp.json()[0]['text']}               Created a non working day

JD-TC-GetAuditLog -24
    [Documentation]   Provider get Audit log when date=date and category-eq=SETTINGS  and subCategory-eq=WAITLIST

    ${resp}=   Encrypted Provider Login  ${PUSERNAME165}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${resp}=   Get Audit Logs  date-eq=${DAY1}  category-eq=SETTINGS  subCategory-eq=WAITLIST
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['Category']}           SETTINGS
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}        WAITLIST
    Should Be Equal As Strings  ${resp.json()[0]['text']}               Updated Q manager Settings

# JD-TC-GetAuditLog -25
#     [Documentation]   Provider get Audit log when date=date and category-eq=SETTINGS  and subCategory-eq=PAYMENT

#     ${resp}=   Encrypted Provider Login  ${PUSERNAME167}  ${PASSWORD} 
#     Should Be Equal As Strings    ${resp.status_code}   200 
#     ${acct_id1}=  get_acc_id  ${PUSERNAME167}
#     ${pan_number}=   Generate_pan_number
#     ${bank_acc_no}=  Generate_random_value   size=11   chars=${digits} 
#     ${bank_name}=    FakerLibrary.company
#     ${ifsc_code}=    Generate_ifsc_code
#     ${name}=         FakerLibrary.name
#     ${branch_city}=  get_place
#     ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${EMPTY}  ${pan_number}  ${bank_acc_no}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch_city}  Individual  Saving   
#     Should Be Equal As Strings    ${resp.status_code}   200
#     ${resp}=  payuVerify  ${acct_id1}   
#     ${resp}=   Get Audit Logs  date-eq=${DAY1}  category-eq=SETTINGS  subCategory-eq=PAYMENT
#     Should Be Equal As Strings  ${resp.status_code}   200
#     Should Be Equal As Strings  ${resp.json()[0]['Category']}           SETTINGS
#     Should Be Equal As Strings  ${resp.json()[0]['subCategory']}        PAYMENT
#     Should Be Equal As Strings  ${resp.json()[0]['text']}               Updated payment settings 


JD-TC-GetAuditLog -26
    [Documentation]   Provider get Audit log when date=date and category-eq=SETTINGS  and subCategory-eq=COUPOUN

    ${resp}=   Encrypted Provider Login  ${PUSERNAME165}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    # ${coupon}=   FakerLibrary.word 
    # ${desc}=     FakerLibrary.word
    # ${price}=    FakerLibrary.pyfloat   left_digits=2  right_digits=2    positive=${bool[1]}
    # ${calc_type}=  Random Element   ['Fixed', 'Percentage']
    # ${resp}=  Create Coupon  ${coupon}  ${desc}  ${price}  ${calc_type}
    # Log    ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${description}=  FakerLibrary.sentence
    ${ser_durtn}=   Random Int   min=2   max=10
    ${ser_amount}=   Random Int   min=100   max=1000
    ${ser_amount1}=   Convert To Number   ${ser_amount}
    ${SERVICE1}=    FakerLibrary.word
    ${resp}=  Create Service  ${SERVICE1}   ${description}   ${ser_durtn}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${ser_amount1}  ${bool[0]}   ${bool[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${sid1}  ${resp.json()}

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${price}=    FakerLibrary.pyfloat   left_digits=2  right_digits=2    positive=${bool[1]}
    ${cupn_code}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code}
    ${calc_type}=  Random Element   ['Fixed', 'Percentage']
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=100   max=150
    ${max_disc_val}=   Random Int   min=100   max=500
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[0]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${sid1}  
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${price}  ${calc_type}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[1]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId}  ${resp.json()}

    ${resp}=   Get Audit Logs  date-eq=${DAY1}  category-eq=SETTINGS  subCategory-eq=COUPOUN
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['Category']}           SETTINGS
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}        COUPOUN
    Should Be Equal As Strings  ${resp.json()[0]['text']}               Created coupon ${coupon}

JD-TC-GetAuditLog -27
    [Documentation]   Provider get Audit log when date=date and category-eq=SETTINGS  and subCategory-eq=ITEM 


    ${resp}=  Encrypted Provider Login  ${PUSERNAME165}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${item}=     FakerLibrary.word
    ${itemCode1}=     FakerLibrary.word
    ${desc}=     FakerLibrary.word
    ${desc1}=    FakerLibrary.sentence
    ${price}=  Random Int  min=10   max=100
    # ${price}=    FakerLibrary.pyfloat   left_digits=3  right_digits=3    positive=${bool[1]}
    # ${resp}=  Create Item   ${item}  ${desc}  ${desc1}  ${price}  ${bool[0]} 
    ${resp}=  Create Sample Item   ${DisplayName1}   ${item}  ${itemCode1}  ${price}  ${bool[0]}    
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME165}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=   Get Audit Logs  date-eq=${DAY1}  category-eq=SETTINGS  subCategory-eq=ITEM
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['Category']}           SETTINGS
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}        ITEM
    Should Be Equal As Strings  ${resp.json()[0]['text']}               Created item ${DisplayName1}


JD-TC-GetAuditLog -28
    [Documentation]   Provider get Audit log when date=date and category-eq=SETTINGS  and subCategory-eq=ADDWORD

    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    ${PUSERNAME}=  Evaluate  ${PUSERNAME}+400022
    Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${PUSERNAME}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME}${\n}  
    ${addword}=   FakerLibrary.word  

    ${p1_l1}=  Create Sample Location

    ${resp}=  Add Adword  ${addword} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=   Get Audit Logs  date-eq=${DAY1}  category-eq=SETTINGS  subCategory-eq=ADDWORD
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['Category']}           SETTINGS
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}        ADDWORD
    Should Be Equal As Strings  ${resp.json()[0]['text']}               Created Jaldee keyword ${addword}

JD-TC-GetAuditLog -29
    [Documentation]   Provider get Audit log when date=date and category-eq=SETTINGS  and subCategory-eq=DISCOUNT

    ${resp}=  Encrypted Provider Login  ${PUSERNAME165}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}   200 
    ${discount}=   FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${disc_value}=  Random Int   min=1   max=100
    ${calc_type}=  Random Element   ['Fixed', 'Percentage']
    ${resp}=   Create Discount  ${discount}   ${desc}    ${disc_value}   ${calc_type}   ${disc_type}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Audit Logs  date-eq=${DAY1}  category-eq=SETTINGS  subCategory-eq=DISCOUNT
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['Category']}           SETTINGS
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}        DISCOUNT
    Should Be Equal As Strings  ${resp.json()[0]['text']}               Created discount ${discount}

JD-TC-GetAuditLog -30
    [Documentation]   Provider get Audit log when date=date and category-eq=LICENSE  and subCategory-eq=ADDON

    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    ${PUSERNAME}=  Evaluate  ${PUSERNAME}+4111222
    Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${PUSERNAME}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME}${\n}  

    ${p1_l1}=  Create Sample Location

    ${resp}=  Get Addons Metadata
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${addon_id}      ${resp.json()[0]['addons'][0]['addonId']}
    Set Suite Variable   ${addon_name}    ${resp.json()[0]['addons'][0]['addonName']}
    ${resp}=   Add addon   ${addon_id}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=   Get Audit Logs  date-eq=${DAY1}  category-eq=LICENSE  subCategory-eq=ADDON
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['Category']}           LICENSE
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}        ADDON
    Should Be Equal As Strings  ${resp.json()[0]['text']}               Added an addon '${addon_name}'

JD-TC-GetAuditLog -31
    [Documentation]   Provider get Audit log when date=date and category-eq=LICENSE  and subCategory-eq=ADDON (Auditlog after addon change)

    ${resp}=   Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get upgradable addons
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${upaddon_id}      ${resp.json()[0]['addons'][0]['addonId']}
    Set Test Variable    ${upaddon_name}    ${resp.json()[0]['addons'][0]['addonName']}
    ${resp}=   Add addon   ${upaddon_id}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p1_l1}=  Create Sample Location

    ${resp}=  Get Location By Id  ${p1_l1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    # ${Time}=  db.get_time_by_timezone  ${tz}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${Time}=  db.get_time_by_timezone  ${tz}
    ${resp}=   Get Audit Logs  date-eq=${DAY1}  category-eq=LICENSE  subCategory-eq=ADDON
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['Category']}           LICENSE
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}        ADDON
    Should Be Equal As Strings  ${resp.json()[0]['text']}               Upgraded addon from '${addon_name}' to '${upaddon_name}'


JD-TC-GetAuditLog -32
    [Documentation]   Provider get Audit log when date=date and category-eq=LICENSE  and subCategory-eq=LICENSE

    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    ${PUSERNAME}=  Evaluate  ${PUSERNAME}+45587
    Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${lowest_package}=  get_lowest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME}   ${lowest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${PUSERNAME}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME}${\n} 
    ${resp}=  Get upgradable license
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${pkg_id}     ${resp.json()[0]['pkgId']}
    Set Test Variable   ${pkg_name}   ${resp.json()[0]['pkgName']}

    ${p1_l1}=  Create Sample Location

    ${resp}=  Get Location By Id  ${p1_l1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    # ${Time}=  db.get_time_by_timezone  ${tz}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Change License Package   ${pkg_id} 
    ${resp}=   Get Audit Logs  date-eq=${DAY1}  category-eq=LICENSE  subCategory-eq=LICENSE
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['Category']}           LICENSE
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}        LICENSE
    Should Be Equal As Strings  ${resp.json()[0]['text']}   	        Changed subscription plan from ${lowest_package[1]} to ${pkg_name}

JD-TC-GetAuditLog -33
    [Documentation]   Provider get Audit log when date=date and category-eq=SETTINGS  and subCategory-eq=ACCOUNT

    ${resp}=  Encrypted Provider Login  ${PUSERNAME169}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}   200 
    ${resp}=  Provider Change Password  ${PASSWORD}  ${NPASS}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get Audit Logs  date-eq=${DAY1}  category-eq=SETTINGS  subCategory-eq=ACCOUNT
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['Category']}           SETTINGS
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}        ACCOUNT
    Should Be Equal As Strings  ${resp.json()[0]['text']}               Change Password
    ${resp}=  Provider Change Password  ${NPASS}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetAuditLog -34
    [Documentation]   Provider get Audit log when date=date and category-eq=SETTINGS  and subCategory-eq=TAX

    ${resp}=  Encrypted Provider Login  ${PUSERNAME170}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}   200 
    ${resp}=  Generate_gst_number   ${Container_id}
    Set Test Variable   ${gst_no1}    ${resp[0]}
    ${resp}=  Update Tax Percentage  ${gstpercentage[1]}  ${gst_no1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=   Get Audit Logs  date-eq=${DAY1}  category-eq=SETTINGS  subCategory-eq=TAX
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['Category']}           SETTINGS
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}        TAX
    Should Be Equal As Strings  ${resp.json()[0]['text']}               Updated tax to ${gstpercentage[1]}% 

JD-TC-GetAuditLog -35
    [Documentation]   Provider get Audit log when add a customer with email

    ${resp}=  Encrypted Provider Login  ${PUSERNAME171}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${fname}=   FakerLibrary.first_name
    ${lname}=   FakerLibrary.last_name
    ${dob}=     FakerLibrary.date
    ${gender}=    Random Element    ${Genderlist}
    ${PUSERPH26}=  Evaluate  ${PUSERNAME}+475638
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH26}${\n}
    Set Test Variable   ${PUSERPH26}
    Set Test Variable  ${email}  ${fname}${PUSERPH26}${C_Email}.${test_mail}
    ${resp}=  AddCustomer with email  ${fname}  ${lname}  ${EMPTY}  ${email}  ${gender}  ${dob}  ${PUSERPH26}   ${EMPTY}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${customerId}  ${resp.json()}
    ${resp}=   Get Audit Logs
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['Category']}           SETTINGS
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}        ACCOUNT
    Should Be Equal As Strings  ${resp.json()[0]['text']}               Created a new client with Mobile no +91 ${PUSERPH26}
    # Should Be Equal As Strings  ${resp.json()[0]['subject']}            Provider client  creation
    Should Contain   "${resp.json()}"   subject  :  Provider client  creation
                                                                        
JD-TC-GetAuditLog -36
    [Documentation]   Provider get Audit log when add a customer without email

    ${resp}=  Encrypted Provider Login  ${PUSERNAME171}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${fname}=   FakerLibrary.first_name
    ${lname}=   FakerLibrary.last_name
    ${dob}=     FakerLibrary.date
    ${gender}=    Random Element    ${Genderlist}
    ${PUSERPH27}=  Evaluate  ${PUSERNAME}+475574
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH27}${\n}
    Set Test Variable   ${PUSERPH27}
    ${resp}=  AddCustomer without email  ${fname}  ${lname}  ${EMPTY}  ${gender}  ${dob}  ${PUSERPH27}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${customerId}  ${resp.json()}
    ${resp}=   Get Audit Logs
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['Category']}           SETTINGS
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}        ACCOUNT
    Should Be Equal As Strings  ${resp.json()[0]['text']}               Created a new client with Mobile no +91 ${PUSERPH27}
    # Should Be Equal As Strings  ${resp.json()[0]['subject']}            Provider client  creation
    Should Contain   "${resp.json()}"   subject  :  Provider client  creation




JD-TC-GetAuditLog -UH1
    [Documentation]   get Auditlog  without login

    ${resp}=   Get Audit Logs
    Should Be Equal As Strings   ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
       
JD-TC-GetAuditLog -UH2
    [Documentation]   Consumer get AuditLog

    ${resp}=   Consumer Login  ${CUSERNAME4}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=   Get Audit Logs
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

    sleep  2s
JD-TC-Verify GetAuditLog -21
    [Documentation]   Verify Provider get Audit log when date=date and category-eq=SETTINGS  and subCategory-eq=QUEUE

    ${resp}=   Encrypted Provider Login  ${PUSERNAME164}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${resp}=   Get Audit Logs  date-eq=${DAY1}  category-eq=SETTINGS  subCategory-eq=QUEUE
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['Category']}           SETTINGS
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}        QUEUE
    Should Be Equal As Strings  ${resp.json()[0]['text']}               Enabled a service time window
    Should Be Equal As Strings  ${resp.json()[1]['Category']}           SETTINGS
    Should Be Equal As Strings  ${resp.json()[1]['subCategory']}        QUEUE
    Should Be Equal As Strings  ${resp.json()[1]['text']}               Disabled a service time window
    Should Be Equal As Strings  ${resp.json()[2]['Category']}           SETTINGS
    Should Be Equal As Strings  ${resp.json()[2]['subCategory']}        QUEUE
    Should Be Equal As Strings  ${resp.json()[2]['text']}               Updated a service time window
    Should Be Equal As Strings  ${resp.json()[3]['Category']}           SETTINGS
    Should Be Equal As Strings  ${resp.json()[3]['subCategory']}        QUEUE
    Should Be Equal As Strings  ${resp.json()[3]['text']}               Created a service time window

JD-TC-Verify GetAuditLog -5
    [Documentation]   Verify Provider get Audit log after disable a location

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    ${resp}=   Get Audit Logs
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[1]['date']}       ${DAY1}
    Variable Should exist       ${resp.json()[1]['time']}       ${converted_time}
    Should Contain  "${resp.json()}"                            subject  :  Location disabled
    Should Contain  "${resp.json()}"                             text  :  Disabled a location
    Should Be Equal As Strings  ${resp.json()[1]['Action']}     DELETE
    Should Be Equal As Strings  ${resp.json()[1]['userType']}   PROVIDER 

JD-TC-Verify GetAuditLog -14
    [Documentation]   Verify Provider get Audit log after holiday creation

    ${resp}=  Encrypted Provider Login  ${PUSERNAME166}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Get Audit Logs  date-eq=${DAY1}  category-eq=SETTINGS  subCategory-eq=HOLIDAY
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                 200
    Should Be Equal As Strings  ${resp.json()[0]['date']}           ${DAY1}
    Variable Should exist       ${resp.json()[0]['time']}           ${convert_time}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}        Non working day created
    Should Be Equal As Strings  ${resp.json()[0]['text']}           Created a non working day     
    Should Be Equal As Strings  ${resp.json()[0]['Action']}         ADD

JD-TC-GetAuditLog-40
    [Documentation]    get auditlog for appointment delay

    ${resp}=    Consumer Login   ${CUSERNAME10}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME149}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    clear_service   ${PUSERNAME149}
    clear_location  ${PUSERNAME149}
    clear_customer   ${PUSERNAME149}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]} 

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']} 

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${PUSERNAME149}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    #  ${eTime1}=  add_timezone_time  ${tz}  3  30  
    # Set Suite Variable   ${eTime1}
    # Set Test Variable  ${qTime}   ${sTime1}-${eTime1}

    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}   0  200
    ${delta}=  FakerLibrary.Random Int  min=1  max=20
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${s_id}=  Create Sample Service  ${SERVICE12}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME10}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId1}

    ${resp}=  AddCustomer  ${CUSERNAME11}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}   ${resp.json()}
    
    ${apptfor2}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor1}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid2}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId2}
    
    ${delaytime}=    Random Int  min=20    max=60
    ${delaymessage}=    FakerLibrary.Sentence   nb_words=4

    ${resp}=    Add Delay on Multiple Appointments    ${delaytime}  ${bool[0]}  ${delaymessage}    ${bool[1]}    ${bool[1]}    ${bool[1]}    ${bool[1]}    ${apptid1}    ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings    ${resp.json()['isAddToDelay']}    ${bool[0]}
    # Should Be Equal As Strings    ${resp.json()['apptDelay']}    ${delaytime}
    # Should Be Equal As Strings    ${resp.json()['apptDelayMessag']}    ${delaymessage}
    # Verify Response List   ${resp}  0  uid=${apptid1}
    # Verify Response List   ${resp}  1  uid=${apptid2}
    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}   ${encId1}
    Should Be Equal As Strings  ${resp.json()[0]['apptDelay']}   ${delaytime}
    
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId2}
    Should Be Equal As Strings  ${resp.json()['apptDelay']}   ${delaytime}
    
    ${time}=   db.get_time_by_timezone  ${tz}
    ${converted_time1}=  db.timeto24hr   ${time}

    ${resp}=   Get Audit Logs
    Should Be Equal As Strings  ${resp.status_code}                 200
    Should Be Equal As Strings  ${resp.json()[0]['date']}           ${DAY1}
    Variable Should exist       ${resp.json()[0]['time']}           ${converted_time1}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}       	Appointment Delay
    Should Be Equal As Strings  ${resp.json()[0]['text']}           Added delay of ${delaytime} mins to slot ${slot1}
    Should Be Equal As Strings  ${resp.json()[0]['Action']}         ADD


JD-TC-GetAuditLog-41
    [Documentation]   get auditlog delay add in waitlist
    ${resp}=  Encrypted Provider Login  ${PUSERNAME136}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    Set Test Variable  ${bname}  ${decrypted_data['userName']}

    ${resp}=   Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${buss_name}  ${resp.json()['businessName']}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${pid1}=  get_acc_id  ${PUSERNAME136}
    clear_service   ${PUSERNAME136}
    clear_location  ${PUSERNAME136}
    clear_queue  ${PUSERNAME136}
    clear_customer   ${PUSERNAME136}
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  0  true  true  true  true  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    # ${city}=   FakerLibrary.state
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
    ${parking}    Random Element     ${parkingType}
    Set Suite Variable  ${parking}
    ${24hours}    Random Element    ${bool}
    Set Suite Variable  ${24hours}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  70      
    Set Suite Variable  ${DAY2}
    ${sTime}=  add_timezone_time  ${tz}  5  15  
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  6  30  
    Set Suite Variable   ${eTime}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking}  ${24hours}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()}
    
    ${sTime1}=  subtract_timezone_time  ${tz}  2  00
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  3  30  
    Set Suite Variable   ${eTime1}
    Set Test Variable  ${qTime}   ${sTime1}-${eTime1}
    ${SERVICE1}=  FakerLibrary.name
    Set Suite Variable   ${SERVICE1} 
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id1}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    clear_Consumermsg  ${CUSERNAME31}
    clear_Consumermsg  ${CUSERNAME3}

    ${resp}=  Get Consumer By Id  ${CUSERNAME31}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${uname_c20}   ${resp.json()['userProfile']['firstName']} ${resp.json()['userProfile']['lastName']}
    Set Suite Variable  ${cname1}   ${resp.json()['userProfile']['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['userProfile']['lastName']}

    ${resp}=  AddCustomer  ${CUSERNAME31}  firstName=${cname1}   lastName=${lname1}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${waitlist_id}  ${wid[0]}

    ${resp}=   Get Waitlist EncodedId    ${waitlist_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Set Suite Variable  ${W_encId1}  ${resp.json()}
    
    ${resp}=  Get Consumer By Id  ${CUSERNAME3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${uname_c21}   ${resp.json()['userProfile']['firstName']} ${resp.json()['userProfile']['lastName']}
    Set Suite Variable  ${cname2}   ${resp.json()['userProfile']['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['userProfile']['lastName']}

    ${resp}=  AddCustomer  ${CUSERNAME3}  firstName=${cname2}   lastName=${lname2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid2}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid2}  ${s_id1}  ${qid}  ${DAY1}  ${desc}  ${bool[1]}  ${cid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${waitlist_id2}  ${wid[0]}

    ${resp}=   Get Waitlist EncodedId    ${waitlist_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Set Suite Variable  ${W_encId2}  ${resp.json()}
    # sleep  02s
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${waitlist_id}
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}  0
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${waitlist_id2}
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}  2
    
    ${resp}=  Waitlist Action  STARTED  ${waitlist_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=  Get Waitlist By Id  ${waitlist_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=started

    ${resp}=  Get Consumer By Id  ${CUSERNAME4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${uname_c22}   ${resp.json()['userProfile']['firstName']} ${resp.json()['userProfile']['lastName']}
    Set Suite Variable  ${cname3}   ${resp.json()['userProfile']['firstName']}
    Set Suite Variable  ${lname3}   ${resp.json()['userProfile']['lastName']}

    ${resp}=  AddCustomer  ${CUSERNAME4}   firstName=${cname3}   lastName=${lname3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid3}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid3}  ${s_id1}  ${qid}  ${DAY1}  ${desc}  ${bool[1]}  ${cid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${waitlist_id3}  ${wid[0]}

    ${resp}=   Get Waitlist EncodedId    ${waitlist_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Set Suite Variable  ${W_encId3}  ${resp.json()}

    clear_Consumermsg  ${CUSERNAME4}
    ${delay_time}=   Random Int  min=5   max=40
    ${prov_msg}=   FakerLibrary.word
    ${resp}=  Add Delay  ${qid}  ${delay_time}  ${prov_msg}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Delay  ${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  delayDuration=${delay_time}
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${bname1}  ${resp.json()['businessName']}

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmwl_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 
    ${defDelayAdd_msg}=  Set Variable   ${resp.json()['delayMessages']['Consumer_APP']}

    ${time}=   db.get_time_by_timezone  ${tz}
    ${converted_time1}=  db.timeto24hr   ${time}

    ${resp}=   Get Audit Logs
    Should Be Equal As Strings  ${resp.status_code}                 200
    Should Be Equal As Strings  ${resp.json()[0]['date']}           ${DAY1}
    Variable Should exist       ${resp.json()[0]['time']}           ${converted_time1}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}       	Booking Delay
    Should Be Equal As Strings  ${resp.json()[0]['text']}           Added delay of ${delaytime} mins 
    Should Be Equal As Strings  ${resp.json()[0]['Action']}         ADD



JD-TC-GetAuditLog -42

    [Documentation]   Provider get Audit log after provider login(us timezone)
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
    ${resp}=  Account SignUp  ${fname}  ${lname}  ${None}  ${domain}  ${subdomain}  ${USProvider}  ${licpkgid}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${USProvider}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${USProvider}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${USProvider}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  01s
    ${resp}=  Encrypted Provider Login  ${USProvider}  ${PASSWORD}
    Log   ${resp.content}
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
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${USProvider}.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    ${address} =  FakerLibrary.address
    ${postcode}=  FakerLibrary.postcode
    ${latti}  ${longi}  ${city}  ${country_abbr}  ${US_tz}=  FakerLibrary.Local Latlng  country_code=US  coords_only=False
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

    ${resp}=  Encrypted Provider Login  ${USProvider}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${US_tz}
    ${time}=   db.get_time_by_timezone  ${US_tz}
    ${converted_time1}=  db.timeto24hr   ${time}

    ${resp}=   Get Audit Logs
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['date']}       ${DAY1}
    Variable Should exist       ${resp.json()[0]['time']}       ${converted_time1}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Logged in
    Should Be Equal As Strings  ${resp.json()[0]['text']}       Login
    Should Be Equal As Strings  ${resp.json()[0]['Action']}     ADD
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   PROVIDER
  

*** Comments ***
JD-TC-GetAuditLog -37
    Comment   Provider get Audit log when Update a customer
    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  UpdateCustomer  Anu  Jejo  ${ph}  1994-02-06  female  ${None}  ${customerId}   
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Audit Logs
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['Category']}  SETTINGS
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}  ACCOUNT
    Should Be Equal As Strings  ${resp.json()[0]['text']}   Created a new consumer with Mobile no 1900663400
    Should Be Equal As Strings  ${resp.json()[0]['subject']}  Customer creation
    
    
JD-TC-GetAuditLog -38
    Comment   Provider get Audit log when delete a customer
    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  DeleteCustomer  ${customerId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Audit Logs
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['Category']}  SETTINGS
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}  ACCOUNT
    Should Be Equal As Strings  ${resp.json()[0]['text']}   Created a new consumer with Mobile no 1900663400
    Should Be Equal As Strings  ${resp.json()[0]['subject']}  Customer creation

*** Comments ***
    JD-TC-GetAuditLog -17
    Comment   Provider get Audit log when date=date and action=ADD
    ${resp}=   Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200    
    ${resp}=   Get Audit Logs  date-eq=${DAY1}  action-eq=ADD
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['text']}  Created a non working day     
    Should Be Equal As Strings  ${resp.json()[0]['Action']}  ADD
    Should Be Equal As Strings  ${resp.json()[1]['text']}  Added delay of 30 mins
    Should Be Equal As Strings  ${resp.json()[1]['Action']}  ADD
    Should Be Equal As Strings  ${resp.json()[2]['text']}  Created a queue
    Should Be Equal As Strings  ${resp.json()[2]['Action']}  ADD
    Should Be Equal As Strings  ${resp.json()[3]['text']}   Created a location
    Should Be Equal As Strings  ${resp.json()[3]['Action']}  ADD
    Should Be Equal As Strings  ${resp.json()[4]['text']}  Created service Bridal Makeupsss with duration 30 mins
    Should Be Equal As Strings  ${resp.json()[4]['Action']}  ADD
    Should Be Equal As Strings  ${resp.json()[5]['text']}  Login
    Should Be Equal As Strings  ${resp.json()[5]['Action']}  ADD
