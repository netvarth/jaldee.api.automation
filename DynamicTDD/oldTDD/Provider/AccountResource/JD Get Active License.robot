***Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        License
Library           Collections
Library           String
Library           json
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Library           /ebs/TDD/db.py

*** Test Cases ***

JD-TC-Get Active License -1
       [Documentation]   Provider Get Active License
       ${resp}=   Encrypted Provider Login  ${PUSERNAME16}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Get upgradable license
       Log  ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200
       Set Test Variable  ${pkg_id}  ${resp.json()[0]['pkgId']}
       Set Test Variable  ${pkg_name}  ${resp.json()[0]['pkgName']}
       Set Test Variable  ${type}  ${resp.json()[0]['type']}
       Set Test Variable  ${price}  ${resp.json()[0]['price']}
       Set Test Variable  ${period}  ${resp.json()[0]['trialPeriod']}
       Set Test Variable  ${display}  ${resp.json()[0]['displayName']}
       ${date}=  db.get_date_by_timezone  ${tz}
       ${resp}=   Change License Package  ${pkg_id}
       Log  ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Get Active License
       Log  ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200
       Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}  ${pkg_id}
       Should Be Equal As Strings  ${resp.json()['accountLicense']['licenseTransactionType']}  Upgrade
       Should Be Equal As Strings  ${resp.json()['accountLicense']['type']}  ${type}
       Should Be Equal As Strings  ${resp.json()['accountLicense']['status']}  Active
       Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}  ${pkg_name}
       Should Be Equal As Strings  ${resp.json()['accountLicense']['dateApplied']}  ${date}
      
JD-TC-Get Active License -UH1
       [Documentation]   get Auditlog  without login
       ${resp}=   Get Active License
       Should Be Equal As Strings  ${resp.status_code}  419
       Should Be Equal As Strings   ${resp.json()}  ${SESSION_EXPIRED}
       
JD-TC-Get Active License -UH2
       [Documentation]   Consumer get AuditLog
       ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Get Active License
       Should Be Equal As Strings  ${resp.status_code}  401
       Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"