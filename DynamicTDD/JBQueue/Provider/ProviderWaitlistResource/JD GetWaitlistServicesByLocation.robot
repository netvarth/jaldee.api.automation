*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags      Service
Library         Collections
Library         String
Library         json
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
*** Variables ***
${service_duration}   5  


*** Test Cases ***
JD-TC-Get Waitlist Service By Location -1

	[Documentation]  Get service by location id

    ${firstname}  ${lastname}  ${PUSERNAME_G}  ${LoginId}=  Provider Signup
    Set Suite Variable  ${PUSERNAME_G}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${ph1}=  Evaluate  ${PUSERNAME_G}+15566124
    # ${ph2}=  Evaluate  ${PUSERNAME_G}+25566128
    # ${views}=  Random Element    ${Views}
    # ${name1}=  FakerLibrary.name
    # ${name2}=  FakerLibrary.name
    # ${name3}=  FakerLibrary.name
    # ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    # ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    # ${emails1}=  Emails  ${name3}  Email  ${P_Email}${PUSERNAME_G}.${test_mail}  ${views}
    # ${bs}=  FakerLibrary.bs
    # ${city}=   FakerLibrary.state

    # ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    # ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    # Set Suite Variable  ${tz}
    # ${parking}   Random Element   ${parkingType}
    # ${24hours}    Random Element    ${bool}
    # ${desc}=   FakerLibrary.sentence
    # ${url}=   FakerLibrary.url
    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${sTime}=  db.add_timezone_time  ${tz}  0  15
    # ${eTime}=  db.add_timezone_time  ${tz}   0  45
    # ${resp}=  Update Business Profile with Schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Business Profile
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    # Log  ${fields.json()}
    # Should Be Equal As Strings    ${fields.status_code}   200

    # ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    # ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # ${spec}=  get_Specializations  ${resp.json()}
    # ${resp}=  Update Specialization  ${spec}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

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

    ${DAY}=  db.add_timezone_date  ${tz}  0   
    Set Suite Variable  ${DAY} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}

    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  db.add_timezone_time  ${tz}  0  30
    # ${city}=   get_place
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}   ${postcode}  ${address}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l1}  ${resp.json()}

    ${sTime1}=  db.add_timezone_time  ${tz}  0  30
    ${eTime1}=  db.add_timezone_time  ${tz}  1  00
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}   ${postcode}  ${address}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l2}  ${resp.json()}

    ${P1SERVICE1}=    generate_service_name
    Set Suite Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}     ${bool[0]}    ${servicecharge}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s1}  ${resp.json()}

    ${P1SERVICE2}=    generate_service_name
    Set Suite Variable  ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}      ${bool[0]}    ${servicecharge}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s2}  ${resp.json()}

    ${P1SERVICE3}=    generate_service_name
    Set Suite Variable   ${P1SERVICE3}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE3}  ${desc}   ${service_duration}      ${bool[0]}    ${servicecharge}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s3}  ${resp.json()}

    ${sTime1}=  db.add_timezone_time  ${tz}  1  00
    ${eTime1}=  db.add_timezone_time  ${tz}  1  30
    ${p1queue1}=    FakerLibrary.word
    Set Suite Variable   ${p1queue1}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q1}  ${resp.json()}

    ${sTime2}=  db.add_timezone_time  ${tz}  1  30
    ${eTime2}=  db.add_timezone_time  ${tz}  2  00
    ${p1queue2}=    FakerLibrary.word
    Set Suite Variable   ${p1queue2}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue2}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${capacity}  ${p1_l2}  ${p1_s2}  ${p1_s3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q2}  ${resp.json()}

    ${resp}=  Get waitlist Service By Location  ${p1_l1}
    Log   ${resp.json()}
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

JD-TC-Get Waitlist Service By Location -2
	[Documentation]  Get service by another location id  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get waitlist Service By Location     ${p1_l2}
    Log   ${resp.json()}
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

JD-TC-Get Waitlist Service By Location -3
	[Documentation]  Get service by location id  here disable one service

    Comment  service Disable   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable service  ${p1_s1} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get waitlist Service By Location  ${p1_l1}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${p1_s3}
    Should Be Equal As Strings  ${resp.json()[0]['name']}  ${P1SERVICE3}

    ${resp}=  Enable service  ${p1_s1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Get Waitlist Service By Location-UH1
	[Documentation]  Get service  by disabled location id 

    Comment  INPUT Disable Location id
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Location  ${p1_l2} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get waitlist Service By Location  ${p1_l2}  
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${LOCATION_DISABLED}"  

    ${resp}=  Enable Location  ${p1_l2} 
    Should Be Equal As Strings  ${resp.status_code}  200
        
JD-TC-Get Waitlist Service By Location-UH2

    [Documentation]  Consumer get Service By LocationId .

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${account_id}=  get_acc_id  ${HLPUSERNAME25}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
    Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}

    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Send Otp For Login    ${PCPHONENO}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}
    
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get waitlist Service By Location  ${p1_l2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-Get Waitlist Service By Location-UH3

    [Documentation]  provider get Service By LocationId without login.

    ${resp}=    Get waitlist Service By Location   ${p1_l2}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-Get Waitlist Service By Location-UH4

    [Documentation]  Trying to provider get Service By LocationId, with an invalid location.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get waitlist Service By Location   0
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   404
    Should Be Equal As Strings  "${resp.json()}"       "${LOCATION_NOT_FOUND}"

    

 