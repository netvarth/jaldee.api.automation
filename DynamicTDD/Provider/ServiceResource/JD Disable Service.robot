*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Service
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           Process
Library           OperatingSystem
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Resource          /ebs/TDD/Keywords.robot

*** Variables ***
${SERVICE5}   SERVICE5
${SERVICE1}   SERVICE1
${SERVICE2}   SERVICE12
${SERVICE3}   SERVICE13
@{service_duration}  10  20  30   40   50


*** Test Cases ***

JD-TC-Disable Service-1

            [Documentation]  Disable Service  of valid provider

            ${description}=  FakerLibrary.sentence
            ${min_pre}=   Random Int   min=10   max=50
            ${Total}=   Random Int   min=100   max=500
            ${min_pre}=  Convert To Number  ${min_pre}  1
            ${Total}=  Convert To Number  ${Total}  1
            ${resp}=  Encrypted Provider Login  ${PUSERNAME71}  ${PASSWORD}
            Should Be Equal As Strings    ${resp.status_code}    200
            clear_service       ${PUSERNAME71}
            ${resp}=  Create Service  ${SERVICE1}   ${description}   ${service_duration[1]}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]} 
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Suite Variable  ${sid}  ${resp.json()}
            ${resp}=   Get Service By Id  ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200
            Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[1]}  notification=${bool[1]}   notificationType=${notifytype[2]}  status=${status[0]}  bType=${btype}  
            ${resp}=  Disable service  ${sid} 
            Should Be Equal As Strings  ${resp.status_code}  200
            ${resp}=   Get Service By Id  ${sid}
            Should Be Equal As Strings  ${resp.status_code}  200
            Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[1]}   notification=${bool[1]}  notificationType=${notifytype[2]}  status=${status[1]}  bType=${btype}   

JD-TC-Disable Service-UH1

            [Documentation]   Disable Service of another provider
            ${description}=  FakerLibrary.sentence
            ${min_pre}=   Random Int   min=10   max=50
            ${Total}=   Random Int   min=100   max=500
            ${min_pre}=  Convert To Number  ${min_pre}  1
            ${Total}=  Convert To Number  ${Total}  1 
            ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
            Should Be Equal As Strings    ${resp.status_code}    200
            clear_service       ${PUSERNAME34}
            ${resp}=  Create Service  ${SERVICE5}    ${description}   ${service_duration[1]}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]} 
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Suite Variable  ${ssid}  ${resp.json()}
            ${resp}=   ProviderLogout
            Should Be Equal As Strings    ${resp.status_code}    200
            ${resp}=  Encrypted Provider Login  ${PUSERNAME55}  ${PASSWORD}
            Should Be Equal As Strings    ${resp.status_code}    200
            ${resp}=  Disable service  ${ssid} 
            Log  ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  401
            Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"


JD-TC-Disable Service-UH2

            [Documentation]   Disable  Invalid service id

            ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
            Should Be Equal As Strings    ${resp.status_code}    200
            ${resp}=  Disable service  0 
            Should Be Equal As Strings  ${resp.status_code}  404
            Should Be Equal As Strings  "${resp.json()}"  "${NO_SUCH_SERVICE}"


JD-TC-Disable Service-UH3

            [Documentation]  Disable a already disabled service

            
            ${resp}=  Encrypted Provider Login  ${PUSERNAME64}  ${PASSWORD}
            Should Be Equal As Strings    ${resp.status_code}    200
            clear_service       ${PUSERNAME64}
            ${resp}=    Create Sample Service  ${SERVICE1}
            Set Suite Variable  ${sid}  ${resp}
            ${resp}=  Disable service  ${sid} 
            Should Be Equal As Strings  ${resp.status_code}  200
            ${resp}=  Disable service  ${sid} 
            Should Be Equal As Strings  ${resp.status_code}  422 
            Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_ALREADY_INACTIVE}"


JD-TC-Disable Service-UH4

            [Documentation]  Disable a service without login

            ${resp}=  Disable service  ${sid} 
            Should Be Equal As Strings  ${resp.status_code}  419
            Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-Disable Service-UH5


            [Documentation]  Disable a service using consumer login
            ${resp}=  ConsumerLogin  ${CUSERNAME7}  ${PASSWORD}
            Should Be Equal As Strings  ${resp.status_code}  200
            ${resp}=  Disable service  ${sid} 
            Should Be Equal As Strings  ${resp.status_code}  401
            Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-Disable Service-UH6
            [Documentation]   Disable a service which in an active checkin(status=prepayment pending)
            ${resp}=  Encrypted Provider Login  ${PUSERNAME78}  ${PASSWORD}
            Should Be Equal As Strings    ${resp.status_code}    200
            clear_service       ${PUSERNAME78}
            ${list}=  Create List   1  2  3  4  5  6  7
            ${DAY1}=  db.get_date_by_timezone  ${tz}
            clear_location  ${PUSERNAME78}
            clear_queue  ${PUSERNAME78}
            ${resp} =  Create Sample Queue
            Set Suite Variable  ${s_id}  ${resp['service_id']}
            Set Suite Variable  ${qid}   ${resp['queue_id']}
            Set Suite Variable  ${lid}   ${resp['location_id']}
            ${resp}=  Get queues
            Should Be Equal As Strings  ${resp.status_code}  200
            ${resp}=   Get Service By Id  ${s_id}
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Test Variable   ${name}  ${resp.json()['name']}     
            Set Test Variable   ${service_duration}  ${resp.json()['serviceDuration']} 
            Set Test Variable   ${description}  ${resp.json()['description']} 
            ${pid}=  get_acc_id  ${PUSERNAME78}
            Set Suite Variable  ${pid}
            
            ${resp}=  ProviderLogout
            Should Be Equal As Strings  ${resp.status_code}  200
            ${resp}=  ConsumerLogin  ${CUSERNAME7}  ${PASSWORD}
            Should Be Equal As Strings  ${resp.status_code}  200
            # ${cid}=  get_id  ${CUSERNAME7}
            # ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+500000
            # ${f_name}=   FakerLibrary.first_name
            # ${l_name}=   FakerLibrary.last_name
            # ${dob}=      FakerLibrary.date
            # ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${cid}  ${f_name}  ${l_name}  ${dob}  ${gender[0]}  ${Familymember_ph}
            # Log  ${resp.json()}
            # Should Be Equal As Strings  ${resp.status_code}  200
            # Set Test Variable  ${mem_id}  ${resp.json()}

            ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY1}  ${s_id}  i need  False  0
            Should Be Equal As Strings  ${resp.status_code}  200
            ${resp}=  Consumer Logout
            Should Be Equal As Strings  ${resp.status_code}  200
            ${resp}=  Encrypted Provider Login  ${PUSERNAME78}  ${PASSWORD}
            Should Be Equal As Strings    ${resp.status_code}    200
            ${resp}=  Disable service  ${s_id} 
            # Should Be Equal As Strings  ${resp.status_code}  200
            # ${resp}=   Get Service By Id  ${sid}
            # Should Be Equal As Strings  ${resp.status_code}  200
            # Verify Response  ${resp}  name=${name}  description=${description}   serviceDuration=${service_duration}   notification=${bool[1]}  notificationType=${notifytype[2]}  status=${status[1]}  bType=${btype}   
            Should Be Equal As Strings  ${resp.status_code}  422
            Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_EXISTS_IN_WAITLIST}"
 
JD-TC-Disable Service-UH7
            
            [Documentation]   Disable a service which in an active checkin(status=checkin)
            
            ${description1}=  FakerLibrary.sentence
            Set Suite Variable   ${description1}
            ${min_pre}=   Random Int   min=10   max=50
            ${Total}=   Random Int   min=100   max=500
            ${min_pre}=  Convert To Number  ${min_pre}  1
            ${Total}=  Convert To Number  ${Total}  1
            ${resp}=  Encrypted Provider Login  ${PUSERNAME78}  ${PASSWORD}
            Should Be Equal As Strings    ${resp.status_code}    200
            clear_service       ${PUSERNAME78}
            ${resp}=  Create Service  ${SERVICE2}   ${description1}   ${service_duration[1]}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]} 
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Suite Variable  ${sid2}  ${resp.json()}
            
            ${resp}=  Create Service  ${SERVICE3}   ${description1}   ${service_duration[1]}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]} 
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Suite Variable  ${sid3}  ${resp.json()}

            ${DAY1}=  db.get_date_by_timezone  ${tz}
            ${list}=  Create List  1  2  3  4  5  6  7
            ${stime2}=  add_timezone_time  ${tz}  1  45  
            ${eTime2}=  add_timezone_time  ${tz}  2  30  
            ${p1queue2}=    FakerLibrary.word
            ${capacity}=  FakerLibrary.Numerify  %%
            ${parallel}=  FakerLibrary.Numerify  %%
            ${resp}=  Create Queue  ${p1queue2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${capacity}  ${lid}  ${sid2}  ${sid3} 
            Log  ${resp.json()} 
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Suite Variable  ${qid1}  ${resp.json()}
    
            ${resp}=  ConsumerLogin  ${CUSERNAME8}  ${PASSWORD}
            Should Be Equal As Strings  ${resp.status_code}  200
            ${cid}=  get_id  ${CUSERNAME8} 
            ${DAY1}=  db.get_date_by_timezone  ${tz}
            ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid1}  ${DAY1}  ${sid2}  i need  False  0
            Should Be Equal As Strings  ${resp.status_code}  200
            ${wid}=  Get Dictionary Values  ${resp.json()}
            Set Suite Variable  ${wid1}  ${wid[0]}
            ${resp}=  Consumer Logout
            Should Be Equal As Strings  ${resp.status_code}  200
            ${resp}=  Encrypted Provider Login  ${PUSERNAME78}  ${PASSWORD}
            Should Be Equal As Strings    ${resp.status_code}    200
            ${resp}=  Disable service  ${sid2} 
            # Should Be Equal As Strings  ${resp.status_code}  200
            # ${resp}=   Get Service By Id  ${sid2}
            # Log   ${resp.json()}
            # Should Be Equal As Strings  ${resp.status_code}  200
            # Verify Response  ${resp}  name=${SERVICE2}  description=${description1}   serviceDuration=${service_duration[1]}   notification=${bool[1]}  notificationType=${notifytype[2]}  status=${status[1]}  bType=${btype}   
            Should Be Equal As Strings  ${resp.status_code}  422
            Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_EXISTS_IN_WAITLIST}"


JD-TC-Disable Service-UH8

            [Documentation]   Disable a service which in an active checkin(status=arrived)
            ${resp}=  ConsumerLogin  ${CUSERNAME9}  ${PASSWORD}
            Should Be Equal As Strings  ${resp.status_code}  200
           
            ${DAY1}=  db.get_date_by_timezone  ${tz}
            ${resp}=  Encrypted Provider Login  ${PUSERNAME78}  ${PASSWORD}
            Should Be Equal As Strings    ${resp.status_code}    200
            clear_customer   ${PUSERNAME78}

            ${resp}=  AddCustomer  ${CUSERNAME9}
            Log   ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Test Variable  ${cid}  ${resp.json()}

            # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME9}
            # Log   ${resp.json()}
            # Should Be Equal As Strings  ${resp.status_code}  200
            # Set Test Variable  ${cid}  ${resp.json()[0]['id']}
            ${resp}=  Add To Waitlist  ${cid}  ${sid3}  ${qid1}  ${DAY1}  hi  True  ${cid}
            Should Be Equal As Strings  ${resp.status_code}  200
            ${resp}=  Disable service  ${sid3} 
            # Should Be Equal As Strings  ${resp.status_code}  200
            # ${resp}=   Get Service By Id  ${sid3}
            # Log   ${resp.json()}
            # Should Be Equal As Strings  ${resp.status_code}  200
            # Verify Response  ${resp}  name=${SERVICE3}  description=${description1}   serviceDuration=${service_duration[1]}   notification=${bool[1]}  notificationType=${notifytype[2]}  status=${status[1]}  bType=${btype}   
            Should Be Equal As Strings  ${resp.status_code}  422
            Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_EXISTS_IN_WAITLIST}" 
            
           
