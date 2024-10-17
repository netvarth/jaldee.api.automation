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
Library         /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/SuperAdminKeywords.robot 

*** Test Cases ***

JD-TC-GetStoreTypeByFilter-1

    [Documentation]  Super Admin Create a Store Type (storeNature is PHARMACY)and provide Get Store Type Filter(encId).

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${TypeName}=    FakerLibrary.name
    Set Suite Variable  ${TypeName}

    ${resp}=  Create Store Type   ${TypeName}    ${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id}    ${resp.json()}

    ${resp}=  Get Store Type Filter   encId-eq=${St_Id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['name']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()[0]['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${St_Id}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Store Type By Filter   encId-eq=${St_Id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['name']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()[0]['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${St_Id}

JD-TC-GetStoreTypeByFilter-2

    [Documentation]  Super Admin Create a Store Type (storeNature is LAB)and Get Store Type Filter(storeNature-LAB).

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${TypeName1}=    FakerLibrary.name
    Set Suite Variable  ${TypeName1}

    ${resp}=  Create Store Type   ${TypeName1}    ${storeNature[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id1}    ${resp.json()}

    ${resp}=  Get Store Type Filter   storeNature-eq=${storeNature[1]}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['name']}    ${TypeName1}
    Should Be Equal As Strings    ${resp.json()[0]['storeNature']}    ${storeNature[1]}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${St_Id1}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Store Type By Filter  storeNature-eq=${storeNature[1]}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['name']}    ${TypeName1}
    Should Be Equal As Strings    ${resp.json()[0]['storeNature']}    ${storeNature[1]}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${St_Id1}

JD-TC-GetStoreTypeByFilter-3

    [Documentation]  Super Admin Create a Store Type (storeNature is LAB)and Get Store Type Filter(storeNature-PHARMACY).

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Store Type Filter   storeNature-eq=${storeNature[0]}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['name']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()[0]['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${St_Id}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Store Type By Filter   storeNature-eq=${storeNature[0]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['name']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()[0]['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${St_Id}

JD-TC-GetStoreTypeByFilter-4

    [Documentation]  Super Admin Create a Store Type (storeNature is RADIOLOGY)and Get Store Type Filter(storeNature-RADIOLOGY).

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${TypeName2}=    FakerLibrary.name
    Set Suite Variable  ${TypeName2}

    ${resp}=  Create Store Type   ${TypeName2}    ${storeNature[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id2}    ${resp.json()}

    ${resp}=  Get Store Type Filter   storeNature-eq=${storeNature[2]}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['name']}    ${TypeName2}
    Should Be Equal As Strings    ${resp.json()[0]['storeNature']}    ${storeNature[2]}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${St_Id2}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Store Type By Filter   storeNature-eq=${storeNature[2]}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['name']}    ${TypeName2}
    Should Be Equal As Strings    ${resp.json()[0]['storeNature']}    ${storeNature[2]}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${St_Id2}

JD-TC-GetStoreTypeByFilter-5

    [Documentation]   Get Store Type Filter(name).

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Store Type Filter   name-eq=${TypeName2}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['name']}    ${TypeName2}
    Should Be Equal As Strings    ${resp.json()[0]['storeNature']}    ${storeNature[2]}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${St_Id2}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Store Type By Filter  name-eq=${TypeName2}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['name']}    ${TypeName2}
    Should Be Equal As Strings    ${resp.json()[0]['storeNature']}    ${storeNature[2]}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${St_Id2}

JD-TC-GetStoreTypeByFilter-6

    [Documentation]   Update store type storenature to PHARMACY and Get Store Type Filter(storeNature).

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Store Type     ${St_Id2}   ${TypeName2}    ${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Store Type Filter   name-eq=${TypeName2}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['name']}    ${TypeName2}
    Should Be Equal As Strings    ${resp.json()[0]['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${St_Id2}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Store Type By Filter   name-eq=${TypeName2}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['name']}    ${TypeName2}
    Should Be Equal As Strings    ${resp.json()[0]['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${St_Id2}
