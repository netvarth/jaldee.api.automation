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
${SERVICE1}	   Bridal Makeup_001
${SERVICE2}	   Groom MakeupW_002
${SERVICE3}	   Groom MakeupW_003
${SERVICE4}	   Groom MakeupW_004
${default_depname}   default

*** Test Cases ***
JD-TC-Get Departments-1
    [Documentation]  Provider Get Departments

    # ${iscorp_subdomains}=  get_iscorp_subdomains  1
    # Log  ${iscorp_subdomains}
    # Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    # Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    # Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    # ${firstname_A}=  FakerLibrary.first_name
    # Set Suite Variable  ${firstname_A}
    # ${lastname_A}=  FakerLibrary.last_name
    # Set Suite Variable  ${lastname_A}
    # ${PUSERNAME_K}=  Evaluate  ${PUSERNAME}+423823
    # ${highest_package}=  get_highest_license_pkg
    # ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_K}    ${highest_package[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Account Activation  ${PUSERNAME_K}  0
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Account Set Credential  ${PUSERNAME_K}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_K}
    # Should Be Equal As Strings    ${resp.status_code}    200
    ${PUSERNAME_K}=  Evaluate  ${PUSERNAME}+423823
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
    
    # clear_service    ${PUSERNAME_K}
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

    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentName']}              ${default_depname}
    Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentCode']}              ${default_depname}
    Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentDescription']}       ${default_depname}
    Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentStatus']}            ${status[0]}
    ${count}=  Get Length  ${resp.json()['departments'][0]['serviceIds']}
	Should Be Equal As Integers  ${count}  4 
    ${dep_name1}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name1}
    ${dep_code1}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code1}
    ${dep_desc}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc}
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc}   ${sid1}  ${sid2}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid1}  ${resp.json()}
    ${dep_name2}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name2}
    ${dep_code2}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code2}
    ${resp}=  Create Department  ${dep_name2}  ${dep_code2}  ${dep_desc}    ${sid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid2}  ${resp.json()}
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['departments'][2]['departmentName']}              ${default_depname}
    Should Be Equal As Strings  ${resp.json()['departments'][2]['departmentCode']}              ${default_depname}
    Should Be Equal As Strings  ${resp.json()['departments'][2]['departmentDescription']}       ${default_depname}
    Should Be Equal As Strings  ${resp.json()['departments'][2]['departmentStatus']}            ${status[0]}
    
    Should Be Equal As Strings  ${resp.json()['departments'][1]['departmentName']}              ${dep_name1}
    Should Be Equal As Strings  ${resp.json()['departments'][1]['departmentId']}                ${depid1}
    Should Be Equal As Strings  ${resp.json()['departments'][1]['departmentCode']}              ${dep_code1}
    Should Be Equal As Strings  ${resp.json()['departments'][1]['departmentDescription']}       ${dep_desc}
    Should Be Equal As Strings  ${resp.json()['departments'][1]['departmentStatus']}            ${status[0]}
    Should Be Equal As Strings  ${resp.json()['departments'][1]['serviceIds'][0]}               ${sid1}
    Should Be Equal As Strings  ${resp.json()['departments'][1]['serviceIds'][1]}               ${sid2}
    Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentName']}              ${dep_name2}
    Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentId']}                ${depid2}
    Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentCode']}              ${dep_code2}
    Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentDescription']}       ${dep_desc}
    Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentStatus']}            ${status[0]}
    Should Be Equal As Strings  ${resp.json()['departments'][0]['serviceIds'][0]}               ${sid3}

JD-TC-Get Departments-2
    [Documentation]  Provider Get Departments

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name3}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name3}
    ${dep_code3}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code3}
    ${resp}=  Create Department  ${dep_name3}  ${dep_code3}  ${dep_desc} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid3}  ${resp.json()}
    ${resp}=  Get Departments
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['departments'][3]['departmentName']}              ${default_depname}
    Should Be Equal As Strings  ${resp.json()['departments'][3]['departmentCode']}              ${default_depname}
    Should Be Equal As Strings  ${resp.json()['departments'][3]['departmentDescription']}       ${default_depname}
    Should Be Equal As Strings  ${resp.json()['departments'][3]['departmentStatus']}            ${status[0]}   
    Should Be Equal As Strings  ${resp.json()['departments'][2]['departmentName']}              ${dep_name1}
    Should Be Equal As Strings  ${resp.json()['departments'][2]['departmentId']}                ${depid1}
    Should Be Equal As Strings  ${resp.json()['departments'][2]['departmentCode']}              ${dep_code1}
    Should Be Equal As Strings  ${resp.json()['departments'][2]['departmentDescription']}       ${dep_desc}
    Should Be Equal As Strings  ${resp.json()['departments'][2]['departmentStatus']}            ${status[0]}
    Should Be Equal As Strings  ${resp.json()['departments'][2]['serviceIds'][0]}               ${sid1}
    Should Be Equal As Strings  ${resp.json()['departments'][2]['serviceIds'][1]}               ${sid2}
    Should Be Equal As Strings  ${resp.json()['departments'][1]['departmentName']}              ${dep_name2}
    Should Be Equal As Strings  ${resp.json()['departments'][1]['departmentId']}                ${depid2}
    Should Be Equal As Strings  ${resp.json()['departments'][1]['departmentCode']}              ${dep_code2}
    Should Be Equal As Strings  ${resp.json()['departments'][1]['departmentDescription']}       ${dep_desc}
    Should Be Equal As Strings  ${resp.json()['departments'][1]['departmentStatus']}            ${status[0]}
    Should Be Equal As Strings  ${resp.json()['departments'][1]['serviceIds'][0]}               ${sid3}
    Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentName']}              ${dep_name3}
    Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentId']}                ${depid3}
    Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentCode']}              ${dep_code3}
    Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentDescription']}       ${dep_desc}
    Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentStatus']}            ${status[0]}
    Should Be Equal As Strings  ${resp.json()['departments'][0]['serviceIds']}                  []

JD-TC-Get Departments-3
    [Documentation]  Provider Create department using Service names then Get Departments

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${dep_name4}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name4}
    ${dep_code4}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code4}
    ${ser_name1}=   FakerLibrary.word
    ${ser_name2}=   FakerLibrary.word
    ${ser_name3}=   FakerLibrary.word
    ${resp}=  Create Department With ServiceName  ${dep_name4}  ${dep_code4}  ${dep_desc}    ${ser_name1}  ${ser_name2}  ${ser_name3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${depid4}  ${resp.json()}
    ${resp}=  Get Departments
    Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentName']}              ${default_depname}
    Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentCode']}              ${default_depname}
    Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentDescription']}       ${default_depname}
    Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentStatus']}            ${status[0]}   
    Should Be Equal As Strings  ${resp.json()['departments'][1]['departmentName']}              ${dep_name1}
    Should Be Equal As Strings  ${resp.json()['departments'][1]['departmentId']}                ${depid1}
    Should Be Equal As Strings  ${resp.json()['departments'][1]['departmentCode']}              ${dep_code1}
    Should Be Equal As Strings  ${resp.json()['departments'][1]['departmentDescription']}       ${dep_desc}
    Should Be Equal As Strings  ${resp.json()['departments'][1]['departmentStatus']}            ${status[0]}
    Should Be Equal As Strings  ${resp.json()['departments'][1]['serviceIds'][0]}               ${sid1}
    Should Be Equal As Strings  ${resp.json()['departments'][1]['serviceIds'][1]}               ${sid2}
    Should Be Equal As Strings  ${resp.json()['departments'][2]['departmentName']}              ${dep_name2}
    Should Be Equal As Strings  ${resp.json()['departments'][2]['departmentId']}                ${depid2}
    Should Be Equal As Strings  ${resp.json()['departments'][2]['departmentCode']}              ${dep_code2}
    Should Be Equal As Strings  ${resp.json()['departments'][2]['departmentDescription']}       ${dep_desc}
    Should Be Equal As Strings  ${resp.json()['departments'][2]['departmentStatus']}            ${status[0]}
    Should Be Equal As Strings  ${resp.json()['departments'][2]['serviceIds'][0]}               ${sid3}
    Should Be Equal As Strings  ${resp.json()['departments'][3]['departmentName']}              ${dep_name3}
    Should Be Equal As Strings  ${resp.json()['departments'][3]['departmentId']}                ${depid3}
    Should Be Equal As Strings  ${resp.json()['departments'][3]['departmentCode']}              ${dep_code3}
    Should Be Equal As Strings  ${resp.json()['departments'][3]['departmentDescription']}       ${dep_desc}
    Should Be Equal As Strings  ${resp.json()['departments'][3]['departmentStatus']}            ${status[0]}
    Should Be Equal As Strings  ${resp.json()['departments'][3]['serviceIds']}                  []
    Should Be Equal As Strings  ${resp.json()['departments'][4]['departmentId']}                ${depid4}
    Should Be Equal As Strings  ${resp.json()['departments'][4]['departmentCode']}              ${dep_code4}
    Should Be Equal As Strings  ${resp.json()['departments'][4]['departmentDescription']}       ${dep_desc}
    Should Be Equal As Strings  ${resp.json()['departments'][4]['departmentStatus']}            ${status[0]}
    ${count}=  Get Length  ${resp.json()['departments'][4]['serviceIds']} 
    Should Be Equal As Integers  ${count}  3

JD-TC-Get Departments-UH1
     [Documentation]  Get departments without login

     ${resp}=  Get Departments
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"    "${SESSION_EXPIRED}"
     
JD-TC-Get Departments-UH2
     [Documentation]  Get departments using consumer login

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

    ${resp}=  Get Departments
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"
     