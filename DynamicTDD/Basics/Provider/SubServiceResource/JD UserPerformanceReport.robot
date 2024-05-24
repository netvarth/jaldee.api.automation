*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        SubService
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
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py


*** Variables ***

${self}         0


*** Test Cases ***

JD-TC-UserPerformanceReport-1

    [Documentation]  Create a sub service and add that sub service to an appointment(walkin) for a provider consumer.
                ...   assign that subservice to a user and verify user performance report.
    
    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME40}  ${PASSWORD}
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
            IF   not '${user_phone}' == '${HLMUSERNAME40}'
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

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME40}  ${PASSWORD}
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
    ${subser_qnty}=  Convert To Number  ${subser_qnty}  1
    
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
    sleep  1s
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total_amt}=    Evaluate    ${ser_amount}+${subser_price}
    ${ser_date} =	Convert Date	${DAY1}	result_format=%d-%m-%Y

    Should Be Equal As Strings  ${resp.json()['status']}                            ${Report_Status[0]}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}     ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}     ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}     ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}     ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}     1.0
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}     ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}     ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}     ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}     ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}     ${userf_name} ${userl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}     ${subser_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}     ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}     ${subser_price}
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}            2
    Should Be Equal As Strings  ${resp.json()['dataHeader']['Grand Total']}         ${total_amt}
    Should Be Equal As Strings  ${resp.json()['reportName']}                        User Performance Report
    Should Be Equal As Strings  ${resp.json()['reportType']}                        ${reportType[6]}
    Should Be Equal As Strings  ${resp.json()['reportResponseType']}                ${ReportResponseType[0]}
    Should Be Equal As Strings  ${resp.json()['reportTokenID']}                     ${token_id1}
    Should Be Equal As Strings  ${resp.json()['reportHeader']['Time Period']}       ${Report_Date_Category[4]}
