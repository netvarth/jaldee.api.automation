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
@{multiples}  10  21  20  30   40   50
${SERVICE1}   MakeUp
${SERVICE4}   Painting2
${a}   0
${start}         20
*** Test Cases ***

JD-TC-CreateDonationService-1
        [Documentation]   Create  a donation service(billable domain)
        ${resp}=   Billable
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
        ${total_amnt}=  Convert To Number  ${total_amnt}  1
        ${resp}=  Create Donation Service  ${SERVICE1}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${total_amnt}  ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable  ${id1}  ${resp.json()}
        ${resp}=   Get Service By Id  ${id1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration}   notification=${bool[1]}   notificationType=${notifytype[2]}   totalAmount=${total_amnt}   bType=${btype}  isPrePayment=${bool[0]}  serviceType=${service_type[0]}  minDonationAmount=${min_don_amt}  maxDonationAmount=${max_don_amt}  multiples=${multiples[0]}
 
JD-TC-CreateDonationService-2
        [Documentation]   Create  a donation service(Nonbillable domain)
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
        ${SERVICE1}=   FakerLibrary.name
        ${resp}=  Create Donation Service  ${SERVICE1}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}   ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable  ${id1}  ${resp.json()}
        ${resp}=   Get Service By Id  ${id1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration}   notification=${bool[1]}   notificationType=${notifytype[2]}   totalAmount=0.0   bType=${btype}  isPrePayment=${bool[0]}  serviceType=${service_type[0]}  minDonationAmount=${min_don_amt}  maxDonationAmount=${max_don_amt}  multiples=${multiples[0]}
 

JD-TC-CreateDonationService-3
        [Documentation]     Create  a donation service for a valid provider with service name same as another provider        
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
        ${total_amnt}=  Convert To Number  ${total_amnt}  1
        ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        clear_service   ${PUSERNAME2}
        ${SERVICE1}=   FakerLibrary.name
        ${resp}=  Create Donation Service   ${SERVICE1}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[1]}   ${total_amnt}  ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        
        ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        delete_donation_service  ${PUSERNAME150}
        clear_service   ${PUSERNAME150}  
        ${resp}=  Create Donation Service  ${SERVICE1}  ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[1]}  ${total_amnt}   ${bool[0]}  ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
        Log  ${resp.json()}
        Set Suite Variable  ${id1}  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=   Get Service By Id  ${id1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}   serviceDuration=${service_duration}    notification=${bool[1]}  notificationType=${notifytype[1]}   totalAmount=${total_amnt}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  serviceType=${service_type[0]}  minDonationAmount=${min_don_amt}  maxDonationAmount=${max_don_amt}  multiples=${multiples[0]}

JD-TC-CreateDonationService-UH1

        [Documentation]  Create  service for a valid provider when isPrePayment is true
        ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        delete_donation_service  ${PUSERNAME2}
        clear_service   ${PUSERNAME2}
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
        ${SERVICE1}=   FakerLibrary.name
        ${total_amnt}=   Random Int   min=100   max=500
        ${resp}=  Create Donation Service  ${SERVICE1}  ${description}   ${service_duration}  ${btype}    ${bool[1]}    ${notifytype[1]}   ${total_amnt}  ${bool[1]}  ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
        Should Be Equal As Strings  ${resp.status_code}  422  
        Should Be Equal As Strings  "${resp.json()}"  "Prepayment is not allowed for donation services"
        
JD-TC-CreateDonationService-4

        [Documentation]   Create Donation Service in Non Billable Domain 
        ${description}=  FakerLibrary.sentence
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
        ${SERVICE1}=   FakerLibrary.name
        ${resp}=  Create Donation Service  ${SERVICE1}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}   ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable  ${id1}  ${resp.json()}
        ${resp}=   Get Service By Id  ${id1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration}   notification=${bool[1]}   notificationType=${notifytype[2]}    totalAmount=0.0  bType=${btype}  isPrePayment=${bool[0]}  serviceType=${service_type[0]}  minDonationAmount=${min_don_amt}  maxDonationAmount=${max_don_amt}  multiples=${multiples[0]}
 
JD-TC-CreateDonationService-UH2        
        [Documentation]  Create an already existing service
        ${resp}=   Billable
        ${description}=  FakerLibrary.sentence
        ${min_don_amt1}=   Random Int   min=100   max=500
        ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
        ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
        ${max_don_amt1}=   Random Int   min=1000   max=5000
        ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
        ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
        ${min_don_amt}=  Convert To Number  ${min_don_amt}  1
        ${max_don_amt}=  Convert To Number  ${max_don_amt}  1
        ${service_duration}=   Random Int   min=10   max=50
        ${SERVICE1}=   FakerLibrary.name
        ${total_amnt}=   Random Int   min=100   max=500
        ${resp}=  Create Donation Service  ${SERVICE1}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}   ${total_amnt}  ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        ${resp}=  Create Donation Service  ${SERVICE1}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}   ${total_amnt}  ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_CANT_BE_SAME}"     
 
JD-TC-CreateDonationService-UH3
        [Documentation]    Create a service without login
        ${description}=  FakerLibrary.sentence
        ${min_don_amt1}=   Random Int   min=100   max=500
        ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
        ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
        ${max_don_amt1}=   Random Int   min=1000   max=5000
        ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
        ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
        ${min_don_amt}=  Convert To Number  ${min_don_amt}  1
        ${max_don_amt}=  Convert To Number  ${max_don_amt}  1
        ${service_duration}=   Random Int   min=10   max=50
        ${total_amnt}=   Random Int   min=100   max=500
        ${resp}=  Create Donation Service  ${SERVICE1}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${total_amnt}  ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  419
        Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-CreateDonationService-UH4    
        [Documentation]   Create a service using consumer login
        ${resp}=  ConsumerLogin  ${CUSERNAME7}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${description}=  FakerLibrary.sentence
        ${min_don_amt1}=   Random Int   min=100   max=500
        ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
        ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
        ${max_don_amt1}=   Random Int   min=1000   max=5000
        ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
        ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
        ${min_don_amt}=  Convert To Number  ${min_don_amt}  1
        ${max_don_amt}=  Convert To Number  ${max_don_amt}  1
        ${service_duration}=   Random Int   min=10   max=50
        ${total_amnt}=   Random Int   min=100   max=500
        ${resp}=  Create Donation Service  ${SERVICE1}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${total_amnt}   ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  401 
        Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-CreateDonationService-UH5
        [Documentation]   Create Donation Service in the  billabe domain without minimum donation amount
        ${resp}=   Billable
        ${description}=  FakerLibrary.sentence
        ${min_don_amt1}=   Random Int   min=100   max=500
        ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
        ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
        ${max_don_amt1}=   Random Int   min=1000   max=5000
        ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
        ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
        ${min_don_amt}=  Convert To Number  ${min_don_amt}  1
        ${max_don_amt}=  Convert To Number  ${max_don_amt}  1
        ${service_duration}=   Random Int   min=10   max=50
        ${total_amnt}=   Random Int   min=100   max=500
        ${resp}=  Create Donation Service  ${SERVICE1}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${total_amnt}  ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${EMPTY}  ${max_don_amt}  ${multiples[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  422 
        Should Be Equal As Strings   "${resp.json()}"   "${MIN_DONATION_REQUIRED}"

JD-TC-CreateDonationService-UH6
        [Documentation]   Create Donation Service in the  billabe domain without maximum donation amount
        ${resp}=   Billable
        ${description}=  FakerLibrary.sentence
        ${min_don_amt1}=   Random Int   min=100   max=500
        ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
        ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
        ${max_don_amt1}=   Random Int   min=1000   max=5000
        ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
        ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
        ${min_don_amt}=  Convert To Number  ${min_don_amt}  1
        ${max_don_amt}=  Convert To Number  ${max_don_amt}  1
        ${service_duration}=   Random Int   min=10   max=50
        ${total_amnt}=   Random Int   min=100   max=500
        ${resp}=  Create Donation Service  ${SERVICE1}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}   ${total_amnt}  ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${EMPTY}  ${multiples[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  422 
        Should Be Equal As Strings   "${resp.json()}"   "${MAX_DONATION_REQUIRED}"

JD-TC-CreateDonationService-UH7
        [Documentation]   Create Donation Service in the  billabe domain without multiples
        ${resp}=   Billable
        ${description}=  FakerLibrary.sentence
        ${min_don_amt1}=   Random Int   min=100   max=500
        ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
        ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
        ${max_don_amt1}=   Random Int   min=1000   max=5000
        ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
        ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
        ${min_don_amt}=  Convert To Number  ${min_don_amt}  1
        ${max_don_amt}=  Convert To Number  ${max_don_amt}  1
        ${service_duration}=   Random Int   min=10   max=50
        ${total_amnt}=   Random Int   min=100   max=500
        ${resp}=  Create Donation Service  ${SERVICE1}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${total_amnt}  ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${EMPTY}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  422 
        Should Be Equal As Strings   "${resp.json()}"   "${MULTIPLES_REQUIRED}"

JD-TC-CreateDonationService-UH8
        [Documentation]   provider adding donation service to queue
        ${resp}=  Encrypted Provider Login  ${PUSERNAME102}  ${PASSWORD}   
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}   200
        delete_donation_service  ${PUSERNAME102}
        clear_service   ${PUSERNAME102}
        clear_queue      ${PUSERNAME102}
        clear_location   ${PUSERNAME102}
        ${acc_id}=  get_acc_id  ${PUSERNAME102}
        ${resp}=   Create Sample Location
        Set Suite Variable    ${loc_id1}    ${resp} 

        ${resp}=   Get Location ById  ${loc_id1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 
        ${description}=  FakerLibrary.sentence
        ${min_don_amt1}=   Random Int   min=100   max=500
        ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
        ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
        ${max_don_amt1}=   Random Int   min=1000   max=5000
        ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
        ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
        ${min_don_amt}=  Convert To Number  ${min_don_amt}  1
        ${max_don_amt}=  Convert To Number  ${max_don_amt}  1
        ${service_duration}=   Random Int   min=10   max=50
        ${total_amnt}=   Random Int   min=100   max=500
        ${resp}=  Create Donation Service  ${SERVICE4}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${total_amnt}  ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable  ${sid5}  ${resp.json()}
        ${DAY1}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${DAY1}
        ${DAY2}=  db.add_timezone_date  ${tz}  10        
        Set Suite Variable  ${DAY2}
        ${list}=  Create List  1  2  3  4  5  6  7
        Set Suite Variable  ${list}
        ${sTime1}=  add_timezone_time  ${tz}  0  15  
        Set Suite Variable   ${sTime1}
        ${eTime1}=  add_timezone_time  ${tz}  0  30  
        Set Suite Variable   ${eTime1}
 
        ${queue_name}=  FakerLibrary.bs
        ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${loc_id1}  ${sid5}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings   "${resp.json()}"   "${DONATION_SERVICE_QUEUE}"

JD-TC-CreateDonationService-5

        [Documentation]  Create  service for a valid provider without service price.
        ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        delete_donation_service  ${PUSERNAME2}
        clear_service   ${PUSERNAME2}
        ${description}=  FakerLibrary.sentence
        ${min_don_amt1}=   Random Int   min=100   max=500
        ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
        ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
        ${max_don_amt1}=   Random Int   min=1000   max=5000
        ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
        ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
        ${min_don_amt}=  Convert To Number  ${min_don_amt}  1
        ${max_don_amt}=  Convert To Number  ${max_don_amt}  1
        ${service_duration}=   Random Int   min=10   max=50
        ${SERVICE1}=   FakerLibrary.name
        ${resp}=  Create Donation Service  ${SERVICE1}  ${description}   ${service_duration}  ${btype}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}   ${bool[0]}  ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
        Should Be Equal As Strings  ${resp.status_code}  200  
        # Should Be Equal As Strings  ${resp.status_code}  422  
        # Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_AMOUNT_CANT_BE_NULL}"
        
JD-TC-CreateDonationService-UH9

        [Documentation]  Create  service for a valid provider without giving proper multiples
        ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        delete_donation_service  ${PUSERNAME2}
        clear_service   ${PUSERNAME2}
        ${description}=  FakerLibrary.sentence
        ${Total1}=   Random Int   min=100   max=500
        ${Total1}=  Convert To Number  ${Total1}  1
        ${min_don_amt1}=   Random Int   min=100   max=500
        ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
        ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
        ${max_don_amt1}=   Random Int   min=1000   max=5000
        ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
        ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
        ${min_don_amt}=  Convert To Number  ${min_don_amt}  1
        ${max_don_amt}=  Convert To Number  ${max_don_amt}  1
        ${service_duration}=   Random Int   min=10   max=50
        ${SERVICE1}=   FakerLibrary.name

        ${MULTIPLES_DOES_NOT_MATCH}=  Format String  ${MULTIPLES_DOES_NOT_MATCH}  ${multiples[1]}
        ${resp}=  Create Donation Service  ${SERVICE1}  ${description}   ${service_duration}  ${btype}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${bool[0]}  ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[1]}
        Should Be Equal As Strings  ${resp.status_code}  422  
        Log  ${resp.json()}
        Should Be Equal As Strings  "${resp.json()}"  "${MULTIPLES_DOES_NOT_MATCH}"
        





*** Keywords ***
Billable

    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
     
    FOR   ${a}  IN RANGE  ${start}   ${length}
            
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        ${domain}=   Set Variable    ${decrypted_data['sector']}
        ${subdomain}=    Set Variable      ${decrypted_data['subSector']}

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

    ${resp}=   Get File    /ebs/TDD/varfiles/musers.py
        ${len}=   Split to lines  ${resp}
        ${length}=  Get Length   ${len}

     FOR    ${a}   IN RANGE  ${start}    ${length}
        ${resp}=  Encrypted Provider Login  ${MUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        ${domain}=   Set Variable    ${decrypted_data['sector']}
        ${subdomain}=    Set Variable      ${decrypted_data['subSector']}
        
        # ${domain}=   Set Variable    ${resp.json()['sector']}
        # ${subdomain}=    Set Variable      ${resp.json()['subSector']}
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
