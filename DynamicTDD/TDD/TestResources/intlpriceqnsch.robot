*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Service
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/providers.py

*** Variables ***
@{service_duration}  10  20  30   40   50
${self}     0
@{empty_list}
${zero_amt}   ${0.0}

*** Test Cases ***

JD-TC-CreateService-28 

    [Documentation]   Create service with supportInternationalConsumer and prePaymentType as percentage

    ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    clear_service   ${PUSERNAME27}
    
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Locations
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${SERVICE1}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
    ${intlamt}=  Pyfloat  right_digits=1  min_value=250  max_value=500
    ${srv_duration}=   Random Int   min=5   max=10
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}  prePaymentType=${advancepaymenttype[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE1}  description=${desc}  serviceDuration=${srv_duration}   totalAmount=${servicecharge}  status=${status[0]}  isPrePayment=${bool[1]}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}

    ${list}=  Create List   1  2  3  4  5  6  7
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10       
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  30  
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}

    ${resp}=   Consumer Login  ${CUSERNAME8}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${desc}=   FakerLibrary.word
    ${EMPTY_List}=  Create List
    ${resp}=  Waitlist AdvancePayment Details   ${account_id}  ${qid1}  ${DAY1}  ${s_id}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}  ${servicecharge}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}  ${min_pre}