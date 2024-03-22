*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Task
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/musers.py
Resource          /ebs/TDD/Keywords.robot
Library           /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/hl_musers.py


*** Variables ***

@{emptylist} 
${jpgfile}      /ebs/TDD/uploadimage.jpg
${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf
${giffile}     /ebs/TDD/sample.gif
${jpegfile}     /ebs/TDD/large.jpeg
${shfile}     /ebs/TDD/example.sh
${docfile}     /ebs/TDD/docsample.doc
${txtfile}     /ebs/TDD/textsample.txt
${self}         0





*** Test Cases ***

JD-TC-UploadTaskAttachment-1

    [Documentation]  UploadTaskAttachment using Task Id.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME55}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id}=  get_acc_id  ${PUSERNAME55}
    Set Test Variable  ${p_id}

     ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
    
    ${resp}=  categorytype  ${p_id}
    ${resp}=  tasktype      ${p_id}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${category_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${category_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${type_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${type_name1}  ${resp.json()[0]['name']}

    ${title}=  FakerLibrary.user name
    Set Suite Variable   ${title}
    ${desc}=   FakerLibrary.word 
    Set Suite Variable    ${desc}

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id1}  ${task_id[0]}
    Set Test Variable  ${task_uid1}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid1} 
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}

    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME55}    ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${caption1}=  Fakerlibrary.Sentence
    ${attachements1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
       
    ${caption2}=  Fakerlibrary.Sentence
    ${attachements2}=  Create Dictionary   file=${pdffile}   caption=${caption1}
     
   # @{fileswithcaption}=  Create List    ${attachements1}    ${attachements2}
    ${resp}=    Imageupload.uploadTaskAttachment     ${cookie}   ${task_uid1}      ${attachements1}  ${attachements2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid1} 
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
     Should Contain     "${resp.json()}"    jpg
    Should Contain     "${resp.json()}"     pdf
  
  
   
    

# JD-TC-UploadTaskAttachment-2

#     [Documentation]  Upload task Attachment for a consumer

#     ${resp}=   Encrypted Provider Login  ${PUSERNAME90}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${p_id}=  get_acc_id  ${PUSERNAME90}
#     Set Test Variable   ${p_id}

#     ${resp}=    Get Locations
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     IF   '${resp.content}' == '${emptylist}'
#         ${locId}=  Create Sample Location
#     ELSE
#         Set Test Variable  ${locId}  ${resp.json()[0]['id']}
#     END
    
#     ${resp}=  categorytype  ${p_id}
#     ${resp}=  tasktype      ${p_id}
#     ${resp}=    Get Task Category Type
#     Log   ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${category_id1}    ${resp.json()[0]['id']}
#     Set Test Variable  ${category_name1}  ${resp.json()[0]['name']}

#     ${resp}=    Get Task Type
#     Log   ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${type_id1}    ${resp.json()[0]['id']}
#     Set Suite Variable  ${type_name1}  ${resp.json()[0]['name']}

#     ${title}=  FakerLibrary.user name
#     Set Test Variable   ${title}

#     ${desc}=   FakerLibrary.word 
#     Set Test Variable  ${desc}


#     ${resp}=    Create Task   ${title}  ${desc}   ${userType[3]}  ${category_id1}  ${type_id1}   ${locId}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${task_id}=  Get Dictionary Values  ${resp.json()}
#     Set Test Variable  ${task_id1}  ${task_id[0]}
#     Set Test Variable  ${task_uid1}  ${task_id[1]}

#     ${resp}=   Get Task By Id   ${task_uid1}
#     Log   ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id1}
#     Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid1}
#     Should Be Equal As Strings  ${resp.json()['accountId']}             ${p_id}
#     Should Be Equal As Strings  ${resp.json()['title']}                ${title}
#     Should Be Equal As Strings  ${resp.json()['description']}          ${desc}
#     Should Be Equal As Strings  ${resp.json()['category']['id']}         ${category_id1} 
#     Should Be Equal As Strings  ${resp.json()['type']['id']}             ${type_id1}
#     Should Be Equal As Strings  ${resp.json()['location']['id']}         ${locId}
    
#     ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME90}    ${PASSWORD}
#     Log     ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}     200

#      ${caption1}=  Fakerlibrary.Sentence
#      ${attachements1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
       
#     ${caption2}=  Fakerlibrary.Sentence
#     ${attachements2}=  Create Dictionary   file=${pdffile}   caption=${caption1}
     
#     @{fileswithcaption}=  Create List    ${attachements1}    ${attachements2}
#     ${resp}=    Imageupload.uploadTaskAttachment     ${cookie}   ${task_uid1}     @{fileswithcaption}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get Task By Id   ${task_uid1}
#     Log   ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['id']}                ${task_id1}
#     Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid1} 
#     Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
#     Should Be Equal As Strings  ${resp.json()['title']}               ${title}
#     Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
#     Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
#     Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
#     Should Be Equal As Strings  ${resp.json()['attachments'][0]['type']}        jpg
#     Should Be Equal As Strings  ${resp.json()['attachments'][0]['size']}        0.223
#     Should Be Equal As Strings  ${resp.json()['attachments'][1]['type']}        pdf
#     Should Be Equal As Strings  ${resp.json()['attachments'][1]['size']}        0.003
    
    
JD-TC-UploadTaskAttachment-3

    [Documentation]  png file UploadTaskAttachment using Task Id.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME60}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id}=  get_acc_id  ${PUSERNAME60}
    Set Suite Variable  ${p_id}

     ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
    
      ${resp}=  categorytype  ${p_id}
    ${resp}=  tasktype      ${p_id}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${category_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${category_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${type_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${type_name1}  ${resp.json()[0]['name']}

    ${title}=  FakerLibrary.user name
    Set Suite Variable   ${title}
    ${desc}=   FakerLibrary.word 
    Set Suite Variable    ${desc}

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${task_id1}  ${task_id[0]}
    Set Suite Variable  ${task_uid1}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid1} 
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}

    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME60}    ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${caption1}=  Fakerlibrary.Sentence
    ${attachements1}=  Create Dictionary   file=${pngfile}   caption=${caption1}
       
    ${caption2}=  Fakerlibrary.Sentence
    ${attachements2}=  Create Dictionary   file=${pngfile}   caption=${caption1}
     
    @{fileswithcaption}=   Create List    ${attachements1}    ${attachements2}
    ${resp}=    Imageupload.uploadTaskAttachment     ${cookie}    ${task_uid1}     @{fileswithcaption}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid1} 
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
    Should Contain     "${resp.json()}"    png
    Should Contain     "${resp.json()}"     0.171
  

    

JD-TC-UploadTaskAttachment-4

    [Documentation]  gif file UploadTaskAttachment using Task Id.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME60}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
     
    clear_Providermsg   ${PUSERNAME60}

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid1} 

    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME60}    ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${caption1}=  Fakerlibrary.Sentence
    ${attachements1}=  Create Dictionary   file=${giffile}   caption=${caption1}

    ${resp}=    Imageupload.uploadTaskAttachment     ${cookie}    ${task_uid1}      ${attachements1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid1} 
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
    Should Contain     "${resp.json()}"     gif
    Should Contain     "${resp.json()}"     1.009

JD-TC-UploadTaskAttachment-5

    [Documentation]  doc file UploadTaskAttachment using Task Id.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME60}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
     
    clear_Providermsg   ${PUSERNAME60}

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid1} 

    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME60}    ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${caption1}=  Fakerlibrary.Sentence
    ${attachements1}=  Create Dictionary   file=${docfile}   caption=${caption1}

    ${resp}=    Imageupload.uploadTaskAttachment     ${cookie}    ${task_uid1}      ${attachements1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid1} 
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
    Should Contain     "${resp.json()}"     doc
    Should Contain     "${resp.json()}"     0.096


JD-TC-UploadTaskAttachment-UH1

    [Documentation]   With  consumer  login  upload attachment

    ${cookie}  ${resp}=  Imageupload.conLogin   ${CUSERNAME3}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${caption1}=  Fakerlibrary.Sentence
    ${attachements1}=  Create Dictionary   file=${giffile}   caption=${caption1}

    ${resp}=    Imageupload.uploadTaskAttachment     ${cookie}    ${task_uid1}      ${attachements1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}" 

    
JD-TC-UploadTaskAttachment-UH2

    [Documentation]   invalid task-userid

    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME62}    ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${INVALID_TASK}=   Replace String  ${INVALID_TASK_UID}  {}  activity

    ${caption1}=  Fakerlibrary.Sentence
    ${attachements1}=  Create Dictionary   file=${giffile}   caption=${caption1}

    ${resp}=    Imageupload.uploadTaskAttachment     ${cookie}    899     ${attachements1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_TASK} 



JD-TC-UploadTaskAttachment-UH3

    [Documentation]   empty attachment

    
    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME60}    ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200

  
    ${resp}=    Imageupload.uploadTaskAttachment     ${cookie}    ${task_uid1}     ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${ATTACHMENT_NOT_FOUND} 


JD-TC-UploadTaskAttachment-6

    [Documentation]  Upload Multiple Task Attachment 

    ${resp}=   Encrypted Provider Login  ${PUSERNAME55}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id}=  get_acc_id  ${PUSERNAME55}
    Set Test Variable  ${p_id}

     ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
    
    ${resp}=  categorytype  ${p_id}
    ${resp}=  tasktype      ${p_id}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${category_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${category_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${type_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${type_name1}  ${resp.json()[0]['name']}

    ${title}=  FakerLibrary.user name
    Set Suite Variable   ${title}
    ${desc}=   FakerLibrary.word 
    Set Suite Variable    ${desc}

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id1}  ${task_id[0]}
    Set Test Variable  ${task_uid1}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid1} 
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}

    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME55}    ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${caption1}=  Fakerlibrary.Sentence
    ${attachements1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
       
    ${caption2}=  Fakerlibrary.Sentence
    ${attachements2}=  Create Dictionary   file=${pdffile}   caption=${caption1}
     
   # @{fileswithcaption}=  Create List    ${attachements1}    ${attachements2}
    ${resp}=    Imageupload.uploadTaskAttachment     ${cookie}   ${task_uid1}      ${attachements1}  ${attachements2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid1} 
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
     Should Contain     "${resp.json()}"    jpg
    Should Contain     "${resp.json()}"     pdf

    ${attachements1a}=  Create Dictionary   file=${jpegfile}   caption=${caption1}

    ${resp}=    Imageupload.uploadTaskAttachment     ${cookie}   ${task_uid1}      ${attachements1a}  ${attachements2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid1} 
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
     Should Contain     "${resp.json()}"    jpeg
    Should Contain     "${resp.json()}"     pdf
  

JD-TC-UploadTaskAttachment-7

    [Documentation]  Upload same file multiple times to a task.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME55}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id}=  get_acc_id  ${PUSERNAME55}
    Set Test Variable  ${p_id}

     ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
    
      ${resp}=  categorytype  ${p_id}
    ${resp}=  tasktype      ${p_id}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${category_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${category_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${type_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${type_name1}  ${resp.json()[0]['name']}

    ${title}=  FakerLibrary.user name
    Set Suite Variable   ${title}
    ${desc}=   FakerLibrary.word 
    Set Suite Variable    ${desc}

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id2}  ${task_id[0]}
    Set Test Variable  ${task_uid2}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid2} 
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}

    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME55}    ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${caption1}=  Fakerlibrary.Sentence
    ${attachements1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
       
    ${caption2}=  Fakerlibrary.Sentence
    ${attachements2}=  Create Dictionary   file=${pdffile}   caption=${caption1}
     
   # @{fileswithcaption}=  Create List    ${attachements1}    ${attachements2}
    ${resp}=    Imageupload.uploadTaskAttachment     ${cookie}   ${task_uid2}      ${attachements1}  ${attachements2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid2} 
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
    Should Contain     "${resp.json()}"    jpg
    Should Contain     "${resp.json()}"     pdf

    ${resp}=    Imageupload.uploadTaskAttachment     ${cookie}   ${task_uid2}      ${attachements1}  ${attachements2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid2} 
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
    Should Contain     "${resp.json()}"    jpg
    Should Contain     "${resp.json()}"     pdf


JD-TC-UploadTaskAttachment-8

    [Documentation]  Upload a file to a subtask.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME61}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id}=  get_acc_id  ${MUSERNAME61}
    Set Suite Variable   ${p_id}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
    
    ${resp}=  categorytype  ${p_id}
    ${resp}=  tasktype      ${p_id}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${category_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${category_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${type_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${type_name1}  ${resp.json()[0]['name']}

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id1}  ${task_id[0]}
    Set Suite Variable  ${task_uid1}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${p_id}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]
    
    ${resp}=    Create SubTask   ${task_uid1}  ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id2}  ${task_id[0]}
    Set Test Variable  ${task_uid2}  ${task_id[1]}
    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${p_id}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['originUid']}      ${task_uid1}
    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid2}

    ${cookie}   ${resp}=    Imageupload.spLogin     ${MUSERNAME61}    ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${caption1}=  Fakerlibrary.Sentence
    ${attachements1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
       
    ${caption2}=  Fakerlibrary.Sentence
    ${attachements2}=  Create Dictionary   file=${pdffile}   caption=${caption1}
     
   # @{fileswithcaption}=  Create List    ${attachements1}    ${attachements2}
    ${resp}=    Imageupload.uploadTaskAttachment     ${cookie}   ${task_uid2}      ${attachements1}  ${attachements2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid2} 
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
    Should Contain     "${resp.json()}"    jpg
    Should Contain     "${resp.json()}"     pdf


JD-TC-UploadTaskAttachment-9

    [Documentation]  Upload a file by branch for a users task.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
    END
    FOR   ${i}  IN RANGE   0   ${len}
       
        Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
        IF   not '${user_phone}' == '${HLMUSERNAME0}'
            clear_users  ${user_phone}
        END
    END
    
    ${u_id}=  Create Sample User 
    Set Suite Variable  ${u_id}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${PUSERNAME_U1}  ${resp.json()['mobileNo']}

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${u_id1}=  Create Sample User 
    Set Suite Variable  ${u_id1}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${PUSERNAME_U2}  ${resp.json()['mobileNo']}

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U2}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U2}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id}=  get_acc_id  ${PUSERNAME_U1}
    Set Suite Variable   ${p_id}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
    
    ${resp}=  categorytype  ${p_id}
    ${resp}=  tasktype      ${p_id}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${category_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${category_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${type_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${type_name1}  ${resp.json()[0]['name']}

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id1}  ${task_id[0]}
    Set Suite Variable  ${task_uid1}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${p_id}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]

    ${cookie}   ${resp}=    Imageupload.spLogin     ${HLMUSERNAME0}    ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${caption1}=  Fakerlibrary.Sentence
    ${attachements1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
       
    ${caption2}=  Fakerlibrary.Sentence
    ${attachements2}=  Create Dictionary   file=${pdffile}   caption=${caption1}
     
   # @{fileswithcaption}=  Create List    ${attachements1}    ${attachements2}
    ${resp}=    Imageupload.uploadTaskAttachment     ${cookie}   ${task_uid1}      ${attachements1}  ${attachements2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid1} 
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
    Should Contain     "${resp.json()}"    jpg
    Should Contain     "${resp.json()}"     pdf




JD-TC-UploadTaskAttachment-10

    [Documentation]  Upload a file by a user to another users task.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id3}  ${task_id[0]}
    Set Suite Variable  ${task_uid3}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${p_id}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]

    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME_U1}    ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${caption1}=  Fakerlibrary.Sentence
    ${attachements1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
       
    ${caption2}=  Fakerlibrary.Sentence
    ${attachements2}=  Create Dictionary   file=${pdffile}   caption=${caption1}
     
   # @{fileswithcaption}=  Create List    ${attachements1}    ${attachements2}
    ${resp}=    Imageupload.uploadTaskAttachment     ${cookie}   ${task_uid3}      ${attachements1}  ${attachements2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                ${task_id3}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid3} 
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
    Should Contain     "${resp.json()}"    jpg
    Should Contain     "${resp.json()}"     pdf



JD-TC-UploadTaskAttachment-11

    [Documentation]  try to upload a file for a closed task.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME55}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id}=  get_acc_id  ${PUSERNAME55}
    Set Test Variable  ${p_id}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
    
    ${resp}=  categorytype  ${p_id}
    ${resp}=  tasktype      ${p_id}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${category_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${category_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${type_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${type_name1}  ${resp.json()[0]['name']}
    
    ${resp}=    Get Task Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${status_name1}  ${resp.json()[0]['name']}
    Set Suite Variable  ${status_name2}  ${resp.json()[4]['name']}

    ${title}=  FakerLibrary.user name
    Set Suite Variable   ${title}
    ${desc}=   FakerLibrary.word 
    Set Suite Variable    ${desc}

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id11}  ${task_id[0]}
    Set Test Variable  ${task_uid11}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid11}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']['name']}    ${status_name1}
    Should Be Equal As Strings  ${resp.json()['id']}                ${task_id11}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid11} 
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}

    ${resp}=    Change User Task Status Closed  ${task_uid11}  
    Log      ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=   Get Task By Id   ${task_uid11}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']['name']}    ${status_name2}


JD-TC-UploadTaskAttachment-12

    [Documentation]  Upload a file by branch after assign it to a user.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id1}  ${task_id[0]}
    Set Suite Variable  ${task_uid1}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${p_id}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]

    ${resp}=    Change Assignee    ${task_uid1}    ${u_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()['assignee']['id']}                ${u_id1}

    ${cookie}   ${resp}=    Imageupload.spLogin     ${HLMUSERNAME0}    ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${caption1}=  Fakerlibrary.Sentence
    ${attachements1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
       
    ${caption2}=  Fakerlibrary.Sentence
    ${attachements2}=  Create Dictionary   file=${pdffile}   caption=${caption1}
     
   # @{fileswithcaption}=  Create List    ${attachements1}    ${attachements2}
    ${resp}=    Imageupload.uploadTaskAttachment     ${cookie}   ${task_uid1}      ${attachements1}  ${attachements2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid1} 
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
    Should Contain     "${resp.json()}"    jpg
    Should Contain     "${resp.json()}"     pdf




JD-TC-UploadTaskAttachment-13
    [Documentation]  create a task and then disable task in account settings then try to upload a file to that task.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME61}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id}=  get_acc_id  ${MUSERNAME61}
    Set Suite Variable   ${p_id}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
    
    ${resp}=  categorytype  ${p_id}
    ${resp}=  tasktype      ${p_id}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${category_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${category_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${type_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${type_name1}  ${resp.json()[0]['name']}

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id13}  ${task_id[0]}
    Set Suite Variable  ${task_uid13}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid13}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${p_id}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['enableCrm']}==${bool[1]}   Enable Disable CRM  ${toggle[1]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}   ${resp}=    Imageupload.spLogin     ${MUSERNAME61}    ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${caption1}=  Fakerlibrary.Sentence
    ${attachements1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
       
    ${caption2}=  Fakerlibrary.Sentence
    ${attachements2}=  Create Dictionary   file=${pdffile}   caption=${caption1}
     
   # @{fileswithcaption}=  Create List    ${attachements1}    ${attachements2}
    ${resp}=    Imageupload.uploadTaskAttachment     ${cookie}   ${task_uid13}      ${attachements1}  ${attachements2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid13}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                ${task_id13}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid13} 
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
    Should Contain     "${resp.json()}"    jpg
    Should Contain     "${resp.json()}"     pdf





    
    




  
       

