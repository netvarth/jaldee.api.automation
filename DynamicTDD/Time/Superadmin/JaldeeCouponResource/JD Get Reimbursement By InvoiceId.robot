*** Settings ***
Suite Teardown    Delete All Sessions
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
#Suite Setup     Run Keywords  clear_queue  ${PUSERNAME1}  AND  clear_waitlist  ${PUSERNAME1}  AND  clear_service  ${PUSERNAME1}  AND  clear_location  ${PUSERNAME1}    AND  clear_jaldeecoupon  Coupon01_01  AND  clear_jaldeecoupon  Coupon02  AND  clear_jaldeecoupon  Coupon03  AND  clear_jaldeecoupon  Coupon04  AND  clear_jaldeecoupon  Coupon05  AND  clear_jaldeecoupon  Coupon06  AND  clear_jaldeecoupon  Coupon07  AND  clear_jaldeecoupon  Coupon08  AND  clear_jaldeecoupon  Coupon09  AND  clear_jaldeecoupon  Coupon10  AND  clear_jaldeecoupon  Coupon11  AND  clear_jaldeecoupon  Coupon12  AND  clear_jaldeecoupon  Coupon13  AND  clear_jaldeecoupon  Coupon14  AND  clear_jaldeecoupon  Coupon15  AND  clear_jaldeecoupon  Coupon16   AND  clear_tax_gstNum  13DEFBV1100M2Z6

*** Variables ***

${SERVICE1}  Note Book1105
${SERVICE2}  boots105
${SERVICE3}  pen105
${SERVICE4}  ABCD105
${queue1}  morning
${LsTime}   08:00 AM
${LeTime}   09:00 AM

${sTime}    09:00 PM
${eTime}    11:00 PM
${longi}        89.524764
${latti}        86.524764
*** Test Cases ***

JD-TC-Get reimbursement byInvoiceId-1
    clear_reimburseReport
    clear_payment_invoice  ${PUSERNAME1}
    [Documentation]  Get reimbursement report    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200 
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
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code2020}=   FakerLibrary.word
    Set Suite Variable    ${cupn_code2020}
    ${cupn_name}=   FakerLibrary.name
    Set Suite Variable    ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable    ${cupn_des}
    ${c_des}=    FakerLibrary.sentence
    Set Suite Variable   ${c_des}
    ${p_des}=    FakerLibrary.sentence
    Set Suite Variable   ${p_des}
    clear_jaldeecoupon     ${cupn_code2020}
    ${resp}=  Create Jaldee Coupon  ${cupn_code2020}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  10  10  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2020}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_Coupon01_01}=   FakerLibrary.word
    Set Suite Variable    ${cupn_Coupon01_01}
    clear_jaldeecoupon     ${cupn_Coupon01_01}
    ${resp}=  Create Jaldee Coupon  ${cupn_Coupon01_01}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  10  10  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_Coupon01_01}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}
    Log    ${resp.json()}
    
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERNAME1}
    ${cid}=  get_id  ${CUSERNAME5}
    Set Suite Variable  ${cid}
    clear_location  ${PUSERNAME1}
    clear_service   ${PUSERNAME1}
    clear_queue     ${PUSERNAME1}
    ${resp}=  Create Sample Queue
    Set Suite Variable  ${qid1}   ${resp['queue_id']}
    Set Suite Variable  ${s_id2}   ${resp['service_id']}
    Set Suite Variable  ${lid}   ${resp['location_id']}
    Set Suite Variable  ${s_name}   ${resp['service_name']}
    ${waitlist_des}=    FakerLibrary.sentence
    Set Suite Variable    ${waitlist_des}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id2}  ${qid1}  ${DAY1}  ${waitlist_des}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}  
    Sleep  2s
    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}   ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${s_name}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  500.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  500.0

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2020}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}   ${couponState[0]}
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code2020}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2020}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_Coupon01_01}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}   ${couponState[0]}
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_Coupon01_01}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_Coupon01_01}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code2020}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2020}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2020}']['systemNote']}  NO_OTHER_COUPONS_ALLOWED
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2020}']['systemNote']}  COUPON_APPLIED
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${s_name}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  450.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  450.0
    ${resp}=  Accept Payment  ${wid}  ${acceptPaymentBy[0]}  450  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Payment By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${acceptPaymentBy[0]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  450.0

    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]} 

    sleep  2s

    ${end}=  db.add_tz_time24  ${tz}   0  0
    ${start}=  db.add_tz_time24  ${tz}   0  -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${invoice_id}  ${resp.json()[0]['invoiceId']}
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  50.0

    ${resp}=  Request For Payment of Jaldeecoupon  ${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Reimburse Reports By Provider  id-eq=${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[1]}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log    ${resp.json()}
    Set Suite Variable   ${uname}     ${resp.json()['userName']}
    Should Be Equal As Strings  ${resp.status_code}  200      
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_code2020}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  0.0 
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  50.0

    ${dis_note}=    FakerLibrary.sentence
    Set Suite Variable    ${dis_note}
    ${privte_note}=    FakerLibrary.sentence
    Set Suite Variable    ${privte_note}

    ${invoice1}=  Reimburse Ivoices  ${invoice_id}  ${dis_note}  ${Reimburse_invoice[1]}  ${privte_note}  ${cupn_for[1]}
    ${invoices}=  Create List  ${invoice1}
    ${resp}=  Reimburse Payment  ${invoices}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimbursement By InvoiceId  ${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['invoice']['invoiceId']}  ${invoice_id}
    Should Be Equal As Strings  ${resp.json()[0]['paidDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['displayNote']}  ${dis_note}
    Should Be Equal As Strings  ${resp.json()[0]['privateNote']}  ${privte_note}
    Should Be Equal As Strings  ${resp.json()[0]['jcTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['jaldeePaymentmode']}  ${jaldeePaymentmode[1]}
    Should Be Equal As Strings  ${resp.json()[0]['grandTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['paidBy']['id']}  2
    Should Be Equal As Strings  ${resp.json()[0]['paidBy']['userName']}  ${uname}

JD-TC-Get reimbursement byInvoiceId-2
    
    [Documentation]     Reimburse payment of same jaldee coupon and same provider and Get reimbursement report 
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERNAME1}
    ${cid}=  get_id  ${CUSERNAME1}
    ${des}=   FakerLibrary.sentence
    Set Suite Variable   ${des}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id2}  ${qid1}  ${DAY1}  ${des}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}   
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${s_name}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  500.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  500.0

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code2020}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2020}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2020}']['systemNote']}  NO_OTHER_COUPONS_ALLOWED
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2020}']['systemNote']}  COUPON_APPLIED
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${s_name}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  450.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  450.0
    ${resp}=  Accept Payment  ${wid}  ${acceptPaymentBy[0]}  450  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Payment By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${acceptPaymentBy[0]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  450.0

    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]} 
    sleep  04s
    ${end}=  db.add_tz_time24  ${tz}   0  0
    ${start}=  db.add_tz_time24  ${tz}   0  -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}  
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  05s
    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${invoice_id}  ${resp.json()[0]['invoiceId']} 
    
    ${resp}=  Request For Payment of Jaldeecoupon  ${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Reimburse Reports By Provider  id-eq=${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[1]}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_code2020}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  100.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  2
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  50.0 
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  50.0

    ${dis_note}=    FakerLibrary.sentence
    Set Suite Variable    ${dis_note}
    ${privte_note}=    FakerLibrary.sentence
    Set Suite Variable    ${privte_note}

    ${invoice1}=  Reimburse Ivoices  ${invoice_id}  ${dis_note}  ${Reimburse_invoice[0]}  ${privte_note}  ${cupn_for[1]}
    ${invoices}=  Create List  ${invoice1}
    ${resp}=  Reimburse Payment  ${invoices}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimbursement By InvoiceId  ${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['invoice']['invoiceId']}  ${invoice_id}
    Should Be Equal As Strings  ${resp.json()[0]['paidDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['displayNote']}  ${dis_note}
    Should Be Equal As Strings  ${resp.json()[0]['privateNote']}  ${privte_note}
    Should Be Equal As Strings  ${resp.json()[0]['jcTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['jaldeePaymentmode']}  ${jaldeePaymentmode[0]}
    Should Be Equal As Strings  ${resp.json()[0]['grandTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['paidBy']['id']}  2
    Should Be Equal As Strings  ${resp.json()[0]['paidBy']['userName']}  ${uname}


JD-TC-Get reimbursement byInvoiceId-3
    [Documentation]  SA do reimuburse payment of 2 jaldeee coupon and same provider

    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${cid}=  get_id  ${CUSERNAME1}
    clear_waitlist    ${CUSERNAME1}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id2}  ${qid1}  ${DAY1}  ${des}  ${bool[1]}  ${cid}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}   
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${s_name}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  500.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  500.0

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code2020}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2020}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2020}']['systemNote']}  NO_OTHER_COUPONS_ALLOWED
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2020}']['systemNote']}  COUPON_APPLIED
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${s_name}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  450.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  450.0
    ${resp}=  Accept Payment  ${wid}  ${acceptPaymentBy[0]}  450  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Payment By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${acceptPaymentBy[0]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  450.0

    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]} 

    ${resp}=  Create Sample Queue
    Set Suite Variable  ${qid1}   ${resp['queue_id']}
    Set Suite Variable  ${s_id1}   ${resp['service_id']}
    Set Suite Variable  ${s_name}   ${resp['service_name']}
    Set Suite Variable  ${lid}   ${resp['location_id']}

    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY1}  ${des}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}   
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${s_name}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  500.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  500.0

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_Coupon01_01}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_Coupon01_01}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_Coupon01_01}']['systemNote']}  NO_OTHER_COUPONS_ALLOWED
    Should Contain  ${resp.json()['jCoupon']['${cupn_Coupon01_01}']['systemNote']}  COUPON_APPLIED
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${s_name}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  450.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  450.0
    ${resp}=  Accept Payment  ${wid}  ${acceptPaymentBy[0]}  450  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Payment By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${acceptPaymentBy[0]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  450.0

    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]} 

    sleep  02s
    ${end}=  db.add_tz_time24  ${tz}   0  0
    ${start}=  db.add_tz_time24  ${tz}   0  -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${invoice_id}  ${resp.json()[0]['invoiceId']} 

    ${resp}=  Request For Payment of Jaldeecoupon  ${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[1]}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_code2020}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  150.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  3
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  100.0 
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  50.0

    ${resp}=  Get Jaldee Coupons Stats  ${cupn_Coupon01_01}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  0.0 
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  50.0

    ${pid}=  get_acc_id  ${PUSERNAME1}
    ${invoice1}=  Reimburse Ivoices  ${invoice_id}  ${dis_note}  ${Reimburse_invoice[0]}  ${privte_note}  ${cupn_for[1]}
    ${invoices}=  Create List  ${invoice1}
    ${resp}=  Reimburse Payment  ${invoices}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimbursement By InvoiceId  ${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['invoice']['invoiceId']}  ${invoice_id}
    Should Be Equal As Strings  ${resp.json()[0]['paidDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['displayNote']}  ${dis_note}
    Should Be Equal As Strings  ${resp.json()[0]['privateNote']}  ${privte_note}
    Should Be Equal As Strings  ${resp.json()[0]['jcTotal']}  100.0
    Should Be Equal As Strings  ${resp.json()[0]['jaldeePaymentmode']}  ${jaldeePaymentmode[0]}
    Should Be Equal As Strings  ${resp.json()[0]['grandTotal']}  100.0
    Should Be Equal As Strings  ${resp.json()[0]['paidBy']['id']}  2
    Should Be Equal As Strings  ${resp.json()[0]['paidBy']['userName']}  ${uname}
