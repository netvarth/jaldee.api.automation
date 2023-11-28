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
${start}         190

*** Test Cases ***

JD-TC-Delete Discount-1
       [Documentation]   login in a Valid provider create and delete discounts
       ${resp}=   Encrypted Provider Login   ${PUSERNAME237}   ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       clear_Discount  ${PUSERNAME237}
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
       Log  ${resp.json()}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${count}=  Get Length  ${resp.json()}
       Should Be Equal As Strings  ${count}  2
       Verify Response List   ${resp}   0  id=${id1}   name=${discount}   description=${desc}    discValue=${amount}   calculationType=${type}  status=${status[0]}
       Verify Response List   ${resp}   1  id=${id2}   name=${discount2}   description=${desc1}    discValue=${amount1}   calculationType=${type1}  status=${status[0]}
       ${resp}=   Delete Discount  ${id1}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=   Get Discounts   
       Should Be Equal As Strings  ${resp.status_code}  200
       ${count}=  Get Length  ${resp.json()}
       Should Be Equal As Strings  ${count}  1
       Verify Response List   ${resp}   0  id=${id2}   name=${discount2}   description=${desc1}    discValue=${amount1}   calculationType=${type1}  status=${status[0]}

JD-TC-Delete Discount-UH1
       [Documentation]   Consumer check to delete Discount 
       ${resp}=   ConsumerLogin  ${CUSERNAME2}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Delete Discount     ${id2}
       Should Be Equal As Strings  ${resp.status_code}  401
       Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"
              
JD-TC-Delete Discount-UH2
       [Documentation]   Provider check to delete Discount  without login
       ${resp}=    Delete Discount    ${id2}
       Should Be Equal As Strings  ${resp.status_code}  419
       Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-Delete Discount-UH3
       [Documentation]   Provider check to delete discount with another provider's discount id
       ${resp}=   Encrypted Provider Login   ${PUSERNAME238}   ${PASSWORD} 
       Should Be Equal As Strings  ${resp.status_code}  200       
       ${resp}=   Delete Discount    ${id2}
       Should Be Equal As Strings  ${resp.status_code}  422
       Should Be Equal As Strings  "${resp.json()}"  "${INCORRECT_DISCOUNT_ID}"

JD-TC-Delete Discount-UH4
       [Documentation]   Provider check to delete discount with invalid discount id
       ${resp}=   Encrypted Provider Login   ${PUSERNAME238}   ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200       
       ${resp}=   Delete Discount   0
       Should Be Equal As Strings  ${resp.status_code}  422 
       Should Be Equal As Strings  "${resp.json()}"   "${INCORRECT_DISCOUNT_ID}"  

JD-TC- Delete Discount-UH5  
       [Documentation]  Try to delete discount that is on bill
       comment  2 remove disconunt from bill and delet discount
       comment  Try to delet coupon when coupon is remove from the bill by update
       ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
       ${len}=   Split to lines  ${resp}
       ${length}=  Get Length   ${len}
       
       FOR   ${a}  IN RANGE   ${start}  ${length}
       ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
       Should Be Equal As Strings    ${resp.status_code}    200
       ${domain}=   Set Variable    ${resp.json()['sector']}
       ${subdomain}=    Set Variable      ${resp.json()['subSector']}
       ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
       Should Be Equal As Strings    ${resp.status_code}    200
       Set Test Variable  ${check}  ${resp2.json()['serviceBillable']}
       Exit For Loop IF     "${check}" == "True"
       END
       clear_Discount  ${PUSERNAME${a}}
       clear_location  ${PUSERNAME${a}}
       clear_queue  ${PUSERNAME${a}}
       clear_service  ${PUSERNAME${a}}
       clear_customer   ${PUSERNAME${a}}
       sleep   1s

       ${list}=  Create List  1  2  3  4  5  6  7
    ${PUSERPH4}=  Evaluate  ${PUSERNAME${a}}+305
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH4}${\n}
    ${PUSERPH5}=  Evaluate  ${PUSERNAME}+306
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH5}${\n}
    ${PUSERMAIL3}=   Set Variable  ${P_Email}${PUSERPH4}.${test_mail}
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH4}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH5}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL3}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  0  15  
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Update Business Profile with schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${lid}  ${resp.json()['baseLocation']['id']}
    ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${fields.status_code}   200
    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}
    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Should Be Equal As Strings    ${resp.status_code}   200
    


       # ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
       # Log   ${resp.json()}
       # Should Be Equal As Strings  ${resp.status_code}  200
    
       # ${resp}=  Get jaldeeIntegration Settings
       # Log   ${resp.json()}
       # Should Be Equal As Strings  ${resp.status_code}  200
       # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   

       ${desc}=  FakerLibrary.Sentence   nb_words=2
       ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
       ${resp}=   Create Discount  ${discount}   ${desc}    ${amount}   ${calctype[0]}  Predefine
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Test Variable   ${discountId}   ${resp.json()}
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
       Set Suite Variable  ${cid}  ${resp.json()}     
       ${DAY}=  db.get_date_by_timezone  ${tz}
       ${resp}=  Add To Waitlist  ${cId}  ${s_id}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid}
       Should Be Equal As Strings  ${resp.status_code}  200
       
       ${wid}=  Get Dictionary Values  ${resp.json()}
       Set Test Variable  ${wid}  ${wid[0]}
       ${resp}=  Get Bill By UUId  ${wid} 
       Should Be Equal As Strings  ${resp.status_code}  200
       ${service}=  Service Bill  ${desc}  ${s_id}  1  ${discountId}
       ${resp}=  Update Bill   ${wid}  addServiceLevelDiscount   ${service}  
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=   Delete Discount   ${discountId}
       Should Be Equal As Strings  ${resp.status_code}  422 
       Should Contain   "${resp.json()}"   "${DISCOUNT_IS_IN_BILL}"
       ${resp}=  Update Bill   ${wid}  removeServiceLevelDiscount   ${service}  
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=   Delete Discount   ${discountId}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=   Get Discount By Id   ${discountId} 
       Should Be Equal As Strings  ${resp.status_code}  422
       Should Be Equal As Strings  "${resp.json()}"  "${INCORRECT_DISCOUNT_ID}"


JD-TC- Delete Discount-UH6 
       [Documentation]  delete discount that is on setled bill
       ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
       ${len}=   Split to lines  ${resp}
       ${length}=  Get Length   ${len}
       
       FOR   ${a}  IN RANGE   ${start}  ${length}
       ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
       Should Be Equal As Strings    ${resp.status_code}    200
       ${domain}=   Set Variable    ${resp.json()['sector']}
       ${subdomain}=    Set Variable      ${resp.json()['subSector']}
       ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
       Should Be Equal As Strings    ${resp.status_code}    200
       Set Test Variable  ${check}  ${resp2.json()['serviceBillable']}
       Exit For Loop IF     "${check}" == "True"
       END
       clear_Discount  ${PUSERNAME${a}}
       clear_customer   ${PUSERNAME${a}}
       ${desc}=  FakerLibrary.Sentence   nb_words=2
       ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
       ${resp}=   Create Discount  ${discount2}   ${desc}    ${amount}   ${calctype[0]}  Predefine
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Test Variable   ${discountId}   ${resp.json()}

       ${resp}=  AddCustomer  ${CUSERNAME2}
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
       ${resp}=   Delete Discount   ${discountId}
       Should Be Equal As Strings  ${resp.status_code}  422 
       Should Contain   "${resp.json()}"   "${DISCOUNT_IS_IN_BILL}"
       ${resp}=  Get Bill By UUId  ${wid}
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Test Variable  ${amount}  ${resp.json()['amountDue']}
       ${resp}=  Accept Payment  ${wid}  ${payment_modes[0]}  ${amount}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=  Settl Bill  ${wid}
       Should Be Equal As Strings  ${resp.status_code}  200    
       ${resp}=   Delete Discount   ${discountId}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=   Get Discount By Id   ${discountId} 
       Should Be Equal As Strings  ${resp.status_code}  422
       Should Be Equal As Strings  "${resp.json()}"  "${INCORRECT_DISCOUNT_ID}"    
       
       

 
