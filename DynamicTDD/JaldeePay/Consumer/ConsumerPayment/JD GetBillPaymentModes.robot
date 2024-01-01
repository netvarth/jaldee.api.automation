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

*** Keywords ***

Get Bill payment modes
    [Arguments]  ${accountId}   ${billId}   ${paymentPurpose}
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /consumer/payment/modes/bill/${accountId}/${billId}/${paymentPurpose}    expected_status=any
    [Return]  ${resp}


*** Variables ***

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
JD-TC-JD-TC-GetServicePaymentModes

    [Documentation]  Get Bill payment modes by consumer for bill payment purpose.(Jaldee Bank)

    ${resp}=  Encrypted Provider Login  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get payment profiles  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${id}  ${resp.json()[0]['profileId']}

    ${pid}=  get_acc_id  ${PUSERNAME160}
    Set Suite Variable   ${pid}

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}

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
    # ${sTime}=  db.get_time_by_timezone   ${tz}
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

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Output/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${bill_id}  ${resp.json()['billId']}

    ${resp}=  Get Bill payment modes    ${pid}  ${bill_id}   ${Payment_Purpose[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME160}  ${PASSWORD}
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


    ${resp}=  Encrypted Provider Login  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone   ${tz}
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


JD-TC-GetBillPaymentModes-1

    [Documentation]  Get Bill payment modes by consumer for bill payment purpose.
    
    clear_queue    ${PUSERNAME123}
    clear_service  ${PUSERNAME123}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME123}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME123}
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
    ${indianPaymodes1}=   Create Dictionary   mode=${payment_modes[5]}   gateway=${gateway}   modeDisplayName=${payment_modes[5]}     mode=${payment_modes[2]}   gatewayFee=${gatewayFee}
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

    ${resp}=   Payment Profile  ${paymentprofileid[0]}  ${displayName}   ${desc}  ${type}  ${txnTypes}   ${destBank}  ${boolean[1]}   ${paymode}  ${boolean[1]}
    ...   ${indianPaymodes1}   ${boolean[1]}   ${internationalPaymodes}  ${splitPayment}   ${destBanks}   ${fromBank}
    
    # ${resp1}=   jaldee_bank_profile
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

    ${indianPaymodes1}=   Create Dictionary   mode=${payment_modes[5]}   gatewayFee=${gatewayFee}    mode=${payment_modes[3]}   gatewayFee=${gatewayFee} 
    ${indianPaymodes1}=  Create List   ${indianPaymodes1}
    ${internationalPaymodes1}=   Create Dictionary   mode=${payment_modes[5]}   gatewayFee=${gatewayFee}  
    ${internationalPaymodes}=  Create List    ${internationalPaymodes1}

    ${resp1}=   Create Dictionary    id=customizedJBProfile    destBank=${destBank}    indiaPay=${boolean[1]}    displayName=Jaldee Bank Payment Profile   convenienceFee=${convenienceFee}   indianPaymodes=${indianPaymodes1}    internationalPay=${boolean[1]}    internationalPaymodes=${internationalPaymodes}
    Log  ${resp}

    ${profiles1}=  Setting Payment Profile  ${resp}   ${resp1}
    
    ${combined_json}=  Payment Profile Json  ${profiles1}  
    
    ${payment_profile}=  payment_profiles   ${combined_json}  ${pid}
    
    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME123}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Destination Bank  ${paymentprofileid[0]}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get payment profiles   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get payment profile By Id    customizedJBProfile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${SERVICE1}=    FakerLibrary.word
    Set Suite Variable   ${SERVICE1}
    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Suite Variable    ${ser_id1}    ${resp} 
                                                  
    ${serviceids}=   Create List   ${ser_id1}
    ${resp}=   Assign Profile To Service   ${paymentprofileid[0]}   ${serviceids}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
     
    ${resp}=   Get Service By Id  ${ser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME123}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get Bill payment modes  ${pid}   ${ser_id1}   ${Payment_Purpose[1]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

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
    # ${sTime}=  db.get_time_by_timezone   ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  1  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    # ${resp}=  ProviderLogout
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME16}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Output/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
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

    # ${resp}=    Get convenienceFee Details     ${pid}    customizedJBProfile   ${min_pre1}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get payment modes    ${pid}    ${s_id}    ${purpose[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['isJaldeeBank']}    ${bool[1]}
    # Set Suite Variable    ${proid}  ${resp.json()[0]['profileId']}

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}    profileId=${paymentprofileid[0]}    paymentGateway=RAZORPAY    paymentSettingsId=1
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME123}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${bill_id}  ${resp.json()['billId']}

    ${resp}=  Get Bill payment modes    ${pid}  ${bill_id}   ${Payment_Purpose[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GetBillPaymentModes-2

    [Documentation]  Get Bill payment modes by consumer for bill payment purpose.
    

    ${resp}=  Encrypted Provider Login  ${PUSERNAME123}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME123}
    Set Suite Variable   ${pid}
    
    
    # ${resp}=   ProviderLogout
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    
    # ${resp}=  Encrypted Provider Login  ${PUSERNAME123}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Update Destination Bank  ${paymentprofileid[0]}  ${bool[0]}  
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get payment profiles   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${id}    ${resp.json()[0]['profileId']} 

    ${resp}=   Get payment profile By Id    customizedJBProfile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${SERVICE1}=    FakerLibrary.word
    # Set Suite Variable   ${SERVICE1}
    # ${resp}=   Create Sample Service  ${SERVICE1}
    # Set Suite Variable    ${ser_id1}    ${resp} 
                                                  
    # ${serviceids}=   Create List   ${ser_id1}
    # ${resp}=   Assign Profile To Service   ${paymentprofileid[0]}   ${serviceids}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
     
    # ${resp}=   Get Service By Id  ${ser_id1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME123}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get Bill payment modes  ${pid}   ${ser_id1}   ${Payment_Purpose[1]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

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
    # ${sTime}=  db.get_time_by_timezone   ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  1  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    # ${resp}=  ProviderLogout
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME16}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Output/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
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

    # ${resp}=    Get convenienceFee Details     ${pid}    customizedJBProfile   ${Tot1}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get payment modes    ${pid}    ${s_id}    ${purpose[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['isJaldeeBank']}    ${bool[1]}
    # Set Suite Variable    ${proid}  ${resp.json()[0]['profileId']}

    ${resp}=  Make payment Consumer Mock  ${pid}  ${Tot1}  ${purpose[1]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}   profileId=${id}    paymentGateway=RAZORPAY    paymentSettingsId=1
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME123}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  2s

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${bill_id}  ${resp.json()['billId']}

    ${resp}=  Get Bill payment modes    ${pid}  ${bill_id}   ${Payment_Purpose[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    

JD-TC-GetBillPaymentModes-UH1

    [Documentation]  Get payment modes by consumer wihout create a payment profile for the provider.
    
    clear_queue    ${PUSERNAME124}
    clear_service  ${PUSERNAME124}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME124}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME124}
    Set Test Variable   ${pid}
    
    ${SERVICE}=    FakerLibrary.word
    Set Test Variable   ${SERVICE}
    ${resp}=   Create Sample Service  ${SERVICE}
    Set Test Variable    ${ser_id}    ${resp} 

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill payment modes    ${pid}  ${bill_id}   ${Payment_Purpose[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GetBillPaymentModes-UH2

    [Documentation]  Get payment modes by consumer without  login.
    
    ${resp}=  Get Bill payment modes    ${pid}  ${bill_id}   ${Payment_Purpose[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetBillPaymentModes-UH3

    [Documentation]  Get payment modes by consumer with provider login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME124}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Bill payment modes    ${pid}  ${bill_id}   ${Payment_Purpose[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GetBillPaymentModes-UH4

    [Documentation]  Get payment modes by consumer with giving Service id.

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Bill payment modes    ${pid}  ${s_id}   ${Payment_Purpose[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${INVALID_BILL_ID}
