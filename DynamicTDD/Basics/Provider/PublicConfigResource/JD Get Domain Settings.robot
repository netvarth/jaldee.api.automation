*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Customer
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Test Cases ***

JD-TC-Get Domain Settings -1
       [Documentation]   Provider check to Get Domain Settings without login
       ${resp}=  Get Domain Settings  healthCare
       Log   ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200 
       Verify Response  ${resp}     multipleLocation=${bool[1]}

JD-TC-Get Get Domain Settings -2
       [Documentation]   Provider check to Get Domain Settings provider login
       ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=  Get Domain Settings  healthCare
       Log   ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200 
       Verify Response  ${resp}      multipleLocation=${bool[1]}       
             
JD-TC-Get Get Domain Settings -3
       [Documentation]   Provider check to Get Domain Settings consumer login
       ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=  Get Domain Settings  healthCare
       Log   ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200 
       Verify Response  ${resp}      multipleLocation=${bool[1]}            
       
JD-TC-Get Domain Settings -UH1
       [Documentation]   Provider check to Get Domain Settings  INVALID domain
       ${resp}=  Get Domain Settings  BIJU  
       Should Be Equal As Strings    ${resp.status_code}   422 
       Should Be Equal As Strings  "${resp.json()}"   "${INVALID_SECTOR}" 
             
JD-TC-Get Domain Settings -UH2
       [Documentation]   Provider check to Get Domain Settings  input sub domain
       ${resp}=  Get Domain Settings  beautyCare
       Should Be Equal As Strings    ${resp.status_code}   422
       Should Be Equal As Strings  "${resp.json()}"   "${INVALID_SECTOR}" 