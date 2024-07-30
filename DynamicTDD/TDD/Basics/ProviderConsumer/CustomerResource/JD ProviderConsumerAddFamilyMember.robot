*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        ConsumerSignup
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***

${cc}                               +91

*** Test Cases ***

JD-TC-AddFamilyMembersForProviderConsumer-1
    
    [Documentation]  Add Family Member for Provider Consumer.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=    get_acc_id       ${PUSERNAME21}
    Set Suite Variable     ${accountId}

    ${gender}                     Random Element    ${Genderlist}                   
    ${dob}                        FakerLibrary.Date
    ${fname}                      FakerLibrary. name
    ${lname}                      FakerLibrary.last_name
    ${email}                      FakerLibrary.email
    ${city}                       FakerLibrary.city
    ${state}                      FakerLibrary.state
    ${address}                    FakerLibrary.address
    ${primnum}                    FakerLibrary.Numerify   text=%%%%%%%%%%
    ${altno}                      FakerLibrary.Numerify   text=%%%%%%%%%%
    ${numt}                       FakerLibrary.Numerify   text=%%%%%%%%%%
    ${numw}                       FakerLibrary.Numerify   text=%%%%%%%%%%

    Set Suite Variable      ${gender}
    Set Suite Variable      ${dob}
    Set Suite Variable      ${fname}
    Set Suite Variable      ${lname}
    Set Suite Variable      ${email}
    Set Suite Variable      ${city}
    Set Suite Variable      ${state}
    Set Suite Variable      ${address}
    Set Suite Variable      ${primnum}
    Set Suite Variable      ${altno}
    Set Suite Variable      ${numt}
    Set Suite Variable      ${numw}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp1}=  AddCustomer  ${CUSERNAME23}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable  ${pcid18}   ${resp1.json()}
   
    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=    Send Otp For Login    ${CUSERNAME23}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME23}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME23}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Get FamilyMember
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Family Members   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Family Member       ${fname}  ${lname}  ${dob}  ${gender}   ${primnum}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Suite Variable   ${memb_id}  ${resp.json()}

    ${resp}=    Get FamilyMember
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Family Members   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lname}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${primnum}
    Should Be Equal As Strings    ${resp.json()[0]['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[0]}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${fname}
    # Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${fname}
    # Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${fname}
    # Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${fname}

JD-TC-AddFamilyMembersForProviderConsumer-2
    
    [Documentation]  Add two more  Family Member with same number for Provider Consumer.
    
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME23}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get FamilyMember
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${fname1}                      FakerLibrary. name

    ${resp}=    Create Family Member       ${fname1}  ${lname}  ${dob}  ${gender}   ${primnum}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${fname2}                      FakerLibrary. name

    ${resp}=    Create Family Member       ${fname2}  ${lname}  ${dob}  ${gender}   ${primnum}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${fname3}                      FakerLibrary. name

    ${resp}=    Create Family Member       ${fname3}  ${lname}  ${dob}  ${gender}   ${primnum}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get FamilyMember
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${fname}
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lname}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${primnum}
    Should Be Equal As Strings    ${resp.json()[0]['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[0]}

    Should Be Equal As Strings    ${resp.json()[1]['firstName']}    ${fname1}
    Should Be Equal As Strings    ${resp.json()[1]['lastName']}    ${lname}
    Should Be Equal As Strings    ${resp.json()[1]['phoneNo']}    ${primnum}
    Should Be Equal As Strings    ${resp.json()[1]['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()[1]['countryCode']}    ${countryCodes[0]}

    Should Be Equal As Strings    ${resp.json()[2]['firstName']}    ${fname2}
    Should Be Equal As Strings    ${resp.json()[2]['lastName']}    ${lname}
    Should Be Equal As Strings    ${resp.json()[2]['phoneNo']}    ${primnum}
    Should Be Equal As Strings    ${resp.json()[2]['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()[2]['countryCode']}    ${countryCodes[0]}

    Should Be Equal As Strings    ${resp.json()[3]['firstName']}    ${fname3}
    Should Be Equal As Strings    ${resp.json()[3]['lastName']}    ${lname}
    Should Be Equal As Strings    ${resp.json()[3]['phoneNo']}    ${primnum}
    Should Be Equal As Strings    ${resp.json()[3]['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()[3]['countryCode']}    ${countryCodes[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ListFamilyMemberByProvider  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${fname}
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lname}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${primnum}
    Should Be Equal As Strings    ${resp.json()[0]['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[0]}

    Should Be Equal As Strings    ${resp.json()[1]['firstName']}    ${fname1}
    Should Be Equal As Strings    ${resp.json()[1]['lastName']}    ${lname}
    Should Be Equal As Strings    ${resp.json()[1]['phoneNo']}    ${primnum}
    Should Be Equal As Strings    ${resp.json()[1]['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()[1]['countryCode']}    ${countryCodes[0]}

    Should Be Equal As Strings    ${resp.json()[2]['firstName']}    ${fname2}
    Should Be Equal As Strings    ${resp.json()[2]['lastName']}    ${lname}
    Should Be Equal As Strings    ${resp.json()[2]['phoneNo']}    ${primnum}
    Should Be Equal As Strings    ${resp.json()[2]['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()[2]['countryCode']}    ${countryCodes[0]}

    Should Be Equal As Strings    ${resp.json()[3]['firstName']}    ${fname3}
    Should Be Equal As Strings    ${resp.json()[3]['lastName']}    ${lname}
    Should Be Equal As Strings    ${resp.json()[3]['phoneNo']}    ${primnum}
    Should Be Equal As Strings    ${resp.json()[3]['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()[3]['countryCode']}    ${countryCodes[0]}

JD-TC-AddFamilyMembersForProviderConsumer-3
    
    [Documentation]  Add a Family Member without number for Provider Consumer.
    
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME23}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${fname4}                      FakerLibrary. name

    ${resp}=    Create Family Member       ${fname4}  ${lname}  ${dob}  ${gender}   ${EMPTY}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get FamilyMember
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[4]['firstName']}    ${fname4}
    Should Be Equal As Strings    ${resp.json()[4]['lastName']}    ${lname}
    Should Be Equal As Strings    ${resp.json()[4]['phoneNo']}    ${CUSERNAME23}
    Should Be Equal As Strings    ${resp.json()[4]['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()[4]['countryCode']}    ${countryCodes[0]}

JD-TC-AddFamilyMembersForProviderConsumer-UH1
    
    [Documentation]  Add another Family Member Without Firstname.

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME23}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Get FamilyMember
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Family Member       ${EMPTY}  ${lname}  ${dob}  ${gender}   ${primnum}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${FAMILY_MEMBEBR_NAME_SAME}

JD-TC-AddFamilyMembersForProviderConsumer-UH2
    
    [Documentation]  Add another Family Member Without LastName.

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME23}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Get FamilyMember
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${fname1}                      FakerLibrary. name

    ${resp}=    Create Family Member       ${fname1}  ${EMPTY}  ${dob}  ${gender}   ${primnum}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${FAMILY_MEMBEBR_NAME_SAME}

JD-TC-AddFamilyMembersForProviderConsumer-UH3
    
    [Documentation]  Try to Add same Family Member.

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME23}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Get FamilyMember
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${fname1}                      FakerLibrary. name

    ${resp}=    Create Family Member       ${fname}  ${lname}  ${dob}  ${gender}   ${primnum}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${FAMILY_MEMBEBR_NAME_SAME}

JD-TC-AddFamilyMembersForProviderConsumer-UH4
    
    [Documentation]  Add another Family Member Without dob.

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME23}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get FamilyMember
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${fname1}                      FakerLibrary. name

    ${resp}=    Create Family Member       ${fname1}  ${lname}  ${EMPTY}  ${gender}   ${primnum}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${FAMILY_MEMBEBR_NAME_SAME}

JD-TC-AddFamilyMembersForProviderConsumer-UH5
    
    [Documentation]  Add another Family Member Without gender.

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME23}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get FamilyMember
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${fname1}                      FakerLibrary. name

    ${resp}=    Create Family Member       ${fname1}  ${lname}  ${dob}  ${EMPTY}   ${primnum}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${FAMILY_MEMBEBR_NAME_SAME}

JD-TC-AddFamilyMembersForProviderConsumer-UH6
    
    [Documentation]  Add another Family Member Without Number.

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME23}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get FamilyMember
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${fname1}                      FakerLibrary. name

    ${resp}=    Create Family Member       ${fname1}  ${lname}  ${dob}  ${gender}   ${EMPTY}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${FAMILY_MEMBEBR_NAME_SAME}

JD-TC-AddFamilyMembersForProviderConsumer-UH7
    
    [Documentation]  Add another Family Member Without countryCodes.

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME23}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get FamilyMember
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${fname1}                      FakerLibrary. name

    ${resp}=    Create Family Member       ${fname1}  ${lname}  ${dob}  ${gender}   ${primnum}  ${EMPTY}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${COUNTRY_CODEREQUIRED}

JD-TC-AddFamilyMembersForProviderConsumer-UH8
    
    [Documentation]  Add another Family Member Without address.

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME23}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get FamilyMember
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${fname1}                      FakerLibrary. name

    ${resp}=    Create Family Member       ${fname1}  ${lname}  ${dob}  ${gender}   ${primnum}  ${countryCodes[0]}  ${EMPTY}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${FAMILY_MEMBEBR_NAME_SAME}

JD-TC-AddFamilyMembersForProviderConsumer-UH9
    
    [Documentation]  Add another Family Member Without countryCodes.

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME23}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get FamilyMember
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${fname1}                      FakerLibrary. name

    ${resp}=    Create Family Member       ${fname1}  ${lname}  ${dob}  ${gender}   ${primnum}  ${EMPTY}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${COUNTRY_CODEREQUIRED}

JD-TC-AddFamilyMembersForProviderConsumer-
    
    [Documentation]  create 4 family members without phonenumber for a provider consumer, verify phone number is same as that of provider consumer, delete a family member, logout and try logging in that provider consumer again.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME22}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId1}=    get_acc_id       ${PUSERNAME22}
    Set Test Variable     ${accountId1}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp1}=  AddCustomer  ${CUSERNAME18}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Test Variable  ${pcid18}   ${resp1.json()}
   
    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=    Send Otp For Login    ${CUSERNAME18}    ${accountId1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME18}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME18}    ${accountId1}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Get FamilyMember
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Family Member       ${fname}  ${lname}  ${dob}  ${gender}   ${EMPTY}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get FamilyMember
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${fname}
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lname}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${CUSERNAME18}
    Should Be Equal As Strings    ${resp.json()[0]['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[0]}
    Set Suite Variable     ${fid1}    ${resp.json()[0]['id']}

    ${fname1}                      FakerLibrary. name
    ${lname1}                      FakerLibrary.last_name

    ${resp}=    Create Family Member       ${fname1}  ${lname1}  ${dob}  ${gender}   ${EMPTY}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get FamilyMember
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[1]['firstName']}    ${fname1}
    Should Be Equal As Strings    ${resp.json()[1]['lastName']}    ${lname1}
    Should Be Equal As Strings    ${resp.json()[1]['phoneNo']}    ${CUSERNAME18}
    Should Be Equal As Strings    ${resp.json()[1]['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()[1]['countryCode']}    ${countryCodes[0]}
    Set Suite Variable     ${fid2}    ${resp.json()[1]['id']}

    ${fname2}                      FakerLibrary. name
    ${lname2}                      FakerLibrary.last_name

    ${resp}=    Create Family Member       ${fname2}  ${lname2}  ${dob}  ${gender}   ${EMPTY}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get FamilyMember
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[2]['firstName']}    ${fname2}
    Should Be Equal As Strings    ${resp.json()[2]['lastName']}    ${lname2}
    Should Be Equal As Strings    ${resp.json()[2]['phoneNo']}    ${CUSERNAME18}
    Should Be Equal As Strings    ${resp.json()[2]['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()[2]['countryCode']}    ${countryCodes[0]}
    Set Suite Variable     ${fid3}    ${resp.json()[2]['id']}

    ${fname3}                      FakerLibrary. name
    ${lname3}                      FakerLibrary.last_name

    ${resp}=    Create Family Member       ${fname3}  ${lname3}  ${dob}  ${gender}   ${EMPTY}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get FamilyMember
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[3]['firstName']}    ${fname3}
    Should Be Equal As Strings    ${resp.json()[3]['lastName']}    ${lname3}
    Should Be Equal As Strings    ${resp.json()[3]['phoneNo']}    ${CUSERNAME18}
    Should Be Equal As Strings    ${resp.json()[3]['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()[3]['countryCode']}    ${countryCodes[0]}
    Set Suite Variable     ${fid4}    ${resp.json()[3]['id']}

    ${resp}=    Delete Family Members   ${fid4}      ${pcid18}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME18}    ${accountId1}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get FamilyMember
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200