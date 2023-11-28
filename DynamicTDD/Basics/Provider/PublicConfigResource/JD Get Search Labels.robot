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
JD-TC-Get Search Labels-1
       [Documentation]   Provider check to Get Search Labels
       ${resp}=  Get Search Labels
       Should Be Equal As Strings    ${resp.status_code}   200
       Should Contain    "${resp.json()}"  healthCare
       Should Contain    "${resp.json()}"  dentists 
       Should Contain    "${resp.json()}"  beautyCare 
       Should Contain    "${resp.json()}"  temple
       Should Contain    "${resp.json()}"  Gastroenterology 
       Should Contain    "${resp.json()}"  ConsumerLawyer
       Should Contain    "${resp.json()}"  physiciansSurgeons
       Should Contain    "${resp.json()}"  alternateMedicinePractitioners 
       Should Contain    "${resp.json()}"  personalFitness      
       Should Contain    "${resp.json()}"  massageCenters     


       Should Contain    "${resp.json()}"  restaurants
       Should Contain    "${resp.json()}"  lawyers 
       Should Contain    "${resp.json()}"  charteredAccountants 
       Should Contain    "${resp.json()}"  taxConsultants
       Should Contain    "${resp.json()}"  civilArchitects 
       Should Contain    "${resp.json()}"  financialAdviser 
       Should Contain    "${resp.json()}"  stockbroker 
       Should Contain    "${resp.json()}"  auditor 
       Should Contain    "${resp.json()}"  geologist 
       Should Contain    "${resp.json()}"  vastu     
     
JD-TC-Get Search Labels -2
       [Documentation]   Provider check to Get Search Labels provider login
       ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=  Get Search Labels
       Should Be Equal As Strings    ${resp.status_code}   200  
       Should Contain    "${resp.json()}"  healthCare
       Should Contain    "${resp.json()}"  dentists 
       Should Contain    "${resp.json()}"  beautyCare 
       Should Contain    "${resp.json()}"  temple
       Should Contain    "${resp.json()}"  Gastroenterology 
       Should Contain    "${resp.json()}"  ConsumerLawyer 
       Should Contain    "${resp.json()}"  physiciansSurgeons
       Should Contain    "${resp.json()}"  alternateMedicinePractitioners 
       Should Contain    "${resp.json()}"  personalFitness      
       Should Contain    "${resp.json()}"  massageCenters     


       Should Contain    "${resp.json()}"  restaurants
       Should Contain    "${resp.json()}"  lawyers 
       Should Contain    "${resp.json()}"  charteredAccountants 
       Should Contain    "${resp.json()}"  taxConsultants
       Should Contain    "${resp.json()}"  civilArchitects 
       Should Contain    "${resp.json()}"  financialAdviser 
       Should Contain    "${resp.json()}"  stockbroker 
       Should Contain    "${resp.json()}"  auditor 
       Should Contain    "${resp.json()}"  geologist 
       Should Contain    "${resp.json()}"  vastu    
             
JD-TC-Get Search Labels -3
       [Documentation]   Provider check to Get Search Labels consumer login
       ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=  Get Search Labels
       Should Be Equal As Strings    ${resp.status_code}   200  
       Should Contain    "${resp.json()}"  healthCare
       Should Contain    "${resp.json()}"  dentists 
       Should Contain    "${resp.json()}"  beautyCare 
       Should Contain    "${resp.json()}"  temple
       Should Contain    "${resp.json()}"  Gastroenterology 
       Should Contain    "${resp.json()}"  ConsumerLawyer 
       Should Contain    "${resp.json()}"  physiciansSurgeons
       Should Contain    "${resp.json()}"  alternateMedicinePractitioners 
       Should Contain    "${resp.json()}"  personalFitness      
       Should Contain    "${resp.json()}"  massageCenters     


       Should Contain    "${resp.json()}"  restaurants
       Should Contain    "${resp.json()}"  lawyers 
       Should Contain    "${resp.json()}"  charteredAccountants 
       Should Contain    "${resp.json()}"  taxConsultants
       Should Contain    "${resp.json()}"  civilArchitects 
       Should Contain    "${resp.json()}"  financialAdviser 
       Should Contain    "${resp.json()}"  stockbroker 
       Should Contain    "${resp.json()}"  auditor 
       Should Contain    "${resp.json()}"  geologist 
       Should Contain    "${resp.json()}"  vastu     