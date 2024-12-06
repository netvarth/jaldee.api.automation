*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Service Advance payment
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           Process
Library           OperatingSystem
Library           /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
@{service_names}
${self}      0

*** Test Cases ***

JD-TC-WL-Mock_payment-1
    [Documentation]   testing wl mock payment

    ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERPH0}=  Provider Signup
    Set Suite Variable  ${PUSERPH0}
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}   
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

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

    ${resp}=  Get jp finance settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}

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

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        Set Suite Variable   ${lid}
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${resp}=    Get Service   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${FOUND}  Set Variable  False
    ELSE 
        ${FOUND}  Set Variable  False 
        FOR  ${service}  IN  @{resp.json()}
            IF   ${service['isPrePayment']} == ${bool[1]}
                ${FOUND}  Set Variable  True
                Set Test Variable  ${min_pre}  ${service['minPrePaymentAmount']}
                Set Test Variable  ${s_id}   ${service['id']}
                BREAK
            END
        END
    END
    IF   not ${FOUND}
        ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
        ${maxbookings}=   Random Int   min=1   max=10
        ${SERVICE1}=    generate_unique_service_name  ${service_names}
        Append To List  ${service_names}  ${SERVICE1}
        ${s_id}=  Create Sample Service  ${SERVICE1}   isPrePayment=${bool[1]}  minPrePaymentAmount=${min_pre}  maxBookingsAllowed=${maxBookings}  prePaymentType=${advancepaymenttype[1]}
        ${resp}=   Get Service By Id  ${s_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${min_pre}  ${resp.json()['minPrePaymentAmount']}
    END

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${service_amount}  ${resp.json()['totalAmount']}

    ${resp}=  Sample Queue  ${lid}   ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${qid}  ${resp.json()}

    ${resp}=  ProviderLogout  
    Should Be Equal As Strings    ${resp.status_code}    200

    ${CUSERNAME9}  ${token}  Create Sample Customer  ${account_id}  primaryMobileNo=${CUSERNAME9}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME9}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${cid1}  ${resp.json()['providerConsumer']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${desc}=   FakerLibrary.word
    ${EMPTY_List}=  Create List
    ${resp}=  Waitlist AdvancePayment Details   ${account_id}  ${qid}  ${DAY1}  ${s_id}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${service_amount}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     ${min_pre}
    
    ${msg}=  FakerLibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Add To Waitlist Consumers  ${cid1}  ${account_id}  ${qid}  ${DAY1}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]} 
    
    ${balamount}=  Evaluate  ${service_amount}-${min_pre}
    ${balamount}=  twodigitfloat  ${balamount}  

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentStatus']}   ${paymentStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}  ${wl_status[3]}

    ${resp}=  Make payment Consumer Mock  ${account_id}  ${min_pre}  ${purpose[0]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
