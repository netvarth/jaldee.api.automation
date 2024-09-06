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
Library           /ebs/TDD/Imageupload.py
Variables          /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/providers.py




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
${xlFile}       ${EXECDIR}/TDD/sampleQnr.xlsx    # DataSheet
${xlFile2}      ${EXECDIR}/TDD/qnr.xlsx    # DataSheet 2
${mp4file}      /ebs/TDD/MP4file.mp4
${mp4mime}      video/mp4
${mp3file}      /ebs/TDD/MP3file.mp3
${mp3mime}      audio/mpeg
${count}       2
${filesize}    0.0084
***Test Cases***

JD-TC-ShareFiles-1

    [Documentation]  share pdf file multiple consumer
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME55}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${acc_id}=  get_acc_id  ${PUSERNAME55}
    Set Suite Variable    ${acc_id}
    ${id}=  get_id  ${PUSERNAME55}
    Set Suite Variable  ${id}
   

    clear_customer      ${PUSERNAME55}

    ${msg}=   FakerLibrary.Word
    ${caption}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}

    ${firstname_C1}=    FakerLibrary.first_name
    ${lastname_C1}=     FakerLibrary.last_name
    ${firstname_C2}=    FakerLibrary.first_name 
    ${lastname_C2}=     FakerLibrary.last_name
    ${firstname_C3}=    FakerLibrary.first_name 
    ${lastname_C3}=     FakerLibrary.last_name
    ${firstname_C4}=    FakerLibrary.first_name 
    ${lastname_C4}=     FakerLibrary.last_name

    Set Suite Variable      ${firstname_C1}
    Set Suite Variable      ${lastname_C1}
    Set Suite Variable      ${firstname_C2}
    Set Suite Variable      ${lastname_C2}
    Set Suite Variable      ${firstname_C3}
    Set Suite Variable      ${lastname_C3}
    Set Suite Variable      ${firstname_C4}
    Set Suite Variable      ${lastname_C4}

    ${resp}=  AddCustomer  ${CUSERNAME11}    firstName=${firstname_C1}   lastName=${lastname_C1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${userId1}        ${resp.json()}     

    ${resp}=  AddCustomer  ${CUSERNAME12}    firstName=${firstname_C2}   lastName=${lastname_C2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${userId2}        ${resp.json()}      

    ${resp}=  AddCustomer  ${CUSERNAME13}    firstName=${firstname_C3}   lastName=${lastname_C3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${userId3}        ${resp.json()} 

    ${resp}=  AddCustomer  ${CUSERNAME14}    firstName=${firstname_C4}   lastName=${lastname_C4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${userId4}        ${resp.json()}      

    ${resp}=    GetCustomer
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${caption1}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}

    ${caption2}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${pngfile}
    Log  ${resp}
    
    ${fileType1}=  Get From Dictionary       ${resp}    ${pngfile}
    Set Suite Variable    ${fileType1}
  
    #Set Text Variable  ${data.json}
    ${list1}=  Create Dictionary         owner=${id}   fileName=${jpegfile}    fileSize=${filesize}   caption=${caption1}     fileType=${fileType}   order=0
    ${list2}=  Create Dictionary         owner=${id}   fileName=${pngfile}    fileSize=${filesize}   caption=${caption2}     fileType=${fileType1}   order=1
  
    ${list}=   Create List     ${list1}   ${list2}


    ${resp}=    Upload To Private Folder      privateFolder    ${id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
    
     
    ${caption2}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${pdffile}
    Log  ${resp}
    
    ${fileType2}=  Get From Dictionary       ${resp}    ${pdffile}
    Set Suite Variable    ${fileType2}
    ${list1}=  Create Dictionary         owner=${id}   fileName=${pdffile}    fileSize=${filesize}     caption=${caption2}     fileType=${fileType2}   order=3
    ${list}=   Create List     ${list1}

    ${resp}=    Upload To Private Folder      privateFolder    ${id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
    Should Be Equal As Strings                 ${resp.json()[0]['orderId']}      3
   
    ${resp}=   Get by Criteria          owner-eq=${id}
    Log                                 ${resp.content}
    Set Suite Variable     ${fileid}       ${resp.json()['${id}']['files'][0]['id']} 

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME55}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${fileid_list}=  Create List   ${fileid}
  
    ${share}=       Create Dictionary     owner=${userId1}       ownerType=${ownerType[1]}
    ${share1}=      Create Dictionary     owner=${userId2}       ownerType=${ownerType[1]}
    ${share2}=      Create Dictionary     owner=${userId3}       ownerType=${ownerType[1]}
    ${share3}=      Create Dictionary     owner=${userId4}       ownerType=${ownerType[1]}

    ${sharedto}=    Create List   ${share}  ${share1}  ${share2}  ${share3}
    
    ${commessage}=  Fakerlibrary.Sentence
    ${medium}=     Create Dictionary     email=${bool[1]}      pushNotification=${bool[1]}    
    ${communication}=   Create Dictionary    medium=${medium}    commessage=${commessage}
   

    ${resp}=    Imageupload.ShareFilesInJaldeeDrive     ${cookie}   ${sharedto}      ${fileid_list}   ${communication}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

JD-TC-ShareFiles-2

    [Documentation]  share file only one consumer

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${jc_id1}=  get_id  ${CUSERNAME5}
    clear_Consumermsg  ${CUSERNAME5}
  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${acc_id}=  get_acc_id  ${PUSERNAME48}
    Set Test Variable    ${acc_id}
    ${id1}=  get_id  ${PUSERNAME48}
    Set Suite Variable  ${id1}

    ${resp}=  AddCustomer  ${CUSERNAME5}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${cId4}        ${resp.json()}      

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid4}  ${resp.json()[0]['id']}
 

    ${caption2}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    
    ${fileType2}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType2}
    ${list1}=  Create Dictionary         owner=${id1}   fileName=${jpgfile}    fileSize=${filesize}     caption=${caption2}     fileType=${fileType2}   order=4
    ${list}=   Create List     ${list1}

    ${resp}=    Upload To Private Folder      publicFolder    ${id1}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
    Should Be Equal As Strings                 ${resp.json()[0]['orderId']}      4
   
   
    ${resp}=   Get by Criteria          owner-eq=${id1}
    Log                                 ${resp.content}
    Set Suite Variable     ${fileid}       ${resp.json()['${id1}']['files'][0]['id']} 

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   

    ${fileid_list}=  Create List   ${fileid}

    ${share}=       Create Dictionary     owner=${cid4}      ownerType=${ownerType[1]}
    ${sharedto}=    Create List   ${share}
    
    ${commessage}=  Fakerlibrary.Sentence
    ${medium}=     Create Dictionary     email=${bool[1]}      pushNotification=${bool[1]}    
    ${communication}=   Create Dictionary    medium=${medium}    commessage=${commessage}
    ${resp}=    Imageupload.ShareFilesInJaldeeDrive     ${cookie}   ${sharedto}      ${fileid_list}    ${communication}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${resp}=  Get provider communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 


    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

  
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
   

  
JD-TC-ShareFiles-3

    [Documentation]  share  more than folder to one consumer

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${jc_id1}=  get_id  ${CUSERNAME15}
    clear_Consumermsg  ${CUSERNAME15}
  
    ${resp}=  Encrypted Provider Login  ${PUSERNAME88}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${acc_id}=  get_acc_id  ${PUSERNAME88}
    Set Test Variable  ${providerId}   ${acc_id}
    ${id}=  get_id  ${PUSERNAME88}
    Set Suite Variable  ${id}
   
    ${resp}=  AddCustomer  ${CUSERNAME15}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${cId4}        ${resp.json()}      

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid12}  ${resp.json()[0]['id']}
 
    ${caption2}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    
    ${fileType2}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType2}
    ${list1}=  Create Dictionary         owner=${id}   fileName=${jpgfile}    fileSize=${filesize}     caption=${caption2}     fileType=${fileType2}   order=4
    ${list}=   Create List     ${list1}

    ${resp}=    Upload To Private Folder      privateFolder    ${id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
  
  
    ${caption2}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${txtfile}
    Log  ${resp}
    
    ${fileType4}=  Get From Dictionary       ${resp}    ${txtfile}
    Set Suite Variable    ${fileType4}
    ${list1}=  Create Dictionary         owner=${id}   fileName=${txtfile}    fileSize=${filesize}     caption=${caption2}     fileType=${fileType4}   order=5
    ${list}=   Create List     ${list1}

    ${resp}=    Upload To Private Folder      privateFolder    ${id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
  
    

    ${resp}=   Get by Criteria              owner-eq=${id}
    Log                                     ${resp.content}
    Set Suite Variable     ${fileid1}       ${resp.json()['${id}']['files'][0]['id']} 
    Set Suite Variable     ${fileid2}       ${resp.json()['${id}']['files'][1]['id']} 

    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME88}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${fileid_list}=  Create List   ${fileid1}    ${fileid2} 

    ${share}=       Create Dictionary     owner=${cid12}        ownerType=${ownerType[1]}
    ${sharedto}=    Create List   ${share}

    ${commessage}=  Fakerlibrary.Sentence
    ${medium}=     Create Dictionary     email=${bool[1]}      pushNotification=${bool[1]}    
    ${communication}=   Create Dictionary    medium=${medium}    commessage=${commessage}
   

    ${resp}=    Imageupload.ShareFilesInJaldeeDrive     ${cookie}   ${sharedto}      ${fileid_list}   ${communication}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
 



JD-TC-ShareFiles-4

    [Documentation]  share  more than folder to more than one consumer

    # ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${jc_id11}=  get_id  ${CUSERNAME3}
    # clear_Consumermsg   ${CUSERNAME3}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME88}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${acc_id}=  get_acc_id  ${PUSERNAME88}
    Set Test Variable  ${providerId}   ${acc_id}
    ${id}=  get_id  ${PUSERNAME88}
    Set Suite Variable  ${id}
    ${resp}=  AddCustomer  ${CUSERNAME38}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${cId38}        ${resp.json()}      

    ${resp}=  AddCustomer  ${CUSERNAME37}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${cId37}        ${resp.json()}      

     ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME37} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid37}  ${resp.json()[0]['id']}
 
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38} 
    Log   ${resp.json()}

    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}

    FOR   ${a}  IN RANGE   10
            
            ${cons_num}    Random Int  min=123456   max=999999
            ${CUSERPH}=  Evaluate  ${CUSERNAME}+${cons_num}
            Set Test Variable  ${CUSERPH${a}}  ${CUSERPH}
            ${resp}=  AddCustomer  ${CUSERPH${a}}
            Log  ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Test Variable  ${cid${a}}  ${resp.json()}

            ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${a}}
            Log   ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200
            Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

    END
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${0}}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${0}}
  
   
    ${caption2}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${txtfile}
    Log  ${resp}
    
    ${fileType4}=  Get From Dictionary       ${resp}    ${txtfile}
    Set Suite Variable    ${fileType4}
    ${list1}=  Create Dictionary         owner=${id}   fileName=${txtfile}    fileSize=${filesize}     caption=${caption2}     fileType=${fileType4}   order=5
    ${list}=   Create List     ${list1}

    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${docfile}
    Log  ${resp}
    
    ${fileType5}=  Get From Dictionary       ${resp}    ${docfile}
    Set Suite Variable    ${fileType5}
    ${list1}=  Create Dictionary         owner=${id}   fileName=${docfile}    fileSize=${filesize}     caption=${caption3}     fileType=${fileType5}   order=6
    ${list}=   Create List     ${list1}

    ${resp}=    Upload To Private Folder      privateFolder    ${id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200

    ${caption4}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${giffile}
    Log  ${resp}
    
    ${fileType6}=  Get From Dictionary       ${resp}    ${giffile}
    Set Suite Variable    ${fileType6}
    ${list1}=  Create Dictionary         owner=${id}   fileName=${giffile}    fileSize=${filesize}    caption=${caption4}     fileType=${fileType5}   order=6
    ${list}=   Create List     ${list1}

    ${resp}=    Upload To Private Folder      privateFolder    ${id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
 
    ${resp}=   Get by Criteria              owner-eq=${id}
    Log                                     ${resp.content}
    Set Suite Variable     ${fileid1}       ${resp.json()['${id}']['files'][0]['id']} 
    Set Suite Variable     ${fileid2}       ${resp.json()['${id}']['files'][1]['id']} 
    Set Suite Variable     ${fileid3}       ${resp.json()['${id}']['files'][2]['id']} 
    
    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME88}    ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200


    ${fileid_list}=  Create List   ${fileid1}    ${fileid2}   ${fileid3}  

    ${share}=       Create Dictionary     owner=${cId38}        ownerType=${ownerType[1]}
    ${share1}=      Create Dictionary     owner=${cId37}       ownerType=${ownerType[1]}
    ${share3}=      Create Dictionary     owner=${cid0}       ownerType=${ownerType[1]}
    ${share4}=      Create Dictionary     owner=${cid1}       ownerType=${ownerType[1]}
    ${share5}=      Create Dictionary     owner=${cid2}       ownerType=${ownerType[1]}
    ${share6}=      Create Dictionary     owner=${cid3}       ownerType=${ownerType[1]}
    ${share7}=      Create Dictionary     owner=${cid4}       ownerType=${ownerType[1]}
    ${share8}=      Create Dictionary     owner=${cid5}       ownerType=${ownerType[1]}
    ${share9}=      Create Dictionary     owner=${cid6}       ownerType=${ownerType[1]}
    ${share10}=      Create Dictionary     owner=${cid7}       ownerType=${ownerType[1]}
    ${share11}=      Create Dictionary     owner=${cid8}       ownerType=${ownerType[1]}

    ${sharedto}=    Create List   ${share}   ${share1}    ${share3}     ${share4}   ${share5}  ${share6}   ${share7}   ${share8}   ${share9}   ${share10}  ${share11}
    
    ${commessage}=  Fakerlibrary.Sentence
    ${medium}=     Create Dictionary     email=${bool[1]}      pushNotification=${bool[1]}    
    ${communication}=   Create Dictionary    medium=${medium}    commessage=${commessage}
   

    ${resp}=    Imageupload.ShareFilesInJaldeeDrive     ${cookie}   ${sharedto}      ${fileid_list}   ${communication}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

    # ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Consumer Communications
# Log   ${resp.json()}        
 
    # ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Consumer Communications
    # Log   ${resp.json()}
 

JD-TC-ShareFiles-5

    [Documentation]  share folder user to consumer

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${jc_id11}=  get_id  ${CUSERNAME3}
    clear_Consumermsg   ${CUSERNAME3}
  

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${p_id}=  get_acc_id  ${HLPUSERNAME0}

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
            IF   not '${user_phone}' == '${HLPUSERNAME0}'
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

    
    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME0}  ${PASSWORD} 
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
    ${list1}=  Create Dictionary         owner=${id}   fileName=${giffile}    fileSize=${filesize}     caption=${caption4}     fileType=${fileType5}   order=6
    ${list}=   Create List     ${list1}

   
    ${resp}=    Upload To Private Folder      privateFolder     ${u_id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
 
    ${resp}=   Get by Criteria              owner-eq=${u_id}
    Log                                     ${resp.content}
    Set Suite Variable     ${fileid11}      ${resp.json()['${u_id}']['files'][0]['id']} 
    # Set Suite Variable     ${fileid2}       ${resp.json()[1]['id']} 
    # Set Suite Variable     ${fileid3}       ${resp.json()[2]['id']} 
    
    ${cookie}   ${resp}=    Imageupload.spLogin    ${PUSERNAME_U1}   ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200


    ${fileid_list}=  Create List   ${fileid11}      

    ${share}=       Create Dictionary     owner=${cId11}       ownerType=${ownerType[1]}
  #  ${share1}=      Create Dictionary     owner= ${cId5}       ownerType=${ownerType[1]}
    
    ${sharedto}=    Create List   ${share}  
    
    ${commessage}=  Fakerlibrary.Sentence
    ${medium}=     Create Dictionary     email=${bool[1]}      pushNotification=${bool[1]}    
    ${communication}=   Create Dictionary    medium=${medium}    commessage=${commessage}
   

    ${resp}=    Imageupload.ShareFilesInJaldeeDrive     ${cookie}   ${sharedto}      ${fileid_list}   ${communication}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

   
JD-TC-ShareFiles-6

    [Documentation]  user  upload file to drive  and  that file  share  by branch to a consumer
    
    ${resp}=   Encrypted Provider Login   ${PUSERNAME_U1}   ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${caption4}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${giffile}
    Log  ${resp}
    
    ${fileType7}=  Get From Dictionary       ${resp}    ${giffile}
    Set Suite Variable    ${fileType7}
    ${list1}=  Create Dictionary         owner=${id}   fileName=${giffile}    fileSize=${filesize}     caption=${caption4}     fileType=${fileType7}   order=6
    ${list}=   Create List     ${list1}

   
    ${resp}=    Upload To Private Folder      privateFolder     ${u_id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
 
    ${resp}=   Get by Criteria              owner-eq=${u_id}
    Log                                     ${resp.content}
    Set Suite Variable     ${fileid22}      ${resp.json()['${u_id}']['files'][0]['id']} 
   
    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${cookie}   ${resp}=    Imageupload.spLogin    ${HLPUSERNAME0}    ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200


    ${fileid_list}=  Create List   ${fileid22}      

    ${share}=       Create Dictionary     owner=${cId11}       ownerType=${ownerType[1]}
  #  ${share1}=      Create Dictionary     owner= ${cId5}       ownerType=${ownerType[1]}
    
    ${sharedto}=    Create List   ${share}  
    
    ${commessage}=  Fakerlibrary.Sentence
    ${medium}=     Create Dictionary     email=${bool[1]}      pushNotification=${bool[1]}    
    ${communication}=   Create Dictionary    medium=${medium}    commessage=${commessage}
   

    ${resp}=    Imageupload.ShareFilesInJaldeeDrive     ${cookie}   ${sharedto}      ${fileid_list}   ${communication}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

   
JD-TC-ShareFiles-7

    [Documentation]   branch  upload file to drive  and  that file  share  by user to a consumer

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${p_id}=  get_acc_id  ${HLPUSERNAME0}
    ${id33}=  get_id  ${HLPUSERNAME0}
    Set Suite Variable  ${id33}


    ${caption4}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${giffile}
    Log  ${resp}
    
    ${fileType8}=  Get From Dictionary       ${resp}    ${giffile}
    Set Suite Variable    ${fileType8}
    ${list1}=  Create Dictionary         owner=${id33}  fileName=${giffile}    fileSize=${filesize}     caption=${caption4}     fileType=${fileType8}   order=8
    ${list}=   Create List     ${list1}

   
    ${resp}=    Upload To Private Folder      privateFolder    ${p_id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
 
    ${resp}=   Get by Criteria              owner-eq=${u_id}
    Log                                     ${resp.content}
    Set Suite Variable     ${fileid33}      ${resp.json()['${u_id}']['files'][0]['id']} 

    ${resp}=   Encrypted Provider Login   ${PUSERNAME_U1}   ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
   
    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME_U1}    ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200


    ${fileid_list}=  Create List   ${fileid33}      

    ${share}=       Create Dictionary     owner=${cId11}       ownerType=${ownerType[1]}
  #  ${share1}=      Create Dictionary     owner= ${cId5}       ownerType=ProviderConsumer
    
    ${sharedto}=    Create List   ${share}  
    
    ${commessage}=  Fakerlibrary.Sentence
    ${medium}=     Create Dictionary     email=${bool[1]}      pushNotification=${bool[1]}    
    ${communication}=   Create Dictionary    medium=${medium}    commessage=${commessage}
   

    ${resp}=    Imageupload.ShareFilesInJaldeeDrive     ${cookie}   ${sharedto}      ${fileid_list}   ${communication}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

   
  
 
  
JD-TC-ShareFiles-UH1

    [Documentation]  share file to another provider
  
    ${resp}=  Encrypted Provider Login  ${PUSERNAME88}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${acc_id}=  get_acc_id  ${PUSERNAME88} ${PUSERNAME88} 
    Set Test Variable  ${providerId}   ${acc_id}
    ${id}=  get_id  ${PUSERNAME88}
    Set Suite Variable  ${id}
   
    ${caption4}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${giffile}
    Log  ${resp}
   
  
    ${fileType8}=  Get From Dictionary       ${resp}    ${giffile}
    Set Suite Variable    ${fileType8}
   
    ${list1}=  Create Dictionary         owner=${id33}  fileName=${giffile}    fileSize=${filesize}     caption=${caption4}     fileType=${fileType8}   order=8
    ${list}=   Create List     ${list1}

   
    ${resp}=    Upload To Private Folder      privateFolder     ${id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
   
   
    ${resp}=   Get by Criteria           owner-eq=${id}
    Log                                 ${resp.content}
    Set Suite Variable     ${fileid1}       ${resp.json()['${id}']['files'][0]['id']} 

    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME213}    ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${fileid_list}=  Create List   ${fileid1} 
    ${share1}=      Create Dictionary     owner=${id}      ownerType=Provider
    
    ${sharedto}=    Create List      ${share1}  
    ${commessage}=  Fakerlibrary.Sentence
    ${medium}=     Create Dictionary     email=${bool[1]}      pushNotification=${bool[1]}    
    ${communication}=   Create Dictionary    medium=${medium}    commessage=${commessage}
   

    ${resp}=    Imageupload.ShareFilesInJaldeeDrive     ${cookie}   ${sharedto}      ${fileid_list}   ${communication}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     401
    Should Be Equal As Strings  "${resp.json()}"     "${NO_PERMISSION}"
 

JD-TC-ShareFiles-UH2

    [Documentation]  consumer login

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${c_id}=  get_id  ${CUSERNAME5}
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME5}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fileid_list}=  Create List   ${fileid1} 
    ${share1}=      Create Dictionary     owner=${id}      ownerType=Provider
    
    ${sharedto}=    Create List      ${share1}  
    
    ${commessage}=  Fakerlibrary.Sentence
    ${medium}=     Create Dictionary     email=${bool[1]}      pushNotification=${bool[1]}    
    ${communication}=   Create Dictionary    medium=${medium}    commessage=${commessage}
   

    ${resp}=    Imageupload.ShareFilesInJaldeeDrive     ${cookie}   ${sharedto}      ${fileid_list}   ${communication}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     401
    Should Be Equal As Strings  "${resp.json()}"     "${NoAccess}"
 
   
  
JD-TC-ShareFiles-UH3

    [Documentation]   without login 

    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME213}    ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${fileid_list}=  Create List   ${fileid1} 
    ${share1}=      Create Dictionary     owner=${id}      ownerType=Provider
    
    ${sharedto}=    Create List      ${share1}  
    
    ${commessage}=  Fakerlibrary.Sentence
    ${medium}=     Create Dictionary     email=${bool[1]}      pushNotification=${bool[1]}    
    ${communication}=   Create Dictionary    medium=${medium}    commessage=${commessage}
   

    ${resp}=    Imageupload.ShareFilesInJaldeeDrive     ${empty}   ${sharedto}      ${fileid_list}   ${communication}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     419
    Should Be Equal As Strings  "${resp.json()}"       "${SESSION_EXPIRED}"
 
    
JD-TC-ShareFiles-UH4

    [Documentation]   empty file id

    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME213}    ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${fileid_list}=  Create List   ${fileid1} 
    ${share1}=      Create Dictionary     owner=${id}      ownerType=Provider
    
    ${sharedto}=    Create List      ${share1}  
    ${emptylist}=    Create List  
    
    ${commessage}=  Fakerlibrary.Sentence
    ${medium}=     Create Dictionary     email=${bool[1]}      pushNotification=${bool[1]}    
    ${communication}=   Create Dictionary    medium=${medium}    commessage=${commessage}
   

    ${resp}=    Imageupload.ShareFilesInJaldeeDrive     ${cookie}   ${sharedto}      ${emptylist}   ${communication}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     422
    Should Be Equal As Strings  "${resp.json()}"       "${INVALID_INPUT}"
 
JD-TC-ShareFiles-UH5
    
    [Documentation]   empty  communication feild

    ${resp}=   Encrypted Provider Login  ${PUSERNAME88}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    # ${p_id}=  get_acc_id  ${PUSERNAME213}

    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME88}    ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${fileid_list}=  Create List   ${fileid1} 
    ${share1}=      Create Dictionary     owner=${id}      ownerType=Provider
    
    ${sharedto}=    Create List      ${share1}  
    ${emptylist}=    Create List  
    
    ${commessage}=  Fakerlibrary.Sentence
    ${medium}=     Create Dictionary     email=${bool[1]}      pushNotification=${bool[1]}    
    ${communication}=   Create Dictionary    medium=${medium}    commessage=${commessage}
   

    ${resp}=    Imageupload.ShareFilesInJaldeeDrive     ${cookie}   ${sharedto}    ${fileid_list}    ${emptylist}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    # Should Be Equal As Strings  "${resp.json()}"       "${INVALID_INPUT}"
 


JD-TC-ShareFiles-8

    [Documentation]  share file user to user


    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${p_id}=  get_acc_id  ${HLPUSERNAME0}


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

    FOR   ${a}  IN RANGE   ${count}

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

    ${list1}=  Create Dictionary         owner=${uidA}  fileName=${docfile}    fileSize=${filesize}     caption=${caption1}     fileType=${fileType51}   order=113
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
  
  
    
    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUsrNm[0]}    ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${fileid_list}=  Create List   ${fileid51} 
    ${share1}=      Create Dictionary     owner=${uidB}      ownerType=Provider
    
    ${sharedto}=    Create List      ${share1}  
    
    ${commessage}=  Fakerlibrary.Sentence
    ${medium}=     Create Dictionary     email=${bool[1]}      pushNotification=${bool[1]}    
    ${communication}=   Create Dictionary    medium=${medium}    commessage=${commessage}
   

    ${resp}=    Imageupload.ShareFilesInJaldeeDrive     ${cookie}   ${sharedto}      ${fileid_list}   ${communication}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
  


JD-TC-ShareFiles-9

    [Documentation]   more files share more than 10 consumers

    ${resp}=  Encrypted Provider Login  ${PUSERNAME88}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${acc_id123}=  get_acc_id  ${PUSERNAME88}
    Set Test Variable    ${acc_id123}
    ${id}=  get_id  ${PUSERNAME88}
    Set Suite Variable  ${id}
  


    FOR   ${a}  IN RANGE   17
            
            ${cons_num}    Random Int  min=123456   max=999999
            ${CUSERPH}=  Evaluate  ${CUSERNAME}+${cons_num}
            Set Test Variable  ${CUSERPH${a}}  ${CUSERPH}
            ${resp}=  AddCustomer  ${CUSERPH${a}}
            Log  ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Test Variable  ${cid${a}}  ${resp.json()}

            ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${a}}
            Log   ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200
            Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

    END
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${0}}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${0}}


    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${docfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${docfile}
    Set Suite Variable    ${fileType5}
    ${list1}=  Create Dictionary         owner=${id}   fileName=${docfile}    fileSize=${filesize}     caption=${caption3}     fileType=${fileType5}   order=1
    
    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${bmpfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${bmpfile}
    Set Suite Variable    ${fileType5}
    ${list2}=  Create Dictionary         owner=${id}   fileName=${bmpfile}    fileSize=${filesize}     caption=${caption3}     fileType=${fileType5}   order=2
  
    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${txtfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${txtfile}
    Set Suite Variable    ${fileType5}
    ${list3}=  Create Dictionary         owner=${id}   fileName=${txtfile}    fileSize=${filesize}     caption=${caption3}     fileType=${fileType5}   order=3
   
    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${docfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${docfile}
    Set Suite Variable    ${fileType5}
    ${list4}=  Create Dictionary         owner=${id}   fileName=${docfile}    fileSize=${filesize}     caption=${caption3}     fileType=${fileType5}   order=4
  
    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${mp4file}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${mp4file}
    Set Suite Variable    ${fileType5}
    ${list5}=  Create Dictionary         owner=${id}   fileName=${mp4file}    fileSize=${filesize}     caption=${caption3}     fileType=${fileType5}   order=5
   
    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${xlfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${xlfile}
    Set Suite Variable    ${fileType5}
    ${list6}=  Create Dictionary         owner=${id}   fileName=${xlfile}    fileSize=${filesize}     caption=${caption3}     fileType=${fileType5}   order=6
  
    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${mp4file}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${mp4file}
    Set Suite Variable    ${fileType5}
    ${list7}=  Create Dictionary         owner=${id}   fileName=${mp4file}    fileSize=${filesize}     caption=${caption3}     fileType=${fileType5}   order=7
   
    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${pdffile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${pdffile}
    Set Suite Variable    ${fileType5}
    ${list8}=  Create Dictionary         owner=${id}   fileName=${pdffile}    fileSize=${filesize}     caption=${caption3}     fileType=${fileType5}   order=8
   
    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${giffile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${giffile}
    Set Suite Variable    ${fileType5}
    ${list9}=  Create Dictionary         owner=${id}   fileName=${giffile}    fileSize=${filesize}     caption=${caption3}     fileType=${fileType5}   order=9
   
    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType5}
    ${list10}=  Create Dictionary         owner=${id}   fileName=${jpgfile}    fileSize=${filesize}    caption=${caption3}     fileType=${fileType5}   order=10
  
    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${pngfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${pngfile}
    Set Suite Variable    ${fileType5}
    ${list11}=  Create Dictionary         owner=${id}   fileName=${pngfile}    fileSize=${filesize}     caption=${caption3}     fileType=${fileType5}   order=11
      
    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${mp3file}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${mp3file}
    Set Suite Variable    ${fileType5}
    ${list12}=  Create Dictionary         owner=${id}   fileName=${mp3file}    fileSize=${filesize}    caption=${caption3}     fileType=${fileType5}   order=12
 
    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${mp3file}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${mp3file}
    Set Suite Variable    ${fileType5}
    ${list13}=  Create Dictionary         owner=${id}   fileName=${mp3file}    fileSize=${filesize}     caption=${caption3}     fileType=${fileType5}   order=13


    ${list}=   Create List     ${list1}   ${list11}   ${list2}   ${list3}   ${list4}   ${list5}  ${list6}  ${list7}   ${list8}  ${list9}  ${list10}     ${list12} 

    ${resp}=    Upload To Private Folder      privateFolder    ${id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
    ${resp}=   Get by Criteria              account-eq=${acc_id123}
    Log                                     ${resp.content}
    Set Suite Variable     ${fileid1}       ${resp.json()['${id}']['files'][0]['id']} 
    Set Suite Variable     ${fileid2}       ${resp.json()['${id}']['files'][1]['id']} 
    Set Suite Variable     ${fileid3}       ${resp.json()['${id}']['files'][2]['id']} 
    Set Suite Variable     ${fileid4}       ${resp.json()['${id}']['files'][3]['id']} 
    Set Suite Variable     ${fileid5}       ${resp.json()['${id}']['files'][4]['id']} 
    Set Suite Variable     ${fileid6}       ${resp.json()['${id}']['files'][5]['id']} 
    Set Suite Variable     ${fileid7}       ${resp.json()['${id}']['files'][6]['id']} 
    Set Suite Variable     ${fileid8}       ${resp.json()['${id}']['files'][7]['id']} 
    Set Suite Variable     ${fileid9}       ${resp.json()['${id}']['files'][8]['id']} 
   

    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME88}    ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200


    ${fileid_list}=  Create List    ${fileid1}  ${fileid2}   ${fileid3}   ${fileid4}  ${fileid5}   ${fileid6}  ${fileid7}   ${fileid8}    ${fileid9}    

    ${share}=       Create Dictionary     owner=${cid9}        ownerType=ProviderConsumer
    ${share1}=      Create Dictionary     owner=${cid7}       ownerType=ProviderConsumer
    ${share3}=      Create Dictionary     owner=${cid0}       ownerType=${ownerType[1]}
    ${share4}=      Create Dictionary     owner=${cid1}       ownerType=${ownerType[1]}
    ${share5}=      Create Dictionary     owner=${cid2}       ownerType=${ownerType[1]}
    ${share6}=      Create Dictionary     owner=${cid3}       ownerType=${ownerType[1]}
    ${share7}=      Create Dictionary     owner=${cid4}       ownerType=${ownerType[1]}
    ${share8}=      Create Dictionary     owner=${cid5}       ownerType=${ownerType[1]}
    ${share9}=      Create Dictionary     owner=${cid6}       ownerType=${ownerType[1]}
    ${share10}=      Create Dictionary     owner=${cid10}       ownerType=${ownerType[1]}
    ${share11}=      Create Dictionary     owner=${cid8}       ownerType=${ownerType[1]}
    ${share12}=      Create Dictionary     owner=${cid11}       ownerType=${ownerType[1]}
    ${share13}=      Create Dictionary     owner=${cid12}       ownerType=${ownerType[1]}
    # #${share14}=      Create Dictionary     owner=${cid13}       ownerType=${ownerType[1]}




    ${sharedto}=    Create List   ${share}   ${share1}   ${share3}     ${share4}   ${share5}  ${share6}   ${share7}   ${share8}    ${share9}     ${share10}    ${share11}    ${share12}   ${share13}
    #  ${share9}   ${share10}  ${share11} ${share12}  ${share13}  

    ${commessage}=  Fakerlibrary.Sentence
    ${medium}=     Create Dictionary     email=${bool[1]}      pushNotification=${bool[1]}    
    ${communication}=   Create Dictionary    medium=${medium}    commessage=${commessage}
   

    ${resp}=    Imageupload.ShareFilesInJaldeeDrive     ${cookie}   ${sharedto}      ${fileid_list}   ${communication}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
