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
JD-TC-UpdateLabel-1
	[Documentation]  Update full details of a  label created by a provider
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_Label  ${HLPUSERNAME15}
    ${Values}=  FakerLibrary.Words  	nb=9
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${Values[3]}  ${Values[4]}  ${Values[5]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Values[6]}  ${Values[2]}  ${Values[7]}  ${Values[4]}  ${Values[8]}
    ${l_name}=  FakerLibrary.Words  nb=2
    ${l_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${l_name[0]}  ${l_name[1]}  ${l_desc}  ${ValueSet}  ${NotificationSet}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${label_id}  ${resp.json()}

    ${Values2}=  FakerLibrary.Words  	nb=6
    Set Suite Variable  ${Values2}
    ${ValueSet}=  Create ValueSet For Label  ${Values2[0]}  ${Values2[1]}  ${Values2[2]}  ${Values2[3]}
    Set Suite Variable  ${ValueSet}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values2[0]}  ${Values2[4]}  ${Values2[2]}  ${Values2[5]}
    Set Suite Variable  ${NotificationSet}
    ${l_desc2}=  FakerLibrary.Sentence
    Set Suite Variable  ${l_desc2}
    ${l_name2}=  FakerLibrary.Words  nb=2
    Set Suite Variable  ${l_name2}
    ${resp}=  Update Label  ${label_id}  ${l_name2[0]}  ${l_name2[1]}  ${l_desc2}  ${ValueSet}  ${NotificationSet}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Label By Id  ${label_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}  ${l_name2[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}  ${l_name2[1]}
    Should Be Equal As Strings  ${resp.json()['description']}  ${l_desc2}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}  ${Values2[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}  ${Values2[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}  ${Values2[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}  ${Values2[3]}     
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}  ${Values2[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Values2[4]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}  ${Values2[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Values2[5]}   

JD-TC-UpdateLabel-2
	[Documentation]  Update only few details of a label created by a provider
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_Label  ${HLPUSERNAME15}
    ${Values}=  FakerLibrary.Words  	nb=9
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${Values[3]}  ${Values[4]}  ${Values[5]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Values[6]}  ${Values[2]}  ${Values[7]}  ${Values[4]}  ${Values[8]}
    ${l_name}=  FakerLibrary.Words  nb=2
    ${l_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${l_name[0]}  ${l_name[1]}  ${l_desc}  ${ValueSet}  ${NotificationSet}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${label_id}  ${resp.json()}

    ${l_desc2}=  FakerLibrary.Sentence
    Set Suite Variable  ${l_desc2}
    ${l_name2}=  FakerLibrary.Words  nb=2
    Set Suite Variable  ${l_name2}
    ${resp}=  Update Label  ${label_id}  ${l_name2[0]}  ${l_name2[1]}  ${l_desc2}  ${ValueSet}  ${NotificationSet}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Label By Id  ${label_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}  ${l_name2[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}  ${l_name2[1]}
    Should Be Equal As Strings  ${resp.json()['description']}  ${l_desc2}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}  ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}  ${Values[3]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}  ${Values[4]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}  ${Values[5]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Values[6]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}  ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Values[7]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}  ${Values[4]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Values[8]}

JD-TC-UpdateLabel-3
	[Documentation]  Update  label with integer value set
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_Label  ${HLPUSERNAME15}
    ${Values}=  FakerLibrary.Words  	nb=9
    Set Suite Variable  ${Values}
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${Values[3]}  ${Values[4]}  ${Values[5]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Values[6]}  ${Values[2]}  ${Values[7]}  ${Values[4]}  ${Values[8]}
    ${l_name}=  FakerLibrary.Words  nb=2
    ${l_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${l_name[0]}  ${l_name[1]}  ${l_desc}  ${ValueSet}  ${NotificationSet}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${label_id}  ${resp.json()}

    ${IntegerValue}=   Random Int   min=10   max=20
    Set Suite Variable  ${IntegerValue}
    ${ValueSet}=  Create ValueSet For Label  ${IntegerValue}  ${Values[0]}
    Set Suite Variable  ${ValueSet}
    ${NotificationSet}=  Create NotificationSet For Label  ${IntegerValue}  ${Values[1]}
    Set Suite Variable  ${NotificationSet}
    ${l_desc2}=  FakerLibrary.Sentence
    Set Suite Variable  ${l_desc2}
    ${l_name2}=  FakerLibrary.Words  nb=2
    Set Suite Variable  ${l_name2}
    ${resp}=  Update Label  ${label_id}  ${l_name2[0]}  ${l_name2[1]}  ${l_desc2}  ${ValueSet}  ${NotificationSet}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Label By Id  ${label_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}  ${l_name2[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}  ${l_name2[1]}
    Should Be Equal As Strings  ${resp.json()['description']}  ${l_desc2}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}  ${IntegerValue} 
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}  ${Values[0]}    
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}  ${IntegerValue}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Values[1]}   

JD-TC-UpdateLabel-UH1
    [Documentation]  Upadte a Label with integer label name
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${integer_id}=   Random Int   min=10   max=20
    ${resp}=  Update Label  ${label_id}  ${integer_id}  ${l_name2[1]}  ${l_desc2}  ${ValueSet}  ${NotificationSet}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${LABEL_NOT_START_WITH_NUMBERS}"

    # ${resp}=  Get Label By Id  ${label_id}
    # Should Be Equal As Strings  ${resp.json()['id']}  ${label_id}
    # Should Be Equal As Strings  ${resp.json()['label']}  ${integer_id}
    # Should Be Equal As Strings  ${resp.json()['displayName']}  ${l_name2[1]}
    # Should Be Equal As Strings  ${resp.json()['description']}  ${l_desc2}
    # Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}  ${IntegerValue} 
    # Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}  ${Values[0]}    
    # Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}  ${IntegerValue}   
    # Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Values[1]} 

JD-TC-UpdateLabel-UH2
    [Documentation]  Upadte a Label by id with invalid notification set
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${Values}=  FakerLibrary.Words  	nb=10
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${Values[3]}  ${Values[4]}  ${Values[5]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[9]}  ${Values[6]}  ${Values[2]}  ${Values[7]}  ${Values[4]}  ${Values[8]}
    ${resp}=  Update Label  ${label_id}  ${l_name2[0]}  ${l_name2[1]}  ${l_desc2}  ${ValueSet}  ${NotificationSet}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${LABEL_NOTIFICATION_VALUE_NOT_EXIST}"

JD-TC-UpdateLabel -UH3
    [Documentation]   Provider update a label without login  
    ${resp}=  Update Label  ${label_id}  ${l_name2[0]}  ${l_name2[1]}  ${l_desc2}  ${ValueSet}  ${NotificationSet}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-UpdateLabel -UH4
    [Documentation]   Provider Consumer trying to update a label
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

    ${resp}=  Update Label  ${label_id}  ${l_name2[0]}  ${l_name2[1]}  ${l_desc2}  ${ValueSet}  ${NotificationSet}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-UpdateLabel-UH5
    [Documentation]  Upadte a Label which is not exist
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${invalid_id}=   Random Int   min=-10   max=0
    ${resp}=  Update Label  ${invalid_id}  ${l_name2[0]}  ${l_name2[1]}  ${l_desc2}  ${ValueSet}  ${NotificationSet}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${LABEL_NOT_EXIST}"

JD-TC-UpdateLabel-UH6
    [Documentation]  Upadte a Label by id of another provider
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME16}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Label  ${label_id}  ${l_name2[0]}  ${l_name2[1]}  ${l_desc2}  ${ValueSet}  ${NotificationSet}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${LABEL_NOT_EXIST}"