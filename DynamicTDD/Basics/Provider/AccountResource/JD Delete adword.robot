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
JD-TC-Delete Adwords -1
       Comment    Provider delete a adword from his adword list
       ${resp}=   Encrypted Provider Login  ${PUSERNAME145}  ${PASSWORD} 
       Log  ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200 
       ${acid}=   get_acc_id  ${PUSERNAME145}       
       ${resp}=   clear_Adword  ${acid} 
       ${resp}=   Get Adword Count   
       Log  ${resp.json()}
       Should Be Equal As Strings  ${resp.status_code}   200
       Set Test Variable  ${addword_count}  ${resp.json()}
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
       Set Suite Variable  ${adId}  ${resp.json()[0]['id']}   
       ${resp}=  Delete Adword  ${adId}
       Should Be Equal As Strings  ${resp.status_code}   200
       ${adId}=  Convert To String  ${adId}
       ${resp}=   Get Adword   
       Should Be Equal As Strings  ${resp.status_code}   200
       Should Not Contain  "${resp.json()}"  ${adId}
       ${resp}=  Delete Adword  ${adId}
       Should Be Equal As Strings  ${resp.status_code}   422
       Should Be Equal As Strings  "${resp.json()}"  "${INVALID_ADWORD}"
       
JD-TC-Delete Adwords -UH1
       Comment    consumer check to Delete Adwords of an account
       ${resp}=   ConsumerLogin  ${CUSERNAME2}  ${PASSWORD} 
       Should Be Equal As Strings  ${resp.status_code}  200     
       ${resp}=  Delete Adword  ${adId}   
       Should Be Equal As Strings  ${resp.status_code}   401 
       Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"           
       
JD-TC-Delete Adwords -UH2
       Comment    without login Delete Adwords    
       ${resp}=  Delete Adword  ${adId}   
       Should Be Equal As Strings  ${resp.status_code}   419
       Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}" 
       
JD-TC-Delete Adwords -UH3
       Comment    Provider check to Delete Adwords  another Provider
       ${resp}=   Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=  Delete Adword  ${adId}            
       Should Be Equal As Strings  ${resp.status_code}   422
       Should Be Equal As Strings  "${resp.json()}"  "${INVALID_ADWORD}"
        
       