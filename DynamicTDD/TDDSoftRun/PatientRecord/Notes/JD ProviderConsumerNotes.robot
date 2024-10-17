*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Patient Record
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
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


JD-TC-Adding Provider Consumer Notes-1

    [Documentation]    Adding Provider Consumer Notes

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

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${primaryMobileNo}     ${accountId}
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
    Set Suite Variable    ${title}
    ${description}=  FakerLibrary.last_name
    Set Suite Variable    ${description}
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
    Set Suite Variable    ${note_id}    ${resp.json()[0]['id']}   

    ${title1}=  FakerLibrary.name
    ${description1}=  FakerLibrary.last_name
    ${users1}=   Create List  

    ${resp}=    Update Provider Consumer Notes    ${note_id}    ${title1}    ${description1}    ${users1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description1}

    ${resp}=    Delete Provider Consumer Notes    ${note_id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


JD-TC-Adding Provider Consumer Notes-2

    [Documentation]    Adding Provider consumer notes where description contain 250 words.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title}=  FakerLibrary.name
    ${description}=  FakerLibrary.Text     	max_nb_chars=255
    ${users}=   Create List  

    ${resp}=    Provider Consumer Add Notes    ${cid}    ${title}    ${description}    ${users}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Adding Provider Consumer Notes-3

    [Documentation]    Adding Provider consumer notes where title contain more than 50 words.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title}=  FakerLibrary.Text     	max_nb_chars=255
    ${description}=  FakerLibrary.Text     	
    ${users}=   Create List  

    ${resp}=    Provider Consumer Add Notes    ${cid}    ${title}    ${description}    ${users}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Adding Provider Consumer Notes-4

    [Documentation]    Adding provider consumer notes where the title is empty.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    # ${title}=  FakerLibrary.Text     	
    ${description}=  FakerLibrary.Text     	
    ${users}=   Create List  

    ${resp}=    Provider Consumer Add Notes    ${cid}    ${EMPTY}    ${description}    ${users}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Adding Provider Consumer Notes-5

    [Documentation]   Adding Provider Consumer notes where description is empty.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title}=  FakerLibrary.Text     	
    # ${description}=  FakerLibrary.Text     	
    ${users}=   Create List  

    ${resp}=    Provider Consumer Add Notes    ${cid}    ${title}    ${EMPTY}    ${users}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Adding Provider Consumer Notes-UH1

    [Documentation]   Adding Provider Consumer notes where user id is empty.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title}=  FakerLibrary.Text     	
    ${description}=  FakerLibrary.Text     	
    ${users}=   Create List  

    ${resp}=    Provider Consumer Add Notes    ${EMPTY}    ${title}    ${description}    ${users}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422

JD-TC-Adding Provider Consumer Notes-UH2

    [Documentation]   Adding Provider consumer notes using another provider login.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}   200

    ${title}=  FakerLibrary.Text     	
    ${description}=  FakerLibrary.Text     	
    ${users}=   Create List  

    ${resp}=    Provider Consumer Add Notes    ${cid}    ${title}    ${description}    ${users}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422

JD-TC-Adding Provider Consumer Notes-UH3

    [Documentation]   Adding Provider consumer notes where description contains numbers.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title}=  FakerLibrary.Text     	
    ${description}=  FakerLibrary.Random Number     	
    ${users}=   Create List  

    ${resp}=    Provider Consumer Add Notes    ${cid}    ${title}    ${description}    ${users}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Adding Provider Consumer Notes-UH4

    [Documentation]   Adding Provider consumer notes where user id is invalid.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title}=  FakerLibrary.Text     	
    ${description}=  FakerLibrary.Text  
    ${fakeid}=    Random Int  min=1000   max=9999	
    ${users}=   Create List   ${fakeid}
    ${USER_NOT_FOUND_WITH_ID}=  Format String  ${USER_NOT_FOUND_WITH_ID}  ${fakeid}

    ${resp}=    Provider Consumer Add Notes    ${cid}    ${title}    ${description}    ${users}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}   ${USER_NOT_FOUND_WITH_ID}

JD-TC-Adding Provider Consumer Notes-UH5

    [Documentation]   Adding Provider consumer notes where consumer id is invalid.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title}=  FakerLibrary.Text     	
    ${description}=  FakerLibrary.Text     	
    ${users}=   Create List   

    ${resp}=    Provider Consumer Add Notes    ${EMPTY}    ${title}    ${description}    ${users}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422

JD-TC-Adding Provider Consumer Notes-UH6

    [Documentation]   Adding Provider consumer notes where the title contains numbers.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title}=  FakerLibrary.Random Number     	
    ${description}=  FakerLibrary.Text     	
    ${users}=   Create List   

    ${resp}=    Provider Consumer Add Notes    ${cid}    ${title}    ${description}    ${users}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Adding Provider Consumer Notes-UH7

    [Documentation]   Adding Provider consumer notes where the title contains special characters.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200
     	
    ${description}=  FakerLibrary.Text     	
    ${users}=   Create List   

    ${resp}=    Provider Consumer Add Notes    ${cid}    ${title1}    ${description}    ${users}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Adding Provider Consumer Notes-UH8

    [Documentation]   Adding Provider consumer notes where the title contains special characters.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200
    
    ${title}=  FakerLibrary.Text     	
    ${users}=   Create List   

    ${resp}=    Provider Consumer Add Notes    ${cid}    ${title}    ${description1}    ${users}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Adding Provider Consumer Notes-UH9

    [Documentation]   Adding Provider consumer notes without login.

    ${description}=  FakerLibrary.Text     	
    ${title}=  FakerLibrary.Text     	
    ${users}=   Create List   

    ${resp}=    Provider Consumer Add Notes    ${cid}    ${title}    ${description}    ${users}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-Adding Provider Consumer Notes-UH10

    [Documentation]   Adding Provider consumer notes with Consumer login.

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${description}=  FakerLibrary.Text     	
    ${title}=  FakerLibrary.Text     	
    ${users}=   Create List   

    ${resp}=    Provider Consumer Add Notes    ${cid}    ${title}    ${description}    ${users}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   400
    Should Be Equal As Strings    ${resp.json()}   ${LOGIN_INVALID_URL}


