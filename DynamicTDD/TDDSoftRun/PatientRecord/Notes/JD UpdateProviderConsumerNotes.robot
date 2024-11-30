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
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***

@{emptylist}
${jpgfile}     /ebs/TDD/uploadimage.jpg
${order}    0
${fileSize}    0.00458
${withspl}        @#!


*** Test Cases ***


JD-TC-Update Provider Consumer Notes-1

    [Documentation]    Update Provider Consumer Notes

    ${resp}=  Encrypted Provider Login    ${PUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable  ${pdrname}  ${decrypted_data['userName']}

    # ${resp}=   ProviderLogin  ${PUSERNAME11}  ${PASSWORD} 
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

    ${resp}=  Encrypted Provider Login    ${PUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title}=  FakerLibrary.name
    Set Suite Variable    ${title}
    ${description}=  FakerLibrary.last_name
    Set Suite Variable    ${description}
    ${users}=   Create List  
    Set Suite Variable    ${users}


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
    Set Suite Variable    ${title1}
    ${description1}=  FakerLibrary.last_name
    Set Suite Variable    ${description1}
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


JD-TC-Update Provider Consumer Notes-2

    [Documentation]     Update Provider consumer notes where  description is empty.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200
    # Set Suite Variable    ${pid}        ${resp.json()['id']}
    # Set Suite Variable    ${pdrname}    ${resp.json()['userName']}

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${accountId}        ${resp.json()['id']}
    Set Suite Variable    ${accountName}      ${resp.json()['businessName']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

   
    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description1}
    Set Suite Variable    ${note_id}    ${resp.json()[0]['id']}   

    ${users1}=   Create List  

    ${resp}=    Update Provider Consumer Notes    ${note_id}    ${title1}    ${empty}    ${users1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description1}

    

JD-TC-Update Provider Consumer Notes-3

    [Documentation]     Update Provider consumer notes where  title is empty.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200
    # Set Suite Variable    ${pid}        ${resp.json()['id']}
    # Set Suite Variable    ${pdrname}    ${resp.json()['userName']}

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${accountId}        ${resp.json()['id']}
    Set Suite Variable    ${accountName}      ${resp.json()['businessName']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

   
    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description1}
    Set Suite Variable    ${note_id}    ${resp.json()[0]['id']}   

    ${users1}=   Create List  

    ${resp}=    Update Provider Consumer Notes    ${note_id}    ${empty}    ${description1}    ${users1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description1}

   

JD-TC-Update Provider Consumer Notes-4

    [Documentation]     Update Provider consumer notes where discription is different.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200
    # Set Suite Variable    ${pid}        ${resp.json()['id']}
    # Set Suite Variable    ${pdrname}    ${resp.json()['userName']}

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${accountId}        ${resp.json()['id']}
    Set Suite Variable    ${accountName}      ${resp.json()['businessName']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

   
    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description1}
    Set Suite Variable    ${note_id}    ${resp.json()[0]['id']}   

    ${users1}=   Create List  

    ${resp}=    Update Provider Consumer Notes    ${note_id}    ${empty}    ${description}    ${users1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description}

   

JD-TC-Update Provider Consumer Notes-5

    [Documentation]     Update Provider consumer notes where title is different.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200
    # Set Suite Variable    ${pid}        ${resp.json()['id']}
    # Set Suite Variable    ${pdrname}    ${resp.json()['userName']}

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${accountId}        ${resp.json()['id']}
    Set Suite Variable    ${accountName}      ${resp.json()['businessName']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

   
    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description}
    Set Suite Variable    ${note_id}    ${resp.json()[0]['id']}   

    ${users1}=   Create List  

    ${resp}=    Update Provider Consumer Notes    ${note_id}    ${title}    ${description}    ${users1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description}

    

JD-TC-Update Provider Consumer Notes-6

    [Documentation]     Update Provider consumer notes where description contain 255 words


    ${resp}=  Encrypted Provider Login    ${PUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200
    # Set Suite Variable    ${pid}        ${resp.json()['id']}
    # Set Suite Variable    ${pdrname}    ${resp.json()['userName']}

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${accountId}        ${resp.json()['id']}
    Set Suite Variable    ${accountName}      ${resp.json()['businessName']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

   
    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description}
    Set Suite Variable    ${note_id}    ${resp.json()[0]['id']}   

    ${users1}=   Create List  
    ${description2}=  FakerLibrary.Text     max_nb_chars=255
    Set Suite Variable    ${description2}

    ${resp}=    Update Provider Consumer Notes    ${note_id}    ${title}    ${description2}    ${users1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description2}

    

JD-TC-Update Provider Consumer Notes-7

    [Documentation]     Update Provider consumer notes where title contain 255 words


    ${resp}=  Encrypted Provider Login    ${PUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200
    # Set Suite Variable    ${pid}        ${resp.json()['id']}
    # Set Suite Variable    ${pdrname}    ${resp.json()['userName']}

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${accountId}        ${resp.json()['id']}
    Set Suite Variable    ${accountName}      ${resp.json()['businessName']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

   
    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description2}
    Set Suite Variable    ${note_id}    ${resp.json()[0]['id']}   

    ${users1}=   Create List  
    ${title2}=  FakerLibrary.Text     max_nb_chars=255

    ${resp}=    Update Provider Consumer Notes    ${note_id}    ${title2}    ${description2}    ${users1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title2}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description2}

JD-TC-Update Provider Consumer Notes-8

    [Documentation]  Update Provider consumer notes with valid user login

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${p_id1}  ${decrypted_data['id']}
    Set Suite Variable  ${pdrname}  ${decrypted_data['userName']}


    # ${resp}=   ProviderLogin  ${HLPUSERNAME4}  ${PASSWORD} 
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # ${p_id1}=  get_acc_id  ${HLPUSERNAME4}
    # Set Suite Variable   ${p_id1}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
        Set Suite Variable  ${locId1}
    ELSE
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
    END

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${accoun_Id}        ${resp.json()['id']}  
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    ${resp}=  Get Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Test Variable  ${dep_id}  ${resp1.json()}

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fName}=  FakerLibrary.name
    Set Suite Variable    ${fName}
    ${lName}=  FakerLibrary.last_name
    Set Suite Variable    ${lName}
    ${primaryMobileNo1}    Generate random string    10    55574711478
    ${primaryMobileNo1}    Convert To Integer  ${primaryMobileNo1}
    Set Suite Variable    ${primaryMobileNo1}
    Set Suite Variable  ${email1}  ${lName}${primaryMobileNo1}.${test_mail}

    ${resp}=    Send Otp For Login    ${primaryMobileNo1}    ${accoun_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo1}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token1}  ${resp.json()['token']}

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${fName}  ${lName}  ${email1}    ${primaryMobileNo1}     ${accoun_Id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo1}    ${accoun_Id}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${cid1}            ${resp.json()['providerConsumer']}
    Set Suite Variable    ${jconid1}         ${resp.json()['id']}
   

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200



    ${u_id}=  Create Sample User
    Set Suite Variable  ${u_id}

    ${resp}=  Get User By Id      ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${PUSERNAME_U1}     ${resp.json()['mobileNo']}
    Set Suite Variable      ${sam_email}     ${resp.json()['email']}


    ${title3}=  FakerLibrary.name
    ${description3}=  FakerLibrary.last_name
    ${users1}=   Create List   ${u_id}


    ${resp}=    Provider Consumer Add Notes    ${cid1}    ${title3}    ${description3}    ${users1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid1}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title3}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description3}
    Set Suite Variable    ${note_id1}    ${resp.json()[0]['id']}   

    
    ${resp}=    Reset LoginId  ${u_id}  ${PUSERNAME_U1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUSERNAME_U1}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUSERNAME_U1}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUSERNAME_U1}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login     ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}   200

    ${users1}=   Create List   ${u_id}
    ${title2}=  FakerLibrary.Text     max_nb_chars=255

    ${resp}=    Update Provider Consumer Notes    ${note_id1}    ${title2}    ${description2}    ${users1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid1}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title2}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description2}
    



JD-TC-Update Provider Consumer Notes-UH1

    [Documentation]     Update Provider consumer notes where user id is invalid.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200
    # Set Suite Variable    ${pid}        ${resp.json()['id']}
    # Set Suite Variable    ${pdrname}    ${resp.json()['userName']}

    ${fakeid}=    Random Int  min=1000   max=9999
    ${users1}=   Create List   ${fakeid}
    ${title2}=  FakerLibrary.Text     max_nb_chars=255
    ${USER_NOT_FOUND_WITH_ID}=  Format String  ${USER_NOT_FOUND_WITH_ID}  ${fakeid}

    ${resp}=    Update Provider Consumer Notes    ${note_id}    ${title2}    ${description2}    ${users1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}   ${USER_NOT_FOUND_WITH_ID}

JD-TC-Update Provider Consumer Notes-UH2

    [Documentation]     Update Provider consumer notes where note id is invalid

    ${resp}=  Encrypted Provider Login    ${PUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200
    # Set Suite Variable    ${pid}        ${resp.json()['id']}
    # Set Suite Variable    ${pdrname}    ${resp.json()['userName']}

    ${test}=   FakerLibrary.Text 
    ${users1}=   Create List   
    ${title2}=  FakerLibrary.Text     max_nb_chars=255
    ${fakeid}=   FakerLibrary.Random Number

    ${resp}=    Update Provider Consumer Notes    ${fakeid}    ${title2}    ${description2}    ${users1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.content}   "${PROVIDER_CONSUMER_NOTES_NOT_FOUND}"

JD-TC-Update Provider Consumer Notes-UH3

    [Documentation]     Update Provider consumer notes where the title contains numbers.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200
    # Set Suite Variable    ${pid}        ${resp.json()['id']}
    # Set Suite Variable    ${pdrname}    ${resp.json()['userName']}

    # ${test}=   FakerLibrary.Text 
    ${users1}=   Create List   
    ${title2}=  FakerLibrary.Text    
    ${fakeid}=   FakerLibrary.Random Number

    ${resp}=    Update Provider Consumer Notes    ${note_id}    ${fakeid}    ${description2}    ${users1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Update Provider Consumer Notes-UH4

    [Documentation]     Update Provider consumer notes where the title contains special characters.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200
    # Set Suite Variable    ${pid}        ${resp.json()['id']}
    # Set Suite Variable    ${pdrname}    ${resp.json()['userName']}

    # ${test}=   FakerLibrary.Text 
    ${users1}=   Create List   
    ${title2}=  FakerLibrary.Text    
    ${fakeid}=   FakerLibrary.Random Number

    ${resp}=    Update Provider Consumer Notes    ${note_id}    ${withspl}    ${description2}    ${users1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Update Provider Consumer Notes-UH5

    [Documentation]    Update Provider consumer notes where the description contains special characters.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200
    # Set Suite Variable    ${pid}        ${resp.json()['id']}
    # Set Suite Variable    ${pdrname}    ${resp.json()['userName']}

    # ${test}=   FakerLibrary.Text 
    ${users1}=   Create List  
    ${title2}=  FakerLibrary.Text    
    ${fakeid}=   FakerLibrary.Random Number

    ${resp}=    Update Provider Consumer Notes    ${note_id}    ${title2}    ${withspl}    ${users1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Update Provider Consumer Notes-UH6

    [Documentation]   Update Provider consumer notes without login.


    # ${test}=   FakerLibrary.Text 
    ${users1}=   Create List   
    ${title2}=  FakerLibrary.Text    
    ${fakeid}=   FakerLibrary.Random Number

    ${resp}=    Update Provider Consumer Notes    ${note_id}    ${title2}    ${description2}    ${users1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Update Provider Consumer Notes-UH7

    [Documentation]   Update Provider consumer notes where description contains numbers.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200
    # Set Suite Variable    ${pid}        ${resp.json()['id']}
    # Set Suite Variable    ${pdrname}    ${resp.json()['userName']}

    # ${test}=   FakerLibrary.Text 
    ${users1}=   Create List   
    ${title2}=  FakerLibrary.Text    
    ${des_num}=   FakerLibrary.Random Number

    ${resp}=    Update Provider Consumer Notes    ${note_id}    ${title2}    ${des_num}    ${users1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Update Provider Consumer Notes-UH8

    [Documentation]   Update Provider consumer notes using another provider login.


    ${resp}=   Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}   200
    # Set Suite Variable    ${pid}        ${resp.json()['id']}
    # Set Suite Variable    ${pdrname}    ${resp.json()['userName']}

    # ${test}=   FakerLibrary.Text 
    ${users1}=   Create List  
    ${title2}=  FakerLibrary.Text    
    ${des_num}=   FakerLibrary.Random Number

    ${resp}=    Update Provider Consumer Notes    ${note_id}    ${title2}    ${description2}    ${users1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.content}   "${NO_PERMISSION}"

JD-TC-Update Provider Consumer Notes-UH9

    [Documentation]   Update Provider consumer notes u with Consumer login.


    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200

    # ${test}=   FakerLibrary.Text 
    ${users1}=   Create List   
    ${title2}=  FakerLibrary.Text    
    ${des_num}=   FakerLibrary.Random Number

    ${resp}=    Update Provider Consumer Notes    ${note_id}    ${title2}    ${description2}    ${users1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   400
    Should Be Equal As Strings    ${resp.json()}   ${LOGIN_INVALID_URL}

    

     







