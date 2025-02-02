*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        POC
Library           Collections
Library           OperatingSystem
Library           String
Library           json
Library           random
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot

*** Variables ***
# ${sTime}  05:00 AM
# ${eTime}  11:00 PM
# ${licpkgid}    1
# ${licpkgname}   basic
@{Views}  self  all  customersOnly
${var_file}               ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py
${data_file}              ${EXECDIR}/data/${ENVIRONMENT}data/${ENVIRONMENT}phnumbers.txt


*** Test Cases ***

JD-TC-Provider_Signup-1
    [Documentation]   Provider Signup in Random Domain 

    # Create Directory   ${EXECDIR}/TDD/scaledata/    #->scalephnumbers.txt
    
    # ${PO_Number}=  FakerLibrary.Numerify  %#####
    # ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${PH_Number}    Random Number 	digits=5  #fix_len=True
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PUSERPH0}  555${PH_Number}
    FOR  ${index}  IN RANGE   1
        ${ph}=  Evaluate   ${PUSERPH0}+${index}
        Log   ${ph}
        ${firstname}  ${lastname}  ${PhoneNumber}  ${LoginId}=  Provider Signup  PhoneNumber=${ph}
        ${num}=  find_last  ${var_file}
        ${num}=  Evaluate   ${num}+1
        Append To File  ${data_file}  ${LoginId} - ${PASSWORD}${\n}
        Append To File  ${var_file}  PUSERNAME${num}=${LoginId}${\n}
        Log    PUSERNAME${num}

        ${resp}=  Encrypted Provider Login  ${LoginId}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200

        ############For Appointment##############3

        ${resp}=   Get License UsageInfo 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Business Profile
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${bname}  ${resp.json()['businessName']}
        Set Test Variable  ${pid}  ${resp.json()['id']}
        Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

        ${resp}=   Get jaldeeIntegration Settings
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF  '${resp.json()['onlinePresence']}'=='${bool[0]}'
            ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${EMPTY}  ${EMPTY}
            Should Be Equal As Strings  ${resp1.status_code}  200
        END

        ${resp}=   Get jaldeeIntegration Settings
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

        # ${resp}=  Get Account Settings
        # Log  ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
    
        # IF  ${resp.json()['onlinePayment']}==${bool[0]}
        #     ${resp1}=    Enable Disable Online Payment   ${toggle[0]}
        #     Log  ${resp1.content}
        #     Should Be Equal As Strings  ${resp1.status_code}  200
        # END

        # ${resp}=  Get Account Settings
        # Log  ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get jp finance settings
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
            ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
        END

        ${resp}=  Get jp finance settings    
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}

        ${resp}=   Get Appointment Settings
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF  ${resp.json()['enableAppt']}==${bool[0]}   
            ${resp}=   Enable Appointment 
            Should Be Equal As Strings  ${resp.status_code}  200
        END

        ${resp}=   Get Appointment Settings
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
        Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]} 

        ${resp}=   Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=    Get Locations
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${lid}=  Create Sample Location  
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}

        ${resp}=    Get Locations
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        comment  Services for check-ins
        
        ${SERVICE1}=    FakerLibrary.job
        ${min_pre}=   Random Int   min=10   max=50
        ${servicecharge}=   Random Int  min=100  max=200
        ${s_id}=  Create Sample Service with Prepayment   ${SERVICE1}  ${min_pre}  ${servicecharge}

        ${SERVICE1}=    FakerLibrary.job
        ${s_id1}=  Create Sample Service  ${SERVICE1}  maxBookingsAllowed=10
        Set Suite Variable  ${s_id1}

        ${resp}=  Get Appointment Schedules
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${DAY1}=  db.get_date_by_timezone  ${tz}
        ${DAY2}=  db.add_timezone_date  ${tz}  10        
        ${DAY3}=  db.add_timezone_date  ${tz}  4  
        ${list}=  Create List  1  2  3  4  5  6  7
        ${sTime1}=  db.get_time_by_timezone  ${tz}
        ${delta}=  FakerLibrary.Random Int  min=10  max=60
        ${eTime1}=  add_two   ${sTime1}  ${delta}
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=1  max=1
        ${maxval}=  Convert To Integer   ${delta/4}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  ${s_id1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}

        ${resp}=  Get Appointment Schedule ById  ${sch_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}  
        ...   parallelServing=${parallel}  batchEnable=${bool1}

        ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        
    END

*** Comments ***
JD-TC-Consumer_Signup-1
    [Documentation]   Consumer Signup

    # ${CUSERPH0}=  Evaluate  ${CUSERPH}+100100201
    # Set Suite Variable   ${CUSERPH0}
    # Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH0}${\n}
    # ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${CUSERPH0}  555${PH_Number}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH0}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH0}  ${OtpPurpose['ConsumerSignUp']}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH0}  ${PASSWORD}  ${OtpPurpose['ConsumerSignUp']}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200



*** Comments ***
JD-TC-AddToWL-1
    [Documentation]   Add To waitlist
    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    # Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ser_durtn}=   Random Int   min=2   max=2
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${ser_durtn}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[0]}   ${Empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Verify Response  ${resp}  onlineCheckIns=${bool[1]}

    ${resp}=  Enable Waitlist
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}
    
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
    END

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${SERVICE1}=    FakerLibrary.Word
        ${s_id}=  Create Sample Service  ${SERVICE1}
    ELSE
        Set Test Variable   ${s_id}   ${resp.json()[0]['id']}
    END


    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}
    # ${sTime1}=  add_timezone_time  ${tz}  0  30  
    # ${eTime1}=  add_timezone_time  ${tz}  0  45  
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  0  45  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id1}  ${resp.json()}

    ${PO_Number}    Generate random string    5    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${PO_Number}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERPH0}  firstName=${firstname}   lastName=${lastname}  countryCode=${countryCodes[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id1}  ${DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wlresp}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wlresp[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-TakeAppointment-1
    [Documentation]   Take appointment
    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    # Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp1}=  Enable Appointment
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get Appointment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]} 
    
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
    END

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${SERVICE1}=    FakerLibrary.Word
        ${s_id}=  Create Sample Service  ${SERVICE1}
    ELSE
        Set Test Variable   ${s_id}   ${resp.json()[0]['id']}
    END

    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${DAY1}=  get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10
    ${sTime1}=  get_time_by_timezone  ${tz}
    # ${eTime1}=  add_timezone_time  ${tz}  0  45      
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${schedule_name}=  FakerLibrary.bs
    ${parallelServing}=  FakerLibrary.Random Int  min=5  max=10
    ${consumerparallelserving}=  FakerLibrary.Random Int  min=1  max=${parallelServing}
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${consumerparallelserving}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${PO_Number}    Generate random string    5    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${PO_Number}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERPH0}  firstName=${firstname}   lastName=${lastname}  countryCode=${countryCodes[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId}
