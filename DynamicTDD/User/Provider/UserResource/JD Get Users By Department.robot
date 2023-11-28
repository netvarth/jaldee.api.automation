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


***Test Cases***

JD-TC-GetUsersByDepartment-1
     [Documentation]  Get users by department
     ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+110217
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
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
     Set Suite Variable  ${MUSERNAME_E}
     ${id}=  get_id  ${MUSERNAME_E}
     Set Suite Variable  ${id}
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
     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+226445
     clear_users  ${PUSERNAME_U1}
     Set Suite Variable  ${PUSERNAME_U1}
     ${firstname}=  FakerLibrary.name
     Set Suite Variable  ${firstname}
     ${lastname}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname}
     ${address}=  get_address
     Set Suite Variable  ${address}
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
     Set Test Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
     Set Test Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
     Set Test Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL} 
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}

     ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+226446
     clear_users  ${PUSERNAME_U2}
     Set Suite Variable  ${PUSERNAME_U2}
     ${firstname1}=  FakerLibrary.name
     Set Suite Variable  ${firstname1}
     ${lastname1}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname1}
     ${address1}=  get_address
     Set Suite Variable  ${address1}
     ${dob1}=  FakerLibrary.Date
     Set Suite Variable  ${dob1}
     # ${pin1}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin1}
     FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Test Variable  ${city1}   ${resp.json()[0]['PostOffice'][0]['District']}   
     Set Test Variable  ${state1}  ${resp.json()[0]['PostOffice'][0]['State']}      
     Set Test Variable  ${pin1}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

     ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id1}  ${resp.json()}
     
     sleep  4s
    ${resp}=  Get Users By Department  ${dep_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  1  id=${u_id}  firstName=${firstname}  lastName=${lastname}   primaryMobileNo=${PUSERNAME_U1}  dob=${dob}  gender=${Genderlist[0]}  email=${P_Email}${PUSERNAME_U1}.${test_mail}    state=${state}
    Should Be Equal As Strings  ${resp.json()[1]['city']}      ${city}    ignore_case=True
    Verify Response List  ${resp}  2  id=${u_id1}  firstName=${firstname1}  lastName=${lastname1}   primaryMobileNo=${PUSERNAME_U2}  dob=${dob1}  gender=${Genderlist[0]}  email=${P_Email}${PUSERNAME_U2}.${test_mail}   state=${state1}
    Should Be Equal As Strings  ${resp.json()[2]['city']}      ${city1}    ignore_case=True
     
JD-TC-GetUsersByDepartment-2
     [Documentation]  Get user for a different department
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=   Get Service
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200  
     Set Suite Variable  ${sid1}  ${resp.json()[0]['id']} 
     ${dep_name1}=  FakerLibrary.bs
     Set Suite Variable   ${dep_name1}
     ${dep_code1}=   Random Int  min=100   max=999
     Set Suite Variable   ${dep_code1}
     ${dep_desc1}=   FakerLibrary.word  
     Set Suite Variable    ${dep_desc1}
     ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}   ${sid1}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${depid1}  ${resp.json()}
     ${PUSERNAME_U4}=  Evaluate  ${PUSERNAME}+3346648
     clear_users  ${PUSERNAME_U4}
     Set Suite Variable  ${PUSERNAME_U4}
     ${firstname3}=  FakerLibrary.name
     Set Suite Variable  ${firstname3}
     ${lastname3}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname3}
     ${address3}=  get_address
     Set Suite Variable   ${address3}
     ${dob3}=  FakerLibrary.Date
     Set Suite Variable  ${dob3}
     # ${pin3}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin3}
     FOR    ${i}    IN RANGE    3
        ${pin3}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin3}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Suite Variable  ${city3}   ${resp.json()[0]['PostOffice'][0]['District']}   
     Set Suite Variable  ${state3}  ${resp.json()[0]['PostOffice'][0]['State']}      
     Set Suite Variable  ${pin3}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

     
     ${resp}=  Create User  ${firstname3}  ${lastname3}  ${dob3}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U4}.${test_mail}   ${userType[0]}  ${pin3}  ${countryCodes[0]}  ${PUSERNAME_U4}  ${dep_id1}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id3}  ${resp.json()}

    ${resp}=  Get Users By Department  ${depid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${u_id3}  firstName=${firstname3}  lastName=${lastname3}   primaryMobileNo=${PUSERNAME_U4}  dob=${dob3}  gender=${Genderlist[0]}  email=${P_Email}${PUSERNAME_U4}.${test_mail}    state=${state3}
    Should Be Equal As Strings  ${resp.json()[0]['city']}      ${city3}    ignore_case=True

    ${resp}=  Get Users By Department  ${dep_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain  ${resp.json()}  ${u_id3}

JD-TC-GetUsersByDepartment-3
     [Documentation]  Create a user for a different subdomain in same domain then get users by department
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Set Suite Variable  ${sud_domain_id1}   ${iscorp_subdomains[1]['subdomainId']}
     ${PUSERNAME_U5}=  Evaluate  ${PUSERNAME}+33469
     Set Suite Variable  ${PUSERNAME_U5}
     clear_users  ${PUSERNAME_U5}
     ${firstname4}=  FakerLibrary.name
     Set Suite Variable  ${firstname4}
     ${lastname4}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname4}
     ${address4}=  get_address
     Set Suite Variable  ${address4}
     ${dob4}=  FakerLibrary.Date
     Set Suite Variable  ${dob4}
     # ${pin4}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin4}
     FOR    ${i}    IN RANGE    3
        ${pin4}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin4}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Suite Variable  ${city4}   ${resp.json()[0]['PostOffice'][0]['District']}   
     Set Suite Variable  ${state4}  ${resp.json()[0]['PostOffice'][0]['State']}      
     Set Suite Variable  ${pin4}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

     ${resp}=  Create User  ${firstname4}  ${lastname4}  ${dob4}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U5}.${test_mail}   ${userType[0]}  ${pin4}  ${countryCodes[0]}  ${PUSERNAME_U5}  ${dep_id1}  ${sud_domain_id1}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id4}  ${resp.json()}
     
     sleep  2s
     ${resp}=  Get Users By Department  ${depid1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response List  ${resp}  0  id=${u_id3}  firstName=${firstname3}  lastName=${lastname3}   primaryMobileNo=${PUSERNAME_U4}  dob=${dob3}  gender=${Genderlist[0]}  email=${P_Email}${PUSERNAME_U4}.${test_mail}    state=${state3}
    Should Be Equal As Strings  ${resp.json()[0]['city']}      ${city3}    ignore_case=True

     Verify Response List  ${resp}  1  id=${u_id4}  firstName=${firstname4}  lastName=${lastname4}   primaryMobileNo=${PUSERNAME_U5}  dob=${dob4}  gender=${Genderlist[0]}  email=${P_Email}${PUSERNAME_U5}.${test_mail}    state=${state4}
    Should Be Equal As Strings  ${resp.json()[1]['city']}      ${city4}    ignore_case=True


JD-TC-GetUsersByDepartment-4
     [Documentation]  Create a user for a different subdomain in same domain then get users by department
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  EnableDisable User  ${u_id4}  ${toggle[1]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     sleep  2s
     ${resp}=  Get Users By Department  ${depid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${u_id3}  firstName=${firstname3}  lastName=${lastname3}  primaryMobileNo=${PUSERNAME_U4}  dob=${dob3}  gender=${Genderlist[0]}  email=${P_Email}${PUSERNAME_U4}.${test_mail}  city=${city3}  state=${state3}
    Should Be Equal As Strings  ${resp.json()[0]['city']}      ${city3}    ignore_case=True

    Verify Response List  ${resp}  1  id=${u_id4}  firstName=${firstname4}  lastName=${lastname4}  primaryMobileNo=${PUSERNAME_U5}  dob=${dob4}  gender=${Genderlist[0]}  email=${P_Email}${PUSERNAME_U5}.${test_mail}  city=${city4}  state=${state4}
    Should Be Equal As Strings  ${resp.json()[1]['city']}      ${city4}    ignore_case=True


JD-TC-GetUsersByDepartment -UH1
     [Documentation]   Provider get a Users by department without login      
     ${resp}=  Get Users By Department  ${dep_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-GetUsersByDepartment -UH2
    [Documentation]   Consumer get a users by department
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Users By Department  ${dep_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-GetUsersByDepartment-UH3
     [Documentation]  Get a users by department with invalid dep id by branch login
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Get Users By Department  000
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"   "${NO_SUCH_DEPARTMENT}"
