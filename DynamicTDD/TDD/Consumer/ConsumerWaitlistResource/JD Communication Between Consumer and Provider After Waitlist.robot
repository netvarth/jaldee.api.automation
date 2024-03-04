*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords     Delete All Sessions
...               AND           Remove File  cookies.txt
Force Tags        Waitlist Communication
Library           Collections
Library           String
Library           json
Library           DateTime
Library           /ebs/TDD/db.py
Library           /ebs/TDD/Imageupload.py
Library           FakerLibrary
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${jpgfile}     /ebs/TDD/uploadimage.jpg
${pngfile}     /ebs/TDD/upload.png
${pdffile}     /ebs/TDD/sample.pdf
${self}        0
${service_duration}   5  
${parallel}            1

*** Test Cases ***

JD-TC-Communication Between Consumer and Provider-1
	[Documentation]   Communication Between Consumer and Provider after waitlist operation by provider side
	${PUSERPH0}=  Evaluate  ${PUSERNAME}+100100601
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
    Set Suite Variable   ${PUSERPH0}
    
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_location  ${PUSERPH0}   AND   clear_service   ${PUSERPH0}  AND  clear waitlist   ${PUSERPH0}
    clear_consumer_msgs  ${CUSERNAME0}
    clear_provider_msgs  ${PUSERPH0}

    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}
        ${sublen}=  Get Length  ${domresp.json()[${pos}]['subDomains']}
        Set Test Variable  ${dpos}   ${pos}
        Set Test Variable  ${d1}  ${domresp.json()[${pos}]['domain']}
    END

    FOR  ${pos}  IN RANGE  ${sublen}
        Set Test Variable  ${sd1}  ${domresp.json()[${dpos}]['subDomains'][${pos}]['subDomain']}
    END

    ${pkg_id}=   get_highest_license_pkg

    ${PUSERPH_SECOND}=  Evaluate  ${PUSERPH0}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERPH0}   ${pkg_id[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${PUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    # Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pro_id}  ${decrypted_data['id']}
    # Set Test Variable  ${pro_id}  ${resp.json()['id']}
    
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+100100602
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH1}${\n}
    
    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+100100603
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH2}${\n}
    
    ${PUSERMAIL0}=   Set Variable  ${P_Email}ph601.${test_mail}
    ${views}=  Evaluate  random.choice($Views)  random
    Log   ${views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL0}  ${views}
    ${list}=  Create List  1  2  3  4  5  6  7
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
    ${DAY}=  db.get_date_by_timezone  ${tz}
    # ${sTime}=  db.get_time_by_timezone   ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  0  15  
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep   01s

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    Set Test Variable  ${email_id}  ${P_Email}${PUSERPH0}.${test_mail}

    ${resp}=  Update Email   ${pro_id}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    # ${resp}=  pyproviderlogin  ${PUSERPH0}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200      
    # @{resp}=  uploadLogoImages
    # Should Be Equal As Strings  ${resp[1]}  200
    # ${resp}=  Get GalleryOrlogo image  logo
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['prefix']}  logo

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
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

    ${resp}=  Get Consumer Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${pid0}=  get_acc_id  ${PUSERPH0}
    
    ${resp}=  AddCustomer  ${CUSERNAME0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cons_id}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_l1}  ${resp.json()}
    
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_s1}  ${resp.json()}

    ${P2SERVICE2}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P2SERVICE2}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_s2}  ${resp.json()}

    ${sTime2}=  add_timezone_time  ${tz}  0  30  
    ${eTime2}=  add_timezone_time  ${tz}  0  45  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}   ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_q1}  ${resp.json()}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cons_id}  ${p1_s1}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${cons_id}   location=${p1_l1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=   Get Consumer Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${cid}  ${resp.json()['id']}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME0}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Imageupload.ConsWLCommunication   ${cookie}  ${wid}  ${pid0}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpgfile}
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}   ${cid}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}   ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}   0
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}    ${pid0}
    
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}   ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}  0
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}    ${pid0}

JD-TC-Communication Between Consumer and Provider-2
    [Documentation]   Communication Between Consumer and Provider after waitlist operation by consumer side  
    clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    clear_consumer_msgs  ${CUSERNAME3}
    clear_provider_msgs  ${PUSERPH0}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pro_id}  ${decrypted_data['id']}
    # Set Test Variable  ${pro_id}  ${resp.json()['id']}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s2}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[0]['name']}
    Set Test Variable   ${p1_s1}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[1]['name']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}

    ${resp}=  Get Queues
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_q1}   ${resp.json()[0]['id']}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  onlineCheckIns=True

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
       
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}  location=${p1_l1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME3}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Imageupload.ConsWLCommunication   ${cookie}  ${wid}  ${pid0}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid3}  ${resp.json()[0]['jaldeeConsumer']}

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable   ${cid3}  ${resp.json()['id']}   
    
    sleep   3s
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}   ${cid3}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}   ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}   0
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}    ${pid0}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}  ${cid3}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}  ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}   0
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}    ${pid0}

JD-TC-Communication Between Consumer and Provider-3
    [Documentation]   Communication Between Consumer and Provider after waitlist cancelled by consumer

    clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    clear_consumer_msgs  ${CUSERNAME28}
    clear_consumer_msgs  ${CUSERNAME3}
    clear_provider_msgs  ${PUSERPH0}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pro_id}  ${decrypted_data['id']}
    # Set Test Variable  ${pro_id}  ${resp.json()['id']}

    ${resp}=  Get Consumer Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    # ${msg1}=  FakerLibrary.text 
    # ${person_ahead1}=   Random Int  min=0   max=0
    # ${resp}=  Update Consumer Notification Settings  ${NotificationResourceType[0]}  ${EventType[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${msg1}  ${person_ahead1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}
    Set Test Variable   ${p1_s2}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[1]['name']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}

    ${resp}=  Get Queues
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_q1}   ${resp.json()[0]['id']}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  onlineCheckIns=True


    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cname}  ${resp.json()['userName']}
    ${cid1}=  get_id  ${CUSERNAME28}

    ${cnote}=   FakerLibrary.word
    ${DAY1}=   db.add_timezone_date  ${tz}   2
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY1}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Cancel Waitlist  ${wid1}  ${pid0}
    Should Be Equal As Strings  ${resp.status_code}  200

    # sleep   3s

    ${resp}=  Get consumer Waitlist By Id  ${wid1}  ${pid0}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME28}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Imageupload.ConsWLCommunication   ${cookie}  ${wid1}  ${pid0}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${date} =	Convert Date	${DAY}	result_format=%d-%m-%Y
    # ${defaultmsg}=  Replace String  ${consumerCancel}  [username]   ${cname} 
    # ${defaultmsg}=  Replace String  ${defaultmsg}  [service]  ${P1SERVICE1}
    # ${defaultmsg}=  Replace String  ${defaultmsg}  [provider name]  ${bsname}
    # # ${defaultmsg}=  Replace String  ${defaultmsg}  [service]  ${P1SERVICE1}
    # ${defaultmsg}=  Replace String  ${defaultmsg}  [date]  ${date}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME28}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid1}  ${resp.json()[0]['jaldeeConsumer']}

    ${resp}=   Get Waitlist EncodedId    ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${W_uuid1}   ${resp.json()}
    
    Set Suite Variable  ${W_encId}  ${resp.json()}

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmAppt_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 
    ${defconsumerCancel_msg}=  Set Variable   ${resp.json()['cancellationMessages']['Consumer_APP']}
    
    ${provider_msg}=   Set Variable  Message from [providerName] : [message] 
    ${provider_msg}=   Replace String  ${provider_msg}  [providerName]   ${bsname}
    ${provider_msg}=   Replace String  ${provider_msg}  [message]        other

    ${bookingid}=  Format String  ${bookinglink}  ${W_encId}  ${W_encId}
    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${cname}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${W_encId}

    ${defaultmsg}=  Replace String  ${defconsumerCancel_msg}  [consumer]   ${cname}
    ${defconsumerCancel_msg}=  Replace String  ${defaultmsg}  [bookingId]   ${W_encId}   
    ${defconsumerCancel_msg}=  Replace String  ${defconsumerCancel_msg}  [providerMessage]   ${provider_msg}

    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    sleep   2s

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   0
    Should Be Equal As Strings  ${resp.json()[0]['msg']}   ${defconfirm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}   ${cid1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${pid0}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}   0
    Variable Should Exist       ${resp.json()[1]['msg']}    ${defconsumerCancel_msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}   ${cid1}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}    ${pid0}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}  0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}  ${wid1}
    Variable Should Exist       ${resp.json()[1]['msg']}  ${defconsumerCancel_msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}  ${cid1}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}    ${pid0}

JD-TC-Communication Between Consumer and Provider-4
    [Documentation]   Consumer attaching a jpg file with communication for provider.
    clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME28}
    clear_consumer_msgs  ${CUSERNAME28}
    clear_provider_msgs  ${PUSERPH0}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pro_id}  ${decrypted_data['id']}
    # Set Test Variable  ${pro_id}  ${resp.json()['id']}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}
    Set Test Variable   ${p1_s2}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[1]['name']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}

    ${resp}=  Get Queues
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_q1}   ${resp.json()[0]['id']}

    ${resp}=  Get Consumer Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  onlineCheckIns=True

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
      
    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME28}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Imageupload.ConsWLCommunication   ${cookie}  ${wid1}  ${pid0}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpgfile}
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}   ${cid}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}   ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}   0
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}    ${pid0}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}  ${wid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}   ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}  0
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}    ${pid0}

JD-TC-Communication Between Consumer and Provider-5
    [Documentation]   Consumer attaching a png file with communication for provider.
    clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME28}
    clear_consumer_msgs  ${CUSERNAME28}
    clear_provider_msgs  ${PUSERPH0}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pro_id}  ${decrypted_data['id']}
    # Set Test Variable  ${pro_id}  ${resp.json()['id']}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}
    Set Test Variable   ${p1_s2}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[1]['name']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}

    ${resp}=  Get Queues
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_q1}   ${resp.json()[0]['id']}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  onlineCheckIns=True

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME28}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Imageupload.ConsWLCommunication   ${cookie}  ${wid1}  ${pid0}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${pngfile}
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}   ${cid}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}   ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}   0
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}    ${pid0}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}  ${wid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}   ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}  0
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}    ${pid0}

JD-TC-Communication Between Consumer and Provider-6
    [Documentation]   Consumer sending communication to provider without caption
    clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME28}
    clear_consumer_msgs  ${CUSERNAME28}
    clear_provider_msgs  ${PUSERPH0}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pro_id}  ${decrypted_data['id']}
    # Set Suite Variable  ${pro_id}  ${resp.json()['id']}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}
    Set Test Variable   ${p1_s2}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[1]['name']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}

    ${resp}=  Get Queues
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_q1}   ${resp.json()[0]['id']}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  onlineCheckIns=True

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME28}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Imageupload.ConsWLCommunication   ${cookie}  ${wid1}  ${pid0}  ${msg}  ${messageType[0]}  ${EMPTY}  ${EMPTY} 
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}   ${cid}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}   ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}   0
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}    ${pid0}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}  ${wid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}   ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}  0
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}    ${pid0}

JD-TC-Communication Between Consumer and Provider-7
    [Documentation]   Consumer sending communication to provider without message body
    clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME28}
    clear_consumer_msgs  ${CUSERNAME28}
    clear_provider_msgs  ${PUSERPH0}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pro_id}  ${decrypted_data['id']}
    # Set Test Variable  ${pro_id}  ${resp.json()['id']}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}
    Set Test Variable   ${p1_s2}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[1]['name']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}

    ${resp}=  Get Queues
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_q1}   ${resp.json()[0]['id']}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  onlineCheckIns=True

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME28}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Imageupload.ConsWLCommunication   ${cookie}  ${wid1}  ${pid0}  ${EMPTY}  ${messageType[0]}  ${caption}  ${EMPTY} 
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}   ${cid}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}   ${EMPTY}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}   0
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}    ${pid0}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}  ${wid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}  ${EMPTY}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}  0
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}    ${pid0}

JD-TC-Communication Between Consumer and Provider-8
    [Documentation]   Consumer sends multiple files to provider in waitlist communication 

    clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME3}
    clear_consumer_msgs  ${CUSERNAME3}
    clear_provider_msgs  ${PUSERPH0}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pro_id}  ${decrypted_data['id']}
    # Set Test Variable  ${pro_id}  ${resp.json()['id']}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}
    Set Test Variable   ${p1_s2}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[1]['name']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}

    ${resp}=  Get Queues
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_q1}   ${resp.json()[0]['id']}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  onlineCheckIns=True

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
       
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
   
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME3}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    @{fileswithcaption}=  Create List   ${filecap_dict1}   ${filecap_dict2}

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Imageupload.CWLSCommMultiFile   ${cookie}  ${pid0}  ${wid}  ${msg}  ${messageType[0]}  ${EMPTY}  @{fileswithcaption}  
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}   ${cid}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}   ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}   0
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}    ${pid0}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}   ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}  0
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}    ${pid0}

JD-TC-Communication Between Consumer and Provider-9
    [Documentation]   Consumer sends multiple files to provider in waitlist communication without caption
    clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME3}
    clear_consumer_msgs  ${CUSERNAME3}
    clear_provider_msgs  ${PUSERPH0}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pro_id}  ${decrypted_data['id']}
    # Set Test Variable  ${pro_id}  ${resp.json()['id']}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}
    Set Test Variable   ${p1_s2}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[1]['name']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}

    ${resp}=  Get Queues
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_q1}   ${resp.json()[0]['id']}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  onlineCheckIns=True

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
       
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME3}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${EMPTY}
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${EMPTY}
    @{fileswithcaption}=  Create List   ${filecap_dict1}   ${filecap_dict2}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Imageupload.CWLSCommMultiFile   ${cookie}  ${pid0}  ${wid}  ${msg}  ${messageType[0]}  ${EMPTY}  @{fileswithcaption}  
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}   ${cid}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}   ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}   0
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}    ${pid0}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}   ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}  0
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}    ${pid0}

JD-TC-Communication Between Consumer and Provider-10
    [Documentation]   Consumer attaching a pdf file with communication for provider.
    clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME28}
    clear_consumer_msgs  ${CUSERNAME28}
    clear_provider_msgs  ${PUSERPH0}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pro_id}  ${decrypted_data['id']}
    # Set Test Variable  ${pro_id}  ${resp.json()['id']}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}
    Set Test Variable   ${p1_s2}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[1]['name']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}

    ${resp}=  Get Queues
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_q1}   ${resp.json()[0]['id']}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  onlineCheckIns=True

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME28}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Imageupload.ConsWLCommunication   ${cookie}  ${wid1}  ${pid0}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${pdffile}
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}   ${cid}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}   ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}   0
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}    ${pid0}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}  ${wid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}   ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}  0
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}    ${pid0}

# JD-TC-Communication Between Consumer and Provider-UH1
# 	[Documentation]  Communication Between Consumer and Provider without login 

#     ${pid0}=  get_acc_id  ${PUSERPH0}
#     ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
#     ${caption}=  Fakerlibrary.sentence
#     ${resp}=  Imageupload.consumercomupload   ${pid0}  ${wid1}  ${msg}  ${caption}
#     Log  ${resp}
#     Should Be Equal As Strings  ${resp[1]}  419         
#     Should Be Equal As Strings  ${resp[0]}  ${SESSION_EXPIRED}

JD-TC-Communication Between Consumer and Provider-UH2
    [Documentation]   Communication Between Consumer  using another consumer uuid

    clear waitlist   ${PUSERPH0}
    clear_consumer_msgs  ${CUSERNAME28}
    clear_provider_msgs  ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME28}
    

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}
    Set Test Variable   ${p1_s2}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[1]['name']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}

    ${resp}=  Get Queues
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_q1}   ${resp.json()[0]['id']}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  onlineCheckIns=True

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME4}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Imageupload.ConsWLCommunication   ${cookie}  ${wid1}  ${pid0}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpgfile}
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  ${resp.json()}  ${INVALID_WAITLIST}

   
    
***Comment***

JD-TC-Communication Between Consumer and Provider-UH2
	[Documentation]  Communication Between Consumer and Provider by provider login
	${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  CommunicationBetweenConsumerAndProvider  ${pid0}  ${wid}  Thank you for your message
    Should Be Equal As Strings  ${resp.status_code}  401 
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"
   
    
    
    
    
    