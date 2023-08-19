***Settings***
Library             RequestsLibrary
Variables           messagesapi.py
Variables           messagesbase.py
Variables           messageslicence.py
Variables           superadminmessagesapi.py 
Library             Collections
Library             String
Library             OperatingSystem
Library             json

*** Variables ***

&{iphone_headers}           Content-Type=application/json  User-Agent=iphone


*** Keywords ***

iphone App Login
    [Arguments]    ${usname}  ${passwrd}  ${countryCode}=+91
    ${login}=    Create Dictionary    loginId=${usname}  password=${passwrd}  countryCode=${countryCode}
    ${log}=    json.dumps    ${login}
    Create Session    ynw    ${BASE_URL}  headers=${iphone_headers}
    [Return]  ${log}

iphone App Check And Create YNW Session
    ${res}=   Session Exists    ynw
    # Run Keyword Unless  ${res}   Create Session    ynw    ${BASE_URL}  headers=${iphone_headers}
    IF  not ${res}
        Create Session    ynw    ${BASE_URL}  headers=${iphone_headers}
    END

iphone App Consumer SignUp
    [Arguments]  ${firstname}  ${lastname}  ${address}  ${primaryNo}  ${alternativeNo}  ${dob}  ${gender}  ${email}   ${countryCode}=+91
    ${apple}=  Consumer Creation  ${firstname}  ${lastname}  ${address}  ${primaryNo}  ${alternativeNo}  ${dob}  ${gender}  ${email}   countryCode=${countryCode}    
    iphone App Check And Create YNW Session
    ${resp}=    POST On Session    ynw    /consumer   data=${apple}  expected_status=any
    [Return]  ${resp}

iphone App Consumer Activation
    [Arguments]  ${email}  ${purpose}
    iphone App Check And Create YNW Session
    ${key}=   verify accnt  ${email}  ${purpose}
    ${resp_val}=  POST On Session   ynw  /consumer/${key}/verify   expected_status=any
    [Return]  ${resp_val}

iphone App Consumer Login
    [Arguments]    ${usname}  ${passwrd}  ${countryCode}=+91
    ${log}=  Android App Login  ${usname}  ${passwrd}   countryCode=${countryCode}
    ${resp}=    POST On Session    ynw    /consumer/login    data=${log}  expected_status=any
    [Return]  ${resp}

iphone App Consumer Logout
    iphone App Check And Create YNW Session
    ${resp}=    DELETE On Session    ynw    /consumer/login  expected_status=any
    [Return]  ${resp}

