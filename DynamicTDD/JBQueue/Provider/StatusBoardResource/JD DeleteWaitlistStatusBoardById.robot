*** Settings ***

Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      StatusBoard
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

JD-TC-DeleteWaitlistStatusBoardById-1
	[Documentation]  Delete a StatusBoard

    ${firstname}  ${lastname}  ${PUSERNAME_B}  ${LoginId}=  Provider Signup
    Set Suite Variable  ${PUSERNAME_B}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

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
    ${resp}=  Create QueueSet for provider   ${s_name[0]}  ${s_name[1]}   ${s_desc}   ${fieldList}     ${ser}     ${queue}    ${EMPTY}   ${EMPTY}     ${w_list}    ${statusboard_type[1]}      ${queue_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sbq_id1}  ${resp.json()}

    ${SERVICE3}=     generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE3}

    ${s_id3}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable  ${s_id3} 
    ${order1}=   Random Int   min=0   max=1
    ${Values}=  FakerLibrary.Words  	nb=3
    ${fieldList}=  Create Fieldlist For QueueSet  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${bool[1]}  ${order1}
    Log  ${fieldList}
    ${s_name}=  FakerLibrary.Words  nb=2
    ${s_desc}=  FakerLibrary.Sentence
    ${service_list}=  Create list  ${s_id3}
    Set Suite Variable  ${service_list}

    ${sid}=    Create Dictionary   id=${s_id3} 
    ${sid1}=   Create List   ${sid}
    ${w_list}=   Create List    ${wl_status[0]}
    ${que}=   Create List
    ${resp}=  Create QueueSet for provider   ${s_name[0]}  ${s_name[1]}  ${s_desc}  ${fieldList}     ${sid1}     ${que}    ${EMPTY}   ${EMPTY}    ${w_list}    ${statusboard_type[0]}      ${service_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sbq_id2}  ${resp.json()}

    ${Positions}=  FakerLibrary.Words  	nb=3
    ${matric_list}=  Create Metric For Status Board  ${Positions[0]}  ${sbq_id1}  ${Positions[1]}  ${sbq_id2}
    Log  ${matric_list}
    ${Data}=  FakerLibrary.Words  	nb=3
    ${resp}=  Create Status Board waitlist  ${Data[0]}  ${Data[1]}  ${Data[2]}  ${matric_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sb_id}  ${resp.json()}

    ${resp}=   Delete Waitlist Status Board By Id    ${sb_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get WaitlistStatus Boards
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   []


JD-TC-DeleteWaitlistStatusBoardById -UH1
    [Documentation]   Provider Delete a Waitlist StatusBoard without login  
    ${resp}=  Delete Waitlist Status Board By Id  ${sb_id}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-DeleteWaitlistStatusBoardById -UH2
    [Documentation]   Consumer delete a Waitlist StatusBoard
    
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

    ${resp}=  Delete Waitlist Status Board By Id  ${sb_id}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-DeleteWaitlistStatusBoardById-UH3
    [Documentation]  Delete a Waitlist StatusBoard by id which is not exist
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${invalid_id}=   Random Int   min=-10   max=0
    ${resp}=  Delete Waitlist Status Board By Id  ${invalid_id}
    Should Be Equal As Strings  ${resp.status_code}  422
    Log  ${resp.json()}
    Should Be Equal As Strings  "${resp.json()}"  "${STATUS_BOARD_DIMENSION_NOT_EXIST}"

JD-TC-DeleteWaitlistStatusBoardById-UH4
    [Documentation]  Delete a StatusBoard by id of another provider
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME25}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Delete Waitlist Status Board By Id  ${sb_id}
    Should Be Equal As Strings  ${resp.status_code}  422
    Log  ${resp.json()}
    Should Be Equal As Strings  "${resp.json()}"  "${STATUS_BOARD_DIMENSION_NOT_EXIST}"
