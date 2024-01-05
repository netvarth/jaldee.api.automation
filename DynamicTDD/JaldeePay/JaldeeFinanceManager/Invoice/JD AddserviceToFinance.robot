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
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py

*** Variables ***

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf
${jpgfile2}      /ebs/TDD/small.jpg
${gif}      /ebs/TDD/sample.gif
${xlsx}      /ebs/TDD/qnr.xlsx

${order}    0
${fileSize}  0.00458
${service_duration}     30
${service_duration1}     10
@{emptylist}
${self}         0
${waitlistedby}           PROVIDER
@{status1}    New     Pending    Assigned     Approved    Rejected
@{New_status}    Proceed     Unassign    Block     Delete    Remove
${DisplayName1}   item1_DisplayName

***Keywords***


Get Billable Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Suite Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Should Be Equal As Strings    ${resp.status_code}    200
            Exit For Loop IF  '${resp.json()['serviceBillable']}' == '${bool[1]}'
    END
    [Return]  ${subdomain}  ${resp.json()['serviceBillable']}



Get Non Billable Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Test Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Should Be Equal As Strings    ${resp.status_code}    200
            Exit For Loop IF  '${resp.json()['serviceBillable']}' == '${bool[0]}'
    END
    [Return]  ${subdomain}  ${resp.json()['serviceBillable']}




*** Test Cases ***

JD-TC-Apply Service to Finance-1

    [Documentation]  Apply Service Level Discount.


    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+3381864
    Set Suite Variable   ${PUSERPH0}
    
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
   FOR  ${pos}  IN RANGE  ${dlen}  
        Set Suite Variable  ${d1}  ${domresp.json()[${pos}]['domain']}
        ${sd1}  ${check}=  Get Billable Subdomain  ${d1}  ${domresp}  ${pos}  
        Set Suite Variable   ${sd1}
        Exit For Loop IF     '${check}' == '${bool[1]}'
    END
    Log  ${d1}
    Log  ${sd1}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}=    Random Element    ${Genderlist}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERPH0}  ${licid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${PUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  "${resp.json()}"    "true"
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH0}${\n}

    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${result}=  Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment
    Log   ${result.json()}
    Should Be Equal As Strings  ${result.status_code}  200
    ${resp}=   Get Accountsettings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appointment']}   ${bool[1]}
    

    ${accId}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${accId}


    ${resp}=  Create Sample Location  
    Set Suite Variable    ${lid}    ${resp}  

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  
    ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
    ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${city}=   get_place
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=   db.add_timezone_time     ${tz}  0  15     
    Set Suite Variable   ${sTime}
    ${eTime}=   db.add_timezone_time     ${tz}  0  45    
    Set Suite Variable   ${eTime}
    ${resp}=  Update Business Profile With Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

    ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

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

    ${resp}=  View Waitlist Settings
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



    ${name}=   FakerLibrary.word
    ${resp}=  Create Category   ${name}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id}   ${resp.json()}


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
    Set Test Variable  ${email}  ${vender_name}${vendor_phno}.${test_mail}
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
    
    ${resp}=  Create Vendor  ${category_id}  ${vendorId}  ${vender_name}   ${contactPersonName}    ${address}    ${state}    ${pin}   ${vendor_phno}   ${email}     bankInfo=${bankInfo}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${vendor_uid1}   ${resp.json()['uid']}
    Set Suite Variable   ${vendor_id1}   ${resp.json()['id']}

    ${resp}=  Get Vendor By Id   ${vendor_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${vendor_id1}
    Should Be Equal As Strings  ${resp.json()['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorType']}  ${category_id}

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


     ${SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${service_duration}   ${status[0]}    ${btype}    ${bool[1]}    ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}   
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
    
    
    ${resp}=  Create Invoice   ${category_id2}    ${invoiceDate}   ${invoiceLabel}   ${address}   ${vendor_uid1}   ${invoiceId}    ${providerConsumerIdList}    serviceList=${serviceList}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_uid}   ${resp.json()['uidList'][0]} 


     ${SERVICE2}=    FakerLibrary.word
    Set Suite Variable  ${SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${service_duration}   ${status[0]}    ${btype}    ${bool[1]}    ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid2}  ${resp.json()} 



    ${serviceList1}=  Create Dictionary  serviceId=${sid2}   quantity=${quantity}   price=${serviceprice} 
    # ${serviceList1}=    Create List    ${serviceList1}


    ${resp}=  AddServiceToFinance   ${invoice_uid}   ${serviceList1}    
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
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['serviceId']}  ${sid2}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['serviceName']}  ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['price']}  ${serviceprice}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['netRate']}  ${netRate}

JD-TC-Apply Service To Finance-2

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
    # Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    # Set Suite Variable  ${CUR_DAY}
  
    ${SERVICE3}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${servicecharge}=  Convert To Number  ${servicecharge}  1 
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE3}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=  Auto Invoice Generation For Service   ${s_id}    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}


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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    # ${resp}=  Consumer Login  ${CUSERNAME32}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  ${jdconID}   ${resp.json()['id']}
    # Set Test Variable  ${fname}   ${resp.json()['firstName']}
    # Set Test Variable  ${lname}   ${resp.json()['lastName']}


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

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   12
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${primaryMobileNo}     ${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${account_id1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid1}    ${resp.json()['providerConsumer']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-3}
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}    location=${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${firstName}
    Set Suite Variable   ${apptid1}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response    ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}  ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${firstName}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lastName}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

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


    ${resp}=  AddServiceToFinance   ${invoice_appt_uid}   ${serviceList1}    
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
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['serviceId']}  ${sid2}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['serviceName']}  ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['price']}  ${serviceprice}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['netRate']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()['amountDue']}  ${Total}
    Should Be Equal As Strings  ${resp.json()['amountTotal']}  ${Total}
    Should Be Equal As Strings  ${resp.json()['netTotal']}  ${Total}
    Should Be Equal As Strings  ${resp.json()['netRate']}  ${Total}

JD-TC-Apply Services to finance-3

    [Documentation]   Service auto invoice generation is on,then took walkin appointment  and check whethrer invoice is created there .

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname1}   ${resp.json()['firstName']}
    Set Test Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


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
    # Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    clear_appt_schedule   ${PUSERPH0}

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${servicecharge}=  Convert To Number  ${servicecharge}  1 
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}

    ${resp}=  Auto Invoice Generation For Service   ${s_id}    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${resp}=  AddCustomer  ${CUSERNAME2}   firstName=${fname1}   lastName=${lname1}
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
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}             ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}              ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}              ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                            ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                            ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                       ${lid}

    ${resp1}=  Get Bookings Invoices  ${apptid1}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable  ${invoice_apptwalkin_uid}  ${resp1.json()[0]['invoiceUid']}
    Should Be Equal As Strings  ${resp1.json()[0]['netTotal']}     ${tot_amt}
    Should Be Equal As Strings  ${resp1.json()[0]['netRate']}     ${tot_amt}
    Should Be Equal As Strings  ${resp1.json()[0]['amountDue']}     ${tot_amt}
    Should Be Equal As Strings  ${resp1.json()[0]['amountTotal']}     ${tot_amt}

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


    ${resp}=  AddServiceToFinance   ${invoice_apptwalkin_uid}   ${serviceList1}    
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
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['serviceId']}  ${sid2}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['serviceName']}  ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['price']}  ${serviceprice}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['netRate']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()['amountDue']}  ${Total}
    Should Be Equal As Strings  ${resp.json()['amountTotal']}  ${Total}
    Should Be Equal As Strings  ${resp.json()['netTotal']}  ${Total}
    Should Be Equal As Strings  ${resp.json()['netRate']}  ${Total}

JD-TC-Apply Services to finance-4

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

      ${resp}=  View Waitlist Settings
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
    # Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

      ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable  ${CUR_DAY} 
    ${SERVICE1}=    FakerLibrary.word
      ${resp}=   Create Sample Service  ${SERVICE1}
      Set Suite Variable    ${ser_id1}    ${resp}  

    ${resp}=  Auto Invoice Generation For Service   ${ser_id1}    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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
    #   Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby}   personsAhead=0
      Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
      Should Be Equal As Strings  ${resp.json()['paymentStatus']}         ${paymentStatus[0]}
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


    ${resp}=  AddServiceToFinance   ${invoice_wtlistwalkin_uid}   ${serviceList1}    
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
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['serviceId']}  ${sid2}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['serviceName']}  ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['price']}  ${serviceprice}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['netRate']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()['amountDue']}  ${Total}
    Should Be Equal As Strings  ${resp.json()['amountTotal']}  ${Total}
    Should Be Equal As Strings  ${resp.json()['netTotal']}  ${Total}
    Should Be Equal As Strings  ${resp.json()['netRate']}  ${Total}


JD-TC-Apply Services to finance-5
    [Documentation]  Taking waitlist from consumer side and the consumer doing the prepayment first then full payment,then check invoice(auto-invoice generation flag is on)
   
    # ${billable_providers}=    Billable Domain Providers   min=70   max=80
    # Log   ${billable_providers}
    # Set Suite Variable   ${billable_providers}
    # ${pro_len}=  Get Length   ${billable_providers}
    # Log  ${pro_len}
    # clear_location  ${PUSERPH1}
    # clear_service    ${PUSERPH1}
    # clear_queue     ${PUSERPH1}
    # clear_customer   ${PUSERPH1}

    # ${pid}=  get_acc_id  ${PUSERPH1}
    # Set Suite Variable  ${pid}

    # ${resp}=  Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${DAY}=  db.get_date_by_timezone  ${tz}
    # Set Suite Variable  ${DAY}
    # ${list}=  Create List  1  2  3  4  5  6  7

    ${PO_Number}    Generate random string    8    1234564789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH1}${\n}
    Set Suite Variable   ${PUSERPH1}
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH1}   AND  clear_service  ${PUSERPH1}  AND  clear_Item    ${PUSERPH1}  AND   clear_Coupon   ${PUSERPH1}   AND  clear_Discount  ${PUSERPH1}  AND  clear_appt_schedule   ${PUSERPH1}
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    Set Test Variable   ${licid}
    
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.content}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${d1}=  Random Int   min=0  max=${dlen-1}
    Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    ${sdom}=  Random Int   min=0  max=${sdlen-1}
    Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ['Male', 'Female']
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERPH1}  ${licid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${PUSERPH1}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.content}    "true"
    
    ${resp}=  Account Set Credential  ${PUSERPH1}  ${PASSWORD}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  
    @{Views}=  Create List  self  all  customersOnly
    ${ph1}=  Evaluate  ${PUSERPH1}+1000000000
    ${ph2}=  Evaluate  ${PUSERPH1}+2000000000
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}025.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    Set Suite Variable   ${eTime}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}  
    
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.content}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Test Variable  ${email_id}  ${P_Email}${PUSERPH1}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    # ------------- Get general details and settings of the provider and update all needed settings
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Get License UsageInfo 
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
    ${resp1}=   Run Keyword If  ${resp.json()['onlinePresence']}==${bool[0]}   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp1}=   Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
    
    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

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
    

    ${resp}=  Get Account Payment Settings
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

    ${min_pre}=   Random Int   min=40   max=50
    ${Tot}=   Random Int   min=100   max=300
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${pre_float}=  twodigitfloat  ${min_pre}
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot}   ${Tot1}

    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration1}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${Tot}  ${bool[1]}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid1}  ${resp.json()}

    ${resp}=  Auto Invoice Generation For Service   ${p1_sid1}    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${p1_sid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}


    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE2} 
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration1}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${Tot}  ${bool[0]}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid2}  ${resp.json()}

    ${resp}=  Auto Invoice Generation For Service   ${p1_sid2}    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    # ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${cid1}=  get_id  ${CUSERNAME6}
    # Set Suite Variable   ${cid1}

    ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Suite Variable    ${primaryMobileNo}
    ${email}=    FakerLibrary.Email
    Set Suite Variable    ${email}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   12
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${primaryMobileNo}     ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid1}    ${resp.json()['providerConsumer']}


    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Output/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot}+${tax}
    ${totalamt}=  twodigitfloat  ${totalamt}
    ${balamount}=  Evaluate  ${totalamt}-${min_pre}
    ${balamount}=  Convert To Number  ${balamount}  2

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}


    sleep   02s

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre}  ${purpose[0]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${None}
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

    ${resp1}=  Get Bookings Invoices  ${cwid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code} 200



    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

   ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    sleep   02s

    ${resp}=   Get Payment Details By UUId   ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${id}   ${resp.json()[0]['id']} 

    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${min_pre}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid}

    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${min_pre}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid}

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...    billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${min_pre}   totalTaxAmount=${tax}
    Should Be Equal As Numbers  ${resp.json()['netRate']}   ${totalamt} 
    Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${balamount}

    ${resp}=  Get Individual Payment Records   ${id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}
    Should Be Equal As Strings  ${resp.json()['amount']}   ${min_pre}
    Should Be Equal As Strings  ${resp.json()['paymentMode']}  Mock
    Should Be Equal As Strings  ${resp.json()['paymentRefId']}   ${payref}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${pid}
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}    ${cwid}

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${balamount}  ${purpose[1]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${None}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Make payment Consumer Mock  ${balamount}  ${bool[1]}  ${cwid}  ${pid}  ${purpose[1]}  ${cid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    sleep   01s
    ${resp}=  Get Waitlist By Id  ${cwid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Apply Service To Finance-6

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
    # Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    # Set Suite Variable  ${CUR_DAY}
  
    ${SERVICE3}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${servicecharge}=  Convert To Number  ${servicecharge}  1 
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE3}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=  Auto Invoice Generation For Service   ${s_id}    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}


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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    # ${resp}=  Consumer Login  ${CUSERNAME32}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  ${jdconID}   ${resp.json()['id']}
    # Set Test Variable  ${fname}   ${resp.json()['firstName']}
    # Set Test Variable  ${lname}   ${resp.json()['lastName']}


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

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   12
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${primaryMobileNo}     ${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${account_id1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid1}    ${resp.json()['providerConsumer']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-3}
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}    location=${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
          
*** comment ***
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
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${service_duration}   ${status[0]}    ${btype}    ${bool[1]}    ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid}  ${resp.json()} 

    ${resp}=   Apply Service Level Discount   ${invoice_uid}   ${discountId}    ${discountprice}   ${EMPTY}  ${EMPTY}  ${sid}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${SERVICE_NOT}
















