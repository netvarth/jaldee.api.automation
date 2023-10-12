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

*** Variables ***
${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf
@{emptylist}
${giffile}     /ebs/TDD/sample.gif
${jpegfile}     /ebs/TDD/large.jpeg
${shfile}     /ebs/TDD/example.sh
${docfile}     /ebs/TDD/docsample.doc
${txtfile}     /ebs/TDD/textsample.txt
${mp4file}      /ebs/TDD/MP4file.mp4
${mp3file}      /ebs/TDD/MP3file.mp3
${order}    0
${fileSize}    0.00458
${titles}    @sdf@123
${description1}    &^7gsdkqwrrf

*** Test Cases ***

JD-TC-Update Case Type-1

    [Documentation]    Update Case Type

    ${resp}=  Encrypted Provider Login    ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable    ${pdrname}    ${decrypted_data['userName']}

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${accountId}        ${resp.json()['id']}
    Set Suite Variable    ${accountName}      ${resp.json()['businessName']}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${name}=  FakerLibrary.name
    Set Suite Variable    ${name}
    ${aliasName}=  FakerLibrary.name
    Set Suite Variable    ${aliasName}
    ${aliasName1}=  FakerLibrary.name
    Set Suite Variable    ${aliasName1}

    ${resp}=    Create Case Type    ${name}  ${aliasName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${id}    ${resp.json()['id']} 

    ${resp}=    Get Case Type    ${id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id} 
    Should Be Equal As Strings    ${resp.json()['account']}     ${accountId} 
    Should Be Equal As Strings    ${resp.json()['name']}     ${name}
    Should Be Equal As Strings    ${resp.json()['aliasName']}     ${aliasName}
    Should Be Equal As Strings    ${resp.json()['status']}     ${toggle[0]}

    ${resp}=    Update Case Type  ${id}  ${name}  ${aliasName1}   ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
   
    ${resp}=    Get Case Type Filter    
    Log   ${resp.content}

    ${resp}=    Get Case Type    ${id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id} 
    Should Be Equal As Strings    ${resp.json()['account']}     ${accountId} 
    Should Be Equal As Strings    ${resp.json()['name']}     ${name}
    Should Be Equal As Strings    ${resp.json()['aliasName']}     ${aliasName1}
    Should Be Equal As Strings    ${resp.json()['status']}     ${toggle[0]}

JD-TC-Update Case Type-2

    [Documentation]    Update Case type where name contain 200 words

    ${resp}=  Encrypted Provider Login    ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${description1}=  FakerLibrary.Text     	max_nb_chars=200

    ${resp}=    Update Case Type    ${id}  ${description1}  ${aliasName}   ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Case Type Filter     
    Log   ${resp.content}

    ${resp}=    Get Case Type    ${id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id} 
    Should Be Equal As Strings    ${resp.json()['account']}     ${accountId} 
    Should Be Equal As Strings    ${resp.json()['name']}     ${description1}
    Should Be Equal As Strings    ${resp.json()['aliasName']}     ${aliasName}
    Should Be Equal As Strings    ${resp.json()['status']}     ${toggle[0]}

JD-TC-Update Case Type-3

    [Documentation]    Update Case type where alias name contain 255 words

    ${resp}=  Encrypted Provider Login    ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${description1}=  FakerLibrary.Text     	max_nb_chars=255

    ${resp}=    Update Case Type    ${id}  ${name}  ${description1}   ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Case Type Filter    
    Log   ${resp.content}

    ${resp}=    Get Case Type    ${id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id} 
    Should Be Equal As Strings    ${resp.json()['account']}     ${accountId} 
    Should Be Equal As Strings    ${resp.json()['name']}     ${name}
    Should Be Equal As Strings    ${resp.json()['aliasName']}     ${description1}
    Should Be Equal As Strings    ${resp.json()['status']}     ${toggle[0]}

JD-TC-Update Case Type-4

    [Documentation]    Update Case type where status is disabled

    ${resp}=  Encrypted Provider Login    ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${description1}=  FakerLibrary.Text     	max_nb_chars=200

    ${resp}=    Update Case Type    ${id}  ${name}  ${description1}   ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=    Get Case Type    ${id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id} 
    Should Be Equal As Strings    ${resp.json()['account']}     ${accountId} 
    Should Be Equal As Strings    ${resp.json()['name']}     ${name}
    Should Be Equal As Strings    ${resp.json()['aliasName']}     ${description1}
    Should Be Equal As Strings    ${resp.json()['status']}     ${toggle[1]}


JD-TC-Update Case Type-5

    [Documentation]    Update Case type where aliasname is empty

    ${resp}=  Encrypted Provider Login    ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

   ${resp}=    Update Case Type    ${id}  ${name}  ${empty}   ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Case Type    ${id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id} 
    Should Be Equal As Strings    ${resp.json()['account']}     ${accountId} 
    Should Be Equal As Strings    ${resp.json()['name']}     ${name}
    Should Be Equal As Strings    ${resp.json()['aliasName']}     ${empty}
    Should Be Equal As Strings    ${resp.json()['status']}     ${toggle[0]}


JD-TC-Update Case Type-6

    [Documentation]    Update Case type where name contain numbers

    ${resp}=  Encrypted Provider Login    ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title1}=  FakerLibrary.Random Number
    Set Suite Variable     ${title1}

    ${resp}=    Update Case Type    ${id}  ${title1}  ${aliasName}   ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Update Case Type-7

    [Documentation]    Update Case type where aliasname contain numbers

    ${resp}=  Encrypted Provider Login    ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200
    ${name1}=  FakerLibrary.name

    ${resp}=    Update Case Type    ${id}  ${name}  ${title1}   ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Update Case Type-8

    [Documentation]    Update Case type where name contain special characters

    ${resp}=  Encrypted Provider Login    ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

   ${resp}=    Update Case Type     ${id}  ${titles}  ${aliasName}   ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


JD-TC-Update Case Type-9

    [Documentation]    Update Case type where aliasname contain special characters

    ${resp}=  Encrypted Provider Login    ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${name1}=  FakerLibrary.name
     ${resp}=    Update Case Type    ${id}  ${name1}  ${titles}   ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Update Case Type-10

    [Documentation]    update already disabled case type

    ${resp}=  Encrypted Provider Login    ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200
      ${name1}=  FakerLibrary.name

    ${resp}=    Update Case Type    ${id}  ${name1}  ${aliasName}   ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Update Case Type     ${id}  ${name1}  ${aliasName}   ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Update Case Type-UH1

    [Documentation]    update case type with invalid id

    ${resp}=  Encrypted Provider Login    ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200
    ${id1}=  Random Int  min=101   max=471

    ${resp}=    Update Case Type    ${id1}  ${name}  ${aliasName}   ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.content}    "${INVALID_CASE_TYPE_ID}"

JD-TC-Update Case Type-UH2

    [Documentation]    Update Case type where name is empty

    ${resp}=  Encrypted Provider Login    ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Update Case Type   ${id}  ${empty}  ${description1}   ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.content}    "${NAME_REQUIRED}"

JD-TC-Update Case Type-UH3

    [Documentation]    Update Case type without login

    ${resp}=    Update Case Type     ${id}  ${name}  ${empty}   ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}
   

*** comment ***

JD-TC-Update Case Type-UH1

    [Documentation]    Update Case type with another provider login

    ${resp}=  Encrypted Provider Login    ${PUSERNAME13}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=   Update Case Type     ${id}  ${name}  ${empty}   ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  401
    Should Be Equal As Strings    ${resp.json()}   ${NO_PERMISSION}


