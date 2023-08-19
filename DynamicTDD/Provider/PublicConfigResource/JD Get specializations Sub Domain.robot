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
JD-TC-Get specializations Sub Domain -1
       [Documentation]   Provider check to Get specializations Sub Domain without login
       ${resp}=  Get specializations Sub Domain  healthCare  physiciansSurgeons
       Log   ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200

       Should Contain    "${resp.json()}"  Allergists 
       Should Contain    "${resp.json()}"  Anaesthesiology 
       Should Contain    "${resp.json()}"  Andrology
       Should Contain    "${resp.json()}"  Audiology
       Should Contain    "${resp.json()}"  BariatricSurgery
       Should Contain    "${resp.json()}"  BonemarrowTransplant       
       Should Contain    "${resp.json()}"  BreastSurgery 
       Should Contain    "${resp.json()}"  CardiacLungTransplantSurgery
       Should Contain    "${resp.json()}"  Cardiology
       Should Contain    "${resp.json()}"  CardiothoracicSurgery
       Should Contain    "${resp.json()}"  ClinicalImmunology
       Should Contain    "${resp.json()}"  CommunityMedicine
       Should Contain    "${resp.json()}"  CosmeticSurgery  
       Should Contain    "${resp.json()}"  CriticalCareMedicine 
       Should Contain    "${resp.json()}"  Cytology
       Should Contain    "${resp.json()}"  covid19
       Should Contain    "${resp.json()}"  Dermatology
       Should Contain    "${resp.json()}"  Dentistry
       Should Contain    "${resp.json()}"  Diabetology
       Should Contain    "${resp.json()}"  DiabeticsClinicalNutrition
       Should Contain    "${resp.json()}"  EmergencyServicesAndTraumaCare        
       Should Contain    "${resp.json()}"  EndocrineSurgery 
       Should Contain    "${resp.json()}"  Endocrinology
       Should Contain    "${resp.json()}"  Epidemiologist
       Should Contain    "${resp.json()}"  ENT
       Should Contain    "${resp.json()}"  ENTNeckSurgery
       Should Contain    "${resp.json()}"  FamilyMedicine       
       Should Contain    "${resp.json()}"  FoetalInterventionRadiology 
       Should Contain    "${resp.json()}"  FoetalMedicine
       Should Contain    "${resp.json()}"  Gastroenterology
       Should Contain    "${resp.json()}"  GastrointestinalOncology
       Should Contain    "${resp.json()}"  GeneralMedicine 
       Should Contain    "${resp.json()}"  internalMedicine     
       Should Contain    "${resp.json()}"  GeneralSurgery  
       Should Contain    "${resp.json()}"  Geriatrics 
       Should Contain    "${resp.json()}"  GynaeOncology
       Should Contain    "${resp.json()}"  GynaecologyObstetrics
       Should Contain    "${resp.json()}"  HaematoOncology
       Should Contain    "${resp.json()}"  Haematology
      
             
JD-TC-Get specializations Sub Domain -2
       [Documentation]   Provider check to Get specializations Sub Domain provider login
       ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=  Get specializations Sub Domain  healthCare  physiciansSurgeons
       Should Be Equal As Strings    ${resp.status_code}   200

       Should Contain    "${resp.json()}"  Allergists 
       Should Contain    "${resp.json()}"  Anaesthesiology 
       Should Contain    "${resp.json()}"  Andrology
       Should Contain    "${resp.json()}"  Audiology
       Should Contain    "${resp.json()}"  BariatricSurgery
       Should Contain    "${resp.json()}"  BonemarrowTransplant       
       Should Contain    "${resp.json()}"  BreastSurgery 
       Should Contain    "${resp.json()}"  CardiacLungTransplantSurgery
       Should Contain    "${resp.json()}"  Cardiology
       Should Contain    "${resp.json()}"  CardiothoracicSurgery
       Should Contain    "${resp.json()}"  ClinicalImmunology
       Should Contain    "${resp.json()}"  CommunityMedicine
       Should Contain    "${resp.json()}"  CosmeticSurgery  
       Should Contain    "${resp.json()}"  CriticalCareMedicine 
       Should Contain    "${resp.json()}"  Cytology
       Should Contain    "${resp.json()}"  covid19
       Should Contain    "${resp.json()}"  Dermatology
       Should Contain    "${resp.json()}"  Dentistry
       Should Contain    "${resp.json()}"  Diabetology
       Should Contain    "${resp.json()}"  DiabeticsClinicalNutrition
       Should Contain    "${resp.json()}"  EmergencyServicesAndTraumaCare        
       Should Contain    "${resp.json()}"  EndocrineSurgery 
       Should Contain    "${resp.json()}"  Endocrinology
       Should Contain    "${resp.json()}"  Epidemiologist
       Should Contain    "${resp.json()}"  ENT
       Should Contain    "${resp.json()}"  ENTNeckSurgery
       Should Contain    "${resp.json()}"  FamilyMedicine       
       Should Contain    "${resp.json()}"  FoetalInterventionRadiology 
       Should Contain    "${resp.json()}"  FoetalMedicine
       Should Contain    "${resp.json()}"  Gastroenterology
       Should Contain    "${resp.json()}"  GastrointestinalOncology
       Should Contain    "${resp.json()}"  GeneralMedicine 
       Should Contain    "${resp.json()}"  internalMedicine     
       Should Contain    "${resp.json()}"  GeneralSurgery  
       Should Contain    "${resp.json()}"  Geriatrics 
       Should Contain    "${resp.json()}"  GynaeOncology
       Should Contain    "${resp.json()}"  GynaecologyObstetrics
       Should Contain    "${resp.json()}"  HaematoOncology
       Should Contain    "${resp.json()}"  Haematology
          
             
JD-TC-Get specializations Sub Domain -3
       [Documentation]   Provider check to Get specializations Sub Domain consumer login
       ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=  Get specializations Sub Domain  healthCare  physiciansSurgeons
       Should Be Equal As Strings    ${resp.status_code}   200
     
       Should Contain    "${resp.json()}"  Allergists 
       Should Contain    "${resp.json()}"  Anaesthesiology 
       Should Contain    "${resp.json()}"  Andrology
       Should Contain    "${resp.json()}"  Audiology
       Should Contain    "${resp.json()}"  BariatricSurgery
       Should Contain    "${resp.json()}"  BonemarrowTransplant       
       Should Contain    "${resp.json()}"  BreastSurgery 
       Should Contain    "${resp.json()}"  CardiacLungTransplantSurgery
       Should Contain    "${resp.json()}"  Cardiology
       Should Contain    "${resp.json()}"  CardiothoracicSurgery
       Should Contain    "${resp.json()}"  ClinicalImmunology
       Should Contain    "${resp.json()}"  CommunityMedicine
       Should Contain    "${resp.json()}"  CosmeticSurgery  
       Should Contain    "${resp.json()}"  CriticalCareMedicine 
       Should Contain    "${resp.json()}"  Cytology
       Should Contain    "${resp.json()}"  covid19
       Should Contain    "${resp.json()}"  Dermatology
       Should Contain    "${resp.json()}"  Dentistry
       Should Contain    "${resp.json()}"  Diabetology
       Should Contain    "${resp.json()}"  DiabeticsClinicalNutrition
       Should Contain    "${resp.json()}"  EmergencyServicesAndTraumaCare        
       Should Contain    "${resp.json()}"  EndocrineSurgery 
       Should Contain    "${resp.json()}"  Endocrinology
       Should Contain    "${resp.json()}"  Epidemiologist
       Should Contain    "${resp.json()}"  ENT
       Should Contain    "${resp.json()}"  ENTNeckSurgery
       Should Contain    "${resp.json()}"  FamilyMedicine       
       Should Contain    "${resp.json()}"  FoetalInterventionRadiology 
       Should Contain    "${resp.json()}"  FoetalMedicine
       Should Contain    "${resp.json()}"  Gastroenterology
       Should Contain    "${resp.json()}"  GastrointestinalOncology
       Should Contain    "${resp.json()}"  GeneralMedicine 
       Should Contain    "${resp.json()}"  internalMedicine     
       Should Contain    "${resp.json()}"  GeneralSurgery  
       Should Contain    "${resp.json()}"  Geriatrics 
       Should Contain    "${resp.json()}"  GynaeOncology
       Should Contain    "${resp.json()}"  GynaecologyObstetrics
       Should Contain    "${resp.json()}"  HaematoOncology
       Should Contain    "${resp.json()}"  Haematology
      
                   
JD-TC-Get specializations Sub Domain -UH1
       [Documentation]   Provider check to Get specializations Sub Domain  Domain and sub domain miss match
       ${resp}=  Get specializations Sub Domain  personalCare  physiciansSurgeons
       Should Be Equal As Strings    ${resp.status_code}   422 
       Should Be Equal As Strings  "${resp.json()}"   "${INVALID_SUB_SECTOR}"
             
JD-TC-Get specializations Sub Domain -UH2
       [Documentation]   Provider check to Get specializations Sub Domain with invalid domain and subdomain 
       ${resp}=  Get specializations Sub Domain  healthCare  XAVIER
       Should Be Equal As Strings    ${resp.status_code}   422 
       Should Be Equal As Strings  "${resp.json()}"   "${INVALID_SUB_SECTOR}"