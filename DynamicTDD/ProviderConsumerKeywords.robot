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
    [Return]  ${resp}

Verify Otp For Login
    [Arguments]  ${loginid}  ${purpose}
    Check And Create YNW Session
    ${key}=   verify accnt  ${loginid}  ${purpose}
    ${headers2}=     Create Dictionary    Content-Type=application/json    Authorization=browser
    ${resp}=    POST On Session    ynw    /consumer/oauth/otp/${key}/verify  headers=${headers2}  expected_status=any
    [Return]  ${resp}

Customer Logout 
    # [Arguments]    ${token}
    Check And Create YNW Session
    ${headers2}=     Create Dictionary    Content-Type=application/json    #Authorization=${token}
    ${resp}=    DELETE On Session    ynw    /consumer/login       expected_status=any
    [Return]  ${resp}

ProviderConsumer Login with token
    [Arguments]    ${loginId}  ${accountId}  ${token}  ${countryCode}=+91
    ${login}=    Create Dictionary    loginId=${loginId}  accountId=${accountId}  countryCode=${countryCode}
    ${log}=    json.dumps    ${login}
    ${headers2}=     Create Dictionary    Content-Type=application/json    Authorization=${token}
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw     /consumer/login   headers=${headers2}  data=${log}   expected_status=any 
    [Return]  ${resp}

ProviderConsumer SignUp
    [Arguments]  ${firstName}  ${lastName}  ${email}    ${primaryMobileNo}   ${accountId}   ${countryCode}=91
    ${data1}=   Create Dictionary    primaryMobileNo=${primaryMobileNo}    firstName=${firstName}   lastName=${lastName}  email=${email}  countryCode=${countryCode}
    ${data}=    Create Dictionary    userProfile=${data1}  accountId=${accountId}
    ${data}=    json.dumps    ${data}
    ${headers2}=     Create Dictionary    Content-Type=application/json    Authorization=${token}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /consumer    data=${data}  headers=${headers2}   expected_status=any  
    [Return]  ${resp} 

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
    [Return]  ${resp}

Get ProviderConsumer
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /spconsumer/     expected_status=any
    [Return]  ${resp}

Add FamilyMember For ProviderConsumer
    [Arguments]                   ${firstname}   ${lastname}   ${dob}   ${gender}   ${email}   ${city}   ${state}   ${address}   ${primarynum}   ${alternativenum}   ${countrycode}   ${countryCodet}   ${numbert}   ${countryCodew}   ${numberw}
    Check And Create YNW Session
    ${whatsAppNum}=               Create Dictionary    countryCode=${countryCodet}   number=${numbert}
    ${telegramNum}=               Create Dictionary    countryCode=${countryCodew}   number=${numberw}
    ${userProfile}=               Create Dictionary    firstName=${firstname}   lastName=${lastname}   dob=${dob}   gender=${gender}   email=${email}   city=${city}  state=${state}   address=${address}  primaryMobileNo=${primarynum}   alternativePhoneNo=${alternativenum}   countryCode=${countrycode}  telegramNum=${telegramNum}   whatsAppNum=${whatsAppNum}
    ${data}=                      Create Dictionary    userProfile=${userProfile}
    ${resp}=                      POST On Session  ynw   /spconsumer/familyMember    json=${data}    expected_status=any
    [Return]                      ${resp}

Get FamilyMember
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /spconsumer/familyMember     expected_status=any
    [Return]  ${resp}

Delete ProCons FamilyMember
    [Arguments]  ${Famid}
    Check And Create YNW Session  
    ${resp}=  DELETE On Session  ynw  /spconsumer/familyMember/${Famid}  expected_status=any
    [Return]  ${resp}

Booking History OF Provider Consumer
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /spconsumer/bookings/history     expected_status=any
    [Return]  ${resp}

Today Booking History OF Provider Consumer
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /spconsumer/bookings/today     expected_status=any
    [Return]  ${resp}

Upcoming Booking details Of Provider Consumer
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /spconsumer/bookings/future     expected_status=any
    [Return]  ${resp}

GetGroupById
	[Arguments]  ${groupid}
	Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /spconsumer/group/${groupid}  expected_status=any 
    [Return]  ${resp}

Get Group
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /spconsumer/group     expected_status=any
    [Return]  ${resp}

ProviderConsumer View Questionnaire
    # [Arguments]      ${jdid}    ${proid}
    Check And Create YNW Session
    ${resp}=  GET On Session   ynw     /provider/questionnaire/consumer   expected_status=any          
     #url=/provider/providerCustomer/${jdid}?account=${proid}
    [Return]  ${resp}

ProviderConsumer Deactivation
    
    Check And Create YNW Session
    # ${headers2}=     Create Dictionary    Content-Type=application/json  
    ${resp}=    DELETE On Session    ynw    /provider${SPACE}consumer/login/deActivate        expected_status=any
    [Return]  ${resp}



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
    [Return]  ${resp}


Get Communication

    [Arguments]    ${proconId}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /spconsumer/communicate/${proconId}    expected_status=any
    [Return]  ${resp}


Update Read Count

    [Arguments]    ${sender}    ${senderUserType}    ${receiver}    ${receiverUserType}    ${messageIds}
    
    ${data}=    Create Dictionary    sender=${sender}    senderUserType=${senderUserType}    receiver=${receiver}    receiverUserType=${receiverUserType}    messageIds=${messageIds}
    ${data}=    json.dumps    ${data}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /spconsumer/communicate/communicationDetailToRead  data=${data}  expected_status=any
    [Return]  ${resp}

Inactive ProviderCustomer 

    [Arguments]     ${consumerId}   ${status}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/customers/${consumerId}/changeStatus/${status}    expected_status=any
    [Return]  ${resp}


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
    [Return]  ${resp}

PC Get Lead By Uid LOS

    [Arguments]      ${uid}  

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/los/lead/${uid}  expected_status=any
    [Return]  ${resp}

PC Update Lead LOS    

    [Arguments]  ${uid}  ${description}  ${losProduct}  ${requestedAmount}  &{kwargs}

    ${data}=  Create Dictionary  losProduct=${losProduct}  requestedAmount=${requestedAmount}  description=${description}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary   ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /consumer/los/lead/${uid}   data=${data}  expected_status=any
    [Return]  ${resp}

PC Get Lead By Filter LOS
    [Arguments]   &{param}

    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /consumer/los/lead   params=${param}   expected_status=any
    [Return]  ${resp}

PC Get Lead Count By Filter LOS
    [Arguments]   &{param}

    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /consumer/los/lead/count   params=${param}   expected_status=any
    [Return]  ${resp}


Get provider Waitlist By Id
    [Arguments]  ${uuid}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/waitlist/${uuid}/billdetails   expected_status=any   
    [Return]  ${resp}


Get provider Appt By Id
    [Arguments]  ${uuid}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/appointment/${uuid}/billdetails   expected_status=any   
    [Return]  ${resp}

Get provider Order By Id
    [Arguments]  ${uuid}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/orders/${uuid}/billdetails   expected_status=any   
    [Return]  ${resp}


Add Profile Photo

    [Arguments]    ${owner}    ${fileName}    ${fileSize}    ${action}    ${caption}    ${fileType}    ${order}

    ${AttachmentsUpload}=  Create List
    ${Attachment}=    Create Dictionary    owner=${owner}    fileName=${fileName}    fileSize=${fileSize}    action=${action}    caption=${caption}    fileType=${fileType}    order=${order}
    Append To List  ${AttachmentsUpload}  ${Attachment}
    
    ${data}=    json.dumps    ${AttachmentsUpload}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /spconsumer/upload/profilePhoto/${owner}  data=${data}  expected_status=any
    [Return]  ${resp}