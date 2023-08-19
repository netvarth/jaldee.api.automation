*** Settings ***
Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      Branch
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

*** Variables ***
${SERVICE1}	   Bridal Makeup_001
${SERVICE2}	   Groom MakeupW_002

*** Test Cases ***

JD-TC-CreateBranchSP-1
	[Documentation]  create Branch SP for a valid provider

	${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    
*** Comment ***

    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Suite Variable  ${domain}  ${domresp.json()[${pos}]['domain']}

        ${subdomain}  ${subdomain_id}=  Get Corporate Subdomain  ${domain}  ${domresp}  ${pos}  
        Set Suite Variable   ${subdomain}
        Exit For Loop IF    '${subdomain}'

    END
    
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_Z}=  Evaluate  ${PUSERNAME}+4521     
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_Z}${\n}
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
    ${resp}=  Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
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
    ${ser_desc}=   FakerLibrary.word
    Set Suite Variable   ${ser_desc}
    ${total_amount}=    Random Int  min=100  max=500
    Set Suite Variable  ${total_amount}
    ${min_prepayment}=  Random Int   min=1   max=50
    Set Suite Variable   ${min_prepayment}
    ${ser_duratn}=      Random Int   min=10   max=30
    Set Suite Variable   ${ser_duratn}
    ${resp}=   Create Service  ${SERVICE1}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE2}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid2}  ${resp.json()} 
    ${resp}=  Toggle Department Enable
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name1}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name1}
    ${dep_code1}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code1}
    ${dep_desc1}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc1}
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}   ${sid1}  ${sid2}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid1}  ${resp.json()}
	${f_name}=  	 FakerLibrary.first_name
    ${l_name}=  	 FakerLibrary.last_name	
	${email}=   	 Set Variable  ${P_Email}${PUSERNAME_Z}.${test_mail}
    ${PHONE1}=  Evaluate  ${PUSERNAME}+7777 
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PHONE1}${\n}
	${resp}=   Create Branch SP  ${f_name}  ${l_name}  ${PHONE1}   ${email}  ${subdomain}  ${PASSWORD}  ${dep_code1}
	Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    
    ${resp}=   Get Branch SP By Id  ${branch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

JD-TC-CreateBranchSP-2
	[Documentation]  create Multiple Branch SPs

	${resp}=  Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

	${f_name}=  	 FakerLibrary.first_name
    ${l_name}=  	 FakerLibrary.last_name
	${email}=   	 Set Variable  ${P_Email}${PUSERNAME2}.${test_mail}
    ${PHONE2}=  Evaluate  ${PUSERNAME}+7710    
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PHONE2}${\n}
	${resp}=   Create Branch SP  ${f_name}  ${l_name}  ${PHONE2}  ${email}  ${subdomain}  ${PASSWORD}  ${dep_code1}
	Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=   Get Branch SP By Id  ${branch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

JD-TC-CreateBranchSP-3
	[Documentation]  create Branch SP with non corporatable subdomain within the corporatable domain.

    ${resp}=  Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200

    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Suite Variable  ${domain1}  ${domresp.json()[${pos}]['domain']}

        ${subdomain1}=  Get Non-Corporate Subdomain  ${domain1}  ${domresp}  ${pos}  
        Set Suite Variable   ${subdomain1}
        Exit For Loop IF    '${subdomain1}'

    END

    ${f_name}=  	 FakerLibrary.first_name
    ${l_name}=  	 FakerLibrary.last_name
	${email}=   	 Set Variable  ${P_Email}${PUSERNAME1}.${test_mail}
    ${PHONE2}=  Evaluate  ${PUSERNAME}+7720    
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PHONE2}${\n}
	${resp}=   Create Branch SP  ${f_name}  ${l_name}  ${PHONE2}  ${email}  ${subdomain1}  ${PASSWORD}   ${dep_code1}
	Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

JD-TC-CreateBranchSP-4
	[Documentation]  create Branch SP and login as Branch SP.

    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_Z}=  Evaluate  ${PUSERNAME}+4500     
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_Z}${\n}
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain}  ${subdomain}  ${PUSERNAME_Z}   ${pkg_id[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_Z}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_Z}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
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
    ${dep_name2}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name2}
    ${dep_code2}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code2}
    ${dep_desc2}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc2}
    ${resp}=  Create Department  ${dep_name2}  ${dep_code2}  ${dep_desc2}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid2}  ${resp.json()}
    ${PHONE1}=  Evaluate  ${PUSERNAME}+33422 
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PHONE1}${\n}
	${f_name}=  	 FakerLibrary.first_name
    ${l_name}=  	 FakerLibrary.last_name
	${email}=   	 Set Variable  ${P_Email}${PHONE1}.${test_mail}
    
	${resp}=   Create Branch SP  ${f_name}  ${l_name}  ${PHONE1}  ${email}  ${subdomain}  ${PASSWORD}  ${dep_code2}
	Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    
    ${resp}=  Provider Login  ${PHONE1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateBranchSP-5
	[Documentation]  Join to corp and creat branch SP.

    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200

    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Test Variable  ${domain}     ${domresp.json()[${pos}]['domain']}
        Set Test Variable  ${domain_id}  ${domresp.json()[${pos}]['id']}

        ${subdomain}   ${subdomain_id}=  Get Corporate Subdomain  ${domain}  ${domresp}  ${pos}  
        Set Test Variable    ${subdomain}
        Set Test Variable    ${subdomain_id}
        Exit For Loop IF    '${subdomain}'

    END
    
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_Z}=  Evaluate  ${PUSERNAME}+4536   
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_Z}${\n}
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain}  ${subdomain}  ${PUSERNAME_Z}   ${pkg_id[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_Z}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_Z}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

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
    ${email}=   FakerLibrary.email
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
    
    ${resp}=  Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=   Join to Corporate  ${corp_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Toggle Department Enable
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name3}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name3}
    ${dep_code3}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code3}
    ${dep_desc3}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc3}
    ${resp}=  Create Department  ${dep_name3}  ${dep_code3}  ${dep_desc3}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid3}  ${resp.json()}

    ${f_name}=  	 FakerLibrary.first_name
    ${l_name}=  	 FakerLibrary.last_name
    ${PHONE1}=  Evaluate  ${PUSERNAME}+3147
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PHONE1}${\n}
	${email}=   Set Variable  ${P_Email}${PHONE1}.${test_mail}
    
	${resp}=   Create Branch SP  ${f_name}  ${l_name}  ${PHONE1}  ${email}  ${subdomain}  ${PASSWORD}  ${dep_code3}
	Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

JD-TC-CreateBranchSP-UH1
	[Documentation]  create Branch SP with same phone number of another branch phone number.

    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200

    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Test Variable  ${domain}  ${domresp.json()[${pos}]['domain']}

        ${subdomain2}  ${subdomain_id}=  Get Corporate Subdomain  ${domain}  ${domresp}  ${pos}  
        Set Suite Variable   ${subdomain2}
        Exit For Loop IF    '${subdomain2}'

    END
    
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+4525     
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_A}${\n}
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain}  ${subdomain2}  ${PUSERNAME_A}   ${pkg_id[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_A}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
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
    ${dep_name4}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name4}
    ${dep_code4}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code4}
    ${dep_desc4}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc4}
    ${resp}=  Create Department  ${dep_name4}  ${dep_code4}  ${dep_desc4}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid4}  ${resp.json()}

    ${f_name}=  	 FakerLibrary.first_name
    ${l_name}=  	 FakerLibrary.last_name
	${email}=   	 Set Variable  ${P_Email}${PUSERNAME10}.${test_mail}
    ${PHONE2}=  Evaluate  ${PUSERNAME}+7720    
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PHONE2}${\n}
	${resp}=   Create Branch SP  ${f_name}  ${l_name}  ${PHONE2}  ${email}  ${subdomain2}  ${PASSWORD}   ${dep_code4}
	Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"        "${MOBILE_NO_USED}"

JD-TC-CreateBranchSP-UH2
	[Documentation]  create Branch SP with subdomain in different domain.

    ${resp}=  Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${d1}  ${resp.json()[1]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[1]['subDomains'][0]['subDomain']}

    ${f_name}=  	 FakerLibrary.first_name
    ${l_name}=  	 FakerLibrary.last_name
	${email}=   	 Set Variable  ${P_Email}${PUSERNAME3}.${test_mail}
    ${PHONE2}=  Evaluate  ${PUSERNAME}+7731    
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PHONE2}${\n}
	${resp}=   Create Branch SP  ${f_name}  ${l_name}  ${PHONE2}  ${email}  ${sd1}  ${PASSWORD}  ${dep_code1}
	Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${INVALID_SUB_SECTOR}"

JD-TC-CreateBranchSP-UH3
	[Documentation]  create Branch SP with same phone number.

    ${resp}=  Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    ${f_name}=  	 FakerLibrary.first_name
    ${l_name}=  	 FakerLibrary.last_name
	${email}=   	 Set Variable  ${P_Email}${PUSERNAME4}.${test_mail}
    ${PHONE2}=  Evaluate  ${PUSERNAME}+7777    
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PHONE2}${\n}
	${resp}=   Create Branch SP  ${f_name}  ${l_name}  ${PHONE2}  ${email}  ${subdomain1}  ${PASSWORD}  ${dep_code1}
	Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"       "${MOBILE_NO_USED}"

JD-TC-CreateBranchSP-UH4
	[Documentation]  create Branch SP with same email.

    ${resp}=  Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    ${f_name}=  	 FakerLibrary.first_name
    ${l_name}=  	 FakerLibrary.last_name
	${email}=   	 Set Variable  ${P_Email}${PUSERNAME1}.${test_mail}
    ${PHONE2}=  Evaluate  ${PUSERNAME}+7751    
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PHONE2}${\n}
	${resp}=   Create Branch SP  ${f_name}  ${l_name}  ${PHONE2}  ${email}  ${subdomain1}  ${PASSWORD}   ${dep_code1}
	Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${EMAIL_EXISTS}"

JD-TC-CreateBranchSP-UH5
	[Documentation]  Join to Corporate by consumer login

    ${resp}=  Consumer Login   ${CUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${f_name}=  	 FakerLibrary.first_name
    ${l_name}=  	 FakerLibrary.last_name
	${email}=   	 Set Variable  ${P_Email}${PUSERNAME1}.${test_mail}
    ${PHONE2}=  Evaluate  ${PUSERNAME}+7751    
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PHONE2}${\n}
    ${resp}=   Create Branch SP  ${f_name}  ${l_name}  ${PHONE2}  ${email}  ${subdomain1}  ${PASSWORD}  ${dep_code1}
	Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"    	 "${LOGIN_NO_ACCESS_FOR_URL}" 

JD-TC-CreateBranchSP-UH6
	[Documentation]  Join to Corporate without login

    ${f_name}=  	 FakerLibrary.first_name
    ${l_name}=  	 FakerLibrary.last_name
	${email}=   	 Set Variable  ${P_Email}${PUSERNAME1}.${test_mail}
    ${PHONE2}=  Evaluate  ${PUSERNAME}+7751    
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PHONE2}${\n}
    ${resp}=   Create Branch SP  ${f_name}  ${l_name}  ${PHONE2}  ${email}  ${subdomain1}  ${PASSWORD}  ${dep_code1}
	Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings  "${resp.json()}"    	 "${SESSION_EXPIRED}"

JD-TC-CreateBranchSP-UH7
	[Documentation]  create Branch SP without  department id

	${resp}=  Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    ${PHONE2}=  Evaluate  ${PUSERNAME}+7910    
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PHONE2}${\n}
	${f_name}=  	 FakerLibrary.first_name
    ${l_name}=  	 FakerLibrary.last_name
	${email}=   	 Set Variable  ${P_Email}${PHONE2}.${test_mail}
    
	${resp}=   Create Branch SP  ${f_name}  ${l_name}  ${PHONE2}  ${email}  ${subdomain}  ${PASSWORD}  ${EMPTY}
	Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    	 "Department feature needs to enabled to add a doctor"

JD-TC-CreateBranchSP-UH8
	[Documentation]  create Branch SP without department

	${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200

    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Suite Variable  ${domain}  ${domresp.json()[${pos}]['domain']}

        ${subdomain}  ${subdomain_id}=  Get Corporate Subdomain  ${domain}  ${domresp}  ${pos}  
        Set Suite Variable   ${subdomain}
        Exit For Loop IF    '${subdomain}'

    END
    
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_Z}=  Evaluate  ${PUSERNAME}+45255     
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_Z}${\n}
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain}  ${subdomain}  ${PUSERNAME_Z}   ${pkg_id[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_Z}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_Z}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
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
	${email}=   	 Set Variable  ${P_Email}${PUSERNAME_Z}.${test_mail}
    ${PHONE1}=  Evaluate  ${PUSERNAME}+7637 
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PHONE1}${\n}
	${resp}=   Create Branch SP  ${f_name}  ${l_name}  ${PHONE1}   ${email}  ${subdomain}  ${PASSWORD}   ${dep_code1}
	Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422 
    Should Be Equal As Strings  "${resp.json()}"    	 "${INVALID_DEPARTMENT}"


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
    [Return]  ${subdomain}   ${subdomain_id}

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
