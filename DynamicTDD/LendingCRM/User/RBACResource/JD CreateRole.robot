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

*** Variables ***

@{emptylist}

*** Test Cases ***

JD-TC-CreateRole-1

    [Documentation]   Provider Create a role empty capability and scope.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable   ${lic_id}   ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableRbac']}==${bool[0]}
        ${resp1}=  Enable Disable CDL RBAC  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get roles
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${role_id1}    ${resp.json()[0]['id']}
    Set Suite Variable  ${role_name1}  ${resp.json()[0]['roleName']}

    ${description}=    Fakerlibrary.Sentence    
    # ${featureName}=    FakerLibrary.name    

    ${resp}=  Create Role      ${role_name1}    ${description}    ${rbac_feature[0]}    ${emptylist}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable  ${id}  ${resp.json()[${len}-1]['id']}

    ${resp}=  Get roles by id    ${id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${id}
    # Should Be Equal As Strings  ${resp.json()['roleId']}  0
    Should Be Equal As Strings  ${resp.json()['roleName']}  ${role_name1}
    Should Be Equal As Strings  ${resp.json()['description']}  ${description}
    Should Be Equal As Strings  ${resp.json()['status']}  ${toggle[0]}
    Should Be Equal As Strings  ${resp.json()['featureName']}   ${rbac_feature[0]}


JD-TC-CreateRole-2

    [Documentation]  Create  Roles with Department scope is 'All'.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description1}=    Fakerlibrary.Sentence    

    ${Department}=  Create List           all

    ${user_scope}=   Create Dictionary     departments=${Department}  

    ${resp}=  Create Role      ${role_name1}    ${description1}     ${rbac_feature[0]}   ${emptylist}   scope=${user_scope}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id_2}  ${resp.json()}

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable  ${id2}  ${resp.json()[${len}-1]['id']}

    ${resp}=  Get roles by id    ${id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${id2}
    # Should Be Equal As Strings  ${resp.json()['roleId']}   ${id_2}
    Should Be Equal As Strings  ${resp.json()['roleName']}  ${role_name1}
    Should Be Equal As Strings  ${resp.json()['description']}  ${description1}
    Should Be Equal As Strings  ${resp.json()['status']}  ${toggle[0]}
    Should Be Equal As Strings  ${resp.json()['featureName']}   ${rbac_feature[0]}
    Should Be Equal As Strings  ${resp.json()['scope']['departments']}  ${Department}

JD-TC-CreateRole-3

    [Documentation]  Create  Roles with labels scope is 'All'.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description1}=    Fakerlibrary.Sentence    
    ${role_name3}=    FakerLibrary.name 

    ${labels}=  Create List           all

    ${user_scope}=   Create Dictionary     labels=${labels}  

    ${resp}=  Create Role      ${role_name3}    ${description1}     ${rbac_feature[0]}   ${emptylist}   scope=${user_scope}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id_3}  ${resp.json()}

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable  ${id3}  ${resp.json()[${len}-1]['id']}

    ${resp}=  Get roles by id    ${id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${id3}
    # Should Be Equal As Strings  ${resp.json()['roleId']}   ${id_3}
    Should Be Equal As Strings  ${resp.json()['roleName']}  ${role_name3}
    Should Be Equal As Strings  ${resp.json()['description']}  ${description1}
    Should Be Equal As Strings  ${resp.json()['status']}  ${toggle[0]}
    Should Be Equal As Strings  ${resp.json()['featureName']}   ${rbac_feature[0]}
    Should Be Equal As Strings  ${resp.json()['scope']['labels']}  ${labels}


JD-TC-CreateRole-4

    [Documentation]  Create  Roles with internalStatus scope is 'All'.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description1}=    Fakerlibrary.Sentence    
    ${role_name4}=    FakerLibrary.name 

    ${internalStatus}=  Create List           all

    ${user_scope}=   Create Dictionary     internalStatus=${internalStatus}  

    ${resp}=  Create Role      ${role_name4}    ${description1}     ${rbac_feature[0]}   ${emptylist}   scope=${user_scope}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id_4}  ${resp.json()}

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable  ${id4}  ${resp.json()[${len}-1]['id']}

    ${resp}=  Get roles by id    ${id4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${id4}
    # Should Be Equal As Strings  ${resp.json()['roleId']}   ${id_4}
    Should Be Equal As Strings  ${resp.json()['roleName']}  ${role_name4}
    Should Be Equal As Strings  ${resp.json()['description']}  ${description1}
    Should Be Equal As Strings  ${resp.json()['status']}  ${toggle[0]}
    Should Be Equal As Strings  ${resp.json()['featureName']}   ${rbac_feature[0]}
    Should Be Equal As Strings  ${resp.json()['scope']['internalStatus']}  ${internalStatus}

JD-TC-CreateRole-5

    [Documentation]  Create  Roles with pincodes scope is 'All'.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description1}=    Fakerlibrary.Sentence    
    ${role_name5}=    FakerLibrary.name 

    ${pincodes}=  Create List           all

    ${user_scope}=   Create Dictionary     pincodes=${pincodes}  

    ${resp}=  Create Role      ${role_name5}    ${description1}     ${rbac_feature[0]}   ${emptylist}   scope=${user_scope}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id_5}  ${resp.json()}

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable  ${id5}  ${resp.json()[${len}-1]['id']}

    ${resp}=  Get roles by id    ${id5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${id5}
    # Should Be Equal As Strings  ${resp.json()['roleId']}   ${id_5}
    Should Be Equal As Strings  ${resp.json()['roleName']}  ${role_name5}
    Should Be Equal As Strings  ${resp.json()['description']}  ${description1}
    Should Be Equal As Strings  ${resp.json()['status']}  ${toggle[0]}
    Should Be Equal As Strings  ${resp.json()['featureName']}   ${rbac_feature[0]}
    Should Be Equal As Strings  ${resp.json()['scope']['pincodes']}  ${pincodes}

JD-TC-CreateRole-6

    [Documentation]  Create  Roles with services scope is 'All'.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description1}=    Fakerlibrary.Sentence    
    ${role_name6}=    FakerLibrary.name 

    ${services}=  Create List           all

    ${user_scope}=   Create Dictionary     services=${services}  

    ${resp}=  Create Role      ${role_name6}    ${description1}     ${rbac_feature[0]}   ${emptylist}   scope=${user_scope}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id_6}  ${resp.json()}

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable  ${id6}  ${resp.json()[${len}-1]['id']}

    ${resp}=  Get roles by id    ${id6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${id6}
    # Should Be Equal As Strings  ${resp.json()['roleId']}   ${id_6}
    Should Be Equal As Strings  ${resp.json()['roleName']}  ${role_name6}
    Should Be Equal As Strings  ${resp.json()['description']}  ${description1}
    Should Be Equal As Strings  ${resp.json()['status']}  ${toggle[0]}
    Should Be Equal As Strings  ${resp.json()['featureName']}   ${rbac_feature[0]}
    Should Be Equal As Strings  ${resp.json()['scope']['services']}  ${services}

JD-TC-CreateRole-7

    [Documentation]  Create  Roles with partners scope is 'All'.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description1}=    Fakerlibrary.Sentence    
    ${role_name7}=    FakerLibrary.name 

    ${partners}=  Create List           all

    ${user_scope}=   Create Dictionary     partners=${partners}  

    ${resp}=  Create Role      ${role_name7}    ${description1}     ${rbac_feature[0]}   ${emptylist}   scope=${user_scope}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id_7}  ${resp.json()}

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable  ${id7}  ${resp.json()[${len}-1]['id']}

    ${resp}=  Get roles by id    ${id7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${id7}
    # Should Be Equal As Strings  ${resp.json()['roleId']}   ${id_7}
    Should Be Equal As Strings  ${resp.json()['roleName']}  ${role_name7}
    Should Be Equal As Strings  ${resp.json()['description']}  ${description1}
    Should Be Equal As Strings  ${resp.json()['status']}  ${toggle[0]}
    Should Be Equal As Strings  ${resp.json()['featureName']}   ${rbac_feature[0]}
    Should Be Equal As Strings  ${resp.json()['scope']['partners']}  ${partners}

JD-TC-CreateRole-8

    [Documentation]  Create  Roles with branches scope is 'All'.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description1}=    Fakerlibrary.Sentence    
    ${role_name8}=    FakerLibrary.name 

    ${branches}=  Create List           all

    ${user_scope}=   Create Dictionary     branches=${branches}  

    ${resp}=  Create Role      ${role_name8}    ${description1}     ${rbac_feature[0]}   ${emptylist}   scope=${user_scope}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id_8}  ${resp.json()}

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable  ${id8}  ${resp.json()[${len}-1]['id']}

    ${resp}=  Get roles by id    ${id8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${id8}
    # Should Be Equal As Strings  ${resp.json()['roleId']}   ${id_8}
    Should Be Equal As Strings  ${resp.json()['roleName']}  ${role_name8}
    Should Be Equal As Strings  ${resp.json()['description']}  ${description1}
    Should Be Equal As Strings  ${resp.json()['status']}  ${toggle[0]}
    Should Be Equal As Strings  ${resp.json()['featureName']}   ${rbac_feature[0]}
    Should Be Equal As Strings  ${resp.json()['scope']['branches']}  ${branches}

JD-TC-CreateRole-9

    [Documentation]  Create  Roles with businessLocations scope is 'All'.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description1}=    Fakerlibrary.Sentence    
    ${role_name9}=    FakerLibrary.name 

    ${businessLocations}=  Create List           all

    ${user_scope}=   Create Dictionary     businessLocations=${businessLocations}  

    ${resp}=  Create Role      ${role_name9}    ${description1}     ${rbac_feature[0]}   ${emptylist}   scope=${user_scope}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id_9}  ${resp.json()}

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable  ${id9}  ${resp.json()[${len}-1]['id']}

    ${resp}=  Get roles by id    ${id9}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${id9}
    # Should Be Equal As Strings  ${resp.json()['roleId']}   ${id_9}
    Should Be Equal As Strings  ${resp.json()['roleName']}  ${role_name9}
    Should Be Equal As Strings  ${resp.json()['description']}  ${description1}
    Should Be Equal As Strings  ${resp.json()['status']}  ${toggle[0]}
    Should Be Equal As Strings  ${resp.json()['featureName']}   ${rbac_feature[0]}
    Should Be Equal As Strings  ${resp.json()['scope']['businessLocations']}  ${businessLocations}

JD-TC-CreateRole-10

    [Documentation]  Create  Roles with areaIds scope is 'All'.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description1}=    Fakerlibrary.Sentence    
    ${role_name10}=    FakerLibrary.name 

    ${areaIds}=  Create List           all

    ${user_scope}=   Create Dictionary     areaIds=${areaIds}  

    ${resp}=  Create Role      ${role_name10}    ${description1}     ${rbac_feature[0]}   ${emptylist}   scope=${user_scope}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id_10}  ${resp.json()}

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable  ${id10}  ${resp.json()[${len}-1]['id']}

    ${resp}=  Get roles by id    ${id10}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${id10}
    # Should Be Equal As Strings  ${resp.json()['roleId']}   ${id_10}
    Should Be Equal As Strings  ${resp.json()['roleName']}  ${role_name10}
    Should Be Equal As Strings  ${resp.json()['description']}  ${description1}
    Should Be Equal As Strings  ${resp.json()['status']}  ${toggle[0]}
    Should Be Equal As Strings  ${resp.json()['featureName']}   ${rbac_feature[0]}
    Should Be Equal As Strings  ${resp.json()['scope']['areaIds']}  ${areaIds}

JD-TC-CreateRole-11

    [Documentation]  Create  Roles with regionIds scope is 'All'.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description1}=    Fakerlibrary.Sentence    
    ${role_name11}=    FakerLibrary.name 

    ${regionIds}=  Create List           all

    ${user_scope}=   Create Dictionary     regionIds=${regionIds}  

    ${resp}=  Create Role      ${role_name11}    ${description1}     ${rbac_feature[0]}   ${emptylist}   scope=${user_scope}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id_11}  ${resp.json()}

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable  ${id11}  ${resp.json()[${len}-1]['id']}

    ${resp}=  Get roles by id    ${id11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${id11}
    # Should Be Equal As Strings  ${resp.json()['roleId']}   ${id_11}
    Should Be Equal As Strings  ${resp.json()['roleName']}  ${role_name11}
    Should Be Equal As Strings  ${resp.json()['description']}  ${description1}
    Should Be Equal As Strings  ${resp.json()['status']}  ${toggle[0]}
    Should Be Equal As Strings  ${resp.json()['featureName']}   ${rbac_feature[0]}
    Should Be Equal As Strings  ${resp.json()['scope']['regionIds']}  ${regionIds}

JD-TC-CreateRole-12

    [Documentation]  Create  Roles with users scope is 'All'.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description1}=    Fakerlibrary.Sentence    
    ${role_name12}=    FakerLibrary.name 

    ${users}=  Create List           all

    ${user_scope}=   Create Dictionary     users=${users}  

    ${resp}=  Create Role      ${role_name12}    ${description1}     ${rbac_feature[0]}   ${emptylist}   scope=${user_scope}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id_12}  ${resp.json()}

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable  ${id12}  ${resp.json()[${len}-1]['id']}

    ${resp}=  Get roles by id    ${id12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${id12}
    # Should Be Equal As Strings  ${resp.json()['roleId']}   ${id_12}
    Should Be Equal As Strings  ${resp.json()['roleName']}  ${role_name12}
    Should Be Equal As Strings  ${resp.json()['description']}  ${description1}
    Should Be Equal As Strings  ${resp.json()['status']}  ${toggle[0]}
    Should Be Equal As Strings  ${resp.json()['featureName']}   ${rbac_feature[0]}
    Should Be Equal As Strings  ${resp.json()['scope']['users']}  ${users}

JD-TC-CreateRole-13

    [Documentation]  Create  Roles with all scope is 'All'.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description1}=    Fakerlibrary.Sentence    
    ${role_name12}=    FakerLibrary.name 

    ${departments}=  Create List           all
    ${labels}=  Create List           all
    ${internalStatus}=  Create List           all
    ${pincodes}=  Create List           all
    ${services}=  Create List           all
    ${partners}=  Create List           all
    ${branches}=  Create List           all
    ${businessLocations}=  Create List           all
    ${areaIds}=  Create List           all
    ${regionIds}=  Create List           all
    ${users}=  Create List           all

    ${user_scope}=   Create Dictionary   departments=${departments}      labels=${labels}   internalStatus=${internalStatus}     pincodes=${pincodes}      services=${services}      partners=${partners}      branches=${branches}      businessLocations=${businessLocations}   areaIds=${areaIds}      regionIds=${regionIds}       users=${users}  

    ${resp}=  Create Role      ${role_name12}    ${description1}     ${rbac_feature[0]}   ${emptylist}   scope=${user_scope}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id_12}  ${resp.json()}

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable  ${id12}  ${resp.json()[${len}-1]['id']}

    ${resp}=  Get roles by id    ${id12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${id12}
    # Should Be Equal As Strings  ${resp.json()['roleId']}   ${id_12}
    Should Be Equal As Strings  ${resp.json()['roleName']}  ${role_name12}
    Should Be Equal As Strings  ${resp.json()['description']}  ${description1}
    Should Be Equal As Strings  ${resp.json()['status']}  ${toggle[0]}
    Should Be Equal As Strings  ${resp.json()['featureName']}   ${rbac_feature[0]}
    Should Be Equal As Strings  ${resp.json()['scope']['users']}  ${users}

JD-TC-CreateRole-14

    [Documentation]  Create  Roles with capabilities is 'actionRequired,viewLeadCreditStatus'.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description1}=    Fakerlibrary.Sentence    
    ${role_name13}=    FakerLibrary.name 
    ${departments}=  Create List           all

    ${user_scope}=   Create Dictionary   departments=${departments}  

    ${resp}=  Get Default Roles With Capabilities  ${rbac_feature[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${role_id1}    ${resp.json()[0]['roleId']}
    Set Suite Variable  ${role_name1}  ${resp.json()[0]['displayName']}
    Set Suite Variable  ${cap1}  ${resp.json()[3]['capabilityList'][2]}
    Set Suite Variable  ${cap2}  ${resp.json()[5]['capabilityList'][3]}
    Set Suite Variable  ${cap3}  ${resp.json()[5]['capabilityList'][4]}
    Set Suite Variable  ${cap4}  ${resp.json()[2]['capabilityList'][3]}
    Set Suite Variable  ${cap5}  ${resp.json()[1]['capabilityList'][4]}

    ${Capabilities}=    Create List    ${cap1}    ${cap2} 

    ${resp}=  Create Role      ${role_name13}    ${description1}     ${rbac_feature[0]}   ${Capabilities}   scope=${user_scope}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id_13}  ${resp.json()}

    ${resp}=  Get roles by id    ${id_13}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${id_13}
    # Should Be Equal As Strings  ${resp.json()['roleId']}   ${id_13}
    Should Be Equal As Strings  ${resp.json()['roleName']}  ${role_name13}
    Should Be Equal As Strings  ${resp.json()['description']}  ${description1}
    Should Be Equal As Strings  ${resp.json()['status']}  ${toggle[0]}
    Should Be Equal As Strings  ${resp.json()['featureName']}   ${rbac_feature[0]}
    Should Be Equal As Strings  ${resp.json()['scope']['departments']}  ${departments}
    Should Be Equal As Strings  ${resp.json()['capabilityList'][0]}  ${cap1}
    Should Be Equal As Strings  ${resp.json()['capabilityList'][1]}  ${cap2}

JD-TC-CreateRole-15

    [Documentation]  Create  Roles with five capabilities.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description1}=    Fakerlibrary.Sentence    
    ${role_name13}=    FakerLibrary.name 
    ${departments}=  Create List           all

    ${user_scope}=   Create Dictionary   departments=${departments}  

    ${Capabilities}=    Create List    ${cap1}    ${cap2}  ${cap3}   ${cap4}   ${cap5}

    ${resp}=  Create Role      ${role_name13}    ${description1}     ${rbac_feature[0]}   ${Capabilities}   scope=${user_scope}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id_13}  ${resp.json()}

    ${resp}=  Get roles by id    ${id_13}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${id_13}
    # Should Be Equal As Strings  ${resp.json()['roleId']}   ${id_13}
    Should Be Equal As Strings  ${resp.json()['roleName']}  ${role_name13}
    Should Be Equal As Strings  ${resp.json()['description']}  ${description1}
    Should Be Equal As Strings  ${resp.json()['status']}  ${toggle[0]}
    Should Be Equal As Strings  ${resp.json()['featureName']}   ${rbac_feature[0]}
    Should Be Equal As Strings  ${resp.json()['scope']['departments']}  ${departments}
    Should Be Equal As Strings  ${resp.json()['capabilityList'][0]}  ${cap1}
    Should Be Equal As Strings  ${resp.json()['capabilityList'][1]}  ${cap2}
    Should Be Equal As Strings  ${resp.json()['capabilityList'][2]}  ${cap3}
    Should Be Equal As Strings  ${resp.json()['capabilityList'][3]}  ${cap4}
    Should Be Equal As Strings  ${resp.json()['capabilityList'][4]}  ${cap5}


JD-TC-CreateRole-16

    [Documentation]  Add roles to user while create user. 

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${id}=  get_id  ${HLPUSERNAME1}
    Set Suite Variable  ${id}
    ${bs}=  FakerLibrary.bs
    Set Suite Variable  ${bs}
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${lid}=  Create Sample Location
   
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+336645
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
    # ${pin}=  get_pincode
     # Set Suite Variable  ${pin}
     # ${resp}=  Get LocationsByPincode     ${pin}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
     Should Be Equal As Strings    ${resp.status_code}    200 
     Set Suite Variable  ${pin}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Suite Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

    ${whpnum}=  Evaluate  ${PUSERNAME}+346245
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346345

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableRbac']}==${bool[0]}
        ${resp1}=  Enable Disable CDL RBAC  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get roles
    Should Be Equal As Strings            ${resp.status_code}  200
    Set Suite Variable  ${role_id1}       ${resp.json()[0]['id']}
    Set Suite Variable  ${role_name1}     ${resp.json()[0]['roleName']}
    Set Suite Variable  ${capability1}    ${resp.json()[0]['capabilityList']}

    ${role1}=        Create Dictionary     id=${role_id1}    roleId=${role_id1}  roleName=${role_name1}  feature=${rbac_feature[0]}  
    ${user_roles}=   Create List           ${role1}

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[2]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}  ${EMPTY}  ${bool[1]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}    userRoles=${user_roles}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}



JD-TC-CreateRole-UH1

    [Documentation]  Create  Roles with ten capabilities include dublicates.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description1}=    Fakerlibrary.Sentence    
    ${role_name13}=    FakerLibrary.name 
    ${departments}=  Create List           all

    ${user_scope}=   Create Dictionary   departments=${departments}  

    ${Capabilities}=    Create List    ${cap1}    ${cap2}  ${cap3}   ${cap4}   ${cap5}  ${cap1}    ${cap2}  ${cap3}   ${cap4}   ${cap5}

    ${resp}=  Create Role      ${role_name13}    ${description1}     ${rbac_feature[0]}   ${Capabilities}   scope=${user_scope}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id_13}  ${resp.json()}

    ${resp}=  Get roles by id    ${id_13}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-CreateRole-UH2

    [Documentation]  Create  Roles with invalid capabilities.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description1}=    Fakerlibrary.Sentence    
    ${role_name13}=    FakerLibrary.name 
    ${departments}=  Create List           all

    ${user_scope}=   Create Dictionary   departments=${departments}  

    ${Capabilities}=    Create List    10_45

    ${resp}=  Create Role      ${role_name13}    ${description1}     ${rbac_feature[0]}   ${Capabilities}   scope=${user_scope}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-CreateRole-UH3

    [Documentation]  Create  Roles with EMPTY role name.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description1}=    Fakerlibrary.Sentence    
    ${role_name13}=    FakerLibrary.name 
    ${departments}=  Create List           all

    ${user_scope}=   Create Dictionary   departments=${departments}  

    ${Capabilities}=    Create List    ${cap1}

    ${resp}=  Create Role      ${EMPTY}    ${description1}     ${rbac_feature[0]}   ${Capabilities}   scope=${user_scope}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-CreateRole-UH4

    [Documentation]  Create  Roles with EMPTY description.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description1}=    Fakerlibrary.Sentence    
    ${role_name13}=    FakerLibrary.name 
    ${departments}=  Create List           all

    ${user_scope}=   Create Dictionary   departments=${departments}  

    ${Capabilities}=    Create List    ${cap1}

    ${resp}=  Create Role      ${role_name13}    ${EMPTY}     ${rbac_feature[0]}   ${Capabilities}   scope=${user_scope}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-CreateRole-UH5

    [Documentation]  Create  Roles with EMPTY featureName.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description1}=    Fakerlibrary.Sentence    
    ${role_name13}=    FakerLibrary.name 
    ${departments}=  Create List           all

    ${user_scope}=   Create Dictionary   departments=${departments}  

    ${Capabilities}=    Create List    ${cap1}

    ${resp}=  Create Role      ${role_name13}    ${description1}    ${EMPTY}   ${Capabilities}   scope=${user_scope}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-CreateRole-UH6

    [Documentation]   Create Role Using Consumer Login

    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description1}=    Fakerlibrary.Sentence       

    ${resp}=  Create Role       ${role_name1}    ${description1}     ${rbac_feature[0]}     ${emptylist}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-CreateRole-UH7

    [Documentation]   Create Role Using Without Login

    ${description1}=    Fakerlibrary.Sentence       

    ${resp}=  Create Role       ${role_name1}    ${description1}     ${rbac_feature[0]}     ${emptylist}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}