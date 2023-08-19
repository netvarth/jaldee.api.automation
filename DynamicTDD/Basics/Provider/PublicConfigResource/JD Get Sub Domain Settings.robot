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

JD-TC-Get Sub Domain Settings -1
       [Documentation]   Provider check to Get Sub Domain Settings without login
       ${resp}=  Get Sub Domain Settings  healthCare  physiciansSurgeons
       Should Be Equal As Strings    ${resp.status_code}   200 
       Verify Response  ${resp}   serviceBillable=${bool[1]}     GST=0  partySize=${bool[0]}  partySizeForCalculation=${bool[0]}  maxPartySize=1
       
JD-TC-Get Sub Domain Settings -2
       [Documentation]   Provider check to Get Get Sub Domain Settings provider login
       ${resp}=  ProviderLogin  ${PUSERNAME2}  ${PASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=  Get Sub Domain Settings  healthCare  physiciansSurgeons
       Should Be Equal As Strings    ${resp.status_code}   200 
       Verify Response  ${resp}   serviceBillable=${bool[1]}     GST=0  partySize=${bool[0]}  partySizeForCalculation=${bool[0]}  maxPartySize=1
         
                   
JD-TC-Get Sub Domain Settings -3
       [Documentation]   Provider check to Get Sub Domain Settings consumer login
       ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=  Get Sub Domain Settings  healthCare  physiciansSurgeons
       Verify Response  ${resp}   serviceBillable=${bool[1]}     GST=0  partySize=${bool[0]}  partySizeForCalculation=${bool[0]}  maxPartySize=1
       
               
JD-TC-Get Sub Domain Settings-UH1
       [Documentation]   Provider check to Get Sub Domain Settings with domain and sub domain are missmatched
       ${resp}=  Get Sub Domain Settings  personalCare   physiciansSurgeons
       Should Be Equal As Strings    ${resp.status_code}   422
       Should Be Equal As Strings  "${resp.json()}"   "${INVALID_SUB_SECTOR}"
        
             
JD-TC-Get Sub Domain Settings-UH2
       [Documentation]   Provider check to Get Sub Domain Settings with invalid domain and subdomain
       ${resp}=  Get Sub Domain Settings  healthCare  YYY
       Should Be Equal As Strings    ${resp.status_code}   422
       Should Be Equal As Strings  "${resp.json()}"   "${INVALID_SUB_SECTOR}"
        
       
