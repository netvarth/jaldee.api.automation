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
${discount}   Discge11
${discount2}  Discge21

*** Test Cases ***

JD-TC-Get Discounts-1
       [Documentation]   Provider login to Get Discounts
       ${resp}=   ProviderLogin  ${PUSERNAME246}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       clear_Discount  ${PUSERNAME246}
       ${desc}=  FakerLibrary.Sentence   nb_words=2
       ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
       ${type}=  Random Element  ${calctype}
       ${resp}=   Create Discount   ${discount}   ${desc}    ${amount}   ${type}  Predefine
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Test Variable   ${id1}   ${resp.json()}
       ${desc2}=  FakerLibrary.Sentence   nb_words=2
       ${amount2}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
       ${type2}=  Random Element  ${calctype}
       ${resp}=   Create Discount   ${discount2}   ${desc2}    ${amount2}   ${type2}  Predefine
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Test Variable   ${id2}   ${resp.json()}
       ${resp}=   Get Discounts 
       Should Be Equal As Strings  ${resp.status_code}  200
       ${count}=  Get Length  ${resp.json()}
       Should Be Equal As Strings  ${count}  2
       Verify Response List   ${resp}   0  id=${id1}   name=${discount}   description=${desc}    discValue=${amount}   calculationType=${type}  status=${status[0]}  discType=Predefine
       Verify Response List   ${resp}   1  id=${id2}  name=${discount2}   description=${desc2}    discValue=${amount2}   calculationType=${type2}  status=${status[0]}  discType=Predefine
       
JD-TC-Get Discounts-UH1
       [Documentation]   Consumer check to get Discounts 
       ${resp}=   ConsumerLogin  ${CUSERNAME2}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Get Discounts 
       Should Be Equal As Strings  ${resp.status_code}  401
       Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"
              
JD-TC-Get Discounts-UH2
       [Documentation]   get Discounts account without login
       ${resp}=  Get Discounts 
       Should Be Equal As Strings  ${resp.status_code}  419
       Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"