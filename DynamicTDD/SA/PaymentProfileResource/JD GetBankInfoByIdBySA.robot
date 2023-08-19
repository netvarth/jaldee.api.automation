*** Settings ***
Test Teardown     Delete All Sessions
Force Tags        Bank Details
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***

${digits}       0123456789
${service_duration}   2
${parallel}           1
${self}               0
@{provider_list}
${start}              140
${jcoupon1}   CouponMul00
${tz}   Asia/Kolkata




*** Test Cases ***

JD-TC-GetBankInfoById-1

    [Documentation]  Get my own bank details by superadmin.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable  ${pid}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
   
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    Set Suite Variable  ${pan_num}
    Set Suite Variable  ${GST_num}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${ifsc_code}=   db.Generate_ifsc_code
    Set Suite Variable  ${ifsc_code}
    ${bank_ac}=   db.Generate_random_value  size=11   chars=${digits} 
    Set Suite Variable  ${bank_ac}
    ${bank_name}=  FakerLibrary.company
    Set Suite Variable  ${bank_name}
    ${name}=  FakerLibrary.name
    Set Suite Variable  ${name}
    ${branch}=   db.get_place
    Set Suite Variable  ${branch}

    ${resp}=   Create Bank Info   ${pid}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME151}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${bank_id1}  ${resp.json()}

    ${resp}=   Get Bank Info By Id   ${bank_id1}  ${pid}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()['accountId']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()['bankId']}                    ${bank_id1}
    Should Be Equal As Strings  ${resp.json()['payTmLinkedPhoneNumber']}    ${PUSERNAME151}
    Should Be Equal As Strings  ${resp.json()['panCardNumber']}             ${pan_num}
    Should Be Equal As Strings  ${resp.json()['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()['payTmVerified']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()['accountType']}               ${accountType[1]}


JD-TC-GetBankInfoById-2

    [Documentation]  Get multiple bank details by superadmin. 

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${GST_num1}  ${pan_num1}=   db.Generate_gst_number   ${Container_id}
    Set Suite Variable  ${pan_num1}
    Set Suite Variable  ${GST_num1}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num1} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${ifsc_code1}=   db.Generate_ifsc_code
    Set Suite Variable  ${ifsc_code1}
    ${bank_ac1}=   db.Generate_random_value  size=11   chars=${digits} 
    Set Suite Variable  ${bank_ac1}
    ${bank_name1}=  FakerLibrary.company
    Set Suite Variable  ${bank_name1}
    ${name1}=  FakerLibrary.name
    Set Suite Variable  ${name1}
    ${branch1}=   db.get_place
    Set Suite Variable  ${branch1}

    ${resp}=   Create Bank Info   ${pid}  ${bank_name1}  ${bank_ac1}  ${ifsc_code1}  ${name1}  ${name1}  ${branch1}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num1}  ${PUSERNAME151}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${bank_id2}  ${resp.json()}
    
    ${resp}=   Get Bank Info By Id   ${bank_id1}  ${pid}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()['accountId']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()['bankId']}                    ${bank_id1}
    Should Be Equal As Strings  ${resp.json()['payTmLinkedPhoneNumber']}    ${PUSERNAME151}
    Should Be Equal As Strings  ${resp.json()['panCardNumber']}             ${pan_num}
    Should Be Equal As Strings  ${resp.json()['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()['payTmVerified']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()['accountType']}               ${accountType[1]}

    ${resp}=   Get Bank Info By Id   ${bank_id2}  ${pid}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()['accountId']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()['bankId']}                    ${bank_id2}
    Should Be Equal As Strings  ${resp.json()['payTmLinkedPhoneNumber']}    ${PUSERNAME151}
    Should Be Equal As Strings  ${resp.json()['panCardNumber']}             ${pan_num1}
    Should Be Equal As Strings  ${resp.json()['bankAccountNumber']}         ${bank_ac1}
    Should Be Equal As Strings  ${resp.json()['payTmVerified']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['branchCity']}                ${branch1}
    Should Be Equal As Strings  ${resp.json()['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()['accountType']}               ${accountType[1]}


JD-TC-CreateBankInfo-UH1

    [Documentation]  Get bank details By id by consumer login.
    
    ${resp}=   ConsumerLogin  ${CUSERNAME2}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Bank Info By Id   ${bank_id2}  ${pid}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  ${resp.json()}   ${SA_SESSION_EXPIRED}


JD-TC-CreateBankInfo-UH2

    [Documentation]  get bank details by id by provider login.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Bank Info By Id   ${bank_id2}  ${pid}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  ${resp.json()}   ${SA_SESSION_EXPIRED}


JD-TC-CreateBankInfo-UH3

    [Documentation]  Get my own bank details by id without login.

    ${resp}=   Get Bank Info By Id   ${bank_id2}  ${pid}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  ${resp.json()}   ${SA_SESSION_EXPIRED}


JD-TC-CreateBankInfo-UH4

    [Documentation]  get bank details by id with invalid account id.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Bank Info By Id   ${bank_id2}  0000
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${ACCOUNT_NOT_EXIST}

JD-TC-CreateBankInfo-UH5

    [Documentation]  get bank details by id with invalid bank id.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Bank Info By Id   0000  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${NO_BANK_DETAILS_FOUND}

