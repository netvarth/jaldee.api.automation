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
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

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

    ${resp}=    Create Scheme    ${account}    ${schemeName}    ${schemeAliasName}    ${CrmSchemeType[1]}    ${schemeRate}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${description}
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

JD-TC-Update Scheme-UH1
                                  
    [Documentation]               Update Scheme where Scheme id is empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Update Scheme    ${empty}    ${account}    ${schemeName2}    ${schemeAliasName2}    ${CrmSchemeType[3]}    ${schemeRate2}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    500

JD-TC-Update Scheme-UH2
                                  
    [Documentation]               Update Scheme where account id is empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Update Scheme    ${Schemeid}    ${empty}    ${schemeName2}    ${schemeAliasName2}    ${CrmSchemeType[3]}    ${schemeRate2}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${ACCOUNT_ID_REQUIRED}

JD-TC-Update Scheme-UH3
                                  
    [Documentation]               Update Scheme where scheme name is empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Update Scheme    ${Schemeid}    ${account}    ${empty}    ${schemeAliasName2}    ${CrmSchemeType[3]}    ${schemeRate2}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${SCHEME_NAME_REQUIRED}

JD-TC-Update Scheme-UH4
                                  
    [Documentation]               Update Scheme where scheme alias name is empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Update Scheme    ${Schemeid}    ${account}    ${schemeName2}    ${empty}    ${CrmSchemeType[3]}    ${schemeRate2}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-Update Scheme-UH5
                                  
    [Documentation]               Update Scheme where crm scheme type is empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Update Scheme    ${Schemeid}    ${account}    ${schemeName2}    ${schemeAliasName2}    ${empty}    ${schemeRate2}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    500

JD-TC-Update Scheme-UH6
                                  
    [Documentation]               Update Scheme where scheme rate is empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Update Scheme    ${Schemeid}    ${account}    ${schemeName2}    ${schemeAliasName2}    ${CrmSchemeType[3]}    ${empty}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${SCHEME_RATE_REQUIRED}

JD-TC-Update Scheme-UH7
                                  
    [Documentation]               Update Scheme where number of Repayment is empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Update Scheme    ${Schemeid}    ${account}    ${schemeName2}    ${schemeAliasName2}    ${CrmSchemeType[3]}    ${schemeRate2}    ${empty}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-Update Scheme-UH8
                                  
    [Documentation]               Update Scheme where number of advance payment is empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Update Scheme    ${Schemeid}    ${account}    ${schemeName2}    ${schemeAliasName2}    ${CrmSchemeType[3]}    ${schemeRate2}    ${noOfRepayment}    ${empty}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-Update Scheme-UH9
                                  
    [Documentation]               Update Scheme where number of advance suggested is empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Update Scheme    ${Schemeid}    ${account}    ${schemeName2}    ${schemeAliasName2}    ${CrmSchemeType[3]}    ${schemeRate2}    ${noOfRepayment}    ${noOfAdvancePayment}    ${empty}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-Update Scheme-UH10
                                  
    [Documentation]               Update Scheme where service charge is empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Update Scheme    ${Schemeid}    ${account}    ${schemeName2}    ${schemeAliasName2}    ${CrmSchemeType[3]}    ${schemeRate2}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${empty}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-Update Scheme-UH11
                                  
    [Documentation]               Update Scheme where insurence charge is empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Update Scheme    ${Schemeid}    ${account}    ${schemeName2}    ${schemeAliasName2}    ${CrmSchemeType[3]}    ${schemeRate2}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${empty}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-Update Scheme-UH12
                                  
    [Documentation]               Update Scheme where minimum amount is empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Update Scheme    ${Schemeid}    ${account}    ${schemeName2}    ${schemeAliasName2}    ${CrmSchemeType[3]}    ${schemeRate2}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${empty}    ${maxAmount}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-Update Scheme-UH13
                                  
    [Documentation]               Update Scheme where max amount empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Update Scheme    ${Schemeid}    ${account}    ${schemeName2}    ${schemeAliasName2}    ${CrmSchemeType[3]}    ${schemeRate2}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${empty}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-Update Scheme-UH14
                                  
    [Documentation]               Update Scheme where statue is disabled
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Update Scheme    ${Schemeid}    ${account}    ${schemeName2}    ${schemeAliasName2}    ${CrmSchemeType[3]}    ${schemeRate2}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[1]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-Update Scheme-UH15
                                  
    [Documentation]               Update Scheme where discription is empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Update Scheme    ${Schemeid}    ${account}    ${schemeName2}    ${schemeAliasName2}    ${CrmSchemeType[3]}    ${schemeRate2}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-Update Scheme-UH16
                                  
    [Documentation]               Update Scheme without provider login

    ${resp}=    Update Scheme    ${Schemeid}    ${account}    ${schemeName2}    ${schemeAliasName2}    ${CrmSchemeType[3]}    ${schemeRate2}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Update Scheme-UH17
                                  
    [Documentation]               Update Scheme without creating scheme

    ${resp}=  Consumer Login  ${CUSERNAME27}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME90}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account}  ${resp.json()['id']}

    ${resp}=    Get Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Update Scheme    ${Schemeid}    ${account}    ${schemeName}    ${schemeAliasName}    ${CrmSchemeType[3]}    ${schemeRate}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200