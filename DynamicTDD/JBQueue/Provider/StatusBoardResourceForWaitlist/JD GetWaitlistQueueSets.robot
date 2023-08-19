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
JD-TC-GetWaitlistQueueSets-1
	[Documentation]  Get all QueueSets created by a provider
    
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${MUSERNAME_M}=  Evaluate  ${MUSERNAME}+436736
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_M}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${MUSERNAME_M}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${MUSERNAME_M}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${MUSERNAME_M}  ${PASSWORD}
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
    ${s_name1}=  FakerLibrary.Words  nb=2
    ${s_desc1}=  FakerLibrary.Sentence
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
    ${resp}=  Create QueueSet for Branch   ${s_name1[0]}  ${s_name1[1]}   ${s_desc1}   ${fieldList}   ${dep}    ${ser}     ${queue}    ${EMPTY}   ${EMPTY}     ${w_list}    ${statusboard_type[0]}  ${service_list}  ${statusboard_type[1]}  ${queue_list}  ${statusboard_type[2]}  ${department_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sbq_id1}  ${resp.json()}

    # ${resp}=   Create QueueSet   ${s_name1[0]}  ${s_name1[1]}  ${s_desc1}  ${fieldList}     ${depid1}   ${s_id1}   ${EMPTY}  ${EMPTY}  ${EMPTY}    ${qid1}    ${wl_status[0]}   ${statusboard_type[0]}  ${service_list}  ${statusboard_type[1]}  ${queue_list}  ${statusboard_type[2]}  ${department_list} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sb_id1}  ${resp.json()}

    ${s_name2}=  FakerLibrary.Words  nb=2
    ${s_desc2}=  FakerLibrary.Sentence
    ${queue_list2}=  Create list  ${qid1}
    Set Suite Variable  ${queue_list2}  

    ${dd}=   Create Dictionary   id=${qid1}
    ${queue}=  Create List   ${dd}
    ${ss}=   Create Dictionary  id=${s_id1} 
    ${ser}=  Create List  ${ss}
    ${dept1}=   Create Dictionary  departmentId=${depid1}
    ${dep}=  Create List   ${dept1}
    ${w_list}=   Create List    ${wl_status[0]}
    ${resp}=  Create QueueSet for Branch   ${s_name2[0]}  ${s_name2[1]}   ${s_desc2}   ${fieldList}   ${dep}    ${ser}     ${queue}    ${EMPTY}   ${EMPTY}     ${w_list}     ${statusboard_type[1]}  ${queue_list2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sb_id2}  ${resp.json()}

    # ${resp}=  Create QueueSet  ${s_name2[0]}  ${s_name2[1]}  ${s_desc2}  ${fieldList}   ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${qid1}   ${wl_status[0]}  ${statusboard_type[1]}   ${queue_list2}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sb_id2}  ${resp.json()}

    ${s_name3}=  FakerLibrary.Words  nb=2
    ${s_desc3}=  FakerLibrary.Sentence
    ${service_list3}=  Create list  ${s_id3}
    Set Suite Variable  ${service_list3}

    ${dd}=   Create Dictionary   id=${qid1}
    ${queue}=  Create List   ${dd}
    ${ss}=   Create Dictionary  id=${s_id1} 
    ${ser}=  Create List  ${ss}
    ${dept1}=   Create Dictionary  departmentId=${depid1}
    ${dep}=  Create List   ${dept1}
    ${w_list}=   Create List    ${wl_status[0]}
    ${resp}=  Create QueueSet for Branch   ${s_name3[0]}  ${s_name3[1]}   ${s_desc3}   ${fieldList}   ${dep}    ${ser}     ${queue}    ${EMPTY}   ${EMPTY}     ${w_list}    ${statusboard_type[0]}  ${service_list3}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sb_id3}  ${resp.json()}

    # ${resp}=  Create QueueSet  ${s_name3[0]}  ${s_name3[1]}  ${s_desc3}  ${fieldList}    ${EMPTY}  ${s_id1}   ${EMPTY}   ${EMPTY}   ${EMPTY}   ${wl_status[0]}   ${statusboard_type[0]}   ${service_list3}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sb_id3}  ${resp.json()}

    ${resp}=  Get WaitlistQueueSets
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${sbq_id1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}  ${s_name1[0]}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}  ${s_name1[1]}
    Should Be Equal As Strings  ${resp.json()[0]['description']}  ${s_desc1}
    Should Be Equal As Strings  ${resp.json()[0]['fieldList'][0]['name']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()[0]['fieldList'][0]['label']}  ${bool[1]}   
    Should Be Equal As Strings  ${resp.json()[0]['fieldList'][0]['order']}  ${order1}   
    Should Be Equal As Strings  ${resp.json()[0]['fieldList'][0]['displayName']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()[0]['fieldList'][0]['defaultValue']}  ${Values[2]}  
    Should Be Equal As Strings  ${resp.json()[0]['fieldList'][1]['name']}  ${Values[3]}   
    Should Be Equal As Strings  ${resp.json()[0]['fieldList'][1]['label']}  ${bool[0]}   
    Should Be Equal As Strings  ${resp.json()[0]['fieldList'][1]['order']}  ${order2}   
    Should Be Equal As Strings  ${resp.json()[0]['fieldList'][1]['displayName']}  ${Values[4]}   
    Should Be Equal As Strings  ${resp.json()[0]['fieldList'][1]['defaultValue']}  ${Values[5]}
    Should Be Equal As Strings  ${resp.json()[1]['id']}  ${sb_id2}
    Should Be Equal As Strings  ${resp.json()[1]['name']}  ${s_name2[0]}
    Should Be Equal As Strings  ${resp.json()[1]['displayName']}  ${s_name2[1]}
    Should Be Equal As Strings  ${resp.json()[1]['description']}  ${s_desc2}
    Should Be Equal As Strings  ${resp.json()[1]['fieldList'][0]['name']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()[1]['fieldList'][0]['label']}  ${bool[1]}   
    Should Be Equal As Strings  ${resp.json()[1]['fieldList'][0]['order']}  ${order1}   
    Should Be Equal As Strings  ${resp.json()[1]['fieldList'][0]['displayName']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()[1]['fieldList'][0]['defaultValue']}  ${Values[2]}  
    Should Be Equal As Strings  ${resp.json()[1]['fieldList'][1]['name']}  ${Values[3]}   
    Should Be Equal As Strings  ${resp.json()[1]['fieldList'][1]['label']}  ${bool[0]}   
    Should Be Equal As Strings  ${resp.json()[1]['fieldList'][1]['order']}  ${order2}   
    Should Be Equal As Strings  ${resp.json()[1]['fieldList'][1]['displayName']}  ${Values[4]}   
    Should Be Equal As Strings  ${resp.json()[1]['fieldList'][1]['defaultValue']}  ${Values[5]}
    Should Be Equal As Strings  ${resp.json()[2]['id']}  ${sb_id3}
    Should Be Equal As Strings  ${resp.json()[2]['name']}  ${s_name3[0]}
    Should Be Equal As Strings  ${resp.json()[2]['displayName']}  ${s_name3[1]}
    Should Be Equal As Strings  ${resp.json()[2]['description']}  ${s_desc3}
    Should Be Equal As Strings  ${resp.json()[2]['fieldList'][0]['name']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()[2]['fieldList'][0]['label']}  ${bool[1]}   
    Should Be Equal As Strings  ${resp.json()[2]['fieldList'][0]['order']}  ${order1}   
    Should Be Equal As Strings  ${resp.json()[2]['fieldList'][0]['displayName']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()[2]['fieldList'][0]['defaultValue']}  ${Values[2]}  
    Should Be Equal As Strings  ${resp.json()[2]['fieldList'][1]['name']}  ${Values[3]}   
    Should Be Equal As Strings  ${resp.json()[2]['fieldList'][1]['label']}  ${bool[0]}   
    Should Be Equal As Strings  ${resp.json()[2]['fieldList'][1]['order']}  ${order2}   
    Should Be Equal As Strings  ${resp.json()[2]['fieldList'][1]['displayName']}  ${Values[4]}   
    Should Be Equal As Strings  ${resp.json()[2]['fieldList'][1]['defaultValue']}  ${Values[5]}
    
JD-TC-GetWaitlistQueueSets -UH1
    [Documentation]   Provider Get QueueSets without login  
    ${resp}=  Get WaitlistQueueSets
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-GetWaitlistQueueSets -UH2
    [Documentation]   Consumer Get QueueSets
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get WaitlistQueueSets
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"
