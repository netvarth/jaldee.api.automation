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
${discount}    Disc11
${discount2 }  Disc21
  
*** Test Cases ***

JD-TC-Create Discount-1
       [Documentation]   Provider check to Create Discount in Fixed type
       ${resp}=   Encrypted Provider Login  ${PUSERNAME235}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       clear_Discount  ${PUSERNAME235}
       ${desc}=  FakerLibrary.Sentence   nb_words=2
       ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
       ${resp}=   Create Discount  ${discount}   ${desc}    ${amount}   ${calctype[1]}  ${disctype[0]}
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Suite Variable   ${id}   ${resp.json()}
       ${resp}=   Get Discount By Id  ${id}
       Should Be Equal As Strings  ${resp.status_code}  200
       Verify Response   ${resp}   id=${id}   name=${discount}   description=${desc}    discValue=${amount}   calculationType=${calctype[1]}  status=${status[0]}

JD-TC-Create Discounts-2
       [Documentation]   Provider create Discount of an account with same discount name of another provider
       ${resp}=   Encrypted Provider Login  ${PUSERNAME236}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       clear_Discount  ${PUSERNAME236}
       ${desc}=  FakerLibrary.Sentence   nb_words=2
       ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
       ${type}=  Random Element  ${calctype}
       ${resp}=   Create Discount   ${discount}   ${desc}    ${amount}   ${type}  ${disctype[0]}
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Test Variable   ${id1}   ${resp.json()}
       ${resp}=   Get Discount By Id   ${id1} 
       Should Be Equal As Strings  ${resp.status_code}  200
       Verify Response   ${resp}   id=${id1}   name=${discount}   description=${desc}    discValue=${amount}   calculationType=${type}  status=${status[0]}
       
       
JD-TC-Create Discounts-3
       [Documentation]   Provider login to create Discount  in Percentage type
       ${resp}=   Encrypted Provider Login  ${PUSERNAME235}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${desc}=  FakerLibrary.Sentence   nb_words=2
       ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
       ${resp}=   Create Discount   ${discount2}   ${desc}    ${amount}   ${calctype[0]}  ${disctype[0]}
       Log   ${resp.json()}
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Test Variable  ${id2}   ${resp.json()}
       ${resp}=   Get Discount By Id  ${id2} 
       Should Be Equal As Strings  ${resp.status_code}  200
       Verify Response   ${resp}  id=${id2}   name=${discount2}   description=${desc}    discValue=${amount}   calculationType=${calctype[0]}  status=${status[0]}
       
       
JD-TC-Create Discount-UH1
       [Documentation]   Consumer check to Create Discount
       ${resp}=   ConsumerLogin  ${CUSERNAME2}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${desc}=  FakerLibrary.Sentence   nb_words=2
       ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
       ${type}=  Random Element  ${calctype}
       ${resp}=   Create Discount  ${discount}   ${desc}    ${amount}   ${type}  ${disctype[0]}
       Should Be Equal As Strings  ${resp.status_code}  401
       Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"
              
JD-TC-Create Discount-UH2
       [Documentation]  Create discount without login
       ${desc}=  FakerLibrary.Sentence   nb_words=2
       ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
       ${type}=  Random Element  ${calctype}
       ${resp}=  Create Discount  ${discount}   ${desc}    ${amount}   ${type}  ${disctype[0]}
       Should Be Equal As Strings  ${resp.status_code}  419
       Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"
       
JD-TC-Create Discount-UH3
       [Documentation]   Create Discount with already existing name
       ${resp}=   Encrypted Provider Login  ${PUSERNAME235}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${desc}=  FakerLibrary.Sentence   nb_words=2
       ${amount}=  Random Int  min=10  max=100
       ${amount}=  Convert To Number  ${amount}  1
       ${type}=  Random Element  ${calctype}
       ${resp}=   Create Discount   ${discount}   ${desc}    ${amount}   ${type}  ${disctype[0]}
       Should Be Equal As Strings  ${resp.status_code}    422
       Should Be Equal As Strings  "${resp.json()}"   "${A_DISCOUNT_ALREADY_EXISTS}"
       
