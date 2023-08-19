*** Settings ***
Test Teardown     Delete All Sessions
Force Tags        Bill
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

Get Service payment modes
    [Arguments]  ${accountId}   ${serviceId}   ${paymentPurpose}
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /consumer/payment/modes/service/${accountId}/${serviceId}/${paymentPurpose}    expected_status=any
    [Return]  ${resp}
    
Get payment modes
    [Arguments]  ${accountId}   ${serviceId}   ${paymentPurpose}
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /consumer/payment/modes/service/${accountId}/${serviceId}/${paymentPurpose}    expected_status=any
    [Return]  ${resp}

# Get convenienceFee Details 
#     [Arguments]  ${accountId}     ${profileId}    ${amount}
#     ${data}=    Create Dictionary    profileId=${profileId}  amount=${amount}
#     ${data}=  json.dumps  ${data}
#     Check And Create YNW Session
#     ${resp}=  PUT On Session  ynw   /consumer/payment/modes/convenienceFee/${accountId}   data=${data}   expected_status=any

# Get convenienceFee Details 
#     [Arguments]  ${accountId}     ${profileId}    ${amount}
#     ${data}=    Create Dictionary    profileId=${profileId}  amount=${amount}
#     ${data}=  json.dumps  ${data}
#     Check And Create YNW Session
#     ${resp}=   PUT On Session  ynw  /consumer/payment/modes/convenienceFee/${accountId}   data=${data}   expected_status=any
#     [Return]  ${resp}

Get convenienceFee Details 
    [Arguments]  ${accountId}     ${profileId}    ${amount}
    ${data}=    Create Dictionary    profileId=${profileId}  amount=${amount}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=   PUT On Session  ynw  /consumer/payment/modes/MockConvenienceFee/${accountId}   data=${data}   expected_status=any
    [Return]  ${resp}

*** Variables ***

${digits}       0123456789
${service_duration}   2
${parallel}           1
${self}               0
@{provider_list}
${start}              140
${jcoupon1}   CouponMul00
${chargeConsumer}    GatewayAPi

${id}            spDefaultProfile
${displayName}   SP Default Payment Profile
${id1}            spDefaultProfile1
${displayName1}   Default Payment Profile2


${SERVICE1}     manicure 
${SERVICE2}     pedicure
@{dom_list}
@{multiloc_providers}
${countryCode}   +91

${item1}   ITEM1
${item2}   ITEM2
${item3}   ITEM3
${item4}   ITEM4
${item5}   ITEM5
${CUSERPH}      ${CUSERNAME}

@{multiples}  10  20  30   40   50
${SERVICE1}   MakeUp
${SERVICE2}   Coloring

*** Test Cases ***

JD-TC-paymentprofiles-1

    [Documentation]  do the prepayment to jaldee bank without convenienceFee.(for online checkin, appointment and order).
    
    # ${billable_doms}=  get_billable_domain
    # Log  ${billable_doms}
    # Set Suite Variable  ${dom}  ${billable_doms[0][0]}
    # Set Suite Variable  ${sub_dom}  ${billable_doms[1][0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    # Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable  ${dom}  ${decrypted_data['sector']}
    Set Suite Variable  ${sub_dom}  ${decrypted_data['subSector']}


    ${pid}=  get_acc_id  ${PUSERNAME190}
    Set Suite Variable   ${pid}

    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME190}+15566124
    ${ph2}=  Evaluate  ${PUSERNAME190}+25566128
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${PUSERNAME190}.ynwtest@netvarth.com  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile With Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200
    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME190}+15566124
    ${ph2}=  Evaluate  ${PUSERNAME190}+25566128
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${PUSERNAME190}.ynwtest@netvarth.com  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile With Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${dom}   ${sub_dom}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200


    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=  Enable Waitlist
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # sleep   01s
    
    ${resp}=   Get payment profiles  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${id}  ${resp.json()[0]['profileId']}

    ${pid}=  get_acc_id  ${PUSERNAME190}
    Set Suite Variable   ${pid}

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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  ProviderLogout
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
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


    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
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

JD-TC-paymentprofiles-1.1

    [Documentation]  do the prepayment to jaldee bank with convenienceFee.(for online checkin, appointment and order).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Destination Bank  customizedJBProfile  ${bool[1]}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get payment profiles  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Bank Details  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

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

    ${resp}=    Get convenienceFee Details     ${pid}    customizedJBProfile   ${min_pre1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${convfee}  ${resp.json()[0]['convenienceFee']}  

    ${resp}=    Get Service payment modes    ${pid}    ${s_id}    ${purpose[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['isJaldeeBank']}    ${bool[1]}
    Set Suite Variable    ${proid}  ${resp.json()[0]['profileId']}

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Bill By UUId  ${cwid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  ProviderLogout
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}    jaldeeConvenienceFee=${convfee}  profileId=${proid}    paymentGateway=RAZORPAY    paymentSettingsId=1
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Bill By UUId  ${cwid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
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


    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
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


JD-TC-paymentprofiles-1.2

    [Documentation]  do the prepayment to jaldee bank with convenienceFee.(total amount)(for online checkin, appointment and order).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get payment profiles  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Bank Details  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[0]}  advancePaymentProfileId=customizedJBProfile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
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

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 

    ${resp}=    Get convenienceFee Details     ${pid}    customizedJBProfile   ${min_pre1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${totalamt}  ${resp.json()[0]['amountWithAllCharges']}  
    Set Test Variable   ${convfee}  ${resp.json()[0]['convenienceFee']} 

    ${resp}=    Get Service payment modes    ${pid}    ${s_id}    ${purpose[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['isJaldeeBank']}    ${bool[1]}
    Set Suite Variable    ${proid}  ${resp.json()[0]['profileId']}
    # ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Bill By UUId  ${cwid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  ProviderLogout
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}   jaldeeConvenienceFee=${convfee}  profileId=${proid}    paymentGateway=RAZORPAY    paymentSettingsId=1
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Bill By UUId  ${cwid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
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


    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
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


JD-TC-paymentprofiles-1.3

    [Documentation]  do the prepayment to jaldee bank with convenienceFee.(Pay the Two Amount Supprate)(for online checkin, appointment and order).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get payment profiles  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Bank Details  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[0]}  advancePaymentProfileId=customizedJBProfile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
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

    ${SERVICE12}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE12}  ${desc}   ${ser_duratn}  ${status[0]}   ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}
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

    ${resp}=    Get convenienceFee Details     ${pid}    customizedJBProfile   ${min_pre1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${convfee}  ${resp.json()[0]['convenienceFee']}  


    ${resp}=    Get Service payment modes    ${pid}    ${s_id}    ${purpose[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['isJaldeeBank']}    ${bool[0]}
    Set Suite Variable    ${proid}  ${resp.json()[0]['profileId']}

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Bill By UUId  ${cwid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  ProviderLogout
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}   jaldeeConvenienceFee=${convfee}   profileId=${proid}    paymentGateway=RAZORPAY    paymentSettingsId=1
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${amounttopay}=   Evaluate   ${Tot1}-${min_pre1}

    ${resp}=  Make payment Consumer Mock  ${pid}  ${amounttopay}  ${purpose[1]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}   jaldeeConvenienceFee=${convfee}   profileId=${proid}    paymentGateway=RAZORPAY    paymentSettingsId=1
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
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
    Should Be Equal As Strings  ${resp.json()[1]['amount']}  ${amounttopay}
    


    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
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

JD-TC-paymentprofiles-2.1

    [Documentation]  do the prepayment to jaldee bank .(for online appointment ).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[0]}  advancePaymentProfileId=customizedJBProfile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${lid}=  Create Sample Location

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${min_pre}=  Convert To Number  ${min_pre}  1
    Set Suite Variable   ${min_pre}
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    clear_appt_schedule   ${PUSERNAME190}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=   Get Account Payment Settings 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}      ${parallel}    ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${sch_id}

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${random slots}=  Evaluate  random.sample(${slots},2)   random
    Set Test Variable   ${slot1}   ${random slots[0]}
    Set Test Variable   ${slot2}   ${random slots[1]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[7]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=    Get convenienceFee Details     ${pid}    customizedJBProfile   ${min_pre1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${convfee}  ${resp.json()[0]['convenienceFee']}  

    ${resp}=    Get Service payment modes    ${pid}    ${s_id}    ${purpose[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['isJaldeeBank']}    ${bool[1]}
    Set Suite Variable    ${proid}  ${resp.json()[0]['profileId']}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  ProviderLogout
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre}  ${purpose[0]}  ${apptid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${jdconID}   jaldeeConvenienceFee=${convfee}   profileId=${proid}    paymentGateway=RAZORPAY    paymentSettingsId=1
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get Bill By UUId  ${apptid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${apptid1}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[7]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY1}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone   ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    Set Test Variable  ${paymentPurpose-eq}      prePayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    
    ${cwid}=  Convert To String  ${apptid1} 
    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-paymentprofiles-2.2

    [Documentation]  do the prepayment to jaldee bank with convenienceFee.(for online appointment ).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[0]}  advancePaymentProfileId=customizedJBProfile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${lid}=  Create Sample Location

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${min_pre}=  Convert To Number  ${min_pre}  1
    Set Suite Variable   ${min_pre}
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    clear_appt_schedule   ${PUSERNAME190}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=   Get Account Payment Settings 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}      ${parallel}    ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${sch_id}

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${random slots}=  Evaluate  random.sample(${slots},2)   random
    Set Test Variable   ${slot1}   ${random slots[0]}
    Set Test Variable   ${slot2}   ${random slots[1]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[7]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=    Get convenienceFee Details     ${pid}    customizedJBProfile   ${min_pre}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${convfee}  ${resp.json()[0]['convenienceFee']} 

    ${resp}=    Get Service payment modes    ${pid}    ${s_id}    ${purpose[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['isJaldeeBank']}    ${bool[0]}
    Set Suite Variable    ${proid}  ${resp.json()[0]['profileId']}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  ProviderLogout
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre}  ${purpose[0]}  ${apptid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${jdconID}   jaldeeConvenienceFee=${convfee}   profileId=${proid}    paymentGateway=RAZORPAY    paymentSettingsId=1
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Bill By UUId  ${apptid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${apptid1}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY1}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone   ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    Set Test Variable  ${paymentPurpose-eq}      prePayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    
    ${cwid}=  Convert To String  ${apptid1} 
    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-paymentprofiles-2.3

    [Documentation]  do the prepayment to jaldee bank with convenienceFee.(total amount)(for online appointment ).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[0]}  advancePaymentProfileId=customizedJBProfile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${lid}=  Create Sample Location

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${min_pre}=  Convert To Number  ${min_pre}  1
    Set Suite Variable   ${min_pre}
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${SERVICE3}=  FakerLibrary.word
    ${resp}=  Create Service  ${SERVICE3}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    clear_appt_schedule   ${PUSERNAME190}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=   Get Account Payment Settings 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}      ${parallel}    ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${sch_id}

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${random slots}=  Evaluate  random.sample(${slots},2)   random
    Set Test Variable   ${slot1}   ${random slots[0]}
    Set Test Variable   ${slot2}   ${random slots[1]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[7]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=    Get convenienceFee Details     ${pid}    customizedJBProfile   ${min_pre}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${convfee}  ${resp.json()[0]['convenienceFee']}  

    ${resp}=    Get Service payment modes    ${pid}    ${s_id}    ${purpose[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['isJaldeeBank']}    ${bool[0]}
    Set Suite Variable    ${proid}  ${resp.json()[0]['profileId']}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  ProviderLogout
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre}  ${purpose[0]}  ${apptid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${jdconID}   jaldeeConvenienceFee=${convfee}   profileId=${proid}    paymentGateway=RAZORPAY    paymentSettingsId=1
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Bill By UUId  ${apptid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${apptid1}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY1}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone   ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    Set Test Variable  ${paymentPurpose-eq}      prePayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    
    ${cwid}=  Convert To String  ${apptid1} 
    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-paymentprofiles-3.1    

    [Documentation]  do the prepayment to jaldee bank(for online Order ).

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[0]}  advancePaymentProfileId=customizedJBProfile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${accId}=  get_acc_id  ${PUSERNAME190}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME190}.ynwtest@netvarth.com

    # ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get payment profiles  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

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

    ${advanceAmount}=  Random Int  min=1   max=1000
    # ${advanceAmount}=  Convert To Number  ${advanceAmount}  1
   
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

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get convenienceFee Details     ${pid}    customizedJBProfile   ${advanceAmount}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${convfee}  ${resp.json()[0]['convenienceFee']} 

    ${cid1}=  get_id  ${CUSERNAME20}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME20}   ${PASSWORD}
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
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Suite Variable  ${address}

    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.ynwtest@netvarth.com
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Bill By UUId  ${orderid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  ProviderLogout
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Make payment Consumer Mock  ${pid}  ${advanceAmount}  ${purpose[0]}  ${orderid1}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid1}    jaldeeConvenienceFee=${convfee}   profileId=customizedJBProfile    paymentGateway=RAZORPAY    paymentSettingsId=1
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${orderid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   02s

    ${resp}=  Get Bill By consumer  ${orderid1}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${advanceAmount}=  Convert To Number  ${advanceAmount}  1 
    ${resp}=  Get Payment By UUId  ${orderid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${orderid1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${advanceAmount}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${startDate}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone   ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${startDate}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    Set Test Variable  ${paymentPurpose-eq}      prePayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    
    ${cwid}=  Convert To String  ${orderid1} 
    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-paymentprofiles-3.2

    [Documentation]  do the prepayment to jaldee bank with convenienceFee(for online Order ).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${accId}=  get_acc_id  ${PUSERNAME190}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME190}.ynwtest@netvarth.com

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[0]}  advancePaymentProfileId=customizedJBProfile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get payment profiles  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

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

    ${advanceAmount}=  Random Int  min=10   max=50
    ${advanceAmount}=  Convert To Number  ${advanceAmount}  1
   
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

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME20}   ${PASSWORD}
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
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Suite Variable  ${address}

    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.ynwtest@netvarth.com
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get convenienceFee Details     ${pid}    customizedJBProfile   ${advanceAmount}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${convfee}  ${resp.json()[0]['convenienceFee']}

    ${resp}=    Get Service payment modes    ${pid}    ${s_id}    ${purpose[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['isJaldeeBank']}    ${bool[0]}
    Set Suite Variable    ${proid}  ${resp.json()[0]['profileId']}

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Bill By UUId  ${orderid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  ProviderLogout
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Make payment Consumer Mock  ${pid}  ${advanceAmount}  ${purpose[0]}  ${orderid1}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${jdconID}   jaldeeConvenienceFee=${convfee}  profileId=customizedJBProfile    paymentGateway=RAZORPAY    paymentSettingsId=1
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${orderid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   02s

    ${resp}=  Get Bill By consumer  ${orderid1}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${orderid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${orderid1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${advanceAmount}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${startDate}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone   ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${startDate}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    Set Test Variable  ${paymentPurpose-eq}      prePayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    
    ${cwid}=  Convert To String  ${orderid1} 
    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-paymentprofiles-4.1
#  with convenienceFee
    [Documentation]  do the payment to jaldee bank(for online Donation ).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    delete_donation_service  ${PUSERNAME190}
    clear_service   ${PUSERNAME190}
    clear_queue      ${PUSERNAME190}
    clear_location   ${PUSERNAME190}

    ${pid}=  get_acc_id  ${PUSERNAME190}
    Set Suite Variable  ${pid}
        
    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[0]}  advancePaymentProfileId=customizedJBProfile
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
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
    ${total_amnt}=   Random Int   min=100   max=500
    ${total_amnt}=  Convert To Number  ${total_amnt}   1
    ${SERVICE5}=   FakerLibrary.name
    ${resp}=  Create Donation Service  ${SERVICE5}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${total_amnt}   ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${sid1}  ${resp.json()}

    ${resp}=   Consumer Login  ${CUSERNAME8}   ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${con_id}=  get_id  ${CUSERNAME8}
    Set Suite Variable  ${con_id}
    ${acc_id}=  get_acc_id  ${PUSERNAME190}
    Set Suite Variable  ${acc_id}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${CUR_DAY}
    ${don_amt}=   Random Int   min=1000   max=4000
    ${mod}=  Evaluate  ${don_amt}%${multiples[0]}
    ${don_amt}=  Evaluate  ${don_amt}-${mod}
    ${don_amt}=  Convert To Number  ${don_amt}  1
    ${don_amt_float}=  twodigitfloat  ${don_amt}

    Set Suite Variable  ${don_amt}
    ${resp}=  Donation By Consumer  ${con_id}  ${sid1}  ${loc_id1}  ${don_amt}  ${fname1}  ${lname1}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${acc_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
        
    ${don_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${don_id}  ${don_id[0]}
    ${resp}=  Get Consumer Donation By Id  ${don_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}    uid=${don_id}   date=${CUR_DAY}  billPaymentStatus=${paymentStatus[0]}  donationAmount=${don_amt}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}  ${con_id}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${loc_id1}

    ${resp}=  Get Bill By consumer  ${don_id}  ${acc_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get convenienceFee Details     ${pid}    customizedJBProfile   ${don_amt}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${convfee}  ${resp.json()[0]['convenienceFee']}
        
    ${resp}=  Make payment Consumer Mock  ${acc_id}  ${don_amt}  ${purpose[5]}  ${don_id}  ${sid1}  ${bool[0]}   ${bool[1]}  ${con_id}   jaldeeConvenienceFee=${convfee}   profileId=${proid}    paymentGateway=RAZORPAY    paymentSettingsId=1
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${don_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Payment Details By UUId    ${don_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mock_id}  ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${don_id}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${pay_mode_selfpay}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${don_amt} 
    Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${con_id}   
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}  ${payment_modes[5]}  
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${acc_id}  
    Should Be Equal As Strings  ${resp.json()[0]['paymentGateway']}  RAZORPAY    

    sleep   02s

    ${resp}=  Get Bill By consumer  ${don_id}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${don_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${don_id}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${don_amt}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${CUR_DAY}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone   ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${CUR_DAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    Set Test Variable  ${paymentPurpose-eq}      prePayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    
    ${cwid}=  Convert To String  ${don_id} 
    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-paymentprofiles-P2

    [Documentation]  do the bill payment to jaldee bank(for online checkin).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get payment profiles  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[0]}  advancePaymentProfileId=customizedJBProfile
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=150   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   
    ${ser_duratn}=   Random Int   min=10   max=30

    ${SERVICE2}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${ser_duratn}  ${status[0]}   ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}

    ${lid}=  Create Sample Location

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    # ${sTime}=  db.get_time_by_timezone   ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  1  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id1}   
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
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY}  ${s_id1}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 

    ${resp}=    Get convenienceFee Details     ${pid}    customizedJBProfile   ${Tot1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${convfee}  ${resp.json()[0]['convenienceFee']}
        
    ${resp}=  Make payment Consumer Mock  ${pid}  ${Tot1}  ${purpose[1]}  ${cwid}  ${s_id1}  ${bool[0]}   ${bool[1]}  ${cid1}  jaldeeConvenienceFee=${convfee}   profileId=${proid}    paymentGateway=RAZORPAY    paymentSettingsId=1
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Bill By UUId  ${cwid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
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


    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
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

JD-TC-paymentprofiles-P2.1

    [Documentation]  do the bill payment to jaldee bank(for online appointment).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get payment profiles  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[0]}  advancePaymentProfileId=customizedJBProfile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${lid}=  Create Sample Location

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${servicecharge}=  Convert To Number  ${servicecharge}  1
    Set Suite Variable   ${servicecharge}
    ${srv_duration}=   Random Int   min=10   max=20
    ${SERVICE1}=    FakerLibrary.word
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    clear_appt_schedule   ${PUSERNAME190}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=   Get Account Payment Settings 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}      ${parallel}    ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${sch_id}

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${random slots}=  Evaluate  random.sample(${slots},2)   random
    Set Test Variable   ${slot1}   ${random slots[0]}
    Set Test Variable   ${slot2}   ${random slots[1]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[7]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=    Get Service payment modes    ${pid}    ${s_id}    ${purpose[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['isJaldeeBank']}    ${bool[0]}
    Set Suite Variable    ${proid}  ${resp.json()[0]['profileId']}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  ProviderLogout
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get convenienceFee Details     ${pid}    customizedJBProfile   ${servicecharge}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${convfee}  ${resp.json()[0]['convenienceFee']}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${servicecharge}  ${purpose[1]}  ${apptid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${jdconID}   jaldeeConvenienceFee=${convfee}  profileId=${proid}    paymentGateway=RAZORPAY    paymentSettingsId=1
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Bill By UUId  ${apptid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Bill By consumer  ${apptid1}  ${pid}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[7]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${servicecharge}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY1}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone   ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    Set Test Variable  ${paymentPurpose-eq}      prePayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    
    ${cwid}=  Convert To String  ${apptid1} 
    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-paymentprofiles-P3.1

    [Documentation]  do the bill payment to my own bank(for online checkin, appointment and order).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get payment profiles  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${pid}=  get_acc_id  ${PUSERNAME186}
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

    ${resp}=   Create Bank Details   ${bank_name}  ${bank_ac}   ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num}  ${PUSERNAME186}
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
    ${destBanks}=   Create Dictionary   bankID=${bank_id1}   payPct=50   fixedPctValueMin=3   fixedPctValueMax=5   fixed=${EMPTY}     
    ${destBanks}=  Create List   ${destBanks}
    ${fee}=   Create List   incl  excl
    ${fromBank}=   Create Dictionary   bankID=${bank_id1}   maxLimit=100000   fee=${fee}  


    ${chargeConsumer}=  Create List   fixedAmount
    ${convenienceFee}=   Create Dictionary   chargeConsumer=${chargeConsumer}   fixedAmountValue=50   fixedPctValue=0  



    ${resp}=   Payment Profile  ${id}  ${displayName}   ${desc}  ${type}  ${txnTypes}   ${destBank}  ${boolean[1]}   ${paymode}  ${boolean[1]}
    ...   ${indianPaymodes1}   ${boolean[1]}   ${internationalPaymodes}  ${splitPayment}   ${destBanks}   ${fromBank}   
    # convenienceFee=${convenienceFee}

    ${resp1}=   Payment Profile  ${id1}  ${displayName1}   ${desc}  ${type}  ${txnTypes}   ${destBank}  ${boolean[1]}   ${paymode}  ${boolean[1]}
    ...   ${indianPaymodes1}   ${boolean[1]}   ${internationalPaymodes}  ${splitPayment}   ${destBanks}   ${fromBank}    

    ${profiles}=  Setting Payment Profile  ${resp}  ${resp1} 
    
    ${combined_json}=  Payment Profile Json  ${profiles}   
    
    ${payment_profile}=  payment_profiles   ${combined_json}  ${pid}
    
    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
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

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[2]}  advancePaymentProfileId=${id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

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

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Bill By UUId  ${cwid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  ProviderLogout
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Service payment modes    ${pid}    ${s_id}    ${purpose[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get convenienceFee Details     ${pid}    ${id1}   ${Tot1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${convfee}  ${resp.json()[0]['convenienceFee']}
  
    ${resp}=  Make payment Consumer Mock  ${pid}  ${Tot1}  ${purpose[1]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}    profileId=${id1}    paymentGateway=RAZORPAY    paymentSettingsId=1
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Bill By UUId  ${cwid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
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


    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone   ${tz}
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


JD-TC-paymentprofiles-P3.2

    [Documentation]  do the bill payment to my own bank(for  appointment).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[2]}  advancePaymentProfileId=${id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${lid}=  Create Sample Location

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${servicecharge}=  Convert To Number  ${servicecharge}  1
    Set Suite Variable   ${servicecharge}
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    clear_appt_schedule   ${PUSERNAME186}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=   Get Account Payment Settings 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}      ${parallel}    ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${sch_id}

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${random slots}=  Evaluate  random.sample(${slots},2)   random
    Set Test Variable   ${slot1}   ${random slots[0]}
    Set Test Variable   ${slot2}   ${random slots[1]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[7]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=    Get Service payment modes    ${pid}    ${s_id}    ${purpose[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['isJaldeeBank']}    ${bool[1]}
    Set Suite Variable    ${proid}  ${resp.json()[0]['profileId']}

    ${resp}=  Make payment Consumer Mock  ${pid}  ${servicecharge}  ${purpose[1]}  ${apptid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${jdconID}   profileId=${proid}    paymentGateway=RAZORPAY    paymentSettingsId=1
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${apptid1}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[7]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${servicecharge}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY1}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone   ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    Set Test Variable  ${paymentPurpose-eq}      billPayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    
    ${cwid}=  Convert To String  ${apptid1} 
    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-paymentprofiles-P3.3

    [Documentation]  do the bill payment to my own bank(for  order).

    # clear_Item   ${PUSERNAME186}
    # clear_Catalog   ${PUSERNAME186}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get payment profiles  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${id}  ${resp.json()[0]['profileId']}

    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[2]}  advancePaymentProfileId=${id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    clear_queue    ${PUSERNAME186}
    clear_service  ${PUSERNAME186}
    clear_customer   ${PUSERNAME186}
    clear_Item   ${PUSERNAME186}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${accId}=  get_acc_id  ${PUSERNAME186}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME186}.ynwtest@netvarth.com

    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

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
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
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

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${cid1}   ${resp.json()['id']}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME20}   ${PASSWORD}
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
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Suite Variable  ${address}

    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.ynwtest@netvarth.com
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Service payment modes    ${pid}    0   ${purpose[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Make payment Consumer Mock  ${pid}  ${price1float}  ${purpose[1]}  ${orderid1}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid1}     profileId=customizedJBProfile    paymentGateway=RAZORPAY    paymentSettingsId=1
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${orderid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   02s

    ${resp}=  Get Bill By consumer  ${orderid1}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${orderid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${orderid1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${advanceAmount}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY1}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone   ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${paymentMode-eq}         Mock
    Set Test Variable  ${paymentPurpose-eq}      billPayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    
    ${cwid}=  Convert To String  ${apptid1} 
    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-paymentprofiles-5

    [Documentation]  assign the same srevice to multiple profiles then do the payment.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME186}
    Set Suite Variable  ${pid}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[1]}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME186}
    Set Suite Variable   ${pid}

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

    ${serviceids}=   Create List   ${s_id}
    ${resp}=   Assign Profile To Service   ${id}   ${serviceids}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=   Assign Profile To Service   ${id1}   ${serviceids}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

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

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 

    ${resp}=  Make payment Consumer Mock  ${pid}  ${Tot1}  ${purpose[1]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
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


    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone   ${tz}
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



JD-TC-paymentprofiles-7s

    [Documentation]  disable one service and do the bill payment.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME186}
    
    # ${resp}=   Get payment profiles  
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=   Get Bank Details By Id  ${bank_id1}  
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[1]}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME186}
    Set Suite Variable   ${pid}

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

    ${serviceids}=   Create List   ${s_id}
    ${resp}=   Assign Profile To Service   ${id}   ${serviceids}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Assign Profile To Service   ${id1}   ${serviceids}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

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

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 

    ${resp}=  ConsumerLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable service  ${sid} 
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${SERVICE_EXISTS_IN_WAITLIST}


    # ${resp}=   Get Service By Id  ${sid}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  name=${SERVICE1}  description=${desc}  serviceDuration=${ser_duratn}   notification=${bool[1]}  notificationType=${notifytype[2]}  status=${status[0]}  bType=${btype}   

    # ${resp}=  ProviderLogout
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Make payment Consumer Mock  ${pid}  ${Tot1}  ${purpose[1]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}   
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Bill By UUId  ${cwid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    # sleep  2s

    # ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Payment By UUId  ${cwid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${cwid}
    # Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    # # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[7]}
    # Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre1}
    # Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY}


    # ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone   ${tz}
    # ${TODAY_dd_mm_yyyy} =	Convert Date	${DAY}	result_format=%d/%m/%Y
    # Set Suite Variable  ${Date_Time}   ${TODAY_dd_mm_yyyy} ${ReportTime}
    # Set Test Variable  ${status-eq}              SUCCESS
    # Set Test Variable  ${paymentMode-eq}         Mock
    # Set Test Variable  ${paymentPurpose-eq}      billPayment
    # Set Test Variable  ${reportType}              PAYMENT
    # Set Test Variable  ${reportDateCategory}      TODAY
    
    # ${cwid}=  Convert To String  ${cwid} 
    # ${filter}=  Create Dictionary 
    # ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${token_id}   ${resp.json()}

    # sleep  2s

    # ${resp}=  Get Report Status By Token Id  ${token_id}  
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-paymentprofiles-8

    [Documentation]  do the donation payment to my own bank.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[2]}  advancePaymentProfileId=${id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    delete_donation_service  ${PUSERNAME186}
    clear_service   ${PUSERNAME186}
    clear_queue      ${PUSERNAME186}
    clear_location   ${PUSERNAME186}

    ${pid}=  get_acc_id  ${PUSERNAME186}
    Set Suite Variable  ${pid}
        
    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
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
    ${total_amnt}=   Random Int   min=100   max=500
    ${total_amnt}=  Convert To Number  ${total_amnt}   1
    ${SERVICE5}=   FakerLibrary.name
    ${resp}=  Create Donation Service  ${SERVICE5}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${total_amnt}   ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${sid1}  ${resp.json()}

    ${resp}=   Consumer Login  ${CUSERNAME8}   ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${con_id}=  get_id  ${CUSERNAME8}
    Set Suite Variable  ${con_id}
    ${acc_id}=  get_acc_id  ${PUSERNAME186}
    Set Suite Variable  ${acc_id}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${CUR_DAY}
        # ${don_amt}=  Evaluate  ${min_don_amt}*${multiples[0]}
        # ${don_amt_float}=  twodigitfloat  ${don_amt}
    ${don_amt}=   Random Int   min=1000   max=4000
    ${mod}=  Evaluate  ${don_amt}%${multiples[0]}
    ${don_amt}=  Evaluate  ${don_amt}-${mod}
    ${don_amt}=  Convert To Number  ${don_amt}  1
    ${don_amt_float}=  twodigitfloat  ${don_amt}

    Set Suite Variable  ${don_amt}
    ${resp}=  Donation By Consumer  ${con_id}  ${sid1}  ${loc_id1}  ${don_amt}  ${fname1}  ${lname1}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${acc_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
        
    ${don_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${don_id}  ${don_id[0]}
    ${resp}=  Get Consumer Donation By Id  ${don_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}    uid=${don_id}   date=${CUR_DAY}  billPaymentStatus=${paymentStatus[0]}  donationAmount=${don_amt}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}  ${con_id}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${loc_id1}

    ${resp}=  Get Bill By consumer  ${don_id}  ${acc_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
        
    ${resp}=  Make payment Consumer Mock  ${acc_id}  ${total_amnt}  ${purpose[5]}  ${don_id}  ${sid1}  ${bool[0]}   ${bool[1]}  ${con_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    ${resp}=  Get Payment Details By UUId    ${don_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mock_id}  ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${don_id}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${pay_mode_selfpay}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${total_amnt} 
    Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${con_id}   
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}  ${payment_modes[5]}  
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${acc_id}  
    Should Be Equal As Strings  ${resp.json()[0]['paymentGateway']}  RAZORPAY

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone   ${tz}
    ${ReportTime}=  db.get_time_by_timezone  ${tz}
    ${TODAY_dd_mm_yyyy} =	Convert Date	${CUR_DAY}	result_format=%d/%m/%Y
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

JD-TC-paymentprofiles-9

    [Documentation]  assign virtual service to a profile then do the prepayment and bill payment.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[2]}  advancePaymentProfileId=${id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
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

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Bill By UUId  ${cwid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Consumer Login  ${CUSERNAME17}   ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${con_id}=  get_id  ${CUSERNAME17}
    # clear_payment_invoice  ${PUSERNAME186} 

    ${resp}=  Make payment Consumer Mock  ${pid}  ${Total1}  ${purpose[1]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${con_id}    profileId=${id}    paymentGateway=RAZORPAY    paymentSettingsId=1
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[7]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${Total1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${ReportTime}=  db.get_time_by_timezone   ${tz}
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


JD-TC-paymentprofiles-10

    [Documentation]  try to create the payment profiles using another providers bank details.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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
    ...   gatewayMerchantId=${bank_id1}  gatewayFee=${gatewayFee}
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

    


*** comment ***


JD-TC-paymentprofiles-4

    [Documentation]  do the bill payment to my own bank(for walkin checkin, appointment and order).


JD-TC-paymentprofiles-6

    [Documentation]  try to do the bill payment to my own bank without assign the service to the payment profile.


 # commented due to invalide case , cannot do convenince fee and pre payment amount seperatly

JD-TC-paymentprofiles-2.4

    [Documentation]  do the prepayment to jaldee bank with convenienceFee.(Pay the Two Amount Supprate)(for online appointment ).
   
    # ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Payment Profile For Prepayment  ${pid}  ${advPayBankType[0]}  advancePaymentProfileId=customizedJBProfile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${lid}=  Create Sample Location

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${min_pre}=  Convert To Number  ${min_pre}  1
    Set Suite Variable   ${min_pre}
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${SERVICE4}=  FakerLibrary.word
    ${resp}=  Create Service  ${SERVICE4}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    clear_appt_schedule   ${PUSERNAME190}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=   Get Account Payment Settings 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}      ${parallel}    ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${sch_id}

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${random slots}=  Evaluate  random.sample(${slots},2)   random
    Set Test Variable   ${slot1}   ${random slots[0]}
    Set Test Variable   ${slot2}   ${random slots[1]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[7]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=    Get convenienceFee Details     ${pid}    customizedJBProfile   ${min_pre}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${convfee}  ${resp.json()[0]['convenienceFee']} 

    ${resp}=    Get Service payment modes    ${pid}    ${s_id}    ${purpose[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['isJaldeeBank']}    ${bool[0]}
    Set Suite Variable    ${proid}  ${resp.json()[0]['profileId']}

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre}  ${purpose[0]}  ${apptid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${jdconID}    jaldeeConvenienceFee=${convfee}   profileId=${proid}    paymentGateway=RAZORPAY    paymentSettingsId=1
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Make payment Consumer Mock  ${pid}  ${totalamt}  ${purpose[0]}  ${apptid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${jdconID}   profileId=${proid}    paymentGateway=RAZORPAY    paymentSettingsId=1
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${PAYMENT_ALREADY_PROCESSED}
