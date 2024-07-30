*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        License
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 


*** Test Cases ***

JD-TC-Update License -1
      [Documentation]  Update License Package with valid data
      ${resp}=   Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}   200
      ${decrypted_data}=  db.decrypt_data  ${resp.content}
      Log  ${decrypted_data}
      Set Suite Variable  ${old_pkgid}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
      # Set Suite Variable  ${old_pkgid}  ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']} 
      ${resp}=   Get upgradable license
      Should Be Equal As Strings    ${resp.status_code}   200
      Set Test Variable  ${pkgid}  ${resp.json()[0]['pkgId']} 
      Set Test Variable  ${pkgname}  ${resp.json()[0]['pkgName']}
      ${resp}=  Change License Package  ${pkgid}
      Should Be Equal As Strings    ${resp.status_code}   200
      ${resp}=  Get Active License
      Should Be Equal As Strings    ${resp.status_code}    200
      Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   ${pkgid}
      Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}   ${pkgname}

      ${resp}=   Get upgradable license
      Should Be Equal As Strings    ${resp.status_code}   200
      Set Suite Variable  ${pkgid}  ${resp.json()[0]['pkgId']} 
      Set Suite Variable  ${pkgname}  ${resp.json()[0]['pkgName']}
      ${resp}=  Change License Package  ${pkgid}
      Should Be Equal As Strings    ${resp.status_code}   200
      ${resp}=  Get Active License
      Should Be Equal As Strings    ${resp.status_code}    200
      Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   ${pkgid}
      Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}   ${pkgname}

            
JD-TC-Update License -UH1
      [Documentation]  Update License Package to downgrade
      ${resp}=   Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}   200
      ${resp}=  Change License Package  ${old_pkgid}
      Should Be Equal As Strings    ${resp.status_code}   422
      Should Be Equal As Strings   ${resp.json()}   ${PROVIDER_CANNOT_DOWNGRADE_PACKAGE}
      
JD-TC-Update License -UH2
      [Documentation]  Update License Package to renew
      ${resp}=   Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}   200      
      ${resp}=  Change License Package  ${pkgid}
      Should Be Equal As Strings    ${resp.status_code}   422
      ${msg}=  Replace String    ${LICENSE_ALREADY_ADDED_IN_ACCOUNT}  {}  ${pkgname}
      Should Be Equal As Strings   ${resp.json()}   ${msg}
      
JD-TC-Update License -UH3
      [Documentation]  Update License Package to invalid package id
      ${resp}=   Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}   200
      ${resp}=  Change License Package  0
      Should Be Equal As Strings    ${resp.status_code}   422
      Should Be Equal As Strings    ${resp.json()}   ${INVALID_PACKAGE_ID}
      
JD-TC-Update License -UH4
      [Documentation]  Update License Package without login
      ${resp}=  Change License Package  ${pkgid}
      Should Be Equal As Strings    ${resp.status_code}   419
      Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
      
JD-TC-Update License -UH${pkgid}
      [Documentation]  Update License Package by consumer
      ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}   200
      ${resp}=  Change License Package   ${pkgid}
      Should Be Equal As Strings   ${resp.status_code}  401
      Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}
      
      
      
      
      
      
      
      
          
      
