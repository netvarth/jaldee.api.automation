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

JD-TC-CreateBankDetails-1

    [Documentation]  Create my own bank details by provider.
    
    ${resp}=  ProviderLogin  ${PUSERNAME120}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME120}
    Set Suite Variable  ${pid}

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

    ${resp}=   Create Bank Details   ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME120}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${bank_id1}  ${resp.json()}

    ${resp}=   Get Bank Details By Id   ${bank_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()['accountId']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()['bankId']}                    ${bank_id1}
    Should Be Equal As Strings  ${resp.json()['payTmLinkedPhoneNumber']}    ${PUSERNAME120}
    Should Be Equal As Strings  ${resp.json()['panCardNumber']}             ${pan_num}
    Should Be Equal As Strings  ${resp.json()['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()['payTmVerified']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()['accountType']}               ${accountType[1]}

JD-TC-CreateBankInfo-2

    [Documentation]  Create my own bank details then do the payu verification.
    
    ${resp}=  ProviderLogin  ${PUSERNAME120}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Bank Details
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  payTmVerify  ${pid}
    Log  ${resp}

    ${resp}=   Get Bank Details By Id  ${bank_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()['accountId']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()['bankId']}                    ${bank_id1}
    Should Be Equal As Strings  ${resp.json()['payTmLinkedPhoneNumber']}    ${PUSERNAME120}
    Should Be Equal As Strings  ${resp.json()['panCardNumber']}             ${pan_num}
    Should Be Equal As Strings  ${resp.json()['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()['payTmVerified']}             ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()['accountType']}               ${accountType[1]}

JD-TC-CreateBankInfo-3

    [Documentation]  Create my own bank details and get the bank details by superadmin..

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Bank Info By Id   ${bank_id1}  ${pid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()['accountId']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()['bankId']}                    ${bank_id1}
    Should Be Equal As Strings  ${resp.json()['payTmLinkedPhoneNumber']}    ${PUSERNAME120}
    Should Be Equal As Strings  ${resp.json()['panCardNumber']}             ${pan_num}
    Should Be Equal As Strings  ${resp.json()['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()['payTmVerified']}             ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()['accountType']}               ${accountType[1]}

JD-TC-CreateBankInfo-4

    [Documentation]  Create multiple bank details.

    ${resp}=  ProviderLogin  ${PUSERNAME120}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${GST_num1}  ${pan_num1}=   db.Generate_gst_number   ${Container_id}
    Set Suite Variable  ${pan_num1}
    Set Suite Variable  ${GST_num1}

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

    ${resp}=   Create Bank Details  ${bank_name1}  ${bank_ac1}  ${ifsc_code1}  ${name1}  ${name1}  ${branch1}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num1}  ${PUSERNAME120}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${bank_id2}  ${resp.json()}

    ${resp}=   Get Bank Details
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['bankId']}                    ${bank_id1}
    # Should Be Equal As Strings  ${resp.json()[1]['payTm']}                     ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[1]['payTmLinkedPhoneNumber']}    ${PUSERNAME120}
    Should Be Equal As Strings  ${resp.json()[1]['panCardNumber']}             ${pan_num}
    Should Be Equal As Strings  ${resp.json()[1]['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()[1]['payTmVerified']}             ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[1]['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()[1]['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()[1]['accountType']}               ${accountType[1]}
    
    Should Be Equal As Strings  ${resp.json()[2]['accountId']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()[2]['bankId']}                    ${bank_id2}
    # Should Be Equal As Strings  ${resp.json()[2]['payTm']}                     ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[2]['payTmLinkedPhoneNumber']}    ${PUSERNAME120}
    Should Be Equal As Strings  ${resp.json()[2]['panCardNumber']}             ${pan_num1}
    Should Be Equal As Strings  ${resp.json()[2]['bankAccountNumber']}         ${bank_ac1}
    Should Be Equal As Strings  ${resp.json()[2]['payTmVerified']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[2]['branchCity']}                ${branch1}
    Should Be Equal As Strings  ${resp.json()[2]['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()[2]['accountType']}               ${accountType[1]}

JD-TC-CreateBankInfo-5

    [Documentation]  Create my own bank details for a provider without any deatils.

    ${resp}=  ProviderLogin  ${PUSERNAME120}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Bank Details   ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}   ${businessFilingStatus[1]}   ${accountType[1]}   ${EMPTY}  ${EMPTY} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200
    Set Suite Variable  ${bank_id3}  ${resp.json()}

    ${resp}=   Get Bank Details By Id   ${bank_id3}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-CreateBankInfo-UH1

    [Documentation]  Create my own bank details without phone number.
    
    ${resp}=  ProviderLogin  ${PUSERNAME120}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Bank Details   ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${EMPTY}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Should Be Equal As Strings    ${resp.status_code}   422
    # Should Be Equal As Strings  ${resp.json()}   ${PAYTM_LINKED_NUMBER_REQUIRED}


JD-TC-CreateBankInfo-UH2

    [Documentation]  create bank details by consumer login.
    
    ${resp}=   ConsumerLogin  ${CUSERNAME2}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Create Bank Details   ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME120}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-CreateBankInfo-UH3

    [Documentation]  create bank details by Superadmin login.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Bank Details   ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME120}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-CreateBankInfo-UH4

    [Documentation]  Create my own bank details without login.

    ${resp}=   Create Bank Details   ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME120}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-CreateBankInfo-UH5

    [Documentation]  create bank details without pancard number.
    
    ${resp}=  ProviderLogin  ${PUSERNAME120}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Bank Details   ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${EMPTY}  ${PUSERNAME120}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Should Be Equal As Strings    ${resp.status_code}   422
    # Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}


JD-TC-CreateBankInfo-UH6

    [Documentation]  create bank details without bank account number.
    
    ${resp}=  ProviderLogin  ${PUSERNAME120}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Bank Details   ${bank_name}  ${EMPTY}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME120}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Should Be Equal As Strings    ${resp.status_code}   422
    # Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}


JD-TC-CreateBankInfo-UH7

    [Documentation]  create bank details without bank name.
    
    ${resp}=  ProviderLogin  ${PUSERNAME120}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Bank Details   ${EMPTY}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME120}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Should Be Equal As Strings    ${resp.status_code}   422
    # Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}


JD-TC-CreateBankInfo-UH8

    [Documentation]  create bank details without ifsc code.
    
    ${resp}=  ProviderLogin  ${PUSERNAME120}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Bank Details   ${bank_name}  ${bank_ac}   ${EMPTY}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME120}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Should Be Equal As Strings    ${resp.status_code}   422
    # Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}


JD-TC-CreateBankInfo-UH9

    [Documentation]  create bank details without name on pan card.
    
    ${resp}=  ProviderLogin  ${PUSERNAME120}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Bank Details   ${bank_name}  ${bank_ac}   ${ifsc_code}  ${EMPTY}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME120}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Should Be Equal As Strings    ${resp.status_code}   422
    # Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}


JD-TC-CreateBankInfo-UH10

    [Documentation]  create bank details without Account holder's name.
    
    ${resp}=  ProviderLogin  ${PUSERNAME120}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Bank Details   ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${EMPTY}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME120}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Should Be Equal As Strings    ${resp.status_code}   422
    # Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}


JD-TC-CreateBankInfo-UH11

    [Documentation]  create bank details without branch city.
    
    ${resp}=  ProviderLogin  ${PUSERNAME120}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Bank Details   ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${EMPTY}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME120}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Should Be Equal As Strings    ${resp.status_code}   422
    # Should Be Equal As Strings  ${resp.json()}   ${PAYU_ACCOUNTDETAILS_REQUIRED}

