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
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Variables ***

${self}         0


*** Test Cases ***

JD-TC-UpdateSubServicesToAppt-1

    [Documentation]  add sub service to an appointment(walkin) without quantity then update the subservice with quantity.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME21}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Appointment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Suite Variable   ${locId}

        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END
   
    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${HLPUSERNAME21}'
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
    ${s_id}=  Create Sample Service  ${SERVICE1}   
    Set Suite Variable    ${s_id}

    ${resp}=   Get Service By Id  ${s_id}
    Log   ${resp.content}  
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

    ${resp}=  Create Service    ${subser_name}  ${desc}   ${subser_dur}  ${bool[0]}  ${subser_price}  ${bool[0]}   serviceCategory=${serviceCategory[0]}
    Log   ${resp.content}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${subser_id1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${subser_id1}
    Log   ${resp.content}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${locId}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}


    ${resp}=  AddCustomer  ${CUSERNAME11} 
    Log   ${resp.content}   
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}   ${subser_id1}

    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}  
    
    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.content}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${subser_qnty}=   Random Int   min=1   max=5
    ${subser_qnty}=  Convert To Number  ${subser_qnty}  1
    Set Suite Variable   ${subser_qnty}
    ${subser_list2}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}    quantity=${subser_qnty}
    
    ${resp}=   Update SubService To Appointment    ${apptid1}   ${subser_list2}
    Log   ${resp.content}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total}=    Evaluate    ${subser_qnty}*${subser_price}
    Set Suite Variable   ${total} 

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
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

JD-TC-UpdateSubServicesToAppt-2

    [Documentation]  add sub service to an appointment(walkin) without any users then assign one user to that service.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME21}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${asgn_users}=   Create List  ${u_id1}
    ${subser_list2}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}    quantity=${subser_qnty}   assigneeUsers=${asgn_users}
    
    ${resp}=   Update SubService To Appointment    ${apptid1}   ${subser_list2}
    Log   ${resp.content}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
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


JD-TC-UpdateSubServicesToAppt-3

    [Documentation]  update the subservice with more than one user as assignee.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME21}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${asgn_users}=   Create List  ${u_id2}   ${u_id3}
    ${subser_list2}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}    quantity=${subser_qnty}   assigneeUsers=${asgn_users}
    
    ${resp}=   Update SubService To Appointment    ${apptid1}   ${subser_list2}
    Log   ${resp.content}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
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

  
JD-TC-UpdateSubServicesToAppt-4

    [Documentation]  update the subservice with assignee conflicting with the existing one.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME21}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${asgn_users}=   Create List  ${u_id2}   ${u_id3}
    ${subser_list2}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}    quantity=${subser_qnty}   assigneeUsers=${asgn_users}
    
    ${resp}=   Update SubService To Appointment    ${apptid1}   ${subser_list2}
    Log   ${resp.content}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
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

  
JD-TC-UpdateSubServicesToAppt-UH1

    [Documentation]  update a subservice to an appointment without Login

    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   

    ${resp}=   Update SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.content}  
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}
 
JD-TC-UpdateSubServicesToAppt-UH2

    [Documentation]  consumer tries to update a subservice to an appointment.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid}=  get_acc_id  ${HLPUSERNAME21}

    ${resp}=  AddCustomer  ${CUSERNAME10}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME10}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME10}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME10}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   

    ${resp}=   Update SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.content}  
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-UpdateSubServicesToAppt-UH3

    [Documentation]  update an inactive subservice to an appointment
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME21}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Disable service  ${subser_id1} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${subser_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']}   ${status[1]}
    
    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   

    ${STATUS_DISABLED}=  format String   ${STATUS_DISABLED}   ${serviceCategory[0]} : ${subser_name}

    ${resp}=   Update SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.content}  
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${STATUS_DISABLED}

    ${resp}=  Enable service  ${subser_id1} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UpdateSubServicesToAppt-UH4

    [Documentation]  update the subservice with inactive user.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME21}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  EnableDisable User  ${u_id1}  ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id1}   status=${status[1]} 

    ${asgn_users}=   Create List  ${u_id1}  
    ${subser_list2}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}    quantity=${subser_qnty}   assigneeUsers=${asgn_users}
    
    ${resp}=   Update SubService To Appointment    ${apptid1}   ${subser_list2}
    Log   ${resp.content}  
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UpdateSubServicesToAppt-UH5

    [Documentation]   Create a sub service with auto invoice generation on and with a service price , then try to update the subservice with price as zero.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get jp finance settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}

    ${desc}=  FakerLibrary.sentence                       
    ${subser_dur}=   Random Int   min=5   max=10
    ${subser_price}=   Random Int   min=100   max=500
    ${subser_price}=  Convert To Number  ${subser_price}  1
    ${subser_name}=    FakerLibrary.firstname
   
    ${resp}=  Create Service    ${subser_name}  ${desc}   ${subser_dur}  ${bool[0]}  ${subser_price}  ${bool[0]}    serviceCategory=${serviceCategory[0]}
    Log   ${resp.content}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${subser_id1}
    Log   ${resp.content}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}

     #.........Auto Invoice Generation...............

    ${resp}=  Auto Invoice Generation For Service   ${subser_id1}    ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${subser_id1}
    Log   ${resp.content}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}               ${serviceCategory[0]}
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}

    ${subser_price}=   Random Int   min=0   max=0

    ${resp}=  Update Service    ${subser_id1}  ${subser_name}  ${desc}   ${subser_dur}   ${status[0]}  ${btype}  ${bool[0]}  ${notifytype[0]}  0  ${subser_price}  ${bool[1]}  ${bool[0]}    serviceCategory=${serviceCategory[0]}
    Log   ${resp.content}  
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${MINIMUM_PREPAYMENT_AMOUNT_SHOULD_BE_PROVIDED}
    