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

***Variables***
${SERVICE1}               SERVICE1
${SERVICE2}               SERVICE2

${self}                   0


*** Test Cases ***
 
JD-TC-Update CustomerDetails-1

	[Documentation]  Update a valid customer without email

    ${resp}=  Encrypted Provider Login  ${PUSERNAME233}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}

    # Set Test Variable  ${p_id}  ${resp.json()['id']}

    # ${resp}=  Get Account Settings
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get jaldeeIntegration Settings
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Run Keyword If   ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[1]}     Set jaldeeIntegration Settings    ${boolean[0]}  ${boolean[0]}  ${boolean[0]}

    # ${resp}=  Get jaldeeIntegration Settings
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}
    # Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[0]}


    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable   ${gender}
    ${ph}=  Evaluate  ${PUSERNAME230}+71011
    ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}   ${gender}  ${dob}  ${ph}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}
    Log  ${resp.json()}  
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph}${\n}
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    # ${gender1}=  Random Element    ${Genderlist}
    ${ph1}=  Evaluate  ${PUSERNAME230}+71012
    Set Test Variable  ${ph1}
    ${resp}=  UpdateCustomer without email  ${cid}   ${firstname1}  ${lastname1}  ${EMPTY}  ${gender}  ${dob1}  ${ph1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ncid}  ${resp.json()}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph1}${\n}
    ${resp}=  GetCustomer  firstName-eq=${firstname1}  phoneNo-eq=${ph1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()} 
    Verify Response List  ${resp}  0  firstName=${firstname1}  lastName=${lastname1}  phoneNo=${ph1}  dob=${dob1}  gender=${gender}  email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${cid}   favourite=${bool[0]}
 
JD-TC-Update CustomerDetails-2
	[Documentation]  Update a valid customer with email
    ${resp}=  Encrypted Provider Login  ${PUSERNAME234}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}

    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable   ${gender}
    ${ph2}=  Evaluate  ${PUSERNAME230}+71013
    Set Suite Variable  ${email2}  ${firstname}${ph2}${C_Email}.${test_mail}
    ${resp}=  AddCustomer with email  ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${ph2}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}  
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph2}${\n}
    Set Test Variable  ${cid2}  ${resp.json()}
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    # ${gender1}=  Random Element    ${Genderlist}
    ${ph3}=  Evaluate  ${PUSERNAME230}+71014
    Set Suite Variable  ${email3}  ${lastname}${ph3}${C_Email}.${test_mail}
    ${resp}=  UpdateCustomer with email  ${cid2}  ${firstname1}  ${lastname1}  ${EMPTY}  ${email3}  ${gender}  ${dob1}  ${ph3}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ncid}  ${resp.json()}
    Log  ${resp.json()}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph3}${\n}
    ${resp}=  GetCustomer  firstName-eq=${firstname1}  phoneNo-eq=${ph3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  firstName=${firstname1}  lastName=${lastname1}  phoneNo=${ph3}  dob=${dob1}  gender=${gender}   email=${email3}   email_verified=${bool[0]}   phone_verified=${bool[0]}   id=${cid2}   favourite=${bool[0]}
    
JD-TC-Update CustomerDetails-3
    [Documentation]  Update a valid customer using email of another customer
    ${resp}=  Encrypted Provider Login  ${PUSERNAME235}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${ph2}=  Evaluate  ${PUSERNAME231}+71015
    Set Test Variable  ${ph2}
    Set Test Variable  ${email8}  ${firstname}${ph2}${C_Email}.${test_mail}
    ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email8}  ${gender}  ${dob}  ${ph2}  ${EMPTY} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph2}${\n}
    Set Test Variable  ${cid3}  ${resp.json()}
    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name
    ${dob2}=  FakerLibrary.Date
    ${gender2}=  Random Element    ${Genderlist}
    ${ph0}=  Evaluate  ${PUSERNAME231}+71016
    Set Test Variable  ${email9}  ${firstname2}${ph0}${C_Email}.${test_mail}
    ${resp}=  AddCustomer with email   ${firstname2}  ${lastname2}  ${EMPTY}  ${email9}  ${gender2}  ${dob2}  ${ph0}  ${EMPTY} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph0}${\n}
    Set Test Variable  ${cid4}  ${resp.json()}
    ${resp}=  UpdateCustomer with email   ${cid4}  ${firstname2}  ${lastname2}  ${EMPTY}  ${email8}  ${gender2}  ${dob2}  ${ph0}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  GetCustomer  firstName-eq=${firstname2}  phoneNo-eq=${ph0}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  firstName=${firstname2}  lastName=${lastname2}  phoneNo=${ph0}  dob=${dob2}  gender=${gender2}   email=${email8}   email_verified=${bool[0]}   phone_verified=${bool[0]}   id=${cid4}   favourite=${bool[0]}
    # Should Be Equal As Strings  "${resp.json()}"  "${EMAIL_EXISTS}"
       
JD-TC-Update CustomerDetails-UH1
    [Documentation]  Update a customer using consumer login
    ${resp}=  ConsumerLogin  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${ph}=  Evaluate  ${PUSERNAME230}+71013
    ${resp}=  UpdateCustomer with email   ${cid}  ${firstname}  ${lastname}  ${EMPTY}  ${email3}  ${gender}  ${dob}  ${ph}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"
    
JD-TC-Update CustomerDetails-UH2
    [Documentation]  Update a valid customer without login
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${ph}=  Evaluate  ${PUSERNAME230}+71013
    ${resp}=  UpdateCustomer with email  ${cid}  ${firstname}  ${lastname}  ${EMPTY}  ${email3}  ${gender}  ${dob}  ${ph}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
     

JD-TC-Update CustomerDetails-UH3
    [Documentation]  Update customer using primary mob no of another provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME236}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${ph5}=  Evaluate  ${PUSERNAME230}+71013
    Set Test Variable  ${ph5}
    Set Test Variable  ${email5}  ${firstname}${ph5}${C_Email}.${test_mail}
    ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email5}  ${gender}  ${dob}  ${ph5}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph5}${\n}
    Set Test Variable  ${cid5}  ${resp.json()}
    ${firstname1}=  FakerLibrary.first_name
    Set Test Variable  ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Test Variable  ${lastname1}
    ${dob1}=  FakerLibrary.Date
    Set Test Variable  ${dob1}
    ${gender1}=  Random Element    ${Genderlist}
    Set Test Variable  ${gender1}
    ${ph3}=  Evaluate  ${PUSERNAME230}+71017
    Set Test Variable  ${email}  ${firstname1}${ph3}${C_Email}.${test_mail}
    ${resp}=  AddCustomer with email   ${firstname1}  ${lastname1}  ${EMPTY}  ${email}  ${gender1}  ${dob1}  ${ph3}  ${EMPTY} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph3}${\n}
    Set Test Variable  ${cid6}  ${resp.json()}
    ${resp}=  UpdateCustomer with email   ${cid6}  ${firstname1}  ${lastname1}  ${EMPTY}  ${email}  ${gender1}  ${dob1}  ${ph5}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${PRO_CON_ALREADY_EXIST}"

JD-TC-Update CustomerDetails-UH4
	[Documentation]  A non parent updates a customer
    ${resp}=  Encrypted Provider Login  ${PUSERNAME232}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}

    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${ph2}=  Evaluate  ${PUSERNAME230}+71016
    Set Test Variable  ${email4}  ${firstname}${ph2}${C_Email}.${test_mail}
    ${resp}=  AddCustomer with email  ${firstname}  ${lastname}  ${EMPTY}  ${email4}  ${gender}  ${dob}  ${ph2}  ${EMPTY} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph2}${\n}
    Set Test Variable  ${cid1}  ${resp.json()}
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    ${gender1}=  Random Element    ${Genderlist}
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME234}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  UpdateCustomer with email  ${cid1}  ${firstname1}  ${lastname1}  ${EMPTY}  ${email4}  ${gender1}  ${dob1}  ${ph2}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"    "${NO_PERMISSION}"
    # Should Be Equal As Strings  "${resp.json()}"   "${CONSUMER_NOT_FOUND}"
   
     
JD-TC-Update CustomerDetails-4
	[Documentation]  Update a valid customer here add a new consumer number(new keyword)
    ${resp}=  Encrypted Provider Login  ${PUSERNAME233}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}

    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${ph}=  Evaluate  ${PUSERNAME230}+71018
    ${resp}=  AddCustomer  ${ph}  firstName=${firstname}   lastName=${lastname} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph}${\n}
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${ph1}=  Evaluate  ${PUSERNAME230}+71019
    Set Test Variable  ${ph1}
    ${resp}=  Update Customer Details  ${cid}  phoneNo=${ph1}  countryCode=91  firstName=${firstname1}  lastName=${lastname1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ncid}  ${resp.json()}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph1}${\n}
    ${resp}=  GetCustomer    phoneNo-eq=${ph1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()} 
    Verify Response List  ${resp}  0  firstName=${firstname1}  lastName=${lastname1}  phoneNo=${ph1}   email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${cid}   favourite=${bool[0]}
   
JD-TC-Update CustomerDetails-5

    [Documentation]  Add a valid customer and take a walkin checkin after updating the customer and check updated waitlist details
   
    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname1}   ${resp.json()['firstName']}
    Set Test Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_queue      ${PUSERNAME233}
    clear_location   ${PUSERNAME233}
    clear_service    ${PUSERNAME233}
    clear waitlist   ${PUSERNAME233}
    clear_customer   ${PUSERNAME233}

     
    ${resp}=  Encrypted Provider Login  ${PUSERNAME233}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[0]}

    # ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${resp}=  Get jaldeeIntegration Settings
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  AddCustomer  ${CUSERNAME2}   firstName=${fname1}   lastName=${lname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable   ${jaldeeid1}    ${resp.json()[0]['jaldeeId']}
    
    ${pid1}=  get_acc_id  ${PUSERNAME233}
    Set Suite Variable   ${pid1} 

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY}
    
    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Suite Variable    ${ser_id1}    ${resp}
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  3  00  
    ${end_time}=    add_timezone_time  ${tz}  3  30      
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()} 
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid1}
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}           ${fname1}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}            ${lname1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid1}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${resp}=  Update Customer Details  ${cid1}  phoneNo=${CUSERNAME2}  countryCode=91   firstName=${firstname}  lastName=${lastname}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid1}
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}           ${firstname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}            ${lastname}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid1}

    ${resp}=  Consumer Login   ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION}"


JD-TC-Update CustomerDetails-6

    [Documentation]  Add a valid customer and take a online checkin after updating the customer and then check updated waitlist details
   
    clear waitlist   ${PUSERNAME233}

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname3}   ${resp.json()['firstName']}
    Set Test Variable  ${lname3}   ${resp.json()['lastName']}

    ${cid2}=  get_id  ${CUSERNAME3}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid1}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${json}=  Set Variable   ${resp.json()}    
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME233}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  AddCustomer  ${CUSERNAME3}   ${fname3}   ${lname3}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid2}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pcons_id1}  ${resp.json()[0]['id']}
    Set Test Variable   ${jaldeeid1}    ${resp.json()[0]['jaldeeId']}

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${pid1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}             ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}               ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${jdconID}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}      ${pcons_id1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}                  ${que_id1}

    ${resp}=   Get Waitlist Consumer
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response List  ${resp}  0   date=${CUR_DAY}  waitlistStatus=${wl_status[0]}  partySize=1    waitlistedBy=${waitlistedby[0]}    personsAhead=0
    # Should Be Equal As Strings  ${resp.json()[0]['service']['name']}               ${SERVICE1}
    # Should Be Equal As Strings  ${resp.json()[0]['service']['id']}                 ${ser_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}                ${pcons_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['consumer']['jaldeeId']}          ${jaldeeid1}
    # Should Be Equal As Strings  ${resp.json()[0]['waitlistingFor'][0]['id']}        ${pcons_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['waitlistingFor'][0]['firstName']}  ${fname3}
    # Should Be Equal As Strings  ${resp.json()[0]['waitlistingFor'][0]['lastName']}   ${lname3}
    # Should Be Equal As Strings  ${resp.json()[0]['waitlistingFor'][0]['phoneNo']}   ${CUSERNAME3}
    # Should Be Equal As Strings  ${resp.json()[0]['queue']['id']}                      ${que_id1}     

    ${resp}=  Encrypted Provider Login  ${PUSERNAME233}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${resp}=  Update Customer Details  ${pcons_id1}  phoneNo=${CUSERNAME3}  countryCode=91  firstName=${firstname}  lastName=${lastname}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${pid1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}     date=${CUR_DAY}  waitlistStatus=${wl_status[0]}  partySize=1    waitlistedBy=${waitlistedby[0]}    personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${pcons_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['jaldeeId']}            ${jaldeeid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${pcons_id1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname3} 
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}   ${lname3}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['phoneNo']}    ${CUSERNAME3}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}                     ${que_id1}     


JD-TC-Update CustomerDetails-7

    [Documentation]  Add a valid customer and take a walkin appointment, after updating the customer and check updated appointment details
   
    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname1}   ${resp.json()['firstName']}
    Set Test Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_queue      ${PUSERNAME233}
    clear_location   ${PUSERNAME233}
    clear_service    ${PUSERNAME233}
    clear waitlist   ${PUSERNAME233}
    clear_service   ${PUSERNAME233}
    clear_customer   ${PUSERNAME233}

     
    ${resp}=  Encrypted Provider Login  ${PUSERNAME233}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[0]}  ${boolean[0]}
    # Should Be Equal As Strings  ${resp.status_code}  200
   
    # ${resp}=   Get jaldeeIntegration Settings
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[0]}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid}=  Create Sample Location  
    Set Suite Variable  ${lid}
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    clear_appt_schedule   ${PUSERNAME233}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${s_id}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id}
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

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${resp}=  Update Customer Details  ${cid}  phoneNo=${CUSERNAME2}  countryCode=91  firstName=${firstname}  lastName=${lastname}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}                            ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}               ${encId}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}         ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}    ${CUSERNAME2}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['jaldeeId']}   ${jaldeeid1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                  ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                 ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                     ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}       ${firstname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}        ${lastname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}        ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                      ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                      ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                 ${lid}

    ${resp}=  Consumer Login   ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get consumer Appointment By Id   ${pid1}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${YOU_CANNOT_VIEW_THE_APPT}"


JD-TC-Update CustomerDetails-8

    [Documentation]  Add a valid customer and take a online appointment, after updating the customer and check updated appointment details
   

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}

    ${cid}=  get_id  ${CUSERNAME7} 
   
    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot3}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot3}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
     Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid2}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid1}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response    ${resp}  appointmentMode=${appointmentMode[2]}    uid=${apptid2}  appmtDate=${DAY1}  appmtTime=${slot3}  
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${f_Name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${l_Name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${ph_no}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${f_Name}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${l_Name}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot3}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot3}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME233}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  AddCustomer  ${CUSERNAME7}   ${f_Name}   ${l_Name}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid0}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid0}  ${resp.json()[0]['id']}
    Set Test Variable   ${jaldeeid1}    ${resp.json()[0]['jaldeeId']}
    
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${resp}=  Update Customer Details  ${cid0}  phoneNo=${CUSERNAME7}  countryCode=91  firstName=${firstname}  lastName=${lastname}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Get consumer Appointment By Id   ${pid1}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response    ${resp}  appointmentMode=${appointmentMode[2]}    uid=${apptid2}  appmtDate=${DAY1}  appmtTime=${slot3}  
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}                 ${firstname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}                  ${lastname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}                   ${CUSERNAME7}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${firstname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${lastname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot3}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot3}


JD-TC-Update CustomerDetails-UH6
    [Documentation]  Update a valid jaldee customer and  trying to login with that updated number
    ${resp}=  Encrypted Provider Login  ${PUSERNAME259}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name 
    ${resp}=  AddCustomer  ${CUSERNAME8}   firstName=${firstname}   lastName=${lastname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${ph1}=  Evaluate  ${PUSERNAME230}+92079
    Set Test Variable  ${ph1}
    ${resp}=  Update Customer Details  ${cid}  phoneNo=${ph1}  countryCode=${countryCodes[0]}  firstName=${firstname1}  lastName=${lastname1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Consumer Login  ${ph1}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${ph1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.json()[0]['phoneNo']}   ${ph1}



    # Should Be Equal As Strings  "${resp.json()}"     "${PHONE_NOT_UPDATE}"
    # Set Test Variable  ${ncid}  ${resp.json()}
    # Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph1}${\n}
    # ${resp}=  GetCustomer    phoneNo-eq=${ph1}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200 
    # Verify Response List  ${resp}  0  firstName=${firstname1}  lastName=${lastname1}  phoneNo=${ph1}   countryCode=91  email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${cid}   favourite=${bool[0]}
   
    # ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Login  ${ph1}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    401
    # Should Be Equal As Strings  "${resp.json()}"     "${NOT_REGISTERED_CUSTOMER}"


JD-TC-Update CustomerDetails-9
    [Documentation]  Add customer and update customer phone number with international number

    ${resp}=  Encrypted Provider Login  ${PUSERNAME53}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${bname}  ${resp.json()['businessName']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    # Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    clear_location   ${PUSERNAME53}
    clear_service    ${PUSERNAME53}
    clear_customer   ${PUSERNAME53}
    clear_provider_msgs  ${PUSERNAME53}

    ${PO_Number1}    Generate random string    5    0123456789
    ${PO_Number1}    Convert To Integer  ${PO_Number1}
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${PO_Number1}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH0}${\n}
    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${resp}=   AddCustomer  ${CUSERPH0}  firstName=${fname}  lastName=${lname}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid}

    ${resp}=  Update Customer Details  ${cid}  phoneNo-eq=${CUSERPH0}  countryCode=${country_code}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Update CustomerDetails-10
    [Documentation]  Add 2 customers with same number but different country code and update one customer  with another  country code

    ${resp}=  Encrypted Provider Login  ${PUSERNAME53}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    clear_location   ${PUSERNAME53}
    clear_service    ${PUSERNAME53}
    clear_customer   ${PUSERNAME53}
    clear_provider_msgs  ${PUSERNAME53}

    ${PO_Number1}    Generate random string    5    0123456789
    ${PO_Number1}    Convert To Integer  ${PO_Number1}
    ${PO_Number2}    Generate random string    5    0123456798
    ${PO_Number2}    Convert To Integer  ${PO_Number2}
    ${country_code1}    Generate random string    2    0123456787
    FOR  ${i}  IN RANGE   5
        Exit For Loop If  '${country_code1}' != '91'
    END
    ${country_code1}    Convert To Integer  ${country_code1}
   # ${country_code2}    Generate random string    2    0123456785
    #FOR  ${i}  IN RANGE   5
    #    Exit For Loop If  '${country_code2}' != '962'
    #END
    #${country_code2}    Convert To Integer  ${country_code2}

    ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${PO_Number1}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH0}${\n}
    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${resp}=   AddCustomer   ${CUSERPH0}      firstName=${fname}  lastName=${lname}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid0}  ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid0}


  
    FOR   ${i}  IN RANGE   5
        # ${PO_Number1}    Generate random string    8    0123456789
        # ${PO_Number1}    Convert To Integer  ${PO_Number1}
        # ${CUSERPH4}=  Evaluate  ${CUSERPH}+${PO_Number1}
        # ${PO_Number1}=  random_phone_num_generator
        ${PO_Number1}=  Get Random Valid Phone Number
        Log  ${PO_Number1}
        ${country_code1}=  Set Variable  ${PO_Number1.country_code}
        ${CUSERPH4}=  Set Variable  ${PO_Number1.national_number}
        ${keywordstatus} 	${value} = 	Run Keyword And Ignore Error   List Should Not Contain Value  ${numbers}  ${CUSERPH4}
        Log Many  ${keywordstatus} 	${value}
        Continue For Loop If  '${keywordstatus}' == 'FAIL'
        Run Keyword If  '${keywordstatus}' == 'PASS'  Append To List   ${numbers}  ${CUSERPH0}
        Exit For Loop IF   '${keywordstatus}' == 'PASS'
    END

   
    ${other_country_codes}=   random_country_codes  ${CUSERPH0}
    Log  ${other_country_codes}
    Log List  ${other_country_codes}
    Append To List  ${other_country_codes}  ${country_code1}
    ${unique_ccodes}=    Remove Duplicates    ${other_country_codes}
    Remove Values From List  ${unique_ccodes}  ${country_code1}
    ${country_code2}=  Evaluate  random.choice($unique_ccodes)  random
    Remove Values From List  ${unique_ccodes}  ${country_code2}
     ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000






  
    ${fname1}=  FakerLibrary.first_name
    ${lname1}=  FakerLibrary.last_name
    ${resp}=   AddCustomer     ${CUSERPH0}   ${country_code2}  firstName=${fname1}  lastName=${lname1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid1}
    Should Be Equal As Strings  ${resp.json()[1]['id']}  ${cid0}

    ${resp}=  Update Customer Details  ${cid0}  phoneNo=${CUSERPH0}  countryCode=${country_code2}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Update CustomerDetails-11
    [Documentation]  Add customer, take checkin and update customer phone number with international number

    ${resp}=  Encrypted Provider Login  ${PUSERNAME53}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${bname}  ${resp.json()['businessName']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    # Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

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

    ${PO_Number1}    Generate random string    5    0123456789
    ${PO_Number1}    Convert To Integer  ${PO_Number1}
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${PO_Number1}
    # Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH0}${\n}
    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${resp}=   AddCustomer  ${CUSERPH0}  firstName=${fname}  lastName=${lname}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wl_json[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



   FOR   ${i}  IN RANGE   5
        # ${PO_Number1}    Generate random string    8    0123456789
        # ${PO_Number1}    Convert To Integer  ${PO_Number1}
        # ${CUSERPH4}=  Evaluate  ${CUSERPH}+${PO_Number1}
        # ${PO_Number1}=  random_phone_num_generator
        ${PO_Number1}=  Get Random Valid Phone Number
        Log  ${PO_Number1}
        ${country_code1}=  Set Variable  ${PO_Number1.country_code}
        ${CUSERPH4}=  Set Variable  ${PO_Number1.national_number}
        ${keywordstatus} 	${value} = 	Run Keyword And Ignore Error   List Should Not Contain Value  ${numbers}  ${CUSERPH4}
        Log Many  ${keywordstatus} 	${value}
        Continue For Loop If  '${keywordstatus}' == 'FAIL'
        Run Keyword If  '${keywordstatus}' == 'PASS'  Append To List   ${numbers}  ${CUSERPH0}
        Exit For Loop IF   '${keywordstatus}' == 'PASS'
    END

   
    ${other_country_codes}=   random_country_codes  ${CUSERPH0}
    Log  ${other_country_codes}
    Log List  ${other_country_codes}
    Append To List  ${other_country_codes}  ${country_code1}
    ${unique_ccodes}=    Remove Duplicates    ${other_country_codes}
    Remove Values From List  ${unique_ccodes}  ${country_code1}
    ${country_code2}=  Evaluate  random.choice($unique_ccodes)  random
    Remove Values From List  ${unique_ccodes}  ${country_code2}
     ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000

  #   ${PO_Number2}    Generate random string    5    112345678
  #  ${PO_Number2}    Convert To Integer  ${PO_Number2}
   # ${country_code}    Generate random string    2    0123456776
   # ${country_code1}    Convert To Integer  ${country_code}
   # ${CUSERPH4}=  Evaluate  ${CUSERNAME}+${PO_Number2}
   

    ${resp}=   Update Customer Details   ${cid}  phoneNo=${CUSERPH0}    countryCode=${country_code2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Update CustomerDetails-12
    [Documentation]  consumer takes checkin for provider and provider updates customer's phone number with international number

    ${resp}=  Encrypted Provider Login  ${PUSERNAME53}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${bname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    # Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

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
    # Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH0}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element   ${Genderlist}
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

      FOR   ${i}  IN RANGE   5
        # ${PO_Number1}    Generate random string    8    0123456789
        # ${PO_Number1}    Convert To Integer  ${PO_Number1}
        # ${CUSERPH4}=  Evaluate  ${CUSERPH}+${PO_Number1}
        # ${PO_Number1}=  random_phone_num_generator
        ${PO_Number1}=  Get Random Valid Phone Number
        Log  ${PO_Number1}
        ${country_code1}=  Set Variable  ${PO_Number1.country_code}
        ${CUSERPH4}=  Set Variable  ${PO_Number1.national_number}
        ${keywordstatus} 	${value} = 	Run Keyword And Ignore Error   List Should Not Contain Value  ${numbers}  ${CUSERPH4}
        Log Many  ${keywordstatus} 	${value}
        Continue For Loop If  '${keywordstatus}' == 'FAIL'
        Run Keyword If  '${keywordstatus}' == 'PASS'  Append To List   ${numbers}  ${CUSERPH0}
        Exit For Loop IF   '${keywordstatus}' == 'PASS'
    END

   
    ${other_country_codes}=   random_country_codes  ${CUSERPH0}
    Log  ${other_country_codes}
    Log List  ${other_country_codes}
    Append To List  ${other_country_codes}  ${country_code1}
    ${unique_ccodes}=    Remove Duplicates    ${other_country_codes}
    Remove Values From List  ${unique_ccodes}  ${country_code1}
    ${country_code2}=  Evaluate  random.choice($unique_ccodes)  random
    Remove Values From List  ${unique_ccodes}  ${country_code2}
     ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000


    ${resp}=  Update Customer Details  ${cid}  phoneNo=${CUSERPH0}  countryCode= ${country_code2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Update CustomerDetails-13
	[Documentation]  Update a valid customer with email
    ${resp}=  Encrypted Provider Login  ${PUSERNAME234}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable   ${gender}
    ${phone1}=  Evaluate  ${PUSERNAME23}+73012
    ${ph2}=  Evaluate  ${PUSERNAME230}+71013
    Set Suite Variable  ${email2}  ${firstname}${ph2}${C_Email}.${test_mail}
    ${resp}=  AddCustomer  ${phone1}   firstName=${firstname}   lastName=${lastname}  secondaryCountryCode=${countryCodes[0]}  secondaryPhoneNo=${ph2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()} 
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph2}${\n}
    Set Test Variable  ${cid2}  ${resp.json()}
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    # ${gender1}=  Random Element    ${Genderlist}
    ${ph3}=  Evaluate  ${PUSERNAME230}+71014
    Set Suite Variable  ${email3}  ${lastname}${ph3}${C_Email}.${test_mail}
    ${resp}=   UpdateCustomer with email  ${cid2}  ${firstname1}  ${lastname1}  ${EMPTY}  ${email3}  ${gender}  ${dob1}  ${ph3}  ${EMPTY}  secondaryCountryCode=${countryCodes[0]}  secondaryPhoneNo=${ph2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ncid}  ${resp.json()}
    Log  ${resp.json()}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph3}${\n}
    ${resp}=  GetCustomer  firstName-eq=${firstname1}  phoneNo-eq=${ph3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  firstName=${firstname1}  lastName=${lastname1}  phoneNo=${ph3}  dob=${dob1}  gender=${gender}   email=${email3}   email_verified=${bool[0]}   phone_verified=${bool[0]}   id=${cid2}   favourite=${bool[0]}

JD-TC-Update CustomerDetails-UH7
    [Documentation]  Add 2 customers with same number but different country code and update one customer phone number's country code to that of the other

    ${resp}=  Encrypted Provider Login  ${PUSERNAME53}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${bname}  ${resp.json()['businessName']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    # Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    clear_location   ${PUSERNAME53}
    clear_service    ${PUSERNAME53}
    clear_customer   ${PUSERNAME53}
    clear_provider_msgs  ${PUSERNAME53}

    ${PO_Number1}    Generate random string    5    0123456789
    ${PO_Number1}    Convert To Integer  ${PO_Number1}
    ${PO_Number2}    Generate random string    5    0123456789
    ${PO_Number2}    Convert To Integer  ${PO_Number2}
    ${country_code1}    Generate random string    2    0123456789
    ${country_code1}    Convert To Integer  ${country_code1}
     ${country_code2}    Generate random string    2    0123456778
    ${country_code2}    Convert To Integer  ${country_code2}
    
    ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${PO_Number1}
    # Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH0}${\n}
    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${resp}=   AddCustomer  ${CUSERPH0}  firstName=${fname}  lastName=${lname}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid0}  ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid0}


    FOR   ${i}  IN RANGE   5
        # ${PO_Number1}    Generate random string    8    0123456789
        # ${PO_Number1}    Convert To Integer  ${PO_Number1}
        # ${CUSERPH4}=  Evaluate  ${CUSERPH}+${PO_Number1}
        # ${PO_Number1}=  random_phone_num_generator
        ${PO_Number1}=  Get Random Valid Phone Number
        Log  ${PO_Number1}
        ${country_code1}=  Set Variable  ${PO_Number1.country_code}
        ${CUSERPH4}=  Set Variable  ${PO_Number1.national_number}
        ${keywordstatus} 	${value} = 	Run Keyword And Ignore Error   List Should Not Contain Value  ${numbers}  ${CUSERPH4}
        Log Many  ${keywordstatus} 	${value}
        Continue For Loop If  '${keywordstatus}' == 'FAIL'
        Run Keyword If  '${keywordstatus}' == 'PASS'  Append To List   ${numbers}  ${CUSERPH0}
        Exit For Loop IF   '${keywordstatus}' == 'PASS'
    END

   
    ${other_country_codes}=   random_country_codes  ${CUSERPH0}
    Log  ${other_country_codes}
    Log List  ${other_country_codes}
    Append To List  ${other_country_codes}  ${country_code1}
    ${unique_ccodes}=    Remove Duplicates    ${other_country_codes}
    Remove Values From List  ${unique_ccodes}  ${country_code1}
    ${country_code2}=  Evaluate  random.choice($unique_ccodes)  random
    Remove Values From List  ${unique_ccodes}  ${country_code2}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000



    ${fname1}=  FakerLibrary.first_name
    ${lname1}=  FakerLibrary.last_name
    ${resp}=   AddCustomer  ${CUSERPH0}  countryCode=${country_code2}  firstName=${fname1}  lastName=${lname1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid1}
    Should Be Equal As Strings  ${resp.json()[1]['id']}  ${cid0}

    ${resp}=  Update Customer Details  ${cid0}  phoneNo=${CUSERPH0}  countryCode=${country_code2}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
     

JD-TC-Update CustomerDetails-UH8
	[Documentation]  Try to Update a  customer with invalid second number
    ${resp}=  Encrypted Provider Login  ${PUSERNAME234}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable   ${gender}
    ${phone1}=  Evaluate  ${PUSERNAME23}+73013
    Set Suite Variable    ${phone1}  
    ${ph2}=  Evaluate  ${PUSERNAME230}+71013
    Set Suite Variable  ${email2}  ${firstname}${ph2}${C_Email}.${test_mail}
    ${resp}=  AddCustomer  ${phone1}   firstName=${firstname}   lastName=${lastname}  secondaryCountryCode=${countryCodes[0]}  secondaryPhoneNo=${ph2}
     Should Be Equal As Strings  ${resp.status_code}  200
     Log  ${resp.json()} 
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph2}${\n}
    Set Test Variable  ${cid2}  ${resp.json()}
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    # ${gender1}=  Random Element    ${Genderlist}
    ${ph3}=  FakerLibrary.RandomNumber  digits=9
    Set Suite Variable  ${email3}  ${lastname}${ph3}${C_Email}.${test_mail}
    ${resp}=   UpdateCustomer with email  ${cid2}  ${firstname1}  ${lastname1}  ${EMPTY}  ${email3}  ${gender}  ${dob1}  ${ph2}  ${EMPTY}  secondaryCountryCode=${countryCodes[0]}  secondaryPhoneNo=${ph3}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${INVALID_SPHONE}



JD-TC-Update CustomerDetails-14
    [Documentation]  update manual id of customer

    ${resp}=  Encrypted Provider Login  ${PUSERNAME234}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}
    
    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['jaldeeIdFormat']['customerSeriesEnum']}'=='${customerseries[0]}'
        ${resp}=  JaldeeId Format   ${customerseries[1]}   ${EMPTY}   ${EMPTY}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeIdFormat']['customerSeriesEnum']}  ${customerseries[1]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${cust_no}    FakerLibrary.Numerify   text=%######
    Set Test Variable  ${cust_no}  555${cust_no}
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${jaldeeid}=  Generate Random String  6  [LETTERS][NUMBERS]
    ${resp}=  AddCustomer  ${cust_no}   countryCode=${countryCodes[0]}  firstName=${firstname}   lastName=${lastname}  jaldeeId=${jaldeeid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer ById  ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeId']}  ${jaldeeid}

    ${jaldeeid2}=  Generate Random String  6  [LETTERS][NUMBERS]
    ${resp}=  Update Customer Details  ${cid}  jaldeeId=${jaldeeid2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${cust_no}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer ById  ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeId']}  ${jaldeeid2}
     