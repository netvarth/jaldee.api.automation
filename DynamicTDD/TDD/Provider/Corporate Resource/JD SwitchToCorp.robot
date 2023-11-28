*** Settings ***
Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      Corporate
Library         Collections
Library         String
Library         json
Library         FakerLibrary
Library         /ebs/TDD/db.py
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Test Cases ***

JD-TC-SwitchToCorp-1
	[Documentation]  Create corporate for a valid provider.

    #clear_corporate   cause
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200

*** Comment ***

    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Suite Variable  ${domain1}  ${domresp.json()[${pos}]['domain']}

        ${subdomain1}=  Get Corporate Subdomain  ${domain1}  ${domresp}  ${pos}  
        Set Suite Variable   ${subdomain1}
        Exit For Loop IF    '${subdomain}'

    END
    
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_Z}=  Evaluate  ${PUSERNAME}+4512     
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_Z}${\n}
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain1}  ${subdomain1}  ${PUSERNAME_Z}   ${pkg_id[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_Z}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_Z}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${PUSERNAME_Z}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    ${corp_name}=   FakerLibrary.word
    Set Suite Variable  ${corp_name}
    ${corp_code}=   FakerLibrary.word
    Set Suite Variable  ${corp_code}
    ${resp}=  Switch To Corporate  ${corp_name}  ${corp_code}  ${bool[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

JD-TC-SwitchToCorp-2
	[Documentation]  Create corporate with multilevel set to false.

    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_B}=  Evaluate  ${PUSERNAME}+7788    
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_B}${\n}
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain1}  ${subdomain1}  ${PUSERNAME_B}   ${pkg_id[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_B}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_B}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${PUSERNAME_B}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    ${corp_name1}=   FakerLibrary.word
    ${corp_code1}=   FakerLibrary.word
    ${resp}=  Switch To Corporate  ${corp_name1}  ${corp_code1}  ${bool[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

JD-TC-SwitchToCorp-3
	[Documentation]  Create same corporate (with same code) for multiple providers.

    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+6694    
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_A}${\n}
    ${resp}=  Get Licensable Packages
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${pkg}    ${resp.json()[2]['pkgId']}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain1}  ${subdomain1}  ${PUSERNAME_A}   ${pkg}
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
    ${corp_name1}=   FakerLibrary.word
    ${resp}=  Switch To Corporate  ${corp_name1}  ${corp_code}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-SwitchToCorp-4
	[Documentation]  Create same corporate (with same name) for multiple providers.

    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+6689     
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_A}${\n}
    ${resp}=  Get Licensable Packages
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${pkg}    ${resp.json()[2]['pkgId']}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain1}  ${subdomain1}  ${PUSERNAME_A}   ${pkg}
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
    ${corp_code1}=   FakerLibrary.word
    ${resp}=  Switch To Corporate  ${corp_name}  ${corp_code1}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
JD-TC-SwitchToCorp-UH1
	[Documentation]  Create corporate without name.

    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+6210     
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_A}${\n}
    ${resp}=  Get Licensable Packages
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${pkg}    ${resp.json()[2]['pkgId']}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain1}  ${subdomain1}  ${PUSERNAME_A}   ${pkg}
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
    ${corp_code1}=   FakerLibrary.word
    ${resp}=  Switch To Corporate  ${EMPTY}  ${corp_code1}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}        "${CORPORATE_NAME}" 

JD-TC-SwitchToCorp-UH2
	[Documentation]  Create multiple corporate for a valid provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    ${corp_name1}=   FakerLibrary.word
    ${corp_code1}=   FakerLibrary.word
    ${resp}=  Switch To Corporate  ${corp_name1}  ${corp_code1}  ${bool[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422 
    Should Be Equal As Strings    ${resp.json()}      "${ALREADY_CORPORATE}"

JD-TC-SwitchToCorp-UH3
	[Documentation]  Create corporate for a non corporatble provider

    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200

    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Suite Variable  ${domain2}  ${domresp.json()[${pos}]['domain']}
        
        ${subdomain2}=  Get Non-Corporate Subdomain  ${domain2}  ${domresp}  ${pos}  
        Set Suite Variable   ${subdomain2}
        Exit For Loop IF    '${subdomain}'

    END
    
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+4518   
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_C}${\n}
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain2}  ${subdomain2}  ${PUSERNAME_C}   ${pkg_id[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_C}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_C}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${PUSERNAME_C}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    ${corp_name}=   FakerLibrary.word
    ${corp_code}=   FakerLibrary.word
    ${resp}=  Switch To Corporate  ${corp_name}  ${corp_code}  ${bool[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422 
    Should Be Equal As Strings    ${resp.json()}        "${CORP_NOT_SUPPORTED}" 

JD-TC-SwitchToCorp-UH4
	[Documentation]  Create Corporate by consumer login

    ${resp}=  Consumer Login   ${CUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Switch To Corporate  ${corp_name}  ${corp_code}  ${bool[1]}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    "${LOGIN_NO_ACCESS_FOR_URL}" 

JD-TC-SwitchToCorp-UH5
	[Documentation]  Create Corporate without login

    ${resp}=  Switch To Corporate  ${corp_name}  ${corp_code}  ${bool[1]}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    "${SESSION_EXPIRED}"

***Keywords***

Get Corporate Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Test Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Should Be Equal As Strings    ${resp.status_code}    200
            Exit For Loop IF  '${resp.json()['isCorp']}' == '${bool[1]}'
    END
    [Return]  ${subdomain}  

Get Non-Corporate Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Test Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Should Be Equal As Strings    ${resp.status_code}    200
            Exit For Loop IF  '${resp.json()['isCorp']}' == '${bool[0]}'
    END
    [Return]  ${subdomain}  