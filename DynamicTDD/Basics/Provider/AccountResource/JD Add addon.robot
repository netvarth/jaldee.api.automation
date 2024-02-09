*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Addon
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/hl_musers.py

*** Variables ***
${nods}  0

*** Test Cases ***

JD-TC-Addaddon-PRE
       [Documentation]    Getting addons metadata
       ${domresp}=  Get BusinessDomainsConf
       Should Be Equal As Strings  ${domresp.status_code}  200
       ${len}=  Get Length  ${domresp.json()}
       ${len}=  Evaluate  ${len}-1
       ${PUSERNAME}=  Evaluate  ${PUSERNAME}+40011222
       Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
       Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
       ${firstname}=  FakerLibrary.first_name
       ${lastname}=  FakerLibrary.last_name
       ${highest_package}=  get_highest_license_pkg
       ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME}   ${highest_package[0]}
       Log  ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Account Activation  ${PUSERNAME}  0
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Account Set Credential  ${PUSERNAME}  ${PASSWORD}  0
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
       Log  ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}    200
       Set Suite Variable  ${PUSERNAME}
       Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME}${\n}  
       clear_Addon  ${PUSERNAME}
       ${up_addons}=   Get upgradable addons
       Log  ${up_addons.json()}
       Should Be Equal As Strings    ${up_addons.status_code}   200
       Set Suite Variable  ${addons}  ${up_addons.json()}  
       ${addon_list}=  addons_all_license_applicable  ${addons}
       Log  ${addon_list}
       Set Suite Variable  ${addon_list}

JD-TC-Addaddon -1
       [Documentation]    Provider Add a addon from first metric and verify addon details
       ${resp}=   Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD} 
       Log  ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=  Add addon  ${addon_list[0][0]['addon_id']}
       Log  ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200
       sleep  3s
       ${resp}=   Get addons auditlog    
       Log  ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200
       Should Be Equal As Strings  ${resp.json()[0]['licPkgOrAddonId']}  ${addon_list[0][0]['addon_id']}
       Should Be Equal As Strings  ${resp.json()[0]['base']}  False
       Should Be Equal As Strings  ${resp.json()[0]['licenseTransactionType']}  New
       Should Be Equal As Strings  ${resp.json()[0]['renewedDays']}  0
       Should Be Equal As Strings  ${resp.json()[0]['type']}  Production
       Should Be Equal As Strings  ${resp.json()[0]['status']}  Active
       Should Be Equal As Strings  ${resp.json()[0]['name']}  ${addon_list[0][0]['addon_name']}

JD-TC-Addaddon -2
       [Documentation]    Provider Add a addon from another metric
       ${resp}=   Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Add addon  ${addon_list[1][0]['addon_id']}
       Log   ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200
       sleep  2s
       ${resp}=   Get addons auditlog
       Should Be Equal As Strings    ${resp.status_code}   200    
       Should Be Equal As Strings  ${resp.json()[0]['licPkgOrAddonId']}  ${addon_list[1][0]['addon_id']}
       Should Be Equal As Strings  ${resp.json()[0]['base']}  False
       Should Be Equal As Strings  ${resp.json()[0]['licenseTransactionType']}  New
       Should Be Equal As Strings  ${resp.json()[0]['renewedDays']}  0
       Should Be Equal As Strings  ${resp.json()[0]['type']}  Production
       Should Be Equal As Strings  ${resp.json()[0]['status']}  Active
       Should Be Equal As Strings  ${resp.json()[0]['name']}  ${addon_list[1][0]['addon_name']}

       Should Be Equal As Strings  ${resp.json()[1]['licPkgOrAddonId']}  ${addon_list[0][0]['addon_id']}
       Should Be Equal As Strings  ${resp.json()[1]['base']}  False
       Should Be Equal As Strings  ${resp.json()[1]['licenseTransactionType']}  New
       Should Be Equal As Strings  ${resp.json()[1]['renewedDays']}  0
       Should Be Equal As Strings  ${resp.json()[1]['type']}  Production
       Should Be Equal As Strings  ${resp.json()[1]['status']}  Active
       Should Be Equal As Strings  ${resp.json()[1]['name']}  ${addon_list[0][0]['addon_name']}
       
JD-TC-Addaddon -3
       [Documentation]   upgrade addon
       ${resp}=   Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=  Add addon  ${addon_list[0][1]['addon_id']}
       Log  ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Get addons auditlog
       Log  ${resp.json()}
       Should Be Equal As Strings   ${resp.status_code}   200
       Should Be Equal As Strings  ${resp.json()[0]['licPkgOrAddonId']}  ${addon_list[0][1]['addon_id']}
       Should Be Equal As Strings  ${resp.json()[0]['base']}  False
       Should Be Equal As Strings  ${resp.json()[0]['licenseTransactionType']}  New
       Should Be Equal As Strings  ${resp.json()[0]['renewedDays']}  0
       Should Be Equal As Strings  ${resp.json()[0]['type']}  Production
       Should Be Equal As Strings  ${resp.json()[0]['status']}  Not_Used
       Should Be Equal As Strings  ${resp.json()[0]['name']}  ${addon_list[0][1]['addon_name']}

       Should Be Equal As Strings  ${resp.json()[1]['licPkgOrAddonId']}  ${addon_list[1][0]['addon_id']}
       Should Be Equal As Strings  ${resp.json()[1]['base']}  False
       Should Be Equal As Strings  ${resp.json()[1]['licenseTransactionType']}  New
       Should Be Equal As Strings  ${resp.json()[1]['renewedDays']}  0
       Should Be Equal As Strings  ${resp.json()[1]['type']}  Production
       Should Be Equal As Strings  ${resp.json()[1]['status']}  Active
       Should Be Equal As Strings  ${resp.json()[1]['name']}  ${addon_list[1][0]['addon_name']}

       Should Be Equal As Strings  ${resp.json()[2]['licPkgOrAddonId']}  ${addon_list[0][0]['addon_id']}
       Should Be Equal As Strings  ${resp.json()[2]['base']}  False
       Should Be Equal As Strings  ${resp.json()[2]['licenseTransactionType']}  New
       Should Be Equal As Strings  ${resp.json()[2]['renewedDays']}  0
       Should Be Equal As Strings  ${resp.json()[2]['type']}  Production
       Should Be Equal As Strings  ${resp.json()[2]['status']}  Active
       Should Be Equal As Strings  ${resp.json()[2]['name']}  ${addon_list[0][0]['addon_name']}

JD-TC-Addaddon -UH1
       [Documentation]   downgrade addon 
       ${resp}=   Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=  Add addon  ${addon_list[0][0]['addon_id']}
       Log  ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200
       # Should Be Equal As Strings   "${resp.json()}"   "${PROVIDER_CANNOT_DOWNGRADE_ADDON}"
       ${resp}=   Get addons auditlog
       Should Be Equal As Strings   ${resp.status_code}   200

       Should Be Equal As Strings  ${resp.json()[0]['licPkgOrAddonId']}  ${addon_list[0][0]['addon_id']}
       Should Be Equal As Strings  ${resp.json()[0]['base']}  False
       Should Be Equal As Strings  ${resp.json()[0]['licenseTransactionType']}  New
       Should Be Equal As Strings  ${resp.json()[0]['renewedDays']}  0
       Should Be Equal As Strings  ${resp.json()[0]['type']}  Production
       Should Be Equal As Strings  ${resp.json()[0]['status']}  Not_Used
       Should Be Equal As Strings  ${resp.json()[0]['name']}  ${addon_list[0][0]['addon_name']}

       Should Be Equal As Strings  ${resp.json()[1]['licPkgOrAddonId']}  ${addon_list[0][1]['addon_id']}
       Should Be Equal As Strings  ${resp.json()[1]['base']}  False
       Should Be Equal As Strings  ${resp.json()[1]['licenseTransactionType']}  New
       Should Be Equal As Strings  ${resp.json()[1]['renewedDays']}  0
       Should Be Equal As Strings  ${resp.json()[1]['type']}  Production
       Should Be Equal As Strings  ${resp.json()[1]['status']}  Not_Used
       Should Be Equal As Strings  ${resp.json()[1]['name']}  ${addon_list[0][1]['addon_name']}

       Should Be Equal As Strings  ${resp.json()[2]['licPkgOrAddonId']}  ${addon_list[1][0]['addon_id']}
       Should Be Equal As Strings  ${resp.json()[2]['base']}  False
       Should Be Equal As Strings  ${resp.json()[2]['licenseTransactionType']}  New
       Should Be Equal As Strings  ${resp.json()[2]['renewedDays']}  0
       Should Be Equal As Strings  ${resp.json()[2]['type']}  Production
       Should Be Equal As Strings  ${resp.json()[2]['status']}  Active
       Should Be Equal As Strings  ${resp.json()[2]['name']}  ${addon_list[1][0]['addon_name']}

       Should Be Equal As Strings  ${resp.json()[3]['licPkgOrAddonId']}  ${addon_list[0][0]['addon_id']}
       Should Be Equal As Strings  ${resp.json()[3]['base']}  False
       Should Be Equal As Strings  ${resp.json()[3]['licenseTransactionType']}  New
       Should Be Equal As Strings  ${resp.json()[3]['renewedDays']}  0
       Should Be Equal As Strings  ${resp.json()[3]['type']}  Production
       Should Be Equal As Strings  ${resp.json()[3]['status']}  Active
       Should Be Equal As Strings  ${resp.json()[3]['name']}  ${addon_list[0][0]['addon_name']}
                                 
JD-TC-Addaddon -UH2
       [Documentation]   Provider check to add invalid addon to an account
       ${resp}=   Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=  Add addon   0
       Should Be Equal As Strings    ${resp.status_code}   422
       Should Be Equal As Strings  "${resp.json()}"  "${INVALID_ADDON}"
       
JD-TC-Addaddon -UH3  
       [Documentation]   Provider check to add addon to an account without login  
       ${resp}=  Add addon   ${addon_list[0][0]['addon_id']}
       Should Be Equal As Strings    ${resp.status_code}   419
       Should Be Equal As Strings   ${resp.json()}    ${SESSION_EXPIRED}
       
 
JD-TC-Addaddon -UH4
       [Documentation]   Consumer check to add addon to an account
       ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Add addon   ${addon_list[0][0]['addon_id']}
       Should Be Equal As Strings    ${resp.status_code}   401
       Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-Addaddon -UH5
       [Documentation]   Provider adding already added addon
       ${resp}=   Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=  Add addon   ${addon_list[1][0]['addon_id']}
       Log  ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200

       ${resp}=   Get addons auditlog
       Log  ${resp.json()}
       Should Be Equal As Strings   ${resp.status_code}   200
       Should Be Equal As Strings  ${resp.json()[0]['licPkgOrAddonId']}  ${addon_list[1][0]['addon_id']}
       Should Be Equal As Strings  ${resp.json()[0]['base']}  False
       Should Be Equal As Strings  ${resp.json()[0]['licenseTransactionType']}  New
       Should Be Equal As Strings  ${resp.json()[0]['renewedDays']}  0
       Should Be Equal As Strings  ${resp.json()[0]['type']}  Production
       Should Be Equal As Strings  ${resp.json()[0]['status']}  Active
       Should Be Equal As Strings  ${resp.json()[0]['name']}  ${addon_list[1][0]['addon_name']}

JD-TC-Addaddon -UH6
       [Documentation]   Provider adding expired  addon
       ${resp}=   Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=  Add addon   ${addon_list[0][0]['addon_id']}
       Log  ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   422
       Should Be Equal As Strings  "${resp.json()}"  "${PROVIDER_CANNOT_DOWNGRADE_ADDON}"


JD-TC-Addaddon -UH7
       [Documentation]   Provider adding 2 Multi User addon then use one full.

       ${resp}=   Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD} 
       Log  ${resp.content}
       Should Be Equal As Strings    ${resp.status_code}   200

       ${p_id1}=  get_acc_id  ${HLMUSERNAME6}
       Set Suite Variable   ${p_id1}

    
       ${resp}=   Get Business Profile
       Log  ${resp.content}
       Should Be Equal As Strings    ${resp.status_code}    200
       Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

       ${resp}=  View Waitlist Settings
       Log  ${resp.content}
       Should Be Equal As Strings    ${resp.status_code}    200
       IF  ${resp.json()['filterByDept']}==${bool[0]}
              ${resp}=  Toggle Department Enable
              Log  ${resp.content}
              Should Be Equal As Strings  ${resp.status_code}  200

       END

       ${resp}=  Get Departments
       Log  ${resp.content}
       Should Be Equal As Strings  ${resp.status_code}  200
       IF   '${resp.content}' == '${emptylist}'
              ${dep_name1}=  FakerLibrary.bs
              ${dep_code1}=   Random Int  min=100   max=999
              ${dep_desc1}=   FakerLibrary.word  
              ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
              Log  ${resp1.content}
              Should Be Equal As Strings  ${resp1.status_code}  200
              Set Suite Variable  ${dep_id}  ${resp1.json()}
       ELSE
              Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
       END

       ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200

       
       ${resp}=  GET Account License details     ${p_id1}
       Log  ${resp.content}
       Should Be Equal As Strings  ${resp.status_code}  200

       ${resp}=  Get Addon Transactions details     ${p_id1}
       Log  ${resp.content}
       Should Be Equal As Strings  ${resp.status_code}  200

       ${resp}=  Get Account Addon details  ${p_id1}  
       Log  ${resp.content} 
       Should be equal as strings  ${resp.status_code}       200

       ${resp}=   Get Addons Metadata For Superadmin
	Log  ${resp.content}
       Should Be Equal As Strings  ${resp.status_code}  200
	Set Suite Variable    ${addon_id}      ${resp.json()[0]['addons'][1]['addonId']}
	Set Suite Variable    ${addon_name}      ${resp.json()[0]['addons'][1]['addonName']}
       Log   ${addon_id}

       ${resp}=  Add Addons details  ${p_id1}   ${addon_id}
	Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  Get Account Addon details  ${p_id1}  
	Log  ${resp.content} 
	should be equal as strings  ${resp.json()[0]['licPkgOrAddonId']}  ${addon_id} 
	should be equal as strings  ${resp.json()[0]['name']}  ${addon_name}	   	  
	Should Be Equal As Strings  ${resp.status_code}  200

       # ${up_addons}=   Get upgradable addons
       # Log  ${up_addons.json()}
       # Should Be Equal As Strings    ${up_addons.status_code}   200
       # Set Suite Variable  ${addons}  ${up_addons.json()}  

       # ${addon_list}=  addons_all_license_applicable  ${addons}
       # Log  ${addon_list}
       # Set Suite Variable  ${addon_list}

       # ${resp}=   Get addons auditlog
       # Log   ${resp.json()}
       # Should Be Equal As Strings   ${resp.status_code}   200

       # ${resp}=   Get License UsageInfo 
       # Log  ${resp.content}
       # Should Be Equal As Strings  ${resp.status_code}  200

       # ${resp}=  Add addon   ${addon_list[7][0]['addon_id']}
       # Log  ${resp.json()}
       # Should Be Equal As Strings    ${resp.status_code}   200
    
       ${u_id}=  Create Sample User
       Set Suite Variable  ${u_id}

       ${resp}=  Get User By Id      ${u_id}
       Log   ${resp.json()}
       Should Be Equal As Strings      ${resp.status_code}  200
       Set Suite Variable      ${PUSERNAME_U1}     ${resp.json()['mobileNo']}

       ${resp}=   Get addons auditlog
       Log   ${resp.json()}
       Should Be Equal As Strings   ${resp.status_code}   200


       ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
       Should Be Equal As Strings  ${resp.status_code}  200

       @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
       Should Be Equal As Strings  ${resp[0].status_code}  200
       Should Be Equal As Strings  ${resp[1].status_code}  200

       ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200

*** Comment ***
JD-TC-Addaddon -4
       [Documentation]   Provider upgrade license package to highest package then check already added addon expired
       ${resp}=   Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200    
       clear_Addon  ${PUSERNAME}   
       ${highest_package}=  get_highest_license_pkg
       ${resp}=  Add addon  ${addon_list[0][0]['addon_id']}
       Log  ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Get addons auditlog
       Log  ${resp.json()}
       Should Be Equal As Strings   ${resp.status_code}   200
       Should Be Equal As Strings  ${resp.json()[0]['licPkgOrAddonId']}  ${addon_list[0][0]['addon_id']}
       Should Be Equal As Strings  ${resp.json()[0]['base']}  False
       Should Be Equal As Strings  ${resp.json()[0]['licenseTransactionType']}  New
       Should Be Equal As Strings  ${resp.json()[0]['renewedDays']}  0
       Should Be Equal As Strings  ${resp.json()[0]['type']}  Production
       Should Be Equal As Strings  ${resp.json()[0]['status']}  Active

       ${resp}=   Change License Package  ${highest_package[0]}
       Log  ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Get Active License
       Should Be Equal As Strings    ${resp.status_code}   200
       Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}  ${highest_package[0]}
       Should Be Equal As Strings  ${resp.json()['accountLicense']['licenseTransactionType']}  Upgrade
       Should Be Equal As Strings  ${resp.json()['accountLicense']['type']}  Production
       Should Be Equal As Strings  ${resp.json()['accountLicense']['status']}  Active
       Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}  ${highest_package[1]}

       sleep  05s
       ${resp}=   Get addons auditlog
       Log  ${resp.json()}
       Should Be Equal As Strings   ${resp.status_code}   200
       Should Be Equal As Strings  ${resp.json()[0]['licPkgOrAddonId']}  ${addon_list[0][0]['addon_id']}
       Should Be Equal As Strings  ${resp.json()[0]['base']}  False
       Should Be Equal As Strings  ${resp.json()[0]['licenseTransactionType']}  New
       Should Be Equal As Strings  ${resp.json()[0]['renewedDays']}  0
       Should Be Equal As Strings  ${resp.json()[0]['type']}  Production
       Should Be Equal As Strings  ${resp.json()[0]['status']}  Expired
