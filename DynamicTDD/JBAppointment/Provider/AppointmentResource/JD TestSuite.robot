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
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

${self}     0
@{service_names}

*** Test Cases ***

JD-TC-GetAppointmentToday-1

    [Documentation]  takes two walkin appointment for today and verify today appointment details.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
    Set Suite Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}
    ${resp}=  AddCustomer  ${CUSERNAME20}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}   email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${cid}  ${resp.json()}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
    Set Suite Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}
    ${resp}=  AddCustomer  ${CUSERNAME20}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}   email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${cid}  ${resp.json()}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME102}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
    Set Suite Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}
    ${resp}=  AddCustomer  ${CUSERNAME20}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}   email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${cid}  ${resp.json()}