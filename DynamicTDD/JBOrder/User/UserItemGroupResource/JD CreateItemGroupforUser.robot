*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        ITEM GROUP
Library           Collections
Library           String
Library           json
Library           DateTime
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Variables ***
@{emptylist}


*** Test Cases ***


JD-TC-CreateItemGroupforUser-1

    [Documentation]  Create Item Group for an existing multi user account.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME37}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableItemGroup']}==${bool[0]}
        ${resp1}=  Enable Disable Item Group  ${Qstate[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableItemGroup']}  ${bool[1]}

    ${groupName}=    FakerLibrary.word
    ${groupDesc}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateItemGroupforUser-2

    [Documentation]  Create multiple Item Group for an existing provider.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME37}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName}=    FakerLibrary.word
    ${groupDesc}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateItemGroupforUser-3

    [Documentation]  Create multiple Item Group with same name for an existing provider.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME38}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableItemGroup']}==${bool[0]}
        ${resp1}=  Enable Disable Item Group  ${Qstate[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableItemGroup']}  ${bool[1]}

    ${groupName}=    FakerLibrary.word
    ${groupDesc}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Item Group   ${groupName}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateItemGroupforUser-4

    [Documentation]  Create Item Group with group name as numbers

    ${resp}=  Encrypted Provider Login  ${MUSERNAME37}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName}=   Random Int   min=1000000   max=5000000
    ${groupDesc}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateItemGroupforUser-5

    [Documentation]  Create Item Group for a provider without group decscription.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableItemGroup']}==${bool[0]}
        ${resp1}=  Enable Disable Item Group  ${Qstate[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableItemGroup']}  ${bool[1]}
    
    ${groupName}=    FakerLibrary.word
    ${resp}=  Create Item Group   ${groupName}  ${EMPTY}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-CreateItemGroupforUser-6

    [Documentation]  Create Item Group by user.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME12}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableItemGroup']}==${bool[0]}
        ${resp1}=  Enable Disable Item Group  ${Qstate[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableItemGroup']}  ${bool[1]}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${MUSERNAME12}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id}=  Create Sample User  admin=${bool[0]}
    Set Test Variable  ${u_id}

    ${resp}=  Get User By Id  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SendProviderResetMail   ${BUSER_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BUSER_U1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName}=    FakerLibrary.word
    ${groupDesc}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateItemGroupforUser-7

    [Documentation]  Create Item Group by user(admin).

    ${resp}=  Encrypted Provider Login  ${MUSERNAME13}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableItemGroup']}==${bool[0]}
        ${resp1}=  Enable Disable Item Group  ${Qstate[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableItemGroup']}  ${bool[1]}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${MUSERNAME13}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id}=  Create Sample User  admin=${bool[1]}
    Set Test Variable  ${u_id}

    ${resp}=  Get User By Id  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SendProviderResetMail   ${BUSER_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BUSER_U1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName}=    FakerLibrary.word
    ${groupDesc}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateItemGroupforUser-UH1

    [Documentation]  Create Item Group for a provider without enable item group flag in account settings.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME10}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableItemGroup']}==${bool[1]}
        ${resp1}=  Enable Disable Item Group  ${Qstate[1]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableItemGroup']}  ${bool[0]}
    
    ${groupName}=    FakerLibrary.word
    ${groupDesc}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${ITEM_GROUP_DISABLED}

JD-TC-CreateItemGroupforUser-UH2

    [Documentation]  Create Item Group for a provider without group name.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME29}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableItemGroup']}==${bool[0]}
        ${resp1}=  Enable Disable Item Group  ${Qstate[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableItemGroup']}  ${bool[1]}
    
    ${groupDesc}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${EMPTY}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"   "${ITEM_GROUP_NAME_IS_MUST}" 

JD-TC-CreateItemGroupforUser-UH3

    [Documentation]  create item group without login

    ${groupName}=    FakerLibrary.word
    ${groupDesc}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}" 

JD-TC-CreateItemGroupforUser-UH4

    [Documentation]  Consumer try to create an Item group

    ${resp}=  Consumer Login    ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${groupName}=    FakerLibrary.word
    ${groupDesc}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"
