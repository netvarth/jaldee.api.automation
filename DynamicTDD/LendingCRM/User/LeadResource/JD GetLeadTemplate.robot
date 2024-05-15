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
Variables         /ebs/TDD/varfiles/hl_musers.py

*** Variables ***

@{emptylist}


*** Test Cases ***

JD-TC-GetLeadTemplates-1
    [Documentation]    Create a lead to a branch and get the lead template.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id}  ${decrypted_data['id']}
# *** Comments ***
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number
    Set Suite Variable  ${targetPotential}
    ${resp}=  AddCustomer  ${CUSERNAME3}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${pcons_id3}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}

    ${resp}=    Create Lead    ${title}    ${desc}    ${targetPotential}      ${locId}    ${pcons_id3}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid}        ${resp.json()['id']}
    Set Suite Variable   ${leUid}        ${resp.json()['uid']}
    
    ${p_id1}=  get_acc_id  ${MUSERNAME1}
    Set Suite Variable    ${p_id1}

    ${resp}=  categorytype  ${p_id1}
    ${resp}=  tasktype      ${p_id1}
    ${resp}=    Get Lead Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Category_id}    ${resp.json()[0]['id']}
    Set Suite Variable  ${Category_id1}    ${resp.json()[1]['id']}
    Set Suite Variable  ${Category_id2}    ${resp.json()[2]['id']}
    # Set Suite Variable  ${priority_id3}    ${resp.json()[3]['id']}
    Set Suite Variable  ${category_name}  ${resp.json()[0]['name']}
    Set Suite Variable  ${category_name1}  ${resp.json()[1]['name']}
    Set Suite Variable  ${category_name2}  ${resp.json()[2]['name']}

    ${resp}=    Get Lead Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${type_id2}    ${resp.json()[0]['id']}
    Set Suite Variable  ${type_name2}  ${resp.json()[0]['name']}
    Set Suite Variable  ${type_id3}    ${resp.json()[1]['id']}
    Set Suite Variable  ${type_name3}  ${resp.json()[1]['name']}
    Set Suite Variable  ${type_id4}    ${resp.json()[2]['id']}
    Set Suite Variable  ${type_name4}  ${resp.json()[2]['name']}
    ${resp}=  categorytype  ${p_id1}
    ${resp}=  tasktype      ${p_id1}
    ${resp}=    Get Lead Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${status_id}    ${resp.json()[0]['id']}
    Set Suite Variable  ${status_id1}    ${resp.json()[1]['id']}
    Set Suite Variable  ${status_id2}    ${resp.json()[2]['id']}
    Set Suite Variable  ${status_id3}    ${resp.json()[3]['id']}
    Set Suite Variable  ${status_id4}    ${resp.json()[4]['id']}
    Set Suite Variable  ${status_id5}    ${resp.json()[5]['id']}
    Set Suite Variable  ${status_name2}  ${resp.json()[0]['name']}

    ${resp}=    Get Lead Priority
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${priority_id}    ${resp.json()[0]['id']}
    Set Suite Variable  ${priority_id1}    ${resp.json()[1]['id']}
    Set Suite Variable  ${priority_id2}    ${resp.json()[2]['id']}
    Set Suite Variable  ${priority_id3}    ${resp.json()[3]['id']}
    Set Suite Variable  ${priority_name}  ${resp.json()[0]['name']}
    Set Suite Variable  ${priority_name1}  ${resp.json()[1]['name']}
    Set Suite Variable  ${priority_name2}  ${resp.json()[2]['name']}
    Set Suite Variable  ${priority_name3}  ${resp.json()[3]['name']}

    ${resp}=    Get Lead Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        IF   '${resp.json()[${i}]['name']}' == 'New'

            Set Suite Variable  ${lead_sts_new_id}    ${resp.json()[${i}]['id']}
            Set Test Variable  ${lead_sts_new_name}  ${resp.json()[${i}]['name']}

        END
    END

    ${lead_template_name}=   FakerLibrary.Domain Word
    leadTemplate   ${account_id}  ${lead_template_name}  ${lead_sts_new_id}  category_id=${Category_id}  type_id=${type_id2}  priority_id=${priority_id}  creator_provider_id=${provider_id} 

    ${resp}=    Get Lead Templates    
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Lead By Id   ${leUid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200



JD-TC-GetLeadTemplates-2
    [Documentation]    Create a lead for a user and get the lead template.

    ${resp}=    Encrypted Provider Login    ${MUSERNAME1}    ${PASSWORD}    
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

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
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
        
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${HLMUSERNAME1}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id}=  Create Sample User 

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${PUSERNAME_U1}  ${resp.json()['mobileNo']}

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=    Encrypted Provider Login    ${PUSERNAME_U1}    ${PASSWORD}    
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id1}  ${decrypted_data['id']}

    ${resp}=    AddCustomer    ${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    GetCustomer   phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${pcons_id8}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}

    # ${locId1}=  Create Sample Location

    # ${title}=  FakerLibrary.user name
    # ${desc}=   FakerLibrary.word 
    # ${targetPotential}=    FakerLibrary.Building Number

    # ${resp}=    Create Lead    ${title}    ${desc}    ${targetPotential}      ${locId}    ${pcons_id8}   
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${leid1}        ${resp.json()['id']}
    # Set Suite Variable   ${leUid1}        ${resp.json()['uid']}

    ${lead_template_name}=   FakerLibrary.Domain Word
    leadTemplate   ${account_id}  ${lead_template_name}  ${lead_sts_new_id}  category_id=${Category_id}  type_id=${type_id2}  priority_id=${priority_id}  creator_provider_id=${provider_id1} 
    # ${resp}=    Get Lead Templates    
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=   Get Lead By Id   ${leUid1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Lead Templates    templateName-eq=${lead_template_name}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.json()[0]['id']}    ${id1}
    Should Be Equal As Strings    ${resp.json()[0]['templateName']}    ${lead_template_name}
    



JD-TC-GetLeadTemplates-3
    [Documentation]    Create a lead for a user and get the lead template Filter by category.

    ${resp}=    Encrypted Provider Login    ${PUSERNAME_U1}    ${PASSWORD}    
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=    GetCustomer   phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${pcons_id8}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}

    # ${locId1}=  Create Sample Location

    # ${title}=  FakerLibrary.user name
    # ${desc}=   FakerLibrary.word 
    # ${targetPotential}=    FakerLibrary.Building Number

    # ${resp}=    Create Lead    ${title}    ${desc}    ${targetPotential}      ${locId}    ${pcons_id8}   
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${leid2}        ${resp.json()['id']}
    # Set Suite Variable   ${leUid2}        ${resp.json()['uid']}

    ${lead_template_name}=   FakerLibrary.Domain Word
    leadTemplate   ${account_id}  ${lead_template_name}  ${lead_sts_new_id}  category_id=${Category_id}  type_id=${type_id2}  priority_id=${priority_id}  creator_provider_id=${provider_id1}  
    # Set Test Variable  ${id2}  ${resp.json()['id']}

    ${resp}=    Get Lead Templates    category-eq=${Category_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.json()[1]['id']}    ${id2}
    Should Be Equal As Strings    ${resp.json()[1]['category']['value']['id']}    ${Category_id}

JD-TC-GetLeadTemplates-4
    [Documentation]    Create a lead for a user and get the lead template Filter by categoryName.

    ${resp}=    Encrypted Provider Login    ${PUSERNAME_U1}    ${PASSWORD}    
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=    GetCustomer   phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${pcons_id8}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}

    # ${locId1}=  Create Sample Location

    # ${title}=  FakerLibrary.user name
    # ${desc}=   FakerLibrary.word 
    # ${targetPotential}=    FakerLibrary.Building Number

    # ${resp}=    Create Lead    ${title}    ${desc}    ${targetPotential}      ${locId}    ${pcons_id8}   
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${leid2}        ${resp.json()['id']}
    # Set Suite Variable   ${leUid2}        ${resp.json()['uid']}

    ${lead_template_name}=   FakerLibrary.Domain Word
    leadTemplate   ${account_id}  ${lead_template_name}  ${lead_sts_new_id}  category_id=${Category_id1}  type_id=${type_id2}  priority_id=${priority_id}  creator_provider_id=${provider_id1} 


    ${resp}=    Get Lead Templates    categoryName-eq=${category_name1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.json()[2]['id']}    ${id3}
    Should Be Equal As Strings    ${resp.json()[0]['category']['value']['id']}    ${Category_id1}
    Should Be Equal As Strings    ${resp.json()[0]['category']['value']['name']}    ${category_name1}

JD-TC-GetLeadTemplates-5
    [Documentation]    Create a lead for a user and get the lead template Filter by type.

    ${resp}=    Encrypted Provider Login    ${PUSERNAME_U1}    ${PASSWORD}    
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=    GetCustomer   phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${pcons_id8}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}

    # ${locId1}=  Create Sample Location

    # ${title}=  FakerLibrary.user name
    # ${desc}=   FakerLibrary.word 
    # ${targetPotential}=    FakerLibrary.Building Number

    # ${resp}=    Create Lead    ${title}    ${desc}    ${targetPotential}      ${locId}    ${pcons_id8}   
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${leid2}        ${resp.json()['id']}
    # Set Suite Variable   ${leUid2}        ${resp.json()['uid']}

    ${lead_template_name}=   FakerLibrary.Domain Word
    leadTemplate   ${account_id}  ${lead_template_name}  ${lead_sts_new_id}  category_id=${Category_id1}  type_id=${type_id2}  priority_id=${priority_id}  creator_provider_id=${provider_id1} 


    ${resp}=    Get Lead Templates    type-eq=${type_id2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.json()[2]['id']}    ${id3}
    Should Be Equal As Strings    ${resp.json()[0]['type']['value']['id']}    ${type_id2}
    # Should Be Equal As Strings    ${resp.json()[0]['type']['value']['name']}    ${category_name1}

JD-TC-GetLeadTemplates-6
    [Documentation]    Create a lead for a user and get the lead template Filter by typeName.

    ${resp}=    Encrypted Provider Login    ${PUSERNAME_U1}    ${PASSWORD}    
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=    GetCustomer   phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${pcons_id8}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}

    # ${locId1}=  Create Sample Location

    # ${title}=  FakerLibrary.user name
    # ${desc}=   FakerLibrary.word 
    # ${targetPotential}=    FakerLibrary.Building Number

    # ${resp}=    Create Lead    ${title}    ${desc}    ${targetPotential}      ${locId}    ${pcons_id8}   
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${leid2}        ${resp.json()['id']}
    # Set Suite Variable   ${leUid2}        ${resp.json()['uid']}

    ${lead_template_name}=   FakerLibrary.Domain Word
    leadTemplate   ${account_id}  ${lead_template_name}  ${lead_sts_new_id}  category_id=${Category_id1}  type_id=${type_id3}  priority_id=${priority_id}  creator_provider_id=${provider_id1} 


    ${resp}=    Get Lead Templates    typeName-eq=${type_name3}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.json()[2]['id']}    ${id3}
    Should Be Equal As Strings    ${resp.json()[0]['type']['value']['id']}    ${type_id3}
    Should Be Equal As Strings    ${resp.json()[0]['type']['value']['name']}    ${type_name3}

JD-TC-GetLeadTemplates-7
    [Documentation]    Create a lead for a user and get the lead template Filter by priority.

    ${resp}=    Encrypted Provider Login    ${PUSERNAME_U1}    ${PASSWORD}    
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=    GetCustomer   phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${pcons_id8}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}

    ${lead_template_name}=   FakerLibrary.Domain Word
    leadTemplate   ${account_id}  ${lead_template_name}  ${lead_sts_new_id}  category_id=${Category_id1}  type_id=${type_id3}  priority_id=${priority_id}  creator_provider_id=${provider_id1} 


    ${resp}=    Get Lead Templates    priority-eq=${priority_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.json()[2]['id']}    ${id3}
    Should Be Equal As Strings    ${resp.json()[0]['priority']['value']['id']}    ${priority_id}
    # Should Be Equal As Strings    ${resp.json()[0]['priority']['value']['name']}    ${priority_name2}

JD-TC-GetLeadTemplates-8
    [Documentation]    Create a lead for a user and get the lead template Filter by priorityName.

    ${resp}=    Encrypted Provider Login    ${PUSERNAME_U1}    ${PASSWORD}    
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    GetCustomer   phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${pcons_id8}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}

    ${lead_template_name}=   FakerLibrary.Domain Word
    leadTemplate   ${account_id}  ${lead_template_name}  ${lead_sts_new_id}  category_id=${Category_id1}  type_id=${type_id3}  priority_id=${priority_id2}  creator_provider_id=${provider_id1} 


    ${resp}=    Get Lead Templates    priorityName-eq=${priority_name2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.json()[2]['id']}    ${id3}
    Should Be Equal As Strings    ${resp.json()[0]['priority']['value']['id']}    ${priority_id2}
    Should Be Equal As Strings    ${resp.json()[0]['priority']['value']['name']}    ${priority_name2}

JD-TC-GetLeadTemplates-9
    [Documentation]    Create a lead for a user and get the lead template Filter by isSubTask.

    ${resp}=    Encrypted Provider Login    ${PUSERNAME_U1}    ${PASSWORD}    
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    GetCustomer   phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${pcons_id8}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}

    ${lead_template_name}=   FakerLibrary.Domain Word
    leadTemplate   ${account_id}  ${lead_template_name}  ${lead_sts_new_id}  category_id=${Category_id1}  type_id=${type_id3}  priority_id=${priority_id2}  creator_provider_id=${provider_id1}  


    ${resp}=    Get Lead Templates    isSubTask-eq=${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.json()[2]['id']}    ${id3}
    Should Be Equal As Strings    ${resp.json()[0]['priority']['value']['id']}    ${priority_id2}
    Should Be Equal As Strings    ${resp.json()[0]['priority']['value']['name']}    ${priority_name2}


*** Comments ***

JD-TC-AddLeadToken-UH4
    [Documentation]  GetLeadToken with consumer login.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id}  ${decrypt_data['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number
    Set Suite Variable  ${targetPotential}
    ${resp}=  AddCustomer  ${CUSERNAME3}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${pcons_id3}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}

    ${resp}=    Create Lead    ${title}    ${desc}    ${targetPotential}      ${locId}    ${pcons_id3}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid}        ${resp.json()['id']}
    Set Suite Variable   ${leUid}        ${resp.json()['uid']}
    
    ${p_id1}=  get_acc_id  ${MUSERNAME1}
    Set Suite Variable    ${p_id1}

    ${resp}=  categorytype  ${p_id1}
    ${resp}=  tasktype      ${p_id1}
    ${resp}=    Get Lead Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Category_id}    ${resp.json()[1]['id']}
    Set Suite Variable  ${Category_id1}    ${resp.json()[1]['id']}
    Set Suite Variable  ${Category_id2}    ${resp.json()[2]['id']}
    # Set Suite Variable  ${priority_id3}    ${resp.json()[3]['id']}
    Set Suite Variable  ${category_name2}  ${resp.json()[0]['name']}

    ${resp}=    Get Lead Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${type_id2}    ${resp.json()[0]['id']}
    Set Suite Variable  ${type_name2}  ${resp.json()[0]['name']}
    ${resp}=  categorytype  ${p_id1}
    ${resp}=  tasktype      ${p_id1}
    ${resp}=    Get Lead Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${status_id}    ${resp.json()[0]['id']}
    Set Suite Variable  ${status_id1}    ${resp.json()[1]['id']}
    Set Suite Variable  ${status_id2}    ${resp.json()[2]['id']}
    Set Suite Variable  ${status_id3}    ${resp.json()[3]['id']}
    Set Suite Variable  ${status_id4}    ${resp.json()[4]['id']}
    Set Suite Variable  ${status_id5}    ${resp.json()[5]['id']}
    Set Suite Variable  ${status_name2}  ${resp.json()[0]['name']}

    ${resp}=    Get Lead Priority
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${priority_id}    ${resp.json()[0]['id']}
    Set Suite Variable  ${priority_id1}    ${resp.json()[1]['id']}
    Set Suite Variable  ${priority_id2}    ${resp.json()[2]['id']}
    Set Suite Variable  ${priority_id3}    ${resp.json()[3]['id']}
    Set Suite Variable  ${priority_name2}  ${resp.json()[0]['name']}

    ${lead_template_name}=   FakerLibrary.Domain Word
    leadTemplate   ${account_id}  ${lead_template_name}  ${lead_sts_new_id}  category_id=${Category_id}  type_id=${type_id2}  priority_id=${priority_id}  creator_provider_id=${provider_id} 

    ${resp}=    Get Lead Templates    
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Lead By Id   ${leUid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


*** Keywords ***
Get Lead Templates
    [Arguments]    &{kwargs}     
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw     /provider/lead/master    params=${kwargs}      expected_status=any
    RETURN  ${resp}


