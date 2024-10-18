*** Settings ***
Library           Collections
Library           String
Library           OperatingSystem
Library           /ebs/TDD/CustomKeywords.py
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


###### All Current Keywords above this line #############################################

SuperAdmin Login
    [Arguments]    ${usname}  ${passwrd}  &{kwargs}
    ${pass2}=  Keywordspy.second_password
    ${login}=    Create Dictionary    loginId=${usname}  password=${passwrd}  secondPassword=${pass2}
    ${log}=    json.dumps    ${login}
    Create Session    synw    ${SUPER_URL}  headers=${headers}   verify=true
    ${resp}=    POST On Session     synw    /login    data=${log}   expected_status=any 
    Check Deprication  ${resp}  SuperAdmin Login   
    RETURN  ${resp}

Check And Create YNW SuperAdmin Session
    # ${res}=     Run Keyword And Return Status   GET On Session    synw    /
    ${res}=   Session Exists    synw
    # Run Keyword Unless  ${res}   Create Session    synw    ${SUPER_URL}  headers=${headers}
    IF  not ${res}
        Create Session    synw    ${SUPER_URL}  headers=${headers}  verify=true
    END

Check And Create YNW Support Session
    ${res}=     Session Exists    supportynw
    # Run Keyword Unless  ${res}   Create Session    supportynw    ${SUPPORT_URL}  headers=${headers}
    IF  not ${res}
        Create Session    supportynw    ${SUPPORT_URL}  headers=${headers}  verify=true
    END
    

Check And Create YNW Rest Session
    ${res}=     Session Exists    syn
    # Run Keyword Unless  ${res}   Create Session    syn    ${SUPER_URL1}   headers=${headers}
    IF  not ${res}
        Create Session    syn    ${SUPER_URL1}  headers=${headers}  verify=true
    END


SuperAdmin Change Password
    [Arguments]  ${oldpswd}  ${newpswd}
    ${auth}=    Create Dictionary    oldpassword=${oldpswd}    password=${newpswd}  
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session     synw    /login/chpwd    data=${apple}  expected_status=any
    Check Deprication  ${resp}  SuperAdmin Change Password  
    RETURN  ${resp}

SuperAdmin Check Password
    [Arguments]    ${secondpass}
    ${login}=    Create Dictionary    secondPassword=${secondpass}
    ${log}=    json.dumps    ${login}
    Check And Create YNW SuperAdmin Session
    ${resp}=    POST On Session     synw    /login/checkpwd    data=${log}  expected_status=any
    Check Deprication  ${resp}  SuperAdmin Check Password
    RETURN  ${resp}

Get Licensable Packages For Superadmin
    Check And Create YNW Session
    ${resp}=    GET On Session    synw  /account/licensepackages  expected_status=any
    Check Deprication  ${resp}  Get Licensable Packages For Superadmin
    RETURN  ${resp} 

Get Addons Metadata For Superadmin
    Check And Create YNW Session
    ${resp}=    GET On Session    synw  /account/license/addonmetadata  expected_status=any
    Check Deprication  ${resp}  Get Addons Metadata For Superadmin
    RETURN  ${resp}

	
SuperAdmin Logout
    Check And Create YNW SuperAdmin Session
    ${resp}=    DELETE On Session     synw    /login  expected_status=any
    Check Deprication  ${resp}  SuperAdmin Logout
    RETURN  ${resp}
    
HealthMonitor
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session     synw   /health  params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  HealthMonitor
    RETURN  ${resp}

HealthMonitorId
    [Arguments]  ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session     synw   /health/${id}  expected_status=any
    Check Deprication  ${resp}  HealthMonitorId
    RETURN  ${resp}

HealthMonitor Config
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session     synw   /health/config  params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  HealthMonitor Config
    RETURN  ${resp}

HealthMonitor Count
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session     synw   /health/count  params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  HealthMonitor Count
    RETURN  ${resp}

SuperAdmin Login Analytics
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session     synw   /login/analytics  expected_status=any
    Check Deprication  ${resp}  SuperAdmin Login Analytics
    RETURN  ${resp}

SuperAdmin Signup Analytics
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session     synw   /login/signup/analytics  expected_status=any
    Check Deprication  ${resp}  SuperAdmin Signup Analytics
    RETURN  ${resp}


Get Config
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw  /health/config  expected_status=any
    Check Deprication  ${resp}  Get Config
    RETURN  ${resp}


Get Health Status
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw  /health  params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  Get Health Status
    RETURN  ${resp}

Build Cache
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session   synw  /cache   expected_status=any
    Check Deprication  ${resp}  Build Cache
    RETURN  ${resp}

Schedule Maintenance
    [arguments]  ${date}  ${time}
    Check And Create YNW SuperAdmin Session
    ${data}=  Create Dictionary  maintenanceOn=${date}  maintenanceTime=${time}
    ${data}=    json.dumps  ${data}
    ${resp}=  POST On Session   synw  /maintenance  data=${data}  expected_status=any
    Check Deprication  ${resp}  Schedule Maintenance
    RETURN  ${resp}

Enable Maintenance
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw  /maintenance/true  expected_status=any
    Check Deprication  ${resp}  Enable Maintenance
    RETURN  ${resp}

Disable Maintenance
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw  /maintenance/false  expected_status=any
    Check Deprication  ${resp}  Disable Maintenance
    RETURN  ${resp}


Get Accounts
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw  /account   params=${kwargs}  expected_status=any  
    Check Deprication  ${resp}  Get Accounts
    RETURN  ${resp}

Get Account Id 
    [Arguments]  ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session  synw  /account/${id}   expected_status=any
    Check Deprication  ${resp}  Get Account Id
    RETURN  ${resp}

Get Accounts Count
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw  /account/count   params=${kwargs}  expected_status=any  
    Check Deprication  ${resp}  Get Accounts Count
    RETURN  ${resp}

Get Service Sectors
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw  /account/serviceSectors  params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  Get Service Sectors
    RETURN  ${resp}

Get Location BySuperadmin
    [Arguments]   ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw  /account/locations/${id}  expected_status=any
    Check Deprication  ${resp}  Get Location BySuperadmin
    RETURN  ${resp}

Get AccountAnalytics
    [Arguments]  ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw  /analytics/accounts/${id}  expected_status=any
    Check Deprication  ${resp}  Get AccountAnalytics
    RETURN  ${resp}

Get ConsumerAnalytics
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw  /analytics/consumers   params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  Get ConsumerAnalytics
    RETURN  ${resp}

Get Consumers
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw  /consumer   params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  Get Consumers
    RETURN  ${resp}

Get ConsumersCount
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw  /consumer/count   params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  Get ConsumersCount
    RETURN  ${resp}

Superadmin Get ConsumerById
    [Arguments]  ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw  /consumer/${id}  expected_status=any
    Check Deprication  ${resp}  Superadmin Get ConsumerById
    RETURN  ${resp}

Get ActiveAccounts
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw  /analytics      params=${kwargs}  expected_status=any  
    Check Deprication  ${resp}  Get ActiveAccounts
    RETURN  ${resp}

Get AuditLog
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw  /auditlog     params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  Get AuditLog
    RETURN  ${resp}

Get SortAuditLog
    [Arguments]  ${sort}=sortby_date   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw  /auditlog     params=${sort} ${kwargs}    expected_status=any
    Check Deprication  ${resp}  Get SortAuditLog
    RETURN  ${resp}

Get AuditLog Count
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw  /auditlog/count      params=${kwargs}  expected_status=any  
    Check Deprication  ${resp}  Get AuditLog Count
    RETURN  ${resp}

Get Account Config
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw  /account/config     params=${kwargs}  expected_status=any  
    Check Deprication  ${resp}  Get Account Config
    RETURN  ${resp}

Get Signedup Consumers
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw  /analytics/consumers/count     params=${kwargs}  expected_status=any  
    Check Deprication  ${resp}  Get Signedup Consumers
    RETURN  ${resp}

Superadmin GetWaitlistCount
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw  /analytics/waitlist/count      params=${kwargs}  expected_status=any  
    Check Deprication  ${resp}  Superadmin GetWaitlistCount
    RETURN  ${resp}

Get Account Credentials
    [Arguments]  ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session  synw  /account/credentials/${id}  expected_status=any
    Check Deprication  ${resp}  Get Account Credentials
    RETURN  ${resp}

Toggle Status
    [Arguments]  ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw  /account/toggleStatus/${id}  expected_status=any
    Check Deprication  ${resp}  Toggle Status
    RETURN  ${resp}

Toggle StatusConsumer
    [Arguments]  ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw  /consumer/toggleStatus/${id}  expected_status=any
    Check Deprication  ${resp}  Toggle StatusConsumer
    RETURN  ${resp}

Delete Account
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=  DELETE On Session   synw  /account  params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  Delete Account
    RETURN  ${resp}   

Delete Consumer
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=  DELETE On Session   synw  /consumer  params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  Delete Consumer
    RETURN  ${resp}   

Verify Account
    [Arguments]  ${verifylevel}  ${verifiedby}  ${aid}
    ${verify}=    Create Dictionary    verifyLevel=${verifylevel}  verifiedBy=${verifiedby}  accountId=${aid}
    ${data}=    json.dumps    ${verify}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session     synw    /account/verify    data=${data}  expected_status=any
    Check Deprication  ${resp}  Verify Account
    RETURN  ${resp}

Get Consumers City
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw  /consumer/city     params=${kwargs}  expected_status=any  
    Check Deprication  ${resp}  Get Consumers City
    RETURN  ${resp}

Get Consumers State
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw  /consumer/state     params=${kwargs}  expected_status=any  
    Check Deprication  ${resp}  Get Consumers State
    RETURN  ${resp}

Support Login
    [Arguments]   ${usname}  ${passwrd}  
    ${secondpass}=  support_secondpassword
    ${supportlogin}=  Create Dictionary  loginId=${usname}  password=${passwrd}  secondPassword=${secondpass}
    ${log}=  json.dumps  ${supportlogin}
    Create Session    supportynw    ${SUPPORT_URL}  headers=${headers}    verify=true
    ${resp}=    POST On Session     supportynw    /login    data=${log}  expected_status=any
    Check Deprication  ${resp}  Support Login
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
    Check Deprication  ${resp}  Support Change Password
    RETURN  ${resp}

Support Check Password
    [Arguments]    ${secondpassword}
    ${supportlogin}=    Create Dictionary    secondPassword=${secondpassword}
    ${log}=    json.dumps    ${supportlogin}
    Check And Create YNW Support Session
    ${resp}=    POST On Session     supportynw    /login/checkpwd    data=${log}  expected_status=any
    Check Deprication  ${resp}  Support Check Password
    RETURN  ${resp}

Support Logout
    Check And Create YNW Support Session
    ${resp}=    DELETE On Session     supportynw   /login   expected_status=any
    Check Deprication  ${resp}  Support Logout
    RETURN  ${resp}

Support Get Account
    [Arguments]   &{kwargs}
    Check And Create YNW Support Session
    ${resp}=    GET On Session   supportynw  /account   params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  Support Get Account
    RETURN  ${resp}

Support Get Account Count
    [Arguments]  &{kwargs}
    Check And Create YNW Support Session
    ${resp}=  GET On Session   supportynw  /account/count   params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  Support Get Account Count
    RETURN  ${resp}


Support Get Account Credentials
    [Arguments]  ${id}
    Check And Create YNW Support Session
    ${resp}=  GET On Session  supportynw  /account/credentials/${id}  expected_status=any
    Check Deprication  ${resp}  Support Get Account Credentials
    RETURN  ${resp}


Apply Account License details
    [Arguments]  ${accid}  ${licensePackage}
    ${auth}=    Create Dictionary    accountId=${accid}   licensePackageId=${licensePackage} 
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=    POST On Session   synw   /account/license/apply   data=${apple}  expected_status=any
    Check Deprication  ${resp}  Apply Account License details
    RETURN  ${resp}


Change Account License details  
    [Arguments]  ${accid}  ${licensePackage}
    ${auth}=    Create Dictionary    accountId=${accid}   licensePackageId=${licensePackage} 
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session   synw   /account/license/change   data=${apple}  expected_status=any
    Check Deprication  ${resp}  Change Account License details
    RETURN  ${resp} 
     
    
GET Account License details
    [Arguments]  ${accountid}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/license/${accountid}  expected_status=any
    Check Deprication  ${resp}  GET Account License details
    RETURN  ${resp} 
    
Get License Transaction details
    [Arguments]  ${accountid}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/license/auditlog/${accountid}   expected_status=any
    Check Deprication  ${resp}  Get License Transaction details
    RETURN  ${resp} 
    
Get Licensable Package details
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/licensepackages   expected_status=any
    Check Deprication  ${resp}  Get Licensable Package details
    RETURN  ${resp} 
    
Get Account Addon details
    [Arguments]  ${accountid}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/license/addon/${accountid}   expected_status=any
    Check Deprication  ${resp}  Get Account Addon details
    RETURN  ${resp} 

Add Addons details
    [Arguments]  ${accid}  ${addonid}
    ${auth}=    Create Dictionary    accountId=${accid}   addonIds=${addonid} 
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=    POST On Session   synw   /account/license/addon/add   data=${apple}  expected_status=any
    Check Deprication  ${resp}  Add Addons details
    RETURN  ${resp} 
   
Get Invoices superadmin
    [Arguments]  ${accountId}  ${subscriptionPaymentStatus}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /account/license/invoice/${accountId}/${subscriptionPaymentStatus}
    Check Deprication  ${resp}  Get Invoices superadmin
    RETURN  ${resp}

Invoice Discount apply 
    [Arguments]    ${uid}   ${name}   ${description}    ${calculationType}   ${discValue}  
    ${discount}=   Create Dictionary   name=${name}   description=${description}    calculationType=${calculationType}   discountValue=${discValue}  
    ${data}=  Create Dictionary    uuid=${uid}   discount=${discount}
    ${data}=  json.dumps  ${data} 
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session  synw  /account/license/invoice/disc   data=${data}  expected_status=any
    Check Deprication  ${resp}  Invoice Discount apply 
    RETURN  ${resp}
 
AcceptPayment By Superadmin
    [Arguments]   ${uuid}  ${acceptPaymentBy}  ${collectedBy}  ${collectedDate}   ${note}     ${amountToPay}
    ${data}=   Create Dictionary   uuid=${uuid}  acceptPaymentBy=${acceptPaymentBy}   collectedBy=${collectedBy}  collectedDate=${collectedDate}  note=${note}    amountToPay=${amountToPay}
    ${auth}=    json.dumps  ${data} 
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session  synw  /account/license/invoice/acceptPayment   data=${auth}  expected_status=any
    Check Deprication  ${resp}  AcceptPayment By Superadmin
    RETURN  ${resp}

Cancel Invoice
    [Arguments]  ${uuid}  ${cancelReason}
    ${data}=  Create Dictionary   uuid=${uuid}   cancelReason=${cancelReason}
    ${auth}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw  /account/license/invoice   data=${auth}  expected_status=any
    Check Deprication  ${resp}  Cancel Invoice
    RETURN  ${resp}

Statement Details
    [Arguments]  ${uuid} 
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /account/license/invoice/${uuid}  expected_status=any
    Check Deprication  ${resp}  Statement Details
    RETURN  ${resp}

Remove Addon details
    [Arguments]  ${accid}  ${addonid}
    ${auth}=    Create Dictionary    accountId=${accid}   addonId=${addonid}  expected_status=any 
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=    DELETE On Session   synw   /account/license/addon/${accid}/${addonid}   data=${apple}  expected_status=any
    Check Deprication  ${resp}  Remove Addon details
    RETURN  ${resp}
    
Get Account AddonsMetadata details
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/license/addonmetadata  expected_status=any 
    Check Deprication  ${resp}  Get Account AddonsMetadata details
    RETURN  ${resp} 

Get Addon Transactions details
    [Arguments]  ${accountid}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/license/addon/auditlog/${accountid}  expected_status=any 
    Check Deprication  ${resp}  Get Addon Transactions details
    RETURN  ${resp} 
                                  
Get day out of compliance
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/license/dayoutofcomplaince  expected_status=any 
    Check Deprication  ${resp}  Get day out of compliance
    RETURN  ${resp} 
    
Get month out of compliance
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/license/monthoutofcomplaince  expected_status=any 
    Check Deprication  ${resp}  Get month out of compliance
    RETURN  ${resp} 

Get License Analytics according to package 
    [Arguments]  ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/license/analytics/${id}  expected_status=any 
    Check Deprication  ${resp}  Get License Analytics according to package 
    RETURN  ${resp}

Get License Analytics
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/license/analytics/packages  expected_status=any 
    Check Deprication  ${resp}  Get License Analytics
    RETURN  ${resp}  
    
Update License Renewal Details
    [Arguments]  ${accid}  ${rsn}  ${durtn}
    ${auth}=    Create Dictionary    accountId=${accid}   Reason=${rsn}   duration=${durtn}
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session   synw   /account/license/renewal   data=${apple}  expected_status=any
    Check Deprication  ${resp}  Update License Renewal Details
    RETURN  ${resp}          

SuperAdmin Change License
    [Arguments]  ${accountId}  ${licensePackageId}  
    ${auth}=    Create Dictionary    accountId=${accountId}   licensePackageId=${licensePackageId}   
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session   synw  /account/license/change   data=${apple}  expected_status=any
    Check Deprication  ${resp}  SuperAdmin Change License
    RETURN  ${resp}       

SuperAdmin Add Addon
    [Arguments]  ${accountId}  ${addonIds}  
    ${auth}=    Create Dictionary    accountId=${accountId}   addonIds=${addonIds}   
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=    POST On Session   synw  /account/license/addon/add   data=${apple}  expected_status=any
    Check Deprication  ${resp}  SuperAdmin Add Addon
    RETURN  ${resp}

SuperAdmin delete Addon
    [Arguments]  ${accountId}  ${addonIds} 
    Check And Create YNW SuperAdmin Session
    ${resp}=    DELETE On Session   synw  /account/license/addon/${accountId}/${addonIds}  expected_status=any
    Check Deprication  ${resp}  SuperAdmin delete Addon
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
    Check Deprication  ${resp}  Create Jaldee Coupon
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
    Check Deprication  ${resp}  Create Jaldee Coupon For Providers
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
    Check Deprication  ${resp}  Get Jaldee Coupon By CouponCode
    RETURN  ${resp} 

Get Jaldee Coupons
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /jc  expected_status=any  
    Check Deprication  ${resp}  Get Jaldee Coupons
    RETURN  ${resp} 

Get Jaldee Coupons Count
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /jc/count   params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  Get Jaldee Coupons Count
    RETURN  ${resp} 

Get Jaldee Coupons Stats
    [Arguments]  ${code}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /jc/${code}/stats  expected_status=any
    Check Deprication  ${resp}  Get Jaldee Coupons Stats
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
    Check Deprication  ${resp}  Update Jaldee Coupon
    RETURN  ${resp} 

Update Jaldee Coupon After Push
    [Arguments]  ${jcode}  ${name}  ${des}  ${eDate}  ${c_terms}  ${p_desc}
    ${coupon_det}=  Create Dictionary  couponName=${name}  couponDescription=${des}  consumerTermsAndconditions=${c_terms}  providerDescription=${p_desc}  newEndDate=${eDate}
    ${coupon}=    json.dumps    ${coupon_det}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session   synw   /jc/${jcode}   data=${coupon}  expected_status=any
    Check Deprication  ${resp}  Update Jaldee Coupon After Push
    RETURN  ${resp} 

Update Jaldee Coupon For Providers
    [Arguments]  ${jcode}  ${code}  ${name}  ${des}  ${age}  ${sDate}  ${eDate}  ${d_type}  ${d_value}  ${d_max}  ${def_enable}  ${al_enable}  ${max_rem}  ${amt}  ${pro_use}  ${cons_use}  ${limit_prov}  ${c_first_ckn}  ${p_first_ckn}  ${self_pay}  ${online_ckn}  ${combine}  ${c_terms}  ${p_desc}  ${p_id}
    ${rules}=    Create Dictionary     defaultEnabled=${def_enable}  alwaysEnabled=${al_enable}  maxReimbursePercentage=${max_rem}  minBillAmount=${amt}  maxProviderUseLimit=${pro_use}  maxConsumerUseLimit=${cons_use}  maxConsumerUseLimitPerProvider=${limit_prov}  firstCheckinOnly=${c_first_ckn}  firstCheckinPerProviderOnly=${p_first_ckn}  selfPaymentRequired=${self_pay}  onlineCheckinRequired=${online_ckn}  combineWithOtherCoupon=${combine}  ageGroup=${age}  startDate=${sDate}  endDate=${eDate}
    ${tar}=   Create Dictionary    providerId=${p_id} 
    ${coupon_det}=  Create Dictionary  jaldeeCouponCode=${code}  couponName=${name}  couponDescription=${des}  consumerTermsAndconditions=${c_terms}  providerDescription=${p_desc}   discountType=${d_type}  discountValue=${d_value}  maxDiscountValue=${d_max}   couponRules=${rules}  target=${tar}
    ${coupon}=    json.dumps    ${coupon_det}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session   synw   /jc/${jcode}    data=${coupon}  expected_status=any
    Check Deprication  ${resp}  Update Jaldee Coupon For Providers
    RETURN  ${resp}

Update Jaldee Coupon For Providers After Push
    [Arguments]  ${jcode}  ${name}  ${des}  ${eDate}  ${c_terms}  ${p_desc}
    ${coupon_det}=  Create Dictionary  couponName=${name}  couponDescription=${des}  consumerTermsAndconditions=${c_terms}  providerDescription=${p_desc}   newEndDate=${eDate}
    ${coupon}=    json.dumps    ${coupon_det}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session   synw   /jc/${jcode}    data=${coupon}  expected_status=any
    Check Deprication  ${resp}  Update Jaldee Coupon For Providers After Push
    RETURN  ${resp}


Delete Jaldee Coupon
    [Arguments]  ${coupon_code}
    Check And Create YNW SuperAdmin Session
    ${resp}=  DELETE On Session   synw  /jc/${coupon_code}  expected_status=any
    Check Deprication  ${resp}  Delete Jaldee Coupon
    RETURN  ${resp}

Disable Jaldee Coupon
    [Arguments]  ${coupon_code}  ${msg}
    ${message}=    Create Dictionary    message=${msg}
    ${data}=    json.dumps    ${message}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw  /jc/${coupon_code}/disable   data=${data}  expected_status=any
    Check Deprication  ${resp}  Disable Jaldee Coupon
    RETURN  ${resp}

Push Jaldee Coupon
    [Arguments]  ${coupon_code}  ${msg}
    ${message}=    Create Dictionary    message=${msg}
    ${data}=    json.dumps    ${message}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session   synw  /jc/${coupon_code}/push    data=${data}  expected_status=any
    Check Deprication  ${resp}  Push Jaldee Coupon
    RETURN  ${resp}

Get Reimburse Reports
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /jc/reports  expected_status=any
    Check Deprication  ${resp}  Get Reimburse Reports
    RETURN  ${resp} 

Get Reimburse Reports Count
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw    /jc/reports/count  params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  Get Reimburse Reports Count
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
    Check Deprication  ${resp}  Reimburse Payment
    RETURN  ${resp}

Get Reimbursement By InvoiceId
    [Arguments]  ${invoice_id}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw    /jc/reimburse/${invoice_id}  expected_status=any
    Check Deprication  ${resp}  Get Reimbursement By InvoiceId
    RETURN  ${resp} 

Change Reimbursement Status
    [Arguments]  ${invoice_id}  ${status}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session   synw    /jc/reimburse/${invoice_id}/${status}  expected_status=any
    Check Deprication  ${resp}  Change Reimbursement Status
    RETURN  ${resp} 

Payu Verification
    [Arguments]  ${acc_id}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session   synw   /payment/payu/${acc_id}  expected_status=any
    Check Deprication  ${resp}  Payu Verification
    RETURN  ${resp}

Change Provider Phoneno
    [Arguments]  ${acc_id}  ${phone_no}
    ${data}=    Create Dictionary    accountId=${acc_id}  phone=${phone_no}
    ${data1}=    json.dumps    ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw   /account/settings/changePrimaryPhone   data=${data1}  expected_status=any
    Check Deprication  ${resp}  Change Provider Phoneno
    RETURN  ${resp}


Create Corporate
    [Arguments]    ${c_name}  ${c_code}  ${email}  ${phone}  ${contact_name}  ${contact_lname}  ${contact_phone}   ${domain}  ${subDomain}  ${licPkgId}
    ${data}=  Create Dictionary   corporateName=${c_name}  corporateCode=${c_code}  officeEmail=${email}  officePhone=${phone}  contactPersonFirstName=${contact_name}  contactPersonLastName=${contact_lname}  contactPersonMobNo=${contact_phone}  domain=${domain}  subDomain=${subDomain}  licPkgId=${licPkgId}  multilevel=True
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session   synw  /corporate  data=${data}  expected_status=any
    Check Deprication  ${resp}  Create Corporate
    RETURN  ${resp}

Get Corporate
    [Arguments]  ${c_id}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw    /corporate/${c_id}  expected_status=any
    Check Deprication  ${resp}  Get Corporate
    RETURN  ${resp} 

Update Corporate
    [Arguments]  ${c_id}  ${c_uid}  ${c_name}  ${c_code}  ${email}  ${phone}  ${contact_name}  ${contact_lname}  ${contact_phone}
    ${data}=  Create Dictionary  corporateId=${c_id}  corporateUid=${c_uid}  corporateName=${c_name}  corporateCode=${c_code}  officeEmail=${email}  officePhone=${phone}  contactPersonFirstName=${contact_name}  contactPersonLastName=${contact_lname}  contactPersonMobNo=${contact_phone}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw  /corporate  data=${data}  expected_status=any
    Check Deprication  ${resp}  Update Corporate
    RETURN  ${resp}

Update CorporateCenter
    [Arguments]  ${c_id}  ${c_uid}  ${c_name}  ${c_mob}  ${domain}  ${sub_domain}  ${center}
    ${data}=  Create Dictionary  corporateId=${c_id}  corporateUid=${c_uid}  corporateName=${c_name}   contactPersonMobNo=${c_mob}  domain=${domain}  subDomain=${sub_domain}  centralised=${center}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw  /corporate  data=${data}  expected_status=any
    Check Deprication  ${resp}  Update CorporateCenter
    RETURN  ${resp}

Get Corporates
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw    /corporate   params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  Get Corporates
    RETURN  ${resp} 

Get verification Level For Independent-SP Byid
    [Arguments]  ${accId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw   /account/verification/${accId}  expected_status=any
    Check Deprication  ${resp}  Get verification Level For Independent-SP Byid
    RETURN  ${resp}
 
Get verification Level History For Independent-SP
    [Arguments]   ${accId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw   /account/verification/logs/${accId}  expected_status=any
    Check Deprication  ${resp}  Get verification Level History For Independent-SP
    RETURN  ${resp}

Create verification Level For Independent-SP 
    [Arguments]   ${accId}   ${verifylevel}  ${verifyLink}  ${verifynote}  ${verifiedby}  ${verifiedOn}  ${d_applied}  ${t_chrged}  ${t_coll}  ${pay_M}  ${pay_by}  ${p_note}
    ${verification_D}=  Create Dictionary   verifyLink=${verifyLink}  verifiedNote=${verifynote}   verifiedBy=${verifiedby}  verifiedOn=${verifiedOn} 
    ${payment_D}=   Create Dictionary  discountApplied=${d_applied}  totalCharged=${t_chrged}  totalCollected=${t_coll}  paymentMode=${pay_M}  paymentDoneBy=${pay_by} 
    ${auth}=  Create Dictionary  accountId=${accId}  verifiedLevel=${verifylevel}  verificationDetails=${verification_D}  paymentDetails=${payment_D}  privateNote=${p_note}
    ${auth}=  json.dumps  ${auth} 
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session   synw      /account/verification     data=${auth}  expected_status=any
    Check Deprication  ${resp}  Create verification Level For Independent-SP 
    RETURN  ${resp}

Create verification Level For Corporate
    [Arguments]    ${c_id}   ${verifylevel}  ${verifyLink}  ${verifynote}  ${verifiedby}  ${verifiedOn}  ${d_applied}  ${t_chrged}  ${t_coll}  ${pay_M}  ${pay_by}  ${p_note}
    ${verification_D}=  Create Dictionary   verifyLink=${verifyLink}  verifiedNote=${verifynote}   verifiedBy=${verifiedby}  verifiedOn=${verifiedOn} 
    ${payment_D}=   Create Dictionary  discountApplied=${d_applied}  totalCharged=${t_chrged}  totalCollected=${t_coll}  paymentMode=${pay_M}  paymentDoneBy=${pay_by} 
    ${auth}=  Create Dictionary  corpId=${c_id}  verifiedLevel=${verifylevel}  verificationDetails=${verification_D}  paymentDetails=${payment_D}  privateNote=${p_note}
    ${auth}=  json.dumps  ${auth} 
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session   synw     /corporate/verification    data=${auth}  expected_status=any
    Check Deprication  ${resp}  Create verification Level For Corporate
    RETURN  ${resp}

Get verification Level For Corporate- Byid
    [Arguments]  ${c_id}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw    /corporate/verification/${c_id}  expected_status=any
    Check Deprication  ${resp}  Get verification Level For Corporate- Byid
    RETURN  ${resp}
 
Get verification Level History For Corporate
    [Arguments]  ${c_id}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw  /corporate/verification/logs/${c_id}  expected_status=any
    Check Deprication  ${resp}  Get verification Level History For Corporate
    RETURN  ${resp}	


	
Update verification Level For Independent-SP
    [Arguments]   ${accId}   ${verifylevel}    ${verifyLink}  ${verifynote}  ${verifiedby}  ${verifiedOn}  ${d_applied}  ${t_chrged}  ${t_coll}  ${pay_M}  ${pay_by}  ${p_note}
    ${verification_D}=  Create Dictionary   verifyLink=${verifyLink}  verifiedNote=${verifynote}   verifiedBy=${verifiedby}   verifiedOn=${verifiedOn} 
    ${payment_D}=   Create Dictionary  discountApplied=${d_applied}  totalCharged=${t_chrged}  totalCollected=${t_coll}  paymentMode=${pay_M}  paymentDoneBy=${pay_by} 
    ${auth}=  Create Dictionary  accountId=${accId}  verifiedLevel=${verifylevel}  verificationDetails=${verification_D}  paymentDetails=${payment_D}   privateNote=${p_note}
    ${auth}=  json.dumps  ${auth} 
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw  /account/verification  data=${auth}  expected_status=any
    Check Deprication  ${resp}  Update verification Level For Independent-SP
    RETURN  ${resp}

Update corporate verification Level 
    [Arguments]   ${c_id}   ${verifylevel}    ${verifyLink}  ${verifynote}  ${verifiedby}  ${verifiedOn}  ${d_applied}  ${t_chrged}  ${t_coll}  ${pay_M}  ${pay_by}  ${p_note}
    ${verification_D}=  Create Dictionary   verifyLink=${verifyLink}  verifiedNote=${verifynote}   verifiedBy=${verifiedby}   verifiedOn=${verifiedOn} 
    ${payment_D}=   Create Dictionary  discountApplied=${d_applied}  totalCharged=${t_chrged}  totalCollected=${t_coll}  paymentMode=${pay_M}  paymentDoneBy=${pay_by} 
    ${auth}=  Create Dictionary  corpId=${c_id}  verifiedLevel=${verifylevel}  verificationDetails=${verification_D}  paymentDetails=${payment_D}   privateNote=${p_note}
    ${auth}=  json.dumps  ${auth} 
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw  /corporate/verification  data=${auth}  expected_status=any
    Check Deprication  ${resp}  Update corporate verification Level
    RETURN  ${resp}
 
Branch Signup by Superadmin
    [Arguments]  ${cop_id}  ${name}  ${code}  ${reg_code}  ${email}  ${desc}  ${pass}  ${p_name}  ${p_l_name}  ${city}  ${state}  ${address}  ${mob_no}  ${al_phone}  ${dob}  ${gender}  ${p_email}  ${country_code}  ${is_admin}  ${sector}  ${sub_sector}  ${licpkg}  @{vargs}
    ${provider}=  Create Dictionary  firstName=${p_name}  lastName=${p_l_name}  city=${city}  state=${state}  address=${address}  primaryMobileNo=${mob_no}  alternativePhoneNo=${al_phone}  dob=${dob}  gender=${gender}  email=${p_email}  countryCode=${country_code}
    ${profile}=  Create Dictionary  userProfile=${provider}  isAdmin=${is_admin}  sector=${sector}  subSector=${sub_sector}  licPkgId=${licpkg}
    ${data}=  Create Dictionary  corpId=${cop_id}  branchName=${name}  branchCode=${code}  regionalCode=${reg_code}  branchEmail=${email}  branchDescription=${desc}  commonPassword=${pass}  provider=${profile}   services=${vargs}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  synw   /sa/branch   data=${data}  expected_status=any
    Check Deprication  ${resp}  Branch Signup by Superadmin
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
    Check Deprication  ${resp}  Branch Business Profile by Superadmin
    RETURN  ${resp}

Enable/Disable Branch Search Data by superadmin
    [Arguments]   ${acct_id}  ${status}
    ${params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${resp}=  PUT On Session  synw   /sa/search/${status}    params=${params}  expected_status=any
    Check Deprication  ${resp}  Enable/Disable Branch Search Data by superadmin
    RETURN  ${resp}
      
    
Enable Department Filter
    [Arguments]  ${acct_id}
    ${params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${resp}=  PUT On Session  synw  /sa/branch/department/Enable  params=${params}  expected_status=any
    Check Deprication  ${resp}  Enable Department Filter
    RETURN  ${resp}
    
Disable Department Filter
    [Arguments]  ${acct_id}
    ${params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${resp}=  PUT On Session  synw  /sa/branch/department/Disable  params=${params}  expected_status=any
    Check Deprication  ${resp}  Disable Department Filter
    RETURN  ${resp}


Update Business Profile Of Branch For Specialization by superadmin
    [Arguments]  ${acct_id}  @{data}   
    ${params}=  Create Dictionary  account=${acct_id} 
    ${data}=  Create Dictionary  specialization=${data}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  synw  /sa/bProfile   data=${data}  params=${params}  expected_status=any
    Check Deprication  ${resp}  Update Business Profile Of Branch For Specialization by superadmin
    RETURN  ${resp}   
    

Create Subscription License Discount
    [Arguments]  ${lDName}  ${desn}  ${ldisc}  ${vaFrom}  ${vaTo}  ${lDType}  ${sectorid}   ${subsectorid}   ${cId}  ${acId}  ${lPkgLevel}  ${lPkgId}   ${lDiSts}  ${combinedMultipleDisc} 
    # ${sectorid}=   Create List  ${sectorid}
    # ${subsectorid}=  Create List   ${subsectorid}
    ${data}=  Create Dictionary  licDiscName=${lDName}   description=${desn}  licDiscCode=${ldisc}  validFrom=${vaFrom}  validTo=${vaTo}  licDiscType=${lDType}  sectorIds=${sectorid}  subsectorIds=${subsectorid}  corpIds=${cId}  accountIds=${acId}    licPkgMinimumLevel=${lPkgLevel}  licPkgId=${lPkgId}    licDiscStatus=${lDiSts}  combinedMultipleDisc=${combinedMultipleDisc} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session   synw     /license/discount   data=${data}  expected_status=any   
    Check Deprication  ${resp}  Create Subscription License Discount
    RETURN  ${resp}


Update Subscription License Discount
    [Arguments]  ${licDiscountId}  ${lDName}  ${desn}  ${ldisc}  ${vaFrom}  ${vaTo}  ${lDType}  ${seId}  ${subsId}   ${cId}  ${acId}  ${lPkgLevel}  ${lPkgId}   ${lDiSts}  ${combinedMultipleDisc} 
    ${data}=  Create Dictionary  licDiscName=${lDName}   description=${desn}  licDiscCode=${ldisc}  validFrom=${vaFrom}  validTo=${vaTo}  licDiscType=${lDType}  sectorId=${seId}  subsectorId=${subsId}  corpId=${cId}  accountId=${acId}    licPkgMinimumLevel=${lPkgLevel}  licPkgId=${lPkgId}    licDiscStatus=${lDiSts}  combinedMultipleDisc=${combinedMultipleDisc} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw     /license/discount/${licDiscountId}   data=${data}  expected_status=any   
    Check Deprication  ${resp}  Update Subscription License Discount
    RETURN  ${resp}

Update Subscription License Discount code
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw    /license/discount   params=${kwargs}  expected_status=any 
    Check Deprication  ${resp}  Update Subscription License Discount code
    RETURN  ${resp}   


Get Subscription License Discount By op
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /license/discount    params=${kwargs}  expected_status=any 
    Check Deprication  ${resp}  Get Subscription License Discount By op
    RETURN  ${resp} 

Get Subscription License Discount By LicenseDsid
    [Arguments]  ${Licdid}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /license/discount/${Licdid}  expected_status=any 
    Check Deprication  ${resp}  Get Subscription License Discount By LicenseDsid
    RETURN  ${resp} 

Delete Subscription License Discount 
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    DELETE On Session   synw  license/discount   params=${kwargs}  expected_status=any 
    Check Deprication  ${resp}  Delete Subscription License Discount
    RETURN  ${resp} 

Delete Subscription License Discount by id
    [Arguments]   ${licDiscountId}
    Check And Create YNW SuperAdmin Session
    ${resp}=    DELETE On Session   synw   license/discount/${licDiscountId}  expected_status=any    
    Check Deprication  ${resp}  Delete Subscription License Discount by id
    RETURN  ${resp} 

Change Corporate License
    [Arguments]  ${ci_d}  ${licPkgid}
    ${auth}=    Create Dictionary    corpId=${ci_d}  licPkgId=${licPkgid} 
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session   synw  /corporate/${ci_d}/license/${licPkgid}    data=${apple}  expected_status=any
    Check Deprication  ${resp}  Change Corporate License
    RETURN  ${resp} 

Get corporate license details
    [Arguments]  ${ci_d}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw  /corporate/${ci_d}/license  expected_status=any
    Check Deprication  ${resp}  Get corporate license details
    RETURN  ${resp}  


Change corporate Addon    
    [Arguments]  ${ci_d}  ${AddonId} 
    ${auth}=    Create Dictionary    corpId=${ci_d}  AddonId=${AddonId} 
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=   PUT On Session    synw    corporate/${ci_d}/addon/${AddonId}    data=${apple}  expected_status=any
    Check Deprication  ${resp}  Change corporate Addon
    RETURN  ${resp}


Delete Corporate Addon    
    [Arguments]  ${ci_d}  ${AddonId}
    ${auth}=    Create Dictionary    corpId=${ci_d}  AddonId=${AddonId} 
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session  
    ${resp}=    DELETE On Session   synw   corporate/${ci_d}/addon/${AddonId}    data=${apple}  expected_status=any
    Check Deprication  ${resp}  Delete Corporate Addon
    RETURN  ${resp}

Renew Corporate License 
    [Arguments]  ${ci_d}   ${Reason}   ${duration} 
    ${auth}=    Create Dictionary   corpId=${ci_d}  reason=${Reason}   duration=${duration}
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw   /corporate/license/renewal   data=${apple}   expected_status=any
    Check Deprication  ${resp}  Renew Corporate License
    RETURN  ${resp}


Create License Discount code
    [Arguments]  ${Lcode}  ${desn}  ${lcdsp}
    ${data}=  Create Dictionary  licDiscCode=${Lcode}   description=${desn}  licDiscPercentage=${lcdsp}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session   synw    /license/discount/code   data=${data}  expected_status=any   
    Check Deprication  ${resp}  Create License Discount code
    RETURN  ${resp}

Update license discount code
    [Arguments]  ${id}  ${Lcode}  ${desn}  ${lcdsp}   
    ${data}=  Create Dictionary   licDiscCode=${Lcode}   description=${desn}  licDiscPercentage=${lcdsp}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw   /license/discount/code/${id}   data=${data}  expected_status=any   
    Check Deprication  ${resp}  Update license discount code
    RETURN  ${resp}


Get license discount codes by optional
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /license/discount/code   params=${kwargs}  expected_status=any 
    Check Deprication  ${resp}  Get license discount codes by optional
    RETURN  ${resp}   

Get license discount code details by discCodeId 
    [Arguments]  ${discCodeId}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw    /license/discount/code/${discCodeId}  expected_status=any
    Check Deprication  ${resp}  Get license discount code details by discCodeId
    RETURN  ${resp} 


Delete license discount code by discCodeId 
    [Arguments]  ${discCodeId}
    ${auth}=    Create Dictionary  
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session  
    ${resp}=    DELETE On Session   synw   /license/discount/code/${discCodeId}  expected_status=any
    Check Deprication  ${resp}  Delete license discount code by discCodeId
    RETURN  ${resp}


Update Subdomain_Level sa
    [Arguments]   ${data}   ${acct_id}  ${subdomain} 
    ${params}=    Create Dictionary   account=${acct_id}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /sa/branch/provider/bProfile/${subdomain}   data=${data}   params=${params}  expected_status=any
    Check Deprication  ${resp}  Update Subdomain_Level sa
    RETURN  ${resp}


Update license of branches
    [Arguments]   ${corpId}
    ${auth}=    Create Dictionary  corpId=${corpId} 
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw  /corporate/${corpId}/branch/license  expected_status=any
    Check Deprication  ${resp}  Update license of branches
    RETURN  ${resp}

Get Addons of corporate 
    [Arguments]  ${ci_d}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw  /corporate/${ci_d}/addon  expected_status=any
    Check Deprication  ${resp}  Get Addons of corporate
    RETURN  ${resp}  

Change Subscription Bill cycle 
    [Arguments]  ${accId}   ${licBillCycle} 
    ${auth}=    Create Dictionary   accId=${accId}    licBillCycle=${licBillCycle} 
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session    synw  /account/${accId}/license/billing/${licBillCycle}  expected_status=any 
    Check Deprication  ${resp}  Change Subscription Bill cycle
    RETURN  ${resp}  

Get Start date of next Bill Cycle
    [Arguments]  ${accId}
    ${auth}=    Create Dictionary   accId=${accId}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw  /account/${accId}/license/billing/nextBillCycle  expected_status=any
    Check Deprication  ${resp}  Get Start date of next Bill Cycle
    RETURN  ${resp}  

Get license bill cycle Subscription type
    [Arguments]  ${accId}
    ${auth}=    Create Dictionary   accId=${accId}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw  /account/${accId}/license/billing  expected_status=any
    Check Deprication  ${resp}  Get license bill cycle Subscription type
    RETURN  ${resp}

Change Subscription type to Annual 
    [Arguments]  ${accId}
    ${auth}=    Create Dictionary   accId=${accId}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session    synw  /account/license/subscription/${accId}  expected_status=any
    Check Deprication  ${resp}  Change Subscription type to Annual
    RETURN  ${resp} 



Get jdn config of a corporate
    [Arguments]   ${corpId}
    ${auth}=    Create Dictionary  corpId=${corpId} 
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw  /corporate/${corpId}/jdn/config  expected_status=any
    Check Deprication  ${resp}  Get jdn config of a corporate
    RETURN  ${resp}

Disable jdn of a corporate  
    [Arguments]   ${corpId}
    ${auth}=    Create Dictionary  corpId=${corpId} 
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw  /corporate/${corpId}/jdn/disable  expected_status=any
    Check Deprication  ${resp}  Disable jdn of a corporate
    RETURN  ${resp}

Enable jdn if it is already disabled
    [Arguments]   ${corpId}
    ${auth}=    Create Dictionary  corpId=${corpId} 
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw  /corporate/${corpId}/jdn/enable  expected_status=any
    Check Deprication  ${resp}  Enable jdn if it is already disabled
    RETURN  ${resp}

Create JDN 
    [Arguments]   ${corpId}  ${label}  ${displyNote}  ${discPercentage}   ${discMax}
    ${auth}=  Create Dictionary  corpId=${corpId}  label=${label}  displyNote=${displyNote}  discPercentage=${discPercentage}  discMax=${discMax}
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session   synw  /corporate/${corpId}/jdn/enable  data=${apple}   expected_status=any
    Check Deprication  ${resp}  Create JDN
    RETURN  ${resp}

Update JDN 
    [Arguments]    ${corpId}  ${label}  ${displyNote}  ${discPercentage}   ${discMax}
    ${auth}=  Create Dictionary  corpId=${corpId}  label=${label}  displyNote=${displyNote}  discPercentage=${discPercentage}  discMax=${discMax}
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw  /corporate/${corpId}/jdn  data=${apple}   expected_status=any
    Check Deprication  ${resp}  Update JDN
    RETURN  ${resp}


Enable JDN of Branches
    [Arguments]    ${corpId} 
    ${auth}=  Create Dictionary  corpId=${corpId} 
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session   synw  /corporate/${corpId}/branch/jdn/enable   data=${apple}   expected_status=any
    Check Deprication  ${resp}  Enable JDN of Branches
    RETURN  ${resp}
    
Get discount details of a corporate  
    [Arguments]   ${corpId}
    ${auth}=    Create Dictionary  corpId=${corpId} 
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw   /corporate/${corpId}/jdn   expected_status=any
    Check Deprication  ${resp}  Get discount details of a corporate
    RETURN  ${resp}


Get Account JDN 
    [Arguments]   ${accId}
    ${auth}=    Create Dictionary  accId=${accId} 
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw   /account/${accId}/jdn   expected_status=any
    Check Deprication  ${resp}  Get Account JDN
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
    Check Deprication  ${resp}  Create SA SalesChannel
    RETURN  ${resp}

Get SCAccount Configuration
     Check And Create YNW SuperAdmin Session
     ${resp}=  GET On Session   synw  /account/config  expected_status=any       
     Check Deprication  ${resp}  Get SCAccount Configuration
    RETURN  ${resp}

Get SalesChannel By Id 
    [Arguments]  ${ScId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw  /sc/${ScId}  expected_status=any
    Check Deprication  ${resp}  Get SalesChannel By Id
    RETURN  ${resp}

Get SC Configuration
     Check And Create YNW SuperAdmin Session
     ${resp}=  GET On Session   synw  /sc/config  expected_status=any     
     Check Deprication  ${resp}  Get SC Configuration
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
    Check Deprication  ${resp}  Update SC By Id
    RETURN  ${resp}
    

Create Branch SP
    [Arguments]  ${firstname}  ${lastname}   ${primaryMobileNo}  ${email}  ${subSector}  ${commonPassword}  ${departmentCode}
    ${data}=   Branch User Creation  ${firstname}  ${lastname}  ${primaryMobileNo}  ${email}  ${subSector}  ${commonPassword}  ${departmentCode}
    ${data}=   json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /provider/branch/createSp    data=${data}  expected_status=any
    Check Deprication  ${resp}  Create Branch SP
    RETURN  ${resp}

Delete SC By Id

    [Arguments]  ${ScId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  DELETE On Session   synw  /sc/${ScId}  expected_status=any
    Check Deprication  ${resp}  Delete SC By Id
    RETURN  ${resp}

Get SC By Id Status

    [Arguments]  ${scId}  ${scStatus}
    Check And Create YNW SuperAdmin Session
    Log  ${scStatus}
    ${resp}=  PUT On Session   synw  /sc/${scId}/${scStatus}  expected_status=any
    Check Deprication  ${resp}  Get SC By Id Status
    RETURN  ${resp}

Create SP SalesRep 

    [Arguments]  ${scId}  ${firstName}  ${lastName}   ${phoneNo}   ${email}   ${kyc}   ${kycDoneBy}   ${areasResponsible}   ${repCode}
    ${scId}=  Create Dictionary  id=${scId}
    ${data}=  Create Dictionary  scId=${scId}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phoneNo}   email=${email}  kyc=${kyc}  kycDoneBy=${kycDoneBy}     privateNote=${privateNote}  areasResponsible=${areasResponsible}  repCode=${repCode}
    ${data}=  json.dumps  ${data}
    Log  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session  synw  /sc/rep  data=${data}  expected_status=any
    Check Deprication  ${resp}  Create SP SalesRep
    RETURN  ${resp} 

Get SC List
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /sc  params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  Get SC List
    RETURN  ${resp} 

Delete SP By Id
    [Arguments]   ${SpId}
    Check And Create YNW SuperAdmin Session
    Log  ${SpId}
    ${resp}=  DELETE On Session   synw   /sc/rep/${SpId}  expected_status=any
    Check Deprication  ${resp}  Delete SP By Id
    RETURN  ${resp}

Update SC By Id And Status
    [Arguments]   ${stat}  ${scId}  ${providerDiscFromJaldee}  ${providerDiscDuration}  ${scName}   ${contactFirstName}  ${contactLastName}  ${address}   ${city}  ${metro}   ${state}   ${latitude}   ${longitude}   ${radiusCoverage}   ${pincodesCoverage}   ${scType}   ${primaryPhoneNo}   ${altPhoneNo1}   ${altPhoneNo2}   ${commissionDuration}   ${commissionPct}   ${primaryEmail}   ${altEmail1}   ${altEmail2}   ${bonusPeriod}   ${id}  ${targetCount}   ${rate}  ${privateNote}
    ${bonusRates}=  Create Dictionary  id=${id}  targetCount=${targetCount}   rate=${rate} 
    ${bonusRates}=  Create List   ${bonusRates} 
    ${data}=  Create Dictionary  scId=${scId}  providerDiscFromJaldee=${providerDiscFromJaldee}  providerDiscDuration=${providerDiscDuration}  scName=${scName}   contactFirstName=${contactFirstName}  contactLastName=${contactLastName}  address=${address}   city=${city}  metro=${metro}   state=${state}   latitude=${latitude}   longitude=${longitude}   radiusCoverage=${radiusCoverage}   pincodesCoverage=${pincodesCoverage}   scType=${scType}   primaryPhoneNo=${primaryPhoneNo}   altPhoneNo1=${altPhoneNo1}   altPhoneNo2=${altPhoneNo2}   commissionDuration=${commissionDuration}   commissionPct=${commissionPct}   primaryEmail=${primaryEmail}   altEmail1=${altEmail1}   altEmail2=${altEmail2}   bonusPeriod=${bonusPeriod}   bonusRates=${bonusRates}     privateNote=${privateNote}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session  synw  /sc/${scId}/${stat}  data=${data}  expected_status=any
    Check Deprication  ${resp}  Update SC By Id And Status
    RETURN  ${resp}

Create SalesRep 

    [Arguments]  ${scId}  ${firstName}  ${lastName}   ${phoneNo}   ${email}   ${kyc}   ${kycDoneBy}   ${areasResponsible}   ${repCode}
    ${scId}=  Create Dictionary  id=${scId}
    ${data}=  Create Dictionary  scId=${scId}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phoneNo}   email=${email}  kyc=${kyc}  kycDoneBy=${kycDoneBy}     privateNote=${privateNote}  areasResponsible=${areasResponsible}  repCode=${repCode}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session  synw  /sc/rep  data=${data}  expected_status=any
    Check Deprication  ${resp}  Create SalesRep
    RETURN  ${resp}


Create Sales Channel Rep 
 
    [Arguments]  ${scId}  ${firstName}  ${lastName}   ${phoneNo}   ${email}   ${kyc}   ${kycDoneBy}   ${areasResponsible}   ${repCode}
    ${scId}=  Create Dictionary  id=${scId}
    ${data}=  Create Dictionary  scId=${scId}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phoneNo}   email=${email}  kyc=${kyc}  kycDoneBy=${kycDoneBy}   areasResponsible=${areasResponsible}  repCode=${repCode}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session  synw  /sc/rep  data=${data}  expected_status=any
    Check Deprication  ${resp}  Create Sales Channel Rep
    RETURN  ${resp} 


Delete Rep By Id
    [Arguments]   ${SpId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  DELETE On Session   synw   /sc/rep/${SpId}  expected_status=any
    Check Deprication  ${resp}  Delete Rep By Id
    RETURN  ${resp}

Get Rep List
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /sc/rep   params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  Get Rep List
    RETURN  ${resp} 

Get Sales Rep By Id 
    [Arguments]  ${spId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw  /sc/rep/${spId}  expected_status=any
    Check Deprication  ${resp}  Get Sales Rep By Id
    RETURN  ${resp}

Update REP By Id
    [Arguments]  ${repId}  ${scId}  ${firstName}  ${lastName}   ${phoneNo}   ${email}   ${kyc}   ${kycDoneBy}   ${areasResponsible}   ${repCode}
    ${scId}=  Create Dictionary  id=${scId}
    ${data}=  Create Dictionary  scId=${scId}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phoneNo}   email=${email}  kyc=${kyc}  kycDoneBy=${kycDoneBy}     privateNote=${privateNote}  areasResponsible=${areasResponsible}  repCode=${repCode}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session  synw  /sc/rep/${repId}  data=${data}  expected_status=any
    Check Deprication  ${resp}  Update REP By Id
    RETURN  ${resp}

Update REP By Id And Status
    [Arguments]  ${repId}   ${status}  ${scId}  ${firstName}  ${lastName}   ${phoneNo}   ${email}   ${kyc}   ${kycDoneBy}   ${areasResponsible}   ${repCode}
    ${scId}=  Create Dictionary  id=${scId}
    ${data}=  Create Dictionary  scId=${scId}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phoneNo}   email=${email}  kyc=${kyc}  kycDoneBy=${kycDoneBy}     privateNote=${privateNote}  areasResponsible=${areasResponsible}  repCode=${repCode}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session  synw  /sc/rep/${repId}/${status}  data=${data}  expected_status=any
    Check Deprication  ${resp}  Update REP By Id And Status
    RETURN  ${resp}  

Get reimburse

    Check And Create YNW SuperAdmin Session
    ${resp}=   GET On Session   synw  /jc/reports  expected_status=any
    Check Deprication  ${resp}  Get reimburse
    RETURN  ${resp}

Recreate reimburse report
    [Arguments]   ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw    /jc/reimburse/report/reGenerate/${id}  expected_status=any
    Check Deprication  ${resp}  Recreate reimburse report
    RETURN  ${resp}

Remove reimburse report
    [Arguments]  ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=    DELETE On Session   synw   /jc/reimburse/report/cancel/${id}  expected_status=any
    Check Deprication  ${resp}  Remove reimburse report
    RETURN  ${resp}


Remove Redis Cache 
    [Arguments]   ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=    DELETE On Session   synw  /account/${id}/license/cache  expected_status=any 
    Check Deprication  ${resp}  Remove Redis Cache
    RETURN  ${resp} 

Get Redis Cache
    [Arguments]   ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/${id}/license/cache  expected_status=any 
    Check Deprication  ${resp}  Get Redis Cache
    RETURN  ${resp} 


Get Invoices Verify
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/license/invoice   params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  Get Invoices Verify
    RETURN  ${resp}

Create Manual Statements
    [Arguments]   ${accId}   ${amount}  ${des}  ${fromdate}  ${todate}
    ${data}=  Create Dictionary  accId=${accId}    amount=${amount}   description=${des}    periodFrom=${fromdate}   periodTo=${todate}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session  synw  /account/license/invoice  data=${data}  expected_status=any
    Check Deprication  ${resp}  Create Manual Statements
    RETURN  ${resp}

Get Manual Statements
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/license/invoice   params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  Get Manual Statements
    RETURN  ${resp}

Cancel Manual Statements 
    [Arguments]   ${uuid}   ${reason}
    ${data}=  Create Dictionary  uuid=${uuid}    cancelReason=${reason}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session  synw  /account/license/invoice  data=${data}  expected_status=any
    Check Deprication  ${resp}  Cancel Manual Statements
    RETURN  ${resp}


Change Status of Questionnaire
    [Arguments]  ${accountid}  ${status}  ${questionnaireid}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw  url=/b2b/${accountid}/questionnaire/change/${status}/${questionnaireid}?account=${accountid}  expected_status=any
    Check Deprication  ${resp}  Change Status of Questionnaire
    RETURN  ${resp}
  

Get Questionnaire By Id
    [Arguments]   ${accountid}  ${qnid}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /b2b/${accountid}/questionnaire/${qnid}  expected_status=any 
    Check Deprication  ${resp}  Get Questionnaire By Id
    RETURN  ${resp}


Get Questionnaire List
    [Arguments]   ${accountid}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /b2b/${accountid}/questionnaire/  expected_status=any 
    Check Deprication  ${resp}  Get Questionnaire List
    RETURN  ${resp}


Provider Update SC  
    [Arguments]   ${accId}   ${salesChannelCode}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session  synw  /account/sc/${accId}/${salesChannelCode}  expected_status=any
    Check Deprication  ${resp}  Provider Update SC
    RETURN  ${resp}

Get Provider Under SC
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /account/sc   params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  Get Provider Under SC
    RETURN  ${resp}
 
Put Downgrade Accounts Revert
    [Arguments]  ${accLicId}  ${accountId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw   /account/license/${accLicId}/downgrade/revert/${accountId}  expected_status=any
    Check Deprication  ${resp}  Put Downgrade Accounts Revert
    RETURN  ${resp}

Get Active License Details
    [Arguments]  ${accountId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw   /account/license/${accountId}  expected_status=any
    Check Deprication  ${resp}  Get Active License Details
    RETURN  ${resp}

Put Downgrade Corporate 
    [Arguments]  ${corpId}  ${licPkgId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw   /corporate/${corpId}/license/${licPkgId}  expected_status=any
    Check Deprication  ${resp}  Put Downgrade Corporate
    RETURN  ${resp}

Get Active License Corporate Details
    [Arguments]  ${corpId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw   /corporate/${corpId}/license  expected_status=any
    Check Deprication  ${resp}  Get Active License Corporate Details
    RETURN  ${resp}

Put Downgrade Corporate Revert
    [Arguments]  ${corpLicId}   ${corpId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw   /corporate/license/${corpLicId}/downgrade/revert/${corpId}  expected_status=any
    Check Deprication  ${resp}  Put Downgrade Corporate Revert
    RETURN  ${resp}

Get Addon Corporate
    [Arguments]   ${corpId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw  /corporate/${corpId}/addon  expected_status=any
    Check Deprication  ${resp}  Get Addon Corporate
    RETURN  ${resp}

Delete Addon Corporate
    [Arguments]   ${corpId}  ${addonId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  DELETE On Session    synw   /corporate/${corpId}/addon/${addonId}  expected_status=any
    Check Deprication  ${resp}  Delete Addon Corporate
    RETURN  ${resp}

Get Corporate Config
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw    /account/license/conf  expected_status=any
    Check Deprication  ${resp}  Get Corporate Config
    RETURN  ${resp}

Subscription License
    [Arguments]  ${acid}  
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session   synw   /account/license/subscription/${acid}  expected_status=any
    Check Deprication  ${resp}  Subscription License
    RETURN  ${resp}

SC_invoice_Id
    [Arguments]  ${invoiceId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw    /sc/invoice/${invoiceId}  expected_status=any
    Check Deprication  ${resp}  SC_invoice_Id
    RETURN  ${resp}

SC_invoice
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw    /sc/invoice   params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  SC_invoice
    RETURN  ${resp}

SC_invoice_Count
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw    /sc/invoice/count  expected_status=any
    Check Deprication  ${resp}  SC_invoice_Count
    RETURN  ${resp}

SC_Commission_Report
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session   synw   /sc/commission  expected_status=any
    Check Deprication  ${resp}  SC_Commission_Report
    RETURN  ${resp}

SC_Get_Report_id
    [Arguments]  ${reportId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw    sc/commission/${reportId}  expected_status=any
    Check Deprication  ${resp}  SC_Get_Report_id
    RETURN  ${resp}

SC_Report_Filter
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw    sc/commission   params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  SC_Report_Filter
    RETURN  ${resp}  

SC_Report_Count
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw    sc/commission/count   params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  SC_Report_Count
    RETURN  ${resp} 

SC_Update_Status
    [Arguments]   ${comReportId}  ${status}  ${privateNote}
    Check And Create YNW SuperAdmin Session
    ${data}=  Create Dictionary  privateNote=${privateNote}
    ${data}=  json.dumps  ${data}
    ${resp}=  PUT On Session   synw    sc/commission/${comReportId}/${status}   data=${data}  expected_status=any
    Check Deprication  ${resp}  SC_Update_Status
    RETURN  ${resp} 

SC_Update_Id
    [Arguments]   ${comReportId}   ${reportStatus}  ${reviewedBy}  ${paidOn}  ${paidTotal}  ${paidBy}  ${disputeAmt}  ${paymentMode}  ${paymentNote}  ${paidConfirmationNo}  ${addressSent}  ${privateNote}  ${adjustments}
    Check And Create YNW SuperAdmin Session
    ${data}=  Create Dictionary  reportStatus=${reportStatus}   reviewedBy=${reviewedBy}  paidOn=${paidOn}  paidTotal=${paidTotal}  paidBy=${paidBy}  disputeAmt=${disputeAmt}  paymentMode=${paymentMode}  paymentNote=${paymentNote}  paidConfirmationNo=${paidConfirmationNo}  addressSent=${addressSent}  privateNote=${privateNote}  adjustments=${adjustments}
    ${data}=  json.dumps  ${data}
    ${resp}=  PUT On Session   synw    sc/commission/${comReportId}   data=${data}  expected_status=any
    Check Deprication  ${resp}  SC_Update_Id
    RETURN  ${resp} 

Update_RazorPay
    [Arguments]  ${accountId}   ${merchantId}  ${merchantKey}  ${webHookId}
    Check And Create YNW SuperAdmin Session
    ${data}=  Create Dictionary   accountId=${accountId}   merchantId=${merchantId}   merchantKey=${merchantKey}   webHookId=${webHookId}
    ${data}=  json.dumps  ${data}
    ${resp}=  PUT On Session   synw    /payment/razorPay   data=${data}  expected_status=any
    Check Deprication  ${resp}  Update_RazorPay
    RETURN  ${resp} 

Get_PaymentSettings
    [Arguments]  ${accountId}  
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw    account/payment/settings/${accountId}  expected_status=any
    Check Deprication  ${resp}  Get_PaymentSettings
    RETURN  ${resp} 



Updat_Virtual_Calling_Mode
    [Arguments]  ${accountId}  ${callingMode1}  ${ModeId1}   ${ModeStatus1}   ${instructions1}   ${callingMode2}  ${ModeId2}   ${ModeStatus2}   ${instructions2}
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${instructions1}
    ${VirtualcallingMode2}=  Create Dictionary   callingMode=${callingMode2}   value=${ModeId2}   status=${ModeStatus2}    instructions=${instructions2}
    ${vcm}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}
    ${data}=  Create Dictionary   virtualCallingModes=${vcm}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session  synw  /account/settings/${accountId}/virtualCallingModes   data=${data}  expected_status=any
    Check Deprication  ${resp}  Updat_Virtual_Calling_Mode
    RETURN  ${resp}

Get_Virtual Settings
    [Arguments]  ${accountId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session   synw   /account/settings/${accountId}/virtualCallingModes  expected_status=any
    Check Deprication  ${resp}  Get_Virtual Settings
    RETURN  ${resp}


Support_Market Login
    [Arguments]    ${ustype}   ${loginId}  ${passwrd}   
    ${pass2}=  support_secondpassword
    ${data}=    Create Dictionary    loginId=${loginId}  password=${passwrd}  secondPassword=${pass2}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Rest Session
    ${resp}=    POST On Session     syn    /${ustype}/login    data=${data}  expected_status=any
    Check Deprication  ${resp}  Support_Market Login
    RETURN  ${resp}

Create Users
    [Arguments]  ${firstName}  ${lastName}   ${email}   ${password}   ${mobileNo}  ${userStatus}  ${userType}
    ${data}=  Create Dictionary   firstName=${firstName}   lastName=${lastName}   email=${email}   password=${password}   mobileNo=${mobileNo}   userStatus=${userStatus}   userType=${userType}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session  synw  /user   data=${data}  expected_status=any
    Check Deprication  ${resp}  Create Users
    RETURN  ${resp} 

Create Users_Support
    [Arguments]  ${firstName}  ${lastName}   ${email}   ${password}   ${mobileNo}  ${userStatus}  ${userType}
    ${data}=  Create Dictionary   firstName=${firstName}   lastName=${lastName}   email=${email}   password=${password}   mobileNo=${mobileNo}   userStatus=${userStatus}   userType=${userType}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Rest Session
    ${resp}=  POST On Session  syn  /mgmt/user   data=${data}  expected_status=any
    Check Deprication  ${resp}  Create Users_Support
    RETURN  ${resp}

Update User Id
    [Arguments]  ${userId}  ${firstName}  ${lastName}   ${email}   ${password}   ${mobileNo}  ${userStatus}  ${userType}
    ${data}=  Create Dictionary   firstName=${firstName}   lastName=${lastName}   email=${email}   password=${password}   mobileNo=${mobileNo}   userStatus=${userStatus}   userType=${userType}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session  synw  /user/${userId}   data=${data}  expected_status=any
    Check Deprication  ${resp}  Update User Id
    RETURN  ${resp}

Update User Id_Support
    [Arguments]  ${userId}  ${firstName}  ${lastName}   ${email}   ${password}   ${mobileNo}  ${userStatus}  ${userType}
    ${data}=  Create Dictionary   firstName=${firstName}   lastName=${lastName}   email=${email}   password=${password}   mobileNo=${mobileNo}   userStatus=${userStatus}   userType=${userType}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Rest Session
    ${resp}=  PUT On Session  syn  /mgmt/user/${userId}   data=${data}  expected_status=any
    Check Deprication  ${resp}  Update User Id_Support
    RETURN  ${resp}

Update SAUser Status
    [Arguments]  ${userId}  ${status}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session  synw  /user/${status}/${userId}  expected_status=any
    Check Deprication  ${resp}  Update SAUser Status
    RETURN  ${resp}

Get SAUser ById
    [Arguments]  ${userId}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session  synw  /user/${userId}  expected_status=any
    Check Deprication  ${resp}  Get SAUser ById
    RETURN  ${resp}

Get User Types
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session  synw  /user/saUserType  expected_status=any
    Check Deprication  ${resp}  Get User Types
    RETURN  ${resp}

Get User Types_Support
     Check And Create YNW Rest Session
    ${resp}=  GET On Session  syn  /mgmt/user/saUserType  expected_status=any
    Check Deprication  ${resp}  Get User Types_Support
    RETURN  ${resp}

Get Transactions
	Check And Create YNW SuperAdmin Session
	${resp}=    GET On Session   synw    /analytics/transactions/count  expected_status=any
 	Check Deprication  ${resp}  Get Transactions
    RETURN  ${resp}
	
Get Account Configuration
    Check And Create YNW Rest Session
    #Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   syn  /mgmt/account/config  expected_status=any
    Check Deprication  ${resp}  Get Account Configuration
    RETURN  ${resp}   

Get Account Verify
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session   synw   /unverify/account   params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  Get Account Verify
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
    Check Deprication  ${resp}  Create Jaldee Cash Offer
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
    Check Deprication  ${resp}  Update Jaldee Cash Offer
    RETURN  ${resp}



Enable Jaldee Cash Offer
    [Arguments]  ${offerId}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session     synw   /jcash/offer/${offerId}/ENABLED  expected_status=any
    Check Deprication  ${resp}  Enable Jaldee Cash Offer
    RETURN  ${resp}


Disable Jaldee Cash Offer
    [Arguments]  ${offerId}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session     synw   /jcash/offer/${offerId}/DISABLED  expected_status=any
    Check Deprication  ${resp}  Disable Jaldee Cash Offer
    RETURN  ${resp}


Get Jaldee Cash Offer By Id
    [Arguments]  ${offerId}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session     synw   /jcash/offer/${offerId}  expected_status=any
    Check Deprication  ${resp}  Get Jaldee Cash Offer By Id
    RETURN  ${resp}


Get Jaldee Cash Offers By Criteria
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session     synw   /jcash/offer  params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  Get Jaldee Cash Offers By Criteria
    RETURN  ${resp}


Delete Jaldee Cash Offer 
    [Arguments]   ${offerId}  
    Check And Create YNW SuperAdmin Session
    ${resp}=  DELETE On Session    synw   /jcash/offer/${offerId}  expected_status=any
    Check Deprication  ${resp}  Delete Jaldee Cash Offer
    RETURN  ${resp}


Get Jaldee Cash Offer Count
    [Arguments]  &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session     synw   /jcash/offer/count  params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  Get Jaldee Cash Offer Count
    RETURN  ${resp}


Get Jaldee Cash Global Max Spendlimit
    Check And Create YNW Session
    ${resp}=    GET On Session    synw  /jcash/offer/config/spendLimit     expected_status=any
    Check Deprication  ${resp}  Get Jaldee Cash Global Max Spendlimit
    RETURN  ${resp}


Get Jaldee Cash Offer Stat Count for Today
    Check And Create YNW Session
    ${resp}=    GET On Session    synw  /jcash/offer/stat/date/TODAY        expected_status=any
    Check Deprication  ${resp}  Get Jaldee Cash Offer Stat Count for Today
    RETURN  ${resp}


Get Jaldee Cash Offer Stat Count for Lastweek
    Check And Create YNW Session
    ${resp}=    GET On Session    synw  /jcash/offer/stat/date/LAST_WEEK        expected_status=any
    Check Deprication  ${resp}  Get Jaldee Cash Offer Stat Count for Lastweek
    RETURN  ${resp}


Get Total Jaldee Cash Offer Stat Count 
    Check And Create YNW Session
    ${resp}=    GET On Session    synw  /jcash/offer/stat/date/TOTAL        expected_status=any
    Check Deprication  ${resp}  Get Total Jaldee Cash Offer Stat Count
    RETURN  ${resp}


Get Consumer Jaldee Cash Offer Stat Count 
    [Arguments]   ${statType}   ${dateCategory}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw  /jcash/offer/stat/consumer/statType/${statType}/category/${dateCategory}    expected_status=any
    Check Deprication  ${resp}  Get Consumer Jaldee Cash Offer Stat Count
    RETURN  ${resp}


Get SP Jaldee Cash Offer Stat Count 
    [Arguments]   ${statType}   ${dateCategory}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw  /jcash/offer/stat/sp/statType/${statType}/category/${dateCategory}    expected_status=any
    Check Deprication  ${resp}  Get SP Jaldee Cash Offer Stat Count
    RETURN  ${resp}


Get Jaldee Cash Offer Stat Count 
    [Arguments]   ${statType}   ${dateCategory}
    Check And Create YNW Session
    ${resp}=    GET On Session    synw  /jcash/offer/stat/offer/statType/${statType}/category/${dateCategory}    expected_status=any
    Check Deprication  ${resp}  Get Jaldee Cash Offer Stat Count
    RETURN  ${resp}



Issue Jaldee Cash 
    [Arguments]   ${jcash_name}  ${amt}  ${maxSpendLimit}  ${expiryDate}   @{vargs}
    ${consids}=   Create List  @{vargs}
    ${JCash_Offer}=    Create Dictionary    name=${jcash_name}  amt=${amt}   spendLimit=${maxSpendLimit}  expiryDate=${expiryDate}  consumerIds=${consids} 
    ${data}=    json.dumps    ${JCash_Offer}
    Log  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=    POST On Session   synw   /jcash    data=${data}  expected_status=any
    Check Deprication  ${resp}  Issue Jaldee Cash
    RETURN  ${resp}

Get Domain Level Analytics
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /analytics/domain  params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  Get Domain Level Analytics
    RETURN  ${resp}


Get Subdomain Level Analytics
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /analytics/subdomain  params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  Get Subdomain Level Analytics
    RETURN  ${resp}

Account Level Analytics
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /analytics/account  params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  Account Level Analytics
    RETURN  ${resp}

Get User Level Analytics
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /analytics/user  params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  Get User Level Analytics
    RETURN  ${resp}

Get Department Level Analytics
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /analytics/dept  params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  Get Department Level Analytics
    RETURN  ${resp}

Get Team Level Analytics
    [Arguments]   &{kwargs}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /analytics/team  params=${kwargs}  expected_status=any
    Check Deprication  ${resp}  Get Team Level Analytics
    RETURN  ${resp}

Superadmin Change Questionnaire Status    
    [Arguments]  ${qnrid}   ${status}   ${account_id}
    Check And Create YNW Session
    ${resp}=    PUT On Session  SYNW  /b2b/${account_id}/questionnaire/change/${Status}/${qnrid}  expected_status=any
    Check Deprication  ${resp}  Superadmin Change Questionnaire Status
    RETURN  ${resp}


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
    Check Deprication  ${resp}  Payment Profile For Prepayment
    RETURN  ${resp}



Create Bank Info
    [Arguments]   ${acc_id}   ${bankName}   ${bankAccountNumber}   ${ifscCode}   ${nameOnPanCard}   ${accountHolderName}  ${branchCity}
    ...   ${businessFilingStatus}   ${accountType}    ${panCardNumber}   ${payTmLinkedPhoneNumber}
    ${data}=   Create Dictionary    bankName=${bankName}  bankAccountNumber=${bankAccountNumber}  ifscCode=${ifscCode}  
    ...   nameOnPanCard=${nameOnPanCard}  accountHolderName=${accountHolderName}  branchCity=${branchCity}   businessFilingStatus=${businessFilingStatus}   
    ...   accountType=${accountType}  panCardNumber=${panCardNumber}  payTmLinkedPhoneNumber=${payTmLinkedPhoneNumber}    
    ${data}=   json.dumps   ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=   POST On Session  synw  /payment/settings/bankInfo/${acc_id}     data=${data}  expected_status=any
    Check Deprication  ${resp}  Create Bank Info
    RETURN  ${resp}


Get Bank Info By Id
    [Arguments]   ${bankid}  ${acc_id}
    Check And Create YNW SuperAdmin Session
    ${resp}=   GET On Session  synw  /payment/settings/bankInfo/${bankid}/${acc_id}    expected_status=any
    Check Deprication  ${resp}  Get Bank Info By Id
    RETURN  ${resp}


Get All Bank Info
    [Arguments]     ${acc_id}
    Check And Create YNW SuperAdmin Session
    ${resp}=   GET On Session  synw  /payment/settings/bankInfo/${acc_id}   expected_status=any
    Check Deprication  ${resp}  Get All Bank Info
    RETURN  ${resp}



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
    Check Deprication  ${resp}  Update Bank Info
    RETURN  ${resp}



Get Payment Bank Details
    [Arguments]    ${acc_id} 
    Check And Create YNW SuperAdmin Session
    ${resp}=   GET On Session  synw   url=/account/payment/payBankDetails?accountId=${acc_id}   expected_status=any
    Check Deprication  ${resp}  Get Payment Bank Details
    RETURN  ${resp}


Create Lucene Search
    [Arguments]       ${account}
    # Check And Create YNW Session
    Check And Create YNW SuperAdmin Session
    ${resp}=    POST On Session    synw    /searchdetails/${account}/providerconsumer/create	    expected_status=any
    Check Deprication  ${resp}  Create Lucene Search
    RETURN  ${resp}

Get Lucene Search
    [Arguments]   ${account}   &{param}
    # Check And Create YNW Session
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw    /searchdetails/${account}/providerconsumer/search    params=${param}     expected_status=any
    Check Deprication  ${resp}  Get Lucene Search
    RETURN  ${resp}

Delete Lucene Search  
    [Arguments]   ${account}   &{param}  
    # Check And Create YNW Session
    Check And Create YNW SuperAdmin Session
    ${resp}=    DELETE On Session    synw    /searchdetails/${account}/providerconsumer/delete	   params=${param}      expected_status=any
    Check Deprication  ${resp}  Delete Lucene Search
    RETURN  ${resp}


Enable Disable Invoice Generartion

    [Arguments]       ${acc_id}   ${bySystem}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session    synw    account/license/createBySystem/${acc_id}/${bySystem}	    expected_status=any
    Check Deprication  ${resp}  Enable Disable Invoice Generartion
    RETURN  ${resp}


Revert Invoice

    [Arguments]       ${acc_id}   ${invoice_id}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session    synw    account/license/invoice/revert/${invoice_id}/${acc_id}	    expected_status=any
    Check Deprication  ${resp}  Revert Invoice
    RETURN  ${resp}


Update Notes and Collected Details

    [Arguments]       ${lic_id}   ${payment_id}  ${note}
    ${data}=   Create Dictionary    uuid=${lic_id}  paymentId=${payment_id}  Note=${note}  
    ${data}=   json.dumps   ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session    synw    payment	 data=${data}   expected_status=any
    Check Deprication  ${resp}  Update Notes and Collected Details
    RETURN  ${resp}


# .....Jaldee Homeo....



Enable Disable Channel 

    [Arguments]       ${acc_id}   ${actiontype}   ${channel_ids}
    ${data}=   Create Dictionary    channelIds=${channel_ids} 
    ${data}=   json.dumps   ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session    synw    account/${acc_id}/${actiontype} 	 data=${data}   expected_status=any
    Check Deprication  ${resp}  Enable Disable Channel
    RETURN  ${resp}


Get Service Label Config

    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw    account/serviceConfig    expected_status=any
    Check Deprication  ${resp}  Get Service Label Config
    RETURN  ${resp}


# ......reimburse......

Update Reimbursement By InvoiceId
    [Arguments]  ${invoice_id}   ${note}
    ${data}=   Create Dictionary    notes=${note} 
    ${data}=   json.dumps   ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session   synw    /jc/reimburse/${invoice_id}    data=${data}    expected_status=any
    Check Deprication  ${resp}  Update Reimbursement By InvoiceId
    RETURN  ${resp}

    
Get Reminder Notification

    Check And Create YNW SuperAdmin Session
    ${resp}=    POST On Session    synw    /userAgent/reminderNotificationTask    expected_status=any  
    Check Deprication  ${resp}  Get Reminder Notification
    RETURN  ${resp} 

    
Get Appointment Reminder

    Check And Create YNW SuperAdmin Session
    ${resp}=    POST On Session    synw    /userAgent/apptNotificationTask    expected_status=any  
    Check Deprication  ${resp}  Get Appointment Reminder
    RETURN  ${resp}

Delete Not Used AddOn 
    [Arguments]   ${account}    ${accLicAddonId}   &{param}  
    # Check And Create YNW Session
    Check And Create YNW SuperAdmin Session
    ${resp}=    DELETE On Session    synw    account/license/${account}/licAddonId/${accLicAddonId}	   params=${param}      expected_status=any
    Check Deprication  ${resp}  Delete Not Used AddOn
    RETURN  ${resp}

Month Matrix Cache Task

    Check And Create YNW SuperAdmin Session
    ${resp}=   POST On Session  synw   userAgent/monthMatrixCacheTask   expected_status=any
    Check Deprication  ${resp}  Month Matrix Cache Task
    RETURN  ${resp}


# .............. Consent Form ..................

Enable Disable Consent Form 

    [Arguments]       ${accountId}   ${status}

    Check And Create YNW SuperAdmin Session
    ${resp}=    PUT On Session    synw    account/settings/${accountId}/consentform/${status}   expected_status=any
    Check Deprication  ${resp}  Enable Disable Consent Form
    RETURN  ${resp}

Create Consent Form Settings

    [Arguments]       ${accountId}   ${name}    ${description}    ${qnrid}

    ${data}=   Create Dictionary    name=${name}  description=${description}  qnrIds=${qnrid}
    ${data}=   json.dumps   ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=    POST On Session    synw    consentform/${accountId}/settings  data=${data}   expected_status=any
    Check Deprication  ${resp}  Create Consent Form Settings
    RETURN  ${resp}

Update Consent Form Settings

    [Arguments]       ${accountId}  ${cfid}   ${name}    ${description}    ${qnrid}

    ${data}=   Create Dictionary    id=${cfid}  name=${name}  description=${description}  qnrIds=${qnrid}
    ${data}=   json.dumps   ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=    PATCH On Session    synw    consentform/${accountId}/settings  data=${data}   expected_status=any
    Check Deprication  ${resp}  Update Consent Form Settings
    RETURN  ${resp}

Get Consent Form Settings

    [Arguments]       ${accountId}

    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw    consentform/${accountId}   expected_status=any
    Check Deprication  ${resp}  Get Consent Form Settings
    RETURN  ${resp}

Get Consent Form Settings By Id

    [Arguments]       ${accountId}  ${settingId}

    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw    consentform/${accountId}/settings/${settingId}   expected_status=any
    Check Deprication  ${resp}  Get Consent Form Settings By Id
    RETURN  ${resp}

Update Consent Form Settings Status

    [Arguments]       ${accountId}  ${settingId}  ${status}

    Check And Create YNW SuperAdmin Session
    ${resp}=    PATCH On Session    synw    consentform/${accountId}/settings/${settingId}/status/${status}  expected_status=any
    Check Deprication  ${resp}  Update Consent Form Settings Status
    RETURN  ${resp}


#------------------Data Migration-----------------

Get List
    [Arguments]     ${account}  
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session  synw  /spdataimport/account/${account}/list   expected_status=any
    Check Deprication  ${resp}  Get List
    RETURN  ${resp}


Get Data By Uid
    [Arguments]     ${account}  ${uid}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session  synw  /spdataimport/account/${account}/${uid}   expected_status=any
    Check Deprication  ${resp}  Get Data By Uid
    RETURN  ${resp}

Generate OTP for patient migration
    [Arguments]    ${account}  ${customerseries}  ${uid}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session   synw   /spdataimport/account/${account}/${customerseries}/Patients/migrate/${uid}/generateotp    expected_status=any
    Check Deprication  ${resp}  Generate OTP for patient migration
    RETURN  ${resp}

Verify OTP For Patients Migration
    [Arguments]     ${propertyphone_no}  ${purpose}     ${account}  ${customerIdFormat}  ${uid}  

    Check And Create YNW SuperAdmin Session
    ${otp}=   verify accnt  ${propertyphone_no}  ${purpose}
    ${resp}=  POST On Session   synw   /spdataimport/account/${account}/${customerIdFormat}/Patients/migrate/${uid}/verifyotp/${otp}    expected_status=any
    Check Deprication  ${resp}  Verify OTP For Patients Migration
    RETURN  ${resp}

Generate OTP For Appointment Migration
    [Arguments]    ${account}    ${uid}   ${tz}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session   synw    /spdataimport/account/${account}/Appointments/migrate/${uid}/generateotp    expected_status=any    data="${tz}"
    Check Deprication  ${resp}  Generate OTP For Appointment Migration
    RETURN  ${resp}


Verify OTP For Appointment Migration
    [Arguments]     ${propertyphone_no}  ${purpose}     ${account}   ${uid}  ${tz}

    Check And Create YNW SuperAdmin Session
    ${otp}=   verify accnt  ${propertyphone_no}  ${purpose}
    ${resp}=  POST On Session   synw   /spdataimport/account/${account}/Appointments/migrate/${uid}/verifyotp/${otp}    expected_status=any   data="${tz}"
    Check Deprication  ${resp}  Verify OTP For Appointment Migration
    RETURN  ${resp}

Generate OTP For Notes Migration
    [Arguments]    ${account}    ${uid}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session   synw   /spdataimport/account/${account}/Notes/migrate/${uid}/generateotp    expected_status=any
    Check Deprication  ${resp}  Generate OTP For Notes Migration
    RETURN  ${resp}

Verify OTP For Notes Migration
    [Arguments]     ${propertyphone_no}  ${purpose}     ${account}    ${uid}  

    Check And Create YNW SuperAdmin Session
    ${otp}=   verify accnt  ${propertyphone_no}  ${purpose}
    ${resp}=  POST On Session   synw   /spdataimport/account/${account}/Notes/migrate/${uid}/verifyotp/${otp}    expected_status=any
    Check Deprication  ${resp}  Verify OTP For Notes Migration
    RETURN  ${resp}

Generate OTP For Revert
    [Arguments]    ${account}   ${uid}
    Check And Create YNW SuperAdmin Session
    ${resp}=  DELETE On Session   synw   /spdataimport/account/${account}/revert/${uid}/generateotp    expected_status=any
    Check Deprication  ${resp}  Generate OTP For Revert
    RETURN  ${resp}

Verify OTP For Revert Migration
    [Arguments]     ${propertyphone_no}  ${purpose}  ${account}   ${uid}  

    Check And Create YNW SuperAdmin Session
    ${otp}=   verify accnt  ${propertyphone_no}  ${purpose}
    ${resp}=  DELETE On Session   synw   /spdataimport/account/${account}/revert/${uid}/verifyotp/${otp}    expected_status=any
    Check Deprication  ${resp}  Verify OTP For Revert Migration
    RETURN  ${resp}


# Inventory
Create Store Type

    [Arguments]      ${name}    ${storeNature}    

    ${data}=   Create Dictionary    name=${name}  storeNature=${storeNature}  
    ${data}=   json.dumps   ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=    POST On Session    synw    /account/store/type   data=${data}   expected_status=any
    Check Deprication  ${resp}  Create Store Type
    RETURN  ${resp}


Get Store Type By EncId
    [Arguments]  ${storeTypeEncId}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /account/store/type/id/${storeTypeEncId}  expected_status=any
    Check Deprication  ${resp}  Get Store Type By EncId
    RETURN  ${resp}

Update Store Type

    [Arguments]     ${uid}   ${name}   ${storeNature}
    ${data}=  Create Dictionary  name=${name}   storeNature=${storeNature}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session  synw  /account/store/type/${uid}  data=${data}  expected_status=any
    Check Deprication  ${resp}  Update Store Type
    RETURN  ${resp}  

Get Store Type Filter
    [Arguments]   &{param}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /account/store/type   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get Store Type Filter
    RETURN  ${resp}

Get Store Type Filter Count

    [Arguments]   &{param}

    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session  synw  /account/store/type/count   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get Store Type Filter Count
    RETURN  ${resp}  

#........ ITEM CATEGORY .................

Create Item Category SA

    [Arguments]  ${account}  ${categoryName}  
    ${data}=  Create Dictionary  categoryName=${categoryName}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session  synw  /item/${account}/category  data=${data}  expected_status=any
    Check Deprication  ${resp}  Create Item Category SA
    RETURN  ${resp}  

Get Item Category SA

    [Arguments]  ${account}  ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /item/${account}/category/${id}  expected_status=any
    Check Deprication  ${resp}  Get Item Category SA
    RETURN  ${resp}

Update Item Category SA

    [Arguments]   ${account}  ${categoryName}   ${categoryCode}
    ${data}=  Create Dictionary  categoryName=${categoryName}   categoryCode=${categoryCode}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PATCH On Session  synw  /item/${account}/category  data=${data}  expected_status=any
    Check Deprication  ${resp}  Update Item Category SA
    RETURN  ${resp}  

Get Item Category By Filter SA  

    [Arguments]   ${account}  &{param}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /item/${account}/category   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get Item Category By Filter SA
    RETURN  ${resp}

Update Item Category Status SA

    [Arguments]   ${account}  ${categoryCode}   ${status}
    
    Check And Create YNW SuperAdmin Session
    ${resp}=  PATCH On Session  synw  /item/${account}/category/${categoryCode}/status/${status}   expected_status=any
    Check Deprication  ${resp}  Update Item Category Status SA
    RETURN  ${resp}  

Get Item Category Count By Filter SA

    [Arguments]   ${account}  &{param}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /item/${account}/category/count   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get Item Category Count By Filter SA
    RETURN  ${resp}

# ......... ITEM TYPE .............

Create Item Type SA

    [Arguments]  ${account}  ${typeName}  
    ${data}=  Create Dictionary  typeName=${typeName}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session  synw  /item/${account}/type  data=${data}  expected_status=any
    Check Deprication  ${resp}  Create Item Type SA
    RETURN  ${resp}  

Get Item Type SA

    [Arguments]  ${account}  ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /item/${account}/type/${id}  expected_status=any
    Check Deprication  ${resp}  Get Item Type SA
    RETURN  ${resp}

Update Item Type SA

    [Arguments]   ${account}  ${typeName}   ${typeCode}
    ${data}=  Create Dictionary  typeName=${typeName}   typeCode=${typeCode}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PATCH On Session  synw  /item/${account}/type  data=${data}  expected_status=any
    Check Deprication  ${resp}  Update Item Type SA
    RETURN  ${resp}  

Get Item Type By Filter SA

    [Arguments]   ${account}  &{param}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /item/${account}/type   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get Item Type By Filter SA
    RETURN  ${resp}

Update Item Type Status SA

    [Arguments]   ${account}  ${typeCode}   ${status}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PATCH On Session  synw  /item/${account}/type/${typeCode}/status/${status}   expected_status=any
    Check Deprication  ${resp}  Update Item Type Status SA
    RETURN  ${resp}  

Get Item Type Count By Filter SA

    [Arguments]   ${account}  &{param}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /item/${account}/type/count   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get Item Type Count By Filter SA
    RETURN  ${resp}


# ......... ITEM MANUFACTURE .............

Create Item manufacturer SA

    [Arguments]  ${account}  ${manufactureName}  
    ${data}=  Create Dictionary  manufacturerName=${manufactureName}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session  synw  /item/${account}/manufacturer  data=${data}  expected_status=any
    Check Deprication  ${resp}  Create Item manufacturer SA
    RETURN  ${resp}  

Get Item manufacturer SA

    [Arguments]  ${account}  ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /item/${account}/manufacturer/${id}  expected_status=any
    Check Deprication  ${resp}  Get Item manufacturer SA
    RETURN  ${resp}

Update Item manufacturer SA

    [Arguments]   ${account}  ${manufacturerName}   ${manufacturerCode}
    ${data}=  Create Dictionary  manufacturerName=${manufacturerName}   manufacturerCode=${manufacturerCode}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PATCH On Session  synw  /item/${account}/manufacturer  data=${data}  expected_status=any
    Check Deprication  ${resp}  Update Item manufacturer SA
    RETURN  ${resp}  

Get Item manufacturer By Filter SA

    [Arguments]   ${account}  &{param}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /item/${account}/manufacturer   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get Item manufacturer By Filter SA
    RETURN  ${resp}

Update Item manufacturer Status SA

    [Arguments]   ${account}  ${manufacturerCode}   ${status}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PATCH On Session  synw  /item/${account}/manufacturer/${manufacturerCode}/status/${status}   expected_status=any
    Check Deprication  ${resp}  Update Item manufacturer Status SA
    RETURN  ${resp}  

Get Item manufacturer Count By Filter SA

    [Arguments]   ${account}  &{param}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /item/${account}/manufacturer/count   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get Item manufacturer Count By Filter SA
    RETURN  ${resp}


# ......... ITEM TAX .............

Create Item Tax SA

    [Arguments]  ${account}  ${taxName}  ${taxTypeEnum}  ${taxPercentage}   &{kwargs}
    ${data}=  Create Dictionary  taxName=${taxName}  taxTypeEnum=${taxTypeEnum}  taxPercentage=${taxPercentage}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session  synw  /item/${account}/tax  data=${data}  expected_status=any
    Check Deprication  ${resp}  Create Item Tax SA
    RETURN  ${resp}  

Get Item Tax SA

    [Arguments]  ${account}  ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /item/${account}/tax/${id}  expected_status=any
    Check Deprication  ${resp}  Get Item Tax SA
    RETURN  ${resp}

Update Item Tax SA

    [Arguments]   ${account}  ${taxName}  ${taxCode}  ${taxTypeEnum}  ${taxPercentage}   &{kwargs}
    ${data}=  Create Dictionary  taxName=${taxName}  taxCode=${taxCode}  taxTypeEnum=${taxTypeEnum}  taxPercentage=${taxPercentage}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PATCH On Session  synw  /item/${account}/tax  data=${data}  expected_status=any
    Check Deprication  ${resp}  Update Item Tax SA
    RETURN  ${resp}  

Get Item Tax By Filter SA

    [Arguments]   ${account}  &{param}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /item/${account}/tax   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get Item Tax By Filter SA
    RETURN  ${resp}

Update Item Tax Status SA

    [Arguments]   ${account}  ${taxCode}   ${status}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PATCH On Session  synw  /item/${account}/tax/${taxCode}/status/${status}   expected_status=any
    Check Deprication  ${resp}  Update Item Tax Status SA
    RETURN  ${resp}  

Get Item Tax Count By Filter SA

    [Arguments]   ${account}  &{param}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /item/${account}/tax/count   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get Item Tax Count By Filter SA
    RETURN  ${resp}


# ......... ITEM UNIT .............

Create Item Unit SA

    [Arguments]  ${account}  ${unitName}    ${convertionQty}  
    ${data}=  Create Dictionary  unitName=${unitName}   convertionQty=${convertionQty}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session  synw  /item/${account}/unit  data=${data}  expected_status=any
    Check Deprication  ${resp}  Create Item Unit SA
    RETURN  ${resp}  

Get Item Unit SA

    [Arguments]  ${account}  ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /item/${account}/unit/${id}  expected_status=any
    Check Deprication  ${resp}  Get Item Unit SA
    RETURN  ${resp}

Update Item Unit SA

    [Arguments]   ${account}  ${unitName}    ${convertionQty}  ${unitCode}
    ${data}=  Create Dictionary  unitName=${unitName}   convertionQty=${convertionQty}  unitCode=${unitCode}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PATCH On Session  synw  /item/${account}/unit  data=${data}  expected_status=any
    Check Deprication  ${resp}  Update Item Unit SA
    RETURN  ${resp}  

Get Item Unit By Filter SA

    [Arguments]   ${account}  &{param}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /item/${account}/unit   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get Item Unit By Filter SA
    RETURN  ${resp}

Update Item Unit Status SA

    [Arguments]   ${account}  ${unitCode}   ${status}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PATCH On Session  synw  /item/${account}/unit/${unitCode}/status/${status}   expected_status=any
    Check Deprication  ${resp}  Update Item Unit Status SA
    RETURN  ${resp}  

Get Item Unit Count By Filter SA

    [Arguments]   ${account}  &{param}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /item/${account}/unit/count   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get Item Unit Count By Filter SA
    RETURN  ${resp}


# ......... ITEM COMPOSITION .............

Create Item Composition SA

    [Arguments]  ${account}  ${compositionName} 
    ${data}=  Create Dictionary  compositionName=${compositionName} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session  synw  /item/${account}/composition  data=${data}  expected_status=any
    Check Deprication  ${resp}  Create Item Composition SA
    RETURN  ${resp}  

Get Item Composition SA

    [Arguments]  ${account}  ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /item/${account}/composition/${id}  expected_status=any
    Check Deprication  ${resp}  Get Item Composition SA
    RETURN  ${resp}

Update Item Composition SA

    [Arguments]   ${account}  ${compositionName}  ${compositionCode}
    ${data}=  Create Dictionary  compositionName=${compositionName}   compositionCode=${compositionCode}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PATCH On Session  synw  /item/${account}/composition  data=${data}  expected_status=any
    Check Deprication  ${resp}  Update Item Composition SA
    RETURN  ${resp}  

Get Item Composition By Filter SA

    [Arguments]   ${account}  &{param}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /item/${account}/composition   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get Item Composition By Filter SA
    RETURN  ${resp}

Update Item Composition Status SA

    [Arguments]   ${account}  ${compositionCode}   ${status}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PATCH On Session  synw  /item/${account}/composition/${compositionCode}/status/${status}   expected_status=any
    Check Deprication  ${resp}  Update Item Composition Status SA
    RETURN  ${resp}  

Get Item Composition Count By Filter SA

    [Arguments]   ${account}  &{param}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /item/${account}/composition/count   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get Item Composition Count By Filter SA
    RETURN  ${resp}

# ......... ITEM HSN .............

Create Item Hsn SA

    [Arguments]  ${account}  ${hsnCode} 
    ${data}=  Create Dictionary  hsnCode=${hsnCode} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session  synw  /item/${account}/hsn  data=${data}  expected_status=any
    Check Deprication  ${resp}  Create Item Hsn SA
    RETURN  ${resp}  

Get Item Hsn SA

    [Arguments]  ${account}  ${id}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /item/${account}/hsn/${id}  expected_status=any
    Check Deprication  ${resp}  Get Item Hsn SA
    RETURN  ${resp}

Update Item Hsn SA

    [Arguments]   ${account}  ${id}  ${hsnCode}
    ${data}=  Create Dictionary  id=${id}   hsnCode=${hsnCode}
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PATCH On Session  synw  /item/${account}/hsn  data=${data}  expected_status=any
    Check Deprication  ${resp}  Update Item Hsn SA
    RETURN  ${resp}  

Get Item Hsn By Filter SA

    [Arguments]   ${account}  &{param}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /item/${account}/hsn   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get Item Hsn By Filter SA
    RETURN  ${resp}

Update Item Hsn Status SA

    [Arguments]   ${account}  ${id}   ${status}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PATCH On Session  synw  /item/${account}/hsn/${id}/status/${status}   expected_status=any
    Check Deprication  ${resp}  Update Item Hsn Status SA
    RETURN  ${resp}  

Get Item Hsn Count By Filter SA

    [Arguments]   ${account}  &{param}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /item/${account}/hsn/count   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get Item Hsn Count By Filter SA
    RETURN  ${resp}


# ......  ITEM JRX ..........

Create Item Jrx 

    # description, sku, hsn are not mandatory
    [Arguments]     ${itemName}  &{kwargs}

    ${data}=  Create Dictionary  itemName=${itemName}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session  synw  /item/jrx  data=${data}  expected_status=any
    Check Deprication  ${resp}  Create Item Jrx
    RETURN  ${resp}  

Get Item Jrx by id

    [Arguments]     ${id}

    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session  synw  /item/jrx/${id}  expected_status=any
    Check Deprication  ${resp}  Get Item Jrx by id
    RETURN  ${resp}

Update Item Jrx 

    # description, sku, hsn are not mandatory
    [Arguments]     ${itemCode}  &{kwargs}

    ${data}=  Create Dictionary  itemCode=${itemCode}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PATCH On Session  synw  /item/jrx  data=${data}  expected_status=any
    Check Deprication  ${resp}  Update Item Jrx
    RETURN  ${resp} 

Get Item Jrx Filter

    [Arguments]   &{param}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /item/jrx   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get Item Jrx Filter
    RETURN  ${resp}

Get Item Jrx Filter Count

    [Arguments]   &{param}
    Check And Create YNW SuperAdmin Session
    ${resp}=    GET On Session    synw   /item/jrx/count   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get Item Jrx Filter Count
    RETURN  ${resp}


#---------------------------RX Push-----------------------------------------    

SA Create Frequency

    [Arguments]  ${frequency}  ${dosage}  &{kwargs}

    ${data}=   Create Dictionary    frequency=${frequency}  dosage=${dosage}
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  POST On Session  synw  /provider/medicalrecord/frequency   data=${data}  expected_status=any
    Check Deprication  ${resp}  SA Create Frequency
    RETURN  ${resp} 

SA Get Frequency

    [Arguments]  ${id}

    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session  synw  /provider/medicalrecord/frequency/${id}     expected_status=any
    Check Deprication  ${resp}  SA Get Frequency
    RETURN  ${resp}

SA Update Frequency

    [Arguments]  ${id}  ${frequency}  ${dosage}  &{kwargs}

    ${data}=   Create Dictionary    id=${id}  frequency=${frequency}  dosage=${dosage}
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW SuperAdmin Session
    ${resp}=  PUT On Session  synw  /provider/medicalrecord/frequency  data=${data}  expected_status=any
    Check Deprication  ${resp}  SA Update Frequency
    RETURN  ${resp} 

SA Delete Frequency

    [Arguments]   ${id}

    Check And Create YNW SuperAdmin Session
    ${resp}=  DELETE On Session  synw  /provider/medicalrecord/frequency/${id}     expected_status=any
    Check Deprication  ${resp}  SA Delete Frequency
    RETURN  ${resp}

SA Get Frequency By Account

    [Arguments]     ${account}

    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session  synw  /provider/medicalrecord/frequency/account/${account}    expected_status=any
    Check Deprication  ${resp}  SA Get Frequency By Account
    RETURN  ${resp}