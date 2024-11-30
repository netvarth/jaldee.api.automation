*** Settings ***

Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      Label
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
*** Test Cases ***
JD-TC-CreateLabel-1
	[Documentation]  Create a label for a valid provider
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME13}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_Label  ${HLPUSERNAME13}
    ${Values}=  FakerLibrary.Words  	nb=9
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${Values[3]}  ${Values[4]}  ${Values[5]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Values[6]}  ${Values[2]}  ${Values[7]}  ${Values[4]}  ${Values[8]}
    ${l_name}=  FakerLibrary.Words  nb=2
    ${l_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${l_name[0]}  ${l_name[1]}  ${l_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}
    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}  ${l_name[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}  ${l_name[1]}
    Should Be Equal As Strings  ${resp.json()['description']}  ${l_desc}
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

JD-TC-CreateLabel-2
	[Documentation]  Create more labels for a single provider
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME13}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${Values}=  FakerLibrary.Words  nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${Values[1]}
    Set Suite Variable  ${ValueSet}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Values[2]}
    Set Suite Variable  ${NotificationSet}
    ${l_name}=  FakerLibrary.Words  nb=2
    Set Suite Variable  ${l_name}
    ${l_desc}=  FakerLibrary.Sentence
    Set Suite Variable  ${l_desc}
    ${resp}=  Create Label  ${l_name[0]}  ${l_name[1]}  ${l_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}
    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}  ${l_name[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}  ${l_name[1]}
    Should Be Equal As Strings  ${resp.json()['description']}  ${l_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Values[2]}   

JD-TC-CreateLabel-3
	[Documentation]  Create a label with integer valueSet
    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_Label  ${PUSERNAME6}
    ${IntegerValue}=   Random Int   min=10   max=20
    ${Values}=  FakerLibrary.Words  	nb=2
    ${ValueSet}=  Create ValueSet For Label  ${IntegerValue}  ${Values[0]}
    ${NotificationSet}=  Create NotificationSet For Label  ${IntegerValue}  ${Values[1]}
    ${l_name}=  FakerLibrary.Words  nb=2
    ${l_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${l_name[0]}  ${l_name[1]}  ${l_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}
    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}  ${l_name[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}  ${l_name[1]}
    Should Be Equal As Strings  ${resp.json()['description']}  ${l_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}  ${IntegerValue} 
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}  ${Values[0]}    
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}  ${IntegerValue}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Values[1]}   

JD-TC-CreateLabel-UH1
    [Documentation]  Create a label with name in integer
    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${integer_lname}=   Random Int   min=10   max=20
    ${IntegerValue}=   Random Int   min=10   max=20
    ${Values}=  FakerLibrary.Words  	nb=2
    ${ValueSet}=  Create ValueSet For Label  ${IntegerValue}  ${Values[0]}
    ${NotificationSet}=  Create NotificationSet For Label  ${IntegerValue}  ${Values[1]}
    ${resp}=  Create Label  ${integer_lname}  ${l_name[1]}  ${l_desc}  ${ValueSet}  ${NotificationSet}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${LABEL_NOT_START_WITH_NUMBERS}"

    # Set Test Variable  ${label_id}  ${resp.json()}
    # ${resp}=  Get Label By Id  ${label_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.json()['id']}  ${label_id}
    # Should Be Equal As Strings  ${resp.json()['label']}  ${integer_lname}
    # Should Be Equal As Strings  ${resp.json()['displayName']}  ${l_name[1]}
    # Should Be Equal As Strings  ${resp.json()['description']}  ${l_desc}
    # Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}  ${IntegerValue} 
    # Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}  ${Values[0]}    
    # Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}  ${IntegerValue}   
    # Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Values[1]}  


JD-TC-CreateLabel -UH2
    [Documentation]   Provider create a label without login  
    ${resp}=  Create Label  ${l_name[0]}  ${l_name[1]}  ${l_desc}  ${ValueSet}  ${NotificationSet}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-CreateLabel -UH3
    [Documentation]   Provider Consumer create a label.
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

    ${resp}=  Create Label  ${l_name[0]}  ${l_name[1]}  ${l_desc}  ${ValueSet}  ${NotificationSet}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-CreateLabel-UH4
    [Documentation]  Create a label which is already created
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME13}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Label  ${l_name[0]}  ${l_name[1]}  ${l_desc}  ${ValueSet}  ${NotificationSet}
    Should Be Equal As Strings  ${resp.status_code}  422
    Log  ${resp.json()}
    Should Be Equal As Strings  "${resp.json()}"  "${LABEL_NAME_ALREADY_EXIST}"

JD-TC-CreateLabel-UH5
    [Documentation]  Create a label using notification set for a invalid value set
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME13}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_Label  ${HLPUSERNAME13}
    ${Values}=  FakerLibrary.Words  	nb=10
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${Values[3]}  ${Values[4]}  ${Values[5]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[9]}  ${Values[6]}  ${Values[2]}  ${Values[7]}  ${Values[4]}  ${Values[8]}
    ${l_name}=  FakerLibrary.Words  nb=2
    ${l_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${l_name[0]}  ${l_name[1]}  ${l_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${LABEL_NOTIFICATION_VALUE_NOT_EXIST}"

