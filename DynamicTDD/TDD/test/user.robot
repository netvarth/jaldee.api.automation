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

*** Variables ***
${zero}        0
@{emptylist}
${var_file}     ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py
${data_file}    ${EXECDIR}/data/${ENVIRONMENT}data/${ENVIRONMENT}phnumbers.txt



***Test Cases***
JD-TC-AssignBussinessLocationsToUser-1

    [Documentation]  Assign bussiness locations to users multiple users have same multiple locations 

    Log Many  ${var_file}  ${data_file}
    ${cust_pro}=  Evaluate  random.choice(list(open($var_file)))  random
    Log  ${cust_pro}
    ${cust_pro}=   Set Variable  ${cust_pro.strip()}
    ${variable} 	${number}=   Split String    ${cust_pro}  =  
    Set Test Variable  ${number}
    
    ${resp}=  Encrypted Provider Login  ${number}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    

    # IF  ${decrypted_data['enableRbac']}==${bool[1]}
    #     ${resp1}=  Enable Disable CDL RBAC  ${toggle[1]}
    #     Log  ${resp1.content}
    #     Should Be Equal As Strings  ${resp1.status_code}  200
    # END

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

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
            ${dep_name1}=  FakerLibrary.bs
            ${dep_code1}=   Random Int  min=100   max=999
            ${dep_desc1}=   FakerLibrary.word  
            ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
            Set Suite Variable  ${dep_id}  ${resp1.json()}
    ELSE
            Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    # ${BSH}=  Create Sample User 
    # Set Suite Variable                    ${BSH}
    
    # ${resp}=  Get User By Id              ${BSH}
    # Log   ${resp.json()}
    # Should Be Equal As Strings            ${resp.status_code}  200
    # Set Suite Variable  ${BSH_USERNAME}   ${resp.json()['mobileNo']}

# *** COMMENTS ***

    ${PH_Number}    FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PUSERNAME_U1}  555${PH_Number}
    # ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+701199
    # clear_users  ${PUSERNAME_U1}
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

    ${PH_Number}    FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PUSERNAME_U2}  555${PH_Number}
    # ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+701198
    # clear_users  ${PUSERNAME_U2}
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