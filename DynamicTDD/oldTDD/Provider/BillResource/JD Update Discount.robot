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
${discount}   Discup11
${discount2}  Discup21

*** Test Cases ***
JD-TC-Update Discount-1
       [Documentation]   Provider check to Update Discount 
       ${resp}=   Encrypted Provider Login  ${PUSERNAME247}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       clear_Discount  ${PUSERNAME247}
       ${desc}=  FakerLibrary.Sentence   nb_words=2
       ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
       ${type}=  Random Element  ${calctype}
       ${resp}=   Create Discount   ${discount}   ${desc}    ${amount}   ${type}  Predefine
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Suite variable  ${id}  ${resp.json()}
       ${resp}=   Get Discount By Id  ${id}
       Should Be Equal As Strings  ${resp.status_code}  200
       Verify Response  ${resp}   id=${id}  name=${discount}   description=${desc}    discValue=${amount}   calculationType=${type}  status=${status[0]}  discType=Predefine
       ${desc2}=  FakerLibrary.Sentence   nb_words=2
       ${amount2}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
       ${type2}=  Random Element  ${calctype}
       ${resp}=   Update Discount   ${id}  ${discount2}   ${desc2}    ${amount2}   ${type2}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=   Get Discount By Id  ${id}
       Should Be Equal As Strings  ${resp.status_code}  200
       Verify Response  ${resp}   id=${id}   name=${discount2}   description=${desc2}    discValue=${amount2}   calculationType=${type2}  status=${status[0]}  discType=Predefine
       
JD-TC-Update Discount-2
       [Documentation]   Provider login to Update Discount with same discount name of another provider
       ${resp}=   Encrypted Provider Login  ${PUSERNAME248}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       clear_Discount  ${PUSERNAME248}
       ${desc}=  FakerLibrary.Sentence   nb_words=2
       ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
       ${type}=  Random Element  ${calctype}
       ${resp}=   Create Discount   ${discount}   ${desc}    ${amount}   ${type}  Predefine
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Suite Variable   ${id1}   ${resp.json()}
       ${resp}=   Get Discount By Id  ${id1} 
       Should Be Equal As Strings  ${resp.status_code}  200
       Verify Response   ${resp}  id=${id1}    name=${discount}   description=${desc}    discValue=${amount}   calculationType=${type}  status=${status[0]}  discType=Predefine
       ${desc2}=  FakerLibrary.Sentence   nb_words=2
       ${amount2}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
       ${type2}=  Random Element  ${calctype}
       ${resp}=   Update Discount   ${id1}  ${discount2}   ${desc2}    ${amount2}   ${type2}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=   Get Discount By Id  ${id1}
       Should Be Equal As Strings  ${resp.status_code}  200
       Verify Response  ${resp}   id=${id1}   name=${discount2}   description=${desc2}    discValue=${amount2}   calculationType=${type2}  status=${status[0]}  discType=Predefine
       
JD-TC-Update Discount-3
       [Documentation]   Provider check to Update Discount with same discount name
       ${resp}=   Encrypted Provider Login  ${PUSERNAME247}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${desc2}=  FakerLibrary.Sentence   nb_words=2
       ${amount2}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
       ${type2}=  Random Element  ${calctype}
       ${resp}=   Update Discount   ${id}  ${discount2}   ${desc2}    ${amount2}   ${type2}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=   Get Discount By Id  ${id}
       Should Be Equal As Strings  ${resp.status_code}  200
       Verify Response  ${resp}   id=${id}   name=${discount2}   description=${desc2}    discValue=${amount2}   calculationType=${type2}  status=${status[0]}  discType=Predefine

       
JD-TC-Update Discount -UH1
       [Documentation]   Consumer check to Update Discount 
       ${resp}=   ConsumerLogin  ${CUSERNAME2}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${desc2}=  FakerLibrary.Sentence   nb_words=2
       ${amount2}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
       ${type2}=  Random Element  ${calctype}
       ${resp}=   Update Discount   ${id}  ${discount2}   ${desc2}    ${amount2}   ${type2}
       Should Be Equal As Strings  ${resp.status_code}  401
       Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"
              
JD-TC-Update Discount -UH2
       [Documentation]    Update Discount without login
       ${desc2}=  FakerLibrary.Sentence   nb_words=2
       ${amount2}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
       ${type2}=  Random Element  ${calctype}
       ${resp}=   Update Discount   ${id}  ${discount2}   ${desc2}    ${amount2}   ${type2}
       Should Be Equal As Strings  ${resp.status_code}  419
       Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"
       
JD-TC-Update Discount-UH3
       [Documentation]   Provider login to update Discounts with already existing discount name
       ${resp}=   Encrypted Provider Login  ${PUSERNAME249}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       clear_Discount  ${PUSERNAME249}
       ${desc}=  FakerLibrary.Sentence   nb_words=2
       ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
       ${type}=  Random Element  ${calctype}
       ${resp}=   Create Discount   ${discount}   ${desc}    ${amount}   ${type}  Predefine
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Test Variable   ${id4}   ${resp.json()}
       ${desc2}=  FakerLibrary.Sentence   nb_words=2
       ${amount2}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
       ${type2}=  Random Element  ${calctype}
       ${resp}=   Create Discount   ${discount2}   ${desc2}    ${amount2}   ${type2}  Predefine
       Should Be Equal As Strings  ${resp.status_code}  200
       
       ${resp}=   Update Discount   ${id4}  ${discount2}  ${desc2}    ${amount2}   ${type2}
       Should Be Equal As Strings  ${resp.status_code}  422
       Should Be Equal As Strings  "${resp.json()}"   "${A_DISCOUNT_ALREADY_EXISTS}"