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

JD-TC-GetUpgradable -1
       [Documentation]   Provider check the upgradable licenses
       ${licresp}=   Get Licensable Packages
       Log  ${licresp.json()}
       Should Be Equal As Strings   ${licresp.status_code}   200
       ${liclen}=  Get Length  ${licresp.json()}
       ${pkgid_list}=  Create List
       FOR  ${index}  IN RANGE  ${liclen}
              Append To List  ${pkgid_list}    ${licresp.json()[${index}]['pkgId']}
       END
       Log  ${pkgid_list}
       Set Suite Variable  ${pkgid_list}
       ${resp}=   Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${decrypted_data}=  db.decrypt_data  ${resp.content}
       Log  ${decrypted_data}
       Set Suite Variable  ${old_pkgid}  ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
       # Set Suite Variable  ${old_pkgid}  ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}  ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']} 
       Remove Values From List  ${pkgid_list}  ${old_pkgid}
       ${resp}=   Get upgradable license
       Should Be Equal As Strings    ${resp.status_code}   200
       ${upgradable_licences}=  Get Length  ${resp.json()}
       ${upgradable_licences_list}=  Create List
       FOR  ${index}  IN RANGE  ${upgradable_licences}
              Append To List  ${upgradable_licences_list}    ${resp.json()[${index}]['pkgId']}
       END
       Log  ${upgradable_licences_list}
       FOR  ${index}  IN RANGE  ${upgradable_licences}
              Should Be Equal As Strings  ${upgradable_licences_list[${index}]}   ${pkgid_list[${index}]}
       END
   
JD-TC-GetUpgradable -2
       [Documentation]   Provider changing license package to next then check the upgradable licenses
       ${resp}=   Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       Set Test Variable  ${next_pkgId}  ${pkgid_list[0]}
       ${resp}=  Change License Package   ${next_pkgId}
       Should Be Equal As Strings    ${resp.status_code}   200
       Remove Values From List  ${pkgid_list}  ${next_pkgId}
       ${resp}=   Get upgradable license
       Should Be Equal As Strings    ${resp.status_code}   200
       ${upgradable_licences}=  Get Length  ${resp.json()}
       ${upgradable_licences_list}=  Create List
       FOR  ${index}  IN RANGE  ${upgradable_licences}
              Append To List  ${upgradable_licences_list}    ${resp.json()[${index}]['pkgId']}
       END
       Log  ${upgradable_licences_list}
       FOR  ${index}  IN RANGE  ${upgradable_licences}
              Should Be Equal As Strings  ${upgradable_licences_list[${index}]}   ${pkgid_list[${index}]}
       END
JD-TC-GetUpgradable -3
       [Documentation]   Provider changing license package to next then check the upgradable licenses
       ${resp}=   Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       Set Test Variable  ${next_pkgId}  ${pkgid_list[0]}
       ${resp}=  Change License Package   ${next_pkgId}
       Should Be Equal As Strings    ${resp.status_code}   200
       Remove Values From List  ${pkgid_list}  ${next_pkgId}
       ${resp}=   Get upgradable license
       Should Be Equal As Strings    ${resp.status_code}   200
       ${upgradable_licences}=  Get Length  ${resp.json()}
       ${upgradable_licences_list}=  Create List
       FOR  ${index}  IN RANGE  ${upgradable_licences}
              Append To List  ${upgradable_licences_list}    ${resp.json()[${index}]['pkgId']}
       END
       Log  ${upgradable_licences_list}
       FOR  ${index}  IN RANGE  ${upgradable_licences}
              Should Be Equal As Strings  ${upgradable_licences_list[${index}]}   ${pkgid_list[${index}]}
       END
       
JD-TC-GetUpgradable -4
       [Documentation]   Provider changing license package to next then check the upgradable licenses
       ${resp}=   Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       Set Test Variable  ${next_pkgId}  ${pkgid_list[0]}
       ${resp}=  Change License Package   ${next_pkgId}
       Should Be Equal As Strings    ${resp.status_code}   200
       Remove Values From List  ${pkgid_list}  ${next_pkgId}
       ${resp}=   Get upgradable license
       Should Be Equal As Strings    ${resp.status_code}   200
       ${upgradable_licences}=  Get Length  ${resp.json()}
       ${upgradable_licences_list}=  Create List
       FOR  ${index}  IN RANGE  ${upgradable_licences}
              Append To List  ${upgradable_licences_list}    ${resp.json()[${index}]['pkgId']}
       END
       Log  ${upgradable_licences_list}
       FOR  ${index}  IN RANGE  ${upgradable_licences}
              Should Be Equal As Strings  ${upgradable_licences_list[${index}]}   ${pkgid_list[${index}]}
       END

JD-TC-GetUpgradable -5
       [Documentation]   Provider changing license package to next then check the upgradable licenses
       ${resp}=   Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       Set Test Variable  ${next_pkgId}  ${pkgid_list[0]}
       ${resp}=  Change License Package   ${next_pkgId}
       Should Be Equal As Strings    ${resp.status_code}   200
       Remove Values From List  ${pkgid_list}  ${next_pkgId}
       ${resp}=   Get upgradable license
       Should Be Equal As Strings    ${resp.status_code}   200
       ${upgradable_licences}=  Get Length  ${resp.json()}
       ${upgradable_licences_list}=  Create List
       FOR  ${index}  IN RANGE  ${upgradable_licences}
              Append To List  ${upgradable_licences_list}    ${resp.json()[${index}]['pkgId']}
       END
       Log  ${upgradable_licences_list}
       FOR  ${index}  IN RANGE  ${upgradable_licences}
              Should Be Equal As Strings  ${upgradable_licences_list[${index}]}   ${pkgid_list[${index}]}
       END

JD-TC-GetUpgradable -6
       [Documentation]   Provider changing license package to next then check the upgradable licenses
       ${resp}=   Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       Set Test Variable  ${next_pkgId}  ${pkgid_list[0]}
       ${resp}=  Change License Package   ${next_pkgId}
       Should Be Equal As Strings    ${resp.status_code}   200
       Remove Values From List  ${pkgid_list}  ${next_pkgId}
       ${resp}=   Get upgradable license
       Should Be Equal As Strings    ${resp.status_code}   200
       ${upgradable_licences}=  Get Length  ${resp.json()}
       ${upgradable_licences_list}=  Create List
       FOR  ${index}  IN RANGE  ${upgradable_licences}
              Append To List  ${upgradable_licences_list}    ${resp.json()[${index}]['pkgId']}
       END
       Log  ${upgradable_licences_list}
       FOR  ${index}  IN RANGE  ${upgradable_licences}
              Should Be Equal As Strings  ${upgradable_licences_list[${index}]}   ${pkgid_list[${index}]}
       END    

JD-TC-GetUpgradable -UH1
       [Documentation]   Provider check to get upgradable license without login
       ${resp}=   Get upgradable license 
       Should Be Equal As Strings    ${resp.status_code}   419
       Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
              
JD-TC-GetUpgradable -UH2 
       [Documentation]   Consumer check to get upgradable license      
       ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=   Get upgradable license 
       Should Be Equal As Strings   ${resp.status_code}   401
       Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}
       
