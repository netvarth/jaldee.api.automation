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

@{emptylist}

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf

${order}    0
${fileSize}  0.00458

${cc}   +91
${phone}     5555512345
${aadhaar}   555555555555
${pan}       5555523145
${bankAccountNo}    5555534564
${bankIfsc}         5555566
${bankPin}       5555533

${bankAccountNo2}    5555534587
${bankIfsc2}         55555688
${bankPin2}       5555589

${invoiceAmount}    100000
${downpaymentAmount}    20000
${requestedAmount}    80000

*** Test Cases ***

JD-TC-GetPartnerProduct-1
                                  
    [Documentation]              Get Partner Product

    ${resp}=  Consumer Login  ${CUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${place}  ${resp.json()[0]['place']}
    END

    ${PO_Number}=  Generate Random Phone Number
    ${phone}=  Convert To Integer    ${PO_Number}
        ${resp}=  GetCustomer  phoneNo-eq=${phone}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${phone}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid14}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${phone}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${custid}    ${resp.json()[0]['id']}
    Set Suite Variable   ${firstName}    ${resp.json()[0]['firstName']}
    Set Suite Variable   ${lastName}    ${resp.json()[0]['lastName']}
    Set Suite Variable   ${phoneNo}    ${resp.json()[0]['phoneNo']}
    Set Suite Variable    ${email}  ${fname}${C_Email}.ynwtest@netvarth.com

    ${resp}=  partnercategorytype   ${account_id}
    ${resp}=  partnertype       ${account_id}

    ${resp}=  Generate Phone Partner Creation    ${phone}    ${cc}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=  Verify Phone Partner Creation    ${phone}    14    ${firstName}   ${lastName}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${id}  ${resp.json()['id']}
    Set Suite Variable  ${partuid}  ${resp.json()['uid']} 

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=   Partner Approval Request    ${partuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${note}=    FakerLibrary.sentence
    Set Suite Variable    ${note}

    ${resp}=   Partner Approved    ${partuid}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=    Identify Partner    ${phone}    ${account_id}    ${id}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=    Verify Otp For Login Partner    ${phone}  12
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=  Partner Logout 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=  Partner Login    ${phone}    ${account_id}    ${token}   
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    # Should Be Equal As Strings     ${resp.json()['id']}   ${id1} 
    Should Be Equal As Strings     ${resp.json()['primaryPhoneNumber']}   ${phone}

    ${resp}=  categorytype   ${account_id}
    ${resp}=  tasktype       ${account_id}
    ${resp}=  loanStatus     ${account_id}
    ${resp}=  loanProduct    ${account_id}
    ${resp}=  loanScheme     ${account_id}

    ${resp}=    Get Partner Loan Application Category
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${categoryid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${categoryname}  ${resp.json()[0]['name']}

    ${resp}=   Get Partner Loan Application Type
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${typeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${typename}  ${resp.json()[0]['name']}

    ${resp}=    Get Partner Loan Application Status
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${statusid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${statusname}  ${resp.json()[0]['name']}

    ${resp}=    Get Partner Loan Application Product
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Productid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${productname}  ${resp.json()[0]['productName']}


JD-TC-GetPartnerProduct-UH1
                                  
    [Documentation]               Get Partner Product with consumer login.
    
    ${resp}=   Consumer Login  ${CUSERNAME14}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Partner Loan Application Product
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    400
    Should Be Equal As Strings    ${resp.json()}   ${LOGIN_INVALID_URL}

JD-TC-GetPartnerProduct-UH2
                                  
    [Documentation]               Get Partner Product without login.

    ${resp}=     Get Partner Loan Application Product
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-GetPartnerProduct-UH3
                                  
    [Documentation]               Get Partner Product with  provider login login.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}


    ${resp}=     Get Partner Loan Application Product
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    400
    Should Be Equal As Strings    ${resp.json()}   ${LOGIN_INVALID_URL}

