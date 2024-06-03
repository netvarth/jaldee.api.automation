***Settings***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        User
Library           Collections
Library           String
Library           json
Library           OperatingSystem
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py




*** Variables ***
@{countryCode}   91  +91  48 
${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf
${SERVICE1}  Consultation 
${SERVICE2}  Scanning
${SERVICE3}  Scannings111
${SERVICE4}  CHECKING
@{service_duration}  10  20  30   40   50
${giffile}     /ebs/TDD/sample.gif
${jpegfile}     /ebs/TDD/large.jpeg
${bmpfile}     /ebs/TDD/first.bmp
${shfile}     /ebs/TDD/example.sh
${docfile}     /ebs/TDD/docsample.doc
${txtfile}     /ebs/TDD/textsample.txt
${digits}       0123456789
@{EMPTY_List} 
@{person_ahead}   0  1  2  3  4  5  6
${self}         0
@{service_duration}   5   20
${parallel}     1
${xlFile}      ${EXECDIR}/TDD/sampleqnr.xlsx    # DataSheet
${xlFile2}      ${EXECDIR}/TDD/qnr.xlsx    # DataSheet 2
${mp4file}   /ebs/TDD/MP4file.mp4
${mp4mime}   video/mp4
${mp3file}   /ebs/TDD/MP3file.mp3
${mp3mime}   audio/mpeg

@{ownerType}   Provider  ProviderConsumer 

***Test Cases***

JD-TC-GetTotalStorageUsage-1
     [Documentation]  Get upload pdf file by provider id
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME204}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${PUSERNAME204}
    ${acc_id}=  get_acc_id  ${PUSERNAME204}
    Set Test Variable   ${acc_id}
    ${id}=  get_id  ${PUSERNAME204}
    Set Test Variable  ${id}
 
    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME6}
    clear_Consumermsg  ${CUSERNAME6}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME6}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

   
    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${pdffile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${msg1}=  Fakerlibrary.sentence
    ${caption2}=  Fakerlibrary.sentence
    
      ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg1}  ${messageType[0]}  ${caption2}  ${EMPTY}  ${jpgfile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s

     ${msg2}=  Fakerlibrary.sentence
    ${caption3}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg2}  ${messageType[0]}  ${caption3}  ${EMPTY}  ${jpgfile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${msg3}=  Fakerlibrary.sentence
    ${caption3}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg3}  ${messageType[0]}  ${caption3}  ${EMPTY}  ${jpgfile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${msg4}=  Fakerlibrary.sentence
    ${caption3}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg4}  ${messageType[0]}  ${caption3}  ${EMPTY}  ${jpgfile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${msg5}=  Fakerlibrary.sentence
    ${caption3}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg5}  ${messageType[0]}  ${caption3}  ${EMPTY}  ${jpgfile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${msg6}=  Fakerlibrary.sentence
    ${caption3}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg6}  ${messageType[0]}  ${caption3}  ${EMPTY}  ${jpgfile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${msg7}=  Fakerlibrary.sentence
    ${caption3}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg7}  ${messageType[0]}  ${caption3}  ${EMPTY}  ${jpgfile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${msg8}=  Fakerlibrary.sentence
    ${caption3}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg8}  ${messageType[0]}  ${caption3}  ${EMPTY}  ${jpgfile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${msg9}=  Fakerlibrary.sentence
    ${caption3}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg9}  ${messageType[0]}  ${caption3}  ${EMPTY}  ${jpgfile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${msg10}=  Fakerlibrary.sentence
    ${caption3}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg10}  ${messageType[0]}  ${caption3}  ${EMPTY}  ${jpgfile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login     ${PUSERNAME204}   ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=   Get total Storage usage
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
  



JD-TC-GetTotalStorageUsage-2

    [Documentation]  Get  total storage
    clear_Providermsg  ${PUSERNAME204}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME204}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${PUSERNAME204}
    ${acc_id}=  get_acc_id  ${PUSERNAME204}
    Set Test Variable   ${acc_id}
    ${id}=  get_id  ${PUSERNAME204}
    Set Test Variable  ${id}
  

     
    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME5}
    clear_Consumermsg  ${CUSERNAME5}
    clear_Providermsg  ${PUSERNAME204}


    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME5}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpgfile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
  
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login     ${PUSERNAME204}   ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${caption4}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${docfile}
    Log  ${resp}
    
    ${fileType7}=  Get From Dictionary       ${resp}    ${docfile}
    Set Suite Variable    ${fileType7}
    ${list1}=  Create Dictionary         owner=${id}   fileName=${docfile}    fileSize=0.0085     caption=${caption4}     fileType=${fileType7}   order=6
    
    ${resp}=  db.getType   ${pngfile}
    Log  ${resp}
    
    ${fileType7}=  Get From Dictionary       ${resp}    ${pngfile}
    Set Suite Variable    ${fileType7}
    ${list2}=  Create Dictionary         owner=${id}   fileName=${pngfile}    fileSize=0.0085     caption=${caption4}     fileType=${fileType7}   order=6
   
    ${resp}=  db.getType   ${giffile}
    Log  ${resp}
    
    ${fileType7}=  Get From Dictionary       ${resp}    ${giffile}
    Set Suite Variable    ${fileType7}
    ${list3}=  Create Dictionary         owner=${id}   fileName=${giffile}    fileSize=0.0085     caption=${caption4}     fileType=${fileType7}   order=6
   
    ${resp}=  db.getType   ${giffile}
    Log  ${resp}
    
    ${fileType8}=  Get From Dictionary       ${resp}    ${giffile}
    Set Suite Variable    ${fileType8}
    ${list4}=  Create Dictionary         owner=${id}   fileName=${giffile}    fileSize=0.0085     caption=${caption4}     fileType=${fileType8}   order=6
   
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    
    ${fileType8}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType8}
    ${list5}=  Create Dictionary         owner=${id}   fileName=${jpegfile}    fileSize=0.0085     caption=${caption4}     fileType=${fileType8}   order=6
   
    ${list}=   Create List     ${list1}   ${list2}   ${list3}  ${list4}  ${list5}

   
    ${resp}=    Upload To Private Folder      privateFolder  ${id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200

    
    ${resp}=   Get total Storage usage
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
  
JD-TC-GetTotalStorageUsage-UH1

    [Documentation]   without provider login

    ${resp}=   Get total Storage usage
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     419
    Should Be Equal As Strings  "${resp.json()}"     "${SESSION_EXPIRED}"
 

JD-TC-GetTotalStorageUsage-UH2

    [Documentation]   with consumer login
     
    ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get total Storage usage
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     401
    Should Be Equal As Strings  "${resp.json()}"     "${NoAccess}"

JD-TC-GetTotalStorageUsage-3

    [Documentation]   with  another provider login
    
    ${resp}=   Encrypted Provider Login     ${PUSERNAME10}   ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get total Storage usage
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}                     200
   # Should Be Equal As Strings  "${resp.json()}"     "${NO_PERMISSION}"
