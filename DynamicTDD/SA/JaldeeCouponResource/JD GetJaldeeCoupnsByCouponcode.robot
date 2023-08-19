*** Settings ***
Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
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

#Suite Setup     Run Keywords  clear_jaldeecoupon  OnamCoupon2018  AND  clear_jaldeecoupon  Coupon01  AND  clear_jaldeecoupon  coupon1  AND  clear_jaldeecoupon  coupon2  AND  clear_jaldeecoupon  coupon3  AND  clear_jaldeecoupon  XMASCoupon2018
*** Variables ***
${longi}        89.524764
${latti}        88.259874
${longi1}       70.524764
${latti1}       88.259874

*** Test Cases ***

JD-TC-GetJaldeeCoupnByCouponcode-1
    [Documentation]   Get jaldee coupon by coupon code
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
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code}=   FakerLibrary.word
    Set Suite Variable    ${cupn_code}
    ${cupn_name}=   FakerLibrary.name
    Set Suite Variable    ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable    ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable    ${c_des}
    ${p_des}=   FakerLibrary.sentence
    Set Suite Variable    ${p_des}
    clear_jaldeecoupon     ${cupn_code}
    ${resp}=  Create Jaldee Coupon  ${cupn_code}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cupn_code}
    Should Be Equal As Strings  ${resp.json()['couponDescription']}  ${cupn_des}
    Should Be Equal As Strings  ${resp.json()['couponName']}  ${cupn_name}
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${couponStatus[0]}
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
    Should Be Equal As Strings  ${resp.json()['couponRules']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['target']['domain']}  ${domains}
    Should Be Equal As Strings  ${resp.json()['target']['subdomain']}  ${sub_domains}
    Should Be Equal As Strings  ${resp.json()['target']['licenseRequired']}  ${licenses}

JD-TC-GetJaldeeCoupnByCouponcode-2
    [Documentation]    Create jaldee coupon for specific providers and get it by coupon code
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
    ${cupn_code1}=    FakerLibrary.word
    clear_jaldeecoupon     ${cupn_code1}
    ${resp}=  Create Jaldee Coupon For Providers  ${cupn_code1}  ${cupn_name}  ${cupn_des}   ${age_group[1]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[0]}  ${bool[0]}  100  250  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${pro_ids}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cupn_code1}
    Should Be Equal As Strings  ${resp.json()['couponDescription']}  ${cupn_des}
    Should Be Equal As Strings  ${resp.json()['couponName']}  ${cupn_name}
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${couponStatus[0]}
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
    Should Be Equal As Strings  ${resp.json()['couponRules']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['target']['providerId']}  [${p1}, ${p2}]

JD-TC-GetJaldeeCoupnByCouponcode-3
    [Documentation]   Push a jaldee coupon and get it by coupon code
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
    ${resp}=   Get Licensable Packages
    Should Be Equal As Strings   ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()[0]['pkgId']}
    Set Suite Variable  ${lic2}  ${resp.json()[2]['pkgId']}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}  ${lic2} 
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  add_date  10
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code2}=    FakerLibrary.word
    clear_jaldeecoupon     ${cupn_code2}
    ${resp}=  Create Jaldee Coupon  ${cupn_code2}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cupn_code2}
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
    Should Be Equal As Strings  ${resp.json()['couponRules']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['target']['domain']}  ${domains}
    Should Be Equal As Strings  ${resp.json()['target']['subdomain']}  ${sub_domains}
    Should Be Equal As Strings  ${resp.json()['target']['licenseRequired']}  ${licenses}

JD-TC-GetJaldeeCoupnByCouponcode-4
    [Documentation]   Disable  a jaldee coupon and get it by coupon code
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd2}  ${resp.json()[0]['subDomains'][1]['subDomain']}
    Set Test Variable  ${sd3}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd4}  ${resp.json()[1]['subDomains'][1]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}  ${d2}
    Set Suite Variable   ${domains}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}  ${d1}_${sd2}  ${d2}_${sd3}  ${d2}_${sd4}
    Set Suite Variable   ${sub_domains}
    ${resp}=   Get Licensable Packages
    Should Be Equal As Strings   ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()[0]['pkgId']}
    Set Suite Variable  ${lic2}  ${resp.json()[2]['pkgId']}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}  ${lic2} 
    Set Suite Variable   ${licenses}
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  add_date  10
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code3}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code3}
    ${cupn_name3}=    FakerLibrary.name
    Set Suite Variable   ${cupn_name3}
    ${cupn_des4}=    FakerLibrary.sentence
    Set Suite Variable   ${cupn_des4}
    clear_jaldeecoupon     ${cupn_code3}
    
    ${resp}=  Create Jaldee Coupon  ${cupn_code3}  ${cupn_name3}  ${cupn_des4}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code3}  ${cupn_des4}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_reason}=   FakerLibrary.sentence
    Set Suite Variable   ${cupn_reason}
    ${resp}=  Disable Jaldee Coupon  ${cupn_code3}  ${cupn_reason}
    Should Be Equal As Strings  ${resp.status_code}  200
    


JD-TC-GetJaldeeCoupnByCouponcode-5
    [Documentation]    Create jaldee coupon for ALL domain, subdomain and licences
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${alldomains}=  Jaldee Coupon Target Domains  ALL
    ${allsub_domains}=  Jaldee Coupon Target SubDomains  ALL

    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    ${domains}=  Jaldee Coupon Target Domains  ALL
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ALL
    ${licenses}=  Jaldee Coupon Target License  0
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10 
    ${resp}=  Create Jaldee Coupon  XMASCoupon2019  Onam Coupon  Onam offer  CHILDREN  ${DAY1}  ${DAY2}  AMOUNT  50  100  false  false  100  1000  1000  5  2  false  false  false  false  false  consumer first use  50% offer  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log   ${resp.json()}
    ${resp}=  Get Jaldee Coupons
    Log   ${resp.json()}

    #${resp}=    Create Sample Jaldee Coupon
    Set Suite Variable   ${cupn_code}     ${resp.json()[0]['jaldeeCouponCode']}
    Set Suite Variable   ${cupn_name}     ${resp.json()[0]['couponName']}
    Set Suite Variable   ${cupn_des1}      ${resp.json()[0]['couponDescription']}

    # ${resp}=    Create Sample Jaldee Coupon
    # Set Suite Variable   ${cupn_code}     ${resp['jaldeeCouponCode']}
    # Set Suite Variable   ${cupn_name}     ${resp['couponName']}
    # Set Suite Variable   ${cupn_des1}      ${resp['couponDescription']}
    # Set Suite Variable   ${alldomains}     ${resp['domain']}
    # Set Suite Variable   ${allsub_domains}     ${resp['subdomain']}

    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cupn_code}
    Should Be Equal As Strings  ${resp.json()['couponDescription']}  ${cupn_des1}
    Should Be Equal As Strings  ${resp.json()['couponName']}  ${cupn_name}
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${couponStatus[0]}
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
    Should Be Equal As Strings  ${resp.json()['couponRules']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['target']['domain']}  ${alldomains}
    Should Be Equal As Strings  ${resp.json()['target']['subdomain']}  ${allsub_domains}
    Should Be Equal As Strings  ${resp.json()['target']['licenseRequired']}  [0]

JD-TC-GetJaldeeCoupnByCouponcode -UH1
    [Documentation]   Get jaldee coupon by code  without login
    ${cupn_code1}=    FakerLibrary.word
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code1}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SA_SESSION_EXPIRED}"
 
JD-TC-GetJaldeeCoupnByCouponcode -UH2
    [Documentation]   Consumer get jaldee coupon by code
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${cupn_code1}=    FakerLibrary.word
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code1}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SA_SESSION_EXPIRED}"

JD-TC-GetJaldeeCoupnByCouponcode -UH3
    [Documentation]  provider try to get jaldee coupon by code
    ${resp}=   ProviderLogin  ${PUSERNAME2}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${cupn_code1}=    FakerLibrary.word
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code1}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SA_SESSION_EXPIRED}"

JD-TC-Verify GetJaldeeCoupnByCouponcode-4
    [Documentation]   Disable  a jaldee coupon and get it by coupon code
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cupn_code3}
    Should Be Equal As Strings  ${resp.json()['couponDescription']}  ${cupn_des4}
    Should Be Equal As Strings  ${resp.json()['couponName']}  ${cupn_name3}
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[2]}
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
    Should Be Equal As Strings  ${resp.json()['couponRules']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['target']['domain']}  ${domains}
    Should Be Equal As Strings  ${resp.json()['target']['subdomain']}  ${sub_domains}
    Should Be Equal As Strings  ${resp.json()['target']['licenseRequired']}  ${licenses}
