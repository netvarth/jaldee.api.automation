*** Settings ***
Library    OperatingSystem
Library    String
Library    Collections
Resource   /ebs/TDD/ProviderKeywords.robot

*** Variables ***
${var_file}               ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py
${data_file}              ${EXECDIR}/data/${ENVIRONMENT}data/${ENVIRONMENT}phnumbers.txt
# ${new_file}               ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers_real.py
# ${new_file}              ${EXECDIR}/data/${ENVIRONMENT}data/${ENVIRONMENT}phnumbers_real.txt

*** Test Cases ***
Remove Entry From Var File
    ${content}=   Get File   ${var_file} 
    ${lines}=  Split To Lines  ${content} 
    ${pro_list}=  Copy List  ${lines}

    ${counter}=    Set Variable   1
    FOR  ${provider}  IN  @{pro_list}
        ${provider_deets}=  Remove String    ${provider}    ${SPACE}
        ${provider_name}  ${ph}=    Split String    ${provider_deets}    =
        Set Test Variable  ${ph}
        
        ${resp}=    Encrypted Provider Login    ${ph}    ${PASSWORD}
        IF  ${resp.status_code} != 200
            Remove Values From List    ${lines}    ${provider}
        ELSE
            ${new_provider_name}=    Set Variable    PUSERNAME${counter}
            ${new_provider}=    Catenate    SEPARATOR=    ${new_provider_name}=${ph}
            ${index}=    Get Index From List    ${lines}    ${provider}
            Set List Value    ${lines}    ${index}    ${new_provider}
            # ${counter}=    ${counter} + 1
            ${counter}=  Set Variable  ${${counter} + 1}
        END
    END

    ${updated_content}=    Catenate    SEPARATOR=\n    @{lines}
    Create File    ${var_file}    ${updated_content}
    # Create File   ${new_file}   ${updated_content}

# *** COMMENTS ***
Remove Entry From Data File
    ${content}=   Get File   ${data_file} 
    ${lines}=  Split To Lines  ${content} 
    ${pro_list}=  Copy List  ${lines}

    FOR  ${provider}  IN  @{pro_list}
        ${provider_deets}=  Remove String    ${provider}    ${SPACE}
        ${ph}  ${PASSWORD}=    Split String    ${provider_deets}    -
        Set Test Variable  ${ph}
        
        ${resp}=    Encrypted Provider Login    ${ph}    ${PASSWORD}
        IF  ${resp.status_code} != 200
            Remove Values From List    ${lines}    ${provider}
        END
    END

    ${updated_content}=    Catenate    SEPARATOR=\n    @{lines}
    Create File    ${data_file}    ${updated_content}
    # Create File   ${new_file}   ${updated_content}
