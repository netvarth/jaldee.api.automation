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
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Test Cases ***
JD-TC-DeleteLabel-1
	[Documentation]  Delete a label by a provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_Label  ${PUSERNAME9}
    ${Values}=  FakerLibrary.Words  	nb=9
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${Values[3]}  ${Values[4]}  ${Values[5]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Values[6]}  ${Values[2]}  ${Values[7]}  ${Values[4]}  ${Values[8]}
    ${l_name}=  FakerLibrary.Words  nb=2
    ${l_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${l_name[0]}  ${l_name[1]}  ${l_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${label_id}  ${resp.json()}
    ${resp}=  Get Label By Id  ${label_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${label_id}

    ${resp}=  Delete Label  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${LABEL_NOT_EXIST}"

    ${resp}=  Get Labels
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []

JD-TC-DeleteLabel -UH1
    [Documentation]   Provider Delete a label without login  
    ${resp}=  Delete Label  ${label_id}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-DeleteLabel -UH2
    [Documentation]   Consumer delete a label
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Delete Label  ${label_id}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-DeleteLabel-UH3
    [Documentation]  Delete a Label by id which is not exist
    ${resp}=  Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${invalid_id}=   Random Int   min=-10   max=0
    ${resp}=  Delete Label  ${invalid_id}
    Should Be Equal As Strings  ${resp.status_code}  422
    Log  ${resp.json()}
    Should Be Equal As Strings  "${resp.json()}"  "${LABEL_NOT_EXIST}"

JD-TC-DeleteLabel-UH4
    [Documentation]  Delete a Label by id of another provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME10}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Delete Label  ${label_id}
    Should Be Equal As Strings  ${resp.status_code}  422
    Log  ${resp.json()}
    Should Be Equal As Strings  "${resp.json()}"  "${LABEL_NOT_EXIST}"