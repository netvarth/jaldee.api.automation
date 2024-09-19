*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        STORE 
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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/SuperAdminKeywords.robot 

*** Variables ***

@{store-names}  OTHERS  Bakery  Warehouse  Medical Lab
${TypeName}  Pharmacy

*** Test Cases ***

JD-TC-UpdateStoreType-1
    [Documentation]   Update store type name from 'Retail Store' to PHARMACY

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Store Type Filter
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

    FOR  ${i}  IN RANGE   ${len}
        
        IF  '${resp.json()[${i}]['name']}' == 'Retail Store'
            Log  ${i}${SPACE}${SPACE}${SPACE}${SPACE}${resp.json()[${i}]['name']}
            ${resp1}=  Update Store Type  ${resp.json()[${i}]['encId']}   ${TypeName}  ${resp.json()[${i}]['storeNature']}
            Log   ${resp1.content}
            Should Be Equal As Strings    ${resp1.status_code}    200

        ELSE IF  '${resp.json()[${i}]['name']}' != '${TypeName}${i+1}' and '${resp.json()[${i}]['name']}' not in @{store-names} 
            Log  ${i}${SPACE}${SPACE}${SPACE}${SPACE}${resp.json()[${i}]['name']}
            ${resp1}=  Update Store Type  ${resp.json()[${i}]['encId']}   ${TypeName}${i+1}    ${resp.json()[${i}]['storeNature']}
            Log   ${resp1.content}
            Should Be Equal As Strings    ${resp1.status_code}    200
        END
    END

    ${resp}=  Get Store Type Filter
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    