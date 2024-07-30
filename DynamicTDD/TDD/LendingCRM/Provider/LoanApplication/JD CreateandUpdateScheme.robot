*** Settings ***
Suite Teardown    Delete All Sessions 
Test Teardown     Delete All Sessions
Force Tags        LOAN
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
Resource          /ebs/TDD/Keywords.robot

*** Variables ***

@{emptylist}
${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf
${order}    0
${fileSize}  0.00458

${minCreditScoreRequired}            50
${minEquifaxScoreRequired}           690
${minCibilScoreRequired}             690
${minAge}                            23
${maxAge}                            60
${minAmount}                         5000
${maxAmount}                         300000
${minDuration}              3
${maxDuration}              12
${loanToValue}              80
${subventionRate}           0
${bureauScores}             0
${processingFeeRate}        3
${processingFeeAmount}      10000
${overdueChargeRate}        3
${foreClosureCharge}        3
${foirOnDeclaredIncome}     55
${foirOnAssesedIncome}      45
${noOfCoApplicatRequired}   0
${noOfSpdcRequired}         1
${noOfPdcRequired}          1

*** Test Cases ***

JD-TC-Update Scheme-1
                                  
    [Documentation]               Update Scheme

    ${resp}=  Consumer Login  ${CUSERNAME22}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account}  ${resp.json()['id']}

    ${schemeName}=    FakerLibrary.name
    ${schemeAliasName}=    FakerLibrary.name
    ${schemeRate}=    FakerLibrary.Random Number
    ${noOfRepayment}=    FakerLibrary.Random Number
    ${noOfAdvancePayment}=    FakerLibrary.Random Number
    ${noOfAdvanceSuggested}=    FakerLibrary.Random Number
    ${serviceCharge}=    FakerLibrary.Random Number
    ${insuranceCharge}=    FakerLibrary.Random Number
    ${minAmount}=    FakerLibrary.Random Number
    ${maxAmount}=    FakerLibrary.Random Number
    ${description}=    FakerLibrary.sentence
    ${integrationId}=   FakerLibrary.Random Number
    Set Suite Variable    ${schemeName}
    Set Suite Variable    ${schemeAliasName}
    Set Suite Variable    ${schemeRate}
    Set Suite Variable    ${noOfRepayment}
    Set Suite Variable    ${noOfAdvancePayment}
    Set Suite Variable    ${noOfAdvanceSuggested}
    Set Suite Variable    ${serviceCharge}
    Set Suite Variable    ${insuranceCharge}
    Set Suite Variable    ${minAmount}
    Set Suite Variable    ${maxAmount}
    Set Suite Variable    ${description}

    ${resp}=    Create Scheme  ${account}  ${schemeName}  ${schemeAliasName}  ${integrationId}  ${CrmSchemeType[1]}  ${RateType[0]}  ${schemeRate}  ${schemeRate}  ${noOfAdvancePayment}  ${noOfAdvanceSuggested}  ${minDuration}  ${maxDuration}  ${minAmount}  ${maxAmount}  ${minAge}  ${maxAge}  ${loanToValue}  ${boolean[0]}  ${boolean[0]}  ${subventionRate}  ${bureauScores}  ${processingFeeRate}  ${processingFeeAmount}  ${overdueChargeRate}  ${foreClosureCharge}  ${foirOnDeclaredIncome}  ${foirOnAssesedIncome}  ${noOfCoApplicatRequired}  ${noOfSpdcRequired}  ${noOfPdcRequired}  ${boolean[1]}  ${boolean[0]}  ${toggle[0]} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Schemeid}  ${resp.json()[0]['id']}

    ${schemeName2}=    FakerLibrary.name
    ${schemeAliasName2}=    FakerLibrary.name
    ${schemeRate2}=    FakerLibrary.Random Number
    Set Suite Variable    ${schemeName2}
    Set Suite Variable    ${schemeAliasName2}
    Set Suite Variable    ${schemeRate2}

    ${resp}=    Update Scheme    ${Schemeid}    ${account}    ${schemeName2}    ${schemeAliasName2}    ${CrmSchemeType[3]}    ${schemeRate2}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

