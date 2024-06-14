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

JD-TC-UNLINK_ONE_LOGIN-1

    [Documentation]    Unlink Login - link provider 2 and provider 3 after that unlink provider 2

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

    # ........ Provider 1 ..........

    ${ph}=  Evaluate  ${PUSERNAME}+5666478
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

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ........ Provider 2 ..........

    ${ph2}=  Evaluate  ${PUSERNAME}+5667854
    Set Suite Variable  ${ph2}
    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name
    Set Suite Variable      ${firstname2}
    Set Suite Variable      ${lastname2}

    ${resp}=  Account SignUp  ${firstname2}  ${lastname2}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph2}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph2}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId2}=     Random Int  min=1  max=9999
    Set Suite Variable      ${loginId2}
    
    ${resp}=  Account Set Credential  ${ph2}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph}${\n}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ........ Provider 3 ..........

    ${ph3}=  Evaluate  ${PUSERNAME}+5667854
    Set Suite Variable  ${ph3}
    ${firstname3}=  FakerLibrary.first_name
    ${lastname3}=  FakerLibrary.last_name
    Set Suite Variable      ${firstname3}
    Set Suite Variable      ${lastname3}

    ${resp}=  Account SignUp  ${firstname3}  ${lastname3}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph3}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph3}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId3}=     Random Int  min=1  max=9999
    Set Suite Variable      ${loginId3}
    
    ${resp}=  Account Set Credential  ${ph3}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Login  ${loginId3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph}${\n}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Connect with other login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    List all links of a loginId
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]}     ${loginId2}

    ${resp}=    Connect with other login  ${loginId3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    List all links of a loginId
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]}     ${loginId2}
    Should Be Equal As Strings    ${resp.json()[1]}     ${loginId3}

    ${resp}=    Unlink one login  ${loginId2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    List all links of a loginId
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[1]}     ${loginId3}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200