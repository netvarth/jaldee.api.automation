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
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py



*** Test Cases ***


JD-TC-GetDefaultRolesWithCapabilities-1

    [Documentation]  Get default roles with capabilities of an existing provider.

    ${resp}=  Provider Login  ${MUSERNAME31}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Default Roles With Capabilities  ${rbac_feature[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${role_id1}    ${resp.json()[0]['roleId']}
    Set Suite Variable  ${role_name1}  ${resp.json()[0]['displayName']}
    Set Suite Variable  ${capability1}  ${resp.json()[0]['capabilityList']}

    Set Suite Variable  ${role_id2}    ${resp.json()[1]['roleId']}
    Set Suite Variable  ${role_name2}  ${resp.json()[1]['displayName']}
    Set Suite Variable  ${capability2}  ${resp.json()[1]['capabilityList']}

    Set Suite Variable  ${role_id3}    ${resp.json()[2]['roleId']}
    Set Suite Variable  ${role_name3}  ${resp.json()[2]['displayName']}
    Set Suite Variable  ${capability3}  ${resp.json()[2]['capabilityList']}

    Set Suite Variable  ${role_id4}    ${resp.json()[3]['roleId']}
    Set Suite Variable  ${role_name4}  ${resp.json()[3]['displayName']}
    Set Suite Variable  ${capability4}  ${resp.json()[3]['capabilityList']}

    Set Suite Variable  ${role_id5}    ${resp.json()[4]['roleId']}
    Set Suite Variable  ${role_name5}  ${resp.json()[4]['displayName']}
    Set Suite Variable  ${capability5}  ${resp.json()[4]['capabilityList']}

    Set Suite Variable  ${role_id6}    ${resp.json()[5]['roleId']}
    Set Suite Variable  ${role_name6}  ${resp.json()[5]['displayName']}
    Set Suite Variable  ${capability6}  ${resp.json()[5]['capabilityList']}

    Set Suite Variable  ${role_id7}    ${resp.json()[6]['roleId']}
    Set Suite Variable  ${role_name7}  ${resp.json()[6]['displayName']}
    Set Suite Variable  ${capability7}  ${resp.json()[6]['capabilityList']}


JD-TC-GetDefaultRolesWithCapabilities-2

    [Documentation]  Get default roles with capabilities for a new provider.

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}

    ${firstname_A}=  FakerLibrary.first_name
    ${lastname_A}=  FakerLibrary.last_name
   
    ${PO_Number}    Generate random string    5    123456789
    ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+${PO_Number}

    ${highest_package}=  get_highest_license_pkg

    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${MUSERNAME_E}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Set Credential  ${MUSERNAME_E}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
    
    ${resp}=  Get Default Roles With Capabilities  ${rbac_feature[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetDefaultRolesWithCapabilities-UH1

    [Documentation]  Get default roles with capabilities without login.

    ${resp}=  Get Default Roles With Capabilities  ${rbac_feature[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-GetDefaultRolesWithCapabilities-UH2

    [Documentation]  Get default roles with capabilities with consumer login.

    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Default Roles With Capabilities  ${rbac_feature[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}