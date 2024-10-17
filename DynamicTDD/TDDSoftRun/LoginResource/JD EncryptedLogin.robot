*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags  NextAvailableSchedule
Library     Collections
Library     String
Library     json
Library     requests
Library     JSONLibrary
# Library     FakerLibrary
Library    FakerLibrary    locale=en_IN
Library     /ebs/TDD/db.py
Resource    /ebs/TDD/ProviderKeywords.robot
Resource    /ebs/TDD/ConsumerKeywords.robot
Resource    /ebs/TDD/SuperAdminKeywords.robot
Variables   /ebs/TDD/varfiles/providers.py
Variables   /ebs/TDD/varfiles/hl_providers.py
Variables   /ebs/TDD/varfiles/consumerlist.py
# Variables   /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${SERVICE1}     manicure 
${SERVICE2}     pedicure
${self}     0
@{service_names}
${digits}       0123456789
@{provider_list}
@{dom_list}
@{multiloc_providers}
${countryCode}   +91

${PASSWORD2}          Netvarth56
${invalid_provider}   abd@in.in
@{emptylist}


*** Test Cases ***

JD-TC-EncryptedProviderLogin-1

    [Documentation]   Login using valid mob no and password with EncryptedProviderLogin.

    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PO_Number}    Generate random string    7    ${digits} 
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERNAME_B}=  Evaluate  ${PUSERNAME}+${PO_Number}
    # ${PUSERNAME_B}=  Evaluate  ${PUSERNAME}+5566014
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_B}    ${highest_package[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202
    ${resp}=  Account Activation  ${PUSERNAME_B}  ${OtpPurpose['ProviderSignUp']}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_B}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_B}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_B}${\n}
    Set Suite Variable  ${PUSERNAME_B}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}

    # Log  ${decrypted_data.json()}

    ${type string}=    Evaluate     type($decrypted_data)
    Log      ${type string}
    Log  ${decrypted_data['id']}
    Should Be Equal As Strings  ${decrypted_data['firstName']}   ${firstname}
    Should Be Equal As Strings  ${decrypted_data['lastName']}   ${lastname}
    Should Be Equal As Strings  ${decrypted_data['userType']}   1
    Should Be Equal As Strings  ${decrypted_data['accStatus']}   ${status[0]}
    Should Be Equal As Strings  ${decrypted_data['primaryPhoneNumber']}   ${PUSERNAME_B}
    Should Be Equal As Strings  ${decrypted_data['isProvider']}   ${bool[1]}
    Should Be Equal As Strings  ${decrypted_data['sector']}   ${dom}
    Should Be Equal As Strings  ${decrypted_data['subSector']}   ${sub_dom}
    Should Be Equal As Strings  ${decrypted_data['accountType']}   ${Business_type[0]}
    Should Be Equal As Strings  ${decrypted_data['adminPrivilege']}   ${bool[1]}


JD-TC-EncryptedProviderLogin-2

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
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${otp}=   verify accnt   ${PUSERNAME35}  ${OtpPurpose['MultiFactorAuthentication']}

    ${resp}=   Multi Factor Authentication ProviderLogin    ${PUSERNAME35}    ${countryCodes[0]}    ${PASSWORD}    ${bool[1]}   otp=${otp}
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
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
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
    
JD-TC-EncryptedProviderLogin-UH1

    [Documentation]    Login using valid userid and invalid password

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

JD-TC-EncryptedProviderLogin-UH2

    [Documentation]    Login using invalid  userid and invalid password

    ${resp}=   Encrypted Provider Login  ${invalid_provider}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${NOT_REGISTERED_CUSTOMER}
    
JD-TC-EncryptedProviderLogin-UH3

    [Documentation]    Login using empty userid and invalid password

    ${resp}=   Encrypted Provider Login  ${EMPTY}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}     ${ENTER_PHONE_EMAIL}
    
JD-TC-EncryptedProviderLogin-UH4

    [Documentation]    Login using empty userid and empty password

    ${resp}=   Encrypted Provider Login  ${EMPTY}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}    ${ENTER_PHONE_EMAIL}
 
JD-TC-EncryptedProviderLogin-UH5

    [Documentation]    Login using valid userid and empty password

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}    ${PASSWORD_EMPTY}

JD-TC-EncryptedProviderLogin-UH6

    [Documentation]    Login using valid consumer userid and  password

    ${resp}=   Encrypted Provider Login  ${CUSERNAME8}   ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}      ${NOT_REGISTERED_PROVIDER}
    
JD-TC-EncryptedProviderLogin-UH7

    [Documentation]    Login using valid consumer userid and  invalid password

    ${resp}=   Encrypted Provider Login  ${CUSERNAME8}   ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}      ${NOT_REGISTERED_PROVIDER}
    
JD-TC-EncryptedProviderLogin-UH8

    [Documentation]    Login using valid consumer userid and  empty password

    ${resp}=   Encrypted Provider Login  ${CUSERNAME8}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${PASSWORD_EMPTY}

JD-TC-EncryptedProviderLogin-UH9

    [Documentation]    Login using valid  userid and  sql injection in password

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}   '' or '1'='1'
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

JD-TC-EncryptedProviderLogin-UH10

    [Documentation]    Login using valid consumer mob no and  password

    ${resp}=   Encrypted Provider Login  ${CUSERNAME9}   ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${NOT_REGISTERED_PROVIDER}
    
JD-TC-EncryptedProviderLogin-UH11

    [Documentation]    Login using invalid provider id and password

    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+85263
    Set Test Variable   ${PUSERPH0}
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}   ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}       ${NOT_REGISTERED_CUSTOMER}

JD-TC-EncryptedProviderLogin-UH12

    [Documentation]    Login using valid userid and invalid password 2 times

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Provider Logout
    Log  ${resp.json()}
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

JD-TC-EncryptedProviderLogin-UH13

    [Documentation]    Login using valid userid and invalid password 2 times(multiFactorAuthenticationRequired is false)

    ${resp}=   Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Provider Logout
    Log  ${resp.json()}
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

JD-TC-EncryptedProviderLogin-UH14

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


# JD-TC-EncryptedProviderLogin-UH15

#     [Documentation]    Login valid provider and enable Multi Factor Authentication then again try to login with invalid otp(multiFactorAuthenticationLogin is false).

#     ${resp}=   Encrypted Provider Login  ${PUSERNAME37}  ${PASSWORD} 
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Get Account Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=    Multi Factor Authentication    ${toggle[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Account Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable    ${mfa}    ${resp.json()['multiFactorAuthenticationRequired']}

#     ${resp}=   ProviderLogout
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${otp}=   verify accnt   ${PUSERNAME3}  ${OtpPurpose['MultiFactorAuthentication']}

#     ${resp}=   Multi Factor Authentication ProviderLogin    ${PUSERNAME35}    ${countryCodes[0]}    ${PASSWORD}    ${bool[0]}   otp=${otp}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   422
#     Should Be Equal As Strings    ${resp.json()}     ${ENTER_VALID_OTP}


# JD-TC-EncryptedProviderLogin-UH16

#     [Documentation]    Login valid provider and enable Multi Factor Authentication then again try to login with EMPTY otp (multiFactorAuthenticationLogin is false).

#     ${resp}=   Encrypted Provider Login  ${PUSERNAME39}  ${PASSWORD} 
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Get Account Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=    Multi Factor Authentication    ${toggle[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Account Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable    ${mfa}    ${resp.json()['multiFactorAuthenticationRequired']}

#     ${resp}=   ProviderLogout
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${otp}=   verify accnt   ${PUSERNAME35}  ${OtpPurpose['MultiFactorAuthentication']}

#     ${resp}=   Multi Factor Authentication ProviderLogin    ${PUSERNAME35}    ${countryCodes[0]}    ${PASSWORD}    ${bool[0]}   otp=${EMPTY}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   422
#     Should Be Equal As Strings    ${resp.json()}     ${OTP_REQUIRED}

# JD-TC-EncryptedProviderLogin-UH17

#     [Documentation]    Login valid provider and enable Multi Factor Authentication then again try to login with invalid otp(multiFactorAuthenticationLogin is true).

#     ${resp}=   Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD} 
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Get Account Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=    Multi Factor Authentication    ${toggle[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Account Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable    ${mfa}    ${resp.json()['multiFactorAuthenticationRequired']}

#     ${resp}=   ProviderLogout
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${otp}=   verify accnt   ${PUSERNAME3}  ${OtpPurpose['MultiFactorAuthentication']}

#     ${resp}=   Multi Factor Authentication ProviderLogin    ${PUSERNAME35}    ${countryCodes[0]}    ${PASSWORD}    ${bool[0]}   otp=${otp}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   422
#     Should Be Equal As Strings    ${resp.json()}     ${ENTER_VALID_OTP}


# JD-TC-EncryptedProviderLogin-UH18

#     [Documentation]    Login valid provider and enable Multi Factor Authentication then again try to login with EMPTY otp (multiFactorAuthenticationLogin is true).

#     ${resp}=   Encrypted Provider Login  ${PUSERNAME43}  ${PASSWORD} 
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Get Account Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=    Multi Factor Authentication    ${toggle[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Account Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable    ${mfa}    ${resp.json()['multiFactorAuthenticationRequired']}

#     ${resp}=   ProviderLogout
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${otp}=   verify accnt   ${PUSERNAME35}  ${OtpPurpose['MultiFactorAuthentication']}

#     ${resp}=   Multi Factor Authentication ProviderLogin    ${PUSERNAME35}    ${countryCodes[0]}    ${PASSWORD}    ${bool[0]}   otp=${EMPTY}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   422
#     Should Be Equal As Strings    ${resp.json()}     ${OTP_REQUIRED}
    


    
