*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions
Force Tags        ENQUIRY
Library           Collections
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Variables ***
${self}      0
@{emptylist}
${task_temp_name1}   Follow Up 1
${task_temp_name2}   Follow Up 2
${en_temp_name}   EnquiryName

*** Test Cases ***
JD-TC-Update Enquiry For SP-1
    [Documentation]   Update Enquiry for an Independant SP with all details.
    Comment   Task and Lead does not get created automatically on updating enquireMasterId & leadMasterId like it does when creating with it.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME17}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid17}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid17}  ${resp.json()[0]['id']}
    END

    updateEnquiryStatus  ${account_id}
    sleep  01s
    ${resp}=  categorytype  ${account_id}
    ${resp}=  tasktype      ${account_id}

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id}=  Set Variable  ${random_catagories['id']}
    ${rand_catagory_name}=  Set Variable  ${random_catagories['name']}

    ${resp}=  Get Provider Enquiry Type  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_cat_types}=  Set Variable  ${resp.json()}
    ${random_cat_types}=  Evaluate  random.choice($en_cat_types)  random
    ${rand_cat_type_id}=  Set Variable  ${random_cat_types['id']}
    ${rand_cat_type_name}=  Set Variable  ${random_cat_types['name']}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_statuses}=  Set Variable  ${resp.json()}
    ${random_status}=  Evaluate  random.choice($en_statuses)  random
    ${rand_status_id}=  Set Variable  ${random_status['id']}
    ${rand_status_name}=  Set Variable  ${random_status['name']}

    ${resp}=  Get Provider Enquiry Priority  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_prio}=  Set Variable  ${resp.json()}
    ${random_priority}=  Evaluate  random.choice($en_prio)  random
    ${rand_priority_id}=  Set Variable  ${random_priority['id']}
    ${rand_priority_name}=  Set Variable  ${random_priority['name']}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        IF   '${resp.json()[${i}]['name']}' == 'Follow Up 1'

            Set Test Variable  ${enq_sts_new_id}    ${resp.json()[${i}]['id']}
            Set Test Variable  ${enq_sts_new_name}  ${resp.json()[${i}]['name']}

        END
    END

    ${resp}=  enquiryTemplate  ${account_id}  ${en_temp_name}  ${enq_sts_new_id}  category_id=${rand_catagory_id}  type_id=${rand_cat_type_id}  creator_provider_id=${provider_id} 

    ${resp}=  Get Enquiry Template
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${en_temp_id}  ${resp.json()[0]['id']}

    ${category}=  Create Dictionary   id=${rand_catagory_id}
    ${resp}=  Create Enquiry  ${locId}  ${pcid17}    category=${category} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${en_id}  ${resp.json()['id']}
    Set Suite Variable   ${en_uid}  ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid17}  
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}

    ${resp}=    Get Lead Priority
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lead_prios}=  Set Variable  ${resp.json()}
    ${random_priority}=  Evaluate  random.choice($lead_prios)  random
    ${rand_lead_priority_id}=  Set Variable  ${random_priority['id']}
    ${rand_lead_priority_name}=  Set Variable  ${random_priority['name']}

    ${resp}=    Get Lead Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ld_cat}=  Set Variable  ${resp.json()}
    ${random_cat}=  Evaluate  random.choice($ld_cat)  random
    ${rand_lead_cat_id}=  Set Variable  ${random_cat['id']}
    ${rand_lead_cat_name}=  Set Variable  ${random_cat['name']}

    ${resp}=    Get Lead Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ld_cat_type}=  Set Variable  ${resp.json()}
    ${random_cat_type}=  Evaluate  random.choice($ld_cat_type)  random
    ${rand_lead_cat_type_id}=  Set Variable  ${random_cat_type['id']}
    ${rand_lead_cat_type_name}=  Set Variable  ${random_cat_type['name']}

    ${resp}=    Get Lead Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        IF   '${resp.json()[${i}]['name']}' == 'New'

            Set Test Variable  ${lead_sts_new_id}    ${resp.json()[${i}]['id']}
            Set Test Variable  ${lead_sts_new_name}  ${resp.json()[${i}]['name']}

        END
    END

    ${lead_template_name}=   FakerLibrary.Domain Word
    leadTemplate   ${account_id}  ${lead_template_name}  ${lead_sts_new_id}  category_id=${rand_lead_cat_id}  type_id=${rand_lead_cat_type_id}  priority_id=${rand_lead_priority_id}  creator_provider_id=${provider_id} 

    ${resp}=    Get Lead Templates    
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${ld_temp_id}  ${resp.json()[0]['id']}

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${category}=  Create Dictionary   id=${rand_catagory_id}
    ${type}=  Create Dictionary   id=${rand_cat_type_id}
    ${status}=  Create Dictionary   id=${rand_status_id}
    ${priority}=  Create Dictionary   id=${rand_priority_id}

    ${resp}=  Update Enquiry  ${en_uid}  ${locId}  ${pcid17}  title=${title}  description=${desc}  category=${category}  type=${type}  status=${status}  priority=${priority}  enquireMasterId=${en_temp_id}  leadMasterId=${ld_temp_id}  isLeadAutogenerate=${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid17}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}
    Should Be Equal As Strings  ${resp.json()['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()['type']['id']}   ${rand_cat_type_id}
    Should Be Equal As Strings  ${resp.json()['type']['name']}   ${rand_cat_type_name}
    Should Be Equal As Strings  ${resp.json()['category']['id']}   ${rand_catagory_id}
    Should Be Equal As Strings  ${resp.json()['category']['name']}   ${rand_catagory_name}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${rand_status_id}
    Should Be Equal As Strings  ${resp.json()['status']['name']}   ${rand_status_name}
    Should Be Equal As Strings  ${resp.json()['priority']['id']}   ${rand_priority_id}
    Should Be Equal As Strings  ${resp.json()['priority']['name']}   ${rand_priority_name}

    ${resp}=    Get Task Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        IF   '${resp.json()[${i}]['name']}' == 'New'

            Set Test Variable  ${new_status_id}    ${resp.json()[${i}]['id']}
            Set Test Variable  ${new_status_name}  ${resp.json()[${i}]['name']}

        END
    END

    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[1]['title']}   ${task_temp_name1}
    # Should Be Equal As Strings  ${resp.json()[1]['status']['name']}   ${new_status_name}
    # Set Test Variable  ${task_id2}  ${resp.json()[1]['id']}
    # Set Test Variable  ${task_uid2}  ${resp.json()[1]['taskUid']}

    # Should Be Equal As Strings  ${resp.json()[0]['title']}   ${task_temp_name2}
    # Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${new_status_name}
    # Set Test Variable  ${task_id1}  ${resp.json()[0]['id']}
    # Set Test Variable  ${task_uid1}  ${resp.json()[0]['taskUid']}

    # ${resp}=    Get Task Status
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${len}  Get Length  ${resp.json()}
    # FOR   ${i}  IN RANGE   ${len}
    #     IF   '${resp.json()[${i}]['name']}' == 'Completed'

    #         Set Suite Variable  ${status_id}    ${resp.json()[${i}]['id']}
    #         Set Suite Variable  ${status_name}  ${resp.json()[${i}]['name']}

    #     END
    # END

    # ${resp}=    Change Task Status to Complete   ${task_uid1}  
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Change Task Status to Complete   ${task_uid2}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Provider Tasks   
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[1]['title']}   ${task_temp_name1}
    # Should Be Equal As Strings  ${resp.json()[1]['status']['name']}   ${status_name}

    # Should Be Equal As Strings  ${resp.json()[0]['title']}   ${task_temp_name2}
    # Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${status_name}

    # ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Provider Enquiry Status  
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Lead Status
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${len}  Get Length  ${resp.json()}
    # Set Test Variable  ${lead_status_name}  ${resp.json()[0]['name']}

    ${resp}=    Get Leads With Filter    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()[0]['status']['name']}    ${lead_status_name}


JD-TC-Update Enquiry For SP-2
    [Documentation]   Update Enquiry for an Independant SP with a different customer.
    Comment  The customer id does not change.
    # clear_customer   ${PUSERNAME27}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME17}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid17}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid17}  ${resp.json()[0]['id']}
    END

    # ${resp}=  categorytype  ${account_id}
    # ${resp}=  tasktype      ${account_id}

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id}=  Set Variable  ${random_catagories['id']}
    ${rand_catagory_name}=  Set Variable  ${random_catagories['name']}

    ${resp}=  Get Provider Enquiry Type  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_cat_types}=  Set Variable  ${resp.json()}
    ${random_cat_types}=  Evaluate  random.choice($en_cat_types)  random
    ${rand_cat_type_id}=  Set Variable  ${random_cat_types['id']}
    ${rand_cat_type_name}=  Set Variable  ${random_cat_types['name']}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_statuses}=  Set Variable  ${resp.json()}
    ${random_status}=  Evaluate  random.choice($en_statuses)  random
    ${rand_status_id}=  Set Variable  ${random_status['id']}
    ${rand_status_name}=  Set Variable  ${random_status['name']}

    ${resp}=  Get Provider Enquiry Priority  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_prio}=  Set Variable  ${resp.json()}
    ${random_priority}=  Evaluate  random.choice($en_prio)  random
    ${rand_priority_id}=  Set Variable  ${random_priority['id']}
    ${rand_priority_name}=  Set Variable  ${random_priority['name']}

    # ${resp}=  enquiryTemplate  ${account_id}  ${en_temp_name}  ${enq_sts_new_id}  category_id=${rand_catagory_id}  type_id=${rand_cat_type_id}

    ${resp}=  Get Enquiry Template
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${category}=  Create Dictionary   id=${rand_catagory_id}

    # ${resp}=  Create Enquiry  ${locId}  ${pcid17}  category=${category}   
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${en_id}  ${resp.json()['id']}
    # Set Test Variable   ${en_uid}  ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid17}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME18}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid18}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid18}  ${resp.json()[0]['id']}
    END

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${category}=  Create Dictionary   id=${rand_catagory_id}
    ${type}=  Create Dictionary   id=${rand_cat_type_id}
    ${status}=  Create Dictionary   id=${rand_status_id}
    ${priority}=  Create Dictionary   id=${rand_priority_id}

    ${resp}=  Update Enquiry  ${en_uid}  ${locId}  ${pcid18}  title=${title}  description=${desc}  category=${category}  type=${type}  status=${status}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid18}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}
    Should Be Equal As Strings  ${resp.json()['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()['type']['id']}   ${rand_cat_type_id}
    Should Be Equal As Strings  ${resp.json()['type']['name']}   ${rand_cat_type_name}
    Should Be Equal As Strings  ${resp.json()['category']['id']}   ${rand_catagory_id}
    Should Be Equal As Strings  ${resp.json()['category']['name']}   ${rand_catagory_name}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${rand_status_id}
    Should Be Equal As Strings  ${resp.json()['status']['name']}   ${rand_status_name}
    Should Be Equal As Strings  ${resp.json()['priority']['id']}   ${rand_priority_id}
    Should Be Equal As Strings  ${resp.json()['priority']['name']}   ${rand_priority_name}


JD-TC-Update Enquiry For SP-3
    [Documentation]   Update Enquiry for an Independant SP with a different location.

    # clear_customer   ${PUSERNAME27}
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME17}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid17}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid17}  ${resp.json()[0]['id']}
    END

    # ${resp}=  categorytype  ${account_id}
    # ${resp}=  tasktype      ${account_id}

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id}=  Set Variable  ${random_catagories['id']}
    ${rand_catagory_name}=  Set Variable  ${random_catagories['name']}

    ${resp}=  Get Provider Enquiry Type  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_cat_types}=  Set Variable  ${resp.json()}
    ${random_cat_types}=  Evaluate  random.choice($en_cat_types)  random
    ${rand_cat_type_id}=  Set Variable  ${random_cat_types['id']}
    ${rand_cat_type_name}=  Set Variable  ${random_cat_types['name']}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_statuses}=  Set Variable  ${resp.json()}
    ${random_status}=  Evaluate  random.choice($en_statuses)  random
    ${rand_status_id}=  Set Variable  ${random_status['id']}
    ${rand_status_name}=  Set Variable  ${random_status['name']}

    ${resp}=  Get Provider Enquiry Priority  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_prio}=  Set Variable  ${resp.json()}
    ${random_priority}=  Evaluate  random.choice($en_prio)  random
    ${rand_priority_id}=  Set Variable  ${random_priority['id']}
    ${rand_priority_name}=  Set Variable  ${random_priority['name']}

    # ${resp}=  enquiryTemplate  ${account_id}  ${en_temp_name}  ${enq_sts_new_id}  category_id=${rand_catagory_id}  type_id=${rand_cat_type_id}

    ${resp}=  Get Enquiry Template
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${category}=  Create Dictionary   id=${rand_catagory_id}

    ${resp}=  Create Enquiry  ${locId}  ${pcid17}  category=${category}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id}  ${resp.json()['id']}
    Set Test Variable   ${en_uid}  ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid17}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}

    ${locId1}=  Create Sample Location

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${category}=  Create Dictionary   id=${rand_catagory_id}
    ${type}=  Create Dictionary   id=${rand_cat_type_id}
    ${status}=  Create Dictionary   id=${rand_status_id}
    ${priority}=  Create Dictionary   id=${rand_priority_id}

    ${resp}=  Update Enquiry  ${en_uid}  ${locId1}  ${pcid17}  title=${title}  description=${desc}  category=${category}  type=${type}  status=${status}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid17}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId1}
    Should Be Equal As Strings  ${resp.json()['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()['type']['id']}   ${rand_cat_type_id}
    Should Be Equal As Strings  ${resp.json()['type']['name']}   ${rand_cat_type_name}
    Should Be Equal As Strings  ${resp.json()['category']['id']}   ${rand_catagory_id}
    Should Be Equal As Strings  ${resp.json()['category']['name']}   ${rand_catagory_name}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${rand_status_id}
    Should Be Equal As Strings  ${resp.json()['status']['name']}   ${rand_status_name}
    Should Be Equal As Strings  ${resp.json()['priority']['id']}   ${rand_priority_id}
    Should Be Equal As Strings  ${resp.json()['priority']['name']}   ${rand_priority_name}


JD-TC-Update Enquiry For SP-4
    [Documentation]   Update Enquiry twice with same details.
    # clear_customer   ${PUSERNAME27}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME17}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid17}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid17}  ${resp.json()[0]['id']}
    END

    # ${resp}=  categorytype  ${account_id}
    # ${resp}=  tasktype      ${account_id}

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id}=  Set Variable  ${random_catagories['id']}
    ${rand_catagory_name}=  Set Variable  ${random_catagories['name']}

    ${resp}=  Get Provider Enquiry Type  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_cat_types}=  Set Variable  ${resp.json()}
    ${random_cat_types}=  Evaluate  random.choice($en_cat_types)  random
    ${rand_cat_type_id}=  Set Variable  ${random_cat_types['id']}
    ${rand_cat_type_name}=  Set Variable  ${random_cat_types['name']}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_statuses}=  Set Variable  ${resp.json()}
    ${random_status}=  Evaluate  random.choice($en_statuses)  random
    ${rand_status_id}=  Set Variable  ${random_status['id']}
    ${rand_status_name}=  Set Variable  ${random_status['name']}

    ${resp}=  Get Provider Enquiry Priority  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_prio}=  Set Variable  ${resp.json()}
    ${random_priority}=  Evaluate  random.choice($en_prio)  random
    ${rand_priority_id}=  Set Variable  ${random_priority['id']}
    ${rand_priority_name}=  Set Variable  ${random_priority['name']}

    # ${resp}=  Get Provider Enquiry Status  
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${len}  Get Length  ${resp.json()}
    # FOR   ${i}  IN RANGE   ${len}
    #     IF   '${resp.json()[${i}]['name']}' == 'Follow Up 1'

    #         Set Test Variable  ${enq_sts_new_id}    ${resp.json()[${i}]['id']}
    #         Set Test Variable  ${enq_sts_new_name}  ${resp.json()[${i}]['name']}

    #     END
    # END

    # ${resp}=  enquiryTemplate  ${account_id}  ${en_temp_name}  ${enq_sts_new_id}  category_id=${rand_catagory_id}  type_id=${rand_cat_type_id}

    ${resp}=  Get Enquiry Template
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${category}=  Create Dictionary   id=${rand_catagory_id}

    # ${resp}=  Create Enquiry  ${locId}  ${pcid17}  category=${category}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${en_id}  ${resp.json()['id']}
    # Set Test Variable   ${en_uid}  ${resp.json()['uid']}

    # ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    # Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    # Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    # Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid17}
    # Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}

    # ${locId1}=  Create Sample Location

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${category}=  Create Dictionary   id=${rand_catagory_id}
    ${type}=  Create Dictionary   id=${rand_cat_type_id}
    ${status}=  Create Dictionary   id=${rand_status_id}
    ${priority}=  Create Dictionary   id=${rand_priority_id}

    ${resp}=  Update Enquiry  ${en_uid}  ${locId}  ${pcid17}  title=${title}  description=${desc}  category=${category}  type=${type}  status=${status}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid17}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}
    Should Be Equal As Strings  ${resp.json()['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()['type']['id']}   ${rand_cat_type_id}
    Should Be Equal As Strings  ${resp.json()['type']['name']}   ${rand_cat_type_name}
    Should Be Equal As Strings  ${resp.json()['category']['id']}   ${rand_catagory_id}
    Should Be Equal As Strings  ${resp.json()['category']['name']}   ${rand_catagory_name}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${rand_status_id}
    Should Be Equal As Strings  ${resp.json()['status']['name']}   ${rand_status_name}
    Should Be Equal As Strings  ${resp.json()['priority']['id']}   ${rand_priority_id}
    Should Be Equal As Strings  ${resp.json()['priority']['name']}   ${rand_priority_name}

    ${resp}=  Update Enquiry  ${en_uid}  ${locId}  ${pcid17}  title=${title}  description=${desc}  category=${category}  type=${type}  status=${status}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid17}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}
    Should Be Equal As Strings  ${resp.json()['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()['type']['id']}   ${rand_cat_type_id}
    Should Be Equal As Strings  ${resp.json()['type']['name']}   ${rand_cat_type_name}
    Should Be Equal As Strings  ${resp.json()['category']['id']}   ${rand_catagory_id}
    Should Be Equal As Strings  ${resp.json()['category']['name']}   ${rand_catagory_name}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${rand_status_id}
    Should Be Equal As Strings  ${resp.json()['status']['name']}   ${rand_status_name}
    Should Be Equal As Strings  ${resp.json()['priority']['id']}   ${rand_priority_id}
    Should Be Equal As Strings  ${resp.json()['priority']['name']}   ${rand_priority_name}


JD-TC-Update Enquiry For SP-UH
    [Documentation]   Update Enquiry without catagory.

    # clear_customer   ${PUSERNAME27}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME17}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid17}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid17}  ${resp.json()[0]['id']}
    END

    # ${resp}=  categorytype  ${account_id}
    # ${resp}=  tasktype      ${account_id}

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id}=  Set Variable  ${random_catagories['id']}
    ${rand_catagory_name}=  Set Variable  ${random_catagories['name']}

    ${resp}=  Get Provider Enquiry Type  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_cat_types}=  Set Variable  ${resp.json()}
    ${random_cat_types}=  Evaluate  random.choice($en_cat_types)  random
    ${rand_cat_type_id}=  Set Variable  ${random_cat_types['id']}
    ${rand_cat_type_name}=  Set Variable  ${random_cat_types['name']}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_statuses}=  Set Variable  ${resp.json()}
    ${random_status}=  Evaluate  random.choice($en_statuses)  random
    ${rand_status_id}=  Set Variable  ${random_status['id']}
    ${rand_status_name}=  Set Variable  ${random_status['name']}

    ${resp}=  Get Provider Enquiry Priority  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_prio}=  Set Variable  ${resp.json()}
    ${random_priority}=  Evaluate  random.choice($en_prio)  random
    ${rand_priority_id}=  Set Variable  ${random_priority['id']}
    ${rand_priority_name}=  Set Variable  ${random_priority['name']}

    # ${resp}=  enquiryTemplate  ${account_id}  ${en_temp_name}  ${enq_sts_new_id}  category_id=${rand_catagory_id}  type_id=${rand_cat_type_id}

    # ${resp}=  Get Enquiry Template
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${category}=  Create Dictionary   id=${rand_catagory_id}

    # ${resp}=  Create Enquiry  ${locId}  ${pcid17}  category=${category}   
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${en_id}  ${resp.json()['id']}
    # Set Test Variable   ${en_uid}  ${resp.json()['uid']}

    # ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    # Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    # Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    # Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid17}
    # Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}

    # ${locId1}=  Create Sample Location

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${category}=  Create Dictionary   id=${rand_catagory_id}
    ${type}=  Create Dictionary   id=${rand_cat_type_id}
    ${status}=  Create Dictionary   id=${rand_status_id}
    ${priority}=  Create Dictionary   id=${rand_priority_id}

    ${resp}=  Update Enquiry  ${en_uid}  ${locId}  ${pcid17}  title=${title}  description=${desc}    type=${type}  status=${status}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${CATEGORY_REQUIRES}

    # ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    # Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    # Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    # Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid17}
    # Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}
    # Should Be Equal As Strings  ${resp.json()['title']}   ${title}
    # Should Be Equal As Strings  ${resp.json()['description']}   ${desc}
    # Should Be Equal As Strings  ${resp.json()['type']['id']}   ${rand_cat_type_id}
    # Should Be Equal As Strings  ${resp.json()['type']['name']}   ${rand_cat_type_name}
    # # Should Be Equal As Strings  ${resp.json()['category']['id']}   ${rand_catagory_id}
    # # Should Be Equal As Strings  ${resp.json()['category']['name']}   ${rand_catagory_name}
    # Should Be Equal As Strings  ${resp.json()['status']['id']}  ${rand_status_id}
    # Should Be Equal As Strings  ${resp.json()['status']['name']}  ${rand_status_name}
    # Should Be Equal As Strings  ${resp.json()['priority']['id']}  ${rand_priority_id}
    # Should Be Equal As Strings  ${resp.json()['priority']['name']}  ${rand_priority_name}


JD-TC-Update Enquiry For SP-6
    [Documentation]   Update Enquiry without catagory type.

    # clear_customer   ${PUSERNAME27}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME17}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid17}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid17}  ${resp.json()[0]['id']}
    END

    # ${resp}=  categorytype  ${account_id}
    # ${resp}=  tasktype      ${account_id}

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id}=  Set Variable  ${random_catagories['id']}
    ${rand_catagory_name}=  Set Variable  ${random_catagories['name']}

    ${resp}=  Get Provider Enquiry Type  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_cat_types}=  Set Variable  ${resp.json()}
    ${random_cat_types}=  Evaluate  random.choice($en_cat_types)  random
    ${rand_cat_type_id}=  Set Variable  ${random_cat_types['id']}
    ${rand_cat_type_name}=  Set Variable  ${random_cat_types['name']}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_statuses}=  Set Variable  ${resp.json()}
    ${random_status}=  Evaluate  random.choice($en_statuses)  random
    ${rand_status_id}=  Set Variable  ${random_status['id']}
    ${rand_status_name}=  Set Variable  ${random_status['name']}

    ${resp}=  Get Provider Enquiry Priority  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_prio}=  Set Variable  ${resp.json()}
    ${random_priority}=  Evaluate  random.choice($en_prio)  random
    ${rand_priority_id}=  Set Variable  ${random_priority['id']}
    ${rand_priority_name}=  Set Variable  ${random_priority['name']}

    # ${resp}=  enquiryTemplate  ${account_id}  ${en_temp_name}  ${enq_sts_new_id}  category_id=${rand_catagory_id}  type_id=${rand_cat_type_id}

    # ${resp}=  Get Enquiry Template
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${category}=  Create Dictionary   id=${rand_catagory_id}

    # ${resp}=  Create Enquiry  ${locId}  ${pcid17}  category=${category}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${en_id}  ${resp.json()['id']}
    # Set Test Variable   ${en_uid}  ${resp.json()['uid']}

    # ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    # Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    # Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    # Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid17}
    # Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}

    # ${locId1}=  Create Sample Location

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${category}=  Create Dictionary   id=${rand_catagory_id}
    ${type}=  Create Dictionary   id=${rand_cat_type_id}
    ${status}=  Create Dictionary   id=${rand_status_id}
    ${priority}=  Create Dictionary   id=${rand_priority_id}

    ${resp}=  Update Enquiry  ${en_uid}  ${locId}  ${pcid17}  title=${title}  description=${desc}  category=${category}  status=${status}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid17}
    Should Be Equal As Strings  ${resp.json()['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()['description']}   ${desc}
    # Should Be Equal As Strings  ${resp.json()['type']['id']}   ${rand_cat_type_id}
    # Should Be Equal As Strings  ${resp.json()['type']['name']}   ${rand_cat_type_name}
    Should Be Equal As Strings  ${resp.json()['category']['id']}   ${rand_catagory_id}
    Should Be Equal As Strings  ${resp.json()['category']['name']}   ${rand_catagory_name}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${rand_status_id}
    Should Be Equal As Strings  ${resp.json()['status']['name']}   ${rand_status_name}
    Should Be Equal As Strings  ${resp.json()['priority']['id']}   ${rand_priority_id}
    Should Be Equal As Strings  ${resp.json()['priority']['name']}   ${rand_priority_name}


JD-TC-Update Enquiry For SP-7
    [Documentation]   Update Enquiry without priority.

    # clear_customer   ${PUSERNAME27}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME17}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid17}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid17}  ${resp.json()[0]['id']}
    END

    # ${resp}=  categorytype  ${account_id}
    # ${resp}=  tasktype      ${account_id}

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id}=  Set Variable  ${random_catagories['id']}
    ${rand_catagory_name}=  Set Variable  ${random_catagories['name']}

    ${resp}=  Get Provider Enquiry Type  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_cat_types}=  Set Variable  ${resp.json()}
    ${random_cat_types}=  Evaluate  random.choice($en_cat_types)  random
    ${rand_cat_type_id}=  Set Variable  ${random_cat_types['id']}
    ${rand_cat_type_name}=  Set Variable  ${random_cat_types['name']}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_statuses}=  Set Variable  ${resp.json()}
    ${random_status}=  Evaluate  random.choice($en_statuses)  random
    ${rand_status_id}=  Set Variable  ${random_status['id']}
    ${rand_status_name}=  Set Variable  ${random_status['name']}

    ${resp}=  Get Provider Enquiry Priority  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_prio}=  Set Variable  ${resp.json()}
    ${random_priority}=  Evaluate  random.choice($en_prio)  random
    ${rand_priority_id}=  Set Variable  ${random_priority['id']}
    ${rand_priority_name}=  Set Variable  ${random_priority['name']}

    # ${resp}=  enquiryTemplate  ${account_id}  ${en_temp_name}  ${enq_sts_new_id}  category_id=${rand_catagory_id}  type_id=${rand_cat_type_id}

    # ${resp}=  Get Enquiry Template
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${category}=  Create Dictionary   id=${rand_catagory_id}

    # ${resp}=  Create Enquiry  ${locId}  ${pcid17}  category=${category}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${en_id}  ${resp.json()['id']}
    # Set Test Variable   ${en_uid}  ${resp.json()['uid']}

    # ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    # Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    # Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    # Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid17}
    # Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}

    # ${locId1}=  Create Sample Location

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${category}=  Create Dictionary   id=${rand_catagory_id}
    ${type}=  Create Dictionary   id=${rand_cat_type_id}
    ${status}=  Create Dictionary   id=${rand_status_id}
    ${priority}=  Create Dictionary   id=${rand_priority_id}

    ${resp}=  Update Enquiry  ${en_uid}  ${locId}  ${pcid17}  title=${title}  description=${desc}  category=${category}  type=${type}  status=${status}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid17}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}
    Should Be Equal As Strings  ${resp.json()['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()['type']['id']}   ${rand_cat_type_id}
    Should Be Equal As Strings  ${resp.json()['type']['name']}   ${rand_cat_type_name}
    Should Be Equal As Strings  ${resp.json()['category']['id']}   ${rand_catagory_id}
    Should Be Equal As Strings  ${resp.json()['category']['name']}   ${rand_catagory_name}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${rand_status_id}
    Should Be Equal As Strings  ${resp.json()['status']['name']}   ${rand_status_name}
    # Should Be Equal As Strings  ${resp.json()['priority']['id']}   ${rand_priority_id}
    # Should Be Equal As Strings  ${resp.json()['priority']['name']}   ${rand_priority_name}


JD-TC-Update Enquiry For SP-8
    [Documentation]   Update Enquiry without status.

    # clear_customer   ${PUSERNAME27}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME17}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid17}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid17}  ${resp.json()[0]['id']}
    END

    # ${resp}=  categorytype  ${account_id}
    # ${resp}=  tasktype      ${account_id}

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id}=  Set Variable  ${random_catagories['id']}
    ${rand_catagory_name}=  Set Variable  ${random_catagories['name']}

    ${resp}=  Get Provider Enquiry Type  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_cat_types}=  Set Variable  ${resp.json()}
    ${random_cat_types}=  Evaluate  random.choice($en_cat_types)  random
    ${rand_cat_type_id}=  Set Variable  ${random_cat_types['id']}
    ${rand_cat_type_name}=  Set Variable  ${random_cat_types['name']}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_statuses}=  Set Variable  ${resp.json()}
    ${random_status}=  Evaluate  random.choice($en_statuses)  random
    ${rand_status_id}=  Set Variable  ${random_status['id']}
    ${rand_status_name}=  Set Variable  ${random_status['name']}

    ${resp}=  Get Provider Enquiry Priority  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_prio}=  Set Variable  ${resp.json()}
    ${random_priority}=  Evaluate  random.choice($en_prio)  random
    ${rand_priority_id}=  Set Variable  ${random_priority['id']}
    ${rand_priority_name}=  Set Variable  ${random_priority['name']}

    # ${resp}=  enquiryTemplate  ${account_id}  ${en_temp_name}  ${enq_sts_new_id}  category_id=${rand_catagory_id}  type_id=${rand_cat_type_id}

    # ${resp}=  Get Enquiry Template
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${category}=  Create Dictionary   id=${rand_catagory_id}
    
    # ${resp}=  Create Enquiry  ${locId}  ${pcid17}  category=${category}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${en_id}  ${resp.json()['id']}
    # Set Test Variable   ${en_uid}  ${resp.json()['uid']}

    # ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    # Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    # Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    # Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid17}
    # Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}

    # ${locId1}=  Create Sample Location

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${category}=  Create Dictionary   id=${rand_catagory_id}
    ${type}=  Create Dictionary   id=${rand_cat_type_id}
    ${status}=  Create Dictionary   id=${rand_status_id}
    ${priority}=  Create Dictionary   id=${rand_priority_id}

    ${resp}=  Update Enquiry  ${en_uid}  ${locId}  ${pcid17}  title=${title}  description=${desc}  category=${category}  type=${type}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid17}
    Should Be Equal As Strings  ${resp.json()['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()['type']['id']}   ${rand_cat_type_id}
    Should Be Equal As Strings  ${resp.json()['type']['name']}   ${rand_cat_type_name}
    Should Be Equal As Strings  ${resp.json()['category']['id']}   ${rand_catagory_id}
    Should Be Equal As Strings  ${resp.json()['category']['name']}   ${rand_catagory_name}
    Should Be Equal As Strings  ${resp.json()['priority']['id']}   ${rand_priority_id}
    Should Be Equal As Strings  ${resp.json()['priority']['name']}   ${rand_priority_name}


JD-TC-Update Enquiry For SP-9
    [Documentation]   Update Enquiry with a different category.

    # clear_customer   ${PUSERNAME27}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME17}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid17}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid17}  ${resp.json()[0]['id']}
    END

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate    random.sample(${en_catagories}, 2)    random
    ${rand_catagory_id}=  Set Variable  ${random_catagories[0]['id']}
    ${rand_catagory_name}=  Set Variable  ${random_catagories[0]['name']}
    ${rand_catagory_id1}=  Set Variable  ${random_catagories[1]['id']}
    ${rand_catagory_name1}=  Set Variable  ${random_catagories[1]['name']}

    # ${category}=  Create Dictionary   id=${rand_catagory_id}

    # ${resp}=  Create Enquiry  ${locId}  ${pcid17}   category=${category} 
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${en_id}  ${resp.json()['id']}
    # Set Test Variable   ${en_uid}  ${resp.json()['uid']}

    # ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    # Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    # Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    # Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid17}
    # Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}
    # Should Be Equal As Strings  ${resp.json()['category']['id']}   ${rand_catagory_id}
    # Should Be Equal As Strings  ${resp.json()['category']['name']}   ${rand_catagory_name}

    ${category1}=  Create Dictionary   id=${rand_catagory_id1}

    ${resp}=  Update Enquiry  ${en_uid}  ${locId}  ${pcid17}  category=${category1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid17}
    Should Be Equal As Strings  ${resp.json()['category']['id']}   ${rand_catagory_id1}
    Should Be Equal As Strings  ${resp.json()['category']['name']}   ${rand_catagory_name1}


JD-TC-Update Enquiry For SP-10
    [Documentation]   Update Enquiry with a different type.

    # clear_customer   ${PUSERNAME27}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME17}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid17}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid17}  ${resp.json()[0]['id']}
    END

    ${resp}=  Get Provider Enquiry Type  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_cat_types}=  Set Variable  ${resp.json()}
    Set Suite Variable    ${en_cat_types}
    ${random_cat_types}=  Evaluate    random.sample(${en_cat_types}, 2)    random
    ${rand_cat_type_id}=  Set Variable  ${random_cat_types[0]['id']}
    ${rand_cat_type_name}=  Set Variable  ${random_cat_types[0]['name']}
    ${rand_cat_type_id1}=  Set Variable  ${random_cat_types[1]['id']}
    ${rand_cat_type_name1}=  Set Variable  ${random_cat_types[1]['name']}
    Set Suite Variable  ${rand_cat_type_name1}
    Set Suite Variable  ${rand_cat_type_id}
    Set Suite Variable  ${rand_cat_type_id1}

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id}=  Set Variable  ${random_catagories['id']}
    ${rand_catagory_name}=  Set Variable  ${random_catagories['name']}

    ${type}=  Create Dictionary   id=${rand_cat_type_id}
    ${category}=  Create Dictionary   id=${rand_catagory_id}

    # ${resp}=  Create Enquiry  ${locId}  ${pcid17}   category=${category}  type=${type} 
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${en_id}  ${resp.json()['id']}
    # Set Test Variable   ${en_uid}  ${resp.json()['uid']}

    # ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    # Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    # Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    # Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid17}
    # Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}
    # Should Be Equal As Strings  ${resp.json()['type']['id']}   ${rand_cat_type_id}
    # Should Be Equal As Strings  ${resp.json()['type']['name']}   ${rand_cat_type_name}
    # Set Suite Variable    ${rand_cat_type_name}

    ${type1}=  Create Dictionary   id=${rand_cat_type_id1}

    ${resp}=  Update Enquiry  ${en_uid}  ${locId}  ${pcid17}  category=${category}  type=${type1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid17}
    Should Be Equal As Strings  ${resp.json()['type']['id']}   ${rand_cat_type_id1}
    Should Be Equal As Strings  ${resp.json()['type']['name']}   ${rand_cat_type_name1}


JD-TC-Update Enquiry For SP-11
    [Documentation]   Update Enquiry with a different priority.

    # clear_customer   ${PUSERNAME27}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME17}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid17}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid17}  ${resp.json()[0]['id']}
    END

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id}=  Set Variable  ${random_catagories['id']}
    ${rand_catagory_name}=  Set Variable  ${random_catagories['name']}

    ${resp}=  Get Provider Enquiry Priority  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_prio}=  Set Variable  ${resp.json()}
    Set Suite Variable    ${en_prio}
    ${random_priority}=  Evaluate    random.sample(${en_prio}, 2)    random
    ${rand_priority_id}=  Set Variable  ${random_priority[0]['id']}
    ${rand_priority_name}=  Set Variable  ${random_priority[0]['name']}
    ${rand_priority_id1}=  Set Variable  ${random_priority[1]['id']}
    ${rand_priority_name1}=  Set Variable  ${random_priority[1]['name']}

    ${priority}=  Create Dictionary   id=${rand_priority_id}
    ${category}=  Create Dictionary   id=${rand_catagory_id}

    # ${resp}=  Create Enquiry  ${locId}  ${pcid17}   category=${category}  priority=${priority} 
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${en_id}  ${resp.json()['id']}
    # Set Test Variable   ${en_uid}  ${resp.json()['uid']}

    # ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    # Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    # Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    # Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid17}
    # Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}
    # Should Be Equal As Strings  ${resp.json()['priority']['id']}   ${rand_priority_id}
    # Should Be Equal As Strings  ${resp.json()['priority']['name']}   ${rand_priority_name}

    ${priority1}=  Create Dictionary   id=${rand_priority_id1}

    ${resp}=  Update Enquiry  ${en_uid}  ${locId}  ${pcid17}  category=${category}  priority=${priority1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid17}
    Should Be Equal As Strings  ${resp.json()['priority']['id']}   ${rand_priority_id1}
    Should Be Equal As Strings  ${resp.json()['priority']['name']}   ${rand_priority_name1}


JD-TC-Update Enquiry For SP-UH1
    [Documentation]   Update Enquiry with isLeadAutogenerate as true when leadMasterId & enquireMasterId are not provided.

    # clear_customer   ${PUSERNAME27}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME17}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid17}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid17}  ${resp.json()[0]['id']}
    END

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id}=  Set Variable  ${random_catagories['id']}
    ${rand_catagory_name}=  Set Variable  ${random_catagories['name']}

    # ${resp}=  Create Enquiry  ${locId}  ${pcid17}  category=${category} 
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${en_id}  ${resp.json()['id']}
    # Set Test Variable   ${en_uid}  ${resp.json()['uid']}
    ${category}=  Create Dictionary   id=${rand_catagory_id}
    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid17}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}

    ${resp}=  Update Enquiry  ${en_uid}  ${locId}  ${pcid17}  category=${category}  isLeadAutogenerate=${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${ENQUIRE_PRODUCT_REQUIRED}

    
# JD-TC-Update Enquiry For SP-UH2
#     [Documentation]   Update Enquiry with isLeadAutogenerate as true, leadMasterId & enquireMasterId.
#     comment  Task and Lead doesn't get generated.

#     ${resp}=   Encrypted Provider Login  ${MUSERNAME28}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${account_id}  ${resp.json()['id']}

#     ${resp}=    Get Locations
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     IF   '${resp.content}' == '${emptylist}'
#         ${locId}=  Create Sample Location
#     ELSE
#         Set Test Variable  ${locId}  ${resp.json()[0]['id']}
#     END

#     ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME16}  
#     Log  ${resp.content}
#     Should Be Equal As Strings      ${resp.status_code}  200
#     IF   '${resp.content}' == '${emptylist}'
#         ${resp1}=  AddCustomer  ${CUSERNAME16}
#         Log  ${resp1.content}
#         Should Be Equal As Strings  ${resp1.status_code}  200
#         Set Test Variable  ${pcid16}   ${resp1.json()}
#     ELSE
#         Set Test Variable  ${pcid16}  ${resp.json()[0]['id']}
#     END

#     ${resp}=  Create Enquiry  ${locId}  ${pcid16}    
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${en_id}  ${resp.json()['id']}
#     Set Test Variable   ${en_uid}  ${resp.json()['uid']}

#     ${resp}=  Get Enquiry by Uuid  ${en_uid}  
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
#     Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
#     Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
#     Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid16}
#     Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}

#     ${resp}=    Get Lead Templates    
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Suite Variable  ${ld_temp_id}  ${resp.json()[0]['id']}

#     ${resp}=  Get Enquiry Template
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${en_temp_id}  ${resp.json()[0]['id']}

#     ${resp}=  Update Enquiry  ${en_uid}  ${locId}  ${pcid16}  enquireMasterId=${en_temp_id}  leadMasterId=${ld_temp_id}  isLeadAutogenerate=${bool[1]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=    Get Provider Tasks
#     Log   ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=    Get Leads With Filter    
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200


    


