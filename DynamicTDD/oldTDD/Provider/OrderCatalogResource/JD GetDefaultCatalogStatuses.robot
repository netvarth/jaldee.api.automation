*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords     Delete All Sessions
...               AND           Remove File  cookies.txt
Force Tags        ORDER ITEM
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           Process
Library           OperatingSystem
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py



*** Test Cases ***
JD-TC-Get_Default_Catalog_Status-1
    [Documentation]  Provider Get Default Catalog Status
    clear_Item  ${PUSERNAME46}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME46}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Default Catalog Status  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

     


JD-TC-Get_Default_Catalog_Status-UH1
    [Documentation]   Get Default Catalog Status Without login

    ${resp}=  Get Default Catalog Status
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


    
JD-TC-Get_Default_Catalog_Status-UH2
    [Documentation]   Login as consumer and Get Default Catalog Status
    ${resp}=   Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Default Catalog Status 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 



