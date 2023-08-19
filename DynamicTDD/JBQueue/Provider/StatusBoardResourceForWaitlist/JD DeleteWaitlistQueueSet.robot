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
JD-TC-JD DeleteWaitlistQueueSet-1
	[Documentation]  Delete a QueueSet by provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME114}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_service   ${PUSERNAME114}
    clear_location  ${PUSERNAME114}
    clear_queue   ${PUSERNAME114}
    clear_Statusboard  ${PUSERNAME114}
    clear_Addon  ${PUSERNAME114}
    ${resp}=  Create Sample Queue
    Set Suite Variable  ${qid1}   ${resp['queue_id']}
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
    ${queue_list}=  Create list  ${qid1}
    Set Suite Variable  ${queue_list} 

    ${dd}=   Create Dictionary   id=${qid1}
    ${queue}=  Create List   ${dd} 
    ${ser}=  Create List
    ${w_list}=   Create List    ${wl_status[0]}
    ${resp}=  Create QueueSet for provider   ${s_name[0]}  ${s_name[1]}   ${s_desc}   ${fieldList}      ${ser}     ${queue}    ${EMPTY}   ${EMPTY}     ${w_list}    ${statusboard_type[1]}      ${queue_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sbq_id1}  ${resp.json()}
    ${resp}=  Delete WaitlistQueueSet By Id  ${sbq_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get WaitlistQueueSet By Id  ${sbq_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${QUEUE_SET_NOT_EXIST}"

    ${resp}=  Get WaitlistQueueSets
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []

JD-TC-JD DeleteWaitlistQueueSet -UH1
    [Documentation]   Provider Delete a Waitlist QueueSet without login  
    ${resp}=  Delete WaitlistQueueSet By Id  ${sbq_id1}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-JD DeleteWaitlistQueueSet -UH2
    [Documentation]   Consumer delete a Waitlist QueueSet
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Delete WaitlistQueueSet By Id   ${sbq_id1}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-JD DeleteWaitlistQueueSet-UH3
    [Documentation]  Delete a Waitlist QueueSet by id which is not exist
    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${invalid_id}=   Random Int   min=-10   max=0
    ${resp}=  Delete WaitlistQueueSet By Id  ${invalid_id}
    Should Be Equal As Strings  ${resp.status_code}  422
    Log  ${resp.json()}
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_SET_NOT_EXIST}"

JD-TC-JD DeleteWaitlistQueueSet-UH4
    [Documentation]  Delete a QueueSet by id of another provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME114}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${order1}=   Random Int   min=0   max=1
    ${Values}=  FakerLibrary.Words  	nb=3
    ${fieldList}=  Create Fieldlist For QueueSet  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${bool[1]}  ${order1}
    Log  ${fieldList}
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
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sbq_id}  ${resp.json()}
    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME10}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Delete WaitlistQueueSet By Id   ${sbq_id}
    Should Be Equal As Strings  ${resp.status_code}  422
    Log  ${resp.json()}
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_SET_NOT_EXIST}"
