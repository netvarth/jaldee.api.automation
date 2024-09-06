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
Variables         /ebs/TDD/varfiles/hl_providers.py





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

JD-TC-RemoveShareFiles-1

    [Documentation]  share file  and remove from consumer

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${jc_id1}=  get_id  ${CUSERNAME5}
    clear_Consumermsg  ${CUSERNAME5}
  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME201}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${acc_id}=  get_acc_id  ${PUSERNAME201}
    Set Test Variable    ${acc_id}
    ${id1}=  get_id  ${PUSERNAME201}
    Set Suite Variable  ${id1}
   
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
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${emptylist}=  Create List
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME5} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid5}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid5}  ${resp.json()[0]['id']}
    END
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
 

    ${caption2}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    
    ${fileType2}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType2}
    ${list1}=  Create Dictionary         owner=${id1}   fileName=${jpgfile}    fileSize=0.0085     caption=${caption2}     fileType=${fileType2}   order=4
    ${list}=   Create List     ${list1}

    ${resp}=    Upload To Private Folder      privateFolder    ${id1}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
    Should Be Equal As Strings                 ${resp.json()[0]['orderId']}      4
   
    ${resp}=   Get by Criteria           owner-eq=${id1}
    Log                                  ${resp.content}
    Set Suite Variable     ${fileid}    ${resp.json()['${id1}']['files'][0]['id']} 

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME201}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${fileid_list}=  Create List   ${fileid}

    ${share}=       Create Dictionary     owner=${cid}      ownerType=${ownerType[1]}
    ${sharedto}=    Create List   ${share}
    
    ${commessage}=  Fakerlibrary.Sentence
    ${medium}=     Create Dictionary     email=${bool[1]}      pushNotification=${bool[1]}    
    ${communication}=   Create Dictionary    medium=${medium}    commessage=${commessage}
   

    ${resp}=    Imageupload.ShareFilesInJaldeeDrive     ${cookie}   ${sharedto}      ${fileid_list}   ${communication}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200 

    ${share}=       Create Dictionary     owner=${cid}        ownerType=${ownerType[1]}
  
    ${resp}=    Remove Share files     ${fileid}      ${share}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200

    ${resp}=   Get by Criteria          owner-eq=${cid}
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}                200
    Should Be Equal As Strings          ${resp.json()}                     {}

JD-TC-RemoveShareFiles-2

    [Documentation]   done general communication and remove file from consumer
    
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${jc_id1}=  get_id  ${CUSERNAME5}
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME201}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${acc_id12}=  get_acc_id  ${PUSERNAME201}
  
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
 
    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME201}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

  

    ${msg2}=  Fakerlibrary.sentence
    ${caption2}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithConsumer   ${cookie}   ${jc_id1}   ${msg2}  ${messageType[0]}  ${caption2}   ${EMPTY}  ${pngfile}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200

    ${resp}=   Get by Criteria          account-eq=${acc_id12}
    Log                                 ${resp.content}
    Set Suite Variable     ${fileid33}      ${resp.json()['${id1}']['files'][0]['id']} 
   

    ${share}=       Create Dictionary     owner=${jc_id1}       ownerType=${ownerType[1]}
  
    ${resp}=    Remove Share files     ${fileid33}      ${share}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200

    ${resp}=   Get by Criteria          owner-eq=${jc_id1}
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}                         200
    Should Be Equal As Strings          ${resp.json()}                     {}

JD-TC-RemoveShareFiles-3

    [Documentation]   user remove share file from consumer


    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${jc_id11}=  get_id  ${CUSERNAME3}
    clear_Consumermsg   ${CUSERNAME3}
  

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME3}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${p_id}=  get_acc_id  ${HLPUSERNAME3}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${bs}=  FakerLibrary.bs
    Set Suite Variable  ${bs}
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
        FOR   ${i}  IN RANGE   0   ${len}
        
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${HLPUSERNAME3}'
                clear_users  ${user_phone}
            END
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

    
    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME3}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  AddCustomer  ${CUSERNAME3}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${cId11}        ${resp.json()}      


    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${pcons_id3}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}
  
    ${resp}=   Encrypted Provider Login   ${PUSERNAME_U1}   ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${caption4}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${giffile}
    Log  ${resp}
    
    ${fileType5}=  Get From Dictionary       ${resp}    ${giffile}
    Set Suite Variable    ${fileType5}
    ${list1}=  Create Dictionary         owner=${u_id}   fileName=${giffile}    fileSize=0.0085     caption=${caption4}     fileType=${fileType5}   order=6
    ${list}=   Create List     ${list1}

   
    ${resp}=    Upload To Private Folder      privateFolder     ${u_id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
 
    ${resp}=   Get by Criteria              owner-eq=${u_id}
    Log                                     ${resp.content}
    Set Suite Variable     ${fileid11}       ${resp.json()['${u_id}']['files'][0]['id']} 
    
    ${cookie}   ${resp}=    Imageupload.spLogin    ${PUSERNAME_U1}   ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200


    ${fileid_list}=  Create List   ${fileid11}      

    ${share}=       Create Dictionary     owner=${cId11}       ownerType=ProviderConsumer
    
    ${sharedto}=    Create List   ${share}  
    
    ${commessage}=  Fakerlibrary.Sentence
    ${medium}=     Create Dictionary     email=${bool[1]}      pushNotification=${bool[1]}    
    ${communication}=   Create Dictionary    medium=${medium}    commessage=${commessage}
   

    ${resp}=    Imageupload.ShareFilesInJaldeeDrive     ${cookie}   ${sharedto}      ${fileid_list}   ${communication}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
  
    ${share}=       Create Dictionary     owner=${cId11}        ownerType=${ownerType[1]}
  
    ${resp}=    Remove Share files     ${fileid11}      ${share}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200

   
    ${resp}=   Get by Criteria          owner-eq=${cId11}
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}                         200
    Should Be Equal As Strings  ${resp.json()}                     {}

JD-TC-RemoveShareFiles-4

    [Documentation]   branch remove share file from consumer
   
    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME3}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${p_id}=  get_acc_id  ${HLPUSERNAME3}

    ${caption4}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${pngfile}
    Log  ${resp}
    
    ${fileType5}=  Get From Dictionary       ${resp}    ${pngfile}
    Set Suite Variable    ${fileType5}
    ${list1}=  Create Dictionary         owner=${p_id}   fileName=${pngfile}    fileSize=0.0085     caption=${caption4}     fileType=${fileType5}   order=6
    ${list}=   Create List     ${list1}

   
    ${resp}=    Upload To Private Folder      privateFolder    ${p_id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
 
    ${resp}=   Get by Criteria              account-eq=${p_id}
    Log                                     ${resp.content}
    Set Suite Variable     ${fileid44}      ${resp.json()['${p_id}']['files'][0]['id']} 
     
    ${cookie}   ${resp}=    Imageupload.spLogin    ${HLPUSERNAME3}   ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200


    ${fileid_list}=  Create List   ${fileid44}      

    ${share}=       Create Dictionary     owner=${cId11}       ownerType=ProviderConsumer
    
    ${sharedto}=    Create List   ${share}  
    
    ${commessage}=  Fakerlibrary.Sentence
    ${medium}=     Create Dictionary     email=${bool[1]}      pushNotification=${bool[1]}    
    ${communication}=   Create Dictionary    medium=${medium}    commessage=${commessage}
   

    ${resp}=    Imageupload.ShareFilesInJaldeeDrive     ${cookie}   ${sharedto}      ${fileid_list}   ${communication}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
  
    ${share}=       Create Dictionary     owner=${cId11}        ownerType=${ownerType[1]}
  
    ${resp}=    Remove Share files     ${fileid44}      ${share}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200

   
    ${resp}=   Get by Criteria          owner-eq=${cId11}
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}                         200
    Should Be Equal As Strings  ${resp.json()}                     {}

JD-TC-RemoveShareFiles-5

    [Documentation]   branch  share file  and user remove file
   
    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME3}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${p_id}=  get_acc_id  ${HLPUSERNAME3}
   
    ${caption4}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${pngfile}
    Log  ${resp}
    
    ${fileType5}=  Get From Dictionary       ${resp}    ${pngfile}
    Set Suite Variable    ${fileType5}
    ${list1}=  Create Dictionary         owner=${p_id}   fileName=${pngfile}    fileSize=0.0085     caption=${caption4}     fileType=${fileType5}   order=6
    ${list}=   Create List     ${list1}

   
    ${resp}=    Upload To Private Folder      privateFolder    ${p_id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
 
    ${resp}=   Get by Criteria              account-eq=${p_id}
    Log                                     ${resp.content}
    Set Suite Variable     ${fileid66}      ${resp.json()['${p_id}']['files'][0]['id']} 
     
    ${cookie}   ${resp}=    Imageupload.spLogin    ${HLPUSERNAME3}   ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200


    ${fileid_list}=  Create List   ${fileid66}      

    ${share}=       Create Dictionary     owner=${cId11}       ownerType=${ownerType[1]}
    
    ${sharedto}=    Create List   ${share}  
    
    ${commessage}=  Fakerlibrary.Sentence
    ${medium}=     Create Dictionary     email=${bool[1]}      pushNotification=${bool[1]}    
    ${communication}=   Create Dictionary    medium=${medium}    commessage=${commessage}
   

    ${resp}=    Imageupload.ShareFilesInJaldeeDrive     ${cookie}   ${sharedto}      ${fileid_list}   ${communication}
     Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
  

    ${resp}=   Encrypted Provider Login   ${PUSERNAME_U1}   ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${share}=       Create Dictionary     owner=${cId11}        ownerType=${ownerType[1]}
  
    ${resp}=    Remove Share files     ${fileid66}      ${share}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
 
    ${resp}=   Get by Criteria          owner-eq=${cId11}
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}                         200
    Should Be Equal As Strings  ${resp.json()}                     {}

JD-TC-RemoveShareFiles-6

    [Documentation]   user  share file  and branch remove file

    ${resp}=   Encrypted Provider Login   ${PUSERNAME_U1}   ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
   
    ${caption4}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${docfile}
    Log  ${resp}
    
    ${fileType7}=  Get From Dictionary       ${resp}    ${docfile}
    Set Suite Variable    ${fileType7}
    ${list1}=  Create Dictionary         owner=${${u_id}}   fileName=${docfile}    fileSize=0.0085     caption=${caption4}     fileType=${fileType7}   order=6
    ${list}=   Create List     ${list1}

   
    ${resp}=    Upload To Private Folder      privateFolder   ${u_id}    ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
 
    ${resp}=   Get by Criteria              fileType-eq=${fileType7}
    Log                                     ${resp.content}
    Set Suite Variable     ${fileid77}      ${resp.json()['${u_id}']['files'][0]['id']} 
     
    ${cookie}   ${resp}=    Imageupload.spLogin    ${PUSERNAME_U1}   ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200


    ${fileid_list}=  Create List   ${fileid77}      

    ${share}=       Create Dictionary     owner=${cId11}       ownerType=${ownerType[1]}
    
    ${sharedto}=    Create List   ${share}  
    ${commessage}=  Fakerlibrary.Sentence
    ${medium}=     Create Dictionary     email=${bool[1]}      pushNotification=${bool[1]}    
    ${communication}=   Create Dictionary    medium=${medium}    commessage=${commessage}
   

    ${resp}=    Imageupload.ShareFilesInJaldeeDrive     ${cookie}   ${sharedto}      ${fileid_list}   ${communication}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME3}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
   
  
    ${share}=   Create Dictionary        owner=${cId11}                    ownerType=${ownerType[1]}
  
    ${resp}=    Remove Share files       ${fileid77}                       ${share}
    Log  ${resp.content}
    Should Be Equal As Strings           ${resp.status_code}               200

   
    ${resp}=   Get by Criteria          owner-eq=${cId11}
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}                200
    Should Be Equal As Strings          ${resp.json()}                     {}

JD-TC-RemoveShareFiles-UH1

    [Documentation]   without provider login

    ${share}=       Create Dictionary     owner=${cId11}        ownerType=${ownerType[1]}
  
    ${resp}=    Remove Share files     ${fileid77}      ${share}
    Should Be Equal As Strings  ${resp.status_code}                     419
    Should Be Equal As Strings  "${resp.json()}"     "${SESSION_EXPIRED}"
 
JD-TC-RemoveShareFiles-UH2
     
    [Documentation]   with consumer login
     
    ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${share}=       Create Dictionary     owner=${cId11}        ownerType=${ownerType[1]}
  
    ${resp}=    Remove Share files     ${fileid77}      ${share}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     401
    Should Be Equal As Strings  "${resp.json()}"     "${NoAccess}"
 

JD-TC-RemoveShareFiles-UH3
   
    [Documentation]   with  another provider login
    
    ${resp}=   Encrypted Provider Login     ${PUSERNAME10}   ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${share}=       Create Dictionary     owner=${cId11}        ownerType=${ownerType[1]}
  
    ${resp}=    Remove Share files     ${fileid77}      ${share}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}                     401
    Should Be Equal As Strings  "${resp.json()}"     "${NO_PERMISSION}"
 

 
# JD-TC-RemoveShareFiles-

#     [Documentation]  Get upload pdf file by provider id
    
#     clear_Item  ${PUSERNAME200}
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${acc_id}=  get_acc_id  ${PUSERNAME200}
#     Set Test Variable   ${acc_id}
     
#     ${id1}=  get_id  ${PUSERNAME200}
#     Set Suite Variable  ${id1}
   
    
#     ${displayName1}=   FakerLibrary.name 
#     Set Suite Variable  ${displayName1}  
#     ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2 
#     Set Test Variable  ${shortDesc1}   
#     ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3 
#     Set Test Variable  ${itemDesc1}   
#     ${price1}=  Random Int  min=50   max=300 
#     Set Test Variable  ${price1}
#     ${price1float}=  twodigitfloat  ${price1}
#     Set Test Variable  ${price1float}
#     ${price2float}=   Convert To Number   ${price1}  2
#     Set Test Variable  ${price2float}    
#     ${itemName1}=   FakerLibrary.name
#     Set Test Variable  ${itemName1}   
#     ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2 
#     Set Test Variable  ${itemNameInLocal1}    
#     ${promoPrice1}=  Random Int  min=10   max=${price1} 
#     Set Test Variable  ${promoPrice1}
#     ${promoPrice1float}=   Convert To Number   ${promoPrice1}  2
#     Set Test Variable  ${promoPrice1float}
#     ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
#     ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}
#     Set Test Variable  ${promotionalPrcnt1}
#     ${note1}=  FakerLibrary.Sentence
#     Set Test Variable  ${note1}    
#     ${itemCode1}=   FakerLibrary.word 
#     Set Test Variable  ${itemCode1}  
#     ${promoLabel1}=   FakerLibrary.word 
#     Set Test Variable  ${promoLabel1}


#     ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${id}  ${resp.json()}

   
#     ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME200}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Eq ${resp}=    Remove Share files     ${fileid}      ${share}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}                     200

#     ${resp}=   Get Item By Id   ${id}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Not Be Equal As Strings  ${resp.json()['itemImages']}   ${EMPTY}
#     Should Be Equal As Strings    ${resp.json()['itemImages'][0]['displayImage']}   ${bool[1]}    
#     # Should Contain  ${resp.json()['itemImages']}  /item/${id}/ 

#     ${resp}=   Get by Criteria          ownerType-eq=Provider
#     Log                                 ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}                     200
#     Set Test Variable  ${fileid}       ${resp.json()[0]['id']}   
#     ${share}=       Create Dictionary     owner=${id1}        ownerType=Provider
  
  
  
#     ${resp}=    Remove Share files     ${fileid}      ${share}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}                200
#     Should Be Equal As Strings  ${resp.json()}                     []


  
    

# JD-TC-RemoveShareFiles-45

#     [Documentation]  UploadTaskAttachment using Task Id.

#     ${resp}=   Encrypted Provider Login  ${PUSERNAME33}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${p_id}=  get_acc_id  ${PUSERNAME33}
#     Set Test Variable  ${p_id}

#     ${resp}=    Get Locations
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     IF   '${resp.content}' == '${emptylist}'
#         ${locId}=  Create Sample Location
#     ELSE
#         Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
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
#     Set Test Variable  ${type_name1}  ${resp.json()[0]['name']}

#     ${title}=  FakerLibrary.user name
#     Set Suite Variable   ${title}
#     ${desc}=   FakerLibrary.word 
#     Set Suite Variable    ${desc}

#     ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${task_id}=  Get Dictionary Values  ${resp.json()}
#     Set Test Variable  ${task_id1}  ${task_id[0]}
#     Set Test Variable  ${task_uid1}  ${task_id[1]}

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

#     ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME33}    ${PASSWORD}
#     Log     ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}     200

#     ${caption1}=  Fakerlibrary.Sentence
#     ${attachements1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
       
#     ${caption2}=  Fakerlibrary.Sentence
#     ${attachements2}=  Create Dictionary   file=${pdffile}   caption=${caption1}
     
#    # @{fileswithcaption}=  Create List    ${attachements1}    ${attachements2}
#     ${resp}=    Imageupload.uploadTaskAttachment     ${cookie}   ${task_uid1}      ${attachements1}  ${attachements2}
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
#     Should Contain     "${resp.json()}"    jpg
#     Should Contain     "${resp.json()}"     pdf
    
#     ${resp}=   Get by Criteria         account-eq=${p_id}
#     Log                                 ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}                                    200
#     Should Be Equal As Strings          ${resp.json()[0]['account']}                   ${pid}
#     Should Be Equal As Strings          ${resp.json()[0]['ownerType']}                 Provider
#     Should Be Equal As Strings          ${resp.json()[0]['context']}                   providerTask
#     Set Suite Variable     ${fileid1}       ${resp.json()[0]['id']} 
#     Set Suite Variable     ${id}       ${resp.json()[0]['owner']} 
   
#     ${share}=       Create Dictionary     owner=${id}        ownerType=Provider
  

#     ${resp}=    Remove Share files     ${fileid1}      ${share}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}                     200
   
   
#     ${resp}=   Get by Criteria          id-eq=${fileid1}
#     Log                                 ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}                     200

    
# JD-TC-RemoveShareFiles-3

#     [Documentation]  file upload to private folder

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME144}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${acc_id}=  get_acc_id  ${PUSERNAME144}
#     Set Test Variable  ${providerId}   ${acc_id}
#     ${id}=  get_id  ${PUSERNAME144}
#     Set Suite Variable  ${id}
   
    
      
#     ${caption1}=  Fakerlibrary.Sentence
 
#     ${resp}=  db.getType   ${jpegfile}
#     Log  ${resp}
    
#     ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
#     Set Suite Variable    ${fileType}

#     #Set Text Variable  ${data.json}
#     ${list1}=  Create Dictionary         owner=${id}   fileName=${jpegfile}    fileSize=0.0085     caption=${caption1}     fileType=${fileType}   order=0
#     ${list}=   Create List     ${list1}
#     ${resp}=    Upload To Private Folder      privateFolder    ${id}     ${list}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Log                                        ${resp.content}
#     Should Be Equal As Strings                 ${resp.status_code}                200
#     Should Be Equal As Strings                 ${resp.json()[0]['orderId']}      0 
#  #   Should Be Equal As Strings                 ${resp.json()[0]['driveId']}      2


   
#     ${resp}=   Get List Of Shared 0wners    ${ownerType[0]}       ${id}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings     ${resp.json()[0]['account']}      ${acc_id}
#     Should Be Equal As Strings     ${resp.json()[0]['sharedType']}   secureShare
#     Should Be Equal As Strings     ${resp.json()[0]['account']}      ${acc_id}
#     Should Be Equal As Strings     ${resp.json()[0]['fileType']}     .jpe
#     Set Suite Variable     ${fileid2}       ${resp.json()[0]['id']} 
#     Set Suite Variable     ${id1}       ${resp.json()[0]['owner']} 
    
#     ${share}=       Create Dictionary     owner=${id1}        ownerType=Provider
  

#     ${resp}=    Remove Share files     ${fileid2}      ${share}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}                     200


 
