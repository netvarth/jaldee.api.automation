*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Comm Templates
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Test Cases ***

JD-TC-CreateCustomVariable-1

    [Documentation]  Create custom variable for the context signup.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME80}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateCustomVariable-2

    [Documentation]  Create custom variable for the context appointment.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME80}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateCustomVariable-3

    [Documentation]  Create custom variable for the context Token.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME83}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateCustomVariable-4

    [Documentation]  Create custom variable for the context order.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME84}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[3]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateCustomVariable-5

    [Documentation]  Create custom variable for the context donation.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME80}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[4]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateCustomVariable-6

    [Documentation]  Create custom variable for the context payment.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME80}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[4]}  ${VariableContext[5]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateCustomVariable-7

    [Documentation]  Create custom variable for the context All.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME80}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[3]}  ${VariableContext[6]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateCustomVariable-8

    [Documentation]  Create multiple custom variables for the context signup.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME81}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name1}=    FakerLibrary.firstname
    ${dis_name1}=    FakerLibrary.word
    ${value1}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name1}  ${dis_name1}  ${value1}  ${VariableValueType[2]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateCustomVariable-UH1

    [Documentation]  Create custom variable without login

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-CreateCustomVariable-UH2

    [Documentation]  Create custom variable with consumer login.

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-CreateCustomVariable-UH3

    [Documentation]  Create custom variable without name.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME80}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${EMPTY}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}   ${VARIABLE_NAME}

JD-TC-CreateCustomVariable-UH4

    [Documentation]  Create custom variable without display name.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME80}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${EMPTY}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}   ${VARIABLE_DISPLAY_NAME}

JD-TC-CreateCustomVariable-UH5

    [Documentation]  Create custom variable without value.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME80}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
  
    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${EMPTY}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}   ${VARIABLE_VALUE}

JD-TC-CreateCustomVariable-UH6

    [Documentation]  Create custom variable with same name.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME82}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${dis_name1}=    FakerLibrary.word
    ${value1}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name1}  ${value1}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}   ${VARIABLE_NAME_EXISTS}

JD-TC-CreateCustomVariable-UH7

    [Documentation]  Create custom variable with same display name.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME83}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name1}=    FakerLibrary.firstname
    ${value1}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name1}  ${dis_name}  ${value1}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}   ${VARIABLE_DISPLAY_NAME_EXISTS}

JD-TC-CreateCustomVariable-UH8

    [Documentation]  Create custom variable with name as integer.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME80}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name}=     Random Int  min=100   max=999
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[4]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422

JD-TC-CreateCustomVariable-UH9

    [Documentation]  Create custom variable with dispaly name as integer.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME80}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${dis_name}=     Random Int  min=100   max=999
    ${name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[4]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422