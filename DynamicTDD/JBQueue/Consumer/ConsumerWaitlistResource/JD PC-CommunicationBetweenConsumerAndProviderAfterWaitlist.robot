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
Library         /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
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
	
    # ${PUSERNAME3}=  Evaluate  ${PUSERNAME}+100100601
    # Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME3}${\n}
    # Set Suite Variable   ${PUSERNAME3}
    
    ${firstname}  ${lastname}  ${PUSERNAME3}  ${login_id}=  Provider Signup  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid0}  ${decrypted_data['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY}=  db.get_date_by_timezone  ${tz}

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${CUSERNAME0}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cons_id}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Sample Location
    Set Suite Variable    ${p1_l1}    ${resp}  
    
    ${resp}=   Get Location ById  ${p1_l1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${P1SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${P1SERVICE1}
    ${P2SERVICE2}=    FakerLibrary.word

    ${resp}=   Create Sample Service  ${P1SERVICE1}
    Set Suite Variable    ${p1_s1}    ${resp}
    ${resp}=   Create Sample Service  ${P2SERVICE2}
    Set Suite Variable    ${p1_s2}    ${resp}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${strt_time}=   db.add_timezone_time  ${tz}  1  00
    Set Suite Variable    ${strt_time}
    ${end_time}=    db.add_timezone_time  ${tz}  3  00 
    Set Suite Variable    ${end_time}   
    ${parallel}=   Random Int  min=1   max=1
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=10   max=20
    Set Suite Variable   ${capacity}
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${p1_l1}  ${p1_s1}  ${p1_s2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q1}   ${resp.json()}

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist  ${cons_id}  ${p1_s1}  ${p1_q1}  ${DAY}  ${desc}  ${bool[1]}  ${cons_id} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=   Get Consumer Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME0}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME0}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME0}    ${account_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME0}
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME0}    ${account_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}   ${resp.json()['id']} 

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Imageupload.ConsWLCommunication   ${cookie}  ${wid}  ${pid0}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpgfile}
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}   ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}   0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${account_id}
    
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  CommunicationBetweenConsumerAndProvider  ${pid0}  ${wid}  Thank you for your message
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Communication Between Consumer and Provider-2
    
    [Documentation]   Communication Between Consumer and Provider after waitlist operation by consumer side  
    
    # clear waitlist   ${PUSERNAME3}
    # ${pid0}=  get_acc_id  ${PUSERNAME3}
    # clear_consumer_msgs  ${CUSERNAME3}
    # clear_provider_msgs  ${PUSERNAME3}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pro_id}  ${decrypted_data['id']}

    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${resp}=    Send Otp For Login    ${CUSERNAME3}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME3}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME3}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME3}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid3}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid3}   ${resp.json()['id']} 
 
       
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}  location=${p1_l1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Imageupload.ConsWLCommunication   ${cookie}  ${wid}  ${pid0}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid3}  ${resp.json()[0]['jaldeeConsumer']}

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME3}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
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

    clear waitlist   ${PUSERNAME3}
    ${pid0}=  get_acc_id  ${PUSERNAME3}
    clear_consumer_msgs  ${CUSERNAME28}
    clear_consumer_msgs  ${CUSERNAME3}
    clear_provider_msgs  ${PUSERNAME3}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
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

    ${resp}=  AddCustomer  ${CUSERNAME28}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    # ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cname}  ${resp.json()['userName']}
    # ${cid1}=  get_id  ${CUSERNAME28}

    ${resp}=    Send Otp For Login    ${CUSERNAME28}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME28}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME28}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
        
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME28}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${Pro_cid1}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid1}   ${resp.json()['id']} 
    Set Test Variable  ${cname}  ${resp.json()['userName']}

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



    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
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
    ${consumerid}=     Set Variable  customer id # ${Pro_cid1} 
    # ${consumerid}=   Replace String  ${consumerid}  [Providerconsumerid]   ${Pro_cid1} 

    ${bookingid}=  Format String  ${bookinglink}  ${W_encId}  ${W_encId}
    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${consumerid}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${W_encId}

    ${defaultmsg}=  Replace String  ${defconsumerCancel_msg}  [consumer]   ${consumerid}
    ${defconsumerCancel_msg}=  Replace String  ${defaultmsg}  [bookingId]   ${W_encId}   
    ${defconsumerCancel_msg}=  Replace String  ${defconsumerCancel_msg}  [providerMessage]   ${provider_msg}


    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME28}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200 
    sleep   2s

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   0
    # Should Be Equal As Strings  ${resp.json()[0]['msg']}   ${defconfirm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}   ${cid1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${pid0}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}   0
    Variable Should Exist       ${resp.json()[1]['msg']}    ${defconsumerCancel_msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}   ${cid1}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}    ${pid0}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
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
    clear waitlist   ${PUSERNAME3}
    ${pid0}=  get_acc_id  ${PUSERNAME3}
    ${cid}=  get_id  ${CUSERNAME28}
    clear_consumer_msgs  ${CUSERNAME28}
    clear_provider_msgs  ${PUSERNAME3}
    clear Customer  ${PUSERNAME3}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pro_id}  ${decrypted_data['id']}
    # Set Test Variable  ${pro_id}  ${resp.json()['id']}

    ${resp}=  AddCustomer  ${CUSERNAME28}
    Log   ${resp.json()}
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

    ${resp}=  Get Consumer Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  onlineCheckIns=True

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
      
    ${resp}=    Send Otp For Login    ${CUSERNAME28}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME28}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME28}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
        
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME28}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']} 


    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    # ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME28}   ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings   ${resp.status_code}    200

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
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
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
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
    clear waitlist   ${PUSERNAME3}
    ${pid0}=  get_acc_id  ${PUSERNAME3}
    ${cid}=  get_id  ${CUSERNAME28}
    clear_consumer_msgs  ${CUSERNAME28}
    clear_provider_msgs  ${PUSERNAME3}
    clear Customer  ${PUSERNAME3}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
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

    ${resp}=  AddCustomer  ${CUSERNAME28}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    ${resp}=    Send Otp For Login    ${CUSERNAME28}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME28}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME28}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
        
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME28}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']} 


    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    # ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME28}   ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings   ${resp.status_code}    200

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
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
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
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
    clear waitlist   ${PUSERNAME3}
    ${pid0}=  get_acc_id  ${PUSERNAME3}
    ${cid}=  get_id  ${CUSERNAME28}
    clear_consumer_msgs  ${CUSERNAME28}
    clear_provider_msgs  ${PUSERNAME3}
    clear Customer  ${PUSERNAME3}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pro_id}  ${decrypted_data['id']}
    # Set Suite Variable  ${pro_id}  ${resp.json()['id']}

    ${resp}=  AddCustomer  ${CUSERNAME28}
    Log   ${resp.json()}
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
    
    
    ${resp}=    Send Otp For Login    ${CUSERNAME28}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME28}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME28}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
        
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME28}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']} 



    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    # ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME28}   ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings   ${resp.status_code}    200

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
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
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
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
    clear waitlist   ${PUSERNAME3}
    ${pid0}=  get_acc_id  ${PUSERNAME3}
    ${cid}=  get_id  ${CUSERNAME28}
    clear_consumer_msgs  ${CUSERNAME28}
    clear_provider_msgs  ${PUSERNAME3}
    clear Customer  ${PUSERNAME3}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pro_id}  ${decrypted_data['id']}
    # Set Test Variable  ${pro_id}  ${resp.json()['id']}

    ${resp}=  AddCustomer  ${CUSERNAME28}
    Log   ${resp.json()}
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
    
    
    ${resp}=    Send Otp For Login    ${CUSERNAME28}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME28}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME28}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
        
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME28}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']} 



    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    # ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME28}   ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings   ${resp.status_code}    200

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
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
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
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

    clear waitlist   ${PUSERNAME3}
    ${pid0}=  get_acc_id  ${PUSERNAME3}
    ${cid}=  get_id  ${CUSERNAME3}
    clear_consumer_msgs  ${CUSERNAME3}
    clear_provider_msgs  ${PUSERNAME3}
    clear Customer  ${PUSERNAME3}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pro_id}  ${decrypted_data['id']}
    # Set Test Variable  ${pro_id}  ${resp.json()['id']}

    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
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
    
    ${resp}=    Send Otp For Login    ${CUSERNAME3}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME3}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME3}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
        
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME3}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']} 


       
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
   
    # ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME3}   ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings   ${resp.status_code}    200

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    @{fileswithcaption}=  Create List   ${filecap_dict1}   ${filecap_dict2}

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
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
    clear waitlist   ${PUSERNAME3}
    ${pid0}=  get_acc_id  ${PUSERNAME3}
    ${cid}=  get_id  ${CUSERNAME3}
    clear_consumer_msgs  ${CUSERNAME3}
    clear_provider_msgs  ${PUSERNAME3}
    clear Customer  ${PUSERNAME3}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pro_id}  ${decrypted_data['id']}
    # Set Test Variable  ${pro_id}  ${resp.json()['id']}

    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
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
    
    ${resp}=    Send Otp For Login    ${CUSERNAME3}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME3}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME3}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
        
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME3}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']} 

       
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    
    # ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME3}   ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings   ${resp.status_code}    200

    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${EMPTY}
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${EMPTY}
    @{fileswithcaption}=  Create List   ${filecap_dict1}   ${filecap_dict2}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
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
    clear waitlist   ${PUSERNAME3}
    ${pid0}=  get_acc_id  ${PUSERNAME3}
    ${cid}=  get_id  ${CUSERNAME28}
    clear_consumer_msgs  ${CUSERNAME28}
    clear_provider_msgs  ${PUSERNAME3}
    clear Customer  ${PUSERNAME3}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pro_id}  ${decrypted_data['id']}
    # Set Test Variable  ${pro_id}  ${resp.json()['id']}

    ${resp}=  AddCustomer  ${CUSERNAME28}
    Log   ${resp.json()}
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
    
    
    ${resp}=    Send Otp For Login    ${CUSERNAME28}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME28}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME28}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
        
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME28}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']} 


    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}

    # ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME28}   ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings   ${resp.status_code}    200

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
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
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
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

#     ${pid0}=  get_acc_id  ${PUSERNAME3}
#     ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
#     ${caption}=  Fakerlibrary.sentence
#     ${resp}=  Imageupload.consumercomupload   ${pid0}  ${wid1}  ${msg}  ${caption}
#     Log  ${resp}
#     Should Be Equal As Strings  ${resp[1]}  419         
#     Should Be Equal As Strings  ${resp[0]}  ${SESSION_EXPIRED}

JD-TC-Communication Between Consumer and Provider-UH2
    [Documentation]   Communication Between Consumer  using another consumer uuid

    clear waitlist   ${PUSERNAME3}
    clear_consumer_msgs  ${CUSERNAME28}
    clear_provider_msgs  ${PUSERNAME3}
    ${pid0}=  get_acc_id  ${PUSERNAME3}
    ${cid}=  get_id  ${CUSERNAME28}
    clear Customer  ${PUSERNAME3}
    

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
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

    ${resp}=  AddCustomer  ${CUSERNAME28}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  onlineCheckIns=True

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    ${resp}=    Send Otp For Login    ${CUSERNAME28}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME28}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME28}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
        
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME28}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']} 


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
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Imageupload.ConsWLCommunication   ${cookie}  ${wid1}  ${pid0}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpgfile}
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  ${resp.json()}  ${INVALID_WAITLIST}

   
JD-TC-Communication Between Consumer and Provider-UH3
	
    [Documentation]  Communication Between Consumer and Provider by provider login
	
    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  CommunicationBetweenConsumerAndProvider  ${pid0}  ${wid}  Thank you for your message
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401 
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"
   
    
    
    
    
    