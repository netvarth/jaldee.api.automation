*** Settings ***
# Suite Teardown    Run Keywords  Delete All Sessions  resetsystem_time
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags      Queue
Library         Collections
Library         String
Library         json
Library           FakerLibrary
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
# Variables         /ebs/TDD/varfiles/consumermail.py 

*** Variables ***
${service_duration}   5   


*** Test Cases ***
JD-TC-Get Queue By Location and Service-1

	[Documentation]  get queue by service id and location id

    ${PUSERNAME_G}=  Evaluate  ${PUSERNAME}+55102040
    
    ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_G}=  Provider Signup  PhoneNumber=${PUSERNAME_G}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Test Variable   ${domain}  ${decrypted_data['sector']}
    Set Test Variable   ${subdomain}  ${decrypted_data['subSector']}
    Set Suite Variable    ${username}    ${decrypted_data['userName']}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_G}${\n}
    Set Suite Variable  ${PUSERNAME_G}

    ${accId}=  get_acc_id  ${PUSERNAME_G}
    Set Suite Variable  ${accId}  ${accId}

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

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz1}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz1}
    ${sTime}=  db.get_time_by_timezone  ${tz1}
    ${eTime}=  add_timezone_time  ${tz1}  0  30
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${loc_result} = 	Convert To Integer 	 ${resp.json()}
    Set Suite Variable  ${p1_l1}   ${loc_result}

    
    ${latti1}  ${longi1}  ${postcode1}  ${city1}  ${district}  ${state}  ${address1}=  get_loc_details
    ${tz2}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz2}
    ${sTime1}=  add_timezone_time  ${tz2}  0  30
    ${eTime1}=  add_timezone_time  ${tz2}  1  00
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']

    ${resp}=  Create Location  ${city1}  ${longi1}  ${latti1}  ${postcode1}  ${address1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${loc_result} = 	Convert To Integer 	 ${resp.json()}
    Set Suite Variable  ${p1_l2}   ${loc_result}

    ${P1SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}  ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s1}  ${resp.json()} 

    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s2}  ${resp.json()} 

    ${P1SERVICE3}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE3}
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE3}  ${desc}   ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s3}  ${resp.json()}

    ${sTime1}=  add_timezone_time  ${tz1}  1  00
    ${eTime1}=  add_timezone_time  ${tz1}  1  30
    ${p1queue1}=    FakerLibrary.word
    Set Suite Variable   ${p1queue1}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q1}  ${resp.json()}

    ${sTime2}=  add_timezone_time  ${tz1}  1  30
    ${eTime2}=  add_timezone_time   ${tz1}  2  00  
    ${p1queue2}=    FakerLibrary.word
    Set Suite Variable   ${p1queue2}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue2}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q2}  ${resp.json()} 

    ${sTime2}=  add_timezone_time  ${tz2}  2  00
    ${eTime2}=  add_timezone_time  ${tz2}  2  30
    ${p1queue3}=    FakerLibrary.word
    Set Suite Variable   ${p1queue3}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue3}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${capacity}  ${p1_l2}  ${p1_s3} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q3}  ${resp.json()}

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${CUSERNAME20}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cid}  ${resp.json()}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME20}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${CUSERNAME20}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${cid}  ${resp.json()['id']}  

    ${resp}=  Get Queue By Location and service  ${p1_l2}  ${p1_s2}  ${accId}       
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    

JD-TC-Get Queue By Location and Service-2

	[Documentation]  get queue by service id and location id  

    Comment  same service in diffrent queue    
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Queue By Location and service  ${p1_l1}  ${p1_s1}  ${accId}    
    Should Be Equal As Strings  ${resp.status_code}  200    
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${p1_q1} 
    Should Be Equal As Strings  ${resp.json()[0]['name']}  ${p1queue1} 
    Should Be Equal As Strings  ${resp.json()[1]['id']}  ${p1_q2} 
    Should Be Equal As Strings  ${resp.json()[1]['name']}  ${p1queue2}

JD-TC-Get Queue By Location and Service-3

	[Documentation]  get queue by service id and location id 
    Comment  same service in diffrent location

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Queue By Location and service  ${p1_l1}  ${p1_s2}  ${accId}       
    Should Be Equal As Strings  ${resp.status_code}  200     
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${p1_q2} 
    Should Be Equal As Strings  ${resp.json()[0]['name']}  ${p1queue2}

JD-TC-Get Queue By Location and Service-UH1

	[Documentation]  get queue by service id and location id 
    Comment  INPUT Disable SERVICE id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${RESP}=  Disable service  ${p1_s2} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Queue By Location and service  ${p1_l1}  ${p1_s2}  ${accId}    
    Should Be Equal As Strings  ${resp.status_code}  422  
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_SERVICE}"    

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable service  ${p1_s2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout

JD-TC-Get Queue By Location and Service-UH2

	[Documentation]  get queue by service id and location id 
    Comment  INPUT Disable queue

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${RESP}=  Disable Queue  ${p1_q3} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200   

    ${resp}=  Get Queue By Location and service  ${p1_l2}  ${p1_s3}  ${accId}        
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings  ${resp.json()}  []  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable service  ${p1_s2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout

JD-TC-Get Queue By Location and Service-UH3

	[Documentation]  get queue by service id and location id 
    Comment  INPUT Disable Location id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${RESP}=  Disable Location  ${p1_l2} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${p1_q3}  ${resp.json()}

    ${resp}=  Get Queue By Location and service  ${p1_l2}  ${p1_s2}  ${accId}      
    Should Be Equal As Strings  ${resp.status_code}  422   
    Should Be Equal As Strings  "${resp.json()}"  "${LOCATION_DISABLED}"  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${RESP}=  Enable Location  ${p1_l2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    
JD-TC-Get Queue By Location and Service-UH4

	[Documentation]  get queue by service id and location id 
    Comment  queue have no service

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${p1_q3}  ${resp.json()}

    ${resp}=  Get Queue By Location and service  ${p1_l2}  ${p1_s3}  ${accId}
    Should Be Equal As Strings  ${resp.json()}  []         
    Should Be Equal As Strings  ${resp.status_code}  200       




