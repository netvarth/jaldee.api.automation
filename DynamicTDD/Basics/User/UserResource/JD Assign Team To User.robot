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
Variables         /ebs/TDD/varfiles/hl_musers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

***Test Cases***

JD-TC-AssignTeamToUser-1
     [Documentation]  Assign team to multiple users
     ${resp}=  Provider Login  ${HLMUSERNAME11}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  View Waitlist Settings
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
     Run Keyword If  '${resp}' != '${None}'   Log   ${resp.json()}
     Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200
     
     sleep  2s
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

     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+601199
     Set Suite Variable  ${PUSERNAME_U1}
     clear_users  ${PUSERNAME_U1}
     ${firstname1}=  FakerLibrary.name
     Set Suite Variable  ${firstname1}
     ${lastname1}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname1}
     ${dob1}=  FakerLibrary.Date
     Set Suite Variable  ${dob1}
     # ${pin1}=  get_pincode
     # Set Suite Variable  ${pin1}
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
     Should Be Equal As Strings    ${resp.status_code}    200 
     Set Suite Variable  ${pin1}
     Set Suite Variable  ${city1}   ${resp.json()[0]['PostOffice'][0]['District']}   
     Set Suite Variable  ${state1}  ${resp.json()[0]['PostOffice'][0]['State']} 
    
     ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id1}  ${resp.json()}
     ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+601198
     Set Suite Variable  ${PUSERNAME_U2}
     clear_users  ${PUSERNAME_U2}
     ${firstname2}=  FakerLibrary.name
     Set Suite Variable  ${firstname2}
     ${lastname2}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname2}
     ${dob2}=  FakerLibrary.Date
     Set Suite Variable  ${dob2}
     # ${pin2}=  get_pincode
     # Set Suite Variable  ${pin2}
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
     Should Be Equal As Strings    ${resp.status_code}    200 
     Set Suite Variable  ${pin2}
     Set Suite Variable  ${city2}   ${resp.json()[0]['PostOffice'][0]['District']}   
     Set Suite Variable  ${state2}  ${resp.json()[0]['PostOffice'][0]['State']}
    
     ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin2}  ${countryCodes[1]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id2}  ${resp.json()}

     ${user_ids}=  Create List  ${u_id1}  ${u_id2}
     ${resp}=   Assign Team To User  ${user_ids}  ${t_id1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get Teams
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Verify Response List  ${resp}  0  id=${t_id1}  name=${team_name2}  size=2  description=${desc2}  status=${status[0]}
     Should Be Equal As Strings  ${resp.json()[0]['users'][0]['id']}  ${u_id1}
     Should Be Equal As Strings  ${resp.json()[0]['users'][0]['firstName']}  ${firstname1}
     Should Be Equal As Strings  ${resp.json()[0]['users'][0]['lastName']}  ${lastname1}
     Should Be Equal As Strings  ${resp.json()[0]['users'][0]['mobileNo']}  ${PUSERNAME_U1}
     Should Be Equal As Strings  ${resp.json()[0]['users'][0]['dob']}  ${dob1}
     Should Be Equal As Strings  ${resp.json()[0]['users'][0]['gender']}  ${Genderlist[0]}
     Should Be Equal As Strings  ${resp.json()[0]['users'][0]['email']}  ${P_Email}${PUSERNAME_U1}.${test_mail}
#      Should Be Equal As Strings  ${resp.json()[0]['users'][0]['city']}  ${city1}
#      Should Be Equal As Strings  ${resp.json()[0]['users'][0]['state']}  ${state1}
     Should Be Equal As Strings  ${resp.json()[0]['users'][0]['countryCode']}  ${countryCodes[1]}
     Should Be Equal As Strings  ${resp.json()[0]['users'][0]['pincode']}  ${pin1}
     #Should Be Equal As Strings  ${resp.json()[0]['users'][0]['deptId']}  ${dep_id}
     #Should Be Equal As Strings  ${resp.json()[0]['users'][0]['subdomain']}  ${sub_domain_id}
     Should Be Equal As Strings  ${resp.json()[0]['users'][1]['id']}  ${u_id2}
     Should Be Equal As Strings  ${resp.json()[0]['users'][1]['firstName']}  ${firstname2}
     Should Be Equal As Strings  ${resp.json()[0]['users'][1]['lastName']}  ${lastname2}
     Should Be Equal As Strings  ${resp.json()[0]['users'][1]['mobileNo']}  ${PUSERNAME_U2}
     Should Be Equal As Strings  ${resp.json()[0]['users'][1]['dob']}  ${dob2}
     Should Be Equal As Strings  ${resp.json()[0]['users'][1]['gender']}  ${Genderlist[0]}
     Should Be Equal As Strings  ${resp.json()[0]['users'][1]['email']}  ${P_Email}${PUSERNAME_U2}.${test_mail}
#      Should Be Equal As Strings  ${resp.json()[0]['users'][1]['city']}  ${city2}
#      Should Be Equal As Strings  ${resp.json()[0]['users'][1]['state']}  ${state2}
     Should Be Equal As Strings  ${resp.json()[0]['users'][1]['countryCode']}  ${countryCodes[1]}
     Should Be Equal As Strings  ${resp.json()[0]['users'][1]['pincode']}  ${pin2}
     #Should Be Equal As Strings  ${resp.json()[0]['users'][1]['deptId']}  ${dep_id}
     #Should Be Equal As Strings  ${resp.json()[0]['users'][1]['subdomain']}  ${sub_domain_id}
     Verify Response List  ${resp}  1  id=${t_id2}  name=${team_name3}  size=0  description=${desc3}  status=${status[0]}  users=[]

JD-TC-AssignTeamToUser-2
     [Documentation]  Assign  multiple team to multiple users
     ${resp}=  Provider Login  ${HLMUSERNAME11}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+601197
     clear_users  ${PUSERNAME_U3}
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
     Should Be Equal As Strings    ${resp.status_code}    200  
     Set Test Variable  ${city3}   ${resp.json()[0]['PostOffice'][0]['District']}   
     Set Test Variable  ${state3}  ${resp.json()[0]['PostOffice'][0]['State']}
    
     ${resp}=  Create User  ${firstname3}  ${lastname3}  ${dob3}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U3}.${test_mail}   ${userType[0]}  ${pin3}  ${countryCodes[1]}  ${PUSERNAME_U3}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id3}  ${resp.json()}

     ${PUSERNAME_U4}=  Evaluate  ${PUSERNAME}+601196
     clear_users  ${PUSERNAME_U4}
     ${firstname4}=  FakerLibrary.name
     ${lastname4}=  FakerLibrary.last_name
     ${address4}=  get_address
     ${dob4}=  FakerLibrary.Date
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
     Should Be Equal As Strings    ${resp.status_code}    200 
     Set Test Variable  ${city4}   ${resp.json()[0]['PostOffice'][0]['District']}   
     Set Test Variable  ${state4}  ${resp.json()[0]['PostOffice'][0]['State']}
    
     ${resp}=  Create User  ${firstname4}  ${lastname4}  ${dob4}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U4}.${test_mail}   ${userType[0]}  ${pin4}  ${countryCodes[1]}  ${PUSERNAME_U4}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id4}  ${resp.json()}

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
     Verify Response List  ${resp}  0  id=${t_id1}  name=${team_name2}  size=4  description=${desc2}  status=${status[0]}
     Should Be Equal As Strings  ${resp.json()[0]['users'][0]['id']}  ${u_id1}
     Should Be Equal As Strings  ${resp.json()[0]['users'][0]['firstName']}  ${firstname1}
     Should Be Equal As Strings  ${resp.json()[0]['users'][0]['lastName']}  ${lastname1}
     Should Be Equal As Strings  ${resp.json()[0]['users'][0]['mobileNo']}  ${PUSERNAME_U1}
     Should Be Equal As Strings  ${resp.json()[0]['users'][0]['dob']}  ${dob1}
     Should Be Equal As Strings  ${resp.json()[0]['users'][0]['gender']}  ${Genderlist[0]}
     Should Be Equal As Strings  ${resp.json()[0]['users'][0]['email']}  ${P_Email}${PUSERNAME_U1}.${test_mail}
#      Should Be Equal As Strings  ${resp.json()[0]['users'][0]['city']}  ${city1}
#      Should Be Equal As Strings  ${resp.json()[0]['users'][0]['state']}  ${state1}
     Should Be Equal As Strings  ${resp.json()[0]['users'][0]['countryCode']}  ${countryCodes[1]}
#      Should Be Equal As Strings  ${resp.json()[0]['users'][0]['pincode']}  ${pin1}
     #Should Be Equal As Strings  ${resp.json()[0]['users'][0]['deptId']}  ${dep_id}
     #Should Be Equal As Strings  ${resp.json()[0]['users'][0]['subdomain']}  ${sub_domain_id}
     Should Be Equal As Strings  ${resp.json()[0]['users'][1]['id']}  ${u_id2}
     Should Be Equal As Strings  ${resp.json()[0]['users'][1]['firstName']}  ${firstname2}
     Should Be Equal As Strings  ${resp.json()[0]['users'][1]['lastName']}  ${lastname2}
     Should Be Equal As Strings  ${resp.json()[0]['users'][1]['mobileNo']}  ${PUSERNAME_U2}
     Should Be Equal As Strings  ${resp.json()[0]['users'][1]['dob']}  ${dob2}
     Should Be Equal As Strings  ${resp.json()[0]['users'][1]['gender']}  ${Genderlist[0]}
     Should Be Equal As Strings  ${resp.json()[0]['users'][1]['email']}  ${P_Email}${PUSERNAME_U2}.${test_mail}
#      Should Be Equal As Strings  ${resp.json()[0]['users'][1]['city']}  ${city2}
#      Should Be Equal As Strings  ${resp.json()[0]['users'][1]['state']}  ${state2}
     Should Be Equal As Strings  ${resp.json()[0]['users'][1]['countryCode']}  ${countryCodes[1]}
#      Should Be Equal As Strings  ${resp.json()[0]['users'][1]['pincode']}  ${pin2}
     #Should Be Equal As Strings  ${resp.json()[0]['users'][1]['deptId']}  ${dep_id}
     #Should Be Equal As Strings  ${resp.json()[0]['users'][1]['subdomain']}  ${sub_domain_id}
     Should Be Equal As Strings  ${resp.json()[0]['users'][2]['id']}  ${u_id3}
     Should Be Equal As Strings  ${resp.json()[0]['users'][2]['firstName']}  ${firstname3}
     Should Be Equal As Strings  ${resp.json()[0]['users'][2]['lastName']}  ${lastname3}
     Should Be Equal As Strings  ${resp.json()[0]['users'][2]['mobileNo']}  ${PUSERNAME_U3}
     Should Be Equal As Strings  ${resp.json()[0]['users'][2]['dob']}  ${dob3}
     Should Be Equal As Strings  ${resp.json()[0]['users'][2]['gender']}  ${Genderlist[0]}
     Should Be Equal As Strings  ${resp.json()[0]['users'][2]['email']}  ${P_Email}${PUSERNAME_U3}.${test_mail}
#      Should Be Equal As Strings  ${resp.json()[0]['users'][2]['city']}  ${city3}
#      Should Be Equal As Strings  ${resp.json()[0]['users'][2]['state']}  ${state3}
     Should Be Equal As Strings  ${resp.json()[0]['users'][2]['countryCode']}  ${countryCodes[1]}
#      Should Be Equal As Strings  ${resp.json()[0]['users'][2]['pincode']}  ${pin3}
     #Should Be Equal As Strings  ${resp.json()[0]['users'][2]['deptId']}  ${dep_id}
     #Should Be Equal As Strings  ${resp.json()[0]['users'][2]['subdomain']}  ${sub_domain_id}
     Should Be Equal As Strings  ${resp.json()[0]['users'][3]['id']}  ${u_id4}
     Should Be Equal As Strings  ${resp.json()[0]['users'][3]['firstName']}  ${firstname4}
     Should Be Equal As Strings  ${resp.json()[0]['users'][3]['lastName']}  ${lastname4}
     Should Be Equal As Strings  ${resp.json()[0]['users'][3]['mobileNo']}  ${PUSERNAME_U4}
     Should Be Equal As Strings  ${resp.json()[0]['users'][3]['dob']}  ${dob4}
     Should Be Equal As Strings  ${resp.json()[0]['users'][3]['gender']}  ${Genderlist[0]}
     Should Be Equal As Strings  ${resp.json()[0]['users'][3]['email']}  ${P_Email}${PUSERNAME_U4}.${test_mail}
#      Should Be Equal As Strings  ${resp.json()[0]['users'][3]['city']}  ${city4}
#      Should Be Equal As Strings  ${resp.json()[0]['users'][3]['state']}  ${state4}
     Should Be Equal As Strings  ${resp.json()[0]['users'][3]['countryCode']}  ${countryCodes[1]}
#      Should Be Equal As Strings  ${resp.json()[0]['users'][3]['pincode']}  ${pin4}
     #Should Be Equal As Strings  ${resp.json()[0]['users'][3]['deptId']}  ${dep_id}
     #Should Be Equal As Strings  ${resp.json()[0]['users'][3]['subdomain']}  ${sub_domain_id}
     Verify Response List  ${resp}  1  id=${t_id2}  name=${team_name3}  size=2  description=${desc3}  status=${status[0]}
     Should Be Equal As Strings  ${resp.json()[1]['users'][0]['id']}  ${u_id3}
     Should Be Equal As Strings  ${resp.json()[1]['users'][0]['firstName']}  ${firstname3}
     Should Be Equal As Strings  ${resp.json()[1]['users'][0]['lastName']}  ${lastname3}
     Should Be Equal As Strings  ${resp.json()[1]['users'][0]['mobileNo']}  ${PUSERNAME_U3}
     Should Be Equal As Strings  ${resp.json()[1]['users'][0]['dob']}  ${dob3}
     Should Be Equal As Strings  ${resp.json()[1]['users'][0]['gender']}  ${Genderlist[0]}
     Should Be Equal As Strings  ${resp.json()[1]['users'][0]['email']}  ${P_Email}${PUSERNAME_U3}.${test_mail}
#      Should Be Equal As Strings  ${resp.json()[1]['users'][0]['city']}  ${city3}
#      Should Be Equal As Strings  ${resp.json()[1]['users'][0]['state']}  ${state3}
     Should Be Equal As Strings  ${resp.json()[1]['users'][0]['countryCode']}  ${countryCodes[1]}
#      Should Be Equal As Strings  ${resp.json()[1]['users'][0]['pincode']}  ${pin3}
     #Should Be Equal As Strings  ${resp.json()[1]['users'][0]['deptId']}  ${dep_id}
     #Should Be Equal As Strings  ${resp.json()[1]['users'][0]['subdomain']}  ${sub_domain_id}
     Should Be Equal As Strings  ${resp.json()[1]['users'][1]['id']}  ${u_id4}
     Should Be Equal As Strings  ${resp.json()[1]['users'][1]['firstName']}  ${firstname4}
     Should Be Equal As Strings  ${resp.json()[1]['users'][1]['lastName']}  ${lastname4}
     Should Be Equal As Strings  ${resp.json()[1]['users'][1]['mobileNo']}  ${PUSERNAME_U4}
     Should Be Equal As Strings  ${resp.json()[1]['users'][1]['dob']}  ${dob4}
     Should Be Equal As Strings  ${resp.json()[1]['users'][1]['gender']}  ${Genderlist[0]}
     Should Be Equal As Strings  ${resp.json()[1]['users'][1]['email']}  ${P_Email}${PUSERNAME_U4}.${test_mail}
#      Should Be Equal As Strings  ${resp.json()[1]['users'][1]['city']}  ${city4}
#      Should Be Equal As Strings  ${resp.json()[1]['users'][1]['state']}  ${state4}
     Should Be Equal As Strings  ${resp.json()[1]['users'][1]['countryCode']}  ${countryCodes[1]}
#      Should Be Equal As Strings  ${resp.json()[1]['users'][1]['pincode']}  ${pin4}
     #Should Be Equal As Strings  ${resp.json()[1]['users'][1]['deptId']}  ${dep_id}
     #Should Be Equal As Strings  ${resp.json()[1]['users'][1]['subdomain']}  ${sub_domain_id}

JD-TC-AssignTeamToUser-3
     [Documentation]  Create team by user login with user type PROVIDER with admin privilage TRUE and assign team
     ${resp}=  Provider Login  ${HLMUSERNAME11}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${u_id}=  Create Sample User  admin=${bool[1]}
     Set Suite Variable  ${u_id}
     ${resp}=  Get User By Id  ${u_id}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${PUSERNAME_U1}  ${resp.json()['mobileNo']}
     ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
     Should Be Equal As Strings  ${resp.status_code}  200
     @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
     Should Be Equal As Strings  ${resp[0].status_code}  200
     Should Be Equal As Strings  ${resp[1].status_code}  200
     ${resp}=  ProviderLogin  ${PUSERNAME_U1}  ${PASSWORD}
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
     Set Test Variable  ${fname}  ${resp.json()['firstName']}
     Set Test Variable  ${lname}  ${resp.json()['lastName']}
     Set Test Variable  ${mno}  ${resp.json()['mobileNo']}
     Set Test Variable  ${db}  ${resp.json()['dob']}
     Set Test Variable  ${gen}  ${resp.json()['gender']}
     Set Test Variable  ${eml}  ${resp.json()['email']}
     Set Test Variable  ${cty}  ${resp.json()['city']}
     Set Test Variable  ${sts}  ${resp.json()['state']}
     Set Test Variable  ${pcode}  ${resp.json()['pincode']}
     ${resp}=  Get Team By Id  ${t_id2}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Verify Response  ${resp}  id=${t_id2}  name=${team_name3}  size=1  description=${desc3}  status=${status[0]}
     Should Be Equal As Strings  ${resp.json()['users'][0]['id']}  ${u_id}
     Should Be Equal As Strings  ${resp.json()['users'][0]['firstName']}  ${fname}
     Should Be Equal As Strings  ${resp.json()['users'][0]['lastName']}  ${lname}
     Should Be Equal As Strings  ${resp.json()['users'][0]['mobileNo']}  ${mno}
     Should Be Equal As Strings  ${resp.json()['users'][0]['dob']}  ${db}
     Should Be Equal As Strings  ${resp.json()['users'][0]['gender']}  ${Genderlist[0]}
     Should Be Equal As Strings  ${resp.json()['users'][0]['email']}  ${eml}
#      Should Be Equal As Strings  ${resp.json()['users'][0]['city']}  ${cty}
#      Should Be Equal As Strings  ${resp.json()['users'][0]['state']}  ${sts}
     Should Be Equal As Strings  ${resp.json()['users'][0]['countryCode']}  ${countryCodes[1]}
#      Should Be Equal As Strings  ${resp.json()['users'][0]['pincode']}  ${pcode}


JD-TC-AssignTeamToUser-4
     [Documentation]  Create team by user login with user type ADMIN then assign team to user
     ${resp}=  Provider Login  ${HLMUSERNAME11}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${PUSERNAME_U5}=  Evaluate  ${PUSERNAME}+330099
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
 
     ${resp}=  Create User  ${firstname3}  ${lastname3}  ${dob3}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U5}.${test_mail}   ${userType[2]}  ${pin3}  ${countryCodes[1]}  ${PUSERNAME_U5}  ${dep_id}  ${sub_domain_id}  ${bool[0]}   ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${u_id3}  ${resp.json()}

     ${resp}=  SendProviderResetMail   ${PUSERNAME_U5}
     Should Be Equal As Strings  ${resp.status_code}  200
     @{resp}=  ResetProviderPassword  ${PUSERNAME_U5}  ${PASSWORD}  2
     Should Be Equal As Strings  ${resp[0].status_code}  200
     Should Be Equal As Strings  ${resp[1].status_code}  200
     ${resp}=  ProviderLogin  ${PUSERNAME_U5}  ${PASSWORD}
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
     # Verify Response  ${resp}  id=${t_id4}  name=${team_name2}  size=${team_size2}  description=${desc2}  status=${status[0]}  users=[]
     ${user_ids}=  Create List  ${u_id3}
     ${resp}=   Assign Team To User  ${user_ids}  ${t_id4}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get Team By Id  ${t_id4}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Verify Response  ${resp}  id=${t_id4}  name=${team_name2}  size=1  description=${desc2}  status=${status[0]}
     Should Be Equal As Strings  ${resp.json()['users'][0]['id']}  ${u_id3}
     Should Be Equal As Strings  ${resp.json()['users'][0]['firstName']}  ${firstname3}
     Should Be Equal As Strings  ${resp.json()['users'][0]['lastName']}  ${lastname3}
     Should Be Equal As Strings  ${resp.json()['users'][0]['mobileNo']}  ${PUSERNAME_U5}
     Should Be Equal As Strings  ${resp.json()['users'][0]['dob']}  ${dob3}
     Should Be Equal As Strings  ${resp.json()['users'][0]['gender']}  ${Genderlist[0]}
     Should Be Equal As Strings  ${resp.json()['users'][0]['email']}  ${P_Email}${PUSERNAME_U5}.${test_mail}
#      Should Be Equal As Strings  ${resp.json()['users'][0]['city']}  ${city3}
#      Should Be Equal As Strings  ${resp.json()['users'][0]['state']}  ${state3}
#      Should Be Equal As Strings  ${resp.json()['users'][0]['countryCode']}  ${countryCodes[1]}
#      Should Be Equal As Strings  ${resp.json()['users'][0]['pincode']}  ${pin3}


JD-TC-AssignTeamToUser-5
     [Documentation]  Create team by user login with user type ASSISTANT with admin privilage TRUE then try to assign team
     ${resp}=  Provider Login  ${HLMUSERNAME11}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${PUSERNAME_U5}=  Evaluate  ${PUSERNAME}+330081
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
 
     ${resp}=  Create User  ${firstname3}  ${lastname3}  ${dob3}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U5}.${test_mail}   ${userType[1]}  ${pin3}  ${countryCodes[1]}  ${PUSERNAME_U5}  ${dep_id}  ${sub_domain_id}  ${bool[1]}   ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${u_id3}  ${resp.json()}

     ${resp}=  SendProviderResetMail   ${PUSERNAME_U5}
     Should Be Equal As Strings  ${resp.status_code}  200
     @{resp}=  ResetProviderPassword  ${PUSERNAME_U5}  ${PASSWORD}  2
     Should Be Equal As Strings  ${resp[0].status_code}  200
     Should Be Equal As Strings  ${resp[1].status_code}  200
     ${resp}=  ProviderLogin  ${PUSERNAME_U5}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${user_ids}=  Create List  ${u_id3}
     ${resp}=   Assign Team To User  ${user_ids}  ${t_id2}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get Team By Id  ${t_id2}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Verify Response  ${resp}  id=${t_id2}  name=${team_name3}  size=1  description=${desc3}  status=${status[0]}
     Should Be Equal As Strings  ${resp.json()['users'][0]['id']}  ${u_id3}
     Should Be Equal As Strings  ${resp.json()['users'][0]['firstName']}  ${firstname3}
     Should Be Equal As Strings  ${resp.json()['users'][0]['lastName']}  ${lastname3}
     Should Be Equal As Strings  ${resp.json()['users'][0]['mobileNo']}  ${PUSERNAME_U5}
     Should Be Equal As Strings  ${resp.json()['users'][0]['dob']}  ${dob3}
     Should Be Equal As Strings  ${resp.json()['users'][0]['gender']}  ${Genderlist[0]}
     Should Be Equal As Strings  ${resp.json()['users'][0]['email']}  ${P_Email}${PUSERNAME_U5}.${test_mail}
#      Should Be Equal As Strings  ${resp.json()['users'][0]['city']}  ${city3}
#      Should Be Equal As Strings  ${resp.json()['users'][0]['state']}  ${state3}
#      Should Be Equal As Strings  ${resp.json()['users'][0]['countryCode']}  ${countryCodes[1]}
#      Should Be Equal As Strings  ${resp.json()['users'][0]['pincode']}  ${pin3}

JD-TC-AssignTeamToUser-6
     [Documentation]  Assign  multiple users with same mutiple team 
     ${resp}=  Provider Login  ${HLMUSERNAME11}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+601121
     clear_users  ${PUSERNAME_U3}
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
     Should Be Equal As Strings    ${resp.status_code}    200  
     Set Test Variable  ${city3}   ${resp.json()[0]['PostOffice'][0]['District']}   
     Set Test Variable  ${state3}  ${resp.json()[0]['PostOffice'][0]['State']}
    
     ${resp}=  Create User  ${firstname3}  ${lastname3}  ${dob3}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U3}.${test_mail}   ${userType[0]}  ${pin3}  ${countryCodes[1]}  ${PUSERNAME_U3}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${u_id6}  ${resp.json()}

     ${PUSERNAME_U4}=  Evaluate  ${PUSERNAME}+601122
     clear_users  ${PUSERNAME_U4}
     ${firstname4}=  FakerLibrary.name
     ${lastname4}=  FakerLibrary.last_name
     ${address4}=  get_address
     ${dob4}=  FakerLibrary.Date
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
     Should Be Equal As Strings    ${resp.status_code}    200 
     Set Test Variable  ${city4}   ${resp.json()[0]['PostOffice'][0]['District']}   
     Set Test Variable  ${state4}  ${resp.json()[0]['PostOffice'][0]['State']}
    
     ${resp}=  Create User  ${firstname4}  ${lastname4}  ${dob4}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U4}.${test_mail}   ${userType[0]}  ${pin4}  ${countryCodes[1]}  ${PUSERNAME_U4}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${u_id7}  ${resp.json()}

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
     Verify Response  ${resp}  id=${t_id6}  name=${team_name6}  size=2  description=${desc6}  status=${status[0]}
     Should Be Equal As Strings  ${resp.json()['users'][0]['id']}  ${u_id6}
     Should Be Equal As Strings  ${resp.json()['users'][0]['firstName']}  ${firstname3}
     Should Be Equal As Strings  ${resp.json()['users'][0]['lastName']}  ${lastname3}
     Should Be Equal As Strings  ${resp.json()['users'][0]['mobileNo']}  ${PUSERNAME_U3}
     Should Be Equal As Strings  ${resp.json()['users'][0]['dob']}  ${dob3}
     Should Be Equal As Strings  ${resp.json()['users'][0]['gender']}  ${Genderlist[0]}
     Should Be Equal As Strings  ${resp.json()['users'][0]['email']}  ${P_Email}${PUSERNAME_U3}.${test_mail}
#      Should Be Equal As Strings  ${resp.json()['users'][0]['city']}  ${city3}
#      Should Be Equal As Strings  ${resp.json()['users'][0]['state']}  ${state3}
#      Should Be Equal As Strings  ${resp.json()['users'][0]['countryCode']}  ${countryCodes[1]}
#      Should Be Equal As Strings  ${resp.json()['users'][0]['pincode']}  ${pin3}

     Should Be Equal As Strings  ${resp.json()['users'][1]['id']}  ${u_id7}
     Should Be Equal As Strings  ${resp.json()['users'][1]['firstName']}  ${firstname4}
     Should Be Equal As Strings  ${resp.json()['users'][1]['lastName']}  ${lastname4}
     Should Be Equal As Strings  ${resp.json()['users'][1]['mobileNo']}  ${PUSERNAME_U4}
     Should Be Equal As Strings  ${resp.json()['users'][1]['dob']}  ${dob4}
     Should Be Equal As Strings  ${resp.json()['users'][1]['gender']}  ${Genderlist[0]}
     Should Be Equal As Strings  ${resp.json()['users'][1]['email']}  ${P_Email}${PUSERNAME_U4}.${test_mail}
#      Should Be Equal As Strings  ${resp.json()['users'][1]['city']}  ${city4}
#      Should Be Equal As Strings  ${resp.json()['users'][1]['state']}  ${state4}
#      Should Be Equal As Strings  ${resp.json()['users'][1]['countryCode']}  ${countryCodes[1]}
#      Should Be Equal As Strings  ${resp.json()['users'][1]['pincode']}  ${pin4}

     ${resp}=  Get Team By Id  ${t_id7}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Verify Response  ${resp}  id=${t_id7}  name=${team_name7}  size=2  description=${desc7}  status=${status[0]}
     Should Be Equal As Strings  ${resp.json()['users'][0]['id']}  ${u_id6}
     Should Be Equal As Strings  ${resp.json()['users'][0]['firstName']}  ${firstname3}
     Should Be Equal As Strings  ${resp.json()['users'][0]['lastName']}  ${lastname3}
     Should Be Equal As Strings  ${resp.json()['users'][0]['mobileNo']}  ${PUSERNAME_U3}
     Should Be Equal As Strings  ${resp.json()['users'][0]['dob']}  ${dob3}
     Should Be Equal As Strings  ${resp.json()['users'][0]['gender']}  ${Genderlist[0]}
     Should Be Equal As Strings  ${resp.json()['users'][0]['email']}  ${P_Email}${PUSERNAME_U3}.${test_mail}
#      Should Be Equal As Strings  ${resp.json()['users'][0]['city']}  ${city3}
#      Should Be Equal As Strings  ${resp.json()['users'][0]['state']}  ${state3}
#      Should Be Equal As Strings  ${resp.json()['users'][0]['countryCode']}  ${countryCodes[1]}
#      Should Be Equal As Strings  ${resp.json()['users'][0]['pincode']}  ${pin3}

     Should Be Equal As Strings  ${resp.json()['users'][1]['id']}  ${u_id7}
     Should Be Equal As Strings  ${resp.json()['users'][1]['firstName']}  ${firstname4}
     Should Be Equal As Strings  ${resp.json()['users'][1]['lastName']}  ${lastname4}
     Should Be Equal As Strings  ${resp.json()['users'][1]['mobileNo']}  ${PUSERNAME_U4}
     Should Be Equal As Strings  ${resp.json()['users'][1]['dob']}  ${dob4}
     Should Be Equal As Strings  ${resp.json()['users'][1]['gender']}  ${Genderlist[0]}
     Should Be Equal As Strings  ${resp.json()['users'][1]['email']}  ${P_Email}${PUSERNAME_U4}.${test_mail}
#      Should Be Equal As Strings  ${resp.json()['users'][1]['city']}  ${city4}
#      Should Be Equal As Strings  ${resp.json()['users'][1]['state']}  ${state4}
#      Should Be Equal As Strings  ${resp.json()['users'][1]['countryCode']}  ${countryCodes[1]}
#      Should Be Equal As Strings  ${resp.json()['users'][1]['pincode']}  ${pin4}

     # ${resp}=   Assign Team To User  ${user_ids1}  ${t_id8}  
     # Log   ${resp.json()}
     # Should Be Equal As Strings  ${resp.status_code}  200

     # ${resp}=  Get Team By Id  ${t_id6}
     # Log   ${resp.json()}
     # Should Be Equal As Strings    ${resp.status_code}    200

     # ${resp}=  Get Teams
     # Log   ${resp.json()}
     # Should Be Equal As Strings    ${resp.status_code}    200
   

JD-TC-AssignTeamToUser-UH1
     [Documentation]  Create team by user login with user type ASSISTANT with admin privilage FALSE then try to assign team
     ${resp}=  Provider Login  ${HLMUSERNAME11}  ${PASSWORD}
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
     ${resp}=  ProviderLogin  ${PUSERNAME_U5}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${user_ids}=  Create List  ${u_id3}
     ${resp}=   Assign Team To User  ${user_ids}  ${t_id2}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION_TO_ADD_USERS_TO_TEAM}"
    
JD-TC-AssignTeamToUser-UH2
     [Documentation]  Create team by user login with user type PROVIDER with admin privilage FALSE then try to assign team
     ${resp}=  Provider Login  ${HLMUSERNAME11}  ${PASSWORD}
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
     ${resp}=  ProviderLogin  ${PUSERNAME_U5}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${user_ids}=  Create List  ${u_id3}
     ${resp}=   Assign Team To User  ${user_ids}  ${t_id2}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION_TO_ADD_USERS_TO_TEAM}"

JD-TC-AssignTeamToUser-UH3
     [Documentation]  Assign a user to empty team 
     ${resp}=  Provider Login  ${HLMUSERNAME11}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${user_ids}=  Create List  ${u_id3}
     ${resp}=   Assign Team To User  ${user_ids}  
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings   ${resp.json()}   ${TEAM_NOT_FOUND}

JD-TC-AssignTeamToUser-UH4
     [Documentation]  Assign empty users to a team
     ${resp}=  Provider Login  ${HLMUSERNAME11}  ${PASSWORD}
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
     ${resp}=  Provider Login  ${HLMUSERNAME11}  ${PASSWORD}
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
    












***comment***
JD-TC-AssignTeamToUser-UH8
     [Documentation]  Assign a same user to same team multiple times
     ${resp}=  Provider Login  ${HLMUSERNAME11}  ${PASSWORD}
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
    
    


















