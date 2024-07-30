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

JD-TC-UpdateFamilyMembersForProviderConsumer-1
    
    [Documentation]  Add Family Member for Provider Consumer, then update with same data.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME22}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=    get_acc_id       ${PUSERNAME22}
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

    ${resp1}=  AddCustomer  ${CUSERNAME35}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable  ${pcid18}   ${resp1.json()}
   
    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=    Send Otp For Login    ${CUSERNAME35}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME35}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME35}    ${accountId}    ${token}
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
    Set Suite Variable   ${memb_id}  ${resp.json()}

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

    ${resp}=   Update Family Members   ${memb_id}  ${cid}   ${fname}  ${lname}  ${dob}  ${gender}   ${primnum}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Family Members   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lname}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${primnum}
    Should Be Equal As Strings    ${resp.json()[0]['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[0]}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${fname}

JD-TC-UpdateFamilyMembersForProviderConsumer-2
    
    [Documentation]   update Family Members first name.

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME35}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${fname1}                      FakerLibrary. name

    ${resp}=   Update Family Members   ${memb_id}  ${cid}   ${fname1}  ${lname}  ${dob}  ${gender}   ${primnum}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Family Members   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lname}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${primnum}
    Should Be Equal As Strings    ${resp.json()[0]['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[0]}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${fname1}

JD-TC-UpdateFamilyMembersForProviderConsumer-3
    
    [Documentation]   update Family Members last name.

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME35}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${lname1}                      FakerLibrary. name

    ${resp}=   Update Family Members   ${memb_id}  ${cid}   ${fname}  ${lname1}  ${dob}  ${gender}   ${primnum}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Family Members   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lname1}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${primnum}
    Should Be Equal As Strings    ${resp.json()[0]['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[0]}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${fname}

JD-TC-UpdateFamilyMembersForProviderConsumer-4
    
    [Documentation]   update Family Members dob as a string.

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME35}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${dob}                      FakerLibrary. name

    ${resp}=   Update Family Members   ${memb_id}  ${cid}   ${fname}  ${lname}  ${dob}  ${gender}   ${primnum}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Family Members   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lname}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${primnum}
    Should Be Equal As Strings    ${resp.json()[0]['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[0]}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${fname}

JD-TC-UpdateFamilyMembersForProviderConsumer-5
    
    [Documentation]   update Family Members gender as integer.

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME35}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${gender}                      FakerLibrary. Random Number

    ${resp}=   Update Family Members   ${memb_id}  ${cid}   ${fname}  ${lname}  ${dob}  ${gender}   ${primnum}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Family Members   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lname}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${primnum}
    Should Be Equal As Strings    ${resp.json()[0]['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[0]}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${fname}

JD-TC-UpdateFamilyMembersForProviderConsumer-6
    
    [Documentation]   update Family Members primnum as string.

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME35}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${primnum}                      FakerLibrary. name

    ${resp}=   Update Family Members   ${memb_id}  ${cid}   ${fname}  ${lname}  ${dob}  ${gender}   ${primnum}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Family Members   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lname}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${primnum}
    Should Be Equal As Strings    ${resp.json()[0]['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[0]}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${fname}

JD-TC-UpdateFamilyMembersForProviderConsumer-UH1
    
    [Documentation]   update Family Members with invalid member id.

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME35}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${memb_id}                      FakerLibrary. Random Number

    ${resp}=   Update Family Members   ${memb_id}  ${cid}   ${fname}  ${lname}  ${dob}  ${gender}   ${primnum}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}    ${FAMILY_MEMEBR_NOT_FOUND}


JD-TC-UpdateFamilyMembersForProviderConsumer-UH2
    
    [Documentation]   update Family Members with invalid provider id.

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME35}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${cid}                      FakerLibrary. Random Number

    ${resp}=   Update Family Members   ${memb_id}  ${cid}   ${fname}  ${lname}  ${dob}  ${gender}   ${primnum}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}    ${NO_PERMISSION_TO_UPDATE_MEMBER}
