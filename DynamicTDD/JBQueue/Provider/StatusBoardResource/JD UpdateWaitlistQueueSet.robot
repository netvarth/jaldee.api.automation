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

JD-TC-UpdateWaitlistQueueSet-1
	[Documentation]  Update few details of a QueueSet
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

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

JD-TC-UpdateWaitlistQueueSet -UH1
    [Documentation]   Provider update a QueueSet without login  
    ${resp}=  Update QueueSet Waitlist for Provider   ${sb_id}  ${s_name1[0]}  ${s_name1[1]}  ${s_desc1}  ${fieldList}     ${sid1}     ${que}    ${EMPTY}   ${EMPTY}    ${w_list}    ${statusboard_type[0]}      ${service_list}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-UpdateWaitlistQueueSet -UH2
    [Documentation]   Consumer trying to update a QueueSet

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

    ${resp}=  Update QueueSet Waitlist for Provider   ${sb_id}  ${s_name1[0]}  ${s_name1[1]}  ${s_desc1}  ${fieldList}    ${sid1}     ${que}    ${EMPTY}   ${EMPTY}    ${w_list}    ${statusboard_type[0]}      ${service_list}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-UpdateWaitlistQueueSet-UH3
    [Documentation]  Upadte a QueueSet which is not exist
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${invalid_id}=   Random Int   min=-10   max=0
    ${resp}=  Update QueueSet Waitlist for Provider   ${invalid_id}  ${s_name1[0]}  ${s_name1[1]}  ${s_desc1}  ${fieldList}     ${sid2}     ${que}    ${EMPTY}   ${EMPTY}    ${w_list}    ${statusboard_type[0]}      ${service_list}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_SET_NOT_EXIST}"

JD-TC-UpdateWaitlistQueueSet-UH4
    [Documentation]  Update a QueueSet by id of another provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME10}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update QueueSet Waitlist for Provider    ${sb_id}  ${s_name1[0]}  ${s_name1[1]}  ${s_desc1}  ${fieldList}    ${sid2}     ${que}    ${EMPTY}   ${EMPTY}    ${w_list}    ${statusboard_type[0]}      ${service_list}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_SET_NOT_EXIST}"