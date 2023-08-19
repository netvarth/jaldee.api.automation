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
#Suite Setup     Run Keywords  clear_jaldeecoupon  ${cupn_code2018}  AND  clear_jaldeecoupon  ${cupn_code001}  AND  clear_jaldeecoupon  ${cupn_codexxx}
*** Variables ***
${longi}        89.524764
${latti}        88.259874
${longi1}       70.524764
${latti1}       88.259874

*** Test Cases ***

JD-TC-GetJaldeeCouponsCount-1
    [Documentation]    Get jaldee coupons count by superadmin
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
    Set Suite Variable  ${lic2}  ${resp.json()[1]['pkgId']}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}  ${lic2} 
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${DAY3}=  db.add_timezone_date  ${tz}  12
    Set Suite Variable  ${DAY3}  ${DAY3}
    ${DAY4}=  db.add_timezone_date  ${tz}  14
    Set Suite Variable  ${DAY4}  ${DAY4}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons Count  couponStatus-eq=${couponStatus[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${draftcount}  ${resp.json()}
    ${resp}=  Get Jaldee Coupons Count  couponStatus-eq=${couponStatus[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${activecount}  ${resp.json()}
    ${resp}=  Get Jaldee Coupons Count  couponStatus-eq=${couponStatus[2]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${disablecount}  ${resp.json()}
    ${resp}=  Get Jaldee Coupons Count  startDate-eq=${DAY1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${startcount1}  ${resp.json()}
    ${resp}=  Get Jaldee Coupons Count  startDate-eq=${DAY2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${startcount2}  ${resp.json()}
    ${resp}=  Get Jaldee Coupons Count  endDate-eq=${DAY2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${endcount1}  ${resp.json()}
    ${resp}=  Get Jaldee Coupons Count  endDate-eq=${DAY3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${endcount2}  ${resp.json()}
    ${c_date}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Get Jaldee Coupons Count  createdDate-eq=${c_date}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${todaycount}  ${resp.json()}

    ${cupn_code2018}=   FakerLibrary.word
    Set Suite Variable    ${cupn_code2018}
    ${cupn_name}=   FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable   ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable   ${c_des}
    ${p_des}=   FakerLibrary.sentence
    set Suite Variable   ${p_des}
    clear_jaldeecoupon    ${cupn_code2018}
    ${resp}=  Create Jaldee Coupon  ${cupn_code2018}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code001}=   FakerLibrary.word
    clear_jaldeecoupon    ${cupn_code001}
    ${resp}=  Create Jaldee Coupon  ${cupn_code001}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
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
    ${cupn_codexxx}=   FakerLibrary.word
    clear_jaldeecoupon     ${cupn_codexxx}
    ${resp}=  Create Jaldee Coupon For Providers  ${cupn_codexxx}  ${cupn_name}  ${cupn_des}   ${age_group[1]}  ${DAY2}  ${DAY3}  ${discountType[1]}  50  100  ${bool[0]}  ${bool[0]}  100  250  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${pro_ids}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons Count  couponCode-eq=${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1
    ${resp}=  Get Jaldee Coupons Count  couponCode-eq=${cupn_code001}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1
    ${resp}=  Get Jaldee Coupons Count  couponCode-eq=${cupn_codexxx}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1


JD-TC-GetJaldeeCouponsCount-8
    [Documentation]    Get jaldee coupons count by superadmin
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_date}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${c_date}
    ${fdate}=  db.add_timezone_date  ${tz}  1  
    ${count}=  Evaluate  ${todaycount}+3
    ${resp}=  Get Jaldee Coupons Count  createdDate-eq=${c_date}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${count}
    ${resp}=  Get Jaldee Coupons Count  createdDate-eq=${fdate}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  0



JD-TC-GetJaldeeCouponsCount -UH3
    [Documentation]   Provider try to Get jaldee coupons count
    ${resp}=   Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupons Count  CreatedDate-eq=${c_date}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED_IN_SA}"


*** Comment ***
    
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Log  ${DAY}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons Count  couponStatus-eq=${couponStatus[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  0
    ${resp}=  Get Jaldee Coupons Count  couponStatus-eq=${couponStatus[3]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1
    ${resp}=  Get Jaldee Coupons Count  couponStatus-eq=${couponStatus[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1
    ${resp}=  Get Jaldee Coupons Count  couponStatus-eq=EXPIRED
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1
    ${resp}=  Push Jaldee Coupon  ${cupn_codexxx}  ${cupn_name}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons Count  couponStatus-eq=${couponStatus[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1
    ${resp}=  Get Jaldee Coupons Count  couponStatus-eq=${couponStatus[3]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1
    ${resp}=  Get Jaldee Coupons Count  couponStatus-eq=${couponStatus[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  0
    ${resp}=  Get Jaldee Coupons Count  couponStatus-eq=EXPIRED
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-GetJaldeeCouponsCount-4
    #resetsystem_time  
    [Documentation]    Get jaldee coupons count by superadmin
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons Count  couponStatus-neq=${couponStatus[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2
    ${resp}=  Get Jaldee Coupons Count  couponStatus-neq=${couponStatus[3]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2
    ${resp}=  Get Jaldee Coupons Count  couponStatus-neq=${couponStatus[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  3