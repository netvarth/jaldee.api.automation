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
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Variables ***

${self}         0


*** Test Cases ***

JD-TC-UserPerformanceReport-1

    [Documentation]  Create a sub service and add that sub service to an appointment(walkin) for a provider consumer.
                ...   assign that subservice to a user and verify user performance report.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME40}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
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

    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
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
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${HLPUSERNAME40}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id1}=  Create Sample User
    Set Test Variable   ${u_id1}
   
    ${resp}=  Get User By Id  ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}
    Set Test Variable  ${userf_name}  ${resp.json()['firstName']}
    Set Test Variable  ${userl_name}  ${resp.json()['lastName']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${empty_list}=   Create List

    ${SERVICE1}=    FakerLibrary.word
    ${s_id}=  Create Sample Service  ${SERVICE1}   department=${dep_id}
   
    ${resp}=   Get Service By Id  ${s_id}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${ser_dur}      ${resp.json()['serviceDuration']}
    Set Test Variable   ${ser_amount}   ${resp.json()['totalAmount']}
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[1]}

    ##....subservice creation..........

    ${desc}=  FakerLibrary.sentence
    ${subser_dur}=   Random Int   min=5   max=10
    ${subser_price}=   Random Int   min=100   max=500
    ${subser_price}=  Convert To Number  ${subser_price}  1
    ${subser_name}=    FakerLibrary.firstname
   
    ${resp}=  Create Service    ${subser_name}  ${desc}  ${subser_dur}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price}
    ...    ${bool[0]}   ${bool[0]}   department=${dep_id}  serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${subser_id1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${locId}  ${duration}  ${bool1}  ${s_id}
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

    #............provider consumer creation..........

    ${NewCustomer}    Generate random string    10    123456789
    ${NewCustomer}    Convert To Integer  ${NewCustomer}

    ${custf_name}=  FakerLibrary.name    
    ${custl_name}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${NewCustomer}    firstName=${custf_name}   lastName=${custl_name}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Send Otp For Login    ${NewCustomer}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Customer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME40}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
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
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Not Contain   ${resp.json()['subServiceData']}                               ${subser_id1}

    ${asgn_users}=   Create List  ${u_id1}
    ${subser_qnty}=   Random Int   min=1   max=5
    # ${subser_qnty}=  Convert To Number  ${subser_qnty}  1
    
    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   quantity=${subser_qnty}  assigneeUsers=${asgn_users}
    
    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total}=    Evaluate    ${subser_qnty}*${subser_price}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceId']}        ${subser_id1}
    
    ${resp}=   Get Appointment level Bill Details      ${apptid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${filter}=  Create Dictionary      
    ${resp}=  Generate Report REST details  ${reportType[6]}  ${Report_Date_Category[4]}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}
  
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${tot_amt}   ${resp.json()['reportContent']['dataHeader']['Grand Total']}

    ${total_amt}=    Evaluate    ${ser_amount}+${total}
    ${ser_date} =	Convert Date	${DAY1}	result_format=%d-%m-%Y
    ${tot_amt} =    Replace String    ${tot_amt}    Rs.     ${EMPTY}
    ${tot_amt} =    Replace String    ${tot_amt}    ,       ${EMPTY}
    ${tot_amt}=  Convert To Number  ${tot_amt}  1

    Should Be Equal As Strings  ${resp.json()['status']}                                        ${Report_Status[0]}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}                 1
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}                 ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}                 ${userf_name} ${userl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}                 ${subser_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}                 ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}                 ${total}
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}                        2
    Should Be Equal As Strings  ${tot_amt}                                                      ${total_amt}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                   User Performance Report
    Should Be Equal As Strings  ${resp.json()['reportType']}                                    ${reportType[6]}
    Should Be Equal As Strings  ${resp.json()['reportResponseType']}                            ${ReportResponseType[0]}
    Should Be Equal As Strings  ${resp.json()['reportTokenID']}                                 ${token_id1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}  ${Report_Date_Category[4]}   ignore_case=True

JD-TC-UserPerformanceReport-2

    [Documentation]  Create a sub service and add that sub service to an appointment(online) for a provider consumer.
                ...   assign that subservice to a user and verify user performance report.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME41}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

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

    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
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
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${HLPUSERNAME41}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id1}=  Create Sample User
    Set Test Variable   ${u_id1}
   
    ${resp}=  Get User By Id  ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}
    Set Test Variable  ${userf_name}  ${resp.json()['firstName']}
    Set Test Variable  ${userl_name}  ${resp.json()['lastName']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${empty_list}=   Create List

    ${SERVICE1}=    FakerLibrary.word
    ${s_id}=  Create Sample Service  ${SERVICE1}   department=${dep_id}
   
    ${resp}=   Get Service By Id  ${s_id}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${ser_dur}      ${resp.json()['serviceDuration']}
    Set Test Variable   ${ser_amount}   ${resp.json()['totalAmount']}
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[1]}

    ##....subservice creation..........

    ${desc}=  FakerLibrary.sentence
    ${subser_dur}=   Random Int   min=5   max=10
    ${subser_price}=   Random Int   min=100   max=500
    ${subser_price}=  Convert To Number  ${subser_price}  1
    ${subser_name}=    FakerLibrary.firstname
   
    ${resp}=  Create Service    ${subser_name}  ${desc}  ${subser_dur}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price}
    ...    ${bool[0]}   ${bool[0]}   department=${dep_id}  serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${subser_id1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${locId}  ${duration}  ${bool1}  ${s_id}
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

    #............provider consumer creation..........

    ${NewCustomer}    Generate random string    10    123456789
    ${NewCustomer}    Convert To Integer  ${NewCustomer}

    ${custf_name}=  FakerLibrary.name    
    ${custl_name}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${NewCustomer}    firstName=${custf_name}   lastName=${custl_name}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Send Otp For Login    ${NewCustomer}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=  Get Appointment Schedules Consumer  ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${account_id}
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

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${account_id}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Not Contain   ${resp.json()['subServiceData']}                               ${subser_id1}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME41}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Not Contain   ${resp.json()['subServiceData']}                               ${subser_id1}

    ${asgn_users}=   Create List  ${u_id1}
    ${subser_qnty}=   Random Int   min=1   max=5
    # ${subser_qnty}=  Convert To Number  ${subser_qnty}  1
    
    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   quantity=${subser_qnty}  assigneeUsers=${asgn_users}
    
    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total}=    Evaluate    ${subser_qnty}*${subser_price}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceId']}        ${subser_id1}
    
    ${resp}=   Get Appointment level Bill Details      ${apptid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${filter}=  Create Dictionary      
    ${resp}=  Generate Report REST details  ${reportType[6]}  ${Report_Date_Category[4]}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}

    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${tot_amt}   ${resp.json()['reportContent']['dataHeader']['Grand Total']}

    ${total_amt}=    Evaluate    ${ser_amount}+${total}
    ${ser_date} =	Convert Date	${DAY1}	result_format=%d-%m-%Y
    ${tot_amt} =    Replace String    ${tot_amt}    Rs.     ${EMPTY}
    ${tot_amt} =    Replace String    ${tot_amt}    ,       ${EMPTY}
    ${tot_amt}=  Convert To Number  ${tot_amt}  1

    Should Be Equal As Strings  ${resp.json()['status']}                                        ${Report_Status[0]}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}                 1
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}                 ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}                 ${userf_name} ${userl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}                 ${subser_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}                 ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}                 ${total}
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}                        2
    Should Be Equal As Strings  ${tot_amt}                                                      ${total_amt}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                   User Performance Report
    Should Be Equal As Strings  ${resp.json()['reportType']}                                    ${reportType[6]}
    Should Be Equal As Strings  ${resp.json()['reportResponseType']}                            ${ReportResponseType[0]}
    Should Be Equal As Strings  ${resp.json()['reportTokenID']}                                 ${token_id1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}  ${Report_Date_Category[4]}   ignore_case=True

JD-TC-UserPerformanceReport-3

    [Documentation]  Create a sub service and add that sub service to an appointment(online) for a provider consumer's family member.
                ...   assign that subservice to a user and verify user performance report.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME42}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

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

    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
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
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${HLPUSERNAME42}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id1}=  Create Sample User
    Set Test Variable   ${u_id1}
   
    ${resp}=  Get User By Id  ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}
    Set Test Variable  ${userf_name}  ${resp.json()['firstName']}
    Set Test Variable  ${userl_name}  ${resp.json()['lastName']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${empty_list}=   Create List

    ${SERVICE1}=    FakerLibrary.word
    ${s_id}=  Create Sample Service  ${SERVICE1}   department=${dep_id}
   
    ${resp}=   Get Service By Id  ${s_id}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${ser_dur}      ${resp.json()['serviceDuration']}
    Set Test Variable   ${ser_amount}   ${resp.json()['totalAmount']}
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[1]}

    ##....subservice creation..........

    ${desc}=  FakerLibrary.sentence
    ${subser_dur}=   Random Int   min=5   max=10
    ${subser_price}=   Random Int   min=100   max=500
    ${subser_price}=  Convert To Number  ${subser_price}  1
    ${subser_name}=    FakerLibrary.firstname
   
    ${resp}=  Create Service    ${subser_name}  ${desc}  ${subser_dur}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price}
    ...    ${bool[0]}   ${bool[0]}   department=${dep_id}  serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${subser_id1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${locId}  ${duration}  ${bool1}  ${s_id}
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

    #............provider consumer creation..........

    ${NewCustomer}    Generate random string    10    123456789
    ${NewCustomer}    Convert To Integer  ${NewCustomer}

    ${custf_name}=  FakerLibrary.name    
    ${custl_name}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${NewCustomer}    firstName=${custf_name}   lastName=${custl_name}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Send Otp For Login    ${NewCustomer}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${gender}                     Random Element    ${Genderlist}                   
    ${dob}                        FakerLibrary.Date
    ${fname}                      FakerLibrary. name
    ${lname}                      FakerLibrary.last_name
    ${email}                      FakerLibrary.email
    ${city}                       FakerLibrary.city
    ${state}                      FakerLibrary.state
    ${address}                    FakerLibrary.address
    ${primnum}                    FakerLibrary.Numerify   text=%%%%%%%%%%
    ${altno}                      FakerLibrary.Numerify   text=%%%%%%%%%%
    ${numt}                       FakerLibrary.Numerify   text=%%%%%%%%%%
    ${numw}                       FakerLibrary.Numerify   text=%%%%%%%%%%

    ${resp}=  AddFamilyMember   ${fname}  ${lname}  ${dob}  ${gender}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${fid}  ${resp.json()}

    ${resp}=  ListFamilyMember
    Verify Response List  ${resp}  0  user=${fid}

    ${resp}=    Add FamilyMember As ProviderConsumer     ${fid}     ${cid}   ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    # ${resp}=    Get ProviderConsumer FamilyMember     ${cid}     ${account_id}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable     ${fid}    ${resp.json()[0]['id']}

    ${resp}=  Get Appointment Schedules Consumer  ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${account_id}
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

    ${apptfor1}=  Create Dictionary  id=${fid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${account_id}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Not Contain   ${resp.json()['subServiceData']}                               ${subser_id1}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME42}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Not Contain   ${resp.json()['subServiceData']}                               ${subser_id1}

    ${asgn_users}=   Create List  ${u_id1}
    ${subser_qnty}=   Random Int   min=1   max=5
    # ${subser_qnty}=  Convert To Number  ${subser_qnty}  1
    
    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   quantity=${subser_qnty}  assigneeUsers=${asgn_users}
    
    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total}=    Evaluate    ${subser_qnty}*${subser_price}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceId']}        ${subser_id1}
    
    ${resp}=   Get Appointment level Bill Details      ${apptid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${filter}=  Create Dictionary      
    ${resp}=  Generate Report REST details  ${reportType[6]}  ${Report_Date_Category[4]}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}
    
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${tot_amt}   ${resp.json()['reportContent']['dataHeader']['Grand Total']}

    ${total_amt}=    Evaluate    ${ser_amount}+${total}
    ${ser_date} =	Convert Date	${DAY1}	result_format=%d-%m-%Y
    ${tot_amt} =    Replace String    ${tot_amt}    Rs.     ${EMPTY}
    ${tot_amt} =    Replace String    ${tot_amt}    ,       ${EMPTY}
    ${tot_amt}=  Convert To Number  ${tot_amt}  1

    Should Be Equal As Strings  ${resp.json()['status']}                                        ${Report_Status[0]}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}                 ${fname} ${lname}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}                 1
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}                 ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}                 ${fname} ${lname}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}                 ${userf_name} ${userl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}                 ${subser_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}                 ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}                 ${total}
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}                        2
    Should Be Equal As Strings  ${tot_amt}                                                      ${total_amt}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                   User Performance Report
    Should Be Equal As Strings  ${resp.json()['reportType']}                                    ${reportType[6]}
    Should Be Equal As Strings  ${resp.json()['reportResponseType']}                            ${ReportResponseType[0]}
    Should Be Equal As Strings  ${resp.json()['reportTokenID']}                                 ${token_id1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}  ${Report_Date_Category[4]}   ignore_case=True


JD-TC-UserPerformanceReport-4

    [Documentation]   add multiple sub services to an appointment(walkin) for a provider consumer.
                ...   assign that subservices to a user and verify user performance report.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME43}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
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

    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
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
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${HLPUSERNAME43}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id1}=  Create Sample User
    Set Test Variable   ${u_id1}
   
    ${resp}=  Get User By Id  ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}
    Set Test Variable  ${userf_name}  ${resp.json()['firstName']}
    Set Test Variable  ${userl_name}  ${resp.json()['lastName']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${empty_list}=   Create List

    ${SERVICE1}=    FakerLibrary.word
    ${s_id}=  Create Sample Service  ${SERVICE1}   department=${dep_id}
   
    ${resp}=   Get Service By Id  ${s_id}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${ser_dur}      ${resp.json()['serviceDuration']}
    Set Test Variable   ${ser_amount}   ${resp.json()['totalAmount']}
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[1]}

    ##....subservice creation..........

    ${desc}=  FakerLibrary.sentence
    ${subser_dur}=   Random Int   min=5   max=10
    ${subser_price}=   Random Int   min=100   max=500
    ${subser_price}=  Convert To Number  ${subser_price}  1
    ${subser_name}=    FakerLibrary.firstname
   
    ${resp}=  Create Service    ${subser_name}  ${desc}  ${subser_dur}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price}
    ...    ${bool[0]}   ${bool[0]}   department=${dep_id}  serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${subser_id1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}

    ${desc1}=  FakerLibrary.sentence
    ${subser_dur1}=   Random Int   min=5   max=10
    ${subser_price1}=   Random Int   min=100   max=500
    ${subser_price1}=  Convert To Number  ${subser_price1}  1
    ${subser_name1}=    FakerLibrary.firstname
   
    ${resp}=  Create Service    ${subser_name1}  ${desc1}  ${subser_dur1}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price1}
    ...    ${bool[0]}   ${bool[0]}   department=${dep_id}  serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id2}  ${resp.json()}

    ${resp}=   Get Service By Id  ${subser_id2}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name1} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}

    ${desc2}=  FakerLibrary.sentence
    ${subser_dur2}=   Random Int   min=5   max=10
    ${subser_price2}=   Random Int   min=100   max=500
    ${subser_price2}=  Convert To Number  ${subser_price2}  1
    ${subser_name2}=    FakerLibrary.firstname
   
    ${resp}=  Create Service    ${subser_name2}  ${desc2}  ${subser_dur2}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price2}
    ...    ${bool[0]}   ${bool[0]}   department=${dep_id}  serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id3}  ${resp.json()}

    ${resp}=   Get Service By Id  ${subser_id3}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name2} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${locId}  ${duration}  ${bool1}  ${s_id}
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

    #............provider consumer creation..........

    ${NewCustomer}    Generate random string    10    123456789
    ${NewCustomer}    Convert To Integer  ${NewCustomer}

    ${custf_name}=  FakerLibrary.name    
    ${custl_name}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${NewCustomer}    firstName=${custf_name}   lastName=${custl_name}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Send Otp For Login    ${NewCustomer}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Customer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME43}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
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
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}

    ${asgn_users}=   Create List  ${u_id1}
    ${subser_qnty}=   Random Int   min=1   max=5
   
    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   quantity=${subser_qnty}  assigneeUsers=${asgn_users}
    ${subser_list2}=  Create Dictionary  serviceId=${subser_id2}  serviceAmount=${subser_price1}   quantity=${subser_qnty}  assigneeUsers=${asgn_users}
    ${subser_list3}=  Create Dictionary  serviceId=${subser_id3}  serviceAmount=${subser_price2}   quantity=${subser_qnty}  assigneeUsers=${asgn_users}
    
    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}  ${subser_list2}  ${subser_list3}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total}=    Evaluate    ${subser_qnty}*${subser_price}
    ${total1}=    Evaluate    ${subser_qnty}*${subser_price1}
    ${total2}=    Evaluate    ${subser_qnty}*${subser_price2}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceId']}        ${subser_id1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][2]['serviceId']}        ${subser_id2}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][3]['serviceId']}        ${subser_id3}
    
    ${resp}=   Get Appointment level Bill Details      ${apptid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${filter}=  Create Dictionary      
    ${resp}=  Generate Report REST details  ${reportType[6]}  ${Report_Date_Category[4]}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}
  
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${tot_amt}   ${resp.json()['reportContent']['dataHeader']['Grand Total']}

    ${total_amt}=    Evaluate    ${ser_amount}+${total}+${total1}+${total2}
    ${ser_date} =	Convert Date	${DAY1}	result_format=%d-%m-%Y
    ${tot_amt} =    Replace String    ${tot_amt}    Rs.     ${EMPTY}
    ${tot_amt} =    Replace String    ${tot_amt}    ,       ${EMPTY}
    ${tot_amt}=  Convert To Number  ${tot_amt}  1

    Should Be Equal As Strings  ${resp.json()['status']}                                        ${Report_Status[0]}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}                 1
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}                 ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}                 ${userf_name} ${userl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}                 ${subser_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}                 ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}                 ${total}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}                 ${userf_name} ${userl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}                 ${subser_name1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}                 ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}                 ${total1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['4']}                 ${userf_name} ${userl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['5']}                 ${subser_name2}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['6']}                 ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['7']}                 ${total2}
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}                        4
    Should Be Equal As Strings  ${tot_amt}                                                      ${total_amt}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                   User Performance Report
    Should Be Equal As Strings  ${resp.json()['reportType']}                                    ${reportType[6]}
    Should Be Equal As Strings  ${resp.json()['reportResponseType']}                            ${ReportResponseType[0]}
    Should Be Equal As Strings  ${resp.json()['reportTokenID']}                                 ${token_id1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}  ${Report_Date_Category[4]}   ignore_case=True

JD-TC-UserPerformanceReport-5

    [Documentation]   add multiple sub services to an appointment(walkin) for a provider consumer.
                ...   update one sub service with a new amount.
                ...   verify user performance report.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME44}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
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

    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
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
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${HLPUSERNAME44}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id1}=  Create Sample User
    Set Test Variable   ${u_id1}
   
    ${resp}=  Get User By Id  ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}
    Set Test Variable  ${userf_name}  ${resp.json()['firstName']}
    Set Test Variable  ${userl_name}  ${resp.json()['lastName']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${empty_list}=   Create List

    ${SERVICE1}=    FakerLibrary.word
    ${s_id}=  Create Sample Service  ${SERVICE1}   department=${dep_id}
   
    ${resp}=   Get Service By Id  ${s_id}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${ser_dur}      ${resp.json()['serviceDuration']}
    Set Test Variable   ${ser_amount}   ${resp.json()['totalAmount']}
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[1]}

    ##....subservice creation..........

    ${desc}=  FakerLibrary.sentence
    ${subser_dur}=   Random Int   min=5   max=10
    ${subser_price}=   Random Int   min=100   max=500
    ${subser_price}=  Convert To Number  ${subser_price}  1
    ${subser_name}=    FakerLibrary.firstname
   
    ${resp}=  Create Service    ${subser_name}  ${desc}  ${subser_dur}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price}
    ...    ${bool[0]}   ${bool[0]}   department=${dep_id}  serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${subser_id1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}

    ${desc1}=  FakerLibrary.sentence
    ${subser_dur1}=   Random Int   min=5   max=10
    ${subser_price1}=   Random Int   min=100   max=500
    ${subser_price1}=  Convert To Number  ${subser_price1}  1
    ${subser_name1}=    FakerLibrary.lastname
   
    ${resp}=  Create Service    ${subser_name1}  ${desc1}  ${subser_dur1}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price1}
    ...    ${bool[0]}   ${bool[0]}   department=${dep_id}  serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id2}  ${resp.json()}

    ${resp}=   Get Service By Id  ${subser_id2}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name1} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}

    ${desc2}=  FakerLibrary.sentence
    ${subser_dur2}=   Random Int   min=5   max=10
    ${subser_price2}=   Random Int   min=100   max=500
    ${subser_price2}=  Convert To Number  ${subser_price2}  1
    ${subser_name2}=    FakerLibrary.name
   
    ${resp}=  Create Service    ${subser_name2}  ${desc2}  ${subser_dur2}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price2}
    ...    ${bool[0]}   ${bool[0]}   department=${dep_id}  serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id3}  ${resp.json()}

    ${resp}=   Get Service By Id  ${subser_id3}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name2} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${locId}  ${duration}  ${bool1}  ${s_id}
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

    #............provider consumer creation..........

    ${NewCustomer}    Generate random string    10    123456789
    ${NewCustomer}    Convert To Integer  ${NewCustomer}

    ${custf_name}=  FakerLibrary.name    
    ${custl_name}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${NewCustomer}    firstName=${custf_name}   lastName=${custl_name}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Send Otp For Login    ${NewCustomer}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Customer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME44}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
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
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}

    ${asgn_users}=   Create List  ${u_id1}
    ${subser_qnty}=   Random Int   min=1   max=5
   
    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   quantity=${subser_qnty}  assigneeUsers=${asgn_users}
    ${subser_list2}=  Create Dictionary  serviceId=${subser_id2}  serviceAmount=${subser_price1}   quantity=${subser_qnty}  assigneeUsers=${asgn_users}
    ${subser_list3}=  Create Dictionary  serviceId=${subser_id3}  serviceAmount=${subser_price2}   quantity=${subser_qnty}  assigneeUsers=${asgn_users}
    
    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}  ${subser_list2}  ${subser_list3}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total}=    Evaluate    ${subser_qnty}*${subser_price}
    ${total1}=    Evaluate    ${subser_qnty}*${subser_price1}
    ${total2}=    Evaluate    ${subser_qnty}*${subser_price2}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceId']}        ${subser_id1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][2]['serviceId']}        ${subser_id2}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][3]['serviceId']}        ${subser_id3}
    Set Test Variable   ${seq_id1}      ${resp.json()['subServiceData'][1]['sequenceId']}
    
    ${resp}=   Get Appointment level Bill Details      ${apptid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${filter}=  Create Dictionary      
    ${resp}=  Generate Report REST details  ${reportType[6]}  ${Report_Date_Category[4]}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}
  
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${tot_amt}   ${resp.json()['reportContent']['dataHeader']['Grand Total']}

    ${total_amt}=    Evaluate    ${ser_amount}+${total}+${total1}+${total2}
    ${ser_date} =	Convert Date	${DAY1}	result_format=%d-%m-%Y
    ${tot_amt} =    Replace String    ${tot_amt}    Rs.     ${EMPTY}
    ${tot_amt} =    Replace String    ${tot_amt}    ,       ${EMPTY}
    ${tot_amt}=  Convert To Number  ${tot_amt}  1

    Should Be Equal As Strings  ${resp.json()['status']}                                        ${Report_Status[0]}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}                 1
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}                 ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}                 ${userf_name} ${userl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}                 ${subser_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}                 ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}                 ${total}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}                 ${userf_name} ${userl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}                 ${subser_name1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}                 ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}                 ${total1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['4']}                 ${userf_name} ${userl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['5']}                 ${subser_name2}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['6']}                 ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['7']}                 ${total2}
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}                        4
    Should Be Equal As Strings  ${tot_amt}                                                      ${total_amt}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                   User Performance Report
    Should Be Equal As Strings  ${resp.json()['reportType']}                                    ${reportType[6]}
    Should Be Equal As Strings  ${resp.json()['reportResponseType']}                            ${ReportResponseType[0]}
    Should Be Equal As Strings  ${resp.json()['reportTokenID']}                                 ${token_id1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}  ${Report_Date_Category[4]}   ignore_case=True

    ${newsubser_price}=   Random Int   min=500   max=700
    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${newsubser_price}    quantity=${subser_qnty}   sequenceId=${seq_id1}
    
    ${resp}=   Update SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total11}=    Evaluate    ${subser_qnty}*${newsubser_price}
    ${total11}=  Convert To Number  ${total11}  1

    ${resp}=  Generate Report REST details  ${reportType[6]}  ${Report_Date_Category[4]}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id2}   ${resp.json()}

    ${resp}=  Get Report Status By Token Id  ${token_id2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${tot_amt1}   ${resp.json()['reportContent']['dataHeader']['Grand Total']}

    ${total_amt1}=    Evaluate    ${ser_amount}+${total1}+${total11}+${total2}
    ${tot_amt1} =    Replace String    ${tot_amt1}    Rs.     ${EMPTY}
    ${tot_amt1} =    Replace String    ${tot_amt1}    ,       ${EMPTY}
    ${tot_amt1}=  Convert To Number  ${tot_amt1}  1

    Should Be Equal As Strings  ${resp.json()['status']}                                        ${Report_Status[0]}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}                 1
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}                 ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}                 ${userf_name} ${userl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}                 ${subser_name1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}                 ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}                 ${total1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}                 ${userf_name} ${userl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}                 ${subser_name2}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}                 ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}                 ${total2}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['5']}                 ${subser_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['6']}                 ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['7']}                 ${total11}
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}                        4
    Should Be Equal As Strings  ${tot_amt1}                                                      ${total_amt1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                   User Performance Report
    Should Be Equal As Strings  ${resp.json()['reportType']}                                    ${reportType[6]}
    Should Be Equal As Strings  ${resp.json()['reportResponseType']}                            ${ReportResponseType[0]}
    Should Be Equal As Strings  ${resp.json()['reportTokenID']}                                 ${token_id2}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}  ${Report_Date_Category[4]}   ignore_case=True

JD-TC-UserPerformanceReport-6

    [Documentation]   add multiple sub services to an appointment(walkin) for a provider consumer.
                ...   remove one sub service.
                ...   verify user performance report.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME45}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
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

    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
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
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${HLPUSERNAME45}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id1}=  Create Sample User
    Set Test Variable   ${u_id1}
   
    ${resp}=  Get User By Id  ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}
    Set Test Variable  ${userf_name}  ${resp.json()['firstName']}
    Set Test Variable  ${userl_name}  ${resp.json()['lastName']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${empty_list}=   Create List

    ${SERVICE1}=    FakerLibrary.word
    ${s_id}=  Create Sample Service  ${SERVICE1}   department=${dep_id}
   
    ${resp}=   Get Service By Id  ${s_id}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${ser_dur}      ${resp.json()['serviceDuration']}
    Set Test Variable   ${ser_amount}   ${resp.json()['totalAmount']}
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[1]}

    ##....subservice creation..........

    ${desc}=  FakerLibrary.sentence
    ${subser_dur}=   Random Int   min=5   max=10
    ${subser_price}=   Random Int   min=100   max=500
    ${subser_price}=  Convert To Number  ${subser_price}  1
    ${subser_name}=    FakerLibrary.firstname
   
    ${resp}=  Create Service    ${subser_name}  ${desc}  ${subser_dur}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price}
    ...    ${bool[0]}   ${bool[0]}   department=${dep_id}  serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${subser_id1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}

    ${desc1}=  FakerLibrary.sentence
    ${subser_dur1}=   Random Int   min=5   max=10
    ${subser_price1}=   Random Int   min=100   max=500
    ${subser_price1}=  Convert To Number  ${subser_price1}  1
    ${subser_name1}=    FakerLibrary.firstname
   
    ${resp}=  Create Service    ${subser_name1}  ${desc1}  ${subser_dur1}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price1}
    ...    ${bool[0]}   ${bool[0]}   department=${dep_id}  serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id2}  ${resp.json()}

    ${resp}=   Get Service By Id  ${subser_id2}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name1} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}

    ${desc2}=  FakerLibrary.sentence
    ${subser_dur2}=   Random Int   min=5   max=10
    ${subser_price2}=   Random Int   min=100   max=500
    ${subser_price2}=  Convert To Number  ${subser_price2}  1
    ${subser_name2}=    FakerLibrary.firstname
   
    ${resp}=  Create Service    ${subser_name2}  ${desc2}  ${subser_dur2}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price2}
    ...    ${bool[0]}   ${bool[0]}   department=${dep_id}  serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id3}  ${resp.json()}

    ${resp}=   Get Service By Id  ${subser_id3}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name2} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${locId}  ${duration}  ${bool1}  ${s_id}
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

    #............provider consumer creation..........

    ${NewCustomer}    Generate random string    10    123456789
    ${NewCustomer}    Convert To Integer  ${NewCustomer}

    ${custf_name}=  FakerLibrary.name    
    ${custl_name}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${NewCustomer}    firstName=${custf_name}   lastName=${custl_name}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Send Otp For Login    ${NewCustomer}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Customer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME45}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
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
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}

    ${asgn_users}=   Create List  ${u_id1}
    ${subser_qnty}=   Random Int   min=1   max=5
   
    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   quantity=${subser_qnty}  assigneeUsers=${asgn_users}
    ${subser_list2}=  Create Dictionary  serviceId=${subser_id2}  serviceAmount=${subser_price1}   quantity=${subser_qnty}  assigneeUsers=${asgn_users}
    ${subser_list3}=  Create Dictionary  serviceId=${subser_id3}  serviceAmount=${subser_price2}   quantity=${subser_qnty}  assigneeUsers=${asgn_users}
    
    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}  ${subser_list2}  ${subser_list3}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total}=    Evaluate    ${subser_qnty}*${subser_price}
    ${total1}=    Evaluate    ${subser_qnty}*${subser_price1}
    ${total2}=    Evaluate    ${subser_qnty}*${subser_price2}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceId']}        ${subser_id1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][2]['serviceId']}        ${subser_id2}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][3]['serviceId']}        ${subser_id3}
    Set Test Variable   ${seq_id1}      ${resp.json()['subServiceData'][1]['sequenceId']}
    
    ${resp}=   Get Appointment level Bill Details      ${apptid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${filter}=  Create Dictionary      
    ${resp}=  Generate Report REST details  ${reportType[6]}  ${Report_Date_Category[4]}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}
  
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${tot_amt}   ${resp.json()['reportContent']['dataHeader']['Grand Total']}

    ${total_amt}=    Evaluate    ${ser_amount}+${total}+${total1}+${total2}
    ${ser_date} =	Convert Date	${DAY1}	result_format=%d-%m-%Y
    ${tot_amt} =    Replace String    ${tot_amt}    Rs.     ${EMPTY}
    ${tot_amt} =    Replace String    ${tot_amt}    ,       ${EMPTY}
    ${tot_amt}=  Convert To Number  ${tot_amt}  1

    Should Be Equal As Strings  ${resp.json()['status']}                                        ${Report_Status[0]}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}                 1
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}                 ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}                 ${userf_name} ${userl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}                 ${subser_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}                 ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}                 ${total}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}                 ${userf_name} ${userl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}                 ${subser_name1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}                 ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}                 ${total1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['4']}                 ${userf_name} ${userl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['5']}                 ${subser_name2}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['6']}                 ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['7']}                 ${total2}
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}                        4
    Should Be Equal As Strings  ${tot_amt}                                                      ${total_amt}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                   User Performance Report
    Should Be Equal As Strings  ${resp.json()['reportType']}                                    ${reportType[6]}
    Should Be Equal As Strings  ${resp.json()['reportResponseType']}                            ${ReportResponseType[0]}
    Should Be Equal As Strings  ${resp.json()['reportTokenID']}                                 ${token_id1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}  ${Report_Date_Category[4]}   ignore_case=True

    ${subser_list2}=  Create Dictionary  serviceId=${subser_id1}  sequenceId=${seq_id1}
    
    ${resp}=   Remove SubService From Appointment    ${apptid1}   ${subser_list2}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Generate Report REST details  ${reportType[6]}  ${Report_Date_Category[4]}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id2}   ${resp.json()}

    ${resp}=  Get Report Status By Token Id  ${token_id2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${tot_amt1}   ${resp.json()['reportContent']['dataHeader']['Grand Total']}

    ${total_amt1}=    Evaluate    ${ser_amount}+${total1}+${total2}
    ${tot_amt1} =    Replace String    ${tot_amt1}    Rs.     ${EMPTY}
    ${tot_amt1} =    Replace String    ${tot_amt1}    ,       ${EMPTY}
    ${tot_amt1}=  Convert To Number  ${tot_amt1}  1

    Should Be Equal As Strings  ${resp.json()['status']}                                        ${Report_Status[0]}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}                 1
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}                 ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}                 ${userf_name} ${userl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}                 ${subser_name1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}                 ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}                 ${total1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}                 ${userf_name} ${userl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}                 ${subser_name2}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}                 ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}                 ${total2}
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}                        3
    Should Be Equal As Strings  ${tot_amt1}                                                      ${total_amt1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                   User Performance Report
    Should Be Equal As Strings  ${resp.json()['reportType']}                                    ${reportType[6]}
    Should Be Equal As Strings  ${resp.json()['reportResponseType']}                            ${ReportResponseType[0]}
    Should Be Equal As Strings  ${resp.json()['reportTokenID']}                                 ${token_id2}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}  ${Report_Date_Category[4]}   ignore_case=True

JD-TC-UserPerformanceReport-7

    [Documentation]   add sub services to two appointments(walkin and online) for a provider consumer.
                ...   verify user performance report with service filter.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME46}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
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

    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
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
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${HLPUSERNAME46}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id1}=  Create Sample User
    Set Test Variable   ${u_id1}
   
    ${resp}=  Get User By Id  ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}
    Set Test Variable  ${userf_name}  ${resp.json()['firstName']}
    Set Test Variable  ${userl_name}  ${resp.json()['lastName']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${FUTDAY}=  db.add_timezone_date  ${tz}  1
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${empty_list}=   Create List

    ${SERVICE1}=    FakerLibrary.word
    ${s_id}=  Create Sample Service  ${SERVICE1}   department=${dep_id}
   
    ${resp}=   Get Service By Id  ${s_id}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${ser_dur}      ${resp.json()['serviceDuration']}
    Set Test Variable   ${ser_amount}   ${resp.json()['totalAmount']}
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[1]}

    ##....subservice creation..........

    ${desc}=  FakerLibrary.sentence
    ${subser_dur}=   Random Int   min=5   max=10
    ${subser_price}=   Random Int   min=100   max=500
    ${subser_price}=  Convert To Number  ${subser_price}  1
    ${subser_name}=    FakerLibrary.firstname
   
    ${resp}=  Create Service    ${subser_name}  ${desc}  ${subser_dur}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price}
    ...    ${bool[0]}   ${bool[0]}   department=${dep_id}  serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${subser_id1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${locId}  ${duration}  ${bool1}  ${s_id}
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

    #............provider consumer creation..........

    ${NewCustomer}    Generate random string    10    123456789
    ${NewCustomer}    Convert To Integer  ${NewCustomer}

    ${custf_name}=  FakerLibrary.name    
    ${custl_name}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${NewCustomer}    firstName=${custf_name}   lastName=${custl_name}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Send Otp For Login    ${NewCustomer}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=  Get Appointment Schedules Consumer  ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${account_id}
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

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${account_id}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Not Contain   ${resp.json()['subServiceData']}                               ${subser_id1}

    ${resp}=    Customer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME46}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${FUTDAY}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${asgn_users}=   Create List  ${u_id1}
    ${subser_qnty}=   Random Int   min=1   max=5
   
    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   quantity=${subser_qnty}  assigneeUsers=${asgn_users}
   
    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}  
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Add SubService To Appointment    ${apptid2}   ${subser_list1}  
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total}=    Evaluate    ${subser_qnty}*${subser_price}
   
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceId']}        ${subser_id1}
    
    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceId']}        ${subser_id1}
    
    ${resp}=   Get Appointment level Bill Details      ${apptid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment level Bill Details      ${apptid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${subser_id1}  Convert To String  ${subser_id1}
    ${filter}=  Create Dictionary    service-eq=${subser_id1}
    ${resp}=  Generate Report REST details  ${reportType[6]}  ${Report_Date_Category[4]}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}
  
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${tot_amt}   ${resp.json()['reportContent']['dataHeader']['Grand Total']}

    ${total_amt}=    Evaluate    ${total}*2
    ${ser_date} =	Convert Date	${DAY1}	result_format=%d-%m-%Y
    ${tot_amt} =    Replace String    ${tot_amt}    Rs.     ${EMPTY}
    ${tot_amt} =    Replace String    ${tot_amt}    ,       ${EMPTY}
    ${tot_amt}=  Convert To Number  ${tot_amt}  1

    ${len}=  Get Length  ${resp.json()['reportContent']['data']}

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()['reportContent']['data'][${i}]['2']}' == '${encId1}'  
            Should Be Equal As Strings  ${resp.json()['status']}                                    ${Report_Status[0]}
            Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}          ${ser_date}
            Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}          ${custf_name} ${custl_name}
            Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}          ${userf_name} ${userl_name}
            Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}          ${subser_name}
            Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}          ${subser_qnty}
            Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}          ${total}

        ELSE IF     '${resp.json()['reportContent']['data'][${i}]['2']}' == '${encId2}'            
            Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}          ${ser_date}
            Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}          ${custf_name} ${custl_name}
            Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}          ${userf_name} ${userl_name}
            Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}          ${subser_name}
            Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}          ${subser_qnty}
            Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}          ${total}
        END
    END
    Should Be Equal As Strings  ${resp.json()['status']}                                        ${Report_Status[0]}
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}                        2
    Should Be Equal As Strings  ${tot_amt}                                                      ${total_amt}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                   User Performance Report
    Should Be Equal As Strings  ${resp.json()['reportType']}                                    ${reportType[6]}
    Should Be Equal As Strings  ${resp.json()['reportResponseType']}                            ${ReportResponseType[0]}
    Should Be Equal As Strings  ${resp.json()['reportTokenID']}                                 ${token_id1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}  ${Report_Date_Category[4]}   ignore_case=True

    ${s_id}  Convert To String  ${s_id}
    ${filter}=  Create Dictionary    service-eq=${s_id}
    ${resp}=  Generate Report REST details  ${reportType[6]}  ${Report_Date_Category[4]}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id2}   ${resp.json()}
  
    ${resp}=  Get Report Status By Token Id  ${token_id2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${tot_amt}   ${resp.json()['reportContent']['dataHeader']['Grand Total']}

    ${ser_date} =	Convert Date	${DAY1}	result_format=%d-%m-%Y
    ${tot_amt} =    Replace String    ${tot_amt}    Rs.     ${EMPTY}
    ${tot_amt} =    Replace String    ${tot_amt}    ,       ${EMPTY}
    ${tot_amt}=  Convert To Number  ${tot_amt}  1

    Should Be Equal As Strings  ${resp.json()['status']}                                        ${Report_Status[0]}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}                 ${encId1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}                 1
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}                 ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}                        1
    Should Be Equal As Strings  ${tot_amt}                                                      ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                   User Performance Report
    Should Be Equal As Strings  ${resp.json()['reportType']}                                    ${reportType[6]}
    Should Be Equal As Strings  ${resp.json()['reportResponseType']}                            ${ReportResponseType[0]}
    Should Be Equal As Strings  ${resp.json()['reportTokenID']}                                 ${token_id2}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}  ${Report_Date_Category[4]}   ignore_case=True

JD-TC-UserPerformanceReport-8

    [Documentation]  Create a sub service and add that sub service to an appointment(walkin) for a provider consumer.
                ...   assign that subservice to a user and verify user performance report with assignee filter.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME47}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
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

    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
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
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${HLPUSERNAME47}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id1}=  Create Sample User
    Set Test Variable   ${u_id1}
   
    ${resp}=  Get User By Id  ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}
    Set Test Variable  ${userf_name}  ${resp.json()['firstName']}
    Set Test Variable  ${userl_name}  ${resp.json()['lastName']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${empty_list}=   Create List

    ${SERVICE1}=    FakerLibrary.word
    ${s_id}=  Create Sample Service  ${SERVICE1}   department=${dep_id}
   
    ${resp}=   Get Service By Id  ${s_id}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${ser_dur}      ${resp.json()['serviceDuration']}
    Set Test Variable   ${ser_amount}   ${resp.json()['totalAmount']}
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[1]}

    ##....subservice creation..........

    ${desc}=  FakerLibrary.sentence
    ${subser_dur}=   Random Int   min=5   max=10
    ${subser_price}=   Random Int   min=100   max=500
    ${subser_price}=  Convert To Number  ${subser_price}  1
    ${subser_name}=    FakerLibrary.firstname
   
    ${resp}=  Create Service    ${subser_name}  ${desc}  ${subser_dur}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price}
    ...    ${bool[0]}   ${bool[0]}   department=${dep_id}  serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${subser_id1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${locId}  ${duration}  ${bool1}  ${s_id}
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

    #............provider consumer creation..........

    ${NewCustomer}    Generate random string    10    123456789
    ${NewCustomer}    Convert To Integer  ${NewCustomer}

    ${custf_name}=  FakerLibrary.name    
    ${custl_name}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${NewCustomer}    firstName=${custf_name}   lastName=${custl_name}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Send Otp For Login    ${NewCustomer}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Customer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME47}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
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
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Not Contain   ${resp.json()['subServiceData']}                               ${subser_id1}

    ${asgn_users}=   Create List  ${u_id1}
    ${subser_qnty}=   Random Int   min=1   max=5
   
    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   quantity=${subser_qnty}  assigneeUsers=${asgn_users}
    
    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total}=    Evaluate    ${subser_qnty}*${subser_price}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceId']}        ${subser_id1}
    
    ${resp}=   Get Appointment level Bill Details      ${apptid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${u_id1}  Convert To String  ${u_id1}
    ${filter}=  Create Dictionary    assignee-eq=${u_id1}
    ${resp}=  Generate Report REST details  ${reportType[6]}  ${Report_Date_Category[4]}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}
  
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${tot_amt}   ${resp.json()['reportContent']['dataHeader']['Grand Total']}

    ${ser_date} =	Convert Date	${DAY1}	result_format=%d-%m-%Y
    ${tot_amt} =    Replace String    ${tot_amt}    Rs.     ${EMPTY}
    ${tot_amt} =    Replace String    ${tot_amt}    ,       ${EMPTY}
    ${tot_amt}=  Convert To Number  ${tot_amt}  1

    Should Be Equal As Strings  ${resp.json()['status']}                                        ${Report_Status[0]}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}                 ${userf_name} ${userl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}                 ${subser_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}                 ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}                 ${total}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}                        1
    Should Be Equal As Strings  ${tot_amt}                                                      ${total}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                   User Performance Report
    Should Be Equal As Strings  ${resp.json()['reportType']}                                    ${reportType[6]}
    Should Be Equal As Strings  ${resp.json()['reportResponseType']}                            ${ReportResponseType[0]}
    Should Be Equal As Strings  ${resp.json()['reportTokenID']}                                 ${token_id1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}  ${Report_Date_Category[4]}   ignore_case=True

JD-TC-UserPerformanceReport-9

    [Documentation]  Create a sub service and add that sub service to an appointment(walkin) for a provider consumer.
                ...   assign that subservice to multiple users and verify user performance report with assignee filter.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME48}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
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

    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
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
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${HLPUSERNAME48}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id1}=  Create Sample User
    Set Test Variable   ${u_id1}
   
    ${resp}=  Get User By Id  ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}
    Set Test Variable  ${userf_name}  ${resp.json()['firstName']}
    Set Test Variable  ${userl_name}  ${resp.json()['lastName']}

    ${u_id2}=  Create Sample User
    Set Test Variable   ${u_id2}
   
    ${resp}=  Get User By Id  ${u_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BUSER_U2}  ${resp.json()['mobileNo']}
    Set Test Variable  ${userf_name2}  ${resp.json()['firstName']}
    Set Test Variable  ${userl_name2}  ${resp.json()['lastName']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${empty_list}=   Create List

    ${SERVICE1}=    FakerLibrary.word
    ${s_id}=  Create Sample Service  ${SERVICE1}   department=${dep_id}
   
    ${resp}=   Get Service By Id  ${s_id}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${ser_dur}      ${resp.json()['serviceDuration']}
    Set Test Variable   ${ser_amount}   ${resp.json()['totalAmount']}
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[1]}

    ##....subservice creation..........

    ${desc}=  FakerLibrary.sentence
    ${subser_dur}=   Random Int   min=5   max=10
    ${subser_price}=   Random Int   min=100   max=500
    ${subser_price}=  Convert To Number  ${subser_price}  1
    ${subser_name}=    FakerLibrary.firstname
   
    ${resp}=  Create Service    ${subser_name}  ${desc}  ${subser_dur}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price}
    ...    ${bool[0]}   ${bool[0]}   department=${dep_id}  serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${subser_id1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${locId}  ${duration}  ${bool1}  ${s_id}
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

    #............provider consumer creation..........

    ${NewCustomer}    Generate random string    10    123456789
    ${NewCustomer}    Convert To Integer  ${NewCustomer}

    ${custf_name}=  FakerLibrary.name    
    ${custl_name}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${NewCustomer}    firstName=${custf_name}   lastName=${custl_name}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Send Otp For Login    ${NewCustomer}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Customer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME48}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
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
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Not Contain   ${resp.json()['subServiceData']}                               ${subser_id1}

    ${asgn_users}=   Create List  ${u_id1}   ${u_id2}
    ${subser_qnty}=   Random Int   min=1   max=5
   
    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   quantity=${subser_qnty}  assigneeUsers=${asgn_users}
    
    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total}=    Evaluate    ${subser_qnty}*${subser_price}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceId']}        ${subser_id1}
    
    ${resp}=   Get Appointment level Bill Details      ${apptid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${u_id1}  Convert To String  ${u_id1}
    ${u_id2}  Convert To String  ${u_id2}
    ${filter}=  Create Dictionary    assignee-eq=${u_id1},${u_id2}
    ${resp}=  Generate Report REST details  ${reportType[6]}  ${Report_Date_Category[4]}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}
  
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${tot_amt}   ${resp.json()['reportContent']['dataHeader']['Grand Total']}

    ${ser_date} =	Convert Date	${DAY1}	result_format=%d-%m-%Y
    ${tot_amt} =    Replace String    ${tot_amt}    Rs.     ${EMPTY}
    ${tot_amt} =    Replace String    ${tot_amt}    ,       ${EMPTY}
    ${tot_amt}=  Convert To Number  ${tot_amt}  1

    Should Be Equal As Strings  ${resp.json()['status']}                                        ${Report_Status[0]}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}                 ${userf_name} ${userl_name}, ${userf_name2} ${userl_name2}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}                 ${subser_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}                 ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}                 ${total}
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}                        1
    Should Be Equal As Strings  ${tot_amt}                                                      ${total}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                   User Performance Report
    Should Be Equal As Strings  ${resp.json()['reportType']}                                    ${reportType[6]}
    Should Be Equal As Strings  ${resp.json()['reportResponseType']}                            ${ReportResponseType[0]}
    Should Be Equal As Strings  ${resp.json()['reportTokenID']}                                 ${token_id1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}  ${Report_Date_Category[4]}   ignore_case=True

JD-TC-UserPerformanceReport-10

    [Documentation]  Create a sub service and add that sub service to an appointment(walkin) for a provider consumer.
                ...   assign that subservice to multiple users and verify user performance report with assignee filter.
                ...   then update with one assignee and verify the report with assignee filter.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME49}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
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

    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
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
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${HLPUSERNAME49}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id1}=  Create Sample User
    Set Test Variable   ${u_id1}
   
    ${resp}=  Get User By Id  ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}
    Set Test Variable  ${userf_name}  ${resp.json()['firstName']}
    Set Test Variable  ${userl_name}  ${resp.json()['lastName']}

    ${u_id2}=  Create Sample User
    Set Test Variable   ${u_id2}
   
    ${resp}=  Get User By Id  ${u_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BUSER_U2}  ${resp.json()['mobileNo']}
    Set Test Variable  ${userf_name2}  ${resp.json()['firstName']}
    Set Test Variable  ${userl_name2}  ${resp.json()['lastName']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${empty_list}=   Create List

    ${SERVICE1}=    FakerLibrary.word
    ${s_id}=  Create Sample Service  ${SERVICE1}   department=${dep_id}
   
    ${resp}=   Get Service By Id  ${s_id}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${ser_dur}      ${resp.json()['serviceDuration']}
    Set Test Variable   ${ser_amount}   ${resp.json()['totalAmount']}
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[1]}

    ##....subservice creation..........

    ${desc}=  FakerLibrary.sentence
    ${subser_dur}=   Random Int   min=5   max=10
    ${subser_price}=   Random Int   min=100   max=500
    ${subser_price}=  Convert To Number  ${subser_price}  1
    ${subser_name}=    FakerLibrary.firstname
   
    ${resp}=  Create Service    ${subser_name}  ${desc}  ${subser_dur}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price}
    ...    ${bool[0]}   ${bool[0]}   department=${dep_id}  serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${subser_id1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${locId}  ${duration}  ${bool1}  ${s_id}
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

    #............provider consumer creation..........

    ${NewCustomer}    Generate random string    10    123456789
    ${NewCustomer}    Convert To Integer  ${NewCustomer}

    ${custf_name}=  FakerLibrary.name    
    ${custl_name}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${NewCustomer}    firstName=${custf_name}   lastName=${custl_name}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Send Otp For Login    ${NewCustomer}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Customer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME49}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
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
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Not Contain   ${resp.json()['subServiceData']}                               ${subser_id1}

    ${asgn_users}=   Create List  ${u_id1}   ${u_id2}
    ${subser_qnty}=   Random Int   min=1   max=5
   
    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   quantity=${subser_qnty}  assigneeUsers=${asgn_users}
    
    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total}=    Evaluate    ${subser_qnty}*${subser_price}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceId']}        ${subser_id1}
    
    ${resp}=   Get Appointment level Bill Details      ${apptid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${u_id1}  Convert To String  ${u_id1}
    ${u_id2}  Convert To String  ${u_id2}
    ${filter}=  Create Dictionary    assignee-eq=${u_id1},${u_id2}
    ${resp}=  Generate Report REST details  ${reportType[6]}  ${Report_Date_Category[4]}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}
  
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${tot_amt}   ${resp.json()['reportContent']['dataHeader']['Grand Total']}

    ${ser_date} =	Convert Date	${DAY1}	result_format=%d-%m-%Y
    ${tot_amt} =    Replace String    ${tot_amt}    Rs.     ${EMPTY}
    ${tot_amt} =    Replace String    ${tot_amt}    ,       ${EMPTY}
    ${tot_amt}=  Convert To Number  ${tot_amt}  1

    Should Be Equal As Strings  ${resp.json()['status']}                                        ${Report_Status[0]}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}                 ${userf_name} ${userl_name}, ${userf_name2} ${userl_name2}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}                 ${subser_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}                 ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}                 ${total}
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}                        1
    Should Be Equal As Strings  ${tot_amt}                                                      ${total}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                   User Performance Report
    Should Be Equal As Strings  ${resp.json()['reportType']}                                    ${reportType[6]}
    Should Be Equal As Strings  ${resp.json()['reportResponseType']}                            ${ReportResponseType[0]}
    Should Be Equal As Strings  ${resp.json()['reportTokenID']}                                 ${token_id1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}  ${Report_Date_Category[4]}   ignore_case=True

    ${asgn_users}=   Create List  ${u_id1}
    ${subser_list2}=  Create Dictionary  serviceId=${subser_id1}   serviceAmount=${subser_price}   quantity=${subser_qnty}  assigneeUsers=${asgn_users}
    
    ${resp}=   Update SubService To Appointment    ${apptid1}   ${subser_list2}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${filter}=  Create Dictionary    assignee-eq=${u_id1}
    ${resp}=  Generate Report REST details  ${reportType[6]}  ${Report_Date_Category[4]}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id2}   ${resp.json()}
  
    ${resp}=  Get Report Status By Token Id  ${token_id2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    Should Be Equal As Strings  ${resp.json()['status']}                                        ${Report_Status[0]}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}                 ${userf_name} ${userl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}                 ${subser_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}                 ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}                 ${total}
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}                        1
    Should Be Equal As Strings  ${tot_amt}                                                      ${total}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                   User Performance Report
    Should Be Equal As Strings  ${resp.json()['reportType']}                                    ${reportType[6]}
    Should Be Equal As Strings  ${resp.json()['reportResponseType']}                            ${ReportResponseType[0]}
    Should Be Equal As Strings  ${resp.json()['reportTokenID']}                                 ${token_id2}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}  ${Report_Date_Category[4]}   ignore_case=True

    ${filter}=  Create Dictionary    assignee-eq=${u_id2}
    ${resp}=  Generate Report REST details  ${reportType[6]}  ${Report_Date_Category[4]}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id3}   ${resp.json()}
  
    ${resp}=  Get Report Status By Token Id  ${token_id3}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}                        0

JD-TC-UserPerformanceReport-11

    [Documentation]  Create a sub service and add that sub service to an appointment(walkin) for a provider consumer.
                ...   then reshedule the appointment to another date then verify the user performance report.
               
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME49}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-UserPerformanceReport-12

    [Documentation]  Create a sub service and add that sub service to an appointment(walkin) for a provider consumer.
                ...   then reshedule the appointment to another date then verify the user performance report.
               
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME49}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
