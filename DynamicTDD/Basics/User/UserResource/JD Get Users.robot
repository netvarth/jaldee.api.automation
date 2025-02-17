***Settings***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        User
Library           Collections
Library           String
Library           json
Library           random
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

***Test Cases***

JD-TC-GetUsers-1
     [Documentation]  Get users by branch login
     ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+550117
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_E}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
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
     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+336545
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
     Set Suite Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
     Set Suite Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
     Set Suite Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}   



    ${resp}=  Get BusinessDomainsConf
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dom_len}=  Get Length  ${resp.json()}
    ${dom}=  random.randint  ${0}  ${dom_len-1}
    ${sdom_len}=  Get Length  ${resp.json()[${dom}]['subDomains']}
    Set Test Variable  ${domain}  ${resp.json()[${dom}]['domain']}
    Log   ${domain}

    FOR  ${subindex}  IN RANGE  ${sdom_len}
        ${sdom}=  random.randint  ${0}  ${sdom_len-1}
        Set Test Variable  ${subdomain}  ${resp.json()[${dom}]['subDomains'][${subindex}]['subDomain']}
        ${is_corp}=  check_is_corp  ${subdomain}
        Exit For Loop If  '${is_corp}' == 'False'
    END
    Log   ${subdomain}
     
    ${lid2}=   Create Sample Location
    Set Suite Variable    ${lid2} 


     ${whpnum}=  Evaluate  ${PUSERNAME}+316215
     ${tlgnum}=  Evaluate  ${PUSERNAME}+316315

     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}



     ${resp}=  Get User By Id  ${u_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}
     Set Suite Variable  ${employeeId}  ${resp.json()['employeeId']}

    ${resp}=  SendProviderResetMail  ${PUSERNAME_U1}  
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}  
    Should Be Equal As Strings  ${resp[0].status_code}   200
    Should Be Equal As Strings  ${resp[1].status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_specs  ${resp.json()}
    ${spec_len}=  Get Length  ${spec}
    ${rand_len}=  Set Variable If  ${spec_len}>3  3   ${spec_len}
    ${spec}=  Random Elements   elements=@{spec}  length=${spec_len}  unique=True
    Log  ${spec}
    Set Suite Variable  ${spec}  

    ${resp}=  Get Spoke Languages
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${Languages}=  get_Languagespoken  ${resp.json()}
    ${Languages}=  Random Elements   elements=@{Languages}  length=5  unique=True
    Log  ${Languages}
    Set Suite Variable  ${Languages}  

    ${bs}=  FakerLibrary.bs
    ${bs_des}=  FakerLibrary.word
    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${spec}  ${Languages}  ${sub_domain_id}  ${u_id} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${me_upid2}  ${resp.json()['profileId']}


#     ${resp}=  Get User Profile  ${In_uid2}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
    # Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs_des}  languagesSpoken=${Languages}  userSubdomain=${sub_domain_id}   profileId=${us_upid1}  specialization=${spec}
 

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

    ${userIds}=  Create List  ${u_id}  
    ${resp}=   Assign Business_loc To User  ${userIds}   ${lid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


     ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+336525
     clear_users  ${PUSERNAME_U2}
     Set Suite Variable  ${PUSERNAME_U2}
     ${firstname2}=  FakerLibrary.name
     Set Suite Variable  ${firstname2}
     ${lastname2}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname2}
     ${address2}=  get_address
     Set Suite Variable  ${address2}
     ${dob2}=  FakerLibrary.Date
     Set Suite Variable  ${dob2}
     # ${pin2}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin2}
     FOR    ${i}    IN RANGE    3
        ${pin2}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin2}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Suite Variable  ${city2}   ${resp.json()[0]['PostOffice'][0]['District']}   
     Set Suite Variable  ${state2}  ${resp.json()[0]['PostOffice'][0]['State']}      
     Set Suite Variable  ${pin2}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

     ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[2]}  ${pin2}  ${countryCodes[1]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id2}  ${resp.json()}

     ${resp}=  Get User By Id  ${u_id2}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     # Set Suite Variable  ${user2_city}  ${resp.json()['city']}


     ${resp}=  Get User
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${len}=  Get Length  ${resp.json()}
     # Should Be Equal As Integers  ${len}  3
     FOR  ${i}  IN RANGE   ${len}
        Run Keyword IF  '${resp.json()[${i}]['id']}' == '${u_id}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['firstName']}                       ${firstname}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['lastName']}                        ${lastname} 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['mobileNo']}                        ${PUSERNAME_U1}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['dob']}                             ${dob}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['gender']}                          ${Genderlist[0]}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['userType']}                        ${userType[0]}     
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['status']}                          ACTIVE    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['email']}                           ${P_Email}${PUSERNAME_U1}.${test_mail}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['city']}                            ${city}   ignore_case=True
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['state']}                           ${state}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['deptId']}                          ${dep_id}     
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['subdomain']}                       ${sub_domain_id}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['admin']}                           ${bool[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['pincode']}                         ${pin} 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['whatsAppNum']['number']}           ${whpnum} 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['whatsAppNum']['countryCode']}      ${countryCodes[1]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['telegramNum']['number']}           ${tlgnum} 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['telegramNum']['countryCode']}      ${countryCodes[1]}
        

        ...    ELSE IF     '${resp.json()[${i}]['id']}' == '${id}'   
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['firstName']}                       ${firstname_A}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['lastName']}                        ${lastname_A} 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['userType']}                        ${userType[0]}     
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['status']}                          ACTIVE    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['mobileNo']}                        ${PUSERNAME_E}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['deptId']}                          ${dep_id}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['subdomain']}                       1
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['admin']}                           ${bool[1]} 
      
        ...    ELSE IF     '${resp.json()[${i}]['id']}' == '${u_id2}'   
        ...    Run Keywords
        ...    Should Be Equal As Strings  ${resp.json()[${i}]['lastName']}                             ${lastname2} 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['firstName']}                       ${firstname2}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['mobileNo']}                        ${PUSERNAME_U2}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['dob']}                             ${dob2}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['gender']}                          ${Genderlist[0]}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['userType']}                        ${userType[2]}     
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['status']}                          ACTIVE    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['email']}                           ${P_Email}${PUSERNAME_U2}.${test_mail}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['city']}                            ${city2}  ignore_case=True 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['state']}                           ${state2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['deptId']}                          0   
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['subdomain']}                       0
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['admin']}                           ${bool[1]} 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['pincode']}                         ${pin2} 

     END


JD-TC-GetUsers-13
     [Documentation]  Get users by specialization
    
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Get User    specialization-eq=name::${spec[0]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200 
     Should Be Equal As Strings  ${resp.json()[0]['specialization'][0]['name']}                        ${spec[0]}  
     Verify Response List  ${resp}  0  id=${u_id}  firstName=${firstname}  lastName=${lastname}   mobileNo=${PUSERNAME_U1}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U1}.${test_mail}  city=${city}  state=${state}  deptId=${dep_id}  subdomain=${sub_domain_id}  admin=${bool[0]}    

JD-TC-GetUsers-14
     [Documentation]  Get users by businesslocation
    
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Get User    businessLocs-eq=${lid2}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200 
     # Should Be Equal As Strings  ${resp.json()[0]['specialization'][0]['name']}                        ${spec[0]}  
     Verify Response List  ${resp}  0  id=${u_id}  firstName=${firstname}  lastName=${lastname}   mobileNo=${PUSERNAME_U1}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U1}.${test_mail}  city=${city}  state=${state}  deptId=${dep_id}  subdomain=${sub_domain_id}  admin=${bool[0]}    

JD-TC-GetUsers-15
     [Documentation]  Get users by Language spoken
    
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Get User   preferredLanguages-eq=${Languages[0]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200 
     # Should Be Equal As Strings  ${resp.json()[0]['specialization'][0]['name']}                        ${spec[0]}  
     Verify Response List  ${resp}  0  id=${u_id}  firstName=${firstname}  lastName=${lastname}   mobileNo=${PUSERNAME_U1}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U1}.${test_mail}  city=${city}  state=${state}  deptId=${dep_id}  subdomain=${sub_domain_id}  admin=${bool[0]}    

JD-TC-GetUsers-16
     [Documentation]  Get users by Language spoken
    
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Get User   preferredLanguages-eq=${Languages[0]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200 
     # Should Be Equal As Strings  ${resp.json()[0]['specialization'][0]['name']}                        ${spec[0]}  
     Verify Response List  ${resp}  0  id=${u_id}  firstName=${firstname}  lastName=${lastname}   mobileNo=${PUSERNAME_U1}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U1}.${test_mail}  city=${city}  state=${state}  deptId=${dep_id}  subdomain=${sub_domain_id}  admin=${bool[0]}    

JD-TC-GetUsers-17
     [Documentation]  Get users by employee id
    
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Get User   employeeId-eq=${employeeId}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200 
     Should Be Equal As Strings  ${resp.json()[0]['employeeId']}                        ${employeeId}  
     Verify Response List  ${resp}  0  id=${u_id}  firstName=${firstname}  lastName=${lastname}   mobileNo=${PUSERNAME_U1}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U1}.${test_mail}  city=${city}  state=${state}  deptId=${dep_id}  subdomain=${sub_domain_id}  admin=${bool[0]}    

JD-TC-GetUsers-18
     [Documentation]  Get users by email id
    
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Get User   email-eq=${P_Email}${PUSERNAME_U1}.${test_mail}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200 
     Should Be Equal As Strings  ${resp.json()[0]['email']}                     ${P_Email}${PUSERNAME_U1}.${test_mail} 
     Verify Response List  ${resp}  0  id=${u_id}  firstName=${firstname}  lastName=${lastname}   mobileNo=${PUSERNAME_U1}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U1}.${test_mail}  city=${city}  state=${state}  deptId=${dep_id}  subdomain=${sub_domain_id}  admin=${bool[0]}     


JD-TC-GetUsers-2
     [Documentation]  Get users by userType 
    
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Get User    specialization-eq=name::${spec[0]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200  

     ${resp}=  Get User    userType-eq=${userType[2]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200  
     Verify Response List  ${resp}  0  id=${u_id2}  firstName=${firstname2}   mobileNo=${PUSERNAME_U2}  dob=${dob2}  gender=${Genderlist[0]}  userType=${userType[2]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U2}.${test_mail}  city=${city2}  state=${state2}  deptId=0  subdomain=0  admin=${bool[1]}  

JD-TC-GetUsers-3
     [Documentation]  Get users by firstName

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200 

     ${resp}=  Get User    firstName-eq=${firstname} 
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200 
     Verify Response List  ${resp}  0  id=${u_id}  firstName=${firstname}  lastName=${lastname}   mobileNo=${PUSERNAME_U1}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U1}.${test_mail}  city=${city}  state=${state}  deptId=${dep_id}  subdomain=${sub_domain_id}  admin=${bool[0]}   

JD-TC-GetUsers-4
     [Documentation]  Get users by lastName

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200   

     ${resp}=  Get User    lastName-eq=${lastname} 
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response List  ${resp}  0  id=${u_id}  firstName=${firstname}  lastName=${lastname}   mobileNo=${PUSERNAME_U1}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U1}.${test_mail}  city=${city}  state=${state}  deptId=${dep_id}  subdomain=${sub_domain_id}  admin=${bool[0]}    

JD-TC-GetUsers-5
     [Documentation]  Get users by status

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200   

     ${resp}=  Get User    status-eq=ACTIVE
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200 
     ${len}=  Get Length  ${resp.json()}
     # Should Be Equal As Integers  ${len}  3
     FOR  ${i}  IN RANGE   ${len}
        Run Keyword IF  '${resp.json()[${i}]['id']}' == '${u_id}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['firstName']}                       ${firstname}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['lastName']}                        ${lastname} 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['mobileNo']}                        ${PUSERNAME_U1}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['dob']}                             ${dob}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['gender']}                          ${Genderlist[0]}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['userType']}                        ${userType[0]}     
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['status']}                          ACTIVE    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['email']}                           ${P_Email}${PUSERNAME_U1}.${test_mail}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['city']}                           ${city}  ignore_case=True
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['state']}                           ${state}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['deptId']}                          ${dep_id}     
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['subdomain']}                       ${sub_domain_id}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['admin']}                           ${bool[0]} 

        ...    ELSE IF     '${resp.json()[${i}]['id']}' == '${id}'   
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['firstName']}                       ${firstname_A}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['lastName']}                        ${lastname_A} 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['userType']}                        ${userType[0]}     
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['status']}                          ACTIVE    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['mobileNo']}                        ${PUSERNAME_E}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['deptId']}                          ${dep_id}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['subdomain']}                       1
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['admin']}                           ${bool[1]} 
      
        ...    ELSE IF     '${resp.json()[${i}]['id']}' == '${u_id2}'   
        ...    Run Keywords
        ...    Should Be Equal As Strings  ${resp.json()[${i}]['lastName']}                           ${lastname2} 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['firstName']}                       ${firstname2}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['mobileNo']}                        ${PUSERNAME_U2}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['dob']}                             ${dob2}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['gender']}                          ${Genderlist[0]}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['userType']}                        ${userType[2]}     
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['status']}                          ACTIVE    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['email']}                           ${P_Email}${PUSERNAME_U2}.${test_mail}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['city']}                            ${city2}   ignore_case=True
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['state']}                           ${state2}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['deptId']}                          0
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['subdomain']}                       0
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['admin']}                           ${bool[1]} 

     END

JD-TC-GetUsers-6
     [Documentation]  Get users by departmentId

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200   

     ${resp}=  Get User    deptId-eq=${dep_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200 
     ${len}=  Get Length  ${resp.json()}
     # Should Be Equal As Integers  ${len}  3
     FOR  ${i}  IN RANGE   ${len}
        Run Keyword IF  '${resp.json()[${i}]['id']}' == '${u_id}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['firstName']}                       ${firstname}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['lastName']}                        ${lastname}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['mobileNo']}                        ${PUSERNAME_U1}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['dob']}                             ${dob}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['gender']}                          ${Genderlist[0]}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['userType']}                        ${userType[0]}     
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['status']}                          ACTIVE    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['email']}                           ${P_Email}${PUSERNAME_U1}.${test_mail}  
     #    ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['city']}                            ${city}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['state']}                           ${state}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['deptId']}                          ${dep_id}     
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['subdomain']}                       ${sub_domain_id}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['admin']}                           ${bool[0]} 

        ...    ELSE IF     '${resp.json()[${i}]['id']}' == '${id}'   
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['firstName']}                       ${firstname_A}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['lastName']}                        ${lastname_A} 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['userType']}                        ${userType[0]}     
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['status']}                          ACTIVE    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['mobileNo']}                        ${PUSERNAME_E}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['deptId']}                          ${dep_id}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['subdomain']}                       1
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['admin']}                           ${bool[1]} 
      
     END
     
JD-TC-GetUsers-7
     [Documentation]  Get users by primaryMobileNo

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200   

     ${resp}=  Get User    primaryMobileNo-eq=${PUSERNAME_U1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200  
     Verify Response List  ${resp}  0  id=${u_id}  firstName=${firstname}  lastName=${lastname}  mobileNo=${PUSERNAME_U1}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U1}.${test_mail}  city=${city}  state=${state}  deptId=${dep_id}  subdomain=${sub_domain_id}  admin=${bool[0]}  

JD-TC-GetUsers-9
     [Documentation]  Get users by state

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200   

     ${resp}=  Get User    state-eq=${state}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200  
     Verify Response List  ${resp}  0  id=${u_id}  firstName=${firstname}  lastName=${lastname}   mobileNo=${PUSERNAME_U1}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U1}.${test_mail}  city=${city}  state=${state}  deptId=${dep_id}  subdomain=${sub_domain_id}  admin=${bool[0]}  

JD-TC-GetUsers-10
     [Documentation]  Get users by isAdmin

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200   

     ${resp}=  Get User    isAdmin-eq=${bool[0]}  
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200 
     Verify Response List  ${resp}  0  id=${u_id}  firstName=${firstname}  lastName=${lastname}    mobileNo=${PUSERNAME_U1}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U1}.${test_mail}  city=${city}  state=${state}  deptId=${dep_id}  subdomain=${sub_domain_id}  admin=${bool[0]}   


JD-TC-GetUsers-11
     [Documentation]  Get users by locationName

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200  

     ${resp}=  Get User    city-eq=${city2}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response List  ${resp}  0  id=${u_id2}  firstName=${firstname2}  lastName=${lastname2}   mobileNo=${PUSERNAME_U2}  dob=${dob2}  gender=${Genderlist[0]}  userType=${userType[2]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U2}.${test_mail}  city=${city2}  state=${state2}  deptId=0  subdomain=0  admin=${bool[1]}   

JD-TC-GetUsers-12
     [Documentation]  Get users by pinCode

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200  

     ${resp}=  Get User    pinCode-eq=${pin} 
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200  
     Verify Response List  ${resp}  0  id=${u_id}  firstName=${firstname}  lastName=${lastname}   mobileNo=${PUSERNAME_U1}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U1}.${test_mail}  city=${city}  state=${state}  deptId=${dep_id}  subdomain=${sub_domain_id}  admin=${bool[0]}   
   
JD-TC-GetUsers -UH1
     [Documentation]   Provider get Users without login      
     ${resp}=  Get User
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings  ${resp.json()}    ${SESSION_EXPIRED}
 
 
JD-TC-GetUsers -UH2
    [Documentation]   Consumer get users
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}



*** Comments ***

JD-TC-GetUsers-13

    ${resp}=  Encrypted Provider Login  ${PUSERNAME57}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Test Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    # clear_queue      ${PUSERNAME57}
    # clear_service    ${PUSERNAME57}
    clear_customer   ${PUSERNAME57}

    ${pid}=  get_acc_id  ${PUSERNAME57}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
   
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

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
    Set Test Variable  ${dep_id1}  ${resp.json()['departments'][0]['departmentId']}
     
    ${ph5}=  Evaluate  ${PUSERNAME57}+1000440000
    ${firstname5}=  FakerLibrary.name
    ${lastname5}=  FakerLibrary.last_name
    ${dob5}=  FakerLibrary.Date
    # ${pin5}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin5}
     FOR    ${i}    IN RANGE    3
        ${pin5}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin5}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    Set Test Variable  ${city5}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state5}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin5}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
 
    ${whpnum5}=  Evaluate  ${PUSERNAME67}+336245
    ${tlgnum5}=  Evaluate  ${PUSERNAME67}+336345

    ${resp}=  Create User  ${firstname5}  ${lastname5}  ${dob5}  ${Genderlist[0]}  ${P_Email}${ph5}.${test_mail}   ${userType[0]}  ${pin5}  ${countryCodes[1]}  ${ph5}  ${dep_id1}  ${sub_domain_id}  ${bool[1]}  ${countryCodes[1]}  ${whpnum5}  ${countryCodes[1]}  ${tlgnum5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id5}  ${resp.json()}
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_id}   ${resp.json()[0]['id']}
    Set Test Variable   ${p2_id}   ${resp.json()[1]['id']}
   
    ${ph6}=  Evaluate  ${PUSERNAME67}+1000440001
    clear_users  ${ph6}
    ${firstname6}=  FakerLibrary.name
    ${lastname6}=  FakerLibrary.last_name
    ${dob6}=  FakerLibrary.Date
    ${pin6}=  get_pincode
    
    ${resp}=  Create User  ${firstname6}  ${lastname6}  ${dob6}  ${Genderlist[0]}  ${P_Email}${ph6}.${test_mail}   ${userType[1]}  ${pin6}  ${countryCodes[1]}  ${ph6}  ${dep_id1}  ${sub_domain_id}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id6}  ${resp.json()}
    
    ${ph7}=  Evaluate  ${PUSERNAME67}+1000440003
    clear_users  ${ph7}
    ${firstname7}=  FakerLibrary.name
    ${lastname7}=  FakerLibrary.last_name
    ${dob7}=  FakerLibrary.Date
    ${pin7}=  get_pincode
   
    ${resp}=  Create User  ${firstname7}  ${lastname7}  ${dob7}  ${Genderlist[0]}  ${P_Email}${ph7}.${test_mail}   ${userType[2]}  ${pin7}  ${countryCodes[1]}  ${ph7}  ${dep_id1}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id7}  ${resp.json()}

    ${resp}=  Get User    userType-eq=${userType[0]}   isAdmin-eq=${bool[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Verify Response List  ${resp}  0  id=${u_id5}  firstName=${firstname5}  lastName=${lastname5}   mobileNo=${ph5}  dob=${dob5}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${ph5}.${test_mail}  city=${city5}  state=${state5}  deptId=${dep_id1}  subdomain=${sub_domain_id}  admin=${bool[1]}   
