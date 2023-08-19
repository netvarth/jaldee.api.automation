*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Lead
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/musers.py

*** Variables ***

@{emptylist} 

*** Test Cases ***

JD-TC-GetLeadById-1

    [Documentation]   Create Lead to a valid branch and get the lead, verify it.

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+590291
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${MUSERNAME_E}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${MUSERNAME_E}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${id}  ${resp.json()['id']}

    Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
    Set Suite Variable  ${MUSERNAME_E}
    
    ${p_id}=  get_acc_id  ${MUSERNAME_E}

    ${resp}=   enquiryStatus  ${p_id}
    ${resp}=   leadStatus     ${p_id}
    ${resp}=   categorytype   ${p_id}
    ${resp}=   tasktype       ${p_id}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
    END

    ${lid1}=  Create Sample Location
    Set Suite Variable  ${lid1}

    ${resp}=  Toggle Department Enable
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+3366499
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
     Should Be Equal As Strings    ${resp.status_code}    200 
     Set Suite Variable  ${pin}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Suite Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

    ${whpnum}=  Evaluate  ${PUSERNAME}+346252
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346352

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+3366500
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    ${firstname1}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname1}=  FakerLibrary.last_name
    
    ${whpnum}=  Evaluate  ${PUSERNAME}+346863
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346390

    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U2}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U2}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U2}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  ProviderLogin  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${title}=  FakerLibrary.user name
    Set Suite Variable   ${title} 
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number

    ${resp}=  AddCustomer  ${CUSERNAME5}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${pcons_id3}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}

    ${resp}=    Create Lead    ${title}    ${desc}    ${targetPotential}      ${lid}    ${pcons_id3}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid1}        ${resp.json()['id']}
    Set Suite Variable   ${leUid1}        ${resp.json()['uid']}

    ${resp}=   Get Lead By Id   ${leUid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['title']}         ${title}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

JD-TC-GetLeadById-2

    [Documentation]   Create multiple leads for different users and get the leads by id.

    ${resp}=  ProviderLogin  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}
    
    ${title}=  FakerLibrary.user name
    Set Suite Variable   ${title} 
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number

    ${resp}=  AddCustomer  ${CUSERNAME6}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${pcons_id6}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}

    ${resp}=    Create Lead    ${title}    ${desc}    ${targetPotential}      ${lid}    ${pcons_id6}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid2}        ${resp.json()['id']}
    Set Suite Variable   ${leUid2}        ${resp.json()['uid']}

    ${resp}=   Get Lead By Id   ${leUid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['title']}         ${title}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  ProviderLogin  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${title1}=  FakerLibrary.user name
    Set Suite Variable   ${title1} 
    ${desc1}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number

    ${resp}=    Create Lead    ${title1}    ${desc1}    ${targetPotential}      ${lid}    ${pcons_id6}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid3}        ${resp.json()['id']}
    Set Suite Variable   ${leUid3}        ${resp.json()['uid']}

    ${resp}=   Get Lead By Id   ${leUid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['title']}         ${title1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}


JD-TC-GetLeadById-3

    [Documentation]   Create multiple leads for different users then add manager and get the leads by id.


    ${resp}=  Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${title1}=   FakerLibrary.word  
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number
    ${manager}=    Create Dictionary    id=${id} 
    Set Suite Variable  ${manager}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${loc_id1}   ${resp.json()[0]['id']}
    # ${loc_id1}=  Create Sample Location
    # Set Suite Variable  ${loc_id1}
    
    ${resp}=    Create Lead   ${title1}   ${desc}     ${targetPotential}   ${loc_id1}    ${pcons_id6}    
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lead_id4}  ${resp.json()['id']}
    Set Suite Variable  ${lead_Uid4}  ${resp.json()['uid']}

    ${resp}=    Change Lead Manager    ${lead_Uid4}    ${u_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.json()}     ${bool[1]}

    ${resp}=   Get Lead By Id  ${lead_Uid4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['title']}         ${title1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${loc_id1}
    Should Be Equal As Strings  ${resp.json()['manager']['id']}   ${u_id1}

    ${resp}=  Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${title2}=   FakerLibrary.word  
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number

    ${resp}=    Create Lead  ${title2}  ${desc}   ${targetPotential}    ${lid}    ${pcons_id3}    
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lead_id5}  ${resp.json()['id']}
    Set Suite Variable  ${lead_Uid5}  ${resp.json()['uid']}

    ${resp}=    Change Lead Manager    ${lead_Uid5}    ${u_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.json()}     ${bool[1]}

    ${resp}=   Get Lead By Id  ${lead_Uid5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['title']}         ${title2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}
    Should Be Equal As Strings  ${resp.json()['manager']['id']}   ${u_id}

    
JD-TC-GetLeadById-4

    [Documentation]   Create leads for users then change manager and get the leads by id.

    ${resp}=  ProviderLogin  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Change Lead Manager    ${leUid3}    ${u_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.json()}     ${bool[1]}

    ${resp}=   Get Lead By Id  ${leUid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['title']}         ${title1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}


JD-TC-GetLeadById-5

    [Documentation]   Create leads for users then remove manager and get the leads by id.
    ${resp}=  ProviderLogin  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Remove Lead Manager   ${leUid3}
    Log  ${resp.content}

    ${resp}=   Get Lead By Id  ${leUid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['title']}         ${title1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}


JD-TC-GetLeadById-8

    [Documentation]   Create leads for users then remove assignee and get the leads by id.
    
    ${resp}=  ProviderLogin  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Remove Lead Assignee   ${leUid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.json()}    ${bool[1]}
    
    ${resp}=   Get Lead By Id  ${leUid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['title']}         ${title1}
    # Should Be Equal As Strings  ${resp.json()['assignee']['id']}   []

JD-TC-GetLeadById-9

    [Documentation]   Create leads for users and change the location then get the leads by id.
    
    ${resp}=  ProviderLogin  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${title4}=  FakerLibrary.user name
    Set Suite Variable   ${title4} 
    ${desc1}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number

    ${resp}=    Create Lead    ${title4}    ${desc1}    ${targetPotential}      ${lid}    ${pcons_id6}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid9}        ${resp.json()['id']}
    Set Suite Variable   ${leUid9}        ${resp.json()['uid']}

    ${resp}=    Transfer Lead Location    ${leUid9}    ${lid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Lead By Id  ${leUid9}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['title']}         ${title4}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid1}

JD-TC-GetLeadById-10

    [Documentation]   get another provider's lead.

    ${resp}=  Provider Login  ${PUSERNAME15}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Lead By Id  ${lead_Uid4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${NO_PERMISSION}

JD-TC-GetLeadById-11

    [Documentation]   Get lead without login.

    ${resp}=   Get Lead By Id  ${leUid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.content}    "${SESSION_EXPIRED}"

JD-TC-GetLeadById-12

    [Documentation]   Get lead by consumer.

    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Lead By Id  ${leUid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.content}   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-GetLeadById-13

    [Documentation]   Get lead by invalid lead id.

    ${resp}=  Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${invalid_id}=  Random Int   min=1000   max=5000

    ${INVALID_LEAD_TEMPLATE_ID}=   Replace String  ${INVALID_LEAD_ID}  {}  Lead

    ${resp}=   Get Lead By Id  ${invalid_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422  
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_LEAD_TEMPLATE_ID}

JD-TC-GetLeadById-14

    [Documentation]   Get lead by without giving lead id.

    ${resp}=  Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Lead By Id  ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

*** comment ***


JD-TC-GetLeadById-6

    [Documentation]   Create leads for users then add assignee and get the leads by id.

    ${resp}=  ProviderLogin  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Change Lead Assignee   ${leUid3}  ${u_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Lead By Id  ${leUid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['title']}         ${title1}
    Should Be Equal As Strings  ${resp.json()['assignee']['id']}   ${u_id}

JD-TC-GetLeadById-7

    [Documentation]   Create leads for users then change assignee and get the leads by id.

    ${resp}=  ProviderLogin  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Change Lead Assignee   ${leUid3}  ${u_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Lead By Id  ${leUid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['title']}         ${title1}
    Should Be Equal As Strings  ${resp.json()['assignee']['id']}   ${u_id1}