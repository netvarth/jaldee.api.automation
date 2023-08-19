

*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Coupon Stats
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
${self}  0
${digits}       0123456789

*** Test Cases ***

JD-TC-GetJaldeeCouponStatsBySuperadmin-1
  
    clear_payment_invoice  ${PUSERNAME160}
    [Documentation]  Consumer apply a coupon at self payment and check get jaldee coupon stats
    clear_payment_invoice  ${PUSERNAME160}
    clear_location  ${PUSERNAME160}
    clear_service  ${PUSERNAME160}
    clear_queue  ${PUSERNAME160}
    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
    Set Suite Variable   ${d1}    ${resp.json()['sector']}
    Set Suite Variable   ${sd1}    ${resp.json()['subSector']}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${accId160}=  get_acc_id  ${PUSERNAME160}
    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
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
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${couponStatus[1]}

    ${resp}=  Get Jaldee Coupons Stats   ${cupn_codeAA}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${provider_pushed}  ${resp.json()['providerPushed']} 
    Set Suite Variable  ${enabled_count}  ${resp.json()['enabledCount']}
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Jaldee Coupon By Provider   ${cupn_codeAA}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeAA}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}
    Log    ${resp.json()}
    ${pid}=  get_acc_id  ${PUSERNAME160}
    Set Suite Variable  ${pid}


    ${DAY}=  get_date
    Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
   
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
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME160}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  payuVerify  ${pid}
    Log  ${resp}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME160}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}    
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  SetMerchantId  ${pid}  ${merchantid}
    
    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}



    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
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

    ${resp}=  Create Service  ${SERVICE1}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  50  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE2}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE3}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${s_id3}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE4}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  50  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id4}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE5}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id5}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE6}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${s_id6}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE7}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${s_id7}  ${resp.json()}
   
    ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}  ${s_id1}  ${s_id2}  ${s_id3}  ${s_id4}  ${s_id5}  ${s_id6}  ${s_id7} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid}  ${s_id2}  ${qid1}  ${DAY1}  ${description}   ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    ${wid1}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid1[0]}   
    sleep  2s
    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid1}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  640.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  640.0

    ${resp}=  Accept Payment  ${wid1}  self_pay  640  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cidja}=  get_id   ${CUSERNAME5}
    Set Suite Variable  ${cidja}
   

    ${resp}=  Apply Jaldee Coupon At Selfpay  ${wid1}  ${cupn_codeAA}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Make payment Consumer  590  ${payment_modes[2]}  ${wid1}  ${pid}  ${purpose[1]}  ${cidja}
    Log  ${resp.json()}
     
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['amount']}  590.0
    Should Be Equal As Strings  ${resp.json()['ConsumerEmail']}   ${CUSEREMAIL5}
    Should Be Equal As Strings  ${resp.json()['values']['MOBILE_NO']}  ${CUSERNAME5}

    # # Should Contain  ${resp.json()}  <td><input name=\"amount\" value=590.00 /></td>
    # Should Contain  ${resp.json()['response']}  <td><input name=\"email\" id=\"email\" value=${CUSEREMAIL5} /></td>
    # Should Contain  ${resp.json()['response']}  <td>Phone: </td>\n   <td><input name=\"phone\" value=${CUSERNAME5} ></td>

     
    # ${resp}=  Make payment Consumer    590    ${bool[1]}   ${wid1}   ${pid}   ${purpose[1]}   ${cidja}

    # Should Be Equal As Strings  ${resp.status_code}  200
   
    # ${resp}=  Make payment Consumer Mock  ${accId201}  ${prepayAmt}  ${purpose[0]}  ${orderid3}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid8}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Make payment Consumer Mock   ${accId160}   590    ${purpose[1]}  ${wid1}  ${s_id7}  ${bool[0]}   ${bool[1]}  ${cidja}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s
    ${resp}=  Get consumer Waitlist By Id  ${wid1}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]} 

    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_codeAA}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 

    ${resp}=  Settl Bill  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid1}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]} 
    sleep  2s
    ${end}=  add_time24  0  0
    ${start}=  add_time24  0  -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${grandTotal}   ${resp.json()[0]['grantTotal']}
    # Set Test Variable  ${jBankTotal}    ${resp.json()[0]['jaldeeBankStatement']['jBankDetails']['jBankTotal']}
  
    ${resp}=  Get Reimburse Reports By Provider
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Set Test Variable  ${invoice_id}  ${resp.json()[0]['invoiceId']}
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  ${grandTotal}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[3]}
  
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
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  ${grandTotal} 
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[2]}
  

    Should Contain  ${resp.json()[0]['listOfJaldeeCoupons']}  ${cupn_codeAA}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  ${grandTotal}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[2]}
    Should Be Equal As Strings  ${resp.json()[0]['subJcTotalPaid']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['totalPaid']}  ${grandTotal}

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
    #${resp}=  Get BusinessDomainsConf
    #Should Be Equal As Strings  ${resp.status_code}  200
    #Set Test Variable  ${d1}  ${resp.json()[5]['domain']}
    #Set Test Variable  ${sd1}  ${resp.json()[5]['subDomains'][0]['subDomain']}
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
    ${resp}=  Create Jaldee Coupon  ${cupn_codeBB}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  15  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_codeCC}=   FakerLibrary.word
    Set Suite Variable    ${cupn_codeCC}
    clear_jaldeecoupon  ${cupn_codeCC}
    ${resp}=  Create Jaldee Coupon  ${cupn_codeCC}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  15  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
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
    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_codeBB}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeBB}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_codeCC}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeCC}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${cid}=  get_id  ${CUSERNAME5}    
    ${des}=   FakerLibrary.sentence
    Set Suite Variable   ${des}
    ${coupons}=  Create List  ${cupn_codeAA}  ${cupn_codeBB}  ${cupn_codeCC}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id1}  ${des}  ${bool[0]}  ${coupons}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid2}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid2}  ${wid2[0]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    #bill amount to pay,tax % ,discount vaue will get from this url
    ${resp}=  Get Bill By UUId  ${wid2}
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
    # ${cidja}=  get_id   ${CUSERNAME5}
    # Set Suite Variable  ${cidja}
   
    
   
    ${resp}=  Make payment Consumer  490  ${payment_modes[2]}  ${wid2}  ${pid}  ${purpose[1]}  ${cidja}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['amount']}  490.0
    Should Be Equal As Strings  ${resp.json()['ConsumerEmail']}   ${CUSEREMAIL5}
    Should Be Equal As Strings  ${resp.json()['values']['MOBILE_NO']}  ${CUSERNAME5}

    # Should Contain  ${resp.json()['response']}  <td><input name=\"amount\" value=490.00 /></td>
    # Should Contain  ${resp.json()['response']}  <td><input name=\"email\" id=\"email\" value=${CUSEREMAIL5} /></td>
    # Should Contain  ${resp.json()['response']}  <td>Phone: </td>\n   <td><input name=\"phone\" value=${CUSERNAME5} ></td>
    ${resp}=  Make payment Consumer   490  ${bool[1]}  ${wid2}  ${pid}  ${purpose[1]}  ${cidja}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   2s
    ${resp}=  Get consumer Waitlist By Id  ${wid2}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]} 

    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Settl Bill  ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid2}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]} 
    sleep  2s
    ${end}=  add_time24  0  0
    ${start}=  add_time24  0  -1
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${grandTotal}   ${resp.json()[0]['grantTotal']}
    # Set Test Variable  ${jBankTotal}    ${resp.json()[0]['jaldeeBankStatement']['jBankDetails']['jBankTotal']}
    # Set Test Variable  ${gatewayCommission}   ${resp.json()[0]['jaldeeBankStatement']['jBankDetails']['gatewayCommission']}
    # Set Test Variable  ${jaldeeCommission}   ${resp.json()[0]['jaldeeBankStatement']['jBankDetails']['jaldeeCommission']} 
    # Set Test Variable   ${subTotalJaldeeCoupons}  ${resp.json()[0]['subTotalJaldeeCoupons']}
    # ${settleAmt} =  Evaluate  ${jBankTotal}-${gatewayCommission}-${jaldeeCommission} 
    # ${grandTotal} =  Evaluate   ${settleAmt}+${subTotalJaldeeCoupons}

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
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Contain  ${resp.json()[0]['listOfJaldeeCoupons']}  ${cupn_codeAA}
    Should Contain  ${resp.json()[0]['listOfJaldeeCoupons']}  ${cupn_codeBB}
    Should Contain  ${resp.json()[0]['listOfJaldeeCoupons']}  ${cupn_codeCC}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  150.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  ${grandTotal}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[2]}
    Should Be Equal As Strings  ${resp.json()[0]['subJcTotalPaid']}  150.0
    Should Be Equal As Strings  ${resp.json()[0]['totalPaid']}  ${grandTotal} 
    #Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}  ${jBankTotal}
    #Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['gatewayCommission']}  ${gatewayCommission}
    #Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['jaldeeCommission']}  ${jaldeeCommission}
  

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
    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
    Set Suite Variable   ${d1}    ${resp.json()['sector']}
    Set Suite Variable   ${sd1}    ${resp.json()['subSector']}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    #${resp}=  Get BusinessDomainsConf
    #Should Be Equal As Strings  ${resp.status_code}  200
    #Set Test Variable  ${d1}  ${resp.json()[5]['domain']}
    #Set Test Variable  ${sd1}  ${resp.json()[5]['subDomains'][0]['subDomain']}
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
    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_codeDD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeDD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME6}    
    ${des}=   FakerLibrary.sentence
    Set Suite Variable   ${des}
    ${coupons}=  Create List  ${cupn_codeAA}  ${cupn_codeBB}  ${cupn_codeDD}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id2}  ${des}  ${bool[0]}  ${coupons}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  422 
    Log    ${resp.json()}
    ${coupons}=  Create List  ${cupn_codeAA}  ${cupn_codeBB}  
    clear_waitlist   ${CUSERNAME6}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id2}  ${des}  ${bool[0]}  ${coupons}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.json()}
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

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${cidj6}=  get_id   ${CUSERNAME6}
    Set Suite Variable  ${cidj6}
   

    ${resp}=  Make payment Consumer  540  ${payment_modes[2]}  ${wid}  ${pid}  ${purpose[1]}  ${cidj6}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['amount']}  490.0
    Should Be Equal As Strings  ${resp.json()['ConsumerEmail']}   ${CUSEREMAIL6}
    Should Be Equal As Strings  ${resp.json()['values']['MOBILE_NO']}  ${CUSERNAME6}
    # Should Contain  ${resp.json()['response']}  <td><input name=\"amount\" value=540.00 /></td>
    # Should Contain  ${resp.json()['response']}  <td><input name=\"email\" id=\"email\" value=${CUSEREMAIL6} /></td>
    # Should Contain  ${resp.json()['response']}  <td>Phone: </td>\n   <td><input name=\"phone\" value=${CUSERNAME6} ></td>
     ${resp}=  Make payment Consumer Mock  540  ${bool[1]}  ${wid}  ${pid}  ${purpose[1]}  ${cidj6}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]} 
    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]} 
    sleep  2s
    ${end}=  add_time24  0  0
    ${start}=  add_time24  0  -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${grandTotal}   ${resp.json()[0]['grantTotal']}
    # Set Test Variable  ${jBankTotal}    ${resp.json()[0]['jaldeeBankStatement']['jBankDetails']['jBankTotal']}
    # Set Test Variable  ${gatewayCommission}   ${resp.json()[0]['jaldeeBankStatement']['jBankDetails']['gatewayCommission']}
    # Set Test Variable  ${jaldeeCommission}   ${resp.json()[0]['jaldeeBankStatement']['jBankDetails']['jaldeeCommission']} 
    # Set Test Variable   ${subTotalJaldeeCoupons}  ${resp.json()[0]['subTotalJaldeeCoupons']}
    # ${settleAmt} =  Evaluate  ${jBankTotal}-${gatewayCommission}-${jaldeeCommission} 
    # ${grandTotal} =  Evaluate   ${settleAmt}+${subTotalJaldeeCoupons}

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
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Contain  ${resp.json()[0]['listOfJaldeeCoupons']}  ${cupn_codeAA}
    Should Contain  ${resp.json()[0]['listOfJaldeeCoupons']}  ${cupn_codeBB}
    Should Not Contain  ${resp.json()[0]['listOfJaldeeCoupons']}  ${cupn_codeDD}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  100.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  ${grandTotal}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[2]}
    Should Be Equal As Strings  ${resp.json()[0]['subJcTotalPaid']}  100.0
    Should Be Equal As Strings  ${resp.json()[0]['totalPaid']}  ${grandTotal} 
    # Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}  ${jBankTotal}
    # Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['gatewayCommission']}  ${gatewayCommission}
    # Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['jaldeeCommission']}  ${jaldeeCommission}
    # Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}   ${settleAmt}
  

    ${resp}=  Get Jaldee Coupons Stats  ${cupn_codeAA}
    Log   ${resp.json()}
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
	[Documentation]  Partial payment done(only jaldee coupon amount paid)Consumer apply a coupon at Checkin time when that coupon has discount type as PERCENTAGE and check coupon status
    
    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
    Set Suite Variable   ${d1}    ${resp.json()['sector']}
    Set Suite Variable   ${sd1}    ${resp.json()['subSector']}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    #${resp}=  Get BusinessDomainsConf
    #Should Be Equal As Strings  ${resp.status_code}  200
    #Set Test Variable  ${d1}  ${resp.json()[5]['domain']}
    #Set Test Variable  ${sd1}  ${resp.json()[5]['subDomains'][0]['subDomain']}

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
    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_codeEE}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeEE}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME5}    
    ${coupons}=  Create List  ${cupn_codeEE}
    clear_waitlist   ${CUSERNAME5}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id4}  ${des}  ${bool[0]}  ${coupons}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
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


    ${cidj5}=  get_id   ${CUSERNAME5}
    Set Suite Variable  ${cidj5}
   

    # ${resp}=  Make payment Consumer  540  ${payment_modes[2]}  ${wid}  ${pid}  ${purpose[1]}  ${cidj6}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['amount']}  490.0
    # Should Be Equal As Strings  ${resp.json()['ConsumerEmail']}   ${CUSEREMAIL6}
    # Should Be Equal As Strings  ${resp.json()['values']['MOBILE_NO']}  ${CUSERNAME6}


    # ${resp}=  Make payment Consumer  590  ${payment_modes[2]}  ${wid}  ${pid}  ${purpose[1]}  ${cidj5}
    # Should Be Equal As Strings  ${resp.status_code}  200
    #  Should Be Equal As Strings  ${resp.json()['amount']}  590.0
    # Should Be Equal As Strings  ${resp.json()['ConsumerEmail']}   ${CUSEREMAIL5}
    # Should Be Equal As Strings  ${resp.json()['values']['MOBILE_NO']}  ${CUSERNAME5}
    # ${resp}=  Make payment Consumer Mock  590  ${bool[1]}  ${wid}  ${pid}  ${purpose[1]}  ${cidj5}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Make payment Consumer Mock  ${pid}  590  ${purpose[1]}  ${wid}  ${s_id4}  ${bool[0]}   ${bool[1]}  ${cidj5}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    #  ${resp}=  Make payment Consumer Mock  ${pid}  590  ${purpose[1]}  ${wid}  ${s_id4}  ${bool[0]}   ${bool[1]}  ${cidj5}   
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${resp}=  Make payment Consumer Mock  590  ${bool[1]}  ${wid}  ${pid}  ${purpose[1]}  ${cidj5}
    # Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]} 
    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]} 
    sleep  2s
    ${end}=  add_time24  0  0
    ${start}=  add_time24  0  -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${grandTotal}   ${resp.json()[0]['grantTotal']}
    # Set Test Variable  ${jBankTotal}    ${resp.json()[0]['jaldeeBankStatement']['jBankDetails']['jBankTotal']}
    # Set Test Variable  ${gatewayCommission}   ${resp.json()[0]['jaldeeBankStatement']['jBankDetails']['gatewayCommission']}
    # Set Test Variable  ${jaldeeCommission}   ${resp.json()[0]['jaldeeBankStatement']['jBankDetails']['jaldeeCommission']} 
    # Set Test Variable   ${subTotalJaldeeCoupons}  ${resp.json()[0]['subTotalJaldeeCoupons']}
    # ${settleAmt} =  Evaluate  ${jBankTotal}-${gatewayCommission}-${jaldeeCommission} 
    # ${grandTotal} =  Evaluate   ${settleAmt}+${subTotalJaldeeCoupons}

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
    Should Be Equal As Strings  ${resp.json()['enabledCount']}  ${count1}
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  50.0
    
    ${invoice1}=  Reimburse Ivoices  ${invoice_id}  ${dis_note}  ${Reimburse_invoice[0]}  ${privte_note}  ${cupn_for[0]}
    ${invoices}=  Create List  ${invoice1}
    ${resp}=  Reimburse Payment  ${invoices}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Reimburse Reports By Provider  id-eq=${invoice_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Contain  ${resp.json()[0]['listOfJaldeeCoupons']}  ${cupn_codeEE}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  ${grandTotal}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[2]}
    Should Be Equal As Strings  ${resp.json()[0]['subJcTotalPaid']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['totalPaid']}  ${grandTotal} 
    # Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}  ${jBankTotal}
    # Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['gatewayCommission']}  ${gatewayCommission}
    # Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['jaldeeCommission']}  ${jaldeeCommission}
    # Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}   ${settleAmt}
  
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
    #${resp}=  Get BusinessDomainsConf
    #Should Be Equal As Strings  ${resp.status_code}  200
    #Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
   # Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    #Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    #Set Test Variable  ${sd2}  ${resp.json()[0]['subDomains'][1]['subDomain']}
    #Set Test Variable  ${sd3}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    #Set Test Variable  ${sd4}  ${resp.json()[1]['subDomains'][1]['subDomain']}
    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${d1}  ${resp.json()['sector']}
    Set Test Variable  ${sd1}  ${resp.json()['subSector']}
    ProviderLogout

    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  add_date  10
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${account_id}=  get_acc_id  ${PUSERNAME160}
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
    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code05}
       
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME5}    
    ${coupons}=  Create List  ${cupn_code05}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id5}  ${des}  ${bool[0]}  ${coupons}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
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

    ${resp}=  Make payment Consumer  590  ${payment_modes[2]}  ${wid}  ${pid}  ${purpose[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain  ${resp.json()['response']}  <td><input name=\"amount\" value=590.00 /></td>
    Should Contain  ${resp.json()['response']}  <td><input name=\"email\" id=\"email\" value=${CUSEREMAIL5} /></td>
    Should Contain  ${resp.json()['response']}  <td>Phone: </td>\n   <td><input name=\"phone\" value=${CUSERNAME5} ></td>
    ${resp}=  Make payment Consumer Mock  590  ${bool[1]}  ${wid}  ${pid}  ${purpose[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]} 
    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]} 

    sleep  2s
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
    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
      
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code07}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME5}    
    ${coupons}=  Create List  ${cupn_code07}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id6}  ${des}  ${bool[0]}  ${coupons}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
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

    ${resp}=  Make payment Consumer  590  ${payment_modes[2]}  ${wid}  ${pid}  ${purpose[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain  ${resp.json()['response']}  <td><input name=\"amount\" value=590.00 /></td>
    Should Contain  ${resp.json()['response']}  <td><input name=\"email\" id=\"email\" value=${CUSEREMAIL5} /></td>
    Should Contain  ${resp.json()['response']}  <td>Phone: </td>\n   <td><input name=\"phone\" value=${CUSERNAME5} ></td>
    ${resp}=  Make payment Consumer Mock  590  ${bool[1]}  ${wid}  ${pid}  ${purpose[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   2s
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]} 

    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]} 

    sleep  2s
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
    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    sleep  2s
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
    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code08}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME5}    
    ${coupons}=  Create List  ${cupn_code08}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id7}  ${des}  ${bool[0]}  ${coupons}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
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

    ${resp}=  Make payment Consumer  640  ${payment_modes[2]}  ${wid}  ${pid}  ${purpose[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain  ${resp.json()['response']}  <td><input name=\"amount\" value=640.00 /></td>
    Should Contain  ${resp.json()['response']}  <td><input name=\"email\" id=\"email\" value=${CUSEREMAIL5} /></td>
    Should Contain  ${resp.json()['response']}  <td>Phone: </td>\n   <td><input name=\"phone\" value=${CUSERNAME5} ></td>
    ${resp}=  Make payment Consumer Mock  640  ${bool[1]}  ${wid}  ${pid}  ${purpose[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   2s
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]} 

    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]} 
    sleep  2s
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
    #${resp}=  Get BusinessDomainsConf
    #Should Be Equal As Strings  ${resp.status_code}  200
    #Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    #Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    #Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    #Set Test Variable  ${sd2}  ${resp.json()[0]['subDomains'][1]['subDomain']}
    #Set Test Variable  ${sd3}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    #Set Test Variable  ${sd4}  ${resp.json()[1]['subDomains'][1]['subDomain']}

    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${d1}  ${resp.json()['sector']}
    Set Test Variable  ${sd1}  ${resp.json()['subSector']}
    ProviderLogout

    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  add_date  10
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code09}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code09}
    clear_jaldeecoupon   ${cupn_code09}
    ${resp}=  Create Jaldee Coupon For Providers  ${cupn_code09}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[1]}  10  100  ${bool[1]}  ${bool[1]}  100  100  5  5  5  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${account_id}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code09}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code09}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME3}    
    ${coupons}=  Create List  ${cupn_code09}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id6}  ${des}  ${bool[0]}  ${coupons}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.json()}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code09}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 
  
    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id7}  ${des}  ${bool[0]}  ${coupons}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=   ProviderLogin  ${PUSERNAME160}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code09}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  100.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  2
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 
    ${resp}=  Accept Payment  ${wid}  ${acceptPaymentBy[0]}  590  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Settl Bill  ${wid}
    
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]} 
    sleep  02s
    ${end}=  add_time24  0  0
    ${start}=  add_time24  0  -5    
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  5s
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_code09}
    Log   ${resp.json()}
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
    ${cupn_code12}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code12}  
    clear_jaldeecoupon   ${cupn_code12}
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code12}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED_IN_SA}"

JD-TC-GetJaldeeCouponStatsBySuperadmin -UH8
    [Documentation]   Consumer disable a Jaldee Coupon
    ${resp}=   Consumer Login  ${CUSERNAME5}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code12}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings   ${resp.json()}   "logged in user has no access permission to this url"

JD-TC-GetJaldeeCouponStatsBySuperadmin -UH9
    [Documentation]   Another Provider disable a Jaldee Coupon
    ${resp}=   ProviderLogin  ${PUSERNAME3}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code12}
    
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "Invalid coupon code" 
    

































