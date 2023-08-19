***Settings***
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
JD-TC-DeleteFamilymemberofprovidercustomer-1
      [Documentation]  Delete a family member with valid id and verify its deleted
      ${resp}=  ProviderLogin  ${PUSERNAME4}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      clear_customer   ${PUSERNAME4}
      # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
      # Log   ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
      ${resp}=  AddCustomer  ${CUSERNAME1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid}  ${resp.json()}

      ${firstname0}=  FakerLibrary.first_name
      Set Suite Variable  ${firstname0}
      ${lastname0}=  FakerLibrary.last_name
      Set Suite Variable  ${lastname0}
      ${dob0}=  FakerLibrary.Date
      Set Suite Variable  ${dob0}
      ${gender0}=  Random Element    ${Genderlist}
      Set Suite Variable  ${gender0}
      ${resp}=  AddFamilyMemberByProvider  ${cid}  ${firstname0}  ${lastname0}  ${dob0}  ${gender0}  
      Log  ${resp.json()}
      Set Suite Variable  ${mem_id0}  ${resp.json()}
      ${resp}=  DeleteFamilymemberByprovidercustomer  ${mem_id0}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMemberByProvider  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Should Not Contain   ${resp.json()}  "id":"${mem_id0}"


JD-TC-DeleteFamilymemberofprovidercustomer-UH1
      [Documentation]  Delete a family member with already deleted familymember id
      ${resp}=  ProviderLogin  ${PUSERNAME4}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  DeleteFamilymemberByprovidercustomer  ${mem_id0}  ${cid}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  404   
      Should Be Equal As Strings  "${resp.json()}"  "${NOT_A_FAMILY_MEMEBR }"
      # Should Be Equal As Strings  ${resp.status_code}  422
      # Should Be Equal As Strings  "${resp.json()}"  "${FAMILY_MEMEBR_NOT_FOUND }"
     
JD-TC-DeleteFamilymemberofprovidercustomer-UH2
      [Documentation]  Delete a family member with invalid familymember id
      ${resp}=  ProviderLogin  ${PUSERNAME4}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  DeleteFamilymemberByprovidercustomer  0   0
      Should Be Equal As Strings  ${resp.status_code}  422
      Log  ${resp.json()}
      Should Be Equal As Strings  "${resp.json()}"  "${FAMILY_MEMEBR_NOT_FOUND}"

JD-TC-DeleteFamilymemberofprovidercustomer-UH3
      [Documentation]  Delete a family member without login
      ${resp}=  DeleteFamilymemberByprovidercustomer  ${mem_id0}  ${cid}
      Should Be Equal As Strings    ${resp.status_code}   419
      Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"
         
JD-TC-DeleteFamilymemberofprovidercustomer-UH4
      [Documentation]  Delete a family member  with consumer login
      ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  DeleteFamilymemberByprovidercustomer  ${mem_id0}  ${cid}
      Should Be Equal As Strings    ${resp.status_code}   401
      Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-DeleteFamilymemberofprovidercustomer-UH5  
      [Documentation]  Delete a family member after waitlisted in a queue
      ${resp}=   ProviderLogin  ${PUSERNAME4}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}   200
      clear_location  ${PUSERNAME4}
      clear_queue  ${PUSERNAME4}
      ${resp}=   ProviderKeywords.Get Queues
      Should Be Equal As Strings  ${resp.status_code}  200
      Log   ${resp.json()}
      ${resp}=  Create Sample Queue
      Set Test Variable  ${s_id}  ${resp['service_id']}
      Set Test Variable  ${qid}   ${resp['queue_id']}
      ${firstname1}=  FakerLibrary.first_name
      ${lastname1}=  FakerLibrary.last_name
      ${dob1}=  FakerLibrary.Date
      ${gender1}=  Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProvider    ${cid}   ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  
      Log  ${resp.json()}
      Set Test Variable  ${mem_id1}  ${resp.json()}
      ${DAY}=  get_date
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${qid}  ${DAY}  ${desc}  ${bool[1]}  ${mem_id1}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[1]}
      ${resp}=  DeleteFamilymemberByprovidercustomer  ${mem_id1}  ${cid}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMemberByProvider  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}    []

      # Should Be Equal As Strings  ${resp.status_code}  422
      # # Should Be Equal As Strings  "${resp.json()}"  "${CANNOT_DEL_CUSTOMER}"
      # ${resp}=  ListFamilyMemberByProvider  ${cid}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Log  ${resp.json()}
      # Verify Response List  ${resp}  0  user=${mem_id1}
      # Should Be Equal As Strings  ${resp.json()[0]['userProfile']['firstName']}  ${firstname1}
      # Should Be Equal As Strings  ${resp.json()[0]['userProfile']['lastName']}  ${lastname1}
      # Should Be Equal As Strings  ${resp.json()[0]['userProfile']['dob']}  ${dob1}
      # Should Be Equal As Strings  ${resp.json()[0]['userProfile']['gender']}  ${gender1}
      # ${desc}=   FakerLibrary.word
      # ${resp}=  Waitlist Action Cancel  ${wid}  ${waitlist_cancl_reasn[4]}   ${desc}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # ${resp}=  Get Waitlist State Changes  ${wid}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # ${resp}=  DeleteFamilymemberByprovidercustomer  ${mem_id1}  ${cid}
      # Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-DeleteFamilymemberofprovidercustomer-UH6 
      [Documentation]  Delete a family member after waitlisted in a queue and check that family member in consumer side
      ${resp}=   ProviderLogin  ${PUSERNAME4}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}   200
      clear_location  ${PUSERNAME4}
      clear_queue  ${PUSERNAME4}
      ${resp}=   ProviderKeywords.Get Queues
      Should Be Equal As Strings  ${resp.status_code}  200
      Log   ${resp.json()}
      ${resp}=  Create Sample Queue
      Set Test Variable  ${s_id}  ${resp['service_id']}
      Set Test Variable  ${qid}   ${resp['queue_id']}
      ${firstname1}=  FakerLibrary.first_name
      ${lastname1}=  FakerLibrary.last_name
      ${dob1}=  FakerLibrary.Date
      ${gender1}=  Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProvider    ${cid}   ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  
      Log  ${resp.json()}
      Set Test Variable  ${mem_id1}  ${resp.json()}
      ${DAY}=  get_date
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${qid}  ${DAY}  ${desc}  ${bool[1]}  ${mem_id1}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[1]}
      ${resp}=  DeleteFamilymemberByprovidercustomer  ${mem_id1}  ${cid}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMemberByProvider  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}    []
      
      ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMember
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Not Contain  ${resp.json()}  id=${mem_id1}
      # Should Be Equal As Strings  ${resp.json()}    []

JD-TC-DeleteFamilymemberofprovidercustomer-UH7

      [Documentation]  Delete a family member after waitlisted in a queue in consumer side then delete that family member and check that family member in provider side
      ${resp}=   ProviderLogin  ${PUSERNAME76}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}   200
      ${pid0}=  get_acc_id  ${PUSERNAME76}
      Should Be Equal As Strings    ${resp.status_code}   200

      clear_location  ${PUSERNAME76}
      clear_queue  ${PUSERNAME76}
      Clear_service  ${PUSERNAME76}
      clear_customer   ${PUSERNAME76}
      ${resp}=  Create Sample Queue
      Set Test Variable  ${s_id}  ${resp['service_id']}
      Set Test Variable  ${qid}   ${resp['queue_id']}
      
      ${resp}=   ProviderLogout
      Should Be Equal As Strings    ${resp.status_code}   200

      ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${f_Name}  ${resp.json()['firstName']}
      Set Test Variable  ${l_Name}  ${resp.json()['lastName']}

      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  AddFamilyMember  ${firstname}  ${lastname}  ${dob}  ${gender}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${mem_id6}  ${resp.json()}

      ${DAY}=  get_date
      ${cnote}=   FakerLibrary.word
      ${resp}=  Add To Waitlist Consumers  ${pid0}  ${qid}  ${DAY}  ${s_id}  ${cnote}  ${bool[0]}  ${mem_id6} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200 
      
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid1}  ${wid[0]}

      ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}   
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1   waitlistedBy=CONSUMER
      Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id}
      # Should Be Equal As Strings  ${resp.json()['consumer']['jaldeeConsumer']}  ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${mem_id6}
      Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${qid}
      Set Test Variable  ${cfid}   ${resp.json()['waitlistingFor'][0]['id']}

      ${resp}=   ProviderLogin  ${PUSERNAME76}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}   200
      
      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME12}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      FOR  ${i}  IN RANGE   ${len}
            Run Keyword IF  '${resp.json()[${i}]['firstName']}' == '${f_Name}'
            ...   Set Suite Variable   ${cid}   ${resp.json()[${i}]['id']}
            ...    ELSE IF     '${resp.json()[${i}]['firstName']}' == '${firstname}' 
            ...   Should Be Equal As Strings   ${cfid}   ${resp.json()[${i}]['id']}
      END
      # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
      # ${resp}=  AddCustomer  ${CUSERNAME12}
      # Log   ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Set Suite Variable  ${cid}  ${resp.json()}

      ${resp}=  ListFamilyMemberByProvider  ${cid}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response List  ${resp}  0  id=${cfid}
      Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
      Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
      Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
      Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}

      ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  DeleteFamilyMember  ${mem_id6}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMember
      Should Not Contain  ${resp.json()}  id=${mem_id6}

      ${resp}=   ProviderLogin  ${PUSERNAME76}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}   200
      ${resp}=  ListFamilyMemberByProvider  ${cid}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response List  ${resp}  0  id=${cfid}
      ${resp}=  DeleteFamilymemberByprovidercustomer  ${cfid}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMemberByProvider  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Should Not Contain   ${resp.json()}  "id":"${cfid}"                
