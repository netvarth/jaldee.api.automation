*** Settings ***
Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      JC
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


*** Test Cases ***

JD-TC-UpdateJaldeeCoupon-1
    [Documentation]    Create a jaldee coupon by superadmin login and update all fields of coupon before push operation
    ${resp}=  Get BusinessDomainsConf
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd2}  ${resp.json()[0]['subDomains'][1]['subDomain']}
    Set Test Variable  ${sd3}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd4}  ${resp.json()[1]['subDomains'][1]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}  ${d2}
    Set Suite Variable  ${domains}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}  ${d1}_${sd2}  ${d2}_${sd3}  ${d2}_${sd4}
    Set Suite Variable  ${sub_domains}
    ${resp}=   Get Licensable Packages
    Should Be Equal As Strings   ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()[0]['pkgId']}
    Set Suite Variable  ${lic2}  ${resp.json()[1]['pkgId']}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}  ${lic2} 
    Set Suite Variable  ${licenses}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${DAY3}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY3}  ${DAY3}
    ${DAY4}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY4}  ${DAY4}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code012}=   FakerLibrary.word
    Set Suite Variable    ${cupn_code012}    
    ${cupn_name}=   FakerLibrary.name
    Set Suite Variable    ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable    ${cupn_des}
    ${c_des}=    FakerLibrary.sentence
    Set Suite Variable    ${c_des}
    ${p_des}=    FakerLibrary.sentence
    Set Suite Variable    ${p_des}
    clear_jaldeecoupon    ${cupn_code012}
    ${resp}=  Create Jaldee Coupon  ${cupn_code012}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[2]['domain']}
    Set Test Variable  ${d2}  ${resp.json()[3]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[2]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd3}  ${resp.json()[3]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd4}  ${resp.json()[3]['subDomains'][1]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}  ${d2}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}  ${d2}_${sd3}  ${d2}_${sd4}
    ${loc1}=  Jaldee Coupon Target Locations  ${longi}  ${latti}  10
    ${loc2}=  Jaldee Coupon Target Locations  ${longi1}  ${latti1}  1
    ${locations}=  Create List  ${loc1}  ${loc2}
    ${resp}=   Get Licensable Packages
    Should Be Equal As Strings   ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()[2]['pkgId']}
    Set Suite Variable  ${lic2}  ${resp.json()[3]['pkgId']}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}  ${lic2} 
    ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY2}  ${DAY4}  ${discountType[1]}  50  100  ${bool[1]}  ${bool[1]}  100  100  100  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code012}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cupn_code012}
    Should Be Equal As Strings  ${resp.json()['couponDescription']}  ${cupn_des}
    Should Be Equal As Strings  ${resp.json()['couponName']}  ${cupn_name}
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  DRAFT
    Should Be Equal As Strings  ${resp.json()['discountType']}  ${discountType[1]}
    Should Be Equal As Strings  ${resp.json()['discountValue']}  50.0
    Should Be Equal As Strings  ${resp.json()['maxDiscountValue']}  100.0
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxReimbursePercentage']}  100.0
    Should Be Equal As Strings  ${resp.json()['couponRules']['minBillAmount']}  100.0
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxProviderUseLimit']}  100
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxConsumerUseLimit']}  5
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxConsumerUseLimitPerProvider']}  2 
    Should Be Equal As Strings  ${resp.json()['couponRules']['firstCheckinOnly']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['firstCheckinPerProviderOnly']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['selfPaymentRequired']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['onlineCheckinRequired']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['combineWithOtherCoupon']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['defaultEnabled']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['alwaysEnabled']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['ageGroup']}  ${age_group[2]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['startDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['couponRules']['endDate']}  ${DAY4}
    Should Be Equal As Strings  ${resp.json()['target']['domain']}  ${domains}
    Should Be Equal As Strings  ${resp.json()['target']['subdomain']}  ${sub_domains}
    Should Be Equal As Strings  ${resp.json()['target']['licenseRequired']}  ${licenses}


JD-TC-UpdateJaldeeCoupon-UH2
    [Documentation]   Update a coupon code
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code014}=    FakerLibrary.word
    ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code014}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY3}  ${DAY4}  ${discountType[1]}  50  100  ${bool[1]}  ${bool[1]}  100  100  100  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_CODE_CANNOT_UPDATE}"




*** Comments ***
JD-TC-UpdateJaldeeCoupon-UH1
    [Documentation]   Check SA can update ‘Valid To’ field before coupons expiry date and can not update after expiry date.
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd2}  ${resp.json()[0]['subDomains'][1]['subDomain']}
    Set Test Variable  ${sd3}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd4}  ${resp.json()[1]['subDomains'][1]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}  ${d2}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}  ${d1}_${sd2}  ${d2}_${sd3}  ${d2}_${sd4}
    ${resp}=   Get Licensable Packages
    Should Be Equal As Strings   ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()[0]['pkgId']}
    Set Suite Variable  ${lic2}  ${resp.json()[1]['pkgId']}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}  ${lic2} 
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  1  
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${DAY4}=  db.add_timezone_date  ${tz}  15  
    Set Suite Variable  ${DAY4}  ${DAY4}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code013}=   FakerLibrary.word
    Set Suite Variable    ${cupn_code013}

    clear_jaldeecoupon    ${cupn_code013}
    ${resp}=  Create Jaldee Coupon  ${cupn_code013}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code013}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  DRAFT
    ${resp}=  Push Jaldee Coupon  ${cupn_code013}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code013}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ACTIVE
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Jaldee Coupon After Push   ${cupn_code013}   ${cupn_name}  ${cupn_des}  ${DAY4}  ${c_des}  ${p_des}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_EXPIRED}"
    