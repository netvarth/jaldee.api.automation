*** Settings ***
Suite Teardown    Delete All Sessions
Force Tags        Provider Login
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ApiKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

${DisplayName1}   item1_DisplayName
@{service_names}

*** Test Cases ***

JD-TC-Switch_Login-1

    [Documentation]    Switch login - Provider 1 switch to provider 2

    ${domresp}=  Get BusinessDomainsConf
    Log  ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${domain_list}=  Create List
    ${subdomain_list}=  Create List
    FOR  ${domindex}  IN RANGE  ${len}
        Set Test Variable  ${d}  ${domresp.json()[${domindex}]['domain']}    
        Append To List  ${domain_list}    ${d} 
        Set Test Variable  ${sd}  ${domresp.json()[${domindex}]['subDomains'][0]['subDomain']}
        Append To List  ${subdomain_list}    ${sd} 
    END
    Log  ${domain_list}
    Log  ${subdomain_list}
    Set Suite Variable  ${domain_list}
    Set Suite Variable  ${subdomain_list}

    # ........ Provider 1 ..........

    ${ph}=  Evaluate  ${PUSERNAME}+5666009
    Set Suite Variable  ${ph}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable      ${firstname}
    Set Suite Variable      ${lastname}

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph}   1
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
    
    ${resp}=  Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${pro_id}      ${resp.json()['id']}
    
    ${resp}=  Get Provider Details    ${pro_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}          ${pro_id}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}      ${ph}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ........ Provider 2 ..........

    ${ph2}=  Evaluate  ${PUSERNAME}+5666400
    Set Suite Variable  ${ph2}
    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name
    Set Suite Variable      ${firstname2}
    Set Suite Variable      ${lastname2}

    ${resp}=  Account SignUp  ${firstname2}  ${lastname2}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph2}   1
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
    
    ${resp}=  Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${pro_id2}    ${resp.json()['id']}
    Set Suite Variable    ${pdrname2}   ${resp.json()['userName']}
    Set Suite Variable    ${pdrfname2}  ${resp.json()['firstName']}
    Set Suite Variable    ${pdrlname2}  ${resp.json()['lastName']}
    
    ${resp}=  Get Provider Details    ${pro_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}          ${pro_id2}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}      ${ph2}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${loginId}  ${PASSWORD}
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
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}          ${pro_id2}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}      ${ph2}
    
JD-TC-Switch_Login-2

    [Documentation]    Switch login - provider 2 to provider 1

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Provider Details    ${pro_id}
    Log  ${resp.json()}
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

    ${resp}=  Provider Login  ${loginId2}  ${PASSWORD}
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

    ${resp}=  Provider Login  ${loginId}  ${PASSWORD}
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

    [Documentation]    Switch login - where login id is empty

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    404

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Switch_Login-UH2

    [Documentation]    Switch login - where login id is invalid

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     Random Int  min=1111  max=9999

    ${resp}=    Switch login    ${inv}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings      ${resp.json()}          ${INV_LOGIN_ID}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Switch_Login-UH3

    [Documentation]    Switch login - without login

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     419
    Should Be Equal As Strings      ${resp.json()}          ${SESSION_EXPIRED}

JD-TC-Switch_Login-UH4

    [Documentation]    Switch login - provider 2 linking provider 3 and provider 1 try to switch provider 3

    # ........ Provider 3 ..........

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${ph3}=  Evaluate  ${PUSERNAME}+5667632
    Set Suite Variable  ${ph3}
    ${firstname3}=  FakerLibrary.first_name
    ${lastname3}=  FakerLibrary.last_name
    Set Suite Variable      ${firstname3}
    Set Suite Variable      ${lastname3}

    ${resp}=  Account SignUp  ${firstname3}  ${lastname3}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph3}   1
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
    
    ${resp}=  Provider Login  ${loginId3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${pro_id3}      ${resp.json()['id']}
    
    ${resp}=  Get Provider Details    ${pro_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}          ${pro_id3}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}      ${ph3}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${loginId2}  ${PASSWORD}
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

    ${resp}=  Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings      ${resp.json()}          ${CANT_SWITCH}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Switch_Login-UH5

    [Documentation]    Switch login - provider 3 switch to provider 1

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${loginId3}  ${PASSWORD}
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

    ${resp}=  Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Provider Details    ${pro_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}          ${pro_id2}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}      ${ph2}

    ${resp}=    Switch login    ${loginId3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Provider Details    ${pro_id3}
    Log  ${resp.json()}
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

    ${resp}=  Provider Login  ${loginId}  ${PASSWORD}
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

    ${resp}=  Provider Login  ${loginId}  ${PASSWORD}
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

    ${resp}=  Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id3}  ${DAY1}  ${sid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Switch_Login-7

    [Documentation]    Switch login - user creation and updation by switching

    ${resp}=  Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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
    Set Test Variable  ${city3}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state3}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin3}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
    
    ${firstname3}=  FakerLibrary.name
    ${lastname3}=  FakerLibrary.last_name
    ${address3}=  get_address
    ${us1}=  Evaluate  ${PUSERNAME}+5665471
    Set Suite Variable  ${us1}

    ${resp}=  Create User  ${firstname3}  ${lastname3}    ${countryCodes[0]}  ${us1}  ${userType[0]}  email=${P_Email}${loginId}.${test_mail}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['firstName']}     ${firstname3} 
    Should Be Equal As Strings  ${resp.json()['lastName']}      ${lastname3} 

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name

    ${resp}=  Update User  ${u_id}  ${countryCodes[0]}  ${us1}   ${userType[0]}  email=${P_Email}${loginId}.${test_mail}  firstName=${firstname1}  lastName=${lastname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Switch_Login-8

    [Documentation]    Switch login - create location

    ${resp}=  Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${loginId}  ${PASSWORD}
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
    
    ${resp}=  Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz1}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    
    ${bName}    FakerLibrary.firstName
    ${bDesc}    FakerLibrary.Sentence
    ${shname}   FakerLibrary.Sentence
    ${phone1}   Evaluate  ${PUSERNAME}+874589

    ${resp}=  Create Business Profile without details  ${bName}  ${bDesc}   ${shname}   ${phone1}   ${empty}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${loginId}  ${PASSWORD}
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

    ${resp}=  Provider Login  ${loginId}  ${PASSWORD}
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
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId}    ${resp.json()['holidayId']}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Holiday By Id   ${holidayId}
    Log   ${resp.json()}
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

    ${resp}=  Provider Login  ${loginId}  ${PASSWORD}
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

    ${resp}=  Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Holiday By Account
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}  "id":"${holidayId}"

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Switch_Login-19

    [Documentation]    Switch login - switch to deactivated provider

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${loginId3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    DeActivate Service Provider 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... Trying to login deactivated provider

    ${resp}=  Provider Login  ${loginId3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}   ${ACCOUNT_DEACTIVATED_BASE}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${loginId2}  ${PASSWORD}
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

    ${resp}=  Provider Login  ${loginId}  ${PASSWORD}
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

    ${resp}=  Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings      ${resp.json()}          ${ACCOUNT_DEACTIVATED_BASE}

