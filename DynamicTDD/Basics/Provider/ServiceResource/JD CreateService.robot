*** Settings ***
Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      Service
Library         Collections
Library         String
Library         json
Library         requests
Library         FakerLibrary
Library         Process
Library         OperatingSystem
Library         /ebs/TDD/CustomKeywords.py
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Resource        /ebs/TDD/ProviderConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

#Suite Setup       Run Keyword    wlsettings
*** Variables ***
@{service_duration}  10  20  30   40   50
${ZOOM_URL}    https://zoom.us/j/{meeting_id}?pwd={passwd}
${MEET_URL}    https://meet.google.com/{meeting_id}
${self}     0
@{service_names}
@{empty_list}
${zero_amt}  ${0.0}
@{service_names1}


*** Test Cases ***

# .......... Create Service ..............#

JD-TC-CreateService-1
    [Documentation]   Create service for an account with all options

    ${licid}  ${licname}=  get_highest_license_pkg
    ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_A}=  Provider Signup without Profile  LicenseId=${licid}
    Set Suite Variable  ${PUSERNAME_A}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[1]}  ${Total}  ${bool[1]}  minPrePaymentAmount=${min_pre}  notificationType=${notifytype[2]}  taxable=${bool[1]}  serviceType=${serviceType[1]}  #prePaymentType=${advancepaymenttype[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    ${resp}=   Get Service By Id  ${resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}   ${SERVICE1}


JD-TC-CreateService-2
    [Documentation]   Create service for a user

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PUSER_A_U1}  ${u_id1} =  Create and Configure Sample User  #admin=${bool[1]}
    Set Suite Variable  ${PUSER_A_U1}

    ${resp}=    Provider Logout
    Should Be Equal As Strings  ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSER_A_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${description}=  FakerLibrary.sentence
    ${Total}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  provider=${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    ${resp}=   Get Service By Id  ${resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}   ${SERVICE1}


JD-TC-CreateService-3
    [Documentation]   Create service in a department

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp1}=  Enable Disable Department  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
            ${dep_name1}=  FakerLibrary.bs
            ${dep_code1}=   Random Int  min=100   max=999
            ${dep_desc1}=   FakerLibrary.word  
            ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
            Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
            Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END
    
    ${description}=  FakerLibrary.sentence
    ${Total}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  department=${dep_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=   Get Service By Id  ${resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}   ${SERVICE1}


JD-TC-CreateService-4
    [Documentation]   Create service after disabling department
    # ${resp}=   Billable  ${start1}
    # clear_service      ${resp}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[1]}
        ${resp}=  Enable Disable Department  ${toggle[1]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    # ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=   Get Service By Id  ${resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE1} 

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateService-5
    [Documentation]   Create service in Non Billable domain
    ${nonbillable_domains}=  get_nonbillable_domains
    ${domain}  ${subdomain_list}   Get Dictionary Items   ${nonbillable_domains}
    ${subdomain}=    Evaluate    random.choice(${subdomain_list})    modules=random

    ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_C}=  Provider Signup without Profile  Domain=${domain}  SubDomain=${subdomain}
    Set Suite Variable  ${PUSERNAME_C}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${description}=  FakerLibrary.sentence
    ${Total}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Service By Id  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE1}  totalAmount=${zero_amt}


JD-TC-CreateService-6
    [Documentation]     Create a service for a valid provider with service name same as another provider
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${srvs_len}=  Get Length  ${resp.json()}
    # Set Test Variable  ${SERVICE1}  ${resp.json()[${srvs_len-1}]['name']} 
    Set Test Variable  ${SERVICE1}  ${resp.json()[0]['name']}   

    ${resp}=  ProviderLogout   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${licid}  ${licname}=  get_highest_license_pkg
    ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_B}=  Provider Signup without Profile  LicenseId=${licid}
    Set Suite Variable  ${PUSERNAME_B}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${description}=  FakerLibrary.sentence
    ${min_pre1}=   Pyfloat  right_digits=1  min_value=1  max_value=10
    ${Total1}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[1]}  ${Total1}  ${bool[0]}  minPrePaymentAmount=${min_pre1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Get Service By Id  ${resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE1} 


JD-TC-CreateService-7
    [Documentation]   Create service with prepayment but without enabling isPrePayment flag
    ...  Prepayment does not show unless isPrePayment flag is enabled.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    ${resp}=   Get Service By Id  ${resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Dictionary Should Not Contain Key  ${resp.json()}  minPrePaymentAmount


JD-TC-CreateService-8
    [Documentation]   Create service without prepayment

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description}=  FakerLibrary.sentence
    ${Total}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    ${resp}=   Get Service By Id  ${resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Dictionary Should Not Contain Key  ${resp.json()}  minPrePaymentAmount


JD-TC-CreateService-9
    [Documentation]   Create service with lead time. 
    ...  (preparation time for provider before next booking. when trying to make a booking in less than 10 mins of start of next slot, when lead time is 10 mins
    ...  the next slot will not be shown. there should be a time difference of 10 mins from current booking time to next slot.)

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description}=   FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${leadTime}=   Random Int   min=1   max=5
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${servicecharge}  ${bool[0]}  leadTime=${leadTime}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  leadTime=${leadTime}


JD-TC-CreateService-10
    [Documentation]   Create service with max bookings allowed. (one consumer can make as many bookings as specified in max bookings allowed)

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${maxbookings}=   Random Int   min=1   max=10
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[1]}  ${servicecharge}  ${bool[0]}  minPrePaymentAmount=${min_pre}  maxBookingsAllowed=${maxbookings}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  maxBookingsAllowed=${maxbookings}


JD-TC-CreateService-11
    [Documentation]   Create service with resoucesRequired. 
    # resoucesRequired defines how many resources we need to complete the said service, eg: say we have 4 resources- 4 beauticians
    # and we need 2 beauticians 1 for hair styling and the other as henna artist for one service, then the we give resource required for that service as 2.
    # In which case if parallelServing is set as 4 in a queue/schedule, noOfAvailbleSlots will only be 2, since we need 2 resources per service.
    # In a queue/Schedule parallelServing cannot be set as less than resoucesRequired.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resoucesRequired}=   Random Int   min=1   max=10
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[1]}  ${servicecharge}  ${bool[0]}  minPrePaymentAmount=${min_pre}  resoucesRequired=${resoucesRequired}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  resoucesRequired=${resoucesRequired}


JD-TC-CreateService-12
    [Documentation]   Create service with priceDynamic.(allows to set schedule level price rather than service charge)

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[1]}  ${servicecharge}  ${bool[0]}  minPrePaymentAmount=${min_pre}  priceDynamic=${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  priceDynamic=${bool[1]}


JD-TC-CreateService-13
    [Documentation]   Create service without service description

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${EMPTY}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=   Get Service By Id  ${resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['description']}   ${EMPTY}


JD-TC-CreateService-14
    [Documentation]   Create service with service charge of 0

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${0.0}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=   Get Service By Id  ${resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['totalAmount']}   0.0


JD-TC-CreateService-15
    [Documentation]   Create multiple Services for a user
    
    ${resp}=  Encrypted Provider Login  ${PUSER_A_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${u_id1}  ${decrypted_data['id']}

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp1}=  Enable Disable Department  ${toggle[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
            ${dep_name1}=  FakerLibrary.bs
            ${dep_code1}=   Random Int  min=100   max=999
            ${dep_desc1}=   FakerLibrary.word  
            ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
            Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
            Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${desc}=  FakerLibrary.sentence
    ${Total}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  Description is "${desc}"  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  provider=${u_id1}  department=${dep_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE1}  description=Description is "${desc}"  serviceDuration=${service_duration[1]}

    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${description2}=   FakerLibrary.sentence
    ${servicecharge2}=   Pyfloat  right_digits=1  min_value=100  max_value=500
    ${srv_duration2}=   Random Int   min=10   max=20
    ${resp}=   Create Service  ${SERVICE2}  ${description2}  ${srv_duration2}  ${bool[0]}  ${servicecharge2}  ${bool[0]}  provider=${u_id1}  department=${dep_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}

    ${resp}=   Get Service By Id  ${s_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE2}  description=${description2}  serviceDuration=${srv_duration2}


JD-TC-CreateService-16
    [Documentation]   Create Service with user id as empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${u_id1}  ${decrypted_data['id']}

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  department=${dep_id}   provider=${NULL}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateService-17
    [Documentation]   Create service with supportInternationalConsumer as true and set internationalAmount with prepayment. (service charge for international consumers)

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
    ${intlamt}=  Pyfloat  right_digits=1  min_value=250  max_value=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[1]}  ${servicecharge}  ${bool[0]}  minPrePaymentAmount=${min_pre}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  minPrePaymentAmount=${min_pre}  totalAmount=${servicecharge}  isPrePayment=${bool[1]}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}


JD-TC-CreateService-18
    [Documentation]   Create service with supportInternationalConsumer as true and set internationalAmount without prepayment. (service charge for international consumers)

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
    ${intlamt}=  Pyfloat  right_digits=1  min_value=250  max_value=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  totalAmount=${servicecharge}  isPrePayment=${bool[0]}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}


JD-TC-CreateService-19
    [Documentation]   Create service with supportInternationalConsumer as true but without internationalAmount. (service charge for international consumers)

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
    ${intlamt}=  Pyfloat  right_digits=1  min_value=250  max_value=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  supportInternationalConsumer=${bool[1]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  totalAmount=${servicecharge}  supportInternationalConsumer=${bool[1]}  internationalAmount=${zero_amt}



JD-TC-CreateService-20
    [Documentation]   Create service with supportInternationalConsumer as false but with internationalAmount. (cannot set internationalAmount when supportInternationalConsumer is false)

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
    ${intlamt}=  Pyfloat  right_digits=1  min_value=250  max_value=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  supportInternationalConsumer=${bool[0]}  internationalAmount=${intlamt}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  totalAmount=${servicecharge}  supportInternationalConsumer=${bool[0]}  internationalAmount=${zero_amt}


JD-TC-CreateService-21
    [Documentation]   Create service with supportInternationalConsumer as true but with internationalAmount as empty. (service charge for international consumers)

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
    ${intlamt}=  Pyfloat  right_digits=1  min_value=250  max_value=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  supportInternationalConsumer=${bool[1]}  internationalAmount=${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  totalAmount=${servicecharge}  supportInternationalConsumer=${bool[1]}  internationalAmount=${zero_amt}


JD-TC-CreateService-22
    [Documentation]   Create service with supportInternationalConsumer as true but with internationalAmount as less than service charge. (service charge for international consumers)

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${addon_resp}=   Get Addons Metadata
    Log  ${addon_resp.content}
    Should Be Equal As Strings    ${addon_resp.status_code}   200
    # Set Test Variable  ${aId}  ${resp.json()[0]['addons'][0]['addonId']}
    Set Suite Variable    ${addon_id}      ${addon_resp.json()[6]['addons'][0]['addonId']}
	Set Suite Variable    ${addon_name}      ${addon_resp.json()[6]['addons'][0]['addonName']}

    # ${resp}=  Add addon  ${addon_id}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${intlamt}=   Pyfloat  right_digits=1  min_value=100  max_value=250
    ${servicecharge}=  Pyfloat  right_digits=1  min_value=250  max_value=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  totalAmount=${servicecharge}  internationalAmount=${intlamt}


JD-TC-CreateService-23
    [Documentation]   Create service with supportInternationalConsumer and prePaymentType as percentage

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
    ${intlamt}=  Pyfloat  right_digits=1  min_value=250  max_value=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[1]}  ${servicecharge}  ${bool[0]}  minPrePaymentAmount=${min_pre}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}  prePaymentType=${advancepaymenttype[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}


    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  isPrePayment=${bool[1]}  minPrePaymentAmount=${min_pre}  totalAmount=${servicecharge}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}


JD-TC-CreateService-24
    [Documentation]   Create service with prePaymentType as percentage and prepayment set as a percentage value

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre_percent}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
    ${intlamt}=  Pyfloat  right_digits=1  min_value=250  max_value=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[1]}  ${servicecharge}  ${bool[0]}  minPrePaymentAmount=${min_pre_percent}  prePaymentType=${advancepaymenttype[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}


    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  isPrePayment=${bool[1]}  minPrePaymentAmount=${min_pre_percent}  totalAmount=${servicecharge} 


JD-TC-CreateService-25
    [Documentation]   Create service with prePaymentType as percentage and prepayment set as 100 percentage value

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre_percent}=   Convert To Number  100  1
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
    ${intlamt}=  Pyfloat  right_digits=1  min_value=250  max_value=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[1]}  ${servicecharge}  ${bool[0]}  minPrePaymentAmount=${min_pre_percent}  prePaymentType=${advancepaymenttype[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}


    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  isPrePayment=${bool[1]}  minPrePaymentAmount=${min_pre_percent}  totalAmount=${servicecharge}


JD-TC-CreateService-26
    [Documentation]   Create service with note,pre info and post info

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
    ${srv_duration}=   Random Int   min=10   max=20
    # ${consumerNoteMandatory}=  Random Element  ${bool}
    ${consumerNoteTitle}=  FakerLibrary.sentence
    ${preInfoTitle}=  FakerLibrary.sentence   
    ${preInfoText}=  FakerLibrary.sentence  
    ${postInfoTitle}=  FakerLibrary.sentence  
    ${postInfoText}=  FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  consumerNoteMandatory=${bool[1]}  consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[1]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[1]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}


    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  consumerNoteMandatory=${bool[1]}  consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[1]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[1]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}


JD-TC-CreateService-27
    [Documentation]   Create service with automaticInvoiceGeneration true

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
    ${srv_duration}=   Random Int   min=10   max=20
    # ${consumerNoteMandatory}=  Random Element  ${bool}
    ${consumerNoteTitle}=  FakerLibrary.sentence
    ${preInfoTitle}=  FakerLibrary.sentence   
    ${preInfoText}=  FakerLibrary.sentence  
    ${postInfoTitle}=  FakerLibrary.sentence  
    ${postInfoText}=  FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  automaticInvoiceGeneration=${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}


    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  automaticInvoiceGeneration=${bool[1]}


# ................Donation................... #
JD-TC-CreateService-27
    [Documentation]   Create a donation service

    ${licid}  ${licname}=  get_highest_license_pkg
    ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_D}=  Provider Signup without Profile  LicenseId=${licid}
    Set Suite Variable  ${PUSERNAME_D}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${min_don_amt1}=   Random Int   min=100   max=500
    ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
    ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
    ${max_don_amt1}=   Random Int   min=5000   max=10000
    ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
    ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
    ${min_don_amt}=  Convert To Number  ${min_don_amt}  1
    ${max_don_amt}=  Convert To Number  ${max_don_amt}  1
    ${description}=  FakerLibrary.sentence
    ${Total}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[2]}  minDonationAmount=${min_don_amt}  maxDonationAmount=${max_don_amt}  multiples=${multiples[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=   Get Service By Id  ${resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceType']}   ${ServiceType[2]}


JD-TC-CreateService-28
    [Documentation]   Create  a donation service(Non billable domain)
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${min_don_amt1}=   Pyfloat  right_digits=1  min_value=100  max_value=500
    ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
    ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
    ${max_don_amt1}=   Pyfloat  right_digits=1  min_value=${min_don_amt1+1}  max_value=1000
    ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
    ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
    ${description}=  FakerLibrary.sentence
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[2]}  minDonationAmount=${min_don_amt}  maxDonationAmount=${max_don_amt}  multiples=${multiples[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=   Get Service By Id  ${resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceType']}   ${ServiceType[2]}

    
# ................................ Virtual Service .......................... #
JD-TC-CreateService-29
    [Documentation]   Create a Virtual service

    ${licid}  ${licname}=  get_highest_license_pkg
    ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_E}=  Provider Signup without Profile  LicenseId=${licid}
    Set Suite Variable  ${PUSERNAME_E}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[1]}
        ${resp1}=  Enable Disable Department  ${toggle[1]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['virtualService']}==${bool[0]}   
        ${resp}=   Enable Disable Virtual Service   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END
    
    ${Description1}=    FakerLibrary.sentences
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERNAME_E}   countryCode=${countryCodes[0]}  status=${status[0]}   instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}
    # Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${vstype}=   Random Element   ${vservicetype}

    ${description}=    FakerLibrary.sentence
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}   virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceType']}   ${ServiceType[0]}
    Should Be Equal As Strings  ${resp.json()['virtualServiceType']}   ${vstype}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}   ${CallingModes[1]}


JD-TC-CreateService-30
    [Documentation]   Create a Virtual service in a department

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp1}=  Enable Disable Department  ${toggle[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
            ${dep_name1}=  FakerLibrary.bs
            ${dep_code1}=   Random Int  min=100   max=999
            ${dep_desc1}=   FakerLibrary.word  
            ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
            Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
            Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id1}  ${resp.json()}
    
    ${Description1}=    FakerLibrary.sentences
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERNAME_E}   countryCode=${countryCodes[0]}  status=${status[0]}   instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}
    ${vstype}=   Random Element   ${vservicetype}

    ${description}=    FakerLibrary.sentence
    ${Total1}=   Random Int   min=100   max=500
    ${Total}=  Convert To Number  ${Total1}  1
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}   virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}  department=${dep_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sid}  ${resp.json()}

    ${resp}=   Get Service By Id  ${sid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceType']}   ${ServiceType[0]}

    ${resp}=  Get Services in Department  ${dep_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}   ${sid}
    Should Be Equal As Strings  ${resp.json()['services'][0]['serviceType']}  ${ServiceType[0]}



JD-TC-CreateService-31
    [Documentation]   Create a Virtual service with prepayment

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[1]}
        ${resp1}=  Enable Disable Department  ${toggle[1]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
    
    ${Description1}=    FakerLibrary.sentences
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERNAME_E}   countryCode=${countryCodes[0]}  status=${status[0]}   instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}
    ${vstype}=   Random Element   ${vservicetype}

    ${description}=    FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[1]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}  minPrePaymentAmount=${min_pre}  virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceType']}   ${ServiceType[0]}


JD-TC-CreateService-32
    [Documentation]   Create a Virtual service with whatsapp only.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Description1}=    FakerLibrary.sentences
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERNAME_E}   countryCode=${countryCodes[0]}  status=${status[0]}   instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}
    ${vstype}=   Random Element   ${vservicetype}

    ${description}=    FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}  virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceType']}   ${ServiceType[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}   ${CallingModes[1]}


JD-TC-CreateService-33
    [Documentation]   Create two virtual services for a provider using same virtual calling mode.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Description1}=    FakerLibrary.sentences
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERNAME_E}   countryCode=${countryCodes[0]}  status=${status[0]}   instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}
    ${vstype}=   Random Element   ${vservicetype}

    ${description}=    FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}  virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceType']}   ${ServiceType[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}   ${CallingModes[1]}

    ${Description1}=    FakerLibrary.sentences
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERNAME_A}   countryCode=${countryCodes[0]}  status=${status[0]}   instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}
    ${vstype}=   Random Element   ${vservicetype}

    ${description}=    FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${resp}=  Create Service  ${SERVICE2}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}  virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceType']}   ${ServiceType[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}   ${CallingModes[1]}


JD-TC-CreateService-34
    [Documentation]   Use different google meet ids and different virtual service type to create different Virtual services

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${meeting_id}=  Generate Random String    10    [NUMBERS]
    # ${passwd}=  FakerLibrary.password  length=30  #special_chars=False  upper_case=False
    # ${ZOOM_id0}=     Format String    ${ZOOM_URL}    meeting_id=9${meeting_id}    passwd=${passwd}.1
    
    ${meeting_id}=   FakerLibrary.lexify  text='???-????-???'  letters=${lower}    # Adjust length and characters as needed
    ${GoogleMeet_url}=     Format String    ${MEET_URL}    meeting_id=${meeting_id}
    Log    ${meet_url}

    ${Description1}=    FakerLibrary.sentences
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[3]}   value=${GoogleMeet_url}   status=${status[0]}    instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    # ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id0}   status=${status[0]}   instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}
    # ${vstype}=   Random Element   ${vservicetype}
    ${vstype1}=   Set Variable   ${vservicetype[0]}

    ${description}=    FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}  virtualServiceType=${vstype1}  virtualCallingModes=${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceType']}   ${ServiceType[0]}
    Should Be Equal As Strings  ${resp.json()['virtualServiceType']}   ${vstype1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}   ${CallingModes[3]}

    # ${meeting_id}=  Generate Random String    10    [NUMBERS]
    # ${passwd}=  FakerLibrary.password  length=30  #special_chars=False  upper_case=False
    # ${ZOOM_id1}=     Format String    ${ZOOM_URL}    meeting_id=9${meeting_id}    passwd=${passwd}.1

    ${meeting_id}=   FakerLibrary.lexify  text='???-????-???'  letters=${lower}    # Adjust length and characters as needed
    ${GoogleMeet_url}=     Format String    ${MEET_URL}    meeting_id=${meeting_id}
    Log    ${meet_url}
    
    ${Description1}=    FakerLibrary.sentences
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[3]}   value=${GoogleMeet_url}   status=${status[0]}    instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    # ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id1}   status=${status[0]}   instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}
    # ${vstype}=   Random Element   ${vservicetype}
    ${vstype2}=   Set Variable   ${vservicetype[1]}

    ${description}=    FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${resp}=  Create Service  ${SERVICE2}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}  virtualServiceType=${vstype2}  virtualCallingModes=${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceType']}   ${ServiceType[0]}
    Should Be Equal As Strings  ${resp.json()['virtualServiceType']}   ${vstype2}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}   ${CallingModes[3]}


JD-TC-CreateService-35
    [Documentation]   Use different Zoom id and same virtual service type to create different Virtual services

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${meeting_id}=  Generate Random String    10    [NUMBERS]
    ${passwd}=  FakerLibrary.password  length=30  #special_chars=False  upper_case=False
    ${ZOOM_id0}=     Format String    ${ZOOM_URL}    meeting_id=9${meeting_id}    passwd=${passwd}.1
    
    ${Description1}=    FakerLibrary.sentences
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id0}   status=${status[0]}   instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}
    # ${vstype}=   Random Element   ${vservicetype}
    ${vstype}=   Set Variable   ${vservicetype[1]}

    ${description}=    FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}  virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceType']}   ${ServiceType[0]}
    Should Be Equal As Strings  ${resp.json()['virtualServiceType']}   ${vstype}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}   ${CallingModes[0]}

    ${meeting_id}=  Generate Random String    10    [NUMBERS]
    ${passwd}=  FakerLibrary.password  length=30  #special_chars=False  upper_case=False
    ${ZOOM_id1}=     Format String    ${ZOOM_URL}    meeting_id=9${meeting_id}    passwd=${passwd}.1
    
    ${Description1}=    FakerLibrary.sentences
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id1}   status=${status[0]}   instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}
    # ${vstype}=   Random Element   ${vservicetype}
    # ${vstype2}=   Set Variable   ${vservicetype[0]}

    ${description}=    FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${resp}=  Create Service  ${SERVICE2}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}  virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceType']}   ${ServiceType[0]}
    Should Be Equal As Strings  ${resp.json()['virtualServiceType']}   ${vstype}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}   ${CallingModes[0]}


JD-TC-CreateService-36
    [Documentation]   Use 2 virtual calling modes to create a single virtual service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${meeting_id}=  Generate Random String    10    [NUMBERS]
    # ${passwd}=  FakerLibrary.password  length=30  #special_chars=False  upper_case=False
    # ${ZOOM_id0}=     Format String    ${ZOOM_URL}    meeting_id=9${meeting_id}    passwd=${passwd}.1
    
    ${meeting_id}=   FakerLibrary.lexify  text='???-????-???'  letters=${lower}
    ${GoogleMeet_url}=     Format String    ${MEET_URL}    meeting_id=${meeting_id}
    Log    ${meet_url}
    
    ${Description1}=    FakerLibrary.sentences
    ${instructions2}=   FakerLibrary.sentence
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[3]}   value=${GoogleMeet_url}   status=${status[0]}    instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${VScallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERNAME_E}   countryCode=${countryCodes[0]}  instructions=${instructions2} 
    ${virtualCallingModes}=  Create List  ${VScallingMode1}  ${VScallingMode2}
    ${vstype}=   Random Element   ${vservicetype}

    ${description}=    FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}  virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceType']}   ${ServiceType[0]}
    Should Be Equal As Strings  ${resp.json()['virtualServiceType']}   ${vstype}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}   ${CallingModes[3]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}   ${CallingModes[1]}


JD-TC-CreateService-37
    [Documentation]   Use Google_meet and Whatsapp virtual calling modes to create a video services

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${meeting_id}=   FakerLibrary.lexify  text='???-????-???'  letters=${lower}
    ${GoogleMeet_url}=     Format String    ${MEET_URL}    meeting_id=${meeting_id}
    Log    ${meet_url}
    
    ${Description1}=    FakerLibrary.sentences
    ${instructions2}=   FakerLibrary.sentence
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[3]}   value=${GoogleMeet_url}   status=${status[0]}    instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${VScallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERNAME_E}   countryCode=${countryCodes[0]}  instructions=${instructions2} 
    ${virtualCallingModes}=  Create List  ${VScallingMode1}  ${VScallingMode2}
    ${vstype}=   Set Variable   ${vservicetype[1]}

    ${description}=    FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}  virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceType']}   ${ServiceType[0]}
    Should Be Equal As Strings  ${resp.json()['virtualServiceType']}   ${vservicetype[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}   ${CallingModes[3]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}   ${CallingModes[1]}


JD-TC-CreateService-38
    [Documentation]   Use Phone_call and Whatsapp virtual calling modes to create a audio services

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${meeting_id}=   FakerLibrary.lexify  text='???-????-???'  letters=${lower}
    ${GoogleMeet_url}=     Format String    ${MEET_URL}    meeting_id=${meeting_id}
    Log    ${meet_url}
    
    ${Description1}=    FakerLibrary.sentences
    ${instructions2}=   FakerLibrary.sentence
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[2]}   value=${PUSERNAME_E}   countryCode=${countryCodes[0]}    instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${VScallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERNAME_E}   countryCode=${countryCodes[0]}  instructions=${instructions2} 
    ${virtualCallingModes}=  Create List  ${VScallingMode1}  ${VScallingMode2}
    ${vstype}=   Set Variable   ${vservicetype[0]}

    ${description}=    FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}  virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceType']}   ${ServiceType[0]}
    Should Be Equal As Strings  ${resp.json()['virtualServiceType']}   ${vservicetype[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}   ${CallingModes[2]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}   ${CallingModes[1]}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${service_names1}  Get service names  ${resp.json()}  ${service_names1}
    Log  ${service_names1}
    ${SERVICE1}=    generate_unique_service_name  ${service_names1}
    Append To List  ${service_names1}  ${SERVICE1}
    Log  ${service_names1}

JD-TC-CreateService-39
    [Documentation]  Create a service with sortOrder field.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description}=    FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500

    ${SERVICE}=    generate_unique_service_name  ${service_names1}
    Append To List  ${service_names1}  ${SERVICE}

    ${resp}=  Create Service  ${SERVICE}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id1}  ${resp.json()}

    ${SERVICE1}=    generate_unique_service_name  ${service_names1}
    Append To List  ${service_names1}  ${SERVICE1}

    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}     sortOrder=1
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id2}  ${resp.json()}

    ${SERVICE2}=    generate_unique_service_name  ${service_names1}
    Append To List  ${service_names1}  ${SERVICE2}

    ${resp}=  Create Service  ${SERVICE2}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id3}  ${resp.json()}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['name']}   ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()[1]['id']}     ${id2}
    Should Be Equal As Strings  ${resp.json()[0]['name']}   ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()[0]['id']}     ${id3}


JD-TC-CreateService-UH1
    [Documentation]  Create an already existing service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${lid}=  Create Sample Location

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${SERVICE1}  ${resp.json()[0]['name']} 

    ${description}=  FakerLibrary.sentence
    ${min_pre1}=   Pyfloat  right_digits=1  min_value=1  max_value=10
    ${Total1}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[1]}  ${Total1}  ${bool[0]}  minPrePaymentAmount=${min_pre1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422 
    Should Be Equal As Strings   ${resp.json()}  ${SERVICE_CANT_BE_SAME}


JD-TC-CreateService-UH2
    [Documentation]    Create a service without login

    ${description}=  FakerLibrary.sentence
    ${Total}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}  ${SESSION_EXPIRED}
    

JD-TC-CreateService-UH3
    [Documentation]   Create a service using consumer login

    ${account_id}=  get_acc_id  ${PUSERNAME_B}

    ${primaryMobileNo}  ${token}  Create Sample Customer  ${account_id}  primaryMobileNo=${CUSERNAME5}

    ${resp}=  ProviderConsumer Login with token   ${CUSERNAME5}  ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${description}=  FakerLibrary.sentence
    ${Total}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}  ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-CreateService-UH4
    [Documentation]   Create service in default department & custom department with same service name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${def_depid}  ${resp.json()['departments'][0]['departmentId']}

    ${len}=  Get Length  ${resp.json()['departments']}
    IF  ${len} <= 1
            ${dep_name1}=  FakerLibrary.bs
            ${dep_code1}=   Random Int  min=100   max=999
            ${dep_desc1}=   FakerLibrary.word  
            ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
            Set Test Variable  ${dep_id1}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id1}  ${resp.json()['departments'][1]['departmentId']}
    END

    ${resp}=  Get Services in Department  ${def_depid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${SERVICE1}  ${resp.json()['services'][0]['name']}

    ${resp}=  Get Services in Department  ${dep_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description}=  FakerLibrary.sentence
    ${Total}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  department=${dep_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${sid}  ${resp.json()}

    ${resp}=   Get Service By Id  ${sid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}   ${SERVICE1}

    ${description}=  FakerLibrary.sentence
    ${Total}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  department=${def_depid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422  
    Should Be Equal As Strings   ${resp.json()}  ${SERVICE_CANT_BE_SAME}


JD-TC-CreateService-UH5
    [Documentation]   Create service without service name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${EMPTY}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings   ${resp.json()}   ${SERVICE_NAME_REQUIRED}


JD-TC-CreateService-UH6
    [Documentation]   Create service without service duration

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${EMPTY}  ${bool[0]}  ${Total}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings   ${resp.json()}   ${SERVICE_DURATION_CANT_BE_ZERO}


JD-TC-CreateService-UH7
    [Documentation]   Create service without notificationType

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${EMPTY}  ${bool[0]}  ${Total}  ${bool[1]}  notificationType=${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   422


JD-TC-CreateService-UH8
    [Documentation]   Create service without prepayment amount

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings   ${resp.json()}   ${MINIMUM_PREPAYMENT_AMOUNT_SHOULD_BE_PROVIDED}


JD-TC-CreateService-UH9
    [Documentation]   Create service without total amount

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${EMPTY}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings   ${resp.json()}   ${SERVICE_AMOUNT_CANT_BE_NULL}


JD-TC-CreateService-UH10
    [Documentation]   Create Service with maxBookingsAllowed as empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  maxBookingsAllowed=${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  maxBookingsAllowed=1


JD-TC-CreateService-UH11
    [Documentation]   Create Service with resoucesRequired as empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  resoucesRequired=${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  resoucesRequired=1


JD-TC-CreateService-UH12
    [Documentation]   Create Service with leadTime as empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  leadTime=${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  leadTime=0


JD-TC-CreateService-UH13
    [Documentation]   Create service with prepayment amount of 0

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=   Pyfloat  right_digits=1  min_value=250  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${0.0}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings   ${resp.json()}   ${MINIMUM_PREPAYMENT_AMOUNT_SHOULD_BE_PROVIDED}


JD-TC-CreateService-UH14
    [Documentation]   Create Service for an invalid user id

    ${resp}=  Encrypted Provider Login  ${PUSER_A_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${u_id1}  ${decrypted_data['id']}

    # Set Test Variable  ${u_id1}  ${resp.json()['id']}

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${inv_userid}    FakerLibrary.Random Number   digits=10  fix_len=True
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  department=${dep_id}   provider=${inv_userid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}  ${NO_PERMISSION_TO_CREATE_SERVICE}


JD-TC-CreateService-UH15
    [Documentation]   Create Service for a user from another account 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PUSER_B_U1}  ${u_id2} =  Create and Configure Sample User

    ${resp}=    Provider Logout
    Should Be Equal As Strings  ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
            ${resp1}=  Enable Disable Department  ${toggle[0]}
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
    END
    
    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF   '${resp.content}' == '${emptylist}'
            ${dep_name1}=  FakerLibrary.bs
            ${dep_code1}=   Random Int  min=100   max=999
            ${dep_desc1}=   FakerLibrary.word  
            ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
            Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
            Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  department=${dep_id}   provider=${u_id2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}  ${NO_PERMISSION}


JD-TC-CreateService-UH16
    [Documentation]   Create Service for an invalid department id 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${u_id1}  ${decrypted_data['id']}

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${inv_depid}    FakerLibrary.Random Number   digits=10  fix_len=True
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  department=${inv_depid}   provider=${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    404
    Should Be Equal As Strings    ${resp.json()}  ${INVALID_DEPARTMENT}


JD-TC-CreateService-UH17
    [Documentation]   Create Service with department id as empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${u_id1}  ${decrypted_data['id']}

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  department=${EMPTY}   provider=${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}  ${DEPT_ID}


JD-TC-CreateService-UH18
    [Documentation]   Create Service for user without department when department is enabled.

    ${resp}=  Encrypted Provider Login  ${PUSER_A_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${u_id1}  ${decrypted_data['id']}

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
            ${resp1}=  Enable Disable Department  ${toggle[0]}
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=500
    ${srv_duration}=   Random Int   min=10   max=20
    # ${inv_depid}    FakerLibrary.Random Number   digits=10  fix_len=True
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}   provider=${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}  ${DEPT_ID}


JD-TC-CreateService-UH19
    [Documentation]   Create Service with service name of over 50 characters.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=    generate_long_service_name
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${inv_depid}    FakerLibrary.Random Number   digits=10  fix_len=True
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}  ${SERVICE_NAME_LIMIT_REACHED}


JD-TC-CreateService-UH20
    [Documentation]   Create Service with same service name but different service type
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${description}=  FakerLibrary.sentence
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=500
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${servicecharge}  ${bool[0]}  serviceType=${serviceType[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    # Should Be Equal As Strings   ${resp.json()}  ${SERVICE_CANT_BE_SAME}

    ${min_don_amt1}=   Pyfloat  right_digits=1  min_value=100  max_value=500
    ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
    ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
    ${max_don_amt1}=   Pyfloat  right_digits=1  min_value=${min_don_amt1+1}  max_value=1000
    ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
    ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
    ${description}=  FakerLibrary.sentence
    ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=500
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${servicecharge}  ${bool[0]}  serviceType=${ServiceType[2]}  minDonationAmount=${min_don_amt}  maxDonationAmount=${max_don_amt}  multiples=${multiples[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422 
    Should Be Equal As Strings   ${resp.json()}  ${SERVICE_CANT_BE_SAME}


# ................Donation................... #

JD-TC-CreateService-UH21
    [Documentation]   Create Donation Service without minimum donation amount

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[1]}
        ${resp1}=  Enable Disable Department  ${toggle[1]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
    
    ${min_don_amt1}=   Pyfloat  right_digits=1  min_value=100  max_value=500
    ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
    ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
    ${max_don_amt1}=   Pyfloat  right_digits=1  min_value=${min_don_amt1+1}  max_value=1000
    ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
    ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
    ${description}=  FakerLibrary.sentence
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[2]}  minDonationAmount=${EMPTY}  maxDonationAmount=${max_don_amt}  multiples=${multiples[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422  
    Should Be Equal As Strings   ${resp.json()}  ${MIN_DONATION_REQUIRED}


JD-TC-CreateService-UH22
    [Documentation]   Create Donation Service in the  billabe domain without maximum donation amount

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[1]}
        ${resp1}=  Enable Disable Department  ${toggle[1]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
    
    ${min_don_amt1}=   Pyfloat  right_digits=1  min_value=100  max_value=500
    ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
    ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
    ${max_don_amt1}=   Pyfloat  right_digits=1  min_value=${min_don_amt1+1}  max_value=1000
    ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
    ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
    ${description}=  FakerLibrary.sentence
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[2]}  minDonationAmount=${min_don_amt}  maxDonationAmount=${EMPTY}  multiples=${multiples[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422  
    Should Be Equal As Strings   ${resp.json()}  ${MAX_DONATION_REQUIRED}


JD-TC-CreateService-UH23
    [Documentation]   Create Donation Service without multiples

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[1]}
        ${resp1}=  Enable Disable Department  ${toggle[1]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
    
    ${min_don_amt1}=   Pyfloat  right_digits=1  min_value=100  max_value=500
    ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
    ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
    ${max_don_amt1}=   Pyfloat  right_digits=1  min_value=${min_don_amt1+1}  max_value=1000
    ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
    ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
    ${description}=  FakerLibrary.sentence
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[2]}  minDonationAmount=${min_don_amt}  maxDonationAmount=${max_don_amt}  multiples=${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422  
    Should Be Equal As Strings   ${resp.json()}  ${MULTIPLES_REQUIRED}


JD-TC-CreateService-UH24
    [Documentation]   Create Donation Service with incorrect multiples. 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[1]}
        ${resp1}=  Enable Disable Department  ${toggle[1]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
    
    ${min_don_amt1}=   Pyfloat  right_digits=1  min_value=100  max_value=500
    ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
    ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
    ${max_don_amt1}=   Pyfloat  right_digits=1  min_value=${min_don_amt1+1}  max_value=1000
    ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
    ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
    ${description}=  FakerLibrary.sentence
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${inv_multiples}=  FakerLibrary.Numerify  %%
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[2]}  minDonationAmount=${min_don_amt}  maxDonationAmount=${max_don_amt}  multiples=${inv_multiples}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422  
    ${MULTIPLES_DOES_NOT_MATCH}=  Format String  ${MULTIPLES_DOES_NOT_MATCH}  ${inv_multiples}
    Should Be Equal As Strings   ${resp.json()}  ${MULTIPLES_DOES_NOT_MATCH}


# ................................ Virtual Service .......................... #


JD-TC-CreateService-UH25
    [Documentation]   Create virtual service with virtual calling mode as EMPTY.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${vstype}=   Random Element   ${vservicetype}
    ${virtualCallingModes}=  Create List  @{EMPTY}

    ${description}=    FakerLibrary.sentence
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}   virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${VIRTUAL_SERVICE_MODE_REQUIRED}"


JD-TC-CreateService-UH26
    [Documentation]   Create virtual service without meeting link when calling mode is ZOOM

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${meeting_id}=  Generate Random String    10    [NUMBERS]
    ${passwd}=  FakerLibrary.password  length=30  #special_chars=False  upper_case=False
    ${ZOOM_id0}=     Format String    ${ZOOM_URL}    meeting_id=9${meeting_id}    passwd=${passwd}.1
    
    ${Description1}=    FakerLibrary.sentences
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${EMPTY}   status=${status[0]}   instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}
    Set Test Variable  ${vstype}  ${vservicetype[1]}

    ${description}=    FakerLibrary.sentence
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}   virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${ZOOM_ID_REQUIRED}"


JD-TC-CreateService-UH27
    [Documentation]   Create virtual service without phone number when calling mode is WHATSAPP

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${Description1}=    FakerLibrary.sentences
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${EMPTY}   countryCode=${countryCodes[0]}  status=${status[0]}   instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}
    ${vstype}=   Random Element   ${vservicetype}

    ${description}=    FakerLibrary.sentence
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}   virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${WHATSAPP_NUMBER_REQUIRED}"


JD-TC-CreateService-UH28
    [Documentation]   Create virtual service without phone number when calling mode is PHONE

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${Description1}=    FakerLibrary.sentences
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[2]}   value=${EMPTY}   countryCode=${countryCodes[0]}  status=${status[0]}   instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}
    Set Test Variable  ${vstype}  ${vservicetype[0]}

    ${description}=    FakerLibrary.sentence
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}   virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${PHONE_NUMBER_REQUIRED}"


JD-TC-CreateService-UH29
    [Documentation]   Create virtual service without meeting id when calling mode is GoogleMeet

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${meeting_id}=   FakerLibrary.lexify  text='???-????-???'  letters=${lower}    # Adjust length and characters as needed
    # ${GoogleMeet_url}=     Format String    ${MEET_URL}    meeting_id=${meeting_id}
    # Log    ${meet_url}

    
    ${Description1}=    FakerLibrary.sentences
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[3]}   value=${EMPTY}   status=${status[0]}    instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}
    ${vstype}=   Random Element   ${vservicetype}

    ${description}=    FakerLibrary.sentence
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}   virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${GOOGLEMEET_ID_REQUIRED}"


JD-TC-CreateService-UH30
    [Documentation]   Create Virtual Service without enabling virtual service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['virtualService']}==${bool[1]}   
        ${resp}=   Enable Disable Virtual Service   ${toggle[1]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END
    
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
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${VIRTUAL_SERVICES_NOT_ENABLED}"


JD-TC-CreateService-UH31
    [Documentation]   Use Zoom (Video Service Type) to create an Audio service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['virtualService']}==${bool[0]}   
        ${resp}=   Enable Disable Virtual Service   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${meeting_id}=  Generate Random String    10    [NUMBERS]
    ${passwd}=  FakerLibrary.password  length=30  #special_chars=False  upper_case=False
    ${ZOOM_id0}=     Format String    ${ZOOM_URL}    meeting_id=9${meeting_id}    passwd=${passwd}.1
    
    ${Description1}=    FakerLibrary.sentences
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id0}   status=${status[0]}   instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}
    Set Test Variable  ${vstype}  ${vservicetype[0]}

    ${description}=    FakerLibrary.sentence
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}   virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${AUDIO_SERVICE_MODE_REQUIRED}"


JD-TC-CreateService-UH32
    [Documentation]   Use Phone or Whatsapp (Audio Service Type) to create a Video service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${Description1}=    FakerLibrary.sentences
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[2]}   value=${PUSERNAME_E}   countryCode=${countryCodes[0]}  status=${status[0]}   instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}
    Set Test Variable  ${vstype}  ${vservicetype[1]}

    ${description}=    FakerLibrary.sentence
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}   virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${VIDEO_SERVICE_MODE_REQUIRED}"


JD-TC-CreateService-UH33
    [Documentation]   Create Virtual Service with invalid zoom url

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${meeting_id}=  Generate Random String    10    [NUMBERS]
    # ${passwd}=  FakerLibrary.password  length=30  #special_chars=False  upper_case=False
    # ${ZOOM_id0}=     Format String    ${ZOOM_URL}    meeting_id=9${meeting_id}    passwd=${passwd}.1

    # ${inv_zoom_id}=  FakerLibrary.url
    
    ${Description1}=    FakerLibrary.sentences
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${PUSERNAME_E}   status=${status[0]}   instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}
    Set Test Variable  ${vstype}  ${vservicetype[1]}

    ${description}=    FakerLibrary.sentence
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}   virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_ZOOM_ID}"


JD-TC-CreateService-UH34
    [Documentation]   Create Virtual Service with invalid google meet id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${inv_meet_id}=  FakerLibrary.url
    
    ${Description1}=    FakerLibrary.sentences
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[3]}   value=${inv_meet_id}   status=${status[0]}    instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}
    Set Test Variable  ${vstype}  ${vservicetype[1]}

    ${description}=    FakerLibrary.sentence
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}   virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_MEET_ID}"

JD-TC-CreateService-UH35
    [Documentation]  Create a service with EMPTY sortOrder field.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME10}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description}=    FakerLibrary.sentence
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  sortOrder=${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200