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

JD-TC-GetAllBankDetails-1

    [Documentation]  Get my own bank details by provider.
    
    ${resp}=  ProviderLogin  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME152}
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

    ${resp}=   Create Bank Details   ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME152}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${bank_id1}  ${resp.json()}

    ${resp}=   Get Bank Details
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['bankId']}                    ${bank_id1}
    Should Be Equal As Strings  ${resp.json()[1]['payTmLinkedPhoneNumber']}    ${PUSERNAME152}
    Should Be Equal As Strings  ${resp.json()[1]['panCardNumber']}             ${pan_num}
    Should Be Equal As Strings  ${resp.json()[1]['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()[1]['payTmVerified']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[1]['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()[1]['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()[1]['accountType']}               ${accountType[1]}
    

JD-TC-GetAllBankDetails-2

    [Documentation]  Get multiple bank details by provider. 

    ${GST_num1}  ${pan_num1}=   db.Generate_gst_number   ${Container_id}
    Set Suite Variable  ${pan_num1}
    Set Suite Variable  ${GST_num1}

    ${resp}=  ProviderLogin  ${PUSERNAME152}  ${PASSWORD}
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

    ${resp}=   Create Bank Details   ${bank_name1}  ${bank_ac1}   ${ifsc_code1}  ${name1}  ${name1}  ${branch1}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num1}  ${PUSERNAME152}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${bank_id2}  ${resp.json()}
    
    ${resp}=    Get Bank Details
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['bankId']}                    ${bank_id1}
    Should Be Equal As Strings  ${resp.json()[1]['payTmLinkedPhoneNumber']}    ${PUSERNAME152}
    Should Be Equal As Strings  ${resp.json()[1]['panCardNumber']}             ${pan_num}
    Should Be Equal As Strings  ${resp.json()[1]['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()[1]['payTmVerified']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[1]['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()[1]['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()[1]['accountType']}               ${accountType[1]}
    
    Should Be Equal As Strings  ${resp.json()[2]['accountId']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()[2]['bankId']}                    ${bank_id2}
    Should Be Equal As Strings  ${resp.json()[2]['payTmLinkedPhoneNumber']}    ${PUSERNAME152}
    Should Be Equal As Strings  ${resp.json()[2]['panCardNumber']}             ${pan_num1}
    Should Be Equal As Strings  ${resp.json()[2]['bankAccountNumber']}         ${bank_ac1}
    Should Be Equal As Strings  ${resp.json()[2]['payTmVerified']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[2]['branchCity']}                ${branch1}
    Should Be Equal As Strings  ${resp.json()[2]['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()[2]['accountType']}               ${accountType[1]}

JD-TC-GetAllBankInfo-3

    [Documentation]  Get bank details of multiple providers by superadmin.

    ${resp}=  ProviderLogin  ${PUSERNAME153}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid2}=  get_acc_id  ${PUSERNAME153}
    Set Suite Variable  ${pid2}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${GST_num2}  ${pan_num2}=   db.Generate_gst_number   ${Container_id}
    Set Suite Variable  ${pan_num2}
    Set Suite Variable  ${GST_num2}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num2} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${ifsc_code2}=   db.Generate_ifsc_code
    Set Suite Variable  ${ifsc_code2}
    ${bank_ac2}=   db.Generate_random_value  size=11   chars=${digits} 
    Set Suite Variable  ${bank_ac2}
    ${bank_name2}=  FakerLibrary.company
    Set Suite Variable  ${bank_name2}
    ${name2}=  FakerLibrary.name
    Set Suite Variable  ${name2}
    ${branch2}=   db.get_place
    Set Suite Variable  ${branch2}

    ${resp}=   Create Bank Info   ${pid2}  ${bank_name2}  ${bank_ac2}   ${ifsc_code2}  ${name2}  ${name2}  ${branch2}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num2}  ${PUSERNAME153}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${bank_id3}  ${resp.json()}
    
    ${resp}=   Get All Bank Info    ${pid}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['bankId']}                    ${bank_id1}
    Should Be Equal As Strings  ${resp.json()[1]['payTmLinkedPhoneNumber']}    ${PUSERNAME152}
    Should Be Equal As Strings  ${resp.json()[1]['panCardNumber']}             ${pan_num}
    Should Be Equal As Strings  ${resp.json()[1]['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()[1]['payTmVerified']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[1]['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()[1]['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()[1]['accountType']}               ${accountType[1]}
    
    Should Be Equal As Strings  ${resp.json()[2]['accountId']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()[2]['bankId']}                    ${bank_id2}
    Should Be Equal As Strings  ${resp.json()[2]['payTmLinkedPhoneNumber']}    ${PUSERNAME152}
    Should Be Equal As Strings  ${resp.json()[2]['panCardNumber']}             ${pan_num1}
    Should Be Equal As Strings  ${resp.json()[2]['bankAccountNumber']}         ${bank_ac1}
    Should Be Equal As Strings  ${resp.json()[2]['payTmVerified']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[2]['branchCity']}                ${branch1}
    Should Be Equal As Strings  ${resp.json()[2]['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()[2]['accountType']}               ${accountType[1]}
    
    ${resp}=   Get All Bank Info    ${pid2}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}                 ${pid2}
    Should Be Equal As Strings  ${resp.json()[1]['bankId']}                    ${bank_id3}
    Should Be Equal As Strings  ${resp.json()[1]['payTmLinkedPhoneNumber']}    ${PUSERNAME153}
    Should Be Equal As Strings  ${resp.json()[1]['panCardNumber']}             ${pan_num2}
    Should Be Equal As Strings  ${resp.json()[1]['bankAccountNumber']}         ${bank_ac2}
    Should Be Equal As Strings  ${resp.json()[1]['payTmVerified']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[1]['branchCity']}                ${branch2}
    Should Be Equal As Strings  ${resp.json()[1]['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()[1]['accountType']}               ${accountType[1]}


JD-TC-CreateBankInfo-4

    [Documentation]  get bank details by id with invalid account id.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get All Bank Info   0000
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${ACCOUNT_NOT_EXIST}


JD-TC-CreateBankInfo-UH1

    [Documentation]  Get bank details by consumer login.
    
    ${resp}=   ConsumerLogin  ${CUSERNAME2}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get All Bank Info    ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  ${resp.json()}   ${SA_SESSION_EXPIRED}


JD-TC-CreateBankInfo-UH2

    [Documentation]  get bank details by provider login.
    
    ${resp}=  ProviderLogin  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get All Bank Info    ${pid}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  ${resp.json()}   ${SA_SESSION_EXPIRED}


JD-TC-CreateBankInfo-UH3

    [Documentation]  Get my own bank details by id without login.

    ${resp}=   Get All Bank Info    ${pid}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  ${resp.json()}   ${SA_SESSION_EXPIRED}


