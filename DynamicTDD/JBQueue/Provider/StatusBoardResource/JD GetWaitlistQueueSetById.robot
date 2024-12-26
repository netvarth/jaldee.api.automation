*** Settings ***

Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      QueueSet
Library         Collections
Library         String
Library         json
Library         FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Resource        /ebs/TDD/ProviderConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 
Variables       /ebs/TDD/varfiles/hl_providers.py

*** Variables ***
@{service_names}

*** Test Cases ***
JD-TC-GetQueueSetById-1
    [Documentation]  Create a Waitlist QueueSet for Service,queue and department

    ${firstname}  ${lastname}  ${PUSERNAME_M}  ${LoginId}=  Provider Signup
    Set Suite Variable  ${PUSERNAME_M}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_M}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${SERVICE1}=    generate_unique_service_name  ${service_names} 
    Append To List  ${service_names}  ${SERVICE1}
    Set Suite Variable  ${SERVICE1}

    ${SERVICE2}=     generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    Set Suite Variable  ${SERVICE2}

    ${SERVICE3}=     generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE3}
    Set Suite Variable  ${SERVICE3}
    
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id1}
    ${resp}=  Create Sample Queue
    Set Suite Variable  ${qid1}   ${resp['queue_id']} 
    ${resp}=  Enable Disable Department  ${toggle[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name1}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name1}
    ${dep_code1}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code1}
    ${dep_desc}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc}
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc}   ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid1}  ${resp.json()}

    ${Addon_id}=  get_statusboard_addonId
    ${resp}=  Add addon  ${Addon_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200  

    ${order1}=   Random Int   min=0   max=1
    ${Values}=  FakerLibrary.Words  	nb=3

    ${fieldList}=  Create Fieldlist For QueueSet  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${bool[0]}  ${order1}
    Log  ${fieldList}
    ${s_name}=  FakerLibrary.Words  nb=2
    ${s_desc}=  FakerLibrary.Sentence
    ${queue_list}=  Create List  ${qid1}
    ${service_list}=  Create list  ${s_id1}
    ${queue_list}=  Create List  ${qid1}
    ${department_list}=  Create List  ${depid1}

    ${dd}=   Create Dictionary   id=${qid1}
    ${queue}=  Create List   ${dd}
    ${ss}=   Create Dictionary  id=${s_id1} 
    ${ser}=  Create List  ${ss}
    ${dept1}=   Create Dictionary  departmentId=${depid1}
    ${dep}=  Create List   ${dept1}
    ${w_list}=   Create List    ${wl_status[0]}
    ${resp}=  Create QueueSet for provider   ${s_name[0]}  ${s_name[1]}   ${s_desc}   ${fieldList}   ${ser}     ${queue}    ${EMPTY}   ${EMPTY}     ${w_list}    ${statusboard_type[1]}   ${queue_list}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sbq_id1}  ${resp.json()}
    ${resp}=  Get WaitlistQueueSet By Id  ${sbq_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${sbq_id1}
    Should Be Equal As Strings  ${resp.json()['name']}  ${s_name[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}  ${s_name[1]}
    Should Be Equal As Strings  ${resp.json()['description']}  ${s_desc}
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['name']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['label']}  ${bool[0]}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['order']}  ${order1}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['displayName']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['defaultValue']}  ${Values[2]}  
    Should Be Equal As Strings  ${resp.json()['queueSetFor'][0]['type']}   ${statusboard_type[1]}
    Should Be Equal As Strings  ${resp.json()['qBoardConditions']['services'][0]['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['qBoardConditions']['queues'][0]['id']}   ${qid1}
    Should Be Equal As Strings  ${resp.json()['queryString']}    service-eq=${s_id1}&queue-eq=${qid1}&waitlistStatus-eq=checkedIn&label-eq=::

JD-TC-GetQueueSetById -UH1

    [Documentation]   Provider get a Waitlist QueueSet without login  

    ${resp}=  Get WaitlistQueueSet By Id  ${sbq_id1}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-GetQueueSetById -UH2

    [Documentation]   Consumer get a WaitlistQueueSet
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${account_id}=  get_acc_id  ${HLPUSERNAME25}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
    Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}

    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Send Otp For Login    ${PCPHONENO}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}
    
    # ${resp}=  Provider Logout
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get WaitlistQueueSet By Id  ${sbq_id1}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-GetQueueSetById-UH3
    [Documentation]  Get a Waitlist QueueSet by id which is not exist
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_M}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${invalid_id}=   Random Int   min=-10   max=0
    ${resp}=  Get WaitlistQueueSet By Id  ${invalid_id}
    Should Be Equal As Strings  ${resp.status_code}  422
    Log  ${resp.json()}
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_SET_NOT_EXIST}"

JD-TC-GetQueueSetById-UH4
    [Documentation]  Get a QueueSet by id of another provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME10}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get WaitlistQueueSet By Id  ${sbq_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_SET_NOT_EXIST}"