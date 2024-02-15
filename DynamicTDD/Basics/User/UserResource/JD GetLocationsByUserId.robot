***Settings***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        User
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Variables ***

@{empty_list}

*** Keywords ***

Get Locations By UserId

    [Arguments]    ${userid}   &{kwargs}
    ${pro_headers}=  Create Dictionary  &{headers}
    ${pro_params}=   Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${pro_headers}   &{tzheaders}
    Set To Dictionary  ${pro_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    Get On Session    ynw    provider/user/${userid}/location       params=${pro_params}   expected_status=any  
    RETURN  ${resp}


***Test Cases***


JD-TC-GetLocationsByUserId-1

    [Documentation]  User create a queue with base location and verify get locations by user id.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Locations
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}           ${resp.json()[0]['id']}
    Set Suite Variable  ${place}         ${resp.json()[0]['place']}
    Set Suite Variable  ${address}       ${resp.json()[0]['address']}
    Set Suite Variable  ${pinCode}       ${resp.json()[0]['pinCode']}
    Set Suite Variable  ${longitude}     ${resp.json()[0]['longitude']}
    Set Suite Variable  ${lattitude}     ${resp.json()[0]['lattitude']}
    Set Suite Variable  ${googleMapUrl}  ${resp.json()[0]['googleMapUrl']}
    Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}


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

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
    END
    FOR   ${i}  IN RANGE   0   ${len}
        Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
        IF   not '${user_phone}' == '${HLMUSERNAME10}'
            clear_users  ${user_phone}
        END
    END

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    ${u_id}=  Create Sample User  admin=${bool[0]}
    Set Suite Variable  ${u_id}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${PUSERNAME_U1}  ${resp.json()['mobileNo']}

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=05  max=10
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${SERVICE1}=  FakerLibrary.word

    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  2  30  
    ${queue_name}=  FakerLibrary.bs

    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id}  ${s_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Locations By UserId  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}             ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['place']}          ${place}
    Should Be Equal As Strings  ${resp.json()[0]['address']}        ${address}
    Should Be Equal As Strings  ${resp.json()[0]['pinCode']}        ${pinCode}
    Should Be Equal As Strings  ${resp.json()[0]['longitude']}      ${longitude}
    Should Be Equal As Strings  ${resp.json()[0]['lattitude']}      ${lattitude}
    Should Be Equal As Strings  ${resp.json()[0]['googleMapUrl']}   ${googleMapUrl}
    Should Be Equal As Strings  ${resp.json()[0]['timezone']}       ${tz}
    Should Be Equal As Strings  ${resp.json()[0]['baseLocation']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['status']}         ${status[0]}


JD-TC-GetLocationsByUserId-2

    [Documentation]  User create an appt schedule with base location and verify get locations by user id.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${u_id1}=  Create Sample User  admin=${bool[0]}
    Set Suite Variable  ${u_id1}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${PUSERNAME_U2}  ${resp.json()['mobileNo']}

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U2}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U2}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=05  max=10
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${SERVICE2}=  FakerLibrary.word

    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=2  max=10
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  0  40  

    ${resp}=  Create Appointment Schedule For User   ${u_id1}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}    ${lid}  ${duration}  ${bool[1]}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Locations By UserId  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}             ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['place']}          ${place}
    Should Be Equal As Strings  ${resp.json()[0]['address']}        ${address}
    Should Be Equal As Strings  ${resp.json()[0]['pinCode']}        ${pinCode}
    Should Be Equal As Strings  ${resp.json()[0]['longitude']}      ${longitude}
    Should Be Equal As Strings  ${resp.json()[0]['lattitude']}      ${lattitude}
    Should Be Equal As Strings  ${resp.json()[0]['googleMapUrl']}   ${googleMapUrl}
    Should Be Equal As Strings  ${resp.json()[0]['timezone']}       ${tz}
    Should Be Equal As Strings  ${resp.json()[0]['baseLocation']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['status']}         ${status[0]}


JD-TC-GetLocationsByUserId-3

    [Documentation]  User create a queue with base location and another queue with another location and verify get locations by user id.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address1}=  get_loc_details
    ${tz1}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${latti}
    Set Suite Variable  ${longi}
    Set Suite Variable  ${postcode}
    Set Suite Variable  ${city}
    Set Suite Variable  ${city}
    Set Suite Variable  ${address1}
    Set Suite Variable  ${tz1}

    ${parking}    Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${DAY}=  db.get_date_by_timezone  ${tz1}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime0}=  add_timezone_time  ${tz1}  0  15  
    ${eTime0}=  add_timezone_time  ${tz1}  0  30  
    
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address1}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime0}  ${eTime0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid1}  ${resp.json()}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY2}=  db.add_timezone_date  ${tz1}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz1}  0  15  
    ${eTime1}=  add_timezone_time  ${tz1}  2  30  
    ${queue_name}=  FakerLibrary.bs

    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid1}  ${u_id}  ${s_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Locations By UserId  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}             ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['place']}          ${place}
    Should Be Equal As Strings  ${resp.json()[0]['address']}        ${address}
    Should Be Equal As Strings  ${resp.json()[0]['pinCode']}        ${pinCode}
    Should Be Equal As Strings  ${resp.json()[0]['longitude']}      ${longitude}
    Should Be Equal As Strings  ${resp.json()[0]['lattitude']}      ${lattitude}
    Should Be Equal As Strings  ${resp.json()[0]['googleMapUrl']}   ${googleMapUrl}
    Should Be Equal As Strings  ${resp.json()[0]['timezone']}       ${tz}
    Should Be Equal As Strings  ${resp.json()[0]['baseLocation']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['status']}         ${status[0]}

    Should Be Equal As Strings  ${resp.json()[1]['id']}             ${lid1}
    Should Be Equal As Strings  ${resp.json()[1]['place']}          ${city}
    Should Be Equal As Strings  ${resp.json()[1]['address']}        ${address1}
    Should Be Equal As Strings  ${resp.json()[1]['pinCode']}        ${postcode}
    Should Be Equal As Strings  ${resp.json()[1]['longitude']}      ${longi}
    Should Be Equal As Strings  ${resp.json()[1]['lattitude']}      ${latti}
    Should Be Equal As Strings  ${resp.json()[1]['timezone']}       ${tz1}
    Should Be Equal As Strings  ${resp.json()[1]['baseLocation']}   ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[1]['status']}         ${status[0]}


JD-TC-GetLocationsByUserId-4

    [Documentation]  User create an appt schedule with base location and another schedule with another location and verify get locations by user id.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=2  max=10
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY1}=  db.get_date_by_timezone  ${tz1}
    ${DAY2}=  db.add_timezone_date  ${tz1}  10        
    ${sTime1}=  add_timezone_time  ${tz1}  0  15  
    ${eTime1}=  add_timezone_time  ${tz1}  0  40  

    ${resp}=  Create Appointment Schedule For User   ${u_id1}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}    ${lid1}  ${duration}  ${bool[1]}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Locations By UserId  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}             ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['place']}          ${place}
    Should Be Equal As Strings  ${resp.json()[0]['address']}        ${address}
    Should Be Equal As Strings  ${resp.json()[0]['pinCode']}        ${pinCode}
    Should Be Equal As Strings  ${resp.json()[0]['longitude']}      ${longitude}
    Should Be Equal As Strings  ${resp.json()[0]['lattitude']}      ${lattitude}
    Should Be Equal As Strings  ${resp.json()[0]['googleMapUrl']}   ${googleMapUrl}
    Should Be Equal As Strings  ${resp.json()[0]['timezone']}       ${tz}
    Should Be Equal As Strings  ${resp.json()[0]['baseLocation']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['status']}         ${status[0]}

    Should Be Equal As Strings  ${resp.json()[1]['id']}             ${lid1}
    Should Be Equal As Strings  ${resp.json()[1]['place']}          ${city}
    Should Be Equal As Strings  ${resp.json()[1]['address']}        ${address1}
    Should Be Equal As Strings  ${resp.json()[1]['pinCode']}        ${postcode}
    Should Be Equal As Strings  ${resp.json()[1]['longitude']}      ${longi}
    Should Be Equal As Strings  ${resp.json()[1]['lattitude']}      ${latti}
    Should Be Equal As Strings  ${resp.json()[1]['timezone']}       ${tz1}
    Should Be Equal As Strings  ${resp.json()[1]['baseLocation']}   ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[1]['status']}         ${status[0]}


JD-TC-GetLocationsByUserId-5

    [Documentation]  User create an appt schedule with base location and another schedule with another location 
    ...  then disable that location and verify get locations by user id.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Disable Location  ${lid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Locations By UserId  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}             ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['place']}          ${place}
    Should Be Equal As Strings  ${resp.json()[0]['address']}        ${address}
    Should Be Equal As Strings  ${resp.json()[0]['pinCode']}        ${pinCode}
    Should Be Equal As Strings  ${resp.json()[0]['longitude']}      ${longitude}
    Should Be Equal As Strings  ${resp.json()[0]['lattitude']}      ${lattitude}
    Should Be Equal As Strings  ${resp.json()[0]['googleMapUrl']}   ${googleMapUrl}
    Should Be Equal As Strings  ${resp.json()[0]['timezone']}       ${tz}
    Should Be Equal As Strings  ${resp.json()[0]['baseLocation']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['status']}         ${status[0]}

    Should not contain   ${resp.json()}             ${lid1}

JD-TC-GetLocationsByUserId-6

    [Documentation]  User create a queue with base location and another schedule with another location 
    ...  then disable that location and verify get locations by user id.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Locations By UserId  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}             ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['place']}          ${place}
    Should Be Equal As Strings  ${resp.json()[0]['address']}        ${address}
    Should Be Equal As Strings  ${resp.json()[0]['pinCode']}        ${pinCode}
    Should Be Equal As Strings  ${resp.json()[0]['longitude']}      ${longitude}
    Should Be Equal As Strings  ${resp.json()[0]['lattitude']}      ${lattitude}
    Should Be Equal As Strings  ${resp.json()[0]['googleMapUrl']}   ${googleMapUrl}
    Should Be Equal As Strings  ${resp.json()[0]['timezone']}       ${tz}
    Should Be Equal As Strings  ${resp.json()[0]['baseLocation']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['status']}         ${status[0]}

    Should not contain   ${resp.json()}             ${lid1}
   
JD-TC-GetLocationsByUserId -UH1

    [Documentation]   Get locations by user id without login.  

    ${resp}=  Get Locations By UserId  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}
 
JD-TC-GetLocationsByUserId -UH2

    [Documentation]   Consumer calls get locations by user id.

    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Locations By UserId  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}