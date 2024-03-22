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
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables          /ebs/TDD/varfiles/hl_musers.py




*** Variables ***
@{countryCode}   91  +91  48 
${CUSERPH}                ${CUSERNAME}
${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf
${SERVICE1}  Consultation 
${SERVICE2}  Scanning
${SERVICE3}  Scannings111
${SERVICE12}   numbers
${SERVICE23}    okperf
${SERVICE32}      thanku
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
${SERV}     CHECK 
${xlFile}      ${EXECDIR}/TDD/sampleqnr.xlsx    # DataSheet
${xlFile2}      ${EXECDIR}/TDD/qnr.xlsx    # DataSheet 2
@{folderName}      privateFolder     publicFolder
@{ownerType}   Provider  ProviderConsumer 


***Test Cases***

JD-TC-GetCountinFilterByProvider-1

    [Documentation]  get count of file by using provider id
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME257}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${acc_id}=  get_acc_id  ${PUSERNAME257}
    Set Suite Variable    ${acc_id}
    ${id}=  get_id  ${PUSERNAME257}
    Set Suite Variable  ${id}
   
    clear_Providermsg   ${PUSERNAME257}

    clear_customer      ${PUSERNAME257}

  
    ${caption1}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}

    ${resp}=  db.getType   ${pngfile}
    Log  ${resp}
    
    ${fileType1}=  Get From Dictionary       ${resp}    ${pngfile}
    Set Suite Variable    ${fileType1}


    #Set Text Variable  ${data.json}
    ${list1}=  Create Dictionary         owner=${id}   fileName=${jpegfile}    fileSize=0.076    caption=${caption1}     fileType=${fileType}   order=0
    ${list2}=  Create Dictionary         owner=${id}   fileName=${pngfile}    fileSize=0.00176    caption=${caption1}     fileType=${fileType1}   order=1
  
    ${list}=   Create List     ${list1}   ${list2}


    ${resp}=    Upload To Private Folder      privateFolder    ${id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200

   
  
    ${resp}=   Get Count File In a filter By provider      ${id}     
    Log  ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}                     200
    Should Be Equal As Strings                 ${resp.json()}    2
   


JD-TC-GetCountinFilterByProvider-2

    [Documentation]   get count of files to upload jaldeedrive folder by using provider

    ${resp}=  Encrypted Provider Login    ${PUSERNAME7}   ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${acc_id}=  get_acc_id  ${PUSERNAME7}
    Set Test Variable  ${acc_id}
    ${id1}=  get_id  ${PUSERNAME7}
    Set Suite Variable  ${id1}
    clear_Providermsg   ${PUSERNAME7}


    ${caption1}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}

    ${resp}=  db.getType   ${pngfile}
    Log  ${resp}
    
    ${fileType1}=  Get From Dictionary       ${resp}    ${pngfile}
    Set Suite Variable    ${fileType1}


    #Set Text Variable  ${data.json}
    ${list1}=  Create Dictionary         owner=${id1}   fileName=${jpegfile}    fileSize=0.076    caption=${caption1}     fileType=${fileType}   order=0
    ${list2}=  Create Dictionary         owner=${id1}   fileName=${pngfile}    fileSize=0.00176    caption=${caption1}     fileType=${fileType1}   order=1
  
    ${list}=   Create List     ${list1}   ${list2}


    ${resp}=    Upload To Private Folder      privateFolder    ${id1}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200

    ${caption2}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${pdffile}
    Log  ${resp}
    
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile}
    Set Suite Variable    ${fileType}

    ${resp}=  db.getType   ${pngfile}
    Log  ${resp}
    
    ${fileType1}=  Get From Dictionary       ${resp}    ${pngfile}
    Set Suite Variable    ${fileType1}


    #Set Text Variable  ${data.json}
    ${list1}=  Create Dictionary         owner=${id1}   fileName=${pdffile}    fileSize=0.076    caption=${caption1}     fileType=${fileType}   order=0
    ${list2}=  Create Dictionary         owner=${id1}   fileName=${pngfile}    fileSize=0.00176    caption=${caption1}     fileType=${fileType1}   order=1
  
    ${list}=   Create List     ${list1}   ${list2}


    ${resp}=    Upload To Private Folder      privateFolder    ${id1}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200

    ${resp}=   Get Count File In a filter By provider      ${id1}     
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings                 ${resp.json()}    4
   

JD-TC-GetCountinFilterByProvider-3

    [Documentation]  get count of files - by provider with filter file type
   
    # ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${c_id}=  get_id  ${CUSERNAME6}
    # ${resp}=   Consumer Logout         
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
  
    # ${resp}=  Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${acc_id3}=  get_acc_id  ${PUSERNAME9}
    # Set Test Variable    ${acc_id3}
    # ${id3}=  get_id  ${PUSERNAME9}
    # Set Suite Variable  ${id3}

    # ${resp}=   Get jaldeeIntegration Settings
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
    #     ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    #     Should Be Equal As Strings  ${resp1.status_code}  200
    # ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
    #     ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    #     Should Be Equal As Strings  ${resp1.status_code}  200
    # END

    # ${resp}=   Get jaldeeIntegration Settings
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

   
    # ${emptylist}=  Create List
    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}  
    # Log  ${resp.content}
    # Should Be Equal As Strings      ${resp.status_code}  200
    # IF   '${resp.content}' == '${emptylist}'
    #     ${resp1}=  AddCustomer  ${CUSERNAME6} 
    #     Log  ${resp1.content}
    #     Should Be Equal As Strings  ${resp1.status_code}  200
    #     Set Suite Variable  ${cid6}   ${resp1.json()}
    # ELSE
    #     Set Suite Variable  ${cid6}  ${resp.json()[0]['id']}
    # END
    # ${resp}=  Provider Logout
    # Should Be Equal As Strings  ${resp.status_code}                      200
 
    # ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${c_id}=  get_id  ${CUSERNAME6}
    # clear_Consumermsg  ${CUSERNAME6}
    # ${msg}=   FakerLibrary.Word
    # ${caption}=  Fakerlibrary.sentence

    # ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME6}   ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id3}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${pdffile}  
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Get Consumer Communications
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200 
    
    #  ${resp}=   Consumer Logout         
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=   Get List Of Shared 0wners    ${ownerType[1]}        ${cid6}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}                      200

    ${resp}=  Encrypted Provider Login    ${PUSERNAME7}   ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Count File In a filter By provider      ${id1}     fileType-eq=userId::${id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings                 ${resp.json()}    4
   
  
 
    ${resp}=   Get Count File In a filter By provider      ${id1}      SharedToProviders-eq=userId::${id1}
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}    200
    Should Be Equal As Strings          ${resp.json()}         4
  

  
JD-TC-GetCountinFilterByProvider-4

    [Documentation]    get count of files by user

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME18}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${HLMUSERNAME18} 
    Set Suite variable     ${pid}
    ${id2}=  get_id  ${HLMUSERNAME18}
    Set Suite Variable    ${id2}

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

  
    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${HLMUSERNAME18} 
    clear_appt_schedule   ${HLMUSERNAME18}
    
    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()}

    FOR  ${p}  IN RANGE  5
        ${ran int}=    Generate Random String    length=4    chars=[NUMBERS]
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

    

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH0}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERPH0}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}
  
   
    ${resp}=  SendProviderResetMail   ${PUSERPH0}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERPH0}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}


    # clear_Consumermsg  ${CUSERNAME2}
    # clear_Providermsg  ${PUSERPH0}

    # ${resp}=  Consumer Login  ${CUSERNAME2}   ${PASSWORD}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${cid2}=  get_id  ${CUSERNAME2}
    
    # ${msg2}=   FakerLibrary.Word
    # ${caption2}=  Fakerlibrary.sentence

    # ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
 
    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME2}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200 
    
    # ${resp}=  Imageupload.GeneralUserCommunicationWithProvider   ${cookie}   ${pid}  ${u_id}   ${msg2}  ${messageType[0]}  ${caption2}  ${EMPTY}  ${jpgfile}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

   
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
     ${caption1}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}

    #Set Text Variable  ${data.json}
    ${list1}=  Create Dictionary         owner=${u_id}   fileName=${jpegfile}    fileSize=0.0085     caption=${caption1}     fileType=${fileType}   order=0
    ${list}=   Create List     ${list1}

    ${resp}=    Upload To Private Folder      privateFolder    ${u_id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
    Should Be Equal As Strings                 ${resp.json()[0]['orderId']}      0 
   
    ${resp}=   Get Count File In a filter By provider      ${u_id}   
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}    200
    Should Be Equal As Strings                 ${resp.json()}    1
  


JD-TC-GetCountinFilterByProvider-5

    [Documentation]    upload file by branch and get count of files number by using user login
   
    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME18}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${HLMUSERNAME18} 
    Set Suite variable     ${pid}
    ${id2}=  get_id  ${HLMUSERNAME18}
    Set Suite Variable    ${id2}


    ${caption1}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${txtfile}
    Log  ${resp}
    
    ${fileType1}=  Get From Dictionary       ${resp}    ${txtfile}
    Set Suite Variable    ${fileType1}


    ${list1}=  Create Dictionary         owner=${id}   fileName=${txtfile}    fileSize=0.076    caption=${caption1}     fileType=${fileType1}   order=3
   # ${list2}=  Create Dictionary         owner=${id}   fileName=${pngfile}    fileSize=0.00176    caption=${caption1}     fileType=${fileType1}   order=1
  
    ${list}=   Create List     ${list1}   


    ${resp}=    Upload To Private Folder      privateFolder    ${id2}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Count File In a filter By provider      ${id2}    
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}    200
    Should Be Equal As Strings                 ${resp.json()}    1
  

JD-TC-GetCountinFilterByProvider-6

    [Documentation]    upload file by user and get count of files number by using branch login
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_Providermsg   ${PUSERPH0}

    ${caption1}=  Fakerlibrary.Sentence
 
    ${resp}=  db.getType   ${docfile}
    Log  ${resp}
    
    ${fileType2}=  Get From Dictionary       ${resp}    ${docfile}
    Set Suite Variable    ${fileType2}


    ${list1}=  Create Dictionary         owner=${id}   fileName=${docfile}    fileSize=0.076    caption=${caption1}     fileType=${fileType2}   order=3
   # ${list2}=  Create Dictionary         owner=${id}   fileName=${pngfile}    fileSize=0.00176    caption=${caption1}     fileType=${fileType1}   order=1
  
    ${list}=   Create List     ${list1}   


    ${resp}=    Upload To Private Folder      privateFolder    ${u_id}     ${list}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log                                        ${resp.content}
    Should Be Equal As Strings                 ${resp.status_code}                200
 

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME18}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_Providermsg   ${HLMUSERNAME18} 

    ${pid}=  get_acc_id  ${HLMUSERNAME18} 
    Set Suite variable     ${pid}
    ${id2}=  get_id  ${HLMUSERNAME18}
    Set Suite Variable    ${id2}
    
    ${resp}=   Get Count File In a filter By provider     ${u_id}     
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}    200
    Should Be Equal As Strings                 ${resp.json()}    2

JD-TC-GetCountinFilterByProvider-7

    [Documentation]  get count of file by using provider id

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${acc_id1}=  get_acc_id  ${PUSERNAME7}
    Set Suite Variable    ${acc_id1}
    ${id3}=  get_id  ${PUSERNAME7}
    Set Suite Variable  ${id3}
   
    clear_Providermsg   ${PUSERNAME7}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

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


    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME8}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid8}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid8}  ${resp.json()[0]['id']}
    END   
    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${c_id}=  get_id  ${CUSERNAME8}
    clear_Consumermsg  ${CUSERNAME8}
    
    ${msg}=   FakerLibrary.Word
    ${caption}=  Fakerlibrary.sentence

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME8}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id1}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${pdffile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get List Of Shared 0wners    ${ownerType[0]}    ${id3}
    Log  ${resp.content}
    ${FLength}=  Get Length  ${resp.json()}


    ${resp}=   Get Count File In a filter By provider       ${id3}   
    Log  ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}                     200
    Should Be Equal As Strings                 ${resp.json()}    ${FLength}
   
  

JD-TC-GetCountinFilterByProvider-UH1

    [Documentation]     Consumer Login

    ${resp}=   ConsumerLogin  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Count File In a filter By provider     ${u_id}     
    Log                                 ${resp.content}
    Should Be Equal As Strings           ${resp.status_code}  401
    Should Be Equal As Strings           ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-GetCountinFilterByProvider-UH2

    [Documentation]    Withoutlogin
      
    ${resp}=   Get Count File In a filter By provider     ${u_id}     
    Log                                 ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}  419
    Should Be Equal As Strings          ${resp.json()}   ${SESSION_EXPIRED}
 
JD-TC-GetCountinFilterByProvider-UH3

    [Documentation]    empty id 
    
    ${resp}=  Encrypted Provider Login   ${PUSERNAME9}    ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Count File In a filter By provider     ${empty}     
    Log                                 ${resp.content}
   
JD-TC-GetCountinFilterByProvider-UH5

    [Documentation]    invalid provider  id 
    
    ${resp}=  Encrypted Provider Login   ${PUSERNAME9}    ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Count File In a filter By provider     000     
    Log         ${resp.content}
   
JD-TC-GetCountinFilterByProvider-UH6

    [Documentation]   another provider login
    
    ${resp}=  Encrypted Provider Login   ${PUSERNAME11}    ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Count File In a filter By provider     ${id}   
    Log         ${resp.content}
   