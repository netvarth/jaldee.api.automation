*** Settings ***
Test Teardown     Delete All Sessions
Force Tags        Payment Profile
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

${id}            spDefaultProfile
${displayName}   SP Default Payment Profile
${chargeConsumer}    GatewayAPi
${digits}       0123456789
${service_duration}   2
${parallel}           1
${self}               0
@{provider_list}
${start}              140
${jcoupon1}   CouponMul00


*** Test Cases ***

JD-TC-GetPaymentProfileById-1

    [Documentation]  Create and get payment profile by id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME191}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME191}
    Set Suite Variable   ${pid}
    
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
    
    ${resp}=   Create Bank Details   ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME123}         
    ...   razorpayMerchantId=rzp_test_tD0hiOsaNEJfpk   razorpayMerchantKey=anvXiqqxugTK3JBOlBNTONEY   razorpayWebhookMerchantKey=abcd       
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${bank_id1}  ${resp.json()}

    ${resp}=   Get Bank Details By Id   ${bank_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${desc}=  FakerLibrary.word
    ${type}=  Create List   onlinePay   bank2bank 
    ${txnTypes}=   Create List   any
    ${destBank}=  Create List   OWN
    ${paymode}=  Create List   any
    ${gateway}=  Create List   RAZORPAY
    ${chargeConsumer}=  Create List   ${chargeConsumer}
    ${gatewayFee}=   Create Dictionary   chargeConsumer=${chargeConsumer}   fixedPctValue=0   fixedAmountValue=0  fixedPctValueMax=0  fixedPctValueMin=0
    ${indianPaymodes1}=   Create Dictionary   mode=${payment_modes[5]}   gateway=${gateway}   modeDisplayName=${payment_modes[5]}   
    ...   gatewayMerchantId=${bank_id1}  gatewayFee=${gatewayFee}
    ${indianPaymodes1}=  Create List   ${indianPaymodes1}

    ${internationalPaymodes1}=   Create Dictionary   mode=${payment_modes[5]}   gateway=${gateway}   modeDisplayName=${payment_modes[5]}   
    ...   gatewayMerchantId=${bank_id1}  gatewayFee=${gatewayFee}
    ${internationalPaymodes}=  Create List    ${internationalPaymodes1}

    ${splitPayment}   Create List   no  2-way   3-way
    ${destBanks}=   Create Dictionary   bankID=${EMPTY}   payPct=50   fixedPctValueMin=3   fixedPctValueMax=5   fixed=${EMPTY}     
    ${destBanks}=  Create List   ${destBanks}
    ${fee}=   Create List   incl  excl
    ${fromBank}=   Create Dictionary   bankID=${EMPTY}   maxLimit=100000   fee=${fee}   

    ${resp}=   Payment Profile  ${id}  ${displayName}   ${desc}  ${type}  ${txnTypes}   ${destBank}  ${boolean[1]}   ${paymode}  ${boolean[1]}
    ...   ${indianPaymodes1}   ${boolean[1]}   ${internationalPaymodes}  ${splitPayment}   ${destBanks}   ${fromBank}

    ${profiles1}=  Setting Payment Profile  ${resp} 
    
    ${combined_json}=  Payment Profile Json  ${profiles1}  
    
    ${payment_profile}=  payment_profiles   ${combined_json}  ${pid}
    
    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME191}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Destination Bank  ${id}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Bank Details
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get payment profile By Id    ${id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()['profileId']}                                ${id}
    Should Be Equal As Strings  ${resp.json()['indiaPay']}                                 ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['internationalPay']}                         ${bool[1]}

JD-TC-GetPaymentProfile-2

    [Documentation]  Create and get payment profile for multiple banks.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME191}  ${PASSWORD}
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

    ${resp}=   Create Bank Details  ${bank_name1}  ${bank_ac1}  ${ifsc_code1}  ${name1}  ${name1}  ${branch1}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num1}  ${PUSERNAME124}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${bank_id2}  ${resp.json()}

    ${resp}=   Get Bank Details
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${desc}=  FakerLibrary.word
    ${type}=  Create List   onlinePay   bank2bank 
    ${txnTypes}=   Create List   any
    ${destBank}=  Create List   OWN
    ${paymode}=  Create List   any
    ${gateway}=  Create List   RAZORPAY
    ${chargeConsumer}=  Create List   ${chargeConsumer}
    ${gatewayFee}=   Create Dictionary   chargeConsumer=${chargeConsumer}   fixedPctValue=0   fixedAmountValue=0  fixedPctValueMax=0  fixedPctValueMin=0
    ${indianPaymodes1}=   Create Dictionary   mode=${payment_modes[5]}   gateway=${gateway}   modeDisplayName=${payment_modes[5]}   
    ...   gatewayMerchantId=${bank_id1}  gatewayFee=${gatewayFee}
    ${indianPaymodes1}=  Create List   ${indianPaymodes1}

    ${internationalPaymodes1}=   Create Dictionary   mode=${payment_modes[5]}   gateway=${gateway}   modeDisplayName=${payment_modes[5]}   
    ...   gatewayMerchantId=${bank_id1}  gatewayFee=${gatewayFee}
    ${internationalPaymodes}=  Create List    ${internationalPaymodes1}

    ${splitPayment}   Create List   no  2-way   3-way
    ${destBanks}=   Create Dictionary   bankID=${EMPTY}   payPct=50   fixedPctValueMin=3   fixedPctValueMax=5   fixed=${EMPTY}     
    ${destBanks}=  Create List   ${destBanks}
    ${fee}=   Create List   incl  excl
    ${fromBank}=   Create Dictionary   bankID=${EMPTY}   maxLimit=100000   fee=${fee}   

    ${resp}=   Payment Profile  ${id}  ${displayName}   ${desc}  ${type}  ${txnTypes}   ${destBank}  ${boolean[1]}   ${paymode}  ${boolean[1]}
    ...   ${indianPaymodes1}   ${boolean[1]}   ${internationalPaymodes}  ${splitPayment}   ${destBanks}   ${fromBank}
    
    ${id1}=  FakerLibrary.word
    ${indianPaymodes2}=   Create Dictionary   mode=${payment_modes[5]}   gateway=${gateway}   modeDisplayName=${payment_modes[5]}   
    ...   gatewayMerchantId=${bank_id2}  gatewayFee=${gatewayFee}
    ${indianPaymodes2}=  Create List   ${indianPaymodes2}

    ${internationalPaymodes}=  Create List

    ${resp1}=   Payment Profile  ${id1}  ${displayName}   ${desc}  ${type}  ${txnTypes}   ${destBank}  ${boolean[1]}   ${paymode}  ${boolean[1]}
    ...   ${indianPaymodes2}   ${boolean[1]}   ${internationalPaymodes}  ${splitPayment}   ${destBanks}   ${fromBank}

    ${profiles1}=  Setting Payment Profile  ${resp}   ${resp1}
    
    ${combined_json}=  Payment Profile Json  ${profiles1}  
    
    ${payment_profile}=  payment_profiles   ${combined_json}  ${pid}
    
    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME191}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get payment profile By Id    ${id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()['profileId']}                                ${id}
    Should Be Equal As Strings  ${resp.json()['indiaPay']}                                 ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['internationalPay']}                         ${bool[1]}
    
    ${resp}=   Get payment profile By Id    ${id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()['profileId']}                                ${id1}
    Should Be Equal As Strings  ${resp.json()['indiaPay']}                                 ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['internationalPay']}                         ${bool[1]}


JD-TC-GetPaymentProfileById-UH1

    [Documentation]  try to get another payment profile by id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get payment profile By Id    ${id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_PAYMENT_PROFILE_ID}


JD-TC-GetPaymentProfileById-UH2

    [Documentation]  get payment profile without login.
    
    ${resp}=   Get payment profile By Id    ${id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-GetPaymentProfileById-UH3

    [Documentation]  try to get payment profile by invalid id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get payment profile By Id    00000
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_PAYMENT_PROFILE_ID}


JD-TC-GetPaymentProfileById-UH4

    [Documentation]  try to get payment profile by consumer login.

    ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get payment profile By Id    ${id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}
