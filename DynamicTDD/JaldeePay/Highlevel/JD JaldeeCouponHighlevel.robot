*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Coupon
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/consumermail.py



***Keywords***

Get Billable Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Suite Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Should Be Equal As Strings    ${resp.status_code}    200
            Exit For Loop IF  '${resp.json()['serviceBillable']}' == '${bool[1]}'
    END
    RETURN  ${subdomain}  ${resp.json()['serviceBillable']}

*** Variables ***

${SERVICE1}  Note Book1107
${SERVICE2}  boots107
${SERVICE3}  pen107
${SERVICE4}  Note Book12107
${SERVICE5}  boots13107
${SERVICE6}  pen15107
${SERVICE7}  pen25107
${SERVICE8}  pen155107
${SERVICE9}  pen255107
${SERVICE10}  pen26107
${SERVICE11}  pen266107
${item1}  PenHHH
${itemCode1}   itemCode1pen266107
${DisplayName1}   item1_DisplayName
${queue1}  morning
${longi}        89.524764
${latti}        86.524764
${self}         0


*** Test Cases ***

JD-TC-JaldeeCouponHighlevel-1
    [Documentation]  Consumer apply a coupon at Checkin time,Disable that coupon by superadmin before bill settilment then also add more item on it
    
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+100100150
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
    Set Suite Variable   ${PUSERPH0}
    clear_location  ${PUSERPH0}
    clear_Item  ${PUSERPH0} 
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_service  ${PUSERPH0}  AND  clear_Item    ${PUSERPH0}  AND   clear_Coupon   ${PUSERPH0}   AND  clear_Discount  ${PUSERPH0}
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    Set Suite Variable   ${licid}
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Suite Variable  ${d1}  ${domresp.json()[${pos}]['domain']}
        ${sd1}  ${check}=  Get Billable Subdomain  ${d1}  ${domresp}  ${pos}  
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
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${p_id}  ${decrypted_data['id']}
    
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
    ${24hours}    Random Element    ['${bool[1]}','${bool[0]}']
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    Set Suite Variable   ${eTime}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  

    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
    Should Be Equal As Strings    ${fields.status_code}   200
    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}
    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    Set Test Variable  ${email_id}  ${P_Email}${PUSERPH0}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}  ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Waitlist
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   01s

    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    ${licenses}=  Jaldee Coupon Target License  ${licid}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  ${DAY2}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code_OO}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code_OO}
    ${cupn_name}=   FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable   ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable   ${c_des}
    ${p_des}=   FakerLibrary.sentence
    Set Suite Variable   ${p_des}
    clear_jaldeecoupon  ${cupn_code_OO}

    ${resp}=  Create Jaldee Coupon  ${cupn_code_OO}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  20  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code_WWY}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code_WWY}
    clear_jaldeecoupon  ${cupn_code_WWY}

    ${resp}=  Create Jaldee Coupon  ${cupn_code_WWY}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  20  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code_OO}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code_WWY}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code_OO}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code_OO}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code_WWY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code_WWY}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${businessStatus}    Random Element   ${businessStatus}  
    ${accounttype}  Random Element   ${accounttype} 
    ${fname}=   FakerLibrary.name
    ${panCardNumber}=  Generate_pan_number
    Set Suite Variable   ${panCardNumber}
    ${bankAccountNumber}=  Generate_random_value  size=16  chars=string.digits
    Set Suite Variable   ${bankAccountNumber}
    ${bankName}=  FakerLibrary.company
    Set Suite Variable   ${bankName}
    ${ifsc}=  Generate_ifsc_code
    Set Suite Variable   ${ifsc}
    ${panname}=  FakerLibrary.name
    Set Suite Variable   ${panname}
    ${city}=   get_place
    Set Suite Variable   ${city}

    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERPH0}   ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc}  ${pan_name}  ${fname}  ${city}  ${businessStatus}  ${accounttype}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${pid}
    ${resp}=  payuVerify  ${pid}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERPH0}   ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc}  ${pan_name}  ${fname}  ${city}  ${businessStatus}  ${accounttype}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid}  ${merchantid}

    ${cid}=  get_id  ${CUSERNAME5}
    Set Suite Variable  ${cid}
    ${list}=  Create List   1  2  3  4  5  6  7

    # ${city}=   FakerLibrary.state
    # Set Suite Variable  ${city}
    # ${latti}=  get_latitude
    # Set Suite Variable  ${latti}
    # ${longi}=  get_longitude
    # Set Suite Variable  ${longi}
    # ${postcode}=  FakerLibrary.postcode
    # Set Suite Variable  ${postcode}
    # ${address}=  get_address
    # Set Suite Variable  ${address}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    Set Suite Variable  ${city}
    Set Suite Variable  ${latti}
    Set Suite Variable  ${longi}
    Set Suite Variable  ${postcode}
    Set Suite Variable  ${address}
    ${24hours}    Random Element    ['True','False']
    Set Suite Variable  ${24hours}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${LsTime}=  add_timezone_time  ${tz}  1  05  
    Set Suite Variable   ${LsTime}
    ${LeTime}=  add_timezone_time  ${tz}  2  30  
    Set Suite Variable   ${LeTime}

    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${LsTime}  ${LeTime}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${lid}  ${resp.json()}

    ${description}=  FakerLibrary.sentence
    Set Suite Variable   ${description}
    ${ser_dutratn}=   Random Int   min=5   max=10
    Set Suite Variable   ${ser_dutratn}
    ${total_amount1}=  Random Int   min=100  max=500
    Set Test Variable   ${total_amount1}
    ${total_amount2}=  Random Int   min=100  max=500
    Set Test Variable   ${total_amount2}
    ${min_prepayment}=   Random Int   min=10  max=50
    Set Test Variable   ${min_prepayment}

    ${resp}=  Create Service  ${SERVICE1}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  50  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE2}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE3}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id3}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE4}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  50  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id4}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE5}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id5}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE6}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id6}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE7}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id7}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE8}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id8}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE9}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id9}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE10}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id10}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE11}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id11}  ${resp.json()}

    ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  10  100  ${lid}  ${s_id1}  ${s_id2}  ${s_id3}  ${s_id4}  ${s_id5}  ${s_id6}  ${s_id7}  ${s_id8}  ${s_id9}  ${s_id10}  ${s_id11}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME3}
    ${coupons}=  Create List  ${cupn_code_OO}  ${cupn_code_WWY}
    ${desc}=   FakerLibrary.sentence
    Set Suite Variable   ${desc}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id1}  ${desc}  ${bool[0]}  ${coupons}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_OO}']['value']}  50.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_OO}']['systemNote'][0]}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_WWY}']['value']}  50.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_WWY}']['systemNote'][0]}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  490.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  490.0
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[0]}

    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code_OO}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0
    
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code_WWY}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0
    sleep  05s
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Disable Jaldee Coupon  ${cupn_code_OO}  reason for disable
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  03s
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code_OO}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${couponStatus[2]}
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  05s
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${service}=  Service Bill  service forme  ${s_id4}  1
    ${resp}=  Update Bill   ${wid}  addService   ${service}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_OO}']['value']}  50.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_OO}']['systemNote'][0]}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_WWY}']['value']}  50.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_WWY}']['systemNote'][0]}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceId']}  ${s_id4}
    Should Be Equal As Strings  ${resp.json()['service'][1]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceName']}  ${SERVICE4}
    Should Be Equal As Strings  ${resp.json()['service'][1]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  1000.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  1080.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  1080.0
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[0]}

JD-TC-JaldeeCouponHighlevel-2
    [Documentation]  Consumer apply a coupon at Checkin time,Disable that coupon by provider before bill settilment then also add more item on it
    
    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    ${licenses}=  Jaldee Coupon Target License  ${licid}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code_ZZZ}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code_ZZZ}
    
    clear_jaldeecoupon  ${cupn_code_ZZZ}

    ${resp}=  Create Jaldee Coupon  ${cupn_code_ZZZ}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  50  20  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code_ZZZ}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code_ZZZ}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code_ZZZ}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME3}
    ${coupons}=  Create List  ${cupn_code_ZZZ}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id2}  ${desc}  ${bool[0]}  ${coupons}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_ZZZ}']['value']}  50.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_ZZZ}']['systemNote'][0]}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  540.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  540.0
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[0]}
    sleep  05s
    ${resp}=  Disable Jaldee Coupon By Provider  ${cupn_code_ZZZ}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  03s
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code_ZZZ}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cupn_code_ZZZ}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[3]}
    sleep  02s
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${des_item}=  FakerLibrary.Word
    ${description_item}=  FakerLibrary.sentence
    
    ${amount1}=  Set Variable    100.0
    # ${resp}=  Create Item   ${item1}  ${des_item}  ${description}  ${amount1}  ${bool[1]}
    ${resp}=  Create Sample Item   ${DisplayName1}   ${item1}  ${itemCode1}  ${amount1}  ${bool[1]} 
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${itemId1}  ${resp.json()}

    ${item}=  Item Bill  ${des_item}  ${itemId1}  1
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  5s
    ${resp}=  Update Bill   ${wid}  addItem   ${item}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_ZZZ}']['value']}  50.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_ZZZ}']['systemNote'][0]}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemId']}  ${itemId1}
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}  100.0
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}  ${DisplayName1}
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  600.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  658.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  658.0
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[0]}


JD-TC-JaldeeCouponHighlevel-3
    [Documentation]  Consumer apply a coupon at self payment and provider also apply a jaldee coupon to same bill
    
    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    ${licenses}=  Jaldee Coupon Target License  ${licid}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2} 
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code_Onam2018}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code_Onam2018}
    
    clear_jaldeecoupon  ${cupn_code_Onam2018}

    ${resp}=  Create Jaldee Coupon  ${cupn_code_Onam2018}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  15  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code_011}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code_011}
    
    clear_jaldeecoupon  ${cupn_code_011}

    ${resp}=  Create Jaldee Coupon  ${cupn_code_011}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  15  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code_Onam2018}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code_Onam2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${couponStatus[1]}
    ${resp}=  Push Jaldee Coupon  ${cupn_code_011}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code_Onam2018}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code_Onam2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code_011}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code_011}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}

    ${resp}=  AddCustomer  ${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    
    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${resp}=  Add To Waitlist  ${cid}  ${s_id2}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
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

    ${resp}=  Accept Payment  ${wid}  ${payment_modes[7]}  590
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Apply Jaldee Coupon At Selfpay  ${wid}  ${cupn_code_Onam2018}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By Consumer  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_Onam2018}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code_Onam2018}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  540.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  540.0

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code_011}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_Onam2018}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code_Onam2018}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_011}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code_011}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  490.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  490.0
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[0]}
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code_Onam2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code_011}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0

JD-TC-JaldeeCouponHighlevel-4
    [Documentation]  Consumer apply a coupon at Checkin time and provider also apply a coupon on bill
    
    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    ${licenses}=  Jaldee Coupon Target License  ${licid}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code_cpn01}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code_cpn01}
    
    clear_jaldeecoupon  ${cupn_code_cpn01}

    ${resp}=  Create Jaldee Coupon  ${cupn_code_cpn01}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code_cpn02}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code_cpn02}
    
    clear_jaldeecoupon  ${cupn_code_cpn02}

    ${resp}=  Create Jaldee Coupon  ${cupn_code_cpn02}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code_cpn01}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code_cpn02}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code_cpn01}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code_cpn01}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code_cpn02}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code_cpn02}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME5}
    ${coupons}=  Create List  ${cupn_code_Onam2018}  ${cupn_code_cpn01}  ${cupn_code_cpn02}
    Set Suite Variable  ${coupons}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id1}  ${desc}  ${bool[0]}  ${coupons}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code_011}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_Onam2018}']['value']}  50.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_Onam2018}']['systemNote'][0]}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_cpn01}']['value']}  50.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_cpn01}']['systemNote'][0]}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_cpn02}']['value']}  50.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_cpn02}']['systemNote'][0]}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_011}']['value']}  50.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_011}']['systemNote'][0]}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  390.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  390.0
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[0]}

    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code_Onam2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  100.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  2
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code_cpn01}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code_cpn02}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code_011}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  100.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  2
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    ${resp}=  Make payment Consumer Mock    ${pid}   390.0    ${purpose[1]}    ${wid}    ${s_id1}    ${bool[0]}   ${bool[1]}         ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   3s
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]}

    ${resp}=  Get Bill By Consumer  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_Onam2018}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code_Onam2018}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_cpn01}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code_cpn01}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_cpn02}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code_cpn02}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_011}']['value']}  50.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_011}']['systemNote'][0]}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  390.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  0.0
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[2]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-JaldeeCouponHighlevel-5
    [Documentation]  Provider apply a coupon after waitlist and consumer also apply a coupon at Selfpay
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  AddCustomer  ${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${resp}=  Add To Waitlist  ${cid}  ${s_id3}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  500.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  500.0

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code_Onam2018}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_Onam2018}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code_Onam2018}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  450.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  450.0

    ${resp}=  Accept Payment  ${wid}  ${payment_modes[7]}  450
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Apply Jaldee Coupon At Selfpay  ${wid}  ${cupn_code_011}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By Consumer  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_Onam2018}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code_Onam2018}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_011}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code_011}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  400.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  400.0

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_Onam2018}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code_Onam2018}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_011}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code_011}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  400.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  400.0
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[0]}
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code_Onam2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  150.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  3
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code_011}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  150.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  3
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0

JD-TC-JaldeeCouponHighlevel-UH1
    [Documentation]  Provider apply a coupon after waitlist and consumer also apply same coupon at Selfpay
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  AddCustomer  ${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${resp}=  Add To Waitlist  ${cid}  ${s_id4}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id4}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE4}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  590.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  590.0

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code_Onam2018}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_Onam2018}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code_Onam2018}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id4}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE4}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  540.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  540.0

    ${resp}=  Accept Payment  ${wid}  ${payment_modes[7]}  540.0
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Apply Jaldee Coupon At Selfpay  ${wid}  ${cupn_code_Onam2018}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"  "${COUPON_ALREADY_USED}"
    Should Be Equal As Strings  "${resp.json()}"  "Coupon already applied"

JD-TC-JaldeeCouponHighlevel-UH2
    [Documentation]  Consumer apply a coupon at self payment and provider also apply same jaldee coupon to same bill
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${resp}=  Add To Waitlist  ${cid}  ${s_id5}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id5}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE5}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  590.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  590.0

    ${resp}=  Accept Payment  ${wid}  ${payment_modes[7]}  590
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Apply Jaldee Coupon At Selfpay  ${wid}  ${cupn_code_Onam2018}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By Consumer  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_Onam2018}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code_Onam2018}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id5}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE5}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  540.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  540.0

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code_Onam2018}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  422
    #Should Be Equal As Strings  "${resp.json()}"  "${COUPON_ALREADY_USED}"
    Should Be Equal As Strings  "${resp.json()}"  "Coupon already applied"

JD-TC-JaldeeCouponHighlevel-UH3
    [Documentation]  Consumer apply a coupon at checkin time and provider also apply same jaldee coupon to same bill
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id6}  ${desc}  ${bool[0]}  ${coupons}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code_Onam2018}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  422
    #Should Be Equal As Strings  "${resp.json()}"  "${COUPON_ALREADY_USED}"
    Should Be Equal As Strings  "${resp.json()}"  "Coupon already applied"
    
JD-TC-JaldeeCouponHighlevel-UH4
    [Documentation]  Provider apply a coupon Apply jaldee coupon ,that created on future date
    
    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    ${licenses}=  Jaldee Coupon Target License  ${licid}
    ${DAY1}=  db.add_timezone_date  ${tz}  3  
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code_19}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code_19}
    
    clear_jaldeecoupon  ${cupn_code_19}

    ${resp}=  Create Jaldee Coupon  ${cupn_code_19}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  15  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Push Jaldee Coupon  ${cupn_code_19}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code_19}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${couponStatus[1]}

    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code_19}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code_19}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    
    ${DAY}=  db.add_timezone_date  ${tz}  1  
    ${resp}=  Add To Waitlist  ${cid}  ${s_id2}  ${qid1}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
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

    ${resp}=  Accept Payment  ${wid}  ${payment_modes[7]}  590
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Apply Jaldee Coupon At Selfpay  ${wid}  ${cupn_code_19}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  409
    Should Be Equal As Strings  "${resp.json()}"  "Jaldee Coupon not applicable on this day"

JD-TC-JaldeeCouponHighlevel-UH5
    [Documentation]  Consumer apply a coupon at checkin time and provider update bill as remove a service from bill again update bill by adding service to bill..then check the coupon limit
    
    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    ${licenses}=  Jaldee Coupon Target License  ${licid}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2} 
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code_HJ}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code_HJ}
    
    clear_jaldeecoupon  ${cupn_code_HJ}

    ${resp}=  Create Jaldee Coupon  ${cupn_code_HJ}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1  5  1  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code_HJ}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code_HJ}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code_HJ}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    ${coupons}=  Create List  ${cupn_code_HJ}
    Set Suite Variable  ${coupons}
    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME25}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id6}  ${desc}  ${bool[0]}  ${coupons}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_HJ}']['value']}  50.0
    #Should Contain  ${resp.json()['jCoupon']['${cupn_code_HJ}']['systemNote']}  ${SystemNote[1]}
    Should Contain  ${resp.json()['jCoupon']['${cupn_code_HJ}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id6}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE6}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  540.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  540.0

    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code_HJ}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 

    ${service}=  Service Bill  service forme  ${s_id6}  1 
    ${resp}=  Update Bill   ${wid}  removeService   ${service}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
JD-TC-JaldeeCouponHighlevel-UH6
    [Documentation]  Provider apply a coupon Apply jaldee coupon ,that created on future date
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  AddCustomer  ${CUSERNAME20}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME20}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    # ${cid}=  get_id  ${CUSERNAME20}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id4}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id4}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE4}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  590.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  590.0

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code_011}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code_011}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code_011}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id4}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE4}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  540.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  540.0

    ${resp}=  Accept Payment  ${wid}  ${payment_modes[7]}  540
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Apply Jaldee Coupon At Selfpay  ${wid}  ${cupn_code_011}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "Coupon already applied"



