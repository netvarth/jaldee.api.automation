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
${longi}        89.524764
${latti}        88.259874
${longi1}       70.524764
${latti1}       88.259874
${invalid_coupon}   xyz
${tz}   Asia/Kolkata


*** Test Cases ***
JD-TC-DeleteJaldeeCoupon-1
    [Documentation]    Create a jaldee coupon by superadmin login and delete before push operation(Draft coupon)
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
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code1}=   FakerLibrary.word
    Set Suite Variable  ${cupn_code1}
    ${cupn_name}=    FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=    FakerLibrary.sentence
    Set Suite Variable   ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable   ${c_des}  
    ${p_des}=    FakerLibrary.sentence
    Set Suite Variable   ${p_des}
    clear_jaldeecoupon     ${cupn_code1}
    ${resp}=  Create Jaldee Coupon  ${cupn_code1}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${c_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Delete Jaldee Coupon  ${cupn_code1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code1}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_DOESNOT_EXISTS}"
    ${resp}=  Get Jaldee Coupons
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}  "jaldeeCouponCode":"${cupn_code1}"
    # Variable Should Exist   ${resp.content}  ${cup_code}

JD-TC-DeleteJaldeeCoupon-2
    [Documentation]    Create jaldee coupon for specific providers and delete it before push operation(Draft coupon)
    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p1}=  get_acc_id  ${PUSERNAME1}
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
    clear_jaldeecoupon     ${cupn_code1}
    ${resp}=  Create Jaldee Coupon For Providers  ${cupn_code1}  ${cupn_name}  ${cupn_des}   ${age_group[1]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[0]}  ${bool[0]}  100  250  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${pro_ids}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Delete Jaldee Coupon  ${cupn_code1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code1}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_DOESNOT_EXISTS}"
    ${resp}=  Get Jaldee Coupons
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}  "jaldeeCouponCode":"${cupn_code1}"

JD-TC-DeleteJaldeeCoupon-UH1
    [Documentation]    Create a jaldee coupon by superadmin login and delete after push operation(Active coupon)
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
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code2}=   FakerLibrary.word
    clear_jaldeecoupon    ${cupn_code2}
    ${resp}=  Create Jaldee Coupon  ${cupn_code2}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}
    ${resp}=  Delete Jaldee Coupon  ${cupn_code2}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_DRAFT_DOESNOT_EXISTS}"
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}

JD-TC-DeleteJaldeeCoupon-UH2
    [Documentation]    Create jaldee coupon for specific providers and delete it after push operation(Active coupon)
    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p1}=  get_acc_id  ${PUSERNAME3}
    ${p1}=  Convert To String  ${p1}
    Set Suite Variable  ${p1}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p2}=  get_acc_id  ${PUSERNAME4}
    ${p2}=  Convert To String  ${p2}
    Set Suite Variable  ${p2}
    ${pro_ids}=  Create List  ${p1}  ${p2}
    Set Suite Variable  ${pro_ids}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code3}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code3}
    clear_jaldeecoupon     ${cupn_code3}
    ${resp}=  Create Jaldee Coupon For Providers  ${cupn_code3}  ${cupn_name}  ${cupn_des}   ${age_group[1]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[0]}  ${bool[0]}  100  250  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${pro_ids}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code3}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}
    ${resp}=  Delete Jaldee Coupon  ${cupn_code3}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_DRAFT_DOESNOT_EXISTS}"
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}

JD-TC-DeleteJaldeeCoupon-UH3
    [Documentation]    Superadmin trying to delete a invalid coupon
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    #${invalid_coupon}=   FakerLibrary.word
    #Set Suite Variable    ${invalid_coupon}
    ${resp}=  Delete Jaldee Coupon  ${invalid_coupon}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_DRAFT_DOESNOT_EXISTS}"

JD-TC-DeleteJaldeeCoupon-UH4
    [Documentation]    Superadmin trying to delete a icoupon which is already deleted
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Delete Jaldee Coupon  ${cupn_code1}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_DRAFT_DOESNOT_EXISTS}"

JD-TC-DeleteJaldeeCoupon -UH5
    [Documentation]   Provider create a Jaldee Coupon without login  
    ${resp}=  Delete Jaldee Coupon  ${cupn_code3}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SA_SESSION_EXPIRED}"

JD-TC-DeleteJaldeeCoupon -UH6
    [Documentation]   Consumer create a Jaldee Coupon
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Delete Jaldee Coupon  ${cupn_code3}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SA_SESSION_EXPIRED}"

JD-TC-DeleteJaldeeCoupon -UH7
    [Documentation]   Consumer create a Jaldee Coupon
    ${resp}=   Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Delete Jaldee Coupon  ${cupn_code3}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SA_SESSION_EXPIRED}"

