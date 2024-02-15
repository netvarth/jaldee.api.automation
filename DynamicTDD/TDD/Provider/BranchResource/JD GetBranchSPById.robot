*** Settings ***
Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      Branch
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

JD-TC-GetBranchSP-1
	[Documentation]  Get Branch SP for a valid provider

	${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200

*** Comment ***

    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Suite Variable  ${domain}  ${domresp.json()[${pos}]['domain']}

        ${subdomain}=  Get Corporate Subdomain  ${domain}  ${domresp}  ${pos}  
        Set Suite Variable   ${subdomain}
        Exit For Loop IF    '${subdomain}'

    END
    
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_Z}=  Evaluate  ${PUSERNAME}+4522     
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME_Z}${\n}
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
	Set Suite Variable  ${branch_id}  ${resp.json()}

    ${resp}=  Toggle Department Enable
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name1}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name1}
    ${dep_code1}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code1}
    ${dep_desc1}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc1}
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid1}  ${resp.json()}

	${f_name}=  	 FakerLibrary.first_name
    ${l_name}=  	 FakerLibrary.last_name
	${email}=   	 Set Variable  ${P_Email}${PUSERNAME_Z}.${test_mail}
    ${PHONE1}=  Evaluate  ${PUSERNAME}+7711
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PHONE1}${\n}

	${resp}=   Create Branch SP  ${f_name}  ${l_name}  ${PHONE1}   ${email}  ${subdomain}  ${PASSWORD}   ${depid1}
	Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=   Get Branch SP By Id  ${branch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  2
    Should Be Equal As Strings  ${resp.json()[0]['serviceSector']['domain']}             ${domain}
    Should Be Equal As Strings  ${resp.json()[0]['serviceSubSector']['subDomain']}       ${subdomain}
    Should Be Equal As Strings  ${resp.json()[0]['status']}                              ${status[1]}
    Should Be Equal As Strings  ${resp.json()[0]['accountType']}                         BRANCH_SP
    Should Be Equal As Strings  ${resp.json()[1]['serviceSector']['domain']}             ${domain}
    Should Be Equal As Strings  ${resp.json()[1]['serviceSubSector']['subDomain']}       ${subdomain}
    Should Be Equal As Strings  ${resp.json()[1]['status']}                              ${status[1]}
    Should Be Equal As Strings  ${resp.json()[1]['accountType']}                         BRANCH

JD-TC-GetBranchSP-UH1
	[Documentation]  Get another providers Branch SP 

    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+4523     
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME_A}${\n}
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
	Set Suite Variable  ${corp_id}  ${resp.json()}

    ${resp}=  Toggle Department Enable
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name2}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name2}
    ${dep_code2}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code2}
    ${dep_desc2}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc2}
    ${resp}=  Create Department  ${dep_name2}  ${dep_code2}  ${dep_desc2}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid2}  ${resp.json()}

	${f_name}=  	 FakerLibrary.first_name
    ${l_name}=  	 FakerLibrary.last_name
	${email}=   	 Set Variable  ${P_Email}${PUSERNAME_A}.${test_mail}
    ${PHONE1}=  Evaluate  ${PUSERNAME}+7721
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PHONE1}${\n}
    
	${resp}=   Create Branch SP  ${f_name}  ${l_name}  ${PHONE1}  ${email}  ${subdomain}  ${PASSWORD}  ${depid2}
	Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    Set Suite Variable    ${branch_id1}   ${resp.json()}

    ${resp}=   Get Branch SP By Id  ${branch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422 
    Should Be Equal As Strings  "${resp.json()}"     "${NO_PERMISSION}"

JD-TC-GetBranchSP-UH2
	[Documentation]  Get Branch SP with invalid branch id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=   Get Branch SP By Id  000
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"     "${BRANCH_NOT_FOUND}"

JD-TC-GetBranchSP-UH3
	[Documentation]  Get Branch SP by consumer login

    ${resp}=  Consumer Login   ${CUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Branch SP By Id  ${branch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"    	 "${LOGIN_NO_ACCESS_FOR_URL}" 

JD-TC-GetBranchSP-UH4
	[Documentation]  Get Branch SP without login

    ${resp}=   Get Branch SP By Id  ${branch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings  "${resp.json()}"    	 "${SESSION_EXPIRED}"



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
    RETURN  ${subdomain}  

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
