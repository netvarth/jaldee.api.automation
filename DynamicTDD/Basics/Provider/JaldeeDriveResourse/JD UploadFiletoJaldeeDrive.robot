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
Variables         /ebs/TDD/varfiles/providers.py

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
#@{owner}     1  2  3  4  5  6
#@{order}     0  1  2  3  4  5 
@{ownerType}         Provider  ProviderConsumer 
${filesize}    0.0084

***Test Cases***

JD-TC-Uploadfiletojaldeedrive-1

    [Documentation]  file upload to private folder

    clear_drive   ${PUSERNAME199}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME199}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${acc_id}=  get_acc_id  ${PUSERNAME199}
    Set Test Variable  ${providerId}   ${acc_id}
    ${id}=  get_id  ${PUSERNAME199}
    Set Suite Variable  ${id}
   
    
    ${filesize1}=  Fakerlibrary.Binary
    Set Suite Variable   ${filesize1}

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
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME199}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=   Get List Of Shared 0wners    ${ownerType[0]}       ${id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings     ${resp.json()[0]['account']}      ${acc_id}
    Should Be Equal As Strings     ${resp.json()[0]['sharedType']}   secureShare
    Should Be Equal As Strings     ${resp.json()[0]['account']}      ${acc_id}
    Should Be Equal As Strings     ${resp.json()[0]['fileType']}     .jpe
 


JD-TC-Uploadfiletojaldeedrive-2
 
    [Documentation]  more than one file upload to folder

    ${resp}=  Encrypted Provider Login  ${PUSERNAME199}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${acc_id}=  get_acc_id  ${PUSERNAME199}

    ${caption1}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}

    ${caption2}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${pdffile}
    Log  ${resp}
    
    ${fileType2}=  Get From Dictionary       ${resp}    ${pdffile}
    Set Suite Variable    ${fileType2}

    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType3}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType3}


   
    ${list1}=  Create Dictionary         owner=${id}   fileName=${jpgfile}     fileSize=${filesize}    caption=${caption1}     fileType=${fileType1}   order=1
    ${list2}=  Create Dictionary         owner=${id}   fileName=${pdffile}     fileSize=${filesize}      caption=${caption2}     fileType=${fileType2}   order=2
    ${list3}=  Create Dictionary         owner=${id}   fileName=${jpegfile}    fileSize=${filesize}      caption=${caption3}     fileType=${fileType3}   order=3
    
    ${list}=   Create List     ${list1}  ${list2}  ${list3}
    ${resp}=    Upload To Private Folder      privateFolder   ${id}     ${list}
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
    Should Be Equal As Strings                 ${resp.json()[0]['orderId']}     1 
  
    ${resp}=   Get by Criteria        fileType-eq=.jpe
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['account']}       ${acc_id} 
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['owner']}         ${id} 
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['fileType']}      .jpe
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['ownerType']}     Provider 
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['sharedType']}    secureShare
  


JD-TC-Uploadfiletojaldeedrive-3

    [Documentation]   pdf file upload to jaldeedrive folder

    ${resp}=  Encrypted Provider Login  ${PUSERNAME199}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${acc_id}=  get_acc_id  ${PUSERNAME199}
    # Set Test Variable  ${providerId}   ${acc_id}
   
    ${caption1}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${pdffile}
    Log  ${resp}
    
    ${fileType4}=  Get From Dictionary       ${resp}    ${pdffile}
    Set Suite Variable    ${fileType4}

    #Set Text Variable  ${data.json}
    ${list1}=  Create Dictionary         owner=${id}   fileName=${pdffile}    fileSize=${filesize}     caption=${caption1}     fileType=${fileType4}   order=4
    ${list}=   Create List     ${list1}
    ${resp}=    Upload To Private Folder     privateFolder   ${id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}              200
   

    
    ${resp}=   Get by Criteria        fileType-eq=.pdf
    Log                                 ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['account']}       ${acc_id} 
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['owner']}         ${id} 
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['fileType']}      .pdf
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['ownerType']}     Provider 
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['sharedType']}    secureShare
  
JD-TC-Uploadfiletojaldeedrive-4

    [Documentation]   png file upload to jaldeedrive folder

    ${resp}=  Encrypted Provider Login  ${PUSERNAME199}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${acc_id}=  get_acc_id  ${PUSERNAME199}
    # Set Test Variable  ${providerId}   ${acc_id}
   
   
    ${caption1}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${pngfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${pngfile}
    Set Test Variable    ${fileType5}

    ${list1}=  Create Dictionary         owner=${id}   fileName=${pngfile}    fileSize=${filesize}    caption=${caption1}     fileType=${fileType5}   order=5
    ${list}=   Create List     ${list1}
    ${resp}=    Upload To Private Folder      privateFolder    ${id}     ${list}
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
   
    ${resp}=   Get by Criteria        fileType-eq=.png
    Log                                 ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['account']}       ${acc_id} 
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['owner']}         ${id} 
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['fileType']}      .png
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['ownerType']}     Provider 
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['sharedType']}    secureShare
  

JD-TC-Uploadfiletojaldeedrive-5

    [Documentation]   jpeg file upload to jaldeedrive folder

    ${resp}=  Encrypted Provider Login  ${PUSERNAME199}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${acc_id}=  get_acc_id  ${PUSERNAME199}
    Set Test Variable    ${acc_id}
   
   
    ${caption2}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Test Variable    ${fileType5}

    ${list1}=  Create Dictionary         owner=${id}   fileName=${jpegfile}    fileSize=${filesize}     caption=${caption2}     fileType=${fileType5}   order=6
    ${list}=   Create List     ${list1}
    ${resp}=    Upload To Private Folder      privateFolder   ${id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings                 ${resp.json()[0]['orderId']}     6
    # Should Be Equal As Strings                 ${resp.json()[0]['driveId']}     2
  

    ${resp}=   Get by Criteria        fileType-eq=.jpe
    Log                                 ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                            200
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['account']}       ${acc_id} 
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['owner']}         ${id} 
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['fileType']}      ${fileType5}
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['ownerType']}     ${ownerType[0]}
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['sharedType']}    secureShare
  


JD-TC-Uploadfiletojaldeedrive-6

    [Documentation]   gif file upload to jaldeedrive folder

    ${resp}=  Encrypted Provider Login  ${PUSERNAME199}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${acc_id}=  get_acc_id  ${PUSERNAME199}
    Set Suite Variable  ${providerId}   ${acc_id}
   
   
    ${caption1}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${giffile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${giffile}
    Set Test Variable    ${fileType5}

    ${list1}=  Create Dictionary         owner=${id}   fileName=${giffile}    fileSize=${filesize}     caption=${caption1}     fileType=${fileType5}   order=7
    ${list}=   Create List     ${list1}
    ${resp}=    Upload To Private Folder      privateFolder     ${id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Get by Criteria        fileType-eq=.gif
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['account']}       ${acc_id} 
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['owner']}         ${id} 
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['fileType']}      .gif
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['ownerType']}    ${ownerType[0]}
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['sharedType']}    secureShare
  



JD-TC-Uploadfiletojaldeedrive-7

    [Documentation]   DOC file upload to jaldeedrive folder

    ${resp}=  Encrypted Provider Login  ${PUSERNAME199}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${acc_id}=  get_acc_id  ${PUSERNAME199}
    # Set Test Variable  ${providerId}   ${acc_id}
   
   
    ${caption1}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${docfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${docfile}
    Set Test Variable    ${fileType5}

    ${list1}=  Create Dictionary         owner=${id}   fileName=${docfile}    fileSize=0.0085     caption=${caption1}     fileType=${fileType5}   order=8
    ${list}=   Create List     ${list1}
    ${resp}=    Upload To Private Folder       privateFolder    ${id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=   Get by Criteria        fileType-eq=.doc
    Log                                 ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['account']}       ${acc_id} 
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['owner']}         ${id} 
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['fileType']}      .doc
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['ownerType']}     ${ownerType[0]} 
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['sharedType']}    secureShare
  




JD-TC-Uploadfiletojaldeedrive-8

    [Documentation]   txt file upload to jaldeedrive folder

    ${resp}=  Encrypted Provider Login  ${PUSERNAME199}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${acc_id}=  get_acc_id  ${PUSERNAME199}
    # Set Test Variable  ${providerId}   ${acc_id}
   
   
    ${caption1}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${txtfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${txtfile}
    Set Test Variable    ${fileType5}

    ${list1}=  Create Dictionary         owner=${id}   fileName=${txtfile}    fileSize=0.0085     caption=${caption1}     fileType=${fileType5}   order=9
    ${list}=   Create List     ${list1}
    ${resp}=    Upload To Private Folder     privateFolder    ${id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get by Criteria        fileType-eq=${fileType5}
    Log                                 ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['account']}       ${acc_id} 
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['owner']}         ${id} 
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['fileType']}      ${fileType5}
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['ownerType']}     ${ownerType[0]}
    Should Be Equal As Strings                 ${resp.json()['${id}']['files'][0]['sharedType']}    secureShare


JD-TC-Uploadfiletojaldeedrive-9

	[Documentation]    upload pdf file to user by branch login

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${HLPUSERNAME11}
    Set Test Variable  ${HLPUSERNAME11}
    ${id}=  get_id  ${HLPUSERNAME11}
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
    Set Test Variable  ${PUSERNAME_U1}
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
    Set Test Variable  ${u_id1}  ${resp.json()}

   

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   # Set Test Variable   ${p2_id}   ${resp.json()[0]['id']}
    Set Test Variable   ${p1_id}   ${resp.json()[1]['id']}
   # Set Test Variable   ${p0_id}   ${resp.json()[2]['id']}


    ${p_id}=  get_acc_id  ${HLPUSERNAME11}
    Set Test Variable   ${p_id}
  

    ${caption1}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${pdffile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${pdffile}
    Set Test Variable    ${fileType5}

    ${list1}=  Create Dictionary         owner=${p_id}   fileName=${pdffile}    fileSize=0.0085     caption=${caption1}     fileType=${fileType5}   order=10
    ${list}=   Create List     ${list1}
    ${resp}=    Upload To Private Folder        privateFolder   ${p_id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Get by Criteria        fileType-eq=.pdf
    Log                                 ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings                 ${resp.json()['${p_id}']['files'][0]['account']}      ${p_id}  
    Should Be Equal As Strings                 ${resp.json()['${p_id}']['files'][0]['fileType']}      .pdf
    Should Be Equal As Strings                 ${resp.json()['${p_id}']['files'][0]['ownerType']}    ${ownerType[0]}
    Should Be Equal As Strings                 ${resp.json()['${p_id}']['files'][0]['sharedType']}    secureShare

   
   

JD-TC-Uploadfiletojaldeedrive-10

	[Documentation]    upload pdf file by  user 

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${HLPUSERNAME12}
    Set Test Variable  ${HLPUSERNAME12}
    ${id}=  get_id  ${HLPUSERNAME12}
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
    

    # ${resp}=  Toggle Department Enable
     #Log   ${resp.json()}
     #Should Be Equal As Strings  ${resp.status_code}  200
     #sleep  2s
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
    Set Test Variable  ${PUSERNAME_U1}
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
    Set Test Variable  ${u_id1}  ${resp.json()}

   

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   # Set Test Variable   ${p2_id}   ${resp.json()[0]['id']}
    Set Test Variable   ${p1_id}   ${resp.json()[0]['id']}
   # Set Test Variable   ${p0_id}   ${resp.json()[2]['id']}

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



    ${p_id}=  get_acc_id  ${HLPUSERNAME12}
    Set Test Variable   ${p_id}

    ${caption1}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${pdffile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${pdffile}
    Set Test Variable    ${fileType5}

    ${list1}=  Create Dictionary         owner=${p1_id}   fileName=${pdffile}    fileSize=0.0085     caption=${caption1}     fileType=${fileType5}   order=11
    ${list}=   Create List     ${list1}
    ${resp}=    Upload To Private Folder       privateFolder    ${p1_id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Get by Criteria        fileType-eq=.pdf
    Log                                 ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings                 ${resp.json()['${p1_id}']['files'][0]['account']}      ${p_id}  
    Should Be Equal As Strings                 ${resp.json()['${p1_id}']['files'][0]['owner']}         ${p1_id}  
    Should Be Equal As Strings                 ${resp.json()['${p1_id}']['files'][0]['fileType']}      .pdf
    Should Be Equal As Strings                 ${resp.json()['${p1_id}']['files'][0]['ownerType']}     ${ownerType[0]}
    Should Be Equal As Strings                 ${resp.json()['${p1_id}']['files'][0]['sharedType']}    secureShare

   


JD-TC-Uploadfiletojaldeedrive-11
    
    [Documentation]    upload  public folder to jaldeedrive 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME199}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${acc_id}=  get_acc_id  ${PUSERNAME199}
    ${id1}=  get_id  ${PUSERNAME199}
    Set Suite Variable  ${id1}
   
    ${caption1}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${pdffile}
    Log  ${resp}
    ${fileType6}=  Get From Dictionary       ${resp}    ${pdffile}
    Set Suite Variable    ${fileType6}

    ${list1}=  Create Dictionary         owner=${id1}   fileName=${pdffile}    fileSize=0.0085     caption=${caption1}     fileType=${fileType6}   order=12
    ${list}=   Create List     ${list1}
    ${resp}=    Upload To Private Folder       publicFolder    ${id1}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${resp}=   Get by Criteria        fileType-eq=.pdf
    Log                                 ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings                 ${resp.json()['${id1}']['files'][0]['account']}       ${acc_id} 
    Should Be Equal As Strings                 ${resp.json()['${id1}']['files'][0]['owner']}         ${id1} 
    Should Be Equal As Strings                 ${resp.json()['${id1}']['files'][0]['fileType']}      .pdf
    Should Be Equal As Strings                 ${resp.json()['${id1}']['files'][0]['ownerType']}     ${ownerType[0]}
   # Should Be Equal As Strings                 ${resp.json()[0]['sharedType']}    secureShare


JD-TC-Uploadfiletojaldeedrive-UH1

    [Documentation]    file upload without provider login

    ${caption1}=  Fakerlibrary.Sentence
    ${list1}=  Create Dictionary         owner=${id1}   fileName=${pdffile}    fileSize=0.0085     caption=${caption1}     fileType=${fileType6}   order=13
    ${list}=   Create List     ${list1}
  
  
    ${resp}=    Upload To Private Folder       publicFolder    ${id1}     ${list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"     "${SESSION_EXPIRED}"
 

  
JD-TC-Uploadfiletojaldeedrive-UH2

    [Documentation]   file upload to jaldeedrive folder  another providerid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME185}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${acc_id}=  get_acc_id  ${PUSERNAME185}
    Set Test Variable     ${acc_id}
    ${Pid12}=  get_id  ${PUSERNAME185}
    Set Suite Variable  ${Pid12}
     

    ${resp}=  Encrypted Provider Login  ${PUSERNAME199}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

   
    ${caption1}=  Fakerlibrary.Sentence
  
    ${list1}=  Create Dictionary         owner=${Pid12}   fileName=${pdffile}    fileSize=0.0085     caption=${caption1}     fileType=${fileType6}   order=13
    ${list}=   Create List     ${list1}
  
    ${resp}=    Upload To Private Folder       privateFolder    ${Pid12}     ${list}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  422

  
JD-TC-Uploadfiletojaldeedrive-UH3

    [Documentation]  empty file upload to jaldeedrive folder

    ${resp}=  Encrypted Provider Login  ${PUSERNAME199}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${acc_id}=  get_acc_id  ${PUSERNAME199}
    
    ${caption1}=  Fakerlibrary.Sentence
  
    ${list1}=  Create Dictionary         owner=${empty}     fileSize=0.0085     caption=${empty}     fileType=${empty}    order=${empty}
    ${list}=   Create List     ${list1}
  
    ${caption2}=  Fakerlibrary.Sentence
    ${resp}=    Upload To Private Folder     publicFolder   ${acc_id}    ${list}  
     Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings           ${resp.json()}    ${UPLOAD_ATLEAST_ONEFILE}



JD-TC-Uploadfiletojaldeedrive-UH4

    [Documentation]   file upload to jaldeedrive folder by cosumer login

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME5}
    ${caption1}=  Fakerlibrary.Sentence
  
    ${list1}=  Create Dictionary         owner=${id1}   fileName=${pdffile}    fileSize=0.0085     caption=${caption1}     fileType=${fileType6}   order=13
    ${list}=   Create List     ${list1}
  
    ${caption2}=  Fakerlibrary.Sentence
    ${resp}=    Upload To Private Folder       publicFolder    ${c_id}     ${list}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings           ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}













