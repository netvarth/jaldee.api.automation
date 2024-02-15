*** Settings ***
Library           Collections
Library           String
Library           OperatingSystem
Library           json
Library           db.py
Resource          Keywords.robot

*** Keywords ***


Consumer SignUp Notification
  
    [Arguments]   ${firstname}   ${lastname}    ${primaryNo}    ${countryCode}   &{kwargs}
    ${items}=  Get Dictionary items  ${kwargs}
    ${data}=  Create Dictionary  firstName=${firstname}  lastName=${lastname}   primaryMobileNo=${primaryNo}  countryCode=${countryCode}  
    FOR  ${key}  ${value}  IN  @{items}
        Set To Dictionary  ${data}   ${key}=${value}
    END
    ${data}=    Create Dictionary    userProfile=${data}
    ${apple}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw    /consumer   data=${apple}  expected_status=any
    RETURN  ${resp}

Consumer Set Credential Notification
    [Arguments]  ${email}  ${password}  ${purpose}  ${countryCode}
    ${auth}=     Create Dictionary   password=${password}  countryCode=${countryCode}
    ${key}=   verify accnt  ${email}  ${purpose}
    ${apple}=    json.dumps    ${auth}
    ${resp}=    PUT On Session    ynw    /consumer/${key}/activate   data=${apple}  expected_status=any
    RETURN  ${resp}

Consumer Login Notification
    [Arguments]    ${usname}  ${passwrd}  ${countryCode}
    ${log}=  Login  ${usname}  ${passwrd}   countryCode=${countryCode}
    ${resp}=    POST On Session    ynw    /consumer/login    data=${log}  expected_status=any
    RETURN  ${resp}

# Account SignUp Notification
#     [Arguments]  ${firstname}  ${lastname}   ${ph}   ${countryCode}    ${sector}  ${sub_sector}    ${licPkgId}  &{kwargs}
#     ${items}=  Get Dictionary items  ${kwargs}
#     ${data}=    Create Dictionary   firstName=${firstname}  lastName=${lastname}    primaryMobileNo=${ph}  countryCode=${countryCode}   sector=${sector}  sub_sector=${sub_sector}   licPkgId=${licPkgId}
#     FOR  ${key}  ${value}  IN  @{items}
#         Set To Dictionary  ${data}   ${key}=${value}
#     END
#     ${data}=    Create Dictionary    userProfile=${data}
#     ${data}=    json.dumps    ${data}
#     Check And Create YNW Session
#     ${resp}=    POST On Session   ynw    /provider    data=${data}  expected_status=any  
#     RETURN  ${resp}
# User Creation
#     [Arguments]  ${firstname}  ${lastname}  ${yemail}  ${sector}  ${sub_sector}  ${ph}  ${licPkgId}  ${countryCode}=91
#     ${usp}=    Create Dictionary   firstName=${firstname}  lastName=${lastname}  email=${yemail}  primaryMobileNo=${ph}  countryCode=${countryCode}
#     ${data}=  Create Dictionary  userProfile=${usp}  sector=${sector}  subSector=${sub_sector}  licPkgId=${licPkgId}
#     RETURN  ${data}
Account Set Credential Notification
    [Arguments]  ${email}  ${password}  ${purpose}  ${countryCode}
    ${auth}=     Create Dictionary   password=${password}  countryCode=${countryCode}
    ${key}=   verify accnt  ${email}  ${purpose}
    ${apple}=    json.dumps    ${auth}
    ${resp}=    PUT On Session    ynw    /provider/${key}/activate    data=${apple}    expected_status=any
    RETURN  ${resp}

ProviderLogin Notification
    [Arguments]    ${usname}  ${passwrd}   ${countryCode}
    ${log}=  Login  ${usname}  ${passwrd}   countryCode=${countryCode}
    ${resp}=    POST On Session    ynw    /provider/login    data=${log}  expected_status=any
    RETURN  ${resp}

Account SignUp Notification
    [Arguments]  ${firstname}  ${lastname}  ${yemail}  ${sector}  ${sub_sector}  ${ph}  ${licPkgId}   ${countryCode}
    ${data}=   User Creation  ${firstname}  ${lastname}  ${yemail}  ${sector}  ${sub_sector}  ${ph}  ${licPkgId}  countryCode=${countryCode}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw    /provider    data=${data}  expected_status=any  
    RETURN  ${resp}

Business Profile with schedule Notification
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

Update Business Profile with schedule Notification
    [Arguments]  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${pin}  ${adds}  ${ph1}  ${ph2}  ${email1}  ${lid}
    ${data}=  Business Profile with schedule  ${bName}  ${bDesc}  ${shname}  ${place}  ${longi}  ${latti}  ${g_url}  ${pt}  ${oh}  ${rt}  ${ri}  ${sDate}  ${eDate}  ${noo}  ${stime}  ${etime}  ${pin}  ${adds}  ${ph1}  ${ph2}  ${email1}  ${lid}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/bProfile   data=${data}  expected_status=any
    RETURN  ${resp}