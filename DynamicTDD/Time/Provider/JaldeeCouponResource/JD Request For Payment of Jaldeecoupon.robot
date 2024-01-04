*** Settings ***
Suite Teardown    Run Keywords  Delete All Sessions  resetsystem_time
Test Teardown     Delete All Sessions
Force Tags        JaldeeCoupon
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***

${self}         0
${digits}       0123456789
@{provider_list}
@{dom_list}
@{multiloc_providers}

***Keywords***

Get Billable Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Suite Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Log  ${resp.json()}
            Should Be Equal As Strings    ${resp.status_code}    200
            ${Status}=   Run Keyword And Return Status   Run Keywords   Should Be ${bool[1]}   '${resp.json()['maxPartySize']}' > '${1}'  AND   Should Be ${bool[1]}  '${resp.json()['serviceBillable']}' == '${bool[1]}'
            Exit For Loop IF  ${Status}
    END
    [Return]  ${subdomain}  ${Status}


*** Test Cases ***


JD-TC-Request for payment-1
    [Documentation]  Provider apply a coupon after waitlist ,done payment and settle bill then Request for payment 
    
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+100100701
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
    Set Suite Variable   ${PUSERPH0}
    
    # clear_reimburseReport  
    clear_queue  ${PUSERPH0}  
    clear_payment_invoice  ${PUSERPH0} 
    clear_payment_invoice  ${PUSERPH0}    
    clear_service  ${PUSERPH0}    
    clear_location  ${PUSERPH0}     
    
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Suite Variable  ${d1}  ${domresp.json()[${pos}]['domain']}
        ${sd1}  ${check}=   Get Billable Subdomain  ${d1}  ${domresp}  ${pos}  
        Set Suite Variable   ${sd1}
        Exit For Loop IF     '${check}' == '${bool[1]}'
    END
    Log  ${d1}
    Log  ${sd1}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERPH0}  ${licid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${PUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}    true
    
    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERPH0}+15566122
    ${ph2}=  Evaluate  ${PUSERPH0}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
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
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  18  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${ifsc_code}=   db.Generate_ifsc_code
    # ${bank_ac}=   db.Generate_random_value  size=11   chars=${digits} 
    # ${bank_name}=  FakerLibrary.company
    # ${name}=  FakerLibrary.name
    # ${branch}=   db.get_place
    # ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERPH0}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    
    ${pid}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${pid}

    clear_customer   ${PUSERPH0}

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    
    # ${resp}=  payuVerify  ${pid}
    # Log  ${resp}
    
    # ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERPH0}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}    
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    
    # ${resp}=  SetMerchantId  ${pid}  ${merchantid}
    # Should Be Equal As Strings    ${resp.status_code}   200
    
    # ${cid}=  get_id  ${CUSERNAME5}
    # Set Suite Variable  ${cid}

    ${domains}=  Jaldee Coupon Target Domains  ALL
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ALL
    ${resp}=  ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}   200

    ${licenses}=  Jaldee Coupon Target License  ${licid}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code2018}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code2018}
    ${cupn_name}=   FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable   ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable   ${c_des}
    ${p_des}=   FakerLibrary.sentence
    Set Suite Variable   ${p_des}
    
    clear_jaldeecoupon  ${cupn_code2018}

    ${resp}=  Create Jaldee Coupon  ${cupn_code2018}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  10  10  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Push Jaldee Coupon  ${cupn_code2018}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${cid}=  get_id  ${CUSERNAME5}
    # Set Suite Variable  ${cid}

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['${bool[1]}','False']
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${LsTime}=  db.get_time_by_timezone  ${tz}
    ${LeTime}=  add_timezone_time  ${tz}  0  15  
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${LsTime}  ${LeTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_l1}  ${resp.json()}

    ${P1SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   2  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   50  500  ${bool[1]}  ${bool[1]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s1}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   2  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s2}  ${resp.json()}

    ${P1SERVICE3}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE3}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE3}  ${desc}   2  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  500  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s3}  ${resp.json()}

    ${P1SERVICE3}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE3}  ${desc}   2  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${p1_s4}  ${resp.json()}
    
    ${sTime}=  add_timezone_time  ${tz}  0  45  
    ${eTime}=  add_timezone_time  ${tz}  2  45  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2}  ${p1_s3}  ${p1_s4} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q1}  ${resp.json()}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s2}  ${p1_q1}  ${DAY1}  ${cnote}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}   
    
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  New  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${p1_s2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${P1SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  590.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  590.0

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2018}
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
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2018}']['systemNote']}  NO_OTHER_COUPONS_ALLOWED
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2018}']['systemNote']}  COUPON_APPLIED
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${p1_s2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${P1SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  540.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  540.0
    
    ${resp}=  Accept Payment  ${wid}  ${payment_modes[0]}  540.0  
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Payment By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[0]}
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
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${invoice_id}  ${resp.json()[0]['invoiceId']} 

    ${resp}=  Get Reimburse Reports By Provider  id-eq=${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}  0.0
    Should Contain  ${resp.json()[0]['listOfJaldeeCoupons']}  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[3]}
    Should Be Equal As Strings  ${resp.json()[0]['subJcTotalPaid']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['subJbankTotalPaid']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['totalPaid']}  0.0  

    ${resp}=  Request For Payment of Jaldeecoupon  ${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Reimburse Reports By Provider  id-eq=${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[1]}

JD-TC-Request for payment-2
    [Documentation]  Provider agian apply a same coupon then request for reimburse 
    clear_payment_invoice  ${PUSERPH0} 

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200  

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${DAY1}  ${cnote}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}   
    
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  New  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${p1_s1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${P1SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  590.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  590.0

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code2018}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2018}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2018}']['systemNote']}  NO_OTHER_COUPONS_ALLOWED
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2018}']['systemNote']}  COUPON_APPLIED
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${p1_s1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${P1SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  540.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  540.0
    
    ${resp}=  Accept Payment  ${wid}  ${payment_modes[0]}  540.0  
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Payment By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[0]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  540.0

    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]} 
    # sleep  02s
    
    ${end}=  db.add_tz_time24  ${tz}   0  0
    ${start}=  db.add_tz_time24  ${tz}   0  -5

    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${invoice_id}  ${resp.json()[0]['invoiceId']}   

    ${resp}=  Get Reimburse Reports By Provider  id-eq=${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}  0.0
    Should Contain  ${resp.json()[0]['listOfJaldeeCoupons']}  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[3]}
    Should Be Equal As Strings  ${resp.json()[0]['subJcTotalPaid']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['subJbankTotalPaid']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['totalPaid']}  0.0  

    ${resp}=  Request For Payment of Jaldeecoupon  ${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Reimburse Reports By Provider  id-eq=${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[1]}

JD-TC-Request for payment-UH1
    [Documentation]  Provider request reimburse of  already requested invoice_id
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200  
    ${resp}=  Request For Payment of Jaldeecoupon  ${invoice_id}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_INVOICE_ALREADY_REQUESTED}"

JD-TC-Request for payment-UH2
    [Documentation]  Provider request reimburse of  invalid  invoice_id
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200  
    ${resp}=  Request For Payment of Jaldeecoupon  0
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_INVOICE_NOT_EXISTS}"

JD-TC-Request for paymen -UH3
    [Documentation]   Request reimburse payment by without login  
    ${resp}=  Request For Payment of Jaldeecoupon  ${invoice_id}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-Request for paymen -UH4
    [Documentation]   Consumer request reimburse payment
    ${resp}=   Consumer Login  ${CUSERNAME}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Request For Payment of Jaldeecoupon  ${invoice_id}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-Request for paymen -UH5
    [Documentation]   Another Provider request reimburse payment
    ${resp}=   Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Request For Payment of Jaldeecoupon  ${invoice_id}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_INVOICE_NOT_EXISTS}"