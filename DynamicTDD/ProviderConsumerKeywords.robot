*** Settings ***
Library           Collections
Library           String
Library           OperatingSystem
Library           json
Library           db.py
Resource          Keywords.robot

*** Keywords ***

Send Otp For Login
    [Arguments]    ${loginid}  ${accountId}  ${countryCode}=+91  &{kwargs}
    Check And Create YNW Session
    ${data}=    Create Dictionary    loginId=${loginid}  accountId=${accountId}  countryCode=${countryCode}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${body}=    json.dumps    ${data}
    ${headers2}=     Create Dictionary    Content-Type=application/json    Authorization=browser
    ${resp}=    POST On Session    ynw    /consumer/oauth/identify    data=${body}  headers=${headers2}  expected_status=any
    RETURN  ${resp}

Verify Otp For Login
    [Arguments]  ${loginid}  ${purpose}
    Check And Create YNW Session
    ${key}=   verify accnt  ${loginid}  ${purpose}
    ${headers2}=     Create Dictionary    Content-Type=application/json    Authorization=browser
    ${resp}=    POST On Session    ynw    /consumer/oauth/otp/${key}/verify  headers=${headers2}  expected_status=any
    RETURN  ${resp}

Customer Logout 
    # [Arguments]    ${token}
    Check And Create YNW Session
    ${headers2}=     Create Dictionary    Content-Type=application/json    #Authorization=${token}
    ${resp}=    DELETE On Session    ynw    /consumer/login       expected_status=any
    RETURN  ${resp}

ProviderConsumer Login with token
    [Arguments]    ${loginId}  ${accountId}  ${token}  ${countryCode}=+91  &{kwargs} 
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    # Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    ${login}=    Create Dictionary    loginId=${loginId}  accountId=${accountId}  countryCode=${countryCode}
    ${log}=    json.dumps    ${login}
    ${headers2}=     Create Dictionary    Content-Type=application/json    Authorization=${token}
    Set To Dictionary 	${headers2} 	&{tzheaders}
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw     /consumer/login   headers=${headers2}  data=${log}   expected_status=any   params=${cons_params}
    RETURN  ${resp}

ProviderConsumer SignUp
    [Arguments]  ${firstName}  ${lastName}  ${email}    ${primaryMobileNo}   ${accountId}   ${countryCode}=91   &{kwargs} 
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    # Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    ${data1}=   Create Dictionary    primaryMobileNo=${primaryMobileNo}    firstName=${firstName}   lastName=${lastName}  email=${email}  countryCode=${countryCode}
    ${data}=    Create Dictionary    userProfile=${data1}  accountId=${accountId}
    ${data}=    json.dumps    ${data}
    ${headers2}=     Create Dictionary    Content-Type=application/json    Authorization=${token}
    Set To Dictionary 	${headers2} 	&{tzheaders}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /consumer    data=${data}  headers=${headers2}   expected_status=any   params=${cons_params}
    RETURN  ${resp} 

Update ProviderConsumer 
    [Arguments]    ${cid}    &{kwargs}
    ${items}=  Get Dictionary items  ${kwargs}
    ${data}=  Create Dictionary  id=${c_id}
    FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    Log  ${data}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /spconsumer/  data=${data}  expected_status=any
    RETURN  ${resp}

Get ProviderConsumer
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /spconsumer/     expected_status=any
    RETURN  ${resp}


Add FamilyMember For ProviderConsumer
      [Arguments]   ${firstname}   ${lastname}  ${dob}  ${gender}  ${primarynum}  &{kwargs}
      Check And Create YNW Session

      ${userProfile}=  Create Dictionary    firstName=${firstname}   lastName=${lastname}   dob=${dob}   gender=${gender}   primaryMobileNo=${primarynum}   
      ${data}=   Create Dictionary    userProfile=${userProfile}
      ${whatsApp}=  Create Dictionary
      ${telegram}=  Create Dictionary
      FOR    ${key}    ${value}    IN    &{kwargs}
            IF  "${key}" == "whatsAppNum"
                Set To Dictionary 	${whatsApp} 	number=${value}
            ELSE IF  "${key}" == "whatsAppCC"
                Set To Dictionary 	${whatsApp} 	countryCode=${value}
            ELSE IF  "${key}" == "telegramNum"
                Set To Dictionary 	${telegram} 	countryCode=${value}
            ELSE IF  "${key}" == "telegramCC"
                Set To Dictionary 	${telegram} 	countryCode=${value}
            ELSE
                Set To Dictionary 	${data} 	${key}=${value}
            END
            IF  ${whatsApp} != &{EMPTY}
                Set To Dictionary 	${data} 	whatsAppNum=${whatsApp}
            END
            IF  ${telegram} != &{EMPTY}
                Set To Dictionary 	${data} 	telegramNum=${telegram}
            END

      END
      ${resp}=  POST On Session  ynw   /consumer/familyMember   json=${data}    expected_status=any
      RETURN  ${resp}

# Add FamilyMember For ProviderConsumer
#     [Arguments]                   ${firstname}   ${lastname}   ${dob}   ${gender}   ${email}   ${city}   ${state}   ${address}   ${primarynum}   ${alternativenum}   ${countrycode}   ${countryCodet}   ${numbert}   ${countryCodew}   ${numberw}
#     Check And Create YNW Session
#     ${whatsAppNum}=               Create Dictionary    countryCode=${countryCodet}   number=${numbert}
#     ${telegramNum}=               Create Dictionary    countryCode=${countryCodew}   number=${numberw}
#     ${userProfile}=               Create Dictionary    firstName=${firstname}   lastName=${lastname}   dob=${dob}   gender=${gender}   email=${email}   city=${city}  state=${state}   address=${address}  primaryMobileNo=${primarynum}   alternativePhoneNo=${alternativenum}   countryCode=${countrycode}  telegramNum=${telegramNum}   whatsAppNum=${whatsAppNum}
#     ${data}=                      Create Dictionary    userProfile=${userProfile}
#     ${resp}=                      POST On Session  ynw   /spconsumer/familyMember    json=${data}    expected_status=any
#     RETURN                      ${resp}

Get FamilyMember
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /spconsumer/familyMember     expected_status=any
    RETURN  ${resp}

Delete ProCons FamilyMember
    [Arguments]  ${Famid}
    Check And Create YNW Session  
    ${resp}=  DELETE On Session  ynw  /spconsumer/familyMember/${Famid}  expected_status=any
    RETURN  ${resp}

Booking History OF Provider Consumer
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /spconsumer/bookings/history     expected_status=any
    RETURN  ${resp}

Today Booking History OF Provider Consumer
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /spconsumer/bookings/today     expected_status=any
    RETURN  ${resp}

Upcoming Booking details Of Provider Consumer
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /spconsumer/bookings/future     expected_status=any
    RETURN  ${resp}

GetGroupById
	[Arguments]  ${groupid}
	Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /spconsumer/group/${groupid}  expected_status=any 
    RETURN  ${resp}

Get Group
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /spconsumer/group     expected_status=any
    RETURN  ${resp}

ProviderConsumer View Questionnaire
    # [Arguments]      ${jdid}    ${proid}
    Check And Create YNW Session
    ${resp}=  GET On Session   ynw     /provider/questionnaire/consumer   expected_status=any          
     #url=/provider/providerCustomer/${jdid}?account=${proid}
    RETURN  ${resp}

ProviderConsumer Deactivation
    
    Check And Create YNW Session
    # ${headers2}=     Create Dictionary    Content-Type=application/json  
    ${resp}=    DELETE On Session    ynw    /provider${SPACE}consumer/login/deActivate        expected_status=any
    RETURN  ${resp}



# Provider COnsumer Communicate with provider


Communication between Provider_consumer and provider

    [Arguments]    ${sender}    ${senderUserType}    ${receiver}    ${receiverUserType}    ${communicationMessage}      ${messageType}    @{vargs} 
    
    ${len}=  Get Length  ${vargs}
    ${attachmentList}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${attachmentList}  ${vargs[${index}]}
    END

    ${data}=    Create Dictionary    sender=${sender}    senderUserType=${senderUserType}    receiver=${receiver}    receiverUserType=${receiverUserType}    communicationMessage=${communicationMessage}    messageType=${messageType}    attachmentList=${attachmentList}
    ${data}=    json.dumps    ${data}

    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /spconsumer/communicate/communicationDetail  data=${data}  expected_status=any
    RETURN  ${resp}


Get Communication

    [Arguments]    ${proconId}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /spconsumer/communicate/${proconId}    expected_status=any
    RETURN  ${resp}


Update Read Count

    [Arguments]    ${sender}    ${senderUserType}    ${receiver}    ${receiverUserType}    ${messageIds}
    
    ${data}=    Create Dictionary    sender=${sender}    senderUserType=${senderUserType}    receiver=${receiver}    receiverUserType=${receiverUserType}    messageIds=${messageIds}
    ${data}=    json.dumps    ${data}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /spconsumer/communicate/communicationDetailToRead  data=${data}  expected_status=any
    RETURN  ${resp}

Inactive ProviderCustomer 

    [Arguments]     ${consumerId}   ${status}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/customers/${consumerId}/changeStatus/${status}    expected_status=any
    RETURN  ${resp}


#----------- LOS LEAD ---------

PC Create Lead LOS     
    [Arguments]  ${channel}  ${description}  ${losProduct}  ${requestedAmount}  &{kwargs}

    ${data}=  Create Dictionary  losProduct=${losProduct}  requestedAmount=${requestedAmount}  description=${description}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary   ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /consumer/los/lead/channel/${channel}   data=${data}  expected_status=any
    RETURN  ${resp}

PC Get Lead By Uid LOS

    [Arguments]      ${uid}  

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/los/lead/${uid}  expected_status=any
    RETURN  ${resp}

PC Update Lead LOS    

    [Arguments]  ${uid}  ${description}  ${losProduct}  ${requestedAmount}  &{kwargs}

    ${data}=  Create Dictionary  losProduct=${losProduct}  requestedAmount=${requestedAmount}  description=${description}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary   ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /consumer/los/lead/${uid}   data=${data}  expected_status=any
    RETURN  ${resp}

PC Get Lead By Filter LOS
    [Arguments]   &{param}

    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /consumer/los/lead   params=${param}   expected_status=any
    RETURN  ${resp}

PC Get Lead Count By Filter LOS
    [Arguments]   &{param}

    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /consumer/los/lead/count   params=${param}   expected_status=any
    RETURN  ${resp}


Add Profile Photo

    [Arguments]    ${owner}    ${fileName}    ${fileSize}    ${action}    ${caption}    ${fileType}    ${order}

    ${AttachmentsUpload}=  Create List
    ${Attachment}=    Create Dictionary    owner=${owner}    fileName=${fileName}    fileSize=${fileSize}    action=${action}    caption=${caption}    fileType=${fileType}    order=${order}
    Append To List  ${AttachmentsUpload}  ${Attachment}
    
    ${data}=    json.dumps    ${AttachmentsUpload}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /spconsumer/upload/profilePhoto/${owner}  data=${data}  expected_status=any
    RETURN  ${resp}


Create Family Member   
    [Arguments]  ${firstName}  ${lastName}  ${dob}  ${gender}   ${phoneNo}  ${countryCode}  ${address}  &{kwargs}

    ${data}=  Create Dictionary  firstName=${firstName}  lastName=${lastName}  dob=${dob}   gender=${gender}  phoneNo=${phoneNo}  countryCode=${countryCode}    address=${address}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary   ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /consumer/family/member   data=${data}  expected_status=any
    RETURN  ${resp}

Update Family Members
    [Arguments]   ${id}  ${parent}  ${firstName}  ${lastName}  ${dob}  ${gender}   ${phoneNo}  ${countryCode}  ${address}  &{kwargs}

    ${data}=  Create Dictionary   id=${id}  parent=${parent}  firstName=${firstName}  lastName=${lastName}  dob=${dob}   gender=${gender}  phoneNo=${phoneNo}  countryCode=${countryCode}    address=${address}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary   ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /consumer/family/member   data=${data}  expected_status=any
    RETURN  ${resp}

Get Family Members
    [Arguments]  ${consumerId}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/family/member/${consumerId}   expected_status=any   
    RETURN  ${resp}

Delete Family Members
    [Arguments]  ${memberId}  ${consumerId} 
    Check And Create YNW Session
    ${resp}=    DELETE On Session    ynw    /consumer/family/member/${memberId}/${consumerId}        expected_status=any
    RETURN  ${resp}

Get Family Member By Id
    [Arguments]  ${memberId}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/family/member/details/${memberId}   expected_status=any   
    RETURN  ${resp}

Get Prescription By ProviderConsumer

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /spconsumer/medicalrecord/prescription   expected_status=any   
    RETURN  ${resp}


SPConsumer Deactivation
    
    Check And Create YNW Session
    ${headers2}=     Create Dictionary    Content-Type=application/json  
    ${resp}=    DELETE On Session    ynw    /spconsumer/login/deActivate      expected_status=any
    RETURN  ${resp}

Customer Take Appointment
    [Arguments]    ${service_id}  ${schedule_id}  ${appmtDate}  ${consumerNote}  ${appmtFor}  &{kwargs}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accid}
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule_id}    
    ${data}=    Create Dictionary   service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}
    ${data}=  json.dumps  ${data}
    Log  ${cons_headers}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Log  ${cons_headers}
    Set To Dictionary  ${cons_params}   &{locparam}
    Log  ${cons_params}
    Check And Create YNW Session
    # Set To Dictionary  ${cons_headers}   timeZone=${timeZone}
    # ${resp}=  POST On Session  ynw   url=/consumer/appointment?account=${accId}  data=${data}  expected_status=any   headers=${cons_headers}
    ${resp}=  POST On Session  ynw   url=/consumer/appointment/add  params=${cons_params}  data=${data}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}