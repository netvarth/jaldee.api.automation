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

JD-TC- verifyLevels -1
       [Documentation]   Provider check to verifyLevels without login
       ${resp}=  Get verifyLevels
       Should Be Equal As Strings    ${resp.status_code}   200 
       Should Be Equal As Strings    ${resp.json()[0]}   NONE
       Should Be Equal As Strings    ${resp.json()[1]}   BASIC 
       Should Be Equal As Strings    ${resp.json()[2]}   BASIC PLUS 
       Should Be Equal As Strings    ${resp.json()[3]}   ADVANCED
     
JD-TC-Get verifyLevels-2
       [Documentation]   Provider check to Get verifyLevels  provider login
       ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=  Get verifyLevels
       Should Be Equal As Strings    ${resp.status_code}   200 
       Should Be Equal As Strings    ${resp.json()[0]}   NONE
       Should Be Equal As Strings    ${resp.json()[1]}   BASIC 
       Should Be Equal As Strings    ${resp.json()[2]}   BASIC PLUS      
       Should Be Equal As Strings    ${resp.json()[3]}   ADVANCED  
             
JD-TC-Get verifyLevels-3
       [Documentation]   Provider check to verifyLevels consumer login
       ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=  Get verifyLevels
       Should Be Equal As Strings    ${resp.status_code}   200
       Should Be Equal As Strings    ${resp.json()[0]}   NONE
       Should Be Equal As Strings    ${resp.json()[1]}   BASIC 
       Should Be Equal As Strings    ${resp.json()[2]}   BASIC PLUS 
       Should Be Equal As Strings    ${resp.json()[3]}   ADVANCED
