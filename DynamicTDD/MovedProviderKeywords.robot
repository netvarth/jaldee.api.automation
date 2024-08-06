
######### Moved Keywords #############

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

Account Activation
    [Arguments]  ${email}  ${purpose}
    Check And Create YNW Session
    ${key}=   verify accnt  ${email}  ${purpose}
    ${resp_val}=  POST On Session   ynw  /provider/${key}/verify  expected_status=any
    RETURN  ${resp_val}
This URL Has Been Commented in rest side

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