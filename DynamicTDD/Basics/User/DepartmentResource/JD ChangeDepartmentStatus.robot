*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Department
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${SERVICE1}	   Bridal Makeup_001
${SERVICE2}	   Groom MakeupW_002
${SERVICE3}	   Groom MakeupW_003
${SERVICE4}	   Groom MakeupW_004
@{dep_status}  enable   disable

*** Test Cases ***
JD-TC-Change Department Status-1
    [Documentation]  Provider Create Department using service id
    
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${MUSERNAME_G}=  Evaluate  ${MUSERNAME}+423814
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_G}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${MUSERNAME_G}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${MUSERNAME_G}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_G}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${MUSERNAME_G}${\n}
    Set Suite Variable  ${MUSERNAME_G}
    ${id}=  get_id  ${MUSERNAME_G}
    Set Suite Variable  ${id}
   
    ${resp}=  Create Sample Service  ${SERVICE1}  
    Set Suite Variable  ${sid1}  ${resp}  
    ${resp}=  Create Sample Service  ${SERVICE2}  
    Set Suite Variable  ${sid2}  ${resp} 
    ${resp}=  Create Sample Service  ${SERVICE3}  
    Set Suite Variable  ${sid3}  ${resp} 
    ${resp}=   Toggle Department Enable
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name1}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name1}
    ${dep_code1}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code1}
    ${dep_desc}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc}  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc}   ${sid1}  ${sid2}  ${sid3} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid1}  ${resp.json()}
    ${resp}=  Change Department Status  ${depid1}  ${dep_status[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Department ById  ${depid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  departmentStatus=${status[1]}
    ${resp}=  Change Department Status  ${depid1}  ${dep_status[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Department ById  ${depid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  departmentStatus=${status[0]}

JD-TC-Change Department Status-UH1
    [Documentation]  Change Department Status of another provider
   
    ${resp}=  Encrypted Provider Login  ${MUSERNAME32}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Toggle Department Enable
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Change Department Status  ${depid1}  ${dep_status[0]}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"
      
JD-TC-Change Department Status-UH2
    [Documentation]  Change department status of Invalid department

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_G}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200      
    ${resp}=  Change Department Status  0  ${dep_status[0]}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${DETP_NOT_BELONGS_TO_THIS_ACCOUNT}"

JD-TC-Change Department Status-UH3
    [Documentation]  Change department status to same status

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_G}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200      
    ${resp}=  Change Department Status  ${depid1}  ${dep_status[0]}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${DETP_ALREADY_ENABLED}"      
    ${resp}=  Change Department Status  ${depid1}  ${dep_status[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Change Department Status  ${depid1}  ${dep_status[1]}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${DETP_ALREADY_DISABLED}"

JD-TC-Change Department Status-UH4
    [Documentation]  Change department status without login

    ${resp}=  Change Department Status  ${depid1}   ${dep_status[0]}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   "${resp.json()}"    "${SESSION_EXPIRED}"
     
JD-TC-Change Department Status-UH5
    [Documentation]  Change department status using consumer login

    ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Change Department Status  ${depid1}   ${dep_status[0]}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"
    