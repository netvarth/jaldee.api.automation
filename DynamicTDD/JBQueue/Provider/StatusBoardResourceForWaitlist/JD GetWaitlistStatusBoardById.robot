*** Settings ***

Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      StatusBoard
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
JD-TC-GetStatusBoardById-1

    [Documentation]  Create a StatusBoard and get it by id
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_service   ${PUSERNAME179}
    clear_location  ${PUSERNAME179}
    clear_queue   ${PUSERNAME179}
    clear_Statusboard  ${PUSERNAME179}
    clear_Addon  ${PUSERNAME179}
    ${resp}=  Create Sample Queue  
    Set Suite Variable  ${qid1}   ${resp['queue_id']}
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
    ${resp}=  Create QueueSet for provider   ${s_name[0]}  ${s_name[1]}   ${s_desc}   ${fieldList}     ${ser}     ${queue}    ${EMPTY}   ${EMPTY}     ${w_list}    ${statusboard_type[1]}      ${queue_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sbq_id1}  ${resp.json()}
    # ${Positions[1]}  ${sbq_id2}
    ${Positions}=  FakerLibrary.Words  	nb=3
    ${matric_list}=  Create Matric For Status Board  ${Positions[0]}  ${sbq_id1}  
    Log  ${matric_list}
    ${Data}=  FakerLibrary.Words  	nb=3
    ${resp}=   Create Status Board waitlist    ${Data[0]}  ${Data[1]}  ${Data[2]}  ${matric_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sb_id}  ${resp.json()}
    ${resp}=  Get WaitlistStatus Board By Id  ${sb_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${sb_id}
    Should Be Equal As Strings  ${resp.json()['name']}  ${Data[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}  ${Data[1]}
    Should Be Equal As Strings  ${resp.json()['layout']}  ${Data[2]}
    Should Be Equal As Strings  ${resp.json()['metric'][0]['sbId']}  ${sbq_id1}  
    Should Be Equal As Strings  ${resp.json()['metric'][0]['position']}  ${Positions[0]}
    Should Be Equal As Strings  ${resp.json()['metric'][0]['queueSet']['queryString']}   queue-eq=${qid1}&waitlistStatus-eq=checkedIn&label-eq=::
    
JD-TC-GetStatusBoardById -UH1
    [Documentation]   Provider get a Status Board by id without login  
    ${resp}=  Get WaitlistStatus Board By Id  ${sb_id}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-GetStatusBoardById -UH2
    [Documentation]   Consumer get a Status Board
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get WaitlistStatus Board By Id  ${sb_id}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-GetStatusBoardById-UH3
    [Documentation]  Get a Status Board by id which is not exist
    ${resp}=  ProviderLogin  ${PUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${invalid_id}=   Random Int   min=-10   max=0
    ${resp}=  Get WaitlistStatus Board By Id  ${sb_id}
    Should Be Equal As Strings  ${resp.status_code}  422
    Log  ${resp.json()}
    Should Be Equal As Strings  "${resp.json()}"  "${STATUS_BOARD_DIMENSION_NOT_EXIST}"

JD-TC-GetStatusBoardById-UH4
    [Documentation]  Get a Status Board by id of another provider
    ${resp}=  ProviderLogin  ${PUSERNAME10}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get WaitlistStatus Board By Id  ${sb_id}
    Should Be Equal As Strings  ${resp.status_code}  422
    Log  ${resp.json()}
    Should Be Equal As Strings  "${resp.json()}"  "${STATUS_BOARD_DIMENSION_NOT_EXIST}" 
