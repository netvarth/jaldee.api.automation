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

JD-TC-Get Spoke Languages -1
       [Documentation]   Get Spoke Languages
       ${resp}=  Get Spoke Languages
       Should Be Equal As Strings    ${resp.status_code}   200 
       Should Be Equal As Strings    ${resp.json()[0]['name']}  assamese    
       Should Be Equal As Strings    ${resp.json()[0]['displayName']}  Assamese       
       Should Be Equal As Strings    ${resp.json()[1]['name']}  bengali    
       Should Be Equal As Strings    ${resp.json()[1]['displayName']}  Bengali  
       Should Be Equal As Strings    ${resp.json()[2]['name']}  english    
       Should Be Equal As Strings    ${resp.json()[2]['displayName']}  English 
       Should Be Equal As Strings    ${resp.json()[3]['name']}  gujarati    
       Should Be Equal As Strings    ${resp.json()[3]['displayName']}  Gujarati
       Should Be Equal As Strings    ${resp.json()[4]['name']}  hindi    
       Should Be Equal As Strings    ${resp.json()[4]['displayName']}  Hindi  
       Should Be Equal As Strings    ${resp.json()[5]['name']}  kannada    
       Should Be Equal As Strings    ${resp.json()[5]['displayName']}  Kannada
       Should Be Equal As Strings    ${resp.json()[6]['name']}  Konkani    
       Should Be Equal As Strings    ${resp.json()[6]['displayName']}  Konkani
       Should Be Equal As Strings    ${resp.json()[7]['name']}  malayalam     
       Should Be Equal As Strings    ${resp.json()[7]['displayName']}  Malayalam
       Should Be Equal As Strings    ${resp.json()[8]['name']}  Marathi    
       Should Be Equal As Strings    ${resp.json()[8]['displayName']}  Marathi
       Should Be Equal As Strings    ${resp.json()[9]['name']}  manipuri                     
       Should Be Equal As Strings    ${resp.json()[9]['displayName']}  Manipuri
       Should Be Equal As Strings    ${resp.json()[10]['name']}  oriya    
       Should Be Equal As Strings    ${resp.json()[10]['displayName']}  Oriya     
       Should Be Equal As Strings    ${resp.json()[11]['name']}  punjabi    
       Should Be Equal As Strings    ${resp.json()[11]['displayName']}  Punjabi    
       Should Be Equal As Strings    ${resp.json()[12]['name']}  rajasthani    
       Should Be Equal As Strings    ${resp.json()[12]['displayName']}  Rajasthani  
       Should Be Equal As Strings    ${resp.json()[13]['name']}  sanskrit    
       Should Be Equal As Strings    ${resp.json()[13]['displayName']}  Sanskrit     
       Should Be Equal As Strings    ${resp.json()[14]['name']}  tamil    
       Should Be Equal As Strings    ${resp.json()[14]['displayName']}  Tamil                  
       Should Be Equal As Strings    ${resp.json()[15]['name']}  telugu    
       Should Be Equal As Strings    ${resp.json()[15]['displayName']}  Telugu  
       Should Be Equal As Strings    ${resp.json()[16]['name']}  urdu    
       Should Be Equal As Strings    ${resp.json()[16]['displayName']}  Urdu
      
       
JD-TC-Get Spoke Languages -2
       [Documentation]   Provider check to Get Get Sub Domain Settings provider login
       ${resp}=  ProviderLogin  ${PUSERNAME2}  ${PASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=  Get Spoke Languages
       Should Be Equal As Strings    ${resp.status_code}   200 
       Should Be Equal As Strings    ${resp.json()[0]['name']}  assamese    
       Should Be Equal As Strings    ${resp.json()[0]['displayName']}  Assamese       
       Should Be Equal As Strings    ${resp.json()[1]['name']}  bengali    
       Should Be Equal As Strings    ${resp.json()[1]['displayName']}  Bengali  
       Should Be Equal As Strings    ${resp.json()[2]['name']}  english    
       Should Be Equal As Strings    ${resp.json()[2]['displayName']}  English 
       Should Be Equal As Strings    ${resp.json()[3]['name']}  gujarati    
       Should Be Equal As Strings    ${resp.json()[3]['displayName']}  Gujarati
       Should Be Equal As Strings    ${resp.json()[4]['name']}  hindi    
       Should Be Equal As Strings    ${resp.json()[4]['displayName']}  Hindi  
       Should Be Equal As Strings    ${resp.json()[5]['name']}  kannada    
       Should Be Equal As Strings    ${resp.json()[5]['displayName']}  Kannada
       Should Be Equal As Strings    ${resp.json()[6]['name']}  Konkani    
       Should Be Equal As Strings    ${resp.json()[6]['displayName']}  Konkani
       Should Be Equal As Strings    ${resp.json()[7]['name']}  malayalam    
       Should Be Equal As Strings    ${resp.json()[7]['displayName']}  Malayalam
       Should Be Equal As Strings    ${resp.json()[8]['name']}  Marathi    
       Should Be Equal As Strings    ${resp.json()[8]['displayName']}  Marathi
       Should Be Equal As Strings    ${resp.json()[9]['name']}  manipuri    
       Should Be Equal As Strings    ${resp.json()[9]['displayName']}  Manipuri
       Should Be Equal As Strings    ${resp.json()[10]['name']}  oriya    
       Should Be Equal As Strings    ${resp.json()[10]['displayName']}  Oriya     
       Should Be Equal As Strings    ${resp.json()[11]['name']}  punjabi    
       Should Be Equal As Strings    ${resp.json()[11]['displayName']}  Punjabi    
       Should Be Equal As Strings    ${resp.json()[12]['name']}  rajasthani    
       Should Be Equal As Strings    ${resp.json()[12]['displayName']}  Rajasthani 
       Should Be Equal As Strings    ${resp.json()[13]['name']}  sanskrit    
       Should Be Equal As Strings    ${resp.json()[13]['displayName']}  Sanskrit       
       Should Be Equal As Strings    ${resp.json()[14]['name']}  tamil    
       Should Be Equal As Strings    ${resp.json()[14]['displayName']}  Tamil                  
       Should Be Equal As Strings    ${resp.json()[15]['name']}  telugu    
       Should Be Equal As Strings    ${resp.json()[15]['displayName']}  Telugu  
       Should Be Equal As Strings    ${resp.json()[16]['name']}  urdu    
       Should Be Equal As Strings    ${resp.json()[16]['displayName']}  Urdu
    
           
         
                   
JD-TC-Get Spoke Languages -3
       [Documentation]   Get Spoke Languages
       ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=  Get Spoke Languages    
       Should Be Equal As Strings    ${resp.status_code}   200  
       Should Be Equal As Strings    ${resp.json()[0]['name']}  assamese    
       Should Be Equal As Strings    ${resp.json()[0]['displayName']}  Assamese       
       Should Be Equal As Strings    ${resp.json()[1]['name']}  bengali    
       Should Be Equal As Strings    ${resp.json()[1]['displayName']}  Bengali  
       Should Be Equal As Strings    ${resp.json()[2]['name']}  english    
       Should Be Equal As Strings    ${resp.json()[2]['displayName']}  English 
       Should Be Equal As Strings    ${resp.json()[3]['name']}  gujarati    
       Should Be Equal As Strings    ${resp.json()[3]['displayName']}  Gujarati
       Should Be Equal As Strings    ${resp.json()[4]['name']}  hindi    
       Should Be Equal As Strings    ${resp.json()[4]['displayName']}  Hindi  
       Should Be Equal As Strings    ${resp.json()[5]['name']}  kannada    
       Should Be Equal As Strings    ${resp.json()[5]['displayName']}  Kannada
       Should Be Equal As Strings    ${resp.json()[6]['name']}  Konkani    
       Should Be Equal As Strings    ${resp.json()[6]['displayName']}  Konkani
       Should Be Equal As Strings    ${resp.json()[7]['name']}  malayalam    
       Should Be Equal As Strings    ${resp.json()[7]['displayName']}  Malayalam
       Should Be Equal As Strings    ${resp.json()[8]['name']}  Marathi    
       Should Be Equal As Strings    ${resp.json()[8]['displayName']}  Marathi
       Should Be Equal As Strings    ${resp.json()[9]['name']}  manipuri    
       Should Be Equal As Strings    ${resp.json()[9]['displayName']}  Manipuri
       Should Be Equal As Strings    ${resp.json()[10]['name']}  oriya    
       Should Be Equal As Strings    ${resp.json()[10]['displayName']}  Oriya     
       Should Be Equal As Strings    ${resp.json()[11]['name']}  punjabi    
       Should Be Equal As Strings    ${resp.json()[11]['displayName']}  Punjabi    
       Should Be Equal As Strings    ${resp.json()[12]['name']}  rajasthani    
       Should Be Equal As Strings    ${resp.json()[12]['displayName']}  Rajasthani  
       Should Be Equal As Strings    ${resp.json()[13]['name']}  sanskrit    
       Should Be Equal As Strings    ${resp.json()[13]['displayName']}  Sanskrit      
       Should Be Equal As Strings    ${resp.json()[14]['name']}  tamil    
       Should Be Equal As Strings    ${resp.json()[14]['displayName']}  Tamil                  
       Should Be Equal As Strings    ${resp.json()[15]['name']}  telugu    
       Should Be Equal As Strings    ${resp.json()[15]['displayName']}  Telugu  
       Should Be Equal As Strings    ${resp.json()[16]['name']}  urdu    
       Should Be Equal As Strings    ${resp.json()[16]['displayName']}  Urdu