*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        CRM
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/consumermail.py


*** Test Cases ***

JD-TC-EnableDisableCRM-1

    [Documentation]   Enable CRM for a valid provider.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME131}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['enableCrm']}==${bool[0]}   Enable Disable CRM  ${toggle[0]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  enableCrm=${bool[1]}


JD-TC-EnableDisableCRM-2

    [Documentation]   Disable CRM After Enabling

    ${resp}=  Encrypted Provider Login  ${PUSERNAME131}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['enableCrm']}==${bool[0]}   Enable Disable CRM  ${toggle[0]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['enableCrm']}==${bool[1]}   Enable Disable CRM  ${toggle[1]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  enableCrm=${bool[0]}


JD-TC-EnableDisableCRM-3

    [Documentation]   Enable CRM which is Disabled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME131}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['enableCrm']}==${bool[1]}   Enable Disable CRM  ${toggle[1]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['enableCrm']}==${bool[0]}   Enable Disable CRM  ${toggle[0]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  enableCrm=${bool[1]}


JD-TC-EnableDisableCRM-UH1

    [Documentation]   Enable CRM without login

    ${resp}=  Enable Disable CRM  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-EnableDisableCRM-UH2

    [Documentation]   Enable CRM Using Consumer Login

    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable CRM  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-EnableDisableCRM-UH3

    [Documentation]   Enable CRM Which is already enabled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME131}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['enableCrm']}==${bool[0]}   Enable Disable CRM  ${toggle[0]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${CRM_ALREDY_ENABLED}=  format String   ${CRM_ALREDY_ENABLED}   CRM

    ${resp}=  Run Keyword If  ${resp.json()['enableCrm']}==${bool[1]}   Enable Disable CRM  ${toggle[0]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${CRM_ALREDY_ENABLED}
    

JD-TC-EnableDisableCRM-UH4

    [Documentation]   Disable CRM Which is already Disabled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME131}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['enableCrm']}==${bool[1]}   Enable Disable CRM  ${toggle[1]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${CRM_ALREDY_DISABLED}=  format String   ${CRM_ALREDY_DISABLED}   CRM

    ${resp}=  Run Keyword If  ${resp.json()['enableCrm']}==${bool[0]}   Enable Disable CRM  ${toggle[1]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${CRM_ALREDY_DISABLED}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

