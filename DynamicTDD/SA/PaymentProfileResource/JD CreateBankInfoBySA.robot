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

JD-TC-CreateBankInfo-1

    [Documentation]  Create my own bank details for a provider by superadmin.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME150}
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

    ${resp}=   Create Bank Info   ${pid}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME150}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${bank_id1}  ${resp.json()}

    ${resp}=   Get Bank Info By Id   ${bank_id1}  ${pid}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()['accountId']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()['bankId']}                    ${bank_id1}
    Should Be Equal As Strings  ${resp.json()['payTmLinkedPhoneNumber']}    ${PUSERNAME150}
    Should Be Equal As Strings  ${resp.json()['panCardNumber']}             ${pan_num}
    Should Be Equal As Strings  ${resp.json()['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()['payTmVerified']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()['accountType']}               ${accountType[1]}

JD-TC-CreateBankInfo-2

    [Documentation]  Create my own bank details for a provider by superadmin then do the payu verification.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Bank Details
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  payTmVerify  ${pid}
    Log  ${resp}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Bank Info By Id   ${bank_id1}  ${pid}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()['accountId']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()['bankId']}                    ${bank_id1}
    Should Be Equal As Strings  ${resp.json()['payTmLinkedPhoneNumber']}    ${PUSERNAME150}
    Should Be Equal As Strings  ${resp.json()['panCardNumber']}             ${pan_num}
    Should Be Equal As Strings  ${resp.json()['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()['payTmVerified']}             ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()['accountType']}               ${accountType[1]}

JD-TC-CreateBankInfo-3

    [Documentation]  Create my own bank details for a provider by superadmin and get the bank details by provider..

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Bank Details By Id    ${bank_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()['accountId']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()['bankId']}                    ${bank_id1}
    Should Be Equal As Strings  ${resp.json()['payTmLinkedPhoneNumber']}    ${PUSERNAME150}
    Should Be Equal As Strings  ${resp.json()['panCardNumber']}             ${pan_num}
    Should Be Equal As Strings  ${resp.json()['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()['payTmVerified']}             ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()['accountType']}               ${accountType[1]}

JD-TC-CreateBankInfo-4

    [Documentation]  Create multiple bank details for a provider by superadmin.
    
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

    ${resp}=   Create Bank Info   ${pid}  ${bank_name1}  ${bank_ac1}  ${ifsc_code1}  ${name1}  ${name1}  ${branch1}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num1}  ${PUSERNAME150}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${bank_id2}  ${resp.json()}

    ${resp}=   Get All Bank Info    ${pid}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['bankId']}                    ${bank_id1}
    Should Be Equal As Strings  ${resp.json()[1]['payTmLinkedPhoneNumber']}    ${PUSERNAME150}
    Should Be Equal As Strings  ${resp.json()[1]['panCardNumber']}             ${pan_num}
    Should Be Equal As Strings  ${resp.json()[1]['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()[1]['payTmVerified']}             ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[1]['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()[1]['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()[1]['accountType']}               ${accountType[1]}
    
    Should Be Equal As Strings  ${resp.json()[2]['accountId']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()[2]['bankId']}                    ${bank_id2}
    Should Be Equal As Strings  ${resp.json()[2]['payTmLinkedPhoneNumber']}    ${PUSERNAME150}
    Should Be Equal As Strings  ${resp.json()[2]['panCardNumber']}             ${pan_num1}
    Should Be Equal As Strings  ${resp.json()[2]['bankAccountNumber']}         ${bank_ac1}
    Should Be Equal As Strings  ${resp.json()[2]['payTmVerified']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[2]['branchCity']}                ${branch1}
    Should Be Equal As Strings  ${resp.json()[2]['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()[2]['accountType']}               ${accountType[1]}


JD-TC-CreateBankInfo-5

    [Documentation]  Create my own bank details for a provider without any deatils by superadmin.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Bank Info  ${pid}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}   ${businessFilingStatus[1]}   ${accountType[1]}   ${EMPTY}  ${EMPTY} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200
    Set Suite Variable  ${bank_id3}  ${resp.json()}

    ${resp}=   Get Bank Info By Id   ${bank_id3}  ${pid}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


JD-TC-CreateBankInfo-UH1

    [Documentation]  Create my own bank details for a provider by superadmin without phone number.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Bank Info   ${pid}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${EMPTY}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${PAYTM_LINKED_NUMBER_REQUIRED}


JD-TC-CreateBankInfo-UH2

    [Documentation]  create bank details by consumer login.
    
    ${resp}=   ConsumerLogin  ${CUSERNAME2}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Create Bank Info   ${pid}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME150}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  ${resp.json()}   ${SA_SESSION_EXPIRED}


JD-TC-CreateBankInfo-UH3

    [Documentation]  create bank details by provider login.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Bank Info   ${pid}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME150}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  ${resp.json()}   ${SA_SESSION_EXPIRED}


JD-TC-CreateBankInfo-UH4

    [Documentation]  create bank details using invalid account id.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Bank Info   0000  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME150}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${ACCOUNT_NOT_EXIST}


JD-TC-CreateBankInfo-UH5

    [Documentation]  Create my own bank details without login.

    ${resp}=   Create Bank Info   ${pid}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME150}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  ${resp.json()}   ${SA_SESSION_EXPIRED}


JD-TC-CreateBankInfo-UH6

    [Documentation]  create bank details without pancard number.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Bank Info   ${pid}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${EMPTY}  ${PUSERNAME150}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}


JD-TC-CreateBankInfo-UH7

    [Documentation]  create bank details without bank account number.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Bank Info   ${pid}  ${bank_name}  ${EMPTY}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME150}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}


JD-TC-CreateBankInfo-UH8

    [Documentation]  create bank details without bank name.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Bank Info   ${pid}  ${EMPTY}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME150}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}


JD-TC-CreateBankInfo-UH9

    [Documentation]  create bank details without ifsc code.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Bank Info   ${pid}  ${bank_name}  ${bank_ac}   ${EMPTY}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME150}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}


JD-TC-CreateBankInfo-UH10

    [Documentation]  create bank details without name on pan card.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Bank Info   ${pid}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${EMPTY}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME150}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}


JD-TC-CreateBankInfo-UH11

    [Documentation]  create bank details without Account holder's name.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Bank Info   ${pid}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${EMPTY}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME150}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}


JD-TC-CreateBankInfo-UH12

    [Documentation]  create bank details without branch city.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Bank Info   ${pid}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${EMPTY}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME150}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}

