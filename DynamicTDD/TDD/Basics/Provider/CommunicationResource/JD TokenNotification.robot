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

JD-TC-TokenNotification-1

    [Documentation]  signup a provider

# ...........signup a provider.......

    Create Directory   ${EXECDIR}/TDD/${ENVIRONMENT}data/
    Create Directory   ${EXECDIR}/data/${ENVIRONMENT}_varfiles/
    Log  ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py
    ${num}=  find_last  ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py

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
    Append To File  ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py  PUSERNAME${num}=${ph}${\n}
    
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
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}

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
    ${sername}=    FakerLibrary.firstname
   
    ${resp}=  Create Service    ${sername}  ${desc}  ${serdur}   ${status[0]}   ${btype}  ${bool[1]}   ${notifytype[2]}   ${EMPTY}   ${serprice}
    ...    ${bool[0]}   ${bool[0]}  maxBookingsAllowed=10
    Log   ${resp.content}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${serid1}  ${resp.json()}

#.....Create a queue......

    ${DAY1}=  db.get_date_by_timezone  ${tz}
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

#......create 5 provider consumers.....

    ${prov_cons_list}=  Create List
    Set Suite Variable   ${prov_cons_list}

    FOR   ${a}  IN RANGE   ${count}
    
        ${PH_Number}=  FakerLibrary.Numerify  %#####
        ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
        Log  ${PH_Number}
        Set Test Variable  ${CUSERPH}  555${PH_Number}
        Set Test Variable  ${CUSERPH${a}}  ${CUSERPH}
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${a}}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${firstname}=  FakerLibrary.first_name
            ${lastname}=  FakerLibrary.last_name
            Set Test Variable  ${pc_email}  ${firstname}${C_Email}.${test_mail}

            ${resp1}=  AddCustomer  ${CUSERPH${a}}   firstName=${firstname}   lastName=${lastname}  countryCode=${countryCodes[1]}  email=${pc_email}
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
            Append To List  ${prov_cons_list}  ${resp1.json()}
        ELSE
            Append To List  ${prov_cons_list}  ${resp.json()[${a}]['id']}
            Append To List  ${prov_cons_list}  ${resp.json()[${a}]['firstName']}
        END
    END

JD-TC-TokenNotification-2

    [Documentation]  take a walkin checkin for today without create any template and check default notifications.

    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  account-eq=${prov_cons_list[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
    Set Suite Variable  ${PCPHONENO}  ${resp.json()[0]['phoneNo']}

    ${desc}=   FakerLibrary.word
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Add To Waitlist  ${cid1}  ${serid1}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Waitlist EncodedId    ${wid}
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

    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get consumer communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-TokenNotification-3

    [Documentation]  cancel a walkin checkin for today without create any template and check default notifications.

    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  account-eq=${prov_cons_list[1]}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
    Set Test Variable  ${PCPHONENO}  ${resp.json()[0]['phoneNo']}

    ${desc}=   FakerLibrary.word
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Add To Waitlist  ${cid1}  ${serid1}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${walk_wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${walk_wid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Waitlist EncodedId    ${walk_wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid_encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${msg}=  Fakerlibrary.word
    ${resp}=  Waitlist Action Cancel  ${walk_wid}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

JD-TC-TokenNotification-4

    [Documentation]  create a template for checkin context and cancel the walkin checkin and verify the notifications.
    ...    context : checkin, trigger : token cancellation, channel : email, whatsapp, target : consumer, provider

    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Send Comm List
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${sendcomm_id1}         ${resp.json()[41]['id']}
    Set Test Variable   ${sendcomm_name1}       ${resp.json()[41]['name']}
    Set Test Variable   ${sendcomm_disname1}    ${resp.json()[41]['displayName']}
    Set Test Variable   ${sendcomm_context1}    ${resp.json()[41]['context']}
    Set Test Variable   ${sendcomm_vars1}       ${resp.json()[41]['variables']}

    ${resp}=  Get Dynamic Variable List By SendComm   ${sendcomm_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${cons_name}        ${resp.json()[0]['name']}
    Set Test Variable   ${book_enid}        ${resp.json()[15]['name']}
    Set Test Variable   ${book_date}        ${resp.json()[16]['name']}

    ${temp_name}=    FakerLibrary.word
    ${content}=    Create Dictionary  intro=${EMPTY}
    ${comm_chanl}=  Create List   ${CommChannel[1]}   ${CommChannel[2]}
    ${comm_target}=  Create List   ${CommTarget[0]}  ${CommTarget[1]}
    ${sendcomm_list}=  Create List   ${sendcomm_id1}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}   ${comm_chanl} 
    ...    sendComm=${sendcomm_list}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${temp_id1}  ${resp.content}

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                             ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                          ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                               ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                           ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}                        ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}                      ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                            ${comm_target}
    Should Be Equal As Strings  ${resp.json()['sendComm']}                              ${sendcomm_list}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['id']}              ${sendcomm_id1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['name']}            ${sendcomm_name1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['displayName']}     ${sendcomm_disname1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['context']}         ${sendcomm_context1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['variables']}       ${sendcomm_vars1} 
    Should Be Equal As Strings  ${resp.json()['status']}                                ${VarStatus[1]} 

    ${booking_details}=  Catenate   SEPARATOR=\n
    ...                   'Name': [${cons_name}],
    ...                   'Booking Reference Number': [${book_enid}],
    ...                   'Check-in Date': [${book_date}],
    ...                   'Check-out Date': [${book_date}]
    ${booking_details}=  Create Dictionary   Booking Details=${booking_details}
    ${content_msg}=  Set Variable    I hope this message finds you well. 
    ${tempheader_sub}=    Set Variable    Cancellation of Booking
    ${salutation}=      Set Variable  Dear [${cons_name}] 
    ${signature}=   FakerLibrary.hostname
    ${salutation}=     Set Variable  ${salutation}.

    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}  note=${EMPTY}
    ${temp_footer}=    Create Dictionary  closing=${EMPTY}   signature=${signature}  

    ${content1}=    Create Dictionary  intro=${content_msg}  details=${booking_details}   cts=${EMPTY}  

    ${resp}=  Update Template  ${temp_id1}  content=${content1}  templateHeader=${temp_header}  footer=${temp_footer}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                 ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}            ${content_msg}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                  ${comm_target}
    Should Be Equal As Strings  ${resp.json()['sendComm']}                              ${sendcomm_list}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['id']}              ${sendcomm_id1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['name']}            ${sendcomm_name1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['displayName']}     ${sendcomm_disname1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['context']}         ${sendcomm_context1}
    Should Be Equal As Strings  ${resp.json()['sendCommDetails'][0]['variables']}       ${sendcomm_vars1}  
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[1]} 

    ${resp}=  Update Template Status   ${temp_id1}  ${VarStatus[0]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Template By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountId']}                   ${account_id} 
    Should Be Equal As Strings  ${resp.json()['templateName']}                ${temp_name}
    Should Be Equal As Strings  ${resp.json()['context']}                     ${VariableContext[0]} 
    Should Be Equal As Strings  ${resp.json()['commChannel']}                 ${comm_chanl} 
    Should Be Equal As Strings  ${resp.json()['templateFormat']}              ${templateFormat[0]}
    Should Be Equal As Strings  ${resp.json()['content']['intro']}            ${content_msg}
    Should Be Equal As Strings  ${resp.json()['commTarget']}                  ${comm_target} 
    Should Be Equal As Strings  ${resp.json()['status']}                      ${VarStatus[0]} 

    ${resp}=  Get Custom Template Preview By Id   ${temp_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${msg}=  Fakerlibrary.word
    ${resp}=  Waitlist Action Cancel  ${wid}  ${waitlist_cancl_reasn[4]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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
  
JD-TC-TokenNotification-5

    [Documentation]  create a template for checkin context and take a walkin checkin and verify the notifications.
    ...    context : checkin, trigger : token confirmation, channel : email, whatsapp, target : provider

    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Send Comm List
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${sendcomm_id1}         ${resp.json()[40]['id']}
    Set Test Variable   ${sendcomm_name1}       ${resp.json()[40]['name']}
    Set Test Variable   ${sendcomm_disname1}    ${resp.json()[40]['displayName']}
    Set Test Variable   ${sendcomm_context1}    ${resp.json()[40]['context']}
    Set Test Variable   ${sendcomm_vars1}       ${resp.json()[40]['variables']}

    ${resp}=  Get Dynamic Variable List By SendComm   ${sendcomm_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${cons_name}        ${resp.json()[0]['name']}
    Set Suite Variable   ${book_enid}        ${resp.json()[15]['name']}
    Set Suite Variable   ${book_date}        ${resp.json()[16]['name']}

    ${temp_name}=    FakerLibrary.word
    ${booking_details}=  Catenate   SEPARATOR=\n
    ...                   'Name': [${cons_name}],
    ...                   'Booking Reference Number': [${book_enid}],
    ...                   'Check-in Date': [${book_date}],
    ...                   'Check-out Date': [${book_date}]
    ${booking_details}=  Create Dictionary   Booking Details=${booking_details}
    ${content_msg}=  Set Variable    I hope this message finds you well. 
    ${tempheader_sub}=    Set Variable    Confirmation of Booking
    ${salutation}=      Set Variable  Dear [${cons_name}] 
    ${signature}=   FakerLibrary.hostname
    ${salutation}=     Set Variable  ${salutation}.

    ${temp_header}=    Create Dictionary  subject=${tempheader_sub}   salutation=${salutation}  note=${EMPTY}
    ${temp_footer}=    Create Dictionary  closing=${EMPTY}   signature=${signature}  

    ${content}=    Create Dictionary  intro=${content_msg}  details=${booking_details}   cts=${EMPTY}  
    ${comm_chanl}=  Create List   ${CommChannel[1]}   ${CommChannel[2]}
    ${comm_target}=  Create List    ${CommTarget[1]}
    ${sendcomm_list}=  Create List   ${sendcomm_id1}  
    
    ${resp}=  Create Template   ${temp_name}  ${content}  ${templateFormat[0]}  ${VariableContext[0]}  ${comm_target}   ${comm_chanl} 
    ...    sendComm=${sendcomm_list}  templateHeader=${temp_header}  footer=${temp_footer}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${temp_id2}  ${resp.content}

    ${resp}=  GetCustomer  account-eq=${prov_cons_list[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
    Set Test Variable  ${PCPHONENO}  ${resp.json()[0]['phoneNo']}

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

JD-TC-TokenNotification-6

    [Documentation]  update the template for checkin context and take a walkin checkin and verify the notifications.
    ...    context : checkin, trigger : token confirmation, channel : email, whatsapp, target : provider, consumer

    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${comm_target1}=  Create List    ${CommTarget[1]}  ${CommTarget[0]}
   
    ${resp}=  Update Template   ${temp_id2}  CommTarget=${comm_target1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  account-eq=${prov_cons_list[2]}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
    Set Test Variable  ${PCPHONENO}  ${resp.json()[0]['phoneNo']}

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

JD-TC-TokenNotification-7

    [Documentation]  Inactive the template for checkin context and take a walkin checkin and verify the notifications.
    ...    context : checkin, trigger : token confirmation, channel : email, whatsapp, target : provider, consumer, status : inactive

    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Template Status   ${temp_id2}  ${VarStatus[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Template By Id   ${temp_id2}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['status']}     ${VarStatus[1]} 

    ${resp}=  GetCustomer  account-eq=${prov_cons_list[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
    Set Test Variable  ${PCPHONENO}  ${resp.json()[0]['phoneNo']}

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
    
JD-TC-TokenNotification-8

    [Documentation]  active the inactive template for checkin context and take a walkin checkin(future) and verify the notifications.
    ...    context : checkin, trigger : token confirmation, channel : email, whatsapp, target : provider, consumer, status : active

    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Template Status   ${temp_id2}  ${VarStatus[0]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Template By Id   ${temp_id2}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['status']}     ${VarStatus[0]} 

    ${resp}=  GetCustomer  account-eq=${prov_cons_list[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
    Set Test Variable  ${PCPHONENO}  ${resp.json()[0]['phoneNo']}

    ${desc}=   FakerLibrary.word
    ${DAY1}=  db.add_timezone_date  ${tz}  2
    ${resp}=  Add To Waitlist  ${cid1}  ${serid1}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid3}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
JD-TC-TokenNotification-9

    [Documentation]  update the template for checkin context with change in content and take an online checkin(today) and verify the notifications.
    ...    context : checkin, trigger : token confirmation, channel : email, whatsapp, target : provider, consumer, status : active

    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${booking_details1}=  Catenate   SEPARATOR=\n
    ...                   'Name': [${cons_name}],
    ...                   'Booking Reference Number': [${book_enid}],
    ...                   'Check-in Date': [${book_date}]
    ${booking_details1}=  Create Dictionary   Booking Details=${booking_details1}
    ${content1}=    Create Dictionary  details=${booking_details1}   
    
    ${resp}=  Update Template   ${temp_id2}  content=${content1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  account-eq=${prov_cons_list[1]}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
    Set Test Variable  ${PCPHONENO}  ${resp.json()[0]['phoneNo']}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${cnote}=   FakerLibrary.word
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Add To Waitlist Consumers  ${account_id}  ${q_id}  ${DAY1}  ${serid1}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${online_wid1}  ${wid[0]}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
JD-TC-TokenNotification-10

    [Documentation]  take an online checkin(today) for a user and verify the notifications.
    ...    context : checkin, trigger : token confirmation, channel : email, whatsapp, target : provider, consumer, status : active

    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  View Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  Get Departments
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    #....user creation...........

    ${resp}=  Get User
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            Set Test Variable   ${u_id1}        ${resp.json()[${i}]['id']}
            IF   not '${user_phone}' == '${ph}'
                BREAK
            END
        END
    END

    ${u_id1}=  Create Sample User
    Set Test Variable   ${u_id1}
   
    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}
    Set Test Variable  ${userf_name}  ${resp.json()['firstName']}
    Set Test Variable  ${userl_name}  ${resp.json()['lastName']}

    ${resp}=  GetCustomer  account-eq=${prov_cons_list[3]}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
    Set Test Variable  ${PCPHONENO}  ${resp.json()[0]['phoneNo']}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${cnote}=   FakerLibrary.word
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Add To Waitlist Consumers  ${u_id1}  ${q_id}  ${DAY1}  ${serid1}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${online_wid1}  ${wid[0]}

    ${resp}=  Get consumer communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200