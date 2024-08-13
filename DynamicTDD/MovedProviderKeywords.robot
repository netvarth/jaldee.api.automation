
######### Moved Keywords #############


Create Service
    #...  merged the following keywords to this
    #...  Create Service with info
    #...  Create Service With serviceType   serviceType=${serviceType}
    #...  Create Service Department
    #...  Create Service For User
    #...  Create Sample Donation For User, needs depid and user id
    [Arguments]  ${name}  ${desc}  ${durtn}  ${status}  ${bType}  ${notfcn}  ${notiTp}   ${minPrePaymentAmount}   ${totalAmount}  ${isPrePayment}  ${taxable}   &{kwargs}
    ${items}=  Get Dictionary items  ${kwargs}
    ${data}=  Create Dictionary  name=${name}  description=${desc}  serviceDuration=${durtn}  notification=${notfcn}  notificationType=${notiTp}  minPrePaymentAmount=${minPrePaymentAmount}   totalAmount=${totalAmount}   status=${status}  bType=${btype}  isPrePayment=${isPrePayment}  taxable=${taxable}
    FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    Log  ${data}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session  
    ${resp}=  POST On Session  ynw  /provider/services  data=${data}  expected_status=any
    RETURN  ${resp}

Create Sample Service
    #...  Create Sample Service with Prepayment
    #...  Create Sample Service with Prepayment For User   
    #...  Create Sample Service For User
    [Arguments]  ${Service_name}    &{kwargs}
    ${desc}=   FakerLibrary.sentence
    ${srv_duration}=   Random Int   min=2   max=2
    ${min_pre}=   Random Int   min=1   max=50
    ${Total}=   Random Int   min=100   max=500
    ${resp}=  Create Service  ${Service_name}  ${desc}   ${srv_duration}  ${status[0]}  ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[0]}  ${bool[0]}   &{kwargs}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    RETURN  ${resp.json()}

Create Service with info
    [Arguments]   ${name}   ${desc}   ${durtn}   ${notfcn}   ${notiTp}   ${minPrePaymentAmount}   ${totalAmount}   ${status}   ${bType}   ${isPrePayment}   ${taxable}   ${serviceType}   ${virtualServiceType}   ${virtualCallingModes}   ${depid}   ${u_id}   ${consumerNoteMandatory}   ${consumerNoteTitle}   ${preInfoEnabled}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled}   ${postInfoTitle}   ${postInfoText}
    ${user_id}=  Create Dictionary  id=${u_id}
    ${data}=  Create Dictionary  name=${name}  description=${desc}  serviceDuration=${durtn}  notification=${notfcn}  notificationType=${notiTp}  minPrePaymentAmount=${minPrePaymentAmount}   totalAmount=${totalAmount}   status=${status}  bType=${btype}  isPrePayment=${isPrePayment}  taxable=${taxable}   serviceType=${serviceType}   virtualServiceType=${virtualServiceType}  virtualCallingModes=${virtualCallingModes}  department=${depid}   provider=${user_id}   consumerNoteMandatory=${consumerNoteMandatory}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${preInfoEnabled}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${postInfoEnabled}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session  
    ${resp}=  POST On Session  ynw  /provider/services  data=${data}  expected_status=any
    RETURN  ${resp}

Create Service With serviceType
    [Arguments]  ${name}  ${desc}  ${durtn}  ${status}  ${bType}  ${notfcn}  ${notiTp}   ${minPrePaymentAmount}   ${totalAmount}  ${isPrePayment}  ${taxable}   ${serviceType}
    ${data}=  Create Dictionary  name=${name}  description=${desc}  serviceDuration=${durtn}  notification=${notfcn}  notificationType=${notiTp}  minPrePaymentAmount=${minPrePaymentAmount}   totalAmount=${totalAmount}   status=${status}  bType=${btype}  isPrePayment=${isPrePayment}  taxable=${taxable}   serviceType=${serviceType}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session  
    ${resp}=  POST On Session  ynw  /provider/services  data=${data}  expected_status=any
    RETURN  ${resp}



Create Sample Service with Prepayment
    [Arguments]  ${Service_name}  ${prepayment_amt}  ${servicecharge}  &{kwargs}
    ${desc}=   FakerLibrary.sentence
    ${srv_duration}=   Random Int   min=2   max=2
    ${resp}=  Create Service  ${Service_name}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${prepayment_amt}  ${servicecharge}  ${bool[1]}  ${bool[0]}  &{kwargs}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    RETURN  ${resp.json()}


Create Sample Service with Prepayment For User
    [Arguments]  ${Service_name}  ${prepayment_amt}  ${servicecharge}  ${u_id}  &{kwargs}
    ${desc}=   FakerLibrary.sentence
    ${srv_duration}=   Random Int   min=2   max=2
    ${resp}=  Create Service For User  ${Service_name}  ${desc}   ${srv_duration}  ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}  ${prepayment_amt}  ${servicecharge}  ${bool[1]}  ${bool[0]}  ${depid}  ${u_id}  &{kwargs}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    RETURN  ${resp.json()}


Create Sample Service For User
    [Arguments]   ${Service_name}   ${depid}   ${u_id}
    ${resp}=  Create Service For User  ${Service_name}  Description   2  ACTIVE  Waitlist  True  email  45  500  False  False  ${depid}   ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    RETURN  ${resp.json()}

Create Service Department
    [Arguments]  ${name}  ${desc}  ${durtn}  ${bType}  ${notfcn}  ${notiTp}   ${minPrePaymentAmount}   ${totalAmount}  ${isPrePayment}  ${taxable}  ${depid}  
    ${data}=  Create Dictionary  name=${name}  description=${desc}  serviceDuration=${durtn}  notification=${notfcn}  notificationType=${notiTp}  minPrePaymentAmount=${minPrePaymentAmount}   totalAmount=${totalAmount}  bType=${btype}  isPrePayment=${isPrePayment}  taxable=${taxable}  department=${depid} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session  
    ${resp}=  POST On Session  ynw  /provider/services  data=${data}  expected_status=any
    RETURN  ${resp}

Create Service For User
    [Arguments]  ${name}  ${desc}  ${durtn}  ${status}  ${bType}  ${notfcn}  ${notiTp}   ${minPrePaymentAmount}   ${totalAmount}  ${isPrePayment}  ${taxable}  ${depid}   ${u_id}  &{kwargs}
    ${user_id}=  Create Dictionary  id=${u_id}
    ${data}=  Create Dictionary  name=${name}  description=${desc}  serviceDuration=${durtn}  notification=${notfcn}  notificationType=${notiTp}  minPrePaymentAmount=${minPrePaymentAmount}   totalAmount=${totalAmount}   status=${status}  bType=${btype}  isPrePayment=${isPrePayment}  taxable=${taxable}  department=${depid}   provider=${user_id}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session  
    ${resp}=  POST On Session  ynw  /provider/services  data=${data}  expected_status=any
    RETURN  ${resp}

Create Sample Donation For User
    [Arguments]  ${Service_name}   ${depid}   ${u_id}
    ${resp}=  Create Service For User   ${Service_name}  Description   2  ACTIVE  Waitlist  True  email  45  500  False  False   ${depid}   ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    RETURN  ${resp.json()}












Get BusinessDomainsConf
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /ynwConf/businessDomains   expected_status=any
    RETURN  ${resp}

Get Business Profile
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/bProfile  expected_status=any
    RETURN  ${resp}

Account SignUp
    [Arguments]  ${firstname}  ${lastname}  ${yemail}  ${sector}  ${sub_sector}  ${ph}  ${licPkgId}   ${countryCode}=91
    ${data}=   User Creation  ${firstname}  ${lastname}  ${yemail}  ${sector}  ${sub_sector}  ${ph}  ${licPkgId}  countryCode=${countryCode}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /provider    data=${data}  expected_status=any  
    RETURN  ${resp}

# Account Activation
#     [Arguments]  ${email}  ${purpose}
#     Check And Create YNW Session
#     ${key}=   verify accnt  ${email}  ${purpose}
#     ${resp_val}=  POST On Session   ynw  /provider/${key}/verify  expected_status=any
#     RETURN  ${resp_val}
# This URL Has Been Commented in rest side

Account Activation
    [Arguments]  ${loginid}  ${purpose}
    Check And Create YNW Session
    ${key}=   verify accnt  ${loginid}  ${purpose}
    ${headers2}=     Create Dictionary    Content-Type=application/json    Authorization=browser
    ${resp}=    POST On Session    ynw    /provider/oauth/otp/${key}/verify  headers=${headers2}  expected_status=any
    RETURN  ${resp}

Account Set Credential
    [Arguments]  ${email}  ${password}  ${purpose}  ${loginId}  &{kwargs}
    ${auth}=     Create Dictionary   password=${password}  loginId=${loginId}
    Check And Create YNW Session
    FOR  ${key}  ${value}  IN  &{kwargs}
        IF  '${key}' == 'JSESSIONYNW'
            ${sessionid}=  Set Variable  ${value}
        END
    END
    ${session_given}=    Get Variable Value    ${sessionid}
    IF  '${session_given}'=='${None}'
        ${key}=   verify accnt  ${email}  ${purpose}
    ELSE
        ${key}=   verify accnt  ${email}  ${purpose}  ${sessionid}
    END
    ${apple}=    json.dumps    ${auth}
    ${resp}=    PUT On Session    ynw    /provider/${key}/activate    data=${apple}    expected_status=any
    RETURN  ${resp}

Encrypted Provider Login
    [Arguments]    ${usname}  ${passwrd}   ${countryCode}=91
    ${data}=  Login  ${usname}  ${passwrd}   countryCode=${countryCode}
    ${encrypted_data}=  db.encrypt_data  ${data}
    ${data}=    json.dumps    ${encrypted_data}
    ${resp}=    POST On Session    ynw    /provider/login/encrypt    data=${data}  expected_status=any
    db.decrypt_data  ${resp.content}
    RETURN  ${resp}


#  Business Logo And Department Icon

Add Business Logo

    [Arguments]    ${owner}    ${fileName}    ${fileSize}    ${action}    ${caption}    ${fileType}    ${order}  &{kwargs}

    ${AttachmentsUpload}=  Create List
    ${Attachment}=    Create Dictionary    owner=${owner}    fileName=${fileName}    fileSize=${fileSize}    action=${action}    caption=${caption}    fileType=${fileType}    order=${order}
    FOR  ${key}  ${value}  IN  &{kwargs}
        IF  '${key}' == 'driveId'
            Set To Dictionary  ${Attachment}   ${key}=${value}
        END
    END
    Append To List  ${AttachmentsUpload}  ${Attachment}
    
    ${data}=    json.dumps    ${AttachmentsUpload}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /provider/upload/businessLogo  data=${data}  expected_status=any
    RETURN  ${resp}

Remove Business Logo

    [Arguments]    ${owner}    ${fileName}    ${fileSize}    ${action}    ${caption}    ${fileType}    ${order}

    ${AttachmentsUpload}=  Create List
    ${Attachment}=    Create Dictionary    owner=${owner}    fileName=${fileName}    fileSize=${fileSize}    action=${action}    caption=${caption}    fileType=${fileType}    order=${order}
    Append To List  ${AttachmentsUpload}  ${Attachment}
    
    ${data}=    json.dumps    ${AttachmentsUpload}
    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw   /provider/remove/businessLogo  data=${data}  expected_status=any
    RETURN  ${resp}

Get Business Logo

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/businessLogo  expected_status=any
    RETURN  ${resp}

Provider Logout
    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw  /provider/login  expected_status=any
    RETURN  ${resp}       

Create Location
    [Arguments]  ${place}  ${longi}  ${latti}  ${g_url}  ${pin}  ${add}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  &{kwargs}
    ${bs}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}
    ${bs}=  Create List  ${bs}
    ${bs}=  Create Dictionary  timespec=${bs}
    ${data}=  Create Dictionary  place=${place}  longitude=${longi}  lattitude=${latti}  googleMapUrl=${g_url}  pinCode=${pin}  address=${add}  parkingType=${pt}  open24hours=${oh}  bSchedule=${bs}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/locations  data=${data}  expected_status=any
    RETURN  ${resp} 

Create Sample Location
    FOR   ${i}  IN RANGE   5
        ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
        ${check}=  Check Location Exists  ${city}
        IF  '${check}' == 'True'
            Continue For Loop
        ELSE
            Exit For Loop
        END
    END
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking_type}    Random Element  ${parkingType}
    ${24hours}    Random Element  ${bool}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY}=  get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  30  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking_type}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    RETURN  ${resp.json()}

Get Location ById
    [Arguments]  ${id}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/locations/${id}  expected_status=any
    RETURN  ${resp}

Disable Location
   [Arguments]   ${id}
   Check And Create YNW Session
   ${resp}=    DELETE On Session    ynw  /provider/locations/${id}/disable  expected_status=any
   RETURN  ${resp}

Get Service
    # Filters: id, name, status, account, serviceDuration, serviceType, serviceCategory, department, provider, notificationType, labels, channelRestricted
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/services  params=${param}  expected_status=any
    RETURN  ${resp}

AddCustomer
    [Arguments]    ${primaryNo}  ${countryCode}=91   &{kwargs}
    ${items}=  Get Dictionary items  ${kwargs}
    ${data}=  Create Dictionary  phoneNo=${primaryNo}  countryCode=${countryCode}
    FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    Log  ${data}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    # ${data}=  Create Dictionary  phoneNo=${primaryNo}  firstName=${firstname}  lastName=${lastname}  countryCode=${countryCode}
    ${resp}=  POST On Session  ynw  url=/provider/customers  data=${data}  expected_status=any
    RETURN  ${resp}

Change Provider Consumer Profile Status 
    [Arguments]    ${consumerId}   ${status}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/customers/${consumerId}/changeStatus/${status}   expected_status=any
    RETURN  ${resp}

Queue
    [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  @{vargs}
    ${bs}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}
    ${loctype} =    Evaluate    type($loc).__name__
    ${loc}=  Run Keyword If  '${loctype}' == 'bytes'   Decode Bytes To String  ${loc}  UTF-8
    ...  ELSE	 Set Variable    ${loc}
    ${location}=  Create Dictionary  id=${loc}
    ${len}=  Get Length  ${vargs}
    # ${service}=  Create Dictionary  id=${vargs[0]}
    # ${services}=  Create List  ${service}
    ${services}=  Create List  
    FOR    ${index}    IN RANGE  0  ${len}
        ${srvid}=  Set Variable    ${vargs[${index}]}
        ${sertype} =    Evaluate    type($srvid).__name__
        ${srvid}=  Run Keyword If  '${sertype}' == 'bytes'   Decode Bytes To String  ${srvid}  UTF-8
        ...  ELSE	 Set Variable    ${srvid}
    	# ${service}=  Create Dictionary  id=${vargs[${index}]} 
        ${service}=  Create Dictionary  id=${srvid}
        Append To List  ${services}  ${service}
    END
    ${data}=  Create Dictionary  name=${name}  queueSchedule=${bs}  parallelServing=${parallel}  capacity=${capacity}  location=${location}  services=${services}
    RETURN  ${data}


Create Queue
   [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  @{vargs}
   ${data}=  Queue  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  @{vargs}
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw  /provider/waitlist/queues  data=${data}  expected_status=any
   RETURN  ${resp}
   
Get Queues
    [Arguments]  &{kwargs}
    # Available filters- id, account, branchId, location, state, provider, service, instantQueue
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/queues  params=${kwargs}  expected_status=any
    RETURN  ${resp}

Get Queue ById
    [Arguments]  ${id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/queues/${id}  expected_status=any
    RETURN  ${resp}

Take Appointment For Consumer 
    [Arguments]   ${consid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${appmtFor}  &{kwargs}
    
    ${pro_headers}=  Create Dictionary  &{headers}
    ${pro_params}=   Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    ${items}=  Get Dictionary items  ${kwargs}
    Set To Dictionary  ${pro_headers}   &{tzheaders}
    Set To Dictionary  ${pro_params}   &{locparam}
    
    ${cid}=  Create Dictionary  id=${consid}
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}
    ${data}=    Create Dictionary   consumer=${cid}  service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}
    # ${data}=    Create Dictionary   appointmentMode=WALK_IN_APPOINTMENT  consumer=${cid}  service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}  
    FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/appointment  params=${pro_params}    data=${data}  expected_status=any
    RETURN  ${resp}

Appointment Schedule
    [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}   ${consumerParallelServing}   ${loc}  ${timeduration}  ${batch}  @{vargs}
    ${bs}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}
    ${location}=  Create Dictionary  id=${loc}
    ${data}=  Create Dictionary  name=${name}  apptSchedule=${bs}   parallelServing=${parallel}    consumerParallelServing=${consumerParallelServing}  location=${location}  timeDuration=${timeduration}  batchEnable=${batch}
    ${len}=  Get Length  ${vargs}
    ${services}=  Create List  
    FOR    ${index}    IN RANGE  0  ${len}
        Exit For Loop If  ${len}==0
    	${service}=  Create Dictionary  id=${vargs[${index}]} 
        Append To List  ${services}  ${service}
    END
    Run Keyword If  ${len}>0  Set To Dictionary  ${data}  services=${services}
    RETURN  ${data}

Create Appointment Schedule
    [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}   ${consumerParallelServing}    ${loc}  ${timeduration}  ${batch}  @{vargs}
    ${data}=  Appointment Schedule  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}    ${consumerParallelServing}   ${loc}  ${timeduration}  ${batch}  @{vargs}
    Check And Create YNW Session
    ${data}=  json.dumps  ${data}
    ${resp}=  POST On Session  ynw  /provider/appointment/schedule  data=${data}  expected_status=any
    RETURN  ${resp}

Get Appoinment Service By Location   
    [Arguments]  ${locationId}   
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/appointment/service/${locationId}  expected_status=any     
    RETURN  ${resp} 

Get Available Slots for Month Year
    [Arguments]  ${location}  ${service}  ${month}  ${year}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/appointment/availability/location/${location}/service/${service}/${month}/${year}  params=${param}  expected_status=any
    RETURN  ${resp}

Send Message With Appointment
    [Arguments]  ${message}  ${emailflag}  ${smsflag}  ${telegramflag}  ${whatsAppflag}  &{kwargs}  
    #Required- uuid- list of wl ids, attachments- list of dictionaries with file details

    ${medium}=  Create Dictionary  email=${emailflag}  sms=${smsflag}  telegram=${telegramflag}  whatsApp=${whatsAppflag}
    ${data}=  Create Dictionary  medium=${medium}  communicationMessage=${message}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/appointment/communication   data=${data}  expected_status=any
    RETURN  ${resp}

Send Attachment From Appointmnent 
    [Arguments]  ${uid}  ${emailflag}  ${smsflag}  ${telegramflag}  ${whatsAppflag}  @{attachments}

    ${medium}=  Create Dictionary  email=${emailflag}  sms=${smsflag}  telegram=${telegramflag}  whatsApp=${whatsAppflag}
    # ${attachments}=  Create Dictionary  owner=${owner}  ownerName=${ownerName}  fileName=${fileName}  caption=${caption}  fileSize=${fileSize}  fileType=${fileType}  order=${order}  driveId=${driveId}  action=${action}
    ${data}=  Create Dictionary  medium=${medium}  attachments=${attachments} 
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/appointment/share/attachments/${uid}   data=${data}  expected_status=any
    RETURN  ${resp}

GetFollowUpDetailsofAppmt
    [Arguments]     ${uid}

    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /provider/appointment/followUp/${uid}   expected_status=any
    RETURN  ${resp}

Provider Get Appt Service Request Count
    [Arguments]    &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/appointment/service/request/count   params=${kwargs}    expected_status=any
    RETURN  ${resp}

Get Appointment Slots By Date Schedule
    [Arguments]    ${scheduleId}   ${date}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/appointment/schedule/${scheduleId}/${date}  expected_status=any
    RETURN  ${resp}

Get Appointment Slots By Date Schedule
    [Arguments]    ${scheduleId}   ${date}   ${service}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/appointment/schedule/${scheduleId}/${date}/${service}   expected_status=any
    RETURN  ${resp}

Block Appointment For Consumer
    [Arguments]    ${service_id}  ${schedule_id}  ${appmtDate}  ${appmtFor}
    ${schedule}=  Create Dictionary  id=${schedule_id}
    ${service}=  Create Dictionary  id=${service_id}
    ${data}=    Create Dictionary   service=${service}   schedule=${schedule}   appmtDate=${appmtDate}   appmtFor=${appmtFor}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/appointment/block  data=${data}  expected_status=any
    RETURN  ${resp}

Unblock Appointment Slot
    [Arguments]    ${appointment_id}  
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/appointment/unblock/${appointment_id}   expected_status=any
    RETURN  ${resp}
    
Get Appointment level Bill Details

    [Arguments]   ${uuid}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/appointment/${uuid}/billdetails     expected_status=any
    RETURN  ${resp}

Provider Change Answer Status for Appointment
    [Arguments]  ${apptId}  @{filedata}  
    ${data}=  Create Dictionary  urls=${filedata}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/appointment/questionnaire/upload/status/${apptId}  data=${data}  expected_status=any
    RETURN  ${resp}  

........ Membership Service ............

Create Membership Service 

    [Arguments]    ${description}    ${name}    ${displayName}    ${effectiveFrom}    ${effectiveTo}    ${approvalType}    ${allowLogin}    ${serviceStatus}

    ${data}=  Create Dictionary    description=${description}    name=${name}    displayName=${displayName}    effectiveFrom=${effectiveFrom}    effectiveTo=${effectiveTo}    approvalType=${approvalType}    allowLogin=${allowLogin}    serviceStatus=${serviceStatus}
    ${data}=    json.dumps    ${data} 
    Check And Create YNW Session
    ${resp}=    POST On Session  ynw  /provider/membership/service    data=${data}   expected_status=any
    RETURN  ${resp}

Get Membership Service by id

    [Arguments]    ${memberid}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/membership/service/${memberid}  expected_status=any
    RETURN  ${resp}

User Creation
    [Arguments]  ${firstname}  ${lastname}  ${yemail}  ${sector}  ${sub_sector}  ${ph}  ${licPkgId}  ${countryCode}=91
    ${usp}=    Create Dictionary   firstName=${firstname}  lastName=${lastname}  email=${yemail}  primaryMobileNo=${ph}  countryCode=${countryCode}
    ${data}=  Create Dictionary  userProfile=${usp}  sector=${sector}  subSector=${sub_sector}  licPkgId=${licPkgId}
    RETURN  ${data}

Get Membership Service 

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/membership/service  expected_status=any
    RETURN  ${resp}

Get Member Count

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/membership/count  expected_status=any
    RETURN  ${resp}

GetCustomer
    [Arguments]  &{param} 
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /provider/customers  params=${param}  expected_status=any
    RETURN  ${resp}

Get Order Settings by account id
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/order/settings   expected_status=any
    RETURN  ${resp}

Enable Order Settings
   Check And Create YNW Session
   ${resp}=    PUT On Session    ynw  /provider/order/settings/true   expected_status=any
   RETURN  ${resp}

Disable Order Settings
   Check And Create YNW Session
   ${resp}=    PUT On Session    ynw  /provider/order/settings/false   expected_status=any
   RETURN  ${resp}

Create MR Case
    [Arguments]      ${category}  ${type}  ${doctor}  ${consumer}   ${title}  ${description}  &{kwargs}
    ${data}=  Create Dictionary    category=${category}  type=${type}  doctor=${doctor}  consumer=${consumer}   title=${title}  description=${description}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/medicalrecord/case  data=${data}  expected_status=any
    RETURN  ${resp}

Get MR Case By UID
     [Arguments]     ${uid}  
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /provider/medicalrecord/case/${uid}  expected_status=any
    RETURN  ${resp}

Create DentalRecord

    [Arguments]      ${toothNo}  ${toothType}  ${orginUid}   &{kwargs}

    ${data}=  Create Dictionary    toothNo=${toothNo}  toothType=${toothType}    orginUid=${orginUid}

    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END

    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/dental  data=${data}  expected_status=any
    RETURN  ${resp}

Get DentalRecord ById
    Check And Create YNW Session
    [Arguments]     ${Id}  
    ${resp}=    GET On Session    ynw    /provider/dental/${Id}        expected_status=any
    RETURN  ${resp}

Delete DentalRecord
    Check And Create YNW Session
    [Arguments]    ${Id}  
    ${resp}=    DELETE On Session    ynw    /provider/dental/${Id}       expected_status=any
    RETURN  ${resp}

Get Frequency By Account

    [Arguments]  ${account}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/medicalrecord/prescription/frequency/account/${account}     expected_status=any
    RETURN  ${resp}

Create Treatment Plan

    [Arguments]      ${caseDto}   ${dental_id}   ${treatment}  ${works}  &{kwargs}
    ${caseDto}=  Create Dictionary  uid=${caseDto} 
    ${dentalRecord}=  Create Dictionary  id=${dental_id}

    ${data}=  Create Dictionary    caseDto=${caseDto}    dentalRecord=${dentalRecord}  treatment=${treatment}  works=${works} 
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    IF  '${dental_id}' == '${EMPTY}'
        Remove From Dictionary 	${data} 	dentalRecord
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/medicalrecord/treatment  data=${data}  expected_status=any
    RETURN  ${resp}

Get Treatment Plan List
    [Arguments]    ${case_uid}        ${toothNo}
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw    /provider/medicalrecord/treatment/case/${case_uid}/toothno/${toothNo}   expected_status=any
    RETURN  ${resp}

User Creation
    [Arguments]  ${firstname}  ${lastname}  ${yemail}  ${sector}  ${sub_sector}  ${ph}  ${licPkgId}  ${countryCode}=91
    ${usp}=    Create Dictionary   firstName=${firstname}  lastName=${lastname}  email=${yemail}  primaryMobileNo=${ph}  countryCode=${countryCode}
    ${data}=  Create Dictionary  userProfile=${usp}  sector=${sector}  subSector=${sub_sector}  licPkgId=${licPkgId}
    RETURN  ${data}

Toggle Department Enable
	Check And Create YNW Session
    ${resp}=  PUT On Session    ynw  /provider/settings/waitlistMgr/department/Enable   expected_status=any
    RETURN  ${resp}   
 
Toggle Department Disable
	Check And Create YNW Session
    ${resp}=  PUT On Session    ynw  /provider/settings/waitlistMgr/department/Disable   expected_status=any
    RETURN  ${resp} 

Get Departments
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/departments  expected_status=any
    RETURN  ${resp}

View Waitlist Settings
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/settings/waitlistMgr  expected_status=any
    RETURN  ${resp}

Create MedicalRecordPrescription Template
    [Arguments]    ${templateName}    @{vargs}
    ${len}=  Get Length  ${vargs}
    ${prescriptionDto}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${prescriptionDto}  ${vargs[${index}]}
    END
    ${data}=    Create Dictionary    templateName=${templateName}  prescriptionDto=${prescriptionDto} 
    Check And Create YNW Session
    ${data}=  json.dumps  ${data}
    ${resp}=    POST On Session    ynw    /provider/medicalrecord/prescription/template    data=${data}    expected_status=any
    RETURN  ${resp}

Update Specialization
    [Arguments]  ${data}    
    ${data}=  json.dumps  ${data}
    Log  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bProfile   data=${data}  expected_status=any
    RETURN  ${resp}
    
Get Section Template
    [Arguments]    ${caseUid} 
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/medicalrecord/section/template/case/${caseUid}    expected_status=any
    RETURN  ${resp}

Create Sections 
    [Arguments]    ${uid}    ${id}    ${templateDetailId}       ${sectionType}    ${sectionValue}    @{vargs}  &{kwargs}
     Check And Create YNW Session
    ${mrCase}=    Create Dictionary  uid=${uid}
    ${doctor}=      Create Dictionary    id=${id}
     ${len}=  Get Length  ${vargs}
    ${attachments}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${attachments}  ${vargs[${index}]}
    END

    ${data}=    Create Dictionary    mrCase=${mrCase}    doctor=${doctor}    templateDetailId=${templateDetailId}      sectionType=${sectionType}    sectionValue=${sectionValue}    attachments=${attachments}   
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    ${resp}=    POST On Session    ynw    /provider/medicalrecord/section    data=${data}    expected_status=any
    RETURN  ${resp}

Add To Waitlist
    [Arguments]   ${consid}  ${service_id}  ${qid}  ${date}  ${consumerNote}  ${ignorePrePayment}  @{fids}  &{kwargs}
    ${pro_headers}=  Create Dictionary  &{headers}
    ${pro_params}=   Create Dictionary
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

    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${pro_headers}   &{tzheaders}
    Set To Dictionary  ${pro_params}   &{locparam}

    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  provider/waitlist  params=${pro_params}  data=${data}  expected_status=any   headers=${headers}  
    RETURN  ${resp}

#----------------------Account-----------------
Get Account contact information
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/contact  expected_status=any
    RETURN  ${resp} 

# Create User
#     #Create User With Roles And Scope         
#     #userRoles=${userRoles}
#    #   ${dob}  ${gender}    ${pincode}  ${countryCode}  ${mob_no}  ${dept_id}  ${sub_domain}  ${admin}  ${whatsApp_countrycode}  ${WhatsApp_num}  ${telegram_countrycode}  ${telegram_num}   
    #  [Arguments]  ${fname}  ${lname}    ${email}  ${user_type}  ${pincode}  ${countryCode}  ${mob_no}  ${dept_id}  ${sub_domain}  ${admin}  ${whatsApp_countrycode}  ${WhatsApp_num}  ${telegram_countrycode}  ${telegram_num}   &{kwargs} 
#     ${whatsAppNum}=  Create Dictionary  countryCode=${whatsApp_countrycode}  number=${WhatsApp_num}
#     ${telegramNum}=  Create Dictionary  countryCode=${telegram_countrycode}  number=${telegram_num}
#     ${data}=  Create Dictionary  firstName=${fname}  lastName=${lname}  dob=${dob}  gender=${gender}  email=${email}  userType=${user_type}  pincode=${pincode}  countryCode=${countryCode}  mobileNo=${mob_no}  deptId=${dept_id}  subdomain=${sub_domain}  admin=${admin}  whatsAppNum=${whatsAppNum}  telegramNum=${telegramNum}
#     FOR  ${key}  ${value}  IN  &{kwargs} 
#             Set To Dictionary  ${data}   ${key}=${value}
#     END
#     ${data}=  json.dumps  ${data}
#     Check And Create YNW Session
#     ${resp}=  POST On Session  ynw  /provider/user    data=${data}  expected_status=any
#     RETURN  ${resp}

Create User
    #Create User With Roles And Scope         
    #userRoles=${userRoles}
    #${dob}  ${gender}    ${pincode}  ${email}   ${dept_id}  ${sub_domain}  ${admin}  ${whatsApp_countrycode}  ${WhatsApp_num}  ${telegram_countrycode}  ${telegram_num}   
    [Arguments]  ${fname}  ${lname}    ${countryCode}  ${mob_no}  ${user_type}   &{kwargs} 
    ${data}=  Create Dictionary  firstName=${fname}  lastName=${lname}  countryCode=${countryCode}  mobileNo=${mob_no}  userType=${user_type}  
    FOR  ${key}  ${value}  IN  &{kwargs} 
            Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/user    data=${data}  expected_status=any
    RETURN  ${resp}

User Profile Updation
    [Arguments]  ${b_name}  ${b_desc}  ${spec}  ${lan}  ${sub_domain}  ${id}
    Check And Create YNW Session
    ${data}=  Create Dictionary  businessName=${b_name}  businessDesc=${b_desc}  specialization=${spec}  languagesSpoken=${lan}  userSubdomain=${sub_domain}
    ${data}=    json.dumps    ${data}
    ${resp}=  PUT On Session  ynw  /provider/user/providerBprofile/${id}  data=${data}  expected_status=any
    RETURN  ${resp}

Get User Profile
    [Arguments]  ${id}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/user/providerBprofile/${id}   expected_status=any  
    RETURN  ${resp}

EnableDisable User
    [Arguments]  ${id}  ${status}
    Check And Create YNW Session
    ${resp}=    PUT On Session     ynw   /provider/user/${status}/${id}   expected_status=any
    RETURN  ${resp}


Get Spoke Languages
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  ynwConf/spokenLangs  expected_status=any
    RETURN  ${resp}    

CreateVendorCategory

    [Arguments]    ${name}    
    ${data}=  Create Dictionary  name=${name}   
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw    /provider/vendor/category    data=${data}  expected_status=any    headers=${headers}
    RETURN  ${resp}

Get VendorCategory With Filter

    [Arguments]   &{param}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/vendor/category    params=${param}     expected_status=any
    RETURN  ${resp}

CreateVendorStatus

    [Arguments]    ${name}    
    ${data}=  Create Dictionary  name=${name}   
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw    /provider/vendor/status    data=${data}  expected_status=any    headers=${headers}
    RETURN  ${resp}

Get Vendorstatus With Filter

    [Arguments]   &{param}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/vendor/status    params=${param}     expected_status=any
    RETURN  ${resp}

Create Vendor

    [Arguments]    ${vendorCategory}  ${vendorId}  ${vendorName}   ${contactPersonName}    ${address}    ${state}    ${pincode}    ${mobileNo}   ${email}    &{kwargs}
    
    ${contact}=  Create Dictionary   address=${address}   state=${state}  pincode=${pincode}    phoneNumbers=${mobileNo}  emails=${email}

    ${data}=  Create Dictionary  categoryEncId=${vendorCategory}   vendorId=${vendorId}  vendorName=${vendorName}   contactPersonName=${contactPersonName}  contactInfo=${contact}    
    # ...    email=${email}  address=${address}  bankAccountNumber=${bank_accno}    
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw    /provider/vendor    data=${data}  expected_status=any    headers=${headers}
    RETURN  ${resp}

Get vendor by encId

    [Arguments]   ${encId}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/vendor/${encId}     expected_status=any
    RETURN  ${resp}

Get Vendor List with filter
    [Arguments]   &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /provider/vendor    params=${param}    expected_status=any    headers=${headers}
    RETURN  ${resp}

Create Category

    [Arguments]    ${name}  ${categoryType}   
    ${data}=  Create Dictionary  name=${name}   categoryType=${categoryType}   
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw    /provider/jp/finance/category    data=${data}  expected_status=any    headers=${headers}
    RETURN  ${resp}


Create Sample User
    [Arguments]   ${admin}=${bool[0]}

    ${random_ph}=   Random Int   min=10000   max=20000
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+${random_ph}
    clear_users  ${PUSERNAME_U1}
    # Set Test Variable  ${PUSERNAME_U1}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name

    ${resp}=  Create User  ${firstname}  ${lastname}  ${countryCodes[1]}  ${PUSERNAME_U1}   ${userType[0]}  
    Should Be Equal As Strings  ${resp.status_code}  200
    RETURN  ${resp.json()}

# Create Sample User
#     [Arguments]   ${admin}=${bool[0]}
#     ${resp}=  Get Departments
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     IF   '${resp.content}' == '${emptylist}'
#         ${dep_name1}=  FakerLibrary.bs
#         ${dep_code1}=   Random Int  min=100   max=999
#         ${dep_desc1}=   FakerLibrary.word  
#         ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
#         Log  ${resp1.content}
#         Should Be Equal As Strings  ${resp1.status_code}  200
#         Set Test Variable  ${dep_id}  ${resp1.json()}
#     ELSE
#         Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
#     END
#     ${random_ph}=   Random Int   min=10000   max=20000
#     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+${random_ph}
#     clear_users  ${PUSERNAME_U1}
#     # Set Test Variable  ${PUSERNAME_U1}
#     ${firstname}=  FakerLibrary.name
#     ${lastname}=  FakerLibrary.last_name
#     ${address}=  get_address
#     ${dob}=  FakerLibrary.Date
#     #  ${pin}=  get_pincode
#     #  ${resp}=  Get LocationsByPincode     ${pin}
#     # FOR    ${i}    IN RANGE    3
#     #     ${pin}=  get_pincode
#     #     ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
#     #     IF    '${kwstatus}' == 'FAIL'
#     #             Continue For Loop
#     #     ELSE IF    '${kwstatus}' == 'PASS'
#     #             Exit For Loop
#     #     END
#     # END
#     #  Should Be Equal As Strings    ${resp.status_code}    200
#     #  Set Suite Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
#     #  Set Suite Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
#     #  Set Suite Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}   

#     ${pin}  ${city}  ${district}  ${state}=  get_pin_loc 

#     ${random_ph}=   Random Int   min=20000   max=30000
#     ${whpnum}=  Evaluate  ${PUSERNAME}+${random_ph}
#     ${tlgnum}=  Evaluate  ${PUSERNAME}+${random_ph}

#     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${admin}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}  
#     Should Be Equal As Strings  ${resp.status_code}  200
#     RETURN  ${resp.json()}


Get Appointment By Id
    [Arguments]  ${appmntId}
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /provider/appointment/${appmntId}  expected_status=any
    RETURN  ${resp}

Create Label
    [Arguments]  ${l_name}  ${display_name}  ${desc}  ${values}  ${notifications}
    ${data}=  Create Dictionary  label=${l_name}  displayName=${display_name}  description=${desc}  valueSet=${values}  notification=${notifications}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/waitlist/label   data=${data}  expected_status=any
    RETURN  ${resp}

Get Label By Id
    [Arguments]   ${label_id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/label/${label_id}   expected_status=any
    RETURN  ${resp}

Add Label for Appointment
    [Arguments]  ${appmntId}  ${labelname}  ${label_value}
    ${data}=    Create Dictionary  ${labelname}=${label_value}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/appointment/addLabel/${appmntId}  data=${data}  expected_status=any
    RETURN  ${resp}
    
Create ValueSet For Label
    [Arguments]  @{vargs}
    ${len}=  Get Length  ${vargs}
    ${values}=  Create Dictionary  value=${vargs[0]}  shortValue=${vargs[1]}
    ${values_set}=  Create List  ${values}
    FOR    ${index}   IN RANGE   2  ${len}  2
        ${index2}=  Evaluate  ${index}+1
        ${values}=  Create Dictionary  value=${vargs[${index}]}  shortValue=${vargs[${index2}]}
        Append To List  ${values_set}  ${values}
    END
    RETURN  ${values_set}

Create NotificationSet For Label
    [Arguments]  @{vargs}
    ${len}=  Get Length  ${vargs}
    ${values}=  Create Dictionary  values=${vargs[0]}  messages=${vargs[1]}
    ${values_set}=  Create List  ${values}
    FOR    ${index}   IN RANGE   2  ${len}  2
        ${index2}=  Evaluate  ${index}+1
        ${values}=  Create Dictionary  values=${vargs[${index}]}  messages=${vargs[${index2}]}
        Append To List  ${values_set}  ${values}
    END
    RETURN  ${values_set}

Create Sample Label
    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    RETURN  ${resp.json()} 

Create Sample Schedule
    [Arguments]   ${lid}   @{vargs}
    # ${DAY1}=  db.get_date
    # ${DAY2}=  db.db.add_timezone_date  ${tz}  10      
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  db.add_two   ${sTime1}  ${delta}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${consumerParallelServing}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/5}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}   ${consumerParallelServing}   ${lid}  ${duration}  ${bool[0]}  @{vargs}
    Should Be Equal As Strings  ${resp.status_code}  200
    RETURN  ${resp}

AddFamilyMemberByProvider
    #AddFamilyMemberByProviderWithPhoneNo---------${PhoneNo}    ${countryCode}=91
    [Arguments]  ${id}  ${firstname}  ${lastname}  ${dob}  ${gender}    &{kwargs}
    Check And Create YNW Session
    ${data}=  Create Dictionary  parent=${id}  firstName=${firstname}  lastName=${lastname}  dob=${dob}  gender=${gender} 
    FOR  ${key}  ${value}  IN  &{kwargs} 
            Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}
    ${resp}=  POST On Session   ynw   /provider/customers/familyMember   data=${data}  expected_status=any
    RETURN  ${resp}

Get Appointments Today
    # Available Filters:- service, consumer(procon id), firstName, lastName, appointmentEncId, 
    # account, schedule, date, apptdate, apptBy, apptTime, apptStatus, paymentStatus, location,
    # provider(user id), apptstartTime, jaldeeConsumer, rejectReason, cancelReason, appointmentMode
    # gender, dob, department, label, groups, phoneNo, appmtFor, accessScope, apptForId, apptForIds
    # providerOwnConsumerId, team, deptId, businessLoc, internalStatus, countryCode, subServiceData
    [Arguments]  &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/appointment/today  params=${kwargs}  expected_status=any
    RETURN  ${resp}

ListFamilyMemberByProvider
    [Arguments]   ${id}
    Check And Create YNW Session
    ${resp}=  GET On Session   ynw   /provider/customers/familyMember/${id}  expected_status=any
    RETURN  ${resp}

Add Label for Multiple Appointment
    [Arguments]  ${label_dict}  @{appmntId}
    ${len}=  Get Length  ${appmntId}
    ${appmnts}=  Create List
    FOR  ${value}  IN  @{appmntId}
        Append To List  ${appmnts}  ${value}
    END
    ${data}=    Create Dictionary  uuid=${appmnts}  labels=${label_dict}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/appointment/labelBatch  data=${data}  expected_status=any
    RETURN  ${resp}

# Business Profile with schedule
#     # [Arguments]  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${pin}  ${adds}  ${ph1}  ${ph2}  ${email1}  ${lid}   &{kwargs}
#     [Arguments]  ${bName}  ${bDesc}    ${place}  ${longi}  ${latti}  ${g_url}    ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${pin}  ${adds}  ${ph1}  ${ph2}  ${email1}  ${lid}   &{kwargs}
#     ${bs}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}
#     ${bs}=  Create List  ${bs}
#     ${bs}=  Create Dictionary  timespec=${bs}
#     # ${b_loc}=  Create Dictionary  place=${place}  longitude=${longi}  lattitude=${latti}  googleMapUrl=${g_url}  parkingType=${pt}  open24hours=${oh}   bSchedule=${bs}  pinCode=${pin}  address=${adds}  id=${lid}
#     ${b_loc}=  Create Dictionary  place=${place}  longitude=${longi}  lattitude=${latti}  googleMapUrl=${g_url}    bSchedule=${bs}  pinCode=${pin}  address=${adds}  id=${lid}
#         # ${ph_nos}=  Create List  ${ph1}  ${ph2}
#     ${ph_nos}=  db.bus_prof_ph  ${ph1}  ${ph2}
#     ${emails}=  Create List  ${email1}
#     ${data}=  Create Dictionary  businessName=${bName}  businessDesc=${bDesc}  shortName=${shname}  baseLocation=${b_loc}  phoneNumbers=${ph_nos}  emails=${emails}
#     FOR    ${key}    ${value}    IN    &{kwargs}
#         Set To Dictionary 	${data} 	${key}=${value}
#     END
#     ${data}=  json.dumps  ${data}
#     RETURN  ${data}

Create Sample Service with Prepayment
    [Arguments]  ${Service_name}  ${prepayment_amt}  ${servicecharge}  &{kwargs}
    ${desc}=   FakerLibrary.sentence
    ${srv_duration}=   Random Int   min=2   max=2
    ${resp}=  Create Service  ${Service_name}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${prepayment_amt}  ${servicecharge}  ${bool[1]}  ${bool[0]}  &{kwargs}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    RETURN  ${resp.json()}

Get Appointment Schedules
    [Arguments]  &{kwargs}
    # Available filters- id, location, state, provider, batch, name, service, account
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/appointment/schedule  params=${kwargs}  expected_status=any
    RETURN  ${resp}

Get jp finance settings
 
   Check And Create YNW Session
   ${resp}=  GET On Session  ynw  /provider/jp/finance/settings  expected_status=any
   RETURN  ${resp}


Get Appointment Status
    [Arguments]   ${uuid}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/appointment/state/${uuid}  expected_status=any
    RETURN  ${resp}

Appointment Action 
    [Arguments]   ${status}   ${appmntId}   &{kwargs}
    ${data}=  Create Dictionary
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session   ynw  /provider/appointment/statuschange/${status}/${appmntId}  data=${data}  expected_status=any
    RETURN  ${resp}

Get Appointment Note
    [Arguments]   ${uuid}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/appointment/note/${uuid}   expected_status=any
    RETURN  ${resp}

Remove Label from Multiple Appointments
    [Arguments]  ${labelname_list}  @{appmntId}
    ${len}=  Get Length  ${appmntId}
    ${appmnts}=  Create List
    FOR  ${value}  IN  @{appmntId}
        Append To List  ${appmnts}  ${value}
    END
    ${data}=    Create Dictionary  uuid=${appmnts}  labelNames=${labelname_list}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw  /provider/appointment/masslabel  data=${data}  expected_status=any
    RETURN  ${resp}


MultiLocation Domain Providers
    [Arguments]  ${min}=0   ${max}=324
    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    ${domlen}=  Get Length   ${multilocdoms}
    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
    @{dom_list}=  Create List
    @{multiloc_providers}=  Create List

    FOR   ${i}  IN RANGE   ${domlen}
        ${dom}=  Convert To String   ${multilocdoms[${i}]['domain']}
        Append To List   ${dom_list}  ${dom}
    END
    Log   ${dom_list}
   
    FOR   ${a}  IN RANGE   ${min}   ${max}    
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        ${domain}=   Set Variable    ${decrypted_data['sector']}
        ${subdomain}=    Set Variable      ${decrypted_data['subSector']}
        # ${domain}=   Set Variable    ${resp.json()['sector']}
        # ${subdomain}=    Set Variable      ${resp.json()['subSector']}
        Log  ${dom_list}
        ${status} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${dom_list}  ${domain}
        Log Many  ${status} 	${value}
        Run Keyword If  '${status}' == 'PASS'   Append To List   ${multiloc_providers}  ${PUSERNAME${a}}
        ${resp}=  View Waitlist Settings
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
	    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[1]}
        ${resp}=  Toggle Department Disable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    END
    RETURN  ${multiloc_providers}

Get Waitlist By Id
    [Arguments]  ${wid}  &{kwargs}
    ${pro_headers}=  Create Dictionary  &{headers}
    ${pro_params}=   Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${pro_headers}   &{tzheaders}
    Set To Dictionary  ${pro_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/${wid}  params=${pro_params}  expected_status=any
    RETURN  ${resp}

Update User
    [Arguments]  ${id}   ${countryCode}  ${mob_no}  ${user_type}  &{kwargs}
    #${fname}  ${lname}  ${dob}  ${gender}  ${email}    ${pincode}    ${dept_id}  ${sub_domain}  ${admin}  ${whatsApp_countrycode}  ${WhatsApp_num}  ${telegram_countrycode}  ${telegram_num} 
    ${data}=  Create Dictionary  countryCode=${countryCode}  mobileNo=${mob_no}  userType=${user_type}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/user/${id}   data=${data}  expected_status=any
    RETURN  ${resp} 



# Update User
#     [Arguments]  ${id}  ${fname}  ${lname}  ${dob}  ${gender}  ${email}  ${user_type}  ${pincode}  ${countryCode}  ${mob_no}  ${dept_id}  ${sub_domain}  ${admin}  ${whatsApp_countrycode}  ${WhatsApp_num}  ${telegram_countrycode}  ${telegram_num}    &{kwargs}
#     ${whatsAppNum}=   Create Dictionary  countryCode=${whatsApp_countrycode}  number=${WhatsApp_num}
#     ${telegramNum}=  Create Dictionary  countryCode=${telegram_countrycode}  number=${telegram_num}
#     ${data}=  Create Dictionary  firstName=${fname}  lastName=${lname}  dob=${dob}  gender=${gender}  email=${email}  userType=${user_type}  pincode=${pincode}  countryCode=${countryCode}  mobileNo=${mob_no}  deptId=${dept_id}  subdomain=${sub_domain}  admin=${admin}  whatsAppNum=${whatsAppNum}  telegramNum=${telegramNum}
#     FOR    ${key}    ${value}    IN    &{kwargs}
#         Set To Dictionary 	${data} 	${key}=${value}
#     END
#     ${data}=  json.dumps  ${data}
#     Check And Create YNW Session
#     ${resp}=  PUT On Session  ynw  /provider/user/${id}   data=${data}  expected_status=any
#     RETURN  ${resp} 


Update Appointment Schedule
    [Arguments]  ${Id}  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}    ${consumerParallelServing}   ${loc}  ${timeduration}  ${batch}  @{vargs}
    ${data}=  Appointment Schedule  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}    ${consumerParallelServing}   ${loc}  ${timeduration}  ${batch}  @{vargs}
    Set To Dictionary  ${data}  id=${Id}
    Check And Create YNW Session
    ${data}=  json.dumps  ${data}
    ${resp}=  PUT On Session  ynw  /provider/appointment/schedule  data=${data}  expected_status=any
    RETURN  ${resp}


Forgot LoginId

    [Arguments]   &{kwargs}  #... countryCode, phoneNo, email ( countryCode is mandatory with phoneNo )

    ${data}=    json.dumps    ${kwargs}   
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/login/forgot/loginId   data=${data}   expected_status=any
    RETURN  ${resp}
    
Get LoginId

    [Arguments]     ${userid}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/login/suggestion/loginId/${userid}   expected_status=any
    RETURN  ${resp}

List all links of a loginId

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/login/connections   expected_status=any
    RETURN  ${resp}

Switch login

    [Arguments]  ${loginId} 
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/login/switch/${loginId}   expected_status=any
    RETURN  ${resp}
Unlink one login

    [Arguments]  ${loginId} 
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/login/connections/${loginId}   expected_status=any
    RETURN  ${resp} 

Reset LoginId

    [Arguments]  ${userid}    ${loginId} 

    ${data}=  Create Dictionary  userId=${userId}  loginId=${loginId}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/login/reset/loginId   data=${data}   expected_status=any
    RETURN  ${resp}

Reset Password LoginId Login

    [Arguments]     ${oldpassword}  ${password}

    ${data}=    Create Dictionary   oldpassword=${oldpassword}  password=${password}
    ${data}=    json.dumps    ${data} 
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/login/reset/password   data=${data}   expected_status=any
    RETURN  ${resp}


Get Store Type By Filter
    [Arguments]   &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/store/type   params=${param}   expected_status=any
    RETURN  ${resp}

Provider Get Store Type By EncId
    [Arguments]   ${storeTypeId}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/store/type/id/${storeTypeId}      expected_status=any
    RETURN  ${resp}

Get Item Manufacture Filter

    [Arguments]    &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/spitem/settings/manufacturer   params=${param}   expected_status=any
    RETURN  ${resp}

Get Item Tax Filter

    [Arguments]    &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/spitem/settings/tax   params=${param}   expected_status=any
    RETURN  ${resp}

Get Item Type By Filter
    [Arguments]   &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/spitem/settings/type   params=${param}   expected_status=any
    RETURN  ${resp}

Get Item Type Count By Filter

    [Arguments]   &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/spitem/settings/type/count   params=${param}   expected_status=any
    RETURN  ${resp}

Get Item Unit Filter

    [Arguments]    &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/spitem/settings/unit   params=${param}   expected_status=any
    RETURN  ${resp}

Update Business Profile with kwargs
	#Update Business Profile with schedule  Business Profile with schedule  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${pin}  ${adds}  ${ph1}  ${ph2}  ${email1}  ${lid}  &{kwargs}
	#Update Business Profile without phone and email   businessName=${bName}  businessDesc=${bDesc}  shortName=${shname}  baseLocation=${None}  phoneNumbers=${None}  emails=${None}
	#Update Business Profile without details    businessName=${bName}  businessDesc=${bDesc}  shortName=${shname}  baseLocation=${None}  phoneNumbers=${ph1}  emails=${email1}
	#Update Business Profile without schedule  ${bName}  ${bDesc}  ${shortname}  ${place}  ${longi}  ${latti}  ${g_url}  ${parkingType}  ${open24hours}  ${pin}  ${adds}   ${ph1}  ${ph2}  ${email1}  ${lid}
    [Arguments]  &{kwargs}
    ${data}=  Create Dictionary
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bProfile   data=${data}  expected_status=any
    RETURN  ${resp}

Get Item Unit Count Filter

    [Arguments]    &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/spitem/settings/unit/count   params=${param}   expected_status=any
    RETURN  ${resp}


Get Item Category Count By Filter

    [Arguments]   &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/spitem/settings/category/count   params=${param}   expected_status=any
    RETURN  ${resp}

Get Default Catalog Status
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/catalog/statuses   expected_status=any
    RETURN  ${resp}

Get Catalog By Criteria
    [Arguments]   &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/catalog  params=${param}  expected_status=any
    RETURN  ${resp}

Get Item hns Filter

    [Arguments]    &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/spitem/settings/hsn   params=${param}   expected_status=any
    RETURN  ${resp}


Get Item Composition Count Filter 

    [Arguments]    &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/spitem/settings/composition/count   params=${param}   expected_status=any
    RETURN  ${resp}

Get Item Composition Filter

    [Arguments]    &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/spitem/settings/composition   params=${param}   expected_status=any
    RETURN  ${resp}

Get Item Category By Filter
    [Arguments]   &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/spitem/settings/category   params=${param}   expected_status=any
    RETURN  ${resp}

Get Accountsettings
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/account/settings  expected_status=any
    RETURN  ${resp}

Get Store Type By Filter Count
    [Arguments]   &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/store/type/count   params=${param}   expected_status=any
    RETURN  ${resp}

Get Store ByEncId
    [Arguments]   ${Encid}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/store/${Encid}      expected_status=any
    RETURN  ${resp}



Create Store

    [Arguments]  ${name}   ${storeTypeEncId}  ${locationId}  ${emails}  ${number}  ${countryCode}  &{kwargs}
    ${phoneNumber}=  Create Dictionary  number=${number}    countryCode=${countryCode} 
    ${phoneNumbers}=  Create List  ${phoneNumber}
    ${data}=  Create Dictionary  name=${name}   storeTypeEncId=${storeTypeEncId}    locationId=${locationId}    emails=${emails}    phoneNumbers=${phoneNumbers} 
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END   
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/store   data=${data}  expected_status=any
    RETURN  ${resp} 

Create Inventory Catalog

    [Arguments]  ${catalogName}   ${storeEncId}    
    ${data}=  Create Dictionary  catalogName=${catalogName}    storeEncId=${storeEncId}   
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/inventory/inventorycatalog   data=${data}  expected_status=any
    RETURN  ${resp} 

Get Inventory Catalog By EncId
    [Arguments]    ${encId}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/inventory/inventorycatalog/${encId}    expected_status=any
    RETURN  ${resp} 

Create Inventory Catalog Item

    [Arguments]  ${icEncId}   @{vargs}
    Check And Create YNW Session

    ${len}=  Get Length  ${vargs}
    ${data}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        ${values}=  Create Dictionary   spCode=${vargs[${index}]}
        ${item}=  Create Dictionary   item=${values}
        Append To List  ${data}  ${item}

    END
    ${data}=    json.dumps    ${data}  
    ${resp}=  POST On Session  ynw  /provider/inventory/inventorycatalog/${icEncId}/items   data=${data}  expected_status=any
    RETURN  ${resp} 

Get Item Details Inventory

    [Arguments]  ${storeEncId}  ${vendorEncId}  ${inventoryCatalogItem}  ${quantity}  ${freeQuantity}  ${amount}  ${fixedDiscount}  ${discountPercentage}

    ${data}=  Create Dictionary  storeEncId=${storeEncId}    vendorEncId=${vendorEncId}  inventoryCatalogItem=${inventoryCatalogItem}       quantity=${quantity}  freeQuantity=${freeQuantity}  amount=${amount}  fixedDiscount=${fixedDiscount}   discountPercentage=${discountPercentage}  
    ${data}=  json.dumps     ${data}
    
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/inventory/purchase/item/details   data=${data}  expected_status=any
    RETURN  ${resp} 

Create SalesOrder Inventory Catalog-InvMgr True

    [Arguments]  ${store_id}   ${name}   ${invMgmt}   ${inventoryCatalog}   &{kwargs}
    ${encid}=  Create Dictionary   encId=${store_id}   
    ${invcatid}=  Create Dictionary   invCatEncIdList=${inventoryCatalog} 
    ${data}=  Create Dictionary   store=${encid}    name=${name}    invMgmt=${invMgmt}   inventoryCatalog=${invcatid}
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/so/catalog   data=${data}  expected_status=any
    RETURN  ${resp} 

Create SalesOrder Catalog Item-invMgmt True

    [Arguments]   ${catEncId}    ${invMgmt}     ${Inv_Cata_Item_Encid}     ${price}    ${batchPricing}    @{vargs}    &{kwargs}

    ${invCatItem}=     Create Dictionary       encId=${Inv_Cata_Item_Encid}
    ${catalog_details}=  Create Dictionary   invMgmt=${invMgmt}       invCatItem=${invCatItem}    price=${price}     batchPricing=${batchPricing} 
    ${items}=    Create List   ${catalog_details}  
    ${len}=  Get Length  ${vargs}
    FOR    ${index}    IN RANGE    ${len}  
        Append To List  ${items}  ${vargs[${index}]}
    END 
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary   ${catalog_details}   ${key}=${value}
    END
    ${data}=  json.dumps  ${items}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/so/catalog/${catEncId}/items  data=${data}  expected_status=any
    RETURN  ${resp} 


Create SalesOrder Catalog Item-invMgmt False

    [Arguments]   ${catEncId}     ${Inv_Cata_Item_Encid}     ${price}      @{vargs}    &{kwargs}

    ${invCatItem}=     Create Dictionary       encId=${Inv_Cata_Item_Encid}
    ${catalog_details}=  Create Dictionary        spItem=${invCatItem}    price=${price}     
    ${items}=    Create List   ${catalog_details}  
    ${len}=  Get Length  ${vargs}
    FOR    ${index}    IN RANGE    ${len}  
        Append To List  ${items}  ${vargs[${index}]}
    END 
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary   ${catalog_details}   ${key}=${value}
    END
    ${data}=  json.dumps  ${items}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/so/catalog/${catEncId}/items   data=${data}  expected_status=any
    RETURN  ${resp} 
Create SalesOrder Inventory Catalog-InvMgr False

    [Arguments]  ${store_id}   ${name}   ${invMgmt}   &{kwargs}
    ${encid}=  Create Dictionary   encId=${store_id}   
    ${data}=  Create Dictionary   store=${encid}    name=${name}    invMgmt=${invMgmt}   
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/so/catalog   data=${data}  expected_status=any
    RETURN  ${resp} 

Create purchaseItemDtoList

    # .....   discountPercentage or fixedDiscount as kwargs

    [Arguments]  ${inv_cat_encid}  ${quantity}  ${freeQuantity}  ${amount}  ${discountAmount}  ${discountPercentage}  ${fixedDiscount}  ${expiryDate}  ${mrp}  ${batchNo}  ${unitCode}    &{kwargs}
    
    ${inventoryCatalogItem}=    Create Dictionary  encId=${inv_cat_encid} 
    ${data}=                    Create Dictionary  inventoryCatalogItem=${inventoryCatalogItem}  quantity=${quantity}  freeQuantity=${freeQuantity}  amount=${amount}  discountAmount=${discountAmount}  discountPercentage=${discountPercentage}  fixedDiscount=${fixedDiscount}  expiryDate=${expiryDate}  mrp=${mrp}  batchNo=${batchNo}  unitCode=${unitCode}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary   ${data}   ${key}=${value}
    END
    RETURN  ${data}

Create Purchase

    [Arguments]  ${store_encid}  ${invoiceReferenceNo}  ${invoiceDate}  ${vendor_encid}  ${ic_encid}  ${purchaseNote}  ${roundOff}  @{vargs}

    ${purchaseItemDtoList}=     Create List
    ${store}=                   Create Dictionary  encId=${store_encid}
    ${vendor}=                  Create Dictionary  encId=${vendor_encid}  
    ${inventoryCatalog}=        Create Dictionary  encId=${ic_encid} 
    ${data}=                    Create Dictionary  store=${store}  invoiceReferenceNo=${invoiceReferenceNo}  invoiceDate=${invoiceDate}  vendor=${vendor}  inventoryCatalog=${inventoryCatalog}  purchaseNote=${purchaseNote}  roundOff=${roundOff}
    ${len}=     Get Length      ${vargs}
    FOR     ${index}    IN RANGE    ${len}  
        Append To List  ${purchaseItemDtoList}  ${vargs[${index}]}
    END 
    Set To Dictionary   ${data}   purchaseItemDtoList=${purchaseItemDtoList}
    ${data}=  json.dumps     ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/inventory/purchase   data=${data}  expected_status=any
    RETURN  ${resp}

Get Purchase By Uid

    [Arguments]  ${uid}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/inventory/purchase/${uid}    expected_status=any
    RETURN  ${resp} 

Update Purchase Status

    [Arguments]  ${Status}  ${Uid}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/inventory/purchase/${uid}/status/${status}   expected_status=any
    RETURN  ${resp} 

Get Inventory Item Count
    [Arguments]  &{param}    
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/inventory/inventoryitem/store/inventorycatalog/summary/count   params=${param}  expected_status=any
    RETURN  ${resp} 

Get Inventory Item Summary
    [Arguments]  &{param}    
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/inventory/inventoryitem/store/inventorycatalog/summary   params=${param}  expected_status=any
    RETURN  ${resp} 

Get Item Transaction By Filter
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/inventory/transaction  params=${param}  expected_status=any
    RETURN  ${resp}

Get Stock Avaliability

    [Arguments]     ${InvCatalogItemEncId}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/inventory/inventoryitem/invcatalogitem/${InvCatalogItemEncId}  expected_status=any 
    RETURN  ${resp}


Get Inventoryitem
    [Arguments]   ${id}     
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/inventory/inventoryitem/invcatalogitem/${id}   expected_status=any
    RETURN  ${resp} 



Create Sales Order

    [Arguments]  ${SO_Catalog_Id}   ${Pro_Con}   ${OrderFor}   ${originFrom}    ${items}    @{vargs}    &{kwargs}
    # ${Cg_encid}=  Create Dictionary   encId=${SO_Catalog_Id}   
    ${PC}=  Create Dictionary   id=${Pro_Con}   
    ${OrderFor}=  Create Dictionary   id=${OrderFor}   

    ${items}=   Create List    ${items} 
    ${len}=  Get Length  ${vargs}
    FOR    ${index}    IN RANGE    ${len}  
        Append To List  ${items}  ${vargs[${index}]}
    END 
    ${data}=  Create Dictionary   catalog=${SO_Catalog_Id}    providerConsumer=${PC}    orderFor=${OrderFor}   originFrom=${originFrom}      items=${items}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary   ${data}   ${key}=${value}
    END 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/sorder   data=${data}  expected_status=any
    RETURN  ${resp} 

Update SalesOrder Status

    [Arguments]  ${orderEncId}   ${status}   
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/sorder/${orderEncId}/${status}   expected_status=any
    RETURN  ${resp} 

Get store list

    [Arguments]     &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/store   params=${param}   expected_status=any
    RETURN  ${resp}

Get Sales Order
    [Arguments]  ${orderEncId}      
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/sorder/${orderEncId}    expected_status=any
    RETURN  ${resp} 


Update Store

    [Arguments]     ${store_id}   ${name}   ${storeTypeEncId}  ${locationId}  ${emails}  ${number}  ${countryCode}    &{kwargs}
    ${phoneNumber}=  Create Dictionary  number=${number}    countryCode=${countryCode} 
    ${phoneNumbers}=  Create List  ${phoneNumber}
    ${data}=  Create Dictionary  name=${name}   storeTypeEncId=${storeTypeEncId}    locationId=${locationId}    emails=${emails}    phoneNumbers=${phoneNumbers}   
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/store/${store_id}    data=${data}  expected_status=any
    RETURN  ${resp} 


Update store status
    [Arguments]     ${store_id}  ${status}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw   /provider/store/${store_id}/${status}      expected_status=any
    RETURN  ${resp}

Get SalesOrder Catalog List
    [Arguments]  &{param}    
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/so/catalog  params=${param}   expected_status=any
    RETURN  ${resp} 


Get SalesOrder Catalog Count
    [Arguments]  &{param}    
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/so/catalog/count  params=${param}   expected_status=any
    RETURN  ${resp} 

Get SalesOrder Catalog Item List
    [Arguments]  &{param}    
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/so/catalog/item    params=${param}   expected_status=any
    RETURN  ${resp} 

Get SalesOrder Catalog Item Count
    [Arguments]  &{param}    
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/so/catalog/item/count  params=${param}   expected_status=any
    RETURN  ${resp} 

Get list by item encId
    [Arguments]  ${socitemEncId}     
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/so/catalog/item/${socitemEncId}/batch/list    expected_status=any
    RETURN  ${resp} 

Get Batches using Salesordercatalog

    [Arguments]  ${OrderCatEncId}   
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/so/catalog/item/${OrderCatEncId}/forcreateorder   expected_status=any
    RETURN  ${resp} 


Get SalesOrder Catalog By Encid
    [Arguments]  ${catEncId}      
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/so/catalog/${catEncId}    expected_status=any
    RETURN  ${resp} 
Get invoice filter
    [Arguments]  &{param}    
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/so/invoice   params=${param}  expected_status=any
    RETURN  ${resp} 

Get invoice count filter
    [Arguments]  &{param}    
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/so/invoice/count   params=${param}  expected_status=any
    RETURN  ${resp} 

Get Invoice By Order Uid

    [Arguments]  ${orderUid}   
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/so/invoice/order/${orderUid}   expected_status=any
    RETURN  ${resp} 

Get Sales Order Invoice By Id

    [Arguments]  ${invoiceuid}   
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/so/invoice/${invoiceuid}   expected_status=any
    RETURN  ${resp} 

