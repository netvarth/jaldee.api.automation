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

*** Test Cases ***
JD-TC-GetJaldeeCoupons-1
    [Documentation]    Get jaldee coupons by superadmin login
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
    ${cupn_code1}=    FakerLibrary.word
    ${cupn_name}=    FakerLibrary.name
    Set Suite Variable    ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable    ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable    ${c_des}
    ${p_des}=    FakerLibrary.sentence
    Set Suite Variable    ${p_des}
    clear_jaldeecoupon     ${cupn_code1}
    ${resp}=  Create Jaldee Coupon  ${cupn_code1}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code01}=    FakerLibrary.word
    clear_jaldeecoupon     ${cupn_code01}
    ${resp}=  Create Jaldee Coupon  ${cupn_code01}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Contain   ${resp.json()}  "jaldeeCouponCode":"${cupn_code1}"
    # Should Contain   ${resp.json()}  "jaldeeCouponCode":"${cupn_code01}"
    Variable Should Exist   ${resp.content}  ${cupn_code1}
    Variable Should Exist   ${resp.content}  ${cupn_code01}
   
JD-TC-GetJaldeeCoupons-2
    [Documentation]    Get jaldee coupons for specific providers
    ${resp}=  ProviderLogin  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p1}=  get_acc_id  ${PUSERNAME1}
    ${p1}=  Convert To String  ${p1}
    Set Suite Variable  ${p1}
    ${resp}=  ProviderLogin  ${PUSERNAME2}  ${PASSWORD}
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
    ${cupn_code2}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code2}
    clear_jaldeecoupon    ${cupn_code2}
    ${resp}=  Create Jaldee Coupon For Providers  ${cupn_code2}  ${cupn_name}  ${cupn_des}   ${age_group[1]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[0]}  ${bool[0]}  100  250  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${pro_ids}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code3}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code3}
    clear_jaldeecoupon    ${cupn_code3}
    ${resp}=  Create Jaldee Coupon For Providers  ${cupn_code3}  ${cupn_name}  ${cupn_des}   ${age_group[1]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[0]}  ${bool[0]}  100  250  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${pro_ids}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Contain   ${resp.json()}  "jaldeeCouponCode":"${cupn_code2}"
    # Should Contain   ${resp.json()}  "jaldeeCouponCode":"${cupn_code3}"
    Variable Should Exist   ${resp.content}  ${cupn_code2}
    Variable Should Exist   ${resp.content}  ${cupn_code3}

JD-TC-GetJaldeeCoupons-3
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
    ${resp}=  Create Jaldee Coupon  XMASCoupon2020  Onam Coupon  Onam offer  CHILDREN  ${DAY1}  ${DAY2}  AMOUNT  50  100  false  false  100  1000  1000  5  2  false  false  false  false  false  consumer first use  50% offer  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log   ${resp.json()}
    ${resp}=  Get Jaldee Coupons
    Log   ${resp.json()}

    #${resp}=    Create Sample Jaldee Coupon
    Set Suite Variable   ${cupn_code}     ${resp.json()[0]['jaldeeCouponCode']}
    # Set Suite Variable   ${cupn_name}     ${resp.json()[0]['couponName']}
    # Set Suite Variable   ${cupn_des1}      ${resp.json()[0]['couponDescription']}

    # ${resp}=    Create Sample Jaldee Coupon
    # Set Suite Variable   ${cupn_code}     ${resp['jaldeeCouponCode']}
    ${resp}=  Get Jaldee Coupons
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Contain   ${resp.json()}  "jaldeeCouponCode":"${cupn_code}"
    Variable Should Exist   ${resp.content}  ${cupn_code}
   
JD-TC-GetJaldeeCoupons -UH1
    [Documentation]   Get jaldee coupons without login  
    ${resp}=  Get Jaldee Coupons
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SA_SESSION_EXPIRED}"
 
JD-TC-GetJaldeeCoupons -UH2
    [Documentation]   Consumer try to Get jaldee coupons
    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Get Jaldee Coupons
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SA_SESSION_EXPIRED}"
