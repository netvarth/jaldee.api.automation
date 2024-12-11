*** Settings ***
Library    OperatingSystem
Library    String
Library    Collections
Resource   /ebs/TDD/ProviderKeywords.robot

*** Variables ***
${var_file}               ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py
${data_file}              ${EXECDIR}/data/${ENVIRONMENT}data/${ENVIRONMENT}phnumbers.txt
${new_file}               ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers_real.py
${SPACE}                 =

*** Test Cases ***
Remove Entry From File
    ${content}=    Get File    ${var_file}
    ${lines}=    Split To Lines    ${content}
    ${providers_list}=    Get File    ${var_file}
    ${pro_list}=    Split To Lines   ${providers_list}

    FOR  ${provider}  IN  @{pro_list}
        ${provider_deets}=  Remove String    ${provider}    ${SPACE}
        ${provider_name}  ${ph}=    Split String    ${provider_deets}    =
        Set Test Variable  ${ph}
        
        ${resp}=    Encrypted Provider Login    ${ph}    ${PASSWORD}
        IF  ${resp.status_code} != 200
            Remove From List    ${lines}    ${provider}
        END
    END

    ${updated_content}=    Catenate    SEPARATOR=\n    ${lines}
    Write File    ${new_file}    ${updated_content}
