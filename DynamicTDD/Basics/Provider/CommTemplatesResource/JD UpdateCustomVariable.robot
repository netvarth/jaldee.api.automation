*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Comm Templates
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Test Cases ***

JD-TC-UpdateCustomVariable-1

    [Documentation]  Create custom variable and update it with same details then get it by id and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME60}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id1}  ${resp.json()}

    ${resp}=  Get Custom Variable By Id   ${var_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

    ${resp}=  Update Custom Variable   ${var_id1}  ${name}  ${dis_name}  ${value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Custom Variable By Id   ${var_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

JD-TC-UpdateCustomVariable-2

    [Documentation]  Create custom variable and update it different name then get it by id and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME61}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id1}  ${resp.json()}

    ${resp}=  Get Custom Variable By Id   ${var_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

    ${name1}=    generate_firstname

    ${resp}=  Update Custom Variable   ${var_id1}  ${name1}  ${dis_name}  ${value}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Custom Variable By Id   ${var_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name1}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

JD-TC-UpdateCustomVariable-3

    [Documentation]  Create custom variable and update it different display name then get it by id and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME68}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id1}  ${resp.json()}

    ${resp}=  Get Custom Variable By Id   ${var_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${dis_name1}=    generate_firstname

    ${resp}=  Update Custom Variable   ${var_id1}  ${name}  ${dis_name1}  ${value}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Custom Variable By Id   ${var_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name1} 
   
JD-TC-UpdateCustomVariable-4

    [Documentation]  Create custom variable and update it different value then get it by id and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME63}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id1}  ${resp.json()}

    ${resp}=  Get Custom Variable By Id   ${var_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

    ${value1}=   FakerLibrary.hostname

    ${resp}=  Update Custom Variable   ${var_id1}  ${name}  ${dis_name}  ${value1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Custom Variable By Id   ${var_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value1}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

JD-TC-UpdateCustomVariable-5

    [Documentation]  Create custom variable and update it without name.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id1}  ${resp.json()}

    ${resp}=  Get Custom Variable By Id   ${var_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

    ${resp}=  Update Custom Variable   ${var_id1}  ${EMPTY}  ${dis_name}  ${value}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Custom Variable By Id   ${var_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

JD-TC-UpdateCustomVariable-6

    [Documentation]  Create custom variable and update it without display name.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME65}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id1}  ${resp.json()}

    ${resp}=  Get Custom Variable By Id   ${var_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

    ${resp}=  Update Custom Variable   ${var_id1}  ${name}  ${EMPTY}  ${value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Custom Variable By Id   ${var_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

JD-TC-UpdateCustomVariable-7

    [Documentation]  Create custom variable and update it without value.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME66}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id1}  ${resp.json()}

    ${resp}=  Get Custom Variable By Id   ${var_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

    ${resp}=  Update Custom Variable   ${var_id1}  ${name}  ${dis_name}  ${EMPTY}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Custom Variable By Id   ${var_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

JD-TC-UpdateCustomVariable-UH1

    [Documentation]  Update custom variable with provider consumer login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME80}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id1}  ${resp.json()}

    #............provider consumer creation..........

    ${NewCustomer}    Generate random string    10    123456789
    ${NewCustomer}    Convert To Integer  ${NewCustomer}

    ${custf_name}=  FakerLibrary.name    
    ${custl_name}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${NewCustomer}    firstName=${custf_name}   lastName=${custl_name}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Send Otp For Login    ${NewCustomer}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    # ${resp}=    Consumer Logout
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}  ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Update Custom Variable     ${var_id1}  ${name}  ${dis_name}  ${value}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-UpdateCustomVariable-UH2

    [Documentation]  Update custom variable without login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME68}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id1}  ${resp.json()}

    ${resp}=  ProviderLogout  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Custom Variable   ${var_id1}  ${name}  ${dis_name}  ${value}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-UpdateCustomVariable-UH3

    [Documentation]  update custom variable using another providers variable id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME69}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Create Custom Variable   ${name}  ${dis_name}  ${value}  ${VariableValueType[1]}  ${VariableContext[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${var_id1}  ${resp.json()}

    ${resp}=  Get Custom Variable By Id   ${var_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}              ${var_id1} 
    Should Be Equal As Strings  ${resp.json()['name']}            ${name}
    Should Be Equal As Strings  ${resp.json()['displayName']}     ${dis_name} 
    Should Be Equal As Strings  ${resp.json()['value']}           ${value}
    Should Be Equal As Strings  ${resp.json()['type']}            ${VariableValueType[1]} 
    Should Be Equal As Strings  ${resp.json()['context']}         ${VariableContext[0]}
    Should Be Equal As Strings  ${resp.json()['status']}          ${VarStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name}=    FakerLibrary.word
    ${dis_name}=    FakerLibrary.word
    ${value}=   FakerLibrary.hostname

    ${resp}=  Update Custom Variable   ${var_id1}  ${name}  ${dis_name}  ${value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}   ${VARIABLE_NOT_FOUND}
