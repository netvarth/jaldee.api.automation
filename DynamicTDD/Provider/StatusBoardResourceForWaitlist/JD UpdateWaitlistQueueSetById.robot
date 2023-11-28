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

*** Variables ***
${SERVICE1}     Radio Repdca111
${SERVICE2}     Radio Repdca123
${SERVICE3}     Radio Repdca222

*** Test Cases ***
JD-TC-UpdateWaitlistQueueSetById-1
	[Documentation]  Update all details of a QueueSet for Service,queue and department
   
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${MUSERNAME_M}=  Evaluate  ${MUSERNAME}+437746
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_M}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${MUSERNAME_M}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${MUSERNAME_M}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_M}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_M}${\n}
    Set Suite Variable  ${MUSERNAME_M}

    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id2}
    ${s_id3}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable  ${s_id3}
    sleep  03s
    ${resp}=  Create Sample Queue
    Set Suite Variable  ${qid1}   ${resp['queue_id']}
    ${resp}=  Toggle Department Enable
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
    ${dep_name2}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name2}
    ${dep_code2}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code2}
    ${dep_desc2}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc2}
    ${resp}=  Create Department  ${dep_name2}  ${dep_code2}  ${dep_desc2}   ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid2}  ${resp.json()}

    ${Addon_id}=  get_statusboard_addonId
    ${resp}=  Add addon  ${Addon_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200  
    ${order1}=   Random Int   min=0   max=1
    ${order2}=   Random Int   min=2   max=3
    ${Values}=  FakerLibrary.Words  	nb=6
    ${fieldList}=  Create Fieldlist For QueueSet  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${bool[1]}  ${order1}  ${Values[3]}  ${Values[4]}  ${Values[5]}  ${bool[0]}  ${order2}
    Log  ${fieldList}
    ${s_name}=  FakerLibrary.Words  nb=2
    ${s_desc}=  FakerLibrary.Sentence
    ${service_list}=  Create list  ${s_id1}  ${s_id2}
    ${queue_list}=  Create List  ${qid1}
    ${department_list}=  Create List  ${depid1}  ${depid2}

    ${dd}=   Create Dictionary   id=${qid1}
    ${queue}=  Create List   ${dd}
    ${ss}=   Create Dictionary  id=${s_id1} 
    ${ser}=  Create List  ${ss}
    ${dept1}=   Create Dictionary  departmentId=${depid1}
    ${dep}=  Create List   ${dept1}
    ${w_list}=   Create List    ${wl_status[0]}
    ${resp}=  Create QueueSet for Branch   ${s_name[0]}  ${s_name[1]}   ${s_desc}   ${fieldList}   ${dep}    ${ser}     ${queue}    ${EMPTY}   ${EMPTY}     ${w_list}    ${statusboard_type[0]}  ${service_list}  ${statusboard_type[1]}  ${queue_list}  ${statusboard_type[2]}  ${department_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sb_id}  ${resp.json()} 

    # ${resp}=  Create QueueSet  ${s_name[0]}  ${s_name[1]}  ${s_desc}  ${fieldList}   ${depid2}   ${s_id1}   ${EMPTY}  ${EMPTY}  ${EMPTY}    ${qid1}    ${wl_status[0]}   ${statusboard_type[0]}  ${service_list}  ${statusboard_type[1]}   ${queue_list}   ${statusboard_type[2]}  ${department_list}    
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sb_id}  ${resp.json()} 

    ${order3}=   Random Int   min=5   max=6
    ${Values1}=  FakerLibrary.Words  	nb=3
    ${fieldList1}=  Create Fieldlist For QueueSet  ${Values1[0]}  ${Values1[1]}  ${Values1[2]}  ${bool[1]}  ${order3}
    Log  ${fieldList1}
    ${s_name1}=  FakerLibrary.Words  nb=2
    ${s_desc1}=  FakerLibrary.Sentence
    ${service_list1}=  Create list  ${s_id3}
    ${department_list1}=  Create List  ${depid1}


    ${dd}=   Create Dictionary   id=${qid1}
    ${queue}=  Create List   ${dd}
    ${ss}=   Create Dictionary  id=${s_id1} 
    ${ser}=  Create List  ${ss}
    ${dept1}=   Create Dictionary  departmentId=${depid1}
    ${dep}=  Create List   ${dept1}
    ${w_list}=   Create List    ${wl_status[0]}

    ${resp}=  Update QueueSet Waitlist for Branch   ${sb_id}   ${s_name1[0]}  ${s_name1[1]}  ${s_desc1}  ${fieldList1}  ${dep}    ${ser}     ${queue}    ${EMPTY}   ${EMPTY}     ${w_list}      ${statusboard_type[0]}  ${service_list1}   ${statusboard_type[2]}  ${department_list1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get WaitlistQueueSet By Id  ${sb_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${sb_id}
    Should Be Equal As Strings  ${resp.json()['name']}  ${s_name1[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}  ${s_name1[1]}
    Should Be Equal As Strings  ${resp.json()['description']}  ${s_desc1}
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['name']}  ${Values1[0]}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['label']}  ${bool[1]}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['order']}  ${order3}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['displayName']}  ${Values1[1]}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['defaultValue']}  ${Values1[2]}  
    Should Be Equal As Strings  ${resp.json()['queryString']}    department-eq=${depid1}&service-eq=${s_id1}&queue-eq=${qid1}&waitlistStatus-eq=checkedIn&label-eq=::

JD-TC-UpdateWaitlistQueueSetById-2
	[Documentation]  Update few details of a QueueSet
    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_service   ${PUSERNAME101}
    clear_location  ${PUSERNAME101}
    clear_queue   ${PUSERNAME101}
    clear_Statusboard  ${PUSERNAME101}
    clear_Addon  ${PUSERNAME101}
    ${resp}=  Create Sample Queue
    Set Suite Variable  ${qid1}   ${resp['queue_id']}
    ${Addon_id}=  get_statusboard_addonId
    ${resp}=  Add addon  ${Addon_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200  
    ${order1}=   Random Int   min=0   max=1
    Set Suite Variable  ${order1}
    ${Values}=  FakerLibrary.Words  	nb=3
    Set Suite Variable  ${Values}
    ${fieldList}=  Create Fieldlist For QueueSet  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${bool[1]}  ${order1}
    Log  ${fieldList}
    Set Suite Variable  ${fieldList}
    ${s_name}=  FakerLibrary.Words  nb=2
    ${s_desc}=  FakerLibrary.Sentence
    ${queue_list}=  Create list  ${qid1}
    Set Suite Variable  ${queue_list}  


    ${dd}=   Create Dictionary   id=${qid1}
    ${queue}=  Create List   ${dd} 
    ${ser}=  Create List
    ${w_list}=   Create List    ${wl_status[0]}
    ${resp}=  Create QueueSet for provider   ${s_name[0]}  ${s_name[1]}   ${s_desc}   ${fieldList}     ${ser}     ${queue}    ${EMPTY}   ${EMPTY}     ${w_list}    ${statusboard_type[1]}      ${queue_list}
    Log  ${resp.json()}
    Set Suite Variable  ${sb_id}  ${resp.json()}

    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id1}
    ${service_list}=  Create list  ${s_id1}
    Set Suite Variable  ${service_list}
    ${s_name1}=  FakerLibrary.Words  nb=2
    Set Suite Variable  ${s_name1}
    ${s_desc1}=  FakerLibrary.Sentence
    Set Suite Variable  ${s_desc1}

    ${sid}=    Create Dictionary   id=${s_id1}
    ${sid2}=   Create List   ${sid}
    Set Suite Variable   ${sid2} 
    ${w_list}=   Create List    ${wl_status[0]}
    Set Suite Variable  ${w_list}
    # ${dept}=  Create List
    # Set Suite Variable  ${dept}
    ${que}=   Create List
    Set Suite Variable  ${que}

    ${resp}=  Update QueueSet Waitlist for Provider   ${sb_id}  ${s_name1[0]}  ${s_name1[1]}  ${s_desc1}  ${fieldList}   ${sid2}     ${que}    ${EMPTY}   ${EMPTY}    ${w_list}    ${statusboard_type[0]}      ${service_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get WaitlistQueueSet By Id  ${sb_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${sb_id}
    Should Be Equal As Strings  ${resp.json()['name']}  ${s_name1[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}  ${s_name1[1]}
    Should Be Equal As Strings  ${resp.json()['description']}  ${s_desc1}
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['name']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['label']}  ${bool[1]}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['order']}  ${order1}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['displayName']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['defaultValue']}  ${Values[2]}  
    Should Be Equal As Strings  ${resp.json()['queryString']}    service-eq=${s_id1}&waitlistStatus-eq=checkedIn&label-eq=::

JD-TC-UpdateWaitlistQueueSetById -UH1
    [Documentation]   Provider update a QueueSet without login  
    ${resp}=  Update QueueSet Waitlist for Provider   ${sb_id}  ${s_name1[0]}  ${s_name1[1]}  ${s_desc1}  ${fieldList}     ${sid1}     ${que}    ${EMPTY}   ${EMPTY}    ${w_list}    ${statusboard_type[0]}      ${service_list}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-UpdateWaitlistQueueSetById -UH2
    [Documentation]   Consumer trying to update a QueueSet
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Update QueueSet Waitlist for Provider   ${sb_id}  ${s_name1[0]}  ${s_name1[1]}  ${s_desc1}  ${fieldList}    ${sid1}     ${que}    ${EMPTY}   ${EMPTY}    ${w_list}    ${statusboard_type[0]}      ${service_list}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-UpdateWaitlistQueueSetById-UH3
    [Documentation]  Upadte a QueueSet which is not exist
    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${invalid_id}=   Random Int   min=-10   max=0
    ${resp}=  Update QueueSet Waitlist for Provider   ${invalid_id}  ${s_name1[0]}  ${s_name1[1]}  ${s_desc1}  ${fieldList}     ${sid2}     ${que}    ${EMPTY}   ${EMPTY}    ${w_list}    ${statusboard_type[0]}      ${service_list}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_SET_NOT_EXIST}"

JD-TC-UpdateWaitlistQueueSetById-UH4
    [Documentation]  Update a QueueSet by id of another provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME10}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update QueueSet Waitlist for Provider    ${sb_id}  ${s_name1[0]}  ${s_name1[1]}  ${s_desc1}  ${fieldList}    ${sid2}     ${que}    ${EMPTY}   ${EMPTY}    ${w_list}    ${statusboard_type[0]}      ${service_list}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_SET_NOT_EXIST}"