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

    [Documentation]   Disable a jaldee coupon by provider

    ${resp}=   ProviderLogin  ${PUSERNAME101}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}

    ${resp}=   ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${domains}=  Jaldee Coupon Target Domains  ALL

    ${sub_domains}=  Jaldee Coupon Target SubDomains  ALL

    ${licenses}=  Jaldee Coupon Target License  ${lic1}

    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  
    
    ${DAY2}=  add_date  10
    Set Suite Variable  ${DAY2} 
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
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

    ${j_price}=  Random Int   min=10  max=50

    clear_jaldeecoupon  ${cupn_code2018}

    ${resp}=  Create Jaldee Coupon  ${cupn_code2018}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  ${j_price}  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Push Jaldee Coupon  ${cupn_code2018}  ${cupn_des}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   ProviderLogin  ${PUSERNAME101}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code2018}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2018}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    ${resp}=  Disable Jaldee Coupon By Provider  ${cupn_code2018}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2018}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[3]}

JD-TC-DisableJaldeeCoupon-UH1

    [Documentation]   Disable a jaldee coupon by provider after validity period of a coupon
    
    ${domains}=  Jaldee Coupon Target Domains  ALL

    ${sub_domains}=  Jaldee Coupon Target SubDomains  ALL

    ${licenses}=  Jaldee Coupon Target License  ${lic1}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  get_date
    ${DAY2}=  add_date  1

    ${cupn_codeDes}=    FakerLibrary.word
    Set Suite Variable   ${cupn_codeDes}

    ${j_price}=  Random Int   min=10  max=50

    clear_jaldeecoupon  ${cupn_codeDes}
    ${resp}=  Create Jaldee Coupon  ${cupn_codeDes}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  ${j_price}  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Push Jaldee Coupon  ${cupn_codeDes}  ${cupn_des}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   ProviderLogin  ${PUSERNAME101}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_codeDes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    change_system_date  2
    ${resp}=   ProviderLogin  ${PUSERNAME101}  ${PASSWORD}
    Log  ${resp.json()} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeDes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cupn_codeDes}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[2]}

    ${resp}=  Disable Jaldee Coupon By Provider  ${cupn_codeDes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${PROVIDER_CANNOT_ENABLE_OR_DISABLED}"
    
JD-TC-DisableJaldeeCoupon-UH2

    [Documentation]    Disable jaldee coupon by provider after maxProviderUseLimit 
    
  
    ${domains}=  Jaldee Coupon Target Domains  ALL

    ${sub_domains}=  Jaldee Coupon Target SubDomains  ALL

    ${licenses}=  Jaldee Coupon Target License  ${lic1}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  get_date
    ${DAY2}=  add_date  1
    ${cupn_code01}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code01}

    ${j_price}=  Random Int   min=10  max=50

    clear_jaldeecoupon  ${cupn_code01}
    ${resp}=  Create Jaldee Coupon  ${cupn_code01}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  ${j_price}  100  ${bool[0]}  ${bool[0]}  100  100  1  5  1  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Push Jaldee Coupon  ${cupn_code01}  ${cupn_des}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   ProviderLogin  ${PUSERNAME101}  ${PASSWORD} 
    Log  ${resp.json()}
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

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code01}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code01}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cupn_code01}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
   
    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}
    
    ${resp}=  Create Sample Queue  
    Set Suite Variable  ${qid1}   ${resp['queue_id']}
    Set Suite Variable  ${s_id2}   ${resp['service_id']}
    Set Suite Variable  ${lid}   ${resp['location_id']}
    Set Suite Variable  ${s_name}   ${resp['service_name']}
    
    ${resp}=   Get Service By Id  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_price}   ${resp.json()['totalAmount']}

    ${des}=    FakerLibrary.sentence
    Set Suite Variable   ${des}
    
    ${resp}=  Add To Waitlist  ${cid}  ${s_id2}  ${qid1}  ${DAY1}  ${des}  ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}  

    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code01}  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${net_rate}=  Evaluate   ${s_price} - ${j_price}

    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code01}']['value']}  ${j_price}.0
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}  
    Should Be Equal As Strings  ${resp.json()['netTotal']}  ${s_price}
    Should Be Equal As Strings  ${resp.json()['netRate']}  ${net_rate}
    Should Be Equal As Strings  ${resp.json()['amountDue']}  ${net_rate}

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code01}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['jaldeeCouponCode']}  ${cupn_code01}
    Should Be Equal As Strings  ${resp.json()['couponState']}   ${couponState[5]}

    ${resp}=  Disable Jaldee Coupon By Provider  ${cupn_code01}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${PROVIDER_CANNOT_ENABLE_OR_DISABLED}"

