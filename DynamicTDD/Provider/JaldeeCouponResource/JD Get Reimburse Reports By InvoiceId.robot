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
#Suite Setup     Run Keywords  clear_jaldeecoupon  cupn_code2018  AND  clear_queue  ${PUSERNAME7}  AND  clear_waitlist  ${PUSERNAME7}  AND  clear_payment_invoice  ${PUSERNAME7}  AND  clear_service  ${PUSERNAME7}  AND  clear_location  ${PUSERNAME7}    AND  clear_jaldeecoupon  OnamCoupon2018  AND  clear_jaldeecoupon  Coupon01  AND  clear_jaldeecoupon  Coupon02  AND  clear_jaldeecoupon  Coupon03  AND  clear_jaldeecoupon  Coupon04  AND  clear_jaldeecoupon  Coupon05  AND  clear_jaldeecoupon  Coupon06  AND  clear_jaldeecoupon  Coupon07  AND  clear_jaldeecoupon  Coupon08  AND  clear_jaldeecoupon  Coupon09  AND  clear_jaldeecoupon  Coupon10  AND  clear_jaldeecoupon  Coupon11  AND  clear_jaldeecoupon  Coupon12  AND  clear_jaldeecoupon  Coupon13  AND  clear_jaldeecoupon  Coupon14  AND  clear_jaldeecoupon  Coupon15  AND  clear_jaldeecoupon  Coupon16

*** Variables ***

${SERVICE1}  Note Book1104
${SERVICE2}  boots104
${SERVICE3}  pen104
${SERVICE4}  ABCD104
${queue1}  morning
${LsTime}   08:00 AM
${LeTime}   09:00 AM

${sTime}    09:00 PM
${eTime}    11:00 PM
${longi}        89.524764
${latti}        86.524764
${self}   0
*** Test Cases ***

JD-TC-GetReimburseReportByInvoiceId-1
    #clear_reimburseReport
    [Documentation]  Provider apply a coupon after waitlist ,done payment and settil bill,create report then get reprt by invoice_id     
    clear_queue  ${PUSERNAME1}  
    #clear_payment_invoice  ${PUSERNAME1}
    clear_waitlist  ${PUSERNAME1}    
    #clear_payment_invoice  ${PUSERNAME1}    
    clear_service  ${PUSERNAME1}    
    clear_location  ${PUSERNAME1}
    clear_customer   ${PUSERNAME1}     
    
    #clear_jaldeecoupon  Coupon01    
    #clear_jaldeecoupon  Coupon02
    #clear_jaldeecoupon  Coupon03
    #clear_jaldeecoupon  Coupon04
    #clear_jaldeecoupon  Coupon05         
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Log   ${resp.json()}
    Set Suite Variable   ${domain}    ${resp.json()['sector']}
    Set Suite Variable   ${subDomain}    ${resp.json()['subSector']}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]} 

    
    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${d1}    ${resp.json()['serviceSector']['domain']}  
    Set Suite Variable    ${sd1}   ${resp.json()['serviceSubSector']['subDomain']}   

    ${domains}=  Jaldee Coupon Target Domains   ${d1}    
    ${sub_domains}=  Jaldee Coupon Target SubDomains   ${d1}_${sd1}  
    
    
    ProviderLogout
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code2018}=   FakerLibrary.word
    Set Suite Variable    ${cupn_code2018}
    ${cupn_name}=    FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable     ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable     ${c_des}
    ${p_des}=    FakerLibrary.sentence
    Set Suite Variable     ${p_des}
    clear_jaldeecoupon   ${cupn_code2018}
    Log  ${cupn_code2018} 
    ${resp}=   Create Jaldee Coupon   ${cupn_code2018}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  10  10  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}   ${domains}   ${sub_domains}   ALL  ${licenses}
    LOg   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon   ${cupn_code2018}   ${cupn_des}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}
    Log    ${resp.json()}

    
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable  ${pid}
    # ${cid}=  get_id  ${CUSERNAME1}
    # Set Suite Variable  ${cid}

    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${description}=  FakerLibrary.sentence
    Set Suite Variable   ${description}
    ${address}=  get_address
    
    ${list}=  Create List   1  2  3  4  5  6  7
    ${resp}=  Create Location  ABCDE  ${longi}  ${latti}  www.${companySuffix}.com  ${postcode}  ${address}  free  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${LsTime}  ${LeTime}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${lid}  ${resp.json()} 

    ${resp}=  Create Service  ${SERVICE1}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  50  500  ${bool[1]}  ${bool[1]}
    Set Suite Variable  ${s_id1}  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Create Service  ${SERVICE2}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[1]}
    Set Suite Variable  ${s_id2}  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Create Service  ${SERVICE3}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[0]}
    Set Suite Variable  ${s_id3}  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    

    ${resp}=  Create Service  ${SERVICE4}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[1]}
    Set Suite Variable  ${s_id4}  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    
    
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}  ${s_id1}  ${s_id2}  ${s_id3}  ${s_id4}
    Set Suite Variable  ${qid1}  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id2}  ${qid1}  ${DAY1}  ${description}  ${bool[1]}  ${cid}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]} 
    
    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  590.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  590.0
    ${resp}=  Get Jaldee Coupons By Coupon_code   ${cupn_code2018}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[0]}
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code2018}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2018}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2018}']['systemNote']}  ${SystemNote[1]}
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2018}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  540.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  540.0
    ${resp}=  Accept Payment  ${wid}  ${acceptPaymentBy[0]}  540.0  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Payment By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${acceptPaymentBy[0]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  540.0

    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]}
    
    ${end}=  db.add_tz_time24  ${tz}   0  0
    ${start}=  db.add_tz_time24  ${tz}   0  -5
    
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}  
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  1s

    ${resp}=  Get Reimburse Reports By Provider
    Log    ${resp.json()}    
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_id}  ${resp.json()[0]['invoiceId']}
    

    ${resp}=  Get Reimburse Reports By Provider By InvoiceId  ${invoice_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['invoiceId']}  ${invoice_id}
    Should Be Equal As Strings  ${resp.json()['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subTotalJaldeeBank']}  0.0
    Should Contain  ${resp.json()['listOfJaldeeCoupons']}  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.json()['subTotalJaldeeCoupons']}  50.0
    Should Be Equal As Strings  ${resp.json()['grantTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()['status']}  ${cupnpaymentStatus[3]}
    Should Be Equal As Strings  ${resp.json()['subJcTotalPaid']}  0.0
    Should Be Equal As Strings  ${resp.json()['subJbankTotalPaid']}  0.0
    Should Be Equal As Strings  ${resp.json()['totalPaid']}  0.0  

    ${resp}=  Request For Payment of Jaldeecoupon  ${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports By Provider By InvoiceId  ${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']}  ${cupnpaymentStatus[1]}

    


JD-TC-GetReimburseReportByInvoiceId-UH1
    [Documentation]  Provider get reimburse report of  invalid  invoice_id
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200  
    ${resp}=  Get Reimburse Reports By Provider By InvoiceId  0
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_INVOICE_NOT_EXISTS}"

JD-TC-GetReimburseReportByInvoiceId -UH2
    [Documentation]   Get reimburse report by without login  
    ${resp}=  Get Reimburse Reports By Provider By InvoiceId  ${invoice_id}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-GetReimburseReportByInvoiceId -UH3
    [Documentation]   Consumer get reimburse report
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Reimburse Reports By Provider By InvoiceId  ${invoice_id}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-GetReimburseReportByInvoiceId -UH4
    [Documentation]   Another Provider request reimburse payment
    ${resp}=   Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Reimburse Reports By Provider By InvoiceId  ${invoice_id}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"   "${JALDEE_INVOICE_NOT_EXISTS}"
    
*** comment***
JD-TC-Verify GetReimburseReportByInvoiceId-1
    [Documentation]  Provider apply a coupon after waitlist ,done payment and settil bill,create report then get reprt by invoice_id
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    
    ${end}=  db.add_tz_time24  ${tz}   0  0
    ${start}=  db.add_tz_time24  ${tz}   0  -5
    
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}  
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    

    ${resp}=  Get Reimburse Reports By Provider
    Log    ${resp.json()}    
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_id}  ${resp.json()[0]['invoiceId']}
    

    ${resp}=  Get Reimburse Reports By Provider By InvoiceId  ${invoice_id}

    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['invoiceId']}  ${invoice_id}
    Should Be Equal As Strings  ${resp.json()['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subTotalJaldeeBank']}  0.0
    Should Contain  ${resp.json()['listOfJaldeeCoupons']}  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.json()['subTotalJaldeeCoupons']}  50.0
    Should Be Equal As Strings  ${resp.json()['grantTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()['status']}  ${cupnpaymentStatus[3]}
    Should Be Equal As Strings  ${resp.json()['subJcTotalPaid']}  0.0
    Should Be Equal As Strings  ${resp.json()['subJbankTotalPaid']}  0.0
    Should Be Equal As Strings  ${resp.json()['totalPaid']}  0.0  

    ${resp}=  Request For Payment of Jaldeecoupon  ${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports By Provider By InvoiceId  ${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']}  ${cupnpaymentStatus[1]}

JD-TC-Verify GetReimburseReportByInvoiceId-2
    [Documentation]  Provider agian apply a same coupon then create report and report by InvoiceId
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    
    ${end}=  db.add_tz_time24  ${tz}   0  0
    ${start}=  db.add_tz_time24  ${tz}   0  -5

    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${invoice_id}  ${resp.json()[0]['invoiceId']} 

    ${resp}=  Get Reimburse Reports By Provider By InvoiceId  ${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['invoiceId']}  ${invoice_id}
    Should Be Equal As Strings  ${resp.json()['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['subTotalJaldeeBank']}  0.0
    Should Contain  ${resp.json()['listOfJaldeeCoupons']}  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.json()['subTotalJaldeeCoupons']}  50.0
    Should Be Equal As Strings  ${resp.json()['grantTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()['status']}  ${cupnpaymentStatus[3]}
    Should Be Equal As Strings  ${resp.json()['subJcTotalPaid']}  0.0
    Should Be Equal As Strings  ${resp.json()['subJbankTotalPaid']}  0.0
    Should Be Equal As Strings  ${resp.json()['totalPaid']}  0.0  

    ${resp}=  Request For Payment of Jaldeecoupon  ${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Reimburse Reports By Provider By InvoiceId  ${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']}  ${cupnpaymentStatus[1]}