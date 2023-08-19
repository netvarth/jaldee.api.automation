*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        POC
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Test Cases ***

JD-TC-ViewWaitlistSettings-1
    [Documentation]  View Waitlist Settings of a valid provider
    ${resp}=  ProviderLogin  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
  
   
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  0  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${Empty} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Verify Response  ${resp}  calculationMode=${calc_mode[0]}  trnArndTime=0  futureDateWaitlist=True  showTokenId=True  onlineCheckIns=True    maxPartySize=1
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  0  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${Empty}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Verify Response  ${resp}  calculationMode=${calc_mode[0]}  trnArndTime=0  futureDateWaitlist=True  showTokenId=False  onlineCheckIns=True    maxPartySize=1
    ${resp}=  Update Waitlist Settings  ${calc_mode [0]}  0  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${Empty}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  View Waitlist Settings
    Verify Response  ${resp}  calculationMode=${calc_mode[0]}  trnArndTime=0  futureDateWaitlist=True  showTokenId=True  onlineCheckIns=True    maxPartySize=1
    

JD-TC-ViewWaitlistSettings-UH1      
     [Documentation]  View Waitlist Settings by consumer login
     ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=   View Waitlist Settings
     Should Be Equal As Strings  ${resp.status_code}  401
     Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"
     
JD-TC-ViewWaitlistSettings-UH2
     [Documentation]  View Waitlist Settings without login
     ${resp}=   View Waitlist Settings
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}" 
