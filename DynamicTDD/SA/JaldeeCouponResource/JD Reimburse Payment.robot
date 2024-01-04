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
#Suite Setup     Run Keywords  clear_jaldeecoupon  OnamCoupon2020  AND  clear_queue  ${PUSERNAME7}  AND  clear_payment_invoice  ${PUSERNAME7}  AND  clear_service  ${PUSERNAME7}  AND  clear_location  ${PUSERNAME7}    AND  clear_jaldeecoupon  OnamCoupon2018  AND  clear_jaldeecoupon  Coupon01_01  AND  clear_jaldeecoupon  Coupon02  AND  clear_jaldeecoupon  Coupon03  AND  clear_jaldeecoupon  Coupon04  AND  clear_jaldeecoupon  Coupon05  AND  clear_jaldeecoupon  Coupon06  AND  clear_jaldeecoupon  Coupon07  AND  clear_jaldeecoupon  Coupon08  AND  clear_jaldeecoupon  Coupon09  AND  clear_jaldeecoupon  Coupon10  AND  clear_jaldeecoupon  Coupon11  AND  clear_jaldeecoupon  Coupon12  AND  clear_jaldeecoupon  Coupon13  AND  clear_jaldeecoupon  Coupon14  AND  clear_jaldeecoupon  Coupon15  AND  clear_jaldeecoupon  Coupon16  AND  clear_tax_gstNum  13DEFBV1100M2Z6

*** Variables ***
${sTime}    09:00 PM
${eTime}    11:00 PM
${SERVICE2}  boots106
${LsTime}   08:00 AM
${LeTime}   09:00 AM
${queue1}  morning
${self}   0

*** Test Cases ***

JD-TC-Reimburse payment-1
    
    [Documentation]  Provider apply a coupon after waitlist ,done payment, settil bill,Request for payment then done reimburse payment through CHEQUE(full amount paid)    
   
    ${billable_domains}=  get_billable_domain
    Set Test Variable  ${domains}  ${billable_domains[0]}
    Set Test Variable  ${sub_domains}   ${billable_domains[1]}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+45125
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
    ${licid}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domains[1]}  ${sub_domains[1]}  ${PUSERPH0}  ${licid[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${domain}  ${decrypted_data['sector']} 
    Set Test Variable  ${subDomain}  ${decrypted_data['subSector']} 
    # Set Suite Variable   ${domain}    ${resp.json()['sector']}
    # Set Suite Variable   ${subDomain}    ${resp.json()['subSector']}
    Set Suite Variable  ${PUSERPH0}

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # Set Suite Variable  ${DAY1}  ${DAY1}
    # ${list}=  Create List  1  2  3  4  5  6  7
    # Set Suite Variable  ${list}  ${list}
    # @{Views}=  Create List  self  all  customersOnly
    # ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
    # ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
    # ${views}=  Evaluate  random.choice($Views)  random
    # ${name1}=  FakerLibrary.name
    # ${name2}=  FakerLibrary.name
    # ${name3}=  FakerLibrary.name
    # ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    # ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    # ${emails1}=  Emails  ${name3}  Email  ${P_Email}101.${test_mail}  ${views}
    # ${bs}=  FakerLibrary.bs
    # ${city}=   get_place
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${companySuffix}=  FakerLibrary.companySuffix
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    # ${parking}   Random Element   ${parkingType}
    # ${24hours}    Random Element    ['True','False']
    # ${desc}=   FakerLibrary.sentence
    # ${url}=   FakerLibrary.url
    # ${sTime}=  add_timezone_time  ${tz}  0  15  
    # Set Suite Variable   ${sTime}
    # ${eTime}=  add_timezone_time  ${tz}  0  45  
    # Set Suite Variable   ${eTime}
    # ${resp}=  Create Business Profile  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200  
    # ${resp}=   Get Active License
    # Should Be Equal As Strings    ${resp.status_code}   200
    # Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    # ${resp}=   ProviderLogout
    # Should Be Equal As Strings    ${resp.status_code}    200


    
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    @{Views}=  Create List  self  all  customersOnly
    ${ph1}=  Evaluate  ${PUSERPH0}+8000000000
    ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}101.${test_mail}  ${views}
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
    ${24hours}    Random Element    ['True','False']
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    Set Suite Variable   ${eTime}

    ${resp}=  Update Business Profile with Schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200 

    # ${resp}=   Get Active License
    # Should Be Equal As Strings    ${resp.status_code}   200
    # Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    # ${resp}=   ProviderLogout
    # Should Be Equal As Strings    ${resp.status_code}    200


    ${domains}=  Jaldee Coupon Target Domains  ${domain}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${domain}_${subDomain}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code2020}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code2020}
    ${cupn_name}=   FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable   ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable   ${c_des}
     ${p_des}=   FakerLibrary.sentence
    Set Suite Variable   ${p_des}

    clear_jaldeecoupon  ${cupn_code2020}
    ${resp}=  Create Jaldee Coupon  ${cupn_code2020}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  10  10  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2020}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code01_01}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code01_01}

    clear_jaldeecoupon  ${cupn_code01_01}
    ${resp}=  Create Jaldee Coupon  ${cupn_code01_01}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  10  10  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code01_01}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}
    Log    ${resp.json()}
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERPH0}
    
    ${resp}=  AddCustomer  ${CUSERNAME24}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME24}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
    # ${cid}=  get_id  ${CUSERNAME24}
    # Set Suite Variable  ${cid}
    
    clear_location  ${PUSERPH0}
    clear_service   ${PUSERPH0}
    clear_queue     ${PUSERPH0}

    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${description}=  FakerLibrary.sentence
    ${address}=  get_address

    ${list}=  Create List   1  2  3  4  5  6  7
    ${resp}=  Create Location  ABCDE  ${longi}  ${latti}  www.${companySuffix}.com  ${postcode}  ${address}  free  ${bool[1]}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${LsTime}  ${LeTime}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${lid}  ${resp.json()} 

    
    ${resp}=  Create Service  ${SERVICE2}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}
    
    
    ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}    ${s_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}

    ${waitlist_des}=    FakerLibrary.sentence
    Set Suite Variable    ${waitlist_des}


    ${resp}=  Add To Waitlist  ${cid}  ${s_id2}  ${qid1}  ${DAY1}  ${waitlist_des}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}   
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}   ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  590.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  590.0

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2020}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[0]}
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code2020}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2020}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${Qstate[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code01_01}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[0]}
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code01_01}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code01_01}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${Qstate[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code2020}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2020}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2020}']['systemNote']}  ${SystemNote[1]}
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2020}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  540.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  540.0
    ${resp}=  Accept Payment  ${wid}  ${acceptPaymentBy[0]}  540  
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

    # ${end}=  db.add_tz_time_sec  ${tz}   0  0  0
    # ${start}=  db.add_tz_time_sec  ${tz}   0  -5  0
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
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
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_code2020}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  0.0 
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  50.0

    ${des_note}=    FakerLibrary.sentence
    Set Suite Variable   ${des_note}
    ${private_note}=    FakerLibrary.sentence
    Set Suite Variable   ${private_note}

    ${invoice1}=  Reimburse Ivoices  ${invoice_id}  ${des_note}  ${Reimburse_invoice[1]}  ${private_note}  ${cupn_for[1]}
    ${invoices}=  Create List  ${invoice1}
    ${resp}=  Reimburse Payment  ${invoices}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports By Provider  id-eq=${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}  0.0
    Should Contain  ${resp.json()[0]['listOfJaldeeCoupons']}  ${cupn_code2020}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[2]}
    Should Be Equal As Strings  ${resp.json()[0]['subJcTotalPaid']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['subJbankTotalPaid']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['totalPaid']}  50.0

    ${resp}=  Get Jaldee Coupons Stats  ${cupn_code2020}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  50.0 
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  0.0


JD-TC-Reimburse payment-2
    [Documentation]    Reimburse payment of same jaldee coupon and same provider
    

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_location  ${PUSERPH0}
    clear_service   ${PUSERPH0}
    clear_queue     ${PUSERPH0}
    clear_invoice   ${PUSERPH0}
    clear_payment_invoice   ${PUSERPH0}


    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${description}=  FakerLibrary.sentence
    ${address}=  get_address

    ${list}=  Create List   1  2  3  4  5  6  7
    ${resp}=  Create Location  ABCDE  ${longi}  ${latti}  www.${companySuffix}.com  ${postcode}  ${address}  free  ${bool[1]}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${LsTime}  ${LeTime}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${lid}  ${resp.json()} 

    
    ${resp}=  Create Service  ${SERVICE2}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}
    
    
    ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}    ${s_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    
    ${pid}=  get_acc_id  ${PUSERPH0}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}

    #${cid}=  get_id  ${CUSERNAME1}
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
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  590.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  590.0

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code2020}  ${wid} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2020}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2020}']['systemNote']}  ${SystemNote[1]}
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2020}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  540.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  540.0
    ${resp}=  Accept Payment  ${wid}  ${acceptPaymentBy[0]}  540  
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
    # ${end}=  db.add_tz_time_sec  ${tz}   0  0  0
    # ${start}=  db.add_tz_time_sec  ${tz}   0  -5  0
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    
    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${invoice_id}  ${resp.json()[0]['invoiceId']}
    
    ${resp}=  Request For Payment of Jaldeecoupon  ${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Reimburse Reports By Provider  id-eq=${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[1]}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_code2020}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  0.0 
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  50.0

    ${invoice1}=  Reimburse Ivoices  ${invoice_id}  ${des_note}  ${Reimburse_invoice[0]}  ${private_note}  ${cupn_for[1]}
    ${invoices}=  Create List  ${invoice1}
    ${resp}=  Reimburse Payment  ${invoices}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Reimburse Reports By Provider  id-eq=${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['listOfJaldeeCoupons']}  {"${cupn_code2020}":50.0}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[2]}
    Should Be Equal As Strings  ${resp.json()[0]['subJcTotalPaid']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['subJbankTotalPaid']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['totalPaid']}  50.0

    ${resp}=  Get Jaldee Coupons Stats  ${cupn_code2020}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  50.0 
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  0.0

JD-TC-Reimburse payment-UH1
    [Documentation]  SA do payment for already fully paid inoice id
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${invoice1}=  Reimburse Ivoices  ${invoice_id}  ${des_note}  ${Reimburse_invoice[0]}  ${private_note}  ${cupn_for[1]}
    ${invoices}=  Create List  ${invoice1}
    ${resp}=  Reimburse Payment  ${invoices}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_REIMBURSE_JC_ALREADY_PAID}"

JD-TC-Reimburse payment-UH2
    [Documentation]  SA reimburse payment     
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_location  ${PUSERPH0}
    clear_service   ${PUSERPH0}
    clear_queue     ${PUSERPH0}
    clear_invoice   ${PUSERPH0}
    clear_payment_invoice   ${PUSERPH0}
    

    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${description}=  FakerLibrary.sentence
    ${address}=  get_address

    ${list}=  Create List   1  2  3  4  5  6  7
    ${resp}=  Create Location  ABCDE  ${longi}  ${latti}  www.${companySuffix}.com  ${postcode}  ${address}  free  ${bool[1]}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${LsTime}  ${LeTime}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${lid}  ${resp.json()} 

    
    ${resp}=  Create Service  ${SERVICE2}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}
    
    
    ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}    ${s_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    
    # ${resp}=  AddCustomer  ${CUSERNAME1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}

    ${resp}=  Add To Waitlist  ${cid}  ${s_id2}  ${qid1}  ${DAY1}  ${des}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}   
    ${resp}=  Get Bill By UUId  ${wid}
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

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code01_01}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code01_01}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code01_01}']['systemNote']}  ${SystemNote[1]}
    Should Contain  ${resp.json()['jCoupon']['${cupn_code01_01}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  540.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  540.0
    ${resp}=  Accept Payment  ${wid}  ${acceptPaymentBy[0]}  540  
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

    # ${end}=  db.add_tz_time_sec  ${tz}   0  0  0
    # ${start}=  db.add_tz_time_sec  ${tz}   0  -5  0
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s

    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${invoice_id}  ${resp.json()[0]['invoiceId']} 

    ${resp}=  Request For Payment of Jaldeecoupon  ${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[1]}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_code01_01}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  0.0 
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  50.0
    ${des_note}=   FakerLibrary.sentence
    ${private_note}=   FakerLibrary.sentence
                                     
    ${invoice1}=  Reimburse Ivoices  ${invoice_id}  ${des_note}  ${Reimburse_invoice[0]}  ${private_note}  ${cupn_for[0]}
    ${invoices}=  Create List  ${invoice1}
    ${resp}=  Reimburse Payment  ${invoices}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Reimburse Reports By Provider  id-eq=${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['listOfJaldeeCoupons']}  {"${cupn_code01_01}":50.0}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[2]}
    Should Be Equal As Strings  ${resp.json()[0]['subJcTotalPaid']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['subJbankTotalPaid']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['totalPaid']}  50.0

JD-TC-Reimburse payment-4
    [Documentation]  Check an alert is gone after payment of reimburse done    
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERPH0}

    ${resp}=  AddCustomer  ${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME11}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
    #${cid}=  get_id  ${CUSERNAME11}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id2}  ${qid1}  ${DAY1}  ${des}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}   
    ${resp}=  Get Bill By UUId  ${wid}
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

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code01_01}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code01_01}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code01_01}']['systemNote']}  ${SystemNote[1]}
    Should Contain  ${resp.json()['jCoupon']['${cupn_code01_01}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  540.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  540.0
    ${resp}=  Accept Payment  ${wid}  ${acceptPaymentBy[0]}  540  
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
    # ${end}=  db.add_tz_time_sec  ${tz}   0  0  0
    # ${start}=  db.add_tz_time_sec  ${tz}   0  -5  0
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${invoice_id}  ${resp.json()[0]['invoiceId']}

    ${resp}=  Request For Payment of Jaldeecoupon  ${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[1]}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_code01_01}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  100.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  2
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  50.0 
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  50.0
    ${des_note}=    FakerLibrary.sentence
    ${private_note}=   FakerLibrary.sentence
                                     
    ${invoice1}=  Reimburse Ivoices  ${invoice_id}  ${des_note}  ${Reimburse_invoice[0]}  ${private_note}   ${cupn_for[1]}
    ${invoices}=  Create List  ${invoice1}
    Set Suite Variable  ${invoices}
    ${resp}=  Reimburse Payment  ${invoices}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Reimburse Reports By Provider  id-eq=${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['listOfJaldeeCoupons']}  {"${cupn_code01_01}":50.0}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[2]}
    Should Be Equal As Strings  ${resp.json()[0]['subJcTotalPaid']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['subJbankTotalPaid']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['totalPaid']}  50.0

    ${resp}=  Get Jaldee Coupons Stats  ${cupn_code01_01}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  100.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  2
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  100.0 
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  0.0

    sleep  05s
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Alerts
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain    ${resp.json()}  ${des_note}

JD-TC-Reimburse payment -UH4
    [Documentation]  Reimburse payment without login  
    ${resp}=  Reimburse Payment  ${invoices}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED_IN_SA}"

JD-TC-Reimburse payment -UH5
    [Documentation]   Consumer do Reimburse payment
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Reimburse Payment  ${invoices}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED_IN_SA}"

JD-TC-Reimburse payment -UH6
    [Documentation]   Provider do Reimburse payment
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Reimburse Payment  ${invoices}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED_IN_SA}"
    
*** Comment ***
JD-TC-Reimburse payment-UH2
    [Documentation]  SA do invalid amount reimburse payment     
    ${resp}=   Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${cid}=  get_id  ${CUSERNAME2}
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
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  590.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  590.0

    ${resp}=  Apply Jaldee Coupon By Provider  OnamCoupon2020  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['OnamCoupon2020']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['OnamCoupon2020']['systemNote']}  ${SystemNote[1]}
    Should Contain  ${resp.json()['jCoupon']['OnamCoupon2020']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  540.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  540.0
    ${resp}=  Accept Payment  ${wid}  ${acceptPaymentBy[0]}  540  
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
    sleep  02s
    ${end}=  db.add_tz_time24  ${tz}   0  0
    ${start}=  db.add_tz_time24  ${tz}   0  -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${invoice_id}  ${resp.json()[0]['invoiceId']}

    ${resp}=  Request For Payment of Jaldeecoupon  ${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[1]}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons Stats  OnamCoupon2020
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  150.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  3
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  100.0 
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  50.0

                                     
    ${invoice1}=  Reimburse Ivoices  ${invoice_id}  payment of reimburse  ${jaldeePaymentmode[0]}  private note  JC
    ${invoices}=  Create List  ${invoice1}
    ${resp}=  Reimburse Payment  ${invoices}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "Reimburse Jaldee Coupon Amount should be equal to Jaldee Statement-Jaldee Coupon total"
