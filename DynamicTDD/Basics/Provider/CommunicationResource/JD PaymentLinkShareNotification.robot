*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Communication
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           random
Library           /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***

${PSUSERNAME}          5550004756
${PASSWORD}            Jaldee12
${test_mail}           test@jaldee.com
${count}               ${5}
${email_id}            reshma.test@jaldee.com
${NEW_PASSWORD}        Jaldee123
${self}                0

*** Test Cases ***

JD-TC-PaymentLinkShareNotification-1

    [Documentation]  signup a provider

# ...........signup a provider.......

    Create Directory   ${EXECDIR}/TDD/${ENVIRONMENT}data/
    Create Directory   ${EXECDIR}/TDD/${ENVIRONMENT}_varfiles/
    Log  ${EXECDIR}/TDD/${ENVIRONMENT}_varfiles/providers.py
    ${num}=  find_last  ${EXECDIR}/TDD/${ENVIRONMENT}_varfiles/providers.py

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${ph}  555${PH_Number}

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${ph1}  555${PH_Number}

    ${ph1}=  Evaluate  ${ph}+1000000000
    ${ph2}=  Evaluate  ${ph}+2000000000
    ${licpkgid}  ${licpkgname}=  get_highest_license_pkg
    ${corp_resp}=   get_iscorp_subdomains  1

    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dom_len}=  Get Length  ${resp.json()}
    ${dom}=  random.randint  ${0}  ${dom_len-1}
    ${sdom_len}=  Get Length  ${resp.json()[${dom}]['subDomains']}
    Set Test Variable  ${domain}  ${resp.json()[${dom}]['domain']}
    Log   ${domain}
    
    FOR  ${subindex}  IN RANGE  ${sdom_len}
        ${sdom}=  random.randint  ${0}  ${sdom_len-1}
        Set Test Variable  ${subdomain}  ${resp.json()[${dom}]['subDomains'][${subindex}]['subDomain']}
        ${is_corp}=  check_is_corp  ${subdomain}
        Exit For Loop If  '${is_corp}' == 'False'
    END
    Log   ${subdomain}

    ${fname}=  FakerLibrary.name
    ${lname}=  FakerLibrary.lastname
    ${resp}=  Account SignUp  ${fname}  ${lname}  ${None}  ${domain}  ${subdomain}  ${ph}  ${licpkgid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=  Account Activation  ${ph}   ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${ph}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  03s

    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pro_id}  ${decrypted_data['id']}

    Append To File  ${EXECDIR}/TDD/${ENVIRONMENT}data/${ENVIRONMENT}phnumbers.txt  ${ph} - ${PASSWORD}${\n}
    Append To File  ${EXECDIR}/TDD/${ENVIRONMENT}_varfiles/providers.py  PUSERNAME${num}=${ph}${\n}
    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${ph}.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${Time}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.add_timezone_time  ${tz}  0  15  
    ${eTime}=  db.add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
    Log  ${fields.content}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Features  ${subdomain}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Update Service Provider With Emailid   ${pro_id}   ${fname}   ${fname}   ${Genderlist[0]}  ${EMPTY}  ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Waitlist
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${checkin_emails}=  Create List   ${email_id}
    ${push_msg_nos}=  Create Dictionary   number=${ph}   countryCode=${countryCodes[1]}
    ${push_msg_nos}=  Create List   ${push_msg_nos}

    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[0]}  ${EMPTY_List}  ${checkin_emails}  ${push_msg_nos}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePresence']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${bool[1]}  ${EMPTY}  ${EMPTY}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

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

#........create location......

    ${resp}=    Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Suite Variable   ${locId}

        ${resp}=   Get Location ById  ${locId}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

#....create service with pre payment.....

    ${desc}=  FakerLibrary.sentence
    ${prepay_serdur}=   Random Int   min=5   max=10
    ${prepay_price}=   Random Int   min=10   max=50
    ${prepay_price}=  Convert To Number  ${prepay_price}  1
    ${prepay_serprice}=   Random Int   min=100   max=500
    ${prepay_serprice}=  Convert To Number  ${prepay_serprice}  1
    ${prepay_sername}=    FakerLibrary.firstname
   
    ${resp}=  Create Service    ${prepay_sername}  ${desc}  ${prepay_serdur}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${prepay_price}   ${prepay_serprice}
    ...    ${bool[1]}   ${bool[0]}   serviceCategory=${serviceCategory[1]}  maxBookingsAllowed=10
    Log   ${resp.content}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${prepay_serid1}  ${resp.json()}

    ${desc}=  FakerLibrary.sentence
    ${serdur}=   Random Int   min=5   max=10
    ${serprice}=   Random Int   min=100   max=500
    ${serprice}=  Convert To Number  ${serprice}  1
    Set Suite Variable  ${serprice}
    ${sername}=    FakerLibrary.firstname
    Set Suite Variable  ${sername}
   
    ${resp}=  Create Service    ${sername}  ${desc}  ${serdur}   ${status[0]}   ${btype}  ${bool[1]}   ${notifytype[2]}   ${EMPTY}   ${serprice}
    ...    ${bool[0]}   ${bool[0]}  maxBookingsAllowed=10
    Log   ${resp.content}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${serid1}  ${resp.json()}

    #.........Auto Invoice Generation...............

    ${resp}=  Auto Invoice Generation For Service   ${serid1}    ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${serid1}
    Log   ${resp.content}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}

    #.....Create a queue......

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY2}=  db.add_timezone_date  ${tz}  10
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  3  30  
    ${parallel}=  Random Int   min=1   max=2
    ${capacity}=  Random Int  min=20   max=40
    ${queue1}=    FakerLibrary.Word
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${locId}  ${prepay_serid1}  ${serid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    #............provider consumer creation..........

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PCPHONENO}  555${PH_Number}

    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${pc_emailid1}  ${firstname}${C_Email}.${test_mail}

    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${firstname}   lastName=${lastname}  countryCode=${countryCodes[1]}  email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=  GetCustomer  phoneNo-eq=${PCPHONENO}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()[0]['id']}
    
    ${resp}=    Customer Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-PaymentLinkShareNotification-2

    [Documentation]  take a walkin checkin for today without create any template and check default notifications.

    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${desc}=   FakerLibrary.word
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Add To Waitlist  ${cid1}  ${serid1}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Waitlist EncodedId    ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid_encId}=  Set Variable   ${resp.json()}
    Set Suite Variable  ${wid_encId}

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get consumer communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Customer Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  2s
    ${resp}=  Get Bookings Invoices  ${wid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${invoice_uid}    ${resp.json()[0]['invoiceUid']}

    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                                        ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}                                     ${CategoryName[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}                                      ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumerId']}                               ${cid1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumerData']['phoneNos'][0]['number']}    ${PCPHONENO}
    Should Be Equal As Strings   ${resp.json()[0]['ynwUuid']}                                         ${wid1}
    Should Be Equal As Strings   ${resp.json()[0]['amountPaid']}                                      0.0
    Should Be Equal As Strings   ${resp.json()[0]['amountDue']}                                       ${serprice}
    Should Be Equal As Strings   ${resp.json()[0]['amountTotal']}                                     ${serprice}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}                      ${serid1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}                    ${sername}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}                       1.0
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['taxable']}                        ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}                     ${serprice}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}                        ${serprice}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceCategory']}                ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['assigneeUsers']}                  ${empty_list}
   
    ${resp}=  Generate Link For Invoice  ${invoice_uid}   ${PCPHONENO}   ${pc_emailid1}    ${boolean[1]}    ${boolean[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-PaymentLinkShareNotification-3

    [Documentation]  take a walkin appointment for today without create any template and check default notifications.

    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY2}=  db.add_timezone_date  ${tz}  10
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${empty_list}=   Create List

    ${list}=  Create List  1  2  3  4  5  6  7
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${locId}  ${duration}  ${bool1}   ${serid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${serid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    ${slots}=  Create List
    FOR   ${i}  IN RANGE   ${no_of_slots}
        ${available_slots_cnt}=  Set Variable  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
        FOR   ${j}  IN RANGE   ${available_slots_cnt}
            Append To List  ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${slots_len}=  Get Length  ${slots}

    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slots[0]}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${serid1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get From Dictionary  ${resp.json()}  ${firstname}
    Set Suite Variable  ${walkin_appt1}  ${apptid}

    ${resp}=  Get Appointment EncodedID   ${walkin_appt1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${encId1}  ${resp.json()}

    ${resp}=  Get Appointment By Id   ${walkin_appt1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}                ${walkin_appt1}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId1}

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get consumer communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Customer Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-PaymentLinkShareNotification-4

    [Documentation]  create a template and check the notifications.
    ...    context : Account, trigger : Share Payment Link, channel : email, whatsapp, target : consumer, provider

    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #....template creation........

    ${resp}=  Get Send Comm List
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${sendcomm_id1}         ${resp.json()[25]['id']}
    Set Test Variable   ${sendcomm_name1}       ${resp.json()[25]['name']}
    Set Test Variable   ${sendcomm_disname1}    ${resp.json()[25]['displayName']}
    Set Test Variable   ${sendcomm_context1}    ${resp.json()[25]['context']}
    Set Test Variable   ${sendcomm_vars1}       ${resp.json()[25]['variables']}

    ${resp}=  Get Dynamic Variable List By SendComm   ${sendcomm_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${cons_name}        ${resp.json()[0]['name']}
    Set Suite Variable   ${bus_name}         ${resp.json()[1]['name']}
    Set Suite Variable   ${prov_name}        ${resp.json()[2]['name']}
    Set Suite Variable   ${serv_name}        ${resp.json()[3]['name']}
    Set Suite Variable   ${pay_link}         ${resp.json()[4]['name']}

    ${temp_name}=    FakerLibrary.word
    ${invoice_details}=  Catenate   SEPARATOR=\n
    ...                   'Service Provider': [${prov_name}]
    ...                   'Consumer Name': [${cons_name}],
    ...                   'Booking Service Name': [${serv_name}],
    ...                   'Payment Link': [${pay_link}],
    ${invoice_details}=   Create Dictionary    Invoice details=${invoice_details} 
    ${content_msg}=        Set Variable    I hope this message finds you well. 
    ${tempheader_sub}=     Set Variable    Payment Link
    ${salutation}=         Set Variable  Dear [${cons_name}] 
    ${signature}=          Set variable  [${bus_name}]
   
    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}  note=${EMPTY}
    ${temp_footer}=    Create Dictionary  closing=${EMPTY}   signature=${signature}  

    ${content}=    Create Dictionary  intro=${content_msg}  details=${invoice_details}   cts=${EMPTY}  
    ${comm_chanl}=  Create List   ${CommChannel[1]}   ${CommChannel[2]}
    ${comm_target}=  Create List    ${CommTarget[0]}  ${CommTarget[1]}
    ${sendcomm_list}=  Create List   ${sendcomm_id1}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}   ${comm_chanl} 
    ...    sendComm=${sendcomm_list}  templateHeader=${temp_header}  footer=${temp_footer}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${temp_id1}  ${resp.content}

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${desc}=   FakerLibrary.word
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Add To Waitlist  ${cid1}  ${serid1}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid2}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Waitlist EncodedId    ${wid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid_encId1}=  Set Variable   ${resp.json()}
    Set Suite Variable  ${wid_encId1}

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get consumer communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Customer Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bookings Invoices  ${wid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${invoice_uid1}    ${resp.json()[0]['invoiceUid']}

    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                                        ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}                                     ${CategoryName[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}                                      ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumerId']}                               ${cid1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumerData']['phoneNos'][0]['number']}    ${PCPHONENO}
    Should Be Equal As Strings   ${resp.json()[0]['ynwUuid']}                                         ${wid2}
    Should Be Equal As Strings   ${resp.json()[0]['amountPaid']}                                      0.0
    Should Be Equal As Strings   ${resp.json()[0]['amountDue']}                                       ${serprice}
    Should Be Equal As Strings   ${resp.json()[0]['amountTotal']}                                     ${serprice}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}                      ${serid1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}                    ${sername}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}                       1.0
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['taxable']}                        ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}                     ${serprice}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}                        ${serprice}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceCategory']}                ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['assigneeUsers']}                  ${empty_list}
   
    ${resp}=  Generate Link For Invoice  ${invoice_uid1}   ${PCPHONENO}   ${pc_emailid1}    ${boolean[1]}    ${boolean[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-PaymentLinkShareNotification-5

    [Documentation]  take a walkin appointment for today with comm template and check the notifications.

    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${serid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    ${slots}=  Create List
    FOR   ${i}  IN RANGE   ${no_of_slots}
        ${available_slots_cnt}=  Set Variable  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
        FOR   ${j}  IN RANGE   ${available_slots_cnt}
            Append To List  ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${slots_len}=  Get Length  ${slots}

    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slots[0]}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${serid1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get From Dictionary  ${resp.json()}  ${firstname}
    Set Suite Variable  ${walkin_appt2}  ${apptid}

    ${resp}=  Get Appointment EncodedID   ${walkin_appt2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${encId2}  ${resp.json()}

    ${resp}=  Get Appointment By Id   ${walkin_appt2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}                ${walkin_appt2}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId2}

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get consumer communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Customer Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bookings Invoices  ${walkin_appt2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${invoice_uid1}    ${resp.json()[0]['invoiceUid']}

    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                                        ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}                                     ${CategoryName[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}                                      ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumerId']}                               ${cid1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumerData']['phoneNos'][0]['number']}    ${PCPHONENO}
    Should Be Equal As Strings   ${resp.json()[0]['ynwUuid']}                                         ${walkin_appt2}
    Should Be Equal As Strings   ${resp.json()[0]['amountPaid']}                                      0.0
    Should Be Equal As Strings   ${resp.json()[0]['amountDue']}                                       ${serprice}
    Should Be Equal As Strings   ${resp.json()[0]['amountTotal']}                                     ${serprice}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}                      ${serid1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}                    ${sername}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}                       1.0
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['taxable']}                        ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}                     ${serprice}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}                        ${serprice}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceCategory']}                ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['assigneeUsers']}                  ${empty_list}
   
    ${resp}=  Generate Link For Invoice  ${invoice_uid1}   ${PCPHONENO}   ${pc_emailid1}    ${boolean[1]}    ${boolean[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
