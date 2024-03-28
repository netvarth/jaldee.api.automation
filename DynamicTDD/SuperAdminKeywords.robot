*** Settings ***
Library           Collections
Library           String
Library           OperatingSystem
Library           json
Library           RequestsLibrary
Library           db.py
Resource          Keywords.robot
Library           Keywordspy.py

*** Variables ***
# ${SUPER_URL}      http://${SA_HOSTED_IP}/superadmin/rest/mgmt
# ${SUPPORT_URL}    http://${SA_HOSTED_IP}/superadmin/rest/support
${SUPER_URL}      ${SA_BASE_URL}/mgmt
${SUPPORT_URL}    ${SA_BASE_URL}/support
${longi}        89.524764
${latti}        88.259874
${longi1}       70.524764
${latti1}       88.259874

*** Keywords ***

SuperAdmin Login
    [Arguments]    ${usname}  ${passwrd}   
    ${pass2}=  Keywordspy.second_password
    ${login}=    Create Dictionary    loginId=${usname}  password=${passwrd}  secondPassword=${pass2}
    ${log}=    json.dumps    ${login}
    Create Session    synw    ${SUPER_URL}  headers=${headers}  
    ${resp}=    POST On Session     synw    /login    data=${log}   expected_status=any   
    RETURN  ${resp}

Check And Create YNW SuperAdmin Session
    # ${res}=     Run Keyword And Return Status   GET On Session    synw    /
    ${res}=   Session Exists    synw
    # Run Keyword Unless  ${res}   Create Session    synw    ${SUPER_URL}  headers=${headers}
    IF  not ${res}
        Create Session    synw    ${SUPER_URL}  headers=${headers}
    END

Check And Create YNW Support Session
    ${res}=     Session Exists    supportynw
    # Run Keyword Unless  ${res}   Create Session    supportynw    ${SUPPORT_URL}  headers=${headers}
    IF  not ${res}
        Create Session    supportynw    ${SUPPORT_URL}  headers=${headers}
    END
    

Check And Create YNW Rest Session
    ${res}=     Session Exists    syn
    # Run Keyword Unless  ${res}   Create Session    syn    ${SUPER_URL1}   headers=${headers}
    IF  not ${res}
        Create Session    syn    ${SUPER_URL1}  headers=${headers}
    END


SuperAdmin Change Password
    [Arguments]  ${oldpswd}  ${newpswd}
    ${auth}=    Create Dictionary    oldpassword=${oldpswd}    password=${newpswd}  
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session     synw    /login/chpwd    data=${apple}  expected_status=any
    RETURN  ${resp}

SuperAdmin Check Password
    [Arguments]    ${secondpass}
    ${login}=    Create Dictionary    secondPassword=${secondpass}
    ${log}=    json.dumps    ${login}
    Check And Create YNW SuperAdmin Session
    ${resp}=    POST On Session     synw    /login/checkpwd    data=${log}  expected_status=any
    RETURN  ${resp}

Get Licensable Packages For Superadmin
    Check And Create YNW Session
    ${resp}=    GET On Session    synw  /account/licensepackages  expected_status=any
    RETURN  ${resp} 

Get Addons Metadata For Superadmin
    Check And Create YNW Session
    ${resp}=    GET On Session    synw  /account/license/addonmetadata  expected_status=any
    RETURN  ${resp}

	
SuperAdmin Logout
    Check And Create YNW SuperAdmin Session
    ${resp}=    DELETE On Session     synw    /login  expected_status=any
    RETURN  ${resp}
    
HealthMonitor
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session     synw   /health  params=${kwargs}  expected_status=any
    RETURN  ${resp}

HealthMonitorId
    [Arguments]  ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session     synw   /health/${id}  expected_status=any
    RETURN  ${resp}

HealthMonitor Config
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session     synw   /health/config  params=${kwargs}  expected_status=any
    RETURN  ${resp}

HealthMonitor Count
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session     synw   /health/count  params=${kwargs}  expected_status=any
    RETURN  ${resp}

SuperAdmin Login Analytics
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session     synw   /login/analytics  expected_status=any
    RETURN  ${resp}

SuperAdmin Signup Analytics
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session     synw   /login/signup/analytics  expected_status=any
    RETURN  ${resp}


Get Config
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw  /health/config  expected_status=any
    RETURN  ${resp}


Get Health Status
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw  /health  params=${kwargs}  expected_status=any
    RETURN  ${resp}

Build Cache
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session   synw  /cache   expected_status=any
    RETURN  ${resp}

Schedule Maintenance
    [arguments]  ${date}  ${time}
    Check And Create YNW SuperAdmin Session
    ${data}=  Create Dictionary  maintenanceOn=${date}  maintenanceTime=${time}
    ${data}=    json.dumps  ${data}
    ${resp}=  POST On Session   synw  /maintenance  data=${data}  expected_status=any
    RETURN  ${resp}

Enable Maintenance
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw  /maintenance/true  expected_status=any
    RETURN  ${resp}

Disable Maintenance
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw  /maintenance/false  expected_status=any
    RETURN  ${resp}


Get Accounts
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw  /account   params=${kwargs}  expected_status=any  
    RETURN  ${resp}

Get Account Id 
    [Arguments]  ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session  synw  /account/${id}   expected_status=any
    RETURN  ${resp}

Get Accounts Count
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw  /account/count   params=${kwargs}  expected_status=any  
    RETURN  ${resp}

Get Service Sectors
   [Arguments]  &{kwargs}
   Check And Create YNW SuperAdmin Session
   ${resp}=  GET On Session   synw  /account/serviceSectors  params=${kwargs}  expected_status=any
   RETURN  ${resp}

Get Location BySuperadmin
   [Arguments]   ${id}
   Check And Create YNW SuperAdmin Session
   ${resp}=  GET On Session   synw  /account/locations/${id}  expected_status=any
   RETURN  ${resp}

Get AccountAnalytics
   [Arguments]  ${id}
   Check And Create YNW SuperAdmin Session
   ${resp}=  GET On Session   synw  /analytics/accounts/${id}  expected_status=any
   RETURN  ${resp}

Get ConsumerAnalytics
   [Arguments]  &{kwargs}
   Check And Create YNW SuperAdmin Session
   ${resp}=  GET On Session   synw  /analytics/consumers   params=${kwargs}  expected_status=any
   RETURN  ${resp}

Get Consumers
   [Arguments]  &{kwargs}
   Check And Create YNW SuperAdmin Session
   ${resp}=  GET On Session   synw  /consumer   params=${kwargs}  expected_status=any
   RETURN  ${resp}

Get ConsumersCount
   [Arguments]  &{kwargs}
   Check And Create YNW SuperAdmin Session
   ${resp}=  GET On Session   synw  /consumer/count   params=${kwargs}  expected_status=any
   RETURN  ${resp}

Superadmin Get ConsumerById
   [Arguments]  ${id}
   Check And Create YNW SuperAdmin Session
   ${resp}=  GET On Session   synw  /consumer/${id}  expected_status=any
   RETURN  ${resp}

Get ActiveAccounts
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw  /analytics      params=${kwargs}  expected_status=any  
    RETURN  ${resp}

Get AuditLog
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw  /auditlog     params=${kwargs}  expected_status=any
    RETURN  ${resp}

Get SortAuditLog
    [Arguments]  ${sort}=sortby_date   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw  /auditlog     params=${sort} ${kwargs}    expected_status=any
    RETURN  ${resp}

Get AuditLog Count
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw  /auditlog/count      params=${kwargs}  expected_status=any  
    RETURN  ${resp}

Get Account Config
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw  /account/config     params=${kwargs}  expected_status=any  
    RETURN  ${resp}

Get Signedup Consumers
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw  /analytics/consumers/count     params=${kwargs}  expected_status=any  
    RETURN  ${resp}

Superadmin GetWaitlistCount
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw  /analytics/waitlist/count      params=${kwargs}  expected_status=any  
    RETURN  ${resp}

Get Account Credentials
   [Arguments]  ${id}
   Check And Create YNW SuperAdmin Session
   ${resp}=  GET On Session  synw  /account/credentials/${id}  expected_status=any
   RETURN  ${resp}

Toggle Status
   [Arguments]  ${id}
   Check And Create YNW SuperAdmin Session
   ${resp}=  PUT On Session   synw  /account/toggleStatus/${id}  expected_status=any
   RETURN  ${resp}

Toggle StatusConsumer
   [Arguments]  ${id}
   Check And Create YNW SuperAdmin Session
   ${resp}=  PUT On Session   synw  /consumer/toggleStatus/${id}  expected_status=any
   RETURN  ${resp}

Delete Account
   [Arguments]  &{kwargs}
   Check And Create YNW SuperAdmin Session
   ${resp}=  DELETE On Session   synw  /account  params=${kwargs}  expected_status=any
   RETURN  ${resp}   

Delete Consumer
   [Arguments]  &{kwargs}
   Check And Create YNW SuperAdmin Session
   ${resp}=  DELETE On Session   synw  /consumer  params=${kwargs}  expected_status=any
   RETURN  ${resp}   

Verify Account
    [Arguments]  ${verifylevel}  ${verifiedby}  ${aid}
    ${verify}=    Create Dictionary    verifyLevel=${verifylevel}  verifiedBy=${verifiedby}  accountId=${aid}
    ${data}=    json.dumps    ${verify}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session     synw    /account/verify    data=${data}  expected_status=any
    RETURN  ${resp}

Get Consumers City
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw  /consumer/city     params=${kwargs}  expected_status=any  
    RETURN  ${resp}

Get Consumers State
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw  /consumer/state     params=${kwargs}  expected_status=any  
    RETURN  ${resp}

Support Login
   [Arguments]   ${usname}  ${passwrd}  
   ${secondpass}=  support_secondpassword
   ${supportlogin}=  Create Dictionary  loginId=${usname}  password=${passwrd}  secondPassword=${secondpass}
   ${log}=  json.dumps  ${supportlogin}
   Create Session    supportynw    ${SUPPORT_URL}  headers=${headers}    
   ${resp}=    POST On Session     supportynw    /login    data=${log}  expected_status=any
   RETURN  ${resp}

# Check And Create YNW Support Session
#     # ${res}=     Run Keyword And Return Status   GET On Session    supportynw    /
#     ${res}=   Session Exists    supportynw
#     Run Keyword Unless  ${res}   Create Session    supportynw    ${SUPPORT_URL}  headers=${headers}

Support Change Password
    [Arguments]  ${oldpswd}  ${newpswd}
    ${auth}=    Create Dictionary    oldpassword=${oldpswd}    password=${newpswd}  
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW Support Session
    ${resp}=    PUT On Session     supportynw   /login/chpwd    data=${apple}  expected_status=any
    RETURN  ${resp}

Support Check Password
    [Arguments]    ${secondpassword}
    ${supportlogin}=    Create Dictionary    secondPassword=${secondpassword}
    ${log}=    json.dumps    ${supportlogin}
    Check And Create YNW Support Session
    ${resp}=    POST On Session     supportynw    /login/checkpwd    data=${log}  expected_status=any
    RETURN  ${resp}

Support Logout
    Check And Create YNW Support Session
    ${resp}=    DELETE On Session     supportynw   /login   expected_status=any
    RETURN  ${resp}

Support Get Account
    [Arguments]   &{kwargs}
    Check And Create YNW Support Session
    ${resp}=    GET On Session   supportynw  /account   params=${kwargs}  expected_status=any
    RETURN  ${resp}

Support Get Account Count
    [Arguments]  &{kwargs}
    Check And Create YNW Support Session
    ${resp}=  GET On Session   supportynw  /account/count   params=${kwargs}  expected_status=any
    RETURN  ${resp}


Support Get Account Credentials
   [Arguments]  ${id}
   Check And Create YNW Support Session
   ${resp}=  GET On Session  supportynw  /account/credentials/${id}  expected_status=any
   RETURN  ${resp}


Apply Account License details
    [Arguments]  ${accid}  ${licensePackage}
    ${auth}=    Create Dictionary    accountId=${accid}   licensePackageId=${licensePackage} 
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=    POST On Session   synw   /account/license/apply   data=${apple}  expected_status=any
    RETURN  ${resp}


Change Account License details  
    [Arguments]  ${accid}  ${licensePackage}
    ${auth}=    Create Dictionary    accountId=${accid}   licensePackageId=${licensePackage} 
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session   synw   /account/license/change   data=${apple}  expected_status=any
    RETURN  ${resp} 
     
    
GET Account License details
    [Arguments]  ${accountid}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/license/${accountid}  expected_status=any
    RETURN  ${resp} 
    
Get License Transaction details
    [Arguments]  ${accountid}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/license/auditlog/${accountid}   expected_status=any
    RETURN  ${resp} 
    
Get Licensable Package details
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/licensepackages   expected_status=any
    RETURN  ${resp} 
    
Get Account Addon details
    [Arguments]  ${accountid}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/license/addon/${accountid}   expected_status=any
    RETURN  ${resp} 

Add Addons details
    [Arguments]  ${accid}  ${addonid}
    ${auth}=    Create Dictionary    accountId=${accid}   addonIds=${addonid} 
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=    POST On Session   synw   /account/license/addon/add   data=${apple}  expected_status=any
    RETURN  ${resp} 
   
Get Invoices superadmin
    [Arguments]  ${accountId}  ${subscriptionPaymentStatus}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /account/license/invoice/${accountId}/${subscriptionPaymentStatus}
    RETURN  ${resp}

Invoice Discount apply 
    [Arguments]    ${uid}   ${name}   ${description}    ${calculationType}   ${discValue}  
    ${discount}=   Create Dictionary   name=${name}   description=${description}    calculationType=${calculationType}   discountValue=${discValue}  
    ${data}=  Create Dictionary    uuid=${uid}   discount=${discount}
    ${data}=  json.dumps  ${data} 
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session  synw  /account/license/invoice/disc   data=${data}  expected_status=any
    RETURN  ${resp}
 
AcceptPayment By Superadmin
    [Arguments]   ${uuid}  ${acceptPaymentBy}  ${collectedBy}  ${collectedDate}   ${note}     ${amountToPay}
    ${data}=   Create Dictionary   uuid=${uuid}  acceptPaymentBy=${acceptPaymentBy}   collectedBy=${collectedBy}  collectedDate=${collectedDate}  note=${note}    amountToPay=${amountToPay}
    ${auth}=    json.dumps  ${data} 
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session  synw  /account/license/invoice/acceptPayment   data=${auth}  expected_status=any
    RETURN  ${resp}

Cancel Invoice
    [Arguments]  ${uuid}  ${cancelReason}
    ${data}=  Create Dictionary   uuid=${uuid}   cancelReason=${cancelReason}
    ${auth}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw  /account/license/invoice   data=${auth}  expected_status=any
    RETURN  ${resp}

Statement Details
    [Arguments]  ${uuid} 
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /account/license/invoice/${uuid}  expected_status=any
    RETURN  ${resp}

Remove Addon details
    [Arguments]  ${accid}  ${addonid}
    ${auth}=    Create Dictionary    accountId=${accid}   addonId=${addonid}  expected_status=any 
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=    DELETE On Session   synw   /account/license/addon/${accid}/${addonid}   data=${apple}  expected_status=any
    RETURN  ${resp}
    
Get Account AddonsMetadata details
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/license/addonmetadata  expected_status=any 
    RETURN  ${resp} 

Get Addon Transactions details
    [Arguments]  ${accountid}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/license/addon/auditlog/${accountid}  expected_status=any 
    RETURN  ${resp} 
                                  
Get day out of compliance
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/license/dayoutofcomplaince  expected_status=any 
    RETURN  ${resp} 
    
Get month out of compliance
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/license/monthoutofcomplaince  expected_status=any 
    RETURN  ${resp} 

Get License Analytics according to package 
    [Arguments]  ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/license/analytics/${id}  expected_status=any 
    RETURN  ${resp}

Get License Analytics
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/license/analytics/packages  expected_status=any 
    RETURN  ${resp}  
    
Update License Renewal Details
    [Arguments]  ${accid}  ${rsn}  ${durtn}
    ${auth}=    Create Dictionary    accountId=${accid}   Reason=${rsn}   duration=${durtn}
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session   synw   /account/license/renewal   data=${apple}  expected_status=any
    RETURN  ${resp}          

SuperAdmin Change License
    [Arguments]  ${accountId}  ${licensePackageId}  
    ${auth}=    Create Dictionary    accountId=${accountId}   licensePackageId=${licensePackageId}   
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session   synw  /account/license/change   data=${apple}  expected_status=any
    RETURN  ${resp}       

SuperAdmin Add Addon
    [Arguments]  ${accountId}  ${addonIds}  
    ${auth}=    Create Dictionary    accountId=${accountId}   addonIds=${addonIds}   
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=    POST On Session   synw  /account/license/addon/add   data=${apple}  expected_status=any
    RETURN  ${resp}

SuperAdmin delete Addon
    [Arguments]  ${accountId}  ${addonIds} 
    Check And Create YNW SuperAdmin Session
    ${resp}=    DELETE On Session   synw  /account/license/addon/${accountId}/${addonIds}  expected_status=any
    RETURN  ${resp} 

Create Jaldee Coupon
    [Arguments]  ${code}  ${name}  ${des}  ${age}  ${sDate}  ${eDate}  ${d_type}  ${d_value}  ${d_max}  ${def_enable}  ${al_enable}  ${max_rem}  ${amt}  ${pro_use}  ${cons_use}  ${limit_prov}  ${c_first_ckn}  ${p_first_ckn}  ${self_pay}  ${online_ckn}  ${combine}  ${c_terms}  ${p_desc}  ${dom}  ${s_dom}  ${loc}  ${license}  &{kwargs} 
    ${rules}=    Create Dictionary    defaultEnabled=${def_enable}  alwaysEnabled=${al_enable}  maxReimbursePercentage=${max_rem}  minBillAmount=${amt}  maxProviderUseLimit=${pro_use}  maxConsumerUseLimit=${cons_use}  maxConsumerUseLimitPerProvider=${limit_prov}  firstCheckinOnly=${c_first_ckn}  firstCheckinPerProviderOnly=${p_first_ckn}  selfPaymentRequired=${self_pay}  onlineCheckinRequired=${online_ckn}  combineWithOtherCoupon=${combine}  ageGroup=${age}  startDate=${sDate}  endDate=${eDate}
    ${targetDate}=  Get Dictionary items  ${kwargs}
    FOR  ${key}  ${value}  IN  @{targetDate}
        Set To Dictionary  ${rules}   ${key}=${value}
    END
    Log  ${rules}
    ${location}=  Create List  ${loc}
    ${tar}=   Create Dictionary    domain=${dom}  subdomain=${s_dom}  couponLocation=${location}  licenseRequired=${license}
    ${coupon_det}=  Create Dictionary  jaldeeCouponCode=${code}  couponName=${name}  couponDescription=${des}  consumerTermsAndconditions=${c_terms}  providerDescription=${p_desc}  discountType=${d_type}  discountValue=${d_value}  maxDiscountValue=${d_max}   couponRules=${rules}  target=${tar}
    ${coupon}=    json.dumps    ${coupon_det}
    Log  ${coupon}
    Check And Create YNW SuperAdmin Session
    ${resp}=    POST On Session   synw   /jc    data=${coupon}  expected_status=any
    RETURN  ${resp} 

Jaldee Coupon Target Locations
    [Arguments]  ${long}  ${latti}  ${rad}
    ${loc}=    Create Dictionary    longitude=${long}   latitude=${latti}  radius=${rad}
    RETURN  ${loc} 

Jaldee Coupon Target Domains
    [Arguments]  @{dom}
    RETURN  ${dom} 

Jaldee Coupon Target SubDomains
    [Arguments]  @{s_dom}
    RETURN  ${s_dom} 

Jaldee Coupon Target License
    [Arguments]  @{lic}
    RETURN  ${lic} 


Create Jaldee Coupon For Providers
    [Arguments]  ${code}  ${name}  ${des}  ${age}  ${sDate}  ${eDate}  ${d_type}  ${d_value}  ${d_max}  ${def_enable}  ${al_enable}  ${max_rem}  ${amt}  ${pro_use}  ${cons_use}  ${limit_prov}  ${c_first_ckn}  ${p_first_ckn}  ${self_pay}  ${online_ckn}  ${combine}  ${c_terms}  ${p_desc}  ${p_id}
    ${rules}=    Create Dictionary    defaultEnabled=${def_enable}  alwaysEnabled=${al_enable}  maxReimbursePercentage=${max_rem}  minBillAmount=${amt}  maxProviderUseLimit=${pro_use}  maxConsumerUseLimit=${cons_use}  maxConsumerUseLimitPerProvider=${limit_prov}  firstCheckinOnly=${c_first_ckn}  firstCheckinPerProviderOnly=${p_first_ckn}  selfPaymentRequired=${self_pay}  onlineCheckinRequired=${online_ckn}  combineWithOtherCoupon=${combine}  ageGroup=${age}  startDate=${sDate}  endDate=${eDate}
    ${tar}=   Create Dictionary    providerId=${p_id} 
    ${coupon_det}=  Create Dictionary  jaldeeCouponCode=${code}  couponName=${name}  couponDescription=${des}  consumerTermsAndconditions=${c_terms}  providerDescription=${p_desc}  discountType=${d_type}  discountValue=${d_value}  maxDiscountValue=${d_max}  couponRules=${rules}  target=${tar}
    ${coupon}=    json.dumps    ${coupon_det}
    Check And Create YNW SuperAdmin Session
    ${resp}=    POST On Session   synw   /jc    data=${coupon}  expected_status=any
    RETURN  ${resp}

Create Sample Jaldee Coupon
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    ${domains}=  Jaldee Coupon Target Domains  ALL
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ALL
    ${licenses}=  Jaldee Coupon Target License  0
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10   
    ${resp}=  Create Jaldee Coupon  XMASCoupon2018  Onam Coupon  Onam offer  CHILDREN  ${DAY1}  ${DAY2}  AMOUNT  50  100  false  false  100  1000  1000  5  2  false  false  false  false  false  consumer first use  50% offer  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    RETURN  ${resp}

Create Sample Jaldee Coupon For Providers
    ${p1}=  get_acc_id  ${PUSERNAME2}
    ${p2}=  get_acc_id  ${PUSERNAME1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    ${resp}=  Create Jaldee Coupon For Providers  coupon1  Coupon1  Xmas offer   STUDENT  ${DAY1}  ${DAY2}  PERCENTAGE  50  100  false  false  100  250  1000  5  2  true  true  false  true  false  consumer first use  50% offer  ${p1}  ${p2}
    Should Be Equal As Strings  ${resp.status_code}  200

Get Jaldee Coupon By CouponCode
    [Arguments]  ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /jc/${id}  expected_status=any
    RETURN  ${resp} 

Get Jaldee Coupons
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /jc  expected_status=any  
    RETURN  ${resp} 

Get Jaldee Coupons Count
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /jc/count   params=${kwargs}  expected_status=any
    RETURN  ${resp} 

Get Jaldee Coupons Stats
    [Arguments]  ${code}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /jc/${code}/stats  expected_status=any
    RETURN  ${resp} 

Update Jaldee Coupon
    [Arguments]  ${jcode}  ${code}  ${name}  ${des}  ${age}  ${sDate}  ${eDate}  ${d_type}  ${d_value}  ${d_max}  ${def_enable}  ${al_enable}  ${max_rem}  ${amt}  ${pro_use}  ${cons_use}  ${limit_prov}  ${c_first_ckn}  ${p_first_ckn}  ${self_pay}  ${online_ckn}  ${combine}  ${c_terms}  ${p_desc}  ${dom}  ${s_dom}  ${loc}  ${license}
    ${rules}=    Create Dictionary    defaultEnabled=${def_enable}  alwaysEnabled=${al_enable}  maxReimbursePercentage=${max_rem}  minBillAmount=${amt}  maxProviderUseLimit=${pro_use}  maxConsumerUseLimit=${cons_use}  maxConsumerUseLimitPerProvider=${limit_prov}  firstCheckinOnly=${c_first_ckn}  firstCheckinPerProviderOnly=${p_first_ckn}  selfPaymentRequired=${self_pay}  onlineCheckinRequired=${online_ckn}  combineWithOtherCoupon=${combine}  ageGroup=${age}  startDate=${sDate}  endDate=${eDate}
    ${location}=  Create List  ${loc}
    ${tar}=   Create Dictionary    domain=${dom}  subdomain=${s_dom}  couponLocation=${location}  licenseRequired=${license}
    ${coupon_det}=  Create Dictionary  jaldeeCouponCode=${code}  couponName=${name}  couponDescription=${des}  consumerTermsAndconditions=${c_terms}  providerDescription=${p_desc}  discountType=${d_type}  discountValue=${d_value}  maxDiscountValue=${d_max}   couponRules=${rules}  target=${tar}
    ${coupon}=    json.dumps    ${coupon_det}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session   synw   /jc/${jcode}   data=${coupon}  expected_status=any
    RETURN  ${resp} 

Update Jaldee Coupon After Push
    [Arguments]  ${jcode}  ${name}  ${des}  ${eDate}  ${c_terms}  ${p_desc}
    ${coupon_det}=  Create Dictionary  couponName=${name}  couponDescription=${des}  consumerTermsAndconditions=${c_terms}  providerDescription=${p_desc}  newEndDate=${eDate}
    ${coupon}=    json.dumps    ${coupon_det}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session   synw   /jc/${jcode}   data=${coupon}  expected_status=any
    RETURN  ${resp} 

Update Jaldee Coupon For Providers
    [Arguments]  ${jcode}  ${code}  ${name}  ${des}  ${age}  ${sDate}  ${eDate}  ${d_type}  ${d_value}  ${d_max}  ${def_enable}  ${al_enable}  ${max_rem}  ${amt}  ${pro_use}  ${cons_use}  ${limit_prov}  ${c_first_ckn}  ${p_first_ckn}  ${self_pay}  ${online_ckn}  ${combine}  ${c_terms}  ${p_desc}  ${p_id}
    ${rules}=    Create Dictionary     defaultEnabled=${def_enable}  alwaysEnabled=${al_enable}  maxReimbursePercentage=${max_rem}  minBillAmount=${amt}  maxProviderUseLimit=${pro_use}  maxConsumerUseLimit=${cons_use}  maxConsumerUseLimitPerProvider=${limit_prov}  firstCheckinOnly=${c_first_ckn}  firstCheckinPerProviderOnly=${p_first_ckn}  selfPaymentRequired=${self_pay}  onlineCheckinRequired=${online_ckn}  combineWithOtherCoupon=${combine}  ageGroup=${age}  startDate=${sDate}  endDate=${eDate}
    ${tar}=   Create Dictionary    providerId=${p_id} 
    ${coupon_det}=  Create Dictionary  jaldeeCouponCode=${code}  couponName=${name}  couponDescription=${des}  consumerTermsAndconditions=${c_terms}  providerDescription=${p_desc}   discountType=${d_type}  discountValue=${d_value}  maxDiscountValue=${d_max}   couponRules=${rules}  target=${tar}
    ${coupon}=    json.dumps    ${coupon_det}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session   synw   /jc/${jcode}    data=${coupon}  expected_status=any
    RETURN  ${resp}

Update Jaldee Coupon For Providers After Push
    [Arguments]  ${jcode}  ${name}  ${des}  ${eDate}  ${c_terms}  ${p_desc}
    ${coupon_det}=  Create Dictionary  couponName=${name}  couponDescription=${des}  consumerTermsAndconditions=${c_terms}  providerDescription=${p_desc}   newEndDate=${eDate}
    ${coupon}=    json.dumps    ${coupon_det}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session   synw   /jc/${jcode}    data=${coupon}  expected_status=any
    RETURN  ${resp}


Delete Jaldee Coupon
   [Arguments]  ${coupon_code}
   Check And Create YNW SuperAdmin Session
   ${resp}=  DELETE On Session   synw  /jc/${coupon_code}  expected_status=any
   RETURN  ${resp}

Disable Jaldee Coupon
   [Arguments]  ${coupon_code}  ${msg}
   ${message}=    Create Dictionary    message=${msg}
   ${data}=    json.dumps    ${message}
   Check And Create YNW SuperAdmin Session
   ${resp}=  PUT On Session   synw  /jc/${coupon_code}/disable   data=${data}  expected_status=any
   RETURN  ${resp}

Push Jaldee Coupon
   [Arguments]  ${coupon_code}  ${msg}
    ${message}=    Create Dictionary    message=${msg}
    ${data}=    json.dumps    ${message}
   Check And Create YNW SuperAdmin Session
   ${resp}=  POST On Session   synw  /jc/${coupon_code}/push    data=${data}  expected_status=any
   RETURN  ${resp}

Get Reimburse Reports
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /jc/reports  expected_status=any
    RETURN  ${resp} 

Get Reimburse Reports Count
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw    /jc/reports/count  params=${kwargs}  expected_status=any
    RETURN  ${resp} 

 
Reimburse Ivoices
    [Arguments]  ${invoice_id}  ${dis_note}  ${pay_mode}  ${private_note}  ${for}  &{kwargs}
    ${invoice}=  Create Dictionary  invoiceId=${invoice_id}
    ${items}=  Get Dictionary items  ${kwargs}
    ${data}=  Create Dictionary  invoice=${invoice}  displayNote=${dis_note}  jaldeePaymentmode=${pay_mode}  privateNote=${private_note}  jaldeeReimburseFor=${for} 
    FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    RETURN  ${data}

# Reimburse Ivoices
#     [Arguments]  ${invoice_id}  ${dis_note}  ${pay_mode}  ${jbank_total}  ${jc_total}   ${grand_total}  ${private_note}
#     ${invoice}=  Create Dictionary  invoiceId=${invoice_id}
#     ${data}=  Create Dictionary   invoice=${invoice}  displayNote=${dis_note}  jaldeePaymentmode=${pay_mode}  jbankTotal=${jbank_total}  jcTotal=${jc_total}  grandTotal=${grand_total}  privateNote=${private_note}  
#     RETURN  ${data}

Reimburse Payment
   [Arguments]  ${invoices} 
   ${data}=    json.dumps    ${invoices}
   Check And Create YNW SuperAdmin Session
   ${resp}=  POST On Session   synw   /jc/reimburse     data=${data}  expected_status=any
   RETURN  ${resp}

Get Reimbursement By InvoiceId
    [Arguments]  ${invoice_id}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw    /jc/reimburse/${invoice_id}  expected_status=any
    RETURN  ${resp} 

Change Reimbursement Status
    [Arguments]  ${invoice_id}  ${status}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session   synw    /jc/reimburse/${invoice_id}/${status}  expected_status=any
    RETURN  ${resp} 

Payu Verification
   [Arguments]  ${acc_id}
   Check And Create YNW SuperAdmin Session
   ${resp}=  POST On Session   synw   /payment/payu/${acc_id}  expected_status=any
   RETURN  ${resp}

Change Provider Phoneno
   [Arguments]  ${acc_id}  ${phone_no}
   ${data}=    Create Dictionary    accountId=${acc_id}  phone=${phone_no}
   ${data1}=    json.dumps    ${data}
   Check And Create YNW SuperAdmin Session
   ${resp}=  PUT On Session   synw   /account/settings/changePrimaryPhone   data=${data1}  expected_status=any
   RETURN  ${resp}

# Create Corporate
#     [Arguments]  ${c_uid}  ${c_name}  ${c_code}  ${multilevel}   ${email}  ${phone}  ${contact_name}  ${contact_lname}  ${contact_phone}  ${dn}  ${sbDn}  ${lId} 
#     ${data}=  Create Dictionary  corporateUid=${c_uid}  corporateName=${c_name}  corporateCode=${c_code}  multilevel=${multilevel}  officeEmail=${email}  officePhone=${phone}  contactPersonFirstName=${contact_name}  contactPersonLastName=${contact_lname}  contactPersonMobNo=${contact_phone}  domain=${dn}  subDomain=${sbDn}  licPkgId=${lId} 
#     ${data}=  json.dumps  ${data}
#     Check And Create YNW SuperAdmin Session
#     ${resp}=  POST On Session   synw  /corporate  data=${data}  expected_status=any
#     RETURN  ${resp}

Create Corporate
    [Arguments]    ${c_name}  ${c_code}  ${email}  ${phone}  ${contact_name}  ${contact_lname}  ${contact_phone}   ${domain}  ${subDomain}  ${licPkgId}
    ${data}=  Create Dictionary   corporateName=${c_name}  corporateCode=${c_code}  officeEmail=${email}  officePhone=${phone}  contactPersonFirstName=${contact_name}  contactPersonLastName=${contact_lname}  contactPersonMobNo=${contact_phone}  domain=${domain}  subDomain=${subDomain}  licPkgId=${licPkgId}  multilevel=True
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session   synw  /corporate  data=${data}  expected_status=any
    RETURN  ${resp}

Get Corporate
    [Arguments]  ${c_id}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw    /corporate/${c_id}  expected_status=any
    RETURN  ${resp} 

Update Corporate
    [Arguments]  ${c_id}  ${c_uid}  ${c_name}  ${c_code}  ${email}  ${phone}  ${contact_name}  ${contact_lname}  ${contact_phone}
    ${data}=  Create Dictionary  corporateId=${c_id}  corporateUid=${c_uid}  corporateName=${c_name}  corporateCode=${c_code}  officeEmail=${email}  officePhone=${phone}  contactPersonFirstName=${contact_name}  contactPersonLastName=${contact_lname}  contactPersonMobNo=${contact_phone}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw  /corporate  data=${data}  expected_status=any
    RETURN  ${resp}

Update CorporateCenter
    [Arguments]  ${c_id}  ${c_uid}  ${c_name}  ${c_mob}  ${domain}  ${sub_domain}  ${center}
    ${data}=  Create Dictionary  corporateId=${c_id}  corporateUid=${c_uid}  corporateName=${c_name}   contactPersonMobNo=${c_mob}  domain=${domain}  subDomain=${sub_domain}  centralised=${center}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw  /corporate  data=${data}  expected_status=any
    RETURN  ${resp}

Get Corporates
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw    /corporate   params=${kwargs}  expected_status=any
    RETURN  ${resp} 

Get verification Level For Independent-SP Byid
    [Arguments]  ${accId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw   /account/verification/${accId}  expected_status=any
    RETURN  ${resp}
 
Get verification Level History For Independent-SP
    [Arguments]   ${accId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw   /account/verification/logs/${accId}  expected_status=any
    RETURN  ${resp}

Create verification Level For Independent-SP 
    [Arguments]   ${accId}   ${verifylevel}  ${verifyLink}  ${verifynote}  ${verifiedby}  ${verifiedOn}  ${d_applied}  ${t_chrged}  ${t_coll}  ${pay_M}  ${pay_by}  ${p_note}
    ${verification_D}=  Create Dictionary   verifyLink=${verifyLink}  verifiedNote=${verifynote}   verifiedBy=${verifiedby}  verifiedOn=${verifiedOn} 
    ${payment_D}=   Create Dictionary  discountApplied=${d_applied}  totalCharged=${t_chrged}  totalCollected=${t_coll}  paymentMode=${pay_M}  paymentDoneBy=${pay_by} 
    ${auth}=  Create Dictionary  accountId=${accId}  verifiedLevel=${verifylevel}  verificationDetails=${verification_D}  paymentDetails=${payment_D}  privateNote=${p_note}
    ${auth}=  json.dumps  ${auth} 
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session   synw      /account/verification     data=${auth}  expected_status=any
    RETURN  ${resp}

Create verification Level For Corporate
    [Arguments]    ${c_id}   ${verifylevel}  ${verifyLink}  ${verifynote}  ${verifiedby}  ${verifiedOn}  ${d_applied}  ${t_chrged}  ${t_coll}  ${pay_M}  ${pay_by}  ${p_note}
    ${verification_D}=  Create Dictionary   verifyLink=${verifyLink}  verifiedNote=${verifynote}   verifiedBy=${verifiedby}  verifiedOn=${verifiedOn} 
    ${payment_D}=   Create Dictionary  discountApplied=${d_applied}  totalCharged=${t_chrged}  totalCollected=${t_coll}  paymentMode=${pay_M}  paymentDoneBy=${pay_by} 
    ${auth}=  Create Dictionary  corpId=${c_id}  verifiedLevel=${verifylevel}  verificationDetails=${verification_D}  paymentDetails=${payment_D}  privateNote=${p_note}
    ${auth}=  json.dumps  ${auth} 
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session   synw     /corporate/verification    data=${auth}  expected_status=any
    RETURN  ${resp}

Get verification Level For Corporate- Byid
    [Arguments]  ${c_id}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw    /corporate/verification/${c_id}  expected_status=any
    RETURN  ${resp}
 
Get verification Level History For Corporate
    [Arguments]  ${c_id}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw  /corporate/verification/logs/${c_id}  expected_status=any
    RETURN  ${resp}	


	
Update verification Level For Independent-SP
    [Arguments]   ${accId}   ${verifylevel}    ${verifyLink}  ${verifynote}  ${verifiedby}  ${verifiedOn}  ${d_applied}  ${t_chrged}  ${t_coll}  ${pay_M}  ${pay_by}  ${p_note}
    ${verification_D}=  Create Dictionary   verifyLink=${verifyLink}  verifiedNote=${verifynote}   verifiedBy=${verifiedby}   verifiedOn=${verifiedOn} 
    ${payment_D}=   Create Dictionary  discountApplied=${d_applied}  totalCharged=${t_chrged}  totalCollected=${t_coll}  paymentMode=${pay_M}  paymentDoneBy=${pay_by} 
    ${auth}=  Create Dictionary  accountId=${accId}  verifiedLevel=${verifylevel}  verificationDetails=${verification_D}  paymentDetails=${payment_D}   privateNote=${p_note}
    ${auth}=  json.dumps  ${auth} 
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw  /account/verification  data=${auth}  expected_status=any
    RETURN  ${resp}

Update corporate verification Level 
    [Arguments]   ${c_id}   ${verifylevel}    ${verifyLink}  ${verifynote}  ${verifiedby}  ${verifiedOn}  ${d_applied}  ${t_chrged}  ${t_coll}  ${pay_M}  ${pay_by}  ${p_note}
    ${verification_D}=  Create Dictionary   verifyLink=${verifyLink}  verifiedNote=${verifynote}   verifiedBy=${verifiedby}   verifiedOn=${verifiedOn} 
    ${payment_D}=   Create Dictionary  discountApplied=${d_applied}  totalCharged=${t_chrged}  totalCollected=${t_coll}  paymentMode=${pay_M}  paymentDoneBy=${pay_by} 
    ${auth}=  Create Dictionary  corpId=${c_id}  verifiedLevel=${verifylevel}  verificationDetails=${verification_D}  paymentDetails=${payment_D}   privateNote=${p_note}
    ${auth}=  json.dumps  ${auth} 
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw  /corporate/verification  data=${auth}  expected_status=any
    RETURN  ${resp}
 
Branch Signup by Superadmin
   [Arguments]  ${cop_id}  ${name}  ${code}  ${reg_code}  ${email}  ${desc}  ${pass}  ${p_name}  ${p_l_name}  ${city}  ${state}  ${address}  ${mob_no}  ${al_phone}  ${dob}  ${gender}  ${p_email}  ${country_code}  ${is_admin}  ${sector}  ${sub_sector}  ${licpkg}  @{vargs}
   ${provider}=  Create Dictionary  firstName=${p_name}  lastName=${p_l_name}  city=${city}  state=${state}  address=${address}  primaryMobileNo=${mob_no}  alternativePhoneNo=${al_phone}  dob=${dob}  gender=${gender}  email=${p_email}  countryCode=${country_code}
   ${profile}=  Create Dictionary  userProfile=${provider}  isAdmin=${is_admin}  sector=${sector}  subSector=${sub_sector}  licPkgId=${licpkg}
   ${data}=  Create Dictionary  corpId=${cop_id}  branchName=${name}  branchCode=${code}  regionalCode=${reg_code}  branchEmail=${email}  branchDescription=${desc}  commonPassword=${pass}  provider=${profile}   services=${vargs}
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  POST On Session  synw   /sa/branch   data=${data}  expected_status=any
   RETURN  ${resp}


Branch_Profile by Superadmin
    [Arguments]  ${bName}  ${bDesc}  ${shname}   ${place}  ${longi}  ${latti}  ${g_url}  ${pin}  ${adds}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${ph1}  ${ph2}  ${email1}
    ${bs}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}
    ${bs}=  Create List  ${bs}
    ${bs}=  Create Dictionary  timespec=${bs}
    ${b_loc}=  Create Dictionary  place=${place}  longitude=${longi}  lattitude=${latti}  googleMapUrl=${g_url}  pinCode=${pin}  address=${adds}  parkingType=${pt}  open24hours=${oh}   bSchedule=${bs}
    ${ph_nos}=  Create List  ${ph1}  ${ph2}
    ${emails}=  Create List  ${email1}
    ${data}=  Create Dictionary  businessName=${bName}  businessDesc=${bDesc}  shortName=${shname}  baseLocation=${b_loc}  phoneNumbers=${ph_nos}  emails=${emails}
    ${data}=  json.dumps  ${data}
    RETURN  ${data}

Branch Business Profile by Superadmin
    [Arguments]   ${acct_id}  ${bName}  ${bDesc}  ${shname}   ${place}   ${longi}  ${latti}  ${g_url}  ${pin}  ${adds}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${ph1}  ${ph2}  ${email1}
    ${data}=  Branch_Profile by Superadmin  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pin}  ${adds}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${ph1}  ${ph2}  ${email1}
    ${params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  synw  /sa/bProfile  data=${data}    params=${params}  expected_status=any
    RETURN  ${resp}

Enable/Disable Branch Search Data by superadmin
    [Arguments]   ${acct_id}  ${status}
    ${params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${resp}=  PUT On Session  synw   /sa/search/${status}    params=${params}  expected_status=any
    RETURN  ${resp}
      
    
Enable Department Filter
    [Arguments]  ${acct_id}
    ${params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${resp}=  PUT On Session  synw  /sa/branch/department/Enable  params=${params}  expected_status=any
    RETURN  ${resp}
    
Disable Department Filter
    [Arguments]  ${acct_id}
    ${params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${resp}=  PUT On Session  synw  /sa/branch/department/Disable  params=${params}  expected_status=any
    RETURN  ${resp}


Update Business Profile Of Branch For Specialization by superadmin
    [Arguments]  ${acct_id}  @{data}   
    ${params}=  Create Dictionary  account=${acct_id} 
    ${data}=  Create Dictionary  specialization=${data}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  synw  /sa/bProfile   data=${data}  params=${params}  expected_status=any
    RETURN  ${resp}   
    

Create Subscription License Discount
    [Arguments]  ${lDName}  ${desn}  ${ldisc}  ${vaFrom}  ${vaTo}  ${lDType}  ${sectorid}   ${subsectorid}   ${cId}  ${acId}  ${lPkgLevel}  ${lPkgId}   ${lDiSts}  ${combinedMultipleDisc} 
    # ${sectorid}=   Create List  ${sectorid}
    # ${subsectorid}=  Create List   ${subsectorid}
    ${data}=  Create Dictionary  licDiscName=${lDName}   description=${desn}  licDiscCode=${ldisc}  validFrom=${vaFrom}  validTo=${vaTo}  licDiscType=${lDType}  sectorIds=${sectorid}  subsectorIds=${subsectorid}  corpIds=${cId}  accountIds=${acId}    licPkgMinimumLevel=${lPkgLevel}  licPkgId=${lPkgId}    licDiscStatus=${lDiSts}  combinedMultipleDisc=${combinedMultipleDisc} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session   synw     /license/discount   data=${data}  expected_status=any   
    RETURN  ${resp}


Update Subscription License Discount
    [Arguments]  ${licDiscountId}  ${lDName}  ${desn}  ${ldisc}  ${vaFrom}  ${vaTo}  ${lDType}  ${seId}  ${subsId}   ${cId}  ${acId}  ${lPkgLevel}  ${lPkgId}   ${lDiSts}  ${combinedMultipleDisc} 
    ${data}=  Create Dictionary  licDiscName=${lDName}   description=${desn}  licDiscCode=${ldisc}  validFrom=${vaFrom}  validTo=${vaTo}  licDiscType=${lDType}  sectorId=${seId}  subsectorId=${subsId}  corpId=${cId}  accountId=${acId}    licPkgMinimumLevel=${lPkgLevel}  licPkgId=${lPkgId}    licDiscStatus=${lDiSts}  combinedMultipleDisc=${combinedMultipleDisc} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw     /license/discount/${licDiscountId}   data=${data}  expected_status=any   
    RETURN  ${resp}

Update Subscription License Discount code
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw    /license/discount   params=${kwargs}  expected_status=any 
    RETURN  ${resp}   


Get Subscription License Discount By op
     [Arguments]  &{kwargs}
     Check And Create YNW SuperAdmin Session
     ${resp}=    GET On Session   synw   /license/discount    params=${kwargs}  expected_status=any 
     RETURN  ${resp} 

Get Subscription License Discount By LicenseDsid
    [Arguments]  ${Licdid}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /license/discount/${Licdid}  expected_status=any 
    RETURN  ${resp} 

Delete Subscription License Discount 
     [Arguments]  &{kwargs}
     Check And Create YNW SuperAdmin Session
     ${resp}=    DELETE On Session   synw  license/discount   params=${kwargs}  expected_status=any 
     RETURN  ${resp} 

Delete Subscription License Discount by id
     [Arguments]   ${licDiscountId}
     Check And Create YNW SuperAdmin Session
     ${resp}=    DELETE On Session   synw   license/discount/${licDiscountId}  expected_status=any    
     RETURN  ${resp} 

Change Corporate License
    [Arguments]  ${ci_d}  ${licPkgid}
    ${auth}=    Create Dictionary    corpId=${ci_d}  licPkgId=${licPkgid} 
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session   synw  /corporate/${ci_d}/license/${licPkgid}    data=${apple}  expected_status=any
    RETURN  ${resp} 

Get corporate license details
    [Arguments]  ${ci_d}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw  /corporate/${ci_d}/license  expected_status=any
    RETURN  ${resp}  


Change corporate Addon    
    [Arguments]  ${ci_d}  ${AddonId} 
    ${auth}=    Create Dictionary    corpId=${ci_d}  AddonId=${AddonId} 
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=   PUT On Session    synw    corporate/${ci_d}/addon/${AddonId}    data=${apple}  expected_status=any
    RETURN  ${resp}


Delete Corporate Addon    
    [Arguments]  ${ci_d}  ${AddonId}
    ${auth}=    Create Dictionary    corpId=${ci_d}  AddonId=${AddonId} 
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session  
    ${resp}=    DELETE On Session   synw   corporate/${ci_d}/addon/${AddonId}    data=${apple}  expected_status=any
    RETURN  ${resp}

Renew Corporate License 
    [Arguments]  ${ci_d}   ${Reason}   ${duration} 
    ${auth}=    Create Dictionary   corpId=${ci_d}  reason=${Reason}   duration=${duration}
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw   /corporate/license/renewal   data=${apple}   expected_status=any
    RETURN  ${resp}


Create License Discount code
    [Arguments]  ${Lcode}  ${desn}  ${lcdsp}
    ${data}=  Create Dictionary  licDiscCode=${Lcode}   description=${desn}  licDiscPercentage=${lcdsp}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session   synw    /license/discount/code   data=${data}  expected_status=any   
    RETURN  ${resp}

Update license discount code
     [Arguments]  ${id}  ${Lcode}  ${desn}  ${lcdsp}   
     ${data}=  Create Dictionary   licDiscCode=${Lcode}   description=${desn}  licDiscPercentage=${lcdsp}
     ${data}=  json.dumps  ${data}
     Check And Create YNW SuperAdmin Session
     ${resp}=  PUT On Session   synw   /license/discount/code/${id}   data=${data}  expected_status=any   
     RETURN  ${resp}


Get license discount codes by optional
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /license/discount/code   params=${kwargs}  expected_status=any 
    RETURN  ${resp}   

Get license discount code details by discCodeId 
    [Arguments]  ${discCodeId}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw    /license/discount/code/${discCodeId}  expected_status=any
    RETURN  ${resp} 


Delete license discount code by discCodeId 
    [Arguments]  ${discCodeId}
    ${auth}=    Create Dictionary  
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session  
    ${resp}=    DELETE On Session   synw   /license/discount/code/${discCodeId}  expected_status=any
    RETURN  ${resp}


Update Subdomain_Level sa
    [Arguments]   ${data}   ${acct_id}  ${subdomain} 
    ${params}=    Create Dictionary   account=${acct_id}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /sa/branch/provider/bProfile/${subdomain}   data=${data}   params=${params}  expected_status=any
    RETURN  ${resp}

# Create corporate JDN enbled
#     [Arguments]   ${corpId}   ${label}  ${displyNote}    ${discPercentage}  ${discMax}
#     ${auth}=    Create Dictionary  corpId=${corpId}  label=${label}  displyNote=${displyNote}   discPercentage=${discPercentage}  discMax=${discMax}
#     ${apple}=    json.dumps    ${auth}
#     Check And Create YNW SuperAdmin Session
#     ${resp}=  POST On Session   synw    /corporate/${corpId}/jdn/enable 
#     RETURN  ${resp}

# Create branch JDN enbled
#     [Arguments]   ${corpId}
#     ${auth}=    Create Dictionary  corpId=${corpId} 
#     Check And Create YNW SuperAdmin Session
#     ${resp}=  POST On Session   synw    /corporate/${corpId}/branch/jdn/enable
#     RETURN  ${resp}



# update discount of a corporate   
#     [Arguments]   ${corpId}   ${label}  ${displyNote}    ${discPercentage}  ${discMax}
#     ${auth}=    Create Dictionary  corpId=${corpId}  label=${label}  displyNote=${displyNote}   discPercentage=${discPercentage}  discMax=${discMax}
#     ${apple}=    json.dumps    ${auth}
#     Check And Create YNW SuperAdmin Session
#     ${resp}=  POST On Session   synw    /corporate/${corpId}/jdn
#     RETURN  ${resp}


Update license of branches
    [Arguments]   ${corpId}
    ${auth}=    Create Dictionary  corpId=${corpId} 
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw  /corporate/${corpId}/branch/license  expected_status=any
    RETURN  ${resp}

Get Addons of corporate 
    [Arguments]  ${ci_d}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw  /corporate/${ci_d}/addon  expected_status=any
    RETURN  ${resp}  

Change Subscription Bill cycle 
    [Arguments]  ${accId}   ${licBillCycle} 
    ${auth}=    Create Dictionary   accId=${accId}    licBillCycle=${licBillCycle} 
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session    synw  /account/${accId}/license/billing/${licBillCycle}  expected_status=any 
    RETURN  ${resp}  

Get Start date of next Bill Cycle
    [Arguments]  ${accId}
    ${auth}=    Create Dictionary   accId=${accId}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw  /account/${accId}/license/billing/nextBillCycle  expected_status=any
    RETURN  ${resp}  

Get license bill cycle Subscription type
    [Arguments]  ${accId}
    ${auth}=    Create Dictionary   accId=${accId}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw  /account/${accId}/license/billing  expected_status=any
    RETURN  ${resp}

Change Subscription type to Annual 
    [Arguments]  ${accId}
    ${auth}=    Create Dictionary   accId=${accId}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session    synw  /account/license/subscription/${accId}  expected_status=any
    RETURN  ${resp} 



Get jdn config of a corporate
    [Arguments]   ${corpId}
    ${auth}=    Create Dictionary  corpId=${corpId} 
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw  /corporate/${corpId}/jdn/config  expected_status=any
    RETURN  ${resp}

Disable jdn of a corporate  
    [Arguments]   ${corpId}
    ${auth}=    Create Dictionary  corpId=${corpId} 
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw  /corporate/${corpId}/jdn/disable  expected_status=any
    RETURN  ${resp}

Enable jdn if it is already disabled
    [Arguments]   ${corpId}
    ${auth}=    Create Dictionary  corpId=${corpId} 
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw  /corporate/${corpId}/jdn/enable  expected_status=any
    RETURN  ${resp}

Create JDN 
    [Arguments]   ${corpId}  ${label}  ${displyNote}  ${discPercentage}   ${discMax}
    ${auth}=  Create Dictionary  corpId=${corpId}  label=${label}  displyNote=${displyNote}  discPercentage=${discPercentage}  discMax=${discMax}
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session   synw  /corporate/${corpId}/jdn/enable  data=${apple}   expected_status=any
    RETURN  ${resp}

Update JDN 
    [Arguments]    ${corpId}  ${label}  ${displyNote}  ${discPercentage}   ${discMax}
    ${auth}=  Create Dictionary  corpId=${corpId}  label=${label}  displyNote=${displyNote}  discPercentage=${discPercentage}  discMax=${discMax}
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw  /corporate/${corpId}/jdn  data=${apple}   expected_status=any
    RETURN  ${resp}


Enable JDN of Branches
    [Arguments]    ${corpId} 
    ${auth}=  Create Dictionary  corpId=${corpId} 
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session   synw  /corporate/${corpId}/branch/jdn/enable   data=${apple}   expected_status=any
    RETURN  ${resp}
    
Get discount details of a corporate  
    [Arguments]   ${corpId}
    ${auth}=    Create Dictionary  corpId=${corpId} 
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw   /corporate/${corpId}/jdn   expected_status=any
    RETURN  ${resp}


Get Account JDN 
    [Arguments]   ${accId}
    ${auth}=    Create Dictionary  accId=${accId} 
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw   /account/${accId}/jdn   expected_status=any
    RETURN  ${resp}

Create SA SalesChannel 
    [Arguments]   ${scId}  ${providerDiscFromJaldee}  ${providerDiscDuration}  ${scName}   ${contactFirstName}  ${contactLastName}  ${address}   ${city}  ${metro}   ${state}   ${latitude}   ${longitude}   ${radiusCoverage}   ${pincodesCoverage}   ${scType}   ${primaryPhoneNo}   ${altPhoneNo1}   ${altPhoneNo2}   ${commissionDuration}   ${commissionPct}   ${primaryEmail}   ${altEmail1}   ${altEmail2}   ${bonusPeriod}   ${id}  ${targetCount}   ${rate}  ${privateNote}

    ${bonusRates}=  Create Dictionary  id=${id}  targetCount=${targetCount}   rate=${rate} 
    ${bonusRates}=  Create List   ${bonusRates} 
    ${data}=  Create Dictionary  scId=${scId}  providerDiscFromJaldee=${providerDiscFromJaldee}  providerDiscDuration=${providerDiscDuration}  scName=${scName}   contactFirstName=${contactFirstName}  contactLastName=${contactLastName}  address=${address}   city=${city}  metro=${metro}   state=${state}   latitude=${latitude}   longitude=${longitude}   radiusCoverage=${radiusCoverage}   pincodesCoverage=${pincodesCoverage}   scType=${scType}   primaryPhoneNo=${primaryPhoneNo}   altPhoneNo1=${altPhoneNo1}   altPhoneNo2=${altPhoneNo2}   commissionDuration=${commissionDuration}   commissionPct=${commissionPct}   primaryEmail=${primaryEmail}   altEmail1=${altEmail1}   altEmail2=${altEmail2}   bonusPeriod=${bonusPeriod}   bonusRates=${bonusRates}     privateNote=${privateNote}
    ${log}=   json.dumps  ${data}
    Log  ${log}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session  synw  /sc   data=${log}  expected_status=any
    RETURN  ${resp}

Get SCAccount Configuration
     Check And Create YNW SuperAdmin Session
     ${resp}=  GET On Session   synw  /account/config  expected_status=any       
     RETURN  ${resp}

Get SalesChannel By Id 
    [Arguments]  ${ScId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw  /sc/${ScId}  expected_status=any
    RETURN  ${resp}

Get SC Configuration
     Check And Create YNW SuperAdmin Session
     ${resp}=  GET On Session   synw  /sc/config  expected_status=any     
     RETURN  ${resp}

Update SC By Id
    [Arguments]   ${scId}  ${providerDiscFromJaldee}  ${providerDiscDuration}  ${scName}   ${contactFirstName}  ${contactLastName}  ${address}   ${city}  ${metro}   ${state}   ${latitude}   ${longitude}   ${radiusCoverage}   ${pincodesCoverage}   ${scType}   ${primaryPhoneNo}   ${altPhoneNo1}   ${altPhoneNo2}   ${commissionDuration}   ${commissionPct}   ${primaryEmail}   ${altEmail1}   ${altEmail2}   ${bonusPeriod}   ${id}  ${targetCount}   ${rate}  ${privateNote}
    ${bonusRates}=  Create Dictionary  id=${id}  targetCount=${targetCount}   rate=${rate} 
    ${bonusRates}=  Create List   ${bonusRates} 
    ${data}=  Create Dictionary  scId=${scId}  providerDiscFromJaldee=${providerDiscFromJaldee}  providerDiscDuration=${providerDiscDuration}  scName=${scName}   contactFirstName=${contactFirstName}  contactLastName=${contactLastName}  address=${address}   city=${city}  metro=${metro}   state=${state}   latitude=${latitude}   longitude=${longitude}   radiusCoverage=${radiusCoverage}   pincodesCoverage=${pincodesCoverage}   scType=${scType}   primaryPhoneNo=${primaryPhoneNo}   altPhoneNo1=${altPhoneNo1}   altPhoneNo2=${altPhoneNo2}   commissionDuration=${commissionDuration}   commissionPct=${commissionPct}   primaryEmail=${primaryEmail}   altEmail1=${altEmail1}   altEmail2=${altEmail2}   bonusPeriod=${bonusPeriod}   bonusRates=${bonusRates}     privateNote=${privateNote}
    ${data}=  json.dumps  ${data}
    Log  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session  synw  /sc/${scId}  data=${data}  expected_status=any
    RETURN  ${resp}
    

Create Branch SP
    [Arguments]  ${firstname}  ${lastname}   ${primaryMobileNo}  ${email}  ${subSector}  ${commonPassword}  ${departmentCode}
    ${data}=   Branch User Creation  ${firstname}  ${lastname}  ${primaryMobileNo}  ${email}  ${subSector}  ${commonPassword}  ${departmentCode}
    ${data}=   json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /provider/branch/createSp    data=${data}  expected_status=any
    RETURN  ${resp}

Delete SC By Id

    [Arguments]  ${ScId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  DELETE On Session   synw  /sc/${ScId}  expected_status=any
    RETURN  ${resp}

Get SC By IdStatus

    [Arguments]  ${scId}  ${scStatus}
    Check And Create YNW SuperAdmin Session
    Log  ${scStatus}
    ${resp}=  PUT On Session   synw  /sc/${scId}/${scStatus}  expected_status=any
    RETURN  ${resp}

Create SP SalesRep 

    [Arguments]  ${scId}  ${firstName}  ${lastName}   ${phoneNo}   ${email}   ${kyc}   ${kycDoneBy}   ${areasResponsible}   ${repCode}
    ${scId}=  Create Dictionary  id=${scId}
    ${data}=  Create Dictionary  scId=${scId}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phoneNo}   email=${email}  kyc=${kyc}  kycDoneBy=${kycDoneBy}     privateNote=${privateNote}  areasResponsible=${areasResponsible}  repCode=${repCode}
    ${data}=  json.dumps  ${data}
    Log  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session  synw  /sc/rep  data=${data}  expected_status=any
    RETURN  ${resp} 

Get SC List
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /sc  params=${kwargs}  expected_status=any
    RETURN  ${resp} 

Delete SP By Id
    [Arguments]   ${SpId}
    Check And Create YNW SuperAdmin Session
    Log  ${SpId}
    ${resp}=  DELETE On Session   synw   /sc/rep/${SpId}  expected_status=any
    RETURN  ${resp}

Update SC By Id And Status
    [Arguments]   ${stat}  ${scId}  ${providerDiscFromJaldee}  ${providerDiscDuration}  ${scName}   ${contactFirstName}  ${contactLastName}  ${address}   ${city}  ${metro}   ${state}   ${latitude}   ${longitude}   ${radiusCoverage}   ${pincodesCoverage}   ${scType}   ${primaryPhoneNo}   ${altPhoneNo1}   ${altPhoneNo2}   ${commissionDuration}   ${commissionPct}   ${primaryEmail}   ${altEmail1}   ${altEmail2}   ${bonusPeriod}   ${id}  ${targetCount}   ${rate}  ${privateNote}
    ${bonusRates}=  Create Dictionary  id=${id}  targetCount=${targetCount}   rate=${rate} 
    ${bonusRates}=  Create List   ${bonusRates} 
    ${data}=  Create Dictionary  scId=${scId}  providerDiscFromJaldee=${providerDiscFromJaldee}  providerDiscDuration=${providerDiscDuration}  scName=${scName}   contactFirstName=${contactFirstName}  contactLastName=${contactLastName}  address=${address}   city=${city}  metro=${metro}   state=${state}   latitude=${latitude}   longitude=${longitude}   radiusCoverage=${radiusCoverage}   pincodesCoverage=${pincodesCoverage}   scType=${scType}   primaryPhoneNo=${primaryPhoneNo}   altPhoneNo1=${altPhoneNo1}   altPhoneNo2=${altPhoneNo2}   commissionDuration=${commissionDuration}   commissionPct=${commissionPct}   primaryEmail=${primaryEmail}   altEmail1=${altEmail1}   altEmail2=${altEmail2}   bonusPeriod=${bonusPeriod}   bonusRates=${bonusRates}     privateNote=${privateNote}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session  synw  /sc/${scId}/${stat}  data=${data}  expected_status=any
    RETURN  ${resp}

Create SalesRep 

    [Arguments]  ${scId}  ${firstName}  ${lastName}   ${phoneNo}   ${email}   ${kyc}   ${kycDoneBy}   ${areasResponsible}   ${repCode}
    ${scId}=  Create Dictionary  id=${scId}
    ${data}=  Create Dictionary  scId=${scId}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phoneNo}   email=${email}  kyc=${kyc}  kycDoneBy=${kycDoneBy}     privateNote=${privateNote}  areasResponsible=${areasResponsible}  repCode=${repCode}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session  synw  /sc/rep  data=${data}  expected_status=any
    RETURN  ${resp}


Create Sales Channel Rep 
 
    [Arguments]  ${scId}  ${firstName}  ${lastName}   ${phoneNo}   ${email}   ${kyc}   ${kycDoneBy}   ${areasResponsible}   ${repCode}
    ${scId}=  Create Dictionary  id=${scId}
    ${data}=  Create Dictionary  scId=${scId}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phoneNo}   email=${email}  kyc=${kyc}  kycDoneBy=${kycDoneBy}   areasResponsible=${areasResponsible}  repCode=${repCode}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session  synw  /sc/rep  data=${data}  expected_status=any
    RETURN  ${resp} 


Delete Rep By Id
    [Arguments]   ${SpId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  DELETE On Session   synw   /sc/rep/${SpId}  expected_status=any
    RETURN  ${resp}

Get Rep List
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /sc/rep   params=${kwargs}  expected_status=any
    RETURN  ${resp} 

Get Sales Rep By Id 
    [Arguments]  ${spId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw  /sc/rep/${spId}  expected_status=any
    RETURN  ${resp}

Update REP By Id
    [Arguments]  ${repId}  ${scId}  ${firstName}  ${lastName}   ${phoneNo}   ${email}   ${kyc}   ${kycDoneBy}   ${areasResponsible}   ${repCode}
    ${scId}=  Create Dictionary  id=${scId}
    ${data}=  Create Dictionary  scId=${scId}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phoneNo}   email=${email}  kyc=${kyc}  kycDoneBy=${kycDoneBy}     privateNote=${privateNote}  areasResponsible=${areasResponsible}  repCode=${repCode}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session  synw  /sc/rep/${repId}  data=${data}  expected_status=any
    RETURN  ${resp}

Update REP By Id And Status
    [Arguments]  ${repId}   ${status}  ${scId}  ${firstName}  ${lastName}   ${phoneNo}   ${email}   ${kyc}   ${kycDoneBy}   ${areasResponsible}   ${repCode}
    ${scId}=  Create Dictionary  id=${scId}
    ${data}=  Create Dictionary  scId=${scId}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phoneNo}   email=${email}  kyc=${kyc}  kycDoneBy=${kycDoneBy}     privateNote=${privateNote}  areasResponsible=${areasResponsible}  repCode=${repCode}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session  synw  /sc/rep/${repId}/${status}  data=${data}  expected_status=any
    RETURN  ${resp}  

Get reimburse

    Check And Create YNW SuperAdmin Session
    ${resp}=   GET On Session   synw  /jc/reports  expected_status=any
    RETURN   ${resp}

Recreate reimburse report
    [Arguments]   ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw    /jc/reimburse/report/reGenerate/${id}  expected_status=any
    RETURN   ${resp}

Remove reimburse report
    [Arguments]  ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=    DELETE On Session   synw   /jc/reimburse/report/cancel/${id}  expected_status=any
    RETURN   ${resp}


Remove Redis Cache 
    [Arguments]   ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=    DELETE On Session   synw  /account/${id}/license/cache  expected_status=any 
    RETURN  ${resp} 

Get Redis Cache
    [Arguments]   ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/${id}/license/cache  expected_status=any 
    RETURN  ${resp} 


Get Invoices Verify
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/license/invoice   params=${kwargs}  expected_status=any
    RETURN  ${resp}

Create Manual Statements
    [Arguments]   ${accId}   ${amount}  ${des}  ${fromdate}  ${todate}
    ${data}=  Create Dictionary  accId=${accId}    amount=${amount}   description=${des}    periodFrom=${fromdate}   periodTo=${todate}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session  synw  /account/license/invoice  data=${data}  expected_status=any
    RETURN  ${resp}

Get Manual Statements
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/license/invoice   params=${kwargs}  expected_status=any
    RETURN  ${resp}

Cancel Manual Statements 
    [Arguments]   ${uuid}   ${reason}
    ${data}=  Create Dictionary  uuid=${uuid}    cancelReason=${reason}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session  synw  /account/license/invoice  data=${data}  expected_status=any
    RETURN  ${resp}


Change Status of Questionnaire
    [Arguments]  ${accountid}  ${status}  ${questionnaireid}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw  url=/b2b/${accountid}/questionnaire/change/${status}/${questionnaireid}?account=${accountid}  expected_status=any
    RETURN  ${resp}
  

Get Questionnaire By Id
    [Arguments]   ${accountid}  ${qnid}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /b2b/${accountid}/questionnaire/${qnid}  expected_status=any 
    RETURN  ${resp}


Get Questionnaire List
    [Arguments]   ${accountid}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /b2b/${accountid}/questionnaire/  expected_status=any 
    RETURN  ${resp}


Provider Update SC  
    [Arguments]   ${accId}   ${salesChannelCode}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session  synw  /account/sc/${accId}/${salesChannelCode}  expected_status=any
    RETURN  ${resp}

Get Provider Under SC
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/sc   params=${kwargs}  expected_status=any
    RETURN  ${resp}
 
Put Downgrade Accounts Revert
    [Arguments]  ${accLicId}  ${accountId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw   /account/license/${accLicId}/downgrade/revert/${accountId}  expected_status=any
    RETURN  ${resp}

Get Active License Details
    [Arguments]  ${accountId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw   /account/license/${accountId}  expected_status=any
    RETURN  ${resp}

Put Downgrade Corporate 
    [Arguments]  ${corpId}  ${licPkgId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw   /corporate/${corpId}/license/${licPkgId}  expected_status=any
    RETURN  ${resp}

Get Active License Corporate Details
    [Arguments]  ${corpId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw   /corporate/${corpId}/license  expected_status=any
    RETURN  ${resp}

Put Downgrade Corporate Revert
    [Arguments]  ${corpLicId}   ${corpId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw   /corporate/license/${corpLicId}/downgrade/revert/${corpId}  expected_status=any
    RETURN  ${resp}

Get Addon Corporate
    [Arguments]   ${corpId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw  /corporate/${corpId}/addon  expected_status=any
    RETURN   ${resp}

Delete Addon Corporate
   [Arguments]   ${corpId}  ${addonId}
   Check And Create YNW SuperAdmin Session
   ${resp}=  DELETE On Session    synw   /corporate/${corpId}/addon/${addonId}  expected_status=any
   RETURN   ${resp}

Get Corporate Config
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw    /account/license/conf  expected_status=any
    RETURN   ${resp}

Subscription License
    [Arguments]  ${acid}  
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw   /account/license/subscription/${acid}  expected_status=any
    RETURN   ${resp}

SC_invoice_Id
    [Arguments]  ${invoiceId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw    /sc/invoice/${invoiceId}  expected_status=any
    RETURN   ${resp}

SC_invoice
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw    /sc/invoice   params=${kwargs}  expected_status=any
    RETURN   ${resp}

SC_invoice_Count
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw    /sc/invoice/count  expected_status=any
    RETURN   ${resp}

SC_Commission_Report
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session   synw   /sc/commission  expected_status=any
    RETURN   ${resp}

SC_Get_Report_id
    [Arguments]  ${reportId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw    sc/commission/${reportId}  expected_status=any
    RETURN   ${resp}

SC_Report_Filter
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw    sc/commission   params=${kwargs}  expected_status=any
    RETURN   ${resp}  

SC_Report_Count
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw    sc/commission/count   params=${kwargs}  expected_status=any
    RETURN   ${resp} 

SC_Update_Status
    [Arguments]   ${comReportId}  ${status}  ${privateNote}
    Check And Create YNW SuperAdmin Session
    ${data}=  Create Dictionary  privateNote=${privateNote}
    ${data}=  json.dumps  ${data}
    ${resp}=  PUT On Session   synw    sc/commission/${comReportId}/${status}   data=${data}  expected_status=any
    RETURN   ${resp} 

SC_Update_Id
    [Arguments]   ${comReportId}   ${reportStatus}  ${reviewedBy}  ${paidOn}  ${paidTotal}  ${paidBy}  ${disputeAmt}  ${paymentMode}  ${paymentNote}  ${paidConfirmationNo}  ${addressSent}  ${privateNote}  ${adjustments}
    Check And Create YNW SuperAdmin Session
    ${data}=  Create Dictionary  reportStatus=${reportStatus}   reviewedBy=${reviewedBy}  paidOn=${paidOn}  paidTotal=${paidTotal}  paidBy=${paidBy}  disputeAmt=${disputeAmt}  paymentMode=${paymentMode}  paymentNote=${paymentNote}  paidConfirmationNo=${paidConfirmationNo}  addressSent=${addressSent}  privateNote=${privateNote}  adjustments=${adjustments}
    ${data}=  json.dumps  ${data}
    ${resp}=  PUT On Session   synw    sc/commission/${comReportId}   data=${data}  expected_status=any
    RETURN   ${resp} 

Update_RazorPay
    [Arguments]  ${accountId}   ${merchantId}  ${merchantKey}  ${webHookId}
    Check And Create YNW SuperAdmin Session
    ${data}=  Create Dictionary   accountId=${accountId}   merchantId=${merchantId}   merchantKey=${merchantKey}   webHookId=${webHookId}
    ${data}=  json.dumps  ${data}
    ${resp}=  PUT On Session   synw    /payment/razorPay   data=${data}  expected_status=any
    RETURN   ${resp} 

Get_PaymentSettings
    [Arguments]  ${accountId}  
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw    account/payment/settings/${accountId}  expected_status=any
    RETURN   ${resp} 



Updat_Virtual_Calling_Mode
    [Arguments]  ${accountId}  ${callingMode1}  ${ModeId1}   ${ModeStatus1}   ${instructions1}   ${callingMode2}  ${ModeId2}   ${ModeStatus2}   ${instructions2}
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${instructions1}
    ${VirtualcallingMode2}=  Create Dictionary   callingMode=${callingMode2}   value=${ModeId2}   status=${ModeStatus2}    instructions=${instructions2}
    ${vcm}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}
    ${data}=  Create Dictionary   virtualCallingModes=${vcm}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session  synw  /account/settings/${accountId}/virtualCallingModes   data=${data}  expected_status=any
    RETURN  ${resp}

Get_Virtual Settings
    [Arguments]  ${accountId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw   /account/settings/${accountId}/virtualCallingModes  expected_status=any
    RETURN  ${resp}

# Create Sales Channel Rep 
 
#     [Arguments]  ${scId}  ${firstName}  ${lastName}   ${phoneNo}   ${email}   ${kyc}   ${kycDoneBy}   ${areasResponsible}   ${repCode}
#     ${scId}=  Create Dictionary  id=${scId}
#     ${data}=  Create Dictionary  scId=${scId}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phoneNo}   email=${email}  kyc=${kyc}  kycDoneBy=${kycDoneBy}   areasResponsible=${areasResponsible}  repCode=${repCode}
#     ${data}=  json.dumps  ${data}
#     Check And Create YNW SuperAdmin Session
#     ${resp}=  POST On Session  synw  /sc/rep  data=${data}  expected_status=any
#     RETURN  ${resp} 


Support_Market Login
    [Arguments]    ${ustype}   ${loginId}  ${passwrd}   
    ${pass2}=  support_secondpassword
    ${data}=    Create Dictionary    loginId=${loginId}  password=${passwrd}  secondPassword=${pass2}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Rest Session
    ${resp}=    POST On Session     syn    /${ustype}/login    data=${data}  expected_status=any
    RETURN  ${resp}

Create Users
    [Arguments]  ${firstName}  ${lastName}   ${email}   ${password}   ${mobileNo}  ${userStatus}  ${userType}
    ${data}=  Create Dictionary   firstName=${firstName}   lastName=${lastName}   email=${email}   password=${password}   mobileNo=${mobileNo}   userStatus=${userStatus}   userType=${userType}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session  synw  /user   data=${data}  expected_status=any
    RETURN  ${resp} 

Create Users_Support
    [Arguments]  ${firstName}  ${lastName}   ${email}   ${password}   ${mobileNo}  ${userStatus}  ${userType}
    ${data}=  Create Dictionary   firstName=${firstName}   lastName=${lastName}   email=${email}   password=${password}   mobileNo=${mobileNo}   userStatus=${userStatus}   userType=${userType}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Rest Session
    ${resp}=  POST On Session  syn  /mgmt/user   data=${data}  expected_status=any
    RETURN  ${resp}

Update User Id
    [Arguments]  ${userId}  ${firstName}  ${lastName}   ${email}   ${password}   ${mobileNo}  ${userStatus}  ${userType}
    ${data}=  Create Dictionary   firstName=${firstName}   lastName=${lastName}   email=${email}   password=${password}   mobileNo=${mobileNo}   userStatus=${userStatus}   userType=${userType}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session  synw  /user/${userId}   data=${data}  expected_status=any
    RETURN  ${resp}

Update User Id_Support
    [Arguments]  ${userId}  ${firstName}  ${lastName}   ${email}   ${password}   ${mobileNo}  ${userStatus}  ${userType}
    ${data}=  Create Dictionary   firstName=${firstName}   lastName=${lastName}   email=${email}   password=${password}   mobileNo=${mobileNo}   userStatus=${userStatus}   userType=${userType}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Rest Session
    ${resp}=  PUT On Session  syn  /mgmt/user/${userId}   data=${data}  expected_status=any
    RETURN  ${resp}

Update SAUser Status
    [Arguments]  ${userId}  ${status}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session  synw  /user/${status}/${userId}  expected_status=any
    RETURN  ${resp}

Get SAUser ById
    [Arguments]  ${userId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session  synw  /user/${userId}  expected_status=any
    RETURN  ${resp}

Get User Types
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session  synw  /user/saUserType  expected_status=any
    RETURN  ${resp}

Get User Types_Support
     Check And Create YNW Rest Session
    ${resp}=  GET On Session  syn  /mgmt/user/saUserType  expected_status=any
    RETURN  ${resp}

Get Transactions
	Check And Create YNW SuperAdmin Session
	${resp}=    GET On Session   synw    /analytics/transactions/count  expected_status=any
 	RETURN  ${resp}
	
Get Account Configuration
    Check And Create YNW Rest Session
    #Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   syn  /mgmt/account/config  expected_status=any
    RETURN  ${resp}   

Get Account Verify
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /unverify/account   params=${kwargs}  expected_status=any
    RETURN  ${resp}


Create Jaldee Cash Offer
    [Arguments]   ${jcash_name}  ${faceValueType}  ${amt}   ${effectiveFrom}  ${effectiveTo}  ${when}  ${scope}  ${forDomains}  ${forSubDomains}  ${forSpLabels}  ${spList}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit} 
    ${whenRules}=    Create Dictionary    scope=${scope}  forDomains=${forDomains}  forSubDomains=${forSubDomains}  forSpLabels=${forSpLabels}  spList=${spList}  minOnlinePaymentAmt=${minOnlinePaymentAmt}  
    ${eligibleWhen}=    Create Dictionary    when=${when}  whenRules=${whenRules} 
    ${eligibilityRules}=    Create Dictionary    effectiveFrom=${effectiveFrom}  effectiveTo=${effectiveTo}  eligibleWhen=${eligibleWhen} 
    ${offerRedeemRules}=    Create Dictionary    maxValidUntil=${maxValidUntil}  validForDays=${validForDays}  maxAmtSpendLimit=${maxSpendLimit} 
    ${offerIssueRules}=    Create Dictionary    issueLimit=${issueLimit} 
    ${JCash_Offer}=    Create Dictionary    name=${jcash_name}  faceValueType=${faceValueType}  amt=${amt}   eligibilityRules=${eligibilityRules}  offerRedeemRules=${offerRedeemRules}  offerIssueRules=${offerIssueRules} 
    ${data}=    json.dumps    ${JCash_Offer}
    Log  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=    POST On Session   synw   /jcash/offer    data=${data}  expected_status=any
    RETURN  ${resp}


Update Jaldee Cash Offer
    [Arguments]  ${offerId}  ${jcash_name}  ${faceValueType}  ${amt}  ${effectiveFrom}  ${effectiveTo}  ${when}  ${scope}  ${forDomains}  ${forSubDomains}  ${forSpLabels}  ${spList}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    ${whenRules}=    Create Dictionary    scope=${scope}  forDomains=${forDomains}  forSubDomains=${forSubDomains}  forSpLabels=${forSpLabels}  spList=${spList}  minOnlinePaymentAmt=${minOnlinePaymentAmt}  
    ${eligibleWhen}=    Create Dictionary    when=${when}  whenRules=${whenRules} 
    ${eligibilityRules}=    Create Dictionary    effectiveFrom=${effectiveFrom}  effectiveTo=${effectiveTo}  eligibleWhen=${eligibleWhen} 
    ${offerRedeemRules}=    Create Dictionary    maxValidUntil=${maxValidUntil}  validForDays=${validForDays}  maxAmtSpendLimit=${maxSpendLimit} 
    ${offerIssueRules}=    Create Dictionary    issueLimit=${issueLimit} 
    ${JCash_Offer}=    Create Dictionary    name=${jcash_name}  faceValueType=${faceValueType}  amt=${amt}  eligibilityRules=${eligibilityRules}   offerRedeemRules=${offerRedeemRules}  offerIssueRules=${offerIssueRules} 
    ${data}=    json.dumps    ${JCash_Offer}
    Log  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session   synw   /jcash/offer/${offerId}    data=${data}  expected_status=any
    RETURN  ${resp}


# Update Jaldee Cash Offer
#     [Arguments]  ${offerId}  ${faceValueType}  ${amt}  ${status}  ${effectiveFrom}  ${effectiveTo}  ${when}  ${scope}  ${forDomains}  ${forSubDomains}  ${forSpLabels}  ${allSps}  ${spList}  ${minOnlinePaymentAmt}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}
#     ${whenRules}=    Create Dictionary    scope=${scope}  forDomains=${forDomains}  forSubDomains=${forSubDomains}  forSpLabels=${forSpLabels}  allSps=${allSps}  spList=${spList}  minOnlinePaymentAmt=${minOnlinePaymentAmt}  
#     ${eligibleWhen}=    Create Dictionary    when=${when}  whenRules=${whenRules} 
#     ${eligibilityRules}=    Create Dictionary    effectiveFrom=${effectiveFrom}  effectiveTo=${effectiveTo}  eligibleWhen=${eligibleWhen} 
#     ${offerRedeemRules}=    Create Dictionary    maxValidUntil=${maxValidUntil}  validForDays=${validForDays}  maxAmtSpendLimit=${maxSpendLimit} 
#     ${JCash_Offer}=    Create Dictionary    faceValueType=${faceValueType}  amt=${amt}  status=${status}  eligibilityRules=${eligibilityRules}  offerRedeemRules=${offerRedeemRules}
#     ${data}=    json.dumps    ${JCash_Offer}
#     Log  ${data}
#     Check And Create YNW SuperAdmin Session
#     ${resp}=    PUT On Session   synw   /jcash/offer/${offerId}    data=${data}  expected_status=any
#     RETURN  ${resp}



Enable Jaldee Cash Offer
    [Arguments]  ${offerId}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session     synw   /jcash/offer/${offerId}/ENABLED  expected_status=any
    RETURN  ${resp}


Disable Jaldee Cash Offer
    [Arguments]  ${offerId}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session     synw   /jcash/offer/${offerId}/DISABLED  expected_status=any
    RETURN  ${resp}


Get Jaldee Cash Offer By Id
    [Arguments]  ${offerId}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session     synw   /jcash/offer/${offerId}  expected_status=any
    RETURN  ${resp}


Get Jaldee Cash Offers By Criteria
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session     synw   /jcash/offer  params=${kwargs}  expected_status=any
    RETURN  ${resp}


Delete Jaldee Cash Offer 
   [Arguments]   ${offerId}  
   Check And Create YNW SuperAdmin Session
   ${resp}=  DELETE On Session    synw   /jcash/offer/${offerId}  expected_status=any
   RETURN   ${resp}


Get Jaldee Cash Offer Count
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session     synw   /jcash/offer/count  params=${kwargs}  expected_status=any
    RETURN  ${resp}


Get Jaldee Cash Global Max Spendlimit
    Check And Create YNW Session
    ${resp}=    GET On Session    synw  /jcash/offer/config/spendLimit     expected_status=any
    RETURN  ${resp}


Get Jaldee Cash Offer Stat Count for Today
    Check And Create YNW Session
    ${resp}=    GET On Session    synw  /jcash/offer/stat/date/TODAY        expected_status=any
    RETURN  ${resp}


Get Jaldee Cash Offer Stat Count for Lastweek
    Check And Create YNW Session
    ${resp}=    GET On Session    synw  /jcash/offer/stat/date/LAST_WEEK        expected_status=any
    RETURN  ${resp}


Get Total Jaldee Cash Offer Stat Count 
    Check And Create YNW Session
    ${resp}=    GET On Session    synw  /jcash/offer/stat/date/TOTAL        expected_status=any
    RETURN  ${resp}


Get Consumer Jaldee Cash Offer Stat Count 
    [Arguments]   ${statType}   ${dateCategory}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw  /jcash/offer/stat/consumer/statType/${statType}/category/${dateCategory}    expected_status=any
    RETURN  ${resp}


Get SP Jaldee Cash Offer Stat Count 
    [Arguments]   ${statType}   ${dateCategory}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw  /jcash/offer/stat/sp/statType/${statType}/category/${dateCategory}    expected_status=any
    RETURN  ${resp}


Get Jaldee Cash Offer Stat Count 
    [Arguments]   ${statType}   ${dateCategory}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw  /jcash/offer/stat/offer/statType/${statType}/category/${dateCategory}    expected_status=any
    RETURN  ${resp}



Issue Jaldee Cash 
    [Arguments]   ${jcash_name}  ${amt}  ${maxSpendLimit}  ${expiryDate}   @{vargs}
    ${consids}=   Create List  @{vargs}
    ${JCash_Offer}=    Create Dictionary    name=${jcash_name}  amt=${amt}   spendLimit=${maxSpendLimit}  expiryDate=${expiryDate}  consumerIds=${consids} 
    ${data}=    json.dumps    ${JCash_Offer}
    Log  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=    POST On Session   synw   /jcash    data=${data}  expected_status=any
    RETURN  ${resp}

Get Domain Level Analytics
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /analytics/domain  params=${kwargs}  expected_status=any
    RETURN  ${resp}

# Android App Get Domain Level Analytics
#     [Arguments]   &{kwargs}
#     Check And Create YNW SuperAdmin Session
#     ${resp}=    GET On Session    synw   /analytics/domain  params=${kwargs}  expected_status=any  headers=${app_headers}
#     RETURN  ${resp}

Get Subdomain Level Analytics
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /analytics/subdomain  params=${kwargs}  expected_status=any
    RETURN  ${resp}

Account Level Analytics
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /analytics/account  params=${kwargs}  expected_status=any
    RETURN  ${resp}

Get User Level Analytics
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /analytics/user  params=${kwargs}  expected_status=any
    RETURN  ${resp}

Get Department Level Analytics
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /analytics/dept  params=${kwargs}  expected_status=any
    RETURN  ${resp}

Get Team Level Analytics
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /analytics/team  params=${kwargs}  expected_status=any
    RETURN  ${resp}

Superadmin Change Questionnaire Status    
    [Arguments]  ${qnrid}   ${status}   ${account_id}
    Check And Create YNW Session
    ${resp}=    PUT On Session  SYNW  /b2b/${account_id}/questionnaire/change/${Status}/${qnrid}  expected_status=any
    RETURN    ${resp}


#......MULTIPLE PAYMENT PROFILES......#


Payment Profile For Prepayment
    [Arguments]   ${acc_id}  ${advPayBankType}  &{kwargs}
    ${items}=  Get Dictionary items  ${kwargs}
    ${data}=   Create Dictionary    advPayBankType=${advPayBankType}  
    FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    Check And Create YNW SuperAdmin Session
    ${resp}=   PUT On Session  synw  url=/payment/advancePayBank?accountId=${acc_id}    expected_status=any
    RETURN  ${resp}


# Create Bank Info
#     [Arguments]   ${acc_id}   ${onlinePayment}   ${payTm}   ${dcOrCcOrNb}   ${payTmLinkedPhoneNumber}  ${panCardNumber}   ${bankAccountNumber}  
#     ...   ${bankName}   ${ifscCode}   ${nameOnPanCard}   ${accountHolderName}  ${branchCity}   ${businessFilingStatus}   ${accountType}
#     ${data}=   Create Dictionary       onlinePayment=${onlinePayment}   payTm=${payTm}   dcOrCcOrNb=${dcOrCcOrNb}   
#     ...   payTmLinkedPhoneNumber=${payTmLinkedPhoneNumber}  panCardNumber=${panCardNumber}   bankAccountNumber=${bankAccountNumber}   
#     ...   bankName=${bankName}   ifscCode=${ifscCode}   nameOnPanCard=${nameOnPanCard}   accountHolderName=${accountHolderName}  
#     ...   branchCity=${branchCity}   businessFilingStatus=${businessFilingStatus}   accountType=${accountType}
#     ${data}=   json.dumps   ${data}
#     Check And Create YNW SuperAdmin Session
#     ${resp}=   POST On Session  synw  /payment/settings/bankInfo/${acc_id}     data=${data}  expected_status=any
#     RETURN  ${resp}



Create Bank Info
    [Arguments]   ${acc_id}   ${bankName}   ${bankAccountNumber}   ${ifscCode}   ${nameOnPanCard}   ${accountHolderName}  ${branchCity}
    ...   ${businessFilingStatus}   ${accountType}    ${panCardNumber}   ${payTmLinkedPhoneNumber}
    ${data}=   Create Dictionary    bankName=${bankName}  bankAccountNumber=${bankAccountNumber}  ifscCode=${ifscCode}  
    ...   nameOnPanCard=${nameOnPanCard}  accountHolderName=${accountHolderName}  branchCity=${branchCity}   businessFilingStatus=${businessFilingStatus}   
    ...   accountType=${accountType}  panCardNumber=${panCardNumber}  payTmLinkedPhoneNumber=${payTmLinkedPhoneNumber}    
    ${data}=   json.dumps   ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=   POST On Session  synw  /payment/settings/bankInfo/${acc_id}     data=${data}  expected_status=any
    RETURN  ${resp}


Get Bank Info By Id
    [Arguments]   ${bankid}  ${acc_id}
    Check And Create YNW SuperAdmin Session
    ${resp}=   GET On Session  synw  /payment/settings/bankInfo/${bankid}/${acc_id}    expected_status=any
    RETURN  ${resp}


Get All Bank Info
    [Arguments]     ${acc_id}
    Check And Create YNW SuperAdmin Session
    ${resp}=   GET On Session  synw  /payment/settings/bankInfo/${acc_id}   expected_status=any
    RETURN  ${resp}


# Update Bank Info
#     [Arguments]   ${bankid}  ${acc_id}   ${onlinePayment}   ${payTm}   ${dcOrCcOrNb}   ${payTmLinkedPhoneNumber}  ${panCardNumber}   ${bankAccountNumber}  
#     ...   ${bankName}   ${ifscCode}   ${nameOnPanCard}   ${accountHolderName}  ${branchCity}   ${businessFilingStatus}   ${accountType}
#     ${data}=   Create Dictionary       onlinePayment=${onlinePayment}   payTm=${payTm}   dcOrCcOrNb=${dcOrCcOrNb}   
#     ...   payTmLinkedPhoneNumber=${payTmLinkedPhoneNumber}  panCardNumber=${panCardNumber}   bankAccountNumber=${bankAccountNumber}   
#     ...   bankName=${bankName}   ifscCode=${ifscCode}   nameOnPanCard=${nameOnPanCard}   accountHolderName=${accountHolderName}  
#     ...   branchCity=${branchCity}   businessFilingStatus=${businessFilingStatus}   accountType=${accountType}
#     ${data}=   json.dumps   ${data}
#     Check And Create YNW SuperAdmin Session
#     ${resp}=   PUT On Session  synw  /payment/settings/bankInfo/${bankid}/${acc_id}     data=${data}  expected_status=any
#     RETURN  ${resp}


Update Bank Info
    [Arguments]   ${bankid}  ${acc_id}   ${bankName}   ${bankAccountNumber}   ${ifscCode}   ${nameOnPanCard}   ${accountHolderName}  ${branchCity} 
    ...   ${businessFilingStatus}   ${accountType}    ${panCardNumber}   ${payTmLinkedPhoneNumber}   &{kwargs}
    ${items}=  Get Dictionary items  ${kwargs}
    ${data}=   Create Dictionary    bankName=${bankName}  bankAccountNumber=${bankAccountNumber}  ifscCode=${ifscCode}  
    ...   nameOnPanCard=${nameOnPanCard}  accountHolderName=${accountHolderName}  branchCity=${branchCity}   businessFilingStatus=${businessFilingStatus}   
    ...   accountType=${accountType}  panCardNumber=${panCardNumber}  payTmLinkedPhoneNumber=${payTmLinkedPhoneNumber}    
    FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    Log  ${data}
    ${data}=   json.dumps   ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=   PUT On Session  synw  /payment/settings/bankInfo/${bankid}/${acc_id}     data=${data}  expected_status=any
    RETURN  ${resp}



# ${items}=  Get Dictionary items  ${kwargs}
#     ${data}=  Create Dictionary   catalogName=${catalogName}   catalogDesc=${catalogDesc}  catalogSchedule=${catalogSchedule}   orderType=${orderType}   paymentType=${paymentType}   orderStatuses=${orderStatuses}   catalogItem=${catalogItem}  minNumberItem=${min}   maxNumberItem=${max}    cancellationPolicy=${cancellationPolicy}
#     FOR  ${key}  ${value}  IN  @{items}
#         Set To Dictionary  ${data}   ${key}=${value}
#     END
#     Log  ${data}
#     ${data}=    json.dumps    ${data}

Get Payment Bank Details
    [Arguments]    ${acc_id} 
    Check And Create YNW SuperAdmin Session
    ${resp}=   GET On Session  synw   url=/account/payment/payBankDetails?accountId=${acc_id}   expected_status=any
    RETURN  ${resp}


Create Lucene Search
    [Arguments]       ${account}
    # Check And Create YNW Session
    Check And Create YNW SuperAdmin Session
    ${resp}=    POST On Session    synw    /searchdetails/${account}/providerconsumer/create	    expected_status=any
    RETURN  ${resp}

Get Lucene Search
    [Arguments]   ${account}   &{param}
    # Check And Create YNW Session
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw    /searchdetails/${account}/providerconsumer/search    params=${param}     expected_status=any
    RETURN  ${resp}

Delete Lucene Search  
    [Arguments]   ${account}   &{param}  
    # Check And Create YNW Session
    Check And Create YNW SuperAdmin Session
    ${resp}=    DELETE On Session    synw    /searchdetails/${account}/providerconsumer/delete	   params=${param}      expected_status=any
    RETURN  ${resp}


Enable Disable Invoice Generartion

    [Arguments]       ${acc_id}   ${bySystem}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session    synw    account/license/createBySystem/${acc_id}/${bySystem}	    expected_status=any
    RETURN  ${resp}


Revert Invoice

    [Arguments]       ${acc_id}   ${invoice_id}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session    synw    account/license/invoice/revert/${invoice_id}/${acc_id}	    expected_status=any
    RETURN  ${resp}


Update Notes and Collected Details

    [Arguments]       ${lic_id}   ${payment_id}  ${note}
    ${data}=   Create Dictionary    uuid=${lic_id}  paymentId=${payment_id}  Note=${note}  
    ${data}=   json.dumps   ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session    synw    payment	 data=${data}   expected_status=any
    RETURN  ${resp}


# .....Jaldee Homeo....



Enable Disable Channel 

    [Arguments]       ${acc_id}   ${actiontype}   ${channel_ids}
    ${data}=   Create Dictionary    channelIds=${channel_ids} 
    ${data}=   json.dumps   ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session    synw    account/${acc_id}/${actiontype} 	 data=${data}   expected_status=any
    RETURN  ${resp}


Get Service Label Config

    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw    account/serviceConfig    expected_status=any
    RETURN  ${resp}


# ......reimburse......

Update Reimbursement By InvoiceId
    [Arguments]  ${invoice_id}   ${note}
    ${data}=   Create Dictionary    notes=${note} 
    ${data}=   json.dumps   ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session   synw    /jc/reimburse/${invoice_id}    data=${data}    expected_status=any
    RETURN  ${resp}

    
Get Reminder Notification

    Check And Create YNW SuperAdmin Session
    ${resp}=    POST On Session    synw    /userAgent/reminderNotificationTask    expected_status=any  
    RETURN  ${resp} 

    
Get Appointment Reminder

    Check And Create YNW SuperAdmin Session
    ${resp}=    POST On Session    synw    /userAgent/apptNotificationTask    expected_status=any  
    RETURN  ${resp}

Delete Not Used AddOn 
    [Arguments]   ${account}    ${accLicAddonId}   &{param}  
    # Check And Create YNW Session
    Check And Create YNW SuperAdmin Session
    ${resp}=    DELETE On Session    synw    account/license/${account}/licAddonId/${accLicAddonId}	   params=${param}      expected_status=any
    RETURN  ${resp}

Month Matrix Cache Task

    Check And Create YNW SuperAdmin Session
    ${resp}=   POST On Session  synw   userAgent/monthMatrixCacheTask   expected_status=any
    RETURN  ${resp}


# .............. Consent Form ..................

Enable Disable Consent Form 

    [Arguments]       ${accountId}   ${status}

    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session    synw    account/settings/${accountId}/consentform/${status}   expected_status=any
    RETURN  ${resp}

Create Consent Form Settings

    [Arguments]       ${accountId}   ${name}    ${description}    ${qnrid}

    ${data}=   Create Dictionary    name=${name}  description=${description}  qnrIds=${qnrid}
    ${data}=   json.dumps   ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=    POST On Session    synw    consentform/${accountId}/settings  data=${data}   expected_status=any
    RETURN  ${resp}

Update Consent Form Settings

    [Arguments]       ${accountId}  ${cfid}   ${name}    ${description}    ${qnrid}

    ${data}=   Create Dictionary    id=${cfid}  name=${name}  description=${description}  qnrIds=${qnrid}
    ${data}=   json.dumps   ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PATCH On Session    synw    consentform/${accountId}/settings  data=${data}   expected_status=any
    RETURN  ${resp}

Get Consent Form Settings

    [Arguments]       ${accountId}

    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw    consentform/${accountId}   expected_status=any
    RETURN  ${resp}

Get Consent Form Settings By Id

    [Arguments]       ${accountId}  ${settingId}

    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw    consentform/${accountId}/settings/${settingId}   expected_status=any
    RETURN  ${resp}

Update Consent Form Settings Status

    [Arguments]       ${accountId}  ${settingId}  ${status}

    Check And Create YNW SuperAdmin Session
    ${resp}=    PATCH On Session    synw    consentform/${accountId}/settings/${settingId}/status/${status}  expected_status=any
    RETURN  ${resp}


#------------------Data Migration-----------------

Get List
    [Arguments]     ${account}  
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session  synw  /spdataimport/account/${account}/list   expected_status=any
    RETURN  ${resp}


Get Data By Uid
    [Arguments]     ${account}  ${uid}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session  synw  /spdataimport/account/${account}/${uid}   expected_status=any
    RETURN  ${resp}

Generate OTP for patient migration
   [Arguments]    ${account}  ${customerseries}  ${uid}
   Check And Create YNW SuperAdmin Session
   ${resp}=  POST On Session   synw   /spdataimport/account/${account}/${customerseries}/Patients/migrate/${uid}/generateotp    expected_status=any
   RETURN  ${resp}

Verify OTP For Patients Migration
   [Arguments]     ${propertyphone_no}  ${purpose}     ${account}  ${customerIdFormat}  ${uid}  

   Check And Create YNW SuperAdmin Session
   ${otp}=   verify accnt  ${propertyphone_no}  ${purpose}
   ${resp}=  POST On Session   synw   /spdataimport/account/${account}/${customerIdFormat}/Patients/migrate/${uid}/verifyotp/${otp}    expected_status=any
   RETURN  ${resp}

Generate OTP For Appointment Migration
   [Arguments]    ${account}    ${uid}   ${tz}
   Check And Create YNW SuperAdmin Session
   ${resp}=  POST On Session   synw    /spdataimport/account/${account}/Appointments/migrate/${uid}/generateotp    expected_status=any    data="${tz}"
   RETURN  ${resp}


Verify OTP For Appointment Migration
   [Arguments]     ${propertyphone_no}  ${purpose}     ${account}   ${uid}  ${tz}

   Check And Create YNW SuperAdmin Session
   ${otp}=   verify accnt  ${propertyphone_no}  ${purpose}
   ${resp}=  POST On Session   synw   /spdataimport/account/${account}/Appointments/migrate/${uid}/verifyotp/${otp}    expected_status=any   data="${tz}"
   RETURN  ${resp}

Generate OTP For Notes Migration
   [Arguments]    ${account}    ${uid}
   Check And Create YNW SuperAdmin Session
   ${resp}=  POST On Session   synw   /spdataimport/account/${account}/Notes/migrate/${uid}/generateotp    expected_status=any
   RETURN  ${resp}

Verify OTP For Notes Migration
   [Arguments]     ${propertyphone_no}  ${purpose}     ${account}    ${uid}  

   Check And Create YNW SuperAdmin Session
   ${otp}=   verify accnt  ${propertyphone_no}  ${purpose}
   ${resp}=  POST On Session   synw   /spdataimport/account/${account}/Notes/migrate/${uid}/verifyotp/${otp}    expected_status=any
   RETURN  ${resp}

Generate OTP For Revert
   [Arguments]    ${account}   ${uid}
   Check And Create YNW SuperAdmin Session
   ${resp}=  DELETE On Session   synw   /spdataimport/account/${account}/revert/${uid}/generateotp    expected_status=any
   RETURN  ${resp}

Verify OTP For Revert Migration
   [Arguments]     ${propertyphone_no}  ${purpose}  ${account}   ${uid}  

   Check And Create YNW SuperAdmin Session
   ${otp}=   verify accnt  ${propertyphone_no}  ${purpose}
   ${resp}=  DELETE On Session   synw   /spdataimport/account/${account}/revert/${uid}/verifyotp/${otp}    expected_status=any
   RETURN  ${resp}


# Inventory
Create Store Type

    [Arguments]      ${name}    ${storeNature}    

    ${data}=   Create Dictionary    name=${name}  storeNature=${storeNature}  
    ${data}=   json.dumps   ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=    POST On Session    synw    /account/store/type   data=${data}   expected_status=any
    RETURN  ${resp}


Get Store Type By EncId
    [Arguments]  ${storeTypeEncId}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw   /account/store/type/id/${storeTypeEncId}  expected_status=any
    RETURN  ${resp}

Update Store Type

    [Arguments]     ${uid}   ${name}   ${storeNature}
    ${data}=  Create Dictionary  name=${name}   storeNature=${storeNature}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  synw  /account/store/type/${uid}  data=${data}  expected_status=any
    RETURN  ${resp}  

Get Store Type Filter
    [Arguments]   &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw   /account/store/type   params=${param}   expected_status=any
    RETURN  ${resp}

Get Store Type Filter Count

    [Arguments]   &{param}

    Check And Create YNW Session
    ${resp}=  GET On Session  synw  /account/store/type/count   params=${param}   expected_status=any
    RETURN  ${resp}  

#........ ITEM CATEGORY .................

Create Item Category SA

    [Arguments]  ${account}  ${categoryName}  
    ${data}=  Create Dictionary  categoryName=${categoryName}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  synw  /item/${account}/category  data=${data}  expected_status=any
    RETURN  ${resp}  

Get Item Category SA

    [Arguments]  ${account}  ${id}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw   /item/${account}/category/${id}  expected_status=any
    RETURN  ${resp}

Update Item Category SA

    [Arguments]   ${account}  ${categoryName}   ${categoryCode}
    ${data}=  Create Dictionary  categoryName=${categoryName}   categoryCode=${categoryCode}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  synw  /item/${account}/category  data=${data}  expected_status=any
    RETURN  ${resp}  

Get Item Category By Filter SA  

    [Arguments]   ${account}  &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw   /item/${account}/category   params=${param}   expected_status=any
    RETURN  ${resp}

Update Item Category Status SA

    [Arguments]   ${account}  ${categoryCode}   ${status}
    
    Check And Create YNW Session
    ${resp}=  PATCH On Session  synw  /item/${account}/category/${categoryCode}/status/${status}   expected_status=any
    RETURN  ${resp}  

Get Item Category Count By Filter SA

    [Arguments]   ${account}  &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw   /item/${account}/category/count   params=${param}   expected_status=any
    RETURN  ${resp}

# ......... ITEM TYPE .............

Create Item Type SA

    [Arguments]  ${account}  ${typeName}  
    ${data}=  Create Dictionary  typeName=${typeName}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  synw  /item/${account}/type  data=${data}  expected_status=any
    RETURN  ${resp}  

Get Item Type SA

    [Arguments]  ${account}  ${id}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw   /item/${account}/type/${id}  expected_status=any
    RETURN  ${resp}

Update Item Type SA

    [Arguments]   ${account}  ${typeName}   ${typeCode}
    ${data}=  Create Dictionary  typeName=${typeName}   typeCode=${typeCode}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  synw  /item/${account}/type  data=${data}  expected_status=any
    RETURN  ${resp}  

Get Item Type By Filter SA

    [Arguments]   ${account}  &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw   /item/${account}/type   params=${param}   expected_status=any
    RETURN  ${resp}

Update Item Type Status SA

    [Arguments]   ${account}  ${typeCode}   ${status}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  synw  /item/${account}/type/${typeCode}/status/${status}   expected_status=any
    RETURN  ${resp}  

Get Item Type Count By Filter SA

    [Arguments]   ${account}  &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw   /item/${account}/type/count   params=${param}   expected_status=any
    RETURN  ${resp}


# ......... ITEM MANUFACTURE .............

Create Item manufacturer SA

    [Arguments]  ${account}  ${manufactureName}  
    ${data}=  Create Dictionary  manufacturerName=${manufactureName}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  synw  /item/${account}/manufacturer  data=${data}  expected_status=any
    RETURN  ${resp}  

Get Item manufacturer SA

    [Arguments]  ${account}  ${id}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw   /item/${account}/manufacturer/${id}  expected_status=any
    RETURN  ${resp}

Update Item manufacturer SA

    [Arguments]   ${account}  ${manufacturerName}   ${manufacturerCode}
    ${data}=  Create Dictionary  manufacturerName=${manufacturerName}   manufacturerCode=${manufacturerCode}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  synw  /item/${account}/manufacturer  data=${data}  expected_status=any
    RETURN  ${resp}  

Get Item manufacturer By Filter SA

    [Arguments]   ${account}  &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw   /item/${account}/manufacturer   params=${param}   expected_status=any
    RETURN  ${resp}

Update Item manufacturer Status SA

    [Arguments]   ${account}  ${manufacturerCode}   ${status}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  synw  /item/${account}/manufacturer/${manufacturerCode}/status/${status}   expected_status=any
    RETURN  ${resp}  

Get Item manufacturer Count By Filter SA

    [Arguments]   ${account}  &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw   /item/${account}/manufacturer/count   params=${param}   expected_status=any
    RETURN  ${resp}


# ......... ITEM TAX .............

Create Item Tax SA

    [Arguments]  ${account}  ${taxName}  ${taxTypeEnum}  ${taxPercentage}   &{kwargs}
    ${data}=  Create Dictionary  taxName=${taxName}  taxTypeEnum=${taxTypeEnum}  taxPercentage=${taxPercentage}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  synw  /item/${account}/tax  data=${data}  expected_status=any
    RETURN  ${resp}  

Get Item Tax SA

    [Arguments]  ${account}  ${id}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw   /item/${account}/tax/${id}  expected_status=any
    RETURN  ${resp}

Update Item Tax SA

    [Arguments]   ${account}  ${taxName}  ${taxCode}  ${taxTypeEnum}  ${taxPercentage}   &{kwargs}
    ${data}=  Create Dictionary  taxName=${taxName}  taxCode=${taxCode}  taxTypeEnum=${taxTypeEnum}  taxPercentage=${taxPercentage}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  synw  /item/${account}/tax  data=${data}  expected_status=any
    RETURN  ${resp}  

Get Item Tax By Filter SA

    [Arguments]   ${account}  &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw   /item/${account}/tax   params=${param}   expected_status=any
    RETURN  ${resp}

Update Item Tax Status SA

    [Arguments]   ${account}  ${taxCode}   ${status}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  synw  /item/${account}/tax/${taxCode}/status/${status}   expected_status=any
    RETURN  ${resp}  

Get Item Tax Count By Filter SA

    [Arguments]   ${account}  &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw   /item/${account}/tax/count   params=${param}   expected_status=any
    RETURN  ${resp}


# ......... ITEM UNIT .............

Create Item Unit SA

    [Arguments]  ${account}  ${unitName}    ${convertionQty}  
    ${data}=  Create Dictionary  unitName=${unitName}   convertionQty=${convertionQty}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  synw  /item/${account}/unit  data=${data}  expected_status=any
    RETURN  ${resp}  

Get Item Unit SA

    [Arguments]  ${account}  ${id}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw   /item/${account}/unit/${id}  expected_status=any
    RETURN  ${resp}

Update Item Unit SA

    [Arguments]   ${account}  ${unitName}    ${convertionQty}  ${unitCode}
    ${data}=  Create Dictionary  unitName=${unitName}   convertionQty=${convertionQty}  unitCode=${unitCode}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  synw  /item/${account}/unit  data=${data}  expected_status=any
    RETURN  ${resp}  

Get Item Unit By Filter SA

    [Arguments]   ${account}  &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw   /item/${account}/unit   params=${param}   expected_status=any
    RETURN  ${resp}

Update Item Unit Status SA

    [Arguments]   ${account}  ${unitCode}   ${status}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  synw  /item/${account}/unit/${unitCode}/status/${status}   expected_status=any
    RETURN  ${resp}  

Get Item Unit Count By Filter SA

    [Arguments]   ${account}  &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw   /item/${account}/unit/count   params=${param}   expected_status=any
    RETURN  ${resp}


# ......... ITEM COMPOSITION .............

Create Item Composition SA

    [Arguments]  ${account}  ${compositionName} 
    ${data}=  Create Dictionary  compositionName=${compositionName} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  synw  /item/${account}/composition  data=${data}  expected_status=any
    RETURN  ${resp}  

Get Item Composition SA

    [Arguments]  ${account}  ${id}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw   /item/${account}/composition/${id}  expected_status=any
    RETURN  ${resp}

Update Item Composition SA

    [Arguments]   ${account}  ${compositionName}  ${compositionCode}
    ${data}=  Create Dictionary  compositionName=${compositionName}   compositionCode=${compositionCode}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  synw  /item/${account}/composition  data=${data}  expected_status=any
    RETURN  ${resp}  

Get Item Composition By Filter SA

    [Arguments]   ${account}  &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw   /item/${account}/composition   params=${param}   expected_status=any
    RETURN  ${resp}

Update Item Composition Status SA

    [Arguments]   ${account}  ${compositionCode}   ${status}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  synw  /item/${account}/composition/${compositionCode}/status/${status}   expected_status=any
    RETURN  ${resp}  

Get Item Composition Count By Filter SA

    [Arguments]   ${account}  &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw   /item/${account}/composition/count   params=${param}   expected_status=any
    RETURN  ${resp}

# ......... ITEM HSN .............

Create Item Hsn SA

    [Arguments]  ${account}  ${hsnCode} 
    ${data}=  Create Dictionary  hsnCode=${hsnCode} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  synw  /item/${account}/hsn  data=${data}  expected_status=any
    RETURN  ${resp}  

Get Item Hsn SA

    [Arguments]  ${account}  ${id}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw   /item/${account}/hsn/${id}  expected_status=any
    RETURN  ${resp}

Update Item Hsn SA

    [Arguments]   ${account}  ${id}  ${hsnCode}
    ${data}=  Create Dictionary  id=${id}   hsnCode=${hsnCode}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  synw  /item/${account}/hsn  data=${data}  expected_status=any
    RETURN  ${resp}  

Get Item Hsn By Filter SA

    [Arguments]   ${account}  &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw   /item/${account}/hsn   params=${param}   expected_status=any
    RETURN  ${resp}

Update Item Hsn Status SA

    [Arguments]   ${account}  ${id}   ${status}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  synw  /item/${account}/hsn/${id}/status/${status}   expected_status=any
    RETURN  ${resp}  

Get Item Hsn Count By Filter SA

    [Arguments]   ${account}  &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw   /item/${account}/hsn/count   params=${param}   expected_status=any
    RETURN  ${resp}