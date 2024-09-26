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
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Variables ***
${SERVICE1}   SERVICE1
${SERVICE2}   SERVICE2
${SERVICE3}   SERVICE3
${SERVICE4}   SERVICE4
${a}   0
${start}    150
@{service_duration}  10  20  30   40   50


*** Test Cases ***
 
 
JD-TC-GetServiceCount-1

    [Documentation]   Get Service Counts
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME10}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service       ${HLPUSERNAME10} 
    ${min_pre}=   Random Int  min=200  max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=   Random Int  min=600  max=800
    ${Total}=  Convert To Number  ${Total}  1
    ${description}=  FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${description}   {service_duration[2]}  ${bool[0]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=   Get Service Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1


JD-TC-GetServiceCount-2

    [Documentation]   Create more services and Get Service Counts
    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Random Int  min=200  max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=   Random Int  min=600  max=800
    ${Total}=  Convert To Number  ${Total}  1
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME10}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Create Service  ${SERVICE2}  ${description}   {service_duration[2]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre} 
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=  Create Service  ${SERVICE3}  ${description}   {service_duration[2]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre} 
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=   Get Service Count
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  3

JD-TC-GetServiceCount-3

    [Documentation]  Create a service ,Disable that service ,Then check the service counts
    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Random Int  min=200  max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=   Random Int  min=600  max=800
    ${Total}=  Convert To Number  ${Total}  1
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME10}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Create Service  ${SERVICE4}  ${description}   {service_duration[2]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${id}  ${resp.json()}  
    ${resp}=   Get Service Count
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  4
    ${resp}=  Disable service  ${id}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Service Count
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  4
    ${resp}=  Enable service  ${id}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Service Count
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  4

JD-TC-GetServiceCount-UH2


    [Documentation]  Check the service counts without login
    ${resp}=  Get Service Count
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}    ${SESSION_EXPIRED}

JD-TC-GetServiceCount-UH3     

    [Documentation]  Check the service counts using consumer login

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME10}  ${PASSWORD}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${accountId}=  get_acc_id  ${HLPUSERNAME10}
    Set Suite Variable    ${accountId} 
    
    ${PH_Number}    Random Number 	       digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable    ${primaryMobileNo}  555${PH_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/proconnum.txt  ${SUITE NAME} - ${TEST NAME} - ${primaryMobileNo}${\n}
    ${firstName}=   FakerLibrary.first_name
    ${lastName}=    FakerLibrary.last_name
    Set Suite Variable      ${firstName}
    Set Suite Variable      ${lastName}  
    ${dob}=    FakerLibrary.Date
    ${permanentAddress1}=  FakerLibrary.address
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${email}  ${C_Email}${primaryMobileNo}${firstName}.${test_mail}

    ${resp}=  AddCustomer  ${primaryMobileNo}  firstName=${firstName}   lastName=${lastName}  address=${permanentAddress1}   gender=${gender}  dob=${dob}  email=${email}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ageyrs}  ${agemonths}=  db.calculate_age_years_months     ${dob}

    ${resp}=  GetCustomer  phoneNo-eq=${primaryMobileNo}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${consumerId}  ${resp.json()[0]['id']}
    ${fullastName}   Set Variable    ${firstName} ${lastName}
    Set Test Variable  ${fullastName}

    ${resp}=  Provider Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}
   
    ${resp}=    ProviderConsumer Login with token    ${primaryMobileNo}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=  Get Service Count
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}


