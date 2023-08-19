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
${self}               customizedJBProfile
@{provider_list}
${start}              140
${jcoupon1}   CouponMul00
${id}            spDefaultProfile
${displayName}   SP Default Payment Profile
${id1}            spDefaultProfile1
${displayName1}   SP Default Payment Profile1
${chargeConsumer}    GatewayAPi

*** Test Cases ***
JD-TC-UpdateDestinationBank-

    [Documentation]  Update destination bank as jaldee bank.

    ${resp}=  ProviderLogin  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${pid}=  get_acc_id  ${PUSERNAME160}
    Set Suite Variable  ${pid}

    ${resp}=   Get payment profiles  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${id}  ${resp.json()[0]['profileId']}
    
    ${desc}=  FakerLibrary.word
    ${type}=  Create List   onlinePay   bank2bank 
    ${txnTypes}=   Create List   any
    
    ${paymode}=  Create List   any
    ${gateway}=  Create List   RAZORPAY
    ${chargeConsumer}=  Create List   ${chargeConsumer}
    # ${gatewayFee}=   Create Dictionary   chargeConsumer=${chargeConsumer}   fixedPctValue=0   fixedAmountValue=0  fixedPctValueMax=0  fixedPctValueMin=0
    
    ${splitPayment}   Create List   no  2-way   3-way
    ${destBanks}=   Create Dictionary   bankID=${EMPTY}   payPct=50   fixedPctValueMin=3   fixedPctValueMax=5   fixed=${EMPTY}     
    ${destBanks}=  Create List   ${destBanks}
    ${fee}=   Create List   incl  excl
    ${fromBank}=   Create Dictionary   bankID=${EMPTY}   maxLimit=100000   fee=${fee}  


    ${chargeConsumer}=  Create List   fixedAmount
    ${convenienceFee}=   Create Dictionary   chargeConsumer=${chargeConsumer}   fixedAmountValue=50   fixedPctValue=0  

    ${destBank}=  Create List   JALDEE
    ${chargeConsumer}=  Create List   fixedAmount
    ${convenienceFee}=   Create Dictionary   chargeConsumer=${chargeConsumer}   fixedAmountValue=50   fixedPctValue=0  

    ${chargeConsumer}=  Create List   NO
    ${gatewayFee}=   Create Dictionary    fixedPctValue=0    chargeConsumer=${chargeConsumer}    fixedAmountValue=0  fixedPctValueMax=0  fixedPctValueMin=0

    ${indianPaymodes1}=   Create Dictionary   mode=${payment_modes[5]}   gatewayFee=${gatewayFee}   
    ${indianPaymodes1}=  Create List   ${indianPaymodes1}
    ${internationalPaymodes1}=   Create Dictionary   mode=${payment_modes[5]}   gatewayFee=${gatewayFee}
    ${internationalPaymodes}=  Create List    ${internationalPaymodes1}
    ${resp}=   Create Dictionary    id=customizedJBProfile    destBank=${destBank}    indiaPay=${boolean[1]}    displayName=Jaldee Bank Payment Profile   convenienceFee=${convenienceFee}   indianPaymodes=${indianPaymodes1}    internationalPay=${boolean[1]}    internationalPaymodes=${internationalPaymodes}
    Log  ${resp}
    # ${resp1}=   Create List   ${resp} 

    # ${paymentProfiles}=    Create Dictionary    paymentProfiles=${resp}
    # Log  ${paymentProfiles}
    ${resp1}=   Create Dictionary    id=secondJBProfile    destBank=${destBank}    indiaPay=${boolean[1]}    displayName=Second Jaldee Bank Payment Profile      indianPaymodes=${indianPaymodes1}    internationalPay=${boolean[1]}    internationalPaymodes=${internationalPaymodes}
    Log  ${resp1}
    ${profiles}=  Setting Payment Profile  ${resp}   ${resp1}
    
    ${combined_json}=  Payment Profile Json  ${profiles}   
    
    ${payment_profile}=  payment_profiles   ${combined_json}  ${pid}

    ${resp}=  razorpayVerify  ${pid}
    Log  ${resp}

    ${resp}=   Get payment profiles  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Bank Details  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  ProviderLogin  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    

    ${resp}=   Update Destination Bank  secondJBProfile  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get payment profile By Id    secondJBProfile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Bank Details
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    # Should Be Equal As Strings  ${resp.json()[0]['accountId']}                 ${pid}
    # Should Be Equal As Strings  ${resp.json()[0]['bankId']}                    ${pid}

    # Should Be Equal As Strings  ${resp.json()[1]['accountId']}                 ${pid}
    # # Should Be Equal As Strings  ${resp.json()[1]['bankId']}                    ${bank_id1}
    # Should Be Equal As Strings  ${resp.json()[1]['payTmLinkedPhoneNumber']}    ${PUSERNAME160}
    # Should Be Equal As Strings  ${resp.json()[1]['panCardNumber']}             ${pan_num}
    # Should Be Equal As Strings  ${resp.json()[1]['bankAccountNumber']}         ${bank_ac}
    # Should Be Equal As Strings  ${resp.json()[1]['payTmVerified']}             ${bool[0]}
    # Should Be Equal As Strings  ${resp.json()[1]['branchCity']}                ${branch}
    # Should Be Equal As Strings  ${resp.json()[1]['businessFilingStatus']}      ${businessFilingStatus[1]}
    # Should Be Equal As Strings  ${resp.json()[1]['accountType']}               ${accountType[1]}

JD-TC-UpdateDestinationBank-1

    [Documentation]  Update destination bank as my own bank.

    ${resp}=  ProviderLogin  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${pid}=  get_acc_id  ${PUSERNAME160}
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

    ${resp}=   Create Bank Details   ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME160}         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${bank_id1}  ${resp.json()}

    ${resp}=   Get Bank Details By Id   ${bank_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()['accountId']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()['bankId']}                    ${bank_id1}
    Should Be Equal As Strings  ${resp.json()['payTmLinkedPhoneNumber']}    ${PUSERNAME160}
    Should Be Equal As Strings  ${resp.json()['panCardNumber']}             ${pan_num}
    Should Be Equal As Strings  ${resp.json()['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()['payTmVerified']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()['accountType']}               ${accountType[1]}

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

    ${resp1}=   Payment Profile  ${id1}  ${displayName1}   ${desc}  ${type}  ${txnTypes}   ${destBank}  ${boolean[1]}   ${paymode}  ${boolean[1]}
    ...   ${indianPaymodes1}   ${boolean[1]}   ${internationalPaymodes}  ${splitPayment}   ${destBanks}   ${fromBank}
    
    ${profiles1}=  Setting Payment Profile  ${resp}   ${resp1}
    
    ${combined_json}=  Payment Profile Json  ${profiles1}  
    
    ${payment_profile}=  payment_profiles   ${combined_json}  ${pid}
    
    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  ProviderLogin  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get payment profile By Id    ${id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Update Destination Bank  ${id}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Bank Details
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['bankId']}                    ${pid}

    Should Be Equal As Strings  ${resp.json()[1]['accountId']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['bankId']}                    ${bank_id1}
    Should Be Equal As Strings  ${resp.json()[1]['payTmLinkedPhoneNumber']}    ${PUSERNAME160}
    Should Be Equal As Strings  ${resp.json()[1]['panCardNumber']}             ${pan_num}
    Should Be Equal As Strings  ${resp.json()[1]['bankAccountNumber']}         ${bank_ac}
    Should Be Equal As Strings  ${resp.json()[1]['payTmVerified']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[1]['branchCity']}                ${branch}
    Should Be Equal As Strings  ${resp.json()[1]['businessFilingStatus']}      ${businessFilingStatus[1]}
    Should Be Equal As Strings  ${resp.json()[1]['accountType']}               ${accountType[1]}


JD-TC-UpdateDestinationBank-2

    [Documentation]  Update destination bank from my own bank to jaldee bank.
    
    ${resp}=  ProviderLogin  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get payment profiles 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  ProviderLogin  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Destination Bank  ${id1}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Bank Details
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-UpdateDestinationBank-3

    [Documentation]  Update destination bank as jaldee bank then get payment profile.

    ${resp}=  ProviderLogin  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get payment profiles 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()}   []

JD-TC-UpdateDestinationBank-4

    [Documentation]  Update destination bank as my own bank then get payment profile.

    ${resp}=  ProviderLogin  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get payment profiles 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Update Destination Bank  ${id}  ${bool[1]}  
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

JD-TC-UpdateDestinationBank-5

    [Documentation]  update destination bank as jaldee bank itself.
    
    ${resp}=  ProviderLogin  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get payment profiles 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=   Get Bank Details
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Update Destination Bank  ${id}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Update Destination Bank  ${id}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Should Be Equal As Strings  ${resp.json()}   ${ALREADY_SET_JALDEE_BANK}


JD-TC-UpdateDestinationBank-UH2

    [Documentation]  update destination bank without login.

    ${resp}=   Update Destination Bank  ${id}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-UpdateDestinationBank-UH3

    [Documentation]  update destination bank by consumer login.
    
    ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Destination Bank  ${id}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-UpdateDestinationBank-UH4

    [Documentation]  update destination bank by invalid bank id.
    
    ${resp}=  ProviderLogin  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Destination Bank  00000  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_PROFILE_ID}


JD-TC-UpdateDestinationBank-UH5

    [Documentation]  update destination bank without passing bank id.
    
    ${resp}=  ProviderLogin  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Destination Bank  ${EMPTY}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_PROFILE_ID}


JD-TC-UpdateDestinationBank-UH6

    [Documentation]  update destination bank by passing another providers bank id.
    
    ${resp}=  ProviderLogin  ${PUSERNAME130}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Destination Bank  ${id}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_PROFILE_ID}

