*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Finance Manager
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***

@{service_names}

${order}    0
${service_duration}     30
${self}         0
${waitlistedby}           PROVIDER



*** Test Cases ***

JD-TC-Remove Service From Invoice-1

    [Documentation]  Apply Service Level Discount.


    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+3381684
    Set Suite Variable   ${PUSERPH0}

    ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERPH0}=  Provider Signup  PhoneNumber=${PUSERPH0}
    


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${result}=  Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Disable Appointment   ${toggle[0]}
    Log   ${result.json()}
    Should Be Equal As Strings  ${result.status_code}  200
    ${resp}=   Get Account Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appointment']}   ${bool[1]}
    

    ${accId}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${accId}


    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}


    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    #sleep   01s
    
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

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200




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



    ${resp}=  Create Sample Location  
    Set Suite Variable    ${lid}    ${resp}  

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${name}=   FakerLibrary.word



    ${name1}=   FakerLibrary.word
    Set Suite Variable   ${name1}
    ${resp}=  Create Category   ${name1}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id2}   ${resp.json()}



    ${resp1}=  AddCustomer  ${CUSERNAME11}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable  ${pcid18}   ${resp1.json()}


    ${providerConsumerIdList}=  Create List  ${pcid18}
    Set Suite Variable  ${providerConsumerIdList}  

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}
    ${invoiceId}=   FakerLibrary.word


    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Set Suite Variable  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()} 

    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${serviceprice}=   Random Int  min=100  max=500
    ${serviceprice}=  Convert To Number  ${serviceprice}  1
    ${netRate}=  Evaluate  ${quantity} * ${serviceprice}

    ${serviceList}=  Create Dictionary  serviceId=${sid1}   quantity=${quantity}   price=${serviceprice} 
    ${serviceList}=    Create List    ${serviceList}
    
    
    ${resp}=  Create Invoice   ${category_id2}    ${invoiceDate}      ${invoiceId}    ${providerConsumerIdList}   ${lid}   serviceList=${serviceList}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_uid}   ${resp.json()['uidList'][0]} 


     ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Set Suite Variable  ${SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid2}  ${resp.json()} 



    ${serviceList1}=  Create Dictionary  serviceId=${sid2}   quantity=${quantity}   price=${serviceprice} 
    # ${serviceList1}=    Create List    ${serviceList1}


    ${resp}=  AddServiceToInvoice    ${invoice_uid}   ${serviceList1}    
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${serviceList2}=  Create Dictionary  serviceId=${sid2}      price=${serviceprice} 

    ${resp}=  RemoveServiceFromInvoice   ${invoice_uid}   ${serviceList2}    
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['serviceName']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['price']}  ${serviceprice}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['netRate']}  ${netRate}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][1]['serviceId']}  ${sid2}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][1]['serviceName']}  ${SERVICE2}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][1]['quantity']}  ${quantity}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][1]['price']}  ${serviceprice}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][1]['netRate']}  ${netRate}

JD-TC-Remove Service From Invoice-2

    [Documentation]   Service auto invoice generation is on,then took one appointment from consumer side  and check whethrer invoice is created there .


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

    ${pid}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME32}

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word

    # ${resp}=  Create Sample Location  
    # Set Suite Variable    ${lid}    ${resp}  

    # ${resp}=   Get Location ById  ${lid}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    # Set Suite Variable  ${CUR_DAY}
  
    ${SERVICE3}=    generate_unique_service_name  ${service_names}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${servicecharge}=  Convert To Number  ${servicecharge}  1 
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Sample Service  ${SERVICE3}    automaticInvoiceGeneration=${bool[1]}
    # ${resp}=  Create Service  ${SERVICE3}  ${desc}   ${srv_duration}  ${bool[1]}  ${servicecharge}  ${bool[0]}   minPrePaymentAmount=${min_pre}   prePaymentType=${advancepaymenttype[1]}    automaticInvoiceGeneration=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    # ${resp}=  Auto Invoice Generation For Service   ${s_id}    ${toggle[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}


    # clear_appt_schedule   ${PUSERPH0}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.add_timezone_time     ${tz}  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    # ${fname}=  generate_firstname
    # Set Test Variable  ${fname}
    # ${lname}=  FakerLibrary.last_name

    # ${resp}=  AddCustomer  ${CUSERNAME32}    firstName=${fname}   lastName=${lname}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME32}  
    # Log  ${resp.content}
    # Should Be Equal As Strings      ${resp.status_code}  200
    # Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    # ${resp}=  ProviderLogout
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Send Otp For Login    ${CUSERNAME32}    ${pid}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    # ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    # ${resp}=    Verify Otp For Login   ${CUSERNAME32}   ${OtpPurpose['Authentication']}    JSESSIONYNW=${jsessionynw_value}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable  ${token7}  ${resp.json()['token']}

    # ${resp}=    ProviderConsumer Login with token   ${CUSERNAME32}    ${pid}  ${token7} 
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200


    # ${resp}=    Get Appmt Service By LocationId   ${lid}
    # Log  ${resp.content}
    # Should Be Equal As Strings   ${resp.status_code}   200

    # ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid}  ${DAY1}  ${lid}  ${s_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${no_of_slots}=  Get Length  ${resp.json()[0]['availableSlots']}
    # @{slots}=  Create List
    # FOR   ${i}  IN RANGE   0   ${no_of_slots}
    #     IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
    #         Set Test Variable   ${a${i}}  ${resp.json()[0]['availableSlots'][${i}]['time']}
    #         Append To List   ${slots}  ${resp.json()[0]['availableSlots'][${i}]['time']}
    #     END
    # END
    # ${num_slots}=  Get Length  ${slots}
    # ${j1}=  Random Int  max=${num_slots-1}
    # Set Test Variable   ${slot1}   ${slots[${j1}]}

    ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456987
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Suite Variable    ${primaryMobileNo}
    ${email}=    FakerLibrary.Email
    Set Suite Variable    ${email}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    # ${resp}=    Consumer Logout
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${primaryMobileNo}     ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid1}    ${resp.json()['providerConsumer']}


    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid}  ${DAY1}  ${lid}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()[0]['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Set Test Variable   ${a${i}}  ${resp.json()[0]['availableSlots'][${i}]['time']}
            Append To List   ${slots}  ${resp.json()[0]['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}



    ${cnote}=   FakerLibrary.word
    ${resp}=   Customer Take Appointment  ${pid}   ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${firstName}
    Set Suite Variable   ${apptid1}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    # ${resp}=  Consumer Login  ${CUSERNAME32}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  ${jdconID}   ${resp.json()['id']}
    # Set Test Variable  ${fname}   ${resp.json()['firstName']}
    # Set Test Variable  ${lname}   ${resp.json()['lastName']}

    # ${resp}=  Get Appointment Schedules Consumer  ${pid}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    # @{slots}=  Create List
    # FOR   ${i}  IN RANGE   0   ${no_of_slots}
    #     IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
    #         Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    #     END
    # END
    # ${num_slots}=  Get Length  ${slots}
    # ${j}=  Random Int  max=${num_slots-3}
    # Set Test Variable   ${slot1}   ${slots[${j}]}

    # ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    # ${apptfor}=   Create List  ${apptfor1}

    # ${cnote}=   FakerLibrary.name
    # ${resp}=   Customer Take Appointment   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}    location=${{str('${lid}')}}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
          
    # ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
    # Set Suite Variable   ${apptid1}

    # ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200 
    # Verify Response    ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    # Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    # Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    # Should Be Equal As Strings  ${resp.json()['apptStatus']}  ${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    # Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    #sleep  02s

    ${resp}=  Encrypted Provider Login    ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    #sleep  02s
    ${resp1}=  Get Booking Invoices  ${apptid1}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable  ${invoice_appt_uid}  ${resp1.json()[0]['invoiceUid']}

    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${serviceprice}=   Random Int  min=100  max=500
    ${serviceprice}=  Convert To Number  ${serviceprice}  1
    ${serviceList1}=  Create Dictionary  serviceId=${sid2}   quantity=${quantity}   price=${serviceprice} 
    # ${serviceList1}=    Create List    ${serviceList1}
    ${netRate}=  Evaluate  ${quantity} * ${serviceprice}
    ${netRate}=  Convert To Number  ${netRate}  1
    ${Total}=  Evaluate  ${servicecharge} + ${netRate}
    ${Total}=  Convert To Number  ${Total}  1


    ${resp}=  AddServiceToInvoice    ${invoice_appt_uid}   ${serviceList1}    
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${serviceList2}=  Create Dictionary  serviceId=${sid2}      price=${serviceprice} 

    ${resp}=  RemoveServiceFromInvoice   ${invoice_appt_uid}   ${serviceList2}    
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_appt_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['serviceId']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['serviceName']}  ${SERVICE3}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['price']}  ${servicecharge}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['netRate']}  ${servicecharge}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][1]['serviceId']}  ${sid2}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][1]['serviceName']}  ${SERVICE2}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][1]['quantity']}  ${quantity}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][1]['price']}  ${serviceprice}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][1]['netRate']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()['amountDue']}  ${servicecharge}
    Should Be Equal As Strings  ${resp.json()['amountTotal']}  ${servicecharge}
    Should Be Equal As Strings  ${resp.json()['netTotal']}  ${servicecharge}
    Should Be Equal As Strings  ${resp.json()['netRate']}  ${servicecharge}

JD-TC-Remove Services to finance-3

    [Documentation]   Service auto invoice generation is on,then took walkin appointment  and check whethrer invoice is created there .




    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

    ${pid}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME32}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    # ${lid}=  Create Sample Location  
    # Set Suite Variable  ${lid}
    # ${resp}=   Get Location ById  ${lid}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    clear_appt_schedule   ${PUSERPH0}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${servicecharge}=  Convert To Number  ${servicecharge}  1 
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}  ${bool[1]}  ${servicecharge}  ${bool[0]}  minPrePaymentAmount=${min_pre}    automaticInvoiceGeneration=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}

    # ${resp}=  Auto Invoice Generation For Service   ${s_id}    ${toggle[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}
    Set Test Variable   ${tot_amt}   ${resp.json()['totalAmount']}


    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}   ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME2}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable   ${jaldeeid1}    ${resp.json()[0]['jaldeeId']}
    
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}   location=${lid}
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
    # Should Be Equal As Strings  ${resp.json()['uid']}                              ${apptid1}
    # Should Be Equal As Strings  ${resp.json()['appointmentEncId']}                  ${encId}
    # Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid}
    # Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}        ${CUSERNAME2}
    # Should Be Equal As Strings  ${resp.json()['providerConsumer']['jaldeeId']}      ${jaldeeid1}
    # Should Be Equal As Strings  ${resp.json()['service']['id']}                      ${s_id}
    # Should Be Equal As Strings  ${resp.json()['schedule']['id']}                      ${sch_id}
    # Should Be Equal As Strings  ${resp.json()['apptStatus']}                          ${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}             ${fname1}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}              ${lname1}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}              ${slot1}
    # Should Be Equal As Strings  ${resp.json()['appmtDate']}                            ${DAY1}
    # Should Be Equal As Strings  ${resp.json()['appmtTime']}                            ${slot1}
    # Should Be Equal As Strings  ${resp.json()['location']['id']}                       ${lid}

    ${resp1}=  Get Booking Invoices  ${apptid1}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable  ${invoice_apptwalkin_uid}  ${resp1.json()[0]['invoiceUid']}
    # Should Be Equal As Strings  ${resp1.json()[0]['netTotal']}     ${tot_amt}
    # Should Be Equal As Strings  ${resp1.json()[0]['netRate']}     ${tot_amt}
    # Should Be Equal As Strings  ${resp1.json()[0]['amountDue']}     ${tot_amt}
    # Should Be Equal As Strings  ${resp1.json()[0]['amountTotal']}     ${tot_amt}

    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${serviceprice}=   Random Int  min=100  max=500
    ${serviceprice}=  Convert To Number  ${serviceprice}  1
    ${serviceList1}=  Create Dictionary  serviceId=${sid2}   quantity=${quantity}   price=${serviceprice} 
    # ${serviceList1}=    Create List    ${serviceList1}
    ${netRate}=  Evaluate  ${quantity} * ${serviceprice}
    ${netRate}=  Convert To Number  ${netRate}  1
    ${Total}=  Evaluate  ${servicecharge} + ${netRate}
    ${Total}=  Convert To Number  ${Total}  1


    ${resp}=  AddServiceToInvoice    ${invoice_apptwalkin_uid}   ${serviceList1}    
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200


    ${serviceList2}=  Create Dictionary  serviceId=${sid2}      price=${serviceprice} 

    ${resp}=  RemoveServiceFromInvoice   ${invoice_apptwalkin_uid}   ${serviceList2}    
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_apptwalkin_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['serviceId']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['serviceName']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['price']}  ${servicecharge}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['netRate']}  ${servicecharge}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][1]['serviceId']}  ${sid2}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][1]['serviceName']}  ${SERVICE2}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][1]['quantity']}  ${quantity}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][1]['price']}  ${serviceprice}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][1]['netRate']}  ${netRate}
    # Should Be Equal As Strings  ${resp.json()['amountDue']}  ${servicecharge}
    Should Be Equal As Strings  ${resp.json()['amountTotal']}  ${servicecharge}
    Should Be Equal As Strings  ${resp.json()['netTotal']}  ${servicecharge}
    Should Be Equal As Strings  ${resp.json()['netRate']}  ${servicecharge}

JD-TC-Remove Services to finance-4

    [Documentation]   Service auto invoice generation is on,then took walkin token  and check whethrer invoice is created there .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

    # ${resp}=  Enable Waitlist
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Waitlist Settings
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}   200

      ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
      Log    ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

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

      ${resp}=  AddCustomer  ${CUSERNAME1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid}  ${resp.json()}

      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
      Log   ${resp.json()}
      Should Be Equal As Strings      ${resp.status_code}  200
     

    # ${resp}=  Create Sample Location  
    # Set Suite Variable    ${loc_id1}    ${resp}  

    # ${resp}=   Get Location ById  ${loc_id1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${tz}  ${resp.json()['timezone']}

      ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable  ${CUR_DAY} 
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
      ${resp}=   Create Sample Service  ${SERVICE1}   automaticInvoiceGeneration=${bool[1]}
      Set Suite Variable    ${ser_id1}    ${resp}  

    # ${resp}=  Auto Invoice Generation For Service   ${ser_id1}    ${toggle[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${ser_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}
    Set Test Variable   ${tot_amt}   ${resp.json()['totalAmount']}
    ${SER}=    generate_unique_service_name  ${service_names}
      ${resp}=   Create Sample Service  ${SER}
      Set Suite Variable    ${ser_id2}    ${resp} 
    ${SERVICE3}=    generate_unique_service_name  ${service_names} 
      ${resp}=   Create Sample Service  ${SERVICE3}
      Set Suite Variable    ${ser_id3}    ${resp}  
      ${q_name}=    FakerLibrary.name
      Set Suite Variable    ${q_name}
      ${list}=  Create List   1  2  3  4  5  6  7
      Set Suite Variable    ${list}
      ${strt_time}=   db.add_timezone_time     ${tz}  1  00
      Set Suite Variable    ${strt_time}
      ${end_time}=    db.add_timezone_time     ${tz}  3  00 
      Set Suite Variable    ${end_time}   
      ${parallel}=   Random Int  min=1   max=1
      Set Suite Variable   ${parallel}
      ${capacity}=  Random Int   min=10   max=20
      Set Suite Variable   ${capacity}
      ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${lid}  ${ser_id1}  ${ser_id2}  ${ser_id3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id1}   ${resp.json()}
      ${desc}=   FakerLibrary.word
      Set Suite Variable  ${desc}
      ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid}   location=${lid}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
    #   Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby}   personsAhead=0
      # Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
      # Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
      # Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
      # Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
      # Should Be Equal As Strings  ${resp.json()['paymentStatus']}         ${paymentStatus[0]}
      Set Test Variable   ${fullAmount}  ${resp.json()['fullAmt']}   


    ${resp1}=  Get Booking Invoices  ${wid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable  ${invoice_wtlistwalkin_uid}  ${resp1.json()[0]['invoiceUid']}

    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${serviceprice}=   Random Int  min=100  max=500
    ${serviceprice}=  Convert To Number  ${serviceprice}  1
    ${serviceList1}=  Create Dictionary  serviceId=${sid2}   quantity=${quantity}   price=${serviceprice} 
    # ${serviceList1}=    Create List    ${serviceList1}
    ${netRate}=  Evaluate  ${quantity} * ${serviceprice}
    ${netRate}=  Convert To Number  ${netRate}  1
    ${Total}=  Evaluate  ${tot_amt} + ${netRate}
    ${Total}=  Convert To Number  ${Total}  1


    ${resp}=  AddServiceToInvoice    ${invoice_wtlistwalkin_uid}   ${serviceList1}    
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${serviceList2}=  Create Dictionary  serviceId=${sid2}      price=${serviceprice} 

    ${resp}=  RemoveServiceFromInvoice   ${invoice_wtlistwalkin_uid}   ${serviceList2}    
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_wtlistwalkin_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['serviceId']}  ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['serviceName']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['price']}  ${tot_amt}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['netRate']}  ${tot_amt}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][1]['serviceId']}  ${sid2}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][1]['serviceName']}  ${SERVICE2}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][1]['quantity']}  ${quantity}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][1]['price']}  ${serviceprice}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][1]['netRate']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()['amountDue']}  ${tot_amt}
    Should Be Equal As Strings  ${resp.json()['amountTotal']}  ${tot_amt}
    Should Be Equal As Strings  ${resp.json()['netTotal']}  ${tot_amt}
    Should Be Equal As Strings  ${resp.json()['netRate']}  ${tot_amt}

# JD-TC-Remove Services to finance-5

#     [Documentation]   Service auto invoice generation is on,then took walkin token  and check whethrer invoice is created there .

#     ${resp}=  Get Order Settings by account id
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings
