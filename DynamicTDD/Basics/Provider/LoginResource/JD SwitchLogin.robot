*** Settings ***
Suite Teardown    Delete All Sessions
Force Tags        Encrypted Provider Login
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ApiKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

${DisplayName1}   item1_DisplayName
${pdffile}      /ebs/TDD/sample.pdf
${jpgfile}     /ebs/TDD/small.jpg

${order}    0
${fileSize}  0.00458
@{service_names}

*** Test Cases ***

JD-TC-Switch_Login-1

    [Documentation]    Switch login - Provider 1 switch to provider 2

    # ${domresp}=  Get BusinessDomainsConf
    # Log  ${domresp.content}
    # Should Be Equal As Strings  ${domresp.status_code}  200
    # ${len}=  Get Length  ${domresp.json()}
    # ${domain_list}=  Create List
    # ${subdomain_list}=  Create List
    # FOR  ${domindex}  IN RANGE  ${len}
    #     Set Test Variable  ${d}  ${domresp.json()[${domindex}]['domain']}    
    #     Append To List  ${domain_list}    ${d} 
    #     Set Test Variable  ${sd}  ${domresp.json()[${domindex}]['subDomains'][0]['subDomain']}
    #     Append To List  ${subdomain_list}    ${sd} 
    # END
    # Log  ${domain_list}
    # Log  ${subdomain_list}
    # Set Suite Variable  ${domain_list}
    # Set Suite Variable  ${subdomain_list}
    ${resp}=  Get BusinessDomainsConf
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${dom_len}=  Get Length  ${resp.json()}
    ${dom}=  Random Int  min=${0}   max=${dom_len-1}    
    Set Suite Variable  ${domain}  ${resp.json()[${dom}]['domain']}
    Log   ${domain}

    ${sdom_len}=  Get Length  ${resp.json()[${dom}]['subDomains']}
    ${sdom}=  Random Int  min=${0}  max=${sdom_len-1}
    Set Suite Variable  ${subdomain}  ${resp.json()[${dom}]['subDomains'][${sdom}]['subDomain']}
    Log   ${subdomain}

    # ........ Provider 1 ..........

    ${ph}=  Evaluate  ${PUSERNAME}+5666400
    Set Suite Variable  ${ph}
    ${firstname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable      ${firstname}
    Set Suite Variable      ${lastname}

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain}  ${subdomain}  ${ph}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId}=     Random Int  min=1111  max=9999
    Set Suite Variable      ${loginId}
    
    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable      ${pro_id}  ${decrypted_data['id']}
    Set Suite Variable      ${userName}  ${decrypted_data['userName']}
    
    ${resp}=  Get Provider Details    ${pro_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}          ${pro_id}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}      ${ph}



    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ........ Provider 2 ..........

    ${ph2}=  Evaluate  ${PUSERNAME}+5666400
    Set Suite Variable  ${ph2}
    ${firstname2}=  generate_firstname
    ${lastname2}=  FakerLibrary.last_name
    Set Suite Variable      ${firstname2}
    Set Suite Variable      ${lastname2}

    ${resp}=  Account SignUp  ${firstname2}  ${lastname2}  ${None}  ${domain}  ${subdomain}  ${ph2}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph2}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId2}=     Random Int  min=1111  max=9999
    Set Suite Variable      ${loginId2}
    
    ${resp}=  Account Set Credential  ${ph2}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable      ${pro_id2}  ${decrypted_data['id']}
    Set Suite Variable      ${pdrname2}  ${decrypted_data['userName']}
    Set Suite Variable    ${pdrfname2}  ${decrypted_data['firstName']}
    Set Suite Variable    ${pdrlname2}  ${decrypted_data['lastName']}
    
    ${resp}=  Get Provider Details    ${pro_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}          ${pro_id2}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}      ${ph2}

    Set Test Variable  ${email_id}  ${P_Email}${ph2}.${test_mail}

    ${resp}=  Update Email   ${pro_id2}   ${firstname2}   ${lastname2}   ${email_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${name3}=  FakerLibrary.word
    ${emails1}=  Emails  ${name3}  Email  ${email_id}  ${views}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Test Variable  ${tz}
    ${DAY1}=  db.get_date_by_timezone  ${tz}

    ${b_loc}=  Create Dictionary  place=${city}   longitude=${longi}   lattitude=${latti}    googleMapUrl=${url}   pinCode=${postcode}  address=${address}
    ${emails}=  Create List  ${emails1}
    ${resp}=  Update Business Profile with kwargs   businessName=${bs}   shortName=${bs}   businessDesc=Description baseLocation=${b_loc}   emails=${emails}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
    Log  ${fields.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec_len}=  Get Length  ${resp.json()}
    ${specs}=  random.choices  ${resp.json()}  k=2
    ${spec}=  Create List    ${specs[0]['displayName']}   ${specs[1]['displayName']}

    

    # ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    # Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable    ${spec1}     ${resp.json()[0]['displayName']}   
    # Set Test Variable    ${spec2}     ${resp.json()[1]['displayName']}   

    # ${spec}=  Create List    ${spec1}   ${spec2}

    # ${resp}=  Update Business Profile with kwargs  specialization=${spec}  
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Business Profile with kwargs  specialization=${spec}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get jaldeeIntegration Settings
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # IF  ${resp.json()['onlinePresence']}==${bool[0]}
    #     ${resp}=  Set jaldeeIntegration Settings    ${bool[1]}  ${EMPTY}  ${EMPTY}
    #     Log  ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200
    # END

    ${resp}=  Get Bill Settings 
    Log   ${resp.json}
    IF  ${resp.status_code}!=200
        Log   Status code is not 200: ${resp.status_code}
        ${resp}=  Enable Disable bill  ${bool[1]}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    ELSE IF  ${resp.json()['enablepos']}==${bool[0]}
        ${resp}=  Enable Disable bill  ${bool[1]}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Bill Settings 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['enablepos']}    ${bool[1]}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Connect with other login  ${loginId2}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation      ${ph2}  ${OtpPurpose['LinkLogin']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key2} =   db.Verify Accnt   ${ph2}    ${OtpPurpose['LinkLogin']}
    Set Suite Variable   ${key2}

    ${resp}=    Connect with other login  ${loginId2}   otp=${key2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Provider Details    ${pro_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}          ${pro_id2}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}      ${ph2}
    
JD-TC-Switch_Login-2

    [Documentation]    Switch login - provider 2 to provider 1

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Provider Details    ${pro_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}          ${pro_id}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}      ${ph}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Switch_Login-3

    [Documentation]    Switch login - swtch to the same login

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings      ${resp.json()}          ${CANT_SWITCH}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Switch_Login-4

    [Documentation]    Switch login - provider 1 switch to provider 2 twice

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings      ${resp.json()}          ${CANT_SWITCH}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Switch_Login-UH1

    [Documentation]    Switch login - where login id is invalid

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     Random Int  min=1111  max=9999

    ${resp}=    Switch login    ${inv}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings      ${resp.json()}          ${INV_LOGIN_ID}  ignore_case=True

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Switch_Login-UH2

    [Documentation]    Switch login - without login

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     419
    Should Be Equal As Strings      ${resp.json()}          ${SESSION_EXPIRED}

JD-TC-Switch_Login-UH3

    [Documentation]    Switch login - provider 2 linking provider 3 and provider 1 try to switch provider 3

    # ........ Provider 3 ..........

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${ph3}=  Evaluate  ${PUSERNAME}+5667632
    Set Suite Variable  ${ph3}
    ${firstname3}=  generate_firstname
    ${lastname3}=  FakerLibrary.last_name
    Set Suite Variable      ${firstname3}
    Set Suite Variable      ${lastname3}

    ${resp}=  Account SignUp  ${firstname3}  ${lastname3}  ${None}  ${domain}  ${subdomain}  ${ph3}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph3}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId3}=     Random Int  min=1111  max=9999
    Set Suite Variable      ${loginId3}
    
    ${resp}=  Account Set Credential  ${ph3}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${loginId3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable      ${pro_id3}  ${decrypted_data['id']}
    
    ${resp}=  Get Provider Details    ${pro_id3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}          ${pro_id3}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}      ${ph3}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Connect with other login  ${loginId3}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation      ${ph3}  ${OtpPurpose['LinkLogin']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key2} =   db.Verify Accnt   ${ph3}    ${OtpPurpose['LinkLogin']}
    Set Suite Variable   ${key2}

    ${resp}=    Connect with other login  ${loginId2}   otp=${key2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings      ${resp.json()}          ${CANT_SWITCH}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Switch_Login-UH4

    [Documentation]    Switch login - provider 3 switch to provider 1

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings      ${resp.json()}          ${CANT_SWITCH}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Switch_Login-5

    [Documentation]    Switch login - provider 1 switch to provider 2 and provider 2 switch to provider 3

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Provider Details    ${pro_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}          ${pro_id2}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}      ${ph2}

    ${resp}=    Switch login    ${loginId3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Provider Details    ${pro_id3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}          ${pro_id3}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}      ${ph3}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Switch_Login-UH6

    [Documentation]    Switch login - provider one switch to an existing provider who is not linked with provider 1

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${PUSERNAME1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings      ${resp.json()}          ${CANT_SWITCH}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Switch_Login-6

    [Documentation]    Switch login - provider 1 creae a appointment schedule, provider 2 login and switch to provider 1 and get appmt

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
    END

    ${resp}=   Get Location By Id   ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz1}  ${resp.json()['timezone']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${sid3}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${sid3}

    ${DAY1}=  db.get_date_by_timezone  ${tz1}
    Set Suite Variable   ${DAY1}

    ${DAY2}=  db.add_timezone_date  ${tz1}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz1}  0  15  
    ${eTime1}=  add_timezone_time  ${tz1}  1  15  
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${duration}=  FakerLibrary.Random Int  min=2  max=10
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${sid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id3}  ${resp.json()}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id3}  ${DAY1}  ${sid3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Switch_Login-7

    [Documentation]    Switch login - user creation and updation by switching

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Waitlist Settings
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # IF  ${resp.json()['filterByDept']}==${bool[0]}
    #     ${resp}=  Enable Disable Department  ${toggle[0]}
    #     Log  ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200

    # END

    #  sleep  2s
    #  ${resp}=  Get Departments
    #  Log  ${resp.content}
    #  Should Be Equal As Strings  ${resp.status_code}  200
    #  Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}
     

    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${city3}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state3}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin3}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
    
    ${firstname3}=  FakerLibrary.name
    ${lastname3}=  FakerLibrary.last_name
    ${address3}=  get_address
    ${dob3}=  FakerLibrary.Date
    ${us1}=  Evaluate  ${PUSERNAME}+5665471
    Set Suite Variable  ${us1}

    ${resp}=  Create User  ${firstname3}  ${lastname3}   ${countryCodes[0]}  ${us1}  ${userType[0]}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['firstName']}     ${firstname3} 
    Should Be Equal As Strings  ${resp.json()['lastName']}      ${lastname3} 

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name

    # ${resp}=  Update User  ${u_id}  ${firstname1}  ${lastname1}  ${dob3}  ${Genderlist[0]}  ${P_Email}${loginId}.${test_mail}   ${userType[0]}  ${pin3}  ${countryCodes[0]}  ${us1}  ${dep_id}   ${sub_domain_id}  ${bool[0]}   ${NULL}  ${NULL}  ${NULL}  ${NULL}
    ${resp}=  Update User  ${u_id}    ${countryCodes[0]}  ${us1}    ${userType[0]}   firstName=${firstname1}  lastName=${lastname1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Switch_Login-8

    [Documentation]    Switch login - create location

    ${resp}=  Encrypted Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${addon_resp}=   Get Addons Metadata
    Log  ${addon_resp.content}
    Should Be Equal As Strings    ${addon_resp.status_code}   200
    # Set Test Variable  ${aId}  ${resp.json()[0]['addons'][0]['addonId']}
    Set Suite Variable    ${addon_id}      ${addon_resp.json()[6]['addons'][0]['addonId']}
	Set Suite Variable    ${addon_name}      ${addon_resp.json()[6]['addons'][0]['addonName']}

    # ${resp}=  Add addon  ${addon_id}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}
    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # IF   '${resp.content}' == '${emptylist}'
    #     ${loc_id1}=  Create Sample Location
    # ELSE
    #     Set Suite Variable  ${loc_id1}  ${resp.json()[0]['id']}
    # END

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Switch_Login-9

    [Documentation]    Switch login - create business profile

    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    Set Suite Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Suite Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    
    ${resp}=  Encrypted Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz1}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    
    ${bName}    generate_firstname
    ${bDesc}    FakerLibrary.Sentence
    ${shname}   FakerLibrary.Sentence
    ${phone1}   Evaluate  ${PUSERNAME}+874589

    ${resp}=  Create Business Profile without details  ${bName}  ${bDesc}   ${shname}   ${phone1}   ${empty}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['businessName']}  ${bName}
    Should Be Equal As Strings  ${resp.json()['businessDesc']}  ${bDesc}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Switch_Login-10

    [Documentation]    Switch login - create Holiday and delete holiday

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid2}=  Create Sample Location
    ELSE
        Set Suite Variable  ${lid2}  ${resp.json()[0]['id']}
    END

    ${resp}=   Get Location By Id   ${lid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz2}  ${resp.json()['timezone']}

    ${DAY1}=  db.get_date_by_timezone  ${tz2}
    ${DAY2}=  db.add_timezone_date  ${tz2}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz2}
    ${eTime1}=  add_timezone_time  ${tz2}  4  00  

    ${DAY}=  db.add_timezone_date  ${tz2}  3  
    # ${sTime1}=  db.get_time_by_timezone   ${tz2}
    ${sTime1}=  db.get_time_by_timezone  ${tz2}
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${desc}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId}    ${resp.json()['holidayId']}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Holiday By Id   ${holidayId}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY1}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${sTime1}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${eTime1}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Delete Holiday  ${holidayId}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Holiday By Account
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}  "id":"${holidayId}"

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Holiday By Account
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}  "id":"${holidayId}"

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Switch_Login-11

    [Documentation]    Switch login - Create Reminder

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${accountId}  ${resp.json()['id']}

    # ${accountId}=    get_acc_id       ${ph}
    # Set Suite Variable    ${accountId}

    ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Suite Variable    ${primaryMobileNo}
    ${email}=    FakerLibrary.Email
    Set Suite Variable    ${email}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    # ${resp}=    Consumer Logout 
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${primaryMobileNo}  ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${cid}            ${resp.json()['providerConsumer']}
    Set Suite Variable    ${jconid}         ${resp.json()['id']}

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz1}
    ${DAY2}=  db.add_timezone_date  ${tz1}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz2}
    ${sTime1}=  db.get_time_by_timezone  ${tz1}  
    ${eTime1}=  add_timezone_time  ${tz1}  3  15  
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${pro_id}  ${cid}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id}  ${resp.content}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200    

JD-TC-Switch_Login-12

    [Documentation]    Switch login - Create Coupon

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}
    Set Suite Variable  ${pid}  ${resp.json()['id']}
    Set Suite Variable  ${firstname}  ${resp.json()['firstName']}
    Set Suite Variable  ${lastname}  ${resp.json()['lastName']}

    

    # ${resp}=  Get Bill Settings 
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # IF  ${resp.json()['enablepos']}==${bool[0]}
    #     ${resp}=  Enable Disable bill  ${bool[1]}
    #     Log   ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200
    # END

    # ${resp}=  Get Bill Settings 
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['enablepos']}    ${bool[1]}

    # ${businessStatus}    Random Element   ${businessStatus}  
    # ${accounttype}  Random Element   ${accounttype} 
    # ${fname}=   FakerLibrary.name
    # ${panCardNumber}=  Generate_pan_number
    # ${bankAccountNumber}=  Generate_random_value  size=16  chars=string.digits
    # ${bankName}=  FakerLibrary.company
    # ${ifsc}=  Generate_ifsc_code
    # ${panname}=  FakerLibrary.name
    # ${city}=   get_place
    # ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${ph_no}   ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc}  ${pan_name}  ${fname}  ${city}  ${businessStatus}  ${accounttype}  
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200
    
    # ${resp}=  payuVerify  ${pid}
    # ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${ph_no}   ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc}  ${pan_name}  ${fname}  ${city}  ${businessStatus}  ${accounttype}   
    # Should Be Equal As Strings    ${resp.status_code}   200
    # ${resp}=  SetMerchantId  ${pid}  ${merchantid}

    # ${resp}=  Get Account Settings
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # IF  ${resp.json()['onlinePayment']}==${bool[0]}   
    #     ${resp}=   Enable Disable Online Payment   ${toggle[0]}
    #     Should Be Equal As Strings  ${resp.status_code}  200
    # END

    # ${resp}=  Get Account Settings
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${sid1}=  Create Sample Service  ${SERVICE1}
    
    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${sid2}=  Create Sample Service  ${SERVICE2}
    
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz2}  ${resp.json()['baseLocation']['timezone']}
    
    ${coupon}=    FakerLibrary.word
    Set Suite Variable   ${coupon}
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=3  right_digits=1
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz2}  0  15  
    ${eTime}=  add_timezone_time  ${tz2}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz2}
    ${EN_DAY}=  db.add_timezone_date  ${tz2}   10
    ${min_bill_amount}=   Random Int   min=100   max=1000
    ${max_disc_val}=   Random Int   min=100   max=500
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[0]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${sid1}   ${sid2}
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[1]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${coupon_id1}  ${resp.json()}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Coupon By Id  ${coupon_id1} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Switch_Login-13

    [Documentation]    Switch login - Create User Token 

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   ${resp.json()['isApiGateway']}==${bool[0]}
        ${resp}=   Enable Disable API gateway   ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['isApiGateway']}  ${bool[1]}

    ${resp}=  Get SP Token
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apiGateway']}   ${toggle[0]}
    Set Suite Variable    ${sp_token}   ${resp.json()['spToken']} 

    ${resp}=   Create User Token   ${loginId}  ${PASSWORD}   ${sp_token}   ${countryCodes[0]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Switch_Login-14

    [Documentation]    Switch login - Create Invoice 

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${accountId}  ${resp.json()['id']}

    ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Suite Variable    ${primaryMobileNo}
    ${email}=    FakerLibrary.Email
    Set Suite Variable    ${email}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    # ${resp}=    Consumer Logout 
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${primaryMobileNo}  ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${cid}            ${resp.json()['providerConsumer']}
    Set Suite Variable    ${jconid2}         ${resp.json()['id']}

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id2}  ${resp.json()['id']}

    ${resp}=  Get jp finance settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid2}   ${resp.json()[0]['id']}

    ${name}=   FakerLibrary.word
    Set Suite Variable   ${name}

    ${resp}=  CreateVendorCategory  ${name}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id}   ${resp.json()}

    ${resp}=  Get by encId  ${category_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}          ${name}
    Should Be Equal As Strings  ${resp.json()['status']}        ${toggle[0]}
    
    ${name}=   FakerLibrary.word
    ${resp}=  Create Category   ${name}  ${categoryType[1]} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id1}   ${resp.json()}

    ${name1}=   FakerLibrary.word
    Set Suite Variable   ${name1}
    ${resp}=  Create Category   ${name1}  ${categoryType[3]} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id2}   ${resp.json()}

    ${resp}=  Get Category By Id   ${category_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}          ${name}
    Should Be Equal As Strings  ${resp.json()['categoryType']}  ${categoryType[1]}
    Should Be Equal As Strings  ${resp.json()['accountId']}     ${account_id2}
    Should Be Equal As Strings  ${resp.json()['status']}        ${toggle[0]}

    ${vender_name}=   generate_firstname
    ${contactPersonName}=   FakerLibrary.lastname
    ${owner_name}=   FakerLibrary.lastname
    ${vendorId}=   FakerLibrary.word
    ${PO_Number}    Generate random string    5    123456789
    ${vendor_phno}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${vendor_phno}=  Create Dictionary  countryCode=${countryCodes[0]}   number=${vendor_phno}
    Set Test Variable  ${email}  ${vender_name}.${test_mail}
    ${address}=  FakerLibrary.city
    Set Suite Variable  ${address}
    ${bank_accno}=   db.Generate_random_value  size=11   chars=${digits} 
    ${branch}=   db.get_place
    ${ifsc_code}=   db.Generate_ifsc_code

    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}
    Set Suite Variable    ${state}
    Set Suite Variable    ${district}
    Set Suite Variable    ${pin}
    ${vendor_phno}=   Create List  ${vendor_phno}
    Set Suite Variable    ${vendor_phno}
    
    ${email}=   Create List  ${email}
    Set Suite Variable    ${email}

    ${bankIfsc}    Random Number 	digits=5 
    ${bankIfsc}=    Evaluate    f'{${bankIfsc}:0>7d}'
    Log  ${bankIfsc}
    Set Suite Variable  ${bankIfsc}  55555${bankIfsc} 

    ${bankName}     FakerLibrary.name
    Set Suite Variable    ${bankName}

    ${upiId}     FakerLibrary.name
    Set Suite Variable  ${upiId}

    ${pan}    Random Number 	digits=5 
    ${pan}=    Evaluate    f'{${pan}:0>5d}'
    Log  ${pan}
    Set Suite Variable  ${pan}  55555${pan}

    ${branchName}=    FakerLibrary.name
    Set Suite Variable  ${branchName}
    ${gstin}    Random Number 	digits=5 
    ${gstin}=    Evaluate    f'{${gstin}:0>8d}'
    Log  ${gstin}
    Set Suite Variable  ${gstin}  55555${gstin}
    
    ${preferredPaymentMode}=    Create List    ${jaldeePaymentmode[0]}
    ${bankInfo}=    Create Dictionary     bankaccountNo=${bank_accno}    ifscCode=${bankIfsc}    bankName=${bankName}    upiId=${upiId}     branchName=${branchName}    pancardNo=${pan}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    ${bankInfo}=    Create List         ${bankInfo}
    
    ${resp}=  Create Vendor  ${category_id}  ${vendorId}  ${vender_name}   ${contactPersonName}    ${address}    ${state}    ${pin}   ${vendor_phno}   ${email}     bankInfo=${bankInfo}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${vendor_uid1}   ${resp.json()['encId']}
    Set Suite Variable   ${vendor_id1}   ${resp.json()['id']}

    ${resp}=  Get vendor by encId   ${vendor_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${vendor_id1}
    Should Be Equal As Strings  ${resp.json()['accountId']}  ${account_id2}

    ${providerConsumerIdList}=  Create List  ${cid}
    Set Suite Variable  ${providerConsumerIdList}   

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}
    ${resp}=   Get next invoice Id   ${lid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoiceId}   ${resp.json()}

    ${item1}=     FakerLibrary.word
    ${itemCode1}=     FakerLibrary.word
    ${price1}=     Random Int   min=400   max=500
    ${price}=  Convert To Number  ${price1}  1
    Set Suite Variable  ${price} 
    ${resp}=  Create Sample Item   ${DisplayName1}   ${item1}  ${itemCode1}  ${price}  ${bool[1]} 
    Log   ${resp.content}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${itemId}  ${resp.json()}

    ${resp}=   Get Item By Id  ${itemId}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${promotionalPrice}   ${resp.json()['promotionalPrice']}

    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${itemList}=  Create Dictionary  itemId=${itemId}   quantity=${quantity}   price=${promotionalPrice}
    # ${itemList}=    Create List    ${itemList}

    ${resp}=  Create Finance Status   ${New_status[0]}  ${categoryType[3]} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${status_id1}   ${resp.json()}

    ${resp}=    Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${SERVICE1}=    generate_unique_service_name  ${service_names}
        Append To List  ${service_names}  ${SERVICE1}   
        ${sid1}=  Create Sample Service  ${SERVICE1}   maxBookingsAllowed=10
    ELSE
        Set Test Variable  ${sid1}   ${resp.json()[0]['id']}
    END

    # ${SERVICE1}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE1}
    # Set Suite Variable  ${SERVICE1}
    # ${sid1}=  Create Sample Service  ${SERVICE1}
    ${serviceprice}=   Random Int  min=10  max=15
    ${serviceprice}=  Convert To Number  ${serviceprice}  1
    ${serviceList}=  Create Dictionary  serviceId=${sid1}   quantity=${quantity}  price=${serviceprice}
    ${serviceList}=    Create List    ${serviceList}

    ${itemName}=    FakerLibrary.word
    Set Suite Variable  ${itemName}
    ${price}=   Random Int  min=10  max=15
    ${price}=  Convert To Number  ${price}  1
    ${adhocItemList}=  Create Dictionary  itemName=${itemName}   quantity=${quantity}   price=${price}
    ${adhocItemList}=    Create List    ${adhocItemList}

    ${resp}=  Create Invoice   ${category_id2}    ${invoiceDate}   ${invoiceId}   ${providerConsumerIdList}   ${lid2}   ${itemList}  invoiceStatus=${status_id1}    serviceList=${serviceList}   adhocItemList=${adhocItemList}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_id}   ${resp.json()['idList'][0]}
    Set Suite Variable   ${invoice_uid}   ${resp.json()['uidList'][0]}    

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp1}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    
    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Switch_Login-15

    [Documentation]    Switch login - Create Prescription

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${accountId}  ${resp.json()['id']}

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

    ${resp}=  Get Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${name}=  FakerLibrary.name
    Set Suite Variable    ${name}
    ${aliasName}=  FakerLibrary.name
    Set Suite Variable    ${aliasName}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${DAY1}

    ${resp}=    Create Case Category    ${name}  ${aliasName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${category_id}    ${resp.json()['id']} 

    ${category}=  Create Dictionary  id=${category_id}  
    Set Suite Variable    ${category} 

    ${resp}=    Create Case Type    ${name}  ${aliasName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${type_id}    ${resp.json()['id']}  

    ${type}=  Create Dictionary  id=${type_id} 
    Set Suite Variable    ${type}  
    ${doctor}=  Create Dictionary  id=${pro_id2} 
    Set Suite Variable    ${doctor} 
    ${title}=  FakerLibrary.name
    Set Suite Variable    ${title}
    ${description}=  FakerLibrary.last_name
    Set Suite Variable    ${description}

    ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Suite Variable    ${primaryMobileNo}
    Set Suite Variable  ${email}  ${lastName}${primaryMobileNo}.${test_mail}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    # ${resp}=    Consumer Logout 
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${primaryMobileNo}  ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${cid}            ${resp.json()['providerConsumer']}
    Set Suite Variable    ${jconid}         ${resp.json()['id']}
    Set Suite Variable    ${proconfname}    ${resp.json()['firstName']}    
    Set Suite Variable    ${proconlname}    ${resp.json()['lastName']} 
    Set Suite Variable    ${fullname}       ${proconfname}${space}${proconlname}

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${pid}  ${resp.json()['id']}
    Set Suite Variable  ${pdrfname}  ${resp.json()['firstName']}
    Set Suite Variable  ${pdrlname}  ${resp.json()['lastName']}
    Set Suite Variable  ${pdrname}   ${resp.json()['userName']}

    ${consumer}=  Create Dictionary  id=${cid} 
    Set Suite Variable    ${consumer} 

     ${resp}=    Create Case   ${title}  ${doctor}  ${consumer}   
    Log  ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${caseId}        ${resp.json()['id']}
    Set Suite Variable    ${caseUId}    ${resp.json()['uid']}

    ${resp}=    Get MR Case By UID   ${caseUId}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
   
    ${toothNo}=   Random Int  min=10   max=99
    ${note1}=  FakerLibrary.word
    ${investigation}=    Create List   ${note1}
    ${toothSurfaces}=    Create List   ${toothSurfaces[0]}

    ${resp}=    Create DentalRecord    ${toothNo}  ${toothType[0]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}
    Log  ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable      ${id1}           ${resp.json()}

    ${med_name}=      FakerLibrary.name
    Set Suite Variable    ${med_name}
    ${frequency}=     FakerLibrary.word
    Set Suite Variable    ${frequency}
    ${duration}=      FakerLibrary.sentence
    Set Suite Variable    ${duration}
    ${instrn}=        FakerLibrary.sentence
    Set Suite Variable    ${instrn}
    ${dosage}=        FakerLibrary.sentence
    Set Suite Variable    ${dosage}
    ${type}=     FakerLibrary.word
    Set Suite Variable    ${type}
    ${clinicalNote}=     FakerLibrary.word
    Set Suite Variable    ${clinicalNote}
    ${clinicalNote1}=        FakerLibrary.sentence
    Set Suite Variable    ${clinicalNote1}
    ${type1}=        FakerLibrary.sentence
    Set Suite Variable    ${type1}


    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption}

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption1}


    ${resp}    upload file to temporary location    ${LoanAction[0]}    ${pid}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${prescriptionAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}  driveId=${driveId}
    Log  ${prescriptionAttachments}
    ${prescriptionAttachments}=  Create List   ${prescriptionAttachments}
    Set Suite Variable    ${prescriptionAttachments}

    ${mrPrescriptions}=  Create Dictionary  medicineName=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    Set Suite Variable    ${mrPrescriptions}

    ${empty_list}=  Create List
    ${note}=  FakerLibrary.Text  max_nb_chars=42                                                                                                                                                            
    ${resp}=    Create Prescription    ${cid}    ${pid}    ${html}     ${mrPrescriptions}    prescriptionAttachments=${empty_list}    prescriptionNotes=${note}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${prescription_uid}   ${resp.json()}

    ${resp}=    Get Prescription By Provider consumer Id   ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${referenceId}   ${resp.json()[0]['referenceId']}   
    Set Suite Variable  ${uid}   ${resp.json()[0]['uid']}
    Set Suite Variable  ${prescriptionStatus}   ${resp.json()[0]['prescriptionStatus']} 

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp1}=  Get Prescription By Filter
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    
    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Switch_Login-16

    [Documentation]    Switch login - Appoinment Reports

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${phn3}=  Evaluate  ${PUSERNAME}+5666400
    Set Suite Variable  ${phn3}
    ${firstname33}=  generate_firstname
    ${lastname33}=  FakerLibrary.last_name
    Set Suite Variable      ${firstname33}
    Set Suite Variable      ${lastname33}

    ${resp}=  Account SignUp  ${firstname33}  ${lastname33}  ${None}  ${domain}  ${subdomain}  ${phn3}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${phn3}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId33}=     Random Int  min=1111  max=9999
    Set Suite Variable      ${loginId33}
    
    ${resp}=  Account Set Credential  ${phn3}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId33}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${loginId33}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable      ${pro_id3}  ${decrypted_data['id']}
    Set Suite Variable      ${userName}  ${decrypted_data['userName']}
    
    ${resp}=  Get Provider Details    ${pro_id3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}          ${pro_id3}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}      ${phn3}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Connect with other login  ${loginId33}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation      ${phn3}  ${OtpPurpose['LinkLogin']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key2} =   db.Verify Accnt   ${phn3}    ${OtpPurpose['LinkLogin']}
    Set Suite Variable   ${key2}

    ${resp}=    Connect with other login  ${loginId2}   otp=${key2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=    Switch login    ${loginId33}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Appointment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${resp}=  Get Account Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id33}  ${resp.json()['id']}
   
    ${resp}=  Get Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable   ${locId}

        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
        Set Test Variable  ${loc_name}  ${resp.json()['place']}

    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
        Set Test Variable  ${loc_name}  ${resp.json()[0]['place']}
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
        Set Test Variable  ${dep_id}  ${resp1.content}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
        Set Test Variable  ${dep_name1}  ${resp.json()['departments'][0]['departmentName']}
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${empty_list}=   Create List

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${user_id}=   Create Dictionary  id=${pro_id3}
    ${s_id}=  Create Sample Service  ${SERVICE1}   department=${dep_id}   provider=${user_id}
   
    ${resp}=   Get Service By Id  ${s_id}
    Log   ${resp.content}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${ser_dur}      ${resp.json()['serviceDuration']}
    Set Test Variable   ${ser_amount}   ${resp.json()['totalAmount']}
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[0]}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${locId}  ${duration}  ${bool1}  ${s_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    #............provider consumer creation..........

    ${NewCustomer}    Generate random string    10    123456789
    ${NewCustomer}    Convert To Integer  ${NewCustomer}

    ${custf_name}=  FakerLibrary.name    
    ${custl_name}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${NewCustomer}    firstName=${custf_name}   lastName=${custl_name}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid1}  ${resp.json()}
    
    ${resp}=    Send Otp For Login    ${NewCustomer}    ${account_id33}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    # ${resp}=    Consumer Logout
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${account_id33}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
 
    ${resp}=    Consumer Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId33}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${NewCustomer}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    # Set Test Variable  ${cid1}  ${resp.json()[0]['id']}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  provider=${user_id}  location=${{str('${locId}')}}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subServiceData'][0]['serviceId']}        ${s_id}

    ${filter}=  Create Dictionary    
    ${resp}=  Generate Report REST details  ${reportType[1]}  ${Report_Date_Category[4]}  ${filter}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}

    ${appt_date} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    ${appt_date} =	Set Variable	${appt_date} [${slot1}]	
   
    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId33}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}                        1
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                   Appointment Report
    Should Be Equal As Strings  ${resp.json()['reportType']}                                    ${reportType[1]}
    Should Be Equal As Strings  ${resp.json()['reportResponseType']}                            ${ReportResponseType[0]}
    Should Be Equal As Strings  ${resp.json()['reportTokenID']}                                 ${token_id1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}  ${Report_Date_filter[4]}  
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}                 ${cid} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}                 ${custf_name} ${custl_name}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}                 ${countryCodes[0]} ${NewCustomer}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}                 ${schedule_name} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}                 ${loc_name} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}                 ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}                 ${encId} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}                 ${apptStatus[1]} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}                ${Checkin_mode[1]} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}                0.00
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}                ${prov_name} 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['13']}                ${dep_name1} 

JD-TC-Switch_Login-17

    [Documentation]    Switch login - inventory

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  02s
    ${resp}=  Get Account Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableInventory']}==${bool[0]}
        ${resp1}=  Enable Disable Inventory  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200

        ${resp}=  Get Account Settings
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['enableInventory']}  ${bool[1]}
    END
    IF  ${resp.json()['enableSalesOrder']}==${bool[0]}
        ${resp1}=  Enable/Disable SalesOrder  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200

        ${resp}=  Get Account Settings
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['enableSalesOrder']}  ${bool[1]}
    END

    ${resp}=  Get Store Type By Filter     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
# --------------------- Create Store Type from sa side -------------------------------
    ${TypeName}=    FakerLibrary.name
    Set Suite Variable  ${TypeName}
    sleep  02s

    ${resp}=  Create Store Type   ${TypeName}    ${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id}    ${resp.json()}

    ${resp}=  Get Store Type By EncId   ${St_Id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}
# --------------------- ---------------------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${accountId}=  get_acc_id  ${HLPUSERNAME16}
    Set Suite Variable    ${accountId} 

    ${resp}=  Provide Get Store Type By EncId     ${St_Id}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    Set Suite Variable  ${address}
    Set Suite Variable  ${postcode}
    Set Suite Variable  ${city}

# ------------------------ Create Store ----------------------------------------------------------

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 

    ${Name}=    FakerLibrary.first name
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Suite Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id}  ${resp.json()}

# ---------------------------------------------------------------------------------------------------

# --------------------------- Create SalesOrder Inventory Catalog-InvMgr False ------------------------------------

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name}  ${boolean[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_Cata_Encid}  ${resp.json()}
# --------------------------------------------------------------------------------------------------------------
# ----------------------------------------  Create Item ---------------------------------------------------

    ${displayName}=     FakerLibrary.name
    ${displayName1}=     FakerLibrary.name
    ${resp}=    Create Item Inventory  ${displayName}    
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId1}  ${resp.json()}

    ${resp}=    Create Item Inventory  ${displayName1}    
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId2}  ${resp.json()}

    ${itemdata}=   FakerLibrary.words    	nb=4

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName1}=   Set Variable     ${itemdata[0]} 
    ${itemCode1}=   Set Variable     ${itemdata[1]}
    ${resp}=  Create Sample Item   ${displayName1}   ${itemName1}  ${itemCode1}  ${price1}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}
# -------------------------------------------------------------------------------------------------------------------
# -------------------------------- Create SalesOrder Catalog Item-invMgmt False -----------------------------------

    ${price}=    Random Int  min=2   max=40
    ${invCatItem}=     Create Dictionary       encId=${itemEncId2}
    ${Item_details}=  Create Dictionary        spItem=${invCatItem}    price=${price}   


    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${SO_Cata_Encid}     ${itemEncId1}     ${price}     ${Item_details}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_itemEncIds}  ${resp.json()[0]}
    Set Suite Variable  ${SO_itemEncIds2}  ${resp.json()[1]}

# -------------------------------- Add a provider Consumer -----------------------------------

    ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Suite Variable    ${primaryMobileNo}
    # ${email}=    FakerLibrary.Email
    # Set Suite Variable    ${email}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    # ${resp}=    Consumer Logout 
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email_id}    ${primaryMobileNo}     ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

# --------------------------------------------------------------------------------------------------------

# ----------------------------- Provider take a Sales Order ------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${quantity}=    Random Int  min=2   max=5

    ${Cg_encid}=  Create Dictionary   encId=${SO_Cata_Encid}   
    ${SO_Cata_Encid_List}=  Create List       ${Cg_encid}
    Set Suite Variable  ${SO_Cata_Encid_List}

    ${store}=  Create Dictionary   encId=${store_id}  
    Set Suite Variable  ${store}

    ${items}=  Create Dictionary   catItemEncId=${SO_itemEncIds}    quantity=${quantity}   

    ${resp}=    Create Sales Order    ${SO_Cata_Encid_List}   ${cid}   ${cid}   ${originFrom}    ${items}    store=${store}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${SO_Uid}  ${resp.json()}

    ${netTotal}=  Evaluate  ${price}*${quantity}
    ${netTotal}=  Convert To Number  ${netTotal}   1


    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${SO_Encid}     ${resp.json()['encId']}

    Should Be Equal As Strings    ${resp.json()['uid']}                                           ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['location']['id']}                                  ${locId1}
    Should Be Equal As Strings    ${resp.json()['store']['name']}                                   ${Name}
    Should Be Equal As Strings    ${resp.json()['store']['encId']}                                  ${store_id}

    Should Be Equal As Strings    ${resp.json()['catalog'][0]['name']}                                 ${Name}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['encId']}                                ${SO_Cata_Encid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['invMgmt']}                              ${bool[0]}

    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                          ${cid}
    Should Be Equal As Strings    ${resp.json()['orderFor']['id']}                                  ${cid}
    Should Be Equal As Strings    ${resp.json()['orderFor']['name']}                                ${firstName} ${lastName}

    Should Be Equal As Strings    ${resp.json()['orderType']}                                       ${bookingChannel[0]}
    Should Be Equal As Strings    ${resp.json()['orderStatus']}                                     ${orderStatus[0]}
    Should Be Equal As Strings    ${resp.json()['deliveryType']}                                    ${deliveryType[0]}
    Should Be Equal As Strings    ${resp.json()['deliveryStatus']}                                  ${deliveryStatus[0]}
    Should Be Equal As Strings    ${resp.json()['originFrom']}                                      ${originFrom}

    Should Be Equal As Strings    ${resp.json()['orderNum']}                                        1
    Should Be Equal As Strings    ${resp.json()['orderRef']}                                        1
    Should Be Equal As Strings    ${resp.json()['deliveryDate']}                                    ${DAY1}

    Should Be Equal As Strings    ${resp.json()['contactInfo']['phone']['number']}                  ${primaryMobileNo}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['email']}                            ${email_id}

    Should Be Equal As Strings    ${resp.json()['itemCount']}                                       1
    Should Be Equal As Strings    ${resp.json()['netTotal']}                                        ${netTotal}
    Should Be Equal As Strings    ${resp.json()['taxTotal']}                                        0.0
    Should Be Equal As Strings    ${resp.json()['discountTotal']}                                   0.0
    Should Be Equal As Strings    ${resp.json()['jaldeeCouponTotal']}                               0.0
    Should Be Equal As Strings    ${resp.json()['providerCouponTotal']}                             0.0
    Should Be Equal As Strings    ${resp.json()['netRate']}                                         ${netTotal}
    Should Be Equal As Strings    ${resp.json()['cgstTotal']}                                       0.0

    Should Be Equal As Strings    ${resp.json()['sgstTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['gst']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['cessTotal']}                                       0.0

JD-TC-Switch_Login-18

    [Documentation]    Switch login - sa link to a provider and switch to provider

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Connect with other login  ${loginId}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation      ${ph}  ${OtpPurpose['LinkLogin']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key2} =   db.Verify Accnt   ${ph}    ${OtpPurpose['LinkLogin']}
    Set Suite Variable   ${key2}

    ${resp}=    Connect with other login  ${loginId2}   otp=${key2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}

    ${resp}=    Switch login    ${loginId2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Switch_Login-19

    [Documentation]    Switch login - switch to deactivated provider

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    DeActivate Service Provider 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... Trying to login deactivated provider

    ${resp}=  Encrypted Provider Login  ${loginId3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}   ${ACCOUNT_DEACTIVATED_BASE}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Switch_Login-20

    [Documentation]    Switch login - provider 1 switch and deactivate 

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    DeActivate Service Provider 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings      ${resp.json()}          ${ACCOUNT_DEACTIVATED_BASE}

