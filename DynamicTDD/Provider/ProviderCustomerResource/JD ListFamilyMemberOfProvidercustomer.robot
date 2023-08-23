*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        FamilyMember
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 


*** Test Cases ***
      
JD-TC-ListFamilyMemberOfProvidercustomer-1
      [Documentation]    List a family member details by provider login
      ${resp}=  Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${pid}  ${resp.json()['id']}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${ph2}=  Evaluate  ${PUSERNAME23}+73003
      Set Suite Variable  ${email2}  ${firstname}${ph2}${C_Email}.${test_mail}
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${CUSERNAME12}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Set Suite Variable  ${pcid}  ${resp.json()}
      Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERNAME12}${\n}
      ${firstname1}=  FakerLibrary.first_name
      Set Suite Variable  ${firstname1}
      ${lastname1}=  FakerLibrary.last_name
      Set Suite Variable   ${lastname1}
      ${dob1}=  FakerLibrary.Date
      Set Suite Variable   ${dob1}
      ${gender1}=  Random Element    ${Genderlist}
      Set Suite Variable   ${gender1}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+400000

      ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${pcid}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  ${Familymember_ph}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${mem_id}  ${resp.json()}
      ${resp}=  ListFamilyMemberByProvider  ${pcid}
      Log  ${resp.json()}
      Verify Response List  ${resp}  0  id=${mem_id}  
      Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname1}
      Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname1}
      Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob1}
      Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender1}

JD-TC-ListFamilyMemberOfProvidercustomer-2
      [Documentation]    List more family members details by provider login
      ${resp}=  Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+400001

      ${resp}=  AddFamilyMemberByProviderWithPhoneNo   ${pcid}  ${firstname}  ${lastname}  ${dob}  ${gender}  ${Familymember_ph}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id1}  ${resp.json()}
      ${resp}=  ListFamilyMemberByProvider  ${pcid}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${len}
      Should Be Equal As Strings   ${len}   2

      Verify Response List  ${resp}  0  id=${mem_id}  
      Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname1}
      Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname1}
      Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob1}
      Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender1}

      Verify Response List  ${resp}  1  id=${mem_id1}  
      Should Be Equal As Strings  ${resp.json()[1]['firstName']}  ${firstname}
      Should Be Equal As Strings  ${resp.json()[1]['lastName']}  ${lastname}
      Should Be Equal As Strings  ${resp.json()[1]['dob']}  ${dob}
      Should Be Equal As Strings  ${resp.json()[1]['gender']}  ${gender}

JD-TC-ListFamilyMemberOfProvidercustomer-3
      [Documentation]    Add a family member by provider own his family memeber then list family memeber details
      ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${pid}  ${resp.json()['id']}
      clear_FamilyMember  ${pid}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${ph2}=  Evaluate  ${PUSERNAME23}+73003
      Set Suite Variable  ${email}  ${firstname}${ph2}${C_Email}.${test_mail}
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email}  ${gender}  ${dob}  ${PUSERNAME8}  ${EMPTY}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      # Log  ${resp.json()}
      Set Suite Variable  ${pcid2}  ${resp.json()}
      Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME}${\n}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+400002

      ${resp}=  AddFamilyMemberByProviderWithPhoneNo   ${pcid2}  ${firstname}  ${lastname}  ${dob}  ${gender}  ${Familymember_ph}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${fid}  ${resp.json()}
      ${resp}=  ListFamilyMemberByProvider  ${pcid2}
      Verify Response List  ${resp}  0  id=${fid} 
      Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
      Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
      Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
      Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender} 


JD-TC-ListFamilyMemberOfProvidercustomer-4
      [Documentation]    Adding customer and add 2 familymembers , after if the consumer signup ,familymembers are list there.
      ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${p_id}  ${resp.json()['id']}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${ph2}=  Evaluate  ${PUSERNAME23}+73099
      Set Test Variable  ${email}  ${firstname}${ph2}${C_Email}.${test_mail}
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email}  ${gender}  ${dob}   ${ph2}  ${EMPTY}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      # Log  ${resp.json()}
      Set Test Variable  ${pcid3}  ${resp.json()}
      Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph2}${\n}
      ${firstname1}=  FakerLibrary.first_name
      ${lastname1}=  FakerLibrary.last_name
      ${dob1}=  FakerLibrary.Date
      ${gender1}=  Random Element    ${Genderlist}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+400003

      ${resp}=  AddFamilyMemberByProviderWithPhoneNo   ${pcid3}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}   ${Familymember_ph}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id1}  ${resp.json()}
      ${firstname2}=  FakerLibrary.first_name
      ${lastname2}=  FakerLibrary.last_name
      ${dob2}=  FakerLibrary.Date
      ${gender2}=  Random Element    ${Genderlist}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+400004

      ${resp}=  AddFamilyMemberByProviderWithPhoneNo   ${pcid3}  ${firstname2}  ${lastname2}  ${dob2}  ${gender2}  ${Familymember_ph}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id2}  ${resp.json()}
      ${address}=  FakerLibrary.Address
      ${alternativeNo}=  Evaluate  ${PUSERNAME23}+73004
      ${resp}=  Consumer SignUp   ${firstname}  ${lastname}  ${address}  ${ph2}  ${alternativeNo}  ${dob}  ${gender}  ${EMPTY} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Consumer Activation  ${ph2}  1
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Set Credential  ${ph2}  ${PASSWORD}  1
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Login   ${ph2}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMember  
      Should Be Equal As Strings  ${resp.status_code}  200
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.json()}   []
      # ${len}=  Get Length  ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Log  ${len}
      # Should Be Equal As Strings   ${len}   2
      # Verify Response List  ${resp}  0  user=${mem_id2}
      # Verify Response List  ${resp}  1  user=${mem_id1}
      # Should Be Equal As Strings  ${resp.json()[0]['userProfile']['firstName']}  ${firstname2}
      # Should Be Equal As Strings  ${resp.json()[0]['userProfile']['lastName']}  ${lastname2}
      # Should Be Equal As Strings  ${resp.json()[0]['userProfile']['dob']}  ${dob2}
      # Should Be Equal As Strings  ${resp.json()[0]['userProfile']['gender']}  ${gender2}    

      # Should Be Equal As Strings  ${resp.json()[1]['userProfile']['firstName']}  ${firstname1}
      # Should Be Equal As Strings  ${resp.json()[1]['userProfile']['lastName']}  ${lastname1}
      # Should Be Equal As Strings  ${resp.json()[1]['userProfile']['dob']}  ${dob1}
      # Should Be Equal As Strings  ${resp.json()[1]['userProfile']['gender']}  ${gender1}    
      ${resp}=  ProviderLogout

JD-TC-ListFamilyMemberOfProvidercustomer-5
      [Documentation]    Adding a customer and add two family members with two different providers ,in this case one family member is common and if the consumer sign up,then  the list of family members should not be duplicated.
      ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${p_id}  ${resp.json()['id']}
      ${firstname}=  FakerLibrary.first_name
      Set Test Variable  ${firstname}
      ${lastname}=  FakerLibrary.last_name
      Set Test Variable  ${lastname}
      ${ph3}=  Evaluate  ${PUSERNAME23}+73098
      Set Test Variable  ${email3}  ${firstname}${ph3}${C_Email}.${test_mail}
      ${dob}=  FakerLibrary.Date
      Set Test Variable  ${dob}
      ${gender}=  Random Element    ${Genderlist}
      Set Test Variable  ${gender}
      ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email3}  ${gender}  ${dob}  ${ph3}  ${EMPTY}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${pcid4}  ${resp.json()}
      # Log  ${resp.json()}
      Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph3}${\n}
      ${firstname1}=  FakerLibrary.first_name
      Set Test Variable  ${firstname1}
      ${lastname1}=  FakerLibrary.last_name
      Set Test Variable  ${lastname1}
      ${dob1}=  FakerLibrary.Date
      Set Test Variable  ${dob1}
      ${gender1}=  Random Element    ${Genderlist}
      Set Test Variable  ${gender1}
      ${Familymember_ph1}=  Evaluate  ${PUSERNAME0}+400005
      Set Test Variable  ${Familymember_ph1}
      ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${pcid4}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  ${Familymember_ph1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Set Test Variable  ${mem_id1}  ${resp.json()}
      ${firstname2}=  FakerLibrary.first_name
      ${lastname2}=  FakerLibrary.last_name
      ${dob2}=  FakerLibrary.Date
      ${gender2}=  Random Element    ${Genderlist}
      Set Test Variable  ${gender2}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+400005

      ${resp}=  AddFamilyMemberByProviderWithPhoneNo     ${pcid4}    ${firstname2}  ${lastname2}  ${dob2}  ${gender2}   ${Familymember_ph}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id2}  ${resp.json()}
      ${resp}=  ProviderLogout
      ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}  ${gender}  ${dob}  ${ph3}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${pcid5}  ${resp.json()}
      Log  ${resp.json()}
      ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${pcid5}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  ${Familymember_ph1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id3}  ${resp.json()}
      ${firstname3}=  FakerLibrary.first_name
      ${lastname3}=  FakerLibrary.last_name
      ${dob3}=  FakerLibrary.Date
      ${gender3}=  Random Element    ${Genderlist}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+400006

      ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${pcid5}   ${firstname3}  ${lastname3}  ${dob3}  ${gender3}  ${Familymember_ph}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id4}  ${resp.json()}
      ${address}=  FakerLibrary.Address
      ${alternativeNo}=  Evaluate  ${PUSERNAME23}+73004
      ${resp}=  Consumer SignUp   ${firstname}  ${lastname}  ${address}  ${ph3}  ${alternativeNo}  ${dob}  ${gender}  ${EMPTY} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Consumer Activation   ${ph3}   1
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Set Credential   ${ph3}   ${PASSWORD}  1
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Login  ${ph3}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMember  
      Should Be Equal As Strings  ${resp.status_code}  200
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.json()}   []
      
      # ${len}=  Get Length  ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Log  ${len}
      # Should Be Equal As Strings   ${len}   3
      # Verify Response List  ${resp}  0  user=${mem_id4}
      # Verify Response List  ${resp}  1  user=${mem_id2}
      # Verify Response List  ${resp}  2  user=${mem_id1}
      # Should Not Contain   ${resp}  3  user=${mem_id3}
      # Should Be Equal As Strings  ${resp.json()[0]['userProfile']['firstName']}  ${firstname3}
      # Should Be Equal As Strings  ${resp.json()[0]['userProfile']['lastName']}  ${lastname3}
      # Should Be Equal As Strings  ${resp.json()[0]['userProfile']['dob']}  ${dob3}
      # Should Be Equal As Strings  ${resp.json()[0]['userProfile']['gender']}  ${gender3}   

      # Should Be Equal As Strings  ${resp.json()[1]['userProfile']['firstName']}  ${firstname2}
      # Should Be Equal As Strings  ${resp.json()[1]['userProfile']['lastName']}  ${lastname2}
      # Should Be Equal As Strings  ${resp.json()[1]['userProfile']['dob']}  ${dob2}
      # Should Be Equal As Strings  ${resp.json()[1]['userProfile']['gender']}  ${gender2}    

      # Should Be Equal As Strings  ${resp.json()[2]['userProfile']['firstName']}  ${firstname1}
      # Should Be Equal As Strings  ${resp.json()[2]['userProfile']['lastName']}  ${lastname1}
      # Should Be Equal As Strings  ${resp.json()[2]['userProfile']['dob']}  ${dob1}
      # Should Be Equal As Strings  ${resp.json()[2]['userProfile']['gender']}  ${gender1}  
      ${resp}=  ProviderLogout

JD-TC-ListFamilyMemberOfProvidercustomer-UH1
      [Documentation]  List a family member  details without login
      ${resp}=  ListFamilyMemberByProvider  ${pcid}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  419
      Should Be Equal As Strings  "${resp.json()}"    	"${SESSION_EXPIRED}"
      

JD-TC-ListFamilyMemberOfProvidercustomer-UH2
      [Documentation]    invalid id using in ListFamilyMemberByProvider
      ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMemberByProvider   0
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"   "${INVALID_ID}"

JD-TC-ListFamilyMemberOfProvidercustomer-UH3
      [Documentation]    Adding a customer and add two family members  and another provider trying to list these family member
      ${resp}=  Encrypted Provider Login  ${PUSERNAME176}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      clear_location  ${PUSERNAME176}
      clear_queue  ${PUSERNAME176}
      clear waitlist   ${PUSERNAME176}
      clear_customer   ${PUSERNAME176}
      ${resp}=   ProviderKeywords.Get Queues
      Should Be Equal As Strings  ${resp.status_code}  200
      Log   ${resp.json()}
      ${resp} =  Create Sample Queue
      Set Test Variable  ${s_id}  ${resp['service_id']}
      Set Test Variable  ${qid}   ${resp['queue_id']}
      Set Suite Variable   ${lid}   ${resp['location_id']}

      ${resp}=   Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
      # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
      # Log   ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Set Test Variable  ${c_id}  ${resp.json()[0]['id']}
      ${resp}=  AddCustomer  ${CUSERNAME2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${c_id}  ${resp.json()}
      ${firstname0}=  FakerLibrary.first_name
      ${lastname0}=  FakerLibrary.last_name
      ${dob0}=  FakerLibrary.Date
      ${gender0}=  Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProvider  ${c_id}  ${firstname0}  ${lastname0}  ${dob0}  ${gender0}  
      Log  ${resp.json()}
      Set Suite Variable  ${mem_id0}  ${resp.json()}
      ${firstname1}=  FakerLibrary.first_name
      ${lastname1}=  FakerLibrary.last_name
      ${dob1}=  FakerLibrary.Date
      ${gender1}=  Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProvider    ${c_id}   ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  
      Log  ${resp.json()}
      Set Test Variable  ${mem_id1}  ${resp.json()}
      ${DAY}=  db.get_date_by_timezone  ${tz}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${c_id}  ${s_id}  ${qid}  ${DAY}  ${desc}  ${bool[1]}  ${mem_id0}   
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[1]}
      ${resp}=  ListFamilyMemberByProvider  ${c_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Verify Response List  ${resp}  0  id=${mem_id0}
      Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname0}
      Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname0}
      Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob0}
      Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender0}

      Verify Response List  ${resp}  1  id=${mem_id1}
      Should Be Equal As Strings  ${resp.json()[1]['firstName']}  ${firstname1}
      Should Be Equal As Strings  ${resp.json()[1]['lastName']}  ${lastname1}
      Should Be Equal As Strings  ${resp.json()[1]['dob']}  ${dob1}
      Should Be Equal As Strings  ${resp.json()[1]['gender']}  ${gender1}

      ${resp}=  ProviderLogout
      ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      clear_location  ${PUSERNAME1}
      clear_queue  ${PUSERNAME1}
      clear_customer   ${PUSERNAME1}
      ${resp}=   ProviderKeywords.Get Queues
      Should Be Equal As Strings  ${resp.status_code}  200
      Log   ${resp.json()}
      ${resp} =  Create Sample Queue
      Set Test Variable  ${s_id}  ${resp['service_id']}
      Set Test Variable  ${qid}   ${resp['queue_id']}
      Set Suite Variable   ${lid}   ${resp['location_id']}

      ${resp}=   Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

      # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
      # Log   ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Set Test Variable  ${c_id1}  ${resp.json()[0]['id']}
      ${resp}=  AddCustomer  ${CUSERNAME2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${c_id1}  ${resp.json()}
      ${resp}=  ListFamilyMemberByProvider  ${c_id1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Should Be Equal As Strings   ${resp.json()}   []
      ${DAY}=  db.get_date_by_timezone  ${tz}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${c_id1}  ${s_id}  ${qid}  ${DAY}  ${desc}  ${bool[1]}  ${mem_id0}
      Log  ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  401
      # Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION}"
      Should Be Equal As Strings  ${resp.status_code}  404
      Should Be Equal As Strings  "${resp.json()}"   "${NOT_A_Familiy_Member}"

JD-TC-ListFamilyMemberOfProvidercustomer-UH4
      [Documentation]    Adding a customer and add one family members with one provider and add to waitlist  and list family member then delete that family member
      ${resp}=  Encrypted Provider Login  ${PUSERNAME176}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      clear_location  ${PUSERNAME176}
      clear_queue  ${PUSERNAME176}
      clear_customer   ${PUSERNAME176}
      ${resp}=   ProviderKeywords.Get Queues
      Should Be Equal As Strings  ${resp.status_code}  200
      Log   ${resp.json()}
      ${resp} =  Create Sample Queue
      Set Test Variable  ${s_id}  ${resp['service_id']}
      Set Test Variable  ${qid}   ${resp['queue_id']}
      Set Suite Variable   ${lid}   ${resp['location_id']}

      ${resp}=   Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

      # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
      # Log   ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Set Test Variable  ${cid}  ${resp.json()[0]['id']}
      ${resp}=  AddCustomer  ${CUSERNAME4}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}  ${resp.json()}

      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProvider  ${cid}  ${firstname}  ${lastname}  ${dob}  ${gender}  
      Log  ${resp.json()}
      Set Test Variable  ${mem_id0}  ${resp.json()}
      ${DAY}=  db.get_date_by_timezone  ${tz}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${qid}  ${DAY}  ${desc}  ${bool[1]}  ${mem_id0}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[1]}
      ${resp}=  ListFamilyMemberByProvider  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Verify Response List  ${resp}  0  id=${mem_id0}
      Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
      Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
      Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
      Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}

      ${resp}=  DeleteFamilymemberByprovidercustomer  ${mem_id0}  ${cid}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMemberByProvider  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Should Be Equal As Strings   ${resp.json()}   []


***comment***
JD-TC-AddFamilyMemberByProvider-3
      [Documentation]    Add a Familymember by provider switched to a consumer
      ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${id1}=  get_id  ${PUSERNAME0}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${ph2}=  Evaluate  ${PUSERNAME23}+73003
      Set Test Variable  ${email2}  ${firstname}${ph2}${C_Email}.${test_mail}
      ${gender}=  Random Element    ${Genderlist}
      ${dob}=  FakerLibrary.Date
      ${resp}=  AddCustomer   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${PUSERNAME0}  ${EMPTY}
      Set Suite Variable  ${pcid1}  ${resp.json()}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      clear_FamilyMember  ${id1}
      ${firstname}=  FakerLibrary.first_name
      Set Suite Variable  ${firstname}
      ${lastname}=  FakerLibrary.last_name
      Set Suite Variable  ${lastname}
      ${dob}=  FakerLibrary.Date
      Set Suite Variable  ${dob}
      ${gender}    Random Element    ['Male', 'Female']
      Set Suite Variable  ${gender}
      ${resp}=  AddFamilyMemberByProvider  ${pcid1}  ${firstname}  ${lastname}  ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id1}  ${resp.json()}
      ${resp}=  ListFamilyMemberByProvider  ${pcid1}
      Verify Response List  ${resp}  0  user=${mem_id1}




***comment***
JD-TC-ListFamilyMemberByProvider-3
      [Documentation]    List Familymember details by provider as a consumer
      ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${pid}  ${resp.json()['id']}
      clear_FamilyMember  ${pid}
      ${id1}=  get_id  ${PUSERNAME6}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${ph2}=  Evaluate  ${PUSERNAME23}+73003
      Set Suite Variable  ${email2}  ${firstname}${ph2}${C_Email}.${test_mail}
      ${gender}=  Random Element    ${Genderlist}
      ${dob}=  FakerLibrary.Date
      ${resp}=  AddCustomer   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${PUSERNAME6}  ${EMPTY}
      Set Suite Variable  ${pcid1}  ${resp.json()}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ['Male', 'Female']
      ${resp}=  AddFamilyMemberByProvider  ${pcid1}  ${firstname}  ${lastname}  ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id1}  ${resp.json()}
      ${resp}=  ListFamilyMemberByProvider  ${pcid1}
      Verify Response List  ${resp}  0  user=${mem_id1}  parent=${pcid1}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['firstName']}  ${firstname}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['lastName']}  ${lastname}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['dob']}  ${dob}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['gender']}  ${gender}