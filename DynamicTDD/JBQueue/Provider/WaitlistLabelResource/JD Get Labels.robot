*** Settings ***

Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      Label
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
*** Test Cases ***
JD-TC-GetLabels-1
	[Documentation]  Get Labels by a valid provider
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME14}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_Label  ${HLPUSERNAME14}  
    ${Values}=  FakerLibrary.Words  	nb=9
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${Values[3]}  ${Values[4]}  ${Values[5]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Values[6]}  ${Values[2]}  ${Values[7]}  ${Values[4]}  ${Values[8]}
    ${l_name}=  FakerLibrary.Words  nb=2
    ${l_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${l_name[0]}  ${l_name[1]}  ${l_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}

    ${Values2}=  FakerLibrary.Words  nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values2[0]}  ${Values2[1]}
    Set Suite Variable  ${ValueSet}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values2[0]}  ${Values2[2]}
    Set Suite Variable  ${NotificationSet}
    ${l_name2}=  FakerLibrary.Words  nb=2
    Set Suite Variable  ${l_name2}
    ${l_desc2}=  FakerLibrary.Sentence
    Set Suite Variable  ${l_desc2}
    ${resp}=  Create Label  ${l_name2[0]}  ${l_name2[1]}  ${l_desc2}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id2}  ${resp.json()}
    ${resp}=  Get Labels
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${label_id}
    Should Be Equal As Strings  ${resp.json()[0]['label']}  ${l_name[0]}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}  ${l_name[1]}
    Should Be Equal As Strings  ${resp.json()[0]['description']}  ${l_desc}
    Should Be Equal As Strings  ${resp.json()[0]['valueSet'][0]['value']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()[0]['valueSet'][0]['shortValue']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()[0]['valueSet'][1]['value']}  ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()[0]['valueSet'][1]['shortValue']}  ${Values[3]}   
    Should Be Equal As Strings  ${resp.json()[0]['valueSet'][2]['value']}  ${Values[4]}   
    Should Be Equal As Strings  ${resp.json()[0]['valueSet'][2]['shortValue']}  ${Values[5]}   
    Should Be Equal As Strings  ${resp.json()[0]['notification'][0]['values']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()[0]['notification'][0]['messages']}  ${Values[6]}   
    Should Be Equal As Strings  ${resp.json()[0]['notification'][1]['values']}  ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()[0]['notification'][1]['messages']}  ${Values[7]}   
    Should Be Equal As Strings  ${resp.json()[0]['notification'][2]['values']}  ${Values[4]}   
    Should Be Equal As Strings  ${resp.json()[0]['notification'][2]['messages']}  ${Values[8]}
    Should Be Equal As Strings  ${resp.json()[1]['id']}  ${label_id2}
    Should Be Equal As Strings  ${resp.json()[1]['label']}  ${l_name2[0]}
    Should Be Equal As Strings  ${resp.json()[1]['displayName']}  ${l_name2[1]}
    Should Be Equal As Strings  ${resp.json()[1]['description']}  ${l_desc2}
    Should Be Equal As Strings  ${resp.json()[1]['valueSet'][0]['value']}  ${Values2[0]}   
    Should Be Equal As Strings  ${resp.json()[1]['valueSet'][0]['shortValue']}  ${Values2[1]}   
    Should Be Equal As Strings  ${resp.json()[1]['notification'][0]['values']}  ${Values2[0]}   
    Should Be Equal As Strings  ${resp.json()[1]['notification'][0]['messages']}  ${Values2[2]}   

JD-TC-GetLabels -UH1
    [Documentation]   Provider Get Labels without login  
    ${resp}=  Get Labels
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-GetLabels -UH2
    [Documentation]   Provider consumer Get Labels
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${account_id}=  get_acc_id  ${HLPUSERNAME4}

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
    
    ${resp}=  Get Labels
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

