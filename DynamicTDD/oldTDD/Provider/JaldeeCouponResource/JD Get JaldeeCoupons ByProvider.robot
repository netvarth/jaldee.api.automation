*** Settings ***
Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
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

*** Variables ***

${longi}        89.524764
${latti}        88.259874
${longi1}       70.524764
${latti1}       88.259874

*** Test Cases ***

JD-TC-GetJaldeeCoupons-1
    [Documentation]    Get all enabled jaldee coupons by provider
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=   Get Active License
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
    ${loc1}=  Jaldee Coupon Target Locations  ${longi}  ${latti}  5
    ${loc2}=  Jaldee Coupon Target Locations  ${longi1}  ${latti1}  2
    ${locations}=  Create List  ${loc1}  ${loc2}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code2018}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code2018}
    ${cupn_name}=    FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable     ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable     ${c_des}
    ${p_des}=    FakerLibrary.sentence
    Set Suite Variable     ${p_des}

    clear_jaldeecoupon  ${cupn_code2018}
    ${resp}=  Create Jaldee Coupon  ${cupn_code2018}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  0  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code001}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code001}
    clear_jaldeecoupon  ${cupn_code001}
    ${resp}=  Create Jaldee Coupon  ${cupn_code001}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  0  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2018}  ${cupn_name}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code001}  ${cupn_name}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupons By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain   ${resp.json()[0]}  jaldeeCouponCode  :  ${cupn_code001}
    Should Contain   ${resp.json()[1]}  jaldeeCouponCode  :  ${cupn_code2018}

JD-TC-GetJaldeeCoupons-2
    [Documentation]    Provider disable a jaldeee coupon and Get all enabled jaldee coupons by provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code001}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain   ${resp.json()[0]}  jaldeeCouponCode  :  ${cupn_code001}
    Should Contain   ${resp.json()[1]}  jaldeeCouponCode  :  ${cupn_code2018}
    
    ${resp}=  Disable Jaldee Coupon By Provider  ${cupn_code001}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain   ${resp.json()[0]}  jaldeeCouponCode  :  ${cupn_code001}
    Should Contain   ${resp.json()[1]}  jaldeeCouponCode  :  ${cupn_code2018}
    
JD-TC-GetJaldeeCoupons-3
    [Documentation]    Superadmin disable a jaldeee coupon and Get all enabled jaldee coupons by provider
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${disable_msg}=   FakerLibrary.word
    Set suite Variable   ${disable_msg}
    ${resp}=  Disable Jaldee Coupon  ${cupn_code2018}  ${disable_msg}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupons By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain   ${resp.json()[0]}  jaldeeCouponCode  :  ${cupn_code001}
    Should Contain   ${resp.json()[1]}  jaldeeCouponCode  :  ${cupn_code2018}

JD-TC-GetJaldeeCoupons-4
    [Documentation]    Get all enabled jaldee coupons by provider and check default enabled coupons are there
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
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code03}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code03}
    clear_jaldeecoupon  ${cupn_code03}
    ${resp}=  Create Jaldee Coupon  ${cupn_code03}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  true  ${bool[0]}  0  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code03}  ${disable_msg}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Jaldee Coupons By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain   ${resp.json()[0]}  jaldeeCouponCode  :  ${cupn_code03}
    
JD-TC-GetJaldeeCoupons-5
    [Documentation]    Get all enabled jaldee coupons by provider and check always enabled coupons are there
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
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code04}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code04}
    clear_jaldeecoupon  ${cupn_code04}
    ${resp}=  Create Jaldee Coupon  ${cupn_code04}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  true  true  0  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code04}  ${disable_msg}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Jaldee Coupons By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain   ${resp.json()[0]}  jaldeeCouponCode  :  ${cupn_code04}
  
JD-TC-GetJaldeeCoupons-6
    [Documentation]    Get jaldee coupon when coupon created for ALL domains, one subDomain and one License package
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    #Set Suite Variable   ${d1}    ${resp.json()['sector']}
    Set Suite Variable   ${sd1}    ${resp.json()['subSector']}

    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${alldomains}=  Jaldee Coupon Target Domains  ALL
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    #Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    ${loc1}=  Jaldee Coupon Target Locations  ${longi}  ${latti}  5
    ${loc2}=  Jaldee Coupon Target Locations  ${longi1}  ${latti1}  2
    ${locations}=  Create List  ${loc1}  ${loc2}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_codeFF}=   FakerLibrary.word
    Set suite Variable   ${cupn_codeFF}
    clear_jaldeecoupon  ${cupn_codeFF}
    ${resp}=  Create Jaldee Coupon  ${cupn_codeFF}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  true  true  0  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${alldomains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_codeFF}  ${disable_msg}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Jaldee Coupons By Provider
    Log    ${resp.json()}
    Set Suite Variable   ${jdc}   ${resp.json()[0]['jaldeeCouponCode']}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain   ${resp.json()[0]}  jaldeeCouponCode  :  ${cupn_codeFF}
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Jaldee Coupons By Provider
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Not Contain   ${resp.json()}  jaldeeCouponCode  :  ${cupn_codeFF}
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME113}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Jaldee Coupons By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}  jaldeeCouponCode  :  ${cupn_codeFF}
   
JD-TC-GetJaldeeCoupons-7
    [Documentation]    Get jaldee coupon when coupon created for ALL domains, one subDomain and more License package
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()} 
    Should Be Equal As Strings    ${resp.status_code}   200
    #Set Suite Variable   ${d1}    ${resp.json()['sector']}
    Set Suite Variable   ${sd1}    ${resp.json()['subSector']}

    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${d2}    ${resp.json()['sector']}
    Set Suite Variable   ${sd2}    ${resp.json()['subSector']}

    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic2}  ${resp.json()['accountLicense']['licPkgOrAddonId']}

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${alldomains}=  Jaldee Coupon Target Domains  ALL
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    #Set Test Variable  ${d2}  ${resp.json()[0]['domain']}
    #Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}    ${d2}_${sd2}
    ${loc1}=  Jaldee Coupon Target Locations  ${longi}  ${latti}  5
    ${loc2}=  Jaldee Coupon Target Locations  ${longi1}  ${latti1}  2
    ${locations}=  Create List  ${loc1}  ${loc2}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}  ${lic2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_codess}=   FakerLibrary.word
    Set Suite Variable   ${cupn_codess}
    clear_jaldeecoupon  ${cupn_codess}
    ${resp}=  Create Jaldee Coupon  ${cupn_codess}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  true  true  0  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${alldomains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_codess}  ${disable_msg}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Get Jaldee Coupons By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain   ${resp.json()[0]}  jaldeeCouponCode  :  ${cupn_codess}
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Jaldee Coupons By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain   ${resp.json()[0]}  jaldeeCouponCode  :  ${cupn_codess}
   
    ${resp}=   Encrypted Provider Login  ${PUSERNAME112}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Jaldee Coupons By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}  jaldeeCouponCode  :  ${cupn_codess}
   
    ${resp}=   Encrypted Provider Login  ${PUSERNAME113}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Jaldee Coupons By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}  jaldeeCouponCode  :  ${cupn_codess}
   
JD-TC-GetJaldeeCoupons-8
    [Documentation]    Get jaldee coupon when coupon created for one domain, all subDomain and more License package
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ALL
    Log   ${sub_domains}
    ${loc1}=  Jaldee Coupon Target Locations  ${longi}  ${latti}  5
    ${loc2}=  Jaldee Coupon Target Locations  ${longi1}  ${latti1}  2
    ${locations}=  Create List  ${loc1}  ${loc2}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}  ${lic2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_codeHH}=    FakerLibrary.word
    Set Suite Variable   ${cupn_codeHH}
    clear_jaldeecoupon  ${cupn_codeHH}
    ${resp}=  Create Jaldee Coupon  ${cupn_codeHH}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  true  true  0  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_codeHH}  ${disable_msg}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Jaldee Coupons By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain   ${resp.json()[0]}  jaldeeCouponCode  :  ${cupn_codeHH}
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME116}  ${PASSWORD}
    Log   ${resp.json()} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Jaldee Coupons By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}  jaldeeCouponCode  :  ${cupn_codeHH}
    
    # ${resp}=   Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=  Get Jaldee Coupons By Provider
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Contain   ${resp.json()}  "jaldeeCouponCode":"${cupn_codeHH}"

    # ${resp}=   Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=  Get Jaldee Coupons By Provider
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Contain   ${resp.json()}  "jaldeeCouponCode":"${cupn_codeHH}"

JD-TC-GetJaldeeCoupons-9
    [Documentation]    Get jaldee coupon when coupon created for one domain, all subDomain and ALL License package
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ALL
    ${loc1}=  Jaldee Coupon Target Locations  ${longi}  ${latti}  5
    ${loc2}=  Jaldee Coupon Target Locations  ${longi1}  ${latti1}  2
    ${locations}=  Create List  ${loc1}  ${loc2}
    ${licenses}=  Jaldee Coupon Target License  0
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_codeGG}=   FakerLibrary.word
    Set Suite Variable   ${cupn_codeGG}
    clear_jaldeecoupon  ${cupn_codeGG}
    ${resp}=  Create Jaldee Coupon  ${cupn_codeGG}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  true  true  0  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_codeGG}  ${disable_msg}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Jaldee Coupons By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain   ${resp.json()[0]}  jaldeeCouponCode  :  ${cupn_codeGG}
   
    ${resp}=   Encrypted Provider Login  ${PUSERNAME116}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Jaldee Coupons By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}  jaldeeCouponCode  :  ${cupn_codeGG}
   
    ${resp}=   Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Jaldee Coupons By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain   ${resp.json()[0]}  jaldeeCouponCode  :  ${cupn_codeGG}
    
    # ${resp}=   Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD} 
    # Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=  Get Jaldee Coupons By Provider
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Contain   ${resp.json()}  "jaldeeCouponCode":"${cupn_codeGG}"

JD-TC-GetJaldeeCoupons-10
    [Documentation]    Get jaldee coupon when coupon created for ALL domains, one subDomain and ALL License package

    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()} 
    Should Be Equal As Strings    ${resp.status_code}   200
    #Set Suite Variable   ${d1}    ${resp.json()['sector']}
    Set Suite Variable   ${sd1}    ${resp.json()['subSector']}
    

    ${alldomains}=  Jaldee Coupon Target Domains  ALL
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    #Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    ${loc1}=  Jaldee Coupon Target Locations  ${longi}  ${latti}  5
    ${loc2}=  Jaldee Coupon Target Locations  ${longi1}  ${latti1}  2
    ${locations}=  Create List  ${loc1}  ${loc2}
    ${licenses}=  Jaldee Coupon Target License  0
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_codeLL}=   FakerLibrary.word
    Set Suite Variable   ${cupn_codeLL}
    clear_jaldeecoupon  ${cupn_codeLL}
    ${resp}=  Create Jaldee Coupon  ${cupn_codeLL}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  true  true  0  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${alldomains}  ${sub_domains}  ALL  ${licenses}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_codeLL}  ${disable_msg}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Jaldee Coupons By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain   ${resp.json()[0]}  jaldeeCouponCode  :  ${cupn_codeLL}
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME60}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Jaldee Coupons By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}  jaldeeCouponCode  :  ${cupn_codeLL}
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME112}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Jaldee Coupons By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}  jaldeeCouponCode  :  ${cupn_codeLL}
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME113}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Jaldee Coupons By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}  jaldeeCouponCode  :  ${cupn_codeLL}
    
JD-TC-GetJaldeeCoupons -UH1
    [Documentation]   Get jaldee coupons by without login  
    ${resp}=  Get Jaldee Coupons By Provider
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-GetJaldeeCoupons -UH2
    [Documentation]   Consumer get jaldee coupons
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Jaldee Coupons By Provider
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"


