*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Discount
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

***Variables***
${discount}  Disc121

*** Test Cases ***

JD-TC-Get Discount By Id-1
       [Documentation]   Provider login to Get Discount By Id
       ${resp}=   ProviderLogin   ${PUSERNAME243}   ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       clear_Discount  ${PUSERNAME243}
       ${desc}=  FakerLibrary.Sentence   nb_words=2
       ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
       ${type}=  Random Element  ${calctype}
       ${resp}=   Create Discount   ${discount}   ${desc}    ${amount}   ${type}  Predefine
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Suite Variable   ${id1}   ${resp.json()}
       ${resp}=   Get Discount By Id   ${id1} 
       Should Be Equal As Strings  ${resp.status_code}  200
       Verify Response   ${resp}   id=${id1}   name=${discount}   description=${desc}    discValue=${amount}   calculationType=${type}  status=${status[0]}  discType=Predefine
       
JD-TC-Get Discount By Id-UH1
       [Documentation]   Consumer check to get Discount By Id
       ${resp}=   ConsumerLogin  ${CUSERNAME2}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Get Discount By Id  ${id1}  
       Should Be Equal As Strings  ${resp.status_code}  401
       Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"
              
JD-TC-Get Discount By Id-UH2
       [Documentation]   get Discount By Id  without login
       ${resp}=  Get Discount By Id  ${id1} 
       Should Be Equal As Strings  ${resp.status_code}  419
       Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-Get Discount By Id-UH3
       [Documentation]   Provider check to get Discount By Id with another provider's discount id
       ${resp}=   ProviderLogin   ${PUSERNAME244}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Get Discount By Id  ${id1}
       Should Be Equal As Strings  "${resp.json()}"   "${INCORRECT_DISCOUNT_ID}"    
       Should Be Equal As Strings  ${resp.status_code}   422 
       
JD-TC-Get Discount By Id-UH4
       [Documentation]    get Discount By Id using invalid discount id
       ${resp}=   ProviderLogin   ${PUSERNAME245}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Get Discount By Id  0
       Should Be Equal As Strings  ${resp.status_code}   422     
       Should Be Equal As Strings  "${resp.json()}"   "${INCORRECT_DISCOUNT_ID}" 


