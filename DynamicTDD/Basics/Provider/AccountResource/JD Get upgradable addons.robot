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

JD-TC-Get Upgradableaddons -1
       [Documentation]   Provider adding one addonid then check the next upgradable addon 
       ${domresp}=  Get BusinessDomainsConf
       Should Be Equal As Strings  ${domresp.status_code}  200
       ${len}=  Get Length  ${domresp.json()}
       ${len}=  Evaluate  ${len}-1
       ${PUSERNAME}=  Evaluate  ${PUSERNAME}+40001423
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
       Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME}${\n}  
       ${addon_resp}=   Get Addons Metadata
       Should Be Equal As Strings    ${resp.status_code}   200
       Set Suite Variable  ${addon_resp}
       ${metric_len}=  Get Length  ${addon_resp.json()}
       ${addonslist}=  Create List
       FOR  ${index}  IN RANGE  ${metric_len}
              ${metric_len2}=  Get Length  ${addon_resp.json()[${index}]['addons']}
              ${addonslist}=  Run Keyword If  ${metric_len2}>0  Addons Metadata  ${index}  ${metric_len2}  ${addonslist}
              Set Suite Variable  ${addonslist}
       END
       ${addons_len}=  Get Length  ${addonslist}
       Set Suite Variable  ${addons_len}
       ${addons_len1}=  Evaluate  ${addons_len}-1
       FOR  ${i}  IN RANGE  ${addons_len1}
              ${resp}=  Add addon   ${addonslist[${i}]}
              Should Be Equal As Strings    ${resp.status_code}   200
              ${resp}=   Get addons auditlog  
              Should Be Equal As Strings    ${resp.status_code}   200         
              Should Be Equal As Strings  ${resp.json()[0]['licPkgOrAddonId']}  ${addonslist[${i}]} 
              ${j}=  Evaluate  ${i}+1  
              Run Keyword If  ${addons_len1}>0  Upgradable Addons  ${addons_len1}  ${addonslist}  ${j}
              ${addons_len1}=  Evaluate  ${addons_len1}-1
       END
            
JD-TC-Get Upgradableaddons -6
       [Documentation]   Provider with addonid 6 check to get upgradable addons
       ${resp}=   Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${addons_len}=  Evaluate  ${addons_len}-1
       ${resp}=  Add addon   ${addonslist[${addons_len}]}
       Should Be Equal As Strings  ${resp.status_code}   200       
       ${resp}=   Get addons auditlog
       Should Be Equal As Strings    ${resp.status_code}   200         
       Should Be Equal As Strings  ${resp.json()[0]['licPkgOrAddonId']}  ${addonslist[${addons_len}]}    
       ${resp}=   Get upgradable addons
       Should Be Equal As Strings    ${resp.status_code}   200
       Should Be Equal As Strings  ${resp.json()}  []
                            
JD-TC-Get Upgradableaddons -UH1
       [Documentation]   Provider check to get upgradable addons without login
       ${resp}=   Get upgradable addons
       Should Be Equal As Strings    ${resp.status_code}   419
       Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
              
JD-TC-Get Upgradableaddons -UH2 
       [Documentation]   Consumer check to get upgradable addons      
       ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=   Get upgradable addons
       Should Be Equal As Strings   ${resp.status_code}   401
       Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}
       

*** Keywords ***
Addons Metadata
       [Arguments]  ${len1}  ${len2}  ${list}
       FOR  ${index}  IN RANGE  ${len2}
              Set Test variable  ${addon_id}  ${addon_resp.json()[${len1}]['addons'][${index}]['addonId']}
              Append To List  ${list}    ${addon_id}
       END
       RETURN  ${list}

UpgradeAddons Metadata
       [Arguments]  ${len1}  ${len2}  ${list}
       FOR  ${index}  IN RANGE  ${len2}
              Set Test variable  ${addon_id}  ${upgradable_addons.json()[${len1}]['addons'][${index}]['addonId']}
              Append To List  ${list}    ${addon_id}
       END
       RETURN  ${list}

Upgradable Addons
       [Arguments]  ${len}  ${list}  ${j}
       ${resp}=   Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${upgradable_addons}=   Get upgradable addons
       Should Be Equal As Strings    ${upgradable_addons.status_code}   200
       Set Suite Variable  ${upgradable_addons}
       ${upgrade_len}=  Get Length  ${upgradable_addons.json()}
       ${upgradeaddonslist}=  Create List
       FOR  ${index}  IN RANGE  ${upgrade_len}
              ${upgrade_len2}=  Get Length  ${upgradable_addons.json()[${index}]['addons']}
              ${upgradeaddonslist}=  Run Keyword If  ${upgrade_len2}>0  UpgradeAddons Metadata  ${index}  ${upgrade_len2}  ${upgradeaddonslist}
       END
       FOR  ${index}  IN RANGE  ${len}
              Run Keyword If  ${upgrade_len}>0  Should Be Equal As Strings  ${upgradeaddonslist[${index}]}   ${list[${j}]}
              ${j}=  Evaluate  ${j}+1
       END