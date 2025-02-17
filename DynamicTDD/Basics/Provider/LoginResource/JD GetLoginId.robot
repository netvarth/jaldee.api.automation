*** Settings ***
Suite Teardown    Delete All Sessions
Force Tags      Encrypted Provider Login
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
      
${withsym}      *#147erd
${onlyspl}      !@#$%^&.-
${alph_digits}  D3r52A
${withus}       Abc_1234
${withat}       ABC@12
${withdot}      ABC.12
${withatanuc}  ABC_@12
${ucafterat}   ABC@_d
${validpasswithsym}    ABCD1234@
${lesspass}     ABCD123
${validpass}    ABCD1234

*** Test Cases ***

JD-TC-Get_LoginId-1

    [Documentation]    Get login Id

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

    ${ph}=  Evaluate  ${PUSERNAME}+5666409
    Set Suite Variable  ${ph}
    ${firstname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable      ${firstname}
    Set Suite Variable      ${lastname}

    ${highest_package}=  get_highest_license_pkg

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph}   ${highest_package[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId}=     Random Int  min=1111  max=9999
    Set Suite Variable      ${loginId}
    
    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable      ${id}  ${decrypted_data['id']}
    Set Suite Variable      ${userName}  ${decrypted_data['userName']}

    ${resp}=    Get LoginId  ${id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200 
    Should Be Equal As Strings      ${resp.json()}      ${loginId}

    ${loginId_n}=     Random Int  min=1111  max=9999
    Set Suite Variable      ${loginId_n}

    ${resp}=    Reset LoginId  ${id}  ${loginId_n}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get LoginId  ${id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200 
    Should Be Equal As Strings      ${resp.json()}      ${loginId_n}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Get_LoginId-2

    [Documentation]    Get login Id - where user id is invalid

    ${resp}=  Encrypted Provider Login  ${loginId_n}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     Random Int  min=88888888  max=99999999

    ${resp}=    Get LoginId  ${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings      ${resp.json()}      ${INV_USER_ID}

JD-TC-Get_LoginId-3

    [Documentation]    Get login Id - without login

    ${resp}=    Get LoginId  ${id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

        