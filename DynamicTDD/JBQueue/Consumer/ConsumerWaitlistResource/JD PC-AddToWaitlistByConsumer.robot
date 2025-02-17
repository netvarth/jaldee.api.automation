*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Waitlist
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
# Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***

${digits}       0123456789
${self}     0
@{service_names}
@{service_duration}  5  10
${parallel}     1

***Keywords***

Get Billable Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Test Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Should Be Equal As Strings    ${resp.status_code}    200
            Exit For Loop IF  '${resp.json()['serviceBillable']}' == 'True'
    END
    RETURN  ${subdomain}  ${resp.json()['serviceBillable']}


*** Test Cases ***


JD-TC-Add To WaitlistByConsumer-1

	[Documentation]  Consumer joins waitlist of a valid provider.

    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+100100301
    Set Suite Variable      ${PUSERPH0}

    ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERPH0}=  Provider Signup  PhoneNumber=${PUSERPH0}
 
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    Set Test Variable  ${firstname}  ${decrypted_data['firstName']}
    Set Test Variable  ${lastname}  ${decrypted_data['lastName']}
    Set Test Variable   ${domain}  ${decrypted_data['sector']}
    Set Test Variable   ${subdomain}  ${decrypted_data['subSector']}
    Set Suite Variable    ${username}    ${decrypted_data['userName']}
    
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+100100302
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH1}${\n}
    
    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+100100303
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH2}${\n}
    
    ${PUSERMAIL0}=   Set Variable  ${P_Email}ph301.${test_mail}
    ${views}=  Evaluate  random.choice($Views)  random
    Log   ${views}
  
    Set Test Variable  ${email_id}  ${P_Email}${PUSERPH0}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${emptylist}=  Create List
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${fname}=  generate_firstname
        ${lname}=  FakerLibrary.last_name
        ${resp1}=  AddCustomer  ${CUSERNAME5} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid5}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid5}  ${resp.json()[0]['id']}
    END

    ${resp}=  Get Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enabledWaitlist']}==${bool[0]}   
        ${resp}=   Enable Waitlist
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enabledWaitlist']}   ${bool[1]}

    sleep   01s

    ${turn_arnd_time}=   Random Int  min=2   max=10
    Set Suite Variable   ${turn_arnd_time}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePresence']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${bool[1]}  ${EMPTY}  ${EMPTY}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}   
    

    ${pid0}=  get_acc_id  ${PUSERPH0}

    # ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    # ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    # Set Suite Variable  ${tz}
    # ${parking}    Random Element     ${parkingType} 
    # ${24hours}    Random Element    ['True','False']
    # ${list}=  Create List  1  2  3  4  5  6  7 
    # ${DAY}=  get_date_by_timezone  ${tz}
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    # ${eTime}=  add_timezone_time  ${tz}  0  15  
    # ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${p1_l1}  ${resp.json()}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${loc_id1}=  Create Sample Location
        Set Suite Variable   ${loc_id1}
        ${resp}=   Get Location ById  ${loc_id1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
        Set Suite Variable  ${p1_l1}  ${resp.json()['id']}
    ELSE
        Set Suite Variable  ${p1_l1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${words}=    FakerLibrary.Words    nb=${10}
    ${unique_words}=    Remove Duplicates    ${words}
    
    ${P1SERVICE1}=  generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${P1SERVICE1}
    Set Suite Variable   ${P1SERVICE1}
    ${p1_s1}=  Create Sample Service  ${P1SERVICE1}     maxBookingsAllowed=40
    Set Suite Variable  ${p1_s1}
    # ${P1SERVICE1}=  Set Variable  ${unique_words[0]}
    # ${desc}=   FakerLibrary.sentence
    # ${servicecharge}=   Random Int  min=100  max=500
    # ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration[0]}  ${bool[0]}    ${servicecharge}    ${bool[0]}  
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${p1_s1}  ${resp.json()}
    
    # ${P1SERVICE2}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${P1SERVICE2}
    # ${P1SERVICE2}=  Set Variable  ${unique_words[1]}
    # Set Suite Variable   ${P1SERVICE2}
    # ${desc}=   FakerLibrary.sentence
    # Set Suite Variable  ${desc}
    # ${servicecharge}=   Random Int  min=100  max=500
    # ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration[0]}  ${bool[0]}    ${servicecharge}    ${bool[0]}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${p1_s2}  ${resp.json()}
    ${P1SERVICE2}=  generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${P1SERVICE2}
    Set Suite Variable   ${P1SERVICE2}
    ${p1_s2}=  Create Sample Service  ${P1SERVICE2}     maxBookingsAllowed=40
    Set Suite Variable  ${p1_s2}

    ${list}=  Create List  1  2  3  4  5  6  7 
    ${DAY}=  get_date_by_timezone  ${tz} 
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  4  30  
    # ${p1queue1}=    FakerLibrary.word
    ${p1queue1}=  Set Variable  ${unique_words[2]}
    ${capacity}=  FakerLibrary.Numerify  %%
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel[0]}  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2} 
    Log  ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_q1}  ${resp.json()}
    
    # ${sTime2}=  add_timezone_time  ${tz}  0  45  
    # ${eTime2}=  add_timezone_time  ${tz}  2  30  
    ${sTime2}=  add_timezone_time  ${tz}  1  45  
    ${eTime2}=  add_timezone_time  ${tz}  2  30  
    # ${p1queue2}=    FakerLibrary.word
    ${p1queue2}=  Set Variable  ${unique_words[3]}
    ${capacity}=  FakerLibrary.Numerify  %%
    ${resp}=  Create Queue  ${p1queue2}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel[0]}  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2} 
    Log  ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q2}  ${resp.json()}
    
    ${resp}=    Enable Search Data
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=    Send Otp For Login    ${CUSERNAME5}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login  ${CUSERNAME5}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME5}
    
    # ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME5}    ${pid0}    ${token}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    # Set Test Variable    ${cid}   ${resp.json()['id']} 
    
    # ${cid}=  get_id  ${CUSERNAME5} 
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid5}  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcons_id1}  ${resp.json()[0]['id']}

    ${resp}=  ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id1}  
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}

JD-TC-Add To WaitlistByConsumer-2

	[Documentation]  Provider removes consumer waitlisted for a service and consumer joins the waitlist of the same service and another service of same queue
    
    # clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    # ${cid}=  get_id  ${CUSERNAME5}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Location ById  ${p1_l1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${CUSERNAME5}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login  ${CUSERNAME5}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    clear_Consumermsg  ${CUSERNAME5}
    
    
    # ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME5}    ${pid0}    ${token}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    # # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    # Set Test Variable    ${cid}   ${resp.json()['id']}   
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}     waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=   FakerLibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action   ${waitlist_actions[2]}  ${wid1}  cancelReason=${waitlist_cancl_reasn[4]}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
  
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=    Send Otp For Login    ${CUSERNAME5}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login  ${CUSERNAME5}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME5}
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']} 

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200    
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id  ${wid1}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}
    
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}   ${p1_q1}  ${DAY}  ${p1_s2}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${pid0}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}


JD-TC-Add To WaitlistByConsumer-3

	[Documentation]  consumer cancels the waitlist then consumer gets waitlisted for the same service again

    # # clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME5}
    ${resp}=    Send Otp For Login    ${CUSERNAME5}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME5}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME5}
    
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    # ${DAY}=  db.get_date_by_timezone  ${tz}  
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id1} 
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}    
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}

    ${resp}=  Cancel Waitlist  ${wid1}  ${pid0}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]} 

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id1}   
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}   
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}

JD-TC-Add To WaitlistByConsumer-4
	[Documentation]  A Consumer Added To Waitlist for same service in diffrent queue
    # # clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME5}

    ${resp}=    Send Otp For Login    ${CUSERNAME5}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login  ${CUSERNAME5}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME5}
    
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}  

    # ${DAY}=  db.get_date_by_timezone  ${tz}
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200   
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id1}  
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}
    
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q2}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]} 
    
    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${pid0}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id1} 
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q2}
    
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}

    ${resp}=  Cancel Waitlist  ${wid1}  ${pid0}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Cancel Waitlist  ${wid2}  ${pid0}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Comment  DELETED ALL WAITLIST OF  ${CUSERNAME5} 



JD-TC-Add To WaitlistByConsumer-5
	[Documentation]  Consumer Added To Waitlist for diffrent services of diffrent Queue   
    # clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME5}
    ${resp}=    Send Otp For Login    ${CUSERNAME5}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME5}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME5}
    
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}  

    # ${DAY}=  db.get_date_by_timezone  ${tz}
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word 
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id1} 
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}
    
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q2}  ${DAY}  ${p1_s2}  ${cnote}  ${bool[0]}  ${self} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${pid0}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s2}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id1} 
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q2}
    
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}



JD-TC-Add To WaitlistByConsumer-6
    [Documentation]  Add Consumer To future waitlist 
    # clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME5}
    # ${TOMORROW}=  db.add_timezone_date  ${tz}  3  
    ${TOMORROW}=  db.add_timezone_date  ${tz}  3

    ${resp}=    Send Otp For Login    ${CUSERNAME5}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME5}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME5}
    
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}  
     
    ${cnote}=   FakerLibrary.word  
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${TOMORROW}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${pid0}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${TOMORROW}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}
    
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}




JD-TC-Add To WaitlistByConsumer-7
    [Documentation]  Add  Consumer To waitlist for another service in same queue
    # clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME5}
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}

     ${resp}=    Send Otp For Login    ${CUSERNAME5}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME5}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME5}
    
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}  
       
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s2}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]} 

    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${pid0}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s2}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}
    
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}


# *** Comments ***

JD-TC-Add To WaitlistByConsumer-8
    [Documentation]  Add Consumer to Future waitlist of two queues for same service
    # clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME5}
    # ${TOMORROW}=  db.add_timezone_date  ${tz}  3  
    ${TOMORROW}=  db.add_timezone_date  ${tz}  3
     ${resp}=    Send Otp For Login    ${CUSERNAME5}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME5}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME5}
    
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}  
       
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${TOMORROW}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]} 

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${TOMORROW}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}
    
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}


    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q2}  ${TOMORROW}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]} 

    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${pid0}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${TOMORROW}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q2}
    
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}


    

JD-TC-Add To WaitlistByConsumer-9
    [Documentation]   future waitlist consumer waitlisted in diffrent service in diffrent queue
    # clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME5}
    # ${TOMORROW}=  db.add_timezone_date  ${tz}  3  
    ${TOMORROW}=  db.add_timezone_date  ${tz}  3

     ${resp}=    Send Otp For Login    ${CUSERNAME5}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME5}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME5}
    
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}  

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${TOMORROW}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${TOMORROW}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}
    
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q2}  ${TOMORROW}  ${p1_s2}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]} 

    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${pid0}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${TOMORROW}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s2}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q2}
    
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}



JD-TC-Add To WaitlistByConsumer-10
    [Documentation]  provider have two location add , consumer waitlist same service in different Location
    # clear waitlist   ${PUSERPH0}
    # clear_queue  ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME5}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
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
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${p1_l2}=  Create Sample Location
    Set Suite Variable   ${p1_l2}   

    ${p1queue2}=    FakerLibrary.word
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}
    # ${sTime2}=  add_timezone_time  ${tz}  2  45  
    # ${eTime2}=  add_timezone_time  ${tz}  3  15  
    ${sTime2}=  add_timezone_time  ${tz}  2  45
    ${eTime2}=  add_timezone_time  ${tz}  3  15  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${capacity}=  FakerLibrary.Numerify  %%
    ${resp}=  Create Queue  ${p1queue2}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel[0]}  ${capacity}  ${p1_l2}  ${p1_s1}  ${p1_s2} 
    Log  ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q3}  ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=    Send Otp For Login    ${CUSERNAME5}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME5}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME5}
    
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}  

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s2}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]} 

    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${pid0}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s2}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}   ${p1_q3}  ${DAY}  ${p1_s2}  ${cnote}  ${bool[0]}  ${self}  location=${p1_l2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]} 

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s2}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q3}
    
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l2}




JD-TC-Add To WaitlistByConsumer-11
    [Documentation]  waitlist for Family Members
    # clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    # ${cid}=  get_id  ${CUSERNAME5}
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}

    ${resp}=    Send Otp For Login    ${CUSERNAME5}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME5}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${cid}  ${resp.json()['providerConsumer']}
    # clear_Consumermsg  ${CUSERNAME5}
    
    
    # ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME5}    ${pid0}    ${token}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    # # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    # Set Test Variable    ${cid}   ${resp.json()['id']}  


    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}

    ${resp}=  Add FamilyMember For ProviderConsumer     ${firstname}  ${lastname}  ${dob}  ${gender} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    # ${resp}=  Add FamilyMember For ProviderConsumer   ${firstname}  ${lastname}  ${dob}  ${gender}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${cidfor}   ${resp.json()}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${cidfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]} 

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}

JD-TC-Add To WaitlistByConsumer-12
    [Documentation]  Future waitlist add family member
    # clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME5}
    # ${TOMORROW}=  db.add_timezone_date  ${tz}  3  
    ${TOMORROW}=  db.add_timezone_date  ${tz}  3

    ${resp}=    Send Otp For Login    ${CUSERNAME5}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME5}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME5}
    
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}  


    ${firstname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Add FamilyMember For ProviderConsumer   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${cidfor}   ${resp.json()}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${TOMORROW}  ${p1_s2}  ${cnote}  ${bool[0]}  ${cidfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]} 

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${TOMORROW}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}

JD-TC-Add To WaitlistByConsumer-13
    [Documentation]  same family member add to waitlist  diffrent service  same queue
    # clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME5}
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}

     ${resp}=    Send Otp For Login    ${CUSERNAME5}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME5}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME5}
    
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}  


    ${firstname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Add FamilyMember For ProviderConsumer   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${cidfor}   ${resp.json()}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${cidfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s2}  ${cnote}  ${bool[0]}  ${cidfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200     
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
 
    ${resp}=  Get consumer Waitlist By Id  ${wid1}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}
    
JD-TC-Add To WaitlistByConsumer-14

    [Documentation]  same family member add to waitlist  same service  diffrent queue

    # clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME5}
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}

     ${resp}=    Send Otp For Login    ${CUSERNAME5}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME5}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME5}
    
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}  


    ${firstname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Add FamilyMember For ProviderConsumer   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${cidfor}   ${resp.json()}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${cidfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}

    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}   ${p1_q2}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${cidfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200     
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
 
    ${resp}=  Get consumer Waitlist By Id  ${wid1}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q2}  
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}    

JD-TC-Add To WaitlistByConsumer-15
    [Documentation]  Consumer future waitlist  diffrent location , same service ,same provider
    # clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME5}
    # ${TOMORROW}=  db.add_timezone_date  ${tz}  3  
    ${TOMORROW}=  db.add_timezone_date  ${tz}  3

     ${resp}=    Send Otp For Login    ${CUSERNAME5}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME5}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME5}
    
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}  
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${TOMORROW}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200    
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]} 

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${TOMORROW}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}
    
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q3}  ${TOMORROW}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200    
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]} 

    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${pid0}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${TOMORROW}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q3}
    
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l2}



JD-TC-Add To WaitlistByConsumer-16
    [Documentation]  Consumer future waitlist remove himself and again add for same service
    # clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME5}
    # ${TOMORROW}=  db.add_timezone_date  ${tz}  3  
    ${TOMORROW}=  db.add_timezone_date  ${tz}  3

     ${resp}=    Send Otp For Login    ${CUSERNAME5}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME5}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME5}
    
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}  

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${TOMORROW}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200    
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]} 

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${TOMORROW}  waitlistStatus=${wl_status[0]}     waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}
    
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}

    ${resp}=  Cancel Waitlist  ${wid1}  ${pid0}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${TOMORROW}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200    
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${widcalcel}  ${wid[0]} 

    ${resp}=  Get consumer Waitlist By Id   ${widcalcel}  ${pid0}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${TOMORROW}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id1} 
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}
    
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}



JD-TC-Add To WaitlistByConsumer-17
    [Documentation]  Consumer future waitlist remove by provider and again add same service
    # clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME5}
    # ${TOMORROW}=  db.add_timezone_date  ${tz}  3  
    ${TOMORROW}=  db.add_timezone_date  ${tz}  3

     ${resp}=    Send Otp For Login    ${CUSERNAME5}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME5}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME5}
    
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}  
 
       
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${TOMORROW}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid25}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid25}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${TOMORROW}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=   FakerLibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action  ${waitlist_actions[2]}  ${wid25}  cancelReason=${waitlist_cancl_reasn[4]}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME5}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${TOMORROW}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200    
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid26}  ${wid[0]} 
    sleep  2s
    ${resp}=  Get consumer Waitlist By Id   ${wid26}  ${pid0}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${TOMORROW}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}   
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}

JD-TC-Add To WaitlistByConsumer-UH1

	[Documentation]  Add To Waitlist By Consumer for the Same Services Two Times

    # clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME5}

     ${resp}=    Send Otp For Login    ${CUSERNAME5}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME5}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME5}
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}  
 

    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}  
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid55}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid55}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id1} 
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l1}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}   ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}      
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"   "${WAITLIST_CUSTOMER_ALREADY_IN}" 

    ${resp}=  Cancel Waitlist  ${wid55}  ${pid0}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Comment  delete all waitlist of  ${CUSERNAME5} its used in anoter test case  



JD-TC-Add To WaitlistByConsumer-18
    [Documentation]   Add a consumer to the same queue for the same Pre_Payment service repeatedly
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid0}=  get_acc_id  ${PUSERPH0}
    # clear waitlist   ${PUSERPH0}
    clear_customer   ${PUSERPH0}
    
    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    Set Suite Variable   ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}
    ${servicecharge2}=   Random Int  min=100  max=500
    Set Suite Variable   ${servicecharge2}
    Set Suite Variable   ${min_pre2}   ${servicecharge2}
    ${Total2}=  Convert To Number  ${servicecharge2}  1 
    Set Suite Variable   ${Total22}   ${Total2}
    ${amt_float2}=  twodigitfloat  ${Total22}
    Set Suite Variable  ${amt_float2} 
    ${servicecharge}=   Random Int  min=100  max=500

    ${Sid1_s1}=   Create Sample Service  ${SERVICE1}   isPrePayment=${bool[1]}   minPrePaymentAmount=${min_pre2}   
    # ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${service_duration[1]}  ${bool[1]}    ${servicecharge}  ${bool[0]}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Sid1_s1} 

    ${sTime1}=  get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  4  30  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${queue1}=    generate_firstname
    
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1   5   ${p1_l2}  ${Sid1_s1}
    Log  ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${qid1}  ${resp.json()}

    ${fname}=  generate_firstname
    Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}
    ${resp}=  AddCustomer  ${CUSERNAME18}     email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid18}  ${resp.json()}

    ${fname}=  generate_firstname
    Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}
    ${resp}=  AddCustomer  ${CUSERNAME15}     email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid15}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid18}  ${Sid1_s1}  ${qid1}  ${DAY}  ${desc}  ${bool[1]}  ${cid18} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Add To Waitlist  ${cid18}  ${Sid1_s1}  ${qid1}  ${DAY}  ${desc}  ${bool[1]}  ${cid18} 
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"    	"${WAITLIST_CUSTOMER_ALREADY_IN}"

     ${resp}=    Send Otp For Login    ${CUSERNAME15}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME15}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME15}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME15}
    
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME15}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid15}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid15}   ${resp.json()['id']}  
 
    ${cid15}=  get_id  ${CUSERNAME15}

    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}  
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers   ${cid15}  ${pid0}  ${qid1}  ${DAY}  ${Sid1_s1}  ${cnote}  ${bool[0]}  ${self} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid15}  ${wid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcons_id2}  ${resp.json()[0]['id']}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME15}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get consumer Waitlist By Id   ${wid15}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[3]}  waitlistedBy=PROVIDER_CONSUMER
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${Sid1_s1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2} 
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${qid1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l2}

    ${resp}=  Add To Waitlist Consumers     ${cid15}  ${pid0}   ${qid1}  ${DAY}  ${Sid1_s1}  ${cnote}  ${bool[0]}  ${self}      
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid16}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid16}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[3]}  waitlistedBy=PROVIDER_CONSUMER
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${Sid1_s1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2} 
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${qid1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l2}

    ${resp}=  Get consumer Waitlist By Id   ${wid15}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[7]}  waitlistedBy=PROVIDER_CONSUMER
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${Sid1_s1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2} 
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${qid1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l2}

    ${resp}=  Add To Waitlist Consumers     ${cid15}  ${pid0}   ${qid1}  ${DAY}  ${Sid1_s1}  ${cnote}  ${bool[0]}  ${self}      
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid17}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid17}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[3]}  waitlistedBy=PROVIDER_CONSUMER
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${Sid1_s1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2} 
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${qid1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l2}

    ${resp}=  Get consumer Waitlist By Id   ${wid16}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[7]}  waitlistedBy=PROVIDER_CONSUMER
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${Sid1_s1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id2} 
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${qid1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l2}


JD-TC-Add To WaitlistByConsumer-19
    [Documentation]   Add a family member to the same queue for the same Pre_Payment service repeatedly
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid0}=  get_acc_id  ${PUSERPH0}
    # clear waitlist   ${PUSERPH0}
    clear_customer   ${PUSERPH0}

    ${desc}=   FakerLibrary.sentence
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}

    ${fname}=  generate_firstname
    Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}
    ${resp}=  AddCustomer  ${CUSERNAME20}     email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid20}  ${resp.json()}

    ${fname}=  generate_firstname
    Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}
    ${resp}=  AddCustomer  ${CUSERNAME25}     email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid25}  ${resp.json()}

    ${firstname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    ${gender1}=  Random Element    ${Genderlist}
    ${resp}=  Add FamilyMemberByProvider  ${cid20}  ${firstname}  ${lastname}  ${dob1}  ${gender1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id_p1}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid20}  ${Sid1_s1}  ${qid1}  ${DAY}  ${desc}  ${bool[1]}  ${mem_id_p1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Add To Waitlist  ${cid20}  ${Sid1_s1}  ${qid1}  ${DAY}  ${desc}  ${bool[1]}  ${mem_id_p1} 
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"    	"${WAITLIST_CUSTOMER_ALREADY_IN}"


    # ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200 
    # ${cid25}=  get_id  ${CUSERNAME25}

     ${resp}=    Send Otp For Login    ${CUSERNAME25}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME25}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME25}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME25}
    
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME25}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid25}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid25}   ${resp.json()['id']}  

    ${family_fname}=  generate_firstname
    ${family_lname}=  FakerLibrary.last_name
    ${dob2}=  FakerLibrary.Date
    ${gender2}    Random Element    ${Genderlist}
    ${resp}=  Add FamilyMember For ProviderConsumer   ${family_fname}  ${family_lname}  ${dob2}  ${gender2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${cidfor_c1}   ${resp.json()}

    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}  
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid25}  ${pid0}  ${qid1}  ${DAY}  ${Sid1_s1}  ${cnote}  ${bool[0]}  ${cidfor_c1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid19}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid19}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[3]}  waitlistedBy=PROVIDER_CONSUMER
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${Sid1_s1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${qid1}

    ${resp}=  Add To Waitlist Consumers  ${cid25}  ${pid0}   ${qid1}  ${DAY}  ${Sid1_s1}  ${cnote}  ${bool[0]}  ${cidfor_c1}      
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid20}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid20}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[3]}  waitlistedBy=PROVIDER_CONSUMER
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${Sid1_s1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${qid1}
    ${resp}=  Get consumer Waitlist By Id   ${wid19}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[7]}  waitlistedBy=PROVIDER_CONSUMER
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${Sid1_s1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${qid1}

    ${resp}=  Add To Waitlist Consumers  ${cid25}  ${pid0}   ${qid1}  ${DAY}  ${Sid1_s1}  ${cnote}  ${bool[0]}  ${cidfor_c1}      
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid21}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid21}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[3]}  waitlistedBy=PROVIDER_CONSUMER
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${Sid1_s1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${qid1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l2}
    
    ${resp}=  Get consumer Waitlist By Id   ${wid20}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[7]}  waitlistedBy=PROVIDER_CONSUMER
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${Sid1_s1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${qid1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l2}

JD-TC-Add To WaitlistByConsumer-20
    [Documentation]   Add a consumer and his family member to the same queue for the same Pre_Payment service repeatedly
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid0}=  get_acc_id  ${PUSERPH0}
    # clear waitlist   ${PUSERPH0}

    ${desc}=   FakerLibrary.sentence
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  db.add_timezone_date  ${tz}  4  

    ${fname}=  generate_firstname
    Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}
    ${resp}=  AddCustomer  ${CUSERNAME30}      email=${pc_emailid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid30}  ${resp.json()}

    ${fname}=  generate_firstname
    Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}
    ${resp}=  AddCustomer  ${CUSERNAME35}       email=${pc_emailid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid35}  ${resp.json()}

    ${firstname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${resp}=  Add FamilyMemberByProvider  ${cid30}  ${firstname}  ${lastname}  ${dob}  ${gender}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id_p2}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${mem_id_p2}  ${Sid1_s1}  ${qid1}  ${DAY}  ${desc}  ${bool[1]}  ${mem_id_p2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Add To Waitlist  ${cid30}  ${Sid1_s1}  ${qid1}  ${DAY}  ${desc}  ${bool[1]}  ${cid30} 
    Should Be Equal As Strings  ${resp.status_code}  200


     ${resp}=    Send Otp For Login    ${CUSERNAME35}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME35}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME35}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME35}

    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME35}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid35}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid35}   ${resp.json()['id']}  

    ${family_fname}=  generate_firstname
    ${family_lname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Add FamilyMember For ProviderConsumer   ${family_fname}  ${family_lname}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${cidfor_c2}   ${resp.json()}

    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  db.add_timezone_date  ${tz}  1 
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers     ${cid35}  ${pid0}  ${qid1}  ${DAY}  ${Sid1_s1}  ${cnote}  ${bool[0]}  ${cidfor_c2} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid25}  ${wid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME35}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcons_id5}  ${resp.json()[1]['id']}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME35}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get consumer Waitlist By Id   ${wid25}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[3]}  waitlistedBy=PROVIDER_CONSUMER
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${Sid1_s1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${qid1}

  
    ${resp}=  Add To Waitlist Consumers     ${cid35}  ${pid0}   ${qid1}  ${DAY}  ${Sid1_s1}  ${cnote}  ${bool[0]}  ${self}      
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid26}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid26}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[3]}  waitlistedBy=PROVIDER_CONSUMER
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${Sid1_s1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id5} 
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${qid1}
    

    ${resp}=  Add To Waitlist Consumers     ${cid35}  ${pid0}   ${qid1}  ${DAY}  ${Sid1_s1}  ${cnote}  ${bool[0]}  ${cidfor_c2}      
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid27}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid27}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[3]}  waitlistedBy=PROVIDER_CONSUMER
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${Sid1_s1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${qid1}
    ${resp}=  Get consumer Waitlist By Id   ${wid25}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[7]}  waitlistedBy=PROVIDER_CONSUMER
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${Sid1_s1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${qid1}
    
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l2}

    ${resp}=  Get consumer Waitlist By Id   ${wid26}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[3]}  waitlistedBy=PROVIDER_CONSUMER
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${Sid1_s1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id5} 
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${qid1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${p1_l2}


JD-TC-Add To WaitlistByConsumer-UH2
    [Documentation]  waitlist  maximum capacity and check
    # # clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}    

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${pcons_id0}  ${resp.json()[0]['id']}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[1]['name']}
    Set Test Variable   ${p1_s2}   ${resp.json()[2]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[2]['name']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    ${p1_l2}=  Create Sample Location
    Set Test Variable   ${p1_l2}   

    ${p1queue1}=    FakerLibrary.word
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}
    # ${sTime1}=  add_timezone_time  ${tz}  3  30  
    # ${eTime1}=  add_timezone_time  ${tz}  4  00  
    ${sTime1}=  add_timezone_time  ${tz}  3  30
    ${eTime1}=  add_timezone_time  ${tz}  4  00  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel[0]}  1  ${p1_l1}  ${p1_s1}  ${p1_s2} 
    Log  ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_q4}  ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=    Send Otp For Login    ${CUSERNAME11}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME11}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME11}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME35}

    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME11}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}  

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q4}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid5}  ${wid[0]}

    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pcons_id0}  ${resp.json()[0]['id']}
    
     ${resp}=    Send Otp For Login    ${CUSERNAME11}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME11}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME11}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME35}

    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME11}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}  

    ${resp}=  Get consumer Waitlist By Id   ${wid5}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id0}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q4}

    ${firstname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Add FamilyMember For ProviderConsumer   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${f1}   ${resp.json()}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}   ${p1_q4}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${f1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422   
    Should Be Equal As Strings  "${resp.json()}"  "${WATLIST_MAX_LIMIT_REACHED}"
    

JD-TC-Add To WaitlistByConsumer-UH3
	[Documentation]  Add To Waitlist By Consumer Queue Disabled  
    # clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME4}
    

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[1]['name']}
    Set Test Variable   ${p1_s2}   ${resp.json()[2]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[2]['name']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}


    ${p1queue1}=    FakerLibrary.word
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}
    # ${sTime1}=  add_timezone_time  ${tz}  4  15  
    # ${eTime1}=  add_timezone_time  ${tz}  4  45  
    ${sTime1}=  add_timezone_time  ${tz}  4  15
    ${eTime1}=  add_timezone_time  ${tz}  4  45  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${capacity}=  FakerLibrary.Numerify  %%
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel[0]}  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2} 
    Log  ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_q5}  ${resp.json()}

    ${resp}=  Enable Disable Queue  ${p1_q5}  ${toggleButton[1]} 
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   02s
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=    Send Otp For Login    ${CUSERNAME4}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME4}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME4}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME35}

    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME4}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}  
  

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q5}  ${DAY}  ${p1_s2}  ${cnote}  ${bool[0]}  ${self}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${QUEUE_DISABLED}" 

 

JD-TC-Add To WaitlistByConsumer-UH4
	[Documentation]  Add To Waitlist By Consumer ,provider  disable online Checkin  
    # clear waitlist   ${PUSERPH0}
   clear Customer  ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME4}
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Online Checkin
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=    Send Otp For Login    ${CUSERNAME4}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME4}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME4}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME35}

    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME4}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}     

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s2}  ${cnote}  ${bool[0]}  0     
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${ONLINE_CHECKIN_OFF}"

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    
JD-TC-Add To WaitlistByConsumer-UH5 
	[Documentation]  Add To Waitlist By Consumer ,provider  disable Waitlist 
    # clear waitlist   ${PUSERPH0}
   clear Customer  ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME4}
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Online Checkin                                              
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Disable Waitlist
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=    Send Otp For Login    ${CUSERNAME4}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME4}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME4}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME4}

    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME4}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}   

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s2}  ${cnote}  ${bool[0]}  ${self}     
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${WAITLIST_NOT_ENABLED}" 

    

JD-TC-Add To WaitlistByConsumer-UH6
	[Documentation]  Add To Waitlist By Consumer ,provider  disable Disable Future Checkin
    # clear waitlist   ${PUSERPH0}
   clear Customer  ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME5}
    # ${TOMORROW}=  db.add_timezone_date  ${tz}  3  
    ${TOMORROW}=  db.add_timezone_date  ${tz}  3

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Waitlist                                              
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Disable Future Checkin
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=    Send Otp For Login    ${CUSERNAME5}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME5}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME5}

    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}   

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${TOMORROW}  ${p1_s2}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${FUTURE_CHECKIN_DISABLED}" 


           
JD-TC-Add To WaitlistByConsumer-UH7
	[Documentation]  Add To Waitlist By Consumer ,service and queue are diffrent
    # clear waitlist   ${PUSERPH0}
   clear Customer  ${PUSERPH0}
    # clear_queue    ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME4}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Future Checkin                                              
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[1]['name']}
    Set Test Variable   ${p1_s2}   ${resp.json()[2]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[2]['name']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    Set Test Variable   ${p1_l2}   ${resp.json()[1]['id']}

    ${p1queue11}=    FakerLibrary.word
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}
    # ${sTime1}=  add_timezone_time  ${tz}  5  00  
    # # ${eTime1}=  add_time   5  30
    ${eTime1}=  add_timezone_time  ${tz}  5  30  
    ${sTime1}=  add_timezone_time  ${tz}  5  00
    ${eTime1}=  add_timezone_time  ${tz}  5  30  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${capacity}=  FakerLibrary.Numerify  %%
    ${resp}=  Create Queue  ${p1queue11}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel[0]}  ${capacity}  ${p1_l1}  ${p1_s1} 
    Log  ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_q11}  ${resp.json()}


     ${resp}=    Send Otp For Login    ${CUSERNAME4}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME4}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME4}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME4}

    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME4}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}      

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q11}  ${DAY}  ${p1_s2}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${SERVICE_NOT_AVAILABLE}" 

JD-TC-Add To WaitlistByConsumer-UH8
	[Documentation]  Add To Waitlist By Consumer ,provider in holiday
    # clear waitlist   ${PUSERPH0}
   clear Customer  ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME4}
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    # ${eTime1}=  add_time   5  30
    ${eTime1}=  add_timezone_time  ${tz}  5  30  
    ${holidayname}=   FakerLibrary.word
    ${desc}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${resp}=  Create Holiday  ${DAY}  ${holidayname}  ${sTime1}  ${eTime1}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY}  ${DAY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${desc}
      
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${hId}    ${resp.json()['holidayId']}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200


     ${resp}=    Send Otp For Login    ${CUSERNAME4}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME4}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME4}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME4}

    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME4}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}   

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q11}  ${DAY}  ${p1_s2}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${HOLIDAY_NON_WORKING_DAY}" 

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Delete Holiday  ${hId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    
JD-TC-Add To WaitlistByConsumer-UH9
	[Documentation]  Add To Waitlist By Consumer service DISABLED 
    # clear waitlist   ${PUSERPH0}
   clear Customer  ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME4}
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Disable service   ${p1_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200


     ${resp}=    Send Otp For Login    ${CUSERNAME4}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME4}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME4}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME4}

    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME4}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}   

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}        
    Log  ${resp.content}
    Should Be Equal As Strings  "${resp.json()}"   "${INVALID_SERVICE}"  
    Should Be Equal As Strings  ${resp.status_code}  422

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=  Enable service  ${p1_s1}                                              
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200        

# JD-TC-Add To WaitlistByConsumer-UH10

# 	[Documentation]  invalid provider

#     # clear waitlist   ${PUSERPH0}
#    clear Customer  ${PUSERPH0}
#    ${pid0}=  get_acc_id  ${PUSERPH0}
#     ${cid}=  get_id  ${CUSERNAME4}
#     # ${DAY}=  db.get_date_by_timezone  ${tz}
#     ${DAY}=  get_date_by_timezone  ${tz}

#     ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  AddCustomer  ${CUSERNAME4}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  ProviderLogout
#     Should Be Equal As Strings  ${resp.status_code}  200


#      ${resp}=    Send Otp For Login    ${CUSERNAME4}    ${pid0}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
  
#      ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME4}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     Set Test Variable   ${token}  ${resp.json()['token']}

#     ${resp}=  Consumer Logout   
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
   
#     ${resp}=    ProviderConsumer Login with token    ${CUSERNAME4}    ${pid0}    ${token}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     clear_Consumermsg  ${CUSERNAME4}

#     ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME4}    ${pid0}    ${token}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
#     Set Test Variable    ${cid}   ${resp.json()['id']}   
    
#     ${pid2}=    Random Int   min=9999   max=99999

#     ${cnote}=   FakerLibrary.word
#     ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid2}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}     
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
   
JD-TC-Add To WaitlistByConsumer-UH11    
    [Documentation]   Add To Waitlist without login
    # # ${resp}=   Run Keywords   clear_queue  ${PUSERPH0}  AND  # clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
   clear Customer  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME4}
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-Add To WaitlistByConsumer-UH12
    [Documentation]  Add To Waitlist By Consumer Location Disabled  
    # clear waitlist   ${PUSERPH0}
   clear Customer  ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME4}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[1]['name']}
    Set Test Variable   ${p1_s2}   ${resp.json()[2]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[2]['name']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}


    ${p1queue1}=    FakerLibrary.word
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}
    # ${sTime1}=  add_timezone_time  ${tz}  5  45  
    # ${eTime1}=  add_timezone_time  ${tz}  6  30  
    ${sTime1}=  add_timezone_time  ${tz}  5  45
    ${eTime1}=  add_timezone_time  ${tz}  6  30  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${capacity}=  FakerLibrary.Numerify  %%
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel[0]}  ${capacity}  ${p1_l2}  ${p1_s1}  ${p1_s2} 
    Log  ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_q1}  ${resp.json()}

    ${resp}=  Disable Location  ${p1_l2}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200


     ${resp}=    Send Otp For Login    ${CUSERNAME4}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME4}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME4}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME4}

    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME4}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}       
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}   ${p1_q1}  ${DAY}  ${p1_s2}  ${cnote}  ${bool[0]}  ${self}     
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${LOCATION_DISABLED}"  

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=  Enable Location  ${p1_l2}                                          
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

JD-TC-Add To WaitlistByConsumer-UH14   
    [Documentation]   Add to waitlist After Business time
    # ${resp}=   Run Keywords   clear_queue  ${PUSERPH0}  AND  # clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME5}
   clear Customer  ${PUSERPH0}
    

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[1]['name']}
    Set Test Variable   ${p1_s2}   ${resp.json()[2]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[2]['name']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    # Set Test Variable   ${p1_l2}   ${resp.json()[1]['id']}

    ${p1queue1}=    FakerLibrary.word
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}
    # ${psTime}=  db.subtract_timezone_time  ${tz}  0  30
    # ${peTime}=  db.subtract_timezone_time  ${tz}   0  15
    ${psTime}=  db.subtract_timezone_time  ${tz}  0  50 
    ${peTime}=  db.subtract_timezone_time  ${tz}  0  15
    ${list}=  Create List  1  2  3  4  5  6  7
    ${capacity}=  FakerLibrary.Numerify  %%
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${psTime}  ${peTime}  ${parallel[0]}  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2} 
    Log  ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_q1}  ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200


     ${resp}=    Send Otp For Login    ${CUSERNAME5}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME5}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME4}

    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}   

    ${firstname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Add FamilyMember For ProviderConsumer   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${f1}   ${resp.json()}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${f1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_BUS_HOURS_END}"  


JD-TC-Add To WaitlistByConsumer-UH16
	[Documentation]  Add consumer to waitlist for a service with prepayment and try to change prepayment status from prepaymentPending to arrived.   


    # ${firstname}  ${lastname}  ${PUSERNAME282}  ${LoginId}=  Provider Signup
    # Set Suite Variable  ${PUSERNAME282}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME282}  ${PASSWORD}
    # Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}

    ${resp}=  Get Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enabledWaitlist']}==${bool[0]}   
        ${resp}=   Enable Waitlist
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enabledWaitlist']}   ${bool[1]}
    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePresence']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${bool[1]}  ${EMPTY}  ${EMPTY}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]} 

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  AddCustomer  ${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid1}=  get_acc_id  ${PUSERNAME282}
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    # ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    # ${tz1}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    # Set Suite Variable  ${tz1}
    # ${parking}    Random Element     ${parkingType}
    # ${24hours}    Random Element    ['True','False']
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    # ${url}=   FakerLibrary.url
    # ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[4]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${p2_l1}  ${resp.json()}

    ${p2_l1}=  Create Sample Location  

    ${P2SERVICE1}=    FakerLibrary.word
    Set Test Variable  ${P2SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P2SERVICE1}  ${desc}  ${service_duration[1]}  ${bool[0]}   ${servicecharge}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p2_s1}  ${resp.json()}

    ${P2SERVICE2}=    generate_firstname
    Set Test Variable  ${P2SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P2SERVICE2}  ${desc}   ${service_duration[1]}  ${bool[0]}    ${servicecharge}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p2_s2}  ${resp.json()}

    ${resp}=   Get Location ById  ${p2_l1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz1}  ${resp.json()['timezone']}

    ${DAY}=  get_date_by_timezone  ${tz1}
    ${sTime}=  add_timezone_time  ${tz1}  0  15
    ${eTime}=  add_timezone_time  ${tz1}  0  30
    ${list}=  Create List  1  2  3  4  5  6  7

    ${resp}=    Update Waitlist Settings  ${calc_mode[0]}  20  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[0]}   ${EMPTY}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${sTime1}=  add_timezone_time  ${tz}  0  30  
    # ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${sTime1}=  add_timezone_time  ${tz1}  0  30
    ${eTime1}=  add_timezone_time  ${tz1}  1  00
    ${p2queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${resp}=  Create Queue  ${p2queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel[0]}  ${capacity}  ${p2_l1}  ${p2_s1}  ${p2_s2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p2_q1}  ${resp.json()}

    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${ifsc_code}=   db.Generate_ifsc_code
    ${bank_ac}=   db.Generate_random_value  size=11   chars=${digits} 
    ${bank_name}=  FakerLibrary.company
    ${name}=  FakerLibrary.name
    ${branch}=   db.get_place
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME282}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  payuVerify  ${pid1}
    Log  ${resp}

    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME282}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Account Settings 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=    Send Otp For Login    ${CUSERNAME8}    ${pid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME8}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME8}    ${pid1}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME8}

    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME8}    ${pid1}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}  
    ${cid}=  get_id  ${CUSERNAME8}    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid1}  ${p2_q1}  ${DAY}  ${p2_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME282}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcons_id8}  ${resp.json()[0]['id']}
   ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME8}    ${pid1}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}    waitlistedBy=PROVIDER_CONSUMER
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P2SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p2_s1}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id8}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p2_q1}
    ${resp}=  Consumer Logout       
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME282}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action  ${waitlist_actions[0]}  ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${WAITLIST_STATUS_NOT_CHANGEABLE}=  Format String  ${WAITLIST_STATUS_NOT_CHANGEABLE}  ${wl_status[3]}   ${wl_status[1]}
    # Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_STATUS_NOT_CHANGEABLE}"




JD-TC-Add To WaitlistByConsumer-UH17
	[Documentation]  the consumer add to waitlist for a service with prepayment  , try to change prepaymentPending to STARTED 
    # ${resp}=   Run Keywords   clear_queue  ${PUSERNAME282}  AND  # clear waitlist   ${PUSERNAME282}
    ${pid1}=  get_acc_id  ${PUSERNAME282}
    ${cid}=  get_id  ${CUSERNAME5}
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}
   clear Customer  ${PUSERNAME282}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME282}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  AddCustomer  ${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p2_s1}   ${resp.json()[1]['id']}
    Set Test Variable   ${P2SERVICE1}   ${resp.json()[1]['name']}
    Set Test Variable   ${p2_s2}   ${resp.json()[2]['id']}
    Set Test Variable   ${P2SERVICE2}   ${resp.json()[2]['name']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p2_l1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    Set Test Variable   ${p2_l2}   ${resp.json()[1]['id']}

    # ${sTime1}=  db.subtract_timezone_time  ${tz}  0  30
    # ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${sTime1}=  db.subtract_timezone_time  ${tz}  0  30  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${p2queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p2queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel[0]}  ${capacity}  ${p2_l1}  ${p2_s1}  ${p2_s2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p2_q1}  ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=    Send Otp For Login    ${CUSERNAME8}    ${pid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME8}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME8}    ${pid1}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME8}

    # ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME8}    ${pid1}    ${token}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${pcons_id8}    ${resp.json()['providerConsumer']}
    # Set Test Variable    ${cid}   ${resp.json()['id']}   

    ${cid}=  get_id  ${CUSERNAME8}    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid1}  ${p2_q1}  ${DAY}  ${p2_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}     appxWaitingTime=0  waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P2SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p2_s1}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id8}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p2_q1}
    
    ${resp}=  Consumer Logout       
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME282}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Waitlist Today  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}  

    ${resp}=  Waitlist Action  STARTED  ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${WAITLIST_STATUS_NOT_CHANGEABLE}=  Format String  ${WAITLIST_STATUS_NOT_CHANGEABLE}  ${wl_status[3]}   ${wl_status[2]}
    # Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_STATUS_NOT_CHANGEABLE}"

    ${resp1}=  Get Waitlist Today  
    Log   ${resp1.json()}
    Should Be Equal As Strings  ${resp1.status_code}  200
    


JD-TC-Add To WaitlistByConsumer-21
	[Documentation]  the consumer add to waitlist for a service with prepayment  , try to change prepaymentPending to checkedIn 
    # ${resp}=   Run Keywords   clear_queue  ${PUSERNAME282}  
    # AND  # clear waitlist   ${PUSERNAME282}
    ${pid1}=  get_acc_id  ${PUSERNAME282}
    ${cid}=  get_id  ${CUSERNAME5}
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}
   clear Customer  ${PUSERNAME282}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME282}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
    Set Suite Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}
    ${resp}=  AddCustomer  ${CUSERNAME8}  firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}   email=${pc_emailid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${p2_s1}   ${resp.json()[1]['id']}
    # Set Test Variable   ${P2SERVICE1}   ${resp.json()[1]['name']}
    Set Test Variable   ${p2_s2}   ${resp.json()[2]['id']}
    Set Test Variable   ${P2SERVICE2}   ${resp.json()[2]['name']}

    ${P2SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${P2SERVICE1}
    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Random Int   min=10   max=20
    ${min_pre}=  Convert To Number  ${min_pre}  0
    ${p2_s1}=  Create Sample Service   ${P2SERVICE1}   isPrePayment=${bool[1]}  minPrePaymentAmount=${min_pre}  maxBookingsAllowed=10
    Set Suite Variable   ${p2_s1}
   
    ${resp}=   Get Service ById   ${p2_s1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p2_l1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    Set Test Variable   ${p2_l2}   ${resp.json()[1]['id']}

    # ${sTime1}=  add_timezone_time  ${tz}  0  30  
    # ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${sTime1}=  add_timezone_time  ${tz}  0  30  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${p2queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p2queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel[0]}  ${capacity}  ${p2_l1}  ${p2_s1}  ${p2_s2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p2_q1}  ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=    Send Otp For Login    ${CUSERNAME8}    ${pid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME8}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME8}    ${pid1}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME8}

    # ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME8}    ${pid1}    ${token}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${pcons_id8}    ${resp.json()['providerConsumer']}
    # Set Test Variable    ${cid}   ${resp.json()['id']}   


    ${cid}=  get_id  ${CUSERNAME8}    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid1}  ${p2_q1}  ${DAY}  ${p2_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[3]}      waitlistedBy=PROVIDER_CONSUMER
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P2SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p2_s1}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id8}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p2_q1}
    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME282}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Waitlist Action  CHECK_IN  ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${PAYMENT_NOT_DONE}"



JD-TC-Add To WaitlistByConsumer-22
	[Documentation]  checking the waitlistStatus of a consumer 
    # ${resp}=   Run Keywords   clear_queue  ${PUSERNAME282}  
    # AND  # clear waitlist   ${PUSERNAME282}
    ${pid1}=  get_acc_id  ${PUSERNAME282}
    ${cid}=  get_id  ${CUSERNAME8}
   clear Customer  ${PUSERNAME282}
    

    ${resp}=  Encrypted Provider Login  ${PUSERNAME282}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
    Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}
    ${resp}=  AddCustomer  ${CUSERNAME8}  firstName=${fname}   lastName=${lname}    email=${pc_emailid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${p2_s1}   ${resp.json()[1]['id']}
    # Set Test Variable   ${P2SERVICE1}   ${resp.json()[1]['name']}
    Set Test Variable   ${p2_s2}   ${resp.json()[2]['id']}
    Set Test Variable   ${P2SERVICE2}   ${resp.json()[2]['name']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p2_l1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    # Set Test Variable   ${p2_l2}   ${resp.json()[1]['id']}

    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}
    # ${sTime1}=  add_timezone_time  ${tz}  0  30  
    # ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${sTime1}=  add_timezone_time  ${tz}  0  30  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${p2queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p2queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel[0]}  ${capacity}  ${p2_l1}  ${p2_s1}  ${p2_s2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p2_q1}  ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=    Send Otp For Login    ${CUSERNAME8}    ${pid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME8}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME8}    ${pid1}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME8}

    # ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME8}    ${pid1}    ${token}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    # Set Test Variable    ${cid}   ${resp.json()['id']}  

    ${cid}=  get_id  ${CUSERNAME8}    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers   ${cid}   ${pid1}  ${p2_q1}  ${DAY}  ${p2_s1}  ${cnote}  ${bool[0]}  0
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
   
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   waitlistStatus=${wl_status[3]}

JD-TC-Add To WaitlistByConsumer-23
	[Documentation]  the consumer add to waitlist for a service with prepayment , try to change prepaymentPending to Cancel 
    # ${resp}=   Run Keywords   clear_queue  ${PUSERNAME282}  
    # AND  # clear waitlist   ${PUSERNAME282}
    ${pid1}=  get_acc_id  ${PUSERNAME282}
    ${cid}=  get_id  ${CUSERNAME2}
    

    ${resp}=  Encrypted Provider Login  ${PUSERNAME282}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
    Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}
    ${resp}=  AddCustomer  ${CUSERNAME2}  firstName=${fname}   lastName=${lname}   email=${pc_emailid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${p2_s1}   ${resp.json()[1]['id']}
    # Set Test Variable   ${P2SERVICE1}   ${resp.json()[1]['name']}
    Set Test Variable   ${p2_s2}   ${resp.json()[2]['id']}
    Set Test Variable   ${P2SERVICE2}   ${resp.json()[2]['name']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p2_l1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    # Set Test Variable   ${p2_l2}   ${resp.json()[1]['id']}

    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}
    # ${sTime1}=  add_timezone_time  ${tz}  0  30  
    # ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${sTime1}=  add_timezone_time  ${tz}  0  30  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${p2queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p2queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel[0]}  ${capacity}  ${p2_l1}  ${p2_s1}  ${p2_s2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p2_q1}  ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=    Send Otp For Login    ${CUSERNAME2}    ${pid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME2}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME2}    ${pid1}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME2}

    # ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME2}    ${pid1}    ${token}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}  
   
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid1}  ${p2_q1}  ${DAY}  ${p2_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME282}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcons2}  ${resp.json()[0]['id']}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=    Send Otp For Login    ${CUSERNAME2}    ${pid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME2}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME2}    ${pid1}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME2}

    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME2}    ${pid1}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}  

    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${pid1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[3]}      waitlistedBy=PROVIDER_CONSUMER
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p2_s1}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons2}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p2_q1}

    ${resp}=  Consumer Logout       
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME282}  ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200    

    # ${msg}=   FakerLibrary.word
    # Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    # ${resp}=  Waitlist Action    ${waitlist_actions[2]}  ${wid2}  cancelReason=${waitlist_cancl_reasn[4]}  
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Add To WaitlistByConsumer-UH18
    [Documentation]  add to waitlist w1 and cancell the waitlist
    Comment  add to waitlist w2  same service again
    Comment  change waitlist status  from canceled to checkedIn
    # ${resp}=   Run Keywords   clear_queue  ${PUSERPH0}  
    # AND  # clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME4}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[1]['name']}
    Set Test Variable   ${p1_s2}   ${resp.json()[2]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[2]['name']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    # Set Test Variable   ${p1_l2}   ${resp.json()[1]['id']}

    # ${TODAY}=  db.get_date_by_timezone  ${tz}
    ${TODAY}=  get_date_by_timezone   ${tz}

    # ${sTime1}=  add_timezone_time  ${tz}  0  30  
    # ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${sTime1}=  add_timezone_time  ${tz}  0  30
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${TODAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel[0]}  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    
     ${resp}=    Send Otp For Login    ${CUSERNAME4}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME4}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME4}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME2}

    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME4}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}   

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${TODAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200        
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid}  ${wid[0]} 

    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${pid0}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${TODAY}  waitlistStatus=${wl_status[0]}    waitlistedBy=PROVIDER_CONSUMER   

    ${resp}=  Cancel Waitlist  ${uuid}  ${pid0}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${pid0}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${TODAY}  waitlistStatus=${wl_status[4]}    waitlistedBy=PROVIDER_CONSUMER   

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${TODAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200     
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid1}  ${wid[0]}
    
    ${resp}=  Get consumer Waitlist By Id   ${uuid1}  ${pid0}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${TODAY}  waitlistStatus=${wl_status[0]}    waitlistedBy=PROVIDER_CONSUMER    

    ${resp}=  Consumer Logout       
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action  CHECK_IN  ${uuid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${WAITLIST_CUSTOMER_ALREADY_IN}"



JD-TC-Add To WaitlistByConsumer-UH19
    [Documentation]  add to waitlist for future w1 and cancel the waitlist
    Comment  add to waitlist w2 for future same service again
    Comment  change waitlist status  from canceled to checkin
    # ${resp}=   Run Keywords   clear_queue  ${PUSERPH0}  
    # AND  # clear waitlist   ${PUSERPH0}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME4}
    # ${TOMORROW}=  db.add_timezone_date  ${tz}  3  
    clear Customer  ${PUSERPH0}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[1]['name']}
    Set Test Variable   ${p1_s2}   ${resp.json()[2]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[2]['name']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    # Set Test Variable   ${p1_l2}   ${resp.json()[1]['id']}

    # ${sTime1}=  add_timezone_time  ${tz}  0  30  
    # ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${TOMORROW}=  db.add_timezone_date  ${tz}  3
    ${sTime1}=  add_timezone_time  ${tz}  0  30  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${TOMORROW}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel[0]}  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    
     ${resp}=    Send Otp For Login    ${CUSERNAME4}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME4}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME4}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME2}

    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME4}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}   

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${TOMORROW}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200        
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid}  ${wid[0]} 

    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${pid0}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${TOMORROW}  waitlistStatus=${wl_status[0]}    waitlistedBy=PROVIDER_CONSUMER   

    ${resp}=  Cancel Waitlist  ${uuid}  ${pid0}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${pid0}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${TOMORROW}  waitlistStatus=${wl_status[4]}    waitlistedBy=PROVIDER_CONSUMER   

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p1_q1}  ${TOMORROW}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200     
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid1}  ${wid[0]}
    
    ${resp}=  Get consumer Waitlist By Id   ${uuid1}  ${pid0}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${TOMORROW}  waitlistStatus=${wl_status[0]}    waitlistedBy=PROVIDER_CONSUMER    

    ${resp}=  Consumer Logout       
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action  CHECK_IN  ${uuid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${WAITLIST_CUSTOMER_ALREADY_IN}"


JD-TC-Add To WaitlistByConsumer-CLEAR
    [Documentation]  Disable Search Data
    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Search Data
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Disable Online Checkin
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Add To WaitlistByConsumer-26
    [Documentation]  consumer takes checkin for a provider's queue with a different phone number.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}
    # Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    # ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    # Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    # Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    # ${resp}=   Get jaldeeIntegration Settings
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  
    # Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    # clear_location   ${PUSERNAME132}
    # clear_service    ${PUSERNAME132}
    clear_customer   ${PUSERNAME132}
    clear_consumer_msgs  ${CUSERNAME27}
    clear_provider_msgs  ${PUSERNAME132}

    ${resp}=  AddCustomer  ${CUSERNAME27}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    
    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    # clear_queue   ${PUSERNAME132}

    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    
    ${resp}=  Sample Queue  ${lid}   ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${lid}  ${resp.json()[0]['id']} 
    # Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${resp}=  Get Queues
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}  queueState=${Qstate[0]}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Login  ${CUSERNAME27}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  ${jdconID}   ${resp.json()['id']}
    # Set Test Variable  ${fname}   ${resp.json()['firstName']}
    # Set Test Variable  ${lname}   ${resp.json()['lastName']}
    # Set Test Variable  ${uname}   ${resp.json()['userName']}

    
     ${resp}=    Send Otp For Login    ${CUSERNAME27}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME27}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME27}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME2}

    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME27}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${jdconID}   ${resp.json()['id']}   

    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY1}=  get_date_by_timezone  ${tz}
    ${PO_Number}    Generate random string    4    ${digits} 
    ${PO_Number}    Convert To Integer  ${PO_Number}
    # ${country_code}    Generate random string    2    ${digits} 
    # ${country_code}    Convert To Integer  ${country_code}
    ${CUSERPH27}=  Evaluate  ${CUSERNAME27}+${PO_Number}
    ${resp}=  Consumer Add To Waitlist with Phone no   ${pid}  ${s_id}  ${q_id}  ${DAY1}  ${CUSERPH27}  91  ${self} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}   waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${jdconID}           
    # Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname}  
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${q_id}
    
JD-TC-Add To WaitlistByConsumer-UH20
    [Documentation]  Add To Waitlist By Consumer where online presence is false
    # clear waitlist   ${PUSERNAME214}
    ${pid0}=  get_acc_id  ${PUSERNAME214}
    ${cid}=  get_id  ${PUSERNAME214}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME214}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}
   
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}

    ${resp}=   Create Sample Location
    Set Test Variable    ${p1_l1}    ${resp}  

    ${resp}=   Get Location ById  ${p1_l1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}
   
    ${p1queue1}=    FakerLibrary.word
    # ${sTime1}=  add_timezone_time  ${tz}  5  45  
    # ${eTime1}=  add_timezone_time  ${tz}  6  30  
    ${sTime1}=  add_timezone_time  ${tz}  5  45
    ${eTime1}=  add_timezone_time  ${tz}  6  30  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${capacity}=  FakerLibrary.Numerify  %%
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel[0]}  ${capacity}  ${p1_l1}  ${p1_s1}  
    Log  ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_q1}  ${resp.json()}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePresence']}==${bool[1]}
        ${resp}=  Set jaldeeIntegration Settings    ${bool[0]}  ${EMPTY}  ${EMPTY}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    
    ${resp}=    Send Otp For Login    ${CUSERNAME4}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME4}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME4}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME2}

    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME4}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}      
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}   ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}     
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${WAITLIST_NOT_TAKEN}"  




*** Comments ***
JD-TC-Add To WaitlistByConsumer-18
    [Documentation]  provider login as consumer and waitlist

    # ${resp}=   Run Keywords  clear_queue  ${PUSERNAME1}   AND  clear_location  ${PUSERNAME1}
    # ${resp}=   Run Keywords   clear_queue  ${PUSERPH0}  AND  # clear waitlist   ${PUSERPH0}
    # clear_location   ${PUSERPH0}
    # clear_location    ${PUSERNAME1}
    ${pid0}=  get_acc_id  ${PUSERPH0}
    ${cid1}=  get_id  ${PUSERNAME1}
    

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
    Set Test Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}
    Set Test Variable   ${p1_s2}   ${resp.json()[1]['id']}
    Set Test Variable   ${P1SERVICE2}   ${resp.json()[1]['name']}s

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_l1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    Set Test Variable   ${p1_l2}   ${resp.json()[1]['id']}

    ${resp}=    Get Queues
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}

    ${p1queue1}=    FakerLibrary.word
    # ${sTime1}=  add_timezone_time  ${tz}  4  15  
    # ${eTime1}=  add_timezone_time  ${tz}  6  30  
    ${sTime1}=  add_timezone_time  ${tz}  4  15
    ${eTime1}=  add_timezone_time  ${tz}  6  30  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${capacity}=  FakerLibrary.Numerify  %%
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel[0]}  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2} 
    Log  ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_q1}  ${resp.json()}

    ${resp}=  Get Waitlist Today  service-eq=${p1_s1}
    Log  ${resp.content}
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Waitlist Today  
    Log   ${resp.json()}
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  ProviderLogout

    ${resp}=  Consumer Login  ${PUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200    
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}   ${p1_q1}  ${DAY}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200     
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id  ${wid1}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}    appxWaitingTime=0  waitlistedBy=PROVIDER_CONSUMER    
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${self}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p1_q1}  


JD-TC-Add To WaitlistByConsumer-24
    
    [Documentation]  Add to waitlist a consumer and familymember

    ${firstname}  ${lastname}  ${PUSERPH8}  ${LoginId}=  Provider Signup
    Set Suite Variable   ${PUSERPH8}

    ${resp}=  Encrypted Provider Login  ${PUSERPH8}  ${PASSWORD}
    # Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}

    ${resp}=  Get Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enabledWaitlist']}==${bool[0]}   
        ${resp}=   Enable Waitlist
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enabledWaitlist']}   ${bool[1]}
    sleep   01s
    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePresence']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${bool[1]}  ${EMPTY}  ${EMPTY}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

    ${pid0}=  get_acc_id  ${PUSERPH8}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${loc1}  ${resp.json()[0]['id']} 
    Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    
    ${P1SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${P1SERVICE1}
    Set Suite Variable   ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration[0]}  ${bool[0]}    ${servicecharge}    ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${ps1}  ${resp.json()}

    ${P2SERVICE2}=    FakerLibrary.word
    Set Suite Variable  ${P2SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    Set Suite Variable  ${min_pre}
    ${servicecharge}=   Random Int  min=100  max=500
    ${Total1}=  Convert To Number  ${servicecharge}  1 
    Set Suite Variable   ${Total}   ${Total1}
    ${amt_float}=  twodigitfloat  ${Total}
    Set Suite Variable  ${amt_float}  ${amt_float}  

    ${resp}=  Create Service  ${P2SERVICE2}  ${desc}   ${service_duration[1]}  ${bool[0]}  ${servicecharge}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${ps2}  ${resp.json()}

    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    # ${eTime1}=  add_timezone_time  ${tz}  1  30  
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  1  30  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY}=  get_date_by_timezone  ${tz}
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel[0]}  ${capacity}  ${loc1}  ${ps1}  ${ps2}  
    Log  ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p_q1}  ${resp.json()}

    ${resp}=    Enable Search Data
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
     ${resp}=    Send Otp For Login    ${CUSERNAME5}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME5}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME2}

    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${cid}   ${resp.json()['id']}  

    ${cid}=  get_id  ${CUSERNAME5}
    ${firstname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Add FamilyMember For ProviderConsumer   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${f1}   ${resp.json()}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p_q1}  ${DAY}  ${ps1}  ${cnote}  ${bool[0]}  ${f1}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200   
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 
    Set Suite Variable  ${cwidfam}  ${wid[1]} 

    ${resp}=  Encrypted Provider Login  ${PUSERPH8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcons5}  ${resp.json()[1]['id']}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME5}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get consumer Waitlist By Id   ${cwid}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}      waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${ps1}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons5}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p_q1}


    ${resp}=  Get consumer Waitlist By Id   ${cwidfam}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}     waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${ps1}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${f1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p_q1}
    Set Test Variable  ${cfid}   ${resp.json()['waitlistingFor'][0]['id']}


    ${resp}=   Encrypted Provider Login  ${PUSERPH8}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[1]['id']}

    ${resp}=  ListFamilyMemberByProvider  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${cfid}
    Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
    Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
    Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}


JD-TC-Add To WaitlistByConsumer-24
    
    [Documentation]  Add to waitlist a consumer and familymember with prepayment

    ${firstname}  ${lastname}  ${PUSERPH8}  ${LoginId}=  Provider Signup
    Set Suite Variable   ${PUSERPH8}

    # clear waitlist   ${PUSERPH8}
    ${pid0}=  get_acc_id  ${PUSERPH8}
    ${cid}=  get_id  ${CUSERNAME8}
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enabledWaitlist']}==${bool[0]}   
        ${resp}=   Enable Waitlist
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enabledWaitlist']}   ${bool[1]}
    sleep   01s
    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePresence']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${bool[1]}  ${EMPTY}  ${EMPTY}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  


    ${resp}=  AddCustomer  ${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    # ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    # ${ifsc_code}=   db.Generate_ifsc_code
    # ${bank_ac}=   db.Generate_random_value  size=11   chars=${digits} 
    # ${bank_name}=  FakerLibrary.company
    # ${name}=  FakerLibrary.name
    # ${branch}=   db.get_place
    # ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERPH8}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=  payuVerify  ${pid0}
    # Log  ${resp}

    # ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERPH8}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=   Get Account Settings 
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200
    # ${resp}=  SetMerchantId  ${pid0}  ${merchantid}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}
    Set Suite Variable  ${accountId}  ${resp.json()['accountId']}    
    

    ${resp}=  Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${loc1}  ${resp.json()[0]['id']} 
    Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${P1SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${P1SERVICE1}
    Set Suite Variable   ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration[0]}  ${bool[0]}    ${servicecharge}    ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${ps1}  ${resp.json()}

    ${P2SERVICE2}=    FakerLibrary.word
    Set Suite Variable  ${P2SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    Set Suite Variable  ${min_pre}
    ${servicecharge}=   Random Int  min=100  max=500
    ${Total1}=  Convert To Number  ${servicecharge}  1 
    Set Suite Variable   ${Total}   ${Total1}
    ${amt_float}=  twodigitfloat  ${Total}
    Set Suite Variable  ${amt_float}  ${amt_float}  

    ${resp}=  Create Service  ${P2SERVICE2}  ${desc}   ${service_duration[1]}  ${bool[0]}  ${servicecharge}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${ps2}  ${resp.json()}

    # ${DAY}=  db.add_timezone_date  ${tz}  3  
    ${DAY}=  db.add_timezone_date  ${tz}  3

    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  1  30  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY}=  get_date_by_timezone  ${tz}
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel[0]}  ${capacity}  ${loc1}  ${ps1}  ${ps2}  
    Log  ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p_q1}  ${resp.json()}

    ${resp}=   Get payment profiles  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    
     ${resp}=    Send Otp For Login    ${CUSERNAME8}    ${pid0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
     ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME8}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME8}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME2}

    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME8}    ${pid0}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${consid1}   ${resp.json()['id']}  

    
    ${firstname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Add FamilyMember For ProviderConsumer   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${f1}   ${resp.json()}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid0}  ${p_q1}  ${DAY}  ${ps2}  ${cnote}  ${bool[0]}  ${f1}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200   
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 
    Set Suite Variable  ${cwidfam}  ${wid[1]} 

    ${resp}=  Encrypted Provider Login  ${PUSERPH8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pcons_id0}  ${resp.json()[1]['id']}

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=  Get consumer Waitlist By Id   ${cwid}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[3]}    appxWaitingTime=0  waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P2SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${ps2}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id0}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p_q1}

    ${resp}=  Get consumer Waitlist By Id   ${cwidfam}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[3]}    appxWaitingTime=12  waitlistedBy=PROVIDER_CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P2SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${ps2}
    
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${f1}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p_q1}

    ${min_pre2}=  Evaluate  $min_pre * 2
    ${resp}=    Get convenienceFee Details     ${pid0}    customizedJBProfile   ${min_pre2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    # ${min_pre2}=  Evaluate  $min_pre * 2
    ${resp}=  Make payment Consumer Mock  ${pid0}  ${min_pre2}  ${purpose[0]}  ${cwid}  ${ps2}  ${bool[0]}   ${bool[1]}  ${consid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Make payment Consumer Mock  ${Total}  ${bool[1]}  ${cwid}  ${pid0}  ${purpose[0]}   ${cid1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${resp}=  Get consumer Waitlist By Id  ${cwidfam}  ${pid0}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}

    sleep   2s
    ${resp}=   Cancel Waitlist  ${cwidfam}  ${pid0}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200



    

























