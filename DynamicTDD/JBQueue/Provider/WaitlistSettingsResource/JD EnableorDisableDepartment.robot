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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${SERVICE1}	   Bridal Makeup_A
${SERVICE2}	   Groom MakeupW_B
${SERVICE3}	   Groom MakeupW_C
${SERVICE4}	   Groom MakeupW_D

*** Test Cases ***
JD-TC-Enable or Disable Department-1
    [Documentation]  provider successfully disables a department 

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${PUSERNAME_K}=  Evaluate  ${PUSERNAME}+423821
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_K}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    202
    ${resp}=  Account Activation  ${PUSERNAME_K}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_K}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_K}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_K}${\n}
    Set Suite Variable  ${PUSERNAME_K}
    ${id}=  get_id  ${PUSERNAME_K}
    Set Suite Variable  ${id}

    ${resp}=  Toggle Department Enable
    Should Be Equal As Strings  ${resp.status_code}  200

    ${dep_name1}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name1}
    ${dep_code1}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code1}
    ${dep_desc}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc}

    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${did01}  ${resp.json()}

    ${desc}=   FakerLibrary.sentence
    Set Suite Variable    ${desc}
    ${total_amount}=    Random Int  min=100  max=500
    ${min_prepayment}=  Random Int   min=1   max=50
    ${ser_duratn}=      Random Int   min=10   max=30
    Set Suite Variable   ${ser_duratn}

    ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}   ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}  ${did01}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()}  

    ${resp}=  Get Department ById  ${did01}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}  ${sid1}

    ${resp}=  Disable Department  ${did01} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Enable or Disable Department-2
    [Documentation]  provider successfully enables a department which is disabled by him

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Departments
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Department  ${did01}
    Log   ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Enable service   ${sid1} 

    ${resp}=  Get Services in Department  ${did01}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain  ${resp.json()['services']}  ${sid1}

    ${resp}=  Add Services To Department  ${did01}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Department ById  ${did01}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  departmentName=${dep_name1}  departmentId=${did01}  departmentCode=${dep_code1}  departmentDescription=${dep_desc}  departmentStatus=${status[0]}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}  ${sid1}

JD-TC-Enable or Disable Department-UH1
    [Documentation]  provider created and added a service to a disabled department

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Department  ${did01} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total_amount}=    Random Int  min=100  max=500
    ${min_prepayment}=  Random Int   min=1   max=50
    
    ${resp}=  Create Service Department  ${SERVICE2}  ${desc}   ${ser_duratn}   ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}  ${did01}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INACTIVE_DEPARTMENT}"

JD-TC-Enable or Disable Department-UH2
    [Documentation]  provider creating new department with same name as disabled departrment

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${DETP_ALREADY_EXISTS}"

JD-TC-Enable or Disable Department-UH3
    [Documentation]  provider creating new department with same department code as disabled departrment

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${dep_name}=  FakerLibrary.bs
    ${resp}=  Create Department  ${dep_name}  ${dep_code1}  ${dep_desc} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${DETP_CODE_ALREADY_EXISTS}"
   
JD-TC-Enable or Disable Department-UH4
    [Documentation]  provider updating a disabled departrment

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Department  ${did01}  ${dep_name1}  ${dep_code1}  ${dep_desc}   ${sid1} 
   # Should Be Equal As Strings  ${resp.status_code}  200
   
     



    

