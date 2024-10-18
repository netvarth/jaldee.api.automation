*** Settings ***
Suite Teardown  Delete All Sessions
Force Tags      SA Login
Library         Collections
Library         String
Library         json
Library         /ebs/TDD/db.py
Library         FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Resource        /ebs/TDD/SuperAdminKeywords.robot
Resource        /ebs/TDD/ProviderKeywords.robot


*** Variables ***
${REST_SUPER_URL}      http://${SA_HOSTED_IP}/v1/rest/superadmin
# v1/rest/superadmin
*** Keywords ***

SuperAdmin Login
    [Arguments]    ${usname}  ${passwrd}  &{kwargs}
    ${pass2}=  Keywordspy.second_password
    ${log}=  Login  ${usname}  ${passwrd}  secondPassword=${pass2}
    # ${login}=    Create Dictionary    loginId=${usname}  password=${passwrd}  secondPassword=${pass2}
    # ${log}=    json.dumps    ${login}
    Create Session    synw    ${SUPER_URL}  headers=${headers}   verify=true
    ${resp}=    POST On Session     synw    /login    data=${log}   expected_status=any 
    Check Deprication  ${resp}  SuperAdmin Login   
    RETURN  ${resp}


Login As Provider
    [Arguments]    ${usname}  ${passwrd}  &{kwargs}
    # ${pass2}=  Keywordspy.second_password
    ${log}=  Login  ${usname}  ${passwrd}  &{kwargs}
    # ${log}=    json.dumps    ${login}
    Create Session    saynw    ${REST_SUPER_URL}  headers=${headers}   verify=true
    ${resp}=    POST On Session     saynw    /login    data=${log}   expected_status=any 
    Check Deprication  ${resp}  SuperAdmin Login   
    RETURN  ${resp}

# {"countryCode":"+91","loginId":"admin.support@jaldee.com","password":"Netvarth1","accountId":"395"}

*** Test Cases ***

JD-TC-SA_Login-1
    [Documentation]    SA Login
    ${resp}=   SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-SA_Login-2
    [Documentation]    Login as provider

    # ${resp}=   SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Login As Provider  ${SUSERNAME}  ${SPASSWORD}  accountId=395  #countryCode=+91
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Provider_Login-2
    [Documentation]    Provider

    ${resp}=  Encrypted Provider Login  2220781051  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200