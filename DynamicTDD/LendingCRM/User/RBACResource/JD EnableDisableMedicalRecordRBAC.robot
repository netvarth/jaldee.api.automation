*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        RBAC
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Test Cases ***

JD-TC-EnableDisableMedicalRecordRbac-1

    [Documentation]  Get default rbac settings of an existing provider.
    clear_Auditlog  ${PUSERNAME89}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${aid}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   []

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${time}=   db.get_time_by_timezone  ${tz}

    ${resp}=   Get Audit Logs
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['date']}       ${DAY1}
    Variable Should Exist       ${resp.json()[0]['time']}       ${time}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Logged in
    Should Be Equal As Strings  ${resp.json()[0]['text']}       Login
    Should Be Equal As Strings  ${resp.json()[0]['Action']}     ADD
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   PROVIDER
    

JD-TC-EnableDisableMedicalRecordRbac-2

    [Documentation]  enable rbac.
    clear_Auditlog  ${PUSERNAME89}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableRbac']}==${bool[0]}
        ${resp1}=  Enable Disable Main RBAC  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    IF  ${resp.json()['mrRbac']}==${bool[0]}
        ${resp1}=  Enable Disable Medical Record RBAC  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['mrRbac']}  ${bool[1]}

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    FOR   ${i}  IN RANGE   0   ${len}
        Should Contain    ${resp.json()[${i}]['featureName']}    medicalRecord
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${time}=   db.get_time_by_timezone  ${tz}

    ${resp}=   Get Audit Logs
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['date']}       ${DAY1}
    Variable Should Exist       ${resp.json()[0]['time']}       ${time}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Enabled MedicalRecord RBAC
    Should Be Equal As Strings  ${resp.json()[0]['text']}       Enabled MedicalRecord RBAC
    Should Be Equal As Strings  ${resp.json()[0]['Action']}     EDIT
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   PROVIDER

    Should Be Equal As Strings  ${resp.json()[1]['date']}       ${DAY1}
    Variable Should Exist       ${resp.json()[1]['time']}       ${time}
    Should Be Equal As Strings  ${resp.json()[1]['subject']}    Logged in
    Should Be Equal As Strings  ${resp.json()[1]['text']}       Login
    Should Be Equal As Strings  ${resp.json()[1]['Action']}     ADD
    Should Be Equal As Strings  ${resp.json()[1]['userType']}   PROVIDER



JD-TC-EnableDisableMedicalRecordRbac-3

    [Documentation]  disable rbac.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp1}=  Enable Disable Medical Record RBAC  ${toggle[1]}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['mrRbac']}  ${bool[0]}

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    FOR   ${i}  IN RANGE   0   ${len}
        Should Contain    ${resp.json()[${i}]['featureName']}    medicalRecord
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${time}=   db.get_time_by_timezone  ${tz}

    ${resp}=   Get Audit Logs
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['date']}       ${DAY1}
    Variable Should Exist       ${resp.json()[0]['time']}       ${time}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Disabled MedicalRecord RBAC
    Should Be Equal As Strings  ${resp.json()[0]['text']}       Disabled MedicalRecord RBAC
    Should Be Equal As Strings  ${resp.json()[0]['Action']}     EDIT
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   PROVIDER

    Should Be Equal As Strings  ${resp.json()[1]['date']}       ${DAY1}
    Variable Should Exist       ${resp.json()[1]['time']}       ${time}
    Should Be Equal As Strings  ${resp.json()[1]['subject']}    Enabled MedicalRecord RBAC
    Should Be Equal As Strings  ${resp.json()[1]['text']}       Enabled MedicalRecord RBAC
    Should Be Equal As Strings  ${resp.json()[1]['Action']}     EDIT
    Should Be Equal As Strings  ${resp.json()[1]['userType']}   PROVIDER

    Should Be Equal As Strings  ${resp.json()[2]['date']}       ${DAY1}
    Variable Should Exist       ${resp.json()[2]['time']}       ${time}
    Should Be Equal As Strings  ${resp.json()[2]['subject']}    Logged in
    Should Be Equal As Strings  ${resp.json()[2]['text']}       Login
    Should Be Equal As Strings  ${resp.json()[2]['Action']}     ADD

JD-TC-EnableDisableMedicalRecordRbac-4

    [Documentation]  enable rbac  which is disabled.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Enable Disable Medical Record RBAC  ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['mrRbac']}  ${bool[1]}

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    FOR   ${i}  IN RANGE   0   ${len}
        Should Contain    ${resp.json()[${i}]['featureName']}    medicalRecord
    END


JD-TC-EnableDisableMedicalRecordRbac-UH1

    [Documentation]  enable already enabled rbac.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${X_RBAC_ALREADY_ENABLED}=    format String   ${X_RBAC_ALREADY_ENABLED}   	Medical Record
   
    ${resp}=  Enable Disable Medical Record RBAC  ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${X_RBAC_ALREADY_ENABLED}

JD-TC-EnableDisableMedicalRecordRbac-UH2

    [Documentation]   Enable Rbac without login

    ${resp}=  Enable Disable Medical Record RBAC  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-EnableDisableMedicalRecordRbac-UH3

    [Documentation]   Enable Rbac Using Consumer Login

    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Medical Record RBAC  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-EnableDisableMedicalRecordRbac-UH4

    [Documentation]  disable rbac which is already disabled.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Enable Disable Medical Record RBAC  ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['mrRbac']}  ${bool[0]}

    ${X_RBAC_ALREADY_DISABLED}=    format String   ${X_RBAC_ALREADY_DISABLED}   	Medical Record

    ${resp}=  Enable Disable Medical Record RBAC  ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${X_RBAC_ALREADY_DISABLED}