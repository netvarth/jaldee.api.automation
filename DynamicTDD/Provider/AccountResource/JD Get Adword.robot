*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Adword
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Test Cases ***

JD-TC-Get Adwords -1
       [Documentation]    Provider check to Get Adwords of an account  
       ${resp}=   Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD} 
       Log  ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200    
       ${resp}=   Get License UsageInfo 
       Log  ${resp.content}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${acid}=   get_acc_id  ${PUSERNAME11}       
       ${resp}=   clear_Adword  ${acid}     
       ${resp}=   Get Adword Count   
       Log  ${resp.json()}
       Should Be Equal As Strings  ${resp.status_code}   200
       Set Test Variable  ${addword_count}  ${resp.json()}
       ${resp}=   Get License UsageInfo 
       Log  ${resp.content}
       Should Be Equal As Strings  ${resp.status_code}  200
       FOR  ${count}  IN RANGE  ${addword_count}
              ${addword}=  FakerLibrary.name
              ${resp}=  Add Adword  ${addword} 
              Log  ${resp.json()}
              Should Be Equal As Strings  ${resp.status_code}   200
              ${resp}=   Get Adword 
              Log  ${resp.json()}  
              Should Be Equal As Strings  ${resp.status_code}   200
              Should Contain    "${resp.json()}"  ${addword}
       END
       ${resp}=   Get Adword 
       Log  ${resp.json()}  
       Should Be Equal As Strings  ${resp.status_code}   200
       ${adword_length}=  Get Length  ${resp.json()}
       Should Be True  ${addword_count}==${adword_length}

JD-TC-Get Adwords -UH1
       [Documentation]    consumer check to Get Adwords of an account
       ${resp}=   ConsumerLogin  ${CUSERNAME2}  ${PASSWORD} 
       Should Be Equal As Strings  ${resp.status_code}  200     
       ${resp}=   Get Adword    
       Should Be Equal As Strings  ${resp.status_code}   401 
       Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"           
       
JD-TC-Get Adwords -UH2
       [Documentation]    without login Get Adwords    
       ${resp}=   Get Adword   
       Should Be Equal As Strings  ${resp.status_code}   419
       Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
                   
       
       
       
       
       
           