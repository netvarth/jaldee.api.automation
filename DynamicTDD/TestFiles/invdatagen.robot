*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment
Library           Collections
Library           String
Library           json
Library           random
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables          ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py


*** Variables ***

${self}     0
@{service_names}
${var_file}               ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py
${data_file}              ${EXECDIR}/data/${ENVIRONMENT}data/${ENVIRONMENT}phnumbers.txt
${LoginId}       ${PUSERNAME8}

*** Test Cases ***

JD-TC-Appointment-1

    [Documentation]  appt data generation

    ${resp}=  Encrypted Provider Login  ${LoginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}
    Set Test Variable  ${pdrname}  ${decrypted_data['userName']}


    ${resp}=    Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # FOR  ${service}  IN  @{resp.json()}
    #     IF   ${service['isPrePayment']} == ${bool[1]}
    #         ${FOUND}  Set Variable  True
    #         Set Test Variable  ${min_pre}  ${service['minPrePaymentAmount']}
    #         Set Test Variable  ${s_id}   ${service['id']}
    #         BREAK
    #     END
    # END