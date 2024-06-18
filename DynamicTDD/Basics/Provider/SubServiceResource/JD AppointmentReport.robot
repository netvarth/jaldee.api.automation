*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Report
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Variables ***

${self}         0
@{CategoryName}   Booking

*** Test Cases ***


JD-TC-AppointmentReport-1

    [Documentation]  take an appointment for the provider specific service by a provider consumer(walk in).
                ...  verify appointment report.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.json()}
    Log  ${decrypted_data}
    Set Test Variable  ${prov_name}  ${decrypted_data['userName']}
    Set Test Variable  ${prov_id}    ${decrypted_data['id']}

    ${resp}=   Get Appointment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Appointment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${resp}=  Get Account Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
   
    ${resp}=  View Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable   ${locId}

        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
        Set Test Variable  ${loc_name}  ${resp.json()['bSchedule']['place']}

    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
        Set Test Variable  ${loc_name}  ${resp.json()[0]['place']}
    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${dep_id}  ${resp1.content}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
        Set Test Variable  ${dep_name1}  ${resp.json()['departments'][0]['departmentName']}
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${empty_list}=   Create List

    ${SERVICE1}=    FakerLibrary.word
    ${user_id}=   Create Dictionary  id=${prov_id}
    ${s_id}=  Create Sample Service  ${SERVICE1}   department=${dep_id}   provider=${user_id}
   
    ${resp}=   Get Service By Id  ${s_id}
    Log   ${resp.content}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${ser_dur}      ${resp.json()['serviceDuration']}
    Set Test Variable   ${ser_amount}   ${resp.json()['totalAmount']}
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[0]}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${locId}  ${duration}  ${bool1}  ${s_id}
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

    #............provider consumer creation..........

    ${NewCustomer}    Generate random string    10    123456789
    ${NewCustomer}    Convert To Integer  ${NewCustomer}

    ${custf_name}=  FakerLibrary.name    
    ${custl_name}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${NewCustomer}    firstName=${custf_name}   lastName=${custl_name}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Send Otp For Login    ${NewCustomer}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
 
    ${resp}=    Customer Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${NewCustomer}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['jaldeeId']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  provider=${user_id}
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
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}

    ${filter}=  Create Dictionary    
    ${resp}=  Generate Report REST details  ${reportType[1]}  ${Report_Date_Category[4]}  ${filter}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}

    ${appt_date} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    ${appt_date} =	Set Variable	${appt_date} [${slot1}]	
   
    sleep  1s
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}                        1
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                   Appointment Report
    Should Be Equal As Strings  ${resp.json()['reportType']}                                    ${reportType[1]}
    Should Be Equal As Strings  ${resp.json()['reportResponseType']}                            ${ReportResponseType[0]}
    Should Be Equal As Strings  ${resp.json()['reportTokenID']}                                 ${token_id1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}  ${Report_Date_filter[4]}  

    # Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}                 ${appt_date} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}                 ${cid} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}                 ${countryCodes[0]} ${NewCustomer}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}                 ${schedule_name} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}                 ${loc_name} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}                 ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}                 ${encId} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}                 ${apptStatus[1]} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}                ${Checkin_mode[1]} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}                0.00
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}                ${prov_name} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['13']}                ${dep_name1} 

JD-TC-AppointmentReport-2

    [Documentation]  take an appointment for the provider specific service by a provider consumer(online).
                ...  verify appointment report.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.json()}
    Log  ${decrypted_data}
    Set Test Variable  ${prov_name}  ${decrypted_data['userName']}
    Set Test Variable  ${prov_id}    ${decrypted_data['id']}

    ${resp}=   Get Appointment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Appointment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${resp}=  Get Account Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
   
    ${resp}=  View Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=    Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable   ${locId}

        ${resp}=   Get Location ById  ${locId}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
        Set Test Variable  ${loc_name}  ${resp.json()['bSchedule']['place']}

    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
        Set Test Variable  ${loc_name}  ${resp.json()[0]['place']}
    END

    ${resp}=  Get Departments
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${dep_id}  ${resp1.content}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
        Set Test Variable  ${dep_name1}  ${resp.json()['departments'][0]['departmentName']}
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${empty_list}=   Create List

    ${SERVICE1}=    FakerLibrary.word
    ${user_id}=   Create Dictionary  id=${prov_id}
    ${s_id}=  Create Sample Service  ${SERVICE1}   department=${dep_id}   provider=${user_id}
   
    ${resp}=   Get Service By Id  ${s_id}
    Log   ${resp.content}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${ser_dur}      ${resp.json()['serviceDuration']}
    Set Test Variable   ${ser_amount}   ${resp.json()['totalAmount']}
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[0]}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${locId}  ${duration}  ${bool1}  ${s_id}
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

    #............provider consumer creation..........

    ${NewCustomer}    Generate random string    10    123456789
    ${NewCustomer}    Convert To Integer  ${NewCustomer}

    ${custf_name}=  FakerLibrary.name    
    ${custl_name}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${NewCustomer}    firstName=${custf_name}   lastName=${custl_name}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Send Otp For Login    ${NewCustomer}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
   
    ${resp}=  Get Appointment Schedules Consumer  ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${account_id}
    Log   ${resp.content}
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

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${account_id}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  provider=${user_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}

    ${resp}=    Customer Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${NewCustomer}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['jaldeeId']}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}

    ${filter}=  Create Dictionary    
    ${resp}=  Generate Report REST details  ${reportType[1]}  ${Report_Date_Category[4]}  ${filter}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}

    ${appt_date} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    # ${appt_date} =	Set Variable	${appt_date} [${slot1}]	
    # ${slot1} = format time  ${slot1}  time_format=%I:%M %p

    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}                        1
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                   Appointment Report
    Should Be Equal As Strings  ${resp.json()['reportType']}                                    ${reportType[1]}
    Should Be Equal As Strings  ${resp.json()['reportResponseType']}                            ${ReportResponseType[0]}
    Should Be Equal As Strings  ${resp.json()['reportTokenID']}                                 ${token_id1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}  ${Report_Date_filter[4]}  

    # Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}                 ${appt_date} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}                 ${cid} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}                 ${countryCodes[0]} ${NewCustomer}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}                 ${schedule_name} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}                 ${loc_name} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}                 ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}                 ${encId} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}                 ${apptStatus[1]} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}                ${Checkin_mode[0]} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}                0.00
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}                ${prov_name} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['13']}                ${dep_name1} 

JD-TC-AppointmentReport-3

    [Documentation]  take an appointment for the provider specific service by a provider consumer(online).
                ...  then reschedule the appointment to another day then verify appointment report.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.json()}
    Log  ${decrypted_data}
    Set Test Variable  ${prov_name}  ${decrypted_data['userName']}
    Set Test Variable  ${prov_id}    ${decrypted_data['id']}

    ${resp}=   Get Appointment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Appointment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${resp}=  Get Account Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
   
    ${resp}=  View Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=    Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable   ${locId}

        ${resp}=   Get Location ById  ${locId}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
        Set Test Variable  ${loc_name}  ${resp.json()['bSchedule']['place']}

    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
        Set Test Variable  ${loc_name}  ${resp.json()[0]['place']}
    END

    ${resp}=  Get Departments
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${dep_id}  ${resp1.content}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
        Set Test Variable  ${dep_name1}  ${resp.json()['departments'][0]['departmentName']}
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${empty_list}=   Create List

    ${SERVICE1}=    FakerLibrary.word
    ${user_id}=   Create Dictionary  id=${prov_id}
    ${s_id}=  Create Sample Service  ${SERVICE1}   department=${dep_id}   provider=${user_id}
   
    ${resp}=   Get Service By Id  ${s_id}
    Log   ${resp.content}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${ser_dur}      ${resp.json()['serviceDuration']}
    Set Test Variable   ${ser_amount}   ${resp.json()['totalAmount']}
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[0]}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${locId}  ${duration}  ${bool1}  ${s_id}
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

    #............provider consumer creation..........

    ${NewCustomer}    Generate random string    10    123456789
    ${NewCustomer}    Convert To Integer  ${NewCustomer}

    ${custf_name}=  FakerLibrary.name    
    ${custl_name}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${NewCustomer}    firstName=${custf_name}   lastName=${custl_name}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Send Otp For Login    ${NewCustomer}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
   
    ${resp}=  Get Appointment Schedules Consumer  ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${account_id}
    Log   ${resp.content}
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

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${account_id}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  provider=${user_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}

    ${resp}=    Customer Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${NewCustomer}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['jaldeeId']}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}

    ${filter}=  Create Dictionary    
    ${resp}=  Generate Report REST details  ${reportType[1]}  ${Report_Date_Category[4]}  ${filter}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}

    ${appt_date} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    # ${appt_date} =	Set Variable	${appt_date} [${slot1}]	
    # ${slot1} = format time  ${slot1}  time_format=%I:%M %p

    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}                        1
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                   Appointment Report
    Should Be Equal As Strings  ${resp.json()['reportType']}                                    ${reportType[1]}
    Should Be Equal As Strings  ${resp.json()['reportResponseType']}                            ${ReportResponseType[0]}
    Should Be Equal As Strings  ${resp.json()['reportTokenID']}                                 ${token_id1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}  ${Report_Date_filter[4]}   

    # Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}                 ${appt_date} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}                 ${cid} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}                 ${countryCodes[0]} ${NewCustomer}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}                 ${schedule_name} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}                 ${loc_name} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}                 ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}                 ${encId} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}                 ${apptStatus[1]} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}                ${Checkin_mode[0]} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}                0.00
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}                ${prov_name} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['13']}                ${dep_name1} 

    ${resp}=    ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    FOR   ${i}  IN RANGE   0   ${num_slots}
        ${j2}=  Random Int  max=${num_slots-1}
        Exit For Loop If  "${resp.json()['availableSlots'][${j2}]['time']}" != "${slot1}"
    END
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][${j2}]['time']}

    ${DAY2}=  db.add_timezone_date  ${tz}  2     
    ${resp}=  Reschedule Appointment   ${account_id}   ${apptid1}  ${slot2}  ${DAY2}  ${sch_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=    Customer Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${filter}=  Create Dictionary    
    ${resp}=  Generate Report REST details  ${reportType[1]}  ${Report_Date_Category[4]}  ${filter}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}

    ${appt_date} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    # ${appt_date} =	Set Variable	${appt_date} [${slot1}]	
    # ${slot1} = format time  ${slot1}  time_format=%I:%M %p

    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}                        0
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                   Appointment Report
    Should Be Equal As Strings  ${resp.json()['reportType']}                                    ${reportType[1]}
    Should Be Equal As Strings  ${resp.json()['reportResponseType']}                            ${ReportResponseType[0]}
    Should Be Equal As Strings  ${resp.json()['reportTokenID']}                                 ${token_id1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}  ${Report_Date_filter[4]}   

    ${filter}=  Create Dictionary    
    ${resp}=  Generate Report REST details  ${reportType[1]}  ${Report_Date_Category[1]}  ${filter}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}

    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}                        1
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                   Appointment Report
    Should Be Equal As Strings  ${resp.json()['reportType']}                                    ${reportType[1]}
    Should Be Equal As Strings  ${resp.json()['reportResponseType']}                            ${ReportResponseType[0]}
    Should Be Equal As Strings  ${resp.json()['reportTokenID']}                                 ${token_id1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}  ${Report_Date_filter[1]}   

    # Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}                 ${appt_date} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}                 ${cid} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}                 ${countryCodes[0]} ${NewCustomer}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}                 ${schedule_name} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}                 ${loc_name} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}                 ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}                 ${encId} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}                 ${apptStatus[1]} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}                ${Checkin_mode[0]} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}                0.00
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}                ${prov_name} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['13']}                ${dep_name1} 

