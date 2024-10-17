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

JD-TC-Get Case Type Filter-1

    [Documentation]    Get Case Type Filter

    ${resp}=  Encrypted Provider Login    ${PUSERNAME21}  ${PASSWORD}
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
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

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

JD-TC-Get Case Type Filter-2

    [Documentation]    Update Case type where name contain 250 words  and  Get Case Type Filter

    ${resp}=  Encrypted Provider Login    ${PUSERNAME21}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${description1}=  FakerLibrary.Text     	max_nb_chars=250

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

JD-TC-Get Case Type Filter-3

    [Documentation]    Update Case type where alias name contain 250 words  and Get Case Type Filter

    ${resp}=  Encrypted Provider Login    ${PUSERNAME21}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${description1}=  FakerLibrary.Text     	max_nb_chars=250

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


JD-TC-Get Case Category Filter-UH1

    [Documentation]    Get Case Type Filter with another provider login

    ${resp}=  Encrypted Provider Login    ${PUSERNAME13}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

     ${resp}=    Get Case Type Filter    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # Should Be Equal As Strings    ${resp.status_code}  401
    # Should Be Equal As Strings    ${resp.json()}   ${NO_PERMISSION}


JD-TC-Get Case Category Filter-UH2

    [Documentation]  Get Case Type Filter without login

    ${resp}=   Get Case Type Filter    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}