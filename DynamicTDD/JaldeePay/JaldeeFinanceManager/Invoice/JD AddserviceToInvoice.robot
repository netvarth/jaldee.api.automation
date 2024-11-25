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

${jpgfile}      /ebs/TDD/uploadimage.jpg
${jpgfile2}      /ebs/TDD/small.jpg
${gif}      /ebs/TDD/sample.gif
${xlsx}      /ebs/TDD/qnr.xlsx

${service_duration}     30
${service_duration1}     10
@{emptylist}
${self}         0
${waitlistedby}           PROVIDER




*** Test Cases ***

JD-TC-Apply Service to Finance-1

    [Documentation]  Create one invoice with one service .then add another service to invoice.


    ${firstname}  ${lastname}  ${PUSERPH0}  ${LoginId}=  Provider Signup
    Set Suite Variable  ${PUSERPH0}

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
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

    ${resp}=  Create Sample Location  
    Set Suite Variable    ${lid}    ${resp}  

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

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


    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END


    ${name}=   FakerLibrary.word
    ${resp}=  CreateVendorCategory  ${name}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id}   ${resp.json()}

    ${resp}=  Get by encId  ${category_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${name1}=   FakerLibrary.word
    Set Suite Variable   ${name1}
    ${resp}=  Create Category   ${name1}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id2}   ${resp.json()}

    ${vender_name}=   FakerLibrary.firstname
    ${contactPersonName}=   FakerLibrary.lastname
    ${owner_name}=   FakerLibrary.lastname
    ${vendorId}=   FakerLibrary.word
    ${PO_Number}    Generate random string    5    123456789
    ${vendor_phno}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${vendor_phno}=  Create Dictionary  countryCode=${countryCodes[0]}   number=${vendor_phno}
    Set Test Variable  ${email}  ${vender_name}.${test_mail}
    ${address}=  FakerLibrary.city
    Set Suite Variable  ${address}
    ${bank_accno}=   db.Generate_random_value  size=11   chars=${digits} 
    ${branch}=   db.get_place
    ${ifsc_code}=   db.Generate_ifsc_code
    # ${gst_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}

    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}
    Set Suite Variable    ${state}
    Set Suite Variable    ${district}
    Set Suite Variable    ${pin}
    ${vendor_phno}=   Create List  ${vendor_phno}
    Set Suite Variable    ${vendor_phno}
    
    ${email}=   Create List  ${email}
    Set Suite Variable    ${email}

    ${bankIfsc}    Random Number 	digits=5 
    ${bankIfsc}=    Evaluate    f'{${bankIfsc}:0>7d}'
    Log  ${bankIfsc}
    Set Suite Variable  ${bankIfsc}  55555${bankIfsc} 

    ${bankName}     FakerLibrary.name
    Set Suite Variable    ${bankName}

    ${upiId}     FakerLibrary.name
    Set Suite Variable  ${upiId}

    ${pan}    Random Number 	digits=5 
    ${pan}=    Evaluate    f'{${pan}:0>5d}'
    Log  ${pan}
    Set Suite Variable  ${pan}  55555${pan}

    ${branchName}=    FakerLibrary.name
    Set Suite Variable  ${branchName}
    ${gstin}    Random Number 	digits=5 
    ${gstin}=    Evaluate    f'{${gstin}:0>8d}'
    Log  ${gstin}
    Set Suite Variable  ${gstin}  55555${gstin}
    
    ${preferredPaymentMode}=    Create List    ${jaldeePaymentmode[0]}
    ${bankInfo}=    Create Dictionary     bankaccountNo=${bank_accno}    ifscCode=${bankIfsc}    bankName=${bankName}    upiId=${upiId}     branchName=${branchName}    pancardNo=${pan}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    ${bankInfo}=    Create List         ${bankInfo}

    ${resp}=   Get next invoice Id   ${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${invoiceId}   ${resp.json()}
    


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



     ${SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500


    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[1]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()} 


    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${serviceprice}=   Random Int  min=100  max=500
    ${serviceprice}=  Convert To Number  ${serviceprice}  1
    ${netRate}=  Evaluate  ${quantity} * ${serviceprice}

    ${serviceList}=  Create Dictionary  serviceId=${sid1}   quantity=${quantity}   price=${serviceprice} 
    ${serviceList}=    Create List    ${serviceList}
    
    
    ${resp}=  Create Invoice   ${category_id2}    ${invoiceDate}     ${invoiceId}    ${providerConsumerIdList}   ${lid}   serviceList=${serviceList}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_uid}   ${resp.json()['uidList'][0]} 


     ${SERVICE2}=    FakerLibrary.word
    Set Suite Variable  ${SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[1]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid2}  ${resp.json()} 



    ${serviceList1}=  Create Dictionary  serviceId=${sid2}   quantity=${quantity}   price=${serviceprice} 
    # ${serviceList1}=    Create List    ${serviceList1}


    ${resp}=  AddServiceToInvoice   ${invoice_uid}   ${serviceList1}    
    Log  ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200




    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['serviceId']}  ${sid1}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][0]['serviceName']}  ${SERVICE1}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][0]['quantity']}  ${quantity}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][0]['price']}  ${serviceprice}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][0]['netRate']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['serviceId']}  ${sid2}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][1]['serviceName']}  ${SERVICE2}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][1]['quantity']}  ${quantity}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][1]['price']}  ${serviceprice}
    # Should Be Equal As Strings  ${resp.json()['serviceList'][1]['netRate']}  ${netRate}

JD-TC-Apply Service To Finance-2

    [Documentation]   Service auto invoice generation is on,then took one appointment from consumer side  and check whethrer invoice is created there ,then add service to that invoice.


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

    clear_appt_schedule   ${PUSERPH0}

    ${pid}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME32}

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word

  
    ${SERVICE3}=    FakerLibrary.word

    ${s_id}=  Create Sample Service  ${SERVICE3}    automaticInvoiceGeneration=${bool[1]}
    Set Test Variable   ${s_id}

    # ${resp}=  Auto Invoice Generation For Service   ${s_id}    ${toggle[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}
    Set Test Variable  ${servicecharge}  ${resp.json()['totalAmount']}




    ${resp}=  Get Appointment Schedules
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


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


    ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456987
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Suite Variable    ${primaryMobileNo}
    ${email}=    FakerLibrary.Email
    Set Suite Variable    ${email}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Consumer Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${primaryMobileNo}     ${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${account_id1}  ${token} 
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


    sleep  02s

    ${resp}=  Encrypted Provider Login    ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    sleep  02s
    ${resp1}=  Get Bookings Invoices  ${apptid1}
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


    ${resp}=  AddServiceToInvoice   ${invoice_appt_uid}   ${serviceList1}    
    Log  ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_appt_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['serviceId']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['serviceName']}  ${SERVICE3}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['price']}  ${servicecharge}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['netRate']}  ${servicecharge}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['serviceId']}  ${sid2}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['serviceName']}  ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['price']}  ${serviceprice}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['netRate']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()['amountDue']}  ${Total}
    Should Be Equal As Strings  ${resp.json()['amountTotal']}  ${Total}
    Should Be Equal As Strings  ${resp.json()['netTotal']}  ${Total}
    Should Be Equal As Strings  ${resp.json()['netRate']}  ${Total}

    ${resp1}=  Get consumer Appt Bill Details   ${apptid1}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200

JD-TC-Apply Services to Invoice-3

    [Documentation]   Service auto invoice generation is on,then took walkin appointment  and check whethrer invoice is created there then add service to that invoice.





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


    clear_appt_schedule   ${PUSERPH0}

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1

    ${srv_duration}=   Random Int   min=10   max=20

    
    ${s_id}=  Create Sample Service   ${SERVICE1}  isPrePayment=${bool[1]}  minPrePaymentAmount=${min_pre}   maxBookingsAllowed=10     automaticInvoiceGeneration=${bool[1]}
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
    Set Test Variable   ${servicecharge}   ${resp.json()['totalAmount']}


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
# firstName=${fname1}   lastName=${lname1}
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
    Should Be Equal As Strings  ${resp.json()['uid']}                              ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}                  ${encId}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}        ${CUSERNAME2}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['jaldeeId']}      ${jaldeeid1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                      ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                      ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                          ${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}             ${fname1}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}              ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}              ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                            ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                            ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                       ${lid}

    ${resp1}=  Get Bookings Invoices  ${apptid1}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable  ${invoice_apptwalkin_uid}  ${resp1.json()[0]['invoiceUid']}
    Should Be Equal As Strings  ${resp1.json()[0]['netTotal']}     ${servicecharge}
    Should Be Equal As Strings  ${resp1.json()[0]['netRate']}     ${servicecharge}
    Should Be Equal As Strings  ${resp1.json()[0]['amountDue']}     ${servicecharge}
    Should Be Equal As Strings  ${resp1.json()[0]['amountTotal']}     ${servicecharge}

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


    ${resp}=  AddServiceToInvoice   ${invoice_apptwalkin_uid}   ${serviceList1}    
    Log  ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_apptwalkin_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['serviceId']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['serviceName']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['price']}  ${servicecharge}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['netRate']}  ${servicecharge}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['serviceId']}  ${sid2}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['serviceName']}  ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['price']}  ${serviceprice}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['netRate']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()['amountDue']}  ${Total}
    Should Be Equal As Strings  ${resp.json()['amountTotal']}  ${Total}
    Should Be Equal As Strings  ${resp.json()['netTotal']}  ${Total}
    Should Be Equal As Strings  ${resp.json()['netRate']}  ${Total}

JD-TC-Apply Services to Invoice-4

    [Documentation]   Service auto invoice generation is on,then took walkin token  and check whethrer invoice is created there then add service to that invoice.

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
    ${SERVICE1}=    FakerLibrary.word
      ${resp}=   Create Sample Service  ${SERVICE1}    automaticInvoiceGeneration=${bool[1]}
      Set Suite Variable    ${ser_id1}    ${resp}  

    # ${resp}=  Auto Invoice Generation For Service   ${ser_id1}    ${toggle[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${ser_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}
    Set Test Variable   ${tot_amt}   ${resp.json()['totalAmount']}
    ${SER}=    FakerLibrary.word
      ${resp}=   Create Sample Service  ${SER}
      Set Suite Variable    ${ser_id2}    ${resp} 
    ${SERVICE3}=    FakerLibrary.word 
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
      Set Test Variable   ${fullAmount}  ${resp.json()['fullAmt']}   


    ${resp1}=  Get Bookings Invoices  ${wid}
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


    ${resp}=  AddServiceToInvoice   ${invoice_wtlistwalkin_uid}   ${serviceList1}    
    Log  ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_wtlistwalkin_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['serviceId']}  ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['serviceName']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['price']}  ${tot_amt}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['netRate']}  ${tot_amt}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['serviceId']}  ${sid2}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['serviceName']}  ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['price']}  ${serviceprice}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['netRate']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()['amountDue']}  ${Total}
    Should Be Equal As Strings  ${resp.json()['amountTotal']}  ${Total}
    Should Be Equal As Strings  ${resp.json()['netTotal']}  ${Total}
    Should Be Equal As Strings  ${resp.json()['netRate']}  ${Total}


JD-TC-Apply Services to Invoice-5
    [Documentation]  Taking waitlist from consumer side and the consumer doing the prepayment - check invoice(auto-invoice generation flag is on) then add service to that invoice.



    ${firstname}  ${lastname}  ${PUSERPH1}  ${LoginId}=  Provider Signup
    Set Suite Variable  ${PUSERPH1}
    
    # ------------- Get general details and settings of the provider and update all needed settings
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Verify Response  ${resp}  onlineCheckIns=${bool[1]}

    ${resp}=  Enable Waitlist
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp1}=   Run Keyword If  ${resp.json()['onlinePresence']}==${bool[0]}   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END
    
    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

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
    Set Suite Variable  ${accountId}  ${resp.json()['accountId']}    
    

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${p1_lid}=  Create Sample Location
    ${resp}=  Get Locations
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_lid}  ${resp.json()[0]['id']} 

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}  

    ${min_pre}=   Random Int   min=40   max=50
    ${Tot}=   Random Int   min=100   max=300
    ${min_pre}=  Convert To Number  ${min_pre}  1
    # ${pre_float}=  twodigitfloat  ${min_pre}
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot}   ${Tot1}

    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence

    ${p1_sid1}=  Create Sample Service   ${P1SERVICE1}  isPrePayment=${bool[1]}  minPrePaymentAmount=${min_pre}   maxBookingsAllowed=10    automaticInvoiceGeneration=${bool[1]}

    # ${resp}=  Auto Invoice Generation For Service   ${p1_sid1}    ${toggle[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${p1_sid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}


    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE2} 
    ${desc}=   FakerLibrary.sentence

    ${p1_sid2}=  Create Sample Service   ${P1SERVICE2}     automaticInvoiceGeneration=${bool[1]}

    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${serviceprice}=   Random Int  min=100  max=500
    ${serviceprice}=  Convert To Number  ${serviceprice}  1
    ${serviceList1}=  Create Dictionary  serviceId=${p1_sid2}   quantity=${quantity}   price=${serviceprice} 

    # ${resp}=  Auto Invoice Generation For Service   ${p1_sid2}    ${toggle[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${p1_sid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}

    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${sTime}=  add_timezone_time  ${tz}  2  00  
    ${eTime}=  add_timezone_time  ${tz}  2  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_lid}  ${p1_sid1}  ${p1_sid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Suite Variable    ${primaryMobileNo}
    ${email}=    FakerLibrary.Email
    Set Suite Variable    ${email}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${primaryMobileNo}     ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid1}    ${resp.json()['providerConsumer']}


    Set Test Variable  ${consumerEmail}  ${primaryMobileNo}.${test_mail}

    ${resp}=    Update ProviderConsumer    ${cid1}    email=${consumerEmail}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get ProviderConsumer
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Add To Waitlist Consumers    ${cid1}   ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 


    sleep   02s
    
    ${tax1}=  Evaluate  ${Tot}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot}+${tax}
    ${totalamt}=  Convert To Integer  ${totalamt}
    ${balamount}=  Evaluate  ${totalamt}-${min_pre}
    ${balamount}=  Convert To Integer  ${balamount}  


    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}


    sleep   02s

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre}  ${purpose[0]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log  ${resp.json()}
    # ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre}  ${purpose[0]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    # Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Make payment Consumer Mock  ${min_pre}  ${bool[1]}  ${cwid}  ${pid}  ${purpose[0]}  ${cid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    ${resp}=  Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp1}=  Get consumer Waitlist Bill Details   ${cwid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200

    sleep  02s
    ${resp}=  Get Bookings Invoices  ${cwid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   ${response_netRate}=  Convert To Integer  ${resp.json()[0]['netRate']}
   ${response_amountDue}=  Convert To Integer  ${resp.json()[0]['amountDue']} 

    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}  ${p1_sid1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['price']}  ${Tot}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}  ${Tot}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['ynwUuid']}  ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['amountPaid']}  ${min_pre}
    Should Be Equal As Strings  ${response_amountDue}   ${balamount}
    Should Be Equal As Strings  ${resp.json()[0]['amountTotal']}  ${Tot}
    Should Be Equal As Strings  ${resp.json()[0]['taxPercentage']}  ${gstpercentage[3]}
    Should Be Equal As Strings  ${resp.json()[0]['defaultCurrencyAmount']}  ${Tot}
    Should Be Equal As Strings  ${resp.json()[0]['netTaxAmount']}  ${tax}
    Should Be Equal As Strings  ${resp.json()[0]['netTotal']}  ${Tot}
    Should Be Equal As Strings  ${response_netRate}  ${totalamt}
    Should Be Equal As Strings  ${resp.json()[0]['taxableTotal']}  ${Tot}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${cwid}
    Set Suite Variable  ${invoice_wtlistonline_uid}  ${resp.json()[0]['invoiceUid']}


    ${resp}=  AddServiceToInvoice   ${invoice_wtlistonline_uid}   ${serviceList1}    
    Log  ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${service_quantity}=  Evaluate  ${serviceprice}*${quantity}
    ${amount_tot}=  Evaluate  ${Tot}+${service_quantity}
    ${tax2}=  Evaluate  ${amount_tot}*${gstpercentage[3]}
    ${nettax}=   Evaluate  ${tax2}/100
    ${netRate}=  Evaluate  ${amount_tot}+${nettax}
    # ${netRate}=  twodigitfloat  ${netRate}
    ${amountDue}=  Evaluate  ${netRate}-${min_pre}
    ${amountDue}=  Convert To Number  ${amountDue}  2

    ${resp}=  Get Bookings Invoices  ${cwid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}  ${p1_sid1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['price']}  ${Tot}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}  ${Tot}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['ynwUuid']}  ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['serviceId']}  ${p1_sid2}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['serviceName']}  ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['price']}  ${serviceprice}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['netRate']}  ${service_quantity}
    Should Be Equal As Strings  ${resp.json()[0]['amountPaid']}  ${min_pre}
    Should Be Equal As Strings  ${resp.json()[0]['amountDue']}  ${amountDue}
    Should Be Equal As Strings  ${resp.json()[0]['amountTotal']}  ${amount_tot}
    Should Be Equal As Strings  ${resp.json()[0]['taxPercentage']}  ${gstpercentage[3]}
    Should Be Equal As Strings  ${resp.json()[0]['netTaxAmount']}  ${nettax}
    Should Be Equal As Strings  ${resp.json()[0]['netTotal']}  ${amount_tot}
    Should Be Equal As Strings  ${resp.json()[0]['netRate']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['taxableTotal']}  ${amount_tot}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${cwid}




JD-TC-Apply Service To Finance-UH1

    [Documentation]   Have Prepayment service for provider.consumer is try to take booking without prepayment.


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



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
  
    ${SERVICE3}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    # ${servicecharge}=  Convert To Number  ${servicecharge}  1 
    ${srv_duration}=   Random Int   min=10   max=20
    # ${resp}=  Create Service  ${SERVICE3}  ${desc}   ${srv_duration}  ${bool[1]}  ${servicecharge}  ${bool[0]}  minPrePaymentAmount=${min_pre}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}   200
    # Set Test Variable  ${s_id}  ${resp.json()}

    ${s_id}=  Create Sample Service   ${SERVICE3}  isPrePayment=${bool[1]}  minPrePaymentAmount=${min_pre}   maxBookingsAllowed=10    automaticInvoiceGeneration=${bool[1]}

    # ${resp}=  Auto Invoice Generation For Service   ${s_id}    ${toggle[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}
    Set Test Variable   ${servicecharge}   ${resp.json()['totalAmount']}


    clear_appt_schedule   ${PUSERPH0}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

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
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}




    ${firstName}=  FakerLibrary.name
    Set Test Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Test Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456987
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Test Variable    ${primaryMobileNo}
    ${email}=    FakerLibrary.Email
    Set Test Variable    ${email}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${primaryMobileNo}     ${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${account_id1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid1}    ${resp.json()['providerConsumer']}



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

    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}    location=${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[1]}


   ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}    apptStatus=${apptStatus[0]}

    sleep  02s

    ${resp}=  Encrypted Provider Login    ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    sleep  02s

    ${NO_INVOICE_GENERATED}=  format String   ${NO_INVOICE_GENERATED}   ${apptid1}
#   Invoice is not generated because prepayment pending
    ${resp1}=  Get Bookings Invoices  ${apptid1}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  422
    Should Be Equal As Strings  ${resp1.json()}   ${NO_INVOICE_GENERATED}
          
*** Comments ***
JD-TC-Apply Service Level Discount-2

    [Documentation]   Apply discount with empty private note and display note.



    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=50   max=100
    ${discountprice}=  Convert To Number  ${discountprice1}  1
    Set Suite Variable   ${discountprice}
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.json()}
    Set Suite Variable   ${discountId1}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${discountValue1}=     Random Int   min=50   max=100
    ${discountValue1}=  Convert To Number  ${discountValue1}  1



    ${resp}=   Apply Service Level Discount   ${invoice_uid}   ${discountId1}    ${discountprice}   ${EMPTY}  ${EMPTY}  ${sid1}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][1]['id']}  ${discountId1}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][1]['name']}  ${discount1}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][1]['discountType']}  ${disctype[0]}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][1]['discountValue']}  ${discountprice}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][1]['calculationType']}  ${calctype[1]}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][1]['privateNote']}  ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][1]['displayNote']}  ${EMPTY}


JD-TC-Apply Service Level Discount--3

    [Documentation]   create discount and remove that then apply discount.



    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word

    ${resp}=  Remove Service Level Discount   ${invoice_uid}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}   ${sid1}
    Log  ${resp.json()}  
    Set Suite Variable   ${rmvid}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['discounts']}  []

    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Apply Service Level Discount   ${invoice_uid}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}  ${sid1}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][1]['id']}  ${discountId}

JD-TC-Apply Service Level Discount-4

    [Documentation]   create percentage type discount apply discount.



    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=50   max=100
    ${discountprice}=  Convert To Number  ${discountprice1}  1
    Set Suite Variable   ${discountprice}
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice}   ${calctype[0]}  ${disctype[0]}
    Log  ${resp.json()}
    Set Test Variable   ${discountId}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${discountValue1}=     Random Int   min=50   max=100
    ${discountValue1}=  Convert To Number  ${discountValue1}  1



    ${resp}=   Apply Service Level Discount   ${invoice_uid}   ${discountId}    ${discountprice}   ${EMPTY}  ${EMPTY}  ${sid1}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][2]['id']}  ${discountId}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][2]['name']}  ${discount1}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][2]['discountType']}  ${disctype[0]}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][2]['discountValue']}  ${discountprice}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][2]['calculationType']}  ${calctype[0]}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][2]['privateNote']}  ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][2]['displayNote']}  ${EMPTY}






JD-TC-Apply Service Level Discount-UH1

    [Documentation]   apply already applied discount.


  ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word


    ${resp}=   Apply Service Level Discount   ${invoice_uid}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${DISCOUNT_ALREADY_USED}

JD-TC-Apply Service Level Discount-UH2

    [Documentation]   Discount is higher than invoice amount.


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=2350   max=3500
    ${discountprice}=  Convert To Number  ${discountprice1}  1
    Set Suite Variable   ${discountprice}
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.json()}
    Set Test Variable   ${discountId}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${discountValue1}=     Random Int   min=50   max=100
    ${discountValue1}=  Convert To Number  ${discountValue1}  1


    ${resp}=   Apply Service Level Discount   ${invoice_uid}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}  ${sid1}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${NEED_BILL_AMOUNT_HIGHER_THAN_DISCOUNT}

JD-TC-Apply Service Level Discount-UH3

    [Documentation]   Apply discount with discount price is empty.


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word


     ${resp}=   Apply Service Level Discount   ${invoice_uid}   ${discountId}    ${EMPTY}   ${privateNote}  ${displayNote}  ${sid1}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${DISCOUNT_ALREADY_USED}

JD-TC-Apply Service Level Discount-UH4

    [Documentation]   Apply discount where invoice_uid is wrong.

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${invoice}=   FakerLibrary.word


    ${resp}=   Apply Service Level Discount   ${invoice}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}  ${sid1}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  ${resp.json()}    ${DISCOUNT_ALREADY_USED}

JD-TC-Apply Service Level Discount-UH5

    [Documentation]   Apply discount where discountid is wrong.


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${discount}=   FakerLibrary.RandomNumber


    ${resp}=   Apply Service Level Discount   ${invoice}   ${discount}    ${discountprice}   ${privateNote}  ${displayNote}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${INCORRECT_DISCOUNT_ID}

JD-TC-Apply Service Level Discount-UH6

    [Documentation]   Apply Service Level Discount where service id is wrong.


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${serviceid}=   FakerLibrary.RandomNumber

    ${resp}=   Apply Service Level Discount   ${invoice_uid}   ${EMPTY}    ${discountprice}   ${privateNote}  ${displayNote}  ${serviceid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${SERVICE_NOT}

JD-TC-Apply Service Level Discount-UH7

    [Documentation]   Apply one service thats not added to any invoice then try to remove apply itemlevel discount using this service id.


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

     ${SERVICE2}=    FakerLibrary.word
    Set Suite Variable  ${SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid}  ${resp.json()} 

    ${resp}=   Apply Service Level Discount   ${invoice_uid}   ${discountId}    ${discountprice}   ${EMPTY}  ${EMPTY}  ${sid}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${SERVICE_NOT}
















