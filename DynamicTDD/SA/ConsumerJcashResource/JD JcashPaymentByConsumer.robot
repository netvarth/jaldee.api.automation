*** Settings ***
Test Teardown     Delete All Sessions
Force Tags        Jcash
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
Resource          /ebs/TDD/AppKeywords.robot


*** Variables ***

${digits}       0123456789
${service_duration}   2
${parallel}           1
${self}               0
@{provider_list}
${start}              140
${jcoupon1}   CouponMul00
${CUSERPH}      ${CUSERNAME}
${tz}   Asia/Kolkata


*** Test Cases ***

JD-TC-JcashPaymentByConsumer

    [Documentation]  Taking waitlist from consumer side and the consumer doing the prepayment with jcash and mock.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Global Max Spendlimit
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${global_max_limit}    ${resp.json()}
    ${global_max_limit}=  Convert To Number  ${global_max_limit}  1
    Set Suite variable   ${global_max_limit}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-JcashPaymentByConsumer0

    [Documentation]  Taking waitlist from consumer side and the consumer doing the prepayment with jcash and mock.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    #   Set Suite Variable   ${ex_date}
    ${maxSpendLimit}=  Random Int  min=30   max=149 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    Set Suite Variable   ${max_limit}
  
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-JcashPaymentByConsumer-1

    [Documentation]  Taking waitlist from consumer side and the consumer doing the prepayment with jcash and mock.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    

    ${name}=  FakerLibrary.name
    Set Suite variable   ${name}
    ${EMPTY_List}=  Create List
    ${start_date}=  db.get_date_by_timezone  ${tz} 
    Set Suite Variable   ${start_date}
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    Set Suite Variable   ${end_date}
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    Set Suite Variable   ${minOnlinePaymentAmt}
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    Set Suite Variable   ${maxValidUntil}
    ${validForDays}=  Random Int  min=5   max=10 
    Set Suite Variable   ${validForDays}
    ${ex_date}=    db.add_timezone_date  ${tz}   ${validForDays} 
    Set Suite Variable   ${ex_date}
    # ${maxSpendLimit}=  Random Int  min=30   max=149 
    # ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    # ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
    # Set Suite Variable   ${max_limit}
    ${issueLimit}=  Random Int  min=1   max=5 
    Set Suite Variable   ${issueLimit}
    ${amt}=  Random Int  min=200   max=500  
    ${amt}=  Convert To Number  ${amt}   1
    Set Suite Variable   ${amt}
    ${accounttype}  Random Element   ${accounttype}
    ${businessStatus}    Random Element   ${businessStatus}   
    ${resp}=  Create Jaldee Cash Offer  ${name}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id}   ${resp.json()}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_queue      ${PUSERNAME101}
    clear_location   ${PUSERNAME101}
    clear_service    ${PUSERNAME101}
    clear_customer   ${PUSERNAME101}
    clear_Coupon     ${PUSERNAME101}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${pid}=  get_acc_id  ${PUSERNAME101}
    Set Suite Variable  ${pid}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

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
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME101}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}   ${businessStatus}   ${accounttype}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  payuVerify  ${pid}
    Log  ${resp}
  

    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME101}   ${pan_num}  ${bank_ac}  ${bankName}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessStatus}  ${accounttype}   
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid}  ${merchantid}
    
    ${p1_lid}=  Create Sample Location

    ${resp}=  Get Locations
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_lid}  ${resp.json()[0]['id']} 

    ${min_pre1}=   Random Int   min=160   max=250
    ${Tot}=   Random Int   min=200   max=1000
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   

    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid1}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid2}  ${resp.json()}
    
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${sTime}=  add_timezone_time  ${tz}  1  00  
    ${eTime}=  add_timezone_time  ${tz}   4   15
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_lid}  ${p1_sid1}  ${p1_sid2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${CUSERPH1}=  Evaluate  ${CUSERPH}+104388201
    # Set Suite Variable   ${CUSERPH1}
    # Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH1}${\n}
    # Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH1}${\n}

    # ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH1}+4468
    # ${firstname}=  FakerLibrary.first_name
    # Set Suite Variable   ${firstname}
    # ${lastname}=  FakerLibrary.last_name
    # Set Suite Variable   ${lastname}
    # ${address}=  FakerLibrary.address
    # ${dob}=  FakerLibrary.Date
    # ${gender}    Random Element    ${Genderlist}
    # ${CUSERMAIL2}=   Set Variable  ${C_Email}ph2424.ynwtest@netvarth.com
    # ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${CUSERPH1}=  Evaluate  ${CUSERPH}+967411232
    Set Suite Variable   ${CUSERPH1}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH1}${\n}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${CUSERPH}+76068
    Set Test Variable  ${email}  ${firstname}${CUSERPH1}${CUSERPH}.ynwtest@netvarth.com
    ${resp}=  Android App Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}   ${alternativeNo}  ${dob}  ${gender}   ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Activation  ${CUSERPH1}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH1}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${CPH0_id3}   ${resp.json()['id']} 
    
    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               0.0

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['jCashAmt']}      ${max_limit}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['creditAmt']}     0.0
    Set Suite Variable    ${pre_payment}    ${resp.json()['amountRequiredNow']}
    
    ${rem_amnt}=   Evaluate   ${pre_payment} - ${max_limit}
    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${pre_payment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${rem_amnt} 

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot1}+${tax}
    ${totalamt}=  Convert To Number  ${totalamt}   2
    ${balamount}=  Evaluate  ${totalamt}-${pre_payment}
    ${balamount}=  Convert To Number  ${balamount}   2
    
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    ...                       jCashUsedAmt=0.0            creditUsedAmt=0.0

    ${resp}=  Make Jcash Payment Consumer Mock  ${pre_payment}  ${bool[1]}  ${cwid}   ${pid}  ${purpose[0]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}       ${resp.json()['response']['merchantId']}  
    Set Suite Variable   ${payref}    ${resp.json()['response']['paymentRefId']}
    Should Be Equal As Strings    ${resp.json()['isJCashPaymentSucess']}        ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['isGateWayPaymentNeeded']}      ${bool[1]}

    sleep   02s
    
    ${avail_amnt}=   Evaluate   ${amt} - ${max_limit}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${max_limit}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${max_limit}
    
    ${resp}=  Get Payment Details  account-eq=${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${rem_amnt}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${cwid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentRefId']}    ${payref} 
    Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}  ${purpose[0]}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_payment}  amountDue=${balamount}  totalTaxAmount=${tax}

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    ...                       jCashUsedAmt=${max_limit}             creditUsedAmt=0.0

JD-TC-JcashPaymentByConsumer-2

    [Documentation]  Taking appointment from consumer side and the consumer doing the prepayment with jcash and mock.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME99}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_queue    ${PUSERNAME99}
    clear_service  ${PUSERNAME99}
    clear_rating    ${PUSERNAME99}
    clear_customer   ${PUSERNAME99}

    ${pid1}=  get_acc_id  ${PUSERNAME99}
    Set Suite Variable  ${pid1} 
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${businessStatus}    Random Element   ${businessStatus}  
    ${accounttype}  Random Element   ${accounttype} 
    ${fname}=   FakerLibrary.name
    ${panCardNumber}=  Generate_pan_number
    ${bankAccountNumber}=  Generate_random_value  size=16  chars=string.digits
    ${bankName}=  FakerLibrary.company
    ${ifsc}=  Generate_ifsc_code
    ${panname}=  FakerLibrary.name
    ${city}=   get_place
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME99}   ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc}  ${pan_name}  ${fname}  ${city}  ${businessStatus}  ${accounttype}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  payuVerify  ${pid1}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME99}   ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc}  ${pan_name}  ${fname}  ${city}  ${businessStatus}  ${accounttype}   
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid1}  ${merchantid}
    
    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    clear_appt_schedule   ${PUSERNAME99}

    ${ser_durtn}=   Random Int   min=2   max=10
    ${ser_amount}=   Random Int   min=200   max=500
    ${ser_amount}=  Convert To Number  ${ser_amount}  1
    Set Suite Variable    ${ser_amount} 
    ${min_pre}=   Random Int   min=100   max=250
    ${min_pre}=  Convert To Number  ${min_pre}  1
    Set Suite Variable    ${min_pre} 
    ${notify}    Random Element     ['True','False']
    ${notifytype}    Random Element     ['none','pushMsg','email']
    ${SERVICE1}=   FakerLibrary.name
    ${description}=  FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${description}   ${ser_durtn}  ${status[0]}  ${btype}  ${notify}   ${notifytype}  ${min_pre}  ${ser_amount}  ${bool[1]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable    ${s_id1}  ${resp.json()}

    ${SERVICE2}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE2}  ${description}   ${ser_durtn}  ${status[0]}  ${btype}  ${notify}   ${notifytype}  ${EMPTY}  ${ser_amount}  ${bool[0]}  ${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable    ${s_id2}  ${resp.json()}
    
    ${SERVICE3}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE3}  ${description}   ${ser_durtn}  ${status[0]}  ${btype}  ${notify}   ${notifytype}  ${EMPTY}  ${ser_amount}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable    ${s_id3}  ${resp.json()}

    ${SERVICE4}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE4}  ${description}   ${ser_durtn}  ${status[0]}  ${btype}  ${notify}   ${notifytype}  ${EMPTY}  ${ser_amount}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable    ${s_id4}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${eTime1}=  add_two   ${sTime1}  ${delta}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${DAY2}=  db.add_timezone_date  ${tz}  11      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  1  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id3}  ${s_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${CUSERPH2}=  Evaluate  ${CUSERPH}+1043874501
    # Set Suite Variable   ${CUSERPH2}
    # Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH2}${\n}
    # Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH2}${\n}

    # ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH2}+4468
    # ${firstname}=  FakerLibrary.first_name
    # Set Suite Variable   ${firstname}
    # ${lastname}=  FakerLibrary.last_name
    # Set Suite Variable   ${lastname}
    # ${address}=  FakerLibrary.address
    # ${dob}=  FakerLibrary.Date
    # ${gender}    Random Element    ${Genderlist}
    # ${CUSERMAIL2}=   Set Variable  ${C_Email}ph2487.ynwtest@netvarth.com
    # ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH2}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    

    ${CUSERPH2}=  Evaluate  ${CUSERPH}+95634323
    Set Suite Variable   ${CUSERPH2}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH2}${\n}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${CUSERPH}+76068
    Set Test Variable  ${email}  ${firstname}${CUSERPH2}${CUSERPH}.ynwtest@netvarth.com
    ${resp}=  Android App Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH2}   ${alternativeNo}  ${dob}  ${gender}   ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Activation  ${CUSERPH2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Login  ${CUSERPH2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${CPH0_id4}   ${resp.json()['id']} 
   
    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               0.0

    ${resp}=  Get Appointment Schedules Consumer  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${totalTaxAmount}=  Evaluate  ${ser_amount} * ${gstpercentage[2]} / 100
    Set Suite Variable  ${totalTaxAmount}
    
    ${cnote}=   FakerLibrary.name
    ${EMPTY_List}=  Create List
    ${resp}=   Appointment AdvancePayment Details   ${pid1}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  ${EMPTY_List}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     ${min_pre}
    Should Be Equal As Strings  ${resp.json()['jdnDiscount']}                           0.0
    Should Be Equal As Strings  ${resp.json()['couponDiscount']}                        0.0
    Should Be Equal As Strings  ${resp.json()['providerCouponDiscount']}                0.0
    Should Be Equal As Strings  ${resp.json()['totalDiscount']}                         0.0
    Should Be Equal As Strings  ${resp.json()['netTaxAmount']}                          ${totalTaxAmount}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['jCashAmt']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['creditAmt']}         0.0
    
    Set Suite Variable    ${pre_payment1}    ${resp.json()['amountRequiredNow']}

    ${rem_amnt}=   Evaluate   ${pre_payment1} - ${max_limit}

    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${pre_payment1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${rem_amnt} 

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid1}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid1}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   apptStatus=${apptStatus[0]}
    ...                       jCashUsedAmt=0.0            creditUsedAmt=0.0  
    
    ${totalamt}=  Evaluate  ${ser_amount}+${totalTaxAmount}
    ${totalamt}=  Convert To Number  ${totalamt}   2
    ${balamount}=  Evaluate  ${totalamt}-${pre_payment1}
    ${balamount}=  Convert To Number  ${balamount}   2
    
    ${resp}=  Make Jcash Payment Consumer Mock  ${pre_payment1}  ${bool[1]}  ${apptid1}   ${pid1}  ${purpose[0]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer1}       ${resp.json()['response']['merchantId']}  
    Set Suite Variable   ${payref1}    ${resp.json()['response']['paymentRefId']}
    Should Be Equal As Strings    ${resp.json()['isJCashPaymentSucess']}        ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['isGateWayPaymentNeeded']}      ${bool[1]}

    sleep   02s
    
    ${avail_amnt}=   Evaluate   ${amt} - ${max_limit}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${max_limit}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${max_limit}
    
    ${resp}=  Get Payment Details  account-eq=${pid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${pid1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${rem_amnt}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${pid1}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[1]['paymentRefId']}    ${payref1} 
    Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}  ${purpose[0]}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${apptid1}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${apptid1}  netTotal=${ser_amount}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_payment1}  amountDue=${balamount}  
    ...   totalTaxAmount=${totalTaxAmount}

    ${resp}=   Get consumer Appointment By Id   ${pid1}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     apptStatus=${apptStatus[1]}
    ...                       jCashUsedAmt=${max_limit}             creditUsedAmt=0.0

JD-TC-JcashPaymentByConsumer-3

    [Documentation]  Taking order from consumer side and the consumer doing the prepayment with jcash and mock.

    clear_queue    ${PUSERNAME150}
    clear_service  ${PUSERNAME150}
    clear_customer   ${PUSERNAME150}
    clear_Item   ${PUSERNAME150}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${accId}=  get_acc_id  ${PUSERNAME150}
    Set Suite Variable  ${accId}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME150}.ynwtest@netvarth.com

    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${businessStatus}    Random Element   ${businessStatus}  
    ${accounttype}  Random Element   ${accounttype} 
    ${fname}=   FakerLibrary.name
    ${panCardNumber}=  Generate_pan_number
    ${bankAccountNumber}=  Generate_random_value  size=16  chars=string.digits
    ${bankName}=  FakerLibrary.company
    ${ifsc}=  Generate_ifsc_code
    ${panname}=  FakerLibrary.name
    ${city}=   get_place
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME99}   ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc}  ${pan_name}  ${fname}  ${city}  ${businessStatus}  ${accounttype}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  payuVerify  ${pid1}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME99}   ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc}  ${pan_name}  ${fname}  ${city}  ${businessStatus}  ${accounttype}   
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid1}  ${merchantid}
   
    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${displayName1}=   FakerLibrary.name 
    Set Suite Variable  ${displayName1}
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1float}=  twodigitfloat  ${price1}
    Set Suite Variable  ${price1}

    ${itemName1}=   FakerLibrary.name  
    Set Suite Variable  ${itemName1}

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    ${promoPrice1}=   Convert To Number  ${promoPrice1}   1
    Set Suite Variable    ${promoPrice1}

    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode1}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable  ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  3  30  
    Set Suite Variable  ${eTime1}   
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
  
    ${deliveryCharge}=  Random Int  min=1   max=100
    ${deliveryCharge}=  Convert To Number   ${deliveryCharge}  1
    Set Suite variable   ${deliveryCharge}

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30
    Set Suite variable   ${minQuantity}

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50
    Set Suite variable   ${maxQuantity}

    ${catalogName}=   FakerLibrary.name  

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id1}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[1]}

    ${advanceAmount}=  Random Int  min=100   max=1000
    ${advanceAmount}=  Convert To Number   ${advanceAmount}   1
    Set Suite Variable  ${advanceAmount} 
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=1   max=1
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${CUSERPH3}=  Evaluate  ${CUSERPH}+105874501
    # Set Suite Variable   ${CUSERPH3}
    # Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH3}${\n}
    # Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH3}${\n}

    # ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH3}+4468
    # ${firstname}=  FakerLibrary.first_name
    # Set Suite Variable   ${firstname}
    # ${lastname}=  FakerLibrary.last_name
    # Set Suite Variable   ${lastname}
    # ${address}=  FakerLibrary.address
    # ${dob}=  FakerLibrary.Date
    # ${gender}    Random Element    ${Genderlist}
    # ${CUSERMAIL2}=   Set Variable  ${C_Email}ph2407.ynwtest@netvarth.com
    # ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH3}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${CUSERPH3}=  Evaluate  ${CUSERPH}+7544680
    Set Suite Variable   ${CUSERPH3}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH3}${\n}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${CUSERPH}+76068
    Set Test Variable  ${email}  ${firstname}${CUSERPH3}${CUSERPH}.ynwtest@netvarth.com
    ${resp}=  Android App Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH3}   ${alternativeNo}  ${dob}  ${gender}   ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Activation  ${CUSERPH3}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH3}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Login  ${CUSERPH3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${CPH0_id4}   ${resp.json()['id']} 
    
    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               0.0
   
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH3}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.ynwtest@netvarth.com
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${code}=  Random Element    ${countryCodes}
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${code}
    Set Suite Variable  ${address}

    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.ynwtest@netvarth.com
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}  
   
    ${item1_total}=  Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalTaxAmount}=  Evaluate  ${item1_total} * ${gstpercentage[3]} / 100
    ${totalTaxAmount}=  twodigitfloat  ${totalTaxAmount}
    ${totalTaxAmount}=  Evaluate  ${totalTaxAmount} * 1
    ${net_total}=  Evaluate  ${item1_total} + ${deliveryCharge} + ${totalTaxAmount}
    ${net_total}=  Convert To Number   ${net_total}  2
    
    # sleep   2s
    ${resp}=   Get Cart Details    ${accId}   ${CatalogId1}   ${boolean[1]}   ${DAY1}    ${EMPTY_List}    ${item_id1}   ${item_quantity1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['id']}           ${item_id1}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['name']}         ${displayName1}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['price']}        ${promoPrice1}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['status']}       FULFILLED
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['totalPrice']}   ${item1_total}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['taxable']}      ${bool[1]}

    Should Be Equal As Strings   ${resp.json()['netTotal']}                      ${net_total}
    Should Be Equal As Strings   ${resp.json()['advanceAmount']}                 ${advanceAmount}
    Should Be Equal As Strings   ${resp.json()['jdnDiscount']}                   0.0
    Should Be Equal As Strings   ${resp.json()['jaldeeCouponDiscount']}          0.0
    Should Be Equal As Strings   ${resp.json()['totalDiscount']}                 0.0
    Should Be Equal As Strings   ${resp.json()['taxAmount']}                     ${totalTaxAmount}
    Should Be Equal As Strings   ${resp.json()['deliveryCharge']}                ${deliveryCharge}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['jCashAmt']}   ${max_limit}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['creditAmt']}  0.0
    
    Set Suite Variable    ${pre_payment2}    ${resp.json()['advanceAmount']}

    ${rem_amnt}=   Evaluate   ${pre_payment2} - ${max_limit}

    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${pre_payment2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${rem_amnt} 

    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    Verify Response  ${resp}  orderStatus=${orderStatuses[0]}   orderInternalStatus=${orderInternalStatus[1]}
    ...                       jCashUsedAmt=0.0            creditUsedAmt=0.0  
    
    ${totalamt}=  Evaluate  ${item1_total} + ${totalTaxAmount} + ${deliveryCharge}
    ${totalamt}=  Convert To Number  ${totalamt}   2
    ${balamount}=  Evaluate  ${totalamt} - ${pre_payment2}
    ${balamount}=  Convert To Number  ${balamount}   2
    
    ${resp}=  Make Jcash Payment Consumer Mock  ${pre_payment2}  ${bool[1]}  ${orderid1}   ${accId}  ${purpose[0]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer2}       ${resp.json()['response']['merchantId']}  
    Set Suite Variable   ${payref2}    ${resp.json()['response']['paymentRefId']}
    Should Be Equal As Strings    ${resp.json()['isJCashPaymentSucess']}        ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['isGateWayPaymentNeeded']}      ${bool[1]}

    sleep   02s
    
    ${avail_amnt}=   Evaluate   ${amt} - ${max_limit}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${max_limit}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${max_limit}
    
    ${resp}=  Get Payment Details  account-eq=${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${accId}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${orderid1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${rem_amnt}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${accId}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${orderid1}
    Should Be Equal As Strings  ${resp.json()[1]['paymentRefId']}    ${payref2} 
    Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}  ${purpose[0]}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${orderid1}  ${accId}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${orderid1}  netTotal=${item1_total}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_payment2}  amountDue=${balamount}  
    ...   totalTaxAmount=${totalTaxAmount}

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  orderStatus=${orderStatuses[0]}   orderInternalStatus=${orderInternalStatus[0]}
    ...                       jCashUsedAmt=${max_limit}             creditUsedAmt=0.0 


JD-TC-JcashPaymentByConsumer-4

    [Documentation]  Taking waitlist from consumer side and the consumer doing the prepayment with jcash and mock then do the full payment.

    ${CUSERPH4}=  Evaluate  ${CUSERPH}+104328201
    Set Suite Variable   ${CUSERPH4}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH4}${\n}
    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH4}${\n}

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH4}+4468
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname}
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL2}=   Set Variable  ${C_Email}ph20.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH4}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               0.0

    ${desc}=   FakerLibrary.word
    ${EMPTY_List}=  Create List
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['jCashAmt']}      ${max_limit}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['creditAmt']}     0.0
    Set Test Variable    ${pre_payment}    ${resp.json()['amountRequiredNow']}
    
    ${rem_amnt}=   Evaluate   ${pre_payment} - ${max_limit}
    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${pre_payment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${rem_amnt} 

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot1}+${tax}
    ${totalamt}=  Convert To Number  ${totalamt}   2
    ${balamount}=  Evaluate  ${totalamt}-${pre_payment}
    ${balamount}=  Convert To Number  ${balamount}   2
    
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    ...                       jCashUsedAmt=0.0            creditUsedAmt=0.0

    ${resp}=  Make Jcash Payment Consumer Mock  ${pre_payment}  ${bool[1]}  ${cwid}   ${pid}  ${purpose[0]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}       ${resp.json()['response']['merchantId']}  
    Set Suite Variable   ${payref}    ${resp.json()['response']['paymentRefId']}
    Should Be Equal As Strings    ${resp.json()['isJCashPaymentSucess']}        ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['isGateWayPaymentNeeded']}      ${bool[1]}

    sleep   02s
    
    ${avail_amnt}=   Evaluate   ${amt} - ${max_limit}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${max_limit}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${max_limit}
    
    ${resp}=  Get Payment Details  account-eq=${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${rem_amnt}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${cwid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentRefId']}    ${payref} 
    Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}  ${purpose[0]}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_payment}  amountDue=${balamount}  totalTaxAmount=${tax}

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    ...                       jCashUsedAmt=${max_limit}             creditUsedAmt=0.0
    
    sleep  1s
    ${resp}=  Make Jcash Payment Consumer Mock  ${balamount}  ${bool[1]}  ${cwid}   ${pid}  ${purpose[1]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${bal_amnt}=   Evaluate   ${avail_amnt} - ${max_limit}
    ${tot_spent}=  Evaluate    ${max_limit} + ${max_limit}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${tot_spent}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${bal_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${bal_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${max_limit}
    
    ${amt_paid}=  Evaluate   ${balamount} - ${max_limit}
    ${amt_paid}=  Convert To Number  ${amt_paid}   2

    ${resp}=  Get Payment Details  account-eq=${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${cwid}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${amt_paid}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}  ${purpose[1]}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[2]}  totalAmountPaid=${totalamt}  amountDue=0.0  totalTaxAmount=${tax}

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]}     waitlistStatus=${wl_status[0]}
    ...                       jCashUsedAmt=${tot_spent}             creditUsedAmt=0.0
    
    ${resp}=   Encrypted Provider Login   ${PUSERNAME101}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Waitlist By Id  ${cwid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}    paymentStatus=${paymentStatus[2]}


JD-TC-JcashPaymentByConsumer-5

    [Documentation]  Taking appointment from consumer side and the consumer doing the prepayment with jcash and mock then do the full payment.

    ${CUSERPH5}=  Evaluate  ${CUSERPH}+104377701
    Set Suite Variable   ${CUSERPH5}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH5}${\n}
    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH5}${\n}

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH5}+4468
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname}
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL2}=   Set Variable  ${C_Email}ph${CUSERPH5}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH5}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               0.0
    
    ${resp}=  Get Appointment Schedules Consumer  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot2}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.name
    ${EMPTY_List}=  Create List
    ${resp}=   Appointment AdvancePayment Details   ${pid1}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  ${EMPTY_List}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     ${min_pre}
    Should Be Equal As Strings  ${resp.json()['jdnDiscount']}                           0.0
    Should Be Equal As Strings  ${resp.json()['couponDiscount']}                        0.0
    Should Be Equal As Strings  ${resp.json()['providerCouponDiscount']}                0.0
    Should Be Equal As Strings  ${resp.json()['totalDiscount']}                         0.0
    Should Be Equal As Strings  ${resp.json()['netTaxAmount']}                          ${totalTaxAmount}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['jCashAmt']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['creditAmt']}         0.0
    
    Set Test Variable    ${pre_payment}    ${resp.json()['amountRequiredNow']}

    ${rem_amnt}=   Evaluate   ${pre_payment} - ${max_limit}

    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${pre_payment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${rem_amnt} 

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid1}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid1}  ${apptid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   apptStatus=${apptStatus[0]}
    ...                       jCashUsedAmt=0.0            creditUsedAmt=0.0  
    
    ${totalamt}=  Evaluate  ${ser_amount}+${totalTaxAmount}
    ${totalamt}=  Convert To Number  ${totalamt}   2
    ${balamount}=  Evaluate  ${totalamt}-${pre_payment}
    ${balamount}=  Convert To Number  ${balamount}   2
    
    sleep  1s
    ${resp}=  Make Jcash Payment Consumer Mock  ${pre_payment}  ${bool[1]}  ${apptid}   ${pid1}  ${purpose[0]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payref}    ${resp.json()['response']['paymentRefId']}
    Should Be Equal As Strings    ${resp.json()['isJCashPaymentSucess']}        ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['isGateWayPaymentNeeded']}      ${bool[1]}

    sleep   02s
    
    ${avail_amnt}=   Evaluate   ${amt} - ${max_limit}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${max_limit}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${max_limit}
    
    ${resp}=  Get Payment Details  account-eq=${pid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${pid1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${apptid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${rem_amnt}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${pid1}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${apptid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentRefId']}    ${payref} 
    Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}  ${purpose[0]}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${apptid}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${apptid}  netTotal=${ser_amount}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_payment}  amountDue=${balamount}  
    ...   totalTaxAmount=${totalTaxAmount}

    ${resp}=   Get consumer Appointment By Id   ${pid1}  ${apptid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     apptStatus=${apptStatus[1]}
    ...                       jCashUsedAmt=${max_limit}             creditUsedAmt=0.0

    # sleep  4s
    ${resp}=  Make Jcash Payment Consumer Mock  ${balamount}  ${bool[1]}  ${apptid}   ${pid1}  ${purpose[1]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${bal_amnt}=   Evaluate   ${avail_amnt} - ${max_limit}
    ${tot_spent}=  Evaluate    ${max_limit} + ${max_limit}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${tot_spent}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${bal_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${bal_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${max_limit}
    
    ${amt_paid}=  Evaluate   ${balamount} - ${max_limit}
    ${amt_paid}=  Convert To Number  ${amt_paid}   2

    ${resp}=  Get Payment Details  account-eq=${pid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${pid1}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${apptid}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${amt_paid}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${pid1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${apptid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}  ${purpose[1]}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${apptid}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${apptid}  netTotal=${ser_amount}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[2]}  totalAmountPaid=${totalamt}  amountDue=0.0  
    ...   totalTaxAmount=${totalTaxAmount}
    
    ${resp}=  Get consumer Appointment By Id   ${pid1}  ${apptid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]}   apptStatus=${apptStatus[1]}
    ...                       jCashUsedAmt=${tot_spent}             creditUsedAmt=0.0
    
    ${resp}=   Encrypted Provider Login   ${PUSERNAME99}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Appointment By Id  ${apptid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  apptStatus=${apptStatus[1]}    paymentStatus=${paymentStatus[2]}


JD-TC-JcashPaymentByConsumer-6

    [Documentation]  Taking order from consumer side and the consumer doing the prepayment with jcash and mock then do the full payment.


    ${CUSERPH6}=  Evaluate  ${CUSERPH}+747328201
    Set Suite Variable   ${CUSERPH6}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH6}${\n}
    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH6}${\n}

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH6}+4468
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname}
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL2}=   Set Variable  ${C_Email}ph${CUSERPH6}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH6}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH6}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               0.0
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH6}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.ynwtest@netvarth.com
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${code}=  Random Element    ${countryCodes}
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${code}
    
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.ynwtest@netvarth.com
    
    ${item1_total}=  Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalTaxAmount}=  Evaluate  ${item1_total} * ${gstpercentage[3]} / 100
    ${totalTaxAmount}=  twodigitfloat  ${totalTaxAmount}
    ${totalTaxAmount}=  Evaluate  ${totalTaxAmount} * 1
    ${net_total}=  Evaluate  ${item1_total} + ${deliveryCharge} + ${totalTaxAmount}
    ${net_total}=  Convert To Number   ${net_total}  2
    
    # sleep   3s
    ${resp}=   Get Cart Details    ${accId}   ${CatalogId1}   ${boolean[1]}   ${DAY1}    ${EMPTY_List}    ${item_id1}   ${item_quantity1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['id']}           ${item_id1}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['name']}         ${displayName1}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['price']}        ${promoPrice1}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['status']}       FULFILLED
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['totalPrice']}   ${item1_total}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['taxable']}      ${bool[1]}

    Should Be Equal As Strings   ${resp.json()['netTotal']}                      ${net_total}
    Should Be Equal As Strings   ${resp.json()['advanceAmount']}                 ${advanceAmount}
    Should Be Equal As Strings   ${resp.json()['jdnDiscount']}                   0.0
    Should Be Equal As Strings   ${resp.json()['jaldeeCouponDiscount']}          0.0
    Should Be Equal As Strings   ${resp.json()['totalDiscount']}                 0.0
    Should Be Equal As Strings   ${resp.json()['taxAmount']}                     ${totalTaxAmount}
    Should Be Equal As Strings   ${resp.json()['deliveryCharge']}                ${deliveryCharge}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['jCashAmt']}   ${max_limit}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['creditAmt']}  0.0
    
    Set Test Variable    ${pre_payment}    ${resp.json()['advanceAmount']}

    ${rem_amnt}=   Evaluate   ${pre_payment} - ${max_limit}

    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${pre_payment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${rem_amnt} 

    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid2}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId}  ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response  ${resp}  orderStatus=${orderStatuses[0]}   orderInternalStatus=${orderInternalStatus[1]}
    ...                       jCashUsedAmt=0.0            creditUsedAmt=0.0  
    
    ${totalamt}=  Evaluate  ${item1_total} + ${totalTaxAmount} + ${deliveryCharge}
    ${totalamt}=  Convert To Number  ${totalamt}   2
    ${balamount}=  Evaluate  ${totalamt} - ${pre_payment}
    ${balamount}=  Convert To Number  ${balamount}   2
    
    ${resp}=  Make Jcash Payment Consumer Mock  ${pre_payment}  ${bool[1]}  ${orderid2}   ${accId}  ${purpose[0]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payref}    ${resp.json()['response']['paymentRefId']}
    Should Be Equal As Strings    ${resp.json()['isJCashPaymentSucess']}        ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['isGateWayPaymentNeeded']}      ${bool[1]}

    sleep   02s
    
    ${avail_amnt}=   Evaluate   ${amt} - ${max_limit}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${max_limit}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${max_limit}
    
    ${resp}=  Get Payment Details  account-eq=${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${accId}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${orderid2}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${rem_amnt}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${accId}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${orderid2}
    Should Be Equal As Strings  ${resp.json()[1]['paymentRefId']}    ${payref} 
    Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}  ${purpose[0]}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${orderid2}  ${accId}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${orderid2}  netTotal=${item1_total}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_payment}  amountDue=${balamount}  
    ...   totalTaxAmount=${totalTaxAmount}

    ${resp}=   Get Order By Id  ${accId}  ${orderid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  orderStatus=${orderStatuses[0]}   orderInternalStatus=${orderInternalStatus[0]}
    ...                       jCashUsedAmt=${max_limit}             creditUsedAmt=0.0 

    # sleep  3s
    ${resp}=  Make Jcash Payment Consumer Mock  ${balamount}  ${bool[1]}  ${orderid2}   ${accId}  ${purpose[1]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${bal_amnt}=   Evaluate   ${avail_amnt} - ${max_limit}
    ${tot_spent}=  Evaluate    ${max_limit} + ${max_limit}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${tot_spent}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${bal_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${bal_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${max_limit}
    
    ${amt_paid}=  Evaluate   ${balamount} - ${max_limit}
    ${amt_paid}=  Convert To Number  ${amt_paid}   2

    ${resp}=  Get Payment Details  account-eq=${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${accId}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${orderid2}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${amt_paid}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${accId}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${orderid2}
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}  ${purpose[1]}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${orderid2}  ${accId}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${orderid2}  netTotal=${item1_total}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[2]}  totalAmountPaid=${totalamt}  amountDue=0.0  
    ...   totalTaxAmount=${totalTaxAmount}
    
  
    ${resp}=   Get Order By Id  ${accId}  ${orderid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  orderStatus=${orderStatuses[0]}   orderInternalStatus=${orderInternalStatus[0]}
    ...                       jCashUsedAmt=${tot_spent}             creditUsedAmt=0.0 

    ${resp}=   Encrypted Provider Login   ${PUSERNAME150}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Order by uid   ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  orderStatus=${orderStatuses[0]}    orderInternalStatus=${orderInternalStatus[0]}

JD-TC-JcashPaymentByConsumer-7

    [Documentation]  Taking waitlist from consumer side then cancel the waitlist after doing the prepayment with jcash and mock.

    ${CUSERPH1}=  Evaluate  ${CUSERPH}+1043401
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH1}${\n}
    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH1}${\n}

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH1}+4468
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL2}=   Set Variable  ${C_Email}ph${CUSERPH1}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               0.0

    ${desc}=   FakerLibrary.word
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['jCashAmt']}      ${max_limit}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['creditAmt']}     0.0
    Set Test Variable    ${pre_payment}    ${resp.json()['amountRequiredNow']}
    
    ${rem_amnt}=   Evaluate   ${pre_payment} - ${max_limit}
    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${pre_payment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${rem_amnt} 

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot1}+${tax}
    ${totalamt}=  Convert To Number  ${totalamt}   2
    ${balamount}=  Evaluate  ${totalamt}-${pre_payment}
    ${balamount}=  Convert To Number  ${balamount}   2
    
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    ...                       jCashUsedAmt=0.0            creditUsedAmt=0.0

    ${resp}=  Make Jcash Payment Consumer Mock  ${pre_payment}  ${bool[1]}  ${cwid}   ${pid}  ${purpose[0]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payref}    ${resp.json()['response']['paymentRefId']}
    Should Be Equal As Strings    ${resp.json()['isJCashPaymentSucess']}        ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['isGateWayPaymentNeeded']}      ${bool[1]}

    sleep   02s
    
    ${avail_amnt}=   Evaluate   ${amt} - ${max_limit}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${max_limit}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${max_limit}
    
    ${resp}=  Get Payment Details  account-eq=${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${rem_amnt}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${cwid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentRefId']}    ${payref} 
    Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}  ${purpose[0]}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_payment}  amountDue=${balamount}  totalTaxAmount=${tax}

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    ...                       jCashUsedAmt=${max_limit}             creditUsedAmt=0.0

    ${resp}=  Cancel Waitlist  ${cwid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}  ${wl_status[4]}
    
    Sleep  2s
    
    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}   billStatus=${billStatus[2]}  billViewStatus=${billViewStatus[1]}  billPaymentStatus=${paymentStatus[3]}  

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login   ${PUSERNAME101}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Waitlist By Id  ${cwid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}   waitlistStatus=${wl_status[4]}  paymentStatus=${paymentStatus[3]}

    ${resp}=  Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}   billStatus=${billStatus[2]}  billViewStatus=${billViewStatus[1]}  billPaymentStatus=${paymentStatus[3]}  

JD-TC-JcashPaymentByConsumer-8

    [Documentation]  Taking waitlist from consumer side then cancel the waitlist after doing the fullpayment with jcash and mock.

    ${CUSERPH4}=  Evaluate  ${CUSERPH}+104555
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH4}${\n}
    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH4}${\n}

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH4}+4468
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname}
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL2}=   Set Variable  ${C_Email}ph${CUSERPH4}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH4}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               0.0

    ${desc}=   FakerLibrary.word
    ${EMPTY_List}=  Create List
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${p1_qid}  ${DAY1}  ${p1_sid2}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['jCashAmt']}      ${max_limit}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['creditAmt']}     0.0
    Set Test Variable    ${pre_payment}    ${resp.json()['amountRequiredNow']}
    
    ${rem_amnt}=   Evaluate   ${pre_payment} - ${max_limit}
    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${pre_payment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${rem_amnt} 

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY1}  ${p1_sid2}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot1}+${tax}
    ${totalamt}=  Convert To Number  ${totalamt}   2
    ${balamount}=  Evaluate  ${totalamt}-${pre_payment}
    ${balamount}=  Convert To Number  ${balamount}   2
    
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    ...                       jCashUsedAmt=0.0            creditUsedAmt=0.0

    ${resp}=  Make Jcash Payment Consumer Mock  ${pre_payment}  ${bool[1]}  ${cwid}   ${pid}  ${purpose[0]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}       ${resp.json()['response']['merchantId']}  
    Set Suite Variable   ${payref}    ${resp.json()['response']['paymentRefId']}
    Should Be Equal As Strings    ${resp.json()['isJCashPaymentSucess']}        ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['isGateWayPaymentNeeded']}      ${bool[1]}

    sleep   02s
    
    ${avail_amnt}=   Evaluate   ${amt} - ${max_limit}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${max_limit}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${max_limit}
    
    ${resp}=  Get Payment Details  account-eq=${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${rem_amnt}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${cwid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentRefId']}    ${payref} 
    Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}  ${purpose[0]}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_payment}  amountDue=${balamount}  totalTaxAmount=${tax}

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    ...                       jCashUsedAmt=${max_limit}             creditUsedAmt=0.0
    
    sleep  1s
    ${resp}=  Make Jcash Payment Consumer Mock  ${balamount}  ${bool[1]}  ${cwid}   ${pid}  ${purpose[1]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${bal_amnt}=   Evaluate   ${avail_amnt} - ${max_limit}
    ${tot_spent}=  Evaluate    ${max_limit} + ${max_limit}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${tot_spent}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${bal_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${bal_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${max_limit}
    
    ${amt_paid}=  Evaluate   ${balamount} - ${max_limit}
    ${amt_paid}=  Convert To Number  ${amt_paid}   2

    ${resp}=  Get Payment Details  account-eq=${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${cwid}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${amt_paid}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}  ${purpose[1]}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[2]}  totalAmountPaid=${totalamt}  amountDue=0.0  totalTaxAmount=${tax}

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]}     waitlistStatus=${wl_status[0]}
    ...                       jCashUsedAmt=${tot_spent}             creditUsedAmt=0.0
   
    ${resp}=  Cancel Waitlist  ${cwid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}  ${wl_status[4]}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get All Jaldee Cash Available
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    Set Test Variable   ${cash_id1}    ${resp.json()[0]['id']}

    ${resp}=  Get Jaldee Cash Available By Id   ${cash_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200    

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}   billStatus=${billStatus[2]}  billViewStatus=${billViewStatus[1]}  billPaymentStatus=${paymentStatus[3]}  

    ${resp}=   Encrypted Provider Login   ${PUSERNAME101}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Waitlist By Id  ${cwid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}   waitlistStatus=${wl_status[4]}  paymentStatus=${paymentStatus[3]}

    ${resp}=  Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}   billStatus=${billStatus[2]}  billViewStatus=${billViewStatus[1]}  billPaymentStatus=${paymentStatus[3]}  


JD-TC-JcashPaymentByConsumer-9

    [Documentation]  Taking appointment from consumer side then cancel the waitlist after doing the fullpayment with jcash and mock.

    ${CUSERPH5}=  Evaluate  ${CUSERPH}+887532454
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH5}${\n}
    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH5}${\n}

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH5}+4468
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL2}=   Set Variable  ${C_Email}ph${CUSERPH5}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH5}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               0.0
    
    ${resp}=  Get Appointment Schedules Consumer  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot2}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.name
    ${EMPTY_List}=  Create List
    ${resp}=   Appointment AdvancePayment Details   ${pid1}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  ${EMPTY_List}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     ${min_pre}
    Should Be Equal As Strings  ${resp.json()['jdnDiscount']}                           0.0
    Should Be Equal As Strings  ${resp.json()['couponDiscount']}                        0.0
    Should Be Equal As Strings  ${resp.json()['providerCouponDiscount']}                0.0
    Should Be Equal As Strings  ${resp.json()['totalDiscount']}                         0.0
    Should Be Equal As Strings  ${resp.json()['netTaxAmount']}                          ${totalTaxAmount}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['jCashAmt']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['creditAmt']}         0.0
    
    Set Test Variable    ${pre_payment}    ${resp.json()['amountRequiredNow']}

    ${rem_amnt}=   Evaluate   ${pre_payment} - ${max_limit}

    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${pre_payment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${rem_amnt} 

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid1}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid1}  ${apptid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   apptStatus=${apptStatus[0]}
    ...                       jCashUsedAmt=0.0            creditUsedAmt=0.0  
    
    ${totalamt}=  Evaluate  ${ser_amount}+${totalTaxAmount}
    ${totalamt}=  Convert To Number  ${totalamt}   2
    ${balamount}=  Evaluate  ${totalamt}-${pre_payment}
    ${balamount}=  Convert To Number  ${balamount}   2
    
    sleep  1s
    ${resp}=  Make Jcash Payment Consumer Mock  ${pre_payment}  ${bool[1]}  ${apptid}   ${pid1}  ${purpose[0]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payref}    ${resp.json()['response']['paymentRefId']}
    Should Be Equal As Strings    ${resp.json()['isJCashPaymentSucess']}        ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['isGateWayPaymentNeeded']}      ${bool[1]}

    sleep   02s
    
    ${avail_amnt}=   Evaluate   ${amt} - ${max_limit}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${max_limit}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${max_limit}
    
    ${resp}=  Get Payment Details  account-eq=${pid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${pid1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${apptid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${rem_amnt}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${pid1}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${apptid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentRefId']}    ${payref} 
    Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}  ${purpose[0]}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${apptid}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${apptid}  netTotal=${ser_amount}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_payment}  amountDue=${balamount}  
    ...   totalTaxAmount=${totalTaxAmount}

    ${resp}=   Get consumer Appointment By Id   ${pid1}  ${apptid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     apptStatus=${apptStatus[1]}
    ...                       jCashUsedAmt=${max_limit}             creditUsedAmt=0.0

    # sleep  4s
    ${resp}=  Make Jcash Payment Consumer Mock  ${balamount}  ${bool[1]}  ${apptid}   ${pid1}  ${purpose[1]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${bal_amnt}=   Evaluate   ${avail_amnt} - ${max_limit}
    ${tot_spent}=  Evaluate    ${max_limit} + ${max_limit}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${tot_spent}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${bal_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${bal_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${max_limit}
    
    ${amt_paid}=  Evaluate   ${balamount} - ${max_limit}
    ${amt_paid}=  Convert To Number  ${amt_paid}   2

    ${resp}=  Get Payment Details  account-eq=${pid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${pid1}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${apptid}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${amt_paid}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${pid1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${apptid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}  ${purpose[1]}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${apptid}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${apptid}  netTotal=${ser_amount}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[2]}  totalAmountPaid=${totalamt}  amountDue=0.0  
    ...   totalTaxAmount=${totalTaxAmount}
    
    ${resp}=  Get consumer Appointment By Id   ${pid1}  ${apptid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]}   apptStatus=${apptStatus[1]}
    ...                       jCashUsedAmt=${tot_spent}             creditUsedAmt=0.0
    
    ${resp}=   Encrypted Provider Login   ${PUSERNAME99}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Appointment By Id  ${apptid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  apptStatus=${apptStatus[1]}    paymentStatus=${paymentStatus[2]}

    ${resp}=  Get Bill By UUId  ${apptid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERPH5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Cancel Appointment By Consumer  ${apptid}   ${pid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get consumer Appointment By Id   ${pid1}  ${apptid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get All Jaldee Cash Available
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    Set Test Variable   ${cash_id1}    ${resp.json()[0]['id']}

    ${resp}=  Get Jaldee Cash Available By Id   ${cash_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200    

    ${resp}=  Get Bill By consumer  ${apptid}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}   billStatus=${billStatus[2]}  billViewStatus=${billViewStatus[1]}  billPaymentStatus=${paymentStatus[3]}  

    ${resp}=   Encrypted Provider Login   ${PUSERNAME99}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=  Get Waitlist By Id  ${cwid}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # Verify Response  ${resp}   waitlistStatus=${wl_status[4]}  paymentStatus=${paymentStatus[3]}

    ${resp}=  Get Bill By UUId  ${apptid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['billStatus']}   Cancel

    # Verify Response  ${resp}   billStatus=${billStatus[2]}  billViewStatus=${billViewStatus[1]}  billPaymentStatus=${paymentStatus[3]}  


JD-TC-JcashPaymentByConsumer-10

    [Documentation]  Taking order from consumer side then cancel the waitlist after doing the fullpayment with jcash and mock.

    ${CUSERPH6}=  Evaluate  ${CUSERPH}+799802
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH6}${\n}
    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH6}${\n}

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH6}+4468
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL2}=   Set Variable  ${C_Email}ph${CUSERPH6}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH6}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH6}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               0.0
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH6}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.ynwtest@netvarth.com
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${code}=  Random Element    ${countryCodes}
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${code}
    
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.ynwtest@netvarth.com
    
    ${item1_total}=  Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalTaxAmount}=  Evaluate  ${item1_total} * ${gstpercentage[3]} / 100
    ${totalTaxAmount}=  twodigitfloat  ${totalTaxAmount}
    ${totalTaxAmount}=  Evaluate  ${totalTaxAmount} * 1
    ${net_total}=  Evaluate  ${item1_total} + ${deliveryCharge} + ${totalTaxAmount}
    ${net_total}=  Convert To Number   ${net_total}  2
    
    # sleep   3s
    ${resp}=   Get Cart Details    ${accId}   ${CatalogId1}   ${boolean[1]}   ${DAY1}    ${EMPTY_List}    ${item_id1}   ${item_quantity1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['id']}           ${item_id1}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['name']}         ${displayName1}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['price']}        ${promoPrice1}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['status']}       FULFILLED
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['totalPrice']}   ${item1_total}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['taxable']}      ${bool[1]}

    Should Be Equal As Strings   ${resp.json()['netTotal']}                      ${net_total}
    Should Be Equal As Strings   ${resp.json()['advanceAmount']}                 ${advanceAmount}
    Should Be Equal As Strings   ${resp.json()['jdnDiscount']}                   0.0
    Should Be Equal As Strings   ${resp.json()['jaldeeCouponDiscount']}          0.0
    Should Be Equal As Strings   ${resp.json()['totalDiscount']}                 0.0
    Should Be Equal As Strings   ${resp.json()['taxAmount']}                     ${totalTaxAmount}
    Should Be Equal As Strings   ${resp.json()['deliveryCharge']}                ${deliveryCharge}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['jCashAmt']}   ${max_limit}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['creditAmt']}  0.0
    
    Set Test Variable    ${pre_payment}    ${resp.json()['advanceAmount']}

    ${rem_amnt}=   Evaluate   ${pre_payment} - ${max_limit}

    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${pre_payment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${rem_amnt} 

    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid2}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId}  ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response  ${resp}  orderStatus=${orderStatuses[0]}   orderInternalStatus=${orderInternalStatus[1]}
    ...                       jCashUsedAmt=0.0            creditUsedAmt=0.0  
    
    ${totalamt}=  Evaluate  ${item1_total} + ${totalTaxAmount} + ${deliveryCharge}
    ${totalamt}=  Convert To Number  ${totalamt}   2
    ${balamount}=  Evaluate  ${totalamt} - ${pre_payment}
    ${balamount}=  Convert To Number  ${balamount}   2
    
    ${resp}=  Make Jcash Payment Consumer Mock  ${pre_payment}  ${bool[1]}  ${orderid2}   ${accId}  ${purpose[0]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payref}    ${resp.json()['response']['paymentRefId']}
    Should Be Equal As Strings    ${resp.json()['isJCashPaymentSucess']}        ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['isGateWayPaymentNeeded']}      ${bool[1]}

    sleep   02s
    
    ${avail_amnt}=   Evaluate   ${amt} - ${max_limit}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${max_limit}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${max_limit}
    
    ${resp}=  Get Payment Details  account-eq=${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${accId}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${orderid2}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${rem_amnt}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${accId}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${orderid2}
    Should Be Equal As Strings  ${resp.json()[1]['paymentRefId']}    ${payref} 
    Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}  ${purpose[0]}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${orderid2}  ${accId}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${orderid2}  netTotal=${item1_total}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_payment}  amountDue=${balamount}  
    ...   totalTaxAmount=${totalTaxAmount}

    ${resp}=   Get Order By Id  ${accId}  ${orderid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  orderStatus=${orderStatuses[0]}   orderInternalStatus=${orderInternalStatus[0]}
    ...                       jCashUsedAmt=${max_limit}             creditUsedAmt=0.0 

    # sleep  3s
    ${resp}=  Make Jcash Payment Consumer Mock  ${balamount}  ${bool[1]}  ${orderid2}   ${accId}  ${purpose[1]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${bal_amnt}=   Evaluate   ${avail_amnt} - ${max_limit}
    ${tot_spent}=  Evaluate    ${max_limit} + ${max_limit}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${tot_spent}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${bal_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${bal_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${max_limit}
    
    ${amt_paid}=  Evaluate   ${balamount} - ${max_limit}
    ${amt_paid}=  Convert To Number  ${amt_paid}   2

    ${resp}=  Get Payment Details  account-eq=${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${accId}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${orderid2}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${amt_paid}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${accId}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${orderid2}
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}  ${purpose[1]}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${orderid2}  ${accId}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${orderid2}  netTotal=${item1_total}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[2]}  totalAmountPaid=${totalamt}  amountDue=0.0  
    ...   totalTaxAmount=${totalTaxAmount}
    
  
    ${resp}=   Get Order By Id  ${accId}  ${orderid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  orderStatus=${orderStatuses[0]}   orderInternalStatus=${orderInternalStatus[0]}
    ...                       jCashUsedAmt=${tot_spent}             creditUsedAmt=0.0 

    ${resp}=   Encrypted Provider Login   ${PUSERNAME150}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Order by uid   ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  orderStatus=${orderStatuses[0]}    orderInternalStatus=${orderInternalStatus[0]}
    
    ${resp}=  Get Bill By UUId  ${orderid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERPH6}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Cancel Order By Consumer    ${accId}   ${orderid2}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  2s
    ${resp}=   Get Order By Id  ${accId}  ${orderid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   orderStatus=${orderStatuses[12]} 

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get All Jaldee Cash Available
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    Set Test Variable   ${cash_id1}    ${resp.json()[0]['jCashOffer']['id']}

    ${resp}=  Get Jaldee Cash Available By Id   ${cash_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200    
    
    sleep  1s
    ${resp}=  Get Bill By consumer  ${orderid2}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}   billStatus=${billStatus[2]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[4]}  

    ${resp}=   Encrypted Provider Login   ${PUSERNAME150}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=  Get Waitlist By Id  ${cwid}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # Verify Response  ${resp}   waitlistStatus=${wl_status[4]}  paymentStatus=${paymentStatus[3]}

    ${resp}=  Get Bill By UUId  ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['billStatus']}   Cancel

    # Verify Response  ${resp}   billStatus=${billStatus[2]}  billViewStatus=${billViewStatus[1]}  billPaymentStatus=${paymentStatus[3]}  


JD-TC-JcashPaymentByConsumer-11

    [Documentation]  Taking waitlist from consumer side and the consumer doing the prepayment with jcash and mock and it fails.

    ${CUSERPH1}=  Evaluate  ${CUSERPH}+866535
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH1}${\n}
    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH1}${\n}

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH1}+4468
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL2}=   Set Variable  ${C_Email}ph${CUSERPH1}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               0.0

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['jCashAmt']}      ${max_limit}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['creditAmt']}     0.0
    Set Suite Variable    ${pre_payment}    ${resp.json()['amountRequiredNow']}
    
    ${rem_amnt}=   Evaluate   ${pre_payment} - ${max_limit}
    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${pre_payment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${rem_amnt} 

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot1}+${tax}
    ${totalamt}=  Convert To Number  ${totalamt}   2
    ${balamount}=  Evaluate  ${totalamt}-${pre_payment}
    ${balamount}=  Convert To Number  ${balamount}   2
    
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    ...                       jCashUsedAmt=0.0            creditUsedAmt=0.0

    ${resp}=  Make Jcash Payment Consumer Mock  ${pre_payment}  ${bool[0]}  ${cwid}   ${pid}  ${purpose[0]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}       ${resp.json()['response']['merchantId']}  
    Set Suite Variable   ${payref}    ${resp.json()['response']['paymentRefId']}
    Should Be Equal As Strings    ${resp.json()['isJCashPaymentSucess']}        ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['isGateWayPaymentNeeded']}      ${bool[1]}

    sleep   02s
    
    ${avail_amnt}=   Evaluate   ${amt} - ${max_limit}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               0.0

    ${resp}=  Get Payment Details  account-eq=${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${max_limit}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[2]}

    Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${rem_amnt}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${cwid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentRefId']}    ${payref} 
    Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}  ${purpose[0]}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[2]}

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    # ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_payment}  amountDue=${balamount}  totalTaxAmount=${tax}

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    # ...                       jCashUsedAmt=${max_limit}             creditUsedAmt=0.0

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-JcashPaymentByConsumer-12

    [Documentation]  Taking waitlist from consumer side and the consumer doing the prepayment with jcash.

    ${CUSERPH1}=  Evaluate  ${CUSERPH}+866538
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH1}${\n}
    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH1}${\n}

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH1}+4468
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL2}=   Set Variable  ${C_Email}ph${CUSERPH1}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               0.0

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['jCashAmt']}      ${max_limit}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['creditAmt']}     0.0
    Set Suite Variable    ${pre_payment}    ${resp.json()['amountRequiredNow']}
    
    ${rem_amnt}=   Evaluate   ${pre_payment} - ${max_limit}

    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${pre_payment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${rem_amnt} 

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot1}+${tax}
    ${totalamt}=  Convert To Number  ${totalamt}   2
    ${balamount}=  Evaluate  ${totalamt}-${pre_payment}
    ${balamount}=  Convert To Number  ${balamount}   2
    
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    ...                       jCashUsedAmt=0.0            creditUsedAmt=0.0

    ${resp}=  Make Jcash Payment Consumer Mock  ${max_limit}  ${bool[1]}  ${cwid}   ${pid}  ${purpose[0]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422


JD-TC-JcashPaymentByConsumer-13

    [Documentation]  Taking waitlist from consumer side and the consumer doing the prepayment with jcash only.
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Jaldee Cash Offer  ${offer_id} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name1}=  FakerLibrary.name
    Set Suite variable   ${name1}
    ${EMPTY_List}=  Create List
    ${start_date1}=  db.get_date_by_timezone  ${tz} 
    Set Suite Variable   ${start_date1}
    ${end_date1}=  db.add_timezone_date  ${tz}  12    
    Set Suite Variable   ${end_date1}
    ${minOnlinePaymentAmt1}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt1}=  Convert To Number  ${minOnlinePaymentAmt1}  1
    Set Suite Variable   ${minOnlinePaymentAmt1}
    ${maxValidUntil1}=  db.add_timezone_date  ${tz}   26  
    Set Suite Variable   ${maxValidUntil1}
    ${validForDays1}=  Random Int  min=5   max=10 
    Set Suite Variable   ${validForDays1}
    ${ex_date1}=    db.add_timezone_date  ${tz}   ${validForDays1} 
    Set Suite Variable   ${ex_date1}
    ${maxSpendLimit1}=  Random Int  min=60   max=149 
    ${maxSpendLimit1}=  Convert To Number  ${maxSpendLimit1}  1
    ${max_limit1}=   Set Variable If  ${maxSpendLimit1} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit1}
    Set Suite Variable   ${max_limit1}
    ${issueLimit1}=  Random Int  min=1   max=5 
    Set Suite Variable   ${issueLimit1}
    ${amt1}=  Random Int  min=200   max=500  
    ${amt1}=  Convert To Number  ${amt1}   1
    Set Suite Variable   ${amt1}

    ${resp}=  Create Jaldee Cash Offer  ${name1}  ${ValueType[0]}  ${amt1}  ${start_date1}  ${end_date1}  ${JCwhen[0]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt1}  ${maxValidUntil1}  ${validForDays1}  ${max_limit1}  ${issueLimit1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id1}   ${resp.json()}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_queue      ${PUSERNAME110}
    clear_location   ${PUSERNAME110}
    clear_service    ${PUSERNAME110}
    clear_customer   ${PUSERNAME110}
    clear_Coupon     ${PUSERNAME110}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${pid}=  get_acc_id  ${PUSERNAME110}
    Set Test Variable  ${pid}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

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
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME101}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  payuVerify  ${pid}
    Log  ${resp}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME101}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}    
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid}  ${merchantid}
	
    ${p1_lid}=  Create Sample Location

    ${min_pre1}=   Random Int   min=30   max=50
    ${Tot}=   Random Int   min=200   max=1000
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Test Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Test Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Test Variable   ${Tot1}   

    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_sid1}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${sTime}=  add_timezone_time  ${tz}  2  00  
    ${eTime}=  add_timezone_time  ${tz}  2  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_lid}  ${p1_sid1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${CUSERPH1}=  Evaluate  ${CUSERPH}+1043301
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH1}${\n}
    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH1}${\n}

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH1}+4468
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL2}=   Set Variable  ${C_Email}ph${CUSERPH1}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt1}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${amt1}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt1}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date1}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${amt1}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date1}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               0.0

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['jCashAmt']}      ${max_limit1}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['creditAmt']}     0.0
    Set Test Variable    ${pre_payment}    ${resp.json()['amountRequiredNow']}
    
    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${pre_payment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   0.0

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot1}+${tax}
    ${totalamt}=  Convert To Number  ${totalamt}   2
    ${balamount}=  Evaluate  ${totalamt}-${pre_payment}
    ${balamount}=  Convert To Number  ${balamount}   2
    
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    ...                       jCashUsedAmt=0.0            creditUsedAmt=0.0

    ${resp}=  Make Jcash Payment Consumer Mock  ${pre_payment}  ${bool[1]}  ${cwid}   ${pid}  ${purpose[0]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()['isJCashPaymentSucess']}        ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['isGateWayPaymentNeeded']}      ${bool[0]}

    sleep   02s
    
    ${avail_amnt}=   Evaluate   ${amt1} - ${pre_payment}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt1}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${pre_payment}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt1}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date1}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date1}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${pre_payment}
    
    ${resp}=  Get Payment Details  account-eq=${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${pre_payment}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_payment}  amountDue=${balamount}  totalTaxAmount=${tax}

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    ...                       jCashUsedAmt=${pre_payment}             creditUsedAmt=0.0

JD-TC-JcashPaymentByConsumer-14

    [Documentation]  Taking appointment from consumer side and the consumer doing the prepayment with jcash only.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_queue    ${PUSERNAME105}
    clear_service  ${PUSERNAME105}
    clear_rating    ${PUSERNAME105}
    clear_customer   ${PUSERNAME105}

    ${pid1}=  get_acc_id  ${PUSERNAME105}
    Set Test Variable  ${pid1} 
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${businessStatus}    Random Element   ${businessStatus}  
    ${accounttype}  Random Element   ${accounttype} 
    ${fname}=   FakerLibrary.name
    ${panCardNumber}=  Generate_pan_number
    ${bankAccountNumber}=  Generate_random_value  size=16  chars=string.digits
    ${bankName}=  FakerLibrary.company
    ${ifsc}=  Generate_ifsc_code
    ${panname}=  FakerLibrary.name
    ${city}=   get_place
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME99}   ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc}  ${pan_name}  ${fname}  ${city}  ${businessStatus}  ${accounttype}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  payuVerify  ${pid1}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME99}   ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc}  ${pan_name}  ${fname}  ${city}  ${businessStatus}  ${accounttype}   
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid1}  ${merchantid}
    
    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${lid}  ${resp.json()[0]['id']}
    clear_appt_schedule   ${PUSERNAME105}

    ${ser_durtn}=   Random Int   min=2   max=10
    ${ser_amount}=   Random Int   min=200   max=500
    ${ser_amount}=  Convert To Number  ${ser_amount}  1
    Set Test Variable    ${ser_amount} 
    ${min_pre}=   Random Int   min=20   max=40
    ${min_pre}=  Convert To Number  ${min_pre}  1
    Set Test Variable    ${min_pre} 
    ${notify}    Random Element     ['True','False']
    ${notifytype}    Random Element     ['none','pushMsg','email']
    ${SERVICE1}=   FakerLibrary.name
    ${description}=  FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${description}   ${ser_durtn}  ${status[0]}  ${btype}  ${notify}   ${notifytype}  ${min_pre}  ${ser_amount}  ${bool[1]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable    ${s_id1}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${eTime1}=  add_two   ${sTime1}  ${delta}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${CUSERPH2}=  Evaluate  ${CUSERPH}+104221
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH2}${\n}
    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH2}${\n}

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH2}+4468
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL2}=   Set Variable  ${C_Email}ph${CUSERPH2}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH2}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt1}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${amt1}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt1}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date1}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${amt1}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date1}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               0.0

    ${resp}=  Get Appointment Schedules Consumer  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${totalTaxAmount}=  Evaluate  ${ser_amount} * ${gstpercentage[2]} / 100
    Set Test Variable  ${totalTaxAmount}
    
    Sleep  2s
    ${cnote}=   FakerLibrary.name
    ${EMPTY_List}=  Create List
    ${resp}=   Appointment AdvancePayment Details   ${pid1}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  ${EMPTY_List}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     ${min_pre}
    Should Be Equal As Strings  ${resp.json()['jdnDiscount']}                           0.0
    Should Be Equal As Strings  ${resp.json()['couponDiscount']}                        0.0
    Should Be Equal As Strings  ${resp.json()['providerCouponDiscount']}                0.0
    Should Be Equal As Strings  ${resp.json()['totalDiscount']}                         0.0
    Should Be Equal As Strings  ${resp.json()['netTaxAmount']}                          ${totalTaxAmount}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['jCashAmt']}          ${max_limit1}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['creditAmt']}         0.0
    
    Set Test Variable    ${pre_payment1}    ${resp.json()['amountRequiredNow']}

    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${pre_payment1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   0.0

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid1}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid1}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   apptStatus=${apptStatus[0]}
    ...                       jCashUsedAmt=0.0            creditUsedAmt=0.0  
    
    ${totalamt}=  Evaluate  ${ser_amount}+${totalTaxAmount}
    ${totalamt}=  Convert To Number  ${totalamt}   2
    ${balamount}=  Evaluate  ${totalamt}-${pre_payment1}
    ${balamount}=  Convert To Number  ${balamount}   2
    
    ${resp}=  Make Jcash Payment Consumer Mock  ${pre_payment1}  ${bool[1]}  ${apptid1}   ${pid1}  ${purpose[0]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()['isJCashPaymentSucess']}        ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['isGateWayPaymentNeeded']}      ${bool[0]}

    sleep   02s
    
    ${avail_amnt}=   Evaluate   ${amt1} - ${pre_payment1}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt1}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${pre_payment1}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt1}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date1}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date1}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${pre_payment1}
    
    ${resp}=  Get Payment Details  account-eq=${pid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${pre_payment1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${pid1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${apptid1}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${apptid1}  netTotal=${ser_amount}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_payment1}  amountDue=${balamount}  
    ...   totalTaxAmount=${totalTaxAmount}

    ${resp}=   Get consumer Appointment By Id   ${pid1}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     apptStatus=${apptStatus[1]}
    ...                       jCashUsedAmt=${pre_payment1}             creditUsedAmt=0.0


JD-TC-JcashPaymentByConsumer-15

    [Documentation]  Taking order from consumer side and the consumer doing the prepayment with jcash only.

    clear_queue    ${PUSERNAME106}
    clear_service  ${PUSERNAME106}
    clear_customer   ${PUSERNAME106}
    clear_Item   ${PUSERNAME106}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME106}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${accId}=  get_acc_id  ${PUSERNAME106}
    
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME106}.ynwtest@netvarth.com

    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${businessStatus}    Random Element   ${businessStatus}  
    ${accounttype}  Random Element   ${accounttype} 
    ${fname}=   FakerLibrary.name
    ${panCardNumber}=  Generate_pan_number
    ${bankAccountNumber}=  Generate_random_value  size=16  chars=string.digits
    ${bankName}=  FakerLibrary.company
    ${ifsc}=  Generate_ifsc_code
    ${panname}=  FakerLibrary.name
    ${city}=   get_place
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME99}   ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc}  ${pan_name}  ${fname}  ${city}  ${businessStatus}  ${accounttype}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  payuVerify  ${pid1}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME99}   ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc}  ${pan_name}  ${fname}  ${city}  ${businessStatus}  ${accounttype}   
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid1}  ${merchantid}
   
    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${displayName1}=   FakerLibrary.name 
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1float}=  twodigitfloat  ${price1}
    
    ${itemName1}=   FakerLibrary.name  
   
    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    ${promoPrice1}=   Convert To Number  ${promoPrice1}   1
   
    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode1}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id1}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  30  
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${deliveryCharge}=  Random Int  min=1   max=100
    ${deliveryCharge}=  Convert To Number   ${deliveryCharge}  1
    
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30
    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50
    
    ${catalogName}=   FakerLibrary.name  

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id1}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[1]}

    ${advanceAmount}=  Random Int  min=20   max=45
    ${advanceAmount}=  Convert To Number   ${advanceAmount}   1
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=1   max=1
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${CUSERPH3}=  Evaluate  ${CUSERPH}+106601
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH3}${\n}
    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH3}${\n}

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH3}+4468
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL2}=   Set Variable  ${C_Email}ph${CUSERPH3}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH3}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt1}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${amt1}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt1}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date1}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${amt1}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date1}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               0.0
   
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH3}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.ynwtest@netvarth.com
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${code}=  Random Element    ${countryCodes}
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${code}
    
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.ynwtest@netvarth.com
    ${EMPTY_List}=  Create List
    
    ${item1_total}=  Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalTaxAmount}=  Evaluate  ${item1_total} * ${gstpercentage[3]} / 100
    ${totalTaxAmount}=  twodigitfloat  ${totalTaxAmount}
    ${totalTaxAmount}=  Evaluate  ${totalTaxAmount} * 1
    ${net_total}=  Evaluate  ${item1_total} + ${deliveryCharge} + ${totalTaxAmount}
    ${net_total}=  Convert To Number   ${net_total}  2
    
    sleep   2s
    ${resp}=   Get Cart Details    ${accId}   ${CatalogId1}   ${boolean[1]}   ${DAY1}    ${EMPTY_List}    ${item_id1}   ${item_quantity1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['id']}           ${item_id1}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['name']}         ${displayName1}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['price']}        ${promoPrice1}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['status']}       FULFILLED
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['totalPrice']}   ${item1_total}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['taxable']}      ${bool[1]}

    Should Be Equal As Strings   ${resp.json()['netTotal']}                      ${net_total}
    Should Be Equal As Strings   ${resp.json()['advanceAmount']}                 ${advanceAmount}
    Should Be Equal As Strings   ${resp.json()['jdnDiscount']}                   0.0
    Should Be Equal As Strings   ${resp.json()['jaldeeCouponDiscount']}          0.0
    Should Be Equal As Strings   ${resp.json()['totalDiscount']}                 0.0
    Should Be Equal As Strings   ${resp.json()['taxAmount']}                     ${totalTaxAmount}
    Should Be Equal As Strings   ${resp.json()['deliveryCharge']}                ${deliveryCharge}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['jCashAmt']}   ${max_limit1}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['creditAmt']}  0.0
    
    Set Test Variable    ${pre_payment2}    ${resp.json()['advanceAmount']}

    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${pre_payment2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   0.0

    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    Verify Response  ${resp}  orderStatus=${orderStatuses[0]}   orderInternalStatus=${orderInternalStatus[1]}
    ...                       jCashUsedAmt=0.0            creditUsedAmt=0.0  
    
    ${totalamt}=  Evaluate  ${item1_total} + ${totalTaxAmount} + ${deliveryCharge}
    ${totalamt}=  Convert To Number  ${totalamt}   2
    ${balamount}=  Evaluate  ${totalamt} - ${pre_payment2}
    ${balamount}=  Convert To Number  ${balamount}   2
    
    ${resp}=  Make Jcash Payment Consumer Mock  ${pre_payment2}  ${bool[1]}  ${orderid1}   ${accId}  ${purpose[0]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()['isJCashPaymentSucess']}        ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['isGateWayPaymentNeeded']}      ${bool[0]}

    sleep   02s
    
    ${avail_amnt}=   Evaluate   ${amt1} - ${pre_payment2}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt1}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${pre_payment2}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt1}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date1}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date1}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${pre_payment2}
    
    ${resp}=  Get Payment Details  account-eq=${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${pre_payment2}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${accId}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${orderid1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${orderid1}  ${accId}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${orderid1}  netTotal=${item1_total}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_payment2}  amountDue=${balamount}  
    ...   totalTaxAmount=${totalTaxAmount}

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  orderStatus=${orderStatuses[0]}   orderInternalStatus=${orderInternalStatus[0]}
    ...                       jCashUsedAmt=${pre_payment2}             creditUsedAmt=0.0 



JD-TC-JcashPaymentByConsumer-16

    [Documentation]  Taking muliple checkin from prvider side and the consumer doing full payment with jcash and mock.

    ${CUSERPH3}=  Evaluate  ${CUSERPH}+19987351
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH3}${\n}
    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH3}${\n}

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH3}+4468
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL2}=   Set Variable  ${C_Email}ph${CUSERPH3}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH3}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${f_name}=  FakerLibrary.first_name
    ${l_name}=  FakerLibrary.last_name
    ${resp}=    get_maxpartysize_subdomain
    Set Test Variable   ${sector}        ${resp['domain']}
    Set Test Variable   ${sub_sector}    ${resp['subdomain']}
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+8706789
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_A}${\n}   
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=   Account SignUp  ${f_name}  ${l_name}  ${None}   ${sector}   ${sub_sector}  ${PUSERNAME_A}  ${pkg_id[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_A}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200  
    Set Suite Variable   ${PUSERNAME_A}

    ${accId1}=  get_acc_id  ${PUSERNAME_A}

    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+342
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH1}${\n}

    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+343
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH2}${\n}

    ${PUSERMAIL0}=   Set Variable  ${P_Email}${PUSERNAME_A}.ynwtest@netvarth.com
    ${views}=  Evaluate  random.choice($Views)  random
    Log   ${views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL0}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${sTime}=  subtract_timezone_time  ${tz}  3  25
    ${eTime}=  add_timezone_time  ${tz}  0  30   
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${fields}=   Get subDomain level Fields  ${sector}  ${sub_sector}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_sector}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${sector}  ${sub_sector}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=  Update Waitlist Settings  ${calc_mode[2]}   ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]} 

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

    ${resp}=  AddCustomer  ${CUSERPH3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH3}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=  Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${loc_id3}   ${resp.json()[0]['id']}

    ${service_amnt}=   Random Int   min=200   max=1000
    ${service_amnt}=  Convert To Number  ${service_amnt}  1 
    Set Test Variable   ${service_amnt}   

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${service_amnt}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id7}  ${resp.json()}

    ${q_name1}=    FakerLibrary.name
    Set Suite Variable    ${q_name1}
    ${strt_time1}=   add_timezone_time  ${tz}  1  00  
    Set Suite Variable    ${strt_time1}
    ${end_time1}=    add_timezone_time  ${tz}  2  20 
    Set Suite Variable    ${end_time1}  
    ${capacity}=  Random Int  min=8   max=20
    ${parallel}=  Random Int   min=1   max=1
    Set Suite Variable   ${parallel}
    Set Suite Variable   ${capacity}
    ${resp}=  Create Queue    ${q_name1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${strt_time1}  ${end_time1}   ${parallel}   ${capacity}    ${loc_id3}  ${ser_id7}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id4}   ${resp.json()}
    ${f_name}=   FakerLibrary.first_name
    ${l_name}=   FakerLibrary.last_name
    ${dob}=      FakerLibrary.date
    ${resp}=  AddFamilyMemberByProvider  ${id}  ${f_name}  ${l_name}  ${dob}  ${gender}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mem_id}  ${resp.json()}
    ${f_name}=   FakerLibrary.first_name
    ${l_name}=   FakerLibrary.last_name
    ${dob}=      FakerLibrary.date
    ${resp}=  AddFamilyMemberByProvider  ${id}  ${f_name}  ${l_name}  ${dob}  ${gender}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mem_id1}  ${resp.json()}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${id}  ${ser_id7}  ${que_id4}  ${DAY}  ${desc}  ${bool[1]}  ${mem_id}  ${mem_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wait_id1}  ${wid[0]}
    Set Suite Variable  ${wait_id2}  ${wid[1]}
    ${resp}=  Get Waitlist By Id  ${wait_id1}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id7}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${id}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${mem_id}
    ${resp}=  Get Waitlist By Id  ${wait_id2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[1]}  partySize=1  waitlistedBy=${waitlistedby[1]}  personsAhead=1
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id7}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${id}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${mem_id1}

    ${resp}=  Get Bill By UUId  ${wait_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Bill By UUId  ${wait_id2}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt1}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${amt1}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt1}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date1}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${amt1}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date1}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               0.0

    ${resp}=  Get Bill By consumer  ${wait_id1}  ${accId1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${amount}=  Evaluate    ${service_amnt} * 2
    ${resp}=  Make Jcash Payment Consumer Mock  ${amount}  ${bool[1]}  ${wait_id1}   ${accId1}  ${purpose[1]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${avail_amnt}=   Evaluate   ${amt1} - ${max_limit1}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt1}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${max_limit1}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt1}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date1}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date1}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${max_limit1}
    
    ${rem_amnt}=  Evaluate    ${amount} - ${max_limit1}

    ${resp}=  Get Payment Details  account-eq=${accId1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${max_limit1}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${accId1}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${wait_id1}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${rem_amnt}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${accId1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${wait_id1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}  ${purpose[1]}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

JD-TC-JcashPaymentByConsumer-17

    [Documentation]  create jcash offer without spent limit then Taking waitlist from prvider side and the consumer doing full payment with jcash and mock.
    

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Disable Jaldee Cash Offer  ${offer_id1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Jaldee Cash Global Max Spendlimit
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${global_max_limit}    ${resp.json()}
    # ${global_max_limit}=  Convert To Number  ${global_max_limit}  1
    # Set Suite variable   ${global_max_limit}

    ${name3}=  FakerLibrary.name
    Set Suite variable   ${name3}
    ${EMPTY_List}=  Create List
    ${start_date}=  db.get_date_by_timezone  ${tz} 
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    ${minOnlinePaymentAmt}=  Random Int  min=250  max=500
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    ${validForDays}=  Random Int  min=5   max=10 
    ${ex_date}=    db.add_timezone_date  ${tz}   ${validForDays} 
    ${maxSpendLimit}=  Random Int  min=0   max=0
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    ${max_limit}=   Set Variable   ${global_max_limit}
    ${issueLimit}=  Random Int  min=1   max=5 
    ${amt}=  Random Int  min=200   max=400
    ${amt}=  Convert To Number  ${amt}   1
    
    ${resp}=  Create Jaldee Cash Offer  ${name3}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id}   ${resp.json()}

    ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_queue      ${PUSERNAME116}
    clear_location   ${PUSERNAME116}
    clear_service    ${PUSERNAME116}
    clear_customer   ${PUSERNAME116}
    clear_Coupon     ${PUSERNAME116}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME116}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${pid}=  get_acc_id  ${PUSERNAME116}
   
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

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
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME101}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  payuVerify  ${pid}
    Log  ${resp}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME101}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}    
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid}  ${merchantid}
	
    ${p1_lid}=  Create Sample Location

    ${resp}=  Get Locations
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_lid}  ${resp.json()[0]['id']} 

    ${min_pre1}=   Random Int   min=160   max=250
    ${Tot}=   Random Int   min=200   max=1000
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    ${Tot1}=  Convert To Number  ${Tot}  1 
    
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set TEst Variable  ${p1_sid1}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${sTime}=  add_timezone_time  ${tz}  1  00  
    ${eTime}=  add_timezone_time  ${tz}   4   15
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_lid}  ${p1_sid1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${CUSERPH1}=  Evaluate  ${CUSERPH}+1045586
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH1}${\n}
    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH1}${\n}

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH1}+4468
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL2}=   Set Variable  ${C_Email}ph${CUSERPH1}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  2s

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               0.0

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['jCashAmt']}      ${max_limit}
    Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['creditAmt']}     0.0
    Set Suite Variable    ${pre_payment}    ${resp.json()['amountRequiredNow']}
    
    ${rem_amnt}=   Evaluate   ${pre_payment} - ${max_limit}
    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${pre_payment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${rem_amnt} 

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot1}+${tax}
    ${totalamt}=  Convert To Number  ${totalamt}   2
    ${balamount}=  Evaluate  ${totalamt}-${pre_payment}
    ${balamount}=  Convert To Number  ${balamount}   2
    
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    ...                       jCashUsedAmt=0.0            creditUsedAmt=0.0

    ${resp}=  Make Jcash Payment Consumer Mock  ${pre_payment}  ${bool[1]}  ${cwid}   ${pid}  ${purpose[0]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()['isJCashPaymentSucess']}        ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['isGateWayPaymentNeeded']}      ${bool[1]}

    sleep   02s
    
    ${avail_amnt}=   Evaluate   ${max_limit} - ${max_limit}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${max_limit}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${avail_amnt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${amt}
    
    ${resp}=  Get Payment Details  account-eq=${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${amt}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[1]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

    Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${rem_amnt}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${cwid}
    Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}  ${purpose[0]}
    Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_payment}  amountDue=${balamount}  totalTaxAmount=${tax}

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    ...                       jCashUsedAmt=${amt}             creditUsedAmt=0.0
    
    sleep  2s
    ${resp}=  Make Jcash Payment Consumer Mock  ${balamount}  ${bool[1]}  ${cwid}   ${pid}  ${purpose[1]}  ${bool[1]}   ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${bal_amnt}=   Evaluate   ${avail_amnt} - ${amt}
    # ${tot_spent}=  Evaluate    ${amt} + ${amt}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${amt}
    
    ${resp}=  Get Payment Details  account-eq=${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${balamount}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}  ${purpose[1]}
    Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}
    
    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[2]}  totalAmountPaid=${totalamt}  amountDue=0.0  totalTaxAmount=${tax}

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]}     waitlistStatus=${wl_status[0]}
    ...                       jCashUsedAmt=${amt}             creditUsedAmt=0.0
    
    ${resp}=   Encrypted Provider Login   ${PUSERNAME116}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Waitlist By Id  ${cwid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}    paymentStatus=${paymentStatus[2]}



JD-TC-JcashPaymentByConsumer-clear

    [Documentation]    Clear all Jcash offers from Super Admin.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_jcashoffer   ${name}
    clear_jcashoffer   ${name1}
    clear_jcashoffer   ${name3}
    
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200


# JD-TC-JcashPaymentByConsumer-18

#     [Documentation]  Taking muliple checkin from prvider side and the consumer doing full payment with jcash and mock.
    

#     ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
    
#     # ${resp}=  Disable Jaldee Cash Offer  ${offer_id1} 
#     # Log  ${resp.content}
#     # Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Jaldee Cash Global Max Spendlimit
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${global_max_limit}    ${resp.json()}
#     ${global_max_limit}=  Convert To Number  ${global_max_limit}  1
#     Set Suite variable   ${global_max_limit}

#     ${name}=  FakerLibrary.name
#     ${EMPTY_List}=  Create List
#     ${start_date}=  db.get_date_by_timezone  ${tz} 
#     Set Suite Variable   ${start_date}
#     ${end_date}=  db.add_timezone_date  ${tz}  12    
#     Set Suite Variable   ${end_date}
#     ${minOnlinePaymentAmt}=  Random Int  min=2500   max=5000  
#     ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
#     Set Suite Variable   ${minOnlinePaymentAmt}
#     ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
#     Set Suite Variable   ${maxValidUntil}
#     ${validForDays}=  Random Int  min=5   max=10 
#     Set Suite Variable   ${validForDays}
#     ${ex_date}=    db.add_timezone_date  ${tz}   ${validForDays} 
#     Set Suite Variable   ${ex_date}
#     ${maxSpendLimit}=  Random Int  min=0   max=0
#     ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
#     ${max_limit}=   Set Variable If  ${maxSpendLimit} > ${global_max_limit}   ${global_max_limit}   ${maxSpendLimit}
#     Set Suite Variable   ${max_limit}
#     ${issueLimit}=  Random Int  min=1   max=5 
#     Set Suite Variable   ${issueLimit}
#     ${amt}=  Random Int  min=20   max=40 
#     ${amt}=  Convert To Number  ${amt}   1
#     Set Suite Variable   ${amt}

#     ${resp}=  Create Jaldee Cash Offer  ${name}  ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${max_limit}  ${issueLimit}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable   ${offer_id}   ${resp.json()}

#     ${resp}=  Get Jaldee Cash Offer By Id  ${offer_id}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  SuperAdmin Logout 
#     Should Be Equal As Strings  ${resp.status_code}  200

#     clear_queue      ${PUSERNAME101}
#     clear_location   ${PUSERNAME101}
#     clear_service    ${PUSERNAME101}
#     clear_customer   ${PUSERNAME101}
#     clear_Coupon     ${PUSERNAME101}

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}   
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}   200

#     ${pid}=  get_acc_id  ${PUSERNAME101}
#     Set Suite Variable  ${pid}

#     ${resp}=  View Waitlist Settings
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}   200

#     ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
#     Log    ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get jaldeeIntegration Settings
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
#     ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
#     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
#     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

#     ${resp}=   Get jaldeeIntegration Settings
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
#     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

#     ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
#     ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200
    
#     ${resp}=  Enable Tax
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200
    
#     ${ifsc_code}=   db.Generate_ifsc_code
#     ${bank_ac}=   db.Generate_random_value  size=11   chars=${digits} 
#     ${bank_name}=  FakerLibrary.company
#     ${name}=  FakerLibrary.name
#     ${branch}=   db.get_place
#     ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME101}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     ${resp}=  payuVerify  ${pid}
#     Log  ${resp}
#     ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME101}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}    
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     ${resp}=  SetMerchantId  ${pid}  ${merchantid}
	
#     ${p1_lid}=  Create Sample Location

#     ${resp}=  Get Locations
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${p1_lid}  ${resp.json()[0]['id']} 

#     ${min_pre1}=   Random Int   min=60   max=150
#     ${Tot}=   Random Int   min=200   max=1000
#     ${min_pre1}=  Convert To Number  ${min_pre1}  1
#     Set Suite Variable   ${min_pre1}
#     ${pre_float1}=  twodigitfloat  ${min_pre1}
#     Set Suite Variable   ${pre_float1}   
#     ${Tot1}=  Convert To Number  ${Tot}  1 
#     Set Suite Variable   ${Tot1}   

#     ${P1SERVICE1}=    FakerLibrary.word
#     ${desc}=   FakerLibrary.sentence
#     ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[1]}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${p1_sid1}  ${resp.json()}

#     ${P1SERVICE2}=    FakerLibrary.word
#     Set Suite Variable   ${P1SERVICE2}
#     ${desc}=   FakerLibrary.sentence
#     ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[1]}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${p1_sid2}  ${resp.json()}
    
#     ${DAY}=  db.get_date_by_timezone  ${tz}
#     Set Suite Variable  ${DAY}
#     ${list}=  Create List  1  2  3  4  5  6  7
#     ${queue1}=    FakerLibrary.word
#     ${capacity}=  FakerLibrary.Numerify  %%
#     ${sTime}=  add_timezone_time  ${tz}  1  00  
#     ${eTime}=  add_time   4   15
#     ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_lid}  ${p1_sid1}  ${p1_sid2}  
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${p1_qid}  ${resp.json()}

#     ${resp}=  ProviderLogout
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
    
#     ${CUSERPH1}=  Evaluate  ${CUSERPH}+1045586
#     Set Suite Variable   ${CUSERPH1}
#     Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH1}${\n}
#     Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH1}${\n}

#     ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH1}+4468
#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${address}=  FakerLibrary.address
#     ${dob}=  FakerLibrary.Date
#     ${gender}    Random Element    ${Genderlist}
#     ${CUSERMAIL2}=   Set Variable  ${C_Email}ph${CUSERPH1}.ynwtest@netvarth.com
#     ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
    
#     sleep  2s

#     ${resp}=  Get Jaldee Cash Details
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
#     Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
#     Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${amt}
#     Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
#     Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
#     Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
#     Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
#     Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${amt}
#     Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
#     Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               0.0

#     ${desc}=   FakerLibrary.word
#     Set Suite Variable  ${desc}
#     ${EMPTY_List}=  Create List
#     Set Suite Variable  ${EMPTY_List}
#     ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['jCashAmt']}      ${max_limit}
#     Should Be Equal As Strings  ${resp.json()['eligibleJcashAmt']['creditAmt']}     0.0
#     Set Suite Variable    ${pre_payment}    ${resp.json()['amountRequiredNow']}
    
#     ${rem_amnt}=   Evaluate   ${pre_payment} - ${max_limit}
#     ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${pre_payment}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings   ${resp.json()}   ${rem_amnt} 

#     ${msg}=  FakerLibrary.word
#     ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     ${wid}=  Get Dictionary Values  ${resp.json()}
#     Set Suite Variable  ${cwid}  ${wid[0]} 
    
#     ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
#     ${tax}=   Evaluate  ${tax1}/100
#     ${totalamt}=  Evaluate  ${Tot1}+${tax}
#     ${totalamt}=  Convert To Number  ${totalamt}   2
#     ${balamount}=  Evaluate  ${totalamt}-${pre_payment}
#     ${balamount}=  Convert To Number  ${balamount}   2
    
#     ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
#     ...                       jCashUsedAmt=0.0            creditUsedAmt=0.0

#     ${resp}=  Make Jcash Payment Consumer Mock  ${pre_payment}  ${bool[1]}  ${cwid}   ${pid}  ${purpose[0]}  ${bool[1]}   ${bool[0]}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable   ${mer}       ${resp.json()['response']['merchantId']}  
#     Set Suite Variable   ${payref}    ${resp.json()['response']['paymentRefId']}
#     Should Be Equal As Strings    ${resp.json()['isJCashPaymentSucess']}        ${bool[1]}
#     Should Be Equal As Strings    ${resp.json()['isGateWayPaymentNeeded']}      ${bool[1]}

#     # sleep   02s
    
#     ${avail_amnt}=   Evaluate   ${amt} - ${max_limit}

#     ${resp}=  Get Jaldee Cash Details
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
#     Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                ${max_limit}
#     Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${avail_amnt}
#     Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
#     Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
#     Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
#     Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
#     Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${avail_amnt}
#     Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
#     Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               ${max_limit}
    
#     ${resp}=  Get Payment Details  account-eq=${pid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()[0]['amount']}          ${max_limit}
#     Should Be Equal As Strings  ${resp.json()[0]['accountId']}       ${pid}
#     Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}     ${Payment_Mode[1]}
#     Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}         ${cwid}
#     Should Be Equal As Strings  ${resp.json()[0]['status']}          ${Payment_Statuses[0]}

#     Should Be Equal As Strings  ${resp.json()[1]['amount']}          ${rem_amnt}
#     Should Be Equal As Strings  ${resp.json()[1]['accountId']}       ${pid}
#     Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}     ${Payment_Mode[0]}
#     Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}         ${cwid}
#     Should Be Equal As Strings  ${resp.json()[1]['paymentRefId']}    ${payref} 
#     Should Be Equal As Strings  ${resp.json()[1]['paymentPurpose']}  ${purpose[0]}
#     Should Be Equal As Strings  ${resp.json()[1]['status']}          ${Payment_Statuses[0]}

#     ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
#     ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_payment}  amountDue=${balamount}  totalTaxAmount=${tax}

#     ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
#     ...                       jCashUsedAmt=${max_limit}             creditUsedAmt=0.0

# *** comment ***

*** comment ***

JD-TC-JcashPaymentByConsumer-3

    [Documentation]  Taking waitlist from consumer side and the consumer doing the prepayment without jcash and then do the full payment with jcash.
    
    ${CUSERPH1}=  Evaluate  ${CUSERPH}+104322201
    Set Suite Variable   ${CUSERPH1}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH1}${\n}
    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH1}${\n}

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH1}+4468
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname}
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL2}=   Set Variable  ${C_Email}ph2424.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${cons_id}   ${resp.json()['id']}                                                         

    ${cid1}=  get_id  ${CUSERPH1}
    Set Suite Variable   ${cid1}

    ${resp}=  Get Jaldee Cash Details
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['totCashAwarded']}                                              ${amt}
    Should Be Equal As Strings  ${resp.json()['totCashSpent']}                                                0.0
    Should Be Equal As Strings  ${resp.json()['totCashAvailable']}                                            ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpdLife']}                               0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpd30Days']}                             0.0
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['totCashExpNext30Days']}                          ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiringCashExpDt']}                         ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashAmt']}    ${amt}
    Should Be Equal As Strings  ${resp.json()['cashExpiry']['nextExpiryCashes'][0]['nextExpiringCashExpDt']}  ${ex_date}
    Should Be Equal As Strings  ${resp.json()['cashSpend']['lastSpendCashTot']}                               0.0

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${pre_payment}    ${resp.json()['amountRequiredNow']}
    
    ${rem_amnt}=   Evaluate   ${pre_payment} - ${max_limit}
    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${pre_payment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${rem_amnt} 

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot1}+${tax}
    ${balamount}=  Evaluate  ${totalamt}-${pre_payment}
    
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

 