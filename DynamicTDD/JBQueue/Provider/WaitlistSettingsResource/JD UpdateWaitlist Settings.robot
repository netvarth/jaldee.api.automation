*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Waitlist
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py

       
*** Variables ***
${SERVICE1} 	   stuff
${SERVICE2} 	   SerUpdSett1
${SERVICE3} 	   SerUpdSett2
${SERVICE5} 	   SerUpdSett3
${loc}             EFGH
${queue1}          MorningQueue
${queue2}          AfternoonQueue
${queue3}          EveningQueue
@{service_duration}  5  10  15   
${parallel}     1


*** Test Cases ***

JD-TC-UpdateWaitlistSettings-1

    [Documentation]  Update wailist settings using calculationMode as Fixed

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${duration}=   Random Int  min=2  max=10
    Set Suite Variable   ${duration}
    
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${duration}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${Empty}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log    ${resp.json()}
    Verify Response  ${resp}  calculationMode=${calc_mode[1]} 

JD-TC-UpdateWaitlistSettings-2

    [Documentation]  Show token id to true and verify

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${duration}  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${bool[0]}   ${Empty}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  showTokenId=${bool[1]}

JD-TC-UpdateWaitlistSettings-3
    [Documentation]  Set futureDateWaitlist to true and verify

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${duration}  ${bool[1]}  ${bool[0]}  ${bool[0]}  ${bool[0]}   ${Empty}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  futureDateWaitlist=True

JD-TC-UpdateWaitlistSettings-4
    [Documentation]  Set OnlineCheckin to true and verify

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${duration}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${bool[0]}   ${Empty}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  onlineCheckIns=${bool[1]}


JD-TC-UpdateWaitlistSettings-UH1
    [Documentation]  Update wailist settings without login

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  30  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


*** Comments ***
JD-TC-UpdateWaitlistSettings-5
    [Documentation]  Set maxPartySize and verify

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${duration}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${bool[0]}   100
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  maxPartySize=100