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
#Suite Setup     Run Keywords  clear_jaldeecoupon  Coupon_QQ  AND  clear_jaldeecoupon  Coupon1  AND  clear_jaldeecoupon  Coupon04   AND  clear_jaldeecoupon  Coupon05  AND  clear_jaldeecoupon  Coupon06  AND  clear_jaldeecoupon  Coupon07  AND  clear_jaldeecoupon  Coupon551  AND  clear_jaldeecoupon  XMASCoupon2018  AND  clear_JaldeeAlerts  ${PUSERNAME}  AND  clear_JaldeeAlerts  ${PUSERNAME1}  AND  clear_JaldeeAlerts  ${PUSERNAME2}  AND  clear_JaldeeAlerts  ${PUSERNAME5}  AND  clear_JaldeeAlerts  ${PUSERNAME6}  AND  clear_JaldeeAlerts  ${CUBS_PUSERNAME}  AND  clear_JaldeeAlerts  ${PUSERNAME7}  AND  clear_jaldeecoupon  Coupon10  AND  clear_jaldeecoupon  Coupon11  AND  clear_jaldeecoupon  Coupon12  AND  clear_jaldeecoupon  Coupon13  AND  clear_jaldeecoupon  Coupon14  AND  clear_jaldeecoupon  Coupon15  AND  clear_jaldeecoupon  Coupon16  AND  clear_jaldeecoupon  Coupon17  AND  clear_jaldeecoupon  Coupon18  AND  clear_jaldeecoupon  Coupon19  AND  clear_jaldeecoupon  Coupon09


*** Variables ***
${longi}        89.524764
${latti}        88.259874
${longi1}       70.524764
${latti1}       88.259874
${tz}   Asia/Kolkata

*** Test Cases ***

JD-TC-PushJaldeeCoupon-1
    [Documentation]    Create a jaldee coupon by superadmin login and push coupon to target and check its status and alerts
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${d1}  ${decrypted_data['sector']} 
    Set Test Variable  ${sd1}  ${decrypted_data['subSector']}
    # Set Suite Variable  ${d1}  ${resp.json()['sector']}
    # Set Suite Variable  ${sd1}  ${resp.json()['subSector']}
    ${resp}=   Get Active License
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${d2}  ${decrypted_data['sector']} 
    Set Test Variable  ${sd2}  ${decrypted_data['subSector']}
    # Set Suite Variable  ${d2}  ${resp.json()['sector']}
    # Set Suite Variable  ${sd2}  ${resp.json()['subSector']}
    ${resp}=   Get Active License
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic2}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${domains}=  Jaldee Coupon Target Domains  ${d1}  ${d2}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}  ${d2}_${sd2}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}  ${lic2}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_codeQQ}=    FakerLibrary.word
    Set Suite Variable   ${cupn_codeQQ}
    ${cupn_name}=   FakerLibrary.name
    Set Suite Variable    ${cupn_name}
    ${cupn_des}=    FakerLibrary.sentence
    Set Suite Variable    ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable    ${c_des}  
    ${p_des}=   FakerLibrary.sentence
    Set Suite Variable    ${p_des}
    clear_jaldeecoupon    ${cupn_codeQQ}
    ${resp}=  Create Jaldee Coupon  ${cupn_codeQQ}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_codeQQ}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${couponStatus[0]}

    ${push_msg}=    FakerLibrary.sentence
    Set Suite Variable   ${push_msg}   

    ${resp}=  Push Jaldee Coupon   ${cupn_codeQQ}   ${push_msg}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_codeQQ}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${couponStatus[1]}
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    sleep  10s
    ${resp}=  Get Alerts
  
    Should Be Equal As Strings  ${resp.status_code}  200
    Variable Should Exist   ${resp.content}  ${push_msg}
    # Should Contain    ${resp.json()}  ${push_msg}
    Should Contain    ${resp.json()}  Jaldee Coupon Enabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Alerts
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain    ${resp.json()}  ${push_msg}
    Should Contain    ${resp.json()}  Jaldee Coupon Enabled


JD-TC-PushJaldeeCoupon-2
    [Documentation]    Create jaldee coupon for specific providers and push it to its target then check its status and alerts
    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p1}=  get_acc_id  ${PUSERNAME2}
    ${p1}=  Convert To String  ${p1}
    Set Suite Variable  ${p1}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
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
    ${cupn_code1}=    FakerLibrary.word
    Set Suite Variable     ${cupn_code1}
    clear_jaldeecoupon   ${cupn_code1}
    ${resp}=  Create Jaldee Coupon For Providers  ${cupn_code1}  ${cupn_name}  ${cupn_des}   ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[1]}  50  100  ${bool[0]}  ${bool[0]}  100  250  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${pro_ids}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${couponStatus[0]}
    ${push_msg}=    FakerLibrary.sentence
    Set Suite Variable   ${push_msg}

    ${resp}=  Push Jaldee Coupon  ${cupn_code1}  ${push_msg}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${couponStatus[1]}
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  3s
    ${resp}=   Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Alerts
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain    ${resp.json()}  ${push_msg}
    Should Contain    ${resp.json()}  Jaldee Coupon Enabled
    ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Alerts
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain    ${resp.json()}  ${push_msg}
    Should Contain    ${resp.json()}  Jaldee Coupon Enabled
    ${resp}=   Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Alerts
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain  ${resp.json()}  ${push_msg}

JD-TC-PushJaldeeCoupon-3
    [Documentation]    Create jaldee coupon for ALL domain, subdomain and licences and push it to its target then check its status and alerts

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
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
    ${resp}=  Create Jaldee Coupon  XMASCoupon2008  Onamm Coupon  Onam offer  CHILDREN  ${DAY1}  ${DAY2}  AMOUNT  50  100  false  false  100  1000  1000  5  2  false  false  false  false  false  consumer first use  50% offer  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log   ${resp.json()}
    ${resp}=  Get Jaldee Coupons
    Log   ${resp.json()}

    #${resp}=    Create Sample Jaldee Coupon
    Set Suite Variable   ${cupn_code}     ${resp.json()[0]['jaldeeCouponCode']}
    Set Suite Variable   ${cupn_name}     ${resp.json()[0]['couponName']}
    Set Suite Variable   ${cupn_des1}      ${resp.json()[0]['couponDescription']}
    
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${couponStatus[0]}

    ${push_msg1}=    FakerLibrary.sentence
    Set Suite Variable   ${push_msg1}
   
    ${resp}=  Push Jaldee Coupon  ${cupn_code}  ${push_msg1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${couponStatus[1]}
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  10s

    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Alerts
  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain    ${resp.json()}  ${push_msg}
    Should Contain    ${resp.json()}  Jaldee Coupon Enabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Alerts
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain    ${resp.json()}  ${push_msg1}
    Should Contain    ${resp.json()}  Jaldee Coupon Enabled
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Alerts
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain    ${resp.json()}  ${push_msg1}
    Should Contain    ${resp.json()}  Jaldee Coupon Enabled
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Alerts
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain    ${resp.json()}  ${push_msg1}
    Should Contain    ${resp.json()}  Jaldee Coupon Enabled
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Alerts
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain    ${resp.json()}  ${push_msg1}
    Should Contain    ${resp.json()}  Jaldee Coupon Enabled
    ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Alerts
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain    ${resp.json()}  ${push_msg1}
    Should Contain    ${resp.json()}  Jaldee Coupon Enabled


JD-TC-PushJaldeeCoupon-4
    [Documentation]   Superadmin trying to push default enabled coupon

    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${d1}  ${decrypted_data['sector']} 
    Set Test Variable  ${sd1}  ${decrypted_data['subSector']}
    # Set Suite Variable  ${d1}  ${resp.json()['sector']}
    # Set Suite Variable  ${sd1}  ${resp.json()['subSector']}
    ${resp}=   Get Active License
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${d2}  ${resp.json()['sector']}
    Set Suite Variable  ${sd2}  ${resp.json()['subSector']}
    ${resp}=   Get Active License
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic3}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${domains}=  Jaldee Coupon Target Domains  ${d1}  ${d2}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}  ${d2}_${sd2}
    ${latti}=  get_latitude
    Set Suite Variable    ${latti}
    ${longi}=  get_longitude
    Set Suite Variable    ${longi}
    ${latti1}=  get_latitude
    Set Suite Variable    ${latti1}
    ${longi1}=  get_longitude
    Set Suite Variable    ${longi1}


    ${loc1}=  Jaldee Coupon Target Locations  ${longi}  ${latti}  5
    ${loc2}=  Jaldee Coupon Target Locations  ${longi1}  ${latti1}  2
    ${locations}=  Create List  ${loc1}  ${loc2}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}  ${lic3}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code04}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code04}
    clear_jaldeecoupon    ${cupn_code04}
    ${resp}=  Create Jaldee Coupon  ${cupn_code04}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[1]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${any_other}=   FakerLibrary.sentence
    Set Suite Variable   ${any_other}
    ${free_shopping}=   FakerLibrary.sentence
    Set Suite Variable   ${free_shopping}

    ${resp}=  Push Jaldee Coupon  ${cupn_code04}  ${push_msg1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code04}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${couponStatus[1]}
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  3s
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Alerts
    Should Be Equal As Strings  ${resp.status_code}  200
    #Should  Contain    ${resp.json()}  ${push_msg1}
    Should Contain    ${resp.json()}  Jaldee Coupon Enabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Alerts
    Should Be Equal As Strings  ${resp.status_code}  200
    #Should  Not Contain    ${resp.json()}  ${push_msg1}
    Should Contain    ${resp.json()}  Jaldee Coupon Enabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Alerts
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain  ${resp.json()}  ${push_msg1}

JD-TC-PushJaldeeCoupon-5
    [Documentation]    Superadmin push a always enabled coupon
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
    ${loc1}=  Jaldee Coupon Target Locations  ${longi}  ${latti}  5
    ${loc2}=  Jaldee Coupon Target Locations  ${longi1}  ${latti1}  2
    ${locations}=  Create List  ${loc1}  ${loc2}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}  ${lic3}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code05}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code05}
    clear_jaldeecoupon    ${cupn_code05}
    ${resp}=  Create Jaldee Coupon  ${cupn_code05}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[1]}  ${bool[1]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${25%_any_other}=   FakerLibrary.sentence
    Set Suite Variable   ${25%_any_other}
    ${resp}=  Push Jaldee Coupon  ${cupn_code05}  ${push_msg1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code05}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${couponStatus[1]}
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  10s
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Alerts
    Should Be Equal As Strings  ${resp.status_code}  200
    #Should Contain    ${resp.json()}  ${push_msg1}
    Should Contain    ${resp.json()}  Jaldee Coupon Enabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Alerts
    Should Be Equal As Strings  ${resp.status_code}  200
    #Should Contain    ${resp.json()}  ${push_msg1}
    Should Contain    ${resp.json()}  Jaldee Coupon Enabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Alerts
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain  ${resp.json()}  ${push_msg1}


JD-TC-PushJaldeeCoupon-UH1
    [Documentation]    Create a jaldee coupon by superadmin login and push coupon to target and check its status and check alerts goes to only specific domain,sub_domains and licenses
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    ${loc1}=  Jaldee Coupon Target Locations  ${longi}  ${latti}  5
    ${loc2}=  Jaldee Coupon Target Locations  ${longi1}  ${latti1}  2
    ${locations}=  Create List  ${loc1}  ${loc2}
    ${licenses}=  Jaldee Coupon Target License  2
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code06}=   FakerLibrary.word
    Set Suite Variable    ${cupn_code06}
    clear_jaldeecoupon   ${cupn_code06}
    ${resp}=  Create Jaldee Coupon  ${cupn_code06}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code06}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code06}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${couponStatus[1]}
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Alerts
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain  ${resp.json()}  ${cupn_des}
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code06}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_NOT_VALID}"



JD-TC-PushJaldeeCoupon-UH4
    [Documentation]    Again push a alreay pushed coupon to specific providers
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code1}=    FakerLibrary.word
    clear_jaldeecoupon     ${cupn_code1}
    ${resp}=  Push Jaldee Coupon  ${cupn_code1}  ${push_msg}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_DRAFT_DOESNOT_EXISTS}"

JD-TC-PushJaldeeCoupon-UH5
    [Documentation]    Superadmin trying to push a invalid coupon
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  InavlidCoupon  ${push_msg}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_DRAFT_DOESNOT_EXISTS}"

JD-TC-PushJaldeeCoupon-UH6
    [Documentation]  Check superadmin push jaldee coupon to ownered provider
    ${resp}=   Encrypted Provider Login  ${PUSERNAME55}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${d1}  ${resp.json()['sector']}
    Set Suite Variable  ${sd1}  ${resp.json()['subSector']}
    ${resp}=   Get Active License
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    Set Suite Variable  ${domains}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    Set Suite Variable  ${sub_domains}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    Set Suite Variable  ${licenses}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code551}=    FakerLibrary.word
    clear_jaldeecoupon    ${cupn_code551}
    ${resp}=  Create Jaldee Coupon  ${cupn_code551}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code551}  ${push_msg}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code551}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_NOT_VALID}"

JD-TC-PushJaldeeCoupon -UH7
    [Documentation]   Push a Jaldee Coupon without login
    ${resp}=  Push Jaldee Coupon  coupon1  ${push_msg}
    Should Be Equal As Strings    ${resp.status_code}   419
    # Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
    Should Start With   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-PushJaldeeCoupon -UH8
    [Documentation]   Consumer push a Jaldee Coupon
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Push Jaldee Coupon  ${cupn_code1}  ${push_msg}
    Should Be Equal As Strings    ${resp.status_code}   419
    # Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
    Should Start With   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-PushJaldeeCoupon -UH9
    [Documentation]   Provider push a Jaldee Coupon
    ${resp}=   Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Push Jaldee Coupon  ${cupn_code1}  ${push_msg}
    Should Be Equal As Strings    ${resp.status_code}   419
    # Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
    Should Start With   ${resp.json()}   ${SESSION_EXPIRED}
