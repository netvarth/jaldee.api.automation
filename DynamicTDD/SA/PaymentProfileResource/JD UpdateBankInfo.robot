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

JD-TC-UpdateBankInfo-1

    [Documentation]  Create and update bank details with another phone number for a provider by superadmin.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME154}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME154}
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

    ${resp}=   Create Bank Info   ${pid}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME154}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${bank_id1}  ${resp.json()}

    ${resp}=   Get Bank Info By Id   ${bank_id1}  ${pid}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()['accountId']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()['bankId']}                    ${bank_id1}
    # Should Be Equal As Strings  ${resp.json()['payTm']}                     ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['payTmLinkedPhoneNumber']}    ${PUSERNAME154}
    Should Be Equal As Strings  ${resp.json()['panCardNumber']}             ${pan_num}
    Should Be Equal As Strings  ${resp.json()['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()['payTmVerified']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()['accountType']}               ${accountType[1]}
    
    ${resp}=   Update Bank Info   ${bank_id1}   ${pid}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME100}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Bank Info By Id   ${bank_id1}  ${pid}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()['accountId']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()['bankId']}                    ${bank_id1}
    # Should Be Equal As Strings  ${resp.json()['payTm']}                     ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['payTmLinkedPhoneNumber']}    ${PUSERNAME100}
    Should Be Equal As Strings  ${resp.json()['panCardNumber']}             ${pan_num}
    Should Be Equal As Strings  ${resp.json()['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()['payTmVerified']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()['accountType']}               ${accountType[1]}

JD-TC-UpdateBankInfo-2

    [Documentation]  Create and update bank details with another another pancard number for a provider by superadmin.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME154}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${GST_num11}  ${pan_num11}=   db.Generate_gst_number   ${Container_id}
    Set Suite Variable  ${pan_num11}
    Set Suite Variable  ${GST_num11}

    ${resp}=  razorpayVerify  ${pid}
    Log  ${resp}

    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num11} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Bank Info   ${bank_id1}   ${pid}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${PUSERNAME100}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Bank Info By Id   ${bank_id1}  ${pid}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()['accountId']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()['bankId']}                    ${bank_id1}
    # Should Be Equal As Strings  ${resp.json()['payTm']}                     ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['dcOrCcOrNb']}                ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['payTmLinkedPhoneNumber']}    ${PUSERNAME100}
    Should Be Equal As Strings  ${resp.json()['panCardNumber']}             ${pan_num11}
    Should Be Equal As Strings  ${resp.json()['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()['payTmVerified']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()['accountType']}               ${accountType[1]}

JD-TC-UpdateBankInfo-3

    [Documentation]  Update my own bank details for a provider by superadmin after did the payu verification.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME154}  ${PASSWORD}
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
    # Should Be Equal As Strings  ${resp.json()['payTm']}                     ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['payTmLinkedPhoneNumber']}    ${PUSERNAME100}
    Should Be Equal As Strings  ${resp.json()['panCardNumber']}             ${pan_num11}
    Should Be Equal As Strings  ${resp.json()['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()['payTmVerified']}             ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()['accountType']}               ${accountType[1]}
    
    ${resp}=   Update Bank Info   ${bank_id1}   ${pid}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${PUSERNAME101}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Bank Info By Id   ${bank_id1}  ${pid}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()['accountId']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()['bankId']}                    ${bank_id1}
    # Should Be Equal As Strings  ${resp.json()['payTm']}                     ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['payTmLinkedPhoneNumber']}    ${PUSERNAME101}
    Should Be Equal As Strings  ${resp.json()['panCardNumber']}             ${pan_num11}
    Should Be Equal As Strings  ${resp.json()['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()['payTmVerified']}             ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()['accountType']}               ${accountType[1]}


JD-TC-UpdateBankInfo-4

    [Documentation]  Create and update my own bank details for a provider by superadmin and get the bank details by provider..

    ${resp}=  Encrypted Provider Login  ${PUSERNAME154}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Bank Details By Id    ${bank_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()['accountId']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()['bankId']}                    ${bank_id1}
    # Should Be Equal As Strings  ${resp.json()['payTm']}                     ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['payTmLinkedPhoneNumber']}    ${PUSERNAME101}
    Should Be Equal As Strings  ${resp.json()['panCardNumber']}             ${pan_num11}
    Should Be Equal As Strings  ${resp.json()['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()['payTmVerified']}             ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()['accountType']}               ${accountType[1]}
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${name1}=  FakerLibrary.firstname
    Set Suite Variable  ${name1}

    ${resp}=   Update Bank Info   ${bank_id1}   ${pid}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name1}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${PUSERNAME101}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME154}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Bank Details By Id    ${bank_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()['accountId']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()['bankId']}                    ${bank_id1}
    # Should Be Equal As Strings  ${resp.json()['payTm']}                     ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['dcOrCcOrNb']}                ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['payTmLinkedPhoneNumber']}    ${PUSERNAME101}
    Should Be Equal As Strings  ${resp.json()['panCardNumber']}             ${pan_num11}
    Should Be Equal As Strings  ${resp.json()['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()['accountHolderName']}         ${name1}
    Should Be Equal As Strings  ${resp.json()['payTmVerified']}             ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()['accountType']}               ${accountType[1]}

JD-TC-UpdateBankInfo-UH1

    [Documentation]  Update my own bank details for a provider by superadmin without phone number.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Bank Info   ${bank_id1}   ${pid}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${EMPTY}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${PAYTM_LINKED_NUMBER_REQUIRED}


JD-TC-UpdateBankInfo-UH2

    [Documentation]  Update bank details by consumer login.
    
    ${resp}=   ConsumerLogin  ${CUSERNAME2}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Update Bank Info   ${bank_id1}   ${pid}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${PUSERNAME101}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  ${resp.json()}   ${SA_SESSION_EXPIRED}


JD-TC-UpdateBankInfo-UH3

    [Documentation]  Update bank details by provider login.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME154}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Bank Info   ${bank_id1}   ${pid}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${PUSERNAME101}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  ${resp.json()}   ${SA_SESSION_EXPIRED}


JD-TC-UpdateBankInfo-UH4

    [Documentation]  Update bank details using invalid account id.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Bank Info   ${bank_id1}   0000  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name1}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${PUSERNAME101}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${ACCOUNT_NOT_EXIST}


JD-TC-UpdateBankInfo-UH5

    [Documentation]  Update my own bank details without login.

    ${resp}=   Update Bank Info   ${bank_id1}   ${pid}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name1}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${PUSERNAME101}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  ${resp.json()}   ${SA_SESSION_EXPIRED}


JD-TC-UpdateBankInfo-UH6

    [Documentation]  Update bank details without pancard number.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Bank Info   ${bank_id1}   ${pid}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name1}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${EMPTY}  ${PUSERNAME101}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}


JD-TC-UpdateBankInfo-UH7

    [Documentation]  Update bank details without bank account number.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Bank Info   ${bank_id1}   ${pid}  ${bank_name}  ${EMPTY}   ${ifsc_code}  ${name}  ${name1}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${PUSERNAME101}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}


JD-TC-UpdateBankInfo-UH8

    [Documentation]  Update bank details without bank name.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Bank Info   ${bank_id1}   ${pid}  ${EMPTY}  ${bank_ac}   ${ifsc_code}  ${name}  ${name1}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${PUSERNAME101}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}


JD-TC-UpdateBankInfo-UH9

    [Documentation]  Update bank details without ifsc code.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Bank Info   ${bank_id1}   ${pid}  ${bank_name}  ${bank_ac}   ${EMPTY}  ${name}  ${name1}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${PUSERNAME101}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}


JD-TC-UpdateBankInfo-UH10

    [Documentation]  Update bank details without name on pan card.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Bank Info   ${bank_id1}   ${pid}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${EMPTY}  ${name1}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${PUSERNAME101}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}


JD-TC-UpdateBankInfo-UH11

    [Documentation]  Update bank details without Account holder's name.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Bank Info   ${bank_id1}   ${pid}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${EMPTY}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${PUSERNAME101}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}


JD-TC-UpdateBankInfo-UH12

    [Documentation]  Update bank details without branch city.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Bank Info   ${bank_id1}   ${pid}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${EMPTY}  ${EMPTY}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${PUSERNAME101}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}


JD-TC-UpdateBankInfo-5

    [Documentation]  Update my own bank details for a provider without any deatils by superadmin.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Update Bank Info   ${bank_id1}   ${pid}  ${EMPTY}  ${EMPTY}   ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${businessFilingStatus[1]}  ${accountType[1]}  ${EMPTY}  ${EMPTY}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200
   
    ${resp}=   Get Bank Info By Id   ${bank_id1}  ${pid}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

