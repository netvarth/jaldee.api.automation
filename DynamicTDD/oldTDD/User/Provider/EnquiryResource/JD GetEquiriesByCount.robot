*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions
Force Tags        ENQUIRY
Library           Collections
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Variables ***
${self}      0
@{emptylist}

*** Keywords ***
Multiple Users branches

    ${resp}=   Get File    /ebs/TDD/varfiles/musers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
    ${multiuser_list}=  Create List
    &{License_total}=  Create Dictionary
    
    FOR   ${a}  IN RANGE   ${length}   
        ${resp}=  Encrypted Provider Login  ${MUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        
        ${resp1}=   Get Active License
        Log  ${resp1.content}
        Should Be Equal As Strings    ${resp1.status_code}   200
        ${name}=  Set Variable  ${resp1.json()['accountLicense']['displayName']}

        ${resp}=   Get License UsageInfo 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF  ${resp.json()['metricUsageInfo'][8]['total']} > 1 and ${resp.json()['metricUsageInfo'][8]['used']} < ${resp.json()['metricUsageInfo'][8]['total']}
            Append To List  ${multiuser_list}  ${MUSERNAME${a}}
            Set To Dictionary 	${License_total} 	${name}=${resp.json()['metricUsageInfo'][8]['total']}
        END
    END

    RETURN  ${multiuser_list}

*** Test Cases ***
JD-TC-Get Enquiries For Branch-1
    [Documentation]   Get Enquiries for a branch.

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login  ${MUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    clear_customer   ${MUSERNAME30}
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
    Set Suite Variable  ${locId1}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${loc_len}=  Get Length   ${resp.json()}
    FOR   ${i}  IN RANGE   ${loc_len}
        IF   '${resp.json()[${i}]['id']}'=='${locId}'
            Set Suite Variable  ${loc_name}  ${resp.json()[${i}]['place']}
        ELSE IF  '${resp.json()[${i}]['id']}'=='${locId1}'
            Set Suite Variable  ${loc_name1}  ${resp.json()[${i}]['place']}
        END
    END


    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME19}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid19}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid19}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME20}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME20}  firstName=${fname1}   lastName=${lname1}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid20}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid20}  ${resp.json()[0]['id']}
    END

    updateEnquiryStatus  ${account_id}
    ${resp}=  categorytype  ${account_id}
    ${resp}=  tasktype      ${account_id}

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories1}  ${random_catagories2} =   Evaluate    random.sample($en_catagories, 2)    random
    # ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id1}=  Set Variable  ${random_catagories1['id']}
    Set Suite Variable   ${rand_catagory_id1}
    ${rand_catagory_name1}=  Set Variable  ${random_catagories1['name']}
    Set Suite Variable  ${rand_catagory_name1}
    ${rand_catagory_id2}=  Set Variable  ${random_catagories2['id']}
    Set Suite Variable  ${rand_catagory_id2}
    ${rand_catagory_name2}=  Set Variable  ${random_catagories2['name']}
    Set Suite Variable  ${rand_catagory_name2}

    ${resp}=  Get Provider Enquiry Type  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_cat_types}=  Set Variable  ${resp.json()}
    ${random_cat_types1}  ${random_cat_types2} =   Evaluate    random.sample($en_cat_types, 2)    random
    # ${random_cat_types}=  Evaluate  random.choice($en_cat_types)  random
    ${rand_cat_type_id1}=  Set Variable  ${random_cat_types1['id']}
    Set Suite Variable  ${rand_cat_type_id1}
    ${rand_cat_type_name1}=  Set Variable  ${random_cat_types1['name']}
    Set Suite Variable  ${rand_cat_type_name1}
    ${rand_cat_type_id2}=  Set Variable  ${random_cat_types2['id']}
    Set Suite Variable  ${rand_cat_type_id2}
    ${rand_cat_type_name2}=  Set Variable  ${random_cat_types2['name']}
    Set Suite Variable  ${rand_cat_type_name2}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_statuses}=  Set Variable  ${resp.json()}
    ${random_status1}  ${random_status2} =   Evaluate    random.sample($en_statuses, 2)    random
    # ${random_status}=  Evaluate  random.choice($en_statuses)  random
    ${rand_status_id1}=  Set Variable  ${random_status1['id']}
    Set Suite Variable  ${rand_status_id1}
    ${rand_status_name1}=  Set Variable  ${random_status1['name']}
    Set Suite Variable  ${rand_status_name1}
    ${rand_status_id2}=  Set Variable  ${random_status2['id']}
    Set Suite Variable  ${rand_status_id2}
    ${rand_status_name2}=  Set Variable  ${random_status2['name']}
    Set Suite Variable  ${rand_status_name2}

    ${resp}=  Get Provider Enquiry Priority  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_prios}=  Set Variable  ${resp.json()}
    ${random_priority1}  ${random_priority2} =   Evaluate    random.sample($en_prios, 2)    random
    # ${random_priority}=  Evaluate  random.choice($en_prios)  random
    ${rand_priority_id1}=  Set Variable  ${random_priority1['id']}
    Set Suite Variable  ${rand_priority_id1}
    ${rand_priority_name1}=  Set Variable  ${random_priority1['name']}
    Set Suite Variable  ${rand_priority_name1}
    ${rand_priority_id2}=  Set Variable  ${random_priority2['id']}
    Set Suite Variable  ${rand_priority_id2}
    ${rand_priority_name2}=  Set Variable  ${random_priority2['name']}
    Set Suite Variable  ${rand_priority_name2}

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
    Set Suite Variable  ${ld_temp_id}  ${resp.json()[0]['id']}

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

    ${resp}=  enquiryTemplate  ${account_id}  "Enquiry1"  ${enq_sts_new_id}  category_id=${rand_catagory_id1}  type_id=${rand_cat_type_id1}  creator_provider_id=${provider_id}  
    ${resp}=  enquiryTemplate  ${account_id}  "Enquiry2"  ${enq_sts_new_id}  category_id=${rand_catagory_id2}  type_id=${rand_cat_type_id2}  creator_provider_id=${provider_id}  

    ${resp}=  Get Enquiry Template
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${en_temp_id1}  ${resp.json()[0]['id']}
    Set Suite Variable  ${en_temp_id2}  ${resp.json()[1]['id']}

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

    ${resp}=  taskTemplate  ${account_id}  "Follow Up 1"  ${new_status_id}  origin_from=3  origin_id=${en_temp_id2}  category_id=${rand_catagory_id1}  priority_id=${rand_priority_id1}  type_id=${rand_cat_type_id1}  creator_provider_id=${provider_id} 
    ${resp}=  taskTemplate  ${account_id}  "Follow Up 2"  ${new_status_id}  origin_from=3  origin_id=${en_temp_id1}  category_id=${rand_catagory_id2}  priority_id=${rand_priority_id2}  type_id=${rand_cat_type_id2}  creator_provider_id=${provider_id} 

    ${title}=  FakerLibrary.sentence
    Set Suite Variable  ${title}
    ${desc}=   FakerLibrary.City
    Set Suite Variable  ${desc}
    ${category1}=  Create Dictionary   id=${rand_catagory_id1}
    ${type1}=  Create Dictionary   id=${rand_cat_type_id1}
    ${status1}=  Create Dictionary   id=${rand_status_id1}
    ${priority1}=  Create Dictionary   id=${rand_priority_id1}

    ${resp}=  Create Enquiry  ${locId}  ${pcid19}  title=${title}  description=${desc}  category=${category1}  type=${type1}  status=${status1}  priority=${priority1}  isLeadAutogenerate=${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${en_id1}        ${resp.json()['id']}
    Set Suite Variable   ${en_uid1}        ${resp.json()['uid']}

    ${title1}=  FakerLibrary.sentence
    Set Suite Variable  ${title1}
    ${desc1}=   FakerLibrary.City
    Set Suite Variable  ${desc1}
    ${category2}=  Create Dictionary   id=${rand_catagory_id2}
    ${type2}=  Create Dictionary   id=${rand_cat_type_id2}
    ${status2}=  Create Dictionary   id=${rand_status_id2}
    ${priority2}=  Create Dictionary   id=${rand_priority_id2}

    ${resp}=  Create Enquiry  ${locId1}  ${pcid20}  title=${title1}  description=${desc1}  category=${category2}  type=${type2}  status=${status2}  priority=${priority2}  leadMasterId=${ld_temp_id}  isLeadAutogenerate=${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${en_id2}        ${resp.json()['id']}
    Set Suite Variable   ${en_uid2}        ${resp.json()['uid']}

    ${resp}=  Get Enquiry with filter 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id2}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid2}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid20}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title1}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id2}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name2}

    Should Be Equal As Strings  ${resp.json()[1]['id']}   ${en_id1}
    Should Be Equal As Strings  ${resp.json()[1]['uid']}   ${en_uid1}
    Should Be Equal As Strings  ${resp.json()[1]['customer']['id']}   ${pcid19}
    Should Be Equal As Strings  ${resp.json()[1]['location']['id']}   ${locId}
    Should Be Equal As Strings  ${resp.json()[1]['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()[1]['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()[1]['type']['id']}   ${rand_cat_type_id1}
    Should Be Equal As Strings  ${resp.json()[1]['type']['name']}   ${rand_cat_type_name1}
    Should Be Equal As Strings  ${resp.json()[1]['category']['id']}   ${rand_catagory_id1}
    Should Be Equal As Strings  ${resp.json()[1]['category']['name']}   ${rand_catagory_name1}
    Should Be Equal As Strings  ${resp.json()[1]['status']['id']}   ${rand_status_id1}
    Should Be Equal As Strings  ${resp.json()[1]['status']['name']}   ${rand_status_name1}
    Should Be Equal As Strings  ${resp.json()[1]['priority']['id']}   ${rand_priority_id1}
    Should Be Equal As Strings  ${resp.json()[1]['priority']['name']}   ${rand_priority_name1}

    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Get Enquiries For Branch-2
    [Documentation]   Get Enquiries for a branch by id filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Enquiry with filter   id-eq=${en_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id2}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid2}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid20}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title1}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id2}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name2}

    ${resp}=  Get Enquiry count with filter   id-eq=${en_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1

    ${resp}=  Get Enquiry with filter   id-eq=${en_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id1}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid1}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid19}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name1}

    ${resp}=  Get Enquiry count with filter   id-eq=${en_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1


JD-TC-Get Enquiries For Branch-3
    [Documentation]   Get Enquiries for a branch by uuid filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Enquiry with filter   uid-eq=${en_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id2}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid2}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid20}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title1}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id2}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name2}

    ${resp}=  Get Enquiry count with filter   uid-eq=${en_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1

    ${resp}=  Get Enquiry with filter   uid-eq=${en_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id1}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid1}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid19}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name1}

    ${resp}=  Get Enquiry count with filter   uid-eq=${en_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1


JD-TC-Get Enquiries For Branch-4
    [Documentation]   Get Enquiries for a branch by title filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Enquiry with filter   title-eq=${title1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id2}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid2}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid20}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title1}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id2}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name2}

    ${resp}=  Get Enquiry count with filter   title-eq=${title1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1

    ${resp}=  Get Enquiry with filter   title-eq=${title}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id1}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid1}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid19}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name1}

    ${resp}=  Get Enquiry count with filter   title-eq=${title}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1


JD-TC-Get Enquiries For Branch-5
    [Documentation]   Get Enquiries for a branch by description filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Enquiry with filter   description-eq=${desc1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id2}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid2}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid20}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title1}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id2}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name2}

    ${resp}=  Get Enquiry count with filter   description-eq=${desc1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1

    ${resp}=  Get Enquiry with filter   description-eq=${desc}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id1}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid1}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid19}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name1}

    ${resp}=  Get Enquiry count with filter   description-eq=${desc}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1


JD-TC-Get Enquiries For Branch-6
    [Documentation]   Get Enquiries for a branch by generatedBy filter.

    ${multiusers}=    Multiple Users branches
    Log   ${multiusers}
    ${pro_len}=  Get Length   ${multiusers}
    ${BUSER}=  Random Element    ${multiusers}
    Set Suite Variable  ${BUSER}

    ${resp}=   Encrypted Provider Login  ${BUSER}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id1}  ${resp.json()['id']}
    Set Suite Variable  ${p_fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${p_lname1}   ${resp.json()['lastName']}

    ${resp}=   Get Active License
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId2}=  Create Sample Location
    ELSE
        Set Suite Variable  ${locId2}  ${resp.json()[0]['id']}
    END
    clear_customer   ${BUSER}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME19}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid19-2}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid19-2}  ${resp.json()[0]['id']}
    END

    ${resp}=  categorytype  ${account_id1}
    ${resp}=  tasktype      ${account_id1}

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id3}=  Set Variable  ${random_catagories['id']}
    Set Suite Variable  ${rand_catagory_id3}
    ${rand_catagory_name3}=  Set Variable  ${random_catagories['name']}
    Set Suite Variable  ${rand_catagory_name3}

    ${resp}=  Get Provider Enquiry Type  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_cat_types}=  Set Variable  ${resp.json()}
    ${random_cat_types}=  Evaluate  random.choice($en_cat_types)  random
    ${rand_cat_type_id3}=  Set Variable  ${random_cat_types['id']}
    Set Suite Variable  ${rand_cat_type_id3}
    ${rand_cat_type_name3}=  Set Variable  ${random_cat_types['name']}
    Set Suite Variable  ${rand_cat_type_name3}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_statuses}=  Set Variable  ${resp.json()}
    ${random_status}=  Evaluate  random.choice($en_statuses)  random
    ${rand_status_id3}=  Set Variable  ${random_status['id']}
    Set Suite Variable  ${rand_status_id3}
    ${rand_status_name3}=  Set Variable  ${random_status['name']}
    Set Suite Variable  ${rand_status_name3}

    ${resp}=  Get Provider Enquiry Priority  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_prios}=  Set Variable  ${resp.json()}
    ${random_priority}=  Evaluate  random.choice($en_prios)  random
    ${rand_priority_id3}=  Set Variable  ${random_priority['id']}
    Set Suite Variable  ${rand_priority_id3}
    ${rand_priority_name3}=  Set Variable  ${random_priority['name']}
    Set Suite Variable  ${rand_priority_name3}

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

    ${resp}=  enquiryTemplate  ${account_id1}  "Enquiry3"  ${enq_sts_new_id}  category_id=${rand_catagory_id3}  type_id=${rand_cat_type_id3}  creator_provider_id=${provider_id1}  

    ${resp}=  Get Enquiry Template
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${resp}=  Get Lead Templates    
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${ld_temp_id}  ${resp.json()[0]['id']}

    ${title2}=  FakerLibrary.Job
    Set Suite Variable  ${title2}
    ${desc2}=   FakerLibrary.City
    Set Suite Variable  ${desc2}
    ${category3}=  Create Dictionary   id=${rand_catagory_id3}
    ${type3}=  Create Dictionary   id=${rand_cat_type_id3}
    ${status3}=  Create Dictionary   id=${rand_status_id3}
    ${priority3}=  Create Dictionary   id=${rand_priority_id3}

    ${resp}=  Create Enquiry  ${locId2}  ${pcid19-2}  title=${title2}  description=${desc2}  category=${category3}  type=${type3}  status=${status3}  priority=${priority3}  leadMasterId=${ld_temp_id}  isLeadAutogenerate=${bool[1]} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${en_id3}   ${resp.json()['id']}
    Set Suite Variable   ${en_uid3}   ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid3}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id3}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid3}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${locId2}

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
        Set Suite Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
    END
    FOR   ${i}  IN RANGE   0   ${len}
        Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
        IF   not '${user_phone}' == '${BUSER}'
            clear_users  ${user_phone}
        END
    END

    ${u_id}=  Create Sample User
    Set Suite Variable  ${u_id}

    ${resp}=  Get User By Id  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SendProviderResetMail   ${BUSER_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BUSER_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=   Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id2}  ${resp.json()['id']}
    Set Suite Variable  ${p_fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${p_lname2}   ${resp.json()['lastName']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId3}=  Create Sample Location
    ELSE
        Set Suite Variable  ${locId3}  ${resp.json()[0]['id']}
    END
    # clear_customer   ${BUSER}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME20}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME20}  firstName=${fname1}   lastName=${lname1}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid19-3}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid19-3}  ${resp.json()[0]['id']}
    END

    ${title3}=  FakerLibrary.Job
    Set Suite Variable  ${title3}
    ${desc3}=   FakerLibrary.City
    Set Suite Variable  ${desc3}
    ${category3}=  Create Dictionary   id=${rand_catagory_id3}
    ${type3}=  Create Dictionary   id=${rand_cat_type_id3}
    ${status3}=  Create Dictionary   id=${rand_status_id3}
    ${priority3}=  Create Dictionary   id=${rand_priority_id3}

    ${resp}=  Create Enquiry  ${locId3}  ${pcid19-3}  title=${title3}  description=${desc3}  category=${category3}  type=${type3}  status=${status3}  priority=${priority3}  leadMasterId=${ld_temp_id}  isLeadAutogenerate=${bool[1]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${en_id4}        ${resp.json()['id']}
    Set Suite Variable   ${en_uid4}        ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid4}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id4}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid4}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id1}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${BUSER}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Enquiry with filter   generatedBy-eq=${provider_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id3}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid3}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid19-2}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId2}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title2}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc2}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id3}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name3}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id3}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name3}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id3}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name3}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id3}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name3}


    ${resp}=  Get Enquiry count with filter   generatedBy-eq=${provider_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1

    ${resp}=  Get Enquiry with filter   generatedBy-eq=${provider_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id4}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid4}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid19-3}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId2}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title3}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc3}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id3}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name3}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id3}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name3}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id3}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name3}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id3}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name3}


    ${resp}=  Get Enquiry count with filter   generatedBy-eq=${provider_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1


JD-TC-Get Enquiries For Branch-7
    [Documentation]   Get Enquiries for a branch by generatedByFirstName filter.

    ${resp}=   Encrypted Provider Login  ${BUSER}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Enquiry with filter   generatedByFirstName-eq=${p_fname1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id3}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid3}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid19-2}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId2}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title2}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc2}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id3}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name3}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id3}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name3}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id3}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name3}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id3}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name3}


    ${resp}=  Get Enquiry count with filter   generatedByFirstName-eq=${p_fname1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1

    ${resp}=  Get Enquiry with filter   generatedByFirstName-eq=${p_fname2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id4}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid4}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid19-3}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId2}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title3}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc3}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id3}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name3}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id3}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name3}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id3}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name3}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id3}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name3}


    ${resp}=  Get Enquiry count with filter   generatedByFirstName-eq=${p_fname2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1


JD-TC-Get Enquiries For Branch-8
    [Documentation]   Get Enquiries for a branch by generatedByLastName filter.

    ${resp}=   Encrypted Provider Login  ${BUSER}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Enquiry with filter   generatedByLastName-eq=${p_lname1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id3}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid3}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid19-2}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId2}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title2}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc2}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id3}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name3}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id3}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name3}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id3}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name3}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id3}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name3}

    ${resp}=  Get Enquiry count with filter   generatedByLastName-eq=${p_lname1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1

    ${resp}=  Get Enquiry with filter   generatedByLastName-eq=${p_lname2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id4}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid4}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid19-3}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId2}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title3}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc3}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id3}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name3}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id3}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name3}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id3}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name3}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id3}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name3}

    ${resp}=  Get Enquiry count with filter   generatedByLastName-eq=${p_lname2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1


JD-TC-Get Enquiries For Branch-9
    [Documentation]   Get Enquiries for a branch by customer filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Enquiry with filter   customer-eq=${pcid20}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id2}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid2}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid20}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title1}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id2}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name2}

    ${resp}=  Get Enquiry count with filter   customer-eq=${pcid20}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1

    ${resp}=  Get Enquiry with filter   customer-eq=${pcid19}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id1}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid1}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid19}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name1}

    ${resp}=  Get Enquiry count with filter   customer-eq=${pcid19}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1


JD-TC-Get Enquiries For Branch-10
    [Documentation]   Get Enquiries for a branch by customerFirstName filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Enquiry with filter   customerFirstName-eq=${fname1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id2}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid2}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid20}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title1}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id2}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name2}

    ${resp}=  Get Enquiry count with filter   customerFirstName-eq=${fname1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1

    ${resp}=  Get Enquiry with filter   customerFirstName-eq=${fname}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id1}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid1}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid19}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name1}

    ${resp}=  Get Enquiry count with filter   customerFirstName-eq=${fname}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1


JD-TC-Get Enquiries For Branch-11
    [Documentation]   Get Enquiries for a branch by customerLastName filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Enquiry with filter   customerLastName-eq=${lname1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id2}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid2}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid20}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title1}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id2}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name2}

    ${resp}=  Get Enquiry count with filter   customerLastName-eq=${lname1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1

    ${resp}=  Get Enquiry with filter   customerLastName-eq=${lname}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id1}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid1}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid19}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name1}

    ${resp}=  Get Enquiry count with filter   customerLastName-eq=${lname}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1


JD-TC-Get Enquiries For Branch-12
    [Documentation]   Get Enquiries for a branch by location filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Enquiry with filter   location-eq=${locId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id2}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid2}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid20}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title1}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id2}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name2}

    ${resp}=  Get Enquiry count with filter   location-eq=${locId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1

    ${resp}=  Get Enquiry with filter   location-eq=${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id1}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid1}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid19}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name1}

    ${resp}=  Get Enquiry count with filter   location-eq=${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1


JD-TC-Get Enquiries For Branch-13
    [Documentation]   Get Enquiries for a branch by locationName filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Enquiry with filter   locationName-eq=${loc_name1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id2}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid2}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid20}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title1}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id2}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name2}

    ${resp}=  Get Enquiry count with filter   locationName-eq=${loc_name1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1

    ${resp}=  Get Enquiry with filter   locationName-eq=${loc_name}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id1}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid1}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid19}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name1}

    ${resp}=  Get Enquiry count with filter   locationName-eq=${loc_name}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1


JD-TC-Get Enquiries For Branch-14
    [Documentation]   Get Enquiries for a branch by category filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Enquiry with filter   category-eq=${rand_catagory_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id2}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid2}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid20}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title1}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id2}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name2}

    ${resp}=  Get Enquiry count with filter   category-eq=${rand_catagory_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1

    ${resp}=  Get Enquiry with filter   category-eq=${rand_catagory_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id1}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid1}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid19}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name1}

    ${resp}=  Get Enquiry count with filter   category-eq=${rand_catagory_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1


JD-TC-Get Enquiries For Branch-15
    [Documentation]   Get Enquiries for a branch by categoryName filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Enquiry with filter   categoryName-eq=${rand_catagory_name2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id2}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid2}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid20}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title1}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id2}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name2}

    ${resp}=  Get Enquiry count with filter   categoryName-eq=${rand_catagory_name2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1

    ${resp}=  Get Enquiry with filter   categoryName-eq=${rand_catagory_name1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id1}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid1}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid19}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name1}

    ${resp}=  Get Enquiry count with filter   categoryName-eq=${rand_catagory_name1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1


JD-TC-Get Enquiries For Branch-16
    [Documentation]   Get Enquiries for a branch by type filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Enquiry with filter   type-eq=${rand_cat_type_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id2}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid2}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid20}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title1}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id2}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name2}

    ${resp}=  Get Enquiry count with filter   type-eq=${rand_cat_type_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1

    ${resp}=  Get Enquiry with filter   type-eq=${rand_cat_type_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id1}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid1}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid19}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name1}

    ${resp}=  Get Enquiry count with filter   type-eq=${rand_cat_type_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1


JD-TC-Get Enquiries For Branch-17
    [Documentation]   Get Enquiries for a branch by typeName filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Enquiry with filter   typeName-eq=${rand_cat_type_name2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id2}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid2}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid20}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title1}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id2}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name2}

    ${resp}=  Get Enquiry count with filter   typeName-eq=${rand_cat_type_name2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1

    ${resp}=  Get Enquiry with filter   typeName-eq=${rand_cat_type_name1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id1}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid1}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid19}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name1}

    ${resp}=  Get Enquiry count with filter   typeName-eq=${rand_cat_type_name1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1


JD-TC-Get Enquiries For Branch-18
    [Documentation]   Get Enquiries for a branch by priority filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Enquiry with filter   priority-eq=${rand_priority_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id2}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid2}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid20}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title1}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id2}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name2}

    ${resp}=  Get Enquiry count with filter   priority-eq=${rand_priority_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1

    ${resp}=  Get Enquiry with filter   priority-eq=${rand_priority_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id1}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid1}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid19}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name1}

    ${resp}=  Get Enquiry count with filter   priority-eq=${rand_priority_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1


JD-TC-Get Enquiries For Branch-19
    [Documentation]   Get Enquiries for a branch by priorityName filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Enquiry with filter   priorityName-eq=${rand_priority_name2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id2}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid2}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid20}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title1}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id2}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name2}

    ${resp}=  Get Enquiry count with filter   priorityName-eq=${rand_priority_name2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1

    ${resp}=  Get Enquiry with filter   priorityName-eq=${rand_priority_name1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id1}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid1}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid19}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name1}

    ${resp}=  Get Enquiry count with filter   priorityName-eq=${rand_priority_name1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1



JD-TC-Get Enquiries For Branch-20
    [Documentation]   Get Enquiries for a branch by status filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Enquiry with filter   status-eq=${rand_status_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id2}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid2}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid20}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title1}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id2}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name2}

    ${resp}=  Get Enquiry count with filter   status-eq=${rand_status_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1

    ${resp}=  Get Enquiry with filter   status-eq=${rand_status_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id1}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid1}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid19}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name1}

    ${resp}=  Get Enquiry count with filter   status-eq=${rand_status_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1


JD-TC-Get Enquiries For Branch-21
    [Documentation]   Get Enquiries for a branch by statusName filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Enquiry with filter   statusName-eq=${rand_status_name2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id2}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid2}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid20}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title1}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id2}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id2}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id2}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name2}

    ${resp}=  Get Enquiry count with filter   statusName-eq=${rand_status_name2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1

    ${resp}=  Get Enquiry with filter   statusName-eq=${rand_status_name1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id1}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid1}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid19}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId}
    Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title}
    Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc}
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id1}
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name1}

    ${resp}=  Get Enquiry count with filter   statusName-eq=${rand_status_name1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}  1


JD-TC-Get Enquiries For Branch-22
    [Documentation]   Get Enquiries for a branch by originFrom filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=  Get Enquiry with filter   statusName-eq=${rand_status_name2}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id2}
    # Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid2}
    # Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid20}
    # Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId1}
    # Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title1}
    # Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc1}
    # Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id2}
    # Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name2}
    # Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id2}
    # Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name2}
    # Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id2}
    # Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name2}
    # Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id2}
    # Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name2}

    # ${resp}=  Get Enquiry count with filter   statusName-eq=${rand_status_name2}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.content}  1

    # ${resp}=  Get Enquiry with filter   statusName-eq=${rand_status_name1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid1}
    # Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid19}
    # Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId}
    # Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title}
    # Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc}
    # Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name1}
    # Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name1}
    # Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name1}
    # Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name1}

    # ${resp}=  Get Enquiry count with filter   statusName-eq=${rand_status_name1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.content}  1


JD-TC-Get Enquiries For Branch-23
    [Documentation]   Get Enquiries for a branch by originId filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=  Get Enquiry with filter   statusName-eq=${rand_status_name2}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id2}
    # Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid2}
    # Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid20}
    # Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId1}
    # Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title1}
    # Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc1}
    # Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id2}
    # Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name2}
    # Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id2}
    # Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name2}
    # Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id2}
    # Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name2}
    # Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id2}
    # Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name2}

    # ${resp}=  Get Enquiry count with filter   statusName-eq=${rand_status_name2}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.content}  1

    # ${resp}=  Get Enquiry with filter   statusName-eq=${rand_status_name1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid1}
    # Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid19}
    # Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId}
    # Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title}
    # Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc}
    # Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name1}
    # Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name1}
    # Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name1}
    # Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name1}

    # ${resp}=  Get Enquiry count with filter   statusName-eq=${rand_status_name1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.content}  1


JD-TC-Get Enquiries For Branch-24
    [Documentation]   Get Enquiries for a branch by originUid filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=  Get Enquiry with filter   statusName-eq=${rand_status_name2}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id2}
    # Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid2}
    # Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid20}
    # Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId1}
    # Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title1}
    # Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc1}
    # Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id2}
    # Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name2}
    # Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id2}
    # Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name2}
    # Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id2}
    # Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name2}
    # Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id2}
    # Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name2}

    # ${resp}=  Get Enquiry count with filter   statusName-eq=${rand_status_name2}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.content}  1

    # ${resp}=  Get Enquiry with filter   statusName-eq=${rand_status_name1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['id']}   ${en_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${en_uid1}
    # Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}   ${pcid19}
    # Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${locId}
    # Should Be Equal As Strings  ${resp.json()[0]['title']}   ${title}
    # Should Be Equal As Strings  ${resp.json()[0]['description']}   ${desc}
    # Should Be Equal As Strings  ${resp.json()[0]['type']['id']}   ${rand_cat_type_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['type']['name']}   ${rand_cat_type_name1}
    # Should Be Equal As Strings  ${resp.json()[0]['category']['id']}   ${rand_catagory_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['category']['name']}   ${rand_catagory_name1}
    # Should Be Equal As Strings  ${resp.json()[0]['status']['id']}   ${rand_status_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['status']['name']}   ${rand_status_name1}
    # Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}   ${rand_priority_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}   ${rand_priority_name1}

    # ${resp}=  Get Enquiry count with filter   statusName-eq=${rand_status_name1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.content}  1

