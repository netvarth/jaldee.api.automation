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
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
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
${defMBVal}  1
${defRRVal}  1
${defLTVal}  0
@{service_names}
${zero_amt}  ${0.0}
${default_note}   Notes

*** Test Cases ***

JD-TC-UpdateService-1
    [Documentation]  update service name for a service.

    ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_A}=  Provider Signup
    Set Suite Variable  ${PUSERNAME_A}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=   Pyfloat  right_digits=1  min_value=100  max_value=250
    ${srv_duration}=   Random Int   min=2   max=10
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${srv_duration}  ${bool[0]}  ${Total}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${s_id}  ${resp.json()} 
    
    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}   ${SERVICE1}

    # ${json_data}=  Convert To Dictionary  ${resp.json()}
    # IF   'description' not in ${json_data}
    #     ${description}=  Set Variable  Default Service Description
    # END


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
    Should Be Equal As Strings  ${resp.json()['serviceDuration']}   ${srv_duration}


JD-TC-UpdateService-4
    [Documentation]  Update service to enable prepayment for a service without prepayment in billable account.

    # ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_B}=  Provider Signup
    # Set Suite Variable  ${PUSERNAME_B}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=   Pyfloat  right_digits=1  min_value=100  max_value=250
    ${srv_duration}=   Random Int   min=2   max=10
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${srv_duration}  ${bool[0]}  ${Total}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${s_id}  ${resp.json()}
    
    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${resp}=  Update Service  ${s_id}  ${resp.json()['name']}  ${resp.json()['description']}  ${resp.json()['serviceDuration']}  ${bool[1]}  ${resp.json()['totalAmount']}  minPrePaymentAmount=${min_pre}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['isPrePayment']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['minPrePaymentAmount']}   ${min_pre}


JD-TC-UpdateService-5
    [Documentation]  Update service to disable prepayment, for a service with prepayment, in a billable account.

    # ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_A}=  Provider Signup
    # Set Suite Variable  ${PUSERNAME_A}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['isPrePayment']}   ${bool[1]}

    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${resp}=  Update Service  ${s_id}  ${resp.json()['name']}  ${resp.json()['description']}  ${resp.json()['serviceDuration']}  ${bool[0]}  ${resp.json()['totalAmount']}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['isPrePayment']}   ${bool[0]}


JD-TC-UpdateService-6
    [Documentation]  Update service charge for a billable account.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[1]['id']}

    ${json_data}=  Convert To Dictionary  ${resp.json()[1]}
    IF   'description' not in ${json_data}
        ${description}=  Set Variable  Default Service Description
    ELSE  
        ${description}=  Set Variable  ${resp.json()[1]['description']}
    END

    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${resp}=  Update Service  ${s_id}  ${resp.json()[1]['name']}  ${description}  ${resp.json()[1]['serviceDuration']}  ${bool[1]}  ${resp.json()[1]['totalAmount']}  minPrePaymentAmount=${min_pre}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['isPrePayment']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['minPrePaymentAmount']}   ${min_pre}


JD-TC-UpdateService-7
    [Documentation]  Update service charge for a non billable account.

    ${nonbillable_domains}=  get_nonbillable_domains
    ${random_domain} =    Evaluate    random.choice(list(${nonbillable_domains}.keys()))    random
    ${random_subdomain} =    Evaluate    random.choice(${nonbillable_domains}[${random_domain}])    random
    ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_A}=  Provider Signup  Domain=${random_domain}  SubDomain=${random_subdomain}
    Set Suite Variable  ${PUSERNAME_A}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${json_data}=  Convert To Dictionary  ${resp.json()[0]}
    IF   'description' not in ${json_data}
        ${description}=  Set Variable  Default Service Description
    ELSE  
        ${description}=  Set Variable  ${resp.json()[0]['description']}
    END

    ${Total}=   Pyfloat  right_digits=1  min_value=100  max_value=250
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${resp}=  Update Service  ${s_id}  ${resp.json()[0]['name']}  ${description}  ${resp.json()[0]['serviceDuration']}  ${bool[1]}  ${Total}  minPrePaymentAmount=${min_pre}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['isPrePayment']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['minPrePaymentAmount']}   ${zero_amt}
    Should Be Equal As Strings  ${resp.json()['totalAmount']}   ${zero_amt}


JD-TC-UpdateService-8
    [Documentation]  Update service and set prepayment amount as 0.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    FOR  ${service}  IN  @{resp.json()}
        ${FOUND}  Set Variable  False
        IF   ${service['isPrePayment']} == ${bool[1]}
            ${FOUND}  Set Variable  True
            Set Test Variable  ${min_pre}  ${service['minPrePaymentAmount']}
            Set Test Variable  ${s_id}   ${service['id']}
            BREAK
        END
    END

    IF   not ${FOUND}
        ${description}=  FakerLibrary.sentence
        ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
        ${Total}=   Pyfloat  right_digits=1  min_value=100  max_value=250
        ${srv_duration}=   Random Int   min=2   max=10
        ${SERVICE1}=    generate_unique_service_name  ${service_names}
        Append To List  ${service_names}  ${SERVICE1}
        ${resp1}=  Create Service  ${SERVICE1}  ${description}  ${srv_duration}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp1.status_code}  200 
        Set Test Variable  ${s_id}  ${resp1.json()}
    END

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${json_data}=  Convert To Dictionary  ${resp.json()}
    IF   'description' not in ${json_data}
        ${description}=  Set Variable  Default Service Description
    ELSE  
        ${description}=  Set Variable  ${resp.json()['description']}
    END

    # ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${resp}=  Update Service  ${s_id}  ${resp.json()['name']}  ${description}  ${resp.json()['serviceDuration']}  ${resp.json()['isPrePayment']}  ${resp.json()['totalAmount']}  minPrePaymentAmount=${zero_amt}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['isPrePayment']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['minPrePaymentAmount']}   ${zero_amt}


JD-TC-UpdateService-9
    [Documentation]  Update service and set totalAmount amount as 0.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    FOR  ${service}  IN  @{resp.json()}
        ${FOUND}  Set Variable  False
        IF   ${service['totalAmount']} > 0
            ${FOUND}  Set Variable  True
            Set Test Variable  ${s_id}   ${service['id']}
            BREAK
        END
    END

    IF   not ${FOUND}
        ${description}=  FakerLibrary.sentence
        ${Total}=   Pyfloat  right_digits=1  min_value=100  max_value=250
        ${srv_duration}=   Random Int   min=2   max=10
        ${SERVICE1}=    generate_unique_service_name  ${service_names}
        Append To List  ${service_names}  ${SERVICE1}
        ${resp1}=  Create Service  ${SERVICE1}  ${description}  ${srv_duration}  ${bool[0]}  ${Total}  ${bool[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp1.status_code}  200 
        Set Test Variable  ${s_id}  ${resp1.json()}
    END

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${json_data}=  Convert To Dictionary  ${resp.json()}
    IF   'description' not in ${json_data}
        ${description}=  Set Variable  Default Service Description
    ELSE  
        ${description}=  Set Variable  ${resp.json()['description']}
    END

    ${resp}=  Update Service  ${s_id}  ${resp.json()['name']}  ${description}  ${resp.json()['serviceDuration']}  ${resp.json()['isPrePayment']}  ${zero_amt}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['totalAmount']}   ${zero_amt}


JD-TC-UpdateService-10
    [Documentation]  Update max bookings allowed in a service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    FOR  ${service}  IN  @{resp.json()}
        ${FOUND}  Set Variable  False
        IF   ${service['totalAmount']} > 0
            ${FOUND}  Set Variable  True
            Set Test Variable  ${s_id}   ${service['id']}
            BREAK
        END
    END

    IF   not ${FOUND}
        ${description}=  FakerLibrary.sentence
        ${Total}=   Pyfloat  right_digits=1  min_value=100  max_value=250
        ${srv_duration}=   Random Int   min=2   max=10
        ${SERVICE1}=    generate_unique_service_name  ${service_names}
        Append To List  ${service_names}  ${SERVICE1}
        ${resp1}=  Create Service  ${SERVICE1}  ${description}  ${srv_duration}  ${bool[0]}  ${Total}  ${bool[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp1.status_code}  200 
        Set Test Variable  ${s_id}  ${resp1.json()}
    END

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${json_data}=  Convert To Dictionary  ${resp.json()}
    IF   'description' not in ${json_data}
        ${description}=  Set Variable  Default Service Description
    ELSE  
        ${description}=  Set Variable  ${resp.json()['description']}
    END

    ${maxbookings}=   Random Int   min=1   max=5
    ${resp}=  Update Service  ${s_id}  ${resp.json()['name']}  ${description}  ${resp.json()['serviceDuration']}  ${resp.json()['isPrePayment']}  ${resp.json()['totalAmount']}  maxBookingsAllowed=${maxbookings}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['maxBookingsAllowed']}   ${maxbookings}


JD-TC-UpdateService-11
    [Documentation]  Update priceDynamic in a service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[1]['id']}
    Should Be Equal As Strings  ${resp.json()[1]['priceDynamic']}   ${bool[0]}

    ${json_data}=  Convert To Dictionary  ${resp.json()[1]}
    IF   'description' not in ${json_data}
        ${description}=  Set Variable  Default Service Description
    ELSE  
        ${description}=  Set Variable  ${resp.json()[1]['description']}
    END

    ${resp}=  Update Service  ${s_id}  ${resp.json()[1]['name']}  ${description}  ${resp.json()[1]['serviceDuration']}  ${resp.json()[1]['isPrePayment']}  ${resp.json()[1]['totalAmount']}  priceDynamic=${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['priceDynamic']}   ${bool[1]}


JD-TC-UpdateService-12
    [Documentation]  Update resoucesRequired in a service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    ${si}=  Random Int   min=0  max=${len-1}
    Set Test Variable   ${s_id}   ${resp.json()[${si}]['id']}

    ${json_data}=  Convert To Dictionary  ${resp.json()[${si}]}
    IF   'description' not in ${json_data}
        ${description}=  Set Variable  Default Service Description
    ELSE  
        ${description}=  Set Variable  ${resp.json()[${si}]['description']}
    END

    ${resoucesRequired}=   Random Int   min=1   max=5
    ${resp}=  Update Service  ${s_id}  ${resp.json()[${si}]['name']}  ${description}  ${resp.json()[${si}]['serviceDuration']}  ${resp.json()[${si}]['isPrePayment']}  ${resp.json()[${si}]['totalAmount']}  resoucesRequired=${resoucesRequired}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['resoucesRequired']}   ${resoucesRequired}


JD-TC-UpdateService-13
    [Documentation]  Update lead time in a service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    ${si}=  Random Int   min=0  max=${len-1}
    Set Test Variable   ${s_id}   ${resp.json()[${si}]['id']}
    
    ${json_data}=  Convert To Dictionary  ${resp.json()[${si}]}
    IF   'description' not in ${json_data}
        ${description}=  Set Variable  Default Service Description
    ELSE  
        ${description}=  Set Variable  ${resp.json()[${si}]['description']}
    END

    ${leadTime}=   Random Int   min=1   max=5
    ${resp}=  Update Service  ${s_id}  ${resp.json()[${si}]['name']}  ${description}  ${resp.json()[${si}]['serviceDuration']}  ${resp.json()[${si}]['isPrePayment']}  ${resp.json()[${si}]['totalAmount']}  leadTime=${leadTime}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['leadTime']}   ${leadTime}


JD-TC-UpdateService-14
    [Documentation]  update a physicalService to virtualService

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${description}=  FakerLibrary.sentence
    ${Total}=   Pyfloat  right_digits=1  min_value=100  max_value=250
    ${srv_duration}=   Random Int   min=2   max=10
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${srv_duration}  ${bool[0]}  ${Total}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${s_id}  ${resp.json()} 

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${json_data}=  Convert To Dictionary  ${resp.json()}
    # IF   'description' not in ${json_data}
    #     ${description}=  Set Variable  Default Service Description
    # ELSE  
    #     ${description}=  Set Variable  ${resp.json()['description']}
    # END

    ${Description1}=    FakerLibrary.sentences
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERNAME_A}   countryCode=${countryCodes[0]}  status=${status[0]}   instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}
    ${vstype}=   Random Element   ${vservicetype}
    
    ${resp}=  Update Service  ${s_id}  ${resp.json()['name']}  ${description}  ${resp.json()['serviceDuration']}  ${resp.json()['isPrePayment']}  ${resp.json()['totalAmount']}  serviceType=${ServiceType[0]}   virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceType']}   ${ServiceType[0]}
    Should Be Equal As Strings  ${resp.json()['virtualServiceType']}   ${vstype}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}   ${CallingModes[1]}


JD-TC-UpdateService-15
    [Documentation]  update a virtualService to physicalService

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${Description1}=    FakerLibrary.sentences
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERNAME_E}   countryCode=${countryCodes[0]}  status=${status[0]}   instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}
    ${vstype}=   Random Element   ${vservicetype}

    ${description}=    FakerLibrary.sentence
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}   virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id}  ${resp.json()} 

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${json_data}=  Convert To Dictionary  ${resp.json()}
    # IF   'description' not in ${json_data}
    #     ${description}=  Set Variable  Default Service Description
    # ELSE  
    #     ${description}=  Set Variable  ${resp.json()['description']}
    # END
    
    ${resp}=  Update Service  ${s_id}  ${resp.json()['name']}  ${description}  ${resp.json()['serviceDuration']}  ${resp.json()['isPrePayment']}  ${resp.json()['totalAmount']}  serviceType=${ServiceType[1]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceType']}   ${ServiceType[1]}
    Should Be Equal As Strings  ${resp.json()['virtualServiceType']}   ${vstype}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}   ${CallingModes[1]}


JD-TC-UpdateService-16
    [Documentation]  update a service type after taking an appointment

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${lid}  ${resp.json()['id']}
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END
    
    ${description}=  FakerLibrary.sentence
    ${Total}=   Pyfloat  right_digits=1  min_value=100  max_value=250
    ${srv_duration}=   Random Int   min=2   max=10
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${srv_duration}  ${bool[0]}  ${Total}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${s_id}  ${resp.json()} 

    ${resp}=  Create Sample Schedule   ${lid}   ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${PO_Number}=  Generate Random Phone Number
    ${resp}=  GetCustomer  phoneNo-eq=${PO_Number}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${fname}=  generate_firstname
        Set Suite Variable   ${fname}
        ${lname}=  FakerLibrary.last_name
        Set Suite Variable   ${lname}
        ${resp1}=  AddCustomer  ${PO_Number}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid}  ${resp.json()[0]['id']}
    END
    
    ${apptfor1}=  Create Dictionary  id=${pcid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${pcid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Description1}=    FakerLibrary.sentences
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERNAME_A}   countryCode=${countryCodes[0]}  status=${status[0]}   instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}
    ${vstype}=   Random Element   ${vservicetype}
    
    ${resp}=  Update Service  ${s_id}  ${resp.json()['name']}  ${description}  ${resp.json()['serviceDuration']}  ${resp.json()['isPrePayment']}  ${resp.json()['totalAmount']}  serviceType=${ServiceType[0]}   virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceType']}   ${ServiceType[0]}
    Should Be Equal As Strings  ${resp.json()['virtualServiceType']}   ${vstype}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}   ${CallingModes[1]}


JD-TC-UpdateService-17
    [Documentation]  update a service type after taking an check-in

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${lid}  ${resp.json()['id']}
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END
    
    ${description}=  FakerLibrary.sentence
    ${Total}=   Pyfloat  right_digits=1  min_value=100  max_value=250
    ${srv_duration}=   Random Int   min=2   max=10
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${srv_duration}  ${bool[0]}  ${Total}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${s_id}  ${resp.json()} 

    ${resp}=  Sample Queue  ${lid}   ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${PO_Number}=  Generate Random Phone Number
    ${resp}=  GetCustomer  phoneNo-eq=${PO_Number}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${fname}=  generate_firstname
        Set Suite Variable   ${fname}
        ${lname}=  FakerLibrary.last_name
        Set Suite Variable   ${lname}
        ${resp1}=  AddCustomer  ${PO_Number}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid1}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid1}  ${resp.json()[0]['id']}
    END
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${pcid1}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${pcid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Description1}=    FakerLibrary.sentences
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERNAME_A}   countryCode=${countryCodes[0]}  status=${status[0]}   instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}
    ${vstype}=   Random Element   ${vservicetype}
    
    ${resp}=  Update Service  ${s_id}  ${resp.json()['name']}  ${description}  ${resp.json()['serviceDuration']}  ${resp.json()['isPrePayment']}  ${resp.json()['totalAmount']}  serviceType=${ServiceType[0]}   virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceType']}   ${ServiceType[0]}
    Should Be Equal As Strings  ${resp.json()['virtualServiceType']}   ${vstype}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}   ${CallingModes[1]}


JD-TC-UpdateService-18
    [Documentation]  Update a service to add consumerNote, preInfo and postInfo

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    ${si}=  Random Int   min=0  max=${len-1}
    Set Test Variable   ${s_id}   ${resp.json()[${si}]['id']}
    
    ${json_data}=  Convert To Dictionary  ${resp.json()[${si}]}
    IF   'description' not in ${json_data}
        ${description}=  Set Variable  Default Service Description
    ELSE  
        ${description}=  Set Variable  ${resp.json()[${si}]['description']}
    END

    ${consumerNoteTitle}=  FakerLibrary.sentence
    ${preInfoTitle}=  FakerLibrary.sentence   
    ${preInfoText}=  FakerLibrary.sentence  
    ${postInfoTitle}=  FakerLibrary.sentence  
    ${postInfoText}=  FakerLibrary.sentence
    ${resp}=  Update Service  ${s_id}  ${resp.json()[${si}]['name']}  ${description}  ${resp.json()[${si}]['serviceDuration']}  ${resp.json()[${si}]['isPrePayment']}  ${resp.json()[${si}]['totalAmount']}  consumerNoteMandatory=${bool[1]}  consumerNoteTitle=${consumerNoteTitle}  preInfoEnabled=${bool[1]}  preInfoTitle=${preInfoTitle}  preInfoText=${preInfoText}  postInfoEnabled=${bool[1]}  postInfoTitle=${postInfoTitle}  postInfoText=${postInfoText}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['leadTime']}   ${leadTime}


JD-TC-UpdateService-19
    [Documentation]  update service with consumerNoteTitle as empty when consumerNoteMandatory is ${bool[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    ${si}=  Random Int   min=0  max=${len-1}
    Set Test Variable   ${s_id}   ${resp.json()[${si}]['id']}

    ${json_data}=  Convert To Dictionary  ${resp.json()[${si}]}
    IF   'description' not in ${json_data}
        ${description}=  Set Variable  Default Service Description
    ELSE  
        ${description}=  Set Variable  ${resp.json()[${si}]['description']}
    END

    ${resp}=  Update Service  ${s_id}  ${resp.json()[${si}]['name']}  ${description}  ${resp.json()[${si}]['serviceDuration']}  ${resp.json()[${si}]['isPrePayment']}  ${resp.json()[${si}]['totalAmount']}  consumerNoteMandatory=${bool[0]}  consumerNoteTitle=${EMPTY}   preInfoEnabled=${bool[1]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[1]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['consumerNoteTitle']}   ${default_note}


JD-TC-UpdateService-20
    [Documentation]  update service with consumerNoteTitle as empty when consumerNoteMandatory is ${bool[1]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    ${si}=  Random Int   min=0  max=${len-1}
    Set Test Variable   ${s_id}   ${resp.json()[${si}]['id']}

    ${json_data}=  Convert To Dictionary  ${resp.json()[${si}]}
    IF   'description' not in ${json_data}
        ${description}=  Set Variable  Default Service Description
    ELSE  
        ${description}=  Set Variable  ${resp.json()[${si}]['description']}
    END

    ${resp}=  Update Service  ${s_id}  ${resp.json()[${si}]['name']}  ${description}  ${resp.json()[${si}]['serviceDuration']}  ${resp.json()[${si}]['isPrePayment']}  ${resp.json()[${si}]['totalAmount']}  consumerNoteMandatory=${bool[1]}  consumerNoteTitle=${EMPTY}   preInfoEnabled=${bool[1]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[1]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['consumerNoteTitle']}   ${default_note}


JD-TC-UpdateService-21
    [Documentation]  update service with consumerNoteMandatory as ${bool[0]} after taking appointment

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${sch_id}   ${lid}   ${s_id}  ${tz}=   Get Schedule Details

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${PO_Number}=  Generate Random Phone Number
    ${resp}=  GetCustomer  phoneNo-eq=${PO_Number}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${fname}=  generate_firstname
        Set Suite Variable   ${fname}
        ${lname}=  FakerLibrary.last_name
        Set Suite Variable   ${lname}
        ${resp1}=  AddCustomer  ${PO_Number}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid}  ${resp.json()[0]['id']}
    END
    
    ${apptfor1}=  Create Dictionary  id=${pcid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${pcid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${json_data}=  Convert To Dictionary  ${resp.json()[${si}]}
    IF   'description' not in ${json_data}
        ${description}=  Set Variable  Default Service Description
    ELSE  
        ${description}=  Set Variable  ${resp.json()[${si}]['description']}
    END

    ${resp}=  Update Service  ${s_id}  ${resp.json()[${si}]['name']}  ${description}  ${resp.json()[${si}]['serviceDuration']}  ${resp.json()[${si}]['isPrePayment']}  ${resp.json()[${si}]['totalAmount']}  consumerNoteMandatory=${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['consumerNoteMandatory']}   ${bool[0]}


JD-TC-UpdateService-UH1
    [Documentation]  Update a service name to an already existing name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[1]['id']}
    Set Test Variable   ${s_name}   ${resp.json()[2]['name']}

    ${json_data}=  Convert To Dictionary  ${resp.json()[1]}
    IF   'description' not in ${json_data}
        ${description}=  Set Variable  Default Service Description
    ELSE  
        ${description}=  Set Variable  ${resp.json()[1]['description']}
    END

    ${resp}=  Update Service  ${s_id}  ${s_name}  ${description}  ${resp.json()[1]['serviceDuration']}  ${resp.json()[1]['isPrePayment']}  ${resp.json()[1]['totalAmount']}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}  ${SERVICE_CANT_BE_SAME}


JD-TC-UpdateService-UH2
    [Documentation]  Update a service without login
    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=   Pyfloat  right_digits=1  min_value=100  max_value=250
    ${srv_duration}=   Random Int   min=2   max=10
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Update Service  ${s_id}  ${SERVICE1}  ${description}  ${srv_duration}  ${bool[1]}  ${Total}  minPrePaymentAmount=${min_pre}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}  ${SESSION_EXPIRED}


JD-TC-UpdateService-UH3
    [Documentation]  Update a service using consumer login
    
    ${CUSERNAME8}  ${token}  Create Sample Customer  ${account_id}  primaryMobileNo=${CUSERNAME8}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME8}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=   Pyfloat  right_digits=1  min_value=100  max_value=250
    ${srv_duration}=   Random Int   min=2   max=10
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Update Service  ${s_id}  ${SERVICE1}  ${description}  ${srv_duration}  ${bool[1]}  ${Total}  minPrePaymentAmount=${min_pre}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}  ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-UpdateService-UH4
    [Documentation]  update service of another provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME69}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE1}

    ${resp1}=   Get Service By Id  ${s_id1}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${json_data}=  Convert To Dictionary  ${resp1.json()}
    IF   'description' not in ${json_data}
        ${description}=  Set Variable  Default Service Description
    ELSE  
        ${description}=  Set Variable  ${resp1.json()['description']}
    END

    ${resp}=  Update Service  ${s_id1}  ${resp1.json()['name']}  ${description}  ${resp1.json()['serviceDuration']}  ${resp1.json()['isPrePayment']}  ${resp1.json()['totalAmount']}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}  ${NO_PERMISSION}


JD-TC-UpdateService-UH5
    [Documentation]  Update maxBookingsAllowed in a service as empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    ${si}=  Random Int   min=0  max=${len-1}
    Set Test Variable   ${s_id}   ${resp.json()[${si}]['id']}

    ${json_data}=  Convert To Dictionary  ${resp.json()[${si}]}
    IF   'description' not in ${json_data}
        ${description}=  Set Variable  Default Service Description
    ELSE  
        ${description}=  Set Variable  ${resp.json()[${si}]['description']}
    END

    ${resp}=  Update Service  ${s_id}  ${resp.json()[${si}]['name']}  ${description}  ${resp.json()[${si}]['serviceDuration']}  ${resp.json()[${si}]['isPrePayment']}  ${resp.json()[${si}]['totalAmount']}  maxBookingsAllowed=${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['maxBookingsAllowed']}   ${defMBVal}
    

JD-TC-UpdateService-UH6
    [Documentation]  Update resoucesRequired in a service as empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    ${si}=  Random Int   min=0  max=${len-1}
    Set Test Variable   ${s_id}   ${resp.json()[${si}]['id']}

    ${json_data}=  Convert To Dictionary  ${resp.json()[${si}]}
    IF   'description' not in ${json_data}
        ${description}=  Set Variable  Default Service Description
    ELSE  
        ${description}=  Set Variable  ${resp.json()[${si}]['description']}
    END

    ${resp}=  Update Service  ${s_id}  ${resp.json()[${si}]['name']}  ${description}  ${resp.json()[${si}]['serviceDuration']}  ${resp.json()[${si}]['isPrePayment']}  ${resp.json()[${si}]['totalAmount']}  resoucesRequired=${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['resoucesRequired']}   ${defRRVal}
    
JD-TC-UpdateService-UH7
    [Documentation]  Update lead time in a service as empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    ${si}=  Random Int   min=0  max=${len-1}
    Set Test Variable   ${s_id}   ${resp.json()[${si}]['id']}

    ${json_data}=  Convert To Dictionary  ${resp.json()[${si}]}
    IF   'description' not in ${json_data}
        ${description}=  Set Variable  Default Service Description
    ELSE  
        ${description}=  Set Variable  ${resp.json()[${si}]['description']}
    END

    ${resp}=  Update Service  ${s_id}  ${resp.json()[${si}]['name']}  ${description}  ${resp.json()[${si}]['serviceDuration']}  ${resp.json()[${si}]['isPrePayment']}  ${resp.json()[${si}]['totalAmount']}  leadTime=${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['leadTime']}   ${defLTVal}





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
    Log  ${resp.content}
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
    [Documentation]  update a service to set prepayment amount 0
    ${resp}=   Billable
    # clear_service      ${resp}
    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${resp}=  Create Service  ${SERVICE4}  ${description}  ${service_duration[1]}  ${status[0]}  ${btype}  ${bool[1]}  ${notifytype[1]}  ${EMPTY}  ${Total}  ${bool[0]}  ${bool[0]}
    Log  ${resp.content}
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

    [Documentation]   Create a service with prePrePayment and Update with remove pre payment Amount
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
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE4}  description=${description}  serviceDuration=${service_duration[2]}  notification=${bool[0]}  notificationType=${notifytype[0]}  totalAmount=0.0  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}


JD-TC-UpdateService-UH1

    [Documentation]  Update a service name to an already existing name
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
    Log  ${resp.content}
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
    # ${resp}=  ConsumerLogin  ${CUSERNAME8}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${CUSERNAME8}  ${token}  Create Sample Customer  ${account_id}  primaryMobileNo=${CUSERNAME8}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME8}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
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
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${id}  ${resp.json()}
    ${resp}=   Get Service By Id  ${id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE8}  description=${description}  serviceDuration=${service_duration[2]}  notification=${bool[1]}  notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}
    ${resp}=  Update Service  ${id}  ${SERVICE8}  ${description}  ${service_duration[3]}  ${status[0]}  ${btype}  ${bool[0]}  ${notifytype[0]}  ${min_pre}  0  ${bool[1]}  ${bool[0]}
    Log  ${resp.content}
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
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=   FakerLibrary.job
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${maxbookings}=   Random Int   min=1   max=5
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  maxBookingsAllowed=${maxbookings}
    Log  ${resp.content}
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
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=   FakerLibrary.job
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    # ${maxbookings}=   Random Int   min=1   max=5
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  priceDynamic=${bool[1]}
    Log  ${resp.content}
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
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=   FakerLibrary.job
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resoucesRequired}=   Random Int   min=1   max=5
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  resoucesRequired=${resoucesRequired}
    Log  ${resp.content}
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
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=   FakerLibrary.job
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${leadTime}=   Random Int   min=1   max=5
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  leadTime=${leadTime}
    Log  ${resp.content}
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
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=   FakerLibrary.job
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}
    Log  ${resp.content}
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
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=   FakerLibrary.job
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${maxbookings}=   Random Int   min=1   max=5
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  maxBookingsAllowed=${maxbookings}
    Log  ${resp.content}
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
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=   FakerLibrary.job
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resoucesRequired}=   Random Int   min=1   max=5
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  resoucesRequired=${resoucesRequired}
    Log  ${resp.content}
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
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=   FakerLibrary.job
    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${leadTime}=   Random Int   min=1   max=5
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  leadTime=${leadTime}
    Log  ${resp.content}
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








