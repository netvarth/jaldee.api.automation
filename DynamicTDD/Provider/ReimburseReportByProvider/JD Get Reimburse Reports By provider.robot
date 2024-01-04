*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Reimbursement
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

***Variables***

${start}  200
${start1}  220

${SERVICE1}  QWERTY1
${SERVICE2}  QWERTY2
${SERVICE3}  QWERTY3
${SERVICE4}  QWERTY4
${SERVICE1P}  QWERTY5
${SERVICE2P}  QWERTY6
${queue1}  morning
${digits}       0123456789
${self}   0

*** Test Cases ***

JD-TC-GetReimburseReports-1
    [Documentation]   Generate reimburse report for a walk-in checkin(taxable service).
      
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200

    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
    Set Test Variable  ${domain}  ${domresp.json()[${pos}]['domain']}

    ${subdomain}=  Get Billable Subdomain  ${domain}  ${domresp}  ${pos}  
    Set Test Variable   ${subdomain}
    Exit For Loop IF    '${subdomain}'

    END

    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_Z}=  Evaluate  ${PUSERNAME}+443205            
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME_Z}${\n}
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain}  ${subdomain}  ${PUSERNAME_Z}   ${pkg_id[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_Z}  0
    
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_Z}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${PUSERNAME_Z}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${PUSERPH4}=  Evaluate  ${PUSERNAME}+305
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH4}${\n}
    ${PUSERPH5}=  Evaluate  ${PUSERNAME}+306
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH5}${\n}
    ${PUSERMAIL3}=   Set Variable  ${P_Email}${PUSERPH4}.${test_mail}
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH4}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH5}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL3}  ${views}
    ${bs}=  FakerLibrary.bs
    Set Suite Variable   ${bs}
    ${city}=   get_place
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  4  15  
    ${desc}=   FakerLibrary.sentence  nb_words=2  variable_nb_words=False
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${resp}=  Update Business Profile with schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${lid}  ${resp.json()['baseLocation']['id']}

    ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${fields.status_code}   200
    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}
    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Waitlist
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${d1}     ${resp.json()['sector']}
    Set Suite Variable   ${sd1}    ${resp.json()['subSector']}

    ${pid}=  get_acc_id  ${PUSERNAME_Z}     
    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${domains}=  Jaldee Coupon Target Domains   ${d1}    
    ${sub_domains}=  Jaldee Coupon Target SubDomains   ${d1}_${sd1}
    ProviderLogout

    ${loc1}=  Jaldee Coupon Target Locations  ${longi}  ${latti}  5
    ${loc2}=  Jaldee Coupon Target Locations  ${longi1}  ${latti1}  2
    ${locations}=  Create List  ${loc1}  ${loc2}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_codeH1}=   FakerLibrary.word
    Set Suite Variable    ${cupn_codeH1}
    ${cupn_name}=    FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable     ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable     ${c_des}
    ${p_des}=    FakerLibrary.sentence
    Set Suite Variable     ${p_des}
    ${jc_amount}    Random Int   min=50   max=100
    ${jc_amount}=  Convert To Number  ${jc_amount}  1
    Set Suite Variable     ${jc_amount}
    clear_jaldeecoupon  ${cupn_codeH1}
    ${resp}=  Create Jaldee Coupon  ${cupn_codeH1}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  ${jc_amount}   100  ${bool[0]}  ${bool[0]}  100  100  1000  10  10  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_codeH1}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    
    # ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    # ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}

    # Should Be Equal As Strings    ${resp.status_code}   200
    # ${resp}=  Enable Tax
    # Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERNAME_Z} 
    LOg   ${resp.json()}
    Set Suite Variable   ${pid}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    clear_customer   ${PUSERNAME_Z}

    ${resp}=  Get Consumer By Id  ${CUSERNAME15}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME15} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    clear_location   ${PUSERNAME_Z} 
    clear_service   ${PUSERNAME_Z}
    clear_queue   ${PUSERNAME_Z}
    clear_payment_invoice  ${PUSERNAME_Z}
    ${lid}=   Create Sample Location
    Log   ${lid}
    Set Suite Variable    ${lid} 
    
    ${ser_desc}=   FakerLibrary.word
    Set Suite Variable   ${ser_desc}  
    ${ser_duratn}=      Random Int   min=10   max=30
    Set Suite Variable   ${ser_duratn}
    ${min_pre}=   Random Int   min=50   max=50
    ${total}=   Random Int   min=100   max=1000
    ${min_pre}=  Convert To Number  ${min_pre}  1
    Set Suite Variable   ${min_pre}
    ${total}=  Convert To Number  ${total}  1
    Set Suite Variable   ${total}

    ${resp}=   Create Service  ${SERVICE1}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${total}   ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}

    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${strt_time}=   db.subtract_timezone_time  ${tz}  2  00
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}       4  20 
    Set Suite Variable    ${end_time} 
    ${capacity}=  Random Int  min=8   max=20
    ${parallel}=  Random Int   min=1   max=2
    Set Suite Variable   ${parallel}
    Set Suite Variable   ${capacity}  
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${lid}  ${s_id1}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}

    ${cnote}=   FakerLibrary.word
    Set Suite Variable  ${cnote}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY1}  ${cnote}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}  

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${gst_rate}=            Evaluate   ${total} * ${gstpercentage[2]}
    ${gst_rate}=            Convert To Number   ${gst_rate}  2
    ${gst_rate1}=           Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=           Convert To Number   ${gst_rate1}    2
    ${net_rate1}=           Evaluate   ${total} + ${gst_rate1}
    ${net_rate1}=           twodigitfloat  ${net_rate1}
   
    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${bill_id}    ${resp.json()['id']}    
    Verify Response  ${resp}  uuid=${wid}  netTotal=${total}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  taxableTotal=${total}   totalTaxAmount=${gst_rate1}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                 ${net_rate1}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}               ${net_rate1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${s_id1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}           ${gstpercentage[2]} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${total}
    Should Be Equal As Numbers  ${resp.json()['service'][0]['netRate']}                 ${total}
    # Should Be Equal As Strings  ${resp.json()['checkinStatus']}                         ${wl_status[1]}

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeH1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[0]}

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_codeH1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeH1}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_codeH1}  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${net_rate1}=    Evaluate   ${net_rate1} - ${jc_amount}

    Verify Response  ${resp}  uuid=${wid}   netTotal=${total}  billStatus=${billStatus[0]}   billViewStatus=${billViewStatus[1]}  
    ...   billPaymentStatus=${paymentStatus[0]}  

    Should Be Equal As Numbers  ${resp.json()['netRate']}                 ${net_rate1}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}               ${net_rate1}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_codeH1}']['value']}        ${jc_amount}
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeH1}']['systemNote']}               ${SystemNote[1]}
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeH1}']['systemNote']}               ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}                   ${s_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                       ${total}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}                 ${SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                    1.0
    
    ${resp}=  Accept Payment  ${wid}   ${payment_modes[0]}   ${net_rate1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Payment By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}                    ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}                     ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}            ${payment_modes[0]}
    Should Be Equal As Numbers  ${resp.json()[0]['amount']}                     ${net_rate1}  

    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}                          ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}                    ${billStatus[1]} 
    
    ${end}=     db.add_tz_time24  ${tz}   0    0
    ${start}=   db.add_tz_time24  ${tz}   0   -10
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                    ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}                   ${DAY1} 
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}                ${DAY1}  
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}                 ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}         ${jc_amount}
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}                    ${jc_amount}
    
    Should Be Equal As Strings  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['account']['id']}                                ${pid}      
    Should Be Equal As Strings  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['coupons'][0]['couponCode']}                     ${cupn_codeH1}  
    Should Be Equal As Strings  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['coupons'][0]['billDetails'][0]['billId']}       ${bill_id}  
    Should Be Equal As Strings  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['coupons'][0]['billDetails'][0]['billAmount']}   ${net_rate1}  
    Should Be Equal As Strings  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['coupons'][0]['billDetails'][0]['discount']}     ${jc_amount}  
    
    Should Be Equal As Strings  ${resp.json()[0]['reportStatus']}                        ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['businessName']}                        ${bs}

    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_codeH1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}             ${jc_amount}
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}           1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}           0.0  
    
    ${resp}=  Get Reimburse Reports By Provider
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                     ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}                    ${DAY1}   
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}                 ${DAY1}    
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}                  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}             0.0
    Should Be Equal As Strings  ${resp.json()[0]['listOfJaldeeCoupons']}            {"${cupn_codeH1}":${jc_amount}}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}          ${jc_amount}
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}                     ${jc_amount}
    Should Be Equal As Strings  ${resp.json()[0]['status']}                         ${cupnpaymentStatus[3]}
    Should Be Equal As Strings  ${resp.json()[0]['totalPaid']}                      0.0
    Should Be Equal As Strings  ${resp.json()[0]['totalBalanceDue']}                ${jc_amount}
    Should Be Equal As Strings  ${resp.json()[0]['reportStatus']}                   ${status[0]}

JD-TC-GetReimburseReports-2
    [Documentation]  Generate reimburse report after make payment for an online checkin and walk-in checkin.

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid1}=  get_id  ${CUSERNAME16}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid1}  ${DAY1}  ${s_id1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 

    ${tax1}=  Evaluate  ${total}*${gstpercentage[2]}
    ${tax}=   Evaluate  ${tax1}/100
    Set Suite Variable    ${tax}
    ${totalamt}=  Evaluate  ${total} + ${tax}
    ${amt_float}=  twodigitfloat  ${totalamt}

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[0]}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
   
    ${resp}=  Get Waitlist By Id  ${cwid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}
    
    ${resp}=  Get Bill By UUId  ${cwid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${bill_id11}    ${resp.json()['id']}  

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_codeH1}  ${cwid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${net_rate1}=    Evaluate   ${totalamt} - ${jc_amount}
    ${net_rate1}=           twodigitfloat  ${net_rate1}

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Make payment Consumer Mock  ${p_id}  ${net_rate1}  ${purpose[0]}  ${cwid}  ${s_id1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Make payment Consumer Mock  ${net_rate1}  ${bool[1]}  ${cwid}  ${pid}  ${purpose[0]}  ${cid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}
 
    sleep   02s

    ${resp}=   Get Payment Details By UUId   ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}           ${payref} 
    Should Be Equal As Numbers  ${resp.json()[0]['amount']}                 ${net_rate1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}              ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}            ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}                ${cwid}

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${bill_id1}    ${resp.json()['id']} 
    Verify Response  ${resp}  uuid=${cwid}  netTotal=${total}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   billPaymentStatus=${paymentStatus[2]}     taxableTotal=${total}  totalTaxAmount=${tax}
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                 ${net_rate1}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}               0.0
    Should Be Equal As Numbers  ${resp.json()['totalAmountPaid']}          ${net_rate1}

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]}    waitlistStatus=${wl_status[0]}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
   
    ${resp}=  Get Waitlist By Id  ${cwid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}

    # ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_codeH1}  ${cwid}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Settl Bill  ${cwid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${cwid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}                          ${cwid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}                    ${billStatus[1]} 
     
    ${net_rate1}=    Evaluate   ${totalamt} - ${jc_amount}

    ${end}=     db.add_tz_time24  ${tz}   0    0
    ${start}=   db.add_tz_time24  ${tz}   0   -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                    ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}                   ${DAY1} 
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}                ${DAY1}  
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}                 ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}         ${jc_amount}
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}                    ${jc_amount}
    
    Should Be Equal As Strings  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['account']['id']}                                ${pid}      
    Should Be Equal As Strings  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['coupons'][0]['couponCode']}                     ${cupn_codeH1}  
    Should Be Equal As Strings  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['coupons'][0]['billDetails'][0]['billId']}       ${bill_id1}  
    Should Be Equal As Strings  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['coupons'][0]['billDetails'][0]['billAmount']}   ${net_rate1}  
    Should Be Equal As Strings  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['coupons'][0]['billDetails'][0]['discount']}     ${jc_amount}  
    
    Should Be Equal As Strings  ${resp.json()[0]['reportStatus']}                        ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['businessName']}                        ${bs}

    ${jc_amount1}=    Evaluate   ${jc_amount} + ${jc_amount}

    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_codeH1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}             ${jc_amount1}
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}           2
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}           0.0  
    
    ${resp}=  Get Reimburse Reports By Provider
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                     ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}                    ${DAY1}   
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}                 ${DAY1}    
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}                  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}             0.0
    Should Be Equal As Strings  ${resp.json()[0]['listOfJaldeeCoupons']}            {"${cupn_codeH1}":${jc_amount}}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}          ${jc_amount}
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}                     ${jc_amount}
    Should Be Equal As Strings  ${resp.json()[0]['status']}                         ${cupnpaymentStatus[3]}
    Should Be Equal As Strings  ${resp.json()[0]['totalPaid']}                      0.0
    Should Be Equal As Strings  ${resp.json()[0]['totalBalanceDue']}                ${jc_amount}
    Should Be Equal As Strings  ${resp.json()[0]['reportStatus']}                   ${status[0]}

    Should Be Equal As Strings  ${resp.json()[1]['providerId']}                     ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['invoiceDate']}                    ${DAY1}   
    Should Be Equal As Strings  ${resp.json()[1]['reportFromDate']}                 ${DAY1}    
    Should Be Equal As Strings  ${resp.json()[1]['reportEndDate']}                  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['subTotalJaldeeBank']}             0.0
    Should Be Equal As Strings  ${resp.json()[1]['listOfJaldeeCoupons']}            {"${cupn_codeH1}":${jc_amount}}
    Should Be Equal As Strings  ${resp.json()[1]['subTotalJaldeeCoupons']}          ${jc_amount}
    Should Be Equal As Strings  ${resp.json()[1]['grantTotal']}                     ${jc_amount}
    Should Be Equal As Strings  ${resp.json()[1]['status']}                         ${cupnpaymentStatus[3]}
    Should Be Equal As Strings  ${resp.json()[1]['totalPaid']}                      0.0
    Should Be Equal As Strings  ${resp.json()[1]['totalBalanceDue']}                ${jc_amount}
    Should Be Equal As Strings  ${resp.json()[1]['reportStatus']}                   ${status[0]}

JD-TC-GetReimburseReports-3
    [Documentation]   Generate reimburse report after two walk-in checkins and an online checkin.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  AddCustomer  ${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid6}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid7}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add To Waitlist  ${cid6}  ${s_id1}  ${qid1}  ${DAY1}  ${cnote}  ${bool[1]}  ${cid6}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid6}  ${wid[0]}  

    ${resp}=  Get Waitlist By Id  ${wid6} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Add To Waitlist  ${cid7}  ${s_id1}  ${qid1}  ${DAY1}  ${cnote}  ${bool[1]}  ${cid7}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid7}  ${wid[0]}  

    ${resp}=  Get Waitlist By Id  ${wid7} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Bill By UUId  ${wid6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${bill_id6}    ${resp.json()['billId']} 

    ${resp}=  Get Bill By UUId  ${wid7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${bill_id7}    ${resp.json()['id']} 

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_codeH1}  ${wid6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${wid6}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${tax1}=  Evaluate  ${total}*${gstpercentage[2]}
    ${tax}=   Evaluate  ${tax1}/100
    Set Suite Variable    ${tax}
    ${totalamt}=  Evaluate  ${total} + ${tax}
    ${amt_float}=  twodigitfloat  ${totalamt}
    ${net_rate1}=    Evaluate   ${totalamt} - ${jc_amount}
    ${net_rate1}=           twodigitfloat  ${net_rate1}

    Verify Response  ${resp}  uuid=${wid6}   netTotal=${total}  billStatus=${billStatus[0]}   billViewStatus=${billViewStatus[1]}  
    ...   billPaymentStatus=${paymentStatus[0]}  

    Should Be Equal As Numbers  ${resp.json()['netRate']}                 ${net_rate1}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}               ${net_rate1}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_codeH1}']['value']}        ${jc_amount}
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeH1}']['systemNote']}               ${SystemNote[1]}
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeH1}']['systemNote']}               ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}                   ${s_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                       ${total}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}                 ${SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                    1.0
    
    ${resp}=  Accept Payment  ${wid6}   ${payment_modes[0]}   ${net_rate1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Payment By UUId  ${wid6}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}                    ${wid6}
    Should Be Equal As Strings  ${resp.json()[0]['status']}                     ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}            ${payment_modes[0]}
    Should Be Equal As Numbers  ${resp.json()[0]['amount']}                     ${net_rate1}  

    ${resp}=  Settl Bill  ${wid6}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid6}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}                          ${wid6}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}                    ${billStatus[1]} 
    
    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_codeH1}  ${wid7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${wid7}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${wid7}   netTotal=${total}  billStatus=${billStatus[0]}   billViewStatus=${billViewStatus[1]}  
    ...   billPaymentStatus=${paymentStatus[0]} 

    Should Be Equal As Numbers  ${resp.json()['netRate']}                 ${net_rate1}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}               ${net_rate1}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_codeH1}']['value']}        ${jc_amount}
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeH1}']['systemNote']}               ${SystemNote[1]}
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeH1}']['systemNote']}               ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}                   ${s_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                       ${total}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}                 ${SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                    1.0
    
    ${resp}=  Accept Payment  ${wid7}   ${payment_modes[0]}   ${net_rate1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Payment By UUId  ${wid7}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}                    ${wid7}
    Should Be Equal As Strings  ${resp.json()[0]['status']}                     ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}            ${payment_modes[0]}
    Should Be Equal As Numbers  ${resp.json()[0]['amount']}                     ${net_rate1}  

    ${resp}=  Settl Bill  ${wid7}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid7}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}                          ${wid7}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}                    ${billStatus[1]} 
    
    ${jc_amount1}=    Evaluate   ${jc_amount} + ${jc_amount}

    sleep  4s
    ${end}=     db.add_tz_time24  ${tz}   0    0
    ${start}=   db.add_tz_time24  ${tz}   0   -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                    ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}                   ${DAY1} 
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}                ${DAY1}  
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}                 ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}         ${jc_amount1}
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}                    ${jc_amount1}
    
    Should Be Equal As Strings  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['account']['id']}                                ${pid}      
    Should Be Equal As Strings  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['coupons'][0]['couponCode']}                     ${cupn_codeH1}  
    Should Be Equal As Strings  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['coupons'][0]['billDetails'][0]['billId']}       ${bill_id6}  
    Should Be Equal As Strings  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['coupons'][0]['billDetails'][0]['billAmount']}   ${net_rate1}  
    Should Be Equal As Strings  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['coupons'][0]['billDetails'][0]['discount']}     ${jc_amount}  
    Should Be Equal As Strings  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['coupons'][0]['billDetails'][1]['billId']}       ${bill_id7}  
    Should Be Equal As Numbers  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['coupons'][0]['billDetails'][1]['billAmount']}   ${net_rate1}  
    Should Be Equal As Numbers  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['coupons'][0]['billDetails'][1]['discount']}     ${jc_amount}  
    
    Should Be Equal As Strings  ${resp.json()[0]['reportStatus']}                        ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['businessName']}                        ${bs}

    ${jc_amount2}=    Evaluate   ${jc_amount1} + ${jc_amount1}

    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_codeH1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}             ${jc_amount2}
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}           4
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}           0.0  
    
    ${resp}=  Get Reimburse Reports By Provider
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                     ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}                    ${DAY1}   
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}                 ${DAY1}    
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}                  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}             0.0
    Should Be Equal As Strings  ${resp.json()[0]['listOfJaldeeCoupons']}            {"${cupn_codeH1}":${jc_amount1}}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}          ${jc_amount1}
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}                     ${jc_amount1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}                         ${cupnpaymentStatus[3]}
    Should Be Equal As Strings  ${resp.json()[0]['totalPaid']}                      0.0
    Should Be Equal As Strings  ${resp.json()[0]['totalBalanceDue']}                ${jc_amount1}
    Should Be Equal As Strings  ${resp.json()[0]['reportStatus']}                   ${status[0]}

    Should Be Equal As Strings  ${resp.json()[1]['providerId']}                     ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['invoiceDate']}                    ${DAY1}   
    Should Be Equal As Strings  ${resp.json()[1]['reportFromDate']}                 ${DAY1}    
    Should Be Equal As Strings  ${resp.json()[1]['reportEndDate']}                  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['subTotalJaldeeBank']}             0.0
    Should Be Equal As Strings  ${resp.json()[1]['listOfJaldeeCoupons']}            {"${cupn_codeH1}":${jc_amount}}
    Should Be Equal As Strings  ${resp.json()[1]['subTotalJaldeeCoupons']}          ${jc_amount}
    Should Be Equal As Strings  ${resp.json()[1]['grantTotal']}                     ${jc_amount}
    Should Be Equal As Strings  ${resp.json()[1]['status']}                         ${cupnpaymentStatus[3]}
    Should Be Equal As Strings  ${resp.json()[1]['totalPaid']}                      0.0
    Should Be Equal As Strings  ${resp.json()[1]['totalBalanceDue']}                ${jc_amount}
    Should Be Equal As Strings  ${resp.json()[1]['reportStatus']}                   ${status[0]}

    Should Be Equal As Strings  ${resp.json()[2]['providerId']}                     ${pid}
    Should Be Equal As Strings  ${resp.json()[2]['invoiceDate']}                    ${DAY1}   
    Should Be Equal As Strings  ${resp.json()[2]['reportFromDate']}                 ${DAY1}    
    Should Be Equal As Strings  ${resp.json()[2]['reportEndDate']}                  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[2]['subTotalJaldeeBank']}             0.0
    Should Be Equal As Strings  ${resp.json()[2]['listOfJaldeeCoupons']}            {"${cupn_codeH1}":${jc_amount}}
    Should Be Equal As Strings  ${resp.json()[2]['subTotalJaldeeCoupons']}          ${jc_amount}
    Should Be Equal As Strings  ${resp.json()[2]['grantTotal']}                     ${jc_amount}
    Should Be Equal As Strings  ${resp.json()[2]['status']}                         ${cupnpaymentStatus[3]}
    Should Be Equal As Strings  ${resp.json()[2]['totalPaid']}                      0.0
    Should Be Equal As Strings  ${resp.json()[2]['totalBalanceDue']}                ${jc_amount}
    Should Be Equal As Strings  ${resp.json()[2]['reportStatus']}                   ${status[0]}

JD-TC-GetReimburseReports-4
    [Documentation]  Three providers make payment with jcoupon and  settle the bill then after generete invoice report.

    #  payment 1
    clear_queue      ${PUSERNAME104}
    clear_location   ${PUSERNAME104}
    clear_service    ${PUSERNAME104}
    clear_customer   ${PUSERNAME104}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME104}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid1}=  get_acc_id  ${PUSERNAME104} 

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bs1}  ${resp.json()['businessName']}

    ${resp}=   Get Active License
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${alldomains}=  Jaldee Coupon Target Domains  ALL
    ${allsub_domains}=  Jaldee Coupon Target SubDomains  ALL
    ${licenses}=  Jaldee Coupon Target License  ${lic1}

    ${cupn_code}=    FakerLibrary.word
    ${cupn_name}=   FakerLibrary.name
    ${cupn_des}=   FakerLibrary.sentence
    ${c_des}=   FakerLibrary.sentence
    ${p_des}=   FakerLibrary.sentence
    ${jc_amount1}    Random Int   min=100   max=150
    ${jc_amount1}=  Convert To Number  ${jc_amount1}  1
    ${jd_max1}    Random Int   min=200   max=250
    ${max_reim_per1}    Random Int   min=25   max=25
    ${min_bill_amt1}    Random Int   min=500   max=1000
    ${prov_use_lim1}    Random Int   min=10   max=20
    ${cons_use_lim1}    Random Int   min=10   max=20
    ${consprov_use_lim1}    Random Int   min=5   max=10
    clear_jaldeecoupon  ${cupn_code}

    ${rem_amount}=      Evaluate   ${jc_amount1} * ${max_reim_per1}
    ${rem_amount}=      Evaluate    ${rem_amount} / 100 
  
    ${resp}=  Create Jaldee Coupon  ${cupn_code}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY}  ${DAY2}  ${discountType[0]}  ${jc_amount1}  ${jd_max1}  ${bool[0]}  ${bool[0]}  ${max_reim_per1}  ${min_bill_amt1}  ${prov_use_lim1}  ${cons_use_lim1}  ${consprov_use_lim1}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${alldomains}  ${allsub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Push Jaldee Coupon  ${cupn_code}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME104}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    # ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    
    # ${resp}=  Enable Tax
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[0]}

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${lid1}=   Create Sample Location
    Set Test Variable    ${lid1} 

    ${ser_desc}=   FakerLibrary.word  
    ${ser_duratn}=      Random Int   min=10   max=30
    ${amount1}=   Random Int   min=1000   max=1000
    ${amount1}=  Convert To Number  ${amount1}  1
    
    ${resp}=   Create Service  ${SERVICE1}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${amount1}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id1}  ${resp.json()}  
    
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${strt_time}=   db.subtract_timezone_time  ${tz}  2  00
    ${end_time}=    add_timezone_time  ${tz}       4  20 
    ${capacity}=  Random Int  min=8   max=20
    ${parallel}=  Random Int   min=1   max=2
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${lid1}  ${s_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME20}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME20}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${s_id1}  ${qid1}  ${DAY1}  ${cnote}  ${bool[0]}  ${cid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}  

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Bill By UUId  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${bill_id1}    ${resp.json()['billId']}

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id  ${wid1}  ${pid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[1]}

    ${resp}=  Get Bill By consumer  ${wid1}  ${pid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Payment Details By UUId   ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s
    ${resp}=  Apply Jaldee Coupon At Selfpay  ${wid1}  ${cupn_code}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${net_amount}=    Evaluate   ${amount1} - ${jc_amount1}

    ${amt_float}=  twodigitfloat  ${net_amount}
    ${cid1}=  get_id  ${CUSERNAME20}
    
    ${resp}=  Make payment Consumer Mock  ${pid1}  ${net_amount}  ${purpose[1]}  ${wid1}  ${s_id1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}
 
    sleep   04s

    ${resp}=   Get Payment Details By UUId   ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['amount']}                 ${net_amount}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}              ${pid1}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}                ${wid1}

    ${resp}=  Get Bill By consumer  ${wid1}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${bill_id1}    ${resp.json()['id']} 

    Verify Response  ${resp}  uuid=${wid1}  netTotal=${amount1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  
    ...  billPaymentStatus=${paymentStatus[2]}  totalAmountPaid=${net_amount}  taxableTotal=0.0  totalTaxAmount=0.0
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                 ${net_amount}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}               0.0
    ${resp}=  Encrypted Provider Login  ${PUSERNAME104}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Settl Bill  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}                          ${wid1}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}                    ${billStatus[1]} 

    #  payment 2
    clear_queue      ${PUSERNAME105}
    clear_location   ${PUSERNAME105}
    clear_service    ${PUSERNAME105}
    clear_customer   ${PUSERNAME105}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid2}=  get_acc_id  ${PUSERNAME105} 

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bs2}  ${resp.json()['businessName']}

    ${resp}=   Get Active License
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic2}  ${resp.json()['accountLicense']['licPkgOrAddonId']}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${alldomains}=  Jaldee Coupon Target Domains  ALL
    ${allsub_domains}=  Jaldee Coupon Target SubDomains  ALL
    ${licenses}=  Jaldee Coupon Target License  ${lic2}

    ${cupn_code1}=    FakerLibrary.word
    ${cupn_name}=   FakerLibrary.name
    ${cupn_des}=   FakerLibrary.sentence
    ${c_des}=   FakerLibrary.sentence
    ${p_des}=   FakerLibrary.sentence
    ${jc_amount2}    Random Int   min=120   max=120
    ${jc_amount2}=  Convert To Number  ${jc_amount2}  1
    ${jd_max1}    Random Int   min=125   max=200
    ${max_reim_per2}    Random Int   min=25   max=25
    ${min_bill_amt1}    Random Int   min=500   max=1000
    ${prov_use_lim1}    Random Int   min=10   max=20
    ${cons_use_lim1}    Random Int   min=10   max=20
    ${consprov_use_lim1}    Random Int   min=5   max=10
    clear_jaldeecoupon  ${cupn_code1}

    ${rem_amount1}=      Evaluate   ${jc_amount2} * ${max_reim_per2}
    ${rem_amount1}=      Evaluate    ${rem_amount1} / 100 

    ${resp}=  Create Jaldee Coupon  ${cupn_code1}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY}  ${DAY2}  ${discountType[0]}  ${jc_amount2}  ${jd_max1}  ${bool[0]}  ${bool[0]}  ${max_reim_per2}  ${min_bill_amt1}  ${prov_use_lim1}  ${cons_use_lim1}  ${consprov_use_lim1}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${alldomains}  ${allsub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Push Jaldee Coupon  ${cupn_code1}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[0]}

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code1}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${lid2}=   Create Sample Location
    Set Test Variable    ${lid2} 

    ${ser_desc}=   FakerLibrary.word  
    ${ser_duratn}=      Random Int   min=10   max=30
    ${amount2}=   Random Int   min=1000   max=1000
    ${amount2}=  Convert To Number  ${amount2}  1
    
    ${resp}=   Create Service  ${SERVICE2}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${amount2}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id2}  ${resp.json()}  
    
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${strt_time}=   db.subtract_timezone_time  ${tz}  2  00
    ${end_time}=    add_timezone_time  ${tz}       4  20 
    ${capacity}=  Random Int  min=8   max=20
    ${parallel}=  Random Int   min=1   max=2
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${lid2}  ${s_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid2}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid2}  ${s_id2}  ${qid2}  ${DAY1}  ${cnote}  ${bool[0]}  ${cid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid2}  ${wid[0]}  

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Bill By UUId  ${wid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${bill_id2}    ${resp.json()['billId']}

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id  ${wid2}  ${pid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[1]}

    ${resp}=  Get Bill By consumer  ${wid2}  ${pid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Payment Details By UUId   ${wid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s
    ${resp}=  Apply Jaldee Coupon At Selfpay  ${wid2}  ${cupn_code1}  ${pid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${net_amount1}=    Evaluate   ${amount2} - ${jc_amount2}

    ${amt_float1}=  twodigitfloat  ${net_amount1}
    ${cid2}=  get_id  ${CUSERNAME11}
    
    ${resp}=  Make payment Consumer Mock  ${p_id2}  ${net_amount1}  ${purpose[1]}  ${wid2}  ${s_id2}  ${bool[0]}   ${bool[1]}  ${cid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Make payment Consumer Mock  ${net_amount1}  ${bool[1]}  ${wid2}  ${pid2}  ${purpose[1]}  ${cid2}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${mer1}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref1}   ${resp.json()['paymentRefId']}
 
    sleep   02s

    ${resp}=   Get Payment Details By UUId   ${wid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}           ${payref1} 
    Should Be Equal As Strings  ${resp.json()[0]['amount']}                 ${net_amount1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}              ${pid2}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}            ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}                ${wid2}

    ${resp}=  Get Bill By consumer  ${wid2}  ${pid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${bill_id2}    ${resp.json()['id']} 

    Verify Response  ${resp}  uuid=${wid2}  netTotal=${amount2}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  
    ...  billPaymentStatus=${paymentStatus[2]}  totalAmountPaid=${net_amount1}  taxableTotal=0.0  totalTaxAmount=0.0
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                 ${net_amount1}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}               0.0
    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Settl Bill  ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}                          ${wid2}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}                    ${billStatus[1]} 
  
    #  payment 3
    clear_queue      ${PUSERNAME106}
    clear_location   ${PUSERNAME106}
    clear_service    ${PUSERNAME106}
    clear_customer   ${PUSERNAME106}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME106}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid3}=  get_acc_id  ${PUSERNAME106} 
    
    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bs3}  ${resp.json()['businessName']}

    ${resp}=   Get Active License
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic3}  ${resp.json()['accountLicense']['licPkgOrAddonId']}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${alldomains}=  Jaldee Coupon Target Domains  ALL
    ${allsub_domains}=  Jaldee Coupon Target SubDomains  ALL
    ${licenses}=  Jaldee Coupon Target License  ${lic3}

    ${cupn_code2}=    FakerLibrary.word
    ${cupn_name}=   FakerLibrary.name
    ${cupn_des}=   FakerLibrary.sentence
    ${c_des}=   FakerLibrary.sentence
    ${p_des}=   FakerLibrary.sentence
    ${jc_amount3}    Random Int   min=10  max=20
    ${jc_amount3}=  Convert To Number  ${jc_amount3}  1
    ${jd_max1}    Random Int   min=100   max=200
    ${max_reim_per3}    Random Int   min=25   max=25
    ${min_bill_amt1}    Random Int   min=500   max=1000
    ${prov_use_lim1}    Random Int   min=10   max=20
    ${cons_use_lim1}    Random Int   min=10   max=20
    ${consprov_use_lim1}    Random Int   min=5   max=10
    clear_jaldeecoupon  ${cupn_code2}

    ${rem_amount2}=      Evaluate   ${jc_amount3} * ${max_reim_per3}
    ${rem_amount2}=      Evaluate    ${rem_amount2} / 100 

    ${resp}=  Create Jaldee Coupon  ${cupn_code2}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY}  ${DAY2}  ${discountType[0]}  ${jc_amount3}  ${jd_max1}  ${bool[0]}  ${bool[0]}  ${max_reim_per3}  ${min_bill_amt1}  ${prov_use_lim1}  ${cons_use_lim1}  ${consprov_use_lim1}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${alldomains}  ${allsub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Push Jaldee Coupon  ${cupn_code2}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME106}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[0]}

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code2}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${lid3}=   Create Sample Location
    Set Test Variable    ${lid3} 

    ${ser_desc}=   FakerLibrary.word  
    ${ser_duratn}=      Random Int   min=10   max=30
    ${amount3}=   Random Int   min=1000   max=1000
    ${amount3}=  Convert To Number  ${amount3}  1
    
    ${resp}=   Create Service  ${SERVICE3}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${amount3}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id3}  ${resp.json()}  
    
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${strt_time}=   db.subtract_timezone_time  ${tz}  2  00
    ${end_time}=    add_timezone_time  ${tz}       4  20 
    ${capacity}=  Random Int  min=8   max=20
    ${parallel}=  Random Int   min=1   max=2
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${lid3}  ${s_id3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid3}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid3}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid3}  ${s_id3}  ${qid3}  ${DAY1}  ${cnote}  ${bool[0]}  ${cid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid3}  ${wid[0]}  

    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Bill By UUId  ${wid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${bill_id3}    ${resp.json()['billId']}

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id  ${wid3}  ${pid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[1]}

    ${resp}=  Get Bill By consumer  ${wid3}  ${pid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Payment Details By UUId   ${wid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s
    ${resp}=  Apply Jaldee Coupon At Selfpay  ${wid3}  ${cupn_code2}  ${pid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${net_amount2}=    Evaluate   ${amount3} - ${jc_amount3}

    ${amt_float2}=  twodigitfloat  ${net_amount2}
    ${cid3}=  get_id  ${CUSERNAME12}
    
    ${resp}=  Make payment Consumer Mock  ${pid3}  ${net_amount2}  ${purpose[1]}  ${wid3}  ${s_id3}  ${bool[0]}   ${bool[1]}  ${cid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Make payment Consumer Mock  ${net_amount2}  ${bool[1]}  ${wid3}  ${pid3}  ${purpose[1]}  ${cid3}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${mer2}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref2}   ${resp.json()['paymentRefId']}
 
    ${resp}=   Get Payment Details By UUId   ${wid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}           ${payref2} 
    Should Be Equal As Strings  ${resp.json()[0]['amount']}                 ${net_amount2}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}              ${pid3}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}            ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}                ${wid3}

    ${resp}=  Get Bill By consumer  ${wid3}  ${pid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${bill_id3}    ${resp.json()['id']} 

    Verify Response  ${resp}  uuid=${wid3}  netTotal=${amount3}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  
    ...   billPaymentStatus=${paymentStatus[2]}  totalAmountPaid=${net_amount2}  taxableTotal=0.0  totalTaxAmount=0.0
    
    Should Be Equal As Numbers  ${resp.json()['netRate']}                 ${net_amount2}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}               0.0
    ${resp}=  Encrypted Provider Login  ${PUSERNAME106}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Settl Bill  ${wid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}                          ${wid3}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}                    ${billStatus[1]} 
    

    ${end}=     db.add_tz_time24  ${tz}   0    0
    ${start}=   db.add_tz_time24  ${tz}   0   -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                    ${pid1}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}                   ${DAY1} 
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}                ${DAY1}  
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}                 ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}         ${rem_amount}
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}                    ${rem_amount}
    
    Should Be Equal As Strings  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['account']['id']}                                ${pid1}      
    Should Be Equal As Strings  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['coupons'][0]['couponCode']}                     ${cupn_code}  
    Should Be Equal As Strings  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['coupons'][0]['billDetails'][0]['billId']}       ${bill_id1}  
    Should Be Equal As Strings  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['coupons'][0]['billDetails'][0]['billAmount']}   ${net_amount}  
    Should Be Equal As Strings  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['coupons'][0]['billDetails'][0]['discount']}     ${rem_amount}  
    
    Should Be Equal As Strings  ${resp.json()[0]['reportStatus']}                        ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['businessName']}                        ${bs1}

    Should Be Equal As Strings  ${resp.json()[1]['providerId']}                    ${pid2}
    Should Be Equal As Strings  ${resp.json()[1]['invoiceDate']}                   ${DAY1} 
    Should Be Equal As Strings  ${resp.json()[1]['reportFromDate']}                ${DAY1}  
    Should Be Equal As Strings  ${resp.json()[1]['reportEndDate']}                 ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['subTotalJaldeeCoupons']}         ${rem_amount1}
    Should Be Equal As Strings  ${resp.json()[1]['grantTotal']}                    ${rem_amount1}
    
    Should Be Equal As Strings  ${resp.json()[1]['jaldeeCouponReimbursableExpense']['account']['id']}                                ${pid2}      
    Should Be Equal As Strings  ${resp.json()[1]['jaldeeCouponReimbursableExpense']['coupons'][0]['couponCode']}                     ${cupn_code1}  
    Should Be Equal As Strings  ${resp.json()[1]['jaldeeCouponReimbursableExpense']['coupons'][0]['billDetails'][0]['billId']}       ${bill_id2}  
    Should Be Equal As Strings  ${resp.json()[1]['jaldeeCouponReimbursableExpense']['coupons'][0]['billDetails'][0]['billAmount']}   ${net_amount1}  
    Should Be Equal As Strings  ${resp.json()[1]['jaldeeCouponReimbursableExpense']['coupons'][0]['billDetails'][0]['discount']}     ${rem_amount1}  
    
    Should Be Equal As Strings  ${resp.json()[1]['reportStatus']}                        ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['businessName']}                        ${bs2}

    Should Be Equal As Strings  ${resp.json()[2]['providerId']}                    ${pid3}
    Should Be Equal As Strings  ${resp.json()[2]['invoiceDate']}                   ${DAY1} 
    Should Be Equal As Strings  ${resp.json()[2]['reportFromDate']}                ${DAY1}  
    Should Be Equal As Strings  ${resp.json()[2]['reportEndDate']}                 ${DAY1}
    Should Be Equal As Strings  ${resp.json()[2]['subTotalJaldeeCoupons']}         ${rem_amount2}
    Should Be Equal As Strings  ${resp.json()[2]['grantTotal']}                    ${rem_amount2}
    
    Should Be Equal As Strings  ${resp.json()[2]['jaldeeCouponReimbursableExpense']['account']['id']}                                ${pid3}      
    Should Be Equal As Strings  ${resp.json()[2]['jaldeeCouponReimbursableExpense']['coupons'][0]['couponCode']}                     ${cupn_code2}  
    Should Be Equal As Strings  ${resp.json()[2]['jaldeeCouponReimbursableExpense']['coupons'][0]['billDetails'][0]['billId']}       ${bill_id3}  
    Should Be Equal As Strings  ${resp.json()[2]['jaldeeCouponReimbursableExpense']['coupons'][0]['billDetails'][0]['billAmount']}   ${net_amount2}  
    Should Be Equal As Strings  ${resp.json()[2]['jaldeeCouponReimbursableExpense']['coupons'][0]['billDetails'][0]['discount']}     ${rem_amount2}  
    
    Should Be Equal As Strings  ${resp.json()[2]['reportStatus']}                        ${status[0]}
    Should Be Equal As Strings  ${resp.json()[2]['businessName']}                        ${bs3}

JD-TC-GetReimburseReports-5
    [Documentation]  Generate reimburse report for a walk-in checkin(appoinment).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME_Z}
    clear_location  ${PUSERNAME_Z}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]} 

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']} 

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${jc_amount}    Random Int   min=50   max=100
    ${jc_amount}=  Convert To Number  ${jc_amount}  1
    Set Suite Variable     ${jc_amount}

    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${PUSERNAME144}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${s_id}=  Create Sample Service  ${SERVICE1}
    ${resp}=   Create Service  ${SERVICE2}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${total}   ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    # ${resp}=  AddCustomer  ${CUSERNAME8}  firstName=${fname}   lastName=${lname}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId}

    ${gst_rate}=            Evaluate   ${total} * ${gstpercentage[2]}
    ${gst_rate}=            Convert To Number   ${gst_rate}  2
    ${gst_rate1}=           Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=           Convert To Number   ${gst_rate1}    2
    ${net_rate1}=           Evaluate   ${total} + ${gst_rate1}
    ${net_rate1}=           twodigitfloat  ${net_rate1}

    ${resp}=  Get Bill By UUId  ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${bill_id}    ${resp.json()['id']}    
    Verify Response  ${resp}  uuid=${apptid1}  netTotal=${total}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  taxableTotal=${total}   totalTaxAmount=${gst_rate1}
    
    # Should Be Equal As Numbers  ${resp.json()['netRate']}                 ${net_rate1}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}               ${net_rate1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${s_id2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}           ${gstpercentage[2]} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${total}
    Should Be Equal As Numbers  ${resp.json()['service'][0]['netRate']}                 ${total}

    

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeH1}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_codeH1}  ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${apptid1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${net_rate1}=    Evaluate   ${net_rate1} - ${jc_amount}

    Verify Response  ${resp}  uuid=${apptid1}   netTotal=${total}  billStatus=${billStatus[0]}   billViewStatus=${billViewStatus[1]}  
    ...   billPaymentStatus=${paymentStatus[0]}  

    Should Be Equal As Numbers  ${resp.json()['netRate']}                 ${net_rate1}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}               ${net_rate1}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_codeH1}']['value']}        ${jc_amount}
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeH1}']['systemNote']}               ${SystemNote[1]}
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeH1}']['systemNote']}               ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}                   ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                       ${total}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}                 ${SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                    1.0
    
    ${resp}=  Accept Payment  ${apptid1}   ${payment_modes[0]}   ${net_rate1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Payment By UUId  ${apptid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}                    ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}                     ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}            ${payment_modes[0]}
    Should Be Equal As Numbers  ${resp.json()[0]['amount']}                     ${net_rate1}  

    ${resp}=  Settl Bill  ${apptid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${apptid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}                          ${apptid1}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}                    ${billStatus[1]} 

    ${end}=     db.add_tz_time24  ${tz}   0    0
    ${start}=   db.add_tz_time24  ${tz}   0   -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                    ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}                   ${DAY1} 
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}                ${DAY1}  
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}                 ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}         ${jc_amount}
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}                    ${jc_amount}

    Should Be Equal As Strings  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['account']['id']}                                ${pid}      
    Should Be Equal As Strings  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['coupons'][0]['couponCode']}                     ${cupn_codeH1}  
    Should Be Equal As Strings  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['coupons'][0]['billDetails'][0]['billId']}       ${bill_id}  
    Should Be Equal As Strings  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['coupons'][0]['billDetails'][0]['billAmount']}   ${net_rate1}  
    Should Be Equal As Strings  ${resp.json()[0]['jaldeeCouponReimbursableExpense']['coupons'][0]['billDetails'][0]['discount']}     ${jc_amount}  
    
    Should Be Equal As Strings  ${resp.json()[0]['reportStatus']}                        ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['businessName']}                        ${bs}

    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_codeH1}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}             ${jc_amount}
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}           5
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}           0.0  
    
    ${resp}=  Get Reimburse Reports By Provider
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}                     ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}                    ${DAY1}   
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}                 ${DAY1}    
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}                  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}             0.0
    Should Be Equal As Strings  ${resp.json()[0]['listOfJaldeeCoupons']}            {"${cupn_codeH1}":${jc_amount}}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}          ${jc_amount}
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}                     ${jc_amount}
    Should Be Equal As Strings  ${resp.json()[0]['status']}                         ${cupnpaymentStatus[3]}
    Should Be Equal As Strings  ${resp.json()[0]['totalPaid']}                      0.0
    Should Be Equal As Strings  ${resp.json()[0]['totalBalanceDue']}                ${jc_amount}
    Should Be Equal As Strings  ${resp.json()[0]['reportStatus']}                   ${status[0]}

*** comment ***
JD-TC-GetReimburseReports-2
    [Documentation]  two provider create bill with jcoupon and  settl then after generete invoice report



    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200

    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
    Set Test Variable  ${domain}  ${domresp.json()[${pos}]['domain']}

    ${subdomain}=  Get Billable Subdomain  ${domain}  ${domresp}  ${pos}  
    Set Test Variable   ${subdomain}
    Exit For Loop IF    '${subdomain}'

    END

    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_W}=  Evaluate  ${PUSERNAME}+443216            
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME_W}${\n}
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain}  ${subdomain}  ${PUSERNAME_W}   ${pkg_id[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_W}  0
    
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_W}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${PUSERNAME_W}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_W}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${PUSERPH4}=  Evaluate  ${PUSERNAME}+305
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH4}${\n}
    ${PUSERPH5}=  Evaluate  ${PUSERNAME}+306
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH5}${\n}
    ${PUSERMAIL3}=   Set Variable  ${P_Email}${PUSERPH4}.${test_mail}
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH4}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH5}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL3}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  4  15  
    ${desc}=   FakerLibrary.sentence  nb_words=2  variable_nb_words=False
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${resp}=  Update Business Profile with schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${lid}  ${resp.json()['baseLocation']['id']}
    ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${fields.status_code}   200
    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}
    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Waitlist
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  18  ${GST_num}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    
    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    ${licenses}=  Jaldee Coupon Target License  ${lic1} 
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_codeH}=    FakerLibrary.word
    Set Suite Variable  ${cupn_codeH}
    clear_jaldeecoupon  ${cupn_codeH}
    ${resp}=  Create Jaldee Coupon  ${cupn_codeH}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_codeH}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_W}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    
    
    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200

    ${fname}=  FakerLibrary.name
    Set suite Variable   ${fname}
    ${name1}=  FakerLibrary.name
    Set Suite Variable   ${name1}
    ${city}=   get_place
    Set Suite Variable   ${city}
    ${IFSC}=  Generate_ifsc_code
    Set Suite Variable   ${IFSC}
    ${ph}=   evaluate    ${PUSERNAME152}+1234
    Set Suite Variable   ${ph}
    ${acc}=    Generate_random_value  11   ${digits}
    Set Suite Variable   ${acc}

    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${ph}   ${pan_num}  ${acc}  ${name1}  ${IFSC}  ${fname}  ${fname}  ${city}   ${businessStatus[1]}  ${accounttype[1]}  
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERNAME_W}
    Set Suite Variable  ${pid}
    #${merchantid}=   Random Int  min=1111111  max=5555555
    ${resp}=  SetMerchantId  ${pid}  ${merchantid}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  payuVerify  ${pid}
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_W}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${ph}   ${pan_num}  ${acc}  ${name1}  ${IFSC}  ${fname}  ${fname}  ${city}   ${businessStatus[1]}  ${accounttype[1]}
    Should Be Equal As Strings    ${resp.status_code}   200

    clear_customer   ${PUSERNAME_W}

    ${resp}=  AddCustomer  ${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}

    # ${cid}=  get_id  ${CUSERNAME15}
    # Set Suite Variable  ${cid}
    ${lid}=   Create Sample Location
    Set Suite Variable    ${lid} 
    
    ${ser_desc}=   FakerLibrary.word
    Set Suite Variable   ${ser_desc}
    ${total_amount}=    Random Int  min=100  max=500
    Set Suite Variable  ${total_amount}
    ${min_prepayment}=  Random Int   min=1   max=50
    Set Suite Variable   ${min_prepayment}
    ${ser_duratn}=      Random Int   min=10   max=30
    Set Suite Variable   ${ser_duratn}
    ${resp}=   Create Service  ${SERVICE1}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  50  1000  ${bool[1]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE2}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  1000  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE3}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id3}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE4}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id4}  ${resp.json()}
    ${strt_time}=   db.subtract_timezone_time  ${tz}  2  00
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}       0  20 
    Set Suite Variable    ${end_time} 
    
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  2  100  ${lid}  ${s_id1}  ${s_id2}  ${s_id3}  ${s_id4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id2}  ${qid1}  ${DAY1}  ${cnote}  ${bool[1]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}   
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  1000.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  1000.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  1180.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  1180.0
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeH}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_codeH}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeH}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_codeH}  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}   netTotal=1000.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=1130.0  billPaymentStatus=${paymentStatus[0]}  amountDue=1130.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_codeH}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeH}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  1000.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    ${resp}=  Accept Payment  ${wid}  ${payment_modes[0]}  1130.0  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Payment By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[0]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  1130.0

    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]} 
  
    ${end}=  db.add_tz_time24  ${tz}   0  0
    ${start}=  db.add_tz_time24  ${tz}   0  -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports By Provider
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['listOfJaldeeCoupons']}  {"${cupn_codeH}":50.0}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[3]}


JD-TC-GetReimburseReports-3
    [Documentation]  Consumer apply a coupon at self payment and GetReimburseReports

    #clear_reimburseReport
    ${resp}=   Encrypted Provider Login  ${PUSERNAME_W}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY1}  ${cnote}  ${bool[1]}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}   
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  1000.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  1000.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  1180.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  1180.0
    ${resp}=  Accept Payment  ${wid}  ${payment_modes[7]}  1180  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Apply Jaldee Coupon At Selfpay  ${wid}  ${cupn_codeH}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By Consumer  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_codeH}']['value']}  50.0
    
    Verify Response  ${resp}  uuid=${wid}   netTotal=1000.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  netRate=1130.0  billPaymentStatus=${paymentStatus[0]}  amountDue=1130.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeH}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  1000.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    #Make payment Consumer  640  ${payment_modes[2]}  ${wid}  ${pid}  ${purpose[1]}  ${cid}
    ${resp}=  Make payment Consumer  1130.0  ${payment_modes[2]}  ${wid}  ${pid}  ${purpose[1]}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain  ${resp.json()['response']}  \"merchantId\":\"${merchantid}\
    Should Contain  ${resp.json()['response']}  <td><input name=\"amount\" value=1130.00 /></td>
    Should Contain  ${resp.json()['response']}  <td><input name=\"email\" id=\"email\" value=${CUSEREMAIL5} /></td>
    Should Contain  ${resp.json()['response']}  <td>Phone: </td>\n   <td><input name=\"phone\" value=${CUSERNAME15} ></td>
    ${resp}=  Make payment Consumer Mock  1130.0  ${bool[1]}  ${wid}   ${pid}  ${purpose[1]}   ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   1s
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]} 
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_W}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_codeH}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeH}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  1000.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  1000.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  1130.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  0.0
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[2]}
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_codeH}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  100.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  2
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 

    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]} 
    
    ${end}=  db.add_tz_time24  ${tz}   0  0
    ${start}=  db.add_tz_time24  ${tz}   0  -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports By Provider
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}  0.0    
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[3]}
    Should Be Equal As Strings  ${resp.json()[0]['listOfJaldeeCoupons']}  {"${cupn_codeH}":50.0}


JD-TC-GetReimburseReports -UH5
    [Documentation]   Get jaldee coupons by without login  
    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-GetReimburseReports -UH6
    [Documentation]   Consumer get jaldee coupons
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

