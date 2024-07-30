*** Settings ***
Suite Teardown    Delete All Sessions
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
${tz}   Asia/Kolkata


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


*** Test Cases ***
JD-TC-CreateJaldeeCoupon-1
    [Documentation]    Create a jaldee coupon by superadmin login   

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
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200       
    ${cup_code}=   FakerLibrary.word
    Set Suite Variable   ${cup_code}
    ${cup_name}=    FakerLibrary.name
    Set Suite Variable   ${cup_name}
    ${cup_des}=    FakerLibrary.sentence
    Set Suite Variable   ${cup_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable   ${c_des}  
    ${p_des}=    FakerLibrary.sentence
    Set Suite Variable   ${p_des}
    clear_jaldeecoupon     ${cup_code}
    ${resp}=  Create Jaldee Coupon  ${cup_code}  ${cup_name}  ${cup_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cup_code}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cup_code}
    Should Be Equal As Strings  ${resp.json()['couponDescription']}  ${cup_des}
    Should Be Equal As Strings  ${resp.json()['couponName']}  ${cup_name}
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


JD-TC-CreateJaldeeCoupon-2
    [Documentation]    Create more jaldee coupon by superadmin login
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[2]['domain']}
    Set Test Variable  ${d2}  ${resp.json()[3]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[2]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd2}  ${resp.json()[3]['subDomains'][1]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}  ${d2}
    Set Suite Variable  ${domains}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}  ${d2}_${sd2}
    Set Suite Variable  ${sub_domains}
    ${longi}=  get_longitude
    Set Suite Variable   ${longi}
    ${latti}=  get_latitude
    Set Suite Variable   ${latti}
    ${longi1}=  get_longitude
    Set Suite Variable   ${longi1}
    ${latti1}=  get_latitude
    Set Suite Variable   ${latti1}
    ${loc1}=  Jaldee Coupon Target Locations  ${longi}  ${latti}  5
    ${loc2}=  Jaldee Coupon Target Locations  ${longi1}  ${latti1}  2
    ${locations}=  Create List  ${loc1}  ${loc2}
    Set Suite Variable  ${locations}
    ${resp}=   Get Licensable Packages
    Should Be Equal As Strings   ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()[2]['pkgId']}
    Set Suite Variable  ${lic2}  ${resp.json()[3]['pkgId']}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}  ${lic2}
    Set Suite Variable  ${licenses}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${cup_code1}=   FakerLibrary.word
    Set Suite Variable   ${cup_code1}
    clear_jaldeecoupon     ${cup_code1}
    ${resp}=  Create Jaldee Coupon  ${cup_code1}  ${cup_name}  ${cup_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Contain  "${resp.json()}"  "jaldeeCouponCode":"${cup_code}"
    # Should Contain  ${resp.json()}   jaldeeCouponCode:${cup_code1}
    Variable Should Exist   ${resp.content}  ${cup_code}

JD-TC-CreateJaldeeCoupon-3
    [Documentation]    Create jaldee coupon for specific providers
    ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p1}=  get_acc_id  ${PUSERNAME4}
    ${p1}=  Convert To String  ${p1}
    Set Suite Variable  ${p1}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p2}=  get_acc_id  ${PUSERNAME2}
    ${p2}=  Convert To String  ${p2}
    Set Suite Variable  ${p2}
    ${pro_ids}=  Create List  ${p1}  ${p2}
    Set Suite Variable  ${pro_ids}    
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${cup_code2}=   FakerLibrary.word
    Set Suite Variable  ${cup_code2}
    ${cup_name2}=   FakerLibrary.name
    Set Suite Variable  ${cup_name2}
    ${cup_desp2}=   FakerLibrary.sentence
    Set Suite Variable  ${cup_desp2}
    clear_jaldeecoupon     ${cup_code2}
    ${resp}=  Create Jaldee Coupon For Providers  ${cup_code2}  ${cup_name2}  ${cup_desp2}   ${age_group[1]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[0]}  ${bool[0]}  100  250  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${pro_ids}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cup_code2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cup_code2}
    Should Be Equal As Strings  ${resp.json()['couponDescription']}  ${cup_desp2}
    Should Be Equal As Strings  ${resp.json()['couponName']}  ${cup_name2}
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
    Should Be Equal As Strings  ${resp.json()['couponRules']['ageGroup']}   ${age_group[1]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['couponRules']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['target']['providerId']}  [${p1}, ${p2}]
    
JD-TC-CreateJaldeeCoupon-4
    [Documentation]    Create jaldee coupon for ALL domain, subdomain and licences
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${alldomains}=  Jaldee Coupon Target Domains  ALL
    ${allsub_domains}=  Jaldee Coupon Target SubDomains  ALL
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    ${domains}=  Jaldee Coupon Target Domains  ALL
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ALL
    ${licenses}=  Jaldee Coupon Target License  0
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10   
    ${resp}=  Create Jaldee Coupon  XMASCoupn2020  Onam1 Coupon  Onam offer  CHILDREN  ${DAY1}  ${DAY2}  AMOUNT  50  100  false  false  100  1000  1000  5  2  false  false  false  false  false  consumer first use  50% offer  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log   ${resp.json()}
    ${resp}=  Get Jaldee Coupons
     Log   ${resp.json()}
    Set Suite Variable   ${cupn_code}     ${resp.json()[0]['jaldeeCouponCode']}
    Set Suite Variable   ${cupn_name}     ${resp.json()[0]['couponName']}
    Set Suite Variable   ${cupn_des}      ${resp.json()[0]['couponDescription']}
    #Set Suite Variable   ${domains}     ${resp['domains']}
    #Set Suite Variable   ${sub_domains}     ${resp['sub_domains']}    
    ${resp}=  Get Jaldee Coupon By CouponCode   ${cupn_code}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cupn_code}
    Should Be Equal As Strings  ${resp.json()['couponDescription']}  ${cupn_des}
    Should Be Equal As Strings  ${resp.json()['couponName']}  ${cupn_name}
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${couponStatus[0]}
    Should Be Equal As Strings  ${resp.json()['discountType']}   ${discountType[0]}
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

    
JD-TC-CreateJaldeeCoupon-5

    [Documentation]    Create jaldee coupon with target date details.
    
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
   
    ${resp}=   Get Licensable Packages
    Should Be Equal As Strings   ${resp.status_code}   200
    Set Test Variable  ${licid}  ${resp.json()[0]['pkgId']}

    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    ${licenses}=  Jaldee Coupon Target License  ${licid}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cupn_code2021}=   FakerLibrary.word
    ${cupn_name}=    FakerLibrary.name
    ${cupn_des}=   FakerLibrary.sentence
    ${c_des}=   FakerLibrary.sentence
    ${p_des}=    FakerLibrary.sentence
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  0  45  
    ${time}=  Create Dictionary  sTime=${sTime1}  eTime=${eTime1}
    ${timeslot}=  Create List  ${time}
    ${terminator}=  Create Dictionary  endDate=${DAY2}  noOfOccurance=${EMPTY}
    ${targetDate}=  Create Dictionary  startDate=${DAY1}   timeSlots=${timeslot}  terminator=${terminator}  recurringType=${recurringtype[1]}   repeatIntervals=${list}
    ${targetDate}=  Create List   ${targetDate}

    clear_jaldeecoupon  ${cupn_code2021}
    ${resp}=  Create Jaldee Coupon  ${cupn_code2021}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  0  100  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}  targetDate=${targetDate}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2021}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}                                             ${cupn_code2021}
    Should Be Equal As Strings  ${resp.json()['couponDescription']}                                            ${cupn_des}
    Should Be Equal As Strings  ${resp.json()['couponName']}                                                   ${cupn_name}
    Should Be Equal As Strings  ${resp.json()['couponStatus']}                                                 ${couponStatus[0]}
    Should Be Equal As Strings  ${resp.json()['discountType']}                                                 ${discountType[0]}
    Should Be Equal As Strings  ${resp.json()['discountValue']}                                                50.0
    Should Be Equal As Strings  ${resp.json()['maxDiscountValue']}                                             100.0
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxReimbursePercentage']}                        0.0
    Should Be Equal As Strings  ${resp.json()['couponRules']['minBillAmount']}                                 100.0
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxProviderUseLimit']}                           1000
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxConsumerUseLimit']}                           5
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxConsumerUseLimitPerProvider']}                2 
    Should Be Equal As Strings  ${resp.json()['couponRules']['firstCheckinOnly']}                              ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['firstCheckinPerProviderOnly']}                   ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['selfPaymentRequired']}                           ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['onlineCheckinRequired']}                         ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['combineWithOtherCoupon']}                        ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['defaultEnabled']}                                ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['alwaysEnabled']}                                 ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['ageGroup']}                                      ${age_group[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['startDate']}                                     ${DAY1}
    Should Be Equal As Strings  ${resp.json()['couponRules']['endDate']}                                       ${DAY2}
    Should Be Equal As Strings  ${resp.json()['couponRules']['targetDate'][0]['startDate']}                    ${DAY1}
    Should Be Equal As Strings  ${resp.json()['couponRules']['targetDate'][0]['timeSlots'][0]['sTime']}        ${sTime1}
    Should Be Equal As Strings  ${resp.json()['couponRules']['targetDate'][0]['timeSlots'][0]['eTime']}        ${eTime1}
    Should Be Equal As Strings  ${resp.json()['couponRules']['targetDate'][0]['terminator']['endDate']}        ${DAY2}
    Should Be Equal As Strings  ${resp.json()['couponRules']['targetDate'][0]['terminator']['noOfOccurance']}  0
    Should Be Equal As Strings  ${resp.json()['couponRules']['targetDate'][0]['recurringType']}                ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['targetDate'][0]['repeatIntervals']}              ${list}
    Should Be Equal As Strings  ${resp.json()['target']['domain']}                                             ${domains}
    Should Be Equal As Strings  ${resp.json()['target']['subdomain']}                                          ${sub_domains}
    Should Be Equal As Strings  ${resp.json()['target']['licenseRequired']}                                    ${licenses}

    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateJaldeeCoupon-6

    [Documentation]    Create jaldee coupon with target date details with different end date .
    
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
   
    ${resp}=   Get Licensable Packages
    Should Be Equal As Strings   ${resp.status_code}   200
    Set Test Variable  ${licid}  ${resp.json()[0]['pkgId']}

    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    ${licenses}=  Jaldee Coupon Target License  ${licid}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cupn_code2021}=   FakerLibrary.word
    ${cupn_name}=    FakerLibrary.name
    ${cupn_des}=   FakerLibrary.sentence
    ${c_des}=   FakerLibrary.sentence
    ${p_des}=    FakerLibrary.sentence
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${END_DAY}=  db.add_timezone_date  ${tz}  11
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  0  45  
    ${time}=  Create Dictionary  sTime=${sTime1}  eTime=${eTime1}
    ${timeslot}=  Create List  ${time}
    ${terminator}=  Create Dictionary  endDate=${END_DAY}  noOfOccurance=${EMPTY}
    ${targetDate}=  Create Dictionary  startDate=${DAY1}   timeSlots=${timeslot}  terminator=${terminator}  recurringType=${recurringtype[1]}   repeatIntervals=${list}
    ${targetDate}=  Create List   ${targetDate}

    clear_jaldeecoupon  ${cupn_code2021}
    ${resp}=  Create Jaldee Coupon  ${cupn_code2021}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  0  100  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}  targetDate=${targetDate}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2021}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}                                             ${cupn_code2021}
    Should Be Equal As Strings  ${resp.json()['couponDescription']}                                            ${cupn_des}
    Should Be Equal As Strings  ${resp.json()['couponName']}                                                   ${cupn_name}
    Should Be Equal As Strings  ${resp.json()['couponStatus']}                                                 ${couponStatus[0]}
    Should Be Equal As Strings  ${resp.json()['discountType']}                                                 ${discountType[0]}
    Should Be Equal As Strings  ${resp.json()['discountValue']}                                                50.0
    Should Be Equal As Strings  ${resp.json()['maxDiscountValue']}                                             100.0
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxReimbursePercentage']}                        0.0
    Should Be Equal As Strings  ${resp.json()['couponRules']['minBillAmount']}                                 100.0
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxProviderUseLimit']}                           1000
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxConsumerUseLimit']}                           5
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxConsumerUseLimitPerProvider']}                2 
    Should Be Equal As Strings  ${resp.json()['couponRules']['firstCheckinOnly']}                              ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['firstCheckinPerProviderOnly']}                   ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['selfPaymentRequired']}                           ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['onlineCheckinRequired']}                         ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['combineWithOtherCoupon']}                        ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['defaultEnabled']}                                ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['alwaysEnabled']}                                 ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['ageGroup']}                                      ${age_group[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['startDate']}                                     ${DAY1}
    Should Be Equal As Strings  ${resp.json()['couponRules']['endDate']}                                       ${DAY2}
    Should Be Equal As Strings  ${resp.json()['couponRules']['targetDate'][0]['startDate']}                    ${DAY1}
    Should Be Equal As Strings  ${resp.json()['couponRules']['targetDate'][0]['timeSlots'][0]['sTime']}        ${sTime1}
    Should Be Equal As Strings  ${resp.json()['couponRules']['targetDate'][0]['timeSlots'][0]['eTime']}        ${eTime1}
    Should Be Equal As Strings  ${resp.json()['couponRules']['targetDate'][0]['terminator']['endDate']}        ${END_DAY}
    Should Be Equal As Strings  ${resp.json()['couponRules']['targetDate'][0]['terminator']['noOfOccurance']}  0
    Should Be Equal As Strings  ${resp.json()['couponRules']['targetDate'][0]['recurringType']}                ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['targetDate'][0]['repeatIntervals']}              ${list}
    Should Be Equal As Strings  ${resp.json()['target']['domain']}                                             ${domains}
    Should Be Equal As Strings  ${resp.json()['target']['subdomain']}                                          ${sub_domains}
    Should Be Equal As Strings  ${resp.json()['target']['licenseRequired']}                                    ${licenses}


JD-TC-CreateJaldeeCoupon-7

    [Documentation]    Create jaldee coupon with target date details without start date and end date.
    
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
   
    ${resp}=   Get Licensable Packages
    Should Be Equal As Strings   ${resp.status_code}   200
    Set Test Variable  ${licid}  ${resp.json()[0]['pkgId']}

    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    ${licenses}=  Jaldee Coupon Target License  ${licid}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cupn_code2021}=   FakerLibrary.word
    ${cupn_name}=    FakerLibrary.name
    ${cupn_des}=   FakerLibrary.sentence
    ${c_des}=   FakerLibrary.sentence
    ${p_des}=    FakerLibrary.sentence
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  0  45  
    ${time}=  Create Dictionary  sTime=${sTime1}  eTime=${eTime1}
    ${timeslot}=  Create List  ${time}
    ${terminator}=  Create Dictionary  endDate=${EMPTY}  noOfOccurance=${EMPTY}
    ${targetDate}=  Create Dictionary  startDate=${EMPTY}   timeSlots=${timeslot}  terminator=${terminator}  recurringType=${recurringtype[1]}   repeatIntervals=${list}
    ${targetDate}=  Create List   ${targetDate}

    clear_jaldeecoupon  ${cupn_code2021}
    ${resp}=  Create Jaldee Coupon  ${cupn_code2021}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  0  100  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}  targetDate=${targetDate}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2021}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}                                             ${cupn_code2021}
    Should Be Equal As Strings  ${resp.json()['couponDescription']}                                            ${cupn_des}
    Should Be Equal As Strings  ${resp.json()['couponName']}                                                   ${cupn_name}
    Should Be Equal As Strings  ${resp.json()['couponStatus']}                                                 ${couponStatus[0]}
    Should Be Equal As Strings  ${resp.json()['discountType']}                                                 ${discountType[0]}
    Should Be Equal As Strings  ${resp.json()['discountValue']}                                                50.0
    Should Be Equal As Strings  ${resp.json()['maxDiscountValue']}                                             100.0
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxReimbursePercentage']}                        0.0
    Should Be Equal As Strings  ${resp.json()['couponRules']['minBillAmount']}                                 100.0
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxProviderUseLimit']}                           1000
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxConsumerUseLimit']}                           5
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxConsumerUseLimitPerProvider']}                2 
    Should Be Equal As Strings  ${resp.json()['couponRules']['firstCheckinOnly']}                              ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['firstCheckinPerProviderOnly']}                   ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['selfPaymentRequired']}                           ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['onlineCheckinRequired']}                         ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['combineWithOtherCoupon']}                        ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['defaultEnabled']}                                ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['alwaysEnabled']}                                 ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['ageGroup']}                                      ${age_group[0]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['startDate']}                                     ${DAY1}
    Should Be Equal As Strings  ${resp.json()['couponRules']['endDate']}                                       ${DAY2}
    Should Be Equal As Strings  ${resp.json()['couponRules']['targetDate'][0]['startDate']}                    ${DAY1}
    Should Be Equal As Strings  ${resp.json()['couponRules']['targetDate'][0]['timeSlots'][0]['sTime']}        ${sTime1}
    Should Be Equal As Strings  ${resp.json()['couponRules']['targetDate'][0]['timeSlots'][0]['eTime']}        ${eTime1}
    Should Be Equal As Strings  ${resp.json()['couponRules']['targetDate'][0]['terminator']['endDate']}        ${DAY2}
    Should Be Equal As Strings  ${resp.json()['couponRules']['targetDate'][0]['terminator']['noOfOccurance']}  0
    Should Be Equal As Strings  ${resp.json()['couponRules']['targetDate'][0]['recurringType']}                ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['targetDate'][0]['repeatIntervals']}              ${list}
    Should Be Equal As Strings  ${resp.json()['target']['domain']}                                             ${domains}
    Should Be Equal As Strings  ${resp.json()['target']['subdomain']}                                          ${sub_domains}
    Should Be Equal As Strings  ${resp.json()['target']['licenseRequired']}                                    ${licenses}
    
JD-TC-CreateJaldeeCoupon-UH1
    [Documentation]   Create a coupon which is already created coupon code for specific provider
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Jaldee Coupon For Providers  ${cup_code1}  ${cupn_name}  ${cupn_des}   ${age_group[1]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[0]}  ${bool[0]}  100  250  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}   ${p_des}   ${pro_ids}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_ALREADY_EXISTS}"

JD-TC-CreateJaldeeCoupon-UH2
    [Documentation]   Create a coupon which is already created coupon code
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${resp}=  Create Jaldee Coupon  ${cup_code1}   ${cupn_name}   ${cupn_des} 	${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}   ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_ALREADY_EXISTS}"

JD-TC-CreateJaldeeCoupon-UH3
    [Documentation]   Create a coupon without coupon code
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${resp}=  Create Jaldee Coupon  ${EMPTY}  ${cupn_name} 	${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}   ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_CODE_REQUIRED}"

JD-TC-CreateJaldeeCoupon-UH4
    [Documentation]   Create a coupon without coupon name
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${resp}=  Create Jaldee Coupon  ${cup_code2}  ${EMPTY}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}   ${p_des}   ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_NAME_REQUIRED}"

JD-TC-CreateJaldeeCoupon-UH5
    [Documentation]   Check coupon created for valid domain
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${inavliddomains}=  Jaldee Coupon Target Domains  invaliddomain
    ${cupn_code3}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code3}    
    ${resp}=  Create Jaldee Coupon  ${cupn_code3}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}   ${p_des}  ${inavliddomains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "No Domain with name invaliddomain"

JD-TC-CreateJaldeeCoupon-UH6
    [Documentation]   Check coupon created for valid Sub_domain
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${inavlidsub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_invalidsubdomain
    ${cupn_code4}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code4}
    ${resp}=  Create Jaldee Coupon  ${cupn_code4}  ${cupn_name}   ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}   ${p_des}  ${domains}  ${inavlidsub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "No Sub Domain with name invalidsubdomain"

JD-TC-CreateJaldeeCoupon-UH7
    [Documentation]   Check coupon created for valid licenses
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${invalidlicenses}=  Jaldee Coupon Target License  20
    ${cupn_code5}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code5}
    ${resp}=  Create Jaldee Coupon  ${cupn_code5}  ${cupn_name}   ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}   ${p_des}  ${domains}  ${sub_domains}  ALL  ${invalidlicenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "License package with id 20 does not exist in Jaldee"

JD-TC-CreateJaldeeCoupon-UH8
    [Documentation]   Check coupon created for valid providers
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p}=  get_id  ${CUSERNAME}
    ${pro_ids}=  Create List  ${p}
    ${cupn_code002}=   FakerLibrary.word
    ${resp}=  Create Jaldee Coupon For Providers  ${cupn_code002}  ${cupn_name}  ${cupn_des}   ${age_group[1]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[0]}  ${bool[0]}  100  250  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}   ${p_des}  ${pro_ids}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "Provider with id ${p} does not exist in Jaldee"

JD-TC-CreateJaldeeCoupon-UH9
    [Documentation]   Check coupon created for valid dates(previous dates)
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY3}=  db.add_timezone_date  ${tz}  -2
    ${DAY4}=  db.add_timezone_date  ${tz}  -1
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${cupn_code7}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code7}
    ${resp}=  Create Jaldee Coupon  ${cupn_code7}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY3}  ${DAY4}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_DATES_INVALID}"

JD-TC-CreateJaldeeCoupon-UH10
    [Documentation]   Check coupon created for valid dates(valid to date previous date than valid from date)
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY3}=  db.get_date_by_timezone  ${tz}
    ${DAY4}=  db.add_timezone_date  ${tz}  -1
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${cupn_code8}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code8}
    ${resp}=  Create Jaldee Coupon  ${cupn_code8}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY3}  ${DAY4}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[1]}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_DATES_REQUIRED}"

JD-TC-CreateJaldeeCoupon-UH11
    [Documentation]   Check discountValue of a created coupon is not greater than maxDiscountValue when discount type is PERCENTAGE
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code9}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code9}
    ${resp}=  Create Jaldee Coupon  ${cupn_code9}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[1]}  150  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_DISCOUNTVALUE_NOT_VALID}"

JD-TC-CreateJaldeeCoupon-UH12
    [Documentation]   Check when alwaysEnabled of a created coupon is true then defaultEnable is true
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code100}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code100}
    ${resp}=  Create Jaldee Coupon  ${cupn_code100}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  true  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_RULES_ALWAYS_ENABLED_INVALID}"

JD-TC-CreateJaldeeCoupon-UH13
    [Documentation]   Check when maxReimburse PERCENTAGE of a created coupon is not greater than 100
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code101}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code101}
    ${resp}=  Create Jaldee Coupon  ${cupn_code101}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  200  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_RULES_MAX_REIMBURSE_INVALID}"

JD-TC-CreateJaldeeCoupon-UH14
    [Documentation]   Check jaldee coupon created only for providers whose must have business profile
    ${p2}=  get_id  ${PUSERNAME}
    ${pro_ids}=  Create List  ${p2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code003}=   FakerLibrary.word
    ${resp}=  Create Jaldee Coupon For Providers  ${cupn_code003}  ${cupn_name}  ${cupn_des}   ${age_group[1]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[0]}  ${bool[0]}  100  250  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${pro_ids}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "Provider with id ${p2} does not exist in Jaldee"

JD-TC-CreateJaldeeCoupon-UH15
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
    ${cupn_code102}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code102}
    ${resp}=  Create Jaldee Coupon   ${cupn_code102}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "No Sub Domain with name ${sd1}"

JD-TC-CreateJaldeeCoupon-UH16
    [Documentation]   When create a coupon,if firstCheckinOnly is true then  firstCheckinPerProviderOnly should be false
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd3}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}  ${d2}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}   ${d2}_${sd3}
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
    ${cupn_code103}=   FakerLibrary.word
    ${resp}=  Create Jaldee Coupon  ${cupn_code103}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[1]}  ${bool[1]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_RULES_FIRSTCHECKIN_INVALID}"

JD-TC-CreateJaldeeCoupon-UH17
    [Documentation]   When create a coupon,if firstCheckinOnly is true then  maxConsumerUseLimit should not be greater than 1
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd3}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}  ${d2}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}   ${d2}_${sd3}
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
    ${cupn_code104}=   FakerLibrary.word
    ${resp}=  Create Jaldee Coupon  ${cupn_code104}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  0  ${bool[1]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_RULES_MAX_CONSUMER_USE_LIMIT_INVALID}"

JD-TC-CreateJaldeeCoupon-UH18
    [Documentation]   When create a coupon,if firstCheckinOnly is true then  MaxUsageLimitPerProvider should not be 0
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd3}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}  ${d2}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}   ${d2}_${sd3}
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
    ${cupn_code105}=   FakerLibrary.word
    ${resp}=  Create Jaldee Coupon  ${cupn_code105}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  1  0  ${bool[1]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_RULES_MAX_CONSUMER_USE_LIMIT_PER_PROVIDER_INVALID}"

JD-TC-CreateJaldeeCoupon-UH19
    [Documentation]   When create a coupon,maxDiscountValue should be greater than minBillAmount
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd3}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}  ${d2}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}   ${d2}_${sd3}
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
    ${cupn_code106}=   FakerLibrary.word
    ${resp}=  Create Jaldee Coupon  ${cupn_code106}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  1000  ${bool[0]}  ${bool[0]}  100  100  1000  1  10  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_MIN_BILL_AMT_INVALID}"

JD-TC-CreateJaldeeCoupon -UH20
    [Documentation]   Provider create a Jaldee Coupon without login  
    ${resp}=  Create Jaldee Coupon  ${cupn_code101}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  200  1000  1000  5  2  ${bool[1]}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   "${resp.json()}"   "${SA_SESSION_EXPIRED}"

JD-TC-CreateJaldeeCoupon -UH21
    [Documentation]   Consumer create a Jaldee Coupon
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Create Jaldee Coupon  ${cupn_code101}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  200  1000  1000  5  2  ${bool[1]}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   "${resp.json()}"   "${SA_SESSION_EXPIRED}"

JD-TC-CreateJaldeeCoupon -UH22
    [Documentation]   Provider create a Jaldee Coupon
    ${resp}=   Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Create Jaldee Coupon  ${cupn_code101}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  200  1000  1000  5  2  ${bool[1]}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   "${resp.json()}"   "${SA_SESSION_EXPIRED}"

JD-TC-CreateJaldeeCoupon-UH23
    [Documentation]   Check when DiscountValue of PERCENTAGE type of a created coupon is not greater than 100
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code13}=   FakerLibrary.word
    ${resp}=  Create Jaldee Coupon  ${cupn_code13}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[1]}  200  250  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_DISCOUNTVALUE_NOT_VALID}"

JD-TC-CreateJaldeeCoupon-UH24
    [Documentation]   Check  maxDiscountValue is 0  when discount type is Fixed
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code9}=   FakerLibrary.word
    ${resp}=  Create Jaldee Coupon  ${cupn_code9}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  150  0  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_MAX_DISCOUNTVALUE_NOT_ZERO}"

JD-TC-CreateJaldeeCoupon-UH25
    [Documentation]   Check  maxDiscountValue is 0  when discount type is Percentage
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code10}=   FakerLibrary.word
    ${resp}=  Create Jaldee Coupon  ${cupn_code10}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[1]}  90  0  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_MAX_DISCOUNTVALUE_NOT_ZERO}"

JD-TC-CreateJaldeeCoupon-UH26
    [Documentation]   Check  DiscountValue is 0  when discount type is Percentage
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code11}=   FakerLibrary.word
    ${resp}=  Create Jaldee Coupon  ${cupn_code11}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[1]}  0  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_DISCOUNTVALUE_NOT_ZERO}"

JD-TC-CreateJaldeeCoupon-UH27
    [Documentation]   Check  DiscountValue is 0  when discount type is Fixed
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code12}=   FakerLibrary.word
    ${resp}=  Create Jaldee Coupon  ${cupn_code12}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  0  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_DISCOUNTVALUE_NOT_ZERO}"

JD-TC-CreateJaldeeCoupon-UH28
    [Documentation]   Check  maxProviderUseLimit is 0  when discount type is Fixed
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code14}=   FakerLibrary.word
    ${resp}=  Create Jaldee Coupon  ${cupn_code14}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  0  0  0  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_MAX_PROVIDER_USE_LIMIT}"

JD-TC-CreateJaldeeCoupon-UH29
    [Documentation]   Check when maxProviderUseLimit of PERCENTAGE type of a created coupon is not greater be 0
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code15}=   FakerLibrary.word
    ${resp}=  Create Jaldee Coupon  ${cupn_code15}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[1]}  100  250  ${bool[0]}  ${bool[0]}  100  1000  0  0  0  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_MAX_PROVIDER_USE_LIMIT}"

JD-TC-CreateJaldeeCoupon-UH30
    [Documentation]   Check  maxConsumerUseLimit is 0  when discount type is Fixed
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code16}=   FakerLibrary.word
    ${resp}=  Create Jaldee Coupon  ${cupn_code16}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  10  0  0  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_MAX_CONSUMER_USE_LIMIT}"

JD-TC-CreateJaldeeCoupon-UH31
    [Documentation]   Check when maxConsumerUseLimit of PERCENTAGE type of a created coupon is not greater be 0
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code17}=   FakerLibrary.word
    ${resp}=  Create Jaldee Coupon  ${cupn_code17}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[1]}  100  250  ${bool[0]}  ${bool[0]}  100  1000  20  0  0  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_MAX_CONSUMER_USE_LIMIT}"

JD-TC-CreateJaldeeCoupon-UH32
    [Documentation]   Check  maxConsumerUseLimitPerProvider is 0  when discount type is Fixed
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code18}=   FakerLibrary.word
    ${resp}=  Create Jaldee Coupon  ${cupn_code18}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  10  5  0  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_MAX_CONSUMER_USE_LIMIT_PER_PROVIDER}"

JD-TC-CreateJaldeeCoupon-UH33
    [Documentation]   Check when maxConsumerUseLimitPerProvider of PERCENTAGE type of a created coupon is not greater be 0
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code19}=   FakerLibrary.word
    ${resp}=  Create Jaldee Coupon  ${cupn_code19}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[1]}  100  250  ${bool[0]}  ${bool[0]}  100  1000  20  5  0  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_MAX_CONSUMER_USE_LIMIT_PER_PROVIDER}"

JD-TC-CreateJaldeeCoupon-UH34
    [Documentation]   Check when maxConsumerUseLimitPerProvider of PERCENTAGE type of a created coupon is not greater than maxConsumerUseLimit
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code20}=   FakerLibrary.word
    ${resp}=  Create Jaldee Coupon  ${cupn_code20}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[1]}  100  250  ${bool[0]}  ${bool[0]}  100  1000  20  5  6  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_CONSUMERLIMIT_PER_PROVIDER_INVALID}"

JD-TC-CreateJaldeeCoupon-UH35
    [Documentation]   Check when maxConsumerUseLimitPerProvider of Fixed type of a created coupon is not greater than maxConsumerUseLimit
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code21}=   FakerLibrary.word
    ${resp}=  Create Jaldee Coupon  ${cupn_code21}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  10  5  14  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_CONSUMERLIMIT_PER_PROVIDER_INVALID}"

*** Comments ***
JD-TC-CreateJaldeeCoupon-UH3
    [Documentation]   Create a coupon which is already created coupon name
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Jaldee Coupon  ${cupn_code}  ${cup_code2}  ${cupn_des}  ${age_group[2]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[0]}  ${bool[0]}  100  500  1000  5  2  true  true  ${bool[0]}  true  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ${locations}  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_ALREADY_EXISTS}"