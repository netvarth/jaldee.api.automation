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

JD-TC-Add Adwords -1
       [Documentation]    Provider in a license Package adding adword without addon
       ${domresp}=  Get BusinessDomainsConf
       Should Be Equal As Strings  ${domresp.status_code}  200
       ${len}=  Get Length  ${domresp.json()}
       FOR  ${index}  IN RANGE  ${len}
              ${sublen}=  Get Length  ${domresp.json()[${index}]['subDomains']}
              ${subdomain_len}=  Evaluate  ${subdomain_len}+${sublen}
       END
       FOR   ${a}  IN RANGE   ${subdomain_len}
              ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
              Should Be Equal As Strings    ${resp.status_code}    200  
              ${acid}=   get_acc_id  ${PUSERNAME${a}}   
              clear_Addon  ${PUSERNAME${a}}  
              clear_Adword  ${acid} 
              ${resp}=   Get Adword Count   
              Log  ${resp.content}
              Should Be Equal As Strings  ${resp.status_code}   200
              Set Test Variable  ${addword_count}  ${resp.json()}
              ${addword_count}=  Convert To Number   ${addword_count}  1
              ${check}=   Run Keyword If   ${addword_count} > 0   AddAdwords   ${addword_count}
              Exit For Loop IF     '${check}' == 'True'
       END

JD-TC-Add Adwords -2
       [Documentation]    Provider  upgrade license to highest license package then add adword without addon
       ${domresp}=  Get BusinessDomainsConf
       Should Be Equal As Strings  ${domresp.status_code}  200
       ${len}=  Get Length  ${domresp.json()}
       ${len}=  Evaluate  ${len}-1
       ${PUSERNAME}=  Evaluate  ${PUSERNAME}+40001111
       Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
       Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
       ${firstname}=  FakerLibrary.first_name
       ${lastname}=  FakerLibrary.last_name
       ${lowest_package}=  get_lowest_license_pkg
       ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME}   ${lowest_package[0]}
       Log  ${resp.content}
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Account Activation  ${PUSERNAME}  0
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Account Set Credential  ${PUSERNAME}  ${PASSWORD}  0
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
       Log  ${resp.content}
       Should Be Equal As Strings    ${resp.status_code}    200
       Set Suite Variable  ${PUSERNAME}
       Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME}${\n}  
       ${resp}=   Get Adword Count   
       Should Be Equal As Strings  ${resp.status_code}   200
       Set Test Variable  ${addword_count1}  ${resp.json()}
       ${check}=   Run Keyword If   ${addword_count1} > 0   AddAdwords   ${addword_count1}
       ${highest_package}=  get_highest_license_pkg
       ${resp}=   Change License Package  ${highest_package[0]}
       Log  ${resp.content}
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Get Active License
       Should Be Equal As Strings    ${resp.status_code}   200
       Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}  ${highest_package[0]}
       Should Be Equal As Strings  ${resp.json()['accountLicense']['licenseTransactionType']}  Upgrade
       Should Be Equal As Strings  ${resp.json()['accountLicense']['type']}  Production
       Should Be Equal As Strings  ${resp.json()['accountLicense']['status']}  Active
       Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}  ${highest_package[1]}
       ${resp}=   Get Adword Count   
       Log  ${resp.content}
       Should Be Equal As Strings  ${resp.status_code}   200
       Set Suite Variable  ${addword_count2}  ${resp.json()}
       ${addword_count}=  Evaluate  ${addword_count2}-${addword_count1}
       FOR  ${count}  IN RANGE  ${addword_count}
              ${addword}=  FakerLibrary.name
              ${resp}=  Add Adword  ${addword}${count} 
              Log  ${resp.content}
              Should Be Equal As Strings  ${resp.status_code}   200
              ${resp}=   Get Adword   
              Should Be Equal As Strings  ${resp.status_code}   200
              Should Contain    "${resp.json()}"  ${addword}
       END 
       sleep  03s
       ${addword}=  FakerLibrary.first_name
       ${resp}=  Add Adword  ${addword} 
       Should Be Equal As Strings  ${resp.status_code}   422
       Should Be Equal As Strings  ${resp.json()}  ${EXCEEDS_LIMIT}           
       
       ${resp}=   Get Adword 
       Log  ${resp.content}  
       Should Be Equal As Strings  ${resp.status_code}   200
       ${adword_length}=  Get Length  ${resp.json()}
       Should Be True  ${addword_count2}==${adword_length}

JD-TC-Add Adwords -3
       [Documentation]    Provider in highest package check to add Adwords to an account after add a addon for addwords
       ${domresp}=  Get BusinessDomainsConf
       Should Be Equal As Strings  ${domresp.status_code}  200
       ${len}=  Get Length  ${domresp.json()}
       ${len}=  Evaluate  ${len}-1
       ${PUSERNAME}=  Evaluate  ${PUSERNAME}+40002222
       Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
       Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
       ${firstname}=  FakerLibrary.first_name
       ${lastname}=  FakerLibrary.last_name
       ${lowest_package}=  get_lowest_license_pkg
       ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME}   ${lowest_package[0]}
       Log  ${resp.content}
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Account Activation  ${PUSERNAME}  0
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Account Set Credential  ${PUSERNAME}  ${PASSWORD}  0
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
       Log  ${resp.content}
       Should Be Equal As Strings    ${resp.status_code}    200
       Set Suite Variable  ${PUSERNAME}
       Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME}${\n}  
       ${resp}=   Get Adword Count   
       Should Be Equal As Strings  ${resp.status_code}   200
       Set Test Variable  ${addword_count1}  ${resp.json()}
       ${check}=   Run Keyword If   ${addword_count1} > 0   AddAdwords   ${addword_count1}
       ${addonId}=  get_jaldeekeyword_pkg
       ${resp}=  Add addon  ${addonId}
       Log  ${resp.content}
       Should Be Equal As Strings  ${resp.status_code}   200       
       ${resp}=   Get Adword Count   
       Log  ${resp.content}
       Should Be Equal As Strings  ${resp.status_code}   200
       Set Test Variable  ${addword_count2}  ${resp.json()}
       ${addword_count}=  Evaluate  ${addword_count2}-${addword_count1}
       FOR  ${count}  IN RANGE  ${addword_count}
              ${addword}=  FakerLibrary.name
              ${resp}=  Add Adword  ${addword}${count}
              Log  ${resp.content}
              Should Be Equal As Strings  ${resp.status_code}   200
              ${resp}=   Get Adword   
              Should Be Equal As Strings  ${resp.status_code}   200
              Should Contain    "${resp.json()}"  ${addword}
       END 
       ${resp}=   Get Adword 
       Log  ${resp.content}  
       Should Be Equal As Strings  ${resp.status_code}   200
       ${adword_length}=  Get Length  ${resp.json()}
       Should Be True  ${addword_count2}==${adword_length}
       
JD-TC-Add Adwords -UH1
       [Documentation]    Adding an already added adword

       ${domresp}=  Get BusinessDomainsConf
       Should Be Equal As Strings  ${domresp.status_code}  200
       ${len}=  Get Length  ${domresp.json()}
       ${len}=  Evaluate  ${len}-1
       ${PUSERNAME}=  Evaluate  ${PUSERNAME}+40002223
       Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
       Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
       ${firstname}=  FakerLibrary.first_name
       ${lastname}=  FakerLibrary.last_name
       ${highest_package}=  get_highest_license_pkg
       ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME}   ${highest_package[0]}
       Log  ${resp.content}
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Account Activation  ${PUSERNAME}  0
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Account Set Credential  ${PUSERNAME}  ${PASSWORD}  0
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
       Log  ${resp.content}
       Should Be Equal As Strings    ${resp.status_code}    200
       Set Suite Variable  ${PUSERNAME}
       Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME}${\n}  
       ${resp}=   Get Adword Count   
       Should Be Equal As Strings  ${resp.status_code}   200
       Set Test Variable  ${addword_count1}  ${resp.json()}
       IF   ${addword_count1} > 0
              ${addword}=  FakerLibrary.name
              Set Suite Variable  ${addword}
              ${resp}=  Add Adword  ${addword}
              Log  ${resp.content}
              Should Be Equal As Strings  ${resp.status_code}   200
              ${resp}=   Get Adword   
              Should Be Equal As Strings  ${resp.status_code}   200
              Should Contain    "${resp.json()}"  ${addword}
       END

       ${resp}=  Add Adword  ${addword} 
       Should Be Equal As Strings  ${resp.status_code}   422
       Should Be Equal As Strings  "${resp.json()}"  "${ADWORD_ALREADY_EXISTS}"


       # ${domresp}=  Get BusinessDomainsConf
       # Should Be Equal As Strings  ${domresp.status_code}  200
       # ${len}=  Get Length  ${domresp.json()}
       # FOR  ${index}  IN RANGE  ${len}
       #        ${sublen}=  Get Length  ${domresp.json()[${index}]['subDomains']}
       #        ${subdomain_len}=  Evaluate  ${subdomain_len}+${sublen}
       # END
       # FOR   ${a}  IN RANGE    ${subdomain_len}
       #        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
       #        Should Be Equal As Strings    ${resp.status_code}    200
       #        ${acid}=   get_acc_id  ${PUSERNAME${a}} 
       #        clear_Addon  ${PUSERNAME${a}}  
       #        clear_Adword  ${acid} 
       #        ${pkg_id}=   get_highest_license_pkg
       #        Log   ${pkg_id}
       #        Set Suite Variable     ${pkgId}   ${pkg_id[0]}
       #        ${resp}=  Change License Package  ${pkgId}
       #        Should Be Equal As Strings    ${resp.status_code}   200
       #        # sleep  1s
       #        ${resp}=   Get Adword Count   
       #        Log  ${resp.content}
       #        Should Be Equal As Strings  ${resp.status_code}   200
       #        Set Test Variable  ${addword_count}  ${resp.json()}
       #        Exit For Loop IF     ${addword_count} > 0
       # END
       # ${addword_count}=  Evaluate  ${addword_count}-1
       # FOR  ${count}  IN RANGE  ${addword_count}
       #        ${addword}=  FakerLibrary.firstname
       #        ${resp}=  Add Adword  ${addword}${count} 
       #        Set Suite Variable  ${addword}
       #        Log  ${resp.content}
       #        Should Be Equal As Strings  ${resp.status_code}   200
       #        ${resp}=   Get Adword 
       #        Log  ${resp.content}  
       #        Should Be Equal As Strings  ${resp.status_code}   200
       #        Should Contain    "${resp.json()}"  ${addword}
       # END   
       # ${resp}=  Add Adword  ${addword}${count} 
       # Should Be Equal As Strings  ${resp.status_code}   422
       # Should Be Equal As Strings  "${resp.json()}"  "${ADWORD_ALREADY_EXISTS}"
       
JD-TC-Add Adwords -UH2
       [Documentation]    consumer check to add Adwords to an account
       ${resp}=   ConsumerLogin  ${CUSERNAME2}  ${PASSWORD} 
       Should Be Equal As Strings  ${resp.status_code}  200     
       ${resp}=  Add Adword  ${addword} 
       Should Be Equal As Strings  ${resp.status_code}   401 
       Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"      
       
JD-TC-Add Adwords -UH3
       [Documentation]    without login add Adwords    
       ${resp}=  Add Adword  ${addword} 
       Should Be Equal As Strings  ${resp.status_code}   419
       Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
       

*** Keywords ***

AddAdwords
       [Arguments]  ${addword_count}
       FOR  ${count}  IN RANGE  ${addword_count}
              ${addword}=  FakerLibrary.word
              ${resp}=  Add Adword  ${addword}${count} 
              Log  ${resp.content}
              #Exit For Loop IF     '${resp.json()}' == "${ADWORD_ALREADY_EXISTS}"
              Should Be Equal As Strings  ${resp.status_code}   200
              ${resp}=   Get Adword 
              Log  ${resp.content}  
              Should Be Equal As Strings  ${resp.status_code}   200
              Should Contain    "${resp.json()}"  ${addword}
       END
       ${resp}=   Get Adword 
       Log  ${resp.content}  
       Should Be Equal As Strings  ${resp.status_code}   200
       ${adword_length}=  Get Length  ${resp.json()}
       Should Be True  ${addword_count}==${adword_length}
