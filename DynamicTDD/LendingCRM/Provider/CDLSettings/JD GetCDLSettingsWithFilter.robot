*** Settings ***
Suite Teardown    Delete All Sessions 
Test Teardown     Delete All Sessions
Force Tags        LOAN
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
Resource          /ebs/TDD/ProviderPartnerKeywords.robot

*** Variables ***

${autoApprovalUptoAmount}    50000
${autoApprovalUptoAmount2}    70000
${minCreditScoreRequired}            50
${minEquifaxScoreRequired}           690
${minCibilScoreRequired}             690
${minAge}                            23
${maxAge}                            60
${minAmount}                         5000
${maxAmount}                         300000

*** Test Cases ***

JD-TC-Get CDL Settings with Filter-1
                                  
    [Documentation]               Get CDL Settings with filter

    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Create and Update Account level cdl setting    ${bool[1]}    ${autoApprovalUptoAmount2}    ${bool[1]}    ${toggle[0]}    ${bool[1]}   ${bool[1]}    ${bool[1]}  demandPromissoryNoteRequired=${bool[1]}    securityPostDatedChequesRequired=${bool[1]}    loanNature=ConsumerDurableLoan    autoEmiDeductionRequire=${bool[1]}   partnerRequired=${bool[0]}  documentSignatureRequired=${bool[0]}   digitalSignatureRequired=${bool[1]}   emandateRequired=${bool[1]}   creditScoreRequired=${bool[1]}   equifaxScoreRequired=${bool[1]}   cibilScoreRequired=${bool[1]}   minCreditScoreRequired=${minCreditScoreRequired}   minEquifaxScoreRequired=${minEquifaxScoreRequired}   minCibilScoreRequired=${minCibilScoreRequired}   minAge=${minAge}   maxAge=${maxAge}   minAmount=${minAmount}   maxAmount=${maxAmount}   bankStatementVerificationRequired=${bool[1]}   eStamp=DIGIO 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get account level cdl setting
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${id}  ${resp.json()['id']}
    Set Suite Variable  ${partner}  ${resp.json()['partner']}
    Set Suite Variable  ${autoApproval}  ${resp.json()['autoApproval']}
    Set Suite Variable  ${autoApprovalUptoAmount}  ${resp.json()['autoApprovalUptoAmount']}
    Set Suite Variable  ${districtWiseRestriction}  ${resp.json()['districtWiseRestriction']}
    Set Suite Variable  ${salesOfficerVerificationRequired}  ${resp.json()['salesOfficerVerificationRequired']}
    Set Suite Variable  ${status}  ${resp.json()['status']}

    ${resp}=    Get List of CDL Settings by filter
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Get CDL Settings with Filter-2
                                  
    [Documentation]               Get CDL Settings with id filter

    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get List of CDL Settings by filter    id-eq=${id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Get CDL Settings with Filter-3
                                  
    [Documentation]               Get CDL Settings with partner filter

    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get List of CDL Settings by filter    partner-eq=${partner}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Get CDL Settings with Filter-4
                                  
    [Documentation]               Get CDL Settings with autoApproval filter

    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get List of CDL Settings by filter    autoApproval-eq=${autoApproval}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Get CDL Settings with Filter-5
                                  
    [Documentation]               Get CDL Settings with autoApprovalUptoAmount filter

    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get List of CDL Settings by filter    autoApprovalUptoAmount-eq=${autoApprovalUptoAmount}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Get CDL Settings with Filter-6
                                  
    [Documentation]               Get CDL Settings with districtWiseRestriction filter

    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get List of CDL Settings by filter    districtWiseRestriction-eq=${districtWiseRestriction}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Get CDL Settings with Filter-7
                                  
    [Documentation]               Get CDL Settings with status filter

    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get List of CDL Settings by filter    status-eq=${status}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Get CDL Settings with Filter-8
                                  
    [Documentation]               Get CDL Settings with salesOfficerVerificationRequired filter

    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get List of CDL Settings by filter    salesOfficerVerificationRequired-eq=${salesOfficerVerificationRequired}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Get CDL Settings with Filter-UH1
                                  
    [Documentation]               Get CDL Settings without login

    ${resp}=    Get List of CDL Settings by filter
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings     ${resp.json()}    ${SESSION_EXPIRED}

JD-TC-Get CDL Settings with Filter-UH2
                                  
    [Documentation]               Get CDL Settings with consumer login

    ${resp}=  Consumer Login  ${CUSERNAME32}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=    Get List of CDL Settings by filter
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings     ${resp.json()}    ${NoAccess}

JD-TC-Get Count Of CDL Settings with Filter-UH3
                                  
    [Documentation]               Get Count Of CDL Settings where CDL settings are not created

    ${resp}=   Encrypted Provider Login  ${PUSERNAME66}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200 

    ${resp}=    Get List of CDL Settings by filter
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200