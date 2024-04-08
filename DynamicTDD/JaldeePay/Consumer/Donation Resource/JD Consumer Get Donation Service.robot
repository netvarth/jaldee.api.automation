*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Donation
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
Variables         /ebs/TDD/varfiles/musers.py

*** Variables ***
@{multiples}  10  20  30   40   50
${SERVICE1}   MakeUp
${a}   0
${start}         20
*** Test Cases ***

JD-TC-ConsumerGetDonationService-1
        [Documentation]   Get  a donation service by consumer (billable domain)
        ${resp}=   Billable Domain Providers
        ${description}=  FakerLibrary.sentence
        ${min_don_amt1}=   Random Int   min=100   max=500
        ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
        ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
        ${max_don_amt1}=   Random Int   min=5000   max=10000
        ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
        ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
        ${min_don_amt}=  Convert To Number  ${min_don_amt}  1
        ${max_don_amt}=  Convert To Number  ${max_don_amt}  1
        ${service_duration}=   Random Int   min=10   max=50
        ${total_amnt}=   Random Int   min=100   max=500
        ${total_amnt}=  Convert To Number  ${total_amnt}   1
        ${resp}=  Create Donation Service  ${SERVICE1}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${total_amnt}   ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable  ${id1}  ${resp.json()}
        ${resp}=   Get Service By Id  ${id1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration}   notification=${bool[1]}   notificationType=${notifytype[2]}    bType=${btype}  isPrePayment=${bool[0]}  serviceType=${service_type[0]}  minDonationAmount=${min_don_amt}  maxDonationAmount=${max_don_amt}  multiples=${multiples[0]}
 
        ${resp}=   Consumer Login  ${CUSERNAME9}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Get Donation Service By Consumer  ${acc_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response List  ${resp}  0  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration}   notification=${bool[1]}   notificationType=${notifytype[2]}     bType=${btype}  isPrePayment=${bool[0]}  serviceType=${service_type[0]}  minDonationAmount=${min_don_amt}  maxDonationAmount=${max_don_amt}  multiples=${multiples[0]}

JD-TC-ConsumerGetDonationService-2
        [Documentation]   Get  a donation service by consumer (Nonbillable domain)
        ${resp}=   Non Billable
        ${description}=  FakerLibrary.sentence
        ${min_don_amt1}=   Random Int   min=100   max=500
        ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
        ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
        ${max_don_amt1}=   Random Int   min=5000   max=10000
        ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
        ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
        ${min_don_amt}=  Convert To Number  ${min_don_amt}  1
        ${max_don_amt}=  Convert To Number  ${max_don_amt}  1
        ${service_duration}=   Random Int   min=10   max=50
        ${total_amnt}=   Random Int   min=100   max=500
        ${total_amnt}=  Convert To Number  ${total_amnt}   1
        ${resp}=  Create Donation Service  ${SERVICE1}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}   ${total_amnt}   ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable  ${id1}  ${resp.json()}
        ${resp}=   Get Service By Id  ${id1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration}   notification=${bool[1]}   notificationType=${notifytype[2]}   bType=${btype}  isPrePayment=${bool[0]}  serviceType=${service_type[0]}  minDonationAmount=${min_don_amt}  maxDonationAmount=${max_don_amt}  multiples=${multiples[0]}
        
        ${resp}=   Consumer Login  ${CUSERNAME9}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Get Donation Service By Consumer  ${acc_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response List  ${resp}  0  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration}   notification=${bool[1]}   notificationType=${notifytype[2]}   bType=${btype}  isPrePayment=${bool[0]}  serviceType=${service_type[0]}  minDonationAmount=${min_don_amt}  maxDonationAmount=${max_don_amt}  multiples=${multiples[0]}
 
JD-TC-ConsumerGetDonationService-UH1
        [Documentation]    Get a donation service without login
        ${resp}=  Get Donation Service By Consumer  ${acc_id}
        Should Be Equal As Strings  ${resp.status_code}  419
        Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-ConsumerGetDonationService-UH2   
        [Documentation]   Get a donation service using provider login
        ${resp}=  Encrypted Provider Login  ${PUSERNAME62}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Get Donation Service By Consumer  ${acc_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"   "${DONATION_SERVICE_NOT_FOUND}"          
        # Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-ConsumerGetDonationService-UH3
        [Documentation]   Get Donation services of a provider but that provider has no donation services
        ${id}=  get_acc_id   ${PUSERNAME20}
        delete_donation_service  ${PUSERNAME20}
        ${resp}=   Consumer Login  ${CUSERNAME9}   ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Get Donation Service By Consumer  ${id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"    "${DONATION_SERVICE_NOT_FOUND}"
        # Should Be Equal As Strings  "${resp.json()}"  ""


*** Keywords ***
Billable Domain Providers
    [Arguments]  ${min}=0   ${max}=260
    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
     
    FOR   ${a}  IN RANGE   ${min}   ${max}
            
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        ${domain}=   Set Variable    ${decrypted_data['sector']}
        ${subdomain}=    Set Variable      ${decrypted_data['subSector']}

        # ${domain}=   Set Variable    ${resp.json()['sector']}
        # ${subdomain}=    Set Variable      ${resp.json()['subSector']}
        ${acc_id}=  get_acc_id  ${PUSERNAME${a}}
        Set Suite Variable   ${acc_id}
        ${resp}=   Get Active License
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=   Get Queues
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=   Get Service
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  View Waitlist Settings
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        IF  ${resp.json()['filterByDept']}==${bool[1]}
            ${resp}=  Toggle Department Disable
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200

        END 
        ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        Should Be Equal As Strings    ${resp.status_code}    200
        delete_donation_service  ${PUSERNAME${a}}
        Set Suite Variable  ${check}    ${resp2.json()['serviceBillable']} 
        Run Keyword IF   '${check}' == 'True'   clear_service       ${PUSERNAME${a}}
        Exit For Loop IF     '${check}' == 'True'

    END   

Non Billable
        [Arguments]  ${min}=0   ${max}=260
        ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
        ${len}=   Split to lines  ${resp}
        ${length}=  Get Length   ${len}

        FOR    ${a}   IN RANGE   ${min}   ${max}
                ${resp}=  Encrypted Provider Login  ${MUSERNAME${a}}  ${PASSWORD}
                Should Be Equal As Strings    ${resp.status_code}    200

                ${decrypted_data}=  db.decrypt_data  ${resp.content}
                Log  ${decrypted_data}
                ${domain}=   Set Variable    ${decrypted_data['sector']}
                ${subdomain}=    Set Variable      ${decrypted_data['subSector']}

                # ${domain}=   Set Variable    ${resp.json()['sector']}
                # ${subdomain}=    Set Variable      ${resp.json()['subSector']}
                ${acc_id}=  get_acc_id  ${MUSERNAME${a}}
                Set Suite Variable   ${acc_id}
                ${resp}=  View Waitlist Settings
                ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[1]}
        ${resp}=  Toggle Department Disable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END  
                ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
                Should Be Equal As Strings    ${resp.status_code}    200
                delete_donation_service  ${MUSERNAME${a}}
                Set Suite Variable  ${check}    ${resp2.json()['serviceBillable']} 
                Run Keyword IF   '${check}' == 'False'   clear_service       ${MUSERNAME${a}}
                Exit For Loop IF     '${check}' == 'False'
        
        END 
