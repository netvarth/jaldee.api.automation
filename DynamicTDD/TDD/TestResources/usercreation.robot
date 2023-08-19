*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        USER
Library           Collections
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_musers.py


*** Variables ***

${self}      0
@{emptylist} 

*** Test Cases ***

JD-TC-CreateUser-1

    [Documentation]   create 10 users by a multi user.

    ${resp}=  Provider Login  ${HLMUSERNAME10}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    ${resp}=   Run Keyword If  '${lic_id}' != '${lic2}'  Change License Package  ${highest_package[0]}
    Run Keyword If   '${resp}' != '${None}'  Log  ${resp.json()}
    Run Keyword If   '${resp}' != '${None}'  Should Be Equal As Strings  ${resp.status_code}  200

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
    END
    FOR   ${i}  IN RANGE   0   ${len}
        Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
        IF   not '${user_phone}' == '${HLMUSERNAME10}'
            clear_users  ${user_phone}
        END
    END

    @{u_ids}=  Create List

    FOR   ${i}  IN RANGE   0   10

        ${resp}=  Provider Login  ${HLMUSERNAME10}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${u_id}=  Create Sample User  admin=${bool[0]}
        Set Test Variable   ${u_id${i}}   ${u_id}
        Append To List   ${u_ids}  ${u_id${i}}

        ${resp}=  Get User By Id  ${u_id${i}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${BUSER_U1${i}}  ${resp.json()['mobileNo']}

        ${resp}=  Provider Logout
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  SendProviderResetMail   ${BUSER_U1${i}}
        Should Be Equal As Strings  ${resp.status_code}  200

        @{resp}=  ResetProviderPassword  ${BUSER_U1${i}}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
        Should Be Equal As Strings  ${resp[0].status_code}  200
        Should Be Equal As Strings  ${resp[1].status_code}  200

        ${resp}=  Provider Login  ${BUSER_U1${i}}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  ProviderLogout
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200


    END

    Log List   ${u_ids}
