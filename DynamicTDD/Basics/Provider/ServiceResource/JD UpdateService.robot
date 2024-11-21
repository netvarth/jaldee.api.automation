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
Library           /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

# ${SERVICE1}  S2SERVICE1
# ${SERVICE2}  S2SERVICE2
# ${SERVICE3}  S2SERVICE3
# ${SERVICE4}  S2SERVICE4
# ${SERVICE5}  S2SERVICE5
# ${SERVICE6}  S2SERVICE6
# ${SERVICE7}  S2SERVICE7
# ${SERVICE8}  S2SERVICE8
# ${SERVICE9}  S2SERVICE9
# ${SERVICE10}  S2SERVICE10
# ${SERVICE14}  S2SERVICE14
# @{service_duration}  10  20  30  40   50
# ${defMBVal}  1
# ${defRRVal}  1
# ${defLTVal}  0
@{service_names}

*** Test Cases ***

JD-TC-UpdateService-1
    [Documentation]  update service name for a service.

    ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_A}=  Provider Signup
    Set Suite Variable  ${PUSERNAME_A}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${srv_duration}=   Random Int   min=2   max=10
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${srv_duration}  ${bool[0]}  ${Total}  ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${s_id}  ${resp.json()} 
    
    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}   ${SERVICE1}

    ${SERVICE1.1}=    generate_unique_service_name  ${service_names}
    ${resp}=  Update Service  ${s_id}  ${SERVICE1.1}  ${description}  ${srv_duration}  ${bool[0]}  ${Total}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}   ${SERVICE1.1}


JD-TC-UpdateService-2
    [Documentation]  update service description for a service.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${description}=  FakerLibrary.sentence
    ${resp}=  Update Service  ${s_id}  ${resp.json()[0]['name']}  ${description}  ${resp.json()[0]['serviceDuration']}  ${resp.json()[0]['isPrePayment']}  ${resp.json()[0]['totalAmount']}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['description']}   ${description}


JD-TC-UpdateService-3
    [Documentation]  update service duration for a service.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${srv_duration}=   Random Int   min=2   max=10
    ${resp}=  Update Service  ${s_id}  ${resp.json()[0]['name']}  ${resp.json()[0]['description']}  ${srv_duration}  ${resp.json()[0]['isPrePayment']}  ${resp.json()[0]['totalAmount']}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['serviceDuration']}   ${srv_duration}


*** Comments ***

JD-TC-UpdateService-1

    [Documentation]   update a  service for a valid provider when domain is Billable 
    ${resp}=   Billable
    # clear_service      ${resp}
    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[2]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${id1}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[2]}   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}
    ${resp}=  Update Service  ${id1}  ${SERVICE2}  ${description}  ${service_duration[3]}  ${status[0]}  ${btype}  ${bool[0]}  ${notifytype[0]}  ${min_pre}  ${Total}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Service By Id  ${id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE2}  description=${description}  serviceDuration=${service_duration[3]}   notification=${bool[0]}  notificationType=${notifytype[0]}  minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}

JD-TC-UpdateService-2

    [Documentation]  update a  service for a valid provider when domain is Billable 
    ${resp}=   Billable
    # clear_service      ${resp}
    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${resp}=  Create Service  ${SERVICE5}  ${description}  ${service_duration[2]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${id}  ${resp.json()}
    ${resp}=   Get Service By Id  ${id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE5}  description=${description}  serviceDuration=${service_duration[2]}   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}   bType=${btype}  isPrePayment=${bool[1]}
    ${resp}=  Update Service  ${id}  ${SERVICE5}  ${description}  ${service_duration[3]}  ${status[0]}  ${btype}  ${bool[0]}  ${notifytype[0]}  ${min_pre}  ${Total}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Service By Id  ${id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE5}  description=${description}  serviceDuration=${service_duration[3]}  notification=${bool[0]}  notificationType=${notifytype[0]}  minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}


JD-TC-UpdateService-3
    [Documentation]  update  a service to set prepayment amount 0
    ${resp}=   Billable
    # clear_service      ${resp}
    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${resp}=  Create Service  ${SERVICE4}  ${description}  ${service_duration[1]}  ${status[0]}  ${btype}  ${bool[1]}  ${notifytype[1]}  ${EMPTY}  ${Total}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${id4}  ${resp.json()}
    ${resp}=   Get Service By Id  ${id4}
    Verify Response  ${resp}  name=${SERVICE4}  description=${description}   serviceDuration=${service_duration[1]}    notification=${bool[1]}  notificationType=${notifytype[1]}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
    ${min_pre1}=   FakerLibrary.pyfloat   left_digits=2   right_digits=2   positive=True
    ${Total1}=   FakerLibrary.pyfloat   left_digits=3   right_digits=2   positive=True
    ${resp}=  Update Service  ${id4}  ${SERVICE14}  ${description}  ${service_duration[3]}  ${status[0]}  ${btype}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${Total1}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Service By Id  ${id4}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE14}  description=${description}  serviceDuration=${service_duration[3]}  notification=${bool[1]}  notificationType=${notifytype[2]}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}


JD-TC-UpdateService-4

    [Documentation]   Create a service with prePrePaymentand  and  Update with remove pre payment Amount
    ${resp}=   Billable
    # clear_service      ${resp}
    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${resp}=  Create Service  ${SERVICE6}  ${description}  ${service_duration[3]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${id}  ${resp.json()}
    ${resp}=   Get Service By Id  ${id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE6}  description=${description}   serviceDuration=${service_duration[3]}   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}
    ${resp}=  Update Service  ${id}  ${SERVICE6}  ${description}  ${service_duration[2]}  ${status[0]}  ${btype}  ${bool[0]}  ${notifytype[0]}  0  ${Total}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Service By Id  ${id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE6}  description=${description}  serviceDuration=${service_duration[2]}  notification=${bool[0]}  notificationType=${notifytype[0]}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}     

JD-TC-UpdateService-5

    [Documentation]   Create service in a non billable domain and update service like billable 
    ${resp}=   Non Billable
    # clear_service      ${resp}
    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${resp}=  Create Service  ${SERVICE7}  ${description}  ${service_duration[2]}  ${status[0]}  ${btype}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${EMPTY}  ${bool[0]}  ${bool[0]}
    Set Test Variable   ${id}  ${resp.json()}
    ${resp}=   Get Service By Id  ${id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE7}  description=${description}  serviceDuration=${service_duration[2]}  notification=${bool[1]}  notificationType=${notifytype[2]}  totalAmount=0.0  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
    ${resp}=  Update Service  ${id}  ${SERVICE4}  ${description}  ${service_duration[2]}  ${status[0]}  ${btype}  ${bool[0]}  ${notifytype[0]}  ${min_pre}  ${Total}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Service By Id  ${id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE4}  description=${description}  serviceDuration=${service_duration[2]}  notification=${bool[0]}  notificationType=${notifytype[0]}  totalAmount=0.0  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}


JD-TC-UpdateService-UH1

    [Documentation]  Update a service name to  an already existing name
    ${billable_domains}=  get_billable_domain
    Set Test Variable  ${domains}  ${billable_domains[0]}
    Set Test Variable  ${sub_domains}  ${billable_domains[1]}
    ${firstname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+111246
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
    ${licid}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domains[0]}  ${sub_domains[0]}  ${PUSERPH0}  ${licid[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${PUSERPH0}
    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[3]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id1}  ${resp.json()}
    ${resp}=   Get Service By Id  ${id1}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[3]}   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}
    ${resp}=  Create Service  ${SERVICE2}  ${description}  ${service_duration[4]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id2}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${id2}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  name=${SERVICE2}  description=${description}  serviceDuration=${service_duration[4]}   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}
    ${min_pre1}=   FakerLibrary.pyfloat   left_digits=2   right_digits=2   positive=True
    ${Total1}=   FakerLibrary.pyfloat   left_digits=3   right_digits=2   positive=True
    ${resp}=  Update Service  ${id1}  ${SERVICE2}  ${description}  ${service_duration[4]}  ${status[0]}  ${btype}  ${bool[0]}  ${notifytype[1]}  ${min_pre1}  ${Total1}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}  ${SERVICE_CANT_BE_SAME}

JD-TC-UpdateService-UH2

    [Documentation]  Update a service without login
    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${resp}=  Update Service  ${id}  ${SERVICE1}  ${description}  ${service_duration[3]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}  ${SESSION_EXPIRED}


JD-TC-UpdateService-UH3

    [Documentation]  Update a service using consumer login
    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${resp}=  ConsumerLogin  ${CUSERNAME8}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Service  ${id}  ${SERVICE1}  ${description}  ${service_duration[3]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}  ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-UpdateService-UH4

    [Documentation]  update service of another provider id
    ${description}=  FakerLibrary.sentence

    ${min_pre}=   Random Int  min=1   max=10
    ${Total}=   Random Int  min=11   max=100
    ${resp}=  Encrypted Provider Login  ${PUSERNAME69}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service       ${PUSERNAME69}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[3]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id123}  ${resp.json()}
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME63}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Update Service  ${id123}  ${SERVICE2}  ${description}  ${service_duration[3]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}  ${NO_PERMISSION}

JD-TC-UpdateService-UH6

    [Documentation]  update a  service for a valid provider with 0 Total amount
    ${resp}=   Billable
    # clear_service      ${resp}
    ${description}=  FakerLibrary.sentence
    # ${min_pre}=   FakerLibrary.pyfloat   left_digits=2   right_digits=2   positive=True
    # ${Total}=   FakerLibrary.pyfloat   left_digits=3   right_digits=2   positive=True
    ${min_pre}=   Random Int   min=10   max=20
    ${Total}=   Random Int   min=21   max=40
    ${min_pre}=  Convert To Number  ${min_pre}  0
    ${Total}=  Convert To Number  ${Total}  0
    ${resp}=  Create Service  ${SERVICE8}  ${description}  ${service_duration[2]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${id}  ${resp.json()}
    ${resp}=   Get Service By Id  ${id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE8}  description=${description}  serviceDuration=${service_duration[2]}  notification=${bool[1]}  notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}
    ${resp}=  Update Service  ${id}  ${SERVICE8}  ${description}  ${service_duration[3]}  ${status[0]}  ${btype}  ${bool[0]}  ${notifytype[0]}  ${min_pre}  0  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    #Should Be Equal As Strings  "${resp.json()}"  "${PREPAYMENT_AMT_LT_PRICE}"
        

JD-TC-UpdateService-UH7

    [Documentation]  Create a service with prePrePayment and  Update with remove pre payment Amount
    ${resp}=   Billable
    # clear_service      ${resp}
    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${resp}=  Create Service  ${SERVICE9}  ${description}  ${service_duration[2]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${id}  ${resp.json()}
    ${resp}=   Get Service By Id  ${id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE9}  description=${description}  serviceDuration=${service_duration[2]}  notification=${bool[1]}  notificationType=${notifytype[2]}  minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}
    ${resp}=  Update Service  ${id}  ${SERVICE10}  ${description}  ${service_duration[3]}  ${status[0]}  ${btype}  ${bool[0]}  ${notifytype[0]}  0  ${Total}  ${bool[1]}  ${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${MINIMUM_PREPAYMENT_AMOUNT_SHOULD_BE_PROVIDED}"   



JD-TC-UpdateService-6
    [Documentation]  Update max bookings allowed in a service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    # clear_service   ${PUSERNAME27}

    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=   FakerLibrary.job
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${maxbookings}=   Random Int   min=1   max=5
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  maxBookingsAllowed=${maxbookings}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE1}  serviceDuration=${srv_duration}  status=${status[0]}  maxBookingsAllowed=${maxbookings}

    ${maxbookings}=   Random Int   min=5   max=10
    ${resp}=  Update Service  ${s_id}  ${SERVICE1}  ${desc}  ${srv_duration}  ${status[0]}  ${btype}  ${bool[0]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  maxBookingsAllowed=${maxbookings}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE1}  serviceDuration=${srv_duration}  status=${status[0]}  maxBookingsAllowed=${maxbookings}


JD-TC-UpdateService-7
    [Documentation]  Update priceDynamic in a service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    # clear_service   ${PUSERNAME27}

    
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=   FakerLibrary.job
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    # ${maxbookings}=   Random Int   min=1   max=5
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  priceDynamic=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE1}  serviceDuration=${srv_duration}  status=${status[0]}  priceDynamic=${bool[1]}

    # ${maxbookings}=   Random Int   min=5   max=10
    ${resp}=  Update Service  ${s_id}  ${SERVICE1}  ${desc}  ${srv_duration}  ${status[0]}  ${btype}  ${bool[0]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  priceDynamic=${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE1}  serviceDuration=${srv_duration}  status=${status[0]}  priceDynamic=${bool[0]}

    ${resp}=  Update Service  ${s_id}  ${SERVICE1}  ${desc}  ${srv_duration}  ${status[0]}  ${btype}  ${bool[0]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  priceDynamic=${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE1}  serviceDuration=${srv_duration}  status=${status[0]}  priceDynamic=${bool[1]}


JD-TC-UpdateService-8
    [Documentation]  Update resoucesRequired in a service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    # clear_service   ${PUSERNAME27}

    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=   FakerLibrary.job
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resoucesRequired}=   Random Int   min=1   max=5
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  resoucesRequired=${resoucesRequired}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE1}  serviceDuration=${srv_duration}  status=${status[0]}  resoucesRequired=${resoucesRequired}

    ${resoucesRequired}=   Random Int   min=5   max=10
    ${resp}=  Update Service  ${s_id}  ${SERVICE1}  ${desc}  ${srv_duration}  ${status[0]}  ${btype}  ${bool[0]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  resoucesRequired=${resoucesRequired}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE1}  serviceDuration=${srv_duration}  status=${status[0]}  resoucesRequired=${resoucesRequired}


JD-TC-UpdateService-9
    [Documentation]  Update lead time in a service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    # clear_service   ${PUSERNAME27}

    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=   FakerLibrary.job
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${leadTime}=   Random Int   min=1   max=5
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  leadTime=${leadTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE1}  serviceDuration=${srv_duration}  status=${status[0]}  leadTime=${leadTime}

    ${leadTime}=   Random Int   min=5   max=10
    ${resp}=  Update Service  ${s_id}  ${SERVICE1}  ${desc}  ${srv_duration}  ${status[0]}  ${btype}  ${bool[0]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  leadTime=${leadTime}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE1}  serviceDuration=${srv_duration}  status=${status[0]}  leadTime=${leadTime}


JD-TC-UpdateService-10
    [Documentation]  Update maxBookingsAllowed, priceDynamic, resoucesRequired and lead time in a service 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    # clear_service   ${PUSERNAME27}

    
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=   FakerLibrary.job
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE1}  serviceDuration=${srv_duration}  status=${status[0]}

    ${maxbookings}=   Random Int   min=1   max=10
    ${resoucesRequired}=   Random Int   min=1   max=10
    ${leadTime}=   Random Int   min=1   max=5
    ${resp}=  Update Service  ${s_id}  ${SERVICE1}  ${desc}  ${srv_duration}  ${status[0]}  ${btype}  ${bool[0]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  maxBookingsAllowed=${maxbookings}  priceDynamic=${bool[1]}  resoucesRequired=${resoucesRequired}  leadTime=${leadTime}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE1}  serviceDuration=${srv_duration}  status=${status[0]}  maxBookingsAllowed=${maxbookings}   resoucesRequired=${resoucesRequired}  priceDynamic=${bool[1]}  leadTime=${leadTime}


JD-TC-UpdateService-UH8
    [Documentation]  Update maxBookingsAllowed in a service as empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    # clear_service   ${PUSERNAME27}
    
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=   FakerLibrary.job
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${maxbookings}=   Random Int   min=1   max=5
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  maxBookingsAllowed=${maxbookings}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE1}  serviceDuration=${srv_duration}  status=${status[0]}  maxBookingsAllowed=${maxbookings}

    ${maxbookings}=   Random Int   min=5   max=10
    ${resp}=  Update Service  ${s_id}  ${SERVICE1}  ${desc}  ${srv_duration}  ${status[0]}  ${btype}  ${bool[0]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  maxBookingsAllowed=${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE1}  serviceDuration=${srv_duration}  status=${status[0]}  maxBookingsAllowed=${defMBVal}


JD-TC-UpdateService-UH9
    [Documentation]  Update resoucesRequired in a service as empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    # clear_service   ${PUSERNAME27}

    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=   FakerLibrary.job
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resoucesRequired}=   Random Int   min=1   max=5
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  resoucesRequired=${resoucesRequired}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE1}  serviceDuration=${srv_duration}  status=${status[0]}  resoucesRequired=${resoucesRequired}

    ${resoucesRequired}=   Random Int   min=5   max=10
    ${resp}=  Update Service  ${s_id}  ${SERVICE1}  ${desc}  ${srv_duration}  ${status[0]}  ${btype}  ${bool[0]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  resoucesRequired=${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE1}  serviceDuration=${srv_duration}  status=${status[0]}  resoucesRequired=${defRRVal}


JD-TC-UpdateService-UH10
    [Documentation]  Update lead time in a service as empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # clear_service   ${PUSERNAME27}

    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=   FakerLibrary.job
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${leadTime}=   Random Int   min=1   max=5
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  leadTime=${leadTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE1}  serviceDuration=${srv_duration}  status=${status[0]}  leadTime=${leadTime}

    ${leadTime}=   Random Int   min=5   max=10
    ${resp}=  Update Service  ${s_id}  ${SERVICE1}  ${desc}  ${srv_duration}  ${status[0]}  ${btype}  ${bool[0]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  leadTime=${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE1}  serviceDuration=${srv_duration}  status=${status[0]}  leadTime=${defLTVal}





*** Keywords ***
Billable

    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
     
    FOR   ${a}  IN RANGE   ${length}
            
        # clear_service       ${PUSERNAME${a}}
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        ${domain}=   Set Variable    ${decrypted_data['sector']}
        ${subdomain}=    Set Variable      ${decrypted_data['subSector']}

        # ${domain}=   Set Variable    ${resp.json()['sector']}
        # ${subdomain}=    Set Variable      ${resp.json()['subSector']}
        ${resp2}=   Get Sub Domain Settings    ${domain}  ${subdomain}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Suite Variable  ${check}  ${resp2.json()['serviceBillable']} 
        Exit For Loop IF     '${check}' == 'True'

    END
    RETURN  ${PUSERNAME${a}}

Non Billable

    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
        ${len}=   Split to lines  ${resp}
        ${length}=  Get Length   ${len}

     FOR    ${a}   IN RANGE    ${length}
        # clear_service       ${PUSERNAME${a}}
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        ${domain}=   Set Variable    ${decrypted_data['sector']}
        ${subdomain}=    Set Variable      ${decrypted_data['subSector']}

        # ${domain}=   Set Variable    ${resp.json()['sector']}
        # ${subdomain}=    Set Variable      ${resp.json()['subSector']}
        ${resp2}=   Get Sub Domain Settings    ${domain}  ${subdomain}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Suite Variable  ${check}  ${resp2.json()['serviceBillable']} 
        Exit For Loop IF     '${check}' == 'False'
       
     END
     RETURN  ${PUSERNAME${a}} 








