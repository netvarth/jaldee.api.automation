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
@{multiples}    10  21  20  30   40   50

*** Test Cases ***

JD-TC-AssignProfileToService-1

    [Documentation]  Assign profile to a service.
    
    clear_queue    ${PUSERNAME188}
    clear_service  ${PUSERNAME188}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME188}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME188}
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

    ${resp}=   Create Bank Details   ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME120}         
    ...   razorpayMerchantId=rzp_test_tD0hiOsaNEJfpk   razorpayMerchantKey=anvXiqqxugTK3JBOlBNTONEY   razorpayWebhookMerchantKey=abcd     
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${bank_id1}  ${resp.json()}

    ${resp}=   Get Bank Details By Id   ${bank_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${GST_num1}  ${pan_num1}=   db.Generate_gst_number   ${Container_id}
    ${ifsc_code1}=   db.Generate_ifsc_code
    ${bank_ac1}=   db.Generate_random_value  size=11   chars=${digits} 
    ${bank_name1}=  FakerLibrary.company
    ${name1}=  FakerLibrary.name
    ${branch1}=   db.get_place
  
    ${resp}=   Create Bank Details   ${bank_name1}  ${bank_ac1}   ${ifsc_code1}  ${name1}  ${name1}  ${branch1}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num1}  ${PUSERNAME130}         
    ...   razorpayMerchantId=rzp_test_tD00hiOsaNEJfpk   razorpayMerchantKey=anvXiqqxugTK3JBOlBNTONEY1   razorpayWebhookMerchantKey=abcd1     
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${bank_id11}  ${resp.json()}

    ${resp}=   Get Bank Details By Id   ${bank_id11} 
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

    ${indianPaymodes2}=   Create Dictionary   mode=${payment_modes[5]}   gateway=${gateway}   modeDisplayName=${payment_modes[5]}   
    ...   gatewayMerchantId=${bank_id11}  gatewayFee=${gatewayFee}
    ${indianPaymodes2}=  Create List   ${indianPaymodes2}

    ${internationalPaymodes1}=   Create Dictionary   mode=${payment_modes[5]}   gateway=${gateway}   modeDisplayName=${payment_modes[5]}   
    ...   gatewayMerchantId=${bank_id1}  gatewayFee=${gatewayFee}
    ${internationalPaymodes}=  Create List    ${internationalPaymodes1}

    ${intern_paymds}=  Create List    []

    ${splitPayment}   Create List   no  2-way   3-way
    ${destBanks}=   Create Dictionary   bankID=${EMPTY}   payPct=50   fixedPctValueMin=3   fixedPctValueMax=5   fixed=${EMPTY}     
    ${destBanks}=  Create List   ${destBanks}
    ${fee}=   Create List   incl  excl
    ${fromBank}=   Create Dictionary   bankID=${EMPTY}   maxLimit=100000   fee=${fee}   

    ${resp}=   Payment Profile  ${id}  ${displayName}   ${desc}  ${type}  ${txnTypes}   ${destBank}  ${boolean[1]}   ${paymode}  ${boolean[1]}
    ...   ${indianPaymodes1}   ${boolean[1]}   ${internationalPaymodes}  ${splitPayment}   ${destBanks}   ${fromBank}
    
    ${id1}=  FakerLibrary.word
    Set Suite Variable   ${id1}
    ${resp1}=   Payment Profile  ${id1}  ${displayName}   ${desc}  ${type}  ${txnTypes}   ${destBank}  ${boolean[1]}   ${paymode}  ${boolean[1]}
    ...   ${indianPaymodes2}   ${boolean[1]}   ${intern_paymds}  ${splitPayment}   ${destBanks}   ${fromBank}

    ${profiles1}=  Setting Payment Profile  ${resp}   ${resp1}
    
    ${combined_json}=  Payment Profile Json  ${profiles1}  
    
    ${payment_profile}=  payment_profiles   ${combined_json}  ${pid}
    
    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME188}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get payment profile By Id    ${id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()['profileId']}                                ${id}
    Should Be Equal As Strings  ${resp.json()['indiaPay']}                                 ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['internationalPay']}                         ${bool[1]}
    
    ${SERVICE1}=    FakerLibrary.word
    Set Suite Variable   ${SERVICE1}
    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Suite Variable    ${ser_id1}    ${resp} 
    
    ${serviceids}=   Create List   ${ser_id1}
    ${resp}=   Assign Profile To Service   ${id}   ${serviceids}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
     
    ${resp}=   Get Service By Id  ${ser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentProfileId']}          ${id}


JD-TC-AssignProfileToService-2

    [Documentation]  Assign profile to multiple services.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME188}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${Total1}=  Convert To Number  ${servicecharge}  1 
    ${amt_float}=  twodigitfloat  ${Total1}
    ${duration}=  Random Int  min=1  max=5

    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${duration}  ${status[0]}    ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${Total1}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${ser_id2}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    ${min_pre2}=   Random Int   min=1   max=50
    ${servicecharge2}=   Random Int  min=100  max=500
    ${Total2}=  Convert To Number  ${servicecharge2}  1 
    ${amt_float2}=  twodigitfloat  ${Total2}
    ${duration1}=  Random Int  min=1  max=5

    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${duration1}  ${status[0]}    ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre2}  ${Total2}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${ser_id3}  ${resp.json()}
    
    ${serviceids}=   Create List   ${ser_id2}  ${ser_id3}
    ${resp}=   Assign Profile To Service   ${id}   ${serviceids} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
     
    ${resp}=   Get Service By Id  ${ser_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentProfileId']}          ${id}

    ${resp}=   Get Service By Id  ${ser_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentProfileId']}          ${id}


JD-TC-AssignProfileToService-3

    [Documentation]  Assign profile to a service after updating jaldee bank to my own bank.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME188}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${P1SERVICE3}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre3}=   Random Int   min=1   max=50
    ${servicecharge3}=   Random Int  min=100  max=500
    ${Total3}=  Convert To Number  ${servicecharge3}  1 
    ${amt_float3}=  twodigitfloat  ${Total3}
    ${duration3}=  Random Int  min=1  max=5

    ${resp}=  Create Service  ${P1SERVICE3}  ${desc}   ${duration3}  ${status[0]}    ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre3}  ${Total3}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${ser_id4}  ${resp.json()}

    ${resp}=   Update Destination Bank  ${id}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Bank Details
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${serviceids}=   Create List   ${ser_id4}  
    ${resp}=   Assign Profile To Service   ${id}   ${serviceids} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
     
    ${resp}=   Get Service By Id  ${ser_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentProfileId']}          ${id}

JD-TC-AssignProfileToService-4

    [Documentation]  try to assign same profile to services multiple times.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME188}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${serviceids}=   Create List   ${ser_id2}  ${ser_id3}
    ${resp}=   Assign Profile To Service   ${id}   ${serviceids} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Service By Id  ${ser_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentProfileId']}          ${id}
    
    ${resp}=   Get Service By Id  ${ser_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentProfileId']}          ${id}

JD-TC-AssignProfileToService-5

    [Documentation]   update payment profile of a service.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME188}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${serviceids}=   Create List   ${ser_id2}  
    ${resp}=   Assign Profile To Service   ${id1}   ${serviceids} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Service By Id  ${ser_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentProfileId']}          ${id1}
  
    ${resp}=   Get Service By Id  ${ser_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentProfileId']}          ${id}

JD-TC-AssignProfileToService-6

    [Documentation]  assign profile to a disabled service.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME188}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable service  ${ser_id4} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${serviceids}=   Create List   ${ser_id4}  
    ${resp}=   Assign Profile To Service   ${id}   ${serviceids} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
     
    ${resp}=   Get Service By Id  ${ser_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentProfileId']}          ${id}
    Should Be Equal As Strings  ${resp.json()['status']}                    ${status[1]}


JD-TC-AssignProfileToService-7

    [Documentation]  Assign profile to a virtual service.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME188}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Set Test Variable  ${callingMode1}     ${CallingModes[1]}
    Set Test Variable  ${ModeId1}          ${PUSERNAME48}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Description1}=    FakerLibrary.sentence
    ${VScallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes1}=  Create List  ${VScallingMode1}

    ${Total1}=   Random Int   min=100   max=500
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE1}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[0]}

    ${resp}=  Create virtual Service  ${SERVICE1}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${Total1}  ${bool[0]}   ${bool[0]}   ${vstype}   ${virtualCallingModes1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${serviceids}=   Create List   ${s_id}  
    ${resp}=   Assign Profile To Service   ${id}   ${serviceids} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
     
    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentProfileId']}          ${id}


JD-TC-AssignProfileToService-8

    [Documentation]  Assign profile to a donation service.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME188}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${description}=  FakerLibrary.sentence
    ${min_don_amt1}=   Random Int   min=100   max=500
    ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
    ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
    ${max_don_amt1}=   Random Int   min=5000   max=10000
    ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
    ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
    ${min_don_amt}=  Convert To Number  ${min_don_amt}  1
    ${max_don_amt}=  Convert To Number  ${max_don_amt}  1
    ${service_duration}=   Random Int   min=10   max=50
    ${SERVICE1}=   FakerLibrary.name

    ${resp}=  Create Donation Service  ${SERVICE1}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}   ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${s_id1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${serviceids}=   Create List   ${s_id1}  
    ${resp}=   Assign Profile To Service   ${id}   ${serviceids} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
     
    ${resp}=   Get Service By Id  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentProfileId']}          ${id}
    
    
JD-TC-AssignProfileToService-UH1

    [Documentation]  try to assign profile for another providers service who does not have payment profile.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${serviceids}=   Create List   ${ser_id2}
    ${resp}=   Assign Profile To Service   ${id}   ${serviceids}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${NO_PAYMENT_PROFILE_FOUND}


JD-TC-AssignProfileToService-UH2

    [Documentation]  try to assign profile for another providers service who has payment profile.

    clear_queue    ${PUSERNAME189}
    clear_service  ${PUSERNAME189}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME189}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid1}=  get_acc_id  ${PUSERNAME189}
    Set Suite Variable   ${pid1}
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${ifsc_code}=   db.Generate_ifsc_code
    ${bank_ac}=   db.Generate_random_value  size=11   chars=${digits} 
    ${bank_name}=  FakerLibrary.company
    ${name}=  FakerLibrary.name
    ${branch}=   db.get_place

    ${resp}=   Create Bank Details   ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME125}         
    ...   razorpayMerchantId=rzp_test_tD0hiOsaNEJfpk   razorpayMerchantKey=anvXiqqxugTK3JBOlBNTONEY   razorpayWebhookMerchantKey=abcd     
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${bank_id2}  ${resp.json()}

    ${resp}=   Get Bank Details By Id   ${bank_id2} 
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
    ...   gatewayMerchantId=${bank_id2}  gatewayFee=${gatewayFee}
    ${indianPaymodes1}=  Create List   ${indianPaymodes1}

    ${internationalPaymodes1}=   Create Dictionary   mode=${payment_modes[5]}   gateway=${gateway}   modeDisplayName=${payment_modes[5]}   
    ...   gatewayMerchantId=${bank_id2}  gatewayFee=${gatewayFee}
    ${internationalPaymodes}=  Create List    ${internationalPaymodes1}

    ${splitPayment}   Create List   no  2-way   3-way
    ${destBanks}=   Create Dictionary   bankID=${EMPTY}   payPct=50   fixedPctValueMin=3   fixedPctValueMax=5   fixed=${EMPTY}     
    ${destBanks}=  Create List   ${destBanks}
    ${fee}=   Create List   incl  excl
    ${fromBank}=   Create Dictionary   bankID=${EMPTY}   maxLimit=100000   fee=${fee}   
    
    ${id1}=  FakerLibrary.word
    ${resp}=   Payment Profile  ${id1}  ${displayName}   ${desc}  ${type}  ${txnTypes}   ${destBank}  ${boolean[1]}   ${paymode}  ${boolean[1]}
    ...   ${indianPaymodes1}   ${boolean[1]}   ${internationalPaymodes}  ${splitPayment}   ${destBanks}   ${fromBank}

    ${profiles1}=  Setting Payment Profile  ${resp} 
    
    ${combined_json}=  Payment Profile Json  ${profiles1}  
    
    ${payment_profile}=  payment_profiles   ${combined_json}  ${pid1}
    
    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME189}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get payment profile By Id    ${id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${serviceids}=   Create List   ${ser_id2}
    ${resp}=   Assign Profile To Service   ${id}   ${serviceids}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${NO_PAYMENT_PROFILE_FOUND}

JD-TC-AssignProfileToService-UH3

    [Documentation]  Assign payment profile to service without login.
    
    ${serviceids}=   Create List   ${ser_id2}
    ${resp}=   Assign Profile To Service   ${id}   ${serviceids}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-AssignProfileToService-UH4

    [Documentation]  assign profile with empty list of service ids.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${serviceids}=   Create List   
    ${resp}=   Assign Profile To Service   ${id}   ${serviceids}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${NO_PAYMENT_PROFILE_FOUND}


JD-TC-AssignProfileToService-UH5

    [Documentation]  Assign profile to an invalid service.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME188}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${serviceids}=   Create List    0000  
    ${resp}=   Assign Profile To Service   ${id}   ${serviceids}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${NO_PAYMENT_PROFILE_FOUND}


JD-TC-AssignProfileToService-UH6

    [Documentation]  Assign profile to a service by consumer login.

    ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${serviceids}=   Create List   ${ser_id2}
    ${resp}=   Assign Profile To Service   ${id}   ${serviceids}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

    