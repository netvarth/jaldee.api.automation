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

*** Variables ***
${LsTime}   08:00 AM
${LeTime}   09:00 AM

${sTime}    09:00 PM
${eTime}    11:00 PM
${longi}        89.524764
${latti}        86.524764
${self}   0
${tz}   Asia/Kolkata


*** Test Cases ***

JD-TC-Change reimbursement status-1
    [Documentation]  Get reimbursement report    
    ${billable_domains}=  get_billable_domain
    Set Test Variable  ${domains}  ${billable_domains[0]}
    Set Test Variable  ${sub_domains}   ${billable_domains[1]}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+45123
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
    ${licid}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domains[0]}  ${sub_domains[0]}  ${PUSERPH0}  ${licid[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERPH0}
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

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    @{Views}=  Create List  self  all  customersOnly
    ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
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
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    Set Suite Variable   ${eTime}
    ${resp}=  Update Business Profile With Schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
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

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
    #${cid}=  get_id  ${CUSERNAME1}
    #Set Suite Variable  ${cid}   
    clear_location  ${PUSERPH0}
    clear_service   ${PUSERPH0}
    clear_queue     ${PUSERPH0}
    ${resp}=  Create Sample Queue
    Set Suite Variable  ${qid1}   ${resp['queue_id']}
    Set Suite Variable  ${s_id2}   ${resp['service_id']}
    Set Suite Variable  ${lid}   ${resp['location_id']}
    Set Suite Variable  ${s_name}   ${resp['service_name']}
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${price}     ${resp.json()['totalAmount']}
  
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2020}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[0]}
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code2020}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2020}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code01_01}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[0]}
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code01_01}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code01_01}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${des}=    FakerLibrary.sentence
    Set Suite Variable   ${des}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id2}  ${qid1}  ${DAY1}  ${des}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    # 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]} 
    sleep  02s  
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${price}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${s_name}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  ${price}
    Should Be Equal As Strings  ${resp.json()['netRate']}  ${price}
    Should Be Equal As Strings  ${resp.json()['amountDue']}  ${price}

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code2020}  ${wid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${netrate}   ${resp.json()['netRate']}

    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2020}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2020}']['systemNote']}  NO_OTHER_COUPONS_ALLOWED
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2020}']['systemNote']}  COUPON_APPLIED
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${price}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${s_name}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  ${price}
    Should Be Equal As Strings  ${resp.json()['netRate']}  ${netrate}
    Should Be Equal As Strings  ${resp.json()['amountDue']}  ${netrate}

    ${resp}=  Accept Payment  ${wid}  ${acceptPaymentBy[0]}  ${netrate}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.content}

    ${resp}=  Get Payment By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${acceptPaymentBy[0]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${netrate} 

    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]} 
    
    ${end}=  db.add_tz_time24  ${tz}   0  0
    ${start}=  db.add_tz_time24  ${tz}   0  -5
    #${start}=  db.add_tz_time_sec  ${tz}   0  -5  0
    #${end}=  db.add_tz_time_sec  ${tz}   0  0  0
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s

    ${resp}=  Get Reimburse Reports By Provider
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${invoice_id}  ${resp.json()[0]['invoiceId']}
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  50.0

    ${resp}=  Request For Payment of Jaldeecoupon  ${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Reimburse Reports By Provider  id-eq=${invoice_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[1]}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Set Suite Variable   ${uname}    ${resp.json()['userName']}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_code2020}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  0.0 
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  50.0

    ${des_note}=   FakerLibrary.sentence
    Set Suite Variable  ${des_note}
    ${private_note}=   FakerLibrary.sentence
    Set Suite Variable  ${private_note}

    ${invoice1}=  Reimburse Ivoices  ${invoice_id}  ${des_note}  ${Reimburse_invoice[1]}  ${private_note}  ${cupn_for[1]}
    ${invoices}=  Create List  ${invoice1}
    ${resp}=  Reimburse Payment  ${invoices}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimbursement By InvoiceId  ${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['invoice']['invoiceId']}  ${invoice_id}
    Should Be Equal As Strings  ${resp.json()[0]['paidDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['displayNote']}  ${des_note}
    Should Be Equal As Strings  ${resp.json()[0]['privateNote']}  ${private_note}
    Should Be Equal As Strings  ${resp.json()[0]['jcTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['jaldeePaymentmode']}  ${jaldeePaymentmode[1]}
    Should Be Equal As Strings  ${resp.json()[0]['grandTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['paidBy']['id']}  2
    Should Be Equal As Strings  ${resp.json()[0]['paidBy']['userName']}  ${uname}

    ${resp}=  Change Reimbursement Status  ${invoice_id}  ${Reimburse_invoice[2]}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_INVOICE_STATUS_CANNOT_CHANGE_FROM_PAID}"

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
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

JD-TC-Change reimbursement status-2
    #clear_reimburseReport
    clear_payment_invoice  ${PUSERPH0}
    [Documentation]  Get reimbursement report    
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERPH0}

    ${resp}=  AddCustomer  ${CUSERNAME21}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME21}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
    #${cid}=  get_id  ${CUSERNAME21}
    ${des}=   FakerLibrary.sentence
    Set Suite Variable   ${des}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id2}  ${qid1}  ${DAY1}  ${des}  ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}  

    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}   ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}   ${price}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${s_name}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}    ${price}
    Should Be Equal As Strings  ${resp.json()['netRate']}     ${price}
    Should Be Equal As Strings  ${resp.json()['amountDue']}   ${price}

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code2020}  ${wid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${netrate}   ${resp.json()['netRate']}

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2020}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2020}']['systemNote']}  NO_OTHER_COUPONS_ALLOWED
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2020}']['systemNote']}  COUPON_APPLIED
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${price}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${s_name}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}   ${price}
    Should Be Equal As Strings  ${resp.json()['netRate']}    ${netrate}
    Should Be Equal As Strings  ${resp.json()['amountDue']}  ${netrate}

    ${resp}=  Accept Payment  ${wid}  ${acceptPaymentBy[0]}  ${netrate} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${acceptPaymentBy[0]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${netrate}

    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]} 

    sleep  02s

    ${end}=  db.add_tz_time24  ${tz}   0  0
    ${start}=  db.add_tz_time24  ${tz}   0  -5

    # ${end}=  db.add_tz_time_sec  ${tz}   0  0  0
    # ${start}=  db.add_tz_time_sec  ${tz}   0  -5  0
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${invoice_id}  ${resp.json()[0]['invoiceId']}
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[3]}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons Stats  ${cupn_code2020}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  0.0 
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  50.0

    ${resp}=  Change Reimbursement Status  ${invoice_id}  ${Reimburse_invoice[2]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['invoiceId']}  ${invoice_id}
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${Reimburse_invoice[2]}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
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
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${Reimburse_invoice[2]}
    Should Be Equal As Strings  ${resp.json()[0]['subJcTotalPaid']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['subJbankTotalPaid']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['totalPaid']}  0.0

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Change Reimbursement Status  ${invoice_id}  ${cupnpaymentStatus[2]}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_INVOICE_STATUS_CANNOT_CHANGE_TO_PAID}"

    ${resp}=  Change Reimbursement Status  ${invoice_id}  ${cupnpaymentStatus[3]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['invoiceId']}  ${invoice_id}
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[3]}

    ${des_note}=   FakerLibrary.sentence
    Set Suite Variable   ${des_note}
    ${private_note}=   FakerLibrary.sentence
    Set Suite Variable   ${private_note}

    ${invoice1}=  Reimburse Ivoices  ${invoice_id}  ${des_note}  ${Reimburse_invoice[1]}  ${private_note}  ${cupn_for[1]}
    ${invoices}=  Create List  ${invoice1}
    ${resp}=  Reimburse Payment  ${invoices}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimbursement By InvoiceId  ${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['invoice']['invoiceId']}  ${invoice_id}
    Should Be Equal As Strings  ${resp.json()[0]['paidDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['displayNote']}  ${des_note}
    Should Be Equal As Strings  ${resp.json()[0]['privateNote']}  ${private_note}
    Should Be Equal As Strings  ${resp.json()[0]['jcTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['jaldeePaymentmode']}  ${jaldeePaymentmode[1]}
    Should Be Equal As Strings  ${resp.json()[0]['grandTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['paidBy']['id']}  2
    Should Be Equal As Strings  ${resp.json()[0]['paidBy']['userName']}  ${uname}

    ${resp}=  Change Reimbursement Status  ${invoice_id}  ${Reimburse_invoice[2]}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_INVOICE_STATUS_CANNOT_CHANGE_FROM_PAID}"

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
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

JD-TC-Change reimbursement status-UH1
    [Documentation]  Change reimbursement status without login  
    ${resp}=  Change Reimbursement Status  ${invoice_id}  ${Reimburse_invoice[3]}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SA_SESSION_EXPIRED}"

JD-TC-Change reimbursement status -UH2
    [Documentation]   Consumer do Change reimbursement status
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Change Reimbursement Status  ${invoice_id}  ${Reimburse_invoice[3]}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SA_SESSION_EXPIRED}"

JD-TC-Change reimbursement status -UH3
    [Documentation]   Provider do Change reimbursement status
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Change Reimbursement Status  ${invoice_id}  ${Reimburse_invoice[3]}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SA_SESSION_EXPIRED}"

*** Comments ***
JD-TC-Change reimbursement status-2
    [Documentation]     Reimburse payment of same jaldee coupon and same provider and Get reimbursement report 
    ${resp}=   Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERNAME7}
    ${cid}=  get_id  ${CUSERNAME}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id2}  ${qid1}  ${DAY1}  hi  True  ${cid}
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

    ${resp}=  Apply Jaldee Coupon By Provider  OnamCoupon2020  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['OnamCoupon2020']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['OnamCoupon2020']['systemNote']}  NO_OTHER_COUPONS_ALLOWED
    Should Contain  ${resp.json()['jCoupon']['OnamCoupon2020']['systemNote']}  COUPON_APPLIED
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  540.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  540.0
    ${resp}=  Accept Payment  ${wid}  cash  540  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Payment By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  cash
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  540.0

    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  Settled 
    sleep  02s
    ${end}=  db.add_tz_time_sec  ${tz}   0  0  0
    ${start}=  db.add_tz_time_sec  ${tz}   0  -5  0
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${invoice_id}  ${resp.json()[0]['invoiceId']}
    
    ${resp}=  Request For Payment of Jaldeecoupon  ${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Reimburse Reports By Provider  id-eq=${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['status']}  REQUESTED

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons Stats  OnamCoupon2020
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  100.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  2
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  50.0 
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  50.0

    ${invoice1}=  Reimburse Ivoices  ${invoice_id}  payment of reimburse  CASH  private note
    ${invoices}=  Create List  ${invoice1}
    ${resp}=  Reimburse Payment  ${invoices}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimbursement By InvoiceId  ${invoice_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Change Reimbursement Status  ${invoice_id}  NOTPAID
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



