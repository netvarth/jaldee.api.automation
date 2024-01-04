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
Variables         /ebs/TDD/varfiles/hl_musers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
${SERVICE1}	   Food 
${SERVICE2}	   Bridal 
${SERVICE3}	   Groom

***Test Cases***

JD-TC-UpdateUser-1
     [Documentation]  update user
     ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${userSubDomain}  ${iscorp_subdomains[0]['userSubDomain']}
    #  Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+550617
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
     Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${MUSERNAME_E}${\n}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/providernumbers.txt  ${SUITE NAME} - ${TEST NAME} - ${MUSERNAME_E}${\n}
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
     
     ${resp}=  ProviderLogout
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Get User By Id  ${u_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}

     Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}  mobileNo=${PUSERNAME_U1}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U1}.${test_mail}   deptId=${dep_id}  state=${state}  pincode=${pin}  admin=${bool[0]} 
     Should Be Equal As Strings  ${resp.json()['whatsAppNum']['number']}           ${whpnum} 
     Should Be Equal As Strings  ${resp.json()['whatsAppNum']['countryCode']}      ${countryCodes[1]}
     Should Be Equal As Strings  ${resp.json()['telegramNum']['number']}           ${tlgnum} 
     Should Be Equal As Strings  ${resp.json()['telegramNum']['countryCode']}      ${countryCodes[1]}
     Should Be Equal As Strings  ${resp.json()['city']}      ${city}    ignore_case=True

     ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+336341
     clear_users  ${PUSERNAME_U3}
     Set Suite Variable  ${PUSERNAME_U3}
     ${firstname3}=  FakerLibrary.name
     ${lastname3}=  FakerLibrary.last_name
     ${dob3}=  FakerLibrary.Date

     ${resp}=  Create User  ${firstname3}  ${lastname3}  ${dob3}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U3}.${test_mail}   ${userType[2]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U3}  ${dep_id}  ${EMPTY}  ${bool[1]}  ${countryCodes[1]}  ${PUSERNAME_U3}  ${countryCodes[1]}  ${PUSERNAME_U3}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id2}  ${resp.json()}
     ${resp}=  Get User By Id  ${u_id2}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  id=${u_id2}  firstName=${firstname3}  lastName=${lastname3}   mobileNo=${PUSERNAME_U3}  dob=${dob3}  gender=${Genderlist[0]}  userType=${userType[2]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U3}.${test_mail}    deptId=0   subdomain=0  state=${state}  pincode=${pin}  admin=${bool[1]} 
     Should Be Equal As Strings  ${resp.json()['whatsAppNum']['number']}           ${PUSERNAME_U3} 
     Should Be Equal As Strings  ${resp.json()['whatsAppNum']['countryCode']}      ${countryCodes[1]}
     Should Be Equal As Strings  ${resp.json()['telegramNum']['number']}           ${PUSERNAME_U3} 
     Should Be Equal As Strings  ${resp.json()['telegramNum']['countryCode']}      ${countryCodes[1]}
     Should Be Equal As Strings  ${resp.json()['city']}      ${city}    ignore_case=True 

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

     ${resp}=  Update User  ${u_id}  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}   ${sub_domain_id}   ${bool[0]}  ${countryCodes[1]}  ${whpnum1}  ${countryCodes[1]}  ${tlgnum1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get User By Id  ${u_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  id=${u_id}  firstName=${firstname1}  lastName=${lastname1}  mobileNo=${PUSERNAME_U1}  dob=${dob1}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U1}.${test_mail}   deptId=${dep_id}  subdomain=${userSubDomain}   state=${state}  pincode=${pin}  admin=${bool[0]} 
     Should Be Equal As Strings  ${resp.json()['whatsAppNum']['number']}           ${whpnum1} 
     Should Be Equal As Strings  ${resp.json()['whatsAppNum']['countryCode']}      ${countryCodes[1]}
     Should Be Equal As Strings  ${resp.json()['telegramNum']['number']}           ${tlgnum1} 
     Should Be Equal As Strings  ${resp.json()['telegramNum']['countryCode']}      ${countryCodes[1]}
     Should Be Equal As Strings  ${resp.json()['city']}      ${city}    ignore_case=True

JD-TC-UpdateUser-2
     [Documentation]  Update a user with different department id by branch login
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
     
     ${resp}=  Update User  ${u_id}  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id1}   ${sub_domain_id}   ${bool[0]}  ${countryCodes[1]}  ${whpnum1}  ${countryCodes[1]}  ${tlgnum1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get User By Id  ${u_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  id=${u_id}  firstName=${firstname1}  lastName=${lastname1}    mobileNo=${PUSERNAME_U1}  dob=${dob1}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U1}.${test_mail}  state=${state}  deptId=${depid1}  subdomain=${userSubDomain}  pincode=${pin}  admin=${bool[0]}
     Should Be Equal As Strings  ${resp.json()['whatsAppNum']['number']}           ${whpnum1} 
     Should Be Equal As Strings  ${resp.json()['whatsAppNum']['countryCode']}      ${countryCodes[1]}
     Should Be Equal As Strings  ${resp.json()['telegramNum']['number']}           ${tlgnum1} 
     Should Be Equal As Strings  ${resp.json()['telegramNum']['countryCode']}      ${countryCodes[1]}
     Should Be Equal As Strings  ${resp.json()['city']}      ${city}    ignore_case=True 

JD-TC-UpdateUser-3
     [Documentation]  Update a user with a different subdomain in same domain by branch login
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
    #  ${iscorp_subdomains}=  get_iscorp_subdomains  1
    #  Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[1]['subdomainId']}
    
     ${resp}=  Update User  ${u_id}  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id1}   ${sub_domain_id}   ${bool[0]}  ${countryCodes[1]}  ${whpnum1}  ${countryCodes[1]}  ${tlgnum1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get User By Id  ${u_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  id=${u_id}  firstName=${firstname1}  lastName=${lastname1}    mobileNo=${PUSERNAME_U1}  dob=${dob1}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U1}.${test_mail}   state=${state}  deptId=${depid1}  subdomain=${userSubDomain}  pincode=${pin}  admin=${bool[0]}
     Should Be Equal As Strings  ${resp.json()['whatsAppNum']['number']}           ${whpnum1} 
     Should Be Equal As Strings  ${resp.json()['whatsAppNum']['countryCode']}      ${countryCodes[1]}
     Should Be Equal As Strings  ${resp.json()['telegramNum']['number']}           ${tlgnum1} 
     Should Be Equal As Strings  ${resp.json()['telegramNum']['countryCode']}      ${countryCodes[1]}
     Should Be Equal As Strings  ${resp.json()['city']}      ${city}    ignore_case=True

JD-TC-UpdateUser-4
     [Documentation]  Update ph of a user by branch login
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${PUSERNAME_U6}=  Evaluate  ${PUSERNAME}+336146
     clear_users  ${PUSERNAME_U6}
     
     ${resp}=  Update User  ${u_id}  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U6}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U6}  ${dep_id1}   ${sub_domain_id}   ${bool[0]}  ${countryCodes[1]}  ${whpnum1}  ${countryCodes[1]}  ${tlgnum1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get User By Id  ${u_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  id=${u_id}  firstName=${firstname1}  lastName=${lastname1}    mobileNo=${PUSERNAME_U6}  dob=${dob1}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U6}.${test_mail}  state=${state}  deptId=${depid1}  subdomain=${userSubDomain}  pincode=${pin}  admin=${bool[0]}
     Should Be Equal As Strings  ${resp.json()['whatsAppNum']['number']}           ${whpnum1} 
     Should Be Equal As Strings  ${resp.json()['whatsAppNum']['countryCode']}      ${countryCodes[1]}
     Should Be Equal As Strings  ${resp.json()['telegramNum']['number']}           ${tlgnum1} 
     Should Be Equal As Strings  ${resp.json()['telegramNum']['countryCode']}      ${countryCodes[1]}
     Should Be Equal As Strings  ${resp.json()['city']}      ${city}    ignore_case=True 
    
JD-TC-UpdateUser-5
     [Documentation]   Update users department id to another one here that user services also changed with that changed department services.
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${dep_desc1}=   FakerLibrary.word  
     Set Suite Variable    ${dep_desc1}  
     ${dep_code1}=   Random Int  min=100   max=999
     ${dep_name1}=   FakerLibrary.word  
     ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}   
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${depid3}  ${resp.json()}
     ${dep_code2}=   Random Int  min=100   max=999
     ${dep_name2}=   FakerLibrary.word  
     ${resp}=  Create Department  ${dep_name2}  ${dep_code2}  ${dep_desc1}   
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${depid4}  ${resp.json()}
    
     ${desc}=   FakerLibrary.sentence
     ${servicecharge}=   Random Int  min=100  max=500
     ${ser_duratn}=      Random Int   min=10   max=30
     ${resp}=  Create Service Department  ${SERVICE2}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${depid3}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${sid3}  ${resp.json()}

     ${desc1}=   FakerLibrary.sentence
     ${servicecharge}=   Random Int  min=100  max=500
     ${ser_duratn1}=      Random Int   min=10   max=30
     ${resp}=  Create Service Department  ${SERVICE3}  ${desc1}   ${ser_duratn1}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${depid4}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${sid4}  ${resp.json()}

     ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+346155
     clear_users  ${PUSERNAME_U2}
     ${firstname}=  FakerLibrary.name
     ${lastname}=  FakerLibrary.last_name
     ${dob}=  FakerLibrary.Date
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
    Set Test Variable  ${city1}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state1}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin1}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[1]}  ${PUSERNAME_U2}  ${dep_id3}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[1]}  ${PUSERNAME_U2}  ${countryCodes[1]}  ${PUSERNAME_U2}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id1}  ${resp.json()}

     sleep  2s
     ${resp}=  Get User By Id  ${u_id1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  id=${u_id1}  firstName=${firstname}  lastName=${lastname}   mobileNo=${PUSERNAME_U2}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U2}.${test_mail}   state=${state1}  deptId=${dep_id3}  subdomain=${userSubDomain}
     Should Be Equal As Strings  ${resp.json()['city']}      ${city1}    ignore_case=True
     
     ${resp}=  Get Services in Department  ${depid3}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['services'][0]['name']}                       ${SERVICE2}
     Should Be Equal As Strings  ${resp.json()['services'][0]['description']}                ${desc}
     Should Be Equal As Strings  ${resp.json()['services'][0]['serviceDuration']}            ${ser_duratn}
     Should Be Equal As Strings  ${resp.json()['services'][0]['notificationType']}           ${notifytype[2]}
     Should Be Equal As Strings  ${resp.json()['services'][0]['isPrePayment']}               ${bool[0]}
     Should Be Equal As Strings  ${resp.json()['services'][0]['bType']}                      ${bType}
     Should Be Equal As Strings  ${resp.json()['services'][0]['status']}                     ${status[0]}
     Should Be Equal As Strings  ${resp.json()['services'][0]['taxable']}                    ${bool[0]}
    
    
     ${resp}=  Update User  ${u_id1}  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[1]}  ${PUSERNAME_U2}  ${dep_id4}   ${sub_domain_id}   ${bool[0]}  ${countryCodes[1]}  ${PUSERNAME_U2}  ${countryCodes[1]}  ${PUSERNAME_U2}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get User By Id  ${u_id1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  id=${u_id1}  firstName=${firstname}  lastName=${lastname}    mobileNo=${PUSERNAME_U2}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U2}.${test_mail}   state=${state1}  deptId=${dep_id4}  subdomain=${userSubDomain}
     Should Be Equal As Strings  ${resp.json()['city']}      ${city1}    ignore_case=True

     ${resp}=  Get Services in Department  ${depid4}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['services'][0]['name']}                       ${SERVICE3}
     Should Be Equal As Strings  ${resp.json()['services'][0]['description']}                ${desc1}
     Should Be Equal As Strings  ${resp.json()['services'][0]['serviceDuration']}            ${ser_duratn1}
     Should Be Equal As Strings  ${resp.json()['services'][0]['notificationType']}           ${notifytype[2]}
     Should Be Equal As Strings  ${resp.json()['services'][0]['isPrePayment']}               ${bool[0]}
     Should Be Equal As Strings  ${resp.json()['services'][0]['bType']}                      ${bType}
     Should Be Equal As Strings  ${resp.json()['services'][0]['status']}                     ${status[0]}
     Should Be Equal As Strings  ${resp.json()['services'][0]['taxable']}                    ${bool[0]}


JD-TC-UpdateUser-6
     [Documentation]  Update a user from PROVIDER to ADMIN usertype by branch login, when checkin doesn't exist
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     
     ${resp}=  Update User  ${u_id}  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[2]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id1}   ${sub_domain_id}   ${bool[1]}  ${countryCodes[1]}  ${whpnum1}  ${countryCodes[1]}  ${tlgnum1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get User By Id  ${u_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['userType']}  ${userType[2]}


JD-TC-UpdateUser-7
     [Documentation]  Update a user from ADMIN to PROVIDER usertype by branch login
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
   
     ${resp}=  Update User  ${u_id}  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id1}   ${sub_domain_id}   ${bool[0]}  ${countryCodes[1]}  ${whpnum1}  ${countryCodes[1]}  ${tlgnum1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get User By Id  ${u_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['userType']}  ${userType[0]}

     
JD-TC-UpdateUser-8
     [Documentation]  Update a user from PROVIDER to ASSISTANT usertype by branch login
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
    
     ${resp}=  Update User  ${u_id}  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[1]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id1}   ${sub_domain_id}   ${bool[0]}  ${countryCodes[1]}  ${whpnum1}  ${countryCodes[1]}  ${tlgnum1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get User By Id  ${u_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['userType']}  ${userType[1]}

JD-TC-UpdateUser-9
     [Documentation]  Update a user from ASSISTANT to PROVIDER usertype by branch login
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
    
     ${resp}=  Update User  ${u_id}  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id1}   ${sub_domain_id}   ${bool[0]}  ${countryCodes[1]}  ${whpnum1}  ${countryCodes[1]}  ${tlgnum1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get User By Id  ${u_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['userType']}  ${userType[0]}


JD-TC-UpdateUser -UH1
     [Documentation]   Provider get a User without login      
     
     ${resp}=  Update User  ${u_id}  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}   ${sub_domain_id}   ${bool[0]}  ${countryCodes[1]}  ${whpnum1}  ${countryCodes[1]}  ${tlgnum1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-UpdateUser -UH2
    [Documentation]   Consumer get a user
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Update User  ${u_id}  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}   ${sub_domain_id}   ${bool[0]}  ${countryCodes[1]}  ${whpnum1}  ${countryCodes[1]}  ${tlgnum1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  401
     Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-UpdateUser-UH3
     [Documentation]  Update a user with invalid id by branch login
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
    
     ${resp}=  Update User  999  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}   ${sub_domain_id}   ${bool[0]}  ${countryCodes[1]}  ${whpnum1}  ${countryCodes[1]}  ${tlgnum1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"  "${USER_NOT_FOUND}"

JD-TC-UpdateUser-UH4
     [Documentation]  Update a user for a invalid subdomain by branch login
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${sub_domain_id2}=  Random Int   min=100  max=200
  
     ${resp}=  Update User  ${u_id}  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id1}   ${sub_domain_id2}   ${bool[0]}  ${countryCodes[1]}  ${whpnum1}  ${countryCodes[1]}  ${tlgnum1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
    #  Should Be Equal As Strings  ${resp.status_code}  422
    #  Should Be Equal As Strings  "${resp.json()}"  "${INVALID_SUB_SECTOR}"

JD-TC-UpdateUser-UH5
     [Documentation]  Update a user for a invalid department by branch login
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${depid2}=  Random Int   min=1000  max=2000
    
     ${resp}=  Update User  ${u_id}  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id2}   ${sub_domain_id}   ${bool[0]}  ${countryCodes[1]}  ${whpnum1}  ${countryCodes[1]}  ${tlgnum1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"  "${INVALID_DEPARTMENT}"


JD-TC-UpdateUser-UH6
     [Documentation]  Update a user with Empty ph by branch login
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
   
     ${resp}=  Update User  ${u_id}  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[1]}  ${pin}  ${countryCodes[1]}  ${EMPTY}  ${dep_id1}   ${sub_domain_id}   ${bool[0]}  ${countryCodes[1]}  ${whpnum1}  ${countryCodes[1]}  ${tlgnum1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     # Should Be Equal As Strings  ${resp.status_code}  422
     # Should Be Equal As Strings  "${resp.json()}"  "${PHONE_NO_REQUIRED}"

JD-TC-UpdateUser-UH7
     [Documentation]  Update a user with empty firstname by branch login
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     
     ${resp}=  Update User  ${u_id}  ${EMPTY}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[1]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id1}   ${sub_domain_id}   ${bool[0]}  ${countryCodes[1]}  ${whpnum1}  ${countryCodes[1]}  ${tlgnum1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"  "${VALID_FIRST_NAME}"

JD-TC-UpdateUser-UH8
     [Documentation]  Update a user with empty last name by branch login
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     
     ${resp}=  Update User  ${u_id}  ${firstname1}  ${EMPTY}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[1]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id1}   ${sub_domain_id}   ${bool[0]}  ${countryCodes[1]}  ${whpnum1}  ${countryCodes[1]}  ${tlgnum1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"  "${VALID_LAST_NAME}"


JD-TC-UpdateUser-UH9
     [Documentation]  Update a user with ADMIN usertype by branch login, when any checkin exist at present and cancel checkin
     ${iscorp_subdomains}=  get_iscorp_subdomains_with_maxpartysize  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_E2}=  Evaluate  ${PUSERNAME}+8546115
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E2}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${MUSERNAME_E2}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${MUSERNAME_E2}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E2}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${MUSERNAME_E2}${\n}
     Set Suite Variable  ${MUSERNAME_E2}
     ${DAY1}=  db.get_date_by_timezone  ${tz}
     Set Suite Variable  ${DAY1}  ${DAY1}
     ${list}=  Create List  1  2  3  4  5  6  7
     Set Suite Variable  ${list}  ${list}
     ${ph1}=  Evaluate  ${MUSERNAME_E2}+1000000000
     ${ph2}=  Evaluate  ${MUSERNAME_E2}+2000000000
     ${views}=  Random Element    ${Views}
     ${name1}=  FakerLibrary.name
     ${name2}=  FakerLibrary.name
     ${name3}=  FakerLibrary.name
     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
     ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
     ${bs}=  FakerLibrary.bs
     ${companySuffix}=  FakerLibrary.companySuffix
     # ${city}=   get_place
     # ${latti}=  get_latitude
     # ${longi}=  get_longitude
     # ${postcode}=  FakerLibrary.postcode
     # ${address}=  get_address
     ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
     ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
     Set Suite Variable  ${tz}
     ${parking}   Random Element   ${parkingType}
     ${24hours}    Random Element    ${bool}
     ${desc}=   FakerLibrary.sentence
     ${url}=   FakerLibrary.url
     ${sTime}=  add_timezone_time  ${tz}  0  15  
     Set Suite Variable   ${sTime}
     ${eTime}=  add_timezone_time  ${tz}  0  45  
     Set Suite Variable   ${eTime}
     ${resp}=  Update Business Profile With Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     
     ${fields}=   Get subDomain level Fields  ${domains}  ${sub_domains}
     Log  ${fields.json()}
     Should Be Equal As Strings    ${fields.status_code}   200

     ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

     ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_domains}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
     Should Be Equal As Strings    ${resp.status_code}   200

     ${spec}=  get_Specializations  ${resp.json()}
     ${resp}=  Update Specialization  ${spec}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}   200


     ${resp}=  Update Waitlist Settings  ${calc_mode[0]}   ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
     Should Be Equal As Strings  ${resp.status_code}  200
     
     ${resp}=  Enable Waitlist
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep   01s
     ${resp}=  Get jaldeeIntegration Settings
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]} 

     ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get jaldeeIntegration Settings
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

   
     ${resp}=  View Waitlist Settings
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['enabledWaitlist']}  ${bool[1]}

     ${id}=  get_id  ${MUSERNAME_E2}
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
     Set Suite Variable  ${dep_id5}  ${resp.json()['departments'][0]['departmentId']}
     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+51130
     clear_users  ${PUSERNAME_U1}
     Set Suite Variable  ${PUSERNAME_U1}
     ${firstname}=  FakerLibrary.name
     Set Suite Variable  ${firstname}
     ${lastname}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname}
     ${dob}=  FakerLibrary.Date
     Set Suite Variable  ${dob}
     ${user_dis_name}=  FakerLibrary.last_name
     Set Suite Variable  ${user_dis_name}
     ${employee_id}=  FakerLibrary.last_name
     Set Suite Variable  ${employee_id}
     
     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id5}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${countryCodes[1]}  ${PUSERNAME_U1}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${user_id}  ${resp.json()}

    ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_specs  ${resp.json()}
    Log  ${spec}

    ${resp}=  Get Spoke Languages
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${Languages}=  get_Languagespoken  ${resp.json()}
    Log  ${Languages}

    ${bs}=  FakerLibrary.bs
    ${bs_des}=  FakerLibrary.word

    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${spec}  ${Languages}  ${sub_domain_id}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${u_p_id}  ${resp.json()['profileId']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  2  30  
    Set Suite Variable   ${eTime1}

    ${resp}=  Get Locations
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${description}=  FakerLibrary.sentence
    Set Suite Variable  ${description}
    ${dur}=  FakerLibrary.Random Int  min=05  max=10
    Set Suite Variable  ${dur}
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    Set Suite Variable  ${amt}
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id5}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}
    
    ${queue_name}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name}
    ${resp}=  Create Queue For User  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${user_id}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id}  ${resp.json()}

     ${resp}=  Update User Search Status  ${toggle[0]}  ${user_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get User Search Status  ${user_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()}  True

      ${resp}=  AddCustomer  ${CUSERNAME1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${pcid}  ${resp.json()}

     ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${cid}  ${resp.json()[0]['id']}

    ${cons_id}=  get_id  ${CUSERNAME1} 
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist By User  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${user_id}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}


     ${resp}=  Update User  ${user_id}  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[2]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id5}   ${sub_domain_id}   ${bool[1]}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${countryCodes[1]}  ${PUSERNAME_U1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"  "${USERTYPE_CAN_NOT_CHANGE}"

     ${desc}=   FakerLibrary.word
     ${cncl_resn}=   Random Element     ${waitlist_cancl_reasn}

     ${resp}=  Waitlist Action Cancel  ${wid}  ${cncl_resn}  ${desc}
     Should Be Equal As Strings  ${resp.status_code}  200
     
     ${resp}=  Get Waitlist By Id  ${wid} 
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[4]}

     ${resp}=  Update User  ${user_id}  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[2]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id5}   ${sub_domain_id}   ${bool[1]}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${countryCodes[1]}  ${PUSERNAME_U1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"  "${USERTYPE_CAN_NOT_CHANGE}"


JD-TC-UpdateUser-UH10
     [Documentation]  Update a user with international country code

     ${resp}=  Encrypted Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${domain}=   Set Variable    ${resp.json()['sector']}
     ${subdomain}=    Set Variable      ${resp.json()['subSector']}

     ${resp}=   Get Business Profile
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

     ${resp}=  View Waitlist Settings
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp2}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
     Run Keyword If  '${resp2}' != '${None}'   Log   ${resp2.json()}
     Run Keyword If  '${resp2}' != '${None}'   Should Be Equal As Strings  ${resp2.status_code}  200

     ${dep_name1}=  FakerLibrary.bs
     ${dep_code1}=   Random Int  min=100   max=999
     ${dep_desc1}=   FakerLibrary.word  
     ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id}  ${resp.json()}

     ${PO_Number}    Generate random string    5    0123456789
     ${PO_Number}    Convert To Integer  ${PO_Number}
     ${country_code}    Generate random string    2    0123456789
     ${country_code}    Convert To Integer  ${country_code}
     ${User1}=  Evaluate  ${PUSERNAME}+${PO_Number}
     clear_users  ${User1}
     ${firstname1}=  FakerLibrary.name
     ${lastname1}=  FakerLibrary.last_name
     ${dob1}=  FakerLibrary.Date
      
     ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${User1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${User1}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${countryCodes[1]}  ${PUSERNAME_U1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${u_id1}  ${resp.json()}

     ${resp}=  Get User By Id  ${u_id1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     Set Suite Variable  ${sub_domain_id1}  ${resp.json()['subdomain']}
     Verify Response  ${resp}  id=${u_id1}  firstName=${firstname1}  lastName=${lastname1}  
     ...   mobileNo=${User1}  dob=${dob1}  gender=${Genderlist[0]}  
     ...   userType=${userType[0]}  status=ACTIVE  email=${P_Email}${User1}.${test_mail}  
     ...   state=${state}  deptId=${dep_id}  
    Should Be Equal As Strings  ${resp.json()['city']}      ${city}    ignore_case=True

     ${resp}=  Update User  ${u_id1}  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${User1}.${test_mail}   ${userType[0]}  ${pin}  ${country_code}  ${User1}  ${dep_id}   ${sub_domain_id1}   ${bool[0]}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${countryCodes[1]}  ${PUSERNAME_U1}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    422
     Should Be Equal As Strings  "${resp.json()}"  "${INVAID_USER_PHONE_NUMBER}"
     # Should Be Equal As Strings  "${resp.json()}"  "${INVALID_COUNTRY_CODE}"

JD-TC-UpdateUser-UH11
     [Documentation]  Update a user with empty country code

     ${resp}=  Encrypted Provider Login  ${HLMUSERNAME5}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${domain}=   Set Variable    ${resp.json()['sector']}
     ${subdomain}=    Set Variable      ${resp.json()['subSector']}

     ${resp}=   Get Business Profile
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

     ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    ${dlen}=  Get Length  ${iscorp_subdomains}
    FOR  ${pos}  IN RANGE  ${dlen}  
        IF  '${iscorp_subdomains[${pos}]['subdomains']}' == '${subdomain}'
            Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[${pos}]['subdomainId']}
            Set Suite Variable  ${userSubDomain}  ${iscorp_subdomains[${pos}]['userSubDomain']}
            Exit For Loop
        ELSE
            Continue For Loop
        END
    END

     ${resp}=  View Waitlist Settings
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp2}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
     Run Keyword If  '${resp2}' != '${None}'   Log   ${resp2.json()}
     Run Keyword If  '${resp2}' != '${None}'   Should Be Equal As Strings  ${resp2.status_code}  200

     ${dep_name1}=  FakerLibrary.bs
     ${dep_code1}=   Random Int  min=100   max=999
     ${dep_desc1}=   FakerLibrary.word  
     ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id}  ${resp.json()}

     ${PO_Number}    Generate random string    5    0123456789
     ${PO_Number}    Convert To Integer  ${PO_Number}
     ${country_code}    Generate random string    2    0123456789
     ${country_code}    Convert To Integer  ${country_code}
     ${User1}=  Evaluate  ${PUSERNAME}+${PO_Number}
     clear_users  ${User1}
     ${firstname1}=  FakerLibrary.name
     ${lastname1}=  FakerLibrary.last_name
     ${dob1}=  FakerLibrary.Date
      
     ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${User1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${User1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${u_id1}  ${resp.json()}

     ${resp}=  Get User By Id  ${u_id1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  id=${u_id1}  firstName=${firstname1}  lastName=${lastname1}  
     ...   mobileNo=${User1}  dob=${dob1}  gender=${Genderlist[0]}  
     ...   userType=${userType[0]}  status=ACTIVE  email=${P_Email}${User1}.${test_mail}  
     ...   state=${state}  deptId=${dep_id}  subdomain=${userSubDomain}
     Should Be Equal As Strings  ${resp.json()['city']}      ${city}    ignore_case=True

     ${resp}=  Update User  ${u_id1}  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${User1}.${test_mail}   ${userType[0]}  ${pin}  ${EMPTY}  ${User1}  ${dep_id}   ${sub_domain_id}   ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"  "${COUNTRY_CODEREQUIRED}"

     ${resp}=  Get User By Id  ${u_id1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  id=${u_id1}  firstName=${firstname1}  
     ...   lastName=${lastname1}  mobileNo=${User1}  dob=${dob1}  
     ...   gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  
     ...   email=${P_Email}${User1}.${test_mail} 
     ...   state=${state}  deptId=${dep_id}  subdomain=${userSubDomain}
     Should Be Equal As Strings  ${resp.json()['city']}      ${city}    ignore_case=True


JD-TC-UpdateUser -10
    [Documentation]   sign up a branch, update default user phone number to empty, create admin user with old phone number, 
    ...   Update default user phone number, login admin user and default provider user.

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Test Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${PO_Number}    Generate random string    4    123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${BUSERPH0}=  Evaluate  ${MUSERNAME}+${PO_Number}
    clear_users  ${BUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domains}  ${sub_domains}  ${BUSERPH0}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${BUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${BUSERPH0}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${BUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${BUSERPH0}${\n}
    ${id}=  get_id  ${BUSERPH0}
    
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id}  ${resp.json()[0]['id']}

    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}

    ${resp}=  Update User  ${u_id}  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${BUSERPH0}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}   ${EMPTY}  ${dep_id}   ${sub_domain_id}   ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}     ${PHONE_NUMBER_CAN_NOT_REMOVE_NO_EMAIL}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${firstname1}=  FakerLibrary.name
#     ${lastname1}=  FakerLibrary.last_name
#     ${dob}=  FakerLibrary.Date
#     ${gender}=  Random Element    ${Genderlist}
    
#     ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob}  ${Genderlist[0]}  ${EMPTY}   ${userType[2]}  ${pin}  ${countryCodes[1]}  ${BUSERPH0}  ${dep_id}  ${sub_domain_id}  ${bool[1]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${u_id1}  ${resp.json()}

#     ${resp}=  Get User By Id  ${u_id1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  id=${u_id1}  firstName=${firstname1}  lastName=${lastname1}  mobileNo=${BUSERPH0}

# #     ${PO_Number}    Generate random string    4    123456789
# #     ${PO_Number}    Convert To Integer  ${PO_Number}
# #     ${PUSERPH1}=  Evaluate  ${PUSERNAME}+${PO_Number}
#     ${PUSERPH1}=  Evaluate  ${PUSERNAME}+6789
#     clear_users  ${PUSERPH1}

#      ${resp}=  Update User  ${u_id}  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERPH1}  ${dep_id}   ${sub_domain_id}   ${bool[0]}  ${countryCodes[1]}  ${whpnum1}  ${countryCodes[1]}  ${tlgnum1}
#      Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get User Count
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()}  2

#     ${resp}=  Get User
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response List  ${resp}  0  id=${u_id}  firstName=${firstname1}  lastName=${lastname1}  address=${address}  mobileNo=${BUSERPH0}  dob=${dob}  gender=${gender}  userType=${userType[2]}  status=ACTIVE  email=${P_Email}${PUSERPH1}.${test_mail}  city=${location}  state=${state}  deptId=0  subdomain=0  admin=${bool[1]}  
#     Verify Response List  ${resp}  1  id=${id}  firstName=${firstname}  lastName=${lastname}  mobileNo=${PUSERPH1}  userType=${userType[0]}  status=ACTIVE  deptId=${dep_id}  subdomain=1  admin=${bool[1]} 

#     ${resp}=  Provider Logout
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-UpdateUser -11
    [Documentation]   change phone number of default user, created another user(admin) with that phone number, 
    ...  ${SPACE} change admin user's phone number.

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Test Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    Set Test Variable  ${userSubDomain}  ${iscorp_subdomains[0]['userSubDomain']}
    ${PO_Number}    Generate random string    4    123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${BUSERPH0}=  Evaluate  ${MUSERNAME}+${PO_Number}
    clear_users  ${BUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domains}  ${sub_domains}  ${BUSERPH0}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${BUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${BUSERPH0}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${BUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${BUSERPH0}${\n}
    ${id}=  get_id  ${BUSERPH0}
    
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id}  ${resp.json()[0]['id']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()[0]['subdomain']}

#     ${PO_Number}    Generate random string    4    123456789
#     ${PO_Number}    Convert To Integer  ${PO_Number}
#     ${PUSERPH1}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+6781
    clear_users  ${PUSERPH1}
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
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

    ${whpnum1}=  Evaluate  ${PUSERNAME}+246245
    ${tlgnum1}=  Evaluate  ${PUSERNAME}+246345

     ${resp}=  Update User  ${u_id}  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERPH1}  ${dep_id}   ${sub_domain_id}   ${bool[1]}  ${countryCodes[1]}  ${whpnum1}  ${countryCodes[1]}  ${tlgnum1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}

        

    ${whpnum}=  Evaluate  ${PUSERNAME}+146245
    ${tlgnum}=  Evaluate  ${PUSERNAME}+146345

    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob}  ${Genderlist[0]}  ${EMPTY}   ${userType[2]}  ${pin}  ${countryCodes[1]}  ${BUSERPH0}  ${dep_id}  ${sub_domain_id}  ${bool[1]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id2}  ${resp.json()['subdomain']}
    Verify Response  ${resp}  id=${u_id1}  firstName=${firstname1}  lastName=${lastname1}  mobileNo=${BUSERPH0}

#     ${PO_Number}    Generate random string    4    123456789
#     ${PO_Number}    Convert To Integer  ${PO_Number}
#     ${PUSERPH2}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+6782
    clear_users  ${PUSERPH2}

     ${resp}=  Update User  ${u_id1}  ${firstname1}  ${lastname1}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH2}.${test_mail}   ${userType[2]}  ${pin}  ${countryCodes[1]}  ${PUSERPH2}  ${dep_id}   ${sub_domain_id}   ${bool[1]}  ${countryCodes[1]}  ${whpnum1}  ${countryCodes[1]}  ${tlgnum1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['id']}' == '${u_id1}'
    
            Verify Response List  ${resp}  ${i}  id=${u_id1}  firstName=${firstname1}  lastName=${lastname1}   mobileNo=${PUSERPH2}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[2]}  status=ACTIVE  email=${P_Email}${PUSERPH2}.${test_mail}  state=${state}  deptId=0  subdomain=${sub_domain_id2}  admin=${bool[1]}  
            Should Be Equal As Strings  ${resp.json()[${i}]['city']}      ${city}    ignore_case=True     
        ELSE IF     '${resp.json()[${i}]['id']}' == '${u_id}'   
            Verify Response List  ${resp}  ${i}  id=${id}  firstName=${firstname}  lastName=${lastname}  mobileNo=${PUSERPH1}  userType=${userType[0]}  status=ACTIVE  deptId=${dep_id}  subdomain=${sub_domain_id}  admin=${bool[1]} 
        END
        
    END

    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERPH2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}



JD-TC-UpdateUser -12
    [Documentation]   change phone number of default user, created another user(provider) with that phone number, 
    ...  ${SPACE} change provider user's phone number.

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Test Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    Set Test Variable  ${userSubDomain}  ${iscorp_subdomains[0]['userSubDomain']}
    ${PO_Number}    Generate random string    4    123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${BUSERPH0}=  Evaluate  ${MUSERNAME}+${PO_Number}
    clear_users  ${BUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domains}  ${sub_domains}  ${BUSERPH0}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${BUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${BUSERPH0}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${BUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${BUSERPH0}${\n}
    ${id}=  get_id  ${BUSERPH0}
    
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id}  ${resp.json()[0]['id']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()[0]['subdomain']}

#     ${PO_Number}    Generate random string    4    123456789
#     ${PO_Number}    Convert To Integer  ${PO_Number}
#     ${PUSERPH1}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+6783
    clear_users  ${PUSERPH1}
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
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

    ${whpnum1}=  Evaluate  ${PUSERNAME}+246145
    ${tlgnum1}=  Evaluate  ${PUSERNAME}+246345

     ${resp}=  Update User  ${u_id}  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERPH1}  ${dep_id}   ${sub_domain_id}   ${bool[1]}  ${countryCodes[1]}  ${whpnum1}  ${countryCodes[1]}  ${tlgnum1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}    

    ${whpnum}=  Evaluate  ${PUSERNAME}+146445
    ${tlgnum}=  Evaluate  ${PUSERNAME}+146545

    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob}  ${Genderlist[0]}   ${EMPTY}  ${userType[0]}  ${pin}  ${countryCodes[1]}  ${BUSERPH0}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}
    Verify Response  ${resp}  id=${u_id1}  firstName=${firstname1}  lastName=${lastname1}  mobileNo=${BUSERPH0}

#     ${PO_Number}    Generate random string    4    123456789
#     ${PO_Number}    Convert To Integer  ${PO_Number}
#     ${PUSERPH2}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+6784
    clear_users  ${PUSERPH2}

     ${resp}=  Update User  ${u_id1}  ${firstname1}  ${lastname1}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH2}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERPH2}  ${dep_id}   ${sub_domain_id}   ${bool[0]}  ${countryCodes[1]}  ${whpnum1}  ${countryCodes[1]}  ${tlgnum1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['id']}' == '${u_id1}'
            Should Be Equal As Strings  ${resp.json()[${i}]['city']}      ${city}    ignore_case=True
            Verify Response List  ${resp}  ${i}  id=${u_id1}  firstName=${firstname1}  lastName=${lastname1}  mobileNo=${PUSERPH2}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERPH2}.${test_mail}   state=${state}  deptId=${dep_id}  subdomain=${userSubDomain}  admin=${bool[0]}  
        ELSE IF     '${resp.json()[${i}]['id']}' == '${u_id}'   
            Verify Response List  ${resp}  ${i}  id=${id}  firstName=${firstname}  lastName=${lastname}  mobileNo=${PUSERPH1}  userType=${userType[0]}  status=ACTIVE  deptId=${dep_id}  subdomain=${userSubDomain}  admin=${bool[1]} 
        END
    END


    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERPH2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}


JD-TC-UpdateUser -13
    [Documentation]   change phone number of default user with email address to empty and try to login.

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Test Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${PO_Number}    Generate random string    4    123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${BUSERPH0}=  Evaluate  ${MUSERNAME}+${PO_Number}
    clear_users  ${BUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domains}  ${sub_domains}  ${BUSERPH0}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${BUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${BUSERPH0}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${BUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${BUSERPH0}${\n}
    ${id}=  get_id  ${BUSERPH0}
    
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id}  ${resp.json()[0]['id']}

#     ${PO_Number}    Generate random string    4    123456789
#     ${PO_Number}    Convert To Integer  ${PO_Number}
#     ${PUSERPH1}=  Evaluate  ${PUSERNAME}+${PO_Number}
#     clear_users  ${PUSERPH1}
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${pin}=  get_pincode

    ${whpnum1}=  Evaluate  ${PUSERNAME}+246545
    ${tlgnum1}=  Evaluate  ${PUSERNAME}+246645

    ${resp}=  Update User  ${u_id}  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${BUSERPH0}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${EMPTY}  ${dep_id}   ${sub_domain_id}   ${bool[1]}  ${countryCodes[1]}  ${whpnum1}  ${countryCodes[1]}  ${tlgnum1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}     ${PHONE_NUMBER_CAN_NOT_REMOVE_NO_EMAIL}
    #  Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${resp}=  Provider Logout
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Encrypted Provider Login  ${BUSERPH0}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Encrypted Provider Login  ${P_Email}${BUSERPH0}.${test_mail}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-UpdateUser -14
    [Documentation]   change phone number of default user and try to login.

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Test Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${PO_Number}    Generate random string    4    123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${BUSERPH0}=  Evaluate  ${MUSERNAME}+${PO_Number}
    clear_users  ${BUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domains}  ${sub_domains}  ${BUSERPH0}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${BUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${BUSERPH0}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${BUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${BUSERPH0}${\n}
    ${id}=  get_id  ${BUSERPH0}
    
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id}  ${resp.json()[0]['id']}

#     ${PO_Number}    Generate random string    4    123456789
#     ${PO_Number}    Convert To Integer  ${PO_Number}
#     ${PUSERPH1}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+6785
    clear_users  ${PUSERPH1}
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${pin}=  get_pincode

    ${whpnum1}=  Evaluate  ${PUSERNAME}+246745
    ${tlgnum1}=  Evaluate  ${PUSERNAME}+246845

     ${resp}=  Update User  ${u_id}  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERPH1}  ${dep_id}   ${sub_domain_id}   ${bool[1]}  ${countryCodes[1]}  ${whpnum1}  ${countryCodes[1]}  ${tlgnum1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${BUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}     ${NOT_REGISTERED_PROVIDER}

    ${resp}=  Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
#     Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}


JD-TC-UpdateUser -15
    [Documentation]   create user with email and empty phone number and update phone number and remove email for the user and login

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Test Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    Set Test Variable  ${userSubDomain}  ${iscorp_subdomains[0]['userSubDomain']}
    ${PO_Number}    Generate random string    4    123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${BUSERPH0}=  Evaluate  ${MUSERNAME}+${PO_Number}
    clear_users  ${BUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domains}  ${sub_domains}  ${BUSERPH0}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${BUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${BUSERPH0}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${BUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${BUSERPH0}${\n}
    ${id}=  get_id  ${BUSERPH0}
    
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id}  ${resp.json()[0]['id']}

#     ${PO_Number}    Generate random string    4    123456789
#     ${PO_Number}    Convert To Integer  ${PO_Number}
#     ${PUSERPH1}=  Evaluate  ${PUSERNAME}+${PO_Number}
     ${PUSERPH1}=  Evaluate  ${PUSERNAME}+6786
#     clear_users  ${PUSERPH1}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${EMPTY}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id1}  firstName=${firstname1}  lastName=${lastname1}  mobileNo=0

     ${resp}=  Update User  ${u_id1}  ${firstname1}  ${lastname1}  ${dob}  ${Genderlist[0]}  ${EMPTY}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERPH1}  ${dep_id}   ${sub_domain_id}   ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${P_Email}${PUSERPH1}.${test_mail}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"  "${NOT_REGISTERED_PROVIDER}"

    ${resp}=  Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_INVALID_USERID_PASSWORD}"


JD-TC-UpdateUser -16
    [Documentation]   create user with email and empty phone number and update phone number and email for the user and login

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Test Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    Set Test Variable  ${userSubDomain}  ${iscorp_subdomains[0]['userSubDomain']}
    ${PO_Number}    Generate random string    4    123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${BUSERPH0}=  Evaluate  ${MUSERNAME}+${PO_Number}
    clear_users  ${BUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domains}  ${sub_domains}  ${BUSERPH0}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${BUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${BUSERPH0}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${BUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${BUSERPH0}${\n}
    ${id}=  get_id  ${BUSERPH0}
    
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id}  ${resp.json()[0]['id']}

    ${PO_Number}    Generate random string    4    123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
#     ${PUSERPH1}=  Evaluate  ${PUSERNAME}+${PO_Number}
     ${PUSERPH1}=  Evaluate  ${PUSERNAME}+111111
#     clear_users  ${PUSERPH1}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${EMPTY}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id1}  firstName=${firstname1}  lastName=${lastname1}  mobileNo=0

     ${resp}=  Update User  ${u_id1}  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERPH1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERPH1}  ${dep_id}   ${sub_domain_id}   ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${P_Email}${PUSERPH1}.${test_mail}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_INVALID_USERID_PASSWORD}"

    ${resp}=  Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_INVALID_USERID_PASSWORD}"


JD-TC-UpdateUser -17
    [Documentation]   create user with ph no and empty email and update phone number to empty and give email for the user and login

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Test Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    Set Test Variable  ${userSubDomain}  ${iscorp_subdomains[0]['userSubDomain']}
    ${PO_Number}    Generate random string    4    123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${BUSERPH0}=  Evaluate  ${MUSERNAME}+${PO_Number}
    clear_users  ${BUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domains}  ${sub_domains}  ${BUSERPH0}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${BUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${BUSERPH0}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${BUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${BUSERPH0}${\n}
    ${id}=  get_id  ${BUSERPH0}
    
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id}  ${resp.json()[0]['id']}

#     ${PO_Number}    Generate random string    4    123456789
#     ${PO_Number}    Convert To Integer  ${PO_Number}
#     ${PUSERPH1}=  Evaluate  ${PUSERNAME}+${PO_Number}
     ${PUSERPH1}=  Evaluate  ${PUSERNAME}+6787
#     clear_users  ${PUSERPH1}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
 
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob}  ${Genderlist[0]}   ${EMPTY}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERPH1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id1}  firstName=${firstname1}  lastName=${lastname1}  mobileNo=${PUSERPH1}

#     ${PO_Number}    Generate random string    4    123456789
#     ${PO_Number}    Convert To Integer  ${PO_Number}
#     ${PUSERPH2}=  Evaluate  ${PUSERNAME}+${PO_Number}
#     clear_users  ${PUSERPH2}

    ${resp}=  Update User  ${u_id1}  ${firstname1}  ${lastname1}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${EMPTY}  ${dep_id}   ${sub_domain_id}   ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}     ${PHONE_NUMBER_CAN_NOT_REMOVE_NO_EMAIL}
    #  Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Provider Logout
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Encrypted Provider Login  ${P_Email}${PUSERPH1}.${test_mail}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-UpdateUser -18
    [Documentation]   create user with ph no and empty email and update phone number and give email for the user and login

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Test Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    Set Test Variable  ${userSubDomain}  ${iscorp_subdomains[0]['userSubDomain']}
    ${PO_Number}    Generate random string    4    123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${BUSERPH0}=  Evaluate  ${MUSERNAME}+${PO_Number}
    clear_users  ${BUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domains}  ${sub_domains}  ${BUSERPH0}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${BUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${BUSERPH0}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${BUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${BUSERPH0}${\n}
    ${id}=  get_id  ${BUSERPH0}
    
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id}  ${resp.json()[0]['id']}

#     ${PO_Number}    Generate random string    4    123456789
#     ${PO_Number}    Convert To Integer  ${PO_Number}
#     ${PUSERPH1}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+6882
#     clear_users  ${PUSERPH1}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
   
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob}  ${Genderlist[0]}  ${EMPTY}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERPH1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id1}  firstName=${firstname1}  lastName=${lastname1}  mobileNo=${PUSERPH1}

     ${resp}=  Update User  ${u_id1}  ${firstname1}  ${lastname1}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERPH1}  ${dep_id}   ${sub_domain_id}   ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${P_Email}${PUSERPH1}.${test_mail}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_INVALID_USERID_PASSWORD}"

    ${resp}=  Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_INVALID_USERID_PASSWORD}"


JD-TC-UpdateUser -19
    [Documentation]   create user with ph no and email and update phone number to empty and update email for the user and login

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Test Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    Set Test Variable  ${userSubDomain}  ${iscorp_subdomains[0]['userSubDomain']}
    ${PO_Number}    Generate random string    4    123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${BUSERPH0}=  Evaluate  ${MUSERNAME}+${PO_Number}
    clear_users  ${BUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domains}  ${sub_domains}  ${BUSERPH0}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${BUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${BUSERPH0}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${BUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${BUSERPH0}${\n}
    ${id}=  get_id  ${BUSERPH0}
    
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id}  ${resp.json()[0]['id']}

#     ${PO_Number}    Generate random string    4    123456789
#     ${PO_Number}    Convert To Integer  ${PO_Number}
#     ${PUSERPH1}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+6881
#     clear_users  ${PUSERPH1}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
   
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERPH1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id1}  firstName=${firstname1}  lastName=${lastname1}  mobileNo=${PUSERPH1}

     ${resp}=  Update User  ${u_id1}  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERPH1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${EMPTY}  ${dep_id}   ${sub_domain_id}   ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${P_Email}${PUSERPH1}.${test_mail}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_INVALID_USERID_PASSWORD}"

    ${resp}=  Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"  "${NOT_REGISTERED_PROVIDER}"


JD-TC-UpdateUser -20
    [Documentation]   create user with ph no and email and update phone number and update email to empty for the user and login

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Test Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    Set Test Variable  ${userSubDomain}  ${iscorp_subdomains[0]['userSubDomain']}
    ${PO_Number}    Generate random string    4    123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${BUSERPH0}=  Evaluate  ${MUSERNAME}+${PO_Number}
    clear_users  ${BUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domains}  ${sub_domains}  ${BUSERPH0}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${BUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${BUSERPH0}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${BUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${BUSERPH0}${\n}
    ${id}=  get_id  ${BUSERPH0}
    
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id}  ${resp.json()[0]['id']}

#     ${PO_Number}    Generate random string    4    123456789
#     ${PO_Number}    Convert To Integer  ${PO_Number}
#     ${PUSERPH1}=  Evaluate  ${PUSERNAME}+${PO_Number}
     ${PUSERPH1}=  Evaluate  ${PUSERNAME}+6788
#     clear_users  ${PUSERPH1}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
  
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERPH1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id1}  firstName=${firstname1}  lastName=${lastname1}  mobileNo=${PUSERPH1}

     ${resp}=  Update User  ${u_id1}  ${firstname1}  ${lastname1}  ${dob}  ${Genderlist[0]}  ${EMPTY}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERPH1}  ${dep_id}   ${sub_domain_id}   ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${P_Email}${PUSERPH1}.${test_mail}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"  "${NOT_REGISTERED_PROVIDER}"

    ${resp}=  Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_INVALID_USERID_PASSWORD}"




