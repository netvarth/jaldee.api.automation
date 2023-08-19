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
${P_PASSWORD}        Netvarth008
${C_PASSWORD}        Netvarth009


*** Test Cases ***
JD-TC-ResetPassword-1
    [Documentation]    Reset provider login  password with valid mobile number and new valid password

    ${resp}=  Encrypted Provider Login  ${PUSERNAME23}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME23}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${PUSERNAME23}  ${P_PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME23}  ${P_PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  ConsumerLogin  ${PUSERNAME23}  ${P_PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}  ${NOT_REGISTERED_CUSTOMER}
    

JD-TC-ResetPassword-2
    [Documentation]    verified user is not able to login using old password
    ${resp}=  SendProviderResetMail   ${PUSERNAME23}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${PUSERNAME23}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME23}  ${P_PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}  ${LOGIN_INVALID_USERID_PASSWORD}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME23}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-ResetPassword-3
    [Documentation]    Reset provider login  password with email and new valid password
    ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${mail}=   FakerLibrary.word
    ${PUSEREMAIL24}=  Set Variable  ${P_Email}${mail}.ynwtest@netvarth.com
    Set Suite Variable  ${PUSEREMAIL24}
    ${resp}=  Send Verify Login   ${PUSEREMAIL24}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Verify Login   ${PUSEREMAIL24}  4
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SendProviderResetMail   ${PUSEREMAIL24}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${PUSEREMAIL24}  ${P_PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${P_PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Provider Change Password  ${P_PASSWORD}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${PUSERNAME24}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}  ${NOT_REGISTERED_CUSTOMER}

JD-TC-ResetPassword-UH1
    [Documentation]    Reuse the generated shared key
    @{resp}=  ResetProviderPassword  ${PUSERNAME24}  ${P_PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  404
    Should Be Equal As Strings  ${resp[1].status_code}  404

JD-TC-ResetPassword-UH2
    [Documentation]    Send reset mail to a non-member email id
    ${resp}=  SendProviderResetMail   ${Invalid_email}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.content}  ${NOT_REGISTERED_USER}  

JD-TC-ResetPassword-UH3
    [Documentation]    Reset provider login  password with valid userid and empty password
    ${resp}=  SendProviderResetMail  ${PUSERNAME23}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${PUSERNAME23}  ${EMPTY}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  422
    Should Be Equal As Strings  ${resp[1].json()}   ${PASSWORD_EMPTY}

JD-TC-ResetPassword-UH4
    [Documentation]    Reset password of consumer using provider urls
    ${resp}=  SendProviderResetMail  ${CUSERNAME3} 
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}  ${NOT_REGISTERED_USER}
    @{resp}=  ResetProviderPassword  ${CUSERNAME3}  ${C_PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  404
    Should Be Equal As Strings  ${resp[1].status_code}  404

JD-TC-ResetPassword-UH5
    [Documentation]    Reset password of Provider with different country code
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${resp}=  SendProviderResetMail  ${PUSERNAME12}  countryCode=${country_code}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings    ${resp.json()}     	${NOT_REGISTERED_USER}
    # ${country_code}    Generate random string    2    0123456789
    # ${country_code}    Convert To Integer  ${country_code}
    # @{resp}=  ResetProviderPassword  ${PUSERNAME12}  ${P_PASSWORD}  2  countryCode=${country_code}
    # Should Be Equal As Strings  ${resp[0].status_code}  404
    # Should Be Equal As Strings  ${resp[1].status_code}  404

*** Comment ***
JD-TC-ResetPassword-UH5
    Comment    Reset password using non verified email
    ${resp}=  SendProviderResetMail  ${PUSERNAME3} 
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}  Sorry, you are not a registered user
