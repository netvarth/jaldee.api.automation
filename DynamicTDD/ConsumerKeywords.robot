*** Settings ***
Library           Collections
Library           String
Library           OperatingSystem
Library           json
Library           db.py
Resource          Keywords.robot

*** Keywords ***

Consumer Login
    [Arguments]    ${usname}  ${passwrd}  ${countryCode}=+91
    ${log}=  Login  ${usname}  ${passwrd}   countryCode=${countryCode}
    ${resp}=    POST On Session    ynw    /consumer/login    data=${log}  expected_status=any
    [Return]  ${resp}


Consumer Logout
    Check And Create YNW Session
    ${resp}=    DELETE On Session    ynw    /consumer/login  expected_status=any
    [Return]  ${resp}

    

Send Reset Email
    [arguments]  ${email}  ${countryCode}=+91
    Check And Create YNW Session
    ${data}=    json.dumps    ${countryCode}
    ${resp}=    POST On Session    ynw   /consumer/login/reset/${email}   data=${data}  expected_status=any 
    [Return]  ${resp}


Reset Password
    [Arguments]    ${email}  ${pswd}  ${purpose}  ${countryCode}=+91
    ${key}=  verify accnt  ${email}   ${purpose}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw    /consumer/login/reset/${key}/validate  expected_status=any     
    ${login}=    Create Dictionary    loginId=${email}  password=${pswd}  countryCode=${countryCode}
    ${log}=    json.dumps    ${login}
    ${respk}=  PUT On Session  ynw  /consumer/login/reset/${key}  data=${log}  expected_status=any
    [Return]  ${resp}  ${respk}

    
Consumer Creation
    [Arguments]  ${firstname}  ${lastname}  ${address}  ${primaryNo}  ${alternativeNo}  ${dob}  ${gender}  ${email}  ${countryCode}=+91
    ${usp}=    Create Dictionary   firstName=${firstname}  lastName=${lastname}  address=${address}  primaryMobileNo=${primaryNo}  alternativePhoneNo=${alternativeNo}  dob=${dob}  gender=${gender}  email=${email}  countryCode=${countryCode}
    ${auth}=    Create Dictionary    userProfile=${usp}
    ${apple}=    json.dumps    ${auth}
    [Return]  ${apple}


Consumer SignUp
    [Arguments]  ${firstname}  ${lastname}  ${address}  ${primaryNo}  ${alternativeNo}  ${dob}  ${gender}  ${email}   ${countryCode}=+91
    ${apple}=  Consumer Creation  ${firstname}  ${lastname}  ${address}  ${primaryNo}  ${alternativeNo}  ${dob}  ${gender}  ${email}   countryCode=${countryCode}    
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw    /consumer   data=${apple}  expected_status=any
    [Return]  ${resp}


Consumer Activation
    [Arguments]  ${email}  ${purpose}
    Check And Create YNW Session
    ${key}=   verify accnt  ${email}  ${purpose}
    ${resp_val}=  POST On Session   ynw  /consumer/${key}/verify   expected_status=any
    [Return]  ${resp_val}


Consumer Set Credential
    [Arguments]  ${email}  ${password}  ${purpose}  ${countryCode}=+91
    ${auth}=     Create Dictionary   password=${password}  countryCode=${countryCode}
    ${key}=   verify accnt  ${email}  ${purpose}
    ${apple}=    json.dumps    ${auth}
    ${resp}=    PUT On Session    ynw    /consumer/${key}/activate   data=${apple}  expected_status=any
    [Return]  ${resp}

Send Verify Login Consumer
    [Arguments]  ${loginid}  ${countryCode}=+91
    Check And Create YNW Session
    ${params}=     Create Dictionary   countryCode=${countryCode}
    # ${data}=    json.dumps    ${countryCode}
    ${resp}=  POST On Session    ynw  /consumer/login/verifyLogin/${loginid}   params=${params}   expected_status=any
    [Return]  ${resp}

Check Consumer Exists
    [Arguments]  ${loginid}  ${countryCode}=+91
    Check And Create YNW Session
    ${body}=     Create Dictionary   countryCode=${countryCode}
    ${data}=    json.dumps    ${body}
    ${resp}=  GET On Session    ynw  /consumer/${loginid}/check    data=${data}  expected_status=any
    [Return]  ${resp}

Verify Login Consumer
    [Arguments]  ${loginid}  ${purpose}  ${countryCode}=+91
    Check And Create YNW Session
    ${auth}=     Create Dictionary   loginId=${loginid}  countryCode=${countryCode}
    ${key}=   verify accnt  ${loginid}  ${purpose}
    ${data}=    json.dumps    ${auth}
    ${resp}=    PUT On Session    ynw    /consumer/login/${key}/verifyLogin    data=${data}  expected_status=any
    [Return]  ${resp}


Update Consumer 
    [Arguments]  ${firstname}  ${lastname}  ${address}  ${primaryNo}  ${alternativeNo}  ${dob}  ${gender}  ${email}   ${countryCode}=+91
    ${usp}=    Create Dictionary   firstName=${firstname}  lastName=${lastname}  address=${address}  primaryMobileNo=${primaryNo}  alternativePhoneNo=${alternativeNo}  dob=${dob}  gender=${gender}  email=${email}  countryCode=${countryCode}
    ${auth}=    Create Dictionary    userProfile    ${usp}  
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW Session
    ${resp}=    PATCH On Session    ynw    /consumer/signUp    data=${apple}  expected_status=any
    [Return]  ${resp}

Get Consumer By Id
    [Arguments]  ${email}
    Check And Create YNW Session
    ${id}=  get_id  ${email}
    ${resp}=    GET On Session    ynw   /consumer/${id}  expected_status=any
    [Return]  ${resp}

Consumer Change Password
    [Arguments]   ${old_password}  ${new_password}
    ${auth}=     Create Dictionary   oldpassword=${old_password}  password=${new_password}
    Check And Create YNW Session
    ${apple}=    json.dumps    ${auth}
    ${resp}=    PUT On Session   ynw    /consumer/login/chpwd  data=${apple}  expected_status=any
    [Return]  ${resp}


Consumer Waitlist
    [Arguments]    ${service_id}  ${partySize}  ${consumerNote}  
    ${service}=     Create Dictionary    id=${service_id}
    ${apple}=  Create Dictionary   service=${service}  partySize=${partySize}  consumerNote=${consumerNote}
    [Return]  ${apple}
    

# Add To Waitlist Consumer
#     [Arguments]   ${service_id}  ${partySize}  ${consumerNote}  ${acct_id}
#     ${params}=  Create Dictionary  account=${acct_id}
#     ${apple}=   Consumer Waitlist  ${service_id}  ${partySize}  ${consumerNote}
#     ${apple}=    json.dumps    ${apple}
#     Check And Create YNW Session
#     ${resp}=    POST On Session   ynw    /consumer/waitlist  data=${apple}  params=${params}   expected_status=any
#     [Return]  ${resp}
    

Consumer Add To Waitlist with Phone no
    [Arguments]   ${acct_id}  ${service_id}  ${queueId}  ${date}  ${waitlistPhoneNumber}  ${country_code}  @{vargs}
    ${params}=  Create Dictionary  account=${acct_id}
    ${service}=     Create Dictionary    id=${service_id}
    ${queueId}=  Create Dictionary  id=${queueId}
    ${len}=  Get Length  ${vargs}
    ${consumer}=  Create Dictionary  id=${vargs[0]}
    ${consumerlist}=  Create List  ${consumer}
    FOR    ${index}    IN RANGE  1  ${len}
        ${consumer}=  Create Dictionary  id=${vargs[${index}]}
        Append To List  ${consumerlist}  ${consumer}
    END
    ${apple}=  Create Dictionary   queue=${queueId}  date=${date}  service=${service}  waitlistPhoneNumber=${waitlistPhoneNumber}  waitlistingFor=${consumerlist}  countryCode=${country_code}
    ${apple}=    json.dumps    ${apple}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /consumer/waitlist  data=${apple}  params=${params}   expected_status=any
    [Return]  ${resp}


Consumer Add To WL With Virtual Service
    [Arguments]  ${accId}  ${queueId}  ${date}  ${serviceId}  ${consumerNote}  ${revealPhone}  ${virtualService}  @{vargs} 
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
    ${data}=  Create Dictionary  queue=${queueId}  date=${date}  service=${serviceId}  consumerNote=${consumerNote}  waitlistingFor=${consumerlist}  revealPhone=${revealPhone}   virtualService=${virtualService} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session  ynw  /consumer/waitlist   data=${data}  params=${param}   expected_status=any    
    [Return]  ${resp}


Virtual Service Checkin with Mode
    [Arguments]  ${waitlistMode}  ${accId}  ${queueId}  ${date}  ${serviceId}  ${consumerNote}  ${revealPhone}  ${virtualService}  @{vargs} 
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
    ${data}=  Create Dictionary  waitlistMode=${waitlistMode}  queue=${queueId}  date=${date}  service=${serviceId}  consumerNote=${consumerNote}  waitlistingFor=${consumerlist}  revealPhone=${revealPhone}   virtualService=${virtualService}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session  ynw  /consumer/waitlist   data=${data}  params=${param}   expected_status=any    
    [Return]  ${resp}



Consumer Add To WL With Virtual Service For User
    [Arguments]  ${accId}  ${queueId}  ${date}  ${serviceId}  ${consumerNote}  ${revealPhone}  ${virtualService}  ${u_id}  @{vargs} 
    ${param}=  Create Dictionary  account=${accId}
    ${user_id}=  Create Dictionary  id=${u_id}
    ${queueId}=  Create Dictionary  id=${queueId}
    ${serviceId}=  Create Dictionary  id=${service_id}
    # ${virtualService}=  Create Dictionary  ${CallingModes[1]}=${CallingModes_id1}  ${CallingModes[0]}=${CallingModes_id2}
    
    ${len}=  Get Length  ${vargs}
    ${consumer}=  Create Dictionary  id=${vargs[0]}
    ${consumerlist}=  Create List  ${consumer}
    FOR    ${index}    IN RANGE  1  ${len}
       ${consumer}=  Create Dictionary  id=${vargs[${index}]}
       Append To List  ${consumerlist}  ${consumer}
    END 
    ${data}=  Create Dictionary  queue=${queueId}  date=${date}  service=${serviceId}  consumerNote=${consumerNote}  waitlistingFor=${consumerlist}  revealPhone=${revealPhone}   virtualService=${virtualService}  provider=${user_id} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session  ynw  /consumer/waitlist   data=${data}  params=${param}   expected_status=any    
    [Return]  ${resp}


Add To Waitlist Children Consumer
    [Arguments]   ${service_id}  ${partySize}  ${consumerNote}  ${acct_id}  @{vargs}
    ${params}=  Create Dictionary  account=${acct_id}
    ${apple}=   Consumer Waitlist  ${service_id}  ${partySize}  ${consumerNote}
    ${len}=  Get Length  ${vargs}
    ${child}=  Create Dictionary  name=${vargs[0]}
    ${wchild}=  Create List  ${child}
    :FOR    ${index}    IN RANGE  1  ${len}
    \	${child}=  Create Dictionary  name=${vargs[${index}]} 
    \   Append To List  ${wchild}  ${child}
    Set To Dictionary  ${apple}  waitlistChild=${wchild} 
    ${apple}=    json.dumps    ${apple}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /consumer/waitlist  data=${apple}  params=${params}   expected_status=any
    [Return]  ${resp}

View Waitlistee
    [Arguments]  ${id}  ${acct_id}
    ${params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/waitlist/${id}    params=${params}   expected_status=any
    [Return]  ${resp}

Get Waitlist Consumer
    [Arguments]    &{kwargs}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/waitlist  params=${kwargs}   expected_status=any
    [Return]  ${resp}

Cancel Waitlist
    [Arguments]  ${id}  ${acct_id}    ${CancelReason}=${waitlist_cancl_reasn[4]}    ${CommunicationMessage}=other
    ${params}=  Create Dictionary  account=${acct_id}
    ${auth}=  Create Dictionary   cancelReason=${CancelReason}    communicationMessage=${CommunicationMessage}
    ${auth}=    json.dumps    ${auth}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /consumer/waitlist/cancel/${id}  data=${auth}   params=${params}   expected_status=any
    [Return]  ${resp}

Approximate Waiting Time Consumer
    [Arguments]  ${acct_id}
    ${params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/waitlist/appxWaitingTime  params=${params}   expected_status=any
    [Return]  ${resp}

Update Consumer Profile
    [Arguments]  ${firstname}  ${lastname}  ${address}  ${dob}  ${gender}  &{kwargs}
    ${phone_numbers}=  Get Dictionary items  ${kwargs}
    ${usp}=    Create Dictionary   firstName=${firstname}  lastName=${lastname}  address=${address}  dob=${dob}  gender=${gender}
    FOR  ${key}  ${value}  IN  @{phone_numbers}
        Set To Dictionary  ${usp}   ${key}=${value}
    END
    Log  ${usp}
    ${apple}=    json.dumps    ${usp}
    Check And Create YNW Session
    ${resp}=    PATCH On Session    ynw    /consumer    data=${apple}  expected_status=any
    [Return]  ${resp}


Update Consumer Profile With Emailid
    [Arguments]  ${firstname}  ${lastname}  ${address}  ${dob}  ${gender}  ${email}
    ${usp}=    Create Dictionary   firstName=${firstname}  lastName=${lastname}  address=${address}  dob=${dob}  gender=${gender}  email=${email}
    ${apple}=    json.dumps    ${usp}
    Check And Create YNW Session
    ${resp}=    PATCH On Session    ynw    /consumer    data=${apple}  expected_status=any
    [Return]  ${resp}

Get Waitlist Id Consumer
    [Arguments]   ${date}  ${id}  ${acct_id}
    ${params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/waitlist/${id}/${date}    params=${params}   expected_status=any
    [Return]  ${resp}
    
Reveal Phone Number
	[Arguments]  ${accid}  ${status}   
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /consumer/providers/revealPhoneNo/${accid}/${status}   expected_status=any
    [Return]  ${resp}
    
    
Add Rating
	[Arguments]  ${accid}  ${uuid}  ${stars}  ${feedback}
	${params}=  Create Dictionary  account=${accid}  
	${data}=  Create Dictionary  uuid=${uuid}  stars=${stars}  feedback=${feedback}
    ${data}=  json.dumps  ${data}
	Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /consumer/waitlist/rating  params=${params}  data=${data}  expected_status=any
    [Return]  ${resp} 
    
Update Rating Waitlist
	[Arguments]  ${accid}  ${uuid}  ${stars}  ${feedback}
	${params}=  Create Dictionary  account=${accid}  
	${data}=  Create Dictionary  uuid=${uuid}  stars=${stars}  feedback=${feedback}
    ${data}=  json.dumps  ${data}
	Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /consumer/waitlist/rating  params=${params}  data=${data}  expected_status=any
    [Return]  ${resp} 

Verify Consumer Profile
    [Arguments]  ${resp}  &{kwargs}
    ${items}=  Get Dictionary items  ${kwargs}
    FOR  ${key}  ${value}  IN  @{items}
        Should Be Equal As Strings  ${resp.json()['userProfile']['${key}']}  ${value}
    END


Familymember Creation
    [Arguments]   ${firstname}  ${lastname}  ${dob}  ${gender}
    ${up}=  Create Dictionary  firstName=${firstname}  lastName=${lastname}  dob=${dob}  gender=${gender}
    ${data}=  Create Dictionary   userProfile=${up}
    ${data}=  json.dumps  ${data}
    [Return]  ${data}

AddFamilyMember
    [Arguments]   ${firstname}  ${lastname}  ${dob}  ${gender}
    Check And Create YNW Session
    ${data}=  Familymember Creation   ${firstname}  ${lastname}  ${dob}  ${gender}
    ${resp}=  POST On Session  ynw  /consumer/familyMember   data=${data}  expected_status=any
    [Return]  ${resp}

DeleteFamilyMember
    [Arguments]  ${id}
    Check And Create YNW Session
    ${resp}=    DELETE On Session  ynw  /consumer/familyMember/${id}   expected_status=any
    [Return]  ${resp}

ListFamilyMember
    [Arguments]    &{kwargs}
    Check And Create YNW Session
    ${resp}=  GET On Session   ynw   /consumer/familyMember   params=${kwargs}   expected_status=any
    [Return]  ${resp}

ConsumerFamilyMember Waitlist
    [Arguments]    ${service_id}  ${partySize}  ${consumerNote}  ${mem_id}
    ${service}=     Create Dictionary    id=${service_id}
    ${member}=     Create Dictionary    id=${mem_id}
    ${apple}=  Create Dictionary   service=${service}  partySize=${partySize}  consumerNote=${consumerNote}  waitlistingFor=${member}
    [Return]  ${apple}

Add To Waitlist ConsumerFamilyMember
    [Arguments]   ${service_id}  ${partySize}  ${consumerNote}  ${mem_id}  ${acct_id}
    ${params}=  Create Dictionary  account=${acct_id}
    ${apple}=   ConsumerFamilyMember Waitlist  ${service_id}  ${partySize}  ${consumerNote}  ${mem_id}
    ${apple}=    json.dumps    ${apple}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /consumer/waitlist  data=${apple}  params=${params}   expected_status=any
    [Return]  ${resp}
    
UpdateFamilymember Creation
    [Arguments]   ${mem_id}  ${firstname}  ${lastname}  ${dob}  ${gender}
    ${up}=  Create Dictionary   id=${mem_id}  firstName=${firstname}  lastName=${lastname}  dob=${dob}  gender=${gender}
    ${data}=  Create Dictionary     userProfile=${up}
    ${data}=  json.dumps  ${data}
    [Return]  ${data}

UpdateFamilyMember
    [Arguments]   ${mem_id}  ${firstname}  ${lastname}  ${dob}  ${gender}
    Check And Create YNW Session
    ${data}=  UpdateFamilymember Creation   ${mem_id}  ${firstname}  ${lastname}  ${dob}  ${gender}
    ${resp}=  PUT On Session  ynw  /consumer/familyMember   data=${data}  expected_status=any
    [Return]  ${resp}
    
Add To Waitlist Consumer FamilymemberChildren
    [Arguments]   ${service_id}  ${partySize}  ${consumerNote}  ${mem_id}  ${acct_id}  @{vargs}
    ${params}=  Create Dictionary  account=${acct_id}
    ${apple}=   Consumer FamilyMemberWaitlist  ${service_id}  ${partySize}  ${consumerNote}  ${mem_id}
    ${len}=  Get Length  ${vargs}
    ${child}=  Create Dictionary  name=${vargs[0]}
    ${wchild}=  Create List  ${child}
    :FOR    ${index}    IN RANGE  1  ${len}
    \   ${child}=  Create Dictionary  name=${vargs[${index}]}
    \   Append To List  ${wchild}  ${child}
    Set To Dictionary  ${apple}  waitlistChild=${wchild}
    ${apple}=    json.dumps    ${apple}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /consumer/waitlist  data=${apple}  params=${params}   expected_status=any
    [Return]  ${resp}
    
Get Waitlist Consumer Count
    [Arguments]    &{kwargs}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/waitlist/count  params=${kwargs}   expected_status=any
    [Return]  ${resp}  
    
CommunicationBetweenConsumerAndProvider
	[Arguments]  ${aid}  ${uuid}  ${msg}
	${data}=  Create Dictionary  communicationMessage=${msg}
	${params}=  Create Dictionary  account=${aid}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session  
    ${resp}=  POST On Session  ynw  /consumer/waitlist/communicate/${uuid}  data=${data}  params=${params}   expected_status=any 
    [Return]  ${resp}

    
List Favourite Provider
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/providers   expected_status=any
    [Return]  ${resp}

Add Favourite Provider
    [Arguments]  ${provider_id}  
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /consumer/providers/${provider_id}   expected_status=any
    [Return]  ${resp}

Remove Favourite Provider
    [Arguments]  ${provider_id}
    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw  /consumer/providers/${provider_id}   expected_status=any
    [Return]  ${resp}
    
Get Bill By Consumer
    [Arguments]  ${id}  ${accId}
    ${param}=  Create Dictionary  account=${accId}
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /consumer/bill/${id}    params=${param}   expected_status=any
    [Return]  ${resp}
 
 
Get S3 Url
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/login/s3Url   expected_status=any
    [Return]  ${resp}
    
Get Consumer Communications
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/communications   expected_status=any
    [Return]  ${resp}

# Reading Provider Communications
#     [Arguments]   ${providerId}  ${messageIds}
#     ${data}=  Create Dictionary  providerId=${providerId}  messageIds=${messageIds}
#     ${data}=  json.dumps  ${data}
#     Check And Create YNW Session
#     ${resp}=  PUT On Session  ynw  /consumer/communications/readMessages/${providerId}/${messageIds}   data=${data}  expected_status=any
#     [Return]  ${resp}


Reading Provider Communications
    [Arguments]   ${providerId}   ${acc_id}  ${messageIds}   
    ${params}=  Create Dictionary  account=${acc_id}
    ${data}=  Create Dictionary  providerId=${providerId}  messageIds=${messageIds}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /consumer/communications/readMessages/${providerId}/${messageIds}   data=${data}   params=${params}   expected_status=any
    [Return]  ${resp}


Get Consumer Communications Unread Count
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/communications/unreadCount   expected_status=any
    [Return]  ${resp}


Get Consumer Communications Unread Messages
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/communications/unreadMessages   expected_status=any
    [Return]  ${resp}
    
General Communication with Provider
    [Arguments]    ${communicationMessage}   ${acc_id}
    ${params}=  Create Dictionary  account=${acc_id}
    ${data}=  Create Dictionary  communicationMessage=${communicationMessage}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /consumer/communications   data=${data}   params=${params}   expected_status=any  
    [Return]  ${resp}  	


General Communication with User
    [Arguments]    ${communicationMessage}   ${acc_id}   ${U_id}
    ${params}=  Create Dictionary  account=${acc_id}
    ${data}=  Create Dictionary  provider=${U_id}   communicationMessage=${communicationMessage}
    ${data}=  json.dumps  ${data}   
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /consumer/communications   data=${data}   params=${params}   expected_status=any  
    [Return]  ${resp}  	

    
Add To Waitlist Consumers
    [Arguments]  ${accId}  ${queueId}  ${date}  ${serviceId}  ${consumerNote}  ${revealPhone}  @{vargs}   &{kwargs}
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
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session  ynw  /consumer/waitlist   data=${data}  params=${param}   expected_status=any    
    [Return]  ${resp}


Add To Waitlist Consumers with mode
    [Arguments]  ${waitlistMode}  ${accId}  ${queueId}  ${date}  ${serviceId}  ${consumerNote}  ${revealPhone}  @{vargs}   
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
    Check And Create YNW Session
    ${resp}=    POST On Session  ynw  /consumer/waitlist   data=${data}  params=${param}   expected_status=any    
    [Return]  ${resp}


Add To Waitlist Consumer For User
    [Arguments]  ${accId}  ${queueId}  ${date}  ${serviceId}  ${consumerNote}  ${revealPhone}  ${user_id}  @{vargs}   
    ${param}=  Create Dictionary  account=${accId}
    ${queueId}=  Create Dictionary  id=${queueId}
    ${serviceId}=  Create Dictionary  id=${service_id}  
    ${uid}=  Create Dictionary  id=${user_id}
    
    ${len}=  Get Length  ${vargs}
    ${consumer}=  Create Dictionary  id=${vargs[0]}
    ${consumerlist}=  Create List  ${consumer}
    FOR    ${index}    IN RANGE  1  ${len}
        ${consumer}=  Create Dictionary  id=${vargs[${index}]}
        Append To List  ${consumerlist}  ${consumer}
    END
    ${data}=  Create Dictionary  queue=${queueId}  date=${date}  service=${serviceId}  consumerNote=${consumerNote}  waitlistingFor=${consumerlist}  revealPhone=${revealPhone}  provider=${uid}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session  ynw  /consumer/waitlist   data=${data}  params=${param}   expected_status=any    
    [Return]  ${resp}
    
Delete Waitlist Consumer
    [Arguments]  ${uuid}  ${accId}
    ${param}=  Create Dictionary  account=${accId}
    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw  /consumer/waitlist/${uuid}  params=${param}   expected_status=any
    [Return]  ${resp} 

Get consumer Waitlist By Id
    [Arguments]  ${uuid}  ${accId}
    ${param}=  Create Dictionary  account=${accId}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/waitlist/${uuid}  params=${param}   expected_status=any 
    [Return]  ${resp}

Get consumer Waitlist 
    [Arguments]  &{param} 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/waitlist/  params=${param}   expected_status=any   
    [Return]  ${resp}   

Get Future Waitlist 
    [Arguments]  &{param} 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/waitlist/future  params=${param}   expected_status=any   
    [Return]  ${resp}            
    
    
Get Future Waitlist Count   
    [Arguments]  &{param} 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/waitlist/future/count  params=${param}   expected_status=any   
    [Return]  ${resp} 
    
Get Waiting Time Of queues
    [Arguments]  ${locationId}  ${accId}
    ${param}=  Create Dictionary  account=${accId}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  consumer/waitlist/${locationId}/waitingTime  params=${param}   expected_status=any   
    [Return]  ${resp}

Make Payment Consumer
    [Arguments]  ${amount}  ${mode}  ${uuid}  ${accid}  ${purpose}  ${c_id}
    Check And Create YNW Session
    ${data}=  Create Dictionary  amount=${amount}  paymentMode=${mode}  uuid=${uuid}  accountId=${accid}  purpose=${purpose}  custId=${c_id}
    ${data}=  json.dumps  ${data}
    ${resp}=  POST On Session    ynw  /consumer/payment  data=${data}  expected_status=any
    [Return]  ${resp}

# Make Payment Consumer Mock
#     [Arguments]  ${amount}  ${response}  ${uuid}  ${accid}  ${purpose}  ${c_id}
#     Check And Create YNW Session
#     ${data}=  Create Dictionary  amount=${amount}  paymentMode=Mock  uuid=${uuid}  mockResponse=${response}  accountId=${accid}  purpose=${purpose}  custId=${c_id}  
#     ${data}=  json.dumps  ${data}
#     ${resp}=  POST On Session    ynw  /consumer/payment  data=${data}  expected_status=any
#     [Return]  ${resp}


Make Payment Consumer Mock
    [Arguments]  ${accid}  ${amount}   ${purpose}  ${uuid}    ${serviceId}   ${international}   ${response}  ${c_id}    &{kwargs}
    Check And Create YNW Session
    ${data}=  Create Dictionary  accountId=${accid}  amount=${amount}  paymentMode=Mock  purpose=${purpose}  uuid=${uuid}  
    ...    serviceId=${serviceId}   isInternational=${international}   mockResponse=${response}  custId=${c_id}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    ${resp}=  POST On Session    ynw  /consumer/payment  data=${data}  expected_status=any
    [Return]  ${resp}

Get Payment Consumer
    [Arguments]  ${uuid}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/payment/${uuid}  expected_status=any     
    [Return]  ${resp}

Get conspayment profiles
    [Arguments]   ${accId}
    Check And Create YNW Session
    ${param}=  Create Dictionary  account=${accId}
    ${resp}=   GET On Session  ynw  /consumer/payment/paymentProfiles   params=${param}   expected_status=any
    [Return]  ${resp}


Get conspayment profiles By Id
    [Arguments]   ${accId}    ${profileId}
    Check And Create YNW Session
    ${param}=  Create Dictionary  account=${accId}
    ${resp}=   GET On Session  ynw  /consumer/payment/paymentProfiles/${profileId}   params=${param}   expected_status=any
    [Return]  ${resp}

Get Rating
    [Arguments]   &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/waitlist/rating  params=${kwargs}   expected_status=any
    [Return]  ${resp}

Get Queue By Location and service 
    [Arguments]  ${locationId}  ${serviceId}  ${accId}
    Check And Create YNW Session
    ${param}=  Create Dictionary  account=${accId}
    ${resp}=    GET On Session    ynw  /consumer/waitlist/queues/${locationId}/${serviceId}    params=${param}   expected_status=any     
    [Return]  ${resp}

Get Service By Location   
    [Arguments]  ${locationId}   
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/waitlist/services/${locationId}  expected_status=any     
    [Return]  ${resp} 

Get history Waitlist 
    [Arguments]  &{param} 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/waitlist/history  params=${param}   expected_status=any   
    [Return]  ${resp}      

AddFamilyMemberWithPhNo
    [Arguments]   ${firstname}  ${lastname}  ${Mobile}  ${dob}  ${gender}
    Check And Create YNW Session 
    ${up}=  Create Dictionary  firstName=${firstname}  lastName=${lastname}  primaryMobileNo=${Mobile}  dob=${dob}  gender=${gender}
    ${data}=  Create Dictionary   userProfile=${up}
    ${data}=  json.dumps  ${data}   
    ${resp}=  POST On Session  ynw  /consumer/familyMember   data=${data}  expected_status=any
    [Return]  ${resp}    

Get history Waitlist Count
    [Arguments]  &{param} 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  consumer/waitlist/history/count  params=${param}   expected_status=any   
    [Return]  ${resp}          

Get Queue By Location and service By Date 
    [Arguments]  ${locationId}  ${serviceId}  ${Date}  ${accId}
    Check And Create YNW Session
    ${param}=  Create Dictionary  account=${accId}
    ${resp}=    GET On Session    ynw  /consumer/waitlist/queues/${locationId}/${serviceId}/${Date}  params=${param}   expected_status=any    
    [Return]  ${resp}   

Send Bill Email
    [Arguments]   ${uuid}   
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/bill/email/${uuid}   expected_status=any  
    [Return]  ${resp} 

Apply Jaldee Coupon At Selfpay
    [Arguments]   ${uuid}  ${coupon_code}  ${accId}
    ${param}=  Create Dictionary  account=${accId}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /consumer/jaldee/coupons/${coupon_code}/${uuid}    params=${param}   expected_status=any
    [Return]  ${resp} 


Add To Waitlist Consumers with JCoupon
    [Arguments]  ${accId}  ${queueId}  ${date}  ${serviceId}  ${consumerNote}  ${revealPhone}  ${coupons}  @{vargs}   
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
    ${data}=  Create Dictionary  queue=${queueId}  date=${date}  service=${serviceId}  consumerNote=${consumerNote}  waitlistingFor=${consumerlist}  revealPhone=${revealPhone}  coupons=${coupons} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session  ynw  /consumer/waitlist   data=${data}  params=${param}   expected_status=any    
    [Return]  ${resp}

Get Services in Department By Consumer
    [Arguments]   ${accId}
    ${param}=  Create Dictionary  account=${accId}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/waitlist/department/services  params=${param}   expected_status=any
    [Return]  ${resp}

Enable location sharing by consumer
    [Arguments]  ${pId}   ${waitlist_id}  ${Phonenumber}  ${travelMode}  ${startTimeMode}  ${lattitude}  ${longitude}   ${shareLocStatus}
    ${param}=  Create Dictionary  account=${pId}
    ${geolocation}=  Create Dictionary   latitude=${lattitude}   longitude=${longitude}
    ${data}=   Create Dictionary   waitlistPhonenumber=${Phonenumber}   jaldeeGeoLocation=${geolocation}   travelMode=${travelMode}   shareLocStatus=${shareLocStatus}   jaldeeStartTimeMod=${startTimeMode}
    ${data}=   json.dumps   ${data}
    Check And Create YNW Session  
    ${resp}=    POST On Session    ynw  /consumer/waitlist/saveMyLoc/${waitlist_id}   data=${data}  params=${param}   expected_status=any
    [Return]  ${resp}

Disable location sharing by consumer
    [Arguments]  ${waitlist_id}   ${accid}
    ${param}=  Create Dictionary  account=${accid}
    Check And Create YNW Session  
    ${resp}=    DELETE On Session    ynw  /consumer/waitlist/unshareMyLoc/${waitlist_id}    params=${param}   expected_status=any
    [Return]  ${resp}

# Enable tracking by consumer
#     [Arguments]     ${waitlist_id}
#     Check And Create YNW Session  
#     ${resp}=    PUT On Session    ynw  /consumer/waitlist/start/mytracking/${waitlist_id}   expected_status=any
#     [Return]  ${resp}

Enable tracking by consumer
    [Arguments]    ${waitlist_id}   ${accid}
    ${param}=  Create Dictionary  account=${accid}
    Check And Create YNW Session  
    ${resp}=    PUT On Session    ynw  /consumer/waitlist/start/mytracking/${waitlist_id}     params=${param}   expected_status=any
    [Return]  ${resp}    

Update consumer location
    [Arguments]   ${pId}  ${waitlist_id}  ${lattitude}  ${longitude} 
    ${param}=  Create Dictionary  account=${pId}
    ${data}=  Create Dictionary   latitude=${lattitude}   longitude=${longitude}
    ${data}=   json.dumps   ${data}
    Check And Create YNW Session  
    ${resp}=    PUT On Session    ynw  /consumer/waitlist/update/latlong/${waitlist_id}   data=${data}  params=${param}   expected_status=any
    [Return]  ${resp}

update consumer tavelmode
    [Arguments]   ${pId}  ${waitlist_id}  ${travelMode}
    ${param}=  Create Dictionary  account=${pId}
    ${data}=   Create Dictionary   travelMode=${travelMode}
    ${data}=   json.dumps   ${data}
    Check And Create YNW Session  
    ${resp}=    PUT On Session    ynw  /consumer/waitlist/update/travelmode/${waitlist_id}   data=${data}  params=${param}   expected_status=any
    [Return]  ${resp}

check start status
    [Arguments]   ${pId}  ${waitlist_id}  
    # ${param}=  Create Dictionary  account=${pId}
    # ${data}=   Create Dictionary   travelMode=${travelMode}
    # ${data}=   json.dumps   ${data}
    Check And Create YNW Session  
    ${resp}=    GET On Session   ynw  /consumer/waitlist/status/mytracking/${waitlist_id}   expected_status=any  
    [Return]  ${resp}

Get Appointment Schedules Consumer
    [Arguments]  ${acct_id}
    ${params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/appointment/schedule    params=${params}   expected_status=any
    [Return]  ${resp}

Get Appointment Schedule ById Consumer
    [Arguments]  ${scheduleId}  ${acct_id}
    ${params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/appointment/schedule/${scheduleId}    params=${params}   expected_status=any
    [Return]  ${resp}

Get Appointment Slots By Schedule and Date
    [Arguments]  ${scheduleId}  ${date}  ${acct_id}
    ${params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/appointment/schedule/${scheduleId}/${date}    params=${params}   expected_status=any
    [Return]  ${resp}

Get All Schedule Slots Today By Location and Service
    [Arguments]  ${acct_id}  ${locationId}  ${serviceId}
    ${params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/appointment/schedule/today/location/${locationId}/service/${serviceId}    params=${params}   expected_status=any
    [Return]  ${resp}

Get All Schedule Slots By Date Location and Service
    [Arguments]  ${acct_id}  ${date}  ${locationId}  ${serviceId}
    ${params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/appointment/schedule/date/${date}/location/${locationId}/service/${serviceId}    params=${params}   expected_status=any
    [Return]  ${resp}


Get Next Available Appointment Slots By ScheduleId
    [Arguments]  ${scheduleId}  ${acct_id}
    ${params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/appointment/schedule/nextAvailable/${scheduleId}    params=${params}   expected_status=any
    [Return]  ${resp}


Get Next Available Appointment Time
    [Arguments]  ${acct_id}
    ${params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/appointment/schedule/nextAvailableApptTime    params=${params}   expected_status=any
    [Return]  ${resp}


Get Appmt Schedule By ServiceId and LocationId
    [Arguments]   ${acct_id}    ${locationId}   ${serviceId}  
    ${params}=  Create Dictionary  account=${acct_id}  
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/appointment/schedule/location/${locationId}/service/${serviceId}    params=${params}   expected_status=any
    [Return]  ${resp}


Get Appmt Schedule By ServiceId_LocationId and Date
    [Arguments]   ${acct_id}    ${locationId}   ${serviceId}   ${DATE}  
    ${params}=  Create Dictionary  account=${acct_id}  
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/appointment/schedule/location/${locationId}/service/${serviceId}/date/${DATE}    params=${params}   expected_status=any
    [Return]  ${resp}


Donation By Consumer
    [Arguments]  ${c_id}  ${s_id}  ${loc_id}  ${amt}  ${d_fname}  ${d_lname}  ${d_add}  ${d_ph}  ${d_email}  ${acct_id}  ${countryCode}=+91
    ${params}=  Create Dictionary  account=${acct_id}
    ${con_id}=  Create Dictionary  id=${c_id}
    ${ser_id}=  Create Dictionary  id=${s_id}
    ${location_id}=  Create Dictionary  id=${loc_id}
    ${donar_det}=  Create Dictionary  firstName=${d_fname}  lastName=${d_lname}  address=${d_add}  phoneNo=${d_ph}  email=${d_email}  countryCode=${countryCode}
    ${data}=  Create Dictionary  consumer=${con_id}   service=${ser_id}  location=${location_id}  donationAmount=${amt}  donor=${donar_det}
    ${data}=   json.dumps   ${data}
    Check And Create YNW Session  
    ${resp}=    POST On Session    ynw  /consumer/donation   data=${data}  expected_status=any   params=${params}   expected_status=any
    [Return]  ${resp}

Get Consumer Donation By Id
    [Arguments]  ${id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /consumer/donation/${id}    expected_status=any
    [Return]  ${resp}

Get Donations By Consumer
    [Arguments]    &{kwargs}
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /consumer/donation   params=${kwargs}   expected_status=any
    [Return]  ${resp}

Get Donation Count By Consumer
    [Arguments]    &{kwargs}
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /consumer/donation/count  params=${kwargs}   expected_status=any
    [Return]  ${resp}

Get Donation Service By Consumer
    [Arguments]  ${acct_id}
    ${params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/donation/services    params=${params}   expected_status=any
    [Return]  ${resp}

Get Payment Details
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /consumer/payment     params=${param}   expected_status=any
    [Return]  ${resp}

Get Payment Details By UUId

    [Arguments]  ${uuid}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /consumer/payment/details/${uuid}    expected_status=any 
    [Return]  ${resp}

Get Individual Payment Records

    [Arguments]  ${id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /consumer/payment/${id}   expected_status=any   
    [Return]  ${resp}
    
Take Appointment For Provider 
    [Arguments]    ${accid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${appmtFor}
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}    
    ${data}=    Create Dictionary    appointmentMode=ONLINE_APPOINTMENT   account=${accId}   service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   url=/consumer/appointment?account=${accId}  data=${data}  expected_status=any
    [Return]  ${resp}

Take Phonein Appointment For Provider 
    [Arguments]    ${accid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${appmtFor}
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}    
    ${data}=    Create Dictionary    appointmentMode=PHONE_IN_APPOINTMENT   account=${accId}   service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   url=/consumer/appointment?account=${accId}  data=${data}  expected_status=any
    [Return]  ${resp}


Take Appointment For User 
    [Arguments]    ${accid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${u_id}  ${appmtFor}
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}
    ${uid}=  Create Dictionary  id=${u_id}    
    ${data}=    Create Dictionary    appointmentMode=ONLINE_APPOINTMENT   account=${accId}   service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}   provider=${uid}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   url=/consumer/appointment?account=${accId}  data=${data}  expected_status=any
    [Return]  ${resp}


Take Appointment For Provider with Phone no
    [Arguments]    ${accid}  ${service_id}  ${schedule}  ${appmtDate}  ${phoneNumber}  ${appmtFor}  ${country_code}=+91
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}    
    ${data}=    Create Dictionary    appointmentMode=ONLINE_APPOINTMENT   account=${accId}   service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  phoneNumber=${phoneNumber}  countryCode=${country_code}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   url=/consumer/appointment?account=${accId}  data=${data}  expected_status=any
    [Return]  ${resp}



Take Virtual Service Appointment For Provider 
    [Arguments]    ${accid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${CallingModes}  ${CallingModes_id1}  ${appmtFor}
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule} 
    ${virtualService}=  Create Dictionary   ${CallingModes}=${CallingModes_id1}    
    ${data}=    Create Dictionary    appointmentMode=ONLINE_APPOINTMENT   account=${accId}   service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}   virtualService=${virtualService}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   url=/consumer/appointment?account=${accId}  data=${data}  expected_status=any
    [Return]  ${resp}


Phone-in Virtual Service Appointment For Provider 
    [Arguments]    ${accid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${CallingModes}  ${CallingModes_id1}  ${appmtFor}
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule} 
    ${virtualService}=  Create Dictionary   ${CallingModes}=${CallingModes_id1}    
    ${data}=    Create Dictionary    appointmentMode=PHONE_IN_APPOINTMENT   account=${accId}   service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}   virtualService=${virtualService}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   url=/consumer/appointment?account=${accId}  data=${data}  expected_status=any
    [Return]  ${resp}



Take Virtual Service Appointment For User 
    [Arguments]    ${accid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${CallingModes}  ${CallingModes_id1}  ${u_id}  ${appmtFor}
    ${user_id}=  Create Dictionary  id=${u_id}
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule} 
    ${virtualService}=  Create Dictionary   ${CallingModes}=${CallingModes_id1}    
    ${data}=    Create Dictionary    appointmentMode=ONLINE_APPOINTMENT   account=${accId}   service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}   virtualService=${virtualService}  provider=${user_id}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   url=/consumer/appointment?account=${accId}  data=${data}  expected_status=any
    [Return]  ${resp}



Take Appointment with ApptMode For Provider
    [Arguments]    ${apptMode}   ${accid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${appmtFor}
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}    
    ${data}=    Create Dictionary    appointmentMode=${apptMode}   account=${accId}   service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   url=/consumer/appointment?account=${accId}  data=${data}  expected_status=any
    [Return]  ${resp}

Get consumer Appointment By Id
    [Arguments]   ${accId}  ${appmntId}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  url=/consumer/appointment/${appmntId}?account=${accId}   expected_status=any
    [Return]  ${resp}

Get Consumer Waitlist By EncodedId
    [Arguments]    ${W_Enc_id}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /consumer/waitlist/enc/${W_Enc_id}   expected_status=any
    [Return]  ${resp}
    
Get Consumer Appointment By EncodedId
    [Arguments]    ${A_Enc_id}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /consumer/appointment/enc/${A_Enc_id}   expected_status=any
    [Return]  ${resp} 
  
Cancel Appointment By Consumer
    [Arguments]  ${appmntId}  ${acct_id}
    ${params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /consumer/appointment/cancel/${appmntId}   params=${params}   expected_status=any
    [Return]  ${resp}

Get Consumer Appointments Today
    [Arguments]  &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /consumer/appointment/today  params=${kwargs}   expected_status=any
    [Return]  ${resp}

Get Appmt Service By LocationId
    [Arguments]   ${locationId}   
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/appointment/service/${locationId}   expected_status=any 
    [Return]  ${resp}

Get Consumer Appmt Today Count
    [Arguments]  &{kwargs}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/appointment/today/count  params=${kwargs}   expected_status=any
    [Return]  ${resp}

Get Consumer Appointments 
    [Arguments]  &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /consumer/appointment  params=${kwargs}   expected_status=any
    [Return]  ${resp}

#Livetracking
Enable apptment SaveMyLocation by consumer
    [Arguments]  ${pId}   ${Appmt_id}  ${Phonenumber}  ${travelMode}  ${startTimeMode}  ${lattitude}  ${longitude}   ${shareLocStatus}
    ${param}=  Create Dictionary  account=${pId}
    ${geolocation}=  Create Dictionary   latitude=${lattitude}   longitude=${longitude}
    ${data}=   Create Dictionary   apptPhonenumber=${Phonenumber}   jaldeeGeoLocation=${geolocation}   travelMode=${travelMode}   shareLocStatus=${shareLocStatus}   jaldeeStartTimeMod=${startTimeMode}
    ${data}=   json.dumps   ${data}
    Check And Create YNW Session  
    ${resp}=    POST On Session    ynw     /consumer/appointment/saveMyLoc/${Appmt_id}   data=${data}  params=${param}   expected_status=any
    [Return]  ${resp}

Locate apptment consumer
    [Arguments]   ${appmt_id}
    Check And Create YNW Session  
    ${resp}=    PUT On Session    ynw  /consumer/appointment/live/locate/distance/time/${appmt_id}   expected_status=any
    [Return]  ${resp}


Start apptment tracking by consumer
    [Arguments]   ${accId}   ${appmt_id}
    Check And Create YNW Session  
    ${resp}=    PUT On Session    ynw  url=/consumer/appointment/start/mytracking/${appmt_id}?account=${accId}   expected_status=any
    [Return]  ${resp}

Stop apptment tracking by consumer
    [Arguments]   ${appmt_id}
    Check And Create YNW Session  
    ${resp}=    DELETE On Session    ynw  /consumer/appointment/stop/mytracking/${appmt_id}   expected_status=any
    [Return]  ${resp}

Get apptment Livetrack Status
    [Arguments]   ${appmt_id}
    Check And Create YNW Session  
    ${resp}=    GET On Session    ynw  /consumer/appointment/status/mytracking/${appmt_id}   expected_status=any
    [Return]  ${resp}


Disable apptment unshareMylocation by consumer
    [Arguments]  ${accId}   ${appmt_id}
    Check And Create YNW Session  
    ${resp}=    DELETE On Session    ynw  url=/consumer/appointment/unshareMyLoc/${appmt_id}?account=${accId}   expected_status=any
    [Return]  ${resp}


Update Consumer apptment latlong
    [Arguments]   ${pId}  ${appmt_id}  ${lattitude}  ${longitude} 
    ${param}=  Create Dictionary  account=${pId}
    ${data}=  Create Dictionary   latitude=${lattitude}   longitude=${longitude}
    ${data}=   json.dumps   ${data}
    Check And Create YNW Session  
    ${resp}=    PUT On Session    ynw   /consumer/appointment/update/latlong/${appmt_id}   data=${data}  params=${param}   expected_status=any
    [Return]  ${resp}
    
Update Consumer apptment MyLocation
    [Arguments]   ${pId}  ${appmt_id}  ${lattitude}  ${longitude} 
    ${param}=  Create Dictionary  account=${pId}
    ${data}=  Create Dictionary   latitude=${lattitude}   longitude=${longitude}
    ${data}=   json.dumps   ${data}
    Check And Create YNW Session  
    ${resp}=    PUT On Session    ynw   /consumer/appointment/updateMyLoc/${appmt_id}   data=${data}  params=${param}   expected_status=any
    [Return]  ${resp}

Update consumer apptment tavelmode
    [Arguments]   ${pId}  ${appmt_id}  ${travelMode}
    ${param}=  Create Dictionary  account=${pId}
    ${data}=   Create Dictionary   travelMode=${travelMode}
    ${data}=   json.dumps   ${data}
    Check And Create YNW Session  
    ${resp}=    PUT On Session    ynw  /consumer/appointment/update/travelmode/${appmt_id}   data=${data}  params=${param}   expected_status=any
    [Return]  ${resp}

Get Consumer Future Appointments
    [Arguments]   &{kwargs}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/appointment/future    params=${kwargs}   expected_status=any
    [Return]  ${resp}
    
Get Consumer Future Appointments Count
    [Arguments]    &{kwargs}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/appointment/future/count   params=${kwargs}   expected_status=any
    [Return]  ${resp}

Add Appointment Rating
	[Arguments]  ${accid}  ${uuid}  ${stars}  ${feedback}
	${params}=  Create Dictionary  account=${accid}  
	${data}=  Create Dictionary  uuid=${uuid}  stars=${stars}  feedback=${feedback}
    ${data}=  json.dumps  ${data}
	Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /consumer/appointment/rating  params=${params}  data=${data}  expected_status=any
    [Return]  ${resp}

Update Appointment Rating
	[Arguments]  ${accid}  ${uuid}  ${stars}  ${feedback}
	${params}=  Create Dictionary  account=${accid}  
	${data}=  Create Dictionary  uuid=${uuid}  stars=${stars}  feedback=${feedback}
    ${data}=  json.dumps  ${data}
	Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /consumer/appointment/rating  params=${params}  data=${data}  expected_status=any
    [Return]  ${resp} 

Get Appointment Rating
    [Arguments]   &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/appointment/rating  params=${kwargs}   expected_status=any
    [Return]  ${resp}
   
Get Consumer Appointments History
    [Arguments]    &{kwargs}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/appointment/history   params=${kwargs}   expected_status=any
    [Return]  ${resp}
    
Get Consumer Appointments History Count
    [Arguments]    &{kwargs}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/appointment/history/count   params=${kwargs}   expected_status=any
    [Return]  ${resp}

Get Waitlist Meeting Details
    [Arguments]  ${uid}  ${mode}  ${acc}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  url=/consumer/waitlist/${uid}/meetingDetails/${mode}?account=${acc}   expected_status=any
    [Return]  ${resp}

Get Appointment Meeting Details
    [Arguments]  ${uid}  ${mode}  ${acc}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  url=/consumer/appointment/${uid}/meetingDetails/${mode}?account=${acc}   expected_status=any
    [Return]  ${resp}

Availability Of Queue By Consumer
    [Arguments]  ${locationId}  ${serviceId}  ${accId}
    ${param}=  Create Dictionary      account=${accId}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /consumer/waitlist/queues/available/${locationId}/${serviceId}   params=${param}   expected_status=any     
    [Return]  ${resp}


Reschedule Appointment
    [Arguments]  ${acc_id}   ${appt_id}   ${time_slot}   ${date}  ${sch_id}
    ${params}=  Create Dictionary  account=${acc_id}
    ${data}=  Create Dictionary  uid=${appt_id}   time=${time_slot}  date=${date}   schedule=${sch_id}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session  
    ${resp}=  PUT On Session   ynw   /consumer/appointment/reschedule   params=${params}  data=${data}  expected_status=any
    [Return]  ${resp}
    

Reschedule Waitlist
    [Arguments]  ${acc_id}   ${wl_id}   ${date}   ${q_id}
    ${params}=  Create Dictionary  account=${acc_id}
    ${data}=  Create Dictionary   ynwUuid=${wl_id}  date=${date}  queue=${q_id} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session  
    ${resp}=  PUT On Session   ynw   /consumer/waitlist/reschedule   params=${params}  data=${data}  expected_status=any
    [Return]  ${resp}


Get consumer Appointment MR By Id
    [Arguments]     ${appmntId}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/appointment/mr/${appmntId}   expected_status=any
    [Return]  ${resp}


Get consumer Waitlist MR By Id
    [Arguments]     ${uuid}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/waitlist/mr/${uuid}   expected_status=any
    [Return]  ${resp}


Update Consumer Delivery Address
    [Arguments]  ${phoneNumber}  ${firstName}  ${lastName}  ${email}  ${address}  ${city}   ${postalCode}   ${landMark}   ${countryCode}=+91  
    ${deliveryaddress}=    Create Dictionary  phoneNumber=${phoneNumber}  firstName=${firstName}  lastName=${lastName}  email=${email}  address=${address}  city=${city}  postalCode=${postalCode}  landMark=${landMark}  countryCode=${countryCode}
    ${data}=  Create List   ${deliveryaddress}
    ${data}=   json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /consumer/deliveryAddress    data=${data}  expected_status=any
    [Return]  ${resp}


Get Consumer Delivery Address
    [Arguments]    &{kwargs}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/deliveryAddress   params=${kwargs}   expected_status=any
    [Return]  ${resp}

# -------------------------

Create Order For HomeDelivery
    [Arguments]   ${Cookie}   ${accId}   ${orderFor}    ${CatalogId}   ${homeDelivery}    ${homeDeliveryAddress}  ${sTime1}    ${eTime1}   ${orderDate}    ${phoneNumber}    ${email}  ${countryCode}  ${coupons}  @{vargs}        
    ${catalog}=  Create Dictionary  id=${CatalogId}
    ${orderFor}=  Create Dictionary  id=${orderFor}
    ${timeSlot}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    # ${coupons}=  Create List
    ${len}=  Get Length  ${vargs}
    ${items}=  Create Dictionary  id=${vargs[0]}  quantity=${vargs[1]}
    ${orderitem}=  Create List  ${items}
    FOR    ${index}   IN RANGE   2  ${len}  2
        ${index2}=  Evaluate  ${index}+1
        ${items}=  Create Dictionary  id=${vargs[${index}]}  quantity=${vargs[${index2}]}
        Append To List  ${orderitem}  ${items}
    END

    ${order}=  Create Dictionary  homeDelivery=${homeDelivery}  homeDeliveryAddress=${homeDeliveryAddress}   catalog=${catalog}  orderFor=${orderFor}    orderItem=${orderitem}   orderDate=${orderDate}   timeSlot=${timeSlot}  phoneNumber=${phoneNumber}  countryCode=${countryCode}  email=${email}  coupons=${coupons}
    ${resp}=  ShoppingCartUpload   ${Cookie}   ${accId}   ${order}
    [Return]  ${resp} 


Create Order For Pickup
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
    ${resp}=  ShoppingCartUpload   ${Cookie}   ${accId}   ${order}
    [Return]  ${resp} 


Create Order For Electronic Delivery
    [Arguments]   ${Cookie}   ${accId}   ${orderFor}    ${CatalogId}   ${orderDate}    ${phoneNumber}    ${email}  ${countryCode}  ${coupons}  @{vargs}        
    ${catalog}=  Create Dictionary  id=${CatalogId}
    ${orderFor}=  Create Dictionary  id=${orderFor}
    ${len}=  Get Length  ${vargs}
    ${items}=  Create Dictionary  id=${vargs[0]}  quantity=${vargs[1]}
    ${orderitem}=  Create List  ${items}
    FOR    ${index}   IN RANGE   2  ${len}  2
        ${index2}=  Evaluate  ${index}+1
        ${items}=  Create Dictionary  id=${vargs[${index}]}  quantity=${vargs[${index2}]}
        Append To List  ${orderitem}  ${items}
    END

    ${order}=  Create Dictionary    catalog=${catalog}  orderFor=${orderFor}    orderItem=${orderitem}   orderDate=${orderDate}   phoneNumber=${phoneNumber}  countryCode=${countryCode}  email=${email}  coupons=${coupons}
    ${resp}=  ShoppingCartUpload   ${Cookie}   ${accId}   ${order}
    [Return]  ${resp} 


Get Cart Details
    [Arguments]   ${accId}   ${CatalogId}   ${homeDelivery}  ${orderDate}   ${coupons}  @{vargs}      
    ${catalog}=  Create Dictionary  id=${CatalogId}
    ${len}=  Get Length  ${vargs}
    ${items}=  Create Dictionary  id=${vargs[0]}  quantity=${vargs[1]}
    ${orderitem}=  Create List  ${items}
    FOR    ${index}   IN RANGE   2  ${len}  2
        ${index2}=  Evaluate  ${index}+1
        ${items}=  Create Dictionary  id=${vargs[${index}]}  quantity=${vargs[${index2}]}
        Append To List  ${orderitem}  ${items}
    END
    ${data}=    Create Dictionary    catalog=${catalog}   orderItem=${orderitem}  orderDate=${orderDate}  coupons=${coupons}   homeDelivery=${homeDelivery} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   url=/consumer/orders/amount?account=${accId}  data=${data}  expected_status=any
    [Return]  ${resp}



Upload ShoppingList Image for Pickup
    [Arguments]   ${cookie}   ${accId}   ${caption}   ${orderFor}    ${CatalogId}   ${storePickup}    ${Date}    ${sTime1}    ${eTime1}   ${phoneNumber}    ${email}   
    ${catalog}=  Create Dictionary  id=${CatalogId}
    ${orderFor}=  Create Dictionary  id=${orderFor}
    ${timeSlot}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${order}=  Create Dictionary  storePickup=${storePickup}  catalog=${catalog}  orderFor=${orderFor}  orderDate=${Date}   timeSlot=${timeSlot}  phoneNumber=${phoneNumber}  countryCode=+91  email=${email}
    ${resp}=  OrderImageUpload   ${Cookie}   ${accId}   ${caption}   ${order}
    [Return]  ${resp} 


Upload ShoppingList Image for HomeDelivery
    [Arguments]   ${cookie}   ${accId}   ${caption}   ${orderFor}    ${CatalogId}   ${homeDelivery}    ${homeDeliveryAddress}  ${Date}    ${sTime1}    ${eTime1}   ${phoneNumber}    ${email}   @{vargs}  
    ${catalog}=  Create Dictionary  id=${CatalogId}
    ${orderFor}=  Create Dictionary  id=${orderFor}
    ${timeSlot}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${len}=  Get Length  ${vargs}
    ${coupons}=  Create List
    FOR    ${index}    IN RANGE  0  ${len}
        Append To List  ${coupons}  ${vargs[${index}]}
    END
    ${order}=  Create Dictionary  homeDelivery=${homeDelivery}  homeDeliveryAddress=${homeDeliveryAddress}   catalog=${catalog}  orderFor=${orderFor}  orderDate=${Date}   timeSlot=${timeSlot}  phoneNumber=${phoneNumber}  countryCode=+91  email=${email}  coupons=${coupons}
    ${resp}=  OrderImageUpload   ${Cookie}   ${accId}   ${caption}   ${order}
    [Return]  ${resp} 


Get Order By Id
    [Arguments]    ${accId}   ${uuid}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  url=/consumer/orders/${uuid}?account=${accId}   expected_status=any
    [Return]  ${resp}


Get Order By Criteria
    [Arguments]   &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/orders  params=${kwargs}   expected_status=any
    [Return]  ${resp}


Get Consumer Order Count By Criteria
    [Arguments]   &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/orders/count  params=${kwargs}   expected_status=any
    [Return]  ${resp}


Get Catalog By AccId
    [Arguments]    ${accId} 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/orders/catalogs/${accId}   expected_status=any
    [Return]  ${resp}


Get Pickup Dates By Catalog
    [Arguments]   ${accId}   ${catalogId} 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   url=/consumer/orders/catalogs/pickUp/dates/${catalogId}?account=${accId}   expected_status=any
    [Return]  ${resp}


Get HomeDelivery Dates By Catalog
    [Arguments]   ${accId}  ${catalogId} 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   url=/consumer/orders/catalogs/delivery/dates/${catalogId}?account=${accId}   expected_status=any
    [Return]  ${resp}


Get Future Order 
    [Arguments]   &{kwargs} 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/orders/future  params=${kwargs}   expected_status=any   
    [Return]  ${resp}            
    
    
Get Future Order Count 
    [Arguments]  &{kwargs} 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/orders/future/count  params=${kwargs}   expected_status=any   
    [Return]  ${resp} 


Get StoreContact Info
    [Arguments]  ${accId} 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/orders/settings/store/contact/info/${accId}   expected_status=any
    [Return]  ${resp}


Get Order Settings of Provider
    [Arguments]  ${accId} 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  url=/consumer/orders/settings?account=${accId}   expected_status=any
    [Return]  ${resp}


Update Email For Order
    [Arguments]  ${accId}   ${uid}   ${email} 
    ${email}=  json.dumps  ${email} 
    Check And Create YNW Session  
    ${resp}=  PUT On Session   ynw   url=/consumer/orders/${uid}/email?account=${accId}   data=${email}   expected_status=any 
    [Return]  ${resp}


Get Item By Catalog
    [Arguments]    ${catalogId}  ${itemId}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/orders/catalog/${catalogId}/item/${itemId}   expected_status=any

    [Return]  ${resp}


Cancel Order By Consumer
    [Arguments]  ${accountId}   ${uid}  
    Check And Create YNW Session  
    ${resp}=  PUT On Session   ynw   url=/consumer/orders/${uid}?account=${accountId}   expected_status=any
    [Return]  ${resp}


Get Order By EncodedId
    [Arguments]    ${encId}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /consumer/orders/enc/${encId}   expected_status=any
    [Return]  ${resp} 

 
Get Consumer Order History 
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /consumer/orders/history  params=${param}   expected_status=any
    [Return]  ${resp}


Get Consumer Order History Count
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/orders/history/count  params=${param}   expected_status=any
    [Return]  ${resp}


Add Order Rating
	[Arguments]  ${accid}  ${uuid}  ${stars}  ${feedback}
	${params}=  Create Dictionary  account=${accid}  
	${data}=  Create Dictionary  uId=${uuid}  stars=${stars}  feedback=${feedback}
    ${data}=  json.dumps  ${data}
	Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /consumer/orders/rating  params=${params}  data=${data}  expected_status=any
    [Return]  ${resp}


Update Order Rating
	[Arguments]  ${accid}  ${uuid}  ${stars}  ${feedback}
	${params}=  Create Dictionary  account=${accid}  
	${data}=  Create Dictionary  uId=${uuid}  stars=${stars}  feedback=${feedback}
    ${data}=  json.dumps  ${data}
	Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /consumer/orders/rating  params=${params}  data=${data}  expected_status=any
    [Return]  ${resp} 


Get Order Rating
    [Arguments]   &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/orders/rating  params=${kwargs}   expected_status=any
    [Return]  ${resp}


Get Consumer Waitlist Attachment
   [Arguments]    ${accid}   ${uuid}
   ${params}=  Create Dictionary  account=${accid}
   Check And Create YNW Session
   ${resp}=    GET On Session    ynw  /consumer/waitlist/attachment/${uuid}   params=${params}   expected_status=any
   [Return]  ${resp}


Get Consumer Wallet
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/wallet/eligible     expected_status=any
    [Return]  ${resp}


Get All Jaldee Cash Available
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/wallet/cash/available     expected_status=any
    [Return]  ${resp}


Get Jaldee Cash Available By Id 
    [Arguments]      ${jcashid} 
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/wallet/cash/${jcashid}     expected_status=any
    [Return]  ${resp}


Get Jaldee Cash Details
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/wallet/cash/info     expected_status=any
    [Return]  ${resp}


Get Jaldee Cash Expired
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/wallet/cash/expired     expected_status=any
    [Return]  ${resp}


Get Remaining Amount To Pay
    [Arguments]  ${useJcash}   ${useJcredit}   ${AdvanceAmt}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   url=/consumer/wallet/redeem/remaining/amt?useJcash=${useJcash}&useJcredit=${useJcredit}&advancePayAmount=${AdvanceAmt}     expected_status=any
    [Return]  ${resp}


Get Total JCash And Credit Amount
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/wallet/redeem/eligible/amt     expected_status=any
    [Return]  ${resp}


Get Total Credit Available
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/wallet/credit     expected_status=any
    [Return]  ${resp}


Make Jcash Payment Consumer Mock
    [Arguments]  ${amount}  ${response}  ${uuid}  ${accid}  ${purpose}  ${isJcashUsed}  ${isreditUsed}
    Check And Create YNW Session
    ${data}=  Create Dictionary  amountToPay=${amount}  paymentMode=Mock  uuid=${uuid}  mockResponse=${response}  accountId=${accid}  paymentPurpose=${purpose}  isJcashUsed=${isJcashUsed}  isreditUsed=${isreditUsed}
    ${data}=  json.dumps  ${data}
    ${resp}=  POST On Session    ynw  /consumer/payment/wallet  data=${data}  expected_status=any
    [Return]  ${resp}


Waitlist AdvancePayment Details
    [Arguments]  ${accId}  ${queueId}  ${date}  ${serviceId}  ${consumerNote}  ${revealPhone}  ${coupons}  @{vargs}   
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
    ${data}=  Create Dictionary  queue=${queueId}  date=${date}  service=${serviceId}  consumerNote=${consumerNote}  waitlistingFor=${consumerlist}  revealPhone=${revealPhone}  coupons=${coupons} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=    PUT On Session  ynw  /consumer/waitlist/advancePayment   data=${data}  params=${param}   expected_status=any    
    [Return]  ${resp}


Appointment AdvancePayment Details
    [Arguments]    ${accid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${appmtFor}  ${coupons}
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}    
    ${data}=    Create Dictionary    appointmentMode=ONLINE_APPOINTMENT   account=${accId}   service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}  coupons=${coupons}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   url=/consumer/appointment/advancePayment?account=${accId}  data=${data}  expected_status=any
    [Return]  ${resp}


Appointment AdvancePayment Details without Coupon
    [Arguments]    ${accid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${appmtFor}
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}    
    ${data}=    Create Dictionary    appointmentMode=ONLINE_APPOINTMENT   account=${accId}   service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   url=/consumer/appointment/advancePayment?account=${accId}  data=${data}  expected_status=any
    [Return]  ${resp}


Consumer View Questionnaire
    [Arguments]    ${accid}   ${serviceId}  ${consumerId}
    ${params}=  Create Dictionary  account=${accid}
    Check And Create YNW Session
    ${resp}=  GET On Session   ynw  /consumer/questionnaire/service/${serviceId}/consumer/${consumerId}   params=${params}   expected_status=any
    [Return]  ${resp}

Get Donation Questionnaire By Id    
    [Arguments]  ${accid}   ${don_id}   
    ${params}=  Create Dictionary  account=${accid}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/questionnaire/donation/${don_id}  params=${params}   expected_status=any   
    [Return]  ${resp}


Consumer Validate Questionnaire
    [Arguments]  ${accid}   ${data}
    ${params}=  Create Dictionary  account=${accid}
    # ${data}=  json.dumps  ${data}
    Log  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /consumer/questionnaire/validate  data=${data}  params=${params}  expected_status=any
    [Return]  ${resp}

Consumer Change Answer Status for Waitlist
    [Arguments]  ${accid}   ${wlId}  ${fileId}  ${labelname}  
    ${params}=  Create Dictionary  account=${accid}
    ${filedata}=  Create Dictionary  uid=${fileId}  labelName=${labelname}  
    ${filedata}=  Create List  ${filedata}
    ${data}=  Create Dictionary  urls=${filedata} 
    ${data}=  json.dumps  ${data} 
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /consumer/waitlist/questionnaire/upload/status/${wlId}  data=${data}  params=${params}  expected_status=any
    [Return]  ${resp}    


Consumer Change Answer Status for Appointment
    [Arguments]  ${accid}   ${apptId}  ${fileId}  ${labelname}  
    ${params}=  Create Dictionary  account=${accid}
    ${filedata}=  Create Dictionary  uid=${fileId}  labelName=${labelname}
    ${filedata}=  Create List  ${filedata}
    ${data}=  Create Dictionary  urls=${filedata} 
    ${data}=  json.dumps  ${data} 
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /consumer/appointment/questionnaire/upload/status/${apptId}  data=${data}  params=${params}  expected_status=any
    [Return]  ${resp}  


Consumer Revalidate Questionnaire
    [Arguments]  ${accid}   ${data}
    ${params}=  Create Dictionary  account=${accid}
    Log  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /consumer/questionnaire/resubmit/validate  data=${data}  params=${params}  expected_status=any
    [Return]  ${resp}

Get Consumer Questionnaire By uuid For Waitlist
    [Arguments]  ${uuid}   ${accId}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  url=/consumer/waitlist/questionnaire/${uuid}?account=${accId}  expected_status=any     
    [Return]  ${resp}

Get Consumer Questionnaire By uuid For Appmnt
    [Arguments]  ${uuid}   ${accId}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  url=/consumer/appointment/questionnaire/${uuid}?account=${accId}   expected_status=any     
    [Return]  ${resp}

Consumer SignUp Via QRcode
    [Arguments]  ${firstname}  ${lastname}  ${primaryNo}   ${countryCode}   ${aacid}    ${email}
    ${usp}=   Create Dictionary   firstName=${firstname}  lastName=${lastname}  primaryMobileNo=${primaryNo}  countryCode=${countryCode}    email=${email}
    ${data}=  Create Dictionary    userProfile=${usp}    accountId=${aacid}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw    /consumer   data=${data}  expected_status=any
    [Return]  ${resp}


Get NextAvailableSchedule appt consumer
    [Arguments]      ${pid}    ${lid}   ${u_id}            
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /consumer/appointment/schedule/nextAvailableSchedule/${pid}-${lid}-${u_id}    expected_status=any
    [Return]  ${resp}


Get payment modes
    [Arguments]  ${accountId}   ${serviceId}   ${paymentPurpose}
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /consumer/payment/modes/${accountId}/${serviceId}/${paymentPurpose}    expected_status=any
    [Return]  ${resp}

Get Questionnaire By CatalogID    
    [Arguments]  ${catalogId1}     ${account_id}
    ${params}=  Create Dictionary  account=${account_id}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  url=/consumer/questionnaire/order/${catalogId1}?account=${account_id}  expected_status=any     
    [Return]  ${resp}

Consumer Get Order Questionnaire By uuid 
    [Arguments]  ${uuid}  ${account_id}
    ${params}=  Create Dictionary  account=${account_id}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/orders/questionnaire/${uuid}  params=${params}  expected_status=any     
    [Return]  ${resp}

Consumer Upload Status for Appnt
    [Arguments]  ${uuid}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /consumer/appointment/serviceoption/upload/status/${uuid}  expected_status=any
    [Return]  ${resp}

Get service options for an item
    [Documentation]    login bypassed url
    [Arguments]  ${item}     ${accountId}
    ${params}=  Create Dictionary  account=${accountId}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   url=/consumer/questionnaire/serviceoptions/order/item/${item}?account=${accountId}   expected_status=any
    [Return]    ${resp} 

Get Service Options By Service
    [Documentation]    login bypassed url
    [Arguments]      ${ser_id}    ${consumer}   ${accountId}    
    ${params}=  Create Dictionary  account=${accountId} 
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   url=/consumer/questionnaire/serviceoptions/${ser_id}/${consumer}?account=${accountId}    expected_status=any
    [Return]  ${resp}

Get Service Options By Order
    [Arguments]      ${catalogid}   ${accountId}    
    ${params}=  Create Dictionary  account=${accountId} 
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   url=/consumer/questionnaire/serviceoptions/order/${catalogid}?account=${accountId}    expected_status=any
    [Return]  ${resp}

Get Service Options By Donation
    [Arguments]      ${uuid}   ${accountId}    
    ${params}=  Create Dictionary  account=${accountId} 
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   url=/consumer/questionnaire/serviceoptions/donation/${uuid}?account=${accountId}    expected_status=any
    [Return]  ${resp}

Change Status Of Service Option Item
    [Arguments]  ${accountId}  ${uuid}  @{filedata}
    ${data}=    Create Dictionary   urls=${filedata}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=   PUT On Session  ynw  url=/consumer/orders/item/serviceoption/upload/status/${uuid}?account=${accountId}   data=${data}   expected_status=any
    [Return]    ${resp}

Change Status Of Service Option Appmt
    [Arguments]  ${accountId}  ${uuid}  @{filedata}
    ${data}=    Create Dictionary   urls=${filedata}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=   PUT On Session  ynw  url=/consumer/appointment/serviceoption/upload/status/${uuid}?account=${accountId}   data=${data}   expected_status=any
    [Return]    ${resp}

Change Status Of Service Option Waitlist
    [Arguments]  ${accountId}  ${uuid}  @{filedata}
    ${data}=    Create Dictionary   urls=${filedata}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=   PUT On Session  ynw  url=/consumer/waitlist/serviceoption/upload/status/${uuid}?account=${accountId}   data=${data}   expected_status=any
    [Return]    ${resp}

Change Status Of Service Option Order
    [Arguments]  ${accountId}  ${uuid}  @{filedata}
    ${data}=    Create Dictionary   urls=${filedata}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=   PUT On Session  ynw  url=/consumer/orders/serviceoption/upload/status/${uuid}?account=${accountId}   data=${data}   expected_status=any
    [Return]    ${resp}

Change Status Of Service Option Donation
    [Arguments]  ${accountId}  ${uuid}  @{filedata}
    ${data}=    Create Dictionary   urls=${filedata}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=   PUT On Session  ynw  url=/consumer/donation/serviceoption/upload/status/${uuid}?account=${accountId}   data=${data}   expected_status=any
    [Return]    ${resp}


Create Payment Link For Donation
    [Arguments]  ${con_id}  ${countryCode}  ${CUR_DAY}  ${don_amt1}  ${donar_fname}  ${donar_lname}  ${donorEmail}  ${ph1}  ${loc_id1}  ${note}  ${sid1}  ${acc_id}
    ${consumer_id}=  Create Dictionary  id=${con_id}
    ${donor_data}=  Create Dictionary  firstName=${donar_fname}  lastName=${donar_lname}
    ${location_data}=  Create Dictionary  id=${loc_id1}
    ${service_data}=  Create Dictionary  id=${sid1}
    ${data}=  Create Dictionary  consumer=${consumer_id}  countryCode=${countryCode}  date=${CUR_DAY}  donationAmount=${don_amt1}  
    ...   donor=${donor_data}  donorEmail=${donorEmail}  donorPhoneNumber=${ph1}  location=${location_data}  note=${note}
    ...   service=${service_data}   
    ${data}=   json.dumps   ${data}
    Check And Create YNW Session  
    ${resp}=    POST On Session    ynw  url=/consumer/payment/generate/paylink?account=${accId}   data=${data}  expected_status=any    
    [Return]  ${resp}

Get Donation Details
    [Arguments]  ${uuid}
    ${resp}=  GET On Session  ynw  /consumer/payment/paylink/donation/${uuid}  expected_status=any
    [Return]  ${resp}

Donation Payment Via Link
    [Arguments]  ${acc_id}  ${custId}  ${amount}  ${isInternational}  ${paymentMode}  ${purpose}  ${serviceId}  ${source}  ${pay_link}  ${response}
    ${data}=  Create Dictionary  accountId=${acc_id}  custId=${custId}  amount=${amount}  isInternational=${isInternational}  
    ...   paymentMode=${paymentMode}  purpose=${purpose}  serviceId=${serviceId}  source=${source}  uuid=${pay_link}
    ...    mockResponse=${response}
    ${data}=   json.dumps   ${data}
    Check And Create YNW Session   
    ${resp}=  POST On Session  ynw  /consumer/payment/paylink/donation  data=${data}  expected_status=any
    [Return]  ${resp}

Add Family
      [Arguments]                   ${firstname}   ${lastname}   ${dob}   ${gender}   ${email}   ${city}   ${state}   ${address}   ${primarynum}   ${alternativenum}   ${countrycode}   ${countryCodet}   ${numbert}   ${countryCodew}   ${numberw}
      Check And Create YNW Session
      ${whatsAppNum}=               Create Dictionary    countryCode=${countryCodet}   number=${numbert}
      ${telegramNum}=               Create Dictionary    countryCode=${countryCodew}   number=${numberw}
      ${headers}=                   Create Dictionary    Content-Type=application/json
      ${userProfile}=               Create Dictionary    firstName=${firstname}   lastName=${lastname}   dob=${dob}   gender=${gender}   email=${email}   city=${city}  state=${state}   address=${address}  primaryMobileNo=${primarynum}   alternativePhoneNo=${alternativenum}   countryCode=${countrycode}  telegramNum=${telegramNum}   whatsAppNum=${whatsAppNum}
      ${data}=                      Create Dictionary    userProfile=${userProfile}
      ${resp}=                      POST On Session  ynw   /consumer/familyMember    json=${data}    headers=${headers}     expected_status=any
      
      [Return]                      ${resp}

Get Seropt By CatalogId
    [Documentation]    login bypassed url
    [Arguments]    ${catalogId}  ${channel}    ${accid}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  url=/consumer/questionnaire/serviceoption/order/catalog/item/${catalogId}/${channel}?account=${accid}    expected_status=any

    [Return]  ${resp}

Order For Item Consumer

    [Arguments]   ${accId}   ${orderFor}    ${CatalogId}   ${homeDelivery}    ${homeDeliveryAddress}  ${sTime1}    ${eTime1}   ${orderDate}    ${phoneNumber}    ${email}  ${countryCode}  ${coupons}  @{vargs}        
    ${catalog}=  Create Dictionary  id=${CatalogId}
    ${orderFor}=  Create Dictionary  id=${orderFor}
    ${timeSlot}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    # ${coupons}=  Create List
    ${len}=  Get Length  ${vargs}
    ${items}=  Create Dictionary  id=${vargs[0]}  quantity=${vargs[1]}
    ${orderitem}=  Create List  ${items}
    FOR    ${index}   IN RANGE   2  ${len}  2
        ${index2}=  Evaluate  ${index}+1
        ${items}=  Create Dictionary  id=${vargs[${index}]}  quantity=${vargs[${index2}]}
        Append To List  ${orderitem}  ${items}
    END

    ${order}=  Create Dictionary  homeDelivery=${homeDelivery}  homeDeliveryAddress=${homeDeliveryAddress}   catalog=${catalog}  orderFor=${orderFor}    orderItem=${orderitem}   orderDate=${orderDate}   timeSlot=${timeSlot}  phoneNumber=${phoneNumber}  countryCode=${countryCode}  email=${email}  coupons=${coupons}
    
    [Return]  ${order} 

Create Order With Service Options Consumer
    [Arguments]    ${cookie}  &{kwargs}
    ${srvAnswers}=    evaluate    json.loads('''${kwargs['srvAnswers']}''')    json
    # Log  ${srvAnswers}
    Set To Dictionary  ${kwargs['order']}  srvAnswers=${srvAnswers}
    # Log  ${kwargs['order']}
    # ${order}=  json.dumps  ${kwargs['order']}
    ${order}=  Set Variable  ${kwargs['order']}
    # Log  ${order} 
    ${resp}=  ShoppingCartUpload   ${Cookie}  ${account_id}   ${order}
    [Return]  ${resp}


Create Order For AuthorDemy

    [Arguments]   ${Cookie}   ${accId}   ${orderFor}    ${CatalogId}    ${orderDate}    ${phoneNumber}    ${email}  ${countryCode}  ${coupons}  @{vargs}        
    ${catalog}=  Create Dictionary  id=${CatalogId}
    ${orderFor}=  Create Dictionary  id=${orderFor}
    # ${timeSlot}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    # ${coupons}=  Create List
    ${len}=  Get Length  ${vargs}
    ${items}=  Create Dictionary  id=${vargs[0]}  quantity=${vargs[1]}
    ${orderitem}=  Create List  ${items}
    FOR    ${index}   IN RANGE   2  ${len}  2
        ${index2}=  Evaluate  ${index}+1
        ${items}=  Create Dictionary  id=${vargs[${index}]}  quantity=${vargs[${index2}]}
        Append To List  ${orderitem}  ${items}
    END

    ${order}=  Create Dictionary   catalog=${catalog}  orderFor=${orderFor}    orderItem=${orderitem}   orderDate=${orderDate}  phoneNumber=${phoneNumber}  countryCode=${countryCode}  email=${email}  coupons=${coupons}
    ${resp}=  ShoppingCartUpload   ${Cookie}   ${accId}   ${order}
    [Return]  ${resp} 


Get Consumer
    [Arguments]    &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /consumer    params=${kwargs}    expected_status=any
    [Return]  ${resp}


Get Users By Loc and AccId
    [Arguments]  ${accountId}  ${locationId}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /consumer/users/${accountId}/${locationId}   expected_status=any
    [Return]  ${resp}


#   Appt Request


Consumer Create Appt Service Request
    [Arguments]      ${accId}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}   ${countryCode}   ${phoneNumber}  ${coupons}  ${appmtFor} 
    ${sid}=  Create Dictionary  id=${service_id} 
    ${schedule}=  Create Dictionary  id=${schedule}
    ${data}=    Create Dictionary   appmtDate=${appmtDate}  service=${sid}  schedule=${schedule}
    ...   appmtFor=${appmtFor}    consumerNote=${consumerNote}  phoneNumber=${phoneNumber}   coupons=${coupons}
    ...   countryCode=${countryCode}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  url=/consumer/appointment/service/request?account=${accId}  data=${data}  expected_status=any
    [Return]  ${resp}


Consumer Get Appt Service Request
    [Arguments]    &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /consumer/appointment/service/request    params=${kwargs}    expected_status=any
    [Return]  ${resp}


Consumer Get Appt Service Request Count
    [Arguments]    &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /consumer/appointment/service/request/count   params=${kwargs}    expected_status=any
    [Return]  ${resp}

#    Jaldee Video Call

Consumer Video Call ready

    [Arguments]  ${uuid}     ${recordingFlag}

    ${data}=  Create Dictionary   uuid=${uuid}    recordingFlag=${recordingFlag}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /consumer/waitlist/videocall/ready   data=${data}  expected_status=any
    Log  ${resp.content}
    [Return]  ${resp}



Get Service By Location Appoinment   
    [Arguments]  ${locationId}   
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/appointment/service/${locationId}  expected_status=any     
    [Return]  ${resp} 

Get locations by service
    [Arguments]      ${serviceId}  
    Check And Create YNW Session
    ${resp}=    GET On Session  ynw   /consumer/service/${serviceId}/location    expected_status=any
    [Return]  ${resp}

Get Booking Invoices
     [Arguments]      ${ynwuuid}  
    Check And Create YNW Session
    ${resp}=    GET On Session  ynw   /consumer/jp/finance/invoice/ynwuid/${ynwuuid}    expected_status=any
    [Return]  ${resp}


Get invoices bydate
     [Arguments]      ${startDate}   ${endDate}
    ${data}=  Create Dictionary   startDate=${startDate}    endDate=${endDate}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    GET On Session  ynw   /consumer/jp/finance/invoice/bydate   data=${data}   expected_status=any
    [Return]  ${resp}
