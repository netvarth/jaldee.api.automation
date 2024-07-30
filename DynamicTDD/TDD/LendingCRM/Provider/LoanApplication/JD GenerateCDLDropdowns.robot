*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        LOAN
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderPartnerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Test Cases ***

JD-TC-Generate CDL Dropdowns-1
                                  
    [Documentation]               Generate CDL Dropdowns.

    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME5}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=    Generate CDL Dropdowns
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}  200
    Set Test Variable   ${customerEducationName}    ${resp.json()["customerEducation"][0]['name']}
    Set Test Variable   ${customerEducationid}    ${resp.json()["customerEducation"][0]['id']}
    Set Test Variable   ${customerEducationCode}    ${resp.json()["customerEducation"][0]['code']}
    Set Test Variable   ${customerEducationScore}    ${resp.json()["customerEducation"][0]['score']}

    Set Test Variable   ${customerEmployement_id}    ${resp.json()["customerEmployement"][0]['id']}
    Set Test Variable   ${customerEmployement_Name}    ${resp.json()["customerEmployement"][0]['name']}
    Set Test Variable   ${customerEmployement_code}    ${resp.json()["customerEmployement"][0]['code']}
    Set Test Variable   ${customerEmployement_type}    ${resp.json()["customerEmployement"][0]['type']}
    Set Test Variable   ${customerEmployement_score}    ${resp.json()["customerEmployement"][0]['score']}

    Set Test Variable   ${monthlyIncome_id}    ${resp.json()["monthlyIncome"][0]['id']}
    Set Test Variable   ${monthlyIncome_minValue}    ${resp.json()["monthlyIncome"][0]['minValue']}
    Set Test Variable   ${monthlyIncome_maxValue}    ${resp.json()["monthlyIncome"][0]['maxValue']}
    Set Test Variable   ${monthlyIncome_score}    ${resp.json()["monthlyIncome"][0]['score']}

    Set Test Variable   ${existingCustomer_id}    ${resp.json()["existingCustomer"][0]['id']}
    Set Test Variable   ${existingCustomer_Name}    ${resp.json()["existingCustomer"][0]['name']}
    Set Test Variable   ${existingCustomer_code}    ${resp.json()["existingCustomer"][0]['code']}
    Set Test Variable   ${existingCustomer_score}    ${resp.json()["existingCustomer"][0]['score']}

    Set Test Variable   ${salaryRouting_id}    ${resp.json()["salaryRouting"][0]['id']}
    Set Test Variable   ${salaryRouting_Name}    ${resp.json()["salaryRouting"][0]['name']}
    Set Test Variable   ${salaryRouting_code}    ${resp.json()["salaryRouting"][0]['code']}
    Set Test Variable   ${salaryRouting_score}    ${resp.json()["salaryRouting"][0]['score']}

    Set Test Variable   ${familyDependants_id}    ${resp.json()["familyDependants"][0]['id']}
    Set Test Variable   ${familyDependants_Name}    ${resp.json()["familyDependants"][0]['name']}
    Set Test Variable   ${familyDependants_code}    ${resp.json()["familyDependants"][0]['code']}
    Set Test Variable   ${familyDependants_score}    ${resp.json()["familyDependants"][0]['score']}

    Set Test Variable   ${noOfYearsAtPresentAddress_id}    ${resp.json()["noOfYearsAtPresentAddress"][0]['id']}
    Set Test Variable   ${noOfYearsAtPresentAddress_Name}    ${resp.json()["noOfYearsAtPresentAddress"][0]['name']}
    Set Test Variable   ${noOfYearsAtPresentAddress_code}    ${resp.json()["noOfYearsAtPresentAddress"][0]['code']}
    Set Test Variable   ${noOfYearsAtPresentAddress_score}    ${resp.json()["noOfYearsAtPresentAddress"][0]['score']}

    Set Test Variable   ${currentResidenceOwnershipStatus_id}    ${resp.json()["currentResidenceOwnershipStatus"][0]['id']}
    Set Test Variable   ${currentResidenceOwnershipStatus_Name}    ${resp.json()["currentResidenceOwnershipStatus"][0]['name']}
    Set Test Variable   ${currentResidenceOwnershipStatus_code}    ${resp.json()["currentResidenceOwnershipStatus"][0]['code']}
    Set Test Variable   ${currentResidenceOwnershipStatus_score}    ${resp.json()["currentResidenceOwnershipStatus"][0]['score']}

    Set Test Variable   ${ownedMovableAssets_id}    ${resp.json()["ownedMovableAssets"][0]['id']}
    Set Test Variable   ${ownedMovableAssets_Name}    ${resp.json()["ownedMovableAssets"][0]['name']}
    Set Test Variable   ${ownedMovableAssets_code}    ${resp.json()["ownedMovableAssets"][0]['code']}
    Set Test Variable   ${ownedMovableAssets_score}    ${resp.json()["ownedMovableAssets"][0]['score']}

    Set Test Variable   ${earningMembers_id}    ${resp.json()["earningMembers"][0]['id']}
    Set Test Variable   ${earningMembers_Name}    ${resp.json()["earningMembers"][0]['name']}
    Set Test Variable   ${earningMembers_code}    ${resp.json()["earningMembers"][0]['code']}
    Set Test Variable   ${earningMembers_score}    ${resp.json()["earningMembers"][0]['score']}

    Set Test Variable   ${goodsFinanced_id}    ${resp.json()["goodsFinanced"][0]['id']}
    Set Test Variable   ${goodsFinanced_Name}    ${resp.json()["goodsFinanced"][0]['name']}
    Set Test Variable   ${goodsFinanced_code}    ${resp.json()["goodsFinanced"][0]['code']}
    Set Test Variable   ${goodsFinanced_score}    ${resp.json()["goodsFinanced"][0]['score']}
    
JD-TC-Generate CDL Dropdowns-UH1
                                  
    [Documentation]               Generate CDL Dropdowns with consumer login.

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=    Generate CDL Dropdowns
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}  401  
    Should Be Equal As Strings   ${resp.json()}  ${NoAccess}

JD-TC-Generate CDL Dropdowns-UH2
                                  
    [Documentation]               Generate CDL Dropdowns without login.

    ${resp}=    Generate CDL Dropdowns
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}  ${SESSION_EXPIRED}