*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Batch  waitingtime
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
${prefix}                   serviceBatch
${suffix}                   serving

*** Test Cases ***
JD-TC-Approx Waiting Time-1
    [Documentation]   Check approximate waiting time when calculation mode is ML and batch is enabled
    
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+1030
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
    Set Suite Variable   ${PUSERPH0}
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_service  ${PUSERPH0}  AND  clear_customer  ${PUSERPH0}  AND  clear_Item    ${PUSERPH0}  AND   clear_Coupon   ${PUSERPH0}   AND  clear_Discount  ${PUSERPH0}   
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    Set Suite Variable   ${licid}
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${dom}=  Random Int   min=0  max=${dlen-1}
    Set Suite Variable  ${d1}  ${domresp.json()[${dom}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${dom}]['subDomains']}
    FOR  ${i}   IN RANGE   ${sdlen}
        ${sdom}=  Random Int   min=0  max=${sdlen-1}
        Set Suite Variable  ${sd1}  ${domresp.json()[${dom}]['subDomains'][${sdom}]['subDomain']}
        ${is_corp}=  check_is_corp  ${sd1}
        Exit For Loop IF   '${is_corp}' == 'False'
    END
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERPH0}  ${licid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${PUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  "${resp.json()}"    "true"
    
    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


*** Comments ***


    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    @{Views}=  Create List  self  all  customersOnly
    ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
    ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}028.${test_mail}  ${views}
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
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    Set Suite Variable   ${eTime}
    ${resp}=  Update Business Profile with Schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enabledWaitlist']}  ${bool[0]}

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  1s
    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enabledWaitlist']}  ${bool[1]}
    
    # ${acc_id} =   get_acc_id  ${PUSERPH0}
    clear_queue  ${PUSERPH0}
    clear_service   ${PUSERPH0}
    # delete_ML_table  ${acc_id}

    ${trnTime}=   Random Int   min=10   max=20
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}   ${trnTime}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[0]}   ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    ${P1SERVICE1}=    FakerLibrary.word
    Set Test Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   5   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_s1}  ${resp.json()} 

    ${resp}=    Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${today}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${today}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${etime1}=  add_timezone_time  ${tz}  1  0  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  Random Int  min=2   max=2
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${today}  ${EMPTY}  10  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${p1_s1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Enable Waitlist Batch   ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add Batch Name   ${p1_q1}  ${prefix}  ${suffix}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['batch']}    ${bool[1]}

    ${count}=  Evaluate  ${parallel} * 3
    FOR  ${i}  IN RANGE  1   ${count+1}
        
        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${i}}
        # Log   ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Test Variable  ${cid}   ${resp.json()[0]['id']}
        ${resp}=  AddCustomer  ${CUSERNAME${i}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid}  ${resp.json()}
        # ${cid} =  get_id  ${CUSERNAME${i}}
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${today}  ${desc}  ${bool[1]}  ${cid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${i}}  ${wid[0]}
    END
    sleep   05s
    
    ${wtime} =  Set Variable   0
    ${resp}=  Get Waitlist Today  queue-eq=${p1_q1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    # Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  batchId=1   batchName=${prefix}1${suffix}
    # Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  batchId=1   batchName=${prefix}1${suffix}
    # Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=5  batchId=2   batchName=${prefix}2${suffix}
    # Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=5  batchId=2   batchName=${prefix}2${suffix}
    # Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=10  batchId=3   batchName=${prefix}3${suffix}
    # Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=10  batchId=3   batchName=${prefix}3${suffix}

    ${len}=   Get Length    ${resp.json()} 
    FOR  ${i}  IN RANGE  ${len}

        ${wtime}=   Run Keyword If   ${i} == ${parallel*1}   Evaluate  ${wtime}+5
        ...         ELSE  Set Variable   ${wtime}
        ${wtime}=   Run Keyword If   ${i} == ${parallel*2}   Evaluate  ${wtime}+5
        ...         ELSE   Set Variable  ${wtime}
        Verify Response List  ${resp}  ${i}  ynwUuid=${wid${i+1}}  appxWaitingTime=${wtime}
    END

JD-TC-Approx Waiting Time-2
    [Documentation]   Check approximate waiting time when calculation mode is Fixed and batch is enabled
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    clear_queue  ${PUSERPH0}
    clear_service   ${PUSERPH0}
    clear_customer  ${PUSERPH0}

    ${trnTime}=   Random Int   min=10   max=10
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${trnTime}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[0]}   ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    ${P1SERVICE1}=    FakerLibrary.word
    Set Test Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   5   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_s1}  ${resp.json()} 
    
    ${today}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${today}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${stime1}=  add_timezone_time  ${tz}  0  45  
    ${etime1}=  add_timezone_time  ${tz}  1  0  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  Random Int  min=2   max=2
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${today}  ${EMPTY}  10  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${p1_s1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Enable Waitlist Batch   ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add Batch Name   ${p1_q1}  ${prefix}  ${suffix}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['batch']}    ${bool[1]}

    ${count}=  Evaluate  ${parallel} * 3
    FOR  ${i}  IN RANGE  1   ${count+1}
        
        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${i}}
        # Log   ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Test Variable  ${cid}   ${resp.json()[0]['id']}
        ${resp}=  AddCustomer  ${CUSERNAME${i}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid}  ${resp.json()}
        # ${cid} =  get_id  ${CUSERNAME${i}}
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${today}  ${desc}  ${bool[1]}  ${cid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${i}}  ${wid[0]}
    END

    ${resp}=  Get Waitlist Today  queue-eq=${p1_q1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wtime} =  Set Variable   0
    ${len}=   Get Length    ${resp.json()} 
    FOR  ${i}  IN RANGE  ${len}

        ${wtime}=   Run Keyword If   ${i} == ${parallel*1}   Evaluate  ${wtime}+10
        ...         ELSE  Set Variable   ${wtime}
        Verify Response List  ${resp}  ${i}  ynwUuid=${wid${i+1}}  appxWaitingTime=${wtime}
    END

JD-TC-Approx Waiting Time-3
    [Documentation]   Check approximate waiting time when calculation mode is NoCalc and batch is enabled
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    clear_queue  ${PUSERPH0}
    clear_service   ${PUSERPH0}
    clear_customer  ${PUSERPH0}

    ${trnTime}=   Random Int   min=10   max=10
    ${resp}=  Update Waitlist Settings  ${calc_mode[2]}   ${trnTime}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[0]}   ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    ${P1SERVICE1}=    FakerLibrary.word
    Set Test Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   5   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_s1}  ${resp.json()} 
    
    ${today}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${today}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${stime1}=  add_timezone_time  ${tz}  0  45  
    ${etime1}=  add_timezone_time  ${tz}  1  0  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  Random Int  min=2   max=2
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${today}  ${EMPTY}  10  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${p1_s1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Enable Waitlist Batch   ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add Batch Name   ${p1_q1}  ${prefix}  ${suffix}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['batch']}    ${bool[1]}

    ${count}=  Evaluate  ${parallel} * 3
    FOR  ${i}  IN RANGE  1   ${count+1}
        
        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${i}}
        # Log   ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Test Variable  ${cid}   ${resp.json()[0]['id']}
        ${resp}=  AddCustomer  ${CUSERNAME${i}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid}  ${resp.json()}
        
        # ${cid} =  get_id  ${CUSERNAME${i}}
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${today}  ${desc}  ${bool[1]}  ${cid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${i}}  ${wid[0]}
    END

    ${resp}=  Get Waitlist Today  queue-eq=${p1_q1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${len}=   Get Length    ${resp.json()} 
    FOR  ${i}  IN RANGE  ${len}

        Verify Response List  ${resp}  ${i}  ynwUuid=${wid${i+1}}  calculationMode=${calc_mode[2]}
    END
    
JD-TC-Approx Waiting Time-4
    [Documentation]   Check approximate waiting time when calculation mode is ML, batch is enabled, and waitlists are started

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    clear_queue  ${PUSERPH0}
    clear_service   ${PUSERPH0}
    clear_customer  ${PUSERPH0}
    
    ${trnTime}=   Random Int   min=10   max=20
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}   ${trnTime}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[0]}   ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    ${P1SERVICE1}=    FakerLibrary.word
    Set Test Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   5   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_s1}  ${resp.json()} 

    ${resp}=    Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${today}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${today}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${etime1}=  add_timezone_time  ${tz}  1  0  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  Random Int  min=2   max=4
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${today}  ${EMPTY}  10  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${p1_s1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Enable Waitlist Batch   ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add Batch Name   ${p1_q1}  ${prefix}  ${suffix}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['batch']}    ${bool[1]}

    ${count}=  Evaluate  ${parallel} * 3
    FOR  ${i}  IN RANGE  1   ${count+1}
        
        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${i}}
        # Log   ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Test Variable  ${cid}   ${resp.json()[0]['id']}
        ${resp}=  AddCustomer  ${CUSERNAME${i}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid}  ${resp.json()}
        
        # ${cid} =  get_id  ${CUSERNAME${i}}
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${today}  ${desc}  ${bool[1]}  ${cid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${i}}  ${wid[0]}
    END

    ${wtime} =  Set Variable   0
    ${resp}=  Get Waitlist Today  queue-eq=${p1_q1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${len}=   Get Length    ${resp.json()} 
    FOR  ${i}  IN RANGE  ${len}

        ${wtime}=   Run Keyword If   ${i} == ${parallel*1}   Evaluate  ${wtime}+5
        ...         ELSE  Set Variable   ${wtime}
        ${wtime}=   Run Keyword If   ${i} == ${parallel*2}   Evaluate  ${wtime}+5
        ...         ELSE   Set Variable  ${wtime}
        Verify Response List  ${resp}  ${i}  ynwUuid=${wid${i+1}}  appxWaitingTime=${wtime}
    END

    comment    Start first waitlist.

    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  5s
    ${resp}=  Get Waitlist By Id  ${wid1}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['date']}    ${today}
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}    ${wl_status[2]}
    ${resp}=  Get Waitlist Today  queue-eq=${p1_q1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    ${wtime} =  Set Variable   0
    ${len}=   Get Length    ${resp.json()}
    FOR  ${i}  IN RANGE  1  ${len}

        ${wtime}=   Run Keyword If   ${i} == ${parallel*1}   Evaluate  ${wtime}+5
        ...         ELSE  Set Variable   ${wtime}
        ${wtime}=   Run Keyword If   ${i} == ${parallel*2}   Evaluate  ${wtime}+5
        ...         ELSE   Set Variable  ${wtime}
        Verify Response List  ${resp}  ${i}  ynwUuid=${wid${i+1}}  appxWaitingTime=${wtime}  waitlistStatus=${wl_status[1]}
    END

    comment    Start second waitlist.

    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  5s
    ${resp}=  Get Waitlist By Id  ${wid2}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['date']}    ${today}
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}    ${wl_status[2]}
    ${resp}=  Get Waitlist Today  queue-eq=${p1_q1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    ${wtime} =  Set Variable   0
    ${len}=   Get Length    ${resp.json()}
    FOR  ${i}  IN RANGE  2  ${parallel}
        Verify Response List  ${resp}  ${i}  ynwUuid=${wid${i+1}}  appxWaitingTime=${wtime}  waitlistStatus=${wl_status[1]}
    END
    
    FOR  ${i}  IN RANGE  ${parallel}   ${len}

        ${wtime}=   Run Keyword If   ${i} == ${parallel*1}   Evaluate  ${wtime}+5
        ...         ELSE  Set Variable   ${wtime}
        ${wtime}=   Run Keyword If   ${i} == ${parallel*2}   Evaluate  ${wtime}+5
        ...         ELSE   Set Variable  ${wtime}
        Verify Response List  ${resp}  ${i}  ynwUuid=${wid${i+1}}  appxWaitingTime=${wtime}  waitlistStatus=${wl_status[1]}
    END

    comment    Start all Waitlists in 1 batch.

    Log   ${parallel}
    FOR  ${i}  IN RANGE  2  ${parallel}
        ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid${i+1}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END
    sleep  5s
    Log  ${parallel}

    FOR  ${i}  IN RANGE  2  ${parallel}
        ${resp}=  Get Waitlist By Id  ${wid${i}}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['date']}    ${today}
        Should Be Equal As Strings  ${resp.json()['waitlistStatus']}    ${wl_status[2]}
    END
    ${wtime} =  Set Variable   0
    ${resp}=  Get Waitlist Today  queue-eq=${p1_q1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=   Get Length    ${resp.json()}

    FOR  ${i}  IN RANGE  ${parallel}
        Should Be Equal As Strings   ${resp.json()[${i}]['ynwUuid']}   ${wid${i+1}}
        Verify Response List  ${resp}  ${i}  ynwUuid=${wid${i+1}}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    END

    FOR  ${i}  IN RANGE  ${parallel}  ${len}

        ${wtime}=   Run Keyword If   ${i} == ${parallel*1}   Evaluate  ${wtime}+5
        ...         ELSE  Set Variable   ${wtime}
        ${wtime}=   Run Keyword If   ${i} == ${parallel*2}   Evaluate  ${wtime}+5
        ...         ELSE   Set Variable  ${wtime}
        Verify Response List  ${resp}  ${i}  ynwUuid=${wid${i+1}}  appxWaitingTime=${wtime}  waitlistStatus=${wl_status[1]}
    END
*** Comments ***
JD-TC-Approx Waiting Time-5
    [Documentation]   Check approximate waiting time when calculation mode is ML, batch is enabled, and 1st and 4th waitlists are cancelled

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # ${resp}=   Encrypted Provider Login  ${PUSERNAME31}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    clear_queue  ${PUSERPH0}
    clear_service   ${PUSERPH0}

    ${trnTime}=   Random Int   min=10   max=20
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}   ${trnTime}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[0]}   ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    ${P1SERVICE1}=    FakerLibrary.word
    Set Test Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   5   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_s1}  ${resp.json()} 

    ${resp}=    Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${today}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${today}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${etime1}=  add_timezone_time  ${tz}  1  0  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  Random Int  min=2   max=4
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${today}  ${EMPTY}  10  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${p1_s1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Enable Waitlist Batch   ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add Batch Name   ${p1_q1}  ${prefix}  ${suffix}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['batch']}    ${bool[1]}

    ${count}=  Evaluate  ${parallel} * 3
    FOR  ${i}  IN RANGE  1   ${count+1}
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${i}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid}   ${resp.json()[0]['id']}

        # ${cid} =  get_id  ${CUSERNAME${i}}
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${today}  ${desc}  ${bool[1]}  0
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${i}}  ${wid[0]}
    END

    ${wtime} =  Set Variable   0
    ${resp}=  Get Waitlist Today  queue-eq=${p1_q1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${len}=   Get Length    ${resp.json()} 
    FOR  ${i}  IN RANGE  ${len}

        ${wtime}=   Run Keyword If   ${i} == ${parallel*1}   Evaluate  ${wtime}+5
        ...         ELSE  Set Variable   ${wtime}
        ${wtime}=   Run Keyword If   ${i} == ${parallel*2}   Evaluate  ${wtime}+5
        ...         ELSE   Set Variable  ${wtime}
        Verify Response List  ${resp}  ${i}  ynwUuid=${wid${i+1}}  appxWaitingTime=${wtime}
    END

    comment    cancel first waitlist.

    ${desc}=    FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[0]}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  5s
    ${resp}=  Get Waitlist By Id  ${wid1}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['date']}    ${today}
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}    ${wl_status[4]}

    ${wtime} =  Set Variable   0
    ${resp}=  Get Waitlist Today  queue-eq=${p1_q1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  waitlistStatus=${wl_status[4]}
    ${len}=   Get Length    ${resp.json()}
    FOR  ${i}  IN RANGE  1  ${len}

        ${wtime}=   Run Keyword If   ${i} == ${parallel*1}   Evaluate  ${wtime}+5
        ...         ELSE  Set Variable   ${wtime}
        ${wtime}=   Run Keyword If   ${i} == ${parallel*2}   Evaluate  ${wtime}+5
        ...         ELSE   Set Variable  ${wtime}
        Verify Response List  ${resp}  ${i}  ynwUuid=${wid${i+1}}  appxWaitingTime=${wtime}  waitlistStatus=${wl_status[1]}
    END

    comment    cancel fourth waitlist.

    ${desc}=    FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${wid4}  ${waitlist_cancl_reasn[0]}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  5s
    ${resp}=  Get Waitlist By Id  ${wid4}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['date']}    ${today}
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}    ${wl_status[4]}
    
    ${wtime} =  Set Variable   0
    ${resp}=  Get Waitlist Today  queue-eq=${p1_q1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}    waitlistStatus=${wl_status[4]}
    Verify Response List  ${resp}  3  ynwUuid=${wid4}    waitlistStatus=${wl_status[4]}
    ${len}=   Get Length    ${resp.json()}
    FOR  ${i}  IN RANGE  1  ${parallel}

        Run Keyword If   ${i} == 3  Continue For Loop
        Verify Response List  ${resp}  ${i}  ynwUuid=${wid${i+1}}  appxWaitingTime=${wtime}   waitlistStatus=${wl_status[1]}
    END

    FOR  ${i}  IN RANGE  ${parallel}  ${len}

        
        ${wtime}=   Run Keyword If   ${i} == ${parallel*1}   Evaluate  ${wtime}+5
        ...         ELSE  Set Variable   ${wtime}
        ${wtime}=   Run Keyword If   ${i} == ${parallel*2}   Evaluate  ${wtime}+5
        ...         ELSE   Set Variable  ${wtime}
        Run Keyword If   ${i} == 3  Continue For Loop
        Verify Response List  ${resp}  ${i}  ynwUuid=${wid${i+1}}  appxWaitingTime=${wtime}  waitlistStatus=${wl_status[1]}
    END

    comment    cancel 1st Batch.
    FOR  ${i}  IN RANGE  1  ${parallel}

        Run Keyword If   ${i} == 3  Continue For Loop
        ${desc}=    FakerLibrary.word
        ${resp}=  Waitlist Action Cancel  ${wid${i+1}}  ${waitlist_cancl_reasn[0]}  ${desc}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END
    sleep  5s
    ${wtime} =  Set Variable   0
    ${resp}=  Get Waitlist Today  queue-eq=${p1_q1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    FOR  ${i}  IN RANGE   ${parallel}

        # Run Keyword If   ${i} == 3  Continue For Loop
        Verify Response List  ${resp}  ${i}  ynwUuid=${wid${i+1}}  appxWaitingTime=${wtime}   waitlistStatus=${wl_status[4]}
    END

    FOR  ${i}  IN RANGE  ${parallel}  ${len}

        Run Keyword If   ${i} == 3   Verify Response List  ${resp}  ${i}  ynwUuid=${wid${i+1}}  appxWaitingTime=${wtime}   waitlistStatus=${wl_status[4]}
        Run Keyword If   ${i} == 3  Continue For Loop
        ${wtime}=   Run Keyword If   ${i} == ${parallel*1}   Evaluate  ${wtime}+5
        ...         ELSE  Set Variable   ${wtime}
        ${wtime}=   Run Keyword If   ${i} == ${parallel*2}   Evaluate  ${wtime}+5
        ...         ELSE   Set Variable  ${wtime}
        Verify Response List  ${resp}  ${i}  ynwUuid=${wid${i+1}}  appxWaitingTime=${wtime}  waitlistStatus=${wl_status[1]}
    END

JD-TC-Approx Waiting Time-6
    [Documentation]   Check approximate waiting time when calculation mode is ML, batch is enabled, and 1st checkIn is completed
    ${resp}=   Encrypted Provider Login  ${PUSERNAME33}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    clear_queue  ${PUSERNAME33}
    clear_service   ${PUSERNAME33}
    ${trnTime}=   Random Int   min=10   max=20
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}   ${trnTime}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[0]}   ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    ${P1SERVICE1}=    FakerLibrary.word
    Set Test Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   5   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_s1}  ${resp.json()} 
    ${resp}=    Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${today}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${today}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${etime1}=  add_timezone_time  ${tz}  1  0  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  Random Int  min=2   max=4
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${today}  ${EMPTY}  10  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${p1_s1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_q1}  ${resp.json()}
    ${resp}=  Enable Waitlist Batch   ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Add Batch Name   ${p1_q1}  ${prefix}  ${suffix}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['batch']}    ${bool[1]}

    ${count}=  Evaluate  ${parallel} * 3
    FOR  ${i}  IN RANGE  1   ${count+1}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${i}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid}   ${resp.json()[0]['id']}

        # ${cid} =  get_id  ${CUSERNAME${i}}
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${today}  ${desc}  ${bool[1]}  0
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${i}}  ${wid[0]}
    END
    ${wtime} =  Set Variable   0
    ${resp}=  Get Waitlist Today  queue-eq=${p1_q1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${len}=   Get Length    ${resp.json()} 
    FOR  ${i}  IN RANGE  ${len}
        ${wtime}=   Run Keyword If   ${i} == ${parallel*1}   Evaluate  ${wtime}+5
        ...         ELSE  Set Variable   ${wtime}
        ${wtime}=   Run Keyword If   ${i} == ${parallel*2}   Evaluate  ${wtime}+5
        ...         ELSE   Set Variable  ${wtime}
        Verify Response List  ${resp}  ${i}  ynwUuid=${wid${i+1}}  appxWaitingTime=${wtime}
    END
    comment    complete first waitlist.
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action  ${waitlist_actions[4]}  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${wid1}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['date']}    ${today}
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}    ${wl_status[5]}
    
    ${wtime} =  Set Variable   0
    ${resp}=  Get Waitlist Today  queue-eq=${p1_q1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  waitlistStatus=${wl_status[5]}
    ${len}=   Get Length    ${resp.json()}
    FOR  ${i}  IN RANGE  1  ${len}
        ${wtime}=   Run Keyword If   ${i} == ${parallel*1}   Evaluate  ${wtime}+5
        ...         ELSE  Set Variable   ${wtime}
        ${wtime}=   Run Keyword If   ${i} == ${parallel*2}   Evaluate  ${wtime}+5
        ...         ELSE   Set Variable  ${wtime}
        Verify Response List  ${resp}  ${i}  ynwUuid=${wid${i+1}}  appxWaitingTime=${wtime}  waitlistStatus=${wl_status[1]}
    END
    comment    complete first batch.
    
    FOR  ${i}  IN RANGE   1   ${parallel}
        ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid${i+1}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Waitlist Action  ${waitlist_actions[4]}  ${wid${i+1}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END
    ${wtime} =  Set Variable   0
    ${resp}=  Get Waitlist Today  queue-eq=${p1_q1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  waitlistStatus=${wl_status[5]}
    ${len}=   Get Length    ${resp.json()}
    
    FOR  ${i}  IN RANGE  ${parallel}
        Verify Response List  ${resp}  ${i}  ynwUuid=${wid${i+1}}  appxWaitingTime=${wtime}   waitlistStatus=${wl_status[5]}
    END
    FOR  ${i}  IN RANGE  ${parallel}  ${len}
        ${wtime}=   Run Keyword If   ${i} == ${parallel*1}   Evaluate  ${wtime}+5
        ...         ELSE  Set Variable   ${wtime}
        ${wtime}=   Run Keyword If   ${i} == ${parallel*2}   Evaluate  ${wtime}+5
        ...         ELSE   Set Variable  ${wtime}
        Verify Response List  ${resp}  ${i}  ynwUuid=${wid${i+1}}  appxWaitingTime=${wtime}  waitlistStatus=${wl_status[1]}
    END

JD-TC-Approx Waiting Time-7
    [Documentation]   update parallel serving and check waiting time.

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    clear_queue  ${PUSERPH0}
    clear_service   ${PUSERPH0}

    ${trnTime}=   Random Int   min=10   max=20
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}   ${trnTime}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[0]}   ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    
    ${P1SERVICE1}=    FakerLibrary.word
    Set Test Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   5   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_s1}  ${resp.json()} 

    ${resp}=    Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${today}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${today}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${etime1}=  add_timezone_time  ${tz}  1  0  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  Random Int  min=2   max=4
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${today}  ${EMPTY}  10  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${p1_s1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Enable Waitlist Batch   ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add Batch Name   ${p1_q1}  ${prefix}  ${suffix}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['batch']}    ${bool[1]}

    ${count}=  Evaluate  ${parallel} * 3
    FOR  ${i}  IN RANGE  1   ${count+1}
        
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${i}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid}   ${resp.json()[0]['id']}
        
        # ${cid} =  get_id  ${CUSERNAME${i}}
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${today}  ${desc}  ${bool[1]}  0
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${i}}  ${wid[0]}
    END

    ${wtime} =  Set Variable   0
    ${resp}=  Get Waitlist Today  queue-eq=${p1_q1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${len}=   Get Length    ${resp.json()} 
    FOR  ${i}  IN RANGE  ${len}

        ${wtime}=   Run Keyword If   ${i} == ${parallel*1}   Evaluate  ${wtime}+5
        ...         ELSE  Set Variable   ${wtime}
        ${wtime}=   Run Keyword If   ${i} == ${parallel*2}   Evaluate  ${wtime}+5
        ...         ELSE   Set Variable  ${wtime}
        Verify Response List  ${resp}  ${i}  ynwUuid=${wid${i+1}}  appxWaitingTime=${wtime}
    END

    comment    update parallel serving

    FOR  ${i}  IN RANGE  ${len}
        ${parallel1}=  Random Int  min=2   max=4
        Run Keyword If    ${parallel1} != ${parallel}   Exit For Loop
        ...  ELSE  Continue For Loop
    END

    ${resp}=  Update Queue  ${p1_q1}  ${p1queue1}  ${recurringtype[1]}  ${list}  ${today}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel1}  ${capacity}  ${lid}  ${p1_s1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel1}
    Should Be Equal As Strings  ${resp.json()['batch']}    ${bool[1]}
    
    ${wtime} =  Set Variable   0
    ${resp}=  Get Waitlist Today  queue-eq=${p1_q1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  waitlistStatus=${wl_status[5]}
    ${len}=   Get Length    ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}

        ${wtime}=   Run Keyword If   ${i} == ${parallel1*1}   Evaluate  ${wtime}+5
        ...         ELSE  Set Variable   ${wtime}
        ${wtime}=   Run Keyword If   ${i} == ${parallel1*2}   Evaluate  ${wtime}+5
        ...         ELSE   Set Variable  ${wtime}
        Verify Response List  ${resp}  ${i}  ynwUuid=${wid${i+1}}  appxWaitingTime=${wtime}  waitlistStatus=${wl_status[1]}
    END


JD-TC-Approx Waiting Time-8
    [Documentation]   update service duration and check waiting time.

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    clear_queue  ${PUSERPH0}
    clear_service   ${PUSERPH0}

    ${trnTime}=   Random Int   min=10   max=20
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}   ${trnTime}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[0]}   ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    
    ${P1SERVICE1}=    FakerLibrary.word
    Set Test Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   5   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_s1}  ${resp.json()} 

    ${resp}=    Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${today}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${today}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${etime1}=  add_timezone_time  ${tz}  1  0  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  Random Int  min=2   max=4
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${today}  ${EMPTY}  10  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${p1_s1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Enable Waitlist Batch   ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add Batch Name   ${p1_q1}  ${prefix}  ${suffix}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['batch']}    ${bool[1]}

    ${count}=  Evaluate  ${parallel} * 3
    FOR  ${i}  IN RANGE  1   ${count+1}
        
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${i}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid}   ${resp.json()[0]['id']}
        
        # ${cid} =  get_id  ${CUSERNAME${i}}
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${today}  ${desc}  ${bool[1]}  0
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${i}}  ${wid[0]}
    END

    ${wtime} =  Set Variable   0
    ${resp}=  Get Waitlist Today  queue-eq=${p1_q1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${len}=   Get Length    ${resp.json()} 
    FOR  ${i}  IN RANGE  ${len}

        ${wtime}=   Run Keyword If   ${i} == ${parallel*1}   Evaluate  ${wtime}+5
        ...         ELSE  Set Variable   ${wtime}
        ${wtime}=   Run Keyword If   ${i} == ${parallel*2}   Evaluate  ${wtime}+5
        ...         ELSE   Set Variable  ${wtime}
        Verify Response List  ${resp}  ${i}  ynwUuid=${wid${i+1}}  appxWaitingTime=${wtime}
    END

    comment    update service duration

    ${srv_duration}=  Random Int  min=6   max=10

    ${resp}=  Update Service  ${p1_s1}  ${P1SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}    ${btype}   ${bool[1]}  ${notifytype[2]}  ${EMPTY}   ${servicecharge}    ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Service By Id  ${p1_s1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceDuration']}   ${srv_duration}
    
    ${wtime} =  Set Variable   0
    ${resp}=  Get Waitlist Today  queue-eq=${p1_q1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  waitlistStatus=${wl_status[5]}
    ${len}=   Get Length    ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}

        ${wtime}=   Run Keyword If   ${i} == ${parallel1*1}   Evaluate  ${wtime}+${srv_duration}
        ...         ELSE  Set Variable   ${wtime}
        ${wtime}=   Run Keyword If   ${i} == ${parallel1*2}   Evaluate  ${wtime}+${srv_duration}
        ...         ELSE   Set Variable  ${wtime}
        Verify Response List  ${resp}  ${i}  ynwUuid=${wid${i+1}}  appxWaitingTime=${wtime}  waitlistStatus=${wl_status[1]}
    END
    

    