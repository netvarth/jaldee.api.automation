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
${longi}        89.524764
${latti}        88.259874
${longi1}       70.524764
${latti1}       88.259874
${tz}   Asia/Kolkata

*** Test Cases ***

JD-TC-GetJaldeeCouponsCount-1
    [Documentation]    Get jaldee coupons count by superadmin
    ${cupn_code2018}=   FakerLibrary.word
    Set Suite Variable    ${cupn_code2018}
    clear_jaldeecoupon    ${cupn_code2018}
    ${cupn_code001}=   FakerLibrary.last_name
    set Suite Variable   ${cupn_code001}
    clear_jaldeecoupon    ${cupn_code001}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${d1}  ${decrypted_data['sector']} 
    Set Test Variable  ${sd1}  ${decrypted_data['subSector']}
    # Set Suite Variable   ${d1}    ${resp.json()['sector']}
    # Set Suite Variable   ${sd1}    ${resp.json()['subSector']}
    
    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${d2}  ${decrypted_data['sector']} 
    Set Test Variable  ${sd2}  ${decrypted_data['subSector']}
    # Set Suite Variable   ${d2}    ${resp.json()['sector']}
    # Set Suite Variable   ${sd2}    ${resp.json()['subSector']}
    
    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic2}  ${resp.json()['accountLicense']['licPkgOrAddonId']}

    ${domains}=  Jaldee Coupon Target Domains  ${d1}  ${d2}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}  ${d2}_${sd2}
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

    ${cupn_name1}=   FakerLibrary.name
    Set Suite Variable   ${cupn_name1}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable   ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable   ${c_des}
    ${p_des}=   FakerLibrary.sentence
    set Suite Variable   ${p_des}
    ${resp}=  Create Jaldee Coupon  ${cupn_code2018}  ${cupn_name1}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Jaldee Coupon  ${cupn_code001}  ${cupn_name1}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p1}=  get_acc_id  ${PUSERNAME1}
    ${p1}=  Convert To String  ${p1}
    Set Suite Variable  ${p1}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
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
    ${cupn_codexxx}=   FakerLibrary.first_name
    Set Suite Variable   ${cupn_codexxx}
    clear_jaldeecoupon     ${cupn_codexxx}
    ${cupn_name2}=   FakerLibrary.first_name
    Set Suite Variable   ${cupn_name2}
    ${resp}=  Create Jaldee Coupon For Providers  ${cupn_codexxx}  ${cupn_name2}  ${cupn_des}   ${age_group[1]}  ${DAY2}  ${DAY3}  ${discountType[1]}  50  100  ${bool[0]}  ${bool[0]}  100  250  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${pro_ids}
    Log   ${resp.json()}
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

JD-TC-GetJaldeeCouponsCount-2
    [Documentation]    Get jaldee coupons count by superadmin
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${totalcount}  ${resp.json()}
    ${count}=  Evaluate  ${totalcount}-1
    ${resp}=  Get Jaldee Coupons Count  couponCode-neq=${cupn_code2018}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${count}

JD-TC-GetJaldeeCouponsCount-3
    [Documentation]    Get jaldee coupons count by superadmin
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${count}=  Evaluate  ${draftcount}+3
    Set Suite Variable   ${count}

    ${resp}=  Get Jaldee Coupons Count  couponStatus-eq=${couponStatus[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${count}

    ${resp}=  Push Jaldee Coupon  ${cupn_code2018}  ${cupn_name1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s

    ${count}=  Evaluate  ${draftcount}+2
    ${resp}=  Get Jaldee Coupons Count  couponStatus-eq=${couponStatus[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${count}
    

    ${count}=  Evaluate  ${activecount}+1
    ${resp}=  Get Jaldee Coupons Count  couponStatus-eq=${couponStatus[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${count}

    ${resp}=  Push Jaldee Coupon  ${cupn_code001}  ${cupn_name1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Evaluate  ${draftcount}+1

    ${resp}=  Get Jaldee Coupons Count  couponStatus-eq=${couponStatus[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${count}

    ${count}=  Evaluate  ${activecount}+2
    ${resp}=  Get Jaldee Coupons Count  couponStatus-eq=${couponStatus[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${count}

    ${resp}=  Disable Jaldee Coupon  ${cupn_code2018}  reason
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  01s
    ${count}=  Evaluate  ${count}-1

    ${resp}=  Get Jaldee Coupons Count  couponStatus-eq=${couponStatus[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${count}
    ${count}=  Evaluate  ${disablecount}+1

    ${resp}=  Get Jaldee Coupons Count  couponStatus-eq=${couponStatus[2]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${count}
    ${count}=  Evaluate  ${draftcount}+1

    ${resp}=  Get Jaldee Coupons Count  couponStatus-eq=${couponStatus[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${count}


JD-TC-GetJaldeeCouponsCount-4
    [Documentation]    Get jaldee coupons count by superadmin
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons Count  couponName-eq=${cupn_name1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2
    ${resp}=  Get Jaldee Coupons Count  couponName-eq=${cupn_name2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-GetJaldeeCouponsCount-5
    [Documentation]    Get jaldee coupons count by superadmin
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons Count
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${totalcount}  ${resp.json()}
    ${count}=  Evaluate  ${totalcount}-2
    ${resp}=  Get Jaldee Coupons Count  couponName-neq=${cupn_name1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${count}
    ${count}=  Evaluate  ${totalcount}-1
    ${resp}=  Get Jaldee Coupons Count  couponName-neq=${cupn_name2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${count}

JD-TC-GetJaldeeCouponsCount-6
    [Documentation]    Get jaldee coupons count by superadmin
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Evaluate  ${startcount1}+2
    ${resp}=  Get Jaldee Coupons Count  startDate-eq=${DAY1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${count}
    ${count}=  Evaluate  ${startcount2}+1
    ${resp}=  Get Jaldee Coupons Count  startDate-eq=${DAY2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${count}

JD-TC-GetJaldeeCouponsCount-7
    [Documentation]    Get jaldee coupons count by superadmin
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Evaluate  ${endcount1}+2
    ${resp}=  Get Jaldee Coupons Count  endDate-eq=${DAY2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${count}
    ${count}=  Evaluate  ${endcount2}+1
    ${resp}=  Get Jaldee Coupons Count  endDate-eq=${DAY3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${count}

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

JD-TC-GetJaldeeCouponsCount -UH1
    [Documentation]   Get jaldee coupons without login  
    ${resp}=  Get Jaldee Coupons Count  CreatedDate-eq=${c_date}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SA_SESSION_EXPIRED}"
 
JD-TC-GetJaldeeCouponsCount -UH2
    [Documentation]   Consumer try to Get jaldee coupons count
    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Get Jaldee Coupons Count  CreatedDate-eq=${c_date}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SA_SESSION_EXPIRED}"