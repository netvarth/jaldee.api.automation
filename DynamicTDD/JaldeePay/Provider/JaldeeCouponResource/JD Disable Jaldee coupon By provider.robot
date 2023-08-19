*** Settings ***
Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags        POC
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
${queue1}  morning
${LsTime}   08:00 AM
${LeTime}   09:00 AM

${sTime}    09:00 PM
${eTime}    11:00 PM
${SERVICE1}  Note Book11
${SERVICE2}  boots11
${SERVICE3}  pen11

*** Test Cases ***

JD-TC-DisableJaldeeCoupon-1
    [Documentation]   Disable a jaldee coupon by provider
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_queue  ${PUSERNAME1}  
    clear_service  ${PUSERNAME1}  
    # clear_location  ${PUSERNAME1}  
    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   ProviderLogout
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
    # ${loc1}=  Jaldee Coupon Target Locations  ${longi}  ${latti}  5
    # ${loc2}=  Jaldee Coupon Target Locations  ${longi1}  ${latti1}  2
    # ${locations}=  Create List  ${loc1}  ${loc2}
    
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  ${DAY2}
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

    ${resp}=  Create Jaldee Coupon  ${cupn_code2018}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2018}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  Disable Jaldee Coupon By Provider  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[3]}

JD-TC-DisableJaldeeCoupon-2
    [Documentation]   Disable  a jaldee coupon by provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p1}=  get_acc_id  ${PUSERNAME1}
    ${p1}=  Convert To String  ${p1}
    Set Suite Variable  ${p1}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p2}=  get_acc_id  ${PUSERNAME1}
    ${p2}=  Convert To String  ${p2}
    Set Suite Variable  ${p2}
    ${pro_ids}=  Create List  ${p1}  ${p2}
    Set Suite Variable  ${pro_ids}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code01}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code01}
    clear_jaldeecoupon  ${cupn_code01}
    ${resp}=  Create Jaldee Coupon For Providers  ${cupn_code01}  ${cupn_name}  ${cupn_des}   ${age_group[1]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[0]}  ${bool[0]}  100  250  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${pro_ids}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code01}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code01}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code01}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cupn_code01}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  Disable Jaldee Coupon By Provider  ${cupn_code01}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code01}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cupn_code01}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[3]}

JD-TC-DisableJaldeeCoupon-3
    [Documentation]   Disable a default enabled jaldee coupon
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
    # ${loc1}=  Jaldee Coupon Target Locations  ${longi}  ${latti}  5
    # ${loc2}=  Jaldee Coupon Target Locations  ${longi1}  ${latti1}  2
    # ${locations}=  Create List  ${loc1}  ${loc2}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code50}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code50}
    clear_jaldeecoupon  ${cupn_code50}
    ${resp}=  Create Jaldee Coupon  ${cupn_code50}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[1]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code50}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code50}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cupn_code50}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  Disable Jaldee Coupon By Provider  ${cupn_code50}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code50}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cupn_code50}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[3]}

JD-TC-DisableJaldeeCoupon-UH2
    [Documentation]   Disable a already disabled jaldee coupon
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Disable Jaldee Coupon By Provider  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${COUPON_STATUS_ALREADY_SET}"

JD-TC-DisableJaldeeCoupon-UH3
    [Documentation]   Disable a already disabled jaldee coupon by Superadmin
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${disable_msg}=   FakerLibrary.word
    Set suite Variable   ${disable_msg}
    ${resp}=  Disable Jaldee Coupon  ${cupn_code2018}  ${disable_msg}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[4]}
    ${resp}=  Disable Jaldee Coupon By Provider  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${PROVIDER_CANNOT_ENABLE_OR_DISABLED}"

JD-TC-DisableJaldeeCoupon-UH4
    [Documentation]   Disable a always enabled jaldee coupon
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
    # ${loc1}=  Jaldee Coupon Target Locations  ${longi}  ${latti}  5
    # ${loc2}=  Jaldee Coupon Target Locations  ${longi1}  ${latti1}  2
    # ${locations}=  Create List  ${loc1}  ${loc2}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code55}=    FakerLibrary.word
    Set Suite Variable  ${cupn_code55}
    clear_jaldeecoupon  ${cupn_code55}
    ${resp}=  Create Jaldee Coupon  ${cupn_code55}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[1]}  ${bool[1]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code55}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Disable Jaldee Coupon By Provider  ${cupn_code55}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${PROVIDER_CANNOT_ENABLE_OR_DISABLED}"


JD-TC-DisableJaldeeCoupon-5
    [Documentation]   Disable jaldee coupon by provider after upgrade license package
    ${resp}=   Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_queue  ${PUSERNAME50}    
    clear_service  ${PUSERNAME50}  
    # clear_location  ${PUSERNAME50}
    ${resp}=  Get Active License
    Set Test Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}

    ${resp}=   Get Business Profile
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${d1}  ${resp.json()['serviceSector']['domain']}
    Set Test Variable  ${sd1}  ${resp.json()['serviceSubSector']['subDomain']}
    Set Test Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    # ${loc1}=  Jaldee Coupon Target Locations  ${longi}  ${latti}  5
    # ${loc2}=  Jaldee Coupon Target Locations  ${longi1}  ${latti1}  2
    # ${locations}=  Create List  ${loc1}  ${loc2}
    ${licenses}=  Jaldee Coupon Target License  ${lic1} 
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code02}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code02}
    clear_jaldeecoupon  ${cupn_code02}
    ${resp}=  Create Jaldee Coupon  ${cupn_code02}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  10  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code02}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code02}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code02}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cupn_code02}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    ${resp}=  Get Active License
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   ${lic1}

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}
    ${resp}=   Change License Package  ${highest_package[0]}
    Log  ${resp.json()}
    #Set Suite Variable  ${lic2}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   ${lic2}

    ${resp}=  Disable Jaldee Coupon By Provider  ${cupn_code02}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_NOT_VALID}"

JD-TC-DisableJaldeeCoupon-UH6
    [Documentation]   Disable a invalid jaldee coupon
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Disable Jaldee Coupon By Provider  invalidcoupon
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_NOT_VALID}"

JD-TC-DisableJaldeeCoupon -UH7
    [Documentation]   Provider disable a Jaldee Coupon without login  
    ${resp}=  Disable Jaldee Coupon By Provider  ${cupn_code02}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-DisableJaldeeCoupon -UH8
    [Documentation]   Consumer disable a Jaldee Coupon
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Disable Jaldee Coupon By Provider  ${cupn_code02}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-DisableJaldeeCoupon -UH9
    [Documentation]   Another Provider disable a Jaldee Coupon
    ${resp}=   Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Disable Jaldee Coupon By Provider  ${cupn_code02}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"   "${JALDEE_COUPON_NOT_VALID}"


