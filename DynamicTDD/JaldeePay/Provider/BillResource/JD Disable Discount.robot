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
${discount}   Disc11
${discount2}  Disc21

*** Test Cases ***

JD-TC-Disable Discount-1
       [Documentation]   login in a Valid provider create and Disable Discounts
       ${resp}=   Encrypted Provider Login   ${PUSERNAME239}   ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       clear_Discount  ${PUSERNAME239}
       ${desc}=  FakerLibrary.Sentence   nb_words=2
       ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
       ${type}=  Random Element  ${calctype}
       ${resp}=   Create Discount  ${discount}   ${desc}    ${amount}   ${type}  Predefine
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Test Variable   ${id1}   ${resp.json()}
       ${desc1}=  FakerLibrary.Sentence   nb_words=2
       ${type1}=  Random Element  ${calctype}
       ${amount1}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
       ${resp}=   Create Discount  ${discount2}   ${desc1}    ${amount1}   ${type1}  Predefine
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Suite Variable   ${id2}   ${resp.json()}
       ${resp}=   Get Discounts 
       Should Be Equal As Strings  ${resp.status_code}  200
       ${count}=  Get Length  ${resp.json()}
       Should Be Equal As Strings  ${count}  2
       Verify Response List   ${resp}   0  id=${id1}   name=${discount}   description=${desc}    discValue=${amount}   calculationType=${type}  status=${status[0]}
       Verify Response List   ${resp}   1  id=${id2}   name=${discount2}   description=${desc1}    discValue=${amount1}   calculationType=${type1}  status=${status[0]}
       ${resp}=   Disable Discount  ${id1}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=   Get Discounts   
       Should Be Equal As Strings  ${resp.status_code}  200
       ${count}=  Get Length  ${resp.json()}
       Should Be Equal As Strings  ${count}  2
       Verify Response List   ${resp}   0  id=${id1}   name=${discount}   description=${desc}    discValue=${amount}   calculationType=${type}  status=${status[1]}
       Verify Response List   ${resp}   1  id=${id2}   name=${discount2}   description=${desc1}    discValue=${amount1}   calculationType=${type1}  status=${status[0]}

JD-TC-Disable Discount-UH1
       [Documentation]   Consumer check to Disable Discount 
       ${resp}=   ConsumerLogin  ${CUSERNAME2}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Disable Discount     ${id2}
       Should Be Equal As Strings  ${resp.status_code}  401
       Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"
              
JD-TC-Disable Discount-UH2
       [Documentation]   Provider check to Disable Discount  without login
       ${resp}=    Disable Discount    ${id2}
       Should Be Equal As Strings  ${resp.status_code}  419
       Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-Disable Discount-UH3
       [Documentation]   Provider check to Disable Discount with another provider's discount id
       ${resp}=   Encrypted Provider Login   ${PUSERNAME120}   ${PASSWORD} 
       Should Be Equal As Strings  ${resp.status_code}  200       
       ${resp}=   Disable Discount    ${id2}
       Should Be Equal As Strings  ${resp.status_code}  422
       Should Be Equal As Strings  "${resp.json()}"  "${INCORRECT_DISCOUNT_ID}"

JD-TC-Disable Discount-UH4
       [Documentation]   Provider check to Disable Discount with invalid discount id
       ${resp}=   Encrypted Provider Login   ${PUSERNAME239}   ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200       
       ${resp}=   Disable Discount   0
       Should Be Equal As Strings  ${resp.status_code}  422 
       Should Be Equal As Strings  "${resp.json()}"   "${INCORRECT_DISCOUNT_ID}"  

JD-TC- Disable Discount-2
       [Documentation]  1 Try to Disable Discount that is on bill
       comment  2 remove disconunt from bill and delet discount
       ${resp}=   Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       clear_Discount  ${PUSERNAME120}

       ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
       Log   ${resp.json()}
       Should Be Equal As Strings  ${resp.status_code}  200
    
       ${resp}=  Get jaldeeIntegration Settings
       Log   ${resp.json()}
       Should Be Equal As Strings  ${resp.status_code}  200
       Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}


       ${desc}=  FakerLibrary.Sentence   nb_words=2
       ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
       ${resp}=   Create Discount  ${discount}   ${desc}    ${amount}   ${calctype[0]}  Predefine
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Test Variable   ${discountId}   ${resp.json()}
       clear_location  ${PUSERNAME120}
       clear_customer   ${PUSERNAME120}
       
       ${resp} =  Create Sample Queue
       Set Suite Variable  ${s_id}  ${resp['service_id']}
       Set Suite Variable  ${qid}   ${resp['queue_id']}
       Set Suite Variable   ${lid}   ${resp['location_id']}

       ${resp}=   Get Location ById  ${lid}
       Log  ${resp.content}
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
      
       ${resp}=  AddCustomer  ${CUSERNAME4}
       Log   ${resp.json()}
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Test Variable  ${cid}  ${resp.json()}      
       ${DAY}=  db.get_date_by_timezone  ${tz}
       ${resp}=  Add To Waitlist  ${cId}  ${s_id}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cId}
       Should Be Equal As Strings  ${resp.status_code}  200
       
       ${wid}=  Get Dictionary Values  ${resp.json()}
       Set Test Variable  ${wid}  ${wid[0]}
       ${resp}=  Get Bill By UUId  ${wid} 
       Should Be Equal As Strings  ${resp.status_code}  200
       ${service}=  Service Bill  ${desc}  ${s_id}  1  ${discountId}
       ${resp}=  Update Bill   ${wid}  addServiceLevelDiscount   ${service}  
       Log  ${resp.json()}
       Should Be Equal As Strings  ${resp.status_code}  200    
       ${resp}=   Disable Discount   ${discountId}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=   Get Discount By Id   ${discountId} 
       Should Be Equal As Strings  ${resp.status_code}  200
       Verify Response  ${resp}   id=${discountId}  name=${discount}   description=${desc}    discValue=${amount}   calculationType=${calctype[0]}  status=IN${status[0]}


JD-TC- Disable Discount-3
       [Documentation]  Disable Discount that is on setled bill
       ${resp}=   Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${desc}=  FakerLibrary.Sentence   nb_words=2
       ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
       ${resp}=   Create Discount  ${discount2}   ${desc}    ${amount}   ${calctype[0]}  Predefine
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Test Variable   ${discountId}   ${resp.json()}

       ${resp}=  AddCustomer  ${CUSERNAME9}
       Log   ${resp.json()}
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Suite Variable  ${cid}  ${resp.json()}   
       ${DAY}=  db.get_date_by_timezone  ${tz}
       ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${qid}  ${DAY}  hi  True  ${cid}
       Should Be Equal As Strings  ${resp.status_code}  200
       
       ${wid}=  Get Dictionary Values  ${resp.json()}
       Set Test Variable  ${wid}  ${wid[0]}

       ${resp}=  Get Bill By UUId  ${wid}
       Log  ${resp.json()}
       Should Be Equal As Strings  ${resp.status_code}  200

       ${service}=  Service Bill  ${desc}  ${s_id}  1  ${discountId}
       ${resp}=  Update Bill   ${wid}  addServiceLevelDiscount   ${service}  
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=  Get Bill By UUId  ${wid}
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Test Variable  ${tamount}  ${resp.json()['amountDue']} 
       ${resp}=  Accept Payment  ${wid}  cash  ${tamount}
       Log  ${resp.json()}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=  Settl Bill  ${wid}
       Should Be Equal As Strings  ${resp.status_code}  200              
       ${resp}=   Disable Discount   ${discountId}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=   Get Discount By Id   ${discountId} 
       Should Be Equal As Strings  ${resp.status_code}  200
       Verify Response  ${resp}   id=${discountId}   name=${discount2}   description=${desc}    discValue=${amount}   calculationType=${calctype[0]}  status=IN${status[0]}  




