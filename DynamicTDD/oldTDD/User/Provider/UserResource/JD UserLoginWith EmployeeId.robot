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
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_musers.py


*** Variables ***
${SERVICE1}  Makeup  
${SERVICE2}  Hairmakeup 
${SERVICE3}  Facial
${SERVICE4}  Bridal makeup 
${SERVICE5}  Hair remove
${SERVICE6}  Bleach
${SERVICE7}  Hair cut
@{emptylist} 
${loginIdType}    EmployeeId


***Test Cases***

JD-TC-UserLoginwithEmployeeid-1

    [Documentation]  Create a Sample user and get the employee id then login with that id.

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${userSubDomain}  ${iscorp_subdomains[0]['userSubDomain']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+560617
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${MUSERNAME_E}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${MUSERNAME_E}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}   
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${MUSERNAME_E}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/providernumbers.txt  ${SUITE NAME} - ${TEST NAME} - ${MUSERNAME_E}${\n}
     Set Suite Variable  ${MUSERNAME_E}
     ${id}=  get_id  ${MUSERNAME_E}
     ${ids}=  get_acc_id  ${MUSERNAME_E}
     Set Suite Variable  ${ids}
     ${bs}=  FakerLibrary.bs
     Set Suite Variable  ${bs}
     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+336145
     clear_users  ${PUSERNAME_U1}
     Set Suite Variable  ${PUSERNAME_U1}
     ${firstname}=  FakerLibrary.name
     Set Suite Variable  ${firstname}
     ${lastname}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname}
     ${dob}=  FakerLibrary.Date
     Set Suite Variable  ${dob}
     # ${pin}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200 
     Set Suite Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
     Set Suite Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
     Set Suite Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    


     ${whpnum}=  Evaluate  ${PUSERNAME}+336245
     ${tlgnum}=  Evaluate  ${PUSERNAME}+336345

     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum} 
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}

     ${resp}=  Get User By Id      ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    # Set Suite Variable      ${PUSERNAME_U1}     ${resp.json()['mobileNo']}
    Set Suite Variable      ${email}     ${resp.json()['email']}
    Set Suite Variable      ${employee_id}     ${resp.json()['employeeId']}

    ${firstname1}=  FakerLibrary.name
     Set Suite Variable  ${firstname1}
     ${lastname1}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname1}
     ${dob1}=  FakerLibrary.Date
     Set Suite Variable  ${dob1}

     ${whpnum1}=  Evaluate  ${PUSERNAME}+336445
     Set Suite Variable  ${whpnum1}
     ${tlgnum1}=  Evaluate  ${PUSERNAME}+336545
     Set Suite Variable  ${tlgnum1}

     ${resp}=  Update User  ${u_id}  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}   ${sub_domain_id}   ${bool[0]}  ${countryCodes[1]}  ${whpnum1}  ${countryCodes[1]}  ${tlgnum1}    employeeId=${employee_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get User By Id      ${u_id}
     Log   ${resp.json()}
     Should Be Equal As Strings      ${resp.status_code}  200
     Should Be Equal As Strings      ${resp.json()['employeeId']}  ${employee_id}

    ${resp}=  SendProviderResetMail   ${email}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${email}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200


     ${resp}=  ProviderLogout
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

    

    ${resp}=  EmployeeLogin    ${ids}    ${loginIdType}   ${employee_id}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UserLoginwithEmployeeid-2

    [Documentation]  again update the user with employeeid and try to login.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${employee_id}=   Random Int  min=1   max=10

    ${resp}=  Update User  ${u_id}  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}   ${sub_domain_id}   ${bool[0]}  ${countryCodes[1]}  ${whpnum1}  ${countryCodes[1]}  ${tlgnum1}    employeeId=${employee_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  EmployeeLogin    ${ids}    ${loginIdType}   ${employee_id}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UserLoginwithEmployeeid-3

    [Documentation]  create a new user and get the employeeid then try to login with that employee id.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+346945
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}

    ${whpnum}=  Evaluate  ${PUSERNAME}+336245
    ${tlgnum}=  Evaluate  ${PUSERNAME}+336345

     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U2}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum} 
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id1}  ${resp.json()}
# *** Comments ***
    sleep  02s

     ${resp}=  Get User By Id      ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    # Set Suite Variable      ${PUSERNAME_U1}     ${resp.json()['mobileNo']}
    Set Suite Variable      ${email}     ${resp.json()['email']}
    Set Suite Variable      ${employee_id}     ${resp.json()['employeeId']}

    ${resp}=  SendProviderResetMail   ${email}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${email}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

     ${resp}=  ProviderLogout
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  EmployeeLogin    ${ids}    ${loginIdType}   ${employee_id}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UserLoginwithEmployeeid-4

    [Documentation]  create a new user with employeeid then try to login with that employee id.    

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+376985
    clear_users  ${PUSERNAME_U3}
    Set Suite Variable  ${PUSERNAME_U3}

    ${whpnum}=  Evaluate  ${PUSERNAME}+336245
    ${tlgnum}=  Evaluate  ${PUSERNAME}+336345

    ${employeeId}=    Random Int  min=10   max=100

     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U3}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U3}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}    employeeId=${employeeId}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id2}  ${resp.json()}

     ${resp}=  Get User By Id      ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    # Set Suite Variable      ${PUSERNAME_U1}     ${resp.json()['mobileNo']}
    Set Suite Variable      ${email}     ${resp.json()['email']}

    ${resp}=  SendProviderResetMail   ${email}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${email}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

     ${resp}=  ProviderLogout
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  EmployeeLogin    ${ids}    ${loginIdType}   ${employeeId}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200