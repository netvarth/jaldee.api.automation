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

JD-TC-Get SubDomain Filters-1
       [Documentation]   Provider check to Get SubDomain Filters without login
       ${resp}=  Get SubDomain Filters  foodJoints  restaurants
       Should Be Equal As Strings    ${resp.status_code}   200 
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
       
              
JD-TC-Get SubDomain Filters -2
       [Documentation]   Provider check to Get SubDomain Filters provider login
       ${resp}=  ProviderLogin  ${PUSERNAME2}  ${PASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=  Get SubDomain Filters  healthCare  physiciansSurgeons
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
JD-TC-Get SubDomain Filters -3
       [Documentation]   Provider check to Get SubDomain Filters consumer login
       ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=  Get SubDomain Filters  personalCare  beautyCare
       Should Be Equal As Strings  ${resp.status_code}  200
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
JD-TC-Get SubDomain Filters -UH1
       [Documentation]   Provider check to Get SubDomain Filters Domain and sub domain miss match
       ${resp}=  Get SubDomain Filters  personalCare  physiciansSurgeons
       Should Be Equal As Strings    ${resp.status_code}   422 
       Should Be Equal As Strings  "${resp.json()}"   "${INVALID_SUB_SECTOR}"
             
JD-TC-Get SubDomain Filters -UH2
       [Documentation]   Provider check to Get SubDomain Filters with invlid domain and subdomain
       ${resp}=  Get SubDomain Filters  healthCare  YYY
       Should Be Equal As Strings    ${resp.status_code}   422
       Should Be Equal As Strings  "${resp.json()}"   "${INVALID_SUB_SECTOR}"