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

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pro_id}  ${decrypted_data['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    
    ${fname}=  FakerLibrary.name
    ${lname}=  FakerLibrary.lastname
    ${resp}=  Update Service Provider With Emailid   ${pro_id}   ${fname}   ${fname}   ${Genderlist[0]}  ${EMPTY}  ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${checkin_emails}=  Create List   ${email_id}
    ${push_msg_nos}=  Create Dictionary   number=${HLPUSERNAME19}   countryCode=${countryCodes[1]}
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

JD-TC-TokenNotification-2

    [Documentation]  take a walkin checkin for today without create any template and check default notifications.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get consumer communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-TokenNotification-3

    [Documentation]  create a template for checkin context and take a walkin checkin and verify the notifications.
    ...    context : checkin, trigger : token confirmation, channel : email, whatsapp, target : provider

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
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

JD-TC-TokenNotification-4

    [Documentation]  cancel a walkin checkin for today without create any template and check default notifications.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

JD-TC-TokenNotification-5

    [Documentation]  create a template for checkin context and cancel the walkin checkin and verify the notifications.
    ...    context : checkin, trigger : token cancellation, channel : email, whatsapp, target : consumer, provider

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
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
  














