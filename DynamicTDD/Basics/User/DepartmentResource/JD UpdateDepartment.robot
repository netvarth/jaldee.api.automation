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
${description}  Service

*** Test Cases ***
JD-TC-Update Department-1
    [Documentation]  Provider Update Department using service id

    # ${iscorp_subdomains}=  get_iscorp_subdomains  1
    # Log  ${iscorp_subdomains}
    # Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    # Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    # Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    # ${firstname_A}=  FakerLibrary.first_name
    # Set Suite Variable  ${firstname_A}
    # ${lastname_A}=  FakerLibrary.last_name
    # Set Suite Variable  ${lastname_A}
    # ${PUSERNAME_K}=  Evaluate  ${PUSERNAME}+423825
    # ${highest_package}=  get_highest_license_pkg
    # ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_K}    ${highest_package[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Account Activation  ${PUSERNAME_K}  0
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Account Set Credential  ${PUSERNAME_K}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_K}
    # Should Be Equal As Strings    ${resp.status_code}    200
    ${PUSERNAME_K}=  Evaluate  ${PUSERNAME}+423825
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
    ${resp}=   Create Service  ${SERVICE1}  ${ser_desc}  ${ser_duratn}   ${bool[0]}  ${total_amount}   ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE2}  ${ser_desc}  ${ser_duratn}    ${bool[0]}  ${total_amount}    ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid2}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE3}  ${ser_desc}  ${ser_duratn}    ${bool[0]}  ${total_amount}    ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid3}  ${resp.json()}  
    
    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${dep_name1}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name1}
    ${dep_code1}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code1}
    ${dep_desc}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc}
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc}   ${sid1}  ${sid2}   ${sid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid1}  ${resp.json()}
    ${dep_name2}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name2}
    ${dep_code2}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code2}
    ${resp}=  Update Department  ${depid1}  ${dep_name2}  ${dep_code2}  ${dep_desc}  ${sid1}  ${sid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Department ById  ${depid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  departmentName=${dep_name2}  departmentId=${depid1}  departmentCode=${dep_code2}  departmentDescription=${dep_desc}  departmentStatus=${status[0]}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}  ${sid1}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][1]}  ${sid2}
    Should Not Contain          ${resp.json()}                  ${sid3}

JD-TC-Update Department-2
    [Documentation]  Provider Update department using same Service ids

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Department  ${depid1}  ${dep_name2}  ${dep_code2}  ${dep_desc}    ${sid1}  ${sid1}  ${sid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Department ById  ${depid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}  ${sid1}
    ${count}=  Get Length  ${resp.json()['serviceIds']} 
    Should Be Equal As Integers  ${count}  1

JD-TC-Update Department-3
    [Documentation]  Provider Update a department with no service details

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Department  ${depid1}  ${dep_name2}  ${dep_code2}  ${dep_desc}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Department ById  ${depid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  departmentName=${dep_name2}  departmentId=${depid1}  departmentCode=${dep_code2}  departmentDescription=${dep_desc}  departmentStatus=${status[0]}
    Should Not Contain  ${resp.json()}  ${sid1}
    Should Not Contain  ${resp.json()}  ${sid2}
    Should Not Contain  ${resp.json()}  ${sid3}

JD-TC-Update Department-4
    [Documentation]  Provider Update department using same Service names

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name3}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name3}
    ${dep_code3}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code3}

    ${SERVICE1}=	   FakerLibrary.Word
    ${SERVICE2}=	   FakerLibrary.Word
    ${SERVICE3}=	   FakerLibrary.Word

    ${resp}=  Create Department With ServiceName  ${dep_name3}   ${dep_code3}  ${dep_desc}   ${SERVICE1}   ${SERVICE2}   ${SERVICE3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${depid3}  ${resp.json()}
    ${resp}=  Get Department ById  ${depid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${newSid1}   ${resp.json()['serviceIds'][0]}
    ${resp}=  Update Department  ${depid3}  ${dep_name3}   ${dep_code3}  ${dep_desc}   ${newSid1}   ${newSid1}  ${newSid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Department ById  ${depid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()['serviceIds']} 
    Should Be Equal As Integers  ${count}  1

JD-TC-Update Department-UH1
    [Documentation]  Provider Update a department to already existing department name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name}=  FakerLibrary.bs
    ${dep_code}=   Random Int  min=100   max=999
    ${resp}=  Create Department   ${dep_name}   ${dep_code}  ${dep_desc}    ${sid1}  ${sid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid2}  ${resp.json()}
    ${resp}=  Update Department  ${depid2}   ${dep_name1}   ${dep_code3}  ${dep_desc}   ${sid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"  "${DETP_CODE_ALREADY_EXISTS}"

JD-TC-Update Department-UH2
    [Documentation]  Provider Create already existing department code

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name}=  FakerLibrary.bs
    ${resp}=  Update Department  ${depid2}  ${dep_name}   ${dep_code2}  ${dep_desc}   ${sid2}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${DETP_CODE_ALREADY_EXISTS}"

JD-TC-Update Department-UH3
    [Documentation]  Provider Update a department with another providers service name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Toggle Department Enable
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name}=  FakerLibrary.bs
    ${dep_code}=   Random Int  min=100   max=999
    ${resp}=  Create Department   ${dep_name}   ${dep_code}  ${dep_desc}   
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid123}  ${resp.json()}
    ${resp}=  Update Department  ${depid123}   ${dep_name1}  ${dep_code1}  ${dep_desc}    ${sid1}  
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_NOT_EXISTS}"

JD-TC-Update Department-UH5
    [Documentation]  Create a department without login
    
    ${resp}=  Update Department  ${depid1}  ${dep_name1}  ${dep_code1}  ${dep_desc}   ${sid1}  ${sid2}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   "${resp.json()}"    "${SESSION_EXPIRED}"
     
JD-TC-Update Department-UH6
    [Documentation]  Create a department using consumer login
    # ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${CUSERNAME0}  ${token}  Create Sample Customer  ${account_id}  primaryMobileNo=${CUSERNAME0}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME0}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Update Department  ${depid1}  ${dep_name1}  ${dep_code1}  ${dep_desc}   ${sid1}  ${sid2}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-Update Department-UH7
    [Documentation]  Provider Update a department with Invalid service id
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name}=  FakerLibrary.bs
    ${dep_code}=   Random Int  min=100   max=999
    ${invalid_ser_id}=   Random Int   min=-499   max=-1
    ${resp}=  Update Department  ${depid1}  ${dep_name}  ${dep_code}  ${dep_desc}   ${invalid_ser_id}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_NOT_EXISTS}"
    