***Settings***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Bill
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
${SERVICE1}  Makeup  
${SERVICE2}  Hairmakeup 
${SERVICE3}  Facialmakeup 
${SERVICE4}  Bridal makeup 
${SERVICE5}  Hair remove
${SERVICE6}  Bleach
${SERVICE7}  Hair cut
${country_code}   +91
${self}         0
${parallel}     1
${digits}       0123456789
@{EMPTY_List}
@{service_duration}   5   20


***Test Cases***

JD-TC-AppointmentByUserLoginAndBillGenarate -1
    [Documentation]  Create AppointmentByUserLogin and consumer do the bill payment (prepayment and Tax disable).
     ${iscorp_subdomains}=  get_iscorp_subdomains_with_maxpartysize  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+998914
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${MUSERNAME_E}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${MUSERNAME_E}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/providernumbers.txt  ${SUITE NAME} - ${TEST NAME} - ${MUSERNAME_E}${\n}
     Set Suite Variable  ${MUSERNAME_E}
     ${resp}=  Get Business Profile
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  status=INCOMPLETE
     
     ${list}=  Create List  1  2  3  4  5  6  7
     Set Suite Variable  ${list}  ${list}
     ${ph1}=  Evaluate  ${MUSERNAME_E}+1000000000
     ${ph2}=  Evaluate  ${MUSERNAME_E}+2000000000
     ${views}=  Random Element    ${Views}
     ${name1}=  FakerLibrary.name
     ${name2}=  FakerLibrary.name
     ${name3}=  FakerLibrary.name
     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
     ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
     ${bs}=  FakerLibrary.bs
     ${companySuffix}=  FakerLibrary.companySuffix
     # ${city}=   get_place
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
     ${sTime}=  add_timezone_time  ${tz}  0  15  
     Set Suite Variable   ${sTime}
     ${eTime}=  add_timezone_time  ${tz}  0  45  
     Set Suite Variable   ${eTime}

     ${DAY1}=  db.get_date_by_timezone  ${tz}
     Set Suite Variable  ${DAY1}  ${DAY1}
     
     ${resp}=  Update Business Profile With Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${fields}=   Get subDomain level Fields  ${domains}  ${sub_domains}
     Log  ${fields.json()}
     Should Be Equal As Strings    ${fields.status_code}   200

     ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

     ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_domains}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
     Should Be Equal As Strings    ${resp.status_code}   200

     ${spec}=  get_Specializations  ${resp.json()}
     ${resp}=  Update Specialization  ${spec}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}   200


     ${resp}=  Update Waitlist Settings  ${calc_mode[0]}   ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
     Should Be Equal As Strings  ${resp.status_code}  200
     
     ${resp}=  Enable Waitlist
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep   01s
     ${resp}=  Get jaldeeIntegration Settings
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]} 

     ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get jaldeeIntegration Settings
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

     ${resp}=  View Waitlist Settings
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200




    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment


    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200


    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]} 

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']} 

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${id}=  get_id  ${MUSERNAME_E}
    Set Suite Variable  ${id}
    ${bs}=  FakerLibrary.bs
    Set Suite Variable  ${bs}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    # ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+58730
    # clear_users  ${PUSERNAME_U1}
    # Set Suite Variable  ${PUSERNAME_U1}
    # ${firstname}=  FakerLibrary.name
    # Set Suite Variable  ${firstname}
    # ${lastname}=  FakerLibrary.last_name
    # Set Suite Variable  ${lastname}
    # ${dob}=  FakerLibrary.Date
    # Set Suite Variable  ${dob}
    # ${pin}=  get_pincode

    # ${u_id1}=  Create Sample User
    # Set Suite Variable  ${u_id1}
    # ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    # Should Be Equal As Strings  ${resp[0].status_code}  200
    # Should Be Equal As Strings  ${resp[1].status_code}  200
    # ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
    END
    FOR   ${i}  IN RANGE   0   ${len}
        Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
        IF   not '${user_phone}' == '${MUSERNAME_E}'
            clear_users  ${user_phone}
        END
    END

    ${u_id1}=  Create Sample User  admin=${bool[0]}
    Set Suite Variable  ${u_id1}

    ${resp}=  Get User By Id  ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${PUSERNAME_U1}  ${resp.json()['mobileNo']}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${description}=  FakerLibrary.sentence
    Set Suite Variable  ${description}
    ${dur}=  FakerLibrary.Random Int  min=05  max=10
    Set Suite Variable  ${dur}
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    Set Suite Variable  ${amt}
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User   ${u_id1}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}    ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME8}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  User Take Appointment For Consumer    ${u_id1}  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Get Bill By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${consumer_id}  ${resp.json()['id']}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    appmtTime=${slot1}  apptStatus=${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}

    ${resp}=  Make payment Consumer Mock  ${pid}  ${amt}  ${purpose[1]}  ${apptid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${consumer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentStatus']}   ${paymentStatus[2]}



JD-TC-AppointmentByUserLoginAndBillGenarate -2
    [Documentation]  Create AppointmentByUserLogin and consumer do the prepayment (Tax is disable).


    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear Customer  ${MUSERNAME_E}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${description}=  FakerLibrary.sentence
    Set Suite Variable  ${description}
    ${dur}=  FakerLibrary.Random Int  min=05  max=10
    Set Suite Variable  ${dur}
    ${amt}=  FakerLibrary.Random Int  min=250  max=500
    ${min_pre}=  FakerLibrary.Random Int  min=25  max=150
    clear Customer  ${PUSERNAME_U1}


    ${amt}=  Convert To Number  ${amt}  1
    Set Suite Variable  ${amt}
    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${min_pre}  ${amt}  ${bool[1]}  ${bool[0]}  ${dep_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User   ${u_id1}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}    ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id1}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME8}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  User Take Appointment For Consumer    ${u_id1}  ${cid}  ${s_id}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[1]}

    # ${resp}=  Get Appointment EncodedID   ${apptid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${encId}=  Set Variable   ${resp.json()}
    sleep  05s
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    # Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id1}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Get Bill By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${consumer_id}  ${resp.json()['id']}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    appmtTime=${slot1}  apptStatus=${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre}  ${purpose[0]}  ${apptid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${consumer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentStatus']}   ${paymentStatus[1]}

JD-TC-AppointmentByUserLoginAndBillGenarate -3
    [Documentation]  Create AppointmentByUserLogin and consumer do the prepayment and bill payment (Tax is disable).

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear Customer  ${MUSERNAME_E}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${description}=  FakerLibrary.sentence
    Set Suite Variable  ${description}
    ${dur}=  FakerLibrary.Random Int  min=05  max=10
    Set Suite Variable  ${dur}
    ${amt}=  FakerLibrary.Random Int  min=250  max=500
    ${min_pre}=  FakerLibrary.Random Int  min=50  max=150
    clear Customer  ${PUSERNAME_U1}

    ${amt}=  Convert To Number  ${amt}  1
    Set Suite Variable  ${amt}
    ${resp}=  Create Service For User  ${SERVICE3}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${min_pre}  ${amt}  ${bool[1]}  ${bool[0]}  ${dep_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User   ${u_id1}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}    ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME8}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  User Take Appointment For Consumer    ${u_id1}  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[1]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Get Bill By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${consumer_id}  ${resp.json()['id']}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    appmtTime=${slot1}  apptStatus=${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre}  ${purpose[0]}  ${apptid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${consumer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentStatus']}   ${paymentStatus[1]}

    ${balance}=   Evaluate   ${amt} - ${min_pre}


    ${resp}=  Make payment Consumer Mock  ${pid}  ${balance}  ${purpose[1]}  ${apptid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${consumer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentStatus']}   ${paymentStatus[2]}


JD-TC-AppointmentByUserLoginAndBillGenarate -4
    [Documentation]  Create AppointmentByUserLogin and consumer do the bill payment (prepayment is off and Tax Enable).

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear Customer  ${MUSERNAME_E}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200   
    clear Customer  ${PUSERNAME_U1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${description}=  FakerLibrary.sentence
    Set Suite Variable  ${description}
    ${dur}=  FakerLibrary.Random Int  min=05  max=10
    Set Suite Variable  ${dur}
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    Set Suite Variable  ${amt}
    ${resp}=  Create Service For User  ${SERVICE4}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[1]}  ${dep_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User   ${u_id1}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}    ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME8}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  User Take Appointment For Consumer    ${u_id1}  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[1]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Get Bill By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${totalAmount}  ${resp.json()['netRate']}  

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${consumer_id}  ${resp.json()['id']}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    appmtTime=${slot1}  apptStatus=${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}

    ${resp}=  Make payment Consumer Mock  ${pid}  ${totalAmount}  ${purpose[1]}  ${apptid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${consumer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentStatus']}   ${paymentStatus[2]}

JD-TC-AppointmentByUserLoginAndBillGenarate -5
    [Documentation]  Create AppointmentByUserLogin and consumer do the prepayment (Tax is Enable).


    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear Customer  ${MUSERNAME_E}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200  
    clear Customer  ${PUSERNAME_U1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${description}=  FakerLibrary.sentence
    Set Suite Variable  ${description}
    ${dur}=  FakerLibrary.Random Int  min=05  max=10
    Set Suite Variable  ${dur}
    ${amt}=  FakerLibrary.Random Int  min=250  max=500
    ${min_pre}=  FakerLibrary.Random Int  min=25  max=150

    ${amt}=  Convert To Number  ${amt}  1
    Set Suite Variable  ${amt}
    ${resp}=  Create Service For User  ${SERVICE5}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${min_pre}  ${amt}  ${bool[1]}  ${bool[1]}  ${dep_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User   ${u_id1}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}    ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id1}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME8}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  User Take Appointment For Consumer    ${u_id1}  ${cid}  ${s_id}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[1]}

    # ${resp}=  Get Appointment EncodedID   ${apptid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${encId}=  Set Variable   ${resp.json()}
    sleep  05s
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    # Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id1}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Get Bill By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${consumer_id}  ${resp.json()['id']}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    appmtTime=${slot1}  apptStatus=${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre}  ${purpose[0]}  ${apptid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${consumer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentStatus']}   ${paymentStatus[1]}
    
JD-TC-AppointmentByUserLoginAndBillGenarate -6
    [Documentation]  Create AppointmentByUserLogin and consumer do the prepayment and bill payment (Tax is Enable).

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear Customer  ${MUSERNAME_E}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${description}=  FakerLibrary.sentence
    Set Suite Variable  ${description}
    ${dur}=  FakerLibrary.Random Int  min=05  max=10
    Set Suite Variable  ${dur}
    ${amt}=  FakerLibrary.Random Int  min=250  max=500
    ${min_pre}=  FakerLibrary.Random Int  min=50  max=150
    clear Customer  ${PUSERNAME_U1}

    ${amt}=  Convert To Number  ${amt}  1
    Set Suite Variable  ${amt}
    ${resp}=  Create Service For User  ${SERVICE6}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${min_pre}  ${amt}  ${bool[1]}  ${bool[1]}  ${dep_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User   ${u_id1}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}    ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME8}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  User Take Appointment For Consumer    ${u_id1}  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[1]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Get Bill By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${totalAmount}  ${resp.json()['netRate']}  

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${consumer_id}  ${resp.json()['id']}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    appmtTime=${slot1}  apptStatus=${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre}  ${purpose[0]}  ${apptid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${consumer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentStatus']}   ${paymentStatus[1]}

    ${balance}=   Evaluate   ${totalAmount} - ${min_pre}


    ${resp}=  Make payment Consumer Mock  ${pid}  ${balance}  ${purpose[1]}  ${apptid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${consumer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentStatus']}   ${paymentStatus[2]}