***Settings***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        User
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***

@{countryCode}   91  +91  48 


***Test Cases***

JD-TC-GetUsersCount-1

     [Documentation]  Get users count by branch login

     ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     ${lastname_A}=  FakerLibrary.last_name
     ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+550717
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_E}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    202
     ${resp}=  Account Activation  ${PUSERNAME_E}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${PUSERNAME_E}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_E}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_E}${\n}
     Append To File  ${EXECDIR}/data/TDD_Logs/providernumbers.txt  ${SUITE NAME} - ${TEST NAME} - ${PUSERNAME_E}${\n}
     Set Suite Variable  ${PUSERNAME_E}
     ${id}=  get_id  ${PUSERNAME_E}
     Set Suite Variable  ${id}
     ${bs}=  FakerLibrary.bs
     Set Suite Variable  ${bs}
     
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
     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+336345
     clear_users  ${PUSERNAME_U1}
     Set Suite Variable  ${PUSERNAME_U1}
     ${firstname}=  FakerLibrary.name
     Set Suite Variable  ${firstname}
     ${lastname}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname}
     
     ${resp}=  Create User  ${firstname}  ${lastname}  ${countryCodes[1]}  ${PUSERNAME_U1}   ${userType[0]}    deptId=${dep_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200 
     Set Suite Variable  ${u_id}  ${resp.json()}

     ${resp}=  Get User Count
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()}  2

     ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+336346
     clear_users  ${PUSERNAME_U2}
     ${firstname1}=  FakerLibrary.name
     ${lastname1}=  FakerLibrary.last_name
     
     ${resp}=  Create User  ${firstname1}  ${lastname1}  ${countryCodes[1]}  ${PUSERNAME_U2}   ${userType[0]}    deptId=${dep_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200 
     Set Test Variable  ${u_id1}  ${resp.json()}

     ${resp}=  Get User Count
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()}  3

JD-TC-GetUsersCount -UH1

     [Documentation]   Provider get Users without login      

     ${resp}=  Get User Count
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-GetUsersCount -UH2

    [Documentation]   Consumer get users

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    #............provider consumer creation..........
    
    clear_customer   ${PUSERNAME_E}

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

    ${resp}=  Get User Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"