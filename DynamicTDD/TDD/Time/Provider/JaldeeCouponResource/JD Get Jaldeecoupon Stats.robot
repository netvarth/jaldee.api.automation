*** Settings ***
Suite Teardown    Run Keywords  Delete All Sessions  resetsystem_time
Test Teardown     Delete All Sessions
Force Tags        JaldeeCoupon
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
${numbers}  0123456789
${SERVICE1}  Note Book1103
${SERVICE2}  boots103
${SERVICE3}  pen103
${SERVICE4}  Note Book12103
${SERVICE5}  boots13103
${SERVICE6}  pen15103
${SERVICE7}  pen25103
${SERVICE8}  pen155103
${SERVICE9}  pen255103
${SERVICE10}  pen26103
${SERVICE11}  pen266103
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
${self}    0
*** Test Cases ***

JD-TC-GetJaldeeCouponStats-1

    [Documentation]  Consumer apply a coupon at self payment and check get jaldee coupon stats

    ${resp}=   Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    clear_queue  ${PUSERNAME110}  
    clear_service  ${PUSERNAME110}  
    clear_location  ${PUSERNAME110}
    clear_customer   ${PUSERNAME110}

    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get BusinessDomainsConf
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    # Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    # Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    # Set Test Variable  ${sd2}  ${resp.json()[0]['subDomains'][1]['subDomain']}
    # Set Test Variable  ${sd3}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    # Set Test Variable  ${sd4}  ${resp.json()[1]['subDomains'][1]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ALL
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ALL

    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
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

    clear_jaldeecoupon  ${cupn_code2018}
    ${resp}=  Create Jaldee Coupon  ${cupn_code2018}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  15  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Push Jaldee Coupon  ${cupn_code2018}  ${cupn_des}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2018}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code2018}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2018}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    #${gstper}=  Random Element  ${gstpercentage}
    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}
    Log    ${resp.json()}

    ${firstname}=  FakerLibrary.name
    ${name1}=  FakerLibrary.name
    ${city}=   get_place
    ${IFSC}=  Generate_ifsc_code
    ${ph}=   evaluate    ${PUSERNAME152}+1234
    ${acc}=    Generate_random_value  11   ${numbers}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${ph}   ${pan_num}  ${acc}  ${name1}  ${IFSC}  ${firstname}  ${firstname}  ${city}  ${businessStatus[1]}  ${accounttype[1]}   
    # Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERNAME110}
    Set Suite Variable  ${pid}
    # ${resp}=  payuVerify  ${pid}
    # ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${ph}   ${pan_num}  ${acc}  ${name1}  ${IFSC}  ${firstname}  ${firstname}  ${city}  ${businessStatus[1]}  ${accounttype[1]}   
    # Should Be Equal As Strings    ${resp.status_code}   200
    # ${resp}=  SetMerchantId  ${pid}  ${merchantid}
    # ${cid}=  get_id  ${CUSERNAME5}
    # Set Suite Variable  ${cid}

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  

    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${description}=  FakerLibrary.sentence
    ${address}=  get_address

    ${list}=  Create List   1  2  3  4  5  6  7
    ${resp}=  Create Location  ABCDE  ${longi}  ${latti}  www.${companySuffix}.com  ${postcode}  ${address}  free  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${LsTime}  ${LeTime}
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
    ${resp}=  Create Service  ${SERVICE7}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  50  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${s_id7}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE8}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${s_id8}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE9}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${s_id9}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE10}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${s_id10}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE11}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${s_id11}  ${resp.json()}
    
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}  ${s_id1}  ${s_id2}  ${s_id3}  ${s_id4}  ${s_id5}  ${s_id6}  ${s_id7}  ${s_id8}  ${s_id9}  ${s_id10}  ${s_id11}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
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

    ${resp}=  Accept Payment  ${wid}  self_pay  590  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Apply Jaldee Coupon At Selfpay  ${wid}  ${cupn_code2018}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 

JD-TC-GetJaldeeCouponStats-2

    [Documentation]  Consumer apply a coupon at Checkin time and check coupon stats

    # ${resp}=  Get BusinessDomainsConf
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    # Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    # Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    # Set Test Variable  ${sd2}  ${resp.json()[0]['subDomains'][1]['subDomain']}
    # Set Test Variable  ${sd3}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    # Set Test Variable  ${sd4}  ${resp.json()[1]['subDomains'][1]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ALL
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ALL 
    ${licenses}=  Jaldee Coupon Target License   ${lic1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cupn_code01}=   FakerLibrary.word
    Set Suite Variable    ${cupn_code01}
    clear_jaldeecoupon  ${cupn_code01}
    ${resp}=  Create Jaldee Coupon  ${cupn_code01}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code02}=   FakerLibrary.word
    Set Suite Variable    ${cupn_code02}
    clear_jaldeecoupon  ${cupn_code02}
    ${resp}=  Create Jaldee Coupon  ${cupn_code02}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code01}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code02}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code01}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code01}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code02}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code02}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200    
    # ${cid}=  get_id  ${CUSERNAME5}    
    ${coupons}=  Create List  ${cupn_code2018}  ${cupn_code01}  ${cupn_code02}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id1}  ${des}  ${bool[0]}  ${coupons}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  100.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  2
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code01}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code02}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 
  
JD-TC-GetJaldeeCouponStats-3
    [Documentation]  Consumer apply a coupon at Checkin time when that coupon has the rule of CombineWithOtherCoupons is ${bool[0]} and check coupon status
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
    ${cupn_code03}=   FakerLibrary.word
    Set Suite Variable    ${cupn_code03} 
    clear_jaldeecoupon  ${cupn_code03}
    ${resp}=  Create Jaldee Coupon  ${cupn_code03}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code03}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code03}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code03}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    # ${cid}=  get_id  ${CUSERNAME5}    
    ${coupons}=  Create List  ${cupn_code2018}  ${cupn_code01}  ${cupn_code03}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id3}  ${des}  ${bool[0]}  ${coupons}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422 

    ${coupons}=  Create List  ${cupn_code2018}  ${cupn_code01}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id3}  ${des}  ${bool[0]}  ${coupons}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  150.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  3
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code01}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  100.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  2
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code02}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 
     ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code03}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  0.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 
  
JD-TC-GetJaldeeCouponStats-4
    [Documentation]  Consumer apply a coupon at Checkin time when that coupon has discount type as PERCENTAGE and check coupon status
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
    ${cupn_code04}=   FakerLibrary.word
    Set Suite Variable    ${cupn_code04}

    clear_jaldeecoupon  ${cupn_code04}
    ${resp}=  Create Jaldee Coupon  ${cupn_code04}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  PERCENTAGE  10  100  ${bool[0]}  ${bool[0]}  100  100  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code04}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code04}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code04}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    # ${cid}=  get_id  ${CUSERNAME5}    
    ${coupons}=  Create List  ${cupn_code04}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id4}  ${des}  ${bool[0]}  ${coupons}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code04}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 

JD-TC-GetJaldeeCouponStats-5
    [Documentation]  Consumer apply a coupon at Checkin time when that coupon as defaultly enabled and check its status
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
    ${cupn_code05}=   FakerLibrary.word
    Set Suite Variable    ${cupn_code05}

    clear_jaldeecoupon  ${cupn_code05}
    ${resp}=  Create Jaldee Coupon  ${cupn_code05}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  PERCENTAGE  10  100  ${bool[1]}  ${bool[0]}  100  100  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code05}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code05}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    # ${cid}=  get_id  ${CUSERNAME5}    
    ${coupons}=  Create List  ${cupn_code05}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id5}  ${des}  ${bool[0]}  ${coupons}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code05}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 

JD-TC-GetJaldeeCouponStats-6
    [Documentation]  Consumer apply a coupon at Checkin time when that coupon as always enabled and check its status
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

    ${cupn_code07}=   FakerLibrary.word
    Set Suite Variable    ${cupn_code07}
    clear_jaldeecoupon  ${cupn_code07}
    ${resp}=  Create Jaldee Coupon  ${cupn_code07}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  PERCENTAGE  10  100  ${bool[1]}  ${bool[1]}  100  100  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code07}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code07}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    # ${cid}=  get_id  ${CUSERNAME5}    
    ${coupons}=  Create List  ${cupn_code07}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id6}  ${des}  ${bool[0]}  ${coupons}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code07}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 

JD-TC-GetJaldeeCouponStats-UH2
    [Documentation]  Consumer apply a coupon at Checkin time.but minBillAmount is not satisfied and check its status
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
    ${cupn_code08}=   FakerLibrary.word
    Set Suite Variable    ${cupn_code08}
    clear_jaldeecoupon  ${cupn_code08}
    ${resp}=  Create Jaldee Coupon  ${cupn_code08}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  PERCENTAGE  10  100  ${bool[1]}  ${bool[1]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code08}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code08}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}    
        
    ${resp}=  Add To Waitlist  ${cid}  ${s_id7}  ${qid1}  ${DAY1}  ${des}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code08}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  409
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_MINIMUM_BILL_AMT_REQUIRED}"   
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code08}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  0.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 

JD-TC-GetJaldeeCouponStats-UH3
    [Documentation]  Consumer apply a coupon at Checkin time.but maxProviderUseLimit is over and check its coupon status
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
    ${cupn_code09}=   FakerLibrary.word
    Set Suite Variable    ${cupn_code09}

    clear_jaldeecoupon  ${cupn_code09}
    ${resp}=  Create Jaldee Coupon  ${cupn_code09}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  PERCENTAGE  10  100  ${bool[1]}  ${bool[1]}  100  100  1  5  1  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code09}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code09}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    # ${cid}=  get_id  ${CUSERNAME3}    
    ${coupons}=  Create List  ${cupn_code09}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id8}  ${des}  ${bool[0]}  ${coupons}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code09}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 
  
    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id7}  ${des}  ${bool[0]}  ${coupons}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "Provider use Limit Reached"

    ${resp}=   Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code09}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 


JD-TC-GetJaldeeCouponStats-UH4
    [Documentation]  Consumer apply a coupon at Checkin time.but maxConsumerUseLimit is over and check coupon status
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
     ${cupn_code10}=   FakerLibrary.word
    Set Suite Variable    ${cupn_code10}
    clear_jaldeecoupon  ${cupn_code10}
    ${resp}=  Create Jaldee Coupon  ${cupn_code10}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  PERCENTAGE  10  100  ${bool[1]}  ${bool[1]}  100  100  1000  1  1  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code10}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code10}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    # ${cid}=  get_id  ${CUSERNAME5}    
    ${coupons}=  Create List  ${cupn_code10}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id9}  ${des}  ${bool[0]}  ${coupons}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code10}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 
  
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id10}  ${des}  ${bool[0]}  ${coupons}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${cupn_code10} ${JALDEE_COUPON_EXCEEDS_APPLY_LIMIT}"

    ${resp}=   Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code10}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 

JD-TC-GetJaldeeCouponStats-UH5
    [Documentation]  Consumer apply a coupon at Checkin time.but coupon apply only at firstCheckinOnly and check its status
    ${CUSERNAME7}=  Evaluate  ${CUSERNAME7}+100100299
    Set Suite Variable   ${CUSERNAME7}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERNAME7}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERNAME7}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}

    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERNAME7}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERNAME7}  1
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERNAME7}  ${PASSWORD}  1
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Logout
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
    ${cupn_code11}=   FakerLibrary.word
    Set Suite Variable    ${cupn_code11}
    clear_jaldeecoupon  ${cupn_code11}
    ${resp}=  Create Jaldee Coupon  ${cupn_code11}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  PERCENTAGE  10  100  ${bool[1]}  ${bool[1]}  100  100  1000  1  1  ${bool[1]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code11}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code11}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    # ${cid}=  get_id  ${CUSERNAME7}    
    ${coupons}=  Create List  ${cupn_code11}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id9}  ${des}  ${bool[0]}  ${coupons}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    sleep  05s
    ${resp}=   Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code11}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 
  
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id10}  ${des}  ${bool[0]}  ${coupons}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_EXCEEDS_APPLY_LIMIT}"
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code11}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 

JD-TC-GetJaldeeCouponStats -UH7
    [Documentation]   Get jaldee coupon stats by without login  
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code03}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-GetJaldeeCouponStats -UH8
    [Documentation]   Consumer Get jaldee coupon stats
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code03}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-GetJaldeeCouponStats -UH9
    [Documentation]   Another Provider Get jaldee coupon stats
    ${resp}=   Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code03}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "Coupon doesn't targented" 
    

















