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

JD-TC-Enable Discount-1
       [Documentation]   login in a Valid provider create and Enable Discounts
       ${resp}=   ProviderLogin   ${PUSERNAME241}   ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       clear_Discount  ${PUSERNAME241}
       ${desc}=  FakerLibrary.Sentence   nb_words=2
       ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
       ${type}=  Random Element  ${calctype}
       ${resp}=   Create Discount   ${discount}   ${desc}    ${amount}   ${type}  Predefine
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Suite Variable   ${id1}   ${resp.json()}
       ${resp}=   Get Discount By Id   ${id1} 
       Should Be Equal As Strings  ${resp.status_code}  200
       Verify Response   ${resp}   id=${id1}   name=${discount}   description=${desc}    discValue=${amount}   calculationType=${type}  status=${status[0]}  discType=Predefine
       ${resp}=   Disable Discount  ${id1}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=   Get Discount By Id   ${id1} 
       Should Be Equal As Strings  ${resp.status_code}  200
       Verify Response   ${resp}   id=${id1}   name=${discount}   description=${desc}    discValue=${amount}   calculationType=${type}  status=IN${status[0]}  discType=Predefine
       ${resp}=   Enable Discount  ${id1}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=   Get Discount By Id   ${id1} 
       Should Be Equal As Strings  ${resp.status_code}  200
       Verify Response   ${resp}   id=${id1}   name=${discount}   description=${desc}    discValue=${amount}   calculationType=${type}  status=${status[0]}  discType=Predefine
      
JD-TC-Enable Discount-UH1
       [Documentation]   Consumer check to Enable Discount 
       ${resp}=   ConsumerLogin  ${CUSERNAME2}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Enable Discount     ${id1}
       Should Be Equal As Strings  ${resp.status_code}  401
       Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"
              
JD-TC-Enable Discount-UH2
       [Documentation]   Provider check to Enable Discount  without login
       ${resp}=    Enable Discount    ${id1}
       Should Be Equal As Strings  ${resp.status_code}  419
       Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-Enable Discount-UH3
       [Documentation]   Provider check to Enable Discount with another provider's discount id
       ${resp}=   ProviderLogin   ${PUSERNAME242}   ${PASSWORD} 
       Should Be Equal As Strings  ${resp.status_code}  200       
       ${resp}=   Enable Discount    ${id1}
       Should Be Equal As Strings  ${resp.status_code}  422
       Should Be Equal As Strings  "${resp.json()}"  "${INCORRECT_DISCOUNT_ID}"

JD-TC-Enable Discount-UH4
       [Documentation]   Provider check to Enable Discount with invalid discount id
       ${resp}=   ProviderLogin   ${PUSERNAME241}   ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200       
       ${resp}=   Enable Discount   0
       Should Be Equal As Strings  ${resp.status_code}  422 
       Should Be Equal As Strings  "${resp.json()}"   "${INCORRECT_DISCOUNT_ID}"  

