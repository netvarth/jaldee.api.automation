*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Patient Record
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/hl_musers.py

*** Variables ***

@{emptylist}
${jpgfile}     /ebs/TDD/uploadimage.jpg
${order}    0
${fileSize}    0.00458
${withspl}        @#!


*** Test Cases ***


JD-TC-Delete Provider Consumer Notes-1

    [Documentation]    Delete Provider Consumer Notes

    ${resp}=  Encrypted Provider Login    ${PUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable  ${pdrname}  ${decrypted_data['userName']}

    # ${resp}=   Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings          ${resp.status_code}   200
    # Set Suite Variable    ${pid}        ${resp.json()['id']}
    # Set Suite Variable    ${pdrname}    ${resp.json()['userName']}

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${accountId}        ${resp.json()['id']}
    Set Suite Variable    ${accountName}      ${resp.json()['businessName']}

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

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   12
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout 
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

    ${resp}=  Encrypted Provider Login    ${PUSERNAME9}  ${PASSWORD}
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

    ${resp}=    Delete Provider Consumer Notes    ${note_id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.content}     []


JD-TC-Delete Provider Consumer Notes-2

    [Documentation]    Adding Provider consumer notes where description contain 250 words and delete using note id.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title}=  FakerLibrary.name
    ${description}=  FakerLibrary.Text     	max_nb_chars=255
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
    Set Suite Variable    ${note1_id}    ${resp.json()[0]['id']}  

    ${resp}=    Delete Provider Consumer Notes    ${note1_id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.content}     []

JD-TC-Delete Provider Consumer Notes-3

    [Documentation]    Adding 2 more provider consumer notes and delete using note id.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title}=  FakerLibrary.name
    ${description}=  FakerLibrary.Text     	max_nb_chars=250
    ${users}=   Create List  

    ${resp}=    Provider Consumer Add Notes    ${cid}    ${title}    ${description}    ${users}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${title1}=  FakerLibrary.name
    Set Suite Variable    ${title1}
    ${description1}=  FakerLibrary.last_name
    Set Suite Variable    ${description1}
    ${users1}=   Create List  

    ${resp}=    Provider Consumer Add Notes    ${cid}    ${title1}    ${description1}    ${users1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description}
    Should Be Equal As Strings    ${resp.json()[1]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[1]['title']}     ${title1}
    Should Be Equal As Strings    ${resp.json()[1]['description']}     ${description1}
    Set Suite Variable    ${note2_id}    ${resp.json()[0]['id']}  
    Set Suite Variable    ${note3_id}    ${resp.json()[1]['id']}  

    ${resp}=    Delete Provider Consumer Notes    ${note2_id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description1}

     ${resp}=    Delete Provider Consumer Notes    ${note3_id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.content}     []
   

JD-TC-Delete Provider Consumer Notes-4

    [Documentation]    Adding provider consumer notes where the title is empty and delete using note id.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    # ${title}=  FakerLibrary.Text     	
    ${description}=  FakerLibrary.Text     	
    ${users}=   Create List  

    ${resp}=    Provider Consumer Add Notes    ${cid}    ${EMPTY}    ${description}    ${users}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description}
    Set Suite Variable    ${note_id}    ${resp.json()[0]['id']}   

    ${resp}=    Delete Provider Consumer Notes    ${note_id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.content}     []

JD-TC-Delete Provider Consumer Notes-5

    [Documentation]   Adding Provider Consumer notes where description is empty  and delete using note id.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title}=  FakerLibrary.Text     	
    # ${description}=  FakerLibrary.Text     	
    ${users}=   Create List  

    ${resp}=    Provider Consumer Add Notes    ${cid}    ${title}    ${EMPTY}    ${users}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title}
    Set Suite Variable    ${note_id}    ${resp.json()[0]['id']}   

    ${resp}=    Delete Provider Consumer Notes    ${note_id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.content}     []


JD-TC-Delete Provider Consumer Notes-6

    [Documentation]   delete the provider consumer notes from valid user login

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${p_id1}  ${decrypted_data['id']}
    Set Suite Variable  ${pdrname}  ${decrypted_data['userName']}

    # ${resp}=   Encrypted Provider Login  ${HLMUSERNAME5}  ${PASSWORD} 
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # ${p_id1}=  get_acc_id  ${HLMUSERNAME5}
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
    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
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

    ${resp}=    Customer Logout 
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
   

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME5}  ${PASSWORD}
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

    
    ${resp}=  SendProviderResetMail   ${sam_email}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${sam_email}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${sam_email}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${users1}=   Create List   ${u_id}
    ${title2}=  FakerLibrary.Text     max_nb_chars=250

    ${resp}=    Delete Provider Consumer Notes    ${note_id1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Delete Provider Consumer Notes-7

    [Documentation]  Update Provider Consumer Notes from user login and remove the notes details from main provider login.


    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME5}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${p_id1}=  get_acc_id  ${HLMUSERNAME5}
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
    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    # ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    # Log  ${resp1.content}
    # Should Be Equal As Strings  ${resp1.status_code}  200
    # Set Test Variable  ${dep_id}  ${resp1.json()}

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

    ${resp}=    Customer Logout 
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
   

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME5}  ${PASSWORD}
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

    
    ${resp}=  SendProviderResetMail   ${sam_email}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${sam_email}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${sam_email}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${users1}=   Create List   ${u_id}
    ${title2}=  FakerLibrary.Text     max_nb_chars=250

    ${resp}=    Update Provider Consumer Notes    ${note_id1}    ${title2}    ${description}    ${users1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid1}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title2}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description}

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Delete Provider Consumer Notes    ${note_id1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.content}     []

JD-TC-Delete Provider Consumer Notes-8

    [Documentation]  update provider consumer notes from user login and delete the notes from user login.


    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME5}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${p_id1}=  get_acc_id  ${HLMUSERNAME5}
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
    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    # ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    # Log  ${resp1.content}
    # Should Be Equal As Strings  ${resp1.status_code}  200
    # Set Test Variable  ${dep_id}  ${resp1.json()}

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

    ${resp}=    Customer Logout 
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
   

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME5}  ${PASSWORD}
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

    
    ${resp}=  SendProviderResetMail   ${sam_email}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${sam_email}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${sam_email}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${users1}=   Create List   ${u_id}
    ${title2}=  FakerLibrary.Text     max_nb_chars=250

    ${resp}=    Update Provider Consumer Notes    ${note_id1}    ${title2}    ${description}    ${users1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid1}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title2}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description}


    ${resp}=    Delete Provider Consumer Notes    ${note_id1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.content}     []

JD-TC-Delete Provider Consumer Notes-9

    [Documentation]  Add 2 provider consumer notes from user login and remove one notes  from main provider login.


    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME5}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${p_id1}=  get_acc_id  ${HLMUSERNAME5}
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
    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    # ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    # Log  ${resp1.content}
    # Should Be Equal As Strings  ${resp1.status_code}  200
    # Set Test Variable  ${dep_id}  ${resp1.json()}

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

    ${resp}=    Customer Logout 
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
   

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME5}  ${PASSWORD}
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

    
    ${resp}=  SendProviderResetMail   ${sam_email}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${sam_email}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${sam_email}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${users1}=   Create List   ${u_id}
    ${title2}=  FakerLibrary.Text     max_nb_chars=250

    ${resp}=    Provider Consumer Add Notes    ${cid1}    ${title3}    ${description3}    ${users1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid1}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title3}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description3}
    Set Suite Variable    ${note_id2}    ${resp.json()[0]['id']}   

    ${resp}=    Provider Consumer Add Notes    ${cid1}    ${title2}    ${description}    ${users1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[1]['providerConsumerId']}     ${cid1}
    Should Be Equal As Strings    ${resp.json()[1]['title']}     ${title2}
    Should Be Equal As Strings    ${resp.json()[1]['description']}     ${description}
    Set Suite Variable    ${note_id3}    ${resp.json()[1]['id']}   


    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Delete Provider Consumer Notes    ${note_id2}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Consumer Notes    ${cid1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid1}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title2}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description}

     

JD-TC-Delete Provider Consumer Notes-UH1

    [Documentation]   Delete Provider Consumer notes where note id is invalid.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title}=  FakerLibrary.Text     	
    ${description}=  FakerLibrary.Text     	
    ${users}=   Create List  

    ${resp}=    Provider Consumer Add Notes    ${cid}    ${title}    ${description}    ${users}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${fake_id}=  Random Int  min=100   max=999

    ${resp}=    Delete Provider Consumer Notes    ${fake_id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}   ${PROVIDER_CONSUMER_NOTES_NOT_FOUND}

JD-TC-Delete Provider Consumer Notes-UH2

    [Documentation]   Delete Provider Consumer notes using another provider login.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}   200


    ${resp}=    Delete Provider Consumer Notes    ${note_id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.content}   "${NO_PERMISSION}"


JD-TC-Delete Provider Consumer Notes-UH3

    [Documentation]   Delete Provider Consumer notes without login.

    ${resp}=   Delete Provider Consumer Notes    ${note_id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Delete Provider Consumer Notes-UH4

    [Documentation]   Delete Provider consumer notes with Consumer login.

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=    Delete Provider Consumer Notes    ${note_id}    
    Log   ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}   400
    Should Be Equal As Strings    ${resp.json()}   ${LOGIN_INVALID_URL}

