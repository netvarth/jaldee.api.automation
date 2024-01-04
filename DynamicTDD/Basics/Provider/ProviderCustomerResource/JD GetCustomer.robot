***Settings***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Customers
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/musers.py
#Force Tags        ProviderCommunication

***Variables***
${self}   0


@{Views}  self  all  customersOnly
${CUSERPH}      ${CUSERNAME}
${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}     /ebs/TDD/upload.png
*** Test Cases ***

JD-TC-Get Customers-1
    [Documentation]   Get Customers by provider login using account 
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME245}  ${PASSWORD}
    clear_customer   ${PUSERNAME245}

    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}

    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${firstname1}=  FakerLibrary.first_name 
    Set Suite Variable  ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname1}
    ${dob1}=  FakerLibrary.Date
    Set Suite Variable  ${dob1}
    ${gender1}=  Random Element    ${Genderlist}
    Set Suite Variable  ${gender1}
    ${ph}=  Evaluate  ${PUSERNAME230}+71109
    Set Suite Variable  ${ph}
    ${resp}=  AddCustomer without email   ${firstname1}  ${lastname1}  ${EMPTY}  ${gender1}  ${dob1}  ${ph}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph}${\n}
    ${resp}=  GetCustomer   account-eq=${cid} 
    Should Be Equal As Strings  ${resp.status_code}  200  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  firstName=${firstname1}  lastName=${lastname1}  phoneNo=${ph}  dob=${dob1}  gender=${gender1}  email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${cid}  favourite=${bool[0]}
   
JD-TC-Get Customers-2
    [Documentation]   Get Customers by another provider using phone and status
    ${resp}=  Encrypted Provider Login  ${PUSERNAME235}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}

    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${ph2}=  Evaluate  ${PUSERNAME230}+71010
    ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}   ${gender}  ${dob}  ${ph2}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph2}${\n}
    # ${resp}=  ProviderLogout
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  GetCustomer  phoneNo-eq=${ph2}   status-eq=ACTIVE 
    Log  ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  firstName=${firstname}  lastName=${lastname}  phoneNo=${ph2}  dob=${dob}  gender=${gender}  email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${cid1}  favourite=${bool[0]}
    
JD-TC-Get Customers-3
    [Documentation]   Get Customers by another provider using fname and lastname
    ${resp}=  Encrypted Provider Login  ${PUSERNAME236}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}

    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${ph2}=  Evaluate  ${PUSERNAME230}+71011
    ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}   ${gender}  ${dob}  ${ph2}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph2}${\n}
    ${resp}=  GetCustomer    firstName-eq=${firstname}   lastName-eq=${lastname}
    Log  ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  firstName=${firstname}  lastName=${lastname}  phoneNo=${ph2}  dob=${dob}  gender=${gender}  email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${cid1}  favourite=${bool[0]}
    

JD-TC-Get Customers-4
	[Documentation]   Get Customers by provider login using dob
    ${resp}=  Encrypted Provider Login  ${PUSERNAME245}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  GetCustomer   dob-eq=${dob1}     
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  firstName=${firstname1}  lastName=${lastname1}  phoneNo=${ph}  dob=${dob1}  gender=${gender1}  email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${cid}  favourite=${bool[0]}
   

JD-TC-Get Customers-5
	[Documentation]   Get Customers by provider login using status
    ${resp}=  Encrypted Provider Login  ${PUSERNAME245}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  GetCustomer   status-eq=ACTIVE   
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()} 
    Verify Response List  ${resp}  0  firstName=${firstname1}  lastName=${lastname1}  phoneNo=${ph}  dob=${dob1}  gender=${gender1}  email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${cid}  favourite=${bool[0]}
    
JD-TC-Get Customers-UH1
    [Documentation]   Get Customers without provider login
    ${resp}=  GetCustomer  
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"
    
JD-TC-Get Customers-UH2
    [Documentation]   Get Customers using consumer login
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  GetCustomer
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"  


JD-TC-Get Customers-6
	[Documentation]   Add consumer with international number, take checkin, 
    ...   ${SPACE}check provider consumer data to see if the provider consumer for that consumer is created. 
    ...   ${SPACE}consumer then changes login id to indian number and check if it is reflected in the provider consumer data

    ${resp}=  Encrypted Provider Login  ${PUSERNAME53}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    clear_location   ${PUSERNAME53}
    clear_service    ${PUSERNAME53}
    clear_customer   ${PUSERNAME53}
    clear_provider_msgs  ${PUSERNAME53}

    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service  ${SERVICE1}
    
    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    clear_queue   ${PUSERNAME53}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    
    ${resp}=  Sample Queue  ${lid}   ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}  queueState=${Qstate[0]}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${PO_Number}    Generate random string    4    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${PO_Number}
    # clear_consumer_msgs  ${CUSERPH0}
    # Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH0}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERPH0_EMAIL}=   Set Variable  ${C_Email}${lastname}${PO_Number}.${test_mail}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH0}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERPH0}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERPH0}  ${PASSWORD}  1  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${q_id}  ${DAY1}  ${s_id}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME53}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${alt_Number}    Generate random string    5    0123456789
    ${alt_Number}    Convert To Integer  ${alt_Number}
    ${CUSERPH0_new}=  Evaluate  ${CUSERPH0}+${alt_Number}

    ${resp}=  Send Verify Login Consumer   ${CUSERPH0_new}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Verify Login Consumer   ${CUSERPH0_new}  5
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME53}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0_new}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200




JD-TC-Get Customers-7
    [Documentation]   A consumer signup and message passed to a provider , that  consumer added as provider customer
    ${CUSERPH75}=  Evaluate  ${CUSERPH}+100100157
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH75}${\n}
    Set Suite Variable   ${CUSERPH75}
   # ${CUSERPH3}=  Evaluate  ${CUSERPH}+100100204
    #Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH3}${\n}
   # Set Suite Variable   ${CUSERPH3}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH75}+1000
    ${CUSERMAIL2}=   Set Variable  ${C_Email}ph9o9j.${test_mail}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH75}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERPH75}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH75}${\n}


    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    


    ${resp}=   Encrypted Provider Login  ${PUSERNAME214}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}

    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${acc_id}=  get_acc_id  ${PUSERNAME214}
    Set Suite Variable   ${acc_id} 
    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${resp}=  Consumer Login  ${CUSERPH75}    ${PASSWORD}
    Log   ${resp.json()}
    
    ${c_id}=  get_id  ${CUSERPH75}
    clear_Consumermsg  ${CUSERPH75}
    clear_Providermsg  ${PUSERNAME214}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH75}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable    ${cookie} 
    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpgfile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME214}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption}


    ${resp}=  GetCustomer   account-eq=${c_id}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Log  ${resp.json()}
    Verify Response List  ${resp}  0  firstName=${firstname}  lastName=${lastname}   phoneNo=${CUSERPH75}     email=${CUSERMAIL2}    email_verified=${bool[0]}   phone_verified=${bool[0]}     favourite=${bool[0]}

JD-TC-Get Customers-8
    [Documentation]  Add a new valid customer ang get that customer using secondary phone number filter
    ${resp}=  Encrypted Provider Login  ${PUSERNAME230}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    #  Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${ph2}=  Evaluate  ${PUSERNAME23}+73009
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${resp}=  AddCustomer  ${phone1}   firstName=${firstname}   lastName=${lastname}  secondaryCountryCode=${countryCodes[0]}  secondaryPhoneNo=${ph2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${cid}  ${resp.json()}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph2}${\n}

    ${resp}=  GetCustomer    secondaryPhoneNo-eq=${ph2}    status-eq=ACTIVE
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  firstName=${firstname}  lastName=${lastname}  phoneNo=${phone1}  secondaryCountryCode=${countryCodes[0]}  secondaryPhoneNo=${ph2}

