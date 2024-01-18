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
Variables          /ebs/TDD/varfiles/hl_musers.py
Variables         /ebs/TDD/varfiles/musers.py
Library           /ebs/TDD/Imageupload.py






*** Variables ***
@{countryCode}   91  +91  48 
${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf
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
@{folderName}      privateFolder     publicFolder

***Test Cases***

JD-TC-GetaFileusingShortUrl-1

    [Documentation]  get pdf file using short url

    clear_customer      ${PUSERNAME21}
 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${PUSERNAME21}
    ${acc_id}=  get_acc_id  ${PUSERNAME21}
    Set Test Variable   ${acc_id}
    ${id}=  get_id  ${PUSERNAME21}
    Set Test Variable  ${id}

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME2}
    clear_Consumermsg  ${CUSERNAME2}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

   
    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${pdffile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login     ${PUSERNAME21}   ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
 
   
    ${resp}=   Get by Criteria          fileType-eq=pdf
    Log                                 ${resp.content}
    Set Test Variable   ${fileid}        ${resp.json()['${cid}']['files'][0]['id']}   
   # Set Test Variable   ${sharedType}        ${resp.json()[0]['sharedType']}   

    ${resp}=  Encoded Short Url    ${fileid}   ${ownerType[1]}  ${id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Set Suite Variable    ${driveid}     ${resp.json()}
    

    ${resp}=    Get a File Using Short Url    ${driveid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200


   
JD-TC-GetaFileusingShortUrl-2

    [Documentation]   get png file using short url

    clear_customer      ${PUSERNAME21}
 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${PUSERNAME21}
    ${acc_id}=  get_acc_id  ${PUSERNAME21}
    Set Test Variable   ${acc_id}
    ${id}=  get_id  ${PUSERNAME21}
    Set Test Variable  ${id}

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME2}
    clear_Consumermsg  ${CUSERNAME2}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

   
    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${pngfile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login     ${PUSERNAME21}   ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
 
   
    ${resp}=   Get by Criteria          fileType-eq=png
    Log                                 ${resp.content}
    Set Test Variable   ${fileid}       ${resp.json()['${cid}']['files'][0]['id']}   
   # Set Test Variable   ${sharedType}        ${resp.json()[0]['sharedType']}   

    ${resp}=  Encoded Short Url    ${fileid}   ${ownerType[1]}   ${id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Set Suite Variable    ${driveid}     ${resp.json()}
    

    ${resp}=    Get a File Using Short Url    ${driveid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
   # Should Contain    ${resp.json()}    png
   

JD-TC-GetaFileusingShortUrl-3

    [Documentation]   get jpg file using short url

    clear_customer      ${PUSERNAME21}
 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${PUSERNAME21}
    ${acc_id}=  get_acc_id  ${PUSERNAME21}
    Set Test Variable   ${acc_id}
    ${id}=  get_id  ${PUSERNAME21}
    Set Test Variable  ${id}

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME2}
    clear_Consumermsg  ${CUSERNAME2}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

   
    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpgfile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login     ${PUSERNAME21}   ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
 
   
    ${resp}=   Get by Criteria          fileType-eq=jpg
    Log                                 ${resp.content}
    Set Test Variable   ${fileid}       ${resp.json()['${cid}']['files'][0]['id']}   
  
    ${resp}=  Encoded Short Url    ${fileid}    ${ownerType[1]}   ${id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Set Suite Variable    ${driveid}     ${resp.json()}
    

    ${resp}=    Get a File Using Short Url    ${driveid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
   

JD-TC-GetaFileusingShortUrl-4

    [Documentation]   get gif file using short url

    clear_customer      ${PUSERNAME21}
 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${PUSERNAME21}
    ${acc_id}=  get_acc_id  ${PUSERNAME21}
    Set Test Variable   ${acc_id}
    ${id}=  get_id  ${PUSERNAME21}
    Set Test Variable  ${id}

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME2}
    clear_Consumermsg  ${CUSERNAME2}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

   
    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${giffile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login     ${PUSERNAME21}   ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
 
   
    ${resp}=   Get by Criteria          fileType-eq=gif
    Log                                 ${resp.content}
    Set Test Variable   ${fileid}       ${resp.json()['${cid}']['files'][0]['id']}   
   # Set Test Variable   ${sharedType}        ${resp.json()[0]['sharedType']}   

    ${resp}=  Encoded Short Url    ${fileid}    ${ownerType[1]}   ${id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Set Suite Variable    ${driveid}     ${resp.json()}
    

    ${resp}=    Get a File Using Short Url    ${driveid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
   # Should Contain    ${resp.json()}    png
   
JD-TC-GetaFileusingShortUrl-5

    [Documentation]   get jpeg file using short url

    clear_customer      ${PUSERNAME2}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${PUSERNAME2}
    ${acc_id12}=  get_acc_id  ${PUSERNAME2}
    Set Test Variable   ${acc_id12}
    ${id}=  get_id  ${PUSERNAME2}
    Set Test Variable  ${id}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid18}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid18}  ${resp.json()[0]['id']}
    END
  

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME13}
    clear_Consumermsg  ${CUSERNAME13}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME13}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

   
    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id12}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpegfile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login     ${PUSERNAME2}   ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
 
   
    ${resp}=   Get by Criteria          account-eq=${acc_id12}
    Log                                 ${resp.content}
    Set Test Variable   ${fileid}       ${resp.json()['${cid}']['files'][0]['id']}   
   # Set Test Variable   ${sharedType}        ${resp.json()[0]['sharedType']}   

    ${resp}=  Encoded Short Url    ${fileid}   ${ownerType[1]}   ${id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Set Suite Variable    ${driveid123}     ${resp.json()}
    

    ${resp}=    Get a File Using Short Url    ${driveid123} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200


JD-TC-GetaFileusingShortUrl-6

    [Documentation]   get txt file using short url

    clear_customer      ${PUSERNAME21}
 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${PUSERNAME21}
    ${acc_id}=  get_acc_id  ${PUSERNAME21}
    Set Test Variable   ${acc_id}
    ${id}=  get_id  ${PUSERNAME21}
    Set Test Variable  ${id}

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME2}
    clear_Consumermsg  ${CUSERNAME2}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

   
    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${txtfile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login     ${PUSERNAME21}   ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
 
   
    ${resp}=   Get by Criteria          fileType-eq=txt
    Log                                 ${resp.content}
    Set Test Variable   ${fileid}       ${resp.json()['${cid}']['files'][0]['id']}   
   # Set Test Variable   ${sharedType}        ${resp.json()[0]['sharedType']}   

    ${resp}=  Encoded Short Url    ${fileid}   ${ownerType[1]}    ${id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Set Suite Variable    ${driveid}     ${resp.json()}
    

    ${resp}=    Get a File Using Short Url    ${driveid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200


JD-TC-GetaFileusingShortUrl-7

    [Documentation]   get doc file using short url

    clear_customer      ${PUSERNAME21}
 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${PUSERNAME21}
    ${acc_id}=  get_acc_id  ${PUSERNAME21}
    Set Test Variable   ${acc_id}
    ${id}=  get_id  ${PUSERNAME21}
    Set Test Variable  ${id}

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME2}
    clear_Consumermsg  ${CUSERNAME2}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

   
    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${docfile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login     ${PUSERNAME21}   ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}# 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
 
   
    ${resp}=   Get by Criteria          fileType-eq=doc
    Log                                 ${resp.content}
    Set Test Variable   ${fileid}       ${resp.json()['${cid}']['files'][0]['id']}   
   # Set Test Variable   ${sharedType}        ${resp.json()[0]['sharedType']}   

    ${resp}=  Encoded Short Url    ${fileid}   ${ownerType[1]}   ${id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Set Suite Variable    ${driveid}     ${resp.json()}
    

    ${resp}=    Get a File Using Short Url    ${driveid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
  
JD-TC-GetaFileusingShortUrl-UH1

	[Documentation]    upload file to jaldeedrive and get using short url

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${id}=  get_id  ${HLMUSERNAME2}
    Set Test Variable  ${id}
    ${p_id}=  get_acc_id  ${HLMUSERNAME2}
    Set Test Variable   ${p_id}

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
    Set Suite Variable  ${u_id1}  ${resp.json()}


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



    ${caption1}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${pngfile}
    Log  ${resp}
    
    ${fileType}=  Get From Dictionary       ${resp}    ${pngfile}
    Set Suite Variable    ${fileType}

    #Set Text Variable  ${data.json}
    ${list1}=  Create Dictionary         owner=${u_id1}   fileName=${pngfile}    fileSize=0.0085     caption=${caption1}     fileType=${fileType}   order=0
    ${list}=   Create List     ${list1}

    ${resp}=    Upload To Private Folder      privateFolder    ${u_id1}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200

    ${resp}=   Get by Criteria        owner-eq=${u_id1} 
    Log                                 ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings                 ${resp.json()['${u_id1}']['files'][0]['account']}       ${p_id}  
    Should Be Equal As Strings                  ${resp.json()['${u_id1}']['files'][0]['owner']}         ${u_id1}  
    Should Be Equal As Strings                  ${resp.json()['${u_id1}']['files'][0]['sharedType']}    secureShare
    Set Suite Variable   ${fileid1234}          ${resp.json()['${u_id1}']['files'][0]['id']}   
   
    ${resp}=  Encoded Short Url    ${fileid1234}   ${ownerType[0]}   ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Set Suite Variable    ${driveid098}     ${resp.json()}
    

    ${resp}=    Get a File Using Short Url   ${driveid098} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     422
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_INVALID_URL}

  


  
# JD-TC-GetaFileusingShortUrl-UH1

#     [Documentation]  invalid provider id

#     ${resp}=   Encrypted Provider Login     ${PUSERNAME21}   ${PASSWORD} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200
    
   
#     ${resp}=  Encoded Short Url    ${fileid}   ${sharedType[0]}    000
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}                     200
#     Set Suite Variable    ${driveid1}     ${resp.json()}
    
# JD-TC-GetaFileusingShortUrl-UH2

#     [Documentation]  empty provider id 

#     ${resp}=   Encrypted Provider Login     ${PUSERNAME21}   ${PASSWORD} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200
    
#     ${resp}=  Encoded Short Url    ${fileid}   ${sharedType[0]}   ${empty}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}                     200
#     Set Suite Variable    ${driveid1}     ${resp.json()}

# JD-TC-GetaFileusingShortUrl-UH3

#     [Documentation]   without login

#     ${resp}=  Encoded Short Url    ${fileid}   ${sharedType[0]}     ${u_id1} 
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}                     200
#     Set Suite Variable    ${driveid1}     ${resp.json()}

# JD-TC-GetaFileusingShortUrl-UH4

#     [Documentation]  consumer login  

#     ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${c_id}=  get_id  ${CUSERNAME5}
    
#     ${resp}=  Encoded Short Url    ${fileid}   ${sharedType[0]}    ${u_id1} 
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}                     200
#     Set Suite Variable    ${driveid1}     ${resp.json()}
