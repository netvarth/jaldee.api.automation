*** Settings ***
Suite Teardown    Run Keywords  Delete All Sessions  resetsystem_time
Test Teardown     Delete All Sessions
Force Tags        POC
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
#Suite Setup     Run Keywords  clear_queue  ${PUSERNAME1}  AND  clear_waitlist  ${PUSERNAME1}    AND  clear_service  ${PUSERNAME1}  AND  clear_location  ${PUSERNAME1}  AND  clear_jaldeecoupon  ${cupn_codeAA}  AND  clear_jaldeecoupon  ${cupn_codeBB}  AND  clear_jaldeecoupon  ${cupn_codeCC}  AND  clear_jaldeecoupon  ${cupn_codeDD}  AND  clear_jaldeecoupon  ${cupn_codeEE}  AND  clear_jaldeecoupon  ${cupn_code05}  AND  clear_jaldeecoupon  Coupon06  AND  clear_jaldeecoupon  ${cupn_code07}  AND  clear_jaldeecoupon  ${cupn_code08}  AND  clear_jaldeecoupon  Coupon09  AND  clear_jaldeecoupon  Coupon10  AND  clear_jaldeecoupon  Coupon11  AND  clear_jaldeecoupon  Coupon12  AND  clear_jaldeecoupon  Coupon13  AND  clear_jaldeecoupon  Coupon14  AND  clear_jaldeecoupon  Coupon15  AND  clear_jaldeecoupon  Coupon16  AND  clear_payment_invoice  ${PUSERNAME1}   AND  clear_tax_gstNum  14DEFBV1100M2Z7

*** Variables ***

${SERVICE1}  Note Book1106
${SERVICE2}  boots106
${SERVICE3}  pen106
${SERVICE4}  Note Book12106
${SERVICE5}  boots13106
${SERVICE6}  pen15106
${SERVICE7}  pen25106
${SERVICE8}  pen155106
${SERVICE9}  pen255106
${SERVICE10}  pen26106
${SERVICE11}  pen266106
${queue1}  morning
${LsTime}   08:00 AM
${LeTime}   09:00 AM

${sTime}    09:00 PM
${eTime}    11:00 PM
${longi}        89.524764
${latti}        86.524764
${sTime1}   	08:52 AM
${eTime1}   	06:30 PM
${sTime2}   	06:40 PM
${eTime2}   	07:30 PM
*** Test Cases ***

JD-TC-GetJaldeeCouponStatsBySuperadmin-1
    clear_reimburseReport
    [Documentation]  Consumer apply a coupon at self payment and check get jaldee coupon stats
    clear_payment_invoice  ${PUSERNAME1}
    ${resp}=   ProviderLogin  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[5]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[5]['subDomains'][0]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  add_date  10
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_codeAA}=   FakerLibrary.word
    Set Suite Variable    ${cupn_codeAA}
    ${cupn_name}=   FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable   ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable   ${c_des}
    ${p_des}=   FakerLibrary.sentence
    set Suite Variable   ${p_des}

    clear_jaldeecoupon    ${cupn_codeAA}
    ${resp}=  Create Jaldee Coupon  ${cupn_codeAA}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  15  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon   ${cupn_codeAA}   ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode   ${cupn_codeAA}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ACTIVE
    ${resp}=  Get Jaldee Coupons Stats   ${cupn_codeAA}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${provider_pushed}  ${resp.json()['providerPushed']} 
    Set Suite Variable  ${enabled_count}  ${resp.json()['enabledCount']}
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   ProviderLogin  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Jaldee Coupon By Provider   ${cupn_codeAA}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeAA}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ENABLED
    ${resp}=  Update Tax Percentage  18  14DEFBV1100M2Z7  
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable  ${pid}
    ${cid}=  get_id  ${CUSERNAME5}
    Set Suite Variable  ${cid}
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}

    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${description}=  FakerLibrary.sentence
    ${address}=  get_address

    ${list}=  Create List   1  2  3  4  5  6  7
    ${resp}=  Create Location  ABCDE  ${longi}  ${latti}  www.${companySuffix}.com  ${postcode}  ${address}  free  ${bool[1]}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${LsTime}  ${LeTime}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${lid}  ${resp.json()} 

    ${resp}=  Create Service  ${SERVICE1}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  email  50  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE2}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  email  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE3}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  email  0  500  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${s_id3}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE4}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  email  50  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id4}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE5}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  email  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id5}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE6}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  email  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${s_id6}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE7}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  email  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${s_id7}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE8}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  email  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${s_id8}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE9}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  email  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${s_id9}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE10}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  email  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${s_id10}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE11}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  email  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${s_id11}  ${resp.json()}
    
    ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}  ${s_id1}  ${s_id2}  ${s_id3}  ${s_id4}  ${s_id5}  ${s_id6}  ${s_id7}  ${s_id8}  ${s_id9}  ${s_id10}  ${s_id11}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid}  ${s_id2}  ${qid1}  ${DAY1}  ${description}   ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}   
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  New  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  590.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  590.0

    ${resp}=  Accept Payment  ${wid}  self_pay  590  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Apply Jaldee Coupon At Selfpay  ${wid}  ${cupn_codeAA}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}

    # ${resp}=  Make payment Consumer  540  CC  ${wid}  ${pid}  billPayment
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Contain  ${resp.json()['response']}  <td><input name=\"amount\" value=540.00 /></td>
    # Should Contain  ${resp.json()['response']}  <td><input name=\"email\" id=\"email\" value=c5.ynwtest@netvarth.com /></td>
    # Should Contain  ${resp.json()['response']}  <td>Phone: </td>\n   <td><input name=\"phone\" value=1087654326 ></td>
    # Should Contain  ${resp.json()['response']}  \"merchantId\":\"6675005\"
     
    ${resp}=  Make payment Consumer Mock  540  ${bool[1]}  ${wid}  ${pid}  billPayment
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=FullyPaid 

    ${resp}=   ProviderLogin  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_codeAA}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 

    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  Settled 
    sleep  03s
    ${end}=  add_time24  0  0
    ${start}=  add_time24  0  -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Set Test Variable  ${invoice_id}  ${resp.json()[0]['invoiceId']}
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}  513.0
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  563.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  PAYMENTPENDING
    Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}  540.0
    Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['gatewayCommission']}  10.8
    Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['jaldeeCommission']}  16.2
    Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}  513.0

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Evaluate  ${enabled_count}+1
    Set Suite Variable  ${count}
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_codeAA}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  0.0 
    Should Be Equal As Strings  ${resp.json()['providerPushed']}  ${provider_pushed}
    Should Be Equal As Strings  ${resp.json()['enabledCount']}  ${count}
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  50.0

    ${dis_note}=    FakerLibrary.sentence
    Set Suite Variable    ${dis_note}
    ${privte_note}=    FakerLibrary.sentence
    Set Suite Variable    ${privte_note}
    
    ${invoice1}=  Reimburse Ivoices  ${invoice_id}  ${dis_note}  ${Reimburse_invoice[1]}  ${privte_note}  ${cupn_for[0]}
    ${invoices}=  Create List  ${invoice1}
    ${resp}=  Reimburse Payment  ${invoices}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports By Provider  id-eq=${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  563.0
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}  513.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[2]}
    Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}  540.0
    Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['gatewayCommission']}  10.8
    Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['jaldeeCommission']}  16.2
    Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}  513.0


    Should Contain  ${resp.json()[0]['listOfJaldeeCoupons']}  ${cupn_codeAA}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  563.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[2]}
    Should Be Equal As Strings  ${resp.json()[0]['subJcTotalPaid']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['subJbankTotalPaid']}  513.0
    Should Be Equal As Strings  ${resp.json()[0]['totalPaid']}  563.0

    ${resp}=  Get Jaldee Coupons Stats  ${cupn_codeAA}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  50.0 
    Should Be Equal As Strings  ${resp.json()['providerPushed']}  ${provider_pushed}
    Should Be Equal As Strings  ${resp.json()['enabledCount']}  ${count}
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  0.0

JD-TC-GetJaldeeCouponStatsBySuperadmin-2
    [Documentation]  Consumer apply a coupon at Checkin time and check coupon stats
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[5]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[5]['subDomains'][0]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  add_date  10
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_codeBB}=   FakerLibrary.word
    Set Suite Variable    ${cupn_codeBB}
    clear_jaldeecoupon  ${cupn_codeBB}
    ${resp}=  Create Jaldee Coupon  ${cupn_codeBB}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_codeCC}=   FakerLibrary.word
    Set Suite Variable    ${cupn_codeCC}
    clear_jaldeecoupon  ${cupn_codeCC}
    ${resp}=  Create Jaldee Coupon  ${cupn_codeCC}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_codeBB}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_codeCC}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_codeBB}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${provider_pushed1}  ${resp.json()['providerPushed']} 
    Set Suite Variable  ${enabled_count1}  ${resp.json()['enabledCount']}
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_codeCC}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${provider_pushed2}  ${resp.json()['providerPushed']} 
    Set Suite Variable  ${enabled_count2}  ${resp.json()['enabledCount']}
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   ProviderLogin  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_codeBB}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeBB}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ENABLED
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_codeCC}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeCC}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ENABLED
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${cid}=  get_id  ${CUSERNAME5}    
    ${coupons}=  Create List  ${cupn_codeAA}  ${cupn_codeBB}  ${cupn_codeCC}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id1}  i need  ${bool[0]}  ${coupons}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   ProviderLogin  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_codeAA}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  100.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  2
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  50.0 
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_codeBB}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_codeCC}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 

    # ${resp}=  Make payment Consumer  440  CC  ${wid}  ${pid}  billPayment
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Contain  ${resp.json()['response']}  <td><input name=\"amount\" value=440.00 /></td>
    # Should Contain  ${resp.json()['response']}  <td><input name=\"email\" id=\"email\" value=c5.ynwtest@netvarth.com /></td>
    # Should Contain  ${resp.json()['response']}  <td>Phone: </td>\n   <td><input name=\"phone\" value=1087654326 ></td>
    ${resp}=  Make payment Consumer Mock  440  ${bool[1]}  ${wid}  ${pid}  billPayment
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=FullyPaid 

    ${resp}=   ProviderLogin  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  Settled 
    sleep  02s
    ${end}=  add_time24  0  0
    ${start}=  add_time24  0  -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${invoice_id}  ${resp.json()[0]['invoiceId']}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count1}=  Evaluate  ${enabled_count1}+1
    Set Suite Variable  ${count1}
    ${count2}=  Evaluate  ${enabled_count2}+1
    Set Suite Variable  ${count2}
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_codeAA}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  100.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  2
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerPushed']}  ${provider_pushed}
    Should Be Equal As Strings  ${resp.json()['enabledCount']}  ${count}
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  50.0
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_codeBB}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  0.0 
    Should Be Equal As Strings  ${resp.json()['providerPushed']}  ${provider_pushed1}
    Should Be Equal As Strings  ${resp.json()['enabledCount']}  ${count1}
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  50.0
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_codeCC}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  0.0 
    Should Be Equal As Strings  ${resp.json()['providerPushed']}  ${provider_pushed2}
    Should Be Equal As Strings  ${resp.json()['enabledCount']}  ${count2}
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  50.0
    
    ${invoice1}=  Reimburse Ivoices  ${invoice_id}  ${dis_note}  ${Reimburse_invoice[1]}  ${privte_note}  ${cupn_for[0]}
    ${invoices}=  Create List  ${invoice1}
    ${resp}=  Reimburse Payment  ${invoices}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports By Provider  id-eq=${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}     418.0
    Should Contain  ${resp.json()[0]['listOfJaldeeCoupons']}  ${cupn_codeAA}
    Should Contain  ${resp.json()[0]['listOfJaldeeCoupons']}  ${cupn_codeBB}
    Should Contain  ${resp.json()[0]['listOfJaldeeCoupons']}  ${cupn_codeCC}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  150.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  568.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[2]}
    Should Be Equal As Strings  ${resp.json()[0]['subJcTotalPaid']}  150.0
    Should Be Equal As Strings  ${resp.json()[0]['subJbankTotalPaid']}  418.0
    Should Be Equal As Strings  ${resp.json()[0]['totalPaid']}  568.0

    Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}  440.0
    Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['gatewayCommission']}  8.8
    Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['jaldeeCommission']}  13.2
    Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}  418.0

    ${resp}=  Get Jaldee Coupons Stats  ${cupn_codeAA}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  100.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  2
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  100.0
    Should Be Equal As Strings  ${resp.json()['providerPushed']}  ${provider_pushed}
    Should Be Equal As Strings  ${resp.json()['enabledCount']}  ${count}
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  0.0

    ${resp}=  Get Jaldee Coupons Stats  ${cupn_codeBB}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerPushed']}  ${provider_pushed1}
    Should Be Equal As Strings  ${resp.json()['enabledCount']}  ${count1}
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  0.0
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_codeCC}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerPushed']}  ${provider_pushed2}
    Should Be Equal As Strings  ${resp.json()['enabledCount']}  ${count2}
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  0.0

JD-TC-GetJaldeeCouponStatsBySuperadmin-3
    [Documentation]  Consumer apply a coupon at Checkin time when that coupon has the rule of CombineWithOtherCoupons is ${bool[0]} and check coupon status
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[5]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[5]['subDomains'][0]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  add_date  10
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_codeDD}=   FakerLibrary.word
    Set Suite Variable    ${cupn_codeDD}
    clear_jaldeecoupon  ${cupn_codeDD}

    ${resp}=  Create Jaldee Coupon  ${cupn_codeDD}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_codeDD}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_codeDD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${provider_pushed3}  ${resp.json()['providerPushed']} 
    Set Suite Variable  ${enabled_count3}  ${resp.json()['enabledCount']}
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   ProviderLogin  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_codeDD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeDD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ENABLED
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME5}    
    ${coupons}=  Create List  ${cupn_codeAA}  ${cupn_codeBB}  ${cupn_codeDD}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id3}  i need  ${bool[0]}  ${coupons}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  422 
    Log    ${resp.json()}
    ${coupons}=  Create List  ${cupn_codeAA}  ${cupn_codeBB}  
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id3}  i need  ${bool[0]}  ${coupons}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=   ProviderLogin  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_codeAA}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  150.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  3
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  100.0 
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_codeBB}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  100.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  2
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  50.0 
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_codeCC}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  50.0 
     ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_codeDD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  0.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 

    # ${resp}=  Make payment Consumer  400  CC  ${wid}  ${pid}  billPayment
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Contain  ${resp.json()['response']}  <td><input name=\"amount\" value=400.00 /></td>
    # Should Contain  ${resp.json()['response']}  <td><input name=\"email\" id=\"email\" value=c5.ynwtest@netvarth.com /></td>
    # Should Contain  ${resp.json()['response']}  <td>Phone: </td>\n   <td><input name=\"phone\" value=1087654326 ></td>
    ${resp}=  Make payment Consumer Mock  400  ${bool[1]}  ${wid}  ${pid}  billPayment
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=FullyPaid 
    ${resp}=   ProviderLogin  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  Settled 
    sleep  02s
    ${end}=  add_time24  0  0
    ${start}=  add_time24  0  -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${invoice_id}  ${resp.json()[0]['invoiceId']}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count3}=  Evaluate  ${enabled_count3}+1
    Set Suite Variable  ${count3}
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_codeAA}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  150.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  3
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  100.0
    Should Be Equal As Strings  ${resp.json()['providerPushed']}  ${provider_pushed}
    Should Be Equal As Strings  ${resp.json()['enabledCount']}  ${count}
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  50.0
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_codeBB}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  100.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  2
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerPushed']}  ${provider_pushed1}
    Should Be Equal As Strings  ${resp.json()['enabledCount']}  ${count1}
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  50.0
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_codeCC}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerPushed']}  ${provider_pushed2}
    Should Be Equal As Strings  ${resp.json()['enabledCount']}  ${count2}
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  0.0
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_codeDD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  0.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  0
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  0.0 
    Should Be Equal As Strings  ${resp.json()['providerPushed']}  ${provider_pushed3}
    Should Be Equal As Strings  ${resp.json()['enabledCount']}  ${count3}
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  0.0
    
    ${invoice1}=  Reimburse Ivoices  ${invoice_id}  ${dis_note}  ${Reimburse_invoice[1]}  ${privte_note}  ${cupn_for[0]}
    ${invoices}=  Create List  ${invoice1}
    ${resp}=  Reimburse Payment  ${invoices}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports By Provider  id-eq=${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}  380.0
    Should Contain  ${resp.json()[0]['listOfJaldeeCoupons']}  ${cupn_codeAA}
    Should Contain  ${resp.json()[0]['listOfJaldeeCoupons']}  ${cupn_codeBB}
    Should Not Contain  ${resp.json()[0]['listOfJaldeeCoupons']}  ${cupn_codeDD}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  100.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  480.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[2]}
    Should Be Equal As Strings  ${resp.json()[0]['subJcTotalPaid']}  100.0
    Should Be Equal As Strings  ${resp.json()[0]['subJbankTotalPaid']}  380.0
    Should Be Equal As Strings  ${resp.json()[0]['totalPaid']}  480.0

    Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}  400.0
    Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['gatewayCommission']}  8.0
    Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['jaldeeCommission']}  12.0
    Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}  380.0

    ${resp}=  Get Jaldee Coupons Stats  ${cupn_codeAA}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  150.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  3
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  150.0
    Should Be Equal As Strings  ${resp.json()['providerPushed']}  ${provider_pushed}
    Should Be Equal As Strings  ${resp.json()['enabledCount']}  ${count}
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  0.0

    ${resp}=  Get Jaldee Coupons Stats  ${cupn_codeBB}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  100.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  2
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  100.0
    Should Be Equal As Strings  ${resp.json()['providerPushed']}  ${provider_pushed1}
    Should Be Equal As Strings  ${resp.json()['enabledCount']}  ${count1}
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  0.0
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_codeCC}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerPushed']}  ${provider_pushed2}
    Should Be Equal As Strings  ${resp.json()['enabledCount']}  ${count2}
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  0.0
    
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_codeDD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  0.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  0
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  0.0 
    Should Be Equal As Strings  ${resp.json()['providerPushed']}  ${provider_pushed3}
    Should Be Equal As Strings  ${resp.json()['enabledCount']}  ${count3}
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  0.0

JD-TC-GetJaldeeCouponStatsBySuperadmin-4
	[Documentation]  Partial payment done(only jaldee coupon amount paid)
    Comment  Consumer apply a coupon at Checkin time when that coupon has discount type as PERCENTAGE and check coupon status
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[5]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[5]['subDomains'][0]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  add_date  10
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_codeEE}=   FakerLibrary.word
    Set Suite Variable    ${cupn_codeEE}
    clear_jaldeecoupon  ${cupn_codeEE}

    ${resp}=  Create Jaldee Coupon  ${cupn_codeEE}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[1]}  10  100  ${bool[0]}  ${bool[0]}  100  100  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_codeEE}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   ProviderLogin  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_codeEE}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeEE}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ENABLED
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME5}    
    ${coupons}=  Create List  ${cupn_codeEE}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id4}  i need  ${bool[0]}  ${coupons}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=   ProviderLogin  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_codeEE}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 

    # ${resp}=  Make payment Consumer  540  CC  ${wid}  ${pid}  billPayment
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Contain  ${resp.json()['response']}  <td><input name=\"amount\" value=540.00 /></td>
    # Should Contain  ${resp.json()['response']}  <td><input name=\"email\" id=\"email\" value=c5.ynwtest@netvarth.com /></td>
    # Should Contain  ${resp.json()['response']}  <td>Phone: </td>\n   <td><input name=\"phone\" value=1087654326 ></td>
    ${resp}=  Make payment Consumer Mock  540  ${bool[1]}  ${wid}  ${pid}  billPayment
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=FullyPaid 
    ${resp}=   ProviderLogin  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  Settled 
    sleep  02s
    ${end}=  add_time24  0  0
    ${start}=  add_time24  0  -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${invoice_id}  ${resp.json()[0]['invoiceId']}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_codeEE}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  0.0 
    Should Be Equal As Strings  ${resp.json()['providerPushed']}  ${provider_pushed3}
    Should Be Equal As Strings  ${resp.json()['enabledCount']}  ${count3}
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  50.0
    
    ${invoice1}=  Reimburse Ivoices  ${invoice_id}  ${dis_note}  ${Reimburse_invoice[0]}  ${privte_note}  ${cupn_for[0]}
    ${invoices}=  Create List  ${invoice1}
    ${resp}=  Reimburse Payment  ${invoices}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Reimburse Reports By Provider  id-eq=${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}  513.0
    Should Contain  ${resp.json()[0]['listOfJaldeeCoupons']}  ${cupn_codeEE}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  563.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[2]}
    Should Be Equal As Strings  ${resp.json()[0]['subJcTotalPaid']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['subJbankTotalPaid']}  513.0
    Should Be Equal As Strings  ${resp.json()[0]['totalPaid']}  563.0
    Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}  540.0
    Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['gatewayCommission']}  10.8
    Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['jaldeeCommission']}  16.2
    Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}  513.0
    Sleep  2s
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_codeEE}
    Log   ${resp.json()}    
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  50.0 
    Should Be Equal As Strings  ${resp.json()['providerPushed']}  ${provider_pushed3}
    Should Be Equal As Strings  ${resp.json()['enabledCount']}  ${count3}
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  0.0


JD-TC-GetJaldeeCouponStatsBySuperadmin-5
    [Documentation]  Consumer apply a coupon at Checkin time when that coupon as defaultly enabled and check its status
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd2}  ${resp.json()[0]['subDomains'][1]['subDomain']}
    Set Test Variable  ${sd3}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd4}  ${resp.json()[1]['subDomains'][1]['subDomain']}
    ${resp}=   ProviderLogin  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${d5}  ${resp.json()['sector']}
    Set Test Variable  ${sd5}  ${resp.json()['subSector']}
    ProviderLogout

    ${domains}=  Jaldee Coupon Target Domains  ${d1}  ${d2}  ${d5}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}  ${d1}_${sd2}  ${d2}_${sd3}  ${d2}_${sd4}  ${d5}_${sd5}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  add_date  10
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${account_id}=  get_acc_id  ${PUSERNAME1}
    ${account_id}=  Create List  ${account_id}
    Set Suite Variable    ${account_id}      ${account_id}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code05}=   FakerLibrary.word
    Set Suite Variable    ${cupn_code05}

    clear_jaldeecoupon  ${cupn_code05}
    ${resp}=  Create Jaldee Coupon For Providers  ${cupn_code05}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[1]}  10  100  ${bool[1]}  ${bool[0]}  100  100  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${account_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code05}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   ProviderLogin  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code05}
       
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ENABLED
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME5}    
    ${coupons}=  Create List  ${cupn_code05}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id5}  i need  ${bool[0]}  ${coupons}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=   ProviderLogin  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code05}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 

    # ${resp}=  Make payment Consumer  540  CC  ${wid}  ${pid}  billPayment
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Contain  ${resp.json()['response']}  <td><input name=\"amount\" value=540.00 /></td>
    # Should Contain  ${resp.json()['response']}  <td><input name=\"email\" id=\"email\" value=c5.ynwtest@netvarth.com /></td>
    # Should Contain  ${resp.json()['response']}  <td>Phone: </td>\n   <td><input name=\"phone\" value=1087654326 ></td>
    ${resp}=  Make payment Consumer Mock  540  ${bool[1]}  ${wid}  ${pid}  billPayment
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=FullyPaid 
    ${resp}=   ProviderLogin  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  Settled 

    sleep  02s
    ${end}=  add_time24  0  0
    ${start}=  add_time24  0  -5
    
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  4s
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_code05}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  0.0 
    Should Be Equal As Strings  ${resp.json()['providerPushed']}  1
    Should Be Equal As Strings  ${resp.json()['enabledCount']}  1
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  50.0

JD-TC-GetJaldeeCouponStatsBySuperadmin-6
    [Documentation]  Consumer apply a coupon at Checkin time when that coupon as always enabled and check its status
    
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  add_date  10
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code07}=   FakerLibrary.word
    Set Suite Variable    ${cupn_code07}
    clear_jaldeecoupon  ${cupn_code07}
    ${resp}=  Create Jaldee Coupon For Providers  ${cupn_code07}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[1]}  10  100  ${bool[1]}  ${bool[1]}  100  100  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}   ${account_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code07}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   ProviderLogin  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
      
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code07}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ENABLED
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME5}    
    ${coupons}=  Create List  ${cupn_code07}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id6}  i need  ${bool[0]}  ${coupons}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=   ProviderLogin  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code07}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 

    # ${resp}=  Make payment Consumer  540  CC  ${wid}  ${pid}  billPayment
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Contain  ${resp.json()['response']}  <td><input name=\"amount\" value=540.00 /></td>
    # Should Contain  ${resp.json()['response']}  <td><input name=\"email\" id=\"email\" value=c5.ynwtest@netvarth.com /></td>
    # Should Contain  ${resp.json()['response']}  <td>Phone: </td>\n   <td><input name=\"phone\" value=1087654326 ></td>
    ${resp}=  Make payment Consumer Mock  540  ${bool[1]}  ${wid}  ${pid}  billPayment
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=FullyPaid 

    ${resp}=   ProviderLogin  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  Settled 

    sleep  02s
    ${end}=  add_time24  0  0
    ${start}=  add_time24  0  -5    
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  4s
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_code07}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  0.0 
    Should Be Equal As Strings  ${resp.json()['providerPushed']}  1
    Should Be Equal As Strings  ${resp.json()['enabledCount']}  1
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  50.0

JD-TC-GetJaldeeCouponStatsBySuperadmin-UH1
    [Documentation]  create reimburse report again and agian then check values in get jaldee coupon stats are same
    ${resp}=   ProviderLogin  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    sleep  02s
    ${end}=  add_time24  0  0
    ${start}=  add_time24  0  -5    
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_code07}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  0.0 
    Should Be Equal As Strings  ${resp.json()['providerPushed']}  1
    Should Be Equal As Strings  ${resp.json()['enabledCount']}  1
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  50.0

JD-TC-GetJaldeeCouponStatsBySuperadmin-UH2
    [Documentation]  Consumer apply a coupon at Checkin time.but minBillAmount is not satisfied and check its status
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  add_date  10
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code08}=   FakerLibrary.word
    Set Suite Variable    ${cupn_code08}
    clear_jaldeecoupon  ${cupn_code08}

    ${resp}=  Create Jaldee Coupon For Providers  ${cupn_code08}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[1]}  10  100  ${bool[1]}  ${bool[1]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${account_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code08}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   ProviderLogin  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code08}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ENABLED
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME5}    
    ${coupons}=  Create List  ${cupn_code08}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id7}  i need  ${bool[0]}  ${coupons}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=   ProviderLogin  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code08}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  0.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 

    # ${resp}=  Make payment Consumer  590  CC  ${wid}  ${pid}  billPayment
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Contain  ${resp.json()['response']}  <td><input name=\"amount\" value=590.00 /></td>
    # Should Contain  ${resp.json()['response']}  <td><input name=\"email\" id=\"email\" value=c5.ynwtest@netvarth.com /></td>
    # Should Contain  ${resp.json()['response']}  <td>Phone: </td>\n   <td><input name=\"phone\" value=1087654326 ></td>
    ${resp}=  Make payment Consumer Mock  590  ${bool[1]}  ${wid}  ${pid}  billPayment
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=FullyPaid 

    ${resp}=   ProviderLogin  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  Settled 
    sleep  02s
    ${end}=  add_time24  0  0
    ${start}=  add_time24  0  -5    
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  5s
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_code08}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  0.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  0
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  0.0 
    Should Be Equal As Strings  ${resp.json()['providerPushed']}  1
    Should Be Equal As Strings  ${resp.json()['enabledCount']}  1
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  0.0

JD-TC-GetJaldeeCouponStatsBySuperadmin-UH3
    [Documentation]  coupon  2times applied  and one bill settled and check report  so only one coupon report will be genereate 
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd2}  ${resp.json()[0]['subDomains'][1]['subDomain']}
    Set Test Variable  ${sd3}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd4}  ${resp.json()[1]['subDomains'][1]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}  ${d2}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}  ${d1}_${sd2}  ${d2}_${sd3}  ${d2}_${sd4}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  add_date  10
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Jaldee Coupon For Providers  Coupon09  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[1]}  10  100  ${bool[1]}  ${bool[1]}  100  100  5  5  5  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${account_id}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  Coupon09  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   ProviderLogin  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupons By Coupon_code  Coupon09
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ENABLED
    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME3}    
    ${coupons}=  Create List  Coupon09
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id8}  i need  ${bool[0]}  ${coupons}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=   ProviderLogin  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  Coupon09
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 
  
    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id7}  i need  ${bool[0]}  ${coupons}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=   ProviderLogin  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  Coupon09
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  100.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  2
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 
    ${resp}=  Accept Payment  ${wid}  cash  540  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Settl Bill  ${wid}
    
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  Settled 
    sleep  02s
    ${end}=  add_time24  0  0
    ${start}=  add_time24  0  -5    
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  5s
    ${resp}=  Get Jaldee Coupons Stats  Coupon09
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  0.0 
    Should Be Equal As Strings  ${resp.json()['providerPushed']}  1
    Should Be Equal As Strings  ${resp.json()['enabledCount']}  1
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  50.0

JD-TC-GetJaldeeCouponStatsBySuperadmin -UH7
    [Documentation]   Disable a Jaldee Coupon without login  
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  Coupon12
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED_IN_SA}."

JD-TC-GetJaldeeCouponStatsBySuperadmin -UH8
    [Documentation]   Consumer disable a Jaldee Coupon
    ${resp}=   Consumer Login  ${CUSERNAME}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  Coupon12
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-GetJaldeeCouponStatsBySuperadmin -UH9
    [Documentation]   Another Provider disable a Jaldee Coupon
    ${resp}=   ProviderLogin  ${PUSERNAME3}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  Coupon12
    
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_NOT_VALID}" 
    

















