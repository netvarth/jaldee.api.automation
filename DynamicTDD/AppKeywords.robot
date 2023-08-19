***Settings***
Library             RequestsLibrary
Variables           messagesapi.py
Variables           messagesbase.py
Variables           messageslicence.py
Variables           superadminmessagesapi.py 
Library             Collections
Library             String
Library             OperatingSystem
Library             json

*** Variables ***

&{app_headers}           Content-Type=application/json  User-Agent=android  BOOKING_REQ_FROM=CONSUMER_APP   sec-ch-ua-platform="Android"
&{sp_app_headers}        Content-Type=application/json  User-Agent=android  BOOKING_REQ_FROM=SP_APP   sec-ch-ua-platform="Android"


*** Keywords ***


# ............web link keywords................


App Check And Create YNW Session
    [Arguments]    ${headers}
    ${res}=   Session Exists    ynw
    # Run Keyword Unless  ${res}   Create Session    ynw    ${BASE_URL}  headers=${headers}
    IF  not ${res}
        Create Session    ynw    ${BASE_URL}  headers=${headers}
    END

App Login
    [Arguments]   ${headers}  ${usname}  ${passwrd}  ${countryCode}=+91
    ${login}=    Create Dictionary    loginId=${usname}  password=${passwrd}  countryCode=${countryCode}
    ${log}=    json.dumps    ${login}
    App Check And Create YNW Session   ${headers}
    [Return]  ${log}

App Consumer SignUp
    [Arguments]  ${headers}  ${firstname}  ${lastname}  ${address}  ${primaryNo}  ${alternativeNo}  ${dob}  ${gender}  ${email}   ${countryCode}=+91
    ${apple}=  Consumer Creation  ${firstname}  ${lastname}  ${address}  ${primaryNo}  ${alternativeNo}  ${dob}  ${gender}  ${email}   countryCode=${countryCode}    
    App Check And Create YNW Session   ${headers}
    ${resp}=    POST On Session    ynw    /consumer   data=${apple}  expected_status=any   headers=${headers}
    [Return]  ${resp}

App Consumer Activation
    [Arguments]  ${headers}  ${email}  ${purpose}
    App Check And Create YNW Session   ${headers}
    ${key}=   verify accnt  ${email}  ${purpose}
    ${resp_val}=  POST On Session   ynw  /consumer/${key}/verify   expected_status=any   headers=${headers}
    [Return]  ${resp_val}

App Consumer Login
    [Arguments]    ${headers}  ${usname}  ${passwrd}  ${countryCode}=+91
    ${log}=  App Login  ${headers}  ${usname}  ${passwrd}   countryCode=${countryCode}
    ${resp}=    POST On Session    ynw    /consumer/login    data=${log}  expected_status=any   headers=${headers}
    [Return]  ${resp}

App Consumer Logout
    [Arguments]  ${headers}
    App Check And Create YNW Session   ${headers}
    ${resp}=    DELETE On Session    ynw    /consumer/login  expected_status=any  headers=${headers}
    [Return]  ${resp}

App ProviderLogin
    [Arguments]    ${headers}  ${usname}  ${passwrd}   ${countryCode}=91
    ${log}=  App Login  ${headers}  ${usname}  ${passwrd}   countryCode=${countryCode}
    ${resp}=    POST On Session    ynw    /provider/login    data=${log}  expected_status=any  headers=${headers}
    [Return]  ${resp}

App ProviderLogout
    [Arguments]  ${headers}
    App Check And Create YNW Session    ${headers}
    ${resp}=  DELETE On Session  ynw  /provider/login  expected_status=any   headers=${headers}
    [Return]  ${resp}       

App Add To Waitlist Consumers
    [Arguments]  ${headers}  ${accId}  ${queueId}  ${date}  ${serviceId}  ${consumerNote}  ${revealPhone}  @{vargs}   
    ${param}=  Create Dictionary  account=${accId}
    ${queueId}=  Create Dictionary  id=${queueId}
    ${serviceId}=  Create Dictionary  id=${service_id}  
    
    ${len}=  Get Length  ${vargs}
    ${consumer}=  Create Dictionary  id=${vargs[0]}
    ${consumerlist}=  Create List  ${consumer}
    FOR    ${index}    IN RANGE  1  ${len}
        ${consumer}=  Create Dictionary  id=${vargs[${index}]}
        Append To List  ${consumerlist}  ${consumer}
    END
    ${data}=  Create Dictionary  queue=${queueId}  date=${date}  service=${serviceId}  consumerNote=${consumerNote}  waitlistingFor=${consumerlist}  revealPhone=${revealPhone} 
    ${data}=  json.dumps  ${data}
    App Check And Create YNW Session  ${headers}
    ${resp}=    POST On Session  ynw  /consumer/waitlist   data=${data}  params=${param}   expected_status=any   headers=${headers}
    [Return]  ${resp}

App Get consumer Waitlist By Id
    [Arguments]  ${headers}  ${uuid}  ${accId}
    ${param}=  Create Dictionary  account=${accId}
    App Check And Create YNW Session   ${headers}
    ${resp}=  GET On Session  ynw  /consumer/waitlist/${uuid}  params=${param}   expected_status=any   headers=${headers}
    [Return]  ${resp}

App GetCustomer
    [Arguments]  ${headers}  &{param}
    App Check And Create YNW Session  ${headers}
    ${resp}=   GET On Session  ynw  /provider/customers  params=${param}  expected_status=any   headers=${headers}
    [Return]  ${resp}

App Add To Waitlist
    [Arguments]   ${headers}  ${consid}  ${service_id}  ${qid}  ${date}  ${consumerNote}  ${ignorePrePayment}  @{fids}
    ${cid}=  Create Dictionary  id=${consid}
    ${sid}=  Create Dictionary  id=${service_id}
    ${qid}=  Create Dictionary  id=${qid}
    ${fid}=  Create Dictionary  id=${fids[0]}
    ${len}=  Get Length  ${fids}
    ${fid}=  Create List  ${fid}
    FOR    ${index}    IN RANGE  1  ${len}
        ${ap}=  Create Dictionary  id=${fids[${index}]}
        Append To List  ${fid} 	${ap}
    END
    ${data}=    Create Dictionary    consumer=${cid}  service=${sid}  queue=${qid}  date=${date}  consumerNote=${consumerNote}  waitlistingFor=${fid}  ignorePrePayment=${ignorePrePayment}
    ${data}=  json.dumps  ${data}
    App Check And Create YNW Session  ${headers}
    ${resp}=  POST On Session  ynw  provider/waitlist  data=${data}  expected_status=any  headers=${headers}
    [Return]  ${resp}

App Add To Waitlist with mode
    [Arguments]   ${headers}  ${waitlistMode}  ${consid}  ${service_id}  ${qid}  ${date}  ${consumerNote}  ${ignorePrePayment}   @{fids}
    ${cid}=  Create Dictionary  id=${consid}
    ${sid}=  Create Dictionary  id=${service_id}
    ${qid}=  Create Dictionary  id=${qid}
    ${fid}=  Create Dictionary  id=${fids[0]}
    ${len}=  Get Length  ${fids}
    ${fid}=  Create List  ${fid}
    FOR    ${index}    IN RANGE  1  ${len}
        ${ap}=  Create Dictionary  id=${fids[${index}]}
        Append To List  ${fid} 	${ap}
    END
    ${data}=    Create Dictionary    consumer=${cid}  service=${sid}  queue=${qid}  date=${date}  consumerNote=${consumerNote}  waitlistingFor=${fid}  ignorePrePayment=${ignorePrePayment}  waitlistMode=${waitlistMode}
    ${data}=  json.dumps  ${data}
    App Check And Create YNW Session  ${headers}
    ${resp}=  POST On Session  ynw  provider/waitlist  data=${data}  expected_status=any  headers=${headers}
    [Return]  ${resp}

App Add To Waitlist Consumers with mode
    [Arguments]  ${headers}  ${waitlistMode}  ${accId}  ${queueId}  ${date}  ${serviceId}  ${consumerNote}  ${revealPhone}  @{vargs}   
    ${param}=  Create Dictionary  account=${accId}
    ${queueId}=  Create Dictionary  id=${queueId}
    ${serviceId}=  Create Dictionary  id=${service_id}  
    
    ${len}=  Get Length  ${vargs}
    ${consumer}=  Create Dictionary  id=${vargs[0]}
    ${consumerlist}=  Create List  ${consumer}
    FOR    ${index}    IN RANGE  1  ${len}
        ${consumer}=  Create Dictionary  id=${vargs[${index}]}
        Append To List  ${consumerlist}  ${consumer}
    END
    ${data}=  Create Dictionary  waitlistMode=${waitlistMode}  queue=${queueId}  date=${date}  service=${serviceId}  consumerNote=${consumerNote}  waitlistingFor=${consumerlist}  revealPhone=${revealPhone} 
    ${data}=  json.dumps  ${data}
    App Check And Create YNW Session  ${headers}
    ${resp}=    POST On Session  ynw  /consumer/waitlist   data=${data}  params=${param}   expected_status=any   headers=${headers}
    [Return]  ${resp}

App Get Locations
    [Arguments]  ${headers}
    App Check And Create YNW Session   ${headers}
    ${resp}=    GET On Session    ynw   /provider/locations  expected_status=any   headers=${headers}
    [Return]  ${resp}

App Get Waiting Time Of Providers
    [Arguments]  ${headers}  @{ids} 
    App Check And Create YNW Session  ${headers}
    ${len}=  Get Length  ${ids}
    Set Test Variable  ${pid}  ${ids[0]}
    FOR    ${index}    IN RANGE  1  ${len}
    	${pid}=  Catenate 	SEPARATOR=,	${pid} 	${ids[${index}]}
    END
    ${resp}=  GET On Session  ynw  /provider/waitlist/queues/waitingTime/${pid}  expected_status=any  headers=${headers}
    [Return]  ${resp}

App Take Appointment For Provider 
    [Arguments]    ${headers}  ${accid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${appmtFor}
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}    
    ${data}=    Create Dictionary    appointmentMode=ONLINE_APPOINTMENT   account=${accId}   service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}
    ${data}=  json.dumps  ${data}
    App Check And Create YNW Session  ${headers}
    ${resp}=  POST On Session  ynw   url=/consumer/appointment?account=${accId}  data=${data}  expected_status=any  headers=${headers}
    [Return]  ${resp}

App Get consumer Appointment By Id
    [Arguments]   ${headers}  ${accId}  ${appmntId}
    App Check And Create YNW Session  ${headers}
    ${resp}=  GET On Session  ynw  url=/consumer/appointment/${appmntId}?account=${accId}   expected_status=any  headers=${headers}
    [Return]  ${resp}


App Take Appointment For Consumer 
    [Arguments]   ${headers}  ${consid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${appmtFor}
    ${cid}=  Create Dictionary  id=${consid}
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}
    ${data}=    Create Dictionary   consumer=${cid}  service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}
    ${data}=  json.dumps  ${data}
    App Check And Create YNW Session  ${headers}
    ${resp}=  POST On Session  ynw  /provider/appointment  data=${data}  expected_status=any  headers=${headers}
    [Return]  ${resp}


App Get Appmt Service By LocationId
    [Arguments]   ${headers}   ${locationId}   
    App Check And Create YNW Session  ${headers}
    ${resp}=    GET On Session    ynw  /consumer/appointment/service/${locationId}   expected_status=any 
    [Return]  ${resp}


Scale Account Activation
    [Arguments]  ${key}
    Check And Create YNW Session
    ${resp_val}=  POST On Session   ynw  /provider/${key}/verify  expected_status=any
    [Return]  ${resp_val}

Scale Account Set Credential
    [Arguments]   ${key}  ${purpose}  ${countryCode}=91
    ${auth}=     Create Dictionary   password=${password}  countryCode=${countryCode}
    ${apple}=    json.dumps    ${auth}
    ${resp}=    PUT On Session    ynw    /provider/${key}/activate    data=${apple}    expected_status=any
    [Return]  ${resp}

App Get Appointment Slots By Schedule and Date
    [Arguments]  ${headers}  ${scheduleId}  ${date}  ${acct_id}
    ${params}=  Create Dictionary  account=${acct_id}
    App Check And Create YNW Session  ${headers}
    ${resp}=  GET On Session  ynw  /consumer/appointment/schedule/${scheduleId}/${date}    params=${params}   expected_status=any
    [Return]  ${resp}

App Create Order For HomeDelivery
    [Arguments]   ${headers}  ${Cookie}   ${accId}   ${orderFor}    ${CatalogId}   ${homeDelivery}    ${homeDeliveryAddress}  ${sTime1}    ${eTime1}   ${orderDate}    ${phoneNumber}    ${email}  ${countryCode}  ${coupons}  @{vargs}        
    ${catalog}=  Create Dictionary  id=${CatalogId}
    ${orderFor}=  Create Dictionary  id=${orderFor}
    ${timeSlot}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${len}=  Get Length  ${vargs}
    ${items}=  Create Dictionary  id=${vargs[0]}  quantity=${vargs[1]}
    ${orderitem}=  Create List  ${items}
    FOR    ${index}   IN RANGE   2  ${len}  2
        ${index2}=  Evaluate  ${index}+1
        ${items}=  Create Dictionary  id=${vargs[${index}]}  quantity=${vargs[${index2}]}
        Append To List  ${orderitem}  ${items}
    END

    ${order}=  Create Dictionary  homeDelivery=${homeDelivery}  homeDeliveryAddress=${homeDeliveryAddress}   catalog=${catalog}  orderFor=${orderFor}    orderItem=${orderitem}   orderDate=${orderDate}   timeSlot=${timeSlot}  phoneNumber=${phoneNumber}  countryCode=${countryCode}  email=${email}  coupons=${coupons}
    ${resp}=  Imageupload.Shopping Cart Upload     ${Cookie}   ${accId}   ${order}
    [Return]  ${resp} 


App Create Order For Pickup
    [Arguments]   ${headers}  ${Cookie}   ${accId}   ${orderFor}    ${CatalogId}   ${storePickup}    ${sTime1}    ${eTime1}   ${orderDate}    ${phoneNumber}    ${email}  ${countryCode}  ${coupons}  @{vargs}      
    ${catalog}=  Create Dictionary  id=${CatalogId}
    ${orderFor}=  Create Dictionary  id=${orderFor}
    ${timeSlot}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}

    ${len}=  Get Length  ${vargs}
    ${items}=  Create Dictionary  id=${vargs[0]}  quantity=${vargs[1]}
    ${orderitem}=  Create List  ${items}
    FOR    ${index}   IN RANGE   2  ${len}  2
        ${index2}=  Evaluate  ${index}+1
        ${items}=  Create Dictionary  id=${vargs[${index}]}  quantity=${vargs[${index2}]}
        Append To List  ${orderitem}  ${items}
    END

    ${order}=  Create Dictionary  storePickup=${storePickup}   catalog=${catalog}  orderFor=${orderFor}    orderItem=${orderitem}   orderDate=${orderDate}   timeSlot=${timeSlot}  phoneNumber=${phoneNumber}  countryCode=${countryCode}  email=${email}  coupons=${coupons}
    ${resp}=  Imageupload.Shopping Cart Upload     ${Cookie}   ${accId}   ${order}
    [Return]  ${resp} 


App Get Order By Id
    [Arguments]    ${headers}  ${accId}   ${uuid}
    App Check And Create YNW Session  ${headers}
    ${resp}=  GET On Session  ynw  url=/consumer/orders/${uuid}?account=${accId}   expected_status=any
    [Return]  ${resp}


App Get Appointment Slots By Date Schedule
    [Arguments]    ${headers}  ${scheduleId}   ${date}   ${service}
    App Check And Create YNW Session  ${headers}
    ${resp}=  GET On Session  ynw  /provider/appointment/schedule/${scheduleId}/${date}/${service}   expected_status=any
    [Return]  ${resp}


App Take Appointment with Appointment Mode 
    [Arguments]   ${headers}  ${apptMode}   ${consid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${appmtFor}
    ${cid}=  Create Dictionary  id=${consid}
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}
    ${data}=    Create Dictionary  appointmentMode=${apptMode}  consumer=${cid}  service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}  
    ${data}=  json.dumps  ${data}
    App Check And Create YNW Session  ${headers}
    ${resp}=  POST On Session  ynw  /provider/appointment  data=${data}  expected_status=any  headers=${sp_app_headers}
    [Return]  ${resp}



*** comment ***
Android App Login
    [Arguments]    ${usname}  ${passwrd}  ${countryCode}=+91
    ${login}=    Create Dictionary    loginId=${usname}  password=${passwrd}  countryCode=${countryCode}
    ${log}=    json.dumps    ${login}
    Create Session    ynw    ${BASE_URL}  headers=${app_headers}
    [Return]  ${log}

Android SP App Login
    [Arguments]    ${usname}  ${passwrd}  ${countryCode}=+91
    ${login}=    Create Dictionary    loginId=${usname}  password=${passwrd}  countryCode=${countryCode}
    ${log}=    json.dumps    ${login}
    Create Session    ynw    ${BASE_URL}  headers=${sp_app_headers}
    [Return]  ${log}

Android App Check And Create YNW Session
    ${res}=   Session Exists    ynw
    # Run Keyword Unless  ${res}   Create Session    ynw    ${BASE_URL}  headers=${app_headers}
    IF  not ${res}
        Create Session    ynw    ${BASE_URL}  headers=${app_headers}
    END

SP App Check And Create YNW Session
    ${res}=   Session Exists    ynw
    # Run Keyword Unless  ${res}   Create Session    ynw    ${BASE_URL}  headers=${sp_app_headers}
    IF  not ${res}
        Create Session    ynw    ${BASE_URL}  headers=${sp_app_headers}
    END

Android App Consumer SignUp
    [Arguments]  ${firstname}  ${lastname}  ${address}  ${primaryNo}  ${alternativeNo}  ${dob}  ${gender}  ${email}   ${countryCode}=+91
    ${apple}=  Consumer Creation  ${firstname}  ${lastname}  ${address}  ${primaryNo}  ${alternativeNo}  ${dob}  ${gender}  ${email}   countryCode=${countryCode}    
    Android App Check And Create YNW Session
    ${resp}=    POST On Session    ynw    /consumer   data=${apple}  expected_status=any
    [Return]  ${resp}

Android App Consumer Activation
    [Arguments]  ${email}  ${purpose}
    Android App Check And Create YNW Session
    ${key}=   verify accnt  ${email}  ${purpose}
    ${resp_val}=  POST On Session   ynw  /consumer/${key}/verify   expected_status=any
    [Return]  ${resp_val}

Android App Consumer Login
    [Arguments]    ${usname}  ${passwrd}  ${countryCode}=+91
    ${log}=  Android App Login  ${usname}  ${passwrd}   countryCode=${countryCode}
    ${resp}=    POST On Session    ynw    /consumer/login    data=${log}  expected_status=any  headers=${app_headers}
    [Return]  ${resp}

Android App Consumer Logout
    Android App Check And Create YNW Session
    ${resp}=    DELETE On Session    ynw    /consumer/login  expected_status=any   headers=${app_headers}
    [Return]  ${resp}

Android ProviderLogin
    [Arguments]    ${usname}  ${passwrd}   ${countryCode}=91
    ${log}=  Android App Login  ${usname}  ${passwrd}   countryCode=${countryCode}
    ${resp}=    POST On Session    ynw    /provider/login    data=${log}  expected_status=any  headers=${app_headers}
    [Return]  ${resp}

Android SP ProviderLogin
    [Arguments]    ${usname}  ${passwrd}   ${countryCode}=91
    ${log}=  Android SP App Login  ${usname}  ${passwrd}   countryCode=${countryCode}
    ${resp}=    POST On Session    ynw    /provider/login    data=${log}  expected_status=any   headers=${sp_app_headers}
    [Return]  ${resp}

Android ProviderLogout
    Android App Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw  /provider/login  expected_status=any
    [Return]  ${resp}       

Android SP ProviderLogout
    SP App Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw  /provider/login  expected_status=any
    [Return]  ${resp}       

Android Create Order For HomeDelivery
    [Arguments]   ${Cookie}   ${accId}   ${orderFor}    ${CatalogId}   ${homeDelivery}    ${homeDeliveryAddress}  ${sTime1}    ${eTime1}   ${orderDate}    ${phoneNumber}    ${email}  ${countryCode}  ${coupons}  @{vargs}        
    ${catalog}=  Create Dictionary  id=${CatalogId}
    ${orderFor}=  Create Dictionary  id=${orderFor}
    ${timeSlot}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${len}=  Get Length  ${vargs}
    ${items}=  Create Dictionary  id=${vargs[0]}  quantity=${vargs[1]}
    ${orderitem}=  Create List  ${items}
    FOR    ${index}   IN RANGE   2  ${len}  2
        ${index2}=  Evaluate  ${index}+1
        ${items}=  Create Dictionary  id=${vargs[${index}]}  quantity=${vargs[${index2}]}
        Append To List  ${orderitem}  ${items}
    END

    ${order}=  Create Dictionary  homeDelivery=${homeDelivery}  homeDeliveryAddress=${homeDeliveryAddress}   catalog=${catalog}  orderFor=${orderFor}    orderItem=${orderitem}   orderDate=${orderDate}   timeSlot=${timeSlot}  phoneNumber=${phoneNumber}  countryCode=${countryCode}  email=${email}  coupons=${coupons}
    ${resp}=  Imageupload.AndroidShoppingCartUpload   ${Cookie}   ${accId}   ${order}
    [Return]  ${resp} 

Android Get Order By Id
    [Arguments]    ${accId}   ${uuid}
    Android App Check And Create YNW Session
    ${resp}=  GET On Session  ynw  url=/consumer/orders/${uuid}?account=${accId}   expected_status=any
    [Return]  ${resp}

Android Add To Waitlist Consumers
    [Arguments]  ${accId}  ${queueId}  ${date}  ${serviceId}  ${consumerNote}  ${revealPhone}  @{vargs}   
    ${param}=  Create Dictionary  account=${accId}
    ${queueId}=  Create Dictionary  id=${queueId}
    ${serviceId}=  Create Dictionary  id=${service_id}  
    
    ${len}=  Get Length  ${vargs}
    ${consumer}=  Create Dictionary  id=${vargs[0]}
    ${consumerlist}=  Create List  ${consumer}
    FOR    ${index}    IN RANGE  1  ${len}
        ${consumer}=  Create Dictionary  id=${vargs[${index}]}
        Append To List  ${consumerlist}  ${consumer}
    END
    ${data}=  Create Dictionary  queue=${queueId}  date=${date}  service=${serviceId}  consumerNote=${consumerNote}  waitlistingFor=${consumerlist}  revealPhone=${revealPhone} 
    ${data}=  json.dumps  ${data}
    Android App Check And Create YNW Session
    ${resp}=    POST On Session  ynw  /consumer/waitlist   data=${data}  params=${param}   expected_status=any   headers=${app_headers}
    [Return]  ${resp}

Android Get consumer Waitlist By Id
    [Arguments]  ${uuid}  ${accId}
    ${param}=  Create Dictionary  account=${accId}
    Android App Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/waitlist/${uuid}  params=${param}   expected_status=any   headers=${app_headers}
    [Return]  ${resp}

Android Take Appointment For Provider 
    [Arguments]    ${accid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${appmtFor}
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}    
    ${data}=    Create Dictionary    appointmentMode=ONLINE_APPOINTMENT   account=${accId}   service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}
    ${data}=  json.dumps  ${data}
    Android App Check And Create YNW Session
    ${resp}=  POST On Session  ynw   url=/consumer/appointment?account=${accId}  data=${data}  expected_status=any  headers=${app_headers}
    [Return]  ${resp}

Android Get consumer Appointment By Id
    [Arguments]   ${accId}  ${appmntId}
    Android App Check And Create YNW Session
    ${resp}=  GET On Session  ynw  url=/consumer/appointment/${appmntId}?account=${accId}   expected_status=any  headers=${app_headers}
    [Return]  ${resp}


Android GetCustomer
    [Arguments]  &{param}
    SP App Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /provider/customers  params=${param}  expected_status=any   headers=${sp_app_headers}
    [Return]  ${resp}


Android Add To Waitlist
    [Arguments]   ${consid}  ${service_id}  ${qid}  ${date}  ${consumerNote}  ${ignorePrePayment}  @{fids}
    ${cid}=  Create Dictionary  id=${consid}
    ${sid}=  Create Dictionary  id=${service_id}
    ${qid}=  Create Dictionary  id=${qid}
    ${fid}=  Create Dictionary  id=${fids[0]}
    ${len}=  Get Length  ${fids}
    ${fid}=  Create List  ${fid}
    FOR    ${index}    IN RANGE  1  ${len}
        ${ap}=  Create Dictionary  id=${fids[${index}]}
        Append To List  ${fid} 	${ap}
    END
    ${data}=    Create Dictionary    consumer=${cid}  service=${sid}  queue=${qid}  date=${date}  consumerNote=${consumerNote}  waitlistingFor=${fid}  ignorePrePayment=${ignorePrePayment}
    ${data}=  json.dumps  ${data}
    SP App Check And Create YNW Session
    ${resp}=  POST On Session  ynw  provider/waitlist  data=${data}  expected_status=any  headers=${sp_app_headers}
    [Return]  ${resp}

Android Add To Waitlist with mode
    [Arguments]   ${waitlistMode}  ${consid}  ${service_id}  ${qid}  ${date}  ${consumerNote}  ${ignorePrePayment}   @{fids}
    ${cid}=  Create Dictionary  id=${consid}
    ${sid}=  Create Dictionary  id=${service_id}
    ${qid}=  Create Dictionary  id=${qid}
    ${fid}=  Create Dictionary  id=${fids[0]}
    ${len}=  Get Length  ${fids}
    ${fid}=  Create List  ${fid}
    FOR    ${index}    IN RANGE  1  ${len}
        ${ap}=  Create Dictionary  id=${fids[${index}]}
        Append To List  ${fid} 	${ap}
    END
    ${data}=    Create Dictionary    consumer=${cid}  service=${sid}  queue=${qid}  date=${date}  consumerNote=${consumerNote}  waitlistingFor=${fid}  ignorePrePayment=${ignorePrePayment}  waitlistMode=${waitlistMode}
    ${data}=  json.dumps  ${data}
    SP App Check And Create YNW Session
    ${resp}=  POST On Session  ynw  provider/waitlist  data=${data}  expected_status=any  headers=${sp_app_headers}
    [Return]  ${resp}

Android Flush Analytics Data to DB
    [Arguments]
    SP App Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/analytics/db/flush  expected_status=any  headers=${sp_app_headers}
    [Return]  ${resp}

Android Get Account Level Analytics
    [Arguments]   ${metricId}  ${dateFrom}  ${dateTo}  ${frequency}  &{kwargs}
    ${params}=  Create Dictionary  metricId=${metricId}  dateFrom=${dateFrom}  dateTo=${dateTo}  frequency=${frequency}
    SP App Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/analytics/account  params=${params}  expected_status=any  headers=${sp_app_headers}
    [Return]  ${resp}


Android Take Appointment For Consumer 
    [Arguments]   ${consid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${appmtFor}
    ${cid}=  Create Dictionary  id=${consid}
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}
    ${data}=    Create Dictionary   consumer=${cid}  service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}
    ${data}=  json.dumps  ${data}
    SP App Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/appointment  data=${data}  expected_status=any  headers=${sp_app_headers}
    [Return]  ${resp}


Android Take Appointment with Appointment Mode 
    [Arguments]   ${apptMode}   ${consid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${appmtFor}
    ${cid}=  Create Dictionary  id=${consid}
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}
    ${data}=    Create Dictionary  appointmentMode=${apptMode}  consumer=${cid}  service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}  
    ${data}=  json.dumps  ${data}
    SP App Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/appointment  data=${data}  expected_status=any  headers=${sp_app_headers}
    [Return]  ${resp}


Android Create Order For Pickup
    [Arguments]   ${Cookie}   ${accId}   ${orderFor}    ${CatalogId}   ${storePickup}    ${sTime1}    ${eTime1}   ${orderDate}    ${phoneNumber}    ${email}  ${countryCode}  ${coupons}  @{vargs}      
    ${catalog}=  Create Dictionary  id=${CatalogId}
    ${orderFor}=  Create Dictionary  id=${orderFor}
    ${timeSlot}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}

    ${len}=  Get Length  ${vargs}
    ${items}=  Create Dictionary  id=${vargs[0]}  quantity=${vargs[1]}
    ${orderitem}=  Create List  ${items}
    FOR    ${index}   IN RANGE   2  ${len}  2
        ${index2}=  Evaluate  ${index}+1
        ${items}=  Create Dictionary  id=${vargs[${index}]}  quantity=${vargs[${index2}]}
        Append To List  ${orderitem}  ${items}
    END

    ${order}=  Create Dictionary  storePickup=${storePickup}   catalog=${catalog}  orderFor=${orderFor}    orderItem=${orderitem}   orderDate=${orderDate}   timeSlot=${timeSlot}  phoneNumber=${phoneNumber}  countryCode=${countryCode}  email=${email}  coupons=${coupons}
    ${resp}=  Imageupload.AndroidSPShoppingCartUpload   ${Cookie}   ${accId}   ${order}
    [Return]  ${resp} 



