*** Settings ***
Library           Collections
Library           String
Library           OperatingSystem
Library           json
Library           db.py
Resource          Keywords.robot

*** Variables ***

# &{cons_headers}                Content-Type=application/json
# &{form_headers}		    
# &{cons_params}       

*** Keywords ***

Consumer Login
    [Arguments]    ${usname}  ${passwrd}  ${countryCode}=+91   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${log}=  Login  ${usname}  ${passwrd}   countryCode=${countryCode}
    # ${kwargs}=  db.Set_TZ_Header  &{kwargs}
    ${cons_headers}=  Create Dictionary  &{headers}  
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    ${resp}=    POST On Session    ynw    /consumer/login    data=${log}   params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Consumer Logout
    [Arguments]    #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    Check And Create YNW Session
    ${resp}=    DELETE On Session    ynw    /consumer/login  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

    

Send Reset Email
    [arguments]  ${email}  ${countryCode}=+91  &{kwargs}  #${timeZone}=Asia/Kolkata
    
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${data}=    json.dumps    ${countryCode}
    ${resp}=    POST On Session    ynw   /consumer/login/reset/${email}   data=${data}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Reset Password
    [Arguments]    ${email}  ${pswd}  ${purpose}  ${countryCode}=+91  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${key}=  verify accnt  ${email}   ${purpose}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw    /consumer/login/reset/${key}/validate  params=${cons_params}  expected_status=any   headers=${cons_headers}  
    ${login}=    Create Dictionary    loginId=${email}  password=${pswd}  countryCode=${countryCode}
    ${log}=    json.dumps    ${login}
    ${respk}=  PUT On Session  ynw  /consumer/login/reset/${key}  data=${log}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}  ${respk}

    
Consumer Creation
    [Arguments]  ${firstname}  ${lastname}  ${address}  ${primaryNo}  ${alternativeNo}  ${dob}  ${gender}  ${email}  ${countryCode}=+91  
    ${usp}=    Create Dictionary   firstName=${firstname}  lastName=${lastname}  address=${address}  primaryMobileNo=${primaryNo}  alternativePhoneNo=${alternativeNo}  dob=${dob}  gender=${gender}  email=${email}  countryCode=${countryCode}
    ${auth}=    Create Dictionary    userProfile=${usp}
    ${apple}=    json.dumps    ${auth}
    RETURN  ${apple}


Consumer SignUp
    [Arguments]  ${firstname}  ${lastname}  ${address}  ${primaryNo}  ${alternativeNo}  ${dob}  ${gender}  ${email}   ${countryCode}=+91  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${apple}=  Consumer Creation  ${firstname}  ${lastname}  ${address}  ${primaryNo}  ${alternativeNo}  ${dob}  ${gender}  ${email}   countryCode=${countryCode}    
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw    /consumer   data=${apple}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Consumer Activation
    [Arguments]  ${email}  ${purpose}  &{kwargs}  #${timeZone}=Asia/Kolkata
    
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    
    Check And Create YNW Session
    ${key}=   verify accnt  ${email}  ${purpose}
    ${resp_val}=  POST On Session   ynw  /consumer/${key}/verify   params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp_val}


Consumer Set Credential
    [Arguments]  ${email}  ${password}  ${purpose}  ${countryCode}=+91  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${auth}=     Create Dictionary   password=${password}  countryCode=${countryCode}
    ${key}=   verify accnt  ${email}  ${purpose}
    ${apple}=    json.dumps    ${auth}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    ${resp}=    PUT On Session    ynw    /consumer/${key}/activate   data=${apple}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Send Verify Login Consumer
    [Arguments]  ${loginid}  ${countryCode}=+91  &{kwargs}  #${timeZone}=Asia/Kolkata
    Check And Create YNW Session
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=     Create Dictionary   countryCode=${countryCode}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    ${resp}=  POST On Session    ynw  /consumer/login/verifyLogin/${loginid}   params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Check Consumer Exists
    [Arguments]  ${loginid}  ${countryCode}=+91  &{kwargs}  #${timeZone}=Asia/Kolkata
    Check And Create YNW Session
    ${body}=     Create Dictionary   countryCode=${countryCode}
    ${data}=    json.dumps    ${body}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    ${resp}=  GET On Session    ynw  /consumer/${loginid}/check    data=${data}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Verify Login Consumer
    [Arguments]  ${loginid}  ${purpose}  ${countryCode}=+91  &{kwargs}  #${timeZone}=Asia/Kolkata
    Check And Create YNW Session
    ${auth}=     Create Dictionary   loginId=${loginid}  countryCode=${countryCode}
    ${key}=   verify accnt  ${loginid}  ${purpose}
    ${data}=    json.dumps    ${auth}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    ${resp}=    PUT On Session    ynw    /consumer/login/${key}/verifyLogin    data=${data}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Update Consumer 
    [Arguments]  ${firstname}  ${lastname}  ${address}  ${primaryNo}  ${alternativeNo}  ${dob}  ${gender}  ${email}   ${countryCode}=+91  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${usp}=    Create Dictionary   firstName=${firstname}  lastName=${lastname}  address=${address}  primaryMobileNo=${primaryNo}  alternativePhoneNo=${alternativeNo}  dob=${dob}  gender=${gender}  email=${email}  countryCode=${countryCode}
    ${auth}=    Create Dictionary    userProfile    ${usp}  
    ${apple}=    json.dumps    ${auth}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    PATCH On Session    ynw    /consumer/signUp    data=${apple}  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get Consumer By Id
    [Arguments]  ${email}  &{kwargs}  #${timeZone}=Asia/Kolkata
    Check And Create YNW Session
    ${id}=  get_id  ${email}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    ${resp}=    GET On Session    ynw   /consumer/${id}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Consumer Change Password
    [Arguments]   ${old_password}  ${new_password}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${auth}=     Create Dictionary   oldpassword=${old_password}  password=${new_password}
    Check And Create YNW Session
    ${apple}=    json.dumps    ${auth}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    ${resp}=    PUT On Session   ynw    /consumer/login/chpwd  data=${apple}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Consumer Waitlist
    [Arguments]    ${service_id}  ${partySize}  ${consumerNote}  
    ${service}=     Create Dictionary    id=${service_id}
    ${apple}=  Create Dictionary   service=${service}  partySize=${partySize}  consumerNote=${consumerNote}
    RETURN  ${apple}
    

# Add To Waitlist Consumer
#     [Arguments]   ${service_id}  ${partySize}  ${consumerNote}  ${acct_id}
#     ${cons_headers}=  Create Dictionary  &{headers} 
#     ${cons_params}=  Create Dictionary  account=${acct_id}
#     ${apple}=   Consumer Waitlist  ${service_id}  ${partySize}  ${consumerNote}
#     ${apple}=    json.dumps    ${apple}
#     Check And Create YNW Session
#     ${resp}=    POST On Session   ynw    /consumer/waitlist  data=${apple}  params=${cons_params}   expected_status=any   headers=${cons_headers}
#     RETURN  ${resp}
    

Consumer Add To Waitlist with Phone no
    [Arguments]   ${acct_id}  ${service_id}  ${queueId}  ${date}  ${waitlistPhoneNumber}  ${country_code}  @{vargs}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${acct_id}
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
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /consumer/waitlist  data=${apple}  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Consumer Add To WL With Virtual Service
    [Arguments]  ${accId}  ${queueId}  ${date}  ${serviceId}  ${consumerNote}  ${revealPhone}  ${virtualService}  @{vargs}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accId}
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
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    POST On Session  ynw  /consumer/waitlist   data=${data}   params=${cons_params}   expected_status=any   headers=${cons_headers} 
    RETURN  ${resp}


Virtual Service Checkin with Mode
    [Arguments]  ${waitlistMode}  ${accId}  ${queueId}  ${date}  ${serviceId}  ${consumerNote}  ${revealPhone}  ${virtualService}  @{vargs}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accId}
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
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    POST On Session  ynw  /consumer/waitlist   data=${data}  params=${cons_params}   expected_status=any   headers=${cons_headers}    
    RETURN  ${resp}



Consumer Add To WL With Virtual Service For User
    [Arguments]  ${accId}  ${queueId}  ${date}  ${serviceId}  ${consumerNote}  ${revealPhone}  ${virtualService}  ${u_id}  @{vargs}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accId}
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
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    POST On Session  ynw  /consumer/waitlist   data=${data}  params=${cons_params}   expected_status=any   headers=${cons_headers}    
    RETURN  ${resp}


Add To Waitlist Children Consumer
    [Arguments]   ${service_id}  ${partySize}  ${consumerNote}  ${acct_id}   @{vargs}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${acct_id}
    ${apple}=   Consumer Waitlist  ${service_id}  ${partySize}  ${consumerNote}
    ${len}=  Get Length  ${vargs}
    ${child}=  Create Dictionary  name=${vargs[0]}
    ${wchild}=  Create List  ${child}
    :FOR    ${index}    IN RANGE  1  ${len}
    \	${child}=  Create Dictionary  name=${vargs[${index}]} 
    \   Append To List  ${wchild}  ${child}
    Set To Dictionary  ${apple}  waitlistChild=${wchild} 
    ${apple}=    json.dumps    ${apple}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /consumer/waitlist  data=${apple}  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

# View Waitlistee <-> Get consumer Waitlist By Id
# View Waitlistee
#     [Arguments]  ${id}  ${acct_id}
#     ${cons_headers}=  Create Dictionary  &{headers} 
#     ${cons_params}=  Create Dictionary  account=${acct_id}
#     Check And Create YNW Session
#     Set To Dictionary  ${cons_headers}   timeZone=${timeZone}
#     ${resp}=  GET On Session  ynw  /consumer/waitlist/${id}    params=${cons_params}   expected_status=any   headers=${cons_headers}
#     RETURN  ${resp}

Get Waitlist Consumer
    [Arguments]    &{kwargs}
    Check And Create YNW Session
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${kwargs}   &{locparam}
    ${resp}=  GET On Session  ynw  /consumer/waitlist  params=${kwargs}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Cancel Waitlist
    [Arguments]  ${id}  ${acct_id}    ${CancelReason}=${waitlist_cancl_reasn[4]}    ${CommunicationMessage}=other  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${acct_id}
    ${auth}=  Create Dictionary   cancelReason=${CancelReason}    communicationMessage=${CommunicationMessage}
    ${auth}=    json.dumps    ${auth}
    Check And Create YNW Session

    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    ${resp}=  PUT On Session  ynw  /consumer/waitlist/cancel/${id}  data=${auth}   params=${cons_params}   expected_status=any  headers=${cons_headers}
    RETURN  ${resp}


Approximate Waiting Time Consumer
    [Arguments]  ${acct_id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    ${resp}=    GET On Session    ynw  /consumer/waitlist/appxWaitingTime  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Update Consumer Profile
    [Arguments]  ${firstname}  ${lastname}  ${address}  ${dob}  ${gender}  &{kwargs}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    ${phone_numbers}=  Get Dictionary items  ${kwargs}
    ${usp}=    Create Dictionary   firstName=${firstname}  lastName=${lastname}  address=${address}  dob=${dob}  gender=${gender}
    FOR  ${key}  ${value}  IN  @{phone_numbers}
        Set To Dictionary  ${usp}   ${key}=${value}
    END
    Log  ${usp}
    ${apple}=    json.dumps    ${usp}
    Check And Create YNW Session
    ${resp}=    PATCH On Session    ynw    /consumer    data=${apple}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Update Consumer Profile With Emailid
    [Arguments]  ${firstname}  ${lastname}  ${address}  ${dob}  ${gender}  ${email}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${usp}=    Create Dictionary   firstName=${firstname}  lastName=${lastname}  address=${address}  dob=${dob}  gender=${gender}  email=${email}
    ${apple}=    json.dumps    ${usp}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    PATCH On Session    ynw    /consumer    data=${apple}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get Waitlist Id Consumer
    [Arguments]   ${date}  ${id}  ${acct_id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${acct_id}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/waitlist/${id}/${date}    params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

    
Reveal Phone Number
	[Arguments]  ${accid}  ${status}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /consumer/providers/revealPhoneNo/${accid}/${status}   params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}
    
    
Add Rating
	[Arguments]  ${accid}  ${uuid}  ${stars}  ${feedback}  &{kwargs}  #${timeZone}=Asia/Kolkata
	${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accid}  
	${data}=  Create Dictionary  uuid=${uuid}  stars=${stars}  feedback=${feedback}
    ${data}=  json.dumps  ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /consumer/waitlist/rating  params=${cons_params}  data=${data}  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp} 

    
Update Rating Waitlist
	[Arguments]  ${accid}  ${uuid}  ${stars}  ${feedback}  &{kwargs}  #${timeZone}=Asia/Kolkata
	${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accid}  
	${data}=  Create Dictionary  uuid=${uuid}  stars=${stars}  feedback=${feedback}
    ${data}=  json.dumps  ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /consumer/waitlist/rating  params=${cons_params}  data=${data}  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp} 


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
    RETURN  ${data}


AddFamilyMember
    [Arguments]   ${firstname}  ${lastname}  ${dob}  ${gender}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${data}=  Familymember Creation   ${firstname}  ${lastname}  ${dob}  ${gender}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /consumer/familyMember   data=${data}  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


DeleteFamilyMember
    [Arguments]  ${id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    DELETE On Session  ynw  /consumer/familyMember/${id}   params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


ListFamilyMember
    [Arguments]    &{kwargs}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${kwargs}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session   ynw   /consumer/familyMember   params=${kwargs}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


ConsumerFamilyMember Waitlist
    [Arguments]    ${service_id}  ${partySize}  ${consumerNote}  ${mem_id}
    ${service}=     Create Dictionary    id=${service_id}
    ${member}=     Create Dictionary    id=${mem_id}
    ${apple}=  Create Dictionary   service=${service}  partySize=${partySize}  consumerNote=${consumerNote}  waitlistingFor=${member}
    RETURN  ${apple}


Add To Waitlist ConsumerFamilyMember
    [Arguments]   ${service_id}  ${partySize}  ${consumerNote}  ${mem_id}  ${acct_id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${acct_id}
    ${apple}=   ConsumerFamilyMember Waitlist  ${service_id}  ${partySize}  ${consumerNote}  ${mem_id}
    ${apple}=    json.dumps    ${apple}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /consumer/waitlist  data=${apple}  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

    
UpdateFamilymember Creation
    [Arguments]   ${mem_id}  ${firstname}  ${lastname}  ${dob}  ${gender}  
    ${up}=  Create Dictionary   id=${mem_id}  firstName=${firstname}  lastName=${lastname}  dob=${dob}  gender=${gender}
    ${data}=  Create Dictionary     userProfile=${up}
    ${data}=  json.dumps  ${data}
    RETURN  ${data}


UpdateFamilyMember
    [Arguments]   ${mem_id}  ${firstname}  ${lastname}  ${dob}  ${gender}  &{kwargs}  #${timeZone}=Asia/Kolkata
    
    ${data}=  UpdateFamilymember Creation   ${mem_id}  ${firstname}  ${lastname}  ${dob}  ${gender}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /consumer/familyMember   data=${data}   params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

    
Add To Waitlist Consumer FamilymemberChildren
    [Arguments]   ${service_id}  ${partySize}  ${consumerNote}  ${mem_id}  ${acct_id}  @{vargs}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${acct_id}
    ${apple}=   Consumer FamilyMemberWaitlist  ${service_id}  ${partySize}  ${consumerNote}  ${mem_id}
    ${len}=  Get Length  ${vargs}
    ${child}=  Create Dictionary  name=${vargs[0]}
    ${wchild}=  Create List  ${child}
    FOR    ${index}    IN RANGE  1  ${len}
       ${child}=  Create Dictionary  name=${vargs[${index}]}
       Append To List  ${wchild}  ${child}
    END
    Set To Dictionary  ${apple}  waitlistChild=${wchild}
    ${apple}=    json.dumps    ${apple}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /consumer/waitlist  data=${apple}  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

    
Get Waitlist Consumer Count
    [Arguments]    &{kwargs}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/waitlist/count  params=${kwargs}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}  

    
CommunicationBetweenConsumerAndProvider
	[Arguments]  ${aid}  ${uuid}  ${msg}  &{kwargs}  #${timeZone}=Asia/Kolkata
	${data}=  Create Dictionary  communicationMessage=${msg}
	${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${aid}
    ${data}=  json.dumps  ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /consumer/waitlist/communicate/${uuid}  data=${data}  params=${cons_params}   expected_status=any   headers=${cons_headers} 
    RETURN  ${resp}

    
List Favourite Provider
    [Arguments]   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/providers   params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Add Favourite Provider
    [Arguments]  ${provider_id}   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /consumer/providers/${provider_id}   params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Remove Favourite Provider
    [Arguments]  ${provider_id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw  /consumer/providers/${provider_id}   params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

    
Get Bill By Consumer
    [Arguments]  ${id}  ${accId}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accId}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /consumer/bill/${id}    params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}
 
 
Get S3 Url
    [Arguments]   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/login/s3Url   params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

    
Get Consumer Communications
    [Arguments]   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/communications   params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


# Reading Provider Communications
#     [Arguments]   ${providerId}  ${messageIds}
#     ${data}=  Create Dictionary  providerId=${providerId}  messageIds=${messageIds}
#     ${data}=  json.dumps  ${data}
#     Check And Create YNW Session
#     ${resp}=  PUT On Session  ynw  /consumer/communications/readMessages/${providerId}/${messageIds}   data=${data}  expected_status=any   headers=${cons_headers}
#     RETURN  ${resp}


Reading Provider Communications
    [Arguments]   ${providerId}   ${acc_id}  ${messageIds}   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${acc_id}
    ${data}=  Create Dictionary  providerId=${providerId}  messageIds=${messageIds}
    ${data}=  json.dumps  ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /consumer/communications/readMessages/${providerId}/${messageIds}   data=${data}   params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get Consumer Communications Unread Count
    [Arguments]   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/communications/unreadCount   params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get Consumer Communications Unread Messages
    [Arguments]   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/communications/unreadMessages   params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}
    
General Communication with Provider
    [Arguments]    ${communicationMessage}   ${acc_id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${acc_id}
    ${data}=  Create Dictionary  communicationMessage=${communicationMessage}
    ${data}=  json.dumps  ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /consumer/communications   data=${data}   params=${cons_params}   expected_status=any   headers=${cons_headers}  
    RETURN  ${resp}  	


General Communication with User
    [Arguments]    ${communicationMessage}   ${acc_id}   ${U_id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${acc_id}
    ${data}=  Create Dictionary  provider=${U_id}   communicationMessage=${communicationMessage}
    ${data}=  json.dumps  ${data}   
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /consumer/communications   data=${data}   params=${cons_params}   expected_status=any   headers=${cons_headers}  
    RETURN  ${resp}  	

    
Add To Waitlist Consumers
    [Arguments]  ${accId}  ${queueId}  ${date}  ${serviceId}  ${consumerNote}  ${revealPhone}  @{vargs}  &{kwargs}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accId}
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
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    POST On Session  ynw  /consumer/waitlist   data=${data}  params=${cons_params}   expected_status=any   headers=${cons_headers}    
    RETURN  ${resp}


Add To Waitlist Consumers with mode
    [Arguments]  ${waitlistMode}  ${accId}  ${queueId}  ${date}  ${serviceId}  ${consumerNote}  ${revealPhone}  @{vargs}  &{kwargs}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accId}
    ${queueId}=  Create Dictionary  id=${queueId}
    ${serviceId}=  Create Dictionary  id=${service_id}  
    
    ${len}=  Get Length  ${vargs}
    ${consumer}=  Create Dictionary  id=${vargs[0]}
    ${consumerlist}=  Create List  ${consumer}
    FOR    ${index}    IN RANGE  1  ${len}
        ${consumer}=  Create Dictionary  id=${vargs[${index}]}
        Append To List  ${consumerlist}  ${consumer}
    END
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  Create Dictionary  waitlistMode=${waitlistMode}  queue=${queueId}  date=${date}  service=${serviceId}  consumerNote=${consumerNote}  waitlistingFor=${consumerlist}  revealPhone=${revealPhone} 
    ${data}=  json.dumps  ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    POST On Session  ynw  /consumer/waitlist   data=${data}  params=${cons_params}   expected_status=any   headers=${cons_headers}    
    RETURN  ${resp}


Add To Waitlist Consumer For User
    [Arguments]  ${accId}  ${queueId}  ${date}  ${serviceId}  ${consumerNote}  ${revealPhone}  ${user_id}  @{vargs}  &{kwargs} 
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accId}
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
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  Create Dictionary  queue=${queueId}  date=${date}  service=${serviceId}  consumerNote=${consumerNote}  waitlistingFor=${consumerlist}  revealPhone=${revealPhone}  provider=${uid}
    ${data}=  json.dumps  ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    POST On Session  ynw  /consumer/waitlist   data=${data}  params=${cons_params}   expected_status=any   headers=${cons_headers}    
    RETURN  ${resp}
    
# Delete Waitlist Consumer
#     [Arguments]  ${uuid}  ${accId}  ${CancelReason}=${waitlist_cancl_reasn[4]}    ${CommunicationMessage}=other   &{kwargs}  #${timeZone}=Asia/Kolkata
#     ${cons_headers}=  Create Dictionary  &{headers} 
    # ${cons_params}=  Create Dictionary  account=${accId}
#     ${auth}=  Create Dictionary   cancelReason=${CancelReason}    communicationMessage=${CommunicationMessage}
#     ${auth}=    json.dumps    ${auth}
#     Check And Create YNW Session

#     ${cons_headers}=  Create Dictionary  &{headers} 
    # ${cons_params}=  Create Dictionary
#     ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
#     Log  ${kwargs}
#     Set To Dictionary  ${cons_headers}   &{tzheaders}
#     Set To Dictionary  ${cons_params}   &{locparam}
    
#     ${resp}=  DELETE On Session  ynw  /consumer/waitlist/${uuid}  data=${auth}  params=${cons_params}   expected_status=any   headers=${cons_headers}
#     RETURN  ${resp} 


Get consumer Waitlist By Id
    [Arguments]  ${uuid}  ${accId}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accId}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/waitlist/${uuid}  params=${cons_params}   expected_status=any   headers=${cons_headers} 
    RETURN  ${resp}

Get consumer Waitlist 
    [Arguments]   &{params}
    ${cons_headers}=  Create Dictionary  &{headers} 
    # &{params}=  db.Set_TZ_Header  &{params}
    ${headers}  ${cons_params}  ${locparam}=  db.Set_TZ_Header  &{params}
    Log  ${cons_params}
    Set To Dictionary  ${cons_headers}   &{headers}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/waitlist/  params=${cons_params}   expected_status=any   headers=${cons_headers}   
    RETURN  ${resp}   

Get Future Waitlist 
    [Arguments]  &{params} 
    ${cons_headers}=  Create Dictionary  &{headers} 
    # &{params}=  db.Set_TZ_Header  &{params}
    ${headers}  ${cons_params}  ${locparam}=  db.Set_TZ_Header  &{params}
    Log  ${cons_params}
    Set To Dictionary  ${cons_headers}   &{headers}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/waitlist/future  params=${cons_params}   expected_status=any   headers=${cons_headers}   
    RETURN  ${resp}            
    
    
Get Future Waitlist Count   
    [Arguments]   &{params} 
    # &{params}=  db.Set_TZ_Header  &{params}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${headers}  ${cons_params}  ${locparam}=  db.Set_TZ_Header  &{params}
    Log  ${cons_params}
    Set To Dictionary  ${cons_headers}   &{headers}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/waitlist/future/count  params=${cons_params}   expected_status=any   headers=${cons_headers}   
    RETURN  ${resp} 
    
Get Waiting Time Of queues
    [Arguments]  ${locationId}  ${accId}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accId}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  consumer/waitlist/${locationId}/waitingTime  params=${cons_params}   expected_status=any   headers=${cons_headers}   
    RETURN  ${resp}

Make Payment Consumer
    [Arguments]  ${amount}  ${mode}  ${uuid}  ${accid}  ${purpose}  ${c_id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${data}=  Create Dictionary  amount=${amount}  paymentMode=${mode}  uuid=${uuid}  accountId=${accid}  purpose=${purpose}  custId=${c_id}
    ${data}=  json.dumps  ${data}
    ${resp}=  POST On Session    ynw  /consumer/payment  data=${data}  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

# Make Payment Consumer Mock
#     [Arguments]  ${amount}  ${response}  ${uuid}  ${accid}  ${purpose}  ${c_id}
#     Check And Create YNW Session
#     ${data}=  Create Dictionary  amount=${amount}  paymentMode=Mock  uuid=${uuid}  mockResponse=${response}  accountId=${accid}  purpose=${purpose}  custId=${c_id}  
#     ${data}=  json.dumps  ${data}
#     ${resp}=  POST On Session    ynw  /consumer/payment  data=${data}  expected_status=any   headers=${cons_headers}
#     RETURN  ${resp}


Make Payment Consumer Mock
    [Arguments]  ${accid}  ${amount}   ${purpose}  ${uuid}    ${serviceId}   ${international}   ${response}  ${c_id}  &{kwargs}  
    
    ${data}=  Create Dictionary  accountId=${accid}  amount=${amount}  paymentMode=Mock  purpose=${purpose}  uuid=${uuid}  
    ...    serviceId=${serviceId}   isInternational=${international}   mockResponse=${response}  custId=${c_id}
    
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session    ynw  /consumer/payment  data=${data}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get Payment Consumer
    [Arguments]  ${uuid}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/payment/${uuid}  params=${cons_params}  expected_status=any   headers=${cons_headers}     
    RETURN  ${resp}


Get conspayment profiles
    [Arguments]   ${accId}  &{kwargs}  #${timeZone}=Asia/Kolkata
    Check And Create YNW Session
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accId}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    ${resp}=   GET On Session  ynw  /consumer/payment/paymentProfiles   params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get conspayment profiles By Id
    [Arguments]   ${accId}  ${profileId}  &{kwargs}  #${timeZone}=Asia/Kolkata
    Check And Create YNW Session
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accId}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    ${resp}=   GET On Session  ynw  /consumer/payment/paymentProfiles/${profileId}   params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get Rating
    [Arguments]   ${timeZone}=Asia/Kolkata  &{kwargs}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/waitlist/rating  params=${kwargs}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get Queue By Location and service 
    [Arguments]  ${locationId}  ${serviceId}  ${accId}  &{kwargs}  #${timeZone}=Asia/Kolkata
    Check And Create YNW Session
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accId}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    ${resp}=    GET On Session    ynw  /consumer/waitlist/queues/${locationId}/${serviceId}    params=${cons_params}   expected_status=any   headers=${cons_headers}     
    RETURN  ${resp}

Get Service By Location   
    [Arguments]  ${locationId}   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/waitlist/services/${locationId}   params=${cons_params}   expected_status=any   headers=${cons_headers}     
    RETURN  ${resp} 

Get history Waitlist 
    [Arguments]  &{cons_params} 
    ${cons_headers}=  Create Dictionary  &{headers}
    ${headers}  ${cons_params}  ${locparam}=  db.Set_TZ_Header  &{params}
    Log  ${cons_params}
    Set To Dictionary  ${cons_headers}   &{headers}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/waitlist/history  params=${cons_params}   expected_status=any   headers=${cons_headers}   
    RETURN  ${resp}      

AddFamilyMemberWithPhNo
    [Arguments]   ${firstname}  ${lastname}  ${Mobile}  ${dob}  ${gender}   &{kwargs}  #${timeZone}=Asia/Kolkata
     
    ${up}=  Create Dictionary  firstName=${firstname}  lastName=${lastname}  primaryMobileNo=${Mobile}  dob=${dob}  gender=${gender}
    ${data}=  Create Dictionary   userProfile=${up}
    ${data}=  json.dumps  ${data} 
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session  
    ${resp}=  POST On Session  ynw  /consumer/familyMember   data=${data}   params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}    

Get history Waitlist Count
    [Arguments]   &{cons_params} 
    ${cons_headers}=  Create Dictionary  &{headers}
    ${headers}  ${cons_params}  ${locparam}=  db.Set_TZ_Header  &{cons_params}
    Log  ${cons_params}
    Set To Dictionary  ${cons_headers}   &{headers}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  consumer/waitlist/history/count  params=${cons_params}   expected_status=any   headers=${cons_headers}   
    RETURN  ${resp}          

Get Queue By Location and service By Date 
    [Arguments]  ${locationId}  ${serviceId}  ${Date}  ${accId}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accId}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/waitlist/queues/${locationId}/${serviceId}/${Date}  params=${cons_params}   expected_status=any   headers=${cons_headers}    
    RETURN  ${resp}   

Send Bill Email
    [Arguments]   ${uuid}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/bill/email/${uuid}   params=${cons_params}  expected_status=any   headers=${cons_headers}  
    RETURN  ${resp} 

Apply Jaldee Coupon At Selfpay
    [Arguments]   ${uuid}  ${coupon_code}  ${accId}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accId}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /consumer/jaldee/coupons/${coupon_code}/${uuid}    params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp} 


Add To Waitlist Consumers with JCoupon
    [Arguments]  ${accId}  ${queueId}  ${date}  ${serviceId}  ${consumerNote}  ${revealPhone}  ${coupons}  @{vargs}   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accId}
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
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    POST On Session  ynw  /consumer/waitlist   data=${data}  params=${cons_params}   expected_status=any   headers=${cons_headers}    
    RETURN  ${resp}

Get Services in Department By Consumer
    [Arguments]   ${accId}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accId}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/waitlist/department/services  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Enable location sharing by consumer
    [Arguments]  ${pId}   ${waitlist_id}  ${Phonenumber}  ${travelMode}  ${startTimeMode}  ${lattitude}  ${longitude}   ${shareLocStatus}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${pId}
    ${geolocation}=  Create Dictionary   latitude=${lattitude}   longitude=${longitude}
    ${data}=   Create Dictionary   waitlistPhonenumber=${Phonenumber}   jaldeeGeoLocation=${geolocation}   travelMode=${travelMode}   shareLocStatus=${shareLocStatus}   jaldeeStartTimeMod=${startTimeMode}
    ${data}=   json.dumps   ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session  
    ${resp}=    POST On Session    ynw  /consumer/waitlist/saveMyLoc/${waitlist_id}   data=${data}  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Disable location sharing by consumer
    [Arguments]  ${waitlist_id}   ${accid}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accid}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    DELETE On Session    ynw  /consumer/waitlist/unshareMyLoc/${waitlist_id}    params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

# Enable tracking by consumer
#     [Arguments]     ${waitlist_id}
#     Check And Create YNW Session  
#     ${resp}=    PUT On Session    ynw  /consumer/waitlist/start/mytracking/${waitlist_id}   expected_status=any   headers=${cons_headers}
#     RETURN  ${resp}

Enable tracking by consumer
    [Arguments]    ${waitlist_id}   ${accid}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accid}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  /consumer/waitlist/start/mytracking/${waitlist_id}   params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}    

Update consumer location
    [Arguments]   ${pId}  ${waitlist_id}  ${lattitude}  ${longitude}   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${pId}
    ${data}=  Create Dictionary   latitude=${lattitude}   longitude=${longitude}
    ${data}=   json.dumps   ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  /consumer/waitlist/update/latlong/${waitlist_id}   data=${data}   params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

update consumer travelmode
    [Arguments]   ${pId}  ${waitlist_id}  ${travelMode}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${pId}
    ${data}=   Create Dictionary   travelMode=${travelMode}
    ${data}=   json.dumps   ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  /consumer/waitlist/update/travelmode/${waitlist_id}   data=${data}  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

check start status
    [Arguments]   ${pId}  ${waitlist_id}   &{kwargs}  #${timeZone}=Asia/Kolkata
    # ${cons_headers}=  Create Dictionary  &{headers} 
    # ${cons_params}=  Create Dictionary  account=${pId}
    # ${data}=   Create Dictionary   travelMode=${travelMode}
    # ${data}=   json.dumps   ${data}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session   ynw  /consumer/waitlist/status/mytracking/${waitlist_id}   params=${cons_params}  expected_status=any   headers=${cons_headers}  
    RETURN  ${resp}

Get Appointment Schedules Consumer
    [Arguments]  ${acct_id}   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${acct_id} 
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}  
    Check And Create YNW Session
    # Set To Dictionary  ${cons_headers}   timeZone=${timeZone}
    ${resp}=  GET On Session  ynw  /consumer/appointment/schedule    params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get Appointment Schedule ById Consumer
    [Arguments]  ${scheduleId}  ${acct_id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${acct_id}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    # Set To Dictionary  ${cons_headers}   timeZone=${timeZone}
    ${resp}=  GET On Session  ynw  /consumer/appointment/schedule/${scheduleId}    params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get Appointment Slots By Schedule and Date
    [Arguments]  ${scheduleId}  ${date}  ${acct_id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${acct_id}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    # Set To Dictionary  ${cons_headers}   timeZone=${timeZone}
    ${resp}=  GET On Session  ynw  /consumer/appointment/schedule/${scheduleId}/${date}    params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get All Schedule Slots Today By Location and Service
    [Arguments]  ${acct_id}  ${locationId}  ${serviceId}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${acct_id}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/appointment/schedule/today/location/${locationId}/service/${serviceId}    params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get All Schedule Slots By Date Location and Service
    [Arguments]  ${acct_id}  ${date}  ${locationId}  ${serviceId}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${acct_id}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/appointment/schedule/date/${date}/location/${locationId}/service/${serviceId}    params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get Next Available Appointment Slots By ScheduleId
    [Arguments]  ${scheduleId}  ${acct_id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${acct_id}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/appointment/schedule/nextAvailable/${scheduleId}    params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get Next Available Appointment Time
    [Arguments]  ${acct_id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${acct_id}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/appointment/schedule/nextAvailableApptTime    params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get Appmt Schedule By ServiceId and LocationId
    [Arguments]   ${acct_id}    ${locationId}   ${serviceId}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${acct_id}  
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/appointment/schedule/location/${locationId}/service/${serviceId}    params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get Appmt Schedule By ServiceId_LocationId and Date
    [Arguments]   ${acct_id}  ${locationId}  ${serviceId}  ${DATE}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${acct_id}  
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/appointment/schedule/location/${locationId}/service/${serviceId}/date/${DATE}    params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Donation By Consumer
    [Arguments]  ${c_id}  ${s_id}  ${loc_id}  ${amt}  ${d_fname}  ${d_lname}  ${d_add}  ${d_ph}  ${d_email}  ${acct_id}  ${countryCode}=+91  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${acct_id}
    ${con_id}=  Create Dictionary  id=${c_id}
    ${ser_id}=  Create Dictionary  id=${s_id}
    ${location_id}=  Create Dictionary  id=${loc_id}
    ${donar_det}=  Create Dictionary  firstName=${d_fname}  lastName=${d_lname}  address=${d_add}  phoneNo=${d_ph}  email=${d_email}  countryCode=${countryCode}
    ${data}=  Create Dictionary  consumer=${con_id}   service=${ser_id}  location=${location_id}  donationAmount=${amt}  donor=${donar_det}
    ${data}=   json.dumps   ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw  /consumer/donation   data=${data}  expected_status=any   headers=${cons_headers}   params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get Consumer Donation By Id
    [Arguments]  ${id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /consumer/donation/${id}   params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get Donations By Consumer
    [Arguments]    &{kwargs}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/donation   params=${kwargs}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get Donation Count By Consumer
    [Arguments]    &{kwargs}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/donation/count  params=${kwargs}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get Donation Service By Consumer
    [Arguments]  ${acct_id}   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${acct_id}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/donation/services    params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get Payment Details
    [Arguments]   &{cons_params}
    ${cons_headers}=  Create Dictionary  &{headers}
    ${headers}  ${cons_params}  ${locparam}=  db.Set_TZ_Header  &{cons_params}
    Log  ${cons_params}
    ${cons_headers}=  Create Dictionary  &{headers} 
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /consumer/payment     params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get Payment Details By UUId
    [Arguments]  ${uuid}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /consumer/payment/details/${uuid}  params=${cons_params}  expected_status=any   headers=${cons_headers} 
    RETURN  ${resp}

Get Individual Payment Records
    [Arguments]  ${id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /consumer/payment/${id}   params=${cons_params}   expected_status=any   headers=${cons_headers}   
    RETURN  ${resp}
    
Take Appointment For Provider 
    [Arguments]    ${accid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${appmtFor}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accid}
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}    
    ${data}=    Create Dictionary    appointmentMode=ONLINE_APPOINTMENT   account=${accId}   service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}
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
    ${resp}=  POST On Session  ynw   url=/consumer/appointment  params=${cons_params}  data=${data}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Take Phonein Appointment For Provider 
    [Arguments]    ${accid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${appmtFor}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}    
    ${data}=    Create Dictionary    appointmentMode=PHONE_IN_APPOINTMENT   account=${accId}   service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}
    ${data}=  json.dumps  ${data}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   url=/consumer/appointment?account=${accId}  data=${data}  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Take Appointment For User 
    [Arguments]    ${accid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${u_id}  ${appmtFor}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}
    ${uid}=  Create Dictionary  id=${u_id}    
    ${data}=    Create Dictionary    appointmentMode=ONLINE_APPOINTMENT   account=${accId}   service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}   provider=${uid}
    ${data}=  json.dumps  ${data}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   url=/consumer/appointment?account=${accId}  data=${data}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Take Appointment For Provider with Phone no
    [Arguments]    ${accid}  ${service_id}  ${schedule}  ${appmtDate}  ${phoneNumber}  ${appmtFor}  ${country_code}=+91  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}    
    ${data}=    Create Dictionary    appointmentMode=ONLINE_APPOINTMENT   account=${accId}   service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  phoneNumber=${phoneNumber}  countryCode=${country_code}
    ${data}=  json.dumps  ${data}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   url=/consumer/appointment?account=${accId}  data=${data}  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}



Take Virtual Service Appointment For Provider 
    [Arguments]    ${accid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${CallingModes}  ${CallingModes_id1}  ${appmtFor}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule} 
    ${virtualService}=  Create Dictionary   ${CallingModes}=${CallingModes_id1}    
    ${data}=    Create Dictionary    appointmentMode=ONLINE_APPOINTMENT   account=${accId}   service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}   virtualService=${virtualService}
    ${data}=  json.dumps  ${data}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   url=/consumer/appointment?account=${accId}  data=${data}  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Phone-in Virtual Service Appointment For Provider 
    [Arguments]    ${accid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${CallingModes}  ${CallingModes_id1}  ${appmtFor}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule} 
    ${virtualService}=  Create Dictionary   ${CallingModes}=${CallingModes_id1}    
    ${data}=    Create Dictionary    appointmentMode=PHONE_IN_APPOINTMENT   account=${accId}   service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}   virtualService=${virtualService}
    ${data}=  json.dumps  ${data}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   url=/consumer/appointment?account=${accId}  data=${data}  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}



Take Virtual Service Appointment For User 
    [Arguments]    ${accid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${CallingModes}  ${CallingModes_id1}  ${u_id}  ${appmtFor}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${user_id}=  Create Dictionary  id=${u_id}
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule} 
    ${virtualService}=  Create Dictionary   ${CallingModes}=${CallingModes_id1}    
    ${data}=    Create Dictionary    appointmentMode=ONLINE_APPOINTMENT   account=${accId}   service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}   virtualService=${virtualService}  provider=${user_id}
    ${data}=  json.dumps  ${data}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   url=/consumer/appointment?account=${accId}  data=${data}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Take Appointment with ApptMode For Provider
    [Arguments]    ${apptMode}   ${accid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${appmtFor}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}    
    ${data}=    Create Dictionary    appointmentMode=${apptMode}   account=${accId}   service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}
    ${data}=  json.dumps  ${data}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   url=/consumer/appointment?account=${accId}  data=${data}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get consumer Appointment By Id
    [Arguments]   ${accId}  ${appmntId}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  url=/consumer/appointment/${appmntId}?account=${accId}   params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get Consumer Waitlist By EncodedId
    [Arguments]    ${W_Enc_id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /consumer/waitlist/enc/${W_Enc_id}   params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}
    
Get Consumer Appointment By EncodedId
    [Arguments]    ${A_Enc_id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /consumer/appointment/enc/${A_Enc_id}   params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp} 
  
Cancel Appointment By Consumer
    [Arguments]  ${appmntId}  ${acct_id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${acct_id}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /consumer/appointment/cancel/${appmntId}   params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get Consumer Appointments Today
    [Arguments]  ${timeZone}=Asia/Kolkata  &{kwargs}  #&{kwargs}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /consumer/appointment/today  params=${kwargs}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get Appmt Service By LocationId
    [Arguments]   ${locationId}   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/appointment/service/${locationId}   params=${cons_params}  expected_status=any   headers=${cons_headers} 
    RETURN  ${resp}

Get Consumer Appmt Today Count
    [Arguments]   &{kwargs}  
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${kwargs}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/appointment/today/count  params=${kwargs}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get Consumer Appointments 
    [Arguments]   &{kwargs}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /consumer/appointment  params=${kwargs}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

#Livetracking
Enable apptment SaveMyLocation by consumer
    [Arguments]  ${pId}   ${Appmt_id}  ${Phonenumber}  ${travelMode}  ${startTimeMode}  ${lattitude}  ${longitude}   ${shareLocStatus}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${pId}
    ${geolocation}=  Create Dictionary   latitude=${lattitude}   longitude=${longitude}
    ${data}=   Create Dictionary   apptPhonenumber=${Phonenumber}   jaldeeGeoLocation=${geolocation}   travelMode=${travelMode}   shareLocStatus=${shareLocStatus}   jaldeeStartTimeMod=${startTimeMode}
    ${data}=   json.dumps   ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw     /consumer/appointment/saveMyLoc/${Appmt_id}   data=${data}  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Locate apptment consumer
    [Arguments]   ${appmt_id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  /consumer/appointment/live/locate/distance/time/${appmt_id}   params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Start apptment tracking by consumer
    [Arguments]   ${accId}   ${appmt_id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  url=/consumer/appointment/start/mytracking/${appmt_id}?account=${accId}   params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Stop apptment tracking by consumer
    [Arguments]   ${appmt_id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    DELETE On Session    ynw  /consumer/appointment/stop/mytracking/${appmt_id}   params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get apptment Livetrack Status
    [Arguments]   ${appmt_id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/appointment/status/mytracking/${appmt_id}   params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Disable apptment unshareMylocation by consumer
    [Arguments]  ${accId}   ${appmt_id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    DELETE On Session    ynw  url=/consumer/appointment/unshareMyLoc/${appmt_id}?account=${accId}   params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Update Consumer apptment latlong
    [Arguments]   ${pId}  ${appmt_id}  ${lattitude}  ${longitude}   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${pId}
    ${data}=  Create Dictionary   latitude=${lattitude}   longitude=${longitude}
    ${data}=   json.dumps   ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw   /consumer/appointment/update/latlong/${appmt_id}   data=${data}  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}
    
Update Consumer apptment MyLocation
    [Arguments]   ${pId}  ${appmt_id}  ${lattitude}  ${longitude}   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${pId}
    ${data}=  Create Dictionary   latitude=${lattitude}   longitude=${longitude}
    ${data}=   json.dumps   ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw   /consumer/appointment/updateMyLoc/${appmt_id}   data=${data}  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Update consumer apptment tavelmode
    [Arguments]   ${pId}  ${appmt_id}  ${travelMode}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${pId}
    ${data}=   Create Dictionary   travelMode=${travelMode}
    ${data}=   json.dumps   ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  /consumer/appointment/update/travelmode/${appmt_id}   data=${data}  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get Consumer Future Appointments
    [Arguments]    &{kwargs}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${kwargs}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/appointment/future    params=${kwargs}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}
    
Get Consumer Future Appointments Count
    [Arguments]    &{kwargs}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${kwargs}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/appointment/future/count   params=${kwargs}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Add Appointment Rating
	[Arguments]  ${accid}  ${uuid}  ${stars}  ${feedback}  &{kwargs}  #${timeZone}=Asia/Kolkata
	${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accid}  
	${data}=  Create Dictionary  uuid=${uuid}  stars=${stars}  feedback=${feedback}
    ${data}=  json.dumps  ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /consumer/appointment/rating  params=${cons_params}  data=${data}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Update Appointment Rating
	[Arguments]  ${accid}  ${uuid}  ${stars}  ${feedback}  &{kwargs}  #${timeZone}=Asia/Kolkata
	${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accid}  
	${data}=  Create Dictionary  uuid=${uuid}  stars=${stars}  feedback=${feedback}
    ${data}=  json.dumps  ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /consumer/appointment/rating  params=${cons_params}  data=${data}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp} 

Get Appointment Rating
    [Arguments]    &{kwargs}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${kwargs}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/appointment/rating  params=${kwargs}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}
   
Get Consumer Appointments History
    [Arguments]     &{kwargs}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${kwargs}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/appointment/history   params=${kwargs}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}
    
Get Consumer Appointments History Count
    [Arguments]     &{kwargs}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${kwargs}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/appointment/history/count   params=${kwargs}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get Waitlist Meeting Details
    [Arguments]  ${uid}  ${mode}  ${acc}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${acc}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  url=/consumer/waitlist/${uid}/meetingDetails/${mode}?account=${acc}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get Appointment Meeting Details
    [Arguments]  ${uid}  ${mode}  ${acc}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  url=/consumer/appointment/${uid}/meetingDetails/${mode}?account=${acc}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Availability Of Queue By Consumer
    [Arguments]  ${locationId}  ${serviceId}  ${accId}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary   account=${accId}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /consumer/waitlist/queues/available/${locationId}/${serviceId}   params=${cons_params}   expected_status=any   headers=${cons_headers}     
    RETURN  ${resp}


Reschedule Appointment
    [Arguments]  ${acc_id}   ${appt_id}   ${time_slot}   ${date}  ${sch_id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${acc_id}
    ${data}=  Create Dictionary  uid=${appt_id}   time=${time_slot}  date=${date}   schedule=${sch_id}
    ${data}=  json.dumps  ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  PUT On Session   ynw   /consumer/appointment/reschedule   params=${cons_params}  data=${data}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}
    

Reschedule Waitlist
    [Arguments]  ${acc_id}   ${wl_id}   ${date}   ${q_id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${acc_id}
    ${data}=  Create Dictionary   ynwUuid=${wl_id}  date=${date}  queue=${q_id} 
    ${data}=  json.dumps  ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  PUT On Session   ynw   /consumer/waitlist/reschedule   params=${cons_params}  data=${data}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get consumer Appointment MR By Id
    [Arguments]     ${appmntId}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/appointment/mr/${appmntId}   params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get consumer Waitlist MR By Id
    [Arguments]     ${uuid}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/waitlist/mr/${uuid}   params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Update Consumer Delivery Address
    [Arguments]  ${phoneNumber}  ${firstName}  ${lastName}  ${email}  ${address}  ${city}   ${postalCode}   ${landMark}   ${countryCode}=+91   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${deliveryaddress}=    Create Dictionary  phoneNumber=${phoneNumber}  firstName=${firstName}  lastName=${lastName}  email=${email}  address=${address}  city=${city}  postalCode=${postalCode}  landMark=${landMark}  countryCode=${countryCode}
    ${data}=  Create List   ${deliveryaddress}
    ${data}=   json.dumps    ${data}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /consumer/deliveryAddress    data=${data}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get Consumer Delivery Address
    [Arguments]     &{kwargs}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/deliveryAddress   params=${kwargs}   params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

# -------------------------

Create Order For HomeDelivery
    [Arguments]   ${Cookie}   ${accId}   ${orderFor}    ${CatalogId}   ${homeDelivery}    ${homeDeliveryAddress}  ${sTime1}    ${eTime1}   ${orderDate}    ${phoneNumber}    ${email}  ${countryCode}  ${coupons}  @{vargs}  &{kwargs}  #${timeZone}=Asia/Kolkata      
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
    # Set To Dictionary  ${form_headers}   timeZone=${timeZone}
    ${form_headers}=  Create Dictionary
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${form_headers}   &{tzheaders}
    # Set To Dictionary  ${cons_params}   &{locparam}
    ${resp}=  ShoppingCartUpload   ${Cookie}   ${accId}   ${order}  ${form_headers}  &{kwargs}
    RETURN  ${resp} 


Create Order For Pickup
    [Arguments]   ${Cookie}   ${accId}   ${orderFor}    ${CatalogId}   ${storePickup}    ${sTime1}    ${eTime1}   ${orderDate}    ${phoneNumber}    ${email}  ${countryCode}  ${coupons}  @{vargs}  &{kwargs}  #${timeZone}=Asia/Kolkata
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
    # Set To Dictionary  ${form_headers}   timeZone=${timeZone}
    ${form_headers}=  Create Dictionary
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${form_headers}   &{tzheaders}
    # Set To Dictionary  ${cons_params}   &{locparam}
    ${resp}=  ShoppingCartUpload   ${Cookie}   ${accId}   ${order}  ${form_headers}  &{kwargs}
    RETURN  ${resp} 


Create Order For Electronic Delivery
    [Arguments]   ${Cookie}   ${accId}   ${orderFor}    ${CatalogId}   ${orderDate}    ${phoneNumber}    ${email}  ${countryCode}  ${coupons}  @{vargs}  &{kwargs}  #${timeZone}=Asia/Kolkata
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
    # Set To Dictionary  ${form_headers}   timeZone=${timeZone}
    ${form_headers}=  Create Dictionary
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${form_headers}   &{tzheaders}
    # Set To Dictionary  ${cons_params}   &{locparam}
    ${resp}=  ShoppingCartUpload   ${Cookie}   ${accId}   ${order}  ${form_headers}  &{kwargs}
    RETURN  ${resp} 


Get Cart Details
    [Arguments]   ${accId}   ${CatalogId}   ${homeDelivery}  ${orderDate}   ${coupons}  @{vargs}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accId}
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
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   url=/consumer/orders/amount  data=${data}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}



Upload ShoppingList Image for Pickup
    [Arguments]   ${cookie}   ${accId}   ${caption}   ${orderFor}    ${CatalogId}   ${storePickup}    ${Date}    ${sTime1}    ${eTime1}   ${phoneNumber}  ${email}   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${catalog}=  Create Dictionary  id=${CatalogId}
    ${orderFor}=  Create Dictionary  id=${orderFor}
    ${timeSlot}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${order}=  Create Dictionary  storePickup=${storePickup}  catalog=${catalog}  orderFor=${orderFor}  orderDate=${Date}   timeSlot=${timeSlot}  phoneNumber=${phoneNumber}  countryCode=+91  email=${email}
    # Set To Dictionary  ${form_headers}   timeZone=${timeZone}
    ${form_headers}=  Create Dictionary 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${form_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    ${resp}=  OrderImageUpload   ${Cookie}   ${accId}   ${caption}   ${order}  ${form_headers}  &{kwargs}
    RETURN  ${resp} 


Upload ShoppingList Image for HomeDelivery
    [Arguments]   ${cookie}   ${accId}   ${caption}   ${orderFor}    ${CatalogId}   ${homeDelivery}    ${homeDeliveryAddress}  ${Date}    ${sTime1}    ${eTime1}   ${phoneNumber}    ${email}   @{vargs}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${catalog}=  Create Dictionary  id=${CatalogId}
    ${orderFor}=  Create Dictionary  id=${orderFor}
    ${timeSlot}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${len}=  Get Length  ${vargs}
    ${coupons}=  Create List
    FOR    ${index}    IN RANGE  0  ${len}
        Append To List  ${coupons}  ${vargs[${index}]}
    END
    ${order}=  Create Dictionary  homeDelivery=${homeDelivery}  homeDeliveryAddress=${homeDeliveryAddress}   catalog=${catalog}  orderFor=${orderFor}  orderDate=${Date}   timeSlot=${timeSlot}  phoneNumber=${phoneNumber}  countryCode=+91  email=${email}  coupons=${coupons}
    # Set To Dictionary  ${form_headers}   timeZone=${timeZone}
    ${form_headers}=  Create Dictionary 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${form_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    ${resp}=  OrderImageUpload   ${Cookie}   ${accId}   ${caption}   ${order}  ${form_headers}  &{kwargs}
    RETURN  ${resp} 


Get Order By Id
    [Arguments]    ${accId}   ${uuid}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accId}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  url=/consumer/orders/${uuid}   params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get Order By Criteria
    [Arguments]   &{kwargs}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/orders  params=${kwargs}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get Consumer Order Count By Criteria
    [Arguments]   &{kwargs}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/orders/count  params=${kwargs}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get Catalog By AccId
    [Arguments]    ${accId}   &{kwargs}  #${timeZone}=Asia/Kolkata
    # ${cons_headers}=  Create Dictionary  &{headers} 
    # ${cons_params}=  Create Dictionary  account=${accId}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/orders/catalogs/${accId}   params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get Pickup Dates By Catalog
    [Arguments]   ${accId}   ${catalogId}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accId}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   url=/consumer/orders/catalogs/pickUp/dates/${catalogId}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get HomeDelivery Dates By Catalog
    [Arguments]   ${accId}  ${catalogId}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accId}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   url=/consumer/orders/catalogs/delivery/dates/${catalogId}   params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get Future Order 
    [Arguments]   &{kwargs} 
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${kwargs}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/orders/future  params=${kwargs}   expected_status=any   headers=${cons_headers}   
    RETURN  ${resp}            
    
    
Get Future Order Count 
    [Arguments]   &{kwargs} 
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${kwargs}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/orders/future/count  params=${kwargs}   expected_status=any   headers=${cons_headers}   
    RETURN  ${resp} 


Get StoreContact Info
    [Arguments]  ${accId}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/orders/settings/store/contact/info/${accId}  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get Order Settings of Provider
    [Arguments]  ${accId}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  url=/consumer/orders/settings?account=${accId}   params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Update Email For Order
    [Arguments]  ${accId}   ${uid}   ${email}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accId}
    ${email}=  json.dumps  ${email} 
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  PUT On Session   ynw   url=/consumer/orders/${uid}/email   params=${cons_params}   data=${email}   expected_status=any   headers=${cons_headers} 
    RETURN  ${resp}


Get Item By Catalog
    [Arguments]    ${catalogId}  ${itemId}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/orders/catalog/${catalogId}/item/${itemId}   params=${cons_params}   expected_status=any   headers=${cons_headers}

    RETURN  ${resp}


Cancel Order By Consumer
    [Arguments]  ${accountId}   ${uid}   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accountId}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  PUT On Session   ynw   url=/consumer/orders/${uid}   params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get Order By EncodedId
    [Arguments]    ${encId}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /consumer/orders/enc/${encId}   params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp} 

 
Get Consumer Order History 
    [Arguments]   &{cons_params}
    ${cons_headers}=  Create Dictionary  &{headers}
    ${tzheaders}  ${cons_params}  ${locparam}=  db.Set_TZ_Header  &{params}
    Log  ${cons_params}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /consumer/orders/history  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get Consumer Order History Count
    [Arguments]  &{cons_params}
    ${cons_headers}=  Create Dictionary  &{headers}
    ${tzheaders}  ${cons_params}  ${locparam}=  db.Set_TZ_Header  &{params}
    Log  ${cons_params}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/orders/history/count  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Add Order Rating
	[Arguments]  ${accid}  ${uuid}  ${stars}  ${feedback}  &{kwargs}  #${timeZone}=Asia/Kolkata
	${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accid}  
	${data}=  Create Dictionary  uId=${uuid}  stars=${stars}  feedback=${feedback}
    ${data}=  json.dumps  ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /consumer/orders/rating  params=${cons_params}  data=${data}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Update Order Rating
	[Arguments]  ${accid}  ${uuid}  ${stars}  ${feedback}  &{kwargs}  #${timeZone}=Asia/Kolkata
	${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accid}  
	${data}=  Create Dictionary  uId=${uuid}  stars=${stars}  feedback=${feedback}
    ${data}=  json.dumps  ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /consumer/orders/rating  params=${cons_params}  data=${data}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp} 


Get Order Rating
    [Arguments]    &{kwargs}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${kwargs}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/orders/rating  params=${kwargs}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get Consumer Waitlist Attachment
   [Arguments]    ${accid}   ${uuid}  &{kwargs}  #${timeZone}=Asia/Kolkata
   ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accid}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
   Log  ${kwargs}
   Set To Dictionary  ${cons_headers}   &{tzheaders}
   Set To Dictionary  ${cons_params}   &{locparam}
   Check And Create YNW Session
   ${resp}=    GET On Session    ynw  /consumer/waitlist/attachment/${uuid}   params=${cons_params}   expected_status=any   headers=${cons_headers}
   RETURN  ${resp}


Get Consumer Wallet
    [Arguments]   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/wallet/eligible  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get All Jaldee Cash Available
    [Arguments]   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/wallet/cash/available  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get Jaldee Cash Available By Id 
    [Arguments]  ${jcashid}   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/wallet/cash/${jcashid}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get Jaldee Cash Details
    [Arguments]   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/wallet/cash/info  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get Jaldee Cash Expired
    [Arguments]   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/wallet/cash/expired  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get Remaining Amount To Pay
    [Arguments]  ${useJcash}   ${useJcredit}   ${AdvanceAmt}  &{kwargs}  #${timeZone}=Asia/Kolkata
    
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  useJcash=${useJcash}  useJcredit=${useJcredit}  advancePayAmount=${AdvanceAmt}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   url=/consumer/wallet/redeem/remaining/amt?useJcash=${useJcash}&useJcredit=${useJcredit}&advancePayAmount=${AdvanceAmt}     expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get Total JCash And Credit Amount
    [Arguments]   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/wallet/redeem/eligible/amt     expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get Total Credit Available
    [Arguments]   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/wallet/credit     expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Make Jcash Payment Consumer Mock
    [Arguments]  ${amount}  ${response}  ${uuid}  ${accid}  ${purpose}  ${isJcashUsed}  ${isreditUsed}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${data}=  Create Dictionary  amountToPay=${amount}  paymentMode=Mock  uuid=${uuid}  mockResponse=${response}  accountId=${accid}  paymentPurpose=${purpose}  isJcashUsed=${isJcashUsed}  isreditUsed=${isreditUsed}
    ${data}=  json.dumps  ${data}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  POST On Session    ynw  /consumer/payment/wallet  data=${data}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Waitlist AdvancePayment Details
    [Arguments]  ${accId}  ${queueId}  ${date}  ${serviceId}  ${consumerNote}  ${revealPhone}  ${coupons}  @{vargs}  &{kwargs}  #${timeZone}=Asia/Kolkata 
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accId}
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
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    PUT On Session  ynw  /consumer/waitlist/advancePayment   data=${data}  params=${cons_params}   expected_status=any   headers=${cons_headers}    
    RETURN  ${resp}


Appointment AdvancePayment Details
    [Arguments]    ${accid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${appmtFor}  ${coupons}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}    
    ${data}=    Create Dictionary    appointmentMode=ONLINE_APPOINTMENT   account=${accId}   service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}  coupons=${coupons}
    ${data}=  json.dumps  ${data}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   url=/consumer/appointment/advancePayment?account=${accId}  data=${data}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Appointment AdvancePayment Details without Coupon
    [Arguments]    ${accid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${appmtFor}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}    
    ${data}=    Create Dictionary    appointmentMode=ONLINE_APPOINTMENT   account=${accId}   service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}
    ${data}=  json.dumps  ${data}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   url=/consumer/appointment/advancePayment?account=${accId}  data=${data}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Consumer View Questionnaire
    [Arguments]    ${accid}   ${serviceId}  ${consumerId}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accid}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session   ynw  /consumer/questionnaire/service/${serviceId}/consumer/${consumerId}   params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get Donation Questionnaire By Id    
    [Arguments]  ${accid}   ${don_id}   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accid}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/questionnaire/donation/${don_id}  params=${cons_params}   expected_status=any   headers=${cons_headers}   
    RETURN  ${resp}


Consumer Validate Questionnaire
    [Arguments]  ${accid}   ${data}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accid}
    # ${data}=  json.dumps  ${data}
    Log  ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /consumer/questionnaire/validate  data=${data}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Consumer Change Answer Status for Waitlist
    [Arguments]  ${accid}   ${wlId}  ${fileId}  ${labelname}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accid}
    ${filedata}=  Create Dictionary  uid=${fileId}  labelName=${labelname}  
    ${filedata}=  Create List  ${filedata}
    ${data}=  Create Dictionary  urls=${filedata} 
    ${data}=  json.dumps  ${data} 
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /consumer/waitlist/questionnaire/upload/status/${wlId}  data=${data}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}    


Consumer Change Answer Status for Appointment
    [Arguments]  ${accid}   ${apptId}  ${fileId}  ${labelname}   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accid}
    ${filedata}=  Create Dictionary  uid=${fileId}  labelName=${labelname}
    ${filedata}=  Create List  ${filedata}
    ${data}=  Create Dictionary  urls=${filedata} 
    ${data}=  json.dumps  ${data} 
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /consumer/appointment/questionnaire/upload/status/${apptId}  data=${data}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}  


Consumer Revalidate Questionnaire
    [Arguments]  ${accid}   ${data}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accid}
    Log  ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /consumer/questionnaire/resubmit/validate  data=${data}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get Consumer Questionnaire By uuid For Waitlist
    [Arguments]  ${uuid}   ${accId}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accId}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session  ynw  url=/consumer/waitlist/questionnaire/${uuid}   params=${cons_params}   expected_status=any   headers=${cons_headers}     
    RETURN  ${resp}

Get Consumer Questionnaire By uuid For Appmnt
    [Arguments]  ${uuid}   ${accId}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accId}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session  ynw  url=/consumer/appointment/questionnaire/${uuid}   params=${cons_params}  expected_status=any   headers=${cons_headers}     
    RETURN  ${resp}

Consumer SignUp Via QRcode
    [Arguments]  ${firstname}  ${lastname}  ${primaryNo}   ${countryCode}   ${aacid}    ${email}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${usp}=   Create Dictionary   firstName=${firstname}  lastName=${lastname}  primaryMobileNo=${primaryNo}  countryCode=${countryCode}    email=${email}
    ${data}=  Create Dictionary    userProfile=${usp}    accountId=${aacid}
    ${data}=  json.dumps  ${data}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw    /consumer   data=${data}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get NextAvailableSchedule appt consumer
    [Arguments]      ${pid}    ${lid}   ${u_id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /consumer/appointment/schedule/nextAvailableSchedule/${pid}-${lid}-${u_id}    params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN  ${resp}


Get payment modes
    [Arguments]  ${accountId}   ${serviceId}   ${paymentPurpose}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /consumer/payment/modes/${accountId}/${serviceId}/${paymentPurpose}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get Questionnaire By CatalogID    
    [Arguments]  ${catalogId1}  ${account_id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${account_id}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  url=/consumer/questionnaire/order/${catalogId1}  params=${cons_params}  expected_status=any   headers=${cons_headers}     
    RETURN  ${resp}

Consumer Get Order Questionnaire By uuid 
    [Arguments]  ${uuid}  ${account_id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${account_id}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/orders/questionnaire/${uuid}  params=${cons_params}  expected_status=any   headers=${cons_headers}     
    RETURN  ${resp}

Consumer Upload Status for Appnt
    [Arguments]  ${uuid}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /consumer/appointment/serviceoption/upload/status/${uuid}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get service options for an item
    [Arguments]  ${item}  ${accountId}  &{kwargs}  #${timeZone}=Asia/Kolkata
    comment    login bypassed url
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accountId}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   url=/consumer/questionnaire/serviceoptions/order/item/${item}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN    ${resp} 

Get Service Options By Service
    [Arguments]      ${ser_id}  ${consumer}   ${accountId}   &{kwargs}  #${timeZone}=Asia/Kolkata 
    comment    login bypassed url
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accountId} 
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   url=/consumer/questionnaire/serviceoptions/${ser_id}/${consumer}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get Service Options By Order
    [Arguments]      ${catalogid}   ${accountId}  &{kwargs}  #${timeZone}=Asia/Kolkata 
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accountId} 
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   url=/consumer/questionnaire/serviceoptions/order/${catalogid}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Get Service Options By Donation
    [Arguments]   ${uuid}   ${accountId}  &{kwargs}  #${timeZone}=Asia/Kolkata 
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accountId} 
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   url=/consumer/questionnaire/serviceoptions/donation/${uuid}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Change Status Of Service Option Item
    [Arguments]  ${accountId}  ${uuid}  @{filedata}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accountId} 
    ${data}=    Create Dictionary   urls=${filedata}
    ${data}=  json.dumps  ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=   PUT On Session  ynw  url=/consumer/orders/item/serviceoption/upload/status/${uuid}  params=${cons_params}  data=${data}   expected_status=any   headers=${cons_headers}
    RETURN    ${resp}

Change Status Of Service Option Appmt
    [Arguments]  ${accountId}  ${uuid}  @{filedata}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accountId} 
    ${data}=    Create Dictionary   urls=${filedata}
    ${data}=  json.dumps  ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=   PUT On Session  ynw  url=/consumer/appointment/serviceoption/upload/status/${uuid}  params=${cons_params}  data=${data}   expected_status=any   headers=${cons_headers}
    RETURN    ${resp}

Change Status Of Service Option Waitlist
    [Arguments]  ${accountId}  ${uuid}  @{filedata}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accountId}
    ${data}=    Create Dictionary   urls=${filedata}
    ${data}=  json.dumps  ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=   PUT On Session  ynw  url=/consumer/waitlist/serviceoption/upload/status/${uuid}  params=${cons_params}  data=${data}   expected_status=any   headers=${cons_headers}
    RETURN    ${resp}

Change Status Of Service Option Order
    [Arguments]  ${accountId}  ${uuid}  @{filedata}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accountId}
    ${data}=    Create Dictionary   urls=${filedata}
    ${data}=  json.dumps  ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=   PUT On Session  ynw  url=/consumer/orders/serviceoption/upload/status/${uuid}  params=${cons_params}  data=${data}   expected_status=any   headers=${cons_headers}
    RETURN    ${resp}

Change Status Of Service Option Donation
    [Arguments]  ${accountId}  ${uuid}  @{filedata}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accountId}
    ${data}=    Create Dictionary   urls=${filedata}
    ${data}=  json.dumps  ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=   PUT On Session  ynw  url=/consumer/donation/serviceoption/upload/status/${uuid}  params=${cons_params}  data=${data}   expected_status=any   headers=${cons_headers}
    RETURN    ${resp}


Create Payment Link For Donation
    [Arguments]  ${con_id}  ${countryCode}  ${CUR_DAY}  ${don_amt1}  ${donar_fname}  ${donar_lname}  ${donorEmail}  ${ph1}  ${loc_id1}  ${note}  ${sid1}  ${acc_id}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary  account=${accId}
    ${consumer_id}=  Create Dictionary  id=${con_id}
    ${donor_data}=  Create Dictionary  firstName=${donar_fname}  lastName=${donar_lname}
    ${location_data}=  Create Dictionary  id=${loc_id1}
    ${service_data}=  Create Dictionary  id=${sid1}
    ${data}=  Create Dictionary  consumer=${consumer_id}  countryCode=${countryCode}  date=${CUR_DAY}  donationAmount=${don_amt1}  
    ...   donor=${donor_data}  donorEmail=${donorEmail}  donorPhoneNumber=${ph1}  location=${location_data}  note=${note}
    ...   service=${service_data}   
    ${data}=   json.dumps   ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    POST On Session  ynw  url=/consumer/payment/generate/paylink   params=${cons_params}  data=${data}  expected_status=any   headers=${cons_headers}    
    RETURN  ${resp}

Get Donation Details
    [Arguments]  ${uuid}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/payment/paylink/donation/${uuid}  params=${cons_params}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Donation Payment Via Link
    [Arguments]  ${acc_id}  ${custId}  ${amount}  ${isInternational}  ${paymentMode}  ${purpose}  ${serviceId}   ${source}   ${uuid}  ${pay_link}  ${response}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${data}=  Create Dictionary  accountId=${acc_id}  custId=${custId}  amount=${amount}  isInternational=${isInternational}  
    ...   paymentMode=${paymentMode}  purpose=${purpose}  serviceId=${serviceId}  source=${source}  paylink=${pay_link}  uuid=${uuid}
    ...    mockResponse=${response}
    ${data}=   json.dumps   ${data}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session   
    ${resp}=  POST On Session  ynw  /consumer/payment/paylink/donation  params=${cons_params}  data=${data}  expected_status=any   headers=${cons_headers}
    RETURN  ${resp}

Add Family
    [Arguments]                   ${firstname}   ${lastname}   ${dob}   ${gender}   ${email}   ${city}   ${state}   ${address}   ${primarynum}   ${alternativenum}   ${countrycode}   ${countryCodet}   ${numbert}   ${countryCodew}   ${numberw}   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${whatsAppNum}=               Create Dictionary    countryCode=${countryCodet}   number=${numbert}
    ${telegramNum}=               Create Dictionary    countryCode=${countryCodew}   number=${numberw}
    ${headers}=                   Create Dictionary    Content-Type=application/json
    ${userProfile}=               Create Dictionary    firstName=${firstname}   lastName=${lastname}   dob=${dob}   gender=${gender}   email=${email}   city=${city}  state=${state}   address=${address}  primaryMobileNo=${primarynum}   alternativePhoneNo=${alternativenum}   countryCode=${countrycode}  telegramNum=${telegramNum}   whatsAppNum=${whatsAppNum}
    ${data}=                      Create Dictionary    userProfile=${userProfile}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=                      POST On Session  ynw   /consumer/familyMember    json=${data}  params=${cons_params}   expected_status=any   headers=${cons_headers}
    RETURN                      ${resp}

Get Seropt By CatalogId
    [Arguments]    ${catalogId}  ${channel}  ${accid}  &{kwargs}  #${timeZone}=Asia/Kolkata
    comment    login bypassed url
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  url=/consumer/questionnaire/serviceoption/order/catalog/item/${catalogId}/${channel}?account=${accid}    expected_status=any   headers=${cons_headers}

    RETURN  ${resp}

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
    
    RETURN  ${order} 

Create Order With Service Options Consumer
    [Arguments]    ${cookie}  &{kwargs}
    ${srvAnswers}=    evaluate    json.loads('''${kwargs['srvAnswers']}''')    json
    # Log  ${srvAnswers}
    Set To Dictionary  ${kwargs['order']}  srvAnswers=${srvAnswers}
    # Log  ${kwargs['order']}
    # ${order}=  json.dumps  ${kwargs['order']}
    ${order}=  Set Variable  ${kwargs['order']}
    # Log  ${order} 
    # Set To Dictionary  ${form_headers}   timeZone=${timeZone}
    ${form_headers}=  Create Dictionary 
    # ${cons_params}=  Create Dictionary
    # ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    # Log  ${kwargs}
    # Set To Dictionary  ${form_headers}   &{tzheaders}
    # Set To Dictionary  ${cons_params}   &{locparam}
    ${resp}=  ShoppingCartUpload   ${Cookie}  ${account_id}   ${order}  ${form_headers}  &{kwargs}
    RETURN  ${resp}


Create Order For AuthorDemy

    [Arguments]   ${Cookie}   ${accId}   ${orderFor}    ${CatalogId}    ${orderDate}    ${phoneNumber}    ${email}  ${countryCode}  ${coupons}  @{vargs}  &{kwargs}  #${timeZone}=Asia/Kolkata
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
    # Set To Dictionary  ${form_headers}   timeZone=${timeZone}
    ${form_headers}=  Create Dictionary 
    # ${cons_params}=  Create Dictionary
    # ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    # Log  ${kwargs}
    # Set To Dictionary  ${form_headers}   &{tzheaders}
    # Set To Dictionary  ${cons_params}   &{locparam}
    ${resp}=  ShoppingCartUpload   ${Cookie}   ${accId}   ${order}  ${form_headers}  &{kwargs}
    RETURN  ${resp} 


Get Consumer
    [Arguments]    &{kwargs}
    Check And Create YNW Session
    # Set To Dictionary  ${form_headers}   timeZone=${timeZone}
    ${form_headers}=  Create Dictionary
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${form_headers}   &{tzheaders}
    Set To Dictionary  ${kwargs}   &{locparam}
    ${resp}=    GET On Session    ynw   /consumer    params=${kwargs}  expected_status=any   headers=${form_headers}
    RETURN  ${resp}


Get Users By Loc and AccId
    [Arguments]  ${accountId}  ${locationId}  &{kwargs}  #${timeZone}=Asia/Kolkata
    Check And Create YNW Session
    # Set To Dictionary  ${form_headers}   timeZone=${timeZone}
    ${form_headers}=  Create Dictionary
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${form_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    ${resp}=    GET On Session     ynw   /consumer/users/${accountId}/${locationId}  params=${cons_params}  expected_status=any   headers=${form_headers}
    RETURN  ${resp}


#   Appt Request


Consumer Create Appt Service Request
    [Arguments]      ${accId}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}   ${countryCode}   ${phoneNumber}  ${coupons}  ${appmtFor}  &{kwargs}  #${timeZone}=Asia/Kolkata
    ${sid}=  Create Dictionary  id=${service_id} 
    ${schedule}=  Create Dictionary  id=${schedule}
    ${data}=    Create Dictionary   appmtDate=${appmtDate}  service=${sid}  schedule=${schedule}
    ...   appmtFor=${appmtFor}    consumerNote=${consumerNote}  phoneNumber=${phoneNumber}   coupons=${coupons}
    ...   countryCode=${countryCode}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    # Set To Dictionary  ${form_headers}   timeZone=${timeZone}
    ${form_headers}=  Create Dictionary
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${form_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    ${resp}=  POST On Session  ynw  url=/consumer/appointment/service/request?account=${accId}  params=${cons_params}  data=${data}  expected_status=any   headers=${form_headers}
    RETURN  ${resp}


Consumer Get Appt Service Request
    [Arguments]     &{kwargs}
    Check And Create YNW Session
    # Set To Dictionary  ${form_headers}   timeZone=${timeZone}
    ${form_headers}=  Create Dictionary
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${form_headers}   &{tzheaders}
    Set To Dictionary  ${kwargs}   &{locparam}
    ${resp}=    GET On Session    ynw   /consumer/appointment/service/request  params=${kwargs}  expected_status=any   headers=${form_headers}
    RETURN  ${resp}


Consumer Get Appt Service Request Count
    [Arguments]     &{kwargs}
    Check And Create YNW Session
    # Set To Dictionary  ${form_headers}   timeZone=${timeZone}
    ${form_headers}=  Create Dictionary 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${form_headers}   &{tzheaders}
    Set To Dictionary  ${kwargs}   &{locparam}
    ${resp}=    GET On Session    ynw   /consumer/appointment/service/request/count   params=${kwargs}  expected_status=any   headers=${form_headers}
    RETURN  ${resp}

#    Jaldee Video Call

Consumer Video Call ready

    [Arguments]  ${uuid}  ${recordingFlag}  &{kwargs}  #${timeZone}=Asia/Kolkata

    ${data}=  Create Dictionary   uuid=${uuid}    recordingFlag=${recordingFlag}
    ${data}=    json.dumps    ${data}
    # Set To Dictionary  ${form_headers}   timeZone=${timeZone}
    ${form_headers}=  Create Dictionary 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${form_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /consumer/waitlist/videocall/ready   data=${data}  params=${cons_params}  expected_status=any   headers=${form_headers}
    Log  ${resp.content}
    RETURN  ${resp}



Get convenienceFee Details 
    [Arguments]  ${accountId}  ${profileId}  ${amount}  &{kwargs}
    ${data}=    Create Dictionary    profileId=${profileId}  amount=${amount}
    ${data}=  json.dumps  ${data}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=   PUT On Session  ynw  /consumer/payment/modes/MockConvenienceFee/${accountId}   params=${cons_params}  data=${data}   expected_status=any  headers=${cons_headers}
    RETURN  ${resp}


Get Service By Location Appoinment   
    [Arguments]  ${locationId}   &{kwargs}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /consumer/appointment/service/${locationId}  params=${cons_params}  expected_status=any  headers=${cons_headers}
    RETURN  ${resp} 


Get locations by service
    [Arguments]      ${serviceId}  
    Check And Create YNW Session
    ${resp}=    GET On Session  ynw   /consumer/service/${serviceId}/location    expected_status=any
    RETURN  ${resp}

Get Booking Invoices
     [Arguments]      ${ynwuuid}  
    Check And Create YNW Session
    ${resp}=    GET On Session  ynw   /consumer/jp/finance/invoice/ynwuid/${ynwuuid}    expected_status=any
    RETURN  ${resp}


Get invoices bydate
     [Arguments]      ${startDate}   ${endDate}
    ${data}=  Create Dictionary   startDate=${startDate}    endDate=${endDate}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    GET On Session  ynw   /consumer/jp/finance/invoice/bydate   data=${data}   expected_status=any
    RETURN  ${resp}

Invoice pay via link
    [Arguments]  ${uuid}  ${amount}  ${purpose}   ${source}  ${accountId}  ${paymentMode}  ${isInternational}  ${serviceId}  ${custId}   &{kwargs}
    ${data}=    Create Dictionary    uuid=${uuid}  amount=${amount}  purpose=${purpose}    source=${source}  accountId=${accountId}   paymentMode=${paymentMode}   isInternational=${isInternational}    serviceId=${serviceId}   custId=${custId}
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=   POST On Session  ynw  /consumer/jp/finance/pay   params=${cons_params}  data=${data}   expected_status=any  headers=${cons_headers}
    RETURN  ${resp}

Consumer Deactivation
    
    Check And Create YNW Session
    ${headers2}=     Create Dictionary    Content-Type=application/json  
    ${resp}=    DELETE On Session    ynw    /consumer/login/deActivate      expected_status=any
    RETURN  ${resp}


Get Service payment modes
    [Arguments]  ${accountId}   ${serviceId}   ${paymentPurpose}
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /consumer/payment/modes/service/${accountId}/${serviceId}/${paymentPurpose}    expected_status=any
    RETURN  ${resp}


######## New Communication URLS ############
    

Get Attachments In Waitlist By Consumer
    [Arguments]  ${uid}

    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /consumer/waitlist/share/attachments/${uid}   expected_status=any
    RETURN  ${resp}


Get Attachments In Appointment By Consumer
    [Arguments]  ${uid}

    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /consumer/appointment/share/attachments/${uid}   expected_status=any
    RETURN  ${resp}


Get Attachments In Order By Consumer
    [Arguments]  ${uid}

    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /consumer/orders/view/attachments/${uid}   expected_status=any
    RETURN  ${resp}


Get Attachments In Donation By Consumer
    [Arguments]  ${uid}

    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /consumer/donation/view/attachments/${uid}   expected_status=any
    RETURN  ${resp}


Send Attachment From Waitlist By Consumer
    [Arguments]  ${uid}  ${emailflag}  ${smsflag}  ${telegramflag}  ${whatsAppflag}  @{attachments}

    ${medium}=  Create Dictionary  email=${emailflag}  sms=${smsflag}  telegram=${telegramflag}  whatsApp=${whatsAppflag}
    ${data}=  Create Dictionary  medium=${medium}  attachments=${attachments} 
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /consumer/waitlist/share/attachments/${uid}   data=${data}  expected_status=any
    RETURN  ${resp}


Send Attachment From Appointment By Consumer 
    [Arguments]  ${uid}  ${emailflag}  ${smsflag}  ${telegramflag}  ${whatsAppflag}  @{attachments}

    ${medium}=  Create Dictionary  email=${emailflag}  sms=${smsflag}  telegram=${telegramflag}  whatsApp=${whatsAppflag}
    ${data}=  Create Dictionary  medium=${medium}  attachments=${attachments} 
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /consumer/appointment/share/attachments/${uid}   data=${data}  expected_status=any
    RETURN  ${resp}


Send Message By Chat from Consumer
    [Arguments]  ${accid}  ${userid}  ${message}  ${messageType}  @{attachments} 

    ${messagedict}=  Create Dictionary  msg=${message}  messageType=${messageType}
    ${data}=  Create Dictionary  provider=${userid}  message=${messagedict}  attachments=${attachments}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  url=/consumer/message/communications?account=${accId}   data=${data}  expected_status=any
    RETURN  ${resp}


upload file to temporary location consumer

    [Arguments]    ${action}    ${owner}    ${ownerType}    ${ownerName}    ${fileName}    ${fileSize}    ${caption}    ${fileType}    ${uid}    ${order}

    ${file}=  Create Dictionary  action=${action}    owner=${owner}    ownerType=${ownerType}    ownerName=${ownerName}    fileName=${fileName}    fileSize=${fileSize}    caption=${caption}    fileType=${fileType}    uid=${uid}    order=${order}
    ${data}=  Create List  ${file}
    ${data}=    json.dumps    ${data}

    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /consumer/fileShare/upload   data=${data}  expected_status=any
    Log  ${resp.content}
    RETURN  ${resp}

Send Message With Waitlist consumer
    [Arguments]  ${provider}  ${uuid}  ${message}  ${messagetype}  &{kwargs}  

    ${message}=  Create Dictionary  msg=${message}  messageType=${messagetype}
    ${data}=  Create Dictionary  provider=${provider}  message=${message}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /consumer/waitlist/communication/${uuid}   data=${data}  expected_status=any
    RETURN  ${resp}

Send Message With Appoinment consumer
    [Arguments]  ${provider}  ${uuid}  ${message}  ${messagetype}  &{kwargs}  

    ${message}=  Create Dictionary  msg=${message}  messageType=${messagetype}
    ${data}=  Create Dictionary  provider=${provider}  message=${message}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /consumer/appointment/communicate/message/${uuid}   data=${data}  expected_status=any
    RETURN  ${resp} 


Send Message With Donation By Consumer
   
    [Arguments]   ${message}  ${emailflag}  ${smsflag}  ${telegramflag}  ${whatsAppflag}  ${uuid}  &{kwargs}  

    ${medium}=  Create Dictionary  email=${emailflag}  sms=${smsflag}  telegram=${telegramflag}  whatsApp=${whatsAppflag}
    ${data}=  Create Dictionary  medium=${medium}  communicationMessage=${message}  uuid=${uuid}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /consumer/donation/communication   data=${data}  expected_status=any
    RETURN  ${resp}

Send Message With Order By Consumer

    [Arguments]  ${provider}  ${uuid}  ${message}  ${messagetype}  &{kwargs}  

    ${message}=  Create Dictionary  msg=${message}  messageType=${messagetype}
    ${data}=  Create Dictionary  provider=${provider}  message=${message}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /consumer/orders/communicate/message/${uuid}   data=${data}  expected_status=any
    RETURN  ${resp} 


Consumer Get user locations by user id
    [Arguments]      ${userid}  
    Check And Create YNW Session
    ${resp}=    GET On Session  ynw   /consumer/user/${userid}/location    expected_status=any
    RETURN  ${resp}


# ....... CONSENT FORM .................

Consumer Get Consent Form By Uid

    [Arguments]      ${uuid}  

    Check And Create YNW Session
    ${resp}=    GET On Session  ynw   /consumer/consentform/${uuid}    expected_status=any
    RETURN  ${resp}

Consumer Get Verify Status of consent form by uid

    [Arguments]      ${uuid}  

    Check And Create YNW Session
    ${resp}=    GET On Session  ynw   /consumer/consentform/verifyStatus/${uuid}    expected_status=any
    RETURN  ${resp}


Consumer Comsent Form Sent Otp 

    [Arguments]     ${uuid}

    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /consumer/consentform/sendOtp/${uuid}   expected_status=any
    RETURN  ${resp}

Consumer Comsent Form Verify Otp

    [Arguments]    ${purpose}  ${uid}  ${phone}
   
    ${otp}=   verify accnt  ${phone}  ${purpose}
    ${loan}=  Create Dictionary   uid=${uid}
    ${data}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  PATCH On Session  ynw  url=/consumer/consentform/verifyOtp/${otp}/${uid}  data=${data}  expected_status=any
    RETURN  ${resp}

Consumer Consent Form Verify Sign  

    [Arguments]     ${uuid}  ${owner}  ${fileName}  ${fileSize}  ${caption}  ${fileType}  ${action}  ${order}  ${driveId}

    ${dict}=  Create Dictionary   owner=${owner}   fileName=${fileName}   fileSize=${fileSize}   caption=${caption}   fileType=${fileType}   action=${action}   order=${order}   driveId=${driveId}
    ${data}=  Create List  ${dict}
    ${data}=   json.dumps   ${data}
    Check And Create YNW Session
    ${resp}=    PATCH On Session    ynw    /consumer/consentform/verifysign/${uuid}  data=${data}   expected_status=any
    RETURN  ${resp}