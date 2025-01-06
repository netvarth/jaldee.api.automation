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
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

***Test Cases***


JD-TC-AssignBussinessLocationsToUser-1

    [Documentation]  Assign bussiness locations to users multiple users have same multiple locations 

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}

    clear_customer   ${HLPUSERNAME17}

    IF  ${decrypted_data['enableRbac']}==${bool[1]}
        ${resp1}=  Enable Disable CDL RBAC  ${toggle[1]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${lid1}=   Create Sample Location
    Set Suite Variable    ${lid1} 
    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz1}  ${resp.json()['timezone']}

    ${lid2}=   Create Sample Location
    Set Suite Variable    ${lid2} 
    ${resp}=   Get Location ById  ${lid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz2}  ${resp.json()['timezone']} 

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END
 
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
    
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${countryCodes[0]}  ${PUSERNAME_U1}   ${userType[0]}    deptId=${dep_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+701198
    clear_users  ${PUSERNAME_U2}
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${address2}=  get_address
    ${dob2}=  FakerLibrary.Date
   
    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${countryCodes[0]}  ${PUSERNAME_U2}   ${userType[0]}    deptId=${dep_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id2}  ${resp.json()}

    ${userIds}=  Create List  ${u_id1}  ${u_id2}
    ${resp}=   Assign Business_loc To User  ${userIds}  ${lid1}  ${lid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${bussLocations}=  Create List  ${lid1}  ${lid2}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-AssignBussinessLocationsToUser-2

    [Documentation]  Assign bussiness locations to user ,user also have team here same team members have different locations

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${lid0}=   Create Sample Location
    Set Suite Variable    ${lid0} 
    ${resp}=   Get Location ById  ${lid0}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz0}  ${resp.json()['timezone']}

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
   
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${countryCodes[0]}  ${PUSERNAME_U1}   ${userType[0]}    deptId=${dep_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id3}  ${resp.json()}

    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+701197
    clear_users  ${PUSERNAME_U2}
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${address2}=  get_address
    ${dob2}=  FakerLibrary.Date
    
    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${countryCodes[0]}  ${PUSERNAME_U2}   ${userType[0]}    deptId=${dep_id}
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
   
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${userIds}=  Create List   ${u_id3}
    ${resp}=   Assign Business_loc To User  ${userIds}  ${lid0}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${bussLocations1}=  Create List  ${lid0} 
  
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
JD-TC-AssignBussinessLocationsToUser-3

    [Documentation]  Assign bussiness locations to user one user have multiple location(account level)

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+701181
    clear_users  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob1}=  FakerLibrary.Date
  
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${countryCodes[0]}  ${PUSERNAME_U1}   ${userType[0]}    deptId=${dep_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id3}  ${resp.json()}

    ${userIds}=  Create List  ${u_id3} 
    ${resp}=   Assign Business_loc To User  ${userIds}  ${lid1}  ${lid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${bussLocations}=  Create List  ${lid1}  ${lid2}
 
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
JD-TC-AssignBussinessLocationsToUser-4

    [Documentation]  Assign bussiness locations to assistant users multiple locations (account level)

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME17}  ${PASSWORD}
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
  
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${countryCodes[0]}  ${PUSERNAME_U1}   ${userType[0]}    deptId=${dep_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id}  ${resp.json()}

    ${userIds}=  Create List  ${u_id}  
    ${resp}=   Assign Business_loc To User  ${userIds}  ${lid1}  ${lid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
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
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['bussLocations']}                   ${bussLocations}
    END
    
JD-TC-AssignBussinessLocationsToUser-5

    [Documentation]  Assign bussiness locations to users by user login

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PUSERNAME_U1}  ${u_id} =  Create and Configure Sample User    deptId=${dep_id}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${userIds}=  Create List  ${u_id}  
    ${resp}=   Assign Business_loc To User  ${userIds}  ${lid1}  ${lid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${NO_PERMISSION_TO_ADD_LOCATION}
   
JD-TC-AssignBussinessLocationsToUser-UH1

    [Documentation]  Assign bussiness disabled locations to users (account level)

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${lid3}=   Create Sample Location
    Set Suite Variable    ${lid3} 

    ${resp}=   Get Location ById  ${lid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz3}  ${resp.json()['timezone']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${u_id3} =  Create Sample User    deptId=${dep_id}
    ${u_id4} =  Create Sample User    deptId=${dep_id}

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

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    #............provider consumer creation..........
    
    clear_customer   ${HLPUSERNAME17}

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

    ${userIds}=  Create List  ${u_id1}  ${u_id2}
    ${resp}=   Assign Business_loc To User  ${userIds}  ${lid1}  ${lid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.content}  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-AssignBussinessLocationsToUser-UH4

    [Documentation]  Assign bussiness locations to users by user login location created in user level

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PUSERNAME_U1}  ${u_id} =  Create and Configure Sample User    deptId=${dep_id}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
   
    ${resp}=  Create Location   ${city}  ${longi}  ${latti}  ${postcode}  ${address}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${NOT_PERMITTED_TO_CREATE_LOCATION}"

JD-TC-AssignBussinessLocationsToUser-UH5

    [Documentation]  Assign another provider bussiness locations to users 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME75}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${lid7}=   Create Sample Location
    Set Suite Variable    ${lid7} 
   
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${u_id1} =  Create Sample User    deptId=${dep_id}
    ${u_id2} =  Create Sample User    deptId=${dep_id}

    ${userIds}=  Create List  ${u_id1}  ${u_id2}
    ${resp}=   Assign Business_loc To User  ${userIds}  ${lid7}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${LOCATION_NOT_FOUND}"

JD-TC-AssignBussinessLocationsToUser-UH6

    [Documentation]  Assign bussiness locations to epmty users list 

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    ${u_id} =  Create Sample User    deptId=${dep_id}
   
    ${userIds}=  Create List  
    ${resp}=   Assign Business_loc To User  ${userIds}  ${lid2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${bussLocations}=  Create List  ${lid2}
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
JD-TC-AssignBussinessLocationsToUser-UH7

    [Documentation]  Assign bussiness locations to disabled user

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${u_id} =  Create Sample User    deptId=${dep_id}
   
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
    Should Be Equal As Strings  "${resp.json()}"  "Cannot assign business location to a INACTIVE user"
    





















*** Comments ***
JD-TC-AssignBussinessLocationsToUser-UH8
    [Documentation]  Assign bussiness locations to mutiple times to same user

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME17}  ${PASSWORD}
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
    

   