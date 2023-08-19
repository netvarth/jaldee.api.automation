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
          
JD-TC-Get Domain Filter -1
       [Documentation]   Provider check to Get Domain Filter
       ${resp}=  Get Domain Filters  personalCare
       Log  ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['name']}  spokenlangs
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['displayName']}   Preferred Languages
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][0]['name']}  assamese    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][0]['displayName']}  Assamese       
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][1]['name']}  bengali    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][1]['displayName']}  Bengali  
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][2]['name']}  english    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][2]['displayName']}  English 
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][3]['name']}  gujarati    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][3]['displayName']}  Gujarati
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][4]['name']}  hindi    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][4]['displayName']}  Hindi  
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][5]['name']}  kannada    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][5]['displayName']}  Kannada
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][6]['name']}  Konkani    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][6]['displayName']}  Konkani
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][7]['name']}  malayalam    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][7]['displayName']}  Malayalam
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][8]['name']}  Marathi    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][8]['displayName']}  Marathi
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][9]['name']}  manipuri    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][9]['displayName']}  Manipuri
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][10]['name']}  oriya    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][10]['displayName']}  Oriya     
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][11]['name']}  punjabi    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][11]['displayName']}  Punjabi    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][12]['name']}  rajasthani    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][12]['displayName']}  Rajasthani  
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][13]['name']}  sanskrit    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][13]['displayName']}  Sanskrit       
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][14]['name']}  tamil    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][14]['displayName']}  Tamil                  
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][15]['name']}  telugu    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][15]['displayName']}  Telugu  
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][16]['name']}  urdu    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][16]['displayName']}  Urdu

JD-TC-Get Domain Filter -2
       [Documentation]   Provider check to Get Domain Filter provider login
       ${resp}=  ProviderLogin  ${PUSERNAME0}  ${PASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=  Get Domain Filters  healthCare 
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['name']}  spokenlangs
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['displayName']}   Preferred Languages
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][0]['name']}  assamese    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][0]['displayName']}  Assamese       
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][1]['name']}  bengali    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][1]['displayName']}  Bengali  
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][2]['name']}  english    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][2]['displayName']}  English 
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][3]['name']}  gujarati    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][3]['displayName']}  Gujarati
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][4]['name']}  hindi    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][4]['displayName']}  Hindi  
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][5]['name']}  kannada    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][5]['displayName']}  Kannada
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][6]['name']}  Konkani    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][6]['displayName']}  Konkani
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][7]['name']}  malayalam    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][7]['displayName']}  Malayalam
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][8]['name']}  Marathi    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][8]['displayName']}  Marathi
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][9]['name']}  manipuri    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][9]['displayName']}  Manipuri
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][10]['name']}  oriya    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][10]['displayName']}  Oriya     
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][11]['name']}  punjabi    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][11]['displayName']}  Punjabi    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][12]['name']}  rajasthani    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][12]['displayName']}  Rajasthani   
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][13]['name']}  sanskrit    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][13]['displayName']}  Sanskrit     
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][14]['name']}  tamil    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][14]['displayName']}  Tamil                  
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][15]['name']}  telugu    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][15]['displayName']}  Telugu  
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][16]['name']}  urdu    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][16]['displayName']}  Urdu
      
JD-TC-Get Domain Filter -3
       [Documentation]   Provider check to Get Domain Filter consumer login
       ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=  Get Domain Filters  foodJoints 
       Should Be Equal As Strings    ${resp.status_code}   200 
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['name']}  spokenlangs
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['displayName']}   Preferred Languages
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][0]['name']}  assamese    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][0]['displayName']}  Assamese       
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][1]['name']}  bengali    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][1]['displayName']}  Bengali  
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][2]['name']}  english    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][2]['displayName']}  English 
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][3]['name']}  gujarati    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][3]['displayName']}  Gujarati
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][4]['name']}  hindi    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][4]['displayName']}  Hindi  
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][5]['name']}  kannada    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][5]['displayName']}  Kannada
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][6]['name']}  Konkani    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][6]['displayName']}  Konkani
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][7]['name']}  malayalam    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][7]['displayName']}  Malayalam
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][8]['name']}  Marathi    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][8]['displayName']}  Marathi
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][9]['name']}  manipuri    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][9]['displayName']}  Manipuri
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][10]['name']}  oriya    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][10]['displayName']}  Oriya     
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][11]['name']}  punjabi    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][11]['displayName']}  Punjabi    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][12]['name']}  rajasthani    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][12]['displayName']}  Rajasthani   
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][13]['name']}  sanskrit    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][13]['displayName']}  Sanskrit     
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][14]['name']}  tamil    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][14]['displayName']}  Tamil                  
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][15]['name']}  telugu    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][15]['displayName']}  Telugu  
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][16]['name']}  urdu    
       Should Be Equal As Strings    ${resp.json()['commonFilters'][0]['enumeratedConstants'][16]['displayName']}  Urdu    
         
                 
JD-TC-Get Domain Filter -UH1
       [Documentation]   Provider check to Get Domain Filter invalid Domain
       ${resp}=  Get Domain Filters  BIJU  
       Should Be Equal As Strings    ${resp.status_code}   422
       Should Be Equal As Strings  "${resp.json()}"    "${INVALID_SECTOR}" 
