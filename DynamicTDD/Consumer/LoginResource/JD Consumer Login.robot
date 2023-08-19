*** Settings ***
Suite Teardown    Delete All Sessions
Force Tags        ConsumerLogin
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${WRONG_PASSWORD}       Netvarth321
${Invalid_Password}     netvarth11

*** Test Cases ***

JD-TC-Consumer Login-1
    [Documentation]    Login using valid mob no and password
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp1}=  Get Consumer By Id  ${CUSERNAME1}
    Log  ${resp1.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${firstname}     ${resp1.json()['userProfile']['firstName']}  
    Set Test Variable  ${lastname}      ${resp1.json()['userProfile']['lastName']}  
    Set Test Variable  ${username}     ${resp1.json()['createdBy']['userName']}
    ${id}=  get_id  ${CUSERNAME1}
    Verify Response  ${resp}  id=${id}  userName=${username}  userType=0  accStatus=NOTAPPLICABLE  firstName=${firstname}  lastName=${lastname}  primaryPhoneNumber=${CUSERNAME1}  isProvider=False


JD-TC-Consumer Login-UH1
    [Documentation]    Login using valid userid and wrong password
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${WRONG_PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"    "${LOGIN_INVALID_USERID_PASSWORD}"
    
JD-TC-Consumer Login-UH2
    [Documentation]    Login using empty userid 
    ${resp}=   Consumer Login  ${EMPTY}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"      "${ENTER_PHONE_EMAIL}"
    
JD-TC-Consumer Login-UH3
    [Documentation]    Login using empty userid and empty password
    ${resp}=   Consumer Login  ${EMPTY}  ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"     "${ENTER_PHONE_EMAIL}"
    
    
JD-TC-Consumer Login-UH4
    [Documentation]    Login using valid userid and empty password
    ${resp}=   Consumer Login  ${CUSERNAME1}   ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"    "${PASSWORD_EMPTY}"
    
JD-TC-Consumer Login-UH5
    [Documentation]    Login using valid consumer userid and  invalid password
    ${resp}=   Consumer Login  ${CUSERNAME1}   ${Invalid_Password}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"     "${LOGIN_INVALID_USERID_PASSWORD}"
    
JD-TC-Consumer Login-UH6
    [Documentation]    Login using valid  userid and  sql injection in password
    ${resp}=   Consumer Login  ${CUSERNAME0}   '' or '1'='1'
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"     "${LOGIN_INVALID_USERID_PASSWORD}"
    
JD-TC-Consumer Login-UH7
    [Documentation]    Login using valid userid and previous valid password
    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Consumer Change Password  ${PASSWORD}  Netvarth2
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Consumer Login   ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"    "${LOGIN_INVALID_USERID_PASSWORD}"

JD-TC-Consumer Login- Revert Password
    [Documentation]   Change password to old password to avoid errors in other test suites
    ${resp}=  Consumer Login  ${CUSERNAME1}  Netvarth2
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Consumer Change Password  Netvarth2  ${PASSWORD}  
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Consumer Login   ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Consumer Login   ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Consumer Login-UH8
    [Documentation]    Login using invalid consumer and password

    ${Invalid_CUSER}=  Evaluate  ${CUSERNAME}+7557100
    ${resp}=   Consumer Login  ${Invalid_CUSER}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"     "${NOT_REGISTERED_CUSTOMER}"


JD-TC-Consumer Login-2
    [Documentation]    Login using valid mob no and password and different country code
    ${PO_Number}    Generate random string    4    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${CUSERPH3}=  Evaluate  ${CUSERNAME}+${PO_Number}
    Set Suite Variable   ${CUSERPH3}
    # Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH3}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH3}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERPH3_EMAIL}=   Set Variable  ${C_Email}${lastname}${PO_Number}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH3}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERPH3_EMAIL}  countryCode=+${country_code}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}    ${INVALID_PHONE}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Activation  ${CUSERPH3_EMAIL}  1
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Set Credential  ${CUSERPH3_EMAIL}  ${PASSWORD}  1   countryCode=+${country_code}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}  countryCode=+${country_code}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp1}=  Get Consumer By Id  ${CUSERPH3}
    # Log  ${resp1.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${firstname}     ${resp1.json()['userProfile']['firstName']}  
    # Set Test Variable  ${lastname}      ${resp1.json()['userProfile']['lastName']}  
    # Set Test Variable  ${username}     ${resp1.json()['createdBy']['userName']}
    # ${id}=  get_id  ${CUSERPH3}
    # Verify Response  ${resp}  id=${id}  userName=${username}  userType=0  
    # ...   accStatus=NOTAPPLICABLE  firstName=${firstname}  lastName=${lastname}  
    # ...   primaryPhoneNumber=${CUSERPH3}  isProvider=False


JD-TC-Consumer Login-3
    [Documentation]    Login using valid mob no and password and no country code
    ${PO_Number}    Generate random string    4    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${CUSERPH2}=  Evaluate  ${CUSERNAME}+${PO_Number}
    Set Suite Variable   ${CUSERPH2}
    # Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH2}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH2}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERPH2_EMAIL}=   Set Variable  ${C_Email}${lastname}${PO_Number}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH2}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERPH2_EMAIL}  countryCode=${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings   ${resp.json()}    ${COUNTRY_CODEREQUIRED}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Activation  ${CUSERPH2_EMAIL}  1
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Set Credential  ${CUSERPH2_EMAIL}  ${PASSWORD}  1   countryCode=+${country_code}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}  countryCode=${EMPTY}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   422
    # Should Be Equal As Strings  "${resp.json()}"     "${COUNTRY_CODEREQUIRED}"
    # Should Be Equal As Strings    ${resp.status_code}    401
    # Should Be Equal As Strings  "${resp.json()}"     "${NOT_REGISTERED_USER}"
    


JD-TC-Consumer Login-4
    [Documentation]    Login same mob no and password but different country code
    ${PO_Number}    Generate random string    4    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${country_code1}    Generate random string    2    123456789
    ${country_code1}    Convert To Integer  ${country_code1}
    ${country_code2}    Generate random string    3    123456789
    ${country_code2}    Convert To Integer  ${country_code2}

    Comment   with default country code +91
    ${CUSERPH4}=  Evaluate  ${CUSERNAME}+${PO_Number}
    # Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH4}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH4}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH4}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH4}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH4}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    Comment   with country code ${country_code1}
    
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERPH4_EMAIL}=   Set Variable  ${C_Email}${lastname}${country_code1}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH4}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERPH4_EMAIL}   countryCode=+${country_code1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}    ${INVALID_PHONE}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Activation  ${CUSERPH4_EMAIL}  1
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Set Credential  ${CUSERPH4_EMAIL}  ${PASSWORD}  1   countryCode=+${country_code1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    

    Comment   with country code ${country_code2}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERPH4_EMAIL}=   Set Variable  ${C_Email}${lastname}${country_code2}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH4}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERPH4_EMAIL}   countryCode=+${country_code2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}    ${INVALID_PHONE}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Activation  ${CUSERPH4_EMAIL}  1
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Set Credential  ${CUSERPH4_EMAIL}  ${PASSWORD}  1   countryCode=+${country_code2}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    Comment   Login

    ${resp}=  Check Consumer Exists  ${CUSERPH4}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Check Consumer Exists  ${CUSERPH4}   countryCode=+${country_code1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Login  ${CUSERPH4}  ${PASSWORD}  countryCode=+${country_code1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Logout
    # Should Be Equal As Strings    ${resp.status_code}    200
    
    # ${resp}=  Consumer Login  ${CUSERPH4}  ${PASSWORD}  countryCode=+${country_code2}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Logout
    # Should Be Equal As Strings    ${resp.status_code}    200

***Comment***

JD-TC-Consumer Login-2
    [Documentation]    Login using provider's mob no and  password
    ${resp}=   Consumer Login  ${PUSERNAME0}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp1}=  Get Consumer By Id  ${PUSERNAME0}
    Log  ${resp1.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${firstname}     ${resp1.json()['userProfile']['firstName']}  
    Set Test Variable  ${lastname}      ${resp1.json()['userProfile']['lastName']}  
    ${id}=  get_id  ${PUSERNAME0}
    Verify Response  ${resp}  id=${id}  userType=0  accStatus=ACTIVE  firstName=${firstname}  lastName=${lastname}  primaryPhoneNumber=${PUSERNAME0}  isProvider=True

JD-TC-Consumer Login-3
    [Documentation]    Login using valid email and password
    ${resp}=   Consumer Login  ${CUSERNAME5}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp1}=  Get Consumer By Id  ${CUSERNAME5}
    Log  ${resp1.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${firstname}     ${resp1.json()['userProfile']['firstName']}  
    Set Test Variable  ${lastname}      ${resp1.json()['userProfile']['lastName']}  
    Set Test Variable  ${username}     ${resp1.json()['createdBy']['userName']}
    ${id}=  get_id  ${CUSERNAME5}
    Verify Response  ${resp}  id=${id}  userName=${username}  userType=0  accStatus=NOTAPPLICABLE  firstName=${firstname}  lastName=${lastname}  primaryPhoneNumber=${CUSERNAME5}  isProvider=False

JD-TC-Consumer Login-4
    [Documentation]    Login using provider's email  and  password
    ${resp}=   Consumer Login  ${PUSEREMAIL6}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp1}=  Get Consumer By Id  ${PUSEREMAIL6}
    Log  ${resp1.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${firstname}     ${resp1.json()['userProfile']['firstName']}  
    Set Test Variable  ${lastname}      ${resp1.json()['userProfile']['lastName']}  
    Set Test Variable  ${username}     ${resp1.json()['createdBy']['userName']}
    ${id}=  get_id  ${PUSEREMAIL6}
    Verify Response  ${resp}  id=${id}  userName=${username}  userType=0  accStatus=ACTIVE  firstName=${firstname}  lastName=${lastname}  primaryPhoneNumber=${PUSERNAME7}  isProvider=True