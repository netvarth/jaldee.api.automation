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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 


*** Test Cases ***

JD-TC-UpdateFamilyMemberOfProvidercustomer-1
    [Documentation]    Update a familymember by provider login
    clear_customer   ${PUSERNAME1}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${resp}=  AddCustomer  ${CUSERNAME13}
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
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mem_id0}  ${resp.json()}
    ${firstname2}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname2}
    ${lastname2}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname2}
    ${resp}=  Update FamilymemberByprovidercustomer    ${cid}    ${mem_id0}  ${firstname2}  ${lastname2}  ${dob0}  ${gender0}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${mem_id0}  ${resp.json()}
    ${resp}=  ListFamilyMemberByProvider  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response List  ${resp}  0  id=${mem_id0}
    Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname2}
    Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname2}
    Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob0}
    Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender0}

JD-TC-UpdateFamilyMemberOfProvidercustomer-2
    [Documentation]    Adding more family members and update
    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider   ${cid}  ${firstname}  ${lastname}  ${dob}  ${gender}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id1}  ${resp.json()}
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    ${gender1}=  Random Element    ${Genderlist}
    ${resp}=  Update FamilymemberByprovidercustomer    ${cid}  ${mem_id1}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id1}  ${resp.json()}
    ${resp}=  ListFamilyMemberByProvider  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${len}
    Should Be Equal As Strings   ${len}   2
    Verify Response List  ${resp}  0  id=${mem_id0}
    Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname2}
    Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname2}
    Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob0}
    Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender0}

    Verify Response List  ${resp}  1  id=${mem_id1}
    Should Be Equal As Strings  ${resp.json()[1]['firstName']}  ${firstname1}
    Should Be Equal As Strings  ${resp.json()[1]['lastName']}  ${lastname1}
    Should Be Equal As Strings  ${resp.json()[1]['dob']}  ${dob1}
    Should Be Equal As Strings  ${resp.json()[1]['gender']}  ${gender1}

JD-TC-UpdateFamilyMemberOfProvidercustomer-3
    [Documentation]  Update a  familymember using name of another provider customer familymember
    
    clear_customer   ${PUSERNAME2}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider   ${cid1}  ${firstname}  ${lastname}  ${dob}  ${gender}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id2}  ${resp.json()}
    ${resp}=  Update FamilymemberByprovidercustomer   ${cid1}  ${mem_id2}  ${firstname2}  ${lastname2}  ${dob}  ${gender}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id2}  ${resp.json()}
    ${resp}=  ListFamilyMemberByProvider  ${cid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response List  ${resp}  0  id=${mem_id2}
    Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname2}
    Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname2}
    Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
    Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}

JD-TC-UpdateFamilyMemberOfProvidercustomer-UH1
    [Documentation]  Update a family member without login
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Update FamilymemberByprovidercustomer   ${cid}   ${mem_id0}  ${firstname2}  ${lastname2}  ${dob}  ${gender}    
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"    "${SESSION_EXPIRED}"

JD-TC-UpdateFamilyMemberOfProvidercustomer-UH2
    [Documentation]  Update a familymember using consumer login
    ${resp}=  ConsumerLogin  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${resp}=  Update FamilymemberByprovidercustomer   ${cid}   ${mem_id0}  ${firstname2}  ${lastname2}  ${dob}  ${gender}   
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-UpdateFamilyMemberOfProvidercustomer-UH3
	[Documentation]  A non parent updates a familymember
    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    ${gender1}=  Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider   ${cid1}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id3}  ${resp.json()}
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update FamilymemberByprovidercustomer  ${cid1}  ${mem_id3}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"    "${NO_PERMISSION}"