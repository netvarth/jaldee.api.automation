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

*** Test Cases ***

JD-TC-GetStoreTypeFilterCount-1
    [Documentation]  Super Admin Create a Store Type (storeNature is PHARMACY)and Get Store Type Filter Count(encId).

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


    ${len}=     Get Length  ${resp.json()}

    ${resp}=  Get Store Type Filter Count   encId-eq=${St_Id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}     ${len}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Store Type By Filter Count   encId-eq=${St_Id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}     ${len}

JD-TC-GetStoreTypeFilterCount-2
    [Documentation]  Super Admin Create a Store Type (storeNature is LAB)and Get Store Type Filter Count(storeNature-LAB).

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
    # Should Be Equal As Strings    ${resp.json()[0]['name']}    ${TypeName1}
    # Should Be Equal As Strings    ${resp.json()[0]['storeNature']}    ${storeNature[1]}
    # Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${St_Id1}

    ${len}=     Get Length  ${resp.json()}

    ${resp}=  Get Store Type Filter Count   storeNature-eq=${storeNature[1]}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}     ${len}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Store Type By Filter Count   storeNature-eq=${storeNature[1]}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}     ${len}

JD-TC-GetStoreTypeFilterCount-3
    [Documentation]  Super Admin Create a Store Type (storeNature is LAB)and Get Store Type Filter Count(storeNature-PHARMACY).

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Store Type Filter   storeNature-eq=${storeNature[0]}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.json()[0]['name']}    ${TypeName}
    # Should Be Equal As Strings    ${resp.json()[0]['storeNature']}    ${storeNature[0]}
    # Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${St_Id}

    ${len}=     Get Length  ${resp.json()}

    ${resp}=  Get Store Type Filter Count   storeNature-eq=${storeNature[0]}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}     ${len}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Store Type By Filter Count   storeNature-eq=${storeNature[0]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}     ${len}

JD-TC-GetStoreTypeFilterCount-4
    [Documentation]  Super Admin Create a Store Type (storeNature is RADIOLOGY)and Get Store Type Filter Count(storeNature-RADIOLOGY).

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
    # Should Be Equal As Strings    ${resp.json()[0]['name']}    ${TypeName2}
    # Should Be Equal As Strings    ${resp.json()[0]['storeNature']}    ${storeNature[2]}
    # Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${St_Id2}

    ${len}=     Get Length  ${resp.json()}

    ${resp}=  Get Store Type Filter Count   storeNature-eq=${storeNature[2]}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}     ${len}
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Store Type By Filter Count   storeNature-eq=${storeNature[2]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}     ${len}

JD-TC-GetStoreTypeFilterCount-5
    [Documentation]   Get Store Type Filter Count(name).

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Store Type Filter   name-eq=${TypeName2}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.json()[0]['name']}    ${TypeName2}
    # Should Be Equal As Strings    ${resp.json()[0]['storeNature']}    ${storeNature[2]}
    # Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${St_Id2}

    ${len}=     Get Length  ${resp.json()}

    ${resp}=  Get Store Type Filter Count   name-eq=${TypeName2}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}     ${len}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Store Type By Filter Count   name-eq=${TypeName2}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}     ${len}

JD-TC-GetStoreTypeFilterCount-6
    [Documentation]   Update store type storenature to PHARMACY and Get Store Type Filter Count(storeNature).

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Store Type     ${St_Id2}   ${TypeName2}    ${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Store Type Filter   name-eq=${TypeName2}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.json()[0]['name']}    ${TypeName2}
    # Should Be Equal As Strings    ${resp.json()[0]['storeNature']}    ${storeNature[0]}
    # Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${St_Id2}

    ${len}=     Get Length  ${resp.json()}

    ${resp}=  Get Store Type Filter Count   name-eq=${TypeName2}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}     ${len}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Store Type By Filter Count   name-eq=${TypeName2}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}     ${len}