
*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        Queue
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***
${SERVICE1}  Makeup  
${SERVICE2}  Hair makeup
${SERVICE3}  Face Makeup  
${SERVICE4}  Facial
@{countryCode}   91  +91  48 
@{emptylist} 

*** Test Cases ***

JD-TC-MakeAvailable-1
    [Documentation]  set to makeavailable a user giving current time as start time
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     
    ${ph1}=  Evaluate  ${HLPUSERNAME19}+1000410004
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
    
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${ph1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCode[1]}  ${ph1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${p1_id}   ${resp.json()[0]['id']}
    # Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}

    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}
    Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}

    ${sTime1}=  db.get_time_by_timezone  ${tz}
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    Set Suite Variable   ${eTime1}

    ${resp}=  SendProviderResetMail   ${ph1}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${ph1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  Encrypted Provider Login  ${ph1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${resp}=  Is Available Queue Now ByProviderId    ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}   availableNow=${bool[0]}

    # ${queue_name}=  FakerLibrary.name
    # ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id}  ${s_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${que_id}  ${resp.json()}

    ${list}=  Create List   1  2  3  4  5  6  7
    ${queue}=    FakerLibrary.word
    ${resp}=  Make Available   ${queue}   ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${sTime1}  ${eTime1}  ${lid}  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Is Available Queue Now ByProviderId    ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}   availableNow=${bool[1]}  holiday=${bool[0]}   instanceQueueId=${p1_q1} 
    Should Be Equal As Strings   ${resp.json()['timeRange']['sTime']}             ${sTime1}  
    Should Be Equal As Strings   ${resp.json()['timeRange']['eTime']}             ${eTime1}
    

JD-TC-MakeAvailable-2
    [Documentation]  check Queue AvailableNow and call terminate call then check availability
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${ph1}=  Evaluate  ${HLPUSERNAME19}+1000420004
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
    
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${ph1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCode[1]}  ${ph1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}

    ${resp}=  SendProviderResetMail   ${ph1}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${ph1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  Encrypted Provider Login  ${ph1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    # ${sTime2}=  db.get_time_by_timezone  ${tz}  
    ${sTime2}=  db.get_time_by_timezone  ${tz}  
    ${eTime2}=  add_timezone_time  ${tz}  1  00  

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${resp}=  Is Available Queue Now ByProviderId    ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}   availableNow=${bool[0]}

    ${list}=  Create List   1  2  3  4  5  6  7
    ${queue}=    FakerLibrary.word
    ${resp}=  Make Available   ${queue}   ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${sTime2}  ${eTime2}  ${lid}  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_q2}  ${resp.json()}
  
    ${resp}=  Is Available Queue Now ByProviderId    ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}   availableNow=${bool[1]}  holiday=${bool[0]}   instanceQueueId=${p1_q2} 
    Should Be Equal As Strings   ${resp.json()['timeRange']['sTime']}             ${sTime2}  
    Should Be Equal As Strings   ${resp.json()['timeRange']['eTime']}             ${eTime2}

    ${resp}=  Get queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   []

    ${resp}=  Get Queue ById  ${p1_q2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}    ${p1_q2}
    Should Be Equal As Strings  ${resp.json()['name']}    availabiliyQ
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[4]}
    # Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}   ['4']
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime2}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()['capacity']}  10
    Should Be Equal As Strings  ${resp.json()['queueState']}  ENABLED
    
    ${resp}=  Terminate Availability Queue    ${p1_q2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Is Available Queue Now ByProviderId    ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}   availableNow=${bool[0]}
    Verify Response    ${resp}   holiday=${bool[0]}

JD-TC-MakeAvailable-3
    [Documentation]  set to makeavailable a user giving future time as start time
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME81}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sud_domain_id1}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id1}  ${resp.json()['departments'][0]['departmentId']}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id1}   ${resp.json()[0]['id']}
    
    ${ph1}=  Evaluate  ${PUSERNAME81}+1000410004
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
    
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${ph1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCode[1]}  ${ph1}  ${dep_id1}  ${sud_domain_id1}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id2}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    
    ${sTime3}=  add_timezone_time  ${tz}  0  30  
    ${eTime3}=  add_timezone_time  ${tz}  1  00  
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid1}   ${resp.json()[0]['id']}

    ${resp}=  SendProviderResetMail   ${ph1}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${ph1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  Encrypted Provider Login  ${ph1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id1}  ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}

    ${resp}=  Is Available Queue Now ByProviderId    ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}   availableNow=${bool[0]}

    # ${queue_name}=  FakerLibrary.name
    # ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id}  ${s_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${que_id}  ${resp.json()}

    ${list}=  Create List   1  2  3  4  5  6  7
    ${queue}=    FakerLibrary.word
    ${resp}=  Make Available   ${queue}   ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${sTime3}  ${eTime3}  ${lid1}  ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Is Available Queue Now ByProviderId    ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}   availableNow=${bool[0]}  holiday=${bool[0]}   
    
JD-TC-MakeAvailable-4
    [Documentation]  set to makeavailable a default user (account level)giving current time as start time
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME81}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    # ${sTime4}=  db.get_time_by_timezone  ${tz}
    ${eTime4}=  add_timezone_time  ${tz}  1  00  
   
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id1}  ${p1_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}

    ${resp}=  Is Available Queue Now ByProviderId    ${p1_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}   availableNow=${bool[0]}

    ${sTime4}=  db.get_time_by_timezone  ${tz}
    ${list}=  Create List   1  2  3  4  5  6  7
    ${queue}=    FakerLibrary.word
    ${resp}=  Make Available   ${queue}   ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${sTime4}  ${eTime4}  ${lid1}  ${p1_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Is Available Queue Now ByProviderId    ${p1_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}   availableNow=${bool[1]}  holiday=${bool[0]}   instanceQueueId=${p1_q1} 
    Should Be Equal As Strings   ${resp.json()['timeRange']['sTime']}             ${sTime4}  
    Should Be Equal As Strings   ${resp.json()['timeRange']['eTime']}             ${eTime4}

JD-TC-MakeAvailable-5
    [Documentation]  set to makeavailable giving subtract time
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME82}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sud_domain_id2}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id2}  ${resp.json()['departments'][0]['departmentId']}

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${PUSERNAME82}'
                clear_users  ${user_phone}
            END
        END
    END

    ${ph2}=  Evaluate  ${PUSERNAME82}+1000410004
    Set Suite Variable   ${ph2} 
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
    
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${ph2}.${test_mail}   ${userType[0]}  ${pin}  ${countryCode[1]}  ${ph2}  ${dep_id2}  ${sud_domain_id2}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id6}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    
    ${sTime}=  db.subtract_timezone_time  ${tz}  1  15
    ${eTime}=  add_timezone_time  ${tz}  0  30  
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid2}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${resp}=  SendProviderResetMail   ${ph2}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${ph2}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  Encrypted Provider Login  ${ph2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id2}  ${u_id6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}

    ${resp}=  Is Available Queue Now ByProviderId    ${u_id6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}   availableNow=${bool[0]}

    ${list}=  Create List   1  2  3  4  5  6  7
    ${queue}=    FakerLibrary.word
    ${resp}=  Make Available   ${queue}   ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${sTime}  ${eTime}  ${lid2}  ${u_id6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Is Available Queue Now ByProviderId    ${u_id6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response    ${resp}   availableNow=${bool[1]}  holiday=${bool[0]}   instanceQueueId=${p1_q1} 
    Should Be Equal As Strings   ${resp.json()['timeRange']['sTime']}             ${sTime}  
    Should Be Equal As Strings   ${resp.json()['timeRange']['eTime']}             ${eTime}

    ${resp}=  Terminate Availability Queue    ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Is Available Queue Now ByProviderId    ${u_id6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}   availableNow=${bool[0]}
    Verify Response    ${resp}   holiday=${bool[0]}

JD-TC-MakeAvailable-6
    [Documentation]  set to makeavailable giving 2 s delay 
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME82}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    
    ${sTime}=  add_timezone_time  ${tz}  0  02  
    ${eTime}=  add_timezone_time  ${tz}  0  30  

    ${resp}=  Encrypted Provider Login  ${ph2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Is Available Queue Now ByProviderId    ${u_id6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}   availableNow=${bool[0]}

    ${list}=  Create List   1  2  3  4  5  6  7
    ${queue}=    FakerLibrary.word
    ${resp}=  Make Available   ${queue}   ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${sTime}  ${eTime}  ${lid2}  ${u_id6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Is Available Queue Now ByProviderId    ${u_id6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response    ${resp}   availableNow=${bool[0]}  holiday=${bool[0]}  

    # sleep  5s
    ${sTime0}=  db.get_time_by_timezone  ${tz}
    ${resp}=  Is Available Queue Now ByProviderId    ${u_id6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response    ${resp}   availableNow=${bool[0]}  holiday=${bool[0]}   
    # Should Be Equal As Strings   ${resp.json()['timeRange']['sTime']}             ${sTime}  
    # Should Be Equal As Strings   ${resp.json()['timeRange']['eTime']}             ${eTime}

JD-TC-MakeAvailable-UH1
    [Documentation]  check Queue Availabilty without login

    ${list}=  Create List   1  2  3  4  5  6  7
    ${queue}=    FakerLibrary.word
    ${resp}=  Make Available   ${queue}   ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${sTime1}  ${eTime1}  ${lid}  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.content}  "${SESSION_EXPIRED}"

JD-TC-MakeAvailable-UH2
    [Documentation]  check Queue Availabilty with consumer login

    ${resp}=   Consumer Login  ${CUSERNAME8}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${list}=  Create List   1  2  3  4  5  6  7
    ${queue}=    FakerLibrary.word
    ${resp}=  Make Available   ${queue}   ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${sTime1}  ${eTime1}  ${lid}  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.content}  "${LOGIN_NO_ACCESS_FOR_URL}"
    
JD-TC-MakeAvailable-UH3
    [Documentation]  set to makeavailable a provider giving current time as start time

    ${resp}=  Encrypted Provider Login  ${PUSERNAME174}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME174}
    # clear_queue  ${PUSERNAME174}

    ${pid}=  get_acc_id  ${PUSERNAME174}
    Set Suite Variable  ${pid}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid2}   ${resp.json()[0]['id']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7

    ${sTime5}=  db.get_time_by_timezone  ${tz}
    ${eTime5}=  add_timezone_time  ${tz}  1  00  
   
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=  Is Available Queue Now
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${list}=  Create List   1  2  3  4  5  6  7
    ${queue}=    FakerLibrary.word
    ${resp}=  Make Available   ${queue}   ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${sTime5}  ${eTime5}  ${lid2}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}   "You have no permission"

   





























*** Comments ***

    JD-TC-MakeAvailable-3
    [Documentation]  check Queue AvailableNow and try to take waitlist
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${ph1}=  Evaluate  ${HLPUSERNAME19}+1000430004
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
    
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${ph1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCode[1]}  ${ph1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id2}  ${resp.json()}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}
   
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  3  00  

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${resp}=  Is Available Queue Now ByProviderId    ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}   availableNow=${bool[0]}

    ${list}=  Create List   1  2  3  4  5  6  7
    ${queue}=    FakerLibrary.word
    ${resp}=  Make Available   ${queue}   ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${sTime1}  ${eTime1}  ${lid}  ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_q3}  ${resp.json()}
  
    ${resp}=  Is Available Queue Now ByProviderId    ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}   availableNow=${bool[1]}  holiday=${bool[0]}   instanceQueueId=${p1_q3} 
    Should Be Equal As Strings   ${resp.json()['timeRange']['sTime']}             ${sTime1}  
    Should Be Equal As Strings   ${resp.json()['timeRange']['eTime']}             ${eTime1}

    ${resp}=  Get queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   []

    ${resp}=  Get Queue ById  ${p1_q3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

JD-TC-MakeAvailable-UH3
    [Documentation]  check make Availabilty with empty id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME81}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${list}=  Create List   1  2  3  4  5  6  7
    ${queue}=    FakerLibrary.word
    ${resp}=  Make Available   ${queue}   ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${sTime1}  ${eTime1}  ${lid1}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  ${resp.content}  "${LOGIN_NO_ACCESS_FOR_URL}"
