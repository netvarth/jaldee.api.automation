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

JD-TC-Create Scheme-1
                                  
    [Documentation]               Create Scheme

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
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

*** Comments ***

    ${resp}=    Create Scheme    ${account}    ${schemeName}    ${schemeAliasName}    ${CrmSchemeType[1]}    ${schemeRate}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Schemeid}  ${resp.json()[0]['id']}

JD-TC-Create Scheme-UH1
                                  
    [Documentation]               Create Scheme where account is empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Create Scheme    ${empty}    ${schemeName}    ${schemeAliasName}    ${CrmSchemeType[1]}    ${schemeRate}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${ACCOUNT_ID_REQUIRED}

JD-TC-Create Scheme-UH2
                                  
    [Documentation]               Create Scheme where Scheme name is empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Create Scheme    ${account}    ${empty}    ${schemeAliasName}    ${CrmSchemeType[1]}    ${schemeRate}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${SCHEME_NAME_REQUIRED}

JD-TC-Create Scheme-UH3
                                  
    [Documentation]               Create Scheme where scheme Alias Name is empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Create Scheme    ${account}    ${schemeName}    ${empty}    ${CrmSchemeType[1]}    ${schemeRate}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-Create Scheme-UH4
                                  
    [Documentation]               Create Scheme where scheme type is empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Create Scheme    ${account}    ${schemeName}    ${schemeAliasName}    ${empty}    ${schemeRate}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    500

JD-TC-Create Scheme-UH5
                                  
    [Documentation]               Create Scheme where scheme rate is empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Create Scheme    ${account}    ${schemeName}    ${schemeAliasName}    ${CrmSchemeType[1]}    ${empty}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${SCHEME_RATE_REQUIRED}

JD-TC-Create Scheme-UH6
                                  
    [Documentation]               Create Scheme where number of repayment is empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Create Scheme    ${account}    ${schemeName}    ${schemeAliasName}    ${CrmSchemeType[1]}    ${schemeRate}    ${empty}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-Create Scheme-UH7
                                  
    [Documentation]               Create Scheme where number of advance payment is empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Create Scheme    ${account}    ${schemeName}    ${schemeAliasName}    ${CrmSchemeType[1]}    ${schemeRate}    ${noOfRepayment}    ${empty}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-Create Scheme-UH8
                                  
    [Documentation]               Create Scheme where number of advance suggested is empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Create Scheme    ${account}    ${schemeName}    ${schemeAliasName}    ${CrmSchemeType[1]}    ${schemeRate}    ${noOfRepayment}    ${noOfAdvancePayment}    ${empty}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-Create Scheme-UH9
                                  
    [Documentation]               Create Scheme where service charge is empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Create Scheme    ${account}    ${schemeName}    ${schemeAliasName}    ${CrmSchemeType[1]}    ${schemeRate}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${empty}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-Create Scheme-UH10
                                  
    [Documentation]               Create Scheme where insurance Charge is empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Create Scheme    ${account}    ${schemeName}    ${schemeAliasName}    ${CrmSchemeType[1]}    ${schemeRate}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${empty}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-Create Scheme-UH11
                                  
    [Documentation]               Create Scheme where min amount is empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Create Scheme    ${account}    ${schemeName}    ${schemeAliasName}    ${CrmSchemeType[1]}    ${schemeRate}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${empty}    ${maxAmount}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-Create Scheme-UH12
                                  
    [Documentation]               Create Scheme where max amount is empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Create Scheme    ${account}    ${schemeName}    ${schemeAliasName}    ${CrmSchemeType[1]}    ${schemeRate}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${empty}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-Create Scheme-UH13
                                  
    [Documentation]               Create Scheme where status is empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Create Scheme    ${account}    ${schemeName}    ${schemeAliasName}    ${CrmSchemeType[1]}    ${schemeRate}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${status}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    500

JD-TC-Create Scheme-UH14
                                  
    [Documentation]               Create Scheme where description is empty
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Create Scheme    ${account}    ${schemeName}    ${schemeAliasName}    ${CrmSchemeType[1]}    ${schemeRate}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-Create Scheme-UH15
                                  
    [Documentation]               Create Scheme without login

    ${resp}=    Create Scheme    ${account}    ${schemeName}    ${schemeAliasName}    ${CrmSchemeType[1]}    ${schemeRate}    ${noOfRepayment}    ${noOfAdvancePayment}    ${noOfAdvanceSuggested}    ${serviceCharge}    ${insuranceCharge}    ${minAmount}    ${maxAmount}    ${toggle[0]}    ${description}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}