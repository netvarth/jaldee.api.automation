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



*** Test Cases ***

JD-TC-UpdateBankDetails-1

    [Documentation]  Create and update bank details with another phone number for a provider by superadmin.
    
    ${resp}=  ProviderLogin  ${PUSERNAME154}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME154}
    Set Suite Variable  ${pid}

    ${DAY}=  get_date
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

    ${resp}=   Create Bank Details   ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME154}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${bank_id1}  ${resp.json()}

    ${resp}=   Get Bank Details By Id   ${bank_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()['bankId']}                    ${bank_id1}
    Should Be Equal As Strings  ${resp.json()['panCardNumber']}             ${pan_num}
    Should Be Equal As Strings  ${resp.json()['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()['accountType']}               ${accountType[1]}
    
    ${resp}=   Update Bank Details   ${bank_id1}   ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME100}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Bank Details By Id   ${bank_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()['bankId']}                    ${bank_id1}
    Should Be Equal As Strings  ${resp.json()['panCardNumber']}             ${pan_num}
    Should Be Equal As Strings  ${resp.json()['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()['accountType']}               ${accountType[1]}

JD-TC-UpdateBankDetails-2

    [Documentation]  Create and update bank details with another another pancard number for a provider by superadmin.
    
    ${resp}=  ProviderLogin  ${PUSERNAME154}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${GST_num11}  ${pan_num11}=   db.Generate_gst_number   ${Container_id}
    Set Suite Variable  ${pan_num11}
    Set Suite Variable  ${GST_num11}

    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num11} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Update Bank Details   ${bank_id1}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${PUSERNAME100}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Bank Details By Id   ${bank_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()['bankId']}                    ${bank_id1}
    Should Be Equal As Strings  ${resp.json()['panCardNumber']}             ${pan_num11}
    Should Be Equal As Strings  ${resp.json()['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()['accountType']}               ${accountType[1]}

JD-TC-UpdateBankDetails-3

    [Documentation]  Update my own bank details for a provider by superadmin after did the payu verification.
    
    ${resp}=  ProviderLogin  ${PUSERNAME154}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Bank Details
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Bank Details By Id   ${bank_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()['bankId']}                    ${bank_id1}
    Should Be Equal As Strings  ${resp.json()['panCardNumber']}             ${pan_num11}
    Should Be Equal As Strings  ${resp.json()['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()['accountType']}               ${accountType[1]}
    
    ${resp}=   Update Bank Details   ${bank_id1}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${PUSERNAME101}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Bank Details By Id   ${bank_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()['bankId']}                    ${bank_id1}
    Should Be Equal As Strings  ${resp.json()['panCardNumber']}             ${pan_num11}
    Should Be Equal As Strings  ${resp.json()['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()['accountType']}               ${accountType[1]}


JD-TC-UpdateBankDetails-4

    [Documentation]  Create and update my own bank details for a provider by superadmin and get the bank details by provider..

    ${resp}=  ProviderLogin  ${PUSERNAME154}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Bank Details By Id    ${bank_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()['bankId']}                    ${bank_id1}
    Should Be Equal As Strings  ${resp.json()['panCardNumber']}             ${pan_num11}
    Should Be Equal As Strings  ${resp.json()['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()['accountType']}               ${accountType[1]}
    
    ${name1}=  FakerLibrary.firstname
    Set Suite Variable  ${name1}

    ${resp}=   Update Bank Details   ${bank_id1}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name1}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${PUSERNAME101}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  ProviderLogin  ${PUSERNAME154}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Bank Details By Id    ${bank_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()['bankId']}                    ${bank_id1}
    Should Be Equal As Strings  ${resp.json()['panCardNumber']}             ${pan_num11}
    Should Be Equal As Strings  ${resp.json()['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()['accountHolderName']}         ${name1}
    Should Be Equal As Strings  ${resp.json()['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()['accountType']}               ${accountType[1]}

JD-TC-UpdateBankDetails-6

    [Documentation]  Update my own bank details for a provider without phone number.
    
    ${resp}=  ProviderLogin  ${PUSERNAME154}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Bank Details   ${bank_id1}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${EMPTY}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Should Be Equal As Strings    ${resp.status_code}   422
    # Should Be Equal As Strings  ${resp.json()}   ${PAYTM_LINKED_NUMBER_REQUIRED}


JD-TC-UpdateBankDetails-UH1

    [Documentation]  Update bank details by consumer login.
    
    ${resp}=   ConsumerLogin  ${CUSERNAME2}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Update Bank Details   ${bank_id1}   ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${PUSERNAME101}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-UpdateBankDetails-UH3

    [Documentation]  Update bank details by super admin login.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Bank Details   ${bank_id1}    ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${PUSERNAME101}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-UpdateBankDetails-UH4

    [Documentation]  Update bank details using invalid bank id.
    
    ${resp}=  ProviderLogin  ${PUSERNAME154}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Bank Details    0000  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name1}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${PUSERNAME101}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${NO_BANK_DETAILS_FOUND}


JD-TC-UpdateBankDetails-UH5

    [Documentation]  Update my own bank details without login.

    ${resp}=   Update Bank Details   ${bank_id1}   ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name1}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${PUSERNAME101}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-UpdateBankDetails-7

    [Documentation]  Update bank details without pancard number.
    
    ${resp}=  ProviderLogin  ${PUSERNAME154}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Bank Details   ${bank_id1}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name1}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${EMPTY}  ${PUSERNAME101}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Should Be Equal As Strings    ${resp.status_code}   422
    # Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}


JD-TC-UpdateBankDetails-8

    [Documentation]  Update bank details without bank account number.
    
    ${resp}=  ProviderLogin  ${PUSERNAME154}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Bank Details   ${bank_id1}  ${bank_name}  ${EMPTY}   ${ifsc_code}  ${name}  ${name1}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${PUSERNAME101}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Should Be Equal As Strings    ${resp.status_code}   422
    # Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}


JD-TC-UpdateBankDetails-9

    [Documentation]  Update bank details without bank name.
    
    ${resp}=  ProviderLogin  ${PUSERNAME154}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Bank Details   ${bank_id1}   ${EMPTY}  ${bank_ac}   ${ifsc_code}  ${name}  ${name1}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${PUSERNAME101}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Should Be Equal As Strings    ${resp.status_code}   422
    # Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}


JD-TC-UpdateBankDetails-10

    [Documentation]  Update bank details without ifsc code.
    
    ${resp}=  ProviderLogin  ${PUSERNAME154}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Bank Details   ${bank_id1}   ${bank_name}  ${bank_ac}   ${EMPTY}  ${name}  ${name1}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${PUSERNAME101}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Should Be Equal As Strings    ${resp.status_code}   422
    # Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}


JD-TC-UpdateBankDetails-11

    [Documentation]  Update bank details without name on pan card.
    
    ${resp}=  ProviderLogin  ${PUSERNAME154}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Bank Details   ${bank_id1}   ${bank_name}  ${bank_ac}   ${ifsc_code}  ${EMPTY}  ${name1}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${PUSERNAME101}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Should Be Equal As Strings    ${resp.status_code}   422
    # Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}


JD-TC-UpdateBankDetails-12

    [Documentation]  Update bank details without Account holder's name.
    
    ${resp}=  ProviderLogin  ${PUSERNAME154}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Bank Details   ${bank_id1}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${EMPTY}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${PUSERNAME101}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Should Be Equal As Strings    ${resp.status_code}   422
    # Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}


JD-TC-UpdateBankDetails-13

    [Documentation]  Update bank details without branch city.
    
    ${resp}=  ProviderLogin  ${PUSERNAME154}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Bank Details   ${bank_id1}  ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${EMPTY}  ${EMPTY}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num11}  ${PUSERNAME101}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Should Be Equal As Strings    ${resp.status_code}   422
    # Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}


JD-TC-UpdateBankDetails-5

    [Documentation]  Update my own bank details for a provider without any deatils by superadmin.

    ${resp}=  ProviderLogin  ${PUSERNAME154}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Update Bank Details   ${bank_id1}   ${EMPTY}  ${EMPTY}   ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${businessFilingStatus[1]}  ${accountType[1]}  ${EMPTY}  ${EMPTY}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200
   
    ${resp}=   Get Bank Details By Id   ${bank_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

