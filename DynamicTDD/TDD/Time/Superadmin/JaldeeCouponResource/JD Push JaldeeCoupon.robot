*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        JC
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

*** Test Cases ***

JD-TC-PushJaldeeCoupon-1
    [Documentation]    Create a jaldee coupon by superadmin login and push coupon to target and check its status and alerts
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${d1}  ${resp.json()['sector']}
    Set Test Variable  ${sd1}  ${resp.json()['subSector']}
    ${resp}=   Get Active License
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${d2}  ${resp.json()['sector']}
    Set Test Variable  ${sd2}  ${resp.json()['subSector']}
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

    ${cupn_enable}=    FakerLibrary.sentence
    Set Suite Variable   ${cupn_enable}

    ${resp}=  Push Jaldee Coupon   ${cupn_codeQQ}   ${push_msg}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_codeQQ}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${couponStatus[1]}
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  3s
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Alerts
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain    ${resp.json()}  ${push_msg}
    Should Contain    ${resp.json()}  ${cupn_enable}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Alerts
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain    ${resp.json()}  ${push_msg}
    Should Contain    ${resp.json()}  ${cupn_enable}


JD-TC-PushJaldeeCoupon-UH2
    [Documentation]    Create a jaldee coupon by superadmin login and push coupon to target after validation period
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    ${loc1}=  Jaldee Coupon Target Locations  ${longi}  ${latti}  5
    ${loc2}=  Jaldee Coupon Target Locations  ${longi1}  ${latti1}  2
    ${locations}=  Create List  ${loc1}  ${loc2}
    ${resp}=   Get Licensable Packages
    Should Be Equal As Strings   ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()[0]['pkgId']}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY3}=  db.add_timezone_date  ${tz}  1  
    Set Suite Variable  ${DAY3}  ${DAY3}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code07}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code07}
    clear_jaldeecoupon    ${cupn_code07}
    ${resp}=  Create Jaldee Coupon  ${cupn_code07}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY3}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code07}  ${push_msg}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_DATES_INVALID}"
  

JD-TC-PushJaldeeCoupon-UH3
    [Documentation]    Again push a already pushed coupon
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_codeQQ}  ${push_msg}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JC_DRAFT_DOESNOT_EXISTS}"


