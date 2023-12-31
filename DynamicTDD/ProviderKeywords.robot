*** Settings ***
Library           Collections
Library           String
Library           OperatingSystem
Library           json
Library           DateTime
Library           db.py
Resource          Keywords.robot
Library	          Imageupload.py
Library           FakerLibrary

# *** Variables ***
# @{emptylist}


*** Keywords ***

Get BusinessDomainsConf
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /ynwConf/businessDomains   expected_status=any
    [Return]  ${resp}

Get Licensable Packages
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/license/packages  expected_status=any
    [Return]  ${resp}

User Creation
    [Arguments]  ${firstname}  ${lastname}  ${yemail}  ${sector}  ${sub_sector}  ${ph}  ${licPkgId}  ${countryCode}=91
    ${usp}=    Create Dictionary   firstName=${firstname}  lastName=${lastname}  email=${yemail}  primaryMobileNo=${ph}  countryCode=${countryCode}
    ${data}=  Create Dictionary  userProfile=${usp}  sector=${sector}  subSector=${sub_sector}  licPkgId=${licPkgId}
    [Return]  ${data}

Account SignUp
    [Arguments]  ${firstname}  ${lastname}  ${yemail}  ${sector}  ${sub_sector}  ${ph}  ${licPkgId}   ${countryCode}=91
    ${data}=   User Creation  ${firstname}  ${lastname}  ${yemail}  ${sector}  ${sub_sector}  ${ph}  ${licPkgId}  countryCode=${countryCode}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /provider    data=${data}  expected_status=any  
    [Return]  ${resp}

Claim SignUp
    [Arguments]  ${firstname}  ${lastname}  ${yemail}  ${sector}  ${sub_sector}  ${ph}  ${licPkgId}  ${acid}
    ${data}=   User Creation  ${firstname}  ${lastname}  ${yemail}  ${sector}  ${sub_sector}  ${ph}  ${licPkgId}
    Set To Dictionary  ${data}  accountId=${acid}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /provider    data=${data}  expected_status=any
    [Return]  ${resp}


Account Activation
    [Arguments]  ${email}  ${purpose}
    Check And Create YNW Session
    ${key}=   verify accnt  ${email}  ${purpose}
    ${resp_val}=  POST On Session   ynw  /provider/${key}/verify  expected_status=any
    [Return]  ${resp_val}

Account Set Credential
    [Arguments]  ${email}  ${password}  ${purpose}  ${countryCode}=91
    ${auth}=     Create Dictionary   password=${password}  countryCode=${countryCode}
    ${key}=   verify accnt  ${email}  ${purpose}
    ${apple}=    json.dumps    ${auth}
    ${resp}=    PUT On Session    ynw    /provider/${key}/activate    data=${apple}    expected_status=any
    [Return]  ${resp}

ProviderLogin
    [Arguments]    ${usname}  ${passwrd}   ${countryCode}=91
    ${log}=  Login  ${usname}  ${passwrd}   countryCode=${countryCode}
    ${resp}=    POST On Session    ynw    /provider/login    data=${log}  expected_status=any
    [Return]  ${resp}

ProviderLogout
    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw  /provider/login  expected_status=any
    [Return]  ${resp}       

    
Phone Numbers
    [Arguments]  ${lbl}  ${res}  ${inst}  ${perm}
    ${ph}=  Create Dictionary  label=${lbl}  resource=${res}  instance=${inst}  permission=${perm}
    [Return]  ${ph}

Emails
    [Arguments]  ${e_lbl}  ${e_res}  ${e_inst}  ${e_perm}
    ${em}=  Create Dictionary  label=${e_lbl}  resource=${e_res}  instance=${e_inst}  permission=${e_perm}
    [Return]  ${em} 

Timeslot
    [Arguments]  ${sTime}  ${eTime}
    ${time}=  Create Dictionary  sTime=${sTime}  eTime=${eTime}
    [Return]  ${time}
 
    
Business Profile
    [Arguments]  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${pin}  ${adds}  ${ph1}  ${ph2}  ${email1}
    ${bs}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}
    ${bs}=  Create List  ${bs}
    ${bs}=  Create Dictionary  timespec=${bs}
    ${b_loc}=  Create Dictionary  place=${place}  longitude=${longi}  lattitude=${latti}  googleMapUrl=${g_url}  parkingType=${pt}  open24hours=${oh}   bSchedule=${bs}  pinCode=${pin}  address=${adds}
    ${ph_nos}=  Create List  ${ph1}  ${ph2}
    ${emails}=  Create List  ${email1}
    ${data}=  Create Dictionary  businessName=${bName}  businessDesc=${bDesc}  shortName=${shname}  baseLocation=${b_loc}  phoneNumbers=${ph_nos}  emails=${emails}
    ${data}=  json.dumps  ${data}
    Log  ${data}
    [Return]  ${data}

Create Business Profile
    [Arguments]  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${pin}  ${adds}  ${ph1}  ${ph2}  ${email1}
    ${data}=  Business Profile  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${pin}  ${adds}  ${ph1}  ${ph2}  ${email1}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  ynw  provider/bProfile  data=${data}  expected_status=any
    [Return]  ${resp}

TimeSpec
    [Arguments]  ${rectype}  ${rint}  ${startDate}  ${endDate}  ${noocc}  ${sTime}  ${eTime} 
    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noocc}
    ${time}=  Create Dictionary  sTime=${sTime}  eTime=${eTime}
    ${timeslot}=  Create List  ${time}
    ${ts}=  Create Dictionary  recurringType=${rectype}  repeatIntervals=${rint}  startDate=${startDate}  terminator=${terminator}  timeSlots=${timeslot}
    [Return]  ${ts}

Create Business Profile without details
    [Arguments]  ${bName}  ${bDesc}  ${shname}   ${ph1}   ${email1}
    # ${ph_nos}=  Create List  ${ph1}  ${ph2}
    # ${emails}=  Create List  ${email1}
    ${data}=  Create Dictionary  businessName=${bName}  businessDesc=${bDesc}  shortName=${shname}  baseLocation=${None}  phoneNumbers=${ph1}  emails=${email1}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  provider/bProfile  data=${data}  expected_status=any
    [Return]  ${resp}

Create Business Profile without schedule
    [Arguments]  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pt}  ${oh}  ${pin}  ${adds}   ${ph1}  ${ph2}  ${email1}  ${lid}
    ${ph_nos}=  Create List  ${ph1}  ${ph2}
    ${emails}=  Create List  ${email1}
    ${b_loc}=  Create Dictionary   id=${lid}  place=${place}  longitude=${longi}  lattitude=${latti}  googleMapUrl=${g_url}  parkingType=${pt}  open24hours=${oh}   bSchedule=${None}  pinCode=${pin}  address=${adds}
    ${data}=  Create Dictionary  businessName=${bName}  businessDesc=${bDesc}  shortName=${shname}  baseLocation=${b_loc}  phoneNumbers=${ph_nos}  emails=${emails}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  ynw  provider/bProfile  data=${data}  expected_status=any
    [Return]  ${resp}
    
Business Profile with schedule only
    [Arguments]  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${pin}  ${adds}  ${lid}
    ${bs}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}
    ${bs}=  Create List  ${bs}
    ${bs}=  Create Dictionary  timespec=${bs}
    ${b_loc}=  Create Dictionary  id=${lid}  place=${place}  longitude=${longi}  lattitude=${latti}  googleMapUrl=${g_url}  bSchedule=${bs}  pinCode=${pin}  address=${adds}
    ${data}=  Create Dictionary  businessName=${bName}  businessDesc=${bDesc}  shortName=${shname}  baseLocation=${b_loc}
    ${data}=  json.dumps  ${data}
    [Return]  ${data} 
    
Create Business Profile with schedule only
    [Arguments]  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${pin}  ${adds}  ${lid}
    ${data}=  Business Profile with schedule only  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${pin}  ${adds}  ${lid}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  ynw  provider/bProfile  data=${data}  expected_status=any
    [Return]  ${resp}


Create Business Profile with location only
    [Arguments]  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pt}  ${oh}  ${pin}  ${adds}   
    ${b_loc}=  Create Dictionary  place=${place}  longitude=${longi}  lattitude=${latti}  googleMapUrl=${g_url}  parkingType=${pt}  open24hours=${oh}   bSchedule=${None}  pinCode=${pin}  address=${adds}
    ${data}=  Create Dictionary  businessName=${bName}  businessDesc=${bDesc}  shortName=${shname}  baseLocation=${b_loc}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  ynw  provider/bProfile  data=${data}  expected_status=any
    [Return]  ${resp}


Update Business Profile with location only
    [Arguments]  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pt}  ${oh}  ${pin}  ${adds}   
    ${b_loc}=  Create Dictionary  place=${place}  longitude=${longi}  lattitude=${latti}  googleMapUrl=${g_url}  parkingType=${pt}  open24hours=${oh}   bSchedule=${None}  pinCode=${pin}  address=${adds}
    ${data}=  Create Dictionary  businessName=${bName}  businessDesc=${bDesc}  shortName=${shname}  baseLocation=${b_loc}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  provider/bProfile  data=${data}  expected_status=any
    [Return]  ${resp}


Business Profile with schedule
    [Arguments]  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${pin}  ${adds}  ${ph1}  ${ph2}  ${email1}  ${lid}   &{kwargs}
    ${bs}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}
    ${bs}=  Create List  ${bs}
    ${bs}=  Create Dictionary  timespec=${bs}
    ${b_loc}=  Create Dictionary  place=${place}  longitude=${longi}  lattitude=${latti}  googleMapUrl=${g_url}  parkingType=${pt}  open24hours=${oh}   bSchedule=${bs}  pinCode=${pin}  address=${adds}  id=${lid}
    ${ph_nos}=  Create List  ${ph1}  ${ph2}
    ${emails}=  Create List  ${email1}
    ${data}=  Create Dictionary  businessName=${bName}  businessDesc=${bDesc}  shortName=${shname}  baseLocation=${b_loc}  phoneNumbers=${ph_nos}  emails=${emails}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    [Return]  ${data}

Update Business Profile with schedule
    [Arguments]  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${pin}  ${adds}  ${ph1}  ${ph2}  ${email1}  ${lid}  &{kwargs}
    ${data}=  Business Profile with schedule  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${pin}  ${adds}  ${ph1}  ${ph2}  ${email1}  ${lid}  &{kwargs}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bProfile   data=${data}  expected_status=any
    [Return]  ${resp}

Update Business Profile without schedule
    [Arguments]  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pt}  ${oh}  ${pin}  ${adds}   ${ph1}  ${ph2}  ${email1}  ${lid}
    ${ph_nos}=  Create List  ${ph1}  ${ph2}
    ${emails}=  Create List  ${email1}
    ${b_loc}=  Create Dictionary  place=${place}  longitude=${longi}  lattitude=${latti}  googleMapUrl=${g_url}  parkingType=${pt}  open24hours=${oh}   bSchedule=${None}  pinCode=${pin}  address=${adds}   id=${lid}
    ${data}=  Create Dictionary  businessName=${bName}  businessDesc=${bDesc}  shortName=${shname}  baseLocation=${b_loc}  phoneNumbers=${ph_nos}  emails=${emails}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bProfile   data=${data}  expected_status=any
    [Return]  ${resp}

Update Business Profile without details
    [Arguments]  ${bName}  ${bDesc}  ${shname}   ${ph1}   ${email1}
    # ${ph_nos}=  Create List  ${ph1}  ${ph2}
    # ${emails}=  Create List  ${email1}
    ${data}=  Create Dictionary  businessName=${bName}  businessDesc=${bDesc}  shortName=${shname}  baseLocation=${None}  phoneNumbers=${ph1}  emails=${email1}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bProfile   data=${data}  expected_status=any
    [Return]  ${resp}

    
Update Business Profile without phone and email
    [Arguments]  ${bName}  ${bDesc}  ${shname}
    ${data}=  Create Dictionary  businessName=${bName}  businessDesc=${bDesc}  shortName=${shname}  baseLocation=${None}  phoneNumbers=${None}  emails=${None}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bProfile   data=${data}  expected_status=any
    [Return]  ${resp}

Get Business Profile
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/bProfile  expected_status=any
    [Return]  ${resp}
    
Update Domain And SubDomain
    [Arguments]   ${dom}  ${subdom}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  /provider/${dom}/${subdom}  expected_status=any
    [Return]  ${resp}    

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
    [Return]  ${resp} 

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
    [Return]  ${resp.json()}

Check Location Exists
    [Arguments]   ${city}
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${loc_length}=  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${loc_length}
        IF  '${resp.json()[${i}]['place']}' == '${city}'
            Return From Keyword    True
        ELSE
            Return From Keyword    False
        END
    END


Create Sample Item
   [Arguments]   ${displayName}   ${itemName}  ${itemCode}  ${price}  ${taxable}      
   ${shortDesc}=  FakerLibrary.Sentence   nb_words=2    
   ${itemDesc}=  FakerLibrary.Sentence   nb_words=3    
   ${itemNameInLocal}=  FakerLibrary.Sentence   nb_words=2  
   ${promoPrice}=   Evaluate    random.uniform(0, ${price})   
   ${promotionalPrcnt}=   Evaluate    random.uniform(0.0,80)    
   ${note}=  FakerLibrary.Sentence    
#    ${stockAvailable}    Random Element    ['True','False']    
#    ${showOnLandingpage}    Random Element    ['True','False']
   ${showPromoPrice}    Random Element    ['True','False']   
   ${promoLabel}=   FakerLibrary.word 
   ${resp}=    Create Order Item    ${displayName}    ${shortDesc}    ${itemDesc}    ${price}    ${taxable}    ${itemName}    ${itemNameInLocal}    ${promotionalPriceType[1]}    ${promoPrice}    ${promotionalPrcnt}    ${note}    ${bool[1]}    ${bool[1]}    ${itemCode}    ${showPromoPrice}    ${promotionLabelType[2]}    ${promoLabel}   
   Log  ${resp.content}
   Should Be Equal As Strings  ${resp.status_code}  200
   [Return]  ${resp}


Create Location without schedule
    [Arguments]  ${place}  ${longi}  ${latti}  ${g_url}  ${pin}  ${add}  ${pt}  ${oh}
    ${data}=  Create Dictionary  place=${place}  longitude=${longi}  lattitude=${latti}  googleMapUrl=${g_url}  pinCode=${pin}  address=${add}  parkingType=${pt}  open24hours=${oh}  bSchedule=${None}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/locations  data=${data}  expected_status=any
    [Return]  ${resp} 
    
Get Location ById
    [Arguments]  ${id}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/locations/${id}  expected_status=any
    [Return]  ${resp}

Get Locations
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/locations  expected_status=any
    [Return]  ${resp}

Update Location with schedule
    [Arguments]   ${place}  ${longi}  ${latti}  ${g_url}  ${pin}  ${add}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${lid}
    ${bs}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}
    ${bs}=  Create List  ${bs}
    ${bs}=  Create Dictionary  timespec=${bs}
    ${data}=  Create Dictionary  place=${place}  longitude=${longi}  lattitude=${latti}  googleMapUrl=${g_url}  pinCode=${pin}  address=${add}  parkingType=${pt}  open24hours=${oh}  bSchedule=${bs}  id=${lid}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/locations  data=${data}  expected_status=any
    [Return]  ${resp}

Update Location
    [Arguments]   ${place}  ${longi}  ${latti}  ${g_url}  ${pin}  ${add}  ${pt}  ${oh}  ${lid}
    ${data}=  Create Dictionary  place=${place}  longitude=${longi}  lattitude=${latti}  googleMapUrl=${g_url}  pinCode=${pin}  address=${add}  parkingType=${pt}  open24hours=${oh}  id=${lid}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/locations  data=${data}  expected_status=any
    [Return]  ${resp}
    
UpdateBaseLocation
    [Arguments]   ${lid}
    ${data}=  Create Dictionary  locationId=${lid}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bProfile/baseLocation/${lid}  data=${data}  expected_status=any
    [Return]  ${resp}

Disable Location
   [Arguments]   ${id}
   Check And Create YNW Session
   ${resp}=    DELETE On Session    ynw  /provider/locations/${id}/disable  expected_status=any
   [Return]  ${resp}
    
Enable Location
   [Arguments]   ${id}
   Check And Create YNW Session
   ${resp}=    PUT On Session    ynw  /provider/locations/${id}/enable  expected_status=any
   [Return]  ${resp}

Get Location Suggester
   [Arguments]  &{kwargs}
   Check And Create YNW Session
   ${resp}=    GET On Session    ynw   /provider/search/suggester/location  params=${kwargs}  expected_status=any
   [Return]  ${resp}


Create Holiday For User
    [Arguments]  ${day}  ${desc}  ${stime}  ${etime}  ${u_id}
    ${user_id}=  Create Dictionary  id=${u_id}
    ${nwh}=  Create Dictionary  sTime=${stime}  eTime=${etime}
    ${data}=  Create Dictionary  startDay=${day}  description=${desc}  nonWorkingHours=${nwh}  provider=${user_id}
    ${data}=  json.dumps  ${data}
    ${resp}=  POST On Session  ynw  /provider/settings/nonBusinessDays  data=${data}  expected_status=any
    [Return]  ${resp}


Get Search Status
   Check And Create YNW Session
   ${resp}=    GET On Session    ynw   /provider/search  expected_status=any
   [Return]  ${resp}

Enable Search Data
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/search/ENABLE  expected_status=any
    [Return]  ${resp}

Disable Search Data
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/search/DISABLE  expected_status=any
    [Return]  ${resp}

Create SocialMedia
    [Arguments]  ${resource}  ${value}
    ${data}=  Create Dictionary  resource=${resource}  value=${value}  
    [Return]  ${data}
       

Update Social Media Info
    [Arguments]  @{data}    
    ${data}=  Create Dictionary  socialMedia=${data}                                                                                                                                            
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session 
    ${resp}=  PUT On Session  ynw  /provider/bProfile/socialMedia  data=${data}  expected_status=any
    [Return]  ${resp}


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
    [Return]  ${data}


Create Queue
   [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  @{vargs}
   ${data}=  Queue  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  @{vargs}
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw  /provider/waitlist/queues  data=${data}  expected_status=any
   [Return]  ${resp}


Queue For User
   [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  ${u_id}  @{vargs}
   ${bs}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}
   ${user_id}=  Create Dictionary  id=${u_id}
   ${location}=  Create Dictionary  id=${loc}
   ${len}=  Get Length  ${vargs}
   ${service}=  Create Dictionary  id=${vargs[0]}
   ${services}=  Create List  ${service}
   FOR    ${index}    IN RANGE  1  ${len}
    	${service}=  Create Dictionary  id=${vargs[${index}]} 
        Append To List  ${services}  ${service}
    END
   ${data}=  Create Dictionary  name=${name}  queueSchedule=${bs}  parallelServing=${parallel}  capacity=${capacity}  location=${location}  provider=${user_id}  services=${services}
   [Return]  ${data}


Create Queue For User
   [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  ${u_id}  @{vargs}
   ${data}=  Queue For User  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  ${u_id}  @{vargs}
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw  /provider/waitlist/queues  data=${data}  expected_status=any
   [Return]  ${resp}

   
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
    IF   '${resp.content}' == '${emptylist}' or '${resp.json()[0]['serviceType']}' == '${service_type[0]}'
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
    ${eTime}=  add_timezone_time  ${tz}  2  00  
    ${queue1}=    FakerLibrary.Word
    ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  5  ${lid}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${data}=  Create Dictionary   queue_id=${resp.json()}   service_id=${s_id}   location_id=${lid}    service_name=${SERVICE1}
    Log  ${data}
    [Return]   ${data}


Sample Queue 
    [Arguments]  ${lid}   @{vargs} 

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${list}=  Create List  1  2  3  4  5  6  7
    # ${DAY1}=  get_date
    # ${DAY2}=  db.add_timezone_date  ${tz}  10 
    # ${Time}=  db.get_time_by_timezone   ${tz}
    ${DAY1}=  get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10
    ${delta}=  FakerLibrary.Random Int  min=20  max=60
    ${Time}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  add_two   ${Time}  ${delta}
    ${eTime}=  add_two   ${sTime}  ${delta}
    ${capacity}=  Random Int  min=20   max=40
    ${parallel}=  Random Int   min=2   max=4
    ${queue1}=    FakerLibrary.Word
    ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  @{vargs}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    [Return]   ${resp}

    
Queue With TokenStart
   [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  ${token_start}  @{vargs}
   ${bs}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}
   ${location}=  Create Dictionary  id=${loc}
   ${len}=  Get Length  ${vargs}
   ${service}=  Create Dictionary  id=${vargs[0]}
   ${services}=  Create List  ${service}
   FOR    ${index}    IN RANGE  1  ${len}
    	${service}=  Create Dictionary  id=${vargs[${index}]} 
        Append To List  ${services}  ${service}
   END
   ${data}=  Create Dictionary  name=${name}  queueSchedule=${bs}  parallelServing=${parallel}  capacity=${capacity}  location=${location}  tokenStarts=${token_start}  services=${services}
   [Return]  ${data}

   
Create Queue With TokenStart
   [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  ${token_start}  @{vargs}
   ${data}=  Queue With TokenStart  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  ${token_start}  @{vargs}
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw  /provider/waitlist/queues  data=${data}  expected_status=any
   [Return]  ${resp}


Queue without Service
   [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}
   ${bs}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}
   ${location}=  Create Dictionary  id=${loc}
   ${data}=  Create Dictionary  name=${name}  queueSchedule=${bs}  parallelServing=${parallel}  capacity=${capacity}  location=${location} 
   [Return]  ${data}


Create Queue without Service
   [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}
   ${data}=  Queue without Service  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw  /provider/waitlist/queues  data=${data}  expected_status=any
   [Return]  ${resp}


Queue without Service For User
   [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  ${u_id}
   ${bs}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}
   ${location}=  Create Dictionary  id=${loc}
   ${user_id}=  Create Dictionary  id=${u_id}
   ${data}=  Create Dictionary  name=${name}  queueSchedule=${bs}  parallelServing=${parallel}  capacity=${capacity}  location=${location}  provider=${user_id}  services=${None}
   [Return]  ${data}


Create Queue without Service For User
   [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  ${u_id}
   ${data}=  Queue without Service For User  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  ${u_id}
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw  /provider/waitlist/queues  data=${data}  expected_status=any
   [Return]  ${resp}


Update Queue
    [Arguments]  ${qid}  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  @{vargs}
    ${data}=  Queue  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  @{vargs}
    Set To Dictionary  ${data}  id=${qid}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/waitlist/queues  data=${data}  expected_status=any
    [Return]  ${resp}

    
Update Queue For User
    [Arguments]  ${qid}  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}   ${u_id}   @{vargs}
    ${data}=  Queue For User  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}   ${u_id}   @{vargs}
    Set To Dictionary  ${data}  id=${qid}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/waitlist/queues  data=${data}  expected_status=any
    [Return]  ${resp}
    

Update Queue without service
    [Arguments]  ${qid}  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}
    ${data}=  Queue without Service  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}
    Set To Dictionary  ${data}  id=${qid}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/waitlist/queues  data=${data}  expected_status=any
    [Return]  ${resp} 

   
Get Queues
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/queues  expected_status=any
    [Return]  ${resp}

Get Queue ById
    [Arguments]  ${id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/queues/${id}  expected_status=any
    [Return]  ${resp}
    
Get Queues Counts
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/queues/count  expected_status=any
    [Return]  ${resp}

Enable Queue
    [Arguments]  ${qid}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/waitlist/queues/${qid}/enable  expected_status=any
    [Return]  ${resp}

Disable Queue
    [Arguments]  ${qid}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/waitlist/queues/${qid}/disable  expected_status=any
    [Return]  ${resp}

Get Queue Location
    [Arguments]  ${locationId}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/queues/${locationId}/location  expected_status=any
    [Return]  ${resp}
    
Get Queue Location and Date
    [Arguments]  ${locationId}  ${date}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/queues/${locationId}/location/${date}  expected_status=any
    [Return]  ${resp}    

View Waitlist Settings
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/settings/waitlistMgr  expected_status=any
    [Return]  ${resp}

Update Waitlist Settings
    [Arguments]   ${calculationmode}   ${TrnArndTime}  ${futuredatewaitlist}  ${showTokenId}  ${onlineChckin}  ${notification}  ${maxPartySize}
    ${data}=  Create Dictionary  calculationMode=${calculationmode}  trnArndTime=${TrnArndTime}  futureDateWaitlist=${futuredatewaitlist}  showTokenId=${showTokenId}  onlineCheckIns=${onlineChckin}  sendNotification=${notification}  maxPartySize=${maxPartySize}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/waitlistMgr   data=${data}  expected_status=any
    [Return]  ${resp}

Send Verify Login
    [Arguments]  ${loginid}  ${countryCode}=91
    Check And Create YNW Session
    ${body}=     Create Dictionary   countryCode=${countryCode}
    ${data}=    json.dumps    ${body}
    ${resp}=  POST On Session    ynw  /provider/login/verifyLogin/${loginid}   params=${data}  expected_status=any
    [Return]  ${resp}

Verify Login
    [Arguments]  ${loginid}  ${purpose}  ${countryCode}=91
    Check And Create YNW Session
    ${auth}=     Create Dictionary   loginId=${loginid}  countryCode=${countryCode}
    ${key}=   verify accnt  ${loginid}  ${purpose}
    ${data}=    json.dumps    ${auth}
    ${resp}=    PUT On Session    ynw    /provider/login/${key}/verifyLogin    data=${data}  expected_status=any
    [Return]  ${resp}

Get Provider By Id
    [Arguments]  ${email}
    Check And Create YNW Session
    ${id}=  get_id  ${email}
    ${resp}=    GET On Session    ynw   /provider/profile/${id}  expected_status=any
    [Return]  ${resp}

Get Consumer By Account
    [Arguments]  &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /consumer  params=${kwargs}  expected_status=any
    [Return]  ${resp}
    
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
    ${resp}=    PUT On Session    ynw   /provider/login/chpwd    data=${apple}    expected_status=any
    [Return]  ${resp}

SendProviderResetMail
   [Arguments]    ${email}  ${countryCode}=91
   Create Session    ynw    ${BASE_URL}
#    ${body}=     Create Dictionary   countryCode=${countryCode}
   ${data}=    json.dumps    ${countryCode}
   ${resp}=  POST On Session  ynw     /provider/login/reset/${email}   data=${data}  expected_status=any
   [Return]  ${resp}  


ResetProviderPassword
    [Arguments]    ${email}  ${pswd}  ${purpose}  ${countryCode}=91
    ${key}=  verify accnt  ${email}   ${purpose}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw    /provider/login/reset/${key}/validate  expected_status=any
    ${login}=    Create Dictionary  password=${pswd}  countryCode=${countryCode}
    ${log}=    json.dumps    ${login}
    ${respk}=  PUT On Session  ynw  /provider/login/reset/${key}  data=${log}  expected_status=any  headers=${headers}
    [Return]  ${resp}  ${respk}

Verify OTP
    [Arguments]  ${email}  ${purpose}
    ${key}=  verify accnt  ${email}   ${purpose}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw    /provider/login/reset/${key}/validate  expected_status=any
    [Return]  ${resp}


AddFamilyMemberByProvider
    [Arguments]  ${id}  ${firstname}  ${lastname}  ${dob}  ${gender}
    Check And Create YNW Session
    ${data}=  Create Dictionary  parent=${id}  firstName=${firstname}  lastName=${lastname}  dob=${dob}  gender=${gender} 
    ${data}=    json.dumps    ${data}
    ${resp}=  POST On Session   ynw   /provider/customers/familyMember   data=${data}  expected_status=any
    [Return]  ${resp}

AddFamilyMemberByProviderWithPhoneNo
    [Arguments]  ${id}  ${firstname}  ${lastname}  ${dob}  ${gender}  ${PhoneNo}
    Check And Create YNW Session
    ${data}=  Create Dictionary  parent=${id}  firstName=${firstname}  lastName=${lastname}  dob=${dob}  gender=${gender}  primaryMobileNo=${PhoneNo}
    ${data}=    json.dumps    ${data}
    ${resp}=  POST On Session   ynw   /provider/customers/familyMember   data=${data}  expected_status=any
    [Return]  ${resp}

ListFamilyMemberByProvider
    [Arguments]   ${id}
    Check And Create YNW Session
    ${resp}=  GET On Session   ynw   /provider/customers/familyMember/${id}  expected_status=any
    [Return]  ${resp}

Add addon 
    [Arguments]    ${addonId}
    Check And Create YNW Session
    ${resp}=   POST On Session   ynw   /provider/license/addon/${addonId}  expected_status=any
    [Return]  ${resp}

Remove addon
    [Arguments]    ${addonId}
    Check And Create YNW Session
    ${resp}=   DELETE On Session   ynw   /provider/license/addon/${addonId}  expected_status=any
    [Return]  ${resp}

Get Active License 
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/license  expected_status=any
    [Return]  ${resp}

Get license auditlog
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/license/auditlog  expected_status=any
    [Return]  ${resp}
   
   
Get addons auditlog
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/license/addon/auditlog  expected_status=any
    [Return]  ${resp}

Get Addons Metadata
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/license/addonmetadata  expected_status=any
    [Return]  ${resp}

Get upgradable license 
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/license/upgradablePackages  expected_status=any
    [Return]  ${resp}

Get upgradable addons
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/license/upgradableAddons  expected_status=any
    [Return]  ${resp}

Change License Package 
    [Arguments]    ${licPkgId}
    Check And Create YNW Session
    ${resp}=   PUT On Session   ynw   /provider/license/${licPkgId}  expected_status=any
    [Return]  ${resp}  

Get SubscriptionTypes 
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  provider/license/getSubscriptionTypes  expected_status=any
    [Return]  ${resp}

Get Subscription
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/license/getSubscription  expected_status=any
    [Return]  ${resp}
    
Change Bill Cycle
    [Arguments]    ${cycle}
    Check And Create YNW Session
    ${resp}=   PUT On Session   ynw   /provider/license/billing/${cycle}  expected_status=any
    [Return]  ${resp}
    
Add adword
   [Arguments]    ${adwordName}
   ${data}=  Create Dictionary  name=${adwordName}
   ${data}=    json.dumps    ${data}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw  /provider/license/adwords/create  data=${data}  expected_status=any
   [Return]  ${resp}
   
Get adword
   Check And Create YNW Session
   ${resp}=   GET On Session  ynw  /provider/license/adwords  expected_status=any
   [Return]  ${resp}
   
Delete adword
    [Arguments]    ${adwordId}
    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw  provider/license/adwords/${adwordId}  expected_status=any
    [Return]  ${resp}

Customer Creation
    [Arguments]  ${firstname}  ${lastname}   ${primaryNo}   ${ydob}  ${ygender}  ${yemail}  ${jid}  ${countryCode}=91
    ${up}=  Create Dictionary  firstName=${firstname}  lastName=${lastname}  address=${EMPTY}  primaryMobileNo=${primaryNo}  dob=${ydob}  gender=${ygender}  email=${yemail}  countryCode=${countryCode}   jaldeeId=${jid}
    ${data}=  Create Dictionary  userProfile=${up}
    ${data}=  json.dumps  ${data}
    [Return]  ${data}
    
Customer Creation after updation
    [Arguments]  ${firstname}  ${lastname}   ${primaryNo}   ${ydob}  ${ygender}  ${yemail}  ${c_id}  ${jid}  ${address}   ${countryCode}=91
    ${up}=  Create Dictionary  id=${c_id}  firstName=${firstname}  lastName=${lastname}  address=${address}  phoneNo=${primaryNo}  dob=${ydob}  gender=${ygender}  email=${yemail}  countryCode=${countryCode}   jaldeeId=${jid}
    ${data}=  Create Dictionary  userProfile=${up}
    ${data}=  json.dumps  ${data}
    [Return]  ${data}


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
    [Return]  ${resp}

AddCustomer with email
    [Arguments]  ${firstname}  ${lastname}  ${address}  ${yemail}  ${ygender}  ${ydob}  ${primaryNo}   ${jid}  ${countryCode}=91  
    Check And Create YNW Session
    ${data}=  Create Dictionary  firstName=${firstname}  lastName=${lastname}  address=${address}  email=${yemail}  gender=${ygender}  dob=${ydob}  phoneNo=${primaryNo}  countryCode=${countryCode}  jaldeeId=${jid}
    ${data}=  json.dumps  ${data}
    ${resp}=  POST On Session  ynw  /provider/customers  data=${data}  expected_status=any
    [Return]  ${resp}


AddCustomer without email
    [Arguments]  ${firstname}  ${lastname}  ${address}  ${ygender}  ${ydob}  ${primaryNo}   ${jid}   ${countryCode}=91   
    Check And Create YNW Session
    ${data}=  Create Dictionary  firstName=${firstname}  lastName=${lastname}  address=${address}   gender=${ygender}  dob=${ydob}  phoneNo=${primaryNo}  countryCode=${countryCode}  jaldeeId=${jid}
    ${data}=  json.dumps  ${data}
    ${resp}=  POST On Session  ynw  /provider/customers  data=${data}  expected_status=any
    [Return]  ${resp}

UpdateCustomer
	[Arguments]  ${firstname}  ${lastname}  ${primaryNo}  ${ydob}  ${ygender}  ${yemail}  ${c_id}   ${jid}  ${address}=${EMPTY}  &{kwargs}
	Check And Create YNW Session
    ${items}=  Get Dictionary items  ${kwargs}
    ${data}=  Customer Creation after updation  ${firstname}  ${lastname}  ${primaryNo}  ${ydob}  ${ygender}  ${yemail}  ${c_id}  ${jid}  ${address}
    ${data}=  json.dumps  ${data}
    FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${resp}=  PUT On Session  ynw  /provider/customers  data=${data}  expected_status=any
	[Return]  ${resp}

UpdateCustomer with email
    [Arguments]  ${c_id}   ${firstname}  ${lastname}  ${address}  ${yemail}  ${ygender}  ${ydob}  ${primaryNo}   ${jid}   ${countryCode}=91  &{kwargs}
    Check And Create YNW Session
    ${items}=  Get Dictionary items  ${kwargs}
    ${data}=  Create Dictionary  id=${c_id}  firstName=${firstname}  lastName=${lastname}  address=${address}  email=${yemail}  gender=${ygender}  dob=${ydob}  phoneNo=${primaryNo}  countryCode=${countryCode}  jaldeeId=${jid}
    ${data}=  json.dumps  ${data}
    FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${resp}=  PUT On Session  ynw  /provider/customers  data=${data}  expected_status=any
    [Return]  ${resp}

UpdateCustomer without email
    [Arguments]  ${c_id}   ${firstname}  ${lastname}  ${address}   ${ygender}  ${ydob}  ${primaryNo}   ${jid}   ${countryCode}=91  
    Check And Create YNW Session
    ${data}=  Create Dictionary  id=${c_id}  firstName=${firstname}  lastName=${lastname}  address=${address}  gender=${ygender}  dob=${ydob}  phoneNo=${primaryNo}  countryCode=${countryCode}  jaldeeId=${jid}
    ${data}=  json.dumps  ${data}
    ${resp}=  PUT On Session  ynw  /provider/customers  data=${data}  expected_status=any
    [Return]  ${resp}


Update Customer Details
    [Arguments]  ${c_id}   &{kwargs}
    ${items}=  Get Dictionary items  ${kwargs}
    ${data}=  Create Dictionary  id=${c_id}
    FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    Log  ${data}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/customers  data=${data}  expected_status=any
    [Return]  ${resp}


GetCustomer
    [Arguments]  &{param} 
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /provider/customers  params=${param}  expected_status=any
    [Return]  ${resp}

GetCustomer ById  
	[Arguments]  ${customerId}   
	Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /provider/customers/${customerId}   expected_status=any 
    [Return]  ${resp}

DeleteCustomer
	[Arguments]  ${customerId}  
	Check And Create YNW Session
    ${resp}=   DELETE On Session  ynw  /provider/customers/${customerId}   expected_status=any
    [Return]  ${resp}

ActivateCustomer
	[Arguments]  ${customerId}
	Check And Create YNW Session
    ${resp}=   PUT On Session  ynw  /provider/customers/activate/${customerId}  expected_status=any
    [Return]  ${resp}

Get consumercount
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/customers/count  params=${param}  expected_status=any
    [Return]  ${resp}

Update Account Payment Settings
    [Arguments]   ${onlinePayment}   ${payTm}   ${dcOrCcOrNb}   ${payTmLinkedPhoneNumber}  ${panCardNumber}   ${bankAccountNumber}   ${bankName}   ${ifscCode}   ${nameOnPanCard}   ${accountHolderName}  ${branchCity}   ${businessFilingStatus}   ${accountType}
    ${data}=   Create Dictionary       onlinePayment=${onlinePayment}   payTm=${payTm}   dcOrCcOrNb=${dcOrCcOrNb}   payTmLinkedPhoneNumber=${payTmLinkedPhoneNumber}  panCardNumber=${panCardNumber}   bankAccountNumber=${bankAccountNumber}   bankName=${bankName}   ifscCode=${ifscCode}   nameOnPanCard=${nameOnPanCard}   accountHolderName=${accountHolderName}  branchCity=${branchCity}   businessFilingStatus=${businessFilingStatus}   accountType=${accountType}
    ${data}=   json.dumps   ${data}
    Check And Create YNW Session
    ${resp}=   PUT On Session  ynw  /provider/payment/settings   data=${data}  expected_status=any
    [Return]  ${resp}
    
Get Account Payment Settings
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /provider/payment/settings   expected_status=any
    [Return]  ${resp}
    
Create Item
   [Arguments]   ${dsplyName}   ${shrtDes}   ${dsplyDes}   ${price}  ${taxable}
   ${auth}=  Create Dictionary   displayName=${dsplyName}    shortDesc=${shrtDes}   displayDesc=${dsplyDes}    price=${price}    taxable=${taxable}
   ${auth}=    json.dumps    ${auth}
   Check And Create YNW Session 
   ${resp}=    POST On Session    ynw  /provider/items   data=${auth}  expected_status=any
   [Return]  ${resp}   
   
Get Item By Id
    [Arguments]   ${id}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/items/${id}  expected_status=any
    [Return]  ${resp} 
    
Get Items 
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/items  expected_status=any
    [Return]  ${resp} 
    
Update Item 
   [Arguments]     ${itemId}   ${dsplyName}   ${shrtDes}   ${dsplyDes}   ${price}   ${taxable}
   ${auth}=  Create Dictionary   itemId=${itemId}   displayName=${dsplyName}    shortDesc=${shrtDes}   displayDesc=${dsplyDes}    price=${price}  taxable=${taxable}  
   ${auth}=    json.dumps    ${auth}
   Check And Create YNW Session  
   ${resp}=    PUT On Session    ynw  /provider/items   data=${auth}  expected_status=any
   [Return]  ${resp}
  
Delete Item 
   [Arguments]   ${id}
   Check And Create YNW Session
   ${resp}=    DELETE On Session    ynw  /provider/items/${id}  expected_status=any 
   [Return]  ${resp}  
   
Enable Item 
   [Arguments]   ${id}
   Check And Create YNW Session
   ${resp}=    PUT On Session    ynw  /provider/items/enable/${id}  expected_status=any 
   [Return]  ${resp}   

Disable Item
    [Arguments]   ${id}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  /provider/items/disable/${id}   expected_status=any
    [Return]  ${resp}    
   
Create Discount 
    [Arguments]  ${name}   ${description}   ${discValue}   ${calculationType}  ${discType}
    ${data}=  Create Dictionary   name=${name}   description=${description}   discValue=${discValue}   calculationType=${calculationType}  discType=${discType}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/bill/discounts   data=${data}  expected_status=any
    [Return]  ${resp}
        
Get Discounts 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/bill/discounts  expected_status=any
    [Return]  ${resp}

Get Discount By Id
    [Arguments]  ${dicountId}   
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/bill/discounts/${dicountId}   expected_status=any
    [Return]  ${resp}

Delete Discount 
    [Arguments]  ${dicountId}   
    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw  /provider/bill/discounts/${dicountId}  expected_status=any 
    [Return]  ${resp}
    
Enable Discount
    [Arguments]  ${dicountId}   
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bill/discounts/${dicountId}/enable  expected_status=any 
    [Return]  ${resp}
       
Disable Discount
    [Arguments]  ${dicountId}   
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bill/discounts/${dicountId}/disable  expected_status=any
    [Return]  ${resp}

Update Discount
    [Arguments]    ${id}   ${name}   ${description}   ${discValue}   ${calculationType}
    ${data}=  Create Dictionary    id=${id}   name=${name}   description=${description}   discValue=${discValue}   calculationType=${calculationType}
    ${data}=  json.dumps  ${data} 
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bill/discounts   data=${data}  expected_status=any
    [Return]  ${resp}  
    
Delete Coupon 
    [Arguments]  ${couponId}   
    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw  /provider/bill/coupons/${couponId}   expected_status=any
    [Return]  ${resp}
    
Enable Coupon
    [Arguments]  ${couponId}   
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bill/coupons/${couponId}/enable   expected_status=any
    [Return]  ${resp}

Disable Coupon
    [Arguments]  ${couponId}   
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bill/coupons/${couponId}/disable  expected_status=any
    [Return]  ${resp}

Update Coupon 
    [Arguments]    ${id}   ${name}   ${description}   ${amount}   ${calculationType}
    ${data}=  Create Dictionary    id=${id}   name=${name}   description=${description}   amount=${amount}   calculationType=${calculationType}
    ${data}=  json.dumps  ${data} 
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bill/coupons   data=${data}  expected_status=any
    [Return]  ${resp}
    
Get Calculation Types coupon 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/bill/coupons/calculationtypes  expected_status=any
    [Return]  ${resp}   
    
Create Coupon 
    [Arguments]  ${name}   ${description}   ${amount}   ${calculationType}
    ${data}=  Create Dictionary   name=${name}  amount=${amount}  description=${description}   calculationType=${calculationType}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/bill/coupons   data=${data}  expected_status=any
    [Return]  ${resp}
    
Get Coupons 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/bill/coupons   expected_status=any
    [Return]  ${resp}

Get Coupon By Id
    [Arguments]  ${couponId}   
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/bill/coupons/${couponId}   expected_status=any
    [Return]  ${resp}

Enable Tax
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw  /provider/payment/tax/enable  expected_status=any
    [Return]  ${resp}

Disable Tax
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw  /provider/payment/tax/disable   expected_status=any
    [Return]  ${resp} 


Create virtual Service
    [Arguments]  ${name}  ${desc}  ${durtn}  ${status}  ${bType}  ${notfcn}  ${notiTp}   ${minPrePaymentAmount}   ${totalAmount}  ${isPrePayment}  ${taxable}   ${virtualServiceType}  ${virtualCallingModes}  &{kwargs}
    ${items}=  Get Dictionary items  ${kwargs}
    ${data}=  Create Dictionary  name=${name}  description=${desc}  serviceDuration=${durtn}  notification=${notfcn}  notificationType=${notiTp}  minPrePaymentAmount=${minPrePaymentAmount}   totalAmount=${totalAmount}   status=${status}  bType=${btype}  isPrePayment=${isPrePayment}  taxable=${taxable}   serviceType=virtualService   virtualServiceType=${virtualServiceType}  virtualCallingModes=${virtualCallingModes}
    FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session  
    ${resp}=  POST On Session  ynw  /provider/services  data=${data}  expected_status=any
    [Return]  ${resp}

Create Virtual Service For User
    [Arguments]  ${name}  ${desc}  ${durtn}  ${status}  ${bType}  ${notfcn}  ${notiTp}   ${minPrePaymentAmount}   ${totalAmount}  ${isPrePayment}  ${taxable}   ${virtualServiceType}  ${virtualCallingModes}   ${depid}   ${u_id}  &{kwargs}
    ${user_id}=  Create Dictionary  id=${u_id}
    ${data}=  Create Dictionary  name=${name}  description=${desc}  serviceDuration=${durtn}  notification=${notfcn}  notificationType=${notiTp}  minPrePaymentAmount=${minPrePaymentAmount}   totalAmount=${totalAmount}   status=${status}  bType=${btype}  isPrePayment=${isPrePayment}  taxable=${taxable}   serviceType=virtualService   virtualServiceType=${virtualServiceType}  virtualCallingModes=${virtualCallingModes}   department=${depid}   provider=${user_id}
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session  
    ${resp}=  POST On Session  ynw  /provider/services  data=${data}  expected_status=any
    [Return]  ${resp}


Enable Disable Virtual Service
   [Arguments]  ${status}  
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  provider/account/settings/virtualServices/${status}  expected_status=any
   [Return]  ${resp}


Update Virtual Calling Mode

    [Arguments]  ${virtual_callingmode} 

    ${data}=  Create Dictionary   virtualCallingModes=${virtual_callingmode}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/account/settings/virtualCallingModes   data=${data}  expected_status=any
    Log  ${resp.content}
    [Return]  ${resp}


Get Virtual Calling Mode
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /provider/account/settings/virtualCallingModes  expected_status=any
    [Return]  ${resp}

# Create Service
#     [Arguments]  ${name}  ${desc}  ${durtn}  ${status}  ${bType}  ${notfcn}  ${notiTp}   ${minPrePaymentAmount}   ${totalAmount}  ${isPrePayment}  ${taxable}   
#     ${data}=  Create Dictionary  name=${name}  description=${desc}  serviceDuration=${durtn}  notification=${notfcn}  notificationType=${notiTp}  minPrePaymentAmount=${minPrePaymentAmount}   totalAmount=${totalAmount}   status=${status}  bType=${btype}  isPrePayment=${isPrePayment}  taxable=${taxable}
#     ${data}=  json.dumps  ${data}
#     Check And Create YNW Session  
#     ${resp}=  POST On Session  ynw  /provider/services  data=${data}  expected_status=any
#     [Return]  ${resp}

Create Service
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
    [Return]  ${resp}


Create Service with info
    [Arguments]   ${name}   ${desc}   ${durtn}   ${notfcn}   ${notiTp}   ${minPrePaymentAmount}   ${totalAmount}   ${status}   ${bType}   ${isPrePayment}   ${taxable}   ${serviceType}   ${virtualServiceType}   ${virtualCallingModes}   ${depid}   ${u_id}   ${consumerNoteMandatory}   ${consumerNoteTitle}   ${preInfoEnabled}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled}   ${postInfoTitle}   ${postInfoText}
    ${user_id}=  Create Dictionary  id=${u_id}
    ${data}=  Create Dictionary  name=${name}  description=${desc}  serviceDuration=${durtn}  notification=${notfcn}  notificationType=${notiTp}  minPrePaymentAmount=${minPrePaymentAmount}   totalAmount=${totalAmount}   status=${status}  bType=${btype}  isPrePayment=${isPrePayment}  taxable=${taxable}   serviceType=${serviceType}   virtualServiceType=${virtualServiceType}  virtualCallingModes=${virtualCallingModes}  department=${depid}   provider=${user_id}   consumerNoteMandatory=${consumerNoteMandatory}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${preInfoEnabled}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${postInfoEnabled}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session  
    ${resp}=  POST On Session  ynw  /provider/services  data=${data}  expected_status=any
    [Return]  ${resp}


Update Service with info
    [Arguments]   ${sid}   ${name}   ${desc}   ${durtn}   ${notfcn}   ${notiTp}   ${minPrePaymentAmount}   ${totalAmount}   ${status}   ${bType}   ${isPrePayment}   ${taxable}   ${serviceType}   ${virtualServiceType}   ${virtualCallingModes}   ${depid}   ${u_id}   ${consumerNoteMandatory}   ${consumerNoteTitle}   ${preInfoEnabled}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled}   ${postInfoTitle}   ${postInfoText}
    ${user_id}=  Create Dictionary  id=${u_id}
    ${data}=  Create Dictionary   id=${sid}  name=${name}  description=${desc}  serviceDuration=${durtn}  notification=${notfcn}  notificationType=${notiTp}  minPrePaymentAmount=${minPrePaymentAmount}   totalAmount=${totalAmount}   status=${status}  bType=${btype}  isPrePayment=${isPrePayment}  taxable=${taxable}   serviceType=${serviceType}   virtualServiceType=${virtualServiceType}  virtualCallingModes=${virtualCallingModes}  department=${depid}   provider=${user_id}   consumerNoteMandatory=${consumerNoteMandatory}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${preInfoEnabled}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${postInfoEnabled}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session  
    ${resp}=  PUT On Session  ynw  /provider/services  data=${data}  expected_status=any
    [Return]  ${resp}
    

Create Service With serviceType
    [Arguments]  ${name}  ${desc}  ${durtn}  ${status}  ${bType}  ${notfcn}  ${notiTp}   ${minPrePaymentAmount}   ${totalAmount}  ${isPrePayment}  ${taxable}   ${serviceType}
    ${data}=  Create Dictionary  name=${name}  description=${desc}  serviceDuration=${durtn}  notification=${notfcn}  notificationType=${notiTp}  minPrePaymentAmount=${minPrePaymentAmount}   totalAmount=${totalAmount}   status=${status}  bType=${btype}  isPrePayment=${isPrePayment}  taxable=${taxable}   serviceType=${serviceType}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session  
    ${resp}=  POST On Session  ynw  /provider/services  data=${data}  expected_status=any
    [Return]  ${resp}


Create Sample Service
    [Arguments]  ${Service_name}    &{kwargs}
    ${desc}=   FakerLibrary.sentence
    ${srv_duration}=   Random Int   min=2   max=2
    ${min_pre}=   Random Int   min=1   max=50
    ${Total}=   Random Int   min=100   max=500
    ${resp}=  Create Service  ${Service_name}  ${desc}   ${srv_duration}  ${status[0]}  ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[0]}  ${bool[0]}   &{kwargs}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    [Return]  ${resp.json()}


Create Sample Service with Prepayment
    [Arguments]  ${Service_name}  ${prepayment_amt}  ${servicecharge}  &{kwargs}
    ${desc}=   FakerLibrary.sentence
    ${srv_duration}=   Random Int   min=2   max=2
    ${resp}=  Create Service  ${Service_name}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${prepayment_amt}  ${servicecharge}  ${bool[1]}  ${bool[0]}  &{kwargs}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    [Return]  ${resp.json()}


Create Sample Service with Prepayment For User
    [Arguments]  ${Service_name}  ${prepayment_amt}  ${servicecharge}  ${u_id}  &{kwargs}
    ${desc}=   FakerLibrary.sentence
    ${srv_duration}=   Random Int   min=2   max=2
    ${resp}=  Create Service For User  ${Service_name}  ${desc}   ${srv_duration}  ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}  ${prepayment_amt}  ${servicecharge}  ${bool[1]}  ${bool[0]}  ${depid}  ${u_id}  &{kwargs}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    [Return]  ${resp.json()}


Create Sample Service For User
    [Arguments]   ${Service_name}   ${depid}   ${u_id}
    ${resp}=  Create Service For User  ${Service_name}  Description   2  ACTIVE  Waitlist  True  email  45  500  False  False  ${depid}   ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    [Return]  ${resp.json()}

Create Service Department
    [Arguments]  ${name}  ${desc}  ${durtn}  ${bType}  ${notfcn}  ${notiTp}   ${minPrePaymentAmount}   ${totalAmount}  ${isPrePayment}  ${taxable}  ${depid}  
    ${data}=  Create Dictionary  name=${name}  description=${desc}  serviceDuration=${durtn}  notification=${notfcn}  notificationType=${notiTp}  minPrePaymentAmount=${minPrePaymentAmount}   totalAmount=${totalAmount}  bType=${btype}  isPrePayment=${isPrePayment}  taxable=${taxable}  department=${depid} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session  
    ${resp}=  POST On Session  ynw  /provider/services  data=${data}  expected_status=any
    [Return]  ${resp}

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
    [Return]  ${resp}

Update Service For User
    [Arguments]  ${id}   ${name}  ${desc}  ${durtn}  ${status}  ${bType}  ${notfcn}  ${notiTp}   ${minPrePaymentAmount}   ${totalAmount}  ${isPrePayment}  ${taxable}  ${depid}   ${u_id}
    ${user_id}=  Create Dictionary  id=${u_id}
    ${data}=  Create Dictionary  id=${id}  name=${name}  description=${desc}  serviceDuration=${durtn}  notification=${notfcn}  notificationType=${notiTp}  minPrePaymentAmount=${minPrePaymentAmount}   totalAmount=${totalAmount}   status=${status}  bType=${btype}  isPrePayment=${isPrePayment}  taxable=${taxable}    department=${depid}    provider=${user_id}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/services  data=${data}  expected_status=any
    [Return]  ${resp}

# Update Service
#     [Arguments]  ${id}   ${name}  ${desc}  ${durtn}  ${status}  ${bType}  ${notfcn}  ${notiTp}   ${minPrePaymentAmount}   ${totalAmount}  ${isPrePayment}  ${taxable}  
#     ${data}=  Create Dictionary  id=${id}  name=${name}  description=${desc}  serviceDuration=${durtn}  notification=${notfcn}  notificationType=${notiTp}  minPrePaymentAmount=${minPrePaymentAmount}   totalAmount=${totalAmount}   status=${status}  bType=${btype}  isPrePayment=${isPrePayment}  taxable=${taxable}
#     ${data}=  json.dumps  ${data}
#     Check And Create YNW Session
#     ${resp}=  PUT On Session  ynw  /provider/services  data=${data}  expected_status=any
#     [Return]  ${resp}

Update Service
    [Arguments]  ${id}   ${name}  ${desc}  ${durtn}  ${status}  ${bType}  ${notfcn}  ${notiTp}   ${minPrePaymentAmount}   ${totalAmount}  ${isPrePayment}  ${taxable}  &{kwargs}
    ${items}=  Get Dictionary items  ${kwargs}
    ${data}=  Create Dictionary  id=${id}  name=${name}  description=${desc}  serviceDuration=${durtn}  notification=${notfcn}  notificationType=${notiTp}  minPrePaymentAmount=${minPrePaymentAmount}   totalAmount=${totalAmount}   status=${status}  bType=${btype}  isPrePayment=${isPrePayment}  taxable=${taxable}
    FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    Log  ${data}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/services  data=${data}  expected_status=any
    [Return]  ${resp}

Update Service With Service Type
    [Arguments]  ${id}   ${name}  ${desc}  ${durtn}  ${status}  ${bType}  ${notfcn}  ${notiTp}   ${minPrePaymentAmount}   ${totalAmount}  ${isPrePayment}  ${taxable}   ${serviceType} 
    ${data}=  Create Dictionary  id=${id}  name=${name}  description=${desc}  serviceDuration=${durtn}  notification=${notfcn}  notificationType=${notiTp}  minPrePaymentAmount=${minPrePaymentAmount}   totalAmount=${totalAmount}   status=${status}  bType=${btype}  isPrePayment=${isPrePayment}  taxable=${taxable}   serviceType=${serviceType}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/services  data=${data}  expected_status=any
    [Return]  ${resp}

Update Virtual Service
    [Arguments]  ${id}   ${name}  ${desc}  ${durtn}  ${status}  ${bType}  ${notfcn}  ${notiTp}   ${minPrePaymentAmount}   ${totalAmount}  ${isPrePayment}  ${taxable}   ${serviceType}   ${virtualCallingModes}
    ${data}=  Create Dictionary  id=${id}  name=${name}  description=${desc}  serviceDuration=${durtn}  notification=${notfcn}  notificationType=${notiTp}  minPrePaymentAmount=${minPrePaymentAmount}   totalAmount=${totalAmount}   status=${status}  bType=${btype}  isPrePayment=${isPrePayment}  taxable=${taxable}   serviceType=${serviceType}   virtualCallingModes=${virtualCallingModes}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/services  data=${data}  expected_status=any
    [Return]  ${resp}   


Get Service
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/services  params=${param}  expected_status=any
    [Return]  ${resp}
    
Get Service By Id
    [Arguments]  ${id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/services/${id}  expected_status=any
    [Return]  ${resp}  

Get Service Count
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/services/count  params=${param}  expected_status=any
    [Return]  ${resp}


Get ServiceImage
    [Arguments]  ${id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  provider/services/serviceGallery/${id}  expected_status=any
    [Return]  ${resp}

Enable service 
   [Arguments]  ${id}  
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  /provider/services/${id}/Enable  expected_status=any
   [Return]  ${resp}  
   
Disable service 
   [Arguments]  ${id} 
   Check And Create YNW Session
   ${resp}=  DELETE On Session  ynw  /provider/services/${id}/Disable  expected_status=any
   [Return]  ${resp}     
   
Delete Service
   [Arguments]  ${id}  
   Check And Create YNW Session
   ${resp}=  DELETE On Session  ynw  /provider/services/${id}  expected_status=any
   [Return]  ${resp}   
    
Get business Domain
     Check And Create YNW Session
     ${resp}=  GET On Session  ynw  /ynwConf/businessDomains  expected_status=any
     [Return]  ${resp}

Get subDomain level Fields
     [Arguments]  ${domain}  ${subdomain}
     Check And Create YNW Session
     ${resp}=  GET On Session  ynw  /provider/ynwConf/dataModel/${domain}/${subdomain}  expected_status=any
     [Return]  ${resp}     
  
Get Domain level Fields
     [Arguments]  ${domain}
     Check And Create YNW Session
     ${resp}=  GET On Session  ynw  /provider/ynwConf/dataModel/${domain}  expected_status=any
     [Return]  ${resp}     
         
Update Domain_Level
     [Arguments]   ${data}
     ${data}=    json.dumps    ${data}  
     Check And Create YNW Session
     ${resp}=  PUT On Session  ynw  /provider/bProfile/domain  data=${data}  expected_status=any
     [Return]  ${resp}

Get Licenses
	Check And Create YNW Session
	${resp}=  GET On Session  ynw  /provider/license  expected_status=any
	[Return]  ${resp}
    
update license
	[Arguments]  ${licPkgId}  
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/license/${licPkgId}  expected_status=any
    [Return]  ${resp} 
		
Get Audit Logs
    [Arguments]    &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /provider/auditlogs    params=${kwargs}  expected_status=any
    [Return]    ${resp}

Enable Online Checkin
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/waitlistMgr/onlineCheckIns/Enable  expected_status=any
    [Return]  ${resp}

Disable Online Checkin
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/waitlistMgr/onlineCheckIns/Disable  expected_status=any
    [Return]  ${resp}

Enable Future Checkin
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/waitlistMgr/futureCheckIns/Enable  expected_status=any
    [Return]  ${resp}

Disable Future Checkin
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/waitlistMgr/futureCheckIns/Disable  expected_status=any
    [Return]  ${resp}

Add Delay
    [Arguments]  ${qid}  ${time}  ${msg}  ${sndmsg}
    ${data}=  Create Dictionary  delayDuration=${time}  message=${msg}  sendMsg=${sndmsg}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/waitlist/queues/${qid}/delay  data=${data}  expected_status=any
    [Return]  ${resp}

Get Delay
    [Arguments]  ${qid}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/queues/${qid}/delay  expected_status=any
    [Return]  ${resp}

Get Queue Waiting Time
    [Arguments]  ${qid}  ${date}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/queues/${qid}/${date}/waitingTime  expected_status=any
    [Return]  ${resp}

Get Queue Length
    [Arguments]  ${qid}  ${date}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/queues/${qid}/${date}/length  expected_status=any
    [Return]  ${resp}

Get Queue Of A Service
    [Arguments]  ${loc}  ${service}  ${date}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/queues/${loc}/location/${service}/service/${date}  expected_status=any
    [Return]  ${resp}

Get Waiting Time Of Providers
    [Arguments]  @{ids} 
    Check And Create YNW Session
    ${len}=  Get Length  ${ids}
    Set Test Variable  ${pid}  ${ids[0]}
    FOR    ${index}    IN RANGE  1  ${len}
    	${pid}=  Catenate 	SEPARATOR=,	${pid} 	${ids[${index}]}
    END
    ${resp}=  GET On Session  ynw  /provider/waitlist/queues/waitingTime/${pid}  expected_status=any
    [Return]  ${resp}

Get Last Computed waitingTime
    [Arguments]  ${qid}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/queues/${qid}/lastComputedWaitingTime  expected_status=any
    [Return]  ${resp}

Get Features
    [Arguments]  ${subdomain}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/ynwConf/features/${subdomain}  expected_status=any
    [Return]  ${resp}
    
Get Business schedules
	Check and Create YNW Session
	${resp}=  GET On Session   ynw  /provider/ynwConf/bSchedule  expected_status=any
	[return]  ${resp}

Create Alert
    [Arguments]  ${s_id}  ${c_id}  ${subc_id}  ${text}  ${sev}  ${ack}  ${sub}
    ${src}=  Create Dictionary  id=${s_id}
    ${cat}=  Create Dictionary  id=${c_id}
    ${sub_cat}=  Create Dictionary  id=${subc_id}
    ${data}=  Create Dictionary  source=${src}  category=${cat}  subCategory=${sub_cat}  text=${text}  severity=${sev}   ackRequired=${ack}  subject=${sub}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  provider/alerts  data=${data}  expected_status=any
    [Return]  ${resp}

Get Alert ById
     [Arguments]  ${alertId}
     Check And Create YNW Session
     ${resp}=  GET On Session  ynw  /provider/alerts/${alertId}  expected_status=any
     [Return]  ${resp}

Get Alerts
     [Arguments]    &{kwargs}
     Check And Create YNW Session
     ${resp}=  GET On Session  ynw  /provider/alerts   params=${kwargs}   expected_status=any
     [Return]  ${resp}

Delete Alerts
     Check And Create YNW Session
     ${resp}=  DELETE On Session  ynw  /provider/alerts  expected_status=any
     [Return]  ${resp}

Acknowldge Alert
     [Arguments]  ${alertId}
     Check And Create YNW Session
     ${resp}=  PUT On Session  ynw  /provider/alerts/${alertId}  expected_status=any
     [Return]  ${resp}

Delete Alert ById
     [Arguments]  ${alertId}
     Check And Create YNW Session
     ${resp}=  DELETE On Session  ynw  /provider/alerts/${alertId}  expected_status=any
     [Return]  ${resp}

Get Alerts Count
     Check And Create YNW Session
     ${resp}=  GET On Session  ynw  /provider/alerts/count  expected_status=any
     [Return]  ${resp}

Get Alerts From Superadmin
     Check And Create YNW Session
     ${resp}=  GET On Session  ynw  /provider/alerts/superadmin  expected_status=any
     [Return]  ${resp}

Get Default Messages
     Check And Create YNW Session
     ${resp}=  GET On Session  ynw  /provider/ynwConf/messages  expected_status=any
     [Return]  ${resp}

Update Service Provider
     [Arguments]  ${id}  ${firstName}  ${lastName}  ${gender}  ${dob}
     ${bin}=  Create Dictionary  id=${id}  firstName=${firstName}  lastName=${lastName}  gender=${gender}  dob=${dob} 
     ${data}=  Create Dictionary  basicInfo=${bin}
     ${data}=    json.dumps    ${data}
     Check And Create YNW Session
     ${resp}=  PATCH On Session  ynw  provider/profile  data=${data}  expected_status=any
     [Return]  ${resp}

Update Service Provider With Emailid
     [Arguments]  ${id}  ${firstName}  ${lastName}  ${gender}  ${dob}  ${email}
     ${bin}=  Create Dictionary  id=${id}  firstName=${firstName}  lastName=${lastName}  gender=${gender}  dob=${dob}  email=${email}
     ${data}=  Create Dictionary  basicInfo=${bin}
     ${data}=    json.dumps    ${data}
     Check And Create YNW Session
     ${resp}=  PATCH On Session  ynw  provider/profile  data=${data}  expected_status=any
     [Return]  ${resp}
       
Get Provider Details
     [Arguments]  ${providerId}
     Check And Create YNW Session
     ${resp}=  GET On Session  ynw  /provider/profile/${providerId}  expected_status=any
     [Return]  ${resp}


Communication consumers
     [Arguments]  ${consumerId}  ${msg}
     ${data}=  Create Dictionary  communicationMessage=${msg} 
     ${data}=  json.dumps  ${data}
     Check And Create YNW Session  
     ${resp}=  POST On Session  ynw  /provider/communications/${consumerId}  data=${data}  expected_status=any
     [Return]  ${resp}


User Consumer Communication 
     [Arguments]  ${UserId}  ${consumerId}  ${msg}
     ${data}=  Create Dictionary  provider=${UserId}   communicationMessage=${msg} 
     ${data}=  json.dumps  ${data}
     Check And Create YNW Session  
     ${resp}=  POST On Session  ynw  /provider/communications/${consumerId}  data=${data}  expected_status=any
     [Return]  ${resp}

     
Get provider communications
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /provider/communications  expected_status=any
    [Return]  ${resp} 

Get User communications
    [Arguments]   ${userId}
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /provider/user/communication/${userId}  expected_status=any
    [Return]  ${resp}

    
Reading Consumer Communications
    [Arguments]   ${consumerId}   ${messageIds}   ${providerId}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/communications/readMessages/${consumerId}/${messageIds}/${providerId}  expected_status=any
    [Return]  ${resp}    


Get provider Unread message Count
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /provider/communications/unreadCount  expected_status=any
    [Return]  ${resp} 
    
Get GalleryOrlogo image
    [Arguments]  ${target}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/${target}  expected_status=any
    [Return]  ${resp}

   	
Get specializations Sub Domain
    [Arguments]  ${domain}  ${subDomain}
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /ynwConf/specializations/${domain}/${subDomain}  expected_status=any
    [Return]  ${resp}
   	
Get Terminologies
    [Arguments]  ${domain}  ${subDomain}
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /ynwConf/terminologies/${domain}/${subDomain}  expected_status=any
    [Return]  ${resp}
    
Get Global Filters
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /ynwConf/refinedFilters  expected_status=any
    [Return]  ${resp}
    

Get Domain Filters 
    [Arguments]  ${domain}  
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /ynwConf/refinedFilters/${domain}  expected_status=any
    [Return]  ${resp}   
    
Get SubDomain Filters  
    [Arguments]  ${domain}  ${subDomain}
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /ynwConf/refinedFilters/${domain}/${subDomain}  expected_status=any
    [Return]  ${resp} 
    
Get Search Labels   
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /ynwConf/searchLabels  expected_status=any
    [Return]  ${resp}  
    
Get Domain Settings    
    [Arguments]  ${domain}  
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /ynwConf/settings/${domain}  expected_status=any
    [Return]  ${resp}
    
Get Sub Domain Settings  
    [Arguments]  ${domain}  ${subDomain}
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /ynwConf/settings/${domain}/${subDomain}  expected_status=any
    [Return]  ${resp}  

Get paymentTypes
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /ynwConf/paymentTypes  expected_status=any
    [Return]  ${resp} 
    
Get parkingTypes
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /ynwConf/parkingTypes  expected_status=any
    [Return]  ${resp}
    
Get verifyLevels 
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /ynwConf/verifyLevels  expected_status=any
    [Return]  ${resp} 
    
Update Privacy Setting
    [Arguments]  ${ph1}  ${email}
    ${data}=  Create Dictionary    emails=${email}   phoneNumbers=${ph1} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/privacySettings  data=${data}  expected_status=any
    [Return]  ${resp} 
    
Get Privacy Setting 
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw   /provider/privacySettings  expected_status=any
    [Return]  ${resp}
           
Enable Waitlist
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/account/settings/waitlist/Enable  expected_status=any
    [Return]  ${resp}

Disable Waitlist
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/account/settings/waitlist/Disable   expected_status=any
    [Return]  ${resp}

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
    [Return]  ${resp}

Add To Waitlist with mode
    [Arguments]   ${waitlistMode}  ${consid}  ${service_id}  ${qid}  ${date}  ${consumerNote}  ${ignorePrePayment}   @{fids}  &{kwargs}
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
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${pro_headers}   &{tzheaders}
    Set To Dictionary  ${pro_params}   &{locparam}

    ${data}=    Create Dictionary    consumer=${cid}  service=${sid}  queue=${qid}  date=${date}  consumerNote=${consumerNote}  waitlistingFor=${fid}  ignorePrePayment=${ignorePrePayment}  waitlistMode=${waitlistMode}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  provider/waitlist  params=${pro_params}  data=${data}  expected_status=any  headers=${headers}
    [Return]  ${resp}

Add To Waitlist with PhoneNo
    [Arguments]   ${consid}  ${service_id}  ${qid}  ${date}  ${waitlistPhoneNumber}  ${country_code}  @{fids}   &{kwargs}
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

    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${pro_headers}   &{tzheaders}
    Set To Dictionary  ${pro_params}   &{locparam}

    ${data}=    Create Dictionary    consumer=${cid}  service=${sid}  queue=${qid}  date=${date}  waitlistPhoneNumber=${waitlistPhoneNumber}  countryCode=${country_code}  waitlistingFor=${fid}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  provider/waitlist  params=${pro_params}  data=${data}  expected_status=any  headers=${headers}
    [Return]  ${resp}

Add To Waitlist By User
    [Arguments]   ${consid}  ${service_id}  ${qid}  ${date}  ${consumerNote}  ${ignorePrePayment}  ${user_id}  @{fids}    &{kwargs}
    ${pro_headers}=  Create Dictionary  &{headers}
    ${pro_params}=   Create Dictionary
    ${cid}=  Create Dictionary  id=${consid}
    ${sid}=  Create Dictionary  id=${service_id}
    ${qid}=  Create Dictionary  id=${qid}
    ${uid}=  Create Dictionary  id=${user_id}
    ${fid}=  Create Dictionary  id=${fids[0]}
    ${len}=  Get Length  ${fids}
    ${fid}=  Create List  ${fid}
    FOR    ${index}    IN RANGE  1  ${len}
        ${ap}=  Create Dictionary  id=${fids[${index}]}
        Append To List  ${fid} 	${ap}
    END
    ${data}=    Create Dictionary    consumer=${cid}  service=${sid}  queue=${qid}  date=${date}  consumerNote=${consumerNote}  waitlistingFor=${fid}  ignorePrePayment=${ignorePrePayment}  provider=${uid}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${pro_headers}   &{tzheaders}
    Set To Dictionary  ${pro_params}   &{locparam}

    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  provider/waitlist  params=${pro_params}  data=${data}  expected_status=any  headers=${headers}
    [Return]  ${resp}

Add To Waitlist Block
    [Arguments]    ${qid}   ${service_id}  ${serviceType}   ${date}  ${consumerNote}   ${ignorePrePayment}  ${waitlistingFor}  &{kwargs}
    ${pro_headers}=  Create Dictionary  &{headers}
    ${pro_params}=   Create Dictionary
    ${qid}=  Create Dictionary  id=${qid}
    ${sid}=  Create Dictionary  id=${service_id}  serviceType=${serviceType}
    ${data}=    Create Dictionary   queue=${qid}   date=${date}   service=${sid}    consumerNote=${consumerNote}    waitlistingFor=${waitlistingFor}    ignorePrePayment=${ignorePrePayment}
    ${data}=  json.dumps  ${data}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${pro_headers}   &{tzheaders}
    Set To Dictionary  ${pro_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  provider/waitlist/block  params=${pro_params}  data=${data}  expected_status=any  headers=${headers}
    [Return]  ${resp}

Confirm Wailtlist Block
    [Arguments]   ${cons_id}  ${wid}   ${waitlistingFor}  &{kwargs}
    ${pro_headers}=  Create Dictionary  &{headers}
    ${pro_params}=   Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${pro_headers}   &{tzheaders}
    Set To Dictionary  ${pro_params}   &{locparam}
    ${consumer}=  Create Dictionary  id=${cons_id} 
    ${data}=    Create Dictionary   waitlistingFor=${waitlistingFor}  ynwUuid=${wid}  consumer=${consumer}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  provider/waitlist/confirm  params=${pro_params}  data=${data}  expected_status=any
    [Return]  ${resp}

Waitlist Unblock
    [Arguments]    ${wid}  &{kwargs} 
    ${pro_headers}=  Create Dictionary  &{headers}
    ${pro_params}=   Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${pro_headers}   &{tzheaders}
    Set To Dictionary  ${pro_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  provider/waitlist/unblock/${wid}  params=${pro_params}  expected_status=any
    [Return]  ${resp}


Provider Add To WL With Virtual Service
    [Arguments]   ${consid}  ${service_id}  ${qid}  ${date}  ${consumerNote}  ${ignorePrePayment}  ${waitlistMode}   ${virtualService}  @{fids}  &{kwargs}
    
    ${pro_headers}=  Create Dictionary  &{headers}
    ${pro_params}=   Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${pro_headers}   &{tzheaders}
    Set To Dictionary  ${pro_params}   &{locparam}
    
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
    ${data}=    Create Dictionary    consumer=${cid}  service=${sid}  queue=${qid}  date=${date}  consumerNote=${consumerNote}  waitlistingFor=${fid}  ignorePrePayment=${ignorePrePayment}    waitlistMode=${waitlistMode}  virtualService=${virtualService}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  provider/waitlist  params=${pro_params}  data=${data}  expected_status=any
    [Return]  ${resp}


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
    [Return]  ${resp}

	     
Get Waitlist Today
    [Arguments]    &{kwargs}
    ${pro_headers}=  Create Dictionary  &{headers}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${pro_headers}   &{tzheaders}
    Set To Dictionary  ${kwargs}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/waitlist/today  params=${kwargs}  expected_status=any
    [Return]  ${resp}

Get Waitlist Count Today
    [Arguments]    &{kwargs}
    ${pro_headers}=  Create Dictionary  &{headers}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${pro_headers}   &{tzheaders}
    Set To Dictionary  ${kwargs}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/waitlist/today/count  params=${kwargs}  expected_status=any
    [Return]  ${resp}

Get Waitlist Future
    [Arguments]     &{kwargs}
    ${pro_headers}=  Create Dictionary  &{headers}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${pro_headers}   &{tzheaders}
    Set To Dictionary  ${kwargs}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/waitlist/future/  params=${kwargs}  expected_status=any
    [Return]  ${resp}

Get Waitlist Count Future
    [Arguments]     &{kwargs}
    ${pro_headers}=  Create Dictionary  &{headers}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${pro_headers}   &{tzheaders}
    Set To Dictionary  ${kwargs}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/waitlist/future/count  params=${kwargs}  expected_status=any
    [Return]  ${resp}
    
Get Waitlist History
    [Arguments]    &{kwargs}
    ${pro_headers}=  Create Dictionary  &{headers}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${pro_headers}   &{tzheaders}
    Set To Dictionary  ${kwargs}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/waitlist/history  params=${kwargs}  expected_status=any
    [Return]  ${resp}

Get Waitlist Count History
    [Arguments]    &{kwargs}
    ${pro_headers}=  Create Dictionary  &{headers}
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${pro_headers}   &{tzheaders}
    Set To Dictionary  ${kwargs}   &{locparam}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/waitlist/history/count  params=${kwargs}  expected_status=any
    [Return]  ${resp}    

# Get Waitlisted Consumers and Get Waitlisted Consumers Count Urls commented from rest side     
# Respective suites commented and moved to tdd.
# Get Waitlisted Consumers
#     [Arguments]    &{kwargs}
#     ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
#     Log  ${kwargs}
#     Set To Dictionary  ${pro_headers}   &{tzheaders}
#     Set To Dictionary  ${kwargs}   &{locparam}
#     Check And Create YNW Session
#     ${resp}=    GET On Session    ynw  /provider/waitlist/consumers  params=${kwargs}  expected_status=any
#     [Return]  ${resp}

# Get Waitlisted Consumers Count
#     [Arguments]    &{kwargs}
#     ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
#     Log  ${kwargs}
#     Set To Dictionary  ${pro_headers}   &{tzheaders}
#     Set To Dictionary  ${kwargs}   &{locparam}
#     Check And Create YNW Session
#     ${resp}=    GET On Session    ynw  /provider/waitlist/consumers/count  params=${kwargs}  expected_status=any
#     [Return]  ${resp}    

Waitlist Action
    [Arguments]  ${action}  ${id} 
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/waitlist/${id}/${action}  expected_status=any
    [Return]  ${resp}

Waitlist Action Cancel
    [Arguments]  ${ids}  ${CR}  ${CM}
    ${auth}=  Create Dictionary  cancelReason=${CR}  communicationMessage=${CM}
    ${apple}=  json.dumps  ${auth}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/waitlist/${ids}/CANCEL  data=${apple}    expected_status=any
    [Return]  ${resp}

Get Waitlist State Changes
    [Arguments]    ${uuid}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/waitlist/states/${uuid}  expected_status=any
    [Return]  ${resp}
    
CommunicationBetweenProviderAndConsumer
	[Arguments]  ${uuid}  ${msg}
	${data}=  Create Dictionary  communicationMessage=${msg} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session  
    ${resp}=  POST On Session  ynw  /provider/waitlist/communicate/${uuid}  data=${data}  expected_status=any
    [Return]  ${resp}

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
    [Return]  ${resp} 

uploadGalleryImageFile
    [Arguments]  ${file}   ${Cookie}
    Property File
    # ${resp}=  uploadGalleryImage  ${file}
    ${resp}=  galleryImgUpload   ${Cookie}  ${file}
    [Return]  ${resp} 

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
    [Return]  ${resp} 
   
uploadLogoImages
    [Arguments]  ${Cookie}
    ${prop}=  Create Dictionary  caption=logo
    ${prop}=  json.dumps  ${prop}
    Create File  TDD/logo.json  ${prop}  
    # ${resp}=  uploadLogoImage
    ${resp}=  uploadProviderLogo   ${cookie}  
    [Return]  ${resp}


uploadLogoImagesofUSER
    [Arguments]  ${providerId}  ${cookie}
    ${prop}=  Create Dictionary  caption=logo
    ${prop}=  json.dumps  ${prop}
    Create File  TDD/logo.json  ${prop}  
    # ${resp}=  uploadLogoImageofUSER   ${providerId} 
    ${resp}=  uploadUserLogo  ${cookie}   ${providerId}
    [Return]  ${resp}

    
uploadServiceImages
    [Arguments]   ${id}  ${cookie}
    ${prop}=  Create Dictionary  caption=firstImage
    ${prop}=  Create Dictionary  0=${prop}
    ${prop}=  Create Dictionary  propertiesMap=${prop}
    ${prop}=  json.dumps  ${prop}
    Create File  TDD/Service.json  ${prop}
    # ${resp}=  uploadServiceImage  ${id}
    ${resp}=  serviceImgUpload  ${id}  ${cookie}
    [Return]  ${resp}


uploadItemImages
    [Arguments]   ${iId}  ${ImgStatus}  ${cookie}
    ${prop}=  Create Dictionary  displayImage=${ImgStatus}
    ${prop}=  Create Dictionary  0=${prop}
    ${prop}=  Create Dictionary  propertiesMap=${prop}
    ${prop}=  json.dumps  ${prop}
    Create File  TDD/proper.json  ${prop} 
    ${resp}=  itemImgUpload  ${iId}  ${cookie}
    [Return]  ${resp}


uploadItemGroupImages
    [Arguments]   ${itemgroupId}  ${ImgStatus}  ${Img}  ${cookie}
    ${prop}=  Create Dictionary  displayImage=${ImgStatus}
    ${prop}=  Create Dictionary  0=${prop}
    ${prop}=  Create Dictionary  propertiesMap=${prop}
    ${prop}=  json.dumps  ${prop}
    Create File  TDD/proper.json  ${prop} 
    ${resp}=  ItemGroupImgUpload  ${itemgroupId}  ${Img}  ${cookie}
    [Return]  ${resp}


uploadCatalogImages
    [Arguments]   ${catalogId}  ${ImgStatus}  ${cookie}
    ${prop}=  Create Dictionary  displayImage=${ImgStatus}
    ${prop}=  Create Dictionary  0=${prop}
    ${prop}=  Create Dictionary  propertiesMap=${prop}
    ${prop}=  json.dumps  ${prop}
    Create File  TDD/proper.json  ${prop}  
    ${resp}=  CatalogImgUpload  ${catalogId}  ${cookie}
    [Return]  ${resp}


Waitlist Rating
   [Arguments]  ${uuid}  ${stars}  ${feedback}
   ${data}=  Create Dictionary  uuid=${uuid}  stars=${stars}  feedback=${feedback}
   ${data}=    json.dumps    ${data}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw  /provider/waitlist/rating  data=${data}  expected_status=any
   [Return]  ${resp}
   
Update Rating
   [Arguments]  ${uuid}  ${stars}  ${feedback}
   ${data}=  Create Dictionary  uuid=${uuid}  stars=${stars}  feedback=${feedback}
   ${data}=    json.dumps    ${data}
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  /provider/waitlist/rating  data=${data}  expected_status=any
   [Return]  ${resp}
   
Create provider Note
   [Arguments]  ${uuid}  ${mesage}
   ${mesage}=  json.dumps  ${mesage}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw  /provider/waitlist/notes/${uuid}   data=${mesage}   expected_status=any
   [Return]  ${resp}

get provider Note
   [Arguments]    ${consumerId}
   Check And Create YNW Session
   ${resp}=    GET On Session    ynw  /provider/waitlist/${consumerId}/notes  expected_status=any
   [Return]  ${resp}

   
Get Invoices 
    [Arguments]  ${status}
   Check And Create YNW Session
   ${resp}=    GET On Session    ynw  /provider/license/invoices/${status}/status  expected_status=any
   [Return]  ${resp}

Get Invoice By uuid
   [Arguments]  ${uuid}
   Check And Create YNW Session
   ${resp}=    GET On Session    ynw  /provider/license/invoices/${uuid}   expected_status=any  
   [Return]  ${resp}  

Service Bill
   [Arguments]  ${serrs}  ${serviceId}  ${srQua}  @{srDic}   
   ${service}=  Create Dictionary  reason=${serrs}  serviceId=${serviceId}  discountIds=${srDic}  quantity=${srQua}
   [Return]  ${service}   


# Item Bill 
#    [Arguments]  ${rsitm}  ${itemId}  ${itmqua}   @{itmdisc}  
#    ${items}=  Create Dictionary  reason=${rsitm}  itemId=${itemId}   discountIds=${itmdisc}  quantity=${itmqua}
#    [Return]  ${items}  

Item Bill
    [Arguments]  ${rsitm}  ${itemId}  ${itmqua}  @{itmdisc}   &{kwargs} 
    ${items}=  Create Dictionary  reason=${rsitm}  itemId=${itemId}   discountIds=${itmdisc}  quantity=${itmqua}
    ${itemPrice}=  Get Dictionary items  ${kwargs}
    FOR  ${key}  ${value}  IN  @{itemPrice}
        Set To Dictionary  ${items}   ${key}=${value}
    END
    Log  ${items}
    [Return]  ${items}  


Item Bill with Price
   [Arguments]  ${rsitm}  ${itemId}  ${itmqua}   ${price}   @{itmdisc}  
   ${items}=  Create Dictionary  reason=${rsitm}  itemId=${itemId}   discountIds=${itmdisc}  quantity=${itmqua}  price=${price}
   [Return]  ${items}

Service Discount
    [Arguments]  ${serId}  @{serDis}
    ${serdis}=   Create Dictionary  serviceId=${serId}  discountIds=${serDis}
    [Return]  ${serdis}

Item Discount
    [Arguments]  ${itemId}  @{itDis}
    ${itdis}=   Create Dictionary  itemId=${itemId}  discountIds=${itDis}
    [Return]  ${itdis}

Bill Discount Input
    [Arguments]  ${bId}  ${pnote}  ${cnote}
    ${bdis}=   Create Dictionary  id=${bId}  privateNote=${pnote}  displayNote=${cnote}
    [Return]  ${bdis}

Bill Discount Adhoc Input
    [Arguments]  ${bId}  ${pnote}  ${cnote}   ${value}
    ${bdis}=   Bill Discount Input  ${bId}  ${pnote}  ${cnote}
    Set To Dictionary  ${bdis}  discValue=${value}
    [Return]  ${bdis}

Bill Discount
    [Arguments]  ${bId}  @{bDis}
    ${bdis}=   Create Dictionary  id=${bId}  discounts=${bDis}
    [Return]  ${bdis}

Remove Bill Discount
    [Arguments]  ${bId}  ${dis}
    ${dis}=  Create Dictionary  id=${dis}
    ${dis}=  Create List  ${dis}
    ${bdis}=   Create Dictionary  id=${bId}  discounts=${dis}
    [Return]  ${bdis}

Provider Coupons
    [Arguments]  ${bId}  @{cIds}
    ${pc}=   Create Dictionary  id=${bId}  couponIds=${cIds}
    [Return]  ${pc} 
   
Get Bill By UUId   
   [Arguments]  ${uuid}
   Check And Create YNW Session
   ${resp}=    GET On Session    ynw  /provider/bill/${uuid}   expected_status=any
   [Return]  ${resp} 


Get Bill Count

    [Arguments]      &{param}
    Check And Create YNW Session
    ${resp}=    Get On Session    ynw    /provider/bill/count      params=${param}   expected_status=any  
    [Return]  ${resp}

Update Bill  
   [Arguments]  ${uuid}  ${action}  ${data}
    ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=    PUT On Session    ynw  /provider/bill/${action}/${uuid}    data=${data}  expected_status=any  
   [Return]  ${resp} 

Remove JC from bill  
   [Arguments]  ${uuid}  ${action}  ${data}
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=    PUT On Session    ynw  /provider/bill/${action}/${uuid}    data=${data}  expected_status=any  
   [Return]  ${resp} 

Settl Bill
   [Arguments]  ${uuid}   
   Check And Create YNW Session
   ${resp}=    PUT On Session    ynw  /provider/bill/settlebill/${uuid}  expected_status=any
   [Return]  ${resp} 

Get Bill By Status   
   [Arguments]  ${status}
   Check And Create YNW Session
   ${resp}=    GET On Session    ynw  /provider/bill/status/${status}   expected_status=any
   [Return]  ${resp}   

Accept Payment
   [Arguments]  ${uuid}  ${acceptPaymentBy}  ${amount}  
   ${data}=  Create Dictionary   uuid=${uuid}  acceptPaymentBy=${acceptPaymentBy}   amount=${amount}  
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=    POST On Session    ynw  /provider/bill/acceptPayment    data=${data}  expected_status=any  
   [Return]  ${resp} 

Get Payment By UUId
   [Arguments]  ${uuid}
   Check And Create YNW Session
   ${resp}=    GET On Session    ynw  /provider/payment/details/${uuid}   expected_status=any
   [Return]  ${resp}   

Get Payment By Individual
   [Arguments]  ${id}
   Check And Create YNW Session
   ${resp}=    GET On Session    ynw  /provider/payment/${id}   expected_status=any
   [Return]  ${resp}

Get License Metadata
   Check And Create YNW Session
   ${resp}=    GET On Session    ynw  /provider/license/licensemetadata   expected_status=any
   [Return]  ${resp}

Claim Account
    [Arguments]  ${acid}
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw  /provider/claim/${acid}   expected_status=any 
    [Return]  ${resp}   

Get badge
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/ynwConf/badges   expected_status=any
    [Return]  ${resp}
   
Make Payment Mock
    [Arguments]  ${amount}  ${response}  ${uuid}  ${purpose}
    Check And Create YNW Session
    ${data}=  Create Dictionary  amount=${amount}  paymentMode=Mock  uuid=${uuid}  mockResponse=${response}  purpose=${purpose}
    ${data}=  json.dumps  ${data}
    ${resp}=  POST On Session    ynw  /provider/payment  data=${data}  expected_status=any
    [Return]  ${resp}

Make Payment
    [Arguments]  ${amount}  ${mode}  ${uuid}  ${purpose}
    Check And Create YNW Session
    ${data}=  Create Dictionary  amount=${amount}  paymentMode=${mode}  uuid=${uuid}   purpose=${purpose}
    ${data}=  json.dumps  ${data}
    ${resp}=  POST On Session    ynw  /provider/payment  data=${data}  expected_status=any
    [Return]  ${resp}
    
Update Tax Percentage
    [Arguments]  ${taxPercentage}  ${gstNumber}  
    ${data}=  Create Dictionary  taxPercentage=${taxPercentage}  gstNumber=${gstNumber}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  /provider/payment/tax   data=${data}  expected_status=any
    [Return]  ${resp}

Get Tax Percentage
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/payment/tax  expected_status=any
    [Return]  ${resp}   

Get Adword Count
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/license/adwords/count  expected_status=any
    [Return]  ${resp}     

Get Spoke Languages
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  ynwConf/spokenLangs  expected_status=any
    [Return]  ${resp}    

Get Jaldee Coupons By Provider
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jaldee/coupons  expected_status=any
    [Return]  ${resp}  

Enable Jaldee Coupon By Provider
    [Arguments]  ${coupon_code}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  /provider/jaldee/coupons/${coupon_code}/enable   expected_status=any
    [Return]  ${resp}

Disable Jaldee Coupon By Provider
    [Arguments]  ${coupon_code}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  /provider/jaldee/coupons/${coupon_code}/disable   expected_status=any
    [Return]  ${resp}

Get Jaldee Coupons By Coupon_code
    [Arguments]  ${coupon_code}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jaldee/coupons/${coupon_code}  expected_status=any
    [Return]  ${resp}

Get Jaldee Coupon Stats By Coupon_code
    [Arguments]  ${coupon_code}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jaldee/coupons/${coupon_code}/stats  expected_status=any
    [Return]  ${resp}

Apply Jaldee Coupon By Provider
    [Arguments]  ${coupon_code}  ${wid}
    ${coupon_code}=  json.dumps  ${coupon_code}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bill/addJaldeeCoupons/${wid}   data=${coupon_code}  expected_status=any
    [Return]  ${resp}

Create Reimburse Reports By Provider
    [Arguments]  ${Day1}  ${Day2}   
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/jaldee/coupons/jcreports/reimburse/${Day1}/${Day2}  expected_status=any
    [Return]  ${resp}

Get Reimburse Reports By Provider
    [Arguments]    &{kwargs}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jaldee/coupons/jcreports/reimburse  params=${kwargs}  expected_status=any
    [Return]  ${resp}

Get Reimburse Reports By Provider By InvoiceId
    [Arguments]  ${invoice_id} 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jaldee/coupons/jcreports/reimburse/${invoice_id}   expected_status=any
    [Return]  ${resp}

Request For Payment of Jaldeecoupon
    [Arguments]  ${invoice_id}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/jaldee/coupons/jcreports/reimburse/${invoice_id}/requestPayment  expected_status=any
    [Return]  ${resp}

Set Fixed Waiting Time
    [Arguments]  ${uuid}  ${waiting_time}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/waitlist/${uuid}/${waiting_time}/waitingTime  expected_status=any
    [Return]  ${resp}

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
    [Return]  ${resp}

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
    [Return]  ${resp}

Instant Queue
    [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}     ${eDate}    ${stime}    ${etime}    ${parallel}  ${capacity}  ${loc}  @{vargs}
    ${bs}=  TimeSpec   ${rt}   ${ri}   ${sDate}  ${eDate}  ${EMPTY}  ${stime}  ${etime}
    ${location}=  Create Dictionary  id=${loc}
    ${len}=  Get Length  ${vargs}
    ${service}=  Create Dictionary  id=${vargs[0]}
    ${services}=  Create List  ${service}
    FOR    ${index}    IN RANGE  1  ${len}
        	${service}=  Create Dictionary  id=${vargs[${index}]} 
            Append To List  ${services}  ${service}
    END
    ${data}=  Create Dictionary  name=${name}  queueSchedule=${bs}  parallelServing=${parallel}  capacity=${capacity}  location=${location}  services=${services}
    [Return]  ${data}

Create Instant Queue
    [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}     ${eDate}    ${stime}    ${etime}    ${parallel}  ${capacity}  ${loc}  @{vargs}
    ${data}=  Instant Queue  ${name}  ${rt}   ${ri}   ${sDate}     ${eDate}    ${stime}    ${etime}    ${parallel}  ${capacity}  ${loc}  @{vargs}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/waitlist/queues/instant  data=${data}  expected_status=any
    [Return]  ${resp}


Instant Queue without Service
   [Arguments]  ${name}   ${rt}   ${ri}   ${sDate}     ${eDate}    ${stime}    ${etime}    ${parallel}  ${capacity}  ${loc}
   ${bs}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${EMPTY}  ${stime}  ${etime}
   ${location}=  Create Dictionary  id=${loc}
   ${data}=  Create Dictionary  name=${name}  queueSchedule=${bs}  parallelServing=${parallel}  capacity=${capacity}  location=${location}  services=${None}
   [Return]  ${data}

Create Instant Queue without Service
    [Arguments]  ${name}  ${rt}   ${ri}   ${sDate}     ${eDate}    ${stime}    ${etime}    ${parallel}  ${capacity}  ${loc}
    ${data}=  Instant Queue without Service   ${name}  ${rt}   ${ri}   ${sDate}     ${eDate}    ${stime}    ${etime}    ${parallel}  ${capacity}  ${loc}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/waitlist/queues/instant  data=${data}  expected_status=any
    [Return]  ${resp}

Update Instant Queue
    [Arguments]  ${qid}  ${name}   ${rt}   ${ri}   ${sDate}     ${eDate}    ${stime}    ${etime}    ${parallel}  ${capacity}  ${loc}  @{vargs}
    ${data}=  Instant Queue  ${name}  ${rt}  ${ri}  ${sDate}     ${eDate}    ${stime}    ${etime}    ${parallel}  ${capacity}  ${loc}  @{vargs}
    Set To Dictionary  ${data}  id=${qid}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/waitlist/queues/instant  data=${data}  expected_status=any
    [Return]  ${resp}

Update Instant Queue without service
    [Arguments]  ${qid}  ${name}  ${rt}   ${ri}  ${sDate}     ${eDate}    ${stime}    ${etime}    ${parallel}  ${capacity}  ${loc}
    ${data}=  Instant Queue without Service  ${name}  ${rt}  ${ri}   ${sDate}     ${eDate}    ${stime}    ${etime}    ${parallel}  ${capacity}  ${loc}
    Set To Dictionary  ${data}  id=${qid}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/waitlist/queues/instant  data=${data}  expected_status=any
    [Return]  ${resp}

Get Queue by Filter
    [Arguments]   ${filterArg}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/queues/filter   params=${filterArg}  expected_status=any
    [Return]  ${resp}

Enable Token
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/waitlistMgr/showTokenId/Enable   expected_status=any
    [Return]  ${resp}

Disable Token
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/waitlistMgr/showTokenId/Disable   expected_status=any
    [Return]  ${resp}

Online Checkin In Queue
    [Arguments]   ${queue_id}  ${status}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  ynw  /provider/waitlist/queues/onlineCheckIn/${status}/${queue_id}   expected_status=any
    [Return]  ${resp}

Future Checkin In Queue
    [Arguments]   ${queue_id}  ${status}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  ynw  /provider/waitlist/queues/futureCheckIn/${status}/${queue_id}   expected_status=any
    [Return]  ${resp}

Toggle Department Enable
	Check And Create YNW Session
    ${resp}=  PUT On Session    ynw  /provider/settings/waitlistMgr/department/Enable   expected_status=any
    [Return]  ${resp}   
 
Toggle Department Disable
	Check And Create YNW Session
    ${resp}=  PUT On Session    ynw  /provider/settings/waitlistMgr/department/Disable   expected_status=any
    [Return]  ${resp} 

Create Department
    [Arguments]  ${dep_name}  ${dep_code}  ${dep_desc}   @{vargs}
    ${data}=  Create Dictionary  departmentName=${dep_name}  departmentCode=${dep_code}  departmentDescription=${dep_desc}  serviceIds=${vargs} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/departments  data=${data}  expected_status=any
    [Return]  ${resp}

Disable Department
   [Arguments]  ${depid} 
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  /provider/departments/${depid}/disable  expected_status=any
   [Return]  ${resp}

Enable Department
   [Arguments]  ${depid} 
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  /provider/departments/${depid}/enable  expected_status=any
   [Return]  ${resp} 
   
Create Department With ServiceName
    [Arguments]  ${dep_name}  ${dep_code}  ${dep_desc}  @{vargs}
    ${data}=  Create Dictionary  departmentName=${dep_name}  departmentCode=${dep_code}  departmentDescription=${dep_desc}  serviceNames=${vargs} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/departments  data=${data}  expected_status=any
    [Return]  ${resp}

Get Department ById
    [Arguments]   ${dep_id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/departments/${dep_id}  expected_status=any
    [Return]  ${resp}

Get Departments
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/departments  expected_status=any
    [Return]  ${resp}

Update Department
    [Arguments]  ${dep_id}  ${dep_name}  ${dep_code}  ${dep_desc}  @{vargs}
    ${data}=  Create Dictionary  departmentName=${dep_name}  departmentCode=${dep_code}  departmentDescription=${dep_desc}  serviceIds=${vargs} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/departments/${dep_id}  data=${data}  expected_status=any
    [Return]  ${resp}

Get Services in Department
    [Arguments]   ${dep_id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/departments/${dep_id}/service   expected_status=any
    [Return]  ${resp}

Add Services To Department
    [Arguments]  ${dep_id}  @{vargs}
    ${data}=  Create Dictionary  serviceIds=${vargs}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/departments/${dep_id}/service  data=${data}  expected_status=any
    [Return]  ${resp}

Delete Service ById In A Department
   [Arguments]   ${dep_id}  ${service_id}
   Check And Create YNW Session
   ${resp}=    DELETE On Session    ynw  /provider/departments/${dep_id}/service/${service_id}  expected_status=any
   [Return]  ${resp}

Change Department Status
   [Arguments]   ${dep_id}  ${status}
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  /provider/departments/${dep_id}/${status}   expected_status=any
   [Return]  ${resp}

Branch Signup
   [Arguments]  ${cop_id}  ${name}  ${code}  ${reg_code}  ${email}  ${desc}  ${pass}  ${p_name}  ${p_l_name}  ${city}  ${state}  ${address}  ${mob_no}  ${al_phone}  ${dob}  ${gender}  ${p_email}  ${country_code}  ${is_admin}  ${sector}  ${sub_sector}  ${licpkg}  @{vargs}
   ${provider}=  Create Dictionary  firstName=${p_name}  lastName=${p_l_name}  city=${city}  state=${state}  address=${address}  primaryMobileNo=${mob_no}  alternativePhoneNo=${al_phone}  dob=${dob}  gender=${gender}  email=${p_email}  countryCode=${country_code}
   ${profile}=  Create Dictionary  userProfile=${provider}  isAdmin=${is_admin}  sector=${sector}  subSector=${sub_sector}  licPkgId=${licpkg}
   ${data}=  Create Dictionary  corpId=${cop_id}  branchName=${name}  branchCode=${code}  regionalCode=${reg_code}  branchEmail=${email}  branchDescription=${desc}  commonPassword=${pass}  provider=${profile}   services=${vargs}
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw   /sa/branch   data=${data}  expected_status=any
   [Return]  ${resp}


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
    [Return]  ${data}

Branch Business Profile
    [Arguments]   ${acct_id}  ${bName}  ${bDesc}  ${shname}   ${place}   ${longi}  ${latti}  ${g_url}  ${pin}  ${adds}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${ph1}  ${ph2}  ${email1}
    ${data}=  Branch_Profile  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pin}  ${adds}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${ph1}  ${ph2}  ${email1}
    ${pro_params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  ynw  /sa/bProfile  data=${data}    params=${pro_params}  expected_status=any
    [Return]  ${resp}

Enable/Disable Branch Search Data
    [Arguments]   ${acct_id}  ${status}
    ${pro_params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /sa/search/${status}    params=${pro_params}  expected_status=any
    [Return]  ${resp}

Create Department For Branch
    [Arguments]  ${acct_id}  ${dep_name}  ${dep_code}  ${dep_desc}  ${status}  @{vargs}
    ${data}=  Create Dictionary  departmentName=${dep_name}  departmentCode=${dep_code}  departmentDescription=${dep_desc}  serviceIds=${vargs}  departmentStatus=${status} 
    ${data}=  json.dumps  ${data}
    ${pro_params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /sa/branch/department  data=${data}   params=${pro_params}  expected_status=any
    [Return]  ${resp}

Branch SP Creation
    [Arguments]  ${p_name}  ${p_l_name}  ${city}  ${state}  ${address}  ${mob_no}  ${al_phone}  ${dob}  ${gender}  ${p_email}  ${country_code}  ${is_admin}  ${sector}  ${sub_sector}  ${licpkg}  ${dept_code}  ${branch_code}  ${pass}  @{vargs}
    ${profile}=  Create Dictionary  firstName=${p_name}  lastName=${p_l_name}  city=${city}  state=${state}  address=${address}  primaryMobileNo=${mob_no}  alternativePhoneNo=${al_phone}  dob=${dob}  gender=${gender}  email=${p_email}  countryCode=${country_code}
    ${data}=  Create Dictionary    userProfile=${profile}  isAdmin=${is_admin}  sector=${sector}  subSector=${sub_sector}  licPkgId=${licpkg}  deparmentCode=${dept_code}  branchCode=${branch_code}  commonPassword=${pass}  services=${vargs}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /sa/branch/provider   data=${data}  expected_status=any
    [Return]  ${resp}

Branch SP Business Profile
    [Arguments]   ${acct_id}  ${bName}  ${bDesc}  ${shname}   ${place}   ${longi}  ${latti}  ${g_url}  ${pin}  ${adds}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${ph1}  ${ph2}  ${email1}
    ${data}=  Branch_Profile  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pin}  ${adds}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${ph1}  ${ph2}  ${email1}
    ${pro_params}=  Create Dictionary  account=${acct_id}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  ynw  /sa/bProfile  data=${data}    params=${pro_params}  expected_status=any
    [Return]  ${resp}

Branch Level Update Subdomain Level Field For Doctor 
     [Arguments]  ${subdomain}  ${acct_id}
     ${qfn}=  Create Dictionary  qualificationName=MBBS  qualifiedyear=2000  qualifiedMonth=July  qualifiedFrom=AIIMS
     ${qfn}=  Create List  ${qfn}
     ${memb}=  Create Dictionary  nameofassociation=IMA   membersince=2001 
     ${memb}=  Create List  ${memb}
     ${data}=  Create Dictionary    doceducationalqualification=${qfn}   docmemberships=${memb}  docgender=male  
     ${data}=  json.dumps  ${data}
     ${pro_params}=  Create Dictionary  account=${acct_id}
     Check And Create YNW Session
     ${resp}=  PUT On Session  ynw  /sa/branch/provider/bProfile/${subdomain}  data=${data}  params=${pro_params}  expected_status=any
     [Return]  ${resp}

Get Server Time
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/server/date  expected_status=any
    [Return]  ${resp}

Update Subdomain_Level
     [Arguments]  ${data}  ${subdomain}
     ${data}=  json.dumps  ${data}
     Check And Create YNW Session
     ${resp}=  PUT On Session  ynw  /provider/bProfile/${subdomain}  data=${data}  expected_status=any
     [Return]  ${resp}

Update Specialization
    [Arguments]  ${data}    
    ${data}=  json.dumps  ${data}
    Log  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bProfile   data=${data}  expected_status=any
    [Return]  ${resp}
    

Provider Notification Settings     
    [Arguments]  ${resourcetype}  ${eventtype}  ${sms}  ${email}  ${pushmessage}  ${providerId}
    ${data}=  Create Dictionary  resourceType=${resourcetype}  eventType=${eventtype}  sms=${sms}  email=${email}  pushMsg=${pushmessage}  providerId=${providerId}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${value}=  POST On Session  ynw  /provider/settings/notification   data=${data}  expected_status=any
    [Return]  ${value}


Update Provider Notification Settings
    [Arguments]  ${resourcetype}  ${eventtype}  ${sms}  ${email}  ${pushmessage}   ${providerId}
    ${data}=  Create Dictionary  resourceType=${resourcetype}  eventType=${eventtype}  sms=${sms}  email=${email}  pushMsg=${pushmessage}   providerId=${providerId}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${value}=  PUT On Session  ynw  /provider/settings/notification   data=${data}  expected_status=any
    [Return]  ${value}       


Get Provider Notification Settings
    Check And Create YNW Session
    ${value}=  GET On Session  ynw  provider/settings/notification  expected_status=any
    [Return]  ${value}

View HS Settings
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/settings/homeservice   expected_status=any
    [Return]  ${resp}

Enable HS
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/homeservice/Enable   expected_status=any
    [Return]  ${resp}

Disable HS
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/homeservice/Disable   expected_status=any
    [Return]  ${resp}

Enable Online HS
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/homeservice/onlineHs/Enable  expected_status=any
    [Return]  ${resp}

Disable Online HS
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/homeservice/onlineHs/Disable   expected_status=any
    [Return]  ${resp}

Enable Future HS
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/homeservice/futureHs/Enable  expected_status=any
    [Return]  ${resp}

Disable Future HS
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/homeservice/futureHs/Disable  expected_status=any
    [Return]  ${resp}

Update HS Settings
    [Arguments]   ${enableHomeService}   ${onlineHs}  ${futureHs}    ${notification}    ${otpVerificationType}   ${liveArrivalNotificationType}
    ${data}=  Create Dictionary  enableHomeService=${enableHomeService}  onlineHs=${onlineHs}  futureHs=${futureHs}   sendNotification=${notification}    otpVerificationType=${otpVerificationType}    liveArrivalNotificationType=${liveArrivalNotificationType}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/homeservice   data=${data}  expected_status=any
    [Return]  ${resp}

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
    [Return]  ${values_set}

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
    [Return]  ${values_set}

Create Label
    [Arguments]  ${l_name}  ${display_name}  ${desc}  ${values}  ${notifications}
    ${data}=  Create Dictionary  label=${l_name}  displayName=${display_name}  description=${desc}  valueSet=${values}  notification=${notifications}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/waitlist/label   data=${data}  expected_status=any
    [Return]  ${resp}

Get Labels
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/label  expected_status=any
    [Return]  ${resp}

Get Label By Id
    [Arguments]   ${label_id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/label/${label_id}   expected_status=any
    [Return]  ${resp}

Update Label
    [Arguments]  ${label_id}  ${l_name}  ${display_name}  ${desc}  ${values}  ${notifications}
    ${data}=  Create Dictionary  id=${label_id}  label=${l_name}  displayName=${display_name}  description=${desc}  valueSet=${values}  notification=${notifications}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/waitlist/label   data=${data}  expected_status=any
    [Return]  ${resp}

Delete Label
   [Arguments]   ${id}
   Check And Create YNW Session
   ${resp}=    DELETE On Session    ynw  /provider/waitlist/label/${id}  expected_status=any
   [Return]  ${resp}

EnableDisable Label
    [Arguments]  ${id}  ${status}
    Check And Create YNW Session
    ${resp}=    PUT On Session     ynw   /provider/waitlist/label/${id}/${status}   expected_status=any
    [Return]  ${resp}

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
    [Return]  ${field_list}


Create Appointment QueueSet for Branch
    [Arguments]   ${s_name}  ${display_name}  ${desc}  ${field_list}   ${dept}   ${service}     ${label1}   ${label2}   ${apptSchdl}   ${appt_status}    @{queueSetFor}  &{kwargs}
    ${pro_headers}=  Create Dictionary  &{headers}
    ${pro_params}=   Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${pro_headers}   &{tzheaders}
    Set To Dictionary  ${pro_params}   &{locparam}
    ${len}=  Get Length  ${queueSetFor}
    ${len}=  Evaluate  ${len}-1
    ${list}=  Create List
    FOR    ${index}   IN RANGE   0  ${len}  2
        ${index2}=  Evaluate  ${index}+1
        ${ids}=  Create Dictionary   type=${queueSetFor[${index}]}  id=${queueSetFor[${index2}]}
        Append To List  ${list}  ${ids}
    END

    ${label}=   Create Dictionary   ${label1}=${label2}

    ${dic}=   Create Dictionary      departments=${dept}    services=${service}     labels=${label}    apptSchedule=${apptSchdl}    apptStatus=${appt_status}

    ${data}=  Create Dictionary  name=${s_name}  displayName=${display_name}  description=${desc}  fieldList=${field_list}   qBoardConditions=${dic}        queueSetFor=${list}   
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/appointment/statusBoard/queueSet  params=${pro_params}  data=${data}  expected_status=any
    [Return]  ${resp}

Create Appointment QueueSet for Provider
    [Arguments]   ${s_name}  ${display_name}  ${desc}  ${field_list}   ${service}   ${label1}   ${label2}   ${apptSchdl}   ${appt_status}    @{queueSetFor}  &{kwargs}
    
    ${pro_headers}=  Create Dictionary  &{headers}
    ${pro_params}=   Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${pro_headers}   &{tzheaders}
    Set To Dictionary  ${pro_params}   &{locparam}

    ${len}=  Get Length  ${queueSetFor}
    ${len}=  Evaluate  ${len}-1
    ${list}=  Create List
    FOR    ${index}   IN RANGE   0  ${len}  2
        ${index2}=  Evaluate  ${index}+1
        ${ids}=  Create Dictionary   type=${queueSetFor[${index}]}  id=${queueSetFor[${index2}]}
        Append To List  ${list}  ${ids}
    END

    ${label}=   Create Dictionary   ${label1}=${label2}

    
    ${dic}=   Create Dictionary      services=${service}     labels=${label}    apptSchedule=${apptSchdl}    apptStatus=${appt_status}

    ${data}=  Create Dictionary  name=${s_name}  displayName=${display_name}  description=${desc}  fieldList=${field_list}   qBoardConditions=${dic}        queueSetFor=${list}   
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/appointment/statusBoard/queueSet   params=${pro_params}  data=${data}  expected_status=any
    [Return]  ${resp}


# Create QueueSet
Create QueueSet for Branch 
    [Arguments]  ${s_name}  ${display_name}  ${desc}  ${field_list}   ${dept}   ${service}   ${queue}    ${label1}   ${label2}    ${wl_stt}   @{queueSetFor}
    ${len}=  Get Length  ${queueSetFor}
    ${len}=  Evaluate  ${len}-1
    ${list}=  Create List
    FOR    ${index}   IN RANGE   0  ${len}  2
        ${index2}=  Evaluate  ${index}+1
        ${ids}=  Create Dictionary   type=${queueSetFor[${index}]}  id=${queueSetFor[${index2}]}
        Append To List  ${list}  ${ids}
    END

    ${label}=   Create Dictionary   ${label1}=${label2}

    ${dic}=   Create Dictionary      departments=${dept}    services=${service}   queues=${queue}   labels=${label}   wlStatus=${wl_stt}

    ${data}=  Create Dictionary  name=${s_name}  displayName=${display_name}  description=${desc}  fieldList=${field_list}   qBoardConditions=${dic}     queueSetFor=${list}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/waitlist/statusBoard/queueSet   data=${data}  expected_status=any
    [Return]  ${resp}


Create QueueSet for provider
    [Arguments]  ${s_name}  ${display_name}  ${desc}  ${field_list}    ${service}   ${queue}    ${label1}   ${label2}    ${wl_stt}   @{queueSetFor}
    ${len}=  Get Length  ${queueSetFor}
    ${len}=  Evaluate  ${len}-1
    ${list}=  Create List
    FOR    ${index}   IN RANGE   0  ${len}  2
        ${index2}=  Evaluate  ${index}+1
        ${ids}=  Create Dictionary   type=${queueSetFor[${index}]}  id=${queueSetFor[${index2}]}
        Append To List  ${list}  ${ids}
    END

    ${label}=   Create Dictionary   ${label1}=${label2}

    ${dic}=   Create Dictionary       services=${service}   queues=${queue}   labels=${label}   wlStatus=${wl_stt}

    ${data}=  Create Dictionary  name=${s_name}  displayName=${display_name}  description=${desc}  fieldList=${field_list}   qBoardConditions=${dic}     queueSetFor=${list}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/waitlist/statusBoard/queueSet   data=${data}  expected_status=any
    [Return]  ${resp}
    

Get AppointmentQueueSet By Id
    [Arguments]   ${id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/appointment/statusBoard/queueSet/${id}  expected_status=any
    [Return]  ${resp}

Get AppointmentQueueSet

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/appointment/statusBoard/queueSet  expected_status=any
    [Return]  ${resp}

Get WaitlistQueueSets
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/statusBoard/queueSet  expected_status=any
    [Return]  ${resp}


Get WaitlistQueueSet By Id
    [Arguments]   ${id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/statusBoard/queueSet/${id}  expected_status=any
    [Return]  ${resp}   


Delete AppointmentQueue By id
    [Arguments]   ${id}
    Check And Create YNW Session
    ${resp}=    DELETE On Session    ynw  /provider/appointment/statusBoard/queueSet/${id}  expected_status=any
    [Return]  ${resp}


Delete WaitlistQueueSet By Id
   [Arguments]   ${id}
   Check And Create YNW Session
   ${resp}=    DELETE On Session    ynw  /provider/waitlist/statusBoard/queueSet/${id}  expected_status=any
   [Return]  ${resp}


Update Appoinment QueueSet for Branch
    [Arguments]   ${s_id}   ${s_name}  ${display_name}  ${desc}  ${field_list}   ${dept}   ${service}     ${label1}   ${label2}   ${apptSchdl}   ${appt_status}       @{queueSetFor}
    ${len}=  Get Length  ${queueSetFor}
    ${len}=  Evaluate  ${len}-1
    ${list}=  Create List
    FOR    ${index}   IN RANGE   0  ${len}  2
        ${index2}=  Evaluate  ${index}+1
        ${ids}=  Create Dictionary   type=${queueSetFor[${index}]}  id=${queueSetFor[${index2}]}
        Append To List  ${list}  ${ids}
    END

    ${label}=   Create Dictionary   ${label1}=${label2}
    ${dic}=   Create Dictionary      departments=${dept}    services=${service}     labels=${label}    apptSchedule=${apptSchdl}    apptStatus=${appt_status}

    ${data}=  Create Dictionary   id=${s_id}   name=${s_name}  displayName=${display_name}  description=${desc}  fieldList=${field_list}   qBoardConditions=${dic}        queueSetFor=${list}   
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session   
    ${resp}=  PUT On Session  ynw  /provider/appointment/statusBoard/queueSet   data=${data}  expected_status=any
    [Return]  ${resp}   

Update Appoinment QueueSet for Provider
    [Arguments]   ${s_id}   ${s_name}  ${display_name}  ${desc}  ${field_list}    ${service}     ${label1}   ${label2}   ${apptSchdl}   ${appt_status}       @{queueSetFor}
    ${len}=  Get Length  ${queueSetFor}
    ${len}=  Evaluate  ${len}-1
    ${list}=  Create List
    FOR    ${index}   IN RANGE   0  ${len}  2
        ${index2}=  Evaluate  ${index}+1
        ${ids}=  Create Dictionary   type=${queueSetFor[${index}]}  id=${queueSetFor[${index2}]}
        Append To List  ${list}  ${ids}
    END

    ${label}=   Create Dictionary   ${label1}=${label2}
    ${dic}=   Create Dictionary      services=${service}     labels=${label}    apptSchedule=${apptSchdl}    apptStatus=${appt_status}

    ${data}=  Create Dictionary   id=${s_id}   name=${s_name}  displayName=${display_name}  description=${desc}  fieldList=${field_list}   qBoardConditions=${dic}        queueSetFor=${list}   
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session   
    ${resp}=  PUT On Session  ynw  /provider/appointment/statusBoard/queueSet   data=${data}  expected_status=any
    [Return]  ${resp}


Update QueueSet Waitlist for Branch
    [Arguments]   ${s_id}  ${s_name}    ${display_name}  ${desc}  ${field_list}   ${dept}   ${service}   ${queue}    ${label1}   ${label2}    ${wl_stt}   @{queueSetFor}
    ${len}=  Get Length  ${queueSetFor}
    ${len}=  Evaluate  ${len}-1
    ${list}=  Create List
    FOR    ${index}   IN RANGE   0  ${len}  2
        ${index2}=  Evaluate  ${index}+1
        ${ids}=  Create Dictionary   type=${queueSetFor[${index}]}  id=${queueSetFor[${index2}]}
        Append To List  ${list}  ${ids}
    END
    
    ${label}=   Create Dictionary   ${label1}=${label2}

    ${dic}=   Create Dictionary      departments=${dept}    services=${service}   queues=${queue}   labels=${label}   wlStatus=${wl_stt}

    ${data}=  Create Dictionary  id=${s_id}  name=${s_name}  displayName=${display_name}  description=${desc}  fieldList=${field_list}    qBoardConditions=${dic}     queueSetFor=${list}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/waitlist/statusBoard/queueSet   data=${data}  expected_status=any
    [Return]  ${resp}   


Update QueueSet Waitlist for Provider
    [Arguments]   ${s_id}  ${s_name}    ${display_name}  ${desc}  ${field_list}     ${service}   ${queue}    ${label1}   ${label2}    ${wl_stt}   @{queueSetFor}
    ${len}=  Get Length  ${queueSetFor}
    ${len}=  Evaluate  ${len}-1
    ${list}=  Create List
    FOR    ${index}   IN RANGE   0  ${len}  2
        ${index2}=  Evaluate  ${index}+1
        ${ids}=  Create Dictionary   type=${queueSetFor[${index}]}  id=${queueSetFor[${index2}]}
        Append To List  ${list}  ${ids}
    END
    
    ${label}=   Create Dictionary   ${label1}=${label2}
    
    ${dic}=   Create Dictionary      services=${service}   queues=${queue}   labels=${label}   wlStatus=${wl_stt}

    ${data}=  Create Dictionary  id=${s_id}  name=${s_name}  displayName=${display_name}  description=${desc}  fieldList=${field_list}    qBoardConditions=${dic}     queueSetFor=${list}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/waitlist/statusBoard/queueSet   data=${data}  expected_status=any
    [Return]  ${resp}   


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
    [Return]  ${list}


Create Status Board waitlist
    [Arguments]  ${d_name}  ${display_name}  ${layout}  ${metric_list}
    ${data}=  Create Dictionary  name=${d_name}  displayName=${display_name}  layout=${layout}  metric=${metric_list}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/waitlist/statusBoard   data=${data}  expected_status=any
    [Return]  ${resp}


Get WaitlistStatus Boards
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/statusBoard  expected_status=any
    [Return]  ${resp} 


Get WaitlistStatus Board By Id
    [Arguments]   ${id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/statusBoard/${id}  expected_status=any
    [Return]  ${resp}


Delete Waitlist Status Board By Id
   [Arguments]   ${id}
   Check And Create YNW Session
   ${resp}=    DELETE On Session    ynw  /provider/waitlist/statusBoard/${id}  expected_status=any
   [Return]  ${resp}


Create Status Board Appointment
    [Arguments]  ${d_name}  ${display_name}  ${layout}  ${metric_list}
    ${data}=  Create Dictionary  name=${d_name}  displayName=${display_name}  layout=${layout}  metric=${metric_list}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/appointment/statusBoard   data=${data}  expected_status=any
    [Return]  ${resp}


Get AppointmentStatusBoards
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/appointment/statusBoard  expected_status=any
    [Return]  ${resp}


Get Appoinment StatusBoard By Id
    [Arguments]   ${id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/appointment/statusBoard/${id}  expected_status=any
    [Return]  ${resp}


Delete Appointment Status Board By Id
    [Arguments]   ${id}
   Check And Create YNW Session
   ${resp}=    DELETE On Session    ynw  /provider/appointment/statusBoard/${id}  expected_status=any
   [Return]  ${resp}


Update Status Board Appoinment
    [Arguments]  ${d_id}  ${d_name}  ${display_name}  ${layout}  ${metric_list}
    ${data}=  Create Dictionary  id=${d_id}  name=${d_name}  displayName=${display_name}  layout=${layout}  metric=${metric_list}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/appointment/statusBoard   data=${data}  expected_status=any
    [Return]  ${resp}


Update Status Board Waitlist
    [Arguments]  ${d_id}  ${d_name}  ${display_name}  ${layout}  ${metric_list}
    ${data}=  Create Dictionary  id=${d_id}  name=${d_name}  displayName=${display_name}  layout=${layout}  metric=${metric_list}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/waitlist/statusBoard   data=${data}  expected_status=any
    [Return]  ${resp} 

    
Enable JDN for Label
    [Arguments]    ${label}   ${displayNote}   
    ${data}=   Create Dictionary   label=${label}   displayNote=${displayNote}   
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /provider/settings/jdn/enable    data=${data}  expected_status=any
    [Return]  ${resp}

Enable JDN for Percent
    [Arguments]    ${displayNote}   ${discPercentage}   ${discMax}   
    ${data}=   Create Dictionary   displayNote=${displayNote}   discPercentage=${discPercentage}   discMax=${discMax} 
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /provider/settings/jdn/enable    data=${data}  expected_status=any
    [Return]  ${resp}

Get JDN 
    Check and Create YNW Session
	${resp}=  GET On Session   ynw  /provider/settings/jdn  expected_status=any
	[return]  ${resp}

Disable JDN
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/jdn/disable  expected_status=any
    [Return]  ${resp}

Update JDN with Label
    [Arguments]    ${label}   ${displayNote}   
    ${data}=   Create Dictionary   label=${label}   displayNote=${displayNote}   
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    PUT On Session   ynw    /provider/settings/jdn    data=${data}  expected_status=any
    [Return]  ${resp}

Update JDN with Percentage
    [Arguments]    ${displayNote}   ${discPercentage}   ${discMax}   
    ${data}=   Create Dictionary   displayNote=${displayNote}   discPercentage=${discPercentage}   discMax=${discMax} 
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    PUT On Session   ynw   /provider/settings/jdn    data=${data}  expected_status=any
    [Return]  ${resp}

Join to Corporate
    [Arguments]  ${corpUid}  
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/corp/joinCorp/${corpUid}  expected_status=any
    [Return]  ${resp}

Switch To Corporate
    [Arguments]  ${corporateName}   ${corporateCode}    ${multilevel}  
    ${data}=  Create Dictionary   corporateName=${corporateName}    corporateCode=${corporateCode}   multilevel=${multilevel}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/corp/switchToCorp   data=${data}  expected_status=any
    [Return]  ${resp}

Branch User Creation
    [Arguments]  ${firstname}  ${lastname}   ${primaryMobileNo}   ${email}  ${subSector}   ${commonPassword}  ${departmentCode}   ${countryCode}=91
    ${usp}=    Create Dictionary   firstName=${firstname}  lastName=${lastname}   primaryMobileNo=${primaryMobileNo}  email=${email}  countryCode=${countryCode}
    ${data}=  Create Dictionary  userProfile=${usp}   subSector=${subSector}  commonPassword=${commonPassword}   departmentCode=${departmentCode}
    [Return]  ${data}

Create Branch SP
    [Arguments]  ${firstname}  ${lastname}   ${primaryMobileNo}  ${email}  ${subSector}  ${commonPassword}  ${departmentCode}
    ${data}=   Branch User Creation  ${firstname}  ${lastname}  ${primaryMobileNo}  ${email}  ${subSector}  ${commonPassword}  ${departmentCode}
    ${data}=   json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /provider/branch/createSp    data=${data}  expected_status=any
    [Return]  ${resp}

Create SP With Pseudo Corp and Branch
    [Arguments]  ${firstname}  ${lastname}   ${primaryMobileNo}  ${email}  ${subSector}  ${commonPassword}  ${departmentCode}
    ${data}=   Branch User Creation  ${firstname}  ${lastname}  ${primaryMobileNo}  ${email}  ${subSector}  ${commonPassword}  ${departmentCode}
    ${data}=   json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /provider/corp/createProvider     data=${data}  expected_status=any
    [Return]  ${resp}

Get Branch SP By Id
    [Arguments]   ${branch_id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/branch/${branch_id}/accounts   expected_status=any
    [Return]  ${resp}

Manage Branch SP 
    [Arguments]   ${branch_id}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/branch/manage/${branch_id}  expected_status=any
    [Return]  ${resp}

Create Consumer Notification Settings
    [Arguments]  ${resource_type}  ${event_type}  ${email}  ${sms}  ${push_notf}  ${common_msg}  ${persons_ahead}  &{kwargs}
    ${data}=  Create Dictionary  resourceType=${resource_type}  eventType=${event_type}  email=${email}  sms=${sms}  pushNotification=${push_notf}  commonMessage=${common_msg}  personsAhead=${persons_ahead}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=   json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /provider/consumerNotification/settings   data=${data}  expected_status=any
    [Return]  ${resp}

Get Consumer Notification Settings
    Check and Create YNW Session
	${resp}=  GET On Session   ynw  /provider/consumerNotification/settings   expected_status=any
	[return]  ${resp}


Get Notification Settings of Consumer By User
    [Arguments]  ${provider}
    Check and Create YNW Session
	${resp}=  GET On Session   ynw   /provider/consumerNotification/settings/provider/${provider}   expected_status=any
	[return]  ${resp}


Get Notification Settings of User
    [Arguments]  ${providerId}
    Check and Create YNW Session
	${resp}=  GET On Session   ynw   /provider/settings/notification/${providerId}   expected_status=any
	[return]  ${resp}


Update Consumer Notification Settings
    [Arguments]  ${resource_type}  ${event_type}  ${email}  ${sms}  ${push_notf}  ${common_msg}  ${persons_ahead}
    ${data}=  Create Dictionary  resourceType=${resource_type}  eventType=${event_type}  email=${email}  sms=${sms}  pushNotification=${push_notf}  commonMessage=${common_msg}  personsAhead=${persons_ahead}
    ${data}=   json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    PUT On Session   ynw    /provider/consumerNotification/settings   data=${data}  expected_status=any
    [Return]  ${resp}


Update Notification Settings of Consumer By User
    [Arguments]   ${u_id}  ${resource_type}  ${event_type}  ${email}  ${sms}  ${push_notf}  ${common_msg}  ${persons_ahead}
    ${data}=  Create Dictionary  resourceType=${resource_type}  eventType=${event_type}  email=${email}  sms=${sms}  pushNotification=${push_notf}  commonMessage=${common_msg}  personsAhead=${persons_ahead}  provider=${u_id}
    ${data}=   json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    PUT On Session   ynw    /provider/consumerNotification/settings/provider   data=${data}  expected_status=any
    [Return]  ${resp}


Update Notification Settings of User
    [Arguments]   ${u_id}  ${resource_type}  ${event_type}  ${sms}  ${email}  ${push_msg}
    ${data}=  Create Dictionary  resourceType=${resource_type}  eventType=${event_type}  sms=${sms}  email=${email}  pushMsg=${push_msg}  providerId=${u_id}
    ${data}=   json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    PUT On Session   ynw    /provider/settings/notification   data=${data}  expected_status=any
    [Return]  ${resp}


Consumer Mass Communication
    [Arguments]     ${cookie}  ${email}  ${sms}  ${push_notf}  ${telegram}  ${msg}   ${fileswithcaption}    @{vargs}
    ${input}=  Create Dictionary  email=${email}  sms=${sms}  pushNotification=${push_notf}  telegram=${telegram}
    ${data}=  Create Dictionary  medium=${input}  communicationMessage=${msg}  uuid=${vargs}
    ${resp}=    Imageupload.providerWLMassCom   ${cookie}     ${data}     @{fileswithcaption}
    [Return]  ${resp}


Create HowDoYouHearUs
    [Arguments]   ${phone}   ${scwtype}    ${sc_code}
    ${data}=  Create Dictionary  hearBy=${scwtype}    scCode=${sc_code}
    ${data}=   json.dumps    ${data}
    ${key}=   verify accnt    ${phone}   0
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw  /provider/${key}/howDoYouHear    data=${data}  expected_status=any
    [Return]  ${resp}

Get SalesChannel

    Check and Create YNW Session
	${resp}=  GET On Session   ynw   /provider/salesChannel  expected_status=any
	[return]  ${resp}

Get SalesChannelByID
    [Arguments]  ${scid}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/salesChannel/${scId}  expected_status=any
    [Return]  ${resp}

Locate consumer
    [Arguments]  ${waitlist_id}
    Check And Create YNW Session  
    ${resp}=    POST On Session    ynw  /provider/waitlist/live/locate/distance/time/${waitlist_id}   expected_status=any
    [Return]  ${resp}

Get Address using lat & long
    [Arguments]  ${lattitude}  ${longitude}
    ${data}=   Create Dictionary       latitude=${lattitude}   longitude=${longitude}
    ${data}=   json.dumps   ${data}
    Check And Create YNW Session  
    ${resp}=    POST On Session    ynw  /provider/signup/location   data=${data}  expected_status=any
    [Return]  ${resp}

Get Address from zipcode
    [Arguments]  ${pincode}
    ${data}=   Create Dictionary       pinCode=${pincode}
    ${data}=   json.dumps   ${data}
    Check And Create YNW Session  
    ${resp}=    POST On Session    ynw  /provider/signup/location/zipcode   data=${data}  expected_status=any
    [Return]  ${resp}

Get Address from city
    [Arguments]  ${city}
    ${citydict}=   Create Dictionary       city=${city}   
    ${data}=   Create Dictionary       city=${citydict}
    ${data}=   json.dumps   ${data}
    Check And Create YNW Session  
    ${resp}=    POST On Session    ynw  /provider/signup/location/address   data=${data}  expected_status=any
    [Return]  ${resp}


Add SalesChannel
    [Arguments]  ${sc_code}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw   /provider/salesChannel/${sc_code}   expected_status=any
    [Return]   ${resp}


Create StatusBoard Container
    [Arguments]  ${name}  ${dis_name}   ${layout}   ${interval}  @{sbid}
    ${sb}=   Create Dictionary   name=${name}   displayName=${dis_name}  layout=${layout}   interval=${interval}   sbIds=@{sbid}
    ${data}=   json.dumps    ${sb}
    Check And Create YNW Session
    ${resp}=   POST On Session   ynw   /provider/statusBoard/container   data=${data}  expected_status=any
    [Return]   ${resp}


Get SatusBoard Container
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/statusBoard/container   expected_status=any
    [Return]  ${resp}


Change SatusBoard Container
   [Arguments]    ${con_id}    ${name}   ${dis_name}   ${layout}   ${interval}   @{sbid}
   ${sb}=   Create Dictionary   name=${name}   displayName=${dis_name}  layout=${layout}   interval=${interval}   sbIds=@{sbid}
   ${data}=   json.dumps    ${sb}
   Check And Create YNW Session
   ${resp}=   PUT On Session   ynw   /provider/statusBoard/container/${con_id}   data=${data}  expected_status=any
   [Return]   ${resp}

    
Get StatusBoard Container ById
    [Arguments]   ${containerId}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/statusBoard/container/${containerId}   expected_status=any
    [Return]  ${resp}

Enable calling status Checkin
    [Arguments]  ${uid}    
    ${data}=   Create Dictionary       uid=${uid}
    ${data}=   json.dumps   ${data}
    Check And Create YNW Session  
    ${resp}=   PUT On Session   ynw   /provider/waitlist/callingStatus/${uid}/Enable   data=${data}  expected_status=any
    [Return]   ${resp}

Disable calling status Checkin
    [Arguments]  ${uid}    
    ${data}=   Create Dictionary       uid=${uid}
    ${data}=   json.dumps   ${data}
    Check And Create YNW Session  
    ${resp}=   PUT On Session   ynw   /provider/waitlist/callingStatus/${uid}/Disable   data=${data}  expected_status=any
    [Return]   ${resp}


Queue TimeInterval 
   [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  ${timeinterval}  ${appointment}  @{vargs}
   ${bs}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}
   ${location}=  Create Dictionary  id=${loc}
   ${len}=  Get Length  ${vargs}
   ${service}=  Create Dictionary  id=${vargs[0]}
   ${services}=  Create List  ${service}
   FOR    ${index}    IN RANGE  1  ${len}
        ${service}=  Create Dictionary  id=${vargs[${index}]} 
        Append To List  ${services}  ${service}
   END
   ${data}=  Create Dictionary  name=${name}  queueSchedule=${bs}   parallelServing=${parallel}  capacity=${capacity}  location=${location}  timeInterval=${timeinterval}  appointment=${appointment}  services=${services}
   [Return]  ${data}


Create Queue timeinterval
   [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  ${timeinterval}  ${appointment}  @{vargs}
   ${data}=  Queue TimeInterval  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  ${timeinterval}  ${appointment}  @{vargs}
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw  /provider/waitlist/queues  data=${data}  expected_status=any
   [Return]  ${resp}


Update Queue TimeInterval
    [Arguments]  ${qid}  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  ${timeinterval}  ${appointment}  @{vargs}   
    ${data}=  Queue TimeInterval  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc}  ${timeinterval}  ${appointment}  @{vargs}   
    Set To Dictionary  ${data}  id=${qid}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/waitlist/queues  data=${data}  expected_status=any
    [Return]  ${resp}
    
Enable Queue Appointment
    [Arguments]  ${queueId}
    Check And Create YNW Session  
    ${resp}=   PUT On Session   ynw   /provider/waitlist/queues/appointment/Enable/${queueId}  expected_status=any
    [Return]   ${resp}

Disable Queue Appointment
    [Arguments]  ${queueId}
    Check And Create YNW Session   
    ${resp}=   PUT On Session   ynw   /provider/waitlist/queues/appointment/Disable/${queueId}  expected_status=any
    [Return]   ${resp}

Enable OnlinePresence
    Check And Create YNW Session  
    ${resp}=   PUT On Session   ynw   /provider/onlinePresence/Enable  expected_status=any
    [Return]   ${resp}

Disable OnlinePresence
    Check And Create YNW Session  
    ${resp}=   PUT On Session   ynw   /provider/onlinePresence/Disable  expected_status=any
    [Return]   ${resp}

Get OnlinePresence
    Check And Create YNW Session  
    ${resp}=   GET On Session   ynw   /provider/account/settings  expected_status=any
    [Return]   ${resp}

Post CustomID
    [Arguments]  ${customId}
    Check And Create YNW Session  
    ${resp}=   POST On Session   ynw   /provider/business/${customId}  expected_status=any
    [Return]   ${resp}
    

Get CustomID
    [Arguments]  ${customId}
    Check And Create YNW Session  
    ${resp}=   POST On Session   ynw   /provider/business/${customId}  expected_status=any
    [Return]   ${resp}


Change StatusBoard Status
    [Arguments]  ${id}  ${status}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/statusBoard/dimension/${id}/${status}  expected_status=any
    [Return]  ${resp}

Create User
    [Arguments]  ${fname}  ${lname}  ${dob}  ${gender}  ${email}  ${user_type}  ${pincode}  ${countryCode}  ${mob_no}  ${dept_id}  ${sub_domain}  ${admin}  ${whatsApp_countrycode}  ${WhatsApp_num}  ${telegram_countrycode}  ${telegram_num}   @{vargs} 
    ${whatsAppNum}=  Create Dictionary  countryCode=${whatsApp_countrycode}  number=${WhatsApp_num}
    ${telegramNum}=  Create Dictionary  countryCode=${telegram_countrycode}  number=${telegram_num}
    ${data}=  Create Dictionary  firstName=${fname}  lastName=${lname}  dob=${dob}  gender=${gender}  email=${email}  userType=${user_type}  pincode=${pincode}  countryCode=${countryCode}  mobileNo=${mob_no}  deptId=${dept_id}  subdomain=${sub_domain}  admin=${admin}  whatsAppNum=${whatsAppNum}  telegramNum=${telegramNum}
    FOR  ${key}  ${value}  IN  @{vargs} 
            Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/user    data=${data}  expected_status=any
    [Return]  ${resp}

Update User
    [Arguments]  ${id}  ${fname}  ${lname}  ${dob}  ${gender}  ${email}  ${user_type}  ${pincode}  ${countryCode}  ${mob_no}  ${dept_id}  ${sub_domain}  ${admin}  ${whatsApp_countrycode}  ${WhatsApp_num}  ${telegram_countrycode}  ${telegram_num}    &{kwargs}
    ${whatsAppNum}=   Create Dictionary  countryCode=${whatsApp_countrycode}  number=${WhatsApp_num}
    ${telegramNum}=  Create Dictionary  countryCode=${telegram_countrycode}  number=${telegram_num}
    ${data}=  Create Dictionary  firstName=${fname}  lastName=${lname}  dob=${dob}  gender=${gender}  email=${email}  userType=${user_type}  pincode=${pincode}  countryCode=${countryCode}  mobileNo=${mob_no}  deptId=${dept_id}  subdomain=${sub_domain}  admin=${admin}  whatsAppNum=${whatsAppNum}  telegramNum=${telegramNum}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/user/${id}   data=${data}  expected_status=any
    [Return]  ${resp}        
    
Get User
    [Arguments]  &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/user   params=${kwargs}  expected_status=any
    [Return]  ${resp}

Get User By Id
    [Arguments]  ${id}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/user/${id}   expected_status=any
    [Return]  ${resp}

Get User Count
    [Arguments]  &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/user/count   params=${kwargs}  expected_status=any
    [Return]  ${resp}

EnableDisable User
    [Arguments]  ${id}  ${status}
    Check And Create YNW Session
    ${resp}=    PUT On Session     ynw   /provider/user/${status}/${id}   expected_status=any
    [Return]  ${resp}

Update Domain_Level Of User
     [Arguments]   ${data}  ${u_id}
     ${data}=    json.dumps    ${data}
     Check And Create YNW Session
     ${resp}=  PUT On Session  ynw  /provider/user/providerBprofile/domain/${u_id}  data=${data}  expected_status=any
     [Return]  ${resp}

Update Sub_Domain_Level Of User
     [Arguments]   ${data}  ${sub_domain_id}  ${u_id}
     ${data}=    json.dumps    ${data}
     Check And Create YNW Session
     ${resp}=  PUT On Session  ynw  /provider/user/providerBprofile/${sub_domain_id}/${u_id}  data=${data}  expected_status=any
     [Return]  ${resp}

User Profile Creation
    [Arguments]  ${b_name}  ${b_desc}  ${spec}  ${lan}  ${sub_domain}  ${id}
    Check And Create YNW Session
    ${data}=  Create Dictionary  businessName=${b_name}  businessDesc=${b_desc}  specialization=${spec}  languagesSpoken=${lan}  userSubdomain=${sub_domain}
    ${data}=    json.dumps    ${data}
    ${resp}=  PATCH On Session  ynw  /provider/user/providerBprofile/${id}  data=${data}  expected_status=any
    [Return]  ${resp}

Get User Profile
    [Arguments]  ${id}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/user/providerBprofile/${id}   expected_status=any  
    [Return]  ${resp}

User Profile Updation
    [Arguments]  ${b_name}  ${b_desc}  ${spec}  ${lan}  ${sub_domain}  ${id}
    Check And Create YNW Session
    ${data}=  Create Dictionary  businessName=${b_name}  businessDesc=${b_desc}  specialization=${spec}  languagesSpoken=${lan}  userSubdomain=${sub_domain}
    ${data}=    json.dumps    ${data}
    ${resp}=  PUT On Session  ynw  /provider/user/providerBprofile/${id}  data=${data}  expected_status=any
    [Return]  ${resp}

Link Profile
    [Arguments]  ${p_id}  ${u_pro_id}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/user/providerBprofile/linkProfile/${p_id}/${u_pro_id}   expected_status=any
    [Return]  ${resp}

Update SocialMedia Of User
    [Arguments]  ${id}  @{data}    
    ${data}=  Create Dictionary  socialMedia=${data}                                                                                                                                            
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session 
    ${resp}=  PUT On Session  ynw  /provider/user/providerBprofile/socialMedia/${id}  data=${data}  expected_status=any
    [Return]  ${resp}

Get Users By Department
    [Arguments]  ${d_id}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/user/providerByDepartmentId/${d_id}   expected_status=any  
    [Return]  ${resp}

Create educational qualification
    [Arguments]    ${sts}   ${u_id}    ${gender}    @{vargs}     

    ${len}=  Get Length  ${vargs}

    ${educationalqualifications}=    Create List 

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${educationalqualifications}   ${vargs[${index}]}
    END

    ${eduqua}=     Create Dictionary      educationalqualifications=${educationalqualifications}     gender=${gender} 

    ${data}=   json.dumps  ${eduqua}
    Check And Create YNW Session
    ${resp}=    PUT On Session     ynw    /provider/user/providerBprofile/${sts}/${u_id}     data=${data}   expected_status=any
    [Return]  ${resp}
    

Get Locations By UserId

    [Arguments]    ${userid}   &{kwargs}
    ${pro_headers}=  Create Dictionary  &{headers}
    ${pro_params}=   Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${pro_headers}   &{tzheaders}
    Set To Dictionary  ${pro_params}   &{locparam}
    Check And Create YNW Session
    ${resp}=    Get On Session    ynw    provider/user/${userid}/location       params=${pro_params}   expected_status=any  
    [Return]  ${resp}   


Update User Search Status
    [Arguments]  ${sts}  ${u_id}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/user/search/${sts}/${u_id}   expected_status=any
    [Return]  ${resp}

Get User Search Status
    [Arguments]  ${u_id}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/user/search/${u_id}   expected_status=any  
    [Return]  ${resp}

Create Team For User
    [Arguments]  ${name}  ${team_size}  ${desc}
    Check And Create YNW Session
    ${data}=  Create Dictionary  name=${name}  size=${team_size}  description=${desc}
    ${data}=  json.dumps  ${data}
    ${resp}=  POST On Session  ynw  /provider/user/team   data=${data}  expected_status=any
    [Return]  ${resp}

Update Team For User
    [Arguments]  ${team_id}  ${name}  ${team_size}  ${desc}
    Check And Create YNW Session
    ${data}=  Create Dictionary  name=${name}  size=${team_size}  description=${desc}
    ${data}=  json.dumps  ${data}
    ${resp}=  PUT On Session  ynw  /provider/user/team/${team_id}   data=${data}  expected_status=any
    [Return]  ${resp}

Get Team By Id
    [Arguments]  ${t_id}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/user/team/${t_id}   expected_status=any  
    [Return]  ${resp}

Get Teams
    [Arguments]  &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/user/team   params=${kwargs}  expected_status=any
    [Return]  ${resp}

Activate&Deactivate Team
    [Arguments]  ${team_id}  ${status}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/user/team/${team_id}/${status}     expected_status=any
    [Return]  ${resp}

Get User Stat Count
    [Arguments]  &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/report/user   params=${kwargs}  expected_status=any
    [Return]  ${resp}

Get User Stat Details
    [Arguments]  &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/report/user/info   params=${kwargs}  expected_status=any
    [Return]  ${resp}

Assign Business_loc To User
    [Arguments]  ${userIds}  @{bussLocations} 
    ${data}=  Create Dictionary    userIds=${userIds}  bussLocations=${bussLocations}                                                                                                                                   
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session 
    ${resp}=  PUT On Session  ynw  /provider/user/updateBusinessLoc  data=${data}  expected_status=any
    [Return]  ${resp}

Assign Team To User
    [Arguments]  ${user_ids}  @{data}    
    ${data}=  Create Dictionary  userIds=${user_ids}   teams=${data}                                                                                                                                
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session 
    ${resp}=  PUT On Session  ynw  /provider/user/updateTeam  data=${data}  expected_status=any
    [Return]  ${resp}

InternalStatuses_permissions
    [Arguments]  ${user_ids}  ${rols}  @{data}    
    ${data}=  Create Dictionary  users=${user_ids}  roles=${rols}   teams=${data}                                                                                                                        
    [Return]  ${data}

Create_InternalStatus
    [Arguments]  ${id}  ${dis_name}  ${sers}  ${dis_order}  ${prev_sts}  ${perm}
    ${data}=  Create Dictionary  id=${id}  displayName=${dis_name}  services=${sers}  displayOrder=${dis_order}  prevStatuses=${prev_sts}  permissions=${perm}
    [Return]  ${data}

Setting InternalStatuses
    [Arguments]  @{kwargs}
    Log  ${kwargs}
    ${data1}=  Create Dictionary  status=${kwargs}
    ${data}=  Create Dictionary  internalStatus=${data1}
    [Return]  ${data}

Internal_UserAccessScope_Json
    [Arguments]  ${internal_data}  ${userscope_data}
    ${data}=  Create Dictionary
    Set to Dictionary      ${data}    internalStatus=${internal_data['internalStatus']}
    Set to Dictionary      ${data}    userAccessScope=${userscope_data['userAccessScope']}
    [Return]  ${data}

Get InternalStatuses by uid
    [Arguments]  ${uid}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/waitlist/internalStatuses/${uid}   expected_status=any
    [Return]  ${resp}

Waitlist Apply Internal Status
    [Arguments]  ${uid}  ${internal_sts}
    Check And Create YNW Session
    ${resp}=    PUT On Session     ynw   /provider/waitlist/applyInternalStatus/${uid}/${internal_sts}   expected_status=any
    [Return]  ${resp}

Appointment Apply Internal Status
    [Arguments]  ${uid}  ${internal_sts}
    Check And Create YNW Session
    ${resp}=    PUT On Session     ynw   /provider/appointment/applyInternalStatus/${uid}/${internal_sts}   expected_status=any
    [Return]  ${resp}

Get Waitlist Internal Sts ActivityLog
    [Arguments]  ${uid}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/waitlist/internalStatuses/log/${uid}   expected_status=any
    [Return]  ${resp}

Get Appointment Internal Sts ActivityLog
    [Arguments]  ${uid}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/appointment/internalStatuses/log/${uid}   expected_status=any
    [Return]  ${resp}

Generate Invoice
   Check And Create YNW Session
   ${resp}=    PUT On Session    ynw  /provider/license/subscription    expected_status=any  
   [Return]  ${resp} 


Generate Report REST details  
    [Arguments]  ${reportType}  ${reportDateCategory}  ${filter}
    ${data}=  create Dictionary  reportType=${reportType}  reportDateCategory=${reportDateCategory}   filter=${filter}  responseType=INLINE
    ${jdata}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/report   data=${jdata}  expected_status=any
    [Return]  ${resp}


Save Report Criteria
    [Arguments]  ${reportName}  ${reportType}  ${reportDateCategory}  ${filter}
    ${data}=  create Dictionary  reportName=${reportName}   reportType=${reportType}  reportDateCategory=${reportDateCategory}
    Set To Dictionary  ${data}  filter=${filter}
    ${jdata}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/report/ops    data=${jdata}  expected_status=any
    [Return]  ${resp}


Update Report Criteria
    [Arguments]  ${reportName}  ${reportType}  ${reportDateCategory}  ${filter}
    ${data}=  create Dictionary  reportName=${reportName}   reportType=${reportType}  reportDateCategory=${reportDateCategory}
    Set To Dictionary  ${data}  filter=${filter}
    ${jdata}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/report/ops    data=${jdata}  expected_status=any
    [Return]  ${resp}


Get Report Criteria
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/report/criteria   expected_status=any  
    [Return]  ${resp}


Delete Report Criteria
    [Arguments]  ${reportName}  ${reportType}
    ${data}=  create Dictionary  reportName=${reportName}   reportType=${reportType}  
    ${jdata}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=    DELETE On Session    ynw  /provider/report/ops    data=${jdata}  expected_status=any
    [Return]  ${resp}


Appointment Status
    [Arguments]  ${status}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/account/settings/appointment/${status}  expected_status=any
    [Return]  ${resp}

JaldeeId Format  
    [Arguments]  ${customerseries}  ${prefi}  ${sufi}
    ${data}=  create Dictionary  prefix=${prefi}  suffix=${sufi}
    ${jdata}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/account/settings/jaldeeIdFormat/${customerseries}   data=${jdata}  expected_status=any
    [Return]  ${resp}

Account Settings
    [Arguments]  ${enasms}  ${jinten}  ${custserenum}  ${prefi}  ${sufi}
    ${patsetting}=  Create Dictionary  prefix=${prefi}    suffix=${sufi}
    ${data}=  create Dictionary  enableSms=${enasms}   jaldeeIntegration=${jinten}  customerSeriesEnum=${custserenum}   patternSettings=${patsetting}
    ${jdata}=  json.dumps  ${data}
    Check And Create YNW Session
    ${response}=  POST On Session  ynw  /provider/account/settings  data=${jdata}  expected_status=any
    [Return]  ${response}

Update Accountsettings 
    [Arguments]  ${enasms}  ${jinten}  ${custserenum}  ${prefi}  ${sufi}
    ${patsetting}=  Create Dictionary  prefix=${prefi}    suffix=${sufi}
    ${data}=  create Dictionary  enableSms=${enasms}   jaldeeIntegration=${jinten}  customerSeriesEnum=${custserenum}   patternSettings=${patsetting}
    ${jdata}=  json.dumps  ${data}
    Check And Create YNW Session
    ${response}=  PUT On Session  ynw  /provider/account/settings  data=${jdata}  expected_status=any
    [Return]  ${response}

Get Accountsettings
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/account/settings  expected_status=any
    [Return]  ${resp}

Sms Status
    [Arguments]  ${status}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/account/settings/sms/${status}  expected_status=any
    [Return]  ${resp}

Get Sms Count
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/account/settings/smsCount  expected_status=any
    [Return]  ${resp}

Waitlist Status
    [Arguments]  ${status}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/account/settings/waitlist/${status}  expected_status=any
    [Return]  ${resp}

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
    [Return]  ${data}

Create Appointment Schedule
    [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}   ${consumerParallelServing}    ${loc}  ${timeduration}  ${batch}  @{vargs}
    ${data}=  Appointment Schedule  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}    ${consumerParallelServing}   ${loc}  ${timeduration}  ${batch}  @{vargs}
    Check And Create YNW Session
    ${data}=  json.dumps  ${data}
    ${resp}=  POST On Session  ynw  /provider/appointment/schedule  data=${data}  expected_status=any
    [Return]  ${resp}

Create Appointment Schedule For User
    [Arguments]  ${userid}  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}    ${consumerParallelServing}   ${loc}  ${timeduration}  ${batch}  @{vargs}
    ${user_id}=  Create Dictionary  id=${userid}
    ${data}=  Appointment Schedule  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}    ${consumerParallelServing}   ${loc}  ${timeduration}  ${batch}  @{vargs}
    Set To Dictionary  ${data}  provider=${user_id}
    Check And Create YNW Session
    ${data}=  json.dumps  ${data}
    ${resp}=  POST On Session  ynw  /provider/appointment/schedule  data=${data}  expected_status=any
    [Return]  ${resp}


Get Appointment Schedule ById
    [Arguments]   ${schId}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/appointment/schedule/${schId}   expected_status=any
    [Return]  ${resp}

Enable Appointment Schedule
    [Arguments]   ${schId}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/appointment/schedule/${schId}/ENABLED   expected_status=any
    [Return]  ${resp}

Disable Appointment Schedule
    [Arguments]   ${schId}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/appointment/schedule/${schId}/DISABLED   expected_status=any
    [Return]  ${resp}
    
Get Appointment Schedules
    [Arguments]  &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/appointment/schedule  params=${kwargs}  expected_status=any
    [Return]  ${resp}

# Get Appointment Slots By Date Schedule
#     [Arguments]    ${scheduleId}   ${date}
#     Check And Create YNW Session
#     ${resp}=  GET On Session  ynw  /provider/appointment/schedule/${scheduleId}/${date}  expected_status=any
#     [Return]  ${resp}

Get Appointment Slots By Date Schedule
    [Arguments]    ${scheduleId}   ${date}   ${service}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/appointment/schedule/${scheduleId}/${date}/${service}   expected_status=any
    [Return]  ${resp}

Get Next Available Appointment Slot
    [Arguments]   ${schId}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/appointment/schedule/nextAvailableTime  expected_status=any
    [Return]  ${resp}

Get Next Available Appointment Schedule
    [Arguments]   ${schId}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/appointment/schedule/nextAvailable/${schId}  expected_status=any
    [Return]  ${resp}

Get Appointment Schedule by location and service
	[Arguments]	 ${locationId}	${serviceId}
	Check And Create YNW Session
	${resp}=  GET On Session  ynw  /provider/appointment/schedule/location/${locationId}/service/${serviceId}  expected_status=any
	[Return]   ${resp}

Get Appointment Schedule by date
	[Arguments]	 ${date}
	Check And Create YNW Session
	${resp}=  GET On Session  ynw  /provider/appointment/schedule/date/${date}  expected_status=any
	[Return]   ${resp}


Update Appointment Schedule
    [Arguments]  ${Id}  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}    ${consumerParallelServing}   ${loc}  ${timeduration}  ${batch}  @{vargs}
    ${data}=  Appointment Schedule  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${parallel}    ${consumerParallelServing}   ${loc}  ${timeduration}  ${batch}  @{vargs}
    Set To Dictionary  ${data}  id=${Id}
    Check And Create YNW Session
    ${data}=  json.dumps  ${data}
    ${resp}=  PUT On Session  ynw  /provider/appointment/schedule  data=${data}  expected_status=any
    [Return]  ${resp}
    

Create CustomeView
	[Arguments]    ${name}  ${merged}  ${departmentId}  ${serviceId}  ${queuesId}  ${usersId}  ${type}
	${len}=  Get Length  ${departmentId}
	${department_L}=  Create List
	FOR    ${index}   IN RANGE   0  ${len}
        ${A}=  Create Dictionary  departmentId=${departmentId[${index}]}
        Append To List  ${department_L}  ${A}
    END
   	
	${len}=  Get Length  ${serviceId}
	${services_L}=  Create List
	FOR    ${index}   IN RANGE   0  ${len}
        ${B}=  Create Dictionary  id=${serviceId[${index}]}
        Append To List  ${services_L}  ${B}
    END
       
    ${len}=  Get Length  ${queuesId}
	${queues_L}=  Create List
	FOR    ${index}   IN RANGE   0  ${len}
        ${C}=  Create Dictionary  id=${queuesId[${index}]}
        Append To List  ${queues_L}  ${C}
    END
       
    ${len}=  Get Length  ${usersId}
	${users_L}=  Create List
	FOR    ${index}   IN RANGE   0  ${len}
        ${D}=  Create Dictionary  id=${usersId[${index}]}
        Append To List  ${users_L}  ${D}
    END
	${cv}=  Create Dictionary  departments=${department_L}  services=${services_L}  queues=${queues_L}  users=${users_L}  
	${data}=  Create Dictionary   name=${name}  merged=${merged}  customViewConditions=${cv}  type=${type}
	${data}=  json.dumps  ${data}	
	Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/customView   data=${data}  expected_status=any
    [Return]  ${resp}
   

Create CustomeView Appointment
	[Arguments]    ${name}  ${merged}  ${departmentId}  ${serviceId}   ${usersId}   ${Scheduleid}   ${type}
	${len}=  Get Length  ${departmentId}
	${department_L}=  Create List
	FOR    ${index}   IN RANGE   0  ${len}
        ${A}=  Create Dictionary  departmentId=${departmentId[${index}]}
        Append To List  ${department_L}  ${A}
    END
   	
	${len}=  Get Length  ${serviceId}
	${services_L}=  Create List
	FOR    ${index}   IN RANGE   0  ${len}
        ${B}=  Create Dictionary  id=${serviceId[${index}]}
        Append To List  ${services_L}  ${B}
    END
       
    ${len}=  Get Length  ${usersId}
	${users_L}=  Create List
	FOR    ${index}   IN RANGE   0  ${len}
        ${D}=  Create Dictionary  id=${usersId[${index}]}
        Append To List  ${users_L}  ${D}
    END

    ${len}=  Get Length  ${Scheduleid}
	${sched_L}=  Create List
	FOR    ${index}   IN RANGE   0  ${len}
        ${C}=  Create Dictionary  id=${Scheduleid[${index}]}
        Append To List  ${sched_L}  ${C}
    END
       
	${cv}=  Create Dictionary  departments=${department_L}  services=${services_L}   users=${users_L}  schedules=${sched_L}  
	${data}=  Create Dictionary   name=${name}  merged=${merged}  customViewConditions=${cv}  type=${type}
	${data}=  json.dumps  ${data}	
	Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/customView   data=${data}  expected_status=any
    [Return]  ${resp}

Update CustomeView Appointment
	[Arguments]   ${id}   ${name}  ${merged}  ${departmentId}  ${serviceId}   ${usersId}   ${Scheduleid}   ${type}
	${len}=  Get Length  ${departmentId}
	${department_L}=  Create List
	FOR    ${index}   IN RANGE   0  ${len}
        ${A}=  Create Dictionary  departmentId=${departmentId[${index}]}
        Append To List  ${department_L}  ${A}
    END
   	
	${len}=  Get Length  ${serviceId}
	${services_L}=  Create List
	FOR    ${index}   IN RANGE   0  ${len}
        ${B}=  Create Dictionary  id=${serviceId[${index}]}
        Append To List  ${services_L}  ${B}
    END
       
    ${len}=  Get Length  ${usersId}
	${users_L}=  Create List
	FOR    ${index}   IN RANGE   0  ${len}
        ${D}=  Create Dictionary  id=${usersId[${index}]}
        Append To List  ${users_L}  ${D}
    END

    ${len}=  Get Length  ${Scheduleid}
	${sched_L}=  Create List
	FOR    ${index}   IN RANGE   0  ${len}
        ${C}=  Create Dictionary  id=${Scheduleid[${index}]}
        Append To List  ${sched_L}  ${C}
    END
       
    
	${cv}=  Create Dictionary  departments=${department_L}  services=${services_L}   users=${users_L}  schedules=${sched_L}  
	${data}=  Create Dictionary   name=${name}  merged=${merged}  customViewConditions=${cv}  type=${type}
	${data}=  json.dumps  ${data}	
	Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/customView/${id}  data=${data}  expected_status=any
    [Return]  ${resp}


Update CustomeView
	[Arguments]    ${id}  ${name}  ${merged}  ${departmentId}  ${serviceId}  ${queuesId}  ${usersId}  ${type}
	${len}=  Get Length  ${departmentId}
	${department_L}=  Create List
	FOR    ${index}   IN RANGE   0  ${len}
        ${A}=  Create Dictionary  departmentId=${departmentId[${index}]}
        Append To List  ${department_L}  ${A}
    END
   	
	${len}=  Get Length  ${serviceId}
	${services_L}=  Create List
	FOR    ${index}   IN RANGE   0  ${len}
        ${B}=  Create Dictionary  id=${serviceId[${index}]}
        Append To List  ${services_L}  ${B}
    END
       
    ${len}=  Get Length  ${queuesId}
	${queues_L}=  Create List
	FOR    ${index}   IN RANGE   0  ${len}
        ${C}=  Create Dictionary  id=${queuesId[${index}]}
        Append To List  ${queues_L}  ${C}
    END
       
    ${len}=  Get Length  ${usersId}
	${users_L}=  Create List
	FOR    ${index}   IN RANGE   0  ${len}
        ${D}=  Create Dictionary  id=${usersId[${index}]}
        Append To List  ${users_L}  ${D}
    END
	${cv}=  Create Dictionary  departments=${department_L}  services=${services_L}  queues=${queues_L}  users=${users_L}  
	
	${data}=  Create Dictionary   id=${id}  name=${name}  merged=${merged}  customViewConditions=${cv}  type=${type}
	${data}=  json.dumps  ${data}	
	Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/customView/${id}   data=${data}  expected_status=any
    [Return]  ${resp}


Get CustomeView By Id
    [Arguments]  ${id}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/customView/${id}   expected_status=any
    [Return]  ${resp}


Get CustomeView
	[Arguments]    &{kwargs}	
	Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/customView   params=${kwargs}  expected_status=any
    [Return]  ${resp}


Delete CustomeView
    [Arguments]  ${id}
    Check And Create YNW Session
    ${resp}=    DELETE On Session     ynw   /provider/customView/${id}   expected_status=any
    [Return]  ${resp}


Enable Waitlist Batch
    [Arguments]   ${queueId} 
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  /provider/waitlist/queues/batch/${queueId}/true  expected_status=any
    [Return]  ${resp}


Disable Waitlist Batch
    [Arguments]   ${queueId}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  /provider/waitlist/queues/batch/${queueId}/false  expected_status=any
    [Return]  ${resp}

Add Batch Name
    [Arguments]   ${queueId}  ${prefix}  ${suffix}
    Check And Create YNW Session
    ${data}=   Create Dictionary   prefix=${prefix}   suffix=${suffix}
    ${data}=    json.dumps    ${data}
    ${resp}=    PUT On Session    ynw  /provider/waitlist/queues/batch/pattern/${queueId}  data=${data}  expected_status=any
    [Return]  ${resp}


Enable Disbale Global Livetrack
    [Arguments]   ${status}  
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  /provider/account/settings/livetrack/${status}  expected_status=any
    [Return]  ${resp}


Enable Disbale Service Livetrack
    [Arguments]   ${serviceId}   ${status}  
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  /provider/services/livetrack/${status}/${serviceId}  expected_status=any
    [Return]  ${resp}
    
Create StatusBoardnew
    [Arguments]  ${name}  ${displayname}  ${layout}  ${serviceRoom}  ${status}  ${container}  ${metric_list}  ${intervel}  ${title1}  ${title2}  ${title3}  ${title11}
    ${headerSettings}=  Create Dictionary   title1=${title1}  title2=${title2}  title3=${title3} 
    ${footerSettings}=  Create Dictionary   title1=${title11} 
    ${dic}=  Create Dictionary  name=${name}  displayName=${displayname}  layout=${layout}  serviceRoom=${serviceRoom}  status=${status}  container=${container}  metric=${metric_list}  intervalTime=${intervel}  headerSettings=${headerSettings}  footerSettings=${footerSettings}
    # ${data}=  Create List  ${dic}
    ${data}=  json.dumps  ${dic}
    Check And Create YNW Session
    ${resp}=  POST On Session   ynw   /provider/statusBoard/dimension   data=${data}  expected_status=any 
    [Return]  ${resp}


DonationFundRaising flag
    [Arguments]  ${status}
    Check And Create YNW Session
    ${resp}=  PUT On Session   ynw   /provider/account/settings/donationFundRaising/${status}   expected_status=any 
    [Return]  ${resp}


Create Donation Service
    [Arguments]  ${name}  ${desc}  ${durtn}  ${bType}  ${notfcn}  ${notiTp}  ${totalAmount}  
    ...  ${isPrePayment}  ${taxable}  ${service_type}  ${min_don_amt}  ${max_don_amt}  
    ...   ${multiples}  &{kwargs}
    ${items}=  Get Dictionary items  ${kwargs}
    ${data}=  Create Dictionary  name=${name}  description=${desc}  serviceDuration=${durtn}  notification=${notfcn}  notificationType=${notiTp}   totalAmount=${totalAmount}   bType=${btype}  isPrePayment=${isPrePayment}  taxable=${taxable}  serviceType=${service_type}  minDonationAmount=${min_don_amt}  maxDonationAmount=${max_don_amt}  multiples=${multiples}
    FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session  
    ${resp}=  POST On Session  ynw  /provider/services  data=${data}  expected_status=any
    [Return]  ${resp}


Get Donation By Id
    [Arguments]  ${d_id}
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /provider/donation/${d_id}   expected_status=any
    [Return]  ${resp}


Get Donations
    [Arguments]    &{kwargs}
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /provider/donation   params=${kwargs}  expected_status=any
    [Return]  ${resp}


Get Donation Count
    [Arguments]    &{kwargs}
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /provider/donation/count  params=${kwargs}  expected_status=any
    [Return]  ${resp}


Set jaldeeIntegration Settings
    [Arguments]  ${onlinePresence}  ${walkinCon}  ${consumerapp}
    ${data}=  Create Dictionary  onlinePresence=${onlinePresence}  walkinConsumerBecomesJdCons=${walkinCon}   consumerApp=${consumerapp}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session   ynw  /provider/account/settings/jaldeeIntegration    data=${data}  expected_status=any 
    [Return]  ${resp}


Get jaldeeIntegration Settings
    
    Check And Create YNW Session 
    ${resp}=  GET On Session  ynw   /provider/account/settings/jaldeeIntegrationSettings  expected_status=any
    [Return]  ${resp}
    

User Take Appointment For Consumer 
    [Arguments]   ${userid}  ${consid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${appmtFor}  &{kwargs}
    
    ${pro_headers}=  Create Dictionary  &{headers}
    ${pro_params}=   Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${pro_headers}   &{tzheaders}
    Set To Dictionary  ${pro_params}   &{locparam}

    ${user_id}=  Create Dictionary  id=${userid}
    ${cid}=  Create Dictionary  id=${consid}
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}
    ${data}=    Create Dictionary   provider=${user_id}  consumer=${cid}  service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}
    # ${data}=    Create Dictionary   appointmentMode=WALK_IN_APPOINTMENT  consumer=${cid}  service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/appointment  params=${pro_params}  data=${data}  expected_status=any
    [Return]  ${resp}


Take Appointment For Consumer 
    [Arguments]   ${consid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${appmtFor}  &{kwargs}
    
    ${pro_headers}=  Create Dictionary  &{headers}
    ${pro_params}=   Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${pro_headers}   &{tzheaders}
    Set To Dictionary  ${pro_params}   &{locparam}
    
    ${cid}=  Create Dictionary  id=${consid}
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}
    ${data}=    Create Dictionary   consumer=${cid}  service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}
    # ${data}=    Create Dictionary   appointmentMode=WALK_IN_APPOINTMENT  consumer=${cid}  service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/appointment  params=${pro_params}    data=${data}  expected_status=any
    [Return]  ${resp}


Take Appointment with Phone no
    [Arguments]   ${consid}  ${service_id}  ${schedule}  ${appmtDate}  ${phoneNumber}  ${country_code}  ${appmtFor}
    ${cid}=  Create Dictionary  id=${consid}
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}
    ${data}=    Create Dictionary   consumer=${cid}  service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  phoneNumber=${phoneNumber}  countryCode=${country_code}
    # ${data}=    Create Dictionary   appointmentMode=WALK_IN_APPOINTMENT  consumer=${cid}  service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/appointment  data=${data}  expected_status=any
    [Return]  ${resp}


Take Virtual Service Appointment For Consumer
    [Arguments]   ${consid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${CallingModes}  ${CallingModes_id1}  ${appmtFor}
    ${cid}=  Create Dictionary  id=${consid}
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}
    ${virtualService}=  Create Dictionary   ${CallingModes}=${CallingModes_id1}
    ${data}=    Create Dictionary   consumer=${cid}  service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}   virtualService=${virtualService}
    # ${data}=    Create Dictionary   appointmentMode=WALK_IN_APPOINTMENT  consumer=${cid}  service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/appointment  data=${data}  expected_status=any
    [Return]  ${resp}

Take Virtual Service Appointment For Consumer with Mode
    [Arguments]   ${apptMode}  ${consid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${CallingModes}  ${CallingModes_id1}  ${appmtFor}
    ${cid}=  Create Dictionary  id=${consid}
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}
    ${virtualService}=  Create Dictionary   ${CallingModes}=${CallingModes_id1}
    ${data}=    Create Dictionary   appointmentMode=${apptMode}  consumer=${cid}  service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}   virtualService=${virtualService}
    # ${data}=    Create Dictionary   appointmentMode=WALK_IN_APPOINTMENT  consumer=${cid}  service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/appointment  data=${data}  expected_status=any
    [Return]  ${resp}

Take Appointment with Appointment Mode 
    [Arguments]   ${apptMode}   ${consid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${appmtFor}
    ${cid}=  Create Dictionary  id=${consid}
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}
    ${data}=    Create Dictionary  appointmentMode=${apptMode}  consumer=${cid}  service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/appointment  data=${data}  expected_status=any
    [Return]  ${resp}

User Take Appointment with Appointment Mode 
    [Arguments]   ${userid}  ${apptMode}   ${consid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${appmtFor}
    ${user_id}=  Create Dictionary  id=${userid}
    ${cid}=  Create Dictionary  id=${consid}
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}
    ${data}=    Create Dictionary  provider=${user_id}  appointmentMode=${apptMode}  consumer=${cid}  service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/appointment  data=${data}  expected_status=any
    [Return]  ${resp}

Get Appointment By Id
    [Arguments]  ${appmntId}
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /provider/appointment/${appmntId}  expected_status=any
    [Return]  ${resp}
    
Get Waitlist EncodedId
    [Arguments]    ${W_Enc_id}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/waitlist/encId/${W_Enc_id}   expected_status=any
    [Return]  ${resp}
    
Get Waitlist By EncodedID
    [Arguments]    ${Enc_id}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/waitlist/enc/${Enc_id}   expected_status=any
    [Return]  ${resp}
    
Get Appointment EncodedID
    [Arguments]    ${uuid}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/appointment/encId/${uuid}   expected_status=any
    [Return]  ${resp}

Get Appointment By EncodedId
    [Arguments]    ${encId}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/appointment/enc/${encId}   expected_status=any
    [Return]  ${resp}    

Provider Cancel Appointment
    [Arguments]  ${appmntId}  ${cancelReason}  ${message}   ${date}
    ${data}=  Create Dictionary  cancelReason=${cancelReason}  communicationMessage=${message}   date=${date}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session   ynw  /provider/appointment/statuschange/Cancelled/${appmntId}    data=${data}  expected_status=any 
    [Return]  ${resp}

Reject Appointment
    [Arguments]  ${appmntId}  ${rejectReason}  ${message}   ${date}  
    ${data}=  Create Dictionary  communicationMessage=${message}   date=${date}   rejectReason=${rejectReason}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session   ynw  /provider/appointment/statuschange/Rejected/${appmntId}    data=${data}  expected_status=any 
    [Return]  ${resp}
    
Appointment Action 
    [Arguments]   ${status}   ${appmntId}   
    Check And Create YNW Session
    ${resp}=  PUT On Session   ynw  /provider/appointment/statuschange/${status}/${appmntId}  expected_status=any
    [Return]  ${resp}
    
Enable Future Appointment
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/apptMgr/futureAppt/Enable  expected_status=any
    [Return]  ${resp}

Disable Future Appointment
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/apptMgr/futureAppt/Disable   expected_status=any
    [Return]  ${resp}

Enable Today Appointment
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/apptMgr/todayAppt/Enable  expected_status=any
    [Return]  ${resp}

Disable Today Appointment
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/apptMgr/todayAppt/Disable  expected_status=any
    [Return]  ${resp}

Get Appointment Settings
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/settings/apptMgr  expected_status=any
    [Return]  ${resp} 

Update Appointmet Settings
    [Arguments]   ${enableToday}   ${futureAppt}
    ${data}=  Create Dictionary   enableToday=${enableToday}  futureAppt=${futureAppt}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    PUT On Session     ynw   /provider/settings/apptMgr   data=${data}  expected_status=any
    [Return]  ${resp}

Enable Appointment
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/account/settings/appointment/Enable   expected_status=any
    [Return]  ${resp}

Disable Appointment
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/account/settings/appointment/Disable   expected_status=any
    [Return]  ${resp}

Get Appointment Status
    [Arguments]   ${uuid}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/appointment/state/${uuid}  expected_status=any
    [Return]  ${resp}
    
Enable Calling Status
    [Arguments]   ${uid}   
    Check And Create YNW Session
    ${resp}=  PUT On Session   ynw  /provider/appointment/callingStatus/${uid}/Enable  expected_status=any
    [Return]  ${resp}

Disable Calling Status
    [Arguments]   ${uid}   
    Check And Create YNW Session
    ${resp}=  PUT On Session   ynw  /provider/appointment/callingStatus/${uid}/Disable  expected_status=any
    [Return]  ${resp}

Appointment Action for Batch
    [Arguments]   ${scheduleId}   ${status}   ${batch}   
    Check And Create YNW Session
    ${resp}=  PUT On Session   ynw  /provider/appointment/statusChangeByBatch/${scheduleId}/${status}/${batch}  expected_status=any
    [Return]  ${resp}

Add Label for Appointment
    [Arguments]  ${appmntId}  ${labelname}  ${label_value}
    ${data}=    Create Dictionary  ${labelname}=${label_value}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/appointment/addLabel/${appmntId}  data=${data}  expected_status=any
    [Return]  ${resp}

Create Label Dictionary
    [Arguments]  @{kwargs}
    # ${items}=  Get Dictionary items  ${kwargs}
    ${data}=  Create Dictionary
    FOR  ${key}  ${value}  IN  @{kwargs}
            Set To Dictionary  ${data}   ${key}=${value}
    END
    Log  ${data}
    [Return]  ${data}


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
    [Return]  ${resp}

Remove Appointment Label
    [Arguments]   ${apptId}  ${label}
    Check And Create YNW Session
    ${resp}=    DELETE On Session    ynw  /provider/appointment/removeLabel/${apptId}/${label}  expected_status=any
    [Return]  ${resp}

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
    [Return]  ${resp}


Add Label for Waitlist
    [Arguments]  ${WaitlistId}  ${labelname}  ${label_value}
    ${data}=    Create Dictionary  ${labelname}=${label_value}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/waitlist/label/${WaitlistId}  data=${data}  expected_status=any
    [Return]  ${resp}

Add Label for Multiple Waitlist
    [Arguments]  ${label_dict}  @{WaitlistId}
    ${len}=  Get Length  ${WaitlistId}
    ${waitlists}=  Create List
    FOR  ${value}  IN  @{WaitlistId}
        Append To List  ${waitlists}  ${value}
    END
    ${data}=    Create Dictionary  uuid=${waitlists}  labels=${label_dict}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/waitlist/labelBatch  data=${data}  expected_status=any
    [Return]  ${resp}


Remove Waitlist Label
    [Arguments]   ${WaitlistId}  ${label}
    Check And Create YNW Session
    ${resp}=    DELETE On Session    ynw  /provider/waitlist/label/${WaitlistId}/${label}  expected_status=any
    [Return]  ${resp} 


Remove Label from Multiple Waitlist
    [Arguments]  ${labelname_list}  @{WaitlistId}
    ${len}=  Get Length  ${WaitlistId}
    ${waitlists}=  Create List
    FOR  ${value}  IN  @{WaitlistId}
        Append To List  ${waitlists}  ${value}
    END
    ${data}=    Create Dictionary  uuid=${waitlists}  labelNames=${labelname_list}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw  /provider/waitlist/masslabel  data=${data}  expected_status=any
    [Return]  ${resp}


Add Note to Appointment
    [Arguments]  ${appmntId}  ${note}
    # ${data}=  Convert To String  ${note}
    ${note}=    json.dumps    ${note}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/appointment/note/${appmntId}  data=${note}  expected_status=any
    [Return]  ${resp}

Get Appointment Note
    [Arguments]   ${uuid}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/appointment/note/${uuid}   expected_status=any
    [Return]  ${resp}

Get Future Appointments
    [Arguments]  &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/appointment/future  params=${kwargs}  expected_status=any
    [Return]  ${resp}

Get Future Appointment Count
    [Arguments]  &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/appointment/future/count  params=${kwargs}   expected_status=any
    [Return]  ${resp}

Get Appointments Today
    [Arguments]  &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/appointment/today  params=${kwargs}  expected_status=any
    [Return]  ${resp}

Get Today Appointment Count
    [Arguments]  &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/appointment/today/count  params=${kwargs}  expected_status=any
    [Return]  ${resp}

Get Appointments History
    [Arguments]  &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/appointment/history  params=${kwargs}  expected_status=any
    [Return]  ${resp}

Get Appointment History Count
    [Arguments]  &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/appointment/history/count  params=${kwargs}  expected_status=any
    [Return]  ${resp}

Create Waitlist Meeting Request
    [Arguments]   ${uuid}  ${type}  @{recipients}
    # ${rec}=  Create List  ${recipients}
    ${data}=    Create Dictionary  mode=${type}  recipients=${recipients}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/waitlist/${uuid}/createmeetingrequest   data=${data}  expected_status=any
    [Return]  ${resp}

Get Waitlist Meeting Request
    [Arguments]  ${uid}   ${mode}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/waitlist/${uid}/meetingDetails/${mode}  expected_status=any
    [Return]  ${resp}


Create Appointment Meeting Request
    [Arguments]   ${uid}  ${type}  @{recipients}
    # ${rec}=  Create List  ${recipients}
    ${data}=    Create Dictionary  mode=${type}  recipients=${recipients}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/appointment/${uid}/createmeetingrequest   data=${data}  expected_status=any
    [Return]  ${resp}


Get Appointment Meeting Request
    [Arguments]   ${uid}   ${mode}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/appointment/${uid}/meetingDetails/${mode}  expected_status=any
    [Return]  ${resp}

Get Billable Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Test Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Should Be Equal As Strings    ${resp.status_code}    200
            Exit For Loop IF  '${resp.json()['serviceBillable']}' == '${bool[1]}'
    END
    [Return]  ${subdomain}  

Rate Appointment
    [Arguments]   ${uid}  ${star}  ${feedback}
    ${data}=  Create Dictionary   uuid=${uid}   stars=${star}   feedback=${feedback}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw  /provider/appointment/rating    data=${data}  expected_status=any
    [Return]  ${resp}

Provider Update Appointment Rating
    [Arguments]    ${uid}  ${star}  ${feedback}
    ${data}=  Create Dictionary   uuid=${uid}   stars=${star}   feedback=${feedback}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=    PUT On Session   ynw  /provider/appointment/rating    data=${data}  expected_status=any
    [Return]  ${resp}

Enable Batch For Appointment
    [Arguments]   ${ScheduleId} 
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw   /provider/appointment/schedule/batch/${ScheduleId}/True  expected_status=any
    [Return]  ${resp}

Disable Batch For Appointment
    [Arguments]   ${ScheduleId}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw   /provider/appointment/schedule/batch/${ScheduleId}/False  expected_status=any
    [Return]  ${resp}

Add Appmt Batch Name
    [Arguments]   ${ScheduleId}  ${prefix}  ${suffix}
    Check And Create YNW Session
    ${data}=   Create Dictionary   prefix=${prefix}   suffix=${suffix}
    ${data}=    json.dumps    ${data}
    ${resp}=    PUT On Session    ynw  /provider/appointment/schedule/batch/pattern/${ScheduleId}  data=${data}  expected_status=any
    [Return]  ${resp}

Change Appmt Status by BatchId
    [Arguments]   ${batchId}  ${status}  ${Date}
    Check And Create YNW Session
    ${data}=   Create Dictionary   date=${Date}
    ${data}=    json.dumps    ${data}
    ${resp}=    PUT On Session    ynw  /provider/appointment/statusChangeByBatch/${batchId}/${status}   data=${data}  expected_status=any
    [Return]  ${resp}

Cancel Appointment by Batch
    [Arguments]   ${batchId}  ${status}   ${Date}   ${cancelReason}
    Check And Create YNW Session
    ${data}=   Create Dictionary      date=${Date}   cancelReason=${cancelReason}
    ${data}=    json.dumps    ${data}
    ${resp}=    PUT On Session    ynw  /provider/appointment/statusChangeByBatch/${batchId}/${status}   data=${data}  expected_status=any
    [Return]  ${resp}

Reject Appointment by Batch
    [Arguments]   ${batchId}  ${status}  ${Date}   ${rejectReason}
    Check And Create YNW Session
    ${data}=   Create Dictionary   date=${Date}   rejectReason=${rejectReason}
    ${data}=    json.dumps    ${data}
    ${resp}=    PUT On Session    ynw  /provider/appointment/statusChangeByBatch/${batchId}/${status}   data=${data}  expected_status=any
    [Return]  ${resp}


Change multiple Appmt Status
    [Arguments]  ${statuschange}     @{vargs}
    ${data}=    json.dumps     ${vargs}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw   /provider/appointment/multiStatusChange/${statuschange}   data=${data}  expected_status=any
    Log  ${resp}
    [Return]  ${resp}

Waitlist Action multiple account
    [Arguments]   ${waitlist_actions[4]}    @{vargs}
    ${data}=    json.dumps     ${vargs}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw   /provider/waitlist/multiStatusChange/${waitlist_actions[4]}   data=${data}  expected_status=any
    Log  ${resp}
    [Return]  ${resp}


Get Appmt Schedule AvailableNow
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/appointment/schedule/availableNow  expected_status=any
    [Return]  ${resp}    
    
Get Appointment Schedule Count
    [Arguments]  &{kwargs}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/appointment/schedule/count   params=${kwargs}  expected_status=any
    [Return]  ${resp}    

Enable Future Appointment By Schedule Id
    [Arguments]   ${schedule_id}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  ynw  /provider/appointment/schedule/futureAppt/true/${schedule_id}   expected_status=any
    [Return]  ${resp}

Disable Future Appointment By Schedule Ids
    [Arguments]   ${schedule_id}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  ynw  /provider/appointment/schedule/futureAppt/false/${schedule_id}   expected_status=any
    [Return]  ${resp}

Enable Today Appointment By Schedule Id
    [Arguments]   ${schedule_id}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  ynw  /provider/appointment/schedule/todayAppt/true/${schedule_id}   expected_status=any
    [Return]  ${resp}

Disable Today Appointment By Schedule Id
    [Arguments]   ${schedule_id}
    Check And Create YNW Session
    ${resp}=  PATCH On Session  ynw  /provider/appointment/schedule/todayAppt/false/${schedule_id}   expected_status=any
    [Return]  ${resp}

Consumer Mass Communication for Appt
    [Arguments]  ${cookie}  ${email}  ${sms}  ${push_notf}  ${telegram}   ${msg}    ${fileswithcaption}    @{vargs}  
    ${input}=  Create Dictionary  email=${email}  sms=${sms}  pushNotification=${push_notf}     telegram=${telegram}
    ${data}=  Create Dictionary  medium=${input}  communicationMessage=${msg}  uuid=${vargs}
    ${resp}=     Imageupload.PAppMassCommMultiFile   ${cookie}     ${data}    @{fileswithcaption}
    [Return]  ${resp}
                     
Get Appmt Schedule AvailableNow By ProviderId   
    [Arguments]     ${providerId}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/appointment/schedule/availableNow/${providerId}   expected_status=any
    [Return]  ${resp}          

Get AppmtSchedule NextAvailableTime By ScheduleId
    [Arguments]  ${scheduleId}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/appointment/schedule/nextAvailableTime/${scheduleId}  expected_status=any
    [Return]  ${resp}
    
Get NextAvailableSchedule By Provider Location
    [Arguments]  ${P_accountId}   ${locationId}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/appointment/schedule/nextAvailableSchedule/${P_accountId}-${locationId}  expected_status=any
    [Return]  ${resp}

Get NextAvailableSchedule By Provider Location and User
    [Arguments]  ${B_accountId}   ${locationId}  ${userId}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/appointment/schedule/nextAvailableSchedule/${B_accountId}-${locationId}-${userId}  expected_status=any
    [Return]  ${resp}

Get NextAvailableSchedule By multi Provider Location and User
    [Arguments]  @{kwargs}
    Check And Create YNW Session
    ${len}=   Get Length  ${kwargs}
    ${data}=  Catenate  SEPARATOR=,  @{kwargs}
    ${resp}=    GET On Session    ynw   /provider/appointment/schedule/nextAvailableSchedule/${data}  expected_status=any
    [Return]  ${resp}
    

Update FamilymemberByprovidercustomer
    [Arguments]  ${id}  ${memid}  ${firstname}  ${lastname}  ${dob}  ${gender}  
    Check And Create YNW Session
    ${data}=  Create Dictionary  parent=${id}  id=${memid}   firstName=${firstname}  lastName=${lastname}  dob=${dob}  gender=${gender}  
    ${data}=    json.dumps    ${data}
    ${resp}=  PUT On Session   ynw   /provider/customers/familyMember   data=${data}  expected_status=any
    [Return]  ${resp}


DeleteFamilymemberByprovidercustomer
	[Arguments]    ${memberId}   ${consumerId}
	Check And Create YNW Session
    ${resp}=   DELETE On Session  ynw  /provider/customers/familyMember/${memberId}/${consumerId}   expected_status=any 
    [Return]  ${resp}


Add Appointment Schedule Delay
    [Arguments]  ${schedulId}  ${time}
    ${data}=  Create Dictionary  delayDuration=${time}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/appointment/schedule/${schedulId}/delay  data=${data}  expected_status=any
    [Return]  ${resp}

Get Appointment Schedule Delay
    [Arguments]  ${schedulId}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/appointment/schedule/${schedulId}/delay  expected_status=any
    [Return]  ${resp}

Get Account contact information
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/contact  expected_status=any
    [Return]  ${resp} 

Update Account contact information
    [Arguments]  ${primaryphnNumber}  ${primeryEmail}  ${secondaryphnnumber}  ${whatsappPhnNumber}  ${secondaryEmail}  ${salutation}  ${contactFirstName}  ${contactLastName}   ${countryCode}  ${whatsAppCountryCode}  ${secondaryCountryCode}
    ${data}=  Create Dictionary   primaryPhoneNumber=${primaryphnNumber}   primaryEmail=${primeryEmail}  secondaryPhoneNumber=${secondaryphnnumber}   whatsappPhoneNumber=${whatsappPhnNumber}  secondaryEmail=${secondaryEmail}  salutation=${salutation}  contactFirstName=${contactFirstName}  contactLastName=${contactLastName}  countryCode=${countryCode}  whatsAppCountryCode=${whatsAppCountryCode}  secondaryCountryCode=${secondaryCountryCode}
    # ${memb}=  Create List  ${data}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/contact  data=${data}  expected_status=any
    [Return]  ${resp}
    

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
    [Return]  ${resp}


Update Email 
    [Arguments]  ${id}   ${firstname}  ${lastname}  ${email}   
    Check And Create YNW Session
    ${data}=  Create Dictionary  id=${id}   firstName=${firstname}  lastName=${lastname}   email=${email}  
    ${data}=  Create Dictionary   basicInfo=${data}
    ${data}=    json.dumps    ${data}
    ${resp}=  PUT On Session   ynw   /provider/email/notification   data=${data}  expected_status=any
    [Return]  ${resp}


# Availability Of Queue By Provider
#     [Arguments]  ${locationId}   ${serviceId}  
#     Check And Create YNW Session
#     ${resp}=  GET On Session  ynw    /consumer/waitlist/queues/available/${locationId}/${serviceId}   expected_status=any
#     [Return]  ${resp}


Get License UsageInfo
   Check And Create YNW Session
   ${resp}=    GET On Session    ynw  /provider/license/usageInfo  expected_status=any
   [Return]  ${resp}


Get Monthly Schedule Availability by Location and Service
    [Arguments]  ${Location_id}   ${Service_id}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/appointment/availability/location/${Location_id}/service/${Service_id}   expected_status=any
    [Return]  ${resp}


# Create MR With uuid
#     [Arguments]  ${uuid}  ${bookingType}  ${consultationMode}  ${complaints}  ${symptoms}  ${allergies}  ${vaccinationHistory}  ${observations}  ${diagnosis}  ${misc_notes}   ${notes}  ${mrConsultationDate}  ${state}   @{vargs}
#     ${clinicalNotes}=  Create Dictionary  complaints=${complaints}  symptoms=${symptoms}  allergies=${allergies}  vaccinationHistory=${vaccinationHistory}  observations=${observations}  diagnosis=${diagnosis}  misc_notes=${misc_notes} 
    
#     ${len}=  Get Length  ${vargs}
#     ${prescriptionsList}=  Create List  

#     FOR    ${index}    IN RANGE    ${len}   
#         Exit For Loop If  ${len}==0
#         Append To List  ${prescriptionsList}  ${vargs[${index}]}
#     END

#     ${prescriptions}=  Create Dictionary  prescriptionsList=${prescriptionsList}  notes=${notes}  

#    ${data}=  Create Dictionary    bookingType=${bookingType}  consultationMode=${consultationMode}  clinicalNotes=${clinicalNotes}  prescriptions=${prescriptions}   mrConsultationDate=${mrConsultationDate}  state=${state}
#    ${data}=  json.dumps  ${data}
#    Check And Create YNW Session
#    ${resp}=  POST On Session  ynw  /provider/mr/${uuid}  data=${data}  expected_status=any
#    [Return]  ${resp}

Create MR With uuid
    [Arguments]  ${uuid}  ${bookingType}  ${consultationMode}   ${mrConsultationDate}  ${state}    &{kwargs}

   ${data}=  Create Dictionary    bookingType=${bookingType}  consultationMode=${consultationMode}    mrConsultationDate=${mrConsultationDate}  state=${state}     
   FOR  ${key}  ${value}  IN  &{kwargs}
            Set To Dictionary  ${data}   ${key}=${value}
   END
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw  /provider/mr/${uuid}  data=${data}  expected_status=any
   [Return]  ${resp}

clinical Notes Attachments
    [Arguments]  ${type}  ${clinicalNote}   @{vargs}  &{kwargs}

    ${len}=  Get Length  ${vargs}
    ${AttachmentList}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${AttachmentList}  ${vargs[${index}]}
    END

    ${clinicalNotes}=  Create Dictionary  type=${type}  clinicalNotes=${clinicalNote}  attachments=${AttachmentList} 
    [Return]  ${clinicalNotes}


Get MR By Id
    [Arguments]  ${mrid}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/mr/${mrid}  expected_status=any
    [Return]  ${resp}

Get MedicalRecords
    [Arguments]    &{kwargs}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/mr   params=${kwargs}  expected_status=any
    [Return]  ${resp}

Get Appointment Messages
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/ynwConf/appointment/messages  expected_status=any
    [Return]  ${resp}

Reschedule Consumer Appointment
    [Arguments]  ${appt_id}   ${time_slot}   ${date}   ${sch_id}
    Check And Create YNW Session
    ${data}=  Create Dictionary  uid=${appt_id}   time=${time_slot}  date=${date}   schedule=${sch_id}  
    ${data}=    json.dumps    ${data}
    ${resp}=  PUT On Session   ynw   /provider/appointment/reschedule   data=${data}  expected_status=any
    [Return]  ${resp}

# Create MR prescription by mr id
#    [Arguments]  ${mrId}   @{vargs}

#    ${len}=  Get Length  ${vargs}
#    ${prescription}=  Create Dictionary  medicine_name=${vargs[0]}  frequency=${vargs[1]}  duration=${vargs[2]}  instructions=${vargs[3]}
#    ${loan}=  Create List  ${prescription}
   
#     FOR    ${index}    IN RANGE  4  ${len}   4
#         Exit For Loop If  ${len}==0
#         ${index2}=  Evaluate  ${index}+1
#         ${index3}=  Evaluate  ${index}+2
#         ${index4}=  Evaluate  ${index}+3      
#     	${prescription}=  Create Dictionary  medicine_name=${vargs[${index}]}  frequency=${vargs[${index2}]}  duration=${vargs[${index3}]}  instructions=${vargs[${index4}]}
#         Append To List  ${loan}  ${prescription}
#     END

#    ${loan}=  json.dumps  ${loan}
#    Check And Create YNW Session
#    ${resp}=  POST On Session  ynw  /provider/mr/prescription/${mrId}  data=${loan}  expected_status=any
#    [Return]  ${resp}

   
Create MR prescription by mr id
    [Arguments]  ${mrId}   ${notes}  @{vargs}

    ${len}=  Get Length  ${vargs}
    ${prescriptionsList}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${prescriptionsList}  ${vargs[${index}]}
    END

    ${prescriptions}=  Create Dictionary  prescriptionsList=${prescriptionsList}  notes=${notes}  

    ${prescriptions}=  json.dumps  ${prescriptions}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/mr/prescription/${mrId}  data=${prescriptions}  expected_status=any
    [Return]  ${resp}


Get MR prescription 
    [Arguments]  ${mrId}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/mr/prescription/${mrId}  expected_status=any
    [Return]  ${resp}


# Update MR prescription
#     [Arguments]  ${mrId}   @{vargs}

#     ${len}=  Get Length  ${vargs}
#     ${prescription}=  Create Dictionary  medicine_name=${vargs[0]}  frequency=${vargs[1]}  duration=${vargs[2]}  instructions=${vargs[3]}
#     ${loan}=  Create List  ${prescription}
   
#     FOR    ${index}    IN RANGE  4  ${len}   4
#         Exit For Loop If  ${len}==0
#         ${index2}=  Evaluate  ${index}+1
#         ${index3}=  Evaluate  ${index}+2
#         ${index4}=  Evaluate  ${index}+3      
#     	${prescription}=  Create Dictionary  medicine_name=${vargs[${index}]}  frequency=${vargs[${index2}]}  duration=${vargs[${index3}]}  instructions=${vargs[${index4}]}
#         Append To List  ${loan}  ${prescription}
#     END

#     ${loan}=  json.dumps  ${loan}
#     Check And Create YNW Session
#     ${resp}=  PUT On Session  ynw  /provider/mr/prescription/${mrId}  data=${loan}  expected_status=any
#     [Return]  ${resp}

Update MR prescription
    [Arguments]  ${mrId}   ${notes}  @{vargs}

    ${len}=  Get Length  ${vargs}
    ${prescriptionsList}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${prescriptionsList}  ${vargs[${index}]}
    END

    ${prescriptions}=  Create Dictionary  prescriptionsList=${prescriptionsList}  notes=${notes}  

    ${prescriptions}=  json.dumps  ${prescriptions}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/mr/prescription/${mrId}  data=${prescriptions}  expected_status=any
    [Return]  ${resp}



Reschedule Consumer Checkin
    [Arguments]  ${wl_id}   ${date}   ${q_id}
    Check And Create YNW Session
    ${data}=  Create Dictionary  ynwUuid=${wl_id}  date=${date}   queue=${q_id}  
    ${data}=  json.dumps  ${data}
    ${resp}=  PUT On Session   ynw   /provider/waitlist/reschedule   data=${data}  expected_status=any
    [Return]  ${resp}


Get bsconf Messages
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/ynwConf/messages  expected_status=any
    [Return]  ${resp}

Enable Disable Token Id
    [Arguments]   ${showTokenId}
    ${data}=  Create Dictionary   showTokenId=${showTokenId}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/waitlistMgr   data=${data}  expected_status=any
    [Return]  ${resp}

# Create MR clinical notes by mr id
#     [Arguments]  ${mrId}   ${symptoms}   ${allergies}  ${diagnosis}   ${complaints}  ${misc_notes}   ${observations}   ${vaccinationHistory}   
#     Check And Create YNW Session
#     ${data}=  Create Dictionary  symptoms=${symptoms}  allergies=${allergies}   diagnosis=${diagnosis}   complaints=${complaints}   misc_notes=${misc_notes}  observations=${observations}   vaccinationHistory=${vaccinationHistory}  
#     ${data}=    json.dumps    ${data}
#     ${resp}=  POST On Session  ynw  /provider/mr/clinicalNotes/${mrId}  data=${data}  expected_status=any
#     [Return]  ${resp}

Create MR clinical notes by mr id
    [Arguments]  ${mrId}     ${type}  ${clinicalNote}   @{vargs}

    ${len}=  Get Length  ${vargs}
    ${AttachmentList}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${AttachmentList}  ${vargs[${index}]}
    END

    Check And Create YNW Session
    ${data}=  Create Dictionary   type=${type}  clinicalNotes=${clinicalNote}  attachments=${AttachmentList} 
    ${data}=  Create List    ${data}
    ${data}=    json.dumps    ${data}
    ${resp}=  POST On Session  ynw  /provider/mr/clinicalNotes/${mrId}  data=${data}  expected_status=any
    [Return]  ${resp}

Get MR clinical notes
    [Arguments]  ${mrId}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/mr/clinicalNotes/${mrId}   expected_status=any
    [Return]  ${resp}

# Update MR clinical notes
#     [Arguments]  ${mrId}   ${symptoms}   ${allergies}  ${diagnosis}   ${complaints}  ${misc_notes}   ${observations}   ${vaccinationHistory} 
#     Check And Create YNW Session
#     ${data}=  Create Dictionary  symptoms=${symptoms}  allergies=${allergies}   diagnosis=${diagnosis}   complaints=${complaints}   misc_notes=${misc_notes}  observations=${observations}   vaccinationHistory=${vaccinationHistory}  
#     ${data}=    json.dumps    ${data}
#     ${resp}=  PUT On Session  ynw  /provider/mr/clinicalNotes/${mrId}  data=${data}  expected_status=any
#     [Return]  ${resp}

Update MR clinical notes
    [Arguments]  ${mrId}     ${type}  ${clinicalNote}   @{vargs}

    ${len}=  Get Length  ${vargs}
    ${AttachmentList}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${AttachmentList}  ${vargs[${index}]}
    END

    Check And Create YNW Session
    ${data}=  Create Dictionary   type=${type}  clinicalNotes=${clinicalNote}  attachments=${AttachmentList} 
    ${data}=  Create List    ${data}
    ${data}=    json.dumps    ${data}
    ${resp}=  PUT On Session  ynw  /provider/mr/clinicalNotes/${mrId}  data=${data}  expected_status=any
    [Return]  ${resp}

Share Prescription
    [Arguments]  ${mrId}   ${msg}  ${html}   ${email}  ${sms}  ${push}  ${expirableLink}  ${expireTimeInMinuts}
    Check And Create YNW Session
    ${medium}=  Create Dictionary  email=${email}   sms=${sms}   pushNotification=${push}
    ${data}=  Create Dictionary  message=${msg}   html=${html}   medium=${medium}  expirableLink=${expirableLink}   expireTimeInMinuts=${expireTimeInMinuts}
    ${data}=    json.dumps    ${data}
    ${resp}=  POST On Session  ynw  /provider/mr/sharePrescription/${mrId}  data=${data}  expected_status=any
    [Return]  ${resp}

uploadDigitalSign
    [Arguments]   ${id}  ${cookie}
    ${prop}=  Create Dictionary  caption=sign
    ${prop}=  json.dumps  ${prop}
    Create File  TDD/sign.json  ${prop}  
    ${resp}=  digitalSignUpload  ${id}  ${cookie}
    [Return]  ${resp}       

Get digital sign
    [Arguments]  ${providerId}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/user/digitalSign/${providerId}   expected_status=any
    [Return]  ${resp}

uploadPrescriptionImage
    [Arguments]   ${mrid}  ${cookie}
    ${prop}=  Create Dictionary  caption=prescription
    ${prop}=  Create Dictionary  0=${prop}
    ${prop}=  Create Dictionary  propertiesMap=${prop}
    ${prop}=  json.dumps  ${prop}
    Create File  TDD/prescription.json  ${prop}
    ${resp}=  prescriptionImgUpload  ${mrid}  ${cookie}
    [Return]  ${resp}

uploadClinicalnotesImage
    [Arguments]   ${mrid}  ${cookie}
    ${prop}=  Create Dictionary  caption=clinicalnotes
    ${prop}=  Create Dictionary  0=${prop}
    ${prop}=  Create Dictionary  propertiesMap=${prop}
    ${prop}=  json.dumps  ${prop}
    Create File  TDD/clinicalnotes.json  ${prop}
    ${resp}=  clinicalnotesImgUpload  ${mrid}  ${cookie}
    [Return]  ${resp}

# Create MR with patientId
#    [Arguments]  ${patientId}  ${bookingType}  ${consultationMode}  ${complaints}  ${symptoms}  ${allergies}  ${vaccinationHistory}  ${observations}  ${diagnosis}  ${misc_notes}   ${mrConsultationDate}  ${state}   @{vargs}
# #    ${providerConsumer}=  Create Dictionary  id=${id}
#    ${clinicalNotes}=  Create Dictionary  complaints=${complaints}  symptoms=${symptoms}  allergies=${allergies}  vaccinationHistory=${vaccinationHistory}  observations=${observations}  diagnosis=${diagnosis}  misc_notes=${misc_notes}
   
#    ${len}=  Get Length  ${vargs}
#    ${prescription}=  Create Dictionary  medicine_name=${vargs[0]}  frequency=${vargs[1]}  duration=${vargs[2]}  instructions=${vargs[3]}
#    ${loan}=  Create List  ${prescription}
   
#     FOR    ${index}    IN RANGE  4  ${len}   4
#         Exit For Loop If  ${len}==0
#         ${index2}=  Evaluate  ${index}+1
#         ${index3}=  Evaluate  ${index}+2
#         ${index4}=  Evaluate  ${index}+3      
#     	${prescription}=  Create Dictionary  medicine_name=${vargs[${index}]}  frequency=${vargs[${index2}]}  duration=${vargs[${index3}]}  instructions=${vargs[${index4}]}
#         Append To List  ${loan}  ${prescription}
#     END
#     # Run Keyword If  ${len}>0  Set To Dictionary  ${loan}  loan=${loan}
#    ${data}=  Create Dictionary    bookingType=${bookingType}  consultationMode=${consultationMode}  clinicalNotes=${clinicalNotes}  loan=${loan}   mrConsultationDate=${mrConsultationDate}  state=${state}
#    ${data}=  json.dumps  ${data}
#    Check And Create YNW Session
#    ${resp}=  POST On Session  ynw  /provider/mr/patient/${patientId}  data=${data}  expected_status=any
#    [Return]  ${resp}


Create MR with patientId
    [Arguments]  ${patientId}  ${bookingType}  ${consultationMode}  ${complaints}  ${symptoms}  ${allergies}  ${vaccinationHistory}  ${observations}  ${diagnosis}  ${misc_notes}   ${notes}  ${mrConsultationDate}  ${state}   @{vargs}
    ${clinicalNotes}=  Create Dictionary  complaints=${complaints}  symptoms=${symptoms}  allergies=${allergies}  vaccinationHistory=${vaccinationHistory}  observations=${observations}  diagnosis=${diagnosis}  misc_notes=${misc_notes} 
    ${clinicalNotes}=  Create List  ${clinicalNotes}

    ${len}=  Get Length  ${vargs}
    ${prescriptionsList}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${prescriptionsList}  ${vargs[${index}]}
    END

    ${prescriptions}=  Create Dictionary  prescriptionsList=${prescriptionsList}  notes=${notes}  

   ${data}=  Create Dictionary    bookingType=${bookingType}  consultationMode=${consultationMode}  clinicalNotes=${clinicalNotes}  prescriptions=${prescriptions}   mrConsultationDate=${mrConsultationDate}  state=${state}
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw  /provider/mr/patient/${patientId}  data=${data}  expected_status=any
   [Return]  ${resp}


Billable Domain Providers
    [Arguments]  ${min}=0   ${max}=260
    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
    ${provider_list}=  Create List
    
    FOR   ${a}  IN RANGE   ${min}   ${max}    
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        ${domain}=   Set Variable    ${decrypted_data['sector']}
        ${subdomain}=    Set Variable      ${decrypted_data['subSector']}
        ${resp}=  View Waitlist Settings
	    Run Keyword If  ${resp.json()['filterByDept']}==${bool[1]}   Toggle Department Disable  
        ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Suite Variable  ${check}    ${resp2.json()['serviceBillable']} 
        Run Keyword If     '${check}' == 'True'   Append To List   ${provider_list}  ${PUSERNAME${a}}
    END
    [Return]  ${provider_list}


Multiloc and Billable Providers
    [Arguments]  ${min}=0   ${max}=260
    @{dom_list}=  Create List
    @{provider_list}=  Create List
    @{multiloc_providers}=  Create List    
    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    ${domlen}=  Get Length   ${multilocdoms}
    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
    # ${length}   Run Keyword If     ${length}>${max}   Set Variable  ${max}
    # ...  ELSE	 Set Variable    ${length}

    FOR   ${i}  IN RANGE   ${domlen}
        ${dom}=  Convert To String   ${multilocdoms[${i}]['domain']}
        Append To List   ${dom_list}  ${dom}
    END
    Log   ${dom_list}
     
    FOR   ${a}  IN RANGE   ${min}   ${max}   
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        ${domain}=   Set Variable    ${decrypted_data['sector']}
        ${subdomain}=    Set Variable      ${decrypted_data['subSector']}
        Log  ${dom_list}
        ${status} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${dom_list}  ${domain}
        Log Many  ${status} 	${value}
        Run Keyword If  '${status}' == 'PASS'   Append To List   ${multiloc_providers}  ${PUSERNAME${a}}
        ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        Log   ${resp2.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Test Variable  ${check}    ${resp2.json()['serviceBillable']} 
        Run Keyword If     '${check}' == 'True'   Append To List   ${provider_list}  ${PUSERNAME${a}}
        # Run Keyword If    '${status}' == 'PASS' and '${check}' == 'True'   Append To List  ${multiloc_billable_providers}  ${PUSERNAME${a}}
    END
    # [Return]  ${provider_list}  ${multiloc_providers}  ${multiloc_billable_providers}
    [Return]  ${provider_list}  ${multiloc_providers}


Get Patient Previous Visit
    [Arguments]  ${patientId}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/mr/patientPreviousVisit/${patientId}  expected_status=any
    [Return]  ${resp}


Get Patient Previous Visit Count
    [Arguments]  ${patientId}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/mr/patientPreviousVisit/count/${patientId}   expected_status=any
    [Return]  ${resp}

Get MR Auditlogs by MR Id
    [Arguments]  ${mrId}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/mr/auditLog/${mrId}   expected_status=any
    [Return]  ${resp}


Enable Order Settings
   Check And Create YNW Session
   ${resp}=    PUT On Session    ynw  /provider/order/settings/true   expected_status=any
   [Return]  ${resp}


Disable Order Settings
   Check And Create YNW Session
   ${resp}=    PUT On Session    ynw  /provider/order/settings/false   expected_status=any
   [Return]  ${resp}


Create Order Settings
    [Arguments]  ${enableOrder}  ${storeContactInfo}
    ${data}=  Create Dictionary  enableOrder=${enableOrder}  storeContactInfo=${storeContactInfo} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/order/settings  data=${data}  expected_status=any
    [Return]  ${resp}


Get Order Settings by account id
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/order/settings   expected_status=any
    [Return]  ${resp}


Update Order Settings
    [Arguments]  ${enableOrder}  ${storeContactInfo}
    ${data}=  Create Dictionary  enableOrder=${enableOrder}  storeContactInfo=${storeContactInfo} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/order/settings  data=${data}  expected_status=any
    [Return]  ${resp} 


Get Order Settings Status
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/order/settings/status   expected_status=any
    [Return]  ${resp}


Get Order Settings Contact info
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/order/settings/contact/info   expected_status=any
    [Return]  ${resp}


Update Store Contact info
    [Arguments]   &{kwargs}
    ${items}=  Get Dictionary items  ${kwargs}
    ${data}=  Create Dictionary
    FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    Set To Dictionary  ${data}   primCountryCode=91   secCountryCode=91   whatsAppCountryCode=91 
    Log  ${data}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/order/settings/contact/info  data=${data}  expected_status=any
    [Return]  ${resp}


Create Order Item
   [Arguments]    ${displayName}    ${shortDesc}    ${itemDesc}    ${price}    ${taxable}    ${itemName}    ${itemNameInLocal}    ${promoPriceType}    ${promoPrice}    ${promotionalPrcnt}    ${note}    ${stockAvailable}    ${showOnLandingpage}    ${itemCode}    ${showPromoPrice}    ${promoLabelType}    ${promoLabel}   
   ${data}=  Create Dictionary   displayName=${displayName}  shortDesc=${shortDesc}  itemDesc=${itemDesc}  price=${price}  taxable=${taxable}  itemName=${itemName}  itemNameInLocal=${itemNameInLocal}  promotionalPriceType=${promoPriceType}  promotionalPrice=${promoPrice}  promotionalPrcnt=${promotionalPrcnt}  note=${note}  isStockAvailable=${stockAvailable}  isShowOnLandingpage=${showOnLandingpage}  itemCode=${itemCode}  showPromotionalPrice=${showPromoPrice}  promotionLabelType=${promoLabelType}  promotionLabel=${promoLabel}
   ${data}=    json.dumps    ${data}
   Check And Create YNW Session 
   ${resp}=    POST On Session    ynw  /provider/items   data=${data}  expected_status=any
   [Return]  ${resp}


Create Virtual Order Item
   [Arguments]    ${displayName}    ${shortDesc}    ${itemDesc}    ${price}    ${taxable}    ${itemName}    ${itemNameInLocal}    ${promoPriceType}    ${promoPrice}    ${promotionalPrcnt}    ${note}    ${stockAvailable}    ${showOnLandingpage}    ${itemCode}    ${showPromoPrice}    ${promoLabelType}    ${promoLabel}  ${itemType}   ${expiryDate} 
   ${data}=  Create Dictionary   displayName=${displayName}  shortDesc=${shortDesc}  itemDesc=${itemDesc}  price=${price}  taxable=${taxable}  
   ...   itemName=${itemName}  itemNameInLocal=${itemNameInLocal}  promotionalPriceType=${promoPriceType}  promotionalPrice=${promoPrice}  
   ...   promotionalPrcnt=${promotionalPrcnt}  note=${note}  isStockAvailable=${stockAvailable}  isShowOnLandingpage=${showOnLandingpage}  
   ...   itemCode=${itemCode}  showPromotionalPrice=${showPromoPrice}  promotionLabelType=${promoLabelType}  promotionLabel=${promoLabel}  
   ...   itemType=${itemType}  expiryDate=${expiryDate}
   ${data}=    json.dumps    ${data}
   Check And Create YNW Session 
   ${resp}=    POST On Session    ynw  /provider/items   data=${data}  expected_status=any
   [Return]  ${resp}


Update Order Item
   [Arguments]     ${id}   ${displayName}    ${shortDesc}    ${itemDesc}    ${price}    ${taxable}    ${status}   ${itemName}    ${itemNameInLocal}    ${stockAvailable}    ${showOnLandingpage}    ${promoPriceType}   ${promoPrice}   ${promotionalPrcnt}    ${showPromoPrice}    ${note}     ${promoLabelType}    ${promoLabel}    ${itemCode}      
   ${data}=  Create Dictionary   itemId=${id}  displayName=${displayName}  shortDesc=${shortDesc}  itemDesc=${itemDesc}  price=${price}  taxable=${taxable}   status=${status}  itemName=${itemName}  itemNameInLocal=${itemNameInLocal}  isStockAvailable=${stockAvailable}  isShowOnLandingpage=${showOnLandingpage}   promotionalPriceType=${promoPriceType}  promotionalPrice=${promoPrice}    promotionalPrcnt=${promotionalPrcnt}  note=${note}   showPromotionalPrice=${showPromoPrice}   itemCode=${itemCode}  promotionLabelType=${promoLabelType}  promotionLabel=${promoLabel}
   ${data}=    json.dumps    ${data}
   Check And Create YNW Session 
   ${resp}=    PUT On Session    ynw  /provider/items   data=${data}  expected_status=any
   [Return]  ${resp}



Update Virtual Order Item
   [Arguments]     ${id}   ${displayName}    ${shortDesc}    ${itemDesc}    ${price}    ${taxable}    ${itemName}    ${itemNameInLocal}    ${stockAvailable}    ${showOnLandingpage}    ${promoPriceType}   ${promoPrice}   ${promotionalPrcnt}    ${showPromoPrice}    ${note}     ${promoLabelType}    ${promoLabel}    ${itemCode}    ${itemType}   ${expiryDate} 
   ${data}=  Create Dictionary   itemId=${id}  displayName=${displayName}  shortDesc=${shortDesc}  itemDesc=${itemDesc}  price=${price}  
   ...   taxable=${taxable}   itemName=${itemName}  itemNameInLocal=${itemNameInLocal}  isStockAvailable=${stockAvailable}  
   ...   isShowOnLandingpage=${showOnLandingpage}   promotionalPriceType=${promoPriceType}  promotionalPrice=${promoPrice}    
   ...   promotionalPrcnt=${promotionalPrcnt}  note=${note}   showPromotionalPrice=${showPromoPrice}   itemCode=${itemCode}  
   ...   promotionLabelType=${promoLabelType}  promotionLabel=${promoLabel}   itemType=${itemType}  expiryDate=${expiryDate}
   ${data}=    json.dumps    ${data}
   Check And Create YNW Session 
   ${resp}=    PUT On Session    ynw  /provider/items   data=${data}  expected_status=any
   [Return]  ${resp}


Get Item By Criteria
    [Arguments]   &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/items  params=${param}  expected_status=any
    [Return]  ${resp}


Add Item Label
    [Arguments]   ${itemId}  &{kwargs}
    ${items}=  Get Dictionary items  ${kwargs}
    ${data}=  Create Dictionary
    FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    Log  ${data}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/items/label/${itemId}  data=${data}  expected_status=any
    [Return]  ${resp}


Remove Item Label
	[Arguments]    ${itemId}   ${LabelName}
	Check And Create YNW Session
    ${resp}=   DELETE On Session  ynw  /provider/items/label/${itemId}/${LabelName}   expected_status=any
    [Return]  ${resp}


Create Order By Provider For Pickup
    [Arguments]    ${Cookie}   ${Consumer_id}  ${orderfor}  ${catalog_id}  ${storePickup}   ${stime}  ${etime}   ${orderDate}  ${phoneNumber}   ${email}  ${orderNote}   ${countryCode}   @{vargs}  &{kwargs}  
    ${catalog}=     Create Dictionary  id=${catalog_id} 
    ${Cid}=  Create Dictionary  id=${Consumer_id}
    ${orderfor}=  Create Dictionary  id=${orderfor}
    ${time}=      Create Dictionary   sTime=${stime}  eTime=${etime}
    ${modes}=  Get Dictionary items  ${kwargs}
    ${len}=  Get Length  ${vargs}
    ${items}=  Create Dictionary  id=${vargs[0]}  quantity=${vargs[1]}
    ${orderitem}=  Create List  ${items}
    FOR    ${index}   IN RANGE   2  ${len}  2
        ${index2}=  Evaluate  ${index}+1
        ${items}=  Create Dictionary  id=${vargs[${index}]}  quantity=${vargs[${index2}]}
        Append To List  ${orderitem}  ${items}
    END

    ${order}=    Create Dictionary    storePickup=${storePickup}   catalog=${catalog}  orderFor=${orderfor}  consumer=${Cid}  timeSlot=${time}  orderItem=${orderitem}   orderNote=${orderNote}   orderDate=${orderDate}  phoneNumber=${phoneNumber}  email=${email}  countryCode=${countryCode}
    FOR  ${key}  ${value}  IN  @{modes}
        Set To Dictionary  ${order}   ${key}=${value}
    END
    Log  ${order} 
    ${resp}=  OrderItemByProvider   ${Cookie}   ${order}
    [Return]  ${resp}


Create Order By Provider For HomeDelivery
    [Arguments]    ${Cookie}   ${Consumer_id}  ${orderfor}  ${catalog_id}   ${homeDelivery}  ${homeDeliveryAddress}  ${stime}  ${etime}   ${orderDate}  ${phoneNumber}   ${email}  ${orderNote}  ${countryCode}  @{vargs}  &{kwargs}
    ${catalog}=     Create Dictionary  id=${catalog_id} 
    ${Cid}=  Create Dictionary  id=${Consumer_id}
    ${orderfor}=  Create Dictionary  id=${orderfor}
    ${time}=      Create Dictionary   sTime=${stime}  eTime=${etime}
    ${modes}=  Get Dictionary items  ${kwargs}
    ${len}=  Get Length  ${vargs}
    ${items}=  Create Dictionary  id=${vargs[0]}  quantity=${vargs[1]}
    ${orderitem}=  Create List  ${items}
    FOR    ${index}   IN RANGE   2  ${len}  2
        ${index2}=  Evaluate  ${index}+1
        ${items}=  Create Dictionary  id=${vargs[${index}]}  quantity=${vargs[${index2}]}
        Append To List  ${orderitem}  ${items}
    END
    ${order}=    Create Dictionary  homeDelivery=${homeDelivery}  homeDeliveryAddress=${homeDeliveryAddress}   catalog=${catalog}  orderFor=${orderfor}  consumer=${Cid}  timeSlot=${time}  orderItem=${orderitem}   orderNote=${orderNote}  orderDate=${orderDate}  phoneNumber=${phoneNumber}  email=${email}  countryCode=${countryCode}   
    FOR  ${key}  ${value}  IN  @{modes}
        Set To Dictionary  ${order}   ${key}=${value}
    END
    Log  ${order} 
    ${resp}=  OrderItemByProvider   ${Cookie}   ${order}
    [Return]  ${resp}


Create Order By Provider For Electronic Delivery
    [Arguments]    ${Cookie}   ${Consumer_id}  ${orderfor}  ${catalog_id}  ${orderDate}  ${phoneNumber}   ${email}  ${orderNote}  ${countryCode}  @{vargs}
    ${catalog}=     Create Dictionary  id=${catalog_id} 
    ${Cid}=  Create Dictionary  id=${Consumer_id}
    ${orderfor}=  Create Dictionary  id=${orderfor}
    ${len}=  Get Length  ${vargs}
    ${items}=  Create Dictionary  id=${vargs[0]}  quantity=${vargs[1]}
    ${orderitem}=  Create List  ${items}
    FOR    ${index}   IN RANGE   2  ${len}  2
        ${index2}=  Evaluate  ${index}+1
        ${items}=  Create Dictionary  id=${vargs[${index}]}  quantity=${vargs[${index2}]}
        Append To List  ${orderitem}  ${items}
    END

    ${order}=    Create Dictionary   catalog=${catalog}  orderFor=${orderfor}  consumer=${Cid}  orderItem=${orderitem}   orderNote=${orderNote}  orderDate=${orderDate}  phoneNumber=${phoneNumber}  email=${email}  countryCode=${countryCode}
    ${resp}=  OrderItemByProvider   ${Cookie}   ${order}
    [Return]  ${resp}


Upload ShoppingList By Provider for Pickup
    [Arguments]   ${cookie}   ${Consumer_id}   ${caption}   ${orderFor}    ${CatalogId}   ${storePickup}    ${Date}    ${sTime1}    ${eTime1}   ${phoneNumber}    ${email}   
    ${catalog}=  Create Dictionary  id=${CatalogId}
    ${Cid}=  Create Dictionary  id=${Consumer_id}
    ${orderFor}=  Create Dictionary  id=${orderFor}
    ${timeSlot}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${order}=  Create Dictionary  storePickup=${storePickup}  catalog=${catalog}  orderFor=${orderFor}  consumer=${Cid}  orderDate=${Date}   timeSlot=${timeSlot}  phoneNumber=${phoneNumber}  countryCode=91  email=${email}
    ${resp}=  OrderImageUploadByProvider   ${Cookie}   ${caption}   ${order}
    [Return]  ${resp} 


Upload ShoppingList By Provider for HomeDelivery
    [Arguments]   ${cookie}   ${Consumer_id}   ${caption}   ${orderFor}    ${CatalogId}   ${homeDelivery}    ${homeDeliveryAddress}  ${Date}    ${sTime1}    ${eTime1}   ${phoneNumber}    ${email}   
    ${catalog}=  Create Dictionary  id=${CatalogId}
    ${Cid}=  Create Dictionary  id=${Consumer_id}
    ${orderFor}=  Create Dictionary  id=${orderFor}
    ${timeSlot}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${order}=  Create Dictionary  homeDelivery=${homeDelivery}  homeDeliveryAddress=${homeDeliveryAddress}   catalog=${catalog}  orderFor=${orderFor}  consumer=${Cid}  orderDate=${Date}   timeSlot=${timeSlot}  phoneNumber=${phoneNumber}  countryCode=91  email=${email}
    ${resp}=  OrderImageUploadByProvider   ${Cookie}   ${caption}   ${order}
    [Return]  ${resp} 


Create Catalog For ShoppingCart
    [Arguments]   ${catalogName}   ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}  ${min}   ${max}    ${cancellationPolicy}   &{kwargs}   
    ${items}=  Get Dictionary items  ${kwargs}
    ${data}=  Create Dictionary   catalogName=${catalogName}   catalogDesc=${catalogDesc}  catalogSchedule=${catalogSchedule}   orderType=${orderType}   paymentType=${paymentType}   orderStatuses=${orderStatuses}   catalogItem=${catalogItem}  minNumberItem=${min}   maxNumberItem=${max}    cancellationPolicy=${cancellationPolicy}
    FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    Log  ${data}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session 
    ${resp}=  POST On Session  ynw  /provider/catalog  data=${data}  expected_status=any
    [Return]  ${resp}



Update Catalog For ShoppingCart
    [Arguments]   ${catalogId}   ${catalogName}   ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}  ${min}   ${max}    ${cancellationPolicy}   &{kwargs}
    ${items}=  Get Dictionary items  ${kwargs}
    ${data}=  Create Dictionary   id=${catalogId}   catalogName=${catalogName}   catalogDesc=${catalogDesc}  catalogSchedule=${catalogSchedule}   orderType=${orderType}   paymentType=${paymentType}   orderStatuses=${orderStatuses}   catalogItem=${catalogItem}  minNumberItem=${min}   maxNumberItem=${max}    cancellationPolicy=${cancellationPolicy}
    FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    Log  ${data}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session 
    ${resp}=  PUT On Session  ynw  /provider/catalog  data=${data}  expected_status=any
    [Return]  ${resp}


Create Catalog For ShoppingList
    [Arguments]   ${catalogName}   ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${min}   ${max}    ${cancellationPolicy}   &{kwargs}
    ${items}=  Get Dictionary items  ${kwargs}
    ${data}=  Create Dictionary   catalogName=${catalogName}   catalogDesc=${catalogDesc}  catalogSchedule=${catalogSchedule}   orderType=SHOPPINGLIST   paymentType=${paymentType}   orderStatuses=${orderStatuses}   minNumberItem=${min}   maxNumberItem=${max}    cancellationPolicy=${cancellationPolicy}
    FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    Log  ${data}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session 
    ${resp}=  POST On Session  ynw  /provider/catalog  data=${data}  expected_status=any
    [Return]  ${resp}


Update Catalog For ShoppingList
    [Arguments]   ${catalogId}   ${catalogName}   ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${min}   ${max}    ${cancellationPolicy}   &{kwargs}
    ${items}=  Get Dictionary items  ${kwargs}
    ${data}=  Create Dictionary   id=${catalogId}   catalogName=${catalogName}   catalogDesc=${catalogDesc}  catalogSchedule=${catalogSchedule}   orderType=SHOPPINGLIST   paymentType=${paymentType}   orderStatuses=${orderStatuses}   minNumberItem=${min}   maxNumberItem=${max}    cancellationPolicy=${cancellationPolicy}
    FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    Log  ${data}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session 
    ${resp}=  PUT On Session  ynw  /provider/catalog  data=${data}  expected_status=any
    [Return]  ${resp}


Order Mass Communication
    [Arguments]   ${cookie}   ${email}  ${sms}  ${push_notf}   ${telegram}   ${msg}    ${fileswithcaption}   @{vargs}
    ${input}=  Create Dictionary  email=${email}  sms=${sms}  pushNotification=${push_notf}     telegram=${telegram}
    # ${orderitem}=  Create List  ${vargs}
    ${data}=  Create Dictionary   medium=${input}   communicationMessage=${msg}  uuid=${vargs}
    ${resp}=    Imageupload.providerOrderMassCommunication    ${cookie}     ${data}     @{fileswithcaption}
    # ${data}=   json.dumps    ${data}
    # Check And Create YNW Session
    # ${resp}=    POST On Session   ynw    /provider/orders/consumerMassCommunication     data=${data}  expected_status=any
    [Return]  ${resp}

    
Get Order Catalog
    [Arguments]  ${CatalogId}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/catalog/${CatalogId}   expected_status=any
    [Return]  ${resp}


Get Catalog By Criteria
    [Arguments]   &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/catalog  params=${param}  expected_status=any
    [Return]  ${resp}


Change Catalog Status
    [Arguments]  ${catalogId}   ${status}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/catalog/${catalogId}/${status}   expected_status=any  
    [Return]  ${resp}


Add Items To Catalog
    [Arguments]   ${CatalogId}   ${Items}
    ${Items}=  json.dumps  ${Items}
    Check And Create YNW Session 
    ${resp}=  POST On Session  ynw  /provider/catalog/${CatalogId}/items  data=${Items}  expected_status=any
    [Return]  ${resp}


Get Item From Catalog
    [Arguments]  ${CatalogId}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/catalog/${CatalogId}/items   expected_status=any
    [Return]  ${resp}


Update Single Catalog Item
   [Arguments]     ${CatalogId}  ${itemId}   ${minQuantity}    ${maxQuantity}  
   ${data}=  Create Dictionary   id=${itemId}  catalogId=${CatalogId}   minQuantity=${minQuantity}  maxQuantity=${maxQuantity} 
   ${data}=    json.dumps    ${data}
   Check And Create YNW Session 
   ${resp}=    PUT On Session    ynw  /provider/catalog/item   data=${data}  expected_status=any
   [Return]  ${resp}


Update Multiple Catalog Items
   [Arguments]     ${CatalogId}  ${Items_List}
   ${Items_List}=  json.dumps  ${Items_List}
   Check And Create YNW Session 
   ${resp}=    PUT On Session    ynw  /provider/catalog/${CatalogId}/items   data=${Items_List}  expected_status=any
   [Return]  ${resp}


Remove Multiple Items From Catalog
	[Arguments]    ${CatalogId}   @{vargs}
    ${data}=   Create List  @{vargs}
    Log  ${data}
    ${data}=    json.dumps    ${data}
	Check And Create YNW Session
    ${resp}=   DELETE On Session  ynw  /provider/catalog/${CatalogId}/items   data=${data}  expected_status=any 
    [Return]  ${resp}


Remove Single Item From Catalog
	[Arguments]    ${CatalogId}   ${itemId}
	Check And Create YNW Session
    ${resp}=   DELETE On Session  ynw  /provider/catalog/${CatalogId}/item/${itemId}  expected_status=any
    [Return]  ${resp}


Get Default Catalog Status
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/catalog/statuses   expected_status=any
    [Return]  ${resp}


Create MR 
    [Arguments]   ${uuid}  ${bookingType}  ${consultationMode}  ${mrConsultationDate}  ${state}  &{kwargs}
    ${items}=  Get Dictionary items  ${kwargs}
    ${data}=  Create Dictionary   bookingType=${bookingType}   consultationMode=${consultationMode}  mrConsultationDate=${mrConsultationDate}   state=${state}
    FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    Log  ${data}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/mr/${uuid}   data=${data}  expected_status=any
    [Return]  ${resp}

Share Prescription Thirdparty
    [Arguments]  ${mrId}   ${msg}  ${html}  ${phone}  ${email}  ${expirableLink}  ${expireTimeInMinuts}  ${countryCode}=91   
    Check And Create YNW Session
    ${shareThirdParty}=  Create Dictionary     phone=${phone}    email=${email}   countryCode=${countryCode}
    ${data}=  Create Dictionary  message=${msg}   html=${html}   shareThirdParty=${shareThirdParty}   expirableLink=${expirableLink}   expireTimeInMinuts=${expireTimeInMinuts}   countryCode=${countryCode}
    ${data}=    json.dumps    ${data}
    ${resp}=  POST On Session  ynw  /provider/mr/sharePrescription/thirdParty/${mrId}  data=${data}  expected_status=any
    [Return]  ${resp}

Block Appointment For Consumer
    [Arguments]    ${service_id}  ${schedule_id}  ${appmtDate}  ${appmtFor}
    ${schedule}=  Create Dictionary  id=${schedule_id}
    ${service}=  Create Dictionary  id=${service_id}
    ${data}=    Create Dictionary   service=${service}   schedule=${schedule}   appmtDate=${appmtDate}   appmtFor=${appmtFor}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/appointment/block  data=${data}  expected_status=any
    [Return]  ${resp}


Confirm Blocked Appointment
    [Arguments]   ${cons_id}  ${appointment_id}   ${appmtFor}
    ${consumer}=  Create Dictionary  id=${cons_id} 
    ${data}=    Create Dictionary   appmtFor=${appmtFor}  uid=${appointment_id}  consumer=${consumer}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/appointment/confirm  data=${data}  expected_status=any
    [Return]  ${resp}


Unblock Appointment Slot
    [Arguments]    ${appointment_id}  
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/appointment/unblock/${appointment_id}   expected_status=any
    [Return]  ${resp}


# Update MR by mr id
#    [Arguments]  ${mrid}  ${bookingType}  ${consultationMode}  ${complaints}  ${symptoms}  ${allergies}  ${vaccinationHistory}  ${observations}  ${diagnosis}  ${misc_notes}   ${mrConsultationDate}  ${state}   @{vargs}
# #    ${providerConsumer}=  Create Dictionary  id=${id}
#    ${clinicalNotes}=  Create Dictionary  complaints=${complaints}  symptoms=${symptoms}  allergies=${allergies}  vaccinationHistory=${vaccinationHistory}  observations=${observations}  diagnosis=${diagnosis}  misc_notes=${misc_notes}
   
#    ${len}=  Get Length  ${vargs}
#    ${prescription}=  Create Dictionary  medicine_name=${vargs[0]}  frequency=${vargs[1]}  duration=${vargs[2]}  instructions=${vargs[3]}
#    ${loan}=  Create List  ${prescription}
   
#     FOR    ${index}    IN RANGE  4  ${len}   4
#         Exit For Loop If  ${len}==0
#         ${index2}=  Evaluate  ${index}+1
#         ${index3}=  Evaluate  ${index}+2
#         ${index4}=  Evaluate  ${index}+3      
#     	${prescription}=  Create Dictionary  medicine_name=${vargs[${index}]}  frequency=${vargs[${index2}]}  duration=${vargs[${index3}]}  instructions=${vargs[${index4}]}
#         Append To List  ${loan}  ${prescription}
#     END
#    ${data}=  Create Dictionary    bookingType=${bookingType}  consultationMode=${consultationMode}  clinicalNotes=${clinicalNotes}  loan=${loan}   mrConsultationDate=${mrConsultationDate}  state=${state}
#    ${data}=  json.dumps  ${data}
#    Check And Create YNW Session
#    ${resp}=  PUT On Session  ynw  /provider/mr/${mrid}  data=${data}  expected_status=any
#    [Return]  ${resp}


# Update MR by mr id
#     [Arguments]  ${mrid}  ${bookingType}  ${consultationMode}  ${complaints}  ${symptoms}  ${allergies}  ${vaccinationHistory}  ${observations}  ${diagnosis}  ${misc_notes}   ${notes}  ${mrConsultationDate}  ${state}   @{vargs}
#     ${clinicalNotes}=  Create Dictionary  complaints=${complaints}  symptoms=${symptoms}  allergies=${allergies}  vaccinationHistory=${vaccinationHistory}  observations=${observations}  diagnosis=${diagnosis}  misc_notes=${misc_notes} 
    
#     ${len}=  Get Length  ${vargs}
#     ${prescriptionsList}=  Create List  

#     FOR    ${index}    IN RANGE    ${len}   
#         Exit For Loop If  ${len}==0
#         Append To List  ${prescriptionsList}  ${vargs[${index}]}
#     END

#     ${prescriptions}=  Create Dictionary  prescriptionsList=${prescriptionsList}  notes=${notes}  

#    ${data}=  Create Dictionary    bookingType=${bookingType}  consultationMode=${consultationMode}  clinicalNotes=${clinicalNotes}  prescriptions=${prescriptions}   mrConsultationDate=${mrConsultationDate}  state=${state}
#    ${data}=  json.dumps  ${data}
#    Check And Create YNW Session
#    ${resp}=  PUT On Session  ynw  /provider/mr/${mrid}  data=${data}  expected_status=any
#    [Return]  ${resp}

Update MR by mr id
    [Arguments]  ${mrid}  ${bookingType}  ${consultationMode}    ${mrConsultationDate}  ${state}    &{kwargs}
    
    ${data}=  Create Dictionary    bookingType=${bookingType}  consultationMode=${consultationMode}    mrConsultationDate=${mrConsultationDate}  state=${state}     
    FOR  ${key}  ${value}  IN  &{kwargs}
             Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/mr/${mrid}  data=${data}  expected_status=any
    [Return]  ${resp}


# Add Label for Customer
#     [Arguments]    ${labelName}  ${labelValue}   @{vargs}
#     ${proConIds}=   Create List  @{vargs}
#     ${data}=    Create Dictionary  labelName=${labelName}  labelValue=${labelValue}  proConIds=${proConIds}
#     ${data}=    json.dumps    ${data}
#     Check And Create YNW Session
#     ${resp}=  POST On Session  ynw  /provider/customers/label  data=${data}  expected_status=any
#     [Return]  ${resp}

Add Labels for Customers
    [Arguments]  ${label_dict}  @{pc_id}
    ${len}=  Get Length  ${pc_id}
    ${procon_id}=  Create List
    FOR  ${value}  IN  @{pc_id}
        Append To List  ${procon_id}  ${value}
    END
    ${data}=    Create Dictionary  proConIds=${procon_id}  labels=${label_dict}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/customers/label   data=${data}  expected_status=any
    [Return]  ${resp}


Remove Labels from Customers
    [Arguments]  ${labelnames_list}  @{pc_id}
    ${len}=  Get Length  ${pc_id}
    ${procon_id}=  Create List
    FOR  ${value}  IN  @{pc_id}
        Append To List  ${procon_id}  ${value}
    END
    ${data}=    Create Dictionary  proConIds=${procon_id}  labelNames=${labelnames_list}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw  /provider/customers/masslabel  data=${data}  expected_status=any
    [Return]  ${resp}

Remove Customer Label
    [Arguments]   ${proConId}  ${labelName}
    Check And Create YNW Session
    ${resp}=    DELETE On Session    ynw  /provider/customers/${proConId}/label/${labelName}  expected_status=any
    [Return]  ${resp}

Update Order For HomeDelivery
    [Arguments]    ${uid}  ${homeDelivery}  ${homeDeliveryAddress}  ${stime}  ${etime}   ${orderDate}  ${phoneNumber}   ${email}  ${countryCode}
    ${time}=      Create Dictionary   sTime=${stime}  eTime=${etime}
    ${data}=    Create Dictionary    uid=${uid}   homeDelivery=${homeDelivery}  homeDeliveryAddress=${homeDeliveryAddress}   timeSlot=${time}  orderDate=${orderDate}  phoneNumber=${phoneNumber}  email=${email}   countryCode=${countryCode} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/orders  data=${data}  expected_status=any
    [Return]  ${resp}

Update Order For Pickup
    [Arguments]    ${uid}  ${storePickup}   ${stime}  ${etime}   ${orderDate}  ${phoneNumber}   ${email}  ${countryCode}
    ${time}=      Create Dictionary   sTime=${stime}  eTime=${etime}
    ${data}=    Create Dictionary    uid=${uid}   storePickup=${storePickup}   timeSlot=${time}  orderDate=${orderDate}  phoneNumber=${phoneNumber}  email=${email}   countryCode=${countryCode} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/orders  data=${data}  expected_status=any
    [Return]  ${resp}


Update Order For Electronic Delivery
    [Arguments]    ${uid}   ${orderDate}  ${phoneNumber}   ${email}  ${countryCode}
    ${data}=    Create Dictionary    uid=${uid}  orderDate=${orderDate}  phoneNumber=${phoneNumber}  email=${email}   countryCode=${countryCode} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/orders  data=${data}  expected_status=any
    [Return]  ${resp}


Update Order Items By Provider
    [Arguments]     ${uuid}   @{vargs}
    ${len}=  Get Length  ${vargs}
    ${items}=  Create Dictionary  id=${vargs[0]}  quantity=${vargs[1]}   storeComment=${vargs[2]}
    ${orderitem}=  Create List  ${items}
    FOR    ${index}   IN RANGE   3  ${len}  3
        ${index2}=  Evaluate  ${index}+1
        ${index3}=  Evaluate  ${index}+2
        ${items}=  Create Dictionary  id=${vargs[${index}]}  quantity=${vargs[${index2}]}   storeComment=${vargs[${index3}]}
        Append To List  ${orderitem}  ${items}
    END
    ${data}=  json.dumps  ${orderitem}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/orders/item/${uuid}   data=${data}  expected_status=any
    [Return]  ${resp}

Get Order by uid
    [Arguments]     ${uid}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/orders/${uid}  expected_status=any
    [Return]  ${resp}

Change Order Status 
    [Arguments]  ${uuid}  ${orderAction}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/orders/${uuid}/${orderAction}   expected_status=any
    [Return]  ${resp}

Get Order Status Changes by uid 
    [Arguments]   ${uuid}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/orders/states/${uuid}  expected_status=any 
    [Return]  ${resp}

Get Order By Criterias
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /provider/orders  params=${param}  expected_status=any
    [Return]  ${resp}

Get Order count by Criterias
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/orders/count  params=${param}  expected_status=any
    [Return]  ${resp}

Get Order By enclosed ID 
    [Arguments]   ${encId}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/orders/enc/${encId}   expected_status=any
    [Return]  ${resp}

Get Future Order By Criterias
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /provider/orders/future  params=${param}  expected_status=any
    [Return]  ${resp}

Get Future Order count by Criterias
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/orders/future/count  params=${param}  expected_status=any
    [Return]  ${resp}

Update Delivery charge 
    [Arguments]  ${action}  ${uuid}  ${Deliverycharge}
    ${data}=    Create Dictionary    deliveryCharges=${Deliverycharge}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session   ynw  /provider/bill/${action}/${uuid}  data=${data}  expected_status=any
    [Return]  ${resp}
    
Get Order History By Criterias
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /provider/orders/history  params=${param}  expected_status=any
    [Return]  ${resp}

Get Order History count by Criterias
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/orders/history/count  params=${param}  expected_status=any
    [Return]  ${resp}


Add Label for Order
    [Arguments]  ${OrderId}  ${labelname}  ${label_value}
    ${data}=    Create Dictionary  ${labelname}=${label_value}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/orders/label/${OrderId}   data=${data}  expected_status=any
    [Return]  ${resp}  


Remove Label for Order
    [Arguments]  ${OrderId}  ${label}  
    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw  /provider/orders/label/${OrderId}/${label}   expected_status=any
    [Return]  ${resp} 


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
    [Return]  ${resp.json()} 


Add Label for Multiple Order
    [Arguments]  ${labelname}  ${label_value}  @{OrderId}
    ${len}=  Get Length  ${OrderId}
    ${orders}=  Create List
    FOR  ${value}  IN  @{OrderId}
        Append To List  ${orders}  ${value}
    END
    ${data}=    Create Dictionary  uuid=${orders}  labelName=${labelname}   labelValue=${label_value}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/orders/labelBatch  data=${data}  expected_status=any
    [Return]  ${resp}


MultiLocation Domain Providers
    [Arguments]  ${min}=0   ${max}=260
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
	    Run Keyword If  ${resp.json()['filterByDept']}==${bool[1]}   Toggle Department Disable
    END
    [Return]  ${multiloc_providers}

Update Delivery Address
    [Arguments]  ${proConsumerId}   @{vargs}
    ${data}=   json.dumps    ${vargs}
    Check And Create YNW Session
    ${resp}=    PUT On Session   ynw    /provider/orders/consumer/${proConsumerId}/deliveryAddress     data=${data}  expected_status=any
    [Return]  ${resp}

Get Delivery Address
    [Arguments]  ${proConsumerId}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/orders/consumer/${proConsumerId}/deliveryAddress  expected_status=any
    [Return]  ${resp}


Create Customer Group
   [Arguments]  ${groupName}  ${Description}    &{kwargs}
   ${items}=  Get Dictionary items  ${kwargs}
   ${data}=    Create Dictionary  groupName=${groupName}  description=${Description}
   FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${data}   ${key}=${value}
   END
   Log  ${data}
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${response}=  POST On Session  ynw  /provider/customers/group  data=${data}  expected_status=any
   [Return]  ${response}




Get Customer Groups
   
   Check And Create YNW Session
   ${response}=  GET On Session  ynw  /provider/customers/group  expected_status=any
   [Return]  ${response}


Get Customer Group by id
   [Arguments]  ${groupId}
   Check And Create YNW Session
   ${response}=  GET On Session  ynw  /provider/customers/group/${groupId}  expected_status=any
   [Return]  ${response}


Update Customer Group
   [Arguments]  ${groupId}  ${groupName}  ${Description}   &{kwargs}
   ${items}=  Get Dictionary items  ${kwargs}
   ${data}=    Create Dictionary  id=${groupId}   groupName=${groupName}  description=${Description}
   FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${data}   ${key}=${value}
   END
   Log  ${data}
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${response}=  PUT On Session  ynw  /provider/customers/group/  data=${data}  expected_status=any
   [Return]  ${response}


Enable Customer Group
    [Arguments]  ${groupId}
    Check And Create YNW Session
    ${response}=  PUT On Session  ynw  /provider/customers/group/${groupId}/ENABLE    expected_status=any
    [Return]  ${response}


Disable Customer Group
    [Arguments]  ${groupId}
    Check And Create YNW Session
    ${response}=  PUT On Session  ynw  /provider/customers/group/${groupId}/DISABLE    expected_status=any
    [Return]  ${response}


# Add Customers to Group
#     [Arguments]  ${groupName}   @{proConId}
#     ${data}=   json.dumps    ${proConId}
#     Check And Create YNW Session
#     ${response}=    POST On Session   ynw    /provider/customers/group/${groupName}   data=${data}  expected_status=any
#     [Return]  ${response}


Add Customers to Group
    [Arguments]  ${groupName}   @{proConId}
    ${data}=    Create Dictionary  groupName=${groupName}   providerConsumerIds=${proConId} 
    ${data}=   json.dumps    ${data}
    Check And Create YNW Session
    ${response}=    POST On Session   ynw    /provider/customers/group/addGroup   data=${data}  expected_status=any
    [Return]  ${response}

Add MemberId for a consumer in group 

    [Arguments]    ${groupName}      ${proConId}    ${memberId}
    Check And Create YNW Session
    ${response}=    POST On Session   ynw    /provider/customers/groupMemId/${groupName}/${proConId}/${memberId}    expected_status=any
    [Return]  ${response}
    

Get Member Id of a consumer in a group 
    
    [Arguments]  ${groupName}   ${proConId}  
    Check And Create YNW Session
    ${response}=    GET On Session   ynw    provider/customers/groupMemId/${groupName}/${proConId}    expected_status=any
    [Return]  ${response}

Update Member Id for a consumer in a group 

    [Arguments]  ${groupName}   ${proConId}  ${memId}
    Check And Create YNW Session
    ${response}=    PUT On Session   ynw    provider/customers/groupMemId/${groupName}/${proConId}/${memId}   expected_status=any
    [Return]  ${response}

 
Remove Customer from Group
    [Arguments]  ${groupName}   ${proConId}
    Check And Create YNW Session
    ${response}=    DELETE On Session   ynw    /provider/customers/${proConId}/group/${groupName}   expected_status=any    
    [Return]  ${response}


Remove Multiple Customer from Group
    [Arguments]  ${groupName}   @{proConId}
    ${data}=   json.dumps    ${proConId}
    Check And Create YNW Session
    ${response}=    DELETE On Session   ynw    /provider/customers/group/${groupName}   data=${data}  expected_status=any
    [Return]  ${response}


Get Customer Count in Group
   [Arguments]  ${groupId}
   Check And Create YNW Session
   ${response}=  GET On Session  ynw  /provider/customers/group/count/${groupId}  expected_status=any
   [Return]  ${response}


Create Holiday
    [Arguments]  ${rectype}  ${repint}  ${startDate}  ${endDate}  ${noocc}  ${sTime}  ${eTime}  ${desc}
    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noocc}
    ${time}=  Create Dictionary  sTime=${sTime}  eTime=${eTime}
    ${timeslot}=  Create List  ${time}
    ${holidaySchedule}=  Create Dictionary  recurringType=${rectype}  repeatIntervals=${repint}  startDate=${startDate}  terminator=${terminator}  timeSlots=${timeslot}
    ${data}=  Create Dictionary  holidaySchedule=${holidaySchedule}  description=${desc}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /provider/settings/nonBusinessDays/holiday  data=${data}  expected_status=any
    [Return]  ${resp}

Activate Holiday
    [Arguments]  ${status}  ${holidayId}  
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/settings/nonBusinessDays/holiday/mark/${status}/${holidayId}   expected_status=any
    [Return]  ${resp}

Get Holiday By Id
    [Arguments]  ${holidayId}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/settings/nonBusinessDays/holiday/${holidayId}  expected_status=any
    [Return]  ${resp}

Update Holiday
    [Arguments]   ${id}  ${desc}  ${rectype}  ${repint}  ${startDate}  ${endDate}  ${noocc}  ${sTime}  ${eTime}  
    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noocc}
    ${time}=  Create Dictionary  sTime=${sTime}  eTime=${eTime}
    ${timeslot}=  Create List  ${time}
    ${holidaySchedule}=  Create Dictionary  recurringType=${rectype}  repeatIntervals=${repint}  startDate=${startDate}  terminator=${terminator}  timeSlots=${timeslot}
    ${data}=  Create Dictionary      id=${id}  description=${desc}  holidaySchedule=${holidaySchedule} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/settings/nonBusinessDays/holiday  data=${data}  expected_status=any
    [Return]  ${resp}

Delete Holiday
    [Arguments]  ${holidayId}
    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw  /provider/settings/nonBusinessDays/holiday/${holidayId}  expected_status=any
    [Return]  ${resp}

Get Holiday By Account
    Check And Create YNW Session 
    ${resp}=  GET On Session  ynw  /provider/settings/nonBusinessDays/holiday  expected_status=any
    [Return]  ${resp}

Get Next Availability
    [Arguments]  ${rectype}  ${repint}  ${startDate}  ${endDate}  ${noocc}  ${sTime}  ${eTime}  ${rectype1}  ${repint1}  ${startDate1}  ${endDate1}  ${noocc1}  ${sTime1}  ${eTime1}  
    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noocc}
    ${time}=  Create Dictionary  sTime=${sTime}  eTime=${eTime}
    ${timeslot}=  Create List  ${time}
    ${queueSchedule}=  Create Dictionary  recurringType=${rectype}  repeatIntervals=${repint}  startDate=${startDate}  terminator=${terminator}  timeSlots=${timeslot}
    
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noocc1}
    ${time1}=  Create Dictionary  sTime=${sTime1}  eTime=${eTime1}
    ${timeslot1}=  Create List  ${time1}
    ${holidaySchedule}=  Create Dictionary  recurringType=${rectype1}  repeatIntervals=${repint1}  startDate=${startDate1}  terminator=${terminator1}  timeSlots=${timeslot1}
    ${data}=  Create Dictionary    queueSchedule=${queueSchedule}    holidaySchedule=${holidaySchedule}  
    
    ${data}=  json.dumps  ${data}    
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/settings/nonBusinessDays/holiday/availability   data=${data}  expected_status=any
    [Return]  ${resp}


Get Provider Waitlist Attachment
   [Arguments]      ${uuid}
   Check And Create YNW Session
   ${resp}=    GET On Session    ynw  /provider/waitlist/attachment/${uuid}      expected_status=any
   [Return]  ${resp}


Get Provider Appointment Attachment
   [Arguments]      ${uuid}
   Check And Create YNW Session
   ${resp}=    GET On Session    ynw  /provider/appointment/attachment/${uuid}      expected_status=any
   [Return]  ${resp}


Get Provider Consumer Orders
   [Arguments]      ${proconsid}
   Check And Create YNW Session
   ${resp}=    GET On Session    ynw  /provider/orders/customer/${proconsid}      expected_status=any
   [Return]  ${resp}


Create Vacation 
    [Arguments]  ${desc}  ${pid}  ${rectype}  ${repint}  ${startDate}  ${endDate}  ${noocc}  ${sTime}  ${eTime}  
    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noocc}
    ${time}=  Create Dictionary  sTime=${sTime}  eTime=${eTime}
    ${timeslot}=  Create List  ${time}
    ${holidaySchedule}=  Create Dictionary  recurringType=${rectype}  repeatIntervals=${repint}  startDate=${startDate}  terminator=${terminator}  timeSlots=${timeslot}  
    ${data}=  Create Dictionary  description=${desc}  providerId=${pid}  holidaySchedule=${holidaySchedule}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /provider/vacation/vacations  data=${data}  expected_status=any
    [Return]  ${resp}

Activate Vacation
    [Arguments]   ${status}   ${vacationId}  
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/vacation/mark/${status}/${vacationId}  expected_status=any
    [Return]  ${resp}

Update Vacation 
	[Arguments]    ${id}  ${desc}  ${pid}  ${rectype}  ${repint}  ${startDate}  ${endDate}  ${noocc}  ${sTime}  ${eTime}  
    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noocc}
    ${time}=  Create Dictionary  sTime=${sTime}  eTime=${eTime}
    ${timeslot}=  Create List  ${time}
    ${holidaySchedule}=  Create Dictionary  recurringType=${rectype}  repeatIntervals=${repint}  startDate=${startDate}  terminator=${terminator}  timeSlots=${timeslot} 
    ${data}=  Create Dictionary  id=${id}  description=${desc}  providerId=${pid}  holidaySchedule=${holidaySchedule}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/vacation/vacations  data=${data}  expected_status=any
    [Return]  ${resp}

    
Get Vacation By Id
	[Arguments]    ${vacationId}	
	Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/vacation/vacations/${vacationId}   expected_status=any
    [Return]  ${resp}  

Get Vacation
	[Arguments]    ${providerId}
	Check And Create YNW Session
	${resp}=  GET On Session  ynw  /provider/vacation/getvacation/${providerId}    expected_status=any
	[Return]  ${resp}  


Delete Vacation
    [Arguments]  ${vacationId}
    Check And Create YNW Session
    ${resp}=  DELETE On Session   ynw   /provider/vacation/vacations/${vacationId}   expected_status=any
    [Return]  ${resp}

Get Vacation Next Availability 
    [Arguments]  ${rectype}  ${repint}  ${startDate}  ${endDate}  ${noocc}  ${sTime}  ${eTime}  ${rectype1}  ${repint1}  ${startDate1}  ${endDate1}  ${noocc1}  ${sTime1}  ${eTime1}  
    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noocc}
    ${time}=  Create Dictionary  sTime=${sTime}  eTime=${eTime}
    ${timeslot}=  Create List  ${time}
    ${queueSchedule}=  Create Dictionary  recurringType=${rectype}  repeatIntervals=${repint}  startDate=${startDate}  terminator=${terminator}  timeSlots=${timeslot}
    
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noocc1}
    ${time1}=  Create Dictionary  sTime=${sTime1}  eTime=${eTime1}
    ${timeslot1}=  Create List  ${time1}
    ${holidaySchedule}=  Create Dictionary  recurringType=${rectype1}  repeatIntervals=${repint1}  startDate=${startDate1}  terminator=${terminator1}  timeSlots=${timeslot1}
    ${data}=  Create Dictionary    queueSchedule=${queueSchedule}    holidaySchedule=${holidaySchedule}  
    
    ${data}=  json.dumps  ${data}    
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/vacation/availability   data=${data}  expected_status=any
    [Return]  ${resp}

    
Create Provider Coupon 
    [Arguments]  ${name}   ${description}   ${amount}   ${calculationType}  ${couponCode}  ${rt}  ${ri}  ${sTime}  ${eTime}  ${sDate}  ${eDate}   ${noo}  ${firstCheckinOnly}  ${minBillAmount}  ${maxDiscountValue}  ${isproviderAcceptCoupon}  ${maxProviderUseLimit}  ${bookingChannel}  ${couponBasedOn}  ${tc}  &{kwargs}
    ${validTimeRange}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime} 
    ${policies}=  Create Dictionary  
    ${policie}=  Get Dictionary items  ${kwargs}
    FOR  ${key}  ${value}  IN  @{policie}
        Set To Dictionary  ${policies}   ${key}=${value}
    END
    Log  ${policies}  
    ${validTimeRange}=  Create List  ${validTimeRange}
    ${couponRules}=  Create Dictionary  startDate=${sDate}  endDate=${eDate}  firstCheckinOnly=${firstCheckinOnly}  minBillAmount=${minBillAmount}  maxDiscountValue=${maxDiscountValue}  isproviderAcceptCoupon=${isproviderAcceptCoupon}  maxProviderUseLimit=${maxProviderUseLimit}  validTimeRange=${validTimeRange}  policies=${policies}
    ${data}=  Create Dictionary   name=${name}  amount=${amount}  description=${description}   calculationType=${calculationType}  couponCode=${couponCode}  couponRules=${couponRules}  bookingChannel=${bookingChannel}  couponBasedOn=${couponBasedOn}  termsConditions=${tc}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/bill/coupons   data=${data}  expected_status=any
    [Return]  ${resp}


Update Provider Coupon 
    [Arguments]  ${id}  ${name}   ${description}   ${amount}   ${calculationType}  ${couponCode}  ${rt}  ${ri}  ${sTime}  ${eTime}  ${sDate}  ${eDate}   ${noo}  ${firstCheckinOnly}  ${minBillAmount}  ${maxDiscountValue}  ${isproviderAcceptCoupon}  ${maxProviderUseLimit}  ${bookingChannel}  ${couponBasedOn}  ${tc}  &{kwargs}
    ${validTimeRange}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime} 
    ${policies}=  Create Dictionary    
    ${policie}=  Get Dictionary items  ${kwargs}
    FOR  ${key}  ${value}  IN  @{policie}
        Set To Dictionary  ${policies}   ${key}=${value}
    END
    Log  ${policies}  
    ${validTimeRange}=  Create List  ${validTimeRange}
    ${couponRules}=  Create Dictionary  startDate=${sDate}  endDate=${eDate}  firstCheckinOnly=${firstCheckinOnly}  minBillAmount=${minBillAmount}  maxDiscountValue=${maxDiscountValue}  isproviderAcceptCoupon=${isproviderAcceptCoupon}  maxProviderUseLimit=${maxProviderUseLimit}  validTimeRange=${validTimeRange}  policies=${policies}
    ${data}=  Create Dictionary  id=${id}   name=${name}  amount=${amount}  description=${description}   calculationType=${calculationType}  couponCode=${couponCode}  couponRules=${couponRules}  bookingChannel=${bookingChannel}  couponBasedOn=${couponBasedOn}  termsConditions=${tc}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bill/coupons   data=${data}  expected_status=any
    [Return]  ${resp}
    

Publish Provider Coupon
    [Arguments]  ${coupon_id}   ${publish_from}  ${publish_to}
    ${couponRules}=    Create Dictionary    publishedFrom=${publish_from}   publishedTo=${publish_to}
    ${data}=   Create Dictionary    id=${coupon_id}    couponRules=${couponRules}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session   ynw  /provider/bill/coupons/${coupon_id}/publish  data=${data}  expected_status=any
    [Return]  ${resp}
    

Add Multiple Labels for Order
    [Arguments]  ${label_dict}  @{OrderId}
    ${len}=  Get Length  ${OrderId}
    ${orders}=  Create List
    FOR  ${value}  IN  @{OrderId}
        Append To List  ${orders}  ${value}
    END
    ${data}=    Create Dictionary  uuid=${orders}  labels=${label_dict}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/orders/labelsBatch  data=${data}  expected_status=any
    [Return]  ${resp}

Remove Multiple Labels from Order
    [Arguments]  ${labelname_list}  @{OrderId}
    ${len}=  Get Length  ${OrderId}
    ${orders}=  Create List
    FOR  ${value}  IN  @{OrderId}
        Append To List  ${orders}  ${value}
    END
    ${data}=    Create Dictionary  uuid=${orders}  labelNames=${labelname_list}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw  /provider/orders/masslabel   data=${data}  expected_status=any
    [Return]  ${resp}

Get waitlist Service By Location   
    [Arguments]  ${locationId}   
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/waitlist/services/${locationId}  expected_status=any     
    [Return]  ${resp} 

Get Appoinment Service By Location   
    [Arguments]  ${locationId}   
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/appointment/service/${locationId}  expected_status=any     
    [Return]  ${resp} 


Get Questionnaire List By Provider      
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/questionnaire  expected_status=any     
    [Return]  ${resp}


Get Provider Questionnaire By Id    
    [Arguments]  ${qnrid}   
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/questionnaire/${qnrid}  expected_status=any     
    [Return]  ${resp}


Get Questionnaire for Consumer     
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/questionnaire/consumer  expected_status=any     
    [Return]  ${resp}


Get Consumer Questionnaire By Channel and ServiceID    
    [Arguments]  ${serviceId}  ${channel}   ${consumerid}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/questionnaire/service/${serviceId}/${channel}/consumer/${consumerid}  expected_status=any     
    [Return]  ${resp}


Provider Change Questionnaire Status    
    [Arguments]  ${qnrid}   ${status}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  /provider/questionnaire/change/${status}/${qnrid}  expected_status=any     
    [Return]  ${resp}


Run JCash Expiry Agent
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/credit/jcash/removeExpired     expected_status=any
    [Return]  ${resp}


Get LocByPincode
    [Arguments]  ${pincode} 
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/account/settings/locByPincode/${pincode}  expected_status=any     
    [Return]  ${resp}

Get LocationsByPincode
    [Arguments]  ${pincode}  
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/account/settings/locations/${pincode}   expected_status=any     
    [Return]  ${resp}

Is Available Queue Now ByProviderId
    [Arguments]  ${uid}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/waitlist/queues/isAvailableNow/today/${uid}  expected_status=any
    [Return]  ${resp}

Assign provider Waitlist
    [Arguments]    ${uid}  ${providerid}  
    ${provider}=   Create Dictionary    id=${providerid}
    ${data}=    Create Dictionary    ynwUuid=${uid}   provider=${provider} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/waitlist/update  data=${data}  expected_status=any
    [Return]  ${resp}

Assign provider Appointment 
    [Arguments]    ${uid}  ${providerid}  
    ${provider}=   Create Dictionary    id=${providerid}
    ${data}=    Create Dictionary    uid=${uid}   provider=${provider} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/appointment/update  data=${data}  expected_status=any
    [Return]  ${resp}

Un Assign provider waitlist
    [Arguments]    ${uid}  ${providerid}  
    ${provider}=   Create Dictionary    id=${providerid}
    ${data}=    Create Dictionary    ynwUuid=${uid}   provider=${provider} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/waitlist/unassign  data=${data}  expected_status=any
    [Return]  ${resp}


Make Available
   [Arguments]  ${name}   ${rt}   ${ri}   ${sDate}   ${eDate}   ${stime}   ${etime}  ${loc}  ${id}
   ${bs}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${EMPTY}  ${stime}  ${etime}
   ${provider}=  Create Dictionary  id=${id}
   ${data}=  Create Dictionary  name=${name}  queueSchedule=${bs}  location=${loc}  provider=${provider}
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  /provider/waitlist/queues/available  data=${data}  expected_status=any
   [Return]  ${resp}

Terminate Availability Queue
    [Arguments]  ${queueId}  
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/waitlist/queues//instant/terminate/${queueId}  expected_status=any
    [Return]  ${resp}


Un Assign provider Appointment 
    [Arguments]    ${uid}  ${providerid}  
    ${provider}=   Create Dictionary    id=${providerid}
    ${data}=    Create Dictionary    uid=${uid}   provider=${provider} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/appointment/unassign  data=${data}  expected_status=any
    [Return]  ${resp}


Delete Gallery Image
    [Arguments]  ${name}
    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw  /provider/gallery/${name}  expected_status=any
    [Return]  ${resp}


Create Sample Donation
    [Arguments]   ${Service_name}  ${multiples}=10
    ${description}=  FakerLibrary.sentence
    ${min_don_amt1}=   Random Int   min=100   max=500
    ${mod}=  Evaluate  ${min_don_amt1}%${multiples}
    ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
    ${max_don_amt1}=   Random Int   min=5000   max=10000
    ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
    ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
    ${min_don_amt}=  Convert To Number  ${min_don_amt}  1
    ${max_don_amt}=  Convert To Number  ${max_don_amt}  1
    ${service_duration}=   Random Int   min=1   max=10
    ${resp}=  Create Donation Service  ${Service_name}   ${description}   ${0}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    [Return]  ${resp.json()}


Create Sample User
    [Arguments]   ${admin}=${bool[0]}
    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    ${random_ph}=   Random Int   min=10000   max=20000
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+${random_ph}
    clear_users  ${PUSERNAME_U1}
    # Set Test Variable  ${PUSERNAME_U1}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    #  ${pin}=  get_pincode
    #  ${resp}=  Get LocationsByPincode     ${pin}
    # FOR    ${i}    IN RANGE    3
    #     ${pin}=  get_pincode
    #     ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
    #     IF    '${kwstatus}' == 'FAIL'
    #             Continue For Loop
    #     ELSE IF    '${kwstatus}' == 'PASS'
    #             Exit For Loop
    #     END
    # END
    #  Should Be Equal As Strings    ${resp.status_code}    200
    #  Set Suite Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    #  Set Suite Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    #  Set Suite Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}   

    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc 

    ${random_ph}=   Random Int   min=20000   max=30000
    ${whpnum}=  Evaluate  ${PUSERNAME}+${random_ph}
    ${tlgnum}=  Evaluate  ${PUSERNAME}+${random_ph}

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${admin}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}  
    Should Be Equal As Strings  ${resp.status_code}  200
    [Return]  ${resp.json()}


Provider Validate Questionnaire
    [Arguments]  ${data}
    # ${data}=  json.dumps  ${data}
    Log  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/questionnaire/validate  data=${data}  expected_status=any
    [Return]  ${resp}


Provider Change Answer Status for Waitlist
    [Arguments]  ${wlId}  @{filedata}
    ${data}=  Create Dictionary  urls=${filedata}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/waitlist/questionnaire/upload/status/${wlId}  data=${data}  expected_status=any
    [Return]  ${resp}    


Provider Change Answer Status for Appointment
    [Arguments]  ${apptId}  @{filedata}  
    ${data}=  Create Dictionary  urls=${filedata}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/appointment/questionnaire/upload/status/${apptId}  data=${data}  expected_status=any
    [Return]  ${resp}  

Assign Team To Checkin
    [Arguments]  ${waitlist_id}  ${team_id}  
    Check And Create YNW Session
    ${data}=  Create Dictionary  ynwUuid=${waitlist_id}  teamId=${team_id} 
    ${data}=  json.dumps  ${data}
    ${resp}=  PUT On Session  ynw  /provider/waitlist/assignTeam   data=${data}  expected_status=any
    [Return]  ${resp}


Assign Team To Appointment
    [Arguments]  ${appt_id}  ${team_id}  
    Check And Create YNW Session
    ${data}=  Create Dictionary  uid=${appt_id}  teamId=${team_id} 
    ${data}=  json.dumps  ${data}
    ${resp}=  PUT On Session  ynw  /provider/appointment/assignTeam   data=${data}  expected_status=any
    [Return]  ${resp}


Provider Revalidate Questionnaire
    [Arguments]  ${data}
    Log  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/questionnaire/resubmit/validate  data=${data}  expected_status=any
    [Return]  ${resp}

Get Questionnaire By uuid For Waitlist
    [Arguments]  ${uuid} 
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/waitlist/questionnaire/${uuid}  expected_status=any     
    [Return]  ${resp}

Provider Change Questionnaire release Status For waitlist
    [Arguments]  ${releaseStatus}  ${uuid}  ${id}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  /provider/waitlist/questionnaire/change/${releaseStatus}/${uuid}/${id}   expected_status=any     
    [Return]  ${resp}

Provider Change Questionnaire release Status For Appmt
    [Arguments]  ${releaseStatus}  ${uuid}  ${id}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  /provider/appointment/questionnaire/change/${releaseStatus}/${uuid}/${id}   expected_status=any     
    [Return]  ${resp}

Get Questionnaire By uuid For Appmt
    [Arguments]  ${uuid} 
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/appointment/questionnaire/${uuid}  expected_status=any     
    [Return]  ${resp}


Label Permissions
    [Arguments]  ${user_ids}  ${rols}  ${label_id}  @{data}    
    ${data}=  Create Dictionary  users=${user_ids}  roles=${rols}   labelId=${label_id}   teams=${data}                                                                                                                        
    [Return]  ${data}


Setting Label Permissions
    [Arguments]  @{kwargs}
    Log  ${kwargs}
    ${data1}=  Create Dictionary  permissions=${kwargs}
    ${data}=  Create Dictionary  labelPermission=${data1}
    [Return]  ${data}


LabelPrmissions_UserAccessScope_Json
    [Arguments]  ${label_permissions}  ${userscope_data}
    ${data}=  Create Dictionary
    Set to Dictionary      ${data}    labelPermission=${label_permissions['labelPermission']}
    Set to Dictionary      ${data}    userAccessScope=${userscope_data['userAccessScope']}
    [Return]  ${data}


User Roles
    [Arguments]  ${roleId}  ${displayName}   @{capabilities}    
    ${data}=  Create Dictionary  users=${user_ids}  roles=${rols}   labelId=${label_id}   teams=${data}                                                                                                                        
    [Return]  ${data}


Setting User Roles
    [Arguments]  @{kwargs}
    Log  ${kwargs}
    ${data1}=  Create Dictionary  roles=${kwargs}
    ${data}=  Create Dictionary  userRoles=${data1}
    [Return]  ${data}


User Scopes
    [Arguments]  ${depts}  ${teams}  ${users}   ${unassigned}  ${internalStatuses}   ${businessLocations}  ${services}  ${pinCodes}   ${checkins}  ${orders}  ${appmnts}
    ${data}=  Create Dictionary  depts=${depts}  teams=${teams}   users=${users}   unassigned=${unassigned}  internalStatuses=${internalStatuses} 
    ...     businessLocations=${businessLocations}   services=${services}  pinCodes=${pinCodes}   checkins=${checkins}  orders=${orders}   appmnts=${appmnts}                                                                                                          
    [Return]  ${data}


Role Scopes
    [Arguments]  ${depts}  ${roles}  ${teams}  ${labels}  ${orders}  ${checkins}  ${appmnts}  ${unassigned}  ${internalStatuses}   ${businessLocations}  ${services}  ${pinCodes}   
    ${data}=  Create Dictionary  depts=${depts}  roles=${roles}  teams=${teams}   labels=${labels}   orders=${orders}   checkins=${checkins}     appmnts=${appmnts}  
    ...     pinCodes=${pinCodes}   services=${services}  unassigned=${unassigned}  internalStatuses=${internalStatuses}   businessLocations=${businessLocations}                                                                                                               
    [Return]  ${data}


Setting User Access Scopes
    [Arguments]  ${roleBased}   ${userBased}  ${rolescope}  @{kwargs}
    ${scopeTypes}=  Create Dictionary  roleBased=${roleBased}   userBased=${userBased}
    Log  ${kwargs}
    ${data1}=  Create Dictionary  roleScope=${roleScope}  usersScope=${kwargs}
    ${data1}=  Create List  ${data1}
    ${data}=  Create Dictionary  scopeTypes=${scopeTypes}   accesssScope=${data1}
    ${result}=  Create Dictionary  userAccessScope=${data}  
    [Return]  ${result}

Set Price Variation Per Schedule
    [Arguments]  ${schedule_id}  ${service_id}  ${price}
    ${schedule}=  Create Dictionary  id=${schedule_id}
    ${service}=  Create Dictionary  id=${service_id}
    ${data}=    Create Dictionary   schedule=${schedule}   service=${service}   price=${price}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  /provider/appointment/schedule/price   data=${data}  expected_status=any     
    [Return]  ${resp}

Get Price Variation Per Schedule
    [Arguments]  ${serviceId} 
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/appointment/schedule/${serviceId}/pricelist  expected_status=any     
    [Return]  ${resp}

Create Sample Donation For User
    [Arguments]  ${Service_name}   ${depid}   ${u_id}
    ${resp}=  Create Service For User   ${Service_name}  Description   2  ACTIVE  Waitlist  True  email  45  500  False  False   ${depid}   ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    [Return]  ${resp.json()}

Get Account Level Analytics
    [Arguments]   ${metricId}  ${dateFrom}  ${dateTo}  ${frequency}  &{kwargs}
    ${pro_params}=  Create Dictionary  metricId=${metricId}  dateFrom=${dateFrom}  dateTo=${dateTo}  frequency=${frequency}
    Check And Create YNW Session
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${param} 	${key}=${value}
    END
    # ${resp}=    GET On Session    ynw   /provider/analytics/account  params=${kwargs}  expected_status=any
    ${resp}=    GET On Session    ynw   /provider/analytics/account  params=${pro_params}  expected_status=any
    [Return]  ${resp}

Get Account Level Analytics Acc To config
    [Arguments]     ${dateFrom}    &{kwargs}
    ${items}=  Get Dictionary items  ${kwargs}
    ${data}=    Create Dictionary  dateFrom=${dateFrom} 
    FOR  ${key}  ${value}  IN  @{items}
            Set To Dictionary  ${data}   ${key}=${value}
    END
    Log  ${data}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/analytics  params=${data}  expected_status=any
    [Return]  ${resp}

Get UserLevel Analytics
    [Arguments]   &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/analytics/user  params=${kwargs}  expected_status=any
    [Return]  ${resp}

Flush Analytics Data to DB
    [Arguments]
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/analytics/db/flush  expected_status=any
    [Return]  ${resp}


User Take Virtual Service Appointment For Consumer
    [Arguments]   ${userid}  ${consid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${CallingModes}  ${CallingModes_id1}  ${appmtFor}
    ${user_id}=  Create Dictionary  id=${userid}
    ${cid}=  Create Dictionary  id=${consid}
    ${sid}=  Create Dictionary  id=${service_id}
    ${schedule}=  Create Dictionary  id=${schedule}
    ${virtualService}=  Create Dictionary   ${CallingModes}=${CallingModes_id1}
    ${data}=    Create Dictionary   provider=${user_id}  consumer=${cid}  service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}   virtualService=${virtualService}
    # ${data}=    Create Dictionary   appointmentMode=WALK_IN_APPOINTMENT  consumer=${cid}  service=${sid}  schedule=${schedule}  appmtFor=${appmtFor}  appmtDate=${appmtDate}  consumerNote=${consumerNote}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/appointment  data=${data}  expected_status=any
    [Return]  ${resp}

Provider Add To WL With Virtual Service For User
    [Arguments]   ${userid}  ${consid}  ${service_id}  ${qid}  ${date}  ${consumerNote}  ${ignorePrePayment}  ${waitlistMode}   ${virtualService}  @{fids}
    ${user_id}=  Create Dictionary  id=${userid}
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
    ${data}=    Create Dictionary    provider=${user_id}  consumer=${cid}  service=${sid}  queue=${qid}  date=${date}  consumerNote=${consumerNote}  waitlistingFor=${fid}  ignorePrePayment=${ignorePrePayment}    waitlistMode=${waitlistMode}  virtualService=${virtualService}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  provider/waitlist  data=${data}  expected_status=any
    [Return]  ${resp}

Create virtual Service with dept
    [Arguments]  ${name}  ${desc}  ${durtn}  ${status}  ${bType}  ${notfcn}  ${notiTp}   ${minPrePaymentAmount}   ${totalAmount}  ${isPrePayment}  ${taxable}   ${virtualServiceType}  ${virtualCallingModes}  ${depid}
    ${data}=  Create Dictionary  name=${name}  description=${desc}  serviceDuration=${durtn}  notification=${notfcn}  notificationType=${notiTp}  minPrePaymentAmount=${minPrePaymentAmount}   totalAmount=${totalAmount}   status=${status}  bType=${btype}  isPrePayment=${isPrePayment}  taxable=${taxable}   serviceType=virtualService   virtualServiceType=${virtualServiceType}  virtualCallingModes=${virtualCallingModes}  department=${depid}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session  
    ${resp}=  POST On Session  ynw  /provider/services  data=${data}  expected_status=any
    [Return]  ${resp}

Create Bank Details
    [Arguments]   ${bankName}   ${bankAccountNumber}   ${ifscCode}   ${nameOnPanCard}   ${accountHolderName}  ${branchCity}
    ...   ${businessFilingStatus}   ${accountType}    ${panCardNumber}   ${payTmLinkedPhoneNumber}  &{kwargs}
    ${items}=  Get Dictionary items  ${kwargs}
    ${data}=   Create Dictionary    bankName=${bankName}  bankAccountNumber=${bankAccountNumber}  ifscCode=${ifscCode}  
    ...   nameOnPanCard=${nameOnPanCard}  accountHolderName=${accountHolderName}  branchCity=${branchCity}   businessFilingStatus=${businessFilingStatus}   
    ...   accountType=${accountType}  panCardNumber=${panCardNumber}  payTmLinkedPhoneNumber=${payTmLinkedPhoneNumber}  
    FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    Log  ${data}
    ${data}=   json.dumps   ${data}
    Check And Create YNW Session
    ${resp}=   POST On Session  ynw  provider/payment/settings/bankInfo     data=${data}  expected_status=any
    [Return]  ${resp}


Get Bank Details
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /provider/payment/settings/bankInfo   expected_status=any
    [Return]  ${resp}
    

Get Bank Details By Id
    [Arguments]  ${bankid} 
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /provider/payment/settings/bankInfo/${bankid}   expected_status=any
    [Return]  ${resp}
    

Update Bank Details
    [Arguments]   ${bankid}  ${bankName}   ${bankAccountNumber}   ${ifscCode}   ${nameOnPanCard}   ${accountHolderName}  ${branchCity}
    ...   ${businessFilingStatus}   ${accountType}    ${panCardNumber}   ${payTmLinkedPhoneNumber}
    ${data}=   Create Dictionary    bankName=${bankName}  bankAccountNumber=${bankAccountNumber}  ifscCode=${ifscCode}  
    ...   nameOnPanCard=${nameOnPanCard}  accountHolderName=${accountHolderName}  branchCity=${branchCity}   businessFilingStatus=${businessFilingStatus}   
    ...   accountType=${accountType}  panCardNumber=${panCardNumber}  payTmLinkedPhoneNumber=${payTmLinkedPhoneNumber}    
    ${data}=   json.dumps   ${data}
    Check And Create YNW Session
    ${resp}=   PUT On Session  ynw  provider/payment/settings/bankInfo/${bankid}     data=${data}  expected_status=any
    [Return]  ${resp}


Update Destination Bank
    [Arguments]   ${ProfileId}  ${jaldeeBank} 
    ${data}=   Create Dictionary    defaultPaymentProfileId=${ProfileId}  jaldeeBank=${jaldeeBank}  
    ${data}=   json.dumps   ${data}
    Check And Create YNW Session
    ${resp}=   PUT On Session  ynw  provider/account/settings/updateDestBank     data=${data}  expected_status=any
    [Return]  ${resp}


Payment Profile  
    [Arguments]  ${id}  ${displayName}   ${desc}   ${type}   ${txnTypes}   ${destBank}  ${default}  ${paymode}   ${indiaPay}  ${indianPaymodes} 
    ...    ${internationalPay}   ${internationalPaymodes}   ${splitPayment}   ${destBanks}   ${fromBank}  
    ${data}=   Create Dictionary    id=${id}  displayName=${displayName}  desc=${desc}  type=${type}   txnTypes=${txnTypes}  destBank=${destBank}
    ...    default=${default}   paymode=${paymode}  indiaPay=${indiaPay}  indianPaymodes=${indianPaymodes}  internationalPay=${internationalPay}
    ...    internationalPaymodes=${internationalPaymodes}  splitPayment=${splitPayment}  destBanks=${destBanks}  fromBank=${fromBank}    
    [Return]  ${data}


Setting Payment Profile
    [Arguments]  @{kwargs}
    Log  ${kwargs}
    ${data}=  Create Dictionary  profiles=${kwargs}
    [Return]  ${data}


Payment Profile Json
    [Arguments]  ${paymentProfiles}
    ${data}=  Create Dictionary   
    Set to Dictionary      ${data}    paymentProfiles=${paymentProfiles}
    ${data}=   json.dumps   ${data}
    [Return]  ${data}


Get payment profiles
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /provider/payment/paymentProfiles    expected_status=any
    [Return]  ${resp}


Get payment profile By Id
    [Arguments]   ${bankid}
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /provider/payment/paymentProfiles/${bankid}    expected_status=any
    [Return]  ${resp}


Assign Profile To Service
   [Arguments]  ${profileId}   ${service_ids}
   ${data}=   json.dumps   ${service_ids}
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw   /provider/services/assignPayProfile/${profileId}   data=${data}   expected_status=any
   [Return]  ${resp}


Enable Disable Online Payment
   [Arguments]  ${status}  
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  provider/payment/${status}  expected_status=any
   [Return]  ${resp}


Create Sample Payment Profile

    ${GST_num1}  ${pan_num1}=   db.Generate_gst_number   ${Container_id}
    ${ifsc_code1}=   db.Generate_ifsc_code
    ${bank_ac1}=   db.Generate_random_value  size=11   chars=${digits} 
    ${bank_name1}=  FakerLibrary.company
    ${name1}=  FakerLibrary.name
    ${branch1}=   db.get_place

    ${resp}=   Create Bank Details  ${bank_name1}  ${bank_ac1}  ${ifsc_code1}  ${name1}  ${name1}  ${branch1}  ${businessFilingStatus[1]}  ${accountType[1]}  ${pan_num1}  ${PUSERNAME120}   
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${bank_id1}  ${resp.json()}

    ${desc}=  FakerLibrary.word
    ${type}=  Create List   onlinePay   bank2bank 
    ${txnTypes}=   Create List   any
    ${destBank}=  Create List   OWN
    ${paymode}=  Create List   any
    ${gateway}=  Create List   RAZORPAY
    ${chargeConsumer}=  Create List   ${chargeConsumer[0]}
    ${gatewayFee}=   Create Dictionary   chargeConsumer=${chargeConsumer}   fixedPctValue=0   fixedAmountValue=0  fixedPctValueMax=0  fixedPctValueMin=0
    ${indianPaymodes1}=   Create Dictionary   mode=${payment_modes[5]}   gateway=${gateway}   modeDisplayName=${payment_modes[5]}   
    ...   gatewayMerchantId=${bank_id1}  gatewayFee=${gatewayFee}
    ${indianPaymodes1}=  Create List   ${indianPaymodes1}

    ${internationalPaymodes1}=   Create Dictionary   mode=${payment_modes[5]}   gateway=${gateway}   modeDisplayName=${payment_modes[5]}   
    ...   gatewayMerchantId=${bank_id1}  gatewayFee=${gatewayFee}
    ${internationalPaymodes}=  Create List    ${internationalPaymodes1}

    ${splitPayment}   Create List   no  2-way   3-way
    ${destBanks}=   Create Dictionary   bankID=${EMPTY}   payPct=50   fixedPctValueMin=3   fixedPctValueMax=5   fixed=${EMPTY}     
    ${destBanks}=  Create List   ${destBanks}
    ${fee}=   Create List   incl  excl
    ${fromBank}=   Create Dictionary   bankID=${EMPTY}   maxLimit=100000   fee=${fee}   

    ${resp}=   Payment Profile  ${paymentprofileid[0]}  ${displayName[0]}   ${desc}  ${type}  ${txnTypes}   ${destBank}  ${boolean[1]}   ${paymode}  ${boolean[1]}
    ...   ${indianPaymodes1}   ${boolean[1]}   ${internationalPaymodes}  ${splitPayment}   ${destBanks}   ${fromBank}

    ${resp2}=   jaldee_bank_profile
   
    ${profiles1}=  Setting Payment Profile  ${resp}   ${resp2}
    
    ${combined_json}=  Payment Profile Json  ${profiles1}   
   
    [Return]   ${GST_num1}   ${bank_id1}   ${combined_json}


Get Filter Comm
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/communications/filterComm     expected_status=any
    [Return]  ${resp}


Get NextAvailableSchedule appt Provider
    [Arguments]      ${pid}    ${lid}   ${prov_id}            
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/appointment/schedule/nextAvailableSchedule/${pid}-${lid}-${prov_id}   expected_status=any
    [Return]  ${resp}

      
Get Questionnaire By uuid For Order
    [Arguments]  ${uuid} 
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/orders/questionnaire/${uuid}  expected_status=any     
    [Return]  ${resp}

Provider Change Questionnaire release Status For Order
    [Arguments]  ${releaseStatus}  ${uuid}  ${id}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  /provider/orders/questionnaire/change/${releaseStatus}/${uuid}/${id}   expected_status=any     
    [Return]  ${resp}

Provider Change Answer Status for order
    [Arguments]  ${uuid}   @{filedata}
    ${data}=  Create Dictionary  urls=${filedata}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/orders/questionnaire/upload/status/${uuid}  data=${data}  expected_status=any
    [Return]  ${resp}

Get Consumer Questionnaire By Channel and OrderID    
    [Arguments]  ${catalogId}  ${channel}   ${consumerid}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/questionnaire/order/${catalogId}/${channel}/consumer/${consumerid}  expected_status=any     
    [Return]  ${resp}
    
Get Appointment Details with apptid  
    [Arguments]   ${apptid}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/appointment/appointmentDetails/${apptid}  expected_status=any     
    [Return]  ${resp}



Multiloc and Billable highest license Providers 
    [Arguments]  ${min}=0   ${max}=260
    @{dom_list}=  Create List
    @{provider_list}=  Create List
    @{multiloc_providers}=  Create List    
    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    ${domlen}=  Get Length   ${multilocdoms}
    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
    # ${length}   Run Keyword If     ${length}>${max}   Set Variable  ${max}
    # ...  ELSE	 Set Variable    ${length}

    FOR   ${i}  IN RANGE   ${domlen}
        ${dom}=  Convert To String   ${multilocdoms[${i}]['domain']}
        Append To List   ${dom_list}  ${dom}
    END
    Log   ${dom_list}
     
    FOR   ${a}  IN RANGE   ${min}   ${max}   
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        ${domain}=   Set Variable    ${decrypted_data['sector']}
        ${subdomain}=    Set Variable      ${decrypted_data['subSector']}
        # ${domain}=   Set Variable    ${resp.json()['sector']}
        # ${subdomain}=    Set Variable      ${resp.json()['subSector']}
        Log  ${dom_list}
        ${pkg_id}=   get_highest_license_pkg
        Log   ${pkg_id}
        Set Suite Variable     ${pkg_id[0]}   ${pkg_id[0]}
        ${resp3}=  Get Business Profile
        Log   ${resp3.json()}
        Should Be Equal As Strings  ${resp3.status_code}  200
        Set Suite Variable   ${check1}   ${resp3.json()['licensePkgID']}
     
        ${status} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${dom_list}  ${domain}
        Log Many  ${status} 	${value}
        Run Keyword If  '${status}' == 'PASS' and '${check1}' == '${pkg_id[0]}'  Append To List   ${multiloc_providers}  ${PUSERNAME${a}}
        ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        Log   ${resp2.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Test Variable  ${check}    ${resp2.json()['serviceBillable']} 
       
        Run Keyword If     '${check}' == 'True' and '${check1}' == '${pkg_id[0]}'  Append To List   ${provider_list}  ${PUSERNAME${a}}
        # Run Keyword If    '${status}' == 'PASS' and '${check}' == 'True'   Append To List  ${multiloc_billable_providers}  ${PUSERNAME${a}}
    END
    # [Return]  ${provider_list}  ${multiloc_providers}  ${multiloc_billable_providers}
    [Return]  ${provider_list}  ${multiloc_providers}

Create Sample Catalog
    [Arguments]    ${catalogName}  ${timezone}  @{vargs} 
    ${catalogDesc}=   FakerLibrary.name
    # ${startDate}=  get_date
    # ${endDate}=  db.add_timezone_date  ${tz}  12       
    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    # ${eTime1}=  add_timezone_time  ${tz}  2  30  
    ${startDate}=  get_date_by_timezone  ${timezone}
    ${endDate}=  db.add_timezone_date  ${timezone}  12  
    ${sTime1}=  add_timezone_time  ${timezone}  0  15  
    ${eTime1}=  add_timezone_time  ${timezone}  2  30  
    ${deliveryCharge}=   Evaluate    random.uniform(1.0,50)
    ${noOfOccurance}=  Random Int  min=0   max=0
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4   
    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5 
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[0]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[0]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}
    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}
    ${minNumberItem}      Set Variable  1
    ${maxNumberItem}      Random Int  min=2   max=5
        
    ${len}=  Get Length  ${vargs}
    ${catalogItem}=  Create List  
    FOR    ${index}    IN RANGE  0  ${len}
        ${item}=  Create Dictionary  itemId=${vargs[${index}]}     
        ${catalogItem1}=  Create Dictionary  item=${item}    minQuantity=${minNumberItem}   maxQuantity=${maxNumberItem}  
        Append To List  ${catalogItem}  ${catalogItem1}
    END
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    # Log   ${catalogStatus[0]}
    Set Test Variable  ${catStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}
    ${advanceAmount}=  Random Int  min=1   max=100
    # ${far}=  Random Int  min=14  max=14
    # ${soon}=  Random Int  min=1   max=1

    # ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}  ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}  ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    [Return]  ${resp.json()}


Get Service Options By Serviceid and Channel
    [Arguments]     ${serviceid}   ${channel}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  url=/provider/questionnaire/serviceoption/${serviceId}/${channel}  expected_status=any
    [Return]    ${resp}


Add Delay on Multiple Appointments
    [Arguments]    ${delaytime}  ${isAddToDelay}   ${delaymessage}    ${email}    ${pushNotification}   ${sms}     ${telegram}    @{vargs}
    # ${delaytime}=    Random Int  min=20    max=60
    # ${delaymessage}=    FakerLibrary.Sentence   nb_words=4
    ${len}=  Get Length  ${vargs}
    ${appmnts}=  Create List
    FOR  ${value}  IN  @{vargs}
        Append To List  ${appmnts}  ${value}
    END
    ${medium}=    Create Dictionary   email=${email}     pushNotification=${pushNotification}    sms=${sms}    telegram=${telegram}
    ${data}=   Create Dictionary    apptDelay=${delaytime}  isAddToDelay=${isAddToDelay}  apptDelayMessag=${delaymessage}    appointments=${appmnts}      medium=${medium}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/appointment/addDelayOnMultipleAppointment   data=${data}  expected_status=any
    [Return]  ${resp}

Get Service Options for Donation By Serviceid
    [Arguments]     ${serviceid}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  url=/provider/questionnaire/serviceoptions/donation/${serviceId}  expected_status=any
    [Return]    ${resp}

Provider Upload Status for Appnt
    [Arguments]  ${apptId}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/appointment/serviceoption/upload/status/${apptId}  expected_status=any
    [Return]  ${resp}

Get Service Options For Order By Catalogueid and Channel
    [Arguments]     ${catalogueid}   ${channel}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  url=/provider/questionnaire/serviceoption/order/${catalogueId}/${channel}  expected_status=any
    [Return]    ${resp}


Get Report Status By Token Id
    [Arguments]  ${reportTokenId}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/report/status/${reportTokenId}   expected_status=any
    [Return]  ${resp}

Get Report By Status
    [Arguments]  @{kwargs}
    Check And Create YNW Session
    ${len}=   Get Length  ${kwargs}
    ${data}=  Catenate  SEPARATOR=,  @{kwargs}
    ${resp}=    GET On Session     ynw   /provider/report/status/cache/${data}   expected_status=any
    [Return]  ${resp}

# ..............CRM Keywords................


Create Task
   [Arguments]  ${title}  ${desc}  ${user_type}   ${cat_type}  ${task_type}  ${locationId}  &{kwargs}
   ${loc}=   Create Dictionary   id=${locationId}
   ${cat_type}=   Create Dictionary   id=${cat_type}
   ${task_type}=   Create Dictionary   id=${task_type}
   ${data}=  Create Dictionary  title=${title}  description=${desc}  userType=${user_type}  category=${cat_type}  type=${task_type}  location=${loc}  
   FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw  /provider/task/  data=${data}  expected_status=any
   [Return]  ${resp}


Update Task
   [Arguments]  ${task_id}  ${title}  ${desc}   ${cat_type}  ${task_type}  ${locationId}  &{kwargs}
   ${loc}=   Create Dictionary   id=${locationId}
   ${cat_type}=   Create Dictionary   id=${cat_type}
   ${task_type}=   Create Dictionary   id=${task_type}
   ${data}=  Create Dictionary  title=${title}  description=${desc}   category=${cat_type}  type=${task_type}  location=${loc}  
   FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  /provider/task/${task_id}  data=${data}  expected_status=any
   [Return]  ${resp}


Create Lead
    [Arguments]  ${title}  ${desc}        ${targetPotential}     ${location_id}    ${customerid}   &{kwargs}
    ${details}=  Get Dictionary items  ${kwargs}
    ${locationid}=   Create Dictionary   id=${location_id}
    ${customerid}=    Create Dictionary    id=${customerid}

    ${data}=  Create Dictionary  title=${title}  description=${desc}        targetPotential=${targetPotential}       customer=${customerid}    location=${locationid}
    FOR  ${key}  ${value}  IN  @{details}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    Log  ${data}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /provider/lead  data=${data}  expected_status=any
    [Return]  ${resp}


Get Lead By Id
    [Arguments]   ${en_uid}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/lead/${en_uid}  expected_status=any
    [Return]  ${resp}  


Get Leads
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/lead  params=${param}  expected_status=any
    [Return]  ${resp}


Enable Disable CRM
   [Arguments]  ${status}  
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  provider/account/settings/crm/${status}  expected_status=any
   [Return]  ${resp}


Get Lead Category Type
   Check And Create YNW Session
   ${resp}=  GET On Session  ynw  provider/lead/category  expected_status=any
   [Return]  ${resp}

Get Task Status
   Check And Create YNW Session
   ${resp}=  GET On Session  ynw  provider/task/status  expected_status=any
   [Return]  ${resp}


Get Task Priority
   Check And Create YNW Session
   ${resp}=  GET On Session  ynw  provider/task/priority  expected_status=any
   [Return]  ${resp}


Get Task Category Type
   Check And Create YNW Session
   ${resp}=  GET On Session  ynw  provider/task/category  expected_status=any
   [Return]  ${resp}


Get Task Type
   Check And Create YNW Session
   ${resp}=  GET On Session  ynw  provider/task/type  expected_status=any
   [Return]  ${resp}


Get Consumer Tasks
   Check And Create YNW Session
   ${resp}=  GET On Session  ynw  provider/task/consumer  expected_status=any
   [Return]  ${resp}


Get Provider Tasks
    [Arguments]  &{filters}
   Check And Create YNW Session
   ${resp}=  GET On Session  ynw  provider/task/provider  params=${filters}  expected_status=any
   [Return]  ${resp}

Get Task By Id
   [Arguments]  ${task_uid}
   Check And Create YNW Session
   ${resp}=  GET On Session  ynw  provider/task/${task_uid}  expected_status=any
   [Return]  ${resp}

Add Notes To Task
   [Arguments]  ${task_id}   ${notes}
   ${data}=  Create Dictionary  note=${notes} 
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  provider/task/${task_id}/notes   data=${data}  expected_status=any
   [Return]  ${resp}

Create Task Appt Details
   [Arguments]  ${task_uid}
   ${data}=  Create Dictionary  reference_id=${task_uid} 
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw  provider/task/appointment  data=${data}  expected_status=any
   [Return]  ${resp}


Change Task Status
   [Arguments]    ${task_uid}     ${statusId}
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw    provider/task/${taskUid}/status/${statusId}     expected_status=any
   [Return]  ${resp}

Change Task Priority
   [Arguments]     ${task_uid}      ${priorityId}
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw    /provider/task/${taskUid}/priority/${priorityId}     expected_status=any
   [Return]  ${resp}


Change Assignee
   [Arguments]  ${task_uid}   ${u_id}
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  provider/task/${task_uid}/assignee/${u_id}   expected_status=any
   [Return]  ${resp}

Add Task Progress For User
   [Arguments]    ${task_uid}    ${progressValue}    ${note}
   ${data}=  Create Dictionary    note=${note}
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  PUT On Session    ynw    provider/task/${task_uid}/progress/${progressValue}  data=${data}     expected_status=any
   [Return]  ${resp}

Change User Task Status
    [Arguments]     ${task_uid}     ${actualResult}     ${actualPotential}      ${closingNote}
    ${data}=  Create Dictionary  actualResult=${actualResult}  actualPotential=${actualPotential}  closingNote=${closingNote}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=    PUT On Session  YNW  provider/task/${task_uid}/status/closed   data=${data}   expected_status=any
    [Return]    ${resp}

Change User Task Closing Details
    [Arguments]     ${task_uid}     ${actualResult}     ${actualPotential}      ${closingNote}
    ${data}=  Create Dictionary  actualResult=${actualResult}  actualPotential=${actualPotential}  closingNote=${closingNote}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=    PUT On Session  YNW  provider/task/${task_uid}/closingdetails  data=${data}   expected_status=any
    [Return]    ${resp}

Change User Task Status Closed
    [Arguments]     ${task_uid}
    Check And Create YNW Session
    ${resp}=    PUT On Session  YNW  provider/task/${task_uid}/status/closed   expected_status=any
    [Return]    ${resp}

Get Task Audit Logs
    [Arguments]     ${task_uid}   &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    provider/task/activity/${task_uid}    params=${kwargs}  expected_status=any
    [Return]    ${resp}


Enable Disable Task
   [Arguments]  ${status}  
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  provider/account/settings/task/${status}  expected_status=any
   [Return]  ${resp}


Enable Disable Lead
   [Arguments]  ${status}  
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  provider/account/settings/lead/${status}  expected_status=any
   [Return]  ${resp}

Create SubTask
   [Arguments]  ${task_uid}  ${title}  ${desc}  ${user_type}   ${cat_type}  ${task_type}  ${locationId}  &{kwargs}
   ${loc}=   Create Dictionary   id=${locationId}
   ${cat_type}=   Create Dictionary   id=${cat_type}
   ${task_type}=   Create Dictionary   id=${task_type}
   ${data}=  Create Dictionary  originUid=${task_uid}  title=${title}  description=${desc}  userType=${user_type}  category=${cat_type}  type=${task_type}  location=${loc}  
   FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw  /provider/task/  data=${data}  expected_status=any
   [Return]  ${resp}

Get Task Progress
    [Arguments]     ${task_id} 
    Check And Create YNW Session
    ${resp}=  GET On Session   ynw   /provider/task/${task_id}/progresslog   expected_status=any
    [Return]  ${resp}


Remove Task Assignee
   [Arguments]  ${task_uid}  
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  provider/task/${task_uid}/assignee/remove   expected_status=any
   [Return]  ${resp}


Remove Task Manager
   [Arguments]  ${task_uid}  
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  provider/task/${task_uid}/manager/remove   expected_status=any
   [Return]  ${resp}

Get Lead Type
   Check And Create YNW Session
   ${resp}=  GET On Session  ynw  provider/lead/type  expected_status=any
   [Return]  ${resp}

Get Lead Status
   Check And Create YNW Session
   ${resp}=  GET On Session  ynw  provider/lead/status  expected_status=any
   [Return]  ${resp}

Get Lead Priority
   Check And Create YNW Session
   ${resp}=  GET On Session  ynw  provider/lead/priority  expected_status=any
   [Return]  ${resp}

Get Leads With Filter
    [Arguments]  &{kwargs}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/lead  params=${kwargs}  expected_status=any
    [Return]  ${resp}

Get Lead Count
    [Arguments]  &{kwargs}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/lead/count  params=${kwargs}  expected_status=any
    [Return]  ${resp}

Create Task Master

   [Arguments]   ${templateName}   ${title}     ${cat_type}  ${task_type}  ${priority}   &{kwargs}
   ${cat_type}=   Create Dictionary   id=${cat_type}
   ${task_type}=   Create Dictionary   id=${task_type}
   ${priority}=   Create Dictionary   id=${priority} 
   ${data}=  Create Dictionary     templateName=${templateName}    title=${title}     category=${cat_type}  type=${task_type}   priority=${priority}  
   FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw    /provider/task/master    data=${data}  expected_status=any
   [Return]  ${resp}

Get Task Master By Id
    [Arguments]   ${taskMasterId} 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw    /provider/task/master/${taskMasterId}      expected_status=any
    [Return]  ${resp}

Add Lead Notes
   [Arguments]    ${lead_uid}    ${note}
   ${data}=  Create Dictionary  note=${note} 
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw    provider/lead/${lead_uid}/note    data=${data}   expected_status=any
   [Return]  ${resp}
   
Get Task Master With Filter
    [Arguments]  &{kwargs}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/task/master   params=${kwargs}   expected_status=any
    [Return]  ${resp}

Change Lead Assignee
   [Arguments]    ${lead_uid}     ${u_id}
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw    provider/lead/${lead_uid}/assignee/${u_id}     expected_status=any
   [Return]  ${resp}

Change Lead Manager
   [Arguments]    ${lead_uid}     ${u_id}
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw    provider/lead/${lead_uid}/manager/${u_id}     expected_status=any
   [Return]  ${resp}

Change Lead Priority
   [Arguments]    ${lead_uid}     ${priority_id}
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw    provider/lead/${lead_uid}/priority/${priority_id}     expected_status=any
   [Return]  ${resp}

Change Lead Status
   [Arguments]    ${lead_uid}     ${statusId}
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw    provider/lead/${lead_uid}/status/${statusId}     expected_status=any
   [Return]  ${resp}

Remove Lead Manager
    [Arguments]    ${leadUid}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw    provider/lead/${leadUid}/manager/remove     expected_status=any
    [Return]  ${resp}

Remove Lead Assignee
    [Arguments]    ${leadUid}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw    provider/lead/${leadUid}/assignee/remove     expected_status=any
    [Return]  ${resp}

Get Lead Notes
   [Arguments]    ${lead_uid}   
   Check And Create YNW Session
   ${resp}=  GET On Session  ynw    provider/lead/${lead_uid}/notes    expected_status=any
   [Return]  ${resp}

Transfer Lead Location
   [Arguments]    ${lead_uid}     ${loc_id}
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw    provider/lead/${lead_uid}/location/${loc_id}     expected_status=any
   [Return]  ${resp}

Update Lead
    [Arguments]  ${id}  ${title}  ${desc}  ${status}   ${priority}  ${location_id}  ${customerid}  ${assignee}   &{kwargs}
    ${details}=  Get Dictionary items  ${kwargs}
    ${status}=   Create Dictionary   id=${status}
    ${priority}=   Create Dictionary   id=${priority}
    ${locationid}=   Create Dictionary   id=${location_id}
    ${customerid}=    Create Dictionary    id=${customerid}
    ${assignee}=   Create Dictionary   id=${assignee}
    ${data}=  Create Dictionary  title=${title}  description=${desc}  status=${status}  priority=${priority}   
    ...   location=${location_id}     customer=${customerid}   assignee=${assignee}
    FOR  ${key}  ${value}  IN  @{details}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    Log  ${data}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/lead/${id}  data=${data}  expected_status=any
    [Return]  ${resp}

Change Task Manager
   [Arguments]     ${task_uid}      ${managerId}
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw    /provider/task/${taskUid}/manager/${managerId}     expected_status=any
   [Return]  ${resp}

Create Task With Multiple Assignee
   [Arguments]  ${title}  ${desc}  ${user_type}   ${cat_type}  ${task_type}  ${locationId}   &{kwargs}
   ${loc}=   Create Dictionary   id=${locationId}
   ${cat_type}=   Create Dictionary   id=${cat_type}
   ${task_type}=   Create Dictionary   id=${task_type}
   ${data}=  Create Dictionary  title=${title}  description=${desc}  userType=${user_type}  category=${cat_type}  type=${task_type}  location=${loc}  
   FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=   POST On Session   ynw   /provider/task/multipleAssignee   data=${data}  expected_status=any
   [Return]  ${resp}

Add Lead Token
    [Arguments]    ${lead_uid}     ${waitlistUid}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw    provider/lead/${lead_uid}/waitlist/${waitlistUid}     expected_status=any
    [Return]  ${resp}

Get Lead Tokens
    [Arguments]    ${leadUid}     
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw     provider/lead/${leadUid}/waitlist      expected_status=any
    [Return]  ${resp}

Get Lead Activity Log
    [Arguments]    ${leadUid}     
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw     /provider/lead/${leadUid}/getactivity          expected_status=any
    [Return]  ${resp}

Get Questionnaire By uuid For Lead
    [Arguments]  ${uuid} 
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/lead/questionnaire/${uuid}  expected_status=any     
    [Return]  ${resp}

Provider Change Answer Status for Lead
    [Arguments]  ${uuid}   @{filedata}
    ${data}=  Create Dictionary  urls=${filedata}  
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/lead/questionnaire/upload/status/${uuid}  data=${data}  expected_status=any
    [Return]  ${resp}

Provider Change Questionnaire release Status For Lead
    [Arguments]  ${releaseStatus}  ${uuid}  ${id}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  /provider/lead/questionnaire/change/${releaseStatus}/${uuid}/${id}   expected_status=any     
    [Return]  ${resp}



# ..........................................

Update Order Notification
    [Arguments]   ${uuid}  ${qnrid}  ${msg}  ${email}  ${push_notif}  ${sms}  ${telegram}
    ${medium}=  Create Dictionary   sms=${sms}  email=${email}  pushNotification=${push_notif}  telegram=${telegram}
    ${data}=  Create Dictionary  medium=${medium}  id=${qnrid}  message=${msg}
    ${data}=   json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    PUT On Session   ynw    /provider/orders/questionnaire/notification/${uuid}   data=${data}  expected_status=any
    [Return]  ${resp}

Get Single Token Status
    [Arguments]     ${task_id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/report/status/cache/token/${task_id}  expected_status=any
    [Return]  ${resp}

# ..............JALDEE DRIVE................
Get List Of Shared 0wners 
    [Arguments]     ${ownerType}    ${providerId}
    Log   ${ownerType} 
    Log  ${providerId}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    provider/fileShare/${ownerType}/${providerId}    expected_status=any     
    [Return]  ${resp}



Get by Criteria
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /provider/fileShare     params=${param}  expected_status=any     
    [Return]  ${resp}

      

Delete Jaldeedrive File
    [Arguments]    ${fileId}
    Check And Create YNW Session
    ${resp}=    DELETE On Session  ynw   /provider/fileShare/${fileId}  expected_status=any  
    [Return]  ${resp}

Get Count of Files in a filter 
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /provider/fileShare/count     params=${param}   expected_status=any     
    [Return]  ${resp}

Get Count File In a filter By provider 
    [Arguments]   ${providerId}      &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /provider/fileShare/count/${providerId}      params=${param}     expected_status=any     
    [Return]  ${resp}

Get total Storage usage
    [Arguments]  
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /provider/fileShare/storage        expected_status=any     
    [Return]  ${resp}


Remove Share files 
    [Arguments]   ${fileId}    ${sharedto}
    ${data}=  Create List          ${sharedto}   
    ${data}=  json.dumps  ${data}
	Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw  /provider/fileShare/sharefiles/${fileId}  data=${data}  expected_status=any
    [Return]  ${resp}

Encoded Short Url
    [Arguments]    ${fileid}   ${sharetype}   ${sharedtoId}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   provider/fileShare/shortUrl/encoded/${fileid}-${sharetype}-${sharedtoId}     expected_status=any
    [Return]  ${resp}



Get a File Using Short Url
    [Arguments]   ${driveid}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   provider/fileShare/shortUrl/${driveid}     expected_status=any
    [Return]  ${resp}

Share files 
    [Arguments]   ${sharedto}     ${attachments}
   # ${share}=  Create Dictionary   owner=${owner}   ownertype=${ownerType}
   # ${sharedto}=  Create List   ${sharedto}
    ${attachments}=   Create List  ${attachments}
    ${data1}=  Create Dictionary    sharedto=${sharedto}   attachments=${attachments}
    ${data}=  json.dumps  ${data2}
    Check And Create YNW Session
    ${resp}=  POST On Session   ynw   /provider/fileShare/sharefiles   data=${data}  expected_status=any
    [Return]  ${resp}

Upload To Private Folder

    [Arguments]    ${Folder}    ${providerid}    ${list}
  #  ${data}=  json.dumps   ${list}
    Check And Create YNW Session
    ${resp}=  POST On Session   ynw   /provider/fileShare/upload/${Folder}/${providerid}     json=${list}   expected_status=any
    [Return]  ${resp}

Change Upload Status

    [Arguments]    ${status}    ${fileid} 
    Check And Create YNW Session
    ${resp}=  PUT On Session   ynw   /provider/fileShare/upload/${status}/${fileid}        expected_status=any
    [Return]  ${resp}
   

Get Provider service options for an item
    [Arguments]  ${item}     ${channel}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   url=/provider/questionnaire/serviceoption/order/item/${item}/${channel}   expected_status=any
    [Return]    ${resp}

Change Provider Status Of Service Option Item
    [Arguments]  ${uuid}  @{filedata}
    ${data}=    Create Dictionary   urls=${filedata}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=   PUT On Session  ynw  url=/provider/orders/item/serviceoption/upload/status/${uuid}   data=${data}   expected_status=any
    [Return]    ${resp} 

Change Provider Status Of Service Option Waitlist
    [Arguments]  ${uuid}  @{filedata}
    ${data}=    Create Dictionary   urls=${filedata}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=   PUT On Session  ynw  url=/provider/waitlist/serviceoption/upload/status/${uuid}   data=${data}   expected_status=any
    [Return]    ${resp} 

Change Provider Status Of Service Option Appointment
    [Arguments]  ${uuid}  @{filedata}
    ${data}=    Create Dictionary   urls=${filedata}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=   PUT On Session  ynw  url=/provider/appointment/serviceoption/upload/status/${uuid}   data=${data}   expected_status=any
    [Return]    ${resp} 

Change Provider Status Of Service Option Order
    [Arguments]  ${uuid}  @{filedata}
    ${data}=    Create Dictionary   urls=${filedata}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=   PUT On Session  ynw  url=/provider/orders/serviceoption/upload/status/${uuid}   data=${data}   expected_status=any
    [Return]    ${resp} 


# ..............ENQUIRY..............................

Get Provider Enquiry Category
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   url=/provider/enquire/category   expected_status=any
    [Return]    ${resp}


Get Provider Enquiry Type
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   url=/provider/enquire/type   expected_status=any
    [Return]    ${resp}


Get Provider Enquiry Status
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   url=/provider/enquire/status   expected_status=any
    [Return]    ${resp}


Get Provider Enquiry Priority
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   url=/provider/enquire/priority   expected_status=any
    [Return]    ${resp}


Get Enquiry Template
    [Arguments]  &{filters}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   url=/provider/enquire/master   params=${filters}  expected_status=any
    [Return]    ${resp}


Enquiry
    [Arguments]  ${location_id}  ${customer_id}  &{kwargs}
    
    ${locationid}=   Create Dictionary   id=${location_id}
    ${customerid}=    Create Dictionary    id=${customer_id}

    ${data}=  Create Dictionary  location=${locationid}  customer=${customerid} 
    Set To Dictionary  ${data}  &{kwargs}
    Log  ${data}

    [Return]  ${data}


Create Enquiry
    [Arguments]  ${location_id}  ${customer_id}  &{kwargs}

    ${data}=  Enquiry  ${location_id}  ${customer_id}  &{kwargs}
    # ${locationid}=   Create Dictionary   id=${location_id}
    # ${customerid}=    Create Dictionary    id=${customer_id}

    # ${data}=  Create Dictionary  location=${locationid}  customer=${customerid} 
    # Set To Dictionary  ${data}  &{kwargs}
    # Log  ${data}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   url=/provider/enquire  data=${data}  expected_status=any
    [Return]  ${resp}


Get Enquiry with filter
    [Arguments]  &{filters}
    Check And Create YNW Session
    ${resp}=    GET On Session  ynw  url=/provider/enquire  params=${filters}  expected_status=any
    [Return]    ${resp}


Get Enquiry count with filter
    [Arguments]  &{filters}
    Check And Create YNW Session
    ${resp}=    GET On Session  ynw  url=/provider/enquire/count  params=${filters}  expected_status=any
    [Return]    ${resp}


Get Enquiry by Uuid
    [Arguments]  ${enquireUid}
    Check And Create YNW Session
    ${resp}=    GET On Session  ynw  url=/provider/enquire/${enquireUid}  expected_status=any
    [Return]    ${resp}


Update Enquiry
    [Arguments]  ${enquireUid}  ${location_id}  ${customer_id}  &{kwargs}

    ${data}=  Enquiry  ${location_id}  ${customer_id}  &{kwargs}
    # ${locationid}=   Create Dictionary   id=${location_id}
    # ${customerid}=    Create Dictionary    id=${customer_id}

    # ${data}=  Create Dictionary  location=${locationid}  customer=${customerid} 
    # Set To Dictionary  ${data}  &{kwargs}
    # Log  ${data}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   url=provider/enquire/${enquireUid}  data=${data}  expected_status=any
    [Return]  ${resp}


Change Enquiry Status
    [Arguments]  ${enquireUid}  ${statusId}
    Check And Create YNW Session
    ${resp}=    PUT On Session  ynw  url=/provider/enquire/${enquireUid}/status/${statusId}  expected_status=any
    [Return]    ${resp}


Get Service Options By Catalogueid and Channel
    [Arguments]     ${catalogueid}   ${channel}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  url=/provider/questionnaire/serviceoption/order/catalog/item/${catalogueId}/${channel}  expected_status=any
    [Return]    ${resp}


Get Lead Templates
    [Arguments]    &{kwargs}     
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw     /provider/lead/master    params=${kwargs}      expected_status=any
    [Return]  ${resp}


Change Task Status to Complete
    [Arguments]    ${task_uid}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw    /provider/task/${taskUid}/status/closed     expected_status=any
    [Return]  ${resp}


Create KYC
    [Arguments]        ${originUid}         ${customerName}      ${dob}        ${relationType}    ${relationName}    ${telephoneType}       ${telephoneNumber}   ${validationId}      ${owner}  ${fileName}     ${fileSize}  ${caption}  ${fileType}    ${order}    ${permanentAddress}    ${permanentCity}    ${permanentState}   ${permanentPinCode}    ${panNumber}    ${parent}      &{kwargs}
    
    ${telephone}=  Create Dictionary   telephoneType=${telephoneType}   telephoneNumber=${telephoneNumber}
    ${telephone}=    Create List   ${telephone}
    
    ${pan}=  Create Dictionary     owner=${owner}        fileName=${fileName}        fileSize=${fileSize}        caption=${caption}        fileType=${fileType}        order=${order}
    ${panAttachments}=    Create List    ${pan}

    ${data}=  Create Dictionary    originUid=${originUid}        customerName=${customerName}   dob=${dob}    telephone=${telephone}    relationType=${relationType}    relationName=${relationName}    validationIds=${validationId}    permanentAddress=${permanentAddress}    permanentCity=${permanentCity}    permanentState=${permanentState}    permanentPinCode=${permanentPinCode}  panNumber=${panNumber}    panAttachments=${panAttachments}    parent=${parent}    
    Log  ${data}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary   ${data}   ${key}=${value}
    END
    ${data}=    Create List    ${data}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   url=/provider/KYC/create  data=${data}  expected_status=any
    [Return]  ${resp}

Get KYC
    [Arguments]    ${uuid}   
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   url=/provider/KYC/${uuid}    expected_status=any
    [Return]  ${resp}


Update KYC 
    [Arguments]    ${id}       ${originUid}        ${customerName}      ${dob}        ${relationType}    ${relationName}    ${telephoneType}       ${telephoneNumber}   ${validationId}       ${owner}  ${fileName}     ${fileSize}  ${caption}  ${fileType}    ${order}    ${permanentAddress}    ${permanentCity}    ${permanentState}   ${permanentPinCode}    ${panNumber}    ${parent}      &{kwargs}
    

    ${telephone}=  Create Dictionary   telephoneType=${telephoneType}   telephoneNumber=${telephoneNumber}
    ${telephone}=    Create List   ${telephone}

    ${pan}=  Create Dictionary     owner=${owner}        fileName=${fileName}        fileSize=${fileSize}        caption=${caption}        fileType=${fileType}        order=${order}
    ${panAttachments}=    Create List    ${pan}

    ${data}=  Create Dictionary    id=${id}    originUid=${originUid}        customerName=${customerName}   dob=${dob}    telephone=${telephone}    relationType=${relationType}    relationName=${relationName}    validationIds=${validationId}    permanentAddress=${permanentAddress}    permanentCity=${permanentCity}    permanentState=${permanentState}    permanentPinCode=${permanentPinCode}  panNumber=${panNumber}    panAttachments=${panAttachments}    parent=${parent}    
    Log  ${data}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary   ${data}   ${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/KYC/update/${originUid}  data=${data}  expected_status=any
    [Return]  ${resp}

Change KYC Status
    [Arguments]      ${originUid}    ${statusId}        &{kwargs}
    
    ${data}=    Get KYC    ${originUid}
    Log  ${data.content}
    ${result}=    Set Variable    ${data.content}    
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /provider/KYC/proceed/status/${statusId}  data=${result}  expected_status=any
    [Return]  ${resp}


Process CRIF Inquiry
    [Arguments]  ${leadUid} 
    ${data}=   Create Dictionary   originUid=${leadUid}
    Check And Create YNW Session
    ${data}=  json.dumps  ${data}
    ${resp}=    POST On Session    ynw  /provider/crif/processinquiry      data=${data}     expected_status=any 
    [Return]  ${resp}

Get CRIF Inquiry
    
    [Arguments]  ${leadUid} 
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/crif/inquiry/${leadUid}           expected_status=any 
    [Return]  ${resp}

Get States

    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/crif/indianstates          expected_status=any 
    [Return]  ${resp}

Status change crif

    [Arguments]  ${leadUid} 
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  /provider/lead/${leadUid}/status/creditscoregenerated           expected_status=any 
    [Return]  ${resp}


Process CRIF Inquiry with kyc
    [Arguments]  ${leadUid}   ${kycId}
    ${data}=   Create Dictionary   originUid=${leadUid}   leadKycId=${kycId}
    Check And Create YNW Session
    ${data}=  json.dumps  ${data}
    ${resp}=    POST On Session    ynw  /provider/crif/processinquiry      data=${data}     expected_status=any 
    [Return]  ${resp}

Get CRIF Inquiry with kyc
    
    [Arguments]  ${leadUid}   ${kycId}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw     provider/crif/inquiry/${leadUid}/kyc/${kycId}       expected_status=any 
    [Return]  ${resp}



Get Qnr for login status
    
    [Arguments]  ${leadUid}  
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw     /provider/lead/questionnaire/status/${leadUid}    expected_status=any 
    [Return]  ${resp}

Change Status Lead

    [Arguments]     ${leadstatus}   ${leadUid}  
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw     /provider/lead/questionnaire/proceed/${leadstatus}/${leadUid}    expected_status=any 
    [Return]  ${resp}

Redirect lead 

    [Arguments]        ${leadUid}    ${statusId}   ${note}
    ${data}=   Create Dictionary   note=${note}
    Check And Create YNW Session
    ${data}=  json.dumps  ${data}
    ${resp}=    PUT On Session    ynw     /provider/lead/${leadUid}/redirect/status/${statusId}    data=${data}    expected_status=any 
    [Return]  ${resp}

Rejected lead

    [Arguments]        ${leadUid}   ${note}
    ${data}=   Create Dictionary   note=${note}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw     /provider/lead/${leaduid}/rejected     data=${data}    expected_status=any 
    [Return]  ${resp}


Get JaldeeBank Statement By Provider
    [Arguments]   ${fromdate}  ${todate}
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw   /provider/payment/jBankStatements/${fromdate}/${todate}    expected_status=any
    [Return]  ${resp}

Change Task Status to Proceed
    [Arguments]    ${enquireUid}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw    /provider/enquire/${enquireUid}/status/done    expected_status=any
    [Return]  ${resp}

Change Task Status to Closed
    [Arguments]    ${enquireUid}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw    /provider/enquire/${enquireUid}/status/closed    expected_status=any
    [Return]  ${resp}

Change Task Status to Rejected
    [Arguments]    ${enquireUid}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw    /provider/enquire/${enquireUid}/status/rejected    expected_status=any
    [Return]  ${resp}

Change Task Status to Pending
    [Arguments]    ${enquireUid}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw    /provider/enquire/${enquireUid}/status/pending    expected_status=any
    [Return]  ${resp}

Order For Item
    [Arguments]    ${Consumer_id}  ${orderfor}  ${catalog_id}   ${homeDelivery}  ${homeDeliveryAddress}  ${stime}  ${etime}   ${orderDate}  ${phoneNumber}   ${email}  ${orderNote}  ${countryCode}  @{vargs}
    ${catalog}=     Create Dictionary  id=${catalog_id} 
    ${Cid}=  Create Dictionary  id=${Consumer_id}
    ${orderfor}=  Create Dictionary  id=${orderfor}
    ${time}=      Create Dictionary   sTime=${stime}  eTime=${etime}
    Log  ${vargs}
    ${len}=  Get Length  ${vargs}
    ${items}=  Create Dictionary  id=${vargs[0]}  quantity=${vargs[1]}
    ${orderitem}=  Create List  ${items}
    FOR    ${index}   IN RANGE   2  ${len}  2
        ${index2}=  Evaluate  ${index}+1
        ${items}=  Create Dictionary  id=${vargs[${index}]}  quantity=${vargs[${index2}]}
        Append To List  ${orderitem}  ${items}
    END
    ${order}=    Create Dictionary  homeDelivery=${homeDelivery}  homeDeliveryAddress=${homeDeliveryAddress}   catalog=${catalog}  orderFor=${orderfor}  consumer=${Cid}  timeSlot=${time}  orderItem=${orderitem}   orderNote=${orderNote}  orderDate=${orderDate}  phoneNumber=${phoneNumber}  email=${email}  countryCode=${countryCode}
    # ${order}=  json.dumps  ${order}
    [Return]  ${order}

Create Order With Service Options
    [Arguments]    ${cookie}  &{kwargs}
    ${srvAnswers}=    evaluate    json.loads('''${kwargs['srvAnswers']}''')    json
    # Log  ${srvAnswers}
    Set To Dictionary  ${kwargs['order']}  srvAnswers=${srvAnswers}
    # Log  ${kwargs['order']}
    # ${order}=  json.dumps  ${kwargs['order']}
    ${order}=  Set Variable  ${kwargs['order']}
    # Log  ${order} 
    ${resp}=  OrderItemByProvider   ${Cookie}   ${order}
    [Return]  ${resp}

Release Appmt Qnr For Consumer
    [Arguments]    ${questId}  ${uuid}  ${releaseStatus}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw    /provider/appointment/questionnaire/${releaseStatus}/consumer/${questId}/${uuid}    expected_status=any
    [Return]  ${resp}

Get Enquiry Internal Status
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw   /provider/enquire/internalstatus    expected_status=any
    [Return]  ${resp}

Update and Proceed Enquiry to Status
    [Arguments]    ${enquireUid}  ${statusId}  ${location_id}  ${customer_id}  &{kwargs}
    Log  ${kwargs}
    ${data}=  Enquiry  ${location_id}  ${customer_id}  &{kwargs}
    ${data}=  json.dumps  ${data}
    Log  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw    /provider/enquire/${enquireUid}/proceed/status/${statusId}  data=${data}  expected_status=any
    [Return]  ${resp}

Reject Enquiry
    
    [Arguments]    ${enquireUid}    ${note}
    ${data}=   Create Dictionary   note=${note}
    Check And Create YNW Session
    ${data}=  json.dumps  ${data}
    ${resp}=    PUT On Session    ynw  /provider/enquire/${enquireUid}/reject  data=${data}  expected_status=any
    [Return]  ${resp}  
   

AppmtEnableEditToConsumer
    [Arguments]    ${questId}  ${uuid}  ${status}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw    /provider/appointment/questionnaire/edit/${status}/consumer/${questId}/${uuid}    expected_status=any
    [Return]  ${resp}

Release Order Qnr For Consumer
    [Arguments]    ${questId}  ${uuid}  ${releaseStatus}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw    /provider/orders/questionnaire/${releaseStatus}/consumer/${questId}/${uuid}    expected_status=any
    [Return]  ${resp}

OrderEnableEditToConsumer
    [Arguments]    ${questId}  ${uuid}  ${status}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw    /provider/orders/questionnaire/edit/${status}/consumer/${questId}/${uuid}    expected_status=any
    [Return]  ${resp}

Release Wl Qnr For Consumer
    [Arguments]    ${questId}  ${uuid}  ${releaseStatus}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw    /provider/waitlist/questionnaire/${releaseStatus}/consumer/${questId}/${uuid}    expected_status=any
    [Return]  ${resp}

WlEnableEditToConsumer
    [Arguments]    ${questId}  ${uuid}  ${status}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw    /provider/waitlist/questionnaire/edit/${status}/consumer/${questId}/${uuid}    expected_status=any
    [Return]  ${resp}


Create Order By Provider For AuthorDemy
    [Arguments]    ${Cookie}   ${Consumer_id}  ${orderfor}  ${catalog_id}   ${orderDate}  ${phoneNumber}   ${email}  ${orderNote}  ${countryCode}  @{vargs}
    ${catalog}=     Create Dictionary  id=${catalog_id} 
    ${Cid}=  Create Dictionary  id=${Consumer_id}
    ${orderfor}=  Create Dictionary  id=${orderfor}
   
    ${len}=  Get Length  ${vargs}
    ${items}=  Create Dictionary  id=${vargs[0]}  quantity=${vargs[1]}
    ${orderitem}=  Create List  ${items}
    FOR    ${index}   IN RANGE   2  ${len}  2
        ${index2}=  Evaluate  ${index}+1
        ${items}=  Create Dictionary  id=${vargs[${index}]}  quantity=${vargs[${index2}]}
        Append To List  ${orderitem}  ${items}
    END

    ${order}=    Create Dictionary   catalog=${catalog}  orderFor=${orderfor}  consumer=${Cid}  orderItem=${orderitem}   orderNote=${orderNote}  orderDate=${orderDate}  phoneNumber=${phoneNumber}  email=${email}  countryCode=${countryCode}
    ${resp}=  OrderItemByProvider   ${Cookie}   ${order}
    [Return]  ${resp}


# Get Account Settings from Cache
#     [Arguments]    ${uid}  ${user_id}  ${json_names}
#     Check And Create YNW Session
#     ${resp}=  GET On Session  ynw  /provider/account/settings/config/${uid}/${user_id}/${json_names}   expected_status=any
#     [Return]  ${resp}


Get Account Settings from Cache
    [Arguments]    ${uid}  ${json_names}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/account/settings/config/${uid}/${json_names}   expected_status=any
    [Return]  ${resp}


Licensable Metrices
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/license/metric  expected_status=any
    [Return]  ${resp}
    

Create Prescription Template
    [Arguments]    ${templateName}  @{vargs}
    ${len}=  Get Length  ${vargs}
    ${prescriptionsList}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${prescriptionsList}  ${vargs[${index}]}
    END

    ${data}=  Create Dictionary  prescriptionDto=${prescriptionsList}  templateName=${templateName}
    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/mr/prescription/template  data=${data}  expected_status=any
    [Return]  ${resp}

Get Prescription Template

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/mr/prescription/template  expected_status=any
    [Return]  ${resp}

Get Prescription Template By Id 
    [Arguments]  ${id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/mr/prescription/template/${id}  expected_status=any
    [Return]  ${resp}

Remove Template
    [Arguments]    ${id}
    Check And Create YNW Session
    ${resp}=   DELETE On Session   ynw   /provider/mr/prescription/template/${id}  expected_status=any
    [Return]  ${resp}

Update Prescription Template
    [Arguments]      ${id}  ${templateName}  @{vargs}

    ${len}=  Get Length  ${vargs}
    ${prescriptionsList}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${prescriptionsList}  ${vargs[${index}]}
    END

    ${prescriptions}=  Create Dictionary  prescriptionsList=${prescriptionsList}  templateName=${templateName}  id=${id}
    ${prescriptions}=  json.dumps  ${prescriptions}
    Check And Create YNW Session

    ${resp}=  PUT On Session  ynw  /provider/mr/prescription/template  data=${prescriptions}  expected_status=any
    [Return]  ${resp}

#Loan Application

Get Loan Application Category

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/loanapplication/category  expected_status=any
    [Return]  ${resp}

Get Loan Application Type

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/loanapplication/type  expected_status=any
    [Return]  ${resp}

Get Loan Application Status

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/loanapplication/status  expected_status=any
    [Return]  ${resp}

Get Loan Application Sub-Status

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/loanapplication/substatus  expected_status=any
    [Return]  ${resp}

Get Loan Application Product

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/loan/products  expected_status=any
    [Return]  ${resp}

Get Loan Application Scheme

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/loan/schemes  expected_status=any
    [Return]  ${resp}

Get Loan Application SP Internal Status

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/loanapplication/sp/internalstatus  expected_status=any
    [Return]  ${resp}

Create Loan Application

    [Arguments]      ${customer}  ${fname}  ${lname}  ${phone}  ${countrycode}  ${email}  ${category}  ${type}  ${loanProduct}  ${location}  ${locationArea}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}  ${action}  ${owner}  ${fileName}  ${fileSize}  ${caption}  ${fileType}  ${order}  @{vargs}    &{kwargs}
    
    ${customer}=       Create Dictionary    id=${customer}  firstName=${fname}  lastName=${lname}  phoneNo=${phone}  countryCode=${countrycode}  email=${email}
    ${category}=       Create Dictionary    id=${category}
    ${type}=           Create Dictionary    id=${type}
    ${loanProduct}=    Create Dictionary    id=${loanProduct}
    ${location}=       Create Dictionary    id=${location}

    ${consumerPhoto}=  Create Dictionary  action=${action}  owner=${owner}  fileName=${fileName}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    ${ConsumerPhotoList}=  Create List  ${consumerPhoto}

    ${len}=  Get Length  ${vargs}
    ${LoanApplicationKycList}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${LoanApplicationKycList}  ${vargs[${index}]}
    END

    ${loan}=  Create Dictionary  customer=${customer}  category=${category}  type=${type}  loanProduct=${loanProduct}  location=${location}  locationArea=${locationArea}  invoiceAmount=${invoiceAmount}  downpaymentAmount=${downpaymentAmount}  requestedAmount=${requestedAmount}  remarks=${remarks}  consumerPhoto=${ConsumerPhotoList}  loanApplicationKycList=${LoanApplicationKycList}

    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${loan} 	${key}=${value}
    END

    ${loan}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/loanapplication  data=${loan}  expected_status=any
    [Return]  ${resp}

Update Loan Application

    [Arguments]   ${loanApplicationRefNo}   ${customer}     ${category}  ${type}  ${status}   ${loanProduct}    ${location}  ${locationArea}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}     ${action}  ${owner}  ${fileName}  ${fileSize}  ${caption}  ${fileType}  ${order}   @{vargs}
    
    ${customer}=       Create Dictionary    id=${customer}
    ${category}=       Create Dictionary    id=${category}
    ${type}=           Create Dictionary    id=${type}
    ${loanProduct}=    Create Dictionary    id=${loanProduct}
    ${location}=       Create Dictionary    id=${location}
    ${status}=       Create Dictionary    id=${status}
   
    ${consumerPhoto}=  Create Dictionary  action=${action}  owner=${owner}  fileName=${fileName}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    ${ConsumerPhotoList}=  Create List  ${consumerPhoto}

    ${len}=  Get Length  ${vargs}
    ${LoanApplicationKycList}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${LoanApplicationKycList}  ${vargs[${index}]}
    END

    ${loan}=  Create Dictionary  customer=${customer}  category=${category}  type=${type}   status=${status}  loanProduct=${loanProduct}    location=${location}  locationArea=${locationArea}  invoiceAmount=${invoiceAmount}  downpaymentAmount=${downpaymentAmount}  requestedAmount=${requestedAmount}  remarks=${remarks}       consumerPhoto=${ConsumerPhotoList}    loanApplicationKycList=${LoanApplicationKycList}
    ${loan}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/loanapplication/${loanApplicationRefNo}  data=${loan}  expected_status=any
    [Return]  ${resp}



Get Loan Application With Filter

    [Arguments]    &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/loanapplication  params=${param}  expected_status=any
    [Return]  ${resp}

Get Loan Application Count with filter

    [Arguments]    &{param}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/loanapplication/count  params=${param}  expected_status=any
    [Return]  ${resp}

Get Loan Application by loanApplicationRefNo

    [Arguments]    ${loanApplicationRefNo}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/loanapplication/${loanApplicationRefNo}  expected_status=any
    [Return]  ${resp}

Approval Loan Application

    [Arguments]    ${loanApplicationUid}  

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/loanapplication/${loanApplicationUid}/approvalrequest    expected_status=any
    [Return]  ${resp}


Reject Loan Application

    [Arguments]    ${loanApplicationRefNo}  ${note}

    ${data}=  Create Dictionary    note=${note}
    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/loanapplication/${loanApplicationRefNo}/reject  data=${data}  expected_status=any
    [Return]  ${resp}

Change Loan Application Status

    [Arguments]    ${loanApplicationRefNo}  ${statusId}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/loanapplication/${loanApplicationRefNo}/status/${statusId}  expected_status=any
    [Return]  ${resp}

Change Loan Application Sub-Status

    [Arguments]    ${loanApplicationRefNo}  ${substatusId}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/loanapplication/${loanApplicationRefNo}/substatus/${substatusId}  expected_status=any
    [Return]  ${resp}

Change Loan Application Status with sp
   
    [Arguments]    ${loanApplicationRefNo} 

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/loanapplication/${loanApplicationRefNo}/sp/publicnotes  expected_status=any
    [Return]  ${resp}

#Partner

Create Partner
    [Arguments]        ${category}   ${type}    ${partnerName}    ${partnerAliasName}    ${partnerMobile}    ${partnerEmail}
    ...  ${description}    ${aadhaar}    ${pan}    ${gstin}    ${partnerAddress1}    ${partnerAddress2}    ${partnerPin}    ${partnerCity}   ${partnerState}    ${bankName}
    ...    ${bankAccountNo}    ${bankIfsc}    ${partnerSize}    ${partnerTrade}   ${ecommerce}    ${multiUserRequired}    ${action}  ${owner}  ${fileName}  ${fileSize}  ${caption}  ${fileType}  ${order}    @{vargs}
    
    ${category}=       Create Dictionary    id=${category}
    ${type}=           Create Dictionary    id=${type}

    ${consumerPhoto}=  Create Dictionary  action=${action}  owner=${owner}  fileName=${fileName}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    ${ConsumerPhotoList}=  Create List  ${consumerPhoto}
   
    ${len}=  Get Length  ${vargs}
    ${LoanApplicationKycList}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${LoanApplicationKycList}  ${vargs[${index}]}
    END

    ${loan}=  Create Dictionary    category=${category}  type=${type}   partnerName=${partnerName}   partnerAliasName=${partnerAliasName}    partnerMobile=${partnerMobile}
    ...    partnerEmail=${partnerEmail}    description=${description}    aadhaar=${aadhaar}    pan=${pan}    gstin=${gstin}    partnerAddress1=${partnerAddress1}
    ...    partnerAddress2=${partnerAddress2}    partnerPin=${partnerPin}    partnerCity=${partnerCity}    partnerState=${partnerState}    bankName=${bankName}
    ...    bankAccountNo=${bankAccountNo}    bankIfsc=${bankIfsc}    partnerSize=${partnerSize}    partnerTrade=${partnerTrade}    ecommerce=${ecommerce}    multiUserRequired=${multiUserRequired}    consumerPhoto=${ConsumerPhotoList}  loanApplicationKycList=${LoanApplicationKycList}
    ${loan}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/partner  data=${loan}  expected_status=any
    [Return]  ${resp}

Get Partner Category

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/partner/category  expected_status=any
    [Return]  ${resp}

Get Partner Type

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/partner/type  expected_status=any
    [Return]  ${resp}


Draft a Partner
    [Arguments]        ${category}    ${type}      ${partnerName}    ${partnerAliasName}    ${partnerMobile}    ${partnerEmail}
    ...  ${description}    ${aadhaar}    ${pan}    ${gstin}    ${partnerAddress1}    ${partnerAddress2}    ${partnerPin}    ${partnerCity}   ${partnerState}    ${bankName}
    ...    ${bankAccountNo}    ${bankIfsc}    ${partnerSize}    ${partnerTrade}   ${ecommerce}    ${multiUserRequired}    @{vargs}
    
    
    ${category}=       Create Dictionary    id=${category}
    ${type}=           Create Dictionary    id=${type}
    
   
    ${len}=  Get Length  ${vargs}
    ${LoanApplicationKycList}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${LoanApplicationKycList}  ${vargs[${index}]}
    END

    ${loan}=  Create Dictionary    category=${category}  type=${type}   partnerName=${partnerName}   partnerAliasName=${partnerAliasName}    partnerMobile=${partnerMobile}
    ...    partnerEmail=${partnerEmail}    description=${description}    aadhaar=${aadhaar}    pan=${pan}    gstin=${gstin}    partnerAddress1=${partnerAddress1}
    ...    partnerAddress2=${partnerAddress2}    partnerPin=${partnerPin}    partnerCity=${partnerCity}    partnerState=${partnerState}    bankName=${bankName}
    ...    bankAccountNo=${bankAccountNo}    bankIfsc=${bankIfsc}    partnerSize=${partnerSize}    partnerTrade=${partnerTrade}    ecommerce=${ecommerce}    multiUserRequired=${multiUserRequired}
    ${loan}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/partner/draft   data=${loan}  expected_status=any
    [Return]  ${resp}



Update Partner
    [Arguments]     ${partnerUid}   ${headOffice}   ${category}   ${type}    ${branch}    ${partnerName}    ${partnerAliasName}    ${partnerMobile}    ${partnerEmail}
    ...  ${description}    ${aadhaar}    ${pan}    ${gstin}    ${partnerAddress1}    ${partnerAddress2}    ${partnerPin}    ${partnerCity}    ${partnerDistrict}   ${partnerState}    ${googleMapUrl}    ${googleMapLocation}    ${longitude}    ${latitude}    ${bankName}
    ...    ${bankAccountNo}    ${bankIfsc}    ${partnerSize}    ${partnerTrade}   ${ecommerce}    ${multiUserRequired}    ${action}  ${owner}  ${fileName}  ${fileSize}  ${caption}  ${fileType}  ${order}    @{vargs}  &{kwargs}
    
   
    ${category}=       Create Dictionary    id=${category}
    ${type}=           Create Dictionary    id=${type}

    ${consumerPhoto}=  Create Dictionary  action=${action}  owner=${owner}  fileName=${fileName}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    ${ConsumerPhotoList}=  Create List  ${consumerPhoto}
  
    ${len}=  Get Length  ${vargs}
    ${LoanApplicationKycList}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${LoanApplicationKycList}  ${vargs[${index}]}
    END

    ${loan}=  Create Dictionary      headOffice=${headOffice}    category=${category}  type=${type}    branch=${branch}   partnerName=${partnerName}   partnerAliasName=${partnerAliasName}    partnerMobile=${partnerMobile}
    ...    partnerEmail=${partnerEmail}    description=${description}    aadhaar=${aadhaar}    pan=${pan}    gstin=${gstin}    partnerAddress1=${partnerAddress1}
    ...    partnerAddress2=${partnerAddress2}    partnerPin=${partnerPin}    partnerCity=${partnerCity}    partnerDistrict=${partnerDistrict}     partnerState=${partnerState}    googleMapUrl=${googleMapUrl}    googleMapLocation=${googleMapLocation}    longitude=${longitude}    latitude=${latitude}    bankName=${bankName}
    ...    bankAccountNo=${bankAccountNo}    bankIfsc=${bankIfsc}    partnerSize=${partnerSize}    partnerTrade=${partnerTrade}    ecommerce=${ecommerce}    multiUserRequired=${multiUserRequired}    validFrom=${validFrom}    validTo=${validTo}    consumerPhoto=${ConsumerPhotoList}  loanApplicationKycList=${LoanApplicationKycList}

    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${loan} 	${key}=${value}
    END

    ${loan}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  provider/partner/${partnerUid}   data=${loan}  expected_status=any
    [Return]  ${resp}


Get Partner by UID

    [Arguments]     ${partnerUid}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw    /provider/partner/${partnerUid}    expected_status=any
    [Return]  ${resp}


Get Partner-With Filter

    [Arguments]    &{param}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/partner   params=${param}   expected_status=any
    [Return]  ${resp}


Get Partner Count-With Filter 

    [Arguments]  &{param}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/partner/count  params=${param}  expected_status=any
    [Return]  ${resp}

Approved Partner

    [Arguments]    ${note}  ${partnerUid}

    ${note}=  Create Dictionary  note=${note}
    ${data}=  json.dumps  ${note}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/partner/${partnerUid}/approved  data=${data}  expected_status=any
    [Return]  ${resp}

Suspended Partner

    [Arguments]    ${note}  ${partnerUid}

    ${note}=  Create Dictionary  note=${note}
    ${data}=  json.dumps  ${note}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/partner/${partnerUid}/suspended  data=${data}   expected_status=any
    [Return]  ${resp}

Reject Partner

    [Arguments]    ${note}  ${partnerUid}

    ${note}=  Create Dictionary  note=${note}
    ${data}=  json.dumps  ${note}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/partner/${partnerUid}/rejected  data=${data}  expected_status=any
    [Return]  ${resp}

Remove Assignee

    [Arguments]    ${loanApplicationUid} 

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   url=/provider/loanapplication/${loanApplicationUid}/assignee/remove  expected_status=any
    [Return]  ${resp}

Change Loan Assignee

    [Arguments]    ${loanApplicationUid}   ${userId}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   url=/provider/loanapplication/${loanApplicationUid}/assignee/${userId}  expected_status=any
    [Return]  ${resp}

Loan Application Approval

    [Arguments]    ${loanApplicationUid}   

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   url=/provider/loanapplication/${loanApplicationUid}/approvalrequest  expected_status=any
    [Return]  ${resp}



Create Partner User

    [Arguments]    ${id}  ${partnerUid}     ${firstName}       ${countryCode}    ${mobileNo}    ${email}    ${mobileNoVerified}    ${emailVerified}    ${admin}

    ${defaultPartner}=     Create Dictionary  id=${id}

    ${PartnerUser}=     Create Dictionary       defaultPartner=${defaultPartner}   firstName=${firstName}        countryCode=${countryCode}    mobileNo=${mobileNo}    email=${email}  mobileNoVerified=${mobileNoVerified}    emailVerified=${emailVerified}  admin=${admin}
    ${data}=  json.dumps  ${PartnerUser}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /provider/partner/${partnerUid}/user    data=${data}   expected_status=any
    [Return]  ${resp}

Update Partner User

    [Arguments]    ${userId}    ${id}  ${partnerUid}     ${firstName}       ${countryCode}    ${mobileNo}    ${email}    ${mobileNoVerified}    ${emailVerified}    ${admin}

    ${defaultPartner}=     Create Dictionary  id=${id}

    ${PartnerUser}=     Create Dictionary       defaultPartner=${defaultPartner}   firstName=${firstName}        countryCode=${countryCode}    mobileNo=${mobileNo}    email=${email}  mobileNoVerified=${mobileNoVerified}    emailVerified=${emailVerified}  admin=${admin}
    ${data}=  json.dumps  ${PartnerUser}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/partner/${partnerUid}/user/${userId}    data=${data}   expected_status=any
    [Return]  ${resp}

Get Partner User

    [Arguments]    ${partnerUid}   
    
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/partner/${partnerUid}/users   expected_status=any
    [Return]  ${resp}

#Otp For Phone Number
Generate Loan Application Otp for Phone Number

    [Arguments]    ${number}  ${countryCode}

    ${data}=  Create Dictionary  countryCode=${countryCode}  number=${number}
    ${data}=  json.dumps  ${data}
    # ${headers2}=     Create Dictionary    Content-Type=application/json    Authorization=browser
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw     /provider/loanapplication/generate/phone   data=${data}   expected_status=any 
    [Return]  ${resp}

#Verify Otp for phone
Verify Phone Otp and Create Loan Application

    [Arguments]    ${loginId}   ${purpose}  ${id}  ${firstName}  ${lastName}  ${phoneNo}  ${countryCode}   ${locid}     @{vargs}

    ${customer}=  Create Dictionary      id=${id}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phoneNo}  countryCode=${countryCode}
    ${location}=  Create Dictionary      id=${locid}
   
    ${otp}=   verify accnt  ${loginId}  ${purpose}

    ${len}=  Get Length  ${vargs}
    ${LoanApplicationKycList}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${LoanApplicationKycList}  ${vargs[${index}]}
    END

    ${loan}=  Create Dictionary   customer=${customer}  location=${location}   loanApplicationKycList=${LoanApplicationKycList}
    ${loan}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/loanapplication/verify/${otp}/phone  data=${loan}  expected_status=any
    [Return]  ${resp}


Verify Phone and Create Loan Application with customer details

    [Arguments]    ${loginId}   ${purpose}  ${id}  ${locid}   @{vargs}  &{custDetailskwargs}

    ${location}=  Create Dictionary      id=${locid}
   
    ${otp}=   verify accnt  ${loginId}  ${purpose}

    ${len}=  Get Length  ${vargs}
    ${LoanApplicationKycList}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${LoanApplicationKycList}  ${vargs[${index}]}
    END

    ${customer}=  Create Dictionary      id=${id}

    Log Many  @{custDetailskwargs}
    FOR  ${key}  IN  @{custDetailskwargs}
        IF  '${key}' in @{custdeets}
            Set to Dictionary  ${customer}  ${key}=${custDetailskwargs}[${key}]
        END
    END

    ${loan}=  Create Dictionary   customer=${customer}  location=${location}   loanApplicationKycList=${LoanApplicationKycList}
    ${loan}=  json.dumps  ${loan}  
    Log  ${loan}

    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/loanapplication/verify/${otp}/phone  data=${loan}  expected_status=any
    [Return]  ${resp}


# Otp For Email
Generate Loan Application Otp for Email

    [Arguments]    ${email}

    ${data}=  Create Dictionary  email=${email}
    ${data}=  json.dumps  ${data}
    # ${headers2}=     Create Dictionary    Content-Type=application/json    Authorization=browser
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw     /provider/loanapplication/generate/email  data=${data}   expected_status=any 
    [Return]  ${resp}

# Verify Otp for Email
Verify Email Otp and Create Loan Application

    [Arguments]    ${email}   ${purpose}  ${uid}
   
    ${otp}=   verify accnt  ${email}  ${purpose}
    ${loan}=  Create Dictionary   uid=${uid}
    ${data}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  url=/provider/loanapplication/verify/${otp}/email  data=${data}  expected_status=any
    [Return]  ${resp}

Requst For Aadhar Validation

    [Arguments]      ${id}  ${loanApplicationUid}  ${customerPhone}  ${aadhaar}      @{vargs}
    

    ${len}=  Get Length  ${vargs}
    ${aadhaarAttachmentsList}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${aadhaarAttachmentsList}  ${vargs[${index}]}
    END

    ${loan}=  Create Dictionary    id=${id}   loanApplicationUid=${loanApplicationUid}  customerPhone=${customerPhone}  aadhaar=${aadhaar}   aadhaarAttachments=${aadhaarAttachmentsList}
    ${loan}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/loanapplication/update/UID  data=${loan}  expected_status=any
    [Return]  ${resp}

Requst For Pan Validation

    [Arguments]      ${id}  ${loanApplicationUid}  ${customerPhone}  ${pan}      @{vargs}
    

    ${len}=  Get Length  ${vargs}
    ${panAttachments}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${panAttachments}  ${vargs[${index}]}
    END

    ${loan}=  Create Dictionary    id=${id}   loanApplicationUid=${loanApplicationUid}  customerPhone=${customerPhone}  pan=${pan}   panAttachments=${panAttachments}
    ${loan}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/loanapplication/update/Pan  data=${loan}  expected_status=any
    [Return]  ${resp}

Add loan Bank Details

    [Arguments]      ${originUid}  ${loanApplicationUid}  ${bankName}  ${bankAccountNo}  ${bankIfsc}  ${branchname}  @{vargs}
    

    ${len}=  Get Length  ${vargs}
    ${bankStatementAttachments}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${bankStatementAttachments}  ${vargs[${index}]}
    END

    ${loan}=  Create Dictionary   originUid=${originUid}  loanApplicationUid=${loanApplicationUid}  bankName=${bankName}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  bankBranchName=${branchname}    bankStatementAttachments=${bankStatementAttachments}
    ${loan}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/loanapplication/bank  data=${loan}  expected_status=any
    [Return]  ${resp}

Update loan Bank Details

    [Arguments]      ${originFrom}  ${originUid}  ${loanApplicationUid}  ${bankName}  ${bankAccountNo}  ${bankIfsc}  ${bankAddress1}  ${bankAddress2}  ${bankCity}  ${bankState}  ${bankPin}  @{vargs}
    

    ${len}=  Get Length  ${vargs}
    ${bankStatementAttachments}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${bankStatementAttachments}  ${vargs[${index}]}
    END

    ${loan}=  Create Dictionary   originFrom=${originFrom}  originUid=${originUid}  loanApplicationUid=${loanApplicationUid}  bankName=${bankName}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  bankAddress1=${bankAddress1}  bankAddress2=${bankAddress2}  bankCity=${bankCity}  bankState=${bankState}  bankPin=${bankPin}    bankStatementAttachments=${bankStatementAttachments}
    ${loan}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/loanapplication/bank  data=${loan}  expected_status=any
    [Return]  ${resp}

Verify loan Bank

    [Arguments]    ${uid}     ${accountnum}    ${ifsc}    &{kwargs}
   
    ${loan}=  Create Dictionary      originUid=${uid}      bankAccountNo=${accountnum}    bankIfsc=${ifsc}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${loan} 	${key}=${value}
    END
    ${data}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/loanapplication/verify/bank  data=${data}  expected_status=any
    [Return]  ${resp}

Verify loan Details

    [Arguments]      ${id}  ${loanProduct}  ${type}  ${invoiceAmount}  ${employee}  ${downpaymentAmount}  ${requestedAmount}  ${productCategoryId}   ${productSubCategoryId}   ${referralEmployeeCode}  ${subventionLoan}  ${montlyIncome}  ${emiPaidAmountMonthly}    @{vargs}    &{kwargs}

    ${len}=  Get Length  ${vargs}
    ${LoanApplicationKycList}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${LoanApplicationKycList}  ${vargs[${index}]}
    END

    ${loan}=  Create Dictionary  id=${id}   loanProducts=${loanProduct}  type=${type}  invoiceAmount=${invoiceAmount}  employee=${employee}  downpaymentAmount=${downpaymentAmount}  requestedAmount=${requestedAmount}   productCategoryId=${productCategoryId}   productSubCategoryId=${productSubCategoryId}   referralEmployeeCode=${referralEmployeeCode}  subventionLoan=${subventionLoan}  montlyIncome=${montlyIncome}  emiPaidAmountMonthly=${emiPaidAmountMonthly}   loanApplicationKycList=${LoanApplicationKycList}

    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${loan} 	${key}=${value}
    END

    ${loan}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/loanapplication/request  data=${loan}  expected_status=any
    [Return]  ${resp}

Get loan Bank

    [Arguments]    ${id}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/loanapplication/bank/${id}   expected_status=any
    [Return]  ${resp}

Get loan Bank Details

    [Arguments]    ${loanApplicationUid}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/loanapplication/${loanApplicationUid}/bankdetails   expected_status=any
    [Return]  ${resp}

Otp for Consumer Acceptance Phone

    [Arguments]    ${phoneNo}  ${email}  ${countryCode}

    ${data}=  Create Dictionary  countryCode=${countryCode}  email=${email}  phoneNo=${phoneNo}
    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=    POST On Session    ynw     /provider/loanapplication/generate/acceptance   data=${data}   expected_status=any 
    [Return]  ${resp}

Otp for Consumer Loan Acceptance Phone

    [Arguments]    ${loginId}   ${purpose}   ${uid}
   
    ${otp}=   verify accnt  ${loginId}  ${purpose}

    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/loanapplication/verify/${uid}/acceptance/${otp}/phone  expected_status=any
    [Return]  ${resp}

Otp for Consumer Acceptance Email

    [Arguments]    ${email}

    ${data}=  Create Dictionary  email=${email}
    ${data}=  json.dumps  ${data}
    # ${headers2}=     Create Dictionary    Content-Type=application/json    Authorization=browser
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw     /provider/loanapplication/generate/acceptance/email  data=${data}   expected_status=any 
    [Return]  ${resp}

Verify Otp for Consumer Acceptance Email

    [Arguments]    ${email}   ${purpose}   ${uid}
   
    ${otp}=   verify accnt  ${email}  ${purpose}

    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/loanapplication/verify/${uid}/acceptance/${otp}/email  expected_status=any
    [Return]  ${resp}

Refresh loan Bank Details Aadhaar
    
    [Arguments]    ${uid}
    
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/loanapplication/aadhar/status/${uid}  expected_status=any
    [Return]  ${resp}

Loan Application Action Required
    
    [Arguments]    ${note}  ${loanApplicationUid}  ${statusId}

    ${data}=  Create Dictionary  note=${note}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/loanapplication/${loanApplicationUid}/actionrequired/spinternalstatus/${statusId}  data=${data}  expected_status=any
    [Return]  ${resp}

Loan Application Action Completed

    [Arguments]    ${note}  ${loanApplicationUid}

    ${data}=  Create Dictionary  note=${note}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/loanapplication/${loanApplicationUid}/actioncompleted  data=${data}  expected_status=any
    [Return]  ${resp}

Update loan Application Kyc Details
    
    [Arguments]      ${id}  ${loanApplicationUid}  ${customerPhone}    &{kwargs}

    ${loan}=  Create Dictionary    id=${id}   loanApplicationUid=${loanApplicationUid}  customerPhone=${customerPhone}  

    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${loan} 	${key}=${value}
    END

    ${loan}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/loanapplication/kyc/update  data=${loan}  expected_status=any
    [Return]  ${resp}

Loan Application Manual Approval

    [Arguments]    ${loanApplicationUid}   ${loanScheme}   ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${sanctionedAmount}     &{kwargs}

    ${data}=     Create Dictionary    loanScheme=${loanScheme}    invoiceAmount=${invoiceAmount}    downpaymentAmount=${downpaymentAmount}    requestedAmount=${requestedAmount}  sanctionedAmount=${sanctionedAmount}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   url=/provider/loanapplication/${loanApplicationUid}/manualapproval    data=${data}   expected_status=any
    [Return]  ${resp}

Loan Approval

    [Arguments]    ${loanApplicationUid}   ${Schemeid}  

    ${loanScheme}=  Create Dictionary  id=${Schemeid}
    ${data}=  Create Dictionary  loanScheme=${loanScheme}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/loanapplication/${loanApplicationUid}/approval  data=${data}  expected_status=any
    [Return]  ${resp}

Delete Loan Attachment
    [Arguments]    ${Uid}   ${customerPhone}    ${ownerid}        ${fileName}      ${fileSize}        ${caption}    ${fileType}    ${action}       ${type}   ${order}  &{kwargs}
    

    ${aadhaarAttachments}=  Create Dictionary   owner=${ownerid}   fileName=${fileName}    fileSize=${fileSize}    caption=${caption}    fileType=${fileType}    action=${action}    type=${type}    order=${order}   
    ${aadhaarAttachments}=    Create List   ${aadhaarAttachments}

    ${panAttachments}=  Create Dictionary   owner=${ownerid}   fileName=${fileName}    fileSize=${fileSize}    caption=${caption}    fileType=${fileType}    action=${action}    type=${type}    order=${order}   
    ${panAttachments}=    Create List   ${panAttachments}

    ${loanApplicationKycList}=    Create Dictionary    uid=${Uid}    customerPhone=${customerPhone}    aadhaarAttachments=${aadhaarAttachments}    panAttachments=${panAttachments}

    # ${pan}=  Create Dictionary     owner=${owner}        fileName=${fileName}        fileSize=${fileSize}        caption=${caption}        fileType=${fileType}        order=${order}
    # ${panAttachments}=    Create List    ${pan}

    ${data}=  Create List    ${loanApplicationKycList}    
    ${data}=  Create Dictionary    loanApplicationKycList=${data}      
    Log  ${data}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/loanapplication/attachments  data=${data}  expected_status=any
    [Return]  ${resp}


Get User Available
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/user/available   expected_status=any
    [Return]  ${resp}


Create Reminder
    [Arguments]   ${prov_id}  ${provcons_id}  ${msg}  ${sms}  ${email}  ${pushnotification}
    ...   ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}
    ${schedule}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}
    ${remindersource}=  Create Dictionary    Sms=${sms}   Email=${email}  PushNotification=${pushnotification} 
    ${data}=  Create Dictionary  schedule=${schedule}  provider=${prov_id}  
    ...   providerConsumer=${provcons_id}  message=${msg}  reminderSource=${remindersource}
    Check And Create YNW Session
    ${data}=  json.dumps  ${data}
    ${resp}=  POST On Session  ynw  /provider/mr/reminder  data=${data}  expected_status=any
    [Return]  ${resp}


Update Reminder
    [Arguments]   ${reminder_id}  ${prov_id}  ${provcons_id}  ${msg}  ${sms}  ${email}  ${pushnotification}
    ...   ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}
    ${schedule}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}
    ${remindersource}=  Create Dictionary    Sms=${sms}   Email=${email}  PushNotification=${pushnotification} 
    ${data}=  Create Dictionary    schedule=${schedule}  provider=${prov_id}  
    ...   providerConsumer=${provcons_id}  message=${msg}  reminderSource=${remindersource}
    Check And Create YNW Session
    ${data}=  json.dumps  ${data}
    ${resp}=  PUT On Session  ynw  /provider/mr/reminder/${reminder_id}  data=${data}  expected_status=any
    [Return]  ${resp}

Get Reminders
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/mr/reminder  params=${param}  expected_status=any
    [Return]  ${resp}

Get Reminders With Filter
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/mr/reminders  params=${param}  expected_status=any
    [Return]  ${resp}


Delete Reminder
   [Arguments]   ${reminder_id}
   Check And Create YNW Session
   ${resp}=    DELETE On Session    ynw  /provider/mr/reminder/${reminder_id}  expected_status=any
   [Return]  ${resp}

LoanApplication Remark

    [Arguments]   ${uid}  ${remarks}

    ${data}=  Create Dictionary    uid=${uid}  remarks=${remarks}
    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw     /provider/loanapplication/remark   data=${data}   expected_status=any 
    [Return]  ${resp}

Add General Notes

    [Arguments]  ${uid}  ${note}

    ${data}=  Create Dictionary    note=${note}
    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw     /provider/loanapplication/${uid}/note   data=${data}   expected_status=any 
    [Return]  ${resp}
    
#   Appt Request


Provider Create Appt Service Request
    [Arguments]      ${consid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${countryCode}  ${phoneNumber}  ${coupons}  ${appmtFor}  &{kwargs}
    ${sid}=  Create Dictionary  id=${service_id} 
    ${cid}=  Create Dictionary  id=${consid}
    ${schedule}=  Create Dictionary  id=${schedule}
    ${data}=    Create Dictionary   appmtDate=${appmtDate}  service=${sid}  schedule=${schedule}
    ...   appmtFor=${appmtFor}    consumerNote=${consumerNote}  phoneNumber=${phoneNumber}   coupons=${coupons}
    ...   consumer=${cid}  countryCode=${countryCode} 
    ${items}=  Get Dictionary items  ${kwargs}
        FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${data}   ${key}=${value}
    END 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/appointment/service/request  data=${data}  expected_status=any
    [Return]  ${resp}


Provider Get Appt Service Request
    [Arguments]    &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/appointment/service/request    params=${kwargs}    expected_status=any
    [Return]  ${resp}


Provider Get Appt Service Request Count
    [Arguments]    &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/appointment/service/request/count   params=${kwargs}    expected_status=any
    [Return]  ${resp}


Confirm Appt Service Request
    [Arguments]    ${uid}  ${consid}  ${service_id}  ${schedule}  ${appmtDate}  ${consumerNote}  ${countryCode}  ${phoneNumber}  ${coupons}  ${appmtFor}  &{kwargs}
    ${sid}=  Create Dictionary  id=${service_id} 
    ${cid}=  Create Dictionary  id=${consid}
    ${schedule}=  Create Dictionary  id=${schedule}
    ${data}=    Create Dictionary   appmtDate=${appmtDate}  service=${sid}  schedule=${schedule}
    ...   appmtFor=${appmtFor}    consumerNote=${consumerNote}  phoneNumber=${phoneNumber}   coupons=${coupons}
    ...   countryCode=${countryCode}   consumer=${cid}  uid=${uid}
    ${items}=  Get Dictionary items  ${kwargs}
        FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${data}   ${key}=${value}
    END 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/appointment/service/request/changestatus/confirmed  data=${data}  expected_status=any
    [Return]  ${resp}


Reject Appt Service Request
    [Arguments]    ${appmntId}  
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/appointment/service/request/reject/${appmntId}   expected_status=any
    [Return]  ${resp}

Partner Approval Request

    [Arguments]    ${partnerUid}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/partner/${partnerUid}/approvalrequest   expected_status=any
    [Return]  ${resp}

Partner Approved

    [Arguments]    ${partnerUid}    ${note}

    ${data}=  Create Dictionary    note=${note}
    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/partner/${partnerUid}/approved    data=${data}  expected_status=any
    [Return]  ${resp}

Create Scheme

    [Arguments]   ${account}  ${schemeName}  ${schemeAliasName}  ${integrationId}  ${schemeType}  ${rateType}  ${schemeRate}  ${displayRate}  ${noOfAdvancePayment}  ${noOfAdvanceSuggested}  ${minDuration}  ${maxDuration}  ${minAmount}  ${maxAmount}  ${minAge}  ${maxAge}  ${loanToValue}  ${employeeScheme}  ${subventionScheme}  ${subventionRate}  ${bureauScores}  ${processingFeeRate}    ${processingFeeAmount}  ${overdueChargeRate}    ${foreClosureCharge}    ${foirOnDeclaredIncome}  ${foirOnAssesedIncome}     ${noOfCoApplicatRequired}  ${noOfSpdcRequired}  ${noOfPdcRequired}  ${multiItem}  ${defaultScheme}  ${status}

    ${data}=  Create Dictionary    account=${account}  schemeName=${schemeName}  schemeAliasName=${schemeAliasName}  integrationId=${integrationId}  schemeType=${schemeType}  rateType=${rateType}  schemeRate=${schemeRate}  displayRate=${displayRate}  noOfAdvancePayment=${noOfAdvancePayment}  noOfAdvanceSuggested=${noOfAdvanceSuggested}  minDuration=${minDuration}  maxDuration=${maxDuration}  minAmount=${minAmount}  maxAmount=${maxAmount}  minAge=${minAge}  maxAge=${maxAge}  loanToValue=${loanToValue}  employeeScheme=${employeeScheme}  subventionScheme=${subventionScheme}  subventionRate=${subventionRate}  bureauScores=${bureauScores}  processingFeeRate=${processingFeeRate}    processingFeeAmount=${processingFeeAmount}  overdueChargeRate=${overdueChargeRate}    foreClosureCharge=${foreClosureCharge}    foirOnDeclaredIncome=${foirOnDeclaredIncome}  foirOnAssesedIncome=${foirOnAssesedIncome}     noOfCoApplicatRequired=${noOfCoApplicatRequired}  noOfSpdcRequired=${noOfSpdcRequired}  noOfPdcRequired=${noOfPdcRequired}  multiItem=${multiItem}  defaultScheme=${defaultScheme}  status=${status}

    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=    POST On Session    ynw     /provider/loan/scheme   data=${data}   expected_status=any 
    [Return]  ${resp}

Update Scheme

    [Arguments]   ${id}  ${account}  ${schemeName}  ${schemeAliasName}  ${schemeType}  ${schemeRate}  ${noOfRepayment}  ${noOfAdvancePayment}  ${noOfAdvanceSuggested}  ${serviceCharge}  ${insuranceCharge}  ${minAmount}  ${maxAmount}  ${status}  ${description}

    ${data}=  Create Dictionary    account=${account}  schemeName=${schemeName}  schemeAliasName=${schemeAliasName}  schemeType=${schemeType}  schemeRate=${schemeRate}  noOfRepayment=${noOfRepayment}  noOfAdvancePayment=${noOfAdvancePayment}  noOfAdvanceSuggested=${noOfAdvanceSuggested}  serviceCharge=${serviceCharge}  insuranceCharge=${insuranceCharge}  minAmount=${minAmount}  maxAmount=${maxAmount}  status=${status}  description=${description}
    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw     /provider/loan/scheme/${id}   data=${data}   expected_status=any 
    [Return]  ${resp}

Get Loan Application By uid

    [Arguments]    ${loanApplicationUid}   
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/loanapplication/${loanApplicationUid}    expected_status=any
    [Return]  ${resp}


Update Sales Officer

    [Arguments]    ${ptnruid}    @{vargs}

    ${len}=  Get Length  ${vargs}
    ${salesofficer}=  Create List
    
    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${salesofficer}  ${vargs[${index}]}
    END
    ${data}=  json.dumps  ${salesofficer}

    Check And Create YNW Session 
    ${resp}=    PUT On Session  ynw  /provider/partner/${ptnruid}/updatesalesofficer    data=${data}   expected_status=any
    [Return]  ${resp}

Update Credit Officer

    [Arguments]    ${ptnruid}    @{vargs}

    ${len}=  Get Length  ${vargs}
    ${creditofficer}=  Create List
    
    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${creditofficer}  ${vargs[${index}]}
    END
    ${data}=  json.dumps  ${creditofficer}

    Check And Create YNW Session 
    ${resp}=    PUT On Session  ynw  /provider/partner/${ptnruid}/updatecreditofficer    data=${data}   expected_status=any
    [Return]  ${resp}

Activate Partner

    [Arguments]    ${partnerUid}    ${activeStatus}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/partner/${partnerUid}/active/${activeStatus}    expected_status=any
    [Return]  ${resp}


# ......RBAC......


Get Default Capabilities
    [Arguments]    ${feature}   
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/user/defaultCapabilities/${feature}    expected_status=any
    [Return]  ${resp}


Get Default Roles With Capabilities
    [Arguments]    ${feature}   
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/user/defaultRolesCapabilities/${feature}    expected_status=any
    [Return]  ${resp}


Create User With Roles And Scope
    [Arguments]  ${fname}  ${lname}  ${dob}  ${gender}  ${email}  ${user_type}  ${pincode}  ${countryCode}  ${mob_no}  ${dept_id}  ${sub_domain}  ${admin}  ${whatsApp_countrycode}  ${WhatsApp_num}  ${telegram_countrycode}  ${telegram_num}  ${userRoles}   &{kwargs}
    ${whatsAppNum}=  Create Dictionary  countryCode=${whatsApp_countrycode}  number=${WhatsApp_num}
    ${telegramNum}=  Create Dictionary  countryCode=${telegram_countrycode}  number=${telegram_num}
    ${data}=  Create Dictionary  firstName=${fname}  lastName=${lname}  dob=${dob}  gender=${gender}  email=${email}  userType=${user_type}  pincode=${pincode}  countryCode=${countryCode}  mobileNo=${mob_no}  deptId=${dept_id}  subdomain=${sub_domain}  admin=${admin}  whatsAppNum=${whatsAppNum}  telegramNum=${telegramNum}  userRoles=${userRoles}
    FOR  ${key}  ${value}  IN  &{kwargs}
            Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/user    data=${data}  expected_status=any
    [Return]  ${resp}

Update User With Roles And Scope
    [Arguments]  ${id}  ${fname}  ${lname}  ${dob}  ${gender}  ${email}  ${user_type}  ${pincode}  ${countryCode}  ${mob_no}  ${dept_id}  ${sub_domain}  ${admin}  ${whatsApp_countrycode}  ${WhatsApp_num}  ${telegram_countrycode}  ${telegram_num}   ${userRoles}   &{kwargs}
    ${whatsAppNum}=   Create Dictionary  countryCode=${whatsApp_countrycode}  number=${WhatsApp_num}
    ${telegramNum}=  Create Dictionary  countryCode=${telegram_countrycode}  number=${telegram_num}
    ${data}=  Create Dictionary  firstName=${fname}  lastName=${lname}  dob=${dob}  gender=${gender}  email=${email}  userType=${user_type}  pincode=${pincode}  countryCode=${countryCode}  mobileNo=${mob_no}  deptId=${dept_id}  subdomain=${sub_domain}  admin=${admin}  whatsAppNum=${whatsAppNum}  telegramNum=${telegramNum}  userRoles=${userRoles}
    FOR  ${key}  ${value}  IN  &{kwargs}
            Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/user/${id}   data=${data}  expected_status=any
    [Return]  ${resp}
    
Update Managers To user
    [Arguments]    ${user_id}   ${manager_ids}
    ${data}=  json.dumps  ${manager_ids}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/user/${user_id}/updateManager  data=${data}  expected_status=any
    [Return]  ${resp}

Get Manager List of User
    [Arguments]    ${user_id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/user/${user_id}/getManager    expected_status=any
    [Return]  ${resp}


Get User Scope By Id
    [Arguments]    ${user_id}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/user/${user_id}/roles    expected_status=any
    [Return]  ${resp}


Append User Scope
    [Arguments]  ${feature}  ${user_ids}  ${userRoles} 
    ${data}=  Create Dictionary  userIds=${user_ids}   roles=${userRoles} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/user/${feature}/appendScope    data=${data}  expected_status=any
    [Return]  ${resp}


Replace User Scope
    [Arguments]  ${feature}  ${user_ids}  ${userRoles} 
    ${data}=  Create Dictionary  userIds=${user_ids}   roles=${userRoles} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/user/${feature}/replaceScope    data=${data}  expected_status=any
    [Return]  ${resp}


Get Team Scope By Id
    [Arguments]    ${teamId}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/user/team/${teamId}/roles    expected_status=any
    [Return]  ${resp}


Append Team Scope
    [Arguments]  ${feature}  ${team_ids}  ${userRoles} 
    ${data}=  Create Dictionary  teamIds=${team_ids}   roles=${userRoles} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/user/${feature}/team/appendScope    data=${data}  expected_status=any
    [Return]  ${resp}

Replace Team Scope
    [Arguments]  ${feature}  ${team_ids}  ${userRoles} 
    ${data}=  Create Dictionary  teamIds=${team_ids}   roles=${userRoles} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/user/${feature}/team/replaceScope    data=${data}  expected_status=any
    [Return]  ${resp}

Enable Disable RBAC
   [Arguments]  ${status}  
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  provider/account/settings/rbac/${status}  expected_status=any
   [Return]  ${resp}

Create Role
    [Arguments]     ${roleName}    ${description}    ${featureName}    ${capabilityList}

    ${data}=    Create Dictionary      roleName=${roleName}    description=${description}    featureName=${featureName}    capabilityList=${capabilityList}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  provider/accessscope/role    data=${data}   expected_status=any
    [Return]  ${resp}

Get roles
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/accessscope/roles  expected_status=any
    [Return]  ${resp}

Get roles by id
    [Arguments]    ${id}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/accessscope/role/${id}  expected_status=any
    [Return]  ${resp}

Update Role
    [Arguments]      ${id}       ${roleName}    ${description}    ${featureName}    ${capabilityList}

    ${data}=    Create Dictionary      roleName=${roleName}    description=${description}    featureName=${featureName}    capabilityList=${capabilityList}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/accessscope/role/${id}    data=${data}   expected_status=any
    [Return]  ${resp}

Update role status
    [Arguments]        ${id}    ${status}   

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/accessscope/role/${id}/${status}    expected_status=any
    [Return]  ${resp}

Restore roles
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/accessscope/roles/restoreDefaults    expected_status=any
    [Return]  ${resp}

Restore role by id
    [Arguments]        ${roleId}
    
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/accessscope/roles/restoreDefaults/${roleId}    expected_status=any
    [Return]  ${resp}

Enable Disable CDL RBAC
    [Arguments]  ${status}  
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  provider/account/settings/cdlrbac/${status}  expected_status=any
    [Return]  ${resp}


#    CDL Setings


Create and Update Account level cdl setting

    [Arguments]    ${autoApproval}    ${autoApprovalUptoAmount}    ${districtWiseRestriction}    ${status}    ${downpaymentRequired}
    ...    ${salesOfficerVerificationRequired}    ${branchManagerVerificationRequired}     &{kwargs}
    ${data}=  Create Dictionary    autoApproval=${autoApproval}    autoApprovalUptoAmount=${autoApprovalUptoAmount}    districtWiseRestriction=${districtWiseRestriction}    status=${status}
    ...    downpaymentRequired=${downpaymentRequired}    salesOfficerVerificationRequired=${salesOfficerVerificationRequired}    branchManagerVerificationRequired=${branchManagerVerificationRequired}   
    FOR  ${key}  ${value}  IN  &{kwargs}
            Set To Dictionary  ${data}   ${key}=${value}
    END
    
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw     /provider/cdlsetting/account   data=${data}   expected_status=any 
    [Return]  ${resp}

Get account level cdl setting

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/cdlsetting/account   expected_status=any
    [Return]  ${resp}

Get List of CDL Settings by filter

    [Arguments]    &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/cdlsetting  params=${param}  expected_status=any
    [Return]  ${resp}

Get Count of CDL Settings by filter

    [Arguments]    &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/cdlsetting/count  params=${param}  expected_status=any
    [Return]  ${resp}

Create BranchMaster

    [Arguments]    ${branchCode}    ${branchName}    ${Location}    ${status}

    ${Location}=       Create Dictionary    id=${Location}
    ${data}=    Create Dictionary    branchCode=${branchCode}    branchName=${branchName}    location=${Location}    status=${status}
    ${data}=    json.dumps    ${data}

    Check And Create YNW Session
    ${resp}=    POST On Session    ynw     /provider/branchmaster   data=${data}   expected_status=any 
    [Return]  ${resp}

Update BranchMaster

    [Arguments]    ${branchId}    ${branchCode}    ${branchName}    ${Location}    ${status}

    ${Location}=       Create Dictionary    id=${Location}
    ${data}=    Create Dictionary    branchCode=${branchCode}    branchName=${branchName}    location=${Location}    status=${status}
    ${data}=    json.dumps    ${data}

    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw     /provider/branchmaster/${branchId}   data=${data}   expected_status=any 
    [Return]  ${resp}

Get BranchMaster

    [Arguments]    &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/branchmaster  params=${param}  expected_status=any
    [Return]  ${resp}

Get BranchMaster Count

    [Arguments]    &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/branchmaster/count  params=${param}  expected_status=any
    [Return]  ${resp}

Get Branch By Id

    [Arguments]    ${branchId}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/branchmaster/${branchId}  expected_status=any
    [Return]  ${resp}

Change Branch Status
    
    [Arguments]    ${branchid}    ${activeStatus}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/branchmaster/${branchId}/status/${activeStatus}  expected_status=any
    [Return]  ${resp}

Enable Disable Branch

    [Arguments]    ${status}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/account/settings/branchMaster/${status}  expected_status=any
    [Return]  ${resp}
        
Enable Disable CDL

    [Arguments]    ${status}   
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/account/settings/cdl/${status}    expected_status=any
    [Return]  ${resp}

Get Draft LoanApplication

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/loanapplication/draft  expected_status=any
    [Return]  ${resp}

sales officer verification

    [Arguments]    ${partnerUid}   ${required}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/partner/${partnerUid}/salesofficerverification/${required}    expected_status=any
    [Return]  ${resp}


Partner Loan Application Action Required
   
    [Arguments]    ${loanApplicationUid}      ${spinternalstatus} 

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/loanapplication/${loanApplicationUid}/actionrequired/spinternalstatus/${spinternalstatus}  expected_status=any
    [Return]  ${resp}

Get Loan Application ProductCategory

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/loanproduct/category  expected_status=any
    [Return]  ${resp}

Get Loan Application ProductSubCategory

    [Arguments]    ${loanProductCategoryId}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/loanproduct/category/${loanProductCategoryId}/subcategory  expected_status=any
    [Return]  ${resp}


Loan Application Operational Approval
   
    [Arguments]    ${loanApplicationUid}  ${note}

    ${data}=    Create Dictionary    note=${note}   
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/loanapplication/${loanApplicationUid}/operationalapproval  data=${data}  expected_status=any
    [Return]  ${resp}

Generate Otp for Guarantor Phone

    [Arguments]    ${guarantor_no}  ${countrycode}

    ${data}=    Create Dictionary   countryCode=${countrycode}  number=${guarantor_no}   
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /provider/loanapplication/generate/guarantor/phone  data=${data}  expected_status=any
    [Return]  ${resp}

Verify Otp for Guarantor Phone

    [Arguments]    ${guarantor_no}  ${uid}   ${fname}  ${lname}  ${countrycode}  ${loan_applicatnkyclist}

    ${otp}=   verify accnt  ${guarantor_no}  ${purpose}

    ${customer_details}=  Create Dictionary   firstName=${fname}  lastName=${lname}  phoneNo=${guarantor_no}  countryCode=${countrycode}

    ${data}=    Create Dictionary   uid=${uid}  customer=${customer_details}  loanApplicationKycList=${loan_applicatnkyclist}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /provider/loanapplication/verify/${otp}/guarantor/phone  data=${data}  expected_status=any
    [Return]  ${resp}

salesofficer Approval

    [Arguments]    ${uid}   ${id}    ${noOfEmi}    ${noOfAdvanceEmi}    ${emiDueDay}    &{kwargs}

    ${loanScheme}=       Create Dictionary    id=${id}
    ${data}=    Create Dictionary    loanScheme=${loanScheme}    noOfEmi=${noOfEmi}    noOfAdvanceEmi=${noOfAdvanceEmi}    emiDueDay=${emiDueDay}
    FOR  ${key}  ${value}  IN  &{kwargs}
            Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}

    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw     /provider/loanapplication/${uid}/approval   data=${data}   expected_status=any 
    [Return]  ${resp}

Partner Accepted

    [Arguments]    ${loanApplicationUid}    ${owner}    ${fileName}    ${fileSize}    ${caption}    ${fileType}    ${action}    ${type}    ${order}

    ${partnerAcceptanceAttachments}=  Create List
    ${Attachment}=    Create Dictionary    owner=${owner}    fileName=${fileName}    fileSize=${fileSize}    caption=${caption}    fileType=${fileType}    action=${action}    type=${type}    order=${order}
    Append To List  ${partnerAcceptanceAttachments}  ${Attachment}
    
    ${data}=    Create Dictionary   uid=${loanApplicationUid}   partnerAcceptanceAttachments=${partnerAcceptanceAttachments}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/loanapplication/partner/acceptance  data=${data}  expected_status=any
    [Return]  ${resp}


Get Avaliable Tenures

    [Arguments]    ${lid}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/loan/scheme/${lid}/availabletenures  expected_status=any
    [Return]  ${resp}

Get Avaliable Scheme

    [Arguments]    ${uid}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/loanapplication/${uid}/availableschemes  expected_status=any
    [Return]  ${resp}

Assigning Branches to Users

    [Arguments]    ${userids}    @{branches}

    ${data}=  Create Dictionary    userIds=${userids}    branchIds=${branches}
    ${data}=    json.dumps    ${data}

    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw     /provider/user/updateBranchMaster   data=${data}   expected_status=any 
    [Return]  ${resp}

Get Loan EMI Details
    
    [Arguments]    ${loanApplicationUid}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/loanapplication/${loanApplicationUid}/loanemi  expected_status=any
    [Return]  ${resp}

Get Address Relation Type
    
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/loanapplication/addressrelationtype  expected_status=any
    [Return]  ${resp}

Account Aggregation
    
    [Arguments]    ${loanApplicationUid}    ${kycId}

    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /provider/loanapplication/accountaggregate/${loanApplicationUid}/${kycId}  expected_status=any
    [Return]  ${resp}

Get Account Aggregation
    
    [Arguments]    ${loanApplicationUid}    ${kycId}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/loanapplication/accountaggregatestatus/${loanApplicationUid}/${kycId}  expected_status=any
    [Return]  ${resp}

Generate CDL Dropdowns
    
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/loanapplication/csms/settings  expected_status=any
    [Return]  ${resp}

Cancel Loan Application

    [Arguments]    ${loanApplicationUid}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/loanapplication/${loanApplicationUid}/cancel    expected_status=any
    [Return]  ${resp}


Generate Credit Score-MAFIL Score

    [Arguments]    ${loanApplicationUid}    ${kycId}

    ${data}=    Create Dictionary   loanApplicationUid=${loanApplicationUid}   loanApplicationKycId=${kycId}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/loanapplication/csms/generatescore    data=${data}  expected_status=any
    [Return]  ${resp}

Add General Notes/Remarks
    
    [Arguments]    ${loanApplicationUid}   ${note}

    ${data}=   Create Dictionary   note=${note}
    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/loanapplication/${loanApplicationUid}/note    data=${data}  expected_status=any
    [Return]  ${resp}


# .....CDL Communication .......

Send Message

    [Arguments]    ${user}  ${commMsg}  ${sender_id}  ${senderUserType}  ${receiver_id}  ${receiverUserType}  ${messageType}  @{attachmentList}

    ${data}=  Create Dictionary    communicationMessage=${commMsg}  sender=${sender_id}  senderUserType=${senderUserType}
    ...    receiver=${receiver_id}   receiverUserType=${receiverUserType}  messageType=${messageType}  attachmentList=${attachmentList}
    ${data}=    json.dumps    ${data}

    Check And Create YNW Session
    ${resp}=    POST On Session    ynw     /${user}/communicate/communicationDetail   data=${data}   expected_status=any 
    [Return]  ${resp}


Get Communication Between Two UserTypes
    
    [Arguments]    ${user}  ${userId1}  ${userId2}  ${userType}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   ${user}/communicate/${userId1}/communicationDetail/${userId2}/${userType}   expected_status=any
    [Return]  ${resp}


Get Full Communication Of User
    
    [Arguments]    ${user}  ${userId}  

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   ${user}/communicate/${userId}   expected_status=any
    [Return]  ${resp}

Change Read Status

    [Arguments]    ${user}  ${sender_id}  ${senderUserType}  ${receiver_id}  ${receiverUserType}  ${message_ids}   ${accid}=0 
    
    ${pro_params}=  Create Dictionary  account=${accid}
    ${data}=  Create Dictionary     sender=${sender_id}  senderUserType=${senderUserType}
    ...    receiver=${receiver_id}   receiverUserType=${receiverUserType}  messageIds=${message_ids}  
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw     /${user}/communicate/communicationDetailToRead   data=${data}   params=${pro_params}  expected_status=any 
    [Return]  ${resp}


# ...... Item Grouping......

Enable Disable Item Group  

   [Arguments]   ${status}
   Check And Create YNW Session
   ${resp}=    PUT On Session    ynw  /provider/account/settings/itemGroup/${status}  expected_status=any 
   [Return]  ${resp}  

Create Item Group

    [Arguments]    ${groupName}    ${groupDesc}   
    ${data}=    Create Dictionary    groupName=${groupName}    groupDesc=${groupDesc}  
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /provider/items/itemGroup   data=${data}  expected_status=any
    [Return]  ${resp}

Update Item Group

    [Arguments]    ${ItemGroupId}  ${groupName}    ${groupDesc}   
    ${data}=    Create Dictionary    groupName=${groupName}    groupDesc=${groupDesc}  
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/items/itemGroup/${ItemGroupId}   data=${data}  expected_status=any
    [Return]  ${resp}

Get Item Group
    
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/items/itemGroup   expected_status=any
    [Return]  ${resp}

Get Item Group By Id
    
    [Arguments]    ${ItemGroupId}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/items/itemGroup/${ItemGroupId}   expected_status=any
    [Return]  ${resp}


Delete Item Group By Id
    
    [Arguments]    ${ItemGroupId}
    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw   /provider/items/itemGroup/${ItemGroupId}   expected_status=any
    [Return]  ${resp}


Delete Item Group Image 
    
    [Arguments]    ${ItemGroupId}  ${imgname}
    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw   /provider/items/itemGroup/${ItemGroupId}/image/${imgname}   expected_status=any
    [Return]  ${resp}


Add Items To Item Group

    [Arguments]   ${ItemGroupId}   ${Items}
    ${Items}=  json.dumps  ${Items}
    Check And Create YNW Session 
    ${resp}=  PUT On Session  ynw  /provider/items/group/${ItemGroupId}  data=${Items}  expected_status=any
    [Return]  ${resp}


Delete Items From Item Group

	[Arguments]    ${ItemGroupId}   ${Items}
    ${Items}=  json.dumps  ${Items}
	Check And Create YNW Session
    ${resp}=   DELETE On Session  ynw  /provider/items/group/${ItemGroupId}  data=${Items}  expected_status=any
    [Return]  ${resp}


Add Items To Multiple Item Group

    [Arguments]    ${itemId}   ${ItemGroupIds}
    ${ItemGroups}=  json.dumps  ${ItemGroupIds}
    Check And Create YNW Session 
    ${resp}=  PUT On Session  ynw  /provider/items/group/item/${itemId}  data=${ItemGroups}  expected_status=any
    [Return]  ${resp}


Delete Items From Multiple Item Group

	[Arguments]     ${itemId}   ${ItemGroupIds} 
    ${ItemGroups}=  json.dumps  ${ItemGroupIds}
	Check And Create YNW Session
    ${resp}=   DELETE On Session  ynw  /provider/items/group/item/${itemId}  data=${ItemGroups}  expected_status=any
    [Return]  ${resp}



Loan Application Branchapproval

    [Arguments]    ${loanApplicationUid}    ${note}

    ${data}=  Create Dictionary    note=${note}
    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/loanapplication/${loanApplicationUid}/branchapproval    data=${data}    expected_status=any
    [Return]  ${resp}



#  Business Logo And Department Icon

Add Business Logo

    [Arguments]    ${owner}    ${fileName}    ${fileSize}    ${action}    ${caption}    ${fileType}    ${order}

    ${AttachmentsUpload}=  Create List
    ${Attachment}=    Create Dictionary    owner=${owner}    fileName=${fileName}    fileSize=${fileSize}    action=${action}    caption=${caption}    fileType=${fileType}    order=${order}
    Append To List  ${AttachmentsUpload}  ${Attachment}
    
    ${data}=    json.dumps    ${AttachmentsUpload}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /provider/upload/businessLogo  data=${data}  expected_status=any
    [Return]  ${resp}


Remove Business Logo

    [Arguments]    ${owner}    ${fileName}    ${fileSize}    ${action}    ${caption}    ${fileType}    ${order}

    ${AttachmentsUpload}=  Create List
    ${Attachment}=    Create Dictionary    owner=${owner}    fileName=${fileName}    fileSize=${fileSize}    action=${action}    caption=${caption}    fileType=${fileType}    order=${order}
    Append To List  ${AttachmentsUpload}  ${Attachment}
    
    ${data}=    json.dumps    ${AttachmentsUpload}
    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw   /provider/remove/businessLogo  data=${data}  expected_status=any
    [Return]  ${resp}


Get Business Logo

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/businessLogo  expected_status=any
    [Return]  ${resp}


Add Department Icon

    [Arguments]    ${deptid}    ${owner}    ${fileName}    ${fileSize}    ${action}    ${caption}    ${fileType}    ${order}

    ${AttachmentsUpload}=  Create List
    ${Attachment}=    Create Dictionary    owner=${owner}    fileName=${fileName}    fileSize=${fileSize}    action=${action}    caption=${caption}    fileType=${fileType}    order=${order}
    Append To List  ${AttachmentsUpload}  ${Attachment}
    
    ${data}=    json.dumps    ${AttachmentsUpload}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /provider/departments/upload/icon/${deptid}  data=${data}  expected_status=any
    [Return]  ${resp}


Remove Department Icon

    [Arguments]    ${deptid}    ${owner}    ${fileName}    ${fileSize}    ${action}    ${caption}    ${fileType}    ${order}

    ${AttachmentsUpload}=  Create List
    ${Attachment}=    Create Dictionary    owner=${owner}    fileName=${fileName}    fileSize=${fileSize}    action=${action}    caption=${caption}    fileType=${fileType}    order=${order}
    Append To List  ${AttachmentsUpload}  ${Attachment}
    
    ${data}=    json.dumps    ${AttachmentsUpload}
    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw   /provider/departments/remove/icon/${deptid}  data=${data}  expected_status=any
    [Return]  ${resp}



Get Department Icon

    [Arguments]    ${deptid}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   url=/provider/departments/${deptid}    expected_status=any
    [Return]  ${resp}


#   MFA Login

Multi Factor Authentication

    [Arguments]    ${toggle}  

    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw     /provider/account/settings/mfa/${toggle}       expected_status=any 
    [Return]  ${resp}


Multi Factor Authentication ProviderLogin
    [Arguments]    ${usname}    ${cc}  ${passwrd}    ${bool}      &{kwargs}
    
    # ${otp}=   verify accnt  ${usname}  ${purpose}

    ${data}=  Create Dictionary  countryCode=${cc}  loginId=${usname}    password=${passwrd}    multiFactorAuthenticationLogin=${bool}    
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    
    ${resp}=    POST On Session    ynw    /provider/login    data=${data}  expected_status=any
    [Return]  ${resp}

# ....Jaldee Video call...


Get Video Call Minutes 

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/account/settings/videoCallMinutes  expected_status=any
    [Return]  ${resp}


Create video Call Meeting Link

    [Arguments]  ${prov_cons_id}  
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/video/adhoc/start/consumer/${prov_cons_id}     expected_status=any
    Log  ${resp.content}
    [Return]  ${resp}


Get video Link Status 

    [Arguments]  ${meeting_id}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/video/adhoc/${meeting_id}/link/status     expected_status=any
    Log  ${resp.content}
    [Return]  ${resp}


Get video Status 

    [Arguments]  ${meeting_id}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/video/adhoc/${meeting_id}/status     expected_status=any
    Log  ${resp.content}
    [Return]  ${resp}

Update Virtual Calling Modes

    [Arguments]  ${virtual_callingmode} 

    ${data}=  Create Dictionary   virtualCallingModes=${virtual_callingmode}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/account/settings/virtualCallingModes   data=${data}  expected_status=any
    Log  ${resp.content}
    [Return]  ${resp}

Provider Video Call ready

    [Arguments]  ${uuid}     ${recordingFlag}

    ${data}=  Create Dictionary   uuid=${uuid}    recordingFlag=${recordingFlag}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/waitlist/videocall/ready   data=${data}  expected_status=any
    Log  ${resp.content}
    [Return]  ${resp}


#.........REST API for Uploading file to temporary location............


upload file to temporary location

    [Arguments]    ${action}    ${owner}    ${ownerType}    ${ownerName}    ${fileName}    ${fileSize}    ${caption}    ${fileType}    ${uid}    ${order}

    ${file}=  Create Dictionary  action=${action}    owner=${owner}    ownerType=${ownerType}    ownerName=${ownerName}    fileName=${fileName}    fileSize=${fileSize}    caption=${caption}    fileType=${fileType}    uid=${uid}    order=${order}
    ${data}=  Create List  ${file}
    ${data}=    json.dumps    ${data}

    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/fileShare/upload   data=${data}  expected_status=any
    Log  ${resp.content}
    [Return]  ${resp}


change status of the uploaded file

    [Arguments]    ${status}    ${id}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  provider/fileShare/upload/${status}/${id}  expected_status=any
    Log  ${resp.content}
    [Return]  ${resp}


# .....Jaldee Homeo....


Apply Labels To Service

    [Arguments]    ${service_id}    ${labels_ids}    

    ${data}=    json.dumps    ${labels_ids}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/services/applyLabel/${service_id}    data=${data}  expected_status=any
    Log  ${resp.content}
    [Return]  ${resp}

# .....Employee login....

EmployeeLogin
    [Arguments]    ${accountId}  ${loginIdType}       ${loginId}  ${password}  
    ${log}=  Create Dictionary  accountId=${accountId}   loginIdType=${loginIdType}    loginId=${loginId}    password=${password}
    ${log}=    json.dumps    ${log}   
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw    /provider/login    data=${log}  expected_status=any    headers=${headers}
    [Return]  ${resp}



#------------  IVR  ------------------


IVR_Config_Json

    [Arguments]    @{dict1}
    [Return]  ${dict1}

Create_IVR_Settings

    [Arguments]    ${account}    ${callPriority}    ${callWaitingTime}    ${serv_id}    ${token}    ${secretKey}    ${apiKey}    ${companyId}    ${publicId}    ${languageResetCount}    ${ivrConfigRule}   ${isQnrManditory}   ${providerLanguageUpdatable}
    ${services}=  Create List    ${serv_id}
    ${data}=    Create Dictionary    account=${account}    callPriority=${callPriority}    callWaitingTime=${callWaitingTime}    services=${services}    token=${token}    secretKey=${secretKey}    apiKey=${apiKey}    companyId=${companyId}    publicId=${publicId}    languageResetCount=${languageResetCount}      isQnrManditory=${isQnrManditory}    providerLanguageUpdatable=${providerLanguageUpdatable}   ivrConfigRule=${ivrConfigRule}
    ${data}=    json.dumps    ${data} 
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw    url=/provider/ivr/settings    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

enable and disable IVR

    [Arguments]    ${status}
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw     /provider/account/settings/ivr/${status}    expected_status=any    headers=${headers}
    [Return]    ${resp}

Incall IVR

    [Arguments]    ${account}    ${id}    ${uid}    ${reference_id}    ${company_id}    ${clid_raw}    ${clid}    ${rdnis}    ${call_state}    ${event}    ${status}    ${users}    ${created}    ${call_time}    ${public_ivr_id}    ${client_ref_id}    ${job_id}
    ${data}=  Create Dictionary    id=${id}    uid=${uid}    reference_id=${reference_id}    company_id=${company_id}    clid_raw=${clid_raw}    clid=${clid}    rdnis=${rdnis}    call_state=${call_state}    event=${event}    status=${status}    users=${users}    created=${created}    call_time=${call_time}    public_ivr_id=${public_ivr_id}    client_ref_id=${client_ref_id}    job_id=${job_id}
    ${data}=    json.dumps    ${data} 
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw    url=/provider/ivr/incall?account=${account}    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

innode IVR 

    [Arguments]    ${account}    ${uid}    ${node_id}    ${timestamp}    ${clid}    ${input}
    ${data}=  Create Dictionary    uid=${uid}    node_id=${node_id}    timestamp=${timestamp}    clid=${clid}    input=${input}
    ${data}=    json.dumps    ${data} 
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw    url=/provider/ivr/innode?account=${account}    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Aftercall IVR

    [Arguments]    ${account}    ${call_log_id}    ${call_source}    ${comp_id}    ${callers_num_raw}    ${caller_contact_name}    ${callers_num}    ${cc}    ${loc}    ${timestamp}    ${start_time}    ${timestamp_milli}    ${diff_et_st}    ${et}    ${dur_hr}    ${dur_min}    ${log_type}    ${event_type}    ${file_name}    ${file_link}    ${noti}    ${status_call}    ${dept_name}    ${dept_id}    ${_pm}    ${_cn}    ${_ld}    ${anony_usr}    ${Refr_id}    ${_ji}    ${public_ivr}    ${clind_rfe_id}
    ${data}=  Create Dictionary  _ai=${call_log_id}  _so=${call_source}  _ci=${comp_id}  _cr=${callers_num_raw}  _cm=${caller_contact_name}    _cl=${callers_num}  _cy=${cc}  _se=${loc}  _ts=${timestamp}  _st=${start_time}  _ms=${timestamp_milli}  _ss=${diff_et_st}  _et=${et}  _dr=${dur_hr}  _drm=${dur_min}  _ty=${log_type}  _ev=${event_type}  _fn=${file_name}  _fu=${file_link}  _ns=${noti}  _su=${status_call}  _dn=${dept_name}    _di=${dept_id}    _pm=${_pm}    _cn=${_cn}    _ld=${_ld}  _an=${anony_usr}  _ri=${Refr_id}    _ji=${_ji}    _ivid=${public_ivr}    _cri=${clind_rfe_id} 
    ${data}=    json.dumps    ${data} 
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw    url=/provider/ivr?account=${account}    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Get Ivr Details By Filter

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/ivr  expected_status=any
    [Return]  ${resp}

create a call back

    [Arguments]    ${uid}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/ivr/callback/${uid}  expected_status=any
    [Return]  ${resp}

Get Ivr By Uid

    [Arguments]    ${uid}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/ivr/${uid}  expected_status=any
    [Return]  ${resp}

Get IVR Count

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/ivr/count  expected_status=any
    [Return]  ${resp}

Assign IVR User

    [Arguments]    ${uid}    ${type}    ${id}
    ${data}=    Create Dictionary    uid=${uid}    userType=${type}    userId=${id}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/ivr/assign    data=${data}  expected_status=any
    [Return]  ${resp}

Get Ivr By reference id

    [Arguments]    ${Refr_id}
    Check And Create YNW Session
    ${resp}=    Get On Session    ynw   /provider/ivr/reference/${Refr_id}     expected_status=any
    [Return]    ${resp}

Unassign IVR User

    [Arguments]    ${uid}    ${type}    ${id}
    ${data}=    Create Dictionary    uid=${uid}    userType=${type}    userId=${id}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/ivr/unassign    data=${data}  expected_status=any
    [Return]  ${resp}

Update User Availability

    [Arguments]    ${userId}    ${available}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/ivr/users/${userId}/${available}  expected_status=any
    [Return]  ${resp}

Get IVR Setting
    
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/ivr/settings  expected_status=any
    [Return]  ${resp}

Update IVR Settings

    [Arguments]    ${account}    ${callPriority}    ${callWaitingTime}    ${serv_id}    ${token}    ${secretKey}    ${apiKey}    ${companyId}    ${publicId}    ${languageResetCount}    ${ivrConfigRule}
    ${services}=  Create List    ${serv_id}
    ${data}=    Create Dictionary    account=${account}    callPriority=${callPriority}    callWaitingTime=${callWaitingTime}    services=${services}    token=${token}    secretKey=${secretKey}    apiKey=${apiKey}    companyId=${companyId}    publicId=${publicId}    languageResetCount=${languageResetCount}    ivrConfigRule=${ivrConfigRule}
    ${data}=    json.dumps    ${data} 
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    url=/provider/ivr/settings?account=${account}    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

IVR Request Call Back Token

    [Arguments]    ${uid}
    Check And Create YNW Session
    ${resp}=    PUT On Session  ynw  /provider/ivr/request/callback/${uid}  expected_status=any
    [Return]  ${resp}

IVR Remove Call Back Request

    [Arguments]    ${uid}
    Check And Create YNW Session
    ${resp}=    PUT On Session  ynw  /provider/ivr/remove/callback/${uid}  expected_status=any
    [Return]  ${resp}

Update IVR Call Status

    [Arguments]    ${uid}    ${status}
    Check And Create YNW Session
    ${resp}=    PUT On Session  ynw  /provider/ivr/status/${uid}/${status}  expected_status=any
    [Return]  ${resp}

Get IVR Graph Details

    [Arguments]    ${category}    ${startDate}    ${endDate}
    ${data}=    Create Dictionary    category=${category}    startDate=${startDate}   endDate=${endDate}    
    ${data}=    json.dumps    ${data} 
    Check And Create YNW Session
    ${resp}=    PUT On Session  ynw  /provider/ivr/graph  data=${data}  expected_status=any
    [Return]  ${resp}

Delete All IVR Records

    Check And Create YNW Session
    ${resp}=    DELETE On Session  ynw  /provider/ivr/users  expected_status=any
    [Return]  ${resp}

Get IVR Users

    Check And Create YNW Session
    ${resp}=    GET On Session  ynw  /provider/ivr/users  expected_status=any
    [Return]  ${resp}

Get IVR Before The Questionnaire

    [Arguments]    ${channel}
    Check And Create YNW Session
    ${resp}=    GET On Session  ynw  /provider/questionnaire/ivr/call/${channel}  expected_status=any
    [Return]  ${resp}

Add Notes To IVR

    [Arguments]    ${uuid}    ${note}    ${attachments}
    
    ${attachments}=  Create List  ${attachments}
    ${data}=    Create Dictionary    note=${note}    attachments=${attachments}
    ${data}=    json.dumps    ${data} 
    Check And Create YNW Session
    ${resp}=    POST On Session  ynw  /provider/ivr/notes/${uuid}    data=${data}   expected_status=any
    [Return]  ${resp}

Upload QNR File to Temp Location

    [Arguments]    ${proid}    ${qnrid}    ${caption}    ${mimetype}    ${url}    ${size}    ${labelName}    

    ${headers2}=     Create Dictionary    Content-Type=multipart/form-data   # Authorization=browser 
    ${file2}=  Create List
    ${file1}=    Create Dictionary     proId=${proid}    questionnaireId=${qnrid}    
    ${file1}=    json.dumps    ${file1}
    ${data2}=    Create Dictionary     caption=${caption}    mimeType=${mimetype}    url=${url}    size=${size}    labelName=${labelName}
    Append To List  ${file2}  ${data2}
    ${file2}=    json.dumps    ${file2}
    # ${files}    Evaluate  {'requests': ('None', ${file1} , 'application/json'), 'files': ('None', ${file2})}
    ${files}    Create Dictionary  requests  ${file1}  files  ${file2}
    Check And Create YNW Session
    ${resp}=    POST On Session  ynw  /provider/questionnaire/upload/file     files=${files}   expected_status=any    headers=${headers2}
    [Return]  ${resp}

Get IVR User Details

    [Arguments]    ${userType}    ${userId}

    Check And Create YNW Session
    ${resp}=    GET On Session  ynw  /provider/ivr/user/settings/${userType}/${userId}   expected_status=any
    [Return]  ${resp}

Delete User Details

    [Arguments]     ${userId}

    Check And Create YNW Session
    ${resp}=    DELETE On Session  ynw  /provider/ivr/users/${userId}   expected_status=any
    [Return]  ${resp}

Get All IVR User Details

    Check And Create YNW Session
    ${resp}=    GET On Session  ynw  /provider/ivr/user/settings   expected_status=any
    [Return]  ${resp}

Get IVR User Avaliability

    Check And Create YNW Session
    ${resp}=    GET On Session  ynw  /provider/ivr/user/availability   expected_status=any
    [Return]  ${resp}

Submit IVR Qnr

    [Arguments]    ${uuid}    ${data}

    Check And Create YNW Session
    ${resp}=    POST On Session  ynw  /provider/ivr/questionnaire/submit/${uuid}    data=${data}       expected_status=any
    [Return]  ${resp}

Get All IVR Qnr

    [Arguments]    ${uuid}

    Check And Create YNW Session
    ${resp}=    GET On Session  ynw  /provider/ivr/questionnaire/${uuid}   expected_status=any
    [Return]  ${resp}

IVR Change Release Status Of Questionnaire

    [Arguments]    ${releaseStatus}  ${uuid}  ${id}

    Check And Create YNW Session
    ${resp}=    PUT On Session  ynw  provider/ivr/questionnaire/change/${releaseStatus}/${uuid}/${id}   expected_status=any
    [Return]  ${resp}

Resubmit IVR Qnr

    [Arguments]    ${uuid}    ${data}

    Check And Create YNW Session
    ${resp}=    POST On Session  ynw  /provider/ivr/questionnaire/resubmit/${uuid}    data=${data}       expected_status=any
    [Return]  ${resp}

Provider Schedule
    [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${scheduleState}  ${providerId}
    ${bs}=  TimeSpec  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}
    ${data}=  Create Dictionary  name=${name}  scheduleTime=${bs}  scheduleState=${scheduleState}  providerId=${providerId}
    [Return]  ${data}

Create Provider Schedule

    [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${scheduleState}  ${providerId}
    
    ${data}=  Provider Schedule  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${scheduleState}  ${providerId}
    Check And Create YNW Session
    ${data}=  json.dumps  ${data}
    ${resp}=  POST On Session  ynw  /provider/schedule  data=${data}  expected_status=any
    [Return]  ${resp}

Get all schedules of an account 

    Check And Create YNW Session
    ${resp}=    GET On Session  ynw  /provider/schedule   expected_status=any
    [Return]  ${resp}

Update Provider Schedule

    [Arguments]  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${scheduleState}  ${providerId}  &{kwargs}

    ${data}=  Provider Schedule  ${name}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${scheduleState}  ${providerId}  
    Check And Create YNW Session
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END 
    ${data}=  json.dumps  ${data}
    ${resp}=  PUT On Session  ynw  /provider/schedule  data=${data}  expected_status=any
    [Return]  ${resp}

Get Scheduled Using Id

    [Arguments]    ${schid}

    Check And Create YNW Session
    ${resp}=    GET On Session  ynw  /provider/schedule/${schid}   expected_status=any
    [Return]  ${resp}

Enable And Disable A Schedule

    [Arguments]    ${scheduleState}  ${id}

    Check And Create YNW Session
    ${resp}=    PUT On Session  ynw  /provider/schedule/${scheduleState}/${id}   expected_status=any
    [Return]  ${resp}

Get User-Specific Schedules 

    [Arguments]    ${userid}

    Check And Create YNW Session
    ${resp}=    GET On Session  ynw  /provider/schedule/user/${userid}   expected_status=any
    [Return]  ${resp}

IVR Update User Language

    [Arguments]    ${userid}    ${languages}
    
    ${languages}=  Create List  ${languages}
    ${data}=  Create Dictionary  languages=${languages}
    ${data}=    json.dumps    ${data} 
    Check And Create YNW Session
    ${resp}=    PUT On Session  ynw  /provider/ivr/users/${userId}    data=${data}   expected_status=any
    [Return]  ${resp}

Get Available Providers In A Time Range

    [Arguments]    ${sDate}    ${eDate}

    ${data}=  Create Dictionary  startDate=${sDate}    endDate=${eDate}
    ${data}=    json.dumps    ${data} 
    Check And Create YNW Session
    ${resp}=    PUT On Session  ynw  /provider/schedule/availableUser    data=${data}   expected_status=any
    [Return]  ${resp}


# ........ Membership Service ............


Create Membership Service 

    [Arguments]    ${description}    ${name}    ${displayName}    ${effectiveFrom}    ${effectiveTo}    ${approvalType}    ${allowLogin}    ${serviceStatus}

    ${data}=  Create Dictionary    description=${description}    name=${name}    displayName=${displayName}    effectiveFrom=${effectiveFrom}    effectiveTo=${effectiveTo}    approvalType=${approvalType}    allowLogin=${allowLogin}    serviceStatus=${serviceStatus}
    ${data}=    json.dumps    ${data} 
    Check And Create YNW Session
    ${resp}=    POST On Session  ynw  /provider/membership/service    data=${data}   expected_status=any
    [Return]  ${resp}

Get Membership Service by id

    [Arguments]    ${memberid}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/membership/service/${memberid}  expected_status=any
    [Return]  ${resp}

Update Membership Service 

    [Arguments]    ${memberServiceId}    ${description}    ${name}    ${displayName}    ${effectiveFrom}    ${effectiveTo}    ${approvalType}    ${allowLogin}    ${serviceStatus}

    ${data}=  Create Dictionary    description=${description}    name=${name}    displayName=${displayName}    effectiveFrom=${effectiveFrom}    effectiveTo=${effectiveTo}    approvalType=${approvalType}    allowLogin=${allowLogin}    serviceStatus=${serviceStatus}
    ${data}=    json.dumps    ${data} 
    Check And Create YNW Session
    ${resp}=    PUT On Session  ynw  /provider/membership/service/${memberServiceId}    data=${data}   expected_status=any
    [Return]  ${resp}

Enable Disable Membership service 

    [Arguments]    ${status}    

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/account/settings/membership/${status}  expected_status=any
    [Return]  ${resp}

Create Membership 

    [Arguments]    ${firstname}    ${lastname}    ${mob}    ${memberserviceid}    ${cc}    

    ${data}=  Create Dictionary    firstName=${firstname}    lastName=${lastname}    phoneNo=${mob}    memberServiceId=${memberserviceid}    countryCode=${cc}
    ${data}=    json.dumps    ${data} 
    Check And Create YNW Session
    ${resp}=    POST On Session  ynw  /consumer/membership    data=${data}   expected_status=any
    [Return]  ${resp}

Get Membership By Id

    [Arguments]    ${member_id}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/membership/${member_id}  expected_status=any
    [Return]  ${resp}

Enable Disable Member Service 

    [Arguments]    ${serviceId}    ${status}    

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/membership/service/${serviceId}/status/${status}  expected_status=any
    [Return]  ${resp}

Get Membership Service 

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/membership/service  expected_status=any
    [Return]  ${resp}

Get Membership Service Count

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/membership/service/count  expected_status=any
    [Return]  ${resp}

Get Member

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/membership  expected_status=any
    [Return]  ${resp}

Get Member Count

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/membership/count  expected_status=any
    [Return]  ${resp}

Approve Member 

    [Arguments]    ${memberId}    ${approvalStatus}    ${remarks}

    ${data}=  Create Dictionary    approvalStatus=${approvalStatus}    remarks=${remarks}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/membership/status/${memberId}    data=${data}    expected_status=any
    [Return]  ${resp}

Get Before Questionnaire Membership

    [Arguments]    ${account}    ${serviceId}    ${channel}
    Check And Create YNW Session
    ${resp}=    GET On Session  ynw  url=/consumer/questionnaire/memberservice/${serviceId}/${channel}?account=${account}  expected_status=any
    [Return]  ${resp}

Submit Member Qnr

    [Arguments]    ${account}    ${uuid}    ${data}

    Check And Create YNW Session
    ${resp}=    POST On Session  ynw  url=/consumer/membership/questionnaire/submit/${uuid}?account=${account}    data=${data}       expected_status=any
    [Return]  ${resp}

get all Member questionnaire

    [Arguments]    ${account}     ${uid}

    Check And Create YNW Session
    ${resp}=    GET On Session  ynw  url=/consumer/membership/questionnaire/${uid}?account=${account}      expected_status=any
    [Return]  ${resp}

Change Release Status Of Member Questionnaire

    [Arguments]    ${releaseStatus}    ${uuid}    ${id}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /consumer/membership/questionnaire/change/${releaseStatus}/${uuid}/${id}    expected_status=any
    [Return]  ${resp}

Resubmit Member Questionnaire

    [Arguments]    ${account}    ${uuid}    ${data}

    Check And Create YNW Session
    ${resp}=    POST On Session  ynw  url=/consumer/membership/questionnaire/resubmit/${uuid}?account=${account}    data=${data}       expected_status=any
    [Return]  ${resp}

Update Membership 

    [Arguments]    ${firstname}    ${lastname}    ${mob}    ${cc}    ${remarks}    ${memberId}

    ${data}=  Create Dictionary    firstName=${firstname}    lastName=${lastname}    phoneNo=${mob}    countryCode=${cc}    remarks=${remarks}    memberId=${memberId}
    ${data}=    json.dumps    ${data} 
    Check And Create YNW Session
    ${resp}=    PUT On Session  ynw  /provider/membership/${memberId}    data=${data}   expected_status=any
    [Return]  ${resp}

Get MemberService by Consumer

    [Arguments]    ${accountId}

    Check And Create YNW Session
    ${resp}=    GET On Session  ynw  url=/consumer/membership/services?account=${accountId}       expected_status=any
    [Return]  ${resp}

Member Creation From Provider Dashboard

    [Arguments]     ${memberServiceId}    ${firstName}    ${lastName}   ${phoneNo}   ${countryCode}

    ${data}=  Create Dictionary    memberServiceId=${memberServiceId}    firstName=${firstName}    lastName=${lastName}    phoneNo=${phoneNo}    countryCode=${countryCode}
    ${data}=    json.dumps    ${data} 

    Check And Create YNW Session
    ${resp}=    POST On Session  ynw  /provider/membership/member   data=${data}    expected_status=any
    [Return]  ${resp}

Submit Provider Member Qnr

    [Arguments]    ${memberId}  ${data}

    Check And Create YNW Session
    ${resp}=    POST On Session  ynw  /provider/membership/questionnaire/submit/${memberId}    data=${data}       expected_status=any
    [Return]  ${resp}

Resubmit Provider Member Qnr

    [Arguments]    ${memberId}  ${data}

    Check And Create YNW Session
    ${resp}=    POST On Session  ynw  /provider/membership/questionnaire/resubmit/${memberId}    data=${data}       expected_status=any
    [Return]  ${resp}

Get Provider Member Qnr

    [Arguments]    ${memberId}

    Check And Create YNW Session
    ${resp}=    GET On Session  ynw  /provider/membership/questionnaire/${memberId}        expected_status=any
    [Return]  ${resp}


# ........Finance Manager.............


Enable Disable Jaldee Finance 

   [Arguments]  ${status}  
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  /provider/jp/finance/settings/jaldeeFinance/${status}  expected_status=any
   [Return]  ${resp}


Create Category

    [Arguments]    ${name}  ${categoryType}   
    ${data}=  Create Dictionary  name=${name}   categoryType=${categoryType}   
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw    /provider/jp/finance/category    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Update Category

    [Arguments]    ${category_id}  ${name}  ${categoryType}   
    ${data}=  Create Dictionary  name=${name}   categoryType=${categoryType}   
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/jp/finance/category/${category_id}    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}


Update Category Status

    [Arguments]    ${category_id}  ${name}  ${categoryType}   ${status}
    ${data}=  Create Dictionary  name=${name}   categoryType=${categoryType}   
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/jp/finance/category/${category_id}/${status}    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}


Get Category By Id

    [Arguments]   ${category_id}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/category/${category_id}     expected_status=any
    [Return]  ${resp}

Get Category With Filter

    [Arguments]   &{param}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/category/list    params=${param}     expected_status=any
    [Return]  ${resp}

Get Default Category By Type

    [Arguments]   ${typeEnum}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/category/default/${typeEnum}     expected_status=any
    [Return]  ${resp}

Update default category by type

    [Arguments]   ${categoryid}   ${categoryTypeEnum}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/jp/finance/category/${categoryid}/${categoryTypeEnum}/default    expected_status=any
    [Return]  ${resp}
    
Get Category By CategoryType

    [Arguments]   ${categoryType}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/category/type/${categoryType}     expected_status=any
    [Return]  ${resp}


Create Vendor

    [Arguments]    ${vendorCategory}  ${vendorId}  ${vendorName}   ${contactPersonName}    ${address}    ${state}    ${pincode}    ${mobileNo}   ${email}    &{kwargs}
    
    ${contact}=  Create Dictionary   address=${address}   state=${state}  pincode=${pincode}    phoneNumbers=${mobileNo}  emails=${email}

    ${data}=  Create Dictionary  vendorCategory=${vendorCategory}   vendorId=${vendorId}  vendorName=${vendorName}   contactPersonName=${contactPersonName}  contactInfo=${contact}    
    # ...    email=${email}  address=${address}  bankAccountNumber=${bank_accno}    
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw    /provider/jp/finance/vendor    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}


Update Vendor

    [Arguments]    ${vendor_uid}    ${vendorCategory}       ${vendorId}  ${vendorName}   ${contactPersonName}    ${address}    ${state}    ${pincode}    ${mobileNo}   ${email}  &{kwargs}
    ${contact}=  Create Dictionary   address=${address}   state=${state}  pincode=${pincode}    phoneNumbers=${mobileNo}  emails=${email}

    ${data}=  Create Dictionary  vendorCategory=${vendorCategory}   vendorId=${vendorId}  vendorName=${vendorName}   contactPersonName=${contactPersonName}  contactInfo=${contact}      
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}  
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/jp/finance/vendor/${vendor_uid}     data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}


Get Vendor By Id

    [Arguments]   ${vendor_id}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/vendor/${vendor_id}     expected_status=any
    [Return]  ${resp}

Upload Finance Attachment
    [Arguments]    ${categoryId}      ${categoryType}      @{vargs}

    ${len}=  Get Length  ${vargs}
    ${attachments}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${attachments}  ${vargs[${index}]}
    END
    
    ${data}=  Create Dictionary      attachments=${attachments}

   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  /provider/jp/finance/category/${categoryId}/${categoryType}/attachments  data=${data}  expected_status=any
   [Return]  ${resp}

Create Finance Status

    [Arguments]    ${name}  ${categoryType}   
    ${data}=  Create Dictionary  name=${name}   categoryType=${categoryType}   
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw    /provider/jp/finance/status    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Update Finance Status

    [Arguments]    ${name}  ${categoryType}   ${status_id} 
    ${data}=  Create Dictionary  name=${name}   categoryType=${categoryType}   
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/jp/finance/status/${status_id}   data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Get jp finance settings
 
   Check And Create YNW Session
   ${resp}=  GET On Session  ynw  /provider/jp/finance/settings  expected_status=any
   [Return]  ${resp}

Enable Disable Jaldee Finance Status

   [Arguments]  ${Status_id}    ${status}  
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  /provider/jp/finance/status/${Status_id}/${status}  expected_status=any
   [Return]  ${resp}

Get Finance Status By Id

    [Arguments]   ${Status_id}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/status/${Status_id}    expected_status=any
    [Return]  ${resp}

Get default status

    [Arguments]   ${categoryType}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/status/default/${categoryType}     expected_status=any
    [Return]  ${resp}

Set default status

   [Arguments]   ${Status_id}    ${Category_type}  
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  /provider/jp/finance/status/${Status_id}/${Category_type}/default   expected_status=any
   [Return]  ${resp}

Get Vendor List with Count filter
    [Arguments]   &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /provider/jp/finance/vendor/count    params=${param}    expected_status=any    headers=${headers}
    [Return]  ${resp}

Get Vendor List with filter
    [Arguments]   &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /provider/jp/finance/vendor    params=${param}    expected_status=any    headers=${headers}
    [Return]  ${resp}

Update Vendor Status

    [Arguments]    ${vendorUId}  ${vendorStatus}  
     
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/jp/finance/vendor/${vendorUId}/${vendorStatus}     expected_status=any    headers=${headers}
    [Return]  ${resp}

Upload Finance Vendor Attachment
    [Arguments]    ${vendorUid}      @{vargs}

    ${len}=  Get Length  ${vargs}
    ${attachments}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${attachments}  ${vargs[${index}]}
    END
    
    ${data}=  Create Dictionary      attachments=${attachments}

   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  /provider/jp/finance/vendor/${vendorUid}/attachments  data=${data}  expected_status=any
   [Return]  ${resp}

Create Expense

    [Arguments]    ${expenseCategoryId}  ${amount}  ${expenseDate}   ${expenseFor}    ${vendorUid}  ${description}  ${referenceNo}   ${employeeName}    ${itemList}    ${departmentList}    ${uploadedDocuments}  &{kwargs}
    ${data}=  Create Dictionary  expenseCategoryId=${expenseCategoryId}   amount=${amount}  expenseDate=${expenseDate}   expenseFor=${expenseFor}  vendorUid=${vendorUid}    description=${description}  referenceNo=${referenceNo}    employeeName=${employeeName}    itemList=${itemList}    departmentList=${departmentList}    uploadedDocuments=${uploadedDocuments}
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw    /provider/jp/finance/expense    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Update Expense

    [Arguments]    ${uid}    ${expenseCategoryId}  ${amount}  ${expenseDate}   ${expenseFor}    ${vendorUid}  ${description}  ${referenceNo}   ${employeeName}    ${itemList}    ${departmentList}    ${uploadedDocuments}  &{kwargs}
    ${data}=  Create Dictionary  expenseCategoryId=${expenseCategoryId}   amount=${amount}  expenseDate=${expenseDate}   expenseFor=${expenseFor}  vendorUid=${vendorUid}    description=${description}  referenceNo=${referenceNo}    employeeName=${employeeName}    itemList=${itemList}    departmentList=${departmentList}    uploadedDocuments=${uploadedDocuments}
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/jp/finance/expense/${uid}    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Get Expense By Id

    [Arguments]   ${uid}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  provider/jp/finance/expense/${uid}     expected_status=any
    [Return]  ${resp}

Get Expense With Filter

    [Arguments]   &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/expense    params=${param}     expected_status=any
    [Return]  ${resp}

Get Expense Count With Filter

    [Arguments]   &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/expense/count    params=${param}     expected_status=any
    [Return]  ${resp}

Upload Finance Expense Attachment
    [Arguments]    ${expenseUid}      @{vargs}

    ${len}=  Get Length  ${vargs}
    ${attachments}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${attachments}  ${vargs[${index}]}
    END
    
    ${data}=  Create Dictionary      attachments=${attachments}

   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  /provider/jp/finance/expense/${expenseUid}/attachments  data=${data}  expected_status=any
   [Return]  ${resp}

Create Invoice

    [Arguments]    ${invoiceCategoryId}   ${invoiceDate}   ${invoiceLabel}    ${billedTo}  ${vendorUid}  ${invoiceId}    ${providerConsumerIdList}  @{vargs}   &{kwargs}

     ${len}=  Get Length  ${vargs}
    ${itemList}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${itemList}  ${vargs[${index}]}
    END
    ${data}=  Create Dictionary  invoiceCategoryId=${invoiceCategoryId}     invoiceDate=${invoiceDate}   invoiceLabel=${invoiceLabel}  billedTo=${billedTo}    vendorUid=${vendorUid}  invoiceId=${invoiceId}    providerConsumerIdList=${providerConsumerIdList}   itemList=${itemList} 

    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    log  ${data}
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw    /provider/jp/finance/invoice    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Update Invoice

    [Arguments]    ${uid}     ${invoiceCategoryId}    ${invoiceDate}   ${invoiceLabel}    ${billedTo}  ${vendorUid}      &{kwargs}
    ${data}=  Create Dictionary  invoiceCategoryId=${invoiceCategoryId}     invoiceDate=${invoiceDate}   invoiceLabel=${invoiceLabel}  billedTo=${billedTo}    vendorUid=${vendorUid}  
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/jp/finance/invoice/${uid}    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Get Invoice By Id

    [Arguments]   ${uid}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/invoice/${uid}    expected_status=any
    [Return]  ${resp}
    

Get Date Time by Timezone
    [Arguments]  ${timezone}
    ${zone}  @{loc}=  Split String    ${timezone}  /
    ${loc}=  Random Element    ${loc}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/location/date/${zone}/${loc}  expected_status=any
    [Return]  ${resp}


Encrypted Provider Login
    [Arguments]    ${usname}  ${passwrd}   ${countryCode}=91
    ${data}=  Login  ${usname}  ${passwrd}   countryCode=${countryCode}
    ${encrypted_data}=  db.ecrypt_data  ${data}
    ${data}=    json.dumps    ${encrypted_data}
    ${resp}=    POST On Session    ynw    /provider/login/encrypt    data=${data}  expected_status=any
    [Return]  ${resp}


Get Invoice With Filter

    [Arguments]   &{param}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/invoice/    params=${param}    expected_status=any
    [Return]  ${resp}

Get Invoice Count With Filter

    [Arguments]   &{param}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/invoice/count    params=${param}    expected_status=any
    [Return]  ${resp}

Assign User

    [Arguments]    ${InvoiceUid}     ${userId}     
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/jp/finance/invoice/${InvoiceUid}/user/assign/${userId}      expected_status=any    headers=${headers}
    [Return]  ${resp}

UnAssign User

    [Arguments]    ${invocieUid}      
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/jp/finance/invoice/${invocieUid}/user/unassign      expected_status=any    headers=${headers}
    [Return]  ${resp}

Upload Finance Invoice Attachment
    [Arguments]    ${invoiceUid}      @{vargs}

    ${len}=  Get Length  ${vargs}
    ${attachments}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${attachments}  ${vargs[${index}]}
    END
    
    ${data}=  Create Dictionary      attachments=${attachments}

   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  /provider/jp/finance/invoice/${invoiceUid}/attachments  data=${data}  expected_status=any
   [Return]  ${resp}


Create PaymentsOut

    [Arguments]    ${amount}  ${payableCategoryId}  ${paidDate}   ${payableLabel}    ${description}  ${referenceNo}  ${vendorUid}   ${paymentsOutStatus}    ${paymentStatus}    ${paymentMode}   @{vargs}    &{kwargs}

    ${paymentMode}=    Create Dictionary   paymentMode=${paymentMode}

    ${len}=  Get Length  ${vargs}
    FOR    ${index}    IN RANGE  1  ${len}
        # ${ap}=  Create Dictionary  id=${vargs[${index}]}
        Append To List  ${vargs}   ${ap}
        
    END
    ${data}=  Create Dictionary  amount=${amount}   paymentsOutCategoryId=${payableCategoryId}  paidDate=${paidDate}   paymentsOutLabel=${payableLabel}  description=${description}    referenceNo=${referenceNo}  vendorUid=${vendorUid}    paymentsOutStatus=${paymentsOutStatus}    paymentStatus=${paymentStatus}    paymentInfo=${paymentMode}
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${paymentMode}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw    /provider/jp/finance/paymentsOut    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Update PaymentsOut

    [Arguments]    ${payable_uid}     ${amount}  ${payableCategoryId}  ${paidDate}   ${payableLabel}    ${description}  ${referenceNo}  ${vendorUid}   ${paymentsOutStatus}    ${paymentStatus}    ${paymentMode}    &{kwargs}
    
    ${paymentMode}=    Create Dictionary   paymentMode=${paymentMode}
    ${data}=  Create Dictionary  amount=${amount}   paymentsOutCategoryId=${payableCategoryId}  paidDate=${paidDate}   paymentsOutLabel=${payableLabel}  description=${description}    referenceNo=${referenceNo}  vendorUid=${vendorUid}    paymentsOutStatus=${paymentsOutStatus}    paymentStatus=${paymentStatus}    paymentInfo=${paymentMode}
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${paymentMode}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/jp/finance/paymentsOut/${payable_uid}     data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Get PaymentsOut By Id

    [Arguments]   ${uid}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/paymentsOut/${uid}     expected_status=any
    [Return]  ${resp}

Get PaymentsOut With Filter

    [Arguments]   &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/paymentsOut    params=${param}     expected_status=any
    [Return]  ${resp}

Get PaymentsOut Count With Filter

    [Arguments]   &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/paymentsOut/count    params=${param}     expected_status=any
    [Return]  ${resp}

Upload Finance PaymentsOut Attachment
    [Arguments]    ${payable_uid}      @{vargs}

    ${len}=  Get Length  ${vargs}
    ${attachments}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${attachments}  ${vargs[${index}]}
    END
    
    ${data}=  Create Dictionary      attachments=${attachments}

   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  /provider/jp/finance/paymentsOut/${payable_uid}/attachments  data=${data}  expected_status=any
   [Return]  ${resp}

Update PaymentsOut Status

    [Arguments]    ${payableUid}     ${status} 
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/jp/finance/paymentsOut/${payableUid}/${status}     expected_status=any    headers=${headers}
    [Return]  ${resp}


Create CDL Enquiry
    [Arguments]  ${category}  ${customer_id}  ${customerCity}  ${aadhaar}  ${pan}  ${customerState}  ${customerPin}  ${location}  ${enquireMasterId}  ${targetPotential}

    ${location}=   Create Dictionary   id=${location}
    ${customerid}=    Create Dictionary    id=${customer_id}

    ${data}=  Create Dictionary  category=${category}  customer=${customerid}  customerCity=${customerCity}  aadhaar=${aadhaar}  pan=${pan}  customerState=${customerState}  customerPin=${customerPin}  location=${location}  enquireMasterId=${enquireMasterId}  targetPotential=${targetPotential}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /provider/enquire  data=${data}  expected_status=any
    [Return]  ${resp}

Draft Loan Application

    [Arguments]  ${loanuid}   ${firstName}   ${lastName}   ${phoneNo}   ${email}   ${dob}   ${gender}   ${countryCode}   ${id}   ${locationArea}   ${invoiceAmount}   ${downpaymentAmount}   ${requestedAmount}   ${remarks}   ${emiPaidAmountMonthly}   ${employee}   ${referralEmployeeCode}   ${subventionLoan}   ${loanApplicationKycList}   ${type}   ${loanProducts}   ${productCategoryId}   ${productSubCategoryId}   ${location}   ${partner}

    ${LoanApplicationKycList}=  Create List     ${loanApplicationKycList}
    ${customer}=    Create Dictionary   firstName=${firstName}   lastName=${lastName}   phoneNo=${phoneNo}   email=${email}   dob=${dob}   gender=${gender}   countryCode=${countryCode}   id=${id}
    ${data}=  Create Dictionary  customer=${customer}   locationArea=${locationArea}   invoiceAmount=${invoiceAmount}   downpaymentAmount=${downpaymentAmount}   requestedAmount=${requestedAmount}   remarks=${remarks}   emiPaidAmountMonthly=${emiPaidAmountMonthly}   employee=${employee}   referralEmployeeCode=${referralEmployeeCode}   subventionLoan=${subventionLoan}   loanApplicationKycList=${loanApplicationKycList}   type=${type}   loanProducts=${loanProducts}   productCategoryId=${productCategoryId}   productSubCategoryId=${productSubCategoryId}   location=${location}   partner=${partner}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/loanapplication/${loanuid}   data=${data}  expected_status=any
    [Return]  ${resp}

    
Save Customer Details 

    [Arguments]  ${loanuid}   ${firstName}   ${lastName}   ${email}   ${dob}   ${gender}   ${id}   ${loanApplicationKycList}   ${location}   ${consumerPhoto}

    ${LoanApplicationKycList}=  Create List     ${loanApplicationKycList}
    ${consumerPhoto}=   Create List    ${consumerPhoto}
    ${customer}=    Create Dictionary   firstName=${firstName}   lastName=${lastName}   email=${email}   dob=${dob}   gender=${gender}   id=${id}
    ${data}=  Create Dictionary  customer=${customer}   consumerPhoto=${consumerPhoto}   loanApplicationKycList=${loanApplicationKycList}   location=${location}   
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/loanapplication/${loanuid}   data=${data}  expected_status=any
    [Return]  ${resp}  

Equifax Report 

    [Arguments]   ${loanuid}   ${phone}   ${kycid}

    ${data}=  Create Dictionary   loanApplicationUid=${loanuid}   customerPhone=${phone}   id=${kycid}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /provider/loanapplication/equifaxreport   data=${data}  expected_status=any
    [Return]  ${resp}  

MAFIL Score

    [Arguments]   ${loanuid}   ${kycid}

    ${data}=  Create Dictionary   loanApplicationUid=${loanuid}   id=${kycid}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/loanapplication/csms/generatescore   data=${data}  expected_status=any
    [Return]  ${resp}

Cibil Score

    [Arguments]   ${kycid}   ${cibilscore}   ${cibilreport}

    ${cibilreport}=  Create List   ${cibilreport}
    ${data}=  Create Dictionary   id=${kycid}   cibilScore=${cibilscore}   cibilReport=${cibilreport}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/loanapplication/cibilscore   data=${data}  expected_status=any
    [Return]  ${resp}

Retainrejected Loan Application

    [Arguments]    ${loanApplicationUid}  ${note}

    ${data}=  Create Dictionary    note=${note}
    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/loanapplication/${loanApplicationUid}/retainrejected  data=${data}  expected_status=any
    [Return]  ${resp}


Perfios Score

    [Arguments]  ${loanuid}   ${kycid}   ${phone}

    ${data}=  Create Dictionary   loanApplicationUid=${loanuid}   id=${kycid}   customerPhone=${phone}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /provider/provider/loanapplication/perfios   data=${data}  expected_status=any
    [Return]  ${resp} 

Account with Multiple Users in NBFC


    ${resp}=   Get File    /ebs/TDD/varfiles/musers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
    ${multiuser_list}=  Create List
    &{License_total}=  Create Dictionary
    ${licid}  ${licname}=  get_highest_license_pkg
    
    FOR   ${a}    IN RANGE   ${length}   
        ${resp}=  Encrypted Provider Login  ${MUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${decrypted_data}=  db.decrypt_data   ${resp.content}
        Log  ${decrypted_data}

        Set Test Variable  ${pkgId}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
        Set Test Variable  ${Dom}   ${decrypted_data['sector']}
        Set Test Variable  ${SubDom}   ${decrypted_data['subSector']}
        ${name}=  Set Variable  ${decrypted_data['accountLicenseDetails']['accountLicense']['name']}

        Continue For Loop If  '${Dom}' != "finance"
        Continue For Loop If  '${SubDom}' != "nbfc"
        Continue For Loop If  '${pkgId}' == '${licId}'

        ${resp}=   Get License UsageInfo 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF  ${resp.json()['metricUsageInfo'][8]['total']} > 2 and ${resp.json()['metricUsageInfo'][8]['used']} < ${resp.json()['metricUsageInfo'][8]['total']}
    Exit For Loop
        END
    END
   
    [Return]  ${MUSERNAME${a}}

Get default status by type

    [Arguments]  ${typeName}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/status/default/${typeName}/     expected_status=any
    [Return]  ${resp}


Get status count

    [Arguments]   &{param} 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/status/list/count   params=${param}   expected_status=any
    [Return]  ${resp}

Get status list filter

    [Arguments]   &{param} 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/status/list   params=${param}   expected_status=any
    [Return]  ${resp}


Update default status

    [Arguments]    ${id}  ${typeName}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/jp/finance/status/${id}/${typeName}/default     expected_status=any
    [Return]  ${resp}
# -------------- Patient Records-----------

Add Patient Medical History

    [Arguments]    ${providerConsumerId}  ${title}  ${description}  ${viewByUsers}   @{vargs}
    ${len}=  Get Length  ${vargs}
    ${AttachmentList}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${AttachmentList}  ${vargs[${index}]}
    END
    ${data}=    Create Dictionary    providerConsumerId=${providerConsumerId}  title=${title}  description=${description}    viewByUsers=${viewByUsers}  medicalHistoryAttachments=${AttachmentList}
    Check And Create YNW Session
    ${data}=  json.dumps  ${data}
    ${resp}=    POST On Session    ynw    provider/medicalrecord/medicalHistory    data=${data}    expected_status=any
    [Return]  ${resp}

Update Patient Medical History

    [Arguments]    ${id}  ${title}  ${description}  ${viewByUsers}  @{vargs}
    ${len}=  Get Length  ${vargs}
    ${AttachmentList}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${AttachmentList}  ${vargs[${index}]}
    END
    ${data}=    Create Dictionary    id=${id}  title=${title}  description=${description}    viewByUsers=${viewByUsers}   medicalHistoryAttachments=${AttachmentList}
    Check And Create YNW Session
    ${data}=  json.dumps  ${data}
    ${resp}=    PUT On Session    ynw    provider/medicalrecord/medicalHistory/${id}    data=${data}     expected_status=any
    [Return]  ${resp}

Delete Patient Medical History
    Check And Create YNW Session
    [Arguments]    ${medicalHistoryId}  
    ${resp}=    DELETE On Session    ynw   /provider/medicalrecord/medicalHistory/${medicalHistoryId}        expected_status=any
    [Return]  ${resp}

Get Patient Medical History
    Check And Create YNW Session
    [Arguments]    ${providerConsumerId}  
    ${resp}=    GET On Session    ynw    /provider/medicalrecord/medicalHistory/${providerConsumerId}        expected_status=any
    [Return]  ${resp}

Provider Consumer Add Notes
    [Arguments]    ${providerConsumerId}  ${title}  ${description}  ${viewByUsers}
    ${data}=    Create Dictionary    providerConsumerId=${providerConsumerId}  title=${title}  description=${description}    viewByUsers=${viewByUsers}
    Check And Create YNW Session
    ${data}=  json.dumps  ${data}
    ${resp}=    POST On Session    ynw    /provider/customers/notes    data=${data}    expected_status=any
    [Return]  ${resp}

Update Provider Consumer Notes
    [Arguments]    ${id}  ${title}  ${description}  ${viewByUsers}
    ${data}=    Create Dictionary    id=${id}  title=${title}  description=${description}    viewByUsers=${viewByUsers}
    Check And Create YNW Session
    ${data}=  json.dumps  ${data}
    ${resp}=    PUT On Session    ynw    /provider/customers/notes    data=${data}    expected_status=any
    [Return]  ${resp}

Delete Provider Consumer Notes
    [Arguments]    ${notesId}  
    Check And Create YNW Session
    ${resp}=    DELETE On Session    ynw    /provider/customers/notes/${notesId}        expected_status=any
    [Return]  ${resp}

Get Provider Consumer Notes
    [Arguments]    ${providerConsumerId}  
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /provider/customers/notes/${providerConsumerId}        expected_status=any
    [Return]  ${resp}  



Create DentalRecord

    [Arguments]      ${toothNo}  ${toothType}  ${orginUid}   &{kwargs}

    ${data}=  Create Dictionary    toothNo=${toothNo}  toothType=${toothType}    orginUid=${orginUid}

    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END

    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/dental  data=${data}  expected_status=any
    [Return]  ${resp}


Update DentalRecord

    [Arguments]    ${id}      ${toothNo}  ${toothType}  ${orginUid}   &{kwargs}

    ${data}=  Create Dictionary    id=${id}    toothNo=${toothNo}  toothType=${toothType}    orginUid=${orginUid}

    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END

    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/dental  data=${data}  expected_status=any
    [Return]  ${resp}

Update DentalRecord Status
    Check And Create YNW Session
    [Arguments]      ${dentalid}   ${healthRecordSectionEnum} 
    ${resp}=    PUT On Session    ynw   /provider/dental/${dentalid}/status/${healthRecordSectionEnum}       expected_status=any
    [Return]  ${resp}

Delete DentalRecord
    Check And Create YNW Session
    [Arguments]    ${Id}  
    ${resp}=    DELETE On Session    ynw    /provider/dental/${Id}       expected_status=any
    [Return]  ${resp}

Get DentalRecord ById
    Check And Create YNW Session
    [Arguments]     ${Id}  
    ${resp}=    GET On Session    ynw    /provider/dental/${Id}        expected_status=any
    [Return]  ${resp}

Get DentalRecord ByProviderConsumerId
    Check And Create YNW Session
    [Arguments]     ${Id}  
    ${resp}=    GET On Session    ynw    /provider/dental/providerconsumer/${Id}        expected_status=any
    [Return]  ${resp}

Get DentalRecord ByCaseId
    Check And Create YNW Session
    [Arguments]     ${Id}  
    ${resp}=    GET On Session    ynw   /provider/dental/mr/${Id}    expected_status=any
    [Return]  ${resp}


Create Case Category

    [Arguments]      ${name}  ${aliasName}  &{kwargs}
    ${data}=  Create Dictionary    name=${name}  aliasName=${aliasName} 
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/medicalrecord/case/category  data=${data}  expected_status=any
    [Return]  ${resp}

Get Case Category

    [Arguments]     ${Id}  
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /provider/medicalrecord/case/category/${id}        expected_status=any
    [Return]  ${resp}

Update Case Category

    [Arguments]     ${id}  ${name}  ${aliasName}  ${status}  &{kwargs}
    ${data}=  Create Dictionary  name=${name}  aliasName=${aliasName}   status=${status}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/medicalrecord/case/category/${id}  data=${data}  expected_status=any
    [Return]  ${resp}

Get Case Category Filter
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/medicalrecord/case/category      expected_status=any
    [Return]  ${resp}

Create Case Type

    [Arguments]      ${name}  ${aliasName}  &{kwargs}
    ${data}=  Create Dictionary    name=${name}  aliasName=${aliasName} 
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/medicalrecord/case/type  data=${data}  expected_status=any
    [Return]  ${resp}

Get Case Type

    [Arguments]     ${Id}  
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /provider/medicalrecord/case/type/${id}  expected_status=any
    [Return]  ${resp}

Update Case Type
    [Arguments]     ${id}  ${name}  ${aliasName}  ${status}  &{kwargs}
    ${data}=  Create Dictionary  name=${name}  aliasName=${aliasName}   status=${status}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/medicalrecord/case/type/${id}  data=${data}  expected_status=any
    [Return]  ${resp}

Get Case Type Filter
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/medicalrecord/case/type      expected_status=any
    [Return]  ${resp}

Create MR Case
    [Arguments]      ${category}  ${type}  ${doctor}  ${consumer}   ${title}  ${description}  &{kwargs}
    ${data}=  Create Dictionary    category=${category}  type=${type}  doctor=${doctor}  consumer=${consumer}   title=${title}  description=${description}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/medicalrecord/case  data=${data}  expected_status=any
    [Return]  ${resp}

Get MR Case By UID
     [Arguments]     ${uid}  
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /provider/medicalrecord/case/${uid}  expected_status=any
    [Return]  ${resp}

Update MR Case
    [Arguments]      ${uid}  ${title}  ${description}   &{kwargs}
    ${data}=  Create Dictionary  title=${title}  description=${description}   status=${status}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/medicalrecord/case/${uid}  data=${data}  expected_status=any
    [Return]  ${resp}

Get Case Filter
    [Arguments]    &{kwargs} 
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/medicalrecord/case   params=${kwargs}   expected_status=any
    [Return]  ${resp}

Change Case Status
    [Arguments]      ${uid}  ${statusName} 
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/medicalrecord/case/${uid}/status/${statusName}   expected_status=any
    [Return]  ${resp}

Get Case Count Filter
    [Arguments]    &{kwargs} 
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/medicalrecord/case     params=${kwargs}   expected_status=any
    [Return]  ${resp}

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
    [Return]  ${resp}

Update Treatment Plan

    [Arguments]     ${id}    ${treatment}    ${status}    &{kwargs}

    ${data}=  Create Dictionary    id=${id}      treatment=${treatment}    status=${status}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/medicalrecord/treatment  data=${data}  expected_status=any
    [Return]  ${resp}

Update Treatment Plan Work status
    [Arguments]     ${treatmentId}  ${workId}  ${status}  
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/medicalrecord/treatment/${treatmentId}/${workId}/${status}   expected_status=any
    [Return]  ${resp}

Update Work list in Treatment Plan
    [Arguments]     ${treatmentId}    ${works}
    ${data}=  json.dumps  ${works}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/medicalrecord/treatment/work/${treatmentId}    data=${data}  expected_status=any
    [Return]  ${resp}

Get Treatment Plan By Id
    [Arguments]     ${id}
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /provider/medicalrecord/treatment/${Id}  expected_status=any
    [Return]  ${resp}

Get Treatment Plan By case Id
    [Arguments]     ${uid}
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /provider/medicalrecord/treatment/case/${uid}  expected_status=any
    [Return]  ${resp}

Get NonDental Treatment Plan By case Id
    [Arguments]     ${uid}
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /provider/medicalrecord/treatment/nondental/case/${uid}  expected_status=any
    [Return]  ${resp}

Delete Treatment Plan Work By id
    [Arguments]     ${id}
    Check And Create YNW Session
    ${resp}=   DELETE On Session  ynw  /provider/medicalrecord/treatment/work/${id}  expected_status=any
    [Return]  ${resp}



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
    [Return]  ${resp}

Update MedicalRecordPrescription Template
    [Arguments]    ${id}  ${templateName}    @{vargs}
    ${len}=  Get Length  ${vargs}
    ${prescriptionDto}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${prescriptionDto}  ${vargs[${index}]}
    END
    ${data}=    Create Dictionary   id=${id}  templateName=${templateName}  prescriptionDto=${prescriptionDto} 
    Check And Create YNW Session
    ${data}=  json.dumps  ${data}
    ${resp}=    PUT On Session    ynw    /provider/medicalrecord/prescription/template    data=${data}    expected_status=any
    [Return]  ${resp}

Remove Prescription Template
    Check And Create YNW Session
    [Arguments]    ${temId} 
    ${resp}=    DELETE On Session    ynw    /provider/medicalrecord/prescription/template/${temId}       expected_status=any
    [Return]  ${resp}

Get Prescription Template By Account Id

    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/medicalrecord/prescription/template      expected_status=any
    [Return]  ${resp}

Get MedicalPrescription Template By Id
    [Arguments]    ${temId} 
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/medicalrecord/prescription/template/${temId}      expected_status=any
    [Return]  ${resp}

Create Prescription 
    [Arguments]    ${providerConsumerId}    ${userId}    ${caseId}       ${dentalRecordId}    ${html}      @{vargs}    &{kwargs}
    ${len}=  Get Length  ${vargs}
    ${mrPrescriptions}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${mrPrescriptions}  ${vargs[${index}]}
    END
    ${data}=    Create Dictionary    providerConsumerId=${providerConsumerId}    doctorId=${userId}    caseId=${caseId}      dentalRecordId=${dentalRecordId}    html=${html}    mrPrescriptions=${mrPrescriptions}    
    Check And Create YNW Session
     FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    ${resp}=    POST On Session    ynw    /provider/medicalrecord/prescription    data=${data}    expected_status=any
    [Return]  ${resp}

Update Prescription 
    [Arguments]    ${prescriptionUId}   ${providerConsumerId}    ${userId}    ${caseId}       ${dentalRecordId}    ${html}    @{vargs}  &{kwargs}
    ${len}=  Get Length  ${vargs}
    ${mrPrescriptions}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${mrPrescriptions}  ${vargs[${index}]}
    END
    ${data}=    Create Dictionary    providerConsumerId=${providerConsumerId}    doctorId=${userId}    caseId=${caseId}      dentalRecordId=${dentalRecordId}    html=${html}    mrPrescriptions=${mrPrescriptions}    
    Check And Create YNW Session
     FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    ${resp}=    PUT On Session    ynw    /provider/medicalrecord/prescription/${prescriptionUId}    data=${data}    expected_status=any
    [Return]  ${resp}

Get Prescription By Provider consumer Id
    [Arguments]    ${providerConsumerId} 
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/medicalrecord/prescription/${providerConsumerId}      expected_status=any
    [Return]  ${resp}

Remove Prescription 
    Check And Create YNW Session
    [Arguments]    ${prescriptionUId}
    ${resp}=    DELETE On Session    ynw    /provider/medicalrecord/prescription/${prescriptionUId}       expected_status=any
    [Return]  ${resp}


Get Prescription By Filter
    [Arguments]    &{kwargs} 
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/medicalrecord/prescription   params=${kwargs}   expected_status=any
    [Return]  ${resp}

Get Prescription Count By Filter
    [Arguments]    &{param} 
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/medicalrecord/prescription/count   params=${param}   expected_status=any
    [Return]  ${resp}

Get Prescription By UID
    [Arguments]    ${uid}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/medicalrecord/prescription/uid/${uid}    expected_status=any
    [Return]  ${resp}


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
    [Return]  ${resp}

Update MR Sections
    [Arguments]    ${uid}    ${sectionType}   ${sectionValue}   ${attachments}   @{vargs}   &{kwargs}
    Check And Create YNW Session
    ${len}=  Get Length  ${vargs}
    ${attachments}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${attachments}  ${vargs[${index}]}
    END
    ${data}=    Create Dictionary    sectionType=${sectionType}     sectionValue=${sectionValue}    attachments=${attachments}        
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    ${resp}=    PUT On Session    ynw    /provider/medicalrecord/section/${uid}   data=${data}    expected_status=any
    [Return]  ${resp}

Create Section Template

    Check And Create YNW Session
    ${resp}=    POST On Session    ynw   /provider/medicalrecord/section/createdefaulttemplates    expected_status=any
    [Return]  ${resp}

Get Section Template
    [Arguments]    ${caseUid} 
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/medicalrecord/section/template/case/${caseUid}    expected_status=any
    [Return]  ${resp}

Get Sections By UID
    [Arguments]    ${uid}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/medicalrecord/section/${uid}    expected_status=any
    [Return]  ${resp}

Get Sections Filter
    [Arguments]    &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/medicalrecord/section    params=${kwargs}    expected_status=any
    [Return]  ${resp}

Get MR Sections By Case
    [Arguments]    ${uid}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/medicalrecord/section/case/${uid}    expected_status=any
    [Return]  ${resp}

Delete MR Sections 
    Check And Create YNW Session
    [Arguments]    ${uid} 
    ${resp}=    DELETE On Session    ynw    /provider/medicalrecord/section/${uid}       expected_status=any
    [Return]  ${resp}

Share Prescription To Patient
    [Arguments]   ${prescriptionUid}   ${msg}   ${email}   ${telegram}  ${sms}    ${whatsapp}  
    Check And Create YNW Session
    ${medium}=  Create Dictionary  email=${email}  telegram=${telegram}   sms=${sms}   whatsapp=${whatsapp}
    ${data}=  Create Dictionary  message=${msg}   medium=${medium}  
    ${data}=    json.dumps    ${data}
    ${resp}=  POST On Session  ynw  /provider/medicalrecord/prescription/sharePrescription/${prescriptionUid}   data=${data}  expected_status=any
    [Return]  ${resp}

Share Prescription To ThirdParty
    [Arguments]   ${prescriptionUid}   ${msg}   ${email}     ${sms}    ${whatsapp}  ${telegram}
    Check And Create YNW Session 
    ${data}=  Create Dictionary  message=${msg}   email=${email}    sms=${sms}   whatsapp=${whatsapp}   telegram=${telegram} 
    ${data}=    json.dumps    ${data}
    ${resp}=  POST On Session  ynw  /provider/medicalrecord/prescription/sharePrescription/thirdParty/${prescriptionUid}   data=${data}  expected_status=any
    [Return]  ${resp}
    
Get Treatment Plan By ProviderConsumer Id
    [Arguments]     ${id}
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /provider/medicalrecord/treatment/consumer/${id}  expected_status=any
    [Return]  ${resp}

Get Treatment Plan By Dental Id
    [Arguments]     ${id}
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /provider/medicalrecord/treatment/dental/${id}  expected_status=any
    [Return]  ${resp}

# --------- Finance ----------
Auto Invoice Generation For Catalog

   [Arguments]  ${catalogId}      ${toggle} 
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  /provider/catalog/${catalogId}/invoicegeneration/${toggle}   expected_status=any
   [Return]  ${resp}

Auto Invoice Generation For Service

   [Arguments]  ${serviceId}      ${toggle} 
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  /provider/services/${serviceId}/invoicegeneration/${toggle}   expected_status=any
   [Return]  ${resp}

Create PaymentsIn

    [Arguments]    ${amount}  ${payableCategoryId}  ${receivedDate}   ${payableLabel}    ${vendorUid}    ${paymentMode}   &{kwargs}   


    # ${paymentMode}=    Create Dictionary   paymentMode=${paymentMode}
    ${data}=  Create Dictionary  amount=${amount}   paymentsInCategoryId=${payableCategoryId}  receivedDate=${receivedDate}   paymentsInLabel=${payableLabel}    vendorUid=${vendorUid}   paymentInfo=${paymentMode}
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw    /provider/jp/finance/paymentsIn    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Update PaymentsIn
    [Arguments]    ${payable_uid}  ${amount}  ${payableCategoryId}  ${receivedDate}   ${payableLabel}    ${vendorUid}    ${paymentMode}   &{kwargs}

    # ${paymentMode}=    Create Dictionary   paymentMode=${paymentMode}
    ${data}=  Create Dictionary  amount=${amount}   paymentsInCategoryId=${payableCategoryId}  receivedDate=${receivedDate}   paymentsInLabel=${payableLabel}    vendorUid=${vendorUid}      paymentInfo=${paymentMode}
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/jp/finance/paymentsIn/${payable_uid}     data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Get PaymentsIn By Id

    [Arguments]   ${uid}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/paymentsIn/${uid}     expected_status=any
    [Return]  ${resp}


Get PaymentsIn With Filter

    [Arguments]   &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/paymentsIn   params=${param}     expected_status=any
    [Return]  ${resp}

Get PaymentsIn Count With Filter

    [Arguments]   &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/paymentsIn/count    params=${param}     expected_status=any
    [Return]  ${resp}

Update PaymentsIn Status

    [Arguments]    ${payableUid}     ${status} 
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/jp/finance/paymentsIn/${payableUid}/${status}     expected_status=any    headers=${headers}
    [Return]  ${resp}

Get PaymentsOut Log List UId

    [Arguments]   ${uid}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/paymentsOut/${uid}/statelist     expected_status=any
    [Return]  ${resp}

Get PaymentsIn Log List UId

    [Arguments]   ${uid}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/paymentsIn/${uid}/statelist     expected_status=any
    [Return]  ${resp}

Upload Finance PaymentsIn Attachment
    [Arguments]    ${payable_uid}      @{vargs}

    ${len}=  Get Length  ${vargs}
    ${attachments}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${attachments}  ${vargs[${index}]}
    END
    
    ${data}=  Create Dictionary      attachments=${attachments}

   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  /provider/jp/finance/paymentsIn/${payable_uid}/attachments  data=${data}  expected_status=any
   [Return]  ${resp}

Generate Link For Invoice

    [Arguments]    ${uuid}  ${phNo}  ${email}  ${emailNotification}    ${smsNotification}   @{vargs}
    
    ${data}=    Create Dictionary    uuid=${uuid}  phNo=${phNo}  email=${email}    emailNotification=${emailNotification}  smsNotification=${smsNotification}
    Check And Create YNW Session
    ${data}=  json.dumps  ${data}
    ${resp}=    POST On Session    ynw    /provider/jp/finance/pay/createLink    data=${data}    expected_status=any
    [Return]  ${resp}

Get Payment Link Details

    [Arguments]   ${paylink}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/link/${paylink}    expected_status=any
    [Return]  ${resp}

Apply Discount

    [Arguments]    ${uuid}     ${id}  ${discountValue}  ${privateNote}   ${displayNote}         &{kwargs}
    ${data}=  Create Dictionary  id=${id}   discountValue=${discountValue}  privateNote=${privateNote}   displayNote=${displayNote}   
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/jp/finance/invoice/${uuid}/apply/discount    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Apply Jaldee Coupon

    [Arguments]    ${uuid}     ${jaldeeCouponCode}         &{kwargs}
    ${data}=  Create Dictionary  jaldeeCouponCode=${jaldeeCouponCode}   
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/jp/finance/invoice/${uuid}/apply/jaldeecoupon    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}


Apply Provider Coupon

    [Arguments]    ${uuid}     ${couponCode}         &{kwargs}
    ${data}=  Create Dictionary  couponCode=${couponCode}   
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/jp/finance/invoice/${uuid}/apply/providercoupon    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Apply Service Level Discount

    [Arguments]    ${uuid}     ${id}  ${discountValue}  ${privateNote}   ${displayNote}    ${serviceId}      &{kwargs}
    ${data}=  Create Dictionary  id=${id}   discountValue=${discountValue}  privateNote=${privateNote}   displayNote=${displayNote}   
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/jp/finance/invoice/${uuid}/apply/serviceleveldiscount/${serviceId}    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}


Remove Discount

    [Arguments]    ${uuid}     ${id}  ${discountValue}  ${privateNote}   ${displayNote}         &{kwargs}
    ${data}=  Create Dictionary  id=${id}   discountValue=${discountValue}  privateNote=${privateNote}   displayNote=${displayNote}   
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/jp/finance/invoice/${uuid}/remove/discount    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}


Remove Jaldee Coupon

    [Arguments]    ${uuid}     ${jaldeeCouponCode}         &{kwargs}
    ${data}=  Create Dictionary  jaldeeCouponCode=${jaldeeCouponCode}   
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/jp/finance/invoice/${uuid}/remove/jaldeecoupon    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}


Remove Provider Coupon

    [Arguments]    ${uuid}     ${couponCode}         &{kwargs}
    ${data}=  Create Dictionary  couponCode=${couponCode}   
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/jp/finance/invoice/${uuid}/remove/providercoupon    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Update Finance Service

    [Arguments]    ${uuid}     @{vargs}
    ${len}=  Get Length  ${vargs}
    ${serviceList}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${serviceList}  ${vargs[${index}]}
    END
    ${data}=    json.dumps    ${serviceList}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/jp/finance/invoice/${uuid}/updateservices    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Remove Service Level Discount

    [Arguments]    ${uuid}     ${id}  ${discountValue}  ${privateNote}   ${displayNote}    ${serviceId}      &{kwargs}
    ${data}=  Create Dictionary  id=${id}   discountValue=${discountValue}  privateNote=${privateNote}   displayNote=${displayNote}   
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/jp/finance/invoice/${uuid}/remove/serviceleveldiscount/${serviceId}    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Update Invoice Items

    [Arguments]    ${uuid}     @{vargs}
    ${len}=  Get Length  ${vargs}
    ${ItemList}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${ItemList}  ${vargs[${index}]}
    END
    ${data}=    json.dumps    ${ItemList}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/jp/finance/invoice/${uuid}/updateitems    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Apply Item Level Discount

    [Arguments]    ${uuid}     ${id}  ${discountValue}  ${privateNote}   ${displayNote}    ${itemId}      &{kwargs}
    ${data}=  Create Dictionary  id=${id}   discountValue=${discountValue}  privateNote=${privateNote}   displayNote=${displayNote}   
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/jp/finance/invoice/${uuid}/apply/itemleveldiscount/${itemId}    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Remove Item Level Discount

    [Arguments]    ${uuid}     ${id}  ${discountValue}  ${privateNote}   ${displayNote}    ${itemId}      &{kwargs}
    ${data}=  Create Dictionary  id=${id}   discountValue=${discountValue}  privateNote=${privateNote}   displayNote=${displayNote}   
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/jp/finance/invoice/${uuid}/remove/itemleveldiscount/${itemId}    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Update Bill Status

    [Arguments]   ${invoiceUid}    ${billStatus}   ${billStatusNote}
    ${data}=  Create Dictionary  billStatusNote=${billStatusNote}  
    Check And Create YNW Session
    ${data}=  json.dumps  ${data}
    ${resp}=  PUT On Session  ynw   /provider/jp/finance/invoice/${invoiceUid}/billstatus/${billStatus}     data=${data}   expected_status=any
    [Return]  ${resp}

Apply Provider Coupon for waitlist

    [Arguments]    ${uuid}     ${couponCode}     &{kwargs}
    ${data}=  Create Dictionary  couponCode=${couponCode}     
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/waitlist/${uuid}/apply/providercoupon    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Remove Provider Coupon for waitlist

    [Arguments]    ${uuid}     ${couponCode}     &{kwargs}
    ${data}=  Create Dictionary  couponCode=${couponCode}      
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/waitlist/${uuid}/remove/providercoupon    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Apply Service Level Discount for waitlist

    [Arguments]    ${uuid}     ${id}  ${discountValue}  ${privateNote}   ${displayNote}    &{kwargs}
    ${data}=  Create Dictionary  id=${id}   discountValue=${discountValue}  privateNote=${privateNote}   displayNote=${displayNote}   
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/waitlist/${uuid}/apply/serviceleveldiscount    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Remove Service Level Discount for waitlist

    [Arguments]    ${uuid}     ${id}  ${discountValue}  ${privateNote}   ${displayNote}    &{kwargs}
    ${data}=  Create Dictionary  id=${id}   discountValue=${discountValue}  privateNote=${privateNote}   displayNote=${displayNote}   
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/waitlist/${uuid}/remove/serviceleveldiscount    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Get Invoice Log List UId

    [Arguments]   ${uid}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/invoice/${uid}/invoicestatelog     expected_status=any
    [Return]  ${resp}

Update bill view status

    [Arguments]   ${uid}    ${billViewStatus}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/jp/finance/invoice/${uid}/billviewstatus/${billViewStatus}     expected_status=any
    [Return]  ${resp}

Share invoice as pdf 
    [Arguments]    ${uuid}   ${emailNotification}    ${email}   ${html}  &{kwargs}
    ${data}=    Create Dictionary       emailNotification=${emailNotification}  email=${email}   html=${html}
     FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}  
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/jp/finance/invoice/${uuid}/createSharePdf    data=${data}   expected_status=any
    [Return]  ${resp}


Apply Jaldee Coupon for waitlist

    [Arguments]    ${uuid}     ${couponCode}     &{kwargs}
    ${data}=  Create Dictionary  jaldeeCouponCode=${couponCode}     
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/waitlist/${uuid}/apply/jaldeecoupon    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Remove Jaldee Coupon for waitlist

    [Arguments]    ${uuid}     ${couponCode}     &{kwargs}
    ${data}=  Create Dictionary  jaldeeCouponCode=${couponCode}     
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/waitlist/${uuid}/remove/jaldeecoupon    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Get Waitlist level Bill Details

    [Arguments]   ${uuid}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/waitlist/${uuid}/billdetails     expected_status=any
    [Return]  ${resp}

Apply Jaldee Coupon for Appointment

    [Arguments]    ${uuid}     ${couponCode}     &{kwargs}
    ${data}=  Create Dictionary  jaldeeCouponCode=${couponCode}     
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/appointment/${uuid}/apply/jaldeecoupon    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Remove Jaldee Coupon for Appointment

    [Arguments]    ${uuid}     ${couponCode}     &{kwargs}
    ${data}=  Create Dictionary  jaldeeCouponCode=${couponCode}     
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/appointment/${uuid}/remove/jaldeecoupon    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Apply Provider Coupon for Appointment

    [Arguments]    ${uuid}     ${couponCode}     &{kwargs}
    ${data}=  Create Dictionary  couponCode=${couponCode}     
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/appointment/${uuid}/apply/providercoupon    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Remove Provider Coupon for Appointment

    [Arguments]    ${uuid}     ${couponCode}     &{kwargs}
    ${data}=  Create Dictionary  couponCode=${couponCode}     
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/appointment/${uuid}/remove/providercoupon    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Apply Service Level Discount for Appointment

    [Arguments]    ${uuid}     ${id}  ${discountValue}  ${privateNote}   ${displayNote}    &{kwargs}
    ${data}=  Create Dictionary  id=${id}   discountValue=${discountValue}  privateNote=${privateNote}   displayNote=${displayNote}   
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/appointment/${uuid}/apply/serviceleveldiscount    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}


Remove Service Level Discount for Appointment

    [Arguments]    ${uuid}     ${id}  ${discountValue}  ${privateNote}   ${displayNote}    &{kwargs}
    ${data}=  Create Dictionary  id=${id}   discountValue=${discountValue}  privateNote=${privateNote}   displayNote=${displayNote}   
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/appointment/${uuid}/remove/serviceleveldiscount    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

    
Get Appointment level Bill Details

    [Arguments]   ${uuid}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/appointment/${uuid}/billdetails     expected_status=any
    [Return]  ${resp}


Get Category List Configuration

    [Arguments]   ${categoryType}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/category/config/${categoryType}       expected_status=any
    [Return]  ${resp}

Copy Category Status List Configuration

    [Arguments]   ${categoryType}  
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/jp/finance/config/${categoryType}       expected_status=any
    [Return]  ${resp}

Get Status List Configuration

    [Arguments]   ${categoryType}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/status/config/${categoryType}       expected_status=any
    [Return]  ${resp}

Get finance Confiq
 
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/jp/finance/config/Invoice     expected_status=any
    [Return]  ${resp}

Get default finance category Confiq
 
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/category/default/Invoice     expected_status=any
    [Return]  ${resp}

Apply Discount for Order

    [Arguments]    ${uuid}     ${id}  ${discountValue}  ${privateNote}   ${displayNote}    &{kwargs}
    ${data}=  Create Dictionary  id=${id}   discountValue=${discountValue}  privateNote=${privateNote}   displayNote=${displayNote}   
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/orders/${uuid}/apply/discount    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Remove Discount for Order

    [Arguments]    ${uuid}     ${id}  ${discountValue}  ${privateNote}   ${displayNote}    &{kwargs}
    ${data}=  Create Dictionary  id=${id}   discountValue=${discountValue}  privateNote=${privateNote}   displayNote=${displayNote}   
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/orders/${uuid}/remove/discount    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Apply Jaldee Coupon for Order

    [Arguments]    ${uuid}     ${couponCode}     &{kwargs}
    ${data}=  Create Dictionary  jaldeeCouponCode=${couponCode}     
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/orders/${uuid}/apply/jaldeecoupon    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Remove Jaldee Coupon for Order

    [Arguments]    ${uuid}     ${couponCode}     &{kwargs}
    ${data}=  Create Dictionary  jaldeeCouponCode=${couponCode}     
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/orders/${uuid}/remove/jaldeecoupon    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Apply Provider Coupon for Order

    [Arguments]    ${uuid}     ${couponCode}     &{kwargs}
    ${data}=  Create Dictionary  couponCode=${couponCode}     
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/orders/${uuid}/apply/providercoupon    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Remove Provider Coupon for Order

    [Arguments]    ${uuid}     ${couponCode}     &{kwargs}
    ${data}=  Create Dictionary  couponCode=${couponCode}     
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/orders/${uuid}/remove/providercoupon    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Get Order level Bill Details

    [Arguments]   ${uuid}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/orders/${uuid}/billdetails     expected_status=any
    [Return]  ${resp}


Make Payment By Cash 

    [Arguments]    ${uuid}     ${acceptPaymentBy}    ${amount}     ${paymentNote}     &{kwargs}
    ${data}=  Create Dictionary  uuid=${uuid}     acceptPaymentBy=${acceptPaymentBy}     amount=${amount}     paymentNote=${paymentNote}     
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw    /provider/payment/acceptPayment    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Make Payment By Cash For Invoice

    [Arguments]    ${uuid}     ${acceptPaymentBy}    ${amount}     ${paymentNote}     &{kwargs}
    ${data}=  Create Dictionary  uuid=${uuid}     acceptPaymentBy=${acceptPaymentBy}     amount=${amount}     paymentNote=${paymentNote}     
    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}   
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw    /provider/jp/finance/pay/acceptPayment    data=${data}  expected_status=any    headers=${headers}
    [Return]  ${resp}

Create Appointment Reminder Settings
    [Arguments]  ${resource_type}  ${event_type}  ${email}  ${sms}  ${push_notf}  ${common_msg}  ${reminder_time}
    ${data}=  Create Dictionary  resourceType=${resource_type}  eventType=${event_type}  email=${email}  sms=${sms}  
                ...    pushNotification=${push_notf}  commonMessage=${common_msg}  time=${reminder_time}
    ${data}=   json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /provider/consumerNotification/settings   data=${data}  expected_status=any
    [Return]  ${resp}

Get Bookings Invoices
     [Arguments]      ${ynwuuid}  
    Check And Create YNW Session
    ${resp}=    GET On Session  ynw   /provider/jp/finance/invoice/ynwuid/${ynwuuid}    expected_status=any
    [Return]  ${resp}

Update Invoice Status

    [Arguments]    ${InvoiceUid}     ${userId}     
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw    /provider/jp/finance/invoice/${InvoiceUid}/${userId}     expected_status=any    headers=${headers}
    [Return]  ${resp}

Get next invoice Id
    [Arguments]   ${locationId}    
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/invoice/${locationId}/nextInvoiceId     expected_status=any


Validate phone number
    [Arguments]     ${countryCode}  ${phoneNumber}
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /provider/validate/phonenumber/${countryCode}/${phoneNumber}  expected_status=any
    

# ................ LOS Lead ....................


Create Lead Status LOS
    [Arguments]      ${name}  

    ${data}=  Create Dictionary    name=${name}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/los/lead/status  data=${data}  expected_status=any
    [Return]  ${resp}

Get Lead Status by id LOS
    [Arguments]      ${id}  

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/los/lead/status/${id}  expected_status=any
    [Return]  ${resp}

Update Lead Status LOS
    [Arguments]      ${id}   ${name}   ${status}

    ${data}=  Create Dictionary    name=${name}  status=${status}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/los/lead/status/${id}  data=${data}  expected_status=any
    [Return]  ${resp}

Get Lead Status LOS

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/los/lead/status  expected_status=any
    [Return]  ${resp}

Create Lead Progress LOS
    [Arguments]      ${name}  

    ${data}=  Create Dictionary    name=${name}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/los/lead/progress  data=${data}  expected_status=any
    [Return]  ${resp}

Get Lead Progress by id LOS
    [Arguments]      ${id}  

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/los/lead/progress/${id}  expected_status=any
    [Return]  ${resp}

Update Lead Progress LOS
    [Arguments]      ${id}   ${name}   ${status}

    ${data}=  Create Dictionary    name=${name}  status=${status}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/los/lead/progress/${id}  data=${data}  expected_status=any
    [Return]  ${resp}

Get Lead Progress LOS

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/los/lead/progress  expected_status=any
    [Return]  ${resp}

Create Lead Credit Status LOS 
    [Arguments]      ${name}  

    ${data}=  Create Dictionary    name=${name}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/los/lead/creditstatus  data=${data}  expected_status=any
    [Return]  ${resp}

Get Lead Credit Status by id LOS
    [Arguments]      ${id}  

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/los/lead/creditstatus/${id}  expected_status=any
    [Return]  ${resp}

Update Lead Credit Status LOS
    [Arguments]      ${id}   ${name}   ${status}

    ${data}=  Create Dictionary    name=${name}  status=${status}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/los/lead/creditstatus/${id}  data=${data}  expected_status=any
    [Return]  ${resp}

Get Lead Credit Status LOS

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/los/lead/creditstatus  expected_status=any
    [Return]  ${resp}

# Create Lead LOS     
#     [Arguments]     ${channel}   ${losProduct}   ${statusid}   ${statusname}    ${progressid}   ${progressname}   ${requestedAmount}   ${description}   ${consumerId}   ${consumerFirstName}   ${consumerLastName}   ${dob}   ${gender}   ${consumerPhoneCode}   ${consumerPhone}   ${consumerEmail}   ${aadhaar}   ${pan}   ${bankAccountNo}   ${bankIfsc}   ${permanentAddress1}   ${permanentAddress2}   ${permanentDistrict}   ${permanentState}   ${permanentPin}   ${nomineeType}   ${nomineeName}

#     Check And Create YNW Session
#     ${status}=  Create Dictionary  id=${statusid}  name=${statusname}
#     ${progress}=  Create Dictionary  id=${progressid}  name=${progressname}
#     ${consumerKyc}=   Create Dictionary  consumerId=${consumerId}  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${consumerPhoneCode}  consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType}  nomineeName=${nomineeName}
#     ${data}=  Create Dictionary  losProduct=${losProduct}  status=${status}  progress=${progress}  requestedAmount=${requestedAmount}  description=${description}  consumerKyc=${consumerKyc}
#     ${data}=    json.dumps    ${data}
#     ${resp}=  POST On Session  ynw  /provider/los/lead/channel/${channel}   data=${data}  expected_status=any
#     [Return]  ${resp}

Create Lead LOS     
    [Arguments]  ${channel}  ${description}  ${losProduct}  ${requestedAmount}  &{kwargs}

    ${data}=  Create Dictionary  losProduct=${losProduct}  requestedAmount=${requestedAmount}  description=${description}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary   ${data}   ${key}=${value}
    END
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/los/lead/channel/${channel}   data=${data}  expected_status=any
    [Return]  ${resp}

Get Lead LOS 
    [Arguments]      ${uid}  

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/los/lead/${uid}  expected_status=any
    [Return]  ${resp}

Updtae Lead LOS    
    [Arguments]     ${uid}   ${losProduct}   ${requestedAmount}   ${description}   ${consumerId}   ${consumerFirstName}   ${consumerLastName}   ${id}   ${dob}   ${gender}   ${consumerPhoneCode}   ${consumerPhone}   ${consumerEmail}   ${aadhaar}   ${pan}   ${bankAccountNo}   ${bankIfsc}   ${permanentAddress1}   ${permanentAddress2}   ${permanentDistrict}   ${permanentState}   ${permanentPin}   ${nomineeType}   ${nomineeName}

    Check And Create YNW Session
    ${consumerKyc}=   Create Dictionary  consumerId=${consumerId}  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  id=${id}  dob=${dob}  gender=${gender}  consumerPhoneCode=${consumerPhoneCode}  consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType}  nomineeName=${nomineeName}
    ${data}=  Create Dictionary  losProduct=${losProduct}  requestedAmount=${requestedAmount}  description=${description}  consumerKyc=${consumerKyc}
    ${data}=    json.dumps    ${data}
    ${resp}=  PUT On Session  ynw  /provider/los/lead/${uid}   data=${data}  expected_status=any
    [Return]  ${resp}

Get Lead By Filter LOS
    [Arguments]   &{param}
    Log  ${param}
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /provider/los/lead   params=${param}   expected_status=any
    [Return]  ${resp}

Get Lead Count By Filter LOS
    [Arguments]   &{param}
    Log  ${param}
    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /provider/los/lead/count   params=${param}   expected_status=any
    [Return]  ${resp}

Change Lead Status LOS
    [Arguments]     ${uid}  ${id}

    Check And Create YNW Session  
    ${resp}=  PUT On Session  ynw  /provider/los/lead/${uid}/status/${id}   expected_status=any
    [Return]  ${resp}

Change Lead Credit Status LOS
    [Arguments]     ${uid}  ${id}

    Check And Create YNW Session  
    ${resp}=  PUT On Session  ynw  /provider/los/lead/${uid}/creditstatus/${id}   expected_status=any
    [Return]  ${resp}

Change Lead Progress LOS
    [Arguments]     ${uid}  ${id}

    Check And Create YNW Session  
    ${resp}=  PUT On Session  ynw  /provider/los/lead/${uid}/progress/${id}   expected_status=any
    [Return]  ${resp}

update lead assignees LOS    
    [Arguments]     ${uid}  @{vargs}

    ${len}=  Get Length  ${vargs}
    ${list}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${list}  ${vargs[${index}]}
    END
    ${data}=  Create Dictionary  assignees=${list} 
    ${data}=    json.dumps    ${data}
    
    Check And Create YNW Session   
    ${resp}=  PUT On Session  ynw  /provider/los/lead/${uid}/assignees    data=${data}   expected_status=any
    [Return]  ${resp}

Generate CIBIL LOS   
    [Arguments]     ${uid}

    Check And Create YNW Session  
    ${resp}=  PUT On Session  ynw  /provider/los/lead/${uid}/generate/cibil   expected_status=any
    [Return]  ${resp}

Generate EQUIFAX LOS
    [Arguments]     ${uid}

    Check And Create YNW Session  
    ${resp}=  PUT On Session  ynw  /provider/los/lead/${uid}/generate/equifax   expected_status=any
    [Return]  ${resp}

Generate Loan Application LOS
    [Arguments]     ${uid}

    Check And Create YNW Session  
    ${resp}=  PUT On Session  ynw  /provider/los/lead/${uid}/generate/loanapplication   expected_status=any
    [Return]  ${resp}

Get Audit Log or History LOS
    [Arguments]     ${uid}

    Check And Create YNW Session  
    ${resp}=  GET On Session  ynw  /provider/los/lead/${uid}/auditlog   expected_status=any
    [Return]  ${resp}

AddItemToFinance
   [Arguments]  ${uuid}   ${ItemLists}  &{kwargs}
    ${ItemLists}=  Create List     ${ItemLists}
    FOR  ${key}  ${value}  IN  &{kwargs}
        Append To List  ${ItemLists}   ${key}=${value}
    END
    ${data}=    json.dumps    ${ItemLists}  

   Check And Create YNW Session
   ${resp}=    PUT On Session    ynw   /provider/jp/finance/invoice/${uuid}/addItems    data=${data}  expected_status=any  
   [Return]  ${resp} 

AddServiceToFinance

   [Arguments]  ${uuid}   ${serviceList}  &{kwargs}
    ${serviceLists}=  Create List     ${serviceList}
    FOR  ${key}  ${value}  IN  &{kwargs}
        Append To List  ${serviceLists}   ${key}=${value}
    END
    ${data}=    json.dumps    ${serviceLists}  

   Check And Create YNW Session
   ${resp}=    PUT On Session    ynw   /provider/jp/finance/invoice/${uuid}/addservices    data=${data}  expected_status=any  
   [Return]  ${resp} 

RemoveServiceToFinance

   [Arguments]  ${uuid}   ${serviceList}  &{kwargs}
    ${serviceLists}=  Create List     ${serviceList}
    FOR  ${key}  ${value}  IN  &{kwargs}
        Append To List  ${serviceLists}   ${key}=${value}
    END
    ${data}=    json.dumps    ${serviceLists}  

   Check And Create YNW Session
   ${resp}=    PUT On Session    ynw   /provider/jp/finance/invoice/${uuid}/removeservices    data=${data}  expected_status=any  
   [Return]  ${resp} 

RemoveItemToFinance

   [Arguments]  ${uuid}   ${ItemLists}  &{kwargs}
    ${ItemLists}=  Create List     ${ItemLists}
    FOR  ${key}  ${value}  IN  &{kwargs}
        Append To List  ${ItemLists}   ${key}=${value}
    END
    ${data}=    json.dumps    ${ItemLists}  

   Check And Create YNW Session
   ${resp}=    PUT On Session    ynw   /provider/jp/finance/invoice/${uuid}/removeitems    data=${data}  expected_status=any  
   [Return]  ${resp} 
