*** Settings ***
Suite Teardown    Delete All Sessions
Force Tags        Provider Login
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
      
${withsym}      *#147erd
${onlyspl}      !@#$%^&
${alph_digits}  D3r52A

*** Test Cases ***

JD-TC-Provider_Login-1

    [Documentation]    Provider Login - with valid details

    ${domresp}=  Get BusinessDomainsConf
    Log  ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${domain_list}=  Create List
    ${subdomain_list}=  Create List
    FOR  ${domindex}  IN RANGE  ${len}
        Set Test Variable  ${d}  ${domresp.json()[${domindex}]['domain']}    
        Append To List  ${domain_list}    ${d} 
        Set Test Variable  ${sd}  ${domresp.json()[${domindex}]['subDomains'][0]['subDomain']}
        Append To List  ${subdomain_list}    ${sd} 
    END
    Log  ${domain_list}
    Log  ${subdomain_list}
    Set Suite Variable  ${domain_list}
    Set Suite Variable  ${subdomain_list}
    ${ph}=  Evaluate  ${PUSERNAME}+5666400
    Set Suite Variable  ${ph}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable      ${firstname}
    Set Suite Variable      ${lastname}

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId}=     Random Int  min=1  max=9999
    Set Suite Variable      ${loginId}
    
    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph}${\n}

JD-TC-Provider_Login-UH1

    [Documentation]    Provider Login - where session alrady exists

    ${resp}=  Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings   ${resp.json()}         ${LOGIN_SESSION_ALREADY_EXISTS}

JD-TC-Provider_Login-UH2

    [Documentation]    Provider Login - where login id is empty

    ${resp}=  Provider Login  ${empty}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}         ${ENTER_LOGIN_ID}

JD-TC-Provider_Login-UH3

    [Documentation]    Provider Login - not signed up

    ${ph2}=  Evaluate  ${PUSERNAME}+566457

    ${resp}=  Provider Login  ${ph2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings   ${resp.json()}         ${LOGINID_NOT_REGISTERED}

JD-TC-Provider_Login-UH4

    [Documentation]    Provider Login - where password is empty

    ${resp}=  Provider Login  ${loginId}  ${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings   ${resp.json()}         ${PASSWORD_EMPTY}