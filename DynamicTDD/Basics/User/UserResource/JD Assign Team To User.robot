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
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

***Test Cases***

JD-TC-AssignTeamToUser-1

     [Documentation]  Assign team to multiple users

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

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
     ${resp2}=   Get Business Profile
     Log  ${resp2.json()}
     Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}
     ${team_name2}=  FakerLibrary.name
     Set Suite Variable  ${team_name2}
     ${team_size2}=  Random Int  min=10  max=50
     ${desc2}=   FakerLibrary.sentence
     Set Suite Variable  ${desc2}
     ${resp}=  Create Team For User  ${team_name2}  ${team_size2}  ${desc2}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Suite Variable  ${t_id1}  ${resp.json()}
     ${team_name3}=  FakerLibrary.name
     Set Suite Variable  ${team_name3}
     ${desc3}=   FakerLibrary.sentence
     Set Suite Variable  ${desc3}
     ${resp}=  Create Team For User  ${team_name3}  ${EMPTY}  ${desc3} 
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Suite Variable  ${t_id2}  ${resp.json()}

     ${u_id1} =  Create Sample User    deptId=${dep_id}
     Set Suite Variable  ${u_id1}

     ${u_id2} =  Create Sample User    deptId=${dep_id}
     Set Suite Variable  ${u_id2}

     ${user_ids}=  Create List  ${u_id1}  ${u_id2}
     ${resp}=   Assign Team To User  ${user_ids}  ${t_id1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get Teams
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
   
JD-TC-AssignTeamToUser-2

     [Documentation]  Assign  multiple team to multiple users

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
   
     ${u_id3} =  Create Sample User    deptId=${dep_id}
     Set Suite Variable  ${u_id3}

     ${u_id4} =  Create Sample User    deptId=${dep_id}
     Set Suite Variable  ${u_id4}

     ${user_ids1}=  Create List  ${u_id1}  ${u_id2}  ${u_id3}  ${u_id4}
     ${user_ids2}=  Create List  ${u_id3}  ${u_id4}
     ${resp}=   Assign Team To User  ${user_ids1}  ${t_id1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=   Assign Team To User  ${user_ids2}  ${t_id2}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get Teams
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
    
JD-TC-AssignTeamToUser-3

     [Documentation]  Create team by user login with user type PROVIDER with admin privilage TRUE and assign team

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${PUSERNAME_U1}  ${u_id} =  Create and Configure Sample User   admin=${bool[1]}   deptId=${dep_id}
     Set Suite Variable  ${u_id}

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${team_name2}=  FakerLibrary.name
     ${team_size2}=  Random Int  min=10  max=50
     ${desc2}=   FakerLibrary.sentence
     ${user_ids}=  Create List  ${u_id}
     ${resp}=   Assign Team To User  ${user_ids}  ${t_id2}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get User By Id  ${u_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
  
     ${resp}=  Get Team By Id  ${t_id2}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-AssignTeamToUser-4

     [Documentation]  Create team by user login with user type ADMIN then assign team to user

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${PUSERNAME_U5}  ${u_id3} =  Create and Configure Sample User   userType=${userType[2]}   deptId=${dep_id}

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U5}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${team_name2}=  FakerLibrary.name
     ${team_size2}=  Random Int  min=10  max=50
     ${desc2}=   FakerLibrary.sentence
     ${resp}=  Create Team For User  ${team_name2}  ${team_size2}  ${desc2}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Suite Variable  ${t_id4}  ${resp.json()}

     ${resp}=  Get Team By Id  ${t_id4}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${user_ids}=  Create List  ${u_id3}
     ${resp}=   Assign Team To User  ${user_ids}  ${t_id4}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get Team By Id  ${t_id4}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-AssignTeamToUser-5

     [Documentation]  Create team by user login with user type ASSISTANT with admin privilage TRUE then try to assign team

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${PUSERNAME_U5}  ${u_id3} =  Create and Configure Sample User   admin=${bool[1]}  userType=${userType[1]}   deptId=${dep_id}

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U5}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${user_ids}=  Create List  ${u_id3}
     ${resp}=   Assign Team To User  ${user_ids}  ${t_id2}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get Team By Id  ${t_id2}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
    
JD-TC-AssignTeamToUser-6

     [Documentation]  Assign  multiple users with same mutiple team 

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     # ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+601121
     # clear_users  ${PUSERNAME_U3}
     # ${firstname3}=  FakerLibrary.name
     # ${lastname3}=  FakerLibrary.last_name
     # ${address3}=  get_address
     # ${dob3}=  FakerLibrary.Date
     # # ${pin3}=  get_pincode
     # # ${resp}=  Get LocationsByPincode     ${pin3}
     # FOR    ${i}    IN RANGE    3
     #    ${pin3}=  get_pincode
     #    ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin3}
     #    IF    '${kwstatus}' == 'FAIL'
     #            Continue For Loop
     #    ELSE IF    '${kwstatus}' == 'PASS'
     #            Exit For Loop
     #    END
     # END
     # Should Be Equal As Strings    ${resp.status_code}    200  
     # Set Test Variable  ${city3}   ${resp.json()[0]['PostOffice'][0]['District']}   
     # Set Test Variable  ${state3}  ${resp.json()[0]['PostOffice'][0]['State']}
    
     # ${resp}=  Create User  ${firstname3}  ${lastname3}  ${dob3}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U3}.${test_mail}   ${userType[0]}  ${pin3}  ${countryCodes[1]}  ${PUSERNAME_U3}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     # Log   ${resp.json()}
     # Should Be Equal As Strings  ${resp.status_code}  200
     # Set Test Variable  ${u_id6}  ${resp.json()}

     ${u_id6} =  Create Sample User    deptId=${dep_id}
     ${u_id7} =  Create Sample User    deptId=${dep_id}


     # ${PUSERNAME_U4}=  Evaluate  ${PUSERNAME}+601122
     # clear_users  ${PUSERNAME_U4}
     # ${firstname4}=  FakerLibrary.name
     # ${lastname4}=  FakerLibrary.last_name
     # ${address4}=  get_address
     # ${dob4}=  FakerLibrary.Date
     # # ${pin4}=  get_pincode
     # # ${resp}=  Get LocationsByPincode     ${pin4}
     # FOR    ${i}    IN RANGE    3
     #    ${pin4}=  get_pincode
     #    ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin4}
     #    IF    '${kwstatus}' == 'FAIL'
     #            Continue For Loop
     #    ELSE IF    '${kwstatus}' == 'PASS'
     #            Exit For Loop
     #    END
     # END
     # Should Be Equal As Strings    ${resp.status_code}    200 
     # Set Test Variable  ${city4}   ${resp.json()[0]['PostOffice'][0]['District']}   
     # Set Test Variable  ${state4}  ${resp.json()[0]['PostOffice'][0]['State']}
    
     # ${resp}=  Create User  ${firstname4}  ${lastname4}  ${dob4}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U4}.${test_mail}   ${userType[0]}  ${pin4}  ${countryCodes[1]}  ${PUSERNAME_U4}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     # Log   ${resp.json()}
     # Should Be Equal As Strings  ${resp.status_code}  200
     # Set Test Variable  ${u_id7}  ${resp.json()}

     ${team_name6}=  FakerLibrary.name
     ${desc6}=   FakerLibrary.sentence
     ${resp}=  Create Team For User  ${team_name6}  ${EMPTY}  ${desc6} 
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Test Variable  ${t_id6}  ${resp.json()}

     ${team_name7}=  FakerLibrary.name
     ${desc7}=   FakerLibrary.sentence
     ${resp}=  Create Team For User  ${team_name7}  ${EMPTY}  ${desc7} 
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Test Variable  ${t_id7}  ${resp.json()}

     ${team_name8}=  FakerLibrary.name
     ${desc8}=   FakerLibrary.sentence
     ${resp}=  Create Team For User  ${team_name8}  ${EMPTY}  ${desc8} 
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Test Variable  ${t_id8}  ${resp.json()}

     ${user_ids1}=  Create List  ${u_id6}  ${u_id7}  
     ${resp}=   Assign Team To User  ${user_ids1}  ${t_id6}  ${t_id7}  
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
   
     ${resp}=  Get Teams
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Get Team By Id  ${t_id6}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     
     ${resp}=  Get Team By Id  ${t_id7}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
   
JD-TC-AssignTeamToUser-UH1

     [Documentation]  Create team by user login with user type ASSISTANT with admin privilage FALSE then try to assign team
     
     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${PUSERNAME_U5}=  Evaluate  ${PUSERNAME}+330082
     clear_users  ${PUSERNAME_U5}
     ${firstname3}=  FakerLibrary.name
     ${lastname3}=  FakerLibrary.last_name
     ${address3}=  get_address
     ${dob3}=  FakerLibrary.Date
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
     Set Test Variable  ${city3}   ${resp.json()[0]['PostOffice'][0]['District']}   
     Set Test Variable  ${state3}  ${resp.json()[0]['PostOffice'][0]['State']}      
     Set Test Variable  ${pin3}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
 
     ${resp}=  Create User  ${firstname3}  ${lastname3}  ${dob3}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U5}.${test_mail}   ${userType[0]}  ${pin3}  ${countryCodes[1]}  ${PUSERNAME_U5}  ${dep_id}  ${sub_domain_id}  ${bool[0]}   ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${u_id3}  ${resp.json()}

     ${resp}=  SendProviderResetMail   ${PUSERNAME_U5}
     Should Be Equal As Strings  ${resp.status_code}  200
     @{resp}=  ResetProviderPassword  ${PUSERNAME_U5}  ${PASSWORD}  2
     Should Be Equal As Strings  ${resp[0].status_code}  200
     Should Be Equal As Strings  ${resp[1].status_code}  200
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U5}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${user_ids}=  Create List  ${u_id3}
     ${resp}=   Assign Team To User  ${user_ids}  ${t_id2}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION_TO_ADD_USERS_TO_TEAM}"
    
JD-TC-AssignTeamToUser-UH2
     [Documentation]  Create team by user login with user type PROVIDER with admin privilage FALSE then try to assign team
     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${PUSERNAME_U5}=  Evaluate  ${PUSERNAME}+330098
     clear_users  ${PUSERNAME_U5}
     ${firstname3}=  FakerLibrary.name
     ${lastname3}=  FakerLibrary.last_name
     ${address3}=  get_address
     ${dob3}=  FakerLibrary.Date
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
     Set Test Variable  ${city3}   ${resp.json()[0]['PostOffice'][0]['District']}   
     Set Test Variable  ${state3}  ${resp.json()[0]['PostOffice'][0]['State']}      
     Set Test Variable  ${pin3}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
 
     ${resp}=  Create User  ${firstname3}  ${lastname3}  ${dob3}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U5}.${test_mail}   ${userType[0]}  ${pin3}  ${countryCodes[1]}  ${PUSERNAME_U5}  ${dep_id}  ${sub_domain_id}  ${bool[0]}   ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id3}  ${resp.json()}

     ${resp}=  SendProviderResetMail   ${PUSERNAME_U5}
     Should Be Equal As Strings  ${resp.status_code}  200
     @{resp}=  ResetProviderPassword  ${PUSERNAME_U5}  ${PASSWORD}  2
     Should Be Equal As Strings  ${resp[0].status_code}  200
     Should Be Equal As Strings  ${resp[1].status_code}  200
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U5}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${user_ids}=  Create List  ${u_id3}
     ${resp}=   Assign Team To User  ${user_ids}  ${t_id2}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION_TO_ADD_USERS_TO_TEAM}"

JD-TC-AssignTeamToUser-UH3
     [Documentation]  Assign a user to empty team 
     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${user_ids}=  Create List  ${u_id3}
     ${resp}=   Assign Team To User  ${user_ids}  
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings   ${resp.json()}   ${TEAM_NOT_FOUND}

JD-TC-AssignTeamToUser-UH4
     [Documentation]  Assign empty users to a team
     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${user_ids}=  Create List  
     ${resp}=   Assign Team To User  ${user_ids}  ${t_id2}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings   "${resp.json()}"   "${USER_REQUIRED}"

JD-TC-AssignTeamToUser -UH5
     [Documentation]   Assign team to user without login      
     ${user_ids}=  Create List  ${u_id3}
     ${resp}=   Assign Team To User  ${user_ids}  ${t_id2}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-AssignTeamToUser -UH6
    [Documentation]   Assign team to user with consumer login
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${user_ids}=  Create List  ${u_id3}
    ${resp}=   Assign Team To User  ${user_ids}  ${t_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-AssignTeamToUser-UH7
     [Documentation]  Assign a disabled user to team
     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${PUSERNAME_U5}=  Evaluate  ${PUSERNAME}+330032
     clear_users  ${PUSERNAME_U5}
     ${firstname3}=  FakerLibrary.name
     ${lastname3}=  FakerLibrary.last_name
     ${address3}=  get_address
     ${dob3}=  FakerLibrary.Date
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
     Set Test Variable  ${city3}   ${resp.json()[0]['PostOffice'][0]['District']}   
     Set Test Variable  ${state3}  ${resp.json()[0]['PostOffice'][0]['State']}      
     Set Test Variable  ${pin3}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
 
     ${resp}=  Create User  ${firstname3}  ${lastname3}  ${dob3}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U5}.${test_mail}   ${userType[0]}  ${pin3}  ${countryCodes[1]}  ${PUSERNAME_U5}  ${dep_id}  ${sub_domain_id}  ${bool[0]}   ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${u_id3}  ${resp.json()}

     ${resp}=  EnableDisable User  ${u_id3}  ${toggle[1]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get User By Id  ${u_id3}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  id=${u_id3}   status=INACTIVE 
     
     ${user_ids}=  Create List  ${u_id3}
     ${resp}=   Assign Team To User  ${user_ids}  ${t_id2}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"  "${DISABLED_USER_CANT_ADD_TOTEAM}"
    












*** Comments ***
JD-TC-AssignTeamToUser-UH8
     [Documentation]  Assign a same user to same team multiple times
     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${PUSERNAME_U5}=  Evaluate  ${PUSERNAME}+330033
     clear_users  ${PUSERNAME_U5}
     ${firstname3}=  FakerLibrary.name
     ${lastname3}=  FakerLibrary.last_name
     ${address3}=  get_address
     ${dob3}=  FakerLibrary.Date
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
     Set Test Variable  ${city3}   ${resp.json()[0]['PostOffice'][0]['District']}   
     Set Test Variable  ${state3}  ${resp.json()[0]['PostOffice'][0]['State']}      
     Set Test Variable  ${pin3}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
 
     ${resp}=  Create User  ${firstname3}  ${lastname3}  ${dob3}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U5}.${test_mail}   ${userType[0]}  ${pin3}  ${countryCodes[1]}  ${PUSERNAME_U5}  ${dep_id}  ${sub_domain_id}  ${bool[0]}   ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${u_id3}  ${resp.json()}

     ${team_name}=  FakerLibrary.name
     ${desc}=   FakerLibrary.sentence
     ${resp}=  Create Team For User  ${team_name}  ${EMPTY}  ${desc} 
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Test Variable  ${t_id}  ${resp.json()}

     ${user_ids}=  Create List  ${u_id3}
     ${resp}=   Assign Team To User  ${user_ids}  ${t_id2}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
    
     ${resp}=   Assign Team To User  ${user_ids}  ${t_id2}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     # Should Be Equal As Strings  "${resp.json()}"  "${DISABLED_USER_CANT_ADD_TOTEAM}"
    
    


















