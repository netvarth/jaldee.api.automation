*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
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
Variables         /ebs/TDD/varfiles/consumermail.py
#Suite Setup     Run Keywords    clear_jaldeecoupon  OnamCoupon2018  AND  clear_jaldeecoupon  Coupon01  AND  clear_jaldeecoupon  Coupon02  AND  clear_jaldeecoupon  Coupon03  AND  clear_jaldeecoupon  Coupon04  AND  clear_jaldeecoupon  Coupon05  AND  clear_jaldeecoupon  Coupon06  AND  clear_jaldeecoupon  Coupon07  AND  clear_jaldeecoupon  Coupon08  AND  clear_jaldeecoupon  Coupon09  AND  clear_jaldeecoupon  Coupon10  AND  clear_jaldeecoupon  Coupon11  AND  clear_jaldeecoupon  Coupon12  AND  clear_jaldeecoupon  Coupon13  AND  clear_jaldeecoupon  Coupon14  AND  clear_jaldeecoupon  Coupon15  AND  clear_jaldeecoupon  Coupon16  AND  clear_jaldeecoupon  Coupon19  AND  clear_tax_gstNum  13DEFBV1100M2Z6
*** Variables ***

${SERVICE1}  Note Book101
${SERVICE2}  boots101
${SERVICE3}  pen101
${SERVICE4}  Note Book12101
${SERVICE5}  boots13101
${SERVICE6}  pen15101
${SERVICE7}  pen25101
${SERVICE8}  pen155101
${SERVICE9}  pen255101
${SERVICE10}  pen26101
${SERVICE11}  pen266101
@{Views}  self  all  customersOnly
${CUSERPH}      ${CUSERNAME}

*** Test Cases ***

JD-TC-ApplyJaldeeCouponByConsumer-1

    [Documentation]  Consumer apply a coupon at self payment

    ${resp}=   Encrypted Provider Login  ${PUSERNAME204}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    clear_queue  ${PUSERNAME204}
    clear_service  ${PUSERNAME204} 
    clear_location  ${PUSERNAME204}

    ${resp}=   Get Active License
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}

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
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
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

    ${resp}=  Create Jaldee Coupon  ${cupn_code2018}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  15  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Push Jaldee Coupon  ${cupn_code2018}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME204}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code2018}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${businessStatus}    Random Element   ${businessStatus}  
    ${accounttype}  Random Element   ${accounttype} 
    ${fname}=   FakerLibrary.name
    ${panCardNumber}=  Generate_pan_number
    Set Suite Variable   ${panCardNumber}
    ${bankAccountNumber}=  Generate_random_value  size=16  chars=string.digits
    Set Suite Variable   ${bankAccountNumber}
    ${bankName}=  FakerLibrary.company
    Set Suite Variable   ${bankName}
    ${ifsc}=  Generate_ifsc_code
    Set Suite Variable   ${ifsc}
    ${panname}=  FakerLibrary.name
    Set Suite Variable   ${panname}
    ${city}=   get_place
    Set Suite Variable   ${city}
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME204}   ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc}  ${pan_name}  ${fname}  ${city}  ${businessStatus}  ${accounttype}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERNAME204}
    Set Suite Variable  ${pid}
    ${resp}=  payuVerify  ${pid}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME204}   ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc}  ${pan_name}  ${fname}  ${city}  ${businessStatus}  ${accounttype}   
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid}  ${merchantid}
    ${cid}=  get_id  ${CUSERNAME5}
    Set Suite Variable  ${cid}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${cid}=  get_id  ${CUSERNAME5}
    Set Suite Variable  ${cid}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    # ${city}=   get_place
    # Set Suite Variable  ${city}
    # ${latti}=  get_latitude
    # Set Suite Variable  ${latti}
    # ${longi}=  get_longitude
    # Set Suite Variable  ${longi}
    # ${postcode}=  FakerLibrary.postcode
    # Set Suite Variable  ${postcode}
    # ${address}=  get_address
    # Set Suite Variable  ${address}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    Set Suite Variable  ${city}
    Set Suite Variable  ${latti}
    Set Suite Variable  ${longi}
    Set Suite Variable  ${postcode}
    Set Suite Variable  ${address}
    ${24hours}    Random Element    ['True','False']
    Set Suite Variable  ${24hours}
    ${sTime}=  add_timezone_time  ${tz}  5  15  
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  6  30  
    Set Suite Variable   ${eTime}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parkingType[0]}  ${24hours}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${loc_id1}    ${resp.json()}  
    ${description}=  FakerLibrary.sentence
    ${notifytype}    Random Element     ['none','pushMsg','email']
    ${notify}    Random Element     ['True','False'] 
    
    ${resp}=  Create Service  ${SERVICE6}  ${description}   2  ACTIVE  ${bType}  ${notify}   ${notifytype}  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable    ${s_id6}  ${resp.json()}

    ${resp}=  Create Service  ${SERVICE11}  ${description}   2  ACTIVE  ${bType}  ${notify}   ${notifytype}  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable    ${s_id11}  ${resp.json()}
    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${strt_time}=   subtract_timezone_time  ${tz}  1  00
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    Set Suite Variable    ${end_time}   
    ${parallel}=   Random Int  min=1   max=2
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=10   max=100
    Set Suite Variable   ${capacity}
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${s_id6}    ${s_id11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}


JD-TC-ApplyJaldeeCouponByConsumer-UH9
    [Documentation]  Consumer apply a coupon at Checkin time.but coupon apply after validity period

    ${resp}=   Encrypted Provider Login  ${PUSERNAME204}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${d1}  ${resp.json()['sector']}
    Set Test Variable  ${sd1}  ${resp.json()['subSector']}
    ProviderLogout

    #${resp}=  Get BusinessDomainsConf
    #Should Be Equal As Strings  ${resp.status_code}  200
    #Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    #Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    #Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    #Set Test Variable  ${sd2}  ${resp.json()[0]['subDomains'][1]['subDomain']}
    #Set Test Variable  ${sd3}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    #Set Test Variable  ${sd4}  ${resp.json()[1]['subDomains'][1]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  1  
    Set Suite Variable  ${DAY2}  ${DAY2}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code2031}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code2031}
    ${cupn_name}=   FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable   ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable   ${c_des}
    ${p_des}=   FakerLibrary.sentence
    Set Suite Variable   ${p_des}
    clear_jaldeecoupon  ${cupn_code2031}
    ${resp}=  Create Jaldee Coupon  ${cupn_code2031}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[1]}  10  100  ${bool[1]}  ${bool[1]}  100  100  1000  10  10  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2031}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME204}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2031}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    
    ${resp}=  AddCustomer  ${CUSERNAME2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    # ${cid}=  get_id  ${CUSERNAME2}
    # clear_waitlist   ${CUSERNAME2}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id6}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${widh9_1}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${widh9_1}  ${widh9_1[0]}   
    ${resp}=  Get Bill By UUId  ${widh9_1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${widh9_1}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id6}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE6}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  590.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  590.0
    ${resp}=  Accept Payment  ${widh9_1}  ${payment_modes[7]}  590  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  change_system_date  2
    Log   ${resp}
    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=  Apply Jaldee Coupon At Selfpay  ${widh9_1}  ${cupn_code2031}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME204}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${widh9_1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2031}']['value']}  59.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2031}']['systemNote'][0]}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${widh9_1}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id6}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE6}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  531.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  531.0
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${cid}=  get_id  ${CUSERNAME4}
    clear_waitlist   ${CUSERNAME4}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id6}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${widh9_2}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${widh9_2}  ${widh9_2[0]}   
    ${resp}=  Get Bill By UUId  ${widh9_2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${widh9_2}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id6}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE6}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  590.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  590.0
    ${resp}=  Accept Payment  ${widh9_2}  ${payment_modes[7]}  590  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
      

    ${resp}=  Apply Jaldee Coupon At Selfpay  ${widh9_2}  ${cupn_code2031}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_NOT_VALID}"

    

JD-TC-ApplyJaldeeCouponByConsumer-UH10
    [Documentation]  Consumer apply a coupon at Checkin time.but consumer pay payment after validity period of a coupon
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
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  1  
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code2032}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code2032}
    ${cupn_name}=   FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable   ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable   ${c_des}
    ${p_des}=   FakerLibrary.sentence
    Set Suite Variable   ${p_des}
    clear_jaldeecoupon  ${cupn_code2032}
    ${resp}=  Create Jaldee Coupon  ${cupn_code2032}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[1]}  10  100  ${bool[1]}  ${bool[1]}  100  100  1000  10  10  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2032}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME204}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2032}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME5}    
    ${coupons}=  Create List  ${cupn_code2032}
    clear_waitlist   ${CUSERNAME5}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id11}  ${desc}  ${bool[0]}  ${coupons}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${widh10}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${widh10}  ${widh10[0]}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME204}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${widh10}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2032}']['value']}  50.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2032}']['systemNote'][0]}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2032}']['systemNote'][1]}  ${SystemNote[1]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${widh10}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id11}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE11}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  540.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  540.0
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[0]}

    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code2032}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 
    change_system_date  2

    ${resp}=   Encrypted Provider Login  ${PUSERNAME204}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2032}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[2]}

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Make payment Consumer  540  ${payment_modes[2]}  ${widh10}  ${pid}  ${purpose[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain  ${resp.json()['response']}  <td><input name=\"amount\" value=540.00 /></td>
    Should Contain  ${resp.json()['response']}  <td><input name=\"email\" id=\"email\" value=${CUSEREMAIL5} /></td>
    Should Contain  ${resp.json()['response']}  <td>Phone: </td>\n   <td><input name=\"phone\" value=${CUSERNAME5} ></td>
    ${resp}=  Make payment Consumer Mock  540  ${bool[1]}  ${widh10}  ${pid}  ${purpose[1]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id  ${widh10}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]} 

    ${resp}=  Get Bill By Consumer  ${widh10}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2032}']['value']}  50.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2032}']['systemNote'][0]}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2032}']['systemNote'][1]}  ${SystemNote[1]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${widh10}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id11}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE11}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  540.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  540.0
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[2]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${cid}=  get_id  ${CUSERNAME5}    
    ${coupons}=  Create List  ${cupn_code2032}
    clear_waitlist   ${cupn_code2032}

    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id11}  ${desc}  ${bool[0]}  ${coupons}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "Coupon Validity Expired"



JD-TC-Verify ApplyJaldeeCouponByConsumer-UH10
    [Documentation]  Consumer apply a coupon at Checkin time.but consumer pay payment after validity period of a coupon
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 

    
   





