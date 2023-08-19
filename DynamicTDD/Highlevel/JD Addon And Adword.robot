*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Adword
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${subdomain_len}  0

*** Test Cases ***
JD-TC-AddonAndAdwords -1
       [Documentation]    Provider in lowest package check to add Jaldee Keywords to an account after add a addon for addwords
       
       ${domresp}=  Get BusinessDomainsConf
       Should Be Equal As Strings  ${domresp.status_code}  200
       ${len}=  Get Length  ${domresp.json()}
       ${len}=  Evaluate  ${len}-1
       ${PUSERNAME}=  Evaluate  ${PUSERNAME}+51002222
       Set Suite Variable  ${PUSERNAME}
       Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
       Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
       ${firstname}=  FakerLibrary.first_name
       ${lastname}=  FakerLibrary.last_name
       ${pkg}=   get_highest_license_pkg
       ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME}   ${pkg[0]}
       Log  ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Account Activation  ${PUSERNAME}  0
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Account Set Credential  ${PUSERNAME}  ${PASSWORD}  0
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
       Should Be Equal As Strings    ${resp.status_code}    200
       Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME}${\n}  
       ${resp}=   Get Adword Count   
       Log   ${resp.json()}
       Should Be Equal As Strings  ${resp.status_code}   200
       Set Test Variable  ${addword_count1}  ${resp.json()}
       ${check}=   Run Keyword If   ${addword_count1} > 0   AddAdwords   ${addword_count1}
       ${addword}=  FakerLibrary.word
       sleep  3s
       ${resp}=  Add Adword  ${addword} 
       Log  ${resp.json()}
       Should Be Equal As Strings  ${resp.status_code}   422
       Should Be Equal As Strings  "${resp.json()}"  "${EXCEEDS_LIMIT}" 
       ${addonId}=  get_jaldeekeyword_pkg
       ${resp}=  Add addon  ${addonId}
       Should Be Equal As Strings  ${resp.status_code}   200       
       ${resp}=   Get Adword Count  
       Should Be Equal As Strings  ${resp.status_code}   200
       Set Test Variable  ${addword_count2}  ${resp.json()}
       ${addword_count}=  Evaluate  ${addword_count2}-${addword_count1}
       FOR  ${count}  IN RANGE  ${addword_count}
              ${addword}=  FakerLibrary.word
              ${resp}=  Add Adword  ${addword}${count}
              Log  ${resp.json()}
              Should Be Equal As Strings  ${resp.status_code}   200
              ${resp}=   Get Adword   
              Should Be Equal As Strings  ${resp.status_code}   200
              Should Contain    "${resp.json()}"  ${addword}${count}
       END 
       ${resp}=   Get Adword 
       Should Be Equal As Strings  ${resp.status_code}   200
       ${adword_length}=  Get Length  ${resp.json()}
       Should Be True  ${addword_count2}==${adword_length}
       sleep  3s
       ${addword}=  FakerLibrary.word
       ${resp}=  Add Adword  ${addword} 
       Log  ${resp.json()}
       Should Be Equal As Strings  ${resp.status_code}   422
       Should Be Equal As Strings  "${resp.json()}"  "${EXCEEDS_LIMIT}"

JD-TC-AddonAndAdwords -2
    [Documentation]  upgrade license package and add jaldeekeywords
    
       ${domresp}=  Get BusinessDomainsConf
       Should Be Equal As Strings  ${domresp.status_code}  200
       ${len}=  Get Length  ${domresp.json()}
       ${len}=  Evaluate  ${len}-1
       ${PUSERNAMEA}=  Evaluate  ${PUSERNAME}+51002222
       Set Suite Variable  ${PUSERNAMEA}
       Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
       Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
       ${firstname}=  FakerLibrary.first_name
       ${lastname}=  FakerLibrary.last_name
       ${pkg}=   get_lowest_license_pkg
       ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAMEA}   ${pkg[0]}
       Log  ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Account Activation  ${PUSERNAMEA}  0
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Account Set Credential  ${PUSERNAMEA}  ${PASSWORD}  0
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Encrypted Provider Login  ${PUSERNAMEA}  ${PASSWORD}
       Should Be Equal As Strings    ${resp.status_code}    200
       Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAMEA}${\n}  
       ${resp}=  Get upgradable license 
       Log   ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200
       ${len}=  Get Length  ${resp.json()}
       ${len}=  Evaluate  ${len}-2
       Set Test Variable  ${licId}  ${resp.json()[${len}]['pkgId']}
       ${resp}=  Change License Package  ${licId}
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Get Adword 
       Should Be Equal As Strings  ${resp.status_code}   200
       ${adword_length}=  Get Length  ${resp.json()}
       ${resp}=   Get Adword Count  
       Should Be Equal As Strings  ${resp.status_code}   200
       Set Test Variable  ${addword_count2}  ${resp.json()}
       ${addword_count}=  Evaluate  ${addword_count2}-${adword_length}
       FOR  ${count}  IN RANGE  ${addword_count}
              ${addword}=  FakerLibrary.word
              ${resp}=  Add Adword  ${addword}${count}
              Log  ${resp.json()}
              Should Be Equal As Strings  ${resp.status_code}   200
              ${resp}=   Get Adword   
              Should Be Equal As Strings  ${resp.status_code}   200
              Should Contain    "${resp.json()}"  ${addword}${count}
       END 
       sleep  3s
       ${addword}=  FakerLibrary.word
       ${resp}=  Add Adword  ${addword} 
       Log  ${resp.json()}
       Should Be Equal As Strings  ${resp.status_code}   422
       Should Be Equal As Strings  "${resp.json()}"  "${EXCEEDS_LIMIT}"

       ${resp}=  Get upgradable license 
       Log   ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200
       ${len}=  Get Length  ${resp.json()}
       ${len}=  Evaluate  ${len}-1
       Set Test Variable  ${licId1}  ${resp.json()[${len}]['pkgId']}
       ${resp}=  Change License Package  ${licId1}
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Get Adword 
       Should Be Equal As Strings  ${resp.status_code}   200
       ${adword_length}=  Get Length  ${resp.json()}
       ${resp}=   Get Adword Count  
       Should Be Equal As Strings  ${resp.status_code}   200
       Set Test Variable  ${addword_count2}  ${resp.json()}
       ${addword_count}=  Evaluate  ${addword_count2}-${adword_length}
       FOR  ${count}  IN RANGE  ${addword_count}
              ${addword}=  FakerLibrary.word
              ${resp}=  Add Adword  ${addword}${count}
              Log  ${resp.json()}
              Should Be Equal As Strings  ${resp.status_code}   200
              ${resp}=   Get Adword   
              Should Be Equal As Strings  ${resp.status_code}   200
              Should Contain    "${resp.json()}"  ${addword}${count}
       END 
       sleep  3s
       ${addword}=  FakerLibrary.word
       ${resp}=  Add Adword  ${addword} 
       Log  ${resp.json()}
       Should Be Equal As Strings  ${resp.status_code}   422
       Should Be Equal As Strings  "${resp.json()}"  "${EXCEEDS_LIMIT}"

*** Keywords ***

AddAdwords
       [Arguments]  ${addword_count}
       FOR  ${count}  IN RANGE  ${addword_count}
              ${addword}=  FakerLibrary.word
              ${resp}=  Add Adword  ${addword}${count} 
              Log  ${resp.json()}
              #Exit For Loop IF     '${resp.json()}' == "${ADWORD_ALREADY_EXISTS}"
              Should Be Equal As Strings  ${resp.status_code}   200
              ${resp}=   Get Adword 
              Log  ${resp.json()}  
              Should Be Equal As Strings  ${resp.status_code}   200
              Should Contain    "${resp.json()}"  ${addword}${count}
       END
       ${resp}=   Get Adword 
       Log  ${resp.json()}  
       Should Be Equal As Strings  ${resp.status_code}   200
       ${adword_length}=  Get Length  ${resp.json()}
       Should Be True  ${addword_count}==${adword_length}
