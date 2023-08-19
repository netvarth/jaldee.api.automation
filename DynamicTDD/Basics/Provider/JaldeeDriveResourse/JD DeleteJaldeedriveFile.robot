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
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Library           /ebs/TDD/db.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Resource          /ebs/TDD/Keywords.robot
Variables         /ebs/TDD/varfiles/consumermail.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/hl_musers.py




*** Variables ***
@{countryCode}   91  +91  48 
${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf
${SERVICE1}  Consultation 
${SERVICE2}  Scanning
${SERVICE3}  Scannings111
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
${jpgfile}     /ebs/TDD/uploadimage.jpg
@{emptylist}
@{folderName}      privateFolder     publicFolder

${filesize}    0.0084
@{ownerType}   Provider  ProviderConsumer 

${CUSERPH}      ${CUSERNAME}


***Test Cases***


# JD-TC-DeleteJaldeedriveFile-1

#     [Documentation]  Delete  file

#     clear_Item  ${PUSERNAME12}
#     ${resp}=  ProviderLogin  ${PUSERNAME12}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${acc_id}=  get_acc_id  ${PUSERNAME12}
#     Set Test Variable   ${acc_id}
     
#     ${id1}=  get_id  ${PUSERNAME12}
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

   
#     ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME12}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=   uploadItemImages   ${id}   ${boolean[1]}   ${cookie}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
    
    
#     ${resp}=   Get Item By Id   ${id}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Not Be Equal As Strings  ${resp.json()['itemImages']}   ${EMPTY}
#     Should Be Equal As Strings    ${resp.json()['itemImages'][0]['displayImage']}   ${bool[1]}    
#     # Should Contain  ${resp.json()['itemImages']}  /item/${id}/ 

#     ${resp}=   Get by Criteria          ownerType-eq=Provider
#     Log                                 ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}                     200
#     Set Test Variable  ${fileid}       ${resp.json()['${id1}']['files'][0]['id']}   

#     ${resp}=   Delete Jaldeedrive File   ${fileid} 
#     Log                                 ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}                     200

#     ${resp}=   Get by Criteria           id-eq= ${fileid}
#     Log                                 ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}                     200
#     Should Be Equal As Strings  ${resp.json()}                     {}
   

# JD-TC-DeleteJaldeedriveFile-2

#     [Documentation]  file upload to private folder and delete file by provider

#     ${resp}=  Provider Login  ${PUSERNAME19}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${acc_id}=  get_acc_id  ${PUSERNAME19}
#     Set Test Variable  ${providerId}   ${acc_id}
#     ${id}=  get_id  ${PUSERNAME19}
#     Set Suite Variable  ${id}
   

#     ${caption1}=  Fakerlibrary.Sentence
 
#     ${resp}=  db.getType   ${jpegfile}
#     Log  ${resp}
    
#     ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
#     Set Suite Variable    ${fileType}

#     #Set Text Variable  ${data.json}
#     ${list1}=  Create Dictionary         owner=${id}   fileName=${jpegfile}    fileSize=${filesize}     caption=${caption1}     fileType=${fileType}   order=0
#     ${list}=   Create List     ${list1}
#     ${resp}=    Upload To Private Folder      privateFolder    ${id}     ${list}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Log                                        ${resp.content}
#     Should Be Equal As Strings                 ${resp.status_code}                200
    
#     ${resp}=   Get by Criteria           owner-eq=${id}
#     Log                                 ${resp.content}
#     Set Suite Variable     ${fileid1}        ${resp.json()['${id}']['files'][0]['id']} 
#     Should Be Equal As Strings     ${resp.json()['${id}']['files'][0]['account']}      ${acc_id}
#     Should Be Equal As Strings     ${resp.json()['${id}']['files'][0]['sharedType']}   secureShare
     
#     ${resp}=   Delete Jaldeedrive File   ${fileid1} 
#     Log                                 ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}                     200

#     ${resp}=   Get by Criteria          id-eq= ${fileid1}
#     Log                                 ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}                     200
#     Should Be Equal As Strings  ${resp.json()}                     {}

# JD-TC-DeleteJaldeedriveFile-3

#   [Documentation]    a file  upload by user and delete file by user

#     ${resp}=  Provider Login  ${HLMUSERNAME16}   ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${pid}=  get_acc_id  ${HLMUSERNAME16} 
#     Set Suite variable     ${pid}

#     ${highest_package}=  get_highest_license_pkg
#     Log  ${highest_package}
#     Set Suite variable  ${lic2}  ${highest_package[0]}

  
#     ${resp}=   Get License UsageInfo 
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     clear_service   ${HLMUSERNAME16} 
#     clear_appt_schedule   ${HLMUSERNAME16}
    
#     ${resp2}=   Get Business Profile
#     Log  ${resp2.json()}
#     Should Be Equal As Strings    ${resp2.status_code}    200

#     ${resp}=  View Waitlist Settings
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
#     Run Keyword If  '${resp}' != '${None}'   Log   ${resp.json()}
#     Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200
    
#     sleep  2s
#     ${dep_name1}=  FakerLibrary.bs
#     ${dep_code1}=   Random Int  min=100   max=999
#     ${dep_desc1}=   FakerLibrary.word  
#     ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${dep_id}  ${resp.json()}

#     FOR  ${p}  IN RANGE  5
#         ${ran int}=    Generate Random String    length=4    chars=[NUMBERS]
#         ${ran int}=    Convert To Integer    ${ran int}
#         ${ran int}=    Convert To Integer    ${ran int}
#         ${ran int}=    Convert To String  ${ran int}
#         ${Status}=   Run Keyword And Return Status   Should Match Regexp	${ran int}	\\d{4}
#         Exit For Loop IF  ${Status}  
#     END
#     ${ran int}=    Convert To Integer    ${ran int}
#     ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${ran int}
#     clear_users  ${PUSERPH0}
#     Set Suite Variable  ${PUSERPH0}
#     ${firstname}=  FakerLibrary.name
#     ${lastname}=  FakerLibrary.last_name
#     ${address}=  get_address
#     ${dob}=  FakerLibrary.Date
#     Set Suite Variable  ${dob}
#     ${location}=  FakerLibrary.city
#     Set Suite Variable  ${location}
#     ${state}=  FakerLibrary.state
#     Set Suite Variable   ${state}
#     FOR    ${i}    IN RANGE    3
#         ${pin}=  get_pincode
#         ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
#         IF    '${kwstatus}' == 'FAIL'
#                 Continue For Loop
#         ELSE IF    '${kwstatus}' == 'PASS'
#                 Exit For Loop
#         END
#     END
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Suite Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
#     Set Suite Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
#     Set Suite Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    


#     clear_service   ${PUSERPH0}
#     clear_appt_schedule   ${PUSERPH0}

    

#     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH0}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERPH0}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${u_id}  ${resp.json()}

#     ${resp}=  Get User By Id  ${u_id}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}
   
   
#     ${resp}=  SendProviderResetMail   ${PUSERPH0}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     @{resp}=  ResetProviderPassword  ${PUSERPH0}  ${PASSWORD}  2
#     Should Be Equal As Strings  ${resp[0].status_code}  200
#     Should Be Equal As Strings  ${resp[1].status_code}  200

#     ${resp}=  ProviderLogin  ${PUSERPH0}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=    Get Locations
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

#    ${caption1}=  Fakerlibrary.Sentence
 
#     ${resp}=  db.getType   ${jpegfile}
#     Log  ${resp}
    
#     ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
#     Set Suite Variable    ${fileType}

#     #Set Text Variable  ${data.json}
#     ${list1}=  Create Dictionary         owner=${u_id}  fileName=${jpegfile}    fileSize=${filesize}     caption=${caption1}     fileType=${fileType}   order=0
#     ${list}=   Create List     ${list1}
#     ${resp}=    Upload To Private Folder      privateFolder    ${u_id}    ${list}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Log                                        ${resp.content}
#     Should Be Equal As Strings                 ${resp.status_code}                200
    
#     ${resp}=   Get List Of Shared 0wners    ${ownerType[0]}       ${u_id}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${fileid}       ${resp.json()[0]['id']}   
   
#     ${resp}=   Delete Jaldeedrive File   ${fileid} 
#     Log                                 ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}                     200

#     ${resp}=   Get by Criteria          id-eq= ${fileid}
#     Log                                 ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}                200
#     Should Be Equal As Strings  ${resp.json()}                     {}


# JD-TC-DeleteJaldeedriveFaile-4

#     [Documentation]    a file send to consumer by provider and delete 

#     clear_Providermsg  ${PUSERNAME5}
    
#     ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${fname}   ${resp.json()['firstName']}
#     Set Suite Variable  ${lname}   ${resp.json()['lastName']}

   
#     ${jc_id}=  get_id  ${CUSERNAME15}
#     Set Test Variable   ${jc_id} 
#     clear_Consumermsg  ${CUSERNAME15}

#     ${resp}=   ProviderLogin  ${PUSERNAME5}  ${PASSWORD} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     Set Test Variable  ${p_id}  ${resp.json()['id']}
#     ${acc_id}=  get_acc_id  ${PUSERNAME5}
#     Set Test Variable   ${acc_id} 
#     ${id1}=  get_id  ${PUSERNAME5}
#     Set Test Variable  ${id1}


#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
#         ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
#         Should Be Equal As Strings  ${resp1.status_code}  200
#     ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
#         ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
#         Should Be Equal As Strings  ${resp1.status_code}  200
#     END

#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}


#     ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}  
#     Log  ${resp.content}
#     Should Be Equal As Strings      ${resp.status_code}  200
#     IF   '${resp.content}' == '${emptylist}'
#         ${resp1}=  AddCustomer  ${CUSERNAME15}  firstName=${fname}   lastName=${lname}
#         Log  ${resp1.content}
#         Should Be Equal As Strings  ${resp1.status_code}  200
#         Set Suite Variable  ${cid15}   ${resp1.json()}
#     ELSE
#         Set Suite Variable  ${cid15}  ${resp.json()[0]['id']}
#     END
#     sleep  1s
#     ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME5}   ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
    
#     ${msg}=  Fakerlibrary.sentence
#     ${caption}=  Fakerlibrary.sentence   

#     ${resp}=  Imageupload.GeneralCommunicationWithConsumer   ${cookie}   ${jc_id}  ${msg}  ${messageType[0]}  ${caption}   ${EMPTY}  ${pngfile}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

    
#     ${resp}=   Get List Of Shared 0wners    ${ownerType[0]}       ${id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${fileid}       ${resp.json()[0]['id']}   
   
#     ${resp}=   Delete Jaldeedrive File   ${fileid} 
#     Log                                 ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}                     200

#     ${resp}=   Get by Criteria          id-eq= ${fileid}
#     Log                                 ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}                200
#     Should Be Equal As Strings  ${resp.json()}                     {}
   


  

# JD-TC-DeleteJaldeedriveFile-UH1

#     [Documentation]  a file send to provider by consumer and delete file by provider login
    
#     ${resp}=  Provider Login  ${PUSERNAME214}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Test Variable  ${PUSERNAME214}
#     ${acc_id1}=  get_acc_id  ${PUSERNAME214}
#     Set Test Variable   ${acc_id1}
#     ${id3}=  get_id  ${PUSERNAME214}
#     Set Test Variable  ${id3}


#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
#         ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
#         Should Be Equal As Strings  ${resp1.status_code}  200
#     ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
#         ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
#         Should Be Equal As Strings  ${resp1.status_code}  200
#     END

#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

#     clear_customer   ${PUSERNAME214}
#     ${resp}=  AddCustomer  ${CUSERNAME3}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
   
#     ${emptylist}=  Create List
#     ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}  
#     Log  ${resp.content}
#     Should Be Equal As Strings      ${resp.status_code}  200
#     IF   '${resp.content}' == '${emptylist}'
#         ${resp1}=  AddCustomer  ${CUSERNAME6} 
#         Log  ${resp1.content}
#         Should Be Equal As Strings  ${resp1.status_code}  200
#         Set Suite Variable  ${cid28}   ${resp1.json()}
#     ELSE
#         Set Suite Variable  ${cid28}  ${resp.json()[0]['id']}
#     END

 
     
#     ${resp}=   ProviderLogout
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200


#     ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${c_id}=  get_id  ${CUSERNAME6}
#     clear_Consumermsg  ${CUSERNAME6}

#     ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME6}   ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${msg}=  Fakerlibrary.sentence
#     ${caption}=  Fakerlibrary.sentence
    
#     ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}  ${acc_id1}   ${msg}   ${messageType[0]}    ${caption}   ${EMPTY}   ${pdffile} 
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
    
   
#     ${resp}=  Get Consumer Communications
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
   
#     ${resp}=  Consumer Logout
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
    
#     ${resp}=   ProviderLogin     ${PUSERNAME214}   ${PASSWORD} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200


#     ${resp}=   Get by Criteria           account-eq=${acc_id1}
#     Log                                 ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Suite Variable  ${fileid}       ${resp.json()['${cid28}']['files'][0]['id']}   

#     ${resp}=   Delete Jaldeedrive File   ${fileid} 
#     Log                                 ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}                     200
 

JD-TC-DeleteJaldeedriveFile-UH2

    [Documentation]    a file send to user by consumer and delete file by  user login

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    
    # clear_customer     ${HLMUSERNAME4}
    ${resp}=  Provider Login  ${HLMUSERNAME4}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${HLMUSERNAME4} 
    Set Suite variable     ${pid}

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

  
    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${HLMUSERNAME4} 
    clear_appt_schedule   ${HLMUSERNAME4}
    
    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200

    ${emptylist}=  Create List
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME10} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid14}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid14}  ${resp.json()[0]['id']}
    END

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
    Run Keyword If  '${resp}' != '${None}'   Log   ${resp.json()}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()}

    FOR  ${p}  IN RANGE  5
        ${ran int}=    Generate Random String    length=5    chars=[NUMBERS]
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To String  ${ran int}
        ${Status}=   Run Keyword And Return Status   Should Match Regexp	${ran int}	\\d{4}
        Exit For Loop IF  ${Status}  
    END
    ${ran int}=    Convert To Integer    ${ran int}
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${ran int}
    clear_users  ${PUSERPH0}
    Set Suite Variable  ${PUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
    ${location}=  FakerLibrary.city
    Set Suite Variable  ${location}
    ${state}=  FakerLibrary.state
    Set Suite Variable   ${state}
    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Suite Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    


    clear_service   ${PUSERPH0}
    clear_appt_schedule   ${PUSERPH0}

    

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH0}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERPH0}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}
    # Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}   mobileNo=${PUSERPH0}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERPH0}.ynwtest@netvarth.com  city=${city}  state=${state}  deptId=${dep_id} 

   
    ${resp}=  SendProviderResetMail   ${PUSERPH0}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERPH0}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  ProviderLogin  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${PUSERPH0}
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    clear_customer   ${PUSERPH0}
    
    clear_Consumermsg  ${CUSERNAME10}
    clear_Providermsg  ${PUSERPH0}

    ${resp}=  Consumer Login  ${CUSERNAME10}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid2}=  get_id  ${CUSERNAME10}
    
    ${msg2}=   FakerLibrary.Word
    ${caption2}=  Fakerlibrary.sentence
    
    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Imageupload.GeneralUserCommunicationWithProvider   ${cookie}   ${pid}    ${u_id}   ${msg2}  ${messageType[0]}  ${caption2}  ${EMPTY}  ${jpgfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    #  ${resp}=  Imageupload.GeneralUserCommunicationWithProvider   ${cookie}   ${p_id}  ${p1_id}  ${msg2}  ${messageType[0]}  ${caption2}  ${EMPTY}  ${jpgfile}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200



    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  #  Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${cid2}
   # Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    ${u_id} 

    ${resp}=  ProviderLogin  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${resp}=  Get User communications   ${u_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${cid142}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg2}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${u_id} 

    ${resp}=   Get by Criteria          fileType-eq=jpg
    Log                                 ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Set Suite Variable     ${fileid}    ${resp.json()['${cid14}']['files'][0]['id']} 
   
    ${resp}=   Delete Jaldeedrive File   ${fileid} 
    Log                                 ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200

    ${resp}=   Get by Criteria          ownerType-eq=Provider
    Log                                 ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200

*** comment ***
JD-TC-DeleteJaldeedriveFaile-UH3

    [Documentation]  Get upload file without provider login
     
    ${resp}=   Delete Jaldeedrive File  ${fileid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     419
    Should Be Equal As Strings  "${resp.json()}"     "${SESSION_EXPIRED}"
 
JD-TC-DeleteJaldeedriveFaile-UH4

    [Documentation]  delete  file by another provider login
    clear_Providermsg  ${PUSERNAME185}

    ${resp}=   ProviderLogin     ${PUSERNAME10}   ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

   
    ${resp}=   Delete Jaldeedrive File  ${fileid}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     401
    Should Be Equal As Strings  "${resp.json()}"     "${NO_PERMISSION}"
 

JD-TC-DeleteJaldeedriveFaile-UH5

    [Documentation]   delete file with consumer login

    clear_Providermsg  ${PUSERNAME185}

    ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

   
    ${resp}=   Delete Jaldeedrive File  ${fileid}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     401
    Should Be Equal As Strings  "${resp.json()}"     "${NoAccess}"
 
    
JD-TC-DeleteJaldeedriveFile-UH6

  [Documentation]    a file upload to branch and delete user

    ${resp}=  Provider Login  ${HLMUSERNAME14}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${HLMUSERNAME14} 
    Set Suite variable     ${pid}
    ${id}=  get_id  ${HLMUSERNAME14}
    Set Test Variable  ${id}
     

   ${caption1}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}

    #Set Text Variable  ${data.json}
    ${list1}=  Create Dictionary         owner=${id}  fileName=${jpegfile}    fileSize=${filesize}      caption=${caption1}     fileType=${fileType}   order=0
    ${list}=   Create List     ${list1}
    ${resp}=    Upload To Private Folder      privateFolder   ${id}    ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
    
    # ${resp}=   Get List Of Shared 0wners    ${ownerType[0]}       ${id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get by Criteria          account-eq=${id}
    Log                                 ${resp.content}
     Set Test Variable  ${fileid}        ${resp.json()['${id}']['files'][0]['id']}   
   
    ${resp}=  Provider Login   ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
  
  
    ${resp}=   Delete Jaldeedrive File   ${fileid} 
    Log                                 ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200

    ${resp}=   Get by Criteria          id-eq= ${fileid}
    Log                                 ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                200
    

 

