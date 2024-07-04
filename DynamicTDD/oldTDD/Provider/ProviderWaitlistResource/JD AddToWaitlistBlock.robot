*** Settings ***
Suite Teardown    Delete All Sessions 
Test Teardown     Delete All Sessions
Force Tags        Waitlist Block
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${SERVICE1}               SERVICE1
${SERVICE2}               SERVICE2
${SERVICE3}               SERVICE3
${SERVICE4}               SERVICE4
${SERVICE5}               SERVICE3
${SERVICE6}               SERVICE4
${sample}                     4452135820

*** Test Cases ***

JD-TC-AddToWaitlistBlock-1
    [Documentation]   Block a waitlist for one user.

    clear_queue      ${PUSERNAME101}
    clear_location   ${PUSERNAME101}
    clear_service    ${PUSERNAME101}
    clear_customer   ${PUSERNAME101}
    clear_service  ${PUSERNAME101}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${loc_id1}=   Create Sample Location
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_id1}=   Create Sample Service  ${SERVICE1}
    
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY} 
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}
    ${desc}=   FakerLibrary.word

    ${fname}=  FakerLibrary.firstname
    ${lname}=  FakerLibrary.lastname

    ${wt_for1}=  Create Dictionary  firstName=${fname}   lastName=${lname}
    ${wt_for}=   Create List  ${wt_for1}
    
    ${resp}=  Add To Waitlist Block  ${que_id1}  ${ser_id1}  ${service_type[2]}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${wt_for}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname}

JD-TC-AddToWaitlistBlock-2
    [Documentation]   Block a waitlist for multple users.

    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    Set Suite Variable  ${dom}  ${domresp.json()[1]['domain']}
    Set Suite Variable  ${sub_dom}  ${domresp.json()[1]['subDomains'][0]['subDomain']}
   
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+55976
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_C}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_C}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_C}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_C}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_C}${\n}
    Set Test Variable  ${PUSERNAME_C}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_C}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_C}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
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
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
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
    
    clear_location   ${PUSERNAME_C}
    
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${loc_id1}=   Create Sample Location

    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${ser_id1}  ${resp.json()}

    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    Set Suite Variable    ${end_time}   
    ${parallel}=   Random Int  min=1   max=1
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=10   max=20
    Set Suite Variable   ${capacity}
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}

    ${fname1}=  FakerLibrary.firstname
    ${lname1}=  FakerLibrary.lastname

    ${fname2}=  FakerLibrary.firstname
    ${lname2}=  FakerLibrary.lastname

    ${fname3}=  FakerLibrary.firstname
    ${lname3}=  FakerLibrary.lastname

    ${fname4}=  FakerLibrary.firstname
    ${lname4}=  FakerLibrary.lastname

    ${fname5}=  FakerLibrary.firstname
    ${lname5}=  FakerLibrary.lastname

    ${wt_for1}=  Create Dictionary  firstName=${fname1}   lastName=${lname1}
    ${wt_for2}=  Create Dictionary  firstName=${fname2}   lastName=${lname2}
    ${wt_for3}=  Create Dictionary  firstName=${fname3}   lastName=${lname3}
    ${wt_for4}=  Create Dictionary  firstName=${fname4}   lastName=${lname4}
    ${wt_for5}=  Create Dictionary  firstName=${fname5}   lastName=${lname5}
    ${wt_for}=   Create List  ${wt_for1}   ${wt_for2}  ${wt_for3}  ${wt_for4}  ${wt_for5}
    
    ${resp}=  Add To Waitlist Block  ${que_id1}  ${ser_id1}  ${service_type[2]}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${wt_for}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    Set Test Variable  ${wid2}  ${wid[1]}
    Set Test Variable  ${wid3}  ${wid[2]}
    Set Test Variable  ${wid4}  ${wid[3]}
    Set Test Variable  ${wid5}  ${wid[4]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname1}

    ${appxWaitingTime}=  Evaluate   ${srv_duration} * 1

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname2}

    ${appxWaitingTime}=  Evaluate   ${srv_duration} * 2

    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname3}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname3}

    ${appxWaitingTime}=  Evaluate   ${srv_duration} * 3

    ${resp}=  Get Waitlist By Id  ${wid4} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname4}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname4}

    ${appxWaitingTime}=  Evaluate   ${srv_duration} * 4

    ${resp}=  Get Waitlist By Id  ${wid5} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname5}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname5}

JD-TC-AddToWaitlistBlock-3
    [Documentation]   Block two waitlist for same user with different service in the same queue.

    clear_queue      ${PUSERNAME102}
    clear_location   ${PUSERNAME102}
    clear_service    ${PUSERNAME102}
    clear_customer   ${PUSERNAME102}
    clear_service  ${PUSERNAME102}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME102}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${loc_id1}=   Create Sample Location
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_id1}=   Create Sample Service  ${SERVICE1}
    
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${ser_id2}=   Create Sample Service  ${SERVICE2}
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}
    ${desc}=   FakerLibrary.word

    ${fname}=  FakerLibrary.firstname
    ${lname}=  FakerLibrary.lastname

    ${wt_for1}=  Create Dictionary  firstName=${fname}   lastName=${lname}
    ${wt_for}=   Create List  ${wt_for1}
    
    ${resp}=  Add To Waitlist Block  ${que_id1}  ${ser_id1}  ${service_type[2]}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${wt_for}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname}

    ${resp}=  Add To Waitlist Block  ${que_id1}  ${ser_id2}  ${service_type[2]}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${wt_for}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=2  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname}
    

JD-TC-AddToWaitlistBlock-4
    [Documentation]   Block two waitlist for differnet users for same service.

    clear_queue      ${PUSERNAME103}
    clear_location   ${PUSERNAME103}
    clear_service    ${PUSERNAME103}
    clear_customer   ${PUSERNAME103}
    clear_service  ${PUSERNAME103}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME103}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${loc_id1}=   Create Sample Location
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_id1}=   Create Sample Service  ${SERVICE1}
    
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}
    ${desc}=   FakerLibrary.word

    ${fname}=  FakerLibrary.firstname
    ${lname}=  FakerLibrary.lastname

    ${wt_for1}=  Create Dictionary  firstName=${fname}   lastName=${lname}
    ${wt_for}=   Create List  ${wt_for1}
    
    ${resp}=  Add To Waitlist Block  ${que_id1}  ${ser_id1}  ${service_type[2]}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${wt_for}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname}

    ${fname1}=  FakerLibrary.firstname
    ${lname1}=  FakerLibrary.lastname

    ${wt_for1}=  Create Dictionary  firstName=${fname1}   lastName=${lname1}
    ${wt_for}=   Create List  ${wt_for1}

    ${resp}=  Add To Waitlist Block  ${que_id1}  ${ser_id1}  ${service_type[2]}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${wt_for}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=2  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname1}
    
JD-TC-AddToWaitlistBlock-5
    [Documentation]   Block two waitlist for same user with same service.

    clear_queue      ${PUSERNAME102}
    clear_location   ${PUSERNAME102}
    clear_service    ${PUSERNAME102}
    clear_customer   ${PUSERNAME102}
    clear_service  ${PUSERNAME102}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME102}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${loc_id1}=   Create Sample Location
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_id1}=   Create Sample Service  ${SERVICE1}
    
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${ser_id2}=   Create Sample Service  ${SERVICE2}
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}
    ${desc}=   FakerLibrary.word

    ${fname}=  FakerLibrary.firstname
    ${lname}=  FakerLibrary.lastname

    ${wt_for1}=  Create Dictionary  firstName=${fname}   lastName=${lname}
    ${wt_for}=   Create List  ${wt_for1}
    
    ${resp}=  Add To Waitlist Block  ${que_id1}  ${ser_id1}  ${service_type[2]}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${wt_for}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname}

    ${resp}=  Add To Waitlist Block  ${que_id1}  ${ser_id1}  ${service_type[2]}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${wt_for}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=2  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname}
*** Comments ***
JD-TC-AddToWaitlistBlock-6
    [Documentation]   Block two waitlist for multple users with same service.

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+55977
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_C}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_C}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_C}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_C}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_C}${\n}
    Set Test Variable  ${PUSERNAME_C}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_C}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_C}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
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
    ${eTime}=  add_timezone_time  ${tz}  5  45  
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
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
    
    clear_location   ${PUSERNAME_C}
    
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${loc_id1}=   Create Sample Location

    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${ser_id1}  ${resp.json()}

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  5  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${fname1}=  FakerLibrary.firstname
    ${lname1}=  FakerLibrary.lastname

    ${fname2}=  FakerLibrary.firstname
    ${lname2}=  FakerLibrary.lastname

    ${fname3}=  FakerLibrary.firstname
    ${lname3}=  FakerLibrary.lastname

    ${fname4}=  FakerLibrary.firstname
    ${lname4}=  FakerLibrary.lastname

    ${fname5}=  FakerLibrary.firstname
    ${lname5}=  FakerLibrary.lastname

    ${wt_for1}=  Create Dictionary  firstName=${fname1}   lastName=${lname1}
    ${wt_for2}=  Create Dictionary  firstName=${fname2}   lastName=${lname2}
    ${wt_for3}=  Create Dictionary  firstName=${fname3}   lastName=${lname3}
    ${wt_for4}=  Create Dictionary  firstName=${fname4}   lastName=${lname4}
    ${wt_for5}=  Create Dictionary  firstName=${fname5}   lastName=${lname5}
    ${wt_for}=   Create List  ${wt_for1}   ${wt_for2}  ${wt_for3}  ${wt_for4}  ${wt_for5}
    
    ${resp}=  Add To Waitlist Block  ${que_id1}  ${ser_id1}  ${service_type[2]}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${wt_for}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${json}=   evaluate    json.loads('''${resp.content}''', object_pairs_hook=collections.OrderedDict)    modules=json, collections
    # 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    Set Test Variable  ${wid2}  ${wid[1]}
    Set Test Variable  ${wid3}  ${wid[2]}
    Set Test Variable  ${wid4}  ${wid[3]}
    Set Test Variable  ${wid5}  ${wid[4]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname1}

    ${appxWaitingTime}=  Evaluate   ${srv_duration} * 1

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname2}

    ${appxWaitingTime}=  Evaluate   ${srv_duration} * 2

    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname3}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname3}

    ${appxWaitingTime}=  Evaluate   ${srv_duration} * 3

    ${resp}=  Get Waitlist By Id  ${wid4} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname4}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname4}

    ${appxWaitingTime}=  Evaluate   ${srv_duration} * 4

    ${resp}=  Get Waitlist By Id  ${wid5} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname5}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname5}

    ${fname11}=  FakerLibrary.firstname
    ${lname11}=  FakerLibrary.lastname

    ${fname21}=  FakerLibrary.firstname
    ${lname21}=  FakerLibrary.lastname

    ${fname31}=  FakerLibrary.firstname
    ${lname31}=  FakerLibrary.lastname

    ${fname41}=  FakerLibrary.firstname
    ${lname41}=  FakerLibrary.lastname

    ${fname51}=  FakerLibrary.firstname
    ${lname51}=  FakerLibrary.lastname

    ${wt_for11}=  Create Dictionary  firstName=${fname11}   lastName=${lname11}
    ${wt_for21}=  Create Dictionary  firstName=${fname21}   lastName=${lname21}
    ${wt_for31}=  Create Dictionary  firstName=${fname31}   lastName=${lname31}
    ${wt_for41}=  Create Dictionary  firstName=${fname41}   lastName=${lname41}
    ${wt_for51}=  Create Dictionary  firstName=${fname51}   lastName=${lname51}
    ${wt_for1}=   Create List  ${wt_for11}   ${wt_for21}  ${wt_for31}  ${wt_for41}  ${wt_for51}
    
    ${resp}=  Add To Waitlist Block  ${que_id1}  ${ser_id1}  ${service_type[2]}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${wt_for1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${json}=   evaluate    json.loads('''${resp.content}''', object_pairs_hook=collections.OrderedDict)    modules=json, collections
    ${wid1}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid11}  ${wid1[0]}
    Set Test Variable  ${wid21}  ${wid1[1]}
    Set Test Variable  ${wid31}  ${wid1[2]}
    Set Test Variable  ${wid41}  ${wid1[3]}
    Set Test Variable  ${wid51}  ${wid1[4]}

    ${resp}=  Get Waitlist By Id  ${wid11} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${appxWaitingTime}=  Evaluate   ${srv_duration} * 5

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname11}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname11}

    ${appxWaitingTime}=  Evaluate   ${srv_duration} * 6

    ${resp}=  Get Waitlist By Id  ${wid21} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname21}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname21}

    ${appxWaitingTime}=  Evaluate   ${srv_duration} * 7

    ${resp}=  Get Waitlist By Id  ${wid31} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname31}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname31}

    ${appxWaitingTime}=  Evaluate   ${srv_duration} * 8

    ${resp}=  Get Waitlist By Id  ${wid41} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname41}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname41}

    ${appxWaitingTime}=  Evaluate   ${srv_duration} * 9

    ${resp}=  Get Waitlist By Id  ${wid51} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname51}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname51}

JD-TC-AddToWaitlistBlock-7
    [Documentation]   Block two waitlist for multple users with different service in same queue.

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+55978
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_C}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_C}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_C}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_C}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_C}${\n}
    Set Test Variable  ${PUSERNAME_C}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_C}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_C}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
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
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
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
    
    clear_location   ${PUSERNAME_C}
    
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${loc_id1}=   Create Sample Location

    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${ser_id1}  ${resp.json()}
    
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration1}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${ser_id2}  ${resp.json()}

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}   ${ser_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${fname1}=  FakerLibrary.firstname
    ${lname1}=  FakerLibrary.lastname

    ${fname2}=  FakerLibrary.firstname
    ${lname2}=  FakerLibrary.lastname

    ${fname3}=  FakerLibrary.firstname
    ${lname3}=  FakerLibrary.lastname

    ${fname4}=  FakerLibrary.firstname
    ${lname4}=  FakerLibrary.lastname

    ${fname5}=  FakerLibrary.firstname
    ${lname5}=  FakerLibrary.lastname

    ${wt_for1}=  Create Dictionary  firstName=${fname1}   lastName=${lname1}
    ${wt_for2}=  Create Dictionary  firstName=${fname2}   lastName=${lname2}
    ${wt_for3}=  Create Dictionary  firstName=${fname3}   lastName=${lname3}
    ${wt_for4}=  Create Dictionary  firstName=${fname4}   lastName=${lname4}
    ${wt_for5}=  Create Dictionary  firstName=${fname5}   lastName=${lname5}
    ${wt_for}=   Create List  ${wt_for1}   ${wt_for2}  ${wt_for3}  ${wt_for4}  ${wt_for5}
    
    ${resp}=  Add To Waitlist Block  ${que_id1}  ${ser_id1}  ${service_type[2]}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${wt_for}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    Set Test Variable  ${wid2}  ${wid[1]}
    Set Test Variable  ${wid3}  ${wid[2]}
    Set Test Variable  ${wid4}  ${wid[3]}
    Set Test Variable  ${wid5}  ${wid[4]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname1}

    ${appxWaitingTime}=  Evaluate   ${srv_duration} * 1

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname2}

    ${appxWaitingTime}=  Evaluate   ${srv_duration} * 2

    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname3}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname3}

    ${appxWaitingTime}=  Evaluate   ${srv_duration} * 3

    ${resp}=  Get Waitlist By Id  ${wid4} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname4}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname4}

    ${appxWaitingTime}=  Evaluate   ${srv_duration} * 4

    ${resp}=  Get Waitlist By Id  ${wid5} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname5}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname5}

    ${fname11}=  FakerLibrary.firstname
    ${lname11}=  FakerLibrary.lastname

    ${fname21}=  FakerLibrary.firstname
    ${lname21}=  FakerLibrary.lastname

    ${fname31}=  FakerLibrary.firstname
    ${lname31}=  FakerLibrary.lastname

    ${fname41}=  FakerLibrary.firstname
    ${lname41}=  FakerLibrary.lastname

    ${fname51}=  FakerLibrary.firstname
    ${lname51}=  FakerLibrary.lastname

    ${wt_for11}=  Create Dictionary  firstName=${fname11}   lastName=${lname11}
    ${wt_for21}=  Create Dictionary  firstName=${fname21}   lastName=${lname21}
    ${wt_for31}=  Create Dictionary  firstName=${fname31}   lastName=${lname31}
    ${wt_for41}=  Create Dictionary  firstName=${fname41}   lastName=${lname41}
    ${wt_for51}=  Create Dictionary  firstName=${fname51}   lastName=${lname51}
    ${wt_for1}=   Create List  ${wt_for11}   ${wt_for21}  ${wt_for31}  ${wt_for41}  ${wt_for51}
    
    ${resp}=  Add To Waitlist Block  ${que_id1}  ${ser_id2}  ${service_type[2]}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${wt_for1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid11}  ${wid[0]}
    Set Test Variable  ${wid21}  ${wid[1]}
    Set Test Variable  ${wid31}  ${wid[2]}
    Set Test Variable  ${wid41}  ${wid[3]}
    Set Test Variable  ${wid51}  ${wid[4]}

    ${resp}=  Get Waitlist By Id  ${wid11} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname11}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname11}

    ${appxWaitingTime}=  Evaluate   ${srv_duration1} * 1

    ${resp}=  Get Waitlist By Id  ${wid21} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname21}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname21}

    ${appxWaitingTime}=  Evaluate   ${srv_duration1} * 2

    ${resp}=  Get Waitlist By Id  ${wid31} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname31}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname31}

    ${appxWaitingTime}=  Evaluate   ${srv_duration1} * 3

    ${resp}=  Get Waitlist By Id  ${wid41} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname41}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname41}

    ${appxWaitingTime}=  Evaluate   ${srv_duration1} * 4

    ${resp}=  Get Waitlist By Id  ${wid51} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname51}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname51}

JD-TC-AddToWaitlistBlock-8
    [Documentation]   Block two waitlist for multple users with different service in different queue.

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+55979
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_C}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_C}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_C}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_C}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_C}${\n}
    Set Test Variable  ${PUSERNAME_C}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_C}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_C}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
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
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
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
    
    clear_location   ${PUSERNAME_C}
    
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${loc_id1}=   Create Sample Location

    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${ser_id1}  ${resp.json()}
    
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration1}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${ser_id2}  ${resp.json()}

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  0  30  
    ${end_time}=    add_timezone_time  ${tz}  1  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}    ${ser_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id2}   ${resp.json()}

    ${fname1}=  FakerLibrary.firstname
    ${lname1}=  FakerLibrary.lastname

    ${fname2}=  FakerLibrary.firstname
    ${lname2}=  FakerLibrary.lastname

    ${fname3}=  FakerLibrary.firstname
    ${lname3}=  FakerLibrary.lastname

    ${fname4}=  FakerLibrary.firstname
    ${lname4}=  FakerLibrary.lastname

    ${fname5}=  FakerLibrary.firstname
    ${lname5}=  FakerLibrary.lastname

    ${wt_for1}=  Create Dictionary  firstName=${fname1}   lastName=${lname1}
    ${wt_for2}=  Create Dictionary  firstName=${fname2}   lastName=${lname2}
    ${wt_for3}=  Create Dictionary  firstName=${fname3}   lastName=${lname3}
    ${wt_for4}=  Create Dictionary  firstName=${fname4}   lastName=${lname4}
    ${wt_for5}=  Create Dictionary  firstName=${fname5}   lastName=${lname5}
    ${wt_for}=   Create List  ${wt_for1}   ${wt_for2}  ${wt_for3}  ${wt_for4}  ${wt_for5}
    
    ${resp}=  Add To Waitlist Block  ${que_id1}  ${ser_id1}  ${service_type[2]}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${wt_for}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    Set Test Variable  ${wid2}  ${wid[1]}
    Set Test Variable  ${wid3}  ${wid[2]}
    Set Test Variable  ${wid4}  ${wid[3]}
    Set Test Variable  ${wid5}  ${wid[4]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname1}

    ${appxWaitingTime}=  Evaluate   ${srv_duration} * 1

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname2}

    ${appxWaitingTime}=  Evaluate   ${srv_duration} * 2

    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname3}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname3}

    ${appxWaitingTime}=  Evaluate   ${srv_duration} * 3

    ${resp}=  Get Waitlist By Id  ${wid4} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname4}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname4}

    ${appxWaitingTime}=  Evaluate   ${srv_duration} * 4

    ${resp}=  Get Waitlist By Id  ${wid5} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname5}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname5}

    ${fname11}=  FakerLibrary.firstname
    ${lname11}=  FakerLibrary.lastname

    ${fname21}=  FakerLibrary.firstname
    ${lname21}=  FakerLibrary.lastname

    ${fname31}=  FakerLibrary.firstname
    ${lname31}=  FakerLibrary.lastname

    ${fname41}=  FakerLibrary.firstname
    ${lname41}=  FakerLibrary.lastname

    ${fname51}=  FakerLibrary.firstname
    ${lname51}=  FakerLibrary.lastname

    ${wt_for11}=  Create Dictionary  firstName=${fname11}   lastName=${lname11}
    ${wt_for21}=  Create Dictionary  firstName=${fname21}   lastName=${lname21}
    ${wt_for31}=  Create Dictionary  firstName=${fname31}   lastName=${lname31}
    ${wt_for41}=  Create Dictionary  firstName=${fname41}   lastName=${lname41}
    ${wt_for51}=  Create Dictionary  firstName=${fname51}   lastName=${lname51}
    ${wt_for1}=   Create List  ${wt_for11}   ${wt_for21}  ${wt_for31}  ${wt_for41}  ${wt_for51}
    
    ${resp}=  Add To Waitlist Block  ${que_id2}  ${ser_id2}  ${service_type[2]}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${wt_for1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid11}  ${wid[0]}
    Set Test Variable  ${wid21}  ${wid[1]}
    Set Test Variable  ${wid31}  ${wid[2]}
    Set Test Variable  ${wid41}  ${wid[3]}
    Set Test Variable  ${wid51}  ${wid[4]}

    ${resp}=  Get Waitlist By Id  ${wid11} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname11}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname11}

    ${appxWaitingTime}=  Evaluate   ${srv_duration1} * 1

    ${resp}=  Get Waitlist By Id  ${wid21} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname21}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname21}

    ${appxWaitingTime}=  Evaluate   ${srv_duration1} * 2

    ${resp}=  Get Waitlist By Id  ${wid31} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname31}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname31}

    ${appxWaitingTime}=  Evaluate   ${srv_duration1} * 3

    ${resp}=  Get Waitlist By Id  ${wid41} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname41}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname41}

    ${appxWaitingTime}=  Evaluate   ${srv_duration1} * 4

    ${resp}=  Get Waitlist By Id  ${wid51} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[8]}  partySize=1  appxWaitingTime=${appxWaitingTime}  waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname51}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname51}




































