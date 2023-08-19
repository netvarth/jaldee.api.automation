*** Settings ***
Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      JaldeeCoupon
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
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  add_date  10
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${DAY3}=  get_date
    Set Suite Variable  ${DAY3}  ${DAY3}
    ${DAY4}=  add_date  10
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

JD-TC-UpdateJaldeeCoupon-2
    [Documentation]    Create a jaldee coupon by superadmin login and update  fields of coupon after push operation
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
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  add_date  10
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${DAY4}=  add_date  15
    Set Suite Variable  ${DAY4}  ${DAY4}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code011}=    FakerLibrary.word
    Set Suite Variable    ${cupn_code011}
    clear_jaldeecoupon    ${cupn_code011}
    ${resp}=  Create Jaldee Coupon  ${cupn_code011}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code011}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  DRAFT
    ${resp}=  Push Jaldee Coupon  ${cupn_code011}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code011}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}
    ${resp}=  Update Jaldee Coupon After Push   ${cupn_code011}   ${cupn_name}  ${cupn_des}  ${DAY4}  ${c_des}  ${p_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code011}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cupn_code011}
    Should Be Equal As Strings  ${resp.json()['couponDescription']}  ${cupn_des}
    Should Be Equal As Strings  ${resp.json()['couponName']}  ${cupn_name}
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}
    Should Be Equal As Strings  ${resp.json()['discountType']}  ${discountType[0]}
    Should Be Equal As Strings  ${resp.json()['discountValue']}  50.0
    Should Be Equal As Strings  ${resp.json()['maxDiscountValue']}  100.0
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxReimbursePercentage']}  100.0
    Should Be Equal As Strings  ${resp.json()['couponRules']['minBillAmount']}  1000.0
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxProviderUseLimit']}  1000
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxConsumerUseLimit']}  5
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxConsumerUseLimitPerProvider']}  2 
    Should Be Equal As Strings  ${resp.json()['couponRules']['firstCheckinOnly']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['firstCheckinPerProviderOnly']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['selfPaymentRequired']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['onlineCheckinRequired']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['combineWithOtherCoupon']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['defaultEnabled']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['alwaysEnabled']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['ageGroup']}  ${age_group[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['couponRules']['endDate']}  ${DAY4}
    Should Be Equal As Strings  ${resp.json()['target']['domain']}  ${domains}
    Should Be Equal As Strings  ${resp.json()['target']['subdomain']}  ${sub_domains}
    Should Be Equal As Strings  ${resp.json()['target']['licenseRequired']}  ${licenses}

JD-TC-UpdateJaldeeCoupon-3
    [Documentation]    Create jaldee coupon for specific providers and update its values before push operations
    ${resp}=  ProviderLogin  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p1}=  get_acc_id  ${PUSERNAME1}
    ${p1}=  Convert To String  ${p1}
    Set Suite Variable  ${p1}
    ${resp}=  ProviderLogin  ${PUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p2}=  get_acc_id  ${PUSERNAME3}
    ${p2}=  Convert To String  ${p2}
    Set Suite Variable  ${p2}
    ${pro_ids}=  Create List  ${p1}  ${p2}
    Set Suite Variable  ${pro_ids}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code1}=   FakerLibrary.word
    Set Suite Variable    ${cupn_code1}
    clear_jaldeecoupon    ${cupn_code1}
    ${resp}=  Create Jaldee Coupon For Providers  ${cupn_code1}  ${cupn_name}  ${cupn_des}   ${age_group[1]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[0]}  ${bool[0]}  100  250  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${pro_ids}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogin  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p1}=  get_acc_id  ${PUSERNAME2}
    ${p1}=  Convert To String  ${p1}
    Set Suite Variable  ${p1}
    ${resp}=  ProviderLogin  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p2}=  get_acc_id  ${PUSERNAME5}
    ${p2}=  Convert To String  ${p2}
    Set Suite Variable  ${p2}
    ${pro_ids}=  Create List  ${p1}  ${p2}
    Set Suite Variable  ${pro_ids}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Jaldee Coupon For Providers  ${cupn_code1}  ${cupn_code1}  ${cupn_name}  ${cupn_des}   ${age_group[0]}  ${DAY2}  ${DAY4}  ${discountType[0]}  500  1000  ${bool[1]}  ${bool[1]}  90  2500  1000  1  1  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${pro_ids}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cupn_code1}
    Should Be Equal As Strings  ${resp.json()['couponDescription']}  ${cupn_des}
    Should Be Equal As Strings  ${resp.json()['couponName']}  ${cupn_name}
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  DRAFT
    Should Be Equal As Strings  ${resp.json()['discountType']}  ${discountType[0]}
    Should Be Equal As Strings  ${resp.json()['discountValue']}  500.0
    Should Be Equal As Strings  ${resp.json()['maxDiscountValue']}  1000.0
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxReimbursePercentage']}  90.0
    Should Be Equal As Strings  ${resp.json()['couponRules']['minBillAmount']}  2500.0
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxProviderUseLimit']}  1000
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxConsumerUseLimit']}  1
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxConsumerUseLimitPerProvider']}  1
    Should Be Equal As Strings  ${resp.json()['couponRules']['firstCheckinOnly']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['firstCheckinPerProviderOnly']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['selfPaymentRequired']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['onlineCheckinRequired']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['combineWithOtherCoupon']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['defaultEnabled']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['alwaysEnabled']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['ageGroup']}  ${age_group[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['startDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['couponRules']['endDate']}  ${DAY4}
    Should Be Equal As Strings  ${resp.json()['target']['providerId']}  [${p1}, ${p2}]

JD-TC-UpdateJaldeeCoupon-4
    [Documentation]    Create jaldee coupon for specific providers and update its values after push operations
    ${resp}=  ProviderLogin  ${PUSERNAME1}  ${PASSWORD}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p1}=  get_acc_id  ${PUSERNAME1}
    ${p1}=  Convert To String  ${p1}
    Set Suite Variable  ${p1}
    ${resp}=  ProviderLogin  ${PUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p2}=  get_acc_id  ${PUSERNAME6}
    ${p2}=  Convert To String  ${p2}
    Set Suite Variable  ${p2}
    ${pro_ids}=  Create List  ${p1}  ${p2}
    Set Suite Variable  ${pro_ids}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code2}=    FakerLibrary.Word
    Set Suite Variable     ${cupn_code2}
    clear_jaldeecoupon    ${cupn_code2}
    ${resp}=  Create Jaldee Coupon For Providers  ${cupn_code2}  ${cupn_name}  ${cupn_des}   ${age_group[1]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[0]}  ${bool[0]}  100  250  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${pro_ids}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Jaldee Coupon For Providers After Push  ${cupn_code2}  ${cupn_name}  ${cupn_des}  ${DAY4}  ${c_des}  ${p_des}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cupn_code2}
    Should Be Equal As Strings  ${resp.json()['couponDescription']}  ${cupn_des}
    Should Be Equal As Strings  ${resp.json()['couponName']}  ${cupn_name}
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}
    Should Be Equal As Strings  ${resp.json()['discountType']}  ${discountType[1]}
    Should Be Equal As Strings  ${resp.json()['discountValue']}  50.0
    Should Be Equal As Strings  ${resp.json()['maxDiscountValue']}  100.0
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxReimbursePercentage']}  100.0
    Should Be Equal As Strings  ${resp.json()['couponRules']['minBillAmount']}  250.0
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxProviderUseLimit']}  1000
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxConsumerUseLimit']}  5
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxConsumerUseLimitPerProvider']}  2
    Should Be Equal As Strings  ${resp.json()['couponRules']['firstCheckinOnly']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['firstCheckinPerProviderOnly']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['selfPaymentRequired']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['onlineCheckinRequired']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['combineWithOtherCoupon']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['defaultEnabled']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['alwaysEnabled']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['ageGroup']}  ${age_group[1]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['couponRules']['endDate']}  ${DAY4}
    Should Be Equal As Strings  ${resp.json()['target']['providerId']}  [${p1}, ${p2}]


JD-TC-UpdateJaldeeCoupon-UH3
    [Documentation]   Update a coupon with invalid coupon code
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Jaldee Coupon  invalidcoupon   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY3}  ${DAY4}  ${discountType[1]}  50  100  ${bool[1]}  ${bool[1]}  100  100  100  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_DOESNOT_EXISTS}"

JD-TC-UpdateJaldeeCoupon-UH4
    [Documentation]   Check coupon updated for valid domain
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${inavliddomains}=  Jaldee Coupon Target Domains  invaliddomain
    ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY3}  ${DAY4}  ${discountType[1]}  50  100  ${bool[1]}  ${bool[1]}  100  100  100  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${inavliddomains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "No Domain with name invaliddomain"

JD-TC-UpdateJaldeeCoupon-UH5
    [Documentation]   Check coupon updated for valid Sub_domain
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${inavlidsub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_invalidsubdomain
    ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY3}  ${DAY4}  ${discountType[1]}  50  100  ${bool[1]}  ${bool[1]}  100  100  100  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${inavlidsub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "No Sub Domain with name invalidsubdomain"

JD-TC-UpdateJaldeeCoupon-UH6
    [Documentation]   Check coupon updated for valid licenses
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${invalidlicenses}=  Jaldee Coupon Target License  20
    ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY3}  ${DAY4}  ${discountType[1]}  50  100  ${bool[1]}  ${bool[1]}  100  100  100  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${invalidlicenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "License package with id 20 does not exist in Jaldee"

JD-TC-UpdateJaldeeCoupon-UH8
    [Documentation]   Check coupon updated for valid providers
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p}=  get_id  ${CUSERNAME}
    ${pro_ids}=  Create List  ${p}
    ${cupn_code1}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code1}
    clear_jaldeecoupon     ${cupn_code1}

    ${resp}=  Update Jaldee Coupon For Providers  ${cupn_code1}  ${cupn_code1}  ${cupn_name}  ${cupn_des}   ${age_group[0]}  ${DAY2}  ${DAY4}  ${discountType[0]}  500  1000  ${bool[1]}  ${bool[1]}  90  2500  1000  1  1  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${pro_ids}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_DOESNOT_EXISTS}"

JD-TC-UpdateJaldeeCoupon-UH9
    [Documentation]   Check coupon updated for valid dates(valid from,to)
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY3}=  add_date  -2
    ${DAY4}=  add_date  -1
    ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY3}  ${DAY4}  ${discountType[1]}  50  100  ${bool[1]}  ${bool[1]}  100  100  100  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_DATES_INVALID}"

JD-TC-UpdateJaldeeCoupon-UH10
    [Documentation]   Check coupon created for valid dates(valid to date previous date than valid from date)
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY3}=  get_date
    ${DAY4}=  add_date  -1
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY3}  ${DAY4}  ${discountType[1]}  50  100  ${bool[1]}  ${bool[1]}  100  100  100  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_DATES_REQUIRED}"

JD-TC-UpdateJaldeeCoupon-UH11
    [Documentation]   Check discountValue of a created coupon is not greater than maxDiscountValue when discount type is PERCENTAGE
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY1}  ${DAY2}  ${discountType[1]}  150  100  ${bool[1]}  ${bool[1]}  100  100  100  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_DISCOUNTVALUE_NOT_VALID}"

JD-TC-UpdateJaldeeCoupon-UH12
    [Documentation]   Check when alwaysEnabled of a created coupon is true then defaultEnable is true
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[0]}  ${bool[1]}  100  100  100  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_RULES_ALWAYS_ENABLED_INVALID}"

JD-TC-UpdateJaldeeCoupon-UH13
    [Documentation]   Check when maxReimburse PERCENTAGE of a created coupon is not greater than 100
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[1]}  ${bool[1]}  200  100  200  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_RULES_MAX_REIMBURSE_INVALID}"

JD-TC-UpdateJaldeeCoupon-UH14
    [Documentation]   When create a coupon,check given subdomians are corresponding given domains
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[2]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd3}  ${resp.json()[3]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd4}  ${resp.json()[3]['subDomains'][1]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}  ${d2}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}   ${d2}_${sd3}  ${d2}_${sd4}
    ${loc1}=  Jaldee Coupon Target Locations  ${longi}  ${latti}  5
    ${loc2}=  Jaldee Coupon Target Locations  ${longi1}  ${latti1}  2
    ${locations}=  Create List  ${loc1}  ${loc2}
    ${resp}=   Get Licensable Packages
    Should Be Equal As Strings   ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()[0]['pkgId']}
    Set Suite Variable  ${lic2}  ${resp.json()[1]['pkgId']}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}  ${lic2} 
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[1]}  ${bool[1]}  100  100  100  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "No Sub Domain with name ${sd1}"

JD-TC-UpdateJaldeeCoupon-UH16
    [Documentation]   When create a coupon,if firstCheckinOnly is true then  firstCheckinPerProviderOnly should be false
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[1]}  ${bool[1]}  100  100  100  5  2  ${bool[1]}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_RULES_FIRSTCHECKIN_INVALID}"

JD-TC-UpdateJaldeeCoupon-UH17
    [Documentation]   When create a coupon,if firstCheckinOnly is true then  maxConsumerUseLimit should not be greater than 1
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[1]}  ${bool[1]}  100  100  100  5  2  ${bool[1]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_RULES_MAX_CONSUMER_USE_LIMIT_INVALID}"

JD-TC-UpdateJaldeeCoupon-UH18
    [Documentation]   When create a coupon,if firstCheckinOnly is true then  MaxUsageLimitPerProvider should not be 0
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[1]}  ${bool[1]}  100  100  100  1  0  ${bool[1]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_RULES_MAX_CONSUMER_USE_LIMIT_PER_PROVIDER_INVALID}"

JD-TC-UpdateJaldeeCoupon-5
    [Documentation]   When create a coupon,maxDiscountValue should not be greater than minBillAmount in Persentage discount type
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  1000  ${bool[1]}  ${bool[1]}  100  100  100  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code012}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cupn_code012}
    Should Be Equal As Strings  ${resp.json()['couponDescription']}  ${cupn_des}
    Should Be Equal As Strings  ${resp.json()['couponName']}  ${cupn_name}
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${couponStatus[0]}
    Should Be Equal As Strings  ${resp.json()['discountType']}  ${discountType[1]}
    Should Be Equal As Strings  ${resp.json()['discountValue']}  50.0
    Should Be Equal As Strings  ${resp.json()['maxDiscountValue']}  1000.0
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxReimbursePercentage']}  100.0
    Should Be Equal As Strings  ${resp.json()['couponRules']['minBillAmount']}  100.0
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxProviderUseLimit']}  100
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxConsumerUseLimit']}  5
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxConsumerUseLimitPerProvider']}  2

JD-TC-UpdateJaldeeCoupon -UH20
    [Documentation]   Provider create a Jaldee Coupon without login  
    ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[1]}  ${bool[1]}  100  100  100  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   "${resp.json()}"   "${SA_SESSION_EXPIRED}"

JD-TC-UpdateJaldeeCoupon -UH21
    [Documentation]   Consumer create a Jaldee Coupon
    ${resp}=   Consumer Login  ${CUSERNAME6}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[1]}  ${bool[1]}  100  100  100  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   "${resp.json()}"   "${SA_SESSION_EXPIRED}"

JD-TC-UpdateJaldeeCoupon -UH22
    [Documentation]   Consumer create a Jaldee Coupon
    ${resp}=   ProviderLogin  ${PUSERNAME2}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Update Jaldee Coupon  ${cupn_code012}   ${cupn_code012}   ${cupn_name}  ${cupn_des}  ${age_group[2]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[1]}  ${bool[1]}  100  100  100  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   "${resp.json()}"   "${SA_SESSION_EXPIRED}"


