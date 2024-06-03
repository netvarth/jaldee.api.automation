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


JD-TC-PaymentReport-1

    [Documentation]  Create a sub service and add that sub service to an appointment(walkin) for a provider consumer.
                ...   without doing the payment ( auto invoice generation on) and verify payment report.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME10}  ${PASSWORD}
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

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}

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
            IF   not '${user_phone}' == '${HLPUSERNAME10}'
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
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[0]}

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

    #.........Auto Invoice Generation...............

    ${resp}=  Auto Invoice Generation For Service   ${s_id}    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}

    ${resp}=  Auto Invoice Generation For Service   ${subser_id1}    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${subser_id1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}

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

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME10}  ${PASSWORD}
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

    ${resp}=  Get Bookings Invoices  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${invoice_id1}    ${resp.json()[0]['invoiceUid']}

    ${asgn_users}=   Create List  ${u_id1}   
    ${subser_qnty}=   Random Int   min=1   max=5
    ${subser_qnty}=  Convert To Number  ${subser_qnty}  1

    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   quantity=${subser_qnty}  invoiceUid=${invoice_id1}  assigneeUsers=${asgn_users}
    
    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total}=    Evaluate    ${subser_qnty}*${subser_price}
    ${total_amt}=    Evaluate    ${ser_amount}+${total}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceId']}        ${subser_id1}
    
    ${resp}=   Get Appointment level Bill Details      ${apptid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netRate']}                   ${total_amt}
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}

    ${resp}=  Get Bookings Invoices  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                                        ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}                                     ${CategoryName[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}                                      ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumerId']}                               ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumerData']['phoneNos'][0]['number']}    ${NewCustomer}
    Should Be Equal As Strings   ${resp.json()[0]['ynwUuid']}                                         ${apptid1}
    Should Be Equal As Strings   ${resp.json()[0]['amountPaid']}                                      0.0
    Should Be Equal As Strings   ${resp.json()[0]['amountDue']}                                       ${total_amt}
    Should Be Equal As Strings   ${resp.json()[0]['amountTotal']}                                     ${total_amt}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}                      ${s_id}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}                    ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}                       1.0
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['taxable']}                        ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}                     ${ser_amount}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}                        ${ser_amount}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceCategory']}                ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['assigneeUsers']}                  ${empty_list}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['serviceId']}                      ${subser_id1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['serviceName']}                    ${subser_name}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['quantity']}                       ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['taxable']}                        ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['totalPrice']}                     ${total}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['netRate']}                        ${total}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['serviceCategory']}                ${serviceCategory[0]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['assigneeUsers']}                  ${asgn_users}

    ${filter}=  Create Dictionary    
    ${resp}=  Generate Report REST details  ${reportType[4]}  ${Report_Date_Category[4]}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}

    ${ser_date} =	Convert Date	${DAY1}	result_format=%d-%m-%Y
  
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}                        0
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                   Payment Report
    Should Be Equal As Strings  ${resp.json()['reportType']}                                    ${reportType[4]}
    Should Be Equal As Strings  ${resp.json()['reportResponseType']}                            ${ReportResponseType[0]}
    Should Be Equal As Strings  ${resp.json()['reportTokenID']}                                 ${token_id1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}  ${Report_Date_Category[4]}   ignore_case=True


JD-TC-PaymentReport-2

    [Documentation]  Create a sub service and add that sub service to an appointment(walkin) for a provider consumer.
                ...   do the payment from provider as cash ( auto invoice generation on) and verify payment report.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${prov_name}  ${decrypted_data['userName']}

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

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}

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
        Set Test Variable  ${dep_name1}  ${resp.json()['departments'][0]['departmentName']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${HLPUSERNAME11}'
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
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[0]}

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

    #.........Auto Invoice Generation...............

    ${resp}=  Auto Invoice Generation For Service   ${s_id}    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}

    ${resp}=  Auto Invoice Generation For Service   ${subser_id1}    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${subser_id1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}

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

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
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

    ${resp}=  Get Bookings Invoices  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${invoice_id1}    ${resp.json()[0]['invoiceUid']}

    ${asgn_users}=   Create List  ${u_id1}   
    ${subser_qnty}=   Random Int   min=1   max=5
    ${subser_qnty}=  Convert To Number  ${subser_qnty}  1

    ${subser_list1}=  Create Dictionary  serviceId=${subser_id1}  serviceAmount=${subser_price}   quantity=${subser_qnty}  invoiceUid=${invoice_id1}  assigneeUsers=${asgn_users}
    
    ${resp}=   Add SubService To Appointment    ${apptid1}   ${subser_list1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total}=    Evaluate    ${subser_qnty}*${subser_price}
    ${total_amt}=    Evaluate    ${ser_amount}+${total}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}
    Should Be Equal As Strings  ${resp.json()['subServiceData'][1]['serviceId']}        ${subser_id1}
    
    ${resp}=   Get Appointment level Bill Details      ${apptid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netRate']}                   ${total_amt}
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}

    ${resp}=  Get Bookings Invoices  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                                        ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}                                     ${CategoryName[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}                                      ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumerId']}                               ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumerData']['phoneNos'][0]['number']}    ${NewCustomer}
    Should Be Equal As Strings   ${resp.json()[0]['ynwUuid']}                                         ${apptid1}
    Should Be Equal As Strings   ${resp.json()[0]['amountPaid']}                                      0.0
    Should Be Equal As Strings   ${resp.json()[0]['amountDue']}                                       ${total_amt}
    Should Be Equal As Strings   ${resp.json()[0]['amountTotal']}                                     ${total_amt}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}                      ${s_id}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}                    ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}                       1.0
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['taxable']}                        ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}                     ${ser_amount}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}                        ${ser_amount}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceCategory']}                ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['assigneeUsers']}                  ${empty_list}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['serviceId']}                      ${subser_id1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['serviceName']}                    ${subser_name}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['quantity']}                       ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['taxable']}                        ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['totalPrice']}                     ${total}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['netRate']}                        ${total}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['serviceCategory']}                ${serviceCategory[0]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['assigneeUsers']}                  ${asgn_users}

    ${note}=    FakerLibrary.word
    ${resp}=  Make Payment By Cash For Invoice   ${invoice_id1}  ${payment_modes[0]}  ${total_amt}  ${note}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${filter}=  Create Dictionary    
    ${resp}=  Generate Report REST details  ${reportType[4]}  ${Report_Date_Category[4]}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}

    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${tot_amt}   ${resp.json()['reportContent']['data'][0]['10']}

    ${pay_date} =	Convert Date	${DAY1}	result_format=%Y-%m-%d
    ${tot_amt} =    Replace String    ${tot_amt}    ,       ${EMPTY}
    ${tot_amt}=  Convert To Number  ${tot_amt}  1

    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}                        1
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}                         ${pay_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                   Payment Report
    Should Be Equal As Strings  ${resp.json()['reportType']}                                    ${reportType[4]}
    Should Be Equal As Strings  ${resp.json()['reportResponseType']}                            ${ReportResponseType[0]}
    Should Be Equal As Strings  ${resp.json()['reportTokenID']}                                 ${token_id1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}  ${Report_Date_Category[4]}   ignore_case=True
    # Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}                 ${countryCodes[0]}${NewCustomer}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}                 ${encId}
    Should Be Equal As Strings  ${tot_amt}                                                      ${total_amt}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}                ${payment_modes[0]}  ignore_case=True
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['15']}                ${total_amt}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['22']}                ${prov_name} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['23']}                ${dep_name1}
    

JD-TC-PaymentReport-3

    [Documentation]  take an appointment(walkin) for today for a provider consumer.
                ...   do the payment from provider as cash ( auto invoice generation on) and verify payment report.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${prov_name}  ${decrypted_data['userName']}

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

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}

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
        Set Test Variable  ${dep_name1}  ${resp.json()['departments'][0]['departmentName']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${HLPUSERNAME12}'
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
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[0]}

    #.........Auto Invoice Generation...............

    ${resp}=  Auto Invoice Generation For Service   ${s_id}    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}

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

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME12}  ${PASSWORD}
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
  
    ${resp}=  Get Bookings Invoices  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${invoice_id1}    ${resp.json()[0]['invoiceUid']}

    ${resp}=   Get Appointment level Bill Details      ${apptid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netRate']}                   ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}

    ${resp}=  Get Bookings Invoices  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                                        ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}                                     ${CategoryName[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}                                      ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumerId']}                               ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumerData']['phoneNos'][0]['number']}    ${NewCustomer}
    Should Be Equal As Strings   ${resp.json()[0]['ynwUuid']}                                         ${apptid1}
    Should Be Equal As Strings   ${resp.json()[0]['amountPaid']}                                      0.0
    Should Be Equal As Strings   ${resp.json()[0]['amountDue']}                                       ${ser_amount}
    Should Be Equal As Strings   ${resp.json()[0]['amountTotal']}                                     ${ser_amount}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}                      ${s_id}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}                    ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}                       1.0
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['taxable']}                        ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}                     ${ser_amount}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}                        ${ser_amount}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceCategory']}                ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['assigneeUsers']}                  ${empty_list}

    ${note}=    FakerLibrary.word
    ${resp}=  Make Payment By Cash For Invoice   ${invoice_id1}  ${payment_modes[0]}  ${ser_amount}  ${note}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${filter}=  Create Dictionary    
    ${resp}=  Generate Report REST details  ${reportType[4]}  ${Report_Date_Category[4]}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}

    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${tot_amt}   ${resp.json()['reportContent']['data'][0]['10']}

    ${pay_date} =	Convert Date	${DAY1}	result_format=%Y-%m-%d
    ${tot_amt} =    Replace String    ${tot_amt}    ,       ${EMPTY}
    ${tot_amt}=  Convert To Number  ${tot_amt}  1

    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}                        1
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}                         ${pay_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                   Payment Report
    Should Be Equal As Strings  ${resp.json()['reportType']}                                    ${reportType[4]}
    Should Be Equal As Strings  ${resp.json()['reportResponseType']}                            ${ReportResponseType[0]}
    Should Be Equal As Strings  ${resp.json()['reportTokenID']}                                 ${token_id1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}  ${Report_Date_Category[4]}   ignore_case=True

    # Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}                 ${countryCodes[0]}${NewCustomer}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}                 ${encId}
    Should Be Equal As Strings  ${tot_amt}                                                      ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}                ${payment_modes[0]}   ignore_case=True
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['15']}                ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['22']}                ${prov_name} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['23']}                ${dep_name1}
    
    