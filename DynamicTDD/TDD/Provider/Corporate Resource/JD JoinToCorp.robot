*** Settings ***
Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      Corporate
Library         Collections
Library         String
Library         json
Library         FakerLibrary
Library         /ebs/TDD/db.py
Resource        /ebs/TDD/SuperAdminKeywords.robot
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Test Cases ***

JD-TC-JoinToCorp-1
	[Documentation]  Join to corp for a valid provider

    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200

*** Comments ***

    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Suite Variable  ${domain}     ${domresp.json()[${pos}]['domain']}
        Set Suite Variable  ${domain_id}  ${domresp.json()[${pos}]['id']}

        ${subdomain}   ${subdomain_id}=  Get Corporate Subdomain  ${domain}  ${domresp}  ${pos}  
        Set Suite Variable    ${subdomain}
        Set Suite Variable    ${subdomain_id}
        Exit For Loop IF    '${subdomain}'

    END
    
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_Z}=  Evaluate  ${PUSERNAME}+4536   
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_Z}${\n}
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain}  ${subdomain}  ${PUSERNAME_Z}   ${pkg_id[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_Z}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_Z}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${PUSERNAME_Z}

    ${resp}=  Get Licensable Packages
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${pkg}    ${resp.json()[1]['pkgId']}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${c_name}=  FakerLibrary.word
    Set Test Variable   ${c_name}
    ${c_code}=  FakerLibrary.word
    ${email}=   Set Variable  ${P_Email}${PUSERNAME_Z}.${test_mail}
    clear_corporate   father
    ${resp}=   Create Corporate   ${c_name}  ${c_code}  ${email}  ${PUSERNAME_Z}  ${firstname}  ${lastname}  ${PUSERNAME_Z}  ${pkg}   ${domain_id}   ${subdomain_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${corp_id}  ${resp.json()}

    ${resp}=  Get Corporate  ${corp_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${corp_uid}    ${resp.json()['corporateUid']}
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=   Join to Corporate  ${corp_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

JD-TC-JoinToCorp-2
	[Documentation]  Join to corp for a provider using multiple corporate uids.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${c_name}=  FakerLibrary.word
    Set Test Variable   ${c_name}
    ${c_code}=  FakerLibrary.word
    ${email}=   Set Variable  ${P_Email}${PUSERNAME3}.${test_mail}
    clear_corporate   father
    ${resp}=   Create Corporate   ${c_name}  ${c_code}  ${email}  ${PUSERNAME1}  ${firstname}  ${lastname}  ${PUSERNAME2}  ${pkg}   ${domain_id}   ${subdomain_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${corp_id1}  ${resp.json()}

    ${resp}=  Get Corporate  ${corp_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${corp_uid1}    ${resp.json()['corporateUid']}
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=   Join to Corporate  ${corp_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-JoinToCorp-3
	[Documentation]  Join to corp for a corporatable provider

    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+4002     
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_A}${\n}
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain}  ${subdomain}  ${PUSERNAME_A}   ${pkg_id[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_A}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    ${corp_name}=   FakerLibrary.word
    Set Suite Variable  ${corp_name}
    ${corp_code}=   FakerLibrary.word
    Set Suite Variable  ${corp_code}
    ${resp}=  Switch To Corporate  ${corp_name}  ${corp_code}  ${bool[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=   Join to Corporate  ${corp_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-JoinToCorp-UH1
	[Documentation]  Join to corp for a non corporatable provider

    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200

    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Test Variable  ${domain}  ${domresp.json()[${pos}]['domain']}

        ${subdomain}=  Get Non-Corporate Subdomain  ${domain}  ${domresp}  ${pos}  
        Set Test Variable   ${subdomain}
        Exit For Loop IF    '${subdomain}'

    END
    
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_Z}=  Evaluate  ${PUSERNAME}+7123     
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_Z}${\n}
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain}  ${subdomain}  ${PUSERNAME_Z}   ${pkg_id[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_Z}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_Z}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=   Join to Corporate  ${corp_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}        "${CORP_NOT_SUPPORTED}"

JD-TC-JoinToCorp-UH2
	[Documentation]  Join to corp for a provider who already joined.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=   Join to Corporate  ${corp_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    "${ALREADY_ASSOCIATED_TO_THIS_CORP}"

JD-TC-JoinToCorp-UH3
	[Documentation]  Join to corp with invalid corporate id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=   Join to Corporate  ${corp_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    404
    Should Be Equal As Strings    ${resp.json()}     "${NO_CORPORATE}"


JD-TC-JoinToCorp-UH4
	[Documentation]  switch to corp who already join to corp

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${corp_name1}=   FakerLibrary.word
    ${corp_code1}=   FakerLibrary.word
    ${resp}=  Switch To Corporate  ${corp_name1}  ${corp_code1}  ${bool[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422 
    Should Be Equal As Strings    ${resp.json()}    "${ALREADY_CORPORATE}"

JD-TC-JoinToCorp-UH5
	[Documentation]  Join to Corporate by consumer login

    ${resp}=  Consumer Login   ${CUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Join to Corporate  ${corp_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    "${LOGIN_NO_ACCESS_FOR_URL}" 

JD-TC-JoinToCorp-UH6
	[Documentation]  Join to Corporate without login

    ${resp}=   Join to Corporate  ${corp_uid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    "${SESSION_EXPIRED}"


***Keywords***

Get Corporate Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Test Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            Set Test Variable  ${subdomain_id}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['id']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Should Be Equal As Strings    ${resp.status_code}    200
            Exit For Loop IF  '${resp.json()['isCorp']}' == '${bool[1]}'
    END
    RETURN  ${subdomain}   ${subdomain_id} 

Get Non-Corporate Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Test Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Should Be Equal As Strings    ${resp.status_code}    200
            Exit For Loop IF  '${resp.json()['isCorp']}' == '${bool[0]}'
    END
    RETURN  ${subdomain}  
