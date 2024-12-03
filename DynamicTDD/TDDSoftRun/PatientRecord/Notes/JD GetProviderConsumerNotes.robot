*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Patient Record
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
# Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***

@{emptylist}
${jpgfile}     /ebs/TDD/uploadimage.jpg
${order}    0
${fileSize}    0.00458
${title1}    @sdf@123
${description1}    &^7gsdkqwrrf

*** Test Cases ***


JD-TC-Get Provider Consumer Notes-1

    [Documentation]    Get Provider Consumer Notes.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable  ${pdrname}  ${decrypted_data['userName']}

    # ${resp}=   ProviderLogin  ${PUSERNAME10}  ${PASSWORD} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings          ${resp.status_code}   200
    # Set Suite Variable    ${pid}        ${resp.json()['id']}
    # Set Suite Variable    ${pdrname}    ${resp.json()['userName']}

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${accountId}        ${resp.json()['id']}
    Set Suite Variable    ${accountName}      ${resp.json()['businessName']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Suite Variable    ${primaryMobileNo}
    Set Suite Variable  ${email}  ${lastName}${primaryMobileNo}.${test_mail}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    # ${resp}=    Consumer Logout 
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${primaryMobileNo}  ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200   
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${cid}            ${resp.json()['providerConsumer']}
    Set Suite Variable    ${jconid}         ${resp.json()['id']}
    Set Suite Variable    ${proconfname}    ${resp.json()['firstName']}    
    Set Suite Variable    ${proconlname}    ${resp.json()['lastName']} 
    Set Suite Variable    ${fullname}       ${proconfname}${space}${proconlname}

    ${resp}=  Encrypted Provider Login    ${PUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title}=  FakerLibrary.name
    ${description}=  FakerLibrary.last_name
    ${users}=   Create List  

    ${resp}=    Provider Consumer Add Notes    ${cid}    ${title}    ${description}    ${users}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description}

JD-TC-Get Provider Consumer Notes-2

    [Documentation]    Adding Provider consumer notes where description contain 250 words and get that details using Providrer consumer id.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title}=  FakerLibrary.name
    ${description1}=  FakerLibrary.Text     	max_nb_chars=255
    ${users}=   Create List  

    ${resp}=    Provider Consumer Add Notes    ${cid}    ${title}    ${description1}    ${users}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[1]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[1]['title']}     ${title}
    Should Be Equal As Strings    ${resp.json()[1]['description']}     ${description1}

JD-TC-Get Provider Consumer Notes-3

    [Documentation]    Adding 2 more provider consumer notes and get the notes details.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title}=  FakerLibrary.name
    ${description}=  FakerLibrary.last_name
    ${users}=   Create List  

    ${resp}=    Provider Consumer Add Notes    ${cid}    ${title}    ${description}    ${users}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${title1}=  FakerLibrary.name
    ${description1}=  FakerLibrary.last_name
    ${users1}=   Create List  

    ${resp}=    Provider Consumer Add Notes    ${cid}    ${title1}    ${description1}    ${users1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[2]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[2]['title']}     ${title}
    Should Be Equal As Strings    ${resp.json()[2]['description']}     ${description}

    Should Be Equal As Strings    ${resp.json()[3]['title']}     ${title1}
    Should Be Equal As Strings    ${resp.json()[3]['description']}     ${description1}


JD-TC-Get Provider Consumer Notes-4

    [Documentation]    Adding provider consumer notes where the title is empty and get the notes details.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${description}=  FakerLibrary.last_name
    ${users}=   Create List  

    ${resp}=    Provider Consumer Add Notes    ${cid}    ${EMPTY}    ${description}    ${users}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Not Contain   ${resp.json()[4]}    title
    # Should Be Equal As Strings    ${resp.json()[4]['title']}     ${EMPTY}
    Should Be Equal As Strings    ${resp.json()[4]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[4]['description']}     ${description}

JD-TC-Get Provider Consumer Notes-5

    [Documentation]    Adding Provider Consumer notes where description is empty and get the notes details.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title}=  FakerLibrary.last_name
    ${users}=   Create List  

    ${resp}=    Provider Consumer Add Notes    ${cid}    ${title}    ${EMPTY}    ${users}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Not Contain   ${resp.json()[5]}    description
    Should Be Equal As Strings    ${resp.json()[5]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[5]['title']}     ${title}
    # Should Be Equal As Strings    ${resp.json()[5]['description']}     ${EMPTY}

JD-TC-Get Provider Consumer Notes-6

    [Documentation]    Create and Update a note then verify it.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title}=  FakerLibrary.name
    ${description}=  FakerLibrary.last_name
    ${users}=   Create List  

    ${resp}=    Provider Consumer Add Notes    ${cid}    ${title}    ${description}    ${users}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[6]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[6]['title']}     ${title}
    Should Be Equal As Strings    ${resp.json()[6]['description']}     ${description}
    Set Suite Variable    ${note_id}    ${resp.json()[6]['id']}   


    ${title1}=  FakerLibrary.name
    ${description1}=  FakerLibrary.last_name
    ${users1}=   Create List  

    ${resp}=    Update Provider Consumer Notes    ${note_id}    ${title1}    ${description1}    ${users1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[6]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[6]['title']}     ${title1}
    Should Be Equal As Strings    ${resp.json()[6]['description']}     ${description1}


JD-TC-Get Provider Consumer Notes-7

    [Documentation]    Delete a note then verify it.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Delete Provider Consumer Notes    ${note_id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Not Contain   ${resp.json()}    ${note_id} 

    # Should Be Equal As Strings    ${resp.json()[6]['providerConsumerId']}     ${cid}

JD-TC-Get Provider Consumer Notes-UH1

    [Documentation]    Adding Provider consumer notes using another provider login and get the notes details.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422

JD-TC-Get Provider Consumer Notes-UH2

    [Documentation]   Get Provider consumer notes without login.

    ${resp}=  Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-Get Provider Consumer Notes-UH3

    [Documentation]   Get Provider consumer notes with Consumer login.

    ${resp}=   Consumer Login  ${CUSERNAME8}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}   ${NoAccess}
