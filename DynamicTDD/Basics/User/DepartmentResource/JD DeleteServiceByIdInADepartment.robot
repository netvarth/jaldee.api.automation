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
${SERVICE1}	   Bridal Makeup_001
${SERVICE2}	   Groom MakeupW_002
${SERVICE3}	   Groom MakeupW_003
${SERVICE4}	   Groom MakeupW_004
${SERVICE5}	   Groom MakeupW_005
${SERVICE6}	   Groom MakeupW_006
${SERVICE7}	   Bridal Makeup_007
${SERVICE8}	   Groom MakeupW_008
${SERVICE9}	   Groom MakeupW_009
${SERVICE10}	   Groom MakeupW_010
${SERVICE11}	   Groom MakeupW_011
${SERVICE12}	   Groom MakeupW_012
${SERVICE13}	   Groom MakeupW_013
${SERVICE14}	   Groom MakeupW_014
${SERVICE15}	   Groom MakeupW_015
${SERVICE16}	   Groom MakeupW_016



*** Test Cases ***
JD-TC-Delete Service In a Department-1
    [Documentation]  Provider deleting service from department

    # ${iscorp_subdomains}=  get_iscorp_subdomains  1
    # Log  ${iscorp_subdomains}
    # Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    # Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    # Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    # ${firstname_A}=  FakerLibrary.first_name
    # Set Suite Variable  ${firstname_A}
    # ${lastname_A}=  FakerLibrary.last_name
    # Set Suite Variable  ${lastname_A}
    # ${PUSERNAME_K}=  Evaluate  ${PUSERNAME}+423820
    # ${highest_package}=  get_highest_license_pkg
    # ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_K}    ${highest_package[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Account Activation  ${PUSERNAME_K}  0
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Account Set Credential  ${PUSERNAME_K}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_K}
    # Should Be Equal As Strings    ${resp.status_code}    200
    ${PUSERNAME_K}=  Evaluate  ${PUSERNAME}+423820
    ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_K}=  Provider Signup without Profile  PhoneNumber=${PUSERNAME_K}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_K}${\n}
    Set Suite Variable  ${PUSERNAME_K}
    ${id}=  get_id  ${PUSERNAME_K}
    Set Suite Variable  ${id}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${ser_desc}=   FakerLibrary.word
    Set Suite Variable   ${ser_desc}
    ${total_amount}=    Random Int  min=100  max=500
    Set Suite Variable  ${total_amount}
    ${min_prepayment}=  Random Int   min=1   max=50
    Set Suite Variable   ${min_prepayment}
    ${ser_duratn}=      Random Int   min=10   max=30
    Set Suite Variable   ${ser_duratn}
    ${resp}=   Create Service  ${SERVICE1}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE2}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid2}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE3}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid3}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE4}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid4}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE5}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid5}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE6}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid6}  ${resp.json()} 
    ${resp}=   Create Service  ${SERVICE7}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid7}  ${resp.json()}   
    ${resp}=   Create Service  ${SERVICE8}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid8}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE9}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid9}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE10}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid10}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE11}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid11}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE12}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid12}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE13}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid13}  ${resp.json()} 

    ${resp}=   Create Service  ${SERVICE15}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid15}  ${resp.json()} 

    ${resp}=   Create Service  ${SERVICE16}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid16}  ${resp.json()} 

    ${resp}=  Toggle Department Enable
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  03s
    ${resp}=  Get Departments
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name1}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name1}
    ${dep_code1}=   Random Int  min=100   max=200
    Set Suite Variable   ${dep_code1}
    ${dep_desc}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc}
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc}   ${sid1}  ${sid2}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid1}  ${resp.json()}
    ${dep_name11}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name11}
    ${dep_code11}=   Random Int  min=201   max=300
    Set Suite Variable   ${dep_code11}
    ${resp}=  Create Department  ${dep_name11}  ${dep_code11}  ${dep_desc}   ${sid3}  ${sid4}   
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid11}  ${resp.json()}
    ${resp}=  Get Department ById  ${depid11}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Delete Service ById In A Department  ${depid11}  ${sid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id   ${sid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE3}  description=${ser_desc}   serviceDuration=${ser_duratn}   notification=${bool[1]}  notificationType=${notifytype[2]}  status=${status[1]}  bType=${btype}   
    


JD-TC-Delete Service In a Department-3
    [Documentation]  Provider deleting another service from a department

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name12}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name12}
    ${dep_code12}=   Random Int  min=301   max=400
    Set Suite Variable   ${dep_code12}
    ${resp}=  Enable service   ${sid3} 
    ${resp}=  Create Department  ${dep_name12}  ${dep_code12}  ${dep_desc}    ${sid3}   ${sid5}   ${sid6}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid12}  ${resp.json()}
    ${resp}=  Delete Service ById In A Department  ${depid12}  ${sid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Delete Service ById In A Department  ${depid12}  ${sid5}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Service By Id   ${sid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE3}  status=${status[1]}  department=${depid12}
    ${resp}=   Get Service By Id   ${sid5} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE5}  status=${status[1]}  department=${depid12}




JD-TC-Delete Service In a Department-4
    [Documentation]  Provider adding new service to a department then trying to delete it

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name13}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name13}
    ${dep_code13}=   Random Int  min=401   max=500
    Set Suite Variable   ${dep_code13}
    ${resp}=  Enable service   ${sid3}
    ${resp}=  Create Department  ${dep_name13}  ${dep_code13}  ${dep_desc}   ${sid3}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid13}  ${resp.json()}
    ${resp}=  Add Services To Department  ${depid13}  ${sid7}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name14}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name14}
    ${dep_code14}=   Random Int  min=501   max=600
    Set Suite Variable   ${dep_code14}
    ${resp}=  Create Department  ${dep_name14}  ${dep_code14}  ${dep_desc}   ${sid8}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid14}  ${resp.json()}
    ${resp}=  Add Services To Department  ${depid14}  ${sid9}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Delete Service ById In A Department  ${depid14}  ${sid9}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Service By Id   ${sid9} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE9}  status=${status[1]}  department=${depid14}


JD-TC-Delete Service In a Department-5
    [Documentation]  Provider enable deleted  service, then again trying to delete it from that same department

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name15}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name15}
    ${dep_code15}=   Random Int  min=601   max=700
    Set Suite Variable   ${dep_code15}

    ${resp}=  Enable service   ${sid9}
    ${resp}=  Create Department  ${dep_name15}  ${dep_code15}  ${dep_desc}   ${sid9}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid15}  ${resp.json()}
    ${resp}=  Delete Service ById In A Department  ${depid15}   ${sid9}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Service By Id   ${sid9} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE9}  status=${status[1]}  department=${depid15}

    ${resp}=  Get Services in Department  ${depid15}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain  ${resp.json()['services']}  ${sid9}
    ${resp}=  Enable service   ${sid9}
    ${resp}=   Get Service By Id   ${sid9} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE9}  status=${status[0]}  department=${depid15}
    # ${resp}=  Add Services To Department  ${depid15}  ${sid9}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    

    ${dep_name16}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name16}
    ${dep_code16}=   Random Int  min=701   max=800
    Set Suite Variable   ${dep_code16}
    ${resp}=  Create Department  ${dep_name16}  ${dep_code16}  ${dep_desc}   ${sid10}  ${sid11}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid16}  ${resp.json()}
    ${resp}=  Delete Service ById In A Department  ${depid16}   ${sid10}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable service   ${sid10}
    ${resp}=   Get Service By Id   ${sid10} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE10}  status=${status[0]}  department=${depid16}

    # ${resp}=  Add Services To Department  ${depid16}  ${sid10}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Delete Service ById In A Department  ${depid16}   ${sid10}
    Should Be Equal As Strings  ${resp.status_code}  200
    

JD-TC-Delete Service In a Department-6
    [Documentation]  Provider deleting all serviceIds in a department

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name17}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name17}
    ${dep_code17}=   Random Int  min=801   max=900
    Set Suite Variable   ${dep_code17}
    ${resp}=  Create Department  ${dep_name17}  ${dep_code17}  ${dep_desc}   ${sid12}  ${sid13}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid17}  ${resp.json()}
    ${resp}=  Delete Service ById In A Department  ${depid17}  ${sid12}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Service By Id   ${sid12} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE12}  status=${status[1]}  department=${depid17}

    ${resp}=  Delete Service ById In A Department  ${depid17}  ${sid13}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Service By Id   ${sid13} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE13}  status=${status[1]}  department=${depid17}
   

JD-TC-Delete Service In a Department-7
    [Documentation]  Provider deleting a service from  department that service become disabled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=   Create Service  ${SERVICE15}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${sid15}  ${resp.json()} 
    ${dep_name18}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name18}
    ${dep_code18}=   Random Int  min=801   max=900
    Set Suite Variable   ${dep_code18}
    ${resp}=  Create Department  ${dep_name18}  ${dep_code18}  ${dep_desc}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid18}  ${resp.json()}
    ${resp}=  Add Services To Department  ${depid18}  ${sid15}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Delete Service ById In A Department  ${depid18}  ${sid15}
    Should Be Equal As Strings  ${resp.status_code}  200
    

    ${resp}=  Get Services in Department  ${depid18}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Service By Id  ${sid15}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE15}  description=${ser_desc}   serviceDuration=${ser_duratn}   notification=${bool[1]}  notificationType=${notifytype[2]}  status=${status[1]}  bType=${btype}   


JD-TC-Delete Service In a Department-UH1
    [Documentation]  Provider deleting already deleted service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${dep_name21}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name21}
    ${dep_code21}=   Random Int  min=1001   max=1201
    Set Suite Variable   ${dep_code21}
    ${resp}=  Create Department  ${dep_name21}  ${dep_code21}  ${dep_desc}   ${sid16} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid21}  ${resp.json()}

    ${resp}=  Delete Service ById In A Department  ${depid21}  ${sid16}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Service By Id   ${sid16} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE16}  status=${status[1]}  department=${depid21}

    ${resp}=  Delete Service ById In A Department  ${depid21}  ${sid16}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_ALREADY_INACTIVE}"
    # Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_NOT_IN_THIS_DEPT}"
    ${resp}=  Enable service   ${sid16} 

    ${resp}=  Delete Service ById In A Department  ${depid21}  ${sid16}
    Should Be Equal As Strings  ${resp.status_code}  200
    


JD-TC-Delete Service In a Department-UH2
    [Documentation]  Provider deleting a invalid service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Delete Service ById In A Department  ${depid1}  000
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${VALID_SERVICE_ID}"


JD-TC-Delete Service In a Department-UH3
    [Documentation]  Provider deleting other provider's service id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME22}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Toggle Department Enable
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Delete Service ById In A Department  ${depid1}  ${sid5}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"


JD-TC-Delete Service In a Department-UH4
    [Documentation]  Provider deleting a service that belongs to other department

    ${resp}=  Encrypted Provider Login  ${PUSERNAME22}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name2}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name2}
    ${dep_code2}=   Random Int  min=901   max=999
    Set Suite Variable   ${dep_code2}
    ${resp}=  Create Department  ${dep_name2}  ${dep_code2}  ${dep_desc} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid2}  ${resp.json()}
    ${total_amount}=    Random Int  min=100  max=500
    Set Suite Variable  ${total_amount}
    ${min_prepayment}=  Random Int   min=1   max=50
    Set Suite Variable   ${min_prepayment}
    ${resp}=  Create Service Department  ${SERVICE14}  ${dep_desc}   ${ser_duratn}   ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}   ${depid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid14}  ${resp.json()}
    ${resp}=  Delete Service ById In A Department  ${depid2}  ${sid4}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"


JD-TC-Delete Service In a Department-UH5
    [Documentation]  Adding a service to department without login

    ${resp}=  Delete Service ById In A Department  ${depid1}  ${sid5}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   "${resp.json()}"    "${SESSION_EXPIRED}"
    

JD-TC-Delete Service In a Department-UH6
    [Documentation]  Adding a service to department using consumer login

    # ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${CUSERNAME0}  ${token}  Create Sample Customer  ${account_id}  primaryMobileNo=${CUSERNAME0}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME0}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Delete Service ById In A Department  ${depid1}  ${sid5}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"
     

JD-TC-Verify Delete Service In a Department-1
    [Documentation]  Verify Provider deleting service from department

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Department ById  ${depid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()['serviceIds']} 
    Should Be Equal As Integers  ${count}  2
    Verify Response  ${resp}  departmentName=${dep_name1}  departmentId=${depid1}  departmentCode=${dep_code1}  departmentDescription=${dep_desc}  departmentStatus=${status[0]}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}  ${sid1}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][1]}  ${sid2}
    ${resp}=  Get Department ById  ${depid11}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()['serviceIds']} 
    Should Be Equal As Integers  ${count}  1
    Verify Response  ${resp}  departmentName=${dep_name11}  departmentId=${depid11}  departmentCode=${dep_code11}  departmentDescription=${dep_desc}  departmentStatus=${status[0]}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}  ${sid4}
    Should Not Contain  ${resp.json()}  ${sid3}


JD-TC-Verify Delete Service In a Department-2
    [Documentation]  Verify Provider deleting another service from a department

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Department ById  ${depid12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()['serviceIds']} 
    Should Be Equal As Integers  ${count}  1
    Verify Response  ${resp}  departmentName=${dep_name12}  departmentId=${depid12}  departmentCode=${dep_code12}  departmentDescription=${dep_desc}  departmentStatus=${status[0]}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}  ${sid6}
    Should Not Contain  ${resp.json()}  ${sid3}
    Should Not Contain  ${resp.json()}  ${sid5}


JD-TC-Verify Delete Service In a Department-3
    [Documentation]  Verify Provider adding new service to a department then trying to delete it

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Department ById  ${depid13}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()['serviceIds']} 
    Should Be Equal As Integers  ${count}  2
    Verify Response  ${resp}  departmentName=${dep_name13}  departmentId=${depid13}  departmentCode=${dep_code13}  departmentDescription=${dep_desc}  departmentStatus=${status[0]}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}  ${sid3}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][1]}  ${sid7}
    ${resp}=  Get Department ById  ${depid14}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()['serviceIds']} 
    Should Be Equal As Integers  ${count}  1
    Verify Response  ${resp}  departmentName=${dep_name14}  departmentId=${depid14}  departmentCode=${dep_code14}  departmentDescription=${dep_desc}  departmentStatus=${status[0]}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}  ${sid8}
    Should Not Contain  ${resp.json()}  ${sid9}


JD-TC-Verify Delete Service In a Department-4
    [Documentation]   Verify Provider adding a already deleted  service to a department then again trying to delete it

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Department ById  ${depid15}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()['serviceIds']} 
    Should Be Equal As Integers  ${count}  1
    Verify Response  ${resp}  departmentName=${dep_name15}  departmentId=${depid15}  departmentCode=${dep_code15}  departmentDescription=${dep_desc}  departmentStatus=${status[0]}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}  ${sid9}
    ${resp}=  Get Department ById  ${depid16}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()['serviceIds']} 
    Should Be Equal As Integers  ${count}  1
    Verify Response  ${resp}  departmentName=${dep_name16}  departmentId=${depid16}  departmentCode=${dep_code16}  departmentDescription=${dep_desc}  departmentStatus=${status[0]}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}  ${sid11}
    Should Not Contain  ${resp.json()}  ${sid10}


JD-TC-Verify Delete Service In a Department-5
    [Documentation]  Verify Provider deleting all serviceIds in a department

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Department ById  ${depid17}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()['serviceIds']} 
    Should Be Equal As Integers  ${count}  0
    Verify Response  ${resp}  departmentName=${dep_name17}  departmentId=${depid17}  departmentCode=${dep_code17}  departmentDescription=${dep_desc}  departmentStatus=${status[0]}
    Should Not Contain  ${resp.json()}  ${sid3}
    Should Not Contain  ${resp.json()}  ${sid2}
    Should Be Equal As Strings  ${resp.json()['serviceIds']}  []




