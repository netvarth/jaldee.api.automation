*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Login
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Variables ***

${PASSWORD2}          Netvarth56
${invalid_provider}   abd@in.in
@{emptylist}

*** Test Cases ***

JD-TC-ProviderLogin-1
    [Documentation]    Login using valid mob no and password

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${ACC_ID35}=  get_id    ${PUSERNAME35}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${firstname}     ${resp.json()['firstName']}  
    Set Test Variable  ${lastname}      ${resp.json()['lastName']}  
    Set Test Variable  ${username}      ${resp.json()['userName']}
    Verify Response    ${resp}  id=${ACC_ID35}  userName=${username}  userType=1  accStatus=${status[0]}  firstName=${firstname}  lastName=${lastname}  primaryPhoneNumber=${PUSERNAME35}  isProvider=${bool[1]}

JD-TC-ProviderLogin-2
    [Documentation]    Login valid provider and enable Multi Factor Authentication then again try to login.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Multi Factor Authentication    ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${mfa}    ${resp.json()['multiFactorAuthenticationRequired']}

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Multi Factor Authentication ProviderLogin    ${PUSERNAME35}    ${countryCodes[0]}    ${PASSWORD}    ${mfa}    ${OtpPurpose['MultiFactorAuthentication']}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${resp}=    Enable Disable Branch    ${status[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${branchCode}=    FakerLibrary.Random Number
    Set Suite Variable    ${branchCode}
    ${branchName}=    FakerLibrary.name
    Set Suite Variable    ${branchName}

   ${resp}=   Get Location ById  ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pin}  ${resp.json()['pinCode']}

    ${resp}=  Get LocationsByPincode     ${pin}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${district}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}  
    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}
    Set Suite Variable    ${state}

    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${branchid1}  ${resp.json()['id']} 
    
JD-TC-ProviderLogin-UH1
    [Documentation]    Login using valid userid and invalid password

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  ${SPASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

JD-TC-ProviderLogin-UH2
    [Documentation]    Login using invalid  userid and invalid password

    ${resp}=   Encrypted Provider Login  ${invalid_provider}  ${SPASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${NOT_REGISTERED_PROVIDER}
    
JD-TC-ProviderLogin-UH3
    [Documentation]    Login using empty userid and invalid password

    ${resp}=   Encrypted Provider Login  ${EMPTY}  ${SPASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}     ${ENTER_PHONE_EMAIL}
    
JD-TC-ProviderLogin-UH4
    [Documentation]    Login using empty userid and empty password

    ${resp}=   Encrypted Provider Login  ${EMPTY}  ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}    ${ENTER_PHONE_EMAIL}
    
JD-TC-ProviderLogin-UH5
    [Documentation]    Login using valid userid and empty password

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}   ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}    ${PASSWORD_EMPTY}

JD-TC-ProviderLogin-UH6
    [Documentation]    Login using valid consumer userid and  password

    ${resp}=   Encrypted Provider Login  ${CUSERNAME8}   ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}      ${NOT_REGISTERED_PROVIDER}
    
JD-TC-ProviderLogin-UH7
    [Documentation]    Login using valid consumer userid and  invalid password

    ${resp}=   Encrypted Provider Login  ${CUSERNAME8}   ${SPASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}      ${NOT_REGISTERED_PROVIDER}
    
JD-TC-ProviderLogin-UH8
    [Documentation]    Login using valid consumer userid and  empty password

    ${resp}=   Encrypted Provider Login  ${CUSERNAME8}   ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${PASSWORD_EMPTY}

JD-TC-ProviderLogin-UH9
    [Documentation]    Login using valid  userid and  sql injection in password

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}   '' or '1'='1'
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

JD-TC-ProviderLogin-UH10
    [Documentation]    Login using valid userid and previous valid password

    ${resp}=  Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Provider Change Password  ${PASSWORD}  ${PASSWORD2}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Encrypted Provider Login   ${PUSERNAME35}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  ${resp.json()}  ${LOGIN_INVALID_USERID_PASSWORD}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD2}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Provider Change Password  ${PASSWORD2}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-ProviderLogin-UH11
    [Documentation]    Login using valid consumer mob no and  password

    ${resp}=   Encrypted Provider Login  ${CUSERNAME9}   ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${NOT_REGISTERED_PROVIDER}
    
JD-TC-ProviderLogin-UH12
    [Documentation]    Login using invalid provider id and password

    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+85263
    Set Test Variable   ${PUSERPH0}
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}   ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}       ${NOT_REGISTERED_PROVIDER}

JD-TC-ProviderLogin-UH13
    [Documentation]    Login provider with different country code
    # ${country_code}    Generate random string    2    0123456789
    FOR  ${i}  IN RANGE   3
        ${country_code}    Generate random string    2    0123456789
        Exit For Loop If  "${country_code}" != "91"
    END
    ${resp}=  Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD}  countryCode=${country_code}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${NOT_REGISTERED_PROVIDER}

JD-TC-ProviderLogin-UH14
    [Documentation]    Login using valid userid and invalid password 2 times

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200



    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  78945dfdg
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  1245asdf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

    # ${resp}=  GetCustomer  
    # Log  ${resp.content}
    # Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

JD-TC-ProviderLogin-UH15
    [Documentation]    Login using valid userid and invalid password 2 times(multiFactorAuthenticationRequired is false)

    ${resp}=   Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=  Get Account Settings
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Multi Factor Authentication    ${toggle[1]}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Account Settings
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable    ${mfa}    ${resp.json()['multiFactorAuthenticationRequired']}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME3}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME3}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME3}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME3}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

JD-TC-ProviderLogin-UH16
    [Documentation]    Login using valid userid and invalid password 2 times(without login)

    ${resp}=   Encrypted Provider Login  ${PUSERNAME3}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME3}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME3}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME3}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}


JD-TC-ProviderLogin-UH16
    [Documentation]    Login using valid userid and invalid password 2 times(Consumer)

    # ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD} 
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME3}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

    ${resp}=  Consumer Login  ${CUSERNAME3}  1245asuf 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

    ${resp}=  Consumer Login  ${CUSERNAME3}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

    ${resp}=  Consumer Login  ${CUSERNAME3}  1245asuf
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

    
***Comment***
JD-TC-ProviderLogin-2
    Comment    Login using valid emailid and password
    ${resp}=   Encrypted Provider Login  ${PUSEREMAIL5}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${id}=  get_id  ${PUSEREMAIL5}
    Verify Response  ${resp}  id=${id}  userName=subair nv  userType=1  accStatus=ACTIVE  firstName=subair  lastName=nv  primaryPhoneNumber=${PUSERNAME5}  isProvider=True
