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

*** Test Cases ***

JD-TC-Get addons auditlog-1
       [Documentation]   Provider check to get addons auditlog
       ${domresp}=  Get BusinessDomainsConf
       Should Be Equal As Strings  ${domresp.status_code}  200
       ${len}=  Get Length  ${domresp.json()}
       ${len}=  Evaluate  ${len}-1
       ${PUSERNAME}=  Evaluate  ${PUSERNAME}+40001233
       Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
       Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
       ${firstname}=  FakerLibrary.first_name
       ${lastname}=  FakerLibrary.last_name
       ${highest_package}=  get_lowest_license_pkg
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
       Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME}${\n}  
       clear_Addon  ${PUSERNAME}
       ${up_addons}=   Get upgradable addons
       Log  ${up_addons.json()}
       Should Be Equal As Strings    ${up_addons.status_code}   200
       Set Suite Variable  ${addons}  ${up_addons.json()}  
       ${addon_list}=  addons_all_license_applicable  ${addons}
       Log  ${addon_list}
       Set Suite Variable  ${addon_list}

       ${resp}=  Add addon  ${addon_list[0][0]['addon_id']}
       Log  ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=  Add addon  ${addon_list[0][1]['addon_id']}
       Log  ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200
       sleep  3s

       ${resp}=   Get addons auditlog    
       Should Be Equal As Strings  ${resp.json()[0]['licPkgOrAddonId']}  ${addon_list[0][1]['addon_id']}
       Should Be Equal As Strings  ${resp.json()[0]['base']}  False
       Should Be Equal As Strings  ${resp.json()[0]['licenseTransactionType']}  Upgrade
       Should Be Equal As Strings  ${resp.json()[0]['renewedDays']}  0
       Should Be Equal As Strings  ${resp.json()[0]['type']}  Production
       Should Be Equal As Strings  ${resp.json()[0]['status']}  Active
       Should Be Equal As Strings  ${resp.json()[0]['name']}  ${addon_list[0][1]['addon_name']}  

       Should Be Equal As Strings  ${resp.json()[1]['licPkgOrAddonId']}  ${addon_list[0][0]['addon_id']}
       Should Be Equal As Strings  ${resp.json()[1]['base']}  False
       Should Be Equal As Strings  ${resp.json()[1]['licenseTransactionType']}  New
       Should Be Equal As Strings  ${resp.json()[1]['renewedDays']}  0
       Should Be Equal As Strings  ${resp.json()[1]['type']}  Production
       Should Be Equal As Strings  ${resp.json()[1]['status']}  Expired
       Should Be Equal As Strings  ${resp.json()[1]['name']}   ${addon_list[0][0]['addon_name']}  
       
JD-TC-Get addons auditlog -UH1
       [Documentation]   consumer check to get addons auditlog       
       ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=   Get addons auditlog
       Should Be Equal As Strings   ${resp.status_code}   401
       Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"
       
JD-TC-Get addons auditlog -UH2
       [Documentation]   Provider check to get addons auditlog without login
       ${resp}=   Get addons auditlog
       Should Be Equal As Strings   ${resp.status_code}   419
       Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"