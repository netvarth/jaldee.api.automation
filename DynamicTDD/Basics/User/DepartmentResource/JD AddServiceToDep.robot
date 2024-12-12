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
${SERVICE1}	   Bridal Makeup_1
${SERVICE2}	   Groom MakeupW_2
${SERVICE3}	   Groom MakeupW_3
${SERVICE4}	   Groom MakeupW_4
${SERVICE5}	   Groom MakeupW_5
${SERVICE6}	   Groom MakeupW_6
${SERVICE7}	   Groom MakeupW_7
${SERVICE8}	   Groom MakeupW_8

*** Test Cases ***
JD-TC-Add Service To Department-1
    [Documentation]  Provider selecting filter by department after creating services

    # ${iscorp_subdomains}=  get_iscorp_subdomains  1
    # Log  ${iscorp_subdomains}
    # Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    # Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    # Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    # ${firstname_A}=  FakerLibrary.first_name
    # Set Suite Variable  ${firstname_A}
    # ${lastname_A}=  FakerLibrary.last_name
    # Set Suite Variable  ${lastname_A}
    # ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+423812
    # ${highest_package}=  get_highest_license_pkg
    # ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_E}    ${highest_package[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Account Activation  ${PUSERNAME_E}  0
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Account Set Credential  ${PUSERNAME_E}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_E}
    # Should Be Equal As Strings    ${resp.status_code}    200
    ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+423812
    ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_E}=  Provider Signup without Profile  PhoneNumber=${PUSERNAME_E}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_E}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/providernumbers.txt  ${SUITE NAME} - ${TEST NAME} - ${PUSERNAME_E}${\n}
    Set Suite Variable  ${PUSERNAME_E}
    ${id}=  get_id  ${PUSERNAME_E}
    Set Suite Variable  ${id}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${sid01}  ${resp}  
    ${resp}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${sid02}  ${resp}
    ${resp}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable  ${sid03}  ${resp}
    ${resp}=  Create Sample Service  ${SERVICE4}
    Set Suite Variable  ${sid04}  ${resp}
    ${resp}=   Toggle Department Enable
    Should Be Equal As Strings  ${resp.status_code}  200
    #services added to default department

JD-TC-Add Service To Department-2
    [Documentation]  provider adding services to new department from default department

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name1}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name1}
    ${dep_code1}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code1}
    ${dep_desc}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc}
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid01}  ${resp.json()}
    ${resp}=  Add Services To Department  ${depid01}  ${sid01}  
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  5s

    ${resp}=  Get Department ById  ${depid01}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  departmentName=${dep_name1}  departmentId=${depid01}  departmentCode=${dep_code1}  departmentDescription=${dep_desc}   departmentStatus=${status[0]}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}  ${sid01}    
    ${resp}=  Get Departments  
    Should Be Equal As Strings  ${resp.status_code}  200
    # services added to new department and removed from default department 

JD-TC-Add Service To Department-3
    [Documentation]  provider creating and adding new services to new department 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${dep_name2}=  FakerLibrary.bs
    Set Suite Variable    ${dep_name2}
    ${dep_code2}=   Random Int  min=100   max=999  
    Set Suite Variable    ${dep_code2}
    ${resp}=  Create Department  ${dep_name2}  ${dep_code2}  ${dep_desc}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid02}  ${resp.json()}
    ${desc}=   FakerLibrary.sentence
    Set Suite Variable    ${desc}
    ${total_amount}=    Random Int   min=100  max=500
    ${min_prepayment}=  Random Int   min=1    max=50
    ${ser_duratn}=      Random Int   min=10   max=30
    Set Suite Variable   ${ser_duratn}
    ${resp}=  Create Service Department  ${SERVICE5}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}  ${depid02}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid05}  ${resp.json()}
    ${resp}=  Get Department ById  ${depid02}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  departmentName=${dep_name2}  departmentId=${depid02}  departmentCode=${dep_code2}  departmentDescription=${dep_desc}  departmentStatus=${status[0]}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}  ${sid05}

JD-TC-Add Service To Department-4
    [Documentation]  provider creating and adding new services to existing department 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${total_amount}=  Random Int  min=100  max=500
    ${min_prepayment}=  Random Int   min=1   max=50
    ${resp}=  Create Service Department  ${SERVICE6}  ${desc}   ${ser_duratn}   ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}  ${depid02}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid06}  ${resp.json()}
    ${resp}=  Get Department ById  ${depid02}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  departmentName=${dep_name2}  departmentId=${depid02}  departmentCode=${dep_code2}  departmentDescription=${dep_desc}  departmentStatus=${status[0]}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}  ${sid05}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][1]}  ${sid06}

JD-TC-Add Service To Department-5
    [Documentation]  Provider adding more services to a department

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Add Services To Department  ${depid01}  ${sid02}  ${sid03}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Department ById  ${depid01}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  departmentName=${dep_name1}  departmentId=${depid01}  departmentCode=${dep_code1}  departmentDescription=${dep_desc}  departmentStatus=${status[0]}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}  ${sid01}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][1]}  ${sid02}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][2]}  ${sid03}
    


JD-TC-Add Service To Department-7
    [Documentation]  Provider adding same service to a another department

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${dep_name3}=  FakerLibrary.bs
    ${dep_code3}=   Random Int  min=100   max=999
    ${resp}=  Create Department  ${dep_name3}  ${dep_code3}  ${dep_desc} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid03}  ${resp.json()}    
    ${resp}=  Add Services To Department  ${depid03}  ${sid01}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${resp}=  Get Department ById  ${depid03}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  departmentName=${dep_name3}  departmentId=${depid03}  departmentCode=${dep_code3}  departmentDescription=${dep_desc}  departmentStatus=${status[0]}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}  ${sid01}
    ${resp}=  Get Department ById  ${depid01}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  departmentName=${dep_name1}  departmentId=${depid01}  departmentCode=${dep_code1}  departmentDescription=${dep_desc}  departmentStatus=${status[0]}
    Should Not Be Equal As Strings  ${resp.json()['serviceIds']}    ${sid01} 

JD-TC-Add Service To Department-8
    [Documentation]  Provider adding service with same name as another providers service

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${PUSERNAME_F}=  Evaluate  ${PUSERNAME}+423813
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_F}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_F}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_F}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_F}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_F}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_F}${\n}
    Set Suite Variable  ${PUSERNAME_F}
    ${id}=  get_id  ${PUSERNAME_F}
    Set Suite Variable  ${id}
    
    ${resp}=   Toggle Department Enable
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name4}=  FakerLibrary.bs
    ${dep_code4}=   Random Int  min=100   max=999
    ${resp}=  Create Department  ${dep_name4}  ${dep_code4}  ${dep_desc} 
    Set Suite Variable  ${depid04}  ${resp.json()}
    ${total_amount}=  Random Int  min=100  max=500
    ${min_prepayment}=  Random Int   min=1   max=50
    ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}   ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}   ${depid04}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid011}  ${resp.json()}
    ${resp}=  Get Department ById  ${depid04}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  departmentName=${dep_name4}  departmentId=${depid04}  departmentCode=${dep_code4}  departmentDescription=${dep_desc}  departmentStatus=${status[0]}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}  ${sid011} 

JD-TC-Add Service To Department-UH1
    [Documentation]  Provider adding already added service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Add Services To Department  ${depid01}  ${sid03}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${SERVICE3} ${SERVICE_ALREADT_ADD}"

JD-TC-Add Service To Department-UH2
    [Documentation]  Provider adding a invalid service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Add Services To Department  ${depid01}  000
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_NOT_EXISTS}"

JD-TC-Add Service To Department-UH3
    [Documentation]  Provider adding disabled service to department

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Disable service  ${sid04} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Add Services To Department  ${depid03}  ${sid04}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${SERVICE4} ${SERVICE_NOT_ENABLED}"

JD-TC-Add Service To Department-UH4
    [Documentation]  Provider adding service to department of another provider
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Add Services To Department  ${depid04}  ${sid03}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

JD-TC-Add Service To Department-UH5
    [Documentation]  Adding a service to department without login

    ${resp}=  Add Services To Department  ${depid01}  ${sid05}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   "${resp.json()}"    "${SESSION_EXPIRED}"

JD-TC-Add Service To Department-UH6
    [Documentation]  Adding a service to department using consumer login

    # ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${CUSERNAME0}  ${token}  Create Sample Customer  ${account_id}  primaryMobileNo=${CUSERNAME0}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME0}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Add Services To Department  ${depid01}  ${sid05}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-Add Service To Department-UH7
    [Documentation]  Provider using service of another provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Add Services To Department  ${depid03}  ${sid011}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

JD-TC-Add Service To Department-UH8
    [Documentation]  provider created and added a service without specifying department

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${total_amount}=  Random Int  min=100  max=500
    ${min_prepayment}=  Random Int   min=1   max=50
    ${resp}=  Create Service Department  ${SERVICE7}  ${desc}   ${ser_duratn}    ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}    ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${DEPT_ID}"
       

JD-TC-Add Service To Department-UH9
	[Documentation]  Provider adding services with same name to different department

	${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${total_amount}=  Random Int  min=100  max=500
    ${min_prepayment}=  Random Int   min=1   max=50
    ${resp}=  Create Service Department  ${SERVICE2}  ${desc}   ${ser_duratn}   ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}  ${depid02}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${SERVICE_CANT_BE_SAME}
    # ${resp}=  Get Department ById  ${depid02}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  departmentName=${dep_name2}  departmentId=${depid02}  departmentCode=${dep_code2}  departmentDescription=${dep_desc}  departmentStatus=${status[0]}
    # Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}  ${sid05}
    # Should Be Equal As Strings  ${resp.json()['serviceIds'][1]}  ${sid06}
    # Should Be Equal As Strings  ${resp.json()['serviceIds'][2]}  ${sid022}  


















































