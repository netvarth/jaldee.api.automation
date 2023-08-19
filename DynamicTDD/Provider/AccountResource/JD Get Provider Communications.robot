*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        Communications
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
*** Test Cases ***

JD-TC-Get Provider Communication-1
    [Documentation]   Getting Communication provider with consumer
    clear_provider_msgs  ${PUSERNAME5}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${a_id}=  get_acc_id  ${PUSERNAME5}
    ${id}=  get_id  ${CUSERNAME2} 
    Set Suite Variable  ${id}  ${id}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    clear_customer   ${PUSERNAME4}
    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME5}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithConsumer   ${cookie}   ${id}  ${msg}  ${messageType[0]}  ${caption}   ${EMPTY}  
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${msg}=  FakerLibrary.text
    # Set Suite Variable  ${msg}
    # ${resp}=  Communication consumers  ${id}  ${msg}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get provider communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}  ${msg}

JD-TC-Get Provider Communication-UH1

    [Documentation]   Communication provider without login.

    ${resp}=  Get provider communications
    Should Be Equal As Strings  ${resp.status_code}  419          
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


JD-TC-Get Provider Communication-UH2

    [Documentation]  consumer login to Communication with consumer login.

    ${resp}=   ConsumerLogin  ${CUSERNAME2}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get provider communications
    Should Be Equal As Strings  ${resp.status_code}  401  
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"  
        
    
    
    
    
    