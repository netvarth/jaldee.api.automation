*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Familymemeber
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

# *** Keywords ***
# Add FamilyMember For ProviderConsumer
#       [Arguments]  ${firstname}   ${lastname}   ${dob}   ${gender}    ${primarynum}        &{kwargs}
#       Check And Create YNW Session

#       ${userProfile}=  Create Dictionary    firstName=${firstname}   lastName=${lastname}   dob=${dob}   gender=${gender}   primaryMobileNo=${primarynum}   
#       ${data}=   Create Dictionary    userProfile=${userProfile}
#       FOR    ${key}    ${value}    IN    &{kwargs}
#             Set To Dictionary 	${data} 	${key}=${value}
#       END
#       ${resp}=  POST On Session  ynw   /consumer/familyMember   json=${data}    expected_status=any
#       RETURN  ${resp}


*** Test Cases ***

JD-TC-AddFamilyMemberOfProvidercustomer-1
      [Documentation]    Add a familymember by provider login
      ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      clear_customer   ${PUSERNAME0}

      ${decrypted_data}=  db.decrypt_data  ${resp.content}
      Log  ${decrypted_data}
      Set Test Variable  ${pid}  ${decrypted_data['id']}

      # Set Test Variable  ${pid}  ${resp.json()['id']}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${ph2}=  Evaluate  ${PUSERNAME0}+76003
      Set Suite Variable  ${ph2}
      Set Suite Variable  ${email2}  ${firstname}${ph2}${C_Email}.${test_mail}
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${CUSERNAME18}  ${EMPTY}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${pcid}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph2}${\n}
      ${firstname1}=  FakerLibrary.first_name
      Set Suite Variable  ${firstname1}
      ${lastname1}=  FakerLibrary.last_name
      Set Suite Variable  ${lastname1}
      ${dob1}=  FakerLibrary.Date
      Set Suite Variable  ${dob1}
      ${gender1}=  Random Element    ${Genderlist}
      Set Suite Variable  ${gender1}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+300000

      ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${pcid}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  ${Familymember_ph}
      Log  ${resp.json()}
      Set Suite Variable  ${mem_id0}  ${resp.json()}
      ${resp}=  ListFamilyMemberByProvider  ${pcid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Verify Response List  ${resp}  0  id=${mem_id0}   
      Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname1}
      Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname1}
      Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob1}
      Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender1}

      ${resp}=  ListFamilyMemberByProvider  ${pcid}
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-AddFamilyMemberOfProvidercustomer-2
      [Documentation]    Adding more family members
      ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+300001
      ${resp}=  AddFamilyMemberByProviderWithPhoneNo   ${pcid}  ${firstname}  ${lastname}  ${dob}  ${gender}  ${Familymember_ph}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id}  ${resp.json()}
      ${resp}=  ListFamilyMemberByProvider  ${pcid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${len}
      Should Be Equal As Strings   ${len}   2
      Verify Response List  ${resp}  1  id=${mem_id}
      Should Be Equal As Strings  ${resp.json()[1]['firstName']}  ${firstname}
      Should Be Equal As Strings  ${resp.json()[1]['lastName']}  ${lastname}
      Should Be Equal As Strings  ${resp.json()[1]['dob']}  ${dob}
      Should Be Equal As Strings  ${resp.json()[1]['gender']}  ${gender}

      Verify Response List  ${resp}  0  id=${mem_id0}
      Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname1}
      Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname1}
      Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob1}
      Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender1}

JD-TC-AddFamilyMemberOfProvidercustomer-3
      [Documentation]    Adding a family member with  same phone number 
      ${Familymember_ph}=  Evaluate  ${PUSERNAME18}+200000
      ${resp}=  Encrypted Provider Login  ${PUSERNAME18}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      clear_customer   ${PUSERNAME18}

      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${ph2}=  Evaluate  ${PUSERNAME18}+76004
      Set Test Variable  ${email}  ${firstname}${ph2}${C_Email}.${test_mail}
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email}  ${gender}  ${dob}  ${PUSERNAME18}  ${EMPTY}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${pcid1}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph2}${\n}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME18}+300002
      Set Test Variable   ${Familymember_ph}
      ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${pcid1}  ${firstname}  ${lastname}  ${dob}  ${gender}  ${Familymember_ph}  
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id}  ${resp.json()}
      ${firstname1}=  FakerLibrary.first_name
      ${lastname1}=  FakerLibrary.last_name
      ${dob1}=  FakerLibrary.Date
      ${gender1}=  Random Element    ${Genderlist}
      # ${Familymember_ph}=  Evaluate  ${PUSERNAME18}+300003

      ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${pcid1}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  ${Familymember_ph}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id1}  ${resp.json()}
      ${resp}=  ListFamilyMemberByProvider  ${pcid1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${len}
      Should Be Equal As Strings   ${len}   2
      Verify Response List  ${resp}  0  id=${mem_id}
      Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
      Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
      Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
      Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}
      Verify Response List  ${resp}  1  id=${mem_id1}
      Should Be Equal As Strings  ${resp.json()[1]['firstName']}  ${firstname1}
      Should Be Equal As Strings  ${resp.json()[1]['lastName']}  ${lastname1}
      Should Be Equal As Strings  ${resp.json()[1]['dob']}  ${dob1}
      Should Be Equal As Strings  ${resp.json()[1]['gender']}  ${gender1}

     
JD-TC-AddFamilyMemberOfProvidercustomer-4
      [Documentation]   One familymember added by two providers
      ${Familymember_ph}=  Evaluate  ${PUSERNAME18}+200001
      ${resp}=  Encrypted Provider Login  ${PUSERNAME18}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${firstname}=  FakerLibrary.first_name
      Set Test Variable  ${firstname}
      ${lastname}=  FakerLibrary.last_name
      Set Test Variable  ${lastname}
      ${dob}=  FakerLibrary.Date
      Set Test Variable  ${dob}
      ${gender}=  Random Element    ${Genderlist}
      Set Test Variable  ${gender}
      Set Test Variable  ${email}  ${firstname}${PUSERNAME18}${C_Email}.${test_mail}
      ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${pcid1}  ${firstname}  ${lastname}  ${dob}  ${gender}  ${Familymember_ph}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ProviderLogout
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email}  ${gender}  ${dob}  ${PUSERNAME2}  ${EMPTY}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${pcid2}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME0}${\n}
      ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${pcid2}  ${firstname}  ${lastname}  ${dob}   ${gender}  ${Familymember_ph}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id}  ${resp.json()}
      ${resp}=  ListFamilyMemberByProvider  ${pcid2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Verify Response List  ${resp}  0  id=${mem_id}
      Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
      Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
      Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
      Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}


JD-TC-AddFamilyMemberOfProvidercustomer-5
      [Documentation]   One familymember added by one provider and consumer
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+200002
      ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+300004

      ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${pcid}  ${firstname}  ${lastname}  ${dob}  ${gender}  ${Familymember_ph}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id}  ${resp.json()}
      ${resp}=  ListFamilyMemberByProvider  ${pcid}
      Log  ${resp.json()}
      Verify Response List  ${resp}  2  id=${mem_id}
      Should Be Equal As Strings  ${resp.json()[2]['firstName']}  ${firstname}
      Should Be Equal As Strings  ${resp.json()[2]['lastName']}  ${lastname}
      Should Be Equal As Strings  ${resp.json()[2]['dob']}  ${dob}
      Should Be Equal As Strings  ${resp.json()[2]['gender']}  ${gender}
      ${resp}=  Consumer Login  ${CUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  AddFamilyMemberWithPhNo   ${firstname}  ${lastname}  ${Familymember_ph}  ${dob}  ${gender}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id1}  ${resp.json()}
      ${resp}=  ListFamilyMember  
      Log   ${resp.json()}
      Verify Response List  ${resp}  0  user=${mem_id1}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['firstName']}  ${firstname}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['lastName']}  ${lastname}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['dob']}  ${dob}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['gender']}  ${gender}

     
JD-TC-AddFamilyMemberOfProvidercustomer-6
      [Documentation]    Adding customer and add 2 familymembers , after if the consumer signup ,familymembers are list there.
      ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${decrypted_data}=  db.decrypt_data  ${resp.content}
      Log  ${decrypted_data}
      Set Test Variable  ${p_id}  ${decrypted_data['id']}

      # Set Test Variable  ${p_id}  ${resp.json()['id']}
      ${firstname}=  FakerLibrary.first_name
      Set Test Variable  ${firstname}
      ${lastname}=  FakerLibrary.last_name
      Set Test Variable  ${lastname}
      ${ph3}=  Evaluate  ${PUSERNAME0}+76005
      Set Test Variable  ${email3}  ${firstname}${ph3}${C_Email}.${test_mail}
      ${dob}=  FakerLibrary.Date
      Set Test Variable  ${dob}
      ${gender}=  Random Element    ${Genderlist}
      Set Test Variable  ${gender}
      ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email3}  ${gender}  ${dob}   ${ph3}  ${EMPTY}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${pcid3}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph3}${\n}
      ${firstname1}=  FakerLibrary.first_name
      ${lastname1}=  FakerLibrary.last_name
      ${dob1}=  FakerLibrary.Date
      ${gender1}=  Random Element    ${Genderlist}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+300005

      ${resp}=  AddFamilyMemberByProviderWithPhoneNo   ${pcid3}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  ${Familymember_ph}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id1}  ${resp.json()}
      ${firstname2}=  FakerLibrary.first_name
      ${lastname2}=  FakerLibrary.last_name
      ${dob2}=  FakerLibrary.Date
      ${gender2}=  Random Element    ${Genderlist}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+300005

      ${resp}=  AddFamilyMemberByProviderWithPhoneNo   ${pcid3}  ${firstname2}  ${lastname2}  ${dob2}  ${gender2}   ${Familymember_ph}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id2}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph3}${\n}
      ${address}=  FakerLibrary.Address
      ${alternativeNo}=  Evaluate  ${PUSERNAME0}+73006
      ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${ph3}    ${alternativeNo}  ${dob}  ${gender}  ${EMPTY}
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Activation  ${ph3}  1
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Set Credential  ${ph3}  ${PASSWORD}  1
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Login   ${ph3}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMember
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      # Should Be Equal As Strings   ${resp.json()}   []
      Should Not Be Empty    ${resp.json()}
      # ${len}=  Get Length  ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Log  ${len}
      # Should Be Equal As Strings   ${len}   2
      # Verify Response List  ${resp}  0  user=${mem_id2}
      # Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname2}
      # Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname2}
      # Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob2}
      # Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender2}
      # Verify Response List  ${resp}  1  user=${mem_id1}
      # Should Be Equal As Strings  ${resp.json()[1]['firstName']}  ${firstname1}
      # Should Be Equal As Strings  ${resp.json()[1]['lastName']}  ${lastname1}
      # Should Be Equal As Strings  ${resp.json()[1]['dob']}  ${dob1}
      # Should Be Equal As Strings  ${resp.json()[1]['gender']}  ${gender1}

      ${resp}=  ProviderLogout
      Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-AddFamilyMemberOfProvidercustomer-7
      [Documentation]    Adding a customer and add two family members with two different providers ,in this case one family member is common and if the consumer sign up,then  the list of family members should not be duplicated.
      ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${decrypted_data}=  db.decrypt_data  ${resp.content}
      Log  ${decrypted_data}
      Set Test Variable  ${p_id}  ${decrypted_data['id']}

      # Set Test Variable  ${p_id}  ${resp.json()['id']}
      ${firstname}=  FakerLibrary.first_name
      Set Test Variable  ${firstname}
      ${lastname}=  FakerLibrary.last_name
      Set Test Variable  ${lastname}
      ${ph4}=  Evaluate  ${PUSERNAME0}+76007
      Set Test Variable  ${email4}  ${firstname}${ph4}${C_Email}.${test_mail}
      ${dob}=  FakerLibrary.Date
      Set Test Variable  ${dob}
      ${gender}=  Random Element    ${Genderlist}
      Set Test Variable  ${gender}
      ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email4}  ${gender}  ${dob}  ${ph4}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${pcid4}  ${resp.json()}
      Log  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph4}${\n}
      ${firstname1}=  FakerLibrary.first_name
      Set Test Variable  ${firstname1}
      ${lastname1}=  FakerLibrary.last_name
      Set Test Variable  ${lastname1}
      ${dob1}=  FakerLibrary.Date
      Set Test Variable  ${dob1}
      ${gender1}=  Random Element    ${Genderlist}
      Set Test Variable  ${gender1}
      ${Familymember_ph1}=  Evaluate  ${PUSERNAME0}+300006
      Set Test Variable  ${Familymember_ph1}
      ${resp}=  AddFamilyMemberByProviderWithPhoneNo   ${pcid4}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  ${Familymember_ph1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id1}  ${resp.json()}
      ${firstname2}=  FakerLibrary.first_name
      ${lastname2}=  FakerLibrary.last_name
      ${dob2}=  FakerLibrary.Date
      ${gender2}=  Random Element    ${Genderlist}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+300006

      ${resp}=  AddFamilyMemberByProviderWithPhoneNo     ${pcid4}    ${firstname2}  ${lastname2}  ${dob2}  ${gender2}   ${Familymember_ph}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id2}  ${resp.json()}
      ${resp}=  ProviderLogout
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}  ${gender}  ${dob}  ${ph4}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${pcid5}  ${resp.json()}
      Log  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph4}${\n}
      # ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+300008

      ${resp}=  AddFamilyMemberByProviderWithPhoneNo   ${pcid5}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}   ${Familymember_ph1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id3}  ${resp.json()}
      ${firstname3}=  FakerLibrary.first_name
      ${lastname3}=  FakerLibrary.last_name
      ${dob3}=  FakerLibrary.Date
      ${gender3}=  Random Element    ${Genderlist}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+300009

      ${resp}=  AddFamilyMemberByProviderWithPhoneNo   ${pcid5}   ${firstname3}  ${lastname3}  ${dob3}  ${gender3}   ${Familymember_ph}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Set Test Variable  ${mem_id4}  ${resp.json()}
      ${address}=  FakerLibrary.Address
      ${alternativeNo}=  Evaluate  ${PUSERNAME0}+76008
      ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${ph4}   ${alternativeNo}  ${dob}  ${Genderlist[0]}   ${EMPTY}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Activation  ${ph4}  1
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Set Credential  ${ph4}  ${PASSWORD}  1
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Login  ${ph4}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMember  
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings   ${resp.json()}   []
      # ${len}=  Get Length  ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Log  ${len}
      # Should Be Equal As Strings   ${len}   3
      # Verify Response List  ${resp}  0  user=${mem_id4}
      # Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname3}
      # Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname3}
      # Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob3}
      # Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender3}
      # Verify Response List  ${resp}  1  user=${mem_id2}
      # Should Be Equal As Strings  ${resp.json()[1]['firstName']}  ${firstname2}
      # Should Be Equal As Strings  ${resp.json()[1]['lastName']}  ${lastname2}
      # Should Be Equal As Strings  ${resp.json()[1]['dob']}  ${dob2}
      # Should Be Equal As Strings  ${resp.json()[1]['gender']}  ${gender2}

      # Verify Response List  ${resp}  2  user=${mem_id1}
      # Should Be Equal As Strings  ${resp.json()[2]['firstName']}  ${firstname1}
      # Should Be Equal As Strings  ${resp.json()[2]['lastName']}  ${lastname1}
      # Should Be Equal As Strings  ${resp.json()[2]['dob']}  ${dob1}
      # Should Be Equal As Strings  ${resp.json()[2]['gender']}  ${gender1}

      # Should Not Contain   ${resp}  3  user=${mem_id3}
      ${resp}=  ProviderLogout
      Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-AddFamilyMemberOfProvidercustomer-8
      [Documentation]    Adding a customer and add two family members with two different providers and list family member
      ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${decrypted_data}=  db.decrypt_data  ${resp.content}
      Log  ${decrypted_data}
      Set Test Variable  ${p_id}  ${decrypted_data['id']}

      # Set Test Variable  ${p_id}  ${resp.json()['id']}
      ${firstname}=  FakerLibrary.first_name
      Set Test Variable  ${firstname}
      ${lastname}=  FakerLibrary.last_name
      Set Test Variable  ${lastname}
      ${ph4}=  Evaluate  ${PUSERNAME0}+77001
      Set Test Variable  ${email4}  ${firstname}${ph4}${C_Email}.${test_mail}
      ${dob}=  FakerLibrary.Date
      Set Test Variable  ${dob}
      ${gender}=  Random Element    ${Genderlist}
      Set Test Variable  ${gender}
      ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email4}  ${gender}  ${dob}  ${ph4}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${pcid44}  ${resp.json()}
      Log  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph4}${\n}
      ${firstname1}=  FakerLibrary.first_name
      ${lastname1}=  FakerLibrary.last_name
      ${dob1}=  FakerLibrary.Date
      ${gender1}=  Random Element    ${Genderlist}
      ${Familymember_ph1}=  Evaluate  ${PUSERNAME0}+300066
      ${resp}=  AddFamilyMemberByProviderWithPhoneNo   ${pcid44}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  ${Familymember_ph1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id1}  ${resp.json()}
      ${firstname2}=  FakerLibrary.first_name
      ${lastname2}=  FakerLibrary.last_name
      ${dob2}=  FakerLibrary.Date
      ${gender2}=  Random Element    ${Genderlist}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+300066
      ${resp}=  AddFamilyMemberByProviderWithPhoneNo     ${pcid44}    ${firstname2}  ${lastname2}  ${dob2}  ${gender2}   ${Familymember_ph}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id2}  ${resp.json()}
      ${resp}=  ProviderLogout
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}  ${gender}  ${dob}  ${ph4}  ${EMPTY}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${pcid55}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph4}${\n}
      ${firstname3}=  FakerLibrary.first_name
      ${lastname3}=  FakerLibrary.last_name
      ${dob3}=  FakerLibrary.Date
      ${gender3}=  Random Element    ${Genderlist}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+300067
      ${resp}=  AddFamilyMemberByProviderWithPhoneNo   ${pcid55}  ${firstname3}  ${lastname3}  ${dob3}  ${gender3}   ${Familymember_ph1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id3}  ${resp.json()}
      ${firstname4}=  FakerLibrary.first_name
      ${lastname4}=  FakerLibrary.last_name
      ${dob4}=  FakerLibrary.Date
      ${gender4}=  Random Element    ${Genderlist}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+300009

      ${resp}=  AddFamilyMemberByProviderWithPhoneNo   ${pcid55}   ${firstname4}  ${lastname4}  ${dob4}  ${gender4}   ${Familymember_ph}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Set Test Variable  ${mem_id4}  ${resp.json()}
      # Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph3}${\n}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMemberByProvider  ${pcid55}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${len}
      Should Be Equal As Strings   ${len}   2
      Verify Response List  ${resp}  0  id=${mem_id3}
      Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname3}
      Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname3}
      Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob3}
      Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender3}
      Verify Response List  ${resp}  1  id=${mem_id4}
      Should Be Equal As Strings  ${resp.json()[1]['firstName']}  ${firstname4}
      Should Be Equal As Strings  ${resp.json()[1]['lastName']}  ${lastname4}
      Should Be Equal As Strings  ${resp.json()[1]['dob']}  ${dob4}
      Should Be Equal As Strings  ${resp.json()[1]['gender']}  ${gender4}
      ${resp}=  ProviderLogout
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMemberByProvider  ${pcid44}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${len}
      Should Be Equal As Strings   ${len}   2
      Verify Response List  ${resp}  0  id=${mem_id1}
      Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname1}
      Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname1}
      Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob1}
      Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender1}
      Verify Response List  ${resp}  1  id=${mem_id2}
      Should Be Equal As Strings  ${resp.json()[1]['firstName']}  ${firstname2}
      Should Be Equal As Strings  ${resp.json()[1]['lastName']}  ${lastname2}
      Should Be Equal As Strings  ${resp.json()[1]['dob']}  ${dob2}
      Should Be Equal As Strings  ${resp.json()[1]['gender']}  ${gender2}

JD-TC-AddFamilyMemberOfProvidercustomer-9
      [Documentation]    Adding a customer and add same family members with two different providers and list family member
      ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${decrypted_data}=  db.decrypt_data  ${resp.content}
      Log  ${decrypted_data}
      Set Test Variable  ${p_id}  ${decrypted_data['id']}

      # Set Test Variable  ${p_id}  ${resp.json()['id']}
      # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}
      # Log   ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Set Test Variable  ${cid}  ${resp.json()[0]['id']}
      ${resp}=  AddCustomer  ${CUSERNAME10}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}  ${resp.json()}
      ${firstname0}=  FakerLibrary.first_name
      Set Test Variable   ${firstname0}
      ${lastname0}=  FakerLibrary.last_name
      ${dob0}=  FakerLibrary.Date
      ${gender0}=  Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProvider  ${cid}  ${firstname0}  ${lastname0}  ${dob0}  ${gender0}  
      Log  ${resp.json()}
      Set Test Variable  ${mem_id0}  ${resp.json()}
      ${firstname1}=  FakerLibrary.first_name
      ${lastname1}=  FakerLibrary.last_name
      ${dob1}=  FakerLibrary.Date
      ${gender1}=  Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProvider    ${cid}   ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  
      Log  ${resp.json()}
      Set Test Variable  ${mem_id1}  ${resp.json()}
      ${resp}=  ProviderLogout
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}
      # Log   ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
      ${resp}=  AddCustomer  ${CUSERNAME10}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid1}  ${resp.json()}

      ${resp}=  AddFamilyMemberByProvider  ${cid1}  ${firstname0}  ${lastname0}  ${dob0}  ${gender0}  
      Log  ${resp.json()}
      Set Test Variable  ${mem_id2}  ${resp.json()}

      ${resp}=  AddFamilyMemberByProvider    ${cid1}   ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  
      Log  ${resp.json()}
      Set Test Variable  ${mem_id3}  ${resp.json()}

      ${resp}=  ListFamilyMemberByProvider  ${cid1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${len}
      Should Be Equal As Strings   ${len}   2
      Verify Response List  ${resp}  0  id=${mem_id2}
      Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname0}
      Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname0}
      Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob0}
      Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender0}
      Verify Response List  ${resp}  1  id=${mem_id3}
      Should Be Equal As Strings  ${resp.json()[1]['firstName']}  ${firstname1}
      Should Be Equal As Strings  ${resp.json()[1]['lastName']}  ${lastname1}
      Should Be Equal As Strings  ${resp.json()[1]['dob']}  ${dob1}
      Should Be Equal As Strings  ${resp.json()[1]['gender']}  ${gender1}
      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMemberByProvider  ${cid}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${len}
      Should Be Equal As Strings   ${len}   2
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
      

JD-TC-AddFamilyMemberOfProvidercustomer-10
      [Documentation]    Adding a customer and add two family members with one provider and add to waitlist  and list family member
      ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      clear_location  ${PUSERNAME0}
      clear_queue  ${PUSERNAME0}
      # clear_customer   ${PUSERNAME0}
      ${resp}=   ProviderKeywords.Get Queues
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp} =  Create Sample Queue
      Set Test Variable  ${s_id}  ${resp['service_id']}
      Set Test Variable  ${qid}   ${resp['queue_id']}
      Set Suite Variable   ${lid}   ${resp['location_id']}

      ${resp}=   Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['timezone']}

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
      ${firstname1}=  FakerLibrary.first_name
      ${lastname1}=  FakerLibrary.last_name
      ${dob1}=  FakerLibrary.Date
      ${gender1}=  Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProvider    ${cid}   ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  
      Log  ${resp.json()}
      Set Test Variable  ${mem_id1}  ${resp.json()}
      ${DAY}=  db.get_date_by_timezone  ${tz}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${qid}  ${DAY}  ${desc}  ${bool[1]}  ${mem_id1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[1]}
      ${resp}=  ListFamilyMemberByProvider  ${c_id1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
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


JD-TC-AddFamilyMemberOfProvidercustomer-UH1
      [Documentation]  Add a family member without login
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+300009

      ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${pcid}  ${firstname}  ${lastname}  ${dob}  ${gender}  ${Familymember_ph}
      Should Be Equal As Strings   ${resp.status_code}  419
      Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"


JD-TC-AddFamilyMemberOfProvidercustomer-UH2
      [Documentation]    Adding a family member with  same name 
      ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${ph5}=  Evaluate  ${PUSERNAME0}+76009
      Set Test Variable  ${email5}  ${firstname}${ph5}${C_Email}.${test_mail}
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email5}  ${gender}  ${dob}   ${ph5}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${pcid6}  ${resp.json()}
      Log  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph5}${\n}
      ${firstname4}=  FakerLibrary.first_name
      Set Test Variable  ${firstname4}
      ${lastname4}=  FakerLibrary.last_name
      Set Test Variable  ${lastname4}
      ${dob4}=  FakerLibrary.Date
      Set Test Variable  ${dob4}
      ${gender4}=  Random Element    ${Genderlist}
      Set Test Variable  ${gender}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+300019

      ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${pcid6}  ${firstname4}  ${lastname4}  ${dob4}  ${gender4}   ${Familymember_ph}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id}  ${resp.json()}
      ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${pcid6}  ${firstname4}  ${lastname4}  ${dob4}  ${gender4}   ${Familymember_ph}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${FAMILY_MEMBEBR_NAME_SAME}"

JD-TC-AddFamilyMemberOfProvidercustomer-UH3
      [Documentation]    Adding a family member with existing family member details and using a jaldee consumer
      ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${firstname}=  FakerLibrary.first_name
      Set Test Variable  ${firstname}
      ${lastname}=  FakerLibrary.last_name
      Set Test Variable  ${lastname}
      ${dob}=  FakerLibrary.Date
      Set Test Variable  ${dob}
      ${gender}=  Random Element    ${Genderlist}
      Set Test Variable  ${gender}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+300018

      ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${pcid}  ${firstname}  ${lastname}  ${dob}  ${gender}  ${Familymember_ph}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${pcid}  ${firstname}  ${lastname}  ${dob}  ${gender}   ${Familymember_ph}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${FAMILY_MEMBEBR_NAME_SAME}"
      
JD-TC-AddFamilyMemberOfProvidercustomer-UH4
      [Documentation]    Adding a customer and add two family members  and another provider traying to list these family member
      ${resp}=  Encrypted Provider Login  ${PUSERNAME177}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      clear_location  ${PUSERNAME177}
      clear_queue  ${PUSERNAME177}
      clear waitlist   ${PUSERNAME177}
      clear_customer   ${PUSERNAME177}
      ${resp}=   ProviderKeywords.Get Queues
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Create Sample Queue
      Set Suite Variable  ${s_id}  ${resp['service_id']}
      Set Suite Variable  ${qid}   ${resp['queue_id']}
      Set Suite Variable   ${lid}   ${resp['location_id']}

      ${resp}=   Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['timezone']}
      # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
      # Log   ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Set Test Variable  ${c_id}  ${resp.json()[0]['id']}
      ${resp}=  AddCustomer  ${CUSERNAME3}
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
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      clear_location  ${PUSERNAME1}
      clear_queue  ${PUSERNAME1}
      clear_customer   ${PUSERNAME1}

      ${resp}=   ProviderKeywords.Get Queues
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${resp} =  Create Sample Queue
      Set Test Variable  ${s_id}  ${resp['service_id']}
      Set Test Variable  ${qid}   ${resp['queue_id']}
      Set Suite Variable   ${lid}   ${resp['location_id']}

      ${resp}=   Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['timezone']}

      # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
      # Log   ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Set Test Variable  ${c_id1}  ${resp.json()[0]['id']}
      ${resp}=  AddCustomer  ${CUSERNAME3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${c_id1}  ${resp.json()}
      ${resp}=  ListFamilyMemberByProvider  ${c_id1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings   ${resp.json()}   []
      ${DAY}=  db.get_date_by_timezone  ${tz}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${c_id1}  ${s_id}  ${qid}  ${DAY}  ${desc}  ${bool[1]}  ${mem_id0}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  404
      Should Be Equal As Strings  "${resp.json()}"   "${NOT_A_Familiy_Member}"
      # Should Be Equal As Strings  ${resp.status_code}  401
      # Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION}"
      
     
JD-TC-AddFamilyMemberOfProvidercustomer-11
      [Documentation]    Adding a customer and add a family member and jaldee integraton is false
      ${resp}=  Encrypted Provider Login  ${PUSERNAME177}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
       
      ${resp}=  AddCustomer  ${CUSERNAME4}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}  ${resp.json()}

      # ${resp}=  Get Consumer By Id  ${CUSERNAME4}
      # Log   ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
      Log   ${resp.json()}
      Should Be Equal As Strings      ${resp.status_code}  200
     
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProvider  ${cid}  ${firstname}  ${lastname}  ${dob}  ${gender}  
      Log  ${resp.json()}
      Set Test Variable  ${fid}  ${resp.json()}

      ${DAY}=  db.get_date_by_timezone  ${tz}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${qid}  ${DAY}  ${desc}  ${bool[1]}  ${fid}   
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[1]}
      ${resp}=  ListFamilyMemberByProvider  ${c_id1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response List  ${resp}  0  id=${fid}
      Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
      Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
      Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
      Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}

JD-TC-AddFamilyMemberOfProvidercustomer-12
      [Documentation]    Adding a customer and add a family members  jaldee integraton is true
      ${resp}=  Encrypted Provider Login  ${PUSERNAME177}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
       
      ${resp}=  Set jaldeeIntegration Settings    ${boolean[0]}  ${boolean[1]}  ${boolean[0]}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get jaldeeIntegration Settings
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME5}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}  ${resp.json()}

      # ${resp}=  Get Consumer By Id  ${CUSERNAME5}
      # Log   ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      
      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
      Log   ${resp.json()}
      Should Be Equal As Strings      ${resp.status_code}  200
     
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProvider  ${cid}  ${firstname}  ${lastname}  ${dob}  ${gender}  
      Log  ${resp.json()}
      Set Test Variable  ${fid}  ${resp.json()}

      ${DAY}=  db.get_date_by_timezone  ${tz}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${qid}  ${DAY}  ${desc}  ${bool[1]}  ${fid}   
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[1]}
      ${resp}=  ListFamilyMemberByProvider  ${c_id1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response List  ${resp}  0  id=${fid}
      Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
      Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
      Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
      Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}

      ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-AddFamilyMemberOfProvidercustomer-13
      [Documentation]    Add two family members from provider side.then check this family members from provider consumer login.

      ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${decrypted_data}=  db.decrypt_data  ${resp.content}
      Log  ${decrypted_data}
      Set Test Variable  ${p_id}  ${decrypted_data['id']}

       # Set Test Variable  ${p_id}  ${resp.json()['id']}
      ${firstname}=  FakerLibrary.first_name
      Set Test Variable  ${firstname}
      ${lastname}=  FakerLibrary.last_name
      Set Test Variable  ${lastname}
      ${ph3}=  Evaluate  ${PUSERNAME0}+77605
      Set Test Variable  ${email3}  ${firstname}${ph3}${C_Email}.${test_mail}
      ${dob}=  FakerLibrary.Date
      Set Test Variable  ${dob}
      ${gender}=  Random Element    ${Genderlist}
      Set Test Variable  ${gender}
      ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email3}  ${gender}  ${dob}   ${ph3}  ${EMPTY}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${pcid3}  ${resp.json()}
      
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph3}${\n}
      ${firstname1}=  FakerLibrary.first_name
      ${lastname1}=  FakerLibrary.last_name
      ${dob1}=  FakerLibrary.Date
      ${gender1}=  Random Element    ${Genderlist}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+340005

      ${resp}=  AddFamilyMemberByProviderWithPhoneNo   ${pcid3}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  ${Familymember_ph}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id1}  ${resp.json()}
      ${firstname2}=  FakerLibrary.first_name
      ${lastname2}=  FakerLibrary.last_name
      ${dob2}=  FakerLibrary.Date
      ${gender2}=  Random Element    ${Genderlist}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+305005

      ${resp}=  AddFamilyMemberByProviderWithPhoneNo   ${pcid3}  ${firstname2}  ${lastname2}  ${dob2}  ${gender2}   ${Familymember_ph}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id2}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph3}${\n}
      ${resp}=    Send Otp For Login    ${ph3}    ${p_id}
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${resp}=    Verify Otp For Login   ${ph3}   ${OtpPurpose['Authentication']}
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200
      Set Suite Variable  ${token}  ${resp.json()['token']}

      ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email3}    ${ph3}     ${p_id}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${resp}=    Customer Logout
      Log  ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=    ProviderConsumer Login with token   ${ph3}    ${p_id}  ${token} 
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200 
      Set Test Variable    ${pcid3}    ${resp.json()['providerConsumer']}

      ${resp}=    Get FamilyMember
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  ListFamilyMember
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200  
      
      # Should Be Equal As Strings   ${resp.json()}   []
      Should Not Be Empty    ${resp.json()}
      # ${len}=  Get Length  ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Log  ${len}
      # Should Be Equal As Strings   ${len}   2
      # Verify Response List  ${resp}  0  user=${mem_id2}
      # Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname2}
      # Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname2}
      # Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob2}
      # Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender2}
      # Verify Response List  ${resp}  1  user=${mem_id1}
      # Should Be Equal As Strings  ${resp.json()[1]['firstName']}  ${firstname1}
      # Should Be Equal As Strings  ${resp.json()[1]['lastName']}  ${lastname1}
      # Should Be Equal As Strings  ${resp.json()[1]['dob']}  ${dob1}
      # Should Be Equal As Strings  ${resp.json()[1]['gender']}  ${gender1}

JD-TC-AddFamilyMemberOfProvidercustomer-14
      [Documentation]    Adding customer and add 2 familymembers , after if the consumer signup ,again adding the same family members and check the provider consumer ids.
      ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${decrypted_data}=  db.decrypt_data  ${resp.content}
      Log  ${decrypted_data}
      Set Test Variable  ${p_id}  ${decrypted_data['id']}

      # Set Test Variable  ${p_id}  ${resp.json()['id']}
      ${firstname}=  FakerLibrary.first_name
      Set Test Variable  ${firstname}
      ${lastname}=  FakerLibrary.last_name
      Set Test Variable  ${lastname}
      ${ph3}=  Evaluate  ${PUSERNAME0}+76605
      Set Test Variable  ${email3}  ${firstname}${ph3}${C_Email}.${test_mail}
      ${dob}=  FakerLibrary.Date
      Set Test Variable  ${dob}
      ${gender}=  Random Element    ${Genderlist}
      Set Test Variable  ${gender}
      ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email3}  ${gender}  ${dob}   ${ph3}  ${EMPTY}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${pcid3}  ${resp.json()}
      
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph3}${\n}
      ${firstname1}=  FakerLibrary.first_name
      ${lastname1}=  FakerLibrary.last_name
      ${dob1}=  FakerLibrary.Date
      ${gender1}=  Random Element    ${Genderlist}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+340005

      ${resp}=  AddFamilyMemberByProviderWithPhoneNo   ${pcid3}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  ${Familymember_ph}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id1}  ${resp.json()}
      ${firstname2}=  FakerLibrary.first_name
      ${lastname2}=  FakerLibrary.last_name
      ${dob2}=  FakerLibrary.Date
      ${gender2}=  Random Element    ${Genderlist}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+300005

      ${resp}=  AddFamilyMemberByProviderWithPhoneNo   ${pcid3}  ${firstname2}  ${lastname2}  ${dob2}  ${gender2}   ${Familymember_ph}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id2}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph3}${\n}
      ${address}=  FakerLibrary.Address
      ${alternativeNo}=  Evaluate  ${PUSERNAME0}+73006
      ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${ph3}    ${alternativeNo}  ${dob}  ${gender}  ${EMPTY}
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Activation  ${ph3}  1
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Set Credential  ${ph3}  ${PASSWORD}  1
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Login   ${ph3}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMember
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings   ${resp.json()}   []

      ${resp}=  Add FamilyMember For ProviderConsumer     ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  ${Familymember_ph}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id4}  ${resp.json()}
      ${firstname2}=  FakerLibrary.first_name
      ${lastname2}=  FakerLibrary.last_name
      ${dob2}=  FakerLibrary.Date
      ${gender2}=  Random Element    ${Genderlist}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+300005

      ${resp}=  Add FamilyMember For ProviderConsumer     ${firstname2}  ${lastname2}  ${dob2}  ${gender2}   ${Familymember_ph}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id5}  ${resp.json()}

      Should Be Equal   ${mem_id1}  ${mem_id4}
      Should Be Equal   ${mem_id2}  ${mem_id5}


      ${resp}=  ProviderLogout
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-AddFamilyMemberOfProvidercustomer-15
      [Documentation]    Add two family members from provider side and took one appointment for one of the family member.then check this family members from provider consumer login.

      ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${decrypted_data}=  db.decrypt_data  ${resp.content}
      Log  ${decrypted_data}
      Set Test Variable  ${p_id}  ${decrypted_data['id']}

       # Set Test Variable  ${p_id}  ${resp.json()['id']}
      ${firstname}=  FakerLibrary.first_name
      Set Test Variable  ${firstname}
      ${lastname}=  FakerLibrary.last_name
      Set Test Variable  ${lastname}
      ${ph3}=  Evaluate  ${PUSERNAME0}+77606
      Set Test Variable  ${email3}  ${firstname}${ph3}${C_Email}.${test_mail}
      ${dob}=  FakerLibrary.Date
      Set Test Variable  ${dob}
      ${gender}=  Random Element    ${Genderlist}
      Set Test Variable  ${gender}
      ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email3}  ${gender}  ${dob}   ${ph3}  ${EMPTY}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${pcid3}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph3}${\n}
      ${firstname1}=  FakerLibrary.first_name
      ${lastname1}=  FakerLibrary.last_name
      ${dob1}=  FakerLibrary.Date
      ${gender1}=  Random Element    ${Genderlist}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+340007

      ${resp}=  AddFamilyMemberByProviderWithPhoneNo   ${pcid3}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  ${Familymember_ph}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id1}  ${resp.json()}
      ${firstname2}=  FakerLibrary.first_name
      ${lastname2}=  FakerLibrary.last_name
      ${dob2}=  FakerLibrary.Date
      ${gender2}=  Random Element    ${Genderlist}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+305008

      ${resp}=  AddFamilyMemberByProviderWithPhoneNo   ${pcid3}  ${firstname2}  ${lastname2}  ${dob2}  ${gender2}   ${Familymember_ph}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id2}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph3}${\n}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid}=  Create Sample Location  
    Set Suite Variable  ${lid}
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    clear_appt_schedule   ${PUSERNAME0}

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${servicecharge}=  Convert To Number  ${servicecharge}  1 
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}


    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${tot_amt}   ${resp.json()['totalAmount']}


    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}   ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${apptfor1}=  Create Dictionary  id=${mem_id2}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${mem_id2}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[1]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=    Send Otp For Login    ${ph3}    ${p_id}
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${resp}=    Verify Otp For Login   ${ph3}   ${OtpPurpose['Authentication']}
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200
      Set Suite Variable  ${token}  ${resp.json()['token']}

      ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email3}    ${ph3}     ${p_id}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${resp}=    Customer Logout
      Log  ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=    ProviderConsumer Login with token   ${ph3}    ${p_id}  ${token} 
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200 
      Set Test Variable    ${pcid3}    ${resp.json()['providerConsumer']}

      ${resp}=    Get FamilyMember
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  ListFamilyMember
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      # Should Be Equal As Strings   ${resp.json()}   []
      Should Not Be Empty    ${resp.json()}


JD-TC-AddFamilyMemberOfProvidercustomer-16
      [Documentation]    Add a familymember with title
      ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      clear_customer   ${PUSERNAME0}

      ${decrypted_data}=  db.decrypt_data  ${resp.content}
      Log  ${decrypted_data}
      Set Test Variable  ${pid}  ${decrypted_data['id']}

      # Set Test Variable  ${pid}  ${resp.json()['id']}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${ph2}=  Evaluate  ${PUSERNAME0}+76003
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${CUSERNAME18}  ${EMPTY}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${pcid}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph2}${\n}
      ${firstname1}=  FakerLibrary.first_name
      Set Suite Variable  ${firstname1}
      ${lastname1}=  FakerLibrary.last_name
      Set Suite Variable  ${lastname1}
      ${dob1}=  FakerLibrary.Date
      Set Suite Variable  ${dob1}
      ${gender1}=  Random Element    ${Genderlist}
      Set Suite Variable  ${gender1}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+300000

      ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${pcid}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  ${Familymember_ph}
      Log  ${resp.json()}
      Set Suite Variable  ${mem_id0}  ${resp.json()}
      ${resp}=  ListFamilyMemberByProvider  ${pcid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Verify Response List  ${resp}  0  id=${mem_id0}   
      Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname1}
      Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname1}
      Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob1}
      Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender1}


JD-TC-AddFamilyMemberOfProvidercustomer-17
      [Documentation]    Add a customer's family member with title.
      ${resp}=  Encrypted Provider Login  ${PUSERNAME177}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
            
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${cust_no}    FakerLibrary.Numerify   text=%######
      ${cust_no}=  Evaluate  ${CUSERNAME}+${cust_no}
      ${dob}=  FakerLibrary.Date
      ${address}=  FakerLibrary.address
      ${gender}=  Random Element    ${Genderlist}
      ${title}=  Random Element    ${customertitle}
      
      ${resp}=  AddCustomer  ${cust_no}   countryCode=${countryCodes[0]}  firstName=${firstname}   lastName=${lastname}  address=${address}   gender=${gender}  dob=${dob}  title=${title}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid1}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${cust_no}${\n}

      # ${resp}=  Get Consumer By Id  ${CUSERNAME4}
      # Log   ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
      Log   ${resp.json()}
      Should Be Equal As Strings      ${resp.status_code}  200
     
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProvider  ${cid}  ${firstname}  ${lastname}  ${dob}  ${gender}  
      Log  ${resp.json()}
      Set Test Variable  ${fid}  ${resp.json()}