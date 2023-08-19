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

JD-TC-DisableJaldeeCoupon-1
    [Documentation]    Create a jaldee coupon by superadmin login and disable after push operation(Active coupon)
    ${resp}=   ProviderLogin  ${PUSERNAME69}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${d1}    ${resp.json()['sector']}
    Set Suite Variable  ${sd1}    ${resp.json()['subSector']}
    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    #Set Suite Variable  ${d1}  ${resp.json()[0]['domain']}
    #Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    #Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    #Set Test Variable  ${sd2}  ${resp.json()[0]['subDomains'][1]['subDomain']}
    #Set Test Variable  ${sd3}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    #Set Test Variable  ${sd4}  ${resp.json()[1]['subDomains'][1]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  add_date  10
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
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

    ${resp}=  Create Jaldee Coupon  ${cupn_code1}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code1}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   ProviderLogin  ${PUSERNAME69}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()['couponState']}   ${couponState[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code1}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_reason}=   FakerLibrary.sentence
    Set Suite Variable   ${cupn_reason}
    ${resp}=  Disable Jaldee Coupon  ${cupn_code1}  ${cupn_reason}
    Should Be Equal As Strings  ${resp.status_code}  200
    

JD-TC-DisableJaldeeCoupon-2
    [Documentation]    Create jaldee coupon for specific providers and disable it after push operation(Active coupon)
    ${resp}=  ProviderLogin  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p1}=  get_acc_id  ${PUSERNAME1}
    ${p1}=  Convert To String  ${p1}
    Set Suite Variable  ${p1}
    ${resp}=  ProviderLogin  ${PUSERNAME4}  ${PASSWORD}
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
    ${resp}=  Create Jaldee Coupon For Providers  ${cupn_code3}  ${cupn_name}  ${cupn_des}   ${age_group[1]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  250  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${pro_ids}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code3}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${couponStatus[1]}
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   ProviderLogin  ${PUSERNAME4}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code3}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code3}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code3}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Disable Jaldee Coupon  ${cupn_code3}  ${cupn_reason}
    Should Be Equal As Strings  ${resp.status_code}  200
    

JD-TC-DisableJaldeeCoupon-UH1
    [Documentation]    Create a jaldee coupon by superadmin login and disable before push operation(Draft coupon)
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
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  add_date  10
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code2}=   FakerLibrary.word
    Set Suite Variable    ${cupn_code2}
    clear_jaldeecoupon     ${cupn_code2}
    ${resp}=  Create Jaldee Coupon  ${cupn_code2}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Disable Jaldee Coupon  coupon2  ${cupn_reason}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_LIVE_DOESNOT_EXISTS}"

JD-TC-DisableJaldeeCoupon-UH2
    [Documentation]    Create jaldee coupon for specific providers and disable it before push operation(Draft coupon)
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
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code4}=    FakerLibrary.word
    Set Suite Variable    ${cupn_code4}
    clear_jaldeecoupon     ${cupn_code4}
    ${resp}=  Create Jaldee Coupon For Providers  ${cupn_code4}  ${cupn_name}  ${cupn_des}   ${age_group[1]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[0]}  ${bool[0]}  100  250  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${pro_ids}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Disable Jaldee Coupon  ${cupn_code4}  ${cupn_reason}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_LIVE_DOESNOT_EXISTS}"

JD-TC-DisableJaldeeCoupon-UH3
    [Documentation]    Disable a already disabled coupon
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Disable Jaldee Coupon  ${cupn_code3}  ${cupn_reason}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_LIVE_DOESNOT_EXISTS}"

JD-TC-DisableJaldeeCoupon-UH4
    [Documentation]    Disable a invalid jaldee coupon
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${invalid_coupon}=   FakerLibrary.word
    Set Suite Variable    ${invalid_coupon}
    clear_jaldeecoupon    ${invalid_coupon}
    ${resp}=  Disable Jaldee Coupon   ${invalid_coupon}  ${cupn_reason}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_LIVE_DOESNOT_EXISTS}"

JD-TC-DisableJaldeeCoupon -UH5
    [Documentation]   Disable a  Coupon without login  
    ${resp}=  Disable Jaldee Coupon  ${cupn_code3}  ${cupn_reason}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SA_SESSION_EXPIRED}"

JD-TC-DisableJaldeeCoupon -UH6
    [Documentation]  Disable a coupon by consumer
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Disable Jaldee Coupon  ${cupn_code3}  ${cupn_reason}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SA_SESSION_EXPIRED}"

JD-TC-DisableJaldeeCoupon -UH7
    [Documentation]   Disable a coupon by provider
    ${resp}=   ProviderLogin  ${PUSERNAME2}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Disable Jaldee Coupon  ${cupn_code3}  ${cupn_reason}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SA_SESSION_EXPIRED}"

    sleep  03s
JD-TC-Verify DisableJaldeeCoupon-1
    [Documentation]    Create a jaldee coupon by superadmin login and disable after push operation(Active coupon)
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${couponStatus[2]}
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   ProviderLogin  ${PUSERNAME69}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()['couponState']}   ${couponState[4]}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
   
    # ${resp}=   ProviderLogin  ${PUSERNAME69}  ${PASSWORD} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    # sleep  10s
    ${cupn_reason}=   FakerLibrary.sentence
    Set Suite Variable   ${cupn_reason}
    ${resp}=  Disable Jaldee Coupon  ${cupn_code1}  ${cupn_reason}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   ProviderLogin  ${PUSERNAME69}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    sleep  10s
    ${resp}=  Get Alerts
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain    ${resp.json()}   ${cupn_reason}
    
    sleep  03s
JD-TC-Verify DisableJaldeeCoupon-2
    [Documentation]    Create jaldee coupon for specific providers and disable it before push operation(Draft coupon)
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${couponStatus[2]}
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   ProviderLogin  ${PUSERNAME4}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code3}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[4]}
    Should Be Equal As Strings  ${resp.status_code}  200
