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

${SERVICE1}  Note Book110510122
${SERVICE2}  boots10510122
${SERVICE3}  pen10510122
${SERVICE4}  ABCD10510122
${queue1}  morning
${LsTime}   08:00 AM
${LeTime}   09:00 AM

${sTime}    09:00 PM
${eTime}    11:00 PM
${longi}        89.524764
${latti}        86.524764
${self}  0
${tz}   Asia/Kolkata


*** Test Cases ***

JD-TC-Get ReimbursereportsCount-1
    [Documentation]  Get reimbursement report   
    ${billable_domains}=  get_billable_domain
    Set Test Variable  ${domains}  ${billable_domains[0]}
    Set Test Variable  ${sub_domains}   ${billable_domains[1]}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+45445
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH0}${\n}
    ${licid}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domains[0]}  ${sub_domains[0]}  ${PUSERPH0}  ${licid[0]}
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


    ${domains}=  Jaldee Coupon Target Domains  ${domain}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${domain}_${subDomain}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code2020}=    FakerLibrary.word
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

    ${cupn_code01_01}=    FakerLibrary.word
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

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
    # ${cid}=  get_id  ${CUSERNAME1}
    # Set Suite Variable  ${cid}
    clear_queue  ${PUSERPH0}
    clear_service  ${PUSERPH0}  
    clear_location  ${PUSERPH0}
    ${resp}=  Create Sample Queue
    Set Suite Variable  ${qid1}    ${resp['queue_id']}
    
    Set Suite Variable  ${s_id2}   ${resp['service_id']}
    
    Set Suite Variable  ${s_name}   ${resp['service_name']}
    Set Suite Variable  ${lid}   ${resp['location_id']}

    ${des}=    FakerLibrary.sentence
    Set Suite Variable    ${des}
    
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

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2020}
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

    ${resp}=   Get reimburse
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${eg_id}    ${resp.json()[0]['reportId']}

    ${resp}=  Get Reimburse Reports Count  reportId-eq=${eg_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get ReimbursereportsCount-2
    [Documentation]     Reimburse payment of same jaldee coupon and same provider and Get reimbursement report 
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERPH0}

    # ${resp}=  AddCustomer  ${CUSERNAME24}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()}


    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid12}  ${resp.json()}


    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid12}  ${resp.json()[0]['id']}
    #${cid}=  get_id  ${CUSERNAME12}
    ${des}=    FakerLibrary.sentence
    Set Suite Variable   ${des}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id2}  ${qid1}  ${DAY1}  ${des}  ${bool[1]}  ${cid12}
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
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2020}']['systemNote']}  ${SystemNote[1]}
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2020}']['systemNote']}  ${SystemNote[2]}
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
    sleep  02s

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
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  100.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  2
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  50.0 
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  50.0

    ${invoice1}=  Reimburse Ivoices  ${invoice_id}  ${dis_note}  ${Reimburse_invoice[0]}  ${privte_note}  ${cupn_for[1]}
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
    Should Be Equal As Strings  ${resp.json()['usageAmt']}  100.0
    Should Be Equal As Strings  ${resp.json()['usageCount']}  2
    Should Be Equal As Strings  ${resp.json()['reimbursed']}  100.0 
    Should Be Equal As Strings  ${resp.json()['balanceDue']}  0.0

    ${resp}=   Get reimburse
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${eg_id}    ${resp.json()[0]['reportId']}

    ${resp}=  Get Reimburse Reports Count  reportId-eq=${eg_id} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1  


JD-TC-Get ReimbursereportsCount-UH1
    [Documentation]  Get ReimbursereportsCount without login  
    ${resp}=  Get Reimburse Reports Count   reportId-eq=${eg_id}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED_IN_SA}"

JD-TC-Get ReimbursereportsCount -UH2
    [Documentation]   Consumer do Get ReimbursereportsCount
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Reimburse Reports Count   reportId-eq=${eg_id}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED_IN_SA}"

JD-TC-Get ReimbursereportsCount -UH3
    [Documentation]   Provider do Get ReimbursereportsCount
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Reimburse Reports Count   reportId-eq=${eg_id}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED_IN_SA}"

