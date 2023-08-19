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

${SERVICE1}  Note Book1102
${SERVICE2}  boots102
${SERVICE3}  pen102
${queue1}  morning
${LsTime}   08:00 AM
${LeTime}   09:00 AM

${sTime}    09:00 PM
${eTime}    11:00 PM
${longi}        89.524764
${latti}        86.524764
${Coupon19}     Coupon1912
${numbers}  0123456789

*** Test Cases ***

JD-TC-ApplyJaldeeCoupon-1

    [Documentation]  Provider apply a coupon after waitlist

    ${resp}=   Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_queue  ${PUSERNAME100}  
    clear_waitlist  ${PUSERNAME100}    
    clear_service  ${PUSERNAME100}  
    clear_location  ${PUSERNAME100}  
    clear_customer   ${PUSERNAME100}
    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get BusinessDomainsConf
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd2}  ${resp.json()[0]['subDomains'][1]['subDomain']}
    Set Test Variable  ${sd3}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd4}  ${resp.json()[1]['subDomains'][1]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}  ${d2}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}  ${d1}_${sd2}  ${d2}_${sd3}  ${d2}_${sd4}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cupn_code2018}=   FakerLibrary.word
    Set Suite Variable    ${cupn_code2018}
    ${cupn_name}=    FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable     ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable     ${c_des}
    ${p_des}=    FakerLibrary.sentence
    Set Suite Variable     ${p_des}
    
    clear_jaldeecoupon  ${cupn_code2018}
    ${resp}=  Create Jaldee Coupon  ${cupn_code2018}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  0  100  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2018}  ${cupn_name}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200

    
    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}
    Log    ${resp.json()}

    ${firstname}=  FakerLibrary.name
    ${name1}=  FakerLibrary.name
    ${city}=   get_place
    ${IFSC}=  Generate_ifsc_code
    ${ph}=   evaluate    ${PUSERNAME152}+1234
    ${acc}=    Generate_random_value  11   ${numbers}

    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${ph}   ${pan_num}  ${acc}  ${name1}  ${IFSC}  ${firstname}  ${firstname}  ${city}  ${businessStatus[1]}  ${accounttype[1]}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERNAME100}
    Set Suite Variable  ${pid}
    ${resp}=  payuVerify  ${pid}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${ph}   ${pan_num}  ${acc}  ${name1}  ${IFSC}  ${firstname}  ${firstname}  ${city}  ${businessStatus[1]}  ${accounttype[1]}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid}  ${merchantid}
    ${cid}=  get_id  ${CUSERNAME5}
    Set Suite Variable  ${cid}
    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${description}=  FakerLibrary.sentence
    ${address}=  get_address
    ${list}=  Create List   1  2  3  4  5  6  7
    ${resp}=  Create Location  ABCDE  ${longi}  ${latti}  www.${companySuffix}.com  ${postcode}  ${address}  ${parkingType[3]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${LsTime}  ${LeTime}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${lid}  ${resp.json()}

    ${resp}=  Create Service  ${SERVICE1}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  50  500  ${bool[1]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE2}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE3}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id3}  ${resp.json()}

    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}  ${s_id1}  ${s_id2}  ${s_id3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    ${des}=   FakerLibrary.sentence
    Set Suite Variable   ${des}

JD-TC-ApplyJaldeeCoupon-UH1

    [Documentation]   After validity period of a coupon, provider trying to apply that coupon
    
    ${domains}=  Jaldee Coupon Target Domains  ALL
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ALL
    ${loc1}=  Jaldee Coupon Target Locations  ${longi}  ${latti}  5
    ${loc2}=  Jaldee Coupon Target Locations  ${longi1}  ${latti1}  2
    ${locations}=  Create List  ${loc1}  ${loc2}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY3}=  db.add_timezone_date  ${tz}  1  
    ${cupn_code06}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code06}
    ${cupn_name}=   FakerLibrary.word
    Set Suite Variable   ${cupn_name}   Coupon_${cupn_name}
    clear_jaldeecoupon  ${cupn_code06}
    ${resp}=  Create Jaldee Coupon  ${cupn_code06}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY3}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  0  100  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code06}  ${cupn_name}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code06}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code06}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    
    change_system_date  2

    ${resp}=   Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code06}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}   ${couponState[2]}

    # ${cid}=  get_id  ${CUSERNAME2}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id2}  ${qid1}  ${DAY}  ${des}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  590.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  590.0

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code06}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_NOT_VALID}"




JD-TC-ApplyJaldeeCoupon-UH2

    [Documentation]   Provider trying to apply a coupon after maxProviderUseLimit, and check an alert get to appropriate  provider
    
    ${domains}=  Jaldee Coupon Target Domains  ALL
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ALL
    ${loc1}=  Jaldee Coupon Target Locations  ${longi}  ${latti}  5
    ${loc2}=  Jaldee Coupon Target Locations  ${longi1}  ${latti1}  2
    ${locations}=  Create List  ${loc1}  ${loc2}

    ${licenses}=  Jaldee Coupon Target License  ${lic1}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code07}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code07}

    ${cupn_name}=   FakerLibrary.word
    Set Suite Variable   ${cupn_name}   Coupon_${cupn_name}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  
    
    clear_jaldeecoupon  ${cupn_code07}
    ${resp}=  Create Jaldee Coupon  ${cupn_code07}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  0  100  1  5  1  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Push Jaldee Coupon  ${cupn_code07}  ${cupn_name}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code07}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${cid}=  get_id  ${CUSERNAME2}
    ${id}=  get_acc_id  ${PUSERNAME100}
    clear_Alert  ${id}

    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY1}  ${des}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  590.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  590.0

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code07}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${cid}=  get_id  ${CUSERNAME2}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id3}  ${qid1}  ${DAY1}  ${des}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  500.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  500.0
    
    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code07}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  409
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_EXCEEDS_APPLY_LIMIT}"
    
    ${resp}=  Get Alerts
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['text']}   ${cupn_code07} ,will not be available as it has reached the maximum apply limit



JD-TC-ApplyJaldeeCoupon-UH3

    [Documentation]   Apply a jaldee coupon when no bill
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${domains}=  Jaldee Coupon Target Domains  ALL
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ALL
    ${loc1}=  Jaldee Coupon Target Locations  ${longi}  ${latti}  5
    ${loc2}=  Jaldee Coupon Target Locations  ${longi1}  ${latti1}  2
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  
    ${locations}=  Create List  ${loc1}  ${loc2}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code0112}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code0112}
    ${cupn_name}=   FakerLibrary.word
    Set Suite Variable   ${cupn_name}   Coupon_${cupn_name}
   
    clear_jaldeecoupon  ${cupn_code0112}
    ${resp}=  Create Jaldee Coupon  ${cupn_code0112}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  0  1000  10  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Push Jaldee Coupon  ${cupn_code0112}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code0112}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY2}  ${des}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code0112}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${NO_BILL_FOUND}"
