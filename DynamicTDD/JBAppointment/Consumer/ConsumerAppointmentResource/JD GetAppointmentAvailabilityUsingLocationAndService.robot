*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           random
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${SERVICE1}     manicure 
${SERVICE2}     pedicure
${self}     0
@{service_names}
${digits}       0123456789
@{provider_list}
@{dom_list}
@{multiloc_providers}
${countryCode}   +91
@{service_duration}  10  20  30  40   50



*** Test Cases ***

JD-TC-Get Availability Of Appointment-1

    [Documentation]  Get Availability Of Appointment of Using service id

    ${firstname}  ${lastname}  ${PUSERNAME_B}  ${LoginId}=  Provider Signup
    Set Suite Variable  ${PUSERNAME_B}

    sleep   02s

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_service   ${PUSERNAME_B}
    # clear_location  ${PUSERNAME_B}    
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${list}=  Create List  1  2  3  4  5  6  7
    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${pid}=  get_acc_id  ${PUSERNAME_B}
    Set Suite Variable   ${pid}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}

    ${DAY}=  db.add_timezone_date  ${tz}  1 
    Set Suite Variable   ${DAY}    

    ${DAY2}=  db.add_timezone_date  ${tz}  2  
    Set Suite Variable   ${DAY2}      

    ${DAY3}=  db.add_timezone_date  ${tz}  5 
    Set Suite Variable   ${DAY3}      

    # clear_appt_schedule   ${PUSERNAME_B}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${s_id2}=  Create Sample Service  ${SERVICE2}   maxBookingsAllowed=10
    Set Suite Variable   ${s_id2}
    
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta}   
    ${schedule_name1}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name1}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()} 

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200




   #............provider consumer creation..........


    ${f_Name}=  generate_firstname
    Set Suite Variable  ${f_Name}
    ${l_Name}=  FakerLibrary.last_name
    
    ${resp}=  AddCustomer  ${CUSERNAME7}    firstName=${f_Name}   lastName=${l_Name}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()[0]['id']}

    ${resp}=    Send Otp For Login    ${CUSERNAME7}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME7}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token1}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME7}    ${pid}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    


    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid}  ${DAY1}  ${lid}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()[0]['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Set Test Variable   ${a${i}}  ${resp.json()[0]['availableSlots'][${i}]['time']}
        END
    END
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            # Set Test Variable   ${a${i}}  ${resp.json()[0]['availableSlots'][${i}]['time']}
            # Append To List   ${slots}  ${resp.json()[0]['availableSlots'][${i}]['time']}

                ${resp}=    Get Availability Of Appointment Using Location And Service    ${lid}  ${s_id}
                Log  ${resp.content}
                Should Be Equal As Strings  ${resp.status_code}  200
                ${no}=  Get Length  ${resp.json()}
                @{slots}=  Create List
                FOR  ${j}  IN RANGE   ${no}
                    IF  '${resp.json()[${j}]['date']}' == '${DAY1}'  

                        Should Be Equal As Strings       ${resp.json()[${j}]['scheduleName']}                       ${schedule_name}  
                        Should Be Equal As Strings  ${resp.json()[${j}]['availableSlots'][${j}]['time']}                      ${a${j}}             
                        Should Be Equal As Strings  ${resp.json()[${j}]['date']}                      ${DAY1}                 
                    
                    ELSE IF   '${resp.json()[${j}]['date']}' == '${DAY}'  
                        Should Be Equal As Strings       ${resp.json()[${j}]['scheduleName']}                       ${schedule_name}  
                        Should Be Equal As Strings  ${resp.json()[${j}]['availableSlots'][${j}]['time']}                      ${a${j}}            
                        Should Be Equal As Strings  ${resp.json()[${j}]['date']}                      ${DAY}     

                    ELSE IF   '${resp.json()[${j}]['date']}' == '${DAY2}'  
                        Should Be Equal As Strings       ${resp.json()[${j}]['scheduleName']}                       ${schedule_name}  
                        Should Be Equal As Strings  ${resp.json()[${j}]['availableSlots'][${j}]['time']}                      ${a${j}}           
                        Should Be Equal As Strings  ${resp.json()[${j}]['date']}                      ${DAY2}     
                    END
                END
        END
    END





JD-TC-Get Availability Of Appointment-2

    [Documentation]  Get Availability Of Appointment of Using second service id
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME7}    ${pid}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid}  ${DAY1}  ${lid}  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()[0]['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Set Test Variable   ${a${i}}  ${resp.json()[0]['availableSlots'][${i}]['time']}
        END
    END
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   

                ${resp}=    Get Availability Of Appointment Using Location And Service    ${lid}  ${s_id2}
                Log  ${resp.content}
                Should Be Equal As Strings  ${resp.status_code}  200
                ${no}=  Get Length  ${resp.json()}
                @{slots}=  Create List
                FOR  ${j}  IN RANGE   ${no}
                    IF  '${resp.json()[${j}]['date']}' == '${DAY1}'  

                        Should Be Equal As Strings  ${resp.json()[${j}]['availableSlots'][${j}]['time']}                      ${a${j}}             
                        Should Be Equal As Strings  ${resp.json()[${j}]['date']}                      ${DAY1}                 
                    
                    ELSE IF   '${resp.json()[${j}]['date']}' == '${DAY}'  
                        Should Be Equal As Strings  ${resp.json()[${j}]['availableSlots'][${j}]['time']}                      ${a${j}}             
                        Should Be Equal As Strings  ${resp.json()[${j}]['date']}                      ${DAY}     

                    ELSE IF   '${resp.json()[${j}]['date']}' == '${DAY2}'  
                        Should Be Equal As Strings  ${resp.json()[${j}]['availableSlots'][${j}]['time']}                      ${a${j}}         
                        Should Be Equal As Strings  ${resp.json()[${j}]['date']}                      ${DAY2}     
                    END
                END
        END
    END




JD-TC-Get Availability Of Appointment-3

    [Documentation]  Get Availability Of Appointment using provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=    Get Availability Of Appointment Using Location And Service    ${lid}  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Get Availability Of Appointment-UH1

    [Documentation]  Get Availability Of Appointment without login

    ${resp}=    Get Availability Of Appointment Using Location And Service    ${lid}  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401


JD-TC-Get Availability Of Appointment-UH2

    [Documentation]   Get Availability Of Appointment using invalid service id

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME7}    ${pid}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${delta}=  FakerLibrary.Random Int  min=10  max=60

    ${resp}=    Get Availability Of Appointment Using Location And Service    ${lid}  ${delta}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}    ${NO_PERMISSION}
   


  




