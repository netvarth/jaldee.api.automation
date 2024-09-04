*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment  Waitlist
Library           Collections
Library           OperatingSystem
Library           String
Library           json
Library           random
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot

*** Variables ***
@{Views}  self  all  customersOnly
${count}  ${1000}



*** Test Cases ***

JD-TC-Login-1
    [Documentation]   Add To waitlist
    ${providers_list}=   Get File    ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py
    ${pro_list}=   Split to lines  ${providers_list}
    ${pro}=  Remove String    ${pro_list[0]}    ${SPACE}
    ${pro} 	${ph}=   Split String    ${pro}  =
    # ${cust_pro}=  Evaluate  random.choice(list(open('${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py')))  random
    # Log  ${cust_pro}
    # ${cust_pro}=   Set Variable  ${cust_pro.strip()}
    # ${var} 	${ph}=   Split String    ${cust_pro}  =  
    Set Suite Variable  ${ph}

    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}
    Set Test Variable  ${provider_name}  ${decrypted_data['userName']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    # ${SERVICE8}=    FakerLibrary.job
    # ${min_pre}=   Random Int   min=10   max=50
    # ${servicecharge}=   Random Int  min=100  max=200
    # ${s_id8}=  Create Sample Service with Prepayment   ${SERVICE8}  ${min_pre}  ${servicecharge}  maxBookingsAllowed=10
    # Set Suite Variable  ${s_id8}
    
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' != '${emptylist}'
        
        ${service_len}=  Get Length   ${resp.json()}
        FOR   ${i}  IN RANGE   ${service_len}
            IF  '${resp.json()[${i}]['status']}' == '${status[0]}'
                Set Test Variable   ${s_id}   ${resp.json()[${i}]['id']}

                ${resp1}=   Get Service By Id  ${s_id}
                Log  ${resp1.content}
                Should Be Equal As Strings  ${resp1.status_code}  200

                IF  '${resp.json()[${i}]['isPrePayment']}' == '${bool[1]}'
                    ${resp1}=   Get Service By Id  ${s_id}
                    Log  ${resp1.content}
                    Should Be Equal As Strings  ${resp1.status_code}  200
                ELSE

                    ${resp1}=   Get Service By Id  ${s_id}
                    Log  ${resp1.content}
                    Should Be Equal As Strings  ${resp1.status_code}  200

                END
                BREAK

                # ${resp}=  Disable service  ${s_id}  
                # Should Be Equal As Strings  ${resp.status_code}  200

            END
        END

        ${srv_val}=    Get Variable Value    ${s_id}
        IF  '${srv_val}'=='${None}'
            ${SERVICE1}=    FakerLibrary.job
            ${maxbookings}=   Random Int   min=5   max=10
            ${s_id}=  Create Sample Service  ${SERVICE1}  maxBookingsAllowed=${count}
        END
    ELSE

        ${SERVICE1}=    FakerLibrary.job
        ${maxbookings}=   Random Int   min=5   max=10
        ${s_id}=  Create Sample Service  ${SERVICE1}  maxBookingsAllowed=${count}

    END

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200