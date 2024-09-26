*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        RBAC
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot

*** Variables ***

${SERVICE1}     SERVICE1
${SERVICE2}     SERVICE2
${SERVICE3}     SERVICE3
${SERVICE4}     SERVICE4
${SERVICE5}     SERVICE5
${SERVICE6}     SERVICE6
@{service_duration}  10  20  30   40   50

@{emptylist}

*** Test Cases ***

JD-TC-CreateBooking_Waitlist-1

    [Documentation]   Create Booking Waitlist

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable   ${lic_id}   ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableRbac']}==${bool[0]}
        ${resp1}=  Enable Disable Main RBAC  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    IF  ${resp.json()['bookingRbac']}==${bool[0]}
        ${resp1}=  Enable Disable Booking RBAC  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['bookingRbac']}  ${bool[1]}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Capabilities By Feature       ${rbac_feature[3]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${role_id1}    ${resp.json()[0]['id']}
    Set Suite Variable  ${role_name1}  ${resp.json()[0]['roleName']}
    Set Suite Variable  ${capabilityList1}  ${resp.json()[0]['capabilityList']}
    
    ${resp}=  Get Capabilities By Feature       ${rbac_feature[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Capa_id1}    ${resp.json()[0]['id']}
    Set Suite Variable  ${Capa_name1}  ${resp.json()[0]['displayName']}
    Set Suite Variable  ${Capa_id2}    ${resp.json()[1]['id']}
    Set Suite Variable  ${Capa_name2}  ${resp.json()[1]['displayName']}
    Set Suite Variable  ${Capa_id3}    ${resp.json()[2]['id']}
    Set Suite Variable  ${Capa_name3}  ${resp.json()[2]['displayName']}
    Set Suite Variable  ${Capa_id4}    ${resp.json()[3]['id']}
    Set Suite Variable  ${Capa_name4}  ${resp.json()[3]['displayName']}
    Set Suite Variable  ${Capa_id5}    ${resp.json()[4]['id']}
    Set Suite Variable  ${Capa_name5}  ${resp.json()[4]['displayName']}
    Set Suite Variable  ${Capa_id6}    ${resp.json()[5]['id']}
    Set Suite Variable  ${Capa_name6}  ${resp.json()[5]['displayName']}
    Set Suite Variable  ${Capa_id7}    ${resp.json()[6]['id']}
    Set Suite Variable  ${Capa_name7}  ${resp.json()[6]['displayName']}
    Set Suite Variable  ${Capa_id21}    ${resp.json()[21]['id']}
    Set Suite Variable  ${Capa_name21}  ${resp.json()[21]['displayName']}
    Set Suite Variable  ${Capa_id24}    ${resp.json()[24]['id']}
    Set Suite Variable  ${Capa_name24}  ${resp.json()[24]['displayName']}

    ${description}=    Fakerlibrary.Sentence    
    ${New_role_name1}=    Fakerlibrary.Sentence    
    ${Capabilities}=    Create List    ${Capa_id1}   ${Capa_id24}  ${Capa_id21}
    
    ${resp}=  Create Role      ${New_role_name1}    ${description}    ${rbac_feature[1]}    ${Capabilities}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${NewRole_id_1}  ${resp.json()}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    # ${resp}=  Get Waitlist Settings
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # IF  ${resp.json()['filterByDept']}==${bool[0]}
    #     ${resp}=  Toggle Department Enable
    #     Log  ${resp.json()}
    #     Should Be Equal As Strings  ${resp.status_code}  200

    # END

    # ${resp}=  Get Departments
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # IF   '${resp.content}' == '${emptylist}'
    #     ${dep_name1}=  FakerLibrary.bs
    #     ${dep_code1}=   Random Int  min=100   max=999
    #     ${dep_desc1}=   FakerLibrary.word  
    #     ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    #     Log  ${resp1.content}
    #     Should Be Equal As Strings  ${resp1.status_code}  200
    #     Set Suite Variable  ${dep_id}  ${resp1.json()}
    # ELSE
    #     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    # END

    # ${resp}=  Get User
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # IF   not '${resp.content}' == '${emptylist}'
    #     ${len}=  Get Length  ${resp.json()}
    #     FOR   ${i}  IN RANGE   0   ${len}
    #         Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
    #         IF   not '${user_phone}' == '${HLPUSERNAME1}'
    #             clear_users  ${user_phone}
    #         END
    #     END
    # END


    # FOR    ${i}    IN RANGE    3
    #     ${pin}=  get_pincode
    #     ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
    #     IF    '${kwstatus}' == 'FAIL'
    #             Continue For Loop
    #     ELSE IF    '${kwstatus}' == 'PASS'
    #             Exit For Loop
    #     END
    # END

    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200 
    # Set Suite Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    # Set Suite Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    # Set Suite Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}  

    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+300145
    clear_users  ${PUSERNAME_U1}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${role1}=  Create Dictionary   id=${NewRole_id_1}  roleName=${New_role_name1}  feature=${rbac_feature[1]}
    ${user_roles}=  Create List   ${role1}

    # ${whpnum}=  Evaluate  ${PUSERNAME}+336245
    # ${tlgnum}=  Evaluate  ${PUSERNAME}+336345

    ${resp}=  Create User  ${firstname}  ${lastname}  ${countryCodes[1]}  ${PUSERNAME_U1}    ${userType[0]}    bookingRoles=${user_roles}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${u_id}=  Create Sample User 
    Set suite Variable                    ${u_id}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${role1}=  Create Dictionary   id=${NewRole_id_1}  roleName=${New_role_name1}  defaultRole=${bool[0]}
    # ...      capabilities=${Capabilities}
    # ${user_roles}=  Create List   ${role1}

    # ${user_ids}=  Create List   ${u_id1}  

    # ${resp}=  Append User Scope  ${rbac_feature[1]}  ${user_ids}  ${user_roles} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${NewRole_id_1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${New_role_name1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${Capabilities}
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${NewRole_id_1}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${New_role_name1}

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}

    # clear_location   ${HLPUSERNAME1}

    # ${resp}=    Provider Logout
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}
	${list1}=  Create List  1  2  3  4
    Set Suite Variable  ${list1}
    ${latti2}  ${longi2}  ${postcode2}  ${city2}  ${district}  ${state}  ${address2}=  get_loc_details
    ${tz2}=   db.get_Timezone_by_lat_long   ${latti2}  ${longi2}
    Set Suite Variable  ${tz2}
    ${parking_type2}    Random Element     ['none','free','street','privatelot','valet','paid']
    Set Suite Variable  ${parking_type2}
    ${24hours2}    Random Element    ['True','False']
    Set Suite Variable   ${24hours2}
    ${sTime2}=  add_timezone_time  ${tz}  2  15  
    Set Suite Variable  ${sTime2}
    ${eTime2}=  add_timezone_time  ${tz}  2  45  
    Set Suite Variable  ${eTime2}
    ${resp}=  Create Location  ${city2}  ${longi2}  ${latti2}  www.${city2}.com  ${postcode2}  ${address2}  ${parking_type2}  ${24hours2}  Weekly  ${list1}  ${DAY}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()}

    # ${resp}=   Get Location ById  ${lid}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1

    # ${resp}=  Create Service  ${SERVICE1}  ${description}   {service_duration[1]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre}  department=${dep_id}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${s_id}  ${resp.json()}

    ${sTime1}=  add_timezone_time  ${tz}  2  15  
    Set Suite Variable  ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  2  45  
    Set Suite Variable  ${eTime1}
    ${queue_name1}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name1}

    # ${resp}=  Create Queue  ${queue_name1}  Weekly  ${list1}  ${DAY}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  1  ${lid}  ${s_id}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${q_id}  ${resp.json()}
# ---------------------------------- create provider consumer ------------------------------------------
    ${PH_Number}    Random Number          digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable    ${primaryMobileNo}  555${PH_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/proconnum.txt  ${SUITE NAME} - ${TEST NAME} - ${primaryMobileNo}${\n}
    ${firstName}=   FakerLibrary.first_name
    ${lastName}=    FakerLibrary.last_name
    Set Suite Variable      ${firstName}
    Set Suite Variable      ${lastName}  
    ${dob}=    FakerLibrary.Date
    ${permanentAddress1}=  FakerLibrary.address
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${email}  ${C_Email}${primaryMobileNo}${firstName}.${test_mail}

    ${resp}=  AddCustomer  ${primaryMobileNo}  firstName=${firstName}   lastName=${lastName}  address=${permanentAddress1}   gender=${gender}  dob=${dob}  email=${email}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ageyrs}  ${agemonths}=  db.calculate_age_years_months     ${dob}

    ${resp}=  GetCustomer  phoneNo-eq=${primaryMobileNo}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${consumerId}  ${resp.json()[0]['id']}
    ${fullastName}   Set Variable    ${firstName} ${lastName}
    Set Test Variable  ${fullastName}

    ${resp}=  Provider Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token    ${primaryMobileNo}    ${account_id1}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}            ${resp.json()['providerConsumer']}
# ---------------------------------------------------------------------------------------------
    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Reset LoginId  ${u_id1}  ${PUSERNAME_U1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUSERNAME_U1}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUSERNAME_U1}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUSERNAME_U1}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # #... linking user to the provider 1 and get linked lists



    # ${resp}=    Connect with other login  ${PUSERNAME_U1}  password=${PASSWORD}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    202

    # ${resp}=    Account Activation      ${PUSERNAME_U1}  ${OtpPurpose['LinkLogin']}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${key2} =   db.Verify Accnt   ${PUSERNAME_U1}    ${OtpPurpose['LinkLogin']}
    # Set Suite Variable   ${key2}

    # ${resp}=    Connect with other login  ${PUSERNAME_U1}   otp=${key2}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=    Provider Logout
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login     ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}   200

    # ${resp}=  Get User By Id  ${u_id1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${desc}=   FakerLibrary.word
    # ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${wid}=  Get Dictionary Values  ${resp.json()}
    # Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Create Service  ${SERVICE1}  ${description}   {service_duration[1]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}
    

    ${resp}=  Create Queue  ${queue_name1}  Weekly  ${list1}  ${DAY}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  1  ${lid}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

