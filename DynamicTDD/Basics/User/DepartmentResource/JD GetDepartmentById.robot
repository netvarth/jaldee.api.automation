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
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${SERVICE1}	   Bridal Makeup_001_1
${SERVICE2}	   Groom MakeupW_002_1
${SERVICE3}	   Groom MakeupW_003_1
${SERVICE4}	   Groom MakeupW_004_1

*** Test Cases ***
JD-TC-Get Department ById-1
    [Documentation]  Provider Get Department ById

    # ${iscorp_subdomains}=  get_iscorp_subdomains  1
    # Log  ${iscorp_subdomains}
    # Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    # Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    # Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    # ${firstname_A}=  FakerLibrary.first_name
    # Set Suite Variable  ${firstname_A}
    # ${lastname_A}=  FakerLibrary.last_name
    # Set Suite Variable  ${lastname_A}
    # ${PUSERNAME_K}=  Evaluate  ${PUSERNAME}+423822
    # ${highest_package}=  get_highest_license_pkg
    # ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_K}    ${highest_package[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Account Activation  ${PUSERNAME_K}  0
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Account Set Credential  ${PUSERNAME_K}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_K}
    # Should Be Equal As Strings    ${resp.status_code}    200
    ${PUSERNAME_K}=  Evaluate  ${PUSERNAME}+423822
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
    
    ${resp}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${sid1}  ${resp}  
    ${resp}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${sid2}  ${resp}
    ${resp}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable  ${sid3}  ${resp}
    
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
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc}   ${sid1}  ${sid2}  ${sid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid1}  ${resp.json()}
    ${resp}=  Get Department ById  ${depid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  departmentName=${dep_name1}  departmentId=${depid1}  departmentCode=${dep_code1}  departmentDescription=${dep_desc}  departmentStatus=${status[0]}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}  ${sid1}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][1]}  ${sid2}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][2]}  ${sid3}

JD-TC-Get Department ById-2
    [Documentation]  Provider Create department using Service names then Get Department ById

    # clear_service   ${PUSERNAME_K}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name2}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name2}
    ${dep_code2}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code2}
    ${resp}=  Create Department With ServiceName  ${dep_name2}  ${dep_code2}  ${dep_desc}    ${SERVICE1}  ${SERVICE2}  ${SERVICE3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${depid1}  ${resp.json()}
    ${resp}=  Get Department ById  ${depid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  departmentName=${dep_name2}  departmentId=${depid1}  departmentCode=${dep_code2}  departmentDescription=${dep_desc}  departmentStatus=${status[0]}
    ${count}=  Get Length  ${resp.json()['serviceIds']} 
    Should Be Equal As Integers  ${count}  3

JD-TC-Get Department ById-UH1
     [Documentation]  Create a department without login

     ${resp}=  Get Department ById  ${depid1}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"    "${SESSION_EXPIRED}"
     
JD-TC-Get Department ById-UH2
     [Documentation]  Create a department using consumer login

    # ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    #............provider consumer creation..........
    
    clear_customer   ${PUSERNAME_K}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${acc_id1}  ${resp.json()['id']}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lastname}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${acc_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}
    
    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${acc_id1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Department ById  ${depid1}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-Get Department ById-UH3
    [Documentation]  Provider get a department with Invalid department id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Department ById  0000
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${DETP_NOT_BELONGS_TO_THIS_ACCOUNT}"

JD-TC-Get Department ById-UH4
    [Documentation]  Provider get a another providers department id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME36}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Department ById  ${depid1}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"
    