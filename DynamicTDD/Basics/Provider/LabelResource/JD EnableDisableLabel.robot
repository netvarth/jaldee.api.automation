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

JD-TC-EnableDisableLabel-1
	[Documentation]  Create a label and check the status for a valid provider.

    ${resp}=  ProviderLogin  ${PUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_Label  ${PUSERNAME15}
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
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']}  ${Qstate[0]}
    
JD-TC-EnableDisableLabel-2
	[Documentation]  Disable a label.

    ${resp}=  ProviderLogin  ${PUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  EnableDisable Label   ${label_id}   ${Qstate[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']}  ${Qstate[1]}

JD-TC-EnableDisableLabel-UH1
	[Documentation]  Try to Disable a disabled label.

    ${resp}=  ProviderLogin  ${PUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  EnableDisable Label   ${label_id}   ${Qstate[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${LABEL_ALREDY_DISABLED}"

JD-TC-EnableDisableLabel-UH2
	[Documentation]  Try to Enable an enabled label.

    ${resp}=  ProviderLogin  ${PUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  EnableDisable Label   ${label_id}   ${Qstate[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']}  ${Qstate[0]}

    ${resp}=  EnableDisable Label   ${label_id}   ${Qstate[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${LABEL_ALREDY_ENABLED}"

JD-TC-EnableDisableLabel -UH3
    [Documentation]   Provider try to update label status without login  

    ${resp}=  EnableDisable Label   ${label_id}   ${Qstate[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-EnableDisableLabel -UH4
    [Documentation]   Consumer try to update label status.

    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  EnableDisable Label   ${label_id}   ${Qstate[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-EnableDisableLabel-UH5
	[Documentation]  Update label staus with another provider's label id.

    ${resp}=  ProviderLogin  ${PUSERNAME16}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_Label  ${PUSERNAME16}
    ${Values}=  FakerLibrary.Words  	nb=9
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${Values[3]}  ${Values[4]}  ${Values[5]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Values[6]}  ${Values[2]}  ${Values[7]}  ${Values[4]}  ${Values[8]}
    ${l_name}=  FakerLibrary.Words  nb=2
    ${l_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${l_name[0]}  ${l_name[1]}  ${l_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${label_id1}  ${resp.json()}

    ${resp}=  Get Label By Id  ${label_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']}  ${Qstate[0]}

    ${resp}=  ProviderLogin  ${PUSERNAME17}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  EnableDisable Label   ${label_id1}   ${Qstate[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${LABEL_NOT_EXIST}"

JD-TC-EnableDisableLabel-UH6
    [Documentation]  Update label status with invalid label id.

    ${resp}=  ProviderLogin  ${PUSERNAME17}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${invalid_id}=   Random Int   min=-10   max=0
    ${resp}=  EnableDisable Label   ${invalid_id}   ${Qstate[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${LABEL_NOT_EXIST}"


    