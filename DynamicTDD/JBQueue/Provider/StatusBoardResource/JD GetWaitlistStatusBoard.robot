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
Resource        /ebs/TDD/ProviderConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot

*** Variables ***
@{service_names}

*** Test Cases ***
JD-TC-GetWaitlistStatusBoard-1

    [Documentation]  Create  Waitlist StatusBoards and get status boards

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
    ${resp}=  Create QueueSet for provider   ${s_name[0]}  ${s_name[1]}   ${s_desc}   ${fieldList}      ${ser}     ${queue}    ${EMPTY}   ${EMPTY}     ${w_list}    ${statusboard_type[1]}      ${queue_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sbq_id1}  ${resp.json()}

    ${SERVICE1}=    generate_unique_service_name  ${service_names} 
    Append To List  ${service_names}  ${SERVICE1}
    Set Suite Variable  ${SERVICE1}

    ${SERVICE2}=     generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    Set Suite Variable  ${SERVICE2}

    ${SERVICE3}=     generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE3}
    Set Suite Variable  ${SERVICE3}

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
    # ${dept}=  Create List
    ${que}=   Create List
    ${resp}=  Create QueueSet for provider   ${s_name[0]}  ${s_name[1]}  ${s_desc}  ${fieldList}      ${sid1}     ${que}    ${EMPTY}   ${EMPTY}    ${w_list}    ${statusboard_type[0]}      ${service_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sbq_id2}  ${resp.json()}

    ${Positions}=  FakerLibrary.Words  	nb=3
    ${matric_list}=  Create Metric For Status Board  ${Positions[0]}  ${sbq_id1}
    Log  ${matric_list}
    ${Data}=  FakerLibrary.Words  	nb=3
    ${resp}=  Create Status Board waitlist  ${Data[0]}  ${Data[1]}  ${Data[2]}  ${matric_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sb_id1}  ${resp.json()}

    ${Positions1}=  FakerLibrary.Words  	nb=3
    ${matric_list1}=  Create Metric For Status Board  ${Positions1[0]}  ${sbq_id2}
    Log  ${matric_list1}
    ${Data1}=  FakerLibrary.Words  	nb=3
    ${resp}=  Create Status Board waitlist  ${Data1[0]}  ${Data1[1]}  ${Data1[2]}  ${matric_list1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sb_id2}  ${resp.json()}

     ${resp}=  Get WaitlistStatus Boards
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${sb_id1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}  ${Data[0]}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}  ${Data[1]}
    Should Be Equal As Strings  ${resp.json()[0]['layout']}  ${Data[2]}
    Should Be Equal As Strings  ${resp.json()[0]['metric'][0]['sbId']}  ${sbq_id1}  
    Should Be Equal As Strings  ${resp.json()[0]['metric'][0]['position']}  ${Positions[0]}
    Should Be Equal As Strings  ${resp.json()[0]['metric'][0]['queueSet']['queryString']}    queue-eq=${qid1}&waitlistStatus-eq=checkedIn&label-eq=::
    Should Be Equal As Strings  ${resp.json()[1]['id']}  ${sb_id2}
    Should Be Equal As Strings  ${resp.json()[1]['name']}  ${Data1[0]}
    Should Be Equal As Strings  ${resp.json()[1]['displayName']}  ${Data1[1]}
    Should Be Equal As Strings  ${resp.json()[1]['layout']}  ${Data1[2]}
    Should Be Equal As Strings  ${resp.json()[1]['metric'][0]['sbId']}  ${sbq_id2}  
    Should Be Equal As Strings  ${resp.json()[1]['metric'][0]['position']}  ${Positions1[0]}  
    Should Be Equal As Strings  ${resp.json()[1]['metric'][0]['queueSet']['queryString']}   service-eq=${s_id3}&waitlistStatus-eq=checkedIn&label-eq=::
    ${Positions2}=  FakerLibrary.Words  	nb=3
    ${matric_list2}=  Create Metric For Status Board  ${Positions2[0]}  ${sbq_id2}
    Log  ${matric_list2}
    ${Data2}=  FakerLibrary.Words  	nb=3
    ${resp}=  Create Status Board waitlist  ${Data2[0]}  ${Data2[1]}  ${Data2[2]}  ${matric_list2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sb_id3}  ${resp.json()}

    ${resp}=   Get WaitlistStatus Boards
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${sb_id1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}  ${Data[0]}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}  ${Data[1]}
    Should Be Equal As Strings  ${resp.json()[0]['layout']}  ${Data[2]}
    Should Be Equal As Strings  ${resp.json()[0]['metric'][0]['sbId']}  ${sbq_id1}  
    Should Be Equal As Strings  ${resp.json()[0]['metric'][0]['position']}  ${Positions[0]}
    Should Be Equal As Strings  ${resp.json()[0]['metric'][0]['queueSet']['queryString']}    queue-eq=${qid1}&waitlistStatus-eq=checkedIn&label-eq=::  
    Should Be Equal As Strings  ${resp.json()[1]['id']}  ${sb_id2}
    Should Be Equal As Strings  ${resp.json()[1]['name']}  ${Data1[0]}
    Should Be Equal As Strings  ${resp.json()[1]['displayName']}  ${Data1[1]}
    Should Be Equal As Strings  ${resp.json()[1]['layout']}  ${Data1[2]}
    Should Be Equal As Strings  ${resp.json()[1]['metric'][0]['sbId']}  ${sbq_id2}  
    Should Be Equal As Strings  ${resp.json()[1]['metric'][0]['position']}  ${Positions1[0]} 
    Should Be Equal As Strings  ${resp.json()[1]['metric'][0]['queueSet']['queryString']}   service-eq=${s_id3}&waitlistStatus-eq=checkedIn&label-eq=::
    Should Be Equal As Strings  ${resp.json()[2]['id']}  ${sb_id3}
    Should Be Equal As Strings  ${resp.json()[2]['name']}  ${Data2[0]}
    Should Be Equal As Strings  ${resp.json()[2]['displayName']}  ${Data2[1]}
    Should Be Equal As Strings  ${resp.json()[2]['layout']}  ${Data2[2]}
    Should Be Equal As Strings  ${resp.json()[2]['metric'][0]['sbId']}  ${sbq_id2}  
    Should Be Equal As Strings  ${resp.json()[2]['metric'][0]['position']}  ${Positions2[0]} 
    Should Be Equal As Strings  ${resp.json()[2]['metric'][0]['queueSet']['queryString']}   service-eq=${s_id3}&waitlistStatus-eq=checkedIn&label-eq=::


JD-TC-GetWaitlistStatusBoard -UH1
    [Documentation]   Provider Get Labels without login  
    ${resp}=  Get WaitlistStatus Boards
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-GetWaitlistStatusBoard -UH2
    [Documentation]   Consumer Get Labels

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

    ${resp}=  Get WaitlistStatus Boards
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"
