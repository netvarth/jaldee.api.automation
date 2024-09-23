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
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Variables ***
${self}      0
@{emptylist}


*** Keywords ***
Multiple Users Accounts

    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
    ${multiuser_list}=  Create List
    &{License_total}=  Create Dictionary
    
    FOR   ${a}  IN RANGE   ${length}   
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        
        ${resp1}=   Get Active License
        Log  ${resp1.content}
        Should Be Equal As Strings    ${resp1.status_code}   200
        ${name}=  Set Variable  ${resp1.json()['accountLicense']['displayName']}

        ${resp}=   Get License UsageInfo 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF  ${resp.json()['metricUsageInfo'][8]['total']} > 1 and ${resp.json()['metricUsageInfo'][8]['used']} < ${resp.json()['metricUsageInfo'][8]['total']}
            Append To List  ${multiuser_list}  ${PUSERNAME${a}}
            Set To Dictionary 	${License_total} 	${name}=${resp.json()['metricUsageInfo'][8]['total']}
        END
    END

    RETURN  ${multiuser_list}



*** Test Cases ***
JD-TC-Update Enquiry For User-1
    [Documentation]   Create Enquiry for a User.

    ${multiusers}=    Multiple Users Accounts
    Log   ${multiusers}
    ${pro_len}=  Get Length   ${multiusers}
    ${BUSER}=  Random Element    ${multiusers}
    Set Suite Variable  ${BUSER}

    ${resp}=   Encrypted Provider Login  ${BUSER}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    clear_customer   ${BUSER}
    ${resp}=   Get Active License
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

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
        {dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${BUSER}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id}=  Create Sample User
    Set Test Variable  ${u_id}

    ${resp}=  Get User By Id  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}

    ${resp}=  SendProviderResetMail   ${BUSER_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BUSER_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=   Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id}  ${decrypted_data['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

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

    ${resp}=  enquiryTemplate  ${account_id}  "Enquiry"   ${enq_sts_new_id}  category_id=${rand_catagory_id}  type_id=${rand_cat_type_id}  creator_provider_id=${provider_id} 

    ${resp}=  Get Enquiry Template
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${category}=  Create Dictionary   id=${rand_catagory_id}

    ${resp}=  Create Enquiry  ${locId}  ${pcid18}  category=${category}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id}   ${resp.json()['id']}
    Set Test Variable   ${en_uid}   ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}

    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

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

JD-TC-Update Enquiry For User-2
    [Documentation]   Update Enquiry for a User with a different customer.

    ${resp}=   Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END
    clear_customer   ${BUSER}

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME17}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid19}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid19}  ${resp.json()[0]['id']}
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

    ${resp}=  Create Enquiry  ${locId}  ${pcid18}  category=${category}  
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
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}

    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${category}=  Create Dictionary   id=${rand_catagory_id}
    ${type}=  Create Dictionary   id=${rand_cat_type_id}
    ${status}=  Create Dictionary   id=${rand_status_id}
    ${priority}=  Create Dictionary   id=${rand_priority_id}

    ${resp}=  Update Enquiry  ${en_uid}  ${locId}  ${pcid19}  title=${title}  description=${desc}  category=${category}  type=${type}  status=${status}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid19}
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


JD-TC-Update Enquiry For User-3
    [Documentation]   Update Enquiry for a User with a different location.

    ${resp}=   Encrypted Provider Login  ${BUSER}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${locId1}=  Create Sample Location

    ${resp}=   Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${locId}  ${resp.json()[0]['id']}
    # IF   '${resp.content}' == '${emptylist}'
    #     ${locId}=  Create Sample Location
    # ELSE
    #     Set Test Variable  ${locId}  ${resp.json()[0]['id']}
    # END
    clear_customer   ${BUSER}

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

    ${resp}=  Create Enquiry  ${locId}  ${pcid18}  category=${category}  
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
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}

    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${category}=  Create Dictionary   id=${rand_catagory_id}
    ${type}=  Create Dictionary   id=${rand_cat_type_id}
    ${status}=  Create Dictionary   id=${rand_status_id}
    ${priority}=  Create Dictionary   id=${rand_priority_id}

    ${resp}=  Update Enquiry  ${en_uid}  ${locId1}  ${pcid18}  title=${title}  description=${desc}  category=${category}  type=${type}  status=${status}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid18}
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

JD-TC-Update Enquiry For User-4
    [Documentation]   Update Enquiry twice with same details.

    ${resp}=   Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${locId}  ${resp.json()[0]['id']}
    # IF   '${resp.content}' == '${emptylist}'
    #     ${locId}=  Create Sample Location
    # ELSE
    #     Set Test Variable  ${locId}  ${resp.json()[0]['id']}
    # END
    clear_customer   ${BUSER}


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

    ${resp}=  Create Enquiry  ${locId}  ${pcid18}  category=${category}  
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
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}

    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

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


JD-TC-Update Enquiry For User-UH1
    [Documentation]   Update Enquiry without catagory.

    ${resp}=   Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${locId}  ${resp.json()[0]['id']}
    # IF   '${resp.content}' == '${emptylist}'
    #     ${locId}=  Create Sample Location
    # ELSE
    #     Set Test Variable  ${locId}  ${resp.json()[0]['id']}
    # END
    clear_customer   ${BUSER}


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

    ${resp}=  Create Enquiry  ${locId}  ${pcid18}  category=${category}  
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
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}

    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${category}=  Create Dictionary   id=${rand_catagory_id}
    ${type}=  Create Dictionary   id=${rand_cat_type_id}
    ${status}=  Create Dictionary   id=${rand_status_id}
    ${priority}=  Create Dictionary   id=${rand_priority_id}

    ${resp}=  Update Enquiry  ${en_uid}  ${locId}  ${pcid18}  title=${title}  description=${desc}  type=${type}  status=${status}  priority=${priority}
    Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${CATEGORY_REQUIRES}


    # ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    # Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    # Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    # Should Be Equal As Strings  ${resp.json()['customer']['id']}   ${pcid18}
    # Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}
    # Should Be Equal As Strings  ${resp.json()['title']}   ${title}
    # Should Be Equal As Strings  ${resp.json()['description']}   ${desc}
    # Should Be Equal As Strings  ${resp.json()['type']['id']}   ${rand_cat_type_id}
    # Should Be Equal As Strings  ${resp.json()['type']['name']}   ${rand_cat_type_name}
    # # Should Be Equal As Strings  ${resp.json()['category']['id']}   ${rand_catagory_id}
    # # Should Be Equal As Strings  ${resp.json()['category']['name']}   ${rand_catagory_name}
    # Should Be Equal As Strings  ${resp.json()['status']['id']}   ${rand_status_id}
    # Should Be Equal As Strings  ${resp.json()['status']['name']}   ${rand_status_name}
    # Should Be Equal As Strings  ${resp.json()['priority']['id']}   ${rand_priority_id}
    # Should Be Equal As Strings  ${resp.json()['priority']['name']}   ${rand_priority_name}


JD-TC-Update Enquiry For User-6
    [Documentation]   Update Enquiry without catagory type.

    ${resp}=   Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${locId}  ${resp.json()[0]['id']}
    # IF   '${resp.content}' == '${emptylist}'
    #     ${locId}=  Create Sample Location
    # ELSE
    #     Set Test Variable  ${locId}  ${resp.json()[0]['id']}
    # END
    clear_customer   ${BUSER}

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

    ${resp}=  Create Enquiry  ${locId}  ${pcid18}  category=${category}  
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
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}

    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${category}=  Create Dictionary   id=${rand_catagory_id}
    ${type}=  Create Dictionary   id=${rand_cat_type_id}
    ${status}=  Create Dictionary   id=${rand_status_id}
    ${priority}=  Create Dictionary   id=${rand_priority_id}

    ${resp}=  Update Enquiry  ${en_uid}  ${locId}  ${pcid18}  title=${title}  description=${desc}  category=${category}  status=${status}  priority=${priority}
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
    # Should Be Equal As Strings  ${resp.json()['type']['id']}   ${rand_cat_type_id}
    # Should Be Equal As Strings  ${resp.json()['type']['name']}   ${rand_cat_type_name}
    Should Be Equal As Strings  ${resp.json()['category']['id']}   ${rand_catagory_id}
    Should Be Equal As Strings  ${resp.json()['category']['name']}   ${rand_catagory_name}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${rand_status_id}
    Should Be Equal As Strings  ${resp.json()['status']['name']}   ${rand_status_name}
    Should Be Equal As Strings  ${resp.json()['priority']['id']}   ${rand_priority_id}
    Should Be Equal As Strings  ${resp.json()['priority']['name']}   ${rand_priority_name}



JD-TC-Update Enquiry For User-7
    [Documentation]   Update Enquiry without priority.

    ${resp}=   Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${locId}  ${resp.json()[0]['id']}
    # IF   '${resp.content}' == '${emptylist}'
    #     ${locId}=  Create Sample Location
    # ELSE
    #     Set Test Variable  ${locId}  ${resp.json()[0]['id']}
    # END
    clear_customer   ${BUSER}

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

    ${resp}=  Create Enquiry  ${locId}  ${pcid18}  category=${category}  
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
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}

    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${category}=  Create Dictionary   id=${rand_catagory_id}
    ${type}=  Create Dictionary   id=${rand_cat_type_id}
    ${status}=  Create Dictionary   id=${rand_status_id}
    ${priority}=  Create Dictionary   id=${rand_priority_id}

    ${resp}=  Update Enquiry  ${en_uid}  ${locId}  ${pcid18}  title=${title}  description=${desc}  category=${category}  type=${type}  status=${status}  
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
    # Should Be Equal As Strings  ${resp.json()['priority']['id']}   ${rand_priority_id}
    # Should Be Equal As Strings  ${resp.json()['priority']['name']}   ${rand_priority_name}

JD-TC-Update Enquiry For User-8
    [Documentation]   Update Enquiry without status.

    ${resp}=   Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${locId}  ${resp.json()[0]['id']}
    # IF   '${resp.content}' == '${emptylist}'
    #     ${locId}=  Create Sample Location
    # ELSE
    #     Set Test Variable  ${locId}  ${resp.json()[0]['id']}
    # END
    clear_customer   ${BUSER}


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

    ${resp}=  Create Enquiry  ${locId}  ${pcid18}  category=${category}  
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
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}

    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${category}=  Create Dictionary   id=${rand_catagory_id}
    ${type}=  Create Dictionary   id=${rand_cat_type_id}
    ${status}=  Create Dictionary   id=${rand_status_id}
    ${priority}=  Create Dictionary   id=${rand_priority_id}

    ${resp}=  Update Enquiry  ${en_uid}  ${locId}  ${pcid18}  title=${title}  description=${desc}  category=${category}  type=${type}    priority=${priority}
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
    # Should Be Equal As Strings  ${resp.json()['status']['id']}   ${rand_status_id}
    # Should Be Equal As Strings  ${resp.json()['status']['name']}   ${rand_status_name}
    Should Be Equal As Strings  ${resp.json()['priority']['id']}   ${rand_priority_id}
    Should Be Equal As Strings  ${resp.json()['priority']['name']}   ${rand_priority_name}


JD-TC-Update Enquiry For User-9
    [Documentation]   Update Enquiry with a different category.

    ${resp}=   Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${locId}  ${resp.json()[0]['id']}
    clear_customer   ${BUSER}

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


    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate    random.sample(${en_catagories}, 2)    random
    ${rand_catagory_id}=  Set Variable  ${random_catagories[0]['id']}
    ${rand_catagory_name}=  Set Variable  ${random_catagories[0]['name']}
    ${rand_catagory_id1}=  Set Variable  ${random_catagories[1]['id']}
    ${rand_catagory_name1}=  Set Variable  ${random_catagories[1]['name']}

    ${category}=  Create Dictionary   id=${rand_catagory_id}

    ${resp}=  Create Enquiry  ${locId}  ${pcid18}   category=${category}    
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
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}
    Should Be Equal As Strings  ${resp.json()['category']['id']}   ${rand_catagory_id}
    Should Be Equal As Strings  ${resp.json()['category']['name']}   ${rand_catagory_name}

    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${category1}=  Create Dictionary   id=${rand_catagory_id1}

    ${resp}=  Update Enquiry  ${en_uid}  ${locId}  ${pcid18}  category=${category1}
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
    Should Be Equal As Strings  ${resp.json()['category']['id']}   ${rand_catagory_id1}
    Should Be Equal As Strings  ${resp.json()['category']['name']}   ${rand_catagory_name1}


JD-TC-Update Enquiry For User-10
    [Documentation]   Update Enquiry with a different type.

    ${resp}=   Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${locId}  ${resp.json()[0]['id']}
    clear_customer   ${BUSER}

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

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id}=  Set Variable  ${random_catagories['id']}
    ${rand_catagory_name}=  Set Variable  ${random_catagories['name']}

    ${type}=  Create Dictionary   id=${rand_cat_type_id}
    ${category}=  Create Dictionary   id=${rand_catagory_id}

    ${resp}=  Create Enquiry  ${locId}  ${pcid18}   type=${type}  category=${category}
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
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}
    Should Be Equal As Strings  ${resp.json()['type']['id']}   ${rand_cat_type_id}
    Should Be Equal As Strings  ${resp.json()['type']['name']}   ${rand_cat_type_name}

    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${type1}=  Create Dictionary   id=${rand_cat_type_id1}

    ${resp}=  Update Enquiry  ${en_uid}  ${locId}  ${pcid18}  type=${type1}  category=${category}
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
    Should Be Equal As Strings  ${resp.json()['type']['id']}   ${rand_cat_type_id1}
    Should Be Equal As Strings  ${resp.json()['type']['name']}   ${rand_cat_type_name1}


JD-TC-Update Enquiry For User-11
    [Documentation]   Update Enquiry with a different priority.

    ${resp}=   Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${locId}  ${resp.json()[0]['id']}
    clear_customer   ${BUSER}

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

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id}=  Set Variable  ${random_catagories['id']}
    ${rand_catagory_name}=  Set Variable  ${random_catagories['name']}

    ${priority}=  Create Dictionary   id=${rand_priority_id}
    ${category}=  Create Dictionary   id=${rand_catagory_id}

    ${resp}=  Create Enquiry  ${locId}  ${pcid18}   priority=${priority}  category=${category}
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
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}
    Should Be Equal As Strings  ${resp.json()['priority']['id']}   ${rand_priority_id}
    Should Be Equal As Strings  ${resp.json()['priority']['name']}   ${rand_priority_name}

    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${priority1}=  Create Dictionary   id=${rand_priority_id1}

    ${resp}=  Update Enquiry  ${en_uid}  ${locId}  ${pcid18}  category=${category}  priority=${priority1}
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
    Should Be Equal As Strings  ${resp.json()['priority']['id']}   ${rand_priority_id1}
    Should Be Equal As Strings  ${resp.json()['priority']['name']}   ${rand_priority_name1}


JD-TC-Update Enquiry For User-UH2
    [Documentation]   Update Enquiry with isLeadAutogenerate as true when leadMasterId & enquireMasterId are not provided.

    ${resp}=   Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${locId}  ${resp.json()[0]['id']}
    clear_customer   ${BUSER}

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

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id}=  Set Variable  ${random_catagories['id']}
    ${rand_catagory_name}=  Set Variable  ${random_catagories['name']}
    
    ${category}=  Create Dictionary   id=${rand_catagory_id}

    ${resp}=  Create Enquiry  ${locId}  ${pcid18}  category=${category}
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
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId}

    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Enquiry  ${en_uid}  ${locId}  ${pcid18}  isLeadAutogenerate=${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${ENQUIRE_PRODUCT_REQUIRED}
