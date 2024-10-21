*** Settings ***

Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      QueueSet
Library         Collections
Library         String
Library         json
Library         FakerLibrary
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot

*** Variables ***
@{service_names}

*** Test Cases ***
JD-TC-CreateQueueSet-1
	[Documentation]  Create a Waitlist QueueSet for Service,queue and department

    ${firstname}  ${lastname}  ${PUSERNAME_B}  ${LoginId}=  Provider Signup
    Set Suite Variable  ${PUSERNAME_B}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
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
    Set Suite Variable  ${depid}  ${resp.json()}

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
    ${department_list}=  Create List  ${depid}

    ${dd}=   Create Dictionary   id=${qid1}
    ${queue}=  Create List   ${dd}
    ${ss}=   Create Dictionary  id=${s_id1} 
    ${ser}=  Create List  ${ss}
    ${dept1}=   Create Dictionary  departmentId=${depid}
    ${dep}=  Create List   ${dept1}
    ${w_list}=   Create List    ${wl_status[0]}
    ${resp}=  Create QueueSet for Branch   ${s_name[0]}  ${s_name[1]}   ${s_desc}   ${fieldList}   ${dep}    ${ser}     ${queue}    ${EMPTY}   ${EMPTY}     ${w_list}    ${statusboard_type[0]}  ${service_list}  ${statusboard_type[1]}  ${queue_list}  ${statusboard_type[2]}  ${department_list}
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
    Should Be Equal As Strings  ${resp.json()['queueSetFor'][0]['type']}   ${statusboard_type[0]}
    Should Be Equal As Strings  ${resp.json()['queueSetFor'][1]['type']}   ${statusboard_type[1]}   
    Should Be Equal As Strings  ${resp.json()['queueSetFor'][2]['type']}   ${statusboard_type[2]}
    Should Be Equal As Strings  ${resp.json()['qBoardConditions']['departments'][0]['departmentId']}   ${depid}  
    Should Be Equal As Strings  ${resp.json()['qBoardConditions']['services'][0]['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['qBoardConditions']['queues'][0]['id']}   ${qid1}
    Should Be Equal As Strings  ${resp.json()['queryString']}   department-eq=${depid}&service-eq=${s_id1}&queue-eq=${qid1}&waitlistStatus-eq=checkedIn&label-eq=::

JD-TC-CreateQueueSet-2
	[Documentation]  Create a Waitlist QueueSet for Queue only

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

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
    ${queue_list}=  Create list  ${qid1}
    Set Suite Variable  ${queue_list} 

    ${dd}=   Create Dictionary   id=${qid1}
    ${queue}=  Create List   ${dd} 
    ${ser}=  Create List
    ${w_list}=   Create List    ${wl_status[0]}
    ${resp}=  Create QueueSet for provider  ${s_name[0]}  ${s_name[1]}   ${s_desc}   ${fieldList}      ${ser}     ${queue}    ${EMPTY}   ${EMPTY}     ${w_list}    ${statusboard_type[1]}      ${queue_list}
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
    Should Be Equal As Strings  ${resp.json()['qBoardConditions']['queues'][0]['id']}   ${qid1}
    Should Be Equal As Strings  ${resp.json()['queryString']}    queue-eq=${qid1}&waitlistStatus-eq=checkedIn&label-eq=::


JD-TC-CreateQueueSet-3
	[Documentation]  Create a QueueSet for Service only

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${s_id3}=  Create Sample Service  ${SERVICE3}   department=${depid}  
    Set Suite Variable  ${s_id3} 
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
    ${service_list}=  Create list  ${s_id3} 
    Set Suite Variable  ${service_list} 

    ${sid}=    Create Dictionary   id=${s_id3} 
    ${sid1}=   Create List   ${sid}
    ${w_list}=   Create List    ${wl_status[0]}
    ${que}=   Create List
    ${resp}=  Create QueueSet for provider   ${s_name[0]}  ${s_name[1]}  ${s_desc}  ${fieldList}   ${sid1}     ${que}    ${EMPTY}   ${EMPTY}    ${w_list}    ${statusboard_type[0]}      ${service_list}
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
    Should Be Equal As Strings  ${resp.json()['queueSetFor'][0]['type']}   ${statusboard_type[0]}
    Should Be Equal As Strings  ${resp.json()['qBoardConditions']['services'][0]['id']}   ${s_id3}
    Should Be Equal As Strings  ${resp.json()['queryString']}    service-eq=${s_id3}&waitlistStatus-eq=checkedIn&label-eq=::

JD-TC-CreateQueueSet-4
	[Documentation]  Create a Waitlist QueueSet for same service with another Waitlist QueueSet details

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${order1}=   Random Int   min=0   max=1
    ${Values}=  FakerLibrary.Words  	nb=3
    ${fieldList}=  Create Fieldlist For QueueSet  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${bool[1]}  ${order1}
    Log  ${fieldList}
    ${service_list}=  Create list  ${s_id3} 
    Set Suite Variable  ${service_list} 
    ${s_name}=  FakerLibrary.Words  nb=2
    ${s_desc}=  FakerLibrary.Sentence
    ${sid}=    Create Dictionary   id=${s_id3} 
    ${sid1}=   Create List   ${sid}
    ${w_list}=   Create List    ${wl_status[0]}
    ${que}=   Create List
    ${resp}=  Create QueueSet for provider  ${s_name[0]}  ${s_name[1]}  ${s_desc}  ${fieldList}     ${sid1}     ${que}    ${EMPTY}   ${EMPTY}    ${w_list}    ${statusboard_type[0]}      ${service_list}
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
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['label']}  ${bool[1]}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['order']}  ${order1}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['displayName']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['defaultValue']}  ${Values[2]}  
    Should Be Equal As Strings  ${resp.json()['queueSetFor'][0]['type']}   ${statusboard_type[0]}
    Should Be Equal As Strings  ${resp.json()['qBoardConditions']['services'][0]['id']}   ${s_id3}
    Should Be Equal As Strings  ${resp.json()['queryString']}    service-eq=${s_id3}&waitlistStatus-eq=checkedIn&label-eq=::



JD-TC-CreateQueueSet-5
	[Documentation]  Create a Waitlist QueueSet for Department only

    ${firstname}  ${lastname}  ${PUSERNAME_G}  ${LoginId}=  Provider Signup
    Set Suite Variable  ${PUSERNAME_G}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    

    ${s_id3}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable  ${s_id3}
    ${resp}=  Enable Disable Department  ${toggle[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name1}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name1}
    ${dep_code1}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code1}
    ${dep_desc}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc}
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc}   ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid1}  ${resp.json()}
    ${Addon_id}=  get_statusboard_addonId
    ${resp}=  Add addon  ${Addon_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200  
    ${order1}=   Random Int   min=0   max=1
    ${Values}=  FakerLibrary.Words  	nb=3
    ${fieldList}=  Create Fieldlist For QueueSet  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${bool[1]}  ${order1}
    Log  ${fieldList}
    Set Suite Variable  ${fieldList}
    ${s_name}=  FakerLibrary.Words  nb=2
    Set Suite Variable  ${s_name}
    ${s_desc}=  FakerLibrary.Sentence
    Set Suite Variable  ${s_desc}
    ${department_list}=  Create list  ${depid1}
    Set Suite Variable  ${department_list}


    ${dept1}=   Create Dictionary  departmentId=${depid1}
    ${dept}=  Create List   ${dept1}
    ${w_list}=   Create List    ${wl_status[0]}
    ${sid1}=  Create List
    ${que}=   Create List

    ${resp}=  Create QueueSet for Branch   ${s_name[0]}  ${s_name[1]}  ${s_desc}  ${fieldList}    ${dept}    ${sid1}     ${que}    ${EMPTY}   ${EMPTY}    ${w_list}   ${statusboard_type[2]}      ${department_list}
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
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['label']}  ${bool[1]}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['order']}  ${order1}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['displayName']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['defaultValue']}  ${Values[2]}  
    Should Be Equal As Strings  ${resp.json()['queueSetFor'][0]['type']}   ${statusboard_type[2]}
    Should Be Equal As Strings  ${resp.json()['qBoardConditions']['departments'][0]['departmentId']}   ${depid1}
    Should Be Equal As Strings  ${resp.json()['queryString']}    department-eq=${depid1}&waitlistStatus-eq=checkedIn&label-eq=::
JD-TC-CreateQueueSet-6

	[Documentation]  Create a QueueSet for same department with another QueueSet details
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${order1}=   Random Int   min=0   max=1
    ${Values}=  FakerLibrary.Words  	nb=3
    ${fieldList}=  Create Fieldlist For QueueSet  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${bool[1]}  ${order1}
    Log  ${fieldList}
    Set Suite Variable  ${fieldList}
    ${s_name}=  FakerLibrary.Words  nb=2
    Set Suite Variable  ${s_name}
    ${s_desc}=  FakerLibrary.Sentence
    Set Suite Variable  ${s_desc}
    ${department_list}=  Create list  ${depid1}
    Set Suite Variable  ${department_list}

    ${dept1}=   Create Dictionary  departmentId=${depid1}
    ${dept}=  Create List   ${dept1}
    ${w_list}=   Create List    ${wl_status[0]}
    ${sid1}=  Create List
    ${que}=   Create List

    ${resp}=  Create QueueSet for Branch   ${s_name[0]}  ${s_name[1]}  ${s_desc}  ${fieldList}    ${dept}    ${sid1}     ${que}    ${EMPTY}   ${EMPTY}    ${w_list}   ${statusboard_type[2]}      ${department_list}
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
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['label']}  ${bool[1]}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['order']}  ${order1}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['displayName']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['defaultValue']}  ${Values[2]}  
    Should Be Equal As Strings  ${resp.json()['queueSetFor'][0]['type']}   ${statusboard_type[2]}
    Should Be Equal As Strings  ${resp.json()['qBoardConditions']['departments'][0]['departmentId']}   ${depid1}
    Should Be Equal As Strings  ${resp.json()['queryString']}         department-eq=${depid1}&waitlistStatus-eq=checkedIn&label-eq=::


JD-TC-CreateQueueSet -UH1
    [Documentation]   Provider create a Waitlist QueueSet without login  
    ${dept1}=   Create Dictionary  departmentId=${depid1}
    ${w_list}=   Create List    ${wl_status[0]}
    ${sid1}=  Create List
    ${que}=   Create List
   
    ${resp}=  Create QueueSet for provider   ${s_name[0]}  ${s_name[1]}  ${s_desc}  ${fieldList}    ${sid1}     ${que}    ${EMPTY}   ${EMPTY}    ${w_list}   ${statusboard_type[2]}      ${department_list}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"


JD-TC-CreateQueueSet -UH2
    [Documentation]   Consumer create a QueueSet

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
    
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${w_list}=   Create List    ${wl_status[0]}
    ${sid1}=  Create List
    ${que}=   Create List
    ${resp}=  Create QueueSet for provider   ${s_name[0]}  ${s_name[1]}  ${s_desc}  ${fieldList}     ${sid1}     ${que}    ${EMPTY}   ${EMPTY}    ${w_list}   ${statusboard_type[2]}      ${department_list}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"
 

JD-TC-CreateQueueSet-UH3
    [Documentation]  Create a QueueSet which is already created
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dept1}=   Create Dictionary  departmentId=${depid1}
    ${dept}=  Create List   ${dept1}
    ${w_list}=   Create List    ${wl_status[0]}
    ${sid1}=  Create List
    ${que}=   Create List
    ${resp}=  Create QueueSet for Branch   ${s_name[0]}  ${s_name[1]}  ${s_desc}  ${fieldList}    ${dept}    ${sid1}     ${que}    ${EMPTY}   ${EMPTY}    ${w_list}   ${statusboard_type[2]}      ${department_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Log  ${resp.json()}
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_SET_NAME_ALREADY_EXIST}"


JD-TC-CreateQueueSet-UH4
	[Documentation]  Create a Waitlist QueueSet with empty fieldlist
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${Addon_id}=  get_statusboard_addonId
    ${resp}=  Add addon  ${Addon_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200  
    ${order1}=   Random Int   min=0   max=1
    ${fieldList}=  Create List
    ${s_name}=  FakerLibrary.Words  nb=2
    ${s_desc}=  FakerLibrary.Sentence
    ${service_list}=  Create list  ${s_id3}

    ${sid}=    Create Dictionary   id=${s_id3} 
    ${sid1}=   Create List   ${sid}
    ${w_list}=   Create List    ${wl_status[0]}
    ${dept}=  Create List
    ${que}=   Create List
    ${resp}=  Create QueueSet for provider  ${s_name[0]}  ${s_name[1]}  ${s_desc}  ${fieldList}    ${sid1}     ${que}    ${EMPTY}   ${EMPTY}    ${w_list}    ${statusboard_type[0]}      ${service_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Log  ${resp.json()}
    Should Be Equal As Strings  "${resp.json()}"  "${STATUS_BOARD_FIELD_NOT_EMPTY}"


JD-TC-CreateQueueSet-UH5
	[Documentation]  Create a Waitlist QueueSet with empty Status Board For
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${Addon_id}=  get_statusboard_addonId
    ${resp}=  Add addon  ${Addon_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200  
    ${order1}=   Random Int   min=0   max=1
    ${Values}=  FakerLibrary.Words  	nb=3
    ${fieldList}=  Create Fieldlist For QueueSet  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${bool[1]}  ${order1}
    Log  ${fieldList}
    ${s_name}=  FakerLibrary.Words  nb=2
    ${s_desc}=  FakerLibrary.Sentence
    ${service_list}=  Create list  ${s_id3}

    ${sid}=    Create Dictionary   id=${s_id3} 
    ${sid1}=   Create List   ${sid}
    ${w_list}=   Create List    ${wl_status[0]}
    ${que}=   Create List
    ${resp}=  Create QueueSet for provider  ${s_name[0]}  ${s_name[1]}  ${s_desc}  ${fieldList}     ${sid1}     ${que}    ${EMPTY}   ${EMPTY}    ${w_list}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "Status Board For ( service, queue, department ) empty"


JD-TC-CreateQueueSet-UH7
	[Documentation]  Create a QueueSet with status board type and without service list
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Addon_id}=  get_statusboard_addonId
    ${resp}=  Add addon  ${Addon_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200  
    ${order1}=   Random Int   min=0   max=1
    ${Values}=  FakerLibrary.Words  	nb=3
    ${fieldList}=  Create Fieldlist For QueueSet  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${bool[1]}  ${order1}
    Log  ${fieldList}
    ${s_name}=  FakerLibrary.Words  nb=2
    ${s_desc}=  FakerLibrary.Sentence
    ${service_list}=  Create list  ${EMPTY}

    ${sid}=    Create Dictionary   id=${s_id3} 
    ${sid1}=   Create List   ${sid}
    ${w_list}=   Create List    ${wl_status[0]}
    ${que}=   Create List
    ${resp}=  Create QueueSet for provider  ${s_name[0]}  ${s_name[1]}  ${s_desc}   ${fieldList}      ${sid1}     ${que}    ${EMPTY}   ${EMPTY}    ${w_list}   ${statusboard_type[0]}   ${service_list}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_NOT_EXISTS}"


JD-TC-CreateQueueSet-UH8
	[Documentation]  Create a Waitlist QueueSet with status board type and using invalid sevice ids
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${order1}=   Random Int   min=0   max=1
    ${Values}=  FakerLibrary.Words  	nb=3
    ${fieldList}=  Create Fieldlist For QueueSet  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${bool[1]}  ${order1}
    Log  ${fieldList}
    ${s_name}=  FakerLibrary.Words  nb=2
    ${s_desc}=  FakerLibrary.Sentence
    ${invalid_id}=   Random Int   min=-10   max=0
    ${service_list}=  Create list  ${invalid_id}

    ${sid}=    Create Dictionary   id=${s_id3} 
    ${sid1}=   Create List   ${sid}
    ${w_list}=   Create List    ${wl_status[0]}
    ${que}=   Create List
    ${resp}=  Create QueueSet for provider  ${s_name[0]}  ${s_name[1]}  ${s_desc}  ${fieldList}      ${sid1}     ${que}    ${EMPTY}   ${EMPTY}    ${w_list}   ${statusboard_type[0]}   ${service_list}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Log  ${resp.json()}
    Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_NOT_EXISTS}"

JD-TC-CreateQueueSet-UH9
	[Documentation]  Create a Waitlist statusboard for a valid provider who is not added addon of Status_Board
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME25}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=   Get addons auditlog
    Log  ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200

    ${SERVICE1}=    generate_service_name 
    ${s_id3}=  Create Sample Service  ${SERVICE1}     
    Set Suite Variable  ${s_id3}

    ${order1}=   Random Int   min=0   max=1
    ${Values}=  FakerLibrary.Words  	nb=3
    ${fieldList}=  Create Fieldlist For QueueSet  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${bool[1]}  ${order1}
    Log  ${fieldList}
    ${s_name}=  FakerLibrary.Words  nb=2
    ${s_desc}=  FakerLibrary.Sentence
    ${service_list}=  Create list  ${s_id3}

    ${sid}=    Create Dictionary   id=${s_id3} 
    ${sid1}=   Create List   ${sid}
    ${w_list}=   Create List    ${wl_status[0]}
    ${que}=   Create List
    ${resp}=  Create QueueSet for provider  ${s_name[0]}  ${s_name[1]}  ${s_desc}  ${fieldList}      ${sid1}     ${que}    ${EMPTY}   ${EMPTY}    ${w_list}   ${statusboard_type[0]}   ${service_list}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sbq_id1}  ${resp.json()}
    # Should Be Equal As Strings  "${resp.json()}"  "${EXCEEDS_LIMIT}"
    ${Positions}=  FakerLibrary.Words  	nb=3
    ${matric_list}=  Create Metric For Status Board  ${Positions[0]}  ${sbq_id1}  
    Log  ${matric_list}
    ${Data}=  FakerLibrary.Words  	nb=3
    ${resp}=   Create Status Board waitlist    ${Data[0]}  ${Data[1]}  ${Data[2]}  ${matric_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${STATUS_BOARD_LICENSE}"

   