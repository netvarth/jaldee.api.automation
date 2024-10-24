*** Settings ***
Library           Collections
Library           String
Library           OperatingSystem
Library           /ebs/TDD/CustomKeywords.py
Library           json
Library           db.py
Resource          Keywords.robot

*** Keywords ***

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
    Check Deprication  ${resp}  Update ProviderConsumer
    RETURN  ${resp}

Send Otp For Login
    [Arguments]    ${loginid}  ${accountId}  ${countryCode}=+91  &{kwargs}
    # Check And Create YNW Session
    ${data}=    Create Dictionary    loginId=${loginid}  accountId=${accountId}  countryCode=${countryCode}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${body}=    json.dumps    ${data}
    ${headers2}=     Create Dictionary    Content-Type=application/json    Authorization=browser
    Create Session    ynw    ${BASE_URL}  headers=${headers}  verify=true
    ${resp}=    POST On Session    ynw    /consumer/oauth/identify    data=${body}  headers=${headers2}  expected_status=any
    Check Deprication  ${resp}  Send Otp For Login
    RETURN  ${resp}

Verify Otp For Login
    [Arguments]  ${loginid}  ${purpose}    &{kwargs}

    FOR  ${key}  ${value}  IN  &{kwargs}
        IF  '${key}' == 'JSESSIONYNW'
            ${sessionid}=  Set Variable  ${value}
        END
    END
    ${session_given}=    Get Variable Value    ${sessionid}
    IF  '${session_given}'=='${None}'
        ${key}=   verify accnt  ${loginid}  ${purpose}
    ELSE
        ${key}=   verify accnt  ${loginid}  ${purpose}  ${sessionid}
    END

    Check And Create YNW Session
    ${key}=   verify accnt  ${loginid}  ${purpose}
    ${headers2}=     Create Dictionary    Content-Type=application/json    Authorization=browser
    ${resp}=    POST On Session    ynw    /consumer/oauth/otp/${key}/verify  headers=${headers2}  expected_status=any
    Check Deprication  ${resp}  Verify Otp For Login
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
    ${headers2}=     Create Dictionary    Content-Type=application/json    #Authorization=${token}
    Set To Dictionary 	${headers2} 	&{tzheaders}
    ${has_key}=  Evaluate  'Authorization' in ${kwargs}
    IF  ${has_key}
        ${auth_dict}  ${kwargs}  GetFromDict  Authorization  &{kwargs}
        Set To Dictionary 	${headers2}  &{auth_dict}
    ELSE IF  $token
        Set To Dictionary 	${headers2}  Authorization=${token}
    END
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /consumer    data=${data}  headers=${headers2}   expected_status=any   params=${cons_params}
    Check Deprication  ${resp}  ProviderConsumer SignUp
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
    Check Deprication  ${resp}  ProviderConsumer Login with token
    RETURN  ${resp}

SPConsumer Deactivation
    Check And Create YNW Session
    ${headers2}=     Create Dictionary    Content-Type=application/json  
    ${resp}=    DELETE On Session    ynw    /spconsumer/login/deActivate      expected_status=any
    Check Deprication  ${resp}  SPConsumer Deactivation
    RETURN  ${resp}

Get sp item category Filter
    [Arguments]  ${accountId}   &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/spitem/settings/${accountId}/category   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get sp item category Filter
    RETURN  ${resp} 

Get stores filter
    [Arguments]    &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/store   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get stores filter
    RETURN  ${resp} 


Get stores Count filter
    [Arguments]    &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/store/count   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get stores Count filter
    RETURN  ${resp} 


Create Sample Customer
    [Arguments]  ${accountId}  ${primaryMobileNo}=${EMPTY}

    IF  '''${primaryMobileNo}''' == '''${EMPTY}'''
        IF  "${ENVIRONMENT}" == "local"
            ${PO_Number}=  FakerLibrary.Numerify  %#####
            ${primaryMobileNo}=  Evaluate  ${CUSERNAME}+${PO_Number}
        ELSE
            ${primaryMobileNo}=    Generate Random 555 Number
        END
    END

    ${firstName}=  generate_firstname
    ${lastName}=  FakerLibrary.last_name
    ${email}  Set Variable  ${firstName}${C_Email}.${test_mail}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${primaryMobileNo}  ${accountId}  Authorization=${token}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    # ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}  ${accountId}  ${token} 
    # Log   ${resp.content}
    # Should Be Equal As Strings              ${resp.status_code}   200

    RETURN  ${primaryMobileNo}  ${token}

#----------- CONSUMER ORDER ---------

Get Provider Catalog Item Filter
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/so/catalog/item   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get Provider Catalog Item Filter
    RETURN  ${resp} 


Get Provider Catalog Item Count Filter
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/so/catalog/item/count   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get Provider Catalog Item Count Filter
    RETURN  ${resp} 

Get catalog item by item encId
    [Arguments]     ${accountId}   ${catItemEncId}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /consumer/so/catalog/${accountId}/item/${catItemEncId}  expected_status=any
    Check Deprication  ${resp}  Get catalog item by item encId
    RETURN  ${resp}

Get invoice Using order uid
    [Arguments]     ${accountId}  ${orderUid} 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /consumer/so/invoice/${accountId}/order/${orderUid}/invoice  expected_status=any
    Check Deprication  ${resp}  Get invoice Using order uid
    RETURN  ${resp}

Get invoice Using Invoice uid
    [Arguments]     ${accountId}  ${invoiceUid} 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /consumer/so/invoice/${accountId}/${invoiceUid}  expected_status=any
    Check Deprication  ${resp}  Get invoice Using Invoice uid
    RETURN  ${resp}

GetOrder using uid
    [Arguments]     ${orderUid} 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /consumer/sorder/${orderUid}  expected_status=any
    Check Deprication  ${resp}  GetOrder using uid
    RETURN  ${resp}


###### All Current Keywords above this line #############################################

Get ProviderConsumer
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /spconsumer/     expected_status=any
    Check Deprication  ${resp}  Get ProviderConsumer
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
    Check Deprication  ${resp}  Add FamilyMember For ProviderConsumer
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
    Check Deprication  ${resp}  Get FamilyMember
    RETURN  ${resp}

Delete ProCons FamilyMember
    [Arguments]  ${Famid}
    Check And Create YNW Session  
    ${resp}=  DELETE On Session  ynw  /spconsumer/familyMember/${Famid}  expected_status=any
    Check Deprication  ${resp}  Delete ProCons FamilyMember
    RETURN  ${resp}

Booking History OF Provider Consumer
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /spconsumer/bookings/history     expected_status=any
    Check Deprication  ${resp}  Booking History OF Provider Consumer
    RETURN  ${resp}

Today Booking History OF Provider Consumer
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /spconsumer/bookings/today     expected_status=any
    Check Deprication  ${resp}  Today Booking History OF Provider Consumer
    RETURN  ${resp}

Upcoming Booking details Of Provider Consumer
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /spconsumer/bookings/future     expected_status=any
    Check Deprication  ${resp}  Upcoming Booking details Of Provider Consumer
    RETURN  ${resp}

GetGroupById
	[Arguments]  ${groupid}
	Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /spconsumer/group/${groupid}  expected_status=any 
    Check Deprication  ${resp}  GetGroupById
    RETURN  ${resp}

Get Group
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /spconsumer/group     expected_status=any
    Check Deprication  ${resp}  Get Group
    RETURN  ${resp}

ProviderConsumer View Questionnaire
    # [Arguments]      ${jdid}    ${proid}
    Check And Create YNW Session
    ${resp}=  GET On Session   ynw     /provider/questionnaire/consumer   expected_status=any          
     #url=/provider/providerCustomer/${jdid}?account=${proid}
    Check Deprication  ${resp}  ProviderConsumer View Questionnaire
    RETURN  ${resp}

ProviderConsumer Deactivation
    
    Check And Create YNW Session
    # ${headers2}=     Create Dictionary    Content-Type=application/json  
    ${resp}=    DELETE On Session    ynw    /provider${SPACE}consumer/login/deActivate        expected_status=any
    Check Deprication  ${resp}  ProviderConsumer Deactivation
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
    Check Deprication  ${resp}  Communication between Provider_consumer and provider
    RETURN  ${resp}


Get Communication

    [Arguments]    ${proconId}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /spconsumer/communicate/${proconId}    expected_status=any
    Check Deprication  ${resp}  Get Communication
    RETURN  ${resp}


Update Read Count

    [Arguments]    ${sender}    ${senderUserType}    ${receiver}    ${receiverUserType}    ${messageIds}
    
    ${data}=    Create Dictionary    sender=${sender}    senderUserType=${senderUserType}    receiver=${receiver}    receiverUserType=${receiverUserType}    messageIds=${messageIds}
    ${data}=    json.dumps    ${data}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /spconsumer/communicate/communicationDetailToRead  data=${data}  expected_status=any
    Check Deprication  ${resp}  Update Read Count
    RETURN  ${resp}

Inactive ProviderCustomer 

    [Arguments]     ${consumerId}   ${status}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/customers/${consumerId}/changeStatus/${status}    expected_status=any
    Check Deprication  ${resp}  Inactive ProviderCustomer 
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
    Check Deprication  ${resp}  PC Create Lead LOS
    RETURN  ${resp}

PC Get Lead By Uid LOS

    [Arguments]      ${uid}  

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/los/lead/${uid}  expected_status=any
    Check Deprication  ${resp}  PC Get Lead By Uid LOS
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
    Check Deprication  ${resp}  PC Update Lead LOS
    RETURN  ${resp}

PC Get Lead By Filter LOS
    [Arguments]   &{param}

    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /consumer/los/lead   params=${param}   expected_status=any
    Check Deprication  ${resp}  PC Get Lead By Filter LOS
    RETURN  ${resp}

PC Get Lead Count By Filter LOS
    [Arguments]   &{param}

    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /consumer/los/lead/count   params=${param}   expected_status=any
    Check Deprication  ${resp}  PC Get Lead Count By Filter LOS
    RETURN  ${resp}


Add Profile Photo

    [Arguments]    ${owner}    ${fileName}    ${fileSize}    ${action}    ${caption}    ${fileType}    ${order}

    ${AttachmentsUpload}=  Create List
    ${Attachment}=    Create Dictionary    owner=${owner}    fileName=${fileName}    fileSize=${fileSize}    action=${action}    caption=${caption}    fileType=${fileType}    order=${order}
    Append To List  ${AttachmentsUpload}  ${Attachment}
    
    ${data}=    json.dumps    ${AttachmentsUpload}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /spconsumer/upload/profilePhoto/${owner}  data=${data}  expected_status=any
    Check Deprication  ${resp}  Add Profile Photo
    RETURN  ${resp}



Get Prescription By ProviderConsumer

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /spconsumer/medicalrecord/prescription   expected_status=any   
    Check Deprication  ${resp}  Get Prescription By ProviderConsumer
    RETURN  ${resp}


#----------- CONSUMER ORDER ---------

Get Provider Catalog Filter
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/so/catalog   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get Provider Catalog Filter
    RETURN  ${resp} 


Get Provider Catalog Count Filter
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/so/catalog/count   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get Provider Catalog Count Filter
    RETURN  ${resp} 



Create Cart From Consumerside

    [Arguments]    ${store}    ${providerConsumer}    ${deliveryType}     @{vargs}   &{kwargs}

    ${stores}=  Create Dictionary    encId=${store}
    ${providerConsumer}=  Create Dictionary    id=${providerConsumer}
    
    ${len}=  Get Length  ${vargs}
    ${items}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${items}  ${vargs[${index}]}
    END
    ${data}=    Create Dictionary    store=${stores}    providerConsumer=${providerConsumer}    deliveryType=${deliveryType}    items=${items}  
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary   ${data}   ${key}=${value}
    END  
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /consumer/cart  data=${data}  expected_status=any
    Check Deprication  ${resp}  Create Cart From Consumerside
    RETURN  ${resp}

Update Cart From Consumerside

    [Arguments]    ${cartUid}   ${store}    ${providerConsumer}    ${deliveryType}     @{vargs}   &{kwargs}

    ${stores}=  Create Dictionary    encId=${store}
    ${providerConsumer}=  Create Dictionary    id=${providerConsumer}
    
    ${len}=  Get Length  ${vargs}
    ${items}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${items}  ${vargs[${index}]}
    END
    ${data}=    Create Dictionary    store=${stores}    providerConsumer=${providerConsumer}    deliveryType=${deliveryType}    items=${items}  
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary   ${data}   ${key}=${value}
    END  
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /consumer/cart/update/${cartUid}  data=${data}  expected_status=any
    Check Deprication  ${resp}  Update Cart From Consumerside
    RETURN  ${resp}

Get ConsumerCart By Uid
    [Arguments]     ${cartUid}  

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/cart/${cartUid}  expected_status=any
    Check Deprication  ${resp}  Get ConsumerCart By Uid
    RETURN  ${resp}

Get ConsumerCart With Items By Uid
    [Arguments]     ${cartUid}  

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/cart/${cartUid}/getitems  expected_status=any
    Check Deprication  ${resp}  Get ConsumerCart With Items By Uid
    RETURN  ${resp}

Get Cart By Provider Consumer 
    [Arguments]     ${providerConsumerId} 

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/cart/procon/${providerConsumerId}  expected_status=any
    Check Deprication  ${resp}  Get Cart By Provider Consumer
    RETURN  ${resp}


Update Cart Items

    [Arguments]    ${cartUid}  ${encId}   ${quantity}       &{kwargs}
    ${catalogItem}=    Create Dictionary    encId=${encId} 
    ${data}=    Create Dictionary    catalogItem=${catalogItem}    quantity=${quantity}    
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary   ${data}   ${key}=${value}
    END  
    ${data}=  Create List    ${data}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /consumer/cart/${cartUid}/updateitems  data=${data}  expected_status=any
    Check Deprication  ${resp}  Update Cart Items
    RETURN  ${resp}

Get Cart Item By Uid
    [Arguments]     ${cartItemUid}  

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/cart/item/${cartItemUid}  expected_status=any
    Check Deprication  ${resp}  Get Cart Item By Uid
    RETURN  ${resp}

Get Item List By Cart Uid
    [Arguments]     ${cartUid} 

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /consumer/cart/${cartUid}/item  expected_status=any
    Check Deprication  ${resp}  Get Item List By Cart Uid
    RETURN  ${resp}

Get Cart Item List- Filter
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/cart/item   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get Cart Item List- Filter
    RETURN  ${resp} 

Get Cart Item Count- Filter
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/cart/item/count   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get BusinessDomainsConf
    RETURN  ${resp} 

Remove Item From Cart
    [Arguments]     ${itemUid}

    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw  /consumer/cart/item/${itemUid}  expected_status=any
    Check Deprication  ${resp}  Remove Item From Cart
    RETURN  ${resp}

Remove All Items From Cart
    [Arguments]     ${cartUid}

    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw  /consumer/cart/${cartUid}/removeitems  expected_status=any
    Check Deprication  ${resp}  Remove All Items From Cart
    RETURN  ${resp}

CheckOut Cart Items
    [Arguments]     ${cartUid}   &{kwargs}
    ${data}=    Create Dictionary   
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary   ${data}   ${key}=${value}
    END  
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /consumer/cart/${cartUid}/checkout    data=${data}   expected_status=any
    Check Deprication  ${resp}  CheckOut Cart Items
    RETURN  ${resp}


Get Order- Filter
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/sorder   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get Order- Filter
    RETURN  ${resp} 

Get Order Count- Filter
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/sorder/count   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get Order Count- Filter
    RETURN  ${resp}


Get invoice- Filter
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/so/invoice   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get invoice- Filter
    RETURN  ${resp} 

Get invoice Count- Filter
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/so/invoice   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get invoice Count- Filter
    RETURN  ${resp}

Make Prepayment From Consumerside

    [Arguments]    ${uuid}    ${amount}    ${purpose}  ${accountId}  ${paymentMode}  ${isInternational}  ${mockResponse}   ${custId}     &{kwargs}
    ${data}=    Create Dictionary    uuid=${uuid}    amount=${amount}    purpose=${purpose}    accountId=${accountId}   paymentMode=${paymentMode}  isInternational=${isInternational}  mockResponse=${mockResponse}   custId=${custId} 
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary   ${data}   ${key}=${value}
    END  
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /consumer/so/pay  data=${data}  expected_status=any
    Check Deprication  ${resp}  Make Prepayment From Consumerside
    RETURN  ${resp}


Get sp item category Count Filter
    [Arguments]  ${accountId}   &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/spitem/settings/${accountId}/category/count   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get sp item category Count Filter
    RETURN  ${resp} 

Get sp item type Filter
    [Arguments]  ${accountId}   &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/spitem/settings/${accountId}/type   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get sp item type Filter
    RETURN  ${resp} 

Get sp item type Count Filter
    [Arguments]  ${accountId}   &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/spitem/settings/${accountId}/type/count   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get sp item type Count Filter
    RETURN  ${resp} 

Get sp item group Filter
    [Arguments]  ${accountId}   &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/spitem/settings/${accountId}/group   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get sp item group Filter
    RETURN  ${resp} 

Get sp item group Count Filter
    [Arguments]  ${accountId}   &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/spitem/settings/${accountId}/group/count   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get sp item group Count Filter
    RETURN  ${resp} 

Get sp item manufacturer Filter
    [Arguments]  ${accountId}   &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/spitem/settings/${accountId}/manufacturer   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get sp item manufacturer Filter
    RETURN  ${resp} 

Get sp item manufacturer Count Filter
    [Arguments]  ${accountId}   &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/spitem/settings/${accountId}/manufacturer/count   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get sp item manufacturer Count Filter
    RETURN  ${resp} 



*** Comments ***

####### Moved Keywords ###########

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
    Check Deprication  ${resp}  Send Otp For Login
    RETURN  ${resp}

Verify Otp For Login
    [Arguments]  ${loginid}  ${purpose}    &{kwargs}

    FOR  ${key}  ${value}  IN  &{kwargs}
        IF  '${key}' == 'JSESSIONYNW'
            ${sessionid}=  Set Variable  ${value}
        END
    END
    ${session_given}=    Get Variable Value    ${sessionid}
    IF  '${session_given}'=='${None}'
        ${key}=   verify accnt  ${loginid}  ${purpose}
    ELSE
        ${key}=   verify accnt  ${loginid}  ${purpose}  ${sessionid}
    END

    Check And Create YNW Session
    ${key}=   verify accnt  ${loginid}  ${purpose}
    ${headers2}=     Create Dictionary    Content-Type=application/json    Authorization=browser
    ${resp}=    POST On Session    ynw    /consumer/oauth/otp/${key}/verify  headers=${headers2}  expected_status=any
    Check Deprication  ${resp}  Verify Otp For Login
    RETURN  ${resp}

Customer Logout 
    # [Arguments]    ${token}
    Check And Create YNW Session
    ${headers2}=     Create Dictionary    Content-Type=application/json    #Authorization=${token}
    ${resp}=    DELETE On Session    ynw    /consumer/login       expected_status=any
    Check Deprication  ${resp}  Customer Logout
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
    Check Deprication  ${resp}  ProviderConsumer Login with token
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
    ${headers2}=     Create Dictionary    Content-Type=application/json    #Authorization=${token}
    Set To Dictionary 	${headers2} 	&{tzheaders}
    ${has_key}=  Evaluate  'Authorization' in ${kwargs}
    IF  ${has_key}
        ${auth_dict}  ${kwargs}  GetFromDict  Authorization  &{kwargs}
        Set To Dictionary 	${headers2}  &{auth_dict}
    ELSE IF  $token
        Set To Dictionary 	${headers2}  Authorization=${token}
    END
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /consumer    data=${data}  headers=${headers2}   expected_status=any   params=${cons_params}
    Check Deprication  ${resp}  ProviderConsumer SignUp
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
    ${resp}=  PUT On Session  ynw  /spconsumer  data=${data}  expected_status=any
    Check Deprication  ${resp}  Update ProviderConsumer
    RETURN  ${resp}

Get stores filter
    [Arguments]    &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/store   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get stores filter
    RETURN  ${resp} 


Get stores Count filter
    [Arguments]    &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/store/count   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get stores Count filter
    RETURN  ${resp} 

Get Provider Catalog Item Filter
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/so/catalog/item   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get Provider Catalog Item Filter
    RETURN  ${resp} 


Get Provider Catalog Item Count Filter
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/so/catalog/item/count   params=${param}   expected_status=any
    Check Deprication  ${resp}  Get Provider Catalog Item Count Filter
    RETURN  ${resp} 

Get catalog item by item encId
    [Arguments]     ${accountId}   ${catItemEncId}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /consumer/so/catalog/${accountId}/item/${catItemEncId}  expected_status=any
    Check Deprication  ${resp}  Get catalog item by item encId
    RETURN  ${resp}

Get invoice Using order uid
    [Arguments]     ${accountId}  ${orderUid} 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /consumer/so/invoice/${accountId}/order/${orderUid}/invoice  expected_status=any
    Check Deprication  ${resp}  Get invoice Using order uid
    RETURN  ${resp}

Get invoice Using Invoice uid
    [Arguments]     ${accountId}  ${invoiceUid} 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /consumer/so/invoice/${accountId}/${invoiceUid}  expected_status=any
    Check Deprication  ${resp}  Get invoice Using Invoice uid
    RETURN  ${resp}

GetOrder using uid
    [Arguments]     ${orderUid} 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /consumer/sorder/${orderUid}  expected_status=any
    Check Deprication  ${resp}  GetOrder using uid
    RETURN  ${resp}




