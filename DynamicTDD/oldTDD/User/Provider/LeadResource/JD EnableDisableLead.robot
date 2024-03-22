*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Lead
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/musers.py


*** Test Cases ***

JD-TC-EnableDisableLeadforUser-1

    [Documentation]   Enable Lead.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['enableLead']}==${bool[0]}   Enable Disable Lead  ${toggle[0]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  enableLead=${bool[1]}


JD-TC-EnableDisableLeadforUser-2

    [Documentation]   Disable Lead After Enabling

    ${resp}=  Encrypted Provider Login  ${MUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['enableLead']}==${bool[0]}   Enable Disable Lead  ${toggle[0]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['enableLead']}==${bool[1]}   Enable Disable Lead  ${toggle[1]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  enableLead=${bool[0]}


JD-TC-EnableDisableLeadforUser-3

    [Documentation]   Enable Lead which is Disabled

    ${resp}=  Encrypted Provider Login  ${MUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['enableLead']}==${bool[1]}   Enable Disable Lead  ${toggle[1]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['enableLead']}==${bool[0]}   Enable Disable Lead  ${toggle[0]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  enableLead=${bool[1]}


JD-TC-EnableDisableLeadforUser-UH1

    [Documentation]   Enable Lead without login

    ${resp}=  Enable Disable Lead  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-EnableDisableLeadforUser-UH2

    [Documentation]   Enable Lead Using Consumer Login

    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Lead  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-EnableDisableLeadforUser-UH3

    [Documentation]   Enable Lead Which is already enabled

    ${resp}=  Encrypted Provider Login  ${MUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['enableLead']}==${bool[0]}   Enable Disable Lead  ${toggle[0]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['enableLead']}==${bool[1]}   Enable Disable Lead  ${toggle[0]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${LEAD_ALREDY_ENABLED}
    

JD-TC-EnableDisableLeadforUser-UH4

    [Documentation]   Disable Lead Which is already Disabled

    ${resp}=  Encrypted Provider Login  ${MUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['enableLead']}==${bool[1]}   Enable Disable Lead  ${toggle[1]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['enableLead']}==${bool[0]}   Enable Disable Lead  ${toggle[1]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${Lead_ALREDY_DISABLED}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

