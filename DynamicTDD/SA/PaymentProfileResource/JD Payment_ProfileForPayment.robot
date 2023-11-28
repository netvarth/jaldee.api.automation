*** Settings ***
Test Teardown     Delete All Sessions
Suite Teardown    Delete All Sessions
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

*** Keywords ***
Get payment modes
    [Arguments]  ${accountId}   ${serviceId}   ${paymentPurpose}
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /consumer/payment/modes/service/${accountId}/${serviceId}/${paymentPurpose}    expected_status=any
    [Return]  ${resp}

Get convenienceFee Details 
    [Arguments]  ${accountId}     ${profileId}    ${amount}
    ${data}=    Create Dictionary    profileId=${profileId}  amount=${amount}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=   PUT On Session  ynw  /consumer/payment/modes/convenienceFee/${accountId}   data=${data}   expected_status=any
    [Return]  ${resp}

PP For Default PP
    [Arguments]   ${acc_id}  ${jaldeeBank}    &{kwargs}
    ${items}=  Get Dictionary items  ${kwargs}
    ${data}=   Create Dictionary    jaldeeBank=${jaldeeBank}   
    # defaultPaymentProfileId=${defaultPaymentProfileId}  
    FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    Check And Create YNW SuperAdmin Session
    ${resp}=   PUT On Session  synw  url=/payment/advancePayBank?accountId=${acc_id}    expected_status=any
    [Return]  ${resp}


*** Variables ***
${digits}       0123456789
${id2}            spDefaultProfile
${displayName}   Default Payment Profile1
${id1}            spDefaultProfile1
${displayName1}   Default Payment Profile2
${chargeConsumer}    GatewayAPi
${parallel}           1
${self}               0
@{provider_list}
${tz}   Asia/Kolkata

*** Test Cases ***

JD-TC-PaymentProfileForPayment---1

    [Documentation]  Set payment profile from SA with adv bank jaldee bank.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME155}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get payment profiles  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${id}  ${resp.json()[0]['profileId']}

    ${pid}=  get_acc_id  ${PUSERNAME155}
    Set Suite Variable   ${pid}
    
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

    ${indianPaymodes1}=   Create Dictionary   mode=${payment_modes[5]}   gatewayFee=${gatewayFee}    mode=${payment_modes[1]}   gatewayFee=${gatewayFee}
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

    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME155}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  razorpayVerify  ${pid}
    Log  ${resp}

    ${resp}=   Update Destination Bank   customizedJBProfile   ${bool[1]}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get payment profiles  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Bank Details  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Update Destination Bank  ${bank_id1}  ${bool[0]}  
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    

    # ${resp}=   Get Bank Details By Id  ${bank_id1}  
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[0]}  advancePaymentProfileId=customizedJBProfile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME155}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=150   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   
    ${ser_duratn}=   Random Int   min=10   max=30

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_duratn}  ${status[0]}   ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  1  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME16}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 

    ${resp}=  ConsumerLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get convenienceFee Details     ${pid}    ${id}   ${min_pre1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get payment modes    ${pid}    ${s_id}    ${purpose[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['isJaldeeBank']}    ${bool[1]}
    Set Suite Variable    ${proid}  ${resp.json()[0]['profileId']}
     

    

    # ......Call Get Mode keyword

    # .....Set Profile id , payment settings id to a variable

    # ......Make payment with kwargs like profile id, payment settings id, payment gateway(RAZORPAY)



    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}   profileId=${proid}    paymentGateway=RAZORPAY    paymentSettingsId=1
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    # ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME155}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[7]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY}

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Encrypted Provider Login  ${PUSERNAME155}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    Set Test Variable  ${paymentPurpose-eq}      prePayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    
    ${cwid}=  Convert To String  ${cwid} 
    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-PaymentProfileForPayment---2

    [Documentation]  Set Default payment profile from SA with adv bank My own bank.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME165}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${pid}=  get_acc_id  ${PUSERNAME165}
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

    ${resp}=   Create Bank Details   ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME165}
    ...    razorpayMerchantId=rzp_test_tD0hiOsaNEJfpk   razorpayMerchantKey=anvXiqqxugTK3JBOlBNTONEY   razorpayWebhookMerchantKey=abcd         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${bank_id1}  ${resp.json()}

    ${resp}=   Get Bank Details By Id   ${bank_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  razorpayVerify  ${pid}
    Log  ${resp}

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


    ${chargeConsumer}=  Create List   fixedAmount
    ${convenienceFee}=   Create Dictionary   chargeConsumer=${chargeConsumer}   fixedAmountValue=50   fixedPctValue=0  



    ${resp}=   Payment Profile  ${id2}  ${displayName}   ${desc}  ${type}  ${txnTypes}   ${destBank}  ${boolean[1]}   ${paymode}  ${boolean[1]}
    ...   ${indianPaymodes1}   ${boolean[1]}   ${internationalPaymodes}  ${splitPayment}   ${destBanks}   ${fromBank}   
    #  convenienceFee=${convenienceFee}

    ${resp1}=   Payment Profile  ${id1}  ${displayName1}   ${desc}  ${type}  ${txnTypes}   ${destBank}  ${boolean[1]}   ${paymode}  ${boolean[1]}
    ...   ${indianPaymodes1}   ${boolean[1]}   ${internationalPaymodes}  ${splitPayment}   ${destBanks}   ${fromBank}    

    ${profiles}=  Setting Payment Profile  ${resp}  ${resp1} 
    
    ${combined_json}=  Payment Profile Json  ${profiles}   
    
    ${payment_profile}=  payment_profiles   ${combined_json}  ${pid}


    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME165}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Destination Bank  ${id2}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get payment profiles  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Bank Details By Id  ${bank_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[1]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME165}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=150   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   
    ${ser_duratn}=   Random Int   min=10   max=30

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_duratn}  ${status[0]}   ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  1  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME20}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 

    ${resp}=  ConsumerLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get convenienceFee Details     ${pid}    ${id}   ${min_pre1}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get payment modes    ${pid}    ${s_id}    ${purpose[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['isJaldeeBank']}    ${bool[0]}
    Set Suite Variable    ${proid}  ${resp.json()[0]['profileId']}
     

    

    # ......Call Get Mode keyword

    # .....Set Profile id , payment settings id to a variable

    # ......Make payment with kwargs like profile id, payment settings id, payment gateway(RAZORPAY)



    ${resp}=  Make payment Consumer Mock  ${pid}  ${Tot1}  ${purpose[1]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}  
    #  profileId=${id1}   paymentGateway=RAZORPAY   paymentSettingsId=1
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s


    ${resp}=  Encrypted Provider Login  ${PUSERNAME165}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[7]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${Tot1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY}

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  2s

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME165}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    # Set Test Variable  ${paymentPurpose-eq}      prePayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    
    ${cwid}=  Convert To String  ${cwid} 
    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  3s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-PaymentProfileForPayment---3

    [Documentation]  Set SP Specific PP from SA .

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get payment profiles  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${pid}=  get_acc_id  ${PUSERNAME152}
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

    ${resp}=   Create Bank Details   ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME152}
    ...    razorpayMerchantId=rzp_test_tD0hiOsaNEJfpk   razorpayMerchantKey=anvXiqqxugTK3JBOlBNTONEY   razorpayWebhookMerchantKey=abcd         
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${bank_id1}  ${resp.json()}

    ${resp}=   Get Bank Details By Id   ${bank_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  razorpayVerify  ${pid}
    Log  ${resp}

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


    ${chargeConsumer}=  Create List   fixedAmount
    ${convenienceFee}=   Create Dictionary   chargeConsumer=${chargeConsumer}   fixedAmountValue=50   fixedPctValue=0  



    ${resp}=   Payment Profile  ${id2}  ${displayName}   ${desc}  ${type}  ${txnTypes}   ${destBank}  ${boolean[1]}   ${paymode}  ${boolean[1]}
    ...   ${indianPaymodes1}   ${boolean[1]}   ${internationalPaymodes}  ${splitPayment}   ${destBanks}   ${fromBank}   
    #  convenienceFee=${convenienceFee}

    ${resp1}=   Payment Profile  ${id1}  ${displayName1}   ${desc}  ${type}  ${txnTypes}   ${destBank}  ${boolean[1]}   ${paymode}  ${boolean[1]}
    ...   ${indianPaymodes1}   ${boolean[1]}   ${internationalPaymodes}  ${splitPayment}   ${destBanks}   ${fromBank}    

    ${profiles}=  Setting Payment Profile  ${resp}  ${resp1} 
    
    ${combined_json}=  Payment Profile Json  ${profiles}   
    
    ${payment_profile}=  payment_profiles   ${combined_json}  ${pid}

    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Destination Bank  ${id1}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get payment profiles  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Bank Details By Id  ${bank_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[2]}   advancePaymentProfileId=${id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=150   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   
    ${ser_duratn}=   Random Int   min=10   max=30

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_duratn}  ${status[0]}   ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  1  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME18}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 

    ${resp}=  ConsumerLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get convenienceFee Details     ${pid}    ${id}   ${min_pre1}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get payment modes    ${pid}    ${s_id}    ${purpose[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['isJaldeeBank']}    ${bool[0]}
    Set Suite Variable    ${proid}  ${resp.json()[0]['profileId']}
     

    

    # ......Call Get Mode keyword

    # .....Set Profile id , payment settings id to a variable

    # ......Make payment with kwargs like profile id, payment settings id, payment gateway(RAZORPAY)



    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}   profileId=${id1}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[7]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY}

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  2s

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    Set Test Variable  ${paymentPurpose-eq}      prePayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    
    ${cwid}=  Convert To String  ${cwid} 
    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  3s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-PaymentProfileForPayment---4

    [Documentation]  Set SERVICE_SPECIFIC Payment profile from SA . 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get payment profiles  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${pid}=  get_acc_id  ${PUSERNAME152}
    Set Suite Variable   ${pid}
    
    # ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    # Set Suite Variable  ${pan_num}
    # Set Suite Variable  ${GST_num}
    # ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    
    # ${resp}=  Enable Tax
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    
    # ${ifsc_code}=   db.Generate_ifsc_code
    # Set Suite Variable  ${ifsc_code}
    # ${bank_ac}=   db.Generate_random_value  size=11   chars=${digits} 
    # Set Suite Variable  ${bank_ac}
    # ${bank_name}=  FakerLibrary.company
    # Set Suite Variable  ${bank_name}
    # ${name}=  FakerLibrary.name
    # Set Suite Variable  ${name}
    # ${branch}=   db.get_place
    # Set Suite Variable  ${branch}

    # ${resp}=   Create Bank Details   ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME152}
    # ...    razorpayMerchantId=rzp_test_tD0hiOsaNEJfpk   razorpayMerchantKey=anvXiqqxugTK3JBOlBNTONEY   razorpayWebhookMerchantKey=abcd         
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    # Set Suite Variable  ${bank_id1}  ${resp.json()}

    # ${resp}=   Get Bank Details By Id   ${bank_id1} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=  razorpayVerify  ${pid}
    # Log  ${resp}

    # ${desc}=  FakerLibrary.word
    # ${type}=  Create List   onlinePay   bank2bank 
    # ${txnTypes}=   Create List   any
    # ${destBank}=  Create List   OWN
    # ${paymode}=  Create List   any
    # ${gateway}=  Create List   RAZORPAY
    # ${chargeConsumer}=  Create List   ${chargeConsumer}
    # ${gatewayFee}=   Create Dictionary   chargeConsumer=${chargeConsumer}   fixedPctValue=0   fixedAmountValue=0  fixedPctValueMax=0  fixedPctValueMin=0
    # ${indianPaymodes1}=   Create Dictionary   mode=${payment_modes[5]}   gateway=${gateway}   modeDisplayName=${payment_modes[5]}   
    # ...   gatewayMerchantId=${bank_id1}  gatewayFee=${gatewayFee}
    # ${indianPaymodes1}=  Create List   ${indianPaymodes1}

    # ${internationalPaymodes1}=   Create Dictionary   mode=${payment_modes[5]}   gateway=${gateway}   modeDisplayName=${payment_modes[5]}   
    # ...   gatewayMerchantId=${bank_id1}  gatewayFee=${gatewayFee}
    # ${internationalPaymodes}=  Create List    ${internationalPaymodes1}

    # ${splitPayment}   Create List   no  2-way   3-way
    # ${destBanks}=   Create Dictionary   bankID=${EMPTY}   payPct=50   fixedPctValueMin=3   fixedPctValueMax=5   fixed=${EMPTY}     
    # ${destBanks}=  Create List   ${destBanks}
    # ${fee}=   Create List   incl  excl
    # ${fromBank}=   Create Dictionary   bankID=${EMPTY}   maxLimit=100000   fee=${fee}  


    # ${chargeConsumer}=  Create List   fixedAmount
    # ${convenienceFee}=   Create Dictionary   chargeConsumer=${chargeConsumer}   fixedAmountValue=50   fixedPctValue=0  



    # ${resp}=   Payment Profile  ${id}  ${displayName}   ${desc}  ${type}  ${txnTypes}   ${destBank}  ${boolean[1]}   ${paymode}  ${boolean[1]}
    # ...   ${indianPaymodes1}   ${boolean[1]}   ${internationalPaymodes}  ${splitPayment}   ${destBanks}   ${fromBank}   
    # #  convenienceFee=${convenienceFee}

    # ${resp1}=   Payment Profile  ${id1}  ${displayName1}   ${desc}  ${type}  ${txnTypes}   ${destBank}  ${boolean[1]}   ${paymode}  ${boolean[1]}
    # ...   ${indianPaymodes1}   ${boolean[1]}   ${internationalPaymodes}  ${splitPayment}   ${destBanks}   ${fromBank}    

    # ${profiles}=  Setting Payment Profile  ${resp}  ${resp1} 
    
    # ${combined_json}=  Payment Profile Json  ${profiles}   
    
    # ${payment_profile}=  payment_profiles   ${combined_json}  ${pid}

    # ${resp}=   ProviderLogout
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Update Destination Bank  ${id1}  ${bool[0]}  
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=   Get payment profiles  
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Bank Details By Id  ${bank_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[3]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=150   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   
    ${ser_duratn}=   Random Int   min=10   max=30

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_duratn}  ${status[0]}   ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}  bankType=${bankType[3]}  paymentProfileId=${id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  1  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME19}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 

    ${resp}=  ConsumerLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get convenienceFee Details     ${pid}    ${id2}   ${min_pre1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get payment modes    ${pid}    ${s_id}    ${purpose[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['isJaldeeBank']}    ${bool[0]}
    Set Suite Variable    ${proid}  ${resp.json()[0]['profileId']}
     

    

    # ......Call Get Mode keyword

    # .....Set Profile id , payment settings id to a variable

    # ......Make payment with kwargs like profile id, payment settings id, payment gateway(RAZORPAY)



    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}    
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    # ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[7]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY}

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  2s
    
    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    Set Test Variable  ${paymentPurpose-eq}      prePayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    
    ${cwid}=  Convert To String  ${cwid} 
    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-PaymentProfileForPayment---5

    [Documentation]  Set a Jaldee bank Payment profile for a provider by SA and do a bill payment.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME155}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get payment profiles  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${id}  ${resp.json()[0]['profileId']}

    ${pid}=  get_acc_id  ${PUSERNAME155}
    Set Suite Variable   ${pid}

    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[0]}  advancePaymentProfileId=customizedJBProfile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME155}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=150   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   
    ${ser_duratn}=   Random Int   min=10   max=30

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_duratn}  ${status[0]}   ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  1  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME16}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 

    ${resp}=  ConsumerLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get convenienceFee Details     ${pid}    ${id}   ${min_pre1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get payment modes    ${pid}    ${s_id}    ${purpose[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['isJaldeeBank']}    ${bool[1]}
    Set Suite Variable    ${proid}  ${resp.json()[0]['profileId']}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${Tot1}  ${purpose[1]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}   profileId=${proid}    paymentGateway=RAZORPAY    paymentSettingsId=1
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    

    ${resp}=  Encrypted Provider Login  ${PUSERNAME155}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId    ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[7]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${Tot1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY}

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  2s

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME155}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    Set Test Variable  ${paymentPurpose-eq}      billPayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    
    ${cwid}=  Convert To String  ${cwid} 
    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-PaymentProfileForPayment---6

    [Documentation]  Set a default Payment profile for a provider by SA and do a bill payment.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get payment profiles  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${pid}=  get_acc_id  ${PUSERNAME150}
    Set Suite Variable   ${pid}


    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[1]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=150   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   
    ${ser_duratn}=   Random Int   min=10   max=30

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_duratn}  ${status[0]}   ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  1  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME16}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 

    ${resp}=  ConsumerLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get convenienceFee Details     ${pid}    ${id}   ${min_pre1}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get payment modes    ${pid}    ${s_id}    ${purpose[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['isJaldeeBank']}    ${bool[1]}
    Set Suite Variable    ${proid}  ${resp.json()[0]['profileId']}
     
    ${resp}=  Make payment Consumer Mock  ${pid}  ${Tot1}  ${purpose[1]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}   profileId=${proid}    paymentGateway=RAZORPAY   paymentSettingsId=1 
    # paymentSettingsId=0
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId   ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[7]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${Tot1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY}

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    Set Test Variable  ${paymentPurpose-eq}      billPayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    
    ${cwid}=  Convert To String  ${cwid} 
    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-PaymentProfileForPayment---7

    [Documentation]  Set a SP Specific  Payment profile for a provider by SA and do a bill payment.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get payment profiles  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${pid}=  get_acc_id  ${PUSERNAME152}
    Set Suite Variable   ${pid}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[3]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=150   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   
    ${ser_duratn}=   Random Int   min=10   max=30

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_duratn}  ${status[0]}   ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}  bankType=${bankType[3]}  paymentProfileId=${id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  1  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME16}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 

    # ${resp}=  ConsumerLogout
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get convenienceFee Details     ${pid}    ${id2}   ${Tot1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get payment modes    ${pid}    ${s_id}    ${purpose[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['isJaldeeBank']}    ${bool[0]}
    Set Suite Variable    ${proid}  ${resp.json()[0]['profileId']}
     

    ${resp}=  Make payment Consumer Mock  ${pid}  ${Tot1}  ${purpose[1]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}    profileId=${id2}    paymentGateway=RAZORPAY  paymentSettingsId=1      
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    # ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId   ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[7]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${Tot1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY}

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    Set Test Variable  ${paymentPurpose-eq}     billPayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    
    ${cwid}=  Convert To String  ${cwid} 
    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-PaymentProfileForPayment---8

    [Documentation]  Create Service specific and set  for a provider by SA and do a bill payment.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get payment profiles  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${id}   ${resp.json()[0]['profileId']}

    ${pid}=  get_acc_id  ${PUSERNAME152}
    Set Suite Variable   ${pid}
    

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[3]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=150   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   
    ${ser_duratn}=   Random Int   min=10   max=30

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_duratn}  ${status[0]}   ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}  bankType=${bankType[3]}  paymentProfileId=${id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  1  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME16}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 

    ${resp}=  ConsumerLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get convenienceFee Details     ${pid}    ${id}   ${min_pre1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get payment modes    ${pid}    ${s_id}    ${purpose[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['isJaldeeBank']}    ${bool[0]}
    Set Suite Variable    ${proid}  ${resp.json()[0]['profileId']}

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}    
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId    ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[7]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY}

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${amountDue}   ${resp.json()['amountDue']}

    ${resp}=  Make payment Consumer Mock  ${pid}  ${amountDue}  ${purpose[1]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}    profileId=${id2}    paymentGateway=RAZORPAY     paymentSettingsId=1
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

     sleep  2s

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId    ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${cwid}
    Should Be Equal As Strings  ${resp.json()[1]['status']}  SUCCESS  
    # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[7]}
    Should Be Equal As Strings  ${resp.json()[1]['amount']}  ${amountDue}
    Should Be Equal As Strings  ${resp.json()[1]['paymentOn']}  ${DAY}

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${amountDue}   ${resp.json()['amountDue']}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    Set Test Variable  ${paymentPurpose-eq}      billPayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    
    ${cwid}=  Convert To String  ${cwid} 
    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

#Default Payment Payment -set from SA

JD-TC-PaymentProfileForPayment---9

    [Documentation]   Set Default Payment Payment as jaldee bank  for a provider by SA and do a bill payment.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME152}
    
    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   PP For Default PP      ${pid}   ${bool[1]}   defaultPaymentProfileId=customizedJBProfile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=150   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   
    ${ser_duratn}=   Random Int   min=10   max=30

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_duratn}  ${status[0]}   ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  1  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME16}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 

    ${tax1}=  Evaluate  ${Tot}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    Set Suite Variable    ${tax}
    ${totalamt}=  Evaluate  ${Tot}+${tax}
    ${amt_float}=  twodigitfloat  ${totalamt}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId    ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[7]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY}

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${amountDue}   ${resp.json()['amountDue']}

    # ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${amountDue}   ${resp.json()['amountDue']}

    ${resp}=  Make payment Consumer Mock  ${pid}  ${amountDue}  ${purpose[1]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId    ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${cwid}
    Should Be Equal As Strings  ${resp.json()[1]['status']}  SUCCESS  
    # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[7]}
    Should Be Equal As Strings  ${resp.json()[1]['amount']}  ${amountDue}
    Should Be Equal As Strings  ${resp.json()[1]['paymentOn']}  ${DAY}

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${amountDue}   ${resp.json()['amountDue']}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


    # ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    Set Test Variable  ${paymentPurpose-eq}      billPayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    
    # ${cwid}=  Convert To String  ${cwid} 
    # ${cwid1}=  Convert To String  ${cwid1} 
    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-PaymentProfileForPayment---10

    [Documentation]  Set Default Payment Profile as jaldee bank Profile for a provider by SA and do a bill payment.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME152}
    
    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   PP For Default PP      ${pid}   ${bool[1]}   defaultPaymentProfileId=secondJBProfile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=150   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   
    ${ser_duratn}=   Random Int   min=10   max=30

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_duratn}  ${status[0]}   ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  1  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME16}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 

    ${tax1}=  Evaluate  ${Tot}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    Set Suite Variable    ${tax}
    ${totalamt}=  Evaluate  ${Tot}+${tax}
    ${amt_float}=  twodigitfloat  ${totalamt}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId    ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[7]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY}

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${amountDue}   ${resp.json()['amountDue']}

    # ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${amountDue}   ${resp.json()['amountDue']}

    ${resp}=  Make payment Consumer Mock  ${pid}  ${amountDue}  ${purpose[1]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId    ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${cwid}
    Should Be Equal As Strings  ${resp.json()[1]['status']}  SUCCESS  
    # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[7]}
    Should Be Equal As Strings  ${resp.json()[1]['amount']}  ${amountDue}
    Should Be Equal As Strings  ${resp.json()[1]['paymentOn']}  ${DAY}

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${amountDue}   ${resp.json()['amountDue']}

    

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    # ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    Set Test Variable  ${paymentPurpose-eq}      billPayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    
    # ${cwid}=  Convert To String  ${cwid} 
    # ${cwid1}=  Convert To String  ${cwid1} 
    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    

JD-TC-PaymentProfileForPayment---11

    [Documentation]  Set Default Payment Profile as My OWN Bank  for a provider by SA and do a bill payment.
    

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME152}
    
    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   PP For Default PP      ${pid}   ${bool[0]}   defaultPaymentProfileId=${id2}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=150   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   
    ${ser_duratn}=   Random Int   min=10   max=30

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_duratn}  ${status[0]}   ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  1  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME16}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 

    ${tax1}=  Evaluate  ${Tot}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    Set Suite Variable    ${tax}
    ${totalamt}=  Evaluate  ${Tot}+${tax}
    ${amt_float}=  twodigitfloat  ${totalamt}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId    ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[7]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY}

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${amountDue}   ${resp.json()['amountDue']}

    # ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${amountDue}   ${resp.json()['amountDue']}

    ${resp}=  Make payment Consumer Mock  ${pid}  ${amountDue}  ${purpose[1]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId    ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${cwid}
    Should Be Equal As Strings  ${resp.json()[1]['status']}  SUCCESS  
    # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[7]}
    Should Be Equal As Strings  ${resp.json()[1]['amount']}  ${amountDue}
    Should Be Equal As Strings  ${resp.json()[1]['paymentOn']}  ${DAY}

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${amountDue}   ${resp.json()['amountDue']}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    Set Test Variable  ${paymentPurpose-eq}      prePayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY

    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-PaymentProfileForPayment---12

    [Documentation]  Set Default Payment Profile as My OWN Bank Payment Profile  for a provider by SA and do a bill payment.
    

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME152}

    ${resp}=   Get payment profiles  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${id1}   ${resp.json()[1]['profileId']}
    
    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   PP For Default PP      ${pid}   ${bool[0]}   defaultPaymentProfileId=${id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=150   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   
    ${ser_duratn}=   Random Int   min=10   max=30

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_duratn}  ${status[0]}   ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  1  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME16}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 

    ${tax1}=  Evaluate  ${Tot}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    Set Suite Variable    ${tax}
    ${totalamt}=  Evaluate  ${Tot}+${tax}
    ${amt_float}=  twodigitfloat  ${totalamt}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId    ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[7]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY}

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${amountDue}   ${resp.json()['amountDue']}

    # ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${amountDue}   ${resp.json()['amountDue']}

    ${resp}=  Make payment Consumer Mock  ${pid}  ${amountDue}  ${purpose[1]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${cwid}
    Should Be Equal As Strings  ${resp.json()[1]['status']}  SUCCESS  
    # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[7]}
    Should Be Equal As Strings  ${resp.json()[1]['amount']}  ${amountDue}
    Should Be Equal As Strings  ${resp.json()[1]['paymentOn']}  ${DAY}

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${amountDue}   ${resp.json()['amountDue']}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    # ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    Set Test Variable  ${paymentPurpose-eq}      prePayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    
    # ${cwid}=  Convert To String  ${cwid} 
    # ${cwid1}=  Convert To String  ${cwid1} 
    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Payment Bank Details    ${pid} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200





*** comment ***
JD-TC-PaymentProfileForPrepayment-2

    [Documentation]  Create multiple payment profile.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
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

    ${resp}=   Create Bank Details  ${bank_name1}  ${bank_ac1}  ${ifsc_code1}  ${name1}  ${name1}  ${branch1}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num1}  ${PUSERNAME121}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${bank_id3}  ${resp.json()}

    ${resp}=   Get Bank Details
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${desc}=  FakerLibrary.word
    ${type}=  Create List   onlinePay   bank2bank 
    ${txnTypes}=   Create List   any
    ${destBank}=  Create List   OWN
    ${paymode}=  Create List   any
    ${gateway}=  Create List   PAYTM
    ${chargeConsumer}=  Create List   ${chargeConsumer}
    ${gatewayFee}=   Create Dictionary   chargeConsumer=${chargeConsumer}   fixedPctValue=0   fixedAmountValue=0  fixedPctValueMax=0  fixedPctValueMin=0
    ${indianPaymodes1}=   Create Dictionary   mode=${payment_modes[5]}   gateway=${gateway}   modeDisplayName=${payment_modes[5]}   
    ...   gatewayMerchantId=${bank_id3}  gatewayFee=${gatewayFee}
    ${indianPaymodes1}=  Create List   ${indianPaymodes1}

    ${internationalPaymodes1}=   Create Dictionary   mode=${payment_modes[5]}   gateway=${gateway}   modeDisplayName=${payment_modes[5]}   
    ...   gatewayMerchantId=${bank_id3}  gatewayFee=${gatewayFee}
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
    ...   gatewayMerchantId=${3}  gatewayFee=${gatewayFee}
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
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Destination Bank  ${id}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get payment profiles  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

# *** comment ***

JD-TC-PaymentProfileForPrepayment-1

    [Documentation]  Set a Jaldee bank Payment profile for a provider by SA.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME89}
    
    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[0]}  advancePaymentProfileId=customizedJBProfile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=150   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   
    ${ser_duratn}=   Random Int   min=10   max=30

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_duratn}  ${status[0]}   ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  1  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME16}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[7]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY}

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid2}=  get_id  ${CUSERNAME17}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid1}  ${wid[0]} 
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    ${resp}=  Get Bill By consumer  ${cwid1}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get JaldeeBank Statement By Provider  ${DAY}  ${DAY1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    Set Test Variable  ${paymentPurpose-eq}      prePayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    
    ${cwid}=  Convert To String  ${cwid} 
    ${cwid1}=  Convert To String  ${cwid1} 
    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    


JD-TC-PaymentProfileForPrepayment-

    [Documentation]  Set Multiple Jaldee Bank PP for prepayment then Check By default prepayment goes to which profile.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME89}
    
    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[0]}  advancePaymentProfileId=customizedJBProfile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=150   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   
    ${ser_duratn}=   Random Int   min=10   max=30

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_duratn}  ${status[0]}   ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  1  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME16}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[7]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY}

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid2}=  get_id  ${CUSERNAME17}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid1}  ${wid[0]} 
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    ${resp}=  Get Bill By consumer  ${cwid1}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get JaldeeBank Statement By Provider  ${DAY}  ${DAY1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    Set Test Variable  ${paymentPurpose-eq}      prePayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    
    ${cwid}=  Convert To String  ${cwid} 
    ${cwid1}=  Convert To String  ${cwid1} 
    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-PaymentProfileForPrepayment-

    [Documentation]  Set a Jaldee bank Payment profile for a provider by SA then do the Razorpay verification.

JD-TC-PaymentProfileForPrepayment-

    [Documentation]  Set a default bank Payment profile for a provider by SA.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME150}

    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[1]}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=150   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   
    ${ser_duratn}=   Random Int   min=10   max=30

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_duratn}  ${status[0]}   ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  1  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME16}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[7]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY}

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid2}=  get_id  ${CUSERNAME17}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid1}  ${wid[0]} 
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    ${resp}=  Get Bill By consumer  ${cwid1}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get JaldeeBank Statement By Provider  ${DAY}  ${DAY1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    Set Test Variable  ${paymentPurpose-eq}      prePayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    
    ${cwid}=  Convert To String  ${cwid} 
    ${cwid1}=  Convert To String  ${cwid1} 
    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-PaymentProfileForPrepayment-

    [Documentation]  Set a default Payment profile using invalid account id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME150}

    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  0000  ${advPayBankType[1]}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422

    
    

JD-TC-PaymentProfileForPrepayment-

    [Documentation]  Set a Specific Payment profile for a provider by SA.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME150}

    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[2]}   advancePaymentProfileId=spDefaultProfile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=150   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   
    ${ser_duratn}=   Random Int   min=10   max=30

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_duratn}  ${status[0]}   ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  1  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME16}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[7]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY}

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid2}=  get_id  ${CUSERNAME17}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid1}  ${wid[0]} 
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    ${resp}=  Get Bill By consumer  ${cwid1}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get JaldeeBank Statement By Provider  ${DAY}  ${DAY1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    Set Test Variable  ${paymentPurpose-eq}      prePayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    
    ${cwid}=  Convert To String  ${cwid} 
    ${cwid1}=  Convert To String  ${cwid1} 
    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-PaymentProfileForPrepayment-

    [Documentation]  Set a Service specific Payment profile for a provider by SA.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME150}

    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[3]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=150   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   
    ${ser_duratn}=   Random Int   min=10   max=30

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_duratn}  ${status[0]}   ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  1  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME16}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[7]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY}

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid2}=  get_id  ${CUSERNAME17}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid1}  ${wid[0]} 
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    ${resp}=  Get Bill By consumer  ${cwid1}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get JaldeeBank Statement By Provider  ${DAY}  ${DAY1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    Set Test Variable  ${paymentPurpose-eq}      prePayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    
    ${cwid}=  Convert To String  ${cwid} 
    ${cwid1}=  Convert To String  ${cwid1} 
    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-PaymentProfileForPrepayment-

    [Documentation]  Set a Service specific Payment profile for a provider by SA then do the Razorpay verification.

JD-TC-PaymentProfileForPrepayment-

    [Documentation]  Set a default Payment profile for a provider by SA.then change bank before payment.

JD-TC-PaymentProfileForPrepayment-

    [Documentation]  Set a default Payment profile for a provider by SA then do the Razorpay verification.

JD-TC-PaymentProfileForPrepayment-

    [Documentation]  Set a Specific Payment profile for a provider by SA then do the Razorpay verification.