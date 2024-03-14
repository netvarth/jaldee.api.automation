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
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

***Test Cases***


JD-TC-AssignBussinessLocationsToUser-1

    [Documentation]  Assign bussiness locations to users multiple users have same multiple locations 

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_queue      ${HLMUSERNAME17}
    clear_location   ${HLMUSERNAME17}
    clear_service    ${HLMUSERNAME17}
    clear_customer   ${HLMUSERNAME17}

    IF  ${resp.json()['enableRbac']}==${bool[1]}
        ${resp1}=  Enable Disable CDL RBAC  ${toggle[1]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${lid1}=   Create Sample Location
    Set Suite Variable    ${lid1} 
    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz1}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${lid2}=   Create Sample Location
    Set Suite Variable    ${lid2} 
    ${resp}=   Get Location ById  ${lid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz2}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${pincode1}  ${resp.json()[0]['pinCode']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
#     sleep  2s
#     ${resp}=  Get Departments
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()}

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+701199
    clear_users  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob1}=  FakerLibrary.Date
    # ${pin}=  get_pincode

    # ${resp}=  Get LocationsByPincode     ${pin}
    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${city1}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state1}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Suite Variable  ${pin1}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
    
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+701198
    clear_users  ${PUSERNAME_U2}
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${address2}=  get_address
    ${dob2}=  FakerLibrary.Date
    # ${pin}=  get_pincode

    # ${resp}=  Get LocationsByPincode     ${pin}
    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
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

    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id2}  ${resp.json()}

    ${userIds}=  Create List  ${u_id1}  ${u_id2}
    ${resp}=   Assign Business_loc To User  ${userIds}  ${lid1}  ${lid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${bussLocations}=  Create List  ${lid1}  ${lid2}

    sleep  02s
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    

    # Verify Response List  ${resp}  0  id=${u_id2}  firstName=${firstname2}  lastName=${lastname2}  mobileNo=${PUSERNAME_U2}  dob=${dob2}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U2}.${test_mail}   state=${state2}  pincode=${pin2}
    # ...    deptId=${dep_id}  subdomain=${sub_domain_id}   bussLocations=${bussLocations}   
    # Variable Should Exist   ${resp.content}  ${city2}
    # Verify Response List  ${resp}  1  id=${u_id1}  firstName=${firstname1}  lastName=${lastname1}  mobileNo=${PUSERNAME_U1}  dob=${dob1}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U1}.${test_mail}  city=${city1}  state=${state1}  pincode=${pin1}
    # ...    deptId=${dep_id}  subdomain=${sub_domain_id}   bussLocations=${bussLocations}   
    # Variable Should Exist   ${resp.content}  ${city1}
   
    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-AssignBussinessLocationsToUser-2

    [Documentation]  Assign bussiness locations to user ,user also have team here same team members have different locations
    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${lid0}=   Create Sample Location
    Set Suite Variable    ${lid0} 
    ${resp}=   Get Location ById  ${lid0}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz0}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${team_name2}=  FakerLibrary.name
    ${team_size2}=  Random Int  min=10  max=50
    ${desc2}=   FakerLibrary.sentence
    ${resp}=  Create Team For User  ${team_name2}  ${team_size2}  ${desc2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${t_id2}  ${resp.json()}

    ${team_name3}=  FakerLibrary.name
    ${desc3}=   FakerLibrary.sentence
    ${resp}=  Create Team For User  ${team_name3}  ${EMPTY}  ${desc3} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${t_id3}  ${resp.json()}

    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+701188
    clear_users  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob1}=  FakerLibrary.Date
    # ${pin}=  get_pincode

    # ${resp}=  Get LocationsByPincode     ${pin}
    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
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
    Set Suite Variable  ${pin3}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
    
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin3}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id3}  ${resp.json()}

    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+701197
    clear_users  ${PUSERNAME_U2}
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${address2}=  get_address
    ${dob2}=  FakerLibrary.Date
    
    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id4}  ${resp.json()}

    ${user_ids}=  Create List  ${u_id3}  ${u_id4}
    ${resp}=   Assign Team To User  ${user_ids}  ${t_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${userIds}=  Create List   ${u_id4}
    ${resp}=   Assign Business_loc To User  ${userIds}  ${lid1}  ${lid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${bussLocations}=  Create List  ${lid1}  ${lid2}
    ${team}=    Create List  ${t_id2}
    sleep  02s

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response List  ${resp}  0  id=${u_id4}  firstName=${firstname2}  lastName=${lastname2}  mobileNo=${PUSERNAME_U2}  dob=${dob2}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U2}.${test_mail}  city=${city1}  state=${state1}  pincode=${pin1}
    # ...    deptId=${dep_id}  subdomain=${sub_domain_id}  admin=${bool[0]}  bussLocations=${bussLocations}   teams=${team} 
   
    ${userIds}=  Create List   ${u_id3}
    ${resp}=   Assign Business_loc To User  ${userIds}  ${lid0}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${bussLocations1}=  Create List  ${lid0} 
    sleep  02s

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response List  ${resp}  0  id=${u_id4}  firstName=${firstname2}  lastName=${lastname2}  mobileNo=${PUSERNAME_U2}  dob=${dob2}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U2}.${test_mail}  city=${city1}  state=${state1}  pincode=${pin1}
    # ...    deptId=${dep_id}  subdomain=${sub_domain_id}  admin=${bool[0]}  bussLocations=${bussLocations}   teams=${team} 
    # Verify Response List  ${resp}  1  id=${u_id3}  firstName=${firstname1}  lastName=${lastname1}  mobileNo=${PUSERNAME_U1}  dob=${dob1}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U1}.${test_mail}  city=${city}  state=${state}  pincode=${pin3}
    # ...    deptId=${dep_id}  subdomain=${sub_domain_id}  admin=${bool[0]}  bussLocations=${bussLocations1}   teams=${team}


JD-TC-AssignBussinessLocationsToUser-3

    [Documentation]  Assign bussiness locations to user one user have multiple location(account level)
    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+701181
    clear_users  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob1}=  FakerLibrary.Date
    # ${pin}=  get_pincode

    # ${resp}=  Get LocationsByPincode     ${pin}
    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
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
    
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id3}  ${resp.json()}

    ${userIds}=  Create List  ${u_id3} 
    ${resp}=   Assign Business_loc To User  ${userIds}  ${lid1}  ${lid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${bussLocations}=  Create List  ${lid1}  ${lid2}
    sleep  02s

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response List  ${resp}  0  id=${u_id3}  firstName=${firstname1}  lastName=${lastname1}  mobileNo=${PUSERNAME_U1}  dob=${dob1}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U1}.${test_mail}  city=${city}  state=${state}  pincode=${pin}
    # ...    deptId=${dep_id}  subdomain=${sub_domain_id}  admin=${bool[0]}  bussLocations=${bussLocations}   

  
JD-TC-AssignBussinessLocationsToUser-4
    [Documentation]  Assign bussiness locations to assistant users multiple locations (account level)

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+701250
    clear_users  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob1}=  FakerLibrary.Date
    # ${pin}=  get_pincode

    # ${resp}=  Get LocationsByPincode     ${pin}
    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${city1}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state1}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Suite Variable  ${pin1}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
    
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[1]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id}  ${resp.json()}

    ${userIds}=  Create List  ${u_id}  
    ${resp}=   Assign Business_loc To User  ${userIds}  ${lid1}  ${lid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s

    ${bussLocations}=  Create List  ${lid1}  ${lid2}
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        Run Keyword IF  '${resp.json()[${i}]['id']}' == '${u_id}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['firstName']}                       ${firstname1}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['lastName']}                        ${lastname1} 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['mobileNo']}                        ${PUSERNAME_U1}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['dob']}                             ${dob1}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['gender']}                          ${Genderlist[0]}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['userType']}                        ${userType[1]}     
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['status']}                          ACTIVE    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['email']}                           ${P_Email}${PUSERNAME_U1}.${test_mail}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['deptId']}                          0     
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['subdomain']}                       0
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['admin']}                           ${bool[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['pincode']}                         ${pin1} 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['bussLocations']}                   ${bussLocations}
    END
    
JD-TC-AssignBussinessLocationsToUser-5
    [Documentation]  Assign bussiness locations to users by user login

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+701113
    clear_users  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob1}=  FakerLibrary.Date
    # ${pin}=  get_pincode

    # ${resp}=  Get LocationsByPincode     ${pin}
    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${city1}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state1}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Suite Variable  ${pin1}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
    
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id}  ${resp.json()}

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${userIds}=  Create List  ${u_id}  
    ${resp}=   Assign Business_loc To User  ${userIds}  ${lid1}  ${lid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${NO_PERMISSION_TO_ADD_LOCATION}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${bussLocations}=  Create List  ${lid1}  ${lid2}
    # ${resp}=  Get User
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response List  ${resp}  0  id=${u_id}  firstName=${firstname1}  lastName=${lastname1}  mobileNo=${PUSERNAME_U1}  dob=${dob1}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U1}.${test_mail}  city=${city1}  state=${state1}  pincode=${pin1}
    # ...    deptId=${dep_id}  subdomain=${sub_domain_id}  admin=${bool[0]}  bussLocations=${bussLocations}   

   
JD-TC-AssignBussinessLocationsToUser-UH1
    [Documentation]  Assign bussiness disabled locations to users (account level)

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${lid3}=   Create Sample Location
    Set Suite Variable    ${lid3} 

    ${resp}=   Get Location ById  ${lid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz3}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+701185
    clear_users  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob1}=  FakerLibrary.Date
    # ${pin}=  get_pincode

    # ${resp}=  Get LocationsByPincode     ${pin}
    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${city1}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state1}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Suite Variable  ${pin1}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
    
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id3}  ${resp.json()}

    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+701189
    clear_users  ${PUSERNAME_U2}
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${address2}=  get_address
    ${dob2}=  FakerLibrary.Date
    # ${pin}=  get_pincode

    # ${resp}=  Get LocationsByPincode     ${pin}
    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
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

    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id4}  ${resp.json()}

    ${resp}=   Disable Location  ${lid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${userIds}=  Create List  ${u_id3}  ${u_id4}
    ${resp}=   Assign Business_loc To User  ${userIds}  ${lid1}  ${lid2}  ${lid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${CANNOT_ASSIGN_DISABLED_LOCATION}"


JD-TC-AssignBussinessLocationsToUser-UH2

    [Documentation]  Assign bussiness locations to user without login

    ${userIds}=  Create List  ${u_id1}  ${u_id2}
    ${resp}=   Assign Business_loc To User  ${userIds}  ${lid1}  ${lid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.content}  "${SESSION_EXPIRED}"


JD-TC-AssignBussinessLocationsToUser-UH3

    [Documentation]  Assign bussiness locations to user with consumer login

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${userIds}=  Create List  ${u_id1}  ${u_id2}
    ${resp}=   Assign Business_loc To User  ${userIds}  ${lid1}  ${lid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.content}  "${LOGIN_NO_ACCESS_FOR_URL}"


JD-TC-AssignBussinessLocationsToUser-UH4
    [Documentation]  Assign bussiness locations to users by user login location created in user level

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+701115
    clear_users  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob1}=  FakerLibrary.Date
    # ${pin}=  get_pincode

    # ${resp}=  Get LocationsByPincode     ${pin}
    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${city1}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state1}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Suite Variable  ${pin1}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
    
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id}  ${resp.json()}

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${lid4}=   Create Sample Location
    ${DAY}=  db.get_date_by_timezone  ${tz}   
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  0  30  
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${NOT_PERMITTED_TO_CREATE_LOCATION}"

    # ${userIds}=  Create List  ${u_id}  
    # ${resp}=   Assign Business_loc To User  ${userIds}  ${lid4}  
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${bussLocations}=  Create List  ${lid4}
    # ${resp}=  Get User
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response List  ${resp}  0  id=${u_id}  firstName=${firstname1}  lastName=${lastname1}  mobileNo=${PUSERNAME_U1}  dob=${dob1}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U1}.${test_mail}  city=${city1}  state=${state1}  pincode=${pin1}
    # ...    deptId=${dep_id}  subdomain=${sub_domain_id}  admin=${bool[0]}  bussLocations=${bussLocations}   teams=[] 

    # ${resp}=  Get User By Id  ${u_id}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-AssignBussinessLocationsToUser-UH5
    [Documentation]  Assign another provider bussiness locations to users 

    ${resp}=  Encrypted Provider Login  ${MUSERNAME75}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${lid7}=   Create Sample Location
    Set Suite Variable    ${lid7} 
   
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+701117
    clear_users  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob1}=  FakerLibrary.Date
    # ${pin}=  get_pincode

    # ${resp}=  Get LocationsByPincode     ${pin}
    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${city1}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state1}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Suite Variable  ${pin1}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
    
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+701118
    clear_users  ${PUSERNAME_U2}
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${address2}=  get_address
    ${dob2}=  FakerLibrary.Date
    # ${pin}=  get_pincode

    # ${resp}=  Get LocationsByPincode     ${pin}
    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
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

    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id2}  ${resp.json()}

    ${userIds}=  Create List  ${u_id1}  ${u_id2}
    ${resp}=   Assign Business_loc To User  ${userIds}  ${lid7}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${LOCATION_NOT_FOUND}"

   
JD-TC-AssignBussinessLocationsToUser-UH6
    [Documentation]  Assign bussiness locations to epmty users list 

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+701116
    clear_users  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob1}=  FakerLibrary.Date
    # ${pin}=  get_pincode

    # ${resp}=  Get LocationsByPincode     ${pin}
    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${city1}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state1}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Suite Variable  ${pin1}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
    
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id}  ${resp.json()}

    # ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    # Should Be Equal As Strings  ${resp[0].status_code}  200
    # Should Be Equal As Strings  ${resp[1].status_code}  200
    # ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${userIds}=  Create List  
    ${resp}=   Assign Business_loc To User  ${userIds}  ${lid2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${bussLocations}=  Create List  ${lid2}
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response List  ${resp}  0  id=${u_id}  firstName=${firstname1}  lastName=${lastname1}  mobileNo=${PUSERNAME_U1}  dob=${dob1}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME_U1}.${test_mail}  city=${city1}  state=${state1}  pincode=${pin1}
    # ...    deptId=${dep_id}  subdomain=${sub_domain_id}  admin=${bool[0]}  
    
JD-TC-AssignBussinessLocationsToUser-UH7
    [Documentation]  Assign bussiness locations to disabled user

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+701143
    clear_users  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob1}=  FakerLibrary.Date
    # ${pin}=  get_pincode

    # ${resp}=  Get LocationsByPincode     ${pin}
    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${city1}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state1}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Suite Variable  ${pin1}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
    
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id}  ${resp.json()}

    ${resp}=  EnableDisable User  ${u_id}  ${toggle[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id}   status=INACTIVE 

    ${userIds}=  Create List   ${u_id}
    ${resp}=   Assign Business_loc To User  ${userIds}  ${lid2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"  "${DISABLED_USER_CANT_ADD_TOTEAM}"
    





















*** Comments ***
JD-TC-AssignBussinessLocationsToUser-UH8
    [Documentation]  Assign bussiness locations to mutiple times to same user

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+701145
    clear_users  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob1}=  FakerLibrary.Date
    # ${pin}=  get_pincode

    # ${resp}=  Get LocationsByPincode     ${pin}
    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${city1}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state1}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Suite Variable  ${pin1}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
    
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id}  ${resp.json()}

    ${userIds}=  Create List   ${u_id}
    ${resp}=   Assign Business_loc To User  ${userIds}  ${lid2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Assign Business_loc To User  ${userIds}  ${lid2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"  "${DISABLED_USER_CANT_ADD_TOTEAM}"
    

   