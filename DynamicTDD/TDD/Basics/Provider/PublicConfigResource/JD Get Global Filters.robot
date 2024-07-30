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

JD-TC-Get Global Filters -1
       [Documentation]   Provider check to Get Global Filters
       ${resp}=  Get Global Filters
       Log   ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200
       Should Contain    "${resp.json()}"  spokenlangs
       Should Contain    "${resp.json()}"  english    
       Should Contain    "${resp.json()}"  bengali      
       Should Contain    "${resp.json()}"  gujarati    
       Should Contain    "${resp.json()}"  hindi    
       Should Contain    "${resp.json()}"  kannada    
       Should Contain    "${resp.json()}"  malayalam    
       Should Contain    "${resp.json()}"  Marathi          
       Should Contain    "${resp.json()}"  tamil        
       Should Contain    "${resp.json()}"  telugu    
       Should Contain    "${resp.json()}"  alwaysopen
       Should Contain    "${resp.json()}"  parkingTypes
       Should Contain    "${resp.json()}"  none
       Should Contain    "${resp.json()}"  free
       Should Contain    "${resp.json()}"  street
       Should Contain    "${resp.json()}"  privatelot
       Should Contain    "${resp.json()}"  valet
       Should Contain    "${resp.json()}"  paid

       Should Contain    "${resp.json()}"  ynwVerifiedLevel
       Should Contain    "${resp.json()}"  1
       Should Contain    "${resp.json()}"  2 
       Should Contain    "${resp.json()}"  3

       Should Contain    "${resp.json()}"  rating

       Should Contain    "${resp.json()}"  male
       Should Contain    "${resp.json()}"  female
       Should Contain    "${resp.json()}"  others

       Should Contain    "${resp.json()}"  vaastucompliant
       Should Contain    "${resp.json()}"  doceducationalqualification
       Should Contain    "${resp.json()}"  dentistemergencyservices
       Should Contain    "${resp.json()}"  densistambulance

       Should Contain    "${resp.json()}"  lawyerplacesofpractice
       Should Contain    "${resp.json()}"  SupremeCourtOfIndia
       Should Contain    "${resp.json()}"  HighCourt
       Should Contain    "${resp.json()}"  TribunalsAndAppellateBoards
       Should Contain    "${resp.json()}"  DistrictAndSessionCourts
       Should Contain    "${resp.json()}"  ConsumerCourts

       Should Contain    "${resp.json()}"  physiciansemergencyservices
       Should Contain    "${resp.json()}"  traumacentre
       Should Contain    "${resp.json()}"  firstaid
       Should Contain    "${resp.json()}"  docambulance
       Should Contain    "${resp.json()}"  businessname

       Should Contain    "${resp.json()}"  businessdomain    
       Should Contain    "${resp.json()}"  healthCare
       Should Contain    "${resp.json()}"  personalCare
       Should Contain    "${resp.json()}"  foodJoints
       Should Contain    "${resp.json()}"  professionalConsulting
       Should Contain    "${resp.json()}"  vastuAstrology
       Should Contain    "${resp.json()}"  religiousPriests
       Should Contain    "${resp.json()}"  subdomain   
       Should Contain    "${resp.json()}"  physiciansSurgeons
       Should Contain    "${resp.json()}"  dentists
       Should Contain    "${resp.json()}"  alternateMedicinePractitioners
       Should Contain    "${resp.json()}"  beautyCare
       Should Contain    "${resp.json()}"  personalFitness
       Should Contain    "${resp.json()}"  massageCenters
       Should Contain    "${resp.json()}"  restaurants
       Should Contain    "${resp.json()}"  lawyers
       Should Contain    "${resp.json()}"  charteredAccountants
       Should Contain    "${resp.json()}"  taxConsultants
       Should Contain    "${resp.json()}"  civilArchitects
       Should Contain    "${resp.json()}"  vastu
       Should Contain    "${resp.json()}"  temple
      
      Should Contain    "${resp.json()}"  specialization
      Should Contain    "${resp.json()}"  emergencyservices
      Should Contain    "${resp.json()}"  pickupdropoptions
      Should Contain    "${resp.json()}"  male
      Should Contain    "${resp.json()}"  female
      Should Contain    "${resp.json()}"  others

      Should Contain    "${resp.json()}"  associatedclinics
      Should Contain    "${resp.json()}"  medicalproblems
      Should Contain    "${resp.json()}"  medicalprocedures
      Should Contain    "${resp.json()}"  foodkind
      Should Contain    "${resp.json()}"  vegetarian
      Should Contain    "${resp.json()}"  nonvegetarian


       Should Contain    "${resp.json()}"  cuisines    
       Should Contain    "${resp.json()}"  cuisines_cust
       Should Contain    "${resp.json()}"  Arab
       Should Contain    "${resp.json()}"  BBQ
       Should Contain    "${resp.json()}"  Chinese
       Should Contain    "${resp.json()}"  Indian
       Should Contain    "${resp.json()}"  Italian
       Should Contain    "${resp.json()}"  Mexican
       Should Contain    "${resp.json()}"  NorthIndian
       Should Contain    "${resp.json()}"  Punjabi
       Should Contain    "${resp.json()}"  Seafood
       Should Contain    "${resp.json()}"  SouthIndian
       Should Contain    "${resp.json()}"  Thai

   
       Should Contain    "${resp.json()}"  alteducationalqualification
       Should Contain    "${resp.json()}"  altemergencyservices
       Should Contain    "${resp.json()}"  altambulance
       Should Contain    "${resp.json()}"  typeofbike

       Should Contain    "${resp.json()}"  dentaleducationalqualification  
       Should Contain    "${resp.json()}"  male
       Should Contain    "${resp.json()}"  female
       Should Contain    "${resp.json()}"  others
       Should Contain    "${resp.json()}"  male
       Should Contain    "${resp.json()}"  female
       Should Contain    "${resp.json()}"  others

JD-TC-Get Global Filters -2
       [Documentation]   Provider check to Get Global Filters provider login
       ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=  Get Global Filters
       Should Be Equal As Strings    ${resp.status_code}   200
       Should Contain    "${resp.json()}"  spokenlangs
       Should Contain    "${resp.json()}"  english    
       Should Contain    "${resp.json()}"  bengali      
       Should Contain    "${resp.json()}"  gujarati    
       Should Contain    "${resp.json()}"  hindi    
       Should Contain    "${resp.json()}"  kannada    
       Should Contain    "${resp.json()}"  malayalam    
       Should Contain    "${resp.json()}"  Marathi          
       Should Contain    "${resp.json()}"  tamil        
       Should Contain    "${resp.json()}"  telugu    
       Should Contain    "${resp.json()}"  alwaysopen
       Should Contain    "${resp.json()}"  parkingTypes
       Should Contain    "${resp.json()}"  none
       Should Contain    "${resp.json()}"  free
       Should Contain    "${resp.json()}"  street
       Should Contain    "${resp.json()}"  privatelot
       Should Contain    "${resp.json()}"  valet
       Should Contain    "${resp.json()}"  paid

       Should Contain    "${resp.json()}"  ynwVerifiedLevel
       Should Contain    "${resp.json()}"  1
       Should Contain    "${resp.json()}"  2 
       Should Contain    "${resp.json()}"  3

       Should Contain    "${resp.json()}"  rating
 
       Should Contain    "${resp.json()}"  male
       Should Contain    "${resp.json()}"  female
       Should Contain    "${resp.json()}"  others

       Should Contain    "${resp.json()}"  vaastucompliant
       Should Contain    "${resp.json()}"  doceducationalqualification
       Should Contain    "${resp.json()}"  dentistemergencyservices
       Should Contain    "${resp.json()}"  densistambulance

       Should Contain    "${resp.json()}"  lawyerplacesofpractice
       Should Contain    "${resp.json()}"  SupremeCourtOfIndia
       Should Contain    "${resp.json()}"  HighCourt
       Should Contain    "${resp.json()}"  TribunalsAndAppellateBoards
       Should Contain    "${resp.json()}"  DistrictAndSessionCourts
       Should Contain    "${resp.json()}"  ConsumerCourts

       Should Contain    "${resp.json()}"  physiciansemergencyservices
       Should Contain    "${resp.json()}"  traumacentre
       Should Contain    "${resp.json()}"  firstaid
       Should Contain    "${resp.json()}"  docambulance
       Should Contain    "${resp.json()}"  businessname

       Should Contain    "${resp.json()}"  businessdomain    
       Should Contain    "${resp.json()}"  healthCare
       Should Contain    "${resp.json()}"  personalCare
       Should Contain    "${resp.json()}"  foodJoints
       Should Contain    "${resp.json()}"  professionalConsulting
       Should Contain    "${resp.json()}"  vastuAstrology
       Should Contain    "${resp.json()}"  religiousPriests
       Should Contain    "${resp.json()}"  subdomain   
       Should Contain    "${resp.json()}"  physiciansSurgeons
       Should Contain    "${resp.json()}"  dentists
       Should Contain    "${resp.json()}"  alternateMedicinePractitioners
       Should Contain    "${resp.json()}"  beautyCare
       Should Contain    "${resp.json()}"  personalFitness
       Should Contain    "${resp.json()}"  massageCenters
       Should Contain    "${resp.json()}"  restaurants
       Should Contain    "${resp.json()}"  lawyers
       Should Contain    "${resp.json()}"  charteredAccountants
       Should Contain    "${resp.json()}"  taxConsultants
       Should Contain    "${resp.json()}"  civilArchitects
       Should Contain    "${resp.json()}"  vastu
       Should Contain    "${resp.json()}"  temple
      
      Should Contain    "${resp.json()}"  specialization
      Should Contain    "${resp.json()}"  emergencyservices
      Should Contain    "${resp.json()}"  pickupdropoptions
      Should Contain    "${resp.json()}"  male
      Should Contain    "${resp.json()}"  female
      Should Contain    "${resp.json()}"  others

      Should Contain    "${resp.json()}"  associatedclinics
      Should Contain    "${resp.json()}"  medicalproblems
      Should Contain    "${resp.json()}"  medicalprocedures
      Should Contain    "${resp.json()}"  foodkind
      Should Contain    "${resp.json()}"  vegetarian
      Should Contain    "${resp.json()}"  nonvegetarian


       Should Contain    "${resp.json()}"  cuisines    
       Should Contain    "${resp.json()}"  cuisines_cust
       Should Contain    "${resp.json()}"  Arab
       Should Contain    "${resp.json()}"  BBQ
       Should Contain    "${resp.json()}"  Chinese
       Should Contain    "${resp.json()}"  Indian
       Should Contain    "${resp.json()}"  Italian
       Should Contain    "${resp.json()}"  Mexican
       Should Contain    "${resp.json()}"  NorthIndian
       Should Contain    "${resp.json()}"  Punjabi
       Should Contain    "${resp.json()}"  Seafood
       Should Contain    "${resp.json()}"  SouthIndian
       Should Contain    "${resp.json()}"  Thai

   
       Should Contain    "${resp.json()}"  alteducationalqualification
       Should Contain    "${resp.json()}"  altemergencyservices
       Should Contain    "${resp.json()}"  altambulance
       Should Contain    "${resp.json()}"  typeofbike

       Should Contain    "${resp.json()}"  dentaleducationalqualification  
       Should Contain    "${resp.json()}"  male
       Should Contain    "${resp.json()}"  female
       Should Contain    "${resp.json()}"  others
       Should Contain    "${resp.json()}"  male
       Should Contain    "${resp.json()}"  female
       Should Contain    "${resp.json()}"  others

JD-TC-Get Global Filters -3
       [Documentation]   Provider check to Get Global Filters consumer login
       ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200       
       ${resp}=  Get Global Filters   
       Should Be Equal As Strings    ${resp.status_code}   200
       Should Contain    "${resp.json()}"  spokenlangs
       Should Contain    "${resp.json()}"  english    
       Should Contain    "${resp.json()}"  bengali      
       Should Contain    "${resp.json()}"  gujarati    
       Should Contain    "${resp.json()}"  hindi    
       Should Contain    "${resp.json()}"  kannada    
       Should Contain    "${resp.json()}"  malayalam    
       Should Contain    "${resp.json()}"  Marathi          
       Should Contain    "${resp.json()}"  tamil        
       Should Contain    "${resp.json()}"  telugu    
       Should Contain    "${resp.json()}"  alwaysopen
       Should Contain    "${resp.json()}"  parkingTypes
       Should Contain    "${resp.json()}"  none
       Should Contain    "${resp.json()}"  free
       Should Contain    "${resp.json()}"  street
       Should Contain    "${resp.json()}"  privatelot
       Should Contain    "${resp.json()}"  valet
       Should Contain    "${resp.json()}"  paid

       Should Contain    "${resp.json()}"  ynwVerifiedLevel
       Should Contain    "${resp.json()}"  1
       Should Contain    "${resp.json()}"  2 
       Should Contain    "${resp.json()}"  3

       Should Contain    "${resp.json()}"  rating
 
       Should Contain    "${resp.json()}"  male
       Should Contain    "${resp.json()}"  female
       Should Contain    "${resp.json()}"  others

       Should Contain    "${resp.json()}"  vaastucompliant
       Should Contain    "${resp.json()}"  doceducationalqualification
       Should Contain    "${resp.json()}"  dentistemergencyservices
       Should Contain    "${resp.json()}"  densistambulance

       Should Contain    "${resp.json()}"  lawyerplacesofpractice
       Should Contain    "${resp.json()}"  SupremeCourtOfIndia
       Should Contain    "${resp.json()}"  HighCourt
       Should Contain    "${resp.json()}"  TribunalsAndAppellateBoards
       Should Contain    "${resp.json()}"  DistrictAndSessionCourts
       Should Contain    "${resp.json()}"  ConsumerCourts

       Should Contain    "${resp.json()}"  physiciansemergencyservices
       Should Contain    "${resp.json()}"  traumacentre
       Should Contain    "${resp.json()}"  firstaid
       Should Contain    "${resp.json()}"  docambulance
       Should Contain    "${resp.json()}"  businessname

       Should Contain    "${resp.json()}"  businessdomain    
       Should Contain    "${resp.json()}"  healthCare
       Should Contain    "${resp.json()}"  personalCare
       Should Contain    "${resp.json()}"  foodJoints
       Should Contain    "${resp.json()}"  professionalConsulting
       Should Contain    "${resp.json()}"  vastuAstrology
       Should Contain    "${resp.json()}"  religiousPriests
       Should Contain    "${resp.json()}"  subdomain   
       Should Contain    "${resp.json()}"  physiciansSurgeons
       Should Contain    "${resp.json()}"  dentists
       Should Contain    "${resp.json()}"  alternateMedicinePractitioners
       Should Contain    "${resp.json()}"  beautyCare
       Should Contain    "${resp.json()}"  personalFitness
       Should Contain    "${resp.json()}"  massageCenters
       Should Contain    "${resp.json()}"  restaurants
       Should Contain    "${resp.json()}"  lawyers
       Should Contain    "${resp.json()}"  charteredAccountants
       Should Contain    "${resp.json()}"  taxConsultants
       Should Contain    "${resp.json()}"  civilArchitects
       Should Contain    "${resp.json()}"  vastu
       Should Contain    "${resp.json()}"  temple
      
      Should Contain    "${resp.json()}"  specialization
      Should Contain    "${resp.json()}"  emergencyservices
      Should Contain    "${resp.json()}"  pickupdropoptions
      Should Contain    "${resp.json()}"  male
      Should Contain    "${resp.json()}"  female
      Should Contain    "${resp.json()}"  others

      Should Contain    "${resp.json()}"  associatedclinics
      Should Contain    "${resp.json()}"  medicalproblems
      Should Contain    "${resp.json()}"  medicalprocedures
      Should Contain    "${resp.json()}"  foodkind
      Should Contain    "${resp.json()}"  vegetarian
      Should Contain    "${resp.json()}"  nonvegetarian


       Should Contain    "${resp.json()}"  cuisines    
       Should Contain    "${resp.json()}"  cuisines_cust
       Should Contain    "${resp.json()}"  Arab
       Should Contain    "${resp.json()}"  BBQ
       Should Contain    "${resp.json()}"  Chinese
       Should Contain    "${resp.json()}"  Indian
       Should Contain    "${resp.json()}"  Italian
       Should Contain    "${resp.json()}"  Mexican
       Should Contain    "${resp.json()}"  NorthIndian
       Should Contain    "${resp.json()}"  Punjabi
       Should Contain    "${resp.json()}"  Seafood
       Should Contain    "${resp.json()}"  SouthIndian
       Should Contain    "${resp.json()}"  Thai

   
       Should Contain    "${resp.json()}"  alteducationalqualification
       Should Contain    "${resp.json()}"  altemergencyservices
       Should Contain    "${resp.json()}"  altambulance
       Should Contain    "${resp.json()}"  typeofbike

       Should Contain    "${resp.json()}"  dentaleducationalqualification  
       Should Contain    "${resp.json()}"  male
       Should Contain    "${resp.json()}"  female
       Should Contain    "${resp.json()}"  others
       Should Contain    "${resp.json()}"  male
       Should Contain    "${resp.json()}"  female
       Should Contain    "${resp.json()}"  others