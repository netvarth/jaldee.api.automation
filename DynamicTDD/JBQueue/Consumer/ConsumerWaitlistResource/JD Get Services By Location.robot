*** Settings ***
# Suite Teardown    Run Keywords  Delete All Sessions  resetsystem_time
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags      Service
Library         Collections
Library         String
Library         json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
# Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***

${service_duration}   5  
@{emptylist} 
@{service_names}


*** Test Cases ***

JD-TC-Get WL Service By Location -1

	[Documentation]  get service  location id

    ${PUSERNAME_G}=  Evaluate  ${PUSERNAME}+8957489
    
    ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_G}=  Provider Signup  PhoneNumber=${PUSERNAME_G}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Test Variable   ${domain}  ${decrypted_data['sector']}
    Set Test Variable   ${subdomain}  ${decrypted_data['subSector']}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_G}${\n}
    Set Suite Variable  ${PUSERNAME_G}

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${spec1}     ${resp.json()[0]['displayName']}   
    Set Test Variable    ${spec2}     ${resp.json()[1]['displayName']}   

    ${spec}=  Create List    ${spec1}   ${spec2}

    ${resp}=  Update Business Profile with kwargs  specialization=${spec}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Test Variable  ${email_id}  ${P_Email}${PUSERNAME_G}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${pid}=  get_acc_id  ${PUSERNAME_G}
    Set Suite Variable  ${pid}  
    Should Be Equal As Strings    ${resp.status_code}   200

    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz1}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz1}
    ${DAY}=  db.get_date_by_timezone  ${tz}   
    Set Suite Variable  ${DAY} 
    # ${sTime}=  db.get_time_by_timezone   ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz1}
    ${eTime}=  add_timezone_time  ${tz1}  0  30
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l1}  ${resp.json()}

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz2}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz2}
    ${sTime1}=  add_timezone_time  ${tz}  0  30  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l2}  ${resp.json()}

    ${P1SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${P1SERVICE1}
    Set Suite Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}  ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s1}  ${resp.json()}

    ${P1SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${P1SERVICE2}
    Set Suite Variable  ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s2}  ${resp.json()}

    ${P1SERVICE3}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${P1SERVICE3}
    Set Suite Variable   ${P1SERVICE3}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE3}  ${desc}   ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s3}  ${resp.json()}

    ${sTime1}=  add_timezone_time  ${tz1}  1  00
    ${eTime1}=  add_timezone_time  ${tz1}  1  30
    ${p1queue1}=    FakerLibrary.word
    Set Suite Variable   ${p1queue1}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q1}  ${resp.json()}

    ${sTime2}=  add_timezone_time  ${tz2}  1  30
    ${eTime2}=  add_timezone_time  ${tz2}  2  00
    ${p1queue2}=    FakerLibrary.word
    Set Suite Variable   ${p1queue2}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue2}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${capacity}  ${p1_l2}  ${p1_s2}  ${p1_s3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q2}  ${resp.json()}
    

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${CUSERNAME2}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cid}  ${resp.json()}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME2}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME2}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME2}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${resp}=   Get WL Service By Location  ${p1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${length}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE  ${length}
        Run Keyword IF   '${resp.json()[${i}]['id']}' == '${p1_s1}'
        ...    Run Keywords 
        ...    Should Be Equal As Strings  ${resp.json()[${i}]['id']}  ${p1_s1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['name']}  ${P1SERVICE1}
        ...    ELSE IF   '${resp.json()[${i}]['id']}' == '${p1_s3}' 
        ...    Run Keywords 
        ...    Should Be Equal As Strings  ${resp.json()[${i}]['id']}  ${p1_s3}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['name']}  ${P1SERVICE3}
    END


JD-TC-Get WL Service By Location -2

	[Documentation]  get service  location id 

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME2}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get WL Service By Location  ${p1_l2}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${length}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE  ${length}
        Run Keyword IF   '${resp.json()[${i}]['id']}' == '${p1_s2}'
        ...    Run Keywords 
        ...    Should Be Equal As Strings  ${resp.json()[${i}]['id']}  ${p1_s2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['name']}  ${P1SERVICE2}
        ...    ELSE IF   '${resp.json()[${i}]['id']}' == '${p1_s3}' 
        ...    Run Keywords 
        ...    Should Be Equal As Strings  ${resp.json()[${i}]['id']}  ${p1_s3}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['name']}  ${P1SERVICE3}
    END
    

JD-TC-Get WL Service By Location -3
	[Documentation]  get service  location id 
    Comment  service Disable   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable service  ${p1_s1} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME2}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get WL Service By Location  ${p1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${p1_s3}
    Should Be Equal As Strings  ${resp.json()[0]['name']}  ${P1SERVICE3}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable service  ${p1_s1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout

JD-TC-Get Queue By Location and Service-UH2
	[Documentation]  get queue by service id and location id 
    Comment  INPUT Disable Location id
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Location  ${p1_l2} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME2}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get WL Service By Location  ${p1_l2}  
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${LOCATION_DISABLED}"  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Location  ${p1_l2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogout     



