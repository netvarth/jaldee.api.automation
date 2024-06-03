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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Variables ***

${self}         0


*** Test Cases ***

JD-TC-AddSubServicesToAppt-1

    [Documentation]  Create a sub service and add that sub service to an appointment(walkin).

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME172}  ${PASSWORD}
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
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

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
        Set Suite Variable   ${locId}

        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
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
        Set Suite Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${PUSERNAME172}'
                clear_users  ${user_phone}
            END
        END
    END

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

    ${u_id1}=  Create Sample User
    Set Suite Variable   ${u_id1}
   
    ${resp}=  Get User By Id  ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${empty_list}=   Create List

    ${SERVICE1}=    FakerLibrary.word
    Set Suite Variable   ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}   department=${dep_id}
    Set Suite Variable    ${s_id}

    ${resp}=   Get Service By Id  ${s_id}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${ser_dur}      ${resp.json()['serviceDuration']}
    Set Suite Variable   ${ser_amount}   ${resp.json()['totalAmount']}
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[1]}

    ##....subservice creation..........

    ${desc}=  FakerLibrary.sentence
    ${subser_dur}=   Random Int   min=5   max=10
    ${subser_price}=   Random Int   min=100   max=500
    ${subser_price}=  Convert To Number  ${subser_price}  1
    Set Suite Variable   ${subser_price}
    ${subser_name}=    FakerLibrary.firstname
    Set Suite Variable   ${subser_name}

    ${resp}=  Create Service    ${subser_name}  ${desc}  ${subser_dur}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price}
    ...    ${bool[0]}   ${bool[0]}   department=${dep_id}  serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${subser_id1}  ${resp.json()}

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
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME11}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}   ${resp.json()}
    
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
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceName']}      ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceAmount']}    ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['quantity']}         1.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['totalPrice']}       ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['netRate']}          ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceCategory']}  ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['teamIds']}          ${empty_list}
    Should Not Contain   ${resp.json()}   ${subser_id1}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    appmtTime=${slot1}  apptStatus=${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME172}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}  
    
    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceName']}      ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceAmount']}    ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['quantity']}         1.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['totalPrice']}       ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['netRate']}          ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceCategory']}  ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['teamIds']}          ${empty_list}
   
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceId']}        ${subser_id1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceName']}      ${subser_name}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceAmount']}    ${subser_price}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['quantity']}         0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['totalPrice']}       0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['netRate']}          0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceCategory']}  ${serviceCategory[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['teamIds']}          ${empty_list}
   

JD-TC-AddSubServicesToAppt-2

    [Documentation]  Create a sub service and add that sub service to an appointment(online).

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${cid}=  get_id  ${CUSERNAME12}   
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${account_id}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid2}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceName']}      ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceAmount']}    ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['quantity']}         1.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['totalPrice']}       ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['netRate']}          ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceCategory']}  ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['teamIds']}          ${empty_list}
    Should Not Contain   ${resp.json()}   ${subser_id1}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME172}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceName']}      ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceAmount']}    ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['quantity']}         1.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['totalPrice']}       ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['netRate']}          ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceCategory']}  ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['teamIds']}          ${empty_list}
    Should Not Contain   ${resp.json()}   ${subser_id1}

    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}  
    
    ${resp}=   Add SubService To Appointment    ${apptid2}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceName']}      ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceAmount']}    ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['quantity']}         1.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['totalPrice']}       ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['netRate']}          ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceCategory']}  ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['teamIds']}          ${empty_list}
   
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceId']}        ${subser_id1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceName']}      ${subser_name}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceAmount']}    ${subser_price}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['quantity']}         0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['totalPrice']}       0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['netRate']}          0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceCategory']}  ${serviceCategory[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['teamIds']}          ${empty_list}
   

JD-TC-AddSubServicesToAppt-3

    [Documentation]  add subservice to an appointment with sub service quantity.

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME173}  ${PASSWORD}
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
    ${subser_qnty}=   Random Int   min=1   max=5
    ${subser_qnty}=  Convert To Number  ${subser_qnty}  1
   
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

    ${resp}=  AddCustomer  ${CUSERNAME3}  firstName=${fname}   lastName=${lname}
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
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceName']}      ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceAmount']}    ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['quantity']}         1.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['totalPrice']}       ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['netRate']}          ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceCategory']}  ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['teamIds']}          ${empty_list}
    Should Not Contain   ${resp.json()}   ${subser_id1}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    appmtTime=${slot1}  apptStatus=${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME173}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   quantity=${subser_qnty}
    
    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total}=    Evaluate    ${subser_qnty}*${subser_price}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceName']}      ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceAmount']}    ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['quantity']}         1.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['totalPrice']}       ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['netRate']}          ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceCategory']}  ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['teamIds']}          ${empty_list}
   
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceId']}        ${subser_id1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceName']}      ${subser_name}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceAmount']}    ${subser_price}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['quantity']}         ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['totalPrice']}       ${total}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['netRate']}          ${total}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceCategory']}  ${serviceCategory[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['teamIds']}          ${empty_list}
   


JD-TC-AddSubServicesToAppt-4

    [Documentation]  add subservice to an appointment with one assignee.

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME174}  ${PASSWORD}
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

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${PUSERNAME174}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id1}=  Create Sample User
   
    ${resp}=  Get User By Id  ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}

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
    ${subser_qnty}=   Random Int   min=1   max=5
    ${subser_qnty}=  Convert To Number  ${subser_qnty}  1
   
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

    ${resp}=  AddCustomer  ${CUSERNAME3}  firstName=${fname}   lastName=${lname}
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
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceName']}      ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceAmount']}    ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['quantity']}         1.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['totalPrice']}       ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['netRate']}          ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceCategory']}  ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['teamIds']}          ${empty_list}
    Should Not Contain   ${resp.json()}   ${subser_id1}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    appmtTime=${slot1}  apptStatus=${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME174}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${asgn_users}=   Create List  ${u_id1}
    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   quantity=${subser_qnty}  assigneeUsers=${asgn_users}
    
    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total}=    Evaluate    ${subser_qnty}*${subser_price}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceName']}      ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceAmount']}    ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['quantity']}         1.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['totalPrice']}       ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['netRate']}          ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceCategory']}  ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['teamIds']}          ${empty_list}
   
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceId']}        ${subser_id1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceName']}      ${subser_name}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceAmount']}    ${subser_price}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['quantity']}         ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['totalPrice']}       ${total}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['netRate']}          ${total}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceCategory']}  ${serviceCategory[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['assigneeUsers']}    ${asgn_users}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['teamIds']}          ${empty_list}
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SendProviderResetMail   ${BUSER_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BUSER_U1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceName']}      ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceAmount']}    ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['quantity']}         1.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['totalPrice']}       ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['netRate']}          ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceCategory']}  ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['teamIds']}          ${empty_list}
   
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceId']}        ${subser_id1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceName']}      ${subser_name}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceAmount']}    ${subser_price}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['quantity']}         ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['totalPrice']}       ${total}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['netRate']}          ${total}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceCategory']}  ${serviceCategory[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['assigneeUsers']}    ${asgn_users}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['teamIds']}          ${empty_list}
   

JD-TC-AddSubServicesToAppt-5

    [Documentation]  Create a sub service and add that sub service to multiple appointments(walkin).
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME172}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY2}=  db.add_timezone_date  ${tz}  1
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY2}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
   
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY2}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceName']}      ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceDate']}      ${DAY2}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceAmount']}    ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['quantity']}         1.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['totalPrice']}       ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['netRate']}          ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceCategory']}  ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['teamIds']}          ${empty_list}
    Should Not Contain   ${resp.json()}   ${subser_id1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceName']}      ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceAmount']}    ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['quantity']}         1.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['totalPrice']}       ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['netRate']}          ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceCategory']}  ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['teamIds']}          ${empty_list}
    Variable Should Exist    ${resp.json()}   ${subser_id1}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    appmtTime=${slot1}  apptStatus=${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME172}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${asgn_users}=   Create List  ${u_id1}
    ${subser_qnty}=   Random Int   min=1   max=5
    ${subser_qnty}=  Convert To Number  ${subser_qnty}  1
    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   quantity=${subser_qnty}  assigneeUsers=${asgn_users}
    
    ${resp}=   Add SubService To Appointment    ${apptid2}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total}=    Evaluate    ${subser_qnty}*${subser_price}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceName']}      ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceDate']}      ${DAY2}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceAmount']}    ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['quantity']}         1.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['totalPrice']}       ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['netRate']}          ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceCategory']}  ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['teamIds']}          ${empty_list}
   
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceId']}        ${subser_id1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceName']}      ${subser_name}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceAmount']}    ${subser_price}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['quantity']}         ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['totalPrice']}       ${total}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['netRate']}          ${total}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceCategory']}  ${serviceCategory[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['assigneeUsers']}    ${asgn_users}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['teamIds']}          ${empty_list}
   

JD-TC-AddSubServicesToAppt-6

    [Documentation]  Create a sub service and add that sub service to multiple appointments(online).

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${cid}=  get_id  ${CUSERNAME12}   
    ${cnote}=   FakerLibrary.name
    ${DAY2}=  db.add_timezone_date  ${tz}  1
    ${resp}=   Take Appointment For Provider   ${account_id}  ${s_id}  ${sch_id}  ${DAY2}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid3}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceName']}      ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceDate']}      ${DAY2}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceAmount']}    ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['quantity']}         1.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['totalPrice']}       ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['netRate']}          ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceCategory']}  ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['teamIds']}          ${empty_list}
    Should Not Contain   ${resp.json()}   ${subser_id1}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME172}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceName']}      ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceAmount']}    ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['quantity']}         1.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['totalPrice']}       ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['netRate']}          ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceCategory']}  ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['teamIds']}          ${empty_list}
    Variable Should Exist    ${resp.json()}   ${subser_id1}

    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}  
    
    ${resp}=   Add SubService To Appointment    ${apptid3}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceName']}      ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceDate']}      ${DAY2}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceAmount']}    ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['quantity']}         1.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['totalPrice']}       ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['netRate']}          ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceCategory']}  ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['teamIds']}          ${empty_list}
   
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceId']}        ${subser_id1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceName']}      ${subser_name}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceAmount']}    ${subser_price}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['quantity']}         0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['totalPrice']}       0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['netRate']}          0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceCategory']}  ${serviceCategory[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['teamIds']}          ${empty_list}
   

JD-TC-AddSubServicesToAppt-7

    [Documentation]  Create a sub service for a user and add that subservice to users appointment(walkin)

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME176}  ${PASSWORD}
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

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${PUSERNAME176}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id1}=  Create Sample User
   
    ${resp}=  Get User By Id  ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SendProviderResetMail   ${BUSER_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BUSER_U1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${empty_list}=   Create List

    ${SERVICE1}=    FakerLibrary.word
    ${s_id}=  Create Sample Service For User  ${SERVICE1}   ${dep_id}   ${u_id1}
   
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
    ${subser_qnty}=   Random Int   min=1   max=5
    ${subser_qnty}=  Convert To Number  ${subser_qnty}  1
   
    ${resp}=  Create Service For User   ${subser_name}  ${desc}  ${subser_dur}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price}
    ...    ${bool[0]}   ${bool[0]}  ${dep_id}  ${u_id1}  serviceCategory=${serviceCategory[0]}
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

    ${resp}=  Create Appointment Schedule For User   ${u_id1}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${locId}  ${duration}  ${bool1}  ${s_id}
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

    ${resp}=  AddCustomer  ${CUSERNAME5}  firstName=${fname}   lastName=${lname}
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

    ${asgn_users}=   Create List  ${u_id1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceName']}      ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceAmount']}    ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['quantity']}         1.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['totalPrice']}       ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['netRate']}          ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceCategory']}  ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['assigneeUsers']}    ${asgn_users}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['teamIds']}          ${empty_list}
    Should Not Contain   ${resp.json()}   ${subser_id1}

    # ${asgn_users}=   Create List  ${u_id1}
    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   quantity=${subser_qnty}  
    
    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total}=    Evaluate    ${subser_qnty}*${subser_price}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceName']}      ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceAmount']}    ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['quantity']}         1.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['totalPrice']}       ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['netRate']}          ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceCategory']}  ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['assigneeUsers']}    ${asgn_users}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['teamIds']}          ${empty_list}
   
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceId']}        ${subser_id1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceName']}      ${subser_name}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceAmount']}    ${subser_price}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['quantity']}         ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['totalPrice']}       ${total}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['netRate']}          ${total}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceCategory']}  ${serviceCategory[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['teamIds']}          ${empty_list}

JD-TC-AddSubServicesToAppt-8

    [Documentation]  Create a sub service for a user and add that subservice to another users appointment.

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
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

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${HLPUSERNAME18}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id1}=  Create Sample User
   
    ${resp}=  Get User By Id  ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}

    ${u_id2}=  Create Sample User
   
    ${resp}=  Get User By Id  ${u_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BUSER_U2}  ${resp.json()['mobileNo']}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SendProviderResetMail   ${BUSER_U2}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BUSER_U2}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BUSER_U2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ##....subservice creation..........

    ${desc}=  FakerLibrary.sentence
    ${subser_dur}=   Random Int   min=5   max=10
    ${subser_price}=   Random Int   min=100   max=500
    ${subser_price}=  Convert To Number  ${subser_price}  1
    ${subser_name}=    FakerLibrary.firstname
    ${subser_qnty}=   Random Int   min=1   max=5
    ${subser_qnty}=  Convert To Number  ${subser_qnty}  1
   
    ${resp}=  Create Service For User   ${subser_name}  ${desc}  ${subser_dur}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price}
    ...    ${bool[0]}   ${bool[0]}  ${dep_id}  ${u_id2}  serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${subser_id1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SendProviderResetMail   ${BUSER_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BUSER_U1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${empty_list}=   Create List

    ${SERVICE1}=    FakerLibrary.word
    ${s_id}=  Create Sample Service For User  ${SERVICE1}   ${dep_id}   ${u_id1}
   
    ${resp}=   Get Service By Id  ${s_id}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${ser_dur}      ${resp.json()['serviceDuration']}
    Set Test Variable   ${ser_amount}   ${resp.json()['totalAmount']}
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[1]}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule For User   ${u_id1}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${locId}  ${duration}  ${bool1}  ${s_id}
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

    ${resp}=  AddCustomer  ${CUSERNAME5}  firstName=${fname}   lastName=${lname}
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

    ${asgn_users}=   Create List  ${u_id1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceName']}      ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceAmount']}    ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['quantity']}         1.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['totalPrice']}       ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['netRate']}          ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceCategory']}  ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['assigneeUsers']}    ${asgn_users}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['teamIds']}          ${empty_list}
    Should Not Contain   ${resp.json()}   ${subser_id1}

    # ${asgn_users}=   Create List  ${u_id1}
    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   quantity=${subser_qnty}  
    
    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total}=    Evaluate    ${subser_qnty}*${subser_price}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceName']}      ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceAmount']}    ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['quantity']}         1.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['totalPrice']}       ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['netRate']}          ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceCategory']}  ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['assigneeUsers']}    ${asgn_users}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['teamIds']}          ${empty_list}
   
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceId']}        ${subser_id1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceName']}      ${subser_name}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceAmount']}    ${subser_price}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['quantity']}         ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['totalPrice']}       ${total}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['netRate']}          ${total}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceCategory']}  ${serviceCategory[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['teamIds']}          ${empty_list}


JD-TC-AddSubServicesToAppt-9

    [Documentation]  created a sub-service with a specified amount, adding the sub-service to the appointment with a different service amount.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME172}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${subser_price1}=   Random Int   min=10   max=50
    ${subser_price1}=  Convert To Number  ${subser_price1}  1
    ${subser_qnty}=   Random Int   min=1   max=5
    ${subser_qnty}=  Convert To Number  ${subser_qnty}  1
    
    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price1}   quantity=${subser_qnty}  

    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings     ${resp.status_code}    200
   
    ${total}=    Evaluate    ${subser_qnty}*${subser_price1}
    
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceId']}        ${subser_id1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceName']}      ${subser_name}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceAmount']}    ${subser_price}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['quantity']}         0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['totalPrice']}       0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['netRate']}          0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceCategory']}  ${serviceCategory[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['teamIds']}          ${empty_list}

    Should Be Equal As Strings  ${resp.json()['subServiceData'][2]['serviceId']}        ${subser_id1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][2]['serviceName']}      ${subser_name}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][2]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][2]['serviceAmount']}    ${subser_price1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][2]['quantity']}         ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][2]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][2]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][2]['totalPrice']}       ${total}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][2]['netRate']}          ${total}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][2]['serviceCategory']}  ${serviceCategory[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][2]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][2]['teamIds']}          ${empty_list}

JD-TC-AddSubServicesToAppt-10

    [Documentation]  add a subservice that conflicts with an existing one.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME172}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   

    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceId']}        ${subser_id1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceName']}      ${subser_name}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceAmount']}    ${subser_price}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['quantity']}         0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['totalPrice']}       0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['netRate']}          0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceCategory']}  ${serviceCategory[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['teamIds']}          ${empty_list}


JD-TC-AddSubServicesToAppt-11

    [Documentation]  Create multiple sub services and add that subservice to an appointment(walkin)

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME165}  ${PASSWORD}
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
    ${subser_qnty}=   Random Int   min=1   max=5
    ${subser_qnty}=  Convert To Number  ${subser_qnty}  1
   
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
    ${subser_qnty1}=   Random Int   min=1   max=5
    ${subser_qnty1}=  Convert To Number  ${subser_qnty1}  1
   
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

    ${resp}=  AddCustomer  ${CUSERNAME3}  firstName=${fname}   lastName=${lname}
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
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceName']}      ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceAmount']}    ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['quantity']}         1.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['totalPrice']}       ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['netRate']}          ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceCategory']}  ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['teamIds']}          ${empty_list}
    Should Not Contain   ${resp.json()}   ${subser_id1}
    Should Not Contain   ${resp.json()}   ${subser_id2}

    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   quantity=${subser_qnty}  
    ${subser_list2}=  Create Dictionary  serviceId=${subser_id2}  serviceAmount=${subser_price1}   quantity=${subser_qnty1}  
    
    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}   ${subser_list2}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total}=    Evaluate    ${subser_qnty}*${subser_price}
    ${total1}=    Evaluate    ${subser_qnty1}*${subser_price1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceName']}      ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceAmount']}    ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['quantity']}         1.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['totalPrice']}       ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['netRate']}          ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceCategory']}  ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['teamIds']}          ${empty_list}
   
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceId']}        ${subser_id1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceName']}      ${subser_name}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceAmount']}    ${subser_price}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['quantity']}         ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['totalPrice']}       ${total}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['netRate']}          ${total}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceCategory']}  ${serviceCategory[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['teamIds']}          ${empty_list}

    Should Be Equal As Strings  ${resp.json()['subServiceData'][2]['serviceId']}        ${subser_id2}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][2]['serviceName']}      ${subser_name1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][2]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][2]['serviceAmount']}    ${subser_price1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][2]['quantity']}         ${subser_qnty1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][2]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][2]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][2]['totalPrice']}       ${total1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][2]['netRate']}          ${total1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][2]['serviceCategory']}  ${serviceCategory[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][2]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][2]['teamIds']}          ${empty_list}

JD-TC-AddSubServicesToAppt-12

    [Documentation]  add a subservice to an appointment without service price.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
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
    ${subser_qnty}=   Random Int   min=1   max=5
    ${subser_qnty}=  Convert To Number  ${subser_qnty}  1
   
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

    ${resp}=  AddCustomer  ${NewCustomer}  
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
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceName']}      ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceAmount']}    ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['quantity']}         1.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['totalPrice']}       ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['netRate']}          ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceCategory']}  ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['teamIds']}          ${empty_list}
    Should Not Contain   ${resp.json()}   ${subser_id1}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceName']}      ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceAmount']}    ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['quantity']}         1.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['totalPrice']}       ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['netRate']}          ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceCategory']}  ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['teamIds']}          ${empty_list}
    Should Not Contain   ${resp.json()}   ${subser_id1}

    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${EMPTY} 
    
    ${resp}=   Add SubService To Appointment    ${apptid2}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total}=    Evaluate    ${subser_qnty}*${subser_price}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceName']}      ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceAmount']}    ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['quantity']}         1.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['totalPrice']}       ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['netRate']}          ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceCategory']}  ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['teamIds']}          ${empty_list}
   
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceId']}        ${subser_id1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceName']}      ${subser_name}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceDate']}      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceAmount']}    ${subser_price}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['quantity']}         0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['totalPrice']}       0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['netRate']}          0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceCategory']}  ${serviceCategory[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['assigneeUsers']}    ${empty_list}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['teamIds']}          ${empty_list}
   
    
JD-TC-AddSubServicesToAppt-UH1

    [Documentation]  Add a subservice to an appointment without Login

    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   

    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}
 
JD-TC-AddSubServicesToAppt-UH2

    [Documentation]  consumer tries to Add a subservice to an appointment.
    
    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   

    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-AddSubServicesToAppt-UH3

    [Documentation]  add an inactive subservice to an appointment
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME172}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Disable service  ${subser_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${subser_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']}   ${status[1]}
    
    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   

    ${STATUS_DISABLED}=  format String   ${STATUS_DISABLED}   ${serviceCategory[0]} : ${subser_name}

    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${STATUS_DISABLED}

    ${resp}=  Enable service  ${subser_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-AddSubServicesToAppt-UH4

    [Documentation]  add another providers subservice to an appointment

    ${resp}=  Encrypted Provider Login  ${PUSERNAME175}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ##....subservice creation..........

    ${desc}=  FakerLibrary.sentence
    ${subser_dur}=   Random Int   min=5   max=10
    ${subser_price}=   Random Int   min=100   max=500
    ${subser_price}=  Convert To Number  ${subser_price}  1
    ${subser_name}=    FakerLibrary.firstname
    ${subser_qnty}=   Random Int   min=1   max=5
    ${subser_qnty}=  Convert To Number  ${subser_qnty}  1
   
    ${resp}=  Create Service    ${subser_name}  ${desc}  ${subser_dur}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price}
    ...    ${bool[0]}   ${bool[0]}   serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id1}  ${resp.json()}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME172}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   

    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings     ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NO_PERMISSION}


JD-TC-AddSubServicesToAppt-UH5

    [Documentation]  add a service to an appointment using sub service url.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME172}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${SERVICE1}=    FakerLibrary.word
    ${s_id}=  Create Sample Service  ${SERVICE1}   department=${dep_id}

    ${subser_list1}=  Create Dictionary  serviceId=${s_id}  serviceAmount=${subser_price}   

    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings     ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NO_PERMISSION}


JD-TC-AddSubServicesToAppt-UH6

    [Documentation]  add a subservice to an appointment without service id.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME172}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${subser_list1}=  Create Dictionary  serviceId=${EMPTY}  serviceAmount=${subser_price}   

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   ${serviceCategory[0]}Id : 0

    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_FIELD}


JD-TC-AddSubServicesToAppt-UH7

    [Documentation]  add subservice to an inactive appointment.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME172}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Disable Appointment
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   

    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_APPOINTMENT}


JD-TC-AddSubServicesToAppt-UH8

    [Documentation]  add subservice to an invalid appointment id.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME172}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${apptid1}=   Random Int   min=5   max=10
    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   

    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings     ${resp.status_code}    404
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_APPOINTMENT}


JD-TC-AddSubServicesToAppt-UH9

    [Documentation]  add subservice to another providers appointment.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME169}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ##....subservice creation..........

    ${desc}=  FakerLibrary.sentence
    ${subser_dur}=   Random Int   min=5   max=10
    ${subser_price}=   Random Int   min=100   max=500
    ${subser_price}=  Convert To Number  ${subser_price}  1
    ${subser_name}=    FakerLibrary.firstname
    ${subser_qnty}=   Random Int   min=1   max=5
    ${subser_qnty}=  Convert To Number  ${subser_qnty}  1
   
    ${resp}=  Create Service    ${subser_name}  ${desc}  ${subser_dur}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price}
    ...    ${bool[0]}   ${bool[0]}   serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id1}  ${resp.json()}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME172}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   

    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings     ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NO_PERMISSION}


JD-TC-AddSubServicesToAppt-UH10

    [Documentation]  add subservice to an inactive user.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME172}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  EnableDisable User  ${u_id1}  ${toggle[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id1}   status=${status[1]} 

    ${asgn_users}=   Create List  ${u_id1}
    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   assigneeUsers=${asgn_users}
   
    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_APPOINTMENT}



*** comments ***

JD-TC-AddSubServicesToAppt-11

    [Documentation]  Create multiple sub services and add that subservice to an appointment(online) for provider consumer


JD-TC-AddSubServicesToAppt-12

    [Documentation]  Create a sub service and add that subservice to a future appointment(online) for provider consumer


JD-TC-AddSubServicesToAppt-13

    [Documentation]  Create a sub service and add that subservice to a future appointment(walkin) for provider consumer


JD-TC-AddSubServicesToAppt-14

    [Documentation]  Create a sub service and add that subservice to a future appointment(online) for provider consumer


JD-TC-AddSubServicesToAppt-5

    [Documentation]  Create a sub service and add that sub service to multiple appointments(walkin and online).

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



JD-TC-AddSubServicesToAppt-7

    [Documentation]  Create a sub service for a user and add that subservice to users appointment(online)

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-AddSubServicesToAppt-8

    [Documentation]  Create a sub service for a user and add that subservice to users multiple appointments(online)

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-AddSubServicesToAppt-9

    [Documentation]  Create a sub service for a user and add that subservice to users multiple appointments(walkin)

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-AddSubServicesToAppt-10

    [Documentation]  Create a sub service for a user and add that subservice to users multiple appointments(online and walkin)

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-AddSubServicesToAppt-11

    [Documentation]  Create a sub service and add that subservice to multiple users appointments(online)

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-AddSubServicesToAppt-12

    [Documentation]  Create a sub service and add that subservice to multiple users appointments(walkin)

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-AddSubServicesToAppt-13

    [Documentation]  Create multiple sub services and add that subservice to an appointment(walkin)

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-AddSubServicesToAppt-14

    [Documentation]  Create multiple sub services and add that subservice to an appointment(online)

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-AddSubServicesToAppt-15

    [Documentation]  Create multiple sub services and add that subservice to a users appointment(walkin)

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-AddSubServicesToAppt-16

    [Documentation]  Create multiple sub services and add that subservice to a users appointment(online)

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

