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

JD-TC-RemoveSubServicesToAppt-1

    [Documentation]  add sub service to an appointment(walkin) then remove that sub service.

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME230}  ${PASSWORD}
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
            IF   not '${user_phone}' == '${PUSERNAME230}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id1}=  Create Sample User
    Set Suite Variable   ${u_id1}
   
    ${resp}=  Get User By Id  ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}

    ${u_id2}=  Create Sample User
    Set Suite Variable   ${u_id2}
   
    ${resp}=  Get User By Id  ${u_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BUSER_U2}  ${resp.json()['mobileNo']}

    ${u_id3}=  Create Sample User
    Set Suite Variable   ${u_id3}
   
    ${resp}=  Get User By Id  ${u_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BUSER_U3}  ${resp.json()['mobileNo']}

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
    Should Not Contain          ${resp.json()['subServiceData']}                        ${subser_id1}

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

    Set Test Variable   ${seq_id}      ${resp.json()['subServiceData'][1]['sequenceId']}
    
    ${subser_list}=  Create Dictionary  serviceId=${subser_id1}   sequenceId=${seq_id}
    
    ${resp}=   Remove SubService From Appointment    ${apptid1}   ${subser_list}  
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
    Should Not Contain   ${resp.json()['subServiceData']}                               ${subser_id1}

JD-TC-RemoveSubServicesToAppt-2

    [Documentation]  remove the subservice with one assigned user.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME230}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${asgn_users}=   Create List  ${u_id1}
    ${subser_qnty}=   Random Int   min=1   max=5
    ${subser_qnty}=  Convert To Number  ${subser_qnty}  1
    ${subser_list2}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}    quantity=${subser_qnty}   assigneeUsers=${asgn_users}
    
    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list2}
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

    Set Test Variable   ${seq_id}      ${resp.json()['subServiceData'][1]['sequenceId']}
    
    ${asgn_users}=   Create List  ${u_id1}
    ${subser_list2}=  Create Dictionary     serviceId=${subser_id1}   sequenceId=${seq_id}  assigneeUsers=${asgn_users}
    
    ${resp}=   Remove SubService From Appointment    ${apptid1}   ${subser_list2}
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
    Should Not Contain   ${resp.json()['subServiceData']}                               ${subser_id1}


JD-TC-RemoveSubServicesToAppt-3

    [Documentation]  add a subservice and change the price then try to remove the subservice .
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME230}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${asgn_users}=   Create List  ${u_id1}
    ${subser_qnty}=   Random Int   min=1   max=5
    ${subser_qnty}=  Convert To Number  ${subser_qnty}  1
    ${subser_list2}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}    quantity=${subser_qnty}   assigneeUsers=${asgn_users}
    
    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list2}
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

    Set Test Variable   ${seq_id}      ${resp.json()['subServiceData'][1]['sequenceId']}
    
    ${subser_price1}=   Random Int   min=10   max=50
    ${subser_price1}=  Convert To Number  ${subser_price1}  1
    ${subser_list}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price1}   quantity=${subser_qnty}   assigneeUsers=${asgn_users}
    
    ${resp}=   Update SubService To Appointment    ${apptid1}   ${subser_list}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total1}=    Evaluate    ${subser_qnty}*${subser_price1}

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
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceAmount']}    ${subser_price1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['quantity']}         ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxable']}          ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['taxPercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['totalPrice']}       ${total1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['netRate']}          ${total1}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceCategory']}  ${serviceCategory[0]}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['assigneeUsers']}    ${asgn_users}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['teamIds']}          ${empty_list}

    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}   sequenceId=${seq_id}

    ${resp}=   Remove SubService From Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings    ${resp.status_code}   200

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
    Should Not Contain   ${resp.json()['subServiceData']}                               ${subser_id1}


JD-TC-RemoveSubServicesToAppt-4

    [Documentation]  add sub service to an appointment(online) then remove that sub service then again add that sub service.

JD-TC-RemoveSubServicesToAppt-UH1

    [Documentation]  Remove a subservice from an appointment without Login

    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  

    ${resp}=   Remove SubService From Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}
 
JD-TC-RemoveSubServicesToAppt-UH2

    [Documentation]  consumer tries to remove a subservice from an appointment.
    
    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}   

    ${resp}=   Remove SubService From Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-RemoveSubServicesToAppt-UH3

    [Documentation]  remove an inactive subservice from an appointment
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME230}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Disable service  ${subser_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${subser_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']}   ${status[1]}
    
    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  

    ${STATUS_DISABLED}=  format String   ${STATUS_DISABLED}   ${serviceCategory[0]} : ${subser_id1}

    ${resp}=   Remove SubService From Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${STATUS_DISABLED}

    ${resp}=  Enable service  ${subser_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
JD-TC-RemoveSubServicesToAppt-UH4

    [Documentation]  Remove a subservice from an appointment that has already been canceled.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME230}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${asgn_users}=   Create List  ${u_id1}
    ${subser_qnty}=   Random Int   min=1   max=5
    ${subser_qnty}=  Convert To Number  ${subser_qnty}  1
    ${subser_list2}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}    quantity=${subser_qnty}   assigneeUsers=${asgn_users}
    
    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list2}
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

    Set Test Variable   ${seq_id}      ${resp.json()['subServiceData'][1]['sequenceId']}
    
    ${asgn_users}=   Create List  ${u_id1}
    ${subser_list2}=  Create Dictionary     serviceId=${subser_id1}   sequenceId=${seq_id}  assigneeUsers=${asgn_users}
    
    ${resp}=   Remove SubService From Appointment    ${apptid1}   ${subser_list2}
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
    Should Not Contain   ${resp.json()['subServiceData']}                               ${subser_id1}


    ${resp}=   Remove SubService From Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-RemoveSubServicesToAppt-UH5

    [Documentation]  add sub service to an appointment(walkin) then remove that sub service after settle the payment.


JD-TC-RemoveSubServicesToAppt-UH6

    [Documentation]  add sub service to an appointment(online) then remove that sub service after settle the payment.


JD-TC-RemoveSubServicesToAppt-UH6

    [Documentation]  add sub service to an appointment(online) then remove that sub service after settle the payment.