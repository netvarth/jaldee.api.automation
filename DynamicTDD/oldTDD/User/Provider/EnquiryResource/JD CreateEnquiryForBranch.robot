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
JD-TC-Create Enquiry For Branch-1
    [Documentation]   Create Enquiry for a branch.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}
    clear_customer   ${PUSERNAME26}
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    updateEnquiryStatus  ${account_id}
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

    ${resp}=  taskTemplate  ${account_id}  ${task_temp_name1}  ${new_status_id}  origin_from=3  origin_id=${en_temp_id}  creator_provider_id=${provider_id} 
    ${resp}=  taskTemplate  ${account_id}  ${task_temp_name2}  ${new_status_id}  origin_from=3  origin_id=${en_temp_id}  creator_provider_id=${provider_id} 

    ${category1}=  Create Dictionary   id=${rand_catagory_id}
    Set Suite Variable  ${category1}

    ${resp}=  Create Enquiry  ${locId}  ${pcid13}   category=${category1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id}        ${resp.json()['id']}
    Set Test Variable   ${en_uid}        ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}

    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create Enquiry For Branch-2
    [Documentation]   Create Enquiry with title and description. 

    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_customer   ${PUSERNAME26}
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


    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City

    ${resp}=  Create Enquiry  ${locId}  ${pcid13}  title=${title}  description=${desc}  category=${category1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id}        ${resp.json()['id']}
    Set Test Variable   ${en_uid}        ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()['description']}   ${desc}

    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Create Enquiry For Branch-3
    [Documentation]   Create Enquiry with category. 

    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
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
    clear_customer   ${PUSERNAME26}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
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

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${category}=  Create Dictionary   id=${rand_catagory_id}

    ${resp}=  Create Enquiry  ${locId}  ${pcid13}  title=${title}  description=${desc}  category=${category}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id}        ${resp.json()['id']}
    Set Test Variable   ${en_uid}        ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}   ${rand_catagory_id}
    Should Be Equal As Strings  ${resp.json()['category']['name']}   ${rand_catagory_name}

    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Create Enquiry For Branch-4
    [Documentation]   Create Enquiry with category type. 

    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
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
    clear_customer   ${PUSERNAME26}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    # ${resp}=  categorytype  ${account_id}
    # ${resp}=  tasktype      ${account_id}

    # ${resp}=  Get Provider Enquiry Category  
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Enquiry Type  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_cat_types}=  Set Variable  ${resp.json()}
    ${random_cat_types}=  Evaluate  random.choice($en_cat_types)  random
    ${rand_cat_type_id}=  Set Variable  ${random_cat_types['id']}
    ${rand_cat_type_name}=  Set Variable  ${random_cat_types['name']}

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${type}=  Create Dictionary   id=${rand_cat_type_id}

    ${resp}=  Create Enquiry  ${locId}  ${pcid13}  title=${title}  description=${desc}  type=${type}  category=${category1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id}        ${resp.json()['id']}
    Set Test Variable   ${en_uid}        ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()['type']['id']}   ${rand_cat_type_id}
    Should Be Equal As Strings  ${resp.json()['type']['name']}   ${rand_cat_type_name}

    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Create Enquiry For Branch-5
    [Documentation]   Create Enquiry with different status. 

    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
    clear_customer   ${PUSERNAME26}
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
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_statuses}=  Set Variable  ${resp.json()}
    ${random_status}=  Evaluate  random.choice($en_statuses)  random
    ${rand_status_id}=  Set Variable  ${random_status['id']}
    ${rand_status_name}=  Set Variable  ${random_status['name']}

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${status}=  Create Dictionary   id=${rand_status_id}

    ${resp}=  Create Enquiry  ${locId}  ${pcid13}  title=${title}  description=${desc}  status=${status}  category=${category1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id}        ${resp.json()['id']}
    Set Test Variable   ${en_uid}        ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${rand_status_id}
    Should Be Equal As Strings  ${resp.json()['status']['name']}   ${rand_status_name}

    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Create Enquiry For Branch-6
    [Documentation]   Create Enquiry with different priority. 

    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
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
    clear_customer   ${PUSERNAME26}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    ${resp}=  Get Provider Enquiry Priority  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_prios}=  Set Variable  ${resp.json()}
    ${random_priority}=  Evaluate  random.choice($en_prios)  random
    ${rand_priority_id}=  Set Variable  ${random_priority['id']}
    ${rand_priority_name}=  Set Variable  ${random_priority['name']}

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${priority}=  Create Dictionary   id=${rand_priority_id}

    ${resp}=  Create Enquiry  ${locId}  ${pcid13}  title=${title}  description=${desc}  priority=${priority}  category=${category1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id}        ${resp.json()['id']}
    Set Test Variable   ${en_uid}        ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()['priority']['id']}   ${rand_priority_id}
    Should Be Equal As Strings  ${resp.json()['priority']['name']}   ${rand_priority_name}

    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Create Enquiry For Branch-7
    [Documentation]   Create Enquiry with isLeadAutogenerate flag disabled. 

    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
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
    clear_customer   ${PUSERNAME26}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City

    ${resp}=  Create Enquiry  ${locId}  ${pcid13}  title=${title}  description=${desc}  isLeadAutogenerate=${bool[0]}  category=${category1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id}        ${resp.json()['id']}
    Set Test Variable   ${en_uid}        ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()['description']}   ${desc}

    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Create Enquiry For Branch-8
    [Documentation]   Create Multiple enquiries for same location different customer. 

    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
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
    clear_customer   ${PUSERNAME26}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME14}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid14}  ${resp.json()[0]['id']}
    END

    # ${title}=  FakerLibrary.Job
    # ${desc}=   FakerLibrary.City

    ${resp}=  Create Enquiry  ${locId}  ${pcid13}  category=${category1}   # title=${title}  description=${desc}  isLeadAutogenerate=${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id1}        ${resp.json()['id']}
    Set Test Variable   ${en_uid1}        ${resp.json()['uid']}

    ${resp}=  Create Enquiry  ${locId}  ${pcid14}  category=${category1}   # title=${title}  description=${desc}  isLeadAutogenerate=${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id2}        ${resp.json()['id']}
    Set Test Variable   ${en_uid2}        ${resp.json()['uid']}

    ${resp}=  Get Enquiry with filter 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id2}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid2}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid14}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId}



    Should Be Equal As Strings  ${resp.json()[1]['id']}   ${en_id1}
    Should Be Equal As Strings  ${resp.json()[1]['uid']}   ${en_uid1}
    Should Be Equal As Strings  ${resp.json()[1]['customer']['id']}   ${pcid13}
    Should Be Equal As Strings  ${resp.json()[1]['location']['id']}   ${locId}

    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Create Enquiry For Branch-UH18
    [Documentation]   Create Multiple enquiries for same customer in different locations. 

    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${fname1}   ${resp.json()['firstName']}
    Set Test Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
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

    ${locId1}=  Create Sample Location
    clear_customer   ${PUSERNAME26}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}   firstName=${fname1}  lastName=${lname1}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    # ${title}=  FakerLibrary.Job
    # ${desc}=   FakerLibrary.City

    ${resp}=  Create Enquiry  ${locId}  ${pcid13}  category=${category1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id1}        ${resp.json()['id']}
    Set Test Variable   ${en_uid1}        ${resp.json()['uid']}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Suite Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Suite Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END
  
    ${resp}=  Get Enquiry by Uuid  ${en_uid1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id1}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid1}
    Set Test Variable  ${Enquiryid}  ${resp.json()['enquireId']}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id0}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name0}
  
    # ${en_id1_str}=    Evaluate    f'{${en_id1}:05d}'
    # Log  ${en_id1_str}
    ${ACTIVE_ENQUIRE_FOR_CUSTOMER}=  Format String  ${ACTIVE_ENQUIRE_FOR_CUSTOMER}  ${fname1} ${lname1}   ${Enquiryid}   ${status_name0}  

    ${resp}=  Create Enquiry  ${locId1}  ${pcid13}  category=${category1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${ACTIVE_ENQUIRE_FOR_CUSTOMER}


  
JD-TC-Create Enquiry For Branch-UH19
    [Documentation]   Create Multiple enquiries with same details. 

    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${fname1}   ${resp.json()['firstName']}
    Set Test Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
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
    clear_customer   ${PUSERNAME26}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}  firstName=${fname1}  lastName=${lname1}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City

    ${resp}=  Create Enquiry  ${locId}  ${pcid13}  category=${category1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id1}        ${resp.json()['id']}
    Set Test Variable   ${en_uid1}        ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id1}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid1}
    Set Test Variable  ${Enquiryid}  ${resp.json()['enquireId']}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id0}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name0}
  
    # ${en_id1_str}=    Evaluate    f'{${en_id1}:05d}'
    # Log  ${en_id1_str}
    ${ACTIVE_ENQUIRE_FOR_CUSTOMER}=  Format String  ${ACTIVE_ENQUIRE_FOR_CUSTOMER}  ${fname1} ${lname1}   ${Enquiryid}   ${status_name0}  

    ${resp}=  Create Enquiry  ${locId}  ${pcid13}  category=${category1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${ACTIVE_ENQUIRE_FOR_CUSTOMER}


JD-TC-Create Enquiry For Branch-11
    [Documentation]   Create Enquiry with all details and check task creation and lead creation.
    Comment   Task status changed using Change Task Status to Complete

    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

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
    clear_customer   ${PUSERNAME26}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
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
    
    ${resp}=  Get Task Category Type  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_task_catagory_id}=  Set Variable  ${random_catagories['id']}
    ${rand_task_catagory_name}=  Set Variable  ${random_catagories['name']}

    ${resp}=  Get Provider Enquiry Type  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_cat_types}=  Set Variable  ${resp.json()}
    ${random_cat_types}=  Evaluate  random.choice($en_cat_types)  random
    ${rand_cat_type_id}=  Set Variable  ${random_cat_types['id']}
    ${rand_cat_type_name}=  Set Variable  ${random_cat_types['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_cat_types}=  Set Variable  ${resp.json()}
    ${random_cat_types}=  Evaluate  random.choice($task_cat_types)  random
    ${rand_task_cat_type_id}=  Set Variable  ${random_cat_types['id']}
    ${rand_task_cat_type_name}=  Set Variable  ${random_cat_types['name']}

    ${resp}=    Get Task Priority
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_prios}=  Set Variable  ${resp.json()}
    ${random_priority}=  Evaluate  random.choice($task_prios)  random
    ${rand_task_priority_id}=  Set Variable  ${random_priority['id']}
    ${rand_task_priority_name}=  Set Variable  ${random_priority['name']}

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

    # enquiryTemplate  ${account_id}  ${en_temp_name}  ${enq_sts_new_id}  category_id=${rand_catagory_id}  type_id=${rand_cat_type_id}  creator_provider_id=${provider_id} 

    ${resp}=  Get Enquiry Template  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${en_temp_id}  ${resp.json()[0]['id']}

    taskTemplate  ${account_id}  ${task_temp_name1}  ${new_status_id}  origin_from=3  origin_id=${en_temp_id}  category_id=${rand_task_catagory_id}  type_id=${rand_task_cat_type_id}  priority_id=${rand_task_priority_id}  creator_provider_id=${provider_id}

    taskTemplate  ${account_id}  ${task_temp_name2}  ${new_status_id}  origin_from=3  origin_id=${en_temp_id}  category_id=${rand_task_catagory_id}  type_id=${rand_task_cat_type_id}  priority_id=${rand_task_priority_id}  creator_provider_id=${provider_id}

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${category}=  Create Dictionary   id=${rand_catagory_id}
    ${type}=  Create Dictionary   id=${rand_cat_type_id}

    ${resp}=  Create Enquiry  ${locId}  ${pcid13}  title=${title}  description=${desc}  category=${category}  type=${type}  enquireMasterId=${en_temp_id}  leadMasterId=${ld_temp_id}  isLeadAutogenerate=${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id}   ${resp.json()['id']}
    Set Test Variable   ${en_uid}   ${resp.json()['uid']}

    ${resp}=  Get Enquiry with filter 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()['type']['id']}   ${rand_cat_type_id}
    Should Be Equal As Strings  ${resp.json()['type']['name']}   ${rand_cat_type_name}
    Should Be Equal As Strings  ${resp.json()['category']['id']}   ${rand_catagory_id}
    Should Be Equal As Strings  ${resp.json()['category']['name']}   ${rand_catagory_name}

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

    comment  Task doesn't get created by default anymore.

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

    ${resp}=    Get Task Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        IF   '${resp.json()[${i}]['name']}' == 'Completed'

            Set Suite Variable  ${status_id}    ${resp.json()[${i}]['id']}
            Set Suite Variable  ${status_name}  ${resp.json()[${i}]['name']}

        END
    END
    # Set Suite Variable  ${status_id1}    ${resp.json()[0]['id']}
    # Set Suite Variable  ${status_name1}  ${resp.json()[0]['name']}
    # Set Suite Variable  ${status_id2}    ${resp.json()[1]['id']}
    # Set Suite Variable  ${status_name2}  ${resp.json()[1]['name']}
    # Set Suite Variable  ${status_id3}    ${resp.json()[2]['id']}
    # Set Suite Variable  ${status_name3}  ${resp.json()[2]['name']}
    # Set Suite Variable  ${status_id4}    ${resp.json()[3]['id']}
    # Set Suite Variable  ${status_name4}  ${resp.json()[3]['name']}
    # Set Suite Variable  ${status_id5}    ${resp.json()[4]['id']}
    # Set Suite Variable  ${status_name5}  ${resp.json()[4]['name']}

    # Comment   Changing task status with status change url (Change Task Status) does not change the enquiry status no. have to use the closed url (Change Task Status to Complete).

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

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Lead Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    Set Test Variable  ${lead_status_name}  ${resp.json()[0]['name']}

    ${resp}=    Get Leads With Filter    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()[0]['status']['name']}    ${lead_status_name}


JD-TC-Create Enquiry For Branch-12
    [Documentation]   Create Enquiry with all details and check task creation  

    Comment   Task status changed using Change Task Status

    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

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
    clear_customer   ${PUSERNAME26}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME20}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME20}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
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
    
    ${resp}=  Get Task Category Type  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_task_catagory_id}=  Set Variable  ${random_catagories['id']}
    ${rand_task_catagory_name}=  Set Variable  ${random_catagories['name']}

    ${resp}=  Get Provider Enquiry Type  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_cat_types}=  Set Variable  ${resp.json()}
    ${random_cat_types}=  Evaluate  random.choice($en_cat_types)  random
    ${rand_cat_type_id}=  Set Variable  ${random_cat_types['id']}
    ${rand_cat_type_name}=  Set Variable  ${random_cat_types['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_cat_types}=  Set Variable  ${resp.json()}
    ${random_cat_types}=  Evaluate  random.choice($task_cat_types)  random
    ${rand_task_cat_type_id}=  Set Variable  ${random_cat_types['id']}
    ${rand_task_cat_type_name}=  Set Variable  ${random_cat_types['name']}

    ${resp}=    Get Task Priority
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_prios}=  Set Variable  ${resp.json()}
    ${random_priority}=  Evaluate  random.choice($task_prios)  random
    ${rand_task_priority_id}=  Set Variable  ${random_priority['id']}
    ${rand_task_priority_name}=  Set Variable  ${random_priority['name']}

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

    # ${lead_template_name}=   FakerLibrary.Domain Word
    # leadTemplate   ${account_id}  ${lead_template_name}  ${lead_sts_new_id}  category_id=${rand_lead_cat_id}  type_id=${rand_lead_cat_type_id}  priority_id=${rand_lead_priority_id}  creator_provider_id=${provider_id} 

    ${resp}=    Get Lead Templates    
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${ld_temp_id}  ${resp.json()[0]['id']}

    # enquiryTemplate  ${account_id}  "Enquiry"   ${enq_sts_new_id}  category_id=${rand_catagory_id}  type_id=${rand_cat_type_id}  creator_provider_id=${provider_id} 

    ${resp}=  Get Enquiry Template  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${en_temp_id}  ${resp.json()[0]['id']}

    ${resp}=  Get Lead Status
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Suite Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Suite Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END

    Log   ${status_id1}
    Log   ${status_name1}
    
   

    # taskTemplate  ${account_id}  ${task_temp_name1}  ${new_status_id}  origin_from=3  origin_id=${en_temp_id}  category_id=${rand_task_catagory_id}  type_id=${rand_task_cat_type_id}  priority_id=${rand_task_priority_id}  creator_provider_id=${provider_id}
    # setOrigin  crm_task_master_tbl   origin_from  3  template_name   ${task_temp_name1}  account  ${account_id}
    # setOrigin  crm_task_master_tbl   origin_id  ${en_temp_id}  template_name   ${task_temp_name1}  account  ${account_id}

    # taskTemplate  ${account_id}  ${task_temp_name2}  ${new_status_id}  origin_from=3  origin_id=${en_temp_id}  category_id=${rand_task_catagory_id}  type_id=${rand_task_cat_type_id}  priority_id=${rand_task_priority_id}  creator_provider_id=${provider_id}
    # setOrigin  crm_task_master_tbl   origin_from  3  template_name   ${task_temp_name2}  account  ${account_id}
    # setOrigin  crm_task_master_tbl   origin_id  ${en_temp_id}  template_name   ${task_temp_name2}  account  ${account_id}

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${category}=  Create Dictionary   id=${rand_catagory_id}
    ${type}=  Create Dictionary   id=${rand_cat_type_id}

    ${resp}=  Create Enquiry  ${locId}  ${pcid13}  title=${title}  description=${desc}  category=${category}  type=${type}  enquireMasterId=${en_temp_id}  leadMasterId=${ld_temp_id}  isLeadAutogenerate=${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id}   ${resp.json()['id']}
    Set Test Variable   ${en_uid}   ${resp.json()['uid']}

    ${resp}=  Get Enquiry with filter 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()['type']['id']}   ${rand_cat_type_id}
    Should Be Equal As Strings  ${resp.json()['type']['name']}   ${rand_cat_type_name}
    Should Be Equal As Strings  ${resp.json()['category']['id']}   ${rand_catagory_id}
    Should Be Equal As Strings  ${resp.json()['category']['name']}   ${rand_catagory_name}

    sleep  2s

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

    comment  Task doesn't get created by default anymore.

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

    ${resp}=    Get Task Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    # Set Suite Variable  ${status_id}    ${resp.json()[${len-1}]['id']}
    # Set Suite Variable  ${status_name}  ${resp.json()[${len-1}]['name']}
    FOR   ${i}  IN RANGE   ${len}
        IF   '${resp.json()[${i}]['name']}' == 'Completed'

            Set Suite Variable  ${status_id}    ${resp.json()[${i}]['id']}
            Set Suite Variable  ${status_name}  ${resp.json()[${i}]['name']}

        END
    END
    # Set Suite Variable  ${status_id1}    ${resp.json()[0]['id']}
    # Set Suite Variable  ${status_name1}  ${resp.json()[0]['name']}
    # Set Suite Variable  ${status_id2}    ${resp.json()[1]['id']}
    # Set Suite Variable  ${status_name2}  ${resp.json()[1]['name']}
    # Set Suite Variable  ${status_id3}    ${resp.json()[2]['id']}
    # Set Suite Variable  ${status_name3}  ${resp.json()[2]['name']}
    # Set Suite Variable  ${status_id4}    ${resp.json()[3]['id']}
    # Set Suite Variable  ${status_name4}  ${resp.json()[3]['name']}
    # Set Suite Variable  ${status_id5}    ${resp.json()[4]['id']}
    # Set Suite Variable  ${status_name5}  ${resp.json()[4]['name']}

    # Comment   Changing task status with status change url (Change Task Status) does not change the enquiry status. have to use the "closed" url (Change Task Status to Complete).

    # ${resp}=    Change Task Status   ${task_uid1}  ${status_id}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Change Task Status   ${task_uid2}  ${status_id}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Change Task Status to Complete   ${task_uid1}  
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Change Task Status to Complete   ${task_uid2}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Provider Tasks  originUid-eq=${en_uid}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[1]['title']}   ${task_temp_name1}
    # Should Be Equal As Strings  ${resp.json()[1]['status']['name']}   ${status_name}

    # Should Be Equal As Strings  ${resp.json()[0]['title']}   ${task_temp_name2}
    # Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${status_name}

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Change Enquiry Status   ${en_uid}  10
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Lead Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
   
    ${resp}=    Get Leads With Filter    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    

JD-TC-Create Enquiry For Branch-13
    [Documentation]   Create Enquiry with empty title
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

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
    clear_customer   ${PUSERNAME26}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    ${resp}=  Create Enquiry  ${locId}  ${pcid13}  title=${EMPTY}  category=${category1}     
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id}   ${resp.json()['id']}
    Set Test Variable   ${en_uid}   ${resp.json()['uid']}

JD-TC-Create Enquiry For Branch-14
    [Documentation]   Create Enquiry with empty description
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

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
    clear_customer   ${PUSERNAME26}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    ${title}=  FakerLibrary.Job
    ${resp}=  Create Enquiry  ${locId}  ${pcid13}  title=${title}   description=${EMPTY}  category=${category1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id}   ${resp.json()['id']}
    Set Test Variable   ${en_uid}   ${resp.json()['uid']}


JD-TC-Create Enquiry For Branch-15
    [Documentation]   Create Enquiry with empty lead master id (lead template id) when isLeadAutogenerate is off
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

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
    clear_customer   ${PUSERNAME26}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    # ${en_temp_id}=  FakerLibrary.Numerify  %%%
    ${resp}=  Create Enquiry  ${locId}  ${pcid13}  title=${title}   description=${desc}  leadMasterId=${EMPTY}  isLeadAutogenerate=${bool[0]}  category=${category1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id}   ${resp.json()['id']}
    Set Test Variable   ${en_uid}   ${resp.json()['uid']}


JD-TC-Create Enquiry For Branch-16
    [Documentation]   Create Enquiry and check task and lead creation with just enquireMasterId, leadMasterId and isLeadAutogenerate enabled
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

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
    clear_customer   ${PUSERNAME26}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    ${resp}=    Get Task Master With Filter
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Templates    
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${ld_temp_id}  ${resp.json()[0]['id']}

    ${resp}=  Get Enquiry Template  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${en_temp_id}  ${resp.json()[0]['id']}

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    # ${ld_temp_id}=  FakerLibrary.Numerify  %%%
    ${resp}=  Create Enquiry  ${locId}  ${pcid13}  title=${title}   description=${desc}  enquireMasterId=${en_temp_id}  leadMasterId=${ld_temp_id}  isLeadAutogenerate=${bool[1]}  category=${category1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id}   ${resp.json()['id']}
    Set Test Variable   ${en_uid}   ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    comment  Task doesn't get created by default anymore. instead its changed to status. change status of enquiry.

    ${resp}=    Get Provider Tasks  originUid-eq=${en_uid}
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

    # ${resp}=    Get Provider Tasks  originUid-eq=${en_uid}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[1]['title']}   ${task_temp_name1}
    # Should Be Equal As Strings  ${resp.json()[1]['status']['name']}   ${status_name}

    # Should Be Equal As Strings  ${resp.json()[0]['title']}   ${task_temp_name2}
    # Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${status_name}

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
  

JD-TC-Create Enquiry For Branch-UH1
    [Documentation]   Create Enquiry with a consumer's jaldee consumer id

    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

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

    ${resp}=  Create Enquiry  ${locId}  ${jdconID}   category=${category1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${INVALID_CONSUMER_ID}


JD-TC-Create Enquiry For Branch-UH2
    [Documentation]   Create Enquiry with another provider's customer id
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
    ELSE
        Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
    END
    clear_customer   ${PUSERNAME27}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13-1}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13-1}  ${resp.json()[0]['id']}
    END

    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${account_id}  ${resp.json()['id']}

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

    ${resp}=  Create Enquiry  ${locId}  ${pcid13-1}    category=${category1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${INVALID_CONSUMER_ID}


JD-TC-Create Enquiry For Branch-UH3
    [Documentation]   Create Enquiry with another provider's location id
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
    ELSE
        Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
    END

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    # Log  ${resp.content}
    # Should Be Equal As Strings      ${resp.status_code}  200
    # IF   '${resp.content}' == '${emptylist}'
    #     ${resp1}=  AddCustomer  ${CUSERNAME13}
    #     Log  ${resp1.content}
    #     Should Be Equal As Strings  ${resp1.status_code}  200
    #     Set Test Variable  ${pcid13-1}   ${resp1.json()}
    # ELSE
    #     Set Test Variable  ${pcid13-1}  ${resp.json()[0]['id']}
    # END

    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${account_id}  ${resp.json()['id']}

    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # IF   '${resp.content}' == '${emptylist}'
    #     ${locId}=  Create Sample Location
    # ELSE
    #     Set Test Variable  ${locId}  ${resp.json()[0]['id']}
    # END
    clear_customer   ${PUSERNAME26}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    ${resp}=  Create Enquiry  ${locId1}  ${pcid13}    category=${category1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${INVALID_BUSS_LOC_ID}


JD-TC-Create Enquiry For Branch-UH4
    [Documentation]   Create Enquiry with invalid catagory
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

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
    clear_customer   ${PUSERNAME26}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END


    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${rand_catagory_id}=  FakerLibrary.Numerify  %%%%
    ${category}=  Create Dictionary   id=${rand_catagory_id}
    ${resp}=  Create Enquiry  ${locId}  ${pcid13}  title=${title}   description=${desc}  category=${category}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${INVALID_CATEGORY_ID}


JD-TC-Create Enquiry For Branch-UH5
    [Documentation]   Create Enquiry with empty catagory
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

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
    clear_customer   ${PUSERNAME26}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    # ${category}=  FakerLibrary.Numerify  %%%%
    ${category}=  Create Dictionary   id=${NONE}
    ${resp}=  Create Enquiry  ${locId}  ${pcid13}  title=${title}   description=${desc}  category=${category}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${CATEGORY_REQUIRES}


JD-TC-Create Enquiry For Branch-UH6
    [Documentation]   Create Enquiry with invalid type
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

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
    clear_customer   ${PUSERNAME26}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${rand_cat_type_id}=  FakerLibrary.Numerify  %%%%
    ${type}=  Create Dictionary   id=${rand_cat_type_id}
    ${resp}=  Create Enquiry  ${locId}  ${pcid13}  title=${title}   description=${desc}  type=${type}  category=${category1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${INVALID_TYPE_ID}


JD-TC-Create Enquiry For Branch-UH7
    [Documentation]   Create Enquiry with empty type
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

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
    clear_customer   ${PUSERNAME26}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    # ${type}=  FakerLibrary.Numerify  %%%
    ${type}=  Create Dictionary   id=${NONE}
    ${resp}=  Create Enquiry  ${locId}  ${pcid13}  title=${title}   description=${desc}  type=${type}  category=${category1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()}  ${INVALID_TYPE_ID}


JD-TC-Create Enquiry For Branch-UH8
    [Documentation]   Create Enquiry with invalid enquire template id
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

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
    clear_customer   ${PUSERNAME26}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    ${INVALID_ENQUIRE_TEMPLATE_ID}=   Replace String  ${INVALID_LEAD_ID}  {}  Enquire template

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${en_temp_id}=  FakerLibrary.Numerify  %%%%
    ${resp}=  Create Enquiry  ${locId}  ${pcid13}  title=${title}   description=${desc}  enquireMasterId=${en_temp_id}  category=${category1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${INVALID_ENQUIRE_TEMPLATE_ID}


JD-TC-Create Enquiry For Branch-UH9
    [Documentation]   Create Enquiry with empty enquire template id
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

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
    clear_customer   ${PUSERNAME26}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    ${INVALID_ENQUIRE_TEMPLATE_ID}=   Replace String  ${INVALID_LEAD_ID}  {}  Enquire template

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    # ${en_temp_id}=  FakerLibrary.Numerify  %%%
    ${resp}=  Create Enquiry  ${locId}  ${pcid13}  title=${title}   description=${desc}  enquireMasterId=${EMPTY}  category=${category1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()}  ${INVALID_ENQUIRE_TEMPLATE_ID}


JD-TC-Create Enquiry For Branch-UH10
    [Documentation]   Create Enquiry with empty lead master id (lead template id) when isLeadAutogenerate is on
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

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
    clear_customer   ${PUSERNAME26}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    # ${en_temp_id}=  FakerLibrary.Numerify  %%%
    ${resp}=  Create Enquiry  ${locId}  ${pcid13}  title=${title}   description=${desc}  leadMasterId=${EMPTY}  isLeadAutogenerate=${bool[1]}  category=${category1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${ENQUIRE_PRODUCT_REQUIRED}


JD-TC-Create Enquiry For Branch-UH11
    [Documentation]   Create Enquiry with invalid lead master id (lead template id) when isLeadAutogenerate is on
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

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
    clear_customer   ${PUSERNAME26}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    ${INVALID_LEAD_TEMPLATE_ID}=   Replace String  ${INVALID_LEAD_ID}  {}  Lead template

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${ld_temp_id}=  FakerLibrary.Numerify  %%%%
    ${resp}=  Create Enquiry  ${locId}  ${pcid13}  title=${title}   description=${desc}  leadMasterId=${ld_temp_id}  isLeadAutogenerate=${bool[1]}  category=${category1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${INVALID_LEAD_TEMPLATE_ID}


JD-TC-Create Enquiry For Branch-UH12
    [Documentation]   Create Enquiry without login
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

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
    clear_customer   ${PUSERNAME26}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    # ${ld_temp_id}=  FakerLibrary.Numerify  %%%
    ${resp}=  Create Enquiry  ${locId}  ${pcid13}  title=${title}   description=${desc}  category=${category1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-Create Enquiry For Branch-UH13
    [Documentation]   Create Enquiry by consumer login
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

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
    clear_customer   ${PUSERNAME26}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    # ${ld_temp_id}=  FakerLibrary.Numerify  %%%
    ${resp}=  Create Enquiry  ${locId}  ${pcid13}  title=${title}   description=${desc}  category=${category1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-Create Enquiry For Branch-UH14
    [Documentation]   Create Enquiry with another branch's category
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable  ${provider_id1}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  categorytype  ${account_id1}
    ${resp}=  tasktype      ${account_id1}

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id1}=  Set Variable  ${random_catagories['id']}
    ${rand_catagory_name1}=  Set Variable  ${random_catagories['name']}

    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable  ${provider_id}  ${resp.json()['id']}

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
    clear_customer   ${PUSERNAME26}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    ${category}=  Create Dictionary   id=${rand_catagory_id1}
    ${resp}=  Create Enquiry  ${locId}  ${pcid13}   category=${category}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${INVALID_CATEGORY_ID}


JD-TC-Create Enquiry For Branch-UH15
    [Documentation]   Create Enquiry with another branch's type
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable  ${provider_id1}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    # ${resp}=  categorytype  ${account_id}
    # ${resp}=  tasktype      ${account_id}

    ${resp}=  Get Provider Enquiry Type  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_cat_types}=  Set Variable  ${resp.json()}
    ${random_cat_types}=  Evaluate  random.choice($en_cat_types)  random
    ${rand_cat_type_id1}=  Set Variable  ${random_cat_types['id']}
    ${rand_cat_type_name1}=  Set Variable  ${random_cat_types['name']}

    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable  ${provider_id}  ${resp.json()['id']}

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
    clear_customer   ${PUSERNAME26}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    ${type}=  Create Dictionary   id=${rand_cat_type_id1}
    ${resp}=  Create Enquiry  ${locId}  ${pcid13}   type=${type}  category=${category1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${INVALID_TYPE_ID}


JD-TC-Create Enquiry For Branch-UH16
    [Documentation]   Create Enquiry with another branch's enquiry template id
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id1}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id1}=  Set Variable  ${random_catagories['id']}
    ${rand_catagory_name1}=  Set Variable  ${random_catagories['name']}

    ${resp}=  Get Provider Enquiry Type  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_cat_types}=  Set Variable  ${resp.json()}
    ${random_cat_types}=  Evaluate  random.choice($en_cat_types)  random
    ${rand_cat_type_id1}=  Set Variable  ${random_cat_types['id']}
    ${rand_cat_type_name1}=  Set Variable  ${random_cat_types['name']}

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

    enquiryTemplate  ${account_id1}  ${en_temp_name}  ${enq_sts_new_id}  category_id=${rand_catagory_id1}  type_id=${rand_cat_type_id1}  creator_provider_id=${provider_id1}

    ${resp}=  Get Enquiry Template  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${en_temp_id1}  ${resp.json()[0]['id']}

    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable  ${provider_id}  ${resp.json()['id']}

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
    clear_customer   ${PUSERNAME26}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    ${INVALID_ENQUIRE_TEMPLATE_ID}=   Replace String  ${INVALID_LEAD_ID}  {}  Enquire template

    ${resp}=  Create Enquiry  ${locId}  ${pcid13}   enquireMasterId=${en_temp_id1}  category=${category1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${INVALID_ENQUIRE_TEMPLATE_ID}


JD-TC-Create Enquiry For Branch-UH17
    [Documentation]   Create Enquiry with another branch's lead template id
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id1}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

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
    leadTemplate   ${account_id1}  ${lead_template_name}  ${lead_sts_new_id}  category_id=${rand_lead_cat_id}  type_id=${rand_lead_cat_type_id}  priority_id=${rand_lead_priority_id}  creator_provider_id=${provider_id1} 

    ${resp}=    Get Lead Templates    
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${ld_temp_id1}  ${resp.json()[0]['id']}

    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable  ${provider_id}  ${resp.json()['id']}

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
    clear_customer   ${PUSERNAME26}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    ${INVALID_LEAD_TEMPLATE_ID}=   Replace String  ${INVALID_LEAD_ID}  {}  Lead template

    ${resp}=  Create Enquiry  ${locId}  ${pcid13}   leadMasterId=${ld_temp_id1}   isLeadAutogenerate=${bool[1]}  category=${category1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${INVALID_LEAD_TEMPLATE_ID}