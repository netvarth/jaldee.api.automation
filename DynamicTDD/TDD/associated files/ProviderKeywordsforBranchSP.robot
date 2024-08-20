*** Settings ***
Library           Collections
Library           String
Library           OperatingSystem
Library           json
Library           DateTime
Library           db.py
Resource          Keywords.robot
Library	          Imageupload.py

*** Keywords ***

Get BusinessDomainsConf
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /ynwConf/businessDomains  expected_status=any
    RETURN  ${resp}

Get Licensable Packages
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/license/packages  expected_status=any
    RETURN  ${resp}

User Creation for SP
    [Arguments]  ${firstname}  ${lastname}  ${yemail}  ${sector}  ${sub_sector}  ${ph}  ${licPkgId}
    ${usp}=    Create Dictionary   firstName=${firstname}  lastName=${lastname}  email=${yemail}  primaryMobileNo=${ph}  countryCode=+91
    ${data}=  Create Dictionary  userProfile=${usp}  sector=${sector}  subSector=${sub_sector}  licPkgId=${licPkgId}
    RETURN  ${data}

Account SignUp
    [Arguments]  ${firstname}  ${lastname}  ${yemail}  ${sector}  ${sub_sector}  ${ph}  ${licPkgId}
    ${data}=   User Creation for SP ${firstname}  ${lastname}  ${yemail}  ${sector}  ${sub_sector}  ${ph}  ${licPkgId}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /provider    data=${data}  expected_status=any
    RETURN  ${resp}

Claim SignUp
    [Arguments]  ${firstname}  ${lastname}  ${yemail}  ${sector}  ${sub_sector}  ${ph}  ${licPkgId}  ${acid}
    ${data}=   User Creation for SP  ${firstname}  ${lastname}  ${yemail}  ${sector}  ${sub_sector}  ${ph}  ${licPkgId}
    Set To Dictionary  ${data}  accountId=${acid}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /provider    data=${data}  expected_status=any
    RETURN  ${resp}

Account Activation
    [Arguments]  ${email}  ${purpose}
    Check And Create YNW Session
    ${key}=   verify accnt  ${email}  ${purpose}
    ${resp_val}=  POST On Session   ynw  /provider/${key}/verify  expected_status=any
    RETURN  ${resp_val}

Account Set Credential
    [Arguments]  ${email}  ${password}  ${purpose}
    ${auth}=     Create Dictionary   password=${password}
    ${key}=   verify accnt  ${email}  ${purpose}
    ${apple}=    json.dumps    ${auth}
    ${resp}=    PUT On Session    ynw    /provider/${key}/activate    data=${apple}  expected_status=any
    RETURN  ${resp}

ProviderLogin
    [Arguments]    ${usname}  ${passwrd}
    ${log}=  Login  ${usname}  ${passwrd}
    ${resp}=    POST On Session    ynw    /provider/login    data=${log}  expected_status=any
    RETURN  ${resp}

ProviderLogout
    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw  /provider/login  expected_status=any
    RETURN  ${resp}       

    
Phone Numbers
    [Arguments]  ${lbl}  ${res}  ${inst}  ${perm}
    ${ph}=  Create Dictionary  label=${lbl}  resource=${res}  instance=${inst}  permission=${perm}
    RETURN  ${ph}

Emails
    [Arguments]  ${e_lbl}  ${e_res}  ${e_inst}  ${e_perm}
    ${em}=  Create Dictionary  label=${e_lbl}  resource=${e_res}  instance=${e_inst}  permission=${e_perm}
    RETURN  ${em} 

Timeslot
    [Arguments]  ${sTime}  ${eTime}
    ${time}=  Create Dictionary  sTime=${sTime}  eTime=${eTime}
    RETURN  ${time}
 
    
Business Profile for SP
    [Arguments]  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${pin}  ${adds}  ${ph1}  ${ph2}  ${email1}
    ${bs}=  TimeSpec for SP  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}
    ${bs}=  Create List  ${bs}
    ${bs}=  Create Dictionary  timespec=${bs}
    ${b_loc}=  Create Dictionary  place=${place}  longitude=${longi}  lattitude=${latti}  googleMapUrl=${g_url}  parkingType=${pt}  open24hours=${oh}   bSchedule=${bs}  pinCode=${pin}  address=${adds}
    ${ph_nos}=  Create List  ${ph1}  ${ph2}
    ${emails}=  Create List  ${email1}
    ${data}=  Create Dictionary  businessName=${bName}  businessDesc=${bDesc}  shortName=${shname}  baseLocation=${b_loc}  phoneNumbers=${ph_nos}  emails=${emails}
    ${data}=  json.dumps  ${data}
    Log  ${data}
    RETURN  ${data}

Create Business Profile
    [Arguments]  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${pin}  ${adds}  ${ph1}  ${ph2}  ${email1}  ${tab_id}
    ${data}=  Business Profile for SP  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${pin}  ${adds}  ${ph1}  ${ph2}  ${email1}
    Set To Dictionary   ${headers}   tab=${tab_id}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  ynw  provider/bProfile  data=${data}  expected_status=any
    RETURN  ${resp}

TimeSpec for SP
    [Arguments]  ${rectype}  ${rint}  ${startDate}  ${endDate}  ${noocc}  ${sTime}  ${eTime} 
    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noocc}
    ${time}=  Create Dictionary  sTime=${sTime}  eTime=${eTime}
    ${timeslot}=  Create List  ${time}
    ${ts}=  Create Dictionary  recurringType=${rectype}  repeatIntervals=${rint}  startDate=${startDate}  terminator=${terminator}  timeSlots=${timeslot}
    RETURN  ${ts}

Create Business Profile without details
    [Arguments]  ${bName}  ${bDesc}  ${shname}   ${ph1}  ${ph2}  ${email1}
    ${ph_nos}=  Create List  ${ph1}  ${ph2}
    ${emails}=  Create List  ${email1}
    ${data}=  Create Dictionary  businessName=${bName}  businessDesc=${bDesc}  shortName=${shname}  baseLocation=${None}  phoneNumbers=${ph_nos}  emails=${emails}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  ynw  provider/bProfile  data=${data}  expected_status=any
    RETURN  ${resp}

Create Business Profile without schedule
    [Arguments]  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pt}  ${oh}  ${pin}  ${adds}   ${ph1}  ${ph2}  ${email1}  ${lid}
    ${ph_nos}=  Create List  ${ph1}  ${ph2}
    ${emails}=  Create List  ${email1}
    ${b_loc}=  Create Dictionary   id=${lid}  place=${place}  longitude=${longi}  lattitude=${latti}  googleMapUrl=${g_url}  parkingType=${pt}  open24hours=${oh}   bSchedule=${None}  pinCode=${pin}  address=${adds}
    ${data}=  Create Dictionary  businessName=${bName}  businessDesc=${bDesc}  shortName=${shname}  baseLocation=${b_loc}  phoneNumbers=${ph_nos}  emails=${emails}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  ynw  provider/bProfile  data=${data}  expected_status=any
    RETURN  ${resp}
    
Business Profile with schedule only
    [Arguments]  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${pin}  ${adds}  ${lid}
    ${bs}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}
    ${bs}=  Create List  ${bs}
    ${bs}=  Create Dictionary  timespec=${bs}
    ${b_loc}=  Create Dictionary  id=${lid}  place=${place}  longitude=${longi}  lattitude=${latti}  googleMapUrl=${g_url}  bSchedule=${bs}  pinCode=${pin}  address=${adds}
    ${data}=  Create Dictionary  businessName=${bName}  businessDesc=${bDesc}  shortName=${shname}  baseLocation=${b_loc}
    ${data}=  json.dumps  ${data}
    RETURN  ${data} 
    
Create Business Profile with schedule only
    [Arguments]  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${pin}  ${adds}  ${lid}
    ${data}=  Business Profile with schedule only  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${pin}  ${adds}  ${lid}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  ynw  provider/bProfile  data=${data}  expected_status=any
    RETURN  ${resp}


Create Business Profile with location only
    [Arguments]  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pt}  ${oh}  ${pin}  ${adds}   
    ${b_loc}=  Create Dictionary  place=${place}  longitude=${longi}  lattitude=${latti}  googleMapUrl=${g_url}  parkingType=${pt}  open24hours=${oh}   bSchedule=${None}  pinCode=${pin}  address=${adds}
    ${data}=  Create Dictionary  businessName=${bName}  businessDesc=${bDesc}  shortName=${shname}  baseLocation=${b_loc}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  ynw  provider/bProfile  data=${data}  expected_status=any
    RETURN  ${resp}

Business Profile with schedule
    [Arguments]  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${pin}  ${adds}  ${ph1}  ${ph2}  ${email1}  ${lid}
    ${bs}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}
    ${bs}=  Create List  ${bs}
    ${bs}=  Create Dictionary  timespec=${bs}
    ${b_loc}=  Create Dictionary  place=${place}  longitude=${longi}  lattitude=${latti}  googleMapUrl=${g_url}  parkingType=${pt}  open24hours=${oh}   bSchedule=${bs}  pinCode=${pin}  address=${adds}  id=${lid}
    ${ph_nos}=  Create List  ${ph1}  ${ph2}
    ${emails}=  Create List  ${email1}
    ${data}=  Create Dictionary  businessName=${bName}  businessDesc=${bDesc}  shortName=${shname}  baseLocation=${b_loc}  phoneNumbers=${ph_nos}  emails=${emails}
    ${data}=  json.dumps  ${data}
    RETURN  ${data}

Update Business Profile with schedule
    [Arguments]  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${pin}  ${adds}  ${ph1}  ${ph2}  ${email1}  ${lid}
    ${data}=  Business Profile with schedule  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${pin}  ${adds}  ${ph1}  ${ph2}  ${email1}  ${lid}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bProfile   data=${data}  expected_status=any
    RETURN  ${resp}

Update Business Profile without schedule
    [Arguments]  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pt}  ${oh}  ${pin}  ${adds}   ${ph1}  ${ph2}  ${email1}  ${lid}
    ${ph_nos}=  Create List  ${ph1}  ${ph2}
    ${emails}=  Create List  ${email1}
    ${b_loc}=  Create Dictionary  place=${place}  longitude=${longi}  lattitude=${latti}  googleMapUrl=${g_url}  parkingType=${pt}  open24hours=${oh}   bSchedule=${None}  pinCode=${pin}  address=${adds}   id=${lid}
    ${data}=  Create Dictionary  businessName=${bName}  businessDesc=${bDesc}  shortName=${shname}  baseLocation=${b_loc}  phoneNumbers=${ph_nos}  emails=${emails}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bProfile   data=${data}  expected_status=any
    RETURN  ${resp}

Update Business Profile without details
    [Arguments]  ${bName}  ${bDesc}  ${shname}   ${ph1}  ${ph2}  ${email1}
    ${ph_nos}=  Create List  ${ph1}  ${ph2}
    ${emails}=  Create List  ${email1}
    ${data}=  Create Dictionary  businessName=${bName}  businessDesc=${bDesc}  shortName=${shname}  baseLocation=${None}  phoneNumbers=${ph_nos}  emails=${emails}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bProfile   data=${data}  expected_status=any
    RETURN  ${resp}
    
Update Business Profile without phone and email
    [Arguments]  ${bName}  ${bDesc}  ${shname}
    ${data}=  Create Dictionary  businessName=${bName}  businessDesc=${bDesc}  shortName=${shname}  baseLocation=${None}  phoneNumbers=${None}  emails=${None}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bProfile   data=${data}  expected_status=any
    RETURN  ${resp}

Get Business Profile
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/bProfile  expected_status=any
    RETURN  ${resp}
    
Update Domain And SubDomain
    [Arguments]   ${dom}  ${subdom}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  /provider/${dom}/${subdom}  expected_status=any
    RETURN  ${resp}    

Create Location
    [Arguments]  ${place}  ${longi}  ${latti}  ${g_url}  ${pin}  ${add}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}   ${tab_id}
    ${bs}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}
    ${bs}=  Create List  ${bs}
    ${bs}=  Create Dictionary  timespec=${bs}
    ${data}=  Create Dictionary  place=${place}  longitude=${longi}  lattitude=${latti}  googleMapUrl=${g_url}  pinCode=${pin}  address=${add}  parkingType=${pt}  open24hours=${oh}  bSchedule=${bs}
    ${data}=  json.dumps  ${data}
    Set To Dictionary   ${headers}   tab=${tab_id}
    Log  ${headers}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/locations  data=${data}  expected_status=any   headers=${headers}
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
    ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
    ${24hours}    Random Element    ['True','False']
    ${list}=  Create List  1  2  3  4  5  6  7
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  30  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    RETURN  ${resp.json()}

Create Location without schedule
    [Arguments]  ${place}  ${longi}  ${latti}  ${g_url}  ${pin}  ${add}  ${pt}  ${oh}
    ${data}=  Create Dictionary  place=${place}  longitude=${longi}  lattitude=${latti}  googleMapUrl=${g_url}  pinCode=${pin}  address=${add}  parkingType=${pt}  open24hours=${oh}  bSchedule=${None}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/locations  data=${data}  expected_status=any
    RETURN  ${resp} 
    
Get Location ById
    [Arguments]  ${id}   ${tab_id}
    Set To Dictionary   ${headers}   tab=${tab_id}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/locations/${id}   expected_status=any
    RETURN  ${resp}

Get Locations
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/locations
    RETURN  ${resp}

Update Location with schedule
    [Arguments]   ${place}  ${longi}  ${latti}  ${g_url}  ${pin}  ${add}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${lid}
    ${bs}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}
    ${bs}=  Create List  ${bs}
    ${bs}=  Create Dictionary  timespec=${bs}
    ${data}=  Create Dictionary  place=${place}  longitude=${longi}  lattitude=${latti}  googleMapUrl=${g_url}  pinCode=${pin}  address=${add}  parkingType=${pt}  open24hours=${oh}  bSchedule=${bs}  id=${lid}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/locations  data=${data}  expected_status=any
    RETURN  ${resp}

Update Location
    [Arguments]   ${place}  ${longi}  ${latti}  ${g_url}  ${pin}  ${add}  ${pt}  ${oh}  ${lid}
    ${data}=  Create Dictionary  place=${place}  longitude=${longi}  lattitude=${latti}  googleMapUrl=${g_url}  pinCode=${pin}  address=${add}  parkingType=${pt}  open24hours=${oh}  id=${lid}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/locations  data=${data}  expected_status=any
    RETURN  ${resp}
    
UpdateBaseLocation
    [Arguments]   ${lid}
    ${data}=  Create Dictionary  locationId=${lid}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bProfile/baseLocation/${lid}  data=${data}  expected_status=any
    RETURN  ${resp}

Disable Location
   [Arguments]   ${id}
   Check And Create YNW Session
   ${resp}=    DELETE On Session    ynw  /provider/locations/${id}/disable
   RETURN  ${resp}
    
Enable Location
   [Arguments]   ${id}
   Check And Create YNW Session
   ${resp}=    PUT On Session    ynw  /provider/locations/${id}/enable
   RETURN  ${resp}

Get Location Suggester
   [Arguments]  &{kwargs}
   Check And Create YNW Session
   ${resp}=    GET On Session    ynw   /provider/search/suggester/location  params=${kwargs}   expected_status=any
   RETURN  ${resp}

Holiday
    [Arguments]  ${day}  ${desc}  ${stime}  ${etime}
    ${nwh}=  Create Dictionary  sTime=${stime}  eTime=${etime}
    ${data}=  Create Dictionary  startDay=${day}  description=${desc}  nonWorkingHours=${nwh}
    Check And Create YNW Session
    RETURN  ${data}

Create Holiday
    [Arguments]  ${day}  ${desc}  ${stime}  ${etime}
    ${data}=  Holiday  ${day}  ${desc}  ${stime}  ${etime}
    ${data}=  json.dumps  ${data}
    ${resp}=  POST On Session  ynw  /provider/settings/nonBusinessDays  data=${data}  expected_status=any
    RETURN  ${resp}

Update Holiday
    [Arguments]  ${day}  ${desc}  ${stime}  ${etime}  ${id}
    ${data}=  Holiday  ${day}  ${desc}  ${stime}  ${etime}
    Set To Dictionary  ${data}  id=${id}
    ${data}=  json.dumps  ${data}
    ${resp}=  PUT On Session  ynw  /provider/settings/nonBusinessDays  data=${data}  expected_status=any
    RETURN  ${resp}

Get Holidays
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/settings/nonBusinessDays
    RETURN  ${resp}

Get Holiday By Id
    [Arguments]  ${id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/settings/nonBusinessDays/${id}
    RETURN  ${resp}

Delete Holiday
    [Arguments]  ${id}
    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw  /provider/settings/nonBusinessDays/${id}
    RETURN  ${resp}

Get Search Status
   Check And Create YNW Session
   ${resp}=    GET On Session    ynw   /provider/search
   RETURN  ${resp}

Enable Search Data
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/search/ENABLE
    RETURN  ${resp}

Disable Search Data
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/search/DISABLE
    RETURN  ${resp}

Create SocialMedia
    [Arguments]  ${resource}  ${value}
    ${data}=  Create Dictionary  resource=${resource}  value=${value}  
    RETURN  ${data}
       

Update Social Media Info
    [Arguments]  @{data}    
    ${data}=  Create Dictionary  socialMedia=${data}                                                                                                                                            
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session 
    ${resp}=  PUT On Session  ynw  /provider/bProfile/socialMedia  data=${data}  expected_status=any
    RETURN  ${resp}

Queue for SP
   [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  @{vargs}
   ${bs}=  TimeSpec for SP  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}
   ${location}=  Create Dictionary  id=${loc}
   ${len}=  Get Length  ${vargs}
   ${service}=  Create Dictionary  id=${vargs[0]}
   ${services}=  Create List  ${service}
   :FOR    ${index}    IN RANGE  1  ${len}
    \	${service}=  Create Dictionary  id=${vargs[${index}]} 
    \   Append To List  ${services}  ${service}
   ${data}=  Create Dictionary  name=${name}  queueSchedule=${bs}  parallelServing=${parallel}  capacity=${capacity}  location=${location}  services=${services}
   RETURN  ${data}
   
Create Queue
   [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  ${tab_id}  @{vargs}  
   ${data}=  Queue for SP  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  @{vargs}
   ${data}=  json.dumps  ${data}
   Set To Dictionary   ${headers}   tab=${tab_id}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw  /provider/waitlist/queues  data=${data}  expected_status=any  headers=${headers}
   RETURN  ${resp}
   
Create Sample Queue

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${SERVICE1}=    FakerLibrary.Word
        ${s_id}=  Create Sample Service  ${SERVICE1}
    ELSE
        Set Test Variable   ${s_id}   ${resp.json()[0]['id']}
        ${SERVICE1}=  Set Variable  ${resp.json()[0]['name']}
    END
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${DAY}=  get_date
    # ${Time}=  db.get_time_by_timezone   ${tz}
    # ${sTime}=  add_time  0  45
    # ${eTime}=  add_time   1  00
    # ${SERVICE1}=    FakerLibrary.Word
    # ${s_id}=  Create Sample Service  ${SERVICE1}
    # ${lid}=  Create Sample Location 
    ${DAY}=  get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  45  
    ${eTime}=  add_timezone_time  ${tz}  1  00  
    ${queue1}=    FakerLibrary.Word
    ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  5  ${lid}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${data}=  Create Dictionary   queue_id=${resp.json()}   service_id=${s_id}   location_id=${lid}    service_name=${SERVICE1}
    RETURN   ${data}
    
Queue With TokenStart
   [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  ${token_start}  @{vargs}
   ${bs}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}
   ${location}=  Create Dictionary  id=${loc}
   ${len}=  Get Length  ${vargs}
   ${service}=  Create Dictionary  id=${vargs[0]}
   ${services}=  Create List  ${service}
   :FOR    ${index}    IN RANGE  1  ${len}
    \	${service}=  Create Dictionary  id=${vargs[${index}]} 
    \   Append To List  ${services}  ${service}
   ${data}=  Create Dictionary  name=${name}  queueSchedule=${bs}  parallelServing=${parallel}  capacity=${capacity}  location=${location}  tokenStarts=${token_start}  services=${services}
   RETURN  ${data}
   
Create Queue With TokenStart
   [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  ${token_start}  @{vargs}
   ${data}=  Queue With TokenStart  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  ${token_start}  @{vargs}
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw  /provider/waitlist/queues  data=${data}  expected_status=any
   RETURN  ${resp}

Queue without Service
   [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}
   ${bs}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}
   ${location}=  Create Dictionary  id=${loc}
   ${data}=  Create Dictionary  name=${name}  queueSchedule=${bs}  parallelServing=${parallel}  capacity=${capacity}  location=${location}  services=${None}
   RETURN  ${data}

Create Queue without Service
   [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}
   ${data}=  Queue without Service  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw  /provider/waitlist/queues  data=${data}  expected_status=any
   RETURN  ${resp}

Update Queue
    [Arguments]  ${qid}  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  @{vargs}
    ${data}=  Queue  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  @{vargs}
    Set To Dictionary  ${data}  id=${qid}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/waitlist/queues  data=${data}  expected_status=any
    RETURN  ${resp}
    
Update Queue without service
    [Arguments]  ${qid}  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}
    ${data}=  Queue without Service  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}
    Set To Dictionary  ${data}  id=${qid}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/waitlist/queues  data=${data}  expected_status=any
    RETURN  ${resp}    
   
Get Queues
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/queues  expected_status=any
    RETURN  ${resp}

Get Queue ById
    [Arguments]  ${id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/queues/${id}  expected_status=any
    RETURN  ${resp}
    
Get Queues Counts
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/queues/count  expected_status=any
    RETURN  ${resp}

Enable Queue
    [Arguments]  ${qid}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/waitlist/queues/${qid}/enable  expected_status=any
    RETURN  ${resp}

Disable Queue
    [Arguments]  ${qid}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/waitlist/queues/${qid}/disable  expected_status=any
    RETURN  ${resp}

Get Queue Location
    [Arguments]  ${locationId}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/queues/${locationId}/location  expected_status=any
    RETURN  ${resp}
    
Get Queue Location and Date
    [Arguments]  ${locationId}  ${date}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/queues/${locationId}/location/${date}  expected_status=any
    RETURN  ${resp}    

View Waitlist Settings
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/settings/waitlistMgr  expected_status=any
    RETURN  ${resp}

Update Waitlist Settings
    [Arguments]   ${calculationmode}   ${TrnArndTime}  ${futuredatewaitlist}  ${showTokenId}  ${onlineChckin}  ${notification}  ${maxPartySize}
    ${data}=  Create Dictionary  calculationMode=${calculationmode}  trnArndTime=${TrnArndTime}  futureDateWaitlist=${futuredatewaitlist}  showTokenId=${showTokenId}  onlineCheckIns=${onlineChckin}  sendNotification=${notification}  maxPartySize=${maxPartySize}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/waitlistMgr   data=${data}  expected_status=any
    RETURN  ${resp}

Send Verify Login
    [Arguments]  ${loginid}
    Check And Create YNW Session
    ${resp}=  POST On Session    ynw  /provider/login/verifyLogin/${loginid}  expected_status=any
    RETURN  ${resp}

Verify Login
    [Arguments]  ${loginid}  ${purpose}
    Check And Create YNW Session
    ${auth}=     Create Dictionary   loginId=${loginid}
    ${key}=   verify accnt  ${loginid}  ${purpose}
    ${data}=    json.dumps    ${auth}
    ${resp}=    PUT On Session    ynw    /provider/login/${key}/verifyLogin   data=${data}  expected_status=any
    RETURN  ${resp}

Get Provider By Id
    [Arguments]  ${email}
    Check And Create YNW Session
    ${id}=  get_id  ${email}
    ${resp}=    GET On Session    ynw   /provider/profile/${id}  expected_status=any
    RETURN  ${resp}

Get Consumer By Account
    [Arguments]  &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /consumer  params=${kwargs}   expected_status=any
    RETURN  ${resp}
    
Verify user profile
    [Arguments]  ${resp}  &{kwargs}
    ${items}=  Get Dictionary items  ${kwargs}
    :FOR  ${key}  ${value}  IN  @{items}
          \  Should Be Equal As Strings  ${resp.json()[0]['userProfile']['${key}']}  ${value}

Provider Change Password
    [Arguments]  ${oldpswd}  ${newpswd}
    ${auth}=    Create Dictionary    oldpassword=${oldpswd}    password=${newpswd}
    ${apple}=    json.dumps    ${auth}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw   /provider/login/chpwd  data=${apple}  expected_status=any
    RETURN  ${resp}

SendProviderResetMail
   [Arguments]    ${email}
   Create Session    ynw    ${BASE_URL}  verify=true
   ${resp}=  POST On Session  ynw     /provider/login/reset/${email}  expected_status=any
   RETURN  ${resp}  

ResetProviderPassword
    [Arguments]    ${email}  ${pswd}  ${purpose}
    ${key}=  verify accnt  ${email}   ${purpose}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw    /provider/login/reset/${key}/validate  expected_status=any 
    ${login}=    Create Dictionary  password=${pswd}
    ${log}=    json.dumps    ${login}
    ${respk}=  PUT On Session  ynw  /provider/login/reset/${key}  data=${log}  expected_status=any
    RETURN  ${resp}  ${respk}

Member Creation
    [Arguments]  ${id}  ${firstname}  ${lastname}  ${dob}  ${gender}
    ${up}=  Create Dictionary  firstName=${firstname}  lastName=${lastname}  dob=${dob}  gender=${gender}
    ${data}=  Create Dictionary  parent=${id}  userProfile=${up}
    ${data}=  json.dumps  ${data}
    RETURN  ${data}

AddFamilyMemberByProvider
    [Arguments]  ${id}  ${firstname}  ${lastname}  ${dob}  ${gender}
    Check And Create YNW Session
    ${data}=  Member Creation  ${id}  ${firstname}  ${lastname}  ${dob}  ${gender}
    ${resp}=  POST On Session   ynw   /provider/familyMember   data=${data}  expected_status=any
    RETURN  ${resp}

ListFamilyMemberByProvider
    [Arguments]   ${id}
    Check And Create YNW Session
    ${resp}=  GET On Session   ynw   /provider/familyMember/${id}  expected_status=any
    RETURN  ${resp}

Add addon 
    [Arguments]    ${addonId}
    Check And Create YNW Session
    ${resp}=   POST On Session   ynw   /provider/license/addon/${addonId}  expected_status=any
    RETURN  ${resp}

Remove addon
    [Arguments]    ${addonId}
    Check And Create YNW Session
    ${resp}=   DELETE On Session   ynw   /provider/license/addon/${addonId}  expected_status=any
    RETURN  ${resp}

Get Active License 
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/license  expected_status=any
    RETURN  ${resp}

Get license auditlog
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/license/auditlog
    RETURN  ${resp}
   
   
Get addons auditlog
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/license/addon/auditlog
    RETURN  ${resp}

Get Addons Metadata
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/license/addonmetadata
    RETURN  ${resp}

Get upgradable license 
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/license/upgradablePackages
    RETURN  ${resp}

Get upgradable addons
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/license/upgradableAddons
    RETURN  ${resp}

Change License Package 
    [Arguments]    ${licPkgId}
    Check And Create YNW Session
    ${resp}=   PUT On Session   ynw   /provider/license/${licPkgId}
    RETURN  ${resp}  

Get SubscriptionTypes 
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  provider/license/getSubscriptionTypes
    RETURN  ${resp}

Get Subscription
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/license/getSubscription
    RETURN  ${resp}
    
Update Subscription
    [Arguments]    ${subscription}
    Check And Create YNW Session
    ${resp}=   PUT On Session   ynw   /provider/license/changeSubscription/${subscription}
    RETURN  ${resp}
    
Add adword
   [Arguments]    ${adwordName}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw  /provider/license/adwords/${adwordName}
   RETURN  ${resp}
   
Get adword
   Check And Create YNW Session
   ${resp}=   GET On Session  ynw  /provider/license/adwords
   RETURN  ${resp}
   
Delete adword
    [Arguments]    ${adwordId}
    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw  provider/license/adwords/${adwordId}
    RETURN  ${resp}

Customer Creation
    [Arguments]  ${firstname}  ${lastname}   ${primaryNo}   ${ydob}  ${ygender}  ${yemail}
    ${up}=  Create Dictionary  firstName=${firstname}  lastName=${lastname}  address=${EMPTY}  primaryMobileNo=${primaryNo}  dob=${ydob}  gender=${ygender}  email=${yemail}  countryCode=+91
    ${data}=  Create Dictionary  userProfile=${up}
    ${data}=  json.dumps  ${data}
    RETURN  ${data}
    
Customer Creation after updation
    [Arguments]  ${firstname}  ${lastname}   ${primaryNo}   ${ydob}  ${ygender}  ${yemail}  ${c_id}
    ${up}=  Create Dictionary  id=${c_id}  firstName=${firstname}  lastName=${lastname}  address=${EMPTY}  primaryMobileNo=${primaryNo}  dob=${ydob}  gender=${ygender}  email=${yemail}  countryCode=+91
    ${data}=  Create Dictionary  userProfile=${up}
    ${data}=  json.dumps  ${data}
    RETURN  ${data}

AddCustomer
    [Arguments]  ${firstname}  ${lastname}   ${primaryNo}   ${ydob}  ${ygender}  ${yemail}
    Check And Create YNW Session
    ${data}=  Customer Creation  ${firstname}  ${lastname}  ${primaryNo}  ${ydob}  ${ygender}  ${yemail}
    ${resp}=  POST On Session  ynw  /provider/customers  data=${data}  expected_status=any
    RETURN  ${resp}
    
UpdateCustomer
	[Arguments]  ${firstname}  ${lastname}  ${primaryNo}  ${ydob}  ${ygender}  ${yemail}  ${c_id} 
	Check And Create YNW Session
    ${data}=  Customer Creation after updation  ${firstname}  ${lastname}  ${primaryNo}  ${ydob}  ${ygender}  ${yemail}  ${c_id}
    ${resp}=  PUT On Session  ynw  /provider/customers  data=${data}  expected_status=any
	RETURN  ${resp}
	
GetCustomer
	[Arguments]  &{param}
	Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /provider/customers  params=${param}    
    RETURN  ${resp}
    
DeleteCustomer
	[Arguments]  ${customerId}
	Check And Create YNW Session
    ${resp}=   DELETE On Session  ynw  /provider/customers/${customerId}   
    RETURN  ${resp}
  
Update Account Payment Settings
    [Arguments]   ${onlinePayment}   ${payTm}   ${dcOrCcOrNb}   ${payTmLinkedPhoneNumber}  ${panCardNumber}   ${bankAccountNumber}   ${bankName}   ${ifscCode}   ${nameOnPanCard}   ${accountHolderName}  ${branchCity}   ${businessFilingStatus}   ${accountType}
    ${data}=   Create Dictionary       onlinePayment=${onlinePayment}   payTm=${payTm}   dcOrCcOrNb=${dcOrCcOrNb}   payTmLinkedPhoneNumber=${payTmLinkedPhoneNumber}  panCardNumber=${panCardNumber}   bankAccountNumber=${bankAccountNumber}   bankName=${bankName}   ifscCode=${ifscCode}   nameOnPanCard=${nameOnPanCard}   accountHolderName=${accountHolderName}  branchCity=${branchCity}   businessFilingStatus=${businessFilingStatus}   accountType=${accountType}
    ${data}=   json.dumps   ${data}
    Check And Create YNW Session
    ${resp}=   PUT On Session  ynw  /provider/payment/settings   data=${data}  expected_status=any
    RETURN  ${resp}
    
Get Account Settings
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /provider/payment/settings   
    RETURN  ${resp}
    
Create Item
   [Arguments]   ${dsplyName}   ${shrtDes}   ${dsplyDes}   ${price}  ${taxable}
   ${auth}=  Create Dictionary   displayName=${dsplyName}    shortDesc=${shrtDes}   displayDesc=${dsplyDes}    price=${price}    taxable=${taxable}
   ${auth}=    json.dumps    ${auth}
   Check And Create YNW Session 
   ${resp}=    POST On Session    ynw  /provider/items   data=${auth}  expected_status=any
   RETURN  ${resp}   
   
Get Item By Id
    [Arguments]   ${id}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/items/${id}  expected_status=any
    RETURN  ${resp} 
    
Get Items 
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/items  expected_status=any
    RETURN  ${resp} 
    
Update Item 
   [Arguments]     ${itemId}   ${dsplyName}   ${shrtDes}   ${dsplyDes}   ${price}   ${taxable}
   ${auth}=  Create Dictionary   itemId=${itemId}   displayName=${dsplyName}    shortDesc=${shrtDes}   displayDesc=${dsplyDes}    price=${price}  taxable=${taxable}  
   ${auth}=    json.dumps    ${auth}
   Check And Create YNW Session  
   ${resp}=    PUT On Session    ynw  /provider/items   data=${auth}  expected_status=any
   RETURN  ${resp}
  
Delete Item 
   [Arguments]   ${id}
   Check And Create YNW Session
   ${resp}=    DELETE On Session    ynw  /provider/items/${id}  expected_status=any   
   RETURN  ${resp}  
   
Enable Item 
   [Arguments]   ${id}
   Check And Create YNW Session
   ${resp}=    PUT On Session    ynw  /provider/items/enable/${id}  expected_status=any   
   RETURN  ${resp}      

Disable Item
    [Arguments]   ${id}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  /provider/items/disable/${id}  expected_status=any   
    RETURN  ${resp}    
   
Create Discount 
    [Arguments]  ${name}   ${description}   ${discValue}   ${calculationType}  ${discType}
    ${data}=  Create Dictionary   name=${name}   description=${description}   discValue=${discValue}   calculationType=${calculationType}  discType=${discType}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/bill/discounts   data=${data}  expected_status=any
    RETURN  ${resp}
        
Get Discounts 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/bill/discounts  expected_status=any  
    RETURN  ${resp}

Get Discount By Id
    [Arguments]  ${dicountId}   
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/bill/discounts/${dicountId}  expected_status=any   
    RETURN  ${resp}

Delete Discount 
    [Arguments]  ${dicountId}   
    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw  /provider/bill/discounts/${dicountId}  expected_status=any   
    RETURN  ${resp}
    
Enable Discount
    [Arguments]  ${dicountId}   
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bill/discounts/${dicountId}/enable  expected_status=any   
    RETURN  ${resp}
       
Disable Discount
    [Arguments]  ${dicountId}   
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bill/discounts/${dicountId}/disable  expected_status=any  
    RETURN  ${resp}

Update Discount
    [Arguments]    ${id}   ${name}   ${description}   ${discValue}   ${calculationType}
    ${data}=  Create Dictionary    id=${id}   name=${name}   description=${description}   discValue=${discValue}   calculationType=${calculationType}
    ${data}=  json.dumps  ${data} 
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bill/discounts   data=${data}  expected_status=any
    RETURN  ${resp}  
    
Delete Coupon 
    [Arguments]  ${couponId}   
    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw  /provider/bill/coupons/${couponId}  expected_status=any   
    RETURN  ${resp}
    
Enable Coupon
    [Arguments]  ${couponId}   
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bill/coupons/${couponId}/enable  expected_status=any   
    RETURN  ${resp}

Disable Coupon
    [Arguments]  ${couponId}   
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bill/coupons/${couponId}/disable  expected_status=any  
    RETURN  ${resp}

Update Coupon 
    [Arguments]    ${id}   ${name}   ${description}   ${amount}   ${calculationType}
    ${data}=  Create Dictionary    id=${id}   name=${name}   description=${description}   amount=${amount}   calculationType=${calculationType}
    ${data}=  json.dumps  ${data} 
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bill/coupons   data=${data}  expected_status=any
    RETURN  ${resp}
    
Get Calculation Types coupon 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/bill/coupons/calculationtypes  expected_status=any
    RETURN  ${resp}   
    
Create Coupon 
    [Arguments]  ${name}   ${description}   ${amount}   ${calculationType}
    ${data}=  Create Dictionary   name=${name}  amount=${amount}  description=${description}   calculationType=${calculationType}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/bill/coupons   data=${data}  expected_status=any
    RETURN  ${resp}
    
Get Coupons 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/bill/coupons  expected_status=any   
    RETURN  ${resp}

Get Coupon By Id
    [Arguments]  ${couponId}   
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/bill/coupons/${couponId}  expected_status=any   
    RETURN  ${resp}

Enable Tax
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw  /provider/payment/tax/enable  expected_status=any
    RETURN  ${resp}

Disable Tax
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw  /provider/payment/tax/disable   expected_status=any
    RETURN  ${resp} 

Create Service
    [Arguments]  ${name}  ${desc}  ${durtn}  ${status}  ${bType}  ${notfcn}  ${notiTp}   ${minPrePaymentAmount}   ${totalAmount}  ${isPrePayment}  ${taxable}   ${tab_id}
    ${data}=  Create Dictionary  name=${name}  description=${desc}  serviceDuration=${durtn}  notification=${notfcn}  notificationType=${notiTp}  minPrePaymentAmount=${minPrePaymentAmount}   totalAmount=${totalAmount}   status=${status}  bType=${btype}  isPrePayment=${isPrePayment}  taxable=${taxable}
    ${data}=  json.dumps  ${data}
    Set To Dictionary   ${headers}   tab=${tab_id}
    Check And Create YNW Session  
    ${resp}=  POST On Session  ynw  /provider/services  data=${data}  expected_status=any   headers=${headers}
    RETURN  ${resp}

Create Sample Service
    [Arguments]  ${Service_name}
    ${resp}=  Create Service  ${Service_name}  Description   2  ACTIVE  Waitlist  True  email  45  500  False  False
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    RETURN  ${resp.json()} 

Create Service Department
    [Arguments]  ${name}  ${desc}  ${durtn}  ${bType}  ${notfcn}  ${notiTp}   ${minPrePaymentAmount}   ${totalAmount}  ${isPrePayment}  ${taxable}  ${depid}  
    ${data}=  Create Dictionary  name=${name}  description=${desc}  serviceDuration=${durtn}  notification=${notfcn}  notificationType=${notiTp}  minPrePaymentAmount=${minPrePaymentAmount}   totalAmount=${totalAmount}  bType=${btype}  isPrePayment=${isPrePayment}  taxable=${taxable}  department=${depid} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session  
    ${resp}=  POST On Session  ynw  /provider/services  data=${data}  expected_status=any
    RETURN  ${resp}
                   
Update Service
    [Arguments]  ${id}   ${name}  ${desc}  ${durtn}  ${status}  ${bType}  ${notfcn}  ${notiTp}   ${minPrePaymentAmount}   ${totalAmount}  ${isPrePayment}  ${taxable}  
    ${data}=  Create Dictionary  id=${id}  name=${name}  description=${desc}  serviceDuration=${durtn}  notification=${notfcn}  notificationType=${notiTp}  minPrePaymentAmount=${minPrePaymentAmount}   totalAmount=${totalAmount}   status=${status}  bType=${btype}  isPrePayment=${isPrePayment}  taxable=${taxable}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/services  data=${data}  expected_status=any
    RETURN  ${resp}
    
Get Service
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/services  params=${param}  expected_status=any 
    RETURN  ${resp}
    
Get Service By Id
    [Arguments]  ${id}   ${tab_id}
    Set To Dictionary   ${headers}   tab=${tab_id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/services/${id}    expected_status=any
    RETURN  ${resp}  

Get Service Count
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/services/count  params=${param}  expected_status=any 
    RETURN  ${resp}


Get ServiceImage
    [Arguments]  ${id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  provider/services/serviceGallery/${id}  expected_status=any
    RETURN  ${resp}

Enable service 
   [Arguments]  ${id}  
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  /provider/services/${id}/Enable  expected_status=any
   RETURN  ${resp}  
   
Disable service 
   [Arguments]  ${id} 
   Check And Create YNW Session
   ${resp}=  DELETE On Session  ynw  /provider/services/${id}/Disable  expected_status=any
   RETURN  ${resp}     
   
Delete Service
   [Arguments]  ${id}  
   Check And Create YNW Session
   ${resp}=  DELETE On Session  ynw  /provider/services/${id}  expected_status=any
   RETURN  ${resp}   
    
Get business Domain
     Check And Create YNW Session
     ${resp}=  GET On Session  ynw  /ynwConf/businessDomains  expected_status=any
     RETURN  ${resp}

Get subDomain level Fields
     [Arguments]  ${domain}  ${subdomain}
     Check And Create YNW Session
     ${resp}=  GET On Session  ynw  /provider/ynwConf/dataModel/${domain}/${subdomain}  expected_status=any
     RETURN  ${resp}     
  
Get Domain level Fields
     [Arguments]  ${domain}
     Check And Create YNW Session
     ${resp}=  GET On Session  ynw  /provider/ynwConf/dataModel/${domain}  expected_status=any
     RETURN  ${resp}     
         
Update Domain_Level
     [Arguments]   ${data}  
     Check And Create YNW Session
     ${data}=  json.dumps  ${data}
     ${resp}=  PUT On Session  ynw  /provider/bProfile/domain  data=${data}  expected_status=any
     RETURN  ${resp}

Get Licenses
	Check And Create YNW Session
	${resp}=  GET On Session  ynw  /provider/license  expected_status=any
	RETURN  ${resp}
    
update license
	[Arguments]  ${licPkgId}  
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/license/${licPkgId}  expected_status=any
    RETURN  ${resp} 
		
Get Audit Logs
    [Arguments]    &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /provider/auditlogs    params=${kwargs}   expected_status=any
    RETURN    ${resp}

Enable Online Checkin
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/waitlistMgr/onlineCheckIns/Enable  expected_status=any
    RETURN  ${resp}

Disable Online Checkin
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/waitlistMgr/onlineCheckIns/Disable  expected_status=any
    RETURN  ${resp}

Enable Future Checkin
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/waitlistMgr/futureCheckIns/Enable  expected_status=any
    RETURN  ${resp}

Disable Future Checkin
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/waitlistMgr/futureCheckIns/Disable  expected_status=any
    RETURN  ${resp}

Add Delay
    [Arguments]  ${qid}  ${time}  ${msg}  ${sndmsg}
    ${data}=  Create Dictionary  delayDuration=${time}  message=${msg}  sendMsg=${sndmsg}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/waitlist/queues/${qid}/delay  data=${data}  expected_status=any
    RETURN  ${resp}

Get Delay
    [Arguments]  ${qid}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/queues/${qid}/delay  expected_status=any
    RETURN  ${resp}

Get Queue Waiting Time
    [Arguments]  ${qid}  ${date}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/queues/${qid}/${date}/waitingTime  expected_status=any
    RETURN  ${resp}

Get Queue Length
    [Arguments]  ${qid}  ${date}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/queues/${qid}/${date}/length  expected_status=any
    RETURN  ${resp}

Get Queue Of A Service
    [Arguments]  ${loc}  ${service}  ${date}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/queues/${loc}/location/${service}/service/${date}  expected_status=any
    RETURN  ${resp}

Get Waiting Time Of Providers
    [Arguments]  @{ids} 
    Check And Create YNW Session
    ${len}=  Get Length  ${ids}
    Set Test Variable  ${pid}  ${ids[0]}
    :FOR    ${index}    IN RANGE  1  ${len}
    \	${pid}=  Catenate 	SEPARATOR=,	${pid} 	${ids[${index}]}
    ${resp}=  GET On Session  ynw  /provider/waitlist/queues/waitingTime/${pid}  expected_status=any
    RETURN  ${resp}

Get Last Computed waitingTime
    [Arguments]  ${qid}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/queues/${qid}/lastComputedWaitingTime  expected_status=any
    RETURN  ${resp}


Get Features
    [Arguments]  ${subdomain}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/ynwConf/features/${subdomain}  expected_status=any
    RETURN  ${resp}
    
Get Business schedules
	Check and Create YNW Session
	${resp}=  GET On Session   ynw  /provider/ynwConf/bSchedule  expected_status=any
	RETURN  ${resp}

Create Alert
    [Arguments]  ${s_id}  ${c_id}  ${subc_id}  ${text}  ${sev}  ${ack}  ${sub}
    ${src}=  Create Dictionary  id=${s_id}
    ${cat}=  Create Dictionary  id=${c_id}
    ${sub_cat}=  Create Dictionary  id=${subc_id}
    ${data}=  Create Dictionary  source=${src}  category=${cat}  subCategory=${sub_cat}  text=${text}  severity=${sev}   ackRequired=${ack}  subject=${sub}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  provider/alerts  data=${data}  expected_status=any
    RETURN  ${resp}

Get Alert ById
     [Arguments]  ${alertId}
     Check And Create YNW Session
     ${resp}=  GET On Session  ynw  /provider/alerts/${alertId}  expected_status=any
     RETURN  ${resp}

Get Alerts
     [Arguments]    &{kwargs}
     Check And Create YNW Session
     ${resp}=  GET On Session  ynw  /provider/alerts   params=${kwargs}   expected_status=any  
     RETURN  ${resp}

Delete Alerts
     Check And Create YNW Session
     ${resp}=  DELETE On Session  ynw  /provider/alerts  expected_status=any
     RETURN  ${resp}

Acknowldge Alert
     [Arguments]  ${alertId}
     Check And Create YNW Session
     ${resp}=  PUT On Session  ynw  /provider/alerts/${alertId}  expected_status=any
     RETURN  ${resp}

Delete Alert ById
     [Arguments]  ${alertId}
     Check And Create YNW Session
     ${resp}=  DELETE On Session  ynw  /provider/alerts/${alertId}  expected_status=any
     RETURN  ${resp}

Get Alerts Count
     Check And Create YNW Session
     ${resp}=  GET On Session  ynw  /provider/alerts/count  expected_status=any
     RETURN  ${resp}

Get Alerts From Superadmin
     Check And Create YNW Session
     ${resp}=  GET On Session  ynw  /provider/alerts/superadmin  expected_status=any
     RETURN  ${resp}

Get Default Messages
     Check And Create YNW Session
     ${resp}=  GET On Session  ynw  /provider/ynwConf/messages  expected_status=any
     RETURN  ${resp}

Update Service Provider
     [Arguments]  ${id}  ${firstName}  ${lastName}  ${gender}  ${dob}
     ${bin}=  Create Dictionary  id=${id}  firstName=${firstName}  lastName=${lastName}  gender=${gender}  dob=${dob} 
     ${data}=  Create Dictionary  basicInfo=${bin}
     ${data}=  json.dumps  ${data}
     Check And Create YNW Session
     ${resp}=  PATCH On Session  ynw  provider/profile  data=${data}  expected_status=any
     RETURN  ${resp}

Update Service Provider With Emailid
     [Arguments]  ${id}  ${firstName}  ${lastName}  ${gender}  ${dob}  ${email}
     ${bin}=  Create Dictionary  id=${id}  firstName=${firstName}  lastName=${lastName}  gender=${gender}  dob=${dob}  email=${email}
     ${data}=  Create Dictionary  basicInfo=${bin}
     ${data}=  json.dumps  ${data}
     Check And Create YNW Session
     ${resp}=  PATCH On Session  ynw  provider/profile  data=${data}  expected_status=any
     RETURN  ${resp}
       
Get Provider Details
     [Arguments]  ${providerId}
     Check And Create YNW Session
     ${resp}=  GET On Session  ynw  /provider/profile/${providerId}  expected_status=any
     RETURN  ${resp}


Communication consumers
     [Arguments]  ${consumerId}  ${msg}
     ${data}=  Create Dictionary  communicationMessage=${msg} 
     ${data}=  json.dumps  ${data}
     Check And Create YNW Session  
     ${resp}=  POST On Session  ynw  /provider/communications/${consumerId}  data=${data}  expected_status=any
     RETURN  ${resp}
     
Get provider communications
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /provider/communications  expected_status=any
    RETURN  ${resp}    
    
Get provider Unread message Count
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /provider/communications/unreadCount  expected_status=any
    RETURN  ${resp} 
    
Get GalleryOrlogo image
    [Arguments]  ${target}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/${target}  expected_status=any
    RETURN  ${resp}
   	
Get specializations Sub Domain
    [Arguments]  ${domain}  ${subDomain}
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /ynwConf/specializations/${domain}/${subDomain}  expected_status=any
    RETURN  ${resp}
   	
Get Terminologies
    [Arguments]  ${domain}  ${subDomain}
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /ynwConf/terminologies/${domain}/${subDomain}  expected_status=any
    RETURN  ${resp}
    
Get Global Filters
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /ynwConf/refinedFilters  expected_status=any
    RETURN  ${resp}
    

Get Domain Filters 
    [Arguments]  ${domain}  
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /ynwConf/refinedFilters/${domain}  expected_status=any
    RETURN  ${resp}   
    
Get SubDomain Filters  
    [Arguments]  ${domain}  ${subDomain}
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /ynwConf/refinedFilters/${domain}/${subDomain}  expected_status=any
    RETURN  ${resp} 
    
Get Search Labels   
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /ynwConf/searchLabels  expected_status=any
    RETURN  ${resp}  
    
Get Domain Settings    
    [Arguments]  ${domain}  
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /ynwConf/settings/${domain}  expected_status=any
    RETURN  ${resp}
    
Get Sub Domain Settings  
    [Arguments]  ${domain}  ${subDomain}
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /ynwConf/settings/${domain}/${subDomain}  expected_status=any
    RETURN  ${resp}  

Get paymentTypes
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /ynwConf/paymentTypes  expected_status=any
    RETURN  ${resp} 
    
Get parkingTypes
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /ynwConf/parkingTypes  expected_status=any
    RETURN  ${resp}
    
Get verifyLevels 
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /ynwConf/verifyLevels  expected_status=any
    RETURN  ${resp} 
    
    
Update Privacy Setting
    [Arguments]  ${ph1}  ${email}
    ${data}=  Create Dictionary    emails=${email}   phoneNumbers=${ph1} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/privacySettings  data=${data}  expected_status=any
    RETURN  ${resp} 
    
Get Privacy Setting 
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw   /provider/privacySettings  expected_status=any
    RETURN  ${resp}
           
Enable Waitlist
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/waitlistMgr/Enable  expected_status=any
    RETURN  ${resp}

Disable Waitlist
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/waitlistMgr/Disable   expected_status=any
    RETURN  ${resp}

Add To Waitlist
    [Arguments]   ${consid}  ${service_id}  ${qid}  ${date}  ${consumerNote}  ${ignorePrePayment}  ${tab_id}  @{fids}
    ${cid}=  Create Dictionary  id=${consid}
    ${sid}=  Create Dictionary  id=${service_id}
    ${qid}=  Create Dictionary  id=${qid}
    ${fid}=  Create Dictionary  id=${fids[0]}
    ${len}=  Get Length  ${fids}
    ${fid}=  Create List  ${fid}
    :FOR    ${index}    IN RANGE  1  ${len}
    \   ${ap}=  Create Dictionary  id=${fids[${index}]}
    \	Append To List  ${fid} 	${ap}
    ${data}=    Create Dictionary    consumer=${cid}  service=${sid}  queue=${qid}  date=${date}  consumerNote=${consumerNote}  waitlistingFor=${fid}  ignorePrePayment=${ignorePrePayment}
    ${data}=  json.dumps  ${data}
    Set To Dictionary   ${headers}   tab=${tab_id}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  provider/waitlist  data=${data}  expected_status=any  headers=${headers}
    RETURN  ${resp}

Add To Waitlist For Foodjoints
    [Arguments]   ${consid}   ${psize}   ${service_id}  ${qid}  ${date}  ${consumerNote}  ${ignorePrePayment}  @{fids}
    ${cid}=  Create Dictionary  id=${consid}
    ${sid}=  Create Dictionary  id=${service_id}
    ${qid}=  Create Dictionary  id=${qid}
    ${fid}=  Create Dictionary  id=${fids[0]}
    ${len}=  Get Length  ${fids}
    ${fid}=  Create List  ${fid}
    :FOR    ${index}    IN RANGE  1  ${len}
    \   ${ap}=  Create Dictionary  id=${fids[${index}]}
    \	Append To List  ${fid} 	${ap}
    ${data}=    Create Dictionary    consumer=${cid}    partySize=${psize}  service=${sid}  queue=${qid}  date=${date}  consumerNote=${consumerNote}  waitlistingFor=${fid}  ignorePrePayment=${ignorePrePayment}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  provider/waitlist  data=${data}  expected_status=any
    RETURN  ${resp}

Get Waitlist By Id
    [Arguments]  ${wid}   ${tab_id}
    Set To Dictionary   ${headers}   tab=${tab_id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/${wid}   expected_status=any
    RETURN  ${resp}

	     
Get Waitlist Today
    [Arguments]    &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/waitlist/today  params=${kwargs}   expected_status=any
    RETURN  ${resp}

Get Waitlist Count Today
    [Arguments]    &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/waitlist/today/count  params=${kwargs}   expected_status=any
    RETURN  ${resp}

Get Waitlist Future
    [Arguments]     &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/waitlist/future/  params=${kwargs}   expected_status=any
    RETURN  ${resp}

Get Waitlist Count Future
    [Arguments]     &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/waitlist/future/count  params=${kwargs}   expected_status=any
    RETURN  ${resp}
    
Get Waitlist History
    [Arguments]    &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/waitlist/history  params=${kwargs}   expected_status=any
    RETURN  ${resp}

Get Waitlist Count History
    [Arguments]    &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/waitlist/history/count  params=${kwargs}   expected_status=any
    RETURN  ${resp}    
    
Get Waitlisted Consumers
    [Arguments]    &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/waitlist/consumers  params=${kwargs}   expected_status=any
    RETURN  ${resp}

Get Waitlisted Consumers Count
    [Arguments]    &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/waitlist/consumers/count  params=${kwargs}   expected_status=any
    RETURN  ${resp}    

Waitlist Action
    [Arguments]  ${action}  ${id} 
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/waitlist/${id}/${action}   expected_status=any
    RETURN  ${resp}

Waitlist Action Cancel
    [Arguments]  ${ids}  ${CR}  ${CM}
    ${auth}=  Create Dictionary  cancelReason=${CR}  communicationMessage=${CM}
    ${apple}=  json.dumps  ${auth}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/waitlist/${ids}/CANCEL  data=${apple}  expected_status=any
    RETURN  ${resp}

Get Waitlist State Changes
    [Arguments]    ${uuid}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/waitlist/states/${uuid}   expected_status=any
    RETURN  ${resp}
    
CommunicationBetweenProviderAndConsumer
	[Arguments]  ${uuid}  ${msg}
	${data}=  Create Dictionary  communicationMessage=${msg} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session  
    ${resp}=  POST On Session  ynw  /provider/waitlist/communicate/${uuid}  data=${data}  expected_status=any
    RETURN  ${resp}

Property File
    ${prop}=  Create Dictionary  caption=firstImage
    ${prop}=  Create Dictionary  0=${prop}
    ${prop}=  Create Dictionary  propertiesMap=${prop}
    ${prop}=  json.dumps  ${prop}
    Create File  TDD/Gallery.json  ${prop}

uploadGalleryImages
    [Arguments]  ${Cookie}
    Property File
    # ${resp}=  uploadGalleryImage
    ${resp}=  galleryImgUpload   ${Cookie}
    RETURN  ${resp} 

uploadGalleryImageFile
    [Arguments]  ${file}  ${Cookie}
    Property File
    # ${resp}=  uploadGalleryImage  ${file}
    ${resp}=  galleryImgUpload   ${Cookie}  ${file}
    RETURN  ${resp} 

uploadGalleryImageMultiple
    [Arguments]  ${Cookie}
    ${prop1}=  Create Dictionary  caption=firstImage
    ${prop2}=  Create Dictionary  caption=secondImage
    ${prop}=  Create Dictionary  0=${prop1}  1=${prop2}
    ${prop}=  Create Dictionary  propertiesMap=${prop}
    ${prop}=  json.dumps  ${prop}
    Create File  TDD/Gallery.json  ${prop} 
    # ${resp}=  uploadGalleryImage  flag=2
    ${resp}=  galleryImgUpload  ${Cookie}   flag=2
    RETURN  ${resp} 
   
uploadLogoImages
    [Arguments]  ${Cookie}  ${image}=/ebs/TDD/images1.jpeg
    ${prop}=  Create Dictionary  caption=logo
    ${prop}=  json.dumps  ${prop}
    Create File  TDD/logo.json  ${prop}  
    # ${resp}=  uploadLogoImage  
    ${resp}=  uploadProviderLogo   ${cookie}  ${image}
    RETURN  ${resp}
    
uploadServiceImages
    [Arguments]   ${id}  ${cookie}
    ${prop}=  Create Dictionary  caption=firstImage
    ${prop}=  Create Dictionary  0=${prop}
    ${prop}=  Create Dictionary  propertiesMap=${prop}
    ${prop}=  json.dumps  ${prop}
    Create File  TDD/Service.json  ${prop}
    # ${resp}=  uploadServiceImage  ${id}
    ${resp}=  serviceImgUpload  ${id}  ${cookie}
    RETURN  ${resp}

uploadItemImages
    [Arguments]   ${iId}
    ${prop}=  Create Dictionary  caption=logo
    ${prop}=  json.dumps  ${prop}
    Create File  TDD/proper.json  ${prop}  
    ${resp}=  uploadItemImage  ${iId}
    RETURN  ${resp}       
       
Waitlist Rating
   [Arguments]  ${uuid}  ${stars}  ${feedback}
   ${data}=  Create Dictionary  uuid=${uuid}  stars=${stars}  feedback=${feedback}
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw  /provider/waitlist/rating  data=${data}  expected_status=any
   RETURN  ${resp}
   
Update Rating
   [Arguments]  ${uuid}  ${stars}  ${feedback}
   ${data}=  Create Dictionary  uuid=${uuid}  stars=${stars}  feedback=${feedback}
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  /provider/waitlist/rating  data=${data}  expected_status=any
   RETURN  ${resp}
   
Create provider Note
   [Arguments]  ${uuid}  ${mesage}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw  /provider/waitlist/notes/${uuid}   ${mesage}   expected_status=any
   RETURN  ${resp}

get provider Note
   [Arguments]    ${consumerId}
   Check And Create YNW Session
   ${resp}=    GET On Session    ynw  /provider/waitlist/${consumerId}/notes   expected_status=any
   RETURN  ${resp}

   
Get Invoices 
    [Arguments]  ${status}
   Check And Create YNW Session
   ${resp}=    GET On Session    ynw  /provider/license/invoices/${status}/status   expected_status=any
   RETURN  ${resp}

Get Invoice By uuid
   [Arguments]  ${uuid}
   Check And Create YNW Session
   ${resp}=    GET On Session    ynw  /provider/license/invoices/${uuid}   expected_status=any   
   RETURN  ${resp}  

Service Bill
   [Arguments]  ${serrs}  ${serviceId}  ${srQua}  @{srDic}   
   ${service}=  Create Dictionary  reason=${serrs}  serviceId=${serviceId}  discountIds=${srDic}  quantity=${srQua}
   RETURN  ${service}   

Item Bill 
   [Arguments]  ${rsitm}  ${itemId}  ${itmqua}  @{itmdisc}
   ${items}=  Create Dictionary  reason=${rsitm}  itemId=${itemId}   discountIds=${itmdisc}  quantity=${itmqua}
   RETURN  ${items}  

Service Discount
    [Arguments]  ${serId}  @{serDis}
    ${serdis}=   Create Dictionary  serviceId=${serId}  discountIds=${serDis}   expected_status=any
    RETURN  ${serdis}

Item Discount
    [Arguments]  ${itemId}  @{itDis}
    ${itdis}=   Create Dictionary  itemId=${itemId}  discountIds=${itDis}   expected_status=any
    RETURN  ${itdis}

Bill Discount Input
    [Arguments]  ${bId}  ${pnote}  ${cnote}
    ${bdis}=   Create Dictionary  id=${bId}  privateNote=${pnote}  displayNote=${cnote}
    RETURN  ${bdis}

Bill Discount Adhoc Input
    [Arguments]  ${bId}  ${pnote}  ${cnote}   ${value}
    ${bdis}=   Bill Discount Input  ${bId}  ${pnote}  ${cnote}
    Set To Dictionary  ${bdis}  discValue=${value}
    RETURN  ${bdis}

Bill Discount
    [Arguments]  ${bId}  @{bDis}
    ${bdis}=   Create Dictionary  id=${bId}  discounts=${bDis}
    RETURN  ${bdis}

Remove Bill Discount
    [Arguments]  ${bId}  ${dis}
    ${dis}=  Create Dictionary  id=${dis}
    ${dis}=  Create List  ${dis}
    ${bdis}=   Create Dictionary  id=${bId}  discounts=${dis}
    RETURN  ${bdis}

Provider Coupons
    [Arguments]  ${bId}  @{cIds}
    ${pc}=   Create Dictionary  id=${bId}  couponIds=${cIds}
    RETURN  ${pc} 
   
Get Bill By UUId   
   [Arguments]  ${uuid}
   Check And Create YNW Session
   ${resp}=    GET On Session    ynw  /provider/bill/${uuid}  expected_status=any    
   RETURN  ${resp} 

Update Bill  
   [Arguments]  ${uuid}  ${action}  ${data}
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=    PUT On Session    ynw  /provider/bill/${action}/${uuid}    data=${data}  expected_status=any  
   RETURN  ${resp} 

Settl Bill
   [Arguments]  ${uuid}   
   Check And Create YNW Session
   ${resp}=    PUT On Session    ynw  /provider/bill/settlebill/${uuid}  expected_status=any   
   RETURN  ${resp} 

Get Bill By Status   
   [Arguments]  ${status}
   Check And Create YNW Session
   ${resp}=    GET On Session    ynw  /provider/bill/status/${status}  expected_status=any    
   RETURN  ${resp}   

Accept Payment
   [Arguments]  ${uuid}  ${acceptPaymentBy}  ${amount}  
   ${data}=  Create Dictionary   uuid=${uuid}  acceptPaymentBy=${acceptPaymentBy}   amount=${amount}  
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=    POST On Session    ynw  /provider/bill/acceptPayment    data=${data}  expected_status=any  
   RETURN  ${resp} 

Get Payment By UUId
   [Arguments]  ${uuid}
   Check And Create YNW Session
   ${resp}=    GET On Session    ynw  /provider/payment/${uuid}  expected_status=any    
   RETURN  ${resp}   

Get License Metadata
   Check And Create YNW Session
   ${resp}=    GET On Session    ynw  /provider/license/licensemetadata  expected_status=any    
   RETURN  ${resp}

Claim Account
    [Arguments]  ${acid}
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw  /provider/claim/${acid}   expected_status=any 
    RETURN  ${resp}   

Generate Invoice
    [Arguments]  ${acid}  ${cyc}
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw  /provider/license/invoice/${cyc}/${acid}/IST   expected_status=any 
    RETURN  ${resp}

Get badge
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/ynwConf/badges   expected_status=any     
    RETURN  ${resp}
   
Make Payment Mock
    [Arguments]  ${amount}  ${response}  ${uuid}  ${purpose}
    Check And Create YNW Session
    ${data}=  Create Dictionary  amount=${amount}  paymentMode=Mock  uuid=${uuid}  mockResponse=${response}  purpose=${purpose}
    ${data}=  json.dumps  ${data}
    ${resp}=  POST On Session    ynw  /provider/payment  data=${data}  expected_status=any
    RETURN  ${resp}

Make Payment
    [Arguments]  ${amount}  ${mode}  ${uuid}  ${purpose}
    Check And Create YNW Session
    ${data}=  Create Dictionary  amount=${amount}  paymentMode=${mode}  uuid=${uuid}   purpose=${purpose}
    ${data}=  json.dumps  ${data}
    ${resp}=  POST On Session    ynw  /provider/payment  data=${data}  expected_status=any
    RETURN  ${resp}
    
Update Tax Percentage
    [Arguments]  ${taxPercentage}  ${gstNumber}  
    ${data}=  Create Dictionary  taxPercentage=${taxPercentage}  gstNumber=${gstNumber}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  /provider/payment/tax   data=${data}  expected_status=any
    RETURN  ${resp}

Get Tax Percentage
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/payment/tax   expected_status=any    
    RETURN  ${resp}   

Get Adword Count
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/license/adwords/count  expected_status=any     
    RETURN  ${resp}     


AddFamilyMemberByProviderWithPhoneNo
    [Arguments]  ${id}  ${firstname}  ${lastname}  ${dob}  ${gender}  ${PhoneNo}
    Check And Create YNW Session
    ${data}=  Create Dictionary  firstName=${firstname}  lastName=${lastname}  dob=${dob}  gender=${gender}  primaryMobileNo=${PhoneNo}
    ${data}=  Create Dictionary  parent=${id}  userProfile=${data}
    ${data}=  json.dumps  ${data}
    ${resp}=  POST On Session   ynw   /provider/familyMember   data=${data}  expected_status=any
    RETURN  ${resp}

Get Spoke Languages
     Check And Create YNW Session
     ${resp}=  GET On Session  ynw  ynwConf/spokenLangs  expected_status=any 
     RETURN  ${resp}    

Get Jaldee Coupons By Provider
     Check And Create YNW Session
     ${resp}=  GET On Session  ynw  /provider/jaldee/coupons  expected_status=any 
     RETURN  ${resp}  

Enable Jaldee Coupon By Provider
    [Arguments]  ${coupon_code}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  /provider/jaldee/coupons/${coupon_code}/enable   expected_status=any
    RETURN  ${resp}

Disable Jaldee Coupon By Provider
    [Arguments]  ${coupon_code}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  /provider/jaldee/coupons/${coupon_code}/disable   expected_status=any
    RETURN  ${resp}

Get Jaldee Coupons By Coupon_code
     [Arguments]  ${coupon_code}  
     Check And Create YNW Session
     ${resp}=  GET On Session  ynw  /provider/jaldee/coupons/${coupon_code}  expected_status=any 
     RETURN  ${resp}

Get Jaldee Coupon Stats By Coupon_code
     [Arguments]  ${coupon_code}  
     Check And Create YNW Session
     ${resp}=  GET On Session  ynw  /provider/jaldee/coupons/${coupon_code}/stats  expected_status=any 
     RETURN  ${resp}

Apply Jaldee Coupon By Provider
     [Arguments]  ${coupon_code}  ${wid}
     Check And Create YNW Session
     ${resp}=  PUT On Session  ynw  /provider/bill/addJaldeeCoupons/${wid}   data=${coupon_code}   expected_status=any
     RETURN  ${resp}

Create Reimburse Reports By Provider
     [Arguments]  ${Day1}  ${Day2}   
     Check And Create YNW Session
     ${resp}=  POST On Session  ynw  /provider/jaldee/coupons/jcreports/reimburse/${Day1}/${Day2}   expected_status=any
     RETURN  ${resp}

Get Reimburse Reports By Provider
     [Arguments]    &{kwargs}
     Check And Create YNW Session
     ${resp}=  GET On Session  ynw  /provider/jaldee/coupons/jcreports/reimburse  params=${kwargs}   expected_status=any
     RETURN  ${resp}

Get Reimburse Reports By Provider By InvoiceId
     [Arguments]  ${invoice_id} 
     Check And Create YNW Session
     ${resp}=  GET On Session  ynw  /provider/jaldee/coupons/jcreports/reimburse/${invoice_id}  expected_status=any  
     RETURN  ${resp}

Request For Payment of Jaldeecoupon
     [Arguments]  ${invoice_id}
     Check And Create YNW Session
     ${resp}=  PUT On Session  ynw  /provider/jaldee/coupons/jcreports/reimburse/${invoice_id}/requestPayment    expected_status=any
     RETURN  ${resp}

Set Fixed Waiting Time
     [Arguments]  ${uuid}  ${waiting_time}
     Check And Create YNW Session
     ${resp}=  PUT On Session  ynw  /provider/waitlist/${uuid}/${waiting_time}/waitingTime    expected_status=any
     RETURN  ${resp}

Update Subdomain Level Field For Doctor 
     [Arguments]  ${subdomain}
     ${qfn}=  Create Dictionary  qualificationName=MBBS  qualifiedyear=2000  qualifiedMonth=July  qualifiedFrom=AIIMS
     ${qfn}=  Create List  ${qfn}
     ${memb}=  Create Dictionary  nameofassociation=IMA   membersince=2001 
     ${memb}=  Create List  ${memb}
     ${data}=  Create Dictionary    doceducationalqualification=${qfn}   docmemberships=${memb}  docgender=male  
     ${data}=  json.dumps  ${data}
     Check And Create YNW Session
     ${resp}=  PUT On Session  ynw  /provider/bProfile/${subdomain}  data=${data}  expected_status=any
     RETURN  ${resp}

Update Mandatory Fields BeautyCare
    [Arguments]  ${subdomain}
    ${memb}=  Create Dictionary  nameofassociation=KBBA  membersince=2000
    ${memb}=  Create List  ${memb}
    ${data}=  Create Dictionary  permemberships=${memb} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bProfile/domain  data=${data}  expected_status=any
    Should Be Equal As Strings  ${resp.status_code}  200
    ${qfn}=  Create Dictionary  qualificationName=MBBS  qualifiedyear=2000  qualifiedMonth=July  qualifiedFrom=AIIMS
    ${qfn}=  Create List  ${qfn}
    ${data}=  Create Dictionary   beautyeducationalqualification=${qfn}
    ${data}=  json.dumps  ${data}
    ${resp}=  PUT On Session  ynw  /provider/bProfile/${subdomain}  data=${data}  expected_status=any
    Should Be Equal As Strings  ${resp.status_code}  200 

Is Available Queue Now
     Check And Create YNW Session
     ${resp}=  GET On Session  ynw   /provider/waitlist/queues/isAvailableNow/today  expected_status=any 
     RETURN  ${resp}

Instant Queue
    [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}     ${eDate}    ${stime}    ${etime}    ${parallel}  ${capacity}  ${loc}  @{vargs}
    ${bs}=  TimeSpec   ${rt}   ${ri}   ${sDate}  ${eDate}  ${EMPTY}  ${stime}  ${etime}
    ${location}=  Create Dictionary  id=${loc}
    ${len}=  Get Length  ${vargs}
    ${service}=  Create Dictionary  id=${vargs[0]}
    ${services}=  Create List  ${service}
    :FOR    ${index}    IN RANGE  1  ${len}
        \	${service}=  Create Dictionary  id=${vargs[${index}]} 
        \   Append To List  ${services}  ${service}
    ${data}=  Create Dictionary  name=${name}  queueSchedule=${bs}  parallelServing=${parallel}  capacity=${capacity}  location=${location}  services=${services}
    RETURN  ${data}

Create Instant Queue
    [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}     ${eDate}    ${stime}    ${etime}    ${parallel}  ${capacity}  ${loc}  @{vargs}
    ${data}=  Instant Queue  ${name}  ${rt}   ${ri}   ${sDate}     ${eDate}    ${stime}    ${etime}    ${parallel}  ${capacity}  ${loc}  @{vargs}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/waitlist/queues/instant  data=${data}  expected_status=any
    RETURN  ${resp}


Instant Queue without Service
   [Arguments]  ${name}   ${rt}   ${ri}   ${sDate}     ${eDate}    ${stime}    ${etime}    ${parallel}  ${capacity}  ${loc}
   ${bs}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${EMPTY}  ${stime}  ${etime}
   ${location}=  Create Dictionary  id=${loc}
   ${data}=  Create Dictionary  name=${name}  queueSchedule=${bs}  parallelServing=${parallel}  capacity=${capacity}  location=${location}  services=${None}
   RETURN  ${data}

Create Instant Queue without Service
    [Arguments]  ${name}  ${rt}   ${ri}   ${sDate}     ${eDate}    ${stime}    ${etime}    ${parallel}  ${capacity}  ${loc}
    ${data}=  Instant Queue without Service   ${name}  ${rt}   ${ri}   ${sDate}     ${eDate}    ${stime}    ${etime}    ${parallel}  ${capacity}  ${loc}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/waitlist/queues/instant  data=${data}  expected_status=any
    RETURN  ${resp}

Update Instant Queue
    [Arguments]  ${qid}  ${name}   ${rt}   ${ri}   ${sDate}     ${eDate}    ${stime}    ${etime}    ${parallel}  ${capacity}  ${loc}  @{vargs}
    ${data}=  Instant Queue  ${name}  ${rt}  ${ri}  ${sDate}     ${eDate}    ${stime}    ${etime}    ${parallel}  ${capacity}  ${loc}  @{vargs}
    Set To Dictionary  ${data}  id=${qid}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/waitlist/queues/instant  data=${data}  expected_status=any
    RETURN  ${resp}

Update Instant Queue without service
    [Arguments]  ${qid}  ${name}  ${rt}   ${ri}  ${sDate}     ${eDate}    ${stime}    ${etime}    ${parallel}  ${capacity}  ${loc}
    ${data}=  Instant Queue without Service  ${name}  ${rt}  ${ri}   ${sDate}     ${eDate}    ${stime}    ${etime}    ${parallel}  ${capacity}  ${loc}
    Set To Dictionary  ${data}  id=${qid}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/waitlist/queues/instant  data=${data}  expected_status=any
    RETURN  ${resp}

Get Queue by Filter
    [Arguments]   ${filterArg}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/queues/filter   params=${filterArg}  expected_status=any
    RETURN  ${resp}

Online Checkin In Queue
    [Arguments]   ${queue_id}  ${status}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  ynw  /provider/waitlist/queues/onlineCheckIn/${status}/${queue_id}   expected_status=any
    RETURN  ${resp}

Future Checkin In Queue
    [Arguments]   ${queue_id}  ${status}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  ynw  /provider/waitlist/queues/futureCheckIn/${status}/${queue_id}   expected_status=any
    RETURN  ${resp}

Toggle Department Enable
	Check And Create YNW Session
    ${resp}=  PUT On Session    ynw  /provider/settings/waitlistMgr/department/Enable  expected_status=any
    RETURN  ${resp}   
 
Toggle Department Disable
	Check And Create YNW Session
    ${resp}=  PUT On Session    ynw  /provider/settings/waitlistMgr/department/Disable  expected_status=any
    RETURN  ${resp} 

Create Department
    [Arguments]  ${dep_name}  ${dep_code}  ${dep_desc}   @{vargs}
    ${data}=  Create Dictionary  departmentName=${dep_name}  departmentCode=${dep_code}  departmentDescription=${dep_desc}  serviceIds=${vargs} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/departments  data=${data}  expected_status=any
    RETURN  ${resp}

Disable Department
   [Arguments]  ${depid} 
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  /provider/departments/${depid}/disable  expected_status=any
   RETURN  ${resp}

Enable Department
   [Arguments]  ${depid} 
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  /provider/departments/${depid}/enable  expected_status=any
   RETURN  ${resp} 
   
Create Department With ServiceName
    [Arguments]  ${dep_name}  ${dep_code}  ${dep_desc}  @{vargs}
    ${data}=  Create Dictionary  departmentName=${dep_name}  departmentCode=${dep_code}  departmentDescription=${dep_desc}  serviceNames=${vargs} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/departments  data=${data}  expected_status=any
    RETURN  ${resp}

Get Department ById
    [Arguments]   ${dep_id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/departments/${dep_id}  expected_status=any
    RETURN  ${resp}

Get Departments
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/departments  expected_status=any
    RETURN  ${resp}

Update Department
    [Arguments]  ${dep_id}  ${dep_name}  ${dep_code}  ${dep_desc}  @{vargs}
    ${data}=  Create Dictionary  departmentName=${dep_name}  departmentCode=${dep_code}  departmentDescription=${dep_desc}  serviceIds=${vargs} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/departments/${dep_id}  data=${data}  expected_status=any
    RETURN  ${resp}

Get Services in Department
    [Arguments]   ${dep_id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/departments/${dep_id}/service  expected_status=any
    RETURN  ${resp}

Add Services To Department
    [Arguments]  ${dep_id}  @{vargs}
    ${data}=  Create Dictionary  serviceIds=${vargs}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/departments/${dep_id}/service  data=${data}  expected_status=any
    RETURN  ${resp}

Delete Service ById In A Department
   [Arguments]   ${dep_id}  ${service_id}
   Check And Create YNW Session
   ${resp}=    DELETE On Session    ynw  /provider/departments/${dep_id}/service/${service_id}  expected_status=any
   RETURN  ${resp}

Change Department Status
   [Arguments]   ${dep_id}  ${status}
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  /provider/departments/${dep_id}/${status}   expected_status=any
   RETURN  ${resp}

Branch Signup
   [Arguments]  ${cop_id}  ${name}  ${code}  ${reg_code}  ${email}  ${desc}  ${pass}  ${p_name}  ${p_l_name}  ${city}  ${state}  ${address}  ${mob_no}  ${al_phone}  ${dob}  ${gender}  ${p_email}  ${country_code}  ${is_admin}  ${sector}  ${sub_sector}  ${licpkg}  @{vargs}
   ${provider}=  Create Dictionary  firstName=${p_name}  lastName=${p_l_name}  city=${city}  state=${state}  address=${address}  primaryMobileNo=${mob_no}  alternativePhoneNo=${al_phone}  dob=${dob}  gender=${gender}  email=${p_email}  countryCode=${country_code}
   ${profile}=  Create Dictionary  userProfile=${provider}  isAdmin=${is_admin}  sector=${sector}  subSector=${sub_sector}  licPkgId=${licpkg}
   ${data}=  Create Dictionary  corpId=${cop_id}  branchName=${name}  branchCode=${code}  regionalCode=${reg_code}  branchEmail=${email}  branchDescription=${desc}  commonPassword=${pass}  provider=${profile}   services=${vargs}
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw   /sa/branch   data=${data}  expected_status=any
   RETURN  ${resp}


Branch_Profile
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

Branch Business Profile
    [Arguments]   ${acct_id}  ${bName}  ${bDesc}  ${shname}   ${place}   ${longi}  ${latti}  ${g_url}  ${pin}  ${adds}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${ph1}  ${ph2}  ${email1}
    ${data}=  Branch_Profile  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pin}  ${adds}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${ph1}  ${ph2}  ${email1}
    ${params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  ynw  /sa/bProfile  data=${data}    params=${params}  expected_status=any
    RETURN  ${resp}

Enable/Disable Branch Search Data
    [Arguments]   ${acct_id}  ${status}
    ${params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /sa/search/${status}    params=${params}  expected_status=any
    RETURN  ${resp}

Create Department For Branch
    [Arguments]  ${acct_id}  ${dep_name}  ${dep_code}  ${dep_desc}  ${status}  @{vargs}
    ${data}=  Create Dictionary  departmentName=${dep_name}  departmentCode=${dep_code}  departmentDescription=${dep_desc}  serviceIds=${vargs}  departmentStatus=${status} 
    ${data}=  json.dumps  ${data}
    ${params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /sa/branch/department  data=${data}   params=${params}  expected_status=any
    RETURN  ${resp}

Branch SP Creation
    [Arguments]  ${p_name}  ${p_l_name}  ${city}  ${state}  ${address}  ${mob_no}  ${al_phone}  ${dob}  ${gender}  ${p_email}  ${country_code}  ${is_admin}  ${sector}  ${sub_sector}  ${licpkg}  ${dept_code}  ${branch_code}  ${pass}  @{vargs}
    ${profile}=  Create Dictionary  firstName=${p_name}  lastName=${p_l_name}  city=${city}  state=${state}  address=${address}  primaryMobileNo=${mob_no}  alternativePhoneNo=${al_phone}  dob=${dob}  gender=${gender}  email=${p_email}  countryCode=${country_code}
    ${data}=  Create Dictionary    userProfile=${profile}  isAdmin=${is_admin}  sector=${sector}  subSector=${sub_sector}  licPkgId=${licpkg}  deparmentCode=${dept_code}  branchCode=${branch_code}  commonPassword=${pass}  services=${vargs}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /sa/branch/provider   data=${data}  expected_status=any
    RETURN  ${resp}

Branch SP Business Profile
    [Arguments]   ${acct_id}  ${bName}  ${bDesc}  ${shname}   ${place}   ${longi}  ${latti}  ${g_url}  ${pin}  ${adds}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${ph1}  ${ph2}  ${email1}
    ${data}=  Branch_Profile  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pin}  ${adds}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${ph1}  ${ph2}  ${email1}
    ${params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  ynw  /sa/bProfile  data=${data}    params=${params}  expected_status=any
    RETURN  ${resp}

Branch Level Update Subdomain Level Field For Doctor 
     [Arguments]  ${subdomain}  ${acct_id}
     ${qfn}=  Create Dictionary  qualificationName=MBBS  qualifiedyear=2000  qualifiedMonth=July  qualifiedFrom=AIIMS
     ${qfn}=  Create List  ${qfn}
     ${memb}=  Create Dictionary  nameofassociation=IMA   membersince=2001 
     ${memb}=  Create List  ${memb}
     ${data}=  Create Dictionary    doceducationalqualification=${qfn}   docmemberships=${memb}  docgender=male  
     ${data}=  json.dumps  ${data}
     ${params}=  Create Dictionary  account=${acct_id}
     Check And Create YNW Session
     ${resp}=  PUT On Session  ynw  /sa/branch/provider/bProfile/${subdomain}  data=${data}  params=${params}  expected_status=any
     RETURN  ${resp}

Get Server Time
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/server/date  expected_status=any
    RETURN  ${resp}

Update Subdomain_Level
     [Arguments]  ${data}  ${subdomain}
     ${data}=  json.dumps  ${data}
     Check And Create YNW Session
     ${resp}=  PUT On Session  ynw  /provider/bProfile/${subdomain}  data=${data}  expected_status=any
     RETURN  ${resp}

Update Specialization
    [Arguments]  ${data}    
    ${data}=  json.dumps  ${data}
    Log  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bProfile   data=${data}  expected_status=any
    RETURN  ${resp}
    
Provider Notification-1     
    [Arguments]  ${resourcetype}  ${eventtype}  ${sms}  ${email}  ${pushmessage}
    @{list1}=  Run Keyword If  '${sms}' == '${EMPTY}'   Create List
    ...  ELSE	 Create List  ${sms}
    @{list2}=  Run Keyword If  '${email}' == '${EMPTY}'  Create List
    ...  ELSE   Create List  ${email}
    ${data}=  Create Dictionary  resourceType=${resourcetype}  eventType=${eventtype}  sms=${list1}  email=${list2}  pushMessage=${pushmessage}
    Log  ${data}
    ${header}=  Create Dictionary  content-type=application/json
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    Log  ${data}
    ${value}=  POST On Session  ynw  /provider/settings/notification   data=${data}  expected_status=any
    RETURN  ${value}  

Provider Notification-2     
    [Arguments]  ${resourcetype}  ${eventtype}  ${sms}  ${email}  ${pushmessage}
    ${data}=  Create Dictionary  resourceType=${resourcetype}  eventType=${eventtype}  sms=${sms}  email=${email}  pushMessage=${pushmessage}
    Log  ${data}
    ${header}=  Create Dictionary  content-type=application/json
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    Log  ${data}
    ${value}=  POST On Session  ynw  /provider/settings/notification   data=${data}  expected_status=any
    RETURN  ${value}         

Update Provider Notification-1     
    [Arguments]  ${resourcetype}  ${eventtype}  ${sms}  ${email}  ${pushmessage}
    @{list1}=  Run Keyword If  '${sms}' == '${EMPTY}'   Create List
    ...  ELSE	 Create List  ${sms}
    @{list2}=  Run Keyword If  '${email}' == '${EMPTY}'  Create List
    ...  ELSE   Create List  ${email}
    ${data}=  Create Dictionary  resourceType=${resourcetype}  eventType=${eventtype}  sms=${list1}  email=${list2}  pushMessage=${pushmessage}
    Log  ${data}
    ${header}=  Create Dictionary  content-type=application/json
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    Log  ${data}
    ${value}=  PUT On Session  ynw  /provider/settings/notification   data=${data}  expected_status=any
    RETURN  ${value} 

Update Provider Notification-2  
    [Arguments]  ${resourcetype}  ${eventtype}  ${sms}  ${email}  ${pushmessage}
    ${data}=  Create Dictionary  resourceType=${resourcetype}  eventType=${eventtype}  sms=${sms}  email=${email}  pushMessage=${pushmessage}
    Log  ${data}
    ${header}=  Create Dictionary  content-type=application/json
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    Log  ${data}
    ${value}=  PUT On Session  ynw  /provider/settings/notification   data=${data}  expected_status=any
    RETURN  ${value}       

Get Notification Details
    Check And Create YNW Session
    ${value}=  GET On Session  ynw  provider/settings/notification  expected_status=any
    RETURN  ${value}

View HS Settings
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/settings/homeservice  expected_status=any
    RETURN  ${resp}

Enable HS
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/homeservice/Enable  expected_status=any
    RETURN  ${resp}

Disable HS
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/homeservice/Disable  expected_status=any 
    RETURN  ${resp}

Enable Online HS
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/homeservice/onlineHs/Enable  expected_status=any
    RETURN  ${resp}

Disable Online HS
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/homeservice/onlineHs/Disable  expected_status=any
    RETURN  ${resp}

Enable Future HS
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/homeservice/futureHs/Enable  expected_status=any
    RETURN  ${resp}

Disable Future HS
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/homeservice/futureHs/Disable  expected_status=any
    RETURN  ${resp}

Update HS Settings
    [Arguments]   ${enableHomeService}   ${onlineHs}  ${futureHs}    ${notification}    ${otpVerificationType}   ${liveArrivalNotificationType}
    ${data}=  Create Dictionary  enableHomeService=${enableHomeService}  onlineHs=${onlineHs}  futureHs=${futureHs}   sendNotification=${notification}    otpVerificationType=${otpVerificationType}    liveArrivalNotificationType=${liveArrivalNotificationType}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/homeservice   data=${data}  expected_status=any
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

Create Label
    [Arguments]  ${l_name}  ${display_name}  ${desc}  ${values}  ${notifications}
    ${data}=  Create Dictionary  label=${l_name}  displayName=${display_name}  description=${desc}  valueSet=${values}  notification=${notifications}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/waitlist/label   data=${data}  expected_status=any
    RETURN  ${resp}

Get Labels
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/label  expected_status=any
    RETURN  ${resp}

Get Label By Id
    [Arguments]   ${label_id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/label/${label_id}  expected_status=any
    RETURN  ${resp}

Update Label
    [Arguments]  ${label_id}  ${l_name}  ${display_name}  ${desc}  ${values}  ${notifications}
    ${data}=  Create Dictionary  id=${label_id}  label=${l_name}  displayName=${display_name}  description=${desc}  valueSet=${values}  notification=${notifications}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/waitlist/label   data=${data}  expected_status=any
    RETURN  ${resp}

Delete Label
   [Arguments]   ${id}
   Check And Create YNW Session
   ${resp}=    DELETE On Session    ynw  /provider/waitlist/label/${id}  expected_status=any
   RETURN  ${resp}


Create Fieldlist For QueueSet
    [Arguments]  @{vargs}
    ${len}=  Get Length  ${vargs}
    ${values}=  Create Dictionary  name=${vargs[0]}  displayName=${vargs[1]}  defaultValue=${vargs[2]}  label=${vargs[3]}  order=${vargs[4]}
    ${field_list}=  Create List  ${values}
    FOR    ${index}   IN RANGE   5  ${len}  5
        ${index2}=  Evaluate  ${index}+1
        ${index3}=  Evaluate  ${index}+2
        ${index4}=  Evaluate  ${index}+3
        ${index5}=  Evaluate  ${index}+4
        ${values}=  Create Dictionary  name=${vargs[${index}]}  displayName=${vargs[${index2}]}  defaultValue=${vargs[${index3}]}  label=${vargs[${index4}]}  order=${vargs[${index5}]}
        Append To List  ${field_list}  ${values}
    END
    RETURN  ${field_list}

Create QueueSet
    [Arguments]  ${s_name}  ${display_name}  ${desc}  ${field_list}  @{statusboard_for}
    ${len}=  Get Length  ${statusboard_for}
    ${len}=  Evaluate  ${len}-1
    ${list}=  Create List
    FOR    ${index}   IN RANGE   0  ${len}  2
        ${index2}=  Evaluate  ${index}+1
        ${ids}=  Create Dictionary   type=${statusboard_for[${index}]}  id=${statusboard_for[${index2}]}
        Append To List  ${list}  ${ids}
    END
    ${data}=  Create Dictionary  name=${s_name}  displayName=${display_name}  description=${desc}  fieldList=${field_list}  statusBoardFor=${list}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/statusBoard   data=${data}  expected_status=any
    RETURN  ${resp}

Get QueueSets
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/statusBoard  expected_status=any
    RETURN  ${resp}

Get QueueSet By Id
    [Arguments]   ${id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/statusBoard/${id}  expected_status=any
    RETURN  ${resp}

Delete QueueSet By Id
   [Arguments]   ${id}
   Check And Create YNW Session
   ${resp}=    DELETE On Session    ynw  /provider/statusBoard/${id}  expected_status=any
   RETURN  ${resp}

Update QueueSet
    [Arguments]   ${s_id}  ${s_name}  ${display_name}  ${desc}  ${field_list}  @{statusboard_for}
    ${len}=  Get Length  ${statusboard_for}
    ${len}=  Evaluate  ${len}-1
    ${list}=  Create List
    FOR    ${index}   IN RANGE   0  ${len}  2
        ${index2}=  Evaluate  ${index}+1
        ${ids}=  Create Dictionary   type=${statusboard_for[${index}]}  id=${statusboard_for[${index2}]}
        Append To List  ${list}  ${ids}
    END
    ${data}=  Create Dictionary  id=${s_id}  name=${s_name}  displayName=${display_name}  description=${desc}  fieldList=${field_list}  statusBoardFor=${list}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/statusBoard   data=${data}  expected_status=any
    RETURN  ${resp}

Create Metric For Status Board
    [Arguments]  @{matrics}
    ${len}=  Get Length  ${matrics}
    ${len}=  Evaluate  ${len}-1
    ${list}=  Create List
    FOR    ${index}   IN RANGE   0  ${len}  2
        ${index2}=  Evaluate  ${index}+1
        ${ids}=  Create Dictionary   position=${matrics[${index}]}  sbId=${matrics[${index2}]}
        Append To List  ${list}  ${ids}
    END
    RETURN  ${list}

Create Status Board
    [Arguments]  ${d_name}  ${display_name}  ${layout}  ${metric_list}
    ${data}=  Create Dictionary  name=${d_name}  displayName=${display_name}  layout=${layout}  metric=${metric_list}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/statusBoard/dimension   data=${data}  expected_status=any
    RETURN  ${resp}

Get Status Boards
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/statusBoard/dimension  expected_status=any
    RETURN  ${resp}

Get Status Board By Id
    [Arguments]   ${id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/statusBoard/dimension/${id}  expected_status=any
    RETURN  ${resp}

Delete Status Board By Id
   [Arguments]   ${id}
   Check And Create YNW Session
   ${resp}=    DELETE On Session    ynw  /provider/statusBoard/dimension/${id}  expected_status=any
   RETURN  ${resp}

Update Status Board
    [Arguments]  ${d_id}  ${d_name}  ${display_name}  ${layout}  ${metric_list}
    ${data}=  Create Dictionary  id=${d_id}  name=${d_name}  displayName=${display_name}  layout=${layout}  metric=${metric_list}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/statusBoard/dimension   data=${data}  expected_status=any
    RETURN  ${resp}

Enable JDN for Label
    [Arguments]    ${label}   ${displayNote}   
    ${data}=   Create Dictionary   label=${label}   displayNote=${displayNote}   
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /provider/settings/jdn/enable    data=${data}  expected_status=any
    RETURN  ${resp}

Enable JDN for Percent
    [Arguments]    ${displayNote}   ${discPercentage}   ${discMax}   
    ${data}=   Create Dictionary   displayNote=${displayNote}   discPercentage=${discPercentage}   discMax=${discMax} 
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /provider/settings/jdn/enable    data=${data}  expected_status=any
    RETURN  ${resp}

Get JDN 
    Check and Create YNW Session
	${resp}=  GET On Session   ynw  /provider/settings/jdn  expected_status=any
	RETURN  ${resp}

Disable JDN
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/jdn/disable  expected_status=any
    RETURN  ${resp}

Update JDN with Label
    [Arguments]    ${label}   ${displayNote}   
    ${data}=   Create Dictionary   label=${label}   displayNote=${displayNote}   
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    PUT On Session   ynw    /provider/settings/jdn    data=${data}  expected_status=any
    RETURN  ${resp}

Update JDN with Percentage
    [Arguments]    ${displayNote}   ${discPercentage}   ${discMax}   
    ${data}=   Create Dictionary   displayNote=${displayNote}   discPercentage=${discPercentage}   discMax=${discMax} 
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    PUT On Session   ynw   /provider/settings/jdn    data=${data}  expected_status=any
    RETURN  ${resp}

Join to Corporate
    [Arguments]  ${corpUid}  
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/corp/joinCorp/${corpUid}  expected_status=any  
    RETURN  ${resp}

Switch To Corporate
    [Arguments]  ${corporateName}   ${corporateCode}    ${multilevel}  
    ${data}=  Create Dictionary   corporateName=${corporateName}    corporateCode=${corporateCode}   multilevel=${multilevel}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/corp/switchToCorp   data=${data}  expected_status=any
    RETURN  ${resp}

Branch User Creation for SP
    [Arguments]  ${firstname}  ${lastname}   ${primaryMobileNo}   ${email}  ${subSector}   ${commonPassword}
    ${usp}=    Create Dictionary   firstName=${firstname}  lastName=${lastname}   primaryMobileNo=${primaryMobileNo}  email=${email}  countryCode=+91
    ${data}=  Create Dictionary  userProfile=${usp}   subSector=${subSector}  commonPassword=${commonPassword}
    RETURN  ${data}

Create Branch SP
    [Arguments]  ${firstname}  ${lastname}   ${primaryMobileNo}  ${email}  ${subSector}  ${commonPassword}
    ${data}=   Branch User Creation for SP  ${firstname}  ${lastname}  ${primaryMobileNo}  ${email}  ${subSector}  ${commonPassword}
    ${data}=   json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /provider/branch/createSp    data=${data}  expected_status=any
    RETURN  ${resp}

Create SP With Pseudo Corp and Branch
    [Arguments]  ${firstname}  ${lastname}  ${primaryMobileNo}   ${email}    ${sub_sector}  ${commonPassword}
    ${data}=   Branch User Creation for SP  ${firstname}  ${lastname}  ${primaryMobileNo}  ${email}   ${sub_sector}  ${commonPassword}
    ${data}=   json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /provider/corp/createProvider     data=${data}  expected_status=any
    RETURN  ${resp}

Get Branch SP By Id
    [Arguments]   ${branch_id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/branch/${branch_id}/accounts  expected_status=any
    RETURN  ${resp}

Manage Branch SP 
    [Arguments]   ${branch_id}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/branch/manage/${branch_id}  expected_status=any
    RETURN  ${resp}

Create Consumer Notification Settings
    [Arguments]  ${resource_type}  ${event_type}  ${email}  ${sms}  ${push_notf}  ${common_msg}  ${persons_ahead}
    ${data}=  Create Dictionary  resourceType=${resource_type}  eventType=${event_type}  email=${email}  sms=${sms}  pushNotification=${push_notf}  commonMessage=${common_msg}  personsAhead=${persons_ahead}
    ${data}=   json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /provider/consumerNotification/settings   data=${data}  expected_status=any
    RETURN  ${resp}

Get Consumer Notification Settings
    Check and Create YNW Session
	${resp}=  GET On Session   ynw  /provider/consumerNotification/settings  expected_status=any 
	RETURN  ${resp}

Update Consumer Notification Settings
    [Arguments]  ${resource_type}  ${event_type}  ${email}  ${sms}  ${push_notf}  ${common_msg}  ${persons_ahead}
    ${data}=  Create Dictionary  resourceType=${resource_type}  eventType=${event_type}  email=${email}  sms=${sms}  pushNotification=${push_notf}  commonMessage=${common_msg}  personsAhead=${persons_ahead}
    ${data}=   json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    PUT On Session   ynw    /provider/consumerNotification/settings   data=${data}  expected_status=any
    RETURN  ${resp}

Consumer Mass Communication
    [Arguments]  ${email}  ${sms}  ${push_notf}  ${msg}  @{vargs}
    ${input}=  Create Dictionary  email=${email}  sms=${sms}  pushNotification=${push_notf}
    ${data}=  Create Dictionary  medium=${input}  communicationMessage=${msg}  uuid=${vargs}
    ${data}=   json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /provider/consumerNotification/settings/consumerMassCommunication  expected_status=any   data=${data}  expected_status=any
    RETURN  ${resp}
