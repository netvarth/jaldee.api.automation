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
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Keywords ***
Change Sp Internal Status

    [Arguments]    ${loanApplicationUid}   ${internalStatus}  
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/loanapplication/${loanApplicationUid}/spinternalstatus/${internalStatus}    expected_status=any
    RETURN  ${resp}

Get Loan Application By uid

    [Arguments]    ${loanApplicationUid}   
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/loanapplication/${loanApplicationUid}    expected_status=any
    RETURN  ${resp}

Enable Disable CDL

    [Arguments]    ${status}   
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/account/settings/cdl/${status}    expected_status=any
    RETURN  ${resp}


*** Variables ***

@{emptylist}

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf

${order}    0
${fileSize}  0.00458

${phonez}   7024567616


# ${cc}   +91
# ${phone}     5555512345
# ${aadhaar}   555555555555
# ${pan}       5555523145
# ${bankAccountNo}    5555534564
# ${bankIfsc}         5555566
# ${bankPin}       5555533

# ${bankAccountNo2}    5555534587
# ${bankIfsc2}         55555688
# ${bankPin2}       5555589

# ${invoiceAmount}    60000
# ${downpaymentAmount}    2000
# ${requestedAmount}    58000

# ${invoiceAmount1}    22001
# ${downpaymentAmount1}    2000
# ${requestedAmount1}    20001

# ${monthlyIncome}    80000
# ${emiPaidAmountMonthly}    2000

# @{sp_status}         ConsumerAccepted     PartnerAccepted    Sanctioned

*** Test Cases ***

JD-TC-Enable Disable CDL-1
                                  
    [Documentation]               Enable CDL for a valid provider.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME131}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['enableCdl']}==${bool[0]}   Enable Disable CDL  ${toggle[0]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  enableCdl=${bool[1]}

JD-TC-Enable Disable CDL-2

    [Documentation]   Disable CDL After Enabling

    ${resp}=  Encrypted Provider Login  ${PUSERNAME131}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['enableCdl']}==${bool[0]}   Enable Disable CDL  ${toggle[0]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['enableCdl']}==${bool[1]}   Enable Disable CDL  ${toggle[1]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  enableCdl=${bool[0]}


JD-TC-Enable Disable CDL-3

    [Documentation]   Enable CDL which is Disabled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME131}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['enableCdl']}==${bool[1]}   Enable Disable CDL  ${toggle[1]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['enableCdl']}==${bool[0]}   Enable Disable CDL  ${toggle[0]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  enableCdl=${bool[1]}


JD-TC-Enable Disable CDL-UH1

    [Documentation]   Enable CDL without login

    ${resp}=  Enable Disable CDL  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-Enable Disable CDL-UH2

    [Documentation]   Enable CDL Using Consumer Login

    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable CDL  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-Enable Disable CDL-UH3

    [Documentation]   Enable CDL Which is already enabled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME131}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['enableCdl']}==${bool[0]}   Enable Disable CDL  ${toggle[0]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${CDL_ALREDY_ENABLED}=  format String   ${CDL_ALREDY_ENABLED}   CDL

    ${resp}=  Run Keyword If  ${resp.json()['enableCdl']}==${bool[1]}   Enable Disable CDL  ${toggle[0]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${CDL_ALREDY_ENABLED}
    

JD-TC-Enable Disable CDL-UH4

    [Documentation]   Disable CDL Which is already Disabled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME131}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['enableCdl']}==${bool[1]}   Enable Disable CDL  ${toggle[1]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${CDL_ALREDY_DISABLED}=  format String   ${CDL_ALREDY_DISABLED}   CDL

    ${resp}=  Run Keyword If  ${resp.json()['enableCdl']}==${bool[0]}   Enable Disable CDL  ${toggle[1]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${CDL_ALREDY_DISABLED}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

