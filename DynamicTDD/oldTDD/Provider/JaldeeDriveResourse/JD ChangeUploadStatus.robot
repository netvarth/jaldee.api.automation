***Settings***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        User
Library           Collections
Library           String
Library           json
Library           OperatingSystem
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Library           /ebs/TDD/db.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables          /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/Keywords.robot
Library           /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/SuperAdminKeywords.robot


*** Variables ***

@{countryCode}   91  +91  48 
@{folderName}      privateFolder     publicFolder
${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf
${giffile}     /ebs/TDD/sample.gif
${jpegfile}     /ebs/TDD/large.jpeg
${shfile}     /ebs/TDD/example.sh
${docfile}     /ebs/TDD/docsample.doc
${txtfile}     /ebs/TDD/textsample.txt
${self}         0
${count}       ${5}
#@{owner}     1  2  3  4  5  6
#@{order}     0  1  2  3  4  5 
@{ownerType}         Provider  ProviderConsumer 
${filesize}    0.0084
***Test Cases***

JD-TC-ChangeUploadStatus-1

    [Documentation]     file upload to private folder and change it status.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${acc_id}=  get_acc_id  ${PUSERNAME111}
    Set Test Variable     ${acc_id}
    ${id}=  get_id  ${PUSERNAME111}
    Set Suite Variable  ${id}
   

    ${caption1}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}

    #Set Text Variable  ${data.json}
    ${list1}=  Create Dictionary         owner=${id}   fileName=${jpegfile}    fileSize=${filesize}     caption=${caption1}     fileType=${fileType}   order=0
    ${list}=   Create List     ${list1}
    ${resp}=    Upload To Private Folder      privateFolder    ${id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log        ${resp.content}
   
    ${resp}=   Get by Criteria           owner-eq=${id}
    Log                                 ${resp.content}
    Set Suite Variable     ${fileid1}       ${resp.json()['${id}']['files'][0]['id']} 
    Should Be Equal As Strings     ${resp.json()['${id}']['files'][0]['account']}       ${acc_id}
    Should Be Equal As Strings     ${resp.json()['${id}']['files'][0]['sharedType']}    ${sharedType[0]}
    Should Be Equal As Strings     ${resp.json()['${id}']['files'][0]['uploadStatus']}  ${QnrStatus[0]}
     
    ${resp}=    Change Upload Status    COMPLETE    ${fileid1} 
    Log                                        ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=   Get by Criteria           owner-eq=${id}
    Log                                 ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings     ${resp.json()['${id}']['files'][0]['uploadStatus']}  ${QnrStatus[1]}
  
JD-TC-ChangeUploadStatus-2
   
    [Documentation]    Change upload status by user

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${HLPUSERNAME4}
    Set Test Variable  ${HLPUSERNAME4}
    ${id}=  get_id  ${HLPUSERNAME4}
    Set Test Variable  ${id}
     
    ${resp}=   Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    

     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     
     
    FOR  ${p}  IN RANGE  5
        ${ran int}=    Generate Random String    length=4    chars=[NUMBERS]
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To String  ${ran int}
        ${Status}=   Run Keyword And Return Status   Should Match Regexp	${ran int}	\\d{4}
        Exit For Loop IF  ${Status}  
    END
    ${ran int}=    Convert To Integer    ${ran int}
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+${ran int}
    Set Suite Variable  ${PUSERNAME_U1}
    clear_users  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    Set Test Variable  ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Test Variable  ${lastname1}
    ${dob1}=  FakerLibrary.Date
    Set Test Variable  ${dob1}
    ${pin1}=  get_pincode
    Set Test Variable  ${pin1}

    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

   

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_id}   ${resp.json()[0]['id']}
   
    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



    ${p_id}=  get_acc_id  ${HLPUSERNAME4}
    Set Test Variable   ${p_id}

    ${caption1}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${pdffile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${pdffile}
    Set Test Variable    ${fileType5}

    ${list1}=  Create Dictionary         owner=${p1_id}   fileName=${pdffile}    fileSize=${filesize}    caption=${caption1}     fileType=${fileType5}   order=11
    ${list}=   Create List     ${list1}
    ${resp}=    Upload To Private Folder       privateFolder    ${p1_id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
   
  
    ${resp}=   Get by Criteria                 fileType-eq=.pdf
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
    Should Be Equal As Strings                 ${resp.json()['${p1_id}']['files'][0]['account']}       ${p_id}  
    Should Be Equal As Strings                 ${resp.json()['${p1_id}']['files'][0]['owner']}         ${p1_id}  
    Should Be Equal As Strings                 ${resp.json()['${p1_id}']['files'][0]['fileType']}      ${fileType5}
    Should Be Equal As Strings                 ${resp.json()['${p1_id}']['files'][0]['ownerType']}     ${ownerType[0]}  
    Should Be Equal As Strings                 ${resp.json()['${p1_id}']['files'][0]['sharedType']}    ${sharedType[0]}
    Should Be Equal As Strings                 ${resp.json()['${p1_id}']['files'][0]['uploadStatus']}  ${QnrStatus[0]}
    Set Suite Variable                         ${fileid2}                         ${resp.json()['${p1_id}']['files'][0]['id']} 
  
    ${resp}=    Change Upload Status    COMPLETE    ${fileid2} 
    Log                                        ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=   Get by Criteria           owner-eq=${p1_id}
    Log                                 ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings     ${resp.json()['${p1_id}']['files'][0]['uploadStatus']}  ${QnrStatus[1]}
   
JD-TC-ChangeUploadStatus-3
   
    [Documentation]   upload file by branch and  Change upload status by user login

   
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${HLPUSERNAME4}
    Set Test Variable    ${HLPUSERNAME4}
    ${id}=  get_id       ${HLPUSERNAME4}
    Set Test Variable    ${id}
   

    ${caption1}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${pdffile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${pdffile}
    Set Test Variable    ${fileType5}

    ${list1}=  Create Dictionary         owner=${id}   fileName=${pdffile}    fileSize=${filesize}    caption=${caption1}     fileType=${fileType5}   order=11
    ${list}=   Create List     ${list1}
    ${resp}=    Upload To Private Folder       privateFolder     ${id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
   
  
    ${resp}=   Get by Criteria                 fileType-eq=.pdf
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                  200
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['account']}         ${p_id}  
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['fileType']}        ${fileType5}
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['ownerType']}       ${ownerType[0]}  
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['sharedType']}      ${sharedType[0]}  
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['uploadStatus']}    ${QnrStatus[0]}
    Set Suite Variable                         ${fileid3}                           ${resp.json()['${id}']['files'][0]['id']} 
  
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Change Upload Status    COMPLETE    ${fileid3} 
    Log                                        ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get by Criteria          account-eq=${pid}
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}                  200
    Should Be Equal As Strings          ${resp.json()['${id}']['files'][0]['uploadStatus']}    ${QnrStatus[1]}
   
  
JD-TC-ChangeUploadStatus-4
   
    [Documentation]   upload file by user and  Change upload status by branch login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    # ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${pid}=  get_acc_id  ${HLPUSERNAME4}
    # Set Test Variable    ${HLPUSERNAME4}
    # ${id}=  get_id       ${HLPUSERNAME4}
    # Set Test Variable    ${id}
   

    ${caption4}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${docfile}
    Log  ${resp}
    ${fileType6}=  Get From Dictionary       ${resp}    ${docfile}
    Set Test Variable    ${fileType6}

    ${list1}=  Create Dictionary         owner=${u_id1}   fileName=${docfile}    fileSize=${filesize}     caption=${caption4}     fileType=${fileType6}   order=11
    ${list}=   Create List     ${list1}
    ${resp}=    Upload To Private Folder       privateFolder      ${u_id1}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
   
  
    ${resp}=   Get by Criteria                 fileType-eq=${fileType6}
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                  200
    Should Be Equal As Strings                 ${resp.json()['${u_id1}']['files'][0]['fileType']}        ${fileType6}
    Should Be Equal As Strings                 ${resp.json()['${u_id1}']['files'][0]['ownerType']}       ${ownerType[0]}  
    Should Be Equal As Strings                 ${resp.json()['${u_id1}']['files'][0]['sharedType']}      ${sharedType[0]}  
    Should Be Equal As Strings                 ${resp.json()['${u_id1}']['files'][0]['uploadStatus']}    ${QnrStatus[0]}
    Set Suite Variable                         ${fileid33}                          ${resp.json()['${u_id1}']['files'][0]['id']} 
  
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${HLPUSERNAME4}
    # Set Test Variable    ${HLPUSERNAME4}
  
  
    ${resp}=    Change Upload Status    COMPLETE    ${fileid33} 
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}    200

    ${resp}=   Get by Criteria          owner-eq=${u_id1}
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}                200
    Should Be Equal As Strings          ${resp.json()['${u_id1}']['files'][0]['uploadStatus']}  ${QnrStatus[1]}
   
  
JD-TC-ChangeUploadStatus-UH1
  
    [Documentation]    without login
    
    ${resp}=    Change Upload Status    COMPLETE    ${fileid1} 
    Log                              ${resp.content}
    Should Be Equal As Strings       ${resp.status_code}             419
    Should Be Equal As Strings       "${resp.json()}"               "${SESSION_EXPIRED}"
 
JD-TC-ChangeUploadStatus-UH2
  
    [Documentation]    consumer login
    
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME5}
    ${caption1}=  Fakerlibrary.Sentence
  
    ${resp}=    Change Upload Status    COMPLETE           ${fileid1} 
    Log                                                    ${resp.content}
    Should Be Equal As Strings           ${resp.status_code}        401
    Should Be Equal As Strings           ${resp.json()}             ${LOGIN_NO_ACCESS_FOR_URL}
  

JD-TC-ChangeUploadStatus-5
  
    [Documentation]    status change complete to complete

    ${resp}=  Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${p_id12}=  get_acc_id  ${PUSERNAME120}
    #Set Test Variable  ${HLPUSERNAME4}
    ${id12}=  get_id  ${PUSERNAME120}
    Set Test Variable  ${id12}
    
  
   
    ${caption2}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}

    #Set Text Variable  ${data.json}
    ${list1}=  Create Dictionary         owner=${id12}   fileName=${jpegfile}    fileSize=${filesize}     caption=${caption2}     fileType=${fileType}   order=0
    ${list}=   Create List     ${list1}
    ${resp}=    Upload To Private Folder      privateFolder    ${id12}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
    
    ${resp}=   Get by Criteria     account-eq=${p_id12}
    Log                            ${resp.content}
    Set Suite Variable             ${fileid12}            ${resp.json()['${id12}']['files'][0]['id']} 
    Should Be Equal As Strings     ${resp.json()['${id12}']['files'][0]['account']}         ${p_id12}
    Should Be Equal As Strings     ${resp.json()['${id12}']['files'][0]['sharedType']}      ${sharedType[0]}
    Should Be Equal As Strings     ${resp.json()['${id12}']['files'][0]['uploadStatus']}    ${QnrStatus[0]}
     

    ${resp}=    Change Upload Status    COMPLETE    ${fileid12} 
    Log                                        ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get by Criteria           account-eq=${p_id12}
    Log                                 ${resp.content}
    Should Be Equal As Strings     ${resp.json()['${id12}']['files'][0]['uploadStatus']}  ${QnrStatus[1]}
   

    ${resp}=    Change Upload Status    COMPLETE    ${fileid12} 
    Log                                        ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get by Criteria           account-eq=${p_id12}
    Log                                 ${resp.content}
    Should Be Equal As Strings     ${resp.json()['${id12}']['files'][0]['uploadStatus']}  ${QnrStatus[1]}
   
   
JD-TC-ChangeUploadStatus-UH3
  
    [Documentation]    status change complete to incomplete

    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${p_id22}=  get_acc_id  ${PUSERNAME122}
    #Set Test Variable  ${HLPUSERNAME4}
    ${id22}=  get_id  ${PUSERNAME122}
    Set Test Variable  ${id22}
    

   
    ${caption3}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}

    #Set Text Variable  ${data.json}
    ${list1}=  Create Dictionary         owner=${id22}    fileName=${jpegfile}    fileSize=${filesize}     caption=${caption3}     fileType=${fileType}   order=0
    ${list}=   Create List     ${list1}
    ${resp}=    Upload To Private Folder      privateFolder    ${id22}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
    
    ${resp}=   Get by Criteria           account-eq=${p_id22}
    Log                                 ${resp.content}
    Set Suite Variable     ${fileid22}       ${resp.json()['${id22}']['files'][0]['id']} 
    Should Be Equal As Strings     ${resp.json()['${id22}']['files'][0]['account']}       ${p_id22}
    Should Be Equal As Strings     ${resp.json()['${id22}']['files'][0]['sharedType']}    ${sharedType[0]}
    Should Be Equal As Strings     ${resp.json()['${id22}']['files'][0]['uploadStatus']}  ${QnrStatus[0]}
     
   

    ${resp}=    Change Upload Status    COMPLETE    ${fileid22} 
    Log                            ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Get by Criteria     account-eq=${p_id22}
    Log                            ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}                200
    Should Be Equal As Strings     ${resp.json()['${id22}']['files'][0]['uploadStatus']}  ${QnrStatus[1]}
   
    ${resp}=    Change Upload Status     ${QnrStatus[0]}        ${fileid22} 
    Log                                  ${resp.content}
    Should Be Equal As Strings           ${resp.status_code}    422
    Should Be Equal As Strings           ${resp.json()}         ${S3_UPLOAD_FAILED}

    

    ${resp}=   Get by Criteria              account-eq=${p_id22}
    Log                                     ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}                 200
    Should Be Equal As Strings              ${resp.json()['${id22}']['files'][0]['uploadStatus']}   ${QnrStatus[1]}
   

JD-TC-ChangeUploadStatus-UH4
  
    [Documentation]    status change another provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME128}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${p_id44}=  get_acc_id  ${PUSERNAME128}
    #Set Test Variable  ${HLPUSERNAME4}
    ${id44}=  get_id  ${PUSERNAME128}
    Set Test Variable  ${id44}
    
    ${caption3}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}

    #Set Text Variable  ${data.json}
    ${list1}=  Create Dictionary         owner=${id44}    fileName=${jpegfile}    fileSize=${filesize}     caption=${caption3}     fileType=${fileType}   order=0
    ${list}=   Create List     ${list1}
    ${resp}=    Upload To Private Folder      privateFolder    ${id44}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
    
    ${resp}=   Get by Criteria     account-eq=${p_id44}
    Log                            ${resp.content}
    Set Suite Variable             ${fileid44}                        ${resp.json()['${id44}']['files'][0]['id']} 
    Should Be Equal As Strings     ${resp.json()['${id44}']['files'][0]['account']}       ${p_id44}
    Should Be Equal As Strings     ${resp.json()['${id44}']['files'][0]['sharedType']}    ${sharedType[0]}
    Should Be Equal As Strings     ${resp.json()['${id44}']['files'][0]['uploadStatus']}  ${QnrStatus[0]}
     
   
    ${resp}=  Encrypted Provider Login            ${PUSERNAME167}        ${PASSWORD}
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}    200
    
    ${resp}=    Change Upload Status    ${QnrStatus[1]}        ${fileid44} 
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}    401
    Should Be Equal As Strings           ${resp.json()}         ${NO_PERMISSION}

JD-TC-ChangeUploadStatus-6

    [Documentation]   upload file by user  status change another user login (same branch)

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${HLPUSERNAME4}
    Set Test Variable  ${HLPUSERNAME4}
    ${id}=  get_id  ${HLPUSERNAME4}
    Set Test Variable  ${id}
     
    ${resp}=   Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

 
     
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}

    ${usr_id}=  Create List
    Set Suite Variable   ${usr_id}

    ${PUsrNm}=  Create List 
    Set Suite Variable  ${PUsrNm}

    FOR   ${a}  IN RANGE   2

        ${userid}=  Create Sample User
        Set Test Variable  ${userid${a}}  ${userid}

        ${resp}=  Get User By Id        ${userid${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings      ${resp.status_code}  200
        Set Suite Variable      ${PUSERNAME_${a}}     ${resp.json()['mobileNo']}

        Append To List   ${usr_id}  ${userid${a}}
        Append To List   ${PUsrNm}  ${PUSERNAME_${a}}
    END

    Log  ${PUsrNm}

    ${resp}=  SendProviderResetMail   ${PUsrNm[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUsrNm[0]}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUsrNm[0]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${u_idA}     ${resp.json()['id']}

    ${resp}=    Get User By Id      ${uidA}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    Set Suite Variable      ${fname1}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname1}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId1}   ${resp.json()['employeeId']}
    
    ${caption1}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${docfile}
    Log  ${resp}
    ${fileType51}=  Get From Dictionary       ${resp}    ${docfile}
    Set Test Variable    ${fileType51}

    ${list1}=  Create Dictionary         owner=${uidA}  fileName=${docfile}    fileSize=${filesize}    caption=${caption1}     fileType=${fileType51}   order=113
    ${list}=   Create List     ${list1}
    ${resp}=    Upload To Private Folder       privateFolder    ${uidA}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
   
  
    ${resp}=   Get by Criteria                 owner-eq=${uidA} 
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
    Should Be Equal As Strings                 ${resp.json()['${uidA}']['files'][0]['account']}       ${p_id}  
    Should Be Equal As Strings                 ${resp.json()['${uidA}']['files'][0]['owner']}         ${uidA} 
    Should Be Equal As Strings                 ${resp.json()['${uidA}']['files'][0]['fileType']}      ${fileType51}
    Should Be Equal As Strings                 ${resp.json()['${uidA}']['files'][0]['ownerType']}     ${ownerType[0]}  
    Should Be Equal As Strings                 ${resp.json()['${uidA}']['files'][0]['sharedType']}    ${sharedType[0]}
    Should Be Equal As Strings                 ${resp.json()['${uidA}']['files'][0]['uploadStatus']}   ${QnrStatus[0]}
    Set Suite Variable                         ${fileid51}                         ${resp.json()['${uidA}']['files'][0]['id']} 
  
  
    ${resp}=  SendProviderResetMail   ${PUsrNm[1]}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUsrNm[1]}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUsrNm[1]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${u_idB}     ${resp.json()['id']}

    ${resp}=    Get User By Id      ${uidB}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Change Upload Status    COMPLETE    ${fileid51} 
    Log                                        ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=   Get by Criteria           owner-eq=${uidA} 
    Log                                 ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings     ${resp.json()['${uidA}']['files'][0]['uploadStatus']}  ${QnrStatus[1]}
   