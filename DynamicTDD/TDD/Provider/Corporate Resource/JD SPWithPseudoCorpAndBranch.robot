** Settings ***
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

JD-TC-CreateSPwithPseudoCorpandBranch-1
	[Documentation]  create SP with pseudo corp and branch

	${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200

*** Comments ***

    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Suite Variable  ${domain}  ${domresp.json()[${pos}]['domain']}

        ${subdomain}=  Get Corporate Subdomain  ${domain}  ${domresp}  ${pos}  
        Set Suite Variable   ${subdomain}
        Exit For Loop IF    '${subdomain}'

    END
    
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_Z}=  Evaluate  ${PUSERNAME}+4520     
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

	${f_name}=  	 FakerLibrary.first_name
    ${l_name}=  	 FakerLibrary.last_name
	${city}=   		 get_place
	${state}=   	 get_place
    ${address}=  	 FakerLibrary.address
    ${dob}=  		 FakerLibrary.Date
    ${gender}    	 Random Element    ${Genderlist}
    ${code}=         FakerLibrary.word
	${email}=   	 Set Variable  ${P_Email}${code}.${test_mail}
    ${PHONE1}=  Evaluate  ${PUSERNAME}+9452 
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PHONE1}${\n}
    ${PHONE11}=  Evaluate  ${PUSERNAME}+7578     
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PHONE11}${\n}
	${resp}=   Create SP With Pseudo Corp and Branch  ${f_name}  ${l_name}  ${city}  ${state}  ${address}  ${PHONE1}  ${PHONE11}  ${dob}  ${gender}  ${email}   ${subdomain}  ${PASSWORD}
	Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

JD-TC-CreateSPwithPseudoCorpandBranch-2
	[Documentation]  create Multiple SPs 

	${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

	${f_name}=  	 FakerLibrary.first_name
    ${l_name}=  	 FakerLibrary.last_name
	${city}=   		 get_place
	${state}=   	 get_place
    ${address}=  	 FakerLibrary.address
    ${dob}=  		 FakerLibrary.Date
    ${gender}    	 Random Element    ${Genderlist}
    ${code}=         FakerLibrary.word
	${email}=   	 Set Variable  ${P_Email}${code}.${test_mail}
    ${PHONE1}=  Evaluate  ${PUSERNAME}+1302 
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PHONE1}${\n}
    ${PHONE11}=  Evaluate  ${PUSERNAME}+7578     
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PHONE11}${\n}
	${resp}=   Create SP With Pseudo Corp and Branch  ${f_name}  ${l_name}  ${city}  ${state}  ${address}  ${PHONE1}  ${PHONE11}  ${dob}  ${gender}  ${email}   ${subdomain}  ${PASSWORD}
	Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

JD-TC-CreateSPwithPseudoCorpandBranch-3
	[Documentation]  create Pseudo Corp and Branch by branch provider.

	${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_Z}=  Evaluate  ${PUSERNAME}+4590     
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

	${f_name}=  	 FakerLibrary.first_name
    ${l_name}=  	 FakerLibrary.last_name
	${city}=   		 get_place
	${state}=   	 get_place
    ${address}=  	 FakerLibrary.address
    ${dob}=  		 FakerLibrary.Date
    ${gender}    	 Random Element    ${Genderlist}
    ${code}=         FakerLibrary.word
	${email}=   	 Set Variable  ${P_Email}${code}.${test_mail}
    ${PHONE1}=  Evaluate  ${PUSERNAME}+1355
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PHONE1}${\n}
    ${PHONE11}=  Evaluate  ${PUSERNAME}+7578     
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PHONE11}${\n}
	${resp}=   Create SP With Pseudo Corp and Branch  ${f_name}  ${l_name}  ${city}  ${state}  ${address}  ${PHONE1}  ${PHONE11}  ${dob}  ${gender}  ${email}   ${subdomain}  ${PASSWORD}
	Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
JD-TC-CreateSPwithPseudoCorpandBranch-UH1
	[Documentation]  create Branch SPs for a non-corporatable provider

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
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+4577     
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
    Set Suite Variable  ${PUSERNAME_A}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

	${f_name}=  	 FakerLibrary.first_name
    ${l_name}=  	 FakerLibrary.last_name
	${city}=   		 get_place
	${state}=   	 get_place
    ${address}=  	 FakerLibrary.address
    ${dob}=  		 FakerLibrary.Date
    ${gender}    	 Random Element    ${Genderlist}
    ${code}=         FakerLibrary.word
	${email}=   	 Set Variable  ${P_Email}${code}.${test_mail}
    ${PHONE1}=  Evaluate  ${PUSERNAME}+8002 
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PHONE1}${\n}
    ${PHONE11}=  Evaluate  ${PUSERNAME}+7578     
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PHONE11}${\n}
	${resp}=   Create SP With Pseudo Corp and Branch  ${f_name}  ${l_name}  ${city}  ${state}  ${address}  ${PHONE1}  ${PHONE11}  ${dob}  ${gender}  ${email}   ${subdomain}  ${PASSWORD}
	Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422

JD-TC-CreateSPwithPseudoCorpandBranch-UH2
	[Documentation]  Join to Corporate by consumer login

    ${resp}=  Consumer Login   ${CUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${f_name}=  	 FakerLibrary.first_name
    ${l_name}=  	 FakerLibrary.last_name
	${city}=   		 get_place
	${state}=   	 get_place
    ${address}=  	 FakerLibrary.address
    ${dob}=  		 FakerLibrary.Date
    ${gender}    	 Random Element    ${Genderlist}
    ${code}=         FakerLibrary.word
	${email}=   	 Set Variable  ${P_Email}${city}.${test_mail}
    ${PHONE1}=  Evaluate  ${PUSERNAME}+1998 
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PHONE1}${\n}
    ${PHONE11}=  Evaluate  ${PUSERNAME}+7578     
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PHONE11}${\n}
	${resp}=   Create SP With Pseudo Corp and Branch  ${f_name}  ${l_name}  ${city}  ${state}  ${address}  ${PHONE1}  ${PHONE11}  ${dob}  ${gender}  ${email}   ${subdomain}  ${PASSWORD}
	Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    	 "${LOGIN_NO_ACCESS_FOR_URL}" 

JD-TC-CreateSPwithPseudoCorpandBranch-UH3
	[Documentation]  Join to Corporate without login

    ${f_name}=  	 FakerLibrary.first_name
    ${l_name}=  	 FakerLibrary.last_name
	${city}=   		 get_place
	${state}=   	 get_place
    ${address}=  	 FakerLibrary.address
    ${dob}=  		 FakerLibrary.Date
    ${gender}    	 Random Element    ${Genderlist}
    ${code}=         FakerLibrary.word
	${email}=   	 Set Variable  ${P_Email}${code}.${test_mail}
    ${PHONE1}=  Evaluate  ${PUSERNAME}+5443 
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PHONE1}${\n}
    ${PHONE11}=  Evaluate  ${PUSERNAME}+7578     
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PHONE11}${\n}
	${resp}=   Create SP With Pseudo Corp and Branch  ${f_name}  ${l_name}  ${city}  ${state}  ${address}  ${PHONE1}  ${PHONE11}  ${dob}  ${gender}  ${email}   ${subdomain}  ${PASSWORD}
	Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    	 "${SESSION_EXPIRED}"

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
